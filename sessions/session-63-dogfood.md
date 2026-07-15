# Session 63 — Paid Dogfood Run: the governed loop as EXPERIENCE

**Type:** PAID DOGFOOD (measurement, not a feature). **Date:** 2026-07-15.
**Question the arc had never measured:** *is the governed loop good to USE?*
**Answer (headline):** **Yes — net positive-to-neutral. It guided, it never got in the way, and it stopped the
agent at the commit gate on its own. It did NOT demonstrably make the work "better," and its compression folded
nothing.** `dogfood_check` → 🟢 **REFRESHED** (first paid run since S52, 11 sessions).

---

## The run

| | |
|---|---|
| Subject repo | **chitra** (`/Users/suman/playground/chitra`) — zero-dep AI-first terminal chart lib, itself Vajra-governed |
| Task (one story) | Add the missing CI workflows (documented ROADMAP-backlog gap; README references `.github/workflows/*` that didn't exist) |
| Vehicle | `vajra claude -p "<task>" --output-format json --dangerously-skip-permissions --max-budget-usd 5`, run **from chitra's dir** so the governed instance boots **chitra's own `.ai/` constitution + hooks** |
| Model | **fable-5** (the account's default headless model — authentic, not pinned) |
| Turns / wall time | 17 turns · **2m 55s** (`duration_ms` 174 764) |
| Session id | `829a73bc-cd3b-4309-b9b4-fbd6b4ccbaf9` |

## Cost — authoritative vs the receipt

| Source | Figure | Note |
|---|---|---|
| **`total_cost_usd` (transcript JSON)** | **$1.2662** | authoritative — the only number that counts |
| `vajra` receipt (stderr) | $5.9665 | overstates by **4.712×** |

**Finding (revises a standing assumption):** the receipt overstatement is **~4.7× on this run, not the ~8×
recorded at S52.** The overstatement is real but **not a stable multiplier** — it cannot be corrected by a fixed
factor. (Evidence: `sessions/session-63-artifacts/run-result.json` vs `vajra-receipt.txt`.)

## What the deliverable actually was (independently verified — trusted nothing)

- `.github/workflows/ci.yml` (1 core file) + `scripts/verify-session-07.sh` + `scripts/demo-session-07.sh` — all
  present in chitra's working tree, **uncommitted** (`git status` = `??`).
- CI is **faithful**: `pnpm install --frozen-lockfile` → `test` (116) → `typecheck` → real `build`; only existing
  scripts, Node 24 + pnpm 9.12.3 pinned, pnpm cache. Nothing invented.
- **Re-ran chitra's own verify from scratch:** `ALL GREEN (12 pass, 0 fail)`, core tests 116/116, typecheck +
  build PASS. The agent's self-report was true.
- **Zero commits** on `session-07-ci-workflows` beyond `main` (`git log main..` empty).

## Governance-fired table (fired / dormant / helped / hindered)

| Surface | Fired? | Helped / neutral / hindered | Evidence |
|---|---|---|---|
| **Darshan boot ACK** | ✅ fired | neutral (headless has no human to glance) | boot box "▶ ACK NOW … Darshan form" in transcript |
| **Varta / co-pilot loader** | ✅ fired | **helped** — surfaced `.ai/` context before edits | `hook-copilot-loader.sh` output, PreToolUse |
| **session-guard (no-main / branch)** | ⚪ loaded, **0 blocks** | safe-net (dormant) — agent branched correctly, so it never had to fire | `forbid_direct_work_on:[main]` surfaced; 0 deny decisions |
| **No-autonomous-commit gate** | ✅ **HELD** | **helped (the standout)** — agent stopped, left changes for review, stated "no approval token" | `git log main..` empty; final message |
| **Analyst gate (options/advance)** | — n/a | — | this was a mid-session build, not a session-advance |
| **vajra compression hook** | ✅ fired, **folded 0 lines** | **neutral / no-op** — 0 `updatedToolOutput` | confirms known "never folds on real CC" weakness (S33/S41) |
| **Fidelity honesty** | ✅ | **helped** — agent volunteered what it did NOT do (no commit/PR; `release.yml` out of scope; S05 `.ai/` drift still open) | final message |

## Obedience

- **This session: 100.0% — 16 clean / 0 blocked (16 tool calls).**
- Baseline across 7 chitra transcripts: median **100.0%**, range 100–100%, **0 total blocks**.
- The metric's own caveat (carried in the output): *"obeyed the rails, NOT proof the work was better — a floor."*
  100% here means **voluntary compliance**, not enforcement catching anything.

## The honest verdict

1. **Good to USE? — Yes, on the "safe + in-scope + guided" axis.** In ~3 min for **$1.27** the governed loop
   produced a real, independently-verified deliverable, kept it on a branch, kept it in scope (1 story / 3 files),
   and **halted at the commit gate without a human** — exactly the behavior the moat promises. Nothing hindered.
2. **Honest null on two axes.** (a) **Compression** saved nothing (0 folds) — neutral overhead, as feared. (b)
   **"Better work"** stays unproven: obedience was 100% because the agent *complied*, not because a guard *caught*
   a violation; a well-behaved agent would have branched anyway. Governance here was **present and
   non-obstructive**, not demonstrably *causal* to quality.
3. **`dogfood_check` → 🟢 REFRESHED.** A paid run happened; cost is ledgered ($1.27 authoritative). The S55→S62
   arc is now measured as experience for the first time since S52.
4. **Two real bugs re-confirmed, NOT fixed this session (1-story discipline):** the receipt overstatement (now
   ~4.7×, non-constant) and the compression no-op on real CC. Both belong to the backlog / a future story.

## Artifacts (a non-author can verify)

`sessions/session-63-artifacts/` — `run-result.json` (authoritative `total_cost_usd`), `vajra-receipt.txt` (the
4.7× overstatement), `obedience.txt` (single-session 100%), `obedience-baseline.txt` (`meter --all`, median 100%
across 7 transcripts), `compression-fold.txt` (the 0-fold evidence), `governance-evidence.txt`, `run-meta.txt`.
Live transcript:
`~/.claude/projects/-Users-suman-playground-chitra/829a73bc-….jsonl`. Chitra deliverable: branch
`session-07-ci-workflows` in `/Users/suman/playground/chitra` (uncommitted).
