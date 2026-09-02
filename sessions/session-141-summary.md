# Session 141 — Best install + upgrade-in-place: recorded provenance for the fleet render

**Type:** CODE. **Branch:** `session-141-best-install-upgrade`. **Story (1):** give every scaffolded
fleet role file a recorded `vajra-render-sha:` stamp, add the fourth `FleetFileState::StaleRender`, and
make `vajra init --sync-fleet` auto-upgrade an untouched old render while still refusing a user edit.

## Goal achieved? YES.

The S136 floor — *"Vajra cannot tell a stale render from a user edit; both are just bytes that differ"* —
is closed the honest way: by RECORDING the provenance Vajra never wrote, not by inferring it from
git/timestamps (which S136 rightly rejected). A stamped untouched old render now auto-upgrades with no
`--overwrite-drifted`; a hand-edit or unstamped file is still refused.

## Evidence (live, not claims)

- **`verify-session-141.sh` 10/10** (7 execute-based · 2 structural · 1 nested), RESULT: PASS.
- **`fixture-session-141.sh` 8/8** — four states against the REAL binary in a throwaway dir; RRS/EDT
  plants prove the stamp is load-bearing; POS/END positive controls assert a clean exit 0 (S134 bar).
- **457 lib tests** pass (3 new + the classify test rewritten to four states); **fmt + clippy clean**.
- **Independent QA (cold `qa-specialist`):** ran both suites (exit 0), classified all checks (**0 hollow**;
  the 2 structural greps assert architecture, separately execute-tested), and ran a **real falsification**
  — bypassed the `StaleRender` guard → fixture went RED (STA plant, exit 1) → restored, tree clean,
  nothing committed. Handoff: `.ai/handoffs/session-141-qa-specialist.md`.
- **Live proof (demo + verify):** a fresh `--sync-fleet` creates 10 stamped files and is idempotent
  (no mtime churn); a planted stamped older render upgrades EXACTLY it, reported by name + old→new.

## Fidelity map — every numbered acceptance criterion

| # | Acceptance | Status | Evidence |
|---|---|---|---|
| 1 | render carries a round-tripping `vajra-render-sha:` stamp, inert to Claude Code (placement asserted) | **SHIPPED** | `stamp_render`/`strip_render_stamp` exact inverses (`src/fleet/mod.rs`); `render_stamp_round_trips_and_is_inert_for_every_role` asserts stamp in frontmatter, NOT body, per role; live `live-stamp-in-frontmatter-not-body` |
| 2 | `classify_fleet_file` returns FOUR states, pure function, StaleRender = stamp verifies | **SHIPPED** | `FleetFileState::StaleRender` + `render_stamp_verifies(body)` gate (`src/cli/init.rs`); `classify_fleet_file_names_the_four_states` (no fs) |
| 3 | `--sync-fleet` auto-upgrades StaleRender (no `--overwrite-drifted`, reported), refuses Drifted (exit 1); fixture RED for the right reason + clean-exit-0 positive control | **SHIPPED** | `sync_fleet` StaleRender arm; `fixture-session-141.sh` 8/8 (RRS/EDT/POS/END); `sync_fleet_auto_upgrades_a_stale_render...` |
| 4 | fresh `init` → `--sync-fleet` all UpToDate, nothing rewritten; a stamped older render upgrades exactly it — proven LIVE with the real binary | **SHIPPED** | `live-real-dir-round-trip` (mtime-unchanged idempotence + exact-one upgrade); demo CASE 1/2 |
| 5 | `## Design` + DECISION-007 S141 addendum state RECORDED (not inferred) provenance, distinct from the rejected classifier | **SHIPPED** | DECISION-007 S141 addendum (f02ddd3); prompt `## Design` supersede line + content-hash disclosure |
| 6 | verify + demo (4 markers) + summary with full fidelity map + 3 ranked candidates; cold `fidelity-reviewer` ACCEPT | **SHIPPED** | this file; `demo-session-141.sh` (4 markers); cold review → `sessions/session-141-review.md` |

**6 of 6 SHIPPED.**

## What I did NOT build (stated plainly)

- **The stamp is a content hash, not a keyed signature.** Provenance by construction, tamper-EVIDENT not
  tamper-PROOF — a user could forge a stamp by hand. Auto-upgrade is safe for the untouched-render case,
  which is the whole job; it is not cryptographic provenance. Disclosed in `## Design` + the addendum.
- **Legacy unstamped files stay Drifted, NOT StaleRender, on first contact.** Every pre-S141 install
  (chitra's 4 stale renders included) is unstamped; its FIRST upgrade still needs one
  `--overwrite-drifted` (which writes the first stamp). S141 makes upgrades smooth **going forward, not
  retroactively.** This is the exact honest limit the prompt named — not walked past.
- **Non-fleet scaffold files** (constitution, `CONSTRAINTS.yaml`, hooks, kickoff) are still add-only. The
  same stamp pattern can extend to them; out of scope here (1 story).
- **No live agent dispatch is exercised** (qa rec 1). The "stamp inert / dispatch untouched" claim rests
  on stamp PLACEMENT in the frontmatter of one role's output, not on a coding agent actually loading the
  file. The placement guarantee is strong (unknown frontmatter key, stripped before the model sees the
  body); the end-to-end agent-dispatch proof is not in this suite.

## The fakest green

**`live-stamp-in-frontmatter-not-body` (and the whole "dispatch is untouched" claim) is proven by
PLACEMENT, not by a live agent dispatch** (qa-specialist rec 1). The stamp sitting in the frontmatter
block before the closing fence, with a clean body, is a strong structural guarantee that Claude Code —
which parses only known frontmatter keys and strips the block before the body reaches the model — ignores
it. But no test in this session actually dispatches a subagent from a stamped file. **"Claude Code
ignores an unknown `vajra-render-sha:` frontmatter key" is therefore an untested ASSUMPTION, and a known
risk** (fidelity-reviewer rec 2): if a future Claude Code surfaced unknown frontmatter keys, this suite
would not catch it. The placement guarantee is strong, but it is not an end-to-end dispatch proof.
Honestly disclosed, not dressed up.

The reviewer also caught a real hollow green — the demo's acceptance table printed six hardcoded ✔ —
**fixed in-session (rec 3):** each mark is now computed from the live case signals.

## Advice (advisors, answered)

- **tech-lead** bound the crew FIRST: required = design-advisor · qa-specialist · fidelity-reviewer; six
  deferred-budget (money facts under the $20/mo cap, not worth calls). Its 3 process recs: all met (design
  before code · qa at verification · fidelity cold at close).
- **design-advisor** (6 recs): rec 1 affirmed `design-significant: yes`; rec 2/5 landed the addendum +
  content-hash disclosure (f02ddd3); rec 3/6 added the two rejected alternatives + the supersede line to
  `## Design`; rec 4 placed the stamp as a frontmatter key (32d90e9). rec 2/4/5 judged independently by
  the fidelity-reviewer (a different role — the S131 designed pattern).
- **qa-specialist** (3 recs): rec 1 disclosed (no live dispatch — the fakest green above); rec 2/3 accepted
  as honest limits and deferred (own-direction falsification is unit-tested; live layer spot-checks
  researcher; rotating is a future nicety — 1 story).

## Cost

Interactive session; four subagent dispatches (tech-lead, design-advisor, qa-specialist,
fidelity-reviewer), each on a tight named-files brief. No `vajra claude` paid run this session (that is
the next founder priority — a chitra dogfood). Metered $: to be confirmed at close.

## Exactly 3 ranked next candidates (A/B/C)

- **A — chitra dogfood: exercise S141's upgrade path on a REAL brownfield repo (RECOMMENDED).**
  *Goal:* run `vajra claude` inside chitra; its 4 unstamped stale renders classify as Drifted on first
  contact → one `--overwrite-drifted` writes the first stamps → prove the next `--sync-fleet` is smooth.
  *Why:* the founder's #2 completeness priority (S140), and the first real-world test of what S141 built.
  *Risk:* chitra must be left undisturbed (four-ways proof); a paid run breaches nothing if scoped tight.
- **B — extend the render stamp to the non-fleet scaffold files.**
  *Goal:* stamp the constitution, `CONSTRAINTS.yaml`, and hooks so `--overwrite-drifted` is no longer the
  only upgrade path for them either. *Why:* closes the add-only gap for ALL scaffold types. *Risk:* these
  files are edited more often than role files — the stale-vs-edited line matters more; scope creep.
- **C — reviewer-independence self-certification at close (S138B, carried).**
  *Goal:* make the close bind that the fidelity verdict came from an independent pass, not a self-grade.
  *Why:* the oldest open governance gap, ranked next-after since S139. *Risk:* the fleet already deepens
  governance-of-governance while adoption is flat (the S140 direction 🟡) — this adds another inward turn.

**Next GT: S145.**

## Independent cold review

`sessions/session-141-review.md` — cold `fidelity-reviewer`, fed only the prompt + diff. **Verdict:
ACCEPT** (5 of 6 SHIPPED at review time; criterion 6 graded PARTIAL only because the summary post-dates
the review dispatch — its artifact is present at close). All three `obeyed:` dispositions independently
judged `implemented:`. The three reviewer recs are answered above (summary landed · CC-key-tolerance
disclosed as an untested assumption · demo marks now computed).
