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
