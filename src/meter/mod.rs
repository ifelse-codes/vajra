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

const WEB_SEARCH_PER_REQUEST: f64 = 0.01;
const WEB_FETCH_PER_REQUEST: f64 = 0.01;
const TOKENS_PER_LINE_ESTIMATE: f64 = 12.0;

/// Rate used to *estimate* a model absent from `MODEL_PRICING`. It is opus (the priciest
/// tier) so the estimate is an upper bound, never an undercount — but an unknown model priced
/// this way is always surfaced (`is_known_model` → `SessionCost.unknown_models`) and labeled in
/// the receipt, so it can never be silently reported as the authoritative charge (S66).
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
/// to `UNKNOWN_MODEL_PRICING` (opus upper bound) — the token estimate for it is unreliable and
/// must be labeled, not presented as the bill (S66 root cause: `claude-fable-5` priced as opus).
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
        self.authoritative_dollars.unwrap_or(self.total_dollars)
    }
}

// ─── core ──────────────────────────────────────────────────────────

pub fn meter_session(
    main_jsonl: &Path,
    subagent_dir: Option<&Path>,
    compression_stats: Option<CompressionStats>,
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
            "model(s) {} not in pricing table — token estimate uses the opus upper bound, not real \
             rates; trust the authoritative total, not the estimate",
            unknown_models.join(", ")
        ));
    }
    if authoritative_dollars.is_none() {
        warnings.push(
            "no total_cost_usd in JSONL — no authoritative cost available; the figure shown is a \
             token estimate only, not the charge"
                .into(),
        );
    }

    Ok(SessionCost {
        session_id,
        model_breakdown,
        total_dollars,
        authoritative_dollars,
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
            format!("{} {} lines", short_model, m.assistant_lines)
        })
        .collect();

    // Headline = the authoritative `total_cost_usd` when the JSONL carried it; the token recompute
    // is then demoted to a labeled `[estimate]` line beneath it. When NO authoritative figure
    // exists, the headline is NOT a dollar total at all — it says "no authoritative cost available"
    // and the token estimate rides a clearly-secondary `~$… token estimate` line (S77, criterion 2:
    // an estimate is never presented as a total). The estimate tag also flags any unknown model
    // whose rate fell back to the opus upper bound (S66) — though S77 priced fable-5, so the S76
    // fixture now shows the plain `[estimate]` tag at real rates, not the opus-bound one.
    let estimate_tag = if cost.unknown_models.is_empty() {
        "[estimate]".to_string()
    } else {
        format!(
            "[estimate · {} priced as opus upper bound, not real rates]",
            cost.unknown_models.join(", ").replace("claude-", "")
        )
    };
    match cost.authoritative_dollars {
        Some(authoritative) => {
            out.push_str(&format!(
                " ${:.4}  total  ({})\n",
                authoritative,
                model_summary.join(" · ")
            ));
            out.push_str(&format!(
                "         ${:.4}  token estimate  {}\n",
                cost.total_dollars, estimate_tag
            ));
        }
        None => {
            out.push_str(&format!(
                " no authoritative cost available  ({})\n",
                model_summary.join(" · ")
            ));
            out.push_str(&format!(
                "         ~${:.4}  token estimate  {}\n",
                cost.total_dollars, estimate_tag
            ));
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
        .unwrap_or((15.0, 75.0));
    let input_cost = total_tokens.input as f64 * primary_input / 1e6;
    let output_cost = total_tokens.output as f64 * primary_output / 1e6;
    let cache_r_cost = total_tokens.cache_read as f64 * primary_input * 0.10 / 1e6;
    let cache_w_cost = (total_tokens.cache_write_5m as f64 * primary_input * 1.25
        + total_tokens.cache_write_1h as f64 * primary_input * 2.0)
        / 1e6;
    out.push_str(&format!(
        "         input ${:.4} · output ${:.4} · cache-r ${:.4} · cache-w ${:.4}\n",
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

        // Hand calculation for opus (input=$15/MTok, output=$75/MTok):
        // input:  60 * 15 / 1e6 = 0.000900
        // output: 332 * 75 / 1e6 = 0.024900
        // cache_read: 16586 * 15 * 0.10 / 1e6 = 0.024879
        // cache_write_5m: 300 * 15 * 1.25 / 1e6 = 0.005625
        // cache_write_1h: 7628 * 15 * 2.0 / 1e6 = 0.228840
        // total = 0.285144
        let expected = 0.285144;
        assert!(
            (result.total_dollars - expected).abs() < 0.0001,
            "got {}, expected {}",
            result.total_dollars,
            expected
        );

        let _ = fs::remove_dir_all(&dir);
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
        assert!(receipt.contains("$0.0859"));
        assert!(receipt.contains("83 lines folded across 7 tool calls"));
        assert!(receipt.contains("~$0.0187 saved"));
        assert!(receipt.contains("opus-4-8 42 lines"));
        // No authoritative figure → the headline total is labeled an estimate (S66, criterion 2).
        assert!(receipt.contains("[estimate]"), "receipt: {receipt}");
    }

    /// A JSONL with a model absent from `MODEL_PRICING` (so priced at the opus upper bound) AND an
    /// authoritative `total_cost_usd`. Headline must be the authoritative figure, the token estimate
    /// demoted + labeled, and the opus-priced overstatement never presented as the charge (S66).
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
        // The unpriced model is flagged unknown, and the token estimate is the inflated opus-priced
        // number (proving the overstatement is real) — but it is NOT the billed figure.
        assert_eq!(result.unknown_models, vec!["claude-mythos-5".to_string()]);
        assert!(
            result.total_dollars > result.billed_dollars() * 2.0,
            "estimate {} should dwarf the authoritative {}",
            result.total_dollars,
            result.billed_dollars()
        );

        let receipt = format_receipt(&result);
        // Headline = authoritative; estimate present but labeled; opus-mispricing disclosed.
        assert!(receipt.contains("$1.2662  total"), "receipt: {receipt}");
        assert!(receipt.contains("token estimate"), "receipt: {receipt}");
        assert!(
            receipt.contains("priced as opus upper bound"),
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
        assert!(receipt.contains("[estimate]"), "receipt: {receipt}");
        assert!(
            result
                .warnings
                .iter()
                .any(|w| w.contains("no total_cost_usd")),
            "authoritative-absent note expected: {:?}",
            result.warnings
        );

        let _ = fs::remove_dir_all(&dir);
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

        // Estimate is at REAL fable rates, not the opus upper bound. Hand calc over the two real
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
            receipt.contains("no authoritative cost available"),
            "receipt: {receipt}"
        );
        assert!(
            !receipt.contains("  total"),
            "estimate must not masquerade as a total: {receipt}"
        );
        // The estimate is still shown, labeled — and NOT with the opus-upper-bound tag anymore.
        assert!(receipt.contains("token estimate"), "receipt: {receipt}");
        assert!(receipt.contains("[estimate]"), "receipt: {receipt}");
        assert!(
            !receipt.contains("priced as opus upper bound"),
            "fable-5 is priced now — no opus-bound tag: {receipt}"
        );
        // The authoritative-absent warning still fires so the reason is explicit.
        assert!(
            result
                .warnings
                .iter()
                .any(|w| w.contains("no total_cost_usd")),
            "warnings: {:?}",
            result.warnings
        );
    }
}
