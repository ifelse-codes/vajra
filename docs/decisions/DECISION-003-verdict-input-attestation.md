# DECISION-003 — Verdict-input attestation: bind an ACCEPT to the delivery it reviewed

**Date:** 2026-07-13 · **Session:** 58 · **Status:** ACCEPTED
**Relates to:** DECISION-002 (fidelity over discipline) — this hardens *one* honest gap in the fidelity gate:
verdict **authorship** independence.

---

## Context — the standing honest #1

S56 built the fidelity gate's *teeth* (`scripts/verify-closeout.sh` fails closeout on a missing / hollow /
REJECT review) and S57 propagated it into `vajra init`. Both carried the same admitted limit:

> The gate enforces the review's **shape** (an in-table verdict list + a canonical `**Verdict:**` line) and
> the **waiver's** authorship (an env var the agent can't write) — but **not the verdict's authorship.**
> A builder can still hand-write its own `**Verdict:** ACCEPT`.

Verdict independence rode entirely on **procedure** (DECISION-002's cold-subagent pass), with nothing in code
tying the ACCEPT to evidence that a cold pass actually consumed the withheld inputs.

## The decision

Add an **input-attestation** to every ACCEPT review and verify it in the gate. The review must carry one line:

```
**Review-Inputs-SHA:** <64-hex sha256>
```

The hash is over the exact **cold inputs** the reviewer is fed:

```
sha256( <contract prompt bytes> \0 <delivery diff bytes> )
```

- **contract prompt** = the single `prompts/NN-task-*.md`.
- **delivery diff** = `git diff <merge-base(main,HEAD)> HEAD`, **excluding** everything authored or synced at
  or after the review, so the hash is stable from emit-time to closeout-time: `sessions/`, the closeout-synced
  `.ai/*` (`STATE.md`, `SESSION-BOOT.md`, `SESSION`, `TASK.md`, `ROADMAP.md`, `KNOWLEDGE.md`), and the gate's
  own timestamped `.ai/verify/` artifacts + `.ai/.session-owner`.

**One function, both sides.** `canonical_inputs_sha()` in `verify-closeout.sh` computes it. The reviewer
embeds it via `verify-closeout.sh --inputs-sha <N>`; `check_review_attestation` recomputes it at closeout and
compares. Because both sides call the same code, normalization can never drift between emit and verify.

**Behavior.** On an ACCEPT: a missing, forged, or **stale** (delivery changed after the review)
`**Review-Inputs-SHA:**` FAILS the gate, behind the same `VAJRA_CLOSEOUT_WAIVER=<N>` founder waiver. A REJECT
needs no attestation (it is already blocking / being waived — no double-jeopardy). `--fidelity-only` keeps its
S56 meaning (shape/verdict/waiver only) so prior harnesses stay green; the attestation has its own focused
entry `--attest-only [N]`.

## What it proves — and what it does NOT (do not overclaim)

**This is bar-raising, NOT tamper-proof.** The same agent that runs the gate can run `--inputs-sha` and paste
the hash without ever running a cold pass. So the attestation does **not** prove a *different mind* authored
the verdict. An in-repo hash computable from committed state is forgeable by anyone with repo access; there is
no in-repo mechanism that makes it un-forgeable by the same agent (recorded here honestly, as the S58 prompt
anticipated).

It **does** raise the bar against three concrete, previously-invisible forgeries:

| Attack | Before S58 | After S58 |
|---|---|---|
| ACCEPT **recycled** from another session | passed (right shape) | FAILS — hash is prompt+diff-specific |
| ACCEPT written against an **earlier** diff, then delivery changed | passed | FAILS — freshness mismatch |
| ACCEPT **decoupled** from what shipped (never matched the diff) | passed | FAILS — gate recomputes from live repo |
| ACCEPT the builder **self-authored** against the true diff | passed | still passes (the honest limit) |

## Consequence for the honest #1

**Downgraded, not closed.** The standing honest #1 — "verdict *authorship* independence is procedural, not
structural" — moves from an *open gap* to a *documented, bounded limit*: procedure (the cold-subagent pass)
still carries the who-authored-it guarantee; the code now carries the what-was-reviewed binding. Closing the
remainder (proving a different mind) would need an out-of-band trust root — a second signer, a CI-side
reviewer identity, or an attestation the builder cannot produce — which is out of scope for an in-repo gate
and would violate "no new store/command." Recorded as future work, not claimed.

## Alternatives considered

- **A signed verdict / second keypair.** Genuinely un-forgeable, but requires a key store + identity the
  in-repo gate can't bootstrap (a new store) — rejected for S58's spine constraint; noted as the real path if
  tamper-evidence is ever required.
- **Hashing only the prompt.** Cheaper but proves nothing about the delivery — a stale ACCEPT would pass.
  Rejected: the delivery diff is the load-bearing half.
- **A new `vajra attest` command.** Rejected — maps onto the existing review artifact + gate; `--inputs-sha`
  / `--attest-only` are script flags, not a new top-level command (no 8th command, no second store).
