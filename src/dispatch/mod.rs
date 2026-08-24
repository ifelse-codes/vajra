//! Dispatch provenance (S131) — replaces the hardcoded literal `"claude-code-subagent"`
//! (`src/cli/next.rs`, since S109) with PROVABLE provenance for a governed handoff.
//!
//! `DECISION-007`'s S111/S117/S123 addenda each proved a real by-name subagent dispatch the same
//! way: two INDEPENDENTLY-WRITTEN Claude Code files — the parent session's own transcript, and the
//! dispatched subagent's separate `agent-<id>.meta.json` sidecar — agreeing on a random tool-use
//! id neither side controlled. Every prior session did this BY HAND, once, as a committed evidence
//! artifact a cold reviewer could check. This module makes it a GATE: the same cross-check, run
//! live, on every `--role --from` write and re-run independently by the closeout gate that reads
//! the result — never trusting the handoff's own self-declared label (`src/fidelity/mod.rs`).
//!
//! A third fact closes the gap those addenda left open (a stale or borrowed id from an unrelated
//! past session): Claude Code's own subagent transcript records a `gitBranch` on its first line —
//! the branch the dispatching session was actually on. Binding the cross-check to
//! `session-{NN}-*` costs no new heuristic (no clock, no age window) and reuses a field the
//! runtime already writes.
//!
//! Pure core (`cross_check`, the parsers) is unit-tested directly. The impure edges (finding
//! `~/.claude/projects/<repo-slug>`, walking `subagents/*.meta.json`) take an explicit
//! `project_dir` so tests never touch the real machine's Claude Code history or race on a shared
//! env var.

use serde_json::Value;
use std::fs;
use std::path::{Path, PathBuf};
use std::time::SystemTime;

/// One `tool_use` call to the Agent tool, read from a PARENT session transcript: the id nobody but
/// Claude Code assigned, and the `subagent_type` it dispatched under that id.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ParentCall {
    pub tool_use_id: String,
    pub subagent_type: String,
}

/// One subagent's own account of itself: its `agent-<id>.meta.json` sidecar (`agentType`,
/// `toolUseId`) plus the `gitBranch` its own transcript's FIRST line recorded — the session it was
/// dispatched from, in Claude Code's own words, not Vajra's guess.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct SubagentMeta {
    pub agent_type: String,
    pub tool_use_id: String,
    pub git_branch: Option<String>,
}

/// Real, derived provenance for a role's dispatch (S131). `Verified` names the tool-use id the
/// cross-check resolved; `Unverifiable` names WHY — so a hand-typed handoff is never silently
/// equivalent to a real one (Deliverable 3).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Provenance {
    Verified { tool_use_id: String },
    Unverifiable(String),
}

impl Provenance {
    /// The single-line string written into a handoff's `agent:` frontmatter field.
    pub fn label(&self) -> String {
        match self {
            Provenance::Verified { tool_use_id } => {
                format!("claude-code-subagent (verified: {tool_use_id})")
            }
            Provenance::Unverifiable(reason) => {
                format!("claude-code-subagent (unverifiable: {reason})")
            }
        }
    }
}

/// Extract the tool-use id a handoff's `agent:` field CLAIMS, if it follows the `(verified: <id>)`
/// shape `Provenance::label` writes. Anything else — a bare pre-S131 string, a hand-typed forgery
/// with no id at all, a copy-pasted label with the parenthetical mangled — returns `None`, and the
/// caller must refuse outright rather than treat a missing id as "nothing to check" (the gate's
/// own fail-closed posture, applied to parsing the claim itself).
pub fn claimed_tool_use_id(agent_field: &str) -> Option<String> {
    let after = agent_field.split_once("(verified: ")?.1;
    let id = after.split(')').next()?.trim();
    if id.is_empty() {
        None
    } else {
        Some(id.to_string())
    }
}

/// The evidentiary shape S111/S117/S123 hand-assembled for a cold reviewer, made a pure,
/// unit-testable check: does `tool_use_id` name a `role_name` dispatch that BOTH
/// independently-written files agree on, from a session whose recorded git branch is really
/// `session-{session:02}-*`? Three independent facts, none of which a forger can fabricate
/// consistently across two files they do not both control: the parent's own `subagent_type`, the
/// subagent's own `agentType`, and the subagent's own `gitBranch`.
pub fn cross_check(
    role_name: &str,
    session: u32,
    tool_use_id: &str,
    parent_calls: &[ParentCall],
    metas: &[SubagentMeta],
) -> Result<(), String> {
    let parent = parent_calls.iter().find(|c| c.tool_use_id == tool_use_id);
    let meta = metas.iter().find(|m| m.tool_use_id == tool_use_id);
    let (parent, meta) = match (parent, meta) {
        (Some(p), Some(m)) => (p, m),
        (None, Some(_)) => {
            return Err(format!(
                "no parent-transcript tool_use call for {tool_use_id} — a subagent meta.json \
                 exists but nothing dispatched it"
            ))
        }
        (Some(_), None) => {
            return Err(format!(
                "no subagent meta.json for {tool_use_id} — a parent transcript claims the \
                 dispatch but the subagent side is missing"
            ))
        }
        (None, None) => {
            return Err(format!(
                "{tool_use_id} appears in neither a parent transcript nor a subagent meta.json \
                 on this machine"
            ))
        }
    };
    if parent.subagent_type != role_name {
        return Err(format!(
            "parent transcript dispatched {tool_use_id} as subagent_type {:?}, not {role_name:?}",
            parent.subagent_type
        ));
    }
    if meta.agent_type != role_name {
        return Err(format!(
            "subagent meta.json records agentType {:?} for {tool_use_id}, not {role_name:?}",
            meta.agent_type
        ));
    }
    let expected_prefix = format!("session-{session:02}-");
    match &meta.git_branch {
        Some(b) if b.starts_with(&expected_prefix) => Ok(()),
        Some(b) => Err(format!(
            "subagent transcript recorded gitBranch {b:?}, not a {expected_prefix}* branch — \
             this dispatch belongs to a different session"
        )),
        None => Err(
            "subagent transcript records no gitBranch — cannot bind it to this session".to_string(),
        ),
    }
}

// ---------------------------------------------------------------------------
// Impure edges — everything below touches the filesystem. Each `_in` function takes its root
// explicitly so tests point it at a tempdir fixture, never the real machine's history and never a
// shared env var (avoiding both a slow/foreign-data test and a parallel-test race).
// ---------------------------------------------------------------------------

/// `~/.claude/projects`, or `VAJRA_CLAUDE_PROJECTS_DIR` when set — the SAME override
/// `scripts/check-subagent-cost-fields.sh` already uses (S111), not a second env var for the same
/// root.
pub fn claude_projects_root() -> Option<PathBuf> {
    if let Ok(p) = std::env::var("VAJRA_CLAUDE_PROJECTS_DIR") {
        return Some(PathBuf::from(p));
    }
    let home = std::env::var_os("HOME")?;
    Some(PathBuf::from(home).join(".claude/projects"))
}

/// `<projects-root>/<repo-path-slug>` — the exact scheme `vajra meter`'s `default_project_dir`
/// already uses (CC replaces `/` with `-`), so a repo checked out anywhere still resolves.
pub fn project_dir_for(repo_root: &Path) -> Option<PathBuf> {
    let projects = claude_projects_root()?;
    let slug = repo_root.to_string_lossy().replace('/', "-");
    Some(projects.join(slug))
}

/// Parse one `agent-<id>.meta.json`'s `agentType` + `toolUseId`. `None` on anything malformed —
/// scanned candidates simply skip it (fail-closed by omission, not by crash).
fn parse_meta_json(text: &str) -> Option<(String, String)> {
    let v: Value = serde_json::from_str(text).ok()?;
    let agent_type = v.get("agentType")?.as_str()?.to_string();
    let tool_use_id = v.get("toolUseId")?.as_str()?.to_string();
    Some((agent_type, tool_use_id))
}

/// `agent-<id>.meta.json` -> `agent-<id>.jsonl`, its sibling raw transcript, string-based (not
/// `Path::with_extension`, which would only strip `.json` and leave `.meta`).
fn sibling_transcript(meta_path: &Path) -> Option<PathBuf> {
    let name = meta_path.file_name()?.to_str()?;
    let stem = name.strip_suffix(".meta.json")?;
    Some(meta_path.with_file_name(format!("{stem}.jsonl")))
}

/// The `gitBranch` Claude Code recorded on a subagent transcript's FIRST line.
fn read_first_line_git_branch(jsonl_path: &Path) -> Option<String> {
    let text = fs::read_to_string(jsonl_path).ok()?;
    let first = text.lines().next()?;
    let v: Value = serde_json::from_str(first).ok()?;
    v.get("gitBranch")?.as_str().map(|s| s.to_string())
}

/// Every `<session-uuid>/subagents/agent-*.meta.json` under `project_dir` whose `agentType` is
/// `role_name`, newest first (mtime) — paired with the meta path (to locate its parent transcript)
/// and its own `SubagentMeta` (including the cross-referenced `gitBranch`).
fn scan_role_candidates(
    project_dir: &Path,
    role_name: &str,
) -> Vec<(PathBuf, SubagentMeta, SystemTime)> {
    let mut out = Vec::new();
    let Ok(sessions) = fs::read_dir(project_dir) else {
        return out;
    };
    for session_entry in sessions.flatten() {
        let subagents_dir = session_entry.path().join("subagents");
        let Ok(files) = fs::read_dir(&subagents_dir) else {
            continue;
        };
        for f in files.flatten() {
            let path = f.path();
            let Some(name) = path.file_name().and_then(|n| n.to_str()) else {
                continue;
            };
            if !name.ends_with(".meta.json") {
                continue;
            }
            let Ok(text) = fs::read_to_string(&path) else {
                continue;
            };
            let Some((agent_type, tool_use_id)) = parse_meta_json(&text) else {
                continue;
            };
            if agent_type != role_name {
                continue;
            }
            let git_branch = sibling_transcript(&path).and_then(|p| read_first_line_git_branch(&p));
            let mtime = f
                .metadata()
                .and_then(|m| m.modified())
                .unwrap_or(SystemTime::UNIX_EPOCH);
            out.push((
                path,
                SubagentMeta {
                    agent_type,
                    tool_use_id,
                    git_branch,
                },
                mtime,
            ));
        }
    }
    out.sort_by_key(|b| std::cmp::Reverse(b.2));
    out
}

/// Parse the `tool_use` Agent-dispatch calls out of a parent transcript's raw JSONL text. Matches
/// on `input.subagent_type` being present (the meaningful, forger-independent field) rather than
/// the tool name — every real dispatch in this repo's evidence trail has been named `"Agent"`, but
/// the field is what the cross-check actually rests on.
pub fn parse_parent_calls(text: &str) -> Vec<ParentCall> {
    let mut out = Vec::new();
    for line in text.lines() {
        let Ok(v) = serde_json::from_str::<Value>(line) else {
            continue;
        };
        let Some(content) = v.pointer("/message/content").and_then(|c| c.as_array()) else {
            continue;
        };
        for block in content {
            if block.get("type").and_then(|t| t.as_str()) != Some("tool_use") {
                continue;
            }
            let Some(id) = block.get("id").and_then(|i| i.as_str()) else {
                continue;
            };
            let Some(subagent_type) = block
                .pointer("/input/subagent_type")
                .and_then(|s| s.as_str())
            else {
                continue;
            };
            out.push(ParentCall {
                tool_use_id: id.to_string(),
                subagent_type: subagent_type.to_string(),
            });
        }
    }
    out
}

/// The parent transcript path for a subagent's containing `<session-uuid>/` directory name — the
/// sibling `<session-uuid>.jsonl` one level up, the same layout `vajra meter`'s `run_single`
/// already derives (in the opposite direction).
fn parent_transcript_for(project_dir: &Path, session_dir_name: &str) -> PathBuf {
    project_dir.join(format!("{session_dir_name}.jsonl"))
}

/// Newest-first: find a verified dispatch of `role_name` for `session` under `project_dir`, or say
/// why none qualifies. The testable core of `derive_provenance` — no env var, no `$HOME`.
pub fn derive_provenance_in(project_dir: &Path, role_name: &str, session: u32) -> Provenance {
    let candidates = scan_role_candidates(project_dir, role_name);
    if candidates.is_empty() {
        return Provenance::Unverifiable(format!(
            "no {role_name} subagent dispatch found on this machine"
        ));
    }
    let mut last_err = String::new();
    for (meta_path, meta, _mtime) in &candidates {
        let Some(session_dir_name) = meta_path
            .parent()
            .and_then(|p| p.parent())
            .and_then(|p| p.file_name())
            .and_then(|n| n.to_str())
        else {
            last_err = format!("malformed subagent path {}", meta_path.display());
            continue;
        };
        let parent_transcript = parent_transcript_for(project_dir, session_dir_name);
        let Ok(parent_text) = fs::read_to_string(&parent_transcript) else {
            last_err = format!(
                "parent transcript {} unreadable",
                parent_transcript.display()
            );
            continue;
        };
        let parent_calls = parse_parent_calls(&parent_text);
        match cross_check(
            role_name,
            session,
            &meta.tool_use_id,
            &parent_calls,
            std::slice::from_ref(meta),
        ) {
            Ok(()) => {
                return Provenance::Verified {
                    tool_use_id: meta.tool_use_id.clone(),
                }
            }
            Err(e) => last_err = e,
        }
    }
    Provenance::Unverifiable(last_err)
}

/// `derive_provenance_in`, resolving `project_dir` from the real machine (`$HOME` /
/// `VAJRA_CLAUDE_PROJECTS_DIR`) — the impure entry point `vajra next --role --from` calls.
pub fn derive_provenance(repo_root: &Path, role_name: &str, session: u32) -> Provenance {
    match project_dir_for(repo_root) {
        Some(dir) if dir.exists() => derive_provenance_in(&dir, role_name, session),
        Some(dir) => Provenance::Unverifiable(format!(
            "no Claude Code project history at {}",
            dir.display()
        )),
        None => Provenance::Unverifiable(
            "could not resolve this machine's Claude Code project directory (no $HOME)".into(),
        ),
    }
}

/// The GATE's re-check (S131): independently re-derive whether `tool_use_id` really cross-checks
/// for `role_name`/`session` under `project_dir` — NEVER trust a handoff's own `agent:` label,
/// which a hand-typed forgery can paste freely. The testable core of `reverify`.
pub fn reverify_in(
    project_dir: &Path,
    role_name: &str,
    session: u32,
    tool_use_id: &str,
) -> Result<(), String> {
    let candidates = scan_role_candidates(project_dir, role_name);
    let Some((meta_path, meta, _)) = candidates
        .iter()
        .find(|(_, m, _)| m.tool_use_id == tool_use_id)
    else {
        return Err(format!(
            "no {role_name} subagent meta.json on this machine records tool-use id {tool_use_id}"
        ));
    };
    let session_dir_name = meta_path
        .parent()
        .and_then(|p| p.parent())
        .and_then(|p| p.file_name())
        .and_then(|n| n.to_str())
        .ok_or_else(|| format!("malformed subagent path {}", meta_path.display()))?;
    let parent_transcript = parent_transcript_for(project_dir, session_dir_name);
    let parent_text = fs::read_to_string(&parent_transcript).map_err(|e| {
        format!(
            "parent transcript {} unreadable: {e}",
            parent_transcript.display()
        )
    })?;
    let parent_calls = parse_parent_calls(&parent_text);
    cross_check(
        role_name,
        session,
        tool_use_id,
        &parent_calls,
        std::slice::from_ref(meta),
    )
}

/// `reverify_in`, resolving `project_dir` from the real machine — the impure entry point the
/// fidelity gate (`src/fidelity/mod.rs`) calls.
pub fn reverify(
    repo_root: &Path,
    role_name: &str,
    session: u32,
    tool_use_id: &str,
) -> Result<(), String> {
    let project_dir = project_dir_for(repo_root).ok_or_else(|| {
        "could not resolve this machine's Claude Code project directory (no $HOME)".to_string()
    })?;
    reverify_in(&project_dir, role_name, session, tool_use_id)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn call(id: &str, ty: &str) -> ParentCall {
        ParentCall {
            tool_use_id: id.into(),
            subagent_type: ty.into(),
        }
    }
    fn meta(id: &str, ty: &str, branch: Option<&str>) -> SubagentMeta {
        SubagentMeta {
            agent_type: ty.into(),
            tool_use_id: id.into(),
            git_branch: branch.map(|s| s.to_string()),
        }
    }

    // ---- cross_check: the pure core, all four failure modes plus the pass ----

    #[test]
    fn cross_check_passes_when_all_three_facts_agree() {
        let calls = [call("t1", "fidelity-reviewer")];
        let metas = [meta(
            "t1",
            "fidelity-reviewer",
            Some("session-131-fleet-mandatory-gate"),
        )];
        assert_eq!(
            cross_check("fidelity-reviewer", 131, "t1", &calls, &metas),
            Ok(())
        );
    }

    #[test]
    // These three assert BEHAVIOR only (Err, not a specific string) — deliberately, so the
    // falsifiability fixture's "renaming every message must stay GREEN" direction (S122/S127) has
    // real teeth: a test bound to exact wording would go red on a harmless rename and mask a
    // genuine bypass. `cross_check_reports_three_distinct_reasons` below still proves the three
    // branches are not collapsed into one message, without pinning what any of them says.
    fn cross_check_fails_when_no_parent_call_matches() {
        let metas = [meta("t1", "fidelity-reviewer", Some("session-131-x"))];
        assert!(cross_check("fidelity-reviewer", 131, "t1", &[], &metas).is_err());
    }

    #[test]
    fn cross_check_fails_when_no_meta_matches() {
        let calls = [call("t1", "fidelity-reviewer")];
        assert!(cross_check("fidelity-reviewer", 131, "t1", &calls, &[]).is_err());
    }

    #[test]
    fn cross_check_fails_when_neither_side_has_the_id() {
        assert!(cross_check("fidelity-reviewer", 131, "t1", &[], &[]).is_err());
    }

    #[test]
    fn cross_check_reports_three_distinct_reasons_for_the_three_missing_evidence_shapes() {
        let metas = [meta("t1", "fidelity-reviewer", Some("session-131-x"))];
        let calls = [call("t1", "fidelity-reviewer")];
        let only_meta = cross_check("fidelity-reviewer", 131, "t1", &[], &metas).unwrap_err();
        let only_parent = cross_check("fidelity-reviewer", 131, "t1", &calls, &[]).unwrap_err();
        let neither = cross_check("fidelity-reviewer", 131, "t1", &[], &[]).unwrap_err();
        assert_ne!(only_meta, only_parent);
        assert_ne!(only_meta, neither);
        assert_ne!(only_parent, neither);
    }

    #[test]
    fn cross_check_fails_when_parent_dispatched_a_different_role() {
        let calls = [call("t1", "researcher")];
        let metas = [meta("t1", "fidelity-reviewer", Some("session-131-x"))];
        let err = cross_check("fidelity-reviewer", 131, "t1", &calls, &metas).unwrap_err();
        assert!(
            err.contains("subagent_type") && err.contains("researcher"),
            "{err}"
        );
    }

    #[test]
    fn cross_check_fails_when_meta_agent_type_mismatches() {
        let calls = [call("t1", "fidelity-reviewer")];
        let metas = [meta("t1", "researcher", Some("session-131-x"))];
        let err = cross_check("fidelity-reviewer", 131, "t1", &calls, &metas).unwrap_err();
        assert!(
            err.contains("agentType") && err.contains("researcher"),
            "{err}"
        );
    }

    #[test]
    fn cross_check_fails_when_git_branch_is_a_different_session() {
        let calls = [call("t1", "fidelity-reviewer")];
        let metas = [meta(
            "t1",
            "fidelity-reviewer",
            Some("session-93-prove-commit-gate-teeth"),
        )];
        let err = cross_check("fidelity-reviewer", 131, "t1", &calls, &metas).unwrap_err();
        assert!(err.contains("different session"), "{err}");
    }

    #[test]
    fn cross_check_fails_when_git_branch_is_absent() {
        let calls = [call("t1", "fidelity-reviewer")];
        let metas = [meta("t1", "fidelity-reviewer", None)];
        let err = cross_check("fidelity-reviewer", 131, "t1", &calls, &metas).unwrap_err();
        assert!(err.contains("no gitBranch"), "{err}");
    }

    // ---- claimed_tool_use_id ----

    #[test]
    fn claimed_id_round_trips_through_the_label() {
        let p = Provenance::Verified {
            tool_use_id: "toolu_01ABC".into(),
        };
        assert_eq!(
            claimed_tool_use_id(&p.label()),
            Some("toolu_01ABC".to_string())
        );
    }

    #[test]
    fn claimed_id_is_none_for_the_pre_s131_bare_string() {
        assert_eq!(claimed_tool_use_id("claude-code-subagent"), None);
    }

    #[test]
    fn claimed_id_is_none_for_an_unverifiable_label() {
        let p = Provenance::Unverifiable("no dispatch found".into());
        assert_eq!(claimed_tool_use_id(&p.label()), None);
    }

    #[test]
    fn claimed_id_is_none_for_an_empty_parenthetical() {
        assert_eq!(
            claimed_tool_use_id("claude-code-subagent (verified: )"),
            None
        );
    }

    // ---- parse_parent_calls ----

    #[test]
    fn parse_parent_calls_reads_a_real_shaped_line() {
        let line = r#"{"message":{"content":[{"type":"tool_use","id":"toolu_01X","name":"Agent","input":{"subagent_type":"fidelity-reviewer","description":"d"}}]}}"#;
        let calls = parse_parent_calls(line);
        assert_eq!(calls, vec![call("toolu_01X", "fidelity-reviewer")]);
    }

    #[test]
    fn parse_parent_calls_skips_non_tool_use_and_malformed_lines() {
        let text = "not json\n{\"message\":{\"content\":[{\"type\":\"text\",\"text\":\"hi\"}]}}\n";
        assert!(parse_parent_calls(text).is_empty());
    }

    // ---- the fs-backed edges, against a tempdir fixture (never the real machine's history) ----

    fn write_fixture(
        project_dir: &Path,
        session_uuid: &str,
        tool_use_id: &str,
        agent_type: &str,
        git_branch: &str,
        subagent_type_in_parent: &str,
    ) {
        let sub_dir = project_dir.join(session_uuid).join("subagents");
        fs::create_dir_all(&sub_dir).unwrap();
        fs::write(
            sub_dir.join("agent-x1.meta.json"),
            serde_json::json!({"agentType": agent_type, "toolUseId": tool_use_id}).to_string(),
        )
        .unwrap();
        fs::write(
            sub_dir.join("agent-x1.jsonl"),
            format!(
                "{}\n",
                serde_json::json!({"gitBranch": git_branch, "type": "user"})
            ),
        )
        .unwrap();
        fs::write(
            project_dir.join(format!("{session_uuid}.jsonl")),
            format!(
                "{}\n",
                serde_json::json!({"message": {"content": [{
                    "type": "tool_use", "id": tool_use_id, "name": "Agent",
                    "input": {"subagent_type": subagent_type_in_parent}
                }]}})
            ),
        )
        .unwrap();
    }

    #[test]
    fn derive_provenance_in_verifies_a_real_looking_dispatch() {
        let tmp = tempdir_for_test();
        write_fixture(
            &tmp,
            "sess-uuid-1",
            "toolu_01REAL",
            "fidelity-reviewer",
            "session-131-fleet-mandatory-gate",
            "fidelity-reviewer",
        );
        let p = derive_provenance_in(&tmp, "fidelity-reviewer", 131);
        assert_eq!(
            p,
            Provenance::Verified {
                tool_use_id: "toolu_01REAL".into()
            }
        );
    }

    #[test]
    fn derive_provenance_in_is_unverifiable_with_no_candidates() {
        let tmp = tempdir_for_test();
        let p = derive_provenance_in(&tmp, "fidelity-reviewer", 131);
        matches!(p, Provenance::Unverifiable(_))
            .then_some(())
            .expect("expected Unverifiable");
    }

    #[test]
    fn derive_provenance_in_is_unverifiable_for_a_wrong_session_branch() {
        let tmp = tempdir_for_test();
        write_fixture(
            &tmp,
            "sess-uuid-2",
            "toolu_01OLD",
            "fidelity-reviewer",
            "session-93-prove-commit-gate-teeth",
            "fidelity-reviewer",
        );
        let p = derive_provenance_in(&tmp, "fidelity-reviewer", 131);
        match p {
            Provenance::Unverifiable(reason) => {
                assert!(reason.contains("different session"), "{reason}")
            }
            other => panic!("expected Unverifiable, got {other:?}"),
        }
    }

    #[test]
    fn reverify_in_confirms_a_real_dispatch_and_rejects_a_fabricated_id() {
        let tmp = tempdir_for_test();
        write_fixture(
            &tmp,
            "sess-uuid-3",
            "toolu_01REAL2",
            "fidelity-reviewer",
            "session-131-fleet-mandatory-gate",
            "fidelity-reviewer",
        );
        assert_eq!(
            reverify_in(&tmp, "fidelity-reviewer", 131, "toolu_01REAL2"),
            Ok(())
        );
        let err = reverify_in(&tmp, "fidelity-reviewer", 131, "toolu_FABRICATED").unwrap_err();
        assert!(
            err.contains("no fidelity-reviewer subagent meta.json"),
            "{err}"
        );
    }

    /// A fresh, uniquely-named tempdir under the OS temp root — plain `std::env::temp_dir` plus a
    /// process-unique suffix, so parallel `cargo test` threads never collide (no shared env var,
    /// no shared path).
    fn tempdir_for_test() -> PathBuf {
        let dir = std::env::temp_dir().join(format!(
            "vajra-dispatch-test-{}-{}",
            std::process::id(),
            uniq()
        ));
        fs::create_dir_all(&dir).unwrap();
        dir
    }

    fn uniq() -> u64 {
        use std::sync::atomic::{AtomicU64, Ordering};
        static N: AtomicU64 = AtomicU64::new(0);
        N.fetch_add(1, Ordering::Relaxed)
    }
}
