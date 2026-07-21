# Session 87 — Fill S76's unfilled Execution shas — summary

**Type:** CODE (docs-only) — one historical-record fix (`prompts/76-task-dogfood-ride-along.md`),
plus the two required verify/demo scripts. No `src/` change, no new command, no new
`CONSTRAINTS.yaml` key. Founder pick B at S86 close (oldest standing debt, 9 sessions overdue).

## Headline

`prompts/76-task-dogfood-ride-along.md`'s `## Execution` section carried 4 unfilled `<sha>`
placeholders since before the S81 closeout-gate existed to catch them. Matched each Plan step to
its real landing commit by reading every candidate commit's actual diff — **not** the "(N/4)"
commit-message numbering, which the prompt itself warned is scrambled relative to Plan-step order
(confirmed: e.g. the commit labeled "(4/4)" is actually step 2's evidence, not step 4's).

**A real, unplanned side effect surfaced live while proving AC3**, not guessed at: filling in
S76's shas retroactively un-attests S76's OWN review. S86's `canonical_inputs_sha` hashes the
prompt file's live on-disk bytes, not a snapshot from review time — so this legitimate fix flips
S76's Reviewer/Releaser dimensions from PASSED to ABSENT, even though this session's actual target
(Coder) correctly flips ABSENT to PASSED. Disclosed immediately, not hidden, and not fixed here
(out of scope — a strong S88 candidate).

**The independent cold review caught a real problem in this session's own proof scripts** (not the
core fix) — REJECT on pass 1, two genuine bugs (a demo that silently stopped proving what it
claimed once its own commit landed; a scope check that was structurally incapable of ever failing).
Both fixed in-session, adversarially re-verified by the same reviewer (not self-certified): ACCEPT
on pass 2. Mirrors the S67 two-pass house pattern.

## What shipped

- **`prompts/76-task-dogfood-ride-along.md`'s `## Execution`** — 4 real shas, content-matched:
  - step 1 (prepare: harness + task + measurement checklist) → `16d30aa`
  - step 2 (capture live run artifacts) → `08e4718` (the two run receipts — the only committed
    evidence of the live run; JSONL/hook logs are gitignored-local)
  - step 3 (derive numbers from artifacts) → `9f0cab0` (the dogfood report's gates-fired table,
    cost comparison, obedience note)
  - step 4 (write report + scripts + summary + review + attestation) → `9f0cab0` also (report/
    summary/review/attestation are the same commit as step 3's output) — disclosed to also span
    `76190f1` (the verify/demo scripts named in the same Plan step landed in a separate commit),
    per AC4 rather than forcing an artificial 1:1.
- **`scripts/verify-session-87.sh`** — 5 checks: no placeholder remains, `--check-exec 76` READY,
  `--stations 76` Coder PASSED, scope held (whole-tree diff, adversarially proven to actually
  catch an out-of-scope change), and the disclosed regression reproduces live.
- **`scripts/demo-session-87.sh`** — before/after against `main` (the real pre-S87 baseline); all
  4 required `demo:<element>` markers.

## Proof

- `vajra next --check-exec 76`: `NOT READY` → `READY`, captured live before/after both passes.
- `vajra next --stations 76`: Coder `ABSENT` → `PASSED`; overall station count 6/8 → 5/8 (Coder
  gains, Reviewer + Releaser lose — the disclosed regression, not a partial fix).
- `bash scripts/verify-closeout.sh --attest-only 76`: `BLOCK: attestation MISMATCH` (claimed
  `4b87434c…` vs. recomputed `8a5d84a6…` after the final commit) — the regression, reproduced live,
  not asserted.
- `bash scripts/verify-session-87.sh` → **5/5 PASS**. `bash scripts/demo-session-87.sh` → exit 0,
  working tree clean after (trap-based restore, adversarially confirmed byte-identical).
- Scope: `git diff --name-only main..HEAD` = exactly 3 files (the docs fix + the 2 required
  verify/demo scripts). No `src/`, no `Cargo.toml`/`Cargo.lock`, no `ROADMAP.md` change.

## Fidelity map (prompt requirement → delivery)

| # | Requirement | Verdict | Evidence |
|---|-------------|---------|----------|
| 1 | Every Plan step matched to its real landing commit, no `<sha>` left | **SHIPPED** | Independent cold reviewer read all 6 candidate diffs itself, confirmed the mapping avoids the "(N/4)" trap the prompt warned about. |
| 2 | `vajra next --check-exec 76` → READY, live | **SHIPPED** | Reproduced fresh both review passes. |
| 3 | `vajra next --stations 76` Coder ABSENT → PASSED, proven live before/after | **SHIPPED** | Pass-1 REJECT correctly caught the delivered demo script's proof of this was broken (identical before/after due to a `HEAD~1` bug); fixed and adversarially re-verified live on pass 2. |
| 4 | Multi-commit span disclosed, not forced 1:1 | **SHIPPED** | Verified accurate against both commits' real contents by the independent reviewer. |
| 5 | No other file changes | **SHIPPED** | `src/`/`ROADMAP.md` untouched; footprint = docs fix + the 2 CONSTRAINTS-required scripts, disclosed as such, scope-check adversarially proven sound (not tautological) on pass 2. |

**NOT built:** nothing from the prompt was skipped. `ROADMAP.md`'s stale table and any dogfood
work were explicitly out of scope and untouched.

## Honest limits (fakest green, reviewer-sharpened)

- **Pass 1's actual finding, stated plainly:** this session's first cut of its OWN verify/demo
  scripts exited 0 and printed all-green while NOT actually proving what they claimed for AC3
  (identical before/after output) and AC5 (a scope check that could never fail). The letter of
  "the script exits 0" was satisfied; the substance it claimed to prove was not. This is the exact
  "green that looks done but is hollow" class the constitution's self-review question 8 asks about
  — caught by an independent pass, not self-caught, which is precisely why DECISION-002 requires
  one.
- **The disclosed Reviewer/Releaser regression is a real, structural gap in S86's mechanism**, not
  specific to this session: `canonical_inputs_sha` hashes the prompt file's CURRENT bytes, so any
  future edit to ANY historical prompt file will retroactively un-attest that session's review.
  This will recur every time a historical prompt is legitimately touched (a typo fix, a sha
  backfill like this one) unless S88+ fixes it — e.g. hashing the prompt content as of the review's
  own commit rather than the live working tree.
- **The tension between the prompt's literal "one file" / "no other file changes" framing (stated
  3×) and the actual 3-file footprint** is real, not hidden — `CONSTRAINTS.yaml#verify.
  required_for_done` structurally requires a verify+demo script per session, which the S87 prompt's
  own guardrails didn't anticipate when it wrote "single-file, docs-only fix." Both cold-review
  passes read this as acceptable (session-scaffolding, not scope creep into the fix), but a future
  prompt for a genuinely single-artifact change should account for this contract up front.

## Attestation

- **Review-Inputs-SHA:** `d2e4c1ace116ad353303d41f60fb3eb826c7e34c4f064a2c31c7cbae06409a12`
  (`sha256(prompt ‖ delivery-diff)`; delivery diff = `scripts/verify-session-87.sh` +
  `scripts/demo-session-87.sh`, per `scripts/verify-closeout.sh --inputs-sha 87` — the exclude list
  structurally omits `prompts/`, so the `prompts/76-...md` fix itself is not part of the hashed
  diff, only the scripts are). See `sessions/session-87-review.md` for the independent two-pass
  cold verdict (pass 1 REJECT → in-session fix → pass 2 ACCEPT).

## Coder-gate execution (plan step → landing commit)

- step 1 (read S76's Plan + all 6 diffs, match by substance) → `f7f14e8`
- step 2 (edit S76's `## Execution` with real shas) → `f7f14e8`
- step 3 (run `--check-exec`/`--stations` before/after live, record output) → `5346920` initial,
  corrected + adversarially proven at `863672b` (the pass-1 REJECT fix)

## 3 ranked S88 candidates

- **🥇 A (recommended) — fix S86's `canonical_inputs_sha` to hash a review-time snapshot, not live
  bytes.** This session just proved the gap is real and will recur: EVERY future edit to a
  historical prompt file un-attests that session's review. Fix: hash the prompt file's content as
  of the commit where `--inputs-sha` was actually run (or as of the review file's own commit),
  not the live working tree. Key risk: touches the same shared hash preimage both
  `verify-closeout.sh` and `src/stations/mod.rs` depend on — a two-sided change needs both sides
  updated in lockstep, and a wrong fix could silently break the 16/20 real-history reproduction
  S86 already validated.
- **🥈 B — the dogfood refresh (still founder-un-parkable).** Stale since S76 — now **11 sessions
  (S77-S87) / 18+ calendar days**. Escalated 🔴 at S85, not picked at S86, not picked here either
  (S87 was pre-committed to the sha fix). Key risk: real spend; keeps aging the longer it's
  deferred, and every session it's not picked, the "measured as experience" gap widens further.
- **🥉 C — fix `ROADMAP.md`'s stale "Where We Are" table.** Quick, cosmetic, concrete evidence for
  the standing readable-roadmap-one-pager pain. Key risk: none material — lowest-stakes of the
  three, deferred 3 sessions running now.
