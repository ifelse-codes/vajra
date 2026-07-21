# Session 89 — Fix ROADMAP.md's stale "Where We Are" table (CODE, docs-only)

> **Status:** APPROVED (founder pick B of 3 ranked candidates at S88 close).

## Goal

**Expanded at session start (founder request, supersedes original narrow scope):** full
`.ai/ROADMAP.md` consolidation. The original task was to fix the stale "Where We Are" table;
the founder explicitly asked to also remove unnecessary information, consolidate the 710-line
document, and organize complete / in-progress / backlog items. Scope extended to a full rewrite
of `.ai/ROADMAP.md`, from 710 lines to ~220 lines. Still docs-only, no `src/` change.

**Original narrow scope (included within the expanded goal):** `.ai/ROADMAP.md`'s "Where We Are"
quick-reference table read `Today | 2026-07-14`, `Current phase | S59 done…`, `Last closed session
| Session 60…`, `Active session | None — S60 closed; S61 (CODE, pick A…) not yet started` —
**27 sessions and 7 calendar days stale**. Rewrite every field to match ground truth.

## Why this session

This has been named as a live-but-deferred finding at every GT and several regular sessions since
at least S84 (ranked 🥉/🥈, never picked — S85, S86, S87, S88 all went to sharper, freshly-discovered
correctness bugs instead, each a legitimate priority call in the moment). It is now the
**longest-standing deferred item in the backlog** (5 sessions running at S88's close) and a live,
concrete instance of the "readable roadmap one-pager" pain the founder has flagged before (per
[[vajra-compression-correctness-first]]'s sibling concern about notebook-bloat when reading raw
`.ai/`/`ROADMAP.md`). Low risk, concrete, and it's been waiting long enough that leaving it stale
another session would itself become a minor discipline-drift signal.

## Investigation starting point (not a conclusion — verify before committing to an approach)

1. **Read the table's current content yourself** (`.ai/ROADMAP.md`, search for `## Where We Are`)
   — do not assume the drift described above is exhaustive; confirm every field against ground
   truth before rewriting.
2. **Ground truth for each field**, derived live, not guessed:
   - `Today`: the actual current date (check `.ai/KNOWLEDGE.md`'s most recent dated entry, or ask
     if genuinely ambiguous — do not hardcode a stale value forward).
   - `Current phase`: read `.ai/STATE.md`'s "What Currently Works" section (updated every closeout)
     and the top of `.ai/ROADMAP.md` (the "Updated:" banner, which IS kept current) — both already
     describe current reality; this table just needs to catch up to them, not invent new framing.
   - `Last closed session`: `.ai/SESSION` (single integer, always current) minus context — the last
     CLOSED session is whatever `.ai/SESSION` reads at boot time.
   - `Active session`: should read "None — between sessions" per
     `CONSTRAINTS.yaml#state.closeout_active_branch_value`'s established convention (the SAME
     phrasing `.ai/STATE.md`'s "Active Branch" field already uses at every closeout) — reuse that
     convention rather than inventing new wording for the same fact.
3. **Do not silently expand scope** into the adjacent "What Works Today" / "What Does NOT Work Yet"
   tables below it — those were checked in this session's own investigation (S88 closeout) and,
   while their last-touched dates are old, their CONTENT was not found to be actively wrong the way
   "Where We Are"'s date/session numbers are. If you find them ALSO genuinely wrong (not just
   old-dated), name it as a new, separate finding — do not fix it in the same commit (1-story
   discipline) unless it's trivial and you disclose the scope decision explicitly.
4. **This table will go stale again after S89 closes**, the same way it did after whichever session
   last touched it. Consider, and disclose either way (fix or explicitly defer), whether there's a
   cheap, durable way to prevent the NEXT recurrence (e.g., a closeout-checklist line, a verify
   check) — but do not let that consideration become its own multi-session arc; a one-line
   disclosed recommendation is sufficient if a durable fix is bigger than this session's scope.

## Acceptance (testable — every criterion is cited by a `## Plan` step below)

1. **WHEN** `.ai/ROADMAP.md`'s "Where We Are" table is read **THEN** every field matches ground
   truth as of this session's close (today's real date; current phase describing the real
   8-station-pipeline + attestation-hardening state; last closed session = 88; active session =
   "None — between sessions" using the established convention) — proven by reading the actual file
   content after the edit, not asserted.
2. **WHEN** `git diff --name-only main..HEAD` is read **THEN** it shows ONLY `.ai/ROADMAP.md` plus
   this session's own required scaffolding (`prompts/89-...md`'s own Execution self-record,
   `scripts/verify-session-89.sh`, `scripts/demo-session-89.sh`, `sessions/session-89-{summary,
   review}.md`) — no `src/` change, no other `.ai/*` file, no unrelated table in `ROADMAP.md`
   touched.
3. **WHEN** `bash scripts/verify-session-89.sh` runs **THEN** it exits 0, having actually READ the
   post-edit table content and asserted the specific stale strings (`2026-07-14`, `S59 done`,
   `Session 60`, the stale `Active session` line) are ABSENT and the correct current values are
   PRESENT — not merely asserting the file changed.
4. **WHEN** `cargo test --lib` runs **THEN** it stays green, unchanged (docs-only session, no `src/`
   touch expected).
5. Scope stays inside the ONE table — no new command, no `CONSTRAINTS.yaml` key, no edits to
   "What Works Today" / "What Does NOT Work Yet" unless a genuine, disclosed, separately-scoped
   finding justifies it (see Investigation point 3).

## Design (the Architect gate — recorded rationale)

design-significant: **no** — a factual content correction to an existing status table, no new
mechanism, store, command, or ADR deviation. Same shape as S82's ledger-fallback fix and S86's
attestation hardening, both marked not design-significant.

## Plan (ordered steps — cite the acceptance criteria each step covers)

1. Read the current "Where We Are" table and every field's ground-truth source
   (`.ai/STATE.md`, `.ai/SESSION`, `.ai/ROADMAP.md`'s own top banner) per the Investigation
   section. `covers: 1`
2. Rewrite the table's 4 fields (Today, Current phase, Last closed session, Active session) to
   match ground truth, reusing the established "None — between sessions" convention for the active
   field. `covers: 1, 5`
3. Confirm no other file or table was touched; write `scripts/verify-session-89.sh` asserting the
   stale strings are gone and the correct values are present, reading the real file content.
   `covers: 2, 3`
4. Write `scripts/demo-session-89.sh` (before/after of the table's real content) and run
   `cargo test --lib` to confirm green. `covers: 4`

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: `b297675` (read ROADMAP + STATE.md + SESSION at session boot)
- step 2 — done: `b297675` (rewrote table + full ROADMAP consolidation per founder expansion)
- step 3 — done: `af8bcbf` (verify-session-89.sh, 16/16; no src/ change confirmed)
- step 4 — done: `af8bcbf` (demo-session-89.sh; cargo test --lib 271 green)

## Guardrails

- **One story:** fix the "Where We Are" table only. Do NOT start the dogfood refresh or touch the
  "What Works Today"/"What Does NOT Work Yet" tables (both explicitly out of scope this round,
  unless a genuine separate finding is disclosed per Investigation point 3).
- **No new command, no new `CONSTRAINTS.yaml` key.**
- Max 3 files per atomic commit · ~2h cap.
- **S90 is the next mandatory NO-CODE ground truth** (`90 % 5 == 0`) — S89 is normal, the LAST
  regular session before it.

## Delta (the Analyst gate — what this session ADDS to the governed pipeline)

- `~` `.ai/ROADMAP.md`'s "Where We Are" table: corrects a 27-session-stale status snapshot to
  match real ground truth — closes the longest-standing deferred item in the backlog (5 sessions
  running at pick time), no new mechanism.
