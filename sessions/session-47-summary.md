# Session 47 — The mid-run co-pilot murmur (direction B, first value session)

**Type:** CODE · **Branch:** `session-47-midrun-copilot` · **Cost:** ~$0 (local build/test only) · **Date:** 2026-07-06

## Goal
Wire the **proactive, non-blocking** half of the co-pilot: a `UserPromptSubmit` murmur that surfaces
the most relevant `copilot.on` context for the work in play — **exit 0, guide, never block** — the
half missing from today's PreToolUse-only blocker. First session of direction **B** ("your AI does
better work"), the return to the north star after the S37→S46 enforcement arc.

## Goal achieved? YES (mechanism) · NOT YET (proof it helps)
- **Shipped** `scripts/hook-copilot-murmur.sh` — reuses the loader's rule-parse + per-session debounce,
  **inverts the posture** to advisory (stdout, exit 0). It **never blocks** (verified: zero `exit 2` in
  source; advisory even at L3). Signal = working-tree changes (`git status --untracked-files=all`);
  `cmd:*` rules stay the loader's; missing `jq` / no match / can't-decide → **stays quiet**.
- **Scaffolded into `vajra init`** byte-identical via `include_str!` (S22 pattern) + wired on a new
  `UserPromptSubmit` block in `TPL_CLAUDE_SETTINGS` (a hook event the scaffold didn't use before);
  `Cargo.toml` un-excludes it so `cargo install` ships it.

## Evidence
- `verify-session-47.sh` **23/23 GREEN**: fmt · clippy · `cargo test` (**119 lib**, +2 new) · packaging ·
  E2E on a real `vajra init` (murmur present, executable, byte-identical, wired on `UserPromptSubmit`;
  loader + publish-guard + session-guard still wired).
- **Behaviour proven E2E:** a real scaffolded murmur fires `⚡on(prompts/*)` on matching work in play →
  surfaces `.ai/TASK.md` + `.ai/ROADMAP.md` at **exit 0**; advisory at L3; debounces (once/session);
  **stays quiet** when nothing matches.
- **Dogfooded live this session:** the loader (the murmur's blocking sibling) fired `⚡on(cmd:git commit)`
  and blocked my own commit until I reckoned with `.ai/STATE.md` — the co-pilot working on itself.
- Commits: `ea7e497` (hook + repo wiring, 2 files) · `027afcb` (scaffold + ship + verify, 3 files).

## Honest read (the founder-flagged risk)
**This is a helper built on faith, not yet a helper we can show helps.** I proved the murmur *fires
correctly* — right context, right moment, non-blocking. I did **not** prove it makes the AI produce
better work (fewer wrong turns, less re-work). There is no obedience/re-work metric yet. Building
guidance before measuring it is exactly the guard-era trap direction B warns against — so the honest
verdict is: **mechanism verified, value unmeasured.** Measuring it is the recommended next.

**Known limitation (accepted v0):** in a fresh *uncommitted* repo, `-uall` lists every untracked file,
so `prompts/*` murmurs on the scaffolded prompt files even if the agent isn't editing one. In any real
(committed) repo, `git status` shows only genuine changes, so this doesn't bite. Low harm (advisory,
debounced). Also: murmur ↔ loader use separate debounce namespaces by design — a murmured rule can
still be enforced later by the loader (independent layers).

## Next — pick one (A/B/C)

**A — The obedience metric [RECOMMENDED].** Measure obedience % = clean ÷ (clean + blocked/retried)
from the session trace, so we can finally tell whether the murmur (and the guard) actually help.
*Why:* directly answers this session's honest gap — turns "built on faith" into a number. *Risk:*
defining "clean vs retried" from the trace is fiddly; it measures obedience, not yet work-quality.

**B — Measure the value gap (real-task baseline, PAID).** Run one small real coding task through
`vajra claude` and through plain `claude`; diff correctness + corrections + cost → the concrete
"where the AI goes wrong" list = the murmur's content backlog. *Why:* grounds *what* to murmur in
real failure, not guesses. *Risk:* one paid run; picking a fair, small-enough task.

**C — Trace-mine missing `⚡on` advisories.** A look-only detector over past traces surfaces repeated
blocks → proposes new `copilot.on` rules the murmur would then carry. *Why:* grows the murmur's
coverage from real friction. *Risk:* headroom-style prose can drift from `.ai/` — must stay look-only.

> Next mandatory NO-CODE ground-truth = **S50** (every 5th; last = S45).
