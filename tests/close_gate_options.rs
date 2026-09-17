//! The close gate's `three-next-options` check, executed (S171 pass-2 cold review rec 9).
//!
//! F34 asked for one thing: a session cannot close without offering the human three ranked
//! options. The check that enforces it is shell, and nothing in the repo ran it — so the awk
//! fallback and the Rust counter could drift apart in silence, and pass 1's version (which read
//! the word "READY" and inferred three) shipped green. These tests run the real function out of
//! `scripts/verify-closeout-scaffold.sh` — the copy every project gets — in both of its branches:
//! with a `vajra` on PATH, and without one.

use std::fs;
use std::path::Path;
use std::process::Command;

/// Run `check_next_options` from the scaffold gate against `summary`, with the harness the gate
/// gives it (N, artifacts dir, ok/bad, waiver, spath) stubbed. Returns (passed, log).
fn run_check(summary: &str, fake_vajra: Option<&str>) -> (bool, String) {
    let dir = tempfile::tempdir().unwrap();
    let root = dir.path();
    fs::create_dir_all(root.join("sessions")).unwrap();
    fs::write(root.join("sessions/session-02-summary.md"), summary).unwrap();

    let gate = Path::new(env!("CARGO_MANIFEST_DIR")).join("scripts/verify-closeout-scaffold.sh");
    fs::copy(&gate, root.join("gate.sh")).unwrap();

    // A `vajra` that prints what the test wants it to, ahead of any real one on PATH.
    let mut path = String::new();
    if let Some(output) = fake_vajra {
        let bin = root.join("bin");
        fs::create_dir_all(&bin).unwrap();
        fs::write(bin.join("vajra"), format!("#!/bin/sh\n{output}\n")).unwrap();
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            fs::set_permissions(bin.join("vajra"), fs::Permissions::from_mode(0o755)).unwrap();
        }
        path = format!("{}:", bin.display());
    }

    let script = r#"
      source /dev/stdin <<<"$(sed -n '/^check_next_options()/,/^}/p' gate.sh)"
      N=2; ARTIFACTS=.
      ok()  { echo "RESULT=PASS"; }
      bad() { echo "RESULT=FAIL"; }
      waiver_ok() { false; }
      spath() { printf '%s%02d%s' "$1" "$N" "$2"; }
      check_next_options
      cat three-next-options.log
    "#;
    let out = Command::new("bash")
        .arg("-c")
        .arg(script)
        .current_dir(root)
        // An empty PATH addition still needs the rest of PATH for sed/awk/cat.
        .env("PATH", format!("{path}/usr/bin:/bin:/usr/sbin:/sbin"))
        .output()
        .expect("bash runs");
    let text = format!(
        "{}{}",
        String::from_utf8_lossy(&out.stdout),
        String::from_utf8_lossy(&out.stderr)
    );
    (text.contains("RESULT=PASS"), text)
}

const THREE_NUMBERED: &str = "# S\n## 3 ranked next candidates\n1. one\n2. two\n3. three\n";
const THREE_LETTERED: &str = "# S\n## candidates\n- **A — one**\n- **B — two**\n- **C — three**\n";
const NO_SECTION: &str = "# S\n\nWe did some work and picked the next thing ourselves.\n";
const TWO_PLUS_PROSE: &str =
    "# S\n## candidates\n- **A — one**\n- **B — two**\n1.5 seconds saved\n";

/// Without a vajra on PATH the awk fallback decides — and it must agree with the Rust counter.
#[test]
fn the_fallback_counts_three_and_refuses_everything_else() {
    assert!(run_check(THREE_NUMBERED, None).0, "three numbered options");
    assert!(run_check(THREE_LETTERED, None).0, "three lettered options");

    let (passed, log) = run_check(NO_SECTION, None);
    assert!(!passed, "a summary offering nothing must BLOCK:\n{log}");
    assert!(log.contains("never given the choice"), "{log}");

    assert!(
        !run_check(TWO_PLUS_PROSE, None).0,
        "two options plus a numeric line is not three"
    );
}

/// The pass-1 hole, as a test: a vajra that says READY while reporting no options must NOT pass.
/// The gate reads the number, never the word.
#[test]
fn the_word_ready_alone_does_not_satisfy_the_gate() {
    let (passed, log) = run_check(
        NO_SECTION,
        Some("echo 'ranked options: 0'; echo 'verdict: READY'"),
    );
    assert!(!passed, "READY with zero options must still BLOCK:\n{log}");

    let (passed, _) = run_check(
        THREE_NUMBERED,
        Some("echo 'ranked options: 3'; echo 'verdict: READY'"),
    );
    assert!(passed, "three reported options must pass");
}

/// An older vajra prints no count at all; the gate must fall back rather than pass by default.
#[test]
fn an_old_vajra_without_the_count_falls_back_instead_of_passing() {
    let (passed, log) = run_check(NO_SECTION, Some("echo 'verdict: READY'"));
    assert!(!passed, "a pre-S171 vajra must not wave it through:\n{log}");
    assert!(log.contains("counting here instead"), "{log}");
}
