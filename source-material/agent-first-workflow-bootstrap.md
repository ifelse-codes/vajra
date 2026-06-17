# Agent-First Session Workflow — Bootstrap Prompt

**Version:** 1.0
**Date:** 2026-05-27
**Author:** *(your name here)*
**License:** *(MIT / CC0 / "use freely, attribution appreciated")*

> A self-contained prompt you paste into a fresh Claude Code / Codex / Cursor session in **any new repository** to install a complete agent-first session workflow — atomic session loops, paired audit files, single source of truth, defense-in-depth hooks, and a fail-closed closeout gate. One paste, ~10 minutes, no trial-and-error.

---

## TLDR (LinkedIn-ready)

> I've been running AI coding agents (Claude Code, Cursor, Codex) for the last few months and watching them drift, hallucinate context across sessions, and lose state when I switched chats. I built a session-based workflow that fixes this — a constitution + state files + Claude Code hooks + tracked git hooks + a fail-closed verifier. After running it across two projects (~20 sessions in one), I've distilled it into a single bootstrap prompt that installs the whole system on any repo.
>
> **What you get:** auditable session pairs (input prompt + output summary), a single-integer source of truth, every-5th-session NO-CODE audits (caught real drift twice already), an end-of-session "present 3 options" rule that forces deliberate transitions, and 5 layers of enforcement so a bad commit becomes mechanically harder than a good one.
>
> Curious for feedback — especially from folks already running agents at scale. Repro prompt below.

---

## What You Get

| Capability | Mechanism |
|---|---|
| Auditable session pairs | `prompts/NN-task-<slug>.md` (input) + `sessions/session-NN-summary.md` (output) |
| Single source of truth | `.ai/SESSION` (one integer; every `.ai/` file reconciles to it) |
| Cross-agent compatibility | Root pointers `AGENTS.md` / `CLAUDE.md` / `.cursorrules` → `.ai/AGENTS.md` |
| Defense-in-depth (5 layers) | L2 tracked git hooks · L3 Claude Code hooks · L4 fail-closed `verify-closeout.sh` · L5 `.ai/SESSION` integer (L0/L1 server-side when remote exists) |
| Drift detection | `scripts/hook-drift-guard.sh` cross-checks `.ai/SESSION` ↔ `SESSION-BOOT.md` ↔ `TASK.md` |
| Ground Truth audits | Every 5th session is NO-CODE; hooks hard-block code edits + commits |
| End-of-session "present and prepare" | Agent must offer exactly 3 options (A/B/C) and write the next prompt before closing |
| Approval-gated commits | Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead` |
| Snapshot vs log discipline | `STATE.md` overwritten in full at every closeout — never grows |

## Why This Workflow

Three pains it solves:

1. **Cross-session amnesia.** Agents lose context when you switch chats. The `.ai/` constitution + paired prompt/summary files reconstitute state without replaying conversation.
2. **Silent drift.** State files claim things the repo doesn't reflect. The fail-closed `verify-closeout.sh` and 5-layer enforcement catch drift before it compounds.
3. **Mid-session scope creep.** The 1-story-per-session + 3-files-per-commit + 2h cap rules force atomic work. The "present 3 options" closeout forces deliberate transitions instead of "I'll just keep going."

## Before You Paste

Mentally replace these six variables inside the prompt:

| Variable | Example | What it is |
|---|---|---|
| `{{PROJECT_NAME}}` | `Foobar` | Product name |
| `{{ONE_LINE_PURPOSE}}` | `Real-time IoT dashboard` | One-sentence positioning |
| `{{PRIMARY_STACK}}` | `Next.js 15 + TypeScript + pnpm` | Target tech stack |
| `{{OWNER_NAME}}` | `Alex` | Owner / founder |
| `{{OWNER_EMAIL}}` | `you@example.com` | Owner contact |
| `{{CANONICAL_DOC_PATH}}` | `docs/PRD.md` or `none yet` | Where the PRD/strategy lives |

If you don't know an answer yet, write "TBD" — the agent will follow up in Step 0.

---

# ===== BEGIN PROMPT (paste from here through `===== END PROMPT =====`) =====

You are bootstrapping the **agent-first session workflow** on this repository. This is **Session 00 — Discovery & Scaffolding**.

## Your role

Senior full-stack + AI engineer + architect. You design, verify, and document state changes deterministically. Move fast on engineering. Slow on assumptions. Never on user trust.

## Communication style (mandatory for every response)

- Under 200 words per response.
- Bullets and tables. No paragraphs of prose.
- Max 5 bullets per section.
- No filler phrases ("Sure!", "Great question!", "I'll help with that").
- No trailing summaries.
- Code first. Show diffs, don't describe them.

## Step 0 — Confirm context, then ask

Survey the repo:

```bash
ls -la
test -d .git && git log --oneline -5 || echo "no git history yet"
test -d .ai && echo "WARNING: .ai/ already exists — abort if not a fresh bootstrap"
```

Then ask the user to fill these blanks **once**:

1. Project name
2. One-sentence positioning
3. Target tech stack
4. Owner name + email
5. Path to canonical PRD/strategy doc, if one exists; else "none yet"

Wait for answers. These fill the `{{ }}` placeholders below.

## Step 1 — Initialize git baseline (if absent)

```bash
# If .git is missing:
git init -b main
git add -A
git commit -m "chore: initial baseline ($(date -u +%F))"
git checkout -b session-00-discovery
```

If `.git` already exists with `main`, just `git checkout -b session-00-discovery`.

## Step 2 — Create `.ai/` directory and 8 core files

### `.ai/SESSION`

A file containing the single integer `00` followed by a newline. That's it.

### `.ai/AGENTS.md`

````markdown
# {{PROJECT_NAME}} — AI Agent Constitution

> Every AI agent (Claude Code, Cursor, Codex, Kilo, Aider, Continue, others) **MUST** read this file and the Load Order below before executing any task.

---

## What This Repo Is

{{PROJECT_NAME}} is {{ONE_LINE_PURPOSE}}.

**Stack:** {{PRIMARY_STACK}}

---

## Agent Communication Style (Mandatory)

| Rule | Detail |
|------|--------|
| Under 200 words | If it can be said in one sentence, don't use three. |
| Bullets and tables | No paragraphs of prose. |
| Max 5 bullets per section | Split if more needed. |
| No filler phrases | Never start with "Sure!", "Great question!", "I'll help with that". |
| No trailing summaries | Do not restate what you just did. |
| Code first | Show the code/command. Explanation (if needed) comes after. |
| Show diffs, don't describe them | The tool already shows the edit. |

---

## Mandatory Load Order (Every Session)

1. `.ai/AGENTS.md` (this file)
2. `.ai/SESSION` — single integer; SoT for current session number
3. `.ai/SESSION-BOOT.md` — current state snapshot + next prompt pointer
4. `.ai/TASK.md` — what this session must deliver
5. `.ai/STATE.md` — what is working / broken / paused
6. `.ai/CONSTRAINTS.yaml` — machine-readable hard rules
7. `.ai/KNOWLEDGE.md` — permanent env facts (on demand)
8. `.ai/ROADMAP.md` — phases ahead (on demand)
9. `prompts/NN-task-<slug>.md` — current session's input contract

Under Claude Code, the `SessionStart` hook in `.claude/settings.json` prints files 2–6 automatically.

---

## Session Loop (10 Steps — All Mandatory)

1. **BOOT** — Read load order. Confirm session goal in <100 words. STOP if `TASK.md` is empty.
2. **BRANCH** — `git checkout -b session-NN-<slug>` from `main`. Never work on `main`.
3. **PLAN** — Bullets. Max 2 assumptions. Wait for approval token.
4. **EXECUTE** — Atomic changes. Update `ROADMAP.md` [x] on completion. Update `KNOWLEDGE.md` on new permanent fact.
5. **VERIFY** — `scripts/verify-session-NN.sh` exits 0 = done. Artifacts at `.ai/verify/session-NN/<ts>/` with `latest` symlink.
6. **PR** — Open PR to `main`. Not closed until merged.
7. **SUMMARY** — `sessions/session-NN-summary.md`. Required: goal achieved? evidence? exactly 3 next options A/B/C.
8. **NEXT** — After user picks, write `prompts/NN+1-task-<slug>.md`. Update `.ai/TASK.md` pointer.
9. **CLOSEOUT** — Sync all `.ai/` files. `.ai/SESSION` → current N. STATE.md REPLACE. ROADMAP.md mark [x]. KNOWLEDGE.md add permanent facts. TASK.md = "between sessions". SESSION-BOOT.md update `**Number:**`. `verify-closeout.sh` must exit 0.
10. **CLOSE** — Start next session in a new chat from the new prompt file.

---

## End-of-Session "Present and Prepare"

Step 7 is not finished until the agent has:

1. Updated `.ai/ROADMAP.md`.
2. Presented **exactly 3** candidate next sessions (A/B/C) drawn from ROADMAP. Each: title, one-sentence goal, why-pick-this, key risk.
3. Waited for the user's pick.
4. Written `prompts/NN+1-task-<slug>.md`.
5. Updated `.ai/TASK.md` pointer.
6. Committed the closeout bundle.

---

## Ground Truth Session (Every 5th Session — No Code)

`NN % 5 == 0` → mandatory NO-CODE. No source-code edits, no commits, no PRs.

Checklist: re-read `.ai/`, drift audit, stale-fact audit, roadmap rerank, cost audit, constraint review. Output: `sessions/session-NN-ground-truth.md`. User signs off before code resumes.

Hooks (`hook-pre-bash.sh`, `hook-pre-write.sh`) enforce. Authorized hardening goes on a `session-NN-closeout` or `session-NN-enforcement` branch (exempt by suffix).

---

## Hard Rules

| Rule | Detail |
|---|---|
| Max 2 assumptions | More → STOP and ask |
| Max 2 error retries | 3rd failure → escalate |
| No autonomous commits | Wait for approval token |
| No `main` commits | Branch first |
| No code in Ground Truth | Hook-enforced |
| Verification = exit 0 | Never leave red |
| State is snapshot | Never append history |
| Max 1 story per session | Larger → split |
| Max 3 files per atomic commit | Hook-enforced |
| ~2h per session cap | Marathon = drift |

**Approval tokens:** `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.

---

## Self-Review (Before Every Ship)

1. What can break?
2. Hidden assumptions?
3. Production ready?
4. Defensive patches only on repro evidence?
5. Scope intact?

If any answer is shaky → do not ship.

---

## Defense-in-Depth Layers

| Layer | Mechanism |
|---|---|
| L0 | Server branch protection on `main` (when remote exists) |
| L1 | CI gate on PRs (when CI exists) |
| L2 | Tracked git hooks (`.githooks/pre-commit`, `pre-push`) |
| L3 | Claude Code hooks (`.claude/settings.json` + `scripts/hook-*.sh`) |
| L4 | `scripts/verify-closeout.sh` (fail-closed) |
| L5 | `.ai/SESSION` (single integer SoT) |

A check that cannot evaluate FAILS. Never silently pass.

---

## ADRs (Locked — Deviations Need Explicit User Approval)

*None yet.*
````

### `.ai/SESSION-BOOT.md`

````markdown
# Session Boot

## Current Session
- **Number:** 00 — COMPLETE
- **Type:** Bootstrap / Discovery
- **Branch:** `session-00-discovery`
- **Date last updated:** (today)

## Live URLs / Endpoints
None.

## Repo State Snapshot
- `.ai/SESSION` = 00.
- `main`: baseline only.
- Enforcement layers L2–L5 in place. L0/L1 deferred until remote + CI exist.

## Next Session
- **Number:** 01
- **Type:** CODE — first real work session
- **Story:** *pending — user picks A / B / C from `sessions/session-00-summary.md`.*
- **Read prompt:** `prompts/01-task-<slug>.md` (written once user picks)

## Carry-Forwards
- Activate git hooks per clone: `git config core.hooksPath .githooks`.
- Set git user identity globally.
- Add remote to enable L0 + L1.
````

### `.ai/TASK.md`

````markdown
# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 00 — Bootstrap — COMPLETE

Discovery + `.ai/` scaffolding + hook system + verify gates. Full record: `sessions/session-00-summary.md` + `prompts/00-task-discovery.md`.

### Between Sessions

Repo is **between sessions** until user picks A/B/C from `sessions/session-00-summary.md`.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
````

### `.ai/STATE.md`

````markdown
# {{PROJECT_NAME}} — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S00 complete, S01 not yet started).

## Active PRs
None.

## What Currently Works
- Agent constitution at `.ai/AGENTS.md`. Root pointers resolve to it.
- Single-integer SoT at `.ai/SESSION` (= 00).
- Defense layers L2–L5 active.
- Session 00 audit pair: `prompts/00-task-discovery.md` + `sessions/session-00-summary.md`.

## What Is Broken
- Nothing in protocol.

## What Is In Progress
- Session 00 closeout pending PR merge. Then between-sessions until user picks Session 01 option.
````

### `.ai/CONSTRAINTS.yaml`

````yaml
version: 2

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
  ground_truth_commit_exempt_branch_suffixes: [-closeout, -enforcement]

commit:
  autonomous: false
  require_user_approval: true
  approval_tokens: [approved, lgtm, "ship it", "yes commit", "go ahead and commit", "go ahead"]
  forbid_skip_hooks: true
  forbid_force_push_to: [main, master]

verify:
  required_for_done: true
  script_pattern: 'scripts/verify-session-{NN}.sh'
  template: 'scripts/verify-session-template.sh'
  artifacts_dir: '.ai/verify/session-{NN}/'
  exit_zero_required: true
  closeout_script: 'scripts/verify-closeout.sh'
  closeout_must_pass_before_close: true

state:
  state_md_mode: snapshot
  knowledge_md_mode: append-permanent-only
  session_summary_in: sessions/session-{NN}-summary.md
  ground_truth_summary_in: sessions/session-{NN}-ground-truth.md
  session_prompt_in: prompts/{NN}-task-{slug}.md
  closeout_active_branch_value: "None — between sessions (SNN complete, SNN+1 not yet started)."

communication:
  max_words_per_response: 200
  required_formats: [bullets, tables, code-blocks]
  forbid: [greetings, apologies, filler, narration-of-thinking, trailing-summaries]
  max_bullets_per_section: 5

self_review_questions: [what_can_break, hidden_assumptions, production_ready, defensive_patches_only_on_repro_evidence, scope_intact]

end_of_session:
  must_present_n_options: 3
  options_drawn_from: .ai/ROADMAP.md
  options_format: [title, one_sentence_goal, why_pick_this, key_risk]
  must_write_next_prompt_before_close: true

ground_truth:
  forbid_code_changes: true
  forbid_commits: true
  forbid_prs: true
  required_outputs: [sessions/session-{NN}-ground-truth.md]
  required_audits: [state_drift, knowledge_staleness, roadmap_priority, constraint_violation_review]

load_order:
  - .ai/AGENTS.md
  - .ai/SESSION
  - .ai/SESSION-BOOT.md
  - .ai/TASK.md
  - .ai/STATE.md
  - .ai/CONSTRAINTS.yaml
  - .ai/KNOWLEDGE.md
  - .ai/ROADMAP.md
  - "prompts/{NN}-task-{slug}.md"

enforcement:
  binds_all_agents: true
  fail_closed: true
  closeout_not_done_until: scripts/verify-closeout.sh exits 0
````

### `.ai/KNOWLEDGE.md`

````markdown
# {{PROJECT_NAME}} — Knowledge Base

**Permanent facts only. Reloaded every session.**

## 1. System Information

| Item | Value |
|---|---|
| Working directory | (fill in) |
| OS | `(uname -a output)` |
| Shell | `(echo $SHELL)` |
| Git | initialized (today) |
| Owner | {{OWNER_NAME}} — {{OWNER_EMAIL}} |

## 2. Product Identity

- **Name:** {{PROJECT_NAME}}
- **Positioning:** {{ONE_LINE_PURPOSE}}

## 3. Repo Layout (Agent Workflow)

```
.ai/             Agent constitution + machine state
.claude/         Claude Code config (settings.json)
.githooks/       Tracked git hooks (pre-commit, pre-push)
scripts/         hook-*.sh, verify-session-NN.sh, verify-closeout.sh
prompts/         Session input contracts (NN-task-<slug>.md)
sessions/        Session output reports (session-NN-summary.md)
AGENTS.md        Root pointer (Codex)
CLAUDE.md        Root pointer (Claude Code)
.cursorrules     Root pointer (Cursor)
```

## 4. Planned Tech Stack

{{PRIMARY_STACK}}

## 5. Source Documents

- {{CANONICAL_DOC_PATH}}

## 6. Solved Problems / Decisions Made

*(empty initially)*
````

### `.ai/ROADMAP.md`

````markdown
# {{PROJECT_NAME}} — Working Roadmap

**Agent-facing backlog. Updated at every closeout.**

## Where We Are

| Field | Value |
|---|---|
| Today | (today) |
| Current phase | Phase 0 — Foundation |
| Completed sessions | 1 (Session 00) |
| Active session | none (between sessions) |
| Next session | Session 01 — pending option selection |

## Phase 0 — Foundation

| Workstream | Target session(s) | Status |
|---|---|---|
| Agent protocol bootstrap | Session 00 | [x] done |
| (project-specific workstreams) | Session 01+ | [ ] planned |
| Session 05 NO-CODE audit | Session 05 | [ ] planned |

## Rules For This Document

1. Update at every closeout.
2. Session numbers aspirational, not contracts.
3. NO-CODE audit sessions at 05, 10, 15, 20, 25.
4. New workstreams emerging mid-flight — add here with a discussion note.
````

## Step 3 — Create root cross-agent pointers

### `AGENTS.md` (root)

````markdown
# AGENTS.md — Cross-Agent Entry Point

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
9. `prompts/NN-task-<slug>.md`

Hard rules headline: no `main` commits · no autonomous commits · max 2 assumptions / 2 retries / 1 story / 3 files per commit / ~2h cap · every 5th session NO-CODE · closeout not done until `scripts/verify-closeout.sh` exits 0.
````

### `CLAUDE.md` (root)

Identical content to `AGENTS.md`. Claude Code reads `CLAUDE.md` by convention.

### `.cursorrules`

Same content as `AGENTS.md`, plus a "Communication style" footer: under 200 words, bullets, no filler, no trailing summaries, code first.

## Step 4 — Claude Code hook system

### `.claude/settings.json`

````json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "hooks": {
    "SessionStart": [{
      "hooks": [
        {"type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hook-session-start.sh\""},
        {"type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hook-drift-guard.sh\""}
      ]
    }],
    "UserPromptSubmit": [{"hooks": [{"type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hook-prompt-submit.sh\""}]}],
    "PreToolUse": [
      {"matcher": "Bash", "hooks": [{"type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hook-pre-bash.sh\""}]},
      {"matcher": "Edit|Write|MultiEdit", "hooks": [{"type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hook-pre-write.sh\""}]}
    ],
    "Stop": [{"hooks": [{"type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/scripts/hook-stop.sh\""}]}]
  }
}
````

### `scripts/hook-session-start.sh`

````bash
#!/usr/bin/env bash
# SessionStart hook: prints mandatory load-order files. Non-blocking.

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"

echo "=== {{PROJECT_NAME}} Agent Boot (per .ai/AGENTS.md) ==="
echo ""

for f in .ai/SESSION .ai/SESSION-BOOT.md .ai/TASK.md .ai/STATE.md .ai/CONSTRAINTS.yaml; do
  if [ -f "$ROOT/$f" ]; then
    echo "----- $f -----"
    cat "$ROOT/$f"
    echo ""
  else
    echo "[hook warn] missing: $f" >&2
  fi
done

BRANCH=$(cd "$ROOT" && git branch --show-current 2>/dev/null || echo "?")
echo "Current branch: $BRANCH"

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo ""
  echo "[REMINDER] On $BRANCH. Branch session-NN-<slug> before any work."
fi

case "$BRANCH" in
  *-closeout|*-enforcement) : ;;
  *)
    SESSION_NUM=$(echo "$BRANCH" | grep -oE 'session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)
    if [[ "$SESSION_NUM" =~ ^[0-9]+$ ]] && [ "$((10#$SESSION_NUM))" -gt 0 ] && [ "$((10#$SESSION_NUM % 5))" -eq 0 ]; then
      echo ""
      echo "[REMINDER] Session $SESSION_NUM is GROUND TRUTH. No code, no commits, no PRs."
    fi
  ;;
esac

exit 0
````

### `scripts/hook-prompt-submit.sh`

````bash
#!/usr/bin/env bash
# UserPromptSubmit hook: lightweight reminders. Non-blocking.

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
BRANCH=$(cd "$ROOT" && git branch --show-current 2>/dev/null || echo "?")

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "[reminder] On $BRANCH. New work must be on a session-NN-<slug> branch."
fi

case "$BRANCH" in
  *-closeout|*-enforcement) : ;;
  *)
    SESSION_NUM=$(echo "$BRANCH" | grep -oE 'session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)
    if [[ "$SESSION_NUM" =~ ^[0-9]+$ ]] && [ "$((10#$SESSION_NUM))" -gt 0 ] && [ "$((10#$SESSION_NUM % 5))" -eq 0 ]; then
      echo "[reminder] Ground Truth Session $SESSION_NUM — no code, no commits, no PRs."
    fi
  ;;
esac

exit 0
````

### `scripts/hook-pre-bash.sh`

````bash
#!/usr/bin/env bash
# PreToolUse(Bash): warns on destructive cmds; blocks commits during Ground Truth.

INPUT=$(cat 2>/dev/null || echo "{}")
CMD=$(echo "$INPUT" | python3 -c "import sys,json
try:
  d=json.load(sys.stdin)
  print(d.get('tool_input',{}).get('command',''))
except Exception:
  print('')" 2>/dev/null || echo "")

case "$CMD" in
  *"git commit"*|*"git push"*|*"git reset --hard"*|*"git push --force"*|*"rm -rf"*|*"--no-verify"*|*"--no-gpg-sign"*|*"git checkout ."*|*"git restore ."*|*"git clean -f"*|*"git branch -D"*)
    echo "[HOOK WARNING] Destructive/publish/skip-verify command:"
    echo "  $CMD"
    echo "[HOOK WARNING] Per .ai/AGENTS.md, confirm explicit user approval first."
    ;;
esac

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
BRANCH=$(cd "$ROOT" && git branch --show-current 2>/dev/null || echo "?")

GT=0; GT_NUM=""
case "$BRANCH" in
  *-closeout|*-enforcement) GT=0 ;;
  *)
    SNUM=$(echo "$BRANCH" | grep -oE 'session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)
    if [[ "$SNUM" =~ ^[0-9]+$ ]] && [ "$((10#$SNUM))" -gt 0 ] && [ "$((10#$SNUM % 5))" -eq 0 ]; then
      GT=1; GT_NUM="$SNUM"
    fi
  ;;
esac

if [ "$GT" -eq 1 ]; then
  case "$CMD" in
    *"git commit"*|*"git push"*|*"gh pr create"*|*"gh pr merge"*|*"glab mr create"*|*"glab mr merge"*)
      echo "[HOOK BLOCK] Ground Truth Session $GT_NUM forbids commits/pushes/PR ops."
      exit 2
      ;;
  esac
fi

exit 0
````

### `scripts/hook-pre-write.sh`

````bash
#!/usr/bin/env bash
# PreToolUse(Edit|Write|MultiEdit): blocks code edits during Ground Truth.

INPUT=$(cat 2>/dev/null || echo "{}")
FILE=$(echo "$INPUT" | python3 -c "import sys,json
try:
  d=json.load(sys.stdin)
  ti=d.get('tool_input',{})
  print(ti.get('file_path') or ti.get('notebook_path') or '')
except Exception:
  print('')" 2>/dev/null || echo "")

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
BRANCH=$(cd "$ROOT" && git branch --show-current 2>/dev/null || echo "?")
SESSION_NUM=$(echo "$BRANCH" | grep -oE 'session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)

case "$BRANCH" in
  *-closeout|*-enforcement) GT_PW=0 ;;
  *)
    if [ -n "$SESSION_NUM" ] && [ "$((10#$SESSION_NUM))" -gt 0 ] && [ "$((10#$SESSION_NUM % 5))" -eq 0 ]; then
      GT_PW=1
    else
      GT_PW=0
    fi
  ;;
esac

if [ "$GT_PW" -eq 1 ]; then
  case "$FILE" in
    */sessions/session-*-ground-truth.md|*/.ai/*) : ;;
    *)
      echo "[HOOK BLOCK] Ground Truth Session $SESSION_NUM forbids edits to $FILE"
      exit 2
      ;;
  esac
fi

if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "[HOOK WARNING] Editing files while on $BRANCH. Branch session-NN-<slug> first."
fi

exit 0
````

### `scripts/hook-stop.sh`

````bash
#!/usr/bin/env bash
# Stop hook: auto-runs verify-session-NN.sh.

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
BRANCH=$(cd "$ROOT" && git branch --show-current 2>/dev/null || echo "?")
SESSION_NUM=$(echo "$BRANCH" | grep -oE 'session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)

if [ -z "$SESSION_NUM" ]; then exit 0; fi

if [ "$((10#$SESSION_NUM))" -gt 0 ] && [ "$((10#$SESSION_NUM % 5))" -eq 0 ]; then
  GT="$ROOT/sessions/session-${SESSION_NUM}-ground-truth.md"
  if [ ! -f "$GT" ]; then
    echo "[HOOK STOP] Ground Truth Session $SESSION_NUM missing $GT"
  fi
  exit 0
fi

VERIFY="$ROOT/scripts/verify-session-${SESSION_NUM}.sh"
if [ -f "$VERIFY" ]; then
  echo "[hook stop] Running $VERIFY"
  if bash "$VERIFY"; then
    echo "[hook stop] ALL GREEN."
  else
    echo "[HOOK STOP] VERIFY FAILED for session $SESSION_NUM. Fix before close."
  fi
else
  echo "[hook stop] No verify script at $VERIFY. Session $SESSION_NUM needs one before close."
fi

exit 0
````

### `scripts/hook-drift-guard.sh`

````bash
#!/usr/bin/env bash
# Drift guard: asserts .ai/ agrees on the current session.

set -uo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

QUIET=0
[ "${1:-}" = "--quiet" ] && QUIET=1

banner() {
  echo ""
  echo "⚠ .ai/ DRIFT — STOP, fix before any work"
  echo "  $1"
  echo "  (.ai/SESSION is the single source of truth.)"
  echo ""
}

if [ ! -f .ai/SESSION ]; then banner ".ai/SESSION missing"; exit 1; fi
N="$(tr -d ' \t\n\r' < .ai/SESSION)"
if ! [[ "$N" =~ ^[0-9]+$ ]]; then banner ".ai/SESSION not an integer: '$N'"; exit 1; fi
Ni="$((10#$N))"

drift=0; detail=""

if [ -f .ai/SESSION-BOOT.md ]; then
  boot="$(grep -m1 -E '\*\*Number:\*\*' .ai/SESSION-BOOT.md | grep -oE '[0-9]+' | head -1)"
  if [ -z "$boot" ]; then
    drift=1; detail="SESSION-BOOT.md has no **Number:** integer"
  elif [ "$((10#$boot))" -ne "$Ni" ]; then
    drift=1; detail="SESSION-BOOT Number=$boot != .ai/SESSION=$Ni"
  fi
else
  drift=1; detail=".ai/SESSION-BOOT.md missing"
fi

if [ "$drift" -eq 0 ] && [ -f .ai/TASK.md ]; then
  pad="$(printf '%02d' "$Ni")"
  if ! grep -qiE "Session 0*${Ni}\b" .ai/TASK.md \
     && ! grep -qiE "Session ${pad}\b" .ai/TASK.md \
     && ! grep -qiE "between sessions" .ai/TASK.md; then
    drift=1; detail="TASK.md references neither Session $Ni nor 'between sessions'"
  fi
fi

if [ "$drift" -ne 0 ]; then banner "$detail"; exit 1; fi

[ "$QUIET" -eq 0 ] && echo "[drift-guard] OK — .ai/ consistent at session $Ni"
exit 0
````

All six `chmod +x`.

## Step 5 — Tracked git hooks

### `.githooks/pre-commit`

````bash
#!/usr/bin/env bash
# Tracked pre-commit hook. Activated by: git config core.hooksPath .githooks

set -uo pipefail
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || echo DETACHED)"
case "$branch" in
  main|master)
    echo "[pre-commit BLOCK] Direct commits to '$branch' forbidden. Branch session-NN-<slug> first."
    exit 1 ;;
esac

staged="$(git diff --cached --name-only --diff-filter=ACMR | sed '/^$/d' | wc -l | tr -d ' ')"
if [ "${staged:-0}" -gt 3 ]; then
  echo "[pre-commit BLOCK] $staged files staged; max 3 per atomic change."
  exit 1
fi

if [ -f .ai/SESSION ] && [ -f .ai/SESSION-BOOT.md ]; then
  n="$(tr -d ' \t\n\r' < .ai/SESSION)"
  boot="$(grep -m1 -E '\*\*Number:\*\*' .ai/SESSION-BOOT.md | grep -oE '[0-9]+' | head -1)"
  if [ -n "$n" ] && [ -n "$boot" ] && [ "$((10#$n))" -ne "$((10#$boot))" ]; then
    echo "[pre-commit BLOCK] .ai/ drift: .ai/SESSION=$n but SESSION-BOOT Number=$boot."
    exit 1
  fi
fi

if [ -x scripts/hook-drift-guard.sh ]; then
  scripts/hook-drift-guard.sh --quiet || {
    echo "[pre-commit BLOCK] drift-guard reported drift."
    exit 1
  }
fi

exit 0
````

### `.githooks/pre-push`

````bash
#!/usr/bin/env bash
# Tracked pre-push: blocks pushes to main/master.

set -uo pipefail

blocked=0
while read -r localref localsha remoteref remotesha; do
  [ -z "${remoteref:-}" ] && continue
  case "$remoteref" in
    refs/heads/main|refs/heads/master)
      echo "[pre-push BLOCK] Push to '$remoteref' forbidden. Open a PR/MR instead."
      blocked=1 ;;
  esac
done

exit "$blocked"
````

### `.githooks/README.md`

````markdown
# Tracked Git Hooks

Activate once per clone:

```bash
git config core.hooksPath .githooks
```

| Hook | Blocks |
|---|---|
| `pre-commit` | Commits on `main`/`master`; commits with >3 staged files; `.ai/` drift |
| `pre-push` | Pushes to `main`/`master` |

Fast local feedback only. Server-side branch protection and CI provide the real guarantees.
````

All `chmod +x`.

## Step 6 — Verify scripts

### `scripts/verify-closeout.sh`

````bash
#!/usr/bin/env bash
# Fail-closed closeout gate. Exit 0 = closeout done.
# Single source of truth: .ai/SESSION (one integer).

set -uo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

TS=$(date -u +%Y%m%dT%H%M%SZ)
ARTIFACTS=".ai/verify/closeout/${TS}"
mkdir -p "$ARTIFACTS"

PASS=0; FAIL=0; RESULTS=()
ok()  { RESULTS+=("$(printf '%-34s %s' "$1" PASS)"); PASS=$((PASS+1)); }
bad() { RESULTS+=("$(printf '%-34s %s' "$1" FAIL)"); FAIL=$((FAIL+1)); }

N=""
check_session_file() {
  local NAME="session-file-valid"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ ! -f .ai/SESSION ]; then echo "BLOCK: .ai/SESSION missing" > "$LOG"; bad "$NAME"; return; fi
  local raw; raw="$(tr -d ' \t\n\r' < .ai/SESSION)"
  if [[ "$raw" =~ ^[0-9]+$ ]]; then
    N="$((10#$raw))"; echo "OK: $raw (N=$N)" > "$LOG"; ok "$NAME"
  else
    echo "BLOCK: not an integer: '$raw'" > "$LOG"; bad "$NAME"
  fi
}

check_required_files() {
  local NAME="required-files-exist"; local LOG="$ARTIFACTS/${NAME}.log"
  : > "$LOG"
  local missing=0
  for f in .ai/AGENTS.md .ai/SESSION .ai/SESSION-BOOT.md .ai/TASK.md \
           .ai/STATE.md .ai/CONSTRAINTS.yaml .ai/KNOWLEDGE.md .ai/ROADMAP.md; do
    if [ -f "$f" ] && [ -s "$f" ]; then echo "OK: $f" >> "$LOG"
    else echo "MISSING/empty: $f" >> "$LOG"; missing=$((missing+1)); fi
  done
  if [ "$missing" -eq 0 ]; then ok "$NAME"; else bad "$NAME"; fi
}

check_session_boot() {
  local NAME="session-boot-current"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ -z "$N" ]; then echo "BLOCK: N unresolved" > "$LOG"; bad "$NAME"; return; fi
  local F=".ai/SESSION-BOOT.md"
  if [ ! -f "$F" ]; then echo "BLOCK: $F missing" > "$LOG"; bad "$NAME"; return; fi
  local num; num="$(grep -m1 -E '\*\*Number:\*\*' "$F" | grep -oE '[0-9]+' | head -1)"
  if [ -z "$num" ]; then echo "BLOCK: no **Number:** integer in $F" > "$LOG"; bad "$NAME"; return; fi
  if [ "$((10#$num))" -eq "$N" ]; then
    echo "OK: SESSION-BOOT Number=$num == N=$N" > "$LOG"; ok "$NAME"
  else
    echo "DRIFT: SESSION-BOOT Number=$num != .ai/SESSION N=$N" > "$LOG"; bad "$NAME"
  fi
}

check_task_ref() {
  local NAME="task-ref-current"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ -z "$N" ]; then echo "BLOCK: N unresolved" > "$LOG"; bad "$NAME"; return; fi
  local F=".ai/TASK.md"
  if [ ! -f "$F" ]; then echo "BLOCK: $F missing" > "$LOG"; bad "$NAME"; return; fi
  local padded; padded="$(printf '%02d' "$N")"
  if grep -qiE "Session 0*${N}\b" "$F" || grep -qiE "Session ${padded}\b" "$F" \
     || grep -qiE "between sessions" "$F"; then
    echo "OK: TASK.md references Session $N (or 'between sessions')" > "$LOG"; ok "$NAME"
  else
    echo "DRIFT: TASK.md does not reference Session $N nor 'between sessions'" > "$LOG"; bad "$NAME"
  fi
}

check_state_sections() {
  local NAME="state-required-sections"; local LOG="$ARTIFACTS/${NAME}.log"
  local F=".ai/STATE.md"
  if [ ! -f "$F" ]; then echo "BLOCK: $F missing" > "$LOG"; bad "$NAME"; return; fi
  : > "$LOG"
  local missing=0
  for h in "What Currently Works" "What Is Broken" "What Is In Progress"; do
    if grep -q "$h" "$F"; then echo "OK: $h" >> "$LOG"
    else echo "MISSING section: $h" >> "$LOG"; missing=$((missing+1)); fi
  done
  if [ "$missing" -eq 0 ]; then ok "$NAME"; else bad "$NAME"; fi
}

check_session_pair() {
  local NAME="session-prompt-summary-pair"; local LOG="$ARTIFACTS/${NAME}.log"
  shopt -s nullglob
  local summaries=(sessions/session-*-summary.md)
  local prompts=(prompts/[0-9]*-task-*.md)
  : > "$LOG"
  local missing=0
  if (( ${#summaries[@]} == 0 )); then echo "MISSING: no session summaries" >> "$LOG"; missing=$((missing+1)); fi
  if (( ${#prompts[@]} == 0 )); then echo "MISSING: no session prompts" >> "$LOG"; missing=$((missing+1)); fi
  for s in "${summaries[@]}"; do
    local base; base=$(basename "$s" -summary.md); local nn="${base#session-}"
    local matches=(prompts/${nn}-task-*.md)
    if (( ${#matches[@]} == 0 )); then
      echo "MISSING prompt for $s (expected prompts/${nn}-task-*.md)" >> "$LOG"
      missing=$((missing+1))
    else
      echo "OK: $s ↔ ${matches[0]}" >> "$LOG"
    fi
  done
  if [ "$missing" -eq 0 ]; then ok "$NAME"; else bad "$NAME"; fi
}

check_roadmap_current() {
  local NAME="roadmap-references-N"; local LOG="$ARTIFACTS/${NAME}.log"
  if [ -z "$N" ]; then echo "BLOCK: N unresolved" > "$LOG"; bad "$NAME"; return; fi
  local F=".ai/ROADMAP.md"
  if [ ! -f "$F" ]; then echo "BLOCK: $F missing" > "$LOG"; bad "$NAME"; return; fi
  local padded; padded="$(printf '%02d' "$N")"
  if grep -qiE "Session 0*${N}\b" "$F" || grep -qiE "Session ${padded}\b" "$F"; then
    echo "OK: ROADMAP.md references Session $N" > "$LOG"; ok "$NAME"
  else
    echo "DRIFT: ROADMAP.md does not reference Session $N" > "$LOG"; bad "$NAME"
  fi
}

check_session_file
check_required_files
check_session_boot
check_task_ref
check_state_sections
check_session_pair
check_roadmap_current

( cd ".ai/verify/closeout" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Closeout Verify Summary (N=${N:-?}) ==="
printf '%-34s %s\n' "STEP" "RESULT"
printf '%-34s %s\n' "----------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done
echo ""
echo "Artifacts: $ARTIFACTS"

if [ "$FAIL" -eq 0 ]; then
  echo "ALL GREEN ($PASS pass, 0 fail) — closeout is done."; exit 0
else
  echo "RED ($PASS pass, $FAIL fail) — closeout NOT done."; exit 1
fi
````

### `scripts/verify-session-template.sh`

````bash
#!/usr/bin/env bash
# Template — copy to scripts/verify-session-NN.sh and customize per session.

set -uo pipefail
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
# run_check "typecheck"  pnpm -r typecheck
# run_check "lint"       pnpm -r lint
# run_check "build"      pnpm -r build
# ========================

( cd ".ai/verify/session-${SESSION}" && ln -sfn "${TS}" "latest" ) 2>/dev/null || true

echo ""
echo "=== Session ${SESSION} Verify Summary ==="
printf '%-30s %s\n' "STEP" "RESULT"
printf '%-30s %s\n' "------------------------------" "------"
for r in "${RESULTS[@]}"; do echo "$r"; done

if [ "$FAIL" -eq 0 ]; then echo "ALL GREEN ($PASS pass, 0 fail)"; exit 0
else echo "RED ($PASS pass, $FAIL fail)"; exit 1; fi
````

Both `chmod +x`.

## Step 7 — `.gitignore`

````
node_modules/
.pnpm-store/
dist/
build/
.next/
.turbo/
coverage/
.vscode/
.idea/
*.swp
.DS_Store
.env
.env.local
.env.*.local
!.env.example
*.log
.ai/verify/                       # per-run timestamped artifacts
.claude/settings.local.json       # user-local Claude Code settings
````

## Step 8 — Session 00 audit pair

### `prompts/00-task-discovery.md`

Reverse-engineered input contract for Session 00. Sections: trigger, goal, deliverables, constraints operative, decisions made, exit criteria, explicit non-goals.

### `sessions/session-00-summary.md`

Output report. Sections:
- Header table (Session ID / Branch / Date / Goal / Verification / Status)
- Key activities
- Files created/modified table
- Assumptions made (max 2)
- Verification status (`verify-closeout.sh` output)
- Self-review (5 questions)
- **Exactly 3 options A/B/C** for Session 01 (drawn from `.ai/ROADMAP.md`):
  - Option A: most foundational / lowest-risk (recommend this)
  - Option B: focused spike validating a key assumption
  - Option C: parallel-track investment (e.g. CI, tooling)
- Recommended carry-forwards

## Step 9 — Verify closeout

```bash
chmod +x scripts/*.sh .githooks/pre-commit .githooks/pre-push
bash scripts/verify-closeout.sh
```

Must exit 0 with 7/7 PASS. Fix drift before continuing.

## Step 10 — Commit plan + Session 01 options

Announce the file inventory (~25 files) split into commits of **3 files max** per `CONSTRAINTS.yaml`. Wait for an approval token, then commit.

In the **same message**, present **exactly 3 options** for Session 01, each: title, one-sentence goal, why-pick-this, key risk. Recommend one.

When the user picks, write `prompts/01-task-<slug>.md`, update `.ai/TASK.md` to point at it, then close Session 00.

# ===== END PROMPT =====

---

## After Bootstrapping — Gotchas

1. **Activate `.githooks/` per clone:** `git config core.hooksPath .githooks`. Easy to forget; not enforced by anything.
2. **`chmod +x` everything in `scripts/` and `.githooks/`.** Common failure mode: committed without executable bit; hooks silently no-op.
3. **Don't skip Step 0 discovery questions.** Filling `{{ }}` is the single highest-leverage customization.
4. **`.ai/SESSION` is the L5 single source of truth.** Every other `.ai/` file reconciles to it. Drift → `verify-closeout.sh` fails.
5. **NO-CODE every 5th session.** Hook-enforced. Adds discipline; catches accumulated drift.
6. **The 3-options-A/B/C closeout is non-negotiable.** It's what makes session-to-session transitions feel deliberate rather than drift-y.
7. **Master prompt itself is versioned.** When you improve the workflow on one repo, bring improvements back here as v1.1, v1.2 …

---

## Feedback

I've shipped this on two real projects now and it's caught drift twice in NO-CODE audits, prevented at least one rage-amend commit on `main`, and reduced "wait, what session am I in?" moments to zero.

Reply / DM with:
- What broke when you tried it
- What you'd change
- Whether you have a similar pattern that's working
- Whether the `verify-closeout.sh` check list misses anything that drift-bit you in your repo

— *(your name)*

---

*Released under MIT / CC0 — copy, fork, remix freely. Attribution appreciated but not required.*
