---
role: design-advisor
session: 195
agent: claude-code-subagent (verified: toolu_01FjhhUmGs7UwP6dcUugcXVN; text-sha: de460e167390b91aaad37d1e4948f52133dbb918f7fc289b24d64ec0f1d043d9)
source-sha: 46c566b3c3423be7ee8787eee7492864389789622c1586f40f48dc1e66ca9ca6
captured: 2026-10-12T17:33:19Z
cost_usd: null
---

# Design-advisor handoff — session 195

## Design-advisor brief: S195 (ground truth, design-flavoured picks only)

**Marker:** keep `design-significant: no` for S195 itself. A review-only session picks designs and builds none, so no interface changes. The fix session that builds rec 1 must say `design-significant: yes`.

rec 1 — F125: the `-closeout` opening should open only when the founder's sign-off of the report has been recorded (`vajra approve NN --close`), not when the agent names a branch; amend DECISION-011.

The agent can't fake this. The approval folder is already watched before and after every agent tool call (DECISION-011 S188 addendum). It also adds no new ceremony: the GT acceptance already says "the founder signs the report off before code resumes". Today that sign-off is a chat word (memory: chat "approved" is not an approval record), and this turns it into the record.

What changes: in `hook-pre-bash.sh:53-61` and `hook-pre-write.sh:42-50`, read the session number on `*-closeout` and `*-enforcement` branches too. On a ground-truth slot the guard stays on unless the close record exists.

The same hole is wider than F125. If the branch name has no `session-NN` in it, `SNUM` is empty and the guard is off (`hook-pre-bash.sh:56-58`). The fix should either cover that or name it.

Rejected:
- "The report is on disk": the agent writes it, so a stub opens the gate.
- "The report is committed": impossible, because the guard blocks commits until the branch is open.
- `VAJRA_GT_WAIVER` at close: needs a relaunch.
- Checks based on timing or commit counts: guessing.

This isn't new policing of Vajra's paperwork. It stops an opening the agent grants itself in a user's project (the same class as S69's "jurisdiction is self-granted").

rec 2 — F123's remaining routes: keep them named, not closed; no record change (the DECISION-007 S194 addendum already names them).

None of them reaches the shared main: pre-push stopped both pushes in rudra S20. A local main can be recovered from the reflog. Closing them would need either the reference-transaction hook or a text match on `--no-verify`. The S194 addendum already rejected the hook (it fires on the founder's own `git pull`), and a text match is the command-text guessing S173/S188 retired. The real harm in S20 was the founder trusting "fully closed", and F121 now answers that.

rec 3 — F121: keep "the agent can write the result file" named (bar-raising, as in DECISION-011). The one step worth taking is for "only at exit": a Stop hook that shows the newest *unseen* result line to the founder (Claude Code's `systemMessage`). Do it only after the founder's next real synced `vajra claude` run proves the exit line live. Amend ADR-0004 (its S194 addendum).

This targets exactly what happened in S20: he merged PR #24 before exiting. It reads the same fixed-format file and judges no words, so it isn't the "Stop hook judging the agent's words" the addendum rejected. Shows, does not stop: that limit stays named. Order: live proof first, because S194's fakest green is a stand-in `claude`.

rec 4 — The Haiku question: order (c), then (d), with (b) as a standing GT audit. Reject (a).

- **(c) now, no code:** a plain "tested with" fact in the README and quick-start. Steps that are only instructions were followed on Opus (rudra S16–S19) and skipped on Haiku 4.5 (S20); the blocks held on both. The README is the founder's spec, so this is his call.
  - Don't build a launch-time "small model" check. The model is often picked mid-run with `/model`, so launch can't know it. And a hand-kept model list is the price-list mistake again (read the tool's own facts, never grow a list).
  - Say it as an observed fact, not a softened promise (memory: "No release until vision").
- **(d) next, in its own design session:** Vajra itself runs the required fidelity-reviewer at close (`claude -p`, on a model Vajra picks, not the session's). This is what makes the promise true on a cheap model: a cheap coder plus a strong reviewer the agent cannot skip or impersonate. It fixes F122 and S138's "required ≠ required" at the root.
  - It needs a **new DECISION record**, or a DECISION-007 addendum that **deviates** from the S131/S133 rule that the agent dispatches the reviewer. It also touches DECISION-002 (independence).
  - It costs real money each close; weigh that against the founder's "then cut cost".
- **(b) as an audit:** each GT classifies every step that is only an instruction as "make it a gate" or "drop it". That is the founder's "prefer removing ceremony". No record needed.
- **(a) rejected:** the gates already caught S20 (close RED, `required-crew` FAIL). The failure was visibility, which F121 addressed. More gates is the policing the founder banned.

rec 5 — N10: keep check 6, and let a line opt out with an explicit marker on the line itself (`# source-claim: <why>`) that the awk skips. Add it to the 3 lines.

All three hits are honest claims about the source, not behaviour shown by a grep:
- verify-189:120 and verify-193:132 decide with a real `diff` of `MODEL_PRICING`; `grep -c` only fills the count in the `ok` message.
- verify-191:103 checks that a test fixture matches the real S188 line; the behaviour test itself runs at line 99.

The check can't tell "a claim about the source" from "behaviour faked by grep", so the author should say which on the line (recorded markers, not guesses). The fidelity-reviewer reads the reason.

Rejected:
- Dropping the check: the S163 hollow-grep hole was real.
- Tightening the awk to skip `$(… grep -c …)`: another text heuristic, and it misses 191:103.
- Waiting for the lines to leave the last-10 window: a red that everyone ignores teaches people to ignore red.

**Record:** no design record covers check 6 today; it came from the S163 finding, not an ADR. If the founder wants it recorded, a short DECISION-002 addendum is the nearest home. Otherwise "no record covers this yet" is the honest citation.

### Files read
- /Users/suman/playground/vajra/prompts/195-task-ground-truth.md
- /Users/suman/playground/vajra/sessions/session-194-summary.md
- /Users/suman/playground/vajra/.ai/ROADMAP.md (766–800)
- /Users/suman/playground/vajra/docs/decisions/DECISION-011-controls-the-agent-cannot-type.md (S188 addendum)
- /Users/suman/playground/vajra/docs/decisions/DECISION-007-agent-fleet.md (S194 addendum, line 1748)
- /Users/suman/playground/vajra/docs/decisions/DECISION-008-session-type-detection.md (52–59, "GT override is structural")
- /Users/suman/playground/vajra/docs/adr/0004-meter-receipt-design.md (S194 addendum, line 572)
- /Users/suman/playground/vajra/scripts/hook-pre-bash.sh (43–69), /Users/suman/playground/vajra/scripts/hook-pre-write.sh (30, 42–63)
- /Users/suman/playground/vajra/scripts/scaffold-drift.sh (290–317)
- /Users/suman/playground/vajra/scripts/verify-session-189.sh (line 120), /Users/suman/playground/vajra/scripts/verify-session-191.sh (line 103), /Users/suman/playground/vajra/scripts/verify-session-193.sh (line 132)

## Handoff Delta
- `+` new: first design-advisor handoff for this session (7006 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
