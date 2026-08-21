---
role: demo-producer
session: 126
agent: claude-code-subagent
source-sha: e4802cbf55835afbcf7b1d06621a2ea6cd249feb6ef8d68abb802738378b2762
captured: 2026-08-21T11:26:21Z
cost_usd: null
---

# Demo-producer handoff — session 126

# Demo brief — Session 126: the last five fleet roles (`scripts/demo-session-126.sh`)

## What actually shipped this session (ground truth, from the diff)

Five roles registered in `src/fleet/mod.rs::ROLES`, taking the roster from 4 to 9: `requirements-analyst`, `design-advisor`, `implementation-advisor`, `demo-producer`, `release-coordinator`. Every one read-only (`Read, Grep, Glob`); the execution allowlist did NOT grow (still exactly one — `qa-specialist`). Each key deliberately avoids shadowing a K-of-8 station word (analyst/architect/coder/demoer/releaser). Commit 4 also unpinned a roster-SIZE assertion in `scripts/verify-session-121.sh` (`[ "$N" = "4" ]` → `[ "$N" -ge 4 ]`) so a ninth role is not scored as a defect.

The proposal below is what the demo must SHOW. The QA gate re-runs this script live and scans its output for the four `[demo:...]` tags. I am proposing content, not writing the script — the author records it in `scripts/demo-session-126.sh`.

---

## `demo:header`

One line, naming the session and what it delivered:

> **Session 126 Demo — the fleet is COMPLETE: the last five roles land, taking the roster from four to nine, and not one of them can execute.**

Sub-line the author should keep: the whole governance claim of this session is *five roles added, zero new grants of Bash* — the roster grew, the execution allowlist did not.

---

## `demo:cases` — ordered, each runs the REAL binary against a throwaway `vajra init` repo

Follow the S121/S123 house pattern: `mktemp -d`, `git init`, `"$VAJRA" init`, then score each case with the real exit code (`score $?`). Every case below can FAIL — none is wrapped to ignore its exit code, none asserts something already true before the session.

1. **A fresh `vajra init` scaffolds NINE agent files, all rendered from the one source in `src/fleet/mod.rs`.**
   `ls -1 "$TMP/.claude/agents/"`, count `*.md`, assert `= 9`. Proves the five new roles reach a real user through the real scaffolder, not just the source table. (Fails if any new role was registered but not rendered.)

2. **All five NEW role files are present by name.**
   Assert each of `requirements-analyst.md design-advisor.md implementation-advisor.md demo-producer.md release-coordinator.md` exists in the scaffolded dir. (Fails if a role is missing or misnamed.)

3. **Exactly ONE of the nine roles was granted Bash — the execution allowlist did not grow with the roster.**
   `grep -lE '^tools:.*Bash' "$TMP/.claude/agents/"*.md | wc -l`, assert `= 1`, and print which file it is (`qa-specialist.md`). This is the session's central governance claim, shown running. (Fails the instant any new role carried an execute/write grant.)

4. **Every new role carries its OWN contract text, not a stub and not a cross-wired copy.**
   For each new role, grep its file for a phrase unique to its contract and assert present — e.g. `requirements-analyst` → `Never propose \`Status: APPROVED\``; `design-advisor` → `an invented id is worse than an honest`; `implementation-advisor` → `never suggest recording a step as done before its commit exists`; `demo-producer` → `A demo that prints claims is theatre`; `release-coordinator` → `never report ancestry, sync, or branch state as if you had observed it`. (Fails on an emptied, stubbed, or cross-wired prompt — the exact tautology S122 killed.)

5. **The writer FAILS CLOSED on each new role's station word.**
   Run `"$VAJRA" next --role <word> --from qa.md` for each shadowed station word — `analyst`, `architect`, `coder`, `demoer`, `demo`, `releaser`, `release` — and assert every one exits non-zero (unknown role). Then show one VALID new role key accepted. This proves the keys resolve as roles while the station words do not — the collision resolution, shown running. (Fails if any station word silently resolves.)

6. **A real findings brief from a new role becomes a governed, delta-tracked handoff.**
   Pick one new role (e.g. `requirements-analyst`), `"$VAJRA" next --role requirements-analyst --from <brief>`, then assert the handoff at `.ai/handoffs/session-126-requirements-analyst.md` exists, carries `role: requirements-analyst`, and a `^source-sha: [0-9a-f]{64}$`. `sed -n '1,8p'` it to screen so the reader sees the real artifact. (Fails if the new role does not actually flow through the governed-handoff path.)

7. **No new top-level command — five roles ride `init` and `next`.**
   `"$VAJRA" --help` and assert the verb list is unchanged (`vajra <init|claude|check|next|estimate|hook|meter>`). (Fails if the roster grew a command.)

---

## `demo:summary_table`

Match the S121 scorecard shape: a `CASE` / `RESULT` table, one row per case above, ending in `X of N cases passed`. Rows must be driven by the SAME variables the cases scored (`$N`, `$NEXEC`, the reject counter), not hardcoded `PASS` strings, so the table cannot go green while a case went red.

| CASE | RESULT |
|---|---|
| 1. init scaffolds nine roles | from `$N = 9` |
| 2. all five new role files present | from the by-name check |
| 3. exactly one role may execute | from `$NEXEC = 1` |
| 4. each new role carries its own contract | from the phrase greps |
| 5. writer rejects every station word | from the reject counter |
| 6. governed handoff with a real source hash | from case 6 |
| 7. no new top-level command | from case 7 |

---

## `demo:before_after`

Two honest contrasts. The before state is real and recoverable, not narrated:

- **The roster.** BEFORE (S123 close): four roles — `researcher`, `fidelity-reviewer`, `plan-advisor`, `qa-specialist`. AFTER (this session): nine, the five new ones added. Show it by listing each scaffolded agent file with its `tools:` line and an arrow on the one Bash role (the S121 format), so the eye sees five new rows appear and the arrow stay on exactly one. The honest before for the five new roles is *they did not exist at all* — do not show only the after nine; show the four-vs-nine delta.

- **The roster-SIZE assertion (commit 4).** BEFORE: `scripts/verify-session-121.sh` pinned `[ "$N" = "4" ]` — a hard four, which would score a ninth role as a defect. AFTER: `[ "$N" -ge 4 ]` — a non-vacuity floor that a role addition cannot break. Show this by running the current `verify-session-121.sh` scaffold check (or the relevant function) against a nine-role `init` and showing it PASS where the old pinned form would have failed. This is the one change that is otherwise invisible in a roster demo — without it the before/after only shows the after.

---

## What this demo does NOT show (state it plainly in the script's closing `dim` block)

- **Nothing dispatched any of the five new roles.** This shows the roles are registered, scaffolded, contract-bearing, and flow through the governed-handoff writer. It does NOT show an agent actually doing analysis, design, implementation-advising, demo-producing, or release-coordinating. That is a live Claude Code dispatch, not a bash script — the same S111 limit every fleet demo since S109 has disclosed.
- **The contract greps are behavioral, not proof of behavior.** Case 4 asserts the contract TEXT is present in the scaffold; it cannot show the dispatched agent obeys it. Finding the string is not the feature working — this is the demo's disclosed fakest green.
- **The read-only grant is enforced by the render, and the harness enforcement of `tools:` was measured live only at S123**, not re-measured here. This demo shows the grants are *what they should be*; it does not re-prove the harness mechanically fences them.
- **A green demo is not a passing delivery.** The fidelity verdict lives in `sessions/session-126-review.md`, not here.

---

## Files read (all absolute)

- `/Users/suman/playground/vajra/src/fleet/mod.rs` — the five new roles, the roster (`ROLES`, now 9), the per-role read-only grants, the collision-key tests, the `ROLES.len() == 9` and single-Bash assertions.
- `/Users/suman/playground/vajra/scripts/demo-session-121.sh` and `/Users/suman/playground/vajra/scripts/demo-session-123.sh` — the house demo format (four `[demo:...]` tags, throwaway `vajra init` repo, `score $?` pattern, scorecard, honest closing disclosures).
- `/Users/suman/playground/vajra/scripts/verify-session-121.sh` (lines 321-365) — the roster-SIZE line commit 4 unpinned (`[ "$N" = "4" ]` → `[ "$N" -ge 4 ]`), load-bearing for the second before/after.

Handoff note for the orchestrator: record this via `vajra next --role demo-producer --from <file>`; I have not written the handoff frontmatter — Vajra owns the source hash, timestamp, and delta.

## Handoff Delta
- `+` new: first demo-producer handoff for this session (8607 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
