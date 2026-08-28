# Session 136 — make Vajra's full 10-role fleet REAL in chitra (the upgrade path a real adopter needs)

> **Status:** APPROVED — founder, in chat at the S135 close (*"approved lets do this way"*), for the
> two-session arc: **S136 = this upgrade → S137 = the scatter dogfood** on the full crew.
> Founder pick: *"we need to fix it, make vajra upgrade in chitra"* — so the S137 scatter dogfood can
> run the FULL tech-lead crew on real chitra work, not the old thin governance.
>
> Founder directive in force (S118): README/VISION claims are the target spec, never softened.

## Type

**CODE.** Max 2 assumptions · 2 retries · ~2h · 1 story · new chat · approval token before any commit.

## Why this session — the gap, measured live at the S135 close

chitra (`/Users/suman/playground/chitra`) is the one project outside Vajra, and it carries **4 of
Vajra's 10 agents**: `researcher · plan-advisor · qa-specialist · fidelity-reviewer`. It is **missing
6**: `requirements-analyst · design-advisor · implementation-advisor · demo-producer ·
release-coordinator`, **and the `tech-lead` itself**. So the S135 tech-lead + `--check-crew` gate
cannot run there at all — the fleet is real here and absent in the one place it would be used.

**And there is no clean way to fix it: Vajra has NO `vajra upgrade` command** — only `vajra init`
with a skip-if-present convention. A real adopter who governed with an older Vajra and wants the new
fleet has no supported path. **That missing upgrade path is this session's most likely headline
finding**, and it is exactly the "we are building it for the user, not for us" gap the founder keeps
naming (S128, S134).

## The one story

Bring chitra's fleet to the full 10 roles AND make the crew gate actually BIND there (installed ≠
used — S125/S129), by way of the upgrade path a real adopter would use: **either build a real
`vajra` upgrade/sync mechanism** (if the design-advisor judges it bounded enough for one session) **or
document the manual procedure honestly** and record the missing-command as a named product gap. Do
NOT do the scatter chart work — that is S137.

## Two repos kept straight

- **chitra is where the scaffold lands** — the 6 missing agent files (and any refreshed scaffold)
  under **chitra's OWN constitution and hooks** (`chitra/.ai/`, `chitra/CLAUDE.md`). Obey chitra's
  rules inside chitra; do NOT import Vajra's, and do NOT disturb chitra's in-flight session-16 work
  or its existing 4 role files.
- **Vajra-side code changes** (if an upgrade command is built) land here under Vajra's rules.

## Deliverables

- **chitra's `.claude/agents/` carrying all TEN role files**, each rendered from Vajra's ONE
  canonical source (`fleet::render_subagent_definition`) and matching it byte-for-byte — never
  hand-typed (the S104/S99 no-drift rule).
- **The crew gate BINDING in chitra, proven live** — `vajra next --check-crew <chitra-session>` run
  inside chitra behaves correctly (blocks with no tech-lead handoff, from any session — the S135
  no-threshold rule), not merely "the files are present."
- **The upgrade path resolved on the record:** either a real, idempotent Vajra upgrade/sync mechanism
  (adds MISSING scaffold to an existing governed project, skip-if-present for what exists, never
  clobbering local edits) — OR a documented manual procedure — with the "no upgrade command existed"
  gap named as the headline finding and its fix scoped for a future session if not built here.
- `scripts/verify-session-136.sh` (exits 0; machine-local checks FAIL-on-absent, never skip — S69) +
  `sessions/session-136-summary.md` with exactly 3 ranked next candidates (one of them S137, the
  scatter dogfood — `prompts/137-task-chitra-scatter-lock-dogfood.md` is already drafted).
- chitra proved UNDISTURBED the S134 four ways outside the declared scaffold paths (HEAD · index hash
  · stash list · branch), every new path pre-declared by name.

## Acceptance (testable, EARS-style)

1. WHEN chitra's `.claude/agents/` is listed, THEN all ten role files are present
   (`researcher … release-coordinator … tech-lead`), each matching `fleet::render_subagent_definition`
   byte-for-byte — a hand-typed or drifted copy FAILS, never a silent skip (S69).
2. WHEN `vajra next --check-crew <chitra-session>` runs INSIDE chitra with no tech-lead handoff, THEN
   it BLOCKS (exit 1) naming the tech-lead as the first-and-mandatory dispatch — proven live, from a
   session number below 133 (the S135 no-threshold rule holds in a brownfield project).
3. The upgrade path is on the record: either `vajra <upgrade-cmd>` adds exactly the six missing role
   files to chitra WITHOUT touching the four it already has and WITHOUT clobbering any local edit
   (idempotent, re-runnable, proven), OR a documented manual procedure exists AND the missing-command
   gap is named as a finding with a scoped fix — the session states plainly which it did and why.
4. chitra's in-flight session-16 work and its four existing role files are UNDISTURBED (four ways);
   exactly the declared scaffold paths changed.

## Design (the Architect gate — the design-advisor was dispatched FIRST, the S133 mandate)

design-significant: yes

**Verdict: BUILD, not document-only** — and the reason it is bounded is structural, not optimism.
`src/cli/init.rs:594-599` already carries the exact loop an upgrade needs
(`for role in crate::fleet::ROLES` → `render_subagent_definition`), and `scaffold()` already carries
the exists-check/write/skip branching that drives it. The upgrade path is that same loop re-entered
and scoped down from the ~40-entry `files()` list to the role definitions alone — one function plus a
thin flag, not new machinery. It rides `vajra init --sync-fleet [--dry-run] [--overwrite-drifted]`:
a FLAG on an existing command, so the seven-command ceiling holds (S128 non-goal).

**The finding that shaped the design.** chitra's four *present* role files were not merely old — each
was missing the entire appended protocol block (`## Numbered recommendations`, `## Judging an obeyed:
disposition`) that teaches a role to emit the `rec N —` lines the Advice and Obedience gates parse.
So chitra's installed roles could not have produced parseable advice, and `--check-advice` there would
have read nothing and reported nothing wrong. **`skip-if-present` can ADD; it can never UPDATE** — and
that, not the six absent files, is the real gap a brownfield adopter falls into.

**The limit, disclosed rather than dressed up.** Vajra CANNOT distinguish a stale render from a
user's own edit: both are just bytes that differ from the current render, and nothing on disk records
which Vajra wrote a given file. So the command does not guess — it reports `Drifted`, refuses to
write, and names the flag a human uses to take responsibility for the call. A classifier built on git
blame or timestamps was considered and rejected: it would invent provenance that was never recorded
(the class of machinery the S122/S123 addenda already reject in favour of a disclosed floor).

**Deviation, stated so the gate does not have to infer it.** This prompt's inherited guardrail says
*"do NOT disturb chitra's 4 existing role files"*, and acceptance criterion 1 requires all ten to
match the canonical render byte-for-byte with a drifted copy FAILING. Given the measured drift both
cannot hold. **Criterion 1 governs:** `DECISION-007` defines every `.claude/agents/*.md` as a pure
render that is never hand-typed (the S104/S99 no-drift rule), so refreshing the four CLOSES a drift
condition the record already forbids rather than introducing one. Executed as a pre-declared, named
action — all ten paths listed before a byte was written — and the four files were tracked and clean
in chitra's git, so every refresh is reversible with one `git checkout`.

**Spine record cited:** `docs/decisions/DECISION-007-agent-fleet.md`, extended by a new
**S136 addendum** (the file's own established pattern, S111 → S135), not a new DECISION-008 — a
general drift/upgrade mechanism for all scaffold types stays out of scope; this is fleet-only.

design-advisor: dispatched — `.ai/handoffs/session-136-design-advisor.md`
tech-lead: dispatched FIRST — `.ai/handoffs/session-136-tech-lead.md`

## Plan (ordered — cite the acceptance criteria each step covers)

1. Dispatch the design-advisor FIRST; decide build-a-command vs document-the-manual-path. covers: 3
2. Bring chitra to all ten role files from Vajra's canonical source (command or manual). covers: 1, 3
3. Prove the crew gate BINDS live inside chitra from a below-133 session. covers: 2
4. Prove chitra undisturbed outside the declared paths; write verify + summary. covers: 4

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>

## Advice (every recommendation from this session's advisors, answered)

(Filled during S136. `--check-advice 136` blocks until every rec is answered; `--check-obeyed 136`
blocks until each `obeyed:` carries an independent judgment from a role that is not the advisor.)

## Guardrails

- **chitra has its own constitution and hooks — read `chitra/.ai/` and obey chitra's rules inside
  chitra. Do NOT import Vajra's. Do NOT disturb its in-flight session-16 work or its 4 existing role
  files** (S134's rule).
- **Installed ≠ used (S125/S129).** Copying six files is not the deliverable — the crew gate must
  actually BIND in chitra, proven live, or this session shipped decoration.
- **Do NOT do the scatter chart work — that is S137** (`prompts/137-…`). One story.
- **Budget every subagent dispatch TIGHT: a narrow brief and NAMED FILES, never "read the repo"**
  (S134); report the RAW subagent token total, never new-tokens-only (S134 45× / S135 20×) via
  `vajra next --crew-cost`. If a dispatch dies on a spend limit, record it INCOMPLETE (S134).
- **An upgrade command, if built, must be idempotent and MUST NOT clobber a user's local edits** —
  skip-if-present is the existing convention; adding-missing is the new behaviour. A command that
  overwrites a user's customised agent file is worse than no command.
- Un-forgeable commit marker on every Vajra-side commit; obey chitra's commit rules on the chitra side.
- Attest LAST (S69/S131): recompute `--inputs-sha 136` after every prompt edit; run the full
  `verify-closeout.sh` on the branch BEFORE merging (S83). Next GT: S140.

## Delta (vs ROADMAP — OpenSpec markers)

- `+` chitra gains the six missing role files + the `tech-lead` — the full 10-role fleet, so the S135
  crew gate is real in the one outside project; possibly a new Vajra upgrade/sync mechanism.
- `~` the `tech-lead` stops being a Vajra-only feature; the brownfield adopter's upgrade path moves
  from "unsolved" to either "built" or "documented + scoped".
- `-` nothing retired.
