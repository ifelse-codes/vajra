# Session 23 — First-run "aha" (CODE)

**Goal:** make `vajra init` → first run deliver a *felt* win in ~2 minutes — the user *sees* Vajra work, not just a pile of files.

**Status:** ✅ achieved. [PR #13](https://github.com/ifelse-codes/vajra/pull/13). verify-session-23.sh **11/11 ALL GREEN**. **Closes Phase 2.**

## What shipped

| Area | Change |
|---|---|
| `src/cli/init.rs` | `run()` now calls `first_run_aha()` after `scaffold()`: fires the *just-scaffolded* `hook-copilot-loader.sh` once against a sample `git commit` (isolated temp debounce dir) and shows the **real** co-pilot block + surfaced `.ai/STATE.md`, framed as a 5-second simulation, then a `vajra claude` next-step. `render_aha_fallback()` covers bash/jq-absent. Unit test added. |
| `scripts/verify-session-23.sh` | 11 checks incl. a real `vajra init </dev/null` asserting the live block in init output. |
| `scripts/demo-session-23.sh` | cumulative; shows the felt win (elapsed ~0s). |

## Key decision (the prompt's required answer)

**What is the aha, and how is it triggered without an 8th command?**

→ The aha is a **live co-pilot fire at the end of `vajra init`** — it *rides on `init`* (still 7 top-level commands). It's a **real hook fire**, not a mockup: honest, and it dogfoods the S22-propagated co-pilot.

- Rejected a **guided multi-step first run** (run `claude`, type a prompt) — needs an API call + user steps; slower than the 2-min bar.
- Rejected a **static "what you got" blurb** — informative but *not felt*.
- **Degrades gracefully:** missing bash/jq → static rule preview; init never fails (child exit 2 is captured, init still exits 0).
- **How we know it landed:** the live co-pilot block (`[vajra co-pilot]` + `fired` + `.ai/STATE.md`) appears in init's own output, asserted against a real scaffold in verify.

## Evidence

- `verify-session-23.sh` 11/11: cargo fmt/clippy/test-init/build + real init → live block present, reframe present, next-step present, scaffold intact (17 files), `init-exits-zero`, `no-debounce-leak`.
- `cargo test` 108 pass; fmt + clippy clean. CI runs cargo only (no jq dependency).

## Self-review

- **What breaks?** shell-out to bash/jq — covered by fallback + unit test; child exit 2 — captured, init exits 0 (verified).
- **Hidden assumptions?** "felt win = seeing the block" (subjective but the most visceral proof of a governance tool); live fire is sub-second, well under 2 min.
- **Scope:** 1 story, 3 files / 2 commits. Intact. No new top-level command.

## Where we are
Phases 1–3 **all complete**. The roadmap's named build queue is done; what remains is the backlog (cross-agent, ledger v2, policy/memory/MCP) + two deferred/provisional items. **S25 is the next ground-truth (NO-CODE)** — keep S24 lean.

## Next options (pick one)

### A. Second agent launcher (Cursor or Codex) — the north-star gap
- **Goal:** wire a second agent so Vajra is cross-agent *in practice*, not just in docs.
- **Why pick:** the north-star is the **cross-agent** coach; only Claude is wired. Phase 2 is done — this is the next real frontier.
- **Key risk:** big lift; enforcement is Claude-hook-shaped (Cursor/Codex hook models differ) — may not port cleanly and is not "lean" right before a GT.

### B. Render `.ai/` → generated `.varta` (lean — recommended) ⭐
- **Goal:** one-way generate a glanceable `.varta` artifact from the live `.ai/` (generated, never hand-kept).
- **Why pick:** completes the Varta language story; **lean + low-risk** (S22/S23 proved generate-from-one-source), leaving a clean surface for the S25 GT. Honors the S19 no-hand-copy rule by construction.
- **Key risk:** value — a rendered `.varta` may be redundant if the agent reads `.ai/` fine already; must justify it earns its place.

### C. Validate the provisionals before GT
- **Goal:** de-risk the two flagged assumptions — "grammar frozen at 9" and `vajra estimate`'s unvalidated 3:1 output ratio — with real session data.
- **Why pick:** directly serves the S25 ground-truth; turns two "provisional" footnotes into evidence.
- **Key risk:** less visible feature work; partly investigative rather than shippable.
