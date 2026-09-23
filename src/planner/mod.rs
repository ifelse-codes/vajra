//! The Planner — the pipeline's second governed SDLC specialist (S64).
//!
//! Vajra is a GOVERNED multi-agent SDLC pipeline (DECISION-001, S53). The Analyst (stage one,
//! S54+S61+S62) governs the **WHAT**: intent → the accepted next prompt. The Planner governs the
//! **HOW**: it turns that accepted prompt into an ordered, coverage-checked **plan** *before* any
//! code is written.
//!
//! The plan is NOT a new artifact. Like the Analyst refusing a `spec.md`, the Planner refuses a
//! `plan.md`: the plan lives in a `## Plan` section INSIDE the session's own prompt
//! (`prompts/NN-task-<slug>.md` — Vajra's spec). No second store (memory
//! `feedback-map-concepts-to-vajra`, `feedback-distill-no-drift`), no 8th command (rides
//! `vajra next`).
//!
//! The plan's job is COVERAGE: each of the prompt's acceptance criteria must map to the ordered
//! step(s) that will satisfy it. This is the pre-execution mirror of the fidelity Validator's
//! post-delivery check — the Validator asks "did the delivery cover every requirement?"; the
//! Planner asks "does the plan cover every requirement, before we start?".
//!
//! Crucially the binary **surfaces + enforces, never authors** (the S54 anti-trap): a Rust binary
//! cannot know *which* step semantically satisfies a criterion — inferring that would be
//! fabricating a plan. So the honest contract is: the author writes the plan and records, per step,
//! the acceptance-criterion numbers it covers (`covers: 1, 3`); the Planner enforces that every
//! criterion number is cited by at least one real step. It counts the recorded mapping; it never
//! invents one.

use std::fs;
use std::path::Path;

use crate::analyst::find_prompt_for;

/// One acceptance criterion surfaced from a prompt's `## Acceptance` section: its literal ordinal
/// (the `N.` the plan cites) and its first-line text (for the `--plan` checklist).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Criterion {
    pub number: u32,
    pub text: String,
}

/// Coverage state of a prompt's `## Plan` section vs its acceptance criteria (S64). Mirrors the
/// Analyst's `DeltaState` (S61) and `OptionsState` (S62): absent is legacy-compatible (WARN),
/// everything else that is not fully covered BLOCKS.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum PlanState {
    /// No `## Plan` heading at all (legacy prompts pre-S64). The gate only WARNS — legacy prompts
    /// stay valid (mirrors `DeltaState::Absent`).
    Absent,
    /// A `## Plan` heading is present but every step is still the template placeholder (`<...>`) or
    /// empty — the fresh-scaffold state. Treated as absent-of-a-real-plan and BLOCKS at L2/L3
    /// (mirrors `DeltaState::Placeholder`).
    Placeholder,
    /// Real plan steps exist, but these acceptance-criterion numbers are cited by no step. BLOCKS —
    /// the plan does not cover the contract. Carries the missing criterion numbers (sorted).
    Uncovered(Vec<u32>),
    /// Real plan steps cite (`covers: N`) criterion numbers the prompt's acceptance list does NOT
    /// have (S176, F70). BLOCKS — the contract the plan was written against has been cut: rudra S08's
    /// agent deleted its own `## Acceptance` mid-session and the plan still read "covered" because
    /// zero criteria left nothing missing. Carries the cited-but-absent numbers (sorted, deduped).
    /// Checked BEFORE `Uncovered`: a wrong list is the root cause; re-run once it is fixed.
    Dangling(Vec<u32>),
    /// Every acceptance criterion is cited by at least one real step. Passes.
    Covered,
}

impl PlanState {
    /// A blocking state refuses the advance at L2/L3 (placeholder, uncovered, or dangling).
    /// Absent/Covered do not block.
    pub fn blocks(&self) -> bool {
        matches!(
            self,
            PlanState::Placeholder | PlanState::Uncovered(_) | PlanState::Dangling(_)
        )
    }
}

/// Extract the numbered acceptance criteria from a prompt's `## Acceptance` section.
///
/// Scoped to the acceptance heading (matched by the Analyst's synonyms) and stops at the next
/// heading, so numbered lists in later sections (or the Deliverables/Delta) are never captured.
/// Each top-level `N.` item becomes one `Criterion`; continuation lines (which do not start with a
/// number) extend nothing — only the first line's text is kept for the surface checklist.
///
/// A table row whose first cell is `ACn` (`| AC3 | criterion |`) is criterion `n` too (S176): eleven
/// prompts (S156–S168) wrote acceptance that way, so this parser found zero criteria in them and the
/// Planner passed their plans without checking one citation — the F70 blind spot, found by the
/// old-vs-new sweep when the new dangling-citation rule flipped them.
///
/// Two shapes no longer close the block early (S176, qa-specialist rec 1 — each was a false block
/// once a cited-but-unfound number began to BLOCK): a deeper sub-heading (`### Edge cases` under
/// `## Acceptance`) stays inside it, and a fenced code block is skipped whole, so its `# comment`
/// lines are not headings and its lines are not criteria.
pub fn acceptance_criteria(content: &str) -> Vec<Criterion> {
    let mut in_block = false;
    let mut block_level = 0usize;
    let mut in_fence = false;
    let mut out = Vec::new();
    for line in content.lines() {
        let t = line.trim();
        if is_fence(t) {
            in_fence = !in_fence;
            continue;
        }
        if in_fence {
            continue;
        }
        if t.starts_with('#') {
            let level = heading_level(t);
            if in_block && level > block_level && !is_plan_heading(t) {
                continue; // a sub-heading of the acceptance section, not its end
            }
            // Entering the acceptance section, or leaving it at the next heading.
            //
            // A `## Plan` heading NEVER opens the acceptance block, even when it names the word
            // (S129): the house heading is `## Plan (ordered — cite the acceptance criteria each
            // step covers)`, and `is_acceptance_heading` matches on `contains("acceptance")`, so
            // the plan's own eleven steps were being read as eleven acceptance criteria. The gate
            // then demanded `covers: 11` for a criterion that did not exist and refused the close.
            // Present in every prompt since the heading was adopted; nobody had run `--check-plan`
            // against one until S129 did. The plan heading is the more specific match, so it wins.
            in_block = is_acceptance_heading(t) && !is_plan_heading(t);
            block_level = level;
            continue;
        }
        if in_block {
            if let Some((number, text)) = numbered_item(t).or_else(|| ac_table_row(t)) {
                out.push(Criterion { number, text });
            }
        }
    }
    out
}

/// True when the prompt has an acceptance heading at all (outside code fences) — lets the Dangling
/// message say "the section is gone" vs "the section is there but unnumbered" (S176, QA rec 1).
pub fn has_acceptance_section(content: &str) -> bool {
    let mut in_fence = false;
    for line in content.lines() {
        let t = line.trim();
        if is_fence(t) {
            in_fence = !in_fence;
        } else if !in_fence && t.starts_with('#') && is_acceptance_heading(t) && !is_plan_heading(t)
        {
            return true;
        }
    }
    false
}

fn is_fence(t: &str) -> bool {
    t.starts_with("```") || t.starts_with("~~~")
}

fn heading_level(t: &str) -> usize {
    t.chars().take_while(|c| *c == '#').count()
}

/// A heading opens the acceptance block if it names acceptance (the same synonyms the Analyst's
/// `REQUIRED_SECTIONS` accepts, so legacy prompt shapes are recognised).
fn is_acceptance_heading(line: &str) -> bool {
    let h = line.trim_start_matches('#').trim().to_ascii_lowercase();
    ["acceptance", "must answer", "must be answered", "what must"]
        .iter()
        .any(|needle| h.contains(needle))
}

/// A heading opens the `## Plan` block. Matched on the first token being exactly `plan` (not merely
/// `contains("plan")`) so a title like "Session 64 — the PLANNER stage" does NOT count as the plan
/// section.
fn is_plan_heading(line: &str) -> bool {
    line.trim_start_matches('#')
        .trim()
        .to_ascii_lowercase()
        .split_whitespace()
        .next()
        == Some("plan")
}

/// If `line` is a top-level ordered-list item (`N. text`), return `(N, text)`. `None` otherwise.
fn numbered_item(line: &str) -> Option<(u32, String)> {
    let (num, rest) = line.split_once('.')?;
    let number: u32 = num.trim().parse().ok()?;
    let rest = rest.trim();
    (!rest.is_empty()).then(|| (number, rest.to_string()))
}

/// If `line` is an acceptance table row whose first cell is `ACn` (any case; `**AC1**`, `AC 1`,
/// `AC-1` too), return `(n, second cell)`. The header (`| AC | Criterion |`) and separator rows carry
/// no digits and yield `None`; so does a sub-labelled `AC1a` (not a whole number — never guessed
/// into criterion 1).
fn ac_table_row(line: &str) -> Option<(u32, String)> {
    let mut cells = line.strip_prefix('|')?.split('|').map(str::trim);
    let label = cells.next()?.trim_matches('*').trim().to_ascii_uppercase();
    let digits = label
        .strip_prefix("AC")?
        .trim_start_matches([' ', '-', '_']);
    let number: u32 = digits.parse().ok()?;
    let text = cells.next().unwrap_or("").to_string();
    Some((number, text))
}

/// The human description of a plan step: the line with its `N.` / `-` / `*` marker stripped.
/// `None` for a non-step line (blank, prose, sub-detail without a marker).
fn plan_step_description(line: &str) -> Option<String> {
    let t = line.trim();
    // Ordered `N.` step, or a `-`/`*` bullet step.
    if let Some((_, text)) = numbered_item(t) {
        return Some(text);
    }
    let rest = t.strip_prefix('-').or_else(|| t.strip_prefix('*'))?.trim();
    (!rest.is_empty()).then(|| rest.to_string())
}

/// True when a step description is still a template placeholder (`<...>`) or empty — not a real
/// step the author wrote.
fn is_placeholder_step(desc: &str) -> bool {
    desc.is_empty() || desc.starts_with('<')
}

/// Parse the acceptance-criterion numbers a line cites via a `covers:` marker.
///
/// The recorded-mapping contract: an author writes `covers: 1, 3` (case-insensitive) to declare
/// which criteria a step satisfies. After each `covers:` marker, consecutive digit runs are read as
/// numbers, with commas/whitespace as separators; the scan stops at the first other character (so
/// `covers: 1, 2 by editing foo` yields `[1, 2]`). A `covers` without a colon, or with no trailing
/// digits, cites nothing — so prose like "this covers the edge case" is not a false citation.
///
/// EVERY `covers:` occurrence on the line is scanned (a wrapped step line, or one whose prose also
/// says the word "covers:", still yields its real citation) — the dogfood surfaced this.
fn cited_criteria(desc: &str) -> Vec<u32> {
    let lower = desc.to_ascii_lowercase();
    let mut out = Vec::new();
    let mut rest = lower.as_str();
    while let Some(i) = rest.find("covers:") {
        let after = &rest[i + "covers:".len()..];
        let mut cur = String::new();
        for c in after.chars() {
            if c.is_ascii_digit() {
                cur.push(c);
            } else if c == ',' || c.is_whitespace() {
                flush(&mut cur, &mut out);
            } else {
                break;
            }
        }
        flush(&mut cur, &mut out);
        rest = after;
    }
    out
}

fn flush(cur: &mut String, out: &mut Vec<u32>) {
    if let Ok(n) = cur.parse::<u32>() {
        out.push(n);
    }
    cur.clear();
}

/// Union the criterion numbers cited on `line` into `cited` (dedup preserved order).
fn push_citations(line: &str, cited: &mut Vec<u32>) {
    for n in cited_criteria(line) {
        if !cited.contains(&n) {
            cited.push(n);
        }
    }
}

/// Classify the `## Plan` section's coverage of the prompt's acceptance criteria (S64).
///
/// - No `## Plan` heading                              → `Absent`   (WARN — legacy compat)
/// - heading present, every step a placeholder/empty   → `Placeholder` (BLOCK)
/// - real steps citing a number the prompt lacks        → `Dangling`  (BLOCK, S176 — wins)
/// - real steps, some criteria cited by no step        → `Uncovered` (BLOCK)
/// - every criterion cited by ≥1 real step             → `Covered`  (PASS)
///
/// A prompt with no numbered acceptance criteria has nothing to cover: a substantive plan that
/// cites nothing is `Covered`, an all-placeholder plan is still `Placeholder` — but a plan that
/// still cites `covers: N` against an empty list is `Dangling` (S176, F70).
pub fn plan_coverage(content: &str) -> PlanState {
    let criteria = acceptance_criteria(content);
    plan_coverage_against(content, &criteria)
}

/// `plan_coverage` split out so the gate can reuse already-parsed criteria without re-scanning.
fn plan_coverage_against(content: &str, criteria: &[Criterion]) -> PlanState {
    let mut in_plan = false;
    let mut saw_heading = false;
    let mut saw_real_step = false;
    let mut cited: Vec<u32> = Vec::new();

    for line in content.lines() {
        let t = line.trim();
        if t.starts_with('#') {
            in_plan = is_plan_heading(t);
            if in_plan {
                saw_heading = true;
            }
            continue;
        }
        if in_plan {
            match plan_step_description(t) {
                // A placeholder step (`<...>`/empty) is not a real step and is not cited from.
                Some(desc) if is_placeholder_step(&desc) => {}
                // A real step marker: it counts, and its own line may carry the citation.
                Some(desc) => {
                    saw_real_step = true;
                    push_citations(&desc, &mut cited);
                }
                // A continuation / prose line inside the section: a step's `covers:` may wrap onto
                // it, so scan it too (but it does not by itself make a "real step").
                None if !t.is_empty() => push_citations(t, &mut cited),
                None => {}
            }
        }
    }

    if !saw_heading {
        return PlanState::Absent;
    }
    if !saw_real_step {
        return PlanState::Placeholder;
    }
    let mut dangling: Vec<u32> = cited
        .iter()
        .copied()
        .filter(|n| !criteria.iter().any(|c| c.number == *n))
        .collect();
    if !dangling.is_empty() {
        dangling.sort_unstable();
        dangling.dedup();
        return PlanState::Dangling(dangling);
    }
    let mut missing: Vec<u32> = criteria
        .iter()
        .map(|c| c.number)
        .filter(|n| !cited.contains(n))
        .collect();
    missing.sort_unstable();
    missing.dedup();
    if missing.is_empty() {
        PlanState::Covered
    } else {
        PlanState::Uncovered(missing)
    }
}

/// The Planner's decision for advancing INTO / checking `session`. Mirrors the Analyst's
/// `GateVerdict`.
#[derive(Debug, Clone)]
pub struct PlanVerdict {
    pub session: u32,
    /// The prompt found for `session` (repo-relative), if any.
    pub prompt_path: Option<String>,
    /// The acceptance criteria surfaced from the prompt (for `--plan`).
    pub criteria: Vec<Criterion>,
    /// The coverage state, when a prompt was read.
    pub plan: Option<PlanState>,
    /// Blocking reasons — non-empty means L2/L3 must refuse the advance.
    pub reasons: Vec<String>,
    /// Non-blocking nudges (e.g. a wholly absent plan on a legacy prompt).
    pub warnings: Vec<String>,
}

impl PlanVerdict {
    pub fn blocked(&self) -> bool {
        !self.reasons.is_empty()
    }
}

/// The Planner gate (S64): advancing INTO `session` requires its prompt's `## Plan` to COVER every
/// acceptance criterion. A placeholder or uncovered plan BLOCKS (L2/L3); a wholly absent plan or a
/// missing prompt only WARNS (legacy compat / the Analyst gate owns the missing-prompt block).
pub fn plan_gate(root: &Path, session: u32) -> PlanVerdict {
    let mut reasons = Vec::new();
    let mut warnings = Vec::new();
    let mut criteria = Vec::new();
    let mut plan = None;

    let prompt_path = find_prompt_for(root, session);
    match &prompt_path {
        None => warnings.push(format!(
            "no prompt for session {session:02} — the Analyst gate owns that block; nothing to plan yet"
        )),
        Some(rel) => match fs::read_to_string(root.join(rel)) {
            Err(e) => reasons.push(format!("cannot read {rel}: {e}")),
            Ok(content) => {
                criteria = acceptance_criteria(&content);
                let state = plan_coverage_against(&content, &criteria);
                match &state {
                    PlanState::Covered => {}
                    PlanState::Absent => warnings.push(format!(
                        "{rel} has no `## Plan` section — add an ordered plan that cites (`covers: N`) \
                         each acceptance criterion before executing"
                    )),
                    PlanState::Placeholder => reasons.push(format!(
                        "{rel} has a placeholder `## Plan` (still the template `<...>`) — record real \
                         ordered steps that cover the acceptance criteria before advancing"
                    )),
                    PlanState::Uncovered(missing) => reasons.push(format!(
                        "{rel} `## Plan` does not cover acceptance criterion(s) {} — add/annotate a \
                         step with `covers: {}` for each",
                        join_nums(missing),
                        join_nums(missing),
                    )),
                    PlanState::Dangling(cited) => {
                        let nums = join_nums(cited);
                        reasons.push(if !criteria.is_empty() {
                            format!(
                                "{rel} `## Plan` cites acceptance item(s) {nums}, but `## Acceptance` \
                                 has only {} numbered item(s) — was the list cut? Restore it from git \
                                 (`git log -p -- {rel}`), or number the missing items as `N.` lines \
                                 or `| ACn |` rows",
                                criteria.len()
                            )
                        } else if has_acceptance_section(&content) {
                            format!(
                                "{rel} `## Plan` cites acceptance item(s) {nums}, but no item under \
                                 `## Acceptance` is numbered — write them as `N.` lines or `| ACn |` \
                                 rows so the check can read them (or restore the list from git if it \
                                 was cut: `git log -p -- {rel}`)"
                            )
                        } else {
                            format!(
                                "{rel} `## Plan` cites acceptance item(s) {nums}, but the prompt has \
                                 no `## Acceptance` section — was it deleted? Restore it from git \
                                 (`git log -p -- {rel}`)"
                            )
                        });
                    }
                }
                plan = Some(state);
            }
        },
    }

    PlanVerdict {
        session,
        prompt_path,
        criteria,
        plan,
        reasons,
        warnings,
    }
}

fn join_nums(nums: &[u32]) -> String {
    nums.iter()
        .map(|n| n.to_string())
        .collect::<Vec<_>>()
        .join(", ")
}

/// Render the `--plan N` surface: the acceptance criteria to plan against + how to record coverage.
/// The plan DERIVES from the contract (the criteria), not from thin air — the binary surfaces them,
/// the author writes the steps.
pub fn format_plan_checklist(verdict: &PlanVerdict) -> String {
    let mut s = format!(
        "=== planner: plan checklist for session {:02} ===\n",
        verdict.session
    );
    s.push_str(&format!(
        "prompt: {}\n",
        verdict.prompt_path.as_deref().unwrap_or("(none)")
    ));
    if verdict.criteria.is_empty() {
        s.push_str("no numbered acceptance criteria found — nothing to plan against yet.\n");
        if let Some(PlanState::Dangling(d)) = &verdict.plan {
            s.push_str(&format!(
                "current `## Plan`: cites missing item(s) → {} (was `## Acceptance` deleted?)\n",
                join_nums(d)
            ));
        }
        return s;
    }
    s.push_str(
        "plan against these acceptance criteria (cite each in `## Plan` with `covers: N`):\n",
    );
    for c in &verdict.criteria {
        let clipped: String = c.text.chars().take(100).collect();
        let ell = if c.text.chars().count() > 100 {
            "…"
        } else {
            ""
        };
        s.push_str(&format!("  [{}] {clipped}{ell}\n", c.number));
    }
    match &verdict.plan {
        Some(PlanState::Covered) => s.push_str("current `## Plan`: COVERS every criterion ✓\n"),
        Some(PlanState::Uncovered(m)) => s.push_str(&format!(
            "current `## Plan`: uncovered → {}\n",
            join_nums(m)
        )),
        Some(PlanState::Dangling(d)) => s.push_str(&format!(
            "current `## Plan`: cites missing item(s) → {} (was the list cut?)\n",
            join_nums(d)
        )),
        Some(PlanState::Placeholder) => {
            s.push_str("current `## Plan`: placeholder (replace the `<...>` steps)\n")
        }
        Some(PlanState::Absent) | None => s.push_str(
            "current `## Plan`: none — add an ordered `## Plan` that covers each above\n",
        ),
    }
    s
}

#[cfg(test)]
mod tests {
    use super::*;

    const PROMPT: &str = r#"# Session 64 — the PLANNER stage: plan coverage
> **Status:** APPROVED
## Goal
Do one thing.
## Acceptance (testable, EARS-style)
1. WHEN --plan is run THEN it surfaces criteria.
2. WHEN the plan is uncovered THEN --check-plan blocks.
3. The binary surfaces, never authors.
## Deliverables
- a thing
## Guardrails
- one story
## Delta (vs ROADMAP)
- `+` the planner
"#;

    #[test]
    fn acceptance_criteria_extracted_and_scoped() {
        let c = acceptance_criteria(PROMPT);
        assert_eq!(c.len(), 3, "got: {c:?}");
        assert_eq!(c[0].number, 1);
        assert!(c[0].text.contains("surfaces criteria"));
        assert_eq!(c[2].number, 3);
        // A "PLANNER" title heading must NOT be read as the acceptance/plan section.
        assert!(!c.iter().any(|x| x.text.contains("plan coverage")));
    }

    #[test]
    fn plan_title_heading_is_not_the_plan_section() {
        // The `# Session 64 — the PLANNER stage` title contains "planner" but is not `## Plan`.
        assert!(!is_plan_heading(
            "# Session 64 — the PLANNER stage: plan coverage"
        ));
        assert!(is_plan_heading("## Plan (ordered steps)"));
        assert!(is_plan_heading("## plan"));
        assert!(!is_plan_heading("## Planning notes"));
    }

    #[test]
    fn cited_criteria_parses_covers_marker() {
        assert_eq!(cited_criteria("do X — covers: 1, 3"), vec![1, 3]);
        assert_eq!(cited_criteria("do Y covers: 2 by editing foo"), vec![2]);
        assert_eq!(cited_criteria("Covers: 4,5,6"), vec![4, 5, 6]);
        // No colon, or no digits → no citation (prose is not a false positive).
        assert!(cited_criteria("this covers the edge case").is_empty());
        assert!(cited_criteria("covers: the auth flow").is_empty());
        assert!(cited_criteria("a plain step").is_empty());
    }

    #[test]
    fn absent_plan_warns() {
        assert_eq!(plan_coverage(PROMPT), PlanState::Absent);
    }

    #[test]
    fn placeholder_plan_blocks() {
        let p = format!(
            "{PROMPT}## Plan (ordered — cite `covers: N`)\n1. <first step — replace me>\n2. <next>\n"
        );
        assert_eq!(plan_coverage(&p), PlanState::Placeholder);
        assert!(plan_coverage(&p).blocks());
    }

    #[test]
    fn uncovered_plan_blocks_with_missing() {
        // Real steps, but only criterion 1 is cited → 2 and 3 missing.
        let p = format!("{PROMPT}## Plan\n1. build the thing — covers: 1\n2. test it\n");
        assert_eq!(plan_coverage(&p), PlanState::Uncovered(vec![2, 3]));
        assert!(plan_coverage(&p).blocks());
    }

    #[test]
    fn covered_plan_passes() {
        let p = format!(
            "{PROMPT}## Plan\n1. build — covers: 1\n2. gate — covers: 2\n3. honesty — covers: 3\n"
        );
        assert_eq!(plan_coverage(&p), PlanState::Covered);
        assert!(!plan_coverage(&p).blocks());
    }

    #[test]
    fn one_step_may_cover_several_criteria() {
        let p = format!("{PROMPT}## Plan\n1. one step — covers: 1, 2, 3\n");
        assert_eq!(plan_coverage(&p), PlanState::Covered);
    }

    #[test]
    fn covers_on_wrapped_continuation_line_is_counted() {
        // The dogfood found this: a step's `covers:` marker wraps onto its continuation line, and a
        // step whose prose also literally says "covers:" must still yield its real citation.
        let p = format!(
            "{PROMPT}## Plan\n\
             1. Build the parser that reads each step's `covers:` marker; surfaces the checklist.\n\
                covers: 1\n\
             2. Add the gate and wire it into --advance.\n   covers: 2, 3\n"
        );
        assert_eq!(plan_coverage(&p), PlanState::Covered);
        // And multiple `covers:` on one line union correctly.
        assert_eq!(
            cited_criteria("talks about covers: nothing then covers: 4, 5"),
            vec![4, 5]
        );
    }

    #[test]
    fn no_criteria_means_substantive_plan_is_covered() {
        let no_accept = "# S\n## Goal\ng\n## Plan\n1. do a real thing\n";
        assert_eq!(plan_coverage(no_accept), PlanState::Covered);
        // But an all-placeholder plan is still a placeholder, criteria or not.
        let ph = "# S\n## Goal\ng\n## Plan\n1. <replace me>\n";
        assert_eq!(plan_coverage(ph), PlanState::Placeholder);
    }

    // S176 (F70): rudra S08's agent deleted its own `## Acceptance` (plus Deliverables, Guardrails,
    // Delta, Assumptions) mid-session. The plan still said `covers: 1..7` and the Planner said READY:
    // zero criteria → nothing "missing". A cited number the prompt lacks now BLOCKS.
    #[test]
    fn plan_citing_a_deleted_acceptance_list_is_dangling() {
        let wiped =
            "# S08\n## Goal\ng\n## Design\nd\n## Plan\n1. a — covers: 1, 2\n2. b — covers: 3\n";
        assert_eq!(plan_coverage(wiped), PlanState::Dangling(vec![1, 2, 3]));
        assert!(
            PlanState::Dangling(vec![1]).blocks(),
            "Dangling must block (rec 2)"
        );
    }

    #[test]
    fn plan_citing_past_a_cut_list_is_dangling() {
        // PROMPT has criteria 1–3; the plan cites 4 and 5 as well.
        let cut = format!("{PROMPT}## Plan\n1. a — covers: 1, 2, 3\n2. b — covers: 5, 4, 5\n");
        assert_eq!(plan_coverage(&cut), PlanState::Dangling(vec![4, 5]));
    }

    #[test]
    fn dangling_wins_over_uncovered() {
        // Criteria 1–3; the plan covers 1 only and cites a missing 7: the list is the root cause.
        let both = format!("{PROMPT}## Plan\n1. a — covers: 1, 7\n");
        assert_eq!(plan_coverage(&both), PlanState::Dangling(vec![7]));
    }

    #[test]
    fn edge_fixtures_non_numbered_list_prose_and_citing_nothing() {
        // (a) acceptance written as bullets: no numbered criteria, so `covers: 1` dangles — and the
        //     gate message names that second cause (items not written as `N.` lines).
        let bullets = "# S\n## Acceptance\n- it works\n## Plan\n1. build — covers: 1\n";
        assert_eq!(plan_coverage(bullets), PlanState::Dangling(vec![1]));
        // (b) a `covers:` on a wrapped continuation line is a citation like any other.
        let wrapped = format!("{PROMPT}## Plan\n1. build the thing\n   covers: 1, 2, 3, 9\n");
        assert_eq!(plan_coverage(&wrapped), PlanState::Dangling(vec![9]));
        // (c) adds only (S173): no criteria + a plan citing nothing stays Covered.
        let none = "# S\n## Goal\ng\n## Plan\n1. do a real thing\n";
        assert_eq!(plan_coverage(none), PlanState::Covered);
    }

    #[test]
    fn ac_table_rows_are_criteria() {
        let table = "# S\n## Acceptance (EARS)\n\n| AC | Criterion |\n|----|-----------|\n\
                     | AC1 | it works |\n| AC2 | it blocks |\n| AC3a | sub-label, not a number |\n\
                     ## Plan\n1. a — covers: 1\n2. b — covers: 2\n";
        let c = acceptance_criteria(table);
        assert_eq!(c.iter().map(|x| x.number).collect::<Vec<_>>(), vec![1, 2]);
        assert_eq!(c[0].text, "it works");
        assert_eq!(plan_coverage(table), PlanState::Covered);
        // A table row outside the acceptance section is never a criterion.
        assert!(acceptance_criteria("## Delta\n| AC1 | x |\n").is_empty());
    }

    // S176 QA rec 1: shapes that falsely blocked once dangling citations began to block.
    #[test]
    fn subheadings_and_code_fences_stay_inside_acceptance() {
        let sub =
            "# S\n## Acceptance\n### Core\n1. a\n### Edge\n2. b\n## Plan\n1. x — covers: 1, 2\n";
        assert_eq!(plan_coverage(sub), PlanState::Covered);
        let fence =
            "# S\n## Acceptance\n1. a\n```\n# not a heading\n9. not a criterion\n```\n2. b\n\
                     ## Plan\n1. x — covers: 1, 2\n";
        assert_eq!(
            acceptance_criteria(fence)
                .iter()
                .map(|c| c.number)
                .collect::<Vec<_>>(),
            vec![1, 2]
        );
        assert_eq!(plan_coverage(fence), PlanState::Covered);
        // A same-level heading still ends the section.
        let next =
            "# S\n## Acceptance\n1. a\n## Notes\n2. not a criterion\n## Plan\n1. x — covers: 1\n";
        assert_eq!(plan_coverage(next), PlanState::Covered);
    }

    #[test]
    fn ac_labels_read_in_any_case_and_common_spellings() {
        for label in ["ac2", "Ac2", "**AC2**", "AC 2", "AC-2", "AC02"] {
            let p = format!("# S\n## Acceptance\n| {label} | x |\n## Plan\n1. a — covers: 2\n");
            assert_eq!(plan_coverage(&p), PlanState::Covered, "label {label}");
        }
    }

    #[test]
    fn dangling_message_names_the_actual_cause() {
        let tmp = tempfile::tempdir().unwrap();
        fs::create_dir_all(tmp.path().join("prompts")).unwrap();
        let msg = |body: &str| {
            fs::write(tmp.path().join("prompts/30-task-x.md"), body).unwrap();
            plan_gate(tmp.path(), 30).reasons.join("\n")
        };
        let cut = msg("# S\n## Acceptance\n1. a\n## Plan\n1. x — covers: 1, 2\n");
        assert!(
            cut.contains("has only 1 numbered item(s) — was the list cut?"),
            "{cut}"
        );
        let unnumbered = msg("# S\n## Acceptance\n- a\n## Plan\n1. x — covers: 1\n");
        assert!(
            unnumbered.contains("no item under `## Acceptance` is numbered"),
            "{unnumbered}"
        );
        let gone = msg("# S\n## Plan\n1. x — covers: 1\n");
        assert!(
            gone.contains("no `## Acceptance` section — was it deleted?"),
            "{gone}"
        );
    }

    #[test]
    fn gate_blocks_dangling_and_names_numbers_and_causes() {
        let tmp = tempfile::tempdir().unwrap();
        fs::create_dir_all(tmp.path().join("prompts")).unwrap();
        fs::write(
            tmp.path().join("prompts/08-task-wiped.md"),
            "# S08\n## Goal\ng\n## Plan\n1. a — covers: 1, 2\n",
        )
        .unwrap();
        let v = plan_gate(tmp.path(), 8);
        assert!(v.blocked());
        let r = v.reasons.join("\n");
        assert!(r.contains("cites acceptance item(s) 1, 2"), "{r}");
        assert!(
            r.contains("no `## Acceptance` section — was it deleted?"),
            "{r}"
        );
        let out = format_plan_checklist(&v);
        assert!(out.contains("cites missing item(s) → 1, 2"), "{out}");
    }

    #[test]
    fn gate_blocks_placeholder_then_uncovered_then_passes_covered() {
        let tmp = tempfile::tempdir().unwrap();
        fs::create_dir_all(tmp.path().join("prompts")).unwrap();
        let rel = tmp.path().join("prompts/64-task-planner.md");

        // Placeholder plan → BLOCK.
        fs::write(
            &rel,
            format!("{PROMPT}## Plan\n1. <first step — replace me>\n"),
        )
        .unwrap();
        let v = plan_gate(tmp.path(), 64);
        assert!(v.blocked(), "placeholder must block");
        assert!(v.reasons.iter().any(|r| r.contains("placeholder")));

        // Uncovered plan → BLOCK, names the missing criteria.
        fs::write(&rel, format!("{PROMPT}## Plan\n1. build — covers: 1\n")).unwrap();
        let v = plan_gate(tmp.path(), 64);
        assert!(v.blocked(), "uncovered must block");
        assert!(v.reasons.iter().any(|r| r.contains("2, 3")));

        // Covered plan → PASS.
        fs::write(
            &rel,
            format!("{PROMPT}## Plan\n1. a — covers: 1\n2. b — covers: 2, 3\n"),
        )
        .unwrap();
        let v = plan_gate(tmp.path(), 64);
        assert!(!v.blocked(), "reasons: {:?}", v.reasons);
        assert_eq!(v.plan, Some(PlanState::Covered));
        assert_eq!(v.criteria.len(), 3);
    }

    #[test]
    fn gate_warns_on_absent_plan_and_missing_prompt() {
        let tmp = tempfile::tempdir().unwrap();
        fs::create_dir_all(tmp.path().join("prompts")).unwrap();
        // A legacy prompt with no ## Plan → WARN, not block.
        fs::write(tmp.path().join("prompts/50-task-x.md"), PROMPT).unwrap();
        let v = plan_gate(tmp.path(), 50);
        assert!(!v.blocked());
        assert!(v.warnings.iter().any(|w| w.contains("no `## Plan`")));
        // No prompt at all → WARN (the Analyst gate owns that block).
        let v = plan_gate(tmp.path(), 99);
        assert!(!v.blocked());
        assert!(v.warnings.iter().any(|w| w.contains("no prompt")));
    }

    #[test]
    fn fresh_scaffold_plan_is_placeholder() {
        // The Analyst scaffold now emits a placeholder `## Plan`; the Planner gate must classify it
        // as Placeholder so a fresh, unfilled prompt BLOCKS until a covered plan is recorded
        // (symmetric with the Delta placeholder). This locks the template ↔ parser alignment.
        let scaffold = crate::analyst::render_scaffold(64, "planner-stage");
        assert_eq!(plan_coverage(&scaffold), PlanState::Placeholder);
    }

    #[test]
    fn plan_heading_naming_acceptance_does_not_add_criteria() {
        // S129: the house plan heading names the word "acceptance", and `is_acceptance_heading`
        // matches on `contains`. Every plan step was therefore counted as an acceptance criterion,
        // so an 11-step plan against 10 criteria demanded a `covers: 11` for a criterion that does
        // not exist. Falsifiable: revert the `&& !is_plan_heading(t)` guard and this fails at 4.
        let prompt = "## Acceptance\n\n1. first.\n2. second.\n\n                      ## Plan (ordered — cite the acceptance criteria each step covers)\n\n                      1. do a thing. `covers: 1`\n2. do another. `covers: 2`\n";
        let criteria = acceptance_criteria(prompt);
        assert_eq!(
            criteria.len(),
            2,
            "the plan's own steps were read as acceptance criteria: {:?}",
            criteria.iter().map(|c| c.number).collect::<Vec<_>>()
        );
        assert_eq!(plan_coverage(prompt), PlanState::Covered);
    }

    #[test]
    fn checklist_surfaces_criteria() {
        let tmp = tempfile::tempdir().unwrap();
        fs::create_dir_all(tmp.path().join("prompts")).unwrap();
        fs::write(tmp.path().join("prompts/64-task-x.md"), PROMPT).unwrap();
        let v = plan_gate(tmp.path(), 64);
        let out = format_plan_checklist(&v);
        assert!(out.contains("[1]"));
        assert!(out.contains("surfaces criteria"));
        assert!(out.contains("covers: N"));
    }
}
