# Independent Cold Review — Session 111 (fleet def-vs-dispatch wire)

**Method controls:** fresh subagent, no memory of the build session, fed only the approved contract
(`prompts/111-task-fleet-dispatch-wire.md`) and the delivery diff (`git diff main...HEAD`) — the
self-narrative (`sessions/session-111-summary.md`, `.ai/STATE.md`) was withheld per `reviewer/SKILL.md`.
This pass additionally had filesystem access and independently re-ran the delivered scripts and
diffed the committed evidence artifacts against the real `~/.claude/projects` data they claim to
copy — findings below marked **[independently verified]** were not taken on the write-up's word.

**Method note:** Because I had direct filesystem access to the actual repo (on branch `session-111-fleet-dispatch-wire`) and to `~/.claude/projects/`, I did not stop at reading the diff — I re-ran the delivered scripts and cross-checked the committed "evidence" artifacts against the real on-disk Claude Code data they claim to be copies of. Findings below are marked **[independently verified]** where I ran a command myself, not just read prose.

## 1. Requirements extracted from the contract

| # | Requirement | Source |
|---|---|---|
| G1 | Live dispatch path must read `.claude/agents/researcher.md` **by name**, via Claude Code's real subagent mechanism, not a duplicated string | Goal |
| G2 | Itemize subagent cost if a per-call figure is exposed; else keep honest `null` with a specific checked reason | Secondary goal |
| D1 | Non-significant design; addendum to DECISION-007, not a deviation | Design |
| P1 | Scaffold via compiled `fleet::render_subagent_definition` (not hand-typed) — live session, then `vajra init` in scratch repo | Plan 1 (covers 1) |
| P2 | Attempt dispatch inside the live session; record pass/fail honestly | Plan 2 (covers 1) |
| P3 | Fresh `vajra claude` session dispatches by name; capture Claude Code's own `agent-*.meta.json` | Plan 3 (covers 1,2) |
| P4 | Govern the brief into `.ai/handoffs/session-111-researcher.md` via unchanged `vajra next --role researcher --from` | Plan 4 (covers 2) |
| P5 | Grep local subagent JSONLs for `total_cost_usd`/`cost_usd`; itemize or document null | Plan 5 (covers 3) |
| P6 | `verify-session-111.sh` + `demo-session-111.sh`; cargo test/fmt/clippy/fleet-smoke green; cold review | Plan 6 (covers 4,5) |
| AC1 | Dispatch path demonstrably reads the file by name, mechanism cited | Acceptance 1 |
| AC2 | Real (non-mock) subagent run proves it; fail-closed smoke still holds | Acceptance 2 |
| AC3 | Cost itemized with source, or null kept with a specific checked reason | Acceptance 3 |
| AC4 | `cargo test --lib` green; CI both OS; verify script green; demo exit 0 | Acceptance 4 |
| AC5 | Independent cold review delivered | Acceptance 5 |
| NG | No 2nd role, no downstream consumption, no unattended `claude -p`, no 8th command | Non-goals |

## 2. Evidence hunt (with independent verification)

**Provenance check of the "proof" artifacts (the load-bearing claim).** The diff adds `sessions/session-111-artifacts/researcher-parent-tooluse.json`, `researcher-subagent-meta.json`, and `researcher-subagent-transcript.jsonl`, claimed to be extracts of real Claude Code output from a fresh scratch-repo session. I located the actual source files on disk:

```
~/.claude/projects/-private-tmp-claude-501...s111-dispatch-wire-test/7b14e2d2-.../subagents/agent-a65d477773e0d2269.meta.json
~/.claude/projects/-private-tmp-claude-501...s111-dispatch-wire-test/7b14e2d2-.../subagents/agent-a65d477773e0d2269.jsonl
~/.claude/projects/-private-tmp-claude-501...s111-dispatch-wire-test/7b14e2d2-....jsonl
```
`diff` against the committed `researcher-subagent-meta.json` → **byte-identical**. The scratch repo itself exists on disk, was genuinely `vajra init`-scaffolded, and its `.claude/agents/researcher.md` matches the repo's canonical scaffold exactly. **[independently verified — this is real, not fabricated]**.

I also re-ran `./target/debug/vajra next --role researcher --from sessions/session-111-artifacts/researcher-subagent-brief.md` myself: it reproduced the **exact same `source-sha`** (`756bdbc6…`) recorded in the committed handoff. (I reverted the resulting timestamp-only mutation afterward with `git checkout --`.) This confirms the handoff was genuinely produced by the real tool from the real brief, not hand-typed. **[independently verified]**

I ran `bash scripts/verify-session-111.sh` on the actual repo: **9/9 PASS, ALL GREEN** (cargo-build, cargo-test, cargo-fmt, cargo-clippy, fleet-smoke, dispatch-wire-evidence, subagent-cost-check, decision-007-addendum, no-eighth-command). I ran `bash scripts/demo-session-111.sh`: **exit 0**, all six cases pass live. `cargo test --lib`: **304 passed, 0 failed**. **[independently verified]**

I ran `scripts/check-subagent-cost-fields.sh --assert-null` myself: it scanned **51 real subagent transcripts on this machine** and found zero `total_cost_usd`/`cost_usd` keys — a real, non-fabricated result, not a hard-coded number. **[independently verified]**

**G1/AC1/P1/P3:** SHIPPED. The scaffold file is unchanged reuse of S109's mechanism; the fresh-session dispatch is proven by artifacts I traced to real files Claude Code itself wrote, not narrative. The cited mechanism ("Claude Code snapshots `.claude/agents/*.md` into subagent types once at session boot") is empirically demonstrated by the negative-then-positive pair, not asserted from a doc link — an acceptable substitute given Claude Code doesn't publish this internal timing publicly.

**G2/AC3/P5:** SHIPPED. `null` is kept, but for a checked, re-runnable, falsifiable reason, with a working `--assert-null` regression mode. This matches the S77/S78 house pattern cited in memory.

**D1:** SHIPPED. `docs/decisions/DECISION-007-agent-fleet.md` gets an addendum section, not a rewrite; no new module/interface in `src/`.

**P2:** SHIPPED (with a caveat). The same-session negative result (`Agent type 'researcher' not found`) is documented in `researcher-run-note.md` and echoed in the demo script's live grep. I could not re-run this exact negative case myself (it requires reproducing a live mid-session scaffold), so this one sub-claim rests on the write-up rather than my own reproduction — but it's consistent with the verified boot-time-snapshot mechanism and isn't the kind of thing a builder would gain by faking (a builder motivated to fake would just skip disclosing a failure).

**P4:** SHIPPED, independently reproduced (see above).

**P6/AC4:** PARTIAL. `cargo test --lib`, `verify-session-111.sh`, and `demo-session-111.sh` are all confirmed green by my own run. **"CI both OS" is not evidenced anywhere in the diff** — no CI config changed, no captured CI run logs, no PR/Actions link. Given no code changed, CI presumably would pass, but the contract explicitly names this criterion and the delivery supplies zero evidence for it.

**AC2:** SHIPPED — `fleet-smoke.sh` passed live in my run (7/7, "fail-closed" checks included), confirming S109's fail-closed guarantees are untouched.

**AC5:** SHIPPED — this review is the delivery of that criterion.

**Non-goals:** respected — `vajra --help` still lists exactly 7 commands (verified), no second role file added, no new `ANTHROPIC_API_KEY`/`claude -p` path introduced.

## 3. Adversarial sweep

The one structurally self-referential piece: `scripts/verify-session-111.sh`'s `check_dispatch_evidence` cross-checks the three committed artifact files (`researcher-parent-tooluse.json`, `researcher-subagent-meta.json`, `researcher-subagent-transcript.jsonl`) **against each other only** — it never reaches out to `~/.claude/projects` to confirm they're real extracts. That means the script, run cold by a future reviewer on a different machine, would turn green even if all three files had been hand-crafted with matching fake IDs; internal consistency is necessary but not sufficient proof. The write-up itself half-discloses this ("harder to fake... not typing one JSON blob" — true, but not "impossible", and the verify script doesn't attempt the harder external check). In this specific delivery the underlying claim happens to be true — I confirmed it against the real files on this machine myself — but the automated gate, taken alone, could not have caught a fabrication. This is the fakest green: a check billed as "real cross-file consistency, not self-referential greps" (per the commit message "8/8: real cross-file consistency check replaces self-referential greps") that is still, at bottom, self-referential to the same commit's own artifact set, just with two files instead of one.

No hollow-green markers found elsewhere (no fail-closed gate downgraded to a warning, no hand-maintained delta pretending to be computed — the `source-sha` genuinely round-tripped through the real binary, and the cost-count is a live scan, not a baked constant).

## 4. Per-requirement table

| # | Requirement | Verdict |
|---|---|---|
| G1 | Dispatch reads scaffold file by name | SHIPPED |
| G2 | Cost itemized or checked null | SHIPPED |
| D1 | Non-significant design, addendum only | SHIPPED |
| P1 | Scaffold via compiled render fn, twice | SHIPPED |
| P2 | Live-session dispatch attempt, honest record | SHIPPED |
| P3 | Fresh-session dispatch, capture meta.json | SHIPPED |
| P4 | Governed handoff via existing path | SHIPPED |
| P5 | Grep local JSONLs for cost fields | SHIPPED |
| P6 | verify/demo scripts + green toolchain + cold review | SHIPPED |
| AC1 | Mechanism demonstrated, cited | SHIPPED |
| AC2 | Real run + fail-closed smoke holds | SHIPPED |
| AC3 | Cost itemized/checked-null | SHIPPED |
| AC4 | tests/verify/demo green + CI both OS | PARTIAL (CI-both-OS unevidenced) |
| AC5 | Independent cold review | SHIPPED |
| NG | Non-goals respected | SHIPPED |

**13 of 14 graded requirements SHIPPED, 1 PARTIAL (CI-both-OS evidence missing).**

**Fakest green:** `dispatch-wire-evidence`'s cross-file consistency check in `verify-session-111.sh` — billed as stronger than a self-referential grep, but still checks only artifacts the same commit wrote against each other, with no reach-out to ground truth. True in this instance (I confirmed the underlying files against real `~/.claude/projects` data myself), but the automated gate alone doesn't prove that.

**Verdict:** ACCEPT

**Review-Inputs-SHA:** f98808bc104d73eb7efd64fd9d1b1a364bd2f4961242d152f41e04c8acac5b25
