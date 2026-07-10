# Session 54 — The Analyst stage: vague intent → a governed spec (the pipeline's first specialist)

> **S53 refined the north-star (DECISION-001 + refinement):** Vajra = a **governed multi-agent SDLC pipeline** —
> each stage a specialised agent, every handoff enforced + delta-tracked. **S54 builds the FIRST stage: the
> Analyst.** It turns a vague intent into a **structured `spec.md` + acceptance criteria + the first delta**,
> gated by Vajra. This supersedes the old S54 ledger plan (the ledger is re-sequenced to the cross-stage delta
> record, once stages emit deltas).

## Type
- **CODE** (first governed SDLC stage). Max **2** assumptions · **2** retries · **~2h** · **1** story ·
  **new chat** · approval token before any commit.

## The job
A specialised **Analyst** takes a vague intent (the session's context file / the user's own words) and produces:
1. A **structured spec artifact** — requirements + **acceptance criteria** — written to the repo (the SoT).
2. A **delta** — the change vs any prior spec, marked **+added / ~changed / −removed** (the first cross-stage
   delta seed; keep it simple — a delta block in the artifact or a sidecar).
3. A **gate** — Vajra **blocks anything downstream until the spec is human-approved** (enforcement, not a prompt).

## Borrow Engine (step 0, mandatory)
Before building, study how the incumbents shape *this* artifact and adopt the best; cite what you took + left:
- **Spec Kit** `spec.md` (structure) · **Kiro** EARS-notation requirements · **OpenSpec** delta markers.
Borrow the **artifact shape**, not the runtime. "You have the pattern, not the polish."

## Design constraints
- **RESPECT the max-7 command cap.** The Analyst stage rides an existing surface (e.g. a stage dispatch on
  `vajra next`, or a scaffolded prompt+gate) — do **NOT** add an 8th top-level command without explicit founder
  approval first.
- **Enforcement, not prose:** the spec gate must *actually block* downstream until approved (reuse the
  PreToolUse/hook gate mechanism) — not just "ask nicely."
- **Own the spine:** the spec lives in `.ai/` (or a feature folder under it) — the SoT. No second store.
- **Honest scope:** A-thin = **ONE stage (Analyst)** — spec + acceptance + delta + gate. Do **NOT** drift into
  Architect/Planner/Developer (those are their own sessions).

## What S54 must answer (in the summary)
1. Does a vague intent produce a structured, human-readable spec + acceptance a **non-author** can act on? Show a
   **real run**, not a mock.
2. Is the gate **real** (blocks downstream until approved) or just advisory? (Enforcement is the wedge.)
3. Did it stay within command-cap + own-the-spine + reuse constraints?
4. What did the Borrow Engine **take** from Spec Kit/OpenSpec/Kiro, and what did it deliberately **leave**?

## Deliverables
- The Analyst stage (spec generation + delta + gate) on an approved surface.
- `scripts/verify-session-54.sh` (exits 0): runs the Analyst on a real vague intent; asserts spec + acceptance +
  delta present; asserts the gate **blocks** downstream when unapproved; asserts no unapproved 8th command.
- `scripts/demo-session-54.sh` + the interactive HTML demo when asked.
- `sessions/session-54-summary.md` + **3 ranked candidates for S56** (**S55 = mandatory NO-CODE ground-truth**);
  top candidate = the next stage (Architect) **or** the cross-stage delta ledger.
- Update memory `vajra-direction-b-copilot` / `vajra-positioning` with the honest "first stage shipped / did the
  gate hold / did it read as more-than-Spec-Kit" finding.

## Guardrails
- CODE session — but **slice tightly to the Analyst stage**; do NOT build the rest of the pipeline.
- Darshan every human reply · Varta against the live `.ai/`.
- **Do not overclaim:** one governed stage ≠ the pipeline. If the spec-gen reads as "just Spec Kit reimplemented,"
  record it — that is the signal to lean harder on **enforcement + delta** (the wedge), not artifact polish.

## Output
- A working Analyst stage that turns a vague intent into a **governed, delta-tracked spec** + `verify-session-54.sh`
  green + a summary with the honest "does the gate hold / is it more than Spec Kit" verdict + 3 ranked S56 candidates.
