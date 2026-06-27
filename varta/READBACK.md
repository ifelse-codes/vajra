# Varta v0 — Read-Back Test

**The proof:** an agent given only the `varta` skill + `vajra.varta` reads the rules correctly and uses the `⚡on` co-pilot. Nothing parses Varta — the agent is the runtime, so the test is the agent answering from the spec.

**Method:** answers below are derived **only** from [`vajra.varta`](vajra.varta) and [`GRAMMAR.varta`](GRAMMAR.varta) — no other `.ai/` file consulted. If the answer is in the spec, internalization worked.

---

### Q1. What is forbidden in this project?
From `⚡forbid`:
- `work_on_main` — branch `session-NN-slug` first.
- `commit_without_approval` — wait for an approval token.
- `autonomous_commit` — a human says when.
- `code_in_ground_truth` — every 5th session is NO-CODE.
- `skip_hooks` — no `--no-verify`.
- `force_push_to_main`.

### Q2. When I touch compression, what context loads?
From `⚡on (compression) ⚡include`:
- `src/engine/*` (the engine + heuristics)
- `research/*fixtures*` (golden fixtures)

→ I fire this load **only** when I actually touch compression work, not at boot. That is the co-pilot.

### Q3. What are the hard numeric limits?
From `⚡max`: assumptions **2** · retries **2** · files per commit **3** · stories per session **1** · hours per session **2** · words per response **200**.

### Q4. Which decisions are locked?
From `⚡final`: **ADR-0001** (compression via PostToolUse hook), **0002** (Engine trait + enum, single crate), **0003** (`--settings` injector, LINE_CAP=30), **0004** (meter/receipt on-exit), **0005** (pre-run estimate). Changing any needs explicit human approval.

### Q5. What is the one goal I must not drift from?
From `⚡project.⚡goal`: **`vajra next` = the cross-agent workflow coach. Co-pilot, not cop.**

### Q6. Before I ship, what must I check?
From `⚡assert`: what can break? · hidden assumptions? · production ready? · patches only on repro evidence? · scope intact?

---

**Result:** 6/6 answerable from the spec alone. The grammar carries real operating context, and the `⚡on` co-pilot is expressed and understood. Varta v0 holds.

*This file is the static capture. The live demo (`scripts/demo-session-19.sh`) shows the spec + a fresh read-back; `scripts/verify-session-19.sh` checks the structural invariants (all 9 constructs present, `⚡forbid` + `⚡on(compression)` exist).*
