# Session 131 — CODE: make the fidelity-reviewer handoff mandatory, and prove it's real

**Branch:** `session-131-fleet-mandatory-gate` · **Prompt:**
`prompts/131-task-fleet-mandatory-gate.md` · **Founder pick:** locked at the S130 closeout
(fidelity-reviewer first, in the founder's own words: "ensure the session complete[s] all
acceptance criteria and what it build[s] is actually high quality work — not fake stamping and
shortcuts").

---

## Goal achieved?

**Yes.** A session can no longer close with zero `fidelity-reviewer` handoffs — the exact failure
S130's ground truth measured (S126 5 → S127 3 → S128 1 → S129 **0**) — and the handoff's
provenance is no longer a hardcoded literal a hand-typed file could copy for free.

| | before S131 | after S131 |
|---|---|---|
| closing with no fleet handoffs | silently allowed — S129 did exactly this | **BLOCKED** at L2/L3, no legacy WARN escape |
| `agent:` provenance field | hardcoded literal `"claude-code-subagent"` | derived + independently re-verified against real dispatch evidence |
| a hand-typed fake handoff | satisfied every existing gate | refused — "no verifiable dispatch id" / "could not be independently re-verified" |
| a real dispatch from a DIFFERENT session | n/a — nothing checked this | rejected too — bound to `session-{NN}-*` via the subagent's own recorded `gitBranch` |
| `--advance` with no fidelity handoff | succeeded | refused, by name (`[vajra fidelity]`), `VAJRA_SKIP_FIDELITY_GATE=1` the only way through |

## What shipped

- **`src/dispatch/mod.rs`** — the S111/S117/S123 evidentiary shape (two independently-written
  Claude Code files agreeing on a tool-use id neither side controls) made a pure, unit-tested
  `cross_check`, plus a third fact those three hand-assembled addenda left open: the subagent
  transcript's own recorded `gitBranch`, binding a dispatch to the SESSION being gated, not merely
  to a real dispatch of the right role at some point in this repo's history.
- **`src/fidelity/mod.rs`** — the mandatory gate. Three distinct BLOCKING outcomes, none reading as
  another: absent (no legacy WARN, unlike every other stage gate here), malformed (fails closed),
  unverifiable provenance (the gate independently re-derives via `dispatch::reverify`, never
  trusting the handoff's own label).
- **`src/cli/next.rs`** — `--role --from` now derives `agent:` via `dispatch::derive_provenance`
  instead of the hardcoded string; new `--check-fidelity-handoff NN` command (its own command, not
  folded into `--check-advice` — see `## Design` in the prompt and the DECISION-007 addendum for
  why); the gate wired into `--advance`, binding on the closing session,
  `VAJRA_SKIP_FIDELITY_GATE=1` the documented override.
- **`docs/decisions/DECISION-007-agent-fleet.md`** — S131 addendum: the design choice, the
  gitBranch-binding mechanism, and the disclosed limits — including, after the cold review's rec 1,
  the sharper honest framing ("forgeable by anyone with shell access to this machine," not merely
  "local-machine-only").
- **`scripts/verify-session-131.sh` (10/10 GREEN, run live)** and **`scripts/demo-session-131.sh`
  (8/8 GREEN, run live, all four required elements)** — both drive the REAL release binary against
  throwaway `mktemp -d` git repos, never this repo. Verify's falsifiability fixture (S122/S127
  contract) actually bypasses the gitBranch bind and the role-identity check in a `git worktree`
  copy and confirms the specific named unit test goes RED for each, then renames every gate message
  string and confirms the suite stays GREEN — bound to behaviour, not wording.
- **`.ai/handoffs/session-131-fidelity-reviewer.md`** — this session's own governed handoff,
  written from a REAL dispatch (`agent-a6fc7f07a30f0f897`, `toolu_01FsZj2Rs9E6vdhsgKo7SUSX`,
  `gitBranch: session-131-fleet-mandatory-gate`), not a fixture — the gate this session hardens,
  satisfied by real evidence.

## Fidelity map — every numbered requirement

### Deliverables

| # | requirement | verdict | evidence |
|---|---|---|---|
| D1 | gate BLOCKS closeout/`--advance` when `.ai/handoffs/session-{NN}-fidelity-reviewer.md` absent, L2/L3, no legacy WARN | **SHIPPED** | `ac9df27`, `4f1cf45` · verify `absent-handoff-blocks`, `advance-really-binds-on-missing-fidelity-handoff` |
| D2 | `src/cli/next.rs:283`'s hardcoded literal replaced with real derived provenance, reusing S111/S117 design | **SHIPPED** | `7cee5eb`, `4f1cf45` · verify `real-dispatch-fixture-verifies-and-passes` |
| D3 | an unverifiable/fabricated handoff refused or fail-closed-flagged, not silently accepted | **SHIPPED** | `ac9df27` · verify `fabricated-provenance-blocks` |
| D4 | falsifiability fixture, all 3 directions, each probe asserts its own pattern matched | **SHIPPED** | `2eb7deb`, `7f4db94` · `fixture-red-on-bypass-green-on-rename` |
| D5 | verify + demo, both exit 0, printed check-class tally | **SHIPPED** | `7f4db94` (10/10) + `65a9b1d` (8/8) |
| D6 | summary + exactly 3 ranked next candidates | **SHIPPED** | this file |

### Acceptance

| # | criterion | verdict | evidence |
|---|---|---|---|
| 1 | `verify-closeout.sh`/gate FAILS if the handoff is absent, proven on a real session dir | **SHIPPED** | verify `absent-handoff-blocks`; cold review AC1 SHIPPED |
| 2 | `--role --from` provenance derived from real dispatch evidence | **SHIPPED** | verify `real-dispatch-fixture-verifies-and-passes`; cold review AC2 SHIPPED |
| 3 | unverifiable provenance treated as absent/invalid, fail-closed (S67/S68 posture) | **SHIPPED** | verify `fabricated-provenance-blocks`; cold review AC3 SHIPPED |
| 4 | falsifiability fixture, all 3 directions, own-pattern-matched assertions | **SHIPPED** | `fixture-red-on-bypass-green-on-rename`; cold review AC4 SHIPPED |
| 5 | `K of 8` + 7 commands + every other gate's contract unchanged | **SHIPPED** | `k-of-8-unchanged-and-not-a-ninth-station`; cold review AC5 SHIPPED (confirmed `stations/mod.rs`, `main.rs` untouched) |
| 6 | verify + demo both exit 0, printed tally, every check execute-based or honestly labelled | **SHIPPED** | 10/10 + 8/8 GREEN, run live twice this session |
| 7 | independent cold `fidelity-reviewer` ACCEPT, attested, dispatched via the mechanism it hardens | **SHIPPED** | `sessions/session-131-review.md`, ACCEPT, 7/8 SHIPPED, `Review-Inputs-SHA` matches (`review-inputs-attested` PASS) |
| 8 | summary states plainly what is NOT fixed (only fidelity-reviewer mandatory; obedience is S132's) | **SHIPPED** | section below |

## The fakest green

**Named by the cold review, and I agree it is the real one:** the entire provenance chain rests on
trusting the contents of `~/.claude/projects/<slug>/*/subagents/agent-*.meta.json` and its sibling
`.jsonl` — plain, **unsigned** JSON with no cryptographic or process binding to a subagent that
actually ran. This session's own `verify-session-131.sh` (`build_real_dispatch_fixture`) and
`demo-session-131.sh` (case 3, case 5) PROVE how cheap forging a "Verified" dispatch is: three
`printf` calls. **"Verified" here proves a file matching a shape exists, not that a subagent ran.**
The Coder gate's `git cat-file -e <sha>` (S68) sets a materially higher bar — a real git object must
exist. S131's bar is real (over a hardcoded string that accepted anything) but it is a bar, not a
wall, and the DECISION-007 addendum now says so in those exact words (cold review rec 1, obeyed).

## What is still NOT fixed after this session

1. **Only ONE role (`fidelity-reviewer`) is mandatory. The other 8 stay entirely optional.**
   Repeating this pattern for a second role is explicit future work — this session's prompt and its
   Non-goals name that directly; nothing here generalises it.
2. **Whether the advice was OBEYED, vs. merely answered, is untouched.** That is S132, locked as
   the next session at the S130 closeout, closing the S127 residual (four factually wrong `obeyed:`
   labels once passed that gate).
3. **The dispatch evidence is forgeable by anyone with shell access to this machine** (the fakest
   green above) — this session raises the bar over a hardcoded string; it does not make the claim
   tamper-proof, and the DECISION-007 addendum says so plainly now.
4. **A new residual the cold review's rec 4 found, deferred (not closed this session,
   `.ai/ROADMAP.md` F2):** `reverify` proves a real dispatch of the right role/session occurred; it
   does not bind that dispatch's own returned content to the specific `--from` findings file later
   ingested. Normal usage doesn't hit this; nothing today proves it can't be misused. Closing it is
   a real design decision (hash the subagent's own last transcript message, require `--from` content
   match/derive from it), correctly out of this session's locked one-story scope.
5. **The fourth fork (`TPL_CONSTRAINTS`) is still refused, still real, untouched this session** —
   parked per `.ai/ROADMAP.md`, not this session's job.
6. **No release, no crates.io action** — founder directive stands; `vajractl` already burned at
   0.1.0.

**Dogfood, unmeasured this session by design:** this was a build session, not a paid dogfood run.
S134 (locked at the S130 closeout) is the next fresh-scaffold paid dogfood.

---

## Next

**S132 is not really a choice — it is the locked next step in the S130-closeout sequence**
(S131 → S132 → S133 → S134), and this session's own rec 4 residual sharpens exactly why: a
recorded claim (a disposition, a provenance label) is not the same thing as a verified one, twice
over now. Presented as three ranked candidates per the standing rule, not as the only option:

**A — S132: verify the recorded `obeyed:` disposition is actually true.** *Goal:* close the S127
residual — four `obeyed:` labels once passed the Advice gate while being factually wrong, caught
only by a cold reader — by making the gate check the CONTENT of what a disposition claims, not just
that a sha resolves. *Why:* it is the founder-locked next step, it is the same "recorded ≠ real"
class this session just fixed for the handoff's own existence, and S131's own rec 4 residual is a
smaller instance of exactly this problem (a dispatch happened ≠ the findings it's stamping came from
it). *Risk:* "was this obeyed" shades into a judgement call a machine cannot fully make (DECISION-002's
own floor) — the session must be honest about where the check's authority actually ends.

**B — close S131's own rec 4 residual: bind a dispatch's returned content to the findings it
stamps.** *Goal:* hash the subagent's own last transcript message and require the `--from` file's
content to match/derive from it, closing the reuse-within-session gap the cold review found.
*Why:* it is freshly named, concrete, and sits directly beside the mechanism just built. *Risk:* it
is a second design decision the size of this one (S131's own prompt explicitly deferred it rather
than folding it in), and doing it before S132 would mean the founder-locked sequence gets
reordered without an explicit founder call.

**C — S133: compression engine, keep or kill.** *Goal:* the founder decides the fate of 1,005 LOC /
$0 real savings (measured twice, S63 and S124); the losing branch is a bounded cleanup session
either way. *Why:* it is next-but-one in the locked sequence and does not depend on S132 landing
first. *Risk:* pulling it forward breaks the locked S131→S132→S133→S134 order the founder set at
the S130 closeout for a reason (S132 closes a standing residual; S133 does not depend on it, but
skipping ahead invites the exact "roster not fleet" drift S130 diagnosed).
