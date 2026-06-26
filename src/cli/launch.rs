use crate::budget::{self, BudgetVerdict};
use crate::launcher::{command_exists, merge_hook_settings, TempSettings};
use crate::meter;
use anyhow::{Context, Result};
use std::path::Path;
use std::process::{Command, Stdio};
use std::time::SystemTime;

pub fn run(args: &[String]) -> Result<()> {
    if !command_exists("claude") {
        anyhow::bail!("claude not found in PATH; install Claude Code before using vajra claude")
    }

    let session_start = SystemTime::now();
    let stats_path = std::env::temp_dir().join(format!(
        "vajra-stats-{:x}-{:x}.jsonl",
        std::process::id(),
        session_start
            .duration_since(std::time::UNIX_EPOCH)
            .map(|d| d.as_nanos())
            .unwrap_or(0)
    ));

    let mut command = Command::new("claude");
    command.env("VAJRA_SESSION_STATS", &stats_path);

    match merge_hook_settings().and_then(TempSettings::write) {
        Ok(temp_settings) => {
            if std::env::var("VAJRA_DEBUG").ok().as_deref() == Some("1") {
                eprintln!("[vajra] temp settings: {}", temp_settings.path().display());
                if let Ok(content) = std::fs::read_to_string(temp_settings.path()) {
                    eprintln!("[vajra] temp settings content:\n{content}");
                }
            }
            command
                .arg("--settings")
                .arg(temp_settings.path())
                .args(args);
            wait_and_meter(command, Some(temp_settings), session_start, &stats_path)
        }
        Err(e) => {
            eprintln!("[vajra] warning: settings injection failed; running bare claude ({e})");
            command.args(args);
            wait_and_meter(command, None, session_start, &stats_path)
        }
    }
}

fn wait_and_meter(
    mut command: Command,
    temp_settings: Option<TempSettings>,
    session_start: SystemTime,
    stats_path: &Path,
) -> Result<()> {
    let mut child = command
        .stdin(Stdio::inherit())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .spawn()
        .context("failed to spawn claude")?;
    let status = child.wait();
    std::mem::drop(temp_settings);
    let status = status.context("failed to wait on claude")?;

    let session_cost = if std::env::var("VAJRA_QUIET").ok().as_deref() != Some("1") {
        print_receipt(session_start, stats_path)
    } else {
        None
    };

    let _ = std::fs::remove_file(stats_path);

    if !status.success() {
        std::process::exit(status.code().unwrap_or(1));
    }

    if let Some(cost) = session_cost {
        check_budget_cap(cost)?;
    }

    Ok(())
}

fn check_budget_cap(session_cost: f64) -> Result<()> {
    let constraints_path = std::env::current_dir()
        .ok()
        .map(|d| d.join(".ai/CONSTRAINTS.yaml"));
    let config = constraints_path
        .as_deref()
        .and_then(budget::read_budget_config);

    match budget::check_budget(config.as_ref(), session_cost) {
        BudgetVerdict::OverBudget { spent, cap, kill } => {
            eprint!("{}", budget::format_budget_warning(spent, cap, kill));
            if kill {
                std::process::exit(2);
            }
        }
        BudgetVerdict::UnderBudget | BudgetVerdict::NoCap => {}
    }
    Ok(())
}

fn print_receipt(session_start: SystemTime, stats_path: &Path) -> Option<f64> {
    let compression_stats = meter::read_compression_stats(stats_path);

    let jsonl = match meter::find_session_jsonl(session_start) {
        Some(j) => j,
        None => {
            if let Some(ref stats) = compression_stats {
                eprintln!(
                    "\n[vajra] {} lines folded across {} tool calls (JSONL not found for cost)",
                    stats.lines_folded, stats.calls_compressed
                );
            }
            return None;
        }
    };

    match meter::meter_session(&jsonl.0, jsonl.1.as_deref(), compression_stats) {
        Ok(cost) => {
            let total = cost.total_dollars;
            eprint!("\n{}", meter::format_receipt(&cost));
            Some(total)
        }
        Err(e) => {
            eprintln!("\n[vajra] meter error: {e}");
            None
        }
    }
}
