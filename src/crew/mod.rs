//! The Crew gate (S135) — the `tech-lead`'s decision, made binding.
//!
//! The `tech-lead` (`fleet::ROLES`, S135) is the tenth role and the FIRST and MANDATORY dispatch of
//! every session. It records, for each of the nine specialist roles, whether this task needs it
//! (`required`) or cannot afford it this session (`deferred-budget`), plus a numeric token budget.
//! This module makes that decision BIND: `crew_gate` blocks a session's close unless
//!   1. a real, provenance-verified `tech-lead` handoff exists (and is NOT a recorded skip — the
//!      tech-lead is the one role phase 1 forbids skipping), AND
//!   2. its handoff records an admissible verdict + substantive reason + numeric budget for all
//!      NINE specialists, AND
//!   3. every role it marked `required` has produced its own real governed handoff.
//!
//! # Built as a CALL SITE on `src/mandate`, not an edit to it (the S133 falsification test)
//!
//! S133 wrote `mandate::mandate_gate` generic over a `fleet::Role` and a `from_session` threshold,
//! and claimed the second mandatory role would be a call site rather than a third copy of the
//! ladder. S135 is the first test of that claim, and it holds: this module calls the UNCHANGED
//! `mandate_gate` twice over — once for the tech-lead's own presence (`from_session: 0`, the S135
//! no-threshold decision), and once per `required` specialist to verify its handoff re-verifies.
//! The only NEW logic is what the S133 ladder never had: PARSING one verified handoff for the roles
//! it names, then verifying THOSE roles' handoffs. That is crew-gate-specific and lives here, not in
//! the shared ladder. `mandate_gate` / `parse_skip_marker` / `classify_marker_value` are untouched.
//!
//! # Phase 1 has NO off switch (DECISION-007 S135 addendum)
//!
//! The only two admissible verdicts are `required` and `deferred-budget`. Anything else —
//! `not-needed`, a bare skip, an empty reason — is REFUSED (`CrewRowDefect::UnknownVerdict`), and
//! the refusal names the all-nine observation (phase 1b) as the condition for earning the discretion
//! to mark a role not-needed. The two verdicts sit on different axes on purpose: `required` is a
//! need; `deferred-budget` is a MONEY fact carrying its own arithmetic, never a usefulness call.
//!
//! # The floor, stated out loud (the `mandate::MANDATE_FLOOR` precedent)
//!
//! `CREW_FLOOR`. The gate proves the tech-lead ran, recorded a verdict + budget for every
//! specialist, and that each required role produced a real handoff. It never proves the budget
//! arithmetic is correct, and never proves the crew it chose was the right crew. Whether a role
//! earns its keep is phase 1b's question, measured — never this gate's to assert.

use std::path::Path;

use crate::advice::{self, skip_fenced, strip_decoration, substantive_reason};
use crate::fleet;
use crate::mandate;

/// The honest ceiling of the crew gate, named once and reused by the gate, the CLI surface and the
/// session summary — the `mandate::MANDATE_FLOOR` / `advice::DODGE` precedent.
pub const CREW_FLOOR: &str = "this proves the tech-lead was really dispatched and recorded a verdict \
                              and a budget for every specialist, and that each REQUIRED role \
                              produced a real governed handoff — never that the budget arithmetic is \
                              correct, and never that the crew it chose was the right one";

/// The two admissible phase-1 verdicts. Phase 2 (the off switch — a `not-needed` verdict) is a
/// LATER session, unlocked only after the all-nine observation (phase 1b). A third variant added
/// here before that evidence exists would violate the recorded founder decision.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CrewKind {
    /// This task needs this role this session — it must produce a real governed handoff to close.
    Required,
    /// A MONEY fact: the account cannot afford this dispatch this session. Carries arithmetic in its
    /// reason, never a judgement that the role is not worth running.
    DeferredBudget,
}

impl CrewKind {
    pub fn word(&self) -> &'static str {
        match self {
            CrewKind::Required => "required",
            CrewKind::DeferredBudget => "deferred-budget",
        }
    }
}

/// One specialist role's line in the tech-lead's crew decision.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct CrewDecision {
    pub role: String,
    pub kind: CrewKind,
    /// The token allowance the tech-lead recorded — an INSTRUCTION the role is trusted to honour,
    /// never a cap Vajra can enforce mid-run (`--crew-cost` reports actual-against-this, to LEARN).
    pub budget_tokens: u64,
    pub reason: String,
}

/// Why a crew row is unusable — the DISCRIMINANT, so this crate's tests bind to behaviour instead of
/// to the sentences the CLI prints (the `mandate::SkipDefect` precedent, S133).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum CrewRowDefect {
    /// A verdict word that is neither `required` nor `deferred-budget`. THIS is the phase-1
    /// no-off-switch refusal — its message names phase 1b as the condition for earning more.
    UnknownVerdict(String),
    /// The reason failed `advice::substantive_reason` (empty, or a `<placeholder>`).
    NonSubstantiveReason(String),
    /// No numeric token budget in the budget field.
    MissingOrNonNumericBudget,
    /// A `crew <role>` line naming something that is not one of the nine specialist roles.
    UnknownRole(String),
    /// The row does not match the `crew <role> — <verdict> — budget: <N> — <reason>` grammar.
    Malformed,
}

/// The outcome of parsing a tech-lead handoff body for its crew decisions.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum CrewParse {
    /// A verdict + budget + reason for all nine specialists, none defective, none duplicated.
    Ok(Vec<CrewDecision>),
    /// A row was present but defective — carries which role/line and why.
    RowDefect(String, CrewRowDefect),
    /// A duplicate crew line for the same role.
    Duplicate(String),
    /// One or more specialists carry no crew line at all.
    MissingRoles(Vec<String>),
}

/// The nine specialist role names — every registered fleet role except the tech-lead itself, which
/// does not decide about its own dispatch. Derived from `fleet::ROLES`, so a future role added to
/// the fleet is a specialist the tech-lead must rule on with no edit here.
pub fn specialist_roles() -> Vec<&'static str> {
    fleet::ROLES
        .iter()
        .map(|r| r.name)
        .filter(|n| *n != "tech-lead")
        .collect()
}

/// Markdown's indented-code rule (four spaces or one tab), reused from the mandate marker parser: a
/// line inside an indented code block is an EXAMPLE of the grammar, never a real crew record.
fn is_indented_code(line: &str) -> bool {
    line.starts_with("    ") || line.starts_with('\t')
}

/// Parse ONE line as a crew row. `None` when the line is not a `crew …` record at all (prose, a
/// heading, a blank line); `Some(Ok/Err)` when it is one, valid or not.
///
/// Grammar: `crew <role> — <verdict> — budget: <N> tokens — <reason>`, four em/en-dash-separated
/// fields after the `crew` keyword. `—`/`–` are the field separator specifically (never plain `-`),
/// because `deferred-budget` carries a hyphen and splitting on `-` would tear it in half.
fn parse_crew_row(line: &str) -> Option<Result<CrewDecision, (String, CrewRowDefect)>> {
    let s = strip_decoration(line);
    let lower = s.to_ascii_lowercase();
    let rest = lower.strip_prefix("crew ")?;
    // Offsets stay valid: ASCII lower-casing preserves byte length.
    let rest = s[s.len() - rest.len()..].trim();

    let parts: Vec<&str> = rest.splitn(4, ['—', '–']).map(str::trim).collect();
    let role = parts[0].to_string();
    let is_specialist = specialist_roles().contains(&role.as_str());
    // A line is only a crew RECORD when its first field names a real specialist. A heading or prose
    // that merely begins with the word `crew` — `## Crew decision — session 135`, decoration- and
    // prefix-stripped to `decision — session 135` — names no specialist and is NOT a record, never a
    // malformed row that would falsely block. But a FULL four-field line naming a NON-specialist
    // (`crew architect …`, `crew tech-lead …` — a station name or a typo) IS a real attempt at a
    // role line, and is flagged as UnknownRole rather than ignored.
    if !is_specialist {
        if parts.len() == 4 && !role.is_empty() {
            return Some(Err((role.clone(), CrewRowDefect::UnknownRole(role))));
        }
        return None;
    }
    if parts.len() < 4 {
        return Some(Err((
            rest.chars().take(40).collect(),
            CrewRowDefect::Malformed,
        )));
    }
    // Verdict FIRST (before budget/reason): an inadmissible verdict is the phase-1 refusal, and it
    // must report as `UnknownVerdict` even when the row is also otherwise malformed.
    let kind = match parts[1].to_ascii_lowercase().as_str() {
        "required" => CrewKind::Required,
        "deferred-budget" => CrewKind::DeferredBudget,
        other => {
            return Some(Err((
                role,
                CrewRowDefect::UnknownVerdict(other.to_string()),
            )))
        }
    };
    let digits: String = parts[2].chars().filter(char::is_ascii_digit).collect();
    let Ok(budget_tokens) = digits.parse::<u64>() else {
        return Some(Err((role, CrewRowDefect::MissingOrNonNumericBudget)));
    };
    let reason = parts[3].to_string();
    if let Err(why) = substantive_reason(&reason) {
        return Some(Err((role, CrewRowDefect::NonSubstantiveReason(why))));
    }
    Some(Ok(CrewDecision {
        role,
        kind,
        budget_tokens,
        reason,
    }))
}

/// Parse a tech-lead handoff body into crew decisions. Requires a valid row for EVERY specialist,
/// no unknown verdicts, no duplicates. Fenced and indented-code lines are skipped (they teach the
/// grammar; they are not records) — the S127 lesson the mandate parser also carries.
pub fn parse_crew(body: &str) -> CrewParse {
    let mut decisions: Vec<CrewDecision> = vec![];
    for line in skip_fenced(body) {
        if is_indented_code(line) {
            continue;
        }
        match parse_crew_row(line) {
            None => continue,
            Some(Err((who, defect))) => return CrewParse::RowDefect(who, defect),
            Some(Ok(d)) => {
                if decisions.iter().any(|e| e.role == d.role) {
                    return CrewParse::Duplicate(d.role);
                }
                decisions.push(d);
            }
        }
    }
    let missing: Vec<String> = specialist_roles()
        .into_iter()
        .filter(|s| !decisions.iter().any(|d| &d.role == s))
        .map(str::to_string)
        .collect();
    if !missing.is_empty() {
        return CrewParse::MissingRoles(missing);
    }
    CrewParse::Ok(decisions)
}

/// WHY the crew gate blocked, as a value rather than a sentence (the `mandate::MandateCause`
/// precedent) — the gate's tests bind to these, not to the CLI's wording.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum CrewCause {
    /// No real, provenance-verified tech-lead handoff (delegated to `mandate_gate`'s ladder).
    TechLeadMissing,
    /// A `tech-lead: skipped — …` marker: refused. Phase 1 has no off switch, and the ONE role it
    /// forbids skipping is the tech-lead itself — the role that decides every other skip.
    TechLeadSkipped,
    /// The tech-lead handoff exists and re-verifies, but its body is not a usable crew decision.
    Unparseable(CrewParse),
    /// One or more `required` roles produced no real governed handoff.
    RequiredRoleMissing(Vec<String>),
}

/// The Crew gate's decision for CLOSING `session`.
#[derive(Debug, Clone)]
pub struct CrewVerdict {
    pub session: u32,
    /// The tech-lead handoff's repo-relative path, when a real one exists.
    pub handoff_path: Option<String>,
    /// The parsed crew decisions, when the handoff parsed cleanly — surfaced for `--check-crew`
    /// display and `--crew-cost` reconciliation.
    pub decisions: Vec<CrewDecision>,
    /// WHICH rung refused, as a value. `None` when nothing blocked.
    pub cause: Option<CrewCause>,
    blocked: bool,
    pub reasons: Vec<String>,
    pub warnings: Vec<String>,
}

impl CrewVerdict {
    pub fn blocked(&self) -> bool {
        self.blocked
    }
    /// The roles this crew marked `required`, in decision order.
    pub fn required_roles(&self) -> Vec<&str> {
        self.decisions
            .iter()
            .filter(|d| d.kind == CrewKind::Required)
            .map(|d| d.role.as_str())
            .collect()
    }
}

/// The Crew gate (S135). Reuses `mandate::mandate_gate` at TWO call sites and adds only the
/// handoff-parsing + required-role-verification the S133 ladder never had.
///
/// `from_session: 0` for the tech-lead's own presence is the S135 threshold decision (DECISION-007
/// S135 addendum): a brand-new role has no legacy prompts to exempt, so silence about it blocks at
/// every session in every project — the fix to the S134 brownfield hole, not a repeat of it.
pub fn crew_gate(root: &Path, session: u32) -> CrewVerdict {
    let tech_lead = fleet::resolve_role("tech-lead")
        .expect("tech-lead is a permanently registered fleet role (S135)");

    let mut v = CrewVerdict {
        session,
        handoff_path: None,
        decisions: vec![],
        cause: None,
        blocked: false,
        reasons: vec![],
        warnings: vec![],
    };

    // Call site 1 — the tech-lead's own presence, via the UNCHANGED generic ladder, no threshold.
    let tl = mandate::mandate_gate(root, tech_lead, session, 0);
    v.handoff_path = tl.handoff_path.clone();
    for w in &tl.warnings {
        v.warnings.push(w.clone());
    }
    if tl.blocked() {
        v.blocked = true;
        v.cause = Some(CrewCause::TechLeadMissing);
        v.reasons.push(format!(
            "session {session:02} records no real tech-lead handoff — the tech-lead is the FIRST \
             and MANDATORY dispatch of every session. Dispatch it and run `vajra next --role \
             tech-lead --from <crew>`. (No environment variable can satisfy or bypass this gate.)"
        ));
        for r in tl.reasons {
            v.reasons.push(format!("  (mandate ladder: {r})"));
        }
        return v;
    }
    // A recorded `tech-lead: skipped` passed the ladder on rung 3. The crew gate refuses it: the one
    // role phase 1 forbids skipping is the role that decides every other skip.
    if let Some(reason) = tl.skipped {
        v.blocked = true;
        v.cause = Some(CrewCause::TechLeadSkipped);
        v.reasons.push(format!(
            "session {session:02} recorded `tech-lead: skipped — {reason}` — the tech-lead cannot \
             be skipped. Phase 1 has NO off switch, and the role that decides which of the crew a \
             task needs is not itself optional. Dispatch it for real. (Earning the discretion to \
             run a smaller crew is phase 1b, the all-nine observation.)"
        ));
        return v;
    }

    // The tech-lead handoff re-verified. Read its body and parse the crew decision.
    let raw = match fleet::read_handoff(root, tech_lead, session) {
        fleet::HandoffRead::Found(h) => h.raw_body,
        // mandate_gate already passed, so this branch is unreachable in practice; fail closed if it
        // ever is not (a gate that cannot read its input FAILS — S69).
        other => {
            v.blocked = true;
            v.cause = Some(CrewCause::TechLeadMissing);
            v.reasons.push(format!(
                "session {session:02} tech-lead handoff could not be re-read after it verified \
                 ({other:?}) — failing closed"
            ));
            return v;
        }
    };

    match parse_crew(&raw) {
        CrewParse::Ok(decisions) => v.decisions = decisions,
        CrewParse::RowDefect(who, defect) => {
            v.blocked = true;
            v.reasons.push(row_defect_reason(&who, &defect));
            v.cause = Some(CrewCause::Unparseable(CrewParse::RowDefect(who, defect)));
            return v;
        }
        CrewParse::Duplicate(role) => {
            v.blocked = true;
            v.reasons.push(format!(
                "the tech-lead recorded two crew lines for `{role}` — record exactly one verdict \
                 per specialist"
            ));
            v.cause = Some(CrewCause::Unparseable(CrewParse::Duplicate(role)));
            return v;
        }
        CrewParse::MissingRoles(missing) => {
            v.blocked = true;
            v.reasons.push(format!(
                "the tech-lead must record a verdict for all nine specialists — missing: {}. Every \
                 role is either `required` or `deferred-budget`; none is silently skipped.",
                missing.join(", ")
            ));
            v.cause = Some(CrewCause::Unparseable(CrewParse::MissingRoles(missing)));
            return v;
        }
    }

    // Call site 2 — every `required` role must have produced its own real governed handoff. Reuse
    // the SAME ladder (rung 1/2 provenance, rung 5 silence), no threshold. A role marked required
    // for which the session recorded a SKIP instead of a dispatch does not satisfy this (skipped
    // passes the ladder on rung 3, but a required role's skip is a contradiction the crew gate
    // refuses).
    let mut missing_required = vec![];
    for name in v.required_roles() {
        let role = fleet::resolve_role(name)
            .expect("a parsed crew role is a registered specialist by construction");
        let sub = mandate::mandate_gate(root, role, session, 0);
        let has_real_handoff = !sub.blocked() && sub.skipped.is_none() && sub.handoff_path.is_some();
        if !has_real_handoff {
            missing_required.push(name.to_string());
        }
    }
    if !missing_required.is_empty() {
        v.blocked = true;
        v.cause = Some(CrewCause::RequiredRoleMissing(missing_required.clone()));
        v.reasons.push(format!(
            "the tech-lead marked these roles `required`, but they produced no real governed \
             handoff: {}. Dispatch each and run `vajra next --role <name> --from <findings>`, or \
             re-run the tech-lead to move a role it cannot afford to `deferred-budget` with the \
             arithmetic (never upgrade an un-dispatched role to a pass).",
            missing_required.join(", ")
        ));
    }
    v
}

/// One human sentence per row defect. Kept out of the gate body so the value-bound tests never read
/// message text; the UnknownVerdict message NAMES phase 1b (acceptance 3).
fn row_defect_reason(who: &str, defect: &CrewRowDefect) -> String {
    match defect {
        CrewRowDefect::UnknownVerdict(v) => format!(
            "the tech-lead recorded `{v}` for `{who}` — phase 1 admits ONLY `required` or \
             `deferred-budget`. `not-needed` and every other judgement about a role's worth are \
             phase 2, earned only after the all-nine observation (phase 1b); you cannot mark a role \
             not-needed you have never watched work."
        ),
        CrewRowDefect::NonSubstantiveReason(why) => format!(
            "the tech-lead's crew line for `{who}` records no substantive reason: {why}"
        ),
        CrewRowDefect::MissingOrNonNumericBudget => format!(
            "the tech-lead's crew line for `{who}` records no numeric token budget — the grammar is \
             `crew {who} — <verdict> — budget: <N> tokens — <reason>`"
        ),
        CrewRowDefect::UnknownRole(r) => format!(
            "`crew {r}` names something that is not one of the nine specialist roles: {}",
            specialist_roles().join(", ")
        ),
        CrewRowDefect::Malformed => format!(
            "`crew {who}…` does not match the grammar `crew <role> — <verdict> — budget: <N> \
             tokens — <reason>` (four em-dash-separated fields)"
        ),
    }
}

/// Re-exported so the CLI surface and the summary quote ONE sentence about what the crew gate does
/// and does not prove — the `mandate::advice_note` precedent.
pub fn advice_note() -> &'static str {
    advice::DODGE
}

// ---------------------------------------------------------------------------
// The crew COST reader (S135, acceptance 6/7). Reads REAL bytes — a dispatched subagent's on-disk
// transcript — and reports its RAW token total (input + output + cache reads + cache writes), the
// number S134 got wrong by ~45× by publishing NEW tokens only. It REPORTS to LEARN; the budget is
// an instruction, so nothing here blocks. But the READING is honest (S69): a transcript that should
// exist and does not is an Err, never a silent zero.
// ---------------------------------------------------------------------------

/// The RAW token total of ONE subagent transcript's text: every turn's
/// `input + output + cache_read + cache_creation`, summed. This is the figure S134 needed and
/// under-reported — 17.5M of its 19.2M was cache reads, which a new-tokens-only count drops. Pure,
/// so it is testable against S134's recorded per-dispatch figures with no filesystem.
pub fn raw_tokens(jsonl_text: &str) -> u64 {
    let mut total: u64 = 0;
    for line in jsonl_text.lines() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }
        let Ok(parsed) = serde_json::from_str::<serde_json::Value>(line) else {
            continue;
        };
        let usage = &parsed["message"]["usage"];
        if !usage.is_object() {
            continue;
        }
        let u = |k: &str| usage[k].as_u64().unwrap_or(0);
        total += u("input_tokens") + u("output_tokens") + u("cache_read_input_tokens");
        // cache creation: the flat field when present, else the ephemeral tiers (same shape
        // `src/meter` folds).
        let cc = usage["cache_creation_input_tokens"].as_u64();
        total += cc.unwrap_or_else(|| {
            let obj = &usage["cache_creation"];
            obj["ephemeral_5m_input_tokens"].as_u64().unwrap_or(0)
                + obj["ephemeral_1h_input_tokens"].as_u64().unwrap_or(0)
        });
    }
    total
}

/// Read ONE dispatch transcript's raw token total off disk. `Err` when the file cannot be read — a
/// transcript that should exist and does not FAILS rather than silently counting zero (S69). The
/// caller reports the Err as an unreadable line, never dropping it from the tally.
pub fn read_dispatch_raw_tokens(path: &Path) -> Result<u64, String> {
    let text = std::fs::read_to_string(path)
        .map_err(|e| format!("{}: {e}", path.display()))?;
    Ok(raw_tokens(&text))
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;
    use std::path::PathBuf;

    fn uniq() -> u64 {
        use std::sync::atomic::{AtomicU64, Ordering};
        static N: AtomicU64 = AtomicU64::new(0);
        N.fetch_add(1, Ordering::Relaxed)
    }

    fn tmp_root() -> PathBuf {
        let dir = std::env::temp_dir().join(format!("vajra-crew-test-{}-{}", std::process::id(), uniq()));
        fs::create_dir_all(dir.join(".ai/handoffs")).unwrap();
        fs::create_dir_all(dir.join("prompts")).unwrap();
        dir
    }

    /// A full, valid crew body covering all nine specialists — the fixture the happy-path and the
    /// required-role tests build on.
    fn full_crew_body(required: &[&str]) -> String {
        let mut s = String::from("## Crew decision\n\n");
        for name in specialist_roles() {
            if required.contains(&name) {
                s.push_str(&format!(
                    "crew {name} — required — budget: 300000 tokens — this task needs it\n"
                ));
            } else {
                s.push_str(&format!(
                    "crew {name} — deferred-budget — budget: 300000 tokens — S134 cost ~6M/dispatch; \
                     a $20/mo plan hit the cap at 19.2M, so this waits for phase 1b\n"
                ));
            }
        }
        s
    }

    // --- the grammar ---------------------------------------------------------------------------

    #[test]
    fn a_valid_row_parses_both_verdicts() {
        let r = parse_crew_row("crew researcher — required — budget: 500000 tokens — needs prior art");
        assert_eq!(
            r,
            Some(Ok(CrewDecision {
                role: "researcher".into(),
                kind: CrewKind::Required,
                budget_tokens: 500000,
                reason: "needs prior art".into(),
            }))
        );
        let d = parse_crew_row(
            "crew demo-producer — deferred-budget — budget: 250000 tokens — cannot afford it this session",
        )
        .unwrap()
        .unwrap();
        assert_eq!(d.kind, CrewKind::DeferredBudget);
        assert_eq!(d.budget_tokens, 250000);
    }

    #[test]
    fn decoration_and_a_comma_budget_do_not_change_the_reading() {
        for line in [
            "- crew researcher — required — budget: 1,500,000 tokens — pure need",
            "* **crew researcher — required — budget: 1500000 tokens — pure need**",
        ] {
            let d = parse_crew_row(line).unwrap().unwrap();
            assert_eq!(d.budget_tokens, 1_500_000, "{line:?}");
            assert_eq!(d.role, "researcher");
        }
    }

    #[test]
    fn a_non_crew_line_is_not_a_row() {
        assert_eq!(parse_crew_row("We considered the crew here."), None);
        assert_eq!(parse_crew_row("## Crew decision"), None);
        assert_eq!(parse_crew_row(""), None);
    }

    // Acceptance 3 (no off switch) — bound to the DEFECT VALUE, never the message text (S133).
    #[test]
    fn an_inadmissible_verdict_is_refused_by_value() {
        for bad in ["not-needed", "skip", "optional", "maybe"] {
            let r = parse_crew_row(&format!(
                "crew researcher — {bad} — budget: 100000 tokens — whatever"
            ));
            assert!(
                matches!(r, Some(Err((_, CrewRowDefect::UnknownVerdict(_))))),
                "{bad:?} -> {r:?}"
            );
        }
    }

    #[test]
    fn a_placeholder_reason_is_non_substantive() {
        let r = parse_crew_row(
            "crew researcher — required — budget: 100000 tokens — <why this task needs it>",
        );
        assert!(matches!(
            r,
            Some(Err((_, CrewRowDefect::NonSubstantiveReason(_))))
        ));
    }

    #[test]
    fn a_missing_or_non_numeric_budget_is_a_defect() {
        let r = parse_crew_row("crew researcher — required — budget: none yet — a reason");
        assert!(matches!(
            r,
            Some(Err((_, CrewRowDefect::MissingOrNonNumericBudget)))
        ));
    }

    #[test]
    fn an_unknown_role_is_refused() {
        let r = parse_crew_row("crew architect — required — budget: 100000 tokens — a reason");
        assert!(matches!(r, Some(Err((_, CrewRowDefect::UnknownRole(_))))));
        // The tech-lead does not decide about itself.
        let r = parse_crew_row("crew tech-lead — required — budget: 100000 tokens — a reason");
        assert!(matches!(r, Some(Err((_, CrewRowDefect::UnknownRole(_))))));
    }

    #[test]
    fn too_few_fields_is_malformed() {
        let r = parse_crew_row("crew researcher — required — a reason with no budget field");
        assert!(matches!(r, Some(Err((_, CrewRowDefect::Malformed)))));
    }

    #[test]
    fn a_fenced_or_indented_example_is_not_a_record() {
        let body = "## Crew\n\n```\ncrew researcher — required — budget: 1 tokens — EXAMPLE\n```\n\
                    \n    crew demo-producer — required — budget: 1 tokens — INDENTED EXAMPLE\n";
        // Neither example counts, so all nine are missing.
        assert!(matches!(parse_crew(body), CrewParse::MissingRoles(_)));
    }

    #[test]
    fn parse_crew_requires_all_nine_and_rejects_duplicates() {
        // Missing everything.
        assert!(matches!(parse_crew("no crew here"), CrewParse::MissingRoles(m) if m.len() == 9));
        // A full valid body parses.
        assert!(matches!(parse_crew(&full_crew_body(&["researcher"])), CrewParse::Ok(_)));
        // A duplicate blocks.
        let dup = format!(
            "{}crew researcher — required — budget: 1 tokens — twice\n",
            full_crew_body(&["researcher"])
        );
        assert!(matches!(parse_crew(&dup), CrewParse::Duplicate(r) if r == "researcher"));
    }

    #[test]
    fn specialist_roles_are_the_nine_not_the_tech_lead() {
        let s = specialist_roles();
        assert_eq!(s.len(), 9);
        assert!(!s.contains(&"tech-lead"));
        assert!(s.contains(&"design-advisor"));
    }

    // --- the gate ------------------------------------------------------------------------------

    fn write_prompt(root: &Path, session: u32, body: &str) {
        fs::write(root.join(format!("prompts/{session:02}-task-fixture.md")), body).unwrap();
    }

    /// Write a handoff for `role` with a given provenance label and body. Real re-verification needs
    /// on-disk dispatch evidence, so gate tests that need a PASS point `VAJRA_CLAUDE_PROJECTS_DIR` at
    /// a fixture — but most gate tests here assert BLOCKS, which need no such evidence.
    fn write_handoff(root: &Path, role_name: &str, session: u32, agent: &str, body: &str) {
        let role = fleet::resolve_role(role_name).unwrap();
        let handoff = fleet::format_handoff(
            role,
            session,
            agent,
            "deadbeef",
            "2026-08-27T00:00:00Z",
            None,
            body,
            "- `+` new: fixture handoff",
        );
        fs::write(root.join(role.handoff_rel(session)), handoff).unwrap();
    }

    #[test]
    fn no_tech_lead_handoff_blocks_at_any_session() {
        let root = tmp_root();
        write_prompt(&root, 135, "# fixture\n");
        let v = crew_gate(&root, 135);
        assert!(v.blocked());
        assert_eq!(v.cause, Some(CrewCause::TechLeadMissing));
    }

    // The S135 threshold decision, proven: NO exemption below any session number — a session 5
    // with no tech-lead handoff blocks exactly like a session 500. This is the fix to the S134
    // brownfield hole (a brand-new role has no legacy prompts to exempt).
    #[test]
    fn there_is_no_brownfield_exemption_for_the_tech_lead() {
        for session in [1u32, 5, 40, 135] {
            let root = tmp_root();
            write_prompt(&root, session, "# fixture\n");
            let v = crew_gate(&root, session);
            assert!(v.blocked(), "session {session} must block — the crew gate has no threshold");
            assert_eq!(v.cause, Some(CrewCause::TechLeadMissing));
        }
    }

    // A hand-typed tech-lead handoff (no verifiable dispatch id) does not satisfy the gate — the
    // provenance rung of the shared ladder, reused.
    #[test]
    fn a_hand_typed_tech_lead_handoff_blocks() {
        let root = tmp_root();
        write_prompt(&root, 135, "# fixture\n");
        write_handoff(&root, "tech-lead", 135, "claude-code-subagent", &full_crew_body(&[]));
        let v = crew_gate(&root, 135);
        assert!(v.blocked(), "unverifiable provenance must block");
        assert_eq!(v.cause, Some(CrewCause::TechLeadMissing));
    }

    // A recorded `tech-lead: skipped` is refused — the one role phase 1 forbids skipping.
    #[test]
    fn a_skipped_tech_lead_is_refused_not_passed() {
        let root = tmp_root();
        write_prompt(
            &root,
            135,
            "# fixture\n- tech-lead: skipped — I decided the crew myself\n",
        );
        let v = crew_gate(&root, 135);
        assert!(v.blocked());
        assert_eq!(v.cause, Some(CrewCause::TechLeadSkipped));
    }

    // --- the cost reader (acceptance 6) --------------------------------------------------------

    /// A subagent turn line with the four token fields — the shape Claude Code writes to
    /// `agent-<id>.jsonl` and `src/meter` folds.
    fn turn(input: u64, output: u64, cache_read: u64, cache_create: u64) -> String {
        format!(
            r#"{{"type":"assistant","message":{{"model":"claude-opus-4-8","usage":{{"input_tokens":{input},"output_tokens":{output},"cache_read_input_tokens":{cache_read},"cache_creation_input_tokens":{cache_create}}}}}}}"#
        )
    }

    // The load-bearing reconciliation: the reader returns S134's exact recorded per-dispatch raw
    // totals, summed across turns — the figure S134 published wrong by ~45× (it dropped cache
    // reads). Cache reads dominate here, exactly as they did live (17.5M of 19.2M).
    #[test]
    fn raw_tokens_reconciles_with_s134_recorded_figures() {
        // design-advisor: 4,928,036
        let da = [
            turn(1_000_000, 0, 3_000_000, 0),
            turn(28_036, 0, 900_000, 0),
        ]
        .join("\n");
        assert_eq!(raw_tokens(&da), 4_928_036);
        // fidelity-reviewer: 6,152,671 — exercises output + cache_creation too.
        let fr = [
            turn(2_000_000, 100_000, 3_900_000, 0),
            turn(52_671, 0, 0, 100_000),
        ]
        .join("\n");
        assert_eq!(raw_tokens(&fr), 6_152_671);
        // implementation-advisor: 8,111,990
        let ia = [
            turn(4_000_000, 0, 4_100_000, 0),
            turn(11_990, 0, 0, 0),
        ]
        .join("\n");
        assert_eq!(raw_tokens(&ia), 8_111_990);
        // And the three together are S134's headline raw total, never the 421,739 new-tokens figure.
        assert_eq!(
            raw_tokens(&da) + raw_tokens(&fr) + raw_tokens(&ia),
            19_192_697
        );
    }

    #[test]
    fn a_missing_transcript_fails_rather_than_counts_zero() {
        let root = tmp_root();
        let missing = root.join(".ai/handoffs/does-not-exist.jsonl");
        assert!(read_dispatch_raw_tokens(&missing).is_err());
        // A present one reads its real total.
        let f = root.join("t.jsonl");
        fs::write(&f, turn(10, 20, 30, 40)).unwrap();
        assert_eq!(read_dispatch_raw_tokens(&f).unwrap(), 100);
    }

    #[test]
    fn cache_creation_falls_back_to_the_ephemeral_tiers() {
        let line = r#"{"message":{"usage":{"input_tokens":1,"output_tokens":2,"cache_read_input_tokens":3,"cache_creation":{"ephemeral_5m_input_tokens":4,"ephemeral_1h_input_tokens":5}}}}"#;
        assert_eq!(raw_tokens(line), 1 + 2 + 3 + 4 + 5);
    }
}
