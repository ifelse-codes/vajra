# Session 109 — fleet slice 1: Researcher as a governed Claude Code subagent

**Type:** CODE · **Branch:** `session-109-fleet-researcher` · **PR:** #115 · **Date:** 2026-08-02
**Order:** C→B→A's **A** ("start the fleet"), first slice.

## Goal — achieved?

**YES.** Vajra now ships the fleet's first named agent: a **Researcher** as a **native Claude Code
subagent**, scaffolded from one canonical source and governed into a delta-tracked handoff — proven
by a **real Researcher subagent run** inside the live session.

## The mid-session mechanism redirect (founder call)

The brief (S108 follow-up) asked for the role to be proven by one **real, small, paid `claude -p`
call**. The first build did exactly that: `vajra claude --role researcher` spawned a headless
`claude -p` subprocess (5 commits, stub-proven 7/7). It then hit a **headless "Not logged in" auth
wall** — a bare `claude -p` fails identically; clearing it needs a credential only the human can
supply. The founder chose **subagent-only**: the role is a native Claude Code subagent that runs
inside the already-authenticated session (no separate paid call, no wall). The `claude -p` path was
**reverted** (`launch.rs` restored to pristine); the mechanism moved to `vajra init` (scaffold) +
`vajra next --role --from` (govern). DECISION-007 records the subprocess path as the rejected
alternative.

## Fidelity map — every requirement in the (redirected) prompt → what shipped

| # | Requirement (final prompt) | Status | Evidence |
|---|---|---|---|
| 1 | `DECISION-007` exists, cited by a non-placeholder `## Design`, passes the Architect gate | **SHIPPED** | `docs/decisions/DECISION-007-agent-fleet.md`; `vajra next --check-design 109` → **READY**; `--stations 109` Architect **PASSED** |
| 2 | Scaffold Researcher as a native subagent (init) AND govern a brief into a validated handoff (next --role --from), existing surfaces, no 8th command | **SHIPPED** | `vajra init` writes `.claude/agents/researcher.md` from `fleet::ROLES`; `vajra next --role researcher --from` → `.ai/handoffs/session-109-researcher.md`; `--help` lists 7 |
| 2a | (a) a real Researcher subagent run whose brief becomes the handoff | **SHIPPED** | Task-tool subagent, sonnet, 58,669 tok, 4 tools; brief → governed handoff (validated, source-sha `ffa5b3fd…`); `sessions/session-109-artifacts/researcher-{run-note,subagent-brief}.md` |
| 2b | (b) the fail-closed smoke (no paid call, no live agent) | **SHIPPED** | `scripts/fleet-smoke.sh` 7/7 |
| 3 | Smoke exits non-zero on unknown role · missing `--from` · missing/empty findings | **SHIPPED** | fleet-smoke cases 4–7 (4 fail-closed) |
| 4 | `cargo test --lib` green; CI green both OS; 8-station gate logic + receipts unchanged (additive) | **SHIPPED (CI pending)** | 304 lib tests green; clippy clean; `launch.rs` pristine, `fleet` is additive — no gate/receipt logic touched. **CI on PR #115 to confirm green both OS.** |
| 5 | `verify-session-109.sh` green (incl. a fail-closed probe); `demo-session-109.sh` exit 0 + 4 markers | **SHIPPED** | verify **9/9** (incl. `smoke-is-falsifiable` meta-check); demo exit 0, markers header/cases/summary_table/before_after |
| 6 | Independent cold review → ACCEPT, attested; ledger chain intact | **SHIPPED** | `sessions/session-109-review.md` (verdict + `Review-Inputs-SHA`); ledger appended |

## What I did NOT build (stated plainly)

- **No paid `claude -p` call** — superseded by the founder's subagent-only redirect. The subprocess
  path was built then reverted; it survives only as DECISION-007's rejected alternative.
- **No unattended dispatch mode.** The subagent path needs a live session; an unattended
  (`claude -p` + `ANTHROPIC_API_KEY`) mode is explicitly deferred (DECISION-007). The live
  Researcher brief actually *researched* how to do it — `ANTHROPIC_API_KEY` is the answer.
- **The next station does not yet consume the handoff.** The handoff is written + validated;
  nothing downstream reads it automatically yet (a future stage/decision).
- **One role only** — a second role, parallelism, orchestration all deferred (the named key risk was
  scope creep; held).

## Fakest green (disclosed)

**The scaffolded subagent definition and the live subagent run are proven *separately*, not as one
wired flow.** `vajra init` scaffolds `.claude/agents/researcher.md`, and a real subagent ran with the
same canonical role prompt — but the live subagent was dispatched by the orchestrator passing that
prompt to the Task tool, **not** by the Task tool reading the scaffolded `.claude/agents/researcher.md`
by name. Both halves are real; the "definition → auto-dispatch by name" wire is not demonstrated
end-to-end in this repo. Also: `cost_usd: null` in the handoff (a subagent's cost is not itemized
per-run; it rolls into the session receipt — honest null, S77), and CI-green-both-OS is pending on
PR #115 at write time.

## Evidence index

- Code: `src/fleet/mod.rs`, `src/cli/next.rs` (`--role --from`), `src/cli/init.rs` (scaffold).
- Design: `docs/decisions/DECISION-007-agent-fleet.md`.
- Live proof: `.ai/handoffs/session-109-researcher.md` + `sessions/session-109-artifacts/`.
- Gates: `scripts/{fleet-smoke,verify-session-109,demo-session-109}.sh`.

## Next — exactly 3 candidate sessions (A/B/C)

**S110 is a mandated NO-CODE ground truth** (`NN % 5 == 0`). These are candidate **lead lenses** for it:

### A — GT lead lens: is the fleet REAL and advancing, or labelled machinery? *(recommended)*
- **Goal:** audit S106–S109 through the "is v0.1 stranger-shippable AND does the fleet actually move
  the product, not just add a role file?" lens; weigh the subagent pivot honestly.
- **Why pick this:** it is the mandated GT and the pivot deserves a cold, independent look before more
  fleet code lands; catches "machinery without payload" (the recurring S25/S60/S65/S70 gap).
- **Key risk:** a GT so soon after the pivot may under-weight that the slice is genuinely thin (one
  role, def-vs-dispatch not wired) — read the fakest-green honestly.

### B — GT lead lens: did the pivot leave the pipeline/handoff model COHERENT?
- **Goal:** focus the GT on whether the subagent handoff fits the 8-station pipeline (nothing consumes
  it yet) and whether "fleet" and "stations" are now two overlapping stories.
- **Why pick this:** the handoff is an orphan until a downstream stage reads it; better to catch the
  design seam now than after role #2.
- **Key risk:** narrower than lens A — could miss the broader shippability question the roadmap leads with.

### C — GT lead lens: cost + dogfood truth for the fleet
- **Goal:** focus on whether the receipt/cost story is honest now that a subagent's cost is null in the
  handoff and rolls into the session receipt; is the fleet "dogfood-able" and measured?
- **Why pick this:** the cost story is the historically weakest link (S66/S77 arc); a fleet that can't
  price its agents undermines the autopilot-trust pitch.
- **Key risk:** cost is a known-yellow area, not the highest-leverage question this session opened.
