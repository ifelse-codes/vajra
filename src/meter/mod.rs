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
];

const WEB_SEARCH_PER_REQUEST: f64 = 0.01;
const WEB_FETCH_PER_REQUEST: f64 = 0.01;
const TOKENS_PER_LINE_ESTIMATE: f64 = 12.0;

fn pricing_for(model: &str) -> (f64, f64) {
    for p in MODEL_PRICING {
        if model.starts_with(p.prefix) {
            return (p.input_per_mtok, p.output_per_mtok);
        }
    }
    (15.0, 75.0)
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
    pub total_dollars: f64,
    pub compression: Option<CompressionStats>,
    pub estimated_tokens_saved: Option<u64>,
    pub estimated_dollars_saved: Option<f64>,
    pub warnings: Vec<String>,
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

    parse_jsonl(main_jsonl, &mut model_map, &mut warnings)?;

    if let Some(dir) = subagent_dir {
        if dir.exists() {
            if let Ok(entries) = fs::read_dir(dir) {
                for entry in entries.flatten() {
                    let path = entry.path();
                    if path.extension().and_then(|e| e.to_str()) == Some("jsonl") {
                        let _ = parse_jsonl(&path, &mut model_map, &mut warnings);
                    }
                }
            }
        }
    }

    let mut model_breakdown: Vec<ModelCost> = Vec::new();
    let mut total_dollars = 0.0;

    for (model, (tokens, lines)) in &model_map {
        let dollars = line_dollars(tokens, model);
        total_dollars += dollars;
        model_breakdown.push(ModelCost {
            model: model.clone(),
            assistant_lines: *lines,
            dollars,
            tokens: tokens.clone(),
        });
    }

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

    Ok(SessionCost {
        session_id,
        model_breakdown,
        total_dollars,
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
    out.push_str(&format!(
        " ${:.4}  total  ({})\n",
        cost.total_dollars,
        model_summary.join(" · ")
    ));

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
        assert!(result.warnings.is_empty());

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
    }
}
