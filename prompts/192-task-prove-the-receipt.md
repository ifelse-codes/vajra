# Session 192 — INTERACTIVE: prove the receipt live, through rudra

> **Status:** DRAFT — written from the founder's S191 pick (2026-10-08: "yes prove the receipt plus rudra next … run
> rudra next and see the amount is the correct or at least the new one"; "fold it to option A" for the
> transcript-folder fix). He approves it with `vajra approve 192` in his own terminal.

## Type
session_type: CODE
- **CODE, interactive.** The founder runs rudra; we check what the receipt said and fix what it shows. Max 2
  assumptions · 2 retries · ~2h · 1 story (the receipt, live) · ≤3 files per commit · new chat.

## Goal
S189 made an interactive `vajra claude` receipt's top line Claude Code's own figure (the transcript's `cost-state`
line, this run's share) — proven only on recorded lines and a stand-in. S192 proves it on a REAL run: the founder's
next rudra session, through a vajra built from S191 or later. Where the real run disagrees with the stand-in, fix
it. Also fix the one receipt bug S190 picked and S191's prompt missed: `find_session_jsonl`'s folder naming.

## Deliverables
1. **Before the rudra run:** a vajra built from this repo's main (S191+) is what `vajra` runs in rudra
   (`cargo install --path .` — the founder's step), and rudra is synced (`vajra init --sync-fleet`, so it also gets
   S191's session guard). Record the version both report.
2. **The live check (founder's rudra session):** after it ends, compare the receipt's top line with Claude Code's
   own `cost-state` total in that run's transcript (and `~/.claude.json` `lastCost` as a cross-check). Record:
   the receipt's line, the transcript's last total, the share it computed, and whether they match. "At least the
   new one" is the floor: the top line must be the S189 shape (Claude Code's figure, or "no cost from Claude Code
   for this run"), never the old `~$… estimated` guess.
3. **`/clear`, `--continue` and a fork:** one tiny run of each through `vajra claude` (cheapest model, a throwaway
   folder, the founder's yes first — a few cents), each receipt recorded against Claude Code's own total. Settle
   S189's named assumption: does a fork keep Claude Code's `startTime`?
4. **`find_session_jsonl`'s folder name** (`src/meter/mod.rs:879`, S189 researcher rec 6, S190 pick, folded in by
   the founder): name the transcript folder the way Claude Code does (every character that is not a letter or
   digit replaced, not only `/`), and honour `CLAUDE_CONFIG_DIR`. Today a project path with `.`, `_` or a space
   gets no receipt.
5. **Whatever the live runs show is wrong, fixed** — or, if it needs design, named with the founder's call. The
   SessionStart session-id gap (S189 researcher rec 2: `/clear` and two sessions in one folder skip the receipt)
   is named or designed here, not silently carried.

## Acceptance
| AC | Check |
|---|---|
| AC1 | The rudra receipt's top line is the S189 shape; its figure equals this run's share of the transcript's `cost-state` total (or the receipt says why it has none) — the numbers recorded in the summary. |
| AC2 | `/clear`, `--continue` and a fork each recorded: receipt line vs Claude Code's total; the fork `startTime` question answered with evidence. |
| AC3 | A project path containing `.`, `_` and a space finds its transcript and gets a receipt; `CLAUDE_CONFIG_DIR` is honoured — each red at the start commit for that reason. |
| AC4 | Every gap the live runs found is fixed with a check red at the start commit, or recorded with the founder's call. |
| AC5 | `bash scripts/verify-session-192.sh` green; `cargo test` passes in full. |

## Design
design-significant: yes
- Cites `docs/adr/0004-meter-receipt-design.md` — its S189 addendum (the resolver order, the fail-closed rules,
  the named fork assumption). AC3 changes how the meter finds a transcript; any SessionStart-hook design needs an
  ADR-0003 addendum (S189 researcher rec 2) and the founder's yes first.
- **Deviates from ADR-0004 §2.2** (recorded in its S192 addendum): `derive_cwd_slug` (replace only `/`) and the
  newest-anywhere fallback are replaced by Claude Code 2.1.280's own rule — every UTF-16 unit outside
  `[A-Za-z0-9]` → `-`, over 200 cut + hashed, under `$CLAUDE_CONFIG_DIR/projects` else `$HOME/.claude/projects`.
  One helper in `src/meter/mod.rs` serves the meter, `vajra meter --all` and dispatch's provenance lookup; only
  dispatch keeps `VAJRA_CLAUDE_PROJECTS_DIR`. The S189 share rule is unchanged. Rejected: three separate edits; a
  prefix match on long names; the newest-anywhere fallback; the meter reading `VAJRA_CLAUDE_PROJECTS_DIR`; a
  SessionStart hook this session (named, not closed).

## Carried in
- **Founder rulings:** read the tool's own cost, never grow the price list (S176/S189); no per-claim `obeyed:`
  judge — one release-coordinator judges all (2026-10-03); the close does not run `cargo test` separately
  (2026-10-04); no new policing of Vajra's own paperwork (2026-09-15).
- **From S191:** existing projects get S191's session guard only via `--sync-fleet` with a vajra built from S191+
  (Deliverable 1 does that for rudra). The write-guard limits in DECISION-011 S191 addendum §1 stay named.
- **Kept in backlog (not this session):** the rest of N7; F97's opt-out key; `tests/gt_cadence_shared.rs`'s loose
  assertion; S188's named gaps (accepted risk); N10 (`scaffold-drift.sh` false positive); N11.
- **Parked:** non-Claude tools (F91/F94/F95); release (`cargo publish` is the founder's call).

## Guardrails
- No paid run without the founder's yes; cheapest model; throwaway folder for `/clear`/`--continue`/fork.
- No transcript or run capture committed — the summary records the numbers (founder rule, S126).
- A receipt that cannot be sure says so; never a wrong number with a "this run" label.

## Plan
1. Deliverable 4 (folder naming + `CLAUDE_CONFIG_DIR`), with tests red at the start commit. — covers: 3
2. The founder installs the new vajra and syncs rudra; he runs his rudra session; we read the receipt against the
   transcript. — covers: 1
3. The `/clear`, `--continue` and fork runs (founder's yes first); record each. — covers: 2
4. Fix what the live runs show, or record the founder's call. — covers: 4
5. `scripts/verify-session-192.sh` (each fix red at the start commit) and the demo; the full `cargo test`.
   — covers: 1, 2, 3, 4, 5
6. Summary with 3 next options; closeout sync; next prompt; one cold review; the `--inputs-sha 192` stamp last.
   — covers: 1, 2, 3, 4, 5

## Delta
- `~` `find_session_jsonl` (Claude Code's folder naming; `CLAUDE_CONFIG_DIR`)
- `+` the live receipt evidence (summary numbers, no captures committed)
- `~` whatever the live runs show is wrong in `src/meter/` (ADR-0004 S189 addendum updated if the resolver changes)

## Execution
- step 1 — done: 348c938
- step 2 — done: eeddc24
- step 3 — done: 3fbe5e0
- step 4 — done: e9cc912
- step 5 — done: 9d872b8
- step 6 — done: eeddc24

## Advice
Roles dispatched: `tech-lead` (mandatory, first), `design-advisor` (required; design-significant: yes),
`fidelity-reviewer` (required; the one cold close review), `release-coordinator` (required; the one judge of every
`obeyed:` answer).
researcher: skipped — the tech-lead deferred it on budget: the open facts were checkable on this machine (the folders in ~/.claude/projects, Claude Code's own code, the tiny runs' logs) and S189 rec 6 had done the research; ~0.4M would take the ~2.6M crew to ~3.0M on a day the account already paid ~$29.86 for two rudra runs.
requirements-analyst: skipped — the tech-lead deferred it on budget: the 5 deliverables and AC1–AC5 restate the founder's S191 pick and AC1 was already evidenced; ~0.3M would buy only a restatement.
plan-advisor: skipped — the tech-lead deferred it on budget: the Plan already covers every AC with `covers: N`, and its rec 1 gave the one order that mattered (~0.3M more).
implementation-advisor: skipped — the tech-lead deferred it on budget: one naming rule plus an env var in the meter; its recs 2–4 named the traps (three copies, env vars in tests, the long path); ~0.6M takes the crew to ~3.2M.
qa-specialist: skipped — the tech-lead deferred it on budget: AC3/AC4 already make verify-192 run each fix red at the start commit, and the fidelity-reviewer re-runs it (~0.6M saved).
demo-producer: skipped — the tech-lead deferred it on budget: the only on-screen change is the receipt's top line, which the founder read live five times (~0.3M saved).

**tech-lead** (`.ai/handoffs/session-192-tech-lead.md`):
- tech-lead rec 1 — obeyed: 348c938 (Deliverable 4 built first, $0); the founder's yes asked before any paid run and given by his running the scripts; Deliverable 5 last (e9cc912, 3fbe5e0)
- tech-lead rec 2 — obeyed: 348c938 (one shared function in src/meter/mod.rs; the meter and `vajra meter --all`) and e9cc912 (dispatch's `project_dir_for`); dispatch kept in scope, not named
- tech-lead rec 3 — obeyed: 9c9d96d (the rule checked against every real folder on this machine: 12 of 12, old rule 9) and 348c938 (the long-name rule read from Claude Code 2.1.280's own code; a wrong hash can only miss a folder → no receipt, never another project's)
- tech-lead rec 4 — obeyed: 348c938 (`cc_project_dir` takes the environment as a reader argument; no test sets an env var) and e9cc912 (order: `VAJRA_CLAUDE_PROJECTS_DIR` in dispatch only, then `$CLAUDE_CONFIG_DIR/projects`, then `~/.claude/projects`)
- tech-lead rec 5 — obeyed: 348c938 (`s192_a_resume_that_sent_nothing_never_shows_the_earlier_total_as_this_run`: the live resume shape gives no figure, never $22.96; the S189 rule was already right)
- tech-lead rec 6 — obeyed: 3fbe5e0 (ADR-0004 S192 addendum names the `/clear` gap as proven live, not closed; no hook, no ADR-0003 addendum) and eeddc24 (the summary records that the founder's call was asked and not yet given)
- tech-lead rec 7 — obeyed: 9c9d96d (design-advisor before the dispatch change and the addendum), then the build, one fidelity-reviewer, one release-coordinator after this section; the skip lines above carry the budget reasons

**design-advisor** (`.ai/handoffs/session-192-design-advisor.md`):
- design-advisor rec 1 — obeyed: 348c938 and e9cc912 (one helper in src/meter/mod.rs serves all three callers). refused in part: the four-function shape — one `cc_project_dir(path, env)` takes the environment as a reader, which keeps it testable without env vars AND covers `CLAUDE_CODE_PROJECT_DIR_NAME`, the third variable Claude Code reads; it returns `Option`, with no `TooLong` error, because long names are named, not refused (rec 4). Commit 1 also carried src/cli/meter.rs and verify-192 (3 files)
- design-advisor rec 2 — obeyed: e9cc912 (the meter never reads `VAJRA_CLAUDE_PROJECTS_DIR`; dispatch reads it first, then `CLAUDE_CONFIG_DIR`, then HOME). The empty value: Claude Code's `??` would keep "" (a relative folder); Vajra counts it as unset — named in the ADR-0004 S192 addendum (9c9d96d)
- design-advisor rec 3 — obeyed: 348c938 (per UTF-16 unit via `u8::try_from`; Claude Code's regex has no `u` flag, read from its code; `é` → `-`, emoji → `--` tested; no canonicalize)
- design-advisor rec 4 — refused: the rec guessed the long-name hash comes from the runtime. Claude Code 2.1.280's own code shows it is `AQ`, a plain JS function (`(r<<5)-r+charCodeAt|0`); `Bun.hash` is a different function (`_se`). It is copied and checked against Claude Code's own function under node (348c938), with the 200/201 boundary (91e992c). A wrong hash can only miss a folder (no receipt), never find a sibling project's, so it meets the rec's own safety reason; no prefix match, no newest-anywhere fallback
- design-advisor rec 5 — obeyed: 9c9d96d (the conformance run on this machine — 12 folders with a `cwd` field, 12 match, the old rule 9 — recorded in the ADR-0004 S192 addendum and the summary; no transcript committed) and 348c938 (pairs incl. `.`, `_`, space, `/private/tmp`); the `.claude` case is covered by the conformance run (`-Users-suman--claude-projects-…`), not a unit pair
- design-advisor rec 6 — obeyed: 348c938 ((a) a resume with messages and no new spend → `ThisRun{0.0}`; (b) only cost-state lines after launch → `None`; (c) new spend → `ThisRun{1.5}`) and 3fbe5e0 ((d) the live fork shape → `IncludesEarlierSpend`). (a) checks the record, not the rendered "$0.00" line
- design-advisor rec 7 — obeyed: 3fbe5e0 (named, not closed; the live `/clear` run printed "multiple sessions detected"; no ADR-0003 addendum, no hook)
- design-advisor rec 8 — obeyed: 9c9d96d and 3fbe5e0 (ADR-0004 S192 addendum: (i) deviates from §2.2; (ii) the long-name rule — copied, per rec 4's answer; (iii) `VAJRA_CLAUDE_PROJECTS_DIR` is dispatch's only; (iv) the shared-folder limit; (v) the live fork, `--continue` and `/clear` results, replacing S189's "assumed, not verified")
