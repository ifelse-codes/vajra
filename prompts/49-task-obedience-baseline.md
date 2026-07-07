# Session 49 — Obedience baseline: give the number a yardstick (direction B, founder pick A)

> **Founder pick at S48 close (A):** S48 built `obedience %` but it has no context — one number, no
> band. This session runs the metric across several past sessions so "98.9%" *means* something: a
> trend, a "good" range, and the outliers worth a look. Descriptive, $0, uses the S48 code on existing
> transcripts.

## Why this session (the S48 gap, one paragraph)
The obedience metric exists and is honest, but a single reading has no yardstick — is 98.9% good, or is
100% the norm and 98.9% already a smell? S48 spot-checked 96–100% across 5 recent traces; S49 makes that
rigorous: compute obedience across the vajra project's past sessions, present the distribution, and name
what "good" looks like. This closes the other half of the S30/S31 "no metric measures usage" gap — S48
gave the metric, S49 gives it context — and it's the cheapest possible next (no paid run, no new code
surface beyond a batch/report over the S48 module).

## Goal (single story)
Produce an **obedience baseline** for Vajra: run the S48 metric over the available past session
transcripts, and surface a small ranked table — per session: tool calls, clean, blocked, obedience %,
top blocking hook — plus the aggregate (median / range) and the honest read. Reporting only; **no new
guidance, no blocking.**

## Recommended slice (founder splits at BOOT if needed — `max_stories: 1`)
- **PRIMARY — the baseline read:** enumerate the transcripts under
  `~/.claude/projects/<slug>/*.jsonl` (the meter's existing discovery lane), call the S48
  `obedience_for` per file, sort, and print the table + aggregate. **No 8th command** — ride the receipt
  lane (`vajra meter`, e.g. a directory/`--all` argument) or `vajra check`, whichever fits cleanest.
  State the design call + its blind spot (the S47/S48 honesty bar).
- **PAIRED FOLLOW-ON (document, likely later):** a committed baseline artifact
  (`sessions/session-49-baseline.md` or similar) the founder can diff future sessions against.

## Method
1. **Reuse, don't rebuild.** The S48 `src/obedience/mod.rs` already computes a session's metric read-only;
   S49 is a *batch + present* layer over it. No new parsing, no new dependency (the S21 rule).
2. **Pick the surface first (the design call).** Keep it in the reporting lane and honor max-7-commands:
   a directory/`--all` mode on `vajra meter`, or a `vajra check`-side report. State the choice.
3. **Keep it honest about what it proves.** A baseline is **descriptive, not causal** — it says what
   obedience *has been*, not that Vajra *caused* it. Blocks are rare in a governed chat, so numbers
   cluster high and the sample is small (name the n). Obedience is still obedience-to-rails, not
   work-quality (the S48 floor caveat carries).

## What counts as done (success criteria)
- Running the baseline prints a per-session table + an aggregate (median + range) with counts traceable
  to their source transcripts.
- `verify-session-49.sh` green; `cargo test` unchanged/green (any new code unit-tested); clippy + fmt clean.
- **Honest check:** state plainly that the baseline is descriptive (not causal), name the sample size,
  and carry the S48 floor caveat (obedience ≠ work-quality).

## Guardrails
- Branch `session-49-<slug>` off `main` (**new chat**). Max 1 story, ≤3 files/commit, max 2 assumptions, ~2h.
- Report, do not guide — this session adds no new advisory/blocking behaviour.
- No 8th top-level command. No new dependency. Skill-not-renderer holds.
- Self-review before ship: what can break · hidden assumptions · production-ready · repro-evidence only ·
  scope intact.

## Output
- `sessions/session-49-summary.md`: goal achieved? evidence (the baseline table on real transcripts); the
  honest "descriptive not causal + sample size + floor" read; exactly 3 next options A/B/C.
- Update ROADMAP (baseline item → done) + STATE + KNOWLEDGE.

> Next mandatory NO-CODE ground-truth = **S50** (every 5th; last = S45) — the session after this one.
