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
    preflight_auth_check()?;

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

/// Fail fast if Claude Code has no credentials (S34, gap noted S18): an unauthenticated
/// launch otherwise surfaces as a confusing failure deep inside the session. Presence-only
/// evidence — never a paid API call. Layers, cheapest first:
///   1. `ANTHROPIC_API_KEY` in the environment
///   2. `~/.claude/.credentials.json` (Linux) / `oauthAccount` in `~/.claude.json`
///   3. macOS Keychain entry `Claude Code-credentials`
///
/// `VAJRA_SKIP_AUTH_CHECK=1` bypasses (escape hatch for storage layouts we don't know).
fn preflight_auth_check() -> Result<()> {
    if std::env::var("VAJRA_SKIP_AUTH_CHECK").ok().as_deref() == Some("1") {
        return Ok(());
    }
    let api_key = std::env::var("ANTHROPIC_API_KEY").ok();
    let home = std::env::var_os("HOME").map(std::path::PathBuf::from);
    if auth_evidence(api_key.as_deref(), home.as_deref()) || keychain_has_credentials() {
        return Ok(());
    }
    anyhow::bail!(
        "no Claude Code credentials found — authenticate before launching:\n  \
         run `claude` once and complete /login, or set ANTHROPIC_API_KEY.\n  \
         (Bypass this pre-check with VAJRA_SKIP_AUTH_CHECK=1.)"
    )
}

fn auth_evidence(api_key: Option<&str>, home: Option<&Path>) -> bool {
    if api_key.is_some_and(|k| !k.trim().is_empty()) {
        return true;
    }
    let Some(home) = home else { return false };
    if home.join(".claude/.credentials.json").exists() {
        return true;
    }
    // After OAuth login, `~/.claude.json` records the account even where the token
    // itself lives elsewhere (e.g. macOS Keychain).
    std::fs::read_to_string(home.join(".claude.json")).is_ok_and(|s| s.contains("\"oauthAccount\""))
}

fn keychain_has_credentials() -> bool {
    if !cfg!(target_os = "macos") {
        return false;
    }
    Command::new("security")
        .args(["find-generic-password", "-s", "Claude Code-credentials"])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .is_ok_and(|s| s.success())
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
            // Budget against the authoritative charge when the JSONL carried it, else the
            // estimate — never the inflated token recompute of an unknown model (S66).
            let total = cost.billed_dollars();
            eprint!("\n{}", meter::format_receipt(&cost));
            Some(total)
        }
        Err(e) => {
            eprintln!("\n[vajra] meter error: {e}");
            None
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    #[test]
    fn auth_evidence_accepts_api_key() {
        assert!(auth_evidence(Some("sk-ant-xxx"), None));
        assert!(
            !auth_evidence(Some("   "), None),
            "blank key is no evidence"
        );
        assert!(!auth_evidence(None, None));
    }

    #[test]
    fn auth_evidence_accepts_credentials_file() {
        let home = tempfile::tempdir().unwrap();
        assert!(!auth_evidence(None, Some(home.path())));
        fs::create_dir_all(home.path().join(".claude")).unwrap();
        fs::write(home.path().join(".claude/.credentials.json"), "{}").unwrap();
        assert!(auth_evidence(None, Some(home.path())));
    }

    #[test]
    fn auth_evidence_accepts_oauth_account_marker() {
        let home = tempfile::tempdir().unwrap();
        fs::write(home.path().join(".claude.json"), r#"{"numStartups":3}"#).unwrap();
        assert!(
            !auth_evidence(None, Some(home.path())),
            "a claude.json without oauthAccount is no evidence"
        );
        fs::write(
            home.path().join(".claude.json"),
            r#"{"oauthAccount":{"emailAddress":"x@y.z"}}"#,
        )
        .unwrap();
        assert!(auth_evidence(None, Some(home.path())));
    }
}
