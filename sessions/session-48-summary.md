# Session 48 — The obedience metric (direction B, founder pick A, CODE) — COMPLETE

> **Founder pick at S47 close (A):** measure before building more co-pilot. S47 shipped the mid-run
> murmur but left an honest gap — *mechanism verified, value unmeasured.* S48 builds the number.

## Goal — ACHIEVED
Compute and surface an **obedience metric** for a Vajra session:
`obedience % = clean ÷ (clean + blocked)`, mined **read-only** from the session trace and printed on
`vajra meter`. Instrumentation only — no guidance, no blocking, no new dependency, no 8th command.

## The signal design call (the one real decision)
| Candidate | Verdict |
|---|---|
| **Session JSONL alone** ✅ | **Picked.** A Vajra rail block already surfaces in the trace as `tool_result{is_error:true, "PreToolUse:<Tool> hook error … [vajra …]"}`. Detect from the JSONL — no hook change, and it runs on **past** sessions (the S49 baseline comes free). |
| Durable exit-2 append in the hooks | Rejected: touches 5 hook files, adds behavior, and **cannot measure past sessions** (no logs exist yet). |
| Debounce markers | Rejected: show *what fired*, not *whether behaviour changed*. |

**Definitions:** `blocked` = distinct tool-call attempts whose result is a Vajra hook block · `clean` =
total tool_use − blocked · a retry after a block = a fresh clean attempt (so a block+retry = 1 blocked +
1 clean). A plain command failure (`is_error` with **no** hook signature) is **not** a block.

## What it PROVES / does NOT prove (the honesty bar)
- ✅ Proves: how often the agent proceeded cleanly vs got stopped by a rail and had to re-do — a real,
  cheap, before/after number every future co-pilot change can be judged against. Closes the S30/S31
  "no metric measures usage" gap.
- ❌ Does **not** prove the *work was better*. Obedience to the rails is a **proxy** — the first rung of
  the obedience ladder, not work-quality (a later, harder measurement).
- **Named blind spot:** it counts only **hook-attributed** blocks (coupled to CC's `hook error` wording
  + Vajra's `[vajra …]` marker). A rule silently worked around, or rework with no hook fire, is invisible
  → the number is a **floor** on friction, not a ceiling.

## Evidence
- **Live on two real transcripts** (traceable to source):
  - a real vajra session (`27034d0…`): **98.9%** · 92 clean / 1 blocked (93 tool calls) → `hook-copilot-loader.sh`.
  - the S46 isolation run (`82791e0…`): **0.0%** · 0 clean / 1 blocked → `hook-publish-guard.sh` — the
    S46 moat-fire, now a number.
  - Observed baseline across 5 recent sessions: **96–100%** (blocks are rare in a governed chat).
- `verify-session-48.sh` **20/20 green** (replayed known-count transcript → 66.7% · 2 clean / 1 blocked ·
  source `hook-publish-guard.sh` · honesty caveat · deterministic; + instrumentation-only invariants).
- `cargo test` **124 lib** (+5) + adapter/integration; clippy + fmt clean.
- **Dogfood:** the co-pilot loader blocked this session's own `git commit` (exit 2) — the very signal the
  metric counts.
- Commits `6f8c8be` (metric: `src/obedience/mod.rs` + `src/lib.rs` + `src/cli/meter.rs`) + `dd8066c`
  (verify). ~$0 (local build/test).

## Self-review
What breaks: CC changing its `hook error` wording (documented blind spot; needs both markers) · large
transcripts read whole (meter already does). Hidden assumptions: every Vajra hook emits `[vajra …]` —
verified against real copilot-loader + publish-guard blocks. Read-only, scope intact (measure, don't
guide), no new dep/command.

## Next — pick one (A/B/C, drawn from ROADMAP)
- **A — Baseline read (recommended).** *Goal:* run the metric across several past sessions so the number
  has context ("what's a good obedience %?"). *Why:* the metric exists but has no yardstick; cheap ($0,
  past traces), turns one number into a trend. *Risk:* purely descriptive — doesn't yet drive a change.
- **B — Measure the value gap (real-task baseline, PAID).** *Goal:* one small real task through
  `vajra claude` vs plain `claude`; diff correctness + corrections + cost. *Why:* this is the
  work-quality question the obedience metric explicitly does **not** answer — the real direction-B proof.
  *Risk:* one paid run; designing a fair small task.
- **C — Trace-mine missing `⚡on` advisories.** *Goal:* a look-only detector over past traces proposes
  new `copilot.on` rules the murmur carries. *Why:* reuses the trace-mining muscle just built; feeds the
  co-pilot's content backlog. *Risk:* headroom-style prose can drift from `.ai/` — must stay look-only.

> Next mandatory NO-CODE ground-truth = **S50** (every 5th; last = S45). S49 is a code session.
