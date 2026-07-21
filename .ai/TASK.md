# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 88 — Hash a review-time snapshot, not the live prompt file (CODE) — COMPLETE

- **Goal:** both hashing call sites (`src/stations/mod.rs#attested_hash_outcome`/`read_prompt`,
  `scripts/verify-closeout.sh#canonical_inputs_sha`) read the prompt file's CURRENT live bytes, not
  a snapshot from review time. Fixed: Rust reads each candidate's prompt bytes from that
  candidate's OWN commit tree (`prompt_bytes_at`); bash reads via `git show HEAD:path` instead of
  `cat`. Delivered.
- **Headline:** `vajra next --stations 76` — Reviewer/Releaser flip back `ABSENT → PASSED`, live.
  **Bonus finding:** S73 and S79 were ALSO victims of this exact bug (previously misdiagnosed as
  "genuinely unreconstructable" by S86) — new split 22 Verified / 4 Absent out of 26.
- Independent cold review: **pass 1 REJECT** (this session's OWN bash-side AC3 fixture was
  hollow-green — a single-digit session number tripped a pre-existing padding bug, passing
  unconditionally regardless of the fix) → fixed in-session (2-digit fixture + negative control +
  an unrelated S32 SIGPIPE/pipefail gotcha) → **pass 2 ACCEPT**, adversarially re-verified by hand
  by the same reviewer. Mirrors the S67/S87 two-pass pattern.
- Report: `sessions/session-88-review.md`. Summary: `sessions/session-88-summary.md`. Prompt:
  `prompts/88-task-fix-canonical-inputs-sha-snapshot.md`.

Between sessions. **Next = S89 — CODE (docs-only), fix ROADMAP.md's stale "Where We Are" table.**
New chat.

## Next Session (S89 — CODE docs-only, founder pick B, APPROVED)

- **Goal:** `.ai/ROADMAP.md`'s "Where We Are" table reads `Today | 2026-07-14`, `Session 60`,
  27 sessions stale inside an otherwise-current document — deferred 5 sessions running (S84→S88),
  now the longest-standing backlog item. Rewrite its 4 fields to match ground truth (today's date,
  current phase, last closed session = 88, active session = "None — between sessions").
- Prompt: `prompts/89-task-fix-roadmap-stale-table.md`.
- **Branch:** `session-89-fix-roadmap-stale-table`. One story, docs-only, no new command/
  CONSTRAINTS key, no edits to the adjacent "What Works Today"/"What Does NOT Work Yet" tables
  unless a genuine separate finding is disclosed.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Every 5th session is NO-CODE ground truth (next = **S90**, the
  session right after S89 — S89 is the LAST regular session before it).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S89; do NOT start it here.
- **Direction:** product = **provable agent governance**, shaped as a **governed multi-agent SDLC
  pipeline** (`DECISION-001`); fidelity is load-bearing (`DECISION-002`), verdicts attested
  (`DECISION-003`) + chained tamper-evident (`DECISION-004`). **Pipeline = 8 governed stations.
  S88 fixed DECISION-003's attestation-hash root cause (review-time snapshot, not live bytes) and,
  as a live bonus, repaired 2 previously-misdiagnosed historical sessions (S73, S79) alongside its
  direct target (S76). Dogfood remains 🔴 (12 sessions / 19+ days stale since S76) and
  founder-un-parkable — not picked at S89 either (founder chose the ROADMAP-table fix instead);
  watch it keep aging into S90's GT.**
