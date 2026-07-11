# Session 57 — Propagate the fidelity gate + reviewer into `vajra init`

> **Status:** APPROVED — the S56 pre-authorized split (prompt G1: "defer `vajra init` propagation to S57")
> + founder standing "all approved". The gate S56 built protects only Vajra's own repo; this makes every
> scaffolded project inherit it. Founder may reprioritize to S57-B (structural verdict-authorship
> independence) or S57-C (delta ledger) in a new chat — the 3 ranked candidates are in
> `sessions/session-56-summary.md`.

## Type
- **CODE** (propagation, the S22/S28/S29/S38 pattern). Max **2** assumptions · **2** retries · **~2h** ·
  **1** story · **new chat** · approval token before any commit.

## Goal
Every project scaffolded by `vajra init` must inherit the S56 fidelity gate — so a green closeout in a
scaffolded project also structurally requires an independent ACCEPT review, not just discipline. Close the
S36-class gap: *a guard built but not scaffolded leaks in the real projects it was meant to protect.*

## The job
1. **Ship the reviewer brain** — scaffold `reviewer/SKILL.md` byte-identical via `include_str!`
   (`src/cli/init.rs`, the S28 Darshan pattern; un-exclude in `Cargo.toml` if needed) + a boot pointer in
   `TPL_AGENTS` so scaffolded agents load it (like Darshan/Varta).
2. **Ship the teeth** — the scaffolded `verify-closeout.sh` must carry `check_fidelity_review` +
   `waiver_ok` + `--fidelity-only`. **Decide + record the mechanism:** `verify-closeout.sh` is
   template-generated text today, not `include_str!`'d — either convert it to `include_str!` (one source of
   truth, no drift — preferred) or justify a template copy. If the refactor is too large for one story,
   **split:** S57 ships the reviewer skill + boot wiring, S58 ships the gate into the scaffolded closeout.
3. **Prove it live** — a real `vajra init` into a temp repo produces a `verify-closeout.sh` whose fidelity
   gate actually FAILS on a missing/REJECT review and PASSES on an ACCEPT — end-to-end, not a grep.

## Deliverables
- `src/cli/init.rs` scaffolds `reviewer/SKILL.md` (+ boot pointer) and (this session or S58) the fidelity
  gate into the scaffolded `verify-closeout.sh`; `Cargo.toml` packaging fixed if a new `include_str!` is
  added (verify via `cargo package --list`).
- `scripts/verify-session-57.sh` (exits 0): asserts a real `vajra init` into a temp dir ships the reviewer
  skill byte-identical, wires the boot pointer, and (if in scope) the scaffolded closeout blocks a REJECT /
  passes an ACCEPT.
- `scripts/demo-session-57.sh` + interactive HTML demo when asked.
- `sessions/session-57-summary.md` + **the independent cold fidelity review of THIS session**
  (`sessions/session-57-review.md`, the gate now requires it) + 3 ranked S58 candidates.

## Acceptance (what S57 must answer)
1. Does a freshly-scaffolded project's closeout **structurally require an ACCEPT review** — proven by a real
   `vajra init` + a real gate run, not a mock?
2. Is the scaffolded gate **byte-identical / drift-free** from Vajra's own (one source of truth), or did a
   copy drift?
3. Did it stay on the spine (no 8th command, no second store) and keep `cargo test` green + clippy clean?
4. If split to S58, is the boundary honest (what shipped vs deferred), not a silent re-scope?

## Guardrails
- CODE session — slice tightly; **the split to S58 is pre-authorized** if the `verify-closeout.sh` refactor
  fills the session (S22/S28/S29 precedent). Do not cram two stories.
- Darshan every human reply · Varta against the live `.ai/`.
- **Eat the dog food:** S57's own closeout must pass the S56 gate — run the cold review on S57 too.
- If tempted to add a new file/store/command, map it onto an existing `.ai/` mechanism first, or **ASK**.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` The fidelity gate + reviewer skill in the `vajra init` scaffold (every project inherits the teeth).
- `~` Extends the S22/S28/S29/S38 propagation arc to the fidelity gate; closes the S36-class "built but not
  scaffolded" gap for the QA/Reviewer stage.
- `-` Retires "the fidelity gate is Vajra-repo-only" — scaffolded projects no longer close green by
  self-certifying either.
