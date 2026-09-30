//! S181 Part 5 — a waiver skips only the checks it NAMES, needs a reason, and says how it was set.
//!
//! Runs two REAL waivable checks out of both close gates on a fixture that fails both of them:
//! `verify-demo-scripts-present` (a CODE session with no verify/demo scripts) and
//! `fidelity-review-accept` (no review file). Before S181 one `VAJRA_CLOSEOUT_WAIVER=N` waived both
//! (and ~20 more).

use std::fs;
use std::path::Path;
use std::process::Command;

const GATES: [&str; 2] = [
    "scripts/verify-closeout.sh",
    "scripts/verify-closeout-scaffold.sh",
];

/// Run both checks for session 181 under the given waiver env; returns (scripts-check passed,
/// review-check passed, scripts-check log, review-check log, stderr).
fn run(gate: &str, env: &[(&str, &str)]) -> (bool, bool, String, String, String) {
    let dir = tempfile::tempdir().unwrap();
    let r = dir.path();
    fs::create_dir_all(r.join(".ai")).unwrap();
    fs::create_dir_all(r.join("prompts")).unwrap();
    fs::create_dir_all(r.join("sessions")).unwrap();
    fs::write(
        r.join(".ai/CONSTRAINTS.yaml"),
        "session:\n  ground_truth_every_n_sessions: 5\n",
    )
    .unwrap();
    fs::write(
        r.join("prompts/181-task-x.md"),
        "# S\n\nsession_type: CODE\n",
    )
    .unwrap();
    let m = Path::new(env!("CARGO_MANIFEST_DIR"));
    fs::copy(m.join(gate), r.join("gate.sh")).unwrap();
    let script = format!(
        r#"
      ROOT=.; source '{lib}'
      eval "$(grep -E '^LEGACY_TYPE_LAST_SESSION=' gate.sh | head -1)"
      for f in is_ground_truth_session legacy_is_code_session is_code_session spath waiver_ok \
               check_verify_demo_scripts check_fidelity_review; do
        source /dev/stdin <<<"$(sed -n "/^$f()/,/^}}/p" gate.sh)"
      done
      N=181; ARTIFACTS=.
      ok()  {{ echo "RESULT $NAME PASS"; }}
      bad() {{ echo "RESULT $NAME FAIL"; }}
      check_verify_demo_scripts
      check_fidelity_review
    "#,
        lib = m.join("scripts/lib-ground-truth.sh").display()
    );
    let mut c = Command::new("bash");
    c.arg("-c").arg(script).current_dir(r);
    for k in [
        "VAJRA_WAIVE",
        "VAJRA_WAIVE_REASON",
        "VAJRA_LAUNCH_WAIVE",
        "VAJRA_CLOSEOUT_WAIVER",
        "VAJRA_CLOSEOUT_WAIVER_REASON",
    ] {
        c.env_remove(k);
    }
    for (k, v) in env {
        c.env(k, v);
    }
    let out = c.output().unwrap();
    let text = String::from_utf8_lossy(&out.stdout).into_owned();
    let read = |n: &str| fs::read_to_string(r.join(format!("{n}.log"))).unwrap_or_default();
    (
        text.contains("RESULT verify-demo-scripts-present PASS"),
        text.contains("RESULT fidelity-review-accept PASS"),
        read("verify-demo-scripts-present"),
        read("fidelity-review-accept"),
        String::from_utf8_lossy(&out.stderr).into_owned(),
    )
}

#[test]
fn with_no_waiver_both_checks_fail() {
    for gate in GATES {
        let (a, b, ..) = run(gate, &[]);
        assert!(!a && !b, "{gate}: the fixture must fail both checks");
    }
}

#[test]
fn a_waiver_naming_one_check_passes_only_that_check() {
    for gate in GATES {
        let env = [
            ("VAJRA_WAIVE", "verify-demo-scripts-present"),
            ("VAJRA_WAIVE_REASON", "dogfood run, no scripts by design"),
        ];
        let (a, b, la, _lb, _) = run(gate, &env);
        assert!(a, "{gate}: the named check is waived: {la}");
        assert!(!b, "{gate}: the OTHER check must still fail");
        assert!(
            la.contains("WAIVED (set later") && la.contains("dogfood run, no scripts by design"),
            "{gate}: {la}"
        );
    }
}

#[test]
fn a_waiver_with_no_reason_is_refused() {
    for gate in GATES {
        for reason in ["", "   "] {
            let env = [
                ("VAJRA_WAIVE", "verify-demo-scripts-present"),
                ("VAJRA_WAIVE_REASON", reason),
            ];
            let (a, _b, la, ..) = run(gate, &env);
            assert!(!a, "{gate}: a waiver without a reason must not waive: {la}");
            assert!(
                la.contains("REFUSED") && la.contains("reason"),
                "{gate}: {la}"
            );
        }
        let (a, ..) = run(gate, &[("VAJRA_WAIVE", "verify-demo-scripts-present")]);
        assert!(!a, "{gate}: no reason variable at all");
    }
}

#[test]
fn the_log_says_launch_time_or_set_later() {
    for gate in GATES {
        let waive = "verify-demo-scripts-present,fidelity-review-accept";
        let (a, b, la, lb, _) = run(
            gate,
            &[
                ("VAJRA_WAIVE", waive),
                ("VAJRA_WAIVE_REASON", "founder call"),
                ("VAJRA_LAUNCH_WAIVE", waive),
            ],
        );
        assert!(a && b, "{gate}: both named");
        assert!(
            la.contains("launch-time") && lb.contains("launch-time"),
            "{gate}: {la}"
        );
        // The launch copy differs from what is set now (someone widened it later): set later.
        let (_, _, la, _, _) = run(
            gate,
            &[
                ("VAJRA_WAIVE", waive),
                ("VAJRA_WAIVE_REASON", "founder call"),
                ("VAJRA_LAUNCH_WAIVE", "verify-demo-scripts-present"),
            ],
        );
        assert!(la.contains("set later"), "{gate}: {la}");
    }
}

#[test]
fn a_name_that_is_not_the_check_waives_nothing_and_a_prefix_does_not_count() {
    for gate in GATES {
        for names in ["verify-demo", "fidelity-review", "other-check"] {
            let env = [("VAJRA_WAIVE", names), ("VAJRA_WAIVE_REASON", "why")];
            let (a, b, ..) = run(gate, &env);
            assert!(!a && !b, "{gate}: '{names}' must waive nothing");
        }
    }
}

#[test]
fn the_old_whole_close_waiver_still_works_but_warns() {
    for gate in GATES {
        let env = [
            ("VAJRA_CLOSEOUT_WAIVER", "181"),
            ("VAJRA_CLOSEOUT_WAIVER_REASON", "old style"),
        ];
        let (a, b, la, _, err) = run(gate, &env);
        assert!(a && b, "{gate}: legacy waiver keeps working");
        assert!(
            la.contains("LEGACY") && la.contains("EVERY check"),
            "{gate}: {la}"
        );
        assert!(
            err.contains("VAJRA_WAIVE"),
            "{gate}: a printed warning: {err}"
        );
        // A waiver for another session does not apply (unchanged).
        let (a, ..) = run(gate, &[("VAJRA_CLOSEOUT_WAIVER", "180")]);
        assert!(!a, "{gate}: stale waiver for another session");
    }
}
