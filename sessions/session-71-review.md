# Session 71 — Independent Fidelity Review (DECISION-002)

**Method:** independent cold pass by a fresh subagent fed ONLY the contract
(`prompts/71-task-demoer-stage.md`) + the delivery diff (main→HEAD, `sessions/`/`prompts/`/
closeout-`.ai/` excluded per the canonical attestation scope), told to read nothing else —
builder's summary, STATE, ROADMAP, prior reviews all withheld — and to verify adversarially by
RUNNING the delivered binary against throwaway fixture repos. 27 recorded probes. The builder
did not author this verdict; it is transcribed unedited from the reviewer's final message.

**Review-Inputs-SHA:** a51a44d6a162510be315ccfecafd8da04566cd00e253b77a643c42bffd34aa0e

---

## 1. Contract enumeration (reviewer's reading)

**Acceptance criteria (5):**
1. `vajra next --demo NN` surfaces the demo contract read-only (script exists/MISSING, 4
   required elements found/missing, honest-cost note), never executes.
2. `vajra next --check-demo NN` re-runs the demo LIVE; exit 1 on non-zero exit OR missing
   elements, naming the real failure; unrunnable/killed script blocks, never passes.
3. `--advance` binds the gate on the CLOSING session at L2/L3; L1 advises;
   `VAJRA_SKIP_DEMOER_GATE=1` distinct both directions, skips the live run itself, disclosed;
   no script → WARN naming the deletion dodge.
4. Sprint-demo shape: `before_after` is a gate-enforced required element;
   `scripts/demo-session-template.sh` exists carrying all 4 elements; `CONSTRAINTS.yaml#demo`
   records `before_after`; demo stays cumulative.
5. Proven live: `cargo test --lib` grows; `scripts/verify-session-71.sh` runs the named E2E
   cases in a temp git repo; no 8th command, no new dependency, no second store.

## 2. Probe log (all observed live)

| # | Probe | Observed result |
|---|-------|-----------------|
| P0 | `cargo build`; `cargo test --lib` | 214 passed, 0 failed; 11 new `demoer::tests::*` (203 pre-existing → grows) |
| P1 | Fixture, no script: `--demo 51` | `(MISSING — ... deleting the script is the named dodge)`, all 4 elements missing, "surfaced read-only", honest-cost note; exit 0 |
| P2 | `--demo` on a script that would `touch EXECUTED` | No sentinel file created — `--demo` never executed the script |
| P3 | `--check-demo` hollow demo (`exit 0`, no markers) | `NOT READY`, "ran live (exit 0) but its output shows no header, cases, summary_table, before_after ... hollow exit-0 demo does not pass the element scan"; **exit 1** |
| P4 | `--check-demo` red demo (`exit 3`) | `NOT READY`, "re-ran LIVE and exited 3 — a recorded green is not accepted"; **exit 1** |
| P5 | `--check-demo` 3-of-4 demo (no before_after) | `NOT READY`, "shows no before_after"; **exit 1** |
| P6 | `--check-demo` full 4-marker demo | `READY`; **exit 0** |
| P7 | `chmod 000` script (unreadable, still exists) | BLOCKS: "exited 126"; **exit 1** — does NOT degrade to the no-script WARN (permission dodge dead) |
| P8 | Script `kill -9 $$` (signal-killed, no exit code) | BLOCKS: "could not be evaluated (no exit code) — a check that cannot evaluate FAILS"; **exit 1** |
| P9 | No script: `--check-demo` | `READY` (exit 0) + WARN naming "deleting the script downgrades this gate to a warning (self-granted jurisdiction, disclosed)" |
| P10 | `--advance` at L3, red demo | Refuses; `.ai/SESSION` stays 51 |
| P11 | `--advance` at L3, hollow demo | exit 1; SESSION stays 51 |
| P12 | `--advance` at L3, full demo | "Advanced: session 51 → 52"; SESSION now 52 |
| P13 | `VAJRA_SKIP_DEMOER_GATE=1` + red demo, `--advance` | Advances 51→52 with "VAJRA_SKIP_DEMOER_GATE set — live demo re-run skipped." (skip-of-the-run disclosed) |
| P14 | Demoer skip + green demo + RED verify script | exit 1, SESSION stays 51 — the Demo-er's skip does NOT skip QA |
| P15 | All 5 other stations' skip envs set + red demo | exit 1, SESSION stays 51 — other skips do NOT skip the Demo-er |
| P16 | Maturity L1 + red demo, `--advance` | Prints the block reasons + "(L1 advise — advancing anyway.)"; advances to 52 |
| P17 | `--advance` with no demo script | WARN with the dodge named in the gate's own output; advances to 52 |
| P18 | Run `scripts/demo-session-template.sh` | exit 0; live output emits all four `demo:<element>` markers |
| P19 | `vajra init` in fresh git dir | `scripts/demo-session-template.sh` **byte-identical** (`diff -q` clean); scaffolded CONSTRAINTS records the 4-element list |
| P20 | Pre-S71 recorded 3-element `required_elements` | 3-marker demo is `READY` — the recorded shorter contract wins, `before_after` not demanded |
| P21 | Custom recorded `script_pattern: scripts/show-{NN}.sh` | Honored: gate runs `scripts/show-51.sh`, `READY` |
| P22 | Marker-stuffing: one line echoing all 4 tokens | `READY` — passes (the disclosed form floor; see Fakest green) |
| P23 | Directory at the script path | Classified as no-script → WARN/`READY` (see Minor 2) |
| P24 | Real repo: `--demo 71` / `--check-demo 71` | Surface: script `(exists)`, all 4 elements found; live gate re-runs S71's own demo → `READY`, **exit 0** |
| P25 | No 8th command / no new dependency / no second store | `git diff main...HEAD -- src/main.rs` = 0 lines; Cargo.toml adds exactly one line (the exclude-negation); no `demo.md`/`qa.md`/`plan.md`/`spec.md` |
| P26 | `bash scripts/verify-session-71.sh` | **41 PASS / 2 FAIL, exit 1.** All 41 code+E2E checks green incl. every contract-named case family. The 2 FAILs are `summary-artifact-present` and `cold-review-present` — closeout paperwork that did not exist yet at audit time |
| P27 | `bash scripts/demo-session-71.sh` direct | exit 0; all four markers live; before/after proven via `git cat-file -e 8dc5485:scripts/demo-session-template.sh` (absent at the S70 merge) |

## 3. Fakest green (reviewer-named)

**The element scan is a marker floor, and a one-line stuffed demo is a READY sprint demo.**
P22: a session whose entire demo is `echo "demo:header demo:cases demo:summary_table
demo:before_after"` passes `--check-demo` and closes at L3. The gate genuinely proves three
things — the demo EXISTS, RUNS GREEN LIVE (stale/recorded greens and unrunnable scripts die,
P4/P7/P8), and PRINTS the four tokens — but "before_after is enforced" means the demo emits the
string `demo:before_after`, not that it shows any actual before/after of the session's
delivery. Same self-asserted-tag class as the Planner's `covers: N`. Disclosed loudly (module
doc, the demo's own honest-edge paragraph, the gate's block message), so it is an honest floor,
not a hidden hole — but it is unambiguously the hollowest-looking green in the delivery.

## 4. Undisclosed minor edges (reviewer-found)

1. **No timeout on the live run** (`run_demo_script` uses `Command::output()`): a hanging demo
   hangs `--check-demo`/`--advance` forever. Never a false green; inherited from the S69 QA
   runner pattern; undisclosed in this diff.
2. **Directory at the script path** classifies as `NoScript` → WARN: a `mkdir` spelling of the
   deletion dodge, reported as "missing" while something exists there. Degrades identically —
   cosmetic misstatement only.
3. **Recorded `required_elements: []`** (explicit empty list) silently falls back to the 4
   defaults rather than honoring the recorded empty contract — fail-closed direction, but a
   one-case exception to "the recorded contract wins".
4. **Surface-vs-gate scan divergence:** `--demo`'s static scan counts a marker anywhere in the
   script text (a comment counts); the gate scans live output only. Surface optimistic, gate
   strict; disclosed in a code doc-comment, not in user-facing output.
5. **Verify was RED overall at audit time** (41/43) — solely the two closeout-paperwork
   presence checks, which cannot pass before this review lands. Sequencing, not a code gap; do
   not quote "verify green" for S71 until closeout re-runs it after the paperwork lands.

## 5. Verdict table

| Requirement | Verdict | Evidence |
|---|---|---|
| AC-1 `--demo NN` read-only surface | SHIPPED | `format_demo_contract` via `run_demo`; P1/P2: MISSING named, 4 elements found/missing, honest-cost note, sentinel proves nothing executes |
| AC-2 `--check-demo NN` live re-run, fail-closed | SHIPPED | P3–P8: hollow exit-0 blocked by element scan, red names "exited 3", missing element named, chmod 000 blocks, signal-kill blocks, full → exit 0 |
| AC-3 `--advance` binding, L1 advise, distinct override, no-script WARN | SHIPPED | P10–P17: red/hollow refuse (SESSION held), full advances; skip distinct both directions, disclosed as skipping the run; L1 advises; no-script WARN names the dodge |
| AC-4 Sprint-demo shape (before_after enforced, template, CONSTRAINTS, cumulative) | SHIPPED | P5 blocks on missing before_after; template runs green with all 4 markers (P18); CONSTRAINTS records 4 elements, `cumulative: true` kept; scaffold byte-identical (P19) |
| AC-5 Proven live (tests grow, verify E2E, no 8th command/dep/store) | SHIPPED | 214 lib tests (+11); verify runs every named E2E family green (41/41 code checks, P26); main.rs untouched, Cargo.toml +1 exclude line, no second store |
| `src/demoer/mod.rs` + `src/lib.rs` + `src/cli/next.rs` wiring | SHIPPED | New module, 11 passing tests, dispatch + advance gate exercised live |
| `scripts/demo-session-template.sh` | SHIPPED | Exists, exit 0, emits all four markers (P18) |
| CONSTRAINTS element + scaffold propagation | SHIPPED | before_after recorded in repo + `vajra init` output; byte-identical template (P19) |
| `scripts/verify-session-71.sh` | SHIPPED | E2E in fresh git fixture; all 41 code checks PASS (P26) |
| `scripts/demo-session-71.sh` | SHIPPED | exit 0, four markers live, real before/after evidence (P27); `--check-demo 71` green (P24) |

**Verdict:** ACCEPT
