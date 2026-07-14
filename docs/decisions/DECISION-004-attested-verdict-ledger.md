# DECISION-004 — The attested-verdict delta ledger: a derived, hash-chained view (no new store)

**Date:** 2026-07-14 · **Session:** 59 · **Status:** ACCEPTED
**Relates to:** DECISION-003 (verdict-input attestation) — the attestation is this ledger's payload;
DECISION-002 (fidelity over discipline); memory `feedback-distill-no-drift`, `feedback-map-concepts-to-vajra`.

---

## Context — the headline moat was 0 code

The differentiator pitch is a **cross-agent, tamper-evident record of what each stage did**. Until now that
record was **0 code** (STATE.md 🔴). S58 gave it its first *trustworthy* content: an independent, attested
acceptance verdict per session (`**Verdict:**` + `**Review-Inputs-SHA:**` in `sessions/session-NN-review.md`),
not a self-report. What was missing: a **cross-session** artifact that binds those per-session verdicts into
one ordered, verifiable chain — turning a per-session *claim* into cross-session *evidence*.

## The decision — a DERIVED view, not a new store

**Map-to-Vajra first.** The source records already exist:

- `sessions/session-NN-review.md` carries the **verdict** + the **`Review-Inputs-SHA`** attestation.
- **git** carries **durability + order** (append-only history, content-addressed blobs).

So the ledger is a **derived, regenerable view** computed on demand — **not** a new append-only file.
A hand-maintained `LEDGER.md`-as-source-of-truth was **rejected**: it would be a *second* source to keep in
sync with the reviews (drift risk), violating `feedback-distill-no-drift` ("generate derived copies, never
hand-maintain them"). No new store; no ASK needed (the derived view was sufficient).

### The chain

For each session with a review, in ascending order:

```
record_hash(N) = sha256( prior_hash \0 N \0 verdict \0 input_sha )
prior_hash(first) = LEDGER_GENESIS   # 64 zeros
```

The last `record_hash` is the **chain head** — a single 64-hex fingerprint of the entire ordered
verdict+attestation history. Editing any *past* verdict changes that record and cascades to every downstream
record → the head moves.

### Surface (no 8th command, no src change)

Two flags on `scripts/verify-closeout.sh` (the closeout-gate surface):

- `--ledger` — build + print the glanceable table (SESS · VERDICT · ATTESTED · RECORD-HASH) + head.
- `--ledger-verify` — recompute the chain over **committed** sessions from the **worktree** and from the
  **blobs at HEAD**; the first record that differs is a tampered / edited / deleted past review (exit 1).

The gate is `include_str!`'d into `vajra init` (S57), so this propagates into every scaffolded project
**byte-identically with zero `src/` change** — the same lever S57/S58 used. Verdict/sha extraction uses the
**same patterns as the fidelity gate** (`check_fidelity_review` / `check_review_attestation`) — hand-synced
and byte-identical today, **not yet a single shared helper** (a future refactor; noted so the claim isn't
overstated).

## What the chain proves — and does NOT (same honesty bar as S58)

- **Tamper-EVIDENT (proven):** any edit to a committed past verdict/attestation makes the worktree chain
  stop matching the committed chain; `--ledger-verify` detects it and names the first divergent session.
  git independently shows the file diff. Verified live: flipping S54 `REJECT→ACCEPT` moves the head and is
  reported as `S54`.
- **NOT tamper-PROOF:** a determined in-repo editor can flip a verdict **and** recompute every downstream
  `record_hash` **and** rewrite committed history (force-push). Nothing here is an **out-of-band anchor** —
  the chain lives in the same repo it protects. Closing that gap needs a signer / external notarization
  (**S59-C**).
- **Scope honesty:** a review with no canonical `**Verdict:**` line records `verdict=NONE`; an un-attested
  review records `attested=no`. The ledger surfaces the pre-canonical S55 review honestly rather than
  papering over it. Attestation exists only from S58 onward — the `ATTESTED` column shows that truthfully.

## Consequence

Retires STATE.md 🔴 "the moat's headline (cross-agent tamper-evident ledger) is 0 code" → downgraded to a
**bounded, honestly-scoped first slice**: a derived hash-chained ledger that is tamper-*evident*, not
tamper-*proof*. Wiring `--ledger-verify` into the mandatory closeout run (vs. a focused entry point) and the
out-of-band signer are follow-ups (S59-C / later).
