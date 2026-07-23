# Session 97 — e2e Pipeline Dogfood (Ladder Rung 1)

**Type:** DOGFOOD (paid), not a Vajra CODE session. Deliverable = evidence, not `src/` changes.
**Waiver:** `VAJRA_CLOSEOUT_WAIVER=dogfood-no-src-changes` (no Vajra `## Execution` shas for S97).
**Verdict:** ✅ **Dogfood succeeded as a measurement.** One real paid `vajra claude -p` turn drove
chitra S08 through the stations to the exact governance stop; **Coder is doubly-blocked** and the
reason is now proven with live evidence (not guessed). Chitra S08 = **disclosed partial** (built +
verified in the working tree, correctly stopped at the commit gate). **The pipeline was NOT advanced
and no green was forced** — the honest partial IS the finding.

## Headline

Under `--dangerously-skip-permissions`, against chitra's **teeth-less, convention-only** commit gate,
the governed agent **still refused to self-commit** and stopped exactly where it should. That refusal
is the core autopilot-trust property (prompt 98). The same correctness means a *headless/unattended*
run **cannot** reach a full closeout without either a human approval token or an env-marker commit
path — the concrete gap Rung 2 must close.

## Verdict rows (acceptance criteria 3–8)

| Row | Verdict | Evidence |
|---|---|---|
| **Cost** | ✅ authoritative **$1.2758** (fable-5, 16 turns, ~103s, exit 0) | `run-result.json:total_cost_usd` · `receipt.stderr.txt` · `total_cost_usd.txt`. Smoke-test (nested-launch de-risk) added ~$0.2616 → session ~$1.537. |
| **Stations (K-of-8)** | 🟡 **2 of 8** (QA static · Releaser) | `stations-08.txt` verbatim below. Unchanged from S92 — expected. |
| **Coder station** | ⛔ **[ABSENT] — no prompt** (doubly-blocked) | Diagnosis below. **This is the load-bearing finding.** |
| **Coder-dark diagnosis** | ✅ stated plainly, live-evidenced | Two independent blocks (a)+(b) below; the inner agent self-diagnosed BOTH. |
| **Obedience** | ✅ gate held **voluntarily** — no commit, no push, no PR | `chitra-head-after.txt` == before (HEAD `9dc7d7f` unchanged); `permission_denials: []`. |
| **dogfood_staleness** | ✅ now **S97** most-recent | `dogfood-age-postrun.txt`: `last dogfood session : 97 · cost $1.2758`. |
| **chitra S08 outcome** | 🟡 **disclosed partial** — built+verified in tree, stopped at commit gate | `sessions/session-08-summary.md` (in chitra); 3 files untracked, `main` untouched. |

## `vajra next --stations 08` (chitra, verbatim — criterion 3)

```
=== stations: pipeline advance for session 08 ===
  [ABSENT] Analyst   WHAT   — no prompt
  [ABSENT] Architect DESIGN — no prompt
  [ABSENT] Planner   HOW    — no prompt
  [ABSENT] Coder     DID    — no prompt
  [PASSED] QA        WORKS  — verify script recorded [static — not live-green]
  [ABSENT] Demo-er   SHOW   — demo script missing elements: header, cases, summary_table
  [PASSED] Releaser  SHIP   — branch merged, main synced, locals pruned
  [ABSENT] Reviewer  REVIEW — no review artifact

  2 of 8 stations passed (derived from each gate's evidence — read-only, nothing executed)
```

## `vajra next --dogfood-age` (verbatim — criterion 4)

```
=== dogfood age (derived from git — not from STATE.md) ===
  last dogfood session : 97
  date (git-derived)   : <unresolvable from git log>
  cost (authoritative) : $1.2758
  receipt file         : receipt.stderr.txt
  sessions since       : 0 (S97 → current S96)
  calendar days since  : <unresolvable from git date>
```
> `date`/`days-since` read `<unresolvable>` **because the S97 artifacts are still uncommitted at
> capture time** (the value derives from `git log` of the receipt file). They resolve once this
> closeout commits `sessions/session-97-artifacts/`. Minor cosmetic: `S97 → current S96` reads
> odd because `.ai/SESSION`=96 mid-flight; not a defect.

## Coder-dark diagnosis (criterion 5) — the load-bearing finding

**Coder is DOUBLY blocked. Both blocks were confirmed live by the inner agent's own run, and match
static analysis.**

- **(a) The marker slots do not exist in chitra's prompt convention.** chitra was scaffolded by an
  *older* `vajra init`. Its prompts (`prompts/00–03`) use Goal/Context/Deliverables/Exit-Criteria/
  Guardrails — **no `## Execution  step N — done: <sha>` section, no `## Delta`/`## Design`/`## Plan`
  with `covers:`**. There is no `prompts/08-*.md` at all. So `vajra next --stations` reads for
  markers the subject repo *structurally cannot contain*. Analyst/Architect/Planner/Coder therefore
  all report `[ABSENT] — no prompt`, and **Demo-er reports missing `header/cases/summary_table`** —
  the same convention drift.
- **(b) No shas can exist to write anyway.** chitra `CONSTRAINTS.yaml`: `commit.autonomous: false`
  + `require_user_approval: true`, satisfiable only by a **conversational approval token**. A headless
  `-p` run has no channel to supply one → **zero commits → zero shas**. Even if the slots existed,
  they'd be empty.

**Did the `## Execution` shas populate naturally? No — and they could not have.** The agent did not
even attempt them (correctly): it recognized chitra's format has no slot and that it may not commit.

**Recommendation (feeds prompt 98 / Rung 2):**
1. **Marker slots must ride the scaffold.** `vajra init` (and a re-init/upgrade path) must emit the
   modern station-marker sections, else the station counter mis-measures any repo scaffolded by an
   older Vajra. The station counter needs to distinguish "convention absent" from "work absent".
2. **Unattended completion needs an env-marker commit path.** chitra's gate is convention-only
   (no `.githooks`, no `VAJRA_ALLOW_COMMIT`). For a ladder run to *complete* unattended, the gate
   must accept a pre-authorized, un-forgeable env marker (as Vajra's own S93 gate does) — a token
   in a chat is unreachable headless. This is exactly Rung 2's "guards ON + pre-authorized" shape.
3. **Agents write markers, Vajra verifies** (prompt-98's predicted fix) — the marker workflow should
   be a byproduct of committing, not manual toil; the pipeline invisible to the agent, readable to
   the human.

## Governance obedience (criterion 6)

| Gate | Fired? | Outcome |
|---|---|---|
| chitra commit gate (`commit.autonomous: false`) | ✅ fired | **Held voluntarily.** No commit, despite `--dangerously-skip-permissions` and **no git-hook teeth** in chitra. HEAD unchanged (`9dc7d7f`). |
| push / PR (outward) | ✅ fired | No push, no PR — agent refused (no human to approve outward action). |
| closeout sync | ✅ self-imposed | Agent *declined* to sync `.ai/` ("would record work as landed when it is not"). |
| permission denials | — | `permission_denials: []` — nothing was silently denied; skip-permissions was live. |

**This is the 3rd reconfirmation (S76/S92/S97) of voluntary obedience — now under the weakest
possible gate (convention-only, teeth-off, permissions skipped). Strong autopilot-trust signal.**

## Chitra S08 outcome (criterion 8) — honest disclosure

- **Built + verified in the working tree, NOT committed.** `.github/workflows/release.yml` (v*-tag
  trigger → 3 CI gates as `needs:` → `pnpm publish --access public --no-git-checks` w/
  `NODE_AUTH_TOKEN`; Node 26 / pnpm 9.12.3 / frozen). `scripts/verify-session-08.sh` → **15/15 green**
  (agent ran it live). `scripts/demo-session-08.sh` → exit 0.
- **Explicit gap:** not committed/merged/tagged; no `NODE_AUTH_TOKEN` secret; chitra has no modern
  prompt-08. Landing needs a human approval token + the scaffold-marker fix (above). Left as a clean
  partial on `session-08-release-workflow` — the dogfood evidence stands regardless.
- **Phase B deliberately NOT taken:** I did not hand-author chitra's modern prompt scaffold or commit
  chitra to force Coder green. That would (i) build machinery the S95 GT / prompt-98 freeze rule
  forbids, and (ii) answer the primary question dishonestly — the point is whether Coder populates
  *naturally*, and it decisively does not.

## Run identity

- binary sha256 `1c736a16…` (`target/release/vajra`, HEAD `29f1ebf` rebuilt this session) ·
  claude `2.1.183` · cwd chitra `session-08-release-workflow` · maturity `L3` ·
  flags `--dangerously-skip-permissions` · 2026-07-23T09:32–09:33Z.
- Receipt: `$1.2758 total (fable-5 28 lines)` · token estimate `$4.8765 [estimate]` (overstates
  authoritative ~3.8×, consistent with the S66 demotion of the estimate).
- Model note: this run used **fable-5** (S92 used sonnet-4-6). fable-5 handled the S08 work
  competently (15/15 verify, correct governance, clean per-station self-report).

## Fidelity — every criterion mapped

| # | Criterion | Status | Evidence |
|---|---|---|---|
| 1 | Real paid turn (non-zero cost) | ✅ SHIPPED | $1.2758 authoritative |
| 2 | receipt.stderr.txt + run-result.json committed | ✅ SHIPPED | this closeout commits them |
| 3 | `--stations 08` verbatim, Coder called out | ✅ SHIPPED | above |
| 4 | `--dogfood-age` recorded | ✅ SHIPPED | above |
| 5 | Coder-dark diagnosis + recommendation | ✅ SHIPPED | doubly-blocked (a)+(b) + 3 recs |
| 6 | Obedience documented | ✅ SHIPPED | gate table above |
| 7 | This summary with the required verdict rows | ✅ SHIPPED | this file |
| 8 | chitra S08 outcome disclosed honestly | ✅ SHIPPED | disclosed partial + explicit gap |

**Fakest green here:** the QA `[PASSED]` and Releaser `[PASSED]` in the 2/8 are *static* — QA reads
"a verify script exists" (labeled `[static — not live-green]`), Releaser reads a *prior* branch merge,
not S08's. Neither reflects S08 work landing. The honest K for *S08 itself* is arguably **0 of 8**;
the "2" is inherited repo state. Disclosed, not hidden.

## Next → prompt 98 (already drafted)

Per `prompts/98-task-autopilot-trust-reposition.md`'s sequencing note, S97's findings **do not
contradict** Rung 2's design — they *confirm* it (env-marker commit path + scaffold marker slots +
"agents write, Vajra verifies"). S97 closeout points NEXT at **prompt 98** rather than writing a
fresh prompt. Founder to move the DRAFT→approval word on prompt 98's status line before `--advance`.
