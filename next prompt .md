DESIGN PHASE COMPLETE (DS1–DS4, ADR-0001 through ADR-0004).

Next phase: CODE.

The architecture is fully locked across four ADRs. All interfaces, constants, wire formats, module layout, heuristic contracts, and guardrails (G1–G12) are defined. The implementation order (from ADR-0002 §7, extended by ADR-0004 §7) is:

1. engine/mod.rs — Engine trait + types (LINE_CAP, FAIL_PASSTHROUGH_CAP)
2. tests/shim_stub.rs — G3 conformance (StubEngine)
3. engine/heuristics/* — cargo, git, generic, pytest, npm, docker (each with SPEC.md fixture test)
4. engine/default.rs — DefaultEngine: pre-rules + dispatch
5. adapter/claude_code.rs — HookAdapter wire types + pre-checks + run()
6. cli/hook.rs — hook subcommand entry point + sidecar append (G12)
7. cli/launch.rs — vajra claude launcher: TempSettings + merge + spawn+wait + sidecar env + on-exit meter call
8. meter/mod.rs, meter/pricing.rs, meter/parser.rs, meter/receipt.rs
9. bench/fixtures/session_v1.jsonl + expected_v1.json + pricing.toml
10. tests/meter_tripwire.rs — G11 release gate
11. cli/meter.rs — vajractl meter subcommand
12. Cargo.toml — set up the crate

Before starting: scaffold the Cargo.toml and src/main.rs skeleton first so the build system is in place.

Key open questions to verify AT IMPLEMENTATION TIME (don't block; implement and verify):
- Does CC's --settings behave additively or as a replacement? (affects TempSettings content)
- Does CC's PostToolUse hook payload include exit_code? (affects G6 is_success logic)
- Does CC flush JSONL synchronously on exit? (affects post-wait() sleep need)
- Exact passthrough behaviour for {} output from the hook process
