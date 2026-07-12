# Session 58 — Structural verdict-authorship independence (make the ACCEPT un-forgeable)

> **Status:** APPROVED (founder standing "all approved") — the recommended S57 candidate A. Closes the
> standing honest #1 carried since S56: the fidelity gate makes the *waiver* un-forgeable and blocks
> missing/hollow/REJECT, but a builder can still author its own `**Verdict:** ACCEPT`. **Founder may
> reprioritize** to S58-B (the cross-stage delta ledger) or S58-C (complete the S54 Analyst) in a new chat —
> 3 ranked candidates are in `sessions/session-57-summary.md`.

## Type
- **CODE.** Max **2** assumptions · **2** retries · **~2h** · **1** story · **new chat** · approval token
  before any commit. (S60 is the next mandatory NO-CODE ground-truth.)

## Goal
Make an ACCEPT verdict **structurally attributable to an independent cold pass**, not just procedurally so.
Today `verify-closeout.sh` proves the review's *shape* (in-table verdicts + a canonical `**Verdict:**` line)
and the *waiver's* authorship (env var) — but **not the verdict's authorship**: the builder can hand-write
its own ACCEPT. Bind the ACCEPT to un-forgeable evidence that the reviewer actually consumed the withheld
cold inputs (the prompt + the delivery diff) — so a self-authored ACCEPT fails the gate.

## The job
1. **Design the attestation (write it down first).** Decide the smallest un-forgeable proof that a cold pass
   ran. Candidate shape: the review must carry a `**Review-Inputs-SHA:** <hash>` line, where the hash is
   over the exact cold inputs (contract prompt + the delivery diff, canonically normalized). The gate
   recomputes the hash from the repo and **fails if it does not match** — so an ACCEPT with no/incorrect
   attestation is rejected. **Map it onto an existing mechanism first** (the review artifact + the gate); do
   NOT add a new command, store, or file type. If the honest conclusion is that no in-repo hash can be
   un-forgeable by the same agent (the builder could recompute it), **say so plainly and record what the
   attestation *does* raise the bar against** — partial, honest hardening beats fake tamper-evidence.
2. **Ship the gate check.** Extend `check_fidelity_review` (or a sibling `check_review_attestation`) in
   `scripts/verify-closeout.sh` to require + verify the attestation on an ACCEPT, behind the same
   `waiver_ok` escape hatch. Keep `--fidelity-only`. Keep every S56 behavior green.
3. **Propagate + dogfood.** The scaffolded `verify-closeout.sh` (S57 `include_str!`) inherits it for free —
   confirm with a real `vajra init`. Update `reviewer/SKILL.md` so the cold pass **emits** the attestation.
   Run the S58 cold review with a real attestation and prove the gate accepts it and rejects a forged one.

## Deliverables
- The attestation design recorded (in `reviewer/SKILL.md` and/or a short `docs/decisions/` note) — what is
  hashed, what it does and does NOT prove, why it is (or is not) un-forgeable.
- `scripts/verify-closeout.sh` gate extension + the scaffolded copy inheriting it (byte-identical, S57).
- `scripts/verify-session-58.sh` (exits 0): a real attestation passes, a missing/forged one fails ACCEPT,
  the waiver still clears, and S56's whole matrix still holds — driven live, not a grep.
- `scripts/demo-session-58.sh` + interactive HTML when asked.
- `sessions/session-58-summary.md` + the independent cold `sessions/session-58-review.md` (now carrying a
  real attestation) + 3 ranked S59 candidates.

## Acceptance (what S58 must answer)
1. Does an ACCEPT with a **missing or forged** input-attestation now FAIL the gate (real run, not a mock)?
2. Does a genuine cold pass's attestation PASS — and is the mechanism honestly described (what it proves vs
   not; is it actually un-forgeable, or only bar-raising)?
3. Byte-identical / drift-free between Vajra's own gate and the scaffolded one (one source)?
4. On the spine (no 8th command, no second store), `cargo test` green + clippy clean?

## Guardrails
- **Do not overclaim tamper-evidence.** If the same agent can recompute the hash, the attestation raises the
  bar but is not un-forgeable — say exactly that. The whole point of this arc is honesty about what is real.
- Map onto the existing review-artifact + gate; if tempted to add a command/store/file type, **ASK** first.
- Darshan every human reply · Varta against the live `.ai/`.
- **Eat the dog food:** S58's own closeout must pass its own (now attestation-bearing) gate.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` An input-attestation on the fidelity review; the gate verifies verdict *authorship*, not just shape.
- `~` Extends the S55→S56→S57 fidelity arc (brain → teeth → propagated) with structural independence.
- `-` Retires the standing honest #1 "verdict authorship is procedural, not structural" — or, if it proves
  only bar-raising, downgrades it from open gap to a documented, bounded limit.
