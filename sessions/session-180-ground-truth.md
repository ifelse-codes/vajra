# Session 180 — Ground Truth (NO-CODE)

**Date:** 2026-09-29 · **Branch:** `session-180-ground-truth` · **Evidence:** rudra S06–S15 records, Vajra git since S175, live `stranger-check`, `--stations`, `--dogfood-age`.
**Founder sign-off needed before code resumes.**

## The glance (plain English)

| Question | Answer |
|---|---|
| Did Vajra get better since S175? | **Yes.** 5 merged PRs (#212–#216). Every one fixed a real problem the founder hit in rudra. |
| Did any stranger get any of it? | **No.** 0 stars, 0 forks, 0 issues. v0.2.0 has 6 downloads (v0.1.0 has 20). crates.io still has 0.1.0. |
| Is the agent able to fake the human's "yes"? | **Yes, still.** Approval, waiver, and "verified" stamp are all text the agent can type. Section "Goal 0" has a plan. |
| Overall | 🟡 **PARTIAL.** The product is improving for one user (the founder). It has not reached a second. |

---

## Goal 1 — Did S174's fixes land? (from the rudra record)

| Finding | Landed? | Evidence |
|---|---|---|
| F60 (commit Vajra's synced files first, never revert) | **YES** | S06: boot named the 4 files by path; the agent committed them first (`prompts/175` findings table) |
| F59/F62 ("session 05 merged — S06 starts here"; stop re-running `--steps`) | **YES, partly** | The boot line appeared. `vajra next --steps` was still re-run **3 times** in S06 — the message works, it did not reach zero |
| F58 (agent opens its own PR) | **YES** | S06: not exercised. S09: the agent opened its own PR (`session-177-summary.md:33`) |
| F48 / F53 / F54 (prompt before merge, review stamped once, `## Advice` format) | **NOT TRACED** | rudra S07 review carries one `Review-Inputs-SHA` line; I found no record line for the other two. Left unanswered, not guessed |

## Goal 2 — Audits

| Audit | | Finding |
|---|---|---|
| **delivery_progress** (first, per F93) | 🟡 | Shipped since S175: cadence config-driven (#212), merge stays human (F65), Planner reads `ACn` tables (F72, #213), `**CODE.**` briefs (F74/F76, #214), wording fixes (#215), `--help` runs nothing + `init` refuses unknown words + project-first ground truth (#216). **Vision goals moved: NONE that a stranger can measure.** The one user is the founder. Cost side: 5 sessions of work, rudra receipts $48–$161 each (overstated ~5×, F67). The ratio is not worsening but it is unchanged: high effort, one user |
| vision_alignment | 🟡 | North-star (a coach any agent can be guided by) still right. The work is the shortest path *to the founder's satisfaction*, not to a stranger's. Pivot signal to watch: if the release is out and still 0 outside users after a fixed window, the "governance moat" bet needs re-testing |
| roadmap_alignment | 🟡 | Next item (S181) is code polish on help text. It is not the highest leverage. Highest = get 0.2.0 published (below) |
| state_drift | 🟡 | `STATE.md` says S179 "PR to open" — it merged (#216). `ROADMAP.md` line 1 is headed S166 (13 sessions stale, 1003 lines). Both hand-maintained. This is the founder's "notebook-bloat wall" again |
| knowledge_staleness | 🟢 | 333 lines, in the pruned range |
| constraint_violation_review | 🟢 | No violation surfaced in what I read (verify 37/37 at S179 close, hooks live). I did not re-audit every commit |
| constitution_review | 🟡 | The rules hold but cannot see the human's own controls (Goal 0). **Meta-check below** |
| cost_review | 🟡 | Vajra's own sessions: $0 metered. rudra receipts are 5× wrong and PARKED three times (F67); the budget cap ($5, warn) means nothing next to a $118 receipt. Cost truth is still not recoverable for interactive runs |
| dogfood_check / dogfood_staleness | 🟡 | `--dogfood-age` says last dogfood = **S161, 18 days ago**. That is a **blind spot, not a fact**: rudra S06–S15 are ten real paid `vajra claude` runs by the founder. The tool reads only this repo's git. The real dogfood is the best it has ever been |
| pipeline_advance_check | 🟢 | Station counter S175 7/8 · S176 8/8 · S177 8/8 · S178 7/8 · S179 7/8. I read the K line only, not which station is short. SHIP / Reviewer are expected to lag before a merge |
| stranger_check | 🟢 | `stranger-check.sh` **21/21, GREEN**, live today. A stranger's first ten minutes work — *if they get the 0.2.0 binary* |
| scaffold_drift_check | 🟡 | Ran; printed the known "hand-typed twins" gap for `init.rs` (`communication.forbid`, `load_order`, `demo.required_elements`). I captured its tail only, not its exit code |

**Carried items:** S174 recs 2/6/7 and the F64 watch — no new evidence, no change. F66 (crew handoff not tracked) — no recurrence in S07–S15. S175 design-advisor recs 1/3 — unchanged. **Rec 2 is live right now:** see New Findings N1.

**Meta-check — did this audit's own mechanism miss a kind of drift?** Yes, two:
1. **The measure of use is blind to the real use.** `--dogfood-age` says "18 days stale" while the founder ran ten paid sessions. The audit would have told the next reader "no dogfood" — the opposite of the truth.
2. **Nothing audits the direction of *reach*.** Every audit measures whether Vajra follows Vajra's rules. `delivery_progress` (new this cycle) is the first that asked about users, and its first honest answer is "0 outside users". That is the finding.

## Goal 3 — The shortest path to a stranger getting value

| Step | Who | State |
|---|---|---|
| 1. `cargo publish` 0.2.0 | **founder**, one command | undone; STATE has said so since S168 |
| 2. Brew formula install-smoke | agent (needs `brew`) | undone |
| 3. One real outsider runs it in their own repo and reports back | founder finds one person | never happened |
| 4. README says what the portable product is (see Goal 0, omp result) | agent | not written |

Steps 1–3 are days, not sessions. Nothing further built inside this repo moves a stranger closer until steps 1 and 3 happen.

## Goal 0 — The human's controls are text the agent can type

**The one root cause behind F77–F80, F84, F85, F92:** a control only means something if the agent cannot produce it. Each of these lives in a file or a shell line the agent can write: the `APPROVED` word (F77), the `.ai/SESSION` counter (F85), the "verified" stamp (F79/F84), and `VAJRA_CLOSEOUT_WAIVER=N` typed inline (F78/F92). The Claude Code classifier stopped two of these; Vajra stopped none. That is luck.

**What an agent cannot do** (the only sound base): change its parent's launch environment, answer a prompt on a real terminal it does not own, or write to a place its sandbox denies. Everything else is bar-raising. Honest statement of each fix:

| Problem | Option | What it truly buys | Recommend |
|---|---|---|---|
| F77/F85 approval is a word | `vajra approve NN` run **by the founder in his own terminal**; needs a real TTY; writes a receipt outside the repo (`~/.vajra/…`). The gate reads the receipt, never the brief's text | An agent shell has no TTY under Claude Code, so it fails there; a pty-capable agent (OpenCode/omp) could open one. **Bar-raising, not tamper-proof — say so** | ✅ yes |
| F78/F92 waiver | Waive **named checks only** (`VAJRA_WAIVE=check-a,check-b`) with a required reason, and log whether the value was in the **launch** environment or appeared later. One waiver must never mean "20 checks" | Fixes F92's scope completely. Fixes F78's provenance for Claude Code | ✅ yes |
| F79/F84 stamp | Bind the "verified" stamp to a hash of the record's text at capture; edit the text → the stamp dies | Ends F84. The builder writing `obeyed:` lines into advisors' files is caught | ✅ yes |
| session type (S177) | One field, `session_type: CODE \| DOCUMENT \| GROUND_TRUTH \| INTERACTIVE`. Missing or unknown → the close gate **fails closed** | Ends the word-search class for good (your no-text-guessing rule) | ✅ yes, first |
| F80 non-Claude helpers | Verify from the tool's own log where readable; otherwise say "unverified" plainly | Honest instead of a wall | park (part of the non-Claude brainstorm) |
| Jev / probability judge | — | — | ❌ stays dropped |

**Team of experts vs strict checklist.** The fleet checks paperwork, not thinking: it missed the word-search design for 8 sessions. But its cold reviewer *did* find real defects (S178 pass-1 REJECT, S175's self-only reimplementation). **Recommendation: no more roles. A checklist for anything that can be checked, the cold reviewer kept for judgment, and one new rule for it — "attack the checks themselves, not only the diff".** Adding roles has not once moved a user.

**The omp result → is the portable product the written process + the end check?** Yes, on the evidence: under omp Vajra delivered the full 7-role order, ≤3-file commits, an end check 15→18/21 with real fixes, and a forced human decision; it delivered nothing as live guards, receipt, or provenance. **Recommendation:** say this in the README in one plain paragraph — "Claude Code: live guards + receipt. Any other agent: a written process and an end-of-session check." Stop implying the first for the second. This feeds the parked non-Claude brainstorm.

## New findings for S181+

| # | Finding | Sev |
|---|---|---|
| N1 | **The GT cadence key runs out after today.** `ground_truth_next_session: 180`; from S181 on the every-5th default is off, so **no GT would ever be scheduled again** (S175 rec 2, now real). **Founder ruling 2026-09-29: NOT a hardcoded 185.** Design: default = every 5th; the key is a one-time override that only counts until that session has happened or been skipped, then it rolls to the next multiple of 5 on its own and asks the founder. Code change in S181 (6 sites read the key) | **HIGH** |
| N2 | ~~Release is the blocker~~ **Founder ruling: not a problem.** Not public, not marketing, not GTM-ready; he wants to trust Vajra himself first, then find an outsider. Downgraded to NOTE | NOTE |
| N3 | `--dogfood-age` cannot see rudra runs; it will read "stale" while dogfood is the strongest ever | MED |
| N4 | `STATE.md` / `ROADMAP.md` header drift (S179 "PR to open", ROADMAP headed S166) — derive, don't hand-type | LOW |
| N5 | F97 — existing projects never receive F93 (`--sync-fleet` skips `CONSTRAINTS.yaml`) | MED (recorded) |
| N6 | F92 (whole-close waiver) + F84/F85 → the Goal 0 design above | HIGH → S182 |
| N7 | F67 receipt ~5× over (parked ×3) | MED (unchanged) |

## What I did NOT do / fakest green

- Did not read rudra S07's full transcript → F48/F53/F54 unanswered.
- Read only the K-of-8 line of `--stations`, not which station is short; read only the tail of `scaffold-drift.sh`.
- Could not query crates.io (blocked by their bot policy) → its state comes from STATE.md, not a live read.
- **Fakest green:** the stranger-check 21/21 and 8/8 station counts. Both measure the *machine*, not whether anyone outside the repo uses it. The download counts (6 / 20 / 0 stars) are the honest numbers.

## Three options for next (A/B/C)

| | Session | Goal | Why | Risk |
|---|---|---|---|---|
| **A (recommend)** | **S181 — ship 0.2.0 to a stranger** | N1 config edit; founder runs `cargo publish`; brew smoke; README "portable product" paragraph; then the S179 recs 5/6 (tiny) | The only item that can move the one number that matters | Needs the founder's hands on publish |
| B | S181 — `session_type` enum + named waivers | Goal 0 rows 1–3, code | Closes the loopholes | More inward work while reach stays 0 (no-more-policing, 2026-09-15) |
| C | S181 — non-Claude brainstorm | The parked F91/F94/F95 question | It was promised | Widens scope before one user exists |

**Sign-off needed:** founder approves this report and picks A/B/C.

## Founder rulings on this report (2026-09-29)

- **Reach / release:** fine as is. Not GTM-ready on purpose; Option A waits until he has confidence. Not a finding.
- **Cadence (N1):** must be intelligent, never a hardcoded number (see N1). S181.
- **Leftover small items** (S179 recs 5/6 + N1 cadence): fix in S181.
- **B (agent cannot fake the human's yes) — direction to design, not yet built.** Either the founder approves, or he sets a launch-time "dangerously allow all" flag; the agent can do neither mid-session. Mechanism sketched: Vajra marks every process it launches; `vajra approve NN` refuses when the mark is present, so it works only from the founder's own unmarked terminal; the allow-all flag is set at launch and logged as "human chose at start"; named waivers (never ~20 checks at once); strict `session_type` enum that fails closed. Disclosed as bar-raising, not tamper-proof (an agent could strip the mark). Founder asked for more explanation; to be brainstormed further.
- **C (other tools):** one tool at a time — **OpenCode, then omp, then a third he named as "code this only"** (unclear — likely Codex; to confirm). **Building is later**, not this session. Shared mechanism for all: a launcher (`vajra opencode`) marks the agent's process; git's own hooks (which work for any tool) use the mark to tell the agent from the founder (fixes F91). F94/F95/F80 handled per tool. Portable promise until then: written process + end check.
