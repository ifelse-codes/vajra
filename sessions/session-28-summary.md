# Session 28 — Propagate Darshan into `vajra init`

**Type:** CODE · **Branch:** `session-28-init-propagation` (from `main`) · **PR:** [#19](https://github.com/ifelse-codes/vajra/pull/19) (merged, `c65fc10`)

## Goal achieved?

**Yes (Darshan-only, as planned).** A fresh `vajra init` now scaffolds the Darshan human-output skill + the boot pointer. Per the prompt's pre-authorized scope-split, the S26 **session-guard** propagation was deferred to **S29** — kept this session to 1 story.

## What shipped

- `src/cli/init.rs`:
  - `const TPL_DARSHAN = include_str!("../../darshan/SKILL.md")` + `f("darshan/SKILL.md", TPL_DARSHAN)` in the emit list — same one-source-of-truth pattern as the S22 co-pilot hook (byte-identical scaffolded copy, no drift).
  - `TPL_AGENTS` gained a **Speaking Skills (Load at Boot)** section naming Darshan = default human output.
- No `Cargo.toml` change — `darshan/` is not in the `exclude` list, so the file already ships with `cargo install`.
- No 8th command, no new dep, no `src/` rendering (skill-not-renderer holds).
- Scaffold grew 17 → **18 files**.

## Evidence

- `scripts/verify-session-28.sh` → **12/12 green** (incl. a real end-to-end `vajra init` into a temp git repo asserting: skill present, byte-identical, AGENTS Speaking-Skills section, AGENTS points at `darshan/SKILL.md`, co-pilot still wired, no `src/` renderer, no 8th command).
- New scaffold tests: `scaffold_ships_darshan_skill_verbatim`, `scaffold_wires_darshan_into_constitution`.
- `scripts/demo-session-28.sh` → a brand-new project inherits Darshan; S22 co-pilot intact.
- `cargo fmt` / `clippy -D warnings` / `cargo test` all green.

## Decisions

- **Scope split (decided in PLAN):** Darshan-only S28, session-guard → S29. The guard needs 4 wiring points (hook `include_str!` + settings PreToolUse + `one_session_per_chat: true` in CONSTRAINTS + a new `.gitignore` template + Cargo un-exclude) = a second story.
- One co-pilot fire (`cmd:git commit`) blocked the feature commit until `.ai/STATE.md` was surfaced — the propagated enforcement, dogfooded on itself.

## Cost

~$0.00 (code session, no API calls). Cumulative ~$0.46.

## Next options (pick one)

**A — S29: propagate the session-guard into `vajra init`** *(already roadmapped — closes the S28 split)*
Goal: a fresh `vajra init` also inherits `hook-session-guard.sh` + settings wiring + `one_session_per_chat: true` + a `.gitignore` for `.ai/.session-owner`.
Why pick: finishes the deferral cleanly; mechanism is the proven S22/S28 `include_str!` pattern.
Risk: a *new* `.gitignore` scaffold template + a `Cargo.toml` un-exclude — more wiring points than Darshan had.

**B — Dogfood Vajra+Varta+Darshan on a real outside project**
Goal: run the full loop on a non-Vajra repo, log friction, fix-or-defer.
Why pick: the founder-satisfaction gate (S26) needs real-use evidence, not more self-features.
Risk: open-ended; may surface scope we don't want to chase mid-stream.

**C — Validate `vajra estimate`'s 3:1 output ratio**
Goal: replace the placeholder ratio (ADR-0005) with measured JSONL data.
Why pick: removes a known unvalidated claim that dominates the estimate.
Risk: lower leverage than A/B right now.

> **Picked: A** (S29 session-guard propagation) — `prompts/29-task-session-guard-propagation.md`.
> Note: **S30 is the next ground-truth (NO-CODE)** — `NN % 5 == 0`.
