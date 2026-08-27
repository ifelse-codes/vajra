use anyhow::{bail, Context, Result};
use std::env;
use std::fs;
use std::io::{self, BufRead, Read as _, Write as _};
use std::path::{Path, PathBuf};
use std::process::Command;

use crate::advice;
use crate::analyst;
use crate::architect;
use crate::coder;
use crate::crew;
use crate::demoer;
use crate::dispatch;
use crate::dogfood;
use crate::fidelity;
use crate::fleet;
use crate::gate_run;
use crate::mandate;
use crate::maturity::{read_maturity, MaturityLevel};
use crate::obeyed;
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
    // The Mandate gate (S133) rides `vajra next` — no 8th command. Deliberately NOT folded into
    // `--check-design`: that flag binds on the session being advanced INTO and asks whether the
    // prompt's `## Design` rationale is substantive; this one binds on the session being CLOSED
    // and asks whether a real `design-advisor` was consulted at all. Folding them would also make
    // `design-significant: no` silently exempt a mandatory role, because `architect::parse_design`
    // never blocks on that value (DECISION-007 S133 addendum).
    if let Some(i) = args.iter().position(|a| a == "--check-design-handoff") {
        return run_check_design_handoff(args.get(i + 1));
    }
    // The Crew gate (S135) rides `vajra next` — no 8th command. Binds on the session being CLOSED:
    // a real, provenance-verified `tech-lead` handoff must exist, and every role it marked
    // `required` must have produced its own real governed handoff. Built as a CALL SITE on
    // `src/mandate` (DECISION-007 S135 addendum) — no edit to the shared ladder.
    if let Some(i) = args.iter().position(|a| a == "--check-crew") {
        return run_check_crew(args.get(i + 1));
    }
    // The crew COST report (S135) rides `vajra next` — no 8th command. Read-only: prints each
    // subagent dispatch's RAW on-disk token total beside the budget the tech-lead recorded. It
    // REPORTS to LEARN; it does not block and does not scold (the budget is an instruction, not a
    // fence). Always exits 0.
    if let Some(i) = args.iter().position(|a| a == "--crew-cost") {
        return run_crew_cost(args.get(i + 1));
    }
    // The Coder stage (S68) also rides `vajra next` — no 8th command.
    if let Some(i) = args.iter().position(|a| a == "--exec") {
        return run_exec(args.get(i + 1));
    }
    if let Some(i) = args.iter().position(|a| a == "--check-exec") {
        return run_check_exec(args.get(i + 1));
    }
    // The Advice gate (S127) rides `vajra next` — no 8th command.
    if let Some(i) = args.iter().position(|a| a == "--advice") {
        return run_advice(args.get(i + 1));
    }
    if let Some(i) = args.iter().position(|a| a == "--check-advice") {
        return run_check_advice(args.get(i + 1));
    }
    // The Fidelity gate (S131) rides `vajra next` — no 8th command. Distinct from the Advice gate:
    // that one proves recommendations ANSWERED, this one proves the fidelity-reviewer handoff
    // itself EXISTS and is PROVABLY real (DECISION-007 S131 addendum).
    if let Some(i) = args.iter().position(|a| a == "--check-fidelity-handoff") {
        return run_check_fidelity_handoff(args.get(i + 1));
    }
    // The Obeyed gate (S132) rides `vajra next` — no 8th command. Distinct from the Advice gate
    // again, and for the same kind of reason S131 gave: `--check-advice` asks whether every
    // recommendation was ANSWERED; this asks whether an `obeyed:` answer is TRUE.
    if let Some(i) = args.iter().position(|a| a == "--check-obeyed") {
        return run_check_obeyed(args.get(i + 1));
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
    // The fleet's handoff governance (S109, DECISION-007) rides `vajra next` — no 8th command.
    if let Some(i) = args.iter().position(|a| a == "--role") {
        let name = args.get(i + 1);
        // S123: fence the executing role's dispatch behind a disposable checkout instead of the
        // real tree. Both ride `--role`, not a new flag family — same no-8th-command rule.
        if args.iter().any(|a| a == "--clean-room-open") {
            return run_clean_room_open(name);
        }
        if let Some(j) = args.iter().position(|a| a == "--clean-room-close") {
            return run_clean_room_close(name, args.get(j + 1));
        }
        return run_role_handoff(name, args);
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
    // S112: the CURRENT session's governed fleet handoffs are intake too — the branch names the
    // session, `.ai/SESSION` is the fallback (`current_session`). Absent handoffs print nothing.
    let session = current_session(&root);
    print!(
        "{}",
        analyst::format_intake(&analyst::gather_intake(&root, session))
    );
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

/// `vajra next --role <name> --clean-room-open` — S123, `DECISION-007` S123 addendum. Materialises
/// a disposable `git worktree` checkout of HEAD and prints its path plus the dispatch instruction:
/// point the role at THIS path, not the repo root. Scoped to a role that actually holds `Bash`
/// (today, only `qa-specialist`) — a read-only role has nothing to isolate. The worktree
/// deliberately outlives this process (see `gate_run::CleanRoom::open_persistent`); pair with
/// `--clean-room-close <path>` once the dispatched run is done.
fn run_clean_room_open(name: Option<&String>) -> Result<()> {
    let name = name.context("usage: vajra next --role <name> --clean-room-open")?;
    let role = fleet::resolve_role(name).ok_or_else(|| {
        anyhow::anyhow!(
            "unknown role {name:?} — known roles: {}",
            fleet::known_roles()
        )
    })?;
    if !role.tools.contains("Bash") {
        bail!(
            "{} is read-only (tools: {}) — a clean room isolates WRITES an executing role could \
             make; a role with no Bash grant has nothing to isolate. This flag is scoped to the \
             fleet's executing role(s).",
            role.name,
            role.tools
        );
    }
    let root = repo_root()?;
    let path = gate_run::CleanRoom::open_persistent(&root)
        .map_err(|e| anyhow::anyhow!("could not create a clean-room checkout of HEAD: {e:?}"))?;
    println!("clean room opened for {}: {}", role.name, path.display());
    println!(
        "  a full `git worktree` checkout of HEAD — every file and script exists here, isolated \
         from the working tree above."
    );
    println!(
        "  point every command {} runs at this path, not the repo root — cd there before \
         running the verify script.",
        role.name
    );
    println!(
        "  when the run is done: vajra next --role {} --clean-room-close {}",
        role.name,
        path.display()
    );
    Ok(())
}

/// `vajra next --role <name> --clean-room-close <path>` — removes a worktree opened by
/// `--clean-room-open`. A worktree never closed is reclaimed by `git worktree prune` like any
/// other orphaned entry (the same fallback `CleanRoom`'s `Drop` relies on) — this is tidiness,
/// not the safety property. The safety property is that nothing was ever pointed at the real tree.
fn run_clean_room_close(name: Option<&String>, path: Option<&String>) -> Result<()> {
    let name = name.context("usage: vajra next --role <name> --clean-room-close <path>")?;
    let role = fleet::resolve_role(name).ok_or_else(|| {
        anyhow::anyhow!(
            "unknown role {name:?} — known roles: {}",
            fleet::known_roles()
        )
    })?;
    let path = path.context("--clean-room-close needs the path --clean-room-open printed")?;
    let root = repo_root()?;
    if gate_run::CleanRoom::remove_persistent(&root, Path::new(path)) {
        println!("clean room closed for {}: {path}", role.name);
        Ok(())
    } else {
        bail!(
            "`git worktree remove --force {path}` did not succeed — it may already be closed, \
             or the path is wrong. `git worktree prune` cleans up a stale entry either way."
        )
    }
}

/// `vajra next --role <name> --from <findings-file>` — the fleet's handoff governance (S109,
/// DECISION-007). A native Claude Code subagent (scaffolded by `vajra init` from the canonical
/// `fleet::ROLES`) returns a findings brief; Vajra wraps it into a delta-tracked, validated handoff
/// in the `.ai/` spine. Fails closed on: unknown role · missing `--from` · missing/empty findings ·
/// a handoff that would not validate. `--from -` reads findings from stdin.
fn run_role_handoff(name: Option<&String>, args: &[String]) -> Result<()> {
    let name = name.context("usage: vajra next --role <name> --from <findings-file>")?;
    let role = fleet::resolve_role(name).ok_or_else(|| {
        anyhow::anyhow!(
            "unknown role {name:?} — known roles: {}. (a new role is a separate decision, \
             DECISION-007 — the fleet does not grow by typo.)",
            fleet::known_roles()
        )
    })?;
    let from = flag_value(args, "--from")
        .context("--role needs --from <findings-file> (or `--from -`)")?;
    let findings = read_findings(&from)?;
    if findings.trim().is_empty() {
        bail!("findings are empty — nothing to record (fail closed)");
    }
    let root = repo_root()?;
    let session = current_session(&root)
        .context("could not determine the session (no session-NN branch and no .ai/SESSION)")?;

    let handoff_rel = role.handoff_rel(session);
    let handoff_path = root.join(&handoff_rel);
    if let Some(parent) = handoff_path.parent() {
        fs::create_dir_all(parent).with_context(|| format!("mkdir {}", parent.display()))?;
    }
    let prior_body = fs::read_to_string(&handoff_path)
        .ok()
        .and_then(|p| fleet::handoff_body(&p));
    let body = findings.trim();
    let source_sha =
        fleet::sha256_hex(body.as_bytes()).unwrap_or_else(|| "unavailable".to_string());
    let delta = fleet::compute_delta(role, prior_body.as_deref(), body);
    // S131: the `agent:` field is DERIVED, not the hardcoded literal `"claude-code-subagent"` a
    // hand-typed handoff could satisfy for free. `dispatch::derive_provenance` independently
    // cross-checks this machine's real Claude Code dispatch evidence (S111/S117/S123's
    // evidentiary shape, automated) and reports honestly when nothing verifies — the gate that
    // reads this field (`--check-fidelity-handoff`) re-derives it again rather than trusting the
    // label written here.
    let provenance = dispatch::derive_provenance(&root, role.name, session);
    let agent_label = provenance.label();
    let handoff = fleet::format_handoff(
        role,
        session,
        // A subagent's cost rolls into the parent session receipt — recorded as `null` here (S77
        // honest null), with the session total disclosed in the summary.
        &agent_label,
        &source_sha,
        &utc_now(),
        None,
        body,
        &delta,
    );
    fleet::validate_handoff(&handoff)
        .map_err(|e| anyhow::anyhow!("refusing to write malformed handoff: {e}"))?;
    fs::write(&handoff_path, &handoff)
        .with_context(|| format!("write {}", handoff_path.display()))?;

    println!(
        "=== fleet: {} handoff governed (session {session:02}) ===",
        role.name
    );
    println!("  handoff:    {handoff_rel}");
    println!("  source-sha: {source_sha}");
    println!("  provenance: {agent_label}");
    println!(
        "  delta:      {}",
        delta.lines().next().unwrap_or("").trim_start_matches("- ")
    );
    println!("  validated:  OK (frontmatter + non-empty body + ## Handoff Delta)");
    Ok(())
}

/// The value following `flag` in `args`, if present.
fn flag_value(args: &[String], flag: &str) -> Option<String> {
    let i = args.iter().position(|a| a == flag)?;
    args.get(i + 1).cloned()
}

/// Read a role's findings from a file, or from stdin when the path is `-`.
fn read_findings(from: &str) -> Result<String> {
    if from == "-" {
        let mut buf = String::new();
        io::stdin()
            .lock()
            .read_to_string(&mut buf)
            .context("failed to read findings from stdin")?;
        Ok(buf)
    } else {
        fs::read_to_string(from).with_context(|| format!("failed to read findings file {from:?}"))
    }
}

/// The CURRENT session number for the handoff path: the active `session-NN-<slug>` branch (names the
/// session in flight even before closeout flips `.ai/SESSION`), else `.ai/SESSION`.
fn current_session(root: &Path) -> Option<u32> {
    let branch = current_branch(root);
    if let Some(rest) = branch.strip_prefix("session-") {
        let digits: String = rest.chars().take_while(|c| c.is_ascii_digit()).collect();
        if let Ok(n) = digits.parse::<u32>() {
            return Some(n);
        }
    }
    fs::read_to_string(root.join(".ai/SESSION"))
        .ok()?
        .trim()
        .parse()
        .ok()
}

/// A UTC ISO-8601 timestamp for the handoff's `captured` field. Shells out to `date` (no chrono dep).
fn utc_now() -> String {
    Command::new("date")
        .args(["-u", "+%Y-%m-%dT%H:%M:%SZ"])
        .output()
        .ok()
        .filter(|o| o.status.success())
        .and_then(|o| String::from_utf8(o.stdout).ok())
        .map(|s| s.trim().to_string())
        .filter(|s| !s.is_empty())
        .unwrap_or_else(|| "unknown".to_string())
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
    // The one-place-to-look property this gate would have had if S133's Mandate gate had been
    // folded into it, recovered by cross-reference rather than by shared logic (S133 `## Design`).
    println!(
        "note:   whether a real design-advisor was consulted is a DIFFERENT question — \
         `vajra next --check-design-handoff {session:02}`."
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

/// `vajra next --check-design-handoff NN` — the Mandate GATE (S133): was a real `design-advisor`
/// consulted for session NN, or is there a RECORDED, substantive reason why this session did not
/// need one? Exit 1 on silence at/after the threshold, on a marker that records no usable reason,
/// and on a handoff that is malformed or whose provenance does not independently re-verify.
///
/// There is no `VAJRA_SKIP_DESIGN_ADVISOR_GATE`: the recorded reason IS this gate's override, and
/// unlike an environment variable it leaves a trace a reader can find months later.
fn run_check_design_handoff(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--check-design-handoff")?;
    let root = repo_root()?;

    let verdict = mandate::design_advisor_gate(&root, session);
    println!("=== mandate: design-advisor for session {session:02} ===");
    println!(
        "prompt:  {}",
        verdict.prompt_path.as_deref().unwrap_or("(none)")
    );
    println!(
        "handoff: {}",
        verdict.handoff_path.as_deref().unwrap_or("(none)")
    );
    if let Some(agent) = &verdict.agent_field {
        println!("agent:   {agent}");
    }
    // Acceptance 2: a skipped design review is VISIBLE, never a clean green.
    if let Some(line) = verdict.skip_line() {
        println!("  ⚠ {line}");
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
    println!("note: {}.", mandate::MANDATE_FLOOR);
    if verdict.blocked() {
        std::process::exit(1);
    }
    Ok(())
}

/// `vajra next --check-crew NN` — the Crew GATE (S135): the tech-lead's decision, made binding.
/// Exit 1 unless (a) a real, provenance-verified `tech-lead` handoff exists (and is not a recorded
/// skip — the one role phase 1 forbids skipping), (b) it records an admissible verdict + substantive
/// reason + numeric budget for all nine specialists, and (c) every role it marked `required`
/// produced its own real governed handoff. Built as a CALL SITE on `src/mandate` — no ladder edit.
///
/// There is NO `VAJRA_SKIP_*` for this gate, matching the Mandate gate (S133): a fleet whose crew is
/// decided by an un-forgeable, provenance-verified handoff cannot have an agent-settable escape.
fn run_check_crew(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--check-crew")?;
    let root = repo_root()?;

    let verdict = crew::crew_gate(&root, session);
    println!("=== crew: tech-lead for session {session:02} ===");
    println!(
        "tech-lead handoff: {}",
        verdict.handoff_path.as_deref().unwrap_or("(none)")
    );
    // The crew decision lives ONLY in the provenance-verified handoff (Q1, handoff-only) — surface
    // it here so a reader of the prompt alone can still see it on demand.
    for d in &verdict.decisions {
        println!(
            "  · {role} — {verdict} — budget: {budget} tokens — {reason}",
            role = d.role,
            verdict = d.kind.word(),
            budget = d.budget_tokens,
            reason = d.reason,
        );
    }
    if verdict.blocked() {
        println!("verdict: NOT READY");
        for r in &verdict.reasons {
            println!("  ✗ {r}");
        }
    } else {
        let required = verdict.required_roles();
        println!(
            "verdict: READY — {} required, {} deferred-budget; every required role has a real handoff",
            required.len(),
            verdict.decisions.len() - required.len(),
        );
    }
    for w in &verdict.warnings {
        println!("  ⚠ {w}");
    }
    println!("note: {}.", crew::CREW_FLOOR);
    if verdict.blocked() {
        std::process::exit(1);
    }
    Ok(())
}

/// `vajra next --crew-cost NN` — the crew COST report (S135): for session NN, read each dispatched
/// subagent's on-disk transcript and print its RAW token total (input + output + cache reads + cache
/// writes) beside the budget the tech-lead recorded. It REPORTS to LEARN; it never blocks and never
/// scolds — the budget is an instruction, not a fence (DECISION-007 S135 addendum). Machine-local
/// like `--dogfood-age` (S91): a fresh CI runner has no `~/.claude/projects` history, disclosed and
/// exit 0. Always exits 0.
fn run_crew_cost(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--crew-cost")?;
    let root = repo_root()?;

    // The tech-lead's recorded budgets, when the crew handoff parsed — so each dispatch's actual can
    // be shown against its allowance. An unparsed/absent handoff still lets costs print (the report
    // does not depend on the gate passing).
    let verdict = crew::crew_gate(&root, session);
    let budget_for = |role: &str| -> Option<u64> {
        verdict
            .decisions
            .iter()
            .find(|d| d.role == role)
            .map(|d| d.budget_tokens)
    };

    println!("=== crew cost: session {session:02} (RAW subagent tokens, on-disk) ===");
    let Some(project_dir) = dispatch::project_dir_for(&root) else {
        println!(
            "  no ~/.claude/projects history on this machine — nothing to read (a fresh CI runner \
             has no dispatch transcripts). This is a report, not a gate: exit 0."
        );
        return Ok(());
    };

    let all = dispatch::subagent_dispatches_in(&project_dir);
    // Scope to THIS session: a dispatch's transcript records the branch it ran under, and this
    // session's branch names the session (`session-NN-<slug>`). A dispatch with no recorded branch
    // is included rather than dropped — an honest over-count beats a silent under-count.
    let want = format!("session-{session:02}");
    let dispatches: Vec<_> = all
        .iter()
        .filter(|d| {
            d.git_branch
                .as_deref()
                .map(|b| b.contains(&want))
                .unwrap_or(true)
        })
        .collect();
    if dispatches.is_empty() {
        println!(
            "  no subagent dispatches recorded for session {session:02} under {}",
            project_dir.display()
        );
        println!("note: the budget is an INSTRUCTION the role is trusted to honour — this report never blocks.");
        return Ok(());
    }

    let mut grand_total: u64 = 0;
    for d in &dispatches {
        match crew::read_dispatch_raw_tokens(&d.jsonl) {
            Ok(raw) => {
                grand_total += raw;
                let budget_note = match budget_for(&d.agent_type) {
                    Some(b) => {
                        let pct = if b > 0 { (raw as f64 / b as f64) * 100.0 } else { 0.0 };
                        format!("budget {b} tokens — actual {:.0}% of allowance", pct)
                    }
                    None => "no recorded tech-lead budget for this role".to_string(),
                };
                println!(
                    "  {role:<22} {raw:>12} raw tokens  ({budget_note})",
                    role = d.agent_type
                );
            }
            // S69: a transcript that should exist and does not is reported, never silently skipped.
            Err(why) => println!(
                "  {role:<22} {:>12}  ⚠ UNREADABLE — cannot evaluate: {why}",
                "?",
                role = d.agent_type
            ),
        }
    }
    println!("  {:-<22} {:->12}", "", "");
    println!("  {:<22} {grand_total:>12} raw tokens TOTAL (never a new-tokens-only figure)", "all dispatches");
    println!(
        "note: the budget is an INSTRUCTION the role is trusted to honour, never a cap Vajra can \
         enforce mid-run. An overrun is a finding for setting better budgets, not an offence — this \
         report never blocks."
    );
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

/// `vajra next --advice NN` — the Advice gate's SURFACE step (S127): print every numbered
/// recommendation session NN's governed handoffs record, INLINE (a path is not consumption —
/// S112), with the disposition the session recorded against each. Read-only; the binary surfaces
/// the advice and the answer, it never authors either.
fn run_advice(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--advice")?;
    let root = repo_root()?;
    let verdict = advice::advice_gate(&root, session);
    print!("{}", advice::format_advice_checklist(&verdict));
    for w in &verdict.warnings {
        println!("  ⚠ {w}");
    }
    Ok(())
}

/// `vajra next --check-advice NN` — the Advice GATE (S127): does every numbered recommendation in
/// session NN's governed handoffs carry a disposition whose evidence is REAL? Exit 1 on an
/// unanswered or unreal answer (BLOCK); a session with no handoffs, or handoffs carrying no
/// numbered recommendations, WARNs at most. Mirrors `--check-exec`.
fn run_check_advice(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--check-advice")?;
    let root = repo_root()?;

    let verdict = advice::advice_gate(&root, session);
    println!("=== advice: dispositions for session {session:02} ===");
    println!(
        "prompt: {}",
        verdict.prompt_path.as_deref().unwrap_or("(none)")
    );
    // Criterion 2: pass or fail, print one line per recommendation showing its disposition.
    for item in &verdict.items {
        let note = match &item.answer {
            advice::Answer::Answered(d) => format!("{}: {}", d.word(), d.evidence()),
            advice::Answer::Unreal(d, why) => format!("{}: {} — {why}", d.word(), d.evidence()),
            advice::Answer::Missing => "UNANSWERED".to_string(),
        };
        let mark = if item.answer.is_answered() {
            "✓"
        } else {
            "✗"
        };
        println!("  [{mark}] {} — {note}", item.rec.label());
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
    println!(
        "note: this proves each recommendation was ANSWERED and its evidence is real — never that \
         the answer was a good one."
    );
    if verdict.blocked() {
        std::process::exit(1);
    }
    Ok(())
}

/// `vajra next --check-fidelity-handoff NN` — the Fidelity GATE (S131): does session NN carry a
/// `fidelity-reviewer` governed handoff whose provenance independently re-verifies against real
/// Claude Code subagent-dispatch evidence? Exit 1 on absence, malformation, or unverifiable
/// provenance (BLOCK) — this gate has no legacy WARN-only escape hatch: the founder locked
/// `fidelity-reviewer` mandatory at the S130 closeout, so unlike the other stage gates a missing
/// handoff is never merely advisory once maturity is L2/L3 (see the `--advance` wiring).
fn run_check_fidelity_handoff(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--check-fidelity-handoff")?;
    let root = repo_root()?;

    let verdict = fidelity::fidelity_gate(&root, session);
    println!("=== fidelity: fidelity-reviewer handoff for session {session:02} ===");
    println!(
        "handoff: {}",
        verdict.handoff_path.as_deref().unwrap_or("(none)")
    );
    if let Some(agent) = &verdict.agent_field {
        println!("agent:   {agent}");
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
    println!(
        "note: this proves the handoff EXISTS and its provenance independently re-verifies — \
         never that the review's own verdict was thorough or correct (that is \
         sessions/session-NN-review.md, gated separately by verify-closeout.sh)."
    );
    if verdict.blocked() {
        std::process::exit(1);
    }
    Ok(())
}

/// `vajra next --check-obeyed NN` — the Obeyed GATE (S132): does every `obeyed: <sha>` disposition
/// session NN records carry an admissible, INDEPENDENT judgment that the cited commit really does
/// what the recommendation asked? Exit 1 on a `mismatch:` verdict (any session), on a judgment that
/// is not admissible (any session), or on a missing judgment from session
/// `OBEYED_JUDGMENT_FROM_SESSION` onward. Before that threshold a missing judgment WARNs and the
/// warning names the exemption — the migration posture, recorded rather than silent.
fn run_check_obeyed(nn: Option<&String>) -> Result<()> {
    let session = parse_session(nn, "--check-obeyed")?;
    let root = repo_root()?;

    let verdict = obeyed::obeyed_gate(&root, session);
    println!(
        "=== obeyed: independent judgment on session {session:02}'s `obeyed:` dispositions ==="
    );
    println!(
        "prompt: {}",
        verdict.prompt_path.as_deref().unwrap_or("(none)")
    );
    for item in &verdict.items {
        let (mark, note) = match &item.state {
            obeyed::ObeyedState::Implemented(j) => {
                ("✓", format!("implemented ({}): {}", j.judge_role, j.note))
            }
            obeyed::ObeyedState::Mismatch(j) => {
                ("✗", format!("MISMATCH ({}): {}", j.judge_role, j.note))
            }
            obeyed::ObeyedState::Rejected(why) => ("✗", format!("judgment REFUSED — {why}")),
            obeyed::ObeyedState::Unjudged => ("?", "UNJUDGED".to_string()),
        };
        println!("  [{mark}] {} — obeyed: {} — {note}", item.label, item.sha);
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
    println!("note: {}.", obeyed::CEILING);
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
    // author must fold into the Goal, so the job comes from context, not the bare slug. S112 adds
    // the third input: this session's governed fleet handoffs (findings the next job should fold in).
    let current = current_session(&root);
    print!(
        "{}",
        analyst::format_intake(&analyst::gather_intake(&root, current))
    );
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
    // S112: if the fleet produced governed findings for THIS session, the Analyst shows them at its
    // own gate — the WHAT is read next to the research that informs it, not in a separate file
    // nobody opens. Advisory only: it never blocks, and prints nothing when there is no handoff.
    print!(
        "{}",
        fleet::format_handoff_brief(
            &fleet::read_handoffs(&root, session),
            analyst::FLEET_HEAD_LINES
        )
    );
    if verdict.blocked() {
        std::process::exit(1);
    }
    Ok(())
}

/// Whether the founder pre-authorized commits for THIS session at launch (S99).
///
/// The S97 Ladder-Rung-1 blocker (b): `commit.autonomous: false` + `require_user_approval: true`
/// are satisfiable only by a conversational approval token, and a headless `-p` run has no channel
/// to receive one — so an unattended session can never commit, and the Coder station can never
/// record a sha. The token has an out-of-band form already (`VAJRA_ALLOW_COMMIT=NN`, the S93
/// un-forgeable env marker the L3 guard enforces); what was missing is that nothing TELLS the
/// agent it exists. This classification mirrors `scripts/hook-commit-guard.sh` exactly so the
/// packet can never say "pre-granted" where the guard would block.
///
/// **Honest bound (disclosed):** this reads `vajra next`'s own process environment, which the
/// agent controls — so the line is ADVISORY, never a permission. The un-forgeable teeth stay with
/// the L3 guard, which reads its OWN launch env before the command runs; an agent that inlines
/// the marker gets an explicit BLOCK there regardless of what this line said.
#[derive(Debug, Clone, PartialEq, Eq)]
enum CommitAuth {
    /// Marker present and valid for this session — the guard would ALLOW.
    PreGranted(String),
    /// Marker present but scoped to a different session — the guard would BLOCK.
    Mismatch { marker: String, session: String },
    /// No marker — a human approval token in chat is the only route.
    TokenRequired,
}

/// Classify the launch environment against the branch-derived session, exactly as the L3 guard
/// does: session digits come from a `session-NN-*` branch; off such a branch the guard accepts any
/// non-empty marker, so the packet reports the same.
fn commit_authorization(branch: &str, marker: Option<&str>) -> CommitAuth {
    let session = branch
        .strip_prefix("session-")
        .and_then(|rest| rest.split_once('-'))
        .map(|(digits, _)| digits)
        .filter(|d| !d.is_empty() && d.chars().all(|c| c.is_ascii_digit()));
    match (marker.filter(|m| !m.is_empty()), session) {
        (None, _) => CommitAuth::TokenRequired,
        (Some(m), None) => CommitAuth::PreGranted(m.to_string()),
        (Some(m), Some(s)) if m == s => CommitAuth::PreGranted(m.to_string()),
        (Some(m), Some(s)) => CommitAuth::Mismatch {
            marker: m.to_string(),
            session: s.to_string(),
        },
    }
}

fn render_commit_auth(auth: CommitAuth) -> String {
    match auth {
        CommitAuth::PreGranted(m) => format!(
            "commit approval: PRE-GRANTED — VAJRA_ALLOW_COMMIT={m} is set in this launch \
             environment.\n  That marker IS the founder's approval token for this session \
             (S93); commits may proceed\n  without a chat token. Advisory line — the L3 \
             guard remains the enforcing check."
        ),
        CommitAuth::Mismatch { marker, session } => format!(
            "commit approval: NOT VALID HERE — VAJRA_ALLOW_COMMIT={marker} is scoped to session \
             {marker},\n  but this branch is session {session}. The guard will BLOCK. Relaunch \
             with VAJRA_ALLOW_COMMIT={session}."
        ),
        CommitAuth::TokenRequired => String::from(
            "commit approval: REQUIRED — no VAJRA_ALLOW_COMMIT in this launch environment.\n  \
             A human must give an approval token in chat before any commit. For an UNATTENDED \
             run,\n  the founder pre-authorizes at launch: `VAJRA_ALLOW_COMMIT=NN vajra claude`.",
        ),
    }
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
    // S99: an unattended run has no chat channel to utter an approval token, so the packet must
    // say whether the founder pre-authorized commits at launch (the S97 Rung-1 blocker (b)).
    println!(
        "{}",
        render_commit_auth(commit_authorization(
            &current_branch(&root),
            env::var("VAJRA_ALLOW_COMMIT").ok().as_deref(),
        ))
    );
    println!();

    // S104 team voice: the pipeline team's progress on THIS session, in plain English — the SAME
    // role narration `vajra next --stations` uses (one source in `stations`, no second copy). A
    // non-numeric `.ai/SESSION` just skips the roster rather than breaking the packet.
    if let Ok(n) = session.trim().parse::<u32>() {
        let report = stations::station_report(&root, n);
        println!("----- pipeline team (session {n:02}) -----");
        print!("{}", stations::format_team_roster(&report));
        println!(
            "  {} of {} roles have finished their part",
            report.passed(),
            stations::STATION_COUNT
        );
        println!();
    }

    // S112 — the fleet's findings reach the agent that needs them. Before this, a governed handoff
    // was written into `.ai/handoffs/` and read by nobody: the packet (the context an agent boots
    // on) never mentioned it. Now the CURRENT session's handoffs ride the packet, findings inline.
    // Silent when there are none — a session with no fleet work sees the packet it always saw.
    if let Some(n) = current_session(&root) {
        let brief =
            fleet::format_handoff_brief(&fleet::read_handoffs(&root, n), analyst::FLEET_HEAD_LINES);
        if !brief.is_empty() {
            println!("----- fleet handoffs (session {n:02}) -----");
            print!("{brief}");
            println!();
        }
    }

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

    // Advice gate (S127): the pipeline's ANSWERED bookend. Like the Coder gate it binds on the
    // session being CLOSED — the advice was given during `current`, so closing it requires every
    // numbered recommendation in `current`'s governed handoffs to carry a recorded disposition
    // whose evidence is REAL. This is the first gate to consume a governed handoff as a binding
    // input (DECISION-007 S127 addendum lifts the S116 deferral that forbade it).
    //
    // It does NOT enforce obedience. `refused: <reason>` passes. What it makes impossible is the
    // silent drop — the failure that cost S126 twice in its own record.
    let advice_verdict = advice::advice_gate(&root, current);
    for w in &advice_verdict.warnings {
        eprintln!("  ⚠ {w}");
    }
    if advice_verdict.blocked() {
        eprintln!(
            "[vajra advice] session {current:02} cannot close — advice it asked for is unanswered:"
        );
        for r in &advice_verdict.reasons {
            eprintln!("    ✗ {r}");
        }
        if maturity == MaturityLevel::L1 {
            eprintln!("  (L1 advise — advancing anyway.)");
        } else if env::var("VAJRA_SKIP_ADVICE_GATE").is_ok() {
            eprintln!("  (VAJRA_SKIP_ADVICE_GATE set — advancing anyway.)");
        } else {
            bail!(
                "refusing to advance: session {current:02} leaves a recorded recommendation \
                 unanswered (Advice gate). Run `vajra next --advice {current:02}`, record \
                 `- <role> rec N — obeyed: <sha>` / `refused: <reason>` / `deferred: <path>` in \
                 the prompt's `## Advice`, or set VAJRA_SKIP_ADVICE_GATE=1 to override. A reasoned \
                 refusal passes — silence does not."
            );
        }
    }

    // Fidelity gate (S131): the pipeline's MANDATORY-HANDOFF bookend. Like the Advice gate it
    // binds on the session being CLOSED — `current` cannot close without a `fidelity-reviewer`
    // governed handoff whose provenance independently re-verifies against real dispatch evidence.
    // Founder-locked at the S130 closeout: this is the first role made mandatory, chosen because
    // it is the one that "ensure[s] the session complete[s] all acceptance criteria and what it
    // build[s] is actually high quality work — not fake stamping and shortcuts." Unlike every
    // other gate above, absence here is NOT a legacy-compat WARN — a session with no
    // fidelity-reviewer handoff blocks at L2/L3 exactly the same as a fabricated one.
    // `VAJRA_SKIP_FIDELITY_GATE=1` is the documented override (distinct from the others', so each
    // stage overrides alone).
    let fidelity_verdict = fidelity::fidelity_gate(&root, current);
    for w in &fidelity_verdict.warnings {
        eprintln!("  ⚠ {w}");
    }
    if fidelity_verdict.blocked() {
        eprintln!(
            "[vajra fidelity] session {current:02} cannot close — its fidelity-reviewer handoff \
             is missing or unprovable:"
        );
        for r in &fidelity_verdict.reasons {
            eprintln!("    ✗ {r}");
        }
        if maturity == MaturityLevel::L1 {
            eprintln!("  (L1 advise — advancing anyway.)");
        } else if env::var("VAJRA_SKIP_FIDELITY_GATE").is_ok() {
            eprintln!("  (VAJRA_SKIP_FIDELITY_GATE set — advancing anyway.)");
        } else {
            bail!(
                "refusing to advance: session {current:02} has no provable fidelity-reviewer \
                 handoff (Fidelity gate). Dispatch the cold review and run `vajra next --role \
                 fidelity-reviewer --from <findings>`, or set VAJRA_SKIP_FIDELITY_GATE=1 to \
                 override."
            );
        }
    }

    // Mandate gate (S133): the pipeline's CONSULTED bookend. Binds on the session being CLOSED,
    // like every other fleet gate — `current` cannot close without either a real `design-advisor`
    // handoff whose provenance independently re-verifies, or a RECORDED, substantive reason for
    // skipping it. Founder-locked at the S132 closeout: the advisors that could change what gets
    // BUILT were all optional, and optional loses to time pressure every session.
    //
    // The one gate here with NO `VAJRA_SKIP_*` escape, on purpose. Its whole novelty is that the
    // escape hatch leaves a trace: the reason lives in the session's own prompt, where a reader
    // finds it months later and `Review-Inputs-SHA` already hashes it. Two limits, recorded rather
    // than implied — L1 still advises (uniform with every other gate), and `VAJRA_CLOSEOUT_WAIVER`
    // still waives the closeout check, because a founder-held, session-scoped marker the AGENT
    // cannot set is a different animal from an agent-settable skip flag.
    let mandate_verdict = mandate::design_advisor_gate(&root, current);
    if let Some(line) = mandate_verdict.skip_line() {
        eprintln!("  ⚠ [vajra mandate] {line}");
    }
    for w in &mandate_verdict.warnings {
        eprintln!("  ⚠ {w}");
    }
    if mandate_verdict.blocked() {
        eprintln!(
            "[vajra mandate] session {current:02} cannot close — no design-advisor was consulted \
             and no reason for skipping is on the record:"
        );
        for r in &mandate_verdict.reasons {
            eprintln!("    ✗ {r}");
        }
        if maturity == MaturityLevel::L1 {
            eprintln!("  (L1 advise — advancing anyway.)");
        } else {
            bail!(
                "refusing to advance: session {current:02} has neither a provable design-advisor \
                 handoff nor a recorded reason for skipping one (Mandate gate). Dispatch the role \
                 and run `vajra next --role design-advisor --from <findings>`, or record \
                 `design-advisor: skipped — <reason>` in the session's prompt. There is no \
                 environment variable for this one — a skip must leave a trace."
            );
        }
    }

    // Crew gate (S135): the tech-lead's decision, made binding. Like every fleet gate it binds on
    // the session being CLOSED — `current` cannot close without a real, provenance-verified
    // tech-lead handoff, AND every role it marked `required` producing its own real governed
    // handoff. Built as a CALL SITE on `src/mandate` (DECISION-007 S135 addendum). Like the Mandate
    // gate, it has NO `VAJRA_SKIP_*` escape, on purpose: a crew decided by an un-forgeable handoff
    // cannot carry an agent-settable bypass. L1 still advises (uniform with every other gate).
    let crew_verdict = crew::crew_gate(&root, current);
    for w in &crew_verdict.warnings {
        eprintln!("  ⚠ {w}");
    }
    if crew_verdict.blocked() {
        eprintln!(
            "[vajra crew] session {current:02} cannot close — the tech-lead's crew decision is \
             missing, forged, or unsatisfied:"
        );
        for r in &crew_verdict.reasons {
            eprintln!("    ✗ {r}");
        }
        if maturity == MaturityLevel::L1 {
            eprintln!("  (L1 advise — advancing anyway.)");
        } else {
            bail!(
                "refusing to advance: session {current:02} has no binding tech-lead crew decision, \
                 or a role it marked `required` produced no real governed handoff (Crew gate). \
                 Dispatch the tech-lead and run `vajra next --role tech-lead --from <crew>`, then \
                 dispatch every role it marked `required`. There is no environment variable for \
                 this one — the crew decision is provenance-verified, not agent-settable."
            );
        }
    }

    // Obeyed gate (S132): the pipeline's TRUE bookend, one level below the Advice gate. The
    // Advice gate proves each recommendation was ANSWERED; this proves an `obeyed:` answer was
    // JUDGED TRUE by an independent, provenance-verified role. Binds on the session being CLOSED,
    // like the Coder and Advice gates. `VAJRA_SKIP_OBEYED_GATE=1` is the documented override
    // (distinct from the others', so each stage overrides alone).
    let obeyed_verdict = obeyed::obeyed_gate(&root, current);
    for w in &obeyed_verdict.warnings {
        eprintln!("  ⚠ {w}");
    }
    if obeyed_verdict.blocked() {
        eprintln!(
            "[vajra obeyed] session {current:02} cannot close — an `obeyed:` disposition is \
             unjudged, or judged a mismatch:"
        );
        for r in &obeyed_verdict.reasons {
            eprintln!("    ✗ {r}");
        }
        if maturity == MaturityLevel::L1 {
            eprintln!("  (L1 advise — advancing anyway.)");
        } else if env::var("VAJRA_SKIP_OBEYED_GATE").is_ok() {
            eprintln!("  (VAJRA_SKIP_OBEYED_GATE set — advancing anyway.)");
        } else {
            bail!(
                "refusing to advance: session {current:02} records an `obeyed:` disposition no \
                 independent judge has graded true (Obeyed gate). Run `vajra next --check-obeyed \
                 {current:02}`, have an independent role record `obeyed-check <role> rec <N> — \
                 implemented: <sha> — <note>` in its governed handoff, or set \
                 VAJRA_SKIP_OBEYED_GATE=1 to override. A reasoned `refused:` passes — a false \
                 `obeyed:` does not."
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

    /// S99 (AC3): the packet's classification encodes the SAME rule `hook-commit-guard.sh` applies
    /// (session digits from a `session-NN-*` branch; off such a branch any non-empty marker is
    /// accepted) — so the packet can never say "pre-granted" where the guard would block. This
    /// test checks the Rust classification table; LIVE parity against the actual guard script (its
    /// real allow/block exit code under each env) is proven in `scripts/verify-session-99.sh`.
    #[test]
    fn commit_authorization_mirrors_the_guard() {
        // Marker matches the branch-derived session -> the guard ALLOWs.
        assert_eq!(
            commit_authorization("session-99-coder-reachable", Some("99")),
            CommitAuth::PreGranted("99".into())
        );
        // Marker scoped to another session -> the guard BLOCKs; never report pre-granted.
        assert_eq!(
            commit_authorization("session-99-coder-reachable", Some("98")),
            CommitAuth::Mismatch {
                marker: "98".into(),
                session: "99".into()
            }
        );
        // No marker (or an empty one) -> a chat token is the only route.
        assert_eq!(
            commit_authorization("session-99-x", None),
            CommitAuth::TokenRequired
        );
        assert_eq!(
            commit_authorization("session-99-x", Some("")),
            CommitAuth::TokenRequired
        );
        // Off a session branch the guard accepts any non-empty marker — mirror it, don't invent.
        assert_eq!(
            commit_authorization("main", Some("99")),
            CommitAuth::PreGranted("99".into())
        );
        assert_eq!(
            commit_authorization("main", None),
            CommitAuth::TokenRequired
        );
        // A malformed branch is not a session branch.
        assert_eq!(
            commit_authorization("session-abc-x", Some("7")),
            CommitAuth::PreGranted("7".into())
        );
    }

    /// The rendered lines must name the un-forgeable route for an UNATTENDED run, and must
    /// disclose that this surface is advisory rather than a permission.
    #[test]
    fn commit_auth_lines_state_route_and_bound() {
        let granted = render_commit_auth(CommitAuth::PreGranted("99".into()));
        assert!(granted.contains("PRE-GRANTED"));
        assert!(granted.contains("approval token"));
        assert!(
            granted.contains("Advisory"),
            "pre-granted line hides that it is not the enforcing check"
        );

        let required = render_commit_auth(CommitAuth::TokenRequired);
        assert!(required.contains("REQUIRED"));
        assert!(
            required.contains("VAJRA_ALLOW_COMMIT=NN vajra claude"),
            "packet does not tell an unattended run how to be pre-authorized"
        );

        let bad = render_commit_auth(CommitAuth::Mismatch {
            marker: "98".into(),
            session: "99".into(),
        });
        assert!(bad.contains("NOT VALID HERE") && bad.contains("BLOCK"));
    }

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
