# Session 170 — Ground Truth: cut the ceremony, point at the user (S166–S169)

**Type:** NO-CODE, mandatory. **Date:** 2026-09-15. **Branch:** `session-170-closeout`.
**Verdict:** 🔴 **Off course.** Four sessions, $0 spent, ~2 of every 3 changed lines were paperwork, and nobody outside this repo received anything. A stranger's `cargo install vajractl` still gets the 1 August code (798 commits old).

---

## 1. Ceremony count, S166–S169 (live: `gh pr list` + `gh pr view --json files`)

"Product" = `src/` + non-verify `scripts/`. "Paperwork" = `.ai/` records, `sessions/`, `prompts/`, `docs/`, handoffs, verify + demo scripts.

| Session | PR | Commits | Wall time (first commit → merge) | Product lines | Paperwork lines | Paperwork share | Who the product was for |
|---|---|---|---|---|---|---|---|
| S166 | #198 | 6 | ~45 min (PR) | 14 | 529 | 97% | Vajra's own close gate |
| S167 | #200 (+#199, #201) | 22 (+4) | 3h 02m | 772 | 1,427 | 65% | Users (terminal demo kit) |
| S168 | #202 (+#203, #204) | 34 (+2) | 2h 05m | 1,175 | 1,512 | 56% | Half users (demo kit), half the Demo-er gate |
| S169 | #205 | 15 | ~25 min of commits | 261 | 781 | 75% | Vajra's own close gate |
| **Total** | | **83** | S167 + S168 both over the 2h cap | **2,222** | **4,249** | **66%** | 2 of 4 sessions were policing |

Gate overrides used (live grep of the summaries): `VAJRA_CLOSEOUT_WAIVER` (S166, S169) · `VAJRA_SKIP_FIDELITY_GATE` (S167) · `VAJRA_SKIP_CODER_GATE` (S168, S169). **Five overrides in four sessions** — the gates are routinely excused by the people who built them.

**Starting THIS session** took 5 tries of `vajra next --advance`: prompt still DRAFT → prompt missing an `## Acceptance` heading (a NO-CODE audit) → an already-merged branch not deleted → a `[y/N]` prompt → yes. Each try re-ran S169's whole 13-case demo; 313 lines of output to open an audit.

**Which steps changed an outcome?**
- ✅ **The first cold fidelity review, every time.** S166 retro review: REJECT (self-certified close). S168: two real demo dodges found and fixed. S169: a zero-padding bug found and fixed.
- ❌ Everything else only fed a gate: tech-lead dispatch (S167 back-filled one for S166 and the gate still refused), the "obeyed" judge (S168: 25 unjudged dispositions blocked close; one extra dispatch + re-stamping), second review passes (confirmed fixes already made), attestation re-stamping after every late file, the 3-commit closeout.

## 2. Keep / make optional / remove — for a small session (one story, < ~300 product lines)

| Step | Cost seen S166–S169 | Changed an outcome? | Call |
|---|---|---|---|
| One cold fidelity review (fed prompt + diff) | 1 dispatch/session | **Yes, 3 of 4 sessions** | **Keep** |
| Verify script (execute-based checks only) | 282–661 lines/session | Sometimes | **Keep**, but size to the change |
| Mandatory tech-lead dispatch | 4 handoffs; blocked S166's close | No | **Make optional** (big / multi-role sessions only) |
| Separate "obeyed" judge dispatch | S168: 1 dispatch + re-attest | No | **Remove** |
| Advice-answer ledger (every rec answered, named session) | dozens of lines/session in prompts | No | **Remove** for small sessions |
| Second review pass | S168, S169 | No (fixes already known) | **Make optional** — only if pass 1 found a user-facing bug |
| Attestation stamping (`Review-Inputs-SHA`, recomputed on every late file) | re-stamps in S168, S169 | No | **Make optional** |
| Demo deck for a change a user cannot see (bash gate) | S169: 314 verify+demo lines, 13 cases | No | **Remove** — demo only what a user sees |
| `--advance` re-running the prior session's full demo + verify | every advance (5× today) | No | **Remove** (it already ran at close) |
| Analyst gate section names on a NO-CODE prompt | blocked today's start | No | **Make optional** for GT prompts |
| 3-commit closeout bundle | 3 commits × 4 sessions | No | **Remove** → one closeout commit |
| Max 3 files per commit | 0 violations, but 22–34 commits/session | No | **Make optional** (raise the cap) |
| Constitution sections: Obedience Protocol, Carry-Forward Rule, Hollow-Advice Retirement, Handoff Condensation, DOCUMENT verify standard | read every session; shipped to strangers | No | **Remove** from the scaffold; keep only as notes here |

## 3. Release 0.2.0 — what is left (live)

| Channel | Live state | Left to do | Who |
|---|---|---|---|
| GitHub release | `v0.2.0` Latest, 2026-09-14 | Nothing | — |
| Homebrew | tap `ifelse-codes/homebrew-tap` formula says `version "0.2.0"` (**STATE says "unverified" — out of date**) | Run `VAJRA_SMOKE_SOURCE=brew scripts/install-smoke.sh` once | Agent |
| crates.io | **`0.1.0`, 19 downloads** (Cargo.toml says 0.2.0) | `cargo publish` | **Founder types it** (irreversible) |
| crates smoke | not run | `VAJRA_SMOKE_SOURCE=crates scripts/install-smoke.sh` after publish | Agent |
| README | claims crates channel is "published and proven" for v0.2.0 — **false today** | Becomes true after publish (don't soften it — make it true) | Founder → agent |
| Founder's own PATH | `~/.cargo/bin/vajra` = **0.1.0** | `cargo install --path .` | Founder or agent |

## 4. A stranger's first 10 minutes (live: 0.2.0 binary, a one-file git repo)

- `vajra init` — fast (0.08 s) but writes **39 files** into a one-file project.
- `vajra next` on a brand-new init prints **"can't tell yet — this brief predates the team"** four times and "0 of 8 roles have finished" — confusing on day one.
- `vajra check` — first thing they run **fails**: `FAIL on main — branch before working` (Score 10/11).
- The next hint is `vajra claude`. That path has had **no real run since S161** (4 days, 8 sessions).
- And via `cargo install vajractl` they get none of this — 0.1.0 from 1 August (no demo kit).
- Outside signals (live): **0 stars, 0 forks, 0 issues.**

## 5. Parked policing — confirmed

- ROADMAP row **S171 stays parked** (all 4 items). S168 review recs 1–3 stay parked.
- **Retire** (only a cheating agent inside this repo could hit them): S171 (1) `done:` sha ownership · (3) waiver on `execution-shas-filled` · (4) claim-match word dodges · S168 rec 2 (disclosed-floor demo row) · rec 3 (relabel verify-168 greps).
- **Keep parked, cheap honesty fix:** S168 rec 1 — DECISION-010's sentence overstates what the gate proves.
- STATE's backlog carry-forward list (S154-QA, S156–S161 FR recs, Releaser NoBranch, waiver BLOCK paths, init.rs hand-typed lists) → **parked — policing**. Exceptions that a user would feel: D2 inner-session gap (autopilot), Windows, light terminal.

---

## Required audits (short)

| Audit | Verdict | Live evidence |
|---|---|---|
| `vision_alignment` | 🔴 | Vision = "leave your agent working for days and trust the result". S166 + S169 policed Vajra's own paperwork; 66% of lines were paperwork; 0 users. |
| `roadmap_alignment` | 🟡 | The highest-leverage row (`S168-release`) is still half done; S171 correctly parked (uncommitted edit); S170 row still says "DRAFT — 12 audits + 7 inputs". |
| `state_drift` | 🟡 | STATE: "Active PRs: S169 PR" — merged as #205. "brew unverified" — formula is live at 0.2.0. Direction still "MAKE THE FLEET REAL", not the 2026-09-15 "no more policing". Untracked `prompts/00-task-brownfield-onboarding.md` + `01-task-kickoff.md` (a stray `vajra init` here on 2 Sep) and stray HTML files are not mentioned. |
| `knowledge_staleness` | 🟡 | 301 lines; no release facts (crates version, founder-typed `cargo publish`, tap repo name). |
| `constraint_violation_review` | 🟡 | 0 commits over 3 files (checked every commit in #198, #200, #202, #205). S167 (3h02m) and S168 (2h05m) over the 2h cap. 5 gate overrides. S166 + S167 never passed `verify-closeout.sh`. |
| `constitution_review` | 🔴 | Rules now cost more than they protect: five paperwork-about-paperwork sections (table §2), mandatory tech-lead, 3-file commits inflating to 34 commits. The one rule that earns its keep: independent cold review. |
| `cost_review` | 🟢 / 🟡 | $0 paid in all four. The real cost is hours: ~6h of sessions for 2 user-facing features. |
| `dogfood_check` | 🔴 | No real work through `vajra claude` since S161. |
| `dogfood_staleness` | 🟡 | `vajra next --dogfood-age` → last S161, 2026-09-11, 8 sessions / 4 days, cost not captured. STATE has no dogfood line to compare. |
| `pipeline_advance_check` | 🟡 | `--stations`: S166 4/8 · S167 7/8 · S168 7/8 · S169 7/8. Stations pass, but the counter cannot tell a user feature from a gate on gates — S169 scores 7/8 with zero user value. |
| `stranger_check` | 🟡 | `scripts/stranger-check.sh` → **21 passed, 0 failed**. But it builds `target/release` (0.2.0 from source) — **not** what crates.io publishes (0.1.0). It checks exit codes, not whether a newcomer understands what to do (see §4). |
| `scaffold_drift_check` | 🟢 | `scripts/scaffold-drift.sh` → **18 passed, 0 failed**. Same caveat: source, not the published crate. Its own named gap (hand-typed `init.rs` lists) → parked — policing. |

## Meta-check — what this audit misses by design

- **10 of 12 audits measure Vajra governing itself.** None measures ceremony cost, paperwork share, or whether any human outside used it. This report had to count lines by hand.
- **`stranger_check` tests unpublished code.** It can be green while every real stranger gets a 6-week-old binary.
- **The station counter rewards gates.** A session that adds a check on a check scores as well as one that ships a feature.
- **The GT itself is ceremony-heavy:** 5 advance attempts and a full re-run of the previous demo before a no-code audit could begin.

---

## Next session — 3 options, all user-facing

| | Title | Goal | Why pick this | Key risk |
|---|---|---|---|---|
| **A** ⭐ | **Ship 0.2.0 for real** | Founder runs `cargo publish`; agent runs install-smoke for crates, brew and release; README true; founder's own binary updated. | Nothing else reaches anyone until this is done; ~30 min; no new code. | `cargo publish` is irreversible — a bad package stays up (yank only). |
| **B** | **Light mode: cut the ceremony** | Apply table §2 in this repo AND in the `vajra init` scaffold, so a small session = one review, one verify, one closeout commit, no re-run demo on advance. | Every stranger inherits today's ceremony; the founder near-abandoned Vajra over it (S168). | Removing too much loses the one review that catches real bugs — keep it. |
| **C** | **A stranger's first hour, for real** | Run `cargo install vajractl` → `vajra init` → `vajra claude` on an outside repo with a real small task (paid, ≤ $5); fix the top 3 confusions found (check fails on `main`, "predates the team", 39 files). | Measures the product a user actually meets — the thing no audit here measures. | Needs A first, or it tests the old 0.1.0. |

**Recommendation:** **A now** (short, unblocks everything), **then B**, **then C**.

## Founder decision (2026-09-15, in chat)

- **C is the founder's own:** he tests Vajra himself in his other project.
- **From S171 on, sessions are interactive:** he checks, brings input, we write or edit the session prompt together, then work in short loops. S171's prompt is written in that chat from his findings — not drafted ahead by the agent.
- A and B stay on the table for him to call when his testing points at them.

**Found while closing this GT (user-facing, not policing):** `vajra next --advance` rewrote `.ai/SESSION-BOOT.md` by swapping the number only — "Number: 170 — CLOSED. CODE: a session cannot close on made-up evidence … `session-170-review.md`". Any Vajra user's boot file gets the same wrong text. Fixed by hand here; the tool bug is open.

**Closing this GT hit the same ceremony:** `verify-closeout.sh` blocked a no-code audit on a missing tech-lead dispatch, a design-advisor dispatch, a cold review file and an `## Execution` sha list — 4 of its 5 failures. Closing needs `VAJRA_CLOSEOUT_WAIVER=170` (founder) or three dispatches that would change nothing.
