# Session 120 — Ground Truth (NO-CODE · audits S116–S119)

**Date:** 2026-08-17  
**Session type:** MANDATORY GT (`120 % 5 == 0`)  
**Scope:** S116 (Plan Advisor role) · S117 (dispatch proof) · S118 (paid dogfood) · S119 (clean-room runner)  
**Produced by:** cold GT agent, no code authored this session

---

## Overall Verdict

**PARTIAL PASS**

| Lens | Verdict | Decisive finding |
|---|---|---|
| Vision alignment | 🟡 PARTIAL | Clean-room runner (S119) not in VISION body; freeze-rule stale in VISION Rules section |
| Roadmap alignment | 🟢 PASS | Entries accurate; S120 row type label is minor stale |
| State/Knowledge consistency | 🟡 PARTIAL | KNOWLEDGE §6 at 642 lines (chronic bloat); STATE S119 PR note is acceptable pre-merge artifact |
| Constitution | 🟢 PASS | All hard rules held S116–S119; one-session-per-chat still convention |
| Cost | 🟢 PASS | Cumulative tracking accurate |
| Dogfood staleness | 🟢 FRESH | S118 was 2 days ago, 1 session; `--dogfood-age` agrees |
| Pipeline advance | 🟡 PARTIAL | 7/8 (Coder ABSENT for S119 — new hollow-step form); counter is live-derived |
| Grep-only-verify sweep | 🔴 SYSTEMIC | Behavioral source greps appear in S119's own verify script; historical pattern is wide |

---

## 1. Vision Audit

**Source:** `VISION.md` (last corrected S100 / 2026-07-24)

| Claim | Status | Evidence |
|---|---|---|
| Autopilot trust layer / leave agent for days | 🟡 PARTIAL | Rung 1 proven (S97 paid); S103 endurance harness with kill-switch; S118 paid dogfood. Rung 2 full-day and Rung 3 multi-repo NOT completed as standalone ladder runs. |
| Enforces discipline at action-time | ✅ IMPLEMENTED | Live-verified S46, S103, S118 (3 permission\_denials on a file-backed gate) |
| Fidelity auditor — independent, attested, chained | ✅ IMPLEMENTED | S55–S59, S86/S88 recompute-and-compare, S115 dispatch proven by name. Three fleet roles (S114/S116/S117) all dispatching by name. |
| Delta-tracking per stage | 🟡 PARTIAL | Full +/~/- triple only at Analyst; other stations record structured evidence, not the triple |
| Cross-agent breadth | 🔴 GAP | 0 code, Claude-only. Correctly documented in VISION. |
| Token savings (bonus) | 🔴 MEASURED ZERO | 0 folds on real CC (S63/S76/S118). Correctly labeled "bonus/hypothesis" in VISION. |
| Clean-room execution (S119) | 🔴 **NOT IN VISION** | S119 shipped a new capability: `git worktree add --detach HEAD` for QA + Demo-er, with a falsifiability fixture. VISION body was not updated. |
| Machinery-freeze rule (Rules section) | 🔴 **STALE** | VISION "Rules" section still says "Under the machinery-freeze rule (S98)…" — but DECISION-005 was SUPERSEDED at S103. The header preamble correctly says retired; the body Rules section does not. Two-paragraph internal contradiction. |

**Summary:** VISION is honest about most gaps. Two actionable stale items: clean-room runner unmentioned, freeze-rule reference in the body not retired.

---

## 2. Roadmap Drift Audit

**Source:** `ROADMAP.md` (header: Updated 2026-08-17, Session 119)

| Entry | Status | Note |
|---|---|---|
| "Where We Are" table — active session | 🟡 STALE-EXPECTED | "S119 PR not yet opened" — PR #129 is MERGED (2026-08-17T14:01:51Z). Accepted pre-merge snapshot pattern per S30 ruling. |
| S120 Active/Upcoming row | 🟡 MINOR STALE | Row says "Candidate (queued, not dropped) \| CODE: the grep-only-verify detector." Status should be "MANDATORY GT" (this session). The row itself notes `120 % 5 == 0 → NO-CODE` — not a confusion risk, but the status label is imprecise. |
| S119 Active/Upcoming row | 🟡 STALE | Status "Next (approved)" but S119 is complete and merged. |
| ROADMAP GT rule 2 | ✅ ACCURATE | "Last = S115…Next = S120." Current session IS S120. |
| Session log rows S116–S119 | ✅ ACCURATE | All four sessions appear in Completed rows with correct verdicts and evidence. |
| Pipeline station table | ✅ ACCURATE | 8/8 stations still listed; counter reference correct. |
| 6-month Autopilot Ladder | 🟡 PARTIAL | "Wk 8: Rung 3 passed once" was a 2026 target. Rung 3 has not run. Launch backstop date 2026-09-15 is ~4 weeks away. No panic — the founder owns the ladder run — but worth noting. |

---

## 3. State / Knowledge Spot-Check

### STATE.md (3 claims verified live)

| Claim | Status |
|---|---|
| "334 lib tests" | ✅ CORRECT — `cargo test --lib` confirms `334 passed` |
| "S118: $4.0911771 authoritative" | ✅ CORRECT — `vajra next --dogfood-age` confirms `$4.0912` |
| "S119 PR not yet opened" | 🟡 STALE-EXPECTED — PR #129 MERGED 2026-08-17; accepted pre-merge snapshot artifact |

### KNOWLEDGE.md (3 claims verified live)

| Claim | Status |
|---|---|
| "Claude CLI: /opt/homebrew/bin/claude" | ✅ CORRECT — file exists |
| "hook-session-guard.sh" (one-session-per-chat) | ✅ CORRECT — `scripts/hook-session-guard.sh` present |
| "7 commands (init/claude/check/next/estimate/hook/meter)" | ✅ CORRECT — `vajra --help` lists exactly these 7 |

### KNOWLEDGE.md line count

**642 lines** — was 475 at S105, 550+ at S115. The §6 "append-only decision log" keeps growing. Header still says "Reloaded every session" (false for §6). Chronic since S60, unfixed through 10 GT sessions.

---

## 4. Constitution Audit

| Rule | Status | Evidence |
|---|---|---|
| Max 7 top-level commands | ✅ HELD | 7 commands, confirmed S116–S119 |
| No autonomous commits | ✅ HELD | All S116–S119 PRs required human approval |
| No `main` commits | ✅ HELD | All on session branches |
| Max 1 story per session | ✅ HELD | Each of S116–S119 was a single story |
| Fidelity ≠ discipline | ✅ HELD | Each CODE session (S116, S117, S119) had a cold fidelity-reviewer pass |
| No self-certification | ✅ HELD | All fidelity passes used subagent cold reads |
| One session per chat | 🟡 CONVENTION | Still advisory + hook-enforced, not Vajra-binary-enforced |
| `verify-closeout.sh` passes before merge | ✅ HELD | All PRs closed with attested Review-Inputs-SHA |
| Fidelity-reviewer dispatch | ✅ HELD | S115 proven by name for role 2; S117 proven for role 3; S116 passed cold review |

**Meta-check:** The constitution is not blocking the vision. All rules that could block (commit gate, review gate, session-per-chat) are either enforced or correctly labeled advisory. No stale rules found that actively harm the workflow.

---

## 5. Cost Audit

| Period | Amount | Source |
|---|---|---|
| S00–S30 | ~$0.46 | Cumulative estimate |
| S36 | ~$61.44 | KNOWLEDGE: fable-5 $3.27 + Opus 4.8 $58.17 (live dogfood) |
| S46 | ~$3.84 | Paid dogfood |
| S51 | ~$1.52 | Paid dogfood |
| S52 | ~$4.95 | Paid dogfood |
| S63 | ~$1.27 | Paid dogfood |
| S76 | UNKNOWN | Opus-estimate ≤ ~$26.6 |
| S78 | ~$0.055 | Paid run |
| S92 | $0.2713 | Authoritative |
| S97 | $1.2758 | Authoritative |
| S102 | $0.4644 | Authoritative |
| S103 | $0.6797 | Authoritative |
| S118 | $4.0912 | Authoritative (confirmed via `--dogfood-age`) |
| **Known total** | **~$80.2** | Excluding S76 unknown |
| **STATE.md "~$83.4"** | matches | ~$3.2 implicit S76 estimate bridges the gap |

**Verdict:** Cost tracking is accurate. STATE.md's cumulative figure is consistent.

---

## 6. Dogfood Staleness

```
=== dogfood age (derived from git — not from STATE.md) ===
  last dogfood session : 118
  date (git-derived)   : 2026-08-15
  cost (authoritative) : $4.0912
  sessions since       : 1 (S118 → current S119)
  calendar days since  : 2 day(s)
```

**Verdict: 🟢 FRESH.** Dogfood is 2 days old (1 session). S118 was a real paid run with authoritative receipt and cold fidelity review. The `--dogfood-age` output agrees with STATE.md. No staleness concern at this GT.

---

## 7. Pipeline-Advance Counter

```
vajra next --stations 119:
  7 of 8 stations passed
  [PASSED] Analyst, Architect, Planner, QA, Demo-er, Releaser, Reviewer
  [ABSENT] Coder — steps 7 not recorded
```

**Finding — new form of Coder-dark:** S119's `## Execution` section has 7 steps, steps 1–6 have valid commit shas (`d11e835`, `8bd1800`, `a607db6`, `3b80265`, `c423c39×2`). Step 7 says:

```
- step 7 — done: cold fidelity-reviewer pass ACCEPT (8/8 SHIPPED); sessions/session-119-review.md
```

This is **prose, not a commit sha**. The Coder gate runs `git cat-file -e <sha>^{commit}` on each `done:` value. Prose fails the git existence check → station reads ABSENT.

S119 IS a code session that shipped commits. The Coder station is dark not because code was absent but because the last execution step records non-commit evidence. This is a **new form of the Coder-dark problem**: the `## Execution` template allows any text after `done:`, and an agent naturally records the fidelity verdict as the final step — which is not a commit sha.

**S116–S119 pipeline shapes:**

| Session | Type | K/8 (derived) | Coder |
|---|---|---|---|
| S116 | CODE (fleet role) | Expected 7/8 | design-significant: no; no `src/` change |
| S117 | CODE (dispatch proof) | Expected 7/8 | design-significant: no; no `src/` change |
| S118 | DOGFOOD (paid) | Low by construction | N/A — dogfood shape |
| S119 | CODE | 7/8 | ABSENT — step 7 prose, not sha |

**Counter reflects reality as it should:** `Outcome::Legacy` handles the no-src-change sessions (S116/S117 correctly marked design-significant: no). S119's Coder ABSENT is an honest gap in the step-recording pattern, not a false-green.

---

## 8. Grep-Only-Verify Sweep

### Classification

Two classes of source grep in verify scripts:

| Class | Description | Risk |
|---|---|---|
| **Structural** | Greps source to check "one source of truth" / code architecture (e.g., `grep -rl "probe_string" src/` to find role text in exactly one file) | Low — tests structure; no better alternative |
| **Behavioral** | Greps source to confirm a feature works by finding its message/flag string in code | **HIGH** — the S118 root cause; the message exists in source but the path may never run |

### S116–S119 detail (audit period)

**S116 (4 src greps counted):**

| Check | Class | Verdict |
|---|---|---|
| `one_source_of_role_text` — greps repo for probe string, asserts 1 hit in `src/fleet/mod.rs` | Structural | 🟡 Valid for its purpose |
| `grep -rqE name: "plan-advisor" src/fleet/mod.rs` | Structural | 🟡 Valid (confirms key in code) |
| `grep -rq "plan-advisor" src/planner/` | Structural | 🟡 Separation-of-concerns check |
| `decision_recorded_and_honoured` — greps docs/decisions/DECISION-007.md for addendum text | Structural/Doc | 🟡 Checks decision record exists |

S116: no behavioral hollow checks. Structural greps are appropriate for a "one-source-of-truth" session.

**S117 (5 src greps counted):**

| Check | Class | Verdict |
|---|---|---|
| Greps `sessions/session-117-artifacts/*.json` for tool-call IDs | Evidence artifact check | ✅ Correct — checks captured evidence |
| `no_src_changes` — greps `git diff --stat main -- src/` | Git diff check | ✅ Correct |
| `first_try_independently_confirmed` — greps `~/.claude/projects/…/*.jsonl` for dispatch count | External evidence check | ✅ Correct (real transcript) |

S117: the "source greps" the sweep flagged are mostly against artifact and transcript files (evidence), not Rust source. S117's verify script is well-constructed.

**S119 (named fakest-green + 3 additional hollow checks):**

| Check | Class | Verdict |
|---|---|---|
| `constraints_has_clean_room_keys` — greps `.ai/CONSTRAINTS.yaml` | Config file check | 🟡 Acceptable (checks config exists) |
| `init_scaffold_has_clean_room` — greps `src/cli/init.rs` for template text | **Behavioral** 🔴 | Hollow: should `vajra init` into a temp dir and check the scaffolded file |
| `skip_env_var_referenced` — greps `src/qa/mod.rs` + `src/demoer/mod.rs` for env var name | **Behavioral** 🔴 | Hollow: proves the string exists in code, not that the escape path works |
| `run_location_printed` — greps source for "running in clean room" message | **Behavioral** 🔴 | **The named fakest green** (S119's own fakest-green disclosure) |

**S119 has 3 behavioral source greps in its own verify suite — the exact pattern it was built to defend against.**

### Historical worst-offenders (all-time, by src_greps count)

| Script | src_greps | exec_checks | Risk |
|---|---|---|---|
| S114 | 11 | 5 | Mix of structural + behavioral; fleet role |
| S34 | 10 | 1 | Heavy behavioral — brownfield session config checks |
| S47 | 10 | 4 | Co-pilot loader |
| S73 | 9 | 11 | Good ratio but still present |
| S29 | 7 | 6 | Mix |
| S32 | 7 | 2 | Mix |
| S38 | 7 | 4 | Mix |
| S57 | 6 | 1 | Fleet scaffolding checks |

**Legacy scripts (S19, S21): 5 src, 0 exec** — entirely source-grep-based. Pre-date the execute-based pattern.

### Finding

The hollow behavioral-source-grep pattern is not isolated to S118's verify-session-11.sh. It appears in the session-specific verify scripts whenever a session ships a new behavior and the verify script checks "the message/flag is in the source" rather than "the code runs and produces the output." The structural source greps (checking one-source-of-truth) are a different and valid class.

---

## 9. Options for S121

**A — Build the grep-only-verify detector** *(highest impact on the root cause)*

- **Goal:** A check in `verify-closeout.sh` or a standalone script that classifies each check in a session's verify script as "behavioral source grep" vs "execute-based," and WARNS (or blocks) when the ratio is too hollow.
- **Why pick this:** S118 named it; S119 reproduced the exact pattern in its own verify suite; 8 sessions since S118 have not fixed it. The detector is the only way to make the pattern self-catching.
- **Key risk:** Hard to define "behavioral source grep" precisely enough to avoid false positives on the structural class. Likely an advisory tool first (exit 1 only on a very obvious pattern like `grep "message" src/`).

**B — Fix the VISION.md stale text and Coder-dark step-7 pattern** *(medium impact, low risk)*

- **Goal:** (1) Remove the machinery-freeze-rule paragraph from VISION "Rules" section (it was retired S103). (2) Add a note about the clean-room runner to VISION. (3) Document that the `## Execution` step format must end with a commit sha (not prose) — or explicitly mark the fidelity step as "non-commit evidence" so the Coder gate handles it.
- **Why pick this:** Two VISION stale items will keep showing up in every GT until fixed. The Coder-dark step-7 pattern will recur in every CODE session that records the fidelity review as the final step.
- **Key risk:** Docs-only; VISION changes must not soften claims (S118 founder directive).

**C — Paid Rung-2 dogfood with clean-room enabled** *(highest product-signal value)*

- **Goal:** A real unattended `vajra claude` run on chitra with `verify.clean_room.enabled: true` (S119 feature enabled for the first time). Generates Rung-2 evidence and exercises the clean-room runner under real conditions.
- **Why pick this:** Dogfood is currently fresh (2 days), but the clean-room feature has NEVER run in a paid session. The Autopilot Ladder backstop (2026-09-15 = ~4 weeks away) makes a paid run increasingly urgent.
- **Key risk:** Costs real $ (~$4–5 budget); the founder must prepare chitra's working tree and enable `clean_room: true` in its CONSTRAINTS.yaml. Cannot start until the founder gives the go-ahead in chat.
