//! The Coder — the pipeline's CODE/execution gate (S68), the LAST governed station.
//!
//! Vajra is a GOVERNED multi-agent SDLC pipeline (DECISION-001, S53). The Analyst (S54+S61+S62)
//! governs the **WHAT**; the Architect (S67) the **DESIGN**; the Planner (S64) the **HOW-plan**.
//! The Coder governs the **DID**: the execution trace from the covered plan to the commits that
//! landed it. Today a session can close with a green plan and commits that did something else
//! entirely — fidelity review catches the *delivery*, but nothing traces plan steps → commits.
//!
//! The trace is NOT a new artifact. Like the Analyst refusing a `spec.md` and the Planner a
//! `plan.md`, the Coder refuses an `execution.md`: the record lives in an `## Execution` section
//! INSIDE the session's own prompt (`step N — done: <sha>`), and git IS the evidence (memory
//! `feedback-map-concepts-to-vajra`, `feedback-distill-no-drift`). No second store, no 8th
//! command (rides `vajra next`).
//!
//! The binary **surfaces + enforces, never authors** (the S54 anti-trap): a Rust binary cannot
//! code, and cannot judge that a commit *semantically* executes a step. The honest contract —
//! the fourth application of the "enforce a RECORDED thing" move (Delta S61, `covers:` S64,
//! `design-significant:` S67), with the S67 existence lesson baked in:
//!
//! 1. Execution is a **recorded marker**, never guessed: the author writes
//!    `step N — done: <sha>` in `## Execution` as each plan step lands.
//! 2. A recorded sha only counts when it **EXISTS** in the repo (`git cat-file -e`) — a made-up
//!    sha is classified unrecorded, the git-verifiable mirror of the spine-existence check.
//! 3. Unlike the other stages, the gate binds on the session being **CLOSED** (like the S62
//!    Options gate) — execution happens during the session being closed, not the one ahead.
//! 4. The gate enforces the *form + existence* of the trace, not the semantics — an author can
//!    `done:` any real sha. That honesty is stated, not hidden.

use std::fs;
use std::path::Path;
use std::process::Command;

use crate::analyst::find_prompt_for;

/// A plan step's recorded execution state, read — never guessed — from `## Execution`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ExecRecord {
    /// No `done:` record names this step.
    Unrecorded,
    /// `done: <sha>` recorded, but the sha does not resolve to a commit in the repo — a made-up
    /// sha is classified unrecorded (the S67 existence lesson). Carries the recorded token.
    Fake(String),
    /// `done: <sha>` recorded and the commit EXISTS. Carries the recorded sha.
    Done(String),
}

/// One numbered plan step surfaced as the execution checklist, with its recorded state.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ExecStep {
    pub number: u32,
    /// The step's first-line text (for the `--exec` checklist).
    pub text: String,
    pub record: ExecRecord,
}

/// Execution-trace state of a prompt's `## Plan` vs its `## Execution` records (S68). Mirrors the
/// Planner's `PlanState`: absent sections are legacy-compatible (WARN); only a real plan whose
/// `## Execution` exists but leaves steps unrecorded/fake BLOCKS.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ExecState {
    /// No numbered `## Plan` steps to trace (no heading, or placeholder-only). Never blocks —
    /// the Planner gate owns plan coverage; there is nothing to trace here.
    NoPlan,
    /// Real plan steps but NO `## Execution` section at all (legacy prompts pre-S68). WARN —
    /// mirrors `PlanState::Absent` / the Architect's legacy stance.
    NoExecution,
    /// `## Execution` exists but these plan-step numbers have no `done: <sha>` naming a commit
    /// that EXISTS (unrecorded, or a fake sha). BLOCKS closing. Carries the numbers (sorted).
    Unrecorded(Vec<u32>),
    /// Every numbered plan step records a `done: <sha>` that exists. Passes.
    Recorded,
}

impl ExecState {
    /// A blocking state refuses the close at L2/L3. Only a real plan with a present-but-
    /// incomplete `## Execution` trace blocks.
    pub fn blocks(&self) -> bool {
        matches!(self, ExecState::Unrecorded(_))
    }
}

/// The parsed execution facts of one prompt: the checklist (numbered plan steps + each one's
/// recorded state) and the classified overall state.
#[derive(Debug, Clone)]
pub struct ExecReport {
    pub steps: Vec<ExecStep>,
    pub state: ExecState,
}

/// A heading opens the `## Plan` block — first token exactly `plan` (the Planner's matcher), so a
/// title mentioning "plan" in prose never counts.
fn is_plan_heading(line: &str) -> bool {
    line.trim_start_matches('#')
        .trim()
        .to_ascii_lowercase()
        .split_whitespace()
        .next()
        == Some("plan")
}

/// A heading opens the `## Execution` block — first token exactly `execution`.
fn is_execution_heading(line: &str) -> bool {
    line.trim_start_matches('#')
        .trim()
        .to_ascii_lowercase()
        .split_whitespace()
        .next()
        == Some("execution")
}

/// If `line` is a top-level ordered-list item (`N. text`), return `(N, text)`.
fn numbered_item(line: &str) -> Option<(u32, String)> {
    let (num, rest) = line.split_once('.')?;
    let number: u32 = num.trim().parse().ok()?;
    let rest = rest.trim();
    (!rest.is_empty()).then(|| (number, rest.to_string()))
}

/// The numbered, non-placeholder steps of the `## Plan` section — the trace's subjects. Only
/// ordered `N.` steps are traceable (a `done:` record maps to a step by its ordinal); placeholder
/// (`<...>`) steps are not real steps.
pub fn plan_steps(content: &str) -> Vec<(u32, String)> {
    let mut in_plan = false;
    let mut out = Vec::new();
    for line in content.lines() {
        let t = line.trim();
        if t.starts_with('#') {
            in_plan = is_plan_heading(t);
            continue;
        }
        if in_plan {
            if let Some((n, text)) = numbered_item(t) {
                if !text.starts_with('<') {
                    out.push((n, text));
                }
            }
        }
    }
    out
}

/// Parse one `## Execution` record line: `step N — done: <sha>` (case-insensitive; may be a
/// bullet and carry markdown emphasis, mirroring the other recorded-marker parsers). The sha is
/// the leading hex run after `done:` — refs like `HEAD` are not shas and record nothing; a
/// template `<...>` placeholder records nothing. `None` for a non-record line.
fn execution_record(line: &str) -> Option<(u32, String)> {
    let cleaned = line.replace(['*', '`'], "");
    let t = cleaned
        .trim()
        .strip_prefix('-')
        .unwrap_or(cleaned.trim())
        .trim_start();
    let lower = t.to_ascii_lowercase();

    let rest = lower.strip_prefix("step")?;
    let digits: String = rest
        .trim_start()
        .chars()
        .take_while(char::is_ascii_digit)
        .collect();
    let number: u32 = digits.parse().ok()?;

    let after = &lower[lower.find("done:")? + "done:".len()..];
    let after = after.trim_start();
    if after.starts_with('<') {
        return None; // still the template placeholder — nothing recorded
    }
    let sha: String = after.chars().take_while(char::is_ascii_hexdigit).collect();
    (!sha.is_empty()).then_some((number, sha))
}

/// The recorded `step N — done: <sha>` pairs of the `## Execution` section. `None` when the
/// section is absent (a legacy prompt); `Some` (possibly empty) when the heading exists. When a
/// step is recorded more than once, the LAST record wins (authors append as work lands).
pub fn execution_records(content: &str) -> Option<Vec<(u32, String)>> {
    let mut in_exec = false;
    let mut saw_heading = false;
    let mut out: Vec<(u32, String)> = Vec::new();
    for line in content.lines() {
        let t = line.trim();
        if t.starts_with('#') {
            in_exec = is_execution_heading(t);
            if in_exec {
                saw_heading = true;
            }
            continue;
        }
        if in_exec {
            if let Some((n, sha)) = execution_record(t) {
                out.retain(|(existing, _)| *existing != n);
                out.push((n, sha));
            }
        }
    }
    saw_heading.then_some(out)
}

/// Classify a prompt's execution trace (S68). `commit_exists` answers "does this sha resolve to
/// a commit in the repo?" — injected so the classification is testable without a repo.
///
/// - no numbered plan steps                       → `NoPlan`      (WARN — nothing to trace)
/// - steps but no `## Execution` section          → `NoExecution` (WARN — legacy compat)
/// - section present, any step unrecorded/fake    → `Unrecorded`  (BLOCK closing)
/// - every step `done:` a commit that exists      → `Recorded`    (PASS)
pub fn exec_report(content: &str, commit_exists: impl Fn(&str) -> bool) -> ExecReport {
    let steps = plan_steps(content);
    if steps.is_empty() {
        return ExecReport {
            steps: Vec::new(),
            state: ExecState::NoPlan,
        };
    }
    let Some(records) = execution_records(content) else {
        let steps = steps
            .into_iter()
            .map(|(number, text)| ExecStep {
                number,
                text,
                record: ExecRecord::Unrecorded,
            })
            .collect();
        return ExecReport {
            steps,
            state: ExecState::NoExecution,
        };
    };

    let steps: Vec<ExecStep> = steps
        .into_iter()
        .map(|(number, text)| {
            let record = match records.iter().find(|(n, _)| *n == number) {
                None => ExecRecord::Unrecorded,
                Some((_, sha)) if commit_exists(sha) => ExecRecord::Done(sha.clone()),
                Some((_, sha)) => ExecRecord::Fake(sha.clone()),
            };
            ExecStep {
                number,
                text,
                record,
            }
        })
        .collect();

    let mut missing: Vec<u32> = steps
        .iter()
        .filter(|s| !matches!(s.record, ExecRecord::Done(_)))
        .map(|s| s.number)
        .collect();
    missing.sort_unstable();
    missing.dedup();
    let state = if missing.is_empty() {
        ExecState::Recorded
    } else {
        ExecState::Unrecorded(missing)
    };
    ExecReport { steps, state }
}

/// Does `sha` resolve to a commit in the repo at `root`? (`git cat-file -e <sha>^{commit}` —
/// the S67 existence lesson, git-shaped: a recorded claim must name a thing that exists.)
pub fn commit_exists(root: &Path, sha: &str) -> bool {
    Command::new("git")
        .args(["cat-file", "-e", &format!("{sha}^{{commit}}")])
        .current_dir(root)
        .output()
        .map(|o| o.status.success())
        .unwrap_or(false)
}

/// The Coder's decision for CLOSING `session`. Mirrors the Architect's `DesignVerdict`.
#[derive(Debug, Clone)]
pub struct ExecVerdict {
    pub session: u32,
    /// The prompt found for `session` (repo-relative), if any.
    pub prompt_path: Option<String>,
    /// The parsed execution facts, when a prompt was read.
    pub report: Option<ExecReport>,
    /// Blocking reasons — non-empty means L2/L3 must refuse the close.
    pub reasons: Vec<String>,
    /// Non-blocking nudges (legacy prompt, nothing to trace, missing prompt).
    pub warnings: Vec<String>,
}

impl ExecVerdict {
    pub fn blocked(&self) -> bool {
        !self.reasons.is_empty()
    }
}

/// The Coder gate (S68): CLOSING `session` requires each numbered plan step to record a
/// `done: <sha>` naming a commit that EXISTS. An incomplete/fake trace BLOCKS (L2/L3); a legacy
/// prompt (no `## Execution`), a plan-less prompt, or a missing prompt only WARN.
pub fn exec_gate(root: &Path, session: u32) -> ExecVerdict {
    let mut reasons = Vec::new();
    let mut warnings = Vec::new();
    let mut report = None;

    let prompt_path = find_prompt_for(root, session);
    match &prompt_path {
        None => warnings.push(format!(
            "no prompt for session {session:02} — nothing to trace (legacy session)"
        )),
        Some(rel) => match fs::read_to_string(root.join(rel)) {
            Err(e) => reasons.push(format!("cannot read {rel}: {e}")),
            Ok(content) => {
                let r = exec_report(&content, |sha| commit_exists(root, sha));
                match &r.state {
                    ExecState::Recorded => {}
                    ExecState::NoPlan => warnings.push(format!(
                        "{rel} has no numbered `## Plan` steps — nothing to trace \
                         (the Planner gate owns plan coverage)"
                    )),
                    ExecState::NoExecution => warnings.push(format!(
                        "{rel} has no `## Execution` section — record `step N — done: <sha>` \
                         per plan step as work lands (legacy prompts pass)"
                    )),
                    ExecState::Unrecorded(missing) => reasons.push(format!(
                        "{rel} `## Execution` records no existing commit for plan step(s) {} — \
                         record `step N — done: <sha>` where the sha EXISTS in the repo \
                         (`git cat-file -e`) before closing",
                        join_nums(missing)
                    )),
                }
                report = Some(r);
            }
        },
    }

    ExecVerdict {
        session,
        prompt_path,
        report,
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

/// Render the `--exec N` surface: the covered plan as the execution checklist, each step's
/// recorded state marked. The trace derives from the recorded contract (the plan + `## Execution`
/// records), not thin air — the binary surfaces it; the author records; git is the evidence.
pub fn format_exec_checklist(verdict: &ExecVerdict) -> String {
    let mut s = format!(
        "=== coder: execution checklist for session {:02} ===\n",
        verdict.session
    );
    s.push_str(&format!(
        "prompt: {}\n",
        verdict.prompt_path.as_deref().unwrap_or("(none)")
    ));

    let Some(report) = &verdict.report else {
        s.push_str("execution trace: (no prompt to read)\n");
        return s;
    };
    if report.steps.is_empty() {
        s.push_str("no numbered `## Plan` steps found — nothing to trace yet.\n");
        return s;
    }

    s.push_str(
        "plan steps → recorded commits (record `step N — done: <sha>` in `## Execution`):\n",
    );
    for step in &report.steps {
        let clipped: String = step.text.chars().take(80).collect();
        let ell = if step.text.chars().count() > 80 {
            "…"
        } else {
            ""
        };
        let (mark, state) = match &step.record {
            ExecRecord::Done(sha) => ("✓", format!("done: {sha}")),
            ExecRecord::Fake(sha) => (
                "✗",
                format!("done: {sha} (NOT a commit in this repo — classified unrecorded)"),
            ),
            ExecRecord::Unrecorded => (" ", "unrecorded".to_string()),
        };
        s.push_str(&format!(
            "  [{mark}] step {} — {state} — {clipped}{ell}\n",
            step.number
        ));
    }

    match &report.state {
        ExecState::Recorded => s.push_str(
            "current `## Execution`: RECORDED — every step names a commit that exists ✓\n",
        ),
        ExecState::Unrecorded(m) => s.push_str(&format!(
            "current `## Execution`: unrecorded → step(s) {}\n",
            join_nums(m)
        )),
        ExecState::NoExecution => s.push_str(
            "current `## Execution`: none — add the section and record `step N — done: <sha>` \
             as work lands (legacy prompts only WARN)\n",
        ),
        ExecState::NoPlan => {}
    }
    s
}

#[cfg(test)]
mod tests {
    use super::*;

    const PROMPT: &str = r#"# Session 68 — the CODER stage: execution trace
> **Status:** APPROVED
## Goal
Do one thing.
## Acceptance (testable, EARS-style)
1. WHEN --exec runs THEN it surfaces the plan checklist.
2. WHEN a sha is fake THEN it is classified unrecorded.
## Plan
1. build the parser — covers: 1
2. wire the gate — covers: 2
## Guardrails
- one story
## Delta (vs ROADMAP)
- `+` the coder
"#;

    fn with_execution(records: &str) -> String {
        format!("{PROMPT}## Execution\n{records}\n")
    }

    /// A fake repo where exactly `abc1234` and `feedbee` are commits.
    fn fake_exists(sha: &str) -> bool {
        sha == "abc1234" || sha == "feedbee"
    }

    #[test]
    fn plan_steps_numbered_scoped_skipping_placeholders() {
        let steps = plan_steps(PROMPT);
        assert_eq!(steps.len(), 2);
        assert_eq!(steps[0].0, 1);
        assert!(steps[0].1.contains("parser"));
        // Placeholder steps are not real steps; acceptance numbering is not the plan.
        let ph = "# S\n## Plan\n1. <replace me>\n2. real step\n";
        assert_eq!(plan_steps(ph), vec![(2, "real step".to_string())]);
        // A "plan" in the title is not the section (the Planner's matcher).
        assert!(!is_plan_heading("# Session 68 — plan the coder"));
        assert!(is_plan_heading("## Plan (ordered steps)"));
    }

    #[test]
    fn execution_record_parses_step_done_sha() {
        assert_eq!(
            execution_record("step 1 — done: abc1234"),
            Some((1, "abc1234".to_string()))
        );
        // Bullet + markdown emphasis + case, trailing punctuation after the hex run.
        assert_eq!(
            execution_record("- **Step 2** — Done: FEEDBEE."),
            Some((2, "feedbee".to_string()))
        );
        // Template placeholder records nothing.
        assert_eq!(
            execution_record("- step 1 — done: <sha — replace me>"),
            None
        );
        // A ref is not a sha — existence gating is against recorded hex, not resolvable names.
        assert_eq!(execution_record("step 1 — done: HEAD"), None);
        // Prose without the step prefix, or without done:, records nothing.
        assert_eq!(execution_record("the work is done: abc1234"), None);
        assert_eq!(execution_record("step 3 landed in abc1234"), None);
    }

    #[test]
    fn execution_records_absent_vs_present_last_wins() {
        assert_eq!(execution_records(PROMPT), None); // no section at all — legacy
        let p = with_execution("- step 1 — done: abc1234\n- step 1 — done: feedbee");
        assert_eq!(
            execution_records(&p),
            Some(vec![(1, "feedbee".to_string())]) // authors append; the LAST record wins
        );
        // A heading with no real records yet is Some(empty) — the section exists.
        let p = with_execution("- step 1 — done: <sha — replace me>");
        assert_eq!(execution_records(&p), Some(vec![]));
    }

    #[test]
    fn no_plan_and_no_execution_never_block() {
        // No numbered plan steps → NoPlan.
        let r = exec_report("# S\n## Goal\ng\n", fake_exists);
        assert_eq!(r.state, ExecState::NoPlan);
        assert!(!r.state.blocks());
        // Real plan, no ## Execution section (legacy prompt) → NoExecution.
        let r = exec_report(PROMPT, fake_exists);
        assert_eq!(r.state, ExecState::NoExecution);
        assert!(!r.state.blocks());
        assert_eq!(r.steps.len(), 2);
        assert!(r.steps.iter().all(|s| s.record == ExecRecord::Unrecorded));
    }

    #[test]
    fn unrecorded_step_blocks() {
        let p = with_execution("- step 1 — done: abc1234");
        let r = exec_report(&p, fake_exists);
        assert_eq!(r.state, ExecState::Unrecorded(vec![2]));
        assert!(r.state.blocks());
    }

    #[test]
    fn fake_sha_is_classified_unrecorded() {
        // The S67 existence lesson, git-shaped: a made-up sha must NOT count as executed.
        let p = with_execution("- step 1 — done: abc1234\n- step 2 — done: deadbeef");
        let r = exec_report(&p, fake_exists);
        assert_eq!(r.state, ExecState::Unrecorded(vec![2]));
        assert_eq!(r.steps[1].record, ExecRecord::Fake("deadbeef".to_string()));
        assert!(r.state.blocks());
    }

    #[test]
    fn fully_recorded_passes() {
        let p = with_execution("- step 1 — done: abc1234\n- step 2 — done: feedbee");
        let r = exec_report(&p, fake_exists);
        assert_eq!(r.state, ExecState::Recorded);
        assert!(!r.state.blocks());
        assert_eq!(r.steps[0].record, ExecRecord::Done("abc1234".to_string()));
    }

    #[test]
    fn fresh_scaffold_is_no_plan_not_blocking() {
        // A fresh scaffold's plan is still the placeholder — the Coder alone must not block it
        // (the Planner's placeholder gate already does); there is nothing to trace yet.
        let scaffold = crate::analyst::render_scaffold(68, "coder-handoff");
        let r = exec_report(&scaffold, |_| false);
        assert_eq!(r.state, ExecState::NoPlan);
        // But the moment a real covered plan exists and the ## Execution placeholder is unfilled,
        // the unrecorded steps BLOCK the close.
        let filled = scaffold.replace(
            "1. <first ordered step — replace me; annotate which acceptance criteria it satisfies>",
            "1. a real step — covers: 1, 2, 3",
        );
        let r = exec_report(&filled, |_| false);
        assert_eq!(r.state, ExecState::Unrecorded(vec![1]));
    }

    fn git_repo_with_commit(root: &Path) -> String {
        let run = |args: &[&str]| {
            let out = Command::new("git")
                .args(args)
                .current_dir(root)
                .output()
                .unwrap();
            assert!(out.status.success(), "git {args:?}: {out:?}");
            String::from_utf8(out.stdout).unwrap()
        };
        run(&["init", "-q"]);
        run(&["config", "user.email", "t@t"]);
        run(&["config", "user.name", "t"]);
        fs::write(root.join("f"), "x").unwrap();
        run(&["add", "-A"]);
        run(&["commit", "-qm", "init"]);
        run(&["rev-parse", "--short", "HEAD"]).trim().to_string()
    }

    #[test]
    fn commit_exists_gates_against_the_real_repo() {
        let tmp = tempfile::tempdir().unwrap();
        let sha = git_repo_with_commit(tmp.path());
        assert!(commit_exists(tmp.path(), &sha));
        assert!(!commit_exists(tmp.path(), "1234567")); // made-up
        assert!(!commit_exists(tmp.path(), "")); // degenerate
    }

    #[test]
    fn gate_blocks_fake_passes_real_warns_legacy() {
        let tmp = tempfile::tempdir().unwrap();
        let sha = git_repo_with_commit(tmp.path());
        fs::create_dir_all(tmp.path().join("prompts")).unwrap();
        let rel = tmp.path().join("prompts/68-task-x.md");

        // Real sha for step 1, fake for step 2 → BLOCK, names step 2.
        fs::write(
            &rel,
            with_execution(&format!("- step 1 — done: {sha}\n- step 2 — done: 9999999")),
        )
        .unwrap();
        let v = exec_gate(tmp.path(), 68);
        assert!(v.blocked(), "fake sha must block");
        assert!(v.reasons.iter().any(|r| r.contains("step(s) 2")));

        // Every step a real commit → PASS.
        fs::write(
            &rel,
            with_execution(&format!("- step 1 — done: {sha}\n- step 2 — done: {sha}")),
        )
        .unwrap();
        let v = exec_gate(tmp.path(), 68);
        assert!(!v.blocked(), "reasons: {:?}", v.reasons);
        assert_eq!(v.report.as_ref().unwrap().state, ExecState::Recorded);

        // Legacy prompt (no ## Execution) → WARN, never block.
        fs::write(&rel, PROMPT).unwrap();
        let v = exec_gate(tmp.path(), 68);
        assert!(!v.blocked());
        assert!(v.warnings.iter().any(|w| w.contains("no `## Execution`")));

        // No prompt at all → WARN.
        let v = exec_gate(tmp.path(), 99);
        assert!(!v.blocked());
        assert!(v.warnings.iter().any(|w| w.contains("no prompt")));
    }

    #[test]
    fn checklist_surfaces_steps_and_marks_records() {
        let tmp = tempfile::tempdir().unwrap();
        let sha = git_repo_with_commit(tmp.path());
        fs::create_dir_all(tmp.path().join("prompts")).unwrap();
        fs::write(
            tmp.path().join("prompts/68-task-x.md"),
            with_execution(&format!("- step 1 — done: {sha}\n- step 2 — done: 9999999")),
        )
        .unwrap();
        let out = format_exec_checklist(&exec_gate(tmp.path(), 68));
        assert!(
            out.contains(&format!("[✓] step 1 — done: {sha}")),
            "got:\n{out}"
        );
        assert!(out.contains("[✗] step 2 — done: 9999999"));
        assert!(out.contains("classified unrecorded"));
        assert!(out.contains("unrecorded → step(s) 2"));
    }
}
