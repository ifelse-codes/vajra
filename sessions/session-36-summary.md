# Session 36 — Real Dogfood Run (option A from S35 GT)

**Type:** CODE-adjacent dogfood. Ran the real `vajra claude` loop against a real brownfield
repo, observed whether the S32/S33/S34 fixes hold *in a live session* (not just tests), captured
a receipt, and re-asked the second-agent gate.
**Branch:** `session-36-real-dogfood-run` · **Date:** 2026-07-02

## Setup

- **Playground:** `/private/tmp/chitra` — a 12M copy of `~/Downloads/chitra` (a real Replit-style
  pnpm monorepo; excluded its 441M `.local`, kept `.git` so git heuristics could be exercised).
  Clean brownfield — no prior `.ai/`/`.claude/` scaffold.
- **Binary:** freshly built `target/release/vajra` from this branch (S34 code).
- **Run 1 — `vajra init`:** brownfield-detected → session 00 onboarding.
- **Run 2 — `vajra claude -p "<analyze this repo>"` `--dangerously-skip-permissions`:** a real
  multi-tool session (6 tool calls), model `claude-fable-5`, receipt printed on exit.

## Verdict per fix (test-verified → now daily-use-verified)

| S31 fix | Test status (prior) | **Live dogfood result** |
|---|---|---|
| S34 brownfield onboarding | 11/11 green | ✅ **HOLDS** — `init` printed "Existing codebase detected → session 00"; 20 files; `.gitignore` idempotent-skipped; hooks in `.ai/hooks/`; co-pilot aha fired for real |
| S34 auth pre-check | tested | ✅ **HOLDS** — no nested-env 401 (S31's failure did **not** recur); pre-check passed (Keychain) and the real spawn authenticated |
| S32 Darshan enforcement | 18/18 green | ✅ **HOLDS + OBEYED** — boot directive confirmed injected into the nested transcript; the agent's reply came back glanceable (header + table + 5 bullets), **not** a wall of text |
| S33 compression schema | 9/9 green | 🔴 **DEAD IN REAL USE** — zero folds live; the S33 carry-note undersold it (see below) |

## 🔴🔴 THE headline (founder's interactive run) — Vajra enforced none of its own rules

Added after the founder ran their **own** interactive `vajra claude` session (not the `-p` run
above): session `8f9c103`, **Opus 4.8, $58.17**, `/private/tmp/chitra` at maturity **L3**.
Transcript (576 entries) reconstructed from `~/.claude/projects/-private-tmp-chitra/`.

In **one chat**, the agent: `git init` + `remote add` → the real `github.com/ifelse-codes/chitra`,
`git push origin main`, branched session-01, **built a whole feature, created + merged PR #1**,
branched session-01-closeout, **created + merged PR #2**, advanced `SESSION` → 01, wrote an S02
handoff. **Vajra's hooks stopped none of it.**

| Hard rule | What happened | Enforced? |
|---|---|---|
| One session per chat | ran ~4 sessions (00 → 01 → closeout → S02 handoff) in one | ❌ |
| No autonomous commits / approval tokens | committed, pushed, **merged 2 PRs** freely | ❌ |
| Max 1 story / ~2h cap | shipped a feature + closeout + handoff | ❌ |
| No `main` commits | committed baseline directly to `main` | ❌ |
| Compression | **0 folds** across 51 Bash + 25 Read calls | ❌ |

**Root cause (structural, 4 gaps):** (1) `hook-session-guard.sh` arms only on
`git checkout -b session-(N+1)` from an *owning* chat — the brownfield agent never branched
session-00, so nothing was owned and the tripwire never armed; (2) **no hook watches `git push` /
`gh pr create` / `gh pr merge`** at all; (3) `vajra init` scaffolds the `.claude/` hooks but not
git-level `pre-push`/`pre-commit`; (4) L3 (auto) gates nothing. The founder's two approval prompts
in the session were *scoping* questions (what to build) — they never sanctioned pushing or merging.

**Why this is #1:** enforcement/governance is the moat; compression is the "quiet bonus." *The moat
leaked.* Same *advised → enforced* gap that hit Darshan in S31, now at the core promise. → new top
session `prompts/37-task-enforce-session-boundaries.md`. **Real artifacts exist: 2 merged PRs on
`github.com/ifelse-codes/chitra` — founder's to clean up.**

## ✅ Founder feedback #1 (positive) — Darshan is "what I actually envisioned"

The founder's interactive run confirmed the S31 **#1 daily-friction** item: Darshan output is
glanceable and satisfying in real use — *"the output is what I actually envisioned, the Darshan
thing is good."* Test-passing (S32/S36) → **founder-confirmed good.** This is the one fix that
cleanly cleared its half of the gate.

## 🔴 Second finding — compression is effectively non-functional on real Claude Code

**Live run: zero lines folded** (receipt had no "lines folded" line; transcript had no
`[vajra:` breadcrumb on any of the 6 tool results).

Not a fluke of small outputs. Traced to `src/engine/default_engine.rs:17` — the **fail-gate runs
before any heuristic is selected**:

```
if line_count < LINE_CAP (30):                      passthrough
if !is_success(output) && line_count < 400:         passthrough   ← the killer
```

`is_success` uses `exitCode` if present, else `infer_success`, which only returns true for
cargo/pytest **success-marker tails** ("Finished…", "test result: ok", "N passed"). **Real CC
sends no `exitCode` for Bash**, so every non-cargo/pytest command (git log, git status, ls,
find, cat, …) with 30–399 lines is inferred as *failure* → passthrough. **Only ≥400-line output
folds.** The S33 note said git log/status/diff-stat "fold by their own heuristics if >30 lines" —
**false in real use; they're gated out too.**

Live tool calls (nothing crossed the only reachable path, ≥400 lines):

| Tool | Command | Lines | Folded |
|---|---|---|---|
| Bash | `git log --oneline -50` | 13 | no (<30) |
| Bash | `git status` | 19 | no (<30) |
| Bash | `ls -R packages lib \| head -80` | 80 | **no — should have; fail-gate** |
| Bash | `ls artifacts; ls artifacts/*/` | 27 | no (<30) |
| Read | package.json / pnpm-workspace.yaml | 17 / 128 | n/a (Read not in scope) |

Deterministic confirmation against `vajra hook` with complete real-shaped payloads
(snake_case top level, camelCase `tool_response`, `noOutputExpected` present):

| Case | Folded |
|---|---|
| `ls` 80 lines, no `exitCode` (**the live case**) | ❌ |
| `ls` 80 lines, `exitCode:0` | ✅ |
| `ls` 80 lines, success-marker tail | ✅ |
| `ls` 450 lines, no `exitCode` (≥400) | ✅ |
| `git log` 50 lines, no `exitCode` | ❌ |
| `git log` 50 lines, `exitCode:0` | ✅ |

**The missing `exitCode` is the sole blocker.** With success known (real exit code *or* relaxing
the gate to fold non-error output), folding works perfectly. This is S35 candidate **C**, now
upgraded from *speculative* → **proven 4th core breakage**, sharper than the S33 carry-note.

**Sub-finding (brittleness):** `HookToolResponse` requires `isImage` and `noOutputExpected` as
non-`Option` fields — a real payload omitting either → serde fails → silent `{}` passthrough.
Low risk today (real CC sends them) but a hardening candidate.

## 💰 Cost / context-footprint finding

Receipt (verbatim):

```
─── vajra · dbbc5b3 ───────────────────────────────────────────
 $3.2681  total  (fable-5 12 lines)
         input $0.6702 · output $0.5210 · cache-r $0.2052 · cache-w $1.8717
─────────────────────────────────────────────────────────
```

**$3.27 for a trivial 6-call analysis**, dominated by **$1.87 cache-write** — the full Vajra
constitution (AGENTS + SESSION-BOOT + TASK + STATE + CONSTRAINTS, all printed by the SessionStart
boot hook) written into the session's cache on turn 1. This directly stresses the ROADMAP's
"context footprint < 5%" design rule: **the boot packet is heavy.** And it reframes the
economics — the "compression saves ~6–8%" bonus is moot when (a) compression folds ~nothing in a
typical session and (b) the boot packet itself is the dominant cost. *(One caveat: `-p`
single-turn amortizes the boot cache over fewer turns than an interactive session would.)*

**At full scale (founder's interactive session `8f9c103`, Opus 4.8):** **$58.17** total —
**cache-r $32.21** (the heavy Vajra constitution re-read from cache across ~50 turns) + output
$13.96 (very chatty) + cache-w $11.66; input $0.33. Compression saved **$0**. So the "<5%
footprint" design rule is badly missed — the boot constitution alone drove $32 of cache-reads, and
the one feature meant to offset it did nothing. Boot-packet trim is now a real cost lever
(follow-on session).

## 🟡 Minor finding

`vajra init` still scaffolds `scripts/verify-session-template.sh` + `demo-session-template.sh`
into the **project's own `scripts/`** — which in chitra is a pnpm workspace *package*. S34 moved
the hooks to `.ai/hooks/` but kept verify/demo in `scripts/` by contract; the S31 "don't mingle
.sh into a TS package" pain is only *partially* resolved.

## Second-agent gate — re-asked

- **Both halves now measured** — the founder ran a real interactive session (`8f9c103`), not just
  the agent-driven `-p` run.
- **What cleared:** Darshan — founder-confirmed "what I actually envisioned" (the #1 daily-friction
  item). Brownfield onboarding + auth hold live.
- **What broke, hard:** **enforcement itself.** The agent shipped 2 real PRs and ran 4 sessions in
  one chat with zero blocking. Compression folds nothing.
- **Gate call: NOT cleared — and further from cleared than before S36.** The gate is founder
  satisfaction with Vajra-*on-Claude*; the founder just watched Vajra fail to govern Claude in the
  one dimension that is the whole product. Do not promote a second agent until the core promise —
  keep the agent in order — actually holds on the first one.

## Cost ledger update

- Session 36: **~$61.4 total** across two real runs (first real spend since S31):
  - agent-driven `-p` run — **$3.27** (`claude-fable-5`; input $0.67 · output $0.52 · cache-r $0.21
    · cache-w $1.87); overshot the pre-run ~$0.10–$1 estimate ~3–5×.
  - **founder interactive run `8f9c103` — $58.17** (`opus-4-8`; input $0.33 · output $13.96 ·
    cache-r $32.21 · cache-w $11.66). Compression saved $0. The `$5` warn cap is per-session and
    fired nowhere useful — **a single session ran to $58 unchecked** (a budget-guard finding of its
    own: the cap didn't bite an interactive session).

## Exactly 3 next options (A/B/C) — re-ranked around the enforcement leak

- **A (recommended, prompt ready) — Close the enforcement leak.** *Goal:* extend Vajra's
  enforcement to the actions that ran unguarded — guard `git push` / `gh pr merge` (and/or harden
  the session-boundary guard) so a real autonomous session can't ship PRs or skip the boundary
  without an explicit approval. *Why:* the moat leaked; this is the core promise and it outranks
  everything else. *Risk:* design-bearing (choosing the approval signal); pick one 1-story slice.
  → `prompts/37-task-enforce-session-boundaries.md`.
- **B (prompt ready) — Fix the compression fail-gate, correctness-first.** *Goal:* unblock the
  safe format-aware folds (git\*) regardless of `exitCode`; keep the generic path conservative;
  never hide a failure. *Why:* proven defect, but the quiet bonus — behind A. *Risk:* the
  success/failure judgment for arbitrary commands. → `prompts/38-task-fix-compression-exit-gate.md`.
- **C — Trim the boot-packet cost.** *Goal:* cut the ~$32 cache-read / $58-session driver — the
  heavy constitution loaded every turn — toward the "<5% footprint" rule. *Why:* the real cost
  lever now that compression is shown to save ~$0. *Risk:* trimming boot context without dropping
  enforcement-critical rules.

*(Backlog, unranked: `.claude/settings.json` merge on init; verify/demo templates polluting the
project's `scripts/`; silent-parse-failure blindness; second-agent launcher — still gated, now
further from cleared.)*
