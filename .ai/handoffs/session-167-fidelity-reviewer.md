---
role: fidelity-reviewer
session: 167
agent: claude-code-subagent (verified: toolu_01A2bxSsaKACh66rdKkXCjPz)
source-sha: 4969d29e960c3f5976ae7d6b44273f27f1b48c4c5e3925c13e9a909201ba0fda
captured: 2026-09-14T11:09:08Z
cost_usd: null
---

# Fidelity-reviewer handoff — session 167

**Verdict:** ACCEPT

**Brief:** Cold, adversarial fidelity review of S167 (prompt + branch diff vs fab1b79; re-judged after a7ed117). 10 of 11 SHIPPED · 0 PARTIAL · 1 NOT-BUILT (AC10 — the release; its own wording permits NOT-BUILT with a stated reason, and the Guardrails put the review before merge and the release after).

| AC | Grade | Evidence |
|----|-------|----------|
| AC1 | SHIPPED | init.rs:1132 scaffolds the kit stamped; init.rs:3668-3733 runs it through bash (100/72, box scan, NO_COLOR, no-UTF-8); ci.yml runs cargo test on ubuntu + macos; verify:54-79 |
| AC2 | SHIPPED (as worded) | template:44-83 dk_todo per section; demo-kit.sh:258-274 dk_finish; init.rs:3738-3787; verify:85-97 — thin fill still passes |
| AC3 | SHIPPED | init.rs:1221, 1350-1354; AGENTS.md:68; CONSTRAINTS.yaml:56-61; fleet/mod.rs:335-338, :567; demoer/mod.rs:15-18; verify:104-116 |
| AC4 | SHIPPED | init.rs:35-36, 242-265, 326-332, 3823-3906, 3912-3971; verify:123-141 |
| AC5 | SHIPPED | verify:147-155 (HEAD/status/stash); chitra inline hash init.rs:249; AC5a greps only the path |
| AC6 | SHIPPED | demo-167:72,74,84-85 real before; verify:167-201 python pty keys; --check-demo verify:166; Demo-er diff guard verify:202-205 |
| AC7 | SHIPPED | DECISION-009:29-36, :94-100, :7/:100 |
| AC8 | SHIPPED (claimed) | Cargo.toml:39; verify:225-231; 487 + 6 = 493 |
| AC9 | SHIPPED | every check runs the binary, scripts, cargo, git or a pty; FALSIFIABILITY per block |
| AC10 | NOT-BUILT | Execution step 10 pending; still 0.1.0 |
| AC11 | SHIPPED | summary lines 48-53 |

Fakest green: dk_check (demo-kit.sh:214) accepts the literal token PASS, so `dk_check "anything" PASS` satisfies dk_finish's "a live check ran" rule (demo-kit.sh:269); verify:91 and init.rs:3760 fill the outline with exactly that line. Delete every placeholder, add one typed PASS, and an empty deck exits 0 with all four markers. Thin fill is disclosed; that the live-check rule is met by a typed word is not.

Recommendations:
1. rec 1 — In S168, make dk_check run a command and record its real exit code (no bare PASS token), and have the Demo-er gate require dk_finish's "demo complete" line.
2. rec 2 — Tighten verify AC5a to match chitra's real states ("would upgrade" for the template, "would create" for the kit), not just the paths.
3. rec 3 — Re-point the tech-lead rec 2 disposition to the commit that actually landed the release-coordinator handoff, and either add a check that the ship checks read this branch or refuse that half in writing. (Addressed by a7ed117 — recorded evidence, acceptable.)
4. rec 4 — Carry AC10 into the S167-release row with the exact checks: install-smoke for release, crates and brew, plus a published-crate `vajra init` that scaffolds scripts/demo-kit.sh.

## Independent obeyed-check judgments
obeyed-check tech-lead rec 1 — implemented: d6806f5 — the design-advisor handoff decides the open question against DECISION-007/008 and SYNC_HOOKS stamping, and its advice lands in DECISION-009
obeyed-check tech-lead rec 2 — implemented: 17c96e9 — lands the release-coordinator handoff before step 10; .git/refs has only session-167-rich-terminal-demo, no session-167-adhoc-fixes ref, so the old merged branch cannot satisfy the ship checks
obeyed-check tech-lead rec 3 — implemented: cb6de81 — this dispatch received the prompt, the diff file list and verify-session-167.sh as of that commit, with AC2/AC6/AC10 named as the focus
obeyed-check tech-lead rec 4 — implemented: 9c363bc — that commit adds the summary, and summary line 52 states the demo-producer brief was never run
obeyed-check design-advisor rec 1 — implemented: d6806f5 — prompt Design line 92 records design-significant: yes with the interface-change reasons
obeyed-check design-advisor rec 2 — implemented: d6806f5 — docs/decisions/DECISION-009-terminal-demo.md exists as a new record
obeyed-check design-advisor rec 3 — implemented: d6806f5 — DECISION-009:6 and prompt lines 95-98 cite only S136/S141/S142/S143
obeyed-check design-advisor rec 4 — implemented: d6806f5 — DECISION-009 Decision points 1-5 carry each condensed design bullet
obeyed-check design-advisor rec 5 — implemented: 8c6ccea — frozen hash list for the template only (init.rs:242-265, 326-332), derivation recorded (DECISION-009:76-87), test re-derives source 1 from git (init.rs:3912-3971); source-2 not re-derived, disclosed
obeyed-check design-advisor rec 6 — implemented: 8c6ccea — DECISION-009:69-70 states the departure from "smooth going forward, never retroactively" and why
obeyed-check design-advisor rec 7 — implemented: d6806f5 — DECISION-009:94-100 lists all three rejected alternatives with reasons

## Handoff Delta
- `+` new: first fidelity-reviewer handoff for this session (4711 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
