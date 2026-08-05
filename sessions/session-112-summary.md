# Session 112 — CODE: downstream handoff-consumption

**Verdict: SHIPPED.** The fleet's output stopped being an orphan. Vajra could already *write* a
governed researcher handoff (S109) and *prove* it came from a real by-name subagent dispatch (S111) —
but nothing ever read one back. A human had to know to open `.ai/handoffs/` by hand. Now four
surfaces read it automatically, findings inline.

## What shipped, in plain English

- **The packet an agent boots on (`vajra next`) carries this session's research.** This is the one
  that matters: the next agent sees the findings without being told to look.
- **The Analyst's intake (`vajra next --intake` / `--scaffold`) folds them in** as a first-class
  input, alongside the prior session number and the ROADMAP's next-builds.
- **The Analyst's gate (`vajra next --validate NN`) shows them beside the WHAT** it is grading.
- **No handoff = nothing printed.** A session with no fleet work reads exactly as it did before.
- **A broken handoff is NAMED, never swallowed** (`⚠ … does not satisfy the handoff contract
  (<reason>) — not used`). A file that exists but is off-contract can never read as "nothing here".
- **Truncation is disclosed** — the inline view shows 6 lines and then says how many it left out and
  where the rest lives.

Nothing blocks. Consumption is advisory this session, by design: a gate that fires on an artifact an
agent may legitimately not need would be false teeth.

## Evidence

| What | Result |
|---|---|
| `cargo test --lib` | **315 passed**, 0 failed (+11 this session) |
| `scripts/verify-session-112.sh` | **16/16 ALL GREEN** |
| `scripts/demo-session-112.sh` | **exit 0**, 6/6 cases, all elements |
| `cargo clippy --all-targets -- -D warnings` | clean |
| Cold review | **ACCEPT ×2** (two independent passes) — `sessions/session-112-review.md` |
| Stations (`vajra next --stations 112`) | Analyst · Architect · Planner READY; Coder closes with this commit |
| Commands | still **7** — consumption rides `next`, no 8th |

The proof is behavioural, not structural. `verify`'s end-to-end check builds a throwaway repo, runs
`vajra init`, governs a handoff through the **real writer** (`vajra next --role researcher --from`),
and requires the same command's output to change and to carry the actual findings — plus a
cross-session negative control and a malformed-handoff case. Separately, it checks **real data**: the
genuine S111 handoff (produced by an actual by-name subagent dispatch) now surfaces at the Analyst
gate in this repo, while S110 (no handoff) is untouched.

## Fidelity map — every numbered requirement

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| D1 | Reader in `src/fleet/` (absent · malformed · found + inline renderer) | SHIPPED | `parse_handoff`, `read_handoff(s)`, `format_handoff_brief`, `HandoffRead` |
| D2 | Analyst consumes it (`--intake`, `--scaffold`) | SHIPPED | `Intake.fleet_handoffs`; `gather_intake(root, session)` |
| D3 | Packet + Analyst gate surface it | SHIPPED | `run_dump`, `run_validate` in `src/cli/next.rs` |
| D4 | verify + demo, green, behavioural | SHIPPED | 16/16 · exit 0 |
| D5 | summary + independent cold review | SHIPPED | this file + `sessions/session-112-review.md` (2 cold passes) |
| AC1 | A station surfaces the handoff, findings INLINED | SHIPPED | asserted by content on all three surfaces |
| AC2 | Absence silent; off-contract handoff named | SHIPPED | `!brief.is_empty()` guards; `— not used` line |
| AC3 | Real end-to-end proof through the real writer | SHIPPED | `e2e-consumption`, no planted fixture |
| AC4 | tests green · CI both OS · both scripts exit 0 | **PARTIAL** | tests + scripts green locally; **CI both OS unevidenced pre-merge** |
| AC5 | Independent cold review, per-requirement + fakest green | SHIPPED | two passes, both ACCEPT |

**9 of 10 SHIPPED · 1 PARTIAL · 0 NOT-BUILT.** The PARTIAL is the same one S109 and S111 carried: CI
runs on the PR, so pre-merge delivery cannot evidence it.

## What I did NOT build

- No second fleet role (still deferred, DECISION-007).
- No change to the handoff format — this session added a reader, not a new writer contract.
- No unattended `claude -p` dispatch mode.
- No 8th command.
- **No blocking gate on unread findings** — deliberate; see above.
- **No live subagent run this session.** The S111 finding stands: Claude Code snapshots
  `.claude/agents/*.md` at session boot, so a mid-session dispatch by name is impossible. The
  real-data check therefore rides S111's genuine handoff rather than manufacturing a new one with
  fake provenance.

## The fakest green (disclosed)

Both cold passes found a real one, and both were fixed in-session:

1. **Pass 1:** the packet and gate checks asserted a section *header* that a **rejected** handoff
   prints too — they could not tell consumption from refusal-to-consume. Fixed (`eaff77d`): they now
   assert the findings themselves.
2. **Pass 2:** `cargo test --lib <filter>` **exits 0 when the filter matches nothing**, so seven
   named-test checks were green after a rename or deletion. Fixed (`26e5544`): a filtered run must
   report `N passed` with N ≥ 1, plus a guard-on-the-guard that runs a nonexistent filter and
   requires it to fail.

**Still standing, not fixed:** `no-eighth-command` greps a hardcoded usage banner, so it would not
notice an 8th command whose author forgot to update the help text. The non-goal genuinely holds; the
*check* does not enforce it. This is house-wide (S111 has the identical check) — flagged, not fixed
unilaterally.

## Cost

**$0 in metered API spend for the build.** Two cold-review subagent passes ran inside this
interactive session (~161k subagent tokens total); their cost rolls into the session receipt
unitemized — the S111 finding stands (`scripts/check-subagent-cost-fields.sh`: no local subagent
transcript carries a cost field). No `vajra claude` governed run — **the launcher dogfood is still
🔴 stale since S103.**

## Next — ranked candidates

- **A — 🥇 Make the fleet earn its keep in the counter (and pick the second role).**
  *Goal:* a governed handoff should earn station credit in `vajra next --stations`, and the second
  fleet role should be chosen by what the pipeline actually lacks, not by reflex.
  *Why:* the S110 GT meta-check flagged that K-of-8 is blind to fleet work; S112 just added a second
  fleet capability and the counter still cannot see either.
  *Risk:* changing the counter's definition mid-flight makes cross-session K numbers incomparable.

- **B — 🥈 A real paid dogfood run (`vajra claude`), overdue since S103.**
  *Goal:* run one governed session through the launcher for real and record the true receipt.
  *Why:* nine sessions of machinery have shipped since the last paid run; STATE has carried 🔴 for
  three sessions. The dogfood audit exists precisely to catch this.
  *Risk:* costs real money and may surface unrelated breakage that eats the session.

- **C — 🥉 The consumption gate grows teeth (opt-in).**
  *Goal:* let a session declare that a handoff is required, so the gate BLOCKS when it is missing or
  off-contract rather than only mentioning it.
  *Why:* advisory consumption is where S112 stopped; enforcement is the product's whole thesis.
  *Risk:* a gate that fires on an artifact a session legitimately does not need is false teeth —
  worse than no gate.

**Founder picks one. Next session = new chat.**
