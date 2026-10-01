//! S182 Parts 3–4 — the approvals guard reaches projects, and a project is told (never edited) when
//! it has no `session_rules_from`.
//!
//! A guard file on disk that no settings entry runs is not a guard (S129, "registered ≠ run"), so
//! every check here finds the hook THROUGH the project's `.claude/settings.json` — the matcher that
//! Claude Code would apply to the tool — and runs that exact command string.

use std::fs;
use std::io::Write as _;
use std::path::Path;
use std::process::{Command, Stdio};

const GUARD: &str = "hook-approvals-guard.sh";

/// The command strings `.claude/settings.json` registers for `tool` under PreToolUse.
fn registered_for(root: &Path, tool: &str) -> Vec<String> {
    let s: serde_json::Value =
        serde_json::from_str(&fs::read_to_string(root.join(".claude/settings.json")).unwrap())
            .unwrap();
    let mut out = Vec::new();
    for g in s["hooks"]["PreToolUse"].as_array().unwrap() {
        let m = g["matcher"].as_str().unwrap_or("");
        if !m.split('|').any(|t| t == tool) {
            continue;
        }
        for h in g["hooks"].as_array().unwrap() {
            out.push(h["command"].as_str().unwrap().to_string());
        }
    }
    out
}

/// Run the registered approvals-guard command for `tool` exactly as settings spell it.
fn guard_exit(root: &Path, tool: &str, input: serde_json::Value) -> i32 {
    let cmds: Vec<String> = registered_for(root, tool)
        .into_iter()
        .filter(|c| c.contains(GUARD))
        .collect();
    assert_eq!(
        cmds.len(),
        1,
        "{tool}: the approvals guard must be registered exactly once, got {cmds:?}"
    );
    let mut child = Command::new("bash")
        .arg("-c")
        .arg(&cmds[0])
        .env("CLAUDE_PROJECT_DIR", root)
        .env_remove("VAJRA_GUARD_MATURITY")
        .current_dir(root)
        .stdin(Stdio::piped())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .spawn()
        .unwrap();
    let payload = serde_json::json!({"tool_name": tool, "tool_input": input});
    child
        .stdin
        .take()
        .unwrap()
        .write_all(payload.to_string().as_bytes())
        .unwrap();
    child.wait().unwrap().code().unwrap_or(-1)
}

fn assert_guarded(root: &Path) {
    let w = format!("{}/.ai/approvals/session-9.json", root.display());
    assert_eq!(
        guard_exit(root, "Write", serde_json::json!({"file_path": w})),
        2
    );
    assert_eq!(
        guard_exit(root, "Edit", serde_json::json!({"file_path": w})),
        2
    );
    assert_eq!(
        guard_exit(
            root,
            "Bash",
            serde_json::json!({"command": "echo x > .ai/approvals/s.json"})
        ),
        2
    );
    assert_eq!(
        guard_exit(
            root,
            "Bash",
            serde_json::json!({"command": "cat .ai/approvals/s.json 2>&1"})
        ),
        0,
        "a read must pass"
    );
}

fn new_project() -> tempfile::TempDir {
    let t = tempfile::tempdir().unwrap();
    fs::create_dir(t.path().join(".git")).unwrap();
    vajractl::cli::init::scaffold(t.path(), "P", "build the thing", "L2").unwrap();
    t
}

#[test]
fn a_new_project_is_guarded_through_its_settings() {
    let t = new_project();
    assert!(t.path().join(".ai/hooks").join(GUARD).exists());
    assert_guarded(t.path());
}
