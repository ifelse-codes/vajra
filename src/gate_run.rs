//! The governed-gate LIVE runner — bounded and fail-closed (S73).
//!
//! Two stations re-run a script live at close: QA (`--check-qa`, S69, streamed) and Demo-er
//! (`--check-demo`, S71, captured for the element scan). Both spawned `bash <script>` with NO
//! time limit, so a hanging script hung the close forever (reviewer-flagged S69, re-flagged S71).
//! This module gives that shared runner a recorded, generous, wall-clock TIMEOUT: a run that
//! exceeds it is KILLED and returns `Err(CannotEvaluate::Timeout)` — which each gate already
//! classifies as a BLOCK ("a check that cannot evaluate FAILS"; AGENTS.md). A timeout narrows the
//! gate (it can never PASS a close), never loosens it: normal green runs behave exactly as before.
//!
//! **S84:** the runners used to collapse two structurally different unevaluable outcomes — the
//! script hung past its bound (a slow-truth problem, the timeout is generous on purpose) and the
//! child process never spawned at all (an environment problem: bash missing, permission denied, a
//! broken path) — into the same untyped `None`. `CannotEvaluate::{Timeout, SpawnFailure}` names
//! which one happened, so a blocked close's message tells an operator what to actually go fix.
//!
//! The bound is a recorded key on the existing CONSTRAINTS spine (`verify.timeout_secs` /
//! `demo.timeout_secs`) — no new store, no new command, `vajra init` propagates the defaults.

use std::fs;
use std::io::{Read, Write};
use std::path::Path;
use std::process::{Child, Command, ExitStatus, Stdio};
use std::time::{Duration, Instant};

#[cfg(unix)]
use std::os::unix::process::CommandExt;

/// Scaffold default when the key is unrecorded (S73, disclosed): 10 minutes. Generous on purpose
/// — a real `cargo test` / verify-harness close takes minutes, so the bound kills HANGS, not slow
/// truth. A recorded `<section>.timeout_secs` wins; pre-S73 repos (no key) get this default.
pub const DEFAULT_TIMEOUT_SECS: u64 = 600;

/// How often the poll wakes to check whether the child exited. Small enough to be responsive,
/// large enough to cost nothing against a multi-minute bound.
const POLL_INTERVAL: Duration = Duration::from_millis(50);

/// Read `<section>.timeout_secs` from `.ai/CONSTRAINTS.yaml` (house-style line scan — no YAML
/// dependency; keys count only inside the named section, since `verify:` and `demo:` both carry
/// their own). A missing file/key/malformed value falls back to [`DEFAULT_TIMEOUT_SECS`]; a
/// recorded value wins. `section` is `"verify"` (QA) or `"demo"` (Demo-er).
pub fn gate_timeout(constraints_path: &Path, section: &str) -> Duration {
    let content = fs::read_to_string(constraints_path).unwrap_or_default();
    let header = format!("{section}:");
    let mut in_section = false;
    let mut secs = DEFAULT_TIMEOUT_SECS;
    for line in content.lines() {
        if !line.starts_with([' ', '\t', '#']) && line.trim_end().ends_with(':') {
            in_section = line.trim_end() == header;
            continue;
        }
        if !in_section {
            continue;
        }
        if let Some(v) = line.trim().strip_prefix("timeout_secs:") {
            // Strip any trailing `# comment`, then parse. Malformed → keep the default.
            let raw = v.split('#').next().unwrap_or("").trim();
            if let Ok(n) = raw.parse::<u64>() {
                if n > 0 {
                    secs = n;
                }
            }
        }
    }
    Duration::from_secs(secs)
}

/// Two structurally different reasons a gate's live re-run cannot produce a real exit code.
/// **Timeout:** the script ran past its recorded bound and was killed — slow truth, not an
/// environment problem. **SpawnFailure:** the child process never started at all (bash missing,
/// permission denied, a broken script path) — an environment problem, not a slow script. Before
/// S84 both collapsed into the same untyped `None`, so a blocked close's message could not tell
/// an operator which one to go fix.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CannotEvaluate {
    Timeout,
    SpawnFailure,
}

/// `<program> <script>` at `root`, spawned in its OWN process group (Unix) so a timeout can kill
/// the whole tree — a hung script's grandchildren (e.g. a `sleep` it spawned) would otherwise
/// keep the captured pipe's write end open and block the reader threads forever. `program` is
/// injectable only so `#[cfg(test)]` can force a deterministic spawn failure (an absolute,
/// guaranteed-nonexistent path) without mutating the process-global `PATH` — `cargo test --lib`
/// runs this suite alongside others that spawn real subprocesses, and a global env mutation would
/// be a flakiness landmine (recorded in the S84 prompt's Design section).
fn command_for(program: &str, root: &Path, script: &str) -> Command {
    let mut cmd = Command::new(program);
    cmd.arg(script).current_dir(root);
    // A gate re-run must NEVER read the operator's stdin: the old Demo-er `.output()` nulled it,
    // and a verify/demo script that reads stdin during a close would race — and silently consume —
    // the `--advance` confirm prompt (observed live at the S73 close). Null it for both runners.
    cmd.stdin(Stdio::null());
    #[cfg(unix)]
    cmd.process_group(0);
    cmd
}

fn bash(root: &Path, script: &str) -> Command {
    command_for("bash", root, script)
}

/// A process that exited before the timeout but without a numeric code (killed by an external
/// signal that is NOT our own timeout kill — that path returns `Err(Timeout)` before reaching
/// here) still counts as a real, non-zero outcome: never let a signal death read as success. `1`
/// is the conservative placeholder, carrying forward the same "no code means this check cannot
/// vouch for success" stance the old `Option<i32>` shape took — now expressed as a real (blocking)
/// exit code instead of a second ambiguous `None`.
fn code_or_conservative(status: &ExitStatus) -> i32 {
    status.code().unwrap_or(1)
}

/// Kill the child AND its process group (Unix) so orphaned grandchildren die too, then reap it.
/// On non-Unix, `child.kill()` alone (best effort — the gate targets bash/Unix repos anyway).
fn kill_tree(child: &mut Child) {
    #[cfg(unix)]
    {
        // The child leads its own group (pgid == pid, from `process_group(0)`); the negative pid
        // targets the whole group, so any `sleep`/subshell a hung script spawned is killed too.
        let _ = Command::new("kill")
            .arg("-KILL")
            .arg(format!("-{}", child.id()))
            .status();
    }
    let _ = child.kill();
    let _ = child.wait();
}

/// Poll `child` until it exits or `timeout` elapses. `Some(status)` = exited in time; `None` =
/// timed out (the caller kills). Polling `try_wait` needs no dependency and makes no assumption
/// about the child's stdio, so it serves both the streamed and the captured run below.
fn wait_or_timeout(child: &mut Child, timeout: Duration) -> Option<ExitStatus> {
    let deadline = Instant::now() + timeout;
    loop {
        match child.try_wait() {
            Ok(Some(status)) => return Some(status),
            Ok(None) => {
                if Instant::now() >= deadline {
                    return None;
                }
                std::thread::sleep(POLL_INTERVAL);
            }
            Err(_) => return None,
        }
    }
}

/// Re-run `script` (repo-relative) LIVE at `root` with inherited stdout/stderr (streamed — the run
/// is the evidence, shown as it happens) but NULL stdin (see `bash`), bounded by `timeout`. Returns
/// the real exit code, or `Err(CannotEvaluate)` naming WHY it cannot be evaluated: `SpawnFailure`
/// (the child never started) or `Timeout` (it ran past `timeout` and was killed). Used by the QA
/// gate — replaces its old unbounded `.status()`.
pub fn run_streamed(root: &Path, script: &str, timeout: Duration) -> Result<i32, CannotEvaluate> {
    run_streamed_inner(bash(root, script), script, timeout)
}

/// Test-only seam (S84 Design note): forces a deterministic spawn failure by pointing at a
/// guaranteed-nonexistent program path, without touching global process state.
#[cfg(test)]
fn run_streamed_with_program(
    program: &str,
    root: &Path,
    script: &str,
    timeout: Duration,
) -> Result<i32, CannotEvaluate> {
    run_streamed_inner(command_for(program, root, script), script, timeout)
}

fn run_streamed_inner(
    mut cmd: Command,
    script: &str,
    timeout: Duration,
) -> Result<i32, CannotEvaluate> {
    let mut child = match cmd.spawn() {
        Ok(c) => c,
        Err(_) => return Err(CannotEvaluate::SpawnFailure),
    };
    match wait_or_timeout(&mut child, timeout) {
        Some(status) => Ok(code_or_conservative(&status)),
        None => {
            kill_tree(&mut child);
            eprintln!("{}", timeout_notice(script, timeout));
            Err(CannotEvaluate::Timeout)
        }
    }
}

/// The line a killed run prints (streamed → live stderr; captured → stderr + folded into the
/// returned text) so the BLOCK NAMES the timeout and the script — never a silent None.
fn timeout_notice(script: &str, timeout: Duration) -> String {
    format!(
        "[vajra: TIMEOUT — killed `{script}` after exceeding the {}s gate bound; a check that cannot evaluate FAILS the close]",
        timeout.as_secs()
    )
}

/// Like [`run_streamed`] but CAPTURES stdout+stderr (for the Demo-er element scan) and echoes them
/// after the run — byte-identical to the old `.output()` behavior on normal completion — bounded by
/// `timeout`. Reader threads drain the pipes so a chatty script cannot deadlock the poll; a timeout
/// kills the child, and whatever was captured before the kill is still echoed and returned with
/// `Err(CannotEvaluate::Timeout)` (→ the gate's cannot-evaluate BLOCK). Used by the Demo-er gate.
pub fn run_captured(
    root: &Path,
    script: &str,
    timeout: Duration,
) -> (Result<i32, CannotEvaluate>, String) {
    run_captured_inner(bash(root, script), script, timeout)
}

/// Test-only seam, mirrors `run_streamed_with_program` (S84 Design note).
#[cfg(test)]
fn run_captured_with_program(
    program: &str,
    root: &Path,
    script: &str,
    timeout: Duration,
) -> (Result<i32, CannotEvaluate>, String) {
    run_captured_inner(command_for(program, root, script), script, timeout)
}

fn run_captured_inner(
    mut cmd: Command,
    script: &str,
    timeout: Duration,
) -> (Result<i32, CannotEvaluate>, String) {
    cmd.stdout(Stdio::piped()).stderr(Stdio::piped());
    let mut child = match cmd.spawn() {
        Ok(c) => c,
        Err(_) => return (Err(CannotEvaluate::SpawnFailure), String::new()),
    };
    let out_reader = read_to_end(child.stdout.take());
    let err_reader = read_to_end(child.stderr.take());
    let (code, timed_out) = match wait_or_timeout(&mut child, timeout) {
        Some(status) => (Ok(code_or_conservative(&status)), false),
        None => {
            kill_tree(&mut child);
            (Err(CannotEvaluate::Timeout), true)
        }
    };
    // Kill (above) closes the child's write ends, so both readers reach EOF and join.
    let out_bytes = out_reader.join().unwrap_or_default();
    let err_bytes = err_reader.join().unwrap_or_default();
    let _ = std::io::stdout().write_all(&out_bytes);
    let _ = std::io::stderr().write_all(&err_bytes);
    let mut text = String::from_utf8_lossy(&out_bytes).into_owned();
    text.push_str(&String::from_utf8_lossy(&err_bytes));
    if timed_out {
        let notice = timeout_notice(script, timeout);
        eprintln!("{notice}");
        text.push('\n');
        text.push_str(&notice);
    }
    (code, text)
}

/// Drain a child pipe to EOF on its own thread (so buffer pressure can't deadlock the poll).
fn read_to_end<R: Read + Send + 'static>(pipe: Option<R>) -> std::thread::JoinHandle<Vec<u8>> {
    std::thread::spawn(move || {
        let mut buf = Vec::new();
        if let Some(mut p) = pipe {
            let _ = p.read_to_end(&mut buf);
        }
        buf
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    fn repo_with(script_body: &str) -> tempfile::TempDir {
        let tmp = tempfile::tempdir().unwrap();
        let scripts = tmp.path().join("scripts");
        fs::create_dir_all(&scripts).unwrap();
        fs::write(scripts.join("s.sh"), script_body).unwrap();
        tmp
    }

    #[test]
    fn gate_timeout_defaults_when_unrecorded() {
        let tmp = tempfile::tempdir().unwrap();
        fs::write(
            tmp.path().join("C.yaml"),
            "verify:\n  required_for_done: true\n",
        )
        .unwrap();
        assert_eq!(
            gate_timeout(&tmp.path().join("C.yaml"), "verify"),
            Duration::from_secs(DEFAULT_TIMEOUT_SECS)
        );
    }

    #[test]
    fn gate_timeout_recorded_value_wins_and_is_section_scoped() {
        let tmp = tempfile::tempdir().unwrap();
        // demo records 5; verify records nothing → verify defaults, demo reads 5.
        fs::write(
            tmp.path().join("C.yaml"),
            "verify:\n  required_for_done: true\ndemo:\n  timeout_secs: 5  # fast\n",
        )
        .unwrap();
        assert_eq!(
            gate_timeout(&tmp.path().join("C.yaml"), "demo"),
            Duration::from_secs(5)
        );
        assert_eq!(
            gate_timeout(&tmp.path().join("C.yaml"), "verify"),
            Duration::from_secs(DEFAULT_TIMEOUT_SECS)
        );
    }

    #[test]
    fn gate_timeout_malformed_or_zero_falls_back_to_default() {
        let tmp = tempfile::tempdir().unwrap();
        fs::write(
            tmp.path().join("C.yaml"),
            "verify:\n  timeout_secs: not-a-number\n",
        )
        .unwrap();
        assert_eq!(
            gate_timeout(&tmp.path().join("C.yaml"), "verify"),
            Duration::from_secs(DEFAULT_TIMEOUT_SECS)
        );
        fs::write(tmp.path().join("Z.yaml"), "verify:\n  timeout_secs: 0\n").unwrap();
        assert_eq!(
            gate_timeout(&tmp.path().join("Z.yaml"), "verify"),
            Duration::from_secs(DEFAULT_TIMEOUT_SECS)
        );
    }

    /// An absolute path guaranteed not to resolve to a real binary — used to force a deterministic
    /// spawn failure without mutating the process-global `PATH` (S84 Design note: other tests in
    /// this suite spawn real subprocesses in parallel threads, so a global env mutation would be
    /// a flakiness landmine).
    const NONEXISTENT_PROGRAM: &str = "/nonexistent/vajra-s84-does-not-exist/bash";

    #[test]
    fn run_streamed_green_returns_zero() {
        let tmp = repo_with("#!/usr/bin/env bash\nexit 0\n");
        assert_eq!(
            run_streamed(tmp.path(), "scripts/s.sh", Duration::from_secs(30)),
            Ok(0)
        );
    }

    #[test]
    fn run_streamed_hang_is_killed_and_blocks() {
        let tmp = repo_with("#!/usr/bin/env bash\nsleep 5\n");
        // 300ms bound on a 5s sleep → kill (whole group) → Timeout (cannot evaluate → BLOCK).
        assert_eq!(
            run_streamed(tmp.path(), "scripts/s.sh", Duration::from_millis(300)),
            Err(CannotEvaluate::Timeout),
            "a run past its bound is killed and returns the TIMEOUT cannot-evaluate reason"
        );
    }

    #[test]
    fn run_streamed_spawn_failure_is_distinct_from_timeout() {
        let tmp = tempfile::tempdir().unwrap();
        let result = run_streamed_with_program(
            NONEXISTENT_PROGRAM,
            tmp.path(),
            "scripts/s.sh",
            Duration::from_secs(30),
        );
        assert_eq!(result, Err(CannotEvaluate::SpawnFailure));
        assert_ne!(
            result,
            Err(CannotEvaluate::Timeout),
            "a spawn failure must not be confusable with a timeout — the S73 fakest-green gap"
        );
    }

    #[test]
    fn run_captured_green_captures_output() {
        let tmp = repo_with("#!/usr/bin/env bash\necho demo:header\nexit 0\n");
        let (code, text) = run_captured(tmp.path(), "scripts/s.sh", Duration::from_secs(30));
        assert_eq!(code, Ok(0));
        assert!(text.contains("demo:header"), "captured output: {text:?}");
    }

    #[test]
    fn run_captured_hang_is_killed_and_names_the_timeout() {
        let tmp = repo_with("#!/usr/bin/env bash\necho started\nsleep 5\n");
        let (code, text) = run_captured(tmp.path(), "scripts/s.sh", Duration::from_millis(300));
        assert_eq!(
            code,
            Err(CannotEvaluate::Timeout),
            "a hung demo run is killed → cannot-evaluate(Timeout) → BLOCK"
        );
        assert!(
            text.contains("started"),
            "output-before-kill survives: {text:?}"
        );
        assert!(
            text.contains("TIMEOUT") && text.contains("scripts/s.sh"),
            "the returned text names the timeout + script: {text:?}"
        );
    }

    #[test]
    fn run_captured_spawn_failure_is_distinct_from_timeout() {
        let tmp = tempfile::tempdir().unwrap();
        let (code, text) = run_captured_with_program(
            NONEXISTENT_PROGRAM,
            tmp.path(),
            "scripts/s.sh",
            Duration::from_secs(30),
        );
        assert_eq!(code, Err(CannotEvaluate::SpawnFailure));
        assert_ne!(code, Err(CannotEvaluate::Timeout));
        assert!(
            text.is_empty(),
            "nothing was ever captured — the child never started: {text:?}"
        );
    }

    #[test]
    fn run_captured_does_not_inherit_stdin() {
        // A gate re-run must not consume the operator's stdin: a script that `read`s must see EOF
        // (null), not block or eat input. The S73 confirm-drain regression was exactly this —
        // inherited stdin let a re-run swallow the `--advance` 'y'.
        let tmp = repo_with(
            "#!/usr/bin/env bash\nif read -r l; then echo \"got:$l\"; else echo noinput; fi\n",
        );
        let (code, text) = run_captured(tmp.path(), "scripts/s.sh", Duration::from_secs(30));
        assert_eq!(code, Ok(0));
        assert!(
            text.contains("noinput"),
            "stdin must be null (EOF): {text:?}"
        );
    }

    #[test]
    fn run_streamed_red_returns_nonzero_code() {
        // A missing/failing script: bash itself spawns fine, then exits non-zero (→ LiveRed →
        // BLOCK). This is NOT a CannotEvaluate case — the real code must survive unchanged.
        let tmp = repo_with("#!/usr/bin/env bash\nexit 3\n");
        assert_eq!(
            run_streamed(tmp.path(), "scripts/s.sh", Duration::from_secs(30)),
            Ok(3)
        );
    }
}
