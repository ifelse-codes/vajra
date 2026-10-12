//! S194 (F120) — `vajra next --role <name> --from <file>` refuses a helper's raw transcript.
//!
//! Given a subagent's `.output` file (Claude Code JSON-lines), the command once wrote all of it —
//! the user's email, the helper's whole system prompt — into the handoff. Real binary, temp repo:
//! a transcript is refused with nothing written (file and stdin), an existing handoff is left
//! byte-for-byte, and a markdown brief that quotes a fenced JSON block still records.

use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

fn bin() -> &'static str {
    env!("CARGO_BIN_EXE_vajra")
}

const TRANSCRIPT: &str = r#"{"parentUuid":null,"isSidechain":true,"sessionId":"s1","type":"user","message":{"role":"user","content":"Session 194 ..."}}
{"parentUuid":"a","isSidechain":true,"sessionId":"s1","type":"attachment","attachment":{"type":"session_context","context":{"userEmail":"someone@example.com"}}}
{"parentUuid":"b","isSidechain":true,"sessionId":"s1","type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Tech-lead brief"}]}}
"#;

const BRIEF: &str = "Tech-lead brief: session 194\n\nThe receipt's record, as Claude Code writes it:\n\n```json\n{\"type\":\"cost-state\",\"totalCostUSD\":1.49}\n```\n\nrec 1 — read the close log for WAIVED first.\n";

struct Repo {
    _tmp: tempfile::TempDir,
    dir: PathBuf,
    projects: PathBuf,
}

fn repo() -> Repo {
    let tmp = tempfile::tempdir().unwrap();
    let dir = tmp.path().join("repo");
    let projects = tmp.path().join("projects");
    fs::create_dir_all(dir.join(".ai")).unwrap();
    fs::create_dir_all(&projects).unwrap();
    fs::write(dir.join(".ai/SESSION"), "194\n").unwrap();
    let git = |args: &[&str]| {
        assert!(Command::new("git")
            .args(args)
            .current_dir(&dir)
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .status()
            .unwrap()
            .success());
    };
    git(&["init", "-q", "-b", "session-194-x"]);
    Repo {
        _tmp: tmp,
        dir,
        projects,
    }
}

fn vajra(r: &Repo, args: &[&str], stdin: Option<&str>) -> (bool, String) {
    let mut child = Command::new(bin())
        .args(args)
        .current_dir(&r.dir)
        .env("VAJRA_CLAUDE_PROJECTS_DIR", &r.projects)
        .stdin(if stdin.is_some() {
            Stdio::piped()
        } else {
            Stdio::null()
        })
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .unwrap();
    if let Some(text) = stdin {
        child
            .stdin
            .take()
            .unwrap()
            .write_all(text.as_bytes())
            .unwrap();
    }
    let out = child.wait_with_output().unwrap();
    (
        out.status.success(),
        format!(
            "{}{}",
            String::from_utf8_lossy(&out.stdout),
            String::from_utf8_lossy(&out.stderr)
        ),
    )
}

fn handoff(r: &Repo) -> PathBuf {
    r.dir.join(".ai/handoffs/session-194-tech-lead.md")
}

fn write(dir: &Path, name: &str, text: &str) -> String {
    let p = dir.join(name);
    fs::write(&p, text).unwrap();
    p.to_str().unwrap().to_string()
}

#[test]
fn s194_a_transcript_file_is_refused_and_nothing_is_written() {
    let r = repo();
    let file = write(&r.dir, "agent.output", TRANSCRIPT);
    let (ok, out) = vajra(&r, &["next", "--role", "tech-lead", "--from", &file], None);
    assert!(!ok, "a transcript must be refused: {out}");
    assert!(out.contains("is a transcript, not a findings brief"), "{out}");
    assert!(!handoff(&r).exists(), "nothing may be written");
}

#[test]
fn s194_a_transcript_on_stdin_is_refused_too() {
    let r = repo();
    let (ok, out) = vajra(
        &r,
        &["next", "--role", "tech-lead", "--from", "-"],
        Some(TRANSCRIPT),
    );
    assert!(!ok, "a transcript must be refused: {out}");
    assert!(out.contains("is a transcript, not a findings brief"), "{out}");
    assert!(!handoff(&r).exists(), "nothing may be written");
}

#[test]
fn s194_an_existing_handoff_is_left_byte_for_byte() {
    let r = repo();
    let brief = write(&r.dir, "brief.md", BRIEF);
    let (ok, out) = vajra(&r, &["next", "--role", "tech-lead", "--from", &brief], None);
    assert!(ok, "a markdown brief must record: {out}");
    let before = fs::read(handoff(&r)).unwrap();

    let file = write(&r.dir, "agent.output", TRANSCRIPT);
    let (ok, out) = vajra(&r, &["next", "--role", "tech-lead", "--from", &file], None);
    assert!(!ok, "a transcript must be refused: {out}");
    assert_eq!(fs::read(handoff(&r)).unwrap(), before, "the handoff changed");
}

#[test]
fn s194_a_brief_quoting_a_json_block_still_records() {
    let r = repo();
    let brief = write(&r.dir, "brief.md", BRIEF);
    let (ok, out) = vajra(&r, &["next", "--role", "tech-lead", "--from", &brief], None);
    assert!(ok, "a markdown brief must record: {out}");
    let text = fs::read_to_string(handoff(&r)).unwrap();
    assert!(text.contains("rec 1 — read the close log for WAIVED first."), "{text}");
}
