# Session 123 — Summary

**Type:** CODE · **Branch:** `session-123-fence-the-write-grant` · **Date:** 2026-08-19
**Goal:** fence the `qa-specialist` role's `Write`/`Edit` grant so it is structurally impossible for
the role to edit the code it tests, instead of asking it not to.
**Verdict:** **ACCEPT** — cold `fidelity-reviewer`, pass 2. 5 of 6 SHIPPED · 0 PARTIAL (closed
before landing) · 0 NOT-BUILT. Full brief: `sessions/session-123-review.md`.
Attested `6b729473cc573fcdf7ad1ed0d78e08e8cbfd26156f728fc0c5ed5a2de7d3b04d`.

## What shipped

| Step | What was wrong | What landed |
|---|---|---|
| 1 | Two S122 fixtures ended on a "fail-closed" tooth that could not fail — the guarded directory/copy still carried an earlier planted defect from the same function, so the assertion passed for the wrong reason | Both isolated to a clean baseline plus exactly one defect (`verify-session-121.sh` `read_only_guard_has_teeth`; `verify-session-122.sh` `execution_policy_guard_has_teeth`). Confirmed live, in scratch copies: neutering the guarded branch flips both to FAIL. |
| 2 | `print_tally()`/`tally_discloses_nesting()` byte-duplicated across `verify-session-121.sh`/`-122.sh`, nothing binding the copies | Extracted to `scripts/lib-tally.sh`, sourced by all three suites (`-121`, `-122`, and the new `-123`). `tally_is_one_source()` uses `declare -F`/`extdebug` to assert real resolution, not a text match — fails if a stray local copy ever reappears. |
| 3 | Nobody had measured whether Claude Code's harness actually enforces a role's `tools:` line, or whether it's a convention the role chooses to follow | Measured live: dispatched the read-only `researcher` role and had it attempt a write by any means. Result — no `Write`/`Edit`/`Bash` tool was present in its callable schema at all, not merely declined. Recorded in `DECISION-007`'s S123 addendum with both rejected alternatives (narrow-the-grant-alone: real but insufficient given `Bash`; a write-blocking hook: requires guessing intent, unwinnable) and the residual risk stated plainly (isolates the REPO, not the MACHINE). |
| 4 | The `Write`/`Edit` grant was documented, not controlled | Two layers: (a) `qa-specialist`'s dispatch is routed through a disposable `git worktree` checkout — new `vajra next --role <name> --clean-room-open`/`--clean-room-close`, backed by `gate_run::CleanRoom::open_persistent`/`remove_persistent`; (b) `Write`/`Edit` dropped from the recorded grant (`Bash, Read, Write, Edit, Grep, Glob` → `Bash, Read, Grep, Glob`), re-rendered into `.claude/agents/qa-specialist.md`. |
| 5 | No suite existed proving the fence stops anything real | `scripts/verify-session-123.sh` (14/14) + `scripts/demo-session-123.sh` (6/6). Load-bearing fixture `clean-room-fence-has-teeth`: opens a real clean room against a throwaway repo, attempts a write while pointed at it, and shows the source repo's HEAD sha / `git ls-files -s` hash / `git status --porcelain` byte-identical before and after — plus a negative control (an unfenced write) proving the detection isn't vacuous. |
| 6 | — | Dispatched `qa-specialist` by name against this session's own suite (governed handoff: `.ai/handoffs/session-123-qa-specialist.md`); it found a real defect (see below). Two cold `fidelity-reviewer` passes: pass 1 REJECT, pass 2 ACCEPT. |

- `scripts/verify-session-123.sh` — **14 checks, exit 0** (9 exec · 2 struct · 2 behav · 1 nested).
  `scripts/demo-session-123.sh` — **6 of 6.** **339 lib tests**, clippy clean, fmt clean.
- **The dispatched `qa-specialist` found a real defect**, disclosed and fixed before the cold
  review: `grant-write-edit-dropped` was mislabeled `exec` when it only greps a static, already-
  committed file — reclassified `behav` (`0e3d7c4`).
- **This dispatch ran under the PRE-S123 grant** (`Bash, Write, Edit`) — per the standing S111
  boot-snapshot limit, the narrowed grant landed mid-session and was invisible to this session's own
  dispatch. Disclosed in the governed handoff itself, not hidden.

## Fidelity map (every numbered requirement)

| # | Requirement | Verdict |
|---|---|---|
| 1 | Both S122 fixtures fail for the right reason, proven by the assertion flipping | SHIPPED |
| 2 | The tally is one source, or divergence turns a check RED | SHIPPED |
| 3 | `tools:` enforcement MEASURED not assumed; addendum with both alternatives + residual risk | SHIPPED (after a pass-1 REJECT — see below) |
| 4 | QA dispatch runs against a disposable clean-room checkout, on the real path | SHIPPED |
| 5 | `verify-session-123.sh` proves the fence via an ATTEMPTED write, never source-text | SHIPPED |
| 6 | Cold `fidelity-reviewer` ACCEPT | SHIPPED |

## THE FAKEST GREEN (do not soften)

**`measurement_artifact_is_cited_and_consistent()` in `verify-session-123.sh`.** It only checks
that two committed prose documents (the `DECISION-007` addendum and
`sessions/session-123-artifacts/tools-enforcement-measurement.md`) agree with each other on a
tool-call-ID string — it cannot fail even if the entire dispatch were invented and the same ID
typed consistently into both by hand. The dispatch DID happen — the raw
`~/.claude/projects/.../*.jsonl` and `.meta.json` files exist locally and were read directly to
build the artifact — but those raw files live outside this repo and are not committed, unlike the
S111 precedent this session explicitly claims to match, which committed the raw JSON. A future
reader of this repo alone has the artifact's word for the dispatch, not the dispatch itself.

**Also still true, and not softened:**
- **The executor thesis is still UNPROVEN.** This fences one specific way `qa-specialist` could
  cheat (repair the product, report the repair as original); it does not establish that no executor
  can fake a pass by any means. Never restate the S121 claim as measured because this fence exists.
- **The clean room isolates the REPO, not the MACHINE.** `qa-specialist` keeps `Bash`; nothing
  stops `cd /real/path && echo x > file` by name. What changed is default isolation plus
  tamper-EVIDENCE (HEAD sha / index hash / porcelain compared), never tamper-proof.
- **Nothing structurally forces a dispatch to call `--clean-room-open` first.** It is real, tested
  machinery, wired into the role's own prompt — but the governed-handoff path (`run_role_handoff`)
  does not require evidence a clean room was used before accepting a QA finding.
- The check-class labels are **still typed by the author** — the unpicked S121 option B, now a
  fifth-time disclosure (S64, S67, S121, S122, S123).
- `no-eighth-command` is still a hardcoded-banner grep.

## How this session actually went (recorded, not hidden)

Two cold-review passes: **REJECT → ACCEPT.** The rejection was correct and scoped to one real gap
(AC3's measurement had no artifact) — closed in one commit (`70b6f91`), not a rewrite. The dispatched
`qa-specialist`, running under the stale pre-fence grant, still found a real defect in this session's
own suite before the cold review ran. Two independent passes, not the builder, found both issues.

## Cost

`$0` metered (interactive session). Two `fidelity-reviewer` passes (~88k, ~97k subagent tokens) and
one `qa-specialist` pass (~50k) roll in unitemized. No paid dogfood run this session; last paid
dogfood remains S118 ($4.0912, 2026-08-15) — 5 sessions / 4 calendar days ago as of this close,
confirmed live by `vajra next --dogfood-age`.

## Next — 3 options (A/B/C)

| | Title | One-sentence goal | Why pick this | Key risk |
|---|---|---|---|---|
| **A** | **Make the check-class label EARNED** | Derive `exec`/`struct`/`behav` from what a check actually does, rather than from a word the author typed. | Disclosed as the fakest green FIVE times now (S64, S67, S121, S122, S123) — the longest-standing unpicked item in the backlog. | Deriving it may be undecidable in the general case; risk of shipping a heuristic that becomes a new fakest green. |
| **B** | **Close the dispatch-side clean-room gap** | Make `vajra next --role qa-specialist --from` require evidence the finding came from a clean-room run, not just accept any prose. | This session's own named residual: "nothing structurally forces a dispatch to call `--clean-room-open` first." Direct continuation of the fence, closing the gap S123 itself disclosed. | Risk of designing a second self-asserted marker (a "ran in clean room: yes" field is the same class of hole as `covers:`/`design-significant:` unless it's checked against something real. |
| **C** | **S125 is the mandatory NO-CODE GT** (`125 % 5 == 0`) — S124 is the last CODE/DOGFOOD slot before it. Candidate: **paid dogfood ride-along** | Run a real `vajra claude` session and see whether the fence (and the fleet generally) holds under real, unscripted use — not a synthetic fixture. | Staleness is 🟡 (5 sessions / 4 calendar days since S118) and climbing; every GT since S30 has flagged dogfood cadence. A live run also gives S125's GT something real, current to audit. | Cost (S118 was $4.09); a dogfood run can surface an unrelated defect that eats the session before it reaches the fence-specific question. |
