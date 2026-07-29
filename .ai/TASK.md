# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 105 — NO-CODE GROUND TRUTH (S101–S104) — COMPLETE

- **Verdict:** **PARTIAL (lead lens: is v0.1 shippable to a stranger?).** The governance **engine** is
  done and proven; the shippable **package** is ~0% — nothing published, README marks 3 install paths
  "NOT YET PUBLISHED", crate name settled on paper only (`DECISION-006`). **3 🟢 · 7 🟡 · 0 🔴.**
  Costs reconcile to the penny (S102 $0.4644 · S103 $0.6797). Two blind spots found: (1) **no
  instrument measures installability** — `vajra next --stations` read 7/8 on S101 while every install
  path was broken; (2) **`--dogfood-age` is blind to untracked receipts** — reports last=S97, true
  last=S103. Machinery-freeze rule (`DECISION-005`) declared **dead letter** post-pivot →
  superseded (Status corrected). All drift corrected in `.ai/` + docs at closeout. Report:
  `sessions/session-105-ground-truth.md`. Branch: `session-105-closeout` (exempt).

**🔀 FOUNDER PIVOT (S103, in force):** sessions now = **finish a shippable MVP**; founder runs the
long unattended test himself. Order **C → B → A**: C team-voice (S104 ✓) → **B make it installable
(S106, next build)** → A real agent fleet (after the MVP ships).

Between sessions. **Next = S106 — CODE: make it installable (v0.1)** (founder pick ①): one working
install path from a clean checkout + an installability smoke test (the missing instrument) + a README
quickstart truth-pass. Brief: `prompts/106-task-installable-v01.md`. **New chat** for S106.

## Always-True Reminders

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. **S106 = CODE** (verify + demo scripts required; no waiver).
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`.
- **crates.io publish is IRREVERSIBLE** — never publish (even an empty reserve) without an explicit
  founder "yes publish" in chat; the name burns on first publish.
- **Write `prompts/NN+1-task-<slug>.md` BEFORE closing** (`end_of_session`) — no gate catches a miss.
- **New session = new chat** — open a fresh chat for S106; do NOT start it here.
- **Direction:** product = **provable agent governance** (`DECISION-001`), sold as the autopilot
  trust layer; fidelity load-bearing (`DECISION-002`), verdicts attested (`DECISION-003`), chained
  tamper-evident (`DECISION-004`). Sessions now finish a shippable MVP (S103 pivot).
