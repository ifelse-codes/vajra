//! Render the live `.ai/` into a glanceable `vajra.varta` in the 9 locked ⚡ constructs.
//!
//! No `serde_yaml` dep (KNOWLEDGE §6): we hand-parse the handful of fields we need from
//! `CONSTRAINTS.yaml`, the same line-scan pattern as `maturity::parse_maturity`. The render
//! is deterministic — same `.ai/` in, byte-identical `.varta` out — which is what lets the
//! drift guard prove the artifact was generated, not hand-edited.

use anyhow::{Context, Result};
use std::fs;
use std::path::Path;

/// Repo-root-relative path of the generated artifact.
pub const RENDER_PATH: &str = "vajra.varta";

/// Read the live `.ai/` under `root` and return the rendered `.varta` text.
pub fn render_from_root(root: &Path) -> Result<String> {
    let read = |rel: &str| -> Result<String> {
        fs::read_to_string(root.join(rel)).with_context(|| format!("could not read {rel}"))
    };
    let constraints = read(".ai/CONSTRAINTS.yaml")?;
    let agents = read(".ai/AGENTS.md")?;
    let session = read(".ai/SESSION")?;
    let boot = read(".ai/SESSION-BOOT.md")?;
    Ok(render(&constraints, &agents, &session, &boot))
}

/// Pure render — the testable core. Takes the four source texts, returns the `.varta`.
pub fn render(constraints: &str, agents: &str, session: &str, boot: &str) -> String {
    let session = session.trim();
    let mut out = String::new();

    out.push_str(&header());
    out.push_str(&project(agents, session, boot));
    out.push_str(&forbid(constraints));
    out.push_str(&require(constraints));
    out.push_str(&max(constraints));
    out.push_str(&pipeline());
    out.push_str(&final_adrs(agents));
    out.push_str(&on(constraints));
    out.push_str(&assert_block(constraints));
    out.push_str(&enum_next(boot));

    out
}

fn header() -> String {
    "// vajra.varta — GENERATED from .ai/ by `vajra check --render`. DO NOT EDIT BY HAND.\n\
     // One-way render: edit .ai/, then regenerate. `vajra check` drift-guards this file\n\
     // against a fresh render (S22 cmp pattern), so it can never silently drift or lose config.\n\n"
        .to_string()
}

fn project(agents: &str, session: &str, boot: &str) -> String {
    let is = section_first_sentence(agents, "## What This Repo Is")
        .unwrap_or_else(|| "a CLI that guides any AI coding agent".into());
    let stack = bold_value(agents, "Stack:").unwrap_or_else(|| "Rust".into());
    let goal = bold_value(agents, "Target vision:").unwrap_or_else(|| "VISION.md".into());
    let now = boot_type(boot).unwrap_or_else(|| "see .ai/TASK.md".into());
    format!(
        "⚡project {{                      // identity — load first, never drift from it.\n\
         \x20 ⚡is    {is:?};\n\
         \x20 ⚡stack {stack:?};\n\
         \x20 ⚡goal  {goal:?};\n\
         \x20 ⚡now   {:?};\n\
         }}\n\n",
        format!("session {session} — {now}")
    )
}

fn forbid(constraints: &str) -> String {
    let mut lines = String::new();
    let branches = yaml_inline_list(constraints, "forbid_direct_work_on");
    if !branches.is_empty() {
        lines.push_str(&format!(
            "\x20 commit_to_{};            // branch.forbid_direct_work_on\n",
            branches.join("_and_")
        ));
    }
    if yaml_scalar(constraints, "autonomous").as_deref() == Some("false") {
        lines.push_str(
            "\x20 autonomous_commit;          // commit.autonomous = false — wait for approval\n",
        );
    }
    if yaml_scalar(constraints, "forbid_skip_hooks").as_deref() == Some("true") {
        lines.push_str("\x20 skip_hooks;                 // commit.forbid_skip_hooks\n");
    }
    format!(
        "⚡forbid {{                       // hard rules. violation = STOP and ask.\n{lines}}}\n\n"
    )
}

fn require(constraints: &str) -> String {
    let mut lines = String::new();
    if yaml_scalar(constraints, "exit_zero_required").as_deref() == Some("true") {
        lines.push_str(
            "\x20 verify_exits_zero;          // verify.exit_zero_required — never leave red\n",
        );
    }
    if yaml_scalar(constraints, "state_md_mode").as_deref() == Some("snapshot") {
        lines.push_str(
            "\x20 state_is_snapshot;          // state.state_md_mode — never append history\n",
        );
    }
    if yaml_scalar(constraints, "fail_closed").as_deref() == Some("true") {
        lines.push_str("\x20 fail_closed;                // enforcement.fail_closed — a check that can't run FAILS\n");
    }
    format!(
        "⚡require {{                      // invariants. must hold at all times.\n{lines}}}\n\n"
    )
}

fn max(constraints: &str) -> String {
    let m = |key: &str| yaml_scalar_under(constraints, "session:", key);
    let pairs = [
        ("assumptions", m("max_assumptions"), "more => STOP and ask"),
        ("retries", m("max_retries"), "3rd failure => escalate"),
        (
            "files_per_commit",
            m("max_files_per_atomic_change"),
            "hook-enforced",
        ),
        (
            "stories_per_session",
            m("max_stories_per_session"),
            "larger => split",
        ),
        (
            "hours_per_session",
            m("cap_hours_per_session"),
            "marathon = drift",
        ),
    ];
    let mut lines = String::new();
    for (name, val, why) in pairs {
        if let Some(v) = val {
            lines.push_str(&format!("\x20 {name} = {v};{}// {why}\n", pad(name, &v)));
        }
    }
    format!("⚡max {{                          // numeric ceilings. cross one => split or stop.\n{lines}}}\n\n")
}

fn pipeline() -> String {
    "⚡pipeline {                     // the session loop, in order.\n\
     \x20 boot -> branch -> plan -> execute -> verify -> ship;\n\
     }\n\n"
        .to_string()
}

fn final_adrs(agents: &str) -> String {
    let mut lines = String::new();
    for line in agents.lines() {
        let t = line.trim();
        if !t.starts_with("| ADR-") {
            continue;
        }
        let cells: Vec<&str> = t.trim_matches('|').split('|').map(str::trim).collect();
        if cells.len() >= 3 {
            let id = cells[0].replace('-', "_");
            lines.push_str(&format!("\x20 {id}: {:?};   // {}\n", cells[1], cells[2]));
        }
    }
    format!("⚡final {{                        // locked decisions (ADRs). change needs approval.\n{lines}}}\n\n")
}

fn on(constraints: &str) -> String {
    let mut block = String::new();
    block.push_str(
        "// ⚡on — THE CO-PILOT. load context ONLY when that work is touched (copilot.on).\n",
    );
    let mut in_on = false;
    for line in constraints.lines() {
        if line.trim_start().starts_with("on:") && starts_at(line, "  ") {
            in_on = true;
            continue;
        }
        if in_on {
            let t = line.trim_start();
            if !t.starts_with("- ") {
                if !line.trim().is_empty() && !line.starts_with("    ") {
                    break;
                }
                continue;
            }
            if let Some(rule) = parse_on_rule(t.trim_start_matches("- ").trim().trim_matches('"')) {
                block.push_str(&rule);
            }
        }
    }
    block.push('\n');
    block
}

fn assert_block(constraints: &str) -> String {
    let qs = yaml_inline_list(constraints, "self_review_questions");
    let mut lines = String::new();
    for q in qs {
        lines.push_str(&format!("\x20 {q}?;\n"));
    }
    format!("⚡assert {{                       // pre-ship checklist. shaky answer => do not ship.\n{lines}}}\n\n")
}

fn enum_next(boot: &str) -> String {
    // The A/B/C menu is a closeout-time human artifact, not machine state. We render the
    // single committed forward pointer from SESSION-BOOT "## Next Session" as `A:`.
    let num = boot_section_value(boot, "## Next Session", "**Number:**");
    let typ = boot_section_value(boot, "## Next Session", "**Type:**");
    let next = match (num, typ) {
        (Some(n), Some(t)) => format!("session {n} — {t}"),
        (Some(n), None) => format!("session {n}"),
        _ => "see .ai/SESSION-BOOT.md".into(),
    };
    format!(
        "⚡enum next {{                   // end-of-session. A/B/C authored at closeout; here = committed pointer.\n\
         \x20 A: {next:?};\n\
         }}\n",
    )
}

// ---- hand-parse helpers (no serde_yaml) ----

fn pad(name: &str, val: &str) -> String {
    let used = name.len() + val.len() + 4; // " name = val;"
    " ".repeat(28usize.saturating_sub(used).max(1))
}

fn starts_at(line: &str, indent: &str) -> bool {
    line.starts_with(indent) && !line.starts_with(&format!("{indent} "))
}

/// `key: value` anywhere (first match), value trimmed.
fn yaml_scalar(content: &str, key: &str) -> Option<String> {
    let needle = format!("{key}:");
    for line in content.lines() {
        let t = line.trim_start();
        if let Some(rest) = t.strip_prefix(&needle) {
            let v = strip_comment(rest).trim().trim_matches('"').to_string();
            if !v.is_empty() {
                return Some(v);
            }
        }
    }
    None
}

/// `key: value` but only after a top-level `parent` line, before the next top-level key.
fn yaml_scalar_under(content: &str, parent: &str, key: &str) -> Option<String> {
    let mut in_parent = false;
    let needle = format!("{key}:");
    for line in content.lines() {
        if line.starts_with(parent) {
            in_parent = true;
            continue;
        }
        if in_parent {
            // a new top-level key (no indent) ends the parent block
            if !line.starts_with(' ') && !line.trim().is_empty() {
                break;
            }
            let t = line.trim_start();
            if let Some(rest) = t.strip_prefix(&needle) {
                let v = strip_comment(rest).trim().trim_matches('"').to_string();
                if !v.is_empty() {
                    return Some(v);
                }
            }
        }
    }
    None
}

/// `key: [a, b, c]` → vec of trimmed items.
fn yaml_inline_list(content: &str, key: &str) -> Vec<String> {
    let needle = format!("{key}:");
    for line in content.lines() {
        let t = line.trim_start();
        if let Some(rest) = t.strip_prefix(&needle) {
            let rest = strip_comment(rest).trim();
            if let Some(inner) = rest.strip_prefix('[').and_then(|s| s.strip_suffix(']')) {
                return inner
                    .split(',')
                    .map(|s| s.trim().trim_matches('"').to_string())
                    .filter(|s| !s.is_empty())
                    .collect();
            }
        }
    }
    Vec::new()
}

fn strip_comment(s: &str) -> &str {
    match s.find(" #") {
        Some(i) => &s[..i],
        None => s,
    }
}

/// `"PATTERN => files | why"` → `⚡on (PATTERN) ⚡include "files";   // why\n`
fn parse_on_rule(raw: &str) -> Option<String> {
    let (lhs, why) = match raw.split_once('|') {
        Some((l, w)) => (l.trim(), w.trim()),
        None => (raw.trim(), ""),
    };
    let (pattern, files) = lhs.split_once("=>")?;
    Some(format!(
        "⚡on ({}) ⚡include {:?};   // {}\n",
        pattern.trim(),
        files.trim(),
        why
    ))
}

/// First sentence of the first non-empty paragraph after a `## heading`.
fn section_first_sentence(md: &str, heading: &str) -> Option<String> {
    let mut after = false;
    for line in md.lines() {
        if line.trim() == heading {
            after = true;
            continue;
        }
        if after {
            let t = line.trim();
            if t.is_empty() || t.starts_with('#') {
                continue;
            }
            let sentence = t.split(". ").next().unwrap_or(t);
            return Some(sentence.trim_end_matches('.').to_string());
        }
    }
    None
}

/// `**Label:** value` (markdown bold label) anywhere.
fn bold_value(md: &str, label: &str) -> Option<String> {
    let needle = format!("**{label}**");
    for line in md.lines() {
        if let Some(i) = line.find(&needle) {
            let v = line[i + needle.len()..]
                .trim()
                .trim_start_matches('`')
                .trim_end_matches('`')
                .trim();
            if !v.is_empty() {
                return Some(v.to_string());
            }
        }
    }
    None
}

/// SESSION-BOOT "## Current Session" → "- **Type:** value".
fn boot_type(boot: &str) -> Option<String> {
    boot_section_value(boot, "## Current Session", "**Type:**")
}

/// Value of `**Label:** v` within a given `## section`, before the next `##`.
fn boot_section_value(boot: &str, section: &str, label: &str) -> Option<String> {
    let mut in_section = false;
    for line in boot.lines() {
        let t = line.trim();
        if t == section {
            in_section = true;
            continue;
        }
        if in_section {
            if t.starts_with("## ") {
                break;
            }
            if let Some(i) = t.find(label) {
                let v = t[i + label.len()..].trim();
                let v = v.split('—').next().unwrap_or(v).trim();
                let v = v.trim_start_matches('`').trim_end_matches('`').trim();
                if !v.is_empty() {
                    return Some(v.to_string());
                }
            }
        }
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    const CONSTRAINTS: &str = "version: 3\nmaturity: L2\n\nsession:\n  max_assumptions: 2\n  max_retries: 2\n  max_files_per_atomic_change: 3\n  max_stories_per_session: 1\n  cap_hours_per_session: 2\n\nbranch:\n  forbid_direct_work_on: [main, master]\n\ncommit:\n  autonomous: false\n  forbid_skip_hooks: true\n\nverify:\n  exit_zero_required: true\n\nstate:\n  state_md_mode: snapshot\n\nself_review_questions: [what_can_break, hidden_assumptions, scope_intact]\n\ncopilot:\n  on:\n    - \"src/engine/* => docs/adr/0003.md | heuristics share the contract\"\n    - \"cmd:git commit => .ai/STATE.md | confirm it matches before you commit\"\n\nenforcement:\n  fail_closed: true\n";

    const AGENTS: &str = "# Vajra\n\n## What This Repo Is\n\nVajra is one CLI that guides any AI coding agent. The agent codes.\n**Stack:** Rust, single static binary\n**Target vision:** `VISION.md`\n\n## ADRs\n\n| ID | Decision | Date |\n|---|---|---|\n| ADR-0001 | Compression via hook | 2026-06-15 |\n| ADR-0002 | Engine trait | 2026-06-16 |\n";

    const BOOT: &str = "# Session Boot\n\n## Current Session\n- **Number:** 24\n- **Type:** CODE — render .ai/ to varta\n\n## Next Session\n- **Number:** 25\n- **Type:** GROUND-TRUTH — no code\n";

    fn out() -> String {
        render(CONSTRAINTS, AGENTS, "24\n", BOOT)
    }

    #[test]
    fn deterministic() {
        assert_eq!(out(), out());
    }

    #[test]
    fn has_all_nine_constructs() {
        let o = out();
        for c in [
            "⚡project",
            "⚡forbid",
            "⚡require",
            "⚡max",
            "⚡pipeline",
            "⚡final",
            "⚡on",
            "⚡assert",
            "⚡enum next",
        ] {
            assert!(o.contains(c), "missing {c}");
        }
    }

    #[test]
    fn renders_project_identity() {
        let o = out();
        assert!(o.contains("Vajra is one CLI that guides any AI coding agent"));
        assert!(o.contains("Rust, single static binary"));
        assert!(o.contains("session 24 — CODE"));
    }

    #[test]
    fn renders_maxes() {
        let o = out();
        assert!(o.contains("assumptions = 2;"));
        assert!(o.contains("files_per_commit = 3;"));
        assert!(o.contains("hours_per_session = 2;"));
    }

    #[test]
    fn renders_forbid_and_require() {
        let o = out();
        assert!(o.contains("commit_to_main_and_master;"));
        assert!(o.contains("autonomous_commit;"));
        assert!(o.contains("verify_exits_zero;"));
        assert!(o.contains("state_is_snapshot;"));
    }

    #[test]
    fn renders_adrs() {
        let o = out();
        assert!(o.contains("ADR_0001: \"Compression via hook\";"));
        assert!(o.contains("ADR_0002: \"Engine trait\";"));
    }

    #[test]
    fn renders_copilot_on_rules() {
        let o = out();
        assert!(o.contains("⚡on (src/engine/*) ⚡include \"docs/adr/0003.md\";"));
        assert!(o.contains("⚡on (cmd:git commit) ⚡include \".ai/STATE.md\";"));
        assert!(o.contains("// confirm it matches before you commit"));
    }

    #[test]
    fn renders_assert_questions() {
        let o = out();
        assert!(o.contains("what_can_break?;"));
        assert!(o.contains("scope_intact?;"));
    }

    #[test]
    fn renders_next_pointer() {
        let o = out();
        assert!(o.contains("A: \"session 25 — GROUND-TRUTH"));
    }

    #[test]
    fn header_warns_generated() {
        assert!(out().starts_with("// vajra.varta — GENERATED"));
    }
}
