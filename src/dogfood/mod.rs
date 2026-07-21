//! S91 (C) — live dogfood-staleness query: `vajra next --dogfood-age`.
//!
//! The S90 GT found that STATE.md's "19+ days since S76 (2026-07-03)" had used S36's date
//! instead of S76's real date (2026-07-18). The "19+ days" figure survived 3 GTs because the
//! date was read from a hand-maintained doc, not derived from git. This module computes dogfood
//! staleness from two sources that CANNOT silently drift:
//!
//! 1. `sessions/session-NN-artifacts/` directory presence — committed to git, so the session
//!    number is git-immutable. A full `vajra claude` dogfood run (not a smoke test) is identified
//!    by the presence of `receipt.stderr.txt` or `vajra-receipt.txt` (the S76/S63 naming pattern;
//!    smoke-test artifacts use the `live-*` prefix and are excluded).
//!
//! 2. The git commit date for those artifacts — derived from `git log` at query time, never read
//!    from STATE.md. A wrong STATE.md date cannot propagate here.
//!
//! Cost is an optional bonus: if `run-result.json` exists and carries `total_cost_usd`, it is
//! reported. Sessions where cost was not captured (S76, pre-S78 fix) still COUNT — the receipt
//! file is sufficient evidence; cost is purely informational.

use std::fs;
use std::path::Path;
use std::process::Command;

/// The result of the live dogfood-staleness scan.
#[derive(Debug, Clone)]
pub struct DogfoodAgeReport {
    /// Session number of the last detected real dogfood run.
    pub session: u32,
    /// ISO-format date string derived from git log (never from STATE.md).
    pub date: Option<String>,
    /// `current_session − session` — how many sessions have elapsed.
    pub sessions_since: u32,
    /// Calendar days since the dogfood date (today − date). `None` when `date` is unparseable.
    pub calendar_days: Option<i64>,
    /// Authoritative cost from `run-result.json`, when available.
    pub cost_usd: Option<f64>,
    /// Which receipt file evidenced the run (for the report's "source" line).
    pub receipt_file: String,
}

/// Scan `sessions/session-NN-artifacts/` directories and return the staleness report for the most
/// recent real dogfood session, or `None` when no dogfood run has been recorded.
///
/// "Real dogfood" = the artifacts dir carries `receipt.stderr.txt` OR `vajra-receipt.txt`
/// (the S76/S63 full-run receipt naming). Smoke-test runs use `live-receipt.stderr.txt` and are
/// intentionally excluded so a two-turn haiku smoke test doesn't mask a stale real dogfood.
pub fn dogfood_age(root: &Path, current_session: u32) -> Option<DogfoodAgeReport> {
    let sessions_dir = root.join("sessions");
    let mut best: Option<(u32, String)> = None; // (session_nn, receipt_filename)

    let entries = fs::read_dir(&sessions_dir).ok()?;
    for entry in entries.flatten() {
        let name = entry.file_name().to_string_lossy().to_string();
        // Only `session-NN-artifacts/` directories.
        let Some(nn) = parse_artifacts_session(&name) else {
            continue;
        };
        let dir = entry.path();
        if !dir.is_dir() {
            continue;
        }
        // Check for a full-run receipt file (not the `live-*` smoke-test pattern).
        let receipt = ["receipt.stderr.txt", "vajra-receipt.txt"]
            .iter()
            .find(|f| dir.join(f).is_file())
            .map(|s| s.to_string());
        let Some(receipt_file) = receipt else {
            continue;
        };
        // Keep the highest-numbered session with a receipt.
        if best.as_ref().map_or(true, |(best_nn, _)| nn > *best_nn) {
            best = Some((nn, receipt_file));
        }
    }

    let (session, receipt_file) = best?;
    let artifact_dir = format!("sessions/session-{session:02}-artifacts");

    // Git date: when was this artifact first committed? Use the earliest commit that touched the dir.
    let date = git_first_date(root, &artifact_dir);

    // Optional cost: parse from run-result.json if the file exists.
    let cost_usd = parse_cost_json(root, session);

    let sessions_since = current_session.saturating_sub(session);
    let calendar_days = date.as_deref().and_then(iso_days_ago);

    Some(DogfoodAgeReport {
        session,
        date,
        sessions_since,
        calendar_days,
        cost_usd,
        receipt_file,
    })
}

/// Render the dogfood age report for `vajra next --dogfood-age`.
pub fn format_dogfood_age(current_session: u32, report: Option<&DogfoodAgeReport>) -> String {
    let mut out = String::new();
    out.push_str("=== dogfood age (derived from git — not from STATE.md) ===\n");
    match report {
        None => {
            out.push_str(
                "  no dogfood run detected in sessions/session-NN-artifacts/\n\
                   (looked for receipt.stderr.txt or vajra-receipt.txt in each artifacts dir)\n",
            );
        }
        Some(r) => {
            out.push_str(&format!("  last dogfood session : {:02}\n", r.session));
            out.push_str(&format!(
                "  date (git-derived)   : {}\n",
                r.date.as_deref().unwrap_or("<unresolvable from git log>")
            ));
            if let Some(cost) = r.cost_usd {
                out.push_str(&format!("  cost (authoritative) : ${cost:.4}\n"));
            } else {
                out.push_str(
                    "  cost                 : not captured (pre-S78 fix or non-headless run)\n",
                );
            }
            out.push_str(&format!("  receipt file         : {}\n", r.receipt_file));
            out.push_str(&format!(
                "  sessions since       : {} (S{:02} → current S{:02})\n",
                r.sessions_since, r.session, current_session
            ));
            out.push_str(&format!(
                "  calendar days since  : {}\n",
                r.calendar_days
                    .map(|d| format!("{d} day(s)"))
                    .as_deref()
                    .unwrap_or("<unresolvable from git date>")
            ));
        }
    }
    out
}

// ---- Helpers ---------------------------------------------------------------------------------

/// Parse `session-NN-artifacts` → `NN` (as `u32`). Returns `None` on any mismatch.
fn parse_artifacts_session(name: &str) -> Option<u32> {
    let inner = name.strip_prefix("session-")?.strip_suffix("-artifacts")?;
    inner.parse().ok()
}

/// Get the date of the first git commit that touched `path` (relative to `root`).
/// Returns an ISO-8601 date string (`YYYY-MM-DD`), or `None` when git is unavailable or the
/// path has no history.
fn git_first_date(root: &Path, rel: &str) -> Option<String> {
    let out = Command::new("git")
        .args(["log", "--follow", "--format=%ai", "--diff-filter=A", "--", rel])
        .current_dir(root)
        .output()
        .ok()?;
    if !out.status.success() {
        return None;
    }
    // `--diff-filter=A` only shows the ADD commit; take the first (latest if there are multiple).
    // We want the earliest commit, so take the last line.
    let stdout = String::from_utf8_lossy(&out.stdout);
    let last_line = stdout.lines().last()?.trim();
    if last_line.is_empty() {
        return None;
    }
    // ISO date is the first 10 chars of an "%ai" line like "2026-07-18 16:39:35 +0530".
    Some(last_line[..10.min(last_line.len())].to_string())
}

/// Try to parse `total_cost_usd` from `sessions/session-NN-artifacts/run-result.json`.
/// Returns `None` when the file is absent or does not carry the key.
fn parse_cost_json(root: &Path, session: u32) -> Option<f64> {
    let path = root.join(format!(
        "sessions/session-{session:02}-artifacts/run-result.json"
    ));
    let text = fs::read_to_string(&path).ok()?;
    // Simple key scan: find `"total_cost_usd":` followed by a float.  No full JSON parser
    // needed — the field is always a bare number in the one place we write it.
    let key = "\"total_cost_usd\":";
    let idx = text.find(key)?;
    let after = text[idx + key.len()..].trim_start();
    // Read the number until a non-numeric character.
    let end = after
        .find(|c: char| !c.is_ascii_digit() && c != '.')
        .unwrap_or(after.len());
    after[..end].parse().ok().filter(|&v: &f64| v > 0.0)
}

/// Compute how many calendar days ago an ISO date string (`YYYY-MM-DD`) was, relative to today.
/// Uses a simple integer arithmetic day-count — no external crates.
fn iso_days_ago(date: &str) -> Option<i64> {
    let today = today_ymd()?;
    let then = parse_ymd(date)?;
    Some(days_since(then, today))
}

fn today_ymd() -> Option<(i32, u32, u32)> {
    let out = Command::new("date").arg("+%Y-%m-%d").output().ok()?;
    parse_ymd(String::from_utf8_lossy(&out.stdout).trim())
}

fn parse_ymd(s: &str) -> Option<(i32, u32, u32)> {
    let s = s.trim();
    if s.len() < 10 {
        return None;
    }
    let y: i32 = s[..4].parse().ok()?;
    let m: u32 = s[5..7].parse().ok()?;
    let d: u32 = s[8..10].parse().ok()?;
    Some((y, m, d))
}

/// Julian Day Number for a Gregorian date — cheap integer arithmetic, no chrono dependency.
fn jdn(y: i32, m: u32, d: u32) -> i64 {
    let m = m as i64;
    let d = d as i64;
    let y = y as i64;
    (1461 * (y + 4800 + (m - 14) / 12)) / 4
        + (367 * (m - 2 - 12 * ((m - 14) / 12))) / 12
        - (3 * ((y + 4900 + (m - 14) / 12) / 100)) / 4
        + d
        - 32075
}

fn days_since(from: (i32, u32, u32), to: (i32, u32, u32)) -> i64 {
    jdn(to.0, to.1, to.2) - jdn(from.0, from.1, from.2)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::fs;

    fn write_artifacts(root: &Path, nn: u32, receipt: &str, cost_json: Option<f64>) {
        let dir = root.join(format!("sessions/session-{nn:02}-artifacts"));
        fs::create_dir_all(&dir).unwrap();
        fs::write(dir.join(receipt), format!("─── vajra receipt for s{nn} ───\n")).unwrap();
        if let Some(cost) = cost_json {
            fs::write(
                dir.join("run-result.json"),
                format!(r#"{{"total_cost_usd":{cost},"type":"result"}}"#),
            )
            .unwrap();
        }
    }

    #[test]
    fn parse_artifacts_session_extracts_nn() {
        assert_eq!(parse_artifacts_session("session-63-artifacts"), Some(63));
        assert_eq!(parse_artifacts_session("session-07-artifacts"), Some(7));
        assert_eq!(parse_artifacts_session("session-63-summary.md"), None);
        assert_eq!(parse_artifacts_session("session-63-artifacts-extra"), None);
    }

    #[test]
    fn parse_cost_json_reads_total_cost_usd() {
        let tmp = tempfile::tempdir().unwrap();
        let root = tmp.path();
        let dir = root.join("sessions/session-63-artifacts");
        fs::create_dir_all(&dir).unwrap();
        fs::write(
            dir.join("run-result.json"),
            r#"{"type":"result","total_cost_usd":1.2662,"usage":{}}"#,
        )
        .unwrap();
        assert_eq!(parse_cost_json(root, 63), Some(1.2662));
        assert_eq!(parse_cost_json(root, 64), None); // no file for s64
    }

    #[test]
    fn parse_cost_json_ignores_zero_cost() {
        let tmp = tempfile::tempdir().unwrap();
        let root = tmp.path();
        let dir = root.join("sessions/session-01-artifacts");
        fs::create_dir_all(&dir).unwrap();
        fs::write(dir.join("run-result.json"), r#"{"total_cost_usd":0.0}"#).unwrap();
        assert_eq!(parse_cost_json(root, 1), None);
    }

    #[test]
    fn dogfood_age_returns_none_when_no_artifacts() {
        let tmp = tempfile::tempdir().unwrap();
        fs::create_dir_all(tmp.path().join("sessions")).unwrap();
        assert!(dogfood_age(tmp.path(), 90).is_none());
    }

    #[test]
    fn dogfood_age_ignores_smoke_test_live_prefix() {
        let tmp = tempfile::tempdir().unwrap();
        let root = tmp.path();
        // A `live-receipt.stderr.txt` file (smoke test pattern) must NOT count.
        let dir = root.join("sessions/session-78-artifacts");
        fs::create_dir_all(&dir).unwrap();
        fs::write(dir.join("live-receipt.stderr.txt"), "smoke test receipt\n").unwrap();
        assert!(
            dogfood_age(root, 90).is_none(),
            "live-receipt.stderr.txt must not count as a real dogfood"
        );
    }

    #[test]
    fn dogfood_age_picks_highest_session_with_receipt() {
        let tmp = tempfile::tempdir().unwrap();
        let root = tmp.path();
        fs::create_dir_all(root.join("sessions")).unwrap();
        // S63: vajra-receipt.txt + cost JSON.
        write_artifacts(root, 63, "vajra-receipt.txt", Some(1.2662));
        // S76: receipt.stderr.txt, no cost JSON (pre-S78).
        write_artifacts(root, 76, "receipt.stderr.txt", None);
        // S78: live-receipt.stderr.txt only (smoke test — must be excluded).
        let dir78 = root.join("sessions/session-78-artifacts");
        fs::create_dir_all(&dir78).unwrap();
        fs::write(dir78.join("live-receipt.stderr.txt"), "smoke\n").unwrap();

        let report = dogfood_age(root, 90).expect("should find a dogfood run");
        // Must pick S76 (highest with a qualifying receipt), not S78 (excluded) or S63.
        assert_eq!(report.session, 76);
        assert_eq!(report.cost_usd, None); // S76 has no run-result.json
        assert_eq!(report.sessions_since, 14); // 90 - 76
    }

    #[test]
    fn dogfood_age_reports_cost_when_run_result_json_exists() {
        let tmp = tempfile::tempdir().unwrap();
        let root = tmp.path();
        fs::create_dir_all(root.join("sessions")).unwrap();
        write_artifacts(root, 63, "vajra-receipt.txt", Some(1.2662));

        let report = dogfood_age(root, 90).expect("should find s63");
        assert_eq!(report.session, 63);
        assert_eq!(report.cost_usd, Some(1.2662));
        assert_eq!(report.sessions_since, 27); // 90 - 63
    }

    #[test]
    fn jdn_arithmetic_is_correct() {
        // 2026-07-18 − 2026-07-18 = 0 days.
        assert_eq!(days_since((2026, 7, 18), (2026, 7, 18)), 0);
        // 2026-07-21 − 2026-07-18 = 3 days.
        assert_eq!(days_since((2026, 7, 18), (2026, 7, 21)), 3);
        // Cross-month: 2026-07-30 − 2026-07-18 = 12 days.
        assert_eq!(days_since((2026, 7, 18), (2026, 7, 30)), 12);
        // Cross-year: 2027-01-01 − 2026-12-31 = 1 day.
        assert_eq!(days_since((2026, 12, 31), (2027, 1, 1)), 1);
    }

    #[test]
    fn iso_days_ago_s76_date_vs_today() {
        // The S76 dogfood date. Today is 2026-07-21. Cross-check the arithmetic.
        let days = days_since((2026, 7, 18), (2026, 7, 21));
        assert_eq!(days, 3);
    }

    #[test]
    fn format_dogfood_age_shows_none_when_no_report() {
        let text = format_dogfood_age(90, None);
        assert!(text.contains("no dogfood run detected"));
    }

    #[test]
    fn format_dogfood_age_shows_session_and_staleness() {
        let r = DogfoodAgeReport {
            session: 76,
            date: Some("2026-07-18".into()),
            sessions_since: 14,
            calendar_days: Some(3),
            cost_usd: None,
            receipt_file: "receipt.stderr.txt".into(),
        };
        let text = format_dogfood_age(90, Some(&r));
        assert!(text.contains("76"));
        assert!(text.contains("2026-07-18"));
        assert!(text.contains("14"));
        assert!(text.contains("3 day(s)"));
        assert!(text.contains("not captured"));
    }
}
