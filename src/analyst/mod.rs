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

## Guardrails
- Slice to ONE story. Own the `.ai/` spine — no second store, no unapproved 8th command.
- Darshan every human reply · Varta against the live `.ai/`.
- <session-specific guardrail>

## Delta (vs ROADMAP — OpenSpec markers)
- `+` <what this session ADDS that did not exist>
- `~` <what it CHANGES about existing behaviour>
- `-` <what it REMOVES / retires / supersedes>
"#;

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
}
