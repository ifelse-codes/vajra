# Session 51 Summary — Measure the value gap (real-task A/B on chitra, PAID)

**Direction B · CODE/VERIFY · PAID** · Branch: `session-51-value-gap` (Vajra) · Date: 2026-07-08
**Founder pick at S50 GT:** A — take the first real reading of *"does the AI do BETTER WORK through Vajra?"*
**Founder call at S51 kickoff:** finish chitra's mid-flight S03 first, then run chitra's own S04 as the A/B.

---

## TL;DR (honest, n=1)

> **Vajra did NOT measurably improve work-quality on this task, and cost ~19% MORE.**
> Both arms were **equally correct** on the core API (themes, exports, methods, `toJSON` shape).
> The Vajra arm was **marginally worse** on peripheral correctness — it faithfully mirrored chitra's own
> *broken* `CONTRIBUTING.md` (wrong clone URL + a `node file.ts` run command that can't execute TS) — and
> **marginally better** on task structure (an explicit ordered new-user path). Net at n=1: **no work-quality
> win for Vajra; a mild negative on cost.** This is a real, useful, humbling signal — not a proof either way.
> The direction-B thesis remains **UNPROVEN**; the first reading leans null-to-slightly-negative *on a simple,
> well-specified one-shot task with a strong base model.*

---

## Setup (what made the A/B fair)

- **Subject:** `/Users/suman/playground/chitra` — real pnpm monorepo, `@chitra/core` terminal chart lib, already Vajra-wired.
- **Precondition fixed:** chitra was dirty, mid-S03-closeout. Finished + committed S03 (3 commits) and merged to chitra `main` → clean, canonical S04 start point. *(chitra advanced for real, duty #1.)*
- **Task (identical, self-contained prompt to both arms):** sharpen `packages/core/README.md` so a new user can, in order, install → render first chart → find runnable examples → understand AI-agent output; every example must use only real exports/themes; edit ONLY the README. (`sessions/session-51-artifacts/task-prompt.txt`.)
- **Arm A — through Vajra:** `vajra claude -p` on chitra's real `session-04-readme-getting-started` branch (full `.ai/` governance + boot packet + Darshan + co-pilot + compression). **Kept.**
- **Arm B — plain control:** `claude -p` in a **throwaway worktree with the Vajra layer stripped** (`.ai/`, `.claude/`, `CLAUDE.md`, `varta/`, `darshan/`, `.githooks/` removed) → same code, no governance. **Discarded.**
- **Held constant (both arms):** same prompt, same tool whitelist (`Read Edit Write Glob Grep` — no Bash, symmetric + safe), same `--max-turns 40`, same cost capture (`--output-format json`, authoritative `total_cost_usd`).
- **Isolation caveat:** the difference measured is *Vajra-governance present (A) vs absent (B)* on the same base model — but `CONTRIBUTING.md` existed in **both** worktrees, so both *could* read it. The correctness divergence below is the agents' *choices*, plausibly nudged by Vajra's "respect repo conventions" posture — but at n=1 that is indistinguishable from sampling variance.

---

## The rubric (declared BEFORE running)

1. **Correctness** — do the outputs actually work? (valid themes, real exports/methods, correct `toJSON` shape, referenced files exist, example run command executes, scope discipline)
2. **Corrections** — how many fixes to make the output shippable?
3. **Cost** — $ per arm (authoritative `total_cost_usd`).

---

## Raw results

| Metric | Arm A — `vajra claude` | Arm B — plain `claude` |
|---|---|---|
| Cost (authoritative) | **$0.8127** | **$0.6813** |
| Turns / wall | 24 / 160s | 16 / 131s |
| Files touched | README only ✅ | README only ✅ |
| README change | +43 / −17 | +51 / −(strip noise) |
| Themes valid (no phantom) | ✅ | ✅ |
| Exports real | ✅ | ✅ |
| Methods real (`toPlain/toMarkdown/toJSON`) | ✅ | ✅ |
| `toJSON` shape `{type,data,labels,title,plain}` | ✅ | ✅ |
| Referenced files exist | ✅ `basic.ts` | ✅ `basic.ts` + `demo.ts` |
| **Example run command works** | ❌ `node …basic.ts` (node can't run TS; exit 1) | ✅ `npx tsx …` (conventional runner) |
| **Clone URL** | ❌ `chitra-dev/chitra` (real: `ifelse-codes/chitra`) | n/a (assumed in-repo) |
| Ordered 4-step journey (task requirement) | ✅ explicit nav path w/ anchors | ⚠️ implicit ordering, no nav path |
| **Corrections to ship** | **~1–2** (fix run cmd + clone URL) | **~1** (add ordered path / `npx tsx` fine as-is) |

Objectively verified against chitra source: 7 real themes, real exports, real methods, real `toJSON` shape, both example files exist, and the working runner is `tsx` (`packages/core/node_modules/.bin/tsx examples/basic.ts` → exit 0, 514 lines). Arm A's `node --experimental-specifier-resolution=node examples/basic.ts` → **exit 1**.

## The interesting finding (both directions)

- **Vajra arm inherited a latent repo bug.** Arm A read chitra's `CONTRIBUTING.md` and copied its clone URL + run command **verbatim** — both of which are wrong. Vajra's convention-respecting posture is double-edged: good for consistency, bad when the repo's own artifacts are buggy.
- **Plain arm reasoned independently to the correct tool** (`tsx`) and referenced an extra real file (`demo.ts`), but skipped the explicit ordered nav path the task asked for.
- **Neither dominates.** Equal on the core API; each made exactly one different peripheral slip.

---

## Verdict

- **Did Vajra measurably improve correctness?** No (n=1). Both arms equal on core correctness; Vajra marginally worse on the peripheral (mirrored broken docs).
- **Did Vajra reduce corrections?** No (n=1). Roughly a wash (~1 each).
- **Was Vajra cheaper?** No — Arm A cost **~19% more** ($0.81 vs $0.68); more ambient context = more tokens. ("Cheaper via less re-work" was always a *multi-session* claim, not a one-shot; this doesn't refute it, but it doesn't support it either.)
- **Honest read:** on a simple, well-specified, one-shot task with a strong base model, **Vajra's context layer added cost without measurably better output.** Any value likely lives in **harder, convention-heavy, multi-turn / multi-session** work where captured context prevents drift and re-work — exactly what a README one-shot cannot show. **The measurement, not the product, was too easy.** n=1 is a start, not a proof.

---

## `dogfood_check` refresh (was 🟡 aging since S46)

- **First paid `vajra claude` run since S46 executed live today** → `dogfood_check` back to **🟢 measured** (fresh).
- **Enforcement fired live during S51:** Vajra's co-pilot loader blocked this orchestration's own `git commit` at **exit 2** (required surfacing `.ai/STATE.md` before retry). The launcher + compression + receipt path all ran live in Arm A.
- **🔴 NEW dogfood finding — the "honest receipt" is inaccurate.** Vajra's own receipt reported **$7.3691** for Arm A while Claude's authoritative `total_cost_usd` was **$0.8127** — a **~9× overstatement** (dominated by cache-r $1.78 + cache-w $3.31; likely a cache-pricing miscalibration in the compiled-in rates). The metering claim ("shows receipts, honestly") is currently **wrong by ~9×** on a real run. High-value bug. → S52 candidate C.
- **Environment note:** nested `claude`/`vajra claude` inference was org-blocked (subscription disabled for the CLI) until the founder enabled API-key billing mid-session; the two arms then ran on API credits.

## Cost ledger (S51)

| Item | $ (authoritative) |
|---|---|
| Arm A (`vajra claude`) | 0.8127 |
| Arm B (plain `claude`) | 0.6813 |
| Access probe | 0.0265 |
| Failed first Arm A (org-blocked) | 0.0000 |
| **S51 total** | **~$1.52** |

Cumulative repo spend: ~$65.8 → **~$67.3**. Under the $5.00 warn cap for the session.

---

## What landed (duties)

1. **Value-gap number:** first real work-quality reading — *no measurable Vajra win at n=1* (above).
2. **Live moat refresh:** `dogfood_check` 🟢 again; enforcement fired live; **+1 real metering bug found.**
3. **chitra advanced for real:** S03 finished + merged to chitra `main`; **S04 README committed** on chitra's `session-04-readme-getting-started` (`def0cfa`) — with Arm A's output, the 1 correction folded in. Not left dangling.

Artifacts: `sessions/session-51-artifacts/` (both READMEs, both diffs, both metrics JSONs, the shared prompt).

---

## Exactly 3 candidates for S52 (ranked, from ROADMAP)

**A — Value gap on a HARDER task (n=2, the honest follow-up).** *Goal:* re-run the A/B on a real *multi-step, convention-heavy* chitra task (e.g. the backlog `dist/` publishable build, or CI workflows) where captured context could plausibly prevent drift/re-work. *Why pick:* S51's null result is likely because a README one-shot is too easy to separate the arms; the thesis deserves a fair test on a task where Vajra *should* help. *Key risk:* harder tasks are noisier and pricier; still n=1→2, not a proof; must pre-declare a rubric that can actually distinguish the arms.

**B — Turn the A/B into a repeatable harness (`vajra` bench).** *Goal:* codify the S51 setup (paired arms, stripped control, rubric probes, authoritative cost capture) into a small repeatable script so value-gap runs are one command, not hand-built. *Why pick:* makes every future reading cheap + comparable → the only way n grows past 1; on-wedge (honest metering). *Key risk:* building measurement infra instead of measuring; scope creep toward a framework; must stay a thin script (max-7-commands cap — no 8th command).

**C — Fix the receipt (the ~9× cost overstatement found today).** *Goal:* correct the meter's cache pricing so the receipt matches Claude's authoritative `total_cost_usd`; regression-test against this session's real payload. *Why pick:* "honest receipts" is a core Vajra claim and it is currently wrong by ~9× on a real run — a live-verified bug, exactly the class dogfood exists to catch. *Key risk:* pricing is a moving target (model rates change); the fix must be a calibration + test, not a hard-coded constant that re-drifts.
