//! S181 Part 4 — the human's "approved" that the agent cannot type (F77, F85, F92).
//!
//! Until S181 a brief was approved when its `Status:` line said APPROVED — words the agent can type
//! itself. From S181 the gate reads an approval RECORD, never the brief's words. A record is written
//! only by a process the agent did not start:
//!
//! - `vajra approve NN`, run by the founder in their own terminal. It REFUSES when the environment
//!   carries the mark Vajra puts on everything it launches ([`AGENT_MARK`]) and when stdin is not a
//!   terminal (an agent's shell tool has none).
//! - `VAJRA_APPROVE=NN vajra claude` — the founder's launch-time yes; the launcher writes the record.
//! - `vajra claude --allow-all` — the founder's launch-time "allow everything this run"; recorded as
//!   "human chose at start", live only while that launch is running.
//!
//! LIMIT (read this): bar-raising, NOT tamper-proof. The agent runs as the same OS user; it could
//! strip the mark (`env -u`), fake a terminal, or write the record file itself. The Vajra hooks block
//! its Write/Bash tools from `.ai/approvals/`, and the record is a file in git, so the trail is
//! reviewable — but a determined agent with a shell is not stopped by this alone.

use anyhow::{bail, Context, Result};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

/// Env var `vajra claude` sets on the process it spawns (and so on everything the agent starts).
pub const AGENT_MARK: &str = "VAJRA_AGENT_MARK";
/// Sessions up to this number predate approval records and keep the brief's `Status:` line — the
/// named, dated fallback (2026-09-30, S181). The gate prints a LEGACY warning whenever it is used.
pub const LEGACY_LAST_SESSION: u32 = 180;

pub fn dir(root: &Path) -> PathBuf {
    root.join(".ai/approvals")
}

fn session_path(root: &Path, n: u32) -> PathBuf {
    dir(root).join(format!("session-{n:02}.json"))
}

fn allow_all_path(root: &Path) -> PathBuf {
    dir(root).join("allow-all.launch")
}

fn now() -> u64 {
    std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0)
}

/// How a session's approval was given.
#[derive(Debug, PartialEq, Eq)]
pub enum Approved {
    /// `vajra approve NN` from the founder's own terminal.
    Command,
    /// `VAJRA_APPROVE=NN` set at launch.
    LaunchEnv,
    /// `vajra claude --allow-all`, while that launch is still running.
    AllowAll,
}

impl Approved {
    pub fn describe(&self) -> &'static str {
        match self {
            Approved::Command => "`vajra approve` (human, own terminal)",
            Approved::LaunchEnv => "VAJRA_APPROVE at launch (human chose at start)",
            Approved::AllowAll => "--allow-all at launch (human chose at start)",
        }
    }
}

/// Is session `n` approved by a record? `None` = no record; the brief's words never count.
pub fn approved(root: &Path, n: u32) -> Option<Approved> {
    if let Ok(text) = fs::read_to_string(session_path(root, n)) {
        if let Ok(v) = serde_json::from_str::<serde_json::Value>(&text) {
            if v.get("session").and_then(|s| s.as_u64()) == Some(n as u64) {
                return match v.get("method").and_then(|m| m.as_str()) {
                    Some("launch-env") => Some(Approved::LaunchEnv),
                    Some("approve-command") => Some(Approved::Command),
                    _ => None, // unknown method: not a record we wrote
                };
            }
        }
    }
    if allow_all_live(root) {
        return Some(Approved::AllowAll);
    }
    None
}

/// The allow-all record counts only while the launch that wrote it is still running.
fn allow_all_live(root: &Path) -> bool {
    let Ok(text) = fs::read_to_string(allow_all_path(root)) else {
        return false;
    };
    let Ok(v) = serde_json::from_str::<serde_json::Value>(&text) else {
        return false;
    };
    match v.get("pid").and_then(|p| p.as_u64()) {
        Some(pid) => pid_alive(pid),
        None => false,
    }
}

fn pid_alive(pid: u64) -> bool {
    Command::new("kill")
        .args(["-0", &pid.to_string()])
        .stdout(std::process::Stdio::null())
        .stderr(std::process::Stdio::null())
        .status()
        .is_ok_and(|s| s.success())
}

fn write_record(root: &Path, n: u32, method: &str) -> Result<PathBuf> {
    fs::create_dir_all(dir(root)).context("cannot create .ai/approvals")?;
    let p = session_path(root, n);
    let body = serde_json::json!({ "session": n, "method": method, "at_unix": now() });
    fs::write(&p, serde_json::to_string_pretty(&body)? + "\n")
        .with_context(|| format!("cannot write {}", p.display()))?;
    Ok(p)
}

/// Why `vajra approve` refuses to run here, or `None` if this is the founder's own terminal.
pub fn refusal(marked: bool, stdin_is_terminal: bool) -> Option<&'static str> {
    if marked {
        return Some(
            "this shell was started by Vajra for an agent (VAJRA_AGENT_MARK is set). Only the \
             founder approves, from their OWN terminal — open one outside the agent and run it there.",
        );
    }
    if !stdin_is_terminal {
        return Some(
            "stdin is not a terminal. `vajra approve` only works typed by a person at a terminal — \
             an agent's shell tool has none.",
        );
    }
    None
}

/// `vajra approve NN` with the process facts passed in (so they can be tested).
pub fn approve(root: &Path, n: u32, marked: bool, stdin_is_terminal: bool) -> Result<String> {
    if let Some(why) = refusal(marked, stdin_is_terminal) {
        bail!("vajra approve refused: {why}");
    }
    let p = write_record(root, n, "approve-command")?;
    Ok(format!(
        "approved session {n} — recorded in {} (human, own terminal). Commit it with the session.",
        p.strip_prefix(root).unwrap_or(&p).display()
    ))
}

/// Launch-time records, written by the launcher from the founder's own env/flags. Called only when
/// the launcher itself is unmarked — a marked launcher (an agent running `vajra claude`) gets nothing.
pub fn record_launch_env(root: &Path, n: u32) -> Result<PathBuf> {
    write_record(root, n, "launch-env")
}

pub fn record_allow_all(root: &Path, pid: u32) -> Result<PathBuf> {
    fs::create_dir_all(dir(root))?;
    let p = allow_all_path(root);
    let body = serde_json::json!({ "method": "allow-all", "pid": pid, "at_unix": now(),
        "note": "human chose at start; live only while this launch runs" });
    fs::write(&p, serde_json::to_string_pretty(&body)? + "\n")?;
    Ok(p)
}

pub fn clear_allow_all(root: &Path) {
    let _ = fs::remove_file(allow_all_path(root));
}

/// Whether this process carries the agent mark.
pub fn is_marked() -> bool {
    std::env::var_os(AGENT_MARK).is_some()
}

#[cfg(unix)]
pub fn stdin_is_terminal() -> bool {
    // SAFETY: isatty on fd 0 has no memory effects.
    unsafe { libc::isatty(0) == 1 }
}

#[cfg(not(unix))]
pub fn stdin_is_terminal() -> bool {
    false
}

/// The `vajra approve NN` command line.
pub fn run(args: &[String]) -> Result<()> {
    let n: u32 = match args {
        [a] => a
            .trim()
            .parse()
            .map_err(|_| anyhow::anyhow!("usage: vajra approve <session number>"))?,
        _ => bail!("usage: vajra approve <session number>"),
    };
    let root = std::env::current_dir()?;
    println!("{}", approve(&root, n, is_marked(), stdin_is_terminal())?);
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn approve_refused_when_marked_or_no_terminal_and_writes_nothing() {
        let d = tempfile::tempdir().unwrap();
        assert!(approve(d.path(), 181, true, true).is_err(), "marked");
        assert!(approve(d.path(), 181, false, false).is_err(), "no terminal");
        assert!(!dir(d.path()).exists(), "a refusal writes nothing");
        assert_eq!(approved(d.path(), 181), None);
    }

    #[test]
    fn approve_from_a_terminal_writes_a_record_the_gate_reads() {
        let d = tempfile::tempdir().unwrap();
        approve(d.path(), 181, false, true).unwrap();
        assert_eq!(approved(d.path(), 181), Some(Approved::Command));
        assert_eq!(approved(d.path(), 182), None, "one session only");
    }

    #[test]
    fn a_record_for_another_session_or_with_unknown_method_is_not_an_approval() {
        let d = tempfile::tempdir().unwrap();
        fs::create_dir_all(dir(d.path())).unwrap();
        fs::write(
            session_path(d.path(), 181),
            r#"{"session":180,"method":"approve-command"}"#,
        )
        .unwrap();
        assert_eq!(approved(d.path(), 181), None);
        fs::write(
            session_path(d.path(), 181),
            r#"{"session":181,"method":"typed-by-agent"}"#,
        )
        .unwrap();
        assert_eq!(approved(d.path(), 181), None);
    }

    #[test]
    fn allow_all_counts_only_while_its_launch_lives() {
        let d = tempfile::tempdir().unwrap();
        record_allow_all(d.path(), std::process::id()).unwrap();
        assert_eq!(approved(d.path(), 181), Some(Approved::AllowAll));
        clear_allow_all(d.path());
        assert_eq!(approved(d.path(), 181), None);
        record_allow_all(d.path(), 999_999_999).unwrap(); // a dead pid: a crashed launch
        assert_eq!(
            approved(d.path(), 181),
            None,
            "a stale record must not approve forever"
        );
    }

    #[test]
    fn launch_env_record_is_labelled_as_launch_time() {
        let d = tempfile::tempdir().unwrap();
        record_launch_env(d.path(), 181).unwrap();
        assert_eq!(approved(d.path(), 181), Some(Approved::LaunchEnv));
    }
}
