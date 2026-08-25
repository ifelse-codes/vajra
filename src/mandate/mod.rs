//! The Mandate gate (S133) — a fleet role that MUST be consulted before a session closes, with a
//! RECORDED, substantive, visible reason as the only way past it.
//!
//! S131 made `fidelity-reviewer` mandatory (`src/fidelity/mod.rs`). It is a cop: it grades finished
//! work at the END. The advisors that could change what gets BUILT stayed optional, and optional
//! loses to time pressure — measured live at the S132 closeout: 18 governed handoffs across 132
//! sessions, `design-advisor` used exactly ONCE (`.ai/ROADMAP.md` F2d). The two most expensive
//! discoveries of S131 and S132 were both DESIGN holes found by a cold reader after the code was
//! written. The founder's call: make the build-shaping advisors mandatory, "and if we want to skip
//! we have to skip with a valid reason."
//!
//! **Named for the MECHANISM, not the role.** `design_advisor_gate` is one call site; S134's
//! `implementation-advisor` is another. The ladder below is written once, generic over a
//! `fleet::Role`, so the second mandatory advisor is a table entry and not a third copy of it
//! (`.ai/ROADMAP.md` F2e records the remaining duplication against `src/fidelity/mod.rs`, which
//! S133 deliberately left untouched — acceptance 7 required S131's gate unchanged).
//!
//! # The precedence ladder — decided, not fallen out of the code
//!
//! | # | Situation | Outcome |
//! |---|---|---|
//! | 1 | handoff exists but is malformed, or its provenance does not re-verify | **BLOCK at any session, even with a recorded reason** |
//! | 2 | handoff exists and its provenance independently re-verifies | PASS (WARN if a skip reason is also recorded) |
//! | 3 | no handoff + a substantive recorded reason | **PASS, and PRINT the reason** |
//! | 4 | no handoff + a marker that records no usable reason | **BLOCK at any session** |
//! | 5 | no handoff + no marker + session ≥ threshold | **BLOCK**, naming both ways to satisfy it |
//! | 6 | no handoff + no marker + session < threshold | WARN, naming the exemption |
//!
//! Rung 1 beating rung 3 is the one genuine conflict in the S133 contract (its acceptance 2 vs its
//! acceptance 4), and it is resolved here on purpose: a forged claim is not cured by a sentence.
//!
//! # Why there is no `VAJRA_SKIP_DESIGN_ADVISOR_GATE`
//!
//! Every other gate wired into `--advance` carries one, and that symmetry is exactly the pull this
//! gate refuses. Its whole novelty is that its escape hatch leaves a trace a reader can find months
//! later. Ship both and the recorded reason becomes the honest person's path while the traceless
//! one stays open for everyone else. Two limits recorded rather than implied: `VAJRA_CLOSEOUT_WAIVER`
//! still waives the closeout check (founder-held, session-scoped, un-forgeable BY THE AGENT — a
//! different animal from an agent-settable flag), and L1 maturity still advises rather than blocks.
//!
//! # The floor, stated out loud
//!
//! `MANDATE_FLOOR`. The gate checks a reason was WRITTEN. Nothing here judges whether it is a good
//! one, and nothing here proves the advice reached the design — see `sessions/session-133-summary.md`.

use std::path::Path;

use crate::advice::{self, skip_fenced, strip_decoration, substantive_reason, SEPARATORS};
use crate::analyst::find_prompt_for;
use crate::architect::{self, Significance};
use crate::dispatch;
use crate::fleet::{self, HandoffRead, Role};

/// The honest ceiling of the reasoned skip, named once and reused by the gate, the CLI surface and
/// the session summary — the `advice::DODGE` / `obeyed::CEILING` precedent. Three retyped copies
/// become three different admissions of the same limit.
pub const MANDATE_FLOOR: &str = "this proves a reason was WRITTEN and, when a handoff is used, that \
                                 its dispatch really happened — never that the reason is a good one, \
                                 and never that the advice reached the design";

/// Migration threshold for the `design-advisor` mandate (S133), governing SILENCE ONLY — the S132
/// precedent (`obeyed::OBEYED_JUDGMENT_FROM_SESSION`). A marker that EXISTS but records no usable
/// reason BLOCKS at session 42; a handoff that exists but does not re-verify BLOCKS at session 100.
/// Only the absence of BOTH is exempt below this number, and the exemption is announced in a WARN
/// rather than passing silently.
///
/// Honest limit of a session-NUMBER threshold, and how S133 closes it: in a freshly `vajra init`ed
/// project, sessions 1..132 would all sit below this number, so a "mandatory" gate would do nothing
/// for 132 sessions. The scaffolded prompt therefore emits the marker as a template placeholder,
/// which lands on rung 4 and BLOCKS. Number-based exemption for legacy prompts, marker-based
/// enforcement for everything scaffolded.
pub const DESIGN_ADVISOR_MANDATE_FROM_SESSION: u32 = 133;

/// What a session's own prompt records about skipping a mandatory role.
///
/// The grammar is `<role-name>: skipped — <reason>`, keyed on the ROLE NAME rather than a
/// design-specific literal, so S134's `implementation-advisor: skipped — <reason>` inherits this
/// parser with no new grammar. `prompts/` IS this repo's memory (the S53 rule) and the prompt is
/// what `Review-Inputs-SHA` already hashes, so a reason recorded here sits inside the tamper-evident
/// record — which a `.ai/skips.md` sidecar would not.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum SkipMarker {
    /// No `<role-name>:` line anywhere in the prompt (outside fenced blocks).
    Absent,
    /// A `<role-name>:` line EXISTS but records no usable reason. Carries a machine-readable
    /// defect AND the human sentence. Blocks at any session: the threshold governs silence, and a
    /// marker that exists is not silence.
    Unusable(SkipDefect, String),
    /// `<role-name>: skipped — <substantive reason>`. Carries the reason, which the gate PRINTS.
    Recorded(String),
}

/// Why a recorded marker is unusable — the DISCRIMINANT, so this crate's own tests bind to
/// behaviour instead of to message text.
///
/// This is not decoration. S122's falsifiability contract has two directions: bypassing a rule
/// must go RED, and RENAMING every message must stay GREEN. A test that asserts
/// `reasons[0].contains("template placeholder")` fails the second direction for the wrong reason,
/// so the wording contract is asserted where it belongs — live, against the real binary's output,
/// in `scripts/verify-session-133.sh` — and the unit tests assert the variant.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum SkipDefect {
    /// Nothing after the colon.
    Empty,
    /// Still the angle-bracketed template, either whole or as the reason (the scaffold's shape).
    Placeholder,
    /// A value that is not a skip claim at all (`done`, `yes`, `consulted`).
    NotASkip,
    /// The word `skipped` with no reason after it.
    NoReason,
}

/// Why the gate blocked. Same purpose as `SkipDefect`: the ladder's rungs are behaviour, and the
/// tests bind to them rather than to the sentences the CLI prints.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum MandateCause {
    /// Rung 1 — a handoff exists but fails the DECISION-007 handoff contract.
    HandoffMalformed,
    /// Rung 1 — a handoff exists but its `agent:` field carries no derivable dispatch id.
    ProvenanceMissingId,
    /// Rung 1 — a handoff exists but its claimed dispatch does not independently re-verify.
    ProvenanceUnverifiable,
    /// Rung 4 — no handoff, and the recorded marker is unusable.
    SkipUnusable(SkipDefect),
    /// Rung 5 — no handoff, no marker, at or after the threshold.
    Silence,
}

/// The Mandate gate's decision for CLOSING `session`. Mirrors `fidelity::FidelityVerdict` field for
/// field where they overlap, plus `skipped` — the reason a passing-by-skip session must show.
#[derive(Debug, Clone)]
pub struct MandateVerdict {
    pub session: u32,
    /// The mandated role's name (`design-advisor`).
    pub role: &'static str,
    /// The session's prompt (repo-relative), when one was found.
    pub prompt_path: Option<String>,
    /// The handoff's repo-relative path, when one exists (however malformed).
    pub handoff_path: Option<String>,
    /// The `agent:` provenance field of a valid handoff — surfaced so a human sees exactly what
    /// claim the gate did or did not accept.
    pub agent_field: Option<String>,
    /// `Some(reason)` when the gate passed on a RECORDED skip rather than a handoff. The CLI must
    /// print this: acceptance 2 forbids a skipped design review reading as a clean green.
    pub skipped: Option<String>,
    /// WHICH rung refused, as a value rather than as a sentence. `None` when nothing blocked.
    pub cause: Option<MandateCause>,
    blocked: bool,
    /// Blocking reasons — non-empty means L2/L3 must refuse the close.
    pub reasons: Vec<String>,
    pub warnings: Vec<String>,
}

impl MandateVerdict {
    pub fn blocked(&self) -> bool {
        self.blocked
    }

    /// The one-line, unmissable rendering of a skipped review. Defined once so the gate output, the
    /// `--advance` wiring and any script grep the same string.
    pub fn skip_line(&self) -> Option<String> {
        self.skipped
            .as_ref()
            .map(|r| format!("{} review SKIPPED — {r}", self.role))
    }
}

/// Split `text` at one leading separator and return the trimmed remainder. Local to the marker
/// grammar (`advice::after_separator` is private to that module's own `rec N —` parsing), reusing
/// the same separator set so `—`, `–`, `-` and `:` all read alike.
fn after_separator(text: &str) -> Option<&str> {
    SEPARATORS
        .iter()
        .find_map(|sep| text.strip_prefix(*sep))
        .map(str::trim)
        .filter(|t| !t.is_empty())
}

/// Classify the value recorded after `<role-name>:`.
fn classify_marker_value(role: &str, value: &str) -> SkipMarker {
    let v = value.trim();
    if v.is_empty() {
        return SkipMarker::Unusable(
            SkipDefect::Empty,
            format!(
                "`{role}:` records nothing after the colon — the grammar is \
                 `{role}: skipped — <reason>`"
            ),
        );
    }
    // The scaffolded placeholder lands here: an angle-bracketed template is a marker that EXISTS
    // and records nothing, which is rung 4, not rung 6. That is what makes the mandate bind from
    // session 1 in a fresh project despite the session-number threshold.
    if v.starts_with('<') && v.ends_with('>') {
        return SkipMarker::Unusable(
            SkipDefect::Placeholder,
            format!(
                "`{role}: {v}` is still the template placeholder — dispatch the role, or replace \
                 it with `{role}: skipped — <a real reason>`"
            ),
        );
    }
    let lower = v.to_ascii_lowercase();
    let Some(rest) = lower.strip_prefix("skipped") else {
        return SkipMarker::Unusable(
            SkipDefect::NotASkip,
            format!(
                "`{role}: {v}` is not a recorded skip — the only value this gate accepts is \
                 `skipped — <reason>` (a role that really ran is recorded as a handoff, not as a \
                 marker)"
            ),
        );
    };
    // Offsets stay valid: ASCII lower-casing preserves byte length.
    let rest = v[v.len() - rest.len()..].trim();
    let Some(reason) = after_separator(rest) else {
        return SkipMarker::Unusable(
            SkipDefect::NoReason,
            format!(
                "`{role}: {v}` records the word `skipped` with no reason after it — a skip must \
                 cost a sentence"
            ),
        );
    };
    match substantive_reason(reason) {
        Ok(()) => SkipMarker::Recorded(reason.to_string()),
        // A reason that is still `<...>` is the same defect as a whole-value placeholder — the
        // scaffold's shape, one level in.
        Err(why) => SkipMarker::Unusable(
            SkipDefect::Placeholder,
            format!("`{role}:` skip reason is not substantive: {why}"),
        ),
    }
}

/// Read the FIRST `<role-name>: …` marker line a prompt records, outside fenced blocks.
///
/// Line-anchored after `advice::strip_decoration`, so a mid-sentence mention of the role never
/// counts — the same anchoring that keeps the word "rec" in prose from becoming a `rec N` marker.
/// Fenced blocks are skipped via `advice::skip_fenced` because S127 shipped exactly that bug: a
/// fenced EXAMPLE was mistaken for the real record. This session's own prompt, the role definition
/// and the scaffold all quote this grammar inside fences.
///
/// Deliberately NOT scoped to the `## Design` section. `## Design` is where the grammar is TAUGHT,
/// but a formatting slip should not turn into a false BLOCK — the fail direction that matters is
/// "the reason is on the record". Disclosed cost: a prompt that quotes another session's skip line
/// at line-start, outside a fence, would satisfy the gate.
pub fn parse_skip_marker(prompt: &str, role: &str) -> SkipMarker {
    for line in skip_fenced(prompt) {
        let s = strip_decoration(line);
        let lower = s.to_ascii_lowercase();
        let Some(rest) = lower.strip_prefix(role) else {
            continue;
        };
        let Some(value) = rest.strip_prefix(':') else {
            continue;
        };
        // Offsets stay valid: ASCII lower-casing preserves byte length.
        let value = &s[s.len() - value.len()..];
        return classify_marker_value(role, value);
    }
    SkipMarker::Absent
}

/// The Mandate gate (S133), generic over the role it makes mandatory. Walks the ladder in the
/// module header, in that order.
///
/// `from_session` is the migration threshold and governs SILENCE only: it is consulted on exactly
/// one rung (6), never to excuse a marker or a handoff that EXISTS.
pub fn mandate_gate(
    root: &Path,
    role: &'static Role,
    session: u32,
    from_session: u32,
) -> MandateVerdict {
    let prompt_path = find_prompt_for(root, session);
    let prompt_text = prompt_path
        .as_ref()
        .and_then(|p| std::fs::read_to_string(root.join(p)).ok());
    let marker = prompt_text
        .as_deref()
        .map(|t| parse_skip_marker(t, role.name))
        .unwrap_or(SkipMarker::Absent);

    let mut v = MandateVerdict {
        session,
        role: role.name,
        prompt_path: prompt_path.clone(),
        handoff_path: None,
        agent_field: None,
        skipped: None,
        cause: None,
        blocked: false,
        reasons: vec![],
        warnings: vec![],
    };
    if prompt_path.is_none() {
        v.warnings.push(format!(
            "no prompt found for session {session:02} — a recorded skip reason has nowhere to live, \
             so only a real {} handoff can satisfy this gate",
            role.name
        ));
    }

    match fleet::read_handoff(root, role, session) {
        // Rung 1 — a handoff that exists but cannot be read is NOT the same as no handoff. A gate
        // that cannot evaluate its input FAILS (S69), and a recorded reason does not cure it.
        HandoffRead::Malformed(path, why) => {
            v.handoff_path = Some(path.clone());
            v.blocked = true;
            v.cause = Some(MandateCause::HandoffMalformed);
            v.reasons.push(format!(
                "{path} exists but does not satisfy the handoff contract ({why}) — delete it and \
                 record the skip, or dispatch {} for real; a recorded reason does not cure a \
                 broken handoff",
                role.name
            ));
        }
        HandoffRead::Found(h) => {
            v.handoff_path = Some(h.path.clone());
            v.agent_field = Some(h.agent.clone());
            match dispatch::claimed_tool_use_id(&h.agent) {
                // Rung 1 — a hand-typed handoff is not fleet evidence (S131's rule, reused).
                None => {
                    v.blocked = true;
                    v.cause = Some(MandateCause::ProvenanceMissingId);
                    v.reasons.push(format!(
                        "{}'s provenance ({:?}) carries no verifiable dispatch id — a hand-typed \
                         or pre-S131 handoff does not satisfy a mandatory role, and a recorded \
                         reason does not cure it",
                        h.path, h.agent
                    ));
                }
                Some(id) => match dispatch::reverify(root, role.name, session, &id) {
                    // Rung 2 — the only way to pass WITH a handoff.
                    Ok(()) => {
                        if let SkipMarker::Recorded(reason) = &marker {
                            v.warnings.push(format!(
                                "session {session:02} records BOTH a real {} handoff and a skip \
                                 reason ({reason:?}) — the handoff wins; delete the stale marker",
                                role.name
                            ));
                        }
                    }
                    // Rung 1 — a claim this gate cannot re-derive is treated as invalid, never
                    // trusted, and never downgraded to "absent" so a marker could rescue it.
                    Err(why) => {
                        v.blocked = true;
                        v.cause = Some(MandateCause::ProvenanceUnverifiable);
                        v.reasons.push(format!(
                            "{}'s provenance could not be independently re-verified: {why} — a \
                             claim this gate cannot re-derive is invalid, and a recorded reason \
                             does not cure it",
                            h.path
                        ));
                    }
                },
            }
        }
        HandoffRead::Absent => match &marker {
            // Rung 3 — the reasoned skip. Passes, and the reason is carried out so the CLI can
            // PRINT it: a skipped review must never read as a clean green (acceptance 2).
            SkipMarker::Recorded(reason) => {
                v.skipped = Some(reason.clone());
                // rec 9: the single most suspicious combination in this design — a session that
                // calls its own work design-significant and then skips the design review. It
                // passes (the founder's "a reasoned skip is always possible"), loudly.
                if let Some(t) = prompt_text.as_deref() {
                    if matches!(architect::design_significance(t), Significance::Yes(_)) {
                        v.warnings.push(format!(
                            "session {session:02} records `design-significant: yes` AND skipped \
                             the {} review — the contradiction is allowed, not hidden",
                            role.name
                        ));
                    }
                }
            }
            // Rung 4 — a marker that exists but records nothing usable. Blocks at ANY session:
            // the threshold governs silence, and a placeholder is not silence.
            SkipMarker::Unusable(defect, why) => {
                v.blocked = true;
                v.cause = Some(MandateCause::SkipUnusable(*defect));
                v.reasons.push(format!(
                    "session {session:02} has no {} handoff and its recorded skip is unusable: \
                     {why}",
                    role.name
                ));
            }
            SkipMarker::Absent => {
                let how = format!(
                    "dispatch the role and run `vajra next --role {} --from <findings>`, or record \
                     `{}: skipped — <reason>` in {} (no environment variable can satisfy or bypass \
                     this gate)",
                    role.name,
                    role.name,
                    prompt_path.as_deref().unwrap_or("the session's prompt"),
                );
                if session >= from_session {
                    // Rung 5 — the silence the whole session exists to end.
                    v.blocked = true;
                    v.cause = Some(MandateCause::Silence);
                    v.reasons.push(format!(
                        "session {session:02} records neither a {} handoff ({}) nor a reason for \
                         skipping it — {how}",
                        role.name,
                        role.handoff_rel(session),
                    ));
                } else {
                    // Rung 6 — the migration exemption, named out loud rather than silent.
                    v.warnings.push(format!(
                        "session {session:02} predates the {} mandate (threshold {from_session}) — \
                         silence is exempt below it, and only below it. To satisfy it anyway: {how}",
                        role.name,
                    ));
                }
            }
        },
    }
    v
}

/// The S133 call site: `design-advisor` is the fleet's SECOND mandatory role.
pub fn design_advisor_gate(root: &Path, session: u32) -> MandateVerdict {
    let role = fleet::resolve_role("design-advisor")
        .expect("design-advisor is a permanently registered fleet role");
    mandate_gate(root, role, session, DESIGN_ADVISOR_MANDATE_FROM_SESSION)
}

/// Re-exported so the CLI surface and the summary quote ONE sentence about what the Advice gate
/// does and does not add on top of this one.
pub fn advice_note() -> &'static str {
    advice::DODGE
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    fn uniq() -> u64 {
        use std::sync::atomic::{AtomicU64, Ordering};
        static N: AtomicU64 = AtomicU64::new(0);
        N.fetch_add(1, Ordering::Relaxed)
    }

    fn tmp_root() -> std::path::PathBuf {
        let dir = std::env::temp_dir().join(format!(
            "vajra-mandate-test-{}-{}",
            std::process::id(),
            uniq()
        ));
        fs::create_dir_all(dir.join(".ai/handoffs")).unwrap();
        fs::create_dir_all(dir.join("prompts")).unwrap();
        dir
    }

    fn write_prompt(root: &Path, session: u32, body: &str) {
        fs::write(
            root.join(format!("prompts/{session:02}-task-fixture.md")),
            body,
        )
        .unwrap();
    }

    fn write_handoff(root: &Path, session: u32, agent: &str) {
        let role = fleet::resolve_role("design-advisor").unwrap();
        let handoff = fleet::format_handoff(
            role,
            session,
            agent,
            "deadbeef",
            "2026-08-25T00:00:00Z",
            None,
            "## Findings\nrec 1 — an example finding\n",
            "- `+` new: first design-advisor handoff for this session (test fixture)",
        );
        fs::write(root.join(role.handoff_rel(session)), handoff).unwrap();
    }

    // --- the marker grammar -------------------------------------------------------------------

    #[test]
    fn a_substantive_skip_is_recorded() {
        assert_eq!(
            parse_skip_marker(
                "## Design\n- design-advisor: skipped — a one-line docs typo, no interface moves\n",
                "design-advisor",
            ),
            SkipMarker::Recorded("a one-line docs typo, no interface moves".into())
        );
    }

    #[test]
    fn the_marker_is_line_anchored_not_a_substring_match() {
        // The role named mid-sentence is prose, not a record.
        assert_eq!(
            parse_skip_marker(
                "We considered whether the design-advisor: should be skipped here.\n",
                "design-advisor",
            ),
            SkipMarker::Absent
        );
    }

    #[test]
    fn a_fenced_example_is_not_a_record() {
        // S127's own bug, in the shape this grammar would have inherited.
        let prompt = "## Design\n\n```\ndesign-advisor: skipped — this is only an EXAMPLE\n```\n";
        assert_eq!(
            parse_skip_marker(prompt, "design-advisor"),
            SkipMarker::Absent
        );
    }

    #[test]
    fn decoration_does_not_change_the_reading() {
        for line in [
            "design-advisor: skipped — pure fix",
            "- design-advisor: skipped — pure fix",
            "* **design-advisor: skipped — pure fix**",
            "### design-advisor: skipped: pure fix",
        ] {
            assert!(
                matches!(parse_skip_marker(line, "design-advisor"), SkipMarker::Recorded(r) if r == "pure fix"),
                "{line:?} did not read as a recorded skip"
            );
        }
    }

    #[test]
    fn the_scaffolded_placeholder_is_unusable_not_absent() {
        let m = parse_skip_marker(
            "- design-advisor: <skipped — why this session needs no design review>\n",
            "design-advisor",
        );
        assert!(
            matches!(m, SkipMarker::Unusable(SkipDefect::Placeholder, _)),
            "{m:?}"
        );
    }

    #[test]
    fn skipped_with_no_reason_is_unusable() {
        let m = parse_skip_marker("- design-advisor: skipped\n", "design-advisor");
        assert!(
            matches!(m, SkipMarker::Unusable(SkipDefect::NoReason, _)),
            "{m:?}"
        );
    }

    #[test]
    fn a_template_reason_after_skipped_is_unusable() {
        // The scaffold's shape one level in: the value IS a skip claim, and the reason is still
        // `<...>`. This is the only path through `advice::substantive_reason`, so without this
        // test the substantiveness floor is unfalsifiable.
        let m = parse_skip_marker(
            "- design-advisor: skipped — <why this session needs no design review>\n",
            "design-advisor",
        );
        assert!(
            matches!(m, SkipMarker::Unusable(SkipDefect::Placeholder, _)),
            "{m:?}"
        );
    }

    #[test]
    fn a_colon_with_nothing_after_it_is_unusable() {
        let m = parse_skip_marker("- design-advisor:\n", "design-advisor");
        assert!(
            matches!(m, SkipMarker::Unusable(SkipDefect::Empty, _)),
            "{m:?}"
        );
    }

    #[test]
    fn a_non_skip_value_is_unusable_never_a_pass() {
        // "done", "yes", "consulted" — the words a hurried author would reach for.
        for v in ["done", "yes", "consulted informally"] {
            let m = parse_skip_marker(&format!("design-advisor: {v}\n"), "design-advisor");
            assert!(
                matches!(m, SkipMarker::Unusable(SkipDefect::NotASkip, _)),
                "{v:?} -> {m:?}"
            );
        }
    }

    #[test]
    fn the_grammar_is_generic_over_the_role_name() {
        // S134's role inherits this parser with no new grammar (rec 2, rec 8).
        assert_eq!(
            parse_skip_marker(
                "- implementation-advisor: skipped — the change is one line in a comment\n",
                "implementation-advisor",
            ),
            SkipMarker::Recorded("the change is one line in a comment".into())
        );
    }

    // --- the ladder ---------------------------------------------------------------------------

    // Rung 5 (acceptance 1): no handoff, no reason, at/after the threshold -> BLOCK naming BOTH ways.
    #[test]
    fn silence_at_the_threshold_blocks_and_names_both_ways_out() {
        let root = tmp_root();
        write_prompt(
            &root,
            133,
            "# fixture\n\n## Design\n- design-significant: no\n",
        );
        let v = design_advisor_gate(&root, 133);
        assert!(v.blocked());
        assert_eq!(v.cause, Some(MandateCause::Silence));
        // Acceptance 1 also demands the message NAME both ways out and the no-env-var rule. That
        // is a WORDING contract, asserted live against the real binary in
        // `scripts/verify-session-133.sh` (check 1) rather than here — otherwise renaming a
        // message would go red and S122's second falsifiability direction could not be tested.
        assert_eq!(v.reasons.len(), 1, "{:?}", v.reasons);
    }

    // Rung 3 (acceptance 2): a substantive reason PASSES and the reason comes back out for printing.
    #[test]
    fn a_recorded_reason_passes_and_is_carried_out_for_printing() {
        let root = tmp_root();
        write_prompt(
            &root,
            133,
            "# fixture\n\n## Design\n- design-significant: no\n- design-advisor: skipped — a \
             one-line README typo; no interface, module, or locked record moves\n",
        );
        let v = design_advisor_gate(&root, 133);
        assert!(!v.blocked(), "{:?}", v.reasons);
        assert_eq!(
            v.skipped.as_deref(),
            Some("a one-line README typo; no interface, module, or locked record moves")
        );
        let line = v
            .skip_line()
            .expect("a skipped gate must render a skip line");
        assert!(
            line.starts_with("design-advisor review SKIPPED — "),
            "{line}"
        );
    }

    // Rung 4 (acceptance 3): a placeholder reason BLOCKS — at ANY session, threshold or not.
    #[test]
    fn a_placeholder_reason_blocks_even_below_the_threshold() {
        let root = tmp_root();
        write_prompt(&root, 42, "# fixture\n\n- design-advisor: <why not>\n");
        let v = design_advisor_gate(&root, 42);
        assert!(v.blocked(), "the threshold governs SILENCE only");
        assert_eq!(
            v.cause,
            Some(MandateCause::SkipUnusable(SkipDefect::Placeholder))
        );
    }

    #[test]
    fn an_empty_reason_blocks() {
        let root = tmp_root();
        write_prompt(&root, 133, "# fixture\n\n- design-advisor: skipped —\n");
        let v = design_advisor_gate(&root, 133);
        assert!(v.blocked());
        assert_eq!(
            v.cause,
            Some(MandateCause::SkipUnusable(SkipDefect::NoReason))
        );
    }

    // Rung 1 (acceptance 4): unverifiable provenance BLOCKS.
    #[test]
    fn a_hand_typed_handoff_blocks() {
        let root = tmp_root();
        write_prompt(&root, 133, "# fixture\n");
        write_handoff(&root, 133, "claude-code-subagent");
        let v = design_advisor_gate(&root, 133);
        assert!(v.blocked());
        assert_eq!(v.cause, Some(MandateCause::ProvenanceMissingId));
    }

    #[test]
    fn a_fabricated_dispatch_id_blocks() {
        let root = tmp_root();
        write_prompt(&root, 133, "# fixture\n");
        write_handoff(
            &root,
            133,
            "claude-code-subagent (verified: toolu_FAKEFAKEFAKE)",
        );
        let v = design_advisor_gate(&root, 133);
        assert!(v.blocked());
        assert_eq!(v.cause, Some(MandateCause::ProvenanceUnverifiable));
    }

    // Rung 1 BEATS rung 3 — the decided conflict. A recorded reason does not launder a forged
    // handoff, and the message says so rather than leaving the precedence to be inferred.
    #[test]
    fn a_recorded_reason_does_not_rescue_an_unverifiable_handoff() {
        let root = tmp_root();
        write_prompt(
            &root,
            133,
            "# fixture\n- design-advisor: skipped — a perfectly good reason, recorded in the repo\n",
        );
        write_handoff(
            &root,
            133,
            "claude-code-subagent (verified: toolu_FAKEFAKEFAKE)",
        );
        let v = design_advisor_gate(&root, 133);
        assert!(v.blocked(), "a forged claim is not cured by a sentence");
        assert!(v.skipped.is_none());
        assert_eq!(v.cause, Some(MandateCause::ProvenanceUnverifiable));
    }

    #[test]
    fn a_malformed_handoff_fails_closed_not_silently_absent() {
        let root = tmp_root();
        write_prompt(
            &root,
            133,
            "# fixture\n- design-advisor: skipped — a real reason\n",
        );
        fs::write(
            root.join(".ai/handoffs/session-133-design-advisor.md"),
            "not a handoff at all",
        )
        .unwrap();
        let v = design_advisor_gate(&root, 133);
        assert!(v.blocked());
        assert_eq!(v.cause, Some(MandateCause::HandoffMalformed));
    }

    // Rung 6: below the threshold, silence WARNs and the warning NAMES the exemption.
    #[test]
    fn silence_below_the_threshold_warns_and_names_the_exemption() {
        let root = tmp_root();
        write_prompt(&root, 100, "# fixture\n");
        let v = design_advisor_gate(&root, 100);
        assert!(!v.blocked(), "{:?}", v.reasons);
        assert_eq!(v.cause, None);
        assert_eq!(
            v.warnings.len(),
            1,
            "silence below the threshold must WARN exactly once: {:?}",
            v.warnings
        );
    }

    // rec 3: `design-significant: no` is a reason a human may WRITE, never an exemption the
    // machine infers. Without a skip line it blocks exactly like any other silence.
    #[test]
    fn design_significant_no_does_not_excuse_the_handoff() {
        let root = tmp_root();
        write_prompt(
            &root,
            133,
            "# fixture\n\n## Design\n- design-significant: no — pure fix\n",
        );
        let v = design_advisor_gate(&root, 133);
        assert!(
            v.blocked(),
            "`design-significant: no` must not be a self-granted exemption"
        );
    }

    // rec 9: the most suspicious combination passes LOUDLY.
    #[test]
    fn significant_plus_skipped_passes_with_a_contradiction_warning() {
        let root = tmp_root();
        write_prompt(
            &root,
            133,
            "# fixture\n\n## Design\n- design-significant: yes — a new module\n\
             - design-advisor: skipped — no advisor was available and the founder said ship it\n",
        );
        let v = design_advisor_gate(&root, 133);
        assert!(!v.blocked(), "{:?}", v.reasons);
        assert!(v.skipped.is_some());
        assert_eq!(
            v.warnings.len(),
            1,
            "the significant+skipped contradiction must produce exactly one WARN: {:?}",
            v.warnings
        );
    }

    // A session with no prompt at all cannot record a reason — say so rather than passing quietly.
    #[test]
    fn a_missing_prompt_warns_that_only_a_handoff_can_satisfy_the_gate() {
        let root = tmp_root();
        let v = design_advisor_gate(&root, 133);
        assert!(v.blocked());
        assert_eq!(v.cause, Some(MandateCause::Silence));
        assert_eq!(
            v.warnings.len(),
            1,
            "a session with no prompt must say so: {:?}",
            v.warnings
        );
    }

    // The generic entry point is really generic — S134 is a call site, not a copy (rec 8).
    #[test]
    fn the_gate_is_generic_over_the_role() {
        let root = tmp_root();
        write_prompt(
            &root,
            134,
            "# fixture\n- implementation-advisor: skipped — a genuinely trivial change\n",
        );
        let role = fleet::resolve_role("implementation-advisor").unwrap();
        let v = mandate_gate(&root, role, 134, 134);
        assert!(!v.blocked(), "{:?}", v.reasons);
        assert_eq!(v.role, "implementation-advisor");
        let line = v
            .skip_line()
            .expect("a skipped gate must render a skip line");
        assert!(line.contains("implementation-advisor"), "{line}");
        assert!(line.contains("a genuinely trivial change"), "{line}");
    }

    // rec 6's fresh-project fix, proven against the REAL scaffold rather than a hand-typed copy:
    // a session-NUMBER threshold would exempt sessions 1..132 of a freshly `vajra init`ed project,
    // so the scaffolded prompt carries the marker as a placeholder — rung 4, which blocks at ANY
    // session number. Number-based exemption for legacy prompts, marker-based enforcement for
    // everything scaffolded.
    #[test]
    fn the_real_scaffold_template_lands_on_rung_4_not_the_threshold_exemption() {
        let m = parse_skip_marker(crate::analyst::PROMPT_TEMPLATE, "design-advisor");
        assert!(
            matches!(m, SkipMarker::Unusable(SkipDefect::Placeholder, _)),
            "the scaffold must carry an UNUSABLE marker, not none: {m:?}"
        );

        let root = tmp_root();
        write_prompt(&root, 1, crate::analyst::PROMPT_TEMPLATE);
        let v = design_advisor_gate(&root, 1);
        assert!(
            v.blocked(),
            "a scaffolded session 1 must block despite sitting below the threshold"
        );
    }

    // The floor is stated, not implied.
    #[test]
    fn the_floor_admits_what_this_gate_does_not_prove() {
        assert!(MANDATE_FLOOR.contains("never that the reason is a good one"));
        assert!(MANDATE_FLOOR.contains("never that the advice reached the design"));
    }
}
