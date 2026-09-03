# Session 142 — Complete the upgrade loop: recorded provenance for the non-fleet scaffold files

> **Status: APPROVED** — founder confirmed the PICK (B) and approved this brief in chat at the S141
> close: *"i approve it — just a single update command and it will make update smooth and seamless."*
> **Founder design directive (binding): ONE update command upgrades everything.** A user runs a single
> invocation and roles + hooks + constitution all upgrade smoothly — NOT a second `--sync-scaffold`
> sibling, NOT a per-file-type command. See Design fork #3. **Start S142 in a FRESH chat** (one session
> per chat), where the agent creates `session-142-<slug>` and commits this prompt as its first act.
>
> Founder directive in force (S118): README/VISION claims are the target spec, never softened.

## Why this session exists (finishes the founder's #1 completeness priority)

S141 gave the smooth upgrade-in-place ONLY to the fleet role files (`.claude/agents/*.md`). Every OTHER
file `vajra init` scaffolds is still **add-only** — created if missing, then **frozen forever**:

| File | On upgrade today |
|---|---|
| `.claude/agents/*.md` (fleet roles) | ✅ S141 — stamped, auto-upgrades, edits protected |
| `.claude/settings.json` | ⚠️ merges (S44 special case) |
| `.ai/AGENTS.md` (the constitution) | ❌ add-only — never upgraded |
| `.ai/hooks/hook-*.sh` (the enforcement) | ❌ add-only |
| `.ai/CONSTRAINTS.yaml` (the rules) | ❌ add-only — **and user-tuned** |

So when Vajra improves a hook or a constitution rule, an existing project (chitra) **cannot pick it up
smoothly** — a human must hand-copy and risk clobbering their own edits. That is the second half of
*"the best install, or vajra upgrade in an existing vajra repo, so it will always be the best"* (the
founder's S140 #1 priority). S141 closed it for roles; **S142 closes it for the pure renders.**

## The one story

Generalise the S141 render stamp beyond frontmatter and widen the SINGLE update command
(`vajra init --sync-fleet`, scope broadened to all pure renders — founder directive, one command
upgrades everything) so the **pure-render** non-fleet scaffold files —
**the hooks (`.ai/hooks/hook-*.sh`) and the constitution (`.ai/AGENTS.md`)** — carry a
`vajra-render-sha:` stamp and gain the same four-state upgrade: an untouched old render auto-upgrades,
a user edit / unstamped file is refused unless `--overwrite-drifted`. One invocation makes the whole
update smooth and seamless. **`CONSTRAINTS.yaml` stays user-owned** and out of auto-upgrade (disclosed
limit — see Guardrails).

## Design (dispatch the tech-lead FIRST, then let it bind the crew)

- **design-significant: yes** — this generalises the stamp to new file TYPES (shell, markdown) with
  different comment syntax, and widens the domain `--sync-fleet` governs. Cite
  `docs/decisions/DECISION-007-agent-fleet.md` + the **S141 addendum**, and add an **S142 addendum**.
- **The core design questions the session must settle (with the design-advisor), not assume:**
  1. **Per-file-type stamp placement (the real work).** S141's stamp is a YAML frontmatter key and its
     helpers split on `\n---\n`. Hooks are shell (`# vajra-render-sha: <hex>` comment line);
     the constitution is markdown (an HTML comment `<!-- vajra-render-sha: <hex> -->`, or a trailing
     comment line). The stamp/strip/verify helpers (`fleet::stamp_render` / `strip_render_stamp` /
     `render_stamp_verifies`) must generalise to "a stamp line identified by the key, in this file's
     comment syntax, removed to recover the preimage" — the exact-inverse round-trip must still hold.
     Prefer REUSING/generalising the S141 helpers over a second copy (no drift).
  2. **Which files are in scope.** Pure renders (hooks, constitution) → stampable + auto-upgrade.
     `CONSTRAINTS.yaml` is user-TUNED (maturity, budget cap, approval tokens) → **leave user-owned**.
     Confirm this split against **what chitra actually edited** in its `.ai/` (a cheap read, no paid
     run) before locking it.
  3. **One command — RESOLVED by the founder: a SINGLE update command upgrades everything.** Widen the
     EXISTING `vajra init --sync-fleet` to cover ALL pure renders (roles + hooks + constitution) under one
     invocation — NOT a separate `--sync-scaffold`, NOT per-file-type commands. A user runs it once and
     every pure render upgrades smoothly. Consider renaming the flag to reflect the wider scope (e.g.
     `--sync`) IF and only if it adds no command; **do NOT add an 8th top-level command** (max 7).
- **Rejected-alternatives must be stated** (a rationale with no rejected option is not a decision):
  e.g. stamping `CONSTRAINTS.yaml` too (rejected — user-tuned) vs. leaving it user-owned; a per-file-type
  stamp vs. a sidecar manifest (S141 already rejected the sidecar — carry that reasoning).
- tech-lead FIRST + design-advisor + fidelity-reviewer mandatory; record every required role's handoff
  (the close runs `check_required_crew`, S139).

## Acceptance (testable, EARS-style)

> **Scope settled S142 (founder-confirmed "hooks now, constitution S143"):** the deliverable is the
> generalised stamp + the **hooks** joining the smooth upgrade. `.ai/AGENTS.md` is DEFERRED to S143
> (a filled per-install template `sync_fleet` cannot reproduce; the fill-split is its own story). The
> `MarkdownComment` syntax is built + unit-tested so S143 is a small step, not a rebuild. Criteria
> below read on the delivered scope; the constitution deferral is disclosed in the summary.

1. WHEN a hook (`hook-*.sh`) is rendered, THEN it carries a `vajra-render-sha:` stamp in shell-comment
   syntax; re-deriving the hash from the body-minus-stamp reproduces the stamp (pure round-trip,
   unit-tested per file type — frontmatter/shell/markdown, frontmatter byte-identical to S141), AND the
   stamp is inert to the consumer (a stamped hook still parses + runs; shebang stays line 1).
2. WHEN a non-fleet pure-render file (a hook) is on disk, THEN classification returns the four states
   (Missing · UpToDate · StaleRender · Drifted) as a syntax-aware pure function, same shape as S141.
3. WHEN the sync command runs, THEN a `StaleRender` hook auto-upgrades WITHOUT `--overwrite-drifted`
   (reported by name), a `Drifted`/unstamped one is refused (exit 1) unless `--overwrite-drifted`, and
   `CONSTRAINTS.yaml`/`.ai/AGENTS.md` are NEVER auto-upgraded. Proven by a four-case falsifiability
   fixture that goes RED for the right reason + a clean-exit-0 positive control.
4. WHEN a fresh `vajra init` scaffolds a project and the sync runs immediately after, THEN every
   role + hook is `UpToDate` and nothing is rewritten (idempotent, no churn) — proven LIVE in a real
   empty dir with the real release binary.
5. `## Design` + a DECISION-007 S142 addendum record the generalised stamp, the in-scope file set, and
   why `CONSTRAINTS.yaml` is deliberately excluded.
6. `scripts/verify-session-142.sh` (exit 0, class tally) + `demo-session-142.sh` (4 sprint markers) +
   `sessions/session-142-summary.md` (full fidelity map + 3 ranked candidates). Cold `fidelity-reviewer` ACCEPT.

## Design decision (settled S142, founder-confirmed)

**design-significant: yes.** The stamp generalises to a comment-syntax abstraction (`StampSyntax`:
Frontmatter | ShellComment | MarkdownComment), one code path, and widens the domain `--sync-fleet`
governs. Cites `docs/decisions/DECISION-007-agent-fleet.md` + its **S141 addendum**; recorded as the
**S142 addendum**. **Fork resolved (design-advisor rec 7, founder-confirmed "hooks now, constitution
S143"):** the shell hooks are in scope (no fill placeholders → byte-identical → clean fit); the
constitution `.ai/AGENTS.md` is DEFERRED (a filled per-install template `sync_fleet` cannot reproduce)
— the named S143 follow-up is to split its governed body from its user-owned fill; `CONSTRAINTS.yaml`
stays user-owned permanently. Rejected alternatives (un-fill / scavenge values / naive rewrite / a
second command / sidecar) are named in the addendum.

## Plan (ordered — cite the acceptance criteria each step covers)

1. Dispatch the tech-lead FIRST; let it bind the crew (design-advisor · qa-specialist · fidelity-reviewer
   required). covers: 6
2. Add `StampSyntax` and parameterise the four S141 helpers on ONE code path; keep the frontmatter
   variant byte-identical (golden test); exact round-trip per file type incl. the trailing-newline
   edge. covers: 1
3. Make `classify_fleet_file` syntax-aware; model `sync_targets()` over roles + hooks; scaffold the
   hooks already stamped so a fresh init is UpToDate (no churn). covers: 2, 4
4. Widen `--sync-fleet` (report line, no 8th command): a stale hook auto-upgrades, a drifted/unstamped
   one is refused unless `--overwrite-drifted`; `CONSTRAINTS.yaml`/constitution never touched. Prove
   with the four-case hook fixture (RED for the right reason + clean exit-0 control). covers: 3
5. Record the DECISION-007 S142 addendum (generalised stamp · hooks-in · constitution-deferred ·
   constraints-out · rejected alternatives · honest limits). covers: 5
6. `verify-session-142.sh` + `fixture-session-142.sh` + `demo-session-142.sh` + the summary; cold
   `fidelity-reviewer` ACCEPT. covers: 1, 6

## Execution (the Coder gate — landing sha per step)

- step 1 — done: d4c471b. covers: 6
- step 2 — done: 90105ca. covers: 1
- step 3 — done: 90105ca. covers: 2, 4
- step 4 — done: 90105ca. covers: 3
- step 5 — done: 58b1033. covers: 5
- step 6 — done: 97a40ef. covers: 1, 6

## Advice (every recommendation from this session's advisors, answered)

Each `obeyed:`/`refused:`/`deferred:` answers one numbered rec. `vajra next --check-advice 142` blocks
the close until every rec is answered; the design-advisor's `obeyed:` dispositions are judged
independently by the fidelity-reviewer (a different role — the S131 pattern), recorded in
`sessions/session-142-review.md`.

**tech-lead — 5 recommendations (crew bound FIRST; required = design-advisor · qa-specialist ·
fidelity-reviewer; six deferred-budget).**

- tech-lead rec 1 — deferred: sessions/session-142-summary.md
- tech-lead rec 2 — deferred: sessions/session-142-summary.md
- tech-lead rec 3 — deferred: .ai/handoffs/session-142-design-advisor.md
- tech-lead rec 4 — deferred: sessions/session-142-summary.md
- tech-lead rec 5 — obeyed: 90105ca

**design-advisor — 10 recommendations (settled both forks; the constitution deferral is founder-confirmed).**

- design-advisor rec 1 — obeyed: 90105ca
- design-advisor rec 2 — obeyed: 90105ca
- design-advisor rec 3 — obeyed: 90105ca
- design-advisor rec 4 — obeyed: 90105ca
- design-advisor rec 5 — obeyed: 90105ca
- design-advisor rec 6 — obeyed: 90105ca
- design-advisor rec 7 — obeyed: 58b1033
- design-advisor rec 8 — deferred: sessions/session-142-summary.md
- design-advisor rec 9 — refused: keep `--sync-fleet`; no rename and no `--sync` alias this session (the report line now reads "roles + hooks"; a rename/alias is cosmetic and churns help/tests/chitra references — deferred to a future polish, not shipped)
- design-advisor rec 10 — obeyed: 58b1033

**qa-specialist — 3 recommendations (ran verify 11/11 · fixture 9/9 · 460 tests LIVE, 0 hollow; falsification bit RED for the right reason then reverted clean).**

- qa-specialist rec 1 — deferred: sessions/session-142-summary.md
- qa-specialist rec 2 — deferred: sessions/session-142-summary.md
- qa-specialist rec 3 — deferred: sessions/session-142-summary.md

**fidelity-reviewer — 4 recommendations + the independent `obeyed:` judgments (cold ACCEPT, 5/6→6/6, all 9 obeyed-checks `implemented:`).**

The independent `obeyed:` judgments of the design-advisor's + tech-lead's dispositions live in
`sessions/session-142-review.md` (read by `vajra next --check-obeyed 142`).

- fidelity-reviewer rec 1 — deferred: sessions/session-142-review.md
- fidelity-reviewer rec 2 — deferred: sessions/session-142-summary.md
- fidelity-reviewer rec 3 — deferred: sessions/session-142-summary.md
- fidelity-reviewer rec 4 — refused: the drifted branch already prints the `--overwrite-drifted` guidance for any drifted file (hooks included); a dedicated hook-drift stdout line is cosmetic, and the retroactive-limit disclosure is in the addendum + demo before_after

## Guardrails

- **Scope = the PURE-RENDER non-fleet scaffold files only** (hooks + constitution). `CONSTRAINTS.yaml`
  and `.claude/settings.json` are OUT of auto-upgrade — user-tuned / already-merged respectively. 1 story.
- **Honest backward-compat (the fakest green to avoid claiming).** Every pre-S142 install has UNSTAMPED
  hooks/constitution → `Drifted` on first contact → still needs one `--overwrite-drifted`. Smooth
  going-forward, not retroactive (same honest limit as S141).
- **The stamp must not change behavior** — a stamped hook must still run identically; assert it.
- **Preserve the no-churn property** — an `UpToDate` file is never rewritten.
- **Do NOT add an 8th top-level command** (max 7) — a flag on `vajra init`.
- **The fixture must fail for the RIGHT reason** (S122); positive control asserts clean exit 0 (S134).
- **Budget every subagent dispatch TIGHT: named files, never "read the repo"** (S134; $20/mo plan).
- Un-forgeable `VAJRA_ALLOW_COMMIT=142` on every commit; attest LAST (`--inputs-sha 142`), run the FULL
  `verify-closeout.sh` on the branch BEFORE merging (S83). **After S142:** the chitra dogfood becomes a
  full-loop test (roles + hooks + constitution all upgrade smoothly). **Next GT: S145.**

## Delta (vs ROADMAP — OpenSpec markers)

- `+` the render stamp generalises to shell + markdown scaffold files; hooks + constitution gain the
  four-state smooth upgrade.
- `~` the S141 upgrade path (roles only) widens to all pure-render scaffold files — the upgrade loop is
  complete for everything Vajra owns byte-for-byte.
- `-` the "non-fleet scaffold files are add-only" limit (S141 disclosed remainder) — retired for pure
  renders; disclosed as still-present for `CONSTRAINTS.yaml` (user-owned, by design).
