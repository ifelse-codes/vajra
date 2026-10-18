# Session 204 — PAUSE: no Vajra development; use Vajra on another project

> **Status:** DRAFT — written in the S201 chat from the founder's decision (2026-10-17): "I think we should stop
> development of Vajra and use it in some other project to see if it actually helpful … I feel it does not impact."
> Then: "finish all now and close it". The founder approves it with `vajra approve 204` only when he brings findings
> from real use. Until then, nothing in this repo is built.
> **Renumbered 202 → 203 (2026-10-17):** the founder ran an ad-hoc bug bash as S202 first (PR #241).
> **Renumbered 203 → 204 (2026-10-18):** a second ad-hoc bug bash ran as S203.

## Type
session_type: INTERACTIVE
- **INTERACTIVE.** It opens only when the founder brings something from real use. Max 2 assumptions · 2 retries ·
  ~2h · 1 story · new chat.

## Goal
Find out whether Vajra helps a real project, judged by **that project's** goals and not by Vajra's own checks. Vajra
development is paused. This session exists only to handle what real use turns up.

## Deliverables
1. **Before the first session there:** the founder picks the project (rudra, or a new one, which also tests a
   stranger's first run) and writes down what "helpful" means. Suggested measure, his to change:
   - Did Vajra catch a real mistake in that project's work that he would have missed? Name it.
   - What did it cost each session (money from the receipt, minutes, steps that got in the way)?
   - After 3–5 sessions: would he keep it on?
2. **Setup there:** reinstall `vajra` from main (`cargo install --path . --locked`, since S203 touched `src/`), then
   `vajra init` (a new project) or `vajra init --sync-fleet` (rudra; this also turns N23 green).
3. **In this repo, only on findings:** fix a finding only if it **blocks** that project's work, one at a time, in
   the founder's words. Anything else is written down, not built.

## Acceptance
| AC | Check |
|---|---|
| AC1 | The project and the "helpful" measure are written in this prompt (founder's words) before any Vajra change. |
| AC2 | Every Vajra change this session names the real-project finding that blocked work, with where it happened. |
| AC3 | The summary answers the measure with evidence from the other project (a commit, a receipt, a session log). |

## Carried in
- **From S203 (ad-hoc bug bash 2, founder 2026-10-18):** 15 fixes found by using Vajra as a new user would, plus 4
  old checks repaired (`sessions/session-203-summary.md`). A new project's first `vajra init` no longer says "already
  runs Vajra"; its briefs name `vajra approve NN`; a repo with no commit gets `git branch main`; init's SESSION-BOOT
  moves on the first advance; a mistyped option fails; **a person may merge on main** (the agent still may not).
  Parked, the founder's call: `VAJRA_SKIP_ANALYST_GATE=1` lets the agent skip the approval record at `--advance`,
  and the refusal message names it.
- **From S202 (ad-hoc bug bash, PR #241):** 15 fixes — N28, F123's routes closed for the agent
  (`.githooks/reference-transaction`, ships via `vajra init` / `--sync-fleet`), F127 leftovers, scaffold settings
  parity, a shorter boot (newest 3 session sections), faster review checks, `past-verdicts-unchanged` at close,
  `vajra --version` with the commit (`sessions/session-202-summary.md`). Not fixed: verify-88's `>= 16` floor.
  A rudra `--sync-fleet` now also brings the new git hook and the full settings.
- **From S201:** N24, N22, N25 and the README "tested with" line shipped (`sessions/session-201-summary.md`). N28 (LOW,
  `--advance` waits on an open stdin) filed — fixed in S202. N23 waits on a rudra `--sync-fleet`. N26 → the S205 prompt, if S205
  ever runs.
- **The whole open list** the founder saw on 2026-10-17 stays in `.ai/ROADMAP.md`'s backlog. Nothing in it is
  picked while development is paused.

## Guardrails
- No Vajra development without a blocking finding from real use. No cleanups, no backlog items, no new checks.
- No paid run by the agent without the founder's yes. No transcript or run capture committed (S126).
- No new policing of Vajra's own paperwork (2026-09-15).

## Design
design-significant: no
- A pause. Any fix a finding needs names its record when it comes.

## Plan
<written only when the founder brings a finding>

## Delta
- `~` Vajra development paused; the next change comes from real use on another project, or not at all

## Advice
