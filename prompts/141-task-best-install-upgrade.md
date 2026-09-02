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
- **Supersedes an S136 lock — recorded, not inferred.** This session DEVIATES FROM / SUPERSEDES the
  S136 *"not derivable"* floor and the `FleetFileState` *"only three because there can only be three"*
  doc comment. The Architect gate checks only that `DECISION-007` resolves to a file, never that the
  design obeys it (the S127 lesson) — so the reversal is legitimate ONLY because the S141 addendum lands
  and says so in its own words. Record the deviation here, where a reader finds it.
- **Honest limit — a content hash, not a keyed signature.** Re-hashing body-minus-stamp proves the
  bytes are a *fixed point of Vajra's own render+hash function* — which any identical render reproduces
  and which a user could in principle forge by hand (there is no secret key). The honest claim is
  **auto-upgrade-safe for the untouched-render case**, NOT "cryptographic provenance": tamper-EVIDENT,
  not tamper-PROOF — the same posture as the DECISION-004 verdict ledger. State it, or a reviewer reads
  "provenance" as stronger than it is.
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
  - *A version/session LABEL* (`vajra-render: 0.x` / `rendered-by-S141`) vs. *a content HASH.* REJECTED
    the label — the most natural thing to reach for, and the S136 future-fix note's own wording. A label
    records a *claim* about the bytes that a hand-edit does not invalidate (edit the body, the label
    still says `S141`), so it cannot tell an untouched render from an edited one — the whole job. The
    hash verifies the actual bytes; the label verifies nothing.
  - *Stamp in a BODY COMMENT* (`<!-- vajra-render-sha: … -->`) vs. *a FRONTMATTER KEY.* REJECTED the
    body comment: it is inert to dispatch, but Claude Code strips frontmatter and feeds the body to the
    model as system-prompt text — so a body comment becomes prompt tokens that could perturb the role,
    while an unknown frontmatter key is ignored by the loader AND never reaches the model. Place the
    stamp as the LAST frontmatter line (after `tools:`, before the closing `---`).
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

- step 1 — done: 712e2e6. covers: 6
- step 2 — done: 32d90e9. covers: 1
- step 3 — done: ff80d7e. covers: 2, 5
- step 4 — done: ff80d7e. covers: 3
- step 5 — done: 7865c34. covers: 3, 4, 5, 6

## Advice (every recommendation from this session's advisors, answered)

(`vajra next --check-advice 141` BLOCKS the close until every recorded recommendation is answered, and
`vajra next --check-obeyed 141` BLOCKS until every `obeyed:` claim carries an independent judgment from a
role that is not the one that gave the advice. The independent judge here is the **fidelity-reviewer**,
grading the **design-advisor** — a different role, so admissible (the S131 designed pattern: the obeyed
judgments ride the already-mandatory fidelity-reviewer handoff).)

**design-advisor — 6 recommendations (dispatched by the tech-lead's `required` verdict).**

- design-advisor rec 1 — deferred: sessions/session-141-summary.md
- design-advisor rec 2 — obeyed: f02ddd3
- design-advisor rec 3 — deferred: prompts/141-task-best-install-upgrade.md
- design-advisor rec 4 — obeyed: 32d90e9
- design-advisor rec 5 — obeyed: f02ddd3
- design-advisor rec 6 — deferred: prompts/141-task-best-install-upgrade.md

*(rec 1 affirmed `design-significant: yes` — kept, no change. rec 2 added the content-hash-not-keyed-
signature / tamper-EVIDENT disclosure to `## Design` and the DECISION-007 S141 addendum (f02ddd3). rec 3
added the two rejected alternatives — version-label-vs-hash and body-comment-vs-frontmatter-key — to the
prompt's `## Design`. rec 4 placed the stamp as a frontmatter key so Claude Code ignores it (32d90e9;
asserted by the per-role placement test + verify #live-stamp-in-frontmatter). rec 5 landed the addendum
text (f02ddd3). rec 6 recorded the deviation/supersede line in `## Design`. rec 2/4/5 judged below.)*

**tech-lead — 3 recommendations (the crew decision + how the session should run).**

- tech-lead rec 1 — deferred: sessions/session-141-summary.md
- tech-lead rec 2 — deferred: sessions/session-141-summary.md
- tech-lead rec 3 — deferred: sessions/session-141-summary.md

*(rec 1 — design-advisor dispatched BEFORE any code, on the tight named-files brief; its handoff carries
the recorded-vs-inferred addendum wording. rec 2 — qa-specialist dispatched at verification against the
four-case fixture. rec 3 — fidelity-reviewer dispatched cold at close, fed prompt + diff. All in the
summary's dispatch accounting.)*

**qa-specialist — 3 recommendations (verification: verify 10/10, fixture 8/8, live falsification RED).**

- qa-specialist rec 1 — deferred: sessions/session-141-review.md
- qa-specialist rec 2 — deferred: sessions/session-141-summary.md
- qa-specialist rec 3 — deferred: sessions/session-141-summary.md

*(rec 1 — the no-live-agent-dispatch limit is disclosed in the review + summary (the fakest green). rec 2
— accepted as an honest limit: the qa break reddens the STA plant; RRS/EDT stay refused under it, so
their own-direction falsification is by the unit test `..._verification_is_falsifiable`, noted in the
summary — not re-worked (1 story). rec 3 — the per-role round-trip/inertness is unit-tested for ALL ten
roles; the live layer spot-checks researcher. Rotating the live role is a cheap future nicety, deferred.)*

**fidelity-reviewer — 3 recommendations + the independent `obeyed:` judgments (cold ACCEPT, 5/6→6/6).**

The independent `obeyed:` judgments of the design-advisor's dispositions live in the fidelity-reviewer's
handoff (`.ai/handoffs/session-141-fidelity-reviewer.md`) and `sessions/session-141-review.md`:
`obeyed-check design-advisor rec 2 — implemented: f02ddd3`, `rec 4 — implemented: 32d90e9`,
`rec 5 — implemented: f02ddd3`. Judge = fidelity-reviewer, advisor = design-advisor — different roles.

- fidelity-reviewer rec 1 — deferred: sessions/session-141-summary.md
- fidelity-reviewer rec 2 — deferred: sessions/session-141-summary.md
- fidelity-reviewer rec 3 — deferred: scripts/demo-session-141.sh

*(rec 1 — the summary is landed with the full fidelity map + 3 ranked candidates, so criterion 6's
artifact is present at close (the reviewer graded it PARTIAL only because the summary post-dates the
review dispatch). rec 2 — APPLIED as disclosure: the summary's fakest-green section states plainly that
"Claude Code ignores an unknown frontmatter key" is an untested ASSUMPTION / known risk, not a proven
fact. rec 3 — APPLIED: `demo-session-141.sh`'s acceptance table now COMPUTES each mark from the live
case signals (stamp present · four states seen · C2==0 && C3!=0 · idempotent re-sync · addendum present)
— the hardcoded ✔ removed.)*

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
