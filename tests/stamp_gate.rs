//! S181 Part 5 (F84), gate level — a helper's "verified" stamp is bound to the record's text.
//!
//! Real binary, real capture, real gates. A fixture stands in for Claude Code's own transcripts
//! (`VAJRA_CLAUDE_PROJECTS_DIR`), so `vajra next --role` derives a genuinely verified stamp; then
//! the findings are edited by hand and the gates must stop trusting the record. Covers the
//! mandate gate (`--check-design-handoff`) and the fidelity gate (`--check-fidelity-handoff`) —
//! the wiring cold review D found untested at gate level; the obeyed gate shares the same
//! `reverify_handoff` call and is unit-covered in `dispatch`.

use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

fn bin() -> &'static str {
    env!("CARGO_BIN_EXE_vajra")
}

struct Fixture {
    _tmp: tempfile::TempDir,
    repo: PathBuf,
    projects: PathBuf,
}

/// A git repo on `session-181-x` with a minimal brief, plus fake Claude Code transcripts that
/// dispatched `roles` for real (parent tool_use + subagent meta + subagent branch).
fn fixture(roles: &[(&str, &str)]) -> Fixture {
    let tmp = tempfile::tempdir().unwrap();
    let repo = tmp.path().join("repo");
    let projects = tmp.path().join("projects");
    fs::create_dir_all(repo.join(".ai")).unwrap();
    fs::create_dir_all(repo.join("prompts")).unwrap();
    fs::write(repo.join(".ai/SESSION"), "181\n").unwrap();
    fs::write(
        repo.join(".ai/CONSTRAINTS.yaml"),
        "maturity: L2\nsession:\n  session_rules_from: 181\n",
    )
    .unwrap();
    fs::write(
        repo.join("prompts/181-task-x.md"),
        "# S181\n\nsession_type: CODE\n\n## Design\ndesign-significant: yes\n",
    )
    .unwrap();
    for args in [
        vec!["init", "-q"],
        vec!["checkout", "-q", "-b", "session-181-x"],
    ] {
        assert!(Command::new("git")
            .args(&args)
            .current_dir(&repo)
            .status()
            .unwrap()
            .success());
    }
    // Claude Code names the project dir by the repo path with `/` -> `-`.
    let canon = fs::canonicalize(&repo).unwrap();
    let pdir = projects.join(canon.to_string_lossy().replace('/', "-"));
    let uuid = "sess-uuid-1";
    let sub = pdir.join(uuid).join("subagents");
    fs::create_dir_all(&sub).unwrap();
    let mut parent = String::new();
    for (i, (role, id)) in roles.iter().enumerate() {
        fs::write(
            sub.join(format!("agent-x{i}.meta.json")),
            serde_json::json!({"agentType": role, "toolUseId": id}).to_string(),
        )
        .unwrap();
        fs::write(
            sub.join(format!("agent-x{i}.jsonl")),
            format!(
                "{}\n",
                serde_json::json!({"gitBranch": "session-181-x", "type": "user"})
            ),
        )
        .unwrap();
        parent.push_str(&format!(
            "{}\n",
            serde_json::json!({"message": {"content": [{
                "type": "tool_use", "id": id, "name": "Agent",
                "input": {"subagent_type": role}
            }]}})
        ));
    }
    fs::write(pdir.join(format!("{uuid}.jsonl")), parent).unwrap();
    Fixture {
        _tmp: tmp,
        repo,
        projects,
    }
}

fn vajra(f: &Fixture, args: &[&str]) -> (bool, String) {
    let out = Command::new(bin())
        .args(args)
        .current_dir(&f.repo)
        .env("VAJRA_CLAUDE_PROJECTS_DIR", &f.projects)
        .env_remove("VAJRA_AGENT_MARK")
        .stdin(Stdio::null())
        .output()
        .unwrap();
    (
        out.status.success(),
        format!(
            "{}{}",
            String::from_utf8_lossy(&out.stdout),
            String::from_utf8_lossy(&out.stderr)
        ),
    )
}

fn record(f: &Fixture, role: &str, findings: &str) -> PathBuf {
    let file = f.repo.join("findings.txt");
    fs::write(&file, findings).unwrap();
    let (ok, text) = vajra(
        f,
        &["next", "--role", role, "--from", file.to_str().unwrap()],
    );
    assert!(ok, "capture failed: {text}");
    assert!(
        text.contains("verified: toolu_"),
        "not stamped verified: {text}"
    );
    assert!(
        text.contains("text-sha:"),
        "stamp carries no text binding: {text}"
    );
    f.repo.join(format!(".ai/handoffs/session-181-{role}.md"))
}

fn edit_findings(path: &Path) {
    let t = fs::read_to_string(path).unwrap();
    let edited = t.replace("finding one", "finding one, and everything is fine now");
    assert_ne!(t, edited, "the edit must change the record");
    fs::write(path, edited).unwrap();
}

#[test]
fn an_edited_handoff_stops_being_trusted_by_the_fidelity_gate() {
    let f = fixture(&[("fidelity-reviewer", "toolu_01FID")]);
    let path = record(&f, "fidelity-reviewer", "finding one\nfinding two\n");
    let (ok, text) = vajra(&f, &["next", "--check-fidelity-handoff", "181"]);
    assert!(ok, "an untouched record must verify: {text}");
    edit_findings(&path);
    let (ok, text) = vajra(&f, &["next", "--check-fidelity-handoff", "181"]);
    assert!(!ok, "an edited record must NOT verify: {text}");
    assert!(text.contains("changed after it was captured"), "{text}");
}

#[test]
fn an_edited_handoff_stops_being_trusted_by_the_mandate_gate() {
    let f = fixture(&[("design-advisor", "toolu_01DES")]);
    let path = record(&f, "design-advisor", "finding one\nfinding two\n");
    let (ok, text) = vajra(&f, &["next", "--check-design-handoff", "181"]);
    assert!(ok, "an untouched record must verify: {text}");
    edit_findings(&path);
    let (ok, text) = vajra(&f, &["next", "--check-design-handoff", "181"]);
    assert!(!ok, "an edited record must NOT verify: {text}");
    assert!(text.contains("changed after it was captured"), "{text}");
}
