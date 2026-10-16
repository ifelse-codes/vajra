# Session 201 — CODE: the S200 small fixes + the README "tested with" line

> **Status:** DRAFT — written in the S200 chat after the founder's sign-off, from his pick (2026-10-16: option C,
> "small fixes"). The founder reads it and runs `vajra approve 201` in his own terminal; the gate reads the record,
> not this line.

## Type
session_type: CODE
- **CODE.** Max 2 assumptions · 2 retries · ~2h · 1 story (the S200 findings) · new chat.
- **Split rule:** do the items in the order below. If the session nears ~2h, stop after the item in progress. What is
  left goes to S202, with the founder's yes, written in the summary.

## Goal
Clear every finding the S200 review filed for code (N24, N22, N25), and put the README "tested with" line (S195 Haiku
answer c) in the founder's own words. N27 (STATE's missing S196 cost row) was fixed in S200's closeout. N26 is a
procedure note for the S205 prompt, not code. Small, each with a real-run check that fails without it.

## Deliverables
1. **N24 — the sign-off step says "write the report" first.** On a review-only session, while
   `sessions/session-NN-ground-truth.md` does not exist, the step's how starts with "write
   `sessions/session-NN-ground-truth.md` (every audit, live), then show it to the founder…". Once it exists, the how is
   today's. `src/nextstep/mod.rs:123-137`.
2. **N22 — retire `scripts/verify-session-178.sh` and `scripts/demo-session-178.sh` as history** (founder, 2026-10-16:
   "Retire it"). Follow the Hollow-Advice Retirement Standard the way verify-175/182/186/187 were retired: say so where
   the next reader looks (the script's header and the ROADMAP known-bug entry), with the superseding reason. No
   rewording of their checks.
3. **N25 — the merge step says "reinstall `vajra`".** The founder's installed `vajra` was older than main at S200's
   start (`~/.cargo/bin/vajra` built 2026-10-15, #238 merged 2026-10-16), so S199's fixes never ran at boot. Where the
   agent hands the founder the after-merge steps, add `cargo install --path . --locked` when the merged branch touched
   `src/`. Find where that text lives first, and name it. A note, not a gate. (A `--version` that carries the commit is
   the founder's call, not this session's.)
4. **The README "tested with" line (S195 Haiku answer c).** A plain, observed fact. Steps that are only instructions
   were followed on Opus (rudra S16–S19, S21) and skipped on Haiku 4.5 (rudra S20); the blocks held on both. **Ask the
   founder for his own words before writing it.** The README is his spec (S118: never soften README or VISION to match reality), so
   the agent proposes and he decides.

## Acceptance
| AC | Check |
|---|---|
| AC1 | N24: in a temp review-only project with no report, `vajra next --steps`'s first open step says to write the report; with the report present it says today's how. It is red with `0caedc3`'s binary. |
| AC2 | N22: both scripts' headers say RETIRED with the reason; the ROADMAP entry says so; nothing else changed in them. |
| AC3 | N25: the after-merge text names `cargo install --path . --locked` for a branch that touched `src/` (a real run, or the exact file and line shown). |
| AC4 | The README line is in the founder's words, quoted in the summary with his yes. |
| AC5 | Verify + demo scripts, full `cargo test` before the push (S187 rule), close GREEN, push through the belt. |

## Carried in
- **From S200:** `sessions/session-200-ground-truth.md` (N24–N27, founder rulings). N23 kept: verify-179's rudra row
  goes green on the founder's next `vajra init --sync-fleet` in rudra. N26 → the S205 ground-truth prompt (order:
  report → cold review → `vajra approve NN --close` → plan, advice, summary).
- **Parked by the founder:** non-Claude tools (F91, F94, F95), release/publish; F123/F127's named routes; F97's opt-out
  key; S188's gaps; the `/clear` receipt gap.
- Founder decisions to respect: no new policing of Vajra's own paperwork (2026-09-15); Vajra's close does not run
  `cargo test` (2026-10-04); one release-coordinator judges all `obeyed:` answers.

## Design
design-significant: no
- Wording, a retirement note, a README line: no design record changes.

## Plan
<the S201 agent writes this after the tech-lead>

## Delta
- `~` `src/nextstep/mod.rs` (N24) · the after-merge text (N25, file named in-session) · `README.md` (the founder's line)
- `~` `scripts/verify-session-178.sh`, `scripts/demo-session-178.sh` (RETIRED headers) · `.ai/ROADMAP.md` known bugs
- `+` `scripts/verify-session-201.sh`, `scripts/demo-session-201.sh`, `sessions/session-201-*.md`, `prompts/202-task-<slug>.md`

## Advice
