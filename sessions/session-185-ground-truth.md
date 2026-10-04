# Session 185 — Ground Truth (NO-CODE)

> Review only. Nothing in Vajra's code changed. The founder signs this off before building resumes.
> Crew: tech-lead (design-advisor + release-coordinator required, the rest deferred for budget) ·
> design-advisor (12 recs, `.ai/handoffs/session-185-design-advisor.md`) · release-coordinator (6 ship recs,
> `.ai/handoffs/session-185-release-coordinator.md`) · fidelity-reviewer (cold review ACCEPT, `sessions/session-185-review.md`).

## The glance (plain English)

| Question | Answer |
|---|---|
| Did Vajra get better since S180? | 🟢 **Yes, for its one user.** Your yes/no is now a record the agent cannot type (S181/S182). The close lints like CI (S183). Three small first-run bugs are gone (S184). rudra reached 8 of 8 stations for the first time. |
| Did it reach anyone new? | 🔴 **No.** 0 stars, 0 forks, 0 issues. crates.io is still 0.1.0 (19 downloads). The v0.2.0 release has 6 downloads, the same as at S180. You ruled this is not a goal yet. |
| F113 (projects start blocking at their session 132) | **Pick: a key only Vajra's own repo sets.** Every project warns and never blocks. That matches your 2026-10-03 rule. |
| F110 (guard blocks harmless text) | **Founder picked (b):** read where the `>` really writes (below). It hit **4 times today**, once in this very session. |
| F115 (red old check) | **Stale, not a regression.** Red since S135 (2026-08-27). But it means **nothing has proved the obeyed gate stops `--advance` for 50 sessions.** |
| F114 (fresh project `--ledger` exits 1, silent) | Confirmed live. One-line fix, size XS. |
| Overall | 🟡 **PARTIAL PASS.** The tool is steadier. The bugs rudra finds are getting smaller. Reach is unchanged at zero. |

## Goal 0 — the two fixes to pick

### F113 — a project's own session 132 starts BLOCKING unchecked `obeyed:` claims

**Today:** `src/obeyed/mod.rs:76` `OBEYED_JUDGMENT_FROM_SESSION = 132`, compared at line 499 against the project's own session number. rudra is at session 17 with **289 `obeyed:` lines** in its prompts. At its session 132 they all start blocking. That breaks your "not a blocking gate for projects" rule. Real, but months away.

**Pick (design-advisor rec 1–3 agree):**

| Part | Design |
|---|---|
| The key | `obeyed_blocks_from: N` in `.ai/CONSTRAINTS.yaml`. Only Vajra's own file sets it (132). `vajra init` never adds it. |
| Absent (every project) | Unchecked claims **warn, forever**. The warning says so in plain words: "this project does not block on unchecked `obeyed:` claims (no `obeyed_blocks_from:` in .ai/CONSTRAINTS.yaml)". This brings back the honest line S184 (F107) removed. |
| Malformed / empty / twice | **Blocks and names the line** (rec 2). It does not copy `session_rules_from`'s quiet fallback (`src/approval/mod.rs:37`). |
| Restore | the comment at `src/obeyed/mod.rs:517` (it still says the exemption is "stated out loud"), and make verify-132's `pre-threshold-warns-and-names-the-exemption` check WHY it doesn't block. Today (line 241) it only checks that the output says it does not block ("names them but does not block on them"), not the reason (rec 3). |
| Rejected | Reusing `session_rules_from`: a fresh project has it at 1, so it would block from session 1, the opposite of your rule. Spotting "is this Vajra's repo?" from file contents: that's text guessing (S177). |
| Limit (said plainly) | An agent can delete the key in Vajra's own repo. The diff shows it. Same class as `session_rules_from`. |
| vs your 2026-10-03 ruling | "No per-claim `obeyed:` judge" was ruled for **projects**. Vajra's own repo keeps blocking from 132, but it's satisfied the way S183/S184 already do it: **one** release-coordinator judges all the `obeyed:` answers in one dispatch, not one judge per claim. Nothing new is added. |
| Record | DECISION-007 S185 addendum. **This changes S132's clause**: 132+ blocks only where the key is set. |

**Same mistake in the design-advisor rule (threshold 133)?** Same units, opposite effect: a project's old prompts with no marker are exempt below its session 133. **Pick: leave the number, fix only the words** (rec 4). `src/mandate/mod.rs:428` prints "threshold 133", which is Vajra's numbering, the same mistake F107 fixed. Using `session_rules_from` here would quietly opt rudra into a new block from its session 16. That's more blocking for projects, and nobody asked for it. rudra already uses the design-advisor in 16 of 19 prompts.

### F110 — the approvals guard blocks harmless text

**Today:** `scripts/hook-approvals-guard.sh:75` blocks any command that names the approvals folder and has a `>` anywhere in it: a heredoc, a markdown `>` quote, or the `<noreply@…>` in a commit sign-off. **Hits: 4 on 2026-10-04.** rudra S17 hit it once, S184 twice, and **this session once**, recording the design-advisor's own text (it quotes the folder). Each one cost a detour of seconds to a minute.

**Your choice (the designer and I see it differently):**

| | Option | What it does | Cost / risk |
|---|---|---|---|
| **a** | **Better message** (design-advisor rec 5, the S173 rule) | The block stays. The message says the way out: "put the text in a file with the Write tool, then `git commit -F <file>`". | Tiny. **Named, not closed:** the false block still happens; it just costs one step instead of a guess. |
| **b** | **Read where the `>` really writes** (tech-lead rec 2, design-advisor rec 6) | It blocks only when a redirect's real target is inside the folder. A heredoc body, a `<…>` email, or `> notes.md` no longer blocks. Anything it can't resolve still blocks: `$`, backticks, globs, `~`, `>(…)`, any `cd`/`pushd`/`-C`/`env -C`, a symlink in the path. | **A real fix** for most hits. But it's a parser in bash, and S173 needed 8 review passes on guard parsing. A command starting `cd x && …` still blocks (fail closed), so some false blocks remain. |

**My recommendation: (b), with (a)'s message on whatever still blocks.** Four hits in one day is not rare. (b) only stops blocking writes it can *prove* don't go into the folder, the same rule the guard already uses for `/dev/null` and `>&1` (line 68). So it stays "guard changes only add". Test it against a list of commands (rec 11): every command the S182 guard blocks must still block, except a named list of proven non-writes. If you'd rather not risk the review loop, (a) is honest as long as we call it "named, not closed".

### S182's three parked guard holes

| Rec | Hole | Severity | Proposed fix (all ADD-only) |
|---|---|---|---|
| 1 (design rec 7) | `.ai/hooks/../approvals/x` walks past **both** the Write check and the Bash check | **MED** (a real Write-tool hole) | Treat `..` + `approvals` as the folder in both places. Delete the false comment at line 43 ("a spelling cannot step around it"). |
| 5 (design rec 9, 10) | Writers the list misses: `git checkout/restore/clean/reset/stash/apply`, `find -delete/-exec`, `rsync`, `curl -o`, `wget`, `tar`, `unzip`, `patch`. Also `sh`, `bash`, `zsh`, `eval`, `source`, `xargs` are not on the interpreter list (`sh x.sh .ai/approvals` passes). | MED (git, find, shells) · LOW (the rest) | One regex line each. It only blocks commands that name the folder, so ordinary work is untouched. |
| 2 (design rec 8) | `merge_claude_settings` still re-adds a hook already wired under a different matcher (`src/cli/init.rs:988`) | LOW, mostly fixed in S182 | Push the matcher with only the missing hooks. |

These are your own controls on any project, not Vajra policing its own paperwork. Recommend fixing all three alongside F110.

## F114 and F115

| # | Verdict | Evidence | Fix | Size |
|---|---|---|---|---|
| **F114** | **Confirmed, first-run.** Fresh `vajra init`, then `bash scripts/verify-closeout.sh --ledger` → `exit=1`, nothing printed. | `bash -x`: `ls 'sessions/session-*-review.md'` finds nothing; `set -euo pipefail` kills the script inside `_ledger_worktree_sessions`. | Tolerate "no reviews yet" (`ls … 2>/dev/null \|\| true`). Print "ledger: no reviewed sessions yet". Exit 0. Both copies (this repo + scaffold). | XS |
| **F115** | **Stale fixture, not a regression.** Same red at e1c348e^ (S182 merge) and e1c348e (S183 merge), with binaries built at each. | Both runs: `refusing to advance: … no binding tech-lead crew decision (Crew gate)`. The tech-lead gate (S135, c7c2ca1, 2026-08-27) runs before the obeyed gate. The fixture never writes a tech-lead file, so the obeyed gate never gets a turn. | Rebuild the fixture in the F113 session: add a tech-lead record (or `tech-lead: skipped — <reason>`) and `obeyed_blocks_from: 132` (the fixture is a fresh project, so after F113 it should *warn* without the key and *block* with it, and test both). | S |

**What F115 really means:** "registered ≠ run" (S129) again. A check went red 50 sessions ago and nobody saw it, because old verify scripts are never re-run. So the promise "an unchecked `obeyed:` stops `--advance`" has had **no working proof since S135**. Note this only matters in Vajra's own repo after F113.

## Goal 1 — Audits

| Audit | | Finding |
|---|---|---|
| **delivery_progress** (first, F93) | 🟡 | **Shipped since S180:** #218 S181 (your approval is a record; strict session type; named waivers; text-bound stamps) · #219 S182 (shipped to projects: one approvals guard, wired by `--sync-fleet`) · #220 S183 (close lints like CI on CI's Rust; main's red CI fixed; F104–F106) · #221 S184 (F103 init never hangs, F107, F108). **Vision goals moved:** your trust: your controls went from "text the agent can type" to records (S180 Goal 0 rows 1–4 **all built**). **Strangers: NONE.** **On track:** for the founder-trust goal, yes. For reach, it's not attempted, by your ruling. **Cost ratio:** 4 sessions, $0 metered here, 22 fleet dispatches, 2 rudra runs. Improving: S181 needed REJECT → ACCEPT, S183/S184 closed on the first review. |
| vision_alignment | 🟡 | North-star (a coach any agent can follow) is still right. The work is the shortest path to *your* trust, and you ruled that comes first. The pivot test from S180 still stands: once released, 0 outside users after a fixed window means the bet needs re-testing. |
| roadmap_alignment | 🟡 | The next items are F113/F110 (yours) and F67 (parked 3×). The highest-leverage one for a *user* is still F67: the receipt is the one number every user sees, and it is ~5× wrong for interactive runs. The roadmap's "next" is fixes for one user's project. That's right for now, but every item is inward. |
| state_drift | 🟡 | `STATE.md` says "S184's PR (open)", but it merged as #221 this morning. `ROADMAP.md`'s top line still reads **Session 166** (19 sessions stale; S180 N4 flagged it, not fixed). Both are hand-kept. |
| knowledge_staleness | 🟢 | 361 lines (333 at S180). Still within its pruned range. |
| constraint_violation_review | 🟢 | 103 commits since S180, **none over 3 files** (checked each). Every session on its own branch, merged by PR. One honest note: the 2 records in this session went through a temp file in `.ai/` because both guards blocked the normal routes (N1, N2, F110). |
| constitution_review | 🟡 | The rules hold. Two of them now block their own users: the ground-truth guard blocks writes and commits **outside the project** (F56, seen twice today), and its reason never reaches the agent (N1). **Meta-check below.** |
| cost_review | 🟡 | Vajra's sessions: $0 metered. rudra S16/S17 receipts read ~$83.54 and ~$110.63, **~5× too high** (F67, parked). So the real cost is roughly $17–22 a run. The $5 budget warning means nothing next to those numbers. Paperwork: **55 of 103 commits (53%)** are review, stamp, summary or state commits. S170 measured 66% paperwork *lines*. Better, still the majority. |
| dogfood_check | 🟡 | Real paid use: your rudra S16 and S17 under `vajra claude`. S17 was GREEN, 8/8 stations, 0 waived, the best run yet. **From the S183/S184 summaries, not rudra's own close logs** (I didn't grep them for WAIVED/N/A), hence 🟡, not 🟢. |
| dogfood_staleness | 🔴 | `vajra next --dogfood-age` → **last dogfood S161, 2026-09-11, 23 sessions / 23 days.** **Wrong, the same blind spot S180 named (N3):** it reads only this repo's git, and rudra runs are invisible to it. The real answer is "2 runs this week". The tool's answer is red and wrong. The real use (2 runs this week) is in the dogfood_check row. |
| pipeline_advance_check | 🟢 | `vajra next --stations`: S181 **8/8** · S182 **8/8** · S183 **8/8** · S184 **8/8**. First time all four since a GT are full (S180 saw 7,8,8,7,7). It measures the machine, not users. |
| stranger_check | 🟢 | `bash scripts/stranger-check.sh` → **21 passed, 0 failed, exit 0**. "GREEN — a stranger's first ten minutes work." Downloads/stars: 6 (v0.2.0) / 20 (v0.1.0) / 19 (crates.io 0.1.0) / **0 stars**. Unchanged since S180. Uncovered first-contact defect: **F114** (a fresh project's first `--ledger` fails silently). Add it to the stranger check when fixed. |
| scaffold_drift_check | 🟡 | `bash scripts/scaffold-drift.sh` → **exit 0**. It names its own scope limit: `init.rs` still hand-types `communication.forbid`, `load_order`, `demo.required_elements` against live twins. Known since S129, unchanged. |

**Meta-check — did this audit's own mechanism miss a kind of drift?** Yes, two:
1. **Nobody re-runs old checks.** F115 sat red for 50 sessions. Every audit reads the *latest* verify script. None asks "do the old promises still hold?" That's how a gate's only proof died quietly. (Not proposing a new gate. That would be policing. Proposal: the F113 fix session re-runs verify-132 as its proof, and the ground-truth checklist gains one line: "re-run the verify script of any gate touched since the last GT".)
2. **The guards can't tell "this project" from "somewhere else".** The ground-truth guard blocked a `git commit` in a throwaway test repo and a file write to the scratch folder (F56, now hit by the auditor itself). Rules written for one repo leak onto every path the agent touches.

## Goal 2 — Is the rudra loop still worth it?

| Since S180 | Count | Which |
|---|---|---|
| Vajra defects the rudra runs surfaced | 6 | F104, F105, F106, F107 (S16 logs) · F110 (S17) · F113 (follow-on from F104/F107) |
| Vajra defects found in Vajra's own work | 6 | F101, F102 (CI) · F103 (own verify hung) · F108 (advisor) · F114 (cold review) · F115 (own verify) |
| rudra's own | 3 | F109, F111, F112 |

**Cost:** rudra S16 + S17 receipts read ~$83.54 + ~$110.63; at F67's ~5× overstatement that is **roughly $17 + $22 ≈ $39 real**, plus about 2 hours of your time at the keyboard (S16 ~55 min, S17 ~66 min active). For **6 Vajra defects** that is **~$6.50 and ~20 minutes of yours per defect**. The money is small; your time is the real price.

**Verdict: still worth it, but it's flattening.** S171's first run found 34 findings, many serious. S16/S17 found wording, empty folders, and one design mistake (F113). The one real design bug came from the loop, so it still earns its keep. But the size of what it finds is dropping, and every fix makes rudra the only project tuned to Vajra. **What would make it worth more:** the same loop on a *second* project or a second person. Bugs only a stranger hits (like F114) don't show up in a project that has adapted to Vajra over 17 sessions.

## Goal 3 — Shortest path to a stranger getting value

Unchanged from S180, and you've ruled it waits until you trust Vajra.

| Step | Who | State |
|---|---|---|
| 1. Fix what a first-run stranger hits: F114 (silent exit 1), F67 (receipt ~5× high) | agent | F114 XS · F67 parked by you, wants the permanent fix |
| 2. `cargo publish` 0.2.x | you, one command | undone since S168 |
| 3. One outsider runs it in their own repo and reports back | you find one person | never happened |

**The honest question for you:** is there a point (a rudra session number, a date) where "I trust it" becomes "someone else tries it"? Without one, Goal 3 stays "later" forever. That's not a defect, just the only open question this audit can't answer.

## New findings for S186+

| # | Finding | Evidence | Sev | Proposed fix |
|---|---|---|---|---|
| N1 | **The ground-truth write block prints its reason to stdout, so the agent sees "No stderr output"** and can't tell why it was blocked. S181 fixed this for the approvals guard only. | This session: the Write tool to the scratch folder returned "No stderr output". `scripts/hook-pre-write.sh:72` `echo "[HOOK BLOCK] …"` with no `>&2`; same at line 38. The GT `git commit` block in hook-pre-bash also came back "No stderr output". | **MED** | `>&2` on every `[HOOK BLOCK]` line in both hooks and the scaffold copies; one test per hook that the message reaches stderr. |
| N2 | **The ground-truth guard blocks work outside the project**: a `git commit` in a throwaway test repo, and a write to the agent's scratch folder. | This session, twice. F56 class (parked LOW at S173). | MED (it blocked this audit) | Only block paths under `$ROOT`. A commit check runs in its own `git -C` dir. |
| N3 | **F115's lesson**: the obeyed gate's binding on `--advance` has had no working proof since S135. | above | MED | Fixed by the F113 session's new fixture. Plus one checklist line in the GT questions (meta-check 1). |
| N4 | `vajra next --steps` never tells you the approval record is missing. You said "approved" in chat, and the list still showed nothing about it. I had to say it. | This session's boot list vs `.ai/approvals/` | LOW | One line in `--steps`: "✗ the founder has approved this session (`vajra approve NN` in their own terminal)". |
| N5 | `--dogfood-age` still blind to rudra (S180 N3, unfixed) | above | MED (unchanged) | Read a project list, or say "this repo only" in its output. |
| N6 | STATE/ROADMAP headers hand-kept and stale (S180 N4, unfixed) | above | LOW | Derive the ROADMAP header, or delete it. |
| N8 | **A ground-truth prompt never passes the prompt check, so `--advance` refuses it.** The GT shape has Goal/Output but no `## Deliverables`/`## Acceptance`. S180 got past by **hand-typing `.ai/SESSION`** in its closeout commit (c265be9), which is the F85 class S181 meant to close. S185 added the two sections at close, restating Goal 0–3 with no new requirement, then advanced normally. | `vajra next --advance` on 2026-10-04: "malformed — missing section(s): deliverables, acceptance" | LOW-MED | Have the GT prompt template carry the two sections, or let the Analyst gate read `session_type: GROUND_TRUTH` and require Goal + Output instead. |
| N9 | **A ground-truth sign-off is text the agent types.** S181 made the session approval a record (`vajra approve NN`), but "the founder signs the report off before code resumes" is still a chat word the agent copies into the report. It's the gate that lets code resume. | cold review S185 rec 2; this report's Founder rulings | LOW | Let the next session's `vajra approve NN+1` count as the sign-off of the GT before it, and say so in the GT template. No new command. |
| N7 | **Old-version test checkouts are left behind.** 11 `…/T/tmp.*/old` folders at e1c348e exist, 4 still registered as git worktrees. `verify-session-184.sh:14` removes its checkout on exit, so these are probably runs that were killed (the 600 s bound, or F103's hang). | `git worktree list` on 2026-10-04 | LOW | Remove them now (`git worktree remove --force` each + `git worktree prune`; your yes). Make the scripts put the checkout under one known folder, so a stale one is found and cleared on the next run. |

## What I did NOT do / fakest green

- **No code.** F113, F110, F114, F115 and the S182 recs are designs only.
- I tested F115 at two commits, not bisected to the exact commit. The S135 cause is from `git log -S"(Crew gate)"` (c7c2ca1) plus the identical refusal text, not a build at S135.
- I didn't read rudra S16/S17 transcripts. The rudra tally comes from the S183/S184 summaries.
- **This session's two crew records went through a temp file in `.ai/handoffs/`** (created, recorded, deleted) because the Bash route hit F110 and the scratch route hit N2. The recorded text is the advisor's exact text (provenance verified by text-sha).
- **The `## Design` and `## Advice` answers were added to the prompt at close**, after the branch was renamed `session-185-closeout`. Before that, a ground truth may not edit `prompts/` (the write hook allows only the report, reviews, `.ai/` and `scripts/`).
- **Fakest green:** the 8/8 stations and 21/21 stranger check. Both measure the machine. The honest numbers are 0 stars and 6 downloads. And the green 8/8 sits next to a check that has been red, unseen, for 50 sessions.

## Advice answers (the recs from this session's crew)

- tech-lead rec 1 (F113: the binary stops knowing the number; decide 133; restore the disclosure): **adopted into the design above**, built in S186 after your sign-off.
- tech-lead rec 2 (F110: block only when the target resolves into the folder; `..`; list recs 2/5 without new blocking): adopted as option (b). Recs 2/5 are listed with severity, and I recommend fixing them (your controls, not Vajra's paperwork). That differs from the tech-lead's "do not design new blocking". Your call.
- tech-lead rec 3 (F115 at e1c348e^ and e1c348e; size F114): **done this session**, above.
- design-advisor recs 1–4, 7–12: adopted into the designs above. Built in S186 after your sign-off.
- design-advisor rec 5 (message-only for F110): offered as option (a). I recommend (b) with (a)'s message. Your call.
- design-advisor rec 6 (target reader, tightened): this is option (b).

## Three options for next (A/B/C)

| | Session | Goal | Why | Risk |
|---|---|---|---|---|
| **A (recommend)** | **S186 — the fix session from this report** | F113 (`obeyed_blocks_from`), F110 (your pick a/b) + S182 recs 1/2/5, F114, F115 fixture, N1 (stderr) | Everything you already said "fix" to, plus two first-run bugs a stranger would hit | Six small items in one session. Guard parsing (if b) has needed many review passes before. Keep it to one PR, and cut (b) to its own session if it grows. |
| B | **F67 — the receipt reads the tool's own cost** | Interactive runs show the real cost, not ~5× | The one wrong number every user sees. Parked 3×, and you want the permanent fix. | Claude Code may not write a cost into an interactive run's transcript. Might end in "can't, say so". |
| C | **The non-Claude tools brainstorm** (F91, F94, F95) | Design for OpenCode first | Promised since S179 | A design session: nothing a user runs comes out of it. |

**Sign-off needed:** approve this report, pick F110 (a) or (b), and pick A/B/C.

## Founder rulings on this report (2026-10-04)

- **Report:** approved — **the founder's chat reply ("approved", 2026-10-04), transcribed here by the agent.** Unlike `.ai/approvals/session-185.json` (the session approval, written by his own `vajra approve 185`), no founder-run record exists for a report sign-off, so this line is text the agent typed (cold review S185 rec 2; N9).
- **F110:** option **(b)**: read where the `>` really writes, fail closed on anything unresolvable, with (a)'s message on whatever still blocks. Built in S186 with S182 recs 1/2/5.
- **Next:** option **A**: S186 = the fix session (F113, F110 b + S182 recs 1/2/5, F114, F115 fixture, N1).
- **N7:** yes, delete. Done in this session: all 11 leftover `…/T/tmp.*/old` checkouts removed and `git worktree prune` run; `git worktree list` now shows only the main checkout.
