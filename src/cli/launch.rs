use crate::budget::{self, BudgetVerdict};
use crate::fleet;
use crate::launcher::{command_exists, merge_hook_settings, TempSettings};
use crate::meter;
use anyhow::{Context, Result};
use std::io::{Read, Write};
use std::path::Path;
use std::process::{ChildStdout, Command, Stdio};
use std::time::SystemTime;

pub fn run(args: &[String]) -> Result<()> {
    // S109 fleet slice 1 (DECISION-007): `vajra claude --role <name>` dispatches a named agent as a
    // GOVERNED STEP that writes a delta-tracked handoff — not the plain interactive/headless
    // passthrough below. `--role` is consumed by vajra (stripped before the agent sees argv), so it
    // rides `vajra claude` and adds no 8th top-level command.
    if let Some((role, rest)) = extract_role(args) {
        return dispatch_role(&role, &rest);
    }

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

// ─── fleet slice 1 — named-role dispatch (S109, DECISION-007) ──────────────────────────────────

/// Pull `--role <name>` out of the args: `Some((name, remaining))` with the flag AND its value
/// removed, else `None`. Exact-token match (same no-substring discipline as `is_headless`). A
/// trailing `--role` with no value yields an empty name — dispatch then fails closed on the unknown
/// empty role, never silently.
fn extract_role(args: &[String]) -> Option<(String, Vec<String>)> {
    let idx = args.iter().position(|a| a == "--role")?;
    let name = args.get(idx + 1).cloned().unwrap_or_default();
    let mut rest: Vec<String> = Vec::with_capacity(args.len().saturating_sub(2));
    rest.extend_from_slice(&args[..idx]);
    rest.extend_from_slice(&args[(idx + 2).min(args.len())..]);
    Some((name, rest))
}

/// The task a role investigates — the `-p`/`--print` value. A role dispatch requires one (there is
/// nothing to research otherwise). `None` when `-p` is absent or has no value (→ fail closed).
fn extract_task(args: &[String]) -> Option<String> {
    let idx = args.iter().position(|a| a == "-p" || a == "--print")?;
    args.get(idx + 1).filter(|v| !v.starts_with('-')).cloned()
}

/// Is the agent command runnable? A path (`contains('/')`) must exist on disk; a bare name must be
/// on `PATH`. Fail-closed input to dispatch (DECISION-007: a missing agent command blocks).
fn agent_available(cmd: &str) -> bool {
    if cmd.contains('/') {
        Path::new(cmd).exists()
    } else {
        command_exists(cmd)
    }
}

/// The `agent:` frontmatter value — the command's basename, marked when it is the injected stub so
/// a handoff records honestly whether it came from a real paid agent or the paid-free stub path.
fn agent_label(agent_cmd: &str, is_stub: bool) -> String {
    let base = Path::new(agent_cmd)
        .file_name()
        .and_then(|s| s.to_str())
        .unwrap_or(agent_cmd);
    if is_stub {
        format!("{base} (stub via VAJRA_AGENT_CMD)")
    } else {
        base.to_string()
    }
}

/// The CURRENT session number for the handoff path. Prefer the active branch (`session-NN-...`):
/// it names the session in flight even before closeout flips `.ai/SESSION` from the prior number
/// to N. Fall back to `.ai/SESSION` (detached HEAD / non-session branch).
fn read_session(root: &Path) -> Option<u32> {
    if let Some(n) = current_branch_session(root) {
        return Some(n);
    }
    std::fs::read_to_string(root.join(".ai/SESSION"))
        .ok()?
        .trim()
        .parse()
        .ok()
}

/// Parse `NN` out of the active `session-NN-<slug>` branch, or `None` off such a branch.
fn current_branch_session(root: &Path) -> Option<u32> {
    let out = Command::new("git")
        .args(["rev-parse", "--abbrev-ref", "HEAD"])
        .current_dir(root)
        .output()
        .ok()?;
    if !out.status.success() {
        return None;
    }
    let branch = String::from_utf8_lossy(&out.stdout);
    let rest = branch.trim().strip_prefix("session-")?;
    let digits: String = rest.chars().take_while(|c| c.is_ascii_digit()).collect();
    digits.parse().ok()
}

/// A UTC ISO-8601 timestamp for the handoff's `captured` field. Shells out to `date` (no chrono
/// dep, matching this crate's zero-extra-dependency posture); falls back to `unix:<secs>`.
fn utc_timestamp() -> String {
    if let Ok(out) = Command::new("date")
        .args(["-u", "+%Y-%m-%dT%H:%M:%SZ"])
        .output()
    {
        if out.status.success() {
            if let Ok(s) = String::from_utf8(out.stdout) {
                let t = s.trim();
                if !t.is_empty() {
                    return t.to_string();
                }
            }
        }
    }
    let secs = SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0);
    format!("unix:{secs}")
}

/// Dispatch one named fleet role as a governed step (DECISION-007): resolve the role, run the agent
/// (real `claude` or the injected stub) with the role-scoped system prompt, capture its result, and
/// write a delta-tracked handoff to `.ai/handoffs/`. Fails closed on: unknown role · missing task ·
/// missing agent command · unparseable/empty result · a handoff that would not validate.
fn dispatch_role(role_name: &str, rest: &[String]) -> Result<()> {
    // 1. Resolve the role — fail closed on unknown (vajra never scopes a role it doesn't know).
    let role = fleet::resolve_role(role_name).ok_or_else(|| {
        anyhow::anyhow!(
            "unknown role `{role_name}` — known roles: {}. \
             (fleet slice 1 ships only the Researcher; a new role is a separate decision, DECISION-007.)",
            fleet::known_roles()
        )
    })?;

    // 2. The task the role investigates comes from -p; a role dispatch needs one.
    let task = extract_task(rest).ok_or_else(|| {
        anyhow::anyhow!(
            "role dispatch needs a task — pass it with -p: \
             `vajra claude --role {role_name} -p \"<question>\"`"
        )
    })?;

    // 3. Resolve the agent command. Default `claude`; VAJRA_AGENT_CMD overrides it — that is the
    //    stub path CI + the fail-closed gate use (a gate must never depend on a paid call). Fail
    //    closed if the resolved command is missing.
    let env_cmd = std::env::var("VAJRA_AGENT_CMD")
        .ok()
        .filter(|c| !c.is_empty());
    let is_stub = env_cmd.is_some();
    let agent_cmd = env_cmd.unwrap_or_else(|| "claude".to_string());
    if !agent_available(&agent_cmd) {
        anyhow::bail!(
            "agent command `{agent_cmd}` not found — install it, or set VAJRA_AGENT_CMD to a real command"
        );
    }
    // Only the real `claude` agent gets the credentials pre-check; a stub carries its own behaviour.
    if !is_stub {
        preflight_auth_check()?;
    }

    // 4. Build the agent argv: the passthrough args (carry `-p <task>` + any --model etc.) plus the
    //    role's system prompt and a json result stream so the S78 tee captures the real cost.
    let mut agent_args: Vec<String> = rest.to_vec();
    agent_args.push("--append-system-prompt".into());
    agent_args.push(role.system_prompt.to_string());
    if !rest.iter().any(|a| a == "--output-format") {
        agent_args.push("--output-format".into());
        agent_args.push("json".into());
    }

    // 5. Spawn, tee stdout (S78 — the user still sees the agent's own output), capture for parsing.
    let mut command = Command::new(&agent_cmd);
    command
        .args(&agent_args)
        .stdin(Stdio::inherit())
        .stderr(Stdio::inherit())
        .stdout(Stdio::piped());
    let mut child = command
        .spawn()
        .with_context(|| format!("failed to spawn agent `{agent_cmd}`"))?;
    let captured = child.stdout.take().map(tee_and_capture).unwrap_or_default();
    let status = child.wait().context("failed to wait on agent")?;
    if !status.success() {
        anyhow::bail!("agent `{agent_cmd}` exited {}", status.code().unwrap_or(-1));
    }

    // 6. Parse the result — fail closed on an unparseable/empty result: a failed dispatch must never
    //    write a silent empty handoff.
    let result = fleet::parse_agent_result(&captured).ok_or_else(|| {
        anyhow::anyhow!("agent produced no parseable result — handoff NOT written (fail closed)")
    })?;

    // 7. Write the governed, delta-tracked handoff into the `.ai/` spine.
    let root = std::env::current_dir().context("no current dir")?;
    let session = read_session(&root).ok_or_else(|| {
        anyhow::anyhow!(
            "cannot read .ai/SESSION — a role dispatch needs a session (run `vajra init`)"
        )
    })?;
    let handoff_rel = role.handoff_rel(session);
    let handoff_path = root.join(&handoff_rel);
    if let Some(parent) = handoff_path.parent() {
        std::fs::create_dir_all(parent).with_context(|| format!("mkdir {}", parent.display()))?;
    }
    let prior_body = std::fs::read_to_string(&handoff_path)
        .ok()
        .and_then(|p| fleet::handoff_body(&p));
    let source_sha = fleet::sha256_hex(fleet::role_scoped_input(role, &task).as_bytes())
        .unwrap_or_else(|| "unavailable".to_string());
    let delta = fleet::compute_delta(prior_body.as_deref(), &result.body);
    let handoff = fleet::format_handoff(
        role,
        session,
        &agent_label(&agent_cmd, is_stub),
        &source_sha,
        &utc_timestamp(),
        result.cost,
        &result.body,
        &delta,
    );
    // Belt-and-suspenders: never persist a handoff that would fail the fail-closed check.
    fleet::validate_handoff(&handoff)
        .map_err(|e| anyhow::anyhow!("refusing to write malformed handoff: {e}"))?;
    std::fs::write(&handoff_path, &handoff)
        .with_context(|| format!("write {}", handoff_path.display()))?;

    // 8. Confirm + receipt.
    eprintln!("\n[vajra] {} handoff → {handoff_rel}", role.name);
    match result.cost {
        Some(c) => eprintln!(
            "[vajra] {} call cost: ${c:.6} (authoritative — S78)",
            role.name
        ),
        None => eprintln!(
            "[vajra] {} call cost: no authoritative figure (S77 honest null)",
            role.name
        ),
    }
    // Post-hoc budget cap: a one-shot's cost is known only after it runs, so the run-time control is
    // that this fires ONLY on an explicit `--role` call (never CI — the stub path is paid-free).
    if let Some(c) = result.cost {
        check_budget_cap(c)?;
    }
    Ok(())
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
    fn extract_role_strips_flag_and_value() {
        // Flag + value removed; the rest (incl. -p and its value) survives in order.
        let (name, rest) = extract_role(&[
            "--role".into(),
            "researcher".into(),
            "-p".into(),
            "what is X".into(),
        ])
        .expect("role present");
        assert_eq!(name, "researcher");
        assert_eq!(rest, vec!["-p".to_string(), "what is X".to_string()]);

        // --role in the middle: args on both sides survive.
        let (name, rest) = extract_role(&[
            "-p".into(),
            "q".into(),
            "--role".into(),
            "researcher".into(),
            "--model".into(),
            "opus".into(),
        ])
        .unwrap();
        assert_eq!(name, "researcher");
        assert_eq!(rest, vec!["-p", "q", "--model", "opus"]);

        // No --role → None (plain passthrough launch, unchanged).
        assert!(extract_role(&["-p".into(), "hi".into()]).is_none());

        // Trailing --role with no value → empty name (dispatch then fails closed on unknown role).
        let (name, rest) = extract_role(&["-p".into(), "q".into(), "--role".into()]).unwrap();
        assert_eq!(name, "");
        assert_eq!(rest, vec!["-p", "q"]);
    }

    #[test]
    fn extract_task_reads_p_value_or_fails_closed() {
        assert_eq!(
            extract_task(&["-p".into(), "the question".into()]).as_deref(),
            Some("the question")
        );
        assert_eq!(
            extract_task(&["--print".into(), "q2".into()]).as_deref(),
            Some("q2")
        );
        // No -p → None (a role dispatch needs a task).
        assert!(extract_task(&["--model".into(), "opus".into()]).is_none());
        // -p with no value (next token is a flag) → None, not a swallowed flag.
        assert!(extract_task(&["-p".into(), "--model".into()]).is_none());
        // -p at end with nothing after → None.
        assert!(extract_task(&["-p".into()]).is_none());
    }

    #[test]
    fn agent_label_marks_stub_and_basenames_path() {
        assert_eq!(agent_label("claude", false), "claude");
        assert_eq!(
            agent_label("/tmp/x/stub.sh", true),
            "stub.sh (stub via VAJRA_AGENT_CMD)"
        );
        assert_eq!(
            agent_label("myagent", true),
            "myagent (stub via VAJRA_AGENT_CMD)"
        );
    }

    #[test]
    fn agent_available_checks_path_for_absolute_missing_paths() {
        // A path that does not exist → not available (fail-closed input to dispatch).
        assert!(!agent_available("/no/such/agent/binary/here"));
        // A real absolute path (this repo's Cargo.toml stands in for any existing file) → available.
        let manifest = env!("CARGO_MANIFEST_DIR");
        assert!(agent_available(&format!("{manifest}/Cargo.toml")));
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
