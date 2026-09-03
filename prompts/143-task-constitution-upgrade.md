# Session 143 — The constitution joins the smooth upgrade (split fill from governed body)

> **Status: APPROVED** — founder picked **A** at the S143 open ("start session 143 all approved") and
> confirmed the target in chat: the constitution `.ai/AGENTS.md` becomes the last pure render that
> `vajra init --sync-fleet` upgrades in place. **Founder directive in force (S142): ONE update command
> upgrades everything** — no 8th command, no `--sync-constitution` sibling. **Start S143 in a FRESH
> chat**, where the agent creates `session-143-constitution-upgrade` and commits this prompt as its
> first act. Founder directive in force (S118): README/VISION claims are the target spec, never softened.

## Why this session exists (finishes the founder's #1 completeness priority)

S141 gave the smooth upgrade to the fleet roles; S142 gave it to the shell hooks. The constitution
`.ai/AGENTS.md` is the **last pure-ish render Vajra owns** and the ONE it still cannot upgrade:

| File | On upgrade today |
|---|---|
| `.claude/agents/*.md` (roles) | ✅ S141 — stamped, auto-upgrades, edits protected |
| `.ai/hooks/hook-*.sh` (hooks) | ✅ S142 — stamped, auto-upgrades, edits protected |
| `.ai/AGENTS.md` (the constitution) | ❌ **add-only — the named S142 deferral, this session** |
| `.ai/CONSTRAINTS.yaml` (the rules) | ⛔ user-owned by design (stays out — no canonical) |

The blocker S142 named: `.ai/AGENTS.md` is a per-install **filled** template (`{PROJECT_NAME}`×5 etc.),
so `sync_fleet(root)` cannot reproduce a project's on-disk bytes and a naive rewrite would clobber that
project's own identity. The fix DECISION-007's S142 addendum already scoped: **split `TPL_AGENTS` into a
user-owned filled header and a byte-identical GOVERNED BODY, and stamp / auto-upgrade only the body.**
The `MarkdownComment` stamp syntax is already built + unit-tested for exactly this.

## The one story

Restructure the scaffolded `.ai/AGENTS.md` into two regions divided by a boundary sentinel — a
**user-owned header** (the `{PROJECT_NAME}` fill, never touched by sync) above it, and a
**byte-identical governed body** (load order · session loop · hard rules · comms — no fill) below it,
carrying a `<!-- vajra-render-sha: -->` stamp. Widen `--sync-fleet` so the constitution's **governed
body** gains the same four-state smooth upgrade — an untouched old body auto-upgrades in place while the
header above it is preserved verbatim; a user-edited body / unstamped-or-boundaryless file is refused
unless `--overwrite-drifted`. Still ONE command; no 8th top-level command.

## Design (dispatch the tech-lead FIRST, then let it bind the crew)

- **design-significant: yes** — this changes the on-disk shape of every install's constitution (a new
  boundary sentinel) and extends the four-state machine from whole-file to a **body-scoped** compare +
  rewrite. Cite `docs/decisions/DECISION-007-agent-fleet.md` + its **S141 and S142 addenda**, and add an
  **S143 addendum**.
- **The design questions the session must settle WITH the design-advisor (not assume):**
  1. **The boundary sentinel (the crux).** What line divides the user-owned header from the governed
     body, so classify/upgrade operate on the body ALONE? It must be: unambiguous, inert to a markdown
     reader, stable across installs, and self-evidently "do not edit below". Propose the exact literal
     (e.g. an HTML comment line) and where the stamp sits relative to it. Reuse the `MarkdownComment`
     `StampSyntax` — do NOT fork a fourth stamp path.
  2. **Body-scoped classify + rewrite.** The four states must be computed on the BODY region only:
     `UpToDate` = body matches canonical body; `StaleRender` = body's stamp self-verifies (untouched old
     render); `Drifted` = body edited, OR no boundary/stamp present (legacy + foreign files). Upgrade
     rewrites the body region and preserves the header bytes above the boundary **verbatim** — prove the
     header survives an upgrade byte-for-byte.
  3. **The legacy migration story (the honest limit to get right).** Every pre-S143 install has a
     constitution with NO boundary and NO stamp → it classifies `Drifted` on first contact. Decide and
     DISCLOSE what a legacy user must do once: is `--overwrite-drifted` safe here (it would rewrite the
     WHOLE file, losing that project's `{PROJECT_NAME}` fill — likely NOT safe for a filled header), or
     is a one-time manual boundary insertion required? Pick the path that never silently destroys a
     user's filled header, and state it plainly. This is the session's fakest-green risk.
  4. **Does `CONSTRAINTS.yaml` stay out?** Yes (user-tuned, no canonical — S142). Confirm, don't reopen.
- **Rejected-alternatives must be stated** (a rationale with no rejected option is not a decision):
  e.g. un-filling the on-disk constitution to recover values (S142-rejected), a sidecar manifest
  (S141-rejected), rewriting the whole file including the header (destroys identity), a second command.
- tech-lead FIRST + design-advisor + fidelity-reviewer mandatory; record every required role's handoff
  (the close runs `check_required_crew`, S139).

## Acceptance (testable, EARS-style)

1. WHEN `.ai/AGENTS.md` is scaffolded, THEN it carries a boundary sentinel dividing a `{PROJECT_NAME}`
   header (user fill) from a governed body, and the governed body carries a `<!-- vajra-render-sha: -->`
   stamp whose hash re-derives from the body-minus-stamp (pure round-trip); the stamp is inert to a
   markdown reader and the file still reads as valid markdown.
2. WHEN a scaffolded `.ai/AGENTS.md` is on disk, THEN body-scoped classification returns the four states
   (Missing · UpToDate · StaleRender · Drifted) as a pure function of (on-disk file, canonical body),
   computed on the body region alone; a file with no boundary or an unverifiable body stamp is `Drifted`.
3. WHEN `--sync-fleet` runs against a `StaleRender` constitution, THEN its governed body auto-upgrades
   WITHOUT `--overwrite-drifted` (reported by name) and the user header above the boundary is preserved
   BYTE-FOR-BYTE; a `Drifted` body is refused (exit 1) unless `--overwrite-drifted`; `CONSTRAINTS.yaml`
   is never touched. Proven by a falsifiability fixture that goes RED for the right reason + a
   clean-exit-0 positive control, AND an explicit assertion the header survives the upgrade unchanged.
4. WHEN a fresh `vajra init` scaffolds a project and the sync runs immediately after, THEN roles + hooks
   + the constitution are ALL `UpToDate` and nothing is rewritten (idempotent, no churn) — proven LIVE
   in a real empty dir with the real release binary.
5. `## Design` + a DECISION-007 **S143 addendum** record the boundary sentinel, the body-scoped
   classify/rewrite, the legacy migration path (disclosed honestly), and why the header is never touched.
6. `scripts/verify-session-143.sh` (exit 0, class tally) + `demo-session-143.sh` (≥4 sprint markers) +
   `sessions/session-143-summary.md` (full fidelity map + 3 ranked candidates). Cold `fidelity-reviewer`
   ACCEPT; every `obeyed:` disposition judged `implemented:` by a different role.

## Design decision (settled S143 with the design-advisor)

**design-significant: yes.** Cites `docs/decisions/DECISION-007-agent-fleet.md` + its S141 and S142
addenda; recorded as the **S143 addendum**. It does NOT deviate from what it cites — S142's addendum
pre-scoped this exact work ("split `TPL_AGENTS` into a user-owned filled header and a byte-identical
governed body, and stamp/auto-upgrade only the body").

- **Boundary sentinel:** `<!-- vajra:governed-body - do not edit below this line - vajra owns and
  upgrades these bytes -->` (`GOVERNED_BODY_SENTINEL`). HTML-legal (single hyphens, no `--`), no fill
  token, inert to markdown. First line of the governed body; the `<!-- vajra-render-sha: -->` stamp
  (reused `MarkdownComment` `StampSyntax` — no fourth path) is the last line, and the hash COVERS the
  sentinel.
- **Body-scoped classify/rewrite:** a sync target carries `boundary: Option<&'static str>`. Roles/hooks
  pass `None` (whole-file, byte-identical S141/S142 path). The constitution passes `Some(sentinel)`.
  `body_region()` slices from the sentinel; classify runs the state machine on that region against a
  body-only `canonical`; `write_target` keeps the header above the sentinel VERBATIM.
- **Legacy migration (the fifth state):** a pre-S143 boundaryless constitution is `NeedsBoundary` —
  refused even under `--overwrite-drifted` (which would destroy the fill), with the exact sentinel
  printed. One-time fix: paste the sentinel above `## Mandatory Load Order`, then
  `vajra init --sync-fleet --overwrite-drifted`. A DELETED constitution warns "run `vajra init`".
- **`CONSTRAINTS.yaml` stays out** (user-tuned, no canonical). Rejected alternatives (whole-file rewrite,
  un-fill/scavenge, auto-insert the sentinel, force a boundaryless file, a `boundary_aware` bool, a
  fourth stamp path, a second command, a sidecar) are named in the addendum.

## Plan (ordered — cite the acceptance criteria each step covers)

1. Dispatch the tech-lead FIRST; let it bind the crew (design-advisor + fidelity-reviewer required at
   least). covers: 6
2. Settle the boundary sentinel + body-scoped model with the design-advisor; record the DECISION-007
   S143 addendum. covers: 5
3. Restructure `TPL_AGENTS` into header + boundary + governed body; scaffold the body already stamped so
   a fresh init is `UpToDate`; add a body-scoped classify that reuses `MarkdownComment`. covers: 1, 2
4. Widen `--sync-fleet` to upgrade the constitution's body in place (header preserved verbatim), refuse
   a drifted/boundaryless one unless `--overwrite-drifted`. Prove with the constitution fixture (RED for
   the right reason + header-survives assertion + clean exit-0 control). covers: 3, 4
5. `verify-session-143.sh` + `fixture-session-143.sh` + `demo-session-143.sh` + the summary; cold
   `fidelity-reviewer` ACCEPT. covers: 1, 6

## Execution (the Coder gate — landing sha per step)

- step 1 — done: 6fdb4eb. covers: 6
- step 2 — done: 3afd229. covers: 5
- step 3 — done: 08824c3. covers: 1, 2
- step 4 — done: d1d9d2c. covers: 3, 4
- step 5 — done: c4b0a12. covers: 1, 6

## Advice (every recommendation from this session's advisors, answered)

Each `obeyed:`/`refused:`/`deferred:` answers one numbered rec. `vajra next --check-advice 143` blocks
the close until every rec is answered; the design-advisor's `obeyed:` dispositions are judged
independently by the fidelity-reviewer (a different role — S131), recorded in
`sessions/session-143-review.md`.

**tech-lead — 7 recommendations (crew bound FIRST; required = design-advisor · qa-specialist ·
fidelity-reviewer; six deferred-budget).**

- tech-lead rec 1 — obeyed: 3afd229
- tech-lead rec 2 — obeyed: 08824c3
- tech-lead rec 3 — obeyed: 08824c3
- tech-lead rec 4 — obeyed: 08824c3
- tech-lead rec 5 — deferred: sessions/session-143-summary.md
- tech-lead rec 6 — obeyed: 08824c3
- tech-lead rec 7 — deferred: sessions/session-143-summary.md

**design-advisor — 10 recommendations (settled all four forks; the S143 addendum records the design).**

- design-advisor rec 1 — obeyed: 3afd229
- design-advisor rec 2 — obeyed: 08824c3
- design-advisor rec 3 — obeyed: 08824c3
- design-advisor rec 4 — obeyed: 08824c3
- design-advisor rec 5 — obeyed: 08824c3
- design-advisor rec 6 — obeyed: 08824c3
- design-advisor rec 7 — obeyed: 08824c3
- design-advisor rec 8 — obeyed: 3afd229
- design-advisor rec 9 — obeyed: 08824c3
- design-advisor rec 10 — obeyed: 3afd229

**qa-specialist — 4 recommendations (ran verify 13/13 · fixture 9/9 · 469 tests LIVE, 0 hollow;
falsification clobbered the header → HDR/MIG RED for the right reason, then reverted, tree clean).**

- qa-specialist rec 1 — obeyed: b9679b5
- qa-specialist rec 2 — deferred: sessions/session-143-summary.md
- qa-specialist rec 3 — obeyed: b9679b5
- qa-specialist rec 4 — deferred: sessions/session-143-summary.md

**fidelity-reviewer — 5 recommendations + the independent `obeyed:` judgments (cold ACCEPT, 5/6 SHIPPED
at review → 6/6 at close; all 10 design-advisor + 5 tech-lead obeyed dispositions `implemented:`).**

The independent `obeyed:` judgments of the design-advisor's + tech-lead's dispositions live in
`sessions/session-143-review.md` (read by `vajra next --check-obeyed 143`).

- fidelity-reviewer rec 1 — obeyed: b9679b5
- fidelity-reviewer rec 2 — obeyed: b9679b5
- fidelity-reviewer rec 3 — obeyed: b9679b5
- fidelity-reviewer rec 4 — obeyed: b9679b5
- fidelity-reviewer rec 5 — refused: `source-has-boundary-wiring` stays labeled `struct` — it is an honest wiring/architecture grep whose behavior is independently proven by the exec/nested checks beside it; relabeling is cosmetic (acknowledged, no code change)

## Guardrails

- **Scope = the constitution `.ai/AGENTS.md` only.** `CONSTRAINTS.yaml` stays user-owned;
  `.claude/settings.json` stays merged. 1 story.
- **Never silently destroy a user's filled header** — the whole point of the split. An upgrade preserves
  header bytes verbatim; if it cannot (no boundary), it refuses and says what to do. This is the fakest
  green to avoid claiming: "smooth" must not mean "clobbered the project name".
- **Honest backward-compat.** Every pre-S143 install has a boundaryless/unstamped constitution →
  `Drifted` on first contact. State the one-time migration plainly (the S141/S142 limit, restated).
- **Do NOT fork a fourth stamp path** — reuse `MarkdownComment` `StampSyntax`.
- **Preserve the no-churn property** — an `UpToDate` file is never rewritten.
- **Do NOT add an 8th top-level command** (max 7) — a flag on `vajra init`.
- **The fixture must fail for the RIGHT reason** (S122); positive control asserts clean exit 0 (S134).
- **Budget every subagent dispatch TIGHT: named files, never "read the repo"** (S134; $20/mo plan).
- Un-forgeable `VAJRA_ALLOW_COMMIT=143` on every commit; attest LAST (`--inputs-sha 143`), run the FULL
  `verify-closeout.sh` on the branch BEFORE merging (S83). **After S143:** the upgrade loop is complete
  for every pure render Vajra owns; the chitra full-loop dogfood (roles + hooks + constitution) becomes
  the next natural test. **Next GT: S145.**

## Delta (vs ROADMAP — OpenSpec markers)

- `+` the constitution `.ai/AGENTS.md` splits into a user-owned header + a governed body; the body gains
  the four-state smooth upgrade via the already-built `MarkdownComment` stamp.
- `~` the S141/S142 upgrade path widens from whole-file renders to a **body-scoped** render inside a
  filled file — the last pure render Vajra owns joins "one command upgrades everything".
- `-` the "constitution is add-only / deferred to S143" limit (S142 disclosed remainder) — retired;
  the only remaining add-only scaffold file is `CONSTRAINTS.yaml`, user-owned by design.
