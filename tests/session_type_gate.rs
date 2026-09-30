//! S181 Part 3 — `session_type:` is ONE strict field; the close gate never guesses from prose.
//!
//! Runs the real `check_session_type` / `is_code_session` out of BOTH close gates (Vajra's own and
//! the scaffold's) against a fixture brief. Missing or unknown fails closed; sessions 1-180 that
//! predate the field keep the old reading, and say so loudly.

use std::fs;
use std::path::Path;
use std::process::Command;

const GATES: [&str; 2] = [
    "scripts/verify-closeout.sh",
    "scripts/verify-closeout-scaffold.sh",
];

/// (check passed, is_code_session, log) for session `n` whose brief body is `brief`.
fn run(gate: &str, n: u32, brief: &str) -> (bool, bool, String) {
    let dir = tempfile::tempdir().unwrap();
    let r = dir.path();
    fs::create_dir_all(r.join(".ai")).unwrap();
    fs::create_dir_all(r.join("prompts")).unwrap();
    fs::write(
        r.join(".ai/CONSTRAINTS.yaml"),
        "session:\n  ground_truth_every_n_sessions: 5\n",
    )
    .unwrap();
    fs::write(r.join(format!("prompts/{n:02}-task-x.md")), brief).unwrap();
    let m = Path::new(env!("CARGO_MANIFEST_DIR"));
    fs::copy(m.join(gate), r.join("gate.sh")).unwrap();
    let script = format!(
        r#"
      ROOT=.; source '{lib}'
      eval "$(grep -E '^LEGACY_TYPE_LAST_SESSION=' gate.sh | head -1)"
      for f in is_ground_truth_session legacy_is_code_session is_code_session check_session_type; do
        source /dev/stdin <<<"$(sed -n "/^$f()/,/^}}/p" gate.sh)"
      done
      N={n}; ARTIFACTS=.
      ok()  {{ echo "RESULT=PASS"; }}
      bad() {{ echo "RESULT=FAIL"; }}
      check_session_type
      if is_code_session; then echo "CODE=yes"; else echo "CODE=no"; fi
      cat session-type-declared.log
    "#,
        lib = m.join("scripts/lib-ground-truth.sh").display()
    );
    let out = Command::new("bash")
        .arg("-c")
        .arg(script)
        .current_dir(r)
        .output()
        .unwrap();
    let t = format!(
        "{}{}",
        String::from_utf8_lossy(&out.stdout),
        String::from_utf8_lossy(&out.stderr)
    );
    (t.contains("RESULT=PASS"), t.contains("CODE=yes"), t)
}

#[test]
fn each_valid_value_is_honoured() {
    for gate in GATES {
        for (ty, code) in [("CODE", true), ("INTERACTIVE", true), ("DOCUMENT", false)] {
            let (pass, is_code, log) = run(gate, 181, &format!("# S\n\nsession_type: {ty}\n"));
            assert!(pass && is_code == code, "{gate} {ty}: {log}");
        }
        // GROUND_TRUTH on a real cadence session (185) is honoured and non-CODE.
        let (pass, is_code, log) = run(gate, 185, "# S\n\nsession_type: GROUND_TRUTH\n");
        assert!(pass && !is_code, "{gate} GT@185: {log}");
    }
}

#[test]
fn missing_or_unknown_fails_closed_after_180() {
    for gate in GATES {
        // Missing — even though the prose says **CODE** (and **NO-CODE** below): prose is never read.
        for brief in [
            "# S\n\n## Type\n- **CODE**, one story.\n",
            "# S\n\n## Type\n- **NO-CODE** review.\n",
        ] {
            let (pass, is_code, log) = run(gate, 181, brief);
            assert!(!pass, "{gate}: missing must FAIL: {log}");
            assert!(
                is_code,
                "{gate}: undeclared is treated as CODE (stricter): {log}"
            );
            assert!(log.contains("no 'session_type:' line"), "{log}");
        }
        for bad in ["code", "CODE | DOCUMENT", "NO-CODE", ""] {
            let (pass, _, log) = run(gate, 181, &format!("# S\n\nsession_type: {bad}\n"));
            assert!(!pass, "{gate}: '{bad}' must FAIL: {log}");
        }
        let (pass, _, log) = run(
            gate,
            181,
            "# S\n\nsession_type: CODE\nsession_type: DOCUMENT\n",
        );
        assert!(!pass && log.contains("more than one"), "{gate}: {log}");
        // A key buried in prose is not a declaration.
        let (pass, _, _) = run(gate, 181, "# S\n\nwe set `session_type: CODE` later\n");
        assert!(
            !pass,
            "{gate}: an indented/embedded mention is not the field"
        );
    }
}

#[test]
fn a_session_cannot_label_itself_review_only() {
    for gate in GATES {
        let (pass, _, log) = run(gate, 181, "# S\n\nsession_type: GROUND_TRUTH\n");
        assert!(
            !pass && log.contains("cannot label itself"),
            "{gate}: {log}"
        );
    }
}

#[test]
fn old_briefs_keep_working_by_a_loud_named_fallback() {
    for gate in GATES {
        let (pass, is_code, log) = run(gate, 179, "# S\n\n## Type\n- **CODE**, interactive.\n");
        assert!(pass && is_code, "{gate}: {log}");
        assert!(
            log.contains("LEGACY FALLBACK") && log.contains("2026-09-30"),
            "{gate}: {log}"
        );
        let (pass, is_code, _) = run(gate, 179, "# S\n\n## Type\n- **NO-CODE** review.\n");
        assert!(pass && !is_code, "{gate}: legacy non-CODE still non-CODE");
    }
}
