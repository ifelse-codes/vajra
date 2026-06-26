use anyhow::{bail, Context, Result};
use std::env;
use std::fs;
use std::io::{self, BufRead, Write as _};
use std::path::{Path, PathBuf};
use std::process::Command;

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
    let advance = args.iter().any(|a| a == "--advance");

    if advance {
        run_advance()
    } else {
        run_dump()
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
