//! S181 Part 4 — `vajra approve` and the launch-time yes, against the REAL binary and REAL hooks.
//!
//! A real terminal for the "works from the founder's terminal" case comes from python's `pty`
//! (a stand-in for the founder's own shell); a plain spawn has no terminal, like an agent's shell tool.

use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

fn bin() -> &'static str {
    env!("CARGO_BIN_EXE_vajra")
}

fn record(dir: &Path, n: u32) -> PathBuf {
    dir.join(format!(".ai/approvals/session-{n:02}.json"))
}

/// Run `vajra approve 181` in `dir` on a pseudo-terminal; `mark` sets the agent mark in its env.
fn approve_on_a_tty(dir: &Path, mark: bool) -> (bool, String) {
    let py = format!(
        "import pty,os,sys\n\
         rc = pty.spawn(['{}','approve','181'])\n\
         sys.exit(0 if rc == 0 else 1)\n",
        bin()
    );
    let mut c = Command::new("python3");
    c.arg("-c").arg(py).current_dir(dir).stdin(Stdio::null());
    if mark {
        c.env("VAJRA_AGENT_MARK", "1");
    } else {
        c.env_remove("VAJRA_AGENT_MARK");
    }
    let out = c.output().expect("python3 with pty");
    (
        out.status.success(),
        format!(
            "{}{}",
            String::from_utf8_lossy(&out.stdout),
            String::from_utf8_lossy(&out.stderr)
        ),
    )
}

#[test]
fn approve_without_a_terminal_is_refused_and_writes_nothing() {
    let d = tempfile::tempdir().unwrap();
    let out = Command::new(bin())
        .args(["approve", "181"])
        .current_dir(d.path())
        .stdin(Stdio::null())
        .env_remove("VAJRA_AGENT_MARK")
        .output()
        .unwrap();
    assert!(!out.status.success());
    let err = String::from_utf8_lossy(&out.stderr);
    assert!(err.contains("not a terminal"), "{err}");
    assert!(
        !record(d.path(), 181).exists(),
        "a refusal must write nothing"
    );
}

#[test]
fn approve_from_a_marked_process_is_refused_even_on_a_terminal() {
    let d = tempfile::tempdir().unwrap();
    let (ok, text) = approve_on_a_tty(d.path(), true);
    assert!(!ok, "{text}");
    assert!(text.contains("VAJRA_AGENT_MARK"), "{text}");
    assert!(!record(d.path(), 181).exists());
}

#[test]
fn approve_from_an_unmarked_terminal_writes_the_record() {
    let d = tempfile::tempdir().unwrap();
    let (ok, text) = approve_on_a_tty(d.path(), false);
    assert!(ok, "{text}");
    let rec = fs::read_to_string(record(d.path(), 181)).expect("record written");
    assert!(
        rec.contains("\"session\": 181") && rec.contains("approve-command"),
        "{rec}"
    );
}

#[test]
fn an_agent_cannot_use_the_launch_time_yes() {
    for args in [vec!["claude", "--allow-all"], vec!["claude"]] {
        let d = tempfile::tempdir().unwrap();
        let mut c = Command::new(bin());
        c.args(&args)
            .current_dir(d.path())
            .stdin(Stdio::null())
            .env("VAJRA_AGENT_MARK", "1");
        if args.len() == 1 {
            c.env("VAJRA_APPROVE", "181");
        }
        let out = c.output().unwrap();
        let err = String::from_utf8_lossy(&out.stderr);
        assert!(!out.status.success(), "{args:?}: {err}");
        assert!(
            err.contains("refused") && err.contains("VAJRA_AGENT_MARK"),
            "{args:?}: {err}"
        );
        assert!(
            !d.path().join(".ai/approvals").exists(),
            "{args:?} wrote a record"
        );
    }
}

fn hook(name: &str, root: &Path, json: &str) -> i32 {
    use std::io::Write;
    let script = Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("scripts")
        .join(name);
    let mut c = Command::new("bash")
        .arg(script)
        .env("CLAUDE_PROJECT_DIR", root)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .unwrap();
    c.stdin.take().unwrap().write_all(json.as_bytes()).unwrap();
    c.wait_with_output().unwrap().status.code().unwrap_or(-1)
}

#[test]
fn the_agents_write_and_shell_tools_are_blocked_from_the_approvals_dir() {
    if Command::new("jq").arg("--version").output().is_err() {
        return;
    }
    let d = tempfile::tempdir().unwrap();
    fs::create_dir_all(d.path().join(".ai")).unwrap();
    fs::write(d.path().join(".ai/CONSTRAINTS.yaml"), "maturity: L2\n").unwrap();
    let f = d.path().join(".ai/approvals/session-181.json");
    let w = format!(r#"{{"tool_input":{{"file_path":"{}"}}}}"#, f.display());
    assert_eq!(hook("hook-pre-write.sh", d.path(), &w), 2, "Write tool");
    let other = format!(
        r#"{{"tool_input":{{"file_path":"{}/notes.md"}}}}"#,
        d.path().display()
    );
    assert_eq!(
        hook("hook-pre-write.sh", d.path(), &other),
        0,
        "positive anchor: other files still pass"
    );
    for cmd in [
        "echo '{}' > .ai/approvals/session-181.json",
        "cp x .ai/approvals/session-181.json",
        "python3 -c \"open('.ai/approvals/session-181.json','w')\"",
    ] {
        let j = serde_json::json!({"tool_input": {"command": cmd}}).to_string();
        assert_eq!(hook("hook-pre-bash.sh", d.path(), &j), 2, "{cmd}");
    }
    for cmd in [
        "ls .ai/approvals",
        "git add .ai/approvals",
        "cat .ai/approvals/session-181.json",
    ] {
        let j = serde_json::json!({"tool_input": {"command": cmd}}).to_string();
        assert_eq!(
            hook("hook-pre-bash.sh", d.path(), &j),
            0,
            "{cmd} is a read/stage and must pass"
        );
    }
}
