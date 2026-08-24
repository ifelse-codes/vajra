# Session 130 — Ground Truth (NO-CODE · audits S126–S129)

**Date:** 2026-08-24
**Session type:** MANDATORY GT (`130 % 5 == 0`)
**Scope:** S126 (fleet complete) · S127 (Advice gate) · S128 (first contact) · S129 (one source for scaffold)
**Produced by:** interactive GT session, no code authored — 4 read-only research subagents dispatched for
parallel evidence-gathering, every load-bearing claim they returned was independently re-checked with
direct `git`/`grep`/`Read` access before being used here.

---

## Overall Verdict

**PARTIAL PASS.**

Both mandated product-facing audits ran live and are GREEN. Discipline held across S126–S129 (zero
constraint violations, independently re-verified via git). But three things keep this from a clean PASS:
the fleet is trending toward pure decoration (handoffs 5→3→1→0, falling every session), VISION.md has
been quietly wrong for a month in the direction nobody watches (understating progress, not overclaiming),
and a second gate — `parse_delta()` in the Analyst — carries the exact same bug class the Planner was
just caught with, sitting live and untested against trigger conditions that already exist in this repo's
own prompt files.

| # | Audit | Verdict | One-line finding |
|---|---|---|---|
| 1 | `vision_alignment` | 🟡 | VISION.md banner (lines 5, 21) is a month stale — understates real progress (says Rung 1, Rung 2 passed at S103; says package ~0%, v0.1 shipped S108) |
| 2 | `roadmap_alignment` | 🟡 | 2026-09-15 backstop already moot (v0.1 shipped early); Rung 3 never attempted since S103; last 3 sessions chose internal derivation work over F2/dogfood |
| 3 | `state_drift` | 🟢 | STATE.md's "PR not yet opened" line is the known, self-disclosed pre-merge snapshot pattern (S65/S125) — stale by construction, not a new drift |
| 4 | `knowledge_staleness` | 🟡→🔴 trending | 1,061 lines / 290KB, +65% since S120 (642 lines); §10 append-only log is now ~74% of the file, worse than when S125 diagnosed the exact same problem |
| 5 | `constraint_violation_review` | 🟢 | Zero violations S126–S129, independently re-verified via `git show --stat` (no >3-file src commits) and `git log -p` (no real `--no-verify` use) |
| 6 | `constitution_review` | 🟡 | `.ai/AGENTS.md:118` has asserted "convention until Vajra enforces it" for 100+ sessions — false since S26, when `hook-session-guard.sh` made it real |
| 7 | `cost_review` | 🟡 | S129 alone rolled in ~267k unmetered subagent tokens (113k+154k, two `fidelity-reviewer` passes) — largest unmetered review spend on record, and the trend is up, not down |
| 8 | `dogfood_check` | 🟡 | Real paid work ran at S124, not fabricated — but "Vajra-on-Claude is satisfying" is unmeasured for 5 sessions running |
| 9 | `pipeline_advance_check` | 🟢 shape / 🟡 substance | K=8/8 for S126–S129 (live-derived, re-run this session) — but fleet handoffs consumed alongside K are 5→3→1→0, and QA/Demo-er stations are inherently `[static — not live-green]` for any past session re-checked post-merge (reproduced live this session, see §Pipeline below) |
| 10 | `dogfood_staleness` | 🟡 | `vajra next --dogfood-age`: S124, 2026-08-20, 5 sessions / 4 days since. Agrees with STATE.md |
| 11 | `stranger_check` | 🟢 **RAN LIVE** | 21/21 PASS, real empty dir, real binary |
| 12 | `scaffold_drift_check` | 🟢 **RAN LIVE** | 17/17 PASS, real empty dir, real binary — GREEN is scoped to 3 derived lists only, by its own printed disclosure |

**Ledger:** `verify-closeout.sh --ledger-verify` → **INTACT** (`93179e15…`, committed == worktree, re-run
live this session).

---

## 1. THIS GT'S CORE MANDATE — did the two product-facing audits actually run?

**Yes, both, live, for the first time ever.** Full pasted tallies:

```
=== stranger-check summary ===
  checks passed    21
  checks failed    0
  GREEN — a stranger's first ten minutes work.

=== scaffold-drift: 17 passed, 0 failed ===
GREEN — across the THREE LISTS THIS CHECK COVERS, a stranger is governed by
        13 of this repo's 13 binding rules, 10 of its 12 ground-truth audits and
        7 of its 7 drift axes, every difference declared with a reason.
```

`scaffold-drift.sh`'s own GREEN line states its jurisdiction unprompted: it names `TPL_CONSTRAINTS`'
undeclared drift (below) as **outside what this GREEN can ever catch**. That is honest instrumentation,
not a false all-clear.

**What it costs when a gate is never run, reproduced live this session, not just cited:** re-running
`scripts/verify-session-129.sh` post-merge now returns **RED (11 pass, 1 fail)** —
`no-undeclared-shipped-file-change` fails because `git merge-base main HEAD` resolves differently once
`main` has absorbed the branch. This is **not a new bug** — the script's own comment (line 99-100)
predicted it: *"a later session nesting it cumulatively will see RED, correctly."* It is offered here as
concrete, reproduced proof of why `--stations` correctly labels QA/Demo-er `[static — not live-green]`
for any past session: **a session's own verify script cannot be meaningfully re-run as a live gate once
merged — the merge-base itself is the thing that moved.** `vajra check` reflects the same fact plainly:
9/11, with `verify: script passes` and `varta: matches render` both FAIL at session start (expected,
not a regression — this session hasn't run `--render` yet).

---

## 2. Fleet: is it a fleet, or a roster? (Lens 1)

**Roster, and the trend is getting worse, not better.**

| Session | Governed handoffs dispatched | Evidence |
|---|---|---|
| S126 | **5** — requirements-analyst, design-advisor, implementation-advisor, demo-producer, release-coordinator | `.ai/handoffs/session-126-*.md` × 5 |
| S127 | **3** — fidelity-reviewer, implementation-advisor, demo-producer | `.ai/handoffs/session-127-*.md` × 3 |
| S128 | **1** — fidelity-reviewer | `.ai/handoffs/session-128-*.md` × 1 |
| S129 | **0** — no advisor dispatched before building | `vajra next --stations 129` prints no `fleet:` line at all (confirmed by re-running it live — every other session's output includes one) |

The one gate that consumes a handoff (the Advice gate, S127) proves ANSWERED, never OBEYED — and its
own ledger already had 4 factually-wrong `obeyed:` labels caught only by a cold reader (S127 residual,
still true). Layered on top: `src/cli/next.rs:283` hardcodes the handoff's provenance field to the
literal string `"claude-code-subagent"` — it is **never derived from any actual dispatch evidence**, so
even the 9 handoffs that do exist across S126-128 carry an unverifiable provenance claim. This is the
real substance behind S131 candidate B (F2) below: the fleet's own "proof of use" field is not proof of
anything.

**Verdict: nine roles is a roster.** Two sessions in a row (S128, S129) reached for at most one advisor;
S129 reached for zero. The founder's S125 gate — "done AND working" — is still open, and the working
half is now moving in the wrong direction.

---

## 3. Cold readers keep finding what the builder cannot. Is one pass at close the right shape? (Lens 2)

**No — the evidence this session says mid-build cold reads would pay for themselves.**

S129 needed **two** independent cold passes to close: pass 1 caught `drift_axes` (a third hand-typed
fork, 6 vs 7, three lines above the fix the session had just written); pass 2 caught `TPL_CONSTRAINTS`
(a fourth fork, two keys already wrong in a live stranger's file). **Both were inside the blast radius of
the very fix the session shipped** — not adjacent scope, the same lines.

This session adds a third data point of the identical shape, found the same way (a fresh, focused,
read-only pass): the Analyst's `parse_delta()` carries the Planner's exact bug class (§5 below), sitting
unfound since S61 — nine sessions longer than the Planner bug lived. **Three for three: every time a
cold, narrow, read-only pass has looked at a hand-written parser/list in this repo, it has found a real
defect the builder(s) missed**, and in two of three cases the defect was already live and silently wrong,
not merely latent.

**Recommendation:** the current ritual (one cold pass, only at close, only fed the prompt + diff) is
necessary but not sufficient. A cheap, low-risk addition: run one narrow, read-only cold pass **mid-build**
on the touched parsing/gate logic specifically — not a second full fidelity review, just a targeted
"does this string-match logic have the S129/S130 failure shape" check — before the session's own tests
get written around whatever the builder already believes is correct.

---

## 4. The fourth fork — still refused, still real, checked again

Re-verified directly against live source, not just cited from STATE.md:

```
TPL_CONSTRAINTS (src/cli/init.rs:737-741)     .ai/CONSTRAINTS.yaml (live, :419-424)
commit:                                        commit:
  autonomous: false                              autonomous: false
  require_user_approval: true                    require_user_approval: true
  approval_tokens: [...]                         approval_tokens: [...]
  (— absent —)                                   forbid_skip_hooks: true
  (— absent —)                                   forbid_force_push_to: [main, master]
```

```
communication.forbid, scaffold: [greetings, apologies, filler, trailing-summaries]   (4 of 5)
communication.forbid, live:     [greetings, apologies, filler, narration-of-thinking, trailing-summaries]
```

Both drifted keys named at S129 are **still drifted, unfixed, exactly as described.** `forbid_skip_hooks`
is still absent while `src/varta/render.rs:84` still reads it — a stranger's Varta render still silently
drops that governance line. **Refusing to hand-patch this was still the right call** (a two-line patch
would reintroduce the exact hand-typed-twin pattern S129 spent the session eliminating for three other
lists) — but this is the second GT in a row this has been named without a fix landing. Deferring a third
time would cross from "principled refusal" into "convenience." It is ranked candidate B below, not A,
because the evidence in §2 makes F2 the higher-leverage pick — but it should not slip a third session.

---

## 5. Which other registered-but-never-run gate is wrong right now?

**`parse_delta()` in `src/analyst/mod.rs:318`** — the same bug class as the Planner, confirmed by direct
read of the source, not taken on the research agent's word alone:

```rust
// src/analyst/mod.rs:318
in_delta = heading.contains("delta");
```

Any heading — including the prompt's own `# Session NN — ...` title line — that merely *contains* the
substring "delta" opens the "inside `## Delta`" parse window, exactly the failure shape that made the
Planner silently miscount plan steps as acceptance criteria for every session since its heading changed.
Unlike the Coder's and the now-fixed Planner's heading matchers (first-token-exact), this one is an
unguarded substring match, and it is **not hypothetical** — the trigger condition already exists twice in
this repo's own prompt corpus:

- `prompts/61-task-analyst-generate-delta.md:1` — `# Session 61 — Analyst: make the Generate + **Delta** half REAL …`
- `prompts/59-task-attested-verdict-ledger.md:1` — `# Session 59 — The cross-stage **delta** ledger …`

Both happened to close the false window cleanly (the line right after the H1 is a `>` blockquote, not a
`-`/`*` bullet, so `delta_bullet_description` never matched inside the accidental window) — **luck of
formatting, not correctness.** No test in `src/analyst/mod.rs:690-716` feeds a non-Delta heading
containing "delta"; the exact case sitting live in this repo's own history is untested. This has **not
been observed to produce a wrong verdict** (unlike the Planner, which demonstrably did) — it is a live,
armed landmine, not yet triggered. Named here so it does not take nine more sessions to find by accident.

---

## 6. Adoption — stated, not guessed

```
stars:      0
forks:      0
open issues: 0   (gh api, filtered for pull_request:null — confirmed no real issue exists)
crates.io downloads: 19  (recent_downloads: 19 — identical to S128/S129's figure)
```

**Unchanged since S128.** Two sessions improved what a stranger receives (S128 first contact, S129 one
source); neither has been reached by anyone outside this repo. A working front door and a correct
rulebook are preconditions for adoption, not evidence of it — consistent with S128/S129's own framing,
re-confirmed with a live `gh` query rather than repeated from memory.

---

## 7. Dogfood

`vajra next --dogfood-age`, run live:

```
last dogfood session : 124
date (git-derived)   : 2026-08-20
cost (authoritative)  : $3.2985
sessions since        : 5 (S124 → current S129)
calendar days since   : 4 day(s)
```

Five sessions of machinery (S126-S130) since the last paid run. Any claim that "Vajra-on-Claude is
satisfying" is unmeasured by definition over that span — consistent with S129's own framing.

---

## 8. Cost

- S126: **$4.4482 authoritative** (5 headless dispatches).
- S127-S129: **$0 metered** (interactive), but S129 alone carried **~267k subagent tokens** (113k+154k,
  two `fidelity-reviewer` cold passes) unitemized — explicitly named by S129's own STATE.md entry as
  "the largest un-metered review spend of any session so far." This session (S130) adds a comparable
  order of magnitude: 4 parallel research subagents, ~266k subagent tokens combined, again $0 metered.
- **The blind spot is structural and growing, not shrinking:** as cold-review discipline increases (§3
  argues for MORE of it), the gap between "$ ledger" and "real tokens spent reviewing" widens further.
  Cumulative estimate remains what STATE.md already carries (~$91.2 + unknowns); no correction needed
  to the number itself, but the *trend* in the blind spot is worth a named line.

---

## 9. Meta-check — did this GT's own mechanism miss a kind of drift?

**Yes, and it is the exact shape of the trap the constitution names.** Every required audit here still
measures either *this repo's own discipline* (constraint/constitution/state/knowledge/cost) or, for the
first time as of S128/S129, *the product a stranger receives* (stranger_check, scaffold_drift_check). No
required audit measures **whether a governed handoff, once it exists, changes what gets built** — the
Advice gate proves ANSWERED, never OBEYED (named at S127, still true, still unaudited by any required
check). The pipeline counter (S25→S60→S74) closed the "is the pipeline advancing" gap; **the equivalent
gap for the fleet — "is a handoff's advice actually followed, measured, not asserted" — has never been
built**, and §2's declining-to-zero handoff count means it is now urgent, not theoretical. Naming it here
so it does not take four more GTs to become a required audit, the way the pipeline counter did.

---

## 10. Ranked candidates for S131

**A — F2, the dispatch receipt: replace the hardcoded `"claude-code-subagent"` provenance in
`src/cli/next.rs:283` with real evidence a different actor produced the handoff.** Ranked first because
it is the direct answer to this session's lens 1: the fleet's own "proof of use" field currently proves
nothing, and the roadmap independently names it "the fleet's working proof." Bounded scope (one function,
one field), unlike a fresh KEY-SET inventory.

**B — the fourth fork: bring the rest of `TPL_CONSTRAINTS` under one source, with a KEY-SET inventory
(not a fourth hand-typed list comparison).** Still real, still user-facing (a stranger's commit-guard
governance silently drops two lines), refused once already with good reason — but this is the second GT
naming it unfixed. Should not slip to a third.

**C — a paid dogfood ride-along from a FRESH SCAFFOLD**, not this repo. Every paid dogfood in 130
sessions has run inside the repo that builds Vajra; dogfood is 5 sessions / 4 days stale, not critical
yet but the only way to test whether the S128/S129 first-contact fixes hold under real, unscripted use.

**Not ranked, but flagged for the founder's immediate call at closeout** (too small to consume an S131
slot, arguably qualifies for the AGENTS.md `session-NN-enforcement` closeout-branch exemption used for
authorized hardening):
- Harden `parse_delta()` (§5) — one-line fix + one regression test, mirroring the Planner's own fix shape.
- Correct `VISION.md:5,21` (Rung 1→2 passed; package ~0%→installable) — a stale spec misdirects planning
  under the S118 rule that VISION is the target spec.
- Correct `.ai/AGENTS.md:118` — the session-per-chat rule has been hook-enforced since S26, not "convention."

---

## Guardrails honored

- **NO-CODE.** No `src/` edits this session. Live commands run (`stranger-check.sh`, `scaffold-drift.sh`,
  `vajra check`, `vajra next --stations/--dogfood-age`, `verify-closeout.sh --ledger-verify`,
  `verify-session-129.sh`) are read-only diagnostics — none mutated tracked source.
- No commits on `session-130-ground-truth`. Closeout rides `session-130-closeout`.
- Findings answered with evidence (live command output, direct source reads, independently re-verified
  git history) — not the roster, not self-report from research subagents taken on faith.
