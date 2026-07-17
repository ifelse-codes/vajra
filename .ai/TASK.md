# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 71 — The Demo-er station (pipeline station 7, the SHOW gate) — COMPLETE

- **Shipped:** every closing session now needs a sprint demo a human can watch (before →
  after) — `vajra next --demo NN` surfaces the recorded `CONSTRAINTS.yaml#demo` contract
  read-only; `--check-demo NN` RE-RUNS the demo LIVE (S69 house pattern) and blocks on a
  non-zero exit OR a required `demo:<element>` marker missing from the live output (the hollow
  exit-0 demo dies on the element scan); rides `--advance` on the CLOSING session
  (`VAJRA_SKIP_DEMOER_GATE=1` distinct). `before_after` recorded as a required element;
  `scripts/demo-session-template.sh` created (the S70 gap) + scaffold propagation.
- **Proof:** 214 lib tests (+11) · `verify-session-71.sh` 43/43 · cold review ACCEPT (27
  probes) attested `a51a44d6…`. Fakest green disclosed: marker-stuffing (the `covers:`-class
  floor). Permission dodge killed in-session. **S71 spend ~$0.**
- Read prompt: `prompts/71-task-demoer-stage.md`

Between sessions. **Next = S72, CODE — the Releaser station**
(`prompts/72-task-releaser-stage.md`, APPROVED, gate-checked READY through
Analyst+Architect+Planner. **New chat.**)

## Next Session (S72 — the Releaser station, pipeline station 8: the SHIP gate)
- **Type:** CODE (standing founder direction "finish the crew" — Demo-er ✓ → Releaser).
- Git-native ship hygiene enforced at close: session branch merged (ancestry) · local main
  synced with origin · merged `session-*` branches pruned (the S37 founder-flagged
  return-to-main step becomes enforcement). `vajra next --release NN` surfaces read-only;
  `--check-release NN` blocks; rides `--advance` (L1 advises; `VAJRA_SKIP_RELEASER_GATE=1`
  distinct); `CONSTRAINTS.yaml#release` recorded + scaffold propagation; no network, no `gh`
  in the gate.
- Branch `session-72-releaser-stage`. **S75 = the next mandatory NO-CODE GT.**

## Always-True Reminders
- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Every 5th session is NO-CODE ground-truth (next = **S75**).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **New session = new chat** — open a fresh chat for S72; do NOT start it here.
- **Direction:** product = **provable agent governance**, shaped as a **governed multi-agent SDLC
  pipeline** (`DECISION-001`); fidelity is the load-bearing governance (`DECISION-002`), verdicts
  attested (`DECISION-003`) + chained into a tamper-evident ledger (`DECISION-004`).
  **Pipeline = 7 governed stations** (Analyst WHAT · Architect DESIGN · Planner HOW-plan ·
  Coder DID · QA WORKS · Demo-er SHOW · Reviewer/ledger REVIEW) + the authoritative receipt.
  Founder direction: **finish the crew** — Releaser (S72) next; Monitor later.
  **S70 founder decisions:** dogfood = founder-led manual run after the crew (deferred by
  decision) · compression = never claimed until measured real · payload counter = backlog.
