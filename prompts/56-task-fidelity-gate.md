# Session 56 — The fidelity gate: make the acceptance auditor's verdict STRUCTURALLY REQUIRED (teeth)

> **Status:** APPROVED — founder picked candidate A at S55 close (the DECISION-002 mandate: build the
> teeth now that S55 proved the brain). S55's cold re-audit returned **S54 = REJECT** — so this gate's
> **first live act is to judge S54**, which is the point: enforcement, not ceremony.

## Type
- **CODE** (the pipeline's QA/Reviewer stage — teeth). Max **2** assumptions · **2** retries · **~2h** ·
  **1** story · **new chat** · approval token before any commit. Builds on `reviewer/SKILL.md` (S55 brain).

## The job
Turn the proven *brain* (`reviewer/SKILL.md`) into *enforcement* — closeout cannot pass by
self-certifying. **Order: brain (done S55) → teeth (this) → independence (already: cold subagent).**
1. **Require the artifact** — `scripts/verify-closeout.sh` (fail-closed, the L4 layer) requires a
   `sessions/session-NN-review.md` for the session being closed.
2. **Check it is real, not present** — the review must carry a per-requirement verdict table
   (SHIPPED/PARTIAL/NOT-BUILT) and an overall **ACCEPT/REJECT** — not just exist (avoid the S54 "fakest
   green": a heading-grep that is trivially true).
3. **Fail on REJECT** — closeout **FAILS** if the review is missing, incomplete, or verdict = **REJECT**,
   **absent an explicit, recorded human waiver** (a signed line the agent cannot forge — mirror the
   `VAJRA_ALLOW_PUBLISH` env-var trust model, not a text marker the agent can write).
4. **Run the pass cold** — the review is produced by a separate subagent fed only the prompt + the diff
   (the S55 method), never the builder's summary.

## Design constraints
- **Own the spine / no 8th command:** the gate rides `verify-closeout.sh` + the existing binary; no new
  top-level command (7-command cap). No second store — the artifact is `sessions/session-NN-review.md`.
- **Enforcement, not prose:** the gate must *actually fail closeout* (exit non-zero) on a missing/REJECT
  review — reuse the L4 fail-closed pattern. A waiver must be un-forgeable by the agent.
- **Honest scope — ONE story.** The gate is the story. **Pre-authorized split (S22/S28/S29 precedent):**
  if the gate fills the session, `vajra init` propagation of `reviewer/SKILL.md` + gate wiring → **S57**.
- **Bundle (small, same theme):** fix the S55 finding — add `sessions/session-*-review.md` + `reviewer/*`
  to the NO-CODE GT whitelist in `scripts/hook-pre-write.sh` (one case line) so a GT can write its own
  approved review deliverables without the exempt-branch detour.

## What S56 must answer (in the summary)
1. Does closeout now **fail** when the review is missing, incomplete, or REJECT — proven by a real run,
   not a mock? Show the red.
2. Is the waiver **un-forgeable by the agent** (env/founder-controlled), or just another text marker?
3. **The dogfood that matters:** run the gate against **S54's REJECT** — does it block, and does closing
   S54 now require either fixing the Analyst gaps (Intake/Options/Delta/TASK.md) or a recorded waiver?
4. Did it stay on the spine (no 8th command, no second store) and NO-CODE-safe for GT sessions?

## Deliverables
- The fidelity gate in `scripts/verify-closeout.sh` (+ binary support if needed): requires + validates
  `sessions/session-NN-review.md`, fails on missing/incomplete/REJECT absent a recorded waiver.
- The cold-subagent review invocation wired into the VERIFY/closeout step (per `reviewer/SKILL.md`).
- The `hook-pre-write.sh` GT-whitelist fix (the S55 bundle).
- `scripts/verify-session-56.sh` (exits 0): asserts closeout FAILS on a missing review, on a REJECT review,
  and PASSES on an ACCEPT review or a recorded waiver; asserts the waiver cannot be forged by the agent.
- `scripts/demo-session-56.sh` + the interactive HTML demo when asked.
- `sessions/session-56-summary.md` + **the fidelity review of THIS session** (eat the dog food) + 3 ranked
  S57 candidates (top = the S57 split: `vajra init` propagation of the reviewer skill + gate).

## Guardrails
- CODE session — slice tightly to the closeout gate; defer init-propagation to S57 if needed.
- Darshan every human reply · Varta against the live `.ai/`.
- **The gate must earn its place** (DECISION-002 honest limit): it is justified only if it catches real
  "shipped 1 of N" gaps — it must block S54's REJECT live, or you have built ceremony. Do not let it
  become a rubber stamp.
- If tempted to add a new file/store/command, map it onto an existing `.ai/` mechanism first, or **ASK**.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` The fidelity **gate** (teeth): closeout structurally requires an independent ACCEPT; the un-forgeable
  waiver; the write-guard whitelist fix.
- `~` Upgrades `verify-closeout.sh` from a discipline check (files synced, SESSION integer) to a **fidelity**
  check (delivery == the prompt's requirements). Sharpens ROADMAP #1 from "prove the brain" to "enforce it".
- `-` Retires self-certified closeout — a session can no longer close green by grading its own delivery.
