# Session 172 — Keep testing rudra, fix what it finds

> **Status:** DRAFT — the shape is set (S171's method, repeated). The founder's findings fill in the Goal and Acceptance at the start of the chat, as they did in S171.

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
| F31 | watch #3 | **Did not recur.** Tech-lead dispatched before any planning. | ✓ |
| + | fleet | The advice changed the work: plan-advisor caught a 22-vs-23 event-count error in a LOCKED spec (founder ruled 23); design-advisor corrected the tech-lead twice. | ✓ positive |

## Fixes landed (founder: "can we fix all of these" → "commit")
- F39 — `4fce12a` (advance reports on a merged session; Vajra's close check gains advice + live verify) · `b2c06d9` (projects' close check gains advice + live verify + live demo)
- F40 — `b2c06d9` (template: "before" = the start commit, never `main`) · `4fce12a` (no demo re-run for a merged session)
- F41 — `4fce12a` (empty-stdin hint on the advance question) · `b2c06d9` + `4fce12a` (review-hash order spelled out) · `5c5c350` (crew line format)
- F35 — `fb8b043` · F36/F38/F42 — `70d087e` · F37 — `5c5c350` · F43 — `4fce12a` (the releaser code; its commit message landed with `5c5c350`)
- Not reached by `--sync-fleet`: `darshan/SKILL.md` (new installs only); the boot banner carries the rule to existing projects.

## Goal
1. _From the founder's run._

## Deliverables
1. _From the founder's run, plus the two carried items above._

## Acceptance
1. _Each item something he can check himself._

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
