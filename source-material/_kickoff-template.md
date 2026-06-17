# Kickoff: install AI-collab scaffolding in this repo

You are a senior engineer setting up a disciplined AI-collaboration scaffold
in this project, modeled on a working system I've used elsewhere. Do NOT
start coding the product. Set up the **process** first.

## Step 1 — Interview me (max 6 questions, in ONE message, then stop)

Ask only what you cannot infer from the repo. Likely gaps:

1. One-paragraph project description + first wedge (who/what/why now).
2. Stack (languages, frameworks, providers, hosting).
3. Git host (GitHub / GitLab) + remote URL + default branch.
4. Cadence: target session length (default 2h), ground-truth cadence
   (default every 5th session), max files per atomic change (default 3).
5. Domain trust rules — any claims the product MUST NOT make
   (e.g. "guaranteed", "exact SKU", "live availability"). Defaults to none.
6. Solo vs team; who is the "founder/maintainer" approver.

Wait for answers before writing anything.

## Step 2 — Generate the scaffold (one branch, one PR)

Branch: `chore/ai-scaffold-bootstrap`. Then create exactly these files.
No product code, no dependencies, no framework choices.

### Entry pointers (cross-agent)
- `CLAUDE.md` — thin pointer to `.ai/AGENTS.md` + the mandatory load order
  + the hard-rules summary table. Mirror as `AGENTS.md` and `.cursorrules`
  (same content, one-line note that `.ai/AGENTS.md` is source of truth).

### Constitution (the only long file)
- `.ai/AGENTS.md` with these sections, in this order:
  1. **What this repo is** — fill from interview answer #1, with a stack table.
  2. **Agent communication style** — under 200 words, bullets/tables, no
     filler ("Sure!", "Great question!"), no trailing summaries, code first.
  3. **Mandatory load order** every session: AGENTS → SESSION-BOOT → TASK →
     STATE → CONSTRAINTS → KNOWLEDGE (on demand) → ROADMAP (on demand).
  4. **Session loop, 10 steps:** BOOT → BRANCH → PLAN (max 2 assumptions,
     wait for "go ahead") → EXECUTE (one atomic change, update ROADMAP/
     KNOWLEDGE inline) → VERIFY (`scripts/verify-session-NN.sh` exits 0) →
     PR → SUMMARY (`sessions/session-NN-summary.md` with exactly 3 next
     options A/B/C) → NEXT (`prompts/NN+1-task.md`) → CLOSEOUT (sync all
     `.ai/` files; bump `.ai/SESSION`; `verify-closeout.sh` exits 0) → CLOSE.
  5. **Ground Truth Session** every Nth session (from interview), no code,
     output `sessions/session-NN-ground-truth.md`. Audits: drift, staleness,
     cost, constraint violations, roadmap rerank.
  6. **Hard rules table**: max 2 assumptions, max 2 retries, no autonomous
     commits (approval token required), no `main` commits, max 1 story,
     max 3 files per atomic change, ~2h cap, STATE.md is snapshot (replace),
     KNOWLEDGE.md is permanent-only, fix before close.
  7. **Self-review checklist** before every ship: what can break? hidden
     assumptions? would a senior engineer pass it? trust intact? defensive
     patches only with repro evidence.
  8. **ADR table** — start empty (`| ADR-001 | TBD |`).
  9. **Cross-agent compatibility** table.
  10. **Your role** — one paragraph.

### State files (short; humans must scan them in <30s)
- `.ai/SESSION` — single line: `0`
- `.ai/STATE.md` — sections: What Works / What Is Broken Or At Risk /
  What's Paused / Active Branch (default: "None — between sessions") /
  Active PRs / Last Verified / Provider Spend. **Snapshot, never append.**
- `.ai/TASK.md` — placeholder: "Between sessions. Write `prompts/01-task.md`
  before starting Session 01."
- `.ai/SESSION-BOOT.md` — Current Session / Live URLs / Repo State Snapshot
  / Next Session / Provider Spend.
- `.ai/ROADMAP.md` — phases derived from interview answer #1.
- `.ai/KNOWLEDGE.md` — empty with header explaining permanent-only rule
  and the "problem → root cause → fix" entry shape.

### Machine-readable rules
- `.ai/CONSTRAINTS.yaml` — version: 1; sections for session caps, branch
  pattern (`^session-\d{2}-[a-z0-9-]+$`), commit (`autonomous: false`,
  approval_tokens: [approved, "ship it", lgtm, "go ahead and commit"]),
  protected paths (`src/**`, `scripts/**`, `.ai/**`, `.claude/**`),
  verify (`exit_zero_required: true`), state (`state_md_mode: snapshot`),
  trust_claims (forbidden_phrases from interview answer #5),
  cost (per-session + cumulative thresholds — ask if not given),
  ground_truth (forbid_code_changes: true), enforcement layers L0–L5.

### Hooks (Claude Code)
- `.claude/settings.json` — SessionStart + UserPromptSubmit + PreToolUse
  (Bash, Edit|Write|MultiEdit) + Stop, each calling
  `bash "$CLAUDE_PROJECT_DIR/scripts/hook-<name>.sh"`.
- `scripts/hook-session-start.sh` — prints `.ai/SESSION-BOOT.md`, TASK,
  STATE, CONSTRAINTS to stdout.
- `scripts/hook-drift-guard.sh` — asserts `.ai/SESSION` matches current
  branch's NN; warns if `STATE.md`'s Active Branch contradicts `git branch`.
- `scripts/hook-prompt-submit.sh` — if on `main`, emit reminder: "On main.
  New work must be on a `session-NN-<slug>` branch."
- `scripts/hook-pre-bash.sh` — block `git commit` on `main`; block
  `git push --force` to `main`; if branch matches `session-N0-*` (ground
  truth), block edits to source paths.
- `scripts/hook-pre-write.sh` — block writes to `main`-protected paths
  when not on a `session-NN-*` branch.
- `scripts/hook-stop.sh` — remind to run `verify-session-NN.sh` if branch
  is a session branch and verify hasn't been run this turn.

All hook scripts: shebang `#!/usr/bin/env bash`, `set -euo pipefail`,
exit 0 on success, non-zero on block, human-readable message on stderr.
Make executable.

### Verify scripts
- `scripts/verify-session-template.sh` — copyable template: bash strict
  mode, prints `STEP | RESULT` table, accumulates failures, exit 0 only
  if all green.
- `scripts/verify-closeout.sh` — fail-closed assertions:
  (a) `.ai/SESSION` is an integer and matches the latest session summary;
  (b) `.ai/STATE.md` Active Branch == "None — between sessions ...";
  (c) `.ai/TASK.md` is not empty;
  (d) latest `prompts/NN-task.md` exists for SESSION+1;
  (e) no uncommitted changes in `.ai/`.

### Folders (with `.gitkeep`)
- `sessions/` `prompts/` `docs/adr/` `.ai/verify/`

### Tracked git hooks (optional L2, mirror of `.claude/` hooks)
- `.githooks/pre-commit` — same blocks as `hook-pre-bash.sh` for the
  commit path. Document one-time install:
  `git config core.hooksPath .githooks`.

## Step 3 — After files are written

1. Show me the diff of every created file (do NOT commit).
2. List each rule from `CONSTRAINTS.yaml` and where it's enforced
   (hook script / verify script / human PR review).
3. Wait for "approved" before committing.
4. After approval: commit on `chore/ai-scaffold-bootstrap`, open the PR,
   and write `prompts/01-task.md` with placeholder for Session 01.

## Non-negotiables for this kickoff

- No product code. No dependencies installed. No framework choices made.
- No file >250 lines (split if needed — except `AGENTS.md` which may be
  longer but stay <500).
- Every file you create must be referenced by at least one other file
  (no orphans).
- If you don't know something, ASK. Max 2 assumptions across the whole
  scaffold; if you'd need more, return to Step 1 with follow-ups.
