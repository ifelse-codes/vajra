# Session 21 — The Co-Pilot Loader (CODE)

## Goal
Make `⚡on(x) ⚡include "files"` actually *fire* mid-session: Vajra surfaces the right context the moment the agent touches matching work — the first **enforcing** (not advisory) use of Varta.

## Why now
S20 ground-truth flagged a live risk: a language the agent merely *speaks* enforces nothing — that is the prompt-library shape Vajra vowed to beat *on enforcement*. This session is the make-or-break test of whether Varta earns its place (memory `vajra-varta-wedge-risk`).

## Scope (1 story)
- A **CC hook** is the only reactive fire point (it sees what the agent touches). S20 sketch: a new hook script in `scripts/` + matcher logic near `src/adapter/`, wired via `.claude/settings.json`, reusing the proven additive `--settings` injection.
- Define a minimal `⚡on(cond)` condition form (e.g. path glob / tool match) + a debounce so nudges don't spam.
- Prove it in a real session: touch a matching file → the `⚡include` context is surfaced/loaded.

## Decision gate (must answer in the summary)
**Does Varta enforce, or merely advise?** If the loader cannot make `⚡on` enforce context-loading, record that Varta is off-wedge and demote it below first-run "aha" (ROADMAP item 9).

## Rider (same session if ~2h cap allows; else split to its own session)
- **Scaffold propagation:** update `src/cli/init.rs` so `vajra init` emits the new GT audits (`vision_alignment`, `roadmap_alignment`, `constitution_review` + question-lists) and the two-drift-class `AGENTS.md` checklist — so every Vajra project inherits the S20 hardening. Update init.rs tests + `verify-session-21.sh`.

## Constraints
- Branch `session-21-copilot-loader`. Max 3 files / atomic commit. Max 1 story. ~2h cap.
- `scripts/verify-session-21.sh` must exit 0. Demo script is cumulative.
- ADRs locked — deviations need explicit approval.

## Output
- A working `⚡on` loader proven in a real session + `sessions/session-21-summary.md` (must answer the decision gate + give 3 next options).
