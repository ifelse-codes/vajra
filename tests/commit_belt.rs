//! The commit/push belt's human-vs-agent split, executed (S171 pass-3 cold review rec 7, S172).
//!
//! S171 changed `.githooks/pre-commit` and `.githooks/pre-push` so they stop the AGENT and let
//! the human through. The cases were checked by hand once and nothing ran them again. These tests
//! install the real hook files into a temp repo (`core.hooksPath`) and drive real `git commit` /
//! the real pre-push script, with the agent markers set and unset. S194 (F123) adds
//! `.githooks/pre-merge-commit`: a merge commit never runs pre-commit, so `git merge` on main
//! slipped past the belt in rudra S20. The S202 bug bash adds `.githooks/reference-transaction`:
//! a fast-forward, `reset --hard`, `branch -f` and `update-ref` make no commit at all.

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
    for name in [
        "pre-commit",
        "pre-push",
        "pre-merge-commit",
        "reference-transaction",
    ] {
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

/// Founder decision, 2026-09-21 (DECISION-007): a branch NOT named `session-NN-…` is ungoverned
/// ad-hoc work, by design. The per-session approval does not apply there; the 3-file cap and the
/// ban on `main` still do. This test locks the decision — change it only on purpose.
#[test]
fn an_agent_on_a_non_session_branch_commits_without_approval_by_design() {
    let d = repo();
    for branch in ["quick-fix", "session-7"] {
        assert!(git(d.path(), &["checkout", "-qb", branch]).status.success());
        let (ok, out) = commit(d.path(), 1, &[CLAUDE]);
        assert!(
            ok,
            "agent on '{branch}', no approval — ungoverned by design: {out}"
        );
        let (ok, out) = commit(d.path(), 4, &[CLAUDE]);
        assert!(
            !ok && out.contains("an agent commits at most 3"),
            "the 3-file cap still binds on '{branch}': {out}"
        );
        assert!(git(d.path(), &["checkout", "-q", "main"]).status.success());
    }
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
    // S196 (F127): an agent's session branch now needs a GREEN close for the commit it pushes —
    // the `1111…` sha here has none, so it is stopped (tests/push_belt.rs has the real pushes).
    let (ok, out) = push("refs/heads/session-07-x", &[CLAUDE]);
    assert!(
        !ok && out.contains("A pull request opens only after the close is GREEN"),
        "agent pushing its branch: {out}"
    );
    let (ok, out) = push("refs/heads/quick-fix", &[CLAUDE]);
    assert!(
        ok && out.is_empty(),
        "a non-session branch is not checked (2026-09-21): {out}"
    );
}

// ── S194 (F123): a merge commit on main ─────────────────────────────────────

/// `git merge --no-ff <branch>` with exactly `env` set. Returns (ok, output).
fn merge(root: &Path, branch: &str, env: &[(&str, &str)]) -> (bool, String) {
    let mut cmd = Command::new("git");
    cmd.args(["merge", "--no-ff", "-m", "merge", branch])
        .current_dir(root)
        .env("GIT_CONFIG_GLOBAL", "/dev/null");
    for v in BELT_VARS {
        cmd.env_remove(v);
    }
    for (k, v) in env {
        cmd.env(k, v);
    }
    let out = cmd.output().expect("git merge runs");
    let text = format!(
        "{}{}",
        String::from_utf8_lossy(&out.stdout),
        String::from_utf8_lossy(&out.stderr)
    );
    if !out.status.success() {
        git(root, &["merge", "--abort"]);
    }
    (out.status.success(), text)
}

fn head(root: &Path) -> String {
    String::from_utf8_lossy(&git(root, &["rev-parse", "HEAD"]).stdout)
        .trim()
        .to_string()
}

/// A session branch with one human commit of `files` files, then back on `back_to`.
fn branch_with_work(root: &Path, branch: &str, files: usize, back_to: &str) {
    assert!(git(root, &["checkout", "-qb", branch]).status.success());
    let (ok, out) = commit(root, files, &[]);
    assert!(ok, "human commit on {branch}: {out}");
    assert!(git(root, &["checkout", "-q", back_to]).status.success());
}

#[test]
fn s194_a_merge_commit_on_main_is_stopped_for_the_agent_and_the_human() {
    let d = repo();
    branch_with_work(d.path(), "session-01-x", 1, "main");
    let before = head(d.path());
    let (ok, out) = merge(
        d.path(),
        "session-01-x",
        &[CLAUDE, ("VAJRA_ALLOW_COMMIT", "01")],
    );
    assert!(
        !ok && out.contains("Vajra stopped this merge: you are on 'main'"),
        "agent merge on main: {out}"
    );
    assert_eq!(head(d.path()), before, "main moved");
    let (ok, out) = merge(d.path(), "session-01-x", &[]);
    assert!(
        !ok && out.contains("Vajra stopped this merge: you are on 'main'"),
        "human merge on main: {out}"
    );
    assert_eq!(head(d.path()), before, "main moved");
}

#[test]
fn s194_merging_into_a_session_branch_is_not_policed() {
    // The new hook checks the branch only: no 3-file cap, no approval marker on a merge.
    let d = repo();
    branch_with_work(d.path(), "session-02-y", 5, "main");
    assert!(git(d.path(), &["checkout", "-qb", "session-03-z"])
        .status
        .success());
    let (ok, out) = merge(d.path(), "session-02-y", &[CLAUDE]);
    assert!(
        ok,
        "agent merging a 5-file branch into its session branch: {out}"
    );
}

/// `git <args>` with exactly `env` set (on top of a clean belt environment).
fn git_as(root: &Path, args: &[&str], env: &[(&str, &str)]) -> (bool, String) {
    let mut cmd = Command::new("git");
    cmd.args(args)
        .current_dir(root)
        .env("GIT_CONFIG_GLOBAL", "/dev/null");
    for v in BELT_VARS {
        cmd.env_remove(v);
    }
    for (k, v) in env {
        cmd.env(k, v);
    }
    let out = cmd.output().expect("git runs");
    let text = format!(
        "{}{}",
        String::from_utf8_lossy(&out.stdout),
        String::from_utf8_lossy(&out.stderr)
    );
    (out.status.success(), text)
}

fn rev(root: &Path, what: &str) -> String {
    String::from_utf8_lossy(&git(root, &["rev-parse", what]).stdout)
        .trim()
        .to_string()
}

/// `repo()` plus a bare `origin` (outside the work tree, so `git add -A` never sweeps it in)
/// holding main as it is now, fetched so `origin/main` exists. Returns (repo, remote's dir).
fn repo_with_origin() -> (tempfile::TempDir, tempfile::TempDir) {
    let d = repo();
    let r = tempfile::tempdir().unwrap();
    let remote = r.path().join("origin.git");
    assert!(git(
        d.path(),
        &["init", "-q", "--bare", remote.to_str().unwrap()]
    )
    .status
    .success());
    git(
        d.path(),
        &["remote", "add", "origin", remote.to_str().unwrap()],
    );
    assert!(git_as(d.path(), &["push", "-q", "origin", "main"], &[]).0);
    assert!(git(d.path(), &["fetch", "-q", "origin"]).status.success());
    (d, r)
}

#[test]
fn s202_the_agent_cannot_move_main_onto_work_origin_does_not_have() {
    let (d, _remote) = repo_with_origin();
    let root = d.path();
    branch_with_work(root, "session-01-x", 1, "main");
    let main_before = rev(root, "main");
    let work = rev(root, "session-01-x");
    for args in [
        &["merge", "--ff-only", "session-01-x"][..],
        &["reset", "-q", "--hard", "session-01-x"],
        &["update-ref", "refs/heads/main", "session-01-x"],
    ] {
        let (ok, out) = git_as(root, args, &[CLAUDE]);
        assert!(!ok, "agent `git {}` moved main: {out}", args.join(" "));
        assert!(out.contains("origin/main does not have"), "{out}");
        assert_eq!(rev(root, "main"), main_before, "git {}", args.join(" "));
    }
    // `branch -f` needs another branch checked out.
    git(root, &["checkout", "-q", "session-01-x"]);
    let (ok, out) = git_as(root, &["branch", "-f", "main", &work], &[CLAUDE]);
    assert!(!ok, "agent `git branch -f main` moved main: {out}");
    assert_eq!(rev(root, "main"), main_before);
}

#[test]
fn s202_a_pull_after_a_merged_pr_still_moves_main_and_a_person_gets_a_note() {
    let (d, _remote) = repo_with_origin();
    let root = d.path();
    branch_with_work(root, "session-01-x", 1, "main");
    // The pull request is merged on the remote: origin's main is now the session's work.
    let (ok, out) = git_as(root, &["push", "-q", "origin", "session-01-x:main"], &[]);
    assert!(ok, "{out}");
    let (ok, out) = git_as(
        root,
        &["pull", "-q", "--ff-only", "origin", "main"],
        &[CLAUDE],
    );
    assert!(ok, "agent pull after a merged PR: {out}");
    assert_eq!(rev(root, "main"), rev(root, "session-01-x"));
    // Going back to an older commit origin has is not policed either.
    let (ok, out) = git_as(root, &["reset", "-q", "--hard", "HEAD~1"], &[CLAUDE]);
    assert!(ok, "agent reset to an older commit: {out}");

    // A person moving main onto local work is told, and the move goes on (the S171 split).
    branch_with_work(root, "session-02-y", 1, "main");
    let (ok, out) = git_as(root, &["merge", "-q", "--ff-only", "session-02-y"], &[]);
    assert!(
        ok && out.contains("Note: moving 'main'"),
        "person ff: {out}"
    );
    assert_eq!(rev(root, "main"), rev(root, "session-02-y"));
}

#[test]
fn s202_a_repo_with_no_origin_is_not_checked_by_design() {
    // Named limit: nothing to follow, so nothing is checked (a brand-new local project).
    let d = repo();
    branch_with_work(d.path(), "session-01-x", 1, "main");
    let (ok, out) = git_as(
        d.path(),
        &["merge", "-q", "--ff-only", "session-01-x"],
        &[CLAUDE],
    );
    assert!(ok, "{out}");
}
