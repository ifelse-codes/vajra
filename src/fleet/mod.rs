//! S109 — fleet slice 1: dispatch ONE named agent role (the Researcher) as a governed step that
//! produces a delta-tracked handoff artifact. Locked by `docs/decisions/DECISION-007-agent-fleet.md`.
//!
//! This module is the PURE core — role resolution (ONE canonical source, no drift per S104/S99),
//! the role-scoped prompt, parsing an agent's captured result, and formatting + validating the
//! governed handoff. The process spawn (the impure part) and the stub-vs-live agent choice
//! (`VAJRA_AGENT_CMD`) live in `cli::launch`. Everything here is unit-testable without spawning.

use std::io::Write;
use std::process::{Command, Stdio};

/// A named fleet role: its dispatch key, the system prompt that scopes an agent to this role, and
/// (via `handoff_rel`) where its governed handoff lands. The ONE place role text lives — the S104
/// team-voice / S99 kickoff no-drift rule applied to real agent invocations.
pub struct Role {
    /// The `--role <name>` key. Lower-case, stable — the join key everywhere.
    pub name: &'static str,
    /// Injected via Claude Code's `--append-system-prompt`: scopes the agent to this role.
    pub system_prompt: &'static str,
}

impl Role {
    /// Where this role's governed handoff for `session` lands, repo-relative. `.ai/` IS the memory
    /// (DECISION-007 / `feedback-map-concepts-to-vajra`) — no new store, no 8th artifact type.
    pub fn handoff_rel(&self, session: u32) -> String {
        format!(".ai/handoffs/session-{session:02}-{}.md", self.name)
    }
}

const RESEARCHER_SYSTEM_PROMPT: &str = "You are the Researcher on a governed software team. \
Your ONE job is to investigate the question you are given and return a concise, decision-ready \
findings brief.\n\
Rules:\n\
- Do NOT write, edit, or run code. You investigate and report only.\n\
- Lead with the answer, then the few facts that support it.\n\
- Prefer specifics (names, numbers, versions, trade-offs) over generalities.\n\
- If the question is ambiguous or you are unsure, say so plainly — never invent facts or sources.\n\
- Keep it short: a busy engineer should be able to act on it in under a minute.";

/// The registered roles. Slice 1 (DECISION-007) ships exactly ONE — the Researcher. Adding a
/// second role is a separate decision, not a reflex (the named key risk of S109 is scope creep).
pub const ROLES: &[Role] = &[Role {
    name: "researcher",
    system_prompt: RESEARCHER_SYSTEM_PROMPT,
}];

/// Resolve a role by its `--role` key. `None` (→ the caller fails closed) for an unknown role:
/// vajra never dispatches a role it cannot scope.
pub fn resolve_role(name: &str) -> Option<&'static Role> {
    ROLES.iter().find(|r| r.name == name)
}

/// The known role names, comma-joined — for a fail-closed "unknown role" error message.
pub fn known_roles() -> String {
    ROLES.iter().map(|r| r.name).collect::<Vec<_>>().join(", ")
}

/// The exact role-scoped input a dispatch hands the agent: the role's system prompt joined to the
/// task with a NUL separator. Its sha256 is the handoff's `source-sha`, so a handoff is traceable
/// to precisely what was asked (role + question), not just the question.
pub fn role_scoped_input(role: &Role, task: &str) -> String {
    format!("{}\0{}", role.system_prompt, task)
}

/// What a dispatched agent returned, parsed from its captured stdout.
#[derive(Debug, Clone, PartialEq)]
pub struct AgentResult {
    /// The findings body — the `result` text field of the terminal `type:"result"` object.
    pub body: String,
    /// The SDK-authoritative `total_cost_usd`, when the result carried one (S78 path).
    pub cost: Option<f64>,
}

/// Parse a headless agent's captured stdout (`--output-format json` / stream-json). The body is the
/// `result` text of the terminal `type:"result"` object; the cost is reused from
/// `meter::extract_result_cost` (the S78 path — no drift on the cost figure). `None` when there is
/// no well-formed result object OR the body is empty (→ the caller fails closed: an unparseable or
/// empty dispatch is a FAILED step, never a silent empty handoff).
pub fn parse_agent_result(stdout: &[u8]) -> Option<AgentResult> {
    let body = extract_result_body(stdout)?;
    if body.trim().is_empty() {
        return None;
    }
    let cost = crate::meter::extract_result_cost(stdout);
    Some(AgentResult {
        body: body.trim().to_string(),
        cost,
    })
}

/// The `result` text of the LAST terminal `type:"result"` object (stream-json: last line wins;
/// else the whole buffer as one JSON object). Mirrors `meter::extract_result_cost`'s scan so the
/// body and the cost are read from the SAME object.
fn extract_result_body(stdout: &[u8]) -> Option<String> {
    let text = std::str::from_utf8(stdout).ok()?;
    let mut found: Option<String> = None;
    for line in text.lines() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }
        if let Ok(v) = serde_json::from_str::<serde_json::Value>(line) {
            if v["type"].as_str() == Some("result") {
                if let Some(r) = v["result"].as_str() {
                    found = Some(r.to_string());
                }
            }
        }
    }
    if found.is_some() {
        return found;
    }
    if let Ok(v) = serde_json::from_str::<serde_json::Value>(text.trim()) {
        if v["type"].as_str() == Some("result") {
            return v["result"].as_str().map(|s| s.to_string());
        }
    }
    None
}

/// The `## Handoff Delta` body: what this handoff adds relative to the PRIOR stage. Slice 1 has no
/// prior handoff (the prior stage is the session prompt / Analyst's WHAT), so the delta records
/// "new"; a re-run against an existing handoff records the size change. This is what makes the
/// handoff a *tracked* artifact with a recorded delta, not an opaque dump.
pub fn compute_delta(prior_body: Option<&str>, new_body: &str) -> String {
    match prior_body {
        None => format!(
            "- `+` new: first researcher handoff for this session ({} bytes of findings)\n\
             - prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against",
            new_body.len()
        ),
        Some(p) => format!(
            "- `~` re-run: researcher handoff replaced ({} bytes now vs {} bytes prior)\n\
             - prior stage: this session's earlier researcher handoff",
            new_body.len(),
            p.len()
        ),
    }
}

/// Format the governed handoff artifact (the DECISION-007 contract). Deterministic given its
/// inputs — the timestamp and cost are passed in so this stays pure and testable.
#[allow(clippy::too_many_arguments)]
pub fn format_handoff(
    role: &Role,
    session: u32,
    agent_label: &str,
    source_sha: &str,
    captured_utc: &str,
    cost: Option<f64>,
    body: &str,
    delta: &str,
) -> String {
    let cost_str = match cost {
        Some(c) => format!("{c:.6}"),
        None => "null".to_string(),
    };
    format!(
        "---\n\
         role: {role}\n\
         session: {session}\n\
         agent: {agent}\n\
         source-sha: {sha}\n\
         captured: {captured}\n\
         cost_usd: {cost}\n\
         ---\n\
         \n\
         # {Role} handoff — session {session}\n\
         \n\
         {body}\n\
         \n\
         ## Handoff Delta\n\
         {delta}\n",
        role = role.name,
        Role = title_case(role.name),
        agent = agent_label,
        sha = source_sha,
        captured = captured_utc,
        cost = cost_str,
    )
}

fn title_case(s: &str) -> String {
    let mut c = s.chars();
    match c.next() {
        None => String::new(),
        Some(f) => f.to_uppercase().collect::<String>() + c.as_str(),
    }
}

/// The six frontmatter keys the handoff contract requires (DECISION-007).
const FRONTMATTER_KEYS: [&str; 6] = [
    "role:",
    "session:",
    "agent:",
    "source-sha:",
    "captured:",
    "cost_usd:",
];

/// A handoff is well-formed iff it carries every frontmatter contract key, a non-empty findings
/// body, AND the `## Handoff Delta` section (DECISION-007). Used by the fail-closed smoke/gate: a
/// malformed or empty handoff must NEVER read as a successful step. `Err(reason)` names the first
/// missing piece.
pub fn validate_handoff(text: &str) -> Result<(), String> {
    for key in FRONTMATTER_KEYS {
        if !text.lines().any(|l| l.trim_start().starts_with(key)) {
            return Err(format!("handoff missing frontmatter key `{key}`"));
        }
    }
    if !text.contains("## Handoff Delta") {
        return Err("handoff missing `## Handoff Delta` section".into());
    }
    match handoff_body(text) {
        Some(b) if !b.trim().is_empty() => Ok(()),
        _ => Err("handoff has an empty findings body".into()),
    }
}

/// The findings body — the content between the closing frontmatter fence and the `## Handoff Delta`
/// section, minus heading lines. `None` when the frontmatter fence or the delta section is absent.
/// Public so the launcher can extract a PRIOR handoff's body to feed `compute_delta` on a re-run.
pub fn handoff_body(text: &str) -> Option<String> {
    let after_fm = text.strip_prefix("---\n")?;
    let close = after_fm.find("\n---\n")?;
    let rest = &after_fm[close + 5..];
    let (before_delta, _) = rest.split_once("## Handoff Delta")?;
    let body: Vec<&str> = before_delta
        .lines()
        .map(|l| l.trim())
        .filter(|l| !l.is_empty() && !l.starts_with('#'))
        .collect();
    Some(body.join("\n"))
}

/// sha256 of a byte string — the handoff's `source-sha` preimage. Shells out (same tool-fallback
/// order as `verify-closeout.sh#_sha256` / `stations::sha256_hex`) rather than add a crate for one
/// hash; this codebase already shells to git/sha tools throughout.
pub fn sha256_hex(bytes: &[u8]) -> Option<String> {
    let variants: [(&str, &[&str]); 2] = [("sha256sum", &[]), ("shasum", &["-a", "256"])];
    for (cmd, args) in variants {
        let mut child = match Command::new(cmd)
            .args(args)
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::null())
            .spawn()
        {
            Ok(c) => c,
            Err(_) => continue,
        };
        if let Some(mut stdin) = child.stdin.take() {
            if stdin.write_all(bytes).is_err() {
                continue;
            }
        }
        if let Ok(out) = child.wait_with_output() {
            if out.status.success() {
                if let Some(h) = String::from_utf8_lossy(&out.stdout)
                    .split_whitespace()
                    .next()
                {
                    return Some(h.to_string());
                }
            }
        }
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn resolve_role_knows_researcher_and_fails_closed_on_unknown() {
        assert!(resolve_role("researcher").is_some());
        assert_eq!(resolve_role("researcher").unwrap().name, "researcher");
        // Unknown role → None (the caller fails closed). Case-sensitive on the stable key.
        assert!(resolve_role("Researcher").is_none());
        assert!(resolve_role("coder").is_none());
        assert!(resolve_role("").is_none());
        assert!(known_roles().contains("researcher"));
    }

    #[test]
    fn handoff_rel_lands_in_ai_spine() {
        let r = resolve_role("researcher").unwrap();
        assert_eq!(r.handoff_rel(109), ".ai/handoffs/session-109-researcher.md");
        // Zero-padded to two digits (matches the sessions/ + prompts/ convention).
        assert_eq!(r.handoff_rel(9), ".ai/handoffs/session-09-researcher.md");
    }

    #[test]
    fn role_scoped_input_binds_role_and_task() {
        let r = resolve_role("researcher").unwrap();
        let a = role_scoped_input(r, "what is X");
        let b = role_scoped_input(r, "what is Y");
        assert_ne!(a, b, "different tasks → different scoped input");
        assert!(a.contains("what is X"));
        assert!(a.contains("Researcher"));
        assert!(a.contains('\0'), "role and task are NUL-separated");
    }

    #[test]
    fn parse_agent_result_reads_stream_json_result() {
        let out = concat!(
            r#"{"type":"system","subtype":"init"}"#,
            "\n",
            r#"{"type":"result","result":"The answer is 42.","total_cost_usd":0.0031}"#,
            "\n"
        );
        let r = parse_agent_result(out.as_bytes()).expect("parses");
        assert_eq!(r.body, "The answer is 42.");
        assert_eq!(r.cost, Some(0.0031));
    }

    #[test]
    fn parse_agent_result_reads_single_json_object() {
        let out = r#"{"type":"result","result":"body here","total_cost_usd":0.5}"#;
        let r = parse_agent_result(out.as_bytes()).expect("parses");
        assert_eq!(r.body, "body here");
        assert_eq!(r.cost, Some(0.5));
    }

    #[test]
    fn parse_agent_result_last_result_wins() {
        let out = concat!(
            r#"{"type":"result","result":"stale","total_cost_usd":0.1}"#,
            "\n",
            r#"{"type":"result","result":"final","total_cost_usd":0.2}"#,
            "\n"
        );
        let r = parse_agent_result(out.as_bytes()).unwrap();
        assert_eq!(r.body, "final");
        assert_eq!(r.cost, Some(0.2));
    }

    #[test]
    fn parse_agent_result_fails_closed_on_no_result_or_empty_body() {
        // No result object at all → None (fail closed).
        assert!(parse_agent_result(b"just some text, not json").is_none());
        assert!(parse_agent_result(br#"{"type":"system"}"#).is_none());
        // A result object with an EMPTY body → None (never write an empty handoff).
        let empty = r#"{"type":"result","result":"   ","total_cost_usd":0.1}"#;
        assert!(parse_agent_result(empty.as_bytes()).is_none());
        // A result object with no `result` field → None.
        let nobody = r#"{"type":"result","total_cost_usd":0.1}"#;
        assert!(parse_agent_result(nobody.as_bytes()).is_none());
    }

    #[test]
    fn parse_agent_result_tolerates_missing_cost() {
        // A well-formed body but no cost → Some with cost None (text-mode-ish; S77 honest null).
        let out = r#"{"type":"result","result":"found it"}"#;
        let r = parse_agent_result(out.as_bytes()).unwrap();
        assert_eq!(r.body, "found it");
        assert_eq!(r.cost, None);
    }

    #[test]
    fn compute_delta_new_vs_rerun() {
        let d0 = compute_delta(None, "abcde");
        assert!(d0.contains("`+` new"));
        assert!(d0.contains("5 bytes"));
        let d1 = compute_delta(Some("ab"), "abcde");
        assert!(d1.contains("`~` re-run"));
        assert!(d1.contains("5 bytes now vs 2 bytes"));
    }

    #[test]
    fn format_handoff_carries_the_full_contract_and_validates() {
        let r = resolve_role("researcher").unwrap();
        let delta = compute_delta(None, "the findings");
        let h = format_handoff(
            r,
            109,
            "stub",
            "a".repeat(64).as_str(),
            "2026-08-02T00:00:00Z",
            Some(0.0031),
            "the findings",
            &delta,
        );
        // Frontmatter contract keys all present.
        assert!(h.contains("role: researcher"));
        assert!(h.contains("session: 109"));
        assert!(h.contains("agent: stub"));
        assert!(h.contains("source-sha: aaaa"));
        assert!(h.contains("captured: 2026-08-02T00:00:00Z"));
        assert!(h.contains("cost_usd: 0.003100"));
        assert!(h.contains("# Researcher handoff — session 109"));
        assert!(h.contains("the findings"));
        assert!(h.contains("## Handoff Delta"));
        // A well-formed handoff validates.
        assert!(validate_handoff(&h).is_ok());
    }

    #[test]
    fn format_handoff_renders_null_cost_when_absent() {
        let r = resolve_role("researcher").unwrap();
        let h = format_handoff(
            r,
            5,
            "claude",
            "b".repeat(64).as_str(),
            "2026-08-02T00:00:00Z",
            None,
            "body",
            "- `+` new",
        );
        assert!(h.contains("cost_usd: null"));
        assert!(validate_handoff(&h).is_ok());
    }

    #[test]
    fn validate_handoff_fails_closed_on_each_missing_piece() {
        let r = resolve_role("researcher").unwrap();
        let good = format_handoff(
            r,
            109,
            "stub",
            "c".repeat(64).as_str(),
            "t",
            Some(0.1),
            "real body",
            "- `+` new",
        );
        assert!(validate_handoff(&good).is_ok());

        // Missing a frontmatter key (drop the `agent:` line).
        let no_agent = good
            .lines()
            .filter(|l| !l.trim_start().starts_with("agent:"))
            .collect::<Vec<_>>()
            .join("\n");
        assert!(validate_handoff(&no_agent).is_err());

        // Missing the delta section.
        let no_delta = good.replace("## Handoff Delta", "## Something Else");
        assert!(validate_handoff(&no_delta).is_err());

        // Empty body (frontmatter + delta only, heading but no findings).
        let empty_body = "---\nrole: researcher\nsession: 109\nagent: stub\n\
             source-sha: cccc\ncaptured: t\ncost_usd: 0.1\n---\n\n\
             # Researcher handoff — session 109\n\n## Handoff Delta\n- `+` new\n";
        assert!(validate_handoff(empty_body).is_err());

        // Not a handoff at all.
        assert!(validate_handoff("just some notes").is_err());
    }

    #[test]
    fn sha256_hex_is_deterministic_64_hex() {
        let a = sha256_hex(b"hello").expect("sha available");
        let b = sha256_hex(b"hello").unwrap();
        assert_eq!(a, b);
        assert_eq!(a.len(), 64);
        assert!(a.chars().all(|c| c.is_ascii_hexdigit()));
        // Known vector for "hello".
        assert_eq!(
            a,
            "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
        );
    }
}
