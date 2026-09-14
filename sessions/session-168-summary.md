# Session 168 — a demo that cannot be faked

**Date:** 2026-09-14
**Type:** CODE
**Verdict:** ACCEPT — cold fidelity review of record (`sessions/session-168-review.md`, pass 4 of 4): 10 SHIPPED · 3 PARTIAL (AC7, AC12, AC14) · 1 NOT-BUILT (AC13 release). The map below is the builder's; the review is the grade.

---

## Goal achieved?

Yes for the demo work; the release (AC13) waits for the merge and the founder's go.

- `dk_check "label" <command…>` runs the command; its real exit code decides. A bare `PASS`, `FAIL`, digit or no command is **refused by name** and the demo fails. `-q` hides the line, still counts.
- `vajra next --demo-facts NN` prints nine derived facts (stations, review, advice answered, crew) in a fixed order. It reads only — a test proves it runs no script.
- `dk_vajra_tiles NN` / `dk_vajra_scorecard NN` draw those facts, labelled "filled in by Vajra", and print one `demo:fact` line each. `dk_finish` prints `demo:complete` only when the whole outline passed.
- The Demo-er gate: a **kit-built** demo (sources the kit, or prints any kit marker) must print `demo:complete` and every fact, each equal to what the gate derives right after the run. A non-kit demo keeps the old rule, with a warning naming the downgrade (DECISION-010).
- Light theme (`DEMO_THEME=light` or a light `COLORFGBG`); template, S167 demo + verify, and the `demo-producer` brief migrated.

## Evidence

| Check | Result |
|---|---|
| `scripts/verify-session-168.sh` | final code: **102 pass, 1 fail** — the one fail was AC10b (fidelity recs not yet answered at that moment); re-run after `## Advice` below |
| `cargo test --lib` | 509 pass (493 + 16 new) |
| `cargo clippy --all-targets -- -D warnings` · `cargo fmt --check` | clean |
| `DEMO_MODE=stream bash scripts/demo-session-168.sh` | exit 0 · 16 of 16 live checks |
| `vajra next --check-demo 168` / `167` | READY / READY under the new gate |
| `scripts/verify-session-167.sh` (migrated) | 69 pass, 0 fail |
| chitra `--sync-fleet --dry-run` | template `would upgrade`, kit `would create` (chitra never synced S167); HEAD / status / stash identical |

## Fidelity map (builder's — the cold review grades it)

| AC | Builder's claim | Evidence |
|----|----|----|
| AC1 bare tokens refused; command exit code; `-q` counted | SHIPPED | `scripts/demo-kit.sh` `dk_check`; verify AC1a–f; `s168_kit_runs_real_checks_fills_vajra_facts_and_has_a_light_theme` |
| AC2 `--demo-facts` stable, read-only, exit 0 | SHIPPED | `src/demoer/facts.rs`; `demo_facts_never_runs_a_script`; verify AC2a–c |
| AC3 Vajra-filled tiles + scorecard, `demo:fact` per fact | SHIPPED | verify AC3a–c (fact lines equal the binary's output) |
| AC4 gate: `demo:complete` + facts; legacy rule warned; fixtures | SHIPPED | `src/demoer/mod.rs` `demo_report_with`; 5 kit fixtures; verify AC4 rows |
| AC5 design decided on the record | SHIPPED | `docs/decisions/DECISION-010-unfakeable-demo.md`; prompt `## Design` |
| AC6 stranger end to end | SHIPPED | verify AC4/AC6 rows in a fresh `vajra init`; demo rule slide |
| AC7 S167 renders → StaleRender; chitra dry-run untouched | PARTIAL | `s167_stamped_kit_and_template_upgrade_as_stale_renders`; chitra lists the template as upgrade but the kit as **create** — chitra never synced S167, so there is no S167 kit render there to upgrade |
| AC8 light theme, NO_COLOR, boxes at 100/72 | SHIPPED | verify AC8a–e; Rust test |
| AC9 S167 demo + verify migrated, green | SHIPPED | verify AC9a–b |
| AC10 demo-producer dispatched, answered, brief updated | SHIPPED | `.ai/handoffs/session-168-demo-producer.md` (verified dispatch); 14 recs answered; rendered agent file |
| AC11 S168 demo on the kit, S167-kit before, pty deck, gate READY | SHIPPED | verify AC11a–d |
| AC12 tests, lint, stranger, drift, package list; behavioral verify | SHIPPED | verify AC12a–f |
| AC13 release 0.2.0 on three channels | **NOT-BUILT (yet)** | waits for the merge and the founder's go (tech-lead rec 4/5; release-coordinator order in `.ai/handoffs/session-167-release-coordinator.md`) |
| AC14 honest limits stated | SHIPPED | below |

## What I did NOT build, and the honest limits (AC14)

- **Fakest green:** `dk_check "x" true` still passes — a real command is not a meaningful one. The demo's rule slide shows it live.
- **What an author can still fake:** extra hand-drawn tiles beside the Vajra-filled ones (the gate checks the facts, not every number on screen); a hand-typed `demo:fact` line with the **right** value (the gate proves the value, not who drew it); an `echo demo:complete` (satisfies that element and marks the demo kit-built, so every fact must then be printed and true — and a failed or refused check still blocks through `demo:check-failed`).
- **The kit is bash the demo sources:** a determined author can write `DK_SCORES` directly, redefine `dk_check`/`dk_finish` after sourcing, or (clean room on) create during the run the files the facts come from. The gate proves what the output says, not honest use of the kit.
- **What the gate proves, exactly (corrected after cold pass 4):** every `demo:fact` printed is true, and the output carries no `demo:check-failed` line and at least one `demo:check-passed` line. Those markers are printed by the kit, but any author can print them by hand: a demo with **zero** real checks plus a hand-printed `demo:check-passed x` and `demo:complete` closes, and `dk_check "tests" cargo test >/dev/null` then a hand-printed `complete` hides a real failure. So it does NOT prove a check passed or that the outline passed — it proves the facts, and that the kit's own failure lines were not left in the output. (DECISION-010 still carries the stronger sentence → corrected in S169, not here, so the reviewed diff stays as reviewed.)
- **Cold pass 3** found the unfilled-outline + `dk_marker complete` path (zero checks): fixed — `dk_todo` prints `demo:check-failed`, and a kit-built demo needs a `demo:check-passed`; `_dk_facts` failures print `demo:check-failed` too.
- **Two earlier cold passes found two dodges, both fixed in-session:** pass 1 — an indented ` demo:complete` passed as legacy (kit-sign scan made a substring scan); pass 2 — `\033[demo:complete` counted raw but not stripped (every scan now reads the same stripped text), and `dk_marker complete` in place of `dk_finish` rescued a typed PASS (the kit now prints `demo:check-failed`, which blocks).
- **What existing projects get:** after upgrading `vajra` and `vajra init --sync-fleet`, their kit-built demos get the `demo:complete` + fact checks automatically. A demo that drops every kit sign stays on the old four-marker rule (warned by name) **until they add `complete` to `CONSTRAINTS.yaml#demo.required_elements`** — sync never touches that file. New projects scaffold with `complete` already required.
- **Old kit demos break on purpose:** `dk_check "label" 0` / `$_DK_RC` / `PASS` now turn red with a message naming the new form.
- **Cost:** `--demo-facts` on a session with an attested review takes ~10 s (the Reviewer station re-derives the attestation hash); the gate derives once more after the run.
- **Not tested:** Windows (bash kit; WSL untested); a real light-background terminal (escape codes proven, not eyeballed); Linux only via CI Rust tests.
- **Process:** `vajra next --advance` into S168 used `VAJRA_SKIP_CODER_GATE=1` because S167's step 10 (the release) was still pending — the same pending release is this session's AC13.

## Next — three candidates (ranked)

- **A · S169 — tighten the close gate S166 loosened.** Goal: `done:` sha word boundary + 7–40 length + `git cat-file` existence; a claimed review with no review file fails; no close without a recorded tech-lead. Why: founder-named, and the S166 REJECT showed a self-certified close slipping through. Risk: old prompts with odd `done:` lines start failing.
- **B · Release 0.2.0 (if not done at this close).** Goal: GitHub Releases + crates.io + Homebrew so strangers get S167 + S168. Why: founder priority 1 — nobody outside this repo has the demo work until then. Risk: `cargo publish` cannot be undone.
- **C · Prove it works, then cut cost.** Goal: a paid end-to-end run of a real session in chitra through close. Why: founder priority 2, unstarted. Risk: spend, and S170 (mandatory GT) is two sessions away.
