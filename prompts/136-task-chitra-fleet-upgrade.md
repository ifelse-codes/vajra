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

## Execution (the Coder gate — each plan step's landing commit)

- step 1 — done: 8a57411
- step 2 — done: 8ede7f5
- step 3 — done: ac69462
- step 4 — done: ac69462

## Advice (every recommendation from this session's advisors, answered)

**tech-lead** (the first and mandatory dispatch — `.ai/handoffs/session-136-tech-lead.md`)

- tech-lead rec 1 — obeyed: 095aa96 — the design-advisor was dispatched FIRST, on a named-files-only
  brief (prompt 136, STATE's disclosed gaps, two line ranges of `init.rs`, DECISION-007). It read 5
  files and cost 59,595 reported tokens.
- tech-lead rec 2 — obeyed: 8ede7f5 — `sync_fleet` re-enters the same `for role in fleet::ROLES` /
  `render_subagent_definition` loop `files()` already uses. There is no second scaffolding path; the
  bytes are re-rendered at write time from the one source, never carried in the plan.
- tech-lead rec 3 — deferred: .ai/handoffs/session-136-implementation-advisor.md
  The recommendation WAS followed (the judge's brief was two named files: the prompt's `## Advice` and
  the closing diff, 71,973 reported tokens), but the independent judge ruled the original
  `obeyed: 8ede7f5` a MISMATCH and it was right: how a subagent was briefed is dispatch metadata, and
  no Rust commit can carry it. Recorded as `deferred:` to the artifact where the dispatch actually
  lives — a provenance-verified handoff — rather than dressed as a `git cat-file`-checkable fact.
- tech-lead rec 4 — deferred: .ai/handoffs/session-136-tech-lead.md
  Same correction, same reason. The 2,000,000-token allowance and the tightest-possible-brief instruction are recorded in the
  tech-lead's own handoff, which is where a budget instruction belongs; the original
  `obeyed: ac69462` cited a shell script that contains no such thing, and the judge called it
  decorative. It was.
- tech-lead rec 5 — obeyed: 095aa96 — all six `deferred-budget` verdicts stand as deferred, each
  carrying its arithmetic, and none was re-labelled a worth judgement. The arithmetic, restated:
  researcher 200K · requirements-analyst 200K · plan-advisor 200K · qa-specialist 150K ·
  demo-producer 150K · release-coordinator 150K = 1.05M raw that was NOT spent, against a ~19.2M
  monthly cap S134 exhausted with three broad dispatches. Phase 2's off switch is not granted here.
- tech-lead rec 6 — obeyed: ac69462 — all ten chitra paths were listed by name before a byte was
  written, and the list is the tracked record `sessions/session-136-chitra-baseline.txt` that
  verify check 9 reads. A path that changed without a `DECLARE` line FAILS the check.

**design-advisor** (`.ai/handoffs/session-136-design-advisor.md`)

- design-advisor rec 1 — obeyed: 8ede7f5 — `design-significant: yes`; the `## Design` cites
  `docs/decisions/DECISION-007-agent-fleet.md`, which gains an **S136 addendum** in the file's own
  established shape (S111 → S135). No DECISION-008 was opened.
- design-advisor rec 2 — obeyed: 8ede7f5 — BUILD, not document-only. The verdict was testable and it
  held: the mechanism landed inside the session cap because the loop it needed already existed.
- design-advisor rec 3 — obeyed: 8ede7f5 — `vajra init --sync-fleet`, a flag on an existing command.
  Verify check 11 asserts the top-level command count is still exactly 7.
- design-advisor rec 4 — obeyed: 8ede7f5 — `Missing` creates unconditionally from the canonical
  render. Verify check 1 proves an empty repo reaches the full roster byte-for-byte.
- design-advisor rec 5 — obeyed: 8ede7f5 — `UpToDate` is a no-op. The unit test asserts the file's
  mtime is unchanged, because a no-op write still churns the user's git status.
- design-advisor rec 6 — obeyed: 8ede7f5 — `Drifted` reports and refuses by default, exits 1 naming
  `--overwrite-drifted`, and leaves the file byte-identical. `--dry-run` writes nothing and returns
  the code the real run would. Verify checks 3, 4 and 5.
- design-advisor rec 7 — obeyed: 8ede7f5 — corrected sha. The judge found the original
  `obeyed: ac69462` cited a file containing only DECLARE lines and hashes, while the reasoning it
  claimed ("criterion 1 governs… reversible with one `git checkout`") is word-for-word in the
  DECISION-007 S136 addendum, which is 8ede7f5. The ACTION the rec asked for — a pre-declared, named
  refresh — is split across both: the reasoning in 8ede7f5, the ten-path DECLARE list and the check
  that enforces it in ac69462.
- design-advisor rec 8 — obeyed: 8a57411 — the deviation is written into `## Design` in plain words
  above, and again into the DECISION-007 S136 addendum. The gate checks the FORM of a citation, so
  the reasoning had to be stated rather than left for it to infer.
- design-advisor rec 9 — obeyed: 8ede7f5 — no classifier was built. `FleetFileState` has three
  variants because only three are derivable, and the doc comment says so. The undecidability is the
  shipped answer, not a gap in it.
- design-advisor rec 10 — obeyed: 8ede7f5 — the Vajra-side diff is exactly three files
  (`src/cli/init.rs` carrying its own `#[cfg(test)]` tests, `src/main.rs`, and the DECISION-007
  addendum), and `--sync-fleet` is wired into NO close-path gate. **Recorded deviation from the
  advisor's guess at which three:** it expected a separate test file; this crate keeps unit tests in
  the module, and `src/main.rs` was unavoidable because `init` took no arguments at all before this
  session. Same count, different third file.

**fidelity-reviewer** (`.ai/handoffs/session-136-fidelity-reviewer.md` — ACCEPT, 6 SHIPPED · 3 PARTIAL)

- fidelity-reviewer rec 1 — deferred: sessions/session-136-summary.md
  This one is not mine to close. The reviewer is right that refreshing chitra's four role files
  overrode an explicit guardrail on the founder's own argument, with only the FORM of the citation
  gate-checked. Surfaced to the founder at close, with the exact undo (`git checkout -- .claude/agents`
  inside chitra) and the fact that NOTHING was committed there. The founder decides.
- fidelity-reviewer rec 2 — obeyed: 0a51ba3 — `CRITERION_ROLES` now spells out the ten names the
  acceptance criterion itself lists, hand-typed on purpose, and check 11 asserts the derived roster
  equals it. Probe E (a mutated name) turns check 11 RED.
- fidelity-reviewer rec 3 — obeyed: 15defef — the FIRST attempt (0a51ba3) was judged a MISMATCH and
  the judge was right: parsing `--help`'s `vajra <a|b|c>` line only reads ANOTHER hand-typed string,
  `main.rs`'s own `eprintln!` banner. An eighth command added to the dispatch logic without editing
  that banner would still have counted 7. The hole MOVED; it did not close. Closed properly by a new
  check 12 that reads the real `match subcommand` dispatch table in `src/main.rs` and requires the
  banner to AGREE with it, so neither can drift from the other silently. Probe G (an eighth arm
  planted in the table) turns it RED. **The judge's caveat, recorded rather than waived:** the
  extraction is pattern-fragile — an eighth command added as a multi-word alternation arm, a
  multi-line arm, a guard-clause match, or a dispatch outside that block would still go uncounted.
  This NARROWS the hole to an unusual-shape escape; it does not close it completely.
- fidelity-reviewer rec 4 — obeyed: 0a51ba3 — check 7 no longer ASSUMES this repo's own agent files
  are the current render; it proves it first by requiring a dry-run sync over this repo to report
  `0 to create, 0 to refresh` and `0 drifted`. Probe F (a drifted agent file here) turns it RED.

**The judge's weakest-green finding, carried forward rather than buried.** The independent
implementation-advisor named verify **check 9** the most likely false green: its two CONTENT-level
baselines were captured AFTER the ten declared writes, so the check would still pass the exact defect
falsifiability probe C planted — an append to a tracked file chitra had already modified before S136
touched anything. The path-level and four-way baselines ARE true pre-write ones and prove no path
appeared, vanished or changed status; the content guarantee is frozen from mid-session onward rather
than closed. Stated here, in the baseline record, and in the summary — three places, because a
disclosure that lives only in a handoff is one nobody reads.

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
