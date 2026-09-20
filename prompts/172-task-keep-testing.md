# Session 172 — Keep testing rudra, fix what it finds

> **Status:** APPROVED — the founder pasted his rudra session 03 run, said "can we fix all of these", then "commit" twice and "i want full close out for 172". Goal and Acceptance were filled from that run, as this brief said they would be.

## Type
- **CODE**, interactive. Same loop as S171: he uses Vajra for real, pastes what he hits, each finding is fixed → shown → committed on his word.

## Why this and not the release (founder's pick, 2026-09-17)
S171's method produced 34 real findings in one evening — more than the previous ten sessions of
self-audit produced between them. The parts of Vajra his run has NOT yet exercised are exactly the
parts most likely to be broken: a demo actually watched, a ground-truth session (rudra hits one at
its session 05), a second project, and the close gate's new `three-next-options` check meeting a
real summary.

## How this session runs
1. The founder runs rudra session 03 (execution OMS/EMS — his own next story) with
   `VAJRA_ALLOW_COMMIT=03 VAJRA_ALLOW_PUBLISH=1 vajra claude`.
2. He pastes what he hits, in order. Each finding is recorded in the table below with a severity.
3. Small fix → shown → his word → commit. One command at a time in his terminal.
4. Stop when he says stop. Whatever is not fixed is written down, not quietly dropped.

## Carried in from S171 (build these even if the run is clean)
1. **An executable test for the commit/push belt split** (S171 pass-3 review rec 7, deferred by name
   to this session). `.githooks/pre-commit` and `pre-push` decide whether the committer is a human
   or an agent, and nothing runs them: the six cases were checked by hand once. Follow the
   `tests/close_gate_options.rs` pattern — a temp repo, the real hook file, `CLAUDECODE` set and
   unset, with and without `VAJRA_ALLOW_COMMIT`, on `main` and on a session branch.
2. **Watch F31 again.** The boot checklist names the tech-lead as the first move and rudra's session
   02 still planned first. If it happens a third time, the answer is a gate, not better wording —
   and that is a founder decision, not the agent's.

## Findings (filled in live)
| # | Step | What happened | Severity |
|---|---|---|---|
| F35 | design gate, rudra S03 | Vajra sees **none** of rudra's 10 ADRs (`docs/ADR/ADR-010-*.md`: capital folder + `ADR-` prefix; Vajra looks for `docs/adr/NNNN-*.md`). The citation check is silently waived, so a made-up ADR would pass. The design-advisor's role text points at a folder that does not exist. | 🔴 high |
| F36 | writing the prompt | The co-pilot loader paused the prompt write to "read TASK.md + ROADMAP" although the agent had read them at boot. The hook never checks what was read; it pauses once per session regardless. One wasted round trip. | 🟡 medium |
| F37 | boot | Boot shows `.ai/SESSION=02 (stale)` while starting 03; the counter moves only at `--advance`, and nothing tells the agent when. | ⚪ low (watch) |
| F38 | S02 handover | rudra's TASK.md names `03-execution-oms-ems.md`; the real file is `03-task-execution-oms-ems.md`. Source not yet traced. | ⚪ low |
| F39 | advancing into S03 | `vajra next --advance` re-judged **S02** (already merged) by rules synced in AFTER it merged (advice answers, demo gate). The agent had to go back and rewrite S02's paperwork before S03 could start. Old sessions punished by new rules. | 🔴 high |
| F40 | S02/S03 demo | Demos compared "before" against `main`. Once the session merges, `main` IS the after, so the demo flips to red and blocks the next advance. The agent wrote `git show main:`; nothing in Vajra's template warns against it. | 🟡 medium |
| F41 | close | Closeout took real trial and error (session 52m): `--advance` needs a `y` (agent piped `yes \|`), crew rows must be `crew <role> — …` lines (a table parses as zero), the review sha must be computed after handoffs are committed. The agent saved these as a memory because Vajra's messages did not say them. | 🟡 medium |
| F42 | end of session | The founder had to ask for plain English again (twice in S02, once in S03). The close report is boxes and jargon; the plain version only came on request. | 🟡 medium |
| F43 | close | Agent said origin/main is behind because of "S02's local merge"; the extra commit is actually the founder's `Sync Vajra` commit made on main by the S171 upgrade. Wrong explanation told to the human. | ⚪ low |
| F44 | this close | The session guard reads a command's PROSE. Writing a closeout note that quoted the advance command in backticks armed the session boundary and blocked the write ("this chat already owns session 172"). Quoted strings are stripped before the scan; backticked text is not. Worked around by writing the file another way; not fixed. | 🟡 medium (open) |
| F31 | watch #3 | **Did not recur.** Tech-lead dispatched before any planning. | ✓ |
| + | fleet | The advice changed the work: plan-advisor caught a 22-vs-23 event-count error in a LOCKED spec (founder ruled 23); design-advisor corrected the tech-lead twice. | ✓ positive |

## Fixes landed (founder: "can we fix all of these" → "commit")
- F39 — `4fce12a` (advance reports on a merged session; Vajra's close check gains advice + live verify) · `b2c06d9` (projects' close check gains advice + live verify + live demo)
- F40 — `b2c06d9` (template: "before" = the start commit, never `main`) · `4fce12a` (no demo re-run for a merged session)
- F41 — `4fce12a` (empty-stdin hint on the advance question) · `b2c06d9` + `4fce12a` (review-hash order spelled out) · `5c5c350` (crew line format)
- F35 — `fb8b043` · F36/F38/F42 — `70d087e` · F37 — `5c5c350` · F43 — `4fce12a` (the releaser code; its commit message landed with `5c5c350`)
- Not reached by `--sync-fleet`: `darshan/SKILL.md` (new installs only); the boot banner carries the rule to existing projects.

## Goal
Keep Vajra honest against a real project. The founder ran his own `rudra` session 03 end to end
under `vajra claude`; nine problems came out of it (F35–F43) and all nine are fixed. The riskiest
untested change from S171 — the commit/push belt's human-vs-agent split — now has an executable
test.

## Deliverables
1. **Enforcement moved to where it can still work (F39).** A session the human has already merged
   is REPORTED on at `vajra next --advance`, never blocked; the blocking run is
   `scripts/verify-closeout.sh`, before the merge — which gained the checks that only lived in
   `--advance`: advice answered, verify live, demo live (projects' copy).
2. **The design check sees real ADR folders (F35)** — `docs/ADR/ADR-010-x.md` as well as
   `docs/adr/0010-x.md`; a made-up id still blocks; the design-advisor's own text says so.
3. **The demo cannot rot at merge (F40)** — the template pins "before" to the session's start
   commit, never `main`.
4. **The messages say what to do (F41)** — the advance question when there is no keyboard, the
   `crew <role> — …` line format, and when to compute `Review-Inputs-SHA`.
5. **Less friction, plainer words (F36, F37, F38, F42, F43)** — the reading pause skips files
   already read this session; the checklist names the session-number step; boot warns when the
   handover names a prompt file that does not exist; the speaking rule demands plain words; the
   ship check lists unpushed commits by name.
6. **The belt split is executable (S171 pass-3 rec 7)** — `tests/commit_belt.rs`, the real hook
   files in a temp repo, plus a fix to `verify-session-93.sh`, which only passed inside an agent
   shell.

## Acceptance
1. Starting a session after a merged one does not stop on the merged session's paperwork: every
   closing check prints `already merged by you — … reporting, not blocking`, and no live verify or
   demo re-run happens. *(run against a clone of rudra at its session 03)*
2. Nothing is lost by that: `scripts/verify-closeout.sh` (and the copy a project gets) runs
   `--check-advice`, `--check-qa` and — in the project copy — `--check-demo`, and FAILS when the
   binary cannot evaluate them. *(rudra S03 closed "all green" with 5 unanswered recommendations;
   the new check catches exactly that)*
3. `vajra next --design NN` lists ADRs stored as `docs/ADR/ADR-NNN-title.md`; a prompt citing a
   real one passes and one citing a made-up id blocks.
4. `tests/commit_belt.rs` covers the 11 cases the qa-specialist settled (8 commit, 3 push) and
   goes RED when the hook's agent detection is disabled.
5. The copilot loader names only files NOT already read this session, and stays silent when all
   of them were read.
6. Boot warns `the handover names prompts/03-execution-oms-ems.md — no such file. Did it mean
   prompts/03-task-execution-oms-ems.md?` on rudra's own S02 pointer, and is silent on this repo.
7. `cargo test` green, `cargo fmt --check` clean, and `vajra init --sync-fleet` on a real project
   (rudra) upgrades the changed files with 0 drifted.

## Design
- design-significant: yes

Enforcement moves from post-merge to pre-merge. `vajra next --advance` re-judged the session it
closes, but advance runs AFTER that session merged — so merged work was re-graded by rules synced in
later (rudra F39). `releaser::shipped_close()` now asks git whether `sessions/session-NN-summary.md`
is on main; if it is, every closing gate REPORTS instead of blocking and the slow live QA/demo
re-runs are skipped. The teeth move earlier, not away: `check_live_gate` in
`scripts/verify-closeout.sh` and `scripts/verify-closeout-scaffold.sh` runs `vajra next
--check-advice/--check-qa/--check-demo` BEFORE the merge. `src/architect` also widens record
discovery to `docs/ADR/` and to `ADR-010-title.md` names: rudra's ten real ADRs were invisible, so
the citation check was silently waived and a made-up id would have passed.

Cites DECISION-007 (S127 addendum: the Advice gate "wired into `--advance` on the CLOSING session";
S131 addendum: the fidelity gate "binds on the session being CLOSED"; S126 addendum: the
design-advisor cites a record under `docs/adr/` or `docs/decisions/`) and DECISION-010 ("the gate
binds only on the session being closed; old demos are never re-graded at close"). **DEVIATION**,
stated plainly because the Architect gate checks the form of a citation and never whether the design
obeys it: this session MOVES the moment DECISION-007's two wiring clauses lock, and in doing so
makes DECISION-010's rule true for the other gates. The S172 addendum to DECISION-007 records the
move by name; no new DECISION record — new information about a locked clause is an addendum (the
S122/S134 house pattern).

Rejected: grandfather merged sessions by a session-number threshold (S134 proved the threshold is
unknowable in a brownfield repo); version the rule set and pin each session to the rules it merged
under (a new store and a clock for n=1 evidence); delete the closing re-runs at advance and add
nothing (removes teeth instead of relocating them); leave the design gate waiving when `docs/adr/`
is absent (a silent waiver reads exactly like a pass — that is the rudra bug).

Honest risk: advance was the backstop and is not one any more. If `verify-closeout.sh` is not run on
the branch before the merge, nothing enforces the closing gates at all. `shipped_close()` keys on a
single file being on main, so landing a summary early downgrades those gates to reporting while the
session is still live: self-granted jurisdiction, disclosed and not fenced. Wider ADR discovery
still proves only that a file exists.

## Plan
- step 1 — F39: a merged session reports, and the close check gains what advance stopped blocking. covers: 1, 2
- step 2 — F35: record discovery reads `docs/ADR/ADR-NNN-*.md`; the role text agrees. covers: 3
- step 3 — F40/F41: demo "before" pinned to the start commit; the three confusing messages say how. covers: 2
- step 4 — F36/F38/F42/F43: the reading pause, the boot warning, plain words, the named commits. covers: 5, 6
- step 5 — the belt split becomes executable, and the old S93 check stops depending on its caller. covers: 4
- step 6 — the session's own verify, demo, decision addendum and summary. covers: 1, 2, 3, 4, 5, 6, 7

## Execution
- step 1 — done: 4fce12a / b2c06d9
- step 2 — done: fb8b043
- step 3 — done: b2c06d9 / 4fce12a / 5c5c350
- step 4 — done: 70d087e / 5c5c350 / 4fce12a
- step 5 — done: bf3b515
- step 6 — done: 53601d2

## Advice

Three roles were dispatched: `tech-lead` (mandatory, first), `qa-specialist` (required by the
tech-lead) and `design-advisor` (the tech-lead deferred it; dispatched anyway once the F39 fix
turned out to move a locked clause — its own rec 5 said to).

**tech-lead** (`.ai/handoffs/session-172-tech-lead.md`):
- tech-lead rec 1 — obeyed: exactly qa-specialist + fidelity-reviewer were dispatched as required; the other seven are recorded `deferred-budget`
- tech-lead rec 2 — obeyed: bf3b515 — the qa-specialist got the three files and settled the count before the test was written (11 cases, not 6 or 8)
- tech-lead rec 3 — obeyed: one fidelity-reviewer pass at close on the session diff and the findings table
- tech-lead rec 4 — obeyed: the tech-lead was dispatched before any planning here, and F31 did NOT recur in rudra S03 (recorded in the findings table); no gate was built
- tech-lead rec 5 — obeyed: the F39 fix moved a locked clause, so design-advisor was moved from deferred to dispatched before the close (`.ai/handoffs/session-172-design-advisor.md`)

**qa-specialist** (`.ai/handoffs/session-172-qa-specialist.md`):
- qa-specialist rec 1 — obeyed: bf3b515 — `BELT_VARS` is removed from every `Command` in `tests/commit_belt.rs`; each case sets only its own
- qa-specialist rec 2 — refused: the hooks stay inside the temp work tree and are COMMITTED before `core.hooksPath` is set, which solves the same problem (a failed case's `git clean` cannot remove them either — that bug did bite, and this is the fix that survived it)
- qa-specialist rec 3 — obeyed: bf3b515 — `verify-session-93.sh` now marks itself as the agent; it was passing only because it ran inside an agent shell
- qa-specialist rec 4 — deferred: prompts/172-task-keep-testing.md — an agent may still commit without approval on a branch not named `session-NN-`; put to the founder in chat as a two-option choice, unanswered at close, so nothing was locked in either direction

**design-advisor** (`.ai/handoffs/session-172-design-advisor.md`):
- design-advisor rec 1 — obeyed: `design-significant: yes`, reason recorded as "a locked clause moves"
- design-advisor rec 2 — obeyed: the `## Design` body above is its text, trimmed
- design-advisor rec 3 — obeyed: one `## S172 addendum` in DECISION-007, no new DECISION record
- design-advisor rec 4 — obeyed: the word DEVIATION is in the `## Design` body, unsoftened
- design-advisor rec 5 — obeyed: the addendum's "does NOT claim" section names the lost backstop first
- design-advisor rec 6 — obeyed: the addendum lists the record shapes now accepted, and `fleet::ROLES` says "in any case"
- design-advisor rec 7 — obeyed in part: `scripts/verify-session-172.sh` AC2 runs the REAL `check_live_gate` out of both close scripts against a failing gate and asserts it goes red, plus the cannot-evaluate case. What it does not do is run the whole `verify-closeout.sh` end to end on a fixture; disclosed here rather than claimed

## Guardrails
- No new gate on Vajra's own paperwork. A gate on the HANDOVER to the human (like S171's
  `three-next-options`) needs his explicit yes first — S171 got it, and that is the bar.
- Show each step before the next. Small commits, his word every time.
- Anything not fixed goes in the findings table with a severity, never dropped.
- If the run surfaces nothing in ~30 minutes, say so plainly and switch to the carried items.

## Delta
- `+` an executable test for the human-vs-agent belt split (the riskiest S171 change, untested)
- `+` whatever the founder's rudra session 03 surfaces
- `~` F31 watched for a third occurrence, with the gate decision put to the founder
- `-` nothing removed
