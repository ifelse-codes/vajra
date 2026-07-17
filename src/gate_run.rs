//! The governed-gate LIVE runner — bounded and fail-closed (S73).
//!
//! Two stations re-run a script live at close: QA (`--check-qa`, S69, streamed) and Demo-er
//! (`--check-demo`, S71, captured for the element scan). Both spawned `bash <script>` with NO
//! time limit, so a hanging script hung the close forever (reviewer-flagged S69, re-flagged S71).
//! This module gives that shared runner a recorded, generous, wall-clock TIMEOUT: a run that
//! exceeds it is KILLED and returns the cannot-evaluate signal (`None`) — which each gate already
//! classifies as a BLOCK ("a check that cannot evaluate FAILS"; AGENTS.md). A timeout narrows the
//! gate (it can never PASS a close), never loosens it: normal green runs behave exactly as before.
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

/// `bash <script>` at `root`, spawned in its OWN process group (Unix) so a timeout can kill the
/// whole tree — a hung script's grandchildren (e.g. a `sleep` it spawned) would otherwise keep
/// the captured pipe's write end open and block the reader threads forever.
fn bash(root: &Path, script: &str) -> Command {
    let mut cmd = Command::new("bash");
    cmd.arg(script).current_dir(root);
    #[cfg(unix)]
    cmd.process_group(0);
    cmd
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

/// Re-run `script` (repo-relative) LIVE at `root` with INHERITED stdio (streamed — the run is the
/// evidence, shown as it happens), bounded by `timeout`. Returns the real exit code, or `None`
/// when it cannot be evaluated: a spawn failure OR a timeout (the child is killed and reaped, then
/// classified `None`). Used by the QA gate — replaces its old unbounded `.status()`.
pub fn run_streamed(root: &Path, script: &str, timeout: Duration) -> Option<i32> {
    let mut child = match bash(root, script).spawn() {
        Ok(c) => c,
        Err(_) => return None,
    };
    match wait_or_timeout(&mut child, timeout) {
        Some(status) => status.code(),
        None => {
            kill_tree(&mut child);
            None
        }
    }
}

/// Like [`run_streamed`] but CAPTURES stdout+stderr (for the Demo-er element scan) and echoes them
/// after the run — byte-identical to the old `.output()` behavior on normal completion — bounded by
/// `timeout`. Reader threads drain the pipes so a chatty script cannot deadlock the poll; a timeout
/// kills the child, and whatever was captured before the kill is still echoed and returned with a
/// `None` code (→ the gate's cannot-evaluate BLOCK). Used by the Demo-er gate.
pub fn run_captured(root: &Path, script: &str, timeout: Duration) -> (Option<i32>, String) {
    let mut cmd = bash(root, script);
    cmd.stdout(Stdio::piped()).stderr(Stdio::piped());
    let mut child = match cmd.spawn() {
        Ok(c) => c,
        Err(_) => return (None, String::new()),
    };
    let out_reader = read_to_end(child.stdout.take());
    let err_reader = read_to_end(child.stderr.take());
    let code = match wait_or_timeout(&mut child, timeout) {
        Some(status) => status.code(),
        None => {
            kill_tree(&mut child);
            None
        }
    };
    // Kill (above) closes the child's write ends, so both readers reach EOF and join.
    let out_bytes = out_reader.join().unwrap_or_default();
    let err_bytes = err_reader.join().unwrap_or_default();
    let _ = std::io::stdout().write_all(&out_bytes);
    let _ = std::io::stderr().write_all(&err_bytes);
    let mut text = String::from_utf8_lossy(&out_bytes).into_owned();
    text.push_str(&String::from_utf8_lossy(&err_bytes));
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

    #[test]
    fn run_streamed_green_returns_zero() {
        let tmp = repo_with("#!/usr/bin/env bash\nexit 0\n");
        assert_eq!(
            run_streamed(tmp.path(), "scripts/s.sh", Duration::from_secs(30)),
            Some(0)
        );
    }

    #[test]
    fn run_streamed_hang_is_killed_and_blocks() {
        let tmp = repo_with("#!/usr/bin/env bash\nsleep 5\n");
        // 300ms bound on a 5s sleep → kill (whole group) → None (cannot evaluate → BLOCK).
        assert_eq!(
            run_streamed(tmp.path(), "scripts/s.sh", Duration::from_millis(300)),
            None,
            "a run past its bound is killed and returns the cannot-evaluate signal"
        );
    }

    #[test]
    fn run_captured_green_captures_output() {
        let tmp = repo_with("#!/usr/bin/env bash\necho demo:header\nexit 0\n");
        let (code, text) = run_captured(tmp.path(), "scripts/s.sh", Duration::from_secs(30));
        assert_eq!(code, Some(0));
        assert!(text.contains("demo:header"), "captured output: {text:?}");
    }

    #[test]
    fn run_captured_hang_is_killed_and_blocks() {
        let tmp = repo_with("#!/usr/bin/env bash\necho started\nsleep 5\n");
        let (code, _text) = run_captured(tmp.path(), "scripts/s.sh", Duration::from_millis(300));
        assert_eq!(
            code, None,
            "a hung demo run is killed → cannot-evaluate → BLOCK"
        );
    }

    #[test]
    fn run_streamed_red_returns_nonzero_code() {
        // A missing/failing script: bash itself spawns fine, then exits non-zero (→ LiveRed →
        // BLOCK). Only bash being unspawnable yields None; the timeout branch is the other None.
        let tmp = repo_with("#!/usr/bin/env bash\nexit 3\n");
        assert_eq!(
            run_streamed(tmp.path(), "scripts/s.sh", Duration::from_secs(30)),
            Some(3)
        );
    }
}
