# Vajra — Current State Snapshot

**Snapshot, not log.** Overwritten in full at every closeout.

## Active Branch
**None — between sessions (S168 complete, S169 not yet started).**

## What was done this session (S168 — CODE: a demo that cannot be faked)

- `dk_check [-q] "label" <command…>` runs the command; its real exit code decides. A bare `PASS` / `FAIL` / digit / no command is refused by name and fails the demo (the S167 fakest green, closed).
- `vajra next --demo-facts NN` — nine derived facts (session · stations passed/total/names · review · recs answered/total · crew handoffs/roles), one `key=value` per line, read-only (a test proves it runs no script).
- `dk_vajra_tiles NN` / `dk_vajra_scorecard NN` draw those facts ("filled in by Vajra") and print `demo:fact` lines; `dk_finish` prints `demo:complete` only when the outline passed; light theme (`DEMO_THEME=light` / light `COLORFGBG`).
- The Demo-er gate: a kit-built demo (sources the kit, or its output contains any kit marker — substring scan) must print `demo:complete` and every fact, each equal to what the gate derives right after the run, from the run folder, with `VAJRA_BIN` = the gate's own binary. Non-kit demos keep the old rule, warned (DECISION-010, overturns DECISION-009 §4).
- `complete` joins `demo.required_elements` here and in the `vajra init` scaffold. Template, `demo-session-167.sh`, `verify-session-167.sh` and the `demo-producer` brief migrated.
- Crew: tech-lead · design-advisor · demo-producer (14 recs, all obeyed) · fidelity-reviewer (two cold passes; the first found the indented-`demo:complete` dodge, fixed in-session). 508 lib tests; `demo-session-168.sh` 16/16 live checks.

## What Currently Works

- A demo that cannot be faked: command-backed checks, Vajra-filled numbers, gate re-derives facts at close (S168).
- Terminal demo deck for every Vajra project: `scripts/demo-kit.sh` + the seven-section template; empty outlines fail by name (S167).
- `vajra init --sync-fleet` upgrades fleet roles + hooks + constitution + close gate + demo template + demo kit; S167-stamped kit/template upgrade as StaleRender (S168 test).
- 10-role fleet, THREE mandatory (`fidelity-reviewer`, `design-advisor`, `tech-lead`); crew binding proven in the wild (S144).
- 8 stations + closeout gate (17+ checks); enforcement floor; tamper-evident ledger; receipts (authoritative on headless stream-json).
- Coder station passes with real `done:` shas; Demo-er live re-run; Releaser + release-coordinator gate at close (S154–S164).
- Test-runner compression for cargo/pytest/npm/jest (S148); `cargo fmt --check` a closeout check (S151).

## What Is Broken / Weak / Disclosed

- **🟡 Release not done** — vajractl still 0.1.0; S167 + S168 ship together as 0.2.0 after this merge, on the founder's go (ROADMAP `S168-release`). Nobody outside this repo has the demo work until then.
- **🟡 S168 fakest green:** `dk_check "x" true` still passes (a real command is not a meaningful one); a hand-typed `demo:fact` with the RIGHT value passes; extra hand-drawn tiles are not checked.
- **🟡 `vajra next --advance` into S168 used `VAJRA_SKIP_CODER_GATE=1`** — S167's plan step 10 (the release) was still pending. S168's step 11 is the same pending release; the next advance will meet it again unless the release lands first.
- **🟡 Existing projects:** a non-kit demo stays on the old four-marker rule until the project adds `complete` to `CONSTRAINTS.yaml#demo.required_elements` (sync never touches that file). Old kit demos using `dk_check "x" 0` turn red, by design.
- **🟡 `--demo-facts` costs ~10 s** on a session with an attested review (Reviewer station re-derives the hash).
- **🟡 S166 close was self-certified** — retroactive review REJECT; close-gate tightening → **S169**. `.ai/SESSION` was moved 166 → 167 by hand (founder) — S166/S167 never passed `verify-closeout.sh`.
- **🟡 Not tested:** Windows (WSL untested); a real light-background terminal (escape codes proven, not eyeballed); Linux only via CI Rust tests.
- **🟡 Old S71 scripts disagree with the template by design**; nothing re-runs them.
- **🟡 prove-then-cut-cost arc unstarted**; **Autopilot Ladder Rung 2/3** never completed; **zero external users**.
- **🟡 Backlog carry-forwards** — D2 inner-session gap + waiver path (S161) · crew advice impact F13 · S154-QA 1–3 · S156-FR r1/r2 · S157-FR r2 · S159-FR r1 · S161-FR 2–4 · S164-QA r1 · verify-158 source grep · no gate against new hollow verify checks · Releaser NoBranch blind spot · init.rs hand-typed scaffold scope · waiver BLOCK paths untested.

## What Is In Progress

- Nothing. S168 complete; the 0.2.0 release waits for the merge + founder go.

## Active PRs

- S168 PR — `session-168-demo-final` → main.

## Cost Tracking

| Session | Cost (authoritative) | Notes |
|---------|----------------------|-------|
| S168 | $0 | No paid run; code + scripts + fleet subagents only |
| S167 | $0 | No paid run; code + scripts + fleet subagents only |
| S166 | $0 | No paid run; bash scripting + verify + demo scripts only |
| S165 | $0 | No paid run; GT audits only |
| S161 (Part 2 — D2 dogfood) | null | `total_cost_usd` not in JSONL; token estimate ~$14.15 (not authoritative) |

## Direction (governance is the product)

- **Product = provable agent governance** (`DECISION-001`). Direction: **MAKE THE FLEET REAL.**
- **Founder priorities (S140/S160):** (1) fresh-user experience + release; (2) prove it works, then cut cost; (3) self-driving unattended close / Rung 2–3; (4) external adoption.
