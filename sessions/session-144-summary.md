# Session 144 — the chitra FULL-LOOP dogfood: upgrade (roles+hooks+constitution) then govern a build, end to end

**Type:** CODE-adjacent dogfood (Vajra-side artifacts = `scripts/verify-session-144.sh` + this summary + a hand-patch to chitra's stale close-gate). The paid work ran INSIDE chitra as a native chitra session.
**Verdict (this write-up):** the upgrade loop + governance were proven end-to-end on a real brownfield adopter; the build closed GREEN with the required crew bound; two structural findings were surfaced that the repo could not have written itself. The founder deferred the chart's *aesthetic* sign-off to a captured design session.

## Two audiences

### A — The founder's build verdict (chitra)
`horizontalBar` — the last chart family not locked to chitra's reference language — was locked by chitra's OWN governed fleet: dashed panel, `VALUES` eyebrow, `+`/`│` value-axis guide + ticks, rule separators, per-item values, **one accent hue (`#8B7CF6`) spent once on the peak bar**, grey tone ramp elsewhere, **no `░` phantom fill**, auto-scale, panel auto-width, and a `n · min · max · avg · peak` summary. 217/217 core tests (+25), accent-count==1 verified at raw-RGB. **The founder SAW the render and judged it correct-to-spec but "too solid" — preferring the S18 heatmap's textured/braille density look.** Because the flatness is inherited from the S12 *bar-lock reference* (solid `█`), this is a reference-level design decision, not a build defect. **Founder's call: accept S144; capture the redesign** (move the whole bar family — bar/horizontalBar/histogram — to a textured fill together) as its own design-advisor-led chitra session. Recorded in memory (`chitra-bar-family-textured-fill`) + a spawned chitra task.

### B — What Vajra's governance actually did
- The SINGLE installed binary (`vajra 0.1.0`, S143 build) upgraded chitra's stale `.ai/` — 10 role renders + 6 hooks + the boundaryless constitution — under one command, preserving chitra's filled constitution header **byte-for-byte**.
- Inside chitra, the SessionStart boot fired, chitra's **tech-lead was dispatched FIRST** (unprompted by role), and its `required` verdict **BOUND at close**: 4 roles marked `required`, all 4 produced real governed handoffs, `verify-closeout.sh` went GREEN including the `required-crew` gate. The S138 "required ≠ required" gap held CLOSED in the wild.
- Commits were gated by chitra's real L2 git hook + L3 PreToolUse commit-guard (marker in the launch env, max-3-files, no-main); nothing was committed to chitra `main`.

## Fidelity map (every acceptance criterion → evidence)

| # | Criterion | Verdict | Evidence |
|---|---|---|---|
| 1 | First `--sync-fleet` classifies first-contact state | SHIPPED | `0 created, 0 upgraded, 0 refreshed, 0 already current, 16 drifted, 1 needs-boundary` — 10 roles + 6 hooks DRIFT (unstamped legacy → not StaleRender, the honest S141 limit), constitution `needs-boundary`; tool refused + printed the sentinel |
| 2 | Migration preserves the filled header byte-for-byte | SHIPPED | header above sentinel = 572 bytes, sha256 `1a318f46…` identical BEFORE and AFTER `--overwrite-drifted`; only the governed body rewritten |
| 3 | Second `--sync-fleet` all UpToDate, 0 churn | SHIPPED | `0 created, 0 upgraded, 0 refreshed, 17 already current, 0 drifted, 0 needs-boundary` — smooth going forward for all three classes |
| 4 | Govern a real build to a GREEN close; crew binds | SHIPPED | `verify-closeout.sh 19` = ALL GREEN 13/13 incl. `required-crew PASS`; tech-lead marked 4 required (implementation-advisor · qa-specialist · demo-producer · fidelity-reviewer), all 4 handoffs recorded, verdict `READY`; horizontalBar locked, 217/217 tests, raw-RGB accent-once |
| 4b | Founder signs off on the built artifact (seen, not read) | PARTIAL | founder SAW the render and accepted the dogfood; **aesthetic sign-off DEFERRED by founder choice** to a captured bar-family redesign session (governance goal met; taste is a separate reference decision) |
| 5 | chitra undisturbed four ways | SHIPPED | main HEAD `8945ce4…` + tree `fa094276…` identical to baseline; 2 stashes intact; all work isolated on `session-19-horizontalbar-lock` (17 commits) |
| 6 | verify script + summary + cold fidelity ACCEPT + honest receipt | SHIPPED | `scripts/verify-session-144.sh` (this file's checks) + this summary + wrapper `fidelity-reviewer` ACCEPT; receipt below |

## The two structural findings (the dogfood's real prize)

1. **`vajra init --sync-fleet` does NOT propagate `scripts/verify-closeout.sh`.** `sync_targets()` covers only the 17 pure-render fleet files (roles + hooks + constitution body); the close-gate is shipped once at `vajra init` via `include_str!` and never updated. A brownfield adopter's closeout is frozen at adopt-time — chitra's was pre-S139, so it never received `check_required_crew` via the upgrade loop. (The S136 "skip-if-present cannot update" lesson, recurring for a non-fleet file.)
2. **The canonical gate hardcodes `BIN="target/release/vajra"`** (Vajra's own Rust build output). A non-Rust adopter (chitra is TypeScript) has no such path, so the three binary-backed gates (crew / obeyed / design-mandate) can never run there — even from a fresh scaffold. Fix: resolve the installed `vajra` on PATH.

**Workaround used (disclosed, not hidden):** chitra's `verify-closeout.sh` was hand-patched to add `check_required_crew` with `BIN` resolved via `command -v vajra`. This let criterion 4's crew-binding be genuinely exercised, but it is a manual step, not the loop doing its job. Follow-up Vajra session spawned (make the close-gate reach adopters, and stop assuming Vajra's build path).

## Receipt (honest, per run mode)

- Run mode: **headless** `vajra claude -p --output-format stream-json` (founder's choice — authoritative `$`, no approval flow, per S134/S138).
- **Authoritative cost: `$11.742472`** · 129 turns · 25.4 min. The stream `is_error:true` was a session-limit **429 that hit AFTER all work was committed**, not a work failure (independent re-run of `verify-closeout.sh 19` = ALL GREEN).
- **RAW subagent tokens: 875,548** (input 104 · output 20,935 · cache-read 636,247 · cache-write 218,262) across 5 dispatches — **~22× tighter than S134's 19.2M** (named-files budgets held). NOT the new-tokens-only figure (21,039), which S134 warns against.
- Two prior launches cost **$0** each (expired-OAuth 401 before any API work); fixed by an interactive `claude` re-login.

## Governance used (wrapper session, Vajra repo)
- tech-lead FIRST → required set {design-advisor, qa-specialist, fidelity-reviewer}; 5 deferred-budget. design-advisor confirmed `design-significant: no` (cites DECISION-007 S141/S142/S143 addenda). qa-specialist + fidelity-reviewer at close.

## What did NOT happen / disclosed limits
- The crew gate reached chitra only via a MANUAL patch (findings 1+2) — the loop itself still leaves the close-gate behind.
- Legacy roles classify DRIFT not StaleRender (unstamped pre-S141) — expected, the disclosed S141 limit met in the wild.
- The chart's aesthetic is unblessed; the bar-family textured redesign is captured, not done.
- chitra `main` was never merged into — the dogfood build lives on `session-19` for the founder to keep/merge/discard.

## Fakest green — found by BOTH wrapper reviewers, closed in-session
The cold `fidelity-reviewer` and the `qa-specialist` independently named the same fakest green: `verify-session-144.sh` C1 + C6 were **self-greps of this author-written summary** (they'd pass with the dogfood deleted), and C5 enforced only 2 of the 4 undisturbed ways. All three were strengthened in-session: **C1** now asserts, via live git, that chitra `main`'s constitution is the boundaryless pre-S143 state; **C6** now asserts both findings against the REAL Vajra source (`sync_targets()` excludes `verify-closeout.sh`; the gate still hardcodes `BIN="target/release/vajra"`); **C5** now checks all four ways (HEAD, tree, stash-count, no-S19-on-main). One qa rec was refused with reason: C4-body-correctness is already implied by C3's 0-churn re-sync (a garbage body would classify Drifted, not "already current").
