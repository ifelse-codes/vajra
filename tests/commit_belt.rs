//! The commit/push belt's human-vs-agent split, executed (S171 pass-3 cold review rec 7, S172).
//!
//! S171 changed `.githooks/pre-commit` and `.githooks/pre-push` so they stop the AGENT and let
//! the human through. The cases were checked by hand once and nothing ran them again. These tests
//! install the real hook files into a temp repo (`core.hooksPath`) and drive real `git commit` /
//! the real pre-push script, with the agent markers set and unset.

use std::fs;
use std::path::Path;
use std::process::{Command, Output};

/// Every variable either hook reads to decide "agent shell" or "approved". The test process runs
/// inside Claude Code, so each case starts with ALL of them removed and adds only its own.
const BELT_VARS: &[&str] = &[
    "CLAUDECODE",
    "CLAUDE_CODE_ENTRYPOINT",
    "CURSOR_TRACE_ID",
    "VAJRA_AGENT",
    "VAJRA_ALLOW_COMMIT",
];

fn hook(name: &str) -> std::path::PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .join(".githooks")
        .join(name)
}

fn git(dir: &Path, args: &[&str]) -> Output {
    let mut cmd = Command::new("git");
    // A global hooksPath or commit signing on the machine running the test must not leak in.
    cmd.args(args)
        .current_dir(dir)
        .env("GIT_CONFIG_GLOBAL", "/dev/null");
    for v in BELT_VARS {
        cmd.env_remove(v);
    }
    cmd.output().expect("git runs")
}

/// A temp repo on `main` with the real hooks committed, then wired in through `core.hooksPath`.
fn repo() -> tempfile::TempDir {
    let tmp = tempfile::tempdir().unwrap();
    let root = tmp.path();
    for args in [
        &["init", "-q", "-b", "main"][..],
        &["config", "user.email", "t@t"],
        &["config", "user.name", "t"],
    ] {
        assert!(git(root, args).status.success());
    }
    let hooks = root.join(".githooks");
    fs::create_dir_all(&hooks).unwrap();
    for name in ["pre-commit", "pre-push"] {
        fs::copy(hook(name), hooks.join(name)).unwrap();
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            fs::set_permissions(hooks.join(name), fs::Permissions::from_mode(0o755)).unwrap();
        }
    }
    // Committed before they are switched on, so a failed case's `git clean` cannot remove them.
    fs::write(root.join("README"), "x\n").unwrap();
    git(root, &["add", "-A"]);
    assert!(git(root, &["commit", "-qm", "init"]).status.success());
    assert!(git(root, &["config", "core.hooksPath", ".githooks"])
        .status
        .success());
    tmp
}

/// Stage `files` new files and run `git commit` with exactly `env` set. Returns (ok, output).
fn commit(root: &Path, files: usize, env: &[(&str, &str)]) -> (bool, String) {
    let tag = format!("{:?}", std::time::Instant::now());
    for i in 0..files {
        fs::write(root.join(format!("f{i}-{}.txt", tag.len())), &tag).unwrap();
    }
    git(root, &["add", "-A"]);
    let mut cmd = Command::new("git");
    cmd.args(["commit", "-qm", "work"])
        .current_dir(root)
        .env("GIT_CONFIG_GLOBAL", "/dev/null");
    for v in BELT_VARS {
        cmd.env_remove(v);
    }
    for (k, v) in env {
        cmd.env(k, v);
    }
    let out = cmd.output().expect("git commit runs");
    let text = format!(
        "{}{}",
        String::from_utf8_lossy(&out.stdout),
        String::from_utf8_lossy(&out.stderr)
    );
    if !out.status.success() {
        // Leave the tree clean for the next case.
        git(root, &["reset", "-q", "--hard"]);
        git(root, &["clean", "-qfd"]);
    }
    (out.status.success(), text)
}

fn on_session_branch(root: &Path) {
    assert!(git(root, &["checkout", "-qb", "session-07-x"])
        .status
        .success());
}

const CLAUDE: (&str, &str) = ("CLAUDECODE", "1");

#[test]
fn main_is_closed_to_the_human_and_the_agent_alike() {
    let d = repo();
    let (ok, out) = commit(d.path(), 1, &[]);
    assert!(
        !ok && out.contains("you are on 'main'"),
        "human on main: {out}"
    );
    let (ok, out) = commit(d.path(), 1, &[CLAUDE, ("VAJRA_ALLOW_COMMIT", "07")]);
    assert!(
        !ok && out.contains("you are on 'main'"),
        "agent on main: {out}"
    );
}

#[test]
fn a_human_commits_on_a_session_branch_without_any_marker() {
    let d = repo();
    on_session_branch(d.path());
    let (ok, out) = commit(d.path(), 1, &[]);
    assert!(ok, "human, no marker: {out}");
}

#[test]
fn every_agent_marker_is_stopped_without_approval() {
    let d = repo();
    on_session_branch(d.path());
    for var in [
        "CLAUDECODE",
        "CLAUDE_CODE_ENTRYPOINT",
        "CURSOR_TRACE_ID",
        "VAJRA_AGENT",
    ] {
        let (ok, out) = commit(d.path(), 1, &[(var, "1")]);
        assert!(
            !ok && out.contains("no approval to commit for session 07"),
            "{var} set, no approval: {out}"
        );
    }
}

#[test]
fn the_agent_commits_only_with_this_sessions_approval() {
    let d = repo();
    on_session_branch(d.path());
    let (ok, out) = commit(d.path(), 1, &[CLAUDE, ("VAJRA_ALLOW_COMMIT", "08")]);
    assert!(!ok, "another session's approval must not count: {out}");
    let (ok, out) = commit(d.path(), 1, &[CLAUDE, ("VAJRA_ALLOW_COMMIT", "07")]);
    assert!(ok, "this session's approval: {out}");
}

#[test]
fn the_three_file_cap_binds_the_agent_not_the_human() {
    let d = repo();
    on_session_branch(d.path());
    let approved = [CLAUDE, ("VAJRA_ALLOW_COMMIT", "07")];
    let (ok, out) = commit(d.path(), 4, &approved);
    assert!(!ok && out.contains("an agent commits at most 3"), "{out}");
    let (ok, out) = commit(d.path(), 3, &approved);
    assert!(ok, "3 files is allowed: {out}");
    let (ok, out) = commit(d.path(), 4, &[]);
    assert!(ok, "a human's 4-file commit: {out}");
}

/// Feed the pre-push hook one ref line, the way git does, with exactly `env` set.
fn push(remote_ref: &str, env: &[(&str, &str)]) -> (bool, String) {
    let mut cmd = Command::new("bash");
    cmd.arg(hook("pre-push"))
        .stdin(std::process::Stdio::piped())
        .stdout(std::process::Stdio::piped())
        .stderr(std::process::Stdio::piped());
    for v in BELT_VARS {
        cmd.env_remove(v);
    }
    for (k, v) in env {
        cmd.env(k, v);
    }
    let mut child = cmd.spawn().expect("pre-push runs");
    use std::io::Write as _;
    writeln!(
        child.stdin.take().unwrap(),
        "refs/heads/x {} {remote_ref} {}",
        "1".repeat(40),
        "0".repeat(40)
    )
    .unwrap();
    let out = child.wait_with_output().unwrap();
    (
        out.status.success(),
        String::from_utf8_lossy(&out.stdout).into_owned(),
    )
}

#[test]
fn pushing_main_stops_the_agent_and_notes_the_human() {
    let (ok, out) = push("refs/heads/main", &[CLAUDE]);
    assert!(!ok && out.contains("agent may not push"), "{out}");
    let (ok, out) = push("refs/heads/master", &[("VAJRA_AGENT", "1")]);
    assert!(!ok, "master is main too: {out}");
    let (ok, out) = push("refs/heads/main", &[]);
    assert!(ok && out.contains("Pushing anyway"), "human: {out}");
    let (ok, out) = push("refs/heads/session-07-x", &[CLAUDE]);
    assert!(ok && out.is_empty(), "agent pushing its branch: {out}");
}
