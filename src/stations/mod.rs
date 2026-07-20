//! S74 — the payload counter: how many of the 8 governed stations a prompt DEMONSTRABLY passed.
//!
//! The meta-gap named at S25, S60, S65, and S70: every gate measures whether the RAILS are
//! followed (branch, files, tests-green, fidelity), but NOTHING measured whether the PIPELINE
//! itself advances — how many governed stations a session actually moved a prompt through. A GT
//! could not answer "is the pipeline progressing?" because no number recorded it. This module
//! records that number, `K of 8`.
//!
//! Two rules keep it honest:
//! 1. **Derived, never asserted (the S64 digit-tag lesson).** Each station's PASS is read from that
//!    station's OWN classifier (`analyst::validate_prompt`, `architect::design_gate`,
//!    `planner::plan_gate`, `coder::exec_gate`, `qa`/`demoer::gather_contract`,
//!    `releaser::derive_ship_state`, the review artifact) — never a hand-typed count. A station's
//!    rule and its counter cannot disagree because the counter has no rule of its own.
//! 2. **Read-only, nothing executes (criterion 1).** The file/git-derived stations reuse their
//!    classifier at its *substantive terminal*. The two LIVE stations (QA, Demo-er) are read
//!    STATICALLY — the recorded contract (`script_exists`, elements-in-file), not the live re-run.
//!    That static read is WEAKER than the close gate's live green and is the **disclosed fakest
//!    green**: a `--stations` QA/Demo PASS attests the evidence is gate-ELIGIBLE, not that a live
//!    re-run is green. The counter never reports PASSED where a classifier statically BLOCKS.

use std::fs;
use std::path::Path;

use crate::analyst::{self, DeltaState};
use crate::architect::{self, DesignState};
use crate::coder::{self, ExecState};
use crate::demoer;
use crate::planner::{self, PlanState};
use crate::qa;
use crate::releaser::{self, BranchShip, MainSync};

/// The eight governed stations (VISION.md + DECISION-001). Fixed — the counter is `K of 8`.
pub const STATION_COUNT: usize = 8;

/// One station's read-only outcome for a session. `Passed` requires the station's classifier at
/// its substantive terminal; everything weaker (absent, placeholder, block, not-applicable) is
/// `Absent` — the count can only be EARNED by evidence a gate would accept, never by a section
/// merely existing (criterion 2).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Outcome {
    Passed,
    Absent,
}

/// One station's line in the report: its name, pipeline lane, outcome, and a short derived note.
#[derive(Debug, Clone)]
pub struct StationStatus {
    pub name: &'static str,
    pub lane: &'static str,
    pub outcome: Outcome,
    /// Short, derived reason (e.g. "substantive `## Delta`", "placeholder", "not design-significant",
    /// "verify script recorded [static — not live-green]") — for the surface, never a store.
    pub note: String,
}

impl StationStatus {
    fn passed(name: &'static str, lane: &'static str, note: impl Into<String>) -> Self {
        StationStatus {
            name,
            lane,
            outcome: Outcome::Passed,
            note: note.into(),
        }
    }
    fn absent(name: &'static str, lane: &'static str, note: impl Into<String>) -> Self {
        StationStatus {
            name,
            lane,
            outcome: Outcome::Absent,
            note: note.into(),
        }
    }
}

/// The per-session station report — the eight statuses plus a derived `K of 8`.
#[derive(Debug, Clone)]
pub struct StationReport {
    pub session: u32,
    pub stations: Vec<StationStatus>,
}

impl StationReport {
    /// How many stations DEMONSTRABLY passed — the payload count.
    pub fn passed(&self) -> usize {
        self.stations
            .iter()
            .filter(|s| s.outcome == Outcome::Passed)
            .count()
    }
}

/// Derive session `session`'s station report — read-only, nothing executes.
pub fn station_report(root: &Path, session: u32) -> StationReport {
    StationReport {
        session,
        stations: vec![
            analyst_status(root, session),
            architect_status(root, session),
            planner_status(root, session),
            coder_status(root, session),
            qa_status(root, session),
            demoer_status(root, session),
            releaser_status(root, session),
            reviewer_status(root, session),
        ],
    }
}

// ---- Per-station derivations (each reuses that station's own classifier) --------------------

/// Analyst (WHAT): the prompt's `## Delta` is substantive (`analyst::validate_prompt`).
fn analyst_status(root: &Path, session: u32) -> StationStatus {
    const N: &str = "Analyst";
    const L: &str = "WHAT";
    match read_prompt(root, session) {
        None => StationStatus::absent(N, L, "no prompt"),
        Some(content) => match analyst::validate_prompt(&content).delta {
            DeltaState::Substantive => StationStatus::passed(N, L, "substantive `## Delta`"),
            DeltaState::Placeholder => StationStatus::absent(N, L, "placeholder `## Delta`"),
            DeltaState::Absent => StationStatus::absent(N, L, "no `## Delta`"),
        },
    }
}

/// Architect (DESIGN): a design-significant prompt carries a substantive, spine-citing `## Design`
/// (`architect::design_gate`). A non-significant prompt is ABSENT (the station was not moved
/// through — a pure fix legitimately maxes below 8/8; the note discloses it).
fn architect_status(root: &Path, session: u32) -> StationStatus {
    const N: &str = "Architect";
    const L: &str = "DESIGN";
    match architect::design_gate(root, session)
        .report
        .map(|r| r.state)
    {
        Some(DesignState::Substantive) => {
            StationStatus::passed(N, L, "substantive, spine-citing `## Design`")
        }
        Some(DesignState::NotSignificant) => StationStatus::absent(N, L, "not design-significant"),
        Some(DesignState::Missing) => {
            StationStatus::absent(N, L, "design-significant, `## Design` missing")
        }
        Some(DesignState::Placeholder) => StationStatus::absent(N, L, "placeholder `## Design`"),
        None => StationStatus::absent(N, L, "no prompt"),
    }
}

/// Planner (HOW): the `## Plan` covers every acceptance criterion (`planner::plan_gate`).
fn planner_status(root: &Path, session: u32) -> StationStatus {
    const N: &str = "Planner";
    const L: &str = "HOW";
    match planner::plan_gate(root, session).plan {
        Some(PlanState::Covered) => StationStatus::passed(N, L, "plan covers all criteria"),
        Some(PlanState::Placeholder) => StationStatus::absent(N, L, "placeholder `## Plan`"),
        Some(PlanState::Absent) => StationStatus::absent(N, L, "no `## Plan`"),
        Some(PlanState::Uncovered(missing)) => StationStatus::absent(
            N,
            L,
            format!("plan misses criteria {}", join_nums(&missing)),
        ),
        None => StationStatus::absent(N, L, "no prompt"),
    }
}

/// Coder (DID): every plan step records a `done: <sha>` naming a commit that EXISTS
/// (`coder::exec_gate`).
fn coder_status(root: &Path, session: u32) -> StationStatus {
    const N: &str = "Coder";
    const L: &str = "DID";
    match coder::exec_gate(root, session).report.map(|r| r.state) {
        Some(ExecState::Recorded) => {
            StationStatus::passed(N, L, "all plan steps record an existing commit")
        }
        Some(ExecState::Unrecorded(missing)) => {
            StationStatus::absent(N, L, format!("steps {} not recorded", join_nums(&missing)))
        }
        Some(ExecState::NoExecution) => StationStatus::absent(N, L, "no `## Execution` trace"),
        Some(ExecState::NoPlan) => StationStatus::absent(N, L, "no plan to trace"),
        None => StationStatus::absent(N, L, "no prompt"),
    }
}

/// QA (WORKS): the verify script is recorded and present (`qa::gather_contract`) — STATIC. Weaker
/// than the close gate's live green; the note discloses it.
fn qa_status(root: &Path, session: u32) -> StationStatus {
    const N: &str = "QA";
    const L: &str = "WORKS";
    let c = qa::gather_contract(root, session);
    if c.script_exists {
        StationStatus::passed(N, L, "verify script recorded [static — not live-green]")
    } else {
        StationStatus::absent(N, L, "no verify script recorded")
    }
}

/// Demo-er (SHOW): the demo script is recorded and its TEXT carries every required element
/// (`demoer::gather_contract`) — STATIC. Weaker than the close gate's live element scan; disclosed.
fn demoer_status(root: &Path, session: u32) -> StationStatus {
    const N: &str = "Demo-er";
    const L: &str = "SHOW";
    let c = demoer::gather_contract(root, session);
    if !c.script_exists {
        StationStatus::absent(N, L, "no demo script recorded")
    } else if c.missing_in_file.is_empty() {
        StationStatus::passed(
            N,
            L,
            "demo script + all elements [static — not live-scanned]",
        )
    } else {
        StationStatus::absent(
            N,
            L,
            format!(
                "demo script missing elements: {}",
                c.missing_in_file.join(", ")
            ),
        )
    }
}

/// Releaser (SHIP): the session's branch is merged into main, main is synced, and merged locals are
/// pruned — re-derived live from git refs (`releaser::derive_ship_state`). Pruning the merged branch
/// is the REQUIRED end-state (the S37 close step), so a properly-shipped session reads `NoBranch` —
/// indistinguishable in git alone from a branch that never existed. When no ref survives, fall back
/// to the attested ledger (`session_attested_accept`): an attested ACCEPT review is evidence the
/// session shipped and was reviewed, so `NoBranch` + that evidence is PASSED, not a false ABSENT.
fn releaser_status(root: &Path, session: u32) -> StationStatus {
    const N: &str = "Releaser";
    const L: &str = "SHIP";
    match releaser::derive_ship_state(root, session) {
        Err(_) => StationStatus::absent(N, L, "ship state underivable (no git / no main)"),
        Ok(s) => match &s.branch {
            BranchShip::Unmerged(_) => StationStatus::absent(N, L, "branch not merged into main"),
            BranchShip::NoBranch => {
                if session_attested_accept(root, session) {
                    StationStatus::passed(
                        N,
                        L,
                        "no branch ref survives, but the ledger's attested ACCEPT review \
                         evidences it shipped",
                    )
                } else {
                    StationStatus::absent(
                        N,
                        L,
                        "no branch ref and no attested ACCEPT review in the ledger",
                    )
                }
            }
            BranchShip::Merged(_) => {
                let synced = s.sync == MainSync::Synced;
                let pruned = s.unpruned.is_empty();
                if synced && pruned {
                    StationStatus::passed(N, L, "branch merged, main synced, locals pruned")
                } else if !synced {
                    StationStatus::absent(N, L, "main not synced with origin")
                } else {
                    StationStatus::absent(N, L, "merged session locals not pruned")
                }
            }
        },
    }
}

/// Reviewer (REVIEW): the independent fidelity review exists, records a canonical
/// `**Verdict:** ACCEPT`, and is attested (`Review-Inputs-SHA`) — the SAME evidence
/// `verify-closeout.sh#check_fidelity_review` reads (no Rust reviewer classifier exists; this reads
/// the artifact, it does not re-run the cold review — disclosed).
fn reviewer_status(root: &Path, session: u32) -> StationStatus {
    const N: &str = "Reviewer";
    const L: &str = "REVIEW";
    let rel = format!("sessions/session-{session:02}-review.md");
    match fs::read_to_string(root.join(&rel)) {
        Err(_) => StationStatus::absent(N, L, "no review artifact"),
        Ok(text) => {
            let attested = text
                .lines()
                .any(|l| l.to_lowercase().contains("review-inputs-sha"));
            match review_verdict_accept(&text) {
                None => StationStatus::absent(N, L, "review records no canonical verdict"),
                Some(false) => StationStatus::absent(N, L, "review verdict is REJECT"),
                Some(true) if !attested => {
                    StationStatus::absent(N, L, "ACCEPT review not attested")
                }
                Some(true) => StationStatus::passed(N, L, "attested ACCEPT review"),
            }
        }
    }
}

// ---- Surface ---------------------------------------------------------------------------------

/// Render the station report for `vajra next --stations NN` — a per-station table + the derived
/// `K of 8`. Read-only; the count is computed here from classifiers, never read from a store.
pub fn format_station_report(r: &StationReport) -> String {
    let mut out = String::new();
    out.push_str(&format!(
        "=== stations: pipeline advance for session {:02} ===\n",
        r.session
    ));
    for s in &r.stations {
        let mark = match s.outcome {
            Outcome::Passed => "PASSED",
            Outcome::Absent => "ABSENT",
        };
        out.push_str(&format!(
            "  [{mark}] {name:<9} {lane:<6} — {note}\n",
            name = s.name,
            lane = s.lane,
            note = s.note,
        ));
    }
    out.push_str(&format!(
        "\n  {} of {} stations passed (derived from each gate's evidence — read-only, nothing executed)\n",
        r.passed(),
        STATION_COUNT,
    ));
    out
}

// ---- Helpers ---------------------------------------------------------------------------------

fn read_prompt(root: &Path, session: u32) -> Option<String> {
    let rel = analyst::find_prompt_for(root, session)?;
    fs::read_to_string(root.join(&rel)).ok()
}

/// The final canonical `**Verdict:** ACCEPT|REJECT` line resolves the review. Mirrors
/// `verify-closeout.sh`: a line whose text contains `verdict:` and then `accept`/`reject`. `None`
/// when no canonical verdict line exists ("No expected verdict supplied" has no colon — not a match).
fn review_verdict_accept(text: &str) -> Option<bool> {
    let verdicts: Vec<bool> = text
        .lines()
        .map(|l| l.to_lowercase())
        .filter(|l| l.contains("verdict:"))
        .filter_map(|l| {
            if l.contains("accept") {
                Some(true)
            } else if l.contains("reject") {
                Some(false)
            } else {
                None
            }
        })
        .collect();
    verdicts.last().copied()
}

/// Does session `session`'s independent review carry a canonical, attested `**Verdict:** ACCEPT`?
/// The same evidence `reviewer_status` reads (`review_verdict_accept` + the `Review-Inputs-SHA`
/// attestation line) — reused as the Releaser's `NoBranch` fallback: a branch pruned after a proper
/// merge (the required S37 end-state) is indistinguishable in git alone from a branch that never
/// existed; the attested ledger disambiguates the two.
fn session_attested_accept(root: &Path, session: u32) -> bool {
    let rel = format!("sessions/session-{session:02}-review.md");
    match fs::read_to_string(root.join(&rel)) {
        Err(_) => false,
        Ok(text) => {
            let attested = text
                .lines()
                .any(|l| l.to_lowercase().contains("review-inputs-sha"));
            attested && review_verdict_accept(&text) == Some(true)
        }
    }
}

fn join_nums(nums: &[u32]) -> String {
    nums.iter()
        .map(|n| n.to_string())
        .collect::<Vec<_>>()
        .join(", ")
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::process::Command;

    const CONSTRAINTS: &str = "\
version: 3

maturity: L2

verify:
  script_pattern: 'scripts/verify-session-{NN}.sh'
  artifacts_dir: '.ai/verify/session-{NN}/'

demo:
  script_pattern: 'scripts/demo-session-{NN}.sh'
  required_elements: [header, cases, summary_table, before_after]

release:
  require_merged_prior: true
  require_main_synced: true
  require_pruned: true
";

    fn git_in(dir: &Path, args: &[&str]) {
        let ok = Command::new("git")
            .args(args)
            .current_dir(dir)
            .output()
            .unwrap()
            .status
            .success();
        assert!(ok, "git {args:?} failed in {dir:?}");
    }

    /// A temp Vajra git repo on `main` with the house CONSTRAINTS + one commit.
    fn repo() -> tempfile::TempDir {
        let tmp = tempfile::tempdir().unwrap();
        let root = tmp.path();
        fs::create_dir_all(root.join(".ai")).unwrap();
        fs::create_dir_all(root.join("prompts")).unwrap();
        fs::create_dir_all(root.join("scripts")).unwrap();
        fs::create_dir_all(root.join("sessions")).unwrap();
        fs::create_dir_all(root.join("docs/decisions")).unwrap();
        fs::write(root.join(".ai/CONSTRAINTS.yaml"), CONSTRAINTS).unwrap();
        fs::write(
            root.join("docs/decisions/DECISION-001-pipeline.md"),
            "# DECISION-001 — governed pipeline\n",
        )
        .unwrap();
        git_in(root, &["init", "-q", "-b", "main"]);
        git_in(root, &["config", "user.email", "t@t"]);
        git_in(root, &["config", "user.name", "t"]);
        git_in(root, &["add", "-A"]);
        git_in(root, &["commit", "-qm", "init"]);
        tmp
    }

    /// A fully-filled prompt for session `nn`: substantive Delta, significant + spine-citing
    /// Design, a Plan covering both criteria, and an Execution trace whose sha is filled by the
    /// caller (so it can name a real commit).
    fn full_prompt(nn: u32, sha: &str) -> String {
        format!(
            "# Session {nn} — fixture\n\
             \n> **Status:** APPROVED\n\
             \ndesign-significant: yes\n\
             \n## Acceptance\n1. **WHEN** x **THEN** y\n2. **WHEN** a **THEN** b\n\
             \n## Design\nRests on DECISION-001 — the governed pipeline; real rationale here.\n\
             \n## Plan\n1. do the first thing. covers: 1\n2. do the second thing. covers: 2\n\
             \n## Execution\n- step 1 — done: {sha}\n- step 2 — done: {sha}\n\
             \n## Delta\n- `+` a real new capability the session adds\n"
        )
    }

    fn write_prompt(root: &Path, nn: u32, body: &str) {
        fs::write(root.join(format!("prompts/{nn:02}-task-fixture.md")), body).unwrap();
    }

    fn head_sha(root: &Path) -> String {
        let out = Command::new("git")
            .args(["rev-parse", "HEAD"])
            .current_dir(root)
            .output()
            .unwrap();
        String::from_utf8_lossy(&out.stdout).trim().to_string()
    }

    fn outcome(root: &Path, nn: u32, name: &str) -> Outcome {
        station_report(root, nn)
            .stations
            .into_iter()
            .find(|s| s.name == name)
            .unwrap()
            .outcome
    }

    #[test]
    fn analyst_passes_on_substantive_delta_absent_on_placeholder() {
        let tmp = repo();
        let root = tmp.path();
        write_prompt(root, 10, &full_prompt(10, "deadbeef"));
        assert_eq!(outcome(root, 10, "Analyst"), Outcome::Passed);

        // Placeholder Delta → ABSENT, and it AGREES with the analyst classifier (never disagree).
        let placeholder = "# S11\n\n## Delta\n- `+` <what this session ADDS…>\n";
        write_prompt(root, 11, placeholder);
        assert_eq!(outcome(root, 11, "Analyst"), Outcome::Absent);
        assert_eq!(
            analyst::validate_prompt(placeholder).delta,
            DeltaState::Placeholder
        );
    }

    #[test]
    fn planner_counter_agrees_with_plan_gate_on_same_fixture() {
        let tmp = repo();
        let root = tmp.path();

        // Covered plan → PASSED, and the plan_gate does NOT block.
        write_prompt(root, 20, &full_prompt(20, "deadbeef"));
        assert_eq!(outcome(root, 20, "Planner"), Outcome::Passed);
        assert!(!planner::plan_gate(root, 20).blocked());

        // Placeholder plan → ABSENT, and the plan_gate BLOCKS. The counter never says PASSED where
        // the gate statically blocks (criterion 3).
        let ph = "# S21\n\n## Acceptance\n1. do x\n\n## Plan\n1. <step>\n";
        write_prompt(root, 21, ph);
        assert_eq!(outcome(root, 21, "Planner"), Outcome::Absent);
        assert!(planner::plan_gate(root, 21).blocked());
    }

    #[test]
    fn architect_absent_when_not_design_significant() {
        let tmp = repo();
        let root = tmp.path();
        let fix = "# S30\n\ndesign-significant: no\n\n## Delta\n- `+` real thing\n";
        write_prompt(root, 30, fix);
        assert_eq!(outcome(root, 30, "Architect"), Outcome::Absent);
        // A pure fix legitimately maxes below 8/8 — it did not move through the Architect station.
    }

    #[test]
    fn qa_and_demoer_are_static_present_vs_absent() {
        let tmp = repo();
        let root = tmp.path();
        write_prompt(root, 40, &full_prompt(40, "deadbeef"));

        // No scripts yet → ABSENT.
        assert_eq!(outcome(root, 40, "QA"), Outcome::Absent);
        assert_eq!(outcome(root, 40, "Demo-er"), Outcome::Absent);

        // Verify script present → QA static PASS.
        fs::write(
            root.join("scripts/verify-session-40.sh"),
            "#!/bin/sh\ntrue\n",
        )
        .unwrap();
        assert_eq!(outcome(root, 40, "QA"), Outcome::Passed);

        // Demo script must carry EVERY required element in its text.
        fs::write(
            root.join("scripts/demo-session-40.sh"),
            "#!/bin/sh\necho demo:header; echo demo:cases\n",
        )
        .unwrap();
        assert_eq!(
            outcome(root, 40, "Demo-er"),
            Outcome::Absent,
            "missing summary_table/before_after elements"
        );
        fs::write(
            root.join("scripts/demo-session-40.sh"),
            "#!/bin/sh\necho demo:header demo:cases demo:summary_table demo:before_after\n",
        )
        .unwrap();
        assert_eq!(outcome(root, 40, "Demo-er"), Outcome::Passed);
    }

    #[test]
    fn releaser_passes_only_when_branch_merged_and_pruned() {
        let tmp = repo();
        let root = tmp.path();

        // Cut + merge session-50, but leave the local branch UNPRUNED → ABSENT.
        git_in(root, &["checkout", "-qb", "session-50-x"]);
        fs::write(root.join("f50.txt"), "w\n").unwrap();
        git_in(root, &["add", "-A"]);
        git_in(root, &["commit", "-qm", "s50"]);
        git_in(root, &["checkout", "-q", "main"]);
        git_in(
            root,
            &["merge", "-q", "--no-ff", "session-50-x", "-m", "merge 50"],
        );
        assert_eq!(outcome(root, 50, "Releaser"), Outcome::Absent); // unpruned

        // Prune it → no ref survives at all (NoBranch); no attested review exists for this
        // session, so the ledger fallback finds no evidence either → still ABSENT.
        git_in(root, &["branch", "-D", "session-50-x"]);
        assert_eq!(outcome(root, 50, "Releaser"), Outcome::Absent);
    }

    #[test]
    fn releaser_passes_when_no_branch_but_ledger_attested() {
        let tmp = repo();
        let root = tmp.path();

        // Merge + prune → NoBranch, indistinguishable in git alone from "never created".
        git_in(root, &["checkout", "-qb", "session-51-x"]);
        fs::write(root.join("f51.txt"), "w\n").unwrap();
        git_in(root, &["add", "-A"]);
        git_in(root, &["commit", "-qm", "s51"]);
        git_in(root, &["checkout", "-q", "main"]);
        git_in(
            root,
            &["merge", "-q", "--no-ff", "session-51-x", "-m", "merge 51"],
        );
        git_in(root, &["branch", "-D", "session-51-x"]);

        // An attested ACCEPT review is the ledger evidence that disambiguates: PASSED.
        fs::write(
            root.join("sessions/session-51-review.md"),
            "**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** abc123\n",
        )
        .unwrap();
        assert_eq!(outcome(root, 51, "Releaser"), Outcome::Passed);
    }

    #[test]
    fn releaser_absent_when_no_branch_and_no_ledger() {
        let tmp = repo();
        let root = tmp.path();
        // No branch ever existed and no review artifact — a ghost session must not earn PASSED.
        assert_eq!(outcome(root, 52, "Releaser"), Outcome::Absent);
    }

    #[test]
    fn releaser_absent_when_no_branch_but_ledger_rejects() {
        let tmp = repo();
        let root = tmp.path();

        git_in(root, &["checkout", "-qb", "session-53-x"]);
        fs::write(root.join("f53.txt"), "w\n").unwrap();
        git_in(root, &["add", "-A"]);
        git_in(root, &["commit", "-qm", "s53"]);
        git_in(root, &["checkout", "-q", "main"]);
        git_in(
            root,
            &["merge", "-q", "--no-ff", "session-53-x", "-m", "merge 53"],
        );
        git_in(root, &["branch", "-D", "session-53-x"]);

        // A REJECT verdict (even attested) is not shipping evidence — still ABSENT.
        fs::write(
            root.join("sessions/session-53-review.md"),
            "**Verdict:** REJECT\n\n**Review-Inputs-SHA:** abc123\n",
        )
        .unwrap();
        assert_eq!(outcome(root, 53, "Releaser"), Outcome::Absent);
    }

    #[test]
    fn reviewer_passes_only_on_attested_accept() {
        let tmp = repo();
        let root = tmp.path();

        // Missing → ABSENT.
        assert_eq!(outcome(root, 60, "Reviewer"), Outcome::Absent);

        // ACCEPT but no attestation → ABSENT.
        fs::write(
            root.join("sessions/session-60-review.md"),
            "## Verdict\n**Verdict:** ACCEPT\n",
        )
        .unwrap();
        assert_eq!(outcome(root, 60, "Reviewer"), Outcome::Absent);

        // Attested ACCEPT → PASSED.
        fs::write(
            root.join("sessions/session-60-review.md"),
            "## Verdict\n**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** abc123\n",
        )
        .unwrap();
        assert_eq!(outcome(root, 60, "Reviewer"), Outcome::Passed);

        // REJECT (even attested) → ABSENT.
        fs::write(
            root.join("sessions/session-60-review.md"),
            "## Verdict\n**Verdict:** REJECT\n\n**Review-Inputs-SHA:** abc123\n",
        )
        .unwrap();
        assert_eq!(outcome(root, 60, "Reviewer"), Outcome::Absent);
    }

    #[test]
    fn placeholder_laden_prompt_counts_low() {
        let tmp = repo();
        let root = tmp.path();
        let scaffold = "\
# S70\n\ndesign-significant: yes\n\n## Acceptance\n1. do x\n\n## Design\n<why>\n\
\n## Plan\n1. <step>\n\n## Execution\n- step 1 — done: <sha>\n\n## Delta\n- `+` <adds>\n";
        write_prompt(root, 70, scaffold);
        let r = station_report(root, 70);
        assert_eq!(
            r.passed(),
            0,
            "a fresh scaffold demonstrably passes nothing"
        );
    }

    #[test]
    fn fully_filled_session_counts_high() {
        let tmp = repo();
        let root = tmp.path();

        // Land the fixture prompt + scripts + review on a session branch, then merge + prune so the
        // Releaser derives a shipped state from the pruned branch's attested ledger evidence — the
        // honest ceiling on a fully-evidenced fixture is 8/8.
        write_prompt(root, 80, "placeholder");
        fs::write(
            root.join("scripts/verify-session-80.sh"),
            "#!/bin/sh\ntrue\n",
        )
        .unwrap();
        fs::write(
            root.join("scripts/demo-session-80.sh"),
            "#!/bin/sh\necho demo:header demo:cases demo:summary_table demo:before_after\n",
        )
        .unwrap();
        fs::write(
            root.join("sessions/session-80-review.md"),
            "**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** abc\n",
        )
        .unwrap();
        git_in(root, &["add", "-A"]);
        git_in(root, &["commit", "-qm", "s80 scaffold"]);
        let sha = head_sha(root);
        // Now the Execution trace can name a real commit.
        write_prompt(root, 80, &full_prompt(80, &sha));
        git_in(root, &["checkout", "-qb", "session-80-x"]);
        git_in(root, &["add", "-A"]);
        git_in(root, &["commit", "-qm", "s80 work"]);
        git_in(root, &["checkout", "-q", "main"]);
        git_in(
            root,
            &["merge", "-q", "--no-ff", "session-80-x", "-m", "merge 80"],
        );
        git_in(root, &["branch", "-D", "session-80-x"]);

        let r = station_report(root, 80);
        let passed: Vec<&str> = r
            .stations
            .iter()
            .filter(|s| s.outcome == Outcome::Passed)
            .map(|s| s.name)
            .collect();
        assert!(
            passed.contains(&"Analyst")
                && passed.contains(&"Architect")
                && passed.contains(&"Planner")
                && passed.contains(&"Coder")
                && passed.contains(&"QA")
                && passed.contains(&"Demo-er")
                && passed.contains(&"Releaser")
                && passed.contains(&"Reviewer"),
            "all eight stations should pass on a fully-evidenced fixture, got {passed:?}"
        );
        assert_eq!(
            r.passed(),
            8,
            "a fully-evidenced fixture (attested ACCEPT ledger) reaches 8/8"
        );
    }

    #[test]
    fn report_has_exactly_eight_stations() {
        let tmp = repo();
        assert_eq!(station_report(tmp.path(), 1).stations.len(), STATION_COUNT);
    }
}
