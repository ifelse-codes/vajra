//! S202 bug bash — the start-of-session hook printed every past session's section of
//! SESSION-BOOT.md, TASK.md and STATE.md at every start (~75 KB of Vajra's ~95 KB boot). It now
//! prints the newest three of each and names how many it held back; the files stay whole.

use std::fs;
use std::path::Path;
use std::process::Command;

#[test]
fn the_boot_prints_the_newest_three_sessions_and_names_the_rest() {
    let dir = tempfile::tempdir().unwrap();
    let r = dir.path();
    fs::create_dir_all(r.join(".ai")).unwrap();
    fs::write(r.join(".ai/SESSION"), "9\n").unwrap();
    fs::write(r.join(".ai/CONSTRAINTS.yaml"), "maturity: L2\n").unwrap();
    let mut task = String::from("# Task\n\n## Between Sessions — note\nkept\n\n");
    for n in (1..=8).rev() {
        task.push_str(&format!("## Session {n} — work\nbody of session {n}\n\n"));
    }
    task.push_str("## Open Questions\nalways shown\n");
    fs::write(r.join(".ai/TASK.md"), &task).unwrap();
    fs::write(
        r.join(".ai/STATE.md"),
        "# State\n\n## What was done this session (S8)\nnow\n\n## Previous session (S7)\na\n\n\
         ## Previous session (S6)\nb\n\n## Previous session (S5)\nc\n\n## Previous session (S4)\nd\n\n\
         ## What Currently Works\nworks\n",
    )
    .unwrap();
    fs::write(
        r.join(".ai/SESSION-BOOT.md"),
        "# Boot\n\n## Next Session\nnext\n",
    )
    .unwrap();

    let out = Command::new("bash")
        .arg(Path::new(env!("CARGO_MANIFEST_DIR")).join("scripts/hook-session-start.sh"))
        .env("CLAUDE_PROJECT_DIR", r)
        .stdin(std::process::Stdio::null())
        .output()
        .unwrap();
    let t = String::from_utf8_lossy(&out.stdout);

    for shown in [
        "body of session 8",
        "body of session 7",
        "body of session 6",
        "## Between Sessions — note",
        "always shown",
        "## Previous session (S7)",
        "## Previous session (S6)",
        "## Previous session (S5)",
        "## What was done this session (S8)",
        "works",
    ] {
        assert!(t.contains(shown), "missing {shown:?}:\n{t}");
    }
    for held in [
        "body of session 5",
        "body of session 1",
        "## Previous session (S4)",
    ] {
        assert!(!t.contains(held), "{held:?} should be held back:\n{t}");
    }
    assert!(
        t.contains("[boot] 5 older session section(s) of .ai/TASK.md not shown"),
        "{t}"
    );
    assert!(
        t.contains("[boot] 1 older session section(s) of .ai/STATE.md not shown"),
        "{t}"
    );
    assert_eq!(fs::read_to_string(r.join(".ai/TASK.md")).unwrap(), task);
}
