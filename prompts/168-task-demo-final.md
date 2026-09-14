# Session 168 — demo-final: finish the demo work — a demo that cannot be faked, shipped

> **Status:** APPROVED — founder approval token "approved", given in chat on 2026-09-14 after
> reading this text. Founder direction: "I want the demo work to complete full and final —
> finish the demo work."

## Type
- **CODE** (~2h cap · $0 — no paid `claude -p` run). Max 2 assumptions · 2 retries · 1 story ·
  new chat · approval token before any commit.

## Where this came from (read first — this chat starts cold)

- **S167 shipped the terminal demo** (DECISION-009, PR #200): `scripts/demo-kit.sh` draws a
  slide deck; `scripts/demo-session-template.sh` is a seven-section outline that fails when left
  empty; the HTML-deck rule is retired; `vajra init --sync-fleet` carries both files. Cold review
  ACCEPT (10 of 11) — `sessions/session-167-review.md`.
- **What is still fakeable (the S167 fakest green, cold review rec 1):** `dk_check`
  (`scripts/demo-kit.sh:214`) accepts the literal token `PASS`, so `dk_check "anything" PASS`
  counts as a live check that cannot fail. Replace every placeholder with that line and an empty
  deck exits 0 with all four markers. Number tiles are free text too: a demo can type
  `STATIONS|8|of 8` whatever the truth is.
- **What the gate checks today** (`src/demoer/mod.rs`, `demo_gate_with` ~line 231): the demo
  re-runs live, exits 0, and prints the four `demo:` markers (header · cases · summary_table ·
  before_after). It does not know whether the checks ran, whether the numbers are true, or
  whether the demo reached `dk_finish`.
- **What Vajra already knows, read-only** — the facts a demo should never type by hand:
  stations passed (`stations::station_report`, `src/stations/mod.rs:177`), the review verdict
  (`review_verdict_accept`, `src/stations/mod.rs:632`), recommendations answered (`vajra next
  --advice NN`), crew handoffs (`stations::fleet_evidence`, `:132`).
- **Other open demo items from S167:** the new `demo-producer` brief was never run; light-
  background terminals untested; `release-coordinator` recs 3–5 and AC10 (release) waiting —
  ROADMAP row `S167-release`. **Nobody outside this repo has any of the demo work until a
  release ships.**
- **Numbering:** `.ai/SESSION` is 167 (moved by hand by the founder after S166's crew gate could
  not be satisfied). This session opens with `vajra next --advance` → 168.

## Goal
The demo work is finished: every Vajra demo tells the whole story in the terminal, its checks
really run, the numbers Vajra knows are filled in by Vajra, the gate proves all three at close —
and strangers get it in a released version.

## Deliverables
- `scripts/demo-kit.sh`: `dk_check` runs a real command and records its real exit code (no
  bare `PASS`/`FAIL`/digit token); `dk_finish` prints a `demo:complete` marker (non-terminal
  runs) only when the whole outline passed; new `dk_vajra_tiles NN` + `dk_vajra_scorecard NN`
  draw Vajra's facts, marked "filled in by Vajra", and print canonical `demo:fact` lines; a light
  terminal look (`DEMO_THEME=light`, or detected from `COLORFGBG`).
- `vajra next --demo-facts NN` — a flag on the existing command (no 8th command): the session's
  facts in one stable, machine-readable form, derived read-only, running nothing.
- The Demo-er gate (`src/demoer/mod.rs`): for a demo built on the kit, also require
  `demo:complete` and require every `demo:fact` line to equal what the gate derives at close —
  a typed or stale fact blocks, naming the mismatch.
- `scripts/demo-session-template.sh` rewritten for the new calls (headline tiles and scorecard
  use `dk_vajra_*`; examples show `dk_check` with a command).
- `scripts/demo-session-167.sh` and `scripts/verify-session-167.sh` migrated to the new
  `dk_check` form and still green (cumulative demos keep working).
- `demo-producer` brief (`src/fleet/mod.rs`) + its rendered agent file: propose Vajra-filled
  tiles/scorecard and command-backed checks; dispatched for real on this session's demo.
- DECISION-009 addendum (S168) — or a new record if the design-advisor rules the change needs one.
- `scripts/demo-session-168.sh` (on the kit, Vajra-filled facts) · `scripts/verify-session-168.sh`
  (exits 0; behavioral).
- The release: vajractl `0.2.0` (S167 + S168 together) on GitHub Releases, crates.io and the
  Homebrew tap — after merge, on the founder's go.
- `sessions/session-168-summary.md` + exactly 3 ranked next candidates.

## Acceptance (what must be answered — testable, EARS-style)

| AC | Criterion |
|----|-----------|
| AC1 | WHEN a demo calls `dk_check "label" PASS` (or `FAIL`, or a bare digit) THEN the kit refuses it by name and the demo exits non-zero; WHEN it calls `dk_check "label" <command…>` THEN the check's result is that command's real exit code (a failing command → FAIL shown, demo non-zero). `-q` keeps a check off-screen but still counted. |
| AC2 | WHEN `vajra next --demo-facts NN` runs THEN it prints stations passed (K of 8 + names), the review verdict (or "no review"), recommendations answered (N of M), and the crew handoffs, one `key=value` per line in a documented stable order; it runs no verify or demo script (no recursion when a demo calls it during its own gate re-run) and exits 0 even when facts are absent. |
| AC3 | WHEN a kit-built demo uses `dk_vajra_tiles NN` / `dk_vajra_scorecard NN` THEN the tiles and scorecard show exactly the `--demo-facts` values, labelled "filled in by Vajra", and non-terminal output carries one `demo:fact key=value` line per fact. |
| AC4 | WHEN `vajra next --check-demo NN` re-runs a kit-built demo THEN it BLOCKS, naming the reason, if (a) `demo:complete` is missing (the demo never reached a passing `dk_finish`), or (b) any `demo:fact` line differs from the facts the gate derives at that moment (a typed or stale number); a legacy demo that does not use the kit keeps today's four-marker rule, and the warning says so. Proven with fixtures: typed PASS → block · forged fact → block · no `dk_finish` → block · honest filled demo → pass. |
| AC5 | The design question is decided on the record: HOW the gate knows a demo is kit-built and whether `complete`/`fact` join `demo.required_elements` (CONSTRAINTS.yaml is never synced — say what existing projects get and when). |
| AC6 | WHEN `vajra init` runs in an empty directory and the template is copied and filled honestly (real commands, Vajra-filled tiles) THEN `vajra next --check-demo` passes end to end in that stranger directory; WHEN the same demo types a fact or a PASS token THEN it fails. |
| AC7 | WHEN an S167-stamped kit or template exists in a project THEN `vajra init --sync-fleet` upgrades it without `--overwrite-drifted` (a real StaleRender from the S167 render, proven by a test); chitra `--dry-run` lists both as upgrades and chitra is provably untouched (HEAD, status, stash identical). |
| AC8 | WHEN `DEMO_THEME=light` is set (or `COLORFGBG` says the background is light) THEN the kit uses a light-background palette (proven by the escape codes it prints); `NO_COLOR` still prints zero escape bytes; boxes stay straight at 100 and 72 columns. |
| AC9 | `scripts/demo-session-167.sh` and `scripts/verify-session-167.sh` are migrated and both still exit 0; the S167 Rust tests are updated to the new `dk_check` form and pass. |
| AC10 | The `demo-producer` is dispatched for real on this session's demo and its handoff recorded; its recommendations are answered in `## Advice`; the brief (and rendered agent file) now proposes Vajra-filled tiles/scorecard and command-backed checks, still names the four scanned elements, and keeps `tools: Read, Grep, Glob`. |
| AC11 | `scripts/demo-session-168.sh` is built on the kit with Vajra-filled headline tiles and scorecard; its before → after runs the S167 kit out of git (a typed-PASS demo passing then, failing now); it plays as a deck in a pseudo-terminal with scripted keys; `vajra next --check-demo 168` exits 0 under the NEW gate. |
| AC12 | `cargo test --lib` passes (493 + new), `cargo clippy -- -D warnings` and `cargo fmt --check` clean, `scripts/stranger-check.sh` and `scripts/scaffold-drift.sh` green, `cargo package --list` includes `scripts/demo-kit.sh`; `scripts/verify-session-168.sh` exits 0 with every check running the real binary or script and naming the failure it catches. |
| AC13 | WHEN the founder gives the go in chat, after the PR is merged THEN vajractl `0.2.0` is live on GitHub Releases (3 tarballs + sha256), crates.io and the Homebrew tap; `scripts/install-smoke.sh` passes with `VAJRA_SMOKE_RELEASE_TAG=v0.2.0` for `release`, `crates` and `brew` (tap formula, not the in-repo copy); a fresh `vajra init` from the published crate scaffolds `scripts/demo-kit.sh` and its `dk_check` refuses a bare PASS; the README names 0.2.0. If the founder says "not yet", graded NOT-BUILT with that reason — never dropped silently. |
| AC14 | The summary states plainly what a determined author can still fake (e.g. hand-drawn extra tiles beside the Vajra-filled ones, a trivially-true command), what existing projects get automatically vs only after editing CONSTRAINTS.yaml, and what was not tested (Windows). |

## Design (the Architect gate — record the decision, cite the ADR/DECISION it rests on)
- design-significant: yes — the Demo-er gate's logic changes for every Vajra project, the kit's
  `dk_check` contract changes, and `vajra next` gains a `--demo-facts` flag.
- Rests on **DECISION-009** (the terminal demo is the human demo; the kit is a scaffolded helper,
  not a renderer; S168 named as its follow-up) and **DECISION-008** (demo marker enforcement at
  close via `check_demo_markers`).
- Rests on **DECISION-007** S141/S142 addenda: the kit and template are stamped `SYNC_HOOKS`
  targets, so the S167 renders upgrade as `StaleRender` — no new sync machinery.
- Facts are DERIVED, never recorded by the author (the house pattern since S74's payload counter:
  a derived K-of-8, never a self-asserted digit). The gate recomputes them at close and compares.
- Recursion is designed out: `--demo-facts` reads, never runs; a demo calling it inside its own
  gate re-run cannot trigger another run.
- **Open question (AC5) — DECIDED in `docs/decisions/DECISION-010-unfakeable-demo.md`** (design-advisor
  handoff `.ai/handoffs/session-168-design-advisor.md`): a new record, because it overturns
  DECISION-009 §4 ("The gate does not change"); DECISION-009 carries a pointer.
  - Kit-built = the script text sources `demo-kit.sh` OR the live output carries any `demo:kit` /
    `demo:complete` / `demo:fact` line. With no sign, the old four-marker rule applies and the
    warning names the downgrade.
  - `complete` joins `demo.required_elements` in this repo and in the `vajra init` scaffold; the
    built-in default stays four elements; `fact` does not join (detection triggers it). Existing
    projects get the fact + complete checks on kit-built demos after upgrading + `--sync-fleet`;
    non-kit demos stay on the old rule until they edit CONSTRAINTS.yaml.
  - A kit-built demo must print every fact; exact `key=value` match on a closed key list, color
    stripped; facts derived from the folder the demo ran in, with the gate's own binary via `VAJRA_BIN`.

## Crew
- `tech-lead` FIRST (mandatory) — its verdict binds.
- `design-advisor` — required (design-significant: yes); dispatch before step 2.
- `demo-producer` — required: its S167 brief was never run; run it on this session's demo (AC10).
- `fidelity-reviewer` — required; cold, BEFORE merge. Look hardest at AC1, AC4, AC13.
- For the tech-lead to weigh: `implementation-advisor` (the facts format + gate comparison +
  recursion guard) · `qa-specialist` (exec vs hollow checks) · `release-coordinator` (the
  three-channel release; its S167 recs 3–5).

## Plan (ordered steps — cite the acceptance criteria each step covers, e.g. `covers: 1, 3`)
1. Dispatch `tech-lead` first, then `design-advisor`; record the decision (DECISION-009 addendum or new record), including the open question's answer. covers: 5
2. Add `vajra next --demo-facts NN` (derived, read-only, stable order) with unit tests. covers: 2
3. Change the kit: command-backed `dk_check` (refuse bare tokens), `demo:complete` from `dk_finish`, `dk_vajra_tiles` / `dk_vajra_scorecard` with `demo:fact` lines, light theme; Rust tests run it through bash. covers: 1, 3, 8
4. Extend the Demo-er gate: kit-built detection, require `demo:complete`, compare `demo:fact` lines to derived facts; fixtures for typed PASS, forged fact, no `dk_finish`, honest demo, legacy demo. covers: 4
5. Rewrite the template for the new calls; migrate `demo-session-167.sh`, `verify-session-167.sh` and the S167 Rust tests; prove the S167 renders upgrade as `StaleRender`. covers: 7, 9
6. Update the `demo-producer` brief + rendered agent file; dispatch it for real on this session's demo; answer its recs. covers: 10
7. Stranger end-to-end: empty dir → `vajra init` → honest filled demo passes the gate; faked ones fail. Chitra `--dry-run` with the untouched-proof. covers: 6, 7
8. Build `scripts/demo-session-168.sh` (before runs the S167 kit from git) and run `vajra next --check-demo 168`. covers: 11
9. Write `scripts/verify-session-168.sh`; run the full non-regression set. covers: 12
10. Cold `fidelity-reviewer` pass, summary with the honest limits, PR, merge. covers: 14
11. After the merge and the founder's go: release 0.2.0 per the S167 release-coordinator order (separate release PR for the bump, tag that merge, founder types `cargo publish`, tap update, install-smoke ×3, published-crate `vajra init` check). covers: 13

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>
- step 5 — done: <sha>
- step 6 — done: <sha>
- step 7 — done: <sha>
- step 8 — done: <sha>
- step 9 — done: <sha>
- step 10 — done: <sha>
- step 11 — done: <sha>

## Guardrails
- ONE story: finish the demo. No 8th command (`--demo-facts` is a flag on `vajra next`), no new
  crate dependency, no renderer inside the binary, no HTML.
- Facts are derived read-only at the moment they are asked for; `--demo-facts` must never run a
  verify or demo script (a demo calls it during its own gate re-run — recursion must be
  impossible, and a test must prove it).
- A legacy (non-kit) demo must keep passing under today's four-marker rule — old sessions are
  never re-graded; the warning names the downgrade.
- `SYNC_HOOKS` templates stay fill-transparent (no `{UPPER}` tokens); bash 3.2 must work; deck
  mode only when stdin AND stdout are terminals (the gate must never hang).
- `.ai/AGENTS.md` and `.ai/CONSTRAINTS.yaml` are compile inputs (`build.rs`): no stray `{`. Keep the
  hand-typed scaffold twin of `demo:` in `src/cli/init.rs` in step; `scaffold-drift.sh` green.
- A verify line must never hold both `grep` and a `src/*.rs` path (scaffold-drift's hollow-grep
  scan) — write a diff to a file first.
- Commit all handoffs BEFORE computing `--inputs-sha`; never change the prompt or code after the
  cold review (the attestation goes stale).
- Close THIS session properly: tech-lead + every required role recorded from this session's branch,
  `verify-closeout.sh` run on the branch BEFORE merge (S166/S167 lesson — none of it can be made
  up afterwards).
- chitra: `--dry-run` only. Release is a human act: prepare and dry-run it (`cargo publish
  --dry-run`); publish only after the merge and the founder's go. A crates.io publish cannot be undone.
- Max 3 files per commit · ~2h cap. If the cap hits, stop at a clean commit and name the rest —
  never half a gate change, never half a release.
- Darshan every human reply; plain English for the founder.

## Non-goals (named, not dropped)
- Windows (bash kit; WSL works but is untested) — disclosed.
- Proving a check's command is *meaningful* (a trivially-true command still passes) — disclosed
  as the honest floor, not solved.
- S169's close-gate tightening (SHA regex, `git cat-file`, missing-tech-lead-at-close) — its own session.
- `scripts/verify-session-71.sh` / `demo-session-71.sh` stay as history (nothing re-runs them).

## Delta (vs ROADMAP — OpenSpec markers)
- `+` `vajra next --demo-facts NN` — the session's derived facts in one stable form, read-only
- `+` kit `dk_vajra_tiles` / `dk_vajra_scorecard` + `demo:fact` / `demo:complete` markers + a light terminal theme
- `~` kit `dk_check` — runs a real command and records its exit code; bare PASS/FAIL tokens refused
- `~` Demo-er gate — a kit-built demo must reach `demo:complete` and its facts must match what Vajra derives at close
- `~` `scripts/demo-session-template.sh`, `demo-session-167.sh`, `verify-session-167.sh`, `demo-producer` brief — migrated to the new calls
- `~` `vajractl` `0.1.0` → `0.2.0` on GitHub Releases, crates.io and Homebrew (S167 + S168 together)
- `-` the typed-PASS live check and hand-typed station/verdict numbers in demos
