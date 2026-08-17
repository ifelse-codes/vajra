//! The QA station — the pipeline's WORKS gate (S69), the 6th governed station.
//!
//! Vajra is a GOVERNED multi-agent SDLC pipeline (DECISION-001, S53). The Analyst (S54+S61+S62)
//! governs the **WHAT**; the Architect (S67) the **DESIGN**; the Planner (S64) the **HOW-plan**;
//! the Coder (S68) the **DID**; the Reviewer/ledger (S55–59) the **REVIEW**. Nothing governs
//! **WORKS**: "verification = exit 0" is a house rule — `scripts/verify-session-NN.sh` +
//! `.ai/verify/` artifacts exist by convention, but no gate checks a session's verify script
//! exists, ran, or passed at close. A session could close red and nothing would block.
//!
//! The contract is NOT a new artifact. Like the Analyst refusing a `spec.md` and the Coder an
//! `execution.md`, QA refuses a `qa.md`: `CONSTRAINTS.yaml#verify` already records the contract
//! (`script_pattern` + `artifacts_dir` + exit-0), and the scripts + `.ai/verify/` runs ARE the
//! store (memory `feedback-map-concepts-to-vajra`). No second store, no 8th command (rides
//! `vajra next`), no new dependency.
//!
//! The binary **surfaces + enforces, never authors** (the S54 anti-trap): it never writes or
//! fixes a test. One deliberate upgrade over the recorded-marker shape (Delta S61, `covers:`
//! S64, `design-significant:` S67, `done: <sha>` S68): the marker here is *executable*, so the
//! gate RE-RUNS it instead of trusting a recorded green —
//!
//! 1. `--qa NN` surfaces the recorded contract read-only: expected script, recorded runs, no
//!    execution.
//! 2. `--check-qa NN` re-runs the script LIVE and blocks on non-zero. A previously recorded
//!    green is never accepted as proof; the stale-green (S68's pre-session-sha analogue) is
//!    killed by construction. "A check that cannot evaluate FAILS" — an unrunnable script blocks.
//! 3. The gate binds on the session being **CLOSED** (the S62/S68 stance) — verification proves
//!    the session's own build.
//! 4. No script (NO-CODE ground-truth / legacy sessions) WARNS at most — and the warning names
//!    the dodge plainly: deleting the script downgrades the gate (the known
//!    self-granted-jurisdiction class, disclosed, S68). A green script only proves what its
//!    author chose to check. That honesty is stated, not hidden.

use std::fs;
use std::path::Path;

use crate::gate_run::CannotEvaluate;

/// `CONSTRAINTS.yaml#verify` defaults — the spine's recorded contract when the file or keys are
/// missing (the same patterns `vajra init` scaffolds).
const DEFAULT_SCRIPT_PATTERN: &str = "scripts/verify-session-{NN}.sh";
const DEFAULT_ARTIFACTS_DIR: &str = ".ai/verify/session-{NN}/";

/// The verify contract's spine patterns, read from `.ai/CONSTRAINTS.yaml#verify` (house-style
/// line scan — no YAML dependency). `demo:` records a `script_pattern:` too, so keys only count
/// inside the `verify:` section; missing file/keys fall back to the scaffold defaults.
pub fn verify_patterns(constraints_path: &Path) -> (String, String) {
    let content = fs::read_to_string(constraints_path).unwrap_or_default();
    let mut in_verify = false;
    let mut script = DEFAULT_SCRIPT_PATTERN.to_string();
    let mut artifacts = DEFAULT_ARTIFACTS_DIR.to_string();
    for line in content.lines() {
        if !line.starts_with([' ', '\t', '#']) && line.trim_end().ends_with(':') {
            in_verify = line.trim_end() == "verify:";
            continue;
        }
        if !in_verify {
            continue;
        }
        let t = line.trim();
        if let Some(v) = t.strip_prefix("script_pattern:") {
            script = unquote(v);
        } else if let Some(v) = t.strip_prefix("artifacts_dir:") {
            artifacts = unquote(v);
        }
    }
    (script, artifacts)
}

fn unquote(v: &str) -> String {
    v.trim().trim_matches(['\'', '"']).to_string()
}

/// Session NN's recorded QA contract, resolved from the spine patterns — the `--qa` surface.
/// Derived from the recorded contract (script path + `.ai/verify/` runs), never thin air.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct QaContract {
    pub session: u32,
    /// Expected verify script (repo-relative, from `verify.script_pattern`).
    pub script: String,
    pub script_exists: bool,
    /// Recorded-runs dir (repo-relative, from `verify.artifacts_dir`).
    pub artifacts_dir: String,
    /// Timestamped run dirs recorded under `artifacts_dir` (excluding `latest`).
    pub recorded_runs: usize,
    /// The `latest` symlink's target run, when recorded.
    pub latest_run: Option<String>,
}

/// Resolve session NN's QA contract from the spine (read-only — nothing executes here).
pub fn gather_contract(root: &Path, session: u32) -> QaContract {
    let (script_pattern, artifacts_pattern) = verify_patterns(&root.join(".ai/CONSTRAINTS.yaml"));
    let nn = format!("{session:02}");
    let script = script_pattern.replace("{NN}", &nn);
    let artifacts_dir = artifacts_pattern.replace("{NN}", &nn);

    let mut recorded_runs = 0;
    let mut latest_run = None;
    if let Ok(entries) = fs::read_dir(root.join(&artifacts_dir)) {
        for entry in entries.flatten() {
            if entry.file_name() == "latest" {
                latest_run = fs::read_link(entry.path())
                    .ok()
                    .map(|t| t.to_string_lossy().into_owned());
            } else if entry.path().is_dir() {
                recorded_runs += 1;
            }
        }
    }

    QaContract {
        session,
        script_exists: root.join(&script).is_file(),
        script,
        artifacts_dir,
        recorded_runs,
        latest_run,
    }
}

/// The QA verdict's classified state — live evidence, never a recorded green.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum QaState {
    /// No verify script recorded (NO-CODE ground-truth / legacy sessions). WARNS at most — and
    /// the dodge is named: deleting the script downgrades the gate.
    NoScript,
    /// The run could not be evaluated at all — BLOCKS, naming WHICH of the two reasons (S84):
    /// `Timeout` (ran past its bound, killed) or `SpawnFailure` (the process never started). A
    /// check that cannot evaluate FAILS.
    CannotEvaluate(CannotEvaluate),
    /// The script re-ran LIVE and exited a REAL non-zero code — BLOCKS. Never an `Option`: once a
    /// process has run to completion this always carries an actual exit code (see
    /// `gate_run::code_or_conservative` for the signal-death edge, which still lands here).
    LiveRed(i32),
    /// The script re-ran LIVE and exited 0 — passes. Only a live green passes.
    LiveGreen,
}

impl QaState {
    /// A blocking state refuses the close at L2/L3. Only a live green or a missing script
    /// (legacy WARN) does not block.
    pub fn blocks(&self) -> bool {
        matches!(self, QaState::LiveRed(_) | QaState::CannotEvaluate(_))
    }
}

/// Classify the contract by RE-RUNNING its script via `run` (injected so classification is
/// testable without spawning). `run` returns the live exit code, or `Err(CannotEvaluate)` naming
/// WHY the script could not be evaluated — which FAILS, never silently passes.
pub fn qa_report(
    contract: &QaContract,
    run: impl FnOnce(&str) -> Result<i32, CannotEvaluate>,
) -> QaState {
    if !contract.script_exists {
        return QaState::NoScript;
    }
    match run(&contract.script) {
        Ok(0) => QaState::LiveGreen,
        Ok(code) => QaState::LiveRed(code),
        Err(reason) => QaState::CannotEvaluate(reason),
    }
}

/// Re-run `script` (repo-relative) LIVE at `root`, streaming its output — the run IS the
/// evidence, shown as it happens. Returns the real exit code, or `Err(CannotEvaluate)` naming why
/// it cannot run. Delegates to the shared bounded runner (S73) with the scaffold-default timeout;
/// `qa_gate` passes the recorded bound. Kept as the thin production entry point + the
/// injection-free test seam.
pub fn run_verify_script(root: &Path, script: &str) -> Result<i32, CannotEvaluate> {
    crate::gate_run::run_streamed(
        root,
        script,
        std::time::Duration::from_secs(crate::gate_run::DEFAULT_TIMEOUT_SECS),
    )
}

/// The QA station's decision for CLOSING `session`. Mirrors the Coder's `ExecVerdict`.
#[derive(Debug, Clone)]
pub struct QaVerdict {
    pub session: u32,
    pub contract: QaContract,
    pub state: QaState,
    /// Blocking reasons — non-empty means L2/L3 must refuse the close.
    pub reasons: Vec<String>,
    /// Non-blocking nudges (no script recorded — the dodge named).
    pub warnings: Vec<String>,
}

impl QaVerdict {
    pub fn blocked(&self) -> bool {
        !self.reasons.is_empty()
    }
}

/// The QA gate (S69): CLOSING `session` requires its verify script to pass a LIVE re-run —
/// executes `run` and blocks on non-zero. A missing script (NO-CODE GT / legacy) WARNS at most,
/// the dodge named. Callers pass `run_verify_script` for the real thing; tests inject.
pub fn qa_gate_with(
    root: &Path,
    session: u32,
    run: impl FnOnce(&str) -> Result<i32, CannotEvaluate>,
) -> QaVerdict {
    let contract = gather_contract(root, session);
    let state = qa_report(&contract, run);
    let mut reasons = Vec::new();
    let mut warnings = Vec::new();

    match &state {
        QaState::LiveGreen => {}
        QaState::NoScript => warnings.push(format!(
            "no verify script recorded for session {:02} ({} missing) — NO-CODE ground-truth \
             and legacy sessions pass, but note the dodge: deleting the script downgrades this \
             gate to a warning (self-granted jurisdiction, disclosed)",
            session, contract.script
        )),
        QaState::LiveRed(code) => reasons.push(format!(
            "{} re-ran LIVE and exited {code} — a recorded green is not accepted as proof; \
             fix the verify until it passes live before closing",
            contract.script
        )),
        QaState::CannotEvaluate(CannotEvaluate::Timeout) => reasons.push(format!(
            "{} could not be evaluated — TIMEOUT: it ran past its recorded timeout bound and \
             was killed — a check that cannot evaluate FAILS",
            contract.script
        )),
        QaState::CannotEvaluate(CannotEvaluate::SpawnFailure) => reasons.push(format!(
            "{} could not be evaluated — SPAWN FAILURE: the process never started (missing \
             interpreter, permission denied, or a broken script path) — a check that cannot \
             evaluate FAILS",
            contract.script
        )),
    }

    QaVerdict {
        session,
        contract,
        state,
        reasons,
        warnings,
    }
}

/// The QA gate against the real repo — re-runs the session's verify script live, bounded by the
/// recorded `verify.timeout_secs` (S73). A run past the bound is killed → cannot-evaluate → BLOCK.
///
/// When `verify.clean_room.enabled: true` in CONSTRAINTS.yaml (default false), the script runs
/// inside a fresh `git worktree add --detach` checkout of HEAD — absent of uncommitted files and
/// gitignored artifacts by construction. `VAJRA_SKIP_CLEAN_ROOM=1` bypasses the clean room and
/// runs in the working tree (disclosed in output). A failed clean-room setup or bootstrap is a
/// CannotEvaluate → BLOCK regardless of script existence (S119).
pub fn qa_gate(root: &Path, session: u32) -> QaVerdict {
    let constraints = root.join(".ai/CONSTRAINTS.yaml");
    let timeout = crate::gate_run::gate_timeout(&constraints, "verify");
    let (cr_enabled, cr_bootstrap) = crate::gate_run::clean_room_config(&constraints);

    let skip = std::env::var("VAJRA_SKIP_CLEAN_ROOM").as_deref() == Ok("1");
    if !cr_enabled || skip {
        if cr_enabled && skip {
            eprintln!("[vajra: VAJRA_SKIP_CLEAN_ROOM=1 — skipping clean room, QA runs in working tree]");
        }
        return qa_gate_with(root, session, |script| {
            crate::gate_run::run_streamed(root, script, timeout)
        });
    }

    // Clean room is enabled — try to create it.
    let cr = match crate::gate_run::CleanRoom::new(root) {
        Ok(cr) => {
            eprintln!("[vajra: QA running in clean room: {}]", cr.path.display());
            cr
        }
        Err(reason) => {
            let contract = gather_contract(root, session);
            return QaVerdict {
                session,
                contract,
                state: QaState::CannotEvaluate(reason),
                reasons: vec![
                    "QA: could not create a clean checkout of HEAD — \
                     a check that cannot evaluate FAILS the close"
                        .to_string(),
                ],
                warnings: vec![],
            };
        }
    };

    // Run bootstrap if configured.
    if let Some(ref cmd) = cr_bootstrap {
        eprintln!("[vajra: QA clean-room bootstrap: {cmd}]");
        if let Err(reason) = crate::gate_run::run_bootstrap(&cr.path, cmd, timeout) {
            let contract = gather_contract(root, session);
            return QaVerdict {
                session,
                contract,
                state: QaState::CannotEvaluate(reason),
                reasons: vec![format!(
                    "QA: bootstrap failed in clean room ({cmd}) — \
                     a check that cannot evaluate FAILS the close"
                )],
                warnings: vec![],
            };
        }
    }

    let run_path = cr.path.clone();
    let verdict = qa_gate_with(root, session, |script| {
        crate::gate_run::run_streamed(&run_path, script, timeout)
    });
    drop(cr); // explicit cleanup before returning
    verdict
}

/// Render the `--qa N` surface: the session's recorded QA contract, read-only — script present
/// or not, recorded runs, latest. States the honest runtime cost plainly: `--check-qa` re-runs
/// the script live (cargo build/test — slow; that is the point — live evidence over stale-green).
pub fn format_qa_contract(contract: &QaContract) -> String {
    let mut s = format!(
        "=== qa: verify contract for session {:02} ===\n",
        contract.session
    );
    s.push_str(&format!(
        "script:    {} {}\n",
        contract.script,
        if contract.script_exists {
            "(exists)"
        } else {
            "(MISSING — NO-CODE GT / legacy sessions warn; deleting the script is the named dodge)"
        }
    ));
    s.push_str(&format!(
        "artifacts: {} ({} recorded run{}{})\n",
        contract.artifacts_dir,
        contract.recorded_runs,
        if contract.recorded_runs == 1 { "" } else { "s" },
        match &contract.latest_run {
            Some(l) => format!(", latest → {l}"),
            None => ", no latest".to_string(),
        }
    ));
    s.push_str(
        "recorded runs are surfaced, never trusted: `--check-qa` RE-RUNS the script live and \
         blocks on non-zero.\n(honest cost: the live run executes the session's verify — cargo \
         build/test — slow; that is the point.)\n",
    );
    s
}

#[cfg(test)]
mod tests {
    use super::*;

    const CONSTRAINTS: &str = "\
version: 3

maturity: L2

verify:
  required_for_done: true
  script_pattern: 'scripts/verify-session-{NN}.sh'
  artifacts_dir: '.ai/verify/session-{NN}/'
  exit_zero_required: true

demo:
  script_pattern: 'scripts/demo-session-{NN}.sh'
";

    fn repo_with_constraints(content: &str) -> tempfile::TempDir {
        let tmp = tempfile::tempdir().unwrap();
        fs::create_dir_all(tmp.path().join(".ai")).unwrap();
        fs::write(tmp.path().join(".ai/CONSTRAINTS.yaml"), content).unwrap();
        tmp
    }

    fn contract(script_exists: bool) -> QaContract {
        QaContract {
            session: 69,
            script: "scripts/verify-session-69.sh".to_string(),
            script_exists,
            artifacts_dir: ".ai/verify/session-69/".to_string(),
            recorded_runs: 0,
            latest_run: None,
        }
    }

    #[test]
    fn verify_patterns_reads_verify_section_not_demo() {
        // `demo:` also records a script_pattern — the verify section's must win.
        let demo_first = CONSTRAINTS.replace(
            "'scripts/verify-session-{NN}.sh'",
            "'scripts/custom-verify-{NN}.sh'",
        );
        let tmp = repo_with_constraints(&demo_first);
        let (script, artifacts) = verify_patterns(&tmp.path().join(".ai/CONSTRAINTS.yaml"));
        assert_eq!(script, "scripts/custom-verify-{NN}.sh");
        assert_eq!(artifacts, ".ai/verify/session-{NN}/");
    }

    #[test]
    fn verify_patterns_falls_back_on_missing_file_or_keys() {
        let (script, artifacts) = verify_patterns(Path::new("/nonexistent/CONSTRAINTS.yaml"));
        assert_eq!(script, DEFAULT_SCRIPT_PATTERN);
        assert_eq!(artifacts, DEFAULT_ARTIFACTS_DIR);
        let tmp = repo_with_constraints("version: 3\nmaturity: L2\n");
        let (script, _) = verify_patterns(&tmp.path().join(".ai/CONSTRAINTS.yaml"));
        assert_eq!(script, DEFAULT_SCRIPT_PATTERN);
    }

    #[test]
    fn gather_contract_resolves_script_and_recorded_runs() {
        let tmp = repo_with_constraints(CONSTRAINTS);
        let root = tmp.path();
        // Nothing recorded yet.
        let c = gather_contract(root, 69);
        assert_eq!(c.script, "scripts/verify-session-69.sh");
        assert!(!c.script_exists);
        assert_eq!((c.recorded_runs, &c.latest_run), (0, &None));

        // Script + two timestamped runs + latest symlink recorded.
        fs::create_dir_all(root.join("scripts")).unwrap();
        fs::write(root.join("scripts/verify-session-69.sh"), "exit 0\n").unwrap();
        let runs = root.join(".ai/verify/session-69");
        fs::create_dir_all(runs.join("20260716T010101Z")).unwrap();
        fs::create_dir_all(runs.join("20260716T020202Z")).unwrap();
        std::os::unix::fs::symlink("20260716T020202Z", runs.join("latest")).unwrap();
        let c = gather_contract(root, 69);
        assert!(c.script_exists);
        assert_eq!(c.recorded_runs, 2);
        assert_eq!(c.latest_run.as_deref(), Some("20260716T020202Z"));
    }

    #[test]
    fn qa_report_no_script_warns_never_runs() {
        // The runner must NOT even fire when the script is missing.
        let state = qa_report(&contract(false), |_| panic!("must not run"));
        assert_eq!(state, QaState::NoScript);
        assert!(!state.blocks());
    }

    #[test]
    fn qa_report_live_green_passes_live_red_blocks() {
        assert_eq!(qa_report(&contract(true), |_| Ok(0)), QaState::LiveGreen);
        assert!(!QaState::LiveGreen.blocks());
        let red = qa_report(&contract(true), |_| Ok(2));
        assert_eq!(red, QaState::LiveRed(2));
        assert!(red.blocks());
    }

    #[test]
    fn qa_report_unevaluable_run_fails_never_silently_passes() {
        // "A check that cannot evaluate FAILS" (AGENTS.md) — neither reason is a pass, and the
        // two reasons must stay visibly distinct (S84 — the S73 fakest-green finding).
        let timeout = qa_report(&contract(true), |_| Err(CannotEvaluate::Timeout));
        assert_eq!(timeout, QaState::CannotEvaluate(CannotEvaluate::Timeout));
        assert!(timeout.blocks());

        let spawn = qa_report(&contract(true), |_| Err(CannotEvaluate::SpawnFailure));
        assert_eq!(spawn, QaState::CannotEvaluate(CannotEvaluate::SpawnFailure));
        assert!(spawn.blocks());

        assert_ne!(
            timeout, spawn,
            "timeout and spawn-failure must not collapse into the same state"
        );
    }

    #[test]
    fn run_verify_script_returns_the_real_exit_code() {
        let tmp = repo_with_constraints(CONSTRAINTS);
        let root = tmp.path();
        fs::create_dir_all(root.join("scripts")).unwrap();
        fs::write(root.join("scripts/green.sh"), "exit 0\n").unwrap();
        fs::write(root.join("scripts/red.sh"), "exit 3\n").unwrap();
        assert_eq!(run_verify_script(root, "scripts/green.sh"), Ok(0));
        assert_eq!(run_verify_script(root, "scripts/red.sh"), Ok(3));
    }

    #[test]
    fn gate_blocks_live_red_passes_live_green_warns_missing() {
        let tmp = repo_with_constraints(CONSTRAINTS);
        let root = tmp.path();

        // Missing script → WARN, and the warning names the dodge.
        let v = qa_gate_with(root, 69, |_| panic!("must not run"));
        assert!(!v.blocked());
        assert!(v.warnings.iter().any(|w| w.contains("deleting the script")));

        // Script present + live red → BLOCK, naming the live exit code.
        fs::create_dir_all(root.join("scripts")).unwrap();
        fs::write(root.join("scripts/verify-session-69.sh"), "exit 3\n").unwrap();
        let v = qa_gate(root, 69);
        assert!(v.blocked());
        assert!(v.reasons.iter().any(|r| r.contains("exited 3")));
        assert!(v.reasons.iter().any(|r| r.contains("recorded green")));

        // Live green → PASS, no warnings.
        fs::write(root.join("scripts/verify-session-69.sh"), "exit 0\n").unwrap();
        let v = qa_gate(root, 69);
        assert!(!v.blocked(), "reasons: {:?}", v.reasons);
        assert_eq!(v.state, QaState::LiveGreen);
        assert!(v.warnings.is_empty());
    }

    #[test]
    fn gate_block_message_names_timeout_distinctly_from_spawn_failure() {
        // The S73/S84 headline: an operator reading a blocked close must be able to tell WHICH of
        // the two cannot-evaluate reasons occurred, not one generic "no exit code" message.
        let tmp = repo_with_constraints(CONSTRAINTS);
        let root = tmp.path();
        fs::create_dir_all(root.join("scripts")).unwrap();
        fs::write(root.join("scripts/verify-session-69.sh"), "exit 0\n").unwrap();

        let timed_out = qa_gate_with(root, 69, |_| Err(CannotEvaluate::Timeout));
        assert!(timed_out.blocked());
        assert!(timed_out.reasons.iter().any(|r| r.contains("TIMEOUT")));
        assert!(!timed_out
            .reasons
            .iter()
            .any(|r| r.contains("SPAWN FAILURE")));

        let unspawnable = qa_gate_with(root, 69, |_| Err(CannotEvaluate::SpawnFailure));
        assert!(unspawnable.blocked());
        assert!(unspawnable
            .reasons
            .iter()
            .any(|r| r.contains("SPAWN FAILURE")));
        assert!(!unspawnable.reasons.iter().any(|r| r.contains("TIMEOUT")));

        assert_ne!(timed_out.reasons, unspawnable.reasons);
    }

    #[test]
    fn surface_shows_contract_and_names_the_live_run_cost() {
        let tmp = repo_with_constraints(CONSTRAINTS);
        let out = format_qa_contract(&gather_contract(tmp.path(), 69));
        assert!(out.contains("scripts/verify-session-69.sh"));
        assert!(out.contains("MISSING"));
        assert!(out.contains("RE-RUNS the script live"));
        assert!(out.contains("honest cost"), "got:\n{out}");
    }
}
