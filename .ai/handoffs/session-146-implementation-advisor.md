---
role: implementation-advisor
session: 146
agent: claude-code-subagent (verified: toolu_0172xGDWcQTMQTdA3cyBdy9P)
source-sha: 08f96fc95753feb69a7668832e5863700f838f92e975e47c25c9a4104d0ea7f8
captured: 2026-09-05T04:00:54Z
cost_usd: null
---

# Implementation-advisor handoff — session 146

# Implementation-Advisor Findings — Session 146

## ONE-LIST invariant verified

fxs() closure: `render_stamped_hook(&fill(content))` — fill is a no-op for the scaffold template (no placeholders), so both paths produce identical bytes. A fresh init + --sync-fleet correctly reports UpToDate.

## BIN resolver syntax verified

`local BIN; BIN="$(command -v vajra 2>/dev/null || echo "target/release/vajra")"` is the correct bash pattern for a local variable assignment capturing a subshell. Three occurrences at lines 335, 402, 478.

## Edge cases (acceptable tradeoffs)

- Version skew: PATH-first means a stale global install wins over target/release/vajra. Expected for non-Rust adopters; inherent PATH-first tradeoff.
- Binary absent on both paths: BIN set to literal "target/release/vajra", [ ! -x ] catches it, emits BLOCK. Correct failure mode.

## Recommendations

rec 1 — Verify Cargo.toml negation follows existing pattern. (Confirmed by build passing.)
rec 2 — Add test: fill(TPL_VERIFY_CLOSEOUT_SCAFFOLD) == TPL_VERIFY_CLOSEOUT_SCAFFOLD. (IMPLEMENTED: placeholder-absence test added.)
rec 3 — Document fill-transparency requirement in SYNC_HOOKS block comment. (IMPLEMENTED.)

## Status

All recommendations implemented. 470 tests passing.

## Handoff Delta
- `+` new: first implementation-advisor handoff for this session (1260 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
