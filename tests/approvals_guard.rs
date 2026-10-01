//! S182 Part 6 — the approvals guard blocks by whether a command can WRITE, not on any `>`.
//!
//! Drives the real `scripts/hook-approvals-guard.sh` (and Vajra's own `hook-pre-bash.sh` /
//! `hook-pre-write.sh`, which call it) with the JSON Claude Code sends. Two live false blocks at the
//! start of S182 are the read cases; every write the S181 line blocked must still block (S173).

use std::io::Write as _;
use std::path::Path;
use std::process::{Command, Stdio};

const DIR: &str = ".ai/approvals";

/// Run `script` with `payload` on stdin in an empty L2 project; returns (exit code, stderr).
fn run(script: &str, payload: serde_json::Value) -> (i32, String) {
    let proj = tempfile::tempdir().unwrap();
    std::fs::create_dir_all(proj.path().join(".ai")).unwrap();
    std::fs::write(proj.path().join(".ai/CONSTRAINTS.yaml"), "maturity: L2\n").unwrap();
    let m = Path::new(env!("CARGO_MANIFEST_DIR"));
    let mut child = Command::new("bash")
        .arg(m.join(script))
        .env("CLAUDE_PROJECT_DIR", proj.path())
        .env_remove("VAJRA_GUARD_MATURITY")
        .current_dir(proj.path())
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .unwrap();
    child
        .stdin
        .take()
        .unwrap()
        .write_all(payload.to_string().as_bytes())
        .unwrap();
    let out = child.wait_with_output().unwrap();
    (
        out.status.code().unwrap_or(-1),
        String::from_utf8_lossy(&out.stderr).into_owned(),
    )
}

fn bash(cmd: &str) -> (i32, String) {
    run(
        "scripts/hook-approvals-guard.sh",
        serde_json::json!({"tool_name": "Bash", "tool_input": {"command": cmd}}),
    )
}

#[test]
fn reads_pass() {
    for cmd in [
        format!("cat {DIR}/session-181.json"),
        // the S182 live false block: a read beside a `2>&1` elsewhere in the same command
        format!("vajra approve --help 2>&1 | head -5; cat {DIR}/session-181.json"),
        format!("cat {DIR}/x 2>&1"),
        format!("ls {DIR} 2>/dev/null"),
        format!("jq . {DIR}/x >/dev/null 2>&1 && echo ok"),
        format!("git add {DIR}/session-182.json"),
        "echo hello > notes.txt".to_string(), // a write that does not name the folder
    ] {
        let (code, err) = bash(&cmd);
        assert_eq!(code, 0, "read was blocked: {cmd}\n{err}");
    }
}

#[test]
fn writes_still_block() {
    for cmd in [
        format!("echo x > {DIR}/x"),
        format!("echo x >> {DIR}/x"),
        format!("echo x 2>&1 > {DIR}/x"),
        format!("echo x 2> {DIR}/x"),
        format!("echo x &> {DIR}/x"),
        format!("echo x >| {DIR}/x"),
        format!("echo x | tee {DIR}/x"),
        format!("cp /tmp/y {DIR}/x"),
        format!("mv /tmp/y {DIR}/x"),
        format!("rm {DIR}/x"),
        format!("touch {DIR}/x"),
        format!("sed -i '' 's/a/b/' {DIR}/x"),
        format!("sed -E -i '' 's/a/b/' {DIR}/x"),
        format!("ln -s /tmp/y {DIR}/x"),
        format!("truncate -s 0 {DIR}/x"),
        format!("python3 -c 'open(\"{DIR}/x\",\"w\")'"),
        format!("perl -e 'print 1' {DIR}/x"),
        format!("node -e '' {DIR}/x"),
        format!("cat {DIR}/x > /tmp/copy"), // over-blocks a redirect elsewhere: kept (only add)
        format!("cat .ai//approvals/x > y"),
        "cd .ai && echo x > approvals/x".to_string(), // S181's disclosed gap, closed
        "cd .ai/approvals && touch x".to_string(),
        "x=`cd .ai && echo y > approvals/z`".to_string(), // inside backticks (S182, found at close)
    ] {
        let (code, err) = bash(&cmd);
        assert_eq!(code, 2, "write was not blocked: {cmd}");
        assert!(
            err.contains("[HOOK BLOCK]"),
            "block message not on stderr: {cmd}\n{err}"
        );
    }
}

#[test]
fn write_tools_block_on_the_path() {
    for (tool, key, path) in [
        ("Write", "file_path", format!("/p/{DIR}/session-9.json")),
        ("Edit", "file_path", format!("{DIR}/session-9.json")),
        (
            "MultiEdit",
            "file_path",
            "/p/.ai//./approvals/x".to_string(),
        ),
        ("NotebookEdit", "notebook_path", format!("/p/{DIR}/n.ipynb")),
    ] {
        let (code, _) = run(
            "scripts/hook-approvals-guard.sh",
            serde_json::json!({"tool_name": tool, "tool_input": {key: path}}),
        );
        assert_eq!(code, 2, "{tool} into {path} was not blocked");
    }
    let (code, _) = run(
        "scripts/hook-approvals-guard.sh",
        serde_json::json!({"tool_name": "Write", "tool_input": {"file_path": "/p/prompts/approvals-notes.md"}}),
    );
    assert_eq!(code, 0, "a file merely named like the folder was blocked");
}

#[test]
fn l1_warns_only() {
    let proj = tempfile::tempdir().unwrap();
    let m = Path::new(env!("CARGO_MANIFEST_DIR"));
    let mut child = Command::new("bash")
        .arg(m.join("scripts/hook-approvals-guard.sh"))
        .env("CLAUDE_PROJECT_DIR", proj.path())
        .env("VAJRA_GUARD_MATURITY", "L1")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()
        .unwrap();
    let p = serde_json::json!({"tool_input": {"command": format!("echo x > {DIR}/x")}});
    child
        .stdin
        .take()
        .unwrap()
        .write_all(p.to_string().as_bytes())
        .unwrap();
    let out = child.wait_with_output().unwrap();
    assert_eq!(out.status.code(), Some(0));
    assert!(String::from_utf8_lossy(&out.stdout).contains("[HOOK WARNING]"));
}

/// Vajra's own hooks call the one guard: same verdicts through them.
#[test]
fn vajras_own_hooks_call_the_guard() {
    let (code, err) = run(
        "scripts/hook-pre-bash.sh",
        serde_json::json!({"tool_name": "Bash", "tool_input": {"command": format!("echo x > {DIR}/x")}}),
    );
    assert_eq!(code, 2, "hook-pre-bash.sh let a write through\n{err}");
    let (code, err) = run(
        "scripts/hook-pre-bash.sh",
        serde_json::json!({"tool_name": "Bash", "tool_input": {"command": format!("cat {DIR}/x 2>&1")}}),
    );
    assert_eq!(code, 0, "hook-pre-bash.sh blocked a read\n{err}");
    let (code, _) = run(
        "scripts/hook-pre-write.sh",
        serde_json::json!({"tool_name": "Write", "tool_input": {"file_path": format!("/p/{DIR}/x")}}),
    );
    assert_eq!(code, 2, "hook-pre-write.sh let a write through");
}
