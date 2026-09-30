//! S181 Part 2 — ONE shared answer to "is session N a ground-truth session?", run for real.
//!
//! The founder's rule: the default is every 5th session; `ground_truth_next_session` is a one-time
//! override that only counts until that session has happened (its report exists) or been passed.
//! `.ai/CONSTRAINTS.yaml` in Vajra itself says `180` and must NEVER need an edit to keep working.
//! Each test drives real bash: the helper directly, then real sites (hook-stop, hook-pre-bash, the
//! close gate function) on a session branch — so a site still carrying its own copy would disagree.

use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

fn scripts() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("scripts")
}

/// A project with `ground_truth_next_session: key` (or none), and reports for `reported` sessions.
fn project(key: Option<u32>, reported: &[u32], branch_n: Option<u32>) -> tempfile::TempDir {
    let dir = tempfile::tempdir().unwrap();
    let r = dir.path();
    fs::create_dir_all(r.join(".ai")).unwrap();
    fs::create_dir_all(r.join("sessions")).unwrap();
    let mut c = String::from("maturity: L2\nsession:\n  ground_truth_every_n_sessions: 5\n");
    if let Some(k) = key {
        c.push_str(&format!("  ground_truth_next_session: {k}\n"));
    }
    fs::write(r.join(".ai/CONSTRAINTS.yaml"), c).unwrap();
    for n in reported {
        fs::write(r.join(format!("sessions/session-{n}-ground-truth.md")), "x").unwrap();
    }
    if let Some(n) = branch_n {
        for args in [
            vec!["init".to_string(), "-q".into()],
            vec![
                "checkout".into(),
                "-q".into(),
                "-b".into(),
                format!("session-{n}-x"),
            ],
        ] {
            assert!(Command::new("git")
                .args(&args)
                .current_dir(r)
                .status()
                .unwrap()
                .success());
        }
    }
    dir
}

/// (is ground truth, note) from the helper itself.
fn helper(dir: &Path, n: u32) -> (bool, String) {
    let out = Command::new("bash")
        .arg("-c")
        .arg(format!(
            "source '{}'; if vajra_is_ground_truth {n} '{}'; then echo GT=yes; else echo GT=no; fi; echo \"NOTE=$VAJRA_GT_NOTE\"",
            scripts().join("lib-ground-truth.sh").display(),
            dir.display()
        ))
        .output()
        .unwrap();
    let t = String::from_utf8_lossy(&out.stdout).into_owned();
    (
        t.contains("GT=yes"),
        t.lines()
            .find(|l| l.starts_with("NOTE="))
            .unwrap_or("")
            .to_string(),
    )
}

#[test]
fn vajra_own_setting_180_needs_no_edit_after_180() {
    // Vajra's real state after S180: key 180, its report exists.
    let d = project(Some(180), &[180], None);
    assert!(!helper(d.path(), 181).0, "S181 is not ground truth");
    assert!(!helper(d.path(), 184).0);
    assert!(
        helper(d.path(), 185).0,
        "S185 is ground truth with the key still 180"
    );
    assert!(helper(d.path(), 190).0);
    assert!(helper(d.path(), 180).0, "the named session itself");
    assert_eq!(
        helper(d.path(), 181).1,
        "NOTE=",
        "a reported override says nothing"
    );
}

#[test]
fn an_override_only_counts_until_its_session_and_earlier_sessions_stay_code() {
    // rudra: key 15, so S10 (a multiple of 5) is CODE — the S177 behaviour is kept.
    let d = project(Some(15), &[], None);
    assert!(!helper(d.path(), 10).0);
    assert!(helper(d.path(), 15).0);
}

#[test]
fn a_passed_override_with_no_report_rolls_forward_and_says_so() {
    let d = project(Some(180), &[], None); // 180 came and went, no report
    let (gt181, note) = helper(d.path(), 181);
    assert!(!gt181);
    assert!(
        note.contains("180") && note.contains("185") && note.contains("passed"),
        "{note}"
    );
    assert!(!helper(d.path(), 184).0);
    assert!(
        helper(d.path(), 185).0,
        "rolls to the next multiple of 5 above the key"
    );
    assert!(helper(d.path(), 190).0, "and keeps going every 5th");
}

#[test]
fn no_key_is_plain_every_fifth() {
    let d = project(None, &[], None);
    assert!(helper(d.path(), 10).0 && !helper(d.path(), 11).0 && !helper(d.path(), 0).0);
}

/// hook-stop.sh, run for real: on a ground-truth branch with no report it complains; else silent.
fn stop_hook_says_gt(d: &Path) -> bool {
    let out = Command::new("bash")
        .arg(scripts().join("hook-stop.sh"))
        .env("CLAUDE_PROJECT_DIR", d)
        .output()
        .unwrap();
    String::from_utf8_lossy(&out.stdout).contains("Ground Truth Session")
}

/// hook-pre-bash.sh, run for real: a `git commit` on a ground-truth branch is blocked (exit 2).
fn pre_bash_blocks_commit(d: &Path) -> bool {
    use std::io::Write;
    let mut c = Command::new("bash")
        .arg(scripts().join("hook-pre-bash.sh"))
        .env("CLAUDE_PROJECT_DIR", d)
        .stdin(std::process::Stdio::piped())
        .stdout(std::process::Stdio::piped())
        .stderr(std::process::Stdio::piped())
        .spawn()
        .unwrap();
    c.stdin
        .take()
        .unwrap()
        .write_all(br#"{"tool_input":{"command":"git commit -m x"}}"#)
        .unwrap();
    c.wait_with_output().unwrap().status.code() == Some(2)
}

#[test]
fn real_sites_agree_with_the_helper() {
    if Command::new("jq").arg("--version").output().is_err() {
        return; // pre-bash fails closed without jq; the stop hook + helper cases above still run
    }
    // S181 with key 180 reported: NOT ground truth at any site. S185: ground truth at both.
    for (n, want) in [(181, false), (185, true)] {
        let d = project(Some(180), &[180], Some(n));
        assert_eq!(stop_hook_says_gt(d.path()), want, "hook-stop at S{n}");
        assert_eq!(
            pre_bash_blocks_commit(d.path()),
            want,
            "hook-pre-bash at S{n}"
        );
    }
    // A passed override rolls forward at the sites too.
    let d = project(Some(180), &[], Some(181));
    assert!(!stop_hook_says_gt(d.path()));
    let d = project(Some(180), &[], Some(185));
    assert!(stop_hook_says_gt(d.path()));
}
