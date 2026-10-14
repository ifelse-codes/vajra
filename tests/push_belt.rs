//! S196 (F127, founder 2026-10-14: "no pr creation till it is not green"): a session branch reaches
//! the remote only when its close check said GREEN for the exact commit pushed.
//!
//! rudra S20's close was RED and its branch was still pushed, a PR opened and merged — nothing read
//! the result before the exit box, after the merge. A PR needs a pushed branch, so the belt is
//! `.githooks/pre-push`. Every case here is a real `git push` from a freshly scaffolded project to a
//! real bare remote, and asks the remote whether the branch arrived.

use std::fs;
use std::path::Path;
use std::process::{Command, Output};

/// Every variable the hooks read to decide "agent shell" or "approved". The test runs inside
/// Claude Code, so each case starts with all of them removed and adds only its own.
const BELT_VARS: &[&str] = &[
    "CLAUDECODE",
    "CLAUDE_CODE_ENTRYPOINT",
    "CURSOR_TRACE_ID",
    "VAJRA_AGENT",
    "VAJRA_ALLOW_COMMIT",
    "CLAUDE_PROJECT_DIR",
];
const AGENT: (&str, &str) = ("CLAUDECODE", "1");
const BRANCH: &str = "session-01-x";

fn git_env(dir: &Path, args: &[&str], env: &[(&str, &str)]) -> Output {
    let mut cmd = Command::new("git");
    cmd.args(args)
        .current_dir(dir)
        .env("GIT_CONFIG_GLOBAL", "/dev/null");
    for v in BELT_VARS {
        cmd.env_remove(v);
    }
    for (k, v) in env {
        cmd.env(k, v);
    }
    cmd.output().expect("git runs")
}

fn git(dir: &Path, args: &[&str]) -> Output {
    git_env(dir, args, &[])
}

fn text(o: &Output) -> String {
    format!(
        "{}{}",
        String::from_utf8_lossy(&o.stdout),
        String::from_utf8_lossy(&o.stderr)
    )
}

/// A `vajra init` project (the real scaffold, its `.githooks/` wired the way init wires them), on
/// `session-01-x`, with a bare `origin`. Returns (tempdir, project root, remote).
fn project() -> (tempfile::TempDir, std::path::PathBuf, std::path::PathBuf) {
    let t = tempfile::tempdir().unwrap();
    let root = t.path().join("p");
    let remote = t.path().join("origin.git");
    fs::create_dir(&root).unwrap();
    for args in [
        &["init", "-q", "-b", "main"][..],
        &["config", "user.email", "t@t"],
        &["config", "user.name", "t"],
    ] {
        assert!(git(&root, args).status.success());
    }
    vajractl::cli::init::scaffold(&root, "P", "build the thing", "L2").unwrap();
    fs::write(root.join(".ai/SESSION"), "1\n").unwrap();
    // The scaffold already pointed core.hooksPath at .githooks, so main refuses commits: the first
    // one lands on the session branch, as a session's work does.
    assert!(git(&root, &["checkout", "-qb", BRANCH]).status.success());
    git(&root, &["add", "-A"]);
    let c = git(&root, &["commit", "-qm", "init"]);
    assert!(c.status.success(), "{}", text(&c));
    assert!(git(t.path(), &["init", "-q", "--bare", "origin.git"])
        .status
        .success());
    assert!(git(
        &root,
        &["remote", "add", "origin", remote.to_str().unwrap()]
    )
    .status
    .success());
    (t, root, remote)
}

fn head(root: &Path) -> String {
    String::from_utf8_lossy(&git(root, &["rev-parse", "HEAD"]).stdout)
        .trim()
        .to_string()
}

/// One close result, format 2, exactly as the close scripts write it.
fn result(
    root: &Path,
    stamp: &str,
    session: u32,
    head: &str,
    clean: &str,
    verdict: &str,
    warn: u32,
) {
    let (fail, failed) = if verdict == "RED" {
        (2, "fidelity-review-accept required-crew")
    } else {
        (0, "")
    };
    let dir = root.join(".ai/verify/closeout").join(stamp);
    fs::create_dir_all(&dir).unwrap();
    fs::write(
        dir.join("result"),
        format!(
            "vajra-closeout-result: 2\nsession: {session}\nhead: {head}\nclean: {clean}\n\
             verdict: {verdict}\npass: 20\nfail: {fail}\nwarn: {warn}\nfailed: {failed}\n"
        ),
    )
    .unwrap();
}

fn push(root: &Path, spec: &str, env: &[(&str, &str)]) -> (bool, String) {
    let o = git_env(root, &["push", "-q", "origin", spec], env);
    (o.status.success(), text(&o))
}

fn arrived(remote: &Path, branch: &str) -> bool {
    git(
        remote,
        &[
            "rev-parse",
            "-q",
            "--verify",
            &format!("refs/heads/{branch}"),
        ],
    )
    .status
    .success()
}

fn commit_one(root: &Path, name: &str) {
    fs::write(root.join(name), name).unwrap();
    git(root, &["add", name]);
    assert!(git(root, &["commit", "-qm", name]).status.success());
}

#[test]
fn a_red_close_keeps_the_agents_session_branch_off_the_remote() {
    let (_t, root, remote) = project();
    result(&root, "20261014T100000Z", 1, &head(&root), "yes", "RED", 0);
    let (ok, out) = push(&root, BRANCH, &[AGENT]);
    assert!(!ok, "{out}");
    assert!(
        !arrived(&remote, BRANCH),
        "the branch reached the remote: {out}"
    );
    assert!(
        out.contains("RED — 2 failed (fidelity-review-accept required-crew)")
            && out.contains("until it says GREEN")
            && out.contains("tell the founder"),
        "{out}"
    );
    assert!(
        !out.contains("--no-verify"),
        "the agent is not shown a way around: {out}"
    );
}

#[test]
fn a_green_close_on_this_commit_lets_it_through_warn_or_not() {
    let (_t, root, remote) = project();
    result(&root, "20261014T100000Z", 1, &head(&root), "yes", "RED", 0);
    result(
        &root,
        "20261014T110000Z",
        1,
        &head(&root),
        "yes",
        "GREEN",
        2,
    );
    let (ok, out) = push(&root, BRANCH, &[AGENT]);
    assert!(ok && arrived(&remote, BRANCH), "{out}");
    assert!(out.contains("GREEN with 2 WARN"), "{out}");
}

#[test]
fn a_green_from_before_the_last_commit_does_not_count() {
    let (_t, root, remote) = project();
    result(
        &root,
        "20261014T100000Z",
        1,
        &head(&root),
        "yes",
        "GREEN",
        0,
    );
    commit_one(&root, "later.txt");
    let (ok, out) = push(&root, BRANCH, &[AGENT]);
    assert!(!ok && !arrived(&remote, BRANCH), "{out}");
    assert!(
        out.contains("a commit landed after it") && out.contains("again"),
        "{out}"
    );
}

#[test]
fn a_later_red_on_the_same_commit_wins_over_an_earlier_green() {
    let (_t, root, remote) = project();
    result(
        &root,
        "20261014T100000Z",
        1,
        &head(&root),
        "yes",
        "GREEN",
        0,
    );
    result(&root, "20261014T110000Z", 1, &head(&root), "yes", "RED", 0);
    let (ok, out) = push(&root, BRANCH, &[AGENT]);
    assert!(!ok && !arrived(&remote, BRANCH), "{out}");
}

#[test]
fn a_green_with_uncommitted_files_or_another_sessions_number_is_refused() {
    let (_t, root, remote) = project();
    result(&root, "20261014T100000Z", 1, &head(&root), "no", "GREEN", 0);
    let (ok, out) = push(&root, BRANCH, &[AGENT]);
    assert!(!ok && !arrived(&remote, BRANCH), "{out}");
    assert!(out.contains("uncommitted changes"), "{out}");

    result(
        &root,
        "20261014T110000Z",
        2,
        &head(&root),
        "yes",
        "GREEN",
        0,
    );
    let (ok, out) = push(&root, BRANCH, &[AGENT]);
    assert!(!ok && !arrived(&remote, BRANCH), "{out}");
    assert!(
        out.contains("checked session 2; this branch is session 1's"),
        "{out}"
    );
}

#[test]
fn no_result_or_an_old_format_result_is_refused_and_says_how_through() {
    let (_t, root, remote) = project();
    let (ok, out) = push(&root, BRANCH, &[AGENT]);
    assert!(!ok && !arrived(&remote, BRANCH), "{out}");
    assert!(out.contains("no close check has run"), "{out}");

    let dir = root.join(".ai/verify/closeout/20261014T100000Z");
    fs::create_dir_all(&dir).unwrap();
    fs::write(
        dir.join("result"),
        "vajra-closeout-result: 1\nsession: 1\nverdict: GREEN\npass: 20\nfail: 0\nwarn: 0\nfailed: \n",
    )
    .unwrap();
    let (ok, out) = push(&root, BRANCH, &[AGENT]);
    assert!(!ok && !arrived(&remote, BRANCH), "{out}");
    assert!(out.contains("vajra init --sync-fleet"), "{out}");
}

#[test]
fn the_founder_pushing_a_red_branch_gets_a_note_and_the_push_goes_on() {
    // Founder's call, 2026-10-14: the agent is stopped; his own push is warned, not stopped.
    let (_t, root, remote) = project();
    result(&root, "20261014T100000Z", 1, &head(&root), "yes", "RED", 0);
    let (ok, out) = push(&root, BRANCH, &[]);
    assert!(ok && arrived(&remote, BRANCH), "{out}");
    assert!(
        out.contains("Note:") && out.contains("RED") && out.contains("Pushing anyway"),
        "{out}"
    );
}

#[test]
fn a_branch_not_named_for_a_session_and_a_delete_are_not_checked() {
    // Founder, 2026-09-21: a branch not named session-NN-… is ungoverned on purpose.
    let (_t, root, remote) = project();
    assert!(git(&root, &["checkout", "-qb", "quick-fix"])
        .status
        .success());
    let (ok, out) = push(&root, "quick-fix", &[AGENT]);
    assert!(ok && arrived(&remote, "quick-fix"), "{out}");
    assert!(out.is_empty(), "{out}");

    // A session branch already on the remote (put there by the founder) can be deleted.
    git(&root, &["checkout", "-q", BRANCH]);
    assert!(push(&root, BRANCH, &[]).0 && arrived(&remote, BRANCH));
    let (ok, out) = push(&root, &format!(":{BRANCH}"), &[AGENT]);
    assert!(ok && !arrived(&remote, BRANCH), "{out}");
}

#[test]
fn the_scaffolds_own_close_check_writes_what_the_push_belt_reads() {
    // The writer and the reader agree: the project's REAL close script runs on this fresh project
    // (RED — nothing of a session exists), and its own result stops the agent's push.
    let (_t, root, remote) = project();
    let bin = Path::new(env!("CARGO_BIN_EXE_vajra")).parent().unwrap();
    let path = format!(
        "{}:{}",
        bin.display(),
        std::env::var("PATH").unwrap_or_default()
    );
    let mut cmd = Command::new("bash");
    cmd.args(["scripts/verify-closeout.sh", "1"])
        .current_dir(&root)
        .env("PATH", path)
        .env("GIT_CONFIG_GLOBAL", "/dev/null");
    for v in BELT_VARS {
        cmd.env_remove(v);
    }
    let run = cmd.output().unwrap();
    assert!(
        !run.status.success(),
        "a fresh project cannot close GREEN: {}",
        text(&run)
    );
    let closeout = root.join(".ai/verify/closeout");
    let stamp = fs::read_dir(&closeout)
        .unwrap()
        .filter_map(|e| e.ok())
        .map(|e| e.file_name().to_string_lossy().into_owned())
        .filter(|n| n.ends_with('Z'))
        .max()
        .expect("the close made its folder");
    let written = fs::read_to_string(closeout.join(&stamp).join("result")).unwrap();
    let lines: Vec<&str> = written.lines().collect();
    assert_eq!(lines[0], "vajra-closeout-result: 2", "{written}");
    assert_eq!(lines[1], "session: 1", "{written}");
    assert_eq!(lines[2], format!("head: {}", head(&root)), "{written}");
    assert_eq!(lines[3], "clean: yes", "{written}");
    assert_eq!(lines[4], "verdict: RED", "{written}");

    let (ok, out) = push(&root, BRANCH, &[AGENT]);
    assert!(!ok && !arrived(&remote, BRANCH), "{out}");
    assert!(out.contains("the close check is RED"), "{out}");
}
