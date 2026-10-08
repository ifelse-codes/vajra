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
