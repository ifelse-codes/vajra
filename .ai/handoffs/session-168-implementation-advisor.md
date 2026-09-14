---
role: implementation-advisor
session: 168
agent: claude-code-subagent (verified: toolu_01LrREyHB9D5Mrc5YZsdugGo)
source-sha: a43d491564bfb668b74834cb3eb62200acbc24d0e87ef4192621dd6f08dc1866
captured: 2026-09-14T15:17:36Z
cost_usd: null
---

# Implementation-advisor handoff — session 168

**Brief:** Independent judge of session 168's `obeyed:` dispositions (implementation-advisor; made none of the graded recommendations; read only one patch per named sha, ran nothing). 24 of 25 hold up against the commits they name; 1 mismatch (tech-lead rec 5 → f1e950d).

Notes (condensed): tech-lead rec 1/2/3 are graded on what the commit carries (the handoffs) — the inputs given to an advisor and running verify-closeout before merge cannot be seen in a commit. Design-advisor recs 5 and 6 were split across two commits; the named commit carries one half and the other half is already in the tree at that commit. Demo-producer rec 9: no literal light≠dark comparison, the one-line rec is done. Demo-producer rec 10: fails on uppercase `DRIFT`, the gate's own drifted-file word.

obeyed-check tech-lead rec 1 — implemented: 2165cec — adds the design-advisor handoff, which rules on the opt-out hole (warning alone does not close it; `complete` in required_elements does), plus DECISION-010 and the DECISION-009 pointer; the exact inputs the advisor was given cannot be seen in a commit
obeyed-check tech-lead rec 2 — implemented: ce72d1b — adds the demo-producer handoff, whose brief says it read only the template, `demo-kit.sh` and the draft `demo-session-168.sh` (14 recs); the Advice answers are not in this commit
obeyed-check tech-lead rec 3 — implemented: 17011a5 — adds the fidelity-reviewer handoff (inputs: prompt, review diff, `verify-session-168.sh`, summary), grading AC1 SHIPPED (bare tokens refused), AC4 SHIPPED (fixtures incl. echoed kit signs, reason-text rows), AC13 NOT-BUILT; the verify-closeout-before-merge step is not something a commit can show
obeyed-check tech-lead rec 5 — mismatch: f1e950d — adds `demo-session-168.sh` and `verify-session-168.sh`; it does not grade AC13 NOT-BUILT, does not name the release in the summary as the next candidate (its Next slide names S169), and mentions the release only as "not shown"
obeyed-check design-advisor rec 1 — implemented: a9d277a — `is_kit_built`: script text contains `demo-kit.sh` OR output has a `demo:kit`/`demo:complete`/`demo:fact` line; otherwise `LegacyGreen` with a warning naming the downgrade and the dodge
obeyed-check design-advisor rec 2 — implemented: 84e2375 — adds `complete` (not `fact`) to `.ai/CONSTRAINTS.yaml` `required_elements`; built-in default untouched; also adds it to the `vajra init` scaffold's CONSTRAINTS (for new projects only, which DECISION-010 records)
obeyed-check design-advisor rec 3 — implemented: 9d0282a — `check_facts`/`fact_lines`: closed `FACT_KEYS`, `strip_ansi` before an exact `key=value` match, blocks on an unknown key, the same key twice with different values, and any differing value
obeyed-check design-advisor rec 4 — implemented: 9d0282a — `check_facts` blocks when any closing-session key is missing ("must show every fact"); `demo_facts` always prints every key, with `none`/`0` for absent facts
obeyed-check design-advisor rec 5 — implemented: a9d277a — the gate sets `VAJRA_BIN` to `current_exe` via the new `run_captured_env` and derives facts from `run_path` (clean room) or `root`, right after the run; the kit's `${VAJRA_BIN:-vajra}` half came in the earlier 7a85060 and is exercised by this commit's kit fixtures
obeyed-check design-advisor rec 6 — implemented: 7a85060 — `dk_check` runs the command through `dk_run_v` (keeps `_DK_OUT`/`_DK_RC`) and refuses bare PASS/FAIL/digit/empty with a message naming the new form; the break for old demos and the `dk_check "x" true` limit are recorded in DECISION-010 from the earlier 2165cec
obeyed-check design-advisor rec 7 — implemented: 2165cec — DECISION-010's Honest limits: "A hand-typed `echo demo:complete` still satisfies the `complete` element; only the facts check is unforgeable"
obeyed-check demo-producer rec 1 — implemented: f1e950d — the `LIB TESTS` tile and `REC_TESTS` both come from one variable, `REC_TESTS_N`
obeyed-check demo-producer rec 2 — implemented: f1e950d — the Old line reads "Old (recorded — the S167 gate is not re-run here): …"
obeyed-check demo-producer rec 3 — implemented: f1e950d — adds `dk_check … git cat-file -e "$S167:scripts/demo-kit.sh"`; the after check requires before exit 0, after exit 1 and a `grep -q "refused"` on the after output
obeyed-check demo-producer rec 4 — implemented: f1e950d — reword option: the panel says the kit catches the typed PASS and the gate catches the typed tile on the next slide, where a live "typed tile, no facts printed at all" row runs the real gate
obeyed-check demo-producer rec 5 — implemented: f1e950d — the Why column is `first_reason` of the gate's own output; each row has a `dk_check -q` that greps the expected reason pattern
obeyed-check demo-producer rec 6 — implemented: f1e950d — adds the rows "a typed tile, no facts printed at all" (want NOT READY, pattern "prints no demo:fact") and "fakest green: dk_check "x" true" (want READY)
obeyed-check demo-producer rec 7 — implemented: f1e950d — forged stations value is `$((sp + 1))` from a live `--demo-facts 99`; the legacy-old row's live `dk_check` greps the warning "not built on"
obeyed-check demo-producer rec 8 — implemented: f1e950d — case 2 runs in `fresh_project`, captures `rc2`, and the check requires exit 0, `session=42`, and no ran-verify/ran-demo files
obeyed-check demo-producer rec 9 — implemented: f1e950d — the label grep is gone; the check asserts light count > 0, dark count > 0, a `COLORFGBG='0;15'` count > 0 and zero escapes under NO_COLOR (no literal light≠dark comparison)
obeyed-check demo-producer rec 10 — implemented: f1e950d — requires `would +upgrade scripts/demo-kit.sh`, fails on a `DRIFT` line (the gate's drifted-file state word), and compares the kit's sha before and after the dry-run
obeyed-check demo-producer rec 11 — implemented: f1e950d — runs throwaway demos with `dk_check "x"` 0 / nothing / FAIL, checks each exits 1 with a refusal line, and adds a live `vajra next --check-demo 167` checked for `verdict: READY`
obeyed-check demo-producer rec 12 — implemented: f1e950d — the recorded table has only Rust tests, lint and chitra rows; no `REC_REVIEW` row or variable
obeyed-check demo-producer rec 13 — implemented: f1e950d — HONEST NOTES carry all five: facts from this run re-derived at close, a hand-typed right-value `demo:fact` passes, the S167 gate is never re-run, rule rows use session 99 in throwaway folders, a green demo is not a passing delivery
obeyed-check demo-producer rec 14 — implemented: f1e950d — the small-words table adds gate, fresh project, out of git (past commit), stream mode, dry-run / --sync-fleet, fakest green, legacy / downgrade

## Handoff Delta
- `+` new: first implementation-advisor handoff for this session (6744 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
