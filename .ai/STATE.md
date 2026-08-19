# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions (S122 complete, S123 not yet started).** S122 PR
[#133](https://github.com/ifelse-codes/vajra/pull/133) **MERGED 2026-08-19** (CI green both OS);
branch pruned local + remote; `main` synced. S123 starts from a fresh `session-123-*` branch.

S122 closed the four real holes the S121 live QA run found in S121's own guardrails, plus a fifth
the QA role found this session. Cold `fidelity-reviewer` **pass 4 ACCEPT** (5 of 6 SHIPPED, 1
PARTIAL, 0 NOT-BUILT). Summary: `sessions/session-122-summary.md`. Review:
`sessions/session-122-review.md`.

**FOUR cold passes were needed — REJECT → ACCEPT-with-findings → REJECT → ACCEPT — and every
rejection was correct.** The same render tautology was found on a THIRD field after two "fixes";
the `.ai/handoffs/` booby-trap was re-armed TWICE inside the session closing it; the anti-hollowness
demo was itself hollow. The dispatched `qa-specialist` found three more defects before any cold pass
ran, and changed nothing.

## Active PRs
- **No open PRs.** S122 [#133](https://github.com/ifelse-codes/vajra/pull/133) **MERGED
  2026-08-19** (CI green both OS; branch pruned local + remote). S121
  [#131](https://github.com/ifelse-codes/vajra/pull/131) MERGED 2026-08-19 · S120 (#130) MERGED ·
  S119 (#129) MERGED 2026-08-17.
- Prior: **S118 [#128](https://github.com/ifelse-codes/vajra/pull/128) MERGED** · S117 #126 · S114
  #122 · S113 #120 · S112 #118 (+#119) · S111 #117 · S109 #115 · S110 #116 · S108 #113/#114 · S107
  #112 · S106 #111 · S116 merged inside #125.

## Direction (governance is the product — now shaped as a shippable MVP)
- **The product = provable agent governance** (`DECISION-001`), sold as the **autopilot trust
  layer**. Fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). The fleet = **real named agents behind the existing gates**
  (`DECISION-007`) — **FOUR roles built, ALL FOUR now proven dispatched by name**
  (`qa-specialist` proved it at the S121 post-close run, inside its own creating session).
- **Post-pivot roadmap:** C team-voice (S104 ✓) → **B installable v0.1 ✓ COMPLETE** → **A fleet
  COMPLETE (4 roles)** → Dogfood S118 ✓ → S119 ✓ (clean-room runner) → S120 ✓ MANDATORY GT →
  **S121 ✓ QA Specialist built + dispatched → S122 ✓ the guardrails it audited are FIXED
  (4 contracted holes + 1 the role found) → S123 = fence the `Write`/`Edit` grant →
  S125 = MANDATORY NO-CODE GT.**

## What Currently Works
- **The 8 stations** riding `vajra next` (+ gates at `--advance`): Analyst · Architect · Planner ·
  Coder · QA · Demo-er · Releaser · Reviewer. Receipt AUTHORITATIVE (S78 tee path).
- **The fleet has FOUR named roles, ALL proven dispatched by name.** Researcher · Fidelity
  Reviewer · Plan Advisor · **QA Specialist (built + dispatched S121; TWO live runs now, seven real
  defects between them — four at S121, three at S122).** `vajra init`
  scaffolds all four `.claude/agents/*.md` files; `vajra next --role <key> --from <file>` governs
  any of them; `vajra next --stations NN` reports fleet evidence beside `K of 8`.
- **Exactly one role executes.** `qa-specialist` holds `Bash, Read, Write, Edit, Grep, Glob`; the
  other three stay read-only, enforced as a named allowlist of one (a fifth role cannot inherit
  Bash by being added to the table). `DECISION-007` S121 addendum.
- **The clean-room runner (S119).** QA and Demo-er route scripts through a fresh `git worktree add
  --detach` checkout of HEAD when `verify.clean_room.enabled: true` (default off). Bootstrap
  command support; failure → `CannotEvaluate` → BLOCK. `VAJRA_SKIP_CLEAN_ROOM=1` escape.
  `vajra init` scaffolds the new keys. Falsifiability fixture: working tree passes with stale
  artifact, clean room fails — the exact defect CI caught at S118.
- **Ledger** (S100): `verify-closeout.sh --ledger-verify` last confirmed INTACT at S115. Ledger is
  DERIVED from `sessions/session-NN-review.md` via `_ledger_read()` in verify-closeout.sh. No
  separate `.ai/ledger/` directory — by design.
- **v0.1 install: CONFIRMED stranger-shippable (S110 GT).** Four channels, all real.
- **CI green on `main`** (both OS); 7 commands, no 8th. **337 lib tests.**
- **The guardrails themselves are now guarded (S122).** The read-only tool-grant check is
  token-exact, not a prefix grep; the one-source check excludes generated/handoff paths and names
  its carriers on failure; no test asserts a render against a content field of the role it rendered
  (the field list is DERIVED from `pub struct Role`); the check-class tally has a fourth class
  `nested`, names what it hides, and calls its behavioral count a FLOOR. **Every one carries a
  falsifiability fixture that invokes the real implementation against a planted defect.**
- **Both halves of the execution policy are bound across their three copies** — forbidden tools AND
  the execution allowlist (`verify-session-122.sh#execution-policy-one-source`). Before S122 the
  Rust list was missing `Task`, so a role granted execution-by-proxy passed the unit test.

## What Is Broken / Weak
- **🔴 Coder-dark for S119 (S120 finding):** `## Execution` step 7 records prose ("cold
  fidelity-reviewer pass ACCEPT") not a commit sha — `git cat-file -e <sha>^{commit}` fails.
  Steps 1-6 have real shas. Legitimate non-commit evidence breaks the gate; filed not fixed.
- **🟡 3 behavioral source greps in verify-session-119.sh (S120 finding):** `init_scaffold_has_clean_room`
  (greps source template), `skip_env_var_referenced` (greps env var name in src), `run_location_printed`
  (the S119 disclosed fakest green). Pattern widespread in older scripts (S19, S21) + fleet sessions.
- **🟡 VISION.md stale (S120 finding):** (1) clean-room runner not in body; (2) Rules section still
  references the retired machinery-freeze rule (freeze RETIRED at S103; preamble says SUPERSEDED
  but Rules body does not).
- **🟡 The clean-room runner is not tested via the compiled CLI path** (`--check-qa` / `--check-demo`
  with `clean_room: true`). Unit tests inject closures; no end-to-end exercise.
- **🟡 The Planner-gate double-count bug** (`src/planner/mod.rs::is_acceptance_heading`,
  `task_2162b487`) — carried, still unfixed.
- **🟡 `vajra next --dogfood-age` does not recurse into artifact subdirectories** (named S115).
- **🟡 `no-eighth-command` checks are a grep for a hardcoded usage banner** (8+ consecutive CODE
  sessions flagged) · **🟡 KNOWLEDGE §6 bloat at 642 lines** (10 GTs flagged, unfixed) · **🟡
  `vajra.varta` re-render drifts every session** · **🟡 `vajra --version` gap** · **🟡 brew
  smoke tests LOCAL formula**.
- **✅ The four S121 live-QA defects are CLOSED (S122)** — token-exact read-only guard, defused
  `.ai/handoffs/` booby-trap with carriers named, three render tautologies removed, tally honest
  about nesting. Each with a falsifiability fixture. Plus a fifth the QA role found: the
  forbidden-tool policy had already drifted (`Task` missing from the Rust list).
- **🔴 S122's own fakest green, UNFIXED and filed as S123 step 1: two of five fixtures end on a
  "fail-closed" tooth that CANNOT FAIL.** `read_only_guard_has_teeth` writes its `tools:`-less
  `mystery.md` into the directory that still holds the planted `Write` leak, so the guard rejects it
  for the wrong reason; `execution_policy_guard_has_teeth` runs its fail-closed case against a copy
  still carrying planted drift 3. Delete the guarded branch and both still print OK. Left unfixed on
  purpose — repairing after the ACCEPT would attest a diff no reviewer saw.
- **🟡 `print_tally()` and `tally_discloses_nesting()` are byte-duplicated** across
  `verify-session-121.sh` and `verify-session-122.sh` with nothing binding them. S122 fixed
  drift-by-copy for the execution policy and created it for the tally in the same diff. S123 step 2.
- **🟡 Five `def.contains(… role.name …)` instances remain by design** — the join key is exempt from
  the tautology guard, reasoned only in a comment. `assert!(def.contains(role.name))` passes today.
- **🟡 The tally's class NUMBERS are still unchecked against the printed rows** — a check given the
  wrong `CLASS` string still yields a fully "honest" tally.
- **🔴 The executor thesis is UNPROVEN — and `DECISION-007` now says so in writing** (S122 addendum
  retracting the S121 claim). **Two** live QA runs, **seven** real defects, EVERY ONE from careful
  independent READING. Execution bought the exit codes and the pass counts, nothing more. What is
  evidenced is INDEPENDENCE, not execution. **No check enforces that correction** — it is typed
  prose in six places and it decays the day someone stops typing it. Never pitch it as measured.
- **🔴 The `Write`/`Edit` grant is documented, not FENCED.** Nothing structurally stops the QA role
  editing the code it tests; on the live run the tree was verified byte-identical before/after, but
  in the agent's own words *"that constraint held because I chose to hold it, which is not a
  control."* Leading ROADMAP candidate after S122.
- **🔴 The check-class tally is STILL A SELF-ASSIGNED LABEL.** S122 made it honest about NESTING —
  it did not make one label EARNED. Nothing checks that a check marked `exec` executes anything.
  **Fourth disclosure of this class** (S64 `covers:` digit-tag, S67 `design-significant:` marker,
  S121 and S122 the tally). **Never cite the number as a measurement.** Option B — make it
  machine-derived — is unbuilt and still unpicked; it was option B at the S122 close too.
- **🟡 `vajra init` hangs forever on stdin without EOF.** SECOND occurrence: 10 minutes lost at
  S121, ~20 more at S122, both inside `verify-session-113.sh`. That script now redirects
  `</dev/null` (S122); `verify-session-121.sh` and `-122.sh` do too. **Older scripts do not, and the
  binary itself is unchanged** — the real fix is in `vajra init`, not in each caller.
- **🟡 `verify-session-116.sh` is red by construction** against S121+: the fleet grew to four and the
  every-role-is-read-only invariant was deliberately changed (test renamed, not loosened). Fourth
  session of per-session-snapshot decay; disclosed in a comment, which is not a gate.
- **🟡 The grep-only-verify detector** (S118 candidate A, deferred at S120 in favor of the QA
  specialist agent) — not yet built.
- **🟡 In THIS repo the commit gate is auditable-not-un-forgeable** (L3 `commit_guard: off`; L2
  belt active) · **Compression no-op on real CC** · **Cross-agent breadth 0 code**.

## What Is In Progress
- **S122 DONE (CODE, ACCEPT at cold pass 4).** `verify-session-122.sh` 22/22 exit 0; demo 9 of 9;
  337 lib tests. PR not yet opened.
- **S123 = CODE: fence the `Write`/`Edit` grant** (founder option A of three).
  `prompts/123-task-fence-the-write-grant.md`. **Design-significant: YES** — the choice between
  narrowing the grant and extending the L3 `hook-pre-write.sh` surface needs a `DECISION-007` S123
  addendum before code lands. Steps 1–2 clear S122's own debt first.

## Cost Tracking
- Session 00–30: ~$0.46 cumulative. S36: ~$61.4 · S46: ~$3.84 · S51: ~$1.52 · S52: ~$4.95 · S63: ~$1.27.
- S53–75: ~$0 each. **S76: real but UNKNOWN** (opus-estimate ≤ ~$26.6).
- **S77–91: ~$0 each** (S78 ~$0.055). **S92: $0.2713** · **S97: $1.2758** · **S102: $0.4644** ·
  **S103: $0.6797** (all authoritative). **S104–109: ~$0 each.**
- **S110: $0 (NO-CODE GT).** **S111–S117: $0 metered for build** (subagent tokens roll in unitemized).
- **S118: $4.0911771** authoritative (sonnet, headless `-p`, 1331s).
- **S119: $0 metered** (interactive session; fidelity-reviewer subagent tokens roll in, unitemized).
- **S120: $0** (NO-CODE GT).
- **S121: $0 metered** (interactive; one `fidelity-reviewer` subagent pass ≈56k subagent tokens,
  rolls in unitemized). No paid dogfood run.
- **S122: $0 metered** (interactive). FIVE subagent passes roll in unitemized — one `qa-specialist`
  (~54k) and four `fidelity-reviewer` passes (~80k, ~97k, ~94k, ~105k). No paid dogfood run.
  No paid dogfood run **in this session**; the last one was **S118 ($4.0912, 2026-08-15)** — 4
  sessions / 4 calendar days ago, confirmed live by `vajra next --dogfood-age`. Staleness 🟢.
- Cumulative: **~$83.4 + S76 (unknown, ≤ ~$26.6 opus-estimate) + S111–S122 subagents (unknown, and
  no longer small — S122 alone spent ~430k subagent tokens).**
