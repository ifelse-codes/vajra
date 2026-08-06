//! S109 — fleet slice 1: one named agent role (the Researcher) dispatched as a NATIVE Claude Code
//! **subagent** and governed by Vajra. Locked by `docs/decisions/DECISION-007-agent-fleet.md`.
//!
//! Vajra is an external binary — it does not (cannot) *call* a Claude Code subagent; subagents only
//! exist inside a running agent session. So Vajra's job for a named role is two things, both in this
//! module's contract:
//!   1. **Scaffold** the role as a native subagent definition (`.claude/agents/<name>.md`), rendered
//!      from ONE canonical source (the S104/S99 no-drift rule) — the same way `vajra init` already
//!      scaffolds `.claude/settings.json` + hooks (S44). The role prompt is vendor-neutral here;
//!      only the *rendering* is Claude-specific.
//!   2. **Govern the handoff.** The subagent returns a findings brief; Vajra wraps it into a
//!      delta-tracked handoff in the `.ai/` spine (the memory — no new store) and FAIL-CLOSES on an
//!      unknown role, missing/empty findings, or a handoff that would not validate.
//!
//! This module is the PURE core (role resolution, subagent rendering, handoff format + validate +
//! delta, one hash). The impure edges (reading findings, writing files, git) live in `cli::next` /
//! `cli::init`. Everything here is unit-testable without spawning anything.
//!
//! S112 adds the READ side — `read_handoff`/`read_handoffs` — so a station can consume what the
//! fleet produced. That is one narrow, fs-READ-only edge (no writes, no processes, tempdir-testable);
//! its parsing core, `parse_handoff`, stays pure like everything else here.
//!
//! S114 adds the SECOND role — the **Fidelity Reviewer** (chosen from evidence at S113, built here;
//! `DECISION-007` S114 addendum). No new machinery: it is one more `ROLES` entry, and every path
//! above already iterates the roles. What it DID force is honesty about the single source — the tool
//! grant and the delta text were both hardcoded to the Researcher while only one role existed, and
//! are now per-role.

use std::io::Write;
use std::process::{Command, Stdio};

/// A named fleet role: its key, a one-line description (for the subagent picker), the system prompt
/// that scopes the agent, and — via `handoff_rel` — where its governed handoff lands. The ONE place
/// role text lives; both the subagent definition and the handoff are rendered from it (no drift).
pub struct Role {
    /// The `--role <name>` key and the subagent `name:`. Lower-case, stable — the join key.
    pub name: &'static str,
    /// One line describing WHEN to use this role — the subagent frontmatter `description:`.
    pub description: &'static str,
    /// The role-scoping system prompt — the subagent definition body.
    pub system_prompt: &'static str,
    /// This role's tool grant, rendered verbatim into the subagent frontmatter `tools:`. Per-role
    /// (S114) — it was hardcoded to the Researcher's list while only one role existed, which would
    /// have silently handed every future role the Researcher's web access. **Every registered role
    /// is read-only**; a role that could write is a materially bigger governance decision
    /// (DECISION-007) and none is taken here.
    pub tools: &'static str,
}

impl Role {
    /// Where this role's governed handoff for `session` lands, repo-relative. `.ai/` IS the memory
    /// (DECISION-007 / `feedback-map-concepts-to-vajra`) — no new store, no 8th artifact type.
    pub fn handoff_rel(&self, session: u32) -> String {
        format!(".ai/handoffs/session-{session:02}-{}.md", self.name)
    }

    /// Where this role's native subagent definition is scaffolded, repo-relative — the standard
    /// Claude Code `.claude/agents/<name>.md` location.
    pub fn subagent_rel(&self) -> String {
        format!(".claude/agents/{}.md", self.name)
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

/// The Reviewer's contract (S114). This is the brief this repo has re-typed from memory every
/// session for 47 cold reviews — made canonical here, which is the whole point of `ROLES`.
///
/// Two things it states that no other role does, both locked by the `DECISION-007` S114 addendum:
/// the verdict it returns is a **pre-stage input**, and the canonical, gated record of the verdict
/// stays `sessions/session-NN-review.md` — this agent never writes that file (it has no write tool
/// and is told not to ask for one).
const FIDELITY_REVIEWER_SYSTEM_PROMPT: &str =
    "You are the Fidelity Reviewer on a governed software \
team. Your ONE job is an INDEPENDENT, ADVERSARIAL cold review of a delivery you did not build.\n\
You are fed only two things: the session prompt (what was asked) and the diff (what was done). \
Judge from those. Do not accept the builder's own summary as evidence.\n\
Rules:\n\
- Do NOT write, edit, or run code. You read and judge only.\n\
- Grade EVERY numbered requirement in the prompt: SHIPPED / PARTIAL / NOT-BUILT, each with the \
concrete evidence in the diff that earns the grade. A requirement with no evidence is NOT-BUILT.\n\
- Following the rules is not delivering what was asked: a green verify script proves discipline, \
never fidelity. Never grade from test counts alone.\n\
- Name THE FAKEST GREEN — the thing that looks done but is hollow (a check that would pass if the \
feature were deleted, a marker the author simply typed, an assertion that cannot fail).\n\
- Never self-certify and never soften: if the delivery is short, say so.\n\
Shape your brief so it can be landed without rewriting — the closeout gate reads the landed record \
and FAILS unless it carries all three of these:\n\
- a per-requirement table using the verdict vocabulary SHIPPED / PARTIAL / NOT-BUILT,\n\
- a canonical `**Verdict:** ACCEPT` or `**Verdict:** REJECT` line (the word buried in a heading \
does not count),\n\
- a count of the form `X of N SHIPPED`.\n\
The full contract you are performing is `reviewer/SKILL.md` in this repo — READ IT before you \
judge; it is canonical and this brief is its dispatch-time summary, never a competing version.\n\
Your verdict is a PRE-STAGE INPUT. The canonical, gated record of the fidelity verdict is \
`sessions/session-NN-review.md` (read by `verify-closeout.sh`, attested by a `**Review-Inputs-SHA:**` \
the orchestrator computes, chained in the ledger) — you do not write it, and you are not its \
replacement.";

/// The registered roles. Slice 1 (DECISION-007) shipped exactly ONE — the Researcher. S114 adds the
/// SECOND, chosen from evidence at S113 and built here: the Fidelity Reviewer. A third role is
/// again a separate decision, not a reflex (the named key risk of S109 is scope creep).
///
/// **The key is `fidelity-reviewer`, not `reviewer`** — the deliberate resolution of the collision
/// the S113 cold review named (`DECISION-007` S114 addendum). `K of 8` already counts a **Reviewer
/// station**; a role keyed `reviewer` would make "Reviewer" mean two different things in two lines
/// of the same report. Distinct key, distinct word, no ambiguity.
pub const ROLES: &[Role] = &[
    Role {
        name: "researcher",
        description: "Investigate a question and return a concise, decision-ready findings brief. \
                      Use before a design or build decision that needs facts, trade-offs, or prior \
                      art. Read-only — never writes code.",
        system_prompt: RESEARCHER_SYSTEM_PROMPT,
        // Investigation needs the web; judging a diff does not.
        tools: "Read, Grep, Glob, WebSearch, WebFetch",
    },
    Role {
        name: "fidelity-reviewer",
        description: "Independently cold-review a finished delivery against the session prompt: \
                      grade every numbered requirement SHIPPED/PARTIAL/NOT-BUILT and name the \
                      fakest green. Use at close, never on your own work. Read-only.",
        system_prompt: FIDELITY_REVIEWER_SYSTEM_PROMPT,
        // Strictly local reads. No web (a fidelity call is decided by the prompt and the diff in
        // front of it, not by the internet) and no Bash (running things is the QA station's job,
        // live — DECISION-007 rejected swapping those teeth for an agent's prose).
        tools: "Read, Grep, Glob",
    },
];

/// Resolve a role by its key. `None` (→ the caller fails closed) for an unknown role: vajra never
/// governs a role it cannot scope.
pub fn resolve_role(name: &str) -> Option<&'static Role> {
    ROLES.iter().find(|r| r.name == name)
}

/// The known role names, comma-joined — for a fail-closed "unknown role" error message.
pub fn known_roles() -> String {
    ROLES.iter().map(|r| r.name).collect::<Vec<_>>().join(", ")
}

/// Render a role as a native Claude Code subagent definition (`.claude/agents/<name>.md`): YAML
/// frontmatter (`name`, `description`, read-only `tools`) + the system prompt + a short note that
/// its findings become a Vajra-governed handoff (so the subagent returns a brief, and does NOT try
/// to author the handoff frontmatter — Vajra owns that). Rendered from the SAME `Role` the handoff
/// uses — one canonical source, no drift.
pub fn render_subagent_definition(role: &Role) -> String {
    format!(
        "---\n\
         name: {name}\n\
         description: {desc}\n\
         tools: {tools}\n\
         ---\n\
         \n\
         {sys}\n\
         \n\
         ## Governed handoff (Vajra owns this)\n\
         Return your findings brief as your final message. The orchestrator records it as a\n\
         Vajra-governed, delta-tracked handoff at `.ai/handoffs/session-<NN>-{name}.md` via\n\
         `vajra next --role {name} --from <file>`. Do NOT write the handoff frontmatter yourself —\n\
         Vajra computes the source hash, the timestamp, and the delta against the prior stage.\n",
        name = role.name,
        desc = role.description,
        tools = role.tools,
        sys = role.system_prompt,
    )
}

/// The `## Handoff Delta` body: what this handoff adds relative to the PRIOR stage. A first handoff
/// has no prior (the prior stage is the session prompt / Analyst's WHAT), so the delta records
/// "new"; a re-run against an existing handoff records the size change. This is what makes the
/// handoff a *tracked* artifact with a recorded delta, not an opaque dump.
///
/// S114: takes the `role` instead of writing the word "researcher" into every delta. With one role
/// registered the hardcoding was invisible; with two it would have stamped a Reviewer handoff with
/// the Researcher's name — the single-source drift this module exists to prevent.
pub fn compute_delta(role: &Role, prior_body: Option<&str>, new_body: &str) -> String {
    match prior_body {
        None => format!(
            "- `+` new: first {role} handoff for this session ({} bytes of findings)\n\
             - prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against",
            new_body.len(),
            role = role.name
        ),
        Some(p) => format!(
            "- `~` re-run: {role} handoff replaced ({} bytes now vs {} bytes prior)\n\
             - prior stage: this session's earlier {role} handoff",
            new_body.len(),
            p.len(),
            role = role.name
        ),
    }
}

/// Format the governed handoff artifact (the DECISION-007 contract). Deterministic given its
/// inputs — the timestamp is passed in so this stays pure and testable. `cost` is the subagent's
/// metered dollars when known, else `None`. **S111 checked this, not guessed it, with a re-runnable
/// script** (`scripts/check-subagent-cost-fields.sh`, not a one-off count baked in here): every real
/// subagent JSONL transcript on the checking machine was scanned — zero carry a `total_cost_usd` /
/// `cost_usd` key. A Task-tool subagent never produces the `-p` headless result stream that field is
/// emitted on (same root cause as S77/S78), so the figure structurally does not exist for Vajra to
/// read — `null` is the honest, checked answer, not a gap to close.
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
/// body, AND the `## Handoff Delta` section (DECISION-007). Used by the fail-closed governance: a
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
/// Public so the ingest can extract a PRIOR handoff's body to feed `compute_delta` on a re-run.
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

/// sha256 of a byte string — the handoff's `source-sha` preimage (the subagent's raw findings), so
/// a governed handoff is verifiably derived from those exact findings. Shells out (same tool-fallback
/// order as `verify-closeout.sh#_sha256`) rather than add a crate for one hash; this codebase already
/// shells to git/sha tools throughout.
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

// ---------------------------------------------------------------------------
// S112 — the READ side. S109 wrote governed handoffs; S111 proved they come from a real by-name
// dispatch; nothing read them back, so the fleet's output sat orphaned next to the pipeline it
// belongs to. Everything below turns a written handoff into something a station can consume.
// ---------------------------------------------------------------------------

/// What a governed handoff says about itself, read back off disk. Built ONLY from a handoff that
/// passed `validate_handoff` — a malformed one becomes `HandoffRead::Malformed`, never a `Handoff`
/// with blank fields, so a broken artifact can never read as a good one (the fail-closed rule,
/// applied to the reader).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Handoff {
    /// The role that produced it (`role:` frontmatter) — e.g. `researcher`.
    pub role: String,
    /// The session it belongs to, from the path it was found at (the SoT for placement).
    pub session: u32,
    /// Repo-relative path, so a caller can point a human at the file.
    pub path: String,
    /// The `agent:` frontmatter — which agent produced the findings.
    pub agent: String,
    /// The `captured:` frontmatter — when.
    pub captured: String,
    /// The `source-sha:` frontmatter — the hash of the raw findings it was derived from.
    pub source_sha: String,
    /// The findings body, already stripped of headings/blank lines by `handoff_body`.
    pub body: String,
}

impl Handoff {
    /// Every non-empty body line, trimmed — the basis for both the inline head and the honest
    /// "there is more" count.
    fn body_lines(&self) -> Vec<String> {
        self.body
            .lines()
            .map(|l| l.trim().to_string())
            .filter(|l| !l.is_empty())
            .collect()
    }

    /// The first `n` body lines — what a consuming station inlines so the findings are actually in
    /// front of the reader, not merely referenced by path.
    pub fn head_lines(&self, n: usize) -> Vec<String> {
        self.body_lines().into_iter().take(n).collect()
    }

    /// How many body lines the inline head LEAVES OUT at `n`. A reader who is shown 6 of 40 lines
    /// must be told so — a truncation that looks like the whole thing is exactly the false green
    /// this project exists to kill.
    pub fn omitted_lines(&self, n: usize) -> usize {
        self.body_lines().len().saturating_sub(n)
    }
}

/// The three honest outcomes of looking for a role's handoff. `Absent` is the silent, harmless
/// case (most sessions have no researcher handoff and must behave exactly as before). `Malformed`
/// is deliberately NOT silent: a file that exists but fails the contract is a problem to surface,
/// not to swallow.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum HandoffRead {
    /// No handoff file for this role/session.
    Absent,
    /// A file exists but does not satisfy the DECISION-007 contract. Carries (path, reason).
    Malformed(String, String),
    /// A contract-valid handoff.
    Found(Handoff),
}

/// Parse handoff TEXT into a `Handoff` (pure — the testable core). `session`/`path` come from where
/// it was found rather than from the frontmatter: the path is the placement SoT, and trusting a
/// self-declared `session:` would let a misfiled handoff claim any session it liked.
pub fn parse_handoff(text: &str, session: u32, path: &str) -> Result<Handoff, String> {
    validate_handoff(text)?;
    let body = handoff_body(text).ok_or_else(|| "handoff has no findings body".to_string())?;
    // Every displayed field must come from the FRONTMATTER BLOCK, not merely from somewhere in the
    // file. `validate_handoff` accepts a `role:` line anywhere (it scans all lines), so without this
    // a file whose keys sit in the body would parse into a `Handoff` with blank fields and render as
    // "  (agent: , captured: )" — a broken artifact reading as a good one. Fail closed instead.
    let field = |key: &str| {
        frontmatter_value(text, key)
            .ok_or_else(|| format!("handoff frontmatter block has no `{key}` value"))
    };
    Ok(Handoff {
        role: field("role:")?,
        session,
        path: path.to_string(),
        agent: field("agent:")?,
        captured: field("captured:")?,
        source_sha: field("source-sha:")?,
        body,
    })
}

/// The value of a frontmatter `key:` line, trimmed. Only the frontmatter block is searched (the
/// text before the closing `---` fence), so a body line that merely starts with `agent:` cannot
/// impersonate a frontmatter field.
fn frontmatter_value(text: &str, key: &str) -> Option<String> {
    let after_fm = text.strip_prefix("---\n")?;
    let close = after_fm.find("\n---\n")?;
    after_fm[..close]
        .lines()
        .find_map(|l| l.trim_start().strip_prefix(key))
        .map(|v| v.trim().to_string())
        .filter(|v| !v.is_empty())
}

/// Read one role's governed handoff for `session` back off disk (the module's one narrow read
/// edge — fs-read-only, no writes, no processes; testable against a tempdir). An unreadable file
/// is reported as `Malformed`, never silently `Absent`.
pub fn read_handoff(root: &std::path::Path, role: &Role, session: u32) -> HandoffRead {
    let rel = role.handoff_rel(session);
    let path = root.join(&rel);
    if !path.exists() {
        return HandoffRead::Absent;
    }
    match std::fs::read_to_string(&path) {
        Err(e) => HandoffRead::Malformed(rel, format!("unreadable: {e}")),
        Ok(text) => match parse_handoff(&text, session, &rel) {
            Ok(h) => HandoffRead::Found(h),
            Err(reason) => HandoffRead::Malformed(rel, reason),
        },
    }
}

/// Every registered role's handoff for `session`, dropping the `Absent` ones. Empty vec = this
/// session simply had no fleet work, which every caller must treat as normal and silent.
pub fn read_handoffs(root: &std::path::Path, session: u32) -> Vec<HandoffRead> {
    ROLES
        .iter()
        .map(|r| read_handoff(root, r, session))
        .filter(|h| !matches!(h, HandoffRead::Absent))
        .collect()
}

/// Render read handoffs as the block a consuming station prints: who produced it, when, where it
/// lives, and the first `head` findings lines INLINE (a path alone is not consumption). Empty
/// input renders the empty string — absence prints nothing at all.
pub fn format_handoff_brief(reads: &[HandoffRead], head: usize) -> String {
    let mut s = String::new();
    for r in reads {
        match r {
            HandoffRead::Absent => {}
            HandoffRead::Malformed(path, reason) => {
                s.push_str(&format!(
                    "  ⚠ {path} exists but does not satisfy the handoff contract ({reason}) \
                     — not used\n"
                ));
            }
            HandoffRead::Found(h) => {
                s.push_str(&format!(
                    "  {role} (agent: {agent}, captured: {captured})\n    {path}\n",
                    role = h.role,
                    agent = h.agent,
                    captured = h.captured,
                    path = h.path,
                ));
                for line in h.head_lines(head) {
                    let clipped: String = line.chars().take(110).collect();
                    let ell = if line.chars().count() > 110 {
                        "…"
                    } else {
                        ""
                    };
                    s.push_str(&format!("    · {clipped}{ell}\n"));
                }
                // Never let a truncated head read as the whole brief — say how much was left out
                // and where the rest is. A partial view that looks complete is a false green.
                let omitted = h.omitted_lines(head);
                if omitted > 0 {
                    s.push_str(&format!(
                        "    · … {omitted} more line(s) — full findings at {}\n",
                        h.path
                    ));
                }
            }
        }
    }
    s
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
    fn handoff_and_subagent_paths_are_conventional() {
        let r = resolve_role("researcher").unwrap();
        assert_eq!(r.handoff_rel(109), ".ai/handoffs/session-109-researcher.md");
        assert_eq!(r.handoff_rel(9), ".ai/handoffs/session-09-researcher.md");
        assert_eq!(r.subagent_rel(), ".claude/agents/researcher.md");
    }

    #[test]
    fn render_subagent_definition_is_valid_claude_agent_from_one_source() {
        let r = resolve_role("researcher").unwrap();
        let def = render_subagent_definition(r);
        // Claude Code subagent frontmatter: name + description, opening `---` fence.
        assert!(def.starts_with("---\n"));
        assert!(def.contains("name: researcher"));
        assert!(def.contains("description:"));
        assert!(def.contains("tools:"));
        // The body is the CANONICAL system prompt (no drift — same string the role carries).
        assert!(def.contains("You are the Researcher"));
        assert!(def.contains(r.system_prompt));
        // It points at the governed handoff, and tells the subagent NOT to author frontmatter.
        assert!(def.contains(".ai/handoffs/session-<NN>-researcher.md"));
        assert!(def.contains("vajra next --role researcher --from"));
    }

    #[test]
    fn compute_delta_new_vs_rerun() {
        let r = resolve_role("researcher").unwrap();
        let d0 = compute_delta(r, None, "abcde");
        assert!(d0.contains("`+` new"));
        assert!(d0.contains("5 bytes"));
        let d1 = compute_delta(r, Some("ab"), "abcde");
        assert!(d1.contains("`~` re-run"));
        assert!(d1.contains("5 bytes now vs 2 bytes"));
    }

    /// S114 — the delta names the role that produced it. Hardcoded to "researcher" before a second
    /// role existed, so a Reviewer handoff would have carried the Researcher's name in its own
    /// tracked delta. Asserted for EVERY registered role, so a third role cannot regress it.
    #[test]
    fn compute_delta_names_the_producing_role_not_a_hardcoded_one() {
        for role in ROLES {
            let new = compute_delta(role, None, "findings");
            let rerun = compute_delta(role, Some("prior"), "findings");
            assert!(
                new.contains(&format!("first {} handoff", role.name)),
                "new-delta does not name {}: {new}",
                role.name
            );
            assert!(
                rerun.contains(&format!("{} handoff replaced", role.name)),
                "re-run delta does not name {}: {rerun}",
                role.name
            );
            // A non-researcher role must not carry the Researcher's name anywhere in its delta.
            if role.name != "researcher" {
                assert!(
                    !new.contains("researcher"),
                    "{} leaked 'researcher'",
                    role.name
                );
                assert!(
                    !rerun.contains("researcher"),
                    "{} leaked 'researcher'",
                    role.name
                );
            }
        }
    }

    /// S114 — the SECOND role exists, is keyed to avoid the Reviewer-STATION collision, and carries
    /// the adversarial contract. This fails if the role is removed, renamed to `reviewer`, or
    /// hollowed out to a stub prompt.
    #[test]
    fn fidelity_reviewer_is_registered_with_a_non_colliding_key() {
        assert_eq!(ROLES.len(), 2, "the fleet ships exactly two roles at S114");
        let r = resolve_role("fidelity-reviewer").expect("the second role is registered");
        // The collision resolution, asserted: the key is NOT the bare station word.
        assert!(resolve_role("reviewer").is_none());
        assert!(known_roles().contains("fidelity-reviewer"));
        assert_eq!(
            r.handoff_rel(114),
            ".ai/handoffs/session-114-fidelity-reviewer.md"
        );
        assert_eq!(r.subagent_rel(), ".claude/agents/fidelity-reviewer.md");
        // The contract, not a stub: the three grades, the fakest green, and no self-certification.
        for must in [
            "SHIPPED / PARTIAL / NOT-BUILT",
            "FAKEST GREEN",
            "Never self-certify",
            "PRE-STAGE INPUT",
            "sessions/session-NN-review.md",
        ] {
            assert!(
                r.system_prompt.contains(must),
                "reviewer prompt is missing {must:?}"
            );
        }
    }

    /// S114, cold-review finding — the role brief is NOT the only statement of this contract:
    /// `reviewer/SKILL.md` is the canonical 100+ line version, scaffolded into every repo by the
    /// same `vajra init`. Two hand-maintained statements of one job is exactly the drift this
    /// module exists to prevent, and the dangerous half is the OUTPUT SHAPE: a dispatched agent
    /// obeying only the role brief could return a verdict the closeout gate then REJECTS.
    ///
    /// So this test binds them: every token `verify-closeout.sh` requires of a landed review must
    /// appear in BOTH files. It reads the skill off disk on purpose — a change to the canonical
    /// contract that the role brief does not follow turns this red.
    #[test]
    fn the_role_brief_carries_the_output_shape_the_closeout_gate_requires() {
        let skill =
            std::fs::read_to_string(concat!(env!("CARGO_MANIFEST_DIR"), "/reviewer/SKILL.md"))
                .expect("reviewer/SKILL.md is the canonical contract and must exist");
        let brief = resolve_role("fidelity-reviewer").unwrap().system_prompt;

        // The three things the gate FAILS a review for missing (verify-closeout.sh).
        for token in [
            "SHIPPED",
            "PARTIAL",
            "NOT-BUILT",
            "**Verdict:**",
            "of N SHIPPED",
        ] {
            // Positive control: the canonical contract really does require it. Without this, a
            // typo'd token would make the assertion below vacuously about nothing.
            assert!(
                skill.contains(token) || skill.contains(&token.replace("of N ", "X of N ")),
                "positive control failed: reviewer/SKILL.md does not mention {token:?} — \
                 fix this test's tokens, do not weaken it"
            );
            assert!(
                brief.contains(token),
                "the role brief omits {token:?}, which the closeout gate requires of the landed \
                 review — a dispatched agent obeying only this brief would produce a REJECTED file"
            );
        }
        // And the brief must point at the canonical contract by name, so it reads as a summary of
        // one source rather than a rival second source.
        assert!(
            brief.contains("reviewer/SKILL.md"),
            "the role brief does not name reviewer/SKILL.md as canonical"
        );
    }

    /// S114 — every role is read-only, and the tool grant is the ROLE's, not a hardcoded list.
    /// The Reviewer gets strictly local reads: no web, no Bash.
    #[test]
    fn every_role_is_read_only_and_renders_its_own_tools() {
        for role in ROLES {
            let def = render_subagent_definition(role);
            assert!(
                def.contains(&format!("tools: {}", role.tools)),
                "{} does not render its own tools",
                role.name
            );
            for forbidden in ["Write", "Edit", "Bash", "NotebookEdit"] {
                assert!(
                    !role.tools.contains(forbidden),
                    "{} grants the write/exec tool {forbidden}",
                    role.name
                );
            }
        }
        let rev = resolve_role("fidelity-reviewer").unwrap();
        assert_eq!(rev.tools, "Read, Grep, Glob");
        let res = resolve_role("researcher").unwrap();
        assert_ne!(res.tools, rev.tools, "the tool grant must be per-role");
    }

    /// S114 — the rendering is generic: every registered role produces a valid subagent definition
    /// pointing at ITS OWN handoff path and ITS OWN `vajra next --role` command line.
    #[test]
    fn render_subagent_definition_is_correct_for_every_registered_role() {
        for role in ROLES {
            let def = render_subagent_definition(role);
            assert!(def.starts_with("---\n"));
            assert!(def.contains(&format!("name: {}", role.name)));
            assert!(def.contains(role.description));
            assert!(def.contains(role.system_prompt));
            assert!(def.contains(&format!(".ai/handoffs/session-<NN>-{}.md", role.name)));
            assert!(def.contains(&format!("vajra next --role {} --from", role.name)));
        }
    }

    #[test]
    fn format_handoff_carries_the_full_contract_and_validates() {
        let r = resolve_role("researcher").unwrap();
        let delta = compute_delta(r, None, "the findings");
        let h = format_handoff(
            r,
            109,
            "claude-code-subagent",
            "a".repeat(64).as_str(),
            "2026-08-02T00:00:00Z",
            None,
            "the findings",
            &delta,
        );
        assert!(h.contains("role: researcher"));
        assert!(h.contains("session: 109"));
        assert!(h.contains("agent: claude-code-subagent"));
        assert!(h.contains("source-sha: aaaa"));
        assert!(h.contains("captured: 2026-08-02T00:00:00Z"));
        assert!(h.contains("cost_usd: null"));
        assert!(h.contains("# Researcher handoff — session 109"));
        assert!(h.contains("the findings"));
        assert!(h.contains("## Handoff Delta"));
        assert!(validate_handoff(&h).is_ok());
    }

    #[test]
    fn format_handoff_renders_known_cost() {
        let r = resolve_role("researcher").unwrap();
        let h = format_handoff(
            r,
            5,
            "claude-code-subagent",
            "b".repeat(64).as_str(),
            "2026-08-02T00:00:00Z",
            Some(0.0031),
            "body",
            "- `+` new",
        );
        assert!(h.contains("cost_usd: 0.003100"));
        assert!(validate_handoff(&h).is_ok());
    }

    #[test]
    fn validate_handoff_fails_closed_on_each_missing_piece() {
        let r = resolve_role("researcher").unwrap();
        let good = format_handoff(
            r,
            109,
            "claude-code-subagent",
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
        let empty_body = "---\nrole: researcher\nsession: 109\nagent: claude-code-subagent\n\
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
        assert_eq!(
            a,
            "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
        );
    }

    // ---- S112: the read side ------------------------------------------------------------

    /// A contract-valid handoff, written where `read_handoff` will look for it.
    fn write_handoff(root: &std::path::Path, session: u32, body: &str) -> String {
        let r = resolve_role("researcher").unwrap();
        let text = format_handoff(
            r,
            session,
            "claude-code-subagent",
            &"d".repeat(64),
            "2026-08-04T00:00:00Z",
            None,
            body,
            &compute_delta(r, None, body),
        );
        let rel = r.handoff_rel(session);
        let path = root.join(&rel);
        std::fs::create_dir_all(path.parent().unwrap()).unwrap();
        std::fs::write(&path, &text).unwrap();
        text
    }

    #[test]
    fn parse_handoff_round_trips_what_format_handoff_wrote() {
        let r = resolve_role("researcher").unwrap();
        let text = format_handoff(
            r,
            112,
            "claude-code-subagent",
            &"e".repeat(64),
            "2026-08-04T00:00:00Z",
            Some(0.25),
            "line one\nline two",
            "- `+` new",
        );
        let h = parse_handoff(&text, 112, ".ai/handoffs/session-112-researcher.md").unwrap();
        assert_eq!(h.role, "researcher");
        assert_eq!(h.session, 112);
        assert_eq!(h.agent, "claude-code-subagent");
        assert_eq!(h.captured, "2026-08-04T00:00:00Z");
        assert_eq!(h.source_sha, "e".repeat(64));
        assert_eq!(h.head_lines(1), vec!["line one".to_string()]);
        assert_eq!(h.head_lines(9), vec!["line one", "line two"]);
    }

    #[test]
    fn parse_handoff_trusts_the_path_not_a_self_declared_session() {
        // Frontmatter claims session 999; it was found at session 112's path. The path wins —
        // a misfiled handoff must not be able to claim a session it is not in.
        let r = resolve_role("researcher").unwrap();
        let text = format_handoff(
            r,
            999,
            "a",
            &"f".repeat(64),
            "t",
            None,
            "findings",
            "- `+` new",
        );
        let h = parse_handoff(&text, 112, ".ai/handoffs/session-112-researcher.md").unwrap();
        assert_eq!(h.session, 112);
    }

    /// A file whose contract keys live in the BODY rather than the frontmatter block passes
    /// `validate_handoff` (it scans every line) but must NOT parse into a `Handoff` with blank
    /// fields — that would render as "(agent: , captured: )" and read as a good artifact.
    #[test]
    fn parse_handoff_fails_closed_when_a_key_is_not_in_the_frontmatter_block() {
        let text = "---\nrole: researcher\nsession: 1\nsource-sha: x\ncaptured: t\n\
             cost_usd: null\n---\n\n# H\n\nagent: down-here-not-in-frontmatter\n\n\
             ## Handoff Delta\n- d\n";
        // The legacy contract check passes — every key appears SOMEWHERE.
        assert!(validate_handoff(text).is_ok());
        // The reader does not: `agent:` is not in the frontmatter block.
        let err = parse_handoff(text, 1, "p").unwrap_err();
        assert!(err.contains("agent:"), "got: {err}");
    }

    #[test]
    fn head_lines_truncation_is_disclosed_not_silent() {
        let tmp = tempfile::tempdir().unwrap();
        write_handoff(tmp.path(), 112, "l1\nl2\nl3\nl4\nl5");
        let out = format_handoff_brief(&read_handoffs(tmp.path(), 112), 2);
        assert!(out.contains("l1"));
        assert!(out.contains("l2"));
        assert!(!out.contains("l5"));
        // The reader is TOLD what was left out, and where the rest lives.
        assert!(out.contains("3 more line(s)"), "got: {out}");
        assert!(out.contains(".ai/handoffs/session-112-researcher.md"));

        // Nothing omitted -> no "more lines" noise.
        let full = format_handoff_brief(&read_handoffs(tmp.path(), 112), 99);
        assert!(!full.contains("more line(s)"));
    }

    #[test]
    fn frontmatter_value_ignores_a_body_line_that_looks_like_a_key() {
        let text = "---\nrole: researcher\nsession: 1\nagent: real-agent\nsource-sha: x\n\
             captured: t\ncost_usd: null\n---\n\n# H\n\nagent: impostor\n\n## Handoff Delta\n- d\n";
        let h = parse_handoff(text, 1, "p").unwrap();
        assert_eq!(h.agent, "real-agent");
    }

    #[test]
    fn read_handoff_absent_found_and_malformed() {
        let tmp = tempfile::tempdir().unwrap();
        let root = tmp.path();
        let r = resolve_role("researcher").unwrap();

        // Absent — the silent, harmless case every no-fleet session must hit.
        assert_eq!(read_handoff(root, r, 112), HandoffRead::Absent);
        assert!(read_handoffs(root, 112).is_empty());

        // Found.
        write_handoff(root, 112, "the finding that matters");
        match read_handoff(root, r, 112) {
            HandoffRead::Found(h) => {
                assert_eq!(h.role, "researcher");
                assert_eq!(h.path, ".ai/handoffs/session-112-researcher.md");
                assert!(h.body.contains("the finding that matters"));
            }
            other => panic!("expected Found, got {other:?}"),
        }
        assert_eq!(read_handoffs(root, 112).len(), 1);

        // Malformed — present but off-contract. NOT silent: it must name why.
        std::fs::write(
            root.join(r.handoff_rel(112)),
            "not a handoff at all, just notes\n",
        )
        .unwrap();
        match read_handoff(root, r, 112) {
            HandoffRead::Malformed(path, reason) => {
                assert!(path.ends_with("session-112-researcher.md"));
                assert!(!reason.is_empty());
            }
            other => panic!("expected Malformed, got {other:?}"),
        }
    }

    #[test]
    fn format_handoff_brief_inlines_findings_and_is_empty_when_absent() {
        // Absence renders NOTHING — a session with no fleet work looks exactly as it did before.
        assert_eq!(format_handoff_brief(&[], 3), "");
        assert_eq!(format_handoff_brief(&[HandoffRead::Absent], 3), "");

        let tmp = tempfile::tempdir().unwrap();
        write_handoff(
            tmp.path(),
            112,
            "first finding\nsecond finding\nthird finding",
        );
        let out = format_handoff_brief(&read_handoffs(tmp.path(), 112), 2);
        assert!(out.contains("researcher"));
        assert!(out.contains("claude-code-subagent"));
        assert!(out.contains(".ai/handoffs/session-112-researcher.md"));
        // The findings are INLINE, not just pointed at — and clipped to `head`.
        assert!(out.contains("first finding"));
        assert!(out.contains("second finding"));
        assert!(!out.contains("third finding"));

        // A malformed handoff is surfaced, never swallowed.
        let bad = HandoffRead::Malformed("p.md".into(), "missing frontmatter key `role:`".into());
        let out = format_handoff_brief(&[bad], 2);
        assert!(out.contains("p.md"));
        assert!(out.contains("not used"));
    }
}
