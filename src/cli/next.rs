use anyhow::{bail, Context, Result};
use std::env;
use std::fs;
use std::io::{self, BufRead, Write as _};
use std::path::{Path, PathBuf};
use std::process::Command;

use crate::analyst;
use crate::maturity::{read_maturity, MaturityLevel};

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
    if args.iter().any(|a| a == "--intake") {
        return run_intake();
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
