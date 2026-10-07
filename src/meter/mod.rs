use anyhow::{Context, Result};
use std::collections::HashMap;
use std::fs;
use std::path::Path;

// ─── pricing (compiled-in, update binary on price change) ──────────

struct ModelPricing {
    prefix: &'static str,
    input_per_mtok: f64,
    output_per_mtok: f64,
}

const MODEL_PRICING: &[ModelPricing] = &[
    // Current opus tier — confirmed via the `claude-api` skill / shared/models.md (cached
    // 2026-06-24): Opus 4.8, 4.7, and 4.6 all price at $5/$25 per MTok, well below the stale
    // $15/$75 the generic "claude-opus-4" prefix used to apply to every opus-4-x id alike (S79;
    // that rate dates to the opus-4.0/4.1 era). Specific-before-generic: these three entries MUST
    // stay ahead of the generic "claude-opus-4" fallback below, since `pricing_for` returns the
    // first prefix match and every one of these strings also starts with "claude-opus-4".
    ModelPricing {
        prefix: "claude-opus-4-8",
        input_per_mtok: 5.0,
        output_per_mtok: 25.0,
    },
    ModelPricing {
        prefix: "claude-opus-4-7",
        input_per_mtok: 5.0,
        output_per_mtok: 25.0,
    },
    ModelPricing {
        prefix: "claude-opus-4-6",
        input_per_mtok: 5.0,
        output_per_mtok: 25.0,
    },
    // Legacy/unconfirmed opus fallback: 4.0, 4.1, 4.5, and any other "claude-opus-4*" id not
    // matched above. The current pricing table has no published rate for these deprecated ids, so
    // this keeps the historical opus-4.0/4.1-era rate ($15/$75) as a conservative, non-decreasing
    // estimate rather than guessing at their present-day billing (S79 granularity decision).
    ModelPricing {
        prefix: "claude-opus-4",
        input_per_mtok: 15.0,
        output_per_mtok: 75.0,
    },
    ModelPricing {
        prefix: "claude-sonnet-4",
        input_per_mtok: 3.0,
        output_per_mtok: 15.0,
    },
    ModelPricing {
        prefix: "claude-haiku",
        input_per_mtok: 0.80,
        output_per_mtok: 4.0,
    },
    // claude-fable-5 — Anthropic's most capable widely released model. Real rates $10 input /
    // $50 output per MTok, from the Claude model catalog (claude-api skill · shared/models.md,
    // cached 2026-06-24). Added S77: the S76 dogfood ran headless on fable-5, which was absent
    // here and so got priced at UNKNOWN_MODEL_PRICING (the opus upper bound, $15/$75) — an
    // overstatement. These real rates (below the upper bound) stop that. Compiled-in per ADR-0004.
    ModelPricing {
        prefix: "claude-fable-5",
        input_per_mtok: 10.0,
        output_per_mtok: 50.0,
    },
];

/// Said when the run reported no charge of its own. Plain words on purpose (S171): the founder's
/// first-run receipt read "no authoritative cost available … no total_cost_usd in JSONL", which
/// tells a new user nothing. `apply_captured_cost` drops this warning by matching on it, so the
/// text lives in ONE place.
pub(crate) const NO_REPORTED_COST_WARNING: &str =
    "Claude Code did not record what this run cost, so there is no charge to show — the \
     [estimate] line is Vajra's own estimate from the tokens in the transcript, not the charge on \
     your bill";

const WEB_SEARCH_PER_REQUEST: f64 = 0.01;
const WEB_FETCH_PER_REQUEST: f64 = 0.01;
const TOKENS_PER_LINE_ESTIMATE: f64 = 12.0;

/// Rate used to *estimate* a model absent from `MODEL_PRICING`. Re-confirmed at S79: opus is no
/// longer the priciest tier (Opus 4.6/4.7/4.8 are $5/$25 — see `MODEL_PRICING` above), so this is
/// kept as a deliberate ceiling instead — 1.5x Claude Fable 5's $10/$50, the priciest rate
/// actually in the table (claude-api skill cache, 2026-06-24). Same numeric value as before
/// (unchanged — it was already an upper bound over every known rate), just decoupled from the
/// "opus" framing that stopped being true. An unknown model priced this way is always surfaced
/// (`is_known_model` → `SessionCost.unknown_models`) and labeled in the receipt, so it can never
/// be silently reported as the authoritative charge (S66). See the
/// `unknown_model_pricing_still_exceeds_every_known_rate` test below for the invariant this
/// preserves.
const UNKNOWN_MODEL_PRICING: (f64, f64) = (15.0, 75.0);

pub(crate) fn pricing_for(model: &str) -> (f64, f64) {
    for p in MODEL_PRICING {
        if model.starts_with(p.prefix) {
            return (p.input_per_mtok, p.output_per_mtok);
        }
    }
    UNKNOWN_MODEL_PRICING
}

/// Is this model in the compiled-in pricing table? A `false` here means `pricing_for` fell back
/// to `UNKNOWN_MODEL_PRICING` (the intentional upper-bound rate) — the token estimate for it is
/// unreliable and must be labeled, not presented as the bill (S66 root cause: `claude-fable-5`
/// priced as opus, back when opus was still the priciest tier).
pub(crate) fn is_known_model(model: &str) -> bool {
    MODEL_PRICING.iter().any(|p| model.starts_with(p.prefix))
}

// ─── types ─────────────────────────────────────────────────────────

#[derive(Debug, Clone, Default)]
pub struct TokenUsage {
    pub input: u64,
    pub output: u64,
    pub cache_read: u64,
    pub cache_write_5m: u64,
    pub cache_write_1h: u64,
    pub web_search_requests: u64,
    pub web_fetch_requests: u64,
}

#[derive(Debug, Clone)]
pub struct ModelCost {
    pub model: String,
    pub assistant_lines: u64,
    pub dollars: f64,
    pub tokens: TokenUsage,
}

#[derive(Debug, Clone)]
pub struct CompressionStats {
    pub lines_folded: u64,
    pub calls_compressed: u64,
}

#[derive(Debug, Clone)]
pub struct SessionCost {
    pub session_id: String,
    pub model_breakdown: Vec<ModelCost>,
    /// The token-recomputed estimate (ADR-0004 §2.5). Kept as a fallback — NOT the authoritative
    /// charge when `authoritative_dollars` is present (S66).
    pub total_dollars: f64,
    /// The SDK-authoritative `total_cost_usd` if the JSONL carried it (headless `type:"result"`
    /// line). When `Some`, this is the real bill and the receipt headline uses it (S66).
    pub authoritative_dollars: Option<f64>,
    /// Claude Code's own `cost-state` record from the transcript (S189, ADR-0004 S189 addendum).
    /// Its own field on purpose: `apply_captured_cost` only fills an empty `authoritative_dollars`,
    /// so putting this figure there would let the transcript silently beat the `-p` stream (AC4).
    /// `headline_dollars` picks between the sources in one place.
    pub tool_record: Option<ToolRecord>,
    /// Models seen in the transcript that are absent from `MODEL_PRICING` — their token estimate
    /// used the opus upper-bound fallback, so it must be labeled, never billed (S66).
    pub unknown_models: Vec<String>,
    pub compression: Option<CompressionStats>,
    pub estimated_tokens_saved: Option<u64>,
    pub estimated_dollars_saved: Option<f64>,
    pub warnings: Vec<String>,
}

impl SessionCost {
    /// The dollar figure to bill/budget against: the authoritative `total_cost_usd` when the
    /// JSONL carried it, else the token estimate. Callers (budget cap, receipt headline) use this
    /// so an unknown-model estimate can never masquerade as the charge (S66).
    pub fn billed_dollars(&self) -> f64 {
        self.headline_dollars().unwrap_or(self.total_dollars)
    }

    /// The one source-order resolver (S189): the transcript's `type:"result"` figure or the
    /// captured `-p` stream (both in `authoritative_dollars`, S66/S78), then this run's share of
    /// Claude Code's `cost-state` total, then none. A whole-conversation total is never this run's
    /// cost, so it is not returned here — the receipt labels it on its own line.
    pub fn headline_dollars(&self) -> Option<f64> {
        self.authoritative_dollars.or(match self.tool_record {
            Some(ToolRecord::ThisRun { dollars, .. }) => Some(dollars),
            _ => None,
        })
    }

    /// Apply an authoritative `total_cost_usd` captured from the coding tool's OWN end-of-session
    /// output — the headless `-p` `type:"result"` stdout line (S78). The on-disk transcript the
    /// meter reads never carries this figure (S77 root cause), so on real headless runs the
    /// launcher captures the result stream and hands the value here. The stream figure IS the real
    /// bill, so it supersedes the no-cost state (S77; S189 wording): the field is set and the
    /// authoritative-absent warning is dropped. A transcript that already carried its own
    /// `total_cost_usd` is left untouched (it is equally authoritative — no double-source override).
    /// `None` (interactive run, or text-mode headless with no result line) is a no-op: S77's honest
    /// fallback stands (criterion 2).
    pub fn apply_captured_cost(&mut self, captured: Option<f64>) {
        if let Some(cost) = captured {
            if self.authoritative_dollars.is_none() {
                self.authoritative_dollars = Some(cost);
                self.warnings.retain(|w| w != NO_REPORTED_COST_WARNING);
            }
        }
    }
}

/// Claude Code's own cost record, read from the `{"type":"cost-state"}` lines it appends to the
/// main transcript at each normal exit (Claude Code 2.1.275 and later; S189 researcher). The line
/// carries the conversation's RUNNING total: a resumed conversation has one line per finished run
/// (4.65 → 13.94 → …), and one exit can write the line twice with the same total — so lines are
/// never added up.
#[derive(Debug, Clone, PartialEq)]
pub enum ToolRecord {
    /// This run's share: the last total minus the last total written before this run began.
    ThisRun { dollars: f64, unpriced: bool },
    /// No launch time to cut at (`vajra meter FILE`): the whole conversation's total, every run in
    /// the file, labelled as that — never as "this run".
    WholeConversation { dollars: f64, unpriced: bool },
    /// The total started before this launch and no earlier total is in the file to subtract (a
    /// fork, or a resume whose earlier record is missing): this run's share is unknown.
    IncludesEarlierSpend { dollars: f64 },
}

/// Read Claude Code's own `cost-state` record from a main transcript's text (S189, ADR-0004 S189
/// addendum). `launch_ms` is Vajra's launch time in Unix milliseconds; `None` (no launch to cut
/// at) gives the whole conversation's total. Fails closed — any doubt is `None`, never a number
/// with the wrong label:
/// - the cut is the first line whose `timestamp` reads (strict UTC shape) at or after the launch;
///   no such line → `None`;
/// - the last `cost-state` line must come after the cut (otherwise this run wrote none: a crash
///   or a kill) → else `None`;
/// - the baseline is the last `cost-state` before the cut (0 when there is none);
/// - a total that is not a finite number ≥ 0, or a negative share → `None`;
/// - no baseline and a `startTime` before the launch (or none at all) → `IncludesEarlierSpend`.
pub fn cost_state_record(content: &str, launch_ms: Option<u64>) -> Option<ToolRecord> {
    // (line index, totalCostUSD, startTime, hasUnknownModelCost)
    let mut records: Vec<(usize, f64, Option<u64>, bool)> = Vec::new();
    let mut cut: Option<usize> = None;
    for (i, line) in content.lines().enumerate() {
        let Ok(v) = serde_json::from_str::<serde_json::Value>(line) else {
            continue;
        };
        if v["type"].as_str() == Some("cost-state") {
            let total = v["totalCostUSD"].as_f64().unwrap_or(f64::NAN);
            let unpriced = v["hasUnknownModelCost"].as_bool().unwrap_or(false);
            records.push((i, total, v["startTime"].as_u64(), unpriced));
            continue;
        }
        if let (None, Some(launch)) = (cut, launch_ms) {
            if v["timestamp"]
                .as_str()
                .and_then(parse_utc_ms)
                .is_some_and(|t| t >= launch)
            {
                cut = Some(i);
            }
        }
    }
    let &(last_i, total, start, unpriced) = records.last()?;
    if !total.is_finite() || total < 0.0 {
        return None;
    }
    let Some(launch) = launch_ms else {
        return Some(ToolRecord::WholeConversation {
            dollars: total,
            unpriced,
        });
    };
    let cut = cut?;
    if last_i < cut {
        return None;
    }
    match records.iter().rev().find(|r| r.0 < cut) {
        Some(&(_, base, _, _)) => {
            let share = total - base;
            if !base.is_finite() || base < 0.0 || share < 0.0 {
                return None;
            }
            Some(ToolRecord::ThisRun {
                dollars: share,
                unpriced,
            })
        }
        None if start.is_some_and(|s| s >= launch) => Some(ToolRecord::ThisRun {
            dollars: total,
            unpriced,
        }),
        None => Some(ToolRecord::IncludesEarlierSpend { dollars: total }),
    }
}

/// A warning when Claude Code SHOULD have recorded its own cost but Vajra cannot read one (S189
/// fidelity rec 1). Failing closed keeps a wrong number off the receipt, but on its own it would
/// also hide Claude Code changing the record's format: every receipt would quietly say "no cost".
/// So: a `cost-state` line with no readable `totalCostUSD`, or — with a launch time — a run whose
/// lines name Claude Code 2.1.275 or later and that wrote no `cost-state` line after the cut, is
/// named. `None` when there is nothing to say.
pub fn cost_state_warning(content: &str, launch_ms: Option<u64>) -> Option<String> {
    let mut cut_seen = launch_ms.is_none();
    let mut record_after_cut = false;
    let mut newest: Option<(u64, u64, u64, String)> = None;
    for line in content.lines() {
        let Ok(v) = serde_json::from_str::<serde_json::Value>(line) else {
            continue;
        };
        if v["type"].as_str() == Some("cost-state") {
            if !v["totalCostUSD"]
                .as_f64()
                .is_some_and(|t| t.is_finite() && t >= 0.0)
            {
                return Some(
                    "Claude Code's cost record in this run log has no total Vajra can read — Claude \
                     Code may have changed how it records cost, so this vajra needs an update"
                        .into(),
                );
            }
            record_after_cut |= cut_seen;
            continue;
        }
        if !cut_seen {
            cut_seen = v["timestamp"]
                .as_str()
                .and_then(parse_utc_ms)
                .zip(launch_ms)
                .is_some_and(|(t, l)| t >= l);
        }
        if cut_seen {
            if let Some(ver) = v["version"].as_str() {
                let parts: Vec<u64> = ver.split('.').map_while(|p| p.parse().ok()).collect();
                if let [a, b, c, ..] = parts[..] {
                    if !newest
                        .as_ref()
                        .is_some_and(|n| (a, b, c) <= (n.0, n.1, n.2))
                    {
                        newest = Some((a, b, c, ver.to_string()));
                    }
                }
            }
        }
    }
    let (a, b, c, ver) = newest?;
    if launch_ms.is_some() && !record_after_cut && (a, b, c) >= (2, 1, 275) {
        return Some(format!(
            "Claude Code {ver} records its own cost when it exits, but this run log has none for \
             this run — it did not end normally, or Claude Code changed how it records cost (then \
             this vajra needs an update)"
        ));
    }
    None
}

/// Unix milliseconds from the one timestamp shape Claude Code writes, `YYYY-MM-DDTHH:MM:SS[.f…]Z`
/// (UTC). Anything else is `None` — the caller skips the line, so the worst case is "no figure"
/// (S189 design-advisor rec 6; no date crate for one comparison).
pub(crate) fn parse_utc_ms(ts: &str) -> Option<u64> {
    let b = ts.as_bytes();
    if b.len() < 20 || *b.last()? != b'Z' {
        return None;
    }
    let num = |r: std::ops::Range<usize>| -> Option<u64> {
        let s = ts.get(r)?;
        if s.is_empty() || !s.bytes().all(|c| c.is_ascii_digit()) {
            return None;
        }
        s.parse().ok()
    };
    if b[4] != b'-' || b[7] != b'-' || b[10] != b'T' || b[13] != b':' || b[16] != b':' {
        return None;
    }
    let (y, mo, d) = (num(0..4)?, num(5..7)?, num(8..10)?);
    let (h, mi, s) = (num(11..13)?, num(14..16)?, num(17..19)?);
    let ms = match b.len() {
        20 => 0,
        n if b[19] == b'.' && (22..=30).contains(&n) => {
            let frac = ts.get(20..n - 1)?;
            num(20..n - 1)?;
            let three: String = frac.chars().chain("000".chars()).take(3).collect();
            three.parse::<u64>().ok()?
        }
        _ => return None,
    };
    if !(1..=12).contains(&mo) || !(1..=31).contains(&d) || h > 23 || mi > 59 || s > 60 {
        return None;
    }
    // Days from 1970-01-01 (Howard Hinnant's days_from_civil).
    let (y, m) = (y as i64 - i64::from(mo <= 2), mo as i64);
    let era = y.div_euclid(400);
    let yoe = y - era * 400;
    let doy = (153 * (m + if m > 2 { -3 } else { 9 }) + 2) / 5 + d as i64 - 1;
    let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;
    let days = era * 146_097 + doe - 719_468;
    if days < 0 {
        return None;
    }
    Some(((days as u64 * 86_400 + h * 3_600 + mi * 60 + s) * 1_000) + ms)
}

/// Extract the SDK-authoritative `total_cost_usd` from a headless run's captured stdout — the
/// terminal `type:"result"` line of `claude -p --output-format json|stream-json` (S78). This is
/// the figure the on-disk transcript never carries (S77 root cause); the launcher tees the `-p`
/// stdout and hands the bytes here. Precedence: the last `type:"result"` line wins (stream-json
/// emits one terminal result). Also tolerates `--output-format json`, which is a single
/// (possibly pretty-printed, multi-line) JSON object rather than line-delimited. Returns `None`
/// for text-mode headless output (no result line) and for anything that is not valid JSON — never
/// guesses a cost from a non-result line.
pub fn extract_result_cost(stdout: &[u8]) -> Option<f64> {
    let text = std::str::from_utf8(stdout).ok()?;

    // stream-json / json-lines: scan each line; last terminal result wins.
    let mut found: Option<f64> = None;
    for line in text.lines() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }
        if let Ok(v) = serde_json::from_str::<serde_json::Value>(line) {
            if v["type"].as_str() == Some("result") {
                if let Some(c) = v["total_cost_usd"].as_f64() {
                    found = Some(c);
                }
            }
        }
    }
    if found.is_some() {
        return found;
    }

    // `--output-format json`: a single JSON object spanning the whole (possibly multi-line) buffer.
    if let Ok(v) = serde_json::from_str::<serde_json::Value>(text.trim()) {
        if v["type"].as_str() == Some("result") {
            return v["total_cost_usd"].as_f64();
        }
    }
    None
}

// ─── core ──────────────────────────────────────────────────────────

/// Meter a transcript with no launch time (`vajra meter FILE`): Claude Code's own record, if any,
/// is the whole conversation's total, labelled as that (S189).
pub fn meter_session(
    main_jsonl: &Path,
    subagent_dir: Option<&Path>,
    compression_stats: Option<CompressionStats>,
) -> Result<SessionCost> {
    meter_run(main_jsonl, subagent_dir, compression_stats, None)
}

/// Meter one `vajra claude` run: `launch` is when Vajra started Claude Code, so Claude Code's own
/// `cost-state` total can be cut to this run's share (S189, ADR-0004 S189 addendum). `None` behaves
/// like `meter_session`.
pub fn meter_run(
    main_jsonl: &Path,
    subagent_dir: Option<&Path>,
    compression_stats: Option<CompressionStats>,
    launch: Option<std::time::SystemTime>,
) -> Result<SessionCost> {
    let session_id = main_jsonl
        .file_stem()
        .and_then(|s| s.to_str())
        .unwrap_or("unknown")
        .to_string();

    let mut model_map: HashMap<String, (TokenUsage, u64)> = HashMap::new();
    let mut warnings: Vec<String> = Vec::new();
    // Authoritative `total_cost_usd` comes from the main transcript's `type:"result"` line only;
    // subagent files carry their own partial totals and must not overwrite it.
    let mut authoritative_dollars: Option<f64> = None;

    parse_jsonl(
        main_jsonl,
        &mut model_map,
        &mut warnings,
        &mut authoritative_dollars,
    )?;

    if let Some(dir) = subagent_dir {
        if dir.exists() {
            if let Ok(entries) = fs::read_dir(dir) {
                for entry in entries.flatten() {
                    let path = entry.path();
                    if path.extension().and_then(|e| e.to_str()) == Some("jsonl") {
                        let mut ignored = None;
                        let _ = parse_jsonl(&path, &mut model_map, &mut warnings, &mut ignored);
                    }
                }
            }
        }
    }

    let mut model_breakdown: Vec<ModelCost> = Vec::new();
    let mut total_dollars = 0.0;
    let mut unknown_models: Vec<String> = Vec::new();

    for (model, (tokens, lines)) in &model_map {
        let dollars = line_dollars(tokens, model);
        total_dollars += dollars;
        if !is_known_model(model) && !unknown_models.contains(model) {
            unknown_models.push(model.clone());
        }
        model_breakdown.push(ModelCost {
            model: model.clone(),
            assistant_lines: *lines,
            dollars,
            tokens: tokens.clone(),
        });
    }
    unknown_models.sort();

    model_breakdown.sort_by(|a, b| {
        b.dollars
            .partial_cmp(&a.dollars)
            .unwrap_or(std::cmp::Ordering::Equal)
    });

    let (estimated_tokens_saved, estimated_dollars_saved) = match &compression_stats {
        Some(stats) if stats.lines_folded > 0 => {
            let tokens_saved = (stats.lines_folded as f64 * TOKENS_PER_LINE_ESTIMATE) as u64;
            let primary_model = model_breakdown
                .first()
                .map(|m| m.model.as_str())
                .unwrap_or("");
            let (input_price, _) = pricing_for(primary_model);
            let dollars_saved = tokens_saved as f64 * input_price * 1.25 / 1_000_000.0;
            (Some(tokens_saved), Some(dollars_saved))
        }
        _ => (None, None),
    };

    if !unknown_models.is_empty() {
        warnings.push(format!(
            "model(s) {} not in pricing table — token estimate uses an intentional upper-bound \
             rate, not real rates; trust the authoritative total, not the estimate",
            unknown_models.join(", ")
        ));
    }
    // Claude Code's own record (S189). Main transcript only — subagent files carry none, and their
    // spend is already inside Claude Code's total.
    let launch_ms = launch.and_then(|t| {
        t.duration_since(std::time::UNIX_EPOCH)
            .ok()
            .map(|d| d.as_millis() as u64)
    });
    let tool_record = fs::read_to_string(main_jsonl)
        .ok()
        .and_then(|text| cost_state_record(&text, launch_ms));
    let tool_has_figure = matches!(
        tool_record,
        Some(ToolRecord::ThisRun { .. } | ToolRecord::WholeConversation { .. })
    );
    if authoritative_dollars.is_none() && !tool_has_figure {
        warnings.push(NO_REPORTED_COST_WARNING.into());
    }
    if let Some(w) = fs::read_to_string(main_jsonl)
        .ok()
        .and_then(|text| cost_state_warning(&text, launch_ms))
    {
        warnings.push(w);
    }

    Ok(SessionCost {
        session_id,
        model_breakdown,
        total_dollars,
        authoritative_dollars,
        tool_record,
        unknown_models,
        compression: compression_stats,
        estimated_tokens_saved,
        estimated_dollars_saved,
        warnings,
    })
}

// ─── JSONL parsing ─────────────────────────────────────────────────

fn parse_jsonl(
    path: &Path,
    model_map: &mut HashMap<String, (TokenUsage, u64)>,
    warnings: &mut Vec<String>,
    authoritative_dollars: &mut Option<f64>,
) -> Result<()> {
    let content = fs::read_to_string(path)
        .with_context(|| format!("failed to read JSONL: {}", path.display()))?;

    // S171 (founder's first-run test): Claude Code writes ONE LINE PER CONTENT BLOCK of an
    // assistant message, and every one of those lines repeats the SAME `usage` object — the
    // message's totals, not that block's share. Summing every line therefore charged a
    // three-block reply three times. Measured on the founder's rudra session 00: 128 usage lines,
    // 56 real messages, receipt $19.33 against Claude Code's own $8.38 — the 2.3x he spotted.
    // So: count a message ONCE, keyed by `message.id`, falling back to `requestId` and then the
    // line's own `uuid`. A line with none of the three is counted (it cannot be a repeat we can
    // recognise, and dropping it would understate the bill).
    let mut counted: std::collections::HashSet<String> = std::collections::HashSet::new();

    for line in content.lines() {
        if line.trim().is_empty() {
            continue;
        }
        let parsed: serde_json::Value = match serde_json::from_str(line) {
            Ok(v) => v,
            Err(_) => continue,
        };

        // The SDK-authoritative charge: the headless run's terminal `type:"result"` line carries
        // `total_cost_usd`. Prefer it over any token recompute (S66). Last one wins if repeated.
        //
        // S77 root-cause finding (criterion 3 — NOT a nesting artifact, NOT cost-on-another-line):
        // the JSONL `find_session_jsonl` locates is the on-disk CC *session transcript*
        // (`~/.claude/projects/<slug>/<uuid>.jsonl`), whose top-level line types are
        // queue-operation / user / assistant / attachment / last-prompt. That file carries NO cost
        // field anywhere — `total_cost_usd` is emitted only on the terminal `type:"result"` line of
        // a headless `claude -p --output-format json|stream-json` *stdout stream*, a different
        // artifact vajra does not capture. So the S76 real runs had no authoritative figure to read;
        // this branch simply never fires for them (verified against both S76 transcripts: 0 result
        // lines, 0 cost keys). Repairing the read would require capturing the -p stdout stream (a
        // launcher change, out of ADR-0004 scope); the honest fix here is the receipt saying "no
        // authoritative cost available" instead of dressing the token estimate up as a total.
        if parsed["type"].as_str() == Some("result") {
            if let Some(cost) = parsed["total_cost_usd"].as_f64() {
                *authoritative_dollars = Some(cost);
            }
        }

        if parsed["type"].as_str() != Some("assistant") {
            continue;
        }

        let model = match parsed["message"]["model"].as_str() {
            Some(m) if !m.is_empty() && m != "<synthetic>" => m,
            _ => continue,
        };

        // One message, one charge (see the note at the top of this function).
        let key = parsed["message"]["id"]
            .as_str()
            .or_else(|| parsed["requestId"].as_str())
            .or_else(|| parsed["uuid"].as_str())
            .map(str::to_string);
        if let Some(k) = key {
            if !counted.insert(k) {
                continue;
            }
        }

        let usage = &parsed["message"]["usage"];

        let input = get_u64(usage, "input_tokens");
        let output = get_u64(usage, "output_tokens");
        let cache_read = get_u64(usage, "cache_read_input_tokens");

        let (cache_write_5m, cache_write_1h) = parse_cache_tiers(usage, warnings);

        let web_search = usage["server_tool_use"]["web_search_requests"]
            .as_u64()
            .unwrap_or(0);
        let web_fetch = usage["server_tool_use"]["web_fetch_requests"]
            .as_u64()
            .unwrap_or(0);

        let entry = model_map.entry(model.to_string()).or_default();
        entry.0.input += input;
        entry.0.output += output;
        entry.0.cache_read += cache_read;
        entry.0.cache_write_5m += cache_write_5m;
        entry.0.cache_write_1h += cache_write_1h;
        entry.0.web_search_requests += web_search;
        entry.0.web_fetch_requests += web_fetch;
        entry.1 += 1;
    }

    Ok(())
}

fn parse_cache_tiers(usage: &serde_json::Value, warnings: &mut Vec<String>) -> (u64, u64) {
    let cc = &usage["cache_creation"];
    let t5m = cc["ephemeral_5m_input_tokens"].as_u64();
    let t1h = cc["ephemeral_1h_input_tokens"].as_u64();

    match (t5m, t1h) {
        (Some(a), Some(b)) => (a, b),
        _ => {
            let fallback = get_u64(usage, "cache_creation_input_tokens");
            if fallback > 0 {
                let estimated = (fallback as f64 * 0.615) as u64;
                warnings.push(
                    "[estimated] cache tier split unavailable; using midpoint estimate".into(),
                );
                (estimated, fallback - estimated)
            } else {
                (0, 0)
            }
        }
    }
}

fn get_u64(v: &serde_json::Value, key: &str) -> u64 {
    v[key].as_u64().unwrap_or(0)
}

// ─── cost formula (ADR-0004 §2.5) ─────────────────────────────────

fn line_dollars(tokens: &TokenUsage, model: &str) -> f64 {
    let (input_price, output_price) = pricing_for(model);
    (tokens.input as f64 * input_price
        + tokens.output as f64 * output_price
        + tokens.cache_read as f64 * input_price * 0.10
        + tokens.cache_write_5m as f64 * input_price * 1.25
        + tokens.cache_write_1h as f64 * input_price * 2.00)
        / 1_000_000.0
        + tokens.web_search_requests as f64 * WEB_SEARCH_PER_REQUEST
        + tokens.web_fetch_requests as f64 * WEB_FETCH_PER_REQUEST
}

// ─── receipt ───────────────────────────────────────────────────────

pub fn format_receipt(cost: &SessionCost) -> String {
    let short_id = &cost.session_id[..cost.session_id.len().min(7)];
    let mut out = String::new();

    out.push_str(&format!(
        "─── vajra · {} ───────────────────────────────────────────\n",
        short_id
    ));

    let model_summary: Vec<String> = cost
        .model_breakdown
        .iter()
        .map(|m| {
            let short_model = m.model.replace("claude-", "");
            format!("{} · {} replies", short_model, m.assistant_lines)
        })
        .collect();

    // Headline = the tool's own figure (`headline_dollars`: the result line or `-p` stream, then this
    // run's share of Claude Code's `cost-state` total — S66/S78/S189); the token recompute is always
    // a labelled `[estimate]` line beneath it. With no figure the headline has NO dollar sign — "no
    // cost from Claude Code for this run" (S189; S77 first said so). The estimate tag also flags any unknown model
    // whose rate fell back to the unknown-model upper bound (S66) — though S77 priced fable-5 and
    // S79 corrected opus, so the S76 fixture now shows the plain `[estimate]` tag at real rates.
    let estimate_tag = if cost.unknown_models.is_empty() {
        "[estimate]".to_string()
    } else {
        format!(
            "[estimate · {} priced at the unknown-model upper bound, not real rates]",
            cost.unknown_models.join(", ").replace("claude-", "")
        )
    };
    let models = model_summary.join(" · ");
    // One resolver picks the source (S189): the tool's own figure for this run, else no dollar
    // sign at all on the headline. The token figure only ever rides the `[estimate]` line beneath.
    let estimate_line = format!(
        "         ~${:.2}  {}  Vajra's own estimate from the tokens — not the charge on your bill\n",
        cost.total_dollars, estimate_tag
    );
    let unpriced_note = "\n         Claude Code could not price every model in this run";
    match (cost.authoritative_dollars, &cost.tool_record) {
        (Some(authoritative), _) => {
            out.push_str(&format!(
                " ${:.2}  what this run cost  ({})\n",
                authoritative, models
            ));
            out.push_str(&format!(
                "         ${:.2}  Vajra's own estimate from tokens  {}\n",
                cost.total_dollars, estimate_tag
            ));
        }
        (None, Some(ToolRecord::ThisRun { dollars, unpriced })) => {
            out.push_str(&format!(
                " ${:.2}  what this run cost — Claude Code's own figure  ({}){}\n",
                dollars,
                models,
                if *unpriced { unpriced_note } else { "" }
            ));
            out.push_str(&estimate_line);
        }
        (None, Some(ToolRecord::WholeConversation { dollars, unpriced })) => {
            out.push_str(&format!(
                " ${:.2}  Claude Code's own total for this whole conversation (every run in this file)  ({}){}\n",
                dollars,
                models,
                if *unpriced { unpriced_note } else { "" }
            ));
            out.push_str(&estimate_line);
        }
        (None, Some(ToolRecord::IncludesEarlierSpend { dollars })) => {
            out.push_str(&format!(
                " no cost from Claude Code for this run  ({models})\n"
            ));
            out.push_str(&format!(
                "         ${dollars:.2}  Claude Code's total for this whole conversation — includes spend before this run\n"
            ));
            out.push_str(&estimate_line);
        }
        (None, None) => {
            out.push_str(&format!(
                " no cost from Claude Code for this run  ({models})\n"
            ));
            out.push_str(&estimate_line);
        }
    }

    let total_tokens = &cost
        .model_breakdown
        .iter()
        .fold(TokenUsage::default(), |mut acc, m| {
            acc.input += m.tokens.input;
            acc.output += m.tokens.output;
            acc.cache_read += m.tokens.cache_read;
            acc.cache_write_5m += m.tokens.cache_write_5m;
            acc.cache_write_1h += m.tokens.cache_write_1h;
            acc
        });
    let (primary_input, primary_output) = cost
        .model_breakdown
        .first()
        .map(|m| pricing_for(&m.model))
        .unwrap_or(UNKNOWN_MODEL_PRICING);
    let input_cost = total_tokens.input as f64 * primary_input / 1e6;
    let output_cost = total_tokens.output as f64 * primary_output / 1e6;
    let cache_r_cost = total_tokens.cache_read as f64 * primary_input * 0.10 / 1e6;
    let cache_w_cost = (total_tokens.cache_write_5m as f64 * primary_input * 1.25
        + total_tokens.cache_write_1h as f64 * primary_input * 2.0)
        / 1e6;
    out.push_str(&format!(
        "         [estimate] split: new text ${:.2} · replies ${:.2} · re-reading context ${:.2} · saving context ${:.2}\n",
        input_cost, output_cost, cache_r_cost, cache_w_cost
    ));

    if let Some(ref stats) = cost.compression {
        out.push_str(&format!(
            "         {} lines folded across {} tool calls\n",
            stats.lines_folded, stats.calls_compressed
        ));
    }

    if let (Some(tokens_saved), Some(dollars_saved)) =
        (cost.estimated_tokens_saved, cost.estimated_dollars_saved)
    {
        out.push_str(&format!(
            "         ~${:.4} saved (est. ~{} input tokens not billed)\n",
            dollars_saved, tokens_saved
        ));
    }

    out.push_str("─────────────────────────────────────────────────────────\n");

    for w in &cost.warnings {
        out.push_str(&format!("[vajra warn] {}\n", w));
    }

    out
}

// ─── sidecar stats ─────────────────────────────────────────────────

pub fn read_compression_stats(path: &Path) -> Option<CompressionStats> {
    let content = fs::read_to_string(path).ok()?;
    let mut lines_folded: u64 = 0;
    let mut calls_compressed: u64 = 0;

    for line in content.lines() {
        if let Ok(v) = serde_json::from_str::<serde_json::Value>(line) {
            let lines_in = v["lines_in"].as_u64().unwrap_or(0);
            let lines_out = v["lines_out"].as_u64().unwrap_or(0);
            lines_folded += lines_in.saturating_sub(lines_out);
            calls_compressed += 1;
        }
    }

    if calls_compressed == 0 {
        return None;
    }

    Some(CompressionStats {
        lines_folded,
        calls_compressed,
    })
}

// ─── JSONL discovery ───────────────────────────────────────────────

pub fn find_session_jsonl(
    session_start: std::time::SystemTime,
) -> Option<(std::path::PathBuf, Option<std::path::PathBuf>)> {
    let cwd = std::env::current_dir().ok()?;
    let home = dirs_or_home()?;
    let slug = cwd.to_string_lossy().replace('/', "-");
    let project_dir = home.join(".claude/projects").join(&slug);

    let candidates = find_jsonl_candidates(&project_dir, session_start);

    if candidates.len() != 1 {
        if candidates.len() > 1 {
            eprintln!("[vajra] multiple sessions detected — skipping meter (run vajra meter <id> manually)");
        }
        return None;
    }

    let main_jsonl = candidates.into_iter().next()?;
    let session_uuid = main_jsonl.file_stem()?.to_str()?;
    let subagent_dir = project_dir.join(session_uuid).join("subagents");
    let subagent_path = if subagent_dir.exists() {
        Some(subagent_dir)
    } else {
        None
    };

    Some((main_jsonl.to_path_buf(), subagent_path))
}

fn find_jsonl_candidates(
    project_dir: &Path,
    session_start: std::time::SystemTime,
) -> Vec<std::path::PathBuf> {
    let Ok(entries) = fs::read_dir(project_dir) else {
        return Vec::new();
    };

    entries
        .flatten()
        .filter(|e| {
            let path = e.path();
            path.extension().and_then(|x| x.to_str()) == Some("jsonl")
                && !path.to_string_lossy().contains("subagents")
        })
        .filter(|e| {
            e.metadata()
                .ok()
                .and_then(|m| m.modified().ok())
                .is_some_and(|t| t > session_start)
        })
        .map(|e| e.path())
        .collect()
}

fn dirs_or_home() -> Option<std::path::PathBuf> {
    std::env::var_os("HOME").map(std::path::PathBuf::from)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Write;

    fn fixture_jsonl() -> String {
        r#"{"type":"assistant","version":"2.1.177","message":{"model":"claude-opus-4-8","usage":{"input_tokens":10,"output_tokens":132,"cache_read_input_tokens":11586,"cache_creation_input_tokens":6928,"cache_creation":{"ephemeral_5m_input_tokens":0,"ephemeral_1h_input_tokens":6928},"server_tool_use":{"web_search_requests":0,"web_fetch_requests":0}}}}
{"type":"assistant","version":"2.1.177","message":{"model":"<synthetic>","usage":{}}}
{"type":"user","message":{"content":"test"}}
{"type":"assistant","version":"2.1.177","message":{"model":"claude-opus-4-8","usage":{"input_tokens":50,"output_tokens":200,"cache_read_input_tokens":5000,"cache_creation_input_tokens":1000,"cache_creation":{"ephemeral_5m_input_tokens":300,"ephemeral_1h_input_tokens":700},"server_tool_use":{"web_search_requests":0,"web_fetch_requests":0}}}}"#.to_string()
    }

    /// S171 cold review rec 7: the same claim against REAL bytes. Four lines lifted from the
    /// founder's own rudra session-00 transcript (ids, model and `usage` only — no content): one
    /// assistant message that Claude Code wrote across three lines, each repeating that message's
    /// whole usage, plus a second, different message. The honest total counts the first message
    /// once; the pre-S171 sum counted it three times, which is where the 2.3x came from.
    #[test]
    fn a_real_multiblock_message_from_the_founders_transcript_is_charged_once() {
        let fixture = Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("sessions/session-171-artifacts/fixtures/s171-multiblock-message.jsonl");
        let text = fs::read_to_string(&fixture).expect("fixture readable");
        assert_eq!(text.lines().count(), 4, "fixture shape changed");

        let cost = meter_session(&fixture, None, None).unwrap();
        let t = &cost.model_breakdown[0].tokens;
        // Message 1 (three lines) + message 2 (one line), each counted once.
        assert_eq!(t.input, 12774 + 2, "input: {t:?}");
        assert_eq!(t.output, 329 + 169, "output: {t:?}");
        assert_eq!(t.cache_read, 8105 + 78008, "cache_read: {t:?}");

        // What the old code did: every line summed. Proves the fixture really is a repeat.
        let naive: u64 = text
            .lines()
            .filter_map(|l| serde_json::from_str::<serde_json::Value>(l).ok())
            .map(|v| get_u64(&v["message"]["usage"], "output_tokens"))
            .sum();
        assert_eq!(
            naive,
            329 * 3 + 169,
            "the fixture must contain a real repeat"
        );
        assert!(naive > t.output, "dedupe must reduce the charge");
    }

    /// S171: Claude Code writes one line per content block, each repeating the message's whole
    /// `usage`. Three lines for one reply must be charged once — this is the 2.3x the founder
    /// caught on his own rudra run (receipt $19.33 vs Claude Code's $8.38).
    #[test]
    fn one_message_is_charged_once_however_many_lines_it_spans() {
        let block = |id: &str| {
            format!(
                r#"{{"type":"assistant","requestId":"req_{id}","message":{{"id":"{id}","model":"claude-opus-4-8","usage":{{"input_tokens":100,"output_tokens":10,"cache_read_input_tokens":1000,"cache_creation_input_tokens":0}}}}}}"#
            )
        };
        let dir = std::env::temp_dir().join("vajra-test-meter-dedup");
        let _ = fs::create_dir_all(&dir);

        let once = dir.join("once.jsonl");
        fs::write(&once, format!("{}\n", block("msg_a"))).unwrap();
        let single = meter_session(&once, None, None).unwrap();

        let thrice = dir.join("thrice.jsonl");
        let three = block("msg_a");
        fs::write(&thrice, format!("{three}\n{three}\n{three}\n")).unwrap();
        let repeated = meter_session(&thrice, None, None).unwrap();

        assert_eq!(repeated.total_dollars, single.total_dollars);
        assert_eq!(repeated.model_breakdown[0].tokens.output, 10);

        // Two DIFFERENT messages still add up — the fix must not swallow real traffic.
        let two = dir.join("two.jsonl");
        fs::write(&two, format!("{}\n{}\n", block("msg_a"), block("msg_b"))).unwrap();
        let pair = meter_session(&two, None, None).unwrap();
        assert_eq!(pair.model_breakdown[0].tokens.output, 20);
    }

    #[test]
    fn meter_parses_fixture_and_skips_synthetic() {
        let dir = std::env::temp_dir().join("vajra-test-meter");
        let _ = fs::create_dir_all(&dir);
        let jsonl_path = dir.join("test-session.jsonl");
        fs::write(&jsonl_path, fixture_jsonl()).unwrap();

        let result = meter_session(&jsonl_path, None, None).unwrap();

        assert_eq!(
            result.model_breakdown.len(),
            1,
            "synthetic should be filtered"
        );
        assert_eq!(result.model_breakdown[0].model, "claude-opus-4-8");
        assert_eq!(result.model_breakdown[0].assistant_lines, 2);
        assert_eq!(result.model_breakdown[0].tokens.input, 60);
        assert_eq!(result.model_breakdown[0].tokens.output, 332);
        assert_eq!(result.model_breakdown[0].tokens.cache_read, 16586);
        assert_eq!(result.model_breakdown[0].tokens.cache_write_5m, 300);
        assert_eq!(result.model_breakdown[0].tokens.cache_write_1h, 7628);
        // A known model with full cache tiers emits no cache-split warning. The fixture has no
        // `total_cost_usd`, so the only warning is the authoritative-absent note (S66).
        assert!(
            !result.warnings.iter().any(|w| w.contains("cache tier")),
            "no cache-tier estimate warning expected: {:?}",
            result.warnings
        );
        assert!(result.authoritative_dollars.is_none());
        assert!(result.unknown_models.is_empty());

        let _ = fs::remove_dir_all(&dir);
    }

    #[test]
    fn meter_cost_formula_matches_hand_calculation() {
        let dir = std::env::temp_dir().join("vajra-test-cost");
        let _ = fs::create_dir_all(&dir);
        let jsonl_path = dir.join("cost-session.jsonl");
        fs::write(&jsonl_path, fixture_jsonl()).unwrap();

        let result = meter_session(&jsonl_path, None, None).unwrap();

        // Hand calculation for claude-opus-4-8 at the corrected current rate (S79: input
        // $5/MTok, output $25/MTok — was $15/$75, the stale opus-4.0/4.1-era rate):
        // input:  60 * 5 / 1e6 = 0.000300
        // output: 332 * 25 / 1e6 = 0.008300
        // cache_read: 16586 * 5 * 0.10 / 1e6 = 0.008293
        // cache_write_5m: 300 * 5 * 1.25 / 1e6 = 0.001875
        // cache_write_1h: 7628 * 5 * 2.0 / 1e6 = 0.076280
        // total = 0.095048
        let expected = 0.095048;
        assert!(
            (result.total_dollars - expected).abs() < 0.0001,
            "got {}, expected {}",
            result.total_dollars,
            expected
        );

        let _ = fs::remove_dir_all(&dir);
    }

    #[test]
    fn opus_4_8_prices_at_current_rate_legacy_opus_keeps_historical_rate() {
        // S79: opus-4-8 (and 4-7 / 4-6) now price at the confirmed current rate ($5/$25 per
        // MTok — claude-api skill / shared/models.md, cached 2026-06-24), correcting the stale
        // $15/$75 the generic "claude-opus-4" prefix used to apply to every opus-4-x id alike.
        assert_eq!(pricing_for("claude-opus-4-8"), (5.0, 25.0));
        assert_eq!(pricing_for("claude-opus-4-7"), (5.0, 25.0));
        assert_eq!(pricing_for("claude-opus-4-6"), (5.0, 25.0));
        // Granularity decision: legacy/unconfirmed opus ids (4.0, 4.1, 4.5, and any dated
        // snapshot of them) fall through to the generic "claude-opus-4" entry, which keeps the
        // historical opus-4.0/4.1-era rate rather than guessing at their present-day billing.
        assert_eq!(pricing_for("claude-opus-4-1-20250805"), (15.0, 75.0));
        assert_eq!(pricing_for("claude-opus-4-20250514"), (15.0, 75.0));
    }

    #[test]
    fn unknown_model_pricing_still_exceeds_every_known_rate() {
        // Criterion 3 (S79): the unknown-model fallback must never undercount, even now that
        // opus (the fallback's original namesake) is cheaper than Claude Fable 5. Reconfirm the
        // fallback is still >= every real rate in MODEL_PRICING on both dimensions.
        let (unknown_in, unknown_out) = UNKNOWN_MODEL_PRICING;
        for p in MODEL_PRICING {
            assert!(
                unknown_in >= p.input_per_mtok,
                "unknown input rate ${unknown_in} must be >= {}'s ${}",
                p.prefix,
                p.input_per_mtok
            );
            assert!(
                unknown_out >= p.output_per_mtok,
                "unknown output rate ${unknown_out} must be >= {}'s ${}",
                p.prefix,
                p.output_per_mtok
            );
        }
    }

    #[test]
    fn sidecar_stats_aggregates_correctly() {
        let dir = std::env::temp_dir().join("vajra-test-sidecar");
        let _ = fs::create_dir_all(&dir);
        let stats_path = dir.join("stats.jsonl");
        let mut f = fs::File::create(&stats_path).unwrap();
        writeln!(f, r#"{{"lines_in":180,"lines_out":1,"command":"cargo"}}"#).unwrap();
        writeln!(f, r#"{{"lines_in":84,"lines_out":1,"command":"cargo"}}"#).unwrap();

        let stats = read_compression_stats(&stats_path).unwrap();
        assert_eq!(stats.lines_folded, 262);
        assert_eq!(stats.calls_compressed, 2);

        let _ = fs::remove_dir_all(&dir);
    }

    #[test]
    fn receipt_format_includes_all_fields() {
        let cost = SessionCost {
            session_id: "a1b2c3d4-e5f6".into(),
            model_breakdown: vec![ModelCost {
                model: "claude-opus-4-8".into(),
                assistant_lines: 42,
                dollars: 0.0859,
                tokens: TokenUsage {
                    input: 500,
                    output: 1000,
                    cache_read: 11000,
                    cache_write_5m: 0,
                    cache_write_1h: 5000,
                    web_search_requests: 0,
                    web_fetch_requests: 0,
                },
            }],
            total_dollars: 0.0859,
            authoritative_dollars: None,
            tool_record: None,
            unknown_models: vec![],
            compression: Some(CompressionStats {
                lines_folded: 83,
                calls_compressed: 7,
            }),
            estimated_tokens_saved: Some(996),
            estimated_dollars_saved: Some(0.0187),
            warnings: vec![],
        };

        let receipt = format_receipt(&cost);
        assert!(receipt.contains("$0.09"));
        assert!(receipt.contains("83 lines folded across 7 tool calls"));
        assert!(receipt.contains("~$0.0187 saved"));
        assert!(receipt.contains("opus-4-8 · 42 replies"));
        // No authoritative figure → the headline total is labeled an estimate (S66, criterion 2).
        assert!(
            receipt.contains("not the charge on your bill"),
            "an estimate must never read as the bill: {receipt}"
        );
    }

    /// A JSONL with a model absent from `MODEL_PRICING` (so priced at the unknown-model upper
    /// bound) AND an authoritative `total_cost_usd`. Headline must be the authoritative figure,
    /// the token estimate demoted + labeled, and the inflated overstatement never presented as
    /// the charge (S66).
    /// Uses `claude-mythos-5` — a real model the table doesn't price — standing in for the generic
    /// "unknown model" case. (S77 priced fable-5, which used to play this role; swap the id here if
    /// mythos-5 is ever added to the table.)
    fn unpriced_model_fixture_with_authoritative() -> String {
        // Unpriced-model assistant line with opus-scale cache tokens (would estimate ~opus rates),
        // plus the headless terminal result line carrying the real bill.
        r#"{"type":"assistant","message":{"model":"claude-mythos-5","usage":{"input_tokens":1000,"output_tokens":2000,"cache_read_input_tokens":500000,"cache_creation":{"ephemeral_5m_input_tokens":0,"ephemeral_1h_input_tokens":100000},"server_tool_use":{"web_search_requests":0,"web_fetch_requests":0}}}}
{"type":"result","subtype":"success","total_cost_usd":1.2662,"num_turns":17}"#
            .to_string()
    }

    #[test]
    fn authoritative_total_is_the_headline_estimate_is_labeled() {
        let dir = std::env::temp_dir().join("vajra-test-authoritative");
        let _ = fs::create_dir_all(&dir);
        let jsonl_path = dir.join("auth-session.jsonl");
        fs::write(&jsonl_path, unpriced_model_fixture_with_authoritative()).unwrap();

        let result = meter_session(&jsonl_path, None, None).unwrap();

        // Authoritative figure is captured and is what we bill against.
        assert_eq!(result.authoritative_dollars, Some(1.2662));
        assert!((result.billed_dollars() - 1.2662).abs() < 1e-9);
        // The unpriced model is flagged unknown, and the token estimate is the inflated
        // upper-bound number (proving the overstatement is real) — but it is NOT the billed figure.
        assert_eq!(result.unknown_models, vec!["claude-mythos-5".to_string()]);
        assert!(
            result.total_dollars > result.billed_dollars() * 2.0,
            "estimate {} should dwarf the authoritative {}",
            result.total_dollars,
            result.billed_dollars()
        );

        let receipt = format_receipt(&result);
        // Headline = authoritative; estimate present but labeled; upper-bound mispricing disclosed.
        assert!(
            receipt.contains("$1.27  what this run cost"),
            "receipt: {receipt}"
        );
        assert!(
            receipt.contains("Vajra's own estimate"),
            "receipt: {receipt}"
        );
        assert!(
            receipt.contains("priced at the unknown-model upper bound"),
            "receipt: {receipt}"
        );
        assert!(
            result
                .warnings
                .iter()
                .any(|w| w.contains("not in pricing table")),
            "unknown-model warning expected: {:?}",
            result.warnings
        );
        // The inflated estimate must never appear as the headline `total`.
        assert!(
            !receipt.contains(&format!("${:.4}  total", result.total_dollars)),
            "estimate leaked into headline: {receipt}"
        );

        let _ = fs::remove_dir_all(&dir);
    }

    #[test]
    fn missing_authoritative_falls_back_to_labeled_estimate() {
        let dir = std::env::temp_dir().join("vajra-test-fallback");
        let _ = fs::create_dir_all(&dir);
        let jsonl_path = dir.join("fallback-session.jsonl");
        // Known model, no `total_cost_usd` (older/interactive transcript).
        fs::write(&jsonl_path, fixture_jsonl()).unwrap();

        let result = meter_session(&jsonl_path, None, None).unwrap();
        assert!(result.authoritative_dollars.is_none());
        assert!((result.billed_dollars() - result.total_dollars).abs() < 1e-12);

        let receipt = format_receipt(&result);
        assert!(
            receipt.contains("not the charge on your bill"),
            "an estimate must never read as the bill: {receipt}"
        );
        assert!(
            result
                .warnings
                .iter()
                .any(|w| w == NO_REPORTED_COST_WARNING),
            "authoritative-absent note expected: {:?}",
            result.warnings
        );

        let _ = fs::remove_dir_all(&dir);
    }

    // ─── S78: recover the true $ from the tool's own result stream ───

    #[test]
    fn extract_result_cost_reads_stream_json_terminal_result() {
        // stream-json: line-delimited; the terminal `type:"result"` carries the bill. Earlier
        // non-result lines (system/assistant) must be ignored; only the result's cost is read.
        let stdout = concat!(
            r#"{"type":"system","subtype":"init","session_id":"abc"}"#,
            "\n",
            r#"{"type":"assistant","message":{"model":"claude-fable-5"}}"#,
            "\n",
            r#"{"type":"result","subtype":"success","total_cost_usd":0.4211,"num_turns":9}"#,
            "\n"
        )
        .as_bytes();
        assert_eq!(extract_result_cost(stdout), Some(0.4211));
    }

    #[test]
    fn extract_result_cost_reads_single_json_object() {
        // `--output-format json`: one (here pretty-printed, multi-line) JSON object, not lines.
        let stdout = r#"{
  "type": "result",
  "subtype": "success",
  "total_cost_usd": 1.9032,
  "result": "done"
}"#
        .as_bytes();
        assert_eq!(extract_result_cost(stdout), Some(1.9032));
    }

    #[test]
    fn extract_result_cost_none_for_text_and_garbage() {
        // Text-mode headless output (plain answer, no result line) → None → honest fallback stands.
        assert_eq!(
            extract_result_cost(b"here is your answer, no json at all"),
            None
        );
        // A result line without a cost field, and a non-result line with a cost-shaped field, are
        // both ignored — we never guess a bill from a non-`result` line.
        assert_eq!(
            extract_result_cost(br#"{"type":"result","subtype":"error_max_turns"}"#),
            None
        );
        assert_eq!(
            extract_result_cost(br#"{"type":"assistant","total_cost_usd":99.0}"#),
            None
        );
        assert_eq!(extract_result_cost(b""), None);
    }

    #[test]
    fn apply_captured_cost_supersedes_absent_and_drops_the_warning() {
        // A known model, no `total_cost_usd` in the transcript → honest "no authoritative" state.
        let dir = std::env::temp_dir().join("vajra-test-apply-captured");
        let _ = fs::create_dir_all(&dir);
        let jsonl_path = dir.join("s.jsonl");
        fs::write(&jsonl_path, fixture_jsonl()).unwrap();
        let mut cost = meter_session(&jsonl_path, None, None).unwrap();
        assert!(cost.authoritative_dollars.is_none());
        assert!(cost.warnings.iter().any(|w| w == NO_REPORTED_COST_WARNING));

        // Feed the tool's own captured cost (S78) → it becomes the bill and the absent-warning goes.
        cost.apply_captured_cost(Some(0.4211));
        assert_eq!(cost.authoritative_dollars, Some(0.4211));
        assert!((cost.billed_dollars() - 0.4211).abs() < 1e-9);
        assert!(
            !cost.warnings.iter().any(|w| w == NO_REPORTED_COST_WARNING),
            "authoritative-absent warning must be dropped: {:?}",
            cost.warnings
        );
        let receipt = format_receipt(&cost);
        assert!(
            receipt.contains("$0.42  what this run cost"),
            "receipt: {receipt}"
        );
        assert!(
            !receipt.contains("no cost from Claude Code"),
            "receipt: {receipt}"
        );

        let _ = fs::remove_dir_all(&dir);
    }

    #[test]
    fn apply_captured_cost_none_is_a_noop_and_does_not_override_existing() {
        // None (interactive / text-mode) is a no-op: S77's honest fallback stands (criterion 2).
        let dir = std::env::temp_dir().join("vajra-test-apply-noop");
        let _ = fs::create_dir_all(&dir);
        let jsonl_path = dir.join("s.jsonl");
        fs::write(&jsonl_path, fixture_jsonl()).unwrap();
        let mut cost = meter_session(&jsonl_path, None, None).unwrap();
        cost.apply_captured_cost(None);
        assert!(cost.authoritative_dollars.is_none());
        assert!(cost.warnings.iter().any(|w| w == NO_REPORTED_COST_WARNING));

        // A transcript that already carried its own authoritative figure is not overridden.
        fs::write(&jsonl_path, unpriced_model_fixture_with_authoritative()).unwrap();
        let mut cost = meter_session(&jsonl_path, None, None).unwrap();
        assert_eq!(cost.authoritative_dollars, Some(1.2662));
        cost.apply_captured_cost(Some(9.99));
        assert_eq!(
            cost.authoritative_dollars,
            Some(1.2662),
            "an existing authoritative figure must not be overridden by a captured one"
        );

        let _ = fs::remove_dir_all(&dir);
    }

    /// S78 regression on a REAL captured headless result stream: a `claude -p
    /// --output-format stream-json` stdout slice whose terminal `type:"result"` line carries the
    /// SDK-authoritative `total_cost_usd`. Proves the end-to-end recovery — the launcher tees this
    /// stream, `extract_result_cost` reads the figure, and `apply_captured_cost` makes it the
    /// receipt headline (what S77 could not do). Real captured data (see the fixture's provenance).
    #[test]
    fn s78_real_captured_result_stream_yields_authoritative_headline() {
        let fixture = Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("sessions/session-78-artifacts/fixtures/s78-headless-result-stream.txt");
        let stdout = fs::read(&fixture).expect("real captured result-stream fixture");

        // The tool's own end-of-session cost is recoverable from the captured stream ...
        let captured = extract_result_cost(&stdout);
        assert!(
            captured.is_some(),
            "expected a real total_cost_usd in the captured stream"
        );

        // ... and feeding it to the meter (which, on an on-disk transcript, has no figure) makes it
        // the authoritative headline — the S77→S78 promotion from "no authoritative" to a real $.
        let transcript = Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("sessions/session-76-artifacts/fixtures/s76-fable-headless.jsonl");
        let mut cost = meter_session(&transcript, None, None).unwrap();
        assert!(
            cost.authoritative_dollars.is_none(),
            "transcript has no cost"
        );
        cost.apply_captured_cost(captured);
        assert_eq!(cost.authoritative_dollars, captured);
        assert!((cost.billed_dollars() - captured.unwrap()).abs() < 1e-9);

        let receipt = format_receipt(&cost);
        assert!(receipt.contains("what this run cost"), "receipt: {receipt}");
        assert!(
            !receipt.contains("no cost from Claude Code"),
            "captured cost must supersede the honest fallback: {receipt}"
        );
    }

    /// S77 regression on the REAL S76 dogfood data: headless `vajra claude` on chitra, model
    /// `claude-fable-5`, an on-disk session transcript with NO `type:"result"` line. Proves the
    /// two S77 fixes together — (1) fable-5 is priced at its real rates ($10/$50), not the opus
    /// upper bound; (2) with no authoritative `total_cost_usd`, the receipt says "no authoritative
    /// cost available" and never dresses the estimate up as a total. The fixture is real captured
    /// data (see its `_provenance` line), read from the repo tree at test time.
    #[test]
    fn s76_fable_headless_fixture_prices_fable_and_reports_no_authoritative() {
        // fable-5 is now a known, priced model — no opus-upper-bound fallback (criterion 1).
        assert!(is_known_model("claude-fable-5"));
        assert_eq!(pricing_for("claude-fable-5"), (10.0, 50.0));

        let fixture = Path::new(env!("CARGO_MANIFEST_DIR"))
            .join("sessions/session-76-artifacts/fixtures/s76-fable-headless.jsonl");
        let result = meter_session(&fixture, None, None).unwrap();

        // The on-disk transcript carries no `total_cost_usd` (the S76 finding) ...
        assert!(result.authoritative_dollars.is_none());
        // ... and fable-5 is priced, so it is NOT flagged as an unknown/opus-bound model.
        assert!(
            result.unknown_models.is_empty(),
            "fable-5 should be priced, got unknown: {:?}",
            result.unknown_models
        );
        assert_eq!(result.model_breakdown.len(), 1);
        assert_eq!(result.model_breakdown[0].model, "claude-fable-5");
        assert_eq!(result.model_breakdown[0].assistant_lines, 2);

        // Estimate is at REAL fable rates, not the unknown-model upper bound. Hand calc over the two real
        // turns (input 7918, output 700, cache_read 45969, cache_write_1h 4494) at $10/$50:
        //   input:   7918  * 10        / 1e6 = 0.079180
        //   output:  700   * 50        / 1e6 = 0.035000
        //   cache_r: 45969 * 10 * 0.10 / 1e6 = 0.045969
        //   cache_w: 4494  * 10 * 2.00 / 1e6 = 0.089880
        //   total = 0.250029
        assert!(
            (result.total_dollars - 0.250029).abs() < 1e-4,
            "expected fable-priced estimate ~0.2500, got {}",
            result.total_dollars
        );

        let receipt = format_receipt(&result);
        // No authoritative figure → the headline is the honest statement, never a `$… total`
        // (criterion 2).
        assert!(
            receipt.contains(" no cost from Claude Code for this run  ("),
            "receipt: {receipt}"
        );
        assert!(
            !receipt.contains("  total"),
            "estimate must not masquerade as a total: {receipt}"
        );
        // The estimate is still shown, labeled — and NOT with the unknown-model tag anymore.
        assert!(
            receipt.contains("Vajra's own estimate"),
            "receipt: {receipt}"
        );
        assert!(
            receipt.contains("not the charge on your bill"),
            "an estimate must never read as the bill: {receipt}"
        );
        assert!(
            !receipt.contains("priced at the unknown-model upper bound"),
            "fable-5 is priced now — no unknown-model tag: {receipt}"
        );
        // The authoritative-absent warning still fires so the reason is explicit.
        assert!(
            result
                .warnings
                .iter()
                .any(|w| w == NO_REPORTED_COST_WARNING),
            "warnings: {:?}",
            result.warnings
        );
    }

    // ─── S189: Claude Code's own `cost-state` record (F67) ─────────────────────────────────────
    // Fixture: two runs of one conversation, built around the REAL `cost-state` lines of a Claude
    // Code 2.1.280 transcript (4.648… after run 1, 13.943… after run 2, written twice at one exit).
    // A tripwire too (design-advisor rec 8): Claude Code calls the line format internal.

    const S189_FIXTURE: &str = include_str!("../../tests/fixtures/meter/cost-state-2.1.280.jsonl");
    const S189_RUN1: f64 = 4.648155399999999;
    const S189_RUN2_TOTAL: f64 = 13.94323919999999;

    fn s189_ms(ts: &str) -> u64 {
        parse_utc_ms(ts).unwrap()
    }
    fn s189_lines(keep: impl Fn(usize, &str) -> bool) -> String {
        S189_FIXTURE
            .lines()
            .enumerate()
            .filter(|(i, l)| keep(*i, l))
            .map(|(_, l)| format!("{l}\n"))
            .collect()
    }
    fn s189_meter(name: &str, text: &str, launch: Option<&str>) -> SessionCost {
        let dir = std::env::temp_dir().join(format!("vajra-s189-{name}-{}", std::process::id()));
        fs::create_dir_all(&dir).unwrap();
        let path = dir.join("69ecb30e-f3ea-4691-84aa-4fe8e8630ef8.jsonl");
        fs::write(&path, text).unwrap();
        let launch =
            launch.map(|t| std::time::UNIX_EPOCH + std::time::Duration::from_millis(s189_ms(t)));
        let cost = meter_run(&path, None, None, launch).unwrap();
        let _ = fs::remove_dir_all(&dir);
        cost
    }
    fn s189_headline(receipt: &str) -> &str {
        receipt.lines().nth(1).unwrap_or("")
    }

    #[test]
    fn s189_timestamps_read_only_in_the_shape_claude_code_writes() {
        // The fixture's startTime 1790227599460 is 2026-09-24T05:26:39.460Z.
        assert_eq!(
            parse_utc_ms("2026-09-24T05:26:39.460Z"),
            Some(1_790_227_599_460)
        );
        assert_eq!(
            parse_utc_ms("2026-09-24T05:26:39Z"),
            Some(1_790_227_599_000)
        );
        assert_eq!(parse_utc_ms("1970-01-01T00:00:00.001Z"), Some(1));
        for bad in [
            "",
            "2026-09-24 05:26:39.460Z",
            "2026-09-24T05:26:39.460+01:00",
            "2026-09-24T05:26:39.460",
            "2026-13-24T05:26:39.460Z",
            "2026-09-24T05:26:39.Z",
            "２026-09-24T05:26:39.460Z",
        ] {
            assert_eq!(parse_utc_ms(bad), None, "{bad:?} must not read");
        }
    }

    #[test]
    fn s189_a_fresh_run_is_claude_codes_own_total() {
        let run1 = s189_lines(|i, _| i < 6);
        assert_eq!(
            cost_state_record(&run1, Some(s189_ms("2026-09-24T05:26:39.000Z"))),
            Some(ToolRecord::ThisRun {
                dollars: S189_RUN1,
                unpriced: false
            })
        );
        // AC1: the receipt's headline IS that figure, not the price-list estimate.
        let cost = s189_meter("fresh", &run1, Some("2026-09-24T05:26:39.000Z"));
        let receipt = format_receipt(&cost);
        assert_eq!(cost.headline_dollars(), Some(S189_RUN1));
        assert!(
            s189_headline(&receipt)
                .starts_with(" $4.65  what this run cost — Claude Code's own figure"),
            "receipt: {receipt}"
        );
        assert!(
            receipt.lines().nth(2).unwrap().contains("[estimate"),
            "the token figure stays, labelled: {receipt}"
        );
        assert!(!cost.warnings.iter().any(|w| w == NO_REPORTED_COST_WARNING));
    }

    #[test]
    fn s189_a_resumed_run_is_its_own_share_and_duplicates_are_never_added() {
        let launch = Some(s189_ms("2026-09-24T11:49:40.000Z"));
        match cost_state_record(S189_FIXTURE, launch) {
            Some(ToolRecord::ThisRun {
                dollars,
                unpriced: false,
            }) => {
                assert!(
                    (dollars - (S189_RUN2_TOTAL - S189_RUN1)).abs() < 1e-9,
                    "{dollars}"
                )
            }
            other => panic!("expected this run's share, got {other:?}"),
        }
        let cost = s189_meter("resume", S189_FIXTURE, Some("2026-09-24T11:49:40.000Z"));
        assert!(s189_headline(&format_receipt(&cost)).starts_with(" $9.30  what this run cost"));
    }

    #[test]
    fn s189_no_record_from_this_run_means_no_figure() {
        // A crash or a kill: run 2's lines are there, its cost-state lines are not.
        let crashed = s189_lines(|i, _| i < 12);
        let crashed = crashed.trim_end().rsplit_once('\n').unwrap().0.to_string() + "\n";
        assert!(crashed.matches("cost-state").count() == 1, "{crashed}");
        assert_eq!(
            cost_state_record(&crashed, Some(s189_ms("2026-09-24T11:49:40.000Z"))),
            None
        );
        // No line from this run at all (no cut): no figure either.
        assert_eq!(
            cost_state_record(S189_FIXTURE, Some(s189_ms("2026-09-25T00:00:00.000Z"))),
            None
        );
        // A total that is not a number, or negative: no figure.
        let neg = s189_lines(|i, _| i < 6).replace(
            "\"totalCostUSD\":4.648155399999999",
            "\"totalCostUSD\":-1.0",
        );
        assert_eq!(
            cost_state_record(&neg, Some(s189_ms("2026-09-24T05:26:39.000Z"))),
            None
        );
        let txt = s189_lines(|i, _| i < 6).replace(
            "\"totalCostUSD\":4.648155399999999",
            "\"totalCostUSD\":\"4.6\"",
        );
        assert_eq!(
            cost_state_record(&txt, Some(s189_ms("2026-09-24T05:26:39.000Z"))),
            None
        );
        // AC2: the headline says so, and the estimate is a labelled line beneath — never the headline.
        let cost = s189_meter("crash", &crashed, Some("2026-09-24T11:49:40.000Z"));
        let receipt = format_receipt(&cost);
        let head = s189_headline(&receipt);
        assert!(
            head.starts_with(" no cost from Claude Code for this run"),
            "receipt: {receipt}"
        );
        assert!(
            !head.contains('$'),
            "no dollar figure on the headline: {receipt}"
        );
        assert!(
            receipt.lines().nth(2).unwrap().contains("[estimate"),
            "receipt: {receipt}"
        );
        assert_eq!(cost.headline_dollars(), None);
    }

    #[test]
    fn s189_spend_from_before_this_run_is_never_called_this_runs_cost() {
        // Run 2's lines only: no earlier total to subtract, and startTime is before the launch.
        let run2 = s189_lines(|i, _| i >= 6);
        let launch = Some(s189_ms("2026-09-24T11:49:40.000Z"));
        assert_eq!(
            cost_state_record(&run2, launch),
            Some(ToolRecord::IncludesEarlierSpend {
                dollars: S189_RUN2_TOTAL
            })
        );
        let cost = s189_meter("fork", &run2, Some("2026-09-24T11:49:40.000Z"));
        let receipt = format_receipt(&cost);
        assert!(s189_headline(&receipt).starts_with(" no cost from Claude Code for this run"));
        assert!(receipt.contains("$13.94  Claude Code's total for this whole conversation — includes spend before this run"));
        assert_eq!(cost.headline_dollars(), None);
        // No startTime at all: fail closed the same way.
        let no_start = s189_lines(|i, _| i < 6).replace("\"startTime\":1790227599460,", "");
        assert!(matches!(
            cost_state_record(&no_start, Some(s189_ms("2026-09-24T05:26:39.000Z"))),
            Some(ToolRecord::IncludesEarlierSpend { .. })
        ));
    }

    #[test]
    fn s189_vajra_meter_on_a_file_shows_the_whole_conversation_labelled() {
        assert_eq!(
            cost_state_record(S189_FIXTURE, None),
            Some(ToolRecord::WholeConversation {
                dollars: S189_RUN2_TOTAL,
                unpriced: false
            })
        );
        let cost = s189_meter("file", S189_FIXTURE, None);
        let receipt = format_receipt(&cost);
        assert!(s189_headline(&receipt).starts_with(
            " $13.94  Claude Code's own total for this whole conversation (every run in this file)"
        ));
        assert!(!receipt.contains("what this run cost"), "{receipt}");
    }

    #[test]
    fn s189_an_unknown_model_never_makes_the_headline_a_guess() {
        // AC3: a made-up model with no price row and no record from Claude Code.
        let opus9 = s189_lines(|i, _| i < 5).replace("claude-opus-5-5", "claude-opus-9");
        let cost = s189_meter("opus9", &opus9, Some("2026-09-24T05:26:39.000Z"));
        let receipt = format_receipt(&cost);
        let head = s189_headline(&receipt);
        assert!(
            head.starts_with(" no cost from Claude Code for this run"),
            "{receipt}"
        );
        assert!(!head.contains('$'), "{receipt}");
        assert!(cost.unknown_models.contains(&"claude-opus-9".to_string()));
        assert!(
            receipt
                .lines()
                .nth(2)
                .unwrap()
                .contains("unknown-model upper bound"),
            "{receipt}"
        );
        // With a record Claude Code could not fully price: still its figure, and it says so.
        let unpriced = s189_lines(|i, _| i < 6)
            .replace("claude-opus-5-5", "claude-opus-9")
            .replace(
                "\"hasUnknownModelCost\":false",
                "\"hasUnknownModelCost\":true",
            );
        let cost = s189_meter("opus9-rec", &unpriced, Some("2026-09-24T05:26:39.000Z"));
        let receipt = format_receipt(&cost);
        assert!(s189_headline(&receipt)
            .starts_with(" $4.65  what this run cost — Claude Code's own figure"));
        assert!(
            receipt.contains("Claude Code could not price every model in this run"),
            "{receipt}"
        );
    }

    #[test]
    fn s189_the_p_stream_still_wins_over_the_transcript_record() {
        // AC4: a headless run also writes a cost-state line; the captured stream stays the headline.
        let mut cost = s189_meter(
            "p",
            &s189_lines(|i, _| i < 6),
            Some("2026-09-24T05:26:39.000Z"),
        );
        cost.apply_captured_cost(Some(0.4211));
        let receipt = format_receipt(&cost);
        assert!(
            s189_headline(&receipt).starts_with(" $0.42  what this run cost  ("),
            "{receipt}"
        );
        assert!(!receipt.contains("Claude Code's own figure"), "{receipt}");
        assert_eq!(cost.billed_dollars(), 0.4211);
    }

    #[test]
    fn s189_a_missing_or_unreadable_record_is_named_not_silent() {
        let launch = Some(s189_ms("2026-09-24T11:49:40.000Z"));
        // Run 2 names Claude Code 2.1.280 and wrote no cost-state line: named.
        let crashed: String = s189_lines(|i, _| i < 11);
        let w = cost_state_warning(&crashed, launch).expect("a crash on 2.1.280 is named");
        assert!(
            w.contains("Claude Code 2.1.280 records its own cost"),
            "{w}"
        );
        // A record whose total is not a number: the format may have changed — named.
        let renamed = S189_FIXTURE.replace("\"totalCostUSD\"", "\"totalCostUsd\"");
        assert!(cost_state_warning(&renamed, launch)
            .unwrap()
            .contains("may have changed"));
        // A normal run, or Claude Code before 2.1.275: nothing to say.
        assert_eq!(cost_state_warning(S189_FIXTURE, launch), None);
        let old = crashed.replace("\"version\":\"2.1.280\"", "\"version\":\"2.1.200\"");
        assert_eq!(cost_state_warning(&old, launch), None);
        // And it reaches the receipt.
        let cost = s189_meter("drift", &crashed, Some("2026-09-24T11:49:40.000Z"));
        assert!(
            format_receipt(&cost).contains("[vajra warn] Claude Code 2.1.280 records its own cost")
        );
    }
}
