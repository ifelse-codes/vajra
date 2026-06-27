use anyhow::{Context, Result};
use std::env;
use std::fs;
use std::path::{Path, PathBuf};

use crate::budget;
use crate::meter;

const CONTEXT_FILES: &[&str] = &[
    ".ai/AGENTS.md",
    ".ai/SESSION",
    ".ai/SESSION-BOOT.md",
    ".ai/TASK.md",
    ".ai/STATE.md",
    ".ai/CONSTRAINTS.yaml",
    ".ai/KNOWLEDGE.md",
    ".ai/ROADMAP.md",
];

const CHARS_PER_TOKEN: f64 = 4.0;
const OUTPUT_INPUT_RATIO: f64 = 3.0;
const DEFAULT_MODEL: &str = "claude-opus-4";

pub fn run() -> Result<()> {
    let cwd = env::current_dir().context("failed to read current directory")?;
    let root =
        find_repo_root(&cwd).context("could not find a Vajra repo (.ai directory missing)")?;

    let _session =
        fs::read_to_string(root.join(".ai/SESSION")).context("failed to read .ai/SESSION")?;

    let prompt_path = find_prompt(&root);

    let mut total_chars: u64 = 0;
    let mut files_read: Vec<(String, u64)> = Vec::new();

    for relative in CONTEXT_FILES {
        let path = root.join(relative);
        if let Ok(content) = fs::read_to_string(&path) {
            let chars = content.len() as u64;
            total_chars += chars;
            files_read.push((relative.to_string(), chars));
        }
    }

    if root.join("VISION.md").is_file() {
        if let Ok(content) = fs::read_to_string(root.join("VISION.md")) {
            let chars = content.len() as u64;
            total_chars += chars;
            files_read.push(("VISION.md".to_string(), chars));
        }
    }

    if let Some(ref relative) = prompt_path {
        let path = root.join(relative);
        if let Ok(content) = fs::read_to_string(&path) {
            let chars = content.len() as u64;
            total_chars += chars;
            files_read.push((relative.clone(), chars));
        }
    }

    let input_tokens = (total_chars as f64 / CHARS_PER_TOKEN) as u64;
    let output_tokens = (input_tokens as f64 * OUTPUT_INPUT_RATIO) as u64;
    let (input_price, output_price) = meter::pricing_for(DEFAULT_MODEL);
    let input_cost = input_tokens as f64 * input_price / 1_000_000.0;
    let output_cost = output_tokens as f64 * output_price / 1_000_000.0;
    let total_cost = input_cost + output_cost;

    println!(
        "Estimated session cost: ~${:.2} ({:.1}k input + {:.1}k output tokens)",
        total_cost,
        input_tokens as f64 / 1000.0,
        output_tokens as f64 / 1000.0,
    );
    println!(
        "  input  ${:.4} ({} tokens @ ${:.0}/MTok)",
        input_cost, input_tokens, input_price
    );
    println!(
        "  output ${:.4} ({} tokens @ ${:.0}/MTok, est. {}:1 ratio)",
        output_cost, output_tokens, output_price, OUTPUT_INPUT_RATIO as u32
    );
    println!(
        "  context: {} files, {} chars",
        files_read.len(),
        total_chars
    );

    let budget_config = budget::read_budget_config(&root.join(".ai/CONSTRAINTS.yaml"));
    if let Some(ref config) = budget_config {
        if total_cost > config.cap_usd {
            eprintln!(
                "[vajra warn] estimate ${:.2} exceeds budget cap ${:.2}",
                total_cost, config.cap_usd
            );
        } else {
            let remaining = config.cap_usd - total_cost;
            println!(
                "  budget: ${:.2} cap, ~${:.2} remaining after this session",
                config.cap_usd, remaining
            );
        }
    }

    Ok(())
}

fn find_repo_root(start: &Path) -> Option<PathBuf> {
    start
        .ancestors()
        .find(|dir| dir.join(".ai").is_dir())
        .map(Path::to_path_buf)
}

fn find_prompt(root: &Path) -> Option<String> {
    let task = fs::read_to_string(root.join(".ai/TASK.md")).ok()?;
    extract_prompt_path(&task).or_else(|| {
        let boot = fs::read_to_string(root.join(".ai/SESSION-BOOT.md")).ok()?;
        extract_prompt_path(&boot)
    })
}

fn extract_prompt_path(content: &str) -> Option<String> {
    content.lines().find_map(|line| {
        if !line.to_ascii_lowercase().contains("read prompt") {
            return None;
        }
        let start = line.find('`')?;
        let tail = &line[start + 1..];
        let end = tail.find('`')?;
        Some(tail[..end].to_string())
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn token_estimate_from_chars() {
        let chars: u64 = 40000;
        let tokens = (chars as f64 / CHARS_PER_TOKEN) as u64;
        assert_eq!(tokens, 10000);
    }

    #[test]
    fn output_estimate_uses_ratio() {
        let input: u64 = 10000;
        let output = (input as f64 * OUTPUT_INPUT_RATIO) as u64;
        assert_eq!(output, 30000);
    }

    #[test]
    fn cost_calculation_matches_hand_math() {
        let input_tokens: u64 = 10000;
        let output_tokens: u64 = 30000;
        let (input_price, output_price) = meter::pricing_for(DEFAULT_MODEL);
        let input_cost = input_tokens as f64 * input_price / 1_000_000.0;
        let output_cost = output_tokens as f64 * output_price / 1_000_000.0;
        let total = input_cost + output_cost;

        // opus: input $15/MTok, output $75/MTok
        // 10k * 15 / 1M = 0.15
        // 30k * 75 / 1M = 2.25
        // total = 2.40
        assert!((total - 2.40).abs() < 0.001, "got {total}, expected 2.40");
    }

    #[test]
    fn extract_prompt_finds_backticked_path() {
        let content = "Read prompt: `prompts/17-task-pre-run-cost-estimate.md`\n";
        assert_eq!(
            extract_prompt_path(content),
            Some("prompts/17-task-pre-run-cost-estimate.md".to_string())
        );
    }

    #[test]
    fn extract_prompt_returns_none_for_no_match() {
        assert_eq!(extract_prompt_path("no prompt here"), None);
    }

    #[test]
    fn find_repo_root_finds_ai_dir() {
        let tmp = tempfile::tempdir().unwrap();
        let ai = tmp.path().join(".ai");
        std::fs::create_dir_all(&ai).unwrap();
        let sub = tmp.path().join("deep/nested");
        std::fs::create_dir_all(&sub).unwrap();

        assert_eq!(find_repo_root(&sub), Some(tmp.path().to_path_buf()));
    }

    #[test]
    fn run_on_scaffolded_repo() {
        let tmp = tempfile::tempdir().unwrap();
        let ai = tmp.path().join(".ai");
        std::fs::create_dir_all(&ai).unwrap();
        std::fs::write(ai.join("SESSION"), "17\n").unwrap();
        std::fs::write(
            ai.join("TASK.md"),
            "Read prompt: `prompts/17-task-test.md`\n",
        )
        .unwrap();
        std::fs::write(ai.join("AGENTS.md"), "# Agents\nTest content here.\n").unwrap();
        std::fs::write(ai.join("STATE.md"), "# State\n").unwrap();
        std::fs::write(
            ai.join("CONSTRAINTS.yaml"),
            "version: 3\nbudget:\n  cap_usd: 5.00\n  mode: warn\n",
        )
        .unwrap();

        let prompts = tmp.path().join("prompts");
        std::fs::create_dir_all(&prompts).unwrap();
        std::fs::write(
            prompts.join("17-task-test.md"),
            "# Session 17\nDo something.\n",
        )
        .unwrap();

        // Run from the temp dir
        let original = std::env::current_dir().unwrap();
        std::env::set_current_dir(tmp.path()).unwrap();
        let result = run();
        std::env::set_current_dir(original).unwrap();

        assert!(result.is_ok());
    }
}
