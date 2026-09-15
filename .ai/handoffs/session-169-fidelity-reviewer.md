---
role: fidelity-reviewer
session: 169
agent: claude-code-subagent (verified: toolu_011Qwzxjcu3xrPfdfdXUyCrK)
source-sha: 8804b5efa68b5aa0a26b645ff8894987e1daacf2504932c0909b6560f5cc9af4
captured: 2026-09-15T03:37:22Z
cost_usd: null
---

# Fidelity-reviewer handoff — session 169

**Brief:** Session 169 did most of what it promised, and did it for real. On Vajra's own sessions, `done: defaced prose`, short or long shas, shas with no commit and `pending:` steps are now blocked by working code, with tests that check the exact block reason. But it ships a bug to every new user. The new check that can't be waived looks for files named `session-1-...`, while Vajra itself writes `session-01-...` (`src/fleet/mod.rs:99` formats `session-{session:02}`). So in a fresh `vajra init` repo, CODE sessions 1–9 (except 5, a ground-truth session) can never pass the tech-lead check, even with a real tech-lead handoff. The same mismatch means a claimed verdict on those sessions is never seen. The verdict-claim search is also easy to dodge. The summary does not exist yet. I did not run anything. I read the code, and I tied each commit to its files from the commit messages, because I could not open the commits one by one.

**Verdict:** REJECT

| # | Requirement | Grade | Evidence |
|---|---|---|---|
| AC1 | Prose / 6-char / 41-char `done:` blocks, line named | SHIPPED | `sha_re='done:[[:space:]]+([0-9a-f]{7,40})([^0-9a-zA-Z_]\|$)'`; if it doesn't match, the line is logged as `BAD-SHA:`. Tests AC1a–c. Uppercase or backticked shas also block (errs on the safe side). |
| AC2 | Well-formed sha that isn't a commit blocks, sha named | SHIPPED | `git cat-file -e "${sha}^{commit}"`, logged as `NO-SUCH-COMMIT ${sha}`. Tests AC2a (`defaced`) and AC2b (made-up 40-hex). |
| AC3 | Claimed verdict with no review file or fidelity handoff blocks, even under the waiver | PARTIAL | `check_claimed_evidence` has no waiver path and runs in the full order before the final `exit 1`. The claim search is `grep -iE 'verdict[*_[:space:]]*:' \| grep -E 'ACCEPT\|REJECT'`, and it misses `Verdict — ACCEPT`, `verdict: accept` and a verdict on the next line. It also reads `session-${N}-summary.md` without zero-padding, so sessions 1–9 are never checked. |
| AC4 | CODE session with no tech-lead file blocks at close | PARTIAL | Checked with plain `-s`, can't be waived; tests AC4a/b plus the full-run test. But `.ai/handoffs/session-${N}-tech-lead.md` is not zero-padded, while the fleet writes `session-01-…`. It wrongly blocks sessions 1–9 that do have the file, and the scaffolded kickoff Type line contains `**CODE**`. |
| AC5 | Decide how a post-merge step is recorded without a skip env var | SHIPPED | DECISION-007 S169 addendum, `## Design` ruling, and the `NO-DONE step N` block (test AC5). The block can still be waived with `VAJRA_CLOSEOUT_WAIVER`; this is disclosed. |
| D1 | `verify-closeout.sh`: tighter sha check, claimed-verdict check, tech-lead check | SHIPPED | All three are in the diff, wired at line 1124. Leftover wording: line 267 still says "valid 7-char hex SHA (S166)" and line 273 still says "7+". |
| D2 | Scaffolded gate carries the same checks | PARTIAL | `verify-closeout-scaffold.sh` (the `include_str!` source, `init.rs:1604`) carries the checks and adds `is_code_session`. But the padding bug hits strangers, whose sessions really are numbered 1–9. |
| D3 | `verify-session-169.sh` with behavioral fixtures | SHIPPED | 15 cases on each of the two gates plus the scaffold presence check = 31. Each matches the exact reason with `grep -F` next to pass cases. Every fixture is session 41–55, which is why the padding bug went unseen. |
| D4 | Summary + exactly 3 ranked next candidates | NOT-BUILT | `sessions/session-169-summary.md` does not exist. |

**5 of 9 SHIPPED** (3 PARTIAL, 1 NOT-BUILT).

**Fakest green:** The `git cat-file -e` existence check. It proves a sha names *some* commit anywhere in the object store: the repo's first commit, a commit on another branch, or an unreachable one. It does not prove the commit belongs to this session or does what the step says. `step 1 — done: <any old real sha>` passes, and so does a line that starts with prose and ends with `done: <real sha>`, because the first match wins. The prompt's goal ("refuses … made-up evidence") reads as closed, but only one kind of made-up evidence is closed: a sha that doesn't exist. The same goes for the fixture that goes red "for the right reason": it only ever uses sessions 41–55, so it can't see that the unwaivable check is blind or wrong for the first nine sessions of every new repo.

rec 1 — Resolve session files zero-padded (`printf '%02d'`), matching `src/fleet/mod.rs:99` and `src/analyst`, in both gate copies, and add session-01 fixtures to verify-session-169.sh.
The claimed-evidence check can't be waived, so today this bug is a close that can never pass. The same unpadded path already exists in `check_fidelity_review` and `check_review_attestation`.

rec 2 — Widen the verdict-claim match: case-insensitive ACCEPT/REJECT, and a verdict word followed by any separator (`:`, `—`, `=`), with fixtures for each dodge.

rec 3 — Require each `done:` sha to be reachable from the session branch and not from the merge-base (`git merge-base --is-ancestor`), so an old real sha cannot back a new step.

rec 4 — Replace the stale S166 block/FAIL wording at verify-closeout.sh lines 267 and 273, or add a check that the carried functions are byte-identical across both copies.

rec 5 — Write sessions/session-169-summary.md with exactly 3 ranked next candidates before closeout.

rec 6 — Record in DECISION-007 that `NO-DONE`, a made-up sha, and a plan written as `1)` or indented (which hides every plan step from the parser) remain waivable or can be dodged.

obeyed-check tech-lead rec 1 — implemented: 14e6cc8 — `check_claimed_evidence` has no `waiver_ok` path and uses a plain `-s` tech-lead file test. The other checks keep their waivers beyond "binary not built", as the note discloses.
obeyed-check tech-lead rec 4 — implemented: b9a75ed — every case pairs an exit code with `grep -F` on the exact block line, beside pass cases, on both gates.
obeyed-check tech-lead rec 5 — implemented: 07c2f2d — the separate `include_str!` source (`verify-closeout-scaffold.sh`) is edited in its own commit.
obeyed-check design-advisor rec 1 — implemented: 07c2f2d — DECISION-007 S169 addendum records option (b), the ROADMAP row, and the rejected alternatives.
obeyed-check design-advisor rec 2 — implemented: 14e6cc8 — `plan_nums`/`done_nums` sets; a plan step with no existing `done:` blocks as `NO-DONE`, `pending:` included.
obeyed-check design-advisor rec 3 — implemented: 14e6cc8 — only the claimed-review and tech-lead checks skip the waiver, using plain file tests with no binary.
obeyed-check design-advisor rec 4 — implemented: 07c2f2d — the diff has no `src/` change; the work is bash plus the scaffold only.
obeyed-check design-advisor rec 5 — implemented: 07c2f2d — the addendum says it supersedes the S133 waiver clause, and `## Design` states the departure.
obeyed-check design-advisor rec 6 — implemented: b9a75ed — `run_cases` runs on both Vajra's gate and a real `vajra init` gate, so a difference in checked behavior goes red. It is not byte-level (see rec 4).

Both refusals give a real reason. Tech-lead rec 2: git prints lowercase, and uppercase is blocked as prose, so it errs on the safe side. Tech-lead rec 3: the role that owns AC5 ruled against it, for concrete reasons (two parsers, and a ROADMAP row can be added in the same commit that cites it).

## Handoff Delta
- `+` new: first fidelity-reviewer handoff for this session (7373 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
