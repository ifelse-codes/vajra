# Session 59 — The cross-stage delta ledger (the 0-code headline moat, first attested content)

> **Status:** APPROVED (founder standing "all approved") — the recommended S58 candidate A. The headline
> moat (a cross-agent, tamper-*evident* record of what each stage did) is still **0 code**. S58 just gave it
> its first trustworthy payload: an **independent, attested acceptance verdict** (not a self-report). This
> session records those verdicts into a durable, hash-chained ledger. **Founder may reprioritize** in a new
> chat to S59-B (complete the S54 Analyst — Intake/Options/Delta, pay down the standing REJECT) or S59-C
> (harden attestation toward real tamper-evidence via an out-of-band signer) — 3 ranked candidates are in
> `sessions/session-58-summary.md`.

## Type
- **CODE.** Max **2** assumptions · **2** retries · **~2h** · **1** story · **new chat** · approval token
  before any commit. **S60 is the next mandatory NO-CODE ground-truth** — so this is the last CODE session
  before the every-5th audit; keep it tight.

## Goal
Turn the per-session fidelity outputs into a **durable, append-only, hash-chained ledger** — the moat's
headline artifact. Each closed session contributes one record: `{ session N, verdict ACCEPT|REJECT,
review-inputs-sha, prior-record-hash, this-record-hash }`. Recomputing the chain detects tampering (an edited
past verdict breaks every downstream hash). This upgrades the Analyst's `Status:` marker + the S58 attestation
from *per-session claim* to *cross-session evidence*.

## The job
1. **Map it onto Vajra's OWN mechanism FIRST (do not add a store by reflex).** The source records already
   exist: `sessions/session-NN-review.md` carries the verdict + `**Review-Inputs-SHA:**`, and git carries
   durability + order. Decide the smallest real ledger: is it a *derived, regenerable* view over the existing
   `sessions/*-review.md` + git history (preferred — no second source of truth, honors
   `feedback-distill-no-drift`), or does it need one new append-only file? If a new file, **ASK first** and
   justify why the derived view is insufficient. Record the decision in a short `docs/decisions/` note.
2. **Build the ledger + its integrity check.** A function/script that (a) extracts each session's verdict +
   input-sha, (b) chains them (`record_hash = sha256(prior_hash ‖ N ‖ verdict ‖ input_sha)`), and (c)
   **verifies** the chain — detecting a tampered past verdict. Ride an existing command surface (`vajra
   meter`/`next`/`check` or the closeout gate) — **no 8th top-level command.** Read-only over the trace where
   possible.
3. **Present it (Darshan).** A glanceable cross-session ledger view (session · verdict · attested? · chain-ok?).
4. **Dogfood.** Generate the ledger over the real S54–S58 history; show it flags S54's REJECT and S58's
   attested ACCEPT; prove a hand-edit of a past verdict is detected by the chain check.

## Deliverables
- The ledger decision recorded (`docs/decisions/` and/or `reviewer`/gate docs) — derived-view vs new-file,
  what the chain proves and does NOT (same honesty bar as S58: is it tamper-*evident* or only *detecting*?).
- The ledger builder + chain-verify, on an existing command/gate surface (no 8th command, no reflexive store).
- `scripts/verify-session-59.sh` (exits 0): builds the ledger over real history, a valid chain verifies, a
  tampered past verdict is **detected** — driven live, not a grep.
- `scripts/demo-session-59.sh` + interactive HTML when asked.
- `sessions/session-59-summary.md` + the independent cold `sessions/session-59-review.md` (carrying a real
  `**Review-Inputs-SHA:**`, per S58) + 3 ranked S60/S61 candidates (note S60 = mandatory NO-CODE GT).

## Acceptance (what S59 must answer)
1. Does the ledger build from the **existing** `sessions/*-review.md` + git (no new source of truth), or is a
   new store genuinely justified + recorded?
2. Does the chain-verify **detect a tampered past verdict** (real run, not a mock)?
3. Is the honesty bar held — tamper-*evident* (detection) vs tamper-*proof* stated plainly; what a determined
   in-repo editor can still do?
4. On the spine (no 8th command, no second store unless justified), `cargo test` green + clippy clean; if it
   rides `include_str!`/scaffold, byte-identical propagation confirmed.

## Guardrails
- **Map-to-Vajra first** (`feedback-map-concepts-to-vajra`): the prompt IS the spec; `.ai/` IS the memory;
  git IS durability. Do not import a "ledger file" by reflex — a derived, regenerable view is the default.
- **Do not overclaim.** A git-tracked hash chain is tamper-*evident* (edits are detectable), not
  tamper-*proof* (a determined editor can rewrite the whole chain + history). Say exactly that.
- Darshan every human reply · Varta against the live `.ai/`.
- **Eat the dog food:** S59's own closeout passes the S56/S58 attestation-bearing gate.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` A cross-session, hash-chained ledger of attested acceptance verdicts (the headline moat's first code).
- `~` Composes on S58 — the attestation is the ledger's payload; upgrades per-session claim → cross-session evidence.
- `-` Retires "the moat's headline (cross-agent tamper-evident ledger) is 0 code" — or, if only a derived
  view proves feasible this session, downgrades it to a bounded, honestly-scoped first slice.
