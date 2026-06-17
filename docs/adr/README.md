# Architecture Decision Records

Each ADR records one decision + its rationale. Lean by design (the doc obeys the discipline the product sells). Status flow: Proposed → Accepted (founder-ratified) → (later) Superseded.

| # | Decision | Status | Date |
|---|---|---|---|
| [0001](0001-compression-delivery-mechanism.md) | v1 compression is delivered via the Claude Code `PostToolUse` hook (not a PATH-shim); shim re-designated the future cross-agent rail | ✅ Accepted | 2026-06-15 |
| [0002](0002-engine-trait-adapter-contract-module-layout.md) | Engine trait interface, ClaudeCodeHookAdapter wire contract, heuristic dispatch strategy, and v1 module layout | ✅ Accepted | 2026-06-16 |
| [0003](0003-settings-injector-and-compression-heuristics.md) | `--settings` injector design (tempfile, merge algorithm, G9 schema validation) and compression engine heuristic contracts + constants | ✅ Accepted | 2026-06-16 |
| [0004](0004-meter-receipt-design.md) | Meter/receipt: on-exit session JSONL parsing, sidecar compression stats, pricing compiled-in, compact receipt to stderr, bench/fixtures tripwire | ✅ Accepted | 2026-06-16 |
