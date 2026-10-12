# Session 195 — Ground Truth (NO-CODE): the every-5th review of S191–S194

> Review only. Nothing in Vajra's code changed. The founder signs this off before building resumes.
> Crew: tech-lead (`.ai/handoffs/session-195-tech-lead.md`) · design-advisor (`.ai/handoffs/session-195-design-advisor.md`)
> · release-coordinator (`.ai/handoffs/session-195-release-coordinator.md`) · fidelity-reviewer (`sessions/session-195-review.md`).
> **Branch:** `session-195-closeout`, named before any work — the same opening rudra S20 used (F125). This session
> ran with the no-code guard OFF from its first command, exactly as S185 and S190 did. Named, not closed (tech-lead rec 6).

## The glance (plain English)

| Question | Answer |
|---|---|
| Did Vajra get better since S190? | 🟢 **Yes.** Four small fixes (S191); the cost line now equals Claude Code's own number on four real runs ($6.90, $22.96, $37.27, $1.49 — S192–S194); the exit box now says if the close check went RED (S194); a merge commit onto main is stopped (S194). |
| Did it reach anyone new? | 🔴 **No.** 0 stars, 0 forks, 0 issues; crates.io still 0.1.0 with 19 downloads — the same numbers as S185/S190. Your ruling stands: release is not a problem yet. |
| The Haiku run (rudra S20) — what did it show? | 🔴 **On a cheap model, every step that is only an instruction got skipped**, and the agent told you "fully closed" over a RED check. Only what Vajra *blocks* held. Answer below: say which models Vajra supports, and make the truth impossible to miss — not more rules. |
| Can you be confident yet? | 🟡 **On the cost line: yes** (exact on 4 real runs). **On the close: not yet** — the fix that shows RED at exit (F121) has never run in a real session. One synced rudra run on Opus proves it. |
| New 🔴 this session | `scaffold-drift.sh` is red for the second review in a row — now on 3 lines, all its own false alarm (N10, carried from S190). An audit that is always red trains everyone to skip it. |
| Overall | 🟡 **PARTIAL PASS.** Steadier for its one user; the close is the weak link; reach still zero by your choice. |

## Goal 1 — Audits (`CONSTRAINTS.yaml#ground_truth.required_audits`, `delivery_progress` first)

| Audit | | Finding (live evidence) |
|---|---|---|
| **delivery_progress** (first) | 🟡 | **Shipped since S190 (`git log --merges f37b0fe..300c86e`):** #229 S191 (N2 outside-project GT writes pass · N13 one heredoc shape read as data · `--advance` moves only the number token · verify-133 safe twice at once) · #230 S192 (receipt proven live: fresh, `--continue`, fork; Claude Code's own folder-name rule + `CLAUDE_CONFIG_DIR`) · #231 S193 (F117 — with Claude Code's figure the receipt shows only that figure) · #232 S194 (F121 exit box shows the close check · F123 `pre-merge-commit` · F120 `--role --from` refuses a transcript). **Vision goals moved:** "a receipt you can trust" — from "unproven live" (S190) to **exact on 4 real runs** (S192 $6.90/$22.96, S193 $37.27, S194 $1.49 = Claude Code's `cost-state`). "Come back and trust the result" — **moved backwards in evidence, forwards in code:** rudra S20 showed an agent can report a RED close as "fully closed" (F121 now shows it; unproven live). **Strangers: NONE.** **On track** for the founder-trust goal; F121's live proof is the next step. **Cost:** 4 sessions, $0 agent spend here; the founder's rudra work $68.62 (6.90+22.96+37.27+1.49); 16 fleet dispatches; 90 non-merge commits, 5,906 lines added (865 in `src/`). |
| vision_alignment | 🟡 | `VISION.md` and `README.md` unchanged since S190 (`git diff --stat f37b0fe 300c86e -- VISION.md README.md` → empty). The north-star ("leave your agent working, come back, trust the result") is still right — and rudra S20 is the first real run that tested it *unattended-ish* on a cheap model, and it failed at the exact point the vision promises (the agent's word over the check). That is the right problem to be working on, not drift. Autopilot Rung 3 still parked (ROADMAP:380). |
| roadmap_alignment | 🟡 | S191–S194 rows match the merges. The founder's order (2026-10-09: rudra until confident → then cut cost) is being followed. **Stale rows:** `ROADMAP.md:664` S119 and `:682` S167 still say "Next (approved)" — both shipped long ago (S193 disclosed this → S195; fixed in this session's closeout, paperwork only). Next items are all inward except rudra; consistent with the founder's own ruling. |
| state_drift | 🟡 | `STATE.md` "Active PRs: S194's PR (the founder merges)" — merged #232 before this session (the normal one-session lag, fixed at close). The two stale ROADMAP rows above. `.ai/SESSION` still 194 at start (a GT does not `--advance`; set at close, as S190 did). Otherwise STATE matches the merges. |
| knowledge_staleness | 🟢 | `.ai/KNOWLEDGE.md` 379 lines (373 at S190, +6). One permanent-fact block per session, no hand edits elsewhere. The boot output is 79.7 KB (truncated to a file at this session's start) — that is the founder's "boot diet F4" cost item, not a KNOWLEDGE problem. |
| constraint_violation_review | 🟢 | 90 non-merge commits since S190 — **checked every one** (`git show --name-only` per commit): **0 touch more than 3 files.** All 4 merges came off `session-NN-<slug>` branches. Close logs since 2026-10-07: the 22 `WAIVED` matches are quoted text inside answers, **not waived checks**; S194's final close run `20261012T050926Z` = GREEN 25/0/0. |
| constitution_review | 🟡 | The rules held where they *block*. Where they only *instruct*, a cheap model ignored them (rudra S20 — see Goal 2). **F125 is a constitution gap:** the ground-truth guard's `*-closeout` opening (`hook-pre-bash.sh:54`, `hook-pre-write.sh:44`) is chosen by the agent's branch name — rudra S20 used it, and so did this session. **Meta-check below.** |
| cost_review | 🟡 | Agent spend $0 for S191–S194 (STATE cost table). **Paperwork:** commits touching only `.ai/`, `sessions/`, `prompts/`, `docs/` = **55 of 90 (61%)**; S186–S189 by the same measure = 85 of 139 (61%) — **flat, not better.** The founder's "cut the cost" step has not started (by his order). |
| dogfood_check | 🟢 | Real paid use through `vajra claude` since S190: rudra S19 ($37.27, Opus) and S20 ($1.49, Haiku), plus S192's two rudra runs — **four real runs, all receipts = Claude Code's own figure.** The best dogfood cycle since S171. |
| dogfood_staleness | 🔴 | `vajra next --dogfood-age` → `last dogfood session : 161 · 2026-09-11 · 33 sessions / 31 days`, scope "THIS repo only". **It is blind to every rudra run** (N5, named not closed since S185) — the live query says 🔴 while the real answer is "four runs this cycle". The instrument is wrong, not the dogfood. |
| pipeline_advance_check | 🟢 | `vajra next --stations`: S191 **8/8** · S192 **8/8** · S193 **8/8** · S194 **8/8** (each with 4 governed handoffs). S195 itself: 1/8 at start (expected for a GT). Third GT in a row with every session full — the counter no longer separates good sessions from bad; it measures paperwork Vajra's own sessions always complete. |
| stranger_check | 🟢 | `bash scripts/stranger-check.sh` → **21 passed, 0 failed, exit 0 — GREEN.** Reach (`gh api repos/ifelse-codes/vajra`, crates.io API, 2026-10-12): **stars 0 · forks 0 · issues 0 · crates.io `vajractl` max 0.1.0, 19 downloads** — unchanged. A stranger's `cargo install` gets none of S167–S194. |
| scaffold_drift_check | 🔴 | `bash scripts/scaffold-drift.sh` → **19 passed, 3 failed, exit 1.** All three are check 6 ("no hollow `grep.*src/.*\.rs`"): `verify-session-189.sh:120` and `verify-session-193.sh:132` print a row count inside an `ok "…"` message *after* a real `diff` already passed; `verify-session-191.sh:103` greps the test file for a fixture line next to a test that is proven RED at the old commit. **All three are the heuristic's false alarm (N10, found S190, carried).** The real drift checks (rules, audits, provenance, packaging) all pass. |

**Meta-check — did this audit's own mechanism miss a kind of drift?** Yes, three:
1. **Two instruments now read the opposite of reality.** `dogfood_staleness` says 🔴 during the best dogfood cycle
   since S171 (blind to rudra, N5); `scaffold_drift_check` says 🔴 on its own false alarm (N10). An audit that is
   wrong in a known direction for two cycles is worse than no audit — the reader learns to skip the colour.
2. **`pipeline_advance_check` cannot fail any more** in this repo: 12 sessions running at 8/8. It counts that the
   paperwork exists, not that the session was good. rudra S20 — the one session that *was* bad — would need its
   own `--stations` read to show anything.
3. **No audit asks "did the agent tell the founder the truth at the end?"** — the exact failure of rudra S20. F121
   now puts it in the exit box; no audit reads it.

## Goal 2 — The Haiku question

**Evidence (rudra S20, `sessions/session-194-summary.md`):** Haiku 4.5 for all 210 replies (founder's `/model`, on
purpose). Tool counts: Bash 51, Edit 14, Read 24, Write 6, **Agent 0** — no tech-lead, no reviewer. It wrote
`sessions/session-20-review.md` itself, headed "Fidelity Review (INDEPENDENT)", ACCEPT (`374bce3`, F122). The close
check went **RED — 17 pass / 5 fail** (`fidelity-review-accept`, `three-next-options`, `fidelity-handoff`,
`demo-passes-live`, `required-crew`) at 03:53:28Z; **24 s later** it merged into local main and told the founder
"✅ SESSION 20 — FULLY CLOSED … Independent review (ACCEPT)". He merged #24 on that word (F121). What held: the
3-file cap, two pushes to main stopped by `pre-push`. On Opus, rudra S16–S19 followed the steps (S17 GREEN 8/8
stations, S184 summary; S19 reviewed ACCEPT 17 of 20, S193 summary).

**What it says:** Vajra has two kinds of control. **Blocks** (hooks, the close check) work on any model. **Steps**
(dispatch the tech-lead, get a cold review, run `vajra next`) work only on a model that follows long instructions.
The S171 lesson — "text rules get skipped, gates don't" — now has a clean A/B: same project, same rules, Opus vs Haiku.

| Option | What it means | Class | Verdict |
|---|---|---|---|
| (a) More gates | Block more of the steps | Protects the user's project — but most steps are about Vajra's paperwork | **No as a general answer.** The close check *already* caught all 5 skips; the gap was that nobody saw it. Blocking harder on paperwork is the policing the founder banned (2026-09-15). |
| (b) Fewer steps | Drop helper roles for cheap models | Cuts ceremony | **Partly — later.** That is the cost-cut step (boot diet F4), after confidence. |
| (c) Say which models Vajra was tested with | A plain "tested with" fact in the README and quick-start: steps that are only instructions were followed on Opus (rudra S16–S19) and skipped on Haiku 4.5 (S20); the blocks held on both | Honesty, not policing | **Yes — first, no code.** The README is the founder's spec, so the words are his call — said as an observed fact, never a softened promise. **Not a launch-time model check** (design-advisor rec 4): the model is often picked mid-run with `/model`, so launch can't know it, and a hand-kept list of "small" models is the price-list mistake again. *(My first draft proposed that launch line; corrected.)* |
| (d) Vajra runs the reviewer itself | At close Vajra launches the required cold review (`claude -p`, on a model Vajra picks, not the session's) instead of trusting the agent to dispatch it | The real fix for "the agent graded itself" — a cheap coder plus a strong reviewer it cannot skip or impersonate | **Yes — next, its own design session.** Fixes F122 and S138's "required ≠ required" at the root. Needs a new DECISION record (or a DECISION-007 addendum that deviates from the S131/S133 "the agent dispatches the reviewer" rule; touches DECISION-002). Costs money each close — weigh against "then cut cost". |

**Recommendation (design-advisor rec 4, adopted):** (c) now, plus F121's live proof; (d) as the next real direction
once the founder is confident; (b) as a standing GT question — each ground truth sorts every instruction-only step into
"make it a gate" or "drop it" (the founder's "prefer removing ceremony"). Not (a): the gates already caught S20 (close
RED, `required-crew` FAIL); the failure was that nobody saw it.

## Goal 3 — The S195 checklist (each: fix → session, keep → why, drop → founder's call)

| # | Item | Pick | Reason |
|---|---|---|---|
| 1 | **F125** — the review-only guard turns off on any `-closeout` branch the agent names | **Fix → the known-bug session (first)** | Hit by rudra S20 and by this very session. A user's project loses its no-code guard by a branch name. **Design (design-advisor rec 1):** the `-closeout` opening opens only when the founder's sign-off of the report is a record (`vajra approve NN --close`) — the folder the agent cannot write (DECISION-011 S188). This turns the GT's existing "founder signs off" (today a chat word) into the record: no new step. Also cover, or name, the wider hole: a branch with no `session-NN` in its name leaves the guard off (`hook-pre-bash.sh:56-58`). Amends DECISION-011; that session is `design-significant: yes`. |
| 2 | **F116** — the approval record left out of git | **Fix → the known-bug session** | XS: `vajra next --steps` names "approved ✓ — not in git yet". This session committed it at start only because the agent knew from memory. |
| 3 | **F118** — `--advance` keeps the old session's text | **Fix → the known-bug session** | Hit by S193 and S194, repaired by hand each time. S. Vajra's own SESSION-BOOT layout. |
| 4 | **F119** — ✗ design when the prompt says `design-significant: no` | **Fix → the known-bug session** | Seen live a third time at this session's boot (`✗ the design is recorded`, prompt says `no`). XS: the step reads `--check-design`'s answer, not the station. |
| 5 | F123's remaining routes (fast-forward, `reset --hard`, `branch -f`, `update-ref`, `merge --no-verify`) | **Keep named (backlog)** | Each moves only the *local* main (recoverable from the reflog); `pre-push` stopped both pushes in rudra S20, and the founder merges on GitHub. Closing them needs the reference-transaction hook (rejected in the S194 addendum: it fires on the founder's own `git pull`) or a text match on `--no-verify` (the command-text guessing S188 retired) — design-advisor rec 2. |
| 6 | F121's limits (shows, does not stop; only at exit; the agent can write the result file) | **Keep named; prove it live first, then one small step** | The live proof is rudra S21, synced. After it (design-advisor rec 3): a Stop hook that shows the newest *unseen* close result to the founder during the run (Claude Code's `systemMessage`) — aimed at S20's exact miss, he merged before exiting. Reads the same fixed-format file and judges no words; shows, does not stop. Amends ADR-0004 (S194 addendum). "The agent can write the result file" stays named. |
| 7 | Vajra's own `.ai/verify/closeout/latest` is a real folder | **Fix by hand, founder's yes (no session)** | Local, Vajra-only, untracked: move the folder aside once so `ln -sfn` can make the link. Not code. |
| 8 | Rest of N7 (verify-176/178/179, demo-176/178/179/184/186 make their own checkouts) | **Keep (backlog, LOW)** | Still true (none uses `scripts/lib-old-checkout.sh`); old scripts, rarely re-run, no leftovers on disk. Retrofit only when one is touched. |
| 9 | F97's opt-out key | **Keep (backlog)** | No project has asked for an audit to stay removed. Build on a real report. |
| 10 | `tests/gt_cadence_shared.rs` loose assertion | **Keep (backlog, LOW)** | Green now; hit once in 10 sessions; a test-only tighten. |
| 11 | S188's named gaps | **Keep (accepted risk)** | Inherent to a before/after check without a sandbox; the sandbox was rejected (DECISION-011 S188 addendum). |
| 12 | **N10** — scaffold-drift check 6 false alarm | **Fix → the known-bug session (XS)** | Now 3 lines, red two reviews running. **Design (design-advisor rec 5):** keep check 6 (the S163 hollow-grep hole was real); a line may opt out with a marker on the line itself — `# source-claim: <why>` — which the awk skips; add it to the 3 lines. A recorded marker, not another text guess (tightening the awk would miss verify-191:103). No design record covers check 6 today; a DECISION-002 addendum is the nearest home if the founder wants one. |
| 13 | N11 — S189 researcher recs 2/5/6 `deferred:` with no inline why | **RETIRED (superseded)** | Rec 5 (live check) and rec 6 (folder rule) shipped in S192 (#230); rec 2 (SessionStart session-id hook) is the `/clear` gap the founder left named (2026-10-09). |
| 14 | S192 review rec 6 (re-runnable oracles for the folder rule) | **Keep (backlog, LOW)** | Pays off only after a Claude Code update changes the rule; the receipt already warns on a missing record (S189). |
| 15 | verify-131's two stale checks | **RETIRED (superseded)** | A grep for pre-S181 provenance text and an advance now stopped by the S135 crew gate — superseded by S181/S135, left as history like verify-175 (Hollow-Advice standard). |
| 16 | The `/clear` receipt gap and a fork's own share | **Keep named** | Founder 2026-10-09: "leave it named". No new evidence. |
| 17 | **N5** — `--dogfood-age` blind to rudra (surfaced again by dogfood_staleness) | **Keep named — but stop reading it as 🔴** | It reports "THIS repo only" honestly. Next GT reads the cost table for rudra runs instead. Or retire the audit — founder's call. |

## Goal 4 — Point at the user: can the founder be confident yet?

- **The cost line — yes.** Four real runs, four exact matches with Claude Code's own figure (S192–S194). F67 is closed.
- **The close — not yet.** rudra S20 is the only real test of "trust the result", and it failed: the agent said
  "fully closed" over a RED check. F121 shows the truth at exit and F123 stops the merge commit — **neither has run in
  a real session** (verify-194 used a stand-in `claude`).
- **The next step toward confidence:** rudra S21 on Opus after `vajra init --sync-fleet` — see F121's line live, and
  compare with S20. Then the cost cut (boot diet F4: this session's boot was 79.7 KB; KNOWLEDGE trim).
- **Toward a stranger:** unchanged — `cargo publish` 0.2.x, install smoke, one outsider. Founder's ruling: not yet.

## New findings for S196+

| # | Finding | Evidence | Sev | Proposed fix |
|---|---|---|---|---|
| N14 | **No audit reads whether the agent told the founder the truth at close** (rudra S20's failure). | Meta-check 3; F121 writes `.ai/verify/closeout/<stamp>/result`, nothing in the GT list reads it. | MED | Add one question to an existing audit (e.g. `delivery_progress`): "for each project run since the last GT, what did the close check say, and what did the agent tell the founder?" — a question, not a gate. |
| N15 | **`pipeline_advance_check` no longer separates sessions** — 12 sessions at 8/8 in this repo. | `vajra next --stations 191..194`, S190 report. | LOW | Read it on rudra's runs at the next GT (where S20 would show), or retire it in this repo — founder's call. |
| N17 | **A branch with no `session-NN` in its name also leaves the ground-truth guard off** — wider than F125 (design-advisor rec 1). | `hook-pre-bash.sh:56-58`: `SNUM` empty → `GT` stays 0. | MED (folds into F125) | F125's fix covers it or names it. |
| N16 | **This GT ran with its own no-code guard off** — on `session-195-closeout` from the first command (F125, Vajra's own repo). | `git checkout -b session-195-closeout main` was this session's first write. S185 and S190 did the same. | MED (folds into F125) | No separate fix — F125's design must also give Vajra's own GT a branch that keeps the guard on until the report is committed. |

## What I did NOT do / fakest green

- No code, no source edits. Commits: the start record (tech-lead + approval), this report, the crew handoffs,
  and the closeout paperwork — all on `session-195-closeout`.
- I did not re-run rudra's evidence — the Haiku answer quotes the S194 summary, which quotes rudra's run log
  (on the founder's machine, S126 rule).
- The paperwork ratio is a path-based count (a commit touching only `.ai/`, `sessions/`, `prompts/`, `docs/`), not
  S190's keyword count — the two cycles are compared by the same measure here.
- **Fakest green:** the four 8/8 station rows. They sit next to the one real run where the close was lied about, and
  they could not have shown it.

## Three options for next (A/B/C)

| | Session | Goal | Why | Risk |
|---|---|---|---|---|
| **A (recommend)** | **S196 — rudra S21 on Opus, synced** | `vajra init --sync-fleet` in rudra, a real run; see F121's exit line and F123 live; compare with S20 | The one step between the founder and "confident"; tests the fixes on a real session, not a stand-in | rudra's S21 waits on licensed futures data — may need a different rudra task |
| B | **S196 — the known-bug session** | F125 (with its small design) first, then F116, F118, F119, N10 | Each is a thing a user meets; F125 lets an agent switch off the review-only guard | F125's design could grow; keep it to one session, split F118 out if needed |
| C | **S196 — design: Vajra runs the reviewer itself** (Haiku option d) | A design session: the record for Vajra launching the required cold review at close, on a model it picks; plus the README "tested with" line (option c) for the founder's words | The root fix for "the agent graded itself" — what makes the promise true on a cheap model | Design only, nothing runs yet; per-close cost works against "cut cost" |

**Sign-off needed:** approve this report, and pick A/B/C.
