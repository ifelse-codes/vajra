//! Obedience metric (S48) — did the agent obey the rails?
//!
//! `obedience % = clean ÷ (clean + blocked)` mined **read-only** from a session
//! transcript (the same JSONL the meter parses, ADR-0004). Instrumentation only:
//! this module never blocks, never writes, adds no guidance and no dependency.
//!
//! ## Signal (the S48 design call)
//! A Vajra rail block already surfaces *in the trace itself*: when a PreToolUse
//! hook exits 2, Claude Code records a `tool_result` with `is_error: true` whose
//! content is `PreToolUse:<Tool> hook error: [bash "…hook-*.sh"]: [vajra …] …`.
//! So we detect blocks from the JSONL alone — no hook change, and it works on
//! **past** sessions (enables a cross-session baseline, S49).
//!
//! ## What it does NOT prove (the honesty bar)
//! - It measures obedience to the **rails**, NOT whether the *output was better*.
//!   A session can be 100% obedient and still ship bad work. First rung of the
//!   ladder, a proxy — not the whole answer.
//! - It counts only **hook-attributed** blocks (coupled to CC's `hook error`
//!   wording + Vajra's `[vajra …]` marker). A rule the agent silently works
//!   around, or rework with no hook fire, is invisible → this is a **floor** on
//!   friction, not a ceiling.

use anyhow::{Context, Result};
use serde_json::Value;
use std::collections::BTreeMap;
use std::collections::HashSet;
use std::path::Path;

/// One rail block, kept for traceability (counts trace back to their source).
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct BlockRecord {
    pub tool_use_id: String,
    /// e.g. `hook-copilot-loader.sh` (best-effort parse of the block text).
    pub hook: String,
    /// e.g. `Bash` (the tool the hook gated).
    pub tool: String,
}

#[derive(Debug, Clone)]
pub struct Obedience {
    /// Distinct tool-call attempts in the transcript.
    pub total_tool_calls: u64,
    /// Attempts that proceeded without a rail block.
    pub clean: u64,
    /// Attempts stopped by a Vajra rail (exit-2 hook block).
    pub blocked: u64,
    /// `clean ÷ total` as a percentage; 100.0 when there were no tool calls.
    pub obedience_pct: f64,
    /// Per-block detail; empty when the session was fully clean.
    pub blocks: Vec<BlockRecord>,
}

impl Obedience {
    /// `blocked` grouped by hook name, most-frequent first — the traceable source.
    pub fn blocks_by_hook(&self) -> Vec<(String, u64)> {
        let mut counts: BTreeMap<String, u64> = BTreeMap::new();
        for b in &self.blocks {
            *counts.entry(b.hook.clone()).or_insert(0) += 1;
        }
        let mut v: Vec<(String, u64)> = counts.into_iter().collect();
        v.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| a.0.cmp(&b.0)));
        v
    }
}

/// Compute the obedience metric for a session transcript.
pub fn obedience_for(main_jsonl: &Path) -> Result<Obedience> {
    let content = std::fs::read_to_string(main_jsonl)
        .with_context(|| format!("failed to read JSONL: {}", main_jsonl.display()))?;
    Ok(obedience_from_str(&content))
}

/// Core: parse a transcript string into the metric. Pure, so it is unit-tested.
pub fn obedience_from_str(transcript: &str) -> Obedience {
    let mut tool_ids: HashSet<String> = HashSet::new();
    let mut blocks: Vec<BlockRecord> = Vec::new();
    let mut seen_block_ids: HashSet<String> = HashSet::new();

    for line in transcript.lines() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }
        let entry: Value = match serde_json::from_str(line) {
            Ok(v) => v,
            Err(_) => continue,
        };
        let content = match entry["message"]["content"].as_array() {
            Some(c) => c,
            None => continue,
        };

        match entry["type"].as_str() {
            Some("assistant") => {
                for block in content {
                    if block["type"].as_str() == Some("tool_use") {
                        if let Some(id) = block["id"].as_str() {
                            tool_ids.insert(id.to_string());
                        }
                    }
                }
            }
            Some("user") => {
                for block in content {
                    if block["type"].as_str() != Some("tool_result") {
                        continue;
                    }
                    if block["is_error"].as_bool() != Some(true) {
                        continue;
                    }
                    let text = block_text(&block["content"]);
                    if !is_vajra_hook_block(&text) {
                        continue;
                    }
                    let id = block["tool_use_id"].as_str().unwrap_or("").to_string();
                    // Dedupe: one block per gated tool call.
                    if !id.is_empty() && !seen_block_ids.insert(id.clone()) {
                        continue;
                    }
                    let (hook, tool) = parse_block_meta(&text);
                    blocks.push(BlockRecord {
                        tool_use_id: id,
                        hook,
                        tool,
                    });
                }
            }
            _ => {}
        }
    }

    // A block always corresponds to a real tool-call attempt; fold block ids into
    // the id set so an out-of-order or truncated transcript never yields
    // blocked > total.
    let mut all_ids = tool_ids;
    for b in &blocks {
        if !b.tool_use_id.is_empty() {
            all_ids.insert(b.tool_use_id.clone());
        }
    }
    let total = all_ids.len() as u64;
    let blocked = blocks.len() as u64;
    let clean = total.saturating_sub(blocked);
    let obedience_pct = if total > 0 {
        clean as f64 / total as f64 * 100.0
    } else {
        100.0
    };

    Obedience {
        total_tool_calls: total,
        clean,
        blocked,
        obedience_pct,
        blocks,
    }
}

/// A Vajra rail block = Claude Code's PreToolUse `hook error` wording carrying
/// Vajra's own `[vajra …]` marker. Requiring both avoids counting a plain tool
/// failure or a non-Vajra hook.
fn is_vajra_hook_block(text: &str) -> bool {
    text.contains("hook error") && text.to_lowercase().contains("vajra")
}

/// Flatten a tool_result `content` field (string, or an array of text blocks).
fn block_text(content: &Value) -> String {
    match content {
        Value::String(s) => s.clone(),
        Value::Array(arr) => arr
            .iter()
            .filter_map(|b| b["text"].as_str())
            .collect::<Vec<_>>()
            .join(" "),
        Value::Null => String::new(),
        other => other.to_string(),
    }
}

/// Best-effort parse of the hook script name + gated tool from the block text
/// `PreToolUse:Bash hook error: [bash "…/hook-foo.sh"]: [vajra …] …`.
fn parse_block_meta(text: &str) -> (String, String) {
    let hook = text
        .find("hook-")
        .and_then(|start| {
            let rest = &text[start..];
            rest.find(".sh").map(|end| rest[..end + 3].to_string())
        })
        .unwrap_or_else(|| "unknown-hook".to_string());

    let tool = text
        .strip_prefix("PreToolUse:")
        .and_then(|rest| rest.split_whitespace().next())
        .unwrap_or("?")
        .to_string();

    (hook, tool)
}

/// A compact, glanceable receipt line (rides `vajra meter`, no 8th command).
pub fn format_obedience(o: &Obedience) -> String {
    let mut out = String::new();
    if o.total_tool_calls == 0 {
        out.push_str(" obedience  —  (no tool calls in this session)\n");
        return out;
    }
    out.push_str(&format!(
        " obedience {:.1}%  ·  {} clean / {} blocked  ({} tool calls)\n",
        o.obedience_pct, o.clean, o.blocked, o.total_tool_calls
    ));
    for (hook, n) in o.blocks_by_hook() {
        out.push_str(&format!("           ↳ {} rail block(s): {}\n", n, hook));
    }
    out.push_str(" obedience = obeyed the rails, NOT proof the work was better (a floor, S48)\n");
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    // A real-shaped copilot-loader block (verbatim signature from a live S47 trace).
    const BLOCK_LINE: &str = r#"{"type":"user","message":{"role":"user","content":[{"type":"tool_result","is_error":true,"tool_use_id":"toolu_02","content":"PreToolUse:Bash hook error: [bash \"$CLAUDE_PROJECT_DIR/scripts/hook-copilot-loader.sh\"]: [vajra co-pilot] load .ai/STATE.md before continuing"}]}}"#;

    fn tool_use(id: &str) -> String {
        format!(
            r#"{{"type":"assistant","message":{{"content":[{{"type":"tool_use","id":"{id}","name":"Bash","input":{{}}}}]}}}}"#
        )
    }

    #[test]
    fn clean_session_is_100_percent() {
        let t = format!("{}\n{}", tool_use("toolu_01"), tool_use("toolu_02"));
        let o = obedience_from_str(&t);
        assert_eq!(o.total_tool_calls, 2);
        assert_eq!(o.clean, 2);
        assert_eq!(o.blocked, 0);
        assert!((o.obedience_pct - 100.0).abs() < 1e-9);
        assert!(o.blocks.is_empty());
    }

    #[test]
    fn one_block_out_of_two_is_fifty_percent() {
        // toolu_02 is attempted then blocked; toolu_01 proceeds clean.
        let t = format!(
            "{}\n{}\n{}",
            tool_use("toolu_01"),
            tool_use("toolu_02"),
            BLOCK_LINE
        );
        let o = obedience_from_str(&t);
        assert_eq!(o.total_tool_calls, 2);
        assert_eq!(o.clean, 1);
        assert_eq!(o.blocked, 1);
        assert!((o.obedience_pct - 50.0).abs() < 1e-9);
        assert_eq!(o.blocks[0].hook, "hook-copilot-loader.sh");
        assert_eq!(o.blocks[0].tool, "Bash");
    }

    #[test]
    fn plain_tool_failure_is_not_a_block() {
        // is_error but no hook signature → counts as a clean attempt, not a block.
        let fail = r#"{"type":"user","message":{"content":[{"type":"tool_result","is_error":true,"tool_use_id":"toolu_03","content":"error: command failed with exit code 1"}]}}"#;
        let t = format!("{}\n{}", tool_use("toolu_03"), fail);
        let o = obedience_from_str(&t);
        assert_eq!(o.blocked, 0);
        assert_eq!(o.clean, 1);
        assert!((o.obedience_pct - 100.0).abs() < 1e-9);
    }

    #[test]
    fn duplicate_block_line_counts_once() {
        let t = format!("{}\n{}\n{}", tool_use("toolu_02"), BLOCK_LINE, BLOCK_LINE);
        let o = obedience_from_str(&t);
        assert_eq!(o.total_tool_calls, 1);
        assert_eq!(o.blocked, 1);
    }

    #[test]
    fn empty_transcript_reports_no_tool_calls() {
        let o = obedience_from_str("");
        assert_eq!(o.total_tool_calls, 0);
        assert!(format_obedience(&o).contains("no tool calls"));
    }
}
