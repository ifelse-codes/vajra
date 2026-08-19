# Session Boot

## Current Session
- **Number:** 123 — COMPLETE
- **Type:** CODE. Fence the `qa-specialist` role's `Write`/`Edit` grant.
- **Goal:** Make it structurally impossible for the QA role to edit the code it tests, instead of
  asking it not to. Steps 1–2 first clear S122's own debt (the two glued-on fail-closed teeth, the
  byte-duplicated `print_tally`/`tally_discloses_nesting`).
- **Verdict:** **ACCEPT** — cold `fidelity-reviewer`, **pass 2**. 5 of 6 SHIPPED, 0 PARTIAL,
  0 NOT-BUILT. Attested `6b729473cc573fcdf7ad1ed0d78e08e8cbfd26156f728fc0c5ed5a2de7d3b04d`.
- **Report:** `sessions/session-123-summary.md` · `sessions/session-123-review.md`.
  Prompt: `prompts/123-task-fence-the-write-grant.md`. **Date last updated:** 2026-08-19.

## Repo State Snapshot
- `.ai/SESSION` = 123. **PR not yet opened.** Branch `session-123-fence-the-write-grant`, not
  merged. S124 starts from a fresh `session-124-*` branch once the founder picks a direction.
- **339 lib tests** (was 337); `verify-session-123.sh` **14/14 green, exit 0**;
  `demo-session-123.sh` **6 of 6**; 7 commands, no 8th (two new flags on the existing `--role`
  surface: `--clean-room-open`/`--clean-room-close`).
- **The fleet is still FOUR roles** — researcher · fidelity-reviewer · plan-advisor · qa-specialist.
  `qa-specialist`'s grant narrowed `Bash, Read, Write, Edit, Grep, Glob` → `Bash, Read, Grep, Glob`.
- **What S123 changed, in one line each:**
  - `read_only_guard_has_teeth` (verify-session-121.sh) and `execution_policy_guard_has_teeth`
    (verify-session-122.sh) — both isolated to a clean baseline plus exactly one planted defect, so
    each fails for the RIGHT reason (confirmed live: neutering the guarded branch flips both red).
  - `print_tally()`/`tally_discloses_nesting()` — extracted to `scripts/lib-tally.sh`, sourced by
    all three verify suites; `tally_is_one_source()` in each proves it via `declare -F`/`extdebug`.
  - `tools:` enforcement — MEASURED live (dispatched `researcher`, confirmed no Write/Edit/Bash tool
    present in its schema at all), not assumed. `DECISION-007` S123 addendum records the mechanism,
    both rejected alternatives, and the residual risk in full.
  - `qa-specialist` dispatch routed through a disposable `git worktree` checkout — `vajra next
    --role <name> --clean-room-open`/`--clean-room-close`, backed by
    `gate_run::CleanRoom::open_persistent`/`remove_persistent` (S119's primitive, split so a
    cross-process dispatch can hold the checkout open past this CLI call's own lifetime).
- **The load-bearing fixture (`clean-room-fence-has-teeth`) holds up.** Built against a throwaway
  repo, never this one: opens a real clean room, attempts a write while pointed at it, and shows the
  source repo's HEAD sha / `git ls-files -s` hash / `git status --porcelain` byte-identical before
  and after — plus a negative control (an unfenced write) proving the detection isn't vacuous.
- **Key S123 findings:**
  - **🟡 The fakest green: `measurement-artifact-cited` only proves two committed documents agree
    with each other**, not that the underlying dispatch happened. The raw transcript
    (`~/.claude/projects/.../*.jsonl` + `.meta.json`) lives outside the repo, uncommitted — unlike
    the S111 precedent it explicitly claims to match, which committed the raw JSON. **Left as-is,
    not softened** — a real, scoped gap, not a blocker.
  - **A cold-review pass 1 REJECT was correct and scoped**: the measurement was true but
    unfalsifiable narrative with no artifact. Fixed in one commit (`70b6f91`).
  - **The dispatched `qa-specialist` found a real defect** in this session's own suite —
    `grant-write-edit-dropped` mislabeled `exec` when it only greps a static file — before any cold
    review ran. Fixed (`0e3d7c4`), then the review file recorded the corrected state.
  - **This dispatch ran under the PRE-S123 grant** (`Bash, Write, Edit`) — the S111 boot-snapshot
    limit means a mid-session grant change is invisible to that same session's own dispatch.
    Disclosed in the governed handoff, not hidden.
- **🔴 The executor thesis is STILL UNPROVEN** — S123 does not change this. It fences one specific
  way `qa-specialist` could cheat; it does not establish that no executor can fake a pass by any
  means. **🔴 The clean room isolates the REPO, not the MACHINE** — `Bash` remains granted; what
  changed is default isolation plus tamper-EVIDENCE, never tamper-proof.

## Next Session
- **Number:** 124 — **CODE.** Close the dispatch-side clean-room gap (founder pick B of three).
- **Goal:** Make `vajra next --role qa-specialist --from` require real evidence a clean room was
  used, not accept any prose. Recommended mechanism: a Vajra-WRITTEN receipt (`--clean-room-open`
  writes it, `--clean-room-close` completes it with real before/after source-repo fingerprints) —
  never an agent-typed marker, which would be the self-asserted-marker class's SIXTH disclosure.
- **Full prompt:** `prompts/124-task-clean-room-dispatch-evidence.md`.
- **Design-significant: YES** — confirm or revise the receipt mechanism in a `DECISION-007` S124
  addendum before step 2 lands.
- **S125 is fixed regardless**: the mandatory NO-CODE GT (`125 % 5 == 0`), auditing S121–S124.
- **🔒 Founder directive (S118):** README/VISION claims are the target spec — never soften them;
  no release until reality meets them.

## Carry-Forwards (NEW from S123)
- **`measurement-artifact-cited` proves document self-consistency, not dispatch reality.** The next
  session that needs to cite a live-dispatch measurement should consider committing the raw
  transcript excerpt itself (as S111 did), not just a hand-written summary of it, if the bar needs
  to go higher than "internally consistent."
- **Nothing structurally forces `vajra next --role qa-specialist --from` to require clean-room
  evidence.** The clean-room flags are real and tested, but a governed handoff is still accepted on
  prose alone. Named as S124 option B.
- **The check-class label is a FIFTH-time disclosed fakest green** (S64, S67, S121, S122, S123).
  Longest-standing unpicked backlog item. Named as S124 option A.
- **`gate_run::CleanRoom` now has two lifetimes**: the original RAII-guarded `new()` (single-process,
  auto-cleanup) and the new `open_persistent()`/`remove_persistent()` (cross-process, explicit
  cleanup). Both share the same `worktree_add`/`worktree_remove` primitives — no logic duplicated.

## Carry-Forwards (from S122)
- **A falsifiability fixture must fail for the RIGHT reason.** Clean the planted defect out of the
  directory before testing the next branch — the exact lesson S123 applied to its OWN new fixture
  (`clean-room-fence-has-teeth`'s two-half, restore-between-halves shape).
- **Expect more than one cold pass.** S122 needed four; S123 needed two. Every rejection so far has
  been correct. Budget for it; pass 1 is not a formality.
- **Do not fix findings after the ACCEPT.** The attestation hashes the reviewed diff; repairing
  afterwards attests something no reviewer saw. File them into the next prompt instead.
- **Widening an exclusion list is not a fix.** The exclusion list IS the hole — assert on a
  FRAGMENT, or read from the canonical source at runtime, instead.

## Standing Carry-Forwards (from S119 + prior)
- **New session = new chat** (AGENTS.md step 10) — open a fresh chat for S124.
- **Communicate in the plainest English** (founder request S103) — translate all jargon.
- **Dispatch-by-name proven for ALL FOUR roles** (Researcher S111, Fidelity Reviewer S115, Plan
  Advisor S117, QA Specialist S121-post-close). Mid-creating-session dispatch of a NEW or JUST-
  MODIFIED role definition still fails per S111 — reconfirmed by S123 (the narrowed grant was
  invisible to this session's own qa-specialist dispatch).
- **Attest LAST:** `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff), the PROMPT IS AN INPUT.
  Compute strictly after every edit to the prompt file itself and confirm two consecutive
  `verify-closeout.sh --inputs-sha NN` runs agree before embedding.
- **`vajra next --role X --from file` hashes the TRIMMED body** — strip before sha256 comparison.
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3).** A bullet list is BLOCKED.
  A verdict wrapped in a `|`-table row also fails — only a bare `**Verdict:** ACCEPT` line passes.
- **Still reuse `named_test_passed()`** — a bare `cargo test --lib <filter>` exits 0 on a filter
  matching zero tests. And **`[[:space:]]`, never `\s`**, in any script check (BSD/macOS grep).
- **Background task flagged, not yet acted on:** `task_2162b487` — the Planner-gate
  `is_acceptance_heading` double-counting bug (S117 finding).
- **KNOWLEDGE §6 growing** — chronic since S60, still unpruned.
- **Known weak check, house-wide, unfixed:** `no-eighth-command` greps a hardcoded usage banner —
  formally classified BEHAVIORAL (hollow) at S121, reused honestly (not re-litigated) at S123.
- **Untracked stragglers** (standing founder call): `sessions/session-9*-artifacts/*`,
  `sessions/session-10{2,3,7,8,9}-artifacts/*`; `vajra-cto-audit-*.html` + `first-mate.html`.
  Also now: `sessions/session-123-artifacts/review-input.diff` (same pattern as S118/S122).
- **crates.io is PUBLISHED — `vajractl` name BURNED**; any crates.io action stays founder-gated.
- **v0.1 installs FOUR ways, all measured, CONFIRMED stranger-shippable at S110 GT.**
- **Max 7 top-level commands** — any fleet growth rides an existing command; an 8th needs a
  separate founder "yes". S123 added flags to `next`, not a command.
