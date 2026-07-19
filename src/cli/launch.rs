use crate::budget::{self, BudgetVerdict};
use crate::launcher::{command_exists, merge_hook_settings, TempSettings};
use crate::meter;
use anyhow::{Context, Result};
use std::io::{Read, Write};
use std::path::Path;
use std::process::{ChildStdout, Command, Stdio};
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

    // A headless `-p`/`--print` run emits the SDK-authoritative cost on its terminal
    // `type:"result"` stdout line (S78); only these runs are tee-captured. Interactive runs have
    // no result stream and must keep an inherited TTY — piping one would break its UI.
    let headless = is_headless(args);

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
            wait_and_meter(
                command,
                Some(temp_settings),
                session_start,
                &stats_path,
                headless,
            )
        }
        Err(e) => {
            eprintln!("[vajra] warning: settings injection failed; running bare claude ({e})");
            command.args(args);
            wait_and_meter(command, None, session_start, &stats_path, headless)
        }
    }
}

/// A headless `claude -p`/`--print` invocation runs non-interactively and (with
/// `--output-format json|stream-json`) emits a terminal `type:"result"` line carrying the
/// SDK-authoritative `total_cost_usd` — the figure the on-disk transcript never has (S77/S78).
/// Interactive runs (no `-p`) have no such stream. Detection is a plain arg scan; text-mode `-p`
/// (no `--output-format`) is still headless but simply carries no result line, so capture yields
/// nothing and S77's honest fallback stands.
fn is_headless(args: &[String]) -> bool {
    args.iter().any(|a| a == "-p" || a == "--print")
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
    headless: bool,
) -> Result<()> {
    command
        .stdin(Stdio::inherit())
        .stderr(Stdio::inherit())
        // Headless: pipe stdout so we can tee + scan it for the tool's own `total_cost_usd`
        // (S78). Interactive: inherit the TTY unchanged (piping would break the UI).
        .stdout(if headless {
            Stdio::piped()
        } else {
            Stdio::inherit()
        });

    let mut child = command.spawn().context("failed to spawn claude")?;

    // On headless runs, drain the child's stdout to EOF — streaming every byte straight through to
    // our own stdout (never swallowed, criterion 3) while keeping a copy to scan afterwards. stderr
    // is inherited (not piped), so there is no second pipe to deadlock against. Read-to-EOF happens
    // before `wait()`: the child closes stdout at exit, then we reap.
    let captured_cost = if headless {
        child
            .stdout
            .take()
            .map(tee_and_capture)
            .and_then(|buf| meter::extract_result_cost(&buf))
    } else {
        None
    };

    let status = child.wait();
    std::mem::drop(temp_settings);
    let status = status.context("failed to wait on claude")?;

    let session_cost = if std::env::var("VAJRA_QUIET").ok().as_deref() != Some("1") {
        print_receipt(session_start, stats_path, captured_cost)
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

/// `captured_cost` is the authoritative `total_cost_usd` teed from a headless run's result stream
/// (S78), or `None` for interactive/text-mode runs. When present it supersedes the transcript's
/// absent figure (the transcript never carries one — S77), so the receipt headline becomes the
/// real bill instead of "no authoritative cost available".
fn print_receipt(
    session_start: SystemTime,
    stats_path: &Path,
    captured_cost: Option<f64>,
) -> Option<f64> {
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
            // No transcript to meter, but a headless run may still have teed its own cost — report
            // it rather than dropping the one authoritative figure we have (S78).
            return captured_cost;
        }
    };

    match meter::meter_session(&jsonl.0, jsonl.1.as_deref(), compression_stats) {
        Ok(mut cost) => {
            // Feed the tool's own end-of-session cost into the S66 authoritative path before we
            // read/format anything (so the headline, budget, and warnings all agree) — S78.
            cost.apply_captured_cost(captured_cost);
            // Budget against the authoritative charge when known (transcript or captured stream),
            // else the estimate — never the inflated token recompute of an unknown model (S66).
            let total = cost.billed_dollars();
            eprint!("\n{}", meter::format_receipt(&cost));
            Some(total)
        }
        Err(e) => {
            eprintln!("\n[vajra] meter error: {e}");
            captured_cost
        }
    }
}

/// Drain `out` to EOF, streaming every byte straight to our stdout (the user sees the agent's own
/// output untouched — criterion 3) while returning a full copy for cost extraction (S78). Byte-for
/// byte: no line reassembly, no re-encoding, so text/json/stream-json all pass through verbatim.
fn tee_and_capture(mut out: ChildStdout) -> Vec<u8> {
    let mut buf = Vec::new();
    let mut chunk = [0u8; 8192];
    let stdout = std::io::stdout();
    let mut handle = stdout.lock();
    loop {
        match out.read(&mut chunk) {
            Ok(0) => break,
            Ok(n) => {
                let _ = handle.write_all(&chunk[..n]);
                let _ = handle.flush();
                buf.extend_from_slice(&chunk[..n]);
            }
            Err(_) => break,
        }
    }
    buf
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
    fn is_headless_detects_print_flags_only() {
        assert!(is_headless(&["-p".into(), "do a thing".into()]));
        assert!(is_headless(&["--print".into()]));
        assert!(is_headless(&[
            "-p".into(),
            "x".into(),
            "--output-format".into(),
            "stream-json".into()
        ]));
        // Interactive launches (no -p/--print) must NOT be tee-captured — the TTY stays inherited.
        assert!(!is_headless(&[]));
        assert!(!is_headless(&["--model".into(), "opus".into()]));
        assert!(!is_headless(&["--dangerously-skip-permissions".into()]));
        // A -p buried in a value string is not the flag (exact-token match, no substring).
        assert!(!is_headless(&[
            "--append-system-prompt".into(),
            "keep -p short".into()
        ]));
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
