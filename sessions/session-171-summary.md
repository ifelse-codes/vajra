# Session 171 — Interactive: the founder's own first-run test, fixed as we went

**Type:** CODE · **Branch:** `session-171-interactive` · **Close:** light (waived, see below)

## What this session was

The founder installed Vajra 0.2.0 into his own project (`rudra`, a Rust trading system) and worked
through the normal path: `init`, session 00 onboarding, session 01, session 02. He pasted what he
hit, in order. Each finding was fixed, shown to him, and committed on his word. 34 findings, 11
commits, 520 tests green.

## Goal achieved?

Yes. Every problem he hit that belongs to Vajra is fixed and checked against his real project.

| # | Prompt deliverable | Verdict | Evidence |
|---|---|---|---|
| 1 | "01 vs 1" bugs (F19, F23) | SHIPPED | `spath()` in both close gates; padded demo fact; rudra's 3 duplicate files deleted and the gate still passes |
| 2 | Guards stop the agent, not the human (F1–F3, F6, F10, F13b, F15) | SHIPPED | 6 cases proven in a scratch repo; founder's own 13-file commit in rudra went through unblocked |
| 3 | Vajra names the next step (F7, F8, F18, F20, F22, F25) | SHIPPED (partial effect) | `src/nextstep` + boot hook; rudra session 02 offered the options and branched itself — but still planned before dispatching the tech-lead (F31) |
| 4 | Receipt truth + plain words (F14, F16, F17, F21) | SHIPPED | one charge per message; rudra session 02: $19.25 vs Claude Code $19.56 (1.6%) |
| 5 | Fixes reach existing projects (F26, F27, F28) | SHIPPED | git belt is a sync target; `.gitignore` appended; init greets a running project by its real session |
| 6 | The handover is real (F32, F33, F34) | SHIPPED | numbered rankings count; `--steps` prints the candidates; new `three-next-options` close check, tested pass and fail |

## What I did NOT build

- **The crew still is not dispatched first (F31).** The checklist names the tech-lead as the first
  move and the agent still planned first. Telling moved this; it did not close it.
- **No `verify-session-171.sh`, no `demo-session-171.sh`, no crew handoffs for THIS session** —
  the founder chose a light close. Recorded as a waiver, not as green.
- **The demo is still not played for the human by anything.** The checklist says PLAYED; nothing
  can tell whether it was.
- **F24 (paperwork commits) and F29 (spine not rolled forward at close) are untouched.**

## The fakest green here

The checklist's steps read like actions ("has been PLAYED", "have been SHOWN") but every one of
them is judged by a file existing. A demo written and never run, or options written and never
shown, still tick. The only line in this session with real teeth is the new close check, and it
only counts three candidates — it cannot tell whether the human ever saw them.

## 3 ranked next candidates

1. **(Recommended) Session 172 — make the crew dispatch happen, not be advised.** F31 is the last
   open finding from the founder's own run: the checklist names the tech-lead first and the agent
   plans first anyway. Either the boot surface has to be impossible to skip, or the plan gate has
   to bind on the tech-lead handoff. Risk: this is another gate, and the founder has said to stop
   adding them — so the cheap version (a refusal to plan without the dispatch) must be tried first.
2. **Session 172 — finish the 0.2.0 release.** crates.io is still on 0.1.0, so nobody outside this
   machine can get any of tonight's fixes. Everything shipped since S166 is invisible to a
   stranger. Risk: release work is not user-visible progress, and the founder has seen enough of
   that.
3. **Session 172 — keep testing in rudra (session 03) and fix what that finds.** The same method
   that produced 34 real findings in one evening, aimed at the parts not yet exercised: the demo
   being watched, the ground-truth session, a second project. Risk: it finds more than one session
   can fix, and the list grows faster than it shrinks.
