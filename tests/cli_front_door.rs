//! S128 — the front door, asserted against the REAL binary.
//!
//! Every other test in this repo calls the library. These do not: `CARGO_BIN_EXE_vajra`
//! is the compiled `vajra` a stranger would run, and the shell semantics that matter
//! (`vajra <typo> && deploy`) live in the process exit code, not in a Rust return value.

use std::process::Command;

fn vajra() -> Command {
    Command::new(env!("CARGO_BIN_EXE_vajra"))
}

/// Criterion 2 — an unknown subcommand exits NON-ZERO and names the unrecognised word.
#[test]
fn unknown_subcommand_exits_nonzero_and_names_the_word() {
    let out = vajra().arg("chek").output().unwrap();
    assert!(
        !out.status.success(),
        "`vajra chek` exited 0 — the front door fails OPEN, so `vajra chek && deploy` runs deploy"
    );
    assert_eq!(out.status.code(), Some(2), "usage error should exit 2");
    let err = String::from_utf8_lossy(&out.stderr);
    assert!(
        err.contains("chek"),
        "the message must name the unrecognised word; got: {err}"
    );
}

/// Criterion 2, the shell semantics themselves. `vajra <typo> && echo RAN` must not print RAN.
/// Asserted through a real `sh -c`, because that is the failure a stranger actually hits.
#[test]
fn typo_short_circuits_a_shell_and_chain() {
    let bin = env!("CARGO_BIN_EXE_vajra");
    let out = Command::new("sh")
        .arg("-c")
        .arg(format!("'{bin}' chek && echo RAN"))
        .output()
        .unwrap();
    let stdout = String::from_utf8_lossy(&out.stdout);
    let stderr = String::from_utf8_lossy(&out.stderr);
    // POSITIVE ANCHOR FIRST. Without it this test passes when `sh` never ran the binary at all:
    // stdout would be empty, "RAN" absent, green — the S127 silent-no-op shape, in Rust.
    assert!(
        stderr.contains("chek"),
        "the binary never ran, or never named the word — stderr was {stderr:?}. \
         A test that cannot tell 'short-circuited' from 'never executed' proves nothing."
    );
    assert!(
        !stdout.contains("RAN"),
        "`vajra chek && echo RAN` printed RAN — the && chain was not short-circuited"
    );
}

/// An unknown FLAG is unknown too — `-x` must not be silently swallowed into help.
#[test]
fn unknown_flag_also_fails_closed() {
    let out = vajra().arg("--frobnicate").output().unwrap();
    assert!(!out.status.success(), "`vajra --frobnicate` exited 0");
    let err = String::from_utf8_lossy(&out.stderr);
    assert!(err.contains("--frobnicate"), "message must name the flag");
}

/// Criterion 3 — asking for help is not an error. Criterion 2 must not break this.
#[test]
fn help_and_bare_invocation_still_exit_zero() {
    for args in [vec![], vec!["help"], vec!["--help"], vec!["-h"]] {
        let out = vajra().args(&args).output().unwrap();
        assert!(
            out.status.success(),
            "`vajra {}` should exit 0, got {:?}",
            args.join(" "),
            out.status.code()
        );
    }
}

/// Criterion 1 — `vajra --version` / `-V` prints the crate version and exits 0.
///
/// The expected value is parsed out of `Cargo.toml` at test time, NOT taken from
/// `env!("CARGO_PKG_VERSION")`. Comparing the binary against the same compile-time
/// constant it prints would pass even if someone typed the number by hand; parsing the
/// manifest is what makes "read from the crate, never typed" falsifiable.
#[test]
fn version_flag_prints_the_manifest_version() {
    let manifest = std::fs::read_to_string(
        std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("Cargo.toml"),
    )
    .unwrap();
    let expected = manifest
        .lines()
        .skip_while(|l| l.trim() != "[package]")
        .find_map(|l| l.strip_prefix("version = "))
        .map(|v| v.trim().trim_matches('"').to_string())
        .expect("no [package] version in Cargo.toml");

    for flag in ["--version", "-V"] {
        let out = vajra().arg(flag).output().unwrap();
        assert!(out.status.success(), "`vajra {flag}` exited non-zero");
        let stdout = String::from_utf8_lossy(&out.stdout);
        assert!(
            stdout.contains(&expected),
            "`vajra {flag}` printed {stdout:?}, expected it to contain the manifest version {expected:?}"
        );
        assert!(
            !stdout.contains("Scaffold .ai/ workflow"),
            "`vajra {flag}` printed the help banner instead of a version"
        );
    }
}

/// A fresh, empty git repo with one commit — the directory a stranger types their first command in.
fn empty_git_repo(tag: &str) -> std::path::PathBuf {
    let nanos = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_nanos();
    let dir = std::env::temp_dir().join(format!("vajra-s179-{tag}-{}-{nanos}", std::process::id()));
    std::fs::create_dir_all(&dir).unwrap();
    for args in [
        vec!["init", "-q"],
        vec![
            "-c",
            "user.name=t",
            "-c",
            "user.email=t@t",
            "commit",
            "-q",
            "--allow-empty",
            "-m",
            "x",
        ],
    ] {
        let st = Command::new("git")
            .args(&args)
            .current_dir(&dir)
            .status()
            .unwrap();
        assert!(st.success(), "git {args:?} failed in {}", dir.display());
    }
    dir
}

/// `git status --porcelain` — empty means the command wrote nothing into the repo.
fn repo_changes(dir: &std::path::Path) -> String {
    let out = Command::new("git")
        .args(["status", "--porcelain"])
        .current_dir(dir)
        .output()
        .unwrap();
    String::from_utf8_lossy(&out.stdout).into_owned()
}

/// S179 (F89) — `vajra <command> --help` prints THAT command's help and writes nothing.
/// Before S179 no subcommand read the flag: `init --help` scaffolded 11 files into an empty repo,
/// `check`/`next`/`estimate` ran, `meter` opened a file named `--help`, `hook` printed `{}`.
/// `claude` is not in the list on purpose — its arguments belong to Claude Code.
#[test]
fn every_subcommand_help_prints_usage_and_writes_nothing() {
    for cmd in ["init", "check", "next", "estimate", "hook", "meter"] {
        for flag in ["--help", "-h"] {
            let dir = empty_git_repo(cmd);
            let out = vajra()
                .args([cmd, flag])
                .current_dir(&dir)
                .stdin(std::process::Stdio::null())
                .output()
                .unwrap();
            let err = String::from_utf8_lossy(&out.stderr);
            let changes = repo_changes(&dir);
            let _ = std::fs::remove_dir_all(&dir);
            assert_eq!(
                out.status.code(),
                Some(0),
                "`vajra {cmd} {flag}` should exit 0; stderr: {err}"
            );
            assert!(
                err.contains(&format!("vajra {cmd} —")) && err.contains("usage:"),
                "`vajra {cmd} {flag}` did not print its own help; stderr: {err}"
            );
            assert!(
                changes.is_empty(),
                "`vajra {cmd} {flag}` wrote into the repo:\n{changes}"
            );
        }
    }
}

/// F89's positive anchor: the help check must not swallow the real command. A bare `vajra init`
/// (no flag) still scaffolds — without this, "writes nothing" would pass on a binary that never
/// runs init at all.
#[test]
fn init_without_help_still_scaffolds() {
    let dir = empty_git_repo("init-real");
    let out = vajra()
        .arg("init")
        .current_dir(&dir)
        .stdin(std::process::Stdio::null())
        .output()
        .unwrap();
    let wrote_ai = dir.join(".ai/SESSION").is_file();
    let _ = std::fs::remove_dir_all(&dir);
    assert!(
        out.status.success(),
        "`vajra init` failed: {}",
        String::from_utf8_lossy(&out.stderr)
    );
    assert!(wrote_ai, "`vajra init` did not write .ai/SESSION");
}

/// S179 (F90) — `vajra init` refuses a word it does not know, and writes nothing. Before S179 an
/// unknown word was ignored: `vajra init --dry-run` (the preview flag, which needs `--sync-fleet`)
/// ran a full scaffold into the repo it was meant to preview.
#[test]
fn init_refuses_unknown_words_and_writes_nothing() {
    for (word, must_name) in [
        ("--dry-run", "--sync-fleet --dry-run"),
        ("--overwrite-drifted", "--sync-fleet --overwrite-drifted"),
        ("--bogus", "--bogus"),
        ("myproject", "myproject"),
    ] {
        let dir = empty_git_repo("init-unknown");
        let out = vajra()
            .args(["init", word])
            .current_dir(&dir)
            .stdin(std::process::Stdio::null())
            .output()
            .unwrap();
        let err = String::from_utf8_lossy(&out.stderr);
        let changes = repo_changes(&dir);
        let _ = std::fs::remove_dir_all(&dir);
        assert!(
            !out.status.success(),
            "`vajra init {word}` exited 0; stderr: {err}"
        );
        assert!(
            err.contains(must_name) && err.contains("nothing was written"),
            "`vajra init {word}` must name `{must_name}` and say nothing was written; stderr: {err}"
        );
        assert!(
            changes.is_empty(),
            "`vajra init {word}` wrote into the repo:\n{changes}"
        );
    }
}

/// F90's positive anchor: the words `init` does know still work. `--sync-fleet --dry-run` in a
/// set-up repo exits 0 and still writes nothing (it is a preview).
#[test]
fn init_sync_fleet_dry_run_still_works() {
    let dir = empty_git_repo("sync-dry");
    let setup = vajra()
        .arg("init")
        .current_dir(&dir)
        .stdin(std::process::Stdio::null())
        .output()
        .unwrap();
    assert!(setup.status.success(), "setup `vajra init` failed");
    let before = repo_changes(&dir);
    let out = vajra()
        .args(["init", "--sync-fleet", "--dry-run"])
        .current_dir(&dir)
        .stdin(std::process::Stdio::null())
        .output()
        .unwrap();
    let after = repo_changes(&dir);
    let _ = std::fs::remove_dir_all(&dir);
    assert!(
        out.status.success(),
        "`vajra init --sync-fleet --dry-run` failed: {}",
        String::from_utf8_lossy(&out.stderr)
    );
    assert_eq!(before, after, "`--sync-fleet --dry-run` changed the repo");
}
