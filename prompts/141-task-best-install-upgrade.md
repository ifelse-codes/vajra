# Session 141 — Best install + upgrade-in-place: give the fleet render real, recorded provenance

> **Status: PICKED** — founder, in chat at the S140 GT close: *"lock S141 = best install + upgrade-in-place."*
> Written at the S140 closeout; **start S141 in a FRESH chat** (one session per chat), where the agent
> creates the `session-141-<slug>` branch itself. **S140 (the NO-CODE GT) must be signed off + closed first.**
>
> Founder directive in force (S118): README/VISION claims are the target spec, never softened.

## Why this session exists (founder's #1 completeness priority, S140)

The founder's plain words at the S140 GT: *"smooth the fresh install first — the best install, or vajra
upgrade in an existing vajra repo, so it will always be the best."* Today it is NOT smooth:

- `vajra init --sync-fleet` (S136) can CREATE a missing role file and no-op an identical one, but the
  moment a file **differs** it reports `Drifted` and **refuses** — because it cannot tell an **old Vajra
  render** (safe to upgrade) from the **user's own edit** (must never be clobbered). Both are just
  "bytes that differ." So a brownfield repo (chitra had **4 stale renders**, S136) can only be upgraded
  by a human forcing `--overwrite-drifted`, which also blows away real edits. That is the opposite of
  "always the best."
- The `FleetFileState` doc comment states the S136 floor exactly: *"nothing anywhere stores which Vajra
  version produced a given file. No version stamp, no manifest, no generated-by marker ... building a
  classifier out of git blame or timestamps would be inventing provenance that was never recorded."*

**S141 closes that floor the honest way: RECORD the provenance Vajra never wrote.** Not a git-blame /
timestamp guess (S136 rightly rejected that as *invented* provenance) — a stamp **Vajra writes itself
at render time**, so an untouched Vajra render is provable and can be auto-upgraded to the latest,
while a user-edited file is provably different and stays untouched. See `[[vajra-skip-if-present-cannot-update]]`,
`sessions/session-136-summary.md`, and the ROADMAP S136 candidate 3 (stamp each render with its hash).

## Type

**CODE.** Max 2 assumptions · 2 retries · ~2h · 1 story · 3 files/commit · new chat · approval token
before any commit · un-forgeable `VAJRA_ALLOW_COMMIT=141` marker.

## The one story

Give every scaffolded fleet role file (`.claude/agents/<role>.md`) a **recorded provenance stamp** —
`vajra-render-sha: <hex>`, written by `fleet::render_subagent_definition` at render time, where hex =
sha256 of the file body **excluding the stamp line**. Then teach `classify_fleet_file` a **fourth,
now-DERIVABLE** state, `StaleRender`: present, differs from the current render, **but** its on-disk body
(minus the stamp line) re-hashes to its own embedded stamp — proving it is an **untouched Vajra render
of an older version**. `vajra init --sync-fleet` **auto-upgrades** a `StaleRender` to the current render
(no `--overwrite-drifted` needed), and still **refuses** a `UserEdited`/unstamped `Drifted` file unless
the human passes `--overwrite-drifted`. Fresh `vajra init` starts stamping, so every future upgrade is
smooth by construction.

## Design (the Architect gate — dispatch the tech-lead FIRST, then let it bind the crew)

- **design-significant: yes** — this adds a state to `FleetFileState` (the enum the S136 comment argues
  is "only three because there can only be three") and a NEW persisted on-disk format (the stamp line).
  Both are deliberate reversals of an S136 decision, made legitimate by a single new fact: the
  provenance is now **recorded, not inferred**. Cite `docs/decisions/DECISION-007-agent-fleet.md` and add
  an **S141 addendum** recording the stamp format, the fourth state, and why it does not reopen the
  rejected classifier. (verified to exist: `docs/decisions/DECISION-007-agent-fleet.md`.)
- **The core distinction that must be stated, not assumed:** S136 rejected a git-blame/timestamp
  classifier as *"inventing provenance that was never recorded."* S141 does the opposite — it **records**
  the provenance at write time. A stamp Vajra itself wrote is ground truth about "these bytes are exactly
  what Vajra last rendered"; re-hashing the on-disk body and comparing to the embedded stamp is a pure,
  deterministic check, no guessing. This is the honest version of the same goal, not a walk-back.
- **Rejected alternatives (a rationale with no rejected option is not a decision):**
  - *A sidecar manifest* (`.vajra/fleet.lock` listing each file's hash) vs. *an in-file stamp.* REJECTED
    the sidecar for v1: a manifest can desync from the file it describes (delete/copy/rename), and the
    file-is-its-own-record property is what makes the check a pure function of the bytes on disk. (Name
    it as a future option if multi-file provenance is ever needed.)
  - *Stamp = hash of the WHOLE file including the stamp* (self-referential, impossible) vs. *hash of the
    body EXCLUDING the stamp line.* REJECTED the self-referential form — the exclusion is what makes the
    round-trip derivable.
  - *Auto-upgrade a `StaleRender` silently* vs. *upgrade it but PRINT what changed.* Keep the upgrade
    automatic (that is the whole point) but REPORT each upgraded file by name and old→new, so a smooth
    upgrade is never an invisible one.
  - *Retire `--overwrite-drifted`* vs. *keep it for the legacy/edited case.* KEEP it: an unstamped file
    (every pre-S141 install, incl. chitra) and a genuinely user-edited file both still need the human's
    explicit override — see the honest backward-compat note in Guardrails.
- The tech-lead is the FIRST and MANDATORY dispatch; it decides which specialists S141 needs and its
  verdict BINDS on this session (record its handoff). design-advisor + fidelity-reviewer are mandatory;
  let the rest be dispatched or reasoned-skipped **as the tech-lead decides**, and record every required
  role's governed handoff (this session's own close runs `check_required_crew`, S139).

## Acceptance (testable, EARS-style)

1. WHEN `fleet::render_subagent_definition(role)` renders a role file, THEN the output carries a
   `vajra-render-sha: <hex>` stamp where hex = sha256 of the rendered body with the stamp line removed;
   re-deriving the hash from the rendered output reproduces the stamp (pure round-trip, unit-tested per
   role), AND the stamp is inert to Claude Code — a stamped `.claude/agents/<role>.md` still dispatches
   by name (frontmatter/comment placement that Claude Code ignores; assert placement, not just presence).
2. WHEN a role file is on disk, THEN `classify_fleet_file` returns exactly one of FOUR states:
   `Missing` · `UpToDate` (bytes == current render) · `StaleRender` (bytes != current render, but the
   body-minus-stamp re-hashes to its own embedded stamp → provably an untouched older render) ·
   `Drifted` (no stamp, or the embedded stamp does NOT verify → user edit or foreign file). The
   classification is a pure function driven by unit tests without a filesystem (as today).
3. WHEN `vajra init --sync-fleet` runs, THEN a `StaleRender` file is **rewritten to the current render
   WITHOUT `--overwrite-drifted`** (and the change is reported by name), a `Drifted` file is **left
   untouched and the run exits 1** unless `--overwrite-drifted` is passed, a `Missing` file is created,
   and an `UpToDate` file is a no-op. Proven by a falsifiability fixture with ALL FOUR cases that goes
   RED for the exact right reason and GREEN when correct, its positive control asserting a clean exit 0
   (S122 right-reason + S134 clean-exit bars).
4. WHEN a fresh `vajra init` scaffolds a project and `vajra init --sync-fleet` is run immediately after,
   THEN every role file is `UpToDate` and NOTHING is rewritten (idempotent, no mtime/git churn — the
   S136 property preserved); AND when a stamped OLDER render is placed on disk, the next `--sync-fleet`
   upgrades exactly it. Proven live in a REAL empty dir with the REAL release binary (stranger-check
   style), not only in unit tests.
5. `## Design` + a `DECISION-007` S141 addendum state that the stamp is RECORDED provenance (written at
   render time), explicitly distinct from the git-blame/timestamp classifier S136 rejected — so the
   fourth state does not reopen "inventing provenance."
6. `scripts/verify-session-141.sh` (exits 0, FAIL-on-absent, check-class tally printed) +
   `demo-session-141.sh` (the 4 sprint markers: header · cases · summary_table · before_after) +
   `sessions/session-141-summary.md` with the full fidelity map (every criterion SHIPPED/PARTIAL/
   NOT-BUILT + the fakest green) and exactly 3 ranked next candidates. Cold `fidelity-reviewer` ACCEPT.

## Plan (ordered — cite the acceptance criteria each step covers)

1. Dispatch the tech-lead FIRST on a named-files brief (`src/cli/init.rs`, `src/fleet/mod.rs`,
   `docs/decisions/DECISION-007-agent-fleet.md`, `sessions/session-136-summary.md`); record its handoff +
   let it bind the crew. covers: 6
2. Add the stamp to `fleet::render_subagent_definition` (body-excluding-stamp sha256) + a helper that
   extracts/verifies a file's stamp; unit-test the round-trip per role and Claude-Code-inertness.
   covers: 1
3. Extend `FleetFileState` with `StaleRender` + rewrite `classify_fleet_file` to the four-way pure
   function; update the doc comment (the S136 "only three" rationale is now superseded — say why in
   place). covers: 2, 5
4. Wire `sync_fleet` to auto-upgrade `StaleRender` (report by name) and keep the `Drifted` refuse /
   `--overwrite-drifted` override; preserve idempotence + no-churn. covers: 3
5. Write the four-case falsifiability fixture + the live real-dir round-trip; write
   `verify-session-141.sh` + `demo-session-141.sh` + the DECISION-007 addendum + the summary. covers: 3, 4, 5, 6

## Execution (the Coder gate — fill each step's landing sha as work lands)

- step 1 — done: <sha>. covers: 6
- step 2 — done: <sha>. covers: 1
- step 3 — done: <sha>. covers: 2, 5
- step 4 — done: <sha>. covers: 3
- step 5 — done: <sha>. covers: 3, 4, 5, 6

## Advice (every recommendation from this session's advisors, answered)

(`vajra next --check-advice 141` BLOCKS the close until every recorded recommendation is answered, and
`vajra next --check-obeyed 141` BLOCKS until every `obeyed:` claim carries an independent judgment from a
role that is not the one that gave the advice. Fill this section in-session as the advisors report.)

## Guardrails

- **Scope = the FLEET role files only** (`.claude/agents/<role>.md`, the exact domain `--sync-fleet`
  already covers). The constitution, `CONSTRAINTS.yaml`, hooks, and the kickoff prompt are **OUT of
  scope** — the same stamp pattern can extend to them in a later session; do not widen here (1 story).
- **Honest backward-compat — the fakest green to avoid claiming.** Every pre-S141 install (chitra
  included) has UNSTAMPED files. On first contact they classify as `Drifted`, NOT `StaleRender`, and are
  still REFUSED without `--overwrite-drifted` — because Vajra genuinely cannot prove provenance it never
  wrote. The smooth auto-upgrade begins only AFTER a file carries a stamp (a re-init, or the human's one
  `--overwrite-drifted`, writes the first stamp; every upgrade after that is automatic). State this
  plainly in the summary: S141 makes upgrades smooth **going forward**, not retroactively for legacy files.
- **The stamp must not change the subagent's behavior** — Claude Code must still dispatch the role by
  name (acceptance 1 asserts placement, not just presence). Do NOT put the stamp anywhere Claude Code
  parses as instruction.
- **Preserve the S136 no-churn property** (acceptance 4): an `UpToDate` file is never rewritten.
- **Do NOT add an eighth top-level command** (max 7) — this rides `vajra init` / `--sync-fleet`.
- **The fixture must fail for the RIGHT reason** (S122); the positive control asserts a clean exit 0
  (S134). A rename/whitespace control must bind to VALUES, not message text (S133).
- **Budget every subagent dispatch TIGHT: named files, never "read the repo"** (S134; $20/mo plan).
- Un-forgeable `VAJRA_ALLOW_COMMIT=141` on every commit. Attest LAST (S69/S131): recompute
  `--inputs-sha 141` after every prompt edit; run the FULL `verify-closeout.sh` on the branch BEFORE
  merging (S83). This session records its own tech-lead + required-role handoffs so its OWN close passes
  `check_required_crew` (S139). **Next after S141:** one or two chitra dogfoods (founder plan, S140).

## Delta (vs ROADMAP — OpenSpec markers)

- `+` `fleet::render_subagent_definition` emits a `vajra-render-sha:` provenance stamp; `FleetFileState`
  gains `StaleRender`; `sync_fleet` auto-upgrades an untouched old render to the latest.
- `~` the S136 floor ("stale-vs-edited is NOT DERIVABLE") is superseded — it is now derivable because the
  provenance is RECORDED at render time, not inferred from git/timestamps (which stays rejected).
- `-` the "upgrade refuses on every difference" friction (S136) — retired for stamped files; disclosed
  as still-present for legacy unstamped files (first upgrade needs `--overwrite-drifted`).
- **Disclosed remainder:** non-fleet scaffold files (constitution, constraints, hooks) are still
  add-only — a later session extends the stamp to them.
