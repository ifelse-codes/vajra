//! The Analyst — the pipeline's first governed SDLC specialist (S54).
//!
//! Vajra is a GOVERNED multi-agent SDLC pipeline (DECISION-001, S53). Each session step
//! generalises into an SDLC stage run by a specialised agent with enforced, delta-tracked
//! handoffs. The Analyst is the first stage: it turns a vague intent into the **next governed
//! prompt** — Vajra's own spec.
//!
//! Crucially, the Analyst does NOT invent a `spec.md`. Vajra's spec ALREADY exists: it is the
//! session prompt `prompts/NN-task-<slug>.md` (goal + deliverables + acceptance + guardrails).
//! Importing a foreign `spec.md` would create a SECOND source of truth — the exact drift the
//! S53 framing corrects (memory `feedback-map-concepts-to-vajra`). So the Analyst owns the
//! `.ai/`+`prompts/` spine and rides `vajra next` (no 8th top-level command, max-7 cap).
//!
//! Three responsibilities, all here so the CLI stays a thin wrapper:
//!
//! 1. SCAFFOLD — emit a well-formed prompt from `PROMPT_TEMPLATE` (the Borrow-Engine shape: Spec
//!    Kit structure + Kiro/EARS testable acceptance + OpenSpec +/~/- deltas, folded INTO Vajra's
//!    prompt format, not a foreign file).
//! 2. VALIDATE — parse a prompt, report which required sections / delta / approval it has.
//! 3. GATE — the enforcement: advancing INTO session N is BLOCKED (fail-closed at L2/L3) unless
//!    prompts/NN-*.md is present, well-formed, and not still a DRAFT.

use std::fs;
use std::path::{Path, PathBuf};

/// The canonical prompt shape the Analyst generates. The Borrow Engine folds three reference
/// designs INTO Vajra's own prompt format (no foreign artifact):
///   - Spec Kit  → an explicit, sectioned structure (Goal / Deliverables).
///   - Kiro EARS → acceptance written as testable, checkable criteria a non-author can verify.
///   - OpenSpec  → a Delta block with `+` add / `~` change / `-` remove markers.
///
/// `{{NN}}` and `{{SLUG}}` are substituted by `scaffold_prompt`. The scaffold ships `Status:
/// DRAFT` so the gate blocks the advance until a human flips it to APPROVED — enforcement, not
/// a ritual.
pub const PROMPT_TEMPLATE: &str = r#"# Session {{NN}} — {{SLUG}}: <one-line goal>

> **Status:** DRAFT — the Analyst gate (`vajra next --advance`) BLOCKS starting this session
> while DRAFT. Flip to `APPROVED` once the human signs off (an approval token recorded here,
> the same trust model as a commit-approval; tamper-evidence is the later cross-stage ledger).

## Type
- **CODE** | **NO-CODE**. Max 2 assumptions · 2 retries · ~2h · 1 story · new chat · approval
  token before any commit.

## Goal
<One paragraph. The single outcome this session delivers. If it needs "and", split the session.>

## Deliverables
- <artifact 1 — the thing that ships>
- <artifact 2>
- `scripts/verify-session-{{NN}}.sh` (exits 0)
- `sessions/session-{{NN}}-summary.md` + exactly 3 ranked next candidates

## Acceptance (what must be answered — testable, EARS-style)
1. <A criterion the verify script can assert green/red — WHEN <x> THEN <observable y>.>
2. <A criterion a non-author could check by running one command.>
3. <The honest verdict this session must state plainly.>

## Design (the Architect gate — record the decision, cite the ADR/DECISION it rests on)
- design-significant: <yes — new/changed interface, new module, or an ADR deviation | no — pure fix>
- <rationale — why this shape and not the alternative, citing the ADR/DECISION ids it rests on; the Architect gate BLOCKS a design-significant prompt until this is substantive>

## Plan (ordered steps — cite the acceptance criteria each step covers, e.g. `covers: 1, 3`)
1. <first ordered step — replace me; annotate which acceptance criteria it satisfies>
2. <next step — the Planner gate BLOCKS until every acceptance criterion above is covered>

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: <sha — the real commit that landed this step; the Coder gate BLOCKS closing the session until every numbered plan step records a commit that EXISTS>

## Guardrails
- Slice to ONE story. Own the `.ai/` spine — no second store, no unapproved 8th command.
- Darshan every human reply · Varta against the live `.ai/`.
- <session-specific guardrail>

## Delta (vs ROADMAP — OpenSpec markers)
- `+` <what this session ADDS that did not exist>
- `~` <what it CHANGES about existing behaviour>
- `-` <what it REMOVES / retires / supersedes>
"#;

/// The intake inputs the Analyst SURFACES (S62 / J1) so a human authors the next job from real
/// context, not a bare slug. A Rust binary cannot *author* intent (that is the agent's job) — its
/// honest job is to put the real inputs in front of the author: the prior session number (the
/// `.ai/SESSION` SoT) and the ROADMAP "Next builds" block (the ranked candidates the roadmap
/// already carries). No second store: both are read from the existing `.ai/` spine.
#[derive(Debug, Clone, Default)]
pub struct Intake {
    /// The prior session number read from `.ai/SESSION`, if present/parseable.
    pub prior_session: Option<u32>,
    /// The ranked items under the ROADMAP "Next builds" heading (raw item text, order preserved).
    pub roadmap_next_builds: Vec<String>,
}

/// Read the intake inputs from the live `.ai/` spine (S62 / J1). Missing/garbled files degrade to
/// empty fields rather than erroring — surfacing partial context still beats a bare slug.
pub fn gather_intake(root: &Path) -> Intake {
    let prior_session = fs::read_to_string(root.join(".ai/SESSION"))
        .ok()
        .and_then(|s| s.trim().parse().ok());
    let roadmap = fs::read_to_string(root.join(".ai/ROADMAP.md")).unwrap_or_default();
    Intake {
        prior_session,
        roadmap_next_builds: extract_next_builds(&roadmap),
    }
}

/// Extract the ranked items under the ROADMAP "Next builds" heading. The block runs from that
/// heading to the next `#` heading or the next `**Prior ·` session entry (every session entry
/// starts that way), so stray numbered lines in later entries are never captured.
fn extract_next_builds(roadmap: &str) -> Vec<String> {
    let mut in_block = false;
    let mut out = Vec::new();
    for line in roadmap.lines() {
        let t = line.trim();
        let lower = t.to_ascii_lowercase();
        if !in_block {
            if t.starts_with('#') && lower.contains("next build") {
                in_block = true;
            }
            continue;
        }
        if t.starts_with('#') || t.starts_with("**Prior") {
            break;
        }
        if let Some(item) = ordered_item(t) {
            out.push(item);
        }
    }
    out
}

/// If `line` is a top-level ordered-list item (`N. text`), return its text. `None` otherwise.
fn ordered_item(line: &str) -> Option<String> {
    let (num, rest) = line.split_once('.')?;
    if num.is_empty() || !num.chars().all(|c| c.is_ascii_digit()) {
        return None;
    }
    let rest = rest.trim();
    (!rest.is_empty()).then(|| rest.to_string())
}

/// Render the intake as a human block (S62 / J1) — what `--scaffold`/`--intake` print so a
/// non-author sees the real inputs the Goal must fold in.
pub fn format_intake(intake: &Intake) -> String {
    let mut s = String::from("=== analyst intake (surface the real inputs — J1) ===\n");
    match intake.prior_session {
        Some(n) => s.push_str(&format!("prior session (.ai/SESSION): {n:02}\n")),
        None => s.push_str("prior session (.ai/SESSION): (unreadable)\n"),
    }
    if intake.roadmap_next_builds.is_empty() {
        s.push_str("ROADMAP next builds: (no \"Next builds\" block found)\n");
    } else {
        s.push_str("ROADMAP next builds:\n");
        for (i, item) in intake.roadmap_next_builds.iter().enumerate() {
            let clipped: String = item.chars().take(110).collect();
            let ell = if item.chars().count() > 110 {
                "…"
            } else {
                ""
            };
            s.push_str(&format!("  {}. {clipped}{ell}\n", i + 1));
        }
    }
    s.push_str("fold these into the Goal — the job comes from context, not the slug.\n");
    s
}

/// The required top-level sections of a well-formed prompt (the substantive gate). All four
/// appear in every real Vajra prompt, so the gate is backward-compatible with legacy prompts.
/// Each entry: (canonical name, the lowercased heading-substrings that satisfy it).
const REQUIRED_SECTIONS: &[(&str, &[&str])] = &[
    ("goal", &["goal", "the job", "job"]),
    ("deliverables", &["deliverable"]),
    (
        "acceptance",
        &["acceptance", "must answer", "must be answered", "what must"],
    ),
    ("guardrails", &["guardrail", "constraint"]),
];

/// Approval state read from a `Status:` line in the prompt.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Approval {
    /// Explicit `Status: DRAFT` — the gate blocks.
    Draft,
    /// Explicit `Status: APPROVED` — the gate passes.
    Approved,
    /// No `Status:` line at all (e.g. a legacy prompt) — the gate does not block on approval.
    Unmarked,
}

/// Substantiveness of the `## Delta` section (S61 — pays down the S54 "fakest green").
///
/// The S54 gate proved delta-recorded with `grep -q '## Delta'` — trivially true because the
/// scaffold hard-codes the heading. This distinguishes a heading from a *recorded* delta so the
/// gate can enforce a real one, not just its presence. A Rust binary cannot *compute* a semantic
/// delta (that is the agent's job) — its job is to enforce that a real one was *recorded*.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DeltaState {
    /// No `## Delta` heading at all (legacy prompts pre-S54). The gate only WARNS — legacy
    /// prompts stay valid (mirrors the backward-compat stance for required sections).
    Absent,
    /// A `## Delta` heading is present but every entry is still the template placeholder
    /// (`<what this session ADDS…>`) or empty — the S54 "fakest green". Since the Analyst's
    /// scaffold always emits this, it BLOCKS exactly the Analyst-generated prompts a human has
    /// not yet filled — at L2/L3.
    Placeholder,
    /// At least one real `+`/`~`/`-` entry the human filled in. The gate passes.
    Substantive,
}

/// Whether a session artifact records the mandated **exactly 3** ranked next-session candidates
/// (S62 / J2 — the same "enforce a *recorded* thing" move S61 made for Delta). The 3 options are
/// the A/B/C the founder picks from; `end_of_session.must_present_n_options: 3` already requires
/// them in the summary, so this enforces the *existing* contract — no new artifact, no second
/// store. A Rust binary cannot *author* the options (the agent does); it enforces the count.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum OptionsState {
    /// No "ranked candidates" section at all (a legacy summary, or none written yet). WARNS only —
    /// mirrors the DeltaState::Absent backward-compat stance.
    Unrecorded,
    /// A candidates section exists but records a number of options other than 3. BLOCKS (L2/L3) —
    /// a non-author cannot close a session on 2 or 4 options.
    WrongCount(usize),
    /// Exactly 3 ranked options recorded. Passes.
    Exactly3,
}

/// The result of validating one prompt file.
#[derive(Debug, Clone)]
pub struct PromptReport {
    /// Canonical names of required sections that are MISSING.
    pub missing_sections: Vec<String>,
    /// State of the `## Delta` section — absent / placeholder / substantive (S61).
    pub delta: DeltaState,
    /// Approval state parsed from the `Status:` line.
    pub approval: Approval,
}

impl PromptReport {
    /// Well-formed = every required section present. Delta/approval are separate signals so a
    /// legacy prompt (four sections, no delta, no status) still validates as well-formed.
    pub fn well_formed(&self) -> bool {
        self.missing_sections.is_empty()
    }
}

/// Parse a prompt's markdown and report its structure.
pub fn validate_prompt(content: &str) -> PromptReport {
    // Collect lowercased heading text (lines that begin with '#').
    let headings: Vec<String> = content
        .lines()
        .map(str::trim)
        .filter(|l| l.starts_with('#'))
        .map(|l| l.trim_start_matches('#').trim().to_ascii_lowercase())
        .collect();

    let mut missing_sections = Vec::new();
    for (name, needles) in REQUIRED_SECTIONS {
        let present = headings
            .iter()
            .any(|h| needles.iter().any(|needle| h.contains(needle)));
        if !present {
            missing_sections.push((*name).to_string());
        }
    }

    let delta = parse_delta(content);
    let approval = parse_approval(content);

    PromptReport {
        missing_sections,
        delta,
        approval,
    }
}

/// Classify the `## Delta` section: absent, still-placeholder, or substantive (S61).
///
/// Walks the lines of the Delta section (from the `delta` heading to the next heading) and
/// inspects its bullets. A bullet is *substantive* if, after stripping its `-`/`*` marker and any
/// leading `+`/`~`/`-` OpenSpec marker (bare or backticked), it has real text that is not itself a
/// `<template placeholder>`. One substantive bullet is enough.
fn parse_delta(content: &str) -> DeltaState {
    let mut in_delta = false;
    let mut saw_heading = false;
    let mut saw_substantive = false;

    for line in content.lines() {
        let trimmed = line.trim();
        if trimmed.starts_with('#') {
            let heading = trimmed.trim_start_matches('#').trim().to_ascii_lowercase();
            in_delta = heading.contains("delta");
            if in_delta {
                saw_heading = true;
            }
            continue;
        }
        if in_delta {
            if let Some(desc) = delta_bullet_description(trimmed) {
                if !desc.is_empty() && !desc.starts_with('<') {
                    saw_substantive = true;
                }
            }
        }
    }

    match (saw_heading, saw_substantive) {
        (false, _) => DeltaState::Absent,
        (true, false) => DeltaState::Placeholder,
        (true, true) => DeltaState::Substantive,
    }
}

/// If `line` is a Delta bullet, return the human description with the list marker and the leading
/// OpenSpec `+`/`~`/`-`/`−` marker (bare or backticked) stripped. `None` for non-bullet lines.
fn delta_bullet_description(line: &str) -> Option<String> {
    // Strip the list marker, then (trim first, so leading space can't defeat it) the opening
    // backtick of a `\`+\`` code-span, then the `+`/`~`/`-`/`−` marker, then the closing backtick.
    let rest = line
        .strip_prefix('-')
        .or_else(|| line.strip_prefix('*'))?
        .trim()
        .trim_start_matches('`')
        .trim_start();
    let rest = rest
        .strip_prefix('+')
        .or_else(|| rest.strip_prefix('~'))
        .or_else(|| rest.strip_prefix('-'))
        .or_else(|| rest.strip_prefix('−')) // U+2212, used in prose
        .unwrap_or(rest);
    Some(rest.trim_start_matches('`').trim().to_string())
}

/// Read the first `Status:` line (heading-agnostic — it may live inside a blockquote).
fn parse_approval(content: &str) -> Approval {
    for line in content.lines() {
        let lower = line.to_ascii_lowercase();
        // Match "status:" allowing markdown emphasis around it (**Status:**, > **Status:**).
        let cleaned = lower.replace(['*', '>', '`'], "");
        let cleaned = cleaned.trim();
        if let Some(rest) = cleaned.strip_prefix("status:") {
            if rest.contains("approved") {
                return Approval::Approved;
            }
            if rest.contains("draft") {
                return Approval::Draft;
            }
        }
    }
    Approval::Unmarked
}

/// Classify a session summary's ranked next-session candidates (S62 / J2).
///
/// `Unrecorded` when no "ranked candidates" section exists (legacy compat → WARN); otherwise the
/// count of distinct ranked options in that section is enforced to be exactly 3.
pub fn options_state(content: &str) -> OptionsState {
    if !has_candidate_section(content) {
        return OptionsState::Unrecorded;
    }
    match count_ranked_options(content) {
        3 => OptionsState::Exactly3,
        n => OptionsState::WrongCount(n),
    }
}

/// True if the artifact has a heading marking the ranked next-session candidates block — the
/// summary's "N ranked candidates" (per `end_of_session.must_present_n_options`).
fn has_candidate_section(content: &str) -> bool {
    content
        .lines()
        .filter(|l| l.trim_start().starts_with('#'))
        .any(is_candidate_heading)
}

/// A heading opens the candidates block if it names the candidates (e.g. "Next — exactly 3 ranked
/// candidates", "3 ranked S63 candidates").
fn is_candidate_heading(line: &str) -> bool {
    let h = line
        .trim_start()
        .trim_start_matches('#')
        .trim()
        .to_ascii_lowercase();
    h.contains("candidate")
}

/// Count the distinct ranked options (A/B/C…) recorded under the candidates heading (S62 / J2).
///
/// Scoped to the candidates section so stray lettered bullets elsewhere are not miscounted, and
/// distinct-lettered so a multi-line option entry (whose only lettered line is its first) counts
/// once. Returns 0 when no candidates section exists.
pub fn count_ranked_options(content: &str) -> usize {
    let mut in_section = false;
    let mut letters: Vec<char> = Vec::new();
    for line in content.lines() {
        if line.trim_start().starts_with('#') {
            in_section = is_candidate_heading(line);
            continue;
        }
        if in_section {
            if let Some(c) = option_letter(line) {
                if !letters.contains(&c) {
                    letters.push(c);
                }
            }
        }
    }
    letters.len()
}

/// If `line` is a ranked-option bullet, return its leading letter. A bullet counts only when, after
/// its `-`/`*` list marker and any `**`/`*` emphasis, it starts with a single uppercase letter
/// followed by a non-alphanumeric (so `- **A 🥇 — …` / `- A. …` count, but `- **Abstract …` and a
/// `*Goal:*` sub-bullet do not).
fn option_letter(line: &str) -> Option<char> {
    let rest = line
        .trim()
        .strip_prefix('-')
        .or_else(|| line.trim().strip_prefix('*'))?
        .trim_start()
        .trim_start_matches('*')
        .trim_start();
    let mut chars = rest.chars();
    let c = chars.next()?;
    if !c.is_ascii_uppercase() {
        return None;
    }
    match chars.next() {
        Some(n) if n.is_ascii_alphanumeric() => None,
        _ => Some(c),
    }
}

/// The options gate's decision for one session's summary (S62 / J2). Mirrors `GateVerdict`.
#[derive(Debug, Clone)]
pub struct OptionsVerdict {
    pub session: u32,
    /// The summary found for `session` (repo-relative), if any.
    pub summary_path: Option<String>,
    /// Blocking reasons — non-empty means L2/L3 must refuse the closeout/advance.
    pub reasons: Vec<String>,
    /// Non-blocking nudges (e.g. no candidates section at all).
    pub warnings: Vec<String>,
}

impl OptionsVerdict {
    pub fn blocked(&self) -> bool {
        !self.reasons.is_empty()
    }
}

/// The options gate (S62 / J2): closing `session` requires its summary to record **exactly 3**
/// ranked next-session candidates. A `WrongCount` BLOCKS (L2/L3); a wholly absent candidates
/// section or missing summary only WARNS (legacy compat). Enforces the existing
/// `end_of_session.must_present_n_options` contract — no new artifact.
pub fn options_gate(root: &Path, session: u32) -> OptionsVerdict {
    let mut reasons = Vec::new();
    let mut warnings = Vec::new();

    let summary_path = find_summary_for(root, session);
    match &summary_path {
        None => warnings.push(format!(
            "no summary for session {session:02} yet — record exactly 3 ranked next candidates in \
             sessions/session-{session:02}-summary.md before closing"
        )),
        Some(rel) => match fs::read_to_string(root.join(rel)) {
            Err(e) => reasons.push(format!("cannot read {rel}: {e}")),
            Ok(content) => match options_state(&content) {
                OptionsState::Exactly3 => {}
                OptionsState::WrongCount(n) => reasons.push(format!(
                    "{rel} records {n} ranked next candidate(s), not exactly 3 — a session must \
                     present exactly 3 A/B/C options (end_of_session.must_present_n_options)"
                )),
                OptionsState::Unrecorded => warnings.push(format!(
                    "{rel} has no ranked-candidates section (add exactly 3 A/B/C next candidates)"
                )),
            },
        },
    }

    OptionsVerdict {
        session,
        summary_path,
        reasons,
        warnings,
    }
}

/// Find `sessions/session-NN-summary.md` for a session number.
pub fn find_summary_for(root: &Path, session: u32) -> Option<String> {
    let rel = format!("sessions/session-{session:02}-summary.md");
    root.join(&rel).is_file().then_some(rel)
}

/// The gate's decision for advancing INTO `session`.
#[derive(Debug, Clone)]
pub struct GateVerdict {
    pub session: u32,
    /// The prompt found for `session` (repo-relative), if any.
    pub prompt_path: Option<String>,
    /// Blocking reasons — non-empty means L2/L3 must refuse the advance.
    pub reasons: Vec<String>,
    /// Non-blocking nudges (e.g. missing delta, a stray second store).
    pub warnings: Vec<String>,
}

impl GateVerdict {
    pub fn blocked(&self) -> bool {
        !self.reasons.is_empty()
    }
}

/// Find `prompts/NN-task-*.md` for a session number.
pub fn find_prompt_for(root: &Path, session: u32) -> Option<String> {
    let prompts_dir = root.join("prompts");
    let prefix = format!("{session:02}-task-");
    fs::read_dir(&prompts_dir)
        .ok()?
        .filter_map(|e| e.ok())
        .find_map(|e| {
            let name = e.file_name().to_string_lossy().to_string();
            (name.starts_with(&prefix) && name.ends_with(".md")).then(|| format!("prompts/{name}"))
        })
}

/// Detect a foreign "second store" — the exact drift the S54 framing forbids (a `spec.md` or a
/// `specs/` tree parallel to the `.ai/`+`prompts/` spine). Returned as warnings, and asserted
/// absent by the verify script.
pub fn detect_second_store(root: &Path) -> Vec<String> {
    let mut found = Vec::new();
    // Lowercase canonical names only — a case-insensitive FS (macOS) would double-count variants.
    for candidate in ["spec.md", "specs", ".spec"] {
        if root.join(candidate).exists() {
            found.push(candidate.to_string());
        }
    }
    found
}

/// The Analyst gate. Advancing INTO `session` requires a present, well-formed, non-DRAFT prompt
/// carrying a substantive (not placeholder) delta.
///
/// Blocking (L2/L3 refuse): no `prompts/NN-task-*.md`; a required section missing (malformed);
/// `Status: DRAFT` (generated but not yet approved); or a placeholder `## Delta` (S61 — the
/// scaffold's untouched `<...>`, never filled in).
///
/// Warning (never blocks): a wholly absent `## Delta` (legacy prompts), a stray second store.
pub fn gate(root: &Path, session: u32) -> GateVerdict {
    let mut reasons = Vec::new();
    let mut warnings = Vec::new();

    let prompt_path = find_prompt_for(root, session);
    match &prompt_path {
        None => {
            reasons.push(format!(
                "no prompt for session {session:02} — run `vajra next --scaffold {session:02} <slug>`, \
                 fill it, get it APPROVED"
            ));
        }
        Some(rel) => match fs::read_to_string(root.join(rel)) {
            Err(e) => reasons.push(format!("cannot read {rel}: {e}")),
            Ok(content) => {
                let report = validate_prompt(&content);
                if !report.well_formed() {
                    reasons.push(format!(
                        "{rel} is malformed — missing section(s): {}",
                        report.missing_sections.join(", ")
                    ));
                }
                if report.approval == Approval::Draft {
                    reasons.push(format!(
                        "{rel} is still DRAFT — the Analyst produced it but it is not APPROVED"
                    ));
                }
                // S61: a delta must be RECORDED, not merely have its heading present. A
                // placeholder delta (the scaffold's untouched `<...>`) BLOCKS at L2/L3 — the
                // exact "fakest green" the S54 cold review named. A wholly absent delta only
                // warns, so legacy prompts (pre-Delta) stay valid.
                match report.delta {
                    DeltaState::Substantive => {}
                    DeltaState::Placeholder => reasons.push(format!(
                        "{rel} has a placeholder `## Delta` (still the template `<...>`) — \
                         record real +/~/- entries vs ROADMAP before advancing"
                    )),
                    DeltaState::Absent => warnings.push(format!(
                        "{rel} has no `## Delta` section (add +/~/- vs ROADMAP)"
                    )),
                }
            }
        },
    }

    for store in detect_second_store(root) {
        warnings.push(format!(
            "second store `{store}` found — Vajra's spec is the prompt; keep to the .ai/+prompts/ spine"
        ));
    }

    GateVerdict {
        session,
        prompt_path,
        reasons,
        warnings,
    }
}

/// Render the template for a new prompt (`scaffold_prompt` writes it; kept pure for testing).
pub fn render_scaffold(session: u32, slug: &str) -> String {
    PROMPT_TEMPLATE
        .replace("{{NN}}", &format!("{session:02}"))
        .replace("{{SLUG}}", slug)
}

/// Write `prompts/NN-task-<slug>.md` from the template. Refuses to clobber an existing file
/// (the Analyst generates a draft; it never silently overwrites a human's prompt).
pub fn scaffold_prompt(root: &Path, session: u32, slug: &str) -> Result<PathBuf, String> {
    if slug.is_empty()
        || !slug
            .chars()
            .all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == '-')
    {
        return Err(format!("slug must be lowercase-kebab (got {slug:?})"));
    }
    let rel = format!("prompts/{session:02}-task-{slug}.md");
    let path = root.join(&rel);
    if path.exists() {
        return Err(format!("{rel} already exists — refusing to overwrite"));
    }
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent).map_err(|e| format!("cannot create prompts/: {e}"))?;
    }
    fs::write(&path, render_scaffold(session, slug))
        .map_err(|e| format!("cannot write {rel}: {e}"))?;
    Ok(path)
}

#[cfg(test)]
mod tests {
    use super::*;

    const GOOD: &str = r#"# Session 56 — planner: plan a slice
> **Status:** APPROVED
## Goal
Do one thing.
## Deliverables
- a thing
## Acceptance (what must be answered)
1. does it work?
## Guardrails
- one story
## Delta (vs ROADMAP)
- `+` a stage
"#;

    #[test]
    fn good_prompt_is_well_formed_approved_with_delta() {
        let r = validate_prompt(GOOD);
        assert!(r.well_formed(), "missing: {:?}", r.missing_sections);
        assert_eq!(r.delta, DeltaState::Substantive);
        assert_eq!(r.approval, Approval::Approved);
    }

    #[test]
    fn delta_states_absent_placeholder_substantive() {
        // No `## Delta` heading at all -> Absent (legacy compat).
        assert_eq!(parse_delta("# S\n## Goal\nx\n"), DeltaState::Absent);
        // The scaffold's untouched template -> Placeholder (every bullet is a `<...>`).
        assert_eq!(parse_delta(PROMPT_TEMPLATE), DeltaState::Placeholder);
        assert_eq!(
            parse_delta("## Delta\n- `+` <what this session ADDS that did not exist>\n"),
            DeltaState::Placeholder
        );
        // Heading present but no bullets filled -> Placeholder (not a free pass).
        assert_eq!(
            parse_delta("## Delta (vs ROADMAP)\n\n"),
            DeltaState::Placeholder
        );
        // A single real entry (bare or backticked marker) -> Substantive.
        assert_eq!(
            parse_delta("## Delta\n- `+` Analyst updates the TASK.md pointer on generate\n"),
            DeltaState::Substantive
        );
        assert_eq!(
            parse_delta("## Delta\n- + a real bare-marker change\n"),
            DeltaState::Substantive
        );
        // One placeholder + one real entry still counts as substantive.
        assert_eq!(
            parse_delta("## Delta\n- `+` <placeholder>\n- `-` retires the heading grep\n"),
            DeltaState::Substantive
        );
    }

    #[test]
    fn missing_sections_are_reported() {
        let r = validate_prompt("# Session 56\n## Goal\nx\n");
        assert!(!r.well_formed());
        assert!(r.missing_sections.contains(&"deliverables".to_string()));
        assert!(r.missing_sections.contains(&"acceptance".to_string()));
        assert!(r.missing_sections.contains(&"guardrails".to_string()));
    }

    #[test]
    fn legacy_headings_still_validate() {
        // "The job" satisfies goal; "What S54 must answer" satisfies acceptance; "constraint"
        // satisfies guardrails — the real prompt shapes used across sessions 40-54.
        let legacy = "# S54\n## The job\nx\n## Deliverables\n- y\n## What S54 must answer\n1. z\n## Design constraints\n- c\n";
        let r = validate_prompt(legacy);
        assert!(r.well_formed(), "missing: {:?}", r.missing_sections);
        assert_eq!(r.approval, Approval::Unmarked);
    }

    #[test]
    fn draft_status_is_parsed() {
        assert_eq!(
            validate_prompt("> **Status:** DRAFT\n").approval,
            Approval::Draft
        );
        assert_eq!(
            validate_prompt("Status: approved\n").approval,
            Approval::Approved
        );
        assert_eq!(
            validate_prompt("no status here\n").approval,
            Approval::Unmarked
        );
    }

    #[test]
    fn scaffold_is_well_formed_and_draft() {
        let out = render_scaffold(56, "planner-stage");
        assert!(out.contains("# Session 56 — planner-stage"));
        let r = validate_prompt(&out);
        assert!(
            r.well_formed(),
            "scaffold missing: {:?}",
            r.missing_sections
        );
        // A fresh scaffold's delta is a PLACEHOLDER — that is exactly why the gate blocks it
        // until a human records a real delta (S61).
        assert_eq!(r.delta, DeltaState::Placeholder);
        assert_eq!(
            r.approval,
            Approval::Draft,
            "a fresh scaffold must gate as DRAFT"
        );
    }

    #[test]
    fn gate_blocks_when_no_prompt() {
        let tmp = tempfile::tempdir().unwrap();
        fs::create_dir_all(tmp.path().join("prompts")).unwrap();
        let v = gate(tmp.path(), 99);
        assert!(v.blocked());
        assert!(v.reasons[0].contains("no prompt"));
    }

    #[test]
    fn gate_blocks_draft_then_passes_when_approved() {
        let tmp = tempfile::tempdir().unwrap();
        scaffold_prompt(tmp.path(), 56, "planner").unwrap();
        let rel = tmp.path().join("prompts/56-task-planner.md");
        // Fresh scaffold is DRAFT -> blocked.
        let v = gate(tmp.path(), 56);
        assert!(v.blocked());
        assert!(v.reasons.iter().any(|r| r.contains("DRAFT")));
        // Approve it, but the delta is still the scaffold placeholder -> STILL blocked (S61).
        let approved = fs::read_to_string(&rel)
            .unwrap()
            .replace("DRAFT", "APPROVED");
        fs::write(&rel, &approved).unwrap();
        let v = gate(tmp.path(), 56);
        assert!(v.blocked(), "placeholder delta must block");
        assert!(v.reasons.iter().any(|r| r.contains("placeholder")));
        // Record a real delta -> passes, no blocking reasons.
        let filled = approved.replace(
            "<what this session ADDS that did not exist>",
            "a real, recorded addition",
        );
        fs::write(&rel, filled).unwrap();
        let v = gate(tmp.path(), 56);
        assert!(!v.blocked(), "reasons: {:?}", v.reasons);
    }

    #[test]
    fn gate_blocks_malformed_prompt() {
        let tmp = tempfile::tempdir().unwrap();
        fs::create_dir_all(tmp.path().join("prompts")).unwrap();
        fs::write(
            tmp.path().join("prompts/57-task-x.md"),
            "# S57\n## Goal\nonly a goal\n",
        )
        .unwrap();
        let v = gate(tmp.path(), 57);
        assert!(v.blocked());
        assert!(v.reasons.iter().any(|r| r.contains("malformed")));
    }

    #[test]
    fn gate_blocks_placeholder_delta_passes_substantive() {
        let tmp = tempfile::tempdir().unwrap();
        fs::create_dir_all(tmp.path().join("prompts")).unwrap();
        let head = "# S60\n> Status: APPROVED\n## Goal\ng\n## Deliverables\n- d\n\
                    ## Acceptance\n1. a\n## Guardrails\n- x\n## Delta\n";
        let rel = tmp.path().join("prompts/60-task-x.md");
        // Well-formed + approved, but the delta is the untouched placeholder -> BLOCK (S61).
        fs::write(&rel, format!("{head}- `+` <what this session ADDS>\n")).unwrap();
        let v = gate(tmp.path(), 60);
        assert!(v.blocked(), "placeholder delta must block");
        assert!(v.reasons.iter().any(|r| r.contains("placeholder")));
        // A real recorded delta -> passes.
        fs::write(&rel, format!("{head}- `+` a real recorded change\n")).unwrap();
        let v = gate(tmp.path(), 60);
        assert!(!v.blocked(), "reasons: {:?}", v.reasons);
    }

    #[test]
    fn missing_delta_warns_not_blocks() {
        let tmp = tempfile::tempdir().unwrap();
        fs::create_dir_all(tmp.path().join("prompts")).unwrap();
        // Well-formed core four, approved, but no ## Delta.
        fs::write(
            tmp.path().join("prompts/58-task-x.md"),
            "# S58\n> Status: APPROVED\n## Goal\ng\n## Deliverables\n- d\n## Acceptance\n1. a\n## Guardrails\n- x\n",
        )
        .unwrap();
        let v = gate(tmp.path(), 58);
        assert!(!v.blocked(), "reasons: {:?}", v.reasons);
        assert!(v.warnings.iter().any(|w| w.contains("Delta")));
    }

    #[test]
    fn detect_second_store_flags_spec_md() {
        let tmp = tempfile::tempdir().unwrap();
        assert!(detect_second_store(tmp.path()).is_empty());
        fs::write(tmp.path().join("spec.md"), "x").unwrap();
        assert_eq!(detect_second_store(tmp.path()), vec!["spec.md".to_string()]);
    }

    #[test]
    fn scaffold_refuses_overwrite_and_bad_slug() {
        let tmp = tempfile::tempdir().unwrap();
        scaffold_prompt(tmp.path(), 56, "planner").unwrap();
        assert!(scaffold_prompt(tmp.path(), 56, "planner")
            .unwrap_err()
            .contains("already exists"));
        assert!(scaffold_prompt(tmp.path(), 56, "Bad_Slug")
            .unwrap_err()
            .contains("kebab"));
    }

    // ---- S62 / J1: Intake surfaces the real inputs ----

    const ROADMAP: &str = "\
# Vajra — Working Roadmap

### Next builds — RE-RANKED S54

Some intro prose that is not a list item.

1. **🥇 The fidelity / acceptance auditor — the missing heart.**
2. **🥈 The cross-stage delta ledger (durability = evidence).**
3. **🥉 Pipeline breadth (Planner / Architect / …).**

*Carry: a footnote line, not an option.*

**Prior · Session 53 — a past entry with its own 1. and 2. stray numbers.**
1. a stray numbered line inside a past entry that must NOT be captured.
";

    #[test]
    fn extract_next_builds_collects_only_the_block() {
        let items = extract_next_builds(ROADMAP);
        assert_eq!(items.len(), 3, "got: {items:?}");
        assert!(items[0].contains("fidelity"));
        assert!(items[2].contains("Pipeline breadth"));
        // The stray `1.` under the later **Prior** entry is not captured.
        assert!(!items.iter().any(|i| i.contains("must NOT be captured")));
    }

    #[test]
    fn gather_intake_reads_session_and_roadmap() {
        let tmp = tempfile::tempdir().unwrap();
        let ai = tmp.path().join(".ai");
        fs::create_dir_all(&ai).unwrap();
        fs::write(ai.join("SESSION"), "61\n").unwrap();
        fs::write(ai.join("ROADMAP.md"), ROADMAP).unwrap();

        let intake = gather_intake(tmp.path());
        assert_eq!(intake.prior_session, Some(61));
        assert_eq!(intake.roadmap_next_builds.len(), 3);

        let rendered = format_intake(&intake);
        assert!(rendered.contains("prior session (.ai/SESSION): 61"));
        assert!(rendered.contains("fidelity"));
        assert!(rendered.contains("from context, not the slug"));
    }

    #[test]
    fn gather_intake_degrades_when_files_missing() {
        let tmp = tempfile::tempdir().unwrap();
        let intake = gather_intake(tmp.path());
        assert_eq!(intake.prior_session, None);
        assert!(intake.roadmap_next_builds.is_empty());
        // Still renders a usable block, not a panic.
        assert!(format_intake(&intake).contains("(unreadable)"));
    }

    // ---- S62 / J2: Options enforced (exactly 3 recorded) ----

    fn summary_with(options: &[&str]) -> String {
        let mut s = String::from("# Session summary\n\n## Next — ranked candidates (S63)\n\n");
        for o in options {
            s.push_str(&format!(
                "- **{o} — a candidate.**\n  *Goal:* do the thing.\n"
            ));
        }
        s
    }

    #[test]
    fn count_ranked_options_counts_distinct_letters() {
        // Sub-bullets like `*Goal:*` and multi-line entries do not inflate the count.
        assert_eq!(
            count_ranked_options(&summary_with(&["A 🥇", "B 🥈", "C 🥉"])),
            3
        );
        assert_eq!(count_ranked_options(&summary_with(&["A", "B"])), 2);
        assert_eq!(
            count_ranked_options(&summary_with(&["A", "B", "C", "D"])),
            4
        );
        // No candidates heading -> 0 (scoped to the section).
        assert_eq!(count_ranked_options("# S\n## Notes\n- **A a thing**\n"), 0);
    }

    #[test]
    fn options_state_absent_wrong_exact() {
        assert_eq!(options_state("# S\n## Goal\nx\n"), OptionsState::Unrecorded);
        assert_eq!(
            options_state(&summary_with(&["A", "B"])),
            OptionsState::WrongCount(2)
        );
        assert_eq!(
            options_state(&summary_with(&["A", "B", "C", "D"])),
            OptionsState::WrongCount(4)
        );
        assert_eq!(
            options_state(&summary_with(&["A 🥇", "B 🥈", "C 🥉"])),
            OptionsState::Exactly3
        );
    }

    #[test]
    fn options_gate_blocks_wrong_count_passes_three_warns_absent() {
        let tmp = tempfile::tempdir().unwrap();
        let sessions = tmp.path().join("sessions");
        fs::create_dir_all(&sessions).unwrap();

        // No summary at all -> warn, not block (legacy/early compat).
        let v = options_gate(tmp.path(), 62);
        assert!(!v.blocked());
        assert!(v.warnings.iter().any(|w| w.contains("no summary")));

        // 2 options -> BLOCK.
        fs::write(
            sessions.join("session-62-summary.md"),
            summary_with(&["A", "B"]),
        )
        .unwrap();
        let v = options_gate(tmp.path(), 62);
        assert!(v.blocked(), "2 options must block");
        assert!(v.reasons.iter().any(|r| r.contains("not exactly 3")));

        // 4 options -> BLOCK.
        fs::write(
            sessions.join("session-62-summary.md"),
            summary_with(&["A", "B", "C", "D"]),
        )
        .unwrap();
        assert!(
            options_gate(tmp.path(), 62).blocked(),
            "4 options must block"
        );

        // Exactly 3 -> PASS.
        fs::write(
            sessions.join("session-62-summary.md"),
            summary_with(&["A 🥇", "B 🥈", "C 🥉"]),
        )
        .unwrap();
        let v = options_gate(tmp.path(), 62);
        assert!(!v.blocked(), "reasons: {:?}", v.reasons);
    }
}
