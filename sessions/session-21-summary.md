# Session 21 — The Co-Pilot Loader (CODE)

## Goal
Make `⚡on(x) ⚡include "files"` actually **fire** mid-session — the first *enforcing* use of Varta — and answer the gate: **does Varta enforce, or merely advise?**

## Goal achieved? YES

`⚡on` now fires via a PreToolUse hook the moment the agent touches matching work, and it **enforces** at L2/L3. Proven in a real session (not just tests).

## What shipped

| Deliverable | Where |
|---|---|
| `⚡on` rules as live config (no hand-copy → no drift) | `.ai/CONSTRAINTS.yaml#copilot.on` (3 rules) |
| The loader — PreToolUse(Edit\|Write\|Bash), debounced, maturity-gated | `scripts/hook-copilot-loader.sh` |
| Wiring into both PreToolUse matchers | `.claude/settings.json` |
| 10-check verify + terminal demo | `scripts/verify-session-21.sh`, `scripts/demo-session-21.sh` |

**Design choices (approved):** rules live in CONSTRAINTS.yaml (not a new `.varta` — honors S19); bash hook (not a Rust matcher — there is no `serde_yaml`/`glob` dep, and all hooks are bash). The S20 "matcher near `src/adapter/`" sketch was set aside on that evidence.

## Decision gate — ANSWERED: Varta ENFORCES (on-wedge)

| Maturity | Behavior | Mechanism |
|---|---|---|
| L1 | advise | print load to stdout, exit 0 (agent may ignore) |
| L2 / L3 | **enforce** | print to stderr, **exit 2 — tool blocked** until the agent reckons with the load |

This is the same exit-2 block every other Vajra hook uses. A spoken-only language enforces nothing; this loader makes `⚡on` a **gate**, not a suggestion → Varta stays on the enforcement wedge and is **not** demoted below first-run "aha".

## Evidence

- `scripts/verify-session-21.sh` → **ALL GREEN (10/10)**: fire on path match, fire on `cmd:` match, silence on non-match, per-session debounce, the L1-advise/L2-enforce gate, anti-rot (every `⚡include` target exists).
- **Live proof (real session):** the `cmd:git commit` rule **fired and blocked a real `git commit`** mid-session — surfaced `.ai/STATE.md` before the commit. Not a simulation.
- `cargo test` green / unaffected (no Rust changed).
- PR: https://github.com/ifelse-codes/vajra/pull/11

## Known limits (honest)

- v0 matching is simple glob (`*` spans `/`) + `cmd:` substring; no `**`/regex yet.
- Debounce keys on `session_id`; if CC omits it, the fallback dir is shared (minor).
- Loader surfaces include **paths + why**, not file contents — the agent still opens them.
- Wired into this repo's committed `.claude/settings.json` (dogfood). The launcher's `--settings` injection only adds the PostToolUse compression hook today; injecting the co-pilot for *other* projects is future work (overlaps the deferred rider).

## Deferred (rider → its own session)
Scaffold propagation: `src/cli/init.rs`'s `TPL_CONSTRAINTS` has **no `ground_truth:` section at all** — scaffolded projects inherit neither the S20 GT hardening nor the S21 co-pilot. Split out to respect the 1-story / ~2h cap.

## Next — pick one (A/B/C)

### A. Scaffold propagation (the deferred rider)
- **Goal:** make `vajra init` emit the S20 GT audits *and* the S21 co-pilot loader, so every Vajra project inherits the hardening.
- **Why pick this:** the hardening currently lives only in *this* repo; small, well-scoped, high-leverage; finishes what S20/S21 started.
- **Key risk:** low — embedded-template edits + init.rs tests; mostly mechanical.

### B. First-run "aha" (ROADMAP item 9 — last Phase-2 item)
- **Goal:** `vajra init` → first session delivers a felt win in 2 minutes (e.g. a seeded `⚡on` rule that fires on the user's first edit).
- **Why pick this:** fixes the S18 "not worth it" first-run feeling; newly compelling now that the co-pilot is a *felt* moment, not files.
- **Key risk:** UX polish; "aha" is subjective and easy to under-deliver.

### C. Co-pilot v1 — richer firing
- **Goal:** surface file *digests* (not just paths), broader conditions, and validate the rule set over real sessions.
- **Why pick this:** deepens the wedge we just proved — "here's the context," not "go load it."
- **Key risk:** context-footprint (<5% rule) + scope creep into a condition language.

**Recommendation:** A — it propagates both S20 and S21 to every project and is the smallest high-leverage step.
