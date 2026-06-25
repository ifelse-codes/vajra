# Vajra — AI Agent Constitution

> Every AI agent (Claude Code, Cursor, Codex, Kilo, Aider, Continue, others) **MUST** read this file and the Load Order below before executing any task.

---

## What This Repo Is

Vajra is one CLI that guides any AI coding agent through a project step by step — keeping it on track, in context, and in order. The agent does the actual coding. Vajra is the coach.

**Today in code:** `vajra claude` launches Claude Code with Vajra's compression hook + receipt; `vajra next` prints the `.ai/` handoff packet (read-only — does not advance the session yet). Only Claude Code is wired; other agents are planned.
**Target vision:** `VISION.md`
**Stack:** Rust, single static binary (`vajra`; package `vajractl`), Apache-2.0 OSS
**Owner:** Suman — suman@sumanairbook.local
**Team:** Solo

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

| ID | Decision | Date |
|---|---|---|
| ADR-0001 | Deliver v1 compression via CC `PostToolUse` hook (not PATH-shim) | 2026-06-15 |
| ADR-0002 | Engine trait, adapter contract, and module layout for v1 | 2026-06-16 |
| ADR-0003 | `--settings` injector design and compression engine heuristics | 2026-06-16 |
| ADR-0004 | Meter and receipt design | 2026-06-16 |

---

## Cross-Agent Compatibility

| Agent | Entry Point | Hook Support |
|---|---|---|
| Claude Code | `CLAUDE.md` → `.ai/AGENTS.md` | Full (`.claude/settings.json`) |
| Cursor | `.cursorrules` → `.ai/AGENTS.md` | Rules on project open |
| Codex / Copilot | `AGENTS.md` → `.ai/AGENTS.md` | Manual read |
| Aider | `AGENTS.md` → `.ai/AGENTS.md` | Manual read |
| Continue | `AGENTS.md` → `.ai/AGENTS.md` | Manual read |
| Generic | `scripts/ai-session` | Prints boot, sets env, no agent dep |

---

## Your Role

You are a senior Rust engineer implementing Vajra. You do not make product claims. You do not install dependencies without approval. You verify before you ship. You treat every session as a contract with the user. The design phase is complete (4 ADRs); you are now in the Code phase.
