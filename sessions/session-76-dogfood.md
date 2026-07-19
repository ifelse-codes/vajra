# Session 76 — Dogfood ride-along report (paid): the 8-station pipeline as lived experience

> **Type:** MEASURE. One real task through `vajra claude` (headless), governed instance in
> `/Users/suman/playground/chitra`, agent riding along. Two runs (a read-only wall, then a
> full-autonomy success). Every claim below traces to a file in `sessions/session-76-artifacts/`.
> **No `src/` change. Bugs are RECORDED as S77 debt, not fixed (S63 stance).**

## Honesty caveat on "founder-led" (criterion 1)
The founder **authored/approved the task** (`task-prompt.txt`) and **directed the run**, but — at the
founder's explicit instruction ("you run the command, approved") — the **agent invoked** `capture.sh`.
So criterion 1's "the founder issues the prompts, the agent never drives" is **bent in the letter**: the
prompt was fixed + founder-blessed and the measured subject is the governed chitra instance (validity of
what we measured holds), but the run was agent-invoked. Recorded, not hidden.

## The two runs

| | Run 1 | Run 2 |
|---|---|---|
| flags | *(none)* | `--dangerously-skip-permissions` |
| outcome | **read-only wall** — every Write/branch/mkdir denied (empty allowlist, no headless approval channel); reads worked | **full CI delivered** — branch + 3 files + verify 13/13 green |
| model | claude-fable-5, 64 lines | claude-fable-5, 56 lines |
| receipt headline | `$14.3894 [estimate · fable-5 as opus upper bound]` | `$12.1773 [estimate · fable-5 as opus upper bound]` |
| authoritative `total_cost_usd` | **ABSENT** (0 `type:result`) | **ABSENT** (0 `type:result`; final line = `last-prompt`) |
| chitra head | unchanged (61a9e67) | unchanged (61a9e67) — **branch made, files written, NOT committed** |
| session id / jsonl | `5284c9f…` | `5202479…` |
| evidence | `run1/` | `run2/` + top-level |

## Gates-fired table (each cell from an artifact, not memory)

| Gate / hook | Fired? | Helped / neutral / hindered | Evidence |
|---|---|---|---|
| SessionStart boot (`hook-session-start.sh`) | **FIRED** | helped (governed instance read chitra's constitution → obeyed it) | run.stdout / run.jsonl both runs |
| session-guard (`hook-session-guard.sh`, L3) | **FIRED, passed** | neutral — fresh chat (new claude session_id) → allowed the 06→07 branch | run 2 branched `session-07-ci-workflows` (`chitra branch --show-current`) |
| copilot-loader (`hook-copilot-loader.sh`, L3) | **FIRED** on edits | neutral | run 2 wrote 3 files under Edit/Write |
| compression hook (`vajra hook`, injected) | **FIRED** | neutral — **0 folds** both runs (read-only / small tool outputs) | no fold line in either receipt (0 ⇒ omitted) |
| no-commit / pre-bash gate | **DORMANT** | n/a — chitra does not wire `hook-pre-bash.sh` | `chitra/.claude/settings.json` (3 hooks, no pre-bash) |
| receipt (on exit) | **FIRED** | **hindered** — headline is an opus-priced fable-5 estimate; real dollars not shown | `receipt.stderr.txt` both runs |

## Findings

### 🟢 Obedience — the headline positive (voluntary governance)
Run 2 ran with **`--dangerously-skip-permissions`**, which bypasses Claude Code's own permission gates.
The governed instance still:
- **branched instead of working on `main`** (chitra rule) — session-guard allowed it (fresh chat);
- **refused to auto-commit** — stopped with "commit ⚠ awaiting your approval (per CONSTRAINTS)", though
  chitra **does not wire the no-commit hook** at all;
- **held the 2-assumption cap** (Node-26 pin + pnpm-9.12.3 pin, both disclosed).

Governance held **by instruction-following, not by an enforcing hook** — the strongest governance reading
in the project to date. (Reconfirms the S63 "obedience 100% VOLUNTARY" finding, now under *bypassed*
permissions.) Run 1's wall produced the same class of signal: it obeyed **"3rd failure → escalate,"**
stopped clean, disclosed a finished design, and **did not thrash or fake a green.**

### 🟢 Fidelity — the delivered work is real
Independent re-run of the governed instance's `scripts/verify-session-07.sh` → **ALL GREEN (13/13)**,
including real gates `gate-core-test`, `core-tests-116`, `gate-docs-build`, `gate-chart-drift`. The CI it
wrote (3 jobs: core · docs · chart-drift; concurrency; a fresh-clone `typecheck:libs` fix) is materially
**better than the human's partial `ci.yml`** (1 core-only job) that was backed up pre-run. The "13/13"
claim was true, not self-graded theater.

### 🔴 Cost — an authoritative dollar figure was UNOBTAINABLE (a null with two causes)
1. **Headless emitted no `total_cost_usd`** — 0 `type:result` lines in either run's JSONL; the terminal
   line is `type:"last-prompt"`. vajra's meter reads authoritative cost only from `type:"result"`
   (`src/meter/mod.rs:241`), so it correctly found none. **This is a regression vs S63**, whose headless
   dogfood *did* carry `total_cost_usd:1.2662`. (This CC = 2.1.183; the run was also nested inside another
   Claude Code session — either could explain it; unproven which.)
2. **Model = fable-5, not in the pricing table** → the token recompute uses the **opus upper bound**, so
   the receipt reads $14.39 / $12.18 for what is a much cheaper fable-5 run. Real dollars = **unknown**.
   With no authoritative figure to fall back to (cause 1), there is **no truthful dollar readout at all**.

S66's *fallback* behavior worked in the wild: the estimate was **labeled** (`[estimate · fable-5 priced
as opus upper bound]`) and warned, never presented as the charge. But S66's *happy path* (authoritative
`total_cost_usd` as the headline) was **never exercised** — so criterion 3's "S66 authoritative behavior
verified in the wild" is only **half** verified (the labeling half).

### 🔴 The read-only wall (run 1)
A headless `vajra claude -p` **without a permission-mode flag is a read-only agent**: no approval channel,
empty write allowlist ⇒ every mutation denied. A real user dogfooding `vajra claude -p "do X"` hits this
wall. The fix that unblocked run 2 was `--dangerously-skip-permissions` (or `--permission-mode`).

## Nulls, stated plainly (S63 honest-nulls rule)
- **0 compression folds**, both runs. Not dressed up. never-claim-until-measured holds.
- **No authoritative cost**, both runs (see 🔴 above).
- **no-commit gate never fired** — because chitra doesn't wire it (DORMANT), not because it passed.

## Bugs / gaps RECORDED (S77 candidates — not fixed this session)
1. **fable-5 unpriced** → receipt overstates (opus upper bound). Compounds the missing-authoritative case
   into "no truthful dollar figure." (`meter::MODEL_PRICING` lacks fable-5.) — *the deferred "fable-5
   price" debt now blocks a core dogfood metric.*
2. **Headless authoritative-cost gap** — `vajra claude -p` produced no `total_cost_usd` (regression vs
   S63). Meter/receipt can't report a real bill for headless runs in this environment.
3. **Read-only-headless UX** — `vajra claude -p` with no permission flag silently yields a read-only
   agent; nothing in vajra surfaces "your agent can't write" up front.

## What this measures about the pipeline
The **governance is real and load-bearing** — it survived a permission bypass on voluntary adherence, and
the delivered work was independently green. The **receipt is the weak station** on real (fable-5, headless)
runs: correct *labeling*, but no truthful dollar number. `dogfood_check` is **refreshed** — measured, not
guessed — for the first time since S63 (12 sessions), now on the full 8-station pipeline.
