# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 46 — live re-dogfood: prove the moat fires live (#17a, CODE/VERIFY, PAID) — COMPLETE

- **Delivered:** live evidence the enforcement moat fires against an autonomous agent. No source-code
  change. Output = `sessions/session-46-summary.md` + `sessions/session-46-live-hook-fire.txt`.
- **Verdict:** the moat is **LIVE-VERIFIED — `dogfood_check` 🟢** (first since S36). $0 replay 13/13 +
  four PAID `vajra claude -p` L3 runs (~$3.84). **Two layers hold live:** governance-in-context (Claude
  self-refuses the guarded push/PR 3/3) + hook backstop (isolation harness: agent ran `git push`,
  publish-guard blocked it exit-2 in the JSONL). 4/4 no leak. `verify-session-46.sh` 13/13.
- **Founder direction LOCK: B** — "your AI does better work", not "your AI can't go rogue". The
  enforcement arc is DONE. Build the co-pilot value; "cheaper" = less re-work, not compression.

Between sessions. Next = S47, the first direction-B session (**founder pick pending** — A/B/C).

## Next Session (S47 — direction B, founder pick: B = mid-run co-pilot)

- **Delivers:** wire a `UserPromptSubmit` murmur so the co-pilot surfaces the right `copilot.on` context
  *proactively, non-blocking* (exit 0 — guide, not block) — the half missing from today's PreToolUse-only
  blocker. Paired follow-on (~S48) = the obedience metric that measures whether it helps.
- **Prompt:** `prompts/47-task-midrun-copilot.md` (ready).
- **Branch:** `session-47-midrun-copilot` off `main` — **new chat.**

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`.
- Every 5th session is NO-CODE ground-truth (last = S45; next mandatory = S50).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S47; do NOT start it here.
- **Direction is B (S46 lock):** make the AI do BETTER WORK (correct results, less re-work, less
  babysitting), not just block it. The enforcement guard is the floor, complete + live-verified — stop
  polishing it. "Cheaper" comes from less re-work, not token compression (~$0). Memory `vajra-direction-b-copilot`.
