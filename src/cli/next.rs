use anyhow::{bail, Context, Result};
use std::env;
use std::fs;
use std::io::{self, BufRead, Write as _};
use std::path::{Path, PathBuf};
use std::process::Command;

use crate::analyst;
use crate::architect;
use crate::coder;
use crate::demoer;
use crate::dogfood;
use crate::maturity::{read_maturity, MaturityLevel};
use crate::planner;
use crate::qa;
use crate::releaser;
use crate::stations;

const PACKET_FILES: &[&str] = &[
    ".ai/AGENTS.md",
    ".ai/SESSION",
    ".ai/SESSION-BOOT.md",
    ".ai/TASK.md",
    ".ai/STATE.md",
    ".ai/CONSTRAINTS.yaml",
    ".ai/KNOWLEDGE.md",
    ".ai/ROADMAP.md",
];

pub fn run(args: &[String]) -> Result<()> {
    // The Analyst stage (S54) rides `vajra next` — no 8th top-level command (max-7 cap).
    if let Some(i) = args.iter().position(|a| a == "--scaffold") {
        return run_scaffold(args.get(i + 1), args.get(i + 2));
    }
    if let Some(i) = args.iter().position(|a| a == "--validate") {
        return run_validate(args.get(i + 1));
    }
    if let Some(i) = args.iter().position(|a| a == "--check-options") {
        return run_check_options(args.get(i + 1));
    }
    // The Planner stage (S64) also rides `vajra next` — no 8th command.
    if let Some(i) = args.iter().position(|a| a == "--plan") {
        return run_plan(args.get(i + 1));
    }
    if let Some(i) = args.iter().position(|a| a == "--check-plan") {
        return run_check_plan(args.get(i + 1));
    }
    // The Architect stage (S67) also rides `vajra next` — no 8th command.
    if let Some(i) = args.iter().position(|a| a == "--design") {
        return run_design(args.get(i + 1));
    }
    if let Some(i) = args.iter().position(|a| a == "--check-design") {
        return run_check_design(args.get(i + 1));
    }
    // The Coder stage (S68) also rides `vajra next` — no 8th command.
    if let Some(i) = args.iter().position(|a| a == "--exec") {
        return run_exec(args.get(i + 1));
    }
    if let Some(i) = args.iter().position(|a| a == "--check-exec") {
        return run_check_exec(args.get(i + 1));
    }
    // The QA stage (S69) also rides `vajra next` — no 8th command.
    if let Some(i) = args.iter().position(|a| a == "--qa") {
        return run_qa(args.get(i + 1));
    }
    if let Some(i) = args.iter().position(|a| a == "--check-qa") {
        return run_check_qa(args.get(i + 1));
    }
    // The Demo-er stage (S71) also rides `vajra next` — no 8th command.
    if let Some(i) = args.iter().position(|a| a == "--demo") {
        return run_demo(args.get(i + 1));
    }
    if let Some(i) = args.iter().position(|a| a == "--check-demo") {
        return run_check_demo(args.get(i + 1));
    }
    // The Releaser stage (S72) also rides `vajra next` — no 8th command.
    if let Some(i) = args.iter().position(|a| a == "--release") {
        return run_release(args.get(i + 1));
    }
    if let Some(i) = args.iter().position(|a| a == "--check-release") {
        return run_check_release(args.get(i + 1));
    }
    if args.iter().any(|a| a == "--intake") {
        return run_intake();
    }
    // The payload counter (S74) rides `vajra next` — no 8th command. Read-only, nothing executes.
    if let Some(i) = args.iter().position(|a| a == "--stations") {
        return run_stations(args.get(i + 1));
    }
    // The dogfood-staleness query (S91) rides `vajra next` — no 8th command. Read-only.
    if args.iter().any(|a| a == "--dogfood-age") {
        return run_dogfood_age();
    }

    if args.iter().any(|a| a == "--advance") {
        run_advance()
    } else {
        run_dump()
    }
}

/// `vajra next --intake` — the Analyst's INTAKE step (S62 / J1): surface the real inputs (prior
/// `.ai/SESSION` + the ROADMAP "Next builds" block) so a human authors the next job from context,
/// not a bare slug. Read-only; the binary surfaces, it does not author.
fn run_intake() -> Result<()> {
    let root = repo_root()?;
    print!("{}", analyst::format_intake(&analyst::gather_intake(&root)));
    Ok(())
}

/// `vajra next --stations NN` — the payload counter (S74): print, per governed station, whether
/// session NN's prompt DEMONSTRABLY passed it (PASSED / ABSENT) plus the derived `K of 8`. Each
/// verdict is read from that station's OWN classifier — never a self-asserted digit. Read-only:
/// nothing executes (the two LIVE stations are read statically). This retires the S25/S60/S65/S70
/// meta-gap — "did the PIPELINE advance?" becomes a measured question. Always exits 0 (a report,
/// not a gate).
fn run_stations(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--stations")?;
    let root = repo_root()?;
    print!(
        "{}",
        stations::format_station_report(&stations::station_report(&root, session))
    );
    Ok(())
}

/// `vajra next --dogfood-age` — the live dogfood-staleness query (S91): scan
/// `sessions/session-NN-artifacts/` for the most recent real `vajra claude` run, derive its date
/// from git (not from STATE.md), and report sessions-elapsed + calendar-days-elapsed. Always
/// exits 0 (a report, not a gate).
fn run_dogfood_age() -> Result<()> {
    let root = repo_root()?;
    let session_str =
        fs::read_to_string(root.join(".ai/SESSION")).context("failed to read .ai/SESSION")?;
    let current: u32 = session_str
        .trim()
        .parse()
        .context(".ai/SESSION is not a valid integer")?;
    let report = dogfood::dogfood_age(&root, current);
    print!("{}", dogfood::format_dogfood_age(current, report.as_ref()));
    Ok(())
}

/// `vajra next --check-options NN` — the Analyst's OPTIONS gate (S62 / J2): does
/// `sessions/session-NN-summary.md` record exactly 3 ranked next candidates? Exit 1 if it records
/// a wrong count (BLOCK); pass on exactly 3 or a wholly absent section (WARN). Mirrors `--validate`.
fn run_check_options(nn: Option<&String>) -> Result<()> {
    let nn = nn.context("usage: vajra next --check-options <NN>")?;
    let session: u32 = nn
        .trim()
        .parse()
        .with_context(|| format!("session number must be an integer (got {nn:?})"))?;
    let root = repo_root()?;

    let verdict = analyst::options_gate(&root, session);
    println!("=== analyst: ranked options for session {session:02} ===");
    println!(
        "summary: {}",
        verdict.summary_path.as_deref().unwrap_or("(none)")
    );
    if verdict.blocked() {
        println!("verdict: NOT READY");
        for r in &verdict.reasons {
            println!("  ✗ {r}");
        }
    } else {
        println!("verdict: READY");
    }
    for w in &verdict.warnings {
        println!("  ⚠ {w}");
    }
    if verdict.blocked() {
        std::process::exit(1);
    }
    Ok(())
}

/// `vajra next --plan NN` — the Planner's SURFACE step (S64): print the acceptance criteria of
/// session NN's prompt as the checklist to plan against (the plan derives from the contract, not
/// thin air). Read-only; the binary surfaces, it does not author.
fn run_plan(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--plan")?;
    let root = repo_root()?;
    let verdict = planner::plan_gate(&root, session);
    print!("{}", planner::format_plan_checklist(&verdict));
    Ok(())
}

/// `vajra next --check-plan NN` — the Planner's GATE (S64): does session NN's `## Plan` COVER every
/// acceptance criterion? Exit 1 on a placeholder/uncovered plan (BLOCK); pass on a covering plan or
/// a wholly absent one (WARN — legacy compat). Mirrors `--check-options`.
fn run_check_plan(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--check-plan")?;
    let root = repo_root()?;

    let verdict = planner::plan_gate(&root, session);
    println!("=== planner: plan for session {session:02} ===");
    println!(
        "prompt: {}",
        verdict.prompt_path.as_deref().unwrap_or("(none)")
    );
    if verdict.blocked() {
        println!("verdict: NOT READY");
        for r in &verdict.reasons {
            println!("  ✗ {r}");
        }
    } else {
        println!("verdict: READY");
    }
    for w in &verdict.warnings {
        println!("  ⚠ {w}");
    }
    if verdict.blocked() {
        std::process::exit(1);
    }
    Ok(())
}

/// `vajra next --design NN` — the Architect's SURFACE step (S67): print the locked design spine
/// (`docs/adr/` + `docs/decisions/`) as the checklist session NN's `## Design` rationale must cite
/// from, with the prompt's current citations marked. Read-only; the binary surfaces, it does not
/// author a design.
fn run_design(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--design")?;
    let root = repo_root()?;
    let verdict = architect::design_gate(&root, session);
    print!("{}", architect::format_design_checklist(&verdict));
    Ok(())
}

/// `vajra next --check-design NN` — the Architect's GATE (S67): a design-significant prompt
/// (recorded `design-significant: yes`) must carry a substantive, spine-citing `## Design`
/// rationale. Exit 1 on a missing/placeholder rationale (BLOCK); pass on a substantive one or a
/// non-significant prompt (WARN at most — legacy compat). Mirrors `--check-plan`.
fn run_check_design(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--check-design")?;
    let root = repo_root()?;

    let verdict = architect::design_gate(&root, session);
    println!("=== architect: design for session {session:02} ===");
    println!(
        "prompt: {}",
        verdict.prompt_path.as_deref().unwrap_or("(none)")
    );
    if verdict.blocked() {
        println!("verdict: NOT READY");
        for r in &verdict.reasons {
            println!("  ✗ {r}");
        }
    } else {
        println!("verdict: READY");
    }
    for w in &verdict.warnings {
        println!("  ⚠ {w}");
    }
    if verdict.blocked() {
        std::process::exit(1);
    }
    Ok(())
}

/// `vajra next --exec NN` — the Coder's SURFACE step (S68): print session NN's plan steps as the
/// execution checklist with each step's recorded state (done `<sha>` / unrecorded). Read-only;
/// the binary surfaces the trace, it never codes.
fn run_exec(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--exec")?;
    let root = repo_root()?;
    let verdict = coder::exec_gate(&root, session);
    print!("{}", coder::format_exec_checklist(&verdict));
    Ok(())
}

/// `vajra next --check-exec NN` — the Coder's GATE (S68): does session NN record a `done: <sha>`
/// naming a commit that EXISTS for every numbered plan step? Exit 1 on an unrecorded/fake trace
/// (BLOCK); pass on a fully recorded one; a legacy prompt (no `## Execution`) WARNS at most.
/// Mirrors `--check-design`.
fn run_check_exec(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--check-exec")?;
    let root = repo_root()?;

    let verdict = coder::exec_gate(&root, session);
    println!("=== coder: execution for session {session:02} ===");
    println!(
        "prompt: {}",
        verdict.prompt_path.as_deref().unwrap_or("(none)")
    );
    if verdict.blocked() {
        println!("verdict: NOT READY");
        for r in &verdict.reasons {
            println!("  ✗ {r}");
        }
    } else {
        println!("verdict: READY");
    }
    for w in &verdict.warnings {
        println!("  ⚠ {w}");
    }
    if verdict.blocked() {
        std::process::exit(1);
    }
    Ok(())
}

/// `vajra next --qa NN` — the QA station's SURFACE step (S69): print session NN's recorded
/// verify contract (expected script, recorded `.ai/verify/` runs, latest) read-only — nothing
/// executes here. The contract derives from `CONSTRAINTS.yaml#verify`, not thin air.
fn run_qa(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--qa")?;
    let root = repo_root()?;
    print!(
        "{}",
        qa::format_qa_contract(&qa::gather_contract(&root, session))
    );
    Ok(())
}

/// `vajra next --check-qa NN` — the QA station's GATE (S69): RE-RUN session NN's verify script
/// LIVE and exit 1 on non-zero (BLOCK) — a previously recorded green is never accepted as proof
/// (no stale-green). A missing script (NO-CODE GT / legacy) WARNS at most, the dodge named.
/// Mirrors `--check-exec`. Honest cost: the live run executes cargo build/test — slow, on purpose.
fn run_check_qa(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--check-qa")?;
    let root = repo_root()?;

    println!("=== qa: verify for session {session:02} ===");
    let verdict = qa::qa_gate(&root, session);
    println!("script: {}", verdict.contract.script);
    if verdict.blocked() {
        println!("verdict: NOT READY");
        for r in &verdict.reasons {
            println!("  ✗ {r}");
        }
    } else {
        println!("verdict: READY");
    }
    for w in &verdict.warnings {
        println!("  ⚠ {w}");
    }
    if verdict.blocked() {
        std::process::exit(1);
    }
    Ok(())
}

/// `vajra next --demo NN` — the Demo-er station's SURFACE step (S71): print session NN's
/// recorded sprint-demo contract (expected script, required elements found/missing in the script
/// text) read-only — nothing executes here. The contract derives from `CONSTRAINTS.yaml#demo`,
/// not thin air.
fn run_demo(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--demo")?;
    let root = repo_root()?;
    print!(
        "{}",
        demoer::format_demo_contract(&demoer::gather_contract(&root, session))
    );
    Ok(())
}

/// `vajra next --check-demo NN` — the Demo-er station's GATE (S71): RE-RUN session NN's demo
/// script LIVE and exit 1 on a non-zero exit OR on required elements missing from the live
/// output (BLOCK) — a recorded green is never accepted, and a hollow exit-0 demo fails the
/// element scan. A missing script (NO-CODE GT / legacy) WARNS at most, the dodge named.
/// Mirrors `--check-qa`. Honest cost: the live run executes the demo — real seconds.
fn run_check_demo(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--check-demo")?;
    let root = repo_root()?;

    println!("=== demoer: sprint demo for session {session:02} ===");
    let verdict = demoer::demo_gate(&root, session);
    println!("script: {}", verdict.contract.script);
    if verdict.blocked() {
        println!("verdict: NOT READY");
        for r in &verdict.reasons {
            println!("  ✗ {r}");
        }
    } else {
        println!("verdict: READY");
    }
    for w in &verdict.warnings {
        println!("  ⚠ {w}");
    }
    if verdict.blocked() {
        std::process::exit(1);
    }
    Ok(())
}

/// `vajra next --release NN` — the Releaser station's SURFACE step (S72): print session NN's
/// ship state (branch merged into main or not, local main vs origin/main, unpruned merged
/// `session-*` locals) re-derived from LOCAL git refs, read-only — nothing is fetched, pushed,
/// merged, or deleted here or anywhere in the station.
fn run_release(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--release")?;
    let root = repo_root()?;
    print!(
        "{}",
        releaser::format_release_report(&releaser::release_gate(&root, session))
    );
    Ok(())
}

/// `vajra next --check-release NN` — the Releaser station's GATE (S72): exit 1 when session
/// NN's ship hygiene is unfinished — its branch is not an ancestor of main, local main is
/// behind/diverged from the last-fetched origin/main, or merged `session-*` branches (other
/// than the current one) are unpruned. Derived live from git; a repo where the state cannot
/// be derived FAILS, never silently passes. Mirrors `--check-demo`.
fn run_check_release(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--check-release")?;
    let root = repo_root()?;

    println!("=== releaser: ship for session {session:02} ===");
    let verdict = releaser::release_gate(&root, session);
    if let Some(state) = &verdict.state {
        println!("main: {} · branch: {}", state.main, {
            match &state.branch {
                releaser::BranchShip::Merged(refs) => format!("{} (merged)", refs.join(", ")),
                releaser::BranchShip::Unmerged(refs) => {
                    format!("{} (NOT merged)", refs.join(", "))
                }
                releaser::BranchShip::NoBranch => "not found (pruned or never created)".into(),
            }
        });
    }
    if verdict.blocked() {
        println!("verdict: NOT READY");
        for r in &verdict.reasons {
            println!("  ✗ {r}");
        }
    } else {
        println!("verdict: READY");
    }
    for w in &verdict.warnings {
        println!("  ⚠ {w}");
    }
    if verdict.blocked() {
        std::process::exit(1);
    }
    Ok(())
}

/// Parse a `<NN>` session-number argument shared by the Planner subcommands.
fn parse_session(nn: Option<&String>, flag: &str) -> Result<u32> {
    let nn = nn.with_context(|| format!("usage: vajra next {flag} <NN>"))?;
    nn.trim()
        .parse()
        .with_context(|| format!("session number must be an integer (got {nn:?})"))
}

/// `vajra next --scaffold NN <slug>` — the Analyst's GENERATE step: write a well-formed prompt
/// (`prompts/NN-task-<slug>.md`) from the Borrow-Engine template, ready to fill and approve.
fn run_scaffold(nn: Option<&String>, slug: Option<&String>) -> Result<()> {
    let (nn, slug) = match (nn, slug) {
        (Some(nn), Some(slug)) => (nn, slug),
        _ => bail!("usage: vajra next --scaffold <NN> <slug>   (e.g. --scaffold 56 planner-stage)"),
    };
    let session: u32 = nn
        .trim()
        .parse()
        .with_context(|| format!("session number must be an integer (got {nn:?})"))?;

    let root = repo_root()?;

    // S62 / J1: surface the real intake inputs FIRST — the prior session + ROADMAP next-builds the
    // author must fold into the Goal, so the job comes from context, not the bare slug.
    print!("{}", analyst::format_intake(&analyst::gather_intake(&root)));
    println!();

    // S61 / J3: GENERATE writes the prompt AND updates the `.ai/TASK.md` pointer (the spine).
    // Previously scaffold only `println!`d advice — the pointer was never moved.
    let rel = scaffold_and_point(&root, session, slug)?;
    println!("scaffolded {rel} (DRAFT)");
    println!("  .ai/TASK.md pointer -> {rel}");
    println!("  fill Goal/Deliverables/Acceptance/Guardrails/Delta, then flip Status -> APPROVED.");
    println!(
        "  the advance gate blocks `vajra next --advance` into session {session:02} until then."
    );
    Ok(())
}

/// The Analyst's GENERATE step, factored pure (explicit `root`) so a test can drive it without
/// `current_dir`. Writes `prompts/NN-task-<slug>.md`, then repoints `.ai/TASK.md` at it — closing
/// the S54 J3 gap ("write the prompt + update TASK.md"). Reuses `update_prompt_pointer` (the same
/// helper `--advance` uses — one implementation, no second store, no drift). The pointer update is
/// a no-op if TASK.md lacks a `Read prompt:` line, so it never clobbers unrelated prose.
fn scaffold_and_point(root: &Path, session: u32, slug: &str) -> Result<String> {
    let path = analyst::scaffold_prompt(root, session, slug).map_err(|e| anyhow::anyhow!(e))?;
    let rel = path
        .strip_prefix(root)
        .unwrap_or(&path)
        .to_string_lossy()
        .into_owned();
    update_prompt_pointer(root, ".ai/TASK.md", &rel)?;
    Ok(rel)
}

/// `vajra next --validate NN` — the Analyst's report: is prompts/NN-*.md well-formed?
fn run_validate(nn: Option<&String>) -> Result<()> {
    let nn = nn.context("usage: vajra next --validate <NN>")?;
    let session: u32 = nn
        .trim()
        .parse()
        .with_context(|| format!("session number must be an integer (got {nn:?})"))?;

    let cwd = env::current_dir().context("failed to read current directory")?;
    let root =
        find_repo_root(&cwd).context("could not find a Vajra repo (.ai directory missing)")?;

    let verdict = analyst::gate(&root, session);
    println!("=== analyst: prompt for session {session:02} ===");
    println!(
        "prompt: {}",
        verdict.prompt_path.as_deref().unwrap_or("(none)")
    );
    if verdict.blocked() {
        println!("verdict: NOT READY");
        for r in &verdict.reasons {
            println!("  ✗ {r}");
        }
    } else {
        println!("verdict: READY");
    }
    for w in &verdict.warnings {
        println!("  ⚠ {w}");
    }
    if verdict.blocked() {
        std::process::exit(1);
    }
    Ok(())
}

fn run_dump() -> Result<()> {
    let cwd = env::current_dir().context("failed to read current directory")?;
    let root =
        find_repo_root(&cwd).context("could not find a Vajra repo (.ai directory missing)")?;
    let session =
        fs::read_to_string(root.join(".ai/SESSION")).context("failed to read .ai/SESSION")?;
    let task = fs::read_to_string(root.join(".ai/TASK.md")).ok();
    let boot = fs::read_to_string(root.join(".ai/SESSION-BOOT.md")).ok();
    let prompt = task
        .as_deref()
        .and_then(extract_prompt_path)
        .or_else(|| boot.as_deref().and_then(extract_prompt_path));

    println!("=== vajra next ===");
    println!("repo: {}", root.display());
    println!("branch: {}", current_branch(&root));
    println!("session: {}", session.trim());
    println!(
        "prompt: {}",
        prompt.as_deref().unwrap_or("(no prompt pointer found)")
    );
    println!();

    for relative in PACKET_FILES {
        print_file(&root, relative)?;
    }

    if root.join("VISION.md").is_file() {
        print_file(&root, "VISION.md")?;
    }

    if let Some(relative) = prompt {
        let prompt_path = root.join(&relative);
        if prompt_path.is_file() {
            print_file(&root, &relative)?;
        } else {
            eprintln!("[vajra] warning: prompt file not found: {relative}");
        }
    }

    Ok(())
}

fn run_advance() -> Result<()> {
    let cwd = env::current_dir().context("failed to read current directory")?;
    let root =
        find_repo_root(&cwd).context("could not find a Vajra repo (.ai directory missing)")?;

    let branch = current_branch(&root);
    if branch == "main" || branch == "master" {
        bail!("refusing to advance on {branch} — switch to a session branch first");
    }

    let session_content =
        fs::read_to_string(root.join(".ai/SESSION")).context("failed to read .ai/SESSION")?;
    let current: u32 = session_content
        .trim()
        .parse()
        .context(".ai/SESSION is not a valid integer")?;
    let next = current + 1;

    let maturity = read_maturity(&root.join(".ai/CONSTRAINTS.yaml"));

    eprintln!("vajra next --advance ({maturity} {})", maturity.label());
    eprintln!("  current session: {current:02}");
    eprintln!("  next session:    {next:02}");
    eprintln!("  branch:          {branch}");
    eprintln!();

    // Analyst gate (S54): the pipeline's first handoff must be governed — you cannot advance
    // INTO session N+1 unless its prompt is present, well-formed, and APPROVED (not DRAFT).
    // Fail-closed at L2/L3; advise at L1; `VAJRA_SKIP_ANALYST_GATE=1` is the documented override.
    let verdict = analyst::gate(&root, next);
    for w in &verdict.warnings {
        eprintln!("  ⚠ {w}");
    }
    if verdict.blocked() {
        eprintln!("[vajra analyst] the prompt for session {next:02} is NOT ready:");
        for r in &verdict.reasons {
            eprintln!("    ✗ {r}");
        }
        if maturity == MaturityLevel::L1 {
            eprintln!("  (L1 advise — advancing anyway.)");
        } else if env::var("VAJRA_SKIP_ANALYST_GATE").is_ok() {
            eprintln!("  (VAJRA_SKIP_ANALYST_GATE set — advancing anyway.)");
        } else {
            bail!(
                "refusing to advance: session {next:02} has no approved, well-formed prompt \
                 (Analyst gate). Run `vajra next --scaffold {next:02} <slug>`, fill + approve it, \
                 or set VAJRA_SKIP_ANALYST_GATE=1 to override."
            );
        }
    }

    // Options gate (S62 / J2): closing `current` requires its summary to record EXACTLY 3 ranked
    // next candidates (end_of_session.must_present_n_options). A wrong count BLOCKS — a non-author
    // cannot close a session on 2 or 4 options; a wholly absent section only WARNS (legacy compat).
    // Same fail-closed-at-L2/L3, advise-at-L1, VAJRA_SKIP_ANALYST_GATE override as the prompt gate.
    let opts = analyst::options_gate(&root, current);
    for w in &opts.warnings {
        eprintln!("  ⚠ {w}");
    }
    if opts.blocked() {
        eprintln!("[vajra analyst] session {current:02} cannot close — its options are not ready:");
        for r in &opts.reasons {
            eprintln!("    ✗ {r}");
        }
        if maturity == MaturityLevel::L1 {
            eprintln!("  (L1 advise — advancing anyway.)");
        } else if env::var("VAJRA_SKIP_ANALYST_GATE").is_ok() {
            eprintln!("  (VAJRA_SKIP_ANALYST_GATE set — advancing anyway.)");
        } else {
            bail!(
                "refusing to advance: session {current:02} does not record exactly 3 ranked next \
                 candidates (Options gate). Fix its summary, or set VAJRA_SKIP_ANALYST_GATE=1."
            );
        }
    }

    // Coder gate (S68): the pipeline's CODE/execution bookend. Like the Options gate it binds on
    // the session being CLOSED — execution happened during `current`, so closing it requires each
    // numbered plan step to record a `done: <sha>` naming a commit that EXISTS (`git cat-file -e`
    // — the S67 existence lesson, git-shaped). An unrecorded/fake trace BLOCKS at L2/L3; a legacy
    // prompt (no `## Execution`) WARNS at most. `VAJRA_SKIP_CODER_GATE=1` is the documented
    // override (distinct from the other stages', so each stage overrides alone).
    let exec_verdict = coder::exec_gate(&root, current);
    for w in &exec_verdict.warnings {
        eprintln!("  ⚠ {w}");
    }
    if exec_verdict.blocked() {
        eprintln!(
            "[vajra coder] session {current:02} cannot close — its execution trace is not recorded:"
        );
        for r in &exec_verdict.reasons {
            eprintln!("    ✗ {r}");
        }
        if maturity == MaturityLevel::L1 {
            eprintln!("  (L1 advise — advancing anyway.)");
        } else if env::var("VAJRA_SKIP_CODER_GATE").is_ok() {
            eprintln!("  (VAJRA_SKIP_CODER_GATE set — advancing anyway.)");
        } else {
            bail!(
                "refusing to advance: session {current:02}'s plan steps lack a recorded, existing \
                 commit (Coder gate). Run `vajra next --exec {current:02}`, record \
                 `step N — done: <sha>` per step in the prompt's `## Execution`, or set \
                 VAJRA_SKIP_CODER_GATE=1 to override."
            );
        }
    }

    // QA gate (S69): the pipeline's WORKS bookend. Like the Coder gate it binds on the session
    // being CLOSED — closing `current` requires its verify script to pass a LIVE re-run (a
    // recorded green is never trusted; no stale-green). Honest cost: the re-run executes the
    // session's verify (cargo build/test — slow, on purpose: live evidence). A missing script
    // (NO-CODE ground-truth / legacy) WARNS at most, the dodge named. `VAJRA_SKIP_QA_GATE=1`
    // is the documented override (distinct from the other stages', so each overrides alone).
    if env::var("VAJRA_SKIP_QA_GATE").is_ok() {
        // The one gate where the override skips the CHECK itself, not just the block: a live
        // re-run is slow and side-effectful, and the author explicitly opted out.
        eprintln!("  ⚠ [vajra qa] VAJRA_SKIP_QA_GATE set — live verify re-run skipped.");
    } else {
        eprintln!("  [vajra qa] re-running session {current:02}'s verify LIVE (slow, on purpose):");
        let qa_verdict = qa::qa_gate(&root, current);
        for w in &qa_verdict.warnings {
            eprintln!("  ⚠ {w}");
        }
        if qa_verdict.blocked() {
            eprintln!(
                "[vajra qa] session {current:02} cannot close — its verify does not pass live:"
            );
            for r in &qa_verdict.reasons {
                eprintln!("    ✗ {r}");
            }
            if maturity == MaturityLevel::L1 {
                eprintln!("  (L1 advise — advancing anyway.)");
            } else {
                bail!(
                    "refusing to advance: session {current:02}'s verify script does not pass a \
                     live re-run (QA gate). Run `vajra next --check-qa {current:02}`, fix the \
                     verify until it is green live, or set VAJRA_SKIP_QA_GATE=1 to override."
                );
            }
        }
    }

    // Demo-er gate (S71): the pipeline's SHOW bookend. Like the QA gate it binds on the session
    // being CLOSED — closing `current` requires its sprint demo to run green LIVE and to SHOW
    // every required element (header · cases · summary_table · before_after) in that live
    // output: "seeing it, the user knows what this session delivered, and the before-and-after."
    // A hollow exit-0 demo fails the element scan; a recorded green is never trusted. A missing
    // script (NO-CODE ground-truth / legacy) WARNS at most, the dodge named.
    // `VAJRA_SKIP_DEMOER_GATE=1` is the documented override (distinct from the other stages',
    // so each overrides alone) — like QA's it skips the slow live run ITSELF, disclosed: an
    // opted-out close records no live demo evidence.
    if env::var("VAJRA_SKIP_DEMOER_GATE").is_ok() {
        eprintln!("  ⚠ [vajra demoer] VAJRA_SKIP_DEMOER_GATE set — live demo re-run skipped.");
    } else {
        eprintln!(
            "  [vajra demoer] re-running session {current:02}'s demo LIVE (real seconds, on purpose):"
        );
        let demo_verdict = demoer::demo_gate(&root, current);
        for w in &demo_verdict.warnings {
            eprintln!("  ⚠ {w}");
        }
        if demo_verdict.blocked() {
            eprintln!(
                "[vajra demoer] session {current:02} cannot close — its sprint demo does not \
                 show live:"
            );
            for r in &demo_verdict.reasons {
                eprintln!("    ✗ {r}");
            }
            if maturity == MaturityLevel::L1 {
                eprintln!("  (L1 advise — advancing anyway.)");
            } else {
                bail!(
                    "refusing to advance: session {current:02}'s demo does not pass a live \
                     re-run showing every required element (Demo-er gate). Run `vajra next \
                     --check-demo {current:02}`, fix the demo until it shows green live, or set \
                     VAJRA_SKIP_DEMOER_GATE=1 to override."
                );
            }
        }
    }

    // Releaser gate (S72): the pipeline's SHIP bookend — the last closing gate. Unlike the
    // QA/Demo-er gates it binds on the PRIOR session (the newest session at-or-below `current`
    // that left a branch or prompt, skipping the branch currently checked out): `current`'s own
    // PR merges AFTER this close, so the freshest verifiable ship is the previous one. Its work
    // must be merged into main (git ancestry), local main synced with the last-fetched
    // origin/main, and merged session-* branches pruned — the S37 founder-flagged
    // return-to-main step, enforced instead of remembered. Everything is re-derived from LOCAL
    // git refs at check time (nothing recorded to forge; no network, no gh) and the gate never
    // pushes, merges, or deletes — shipping stays a human act it waits for. A fresh repo (no
    // prior evidence) WARNS at most, the dodge named. `VAJRA_SKIP_RELEASER_GATE=1` is the
    // documented override (distinct — the check itself is cheap git reads, so unlike QA's it
    // still runs and prints; the env only bypasses the block).
    let ship = releaser::release_gate_for_close(&root, current);
    for w in &ship.warnings {
        eprintln!("  ⚠ {w}");
    }
    if ship.blocked() {
        let target = ship
            .session
            .map(|s| format!("{s:02}"))
            .unwrap_or_else(|| "??".into());
        eprintln!(
            "[vajra releaser] session {target}'s ship hygiene is unfinished — the close waits:"
        );
        for r in &ship.reasons {
            eprintln!("    ✗ {r}");
        }
        if maturity == MaturityLevel::L1 {
            eprintln!("  (L1 advise — advancing anyway.)");
        } else if env::var("VAJRA_SKIP_RELEASER_GATE").is_ok() {
            eprintln!("  (VAJRA_SKIP_RELEASER_GATE set — advancing anyway.)");
        } else {
            bail!(
                "refusing to advance: session {target}'s release is unfinished (Releaser gate). \
                 Run `vajra next --release {target}`, finish the ship (merge the PR / sync main \
                 / prune merged session-* branches), or set VAJRA_SKIP_RELEASER_GATE=1 to \
                 override."
            );
        }
    }

    // Architect gate (S67): the pipeline's DESIGN handoff, between the Analyst's WHAT and the
    // Planner's HOW-plan. You cannot advance INTO session N+1 when its prompt records
    // `design-significant: yes` but carries no substantive, spine-citing `## Design` rationale.
    // Non-significant/legacy prompts WARN at most. Same fail-closed-at-L2/L3, advise-at-L1
    // posture; `VAJRA_SKIP_ARCHITECT_GATE=1` is the documented override (distinct from the
    // Analyst's and Planner's, so each stage overrides alone).
    let design_verdict = architect::design_gate(&root, next);
    for w in &design_verdict.warnings {
        eprintln!("  ⚠ {w}");
    }
    if design_verdict.blocked() {
        eprintln!(
            "[vajra architect] session {next:02} is design-significant with no recorded design:"
        );
        for r in &design_verdict.reasons {
            eprintln!("    ✗ {r}");
        }
        if maturity == MaturityLevel::L1 {
            eprintln!("  (L1 advise — advancing anyway.)");
        } else if env::var("VAJRA_SKIP_ARCHITECT_GATE").is_ok() {
            eprintln!("  (VAJRA_SKIP_ARCHITECT_GATE set — advancing anyway.)");
        } else {
            bail!(
                "refusing to advance: session {next:02} is design-significant but records no \
                 substantive `## Design` rationale (Architect gate). Run `vajra next --design \
                 {next:02}`, record the rationale citing the ADR/DECISION it rests on, or set \
                 VAJRA_SKIP_ARCHITECT_GATE=1 to override."
            );
        }
    }

    // Planner gate (S64): the pipeline's 2nd governed handoff. You cannot advance INTO session N+1
    // unless its prompt's `## Plan` COVERS every acceptance criterion — the pre-execution mirror of
    // the fidelity Validator. A placeholder/uncovered plan BLOCKS; a wholly absent plan only WARNS
    // (legacy compat). Same fail-closed-at-L2/L3, advise-at-L1 posture; `VAJRA_SKIP_PLANNER_GATE=1`
    // is the documented override (distinct from the Analyst gate's, so each stage overrides alone).
    let plan_verdict = planner::plan_gate(&root, next);
    for w in &plan_verdict.warnings {
        eprintln!("  ⚠ {w}");
    }
    if plan_verdict.blocked() {
        eprintln!("[vajra planner] the plan for session {next:02} does NOT cover its contract:");
        for r in &plan_verdict.reasons {
            eprintln!("    ✗ {r}");
        }
        if maturity == MaturityLevel::L1 {
            eprintln!("  (L1 advise — advancing anyway.)");
        } else if env::var("VAJRA_SKIP_PLANNER_GATE").is_ok() {
            eprintln!("  (VAJRA_SKIP_PLANNER_GATE set — advancing anyway.)");
        } else {
            bail!(
                "refusing to advance: session {next:02}'s `## Plan` does not cover every acceptance \
                 criterion (Planner gate). Run `vajra next --plan {next:02}`, record a covering plan, \
                 or set VAJRA_SKIP_PLANNER_GATE=1 to override."
            );
        }
    }

    if maturity != MaturityLevel::L3 {
        if !confirm("Advance to next session?")? {
            eprintln!("Aborted.");
            return Ok(());
        }
    } else {
        eprintln!("L3 auto-advance — skipping confirmation.");
    }

    fs::write(root.join(".ai/SESSION"), format!("{next:02}\n"))
        .context("failed to write .ai/SESSION")?;

    update_session_boot(&root, current, next)?;

    let next_prompt = find_next_prompt(&root, next);
    if let Some(ref prompt_path) = next_prompt {
        update_prompt_pointer(&root, ".ai/TASK.md", prompt_path)?;
        update_prompt_pointer(&root, ".ai/SESSION-BOOT.md", prompt_path)?;
    }

    eprintln!();
    eprintln!("Advanced: session {current:02} → {next:02}");
    eprintln!("  .ai/SESSION updated");
    eprintln!("  .ai/SESSION-BOOT.md updated");
    if let Some(ref prompt_path) = next_prompt {
        eprintln!("  prompt pointer → {prompt_path}");
    } else {
        eprintln!("  warning: no prompt found for session {next:02} in prompts/");
    }

    Ok(())
}

fn update_session_boot(root: &Path, current: u32, next: u32) -> Result<()> {
    let path = root.join(".ai/SESSION-BOOT.md");
    let content = fs::read_to_string(&path).context("failed to read .ai/SESSION-BOOT.md")?;

    let current_str = format!("{current:02}");
    let next_str = format!("{next:02}");

    let updated: String = content
        .lines()
        .map(|line| {
            if line.contains("**Number:**") {
                line.replace(&current_str, &next_str)
            } else {
                line.to_string()
            }
        })
        .collect::<Vec<_>>()
        .join("\n");

    let updated = if content.ends_with('\n') && !updated.ends_with('\n') {
        updated + "\n"
    } else {
        updated
    };

    fs::write(&path, updated).context("failed to write .ai/SESSION-BOOT.md")?;
    Ok(())
}

fn confirm(question: &str) -> Result<bool> {
    eprint!("{question} [y/N] ");
    io::stderr().flush()?;
    let mut line = String::new();
    let bytes = io::stdin()
        .lock()
        .read_line(&mut line)
        .context("failed to read input")?;
    if bytes == 0 {
        return Ok(false);
    }
    Ok(matches!(
        line.trim().to_ascii_lowercase().as_str(),
        "y" | "yes"
    ))
}

fn find_repo_root(start: &Path) -> Option<PathBuf> {
    start
        .ancestors()
        .find(|dir| dir.join(".ai").is_dir())
        .map(Path::to_path_buf)
}

/// The Vajra repo root from the current directory (the `.ai/`-carrying ancestor).
fn repo_root() -> Result<PathBuf> {
    let cwd = env::current_dir().context("failed to read current directory")?;
    find_repo_root(&cwd).context("could not find a Vajra repo (.ai directory missing)")
}

fn current_branch(root: &Path) -> String {
    Command::new("git")
        .arg("branch")
        .arg("--show-current")
        .current_dir(root)
        .output()
        .ok()
        .filter(|output| output.status.success())
        .and_then(|output| String::from_utf8(output.stdout).ok())
        .map(|stdout| stdout.trim().to_string())
        .filter(|branch| !branch.is_empty())
        .unwrap_or_else(|| "?".to_string())
}

fn print_file(root: &Path, relative: &str) -> Result<()> {
    let path = root.join(relative);
    let content =
        fs::read_to_string(&path).with_context(|| format!("failed to read {}", path.display()))?;

    println!("----- {relative} -----");
    print!("{content}");
    if !content.ends_with('\n') {
        println!();
    }
    println!();

    Ok(())
}

fn find_next_prompt(root: &Path, next: u32) -> Option<String> {
    let prompts_dir = root.join("prompts");
    let prefix = format!("{next:02}-task-");

    fs::read_dir(&prompts_dir)
        .ok()?
        .filter_map(|e| e.ok())
        .find_map(|e| {
            let name = e.file_name().to_string_lossy().to_string();
            if name.starts_with(&prefix) && name.ends_with(".md") {
                Some(format!("prompts/{name}"))
            } else {
                None
            }
        })
}

fn update_prompt_pointer(root: &Path, relative: &str, new_prompt: &str) -> Result<()> {
    let path = root.join(relative);
    let content = match fs::read_to_string(&path) {
        Ok(c) => c,
        Err(_) => return Ok(()),
    };

    let updated: String = content
        .lines()
        .map(|line| {
            if !line.to_ascii_lowercase().contains("read prompt") {
                return line.to_string();
            }
            let Some(start) = line.find('`') else {
                return line.to_string();
            };
            let tail = &line[start + 1..];
            let Some(end) = tail.find('`') else {
                return line.to_string();
            };
            format!("{}`{new_prompt}`{}", &line[..start], &tail[end + 1..])
        })
        .collect::<Vec<_>>()
        .join("\n");

    let updated = if content.ends_with('\n') && !updated.ends_with('\n') {
        updated + "\n"
    } else {
        updated
    };

    fs::write(&path, updated).with_context(|| format!("failed to write {relative}"))?;
    Ok(())
}

fn extract_prompt_path(content: &str) -> Option<String> {
    content.lines().find_map(extract_backticked_prompt)
}

fn extract_backticked_prompt(line: &str) -> Option<String> {
    if !line.to_ascii_lowercase().contains("read prompt") {
        return None;
    }

    let start = line.find('`')?;
    let tail = &line[start + 1..];
    let end = tail.find('`')?;
    Some(tail[..end].to_string())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn extract_prompt_path_reads_task_pointer() {
        let task = "Read prompt: `prompts/04-task-launcher.md`";
        assert_eq!(
            extract_prompt_path(task),
            Some("prompts/04-task-launcher.md".to_string())
        );
    }

    #[test]
    fn extract_prompt_path_reads_session_boot_pointer() {
        let boot = "- **Read prompt:** `prompts/05-task-next.md`";
        assert_eq!(
            extract_prompt_path(boot),
            Some("prompts/05-task-next.md".to_string())
        );
    }

    #[test]
    fn extract_prompt_path_ignores_other_lines() {
        assert_eq!(extract_prompt_path("no prompt here"), None);
    }

    #[test]
    fn find_next_prompt_finds_matching_file() {
        let tmp = tempfile::tempdir().unwrap();
        let prompts = tmp.path().join("prompts");
        fs::create_dir_all(&prompts).unwrap();
        fs::write(prompts.join("02-task-add-goodbye.md"), "# S02").unwrap();
        fs::write(prompts.join("01-task-kickoff.md"), "# S01").unwrap();

        assert_eq!(
            find_next_prompt(tmp.path(), 2),
            Some("prompts/02-task-add-goodbye.md".to_string())
        );
        assert_eq!(find_next_prompt(tmp.path(), 3), None);
    }

    #[test]
    fn update_prompt_pointer_replaces_backticked_path() {
        let tmp = tempfile::tempdir().unwrap();
        let ai = tmp.path().join(".ai");
        fs::create_dir_all(&ai).unwrap();
        fs::write(
            ai.join("TASK.md"),
            "# Task\nRead prompt: `prompts/01-task-kickoff.md`\n",
        )
        .unwrap();

        update_prompt_pointer(tmp.path(), ".ai/TASK.md", "prompts/02-task-add-goodbye.md").unwrap();

        let result = fs::read_to_string(ai.join("TASK.md")).unwrap();
        assert!(result.contains("`prompts/02-task-add-goodbye.md`"));
        assert!(!result.contains("01-task-kickoff"));
    }

    #[test]
    fn scaffold_and_point_writes_prompt_and_repoints_task() {
        let tmp = tempfile::tempdir().unwrap();
        let ai = tmp.path().join(".ai");
        fs::create_dir_all(&ai).unwrap();
        fs::write(
            ai.join("TASK.md"),
            "# Task\nRead prompt: `prompts/60-task-old.md`\n",
        )
        .unwrap();

        let rel = scaffold_and_point(tmp.path(), 61, "analyst-generate-delta").unwrap();
        assert_eq!(rel, "prompts/61-task-analyst-generate-delta.md");
        // The prompt file was written...
        assert!(tmp.path().join(&rel).is_file());
        // ...and the TASK.md pointer now names it (J3), old pointer gone, prose intact.
        let task = fs::read_to_string(ai.join("TASK.md")).unwrap();
        assert!(task.contains("`prompts/61-task-analyst-generate-delta.md`"));
        assert!(!task.contains("60-task-old"));
        assert!(task.starts_with("# Task"));
    }

    #[test]
    fn update_prompt_pointer_skips_missing_file() {
        let tmp = tempfile::tempdir().unwrap();
        let result =
            update_prompt_pointer(tmp.path(), ".ai/TASK.md", "prompts/02-task-add-goodbye.md");
        assert!(result.is_ok());
    }

    #[test]
    fn update_session_boot_replaces_number() {
        let tmp = tempfile::tempdir().unwrap();
        let ai = tmp.path().join(".ai");
        fs::create_dir_all(&ai).unwrap();
        fs::write(
            ai.join("SESSION-BOOT.md"),
            "# Session Boot\n- **Number:** 08\n- **Type:** CODE\n",
        )
        .unwrap();

        update_session_boot(tmp.path(), 8, 9).unwrap();

        let result = fs::read_to_string(ai.join("SESSION-BOOT.md")).unwrap();
        assert!(result.contains("**Number:** 09"));
        assert!(!result.contains("**Number:** 08"));
    }
}
