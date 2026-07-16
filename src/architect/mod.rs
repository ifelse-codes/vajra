//! The Architect — the pipeline's DESIGN gate (S67).
//!
//! Vajra is a GOVERNED multi-agent SDLC pipeline (DECISION-001, S53). The Analyst (S54+S61+S62)
//! governs the **WHAT** (intent → the accepted prompt); the Planner (S64) governs the **HOW-plan**
//! (an ordered, coverage-checked `## Plan`). The Architect governs the **DESIGN decision** that
//! sits between them: a session that changes an interface, adds a module, or deviates from a
//! locked ADR must record *why* — before the plan is executed.
//!
//! The design record is NOT a new artifact. Vajra's design spine ALREADY exists: `docs/adr/`
//! (the locked ADRs) + `docs/decisions/` (the DECISION records) + the rationale section inside
//! the session's own prompt. Like the Analyst refusing a `spec.md` and the Planner refusing a
//! `plan.md`, the Architect refuses a `design.md`: the rationale lives in a `## Design` section
//! INSIDE `prompts/NN-task-<slug>.md` (memory `feedback-map-concepts-to-vajra`,
//! `feedback-distill-no-drift`). No second store, no 8th command (rides `vajra next`).
//!
//! The binary **surfaces + enforces, never authors** (the S54 anti-trap): a Rust binary cannot
//! make a design decision or judge whether a rationale is *good*. The honest contract, the same
//! "enforce a RECORDED thing" move as S61 (Delta) and S64 (`covers:`):
//!
//! 1. Significance is a **recorded marker**, never guessed: the author writes
//!    `design-significant: yes` (new/changed interface, new module, ADR deviation) or
//!    `design-significant: no` (pure fix). The gate reads the marker; it does not infer.
//! 2. A design-significant prompt must carry a **substantive** `## Design` rationale — real text,
//!    not the template `<...>`, citing the locked spine (`ADR-000N` / `DECISION-00N`) it rests on.
//! 3. The gate enforces the *form* of the record (marker + non-placeholder + citation), not the
//!    semantic quality of the design — that honesty is stated, not hidden.

use std::fs;
use std::path::Path;

use crate::analyst::find_prompt_for;

/// Which side of the design spine a record (or citation) belongs to.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum DesignRefKind {
    /// `docs/adr/NNNN-*.md` — a locked ADR.
    Adr,
    /// `docs/decisions/DECISION-NNN-*.md` — a locked product/process decision.
    Decision,
}

/// One locked design record surfaced from the repo's design spine.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DesignRecord {
    pub kind: DesignRefKind,
    pub num: u32,
    /// Normalized id (`ADR-0003`, `DECISION-002`).
    pub id: String,
    /// The record's first `#` heading text (filename stem when headless).
    pub title: String,
    /// Repo-relative path.
    pub path: String,
}

/// The recorded design-significance marker (`design-significant:`), read — never guessed — from
/// the prompt. Mirrors the `Status:`/`covers:` recorded-marker contracts.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Significance {
    /// No marker line, or the value is still the template placeholder (`<...>`)/empty.
    Unrecorded,
    /// `design-significant: no` / `none` — a pure fix; the gate never blocks. Carries the value.
    No(String),
    /// Any other recorded value (`yes`, `new-module …`) — the gate enforces a recorded rationale.
    Yes(String),
}

/// State of a prompt's `## Design` rationale vs its recorded significance (S67). Mirrors the
/// Planner's `PlanState`: only a design-significant prompt can block; everything else is
/// legacy-compatible (WARN at most).
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum DesignState {
    /// Not recorded as design-significant (marker absent, placeholder, or an explicit `no`).
    /// Never blocks — a pure fix / legacy prompt needs no design rationale.
    NotSignificant,
    /// Recorded design-significant but NO `## Design` section at all. BLOCKS.
    Missing,
    /// Recorded design-significant with a `## Design` that is not substantive: still the template
    /// `<...>`/empty, or (when the repo has a design spine) citing no `ADR-000N`/`DECISION-00N`.
    /// BLOCKS.
    Placeholder,
    /// Recorded design-significant with a real, spine-citing rationale. Passes.
    Substantive,
}

impl DesignState {
    /// A blocking state refuses the advance at L2/L3. Only a design-significant prompt with no
    /// real recorded rationale blocks.
    pub fn blocks(&self) -> bool {
        matches!(self, DesignState::Missing | DesignState::Placeholder)
    }
}

/// The parsed design facts of one prompt: the recorded marker, the classified state, and the
/// spine ids its `## Design` cites (normalized, deduped; ADR citations before decision citations
/// within a line — a set, not a positional record).
#[derive(Debug, Clone)]
pub struct DesignReport {
    pub significance: Significance,
    pub state: DesignState,
    pub cited: Vec<(DesignRefKind, u32)>,
}

/// Normalize a spine reference to its display id (`ADR-0003` / `DECISION-002` — the widths the
/// repo's own filenames use).
pub fn ref_id(kind: DesignRefKind, num: u32) -> String {
    match kind {
        DesignRefKind::Adr => format!("ADR-{num:04}"),
        DesignRefKind::Decision => format!("DECISION-{num:03}"),
    }
}

/// A heading opens the `## Design` block. Matched on the first token being exactly `design` (so a
/// title like "the DESIGN gate" inside prose never counts), excluding the legacy "Design
/// constraints" heading, which is a guardrails synonym, not the rationale section.
fn is_design_heading(line: &str) -> bool {
    let h = line.trim_start_matches('#').trim().to_ascii_lowercase();
    h.split_whitespace().next() == Some("design") && !h.contains("constraint")
}

/// Read the first recorded `design-significant:` marker line. The line may be a bullet and carry
/// markdown emphasis (`- **design-significant:** yes`), mirroring `parse_approval`'s cleanup.
pub fn design_significance(content: &str) -> Significance {
    for line in content.lines() {
        let cleaned = line.to_ascii_lowercase().replace(['*', '>', '`'], "");
        let cleaned = cleaned
            .trim()
            .strip_prefix('-')
            .unwrap_or(cleaned.trim())
            .trim_start();
        if let Some(value) = cleaned.strip_prefix("design-significant:") {
            let value = value.trim();
            if value.is_empty() || value.starts_with('<') {
                return Significance::Unrecorded;
            }
            let token: String = value
                .split_whitespace()
                .next()
                .unwrap_or("")
                .chars()
                .filter(|c| c.is_ascii_alphanumeric())
                .collect();
            return match token.as_str() {
                "no" | "none" => Significance::No(value.to_string()),
                _ => Significance::Yes(value.to_string()),
            };
        }
    }
    Significance::Unrecorded
}

/// Scan a line for spine citations: every `adr-<digits>` / `decision-<digits>` occurrence
/// (case-insensitive). `ADR-3` and `ADR-0003` normalize to the same reference.
fn cited_refs_on(line: &str, out: &mut Vec<(DesignRefKind, u32)>) {
    let lower = line.to_ascii_lowercase();
    for (needle, kind) in [
        ("adr-", DesignRefKind::Adr),
        ("decision-", DesignRefKind::Decision),
    ] {
        let mut rest = lower.as_str();
        while let Some(i) = rest.find(needle) {
            let after = &rest[i + needle.len()..];
            let digits: String = after.chars().take_while(char::is_ascii_digit).collect();
            if let Ok(n) = digits.parse::<u32>() {
                if !out.contains(&(kind, n)) {
                    out.push((kind, n));
                }
            }
            rest = after;
        }
    }
}

/// Parse a prompt's design facts (S67).
///
/// - marker absent/placeholder, or an explicit `no`      → `NotSignificant` (never blocks)
/// - marker `yes` + no `## Design` heading               → `Missing`     (BLOCK)
/// - marker `yes` + placeholder/uncited `## Design`      → `Placeholder` (BLOCK)
/// - marker `yes` + real rationale citing the spine      → `Substantive` (PASS)
///
/// `require_citation` is false when the repo has no `docs/adr/`+`docs/decisions/` records at all
/// (a fresh `vajra init` project) — demanding a citation of a spine that does not exist would
/// block forever, so substance then means a real, non-placeholder rationale.
pub fn parse_design(content: &str, require_citation: bool) -> DesignReport {
    let significance = design_significance(content);

    let mut in_design = false;
    let mut saw_heading = false;
    let mut saw_real_rationale = false;
    let mut cited: Vec<(DesignRefKind, u32)> = Vec::new();

    for line in content.lines() {
        let t = line.trim();
        if t.starts_with('#') {
            in_design = is_design_heading(t);
            if in_design {
                saw_heading = true;
            }
            continue;
        }
        if in_design && !t.is_empty() {
            cited_refs_on(t, &mut cited);
            if is_rationale_line(t) {
                saw_real_rationale = true;
            }
        }
    }

    let state = match &significance {
        Significance::Unrecorded | Significance::No(_) => DesignState::NotSignificant,
        Significance::Yes(_) => {
            if !saw_heading {
                DesignState::Missing
            } else if !saw_real_rationale || (require_citation && cited.is_empty()) {
                DesignState::Placeholder
            } else {
                DesignState::Substantive
            }
        }
    };

    DesignReport {
        significance,
        state,
        cited,
    }
}

/// True when a `## Design` line is real rationale text the author wrote: not the significance
/// marker itself, and not (after its `-`/`*`/`N.` list marker) a template `<...>` placeholder.
fn is_rationale_line(line: &str) -> bool {
    let cleaned = line.to_ascii_lowercase().replace(['*', '>', '`'], "");
    let cleaned = cleaned
        .trim()
        .strip_prefix('-')
        .unwrap_or(cleaned.trim())
        .trim_start();
    if cleaned.starts_with("design-significant:") {
        return false;
    }
    let body = strip_list_marker(line.trim());
    !body.is_empty() && !body.starts_with('<')
}

/// Strip a leading `-`/`*` bullet or `N.` ordinal from a line, returning the text.
fn strip_list_marker(line: &str) -> &str {
    if let Some(rest) = line.strip_prefix('-').or_else(|| line.strip_prefix('*')) {
        return rest.trim();
    }
    if let Some((num, rest)) = line.split_once('.') {
        if !num.is_empty() && num.chars().all(|c| c.is_ascii_digit()) {
            return rest.trim();
        }
    }
    line
}

/// Surface the repo's locked design spine: every ADR under `docs/adr/` (`NNNN-*.md`) and every
/// decision under `docs/decisions/` (`DECISION-NNN-*.md`), sorted ADRs-then-decisions by number.
/// Missing directories degrade to an empty spine (a fresh project), never an error.
pub fn locked_design_spine(root: &Path) -> Vec<DesignRecord> {
    let mut out = Vec::new();
    collect_records(root, "docs/adr", DesignRefKind::Adr, &mut out);
    collect_records(root, "docs/decisions", DesignRefKind::Decision, &mut out);
    out.sort_by_key(|r| (r.kind, r.num));
    out
}

fn collect_records(root: &Path, dir: &str, kind: DesignRefKind, out: &mut Vec<DesignRecord>) {
    let Ok(entries) = fs::read_dir(root.join(dir)) else {
        return;
    };
    for entry in entries.filter_map(Result::ok) {
        let name = entry.file_name().to_string_lossy().to_string();
        let Some(stem) = name.strip_suffix(".md") else {
            continue;
        };
        let Some(num) = record_number(stem, kind) else {
            continue; // README.md and other non-record files
        };
        let path = format!("{dir}/{name}");
        let title = fs::read_to_string(entry.path())
            .ok()
            .and_then(|c| {
                c.lines()
                    .find(|l| l.trim_start().starts_with('#'))
                    .map(|l| l.trim_start_matches('#').trim().to_string())
            })
            .unwrap_or_else(|| stem.to_string());
        out.push(DesignRecord {
            kind,
            num,
            id: ref_id(kind, num),
            title,
            path,
        });
    }
}

/// Parse a record number from a filename stem: `0003-settings-injector…` (ADR) or
/// `DECISION-002-fidelity…` (decision). `None` for non-record files.
fn record_number(stem: &str, kind: DesignRefKind) -> Option<u32> {
    let digits = match kind {
        DesignRefKind::Adr => stem.split('-').next()?,
        DesignRefKind::Decision => stem
            .strip_prefix("DECISION-")
            .or_else(|| stem.strip_prefix("decision-"))?
            .split('-')
            .next()?,
    };
    (!digits.is_empty() && digits.chars().all(|c| c.is_ascii_digit()))
        .then(|| digits.parse().ok())
        .flatten()
}

/// The Architect's decision for advancing INTO / checking `session`. Mirrors the Planner's
/// `PlanVerdict`.
#[derive(Debug, Clone)]
pub struct DesignVerdict {
    pub session: u32,
    /// The prompt found for `session` (repo-relative), if any.
    pub prompt_path: Option<String>,
    /// The locked design spine surfaced from `docs/adr/` + `docs/decisions/` (for `--design`).
    pub spine: Vec<DesignRecord>,
    /// The parsed design facts, when a prompt was read.
    pub report: Option<DesignReport>,
    /// Blocking reasons — non-empty means L2/L3 must refuse the advance.
    pub reasons: Vec<String>,
    /// Non-blocking nudges (unrecorded marker, missing prompt).
    pub warnings: Vec<String>,
}

impl DesignVerdict {
    pub fn blocked(&self) -> bool {
        !self.reasons.is_empty()
    }
}

/// The Architect gate (S67): advancing INTO `session` requires a design-significant prompt to
/// carry a substantive, spine-citing `## Design` rationale. `Missing`/`Placeholder` BLOCK (L2/L3);
/// a non-significant prompt, an unrecorded marker, or a missing prompt only WARN (legacy compat /
/// the Analyst gate owns the missing-prompt block).
pub fn design_gate(root: &Path, session: u32) -> DesignVerdict {
    let mut reasons = Vec::new();
    let mut warnings = Vec::new();
    let mut report = None;

    let spine = locked_design_spine(root);
    let prompt_path = find_prompt_for(root, session);
    match &prompt_path {
        None => warnings.push(format!(
            "no prompt for session {session:02} — the Analyst gate owns that block; nothing to design yet"
        )),
        Some(rel) => match fs::read_to_string(root.join(rel)) {
            Err(e) => reasons.push(format!("cannot read {rel}: {e}")),
            Ok(content) => {
                let r = parse_design(&content, !spine.is_empty());
                match &r.state {
                    DesignState::Substantive => {}
                    DesignState::NotSignificant => {
                        if r.significance == Significance::Unrecorded {
                            warnings.push(format!(
                                "{rel} does not record design significance — add \
                                 `design-significant: yes` (new/changed interface, new module, ADR \
                                 deviation) or `design-significant: no` (pure fix) to its `## Design`"
                            ));
                        }
                    }
                    DesignState::Missing => reasons.push(format!(
                        "{rel} records `design-significant: yes` but has NO `## Design` section — \
                         record the design rationale (and the ADR/DECISION it rests on) before advancing"
                    )),
                    DesignState::Placeholder => reasons.push(if spine.is_empty() {
                        format!(
                            "{rel} is design-significant but its `## Design` is still the template \
                             placeholder — record a real rationale before advancing"
                        )
                    } else {
                        format!(
                            "{rel} is design-significant but its `## Design` has no substantive, \
                             spine-citing rationale — record why this shape, citing the \
                             `ADR-000N`/`DECISION-00N` it rests on, before advancing"
                        )
                    }),
                }
                report = Some(r);
            }
        },
    }

    DesignVerdict {
        session,
        prompt_path,
        spine,
        report,
        reasons,
        warnings,
    }
}

/// Render the `--design N` surface: the locked design spine as the checklist the rationale must
/// cite from, with the prompt's current citations marked. The design derives from the recorded
/// spine, not thin air — the binary surfaces it, the author decides.
pub fn format_design_checklist(verdict: &DesignVerdict) -> String {
    let mut s = format!(
        "=== architect: design checklist for session {:02} ===\n",
        verdict.session
    );
    s.push_str(&format!(
        "prompt: {}\n",
        verdict.prompt_path.as_deref().unwrap_or("(none)")
    ));

    let cited = verdict
        .report
        .as_ref()
        .map(|r| r.cited.as_slice())
        .unwrap_or(&[]);

    match verdict.report.as_ref().map(|r| &r.significance) {
        Some(Significance::Yes(v)) => s.push_str(&format!("design-significant: yes — {v}\n")),
        Some(Significance::No(v)) => s.push_str(&format!("design-significant: no — {v}\n")),
        Some(Significance::Unrecorded) => s.push_str(
            "design-significant: (unrecorded — record `yes` for a new/changed interface, new \
             module, or ADR deviation; `no` for a pure fix)\n",
        ),
        None => {}
    }

    if verdict.spine.is_empty() {
        s.push_str(
            "locked design spine: (none found under docs/adr/ + docs/decisions/ — citation \
             requirement waived; record the rationale itself)\n",
        );
    } else {
        s.push_str("locked design spine (cite what the design rests on):\n");
        for rec in &verdict.spine {
            let mark = if cited.contains(&(rec.kind, rec.num)) {
                "✓"
            } else {
                " "
            };
            let clipped: String = rec.title.chars().take(80).collect();
            let ell = if rec.title.chars().count() > 80 {
                "…"
            } else {
                ""
            };
            s.push_str(&format!("  [{mark}] {} — {clipped}{ell}\n", rec.id));
        }
    }

    match verdict.report.as_ref().map(|r| &r.state) {
        Some(DesignState::Substantive) => {
            let ids: Vec<String> = cited.iter().map(|&(k, n)| ref_id(k, n)).collect();
            s.push_str(&format!(
                "current `## Design`: SUBSTANTIVE (cites {}) ✓\n",
                ids.join(", ")
            ));
        }
        Some(DesignState::Placeholder) => s.push_str(
            "current `## Design`: placeholder — record a real rationale citing the spine\n",
        ),
        Some(DesignState::Missing) => s.push_str(
            "current `## Design`: MISSING — design-significant, add the section + rationale\n",
        ),
        Some(DesignState::NotSignificant) => {
            s.push_str("current `## Design`: not design-significant — the gate does not block\n")
        }
        None => s.push_str("current `## Design`: (no prompt to read)\n"),
    }
    s
}

#[cfg(test)]
mod tests {
    use super::*;

    const PROMPT: &str = r#"# Session 67 — the ARCHITECT stage: design gate
> **Status:** APPROVED
## Goal
Do one thing.
## Acceptance (testable, EARS-style)
1. WHEN --design runs THEN it surfaces the spine.
2. WHEN significant + placeholder THEN --check-design blocks.
## Guardrails
- one story
## Delta (vs ROADMAP)
- `+` the architect
"#;

    fn with_design(design: &str) -> String {
        format!("{PROMPT}## Design\n{design}\n")
    }

    #[test]
    fn significance_marker_is_recorded_never_guessed() {
        assert_eq!(design_significance(PROMPT), Significance::Unrecorded);
        // Placeholder value → still unrecorded.
        assert_eq!(
            design_significance("- design-significant: <yes | no>\n"),
            Significance::Unrecorded
        );
        assert_eq!(
            design_significance("- **design-significant:** yes — new module\n"),
            Significance::Yes("yes — new module".into())
        );
        assert_eq!(
            design_significance("design-significant: no — pure fix\n"),
            Significance::No("no — pure fix".into())
        );
        assert_eq!(
            design_significance("design-significant: none\n"),
            Significance::No("none".into())
        );
        // Prose mentioning the marker mid-line is not a marker.
        assert_eq!(
            design_significance("the gate reads design-significant: markers\n"),
            Significance::Unrecorded
        );
    }

    #[test]
    fn design_heading_matched_first_token_not_prose_or_constraints() {
        assert!(is_design_heading("## Design"));
        assert!(is_design_heading("## Design (the Architect gate)"));
        assert!(!is_design_heading(
            "# Session 67 — the ARCHITECT stage: design gate"
        ));
        // The legacy guardrails synonym is NOT the rationale section.
        assert!(!is_design_heading("## Design constraints"));
        assert!(!is_design_heading("## Designing notes"));
    }

    #[test]
    fn cited_refs_normalize_widths() {
        let mut out = Vec::new();
        cited_refs_on("rests on ADR-0002 and adr-3, per DECISION-002.", &mut out);
        assert_eq!(
            out,
            vec![
                (DesignRefKind::Adr, 2),
                (DesignRefKind::Adr, 3),
                (DesignRefKind::Decision, 2)
            ]
        );
        assert_eq!(ref_id(DesignRefKind::Adr, 2), "ADR-0002");
        assert_eq!(ref_id(DesignRefKind::Decision, 2), "DECISION-002");
    }

    #[test]
    fn not_significant_never_blocks() {
        // No marker at all (legacy prompt).
        let r = parse_design(PROMPT, true);
        assert_eq!(r.state, DesignState::NotSignificant);
        assert!(!r.state.blocks());
        // Explicit `no`.
        let p = with_design("- design-significant: no — pure fix");
        assert_eq!(parse_design(&p, true).state, DesignState::NotSignificant);
    }

    #[test]
    fn significant_without_section_is_missing_and_blocks() {
        let p = format!("{PROMPT}\ndesign-significant: yes — new module\n");
        let r = parse_design(&p, true);
        assert_eq!(r.state, DesignState::Missing);
        assert!(r.state.blocks());
    }

    #[test]
    fn significant_placeholder_or_uncited_blocks() {
        // Template placeholder rationale.
        let p =
            with_design("- design-significant: yes — new interface\n- <rationale — replace me>");
        assert_eq!(parse_design(&p, true).state, DesignState::Placeholder);
        // Real text but citing no ADR/DECISION (spine exists) → still placeholder.
        let p = with_design("- design-significant: yes — new interface\n- because it felt right");
        assert_eq!(parse_design(&p, true).state, DesignState::Placeholder);
        // …but with NO spine in the repo, the citation requirement is waived.
        assert_eq!(parse_design(&p, false).state, DesignState::Substantive);
    }

    #[test]
    fn significant_substantive_cited_passes() {
        let p = with_design(
            "- design-significant: yes — new `--design` surface\n\
             - Mirrors the Planner's recorded-marker shape per DECISION-001; rides `vajra next` \
             per ADR-0002's thin-CLI layout.",
        );
        let r = parse_design(&p, true);
        assert_eq!(r.state, DesignState::Substantive);
        assert!(!r.state.blocks());
        assert_eq!(
            r.cited,
            vec![(DesignRefKind::Adr, 2), (DesignRefKind::Decision, 1)]
        );
    }

    #[test]
    fn fresh_scaffold_design_is_unrecorded_not_blocking() {
        // The scaffold ships a placeholder marker: the Architect alone must not block a fresh
        // prompt (the Analyst's DRAFT/Delta gates already do); it nudges via the gate's warning.
        let scaffold = crate::analyst::render_scaffold(67, "architect-stage");
        let r = parse_design(&scaffold, true);
        assert_eq!(r.significance, Significance::Unrecorded);
        assert_eq!(r.state, DesignState::NotSignificant);
        // But the moment the author records `yes`, the placeholder rationale BLOCKS until filled.
        let marked = scaffold.replace(
            "- design-significant: <yes — new/changed interface, new module, or an ADR deviation | no — pure fix>",
            "- design-significant: yes — new module",
        );
        assert_eq!(parse_design(&marked, true).state, DesignState::Placeholder);
    }

    fn spine_fixture(root: &Path) {
        fs::create_dir_all(root.join("docs/adr")).unwrap();
        fs::create_dir_all(root.join("docs/decisions")).unwrap();
        fs::write(
            root.join("docs/adr/0002-engine-trait.md"),
            "# ADR-0002: Engine trait and module layout\n",
        )
        .unwrap();
        fs::write(
            root.join("docs/adr/0001-compression.md"),
            "# ADR-0001: Compression delivery\n",
        )
        .unwrap();
        fs::write(root.join("docs/adr/README.md"), "# index\n").unwrap();
        fs::write(
            root.join("docs/decisions/DECISION-001-governance.md"),
            "# DECISION-001: Governance as product\n",
        )
        .unwrap();
    }

    #[test]
    fn spine_reads_adrs_and_decisions_sorted_skipping_readme() {
        let tmp = tempfile::tempdir().unwrap();
        spine_fixture(tmp.path());
        let spine = locked_design_spine(tmp.path());
        let ids: Vec<&str> = spine.iter().map(|r| r.id.as_str()).collect();
        assert_eq!(ids, vec!["ADR-0001", "ADR-0002", "DECISION-001"]);
        assert!(spine[1].title.contains("Engine trait"));
        assert_eq!(spine[2].path, "docs/decisions/DECISION-001-governance.md");
        // A repo with no spine degrades to empty, not an error.
        let bare = tempfile::tempdir().unwrap();
        assert!(locked_design_spine(bare.path()).is_empty());
    }

    #[test]
    fn gate_blocks_missing_and_placeholder_passes_substantive() {
        let tmp = tempfile::tempdir().unwrap();
        spine_fixture(tmp.path());
        fs::create_dir_all(tmp.path().join("prompts")).unwrap();
        let rel = tmp.path().join("prompts/67-task-x.md");

        // Significant, no ## Design → BLOCK (missing).
        fs::write(&rel, format!("{PROMPT}\ndesign-significant: yes\n")).unwrap();
        let v = design_gate(tmp.path(), 67);
        assert!(v.blocked(), "missing must block");
        assert!(v.reasons.iter().any(|r| r.contains("NO `## Design`")));

        // Significant, placeholder rationale → BLOCK.
        fs::write(
            &rel,
            with_design("- design-significant: yes\n- <rationale — replace me>"),
        )
        .unwrap();
        let v = design_gate(tmp.path(), 67);
        assert!(v.blocked(), "placeholder must block");
        assert!(v.reasons.iter().any(|r| r.contains("spine-citing")));

        // Substantive, cites the spine → PASS.
        fs::write(
            &rel,
            with_design("- design-significant: yes\n- rides ADR-0002's module layout."),
        )
        .unwrap();
        let v = design_gate(tmp.path(), 67);
        assert!(!v.blocked(), "reasons: {:?}", v.reasons);
        assert_eq!(v.report.as_ref().unwrap().state, DesignState::Substantive);
    }

    #[test]
    fn gate_warns_on_unrecorded_marker_and_missing_prompt() {
        let tmp = tempfile::tempdir().unwrap();
        fs::create_dir_all(tmp.path().join("prompts")).unwrap();
        // Legacy prompt, no marker → WARN (nudge to record), never block.
        fs::write(tmp.path().join("prompts/50-task-x.md"), PROMPT).unwrap();
        let v = design_gate(tmp.path(), 50);
        assert!(!v.blocked());
        assert!(v
            .warnings
            .iter()
            .any(|w| w.contains("does not record design significance")));
        // No prompt at all → WARN (the Analyst gate owns that block).
        let v = design_gate(tmp.path(), 99);
        assert!(!v.blocked());
        assert!(v.warnings.iter().any(|w| w.contains("no prompt")));
        // An explicit `no` passes silently — a pure fix needs no nudge.
        fs::write(
            tmp.path().join("prompts/51-task-y.md"),
            with_design("- design-significant: no — pure fix"),
        )
        .unwrap();
        let v = design_gate(tmp.path(), 51);
        assert!(!v.blocked());
        assert!(v.warnings.is_empty(), "warnings: {:?}", v.warnings);
    }

    #[test]
    fn checklist_surfaces_spine_and_marks_citations() {
        let tmp = tempfile::tempdir().unwrap();
        spine_fixture(tmp.path());
        fs::create_dir_all(tmp.path().join("prompts")).unwrap();
        fs::write(
            tmp.path().join("prompts/67-task-x.md"),
            with_design("- design-significant: yes\n- rests on ADR-0002."),
        )
        .unwrap();
        let out = format_design_checklist(&design_gate(tmp.path(), 67));
        assert!(out.contains("[✓] ADR-0002"), "got:\n{out}");
        assert!(out.contains("[ ] ADR-0001"));
        assert!(out.contains("[ ] DECISION-001"));
        assert!(out.contains("SUBSTANTIVE (cites ADR-0002)"));
        assert!(out.contains("design-significant: yes"));
    }
}
