use crate::approval;
use crate::budget::{self, BudgetVerdict};
use crate::launcher::{command_exists, merge_hook_settings, TempSettings};
use crate::meter;
use anyhow::{Context, Result};
use std::io::{Read, Write};
use std::path::Path;
use std::process::{ChildStdout, Command, Stdio};
use std::time::SystemTime;

pub fn run(args: &[String]) -> Result<()> {
    // S181 Part 4 — the founder's launch-time yes. `--allow-all` is Vajra's own flag (stripped; Claude
    // Code never sees it) and `VAJRA_APPROVE=NN` is the same yes for one session. Both are honoured
    // ONLY when this launcher is not itself running under an agent (a marked env): an agent that runs
    // `vajra claude --allow-all` gets a refusal, not an approval.
    // S182 Part 5 (DECISION-011 S182 addendum): `--allow-all=NN` names the ONE session it approves,
    // like every other founder control (`vajra approve NN`, `VAJRA_APPROVE=NN`,
    // `VAJRA_ALLOW_COMMIT=NN`). Not the branch name — the agent usually types that, and `main` has none.
    let allow_all_arg = args
        .iter()
        .find(|a| *a == "--allow-all" || a.starts_with("--allow-all="))
        .cloned();
    let allow_all = allow_all_arg.is_some();
    let args: Vec<String> = args
        .iter()
        .filter(|a| *a != "--allow-all" && !a.starts_with("--allow-all="))
        .cloned()
        .collect();
    let args = args.as_slice();
    let launch_approve = std::env::var("VAJRA_APPROVE")
        .ok()
        .filter(|v| !v.trim().is_empty());
    if approval::is_marked() && (allow_all || launch_approve.is_some()) {
        anyhow::bail!(
            "refused: --allow-all / VAJRA_APPROVE at launch are the founder's, set from their own \
             terminal. This process was started by Vajra for an agent (VAJRA_AGENT_MARK is set)."
        )
    }
    let allow_all_session: Option<u32> = match allow_all_arg.as_deref() {
        None => None,
        Some(a) => match a
            .strip_prefix("--allow-all=")
            .map(|v| v.trim().parse::<u32>())
        {
            Some(Ok(n)) => Some(n),
            _ => anyhow::bail!(
                "refused: --allow-all needs the session it approves, e.g. `vajra claude \
                 --allow-all=182`. It approves that one session only, while this launch runs \
                 (S182). Nothing was started."
            ),
        },
    };
    let root = std::env::current_dir()?;
    if let Some(v) = &launch_approve {
        let n: u32 = v
            .trim()
            .parse()
            .map_err(|_| anyhow::anyhow!("VAJRA_APPROVE must be a session number, got '{v}'"))?;
        let p = approval::record_launch_env(&root, n)?;
        eprintln!(
            "[vajra] approval for session {n} recorded at launch (human chose at start): {}",
            p.display()
        );
    }
    if let Some(n) = allow_all_session {
        let p = approval::record_allow_all(&root, n, std::process::id())?;
        eprintln!("[vajra] --allow-all={n} recorded (human chose at start; session {n} only, live only while this launch runs): {}", p.display());
    }
    let result = run_launch(args);
    if allow_all {
        approval::clear_allow_all(&root);
    }
    result
}

fn run_launch(args: &[String]) -> Result<()> {
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
    // S181 Part 4: mark everything the agent will start, and do not hand it the founder's launch yes.
    command.env(approval::AGENT_MARK, "1");
    command.env_remove("VAJRA_APPROVE");
    // S181 Part 5: remember what was waived AT LAUNCH, from the founder's own terminal, so the close
    // gate can tell a launch-time waiver from one set later in the session. A marked launcher (an
    // agent running `vajra claude`) records nothing.
    match std::env::var("VAJRA_WAIVE") {
        Ok(w) if !w.trim().is_empty() && !approval::is_marked() => {
            command.env("VAJRA_LAUNCH_WAIVE", w);
        }
        _ => {
            command.env_remove("VAJRA_LAUNCH_WAIVE");
        }
    }

    // A headless `-p`/`--print` run emits the SDK-authoritative cost on its terminal
    // `type:"result"` stdout line (S78); only these runs are tee-captured. Interactive runs have
    // no result stream and must keep an inherited TTY — piping one would break its UI.
    let headless = is_headless(args);

    // Headless Claude Code has no approval channel: every Write/Edit/Bash call is silently
    // denied unless the launch already carries a permission decision (S76 dogfood run 1 burned a
    // paid call against exactly this wall). Advisory only — never blocks, never mutates `args`.
    if should_warn_readonly_headless(args) {
        eprintln!("{}", READONLY_HEADLESS_WARNING);
    }

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

const READONLY_HEADLESS_WARNING: &str =
    "[vajra] warning: headless run with no permission-mode flag — \
Claude Code has no approval channel, so every Write/Edit/Bash call will be silently denied.\n  \
Fix: pass --dangerously-skip-permissions or --permission-mode <mode>.\n  \
(A read-only probe is fine if that's what you intended — this warning is advisory only.)";

/// A headless run with no permission decision on argv is about to hit the silent read-only wall
/// (S76). Exact-token scan, same style as `is_headless`/`has_permission_flag` — no substring
/// false-positives. Interactive runs never warn: the TTY is its own approval channel.
fn should_warn_readonly_headless(args: &[String]) -> bool {
    is_headless(args) && !has_permission_flag(args)
}

/// `true` if the launch already carries a permission decision — either flag is accepted as-is;
/// vajra does not second-guess which mode the user chose.
fn has_permission_flag(args: &[String]) -> bool {
    args.iter()
        .any(|a| a == "--dangerously-skip-permissions" || a == "--permission-mode")
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
        let cost = print_receipt(session_start, stats_path, captured_cost);
        // S194 (F121): the close check's verdict, from Vajra — not from the agent's summary.
        // Printed even when the cost could not be read.
        let closeout = project_root().join(".ai/verify/closeout");
        eprintln!(
            " {}",
            read_close_check(&closeout, &utc_stamp(session_start)).line()
        );
        cost
    } else {
        None
    };

    let _ = std::fs::remove_file(stats_path);

    if !status.success() {
        std::process::exit(status.code().unwrap_or(1));
    }

    if let Some((cost, estimated)) = session_cost {
        check_budget_cap(cost, estimated)?;
    }

    Ok(())
}

// ── S194 (F121): the close check at exit ─────────────────────────────────────────────────────
// rudra S20's close check went RED (5 fail) and only the agent saw it; it told the founder "fully
// closed" and he merged on that word. `verify-closeout.sh` now writes one fixed-format `result`
// file into its run folder; the exit box reads only that file — never the screen text, the
// per-check logs or the transcript (ADR-0004 S194 addendum). Named, not closed: it shows the
// truth, it does not stop an agent claiming otherwise; the agent could write the file itself.

/// What the close check said during this run.
#[derive(Debug, PartialEq)]
enum CloseCheck {
    NotRun,
    NoResult {
        stamp: String,
    },
    Unreadable {
        stamp: String,
    },
    Green {
        pass: u32,
        warn: u32,
        stamp: String,
    },
    Red {
        pass: u32,
        fail: u32,
        failed: Vec<String>,
        stamp: String,
    },
}

impl CloseCheck {
    fn line(&self) -> String {
        let folder = |stamp: &str| format!(".ai/verify/closeout/{stamp}");
        match self {
            CloseCheck::NotRun => "close check: not run during this run".to_string(),
            CloseCheck::NoResult { stamp } => format!(
                "close check: started {} but wrote no result (a focused mode such as --fidelity-only, \
                 it stopped early, or the project's script is older — run `vajra init --sync-fleet`) · {}",
                stamp_time(stamp),
                folder(stamp)
            ),
            CloseCheck::Unreadable { stamp } => format!(
                "close check: result unreadable — not counted as GREEN · {}/result",
                folder(stamp)
            ),
            CloseCheck::Green {
                pass,
                warn: 0,
                stamp,
            } => {
                format!("close check: GREEN — {pass} passed · {}", folder(stamp))
            }
            CloseCheck::Green { pass, warn, stamp } => format!(
                "close check: GREEN with {warn} WARN — {pass} passed; read the WARN rows · {}",
                folder(stamp)
            ),
            CloseCheck::Red {
                pass,
                fail,
                failed,
                stamp,
            } => format!(
                "close check: RED — {fail} of {} failed ({}) · {}",
                pass + fail,
                failed.join(", "),
                folder(stamp)
            ),
        }
    }
}

/// A run folder's name: `%Y%m%dT%H%M%SZ`, fixed width, so names compare as times.
fn is_run_stamp(name: &str) -> bool {
    let b = name.as_bytes();
    b.len() == 16
        && b[8] == b'T'
        && b[15] == b'Z'
        && b[..8].iter().chain(&b[9..15]).all(u8::is_ascii_digit)
}

/// "HH:MM:SSZ" out of a run stamp.
fn stamp_time(stamp: &str) -> String {
    format!("{}:{}:{}Z", &stamp[9..11], &stamp[11..13], &stamp[13..15])
}

/// `t` as a run stamp, UTC (civil-from-days; no date dependency).
fn utc_stamp(t: SystemTime) -> String {
    let secs = t
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_secs() as i64)
        .unwrap_or(0);
    let (days, rem) = (secs.div_euclid(86_400), secs.rem_euclid(86_400));
    let z = days + 719_468;
    let era = z.div_euclid(146_097);
    let doe = z - era * 146_097;
    let yoe = (doe - doe / 1460 + doe / 36_524 - doe / 146_096) / 365;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let d = doy - (153 * mp + 2) / 5 + 1;
    let m = if mp < 10 { mp + 3 } else { mp - 9 };
    let y = yoe + era * 400 + i64::from(m <= 2);
    format!(
        "{y:04}{m:02}{d:02}T{:02}{:02}{:02}Z",
        rem / 3600,
        rem % 3600 / 60,
        rem % 60
    )
}

/// The newest run folder stamped at or after `since` is this run's close check.
/// The close check's verdict for this run, plus — when newer run folders wrote no result — the
/// newest of them, so a later partial run is named instead of hiding the verdict.
#[derive(Debug, PartialEq)]
struct CloseReport {
    check: CloseCheck,
    later_without_result: Option<String>,
}

impl CloseReport {
    fn line(&self) -> String {
        match &self.later_without_result {
            None => self.check.line(),
            Some(later) => format!(
                "{} · a later run at {} wrote no result (a focused mode such as --fidelity-only, \
                 or it stopped early)",
                self.check.line(),
                stamp_time(later)
            ),
        }
    }
}

/// The newest run folder stamped at or after `since` that WROTE a result is this run's verdict.
/// Review rec 1 (S194): every focused mode (`--fidelity-only`, `--attest-only`, …) makes a dated
/// folder and exits before the result is written, so "the newest folder" alone let a later
/// partial run hide a full run's RED behind "wrote no result".
fn read_close_check(closeout_dir: &Path, since: &str) -> CloseReport {
    let mut stamps: Vec<String> = std::fs::read_dir(closeout_dir)
        .into_iter()
        .flatten()
        .flatten()
        .filter(|e| e.path().is_dir())
        .filter_map(|e| e.file_name().into_string().ok())
        .filter(|n| is_run_stamp(n) && n.as_str() >= since)
        .collect();
    stamps.sort_unstable_by(|a, b| b.cmp(a));
    let Some(newest) = stamps.first().cloned() else {
        return CloseReport {
            check: CloseCheck::NotRun,
            later_without_result: None,
        };
    };
    for stamp in &stamps {
        if let Ok(text) = std::fs::read_to_string(closeout_dir.join(stamp).join("result")) {
            let check =
                parse_close_result(&text, stamp.clone()).unwrap_or(CloseCheck::Unreadable {
                    stamp: stamp.clone(),
                });
            return CloseReport {
                check,
                later_without_result: (*stamp != newest).then_some(newest),
            };
        }
    }
    CloseReport {
        check: CloseCheck::NoResult { stamp: newest },
        later_without_result: None,
    }
}

/// The result file, exactly as verify-closeout.sh writes it — anything else is unreadable, and
/// unreadable is never GREEN.
fn parse_close_result(text: &str, stamp: String) -> Option<CloseCheck> {
    // S196 review rec 4: as strict as the push belt's reader — `lines()` would hide a `\r`, and
    // `u32::from_str` would take `+5`.
    if text.contains('\r') {
        return None;
    }
    let num = |v: String| -> Option<u32> {
        if v.is_empty() || !v.bytes().all(|b| b.is_ascii_digit()) {
            return None;
        }
        v.parse().ok()
    };
    let mut lines = text.lines();
    // `key: value`, or a bare `key:` for an empty value (`failed:` on a GREEN run).
    let mut field = |key: &str| {
        let line = lines.next()?.strip_prefix(key)?;
        match line.strip_prefix(": ") {
            Some(v) => Some(v.to_string()),
            None if line == ":" => Some(String::new()),
            None => None,
        }
    };
    // S196 (F127): format 2 adds `head:` + `clean:` after `session:` for the push belt
    // (.githooks/pre-push, the file's second reader). Both formats read; any other is unreadable.
    let version = field("vajra-closeout-result")?;
    if version != "1" && version != "2" {
        return None;
    }
    let _session = field("session")?;
    if version == "2" {
        let head = field("head")?;
        let hex = |n: usize| {
            head.len() == n
                && head
                    .bytes()
                    .all(|b| b.is_ascii_digit() || (b'a'..=b'f').contains(&b))
        };
        if !(hex(40) || hex(64) || head == "none") {
            return None;
        }
        if !matches!(field("clean")?.as_str(), "yes" | "no") {
            return None;
        }
    }
    let verdict = field("verdict")?;
    let pass: u32 = num(field("pass")?)?;
    let fail: u32 = num(field("fail")?)?;
    let warn: u32 = num(field("warn")?)?;
    let failed: Vec<String> = field("failed")?
        .split_whitespace()
        .map(str::to_string)
        .collect();
    if lines.next().is_some() {
        return None;
    }
    match verdict.as_str() {
        "GREEN" if fail == 0 && failed.is_empty() => Some(CloseCheck::Green { pass, warn, stamp }),
        "RED" if fail > 0 && failed.len() == fail as usize => Some(CloseCheck::Red {
            pass,
            fail,
            failed,
            stamp,
        }),
        _ => None,
    }
}

/// The project the run was launched in: git's top level, else the launch folder.
fn project_root() -> std::path::PathBuf {
    Command::new("git")
        .args(["rev-parse", "--show-toplevel"])
        .output()
        .ok()
        .filter(|o| o.status.success())
        .and_then(|o| String::from_utf8(o.stdout).ok())
        .map(|s| std::path::PathBuf::from(s.trim()))
        .filter(|p| !p.as_os_str().is_empty())
        .or_else(|| std::env::current_dir().ok())
        .unwrap_or_default()
}

/// `estimated`: Claude Code gave no figure, so `session_cost` is Vajra's token estimate (S189).
fn check_budget_cap(session_cost: f64, estimated: bool) -> Result<()> {
    let constraints_path = std::env::current_dir()
        .ok()
        .map(|d| d.join(".ai/CONSTRAINTS.yaml"));
    let config = constraints_path
        .as_deref()
        .and_then(budget::read_budget_config);

    match budget::check_budget(config.as_ref(), session_cost) {
        BudgetVerdict::OverBudget { spent, cap, kill } => {
            if estimated {
                eprint!(
                    "{}",
                    budget::format_budget_estimate_warning(spent, cap, kill)
                );
            } else {
                eprint!("{}", budget::format_budget_warning(spent, cap, kill));
            }
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
/// real bill instead of the no-cost headline; for an interactive run the meter reads Claude Code's own
/// `cost-state` record instead (S189).
fn print_receipt(
    session_start: SystemTime,
    stats_path: &Path,
    captured_cost: Option<f64>,
) -> Option<(f64, bool)> {
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
            return captured_cost.map(|c| (c, false));
        }
    };

    // The launch time lets the meter cut Claude Code's own running total to this run's share (S189).
    match meter::meter_run(
        &jsonl.0,
        jsonl.1.as_deref(),
        compression_stats,
        Some(session_start),
    ) {
        Ok(mut cost) => {
            // Feed the tool's own end-of-session cost into the S66 authoritative path before we
            // read/format anything (so the headline, budget, and warnings all agree) — S78.
            cost.apply_captured_cost(captured_cost);
            // Budget against the tool's own figure when known; else the estimate, said as one (S189).
            let total = cost.billed_dollars();
            eprint!("\n{}", meter::format_receipt(&cost));
            Some((total, cost.headline_dollars().is_none()))
        }
        Err(e) => {
            eprintln!("\n[vajra] meter error: {e}");
            captured_cost.map(|c| (c, false))
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
    fn has_permission_flag_detects_either_flag_exact_token() {
        assert!(has_permission_flag(&[
            "--dangerously-skip-permissions".into()
        ]));
        assert!(has_permission_flag(&[
            "--permission-mode".into(),
            "acceptEdits".into()
        ]));
        assert!(!has_permission_flag(&[]));
        assert!(!has_permission_flag(&["-p".into(), "do a thing".into()]));
        // Exact-token match, no substring: a flag name buried in a value string doesn't count.
        assert!(!has_permission_flag(&[
            "--append-system-prompt".into(),
            "use --permission-mode wisely".into()
        ]));
    }

    #[test]
    fn should_warn_readonly_headless_matrix() {
        // AC1: headless + no permission flag -> warn.
        assert!(should_warn_readonly_headless(&[
            "-p".into(),
            "do a thing".into()
        ]));
        // AC2: headless + --dangerously-skip-permissions -> no warn.
        assert!(!should_warn_readonly_headless(&[
            "-p".into(),
            "x".into(),
            "--dangerously-skip-permissions".into()
        ]));
        // AC3: headless + --permission-mode <anything> -> no warn (vajra doesn't judge the mode).
        assert!(!should_warn_readonly_headless(&[
            "--print".into(),
            "--permission-mode".into(),
            "plan".into()
        ]));
        // AC4: interactive (no -p/--print) -> never warn, regardless of permission flags.
        assert!(!should_warn_readonly_headless(&[]));
        assert!(!should_warn_readonly_headless(&[
            "--model".into(),
            "opus".into()
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

    // ── S194 (F121): the close check at exit ──────────────────────────────────────────────

    const RED_RESULT: &str = "vajra-closeout-result: 1\nsession: 20\nverdict: RED\npass: 17\nfail: 5\nwarn: 0\nfailed: fidelity-review-accept three-next-options fidelity-handoff demo-passes-live required-crew\n";
    const GREEN_RESULT: &str = "vajra-closeout-result: 1\nsession: 20\nverdict: GREEN\npass: 22\nfail: 0\nwarn: 0\nfailed: \n";

    // S196 (F127): format 2, as both close scripts now write it.
    const GREEN_V2: &str = "vajra-closeout-result: 2\nsession: 196\nhead: 59719f8e0c1d2b3a4f5e6d7c8b9a0f1e2d3c4b5a\nclean: yes\nverdict: GREEN\npass: 30\nfail: 0\nwarn: 1\nfailed: \n";

    #[test]
    fn s196_a_format_2_result_is_read_like_format_1() {
        let d = tempfile::tempdir().unwrap();
        run_folder(d.path(), "20261014T120000Z", Some(GREEN_V2));
        assert_eq!(
            read_close_check(d.path(), "20261014T110000Z").check,
            CloseCheck::Green {
                pass: 30,
                warn: 1,
                stamp: "20261014T120000Z".into()
            }
        );
        let red = RED_RESULT.replace(
            "vajra-closeout-result: 1\nsession: 20\n",
            "vajra-closeout-result: 2\nsession: 20\nhead: none\nclean: no\n",
        );
        run_folder(d.path(), "20261014T130000Z", Some(&red));
        assert!(matches!(
            read_close_check(d.path(), "20261014T110000Z").check,
            CloseCheck::Red { fail: 5, .. }
        ));
    }

    /// The push belt's own reader (`read_result` in .githooks/pre-push), run by bash on one file:
    /// true when it reads the file as a well-formed format-2 result.
    fn hook_reads(file: &Path) -> bool {
        let hook = Path::new(env!("CARGO_MANIFEST_DIR")).join(".githooks/pre-push");
        let script = format!(
            "eval \"$(sed -n '/^read_result() {{/,/^}}/p' '{}')\"; read_result \"$1\"",
            hook.display()
        );
        Command::new("bash")
            .args(["-c", &script, "_"])
            .arg(file)
            .status()
            .expect("bash runs")
            .success()
    }

    #[test]
    fn s196_the_push_belt_and_the_exit_box_agree_on_every_format_2_result() {
        // Design-advisor rec 5: two readers of one file must not drift. Format 1 is the exit box's
        // alone (it has no head, so the belt never matches it) and is left out.
        let red = RED_RESULT.replace(
            "vajra-closeout-result: 1\nsession: 20\n",
            "vajra-closeout-result: 2\nsession: 20\nhead: none\nclean: no\n",
        );
        let cases = [
            GREEN_V2.to_string(),
            red.clone(),
            format!("{GREEN_V2}extra: line\n"),
            GREEN_V2.replace("fail: 0", "fail: 1"),
            red.replace("fail: 5", "fail: 4"),
            GREEN_V2.replace("head: ", "head: 12"),
            GREEN_V2.replace("head: 59719f8e", "head: 59719F8E"),
            GREEN_V2.replace("clean: yes", "clean: maybe"),
            GREEN_V2.replace("clean: yes\n", ""),
            GREEN_V2.replace("verdict: GREEN", "verdict: PASSED"),
            GREEN_V2.replace("pass: 30", "pass: lots"),
            GREEN_V2.replace("vajra-closeout-result: 2", "vajra-closeout-result: 3"),
            GREEN_V2.replace("pass: 30", "pass: +30"),
            GREEN_V2.replace('\n', "\r\n"),
            String::new(),
        ];
        let mut readable = 0;
        for (i, text) in cases.iter().enumerate() {
            let d = tempfile::tempdir().unwrap();
            run_folder(d.path(), "20261014T120000Z", Some(text));
            let binary = !matches!(
                read_close_check(d.path(), "20261014T110000Z").check,
                CloseCheck::Unreadable { .. }
            );
            let hook = hook_reads(&d.path().join("20261014T120000Z/result"));
            assert_eq!(
                binary, hook,
                "case {i}: exit box {binary}, push belt {hook}:\n{text}"
            );
            readable += usize::from(binary);
        }
        assert_eq!(readable, 2, "exactly the GREEN and the RED read");
    }

    fn run_folder(dir: &Path, stamp: &str, result: Option<&str>) {
        fs::create_dir_all(dir.join(stamp)).unwrap();
        if let Some(r) = result {
            fs::write(dir.join(stamp).join("result"), r).unwrap();
        }
    }

    #[test]
    fn s194_utc_stamp_matches_the_close_scripts_folder_names() {
        let t = std::time::UNIX_EPOCH + std::time::Duration::from_secs(1_791_777_212);
        assert_eq!(utc_stamp(t), "20261012T035332Z");
        assert_eq!(utc_stamp(std::time::UNIX_EPOCH), "19700101T000000Z");
        assert!(is_run_stamp("20261012T035332Z"));
        assert!(!is_run_stamp("latest") && !is_run_stamp("20261012T035332"));
    }

    #[test]
    fn s194_a_red_close_check_after_launch_is_shown_with_its_failed_names() {
        let d = tempfile::tempdir().unwrap();
        run_folder(d.path(), "20261012T035332Z", Some(RED_RESULT));
        let line = read_close_check(d.path(), "20261012T030000Z").line();
        assert_eq!(
            line,
            "close check: RED — 5 of 22 failed (fidelity-review-accept, three-next-options, \
             fidelity-handoff, demo-passes-live, required-crew) · .ai/verify/closeout/20261012T035332Z"
        );
    }

    #[test]
    fn s194_a_close_check_from_before_launch_is_not_this_runs() {
        let d = tempfile::tempdir().unwrap();
        run_folder(d.path(), "20261011T120000Z", Some(GREEN_RESULT));
        assert_eq!(
            read_close_check(d.path(), "20261012T030000Z").check,
            CloseCheck::NotRun
        );
        assert_eq!(
            read_close_check(&d.path().join("missing"), "20261012T030000Z").line(),
            "close check: not run during this run"
        );
    }

    #[test]
    fn s194_a_run_with_no_result_file_is_not_green() {
        let d = tempfile::tempdir().unwrap();
        run_folder(d.path(), "20261012T035332Z", None);
        let line = read_close_check(d.path(), "20261012T030000Z").line();
        assert!(
            line.starts_with("close check: started 03:53:32Z but wrote no result"),
            "{line}"
        );
        assert!(line.contains("vajra init --sync-fleet"), "{line}");
    }

    #[test]
    fn s194_a_result_that_does_not_parse_exactly_is_unreadable_never_green() {
        for bad in [
            GREEN_RESULT.replace("verdict: GREEN", "verdict: PASSED"),
            GREEN_RESULT.replace("fail: 0\n", ""),
            GREEN_RESULT.replace("pass: 22", "pass: lots"),
            GREEN_RESULT.replace("vajra-closeout-result: 1", "vajra-closeout-result: 3"),
            GREEN_V2.replace("head: ", "head: 12"),
            GREEN_V2.replace("clean: yes", "clean: maybe"),
            GREEN_V2.replace("clean: yes\n", ""),
            GREEN_RESULT.replace("fail: 0", "fail: 1"),
            RED_RESULT.replace("fail: 5", "fail: 4"),
            format!("{GREEN_RESULT}extra: line\n"),
            String::new(),
        ] {
            let d = tempfile::tempdir().unwrap();
            run_folder(d.path(), "20261012T035332Z", Some(&bad));
            let got = read_close_check(d.path(), "20261012T030000Z").check;
            assert_eq!(
                got,
                CloseCheck::Unreadable {
                    stamp: "20261012T035332Z".into()
                },
                "{bad:?}"
            );
            assert!(got.line().contains("not counted as GREEN"));
        }
    }

    #[test]
    fn s194_the_newest_close_check_of_this_run_wins() {
        let d = tempfile::tempdir().unwrap();
        run_folder(d.path(), "20261012T035332Z", Some(RED_RESULT));
        run_folder(d.path(), "20261012T040500Z", Some(GREEN_RESULT));
        assert_eq!(
            read_close_check(d.path(), "20261012T030000Z").line(),
            "close check: GREEN — 22 passed · .ai/verify/closeout/20261012T040500Z"
        );
        let warned = GREEN_RESULT.replace("warn: 0", "warn: 2");
        run_folder(d.path(), "20261012T041000Z", Some(&warned));
        assert!(read_close_check(d.path(), "20261012T030000Z")
            .line()
            .starts_with("close check: GREEN with 2 WARN"));
    }

    #[test]
    fn s194_a_later_partial_run_does_not_hide_the_red() {
        // Review rec 1: a full RED close, then `--fidelity-only` in a later second (a folder, no result).
        let d = tempfile::tempdir().unwrap();
        run_folder(d.path(), "20261012T035332Z", Some(RED_RESULT));
        run_folder(d.path(), "20261012T035340Z", None);
        let r = read_close_check(d.path(), "20261012T030000Z");
        assert!(matches!(r.check, CloseCheck::Red { fail: 5, .. }), "{r:?}");
        let line = r.line();
        assert!(
            line.starts_with("close check: RED — 5 of 22 failed"),
            "{line}"
        );
        assert!(
            line.ends_with("a later run at 03:53:40Z wrote no result (a focused mode such as --fidelity-only, or it stopped early)"),
            "{line}"
        );
        // A later FULL run that wrote a result still wins, with no note.
        run_folder(d.path(), "20261012T035400Z", Some(GREEN_RESULT));
        let r = read_close_check(d.path(), "20261012T030000Z");
        assert_eq!(r.later_without_result, None);
        assert!(r.line().starts_with("close check: GREEN — 22 passed"));
    }
}
