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

    scaffold(&root, &project_name, &goal, maturity)?;
    first_run_aha(&root);
    Ok(())
}

pub fn scaffold(root: &Path, project_name: &str, goal: &str, maturity: &str) -> Result<()> {
    let slug = slugify(goal);
    let date = today();
    let brownfield = is_brownfield(root);

    let mut created = 0u32;
    let mut skipped = 0u32;

    for dir in &[
        ".ai",
        ".ai/hooks",
        "scripts",
        "prompts",
        "sessions",
        ".claude",
    ] {
        fs::create_dir_all(root.join(dir))
            .with_context(|| format!("failed to create {dir}/ directory"))?;
    }

    for entry in files(project_name, goal, &slug, &date, maturity, brownfield) {
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
    if brownfield {
        eprintln!();
        eprintln!("Existing codebase detected → session 00 is a guided onboarding:");
        eprintln!("  study the repo, fill .ai/KNOWLEDGE.md + .ai/STATE.md with reality,");
        eprintln!("  then start feature work in session 01.");
        eprintln!("  Brief: prompts/00-task-brownfield-onboarding.md");
    }
    Ok(())
}

/// Brownfield = the repo already has content Vajra didn't put there. Detected by any
/// root entry that isn't `.git` or one of the paths this scaffold itself creates —
/// so re-running `init` on an already-scaffolded project stays greenfield, while a
/// repo with real source (src/, package.json, …) gets the session-0 onboarding path.
fn is_brownfield(root: &Path) -> bool {
    const SCAFFOLD_OWNED: &[&str] = &[
        ".git",
        ".ai",
        "scripts",
        "prompts",
        "sessions",
        ".claude",
        "darshan",
        "CLAUDE.md",
        "AGENTS.md",
        ".cursorrules",
        ".gitignore",
    ];
    fs::read_dir(root)
        .map(|entries| {
            entries.filter_map(|e| e.ok()).any(|e| {
                let name = e.file_name();
                !SCAFFOLD_OWNED
                    .iter()
                    .any(|owned| name.as_os_str() == *owned)
            })
        })
        .unwrap_or(false)
}

/// First-run "aha" (S23): after scaffolding, let the user *see* the co-pilot work in
/// seconds — fire the just-scaffolded hook once against a sample `git commit` so the
/// guard is felt, not just filed. Best-effort: a missing bash/jq never fails init.
fn first_run_aha(root: &Path) {
    eprintln!();
    eprintln!("▶ See it work — a 5-second simulation against your new project:");
    eprintln!();
    match copilot_fire_preview(root) {
        Some(block) => {
            for line in block.lines() {
                eprintln!("    {line}");
            }
            eprintln!();
            eprintln!("↑ That's Vajra guiding your agent: the moment it runs `git commit`, the");
            eprintln!(
                "  right context is surfaced first — automatically, for every guarded action."
            );
        }
        None => eprint!("{}", render_aha_fallback()),
    }
    eprintln!();
    eprintln!("Next: git add .ai/ && start a guided session →  vajra claude");
}

/// Fire the scaffolded co-pilot hook once and capture what the agent would see.
/// Returns None if the hook or its deps (bash/jq) aren't available — caller falls back.
fn copilot_fire_preview(root: &Path) -> Option<String> {
    use std::io::Write as _;
    use std::process::Stdio;

    let hook = root.join(".ai/hooks/hook-copilot-loader.sh");
    if !hook.exists() {
        return None;
    }
    // Isolated debounce dir so the preview can't interfere with a real session.
    let state_dir = std::env::temp_dir().join(format!("vajra-aha-{}", std::process::id()));
    let payload = r#"{"tool_name":"Bash","tool_input":{"command":"git commit -m wip"},"session_id":"vajra-init-aha"}"#;

    let mut child = Command::new("bash")
        .arg(&hook)
        .env("CLAUDE_PROJECT_DIR", root)
        .env("VAJRA_COPILOT_STATE_DIR", &state_dir)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .ok()?;

    // Drop stdin right after writing so the hook's `cat` sees EOF and proceeds.
    child.stdin.take()?.write_all(payload.as_bytes()).ok()?;
    let out = child.wait_with_output().ok()?;
    let _ = fs::remove_dir_all(&state_dir);

    let mut combined = String::from_utf8_lossy(&out.stdout).into_owned();
    combined.push_str(&String::from_utf8_lossy(&out.stderr));
    let trimmed = combined.trim();
    if trimmed.is_empty() {
        None
    } else {
        Some(trimmed.to_string())
    }
}

/// Shown when the live fire can't run (no bash/jq): a static, still-useful preview.
fn render_aha_fallback() -> String {
    let lines = [
        "    [co-pilot] Your agent is now guided. Example rule (.ai/CONSTRAINTS.yaml):",
        "",
        "        ⚡on(cmd:git commit) ⚡include \".ai/STATE.md\"",
        "",
        "    Before a commit, Vajra surfaces STATE.md to check first — for every",
        "    guarded action. (Install `jq` to see this fire live on `vajra init`.)",
    ];
    let mut s = lines.join("\n");
    s.push('\n');
    s
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

fn files(
    name: &str,
    goal: &str,
    slug: &str,
    date: &str,
    maturity: &str,
    brownfield: bool,
) -> Vec<FileEntry> {
    // Brownfield repos boot into session 00 (study the codebase); greenfield goes
    // straight to the session-01 kickoff. The kickoff prompt is emitted either way.
    let (first_nn, first_prompt, first_title, first_note) = if brownfield {
        (
            "00",
            "prompts/00-task-brownfield-onboarding.md",
            "Brownfield onboarding (study the codebase)",
            "Existing codebase — session 00 studies it before any feature work.",
        )
    } else {
        (
            "01",
            "prompts/01-task-kickoff.md",
            goal,
            "First session. No prior work.",
        )
    };
    let fill = move |content: &str| {
        content
            .replace("{PROJECT_NAME}", name)
            .replace("{GOAL}", goal)
            .replace("{SLUG}", slug)
            .replace("{DATE}", date)
            .replace("{MATURITY}", maturity)
            .replace("{FIRST_NN}", first_nn)
            .replace("{FIRST_PROMPT}", first_prompt)
            .replace("{FIRST_TITLE}", first_title)
            .replace("{FIRST_NOTE}", first_note)
    };
    let f = |path: &str, content: &str| FileEntry {
        path: path.to_string(),
        content: fill(content),
        executable: false,
    };
    let fx = |path: &str, content: &str| FileEntry {
        path: path.to_string(),
        content: fill(content),
        executable: true,
    };

    let mut entries = vec![
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
        f(".gitignore", TPL_GITIGNORE),
        f("darshan/SKILL.md", TPL_DARSHAN),
        f(".claude/settings.json", TPL_CLAUDE_SETTINGS),
        // Hooks live under .ai/hooks/ (S34): they are Vajra's, not the project's —
        // keeps them out of a brownfield project's own scripts/ package. Per-session
        // verify/demo scripts stay in scripts/ (that contract is unchanged).
        fx(".ai/hooks/hook-session-start.sh", TPL_HOOK_SESSION_START),
        fx(".ai/hooks/hook-copilot-loader.sh", TPL_HOOK_COPILOT_LOADER),
        fx(".ai/hooks/hook-session-guard.sh", TPL_HOOK_SESSION_GUARD),
        fx("scripts/verify-session-template.sh", TPL_VERIFY_TEMPLATE),
        fx("scripts/demo-session-template.sh", TPL_DEMO_TEMPLATE),
        f("prompts/01-task-kickoff.md", TPL_PROMPT),
    ];
    if brownfield {
        entries.push(f(
            "prompts/00-task-brownfield-onboarding.md",
            TPL_PROMPT_ONBOARD,
        ));
    }
    entries
}

// ── Templates ───────────────────────────────────────────────────────────────

const TPL_AGENTS: &str = r#"# {PROJECT_NAME} — AI Agent Constitution

> Every AI agent MUST read this file and the load order below before executing any task.

## What This Repo Is

{PROJECT_NAME}. Managed by the Vajra workflow.

## Speaking Skills (Load at Boot)

**Darshan** (`darshan/SKILL.md`) is your default human-output skill — read and internalize
it at boot, then speak it all session. One rule: *render the richest visual this surface can
handle; always glanceable; never drop meaning.* It is a skill, not a renderer — nothing in
the binary parses or draws it. The user sees Darshan in every reply.

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

const TPL_SESSION: &str = "{FIRST_NN}\n";

const TPL_SESSION_BOOT: &str = r#"# Session Boot

## Current Session
- **Number:** {FIRST_NN}
- **Type:** CODE
- **Branch:** pending
- **Date last updated:** {DATE}

## Repo State Snapshot
- `.ai/SESSION` = {FIRST_NN}.
- {FIRST_NOTE}

## Next Session
- **Read prompt:** `{FIRST_PROMPT}`
"#;

const TPL_TASK: &str = r#"# Current Task Pointer

## Session {FIRST_NN} — {FIRST_TITLE}

- **Branch:** pending
- **Goal:** {FIRST_TITLE}

Read prompt: `{FIRST_PROMPT}`
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
  one_session_per_chat: true   # new session = new chat; enforced by .ai/hooks/hook-session-guard.sh

branch:
  forbid_direct_work_on: [main, master]
  required_session_branch_pattern: '^session-\d{2,}-[a-z0-9-]+$'
  ground_truth_commit_exempt_branch_suffixes: [-closeout, -enforcement]

commit:
  autonomous: false
  require_user_approval: true
  approval_tokens: [approved, lgtm, "ship it", "yes commit", "go ahead and commit", "go ahead"]

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

ground_truth:
  # Every 5th session is NO-CODE. It must catch BOTH direction drift (vision+roadmap)
  # and discipline drift (rules+constitution+state). Rules exist to serve the vision —
  # auditing rule-following without auditing the vision is the trap.
  forbid_code_changes: true
  forbid_commits: true
  forbid_prs: true
  required_outputs: [sessions/session-{NN}-ground-truth.md]
  drift_axes: [vision, roadmap, rules, constitution, state, cost]
  required_audits: [vision_alignment, roadmap_alignment, state_drift, knowledge_staleness, constraint_violation_review, constitution_review, cost_review]
  vision_questions:
    - Is the north-star still the right destination?
    - Is current work the shortest path to it, or intellectually-fun scope creep?
    - What new evidence would make us pivot or abandon this direction?
  roadmap_questions:
    - Does each phase still map to the north-star?
    - Is the next item the highest-leverage one, or just the easiest?
    - Any item now obsolete, or any the vision now demands but the roadmap lacks?
  constitution_questions:
    - Is any rule now blocking the vision instead of protecting it?
    - Did this audit's own mechanism have a blind spot? (meta-check)

load_order:
  - .ai/AGENTS.md
  - .ai/SESSION
  - .ai/SESSION-BOOT.md
  - .ai/TASK.md
  - .ai/STATE.md
  - .ai/CONSTRAINTS.yaml
  - .ai/KNOWLEDGE.md
  - .ai/ROADMAP.md

copilot:
  # The co-pilot loader (fired by .ai/hooks/hook-copilot-loader.sh): surface the right
  # context the moment matching work is touched, not all up front.
  # Rule form:  "PATTERN => file, file | why this context, for this work"
  #   PATTERN = a path glob (matched against the touched file, repo-relative)
  #          or cmd:<substring> (matched against a Bash command).
  # Maturity-gated: L1 advises (non-blocking); L2/L3 enforce (exit 2 — block until surfaced).
  # Per-session debounce: each rule fires once per session. Edit these for your project.
  on:
    - "cmd:git commit => .ai/STATE.md | STATE.md is a snapshot of reality — confirm it matches before you commit"
    - "prompts/* => .ai/TASK.md, .ai/ROADMAP.md | the prompt is the session contract — re-read the task + roadmap before editing it"
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
            "command": "bash \"$CLAUDE_PROJECT_DIR/.ai/hooks/hook-session-start.sh\""
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.ai/hooks/hook-copilot-loader.sh\""
          },
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.ai/hooks/hook-session-guard.sh\""
          }
        ]
      },
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/.ai/hooks/hook-copilot-loader.sh\""
          }
        ]
      }
    ]
  }
}
"#;

// Canonical SessionStart boot hook, embedded verbatim (S32) so the scaffolded copy can
// never drift from the real one — the same one-source pattern as the co-pilot loader and
// session guard. This is what surfaces the Darshan speaking skill in every project's boot
// packet (S32 Darshan enforcement: advised -> enforced). Un-excluded in Cargo.toml so it
// ships with `cargo install`.
const TPL_HOOK_SESSION_START: &str = include_str!("../../scripts/hook-session-start.sh");

// Canonical co-pilot loader, embedded verbatim from the real script — one source of
// truth, no hand-copy, so it can never drift (the S19 rule Varta enforces). The file is
// un-excluded in Cargo.toml's `exclude` so it ships with `cargo install`.
const TPL_HOOK_COPILOT_LOADER: &str = include_str!("../../scripts/hook-copilot-loader.sh");

// Canonical session-guard (S26/S29) — one-session-per-chat enforcement, embedded
// verbatim so the scaffolded copy can never drift (S22 pattern). Gated on
// CONSTRAINTS.yaml#session.one_session_per_chat: true; records the owning chat in a
// gitignored `.ai/.session-owner`. Un-excluded in Cargo.toml so it ships with `cargo install`.
const TPL_HOOK_SESSION_GUARD: &str = include_str!("../../scripts/hook-session-guard.sh");

// The scaffold's `.gitignore` — the session-guard writes the owning chat's id into
// `.ai/.session-owner`, a local-only record that must never be committed.
const TPL_GITIGNORE: &str = r#"# Vajra session-guard owner record (one-session-per-chat) — local only, never commit.
.ai/.session-owner
"#;

// Darshan (S27/S28) — the human's glanceable output skill, embedded verbatim from the
// canonical file so the scaffolded copy can never drift. `darshan/` is not in Cargo.toml's
// `exclude`, so it already ships with `cargo install`. Skill-not-renderer holds: `init`
// only *copies* the skill + wires the AGENTS.md boot pointer; nothing in Rust renders it.
const TPL_DARSHAN: &str = include_str!("../../darshan/SKILL.md");

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

// Session-0 brief for brownfield repos (S34): the codebase existed before Vajra, so the
// first session studies it and seeds the .ai/ files with reality — no feature work.
const TPL_PROMPT_ONBOARD: &str = r#"# Session 00 — Brownfield Onboarding (study the codebase)

> This project existed before Vajra. Session 00 is a guided study session: learn the
> codebase, then fill the `.ai/` files with reality instead of empty templates. No
> feature work happens here — session 01 (`prompts/01-task-kickoff.md`) starts on facts.

## Goal (one story)
Study the existing repo and seed `.ai/KNOWLEDGE.md` + `.ai/STATE.md` with a real
first-pass understanding.

## Steps
1. **Scan the repo** — layout, languages, entry points, how to build/test/run, CI,
   existing docs. Read the top-level manifests (package.json / Cargo.toml / etc.) first.
2. **Ask the founder** (max 5 framing questions) — what is this project, what state is it
   really in, what is the next milestone, what must never break, any no-go areas?
3. **Fill `.ai/KNOWLEDGE.md`** — permanent facts only: stack, commands, conventions,
   invariants, environment quirks. If you can't verify a fact, don't write it.
4. **Rewrite `.ai/STATE.md`** — What Currently Works / What Is Broken from observed
   reality (run the tests; the results are the evidence).
5. **Seed `.ai/ROADMAP.md`** with the founder's next milestone, then point `.ai/TASK.md`
   at `prompts/01-task-kickoff.md` and set `.ai/SESSION` to 01.

## Guardrails
- **Docs only**: `.ai/` files. No source-code edits, no refactors, no "quick fixes".
- Branch `session-00-onboarding` from `main`. Commits need the founder's approval token.
- Max 2 assumptions; unverifiable claims are questions for the founder, not facts.

## Exit Criteria
- Founder signs off that `KNOWLEDGE.md` + `STATE.md` match reality.
- Session 01 starts in a **new chat** from `prompts/01-task-kickoff.md`.
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

    // ── Scaffold propagation (S22) ────────────────────────────────────────────

    fn scaffold_tmp() -> tempfile::TempDir {
        let dir = tempfile::tempdir().unwrap();
        scaffold(dir.path(), "Demo", "build it", "L2").unwrap();
        dir
    }

    #[test]
    fn scaffold_emits_ground_truth_audits() {
        let dir = scaffold_tmp();
        let c = fs::read_to_string(dir.path().join(".ai/CONSTRAINTS.yaml")).unwrap();
        for needle in [
            "ground_truth:",
            "vision_alignment",
            "roadmap_alignment",
            "constitution_review",
            "drift_axes:",
            "vision_questions:",
        ] {
            assert!(c.contains(needle), "TPL_CONSTRAINTS missing {needle:?}");
        }
    }

    #[test]
    fn scaffold_emits_copilot_rules_and_refreshes() {
        let dir = scaffold_tmp();
        let c = fs::read_to_string(dir.path().join(".ai/CONSTRAINTS.yaml")).unwrap();
        assert!(c.contains("copilot:"), "missing copilot block");
        assert!(c.contains("=>"), "missing a ⚡on rule");
        // refreshed since pre-S20:
        assert!(c.contains("go ahead and commit"), "stale approval_tokens");
        assert!(
            c.contains("ground_truth_commit_exempt_branch_suffixes"),
            "missing GT exempt suffixes"
        );
    }

    #[test]
    fn scaffold_ships_copilot_hook_verbatim() {
        let dir = scaffold_tmp();
        let hook = dir.path().join(".ai/hooks/hook-copilot-loader.sh");
        assert!(hook.exists(), "hook not scaffolded");
        // The whole point of option (b): the scaffolded copy is byte-identical to the
        // canonical script — one source of truth, no drift.
        assert_eq!(
            fs::read_to_string(&hook).unwrap(),
            TPL_HOOK_COPILOT_LOADER,
            "scaffolded hook drifted from canonical"
        );
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            let mode = fs::metadata(&hook).unwrap().permissions().mode();
            assert_eq!(mode & 0o111, 0o111, "hook must be executable");
        }
    }

    #[test]
    fn scaffold_ships_darshan_skill_verbatim() {
        let dir = scaffold_tmp();
        let skill = dir.path().join("darshan/SKILL.md");
        assert!(skill.exists(), "Darshan skill not scaffolded");
        // Byte-identical to the canonical source — one source of truth, no drift (S22 pattern).
        assert_eq!(
            fs::read_to_string(&skill).unwrap(),
            TPL_DARSHAN,
            "scaffolded Darshan skill drifted from canonical darshan/SKILL.md"
        );
    }

    #[test]
    fn scaffold_wires_darshan_into_constitution() {
        let dir = scaffold_tmp();
        let agents = fs::read_to_string(dir.path().join(".ai/AGENTS.md")).unwrap();
        assert!(
            agents.contains("Speaking Skills"),
            "missing Speaking Skills boot section"
        );
        assert!(
            agents.contains("darshan/SKILL.md"),
            "AGENTS.md must point at the scaffolded Darshan skill"
        );
    }

    // ── Session-guard propagation (S29) ──────────────────────────────────────

    #[test]
    fn scaffold_ships_session_guard_verbatim() {
        let dir = scaffold_tmp();
        let hook = dir.path().join(".ai/hooks/hook-session-guard.sh");
        assert!(hook.exists(), "session-guard not scaffolded");
        // Byte-identical to canonical — one source of truth, no drift (S22 pattern).
        assert_eq!(
            fs::read_to_string(&hook).unwrap(),
            TPL_HOOK_SESSION_GUARD,
            "scaffolded session-guard drifted from canonical hook-session-guard.sh"
        );
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            let mode = fs::metadata(&hook).unwrap().permissions().mode();
            assert_eq!(mode & 0o111, 0o111, "session-guard must be executable");
        }
    }

    #[test]
    fn scaffold_wires_session_guard_into_settings() {
        let dir = scaffold_tmp();
        let s = fs::read_to_string(dir.path().join(".claude/settings.json")).unwrap();
        assert_eq!(
            s.matches("hook-session-guard.sh").count(),
            1,
            "session-guard must be wired once (PreToolUse Bash)"
        );
        // Both Bash-matcher co-pilot + guard fire on Bash: the guard rides the Bash matcher.
        assert!(s.contains("hook-copilot-loader.sh"), "co-pilot wiring lost");
    }

    #[test]
    fn scaffold_emits_one_session_per_chat_flag() {
        let dir = scaffold_tmp();
        let c = fs::read_to_string(dir.path().join(".ai/CONSTRAINTS.yaml")).unwrap();
        assert!(
            c.contains("one_session_per_chat: true"),
            "session-guard is gated on one_session_per_chat: true"
        );
    }

    #[test]
    fn scaffold_gitignores_session_owner() {
        let dir = scaffold_tmp();
        let gi = dir.path().join(".gitignore");
        assert!(gi.exists(), ".gitignore not scaffolded");
        assert!(
            fs::read_to_string(&gi)
                .unwrap()
                .contains(".ai/.session-owner"),
            ".gitignore must ignore the session-guard owner record"
        );
    }

    // ── Brownfield onboarding + hook placement (S34) ──────────────────────────

    #[test]
    fn scaffold_hooks_land_in_ai_hooks_not_scripts() {
        let dir = scaffold_tmp();
        for hook in [
            "hook-session-start.sh",
            "hook-copilot-loader.sh",
            "hook-session-guard.sh",
        ] {
            assert!(
                dir.path().join(".ai/hooks").join(hook).exists(),
                "{hook} missing from .ai/hooks/"
            );
            assert!(
                !dir.path().join("scripts").join(hook).exists(),
                "{hook} must not land in the project's scripts/"
            );
        }
        let s = fs::read_to_string(dir.path().join(".claude/settings.json")).unwrap();
        assert!(
            s.contains("$CLAUDE_PROJECT_DIR/.ai/hooks/hook-session-start.sh"),
            "settings.json must point at .ai/hooks/"
        );
        assert!(
            !s.contains("scripts/hook-"),
            "settings.json still references scripts/ hooks"
        );
    }

    #[test]
    fn scaffold_empty_repo_is_greenfield() {
        let dir = scaffold_tmp();
        assert_eq!(
            fs::read_to_string(dir.path().join(".ai/SESSION")).unwrap(),
            "01\n"
        );
        assert!(!dir
            .path()
            .join("prompts/00-task-brownfield-onboarding.md")
            .exists());
        let task = fs::read_to_string(dir.path().join(".ai/TASK.md")).unwrap();
        assert!(task.contains("prompts/01-task-kickoff.md"));
    }

    #[test]
    fn scaffold_existing_code_gets_session_zero() {
        let dir = tempfile::tempdir().unwrap();
        fs::create_dir_all(dir.path().join("src")).unwrap();
        fs::write(dir.path().join("src/index.ts"), "export {};\n").unwrap();
        fs::write(dir.path().join("package.json"), "{}\n").unwrap();
        scaffold(dir.path(), "Demo", "build it", "L2").unwrap();

        assert_eq!(
            fs::read_to_string(dir.path().join(".ai/SESSION")).unwrap(),
            "00\n"
        );
        let brief = dir.path().join("prompts/00-task-brownfield-onboarding.md");
        assert!(brief.exists(), "onboarding brief not emitted");
        let brief = fs::read_to_string(brief).unwrap();
        for needle in [
            "KNOWLEDGE.md",
            "STATE.md",
            "Docs only",
            "session-00-onboarding",
        ] {
            assert!(
                brief.contains(needle),
                "onboarding brief missing {needle:?}"
            );
        }
        // Session 00 studies; session 01 still holds the user's goal.
        let task = fs::read_to_string(dir.path().join(".ai/TASK.md")).unwrap();
        assert!(task.contains("Session 00 — Brownfield onboarding"));
        assert!(task.contains("prompts/00-task-brownfield-onboarding.md"));
        assert!(dir.path().join("prompts/01-task-kickoff.md").exists());
    }

    #[test]
    fn brownfield_detection_ignores_scaffold_owned_paths() {
        let dir = scaffold_tmp();
        // A fully-scaffolded (or re-run) project is not brownfield…
        assert!(!is_brownfield(dir.path()));
        // …but one real source file flips it.
        fs::write(dir.path().join("main.py"), "print()\n").unwrap();
        assert!(is_brownfield(dir.path()));
    }

    #[test]
    fn aha_fallback_is_informative() {
        let s = render_aha_fallback();
        assert!(s.contains("⚡on(cmd:git commit)"), "fallback lost the rule");
        assert!(s.contains(".ai/STATE.md"), "fallback lost the include");
        assert!(s.contains("guided"), "fallback lost the framing");
    }

    #[test]
    fn scaffold_wires_copilot_into_settings() {
        let dir = scaffold_tmp();
        let s = fs::read_to_string(dir.path().join(".claude/settings.json")).unwrap();
        assert_eq!(
            s.matches("hook-copilot-loader.sh").count(),
            2,
            "co-pilot must be wired for both Bash and Edit|Write|MultiEdit"
        );
        assert!(s.contains("PreToolUse"), "missing PreToolUse wiring");
    }
}
