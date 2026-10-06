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
//! its Write tools from `.ai/approvals/` and (S188) catch a change any tool call made there AFTER it
//! runs — the approval stops counting until the founder writes it again (the void, below). The record
//! is a file in git, so the trail is reviewable — but a determined agent with a shell is not stopped by
//! this alone.

use anyhow::{bail, Context, Result};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

/// Env var `vajra claude` sets on the process it spawns (and so on everything the agent starts).
pub const AGENT_MARK: &str = "VAJRA_AGENT_MARK";
/// Vajra's own boundary: sessions below this keep the old readings (approval from the brief's words,
/// stamps without a text hash) through named, dated fallbacks (2026-09-30, S181). A project sets its
/// own with `session_rules_from: N` in `.ai/CONSTRAINTS.yaml` — one that adopted Vajra long before
/// 181 would otherwise never leave the fallback. New scaffolds ship `session_rules_from: 1`.
pub const DEFAULT_RULES_FROM: u32 = 181;

/// The first session that must follow the new rules, and whether the project declared it.
pub fn rules_from(root: &Path) -> (u32, bool) {
    let text = fs::read_to_string(root.join(".ai/CONSTRAINTS.yaml")).unwrap_or_default();
    for line in text.lines() {
        if let Some(rest) = line.trim_start().strip_prefix("session_rules_from:") {
            if let Ok(n) = rest.split('#').next().unwrap_or("").trim().parse::<u32>() {
                return (n, true);
            }
        }
    }
    (DEFAULT_RULES_FROM, false)
}

/// The note every legacy fallback ends with when the project never set the key.
pub fn rules_from_hint(declared: bool) -> &'static str {
    if declared {
        ""
    } else {
        " This project has no `session_rules_from:` in .ai/CONSTRAINTS.yaml, so every session reads \
         the OLD way — add `session_rules_from: N` (N = the first session that must follow the new rules)."
    }
}

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

/// S188 (DECISION-011 S188 addendum): the void. When an AI tool call changes `.ai/approvals`, the
/// before/after check (`scripts/hook-approvals-guard.sh`) lists every record name present after the
/// change in this file. A listed record does not count until the founder's own process writes it again.
/// It lives INSIDE the folder, so removing or editing it is itself a change the next check re-lists.
pub const VOID_FILE: &str = "voided.json";

fn void_path(root: &Path) -> PathBuf {
    dir(root).join(VOID_FILE)
}

/// What the void marker says. Names are lower-cased: macOS's default disk is case-insensitive, so a
/// forged `SESSION-189.json` is read as `session-189.json` (design-advisor rec 7).
enum Void {
    Absent,
    Listed(Vec<String>),
    /// Present but not a `{"listed": [names]}` object: every approval reads as missing (fail closed).
    Unreadable,
}

fn read_void(root: &Path) -> Void {
    let text = match fs::read_to_string(void_path(root)) {
        Ok(t) => t,
        Err(e) if e.kind() == std::io::ErrorKind::NotFound => return Void::Absent,
        Err(_) => return Void::Unreadable,
    };
    let names = serde_json::from_str::<serde_json::Value>(&text)
        .ok()
        .and_then(|v| v.get("listed").and_then(|l| l.as_array()).cloned())
        .and_then(|a| {
            a.iter()
                .map(|n| n.as_str().map(str::to_lowercase))
                .collect::<Option<Vec<_>>>()
        });
    names.map_or(Void::Unreadable, Void::Listed)
}

/// Is the record named `name` voided (listed, or the marker cannot be read)?
fn is_void(root: &Path, name: &str) -> bool {
    match read_void(root) {
        Void::Absent => false,
        Void::Listed(names) => names.contains(&name.to_lowercase()),
        Void::Unreadable => true,
    }
}

fn file_name(p: &Path) -> String {
    p.file_name()
        .map(|n| n.to_string_lossy().into_owned())
        .unwrap_or_default()
}

/// The founder's own process un-lists the records it just wrote (`unlist` says which names). An
/// unreadable marker is rebuilt from the records present, minus those — never just deleted, which
/// would make every forged record count again (design-advisor rec 8); an empty list removes it.
fn unlist(root: &Path, drop: impl Fn(&str) -> bool) -> Result<()> {
    let p = void_path(root);
    let mut v = match read_void(root) {
        Void::Absent => return Ok(()),
        Void::Listed(_) => serde_json::from_str::<serde_json::Value>(&fs::read_to_string(&p)?)?,
        Void::Unreadable => {
            let mut present: Vec<String> = fs::read_dir(dir(root))
                .map(|rd| {
                    rd.flatten()
                        .map(|e| e.file_name().to_string_lossy().to_lowercase())
                        .collect()
                })
                .unwrap_or_default();
            present.retain(|n| n != VOID_FILE);
            present.sort();
            if p.is_dir() {
                fs::remove_dir_all(&p)?;
            }
            serde_json::json!({ "listed": present,
                "note": "rebuilt by Vajra from the records present: the marker could not be read" })
        }
    };
    let keep: Vec<serde_json::Value> = v["listed"]
        .as_array()
        .cloned()
        .unwrap_or_default()
        .into_iter()
        .filter(|n| n.as_str().is_some_and(|n| !drop(&n.to_lowercase())))
        .collect();
    if keep.is_empty() {
        match fs::remove_file(&p) {
            Err(e) if e.kind() != std::io::ErrorKind::NotFound => {
                return Err(e).with_context(|| format!("cannot remove {}", p.display()))
            }
            _ => {}
        }
    } else {
        v["listed"] = serde_json::Value::Array(keep);
        fs::write(&p, serde_json::to_string_pretty(&v)? + "\n")
            .with_context(|| format!("cannot write {}", p.display()))?;
    }
    Ok(())
}

/// `session-NN.json` → NN (any zero padding).
fn session_of(name: &str) -> Option<u32> {
    name.strip_prefix("session-")?
        .strip_suffix(".json")?
        .parse()
        .ok()
}

/// Why session `n` has no approval although a record is there: the void lists it. `None` when the
/// session is approved, or when there is simply no record (design-advisor rec 10: the founder sees the
/// file with `ls` and must not be told it is "missing").
pub fn void_note(root: &Path, n: u32) -> Option<String> {
    if approved(root, n).is_some() {
        return None;
    }
    let rec = session_path(root, n);
    let all = allow_all_path(root);
    let voided = (rec.exists() && is_void(root, &file_name(&rec)))
        || (all.exists() && is_void(root, &file_name(&all)));
    voided.then(|| {
        format!(
            "session {n}'s approval does not count — an AI command changed .ai/approvals (listed in \
             .ai/approvals/{VOID_FILE}); the founder runs `vajra approve {n}` again"
        )
    })
}

/// Is session `n` approved by a record? `None` = no record; the brief's words never count. S188: a
/// record the void lists does not count.
pub fn approved(root: &Path, n: u32) -> Option<Approved> {
    let rec = session_path(root, n);
    if is_void(root, &file_name(&rec)) {
        // listed by the before/after check: falls through to the allow-all record, itself checked
    } else if let Ok(text) = fs::read_to_string(&rec) {
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
    if allow_all_live(root, n) {
        return Some(Approved::AllowAll);
    }
    None
}

/// The allow-all record counts only for the session it names (S182), and only while the launch that
/// wrote it is still running. A record with no `session` (written before S182) approves nothing.
fn allow_all_live(root: &Path, n: u32) -> bool {
    if is_void(root, &file_name(&allow_all_path(root))) {
        return false;
    }
    let Ok(text) = fs::read_to_string(allow_all_path(root)) else {
        return false;
    };
    let Ok(v) = serde_json::from_str::<serde_json::Value>(&text) else {
        return false;
    };
    if v.get("session").and_then(|s| s.as_u64()) != Some(n as u64) {
        return false;
    }
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
    // S188: the founder's yes for NN also closes every earlier session's listing (approving the next
    // session clears the current one at closeout); a record forged for a LATER session stays listed.
    unlist(root, |name| session_of(name).is_some_and(|m| m <= n))?;
    Ok(format!(
        "approved session {n} — recorded in {} (human, own terminal). Commit it with the session.",
        p.strip_prefix(root).unwrap_or(&p).display()
    ))
}

/// Launch-time records, written by the launcher from the founder's own env/flags. Called only when
/// the launcher itself is unmarked — a marked launcher (an agent running `vajra claude`) gets nothing.
pub fn record_launch_env(root: &Path, n: u32) -> Result<PathBuf> {
    let p = write_record(root, n, "launch-env")?;
    let name = file_name(&p).to_lowercase();
    unlist(root, |listed| listed == name)?;
    Ok(p)
}

pub fn record_allow_all(root: &Path, n: u32, pid: u32) -> Result<PathBuf> {
    fs::create_dir_all(dir(root))?;
    let p = allow_all_path(root);
    let body = serde_json::json!({ "method": "allow-all", "session": n, "pid": pid, "at_unix": now(),
        "note": "human chose at start; this session only, live only while this launch runs" });
    fs::write(&p, serde_json::to_string_pretty(&body)? + "\n")?;
    let name = file_name(&p).to_lowercase();
    unlist(root, |listed| listed == name)?;
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
        record_allow_all(d.path(), 181, std::process::id()).unwrap();
        assert_eq!(approved(d.path(), 181), Some(Approved::AllowAll));
        clear_allow_all(d.path());
        assert_eq!(approved(d.path(), 181), None);
        record_allow_all(d.path(), 181, 999_999_999).unwrap(); // a dead pid: a crashed launch
        assert_eq!(
            approved(d.path(), 181),
            None,
            "a stale record must not approve forever"
        );
    }

    /// S182 Part 5: a live `--allow-all=A` approves session A and nothing else; a pre-S182 record
    /// that names no session approves nothing.
    #[test]
    fn allow_all_approves_only_the_session_it_names() {
        let d = tempfile::tempdir().unwrap();
        record_allow_all(d.path(), 181, std::process::id()).unwrap();
        assert_eq!(approved(d.path(), 181), Some(Approved::AllowAll));
        assert_eq!(
            approved(d.path(), 182),
            None,
            "session B must not ride A's yes"
        );
        let legacy = serde_json::json!({"method": "allow-all", "pid": std::process::id()});
        fs::write(allow_all_path(d.path()), legacy.to_string()).unwrap();
        assert_eq!(approved(d.path(), 181), None, "a record naming no session");
    }

    fn void(root: &Path, names: &[&str]) {
        fs::create_dir_all(dir(root)).unwrap();
        let v = serde_json::json!({ "listed": names });
        fs::write(void_path(root), v.to_string()).unwrap();
    }

    /// S188 AC2: a record the before/after check listed does not count, whatever its case, and the
    /// readers are told why (the file is still there).
    #[test]
    fn a_listed_record_does_not_count_and_says_why() {
        let d = tempfile::tempdir().unwrap();
        approve(d.path(), 188, false, true).unwrap();
        assert_eq!(
            void_note(d.path(), 188),
            None,
            "approved: nothing to explain"
        );
        void(d.path(), &["SESSION-188.JSON"]);
        assert_eq!(approved(d.path(), 188), None);
        let why = void_note(d.path(), 188).expect("a voided record says why");
        assert!(
            why.contains("vajra approve 188") && why.contains(VOID_FILE),
            "{why}"
        );
        assert_eq!(void_note(d.path(), 7), None, "no record at all: not a void");
    }

    /// S188 AC3: the founder's `vajra approve NN` makes NN count again and un-lists every earlier
    /// session; a record forged for a LATER session stays listed (option B, not A).
    #[test]
    fn approve_unlists_its_own_and_earlier_sessions_only() {
        let d = tempfile::tempdir().unwrap();
        approve(d.path(), 187, false, true).unwrap();
        fs::write(
            session_path(d.path(), 189),
            r#"{"session":189,"method":"approve-command"}"#,
        )
        .unwrap();
        void(
            d.path(),
            &["session-187.json", "session-188.json", "session-189.json"],
        );
        approve(d.path(), 188, false, true).unwrap();
        assert_eq!(approved(d.path(), 188), Some(Approved::Command));
        assert_eq!(approved(d.path(), 187), Some(Approved::Command));
        assert_eq!(
            approved(d.path(), 189),
            None,
            "the forged later record stays void"
        );
        approve(d.path(), 189, false, true).unwrap();
        assert_eq!(approved(d.path(), 189), Some(Approved::Command));
        assert!(
            !void_path(d.path()).exists(),
            "an empty list removes the marker"
        );
    }

    /// Design-advisor rec 8: an unreadable marker voids everything; approve rebuilds it from what is
    /// present (never just deletes it), so a forged record stays void.
    #[test]
    fn an_unreadable_marker_voids_all_and_approve_rebuilds_it() {
        let d = tempfile::tempdir().unwrap();
        approve(d.path(), 188, false, true).unwrap();
        fs::write(
            session_path(d.path(), 189),
            r#"{"session":189,"method":"approve-command"}"#,
        )
        .unwrap();
        fs::write(void_path(d.path()), "not json").unwrap();
        assert_eq!(approved(d.path(), 188), None);
        assert_eq!(approved(d.path(), 189), None);
        approve(d.path(), 188, false, true).unwrap();
        assert_eq!(approved(d.path(), 188), Some(Approved::Command));
        assert_eq!(approved(d.path(), 189), None, "rebuilt, not deleted");
        // a directory where the marker should be is unreadable too, and is rebuilt as a file
        fs::remove_file(void_path(d.path())).unwrap();
        fs::create_dir(void_path(d.path())).unwrap();
        assert_eq!(approved(d.path(), 188), None);
        approve(d.path(), 188, false, true).unwrap();
        assert_eq!(approved(d.path(), 188), Some(Approved::Command));
        assert_eq!(approved(d.path(), 189), None);
    }

    /// The allow-all branch and the launch-time record are voided the same way, and their own
    /// writers un-list only what they wrote.
    #[test]
    fn launch_time_records_are_voided_and_unlisted_by_their_writers() {
        let d = tempfile::tempdir().unwrap();
        record_allow_all(d.path(), 188, std::process::id()).unwrap();
        record_launch_env(d.path(), 187).unwrap();
        void(
            d.path(),
            &["allow-all.launch", "session-187.json", "session-186.json"],
        );
        assert_eq!(approved(d.path(), 188), None, "allow-all listed");
        assert!(void_note(d.path(), 188).is_some());
        assert_eq!(approved(d.path(), 187), None);
        record_allow_all(d.path(), 188, std::process::id()).unwrap();
        assert_eq!(approved(d.path(), 188), Some(Approved::AllowAll));
        record_launch_env(d.path(), 187).unwrap();
        assert_eq!(approved(d.path(), 187), Some(Approved::LaunchEnv));
        let left = fs::read_to_string(void_path(d.path())).unwrap();
        assert!(
            left.contains("session-186.json"),
            "only what was written is un-listed: {left}"
        );
    }

    #[test]
    fn launch_env_record_is_labelled_as_launch_time() {
        let d = tempfile::tempdir().unwrap();
        record_launch_env(d.path(), 181).unwrap();
        assert_eq!(approved(d.path(), 181), Some(Approved::LaunchEnv));
    }
}
