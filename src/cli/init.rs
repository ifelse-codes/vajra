use anyhow::{Context, Result};
use std::io::{self, BufRead, Write as _};
use std::path::{Path, PathBuf};
use std::process::Command;
use std::{fmt, fs};

pub fn run() -> Result<()> {
    let root = find_project_root()?;

    eprintln!("vajra init — scaffolding .ai/ workflow");
    eprintln!();

    let project_name = prompt("Project name: ")?.unwrap_or_else(|| "my-project".into());
    let goal = prompt("First session goal: ")?.unwrap_or_else(|| "first session".into());
    eprintln!();
    eprintln!("Maturity levels:");
    eprintln!("  L1 (Report) — hooks log violations but never block");
    eprintln!("  L2 (Gated)  — hooks can reject, human approval required [default]");
    eprintln!("  L3 (Auto)   — auto-advance, strict enforcement");
    let maturity = prompt("Maturity level [L1/L2/L3]: ")?
        .and_then(|v| match v.trim() {
            "L1" | "l1" => Some("L1"),
            "L3" | "l3" => Some("L3"),
            _ => None,
        })
        .unwrap_or("L2");

    scaffold(&root, &project_name, &goal, maturity)
}

pub fn scaffold(root: &Path, project_name: &str, goal: &str, maturity: &str) -> Result<()> {
    let slug = slugify(goal);
    let date = today();

    let mut created = 0u32;
    let mut skipped = 0u32;

    for dir in &[".ai", "scripts", "prompts", "sessions", ".claude"] {
        fs::create_dir_all(root.join(dir))
            .with_context(|| format!("failed to create {dir}/ directory"))?;
    }

    for entry in files(project_name, goal, &slug, &date, maturity) {
        let full = root.join(&entry.path);
        if full.exists() {
            eprintln!("  skip   {}", entry.path);
            skipped += 1;
        } else {
            if let Some(parent) = full.parent() {
                fs::create_dir_all(parent)?;
            }
            fs::write(&full, &entry.content)
                .with_context(|| format!("failed to write {}", entry.path))?;
            #[cfg(unix)]
            if entry.executable {
                use std::os::unix::fs::PermissionsExt;
                fs::set_permissions(&full, fs::Permissions::from_mode(0o755))?;
            }
            eprintln!("  create {}", entry.path);
            created += 1;
        }
    }

    eprintln!();
    eprintln!("Created {created} files, skipped {skipped}.");
    eprintln!("Next: git add .ai/ && vajra claude");
    Ok(())
}

struct FileEntry {
    path: String,
    content: String,
    executable: bool,
}

impl fmt::Debug for FileEntry {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.debug_struct("FileEntry")
            .field("path", &self.path)
            .field("executable", &self.executable)
            .finish()
    }
}

fn prompt(label: &str) -> Result<Option<String>> {
    eprint!("{label}");
    io::stderr().flush()?;
    let mut line = String::new();
    let bytes = io::stdin()
        .lock()
        .read_line(&mut line)
        .context("failed to read input")?;
    if bytes == 0 {
        return Ok(None);
    }
    let trimmed = line.trim().to_string();
    if trimmed.is_empty() {
        Ok(None)
    } else {
        Ok(Some(trimmed))
    }
}

pub fn slugify(s: &str) -> String {
    let slug: String = s
        .to_ascii_lowercase()
        .chars()
        .map(|c| if c.is_ascii_alphanumeric() { c } else { '-' })
        .collect();
    let slug = slug.trim_matches('-').to_string();
    let mut result: String = slug.chars().take(30).collect();
    while result.ends_with('-') {
        result.pop();
    }
    // collapse consecutive hyphens
    let mut collapsed = String::with_capacity(result.len());
    let mut prev_hyphen = false;
    for c in result.chars() {
        if c == '-' {
            if !prev_hyphen {
                collapsed.push(c);
            }
            prev_hyphen = true;
        } else {
            collapsed.push(c);
            prev_hyphen = false;
        }
    }
    collapsed
}

fn today() -> String {
    Command::new("date")
        .arg("+%Y-%m-%d")
        .output()
        .ok()
        .filter(|o| o.status.success())
        .and_then(|o| String::from_utf8(o.stdout).ok())
        .map(|s| s.trim().to_string())
        .unwrap_or_else(|| "YYYY-MM-DD".into())
}

fn find_project_root() -> Result<PathBuf> {
    let cwd = std::env::current_dir().context("failed to read current directory")?;
    Ok(cwd
        .ancestors()
        .find(|dir| dir.join(".git").exists())
        .map(Path::to_path_buf)
        .unwrap_or(cwd))
}

fn files(name: &str, goal: &str, slug: &str, date: &str, maturity: &str) -> Vec<FileEntry> {
    let f = |path: &str, content: &str| FileEntry {
        path: path.to_string(),
        content: content
            .replace("{PROJECT_NAME}", name)
            .replace("{GOAL}", goal)
            .replace("{SLUG}", slug)
            .replace("{DATE}", date)
            .replace("{MATURITY}", maturity),
        executable: false,
    };
    let fx = |path: &str, content: &str| FileEntry {
        path: path.to_string(),
        content: content
            .replace("{PROJECT_NAME}", name)
            .replace("{GOAL}", goal)
            .replace("{SLUG}", slug)
            .replace("{DATE}", date)
            .replace("{MATURITY}", maturity),
        executable: true,
    };

    vec![
        f(".ai/AGENTS.md", TPL_AGENTS),
        f(".ai/SESSION", TPL_SESSION),
        f(".ai/SESSION-BOOT.md", TPL_SESSION_BOOT),
        f(".ai/TASK.md", TPL_TASK),
        f(".ai/STATE.md", TPL_STATE),
        f(".ai/CONSTRAINTS.yaml", TPL_CONSTRAINTS),
        f(".ai/KNOWLEDGE.md", TPL_KNOWLEDGE),
        f(".ai/ROADMAP.md", TPL_ROADMAP),
        f("CLAUDE.md", TPL_CLAUDE_MD),
        f("AGENTS.md", TPL_AGENTS_ROOT),
        f(".cursorrules", TPL_CURSORRULES),
        f(".claude/settings.json", TPL_CLAUDE_SETTINGS),
        fx("scripts/hook-session-start.sh", TPL_HOOK_SESSION_START),
        fx("scripts/verify-session-template.sh", TPL_VERIFY_TEMPLATE),
        fx("scripts/demo-session-template.sh", TPL_DEMO_TEMPLATE),
        f("prompts/01-task-kickoff.md", TPL_PROMPT),
    ]
}

// ── Templates ───────────────────────────────────────────────────────────────

const TPL_AGENTS: &str = r#"# {PROJECT_NAME} — AI Agent Constitution

> Every AI agent MUST read this file and the load order below before executing any task.

## What This Repo Is

{PROJECT_NAME}. Managed by the Vajra workflow.

## Mandatory Load Order

1. `.ai/AGENTS.md` (this file)
2. `.ai/SESSION`
3. `.ai/SESSION-BOOT.md`
4. `.ai/TASK.md`
5. `.ai/STATE.md`
6. `.ai/CONSTRAINTS.yaml`
7. `.ai/KNOWLEDGE.md` (on demand)
8. `.ai/ROADMAP.md` (on demand)

## Session Loop

1. BOOT — Read load order. Confirm goal.
2. BRANCH — `session-NN-<slug>` from `main`.
3. PLAN — Bullets. Max 2 assumptions. Wait for approval.
4. EXECUTE — Atomic changes. Max 3 files per commit.
5. VERIFY + DEMO — `scripts/verify-session-NN.sh` exits 0. `scripts/demo-session-NN.sh` shows what was built (cumulative).
6. PR — Open PR to `main`.
7. SUMMARY — `sessions/session-NN-summary.md`. 3 next options.
8. CLOSEOUT — Sync `.ai/` files. `verify-closeout.sh` exits 0.
9. CLOSE — New chat from next prompt file.

## Hard Rules

| Rule | Detail |
|---|---|
| Max 2 assumptions | More = STOP and ask |
| Max 2 retries | 3rd failure = escalate |
| No autonomous commits | Wait for approval |
| No `main` commits | Branch first |
| Max 3 files per commit | Atomic changes |
| Verification = exit 0 | Never leave red |

## Communication Style

- Under 200 words per response
- Bullets and tables, no paragraphs
- No filler phrases, no trailing summaries
- Code first, explanation after
"#;

const TPL_SESSION: &str = "01\n";

const TPL_SESSION_BOOT: &str = r#"# Session Boot

## Current Session
- **Number:** 01
- **Type:** CODE
- **Branch:** pending
- **Date last updated:** {DATE}

## Repo State Snapshot
- `.ai/SESSION` = 01.
- First session. No prior work.

## Next Session
- **Read prompt:** `prompts/01-task-kickoff.md`
"#;

const TPL_TASK: &str = r#"# Current Task Pointer

## Session 01 — {GOAL}

- **Branch:** pending
- **Goal:** {GOAL}

Read prompt: `prompts/01-task-kickoff.md`
"#;

const TPL_STATE: &str = r#"# {PROJECT_NAME} — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — initialization complete, S01 not yet started.

## What Currently Works
- Vajra workflow initialized.

## What Is Broken
- Nothing yet.

## What Is In Progress
- Session 01 pending.

## Cost Tracking
- Cumulative: $0.00
"#;

const TPL_CONSTRAINTS: &str = r#"version: 3

maturity: {MATURITY}

session:
  max_assumptions: 2
  max_retries: 2
  max_files_per_atomic_change: 3
  max_stories_per_session: 1
  cap_hours_per_session: 2
  ground_truth_every_n_sessions: 5

branch:
  forbid_direct_work_on: [main, master]
  required_session_branch_pattern: '^session-\d{2,}-[a-z0-9-]+$'

commit:
  autonomous: false
  require_user_approval: true
  approval_tokens: [approved, lgtm, "ship it", "yes commit", "go ahead"]

verify:
  required_for_done: true
  script_pattern: 'scripts/verify-session-{NN}.sh'
  template: 'scripts/verify-session-template.sh'
  exit_zero_required: true

demo:
  script_pattern: 'scripts/demo-session-{NN}.sh'
  template: 'scripts/demo-session-template.sh'
  cumulative: true
  required_elements: [header, cases, summary_table]

state:
  state_md_mode: snapshot
  knowledge_md_mode: append-permanent-only

communication:
  max_words_per_response: 200
  required_formats: [bullets, tables, code-blocks]
  forbid: [greetings, apologies, filler, trailing-summaries]

load_order:
  - .ai/AGENTS.md
  - .ai/SESSION
  - .ai/SESSION-BOOT.md
  - .ai/TASK.md
  - .ai/STATE.md
  - .ai/CONSTRAINTS.yaml
  - .ai/KNOWLEDGE.md
  - .ai/ROADMAP.md
"#;

const TPL_KNOWLEDGE: &str = r#"# {PROJECT_NAME} — Knowledge Base

**Permanent facts only. Reloaded every session.**
"#;

const TPL_ROADMAP: &str = r#"# {PROJECT_NAME} — Working Roadmap

**Updated at every closeout.**

## Session 01 — {GOAL}
- [ ] {GOAL}
"#;

const TPL_CLAUDE_MD: &str = r#"# CLAUDE.md — Cross-Agent Entry Point

> Stop. Read `.ai/AGENTS.md` before any action.

Full constitution at `.ai/AGENTS.md`.
"#;

const TPL_AGENTS_ROOT: &str = r#"# AGENTS.md — Cross-Agent Entry Point

> Stop. Read `.ai/AGENTS.md` before any action.

Full constitution at `.ai/AGENTS.md`.
"#;

const TPL_CURSORRULES: &str = r#"# Cross-Agent Entry Point

> Stop. Read `.ai/AGENTS.md` before any action.

Full constitution at `.ai/AGENTS.md`. Mandatory load order:

1. `.ai/AGENTS.md`
2. `.ai/SESSION`
3. `.ai/SESSION-BOOT.md`
4. `.ai/TASK.md`
5. `.ai/STATE.md`
6. `.ai/CONSTRAINTS.yaml`
7. `.ai/KNOWLEDGE.md`
8. `.ai/ROADMAP.md`

## Communication style

- Under 200 words per response.
- Bullets and tables. No paragraphs.
- Max 5 bullets per section.
- No filler phrases.
- No trailing summaries.
- Code first.
"#;

const TPL_CLAUDE_SETTINGS: &str = r#"{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hook-session-start.sh\""
          }
        ]
      }
    ]
  }
}
"#;

const TPL_HOOK_SESSION_START: &str = r#"#!/usr/bin/env bash
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"

echo "=== Agent Boot (per .ai/AGENTS.md) ==="
echo ""
for f in .ai/SESSION .ai/SESSION-BOOT.md .ai/TASK.md .ai/STATE.md .ai/CONSTRAINTS.yaml; do
  if [ -f "$ROOT/$f" ]; then
    echo "----- $f -----"
    cat "$ROOT/$f"
    echo ""
  fi
done
exit 0
"#;

const TPL_VERIFY_TEMPLATE: &str = r#"#!/usr/bin/env bash
# Template — copy to scripts/verify-session-NN.sh and customize per session.

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# === EDIT PER SESSION ===
SESSION="NN"
# ========================

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/session-${SESSION}/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
run_check() {
  local NAME="$1"; shift
  local LOG="$ARTIFACTS/${NAME}.log"
  if "$@" > "$LOG" 2>&1; then
    RESULTS+=("$(printf '%-30s %s' "$NAME" PASS)"); PASS=$((PASS+1))
  else
    RESULTS+=("$(printf '%-30s %s' "$NAME" FAIL)"); FAIL=$((FAIL+1))
  fi
}

# === EDIT PER SESSION ===
# run_check "cargo-check"  cargo check --all-targets
# run_check "cargo-test"   cargo test --all-targets
# run_check "cargo-fmt"    cargo fmt -- --check
# run_check "cargo-clippy" cargo clippy --all-targets -- -D warnings
# ========================

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
"#;

const TPL_DEMO_TEMPLATE: &str = r#"#!/usr/bin/env bash
# Template — copy to scripts/demo-session-NN.sh and customize per session.
# Demo scripts are narrative — they show what was built with real/mock data.
# Demos are cumulative: each session's demo includes prior session capabilities.
# NOTE: This bash script is for CI/verify. When a user asks to see the demo,
# the agent should present results as an interactive HTML slide deck
# (terminal-styled, auto-play, PASS/FAIL coloring, scorecard summary).

set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# === EDIT PER SESSION ===
SESSION="NN"
# ========================

BOLD="\033[1m"; CYAN="\033[36m"; GREEN="\033[32m"
YELLOW="\033[33m"; DIM="\033[2m"; RESET="\033[0m"

header() { printf "\n${CYAN}${BOLD}══ %s ══${RESET}\n" "$1"; }
label()  { printf "${YELLOW}${BOLD}▸ %s${RESET}\n" "$1"; }
ok()     { printf "${GREEN}✓ %s${RESET}\n" "$1"; }

header "Session ${SESSION} Demo"

# === EDIT PER SESSION ===
# header "Feature Name"
# label "Description of what this demonstrates"
# Run commands, show output, display results
# ok "What this proves"
# ========================

# --- Summary Table ---
header "Summary"
printf "\n"
printf "  %-30s %s\n" "Feature" "Status"
printf "  %-30s %s\n" "------------------------------" "------"
# printf "  %-30s %s\n" "Feature name"                  "WORKS"
printf "\n"

ok "Session ${SESSION} demo complete."
"#;

const TPL_PROMPT: &str = r#"# Session 01 — {GOAL}

## Goal
{GOAL}

## Deliverables
- (define before starting)

## Exit Criteria
- `scripts/verify-session-01.sh` exits 0
- `scripts/demo-session-01.sh` shows what was built
- Session summary with 3 next options
"#;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn slugify_basic() {
        assert_eq!(slugify("Build the CLI"), "build-the-cli");
    }

    #[test]
    fn slugify_special_chars() {
        assert_eq!(
            slugify("Add `vajra init` command"),
            "add-vajra-init-command"
        );
    }

    #[test]
    fn slugify_truncates() {
        let long = "this is a very long goal that should be truncated at thirty chars";
        let result = slugify(long);
        assert!(result.len() <= 30);
        assert!(!result.ends_with('-'));
    }

    #[test]
    fn slugify_empty() {
        assert_eq!(slugify(""), "");
    }
}
