# Session 56 — The fidelity GATE (teeth): make the acceptance verdict structurally required — DONE (CODE)

**Branch:** `session-56-fidelity-gate` · **Type:** CODE · **Spend:** ~$0 (bash-only; one subagent call).
**Deliverable:** `scripts/verify-closeout.sh` now **fails closeout** on a missing / present-but-hollow /
REJECT independent review, absent an **un-forgeable founder waiver** — retiring the ability to close a
session by self-certifying. First live act: **the gate blocks S54's real REJECT.**

---

## What shipped

| Piece | Where | Real? |
|---|---|---|
| `check_fidelity_review()` — requires `sessions/session-NN-review.md`, validates a real **in-table** verdict list (≥3 SHIPPED/PARTIAL/NOT-BUILT) + a canonical `**Verdict:** ACCEPT\|REJECT` line, FAILS on missing/incomplete/REJECT | `scripts/verify-closeout.sh` (+ wired into the main flow) | ✅ |
| Un-forgeable waiver `VAJRA_CLOSEOUT_WAIVER=<N>` (session-scoped env, S37 `VAJRA_ALLOW_PUBLISH` model) — **not** a text marker the agent can Write | same | ✅ |
| `--fidelity-only [N]` focused entry (used by verify + the S54 dogfood) | same | ✅ |
| GT write-guard whitelist fix (S55 bundle): allow `sessions/*-review.md` + `reviewer/*` | `scripts/hook-pre-write.sh` (1 case line) | ✅ |
| Canonical verdict-line contract + honest-limit note | `reviewer/SKILL.md` | ✅ |
| `sessions/session-54-review.md` — the gate's first live target (`**Verdict:** REJECT`) | new | ✅ |
| `verify-session-56.sh` **20/20** + `demo-session-56.sh` (7 scenes) | new | ✅ |

**No `src/` change** (bash-only). `cargo test` **140 lib** unchanged. 3 feature commits + closeout.

---

## What S56 must answer (the prompt's 4 questions)

1. **Does closeout now FAIL on missing/incomplete/REJECT — real run, show the red?** ✅ **Yes.** Full
   `verify-closeout.sh` at N=55 (its review lacks a canonical verdict line) went **RED (8 pass, 1 fail)** on
   `fidelity-review-accept` while all 8 legacy discipline checks passed — proof the fidelity step alone now
   gates the close. verify-session-56 cases a–e cover missing/REJECT/hollow→FAIL, complete ACCEPT→PASS.
2. **Is the waiver un-forgeable by the agent?** ✅ **Yes, for the shape that matters — with an honest
   boundary.** A forged in-file `**Human-Waiver:** APPROVED` / `Status: WAIVED` marker does **not** waive
   (proven); only `VAJRA_CLOSEOUT_WAIVER=<N>` in the launch env does, and a cross-session `=99` is inert.
   **Honest limit (recorded):** identical to S37 — the env var is un-forgeable at the *launch-env* boundary
   (founder-run / PreToolUse); if the agent itself invokes the script it could prepend the var inline. Same
   coarseness class as `VAJRA_ALLOW_PUBLISH`. Not overclaimed.
3. **The dogfood — does it block S54's REJECT?** ✅ **Yes, live.** `verify-closeout.sh --fidelity-only 54`
   against the real `sessions/session-54-review.md` (`**Verdict:** REJECT`) → **FIDELITY: FAIL**. Closing S54
   as "the Analyst stage" now requires fixing the Intake/Options/Delta/TASK.md gaps **or** a recorded
   founder waiver. The gate earns its place — it is not ceremony.
4. **On the spine + NO-CODE-safe?** ✅ `--fidelity-only` is a flag on the existing L4 script — **no 8th
   command**, no second store (artifact rides existing `sessions/`). The bundle fix lets a NO-CODE GT write
   its own `-review.md`/`reviewer/*` without the exempt-branch detour.

---

## Fidelity self-review (DECISION-002 — independent cold pass, not self-certified)

A **fresh subagent** was fed only `prompts/56-task-fidelity-gate.md` + the delivery diff at commit
`96a4d90` (summary/STATE withheld; answer withheld; adversarial framing). It independently returned
**ACCEPT — 16 SHIPPED · 4 PARTIAL · 1 NOT-BUILT** over 21 numbered requirements. Full artifact:
[`sessions/session-56-review.md`](session-56-review.md).

**It found two real edges — both fixed after the pass (commit `2dd0f75`), not buried:**
- **Fakest green:** the table check counted verdict *words anywhere*, a soft proxy — the exact disease the
  gate exists to kill. **Fixed:** now counts tokens only inside table rows; a prose-only ACCEPT is BLOCKED.
- **Overclaim:** "self-certification retired" was too strong — the gate makes the *waiver* un-forgeable but
  a builder can still author its own `**Verdict:** ACCEPT`. **Corrected in `reviewer/SKILL.md`:** verdict
  *authorship* independence is procedural (the cold subagent), not structural — named as the next hardening.

### What I did NOT build (plainly)
- **Structural verdict-authorship independence.** The gate enforces the review's *shape* + the *waiver's*
  authorship, but not that the ACCEPT came from an independent pass. Today that independence is procedure
  (the cold subagent), demonstrated but not code-enforced. → **S57 candidate B.**
- **`vajra init` propagation.** The gate protects only Vajra's own repo; scaffolded projects don't inherit
  it yet (the pre-authorized split). → **S57 candidate A (top).**
- **The fakest green here:** now that the table proxy is closed, it's the ACCEPT-authorship gap above —
  the gate looks like it "requires independence" but structurally requires only *shape + a real REJECT/waiver*.

---

## 3 ranked candidates for S57

### 🥇 A — Propagate the gate + reviewer into `vajra init` (the pre-authorized split)
- **Goal:** every scaffolded project inherits `check_fidelity_review` in its `verify-closeout.sh` +
  `reviewer/SKILL.md` (byte-identical via `include_str!`, the S22/S28/S29 pattern).
- **Why pick this:** the S36-class lesson — a guard built but not scaffolded leaks in real projects. Without
  this the teeth are Vajra-repo-only. Mechanical, bounded, completes the propagation arc.
- **Key risk:** `verify-closeout.sh` is scaffold-generated text, not `include_str!`'d today — propagation
  may need a template refactor; could split (S57 does the gate, S58 the reviewer skill).

### 🥈 B — Structural verdict-authorship independence (attest the cold pass)
- **Goal:** close this session's honest #1 limit — bind an ACCEPT to proof it came from an independent cold
  pass (e.g. an attested hash of the withheld inputs), so a builder can't self-author ACCEPT.
- **Why pick this:** makes the gate's independence *structural*, not procedural — the deepest "make
  governance true" move DECISION-002 points at.
- **Key risk:** hard to make truly un-forgeable when the agent shares the environment; risks ceremony if the
  attestation is itself forgeable. Design-heavy.

### 🥉 C — The cross-stage delta ledger (record the verdicts)
- **Goal:** commit each stage's acceptance verdict + +/~/− deltas into a git-tied, hash-chained record →
  tamper-*evident*; upgrades the Analyst's `Status:` marker from claim to evidence.
- **Why pick this:** the DECISION-002 #2; it now has something worth recording (independent verdicts).
- **Key risk:** the headline moat but still 0 code; composes *after* fidelity, so it's correctly #3.

*Carry: cargo/npm/pytest never fold on real CC (S33/S41); vajra receipt overstates ~8× (use
`total_cost_usd`); dogfood 🟡 aging (no paid `vajra claude` since S52).*
