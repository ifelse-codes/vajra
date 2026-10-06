# Session 189 — F67 for good: the receipt reads Claude Code's own cost for interactive runs

> **Status:** DRAFT — written at the end of S188 from the founder's pick (2026-10-05: "F67 receipt cost").
> He approves it with `vajra approve 189` in his own terminal; the gate reads the approval record, not this line.

## Type
session_type: CODE
- **CODE.** Max 2 assumptions · 2 retries · ~2h · 1 story · new chat.
- The one story: **the cost line on every `vajra claude` receipt is Claude Code's own figure, or says plainly
  that none is known — never a guess from a price list.**

## Goal
F67 (S176, parked three times by the founder, who asked for the permanent fix, not new price rows): an
interactive `vajra claude` run has no result stream, so the receipt estimates the cost from Vajra's hand-kept
price list — and every new model breaks it (Opus 5.5 reads ~5× too high: rudra S07/S08/S09 receipts said
~$48.68 / ~$62.71 / ~$118.69). A headless `vajra claude -p` run already reads the tool's own
`total_cost_usd` (S77/S78; S188's live run showed "$0.03 what this run cost"). This session finds where Claude
Code exposes its own cost for an INTERACTIVE session (candidates: the status-line JSON's `cost.total_cost_usd`,
a hook's input, the transcript) and makes the receipt use it; where the tool gives none, the receipt says so.

## Deliverables
1. **Find the tool's own figure (researcher first).** Which surface of Claude Code 2.1.x carries an interactive
   session's cost, when it is written, and whether Vajra can read it without the user's own settings changing
   (the status line is the user's; `vajra claude` injects `--settings` today — ADR-0003). Recorded in the design.
2. **The receipt uses it.** An interactive `vajra claude` run's headline cost is the tool's own figure, labelled
   as such. When the tool gives none, the headline says "no cost from Claude Code for this run" and the token
   estimate stays a labelled `[estimate]` — never the headline.
3. **No new price rows.** The price list is not extended for Opus 5.5 or any other model (founder, S176/S177).
4. **Projects get it** with no action: `vajra claude` in rudra shows the real figure on its next run.

## Acceptance
| AC | Check |
|---|---|
| AC1 | A recorded interactive-run fixture (or a live interactive run, founder's yes first) whose tool figure is known: the receipt's headline equals that figure. Red at the start commit: it prints the price-list estimate. |
| AC2 | A run where the tool gives no figure: the headline says no cost is known; the estimate is labelled `[estimate]` and is not the headline. |
| AC3 | An unknown model (e.g. a made-up `claude-opus-9`) never makes the headline a guess. |
| AC4 | `-p` runs are unchanged (the S77/S78 result-stream figure still wins). |
| AC5 | Every fix has a real-run check in `scripts/verify-session-189.sh` (no source greps), red at the commit S189 starts from; the full `cargo test` passes before the PR. |

## Design
design-significant: yes
- Extends ADR-0004 (meter and receipt) and the S77/S78 "the tool's own cost is authoritative" decision to
  interactive runs; may touch ADR-0003 (the `--settings` injector) if the figure arrives through a hook or the
  status line. The design-advisor names the record and the shape after the researcher's finding.

## Carried in
- F67 (S176 summary row; STATE 🔴). Memory: read the tool's own cost, don't grow a price list (S77–S79).
- From S188: the approvals before/after check shipped (DECISION-011 S188 addendum); rudra gets it on its next
  `--sync-fleet`. **Backlog, S190 checklist:** N2; the rest of N7; F97's opt-out key; `--advance` number-swaps
  SESSION-BOOT (hit again in S188); the session guard reads a session number in edit text; verify-133 not safe to
  run twice at once; `tests/gt_cadence_shared.rs` reads the real repo's summary; S188's named gaps (a change undone
  in one command, writes between pairs, another project's folder). **Parked:** non-Claude tools, release.

## Guardrails
- ≤3 files per commit; every fix has a check red at the start commit for the named reason.
- A paid live run needs the founder's yes first, cheapest model, throwaway folder.
- Never print a guessed dollar figure as the headline.
- Run the full `cargo test` before pushing.

## Plan
<the S189 agent writes this after the tech-lead, each step citing `covers: N`>

## Delta
- `~` an interactive `vajra claude` receipt's headline cost: the tool's own figure, or "no cost known"
- `~` the price-list estimate: labelled `[estimate]`, never the headline
- `-` F67 from STATE's broken list (if AC1–AC3 pass)
