# Session 23 — First-run "aha" (CODE)

## Goal
Make `vajra init` → first session deliver a **felt win in ~2 minutes** — one concrete, scripted moment where the user *sees* Vajra work for them, not just a pile of scaffolded files.

## Why now
S18's walkthrough found the core gap: running the commands produces *files*, not a *feeling* — the first-run payoff is invisible. Two things now make this finally winnable:
- **S21** made the co-pilot a *felt* moment (it fires and blocks live).
- **S22** made that co-pilot **propagate** — every `vajra init` project now enforces day one. So the aha is real and reproducible, not repo-local.
This is the last open Phase 2 item; landing it **closes Phase 2**.

## Scope (1 story)
- Design + build **one** scripted "aha" moment reachable within ~2 minutes of `vajra init`. Candidate shapes (pick in PLAN, don't build all):
  - a post-init **next-step nudge** that walks the user into triggering the co-pilot once, live;
  - a tiny **guided first action** (e.g. `vajra init` ends by telling the user the exact edit/command that will make the co-pilot fire, then they feel the block→surface→proceed loop);
  - a **`--demo`/tour** path that runs the felt moment on canned state.
- Whatever the shape: it must show **enforcement working for the user**, end-to-end, fast.

## Key decision (must answer in the summary)
**What is the aha moment, and how is it triggered — without adding a top-level command?**
- Hard cap: **max 7 top-level commands** (ROADMAP rule). Prefer extending `init` output or reusing `claude`/`next` over a new verb; if a new verb is truly needed, justify against the cap.
- It must be a *felt* win (the user reacts), not another printed file list. Define how you'll know it landed.

## Constraints
- Branch `session-23-first-run-aha`. Max 3 files / atomic commit. Max 1 story. ~2h cap.
- `scripts/verify-session-23.sh` must exit 0. Demo cumulative. ADRs locked.
- S25 is the next ground-truth (NO-CODE) session — keep S23/S24 lean so the GT has a clean surface.

## Output
- The aha moment, reachable in ~2 min from a real `vajra init` into a temp dir, proven by verify + demo + `sessions/session-23-summary.md` (answer the decision + 3 next options).
