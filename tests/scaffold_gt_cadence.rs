//! The scaffold close gate reads the project's own "next ground truth" setting (S177, F74).
//!
//! rudra's founder moved the next review-only session to S15 (`ground_truth_next_session: 15`).
//! The session-start hook obeyed it; the close gate every project gets
//! (`scripts/verify-closeout-scaffold.sh`) still said `N % 5 == 0`, so rudra S10 — a CODE
//! session — would have passed "verify + demo scripts exist" and "tech-lead recorded" as N/A.
//! These tests run the real functions out of that file against a fixture project.

use std::fs;
use std::path::Path;
use std::process::Command;

/// Run `check_verify_demo_scripts` and `is_code_session` from the scaffold gate for session `n`,
/// in a project whose CONSTRAINTS.yaml carries `ground_truth_next_session: <gt_next>` (or no such
/// key). The session's prompt says CODE and it has NO verify/demo scripts. Returns
/// (scripts check passed, is_code_session, log).
fn run(n: u32, gt_next: Option<u32>) -> (bool, bool, String) {
    run_typed(n, gt_next, "- **CODE**, one story.")
}

/// `run`, with the prompt's `## Type` line given.
fn run_typed(n: u32, gt_next: Option<u32>, type_line: &str) -> (bool, bool, String) {
    let dir = tempfile::tempdir().unwrap();
    let root = dir.path();
    fs::create_dir_all(root.join(".ai")).unwrap();
    fs::create_dir_all(root.join("prompts")).unwrap();
    let mut constraints =
        String::from("version: 3\nsession:\n  ground_truth_every_n_sessions: 5\n");
    if let Some(g) = gt_next {
        constraints.push_str(&format!(
            "  ground_truth_next_session: {g}   # founder moved it\n"
        ));
    }
    fs::write(root.join(".ai/CONSTRAINTS.yaml"), constraints).unwrap();
    fs::write(
        root.join(format!("prompts/{n:02}-task-x.md")),
        format!("# S\n\n## Type\n{type_line}\n"),
    )
    .unwrap();

    let gate = Path::new(env!("CARGO_MANIFEST_DIR")).join("scripts/verify-closeout-scaffold.sh");
    fs::copy(&gate, root.join("gate.sh")).unwrap();

    let script = format!(
        r#"
      for f in is_ground_truth_session is_code_session check_verify_demo_scripts spath waiver_ok; do
        source /dev/stdin <<<"$(sed -n "/^$f()/,/^}}/p" gate.sh)"
      done
      waiver_ok() {{ false; }}
      N={n}; ARTIFACTS=.
      ok()  {{ echo "RESULT=PASS"; }}
      bad() {{ echo "RESULT=FAIL"; }}
      check_verify_demo_scripts
      if is_code_session; then echo "CODE=yes"; else echo "CODE=no"; fi
      cat verify-demo-scripts-present.log
    "#
    );
    let out = Command::new("bash")
        .arg("-c")
        .arg(script)
        .current_dir(root)
        .output()
        .expect("bash runs");
    let text = format!(
        "{}{}",
        String::from_utf8_lossy(&out.stdout),
        String::from_utf8_lossy(&out.stderr)
    );
    (
        text.contains("RESULT=PASS"),
        text.contains("CODE=yes"),
        text,
    )
}

/// rudra S10 with the ground truth moved to S15: a CODE session, so the checks run.
#[test]
fn a_moved_ground_truth_makes_session_10_a_code_session() {
    let (passed, code, log) = run(10, Some(15));
    assert!(
        code,
        "S10 is CODE when the ground truth moved to S15:\n{log}"
    );
    assert!(
        !passed,
        "S10 without scripts must BLOCK, not pass as N/A:\n{log}"
    );
    assert!(
        log.contains("MISSING: scripts/verify-session-10.sh"),
        "{log}"
    );
}

/// The session the founder named is the review-only one.
#[test]
fn the_named_session_is_the_ground_truth() {
    let (passed, code, log) = run(15, Some(15));
    assert!(!code, "S15 is the ground truth:\n{log}");
    assert!(passed, "S15 needs no session scripts:\n{log}");
    assert!(log.contains("N/A"), "{log}");
}

/// No key → the every-5th rule, exactly as before.
#[test]
fn without_the_setting_every_fifth_session_is_unchanged() {
    let (passed, code, log) = run(10, None);
    assert!(
        !code && passed && log.contains("N/A"),
        "old rule: S10 is GT:\n{log}"
    );
    let (passed, code, log) = run(9, None);
    assert!(
        code && !passed,
        "old rule: S9 is CODE and blocks without scripts:\n{log}"
    );
}

/// F76: rudra writes `- **CODE.** Max 2 assumptions` — the period inside the bold. The exact
/// `**CODE**` match read every one of its CODE sessions (S02–S10) as non-CODE, so the close
/// gate's tech-lead check never ran there. A NO-CODE session must still read as non-CODE.
#[test]
fn the_rudra_spelling_of_code_is_a_code_session() {
    for line in [
        "- **CODE.** Max 2 assumptions · 2 retries · ~2h · **1 story**",
        "- **CODE** — fixes",
        "- **CODE**, interactive.",
    ] {
        let (_, code, log) = run_typed(9, None, line);
        assert!(code, "{line:?} is a CODE session:\n{log}");
    }
    for line in [
        "- **NO-CODE.** Max 2 assumptions",
        "- **NO-CODE** ground truth",
        "- **DOCUMENT.** No source changes",
    ] {
        let (_, code, log) = run_typed(9, None, line);
        assert!(!code, "{line:?} is not a CODE session:\n{log}");
    }
}
