# Session 123 — Independent Fidelity Review (cold `fidelity-reviewer`, pass 2)

> **Dispatched by name** (`subagent_type: "fidelity-reviewer"`), fed only two things: the session
> prompt `prompts/123-task-fence-the-write-grant.md` and the full branch diff
> `sessions/session-123-artifacts/review-input.diff`. Not self-certified. Read-only tools.
>
> **Two passes were needed.** Pass 1 **REJECT** (AC3's `tools:` enforcement claim was true but
> unfalsifiable narrative — no artifact in `sessions/session-123-artifacts/` to check it against).
> Fixed in `70b6f91`: a real cross-verified artifact
> (`sessions/session-123-artifacts/tools-enforcement-measurement.md`), reusing the exact
> evidentiary shape `DECISION-007`'s S111 addendum used (two independently-written files agreeing
> on a tool-call ID neither side controlled), plus a bound `measurement-artifact-cited` check.
> Pass 2 **ACCEPT**. Pass 1's brief is preserved in `sessions/session-123-summary.md`.

**Review-Inputs-SHA:** 6b729473cc573fcdf7ad1ed0d78e08e8cbfd26156f728fc0c5ed5a2de7d3b04d

## Per-requirement verdict

| # | Acceptance criterion | Verdict | Evidence |
|---|---|---|---|
| 1 | Both S122 fixtures fail for the right reason, proven by removing the guarded branch and showing the assertion flip | SHIPPED | `read_only_guard_has_teeth` isolated into fresh `$TMP/faildeny` (negative) and `$TMP/failallow` (positive control), no longer reusing the leak-carrying `$TMP/leak`. `execution_policy_guard_has_teeth` restores clean `s121.sh`/`s122.sh` copies before the fail-closed `empty.rs` case, no longer riding leftover planted drift 3. Both confirmed live in a scratch copy: neutering the guarded branch flips each fixture to FAIL. |
| 2 | The tally implementation is one source across both suites, or divergence between the copies turns a check RED | SHIPPED | New `scripts/lib-tally.sh` holds the single `print_tally()`/`tally_discloses_nesting()`; all three suites (`-121`, `-122`, `-123`) source it. `tally_is_one_source()` uses `declare -F` with `extdebug` to assert the functions resolve from `lib-tally.sh`, not a local redefinition — a real behavioral check, not a text match. |
| 3 | Whether the harness enforces a role's `tools:` line is MEASURED and recorded, not assumed; the clean-room fence is recorded in a `DECISION-007` S123 addendum with both rejected alternatives and the residual risk stated plainly | SHIPPED | Addendum records both rejected alternatives (narrow-grant-alone; write-blocking hook) and the residual risk (isolates the REPO, not the MACHINE; tamper-evident not tamper-proof) in full. The measurement is backed by `sessions/session-123-artifacts/tools-enforcement-measurement.md`: the `researcher` role's actual dispatch, cross-verified via two independently-written files (this session's transcript and the subagent's own `meta.json`) agreeing on tool-call ID `toolu_01BpAnw69h7MVcRAZjbjYQo1`, plus its verbatim final report. Pass 1 REJECTED the first cut (prose-only, no artifact); this is the fix. |
| 4 | The QA role's dispatch runs against a disposable clean-room checkout, on the real path, not a flag nobody sets | SHIPPED | `--clean-room-open`/`--clean-room-close` are real CLI flags on the existing `--role` surface, backed by `gate_run::CleanRoom::open_persistent`/`remove_persistent` (unit-tested) and gated to Bash-holding roles. `qa-specialist.md`'s system prompt instructs dispatch through this path. Disclosed, not hidden: nothing in code structurally forces a dispatch to call `--clean-room-open` first — it is a documented workflow step. |
| 5 | `verify-session-123.sh` exits 0 with its own tally; the fence is proven by a fixture in which a write is ATTEMPTED during a QA run and the source repo is shown byte-identical before and after — never by asserting the fence's own source text exists | SHIPPED | `clean_room_fence_has_teeth()` builds a throwaway git repo, opens a real clean room via the compiled binary, writes into it, and compares the source repo's HEAD sha / `git ls-files -s` hash / `git status --porcelain` before and after — plus a negative-control half that performs an unfenced write and confirms the same detection flips (the S122 lesson, applied). 14/14 green. |
| 6 | Cold `fidelity-reviewer` ACCEPT | SHIPPED | This file. |

**5 of 6 SHIPPED · 1 PARTIAL (at pass 1, closed before this landed record) · 0 NOT-BUILT.**

## THE FAKEST GREEN

**`measurement_artifact_is_cited_and_consistent()` in `verify-session-123.sh`.** It only checks
that two committed prose documents (the addendum and the artifact) agree with each other on a
tool-call-ID string — it cannot fail even if the entire dispatch were invented and the same ID
typed consistently into both files by hand. The underlying dispatch DID happen (the raw
`~/.claude/projects/.../*.jsonl` and `.meta.json` files exist locally and were read directly to
build the artifact) but those raw files are outside the repo and not committed — unlike the S111
precedent this session explicitly claims to match, which committed the raw JSON. A future reader
of this repo alone has the artifact's word for the dispatch, not the dispatch itself.

**Verdict:** ACCEPT

The real scope delivered is a faithful build of the contract: both named S122 debts were closed
with genuine negative-control fixtures, the tally-duplication hazard is structurally eliminated,
the clean-room fence has a real teeth-bearing falsifiability fixture (confirmed to flip red when
neutered), and every residual limitation (machine-not-repo isolation, executor-thesis-still-
unproven, dispatch-side enforcement not code-gated, the measurement artifact's own evidentiary
ceiling) is disclosed plainly. Pass 1's REJECT was correct and scoped to one real gap; it is closed.
