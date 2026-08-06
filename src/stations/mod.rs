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
use std::io::Write;
use std::path::Path;
use std::process::{Command, Stdio};

use crate::analyst::{self, DeltaState};
use crate::architect::{self, DesignState};
use crate::coder::{self, ExecState};
use crate::demoer;
use crate::fleet;
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
    /// The prompt EXISTS but predates the station-marker convention entirely — it carries none of
    /// the marker sections the gates read (S99, the S97 Rung-1 finding). Reported apart from
    /// `Absent` because the two mean opposite things about the session: `Absent` says *the work
    /// was not done*, `Legacy` says *the repo cannot record that it was*. Conflating them made
    /// `--stations` read an older-scaffolded repo as an idle one. Never counts toward `K of 8` —
    /// an unmeasurable station is not a passed station.
    Legacy,
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
    /// The prompt predates the marker convention — cause + remedy in one note (S99).
    fn legacy(name: &'static str, lane: &'static str) -> Self {
        StationStatus {
            name,
            lane,
            outcome: Outcome::Legacy,
            note: "prompt predates the station-marker convention — re-scaffold with \
                   `vajra next --advance` (not measurable, not idle)"
                .into(),
        }
    }
}

/// What the fleet (DECISION-007) demonstrably did for a session — reported **beside** `K of 8`,
/// never inside it (S113, design shape (c)).
///
/// The counter's eight stations, their classifiers, and the number they produce are untouched by
/// this type, so S74's `K` and S113's `K` mean exactly the same thing. A 9th station would have
/// broken that comparability; folding fleet work into an existing station's verdict would have been
/// worse — old and new `K` would look identical while measuring different things.
///
/// Derived, never asserted (the same rule the stations follow): every entry comes from
/// `fleet::read_handoffs`, i.e. a handoff **parsed and validated off disk**. A file that exists but
/// fails the DECISION-007 contract is named as malformed, never counted as fleet work done.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct FleetEvidence {
    /// The role name of each contract-valid governed handoff found for this session.
    pub governed: Vec<String>,
    /// `(repo-relative path, reason)` for each file at a role's handoff path that fails the
    /// contract. Surfaced, never swallowed — an unusable artifact is a problem to show.
    pub malformed: Vec<(String, String)>,
}

impl FleetEvidence {
    /// No fleet artifact of any kind for this session — the silent case. Most sessions are this,
    /// and they must render byte-for-byte as they did before S113.
    pub fn is_empty(&self) -> bool {
        self.governed.is_empty() && self.malformed.is_empty()
    }
}

/// Derive session `session`'s fleet evidence — read-only (one fs read per registered role, via
/// `fleet::read_handoffs`), nothing executes.
pub fn fleet_evidence(root: &Path, session: u32) -> FleetEvidence {
    let mut ev = FleetEvidence::default();
    for read in fleet::read_handoffs(root, session) {
        match read {
            fleet::HandoffRead::Found(h) => ev.governed.push(h.role),
            fleet::HandoffRead::Malformed(path, reason) => ev.malformed.push((path, reason)),
            // `read_handoffs` already drops these; matched explicitly so a future variant is a
            // compile error rather than a silent omission.
            fleet::HandoffRead::Absent => {}
        }
    }
    ev
}

/// The per-session station report — the eight statuses plus a derived `K of 8`, and (S113) the
/// session's fleet evidence carried alongside it.
#[derive(Debug, Clone)]
pub struct StationReport {
    pub session: u32,
    pub stations: Vec<StationStatus>,
    /// Fleet work for this session. Reported next to `K of 8`; contributes **nothing** to it.
    pub fleet: FleetEvidence,
}

impl StationReport {
    /// How many stations DEMONSTRABLY passed — the payload count.
    pub fn passed(&self) -> usize {
        self.stations
            .iter()
            .filter(|s| s.outcome == Outcome::Passed)
            .count()
    }

    /// How many stations are UNMEASURABLE because the prompt predates the marker convention
    /// (S99). Reported alongside `K of 8` so a low count in an older-scaffolded repo is never
    /// read as "the pipeline stalled".
    pub fn legacy(&self) -> usize {
        self.stations
            .iter()
            .filter(|s| s.outcome == Outcome::Legacy)
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
        fleet: fleet_evidence(root, session),
    }
}

// ---- Per-station derivations (each reuses that station's own classifier) --------------------

/// Analyst (WHAT): the prompt's `## Delta` is substantive (`analyst::validate_prompt`).
fn analyst_status(root: &Path, session: u32) -> StationStatus {
    const N: &str = "Analyst";
    const L: &str = "WHAT";
    if is_legacy_prompt(root, session) {
        return StationStatus::legacy(N, L);
    }
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
    if is_legacy_prompt(root, session) {
        return StationStatus::legacy(N, L);
    }
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
    if is_legacy_prompt(root, session) {
        return StationStatus::legacy(N, L);
    }
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
    if is_legacy_prompt(root, session) {
        return StationStatus::legacy(N, L);
    }
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
/// `**Verdict:** ACCEPT`, and its `Review-Inputs-SHA` is cryptographically VERIFIED (S86,
/// `attested_hash_outcome`) — not merely present, the pre-S86 bug. Still disclosed: no Rust
/// classifier re-runs the cold fidelity REVIEW itself (that stays
/// `verify-closeout.sh#check_fidelity_review`'s job); this only re-derives whether the recorded
/// hash is genuine.
fn reviewer_status(root: &Path, session: u32) -> StationStatus {
    const N: &str = "Reviewer";
    const L: &str = "REVIEW";
    let rel = format!("sessions/session-{session:02}-review.md");
    match fs::read_to_string(root.join(&rel)) {
        Err(_) => StationStatus::absent(N, L, "no review artifact"),
        Ok(text) => match review_verdict_accept(&text) {
            None => StationStatus::absent(N, L, "review records no canonical verdict"),
            Some(false) => StationStatus::absent(N, L, "review verdict is REJECT"),
            Some(true) => match attested_hash_outcome(root, session, &text) {
                AttestOutcome::NotAttested => {
                    StationStatus::absent(N, L, "ACCEPT review not attested")
                }
                AttestOutcome::Unverifiable => StationStatus::absent(
                    N,
                    L,
                    "ACCEPT review's Review-Inputs-SHA matches no reconstructable diff \
                     (forged/stale/recycled, or an unreconstructable historical hash)",
                ),
                AttestOutcome::Verified => {
                    StationStatus::passed(N, L, "attested ACCEPT review, hash verified")
                }
            },
        },
    }
}

// ---- Team voice (S104) -----------------------------------------------------------------------
//
// The founder's S103 critique: "station K-of-8" reads like plumbing, not a product. This layer
// gives each of the eight stations a human ROLE and a plain-English status line, so the pipeline
// reads like a team ("Analyst ✓ framed the goal · Coder — no code yet") rather than a bare
// number. It is PRESENTATION ONLY — it reads the SAME `Outcome` the gates compute and changes no
// pass/fail logic. Defined ONCE here (the S19 no-drift rule) and reused by BOTH
// `vajra next --stations` and the `vajra next` handoff packet — never a second copy.

/// One governed station's human face: the plain phrase for each outcome. The `station` field is
/// the join key to `StationStatus.name`, so a station and its narration can never disagree.
struct Role {
    /// Matches `StationStatus.name` exactly — how an outcome finds its narration.
    station: &'static str,
    /// What this role DID, in plain words, when its station PASSED.
    done: &'static str,
    /// What this role has NOT done yet when its station is ABSENT.
    pending: &'static str,
}

/// Shared phrase for a station whose prompt predates the marker convention (S99): the work may be
/// done, but this older brief cannot record it — the same meaning `Outcome::Legacy` carries.
const LEGACY_PHRASE: &str = "can't tell yet — this brief predates the team";

/// The eight roles in pipeline order — the ONE place role phrasing lives (S19 no-drift). Every
/// `station` here must match a `StationStatus.name`; `roles_cover_every_station` pins that.
const ROLES: [Role; STATION_COUNT] = [
    Role {
        station: "Analyst",
        done: "framed what to build",
        pending: "hasn't framed the goal yet",
    },
    Role {
        station: "Architect",
        done: "recorded the design",
        pending: "no design recorded yet",
    },
    Role {
        station: "Planner",
        done: "mapped a plan to the goal",
        pending: "no plan covering the goal yet",
    },
    Role {
        station: "Coder",
        done: "landed the code",
        pending: "no code committed yet",
    },
    Role {
        station: "QA",
        done: "the checks pass",
        pending: "checks not run yet",
    },
    Role {
        station: "Demo-er",
        done: "has a demo to show",
        pending: "no demo yet",
    },
    Role {
        station: "Releaser",
        done: "shipped it",
        pending: "not shipped yet",
    },
    Role {
        station: "Reviewer",
        done: "signed off",
        pending: "no sign-off yet",
    },
];

fn role_of(name: &str) -> Option<&'static Role> {
    ROLES.iter().find(|r| r.station == name)
}

/// One roster line for a station's outcome — `<mark> <Role> <plain phrase>`. The mark and phrase
/// are chosen purely from the `Outcome` the gate already computed; this authors no new verdict.
fn role_line(s: &StationStatus) -> String {
    let (mark, phrase) = match s.outcome {
        Outcome::Passed => (
            "✓",
            role_of(s.name).map(|r| r.done).unwrap_or(s.note.as_str()),
        ),
        Outcome::Absent => (
            "—",
            role_of(s.name)
                .map(|r| r.pending)
                .unwrap_or(s.note.as_str()),
        ),
        Outcome::Legacy => ("?", LEGACY_PHRASE),
    };
    format!("{mark} {name:<9} {phrase}", name = s.name)
}

/// The human-facing team roster — each station as a named role with a plain status line. The ONE
/// renderer reused by `vajra next --stations` (as its headline) and the `vajra next` packet.
pub fn format_team_roster(r: &StationReport) -> String {
    let mut out = String::new();
    for s in &r.stations {
        out.push_str("  ");
        out.push_str(&role_line(s));
        out.push('\n');
    }
    out
}

// ---- Surface ---------------------------------------------------------------------------------

/// Render the station report for `vajra next --stations NN`. Headline = the human TEAM roster
/// (S104); below it, the derived `K of 8` subtitle plus the machine-readable per-station detail
/// (unchanged — auditable). Read-only; the count is computed from classifiers, never a store.
pub fn format_station_report(r: &StationReport) -> String {
    let mut out = String::new();
    // S104 team voice: the roster leads — plain English, one line per role.
    out.push_str(&format!(
        "=== session {:02} — the pipeline team ===\n\n",
        r.session
    ));
    out.push_str(&format_team_roster(r));
    out.push('\n');
    // The original per-station table + `K of 8` subtitle + legacy disclosure — UNCHANGED, kept as
    // the auditable detail beneath the team headline.
    out.push_str(&format!(
        "=== stations: pipeline advance for session {:02} ===\n",
        r.session
    ));
    for s in &r.stations {
        let mark = match s.outcome {
            Outcome::Passed => "PASSED",
            Outcome::Absent => "ABSENT",
            Outcome::Legacy => "LEGACY",
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
    // S113: fleet work, BESIDE `K of 8` — the line above is untouched, so K stays comparable
    // across every session that ever printed it. Silent when there is no fleet artifact at all.
    out.push_str(&format_fleet_line(&r.fleet));
    // S99: never let a legacy-convention repo read as an idle one — say so on the same surface.
    if r.legacy() > 0 {
        out.push_str(&format!(
            "  note: {} station(s) UNMEASURABLE — this prompt predates the station-marker\n  \
             convention, so absence of markers is not absence of work. `vajra next --advance`\n  \
             scaffolds a modern prompt; `vajra init` (skip-if-present) restores missing guards.\n",
            r.legacy(),
        ));
    }
    out
}

/// Render fleet evidence as the line(s) that sit BESIDE `K of 8` (S113). Empty evidence renders the
/// empty string — a session with no fleet work reads exactly as it did before this existed.
///
/// The wording is deliberate: every line says the evidence is **not counted in K**, so no reader can
/// mistake a fleet handoff for a station pass, and `K` never silently changes meaning.
pub fn format_fleet_line(ev: &FleetEvidence) -> String {
    let mut out = String::new();
    if ev.is_empty() {
        return out;
    }
    if !ev.governed.is_empty() {
        out.push_str(&format!(
            "  fleet: {n} governed handoff(s) — {roles} (derived from the validated handoff on \
             disk; reported beside K, NOT counted in it)\n",
            n = ev.governed.len(),
            roles = ev.governed.join(", "),
        ));
    }
    for (path, reason) in &ev.malformed {
        out.push_str(&format!(
            "  ⚠ fleet: {path} exists but does not satisfy the handoff contract ({reason}) \
             — not counted\n"
        ));
    }
    out
}

// ---- Helpers ---------------------------------------------------------------------------------

fn read_prompt(root: &Path, session: u32) -> Option<String> {
    let rel = analyst::find_prompt_for(root, session)?;
    fs::read_to_string(root.join(&rel)).ok()
}

/// The five section headings the four prompt-driven stations read. A prompt carrying at least one
/// of them speaks the modern convention; a prompt carrying none of them predates it.
const MARKER_HEADINGS: [&str; 5] = ["acceptance", "design", "plan", "execution", "delta"];

/// Does session `session`'s prompt exist but speak NONE of the station-marker convention (S99)?
///
/// The discriminator is deliberately generous: ONE marker heading is enough to count as modern, so
/// a half-filled prompt keeps reporting per-station ABSENT (the convention is there; the work is
/// not). Only a prompt with zero markers — the shape `vajra init` emitted before S99, and the shape
/// chitra's `prompts/00–03` still carry — is classified legacy. A missing prompt is NOT legacy:
/// "no prompt" is already an unambiguous note.
fn is_legacy_prompt(root: &Path, session: u32) -> bool {
    let Some(content) = read_prompt(root, session) else {
        return false;
    };
    !content.lines().any(|line| {
        let t = line.trim_start();
        if !t.starts_with('#') {
            return false;
        }
        let lowered = t.trim_start_matches('#').trim().to_ascii_lowercase();
        let first = lowered.split_whitespace().next().unwrap_or_default();
        MARKER_HEADINGS.contains(&first)
    })
}

/// Read a session's prompt file bytes **as they existed in one specific commit's tree**
/// (`git show <tip>:<rel>`), never the live working tree. This is the per-candidate twin of
/// `read_prompt`: `attested_hash_outcome` tries several historical `(base, tip)` candidates, and
/// each one's hash must be checked against the prompt bytes AS THEY STOOD AT THAT TIP — a later
/// commit editing the same prompt path (the S87→S76 live incident: filling in unrelated `<sha>`
/// placeholders un-attested an already-ACCEPTed review) must never change an earlier candidate's
/// hash. `None` when the blob doesn't exist at `tip` (e.g. the file was added/renamed after that
/// commit) — the caller just skips this candidate, same as any other unreconstructable one.
fn prompt_bytes_at(root: &Path, tip: &str, rel: &str) -> Option<Vec<u8>> {
    let out = Command::new("git")
        .args(["show", &format!("{tip}:{rel}")])
        .current_dir(root)
        .output()
        .ok()?;
    out.status.success().then_some(out.stdout)
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

/// Does session `session`'s independent review carry a canonical, cryptographically-VERIFIED
/// `**Verdict:** ACCEPT`? The SAME `attested_hash_outcome` `reviewer_status` calls (S86, no
/// hand-duplication) — reused as the Releaser's `NoBranch` fallback: a branch pruned after a
/// proper merge (the required S37 end-state) is indistinguishable in git alone from a branch that
/// never existed; a genuinely verified attestation disambiguates the two.
fn session_attested_accept(root: &Path, session: u32) -> bool {
    let rel = format!("sessions/session-{session:02}-review.md");
    match fs::read_to_string(root.join(&rel)) {
        Err(_) => false,
        Ok(text) => {
            review_verdict_accept(&text) == Some(true)
                && attested_hash_outcome(root, session, &text) == AttestOutcome::Verified
        }
    }
}

// ---- Attestation hash verification (S86) ------------------------------------------------------
//
// Pre-S86 bug: both call sites above classified an ACCEPT review as "attested" via
// `text.lines().any(|l| l.to_lowercase().contains("review-inputs-sha"))` — the LABEL's presence,
// never the claimed hash's value. A review with `**Review-Inputs-SHA:** <64 hex chars of garbage>`
// satisfied it. Fix: recompute the SAME `sha256(prompt bytes \0 delivery diff)` preimage
// `verify-closeout.sh#canonical_inputs_sha` commits to, and compare.
//
// The hard part (why this isn't a one-line change): `git merge-base main HEAD` — the bash script's
// own base — is only valid PRE-merge. Empirically confirmed on this repo: recomputing it live,
// post-merge, for a real historical session (S84) produces a materially different, WRONG hash
// (base collapses to HEAD once main has absorbed the branch, so the "diff" is empty). A naive
// live-only recompute would therefore falsely reject nearly every already-accepted historical
// session — worse than the bug it fixes. Fix for THAT: a `--no-ff` merge (this repo's convention,
// never squash) preserves both parents on the merge commit forever, even after the branch ref
// itself is pruned — so `candidate_diffs` recovers (base, tip) from every merge commit reachable
// from `main`, not just a live, possibly-vanished branch ref. Confirmed empirically: this
// reproduces the exact recorded hash for 16 of 20 real historical reviews sampled from this
// repo's own history. The remaining 4 (S64, S69, S73, S79) reproduce under NO candidate, even
// after searching every merge commit in the repo — most plausibly because
// `canonical_inputs_sha`'s own exclude-list/algorithm changed after their hash was computed, not
// forgery. This function CANNOT tell "genuinely unreconstructable" apart from "forged" — both
// fail closed as `Unverifiable`. That is a deliberate, disclosed trade-off (fail-closed per the
// constitution's L4: "a check that cannot evaluate FAILS. Never silently pass."), not a silent
// reintroduction of the old bug: unlike the old bug, a garbage/forged/recycled hash can no longer
// silently PASS.

/// Outcome of checking whether a review's claimed `Review-Inputs-SHA` is genuine — the shared
/// logic both `reviewer_status` and `session_attested_accept` call.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum AttestOutcome {
    /// No well-formed 64-hex `Review-Inputs-SHA` value on any line.
    NotAttested,
    /// The claimed hash was reproduced from a real, reconstructable diff.
    Verified,
    /// A well-formed hash is present but no reconstructable diff (live or historical)
    /// reproduces it — see the module note above for why this is a deliberate, disclosed
    /// fail-closed conflation, not a gap.
    Unverifiable,
}

fn attested_hash_outcome(root: &Path, session: u32, review_text: &str) -> AttestOutcome {
    let Some(claimed) = claimed_inputs_sha(review_text) else {
        return AttestOutcome::NotAttested;
    };
    // The FILENAME is resolved once, live (a prompt is never renamed post-merge — the same
    // accepted limitation `find_prompt_for` already carries elsewhere). The BYTES are re-read
    // per candidate, from that candidate's own `tip` tree — never one shared live buffer (the
    // S87-discovered bug: a later, unrelated commit editing this same path used to retroactively
    // change every earlier candidate's hash too).
    let Some(rel) = analyst::find_prompt_for(root, session) else {
        return AttestOutcome::Unverifiable;
    };
    for (base, tip) in candidate_diffs(root) {
        let Some(prompt) = prompt_bytes_at(root, &tip, &rel) else {
            continue;
        };
        if let Some(h) = diff_hash(root, &base, &tip, &prompt) {
            if h == claimed {
                return AttestOutcome::Verified;
            }
        }
    }
    AttestOutcome::Unverifiable
}

/// The first well-formed (>=64 consecutive hex chars, first 64 taken) value on the FIRST line
/// that actually IS the attestation (not merely a line that mentions it in prose — this session's
/// own review file discusses the label by name in several places, none of which are the real
/// attestation). Same anchored match `verify-closeout.sh` uses
/// (`grep -m1 -iE '^[*_[:space:]]*Review-Inputs-SHA[*_[:space:]]*:'`, then
/// `grep -oiE '[0-9a-f]{64}'`) — a bare `.contains()` here would have hit the WRONG line (proven
/// live: it did, on this repo's own `sessions/session-82-review.md`, whose line 17 mentions the
/// label in a table cell before line 89's real attestation).
fn claimed_inputs_sha(text: &str) -> Option<String> {
    text.lines()
        .find(|l| is_attestation_line(l))
        .and_then(|l| extract_hex64(&l.to_lowercase()))
}

/// Mirrors `verify-closeout.sh`'s anchored pattern
/// `^[*_[:space:]]*Review-Inputs-SHA[*_[:space:]]*:` — the line must START WITH (after optional
/// markdown emphasis markers/whitespace) the literal label followed by a colon, not merely
/// mention it somewhere in prose or a code sample.
fn is_attestation_line(line: &str) -> bool {
    let after_markup = line.trim_start_matches(|c: char| c == '*' || c == '_' || c.is_whitespace());
    let lower = after_markup.to_lowercase();
    let Some(rest) = lower.strip_prefix("review-inputs-sha") else {
        return false;
    };
    rest.trim_start_matches(|c: char| c == '*' || c == '_' || c.is_whitespace())
        .starts_with(':')
}

fn extract_hex64(lower_line: &str) -> Option<String> {
    let chars: Vec<char> = lower_line.chars().collect();
    let mut i = 0;
    while i < chars.len() {
        if chars[i].is_ascii_hexdigit() {
            let start = i;
            while i < chars.len() && chars[i].is_ascii_hexdigit() {
                i += 1;
            }
            if i - start >= 64 {
                return Some(chars[start..start + 64].iter().collect());
            }
        } else {
            i += 1;
        }
    }
    None
}

/// Run a read-only git plumbing command at `root`; `Some((exit_code, stdout))` when it spawned.
fn git_out(root: &Path, args: &[&str]) -> Option<(i32, String)> {
    let out = Command::new("git")
        .args(args)
        .current_dir(root)
        .output()
        .ok()?;
    Some((
        out.status.code()?,
        String::from_utf8_lossy(&out.stdout).into_owned(),
    ))
}

/// Every (base, tip) pair whose diff might reproduce a session's attestation hash: the live,
/// not-yet-merged current branch against `main` (base = merge-base, tip = HEAD) — correct when
/// nothing has been pruned yet — plus every 2-parent merge commit reachable from `main`, whose own
/// two parents ARE the original merge-base and branch tip even after the branch ref itself was
/// pruned (a `--no-ff` merge, this repo's convention, preserves both parents forever).
///
/// For each historical `(base, tip)`, we also enumerate EVERY intermediate commit on the branch
/// (`git log base..tip` minus `tip` itself) and add it as a separate `(base, intermediate)`
/// candidate. This handles sessions where `--inputs-sha` was computed before the final closeout
/// commit (e.g. S89: execution shas were added to the prompt in the same commit that committed
/// the review, so the hash necessarily captured the state one commit earlier — the branch tip
/// carries a different prompt, so `(base, tip)` alone never matches).
fn candidate_diffs(root: &Path) -> Vec<(String, String)> {
    let mut out = Vec::new();
    if let (Some((0, head)), Some((0, base))) = (
        git_out(root, &["rev-parse", "HEAD"]),
        git_out(root, &["merge-base", "main", "HEAD"]),
    ) {
        out.push((base.trim().to_string(), head.trim().to_string()));
    }
    if let Some((0, log)) = git_out(root, &["log", "--merges", "--format=%P", "main"]) {
        for line in log.lines() {
            let mut parents = line.split_whitespace();
            if let (Some(p1), Some(p2)) = (parents.next(), parents.next()) {
                if let Some((0, base_raw)) = git_out(root, &["merge-base", p1, p2]) {
                    let base = base_raw.trim().to_string();
                    // Primary candidate: the branch tip.
                    out.push((base.clone(), p2.to_string()));
                    // Intermediate candidates: every commit on the branch between base and tip.
                    // `git log base..p2` lists them newest-first; `tip` is the first entry.
                    if let Some((0, commits)) =
                        git_out(root, &["log", "--format=%H", &format!("{base}..{p2}")])
                    {
                        for commit in commits.lines().skip(1) {
                            let c = commit.trim();
                            if !c.is_empty() {
                                out.push((base.clone(), c.to_string()));
                            }
                        }
                    }
                }
            }
        }
    }
    out
}

/// `sha256(prompt_bytes \0 delivery_diff)` for one (base, tip) candidate — the SAME preimage and
/// exclude list as `verify-closeout.sh#canonical_inputs_sha`, so a genuine attestation from either
/// side always matches. `None` when the diff or hash cannot be computed — the caller just tries
/// the next candidate.
fn diff_hash(root: &Path, base: &str, tip: &str, prompt_bytes: &[u8]) -> Option<String> {
    let out = Command::new("git")
        .args([
            "diff",
            "--no-color",
            "--no-ext-diff",
            base,
            tip,
            "--",
            ":(exclude)sessions",
            ":(exclude)prompts",
            ":(exclude).ai/STATE.md",
            ":(exclude).ai/SESSION-BOOT.md",
            ":(exclude).ai/SESSION",
            ":(exclude).ai/TASK.md",
            ":(exclude).ai/ROADMAP.md",
            ":(exclude).ai/KNOWLEDGE.md",
            ":(exclude).ai/verify",
            ":(exclude).ai/.session-owner",
        ])
        .current_dir(root)
        .output()
        .ok()?;
    if !out.status.success() {
        return None;
    }
    // `canonical_inputs_sha`'s bash captures the diff via `$(...)`, which strips ALL trailing
    // newlines before hashing — match that exactly, or every hash mismatches (confirmed the hard
    // way: this repo's own S84 review hash only reproduces once trailing '\n's are stripped here).
    let mut diff_bytes = out.stdout.as_slice();
    while diff_bytes.last() == Some(&b'\n') {
        diff_bytes = &diff_bytes[..diff_bytes.len() - 1];
    }
    let mut preimage = Vec::with_capacity(prompt_bytes.len() + 1 + diff_bytes.len());
    preimage.extend_from_slice(prompt_bytes);
    preimage.push(0u8);
    preimage.extend_from_slice(diff_bytes);
    sha256_hex(&preimage)
}

/// Shell out for the hash (same tool-fallback order as `verify-closeout.sh#_sha256`) rather than
/// add a crate dependency for one hash — this codebase already shells out to git everywhere here.
fn sha256_hex(bytes: &[u8]) -> Option<String> {
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

    /// Cut `session-{nn}-x` off the current HEAD, add one real file change, merge it into `main`
    /// (`--no-ff`, this repo's convention — never squash), and delete the local branch — mirrors
    /// the mandatory S37 close step (merge + prune). Returns (pre-merge main tip, branch tip) so
    /// callers can compute the REAL canonical hash the same way `attested_hash_outcome`
    /// re-derives it via `candidate_diffs`/`diff_hash`.
    fn merge_and_prune_session_branch(root: &Path, nn: u32, marker: &str) -> (String, String) {
        let branch = format!("session-{nn:02}-x");
        let base = head_sha(root);
        git_in(root, &["checkout", "-qb", &branch]);
        fs::write(root.join(format!("{marker}.txt")), "work\n").unwrap();
        git_in(root, &["add", "-A"]);
        git_in(root, &["commit", "-qm", &format!("s{nn} work")]);
        let tip = head_sha(root);
        git_in(root, &["checkout", "-q", "main"]);
        git_in(
            root,
            &[
                "merge",
                "-q",
                "--no-ff",
                &branch,
                "-m",
                &format!("merge {nn}"),
            ],
        );
        git_in(root, &["branch", "-D", &branch]);
        (base, tip)
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
        let prompt = "prompt for session 51\n";
        write_prompt(root, 51, prompt);
        let (base, tip) = merge_and_prune_session_branch(root, 51, "f51");

        // An attested ACCEPT review with a REAL, cryptographically-verified hash (S86 — a bare
        // label used to be enough) is the ledger evidence that disambiguates: PASSED.
        let real_hash =
            diff_hash(root, &base, &tip, prompt.as_bytes()).expect("diff hash computable");
        fs::write(
            root.join("sessions/session-51-review.md"),
            format!("**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** {real_hash}\n"),
        )
        .unwrap();
        assert_eq!(outcome(root, 51, "Releaser"), Outcome::Passed);
    }

    #[test]
    fn releaser_absent_when_no_branch_but_hash_forged() {
        let tmp = repo();
        let root = tmp.path();

        write_prompt(root, 54, "prompt for session 54\n");
        merge_and_prune_session_branch(root, 54, "f54");

        // A well-formed 64-hex value that matches NO reconstructable diff — forged, stale, or
        // recycled from another session — must NOT count as ledger evidence (AC2). Before S86
        // this passed because the classifier only checked the LABEL was present.
        fs::write(
            root.join("sessions/session-54-review.md"),
            format!(
                "**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** {}\n",
                "a".repeat(64)
            ),
        )
        .unwrap();
        assert_eq!(outcome(root, 54, "Releaser"), Outcome::Absent);
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
    fn reviewer_absent_on_missing_reject_or_malformed_attestation() {
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

        // ACCEPT with a too-short/malformed value (not 64 hex chars) → ABSENT, same as missing —
        // this is the exact pre-S86 gap: a bare label match used to accept this as "attested".
        fs::write(
            root.join("sessions/session-60-review.md"),
            "## Verdict\n**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** abc123\n",
        )
        .unwrap();
        assert_eq!(outcome(root, 60, "Reviewer"), Outcome::Absent);

        // REJECT (even with a well-formed attestation) → ABSENT.
        fs::write(
            root.join("sessions/session-60-review.md"),
            format!(
                "## Verdict\n**Verdict:** REJECT\n\n**Review-Inputs-SHA:** {}\n",
                "b".repeat(64)
            ),
        )
        .unwrap();
        assert_eq!(outcome(root, 60, "Reviewer"), Outcome::Absent);
    }

    #[test]
    fn reviewer_passes_on_verified_hash_rejects_forged() {
        let tmp = repo();
        let root = tmp.path();
        let prompt = "prompt for session 90\n";
        write_prompt(root, 90, prompt);
        let (base, tip) = merge_and_prune_session_branch(root, 90, "f90");
        let real_hash =
            diff_hash(root, &base, &tip, prompt.as_bytes()).expect("diff hash computable");

        // Genuine, matching hash → PASSED (AC1).
        fs::write(
            root.join("sessions/session-90-review.md"),
            format!("**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** {real_hash}\n"),
        )
        .unwrap();
        assert_eq!(outcome(root, 90, "Reviewer"), Outcome::Passed);

        // Well-formed but WRONG (forged) → ABSENT (AC2) — the exact case that silently passed
        // before S86 (any 64 hex chars after the label satisfied the old `.contains()` check).
        let forged = "f".repeat(64);
        assert_ne!(forged, real_hash);
        fs::write(
            root.join("sessions/session-90-review.md"),
            format!("**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** {forged}\n"),
        )
        .unwrap();
        assert_eq!(outcome(root, 90, "Reviewer"), Outcome::Absent);
    }

    #[test]
    fn reviewer_absent_when_hash_recycled_from_another_session() {
        let tmp = repo();
        let root = tmp.path();

        let prompt91 = "prompt for session 91\n";
        write_prompt(root, 91, prompt91);
        let (base91, tip91) = merge_and_prune_session_branch(root, 91, "f91");
        let hash91 =
            diff_hash(root, &base91, &tip91, prompt91.as_bytes()).expect("hash computable");
        fs::write(
            root.join("sessions/session-91-review.md"),
            format!("**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** {hash91}\n"),
        )
        .unwrap();
        assert_eq!(outcome(root, 91, "Reviewer"), Outcome::Passed);

        // Recycle session 91's GENUINE hash into session 92's review. A different session has a
        // different prompt, hence a different preimage — the recycled hash must NOT verify here
        // (AC2's "recycled from another session" case, named explicitly in the prompt).
        write_prompt(root, 92, "prompt for session 92\n");
        merge_and_prune_session_branch(root, 92, "f92");
        fs::write(
            root.join("sessions/session-92-review.md"),
            format!("**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** {hash91}\n"),
        )
        .unwrap();
        assert_eq!(outcome(root, 92, "Reviewer"), Outcome::Absent);
    }

    #[test]
    fn reviewer_stays_verified_after_a_later_session_edits_the_same_prompt_file() {
        // Reproduces the S87→S76 live incident exactly: session 93 merges first with a genuine
        // attestation; a LATER session (94) legitimately edits session 93's own prompt file
        // (any reason — a typo fix, filling in a placeholder, S87's real case) and merges too.
        // Pre-S88, `attested_hash_outcome` re-hashed the LIVE (now-edited) prompt bytes against
        // every candidate, including 93's own — which could never match 93's ORIGINAL diff, so
        // an already-ACCEPTed review silently flipped Verified -> Unverifiable.
        let tmp = repo();
        let root = tmp.path();

        let original_prompt = "prompt for session 93 — original text\n";
        write_prompt(root, 93, original_prompt);
        let (base93, tip93) = merge_and_prune_session_branch(root, 93, "f93");
        let hash93 =
            diff_hash(root, &base93, &tip93, original_prompt.as_bytes()).expect("hash computable");
        fs::write(
            root.join("sessions/session-93-review.md"),
            format!("**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** {hash93}\n"),
        )
        .unwrap();
        assert_eq!(outcome(root, 93, "Reviewer"), Outcome::Passed);

        // Session 94 edits session 93's OWN prompt file, on its own branch, and merges.
        let edited_prompt = "prompt for session 93 — EDITED by a later session\n";
        git_in(root, &["checkout", "-qb", "session-94-x"]);
        write_prompt(root, 93, edited_prompt);
        git_in(root, &["add", "-A"]);
        git_in(root, &["commit", "-qm", "s94 edits s93's prompt"]);
        git_in(root, &["checkout", "-q", "main"]);
        git_in(
            root,
            &["merge", "-q", "--no-ff", "session-94-x", "-m", "merge 94"],
        );
        git_in(root, &["branch", "-D", "session-94-x"]);

        // Sanity: the live file really did change underneath session 93's review.
        assert_eq!(
            fs::read_to_string(root.join("prompts/93-task-fixture.md")).unwrap(),
            edited_prompt
        );

        // Session 93's attestation must be UNAFFECTED by session 94's later, unrelated edit —
        // the direct fix this session ships (AC1/AC4).
        assert_eq!(outcome(root, 93, "Reviewer"), Outcome::Passed);
        let review_text = fs::read_to_string(root.join("sessions/session-93-review.md")).unwrap();
        assert_eq!(
            attested_hash_outcome(root, 93, &review_text),
            AttestOutcome::Verified
        );
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
        let prompt_body = full_prompt(80, &sha);
        write_prompt(root, 80, &prompt_body);
        git_in(root, &["checkout", "-qb", "session-80-x"]);
        git_in(root, &["add", "-A"]);
        git_in(root, &["commit", "-qm", "s80 work"]);
        let tip = head_sha(root);
        git_in(root, &["checkout", "-q", "main"]);
        git_in(
            root,
            &["merge", "-q", "--no-ff", "session-80-x", "-m", "merge 80"],
        );
        git_in(root, &["branch", "-D", "session-80-x"]);

        // The placeholder "abc" attestation from the scaffold commit no longer counts (S86) — swap
        // in the REAL, verifiable hash so the ceiling stays 8/8 on a genuinely-evidenced fixture.
        let real_hash = diff_hash(root, &sha, &tip, prompt_body.as_bytes())
            .expect("diff hash computable in fixture");
        fs::write(
            root.join("sessions/session-80-review.md"),
            format!("**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** {real_hash}\n"),
        )
        .unwrap();

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

    // ---- S104 team voice ---------------------------------------------------------------------

    /// Single-source guarantee (AC2): every station the report emits has a `Role` narration, and
    /// every `Role` names a real station — so the roster can never fall back to a technical note.
    #[test]
    fn roles_cover_every_station() {
        let tmp = repo();
        let names: Vec<&str> = station_report(tmp.path(), 1)
            .stations
            .iter()
            .map(|s| s.name)
            .collect();
        for name in &names {
            assert!(
                role_of(name).is_some(),
                "station {name} has no Role narration"
            );
        }
        for r in ROLES.iter() {
            assert!(
                names.contains(&r.station),
                "Role {} names no real station",
                r.station
            );
        }
        assert_eq!(ROLES.len(), STATION_COUNT);
    }

    /// The roster reads like a team (AC1): a passed station shows its `done` phrase with a ✓, an
    /// absent one shows its `pending` phrase — plain English, never a bare `K-of-8`.
    #[test]
    fn roster_narrates_done_vs_pending_per_role() {
        let tmp = repo();
        let root = tmp.path();
        write_prompt(root, 10, &full_prompt(10, "deadbeef"));
        let r = station_report(root, 10);
        let roster = format_team_roster(&r);

        // Analyst passed on a substantive Delta → its plain `done` phrase, with the ✓ mark.
        assert_eq!(outcome(root, 10, "Analyst"), Outcome::Passed);
        assert!(roster.contains("✓ Analyst"), "roster: {roster}");
        assert!(roster.contains("framed what to build"), "roster: {roster}");

        // Coder has no execution trace against a real commit → its plain `pending` phrase.
        assert_eq!(outcome(root, 10, "Coder"), Outcome::Absent);
        assert!(roster.contains("no code committed yet"), "roster: {roster}");

        // Not a bare number: no `of 8` inside the roster body itself (that is the subtitle's job).
        assert!(
            !roster.contains("of 8"),
            "roster leaked the K-of-8 plumbing"
        );
    }

    /// AC3 — the reface changes only the SHOW, never the count: on a fresh 0/8 scaffold the roster
    /// headline and the `K of 8` subtitle report the SAME number `passed()` computes, and the
    /// auditable detail table survives beneath it. (The 0/8 and 8/8 values themselves stay pinned
    /// by the unchanged `placeholder_laden_prompt_counts_low` / `fully_filled_session_counts_high`.)
    #[test]
    fn reface_preserves_k_and_shows_it() {
        let tmp = repo();
        let root = tmp.path();

        // A fresh scaffold: passed() == 0, and the subtitle says "0 of 8".
        let scaffold = "\
# S70\n\ndesign-significant: yes\n\n## Acceptance\n1. do x\n\n## Design\n<why>\n\
\n## Plan\n1. <step>\n\n## Execution\n- step 1 — done: <sha>\n\n## Delta\n- `+` <adds>\n";
        write_prompt(root, 70, scaffold);
        let r = station_report(root, 70);
        assert_eq!(r.passed(), 0);
        let text = format_station_report(&r);
        assert!(
            text.contains("the pipeline team"),
            "no team headline: {text}"
        );
        assert!(
            text.contains(&format!(
                "{} of {} stations passed",
                r.passed(),
                STATION_COUNT
            )),
            "K subtitle drifted from passed(): {text}"
        );
        // The auditable detail table is still present beneath the roster (progressive disclosure).
        assert!(
            text.contains("[ABSENT]"),
            "auditable detail dropped: {text}"
        );
    }

    /// S99 (AC2), reproducing the S97 chitra reading: a prompt in the pre-marker convention
    /// (Goal/Context/Deliverables/Exit-Criteria/Guardrails) made all four prompt-driven stations
    /// report plain `[ABSENT]` — indistinguishable from a session that simply did no work. They
    /// must now report `LEGACY` with the cause and the remedy.
    #[test]
    fn legacy_convention_prompt_is_unmeasurable_not_absent() {
        let tmp = repo();
        let root = tmp.path();
        write_prompt(
            root,
            8,
            "# Session 08 — release workflow\n\n## Goal\nShip the release workflow.\n\n\
             ## Context\nchitra was scaffolded by an older vajra.\n\n\
             ## Deliverables\n- a workflow file\n\n## Exit Criteria\n- CI green\n\n\
             ## Guardrails\n- one story\n",
        );

        for station in ["Analyst", "Architect", "Planner", "Coder"] {
            assert_eq!(
                outcome(root, 8, station),
                Outcome::Legacy,
                "{station} must report LEGACY for a pre-marker-convention prompt"
            );
        }
        let r = station_report(root, 8);
        assert_eq!(r.legacy(), 4);
        assert_eq!(r.passed(), 0, "LEGACY must never earn a passed station");

        let text = format_station_report(&r);
        assert!(
            text.contains("[LEGACY]"),
            "surface hides the legacy outcome"
        );
        assert!(
            text.contains("UNMEASURABLE"),
            "surface hides the disclosure"
        );
        assert!(
            text.contains("vajra next --advance"),
            "surface states no remedy"
        );
    }

    /// The discriminator must not over-fire: a modern prompt that is merely EMPTY of work keeps
    /// reporting `ABSENT` — the convention is present, the work is not. One marker heading is
    /// enough to count as modern.
    #[test]
    fn half_filled_modern_prompt_stays_absent_not_legacy() {
        let tmp = repo();
        let root = tmp.path();
        write_prompt(
            root,
            9,
            "# Session 09 — fixture\n\n> **Status:** APPROVED\n\n## Goal\nDo a thing.\n\n\
             ## Delta\n- `+` <what this session ADDS that did not exist>\n",
        );
        for station in ["Analyst", "Architect", "Planner", "Coder"] {
            assert_eq!(
                outcome(root, 9, station),
                Outcome::Absent,
                "{station} mis-read a modern (if unfilled) prompt as legacy"
            );
        }
        assert_eq!(station_report(root, 9).legacy(), 0);
    }

    /// A missing prompt is NOT legacy — "no prompt" is already unambiguous, and calling it legacy
    /// would suggest a re-scaffold fixes a session that was never briefed.
    #[test]
    fn missing_prompt_is_absent_not_legacy() {
        let tmp = repo();
        assert!(!is_legacy_prompt(tmp.path(), 42));
        assert_eq!(outcome(tmp.path(), 42, "Coder"), Outcome::Absent);
    }

    /// Reproduces the S89 live incident: `--inputs-sha` was computed at an intermediate commit
    /// on the branch (before execution shas were added to the prompt file in a later closeout
    /// commit). Pre-fix, `candidate_diffs` only tried the branch tip — the intermediate hash
    /// never matched. Post-fix, every commit on the branch is tried; the intermediate one matches.
    #[test]
    fn reviewer_passes_when_hash_computed_at_intermediate_branch_commit() {
        let tmp = repo();
        let root = tmp.path();

        // Session 95 branch: two commits.
        // Commit 1 — the state when `--inputs-sha` was computed (prompt v1 + verify script).
        let prompt_v1 = "prompt for session 95 — v1 (state when --inputs-sha was run)\n";
        write_prompt(root, 95, prompt_v1);
        let base = head_sha(root);
        git_in(root, &["checkout", "-qb", "session-95-x"]);
        fs::write(
            root.join("scripts/verify-session-95.sh"),
            "#!/bin/sh\ntrue\n",
        )
        .unwrap();
        git_in(root, &["add", "-A"]);
        git_in(root, &["commit", "-qm", "s95 work"]);
        let intermediate = head_sha(root);

        // Hash computed HERE (at `intermediate`) — before the prompt was updated.
        let real_hash = diff_hash(root, &base, &intermediate, prompt_v1.as_bytes())
            .expect("diff hash computable at intermediate commit");

        // Commit 2 — the final closeout commit: add execution shas to the prompt (changes it!)
        // and embed the review (which already carries the hash from commit 1).
        let prompt_v2 = "prompt for session 95 — v2 (execution shas added in closeout)\n";
        write_prompt(root, 95, prompt_v2);
        fs::write(
            root.join("sessions/session-95-review.md"),
            format!("**Verdict:** ACCEPT\n\n**Review-Inputs-SHA:** {real_hash}\n"),
        )
        .unwrap();
        git_in(root, &["add", "-A"]);
        git_in(root, &["commit", "-qm", "s95 closeout: exec shas + review"]);

        // Merge + prune — now the branch ref is gone.
        git_in(root, &["checkout", "-q", "main"]);
        git_in(
            root,
            &["merge", "-q", "--no-ff", "session-95-x", "-m", "merge 95"],
        );
        git_in(root, &["branch", "-D", "session-95-x"]);

        // The tip's prompt is v2; hashing `(base, tip, prompt_v2)` must NOT match the review
        // (the pre-fix failure mode: tip-only candidate_diffs would call this Unverifiable).
        let tip_hash = diff_hash(root, &base, &head_sha(root), prompt_v2.as_bytes());
        assert!(
            tip_hash.map_or(true, |h| h != real_hash),
            "tip should NOT match the review hash"
        );

        // Post-fix: the intermediate commit IS tried → Verified.
        assert_eq!(
            outcome(root, 95, "Reviewer"),
            Outcome::Passed,
            "Reviewer must PASS when hash was computed at an intermediate branch commit"
        );
    }

    // ---- S113: fleet evidence beside K ---------------------------------------------------

    /// Write a role's handoff for `nn` at the canonical path, with the given file text.
    fn write_handoff(root: &Path, role: &str, nn: u32, text: &str) {
        let r = fleet::resolve_role(role).expect("known role");
        let rel = r.handoff_rel(nn);
        let path = root.join(&rel);
        fs::create_dir_all(path.parent().unwrap()).unwrap();
        fs::write(path, text).unwrap();
    }

    /// A contract-valid governed handoff, built by the SAME renderer the write path uses — so this
    /// fixture cannot drift away from the real artifact shape.
    fn valid_handoff(nn: u32) -> String {
        fleet::format_handoff(
            fleet::resolve_role("researcher").unwrap(),
            nn,
            "claude-opus-5",
            "a".repeat(64).as_str(),
            "2026-08-06T00:00:00Z",
            None,
            "- headless auth needs ANTHROPIC_API_KEY\n- interactive OAuth will not survive",
            "- `+` new handoff (first for this session)",
        )
    }

    #[test]
    fn fleet_evidence_absent_renders_nothing_and_leaves_k_untouched() {
        let tmp = repo();
        let root = tmp.path();
        write_prompt(root, 30, &full_prompt(30, "deadbeef"));

        let report = station_report(root, 30);
        assert!(report.fleet.is_empty(), "no handoff on disk → no evidence");
        assert_eq!(format_fleet_line(&report.fleet), "");
        let rendered = format_station_report(&report);
        assert!(
            !rendered.contains("fleet:"),
            "a session with no fleet work must render exactly as before S113:\n{rendered}"
        );
        // A LIVE counter, not a floor: this fixture passes real stations, so the sibling tests'
        // "K did not move" assertions compare against something that could have moved.
        // (Comparing the report to a second call on unchanged disk would be a tautology.)
        assert_eq!(
            report.passed(),
            3,
            "fixture must pass Analyst + Architect + Planner"
        );
    }

    #[test]
    fn fleet_evidence_reports_a_governed_handoff_beside_k_without_changing_k() {
        let tmp = repo();
        let root = tmp.path();
        write_prompt(root, 31, &full_prompt(31, "deadbeef"));
        let k_before = station_report(root, 31).passed();

        write_handoff(root, "researcher", 31, &valid_handoff(31));
        let report = station_report(root, 31);

        assert_eq!(report.fleet.governed, vec!["researcher".to_string()]);
        assert!(report.fleet.malformed.is_empty());
        // The load-bearing guarantee of design shape (c): K is IDENTICAL with and without fleet
        // work, so S74's K and S113's K mean the same thing.
        assert_eq!(
            report.passed(),
            k_before,
            "fleet evidence must not change K of 8"
        );

        let rendered = format_station_report(&report);
        assert!(rendered.contains("fleet: 1 governed handoff(s) — researcher"));
        assert!(
            rendered.contains("NOT counted in it"),
            "the line must say plainly that it is not part of K:\n{rendered}"
        );
        assert!(
            rendered.contains(&format!(
                "{} of {} stations passed",
                k_before, STATION_COUNT
            )),
            "the K line itself is untouched:\n{rendered}"
        );
    }

    #[test]
    fn fleet_evidence_names_a_malformed_handoff_and_never_counts_it() {
        let tmp = repo();
        let root = tmp.path();
        write_prompt(root, 32, &full_prompt(32, "deadbeef"));
        let k_before = station_report(root, 32).passed();

        // Everything the eye expects — frontmatter keys, a body — but no `## Handoff Delta`, so it
        // fails the DECISION-007 contract. A file that merely EXISTS is not fleet work done.
        let broken = "---\nrole: researcher\nsession: 32\nagent: x\nsource-sha: abc\n\
                      captured: 2026-08-06T00:00:00Z\ncost_usd: null\n---\n\nsome findings\n";
        write_handoff(root, "researcher", 32, broken);
        let report = station_report(root, 32);

        assert!(
            report.fleet.governed.is_empty(),
            "a malformed handoff must never count as governed fleet work"
        );
        assert_eq!(report.fleet.malformed.len(), 1);
        assert_eq!(report.passed(), k_before, "K of 8 is untouched either way");

        let rendered = format_station_report(&report);
        assert!(rendered.contains("does not satisfy the handoff contract"));
        assert!(rendered.contains("— not counted"));
        assert!(
            !rendered.contains("governed handoff(s)"),
            "a broken artifact must not render as a good one:\n{rendered}"
        );
    }
}
