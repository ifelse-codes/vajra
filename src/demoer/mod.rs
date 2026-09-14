//! The Demo-er station — the pipeline's SHOW gate (S71), the 7th governed station.
//!
//! Vajra is a GOVERNED multi-agent SDLC pipeline (DECISION-001, S53). The Analyst (S54+S61+S62)
//! governs the **WHAT**; the Architect (S67) the **DESIGN**; the Planner (S64) the **HOW-plan**;
//! the Coder (S68) the **DID**; QA (S69) the **WORKS**; the Reviewer/ledger (S55–59) the
//! **REVIEW**. Nothing governs **SHOW**: the sprint demo — "seeing it, the user knows what this
//! session delivered, and the before-and-after" (the founder's S70 contract) — is a house rule
//! (`CONSTRAINTS.yaml#demo` records `script_pattern` + `cumulative` + `required_elements`), but
//! no gate checks a session's demo exists, runs, or shows anything at close.
//!
//! The contract is NOT a new artifact. Like QA refusing a `qa.md`, the Demo-er refuses a
//! `demo.md`: `CONSTRAINTS.yaml#demo` already records the contract and the demo scripts ARE the
//! store (memory `feedback-map-concepts-to-vajra`). No second store, no 8th command (rides
//! `vajra next`), no new dependency. The binary **surfaces + enforces, never authors** a demo —
//! and never renders one. S167 (DECISION-009): the terminal demo IS the human demo — the same
//! script this gate re-runs plays as a slide deck in a terminal, drawn by the scaffolded
//! `scripts/demo-kit.sh`; `demo.presentation: interactive_html` (a separate agent-made HTML deck)
//! is retired. S168 (DECISION-010, overturning DECISION-009 §4): a demo BUILT ON THE KIT must
//! also print `demo:complete` and every `demo:fact`, each equal to what `facts::demo_facts` derives
//! right after the re-run — a typed PASS, a typed number, or a demo that never finished blocks.
//!
//! The marker here is *executable* (a demo script), so per the S69 house pattern the gate
//! RE-RUNS it instead of trusting a recorded green:
//!
//! 1. `--demo NN` surfaces the recorded contract read-only: expected script, required elements
//!    found/missing in the script text, no execution.
//! 2. `--check-demo NN` re-runs the script LIVE and blocks on a non-zero exit OR on required
//!    elements missing from the LIVE output — a hollow demo (`exit 0`, nothing shown) fails the
//!    element scan by construction. "A check that cannot evaluate FAILS" — an unrunnable or
//!    signal-killed script blocks, never passes.
//! 3. The gate binds on the session being **CLOSED** (the S62/S68/S69 stance) — the demo shows
//!    what THIS session delivered, before → after.
//! 4. No script (NO-CODE ground-truth / legacy sessions) WARNS at most — and the warning names
//!    the dodge plainly: deleting the script downgrades the gate (the known
//!    self-granted-jurisdiction class, disclosed, S68/S69).
//!
//! Honest floor, stated not hidden: an element is a *recorded marker* the demo emits
//! (`demo:<element>`), the same class as the Planner's `covers: N` digit-tag — the scan proves
//! the author's demo PRINTS header · cases · summary_table · before_after, not that what it
//! prints demonstrates anything. Never pitch this as "the demo is verified."

use std::fs;
use std::path::Path;

use crate::gate_run::CannotEvaluate;

pub mod facts;

/// `CONSTRAINTS.yaml#demo` defaults — the spine's recorded contract when the file or keys are
/// missing (the same patterns `vajra init` scaffolds).
const DEFAULT_SCRIPT_PATTERN: &str = "scripts/demo-session-{NN}.sh";
const DEFAULT_REQUIRED_ELEMENTS: &[&str] = &["header", "cases", "summary_table", "before_after"];

/// The demo contract's spine, read from `.ai/CONSTRAINTS.yaml#demo` (house-style line scan — no
/// YAML dependency). `verify:` records a `script_pattern:` too, so keys only count inside the
/// `demo:` section; a missing file/key falls back to the scaffold defaults, but a RECORDED
/// `required_elements` list wins (a pre-S71 scaffold's 3-element contract stays honored).
pub fn demo_patterns(constraints_path: &Path) -> (String, Vec<String>) {
    let content = fs::read_to_string(constraints_path).unwrap_or_default();
    let mut in_demo = false;
    let mut script = DEFAULT_SCRIPT_PATTERN.to_string();
    let mut elements: Vec<String> = DEFAULT_REQUIRED_ELEMENTS
        .iter()
        .map(|s| s.to_string())
        .collect();
    for line in content.lines() {
        if !line.starts_with([' ', '\t', '#']) && line.trim_end().ends_with(':') {
            in_demo = line.trim_end() == "demo:";
            continue;
        }
        if !in_demo {
            continue;
        }
        let t = line.trim();
        if let Some(v) = t.strip_prefix("script_pattern:") {
            script = unquote(v);
        } else if let Some(v) = t.strip_prefix("required_elements:") {
            let recorded: Vec<String> = v
                .trim()
                .trim_start_matches('[')
                .trim_end_matches(']')
                .split(',')
                .map(unquote)
                .filter(|e| !e.is_empty())
                .collect();
            if !recorded.is_empty() {
                elements = recorded;
            }
        }
    }
    (script, elements)
}

fn unquote(v: &str) -> String {
    v.trim().trim_matches(['\'', '"']).to_string()
}

/// Session NN's recorded demo contract, resolved from the spine — the `--demo` surface.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct DemoContract {
    pub session: u32,
    /// Expected demo script (repo-relative, from `demo.script_pattern`).
    pub script: String,
    pub script_exists: bool,
    /// Required elements, from `demo.required_elements`.
    pub required_elements: Vec<String>,
    /// Elements whose `demo:<element>` marker the script TEXT lacks (static scan; every element
    /// when the script is missing). The live output scan in `--check-demo` is the enforced one.
    pub missing_in_file: Vec<String>,
    /// The script text names `demo-kit.sh` (S168, DECISION-010) — one of the signs that the demo is
    /// built on the kit, so the gate also requires `demo:complete` and true facts.
    pub sources_kit: bool,
}

/// Is this demo built on the kit (S168, DECISION-010)? Any ONE sign is enough — the script text
/// names `demo-kit.sh`, or the live output carries a `demo:kit`, `demo:complete` or `demo:fact`
/// line — so a faker must remove every sign to fall back to the old four-marker rule (warned).
pub fn is_kit_built(sources_kit: bool, output: &str) -> bool {
    sources_kit
        || facts::strip_ansi(output).lines().any(|l| {
            let t = l.trim();
            t == "demo:kit" || t == "demo:complete" || t.starts_with("demo:fact ")
        })
}

/// Elements from `required` whose `demo:<element>` marker `text` does not contain.
pub fn missing_elements(text: &str, required: &[String]) -> Vec<String> {
    required
        .iter()
        .filter(|e| !text.contains(&format!("demo:{e}")))
        .cloned()
        .collect()
}

/// Resolve session NN's demo contract from the spine (read-only — nothing executes here).
/// Existence is `is_file()`, NOT readability: an unreadable script still EXISTS, so the gate
/// re-runs it and blocks on the failure — `chmod 000` must not turn a BLOCK into the no-script
/// WARN (that would extend the deletion dodge to a permission dodge). Unreadable text degrades
/// to every element missing-in-file; the live run is the enforced scan anyway.
pub fn gather_contract(root: &Path, session: u32) -> DemoContract {
    let (script_pattern, required_elements) = demo_patterns(&root.join(".ai/CONSTRAINTS.yaml"));
    let script = script_pattern.replace("{NN}", &format!("{session:02}"));
    let path = root.join(&script);
    let (missing_in_file, sources_kit) = match fs::read_to_string(&path) {
        Ok(text) => (
            missing_elements(&text, &required_elements),
            text.contains("demo-kit.sh"),
        ),
        Err(_) => (required_elements.clone(), false),
    };
    DemoContract {
        session,
        script_exists: path.is_file(),
        script,
        required_elements,
        missing_in_file,
        sources_kit,
    }
}

/// The Demo-er verdict's classified state — live evidence, never a recorded green.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum DemoState {
    /// No demo script recorded (NO-CODE ground-truth / legacy sessions). WARNS at most — and
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
    /// The script re-ran LIVE and exited 0 but its OUTPUT lacks these required elements —
    /// BLOCKS. The hollow demo (exit 0, nothing shown) dies here, by construction.
    MissingElements(Vec<String>),
    /// The script re-ran LIVE, exited 0, and its output carries every required element — and, for a
    /// demo built on the kit, `demo:complete` plus every fact, each equal to what Vajra derives.
    LiveGreen,
    /// Exit 0 with every required element, but NOT built on the kit: the old four-marker rule
    /// applied, with no `demo:complete` or fact check. Passes with a warning naming the downgrade.
    LegacyGreen,
    /// Built on the kit, exit 0, every element shown — but `demo:complete` is missing or a
    /// `demo:fact` is typed, stale, unknown or absent (S168). BLOCKS, naming each reason.
    KitUnproven(Vec<String>),
}

impl DemoState {
    /// A blocking state refuses the close at L2/L3. Only a live green, a legacy green (warned) or
    /// a missing script (legacy WARN) does not block.
    pub fn blocks(&self) -> bool {
        matches!(
            self,
            DemoState::LiveRed(_)
                | DemoState::MissingElements(_)
                | DemoState::CannotEvaluate(_)
                | DemoState::KitUnproven(_)
        )
    }
}

/// Classify the contract by RE-RUNNING its script via `run` (injected so classification is
/// testable without spawning). `run` returns the live exit code + captured output, or
/// `Err(CannotEvaluate)` naming WHY the run could not be evaluated — which FAILS, never silently
/// passes.
pub fn demo_report(
    contract: &DemoContract,
    run: impl FnOnce(&str) -> (Result<i32, CannotEvaluate>, String),
) -> DemoState {
    demo_report_with(contract, run, |_| Vec::new())
}

/// `demo_report` with the facts source injected (S168): `derive(NN)` returns session NN's facts as
/// Vajra derives them RIGHT AFTER the run, from the folder the demo ran in.
pub fn demo_report_with(
    contract: &DemoContract,
    run: impl FnOnce(&str) -> (Result<i32, CannotEvaluate>, String),
    derive: impl Fn(u32) -> Vec<(String, String)>,
) -> DemoState {
    if !contract.script_exists {
        return DemoState::NoScript;
    }
    let (code, output) = run(&contract.script);
    match code {
        Ok(0) => {
            let missing = missing_elements(&output, &contract.required_elements);
            if !missing.is_empty() {
                return DemoState::MissingElements(missing);
            }
            if !is_kit_built(contract.sources_kit, &output) {
                return DemoState::LegacyGreen;
            }
            let mut reasons = Vec::new();
            if !facts::strip_ansi(&output)
                .lines()
                .any(|l| l.trim() == "demo:complete")
            {
                reasons.push(
                    "never printed `demo:complete` — it did not reach a passing dk_finish (a \
                     section unfilled, a live check failed or refused, or dk_finish never called)"
                        .to_string(),
                );
            }
            reasons.extend(facts::check_facts(
                &facts::fact_lines(&output),
                contract.session,
                derive,
            ));
            if reasons.is_empty() {
                DemoState::LiveGreen
            } else {
                DemoState::KitUnproven(reasons)
            }
        }
        Ok(c) => DemoState::LiveRed(c),
        Err(reason) => DemoState::CannotEvaluate(reason),
    }
}

/// Re-run `script` (repo-relative) LIVE at `root`, capturing its output for the element scan and
/// echoing it so the demo is still SEEN — the run is the evidence, shown and scanned. Returns
/// the real exit code, or `Err(CannotEvaluate)` naming why it cannot run, + the combined
/// stdout/stderr text.
pub fn run_demo_script(root: &Path, script: &str) -> (Result<i32, CannotEvaluate>, String) {
    crate::gate_run::run_captured(
        root,
        script,
        std::time::Duration::from_secs(crate::gate_run::DEFAULT_TIMEOUT_SECS),
    )
}

/// The Demo-er station's decision for CLOSING `session`. Mirrors QA's `QaVerdict`.
#[derive(Debug, Clone)]
pub struct DemoVerdict {
    pub session: u32,
    pub contract: DemoContract,
    pub state: DemoState,
    /// Blocking reasons — non-empty means L2/L3 must refuse the close.
    pub reasons: Vec<String>,
    /// Non-blocking nudges (no script recorded — the dodge named).
    pub warnings: Vec<String>,
}

impl DemoVerdict {
    pub fn blocked(&self) -> bool {
        !self.reasons.is_empty()
    }
}

/// The Demo-er gate (S71): CLOSING `session` requires its demo script to pass a LIVE re-run AND
/// show every required element in that live output. A missing script (NO-CODE GT / legacy)
/// WARNS at most, the dodge named. Callers pass `run_demo_script` for the real thing; tests
/// inject.
pub fn demo_gate_with(
    root: &Path,
    session: u32,
    run: impl FnOnce(&str) -> (Result<i32, CannotEvaluate>, String),
) -> DemoVerdict {
    demo_gate_with_facts(root, session, run, |s| facts::demo_facts(root, s))
}

/// `demo_gate_with` with the facts source injected (S168) — `derive` must read the folder the demo
/// ran in (the clean room when enabled), so the demo and the gate see the same files.
pub fn demo_gate_with_facts(
    root: &Path,
    session: u32,
    run: impl FnOnce(&str) -> (Result<i32, CannotEvaluate>, String),
    derive: impl Fn(u32) -> Vec<(String, String)>,
) -> DemoVerdict {
    let contract = gather_contract(root, session);
    let state = demo_report_with(&contract, run, derive);
    let mut reasons = Vec::new();
    let mut warnings = Vec::new();

    match &state {
        DemoState::LiveGreen => {}
        DemoState::LegacyGreen => warnings.push(format!(
            "{} is not built on scripts/demo-kit.sh — the old four-marker rule applied: no \
             `demo:complete` check and no fact check (a downgrade, named: a demo that drops every \
             kit sign dodges both; add `complete` to CONSTRAINTS.yaml#demo.required_elements to \
             close it)",
            contract.script
        )),
        DemoState::KitUnproven(why) => {
            for w in why {
                reasons.push(format!(
                    "{} is built on the demo kit but {w}",
                    contract.script
                ));
            }
        }
        DemoState::NoScript => warnings.push(format!(
            "no demo script recorded for session {:02} ({} missing) — NO-CODE ground-truth \
             and legacy sessions pass, but note the dodge: deleting the script downgrades this \
             gate to a warning (self-granted jurisdiction, disclosed)",
            session, contract.script
        )),
        DemoState::MissingElements(missing) => reasons.push(format!(
            "{} ran live (exit 0) but its output shows no {} — a sprint demo must SHOW its \
             required elements ({}), each as an emitted `demo:<element>` marker; a hollow exit-0 \
             demo does not pass the element scan",
            contract.script,
            missing.join(", "),
            contract.required_elements.join(" · ")
        )),
        DemoState::LiveRed(code) => reasons.push(format!(
            "{} re-ran LIVE and exited {code} — a recorded green is not accepted as proof; \
             fix the demo until it runs green live before closing",
            contract.script
        )),
        DemoState::CannotEvaluate(CannotEvaluate::Timeout) => reasons.push(format!(
            "{} could not be evaluated — TIMEOUT: it ran past its recorded timeout bound and \
             was killed — a check that cannot evaluate FAILS",
            contract.script
        )),
        DemoState::CannotEvaluate(CannotEvaluate::SpawnFailure) => reasons.push(format!(
            "{} could not be evaluated — SPAWN FAILURE: the process never started (missing \
             interpreter, permission denied, or a broken script path) — a check that cannot \
             evaluate FAILS",
            contract.script
        )),
    }

    DemoVerdict {
        session,
        contract,
        state,
        reasons,
        warnings,
    }
}

/// The Demo-er gate against the real repo — re-runs the session's demo script live.
///
/// Follows the same clean-room routing as `qa_gate` (S119): when `verify.clean_room.enabled:
/// true`, the demo script runs inside a fresh checkout of HEAD — absent of uncommitted files and
/// gitignored artifacts. `VAJRA_SKIP_CLEAN_ROOM=1` bypasses the clean room (disclosed in output).
/// A failed setup or bootstrap is CannotEvaluate → BLOCK.
pub fn demo_gate(root: &Path, session: u32) -> DemoVerdict {
    let constraints = root.join(".ai/CONSTRAINTS.yaml");
    let timeout = crate::gate_run::gate_timeout(&constraints, "demo");
    let (cr_enabled, cr_bootstrap) = crate::gate_run::clean_room_config(&constraints);

    // S168: a kit demo reads its facts from THIS binary, so the demo and the comparison cannot skew.
    let envs: Vec<(&str, std::ffi::OsString)> = std::env::current_exe()
        .map(|p| vec![("VAJRA_BIN", p.into_os_string())])
        .unwrap_or_default();

    let skip = std::env::var("VAJRA_SKIP_CLEAN_ROOM").as_deref() == Ok("1");
    if !cr_enabled || skip {
        if cr_enabled && skip {
            eprintln!("[vajra: VAJRA_SKIP_CLEAN_ROOM=1 — skipping clean room, Demo-er runs in working tree]");
        }
        return demo_gate_with_facts(
            root,
            session,
            |script| crate::gate_run::run_captured_env(root, script, timeout, &envs),
            |s| facts::demo_facts(root, s),
        );
    }

    // Clean room is enabled — try to create it.
    let cr = match crate::gate_run::CleanRoom::new(root) {
        Ok(cr) => {
            eprintln!(
                "[vajra: Demo-er running in clean room: {}]",
                cr.path.display()
            );
            cr
        }
        Err(reason) => {
            let contract = gather_contract(root, session);
            return DemoVerdict {
                session,
                contract,
                state: DemoState::CannotEvaluate(reason),
                reasons: vec!["Demo-er: could not create a clean checkout of HEAD — \
                     a check that cannot evaluate FAILS the close"
                    .to_string()],
                warnings: vec![],
            };
        }
    };

    // Run bootstrap if configured.
    if let Some(ref cmd) = cr_bootstrap {
        eprintln!("[vajra: Demo-er clean-room bootstrap: {cmd}]");
        if let Err(reason) = crate::gate_run::run_bootstrap(&cr.path, cmd, timeout) {
            let contract = gather_contract(root, session);
            return DemoVerdict {
                session,
                contract,
                state: DemoState::CannotEvaluate(reason),
                reasons: vec![format!(
                    "Demo-er: bootstrap failed in clean room ({cmd}) — \
                     a check that cannot evaluate FAILS the close"
                )],
                warnings: vec![],
            };
        }
    }

    let run_path = cr.path.clone();
    let verdict = demo_gate_with_facts(
        root,
        session,
        |script| crate::gate_run::run_captured_env(&run_path, script, timeout, &envs),
        |s| facts::demo_facts(&run_path, s),
    );
    drop(cr); // explicit cleanup before returning
    verdict
}

/// Render the `--demo N` surface: the session's recorded sprint-demo contract, read-only —
/// script present or not, required elements found/missing in the script text. States the honest
/// runtime cost plainly: `--check-demo` re-runs the demo live (real seconds — the point: live
/// evidence over stale-green), and the skip env skips that run itself, disclosed.
pub fn format_demo_contract(contract: &DemoContract) -> String {
    let mut s = format!(
        "=== demoer: sprint-demo contract for session {:02} ===\n",
        contract.session
    );
    s.push_str(&format!(
        "script:   {} {}\n",
        contract.script,
        if contract.script_exists {
            "(exists)"
        } else {
            "(MISSING — NO-CODE GT / legacy sessions warn; deleting the script is the named dodge)"
        }
    ));
    s.push_str("elements (required, from CONSTRAINTS.yaml#demo — before → after is the sprint-demo core):\n");
    for e in &contract.required_elements {
        if contract.missing_in_file.contains(e) {
            s.push_str(&format!(
                "  ✗ {e} (no `demo:{e}` marker in the script text)\n"
            ));
        } else {
            s.push_str(&format!("  ✓ {e}\n"));
        }
    }
    s.push_str(
        "surfaced read-only — nothing executed here: `--check-demo` RE-RUNS the demo live and \
         blocks on a non-zero exit or on elements missing from the LIVE output (a hollow exit-0 \
         demo fails the scan).\n(honest cost: the live run costs real seconds — that is the \
         point; VAJRA_SKIP_DEMOER_GATE=1 skips the run itself, disclosed.)\n",
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

demo:
  script_pattern: 'scripts/demo-session-{NN}.sh'
  template: 'scripts/demo-session-template.sh'
  cumulative: true
  required_elements: [header, cases, summary_table, before_after]
  presentation: terminal_deck
";

    fn repo_with_constraints(content: &str) -> tempfile::TempDir {
        let tmp = tempfile::tempdir().unwrap();
        fs::create_dir_all(tmp.path().join(".ai")).unwrap();
        fs::write(tmp.path().join(".ai/CONSTRAINTS.yaml"), content).unwrap();
        tmp
    }

    fn elements(names: &[&str]) -> Vec<String> {
        names.iter().map(|s| s.to_string()).collect()
    }

    fn contract(script_exists: bool) -> DemoContract {
        DemoContract {
            session: 71,
            script: "scripts/demo-session-71.sh".to_string(),
            script_exists,
            required_elements: elements(&["header", "cases", "summary_table", "before_after"]),
            missing_in_file: Vec::new(),
            sources_kit: false,
        }
    }

    const FULL_OUTPUT: &str =
        "demo:header S71\ndemo:cases 3 cases\ndemo:summary_table\ndemo:before_after old vs new\n";

    #[test]
    fn demo_patterns_reads_demo_section_not_verify() {
        // `verify:` records a script_pattern too — the demo section's must win.
        let tmp = repo_with_constraints(&CONSTRAINTS.replace(
            "'scripts/demo-session-{NN}.sh'",
            "'scripts/custom-demo-{NN}.sh'",
        ));
        let (script, els) = demo_patterns(&tmp.path().join(".ai/CONSTRAINTS.yaml"));
        assert_eq!(script, "scripts/custom-demo-{NN}.sh");
        assert_eq!(
            els,
            elements(&["header", "cases", "summary_table", "before_after"])
        );
    }

    #[test]
    fn demo_patterns_honors_a_recorded_shorter_element_list() {
        // A pre-S71 scaffold records 3 elements — the RECORDED contract wins over the default.
        let tmp = repo_with_constraints(
            "demo:\n  script_pattern: 'scripts/demo-session-{NN}.sh'\n  required_elements: [header, cases, summary_table]\n",
        );
        let (_, els) = demo_patterns(&tmp.path().join(".ai/CONSTRAINTS.yaml"));
        assert_eq!(els, elements(&["header", "cases", "summary_table"]));
    }

    #[test]
    fn demo_patterns_falls_back_on_missing_file_or_keys() {
        let (script, els) = demo_patterns(Path::new("/nonexistent/CONSTRAINTS.yaml"));
        assert_eq!(script, DEFAULT_SCRIPT_PATTERN);
        assert_eq!(
            els,
            elements(&["header", "cases", "summary_table", "before_after"])
        );
        let tmp = repo_with_constraints("version: 3\nmaturity: L2\n");
        let (script, _) = demo_patterns(&tmp.path().join(".ai/CONSTRAINTS.yaml"));
        assert_eq!(script, DEFAULT_SCRIPT_PATTERN);
    }

    #[test]
    fn gather_contract_scans_the_script_text_statically() {
        let tmp = repo_with_constraints(CONSTRAINTS);
        let root = tmp.path();
        // Missing script → every element missing, nothing to scan.
        let c = gather_contract(root, 71);
        assert!(!c.script_exists);
        assert_eq!(c.missing_in_file, c.required_elements);

        // Script carrying 2 of 4 markers → the other 2 reported missing (static, no execution).
        fs::create_dir_all(root.join("scripts")).unwrap();
        fs::write(
            root.join("scripts/demo-session-71.sh"),
            "echo 'demo:header'\necho 'demo:cases'\n",
        )
        .unwrap();
        let c = gather_contract(root, 71);
        assert!(c.script_exists);
        assert_eq!(
            c.missing_in_file,
            elements(&["summary_table", "before_after"])
        );
    }

    #[test]
    fn demo_report_no_script_warns_never_runs() {
        // The runner must NOT even fire when the script is missing.
        let state = demo_report(&contract(false), |_| panic!("must not run"));
        assert_eq!(state, DemoState::NoScript);
        assert!(!state.blocks());
    }

    #[test]
    fn demo_report_live_red_blocks_and_unevaluable_fails() {
        let red = demo_report(&contract(true), |_| (Ok(3), String::new()));
        assert_eq!(red, DemoState::LiveRed(3));
        assert!(red.blocks());
        // "A check that cannot evaluate FAILS" — neither reason is a pass, and the two reasons
        // must stay visibly distinct (S84 — the S73 fakest-green finding).
        let timeout = demo_report(&contract(true), |_| {
            (Err(CannotEvaluate::Timeout), String::new())
        });
        assert_eq!(timeout, DemoState::CannotEvaluate(CannotEvaluate::Timeout));
        assert!(timeout.blocks());
        let spawn = demo_report(&contract(true), |_| {
            (Err(CannotEvaluate::SpawnFailure), String::new())
        });
        assert_eq!(
            spawn,
            DemoState::CannotEvaluate(CannotEvaluate::SpawnFailure)
        );
        assert!(spawn.blocks());
        assert_ne!(
            timeout, spawn,
            "timeout and spawn-failure must not collapse into the same state"
        );
    }

    #[test]
    fn demo_report_hollow_green_fails_the_element_scan() {
        // The hollow demo: exit 0, nothing shown — passes the run, DIES on the element scan.
        let hollow = demo_report(&contract(true), |_| (Ok(0), "all fine\n".to_string()));
        assert_eq!(
            hollow,
            DemoState::MissingElements(elements(&[
                "header",
                "cases",
                "summary_table",
                "before_after"
            ]))
        );
        assert!(hollow.blocks());
        // Exit 0 + every marker in the LIVE output, no kit sign → the legacy green (S168: warned).
        let green = demo_report(&contract(true), |_| (Ok(0), FULL_OUTPUT.to_string()));
        assert_eq!(green, DemoState::LegacyGreen);
        assert!(!green.blocks());
    }

    #[test]
    fn run_demo_script_returns_exit_code_and_captured_output() {
        let tmp = repo_with_constraints(CONSTRAINTS);
        let root = tmp.path();
        fs::create_dir_all(root.join("scripts")).unwrap();
        fs::write(root.join("scripts/green.sh"), "echo 'demo:header shown'\n").unwrap();
        fs::write(root.join("scripts/red.sh"), "exit 3\n").unwrap();
        let (code, out) = run_demo_script(root, "scripts/green.sh");
        assert_eq!(code, Ok(0));
        assert!(out.contains("demo:header"));
        assert_eq!(run_demo_script(root, "scripts/red.sh").0, Ok(3));
    }

    #[test]
    fn gate_blocks_red_and_hollow_passes_full_warns_missing() {
        let tmp = repo_with_constraints(CONSTRAINTS);
        let root = tmp.path();

        // Missing script → WARN, and the warning names the dodge.
        let v = demo_gate_with(root, 71, |_| panic!("must not run"));
        assert!(!v.blocked());
        assert!(v.warnings.iter().any(|w| w.contains("deleting the script")));

        // Script present + live red → BLOCK, naming the live exit code.
        fs::create_dir_all(root.join("scripts")).unwrap();
        fs::write(root.join("scripts/demo-session-71.sh"), "exit 3\n").unwrap();
        let v = demo_gate(root, 71);
        assert!(v.blocked());
        assert!(v.reasons.iter().any(|r| r.contains("exited 3")));

        // Hollow green (exit 0, no elements shown) → BLOCK, naming what is missing.
        fs::write(root.join("scripts/demo-session-71.sh"), "echo done\n").unwrap();
        let v = demo_gate(root, 71);
        assert!(v.blocked());
        assert!(v.reasons.iter().any(|r| r.contains("before_after")));
        assert!(v.reasons.iter().any(|r| r.contains("hollow")));

        // Live green with every element in the LIVE output → PASS, no warnings.
        let full =
            "printf 'demo:header\\ndemo:cases\\ndemo:summary_table\\ndemo:before_after\\n'\n";
        fs::write(root.join("scripts/demo-session-71.sh"), full).unwrap();
        let v = demo_gate(root, 71);
        assert!(!v.blocked(), "reasons: {:?}", v.reasons);
        assert_eq!(v.state, DemoState::LegacyGreen);
        assert!(
            v.warnings.iter().any(|w| w.contains("not built on")),
            "a legacy demo passes, but the warning names the downgrade: {:?}",
            v.warnings
        );
    }

    #[test]
    fn gate_block_message_names_timeout_distinctly_from_spawn_failure() {
        // The S73/S84 headline: an operator reading a blocked close must be able to tell WHICH of
        // the two cannot-evaluate reasons occurred, not one generic "no exit code" message.
        let tmp = repo_with_constraints(CONSTRAINTS);
        let root = tmp.path();
        fs::create_dir_all(root.join("scripts")).unwrap();
        fs::write(root.join("scripts/demo-session-71.sh"), "exit 0\n").unwrap();

        let timed_out = demo_gate_with(root, 71, |_| (Err(CannotEvaluate::Timeout), String::new()));
        assert!(timed_out.blocked());
        assert!(timed_out.reasons.iter().any(|r| r.contains("TIMEOUT")));
        assert!(!timed_out
            .reasons
            .iter()
            .any(|r| r.contains("SPAWN FAILURE")));

        let unspawnable = demo_gate_with(root, 71, |_| {
            (Err(CannotEvaluate::SpawnFailure), String::new())
        });
        assert!(unspawnable.blocked());
        assert!(unspawnable
            .reasons
            .iter()
            .any(|r| r.contains("SPAWN FAILURE")));
        assert!(!unspawnable.reasons.iter().any(|r| r.contains("TIMEOUT")));

        assert_ne!(timed_out.reasons, unspawnable.reasons);
    }

    #[cfg(unix)]
    #[test]
    fn unreadable_script_still_exists_and_blocks_fail_closed() {
        // chmod 000 must not turn a BLOCK into the no-script WARN — existence is is_file(),
        // not readability, and the live run then fails (bash exit 126), which BLOCKS.
        use std::os::unix::fs::PermissionsExt;
        let tmp = repo_with_constraints(CONSTRAINTS);
        let root = tmp.path();
        fs::create_dir_all(root.join("scripts")).unwrap();
        let path = root.join("scripts/demo-session-71.sh");
        fs::write(&path, "echo hi\n").unwrap();
        fs::set_permissions(&path, fs::Permissions::from_mode(0o000)).unwrap();

        let c = gather_contract(root, 71);
        assert!(c.script_exists, "an unreadable script still EXISTS");
        assert_eq!(c.missing_in_file, c.required_elements);
        let v = demo_gate(root, 71);
        assert!(v.blocked(), "must block fail-closed, not warn as no-script");
        fs::set_permissions(&path, fs::Permissions::from_mode(0o644)).unwrap();
    }

    #[test]
    fn surface_shows_elements_and_names_the_live_run_cost() {
        let tmp = repo_with_constraints(CONSTRAINTS);
        fs::create_dir_all(tmp.path().join("scripts")).unwrap();
        fs::write(
            tmp.path().join("scripts/demo-session-71.sh"),
            "echo 'demo:header'\n",
        )
        .unwrap();
        let out = format_demo_contract(&gather_contract(tmp.path(), 71));
        assert!(out.contains("scripts/demo-session-71.sh"));
        assert!(out.contains("✓ header"));
        assert!(out.contains("✗ before_after"));
        assert!(out.contains("read-only"));
        assert!(out.contains("honest cost"), "got:\n{out}");
        // Missing script → the surface says so and still lists what is required.
        let missing = format_demo_contract(&gather_contract(tmp.path(), 72));
        assert!(missing.contains("MISSING"));
        assert!(missing.contains("✗ summary_table"));
    }

    // ── S168 (DECISION-010): a kit-built demo must reach demo:complete and print true facts ─────

    const OUTLINE: &str = "s1() { dk_section headline; dk_vajra_tiles 71; }
s2() { dk_section story; }
s3() { dk_section before_after; }
s4() { dk_section rule; }
s5() { dk_section cases; CHECK; }
s6() { dk_section scorecard; dk_scorecard LIVE; }
s7() { dk_section next; }
dk_deck s1 s2 s3 s4 s5 s6 s7
";

    /// A temp repo with the REAL kit, a demo built on it, and a stub `vajra` that prints the facts
    /// file (written AFTER the demo, so the honest file equals what the gate derives).
    fn kit_repo(check: &str, finish: bool) -> tempfile::TempDir {
        use std::os::unix::fs::PermissionsExt;
        let tmp = repo_with_constraints(CONSTRAINTS);
        let root = tmp.path();
        fs::create_dir_all(root.join("scripts")).unwrap();
        fs::write(
            root.join("scripts/demo-kit.sh"),
            include_str!("../../scripts/demo-kit.sh"),
        )
        .unwrap();
        let script = format!(
            ". \"$(cd \"$(dirname \"$0\")\" && pwd)/demo-kit.sh\"\n{}{}",
            OUTLINE.replace("CHECK", check),
            if finish { "dk_finish\n" } else { "" }
        );
        fs::write(root.join("scripts/demo-session-71.sh"), script).unwrap();
        fs::write(
            root.join("facts-71.txt"),
            facts::format_demo_facts(&facts::demo_facts(root, 71)),
        )
        .unwrap();
        let stub = root.join("stub-vajra");
        fs::write(
            &stub,
            format!("#!/bin/sh\ncat \"{}/facts-$3.txt\"\n", root.display()),
        )
        .unwrap();
        fs::set_permissions(&stub, fs::Permissions::from_mode(0o755)).unwrap();
        tmp
    }

    fn gate_kit(root: &Path) -> DemoVerdict {
        let envs = [
            ("VAJRA_BIN", root.join("stub-vajra").into_os_string()),
            ("DEMO_MODE", "stream".into()),
        ];
        demo_gate_with_facts(
            root,
            71,
            |script| {
                crate::gate_run::run_captured_env(
                    root,
                    script,
                    std::time::Duration::from_secs(120),
                    &envs,
                )
            },
            |s| facts::demo_facts(root, s),
        )
    }

    #[cfg(unix)]
    #[test]
    fn kit_demo_honest_passes_with_no_downgrade_warning() {
        let tmp = kit_repo("dk_check \"a real command\" test -d scripts", true);
        let v = gate_kit(tmp.path());
        assert_eq!(v.state, DemoState::LiveGreen, "reasons: {:?}", v.reasons);
        assert!(v.warnings.is_empty(), "{:?}", v.warnings);
    }

    #[cfg(unix)]
    #[test]
    fn kit_demo_with_a_typed_pass_blocks() {
        let tmp = kit_repo("dk_check \"typed\" PASS", true);
        let v = gate_kit(tmp.path());
        assert!(v.blocked());
        assert_eq!(
            v.state,
            DemoState::LiveRed(1),
            "the kit refuses the token and exits 1"
        );
    }

    #[cfg(unix)]
    #[test]
    fn kit_demo_with_a_forged_fact_blocks_naming_it() {
        let tmp = kit_repo("dk_check \"a real command\" test -d scripts", true);
        let root = tmp.path();
        let honest = fs::read_to_string(root.join("facts-71.txt")).unwrap();
        let forged: String = honest
            .lines()
            .map(|l| {
                if l.starts_with("stations_passed=") {
                    "stations_passed=8\n".to_string()
                } else {
                    format!("{l}\n")
                }
            })
            .collect();
        assert_ne!(forged, honest, "the fixture must actually forge a fact");
        fs::write(root.join("facts-71.txt"), forged).unwrap();
        let v = gate_kit(root);
        assert!(
            matches!(v.state, DemoState::KitUnproven(_)),
            "{:?}",
            v.state
        );
        assert!(
            v.reasons
                .iter()
                .any(|r| r.contains("stations_passed=8") && r.contains("Vajra derives")),
            "{:?}",
            v.reasons
        );
    }

    #[cfg(unix)]
    #[test]
    fn kit_demo_that_never_reaches_dk_finish_blocks() {
        let tmp = kit_repo("dk_check \"a real command\" test -d scripts", false);
        let v = gate_kit(tmp.path());
        // Exit 0 and every marker shown — only the missing `demo:complete` catches it.
        assert!(
            matches!(v.state, DemoState::KitUnproven(_)),
            "{:?}",
            v.state
        );
        assert!(v.reasons.iter().any(|r| r.contains("demo:complete")));
    }

    #[test]
    fn hand_echoed_kit_signs_make_the_demo_kit_built() {
        // No kit in the script text, but an echoed `demo:complete` + a typed fact: detection by
        // output fires, so the typed fact and the missing fact set block.
        let tmp = repo_with_constraints(CONSTRAINTS);
        let root = tmp.path();
        fs::create_dir_all(root.join("scripts")).unwrap();
        fs::write(
            root.join("scripts/demo-session-71.sh"),
            "printf 'demo:header\\ndemo:cases\\ndemo:summary_table\\ndemo:before_after\\ndemo:complete\\ndemo:fact session=71\\ndemo:fact stations_passed=8\\n'\n",
        )
        .unwrap();
        let v = demo_gate(root, 71);
        assert!(v.blocked(), "{:?}", v.state);
        assert!(v.reasons.iter().any(|r| r.contains("stations_passed=8")));
        assert!(v.reasons.iter().any(|r| r.contains("prints no demo:fact")));
    }
}
