# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
None — between sessions (S36 complete, S37 not yet started).

## Active PRs
- S36 real-dogfood-run PR — open (docs-only: dogfood report + re-ranked prompts + `.ai/` sync).
- Merged: S34 brownfield [#29](https://github.com/ifelse-codes/vajra/pull/29) · S33 compression #27 · S32 Darshan #24 · S31 dogfood #23 · S35 GT closeout #30.

## Direction (set S18 … dogfood-measured S31, Darshan-enforced S32, compression-enforced S33, brownfield-guided S34, gate-reaudited S35, **dogfood-verified-live S36**)
- **Co-pilot, not cop** — guide the agent in real time; **Varta** = the agent's lane, **Darshan** = the human's lane.
- **S36 headline (founder's own interactive `vajra claude` run): the enforcement moat LEAKED.** At L3, in one chat, the agent shipped **2 real merged PRs** to `github.com/ifelse-codes/chitra`, ran ~4 sessions, committed to `main` — Vajra's hooks stopped **none** of it. Enforcement is the moat; this outranks the compression fix.
- **What DID hold live:** Darshan — **founder-confirmed "what I actually envisioned"** (the S31 #1 daily-friction item). Brownfield onboarding + auth (S34) hold live.
- **What is DEAD live:** compression — 0 folds across a 576-entry session (the `exitCode` fail-gate, proven).
- **Second agent stays parked — now FURTHER from cleared** than before S36: the founder watched Vajra fail to govern Claude in the one dimension that is the whole product.

## What Currently Works
- **Darshan (S32) — founder-confirmed good in real use (S36).** Boot directive surfaces every session and is obeyed; the interactive agent replied in glanceable tables/bullets. The S31 #1 complaint is cleared by the person who lives with it.
- **Brownfield onboarding + auth (S34) — hold live (S36).** `vajra init` on a real copy of `chitra` detected brownfield → session 00 brief; hooks in `.ai/hooks/`; `.gitignore` idempotent-skipped; auth pre-check passed and the nested spawn authenticated (no S31 401).
- `vajra claude` · `vajra next` · `vajra check` · `vajra init` · `vajra estimate` · `vajra meter`. `cargo test` 133 pass, clippy clean — unchanged this session (no `src/` edits).

## What Is Broken
- **🔴 Enforcement leak (S36 headline, NEW).** Vajra enforces none of its hard rules in a real autonomous (L3) session. Root cause (4 structural gaps): (1) `hook-session-guard.sh` arms only on `git checkout -b session-(N+1)` from an owning chat — brownfield never branches 00, so the tripwire never arms; (2) **no hook watches `git push` / `gh pr create` / `gh pr merge`**; (3) `vajra init` scaffolds `.claude/` hooks but not git-level `pre-push`/`pre-commit`; (4) L3 gates nothing. **S37-ranked #1** (`prompts/37-task-enforce-session-boundaries.md`).
- **🔴 Compression dead in real use (S36, sharper than the S33 carry-note).** `default_engine.rs:17` fail-gate drops all 30–399-line output unless `is_success`; real CC sends no `exitCode` and `infer_success` only matches cargo/pytest tails → git log/status AND generic output all pass through; only ≥400-line output folds. Fix must be **correctness-first** (never gamble). **S38-ranked** (`prompts/38-task-fix-compression-exit-gate.md`).
- **🟡 Budget cap didn't bite (S36).** A single interactive session ran to **$58** under a `$5` warn-mode cap (checked only after exit; warn never kills). Cost is dominated by boot-packet cache-read (~$32) — the "<5% footprint" rule.
- **🟡 Silent-parse-failure blindness / verify+demo templates in the project's `scripts/` / `.claude/settings.json` merge on init (S34)** — backlog.
- **Co-pilot v0 limits** — simple-glob + `cmd:` substring (false-positive-prone; blocked this closeout's own tooling once).
- Second agent launcher stays parked (gate unmet).

## What Is In Progress
- **S36 DONE + closed.** Report: `sessions/session-36-summary.md`. Ran the real `vajra claude` loop against `/private/tmp/chitra` (both an agent `-p` run and the founder's interactive run). **Next (S37)** = founder pick, re-ranked around the enforcement leak: **A (recommended)** enforcement (`prompts/37`), **B** compression (`prompts/38`), **C** boot-cost trim — in a **new chat**.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative (S07 the only prior spend).
- Session 31: first real `vajra claude` dogfood since S07 (chitra; exact $ not captured).
- Session 32–35: ~$0.00 (code + GT docs sessions).
- **Session 36: ~$61.4** — two real runs against `/private/tmp/chitra`: agent `-p` run **$3.27** (`fable-5`) + founder interactive run **$58.17** (`opus-4-8`; cache-r $32.21 · output $13.96 · cache-w $11.66 · input $0.33). Compression saved **$0**.
- Cumulative: ~$62.
