# Session 167 — rich-terminal-demo: every Vajra demo plays as a rich story, in the terminal

> **Status:** APPROVED — founder approval token "approved", given in chat on 2026-09-14 after
> reading this text. The scope is the founder's own list: "the kit, the rich outline, the new
> rules, the updated helper, and adding the demo files to the sync list. Then release a new
> version." Renumbered 168 → 167 after approval, with no content change: `vajra next --advance`
> opens `.ai/SESSION` + 1.

## Type
- **CODE** (~2h cap · $0 — no paid `claude -p` run). Max 2 assumptions · 2 retries · 1 story ·
  new chat · approval token before any commit.

## Where this came from (read first — this chat starts cold)

- **What the founder saw.** Coding agents (zcode, freebuff) asked for a session demo in chitra
  made HTML slide decks: `/Users/suman/playground/chitra/design-reference/session-21-demo.html`,
  `session-22-demo.html`, `session-25-demo.html`. Their richness is the OUTLINE, not the HTML:
  a headline + number tiles + a one-breath verdict · the story · real before → after renders side
  by side · the rules in plain words · odd-input cases · a scorecard with honest notes · what's
  next · a small-words helper.
- **What the founder wants.** That information and visual richness **in the terminal**, produced
  by the demo itself, for Vajra and for every project that uses Vajra.
- **Cause (verified 2026-09-14).** The template (`scripts/demo-session-template.sh`) asks for
  four marker words and gives three one-line helpers; drawing aligned boxes by hand in bash is
  hard (bash 3.2, the macOS default, counts bytes, not characters, unless the locale is UTF-8).
- **Root cause.** Vajra's own rules split the demo in two — "this bash script is for CI/verify;
  when the user asks, present an interactive HTML slide deck" — in the template note (lines
  15–17), `.ai/AGENTS.md` step 5, and `.ai/CONSTRAINTS.yaml#demo` (`presentation:
  interactive_html` + `presentation_rules`); the `src/demoer/mod.rs` header says the same.
  Projects scaffolded by `vajra init` receive the rule only through the template note (their
  constitution step 5 and scaffolded `demo:` section carry no HTML rule) — which is exactly why
  zcode and freebuff made HTML.
- **Limit, not this session.** The Demo-er gate checks exit 0 plus the marker words
  (`demoer::missing_elements`), so a thin demo still passes → S168.
- **A working prototype exists — local and gitignored; never commit it, never reference its path
  from a committed script:** `sessions/session-167-artifacts/prototype/` — `demo-kit.sh` (the
  kit), `demo-deck-166.sh` (S166's demo redone as a 7-slide terminal deck; every panel is a live
  command; its "before" runs the pre-S166 close gate straight out of git at `6c4d2b0`), `scan.py`
  (box-straightness checker), `ansi2html.py` + `deck-preview.html` (pictures of one run).
  Tested on macOS bash 3.2.57: 7 slides, 9 of 9 live checks, all four `demo:` markers present when
  not in a terminal, boxes straight at 100 and 72 columns, `NO_COLOR` = zero escape bytes, deck
  keys driven in a pseudo-terminal, early quit says "stopped" not "complete". Testing found and
  fixed two prototype bugs (clipped table labels; a false "complete" on early quit). **Not
  tested:** Linux, light-background terminals, Windows, and the real `vajra next --check-demo`
  gate on a kit-built demo.
- **Numbering.** The number 167 was first used by an ungoverned adhoc fixes merge (`fab1b79`;
  commits `872ba7f`, `24e13b2`) that never advanced `.ai/SESSION` (still 166) and has no prompt,
  summary, verify or demo script. This governed session takes 167 because `vajra next --advance`
  opens `.ai/SESSION` + 1. Two branches now share the `session-167-` prefix — the old one survives
  as `origin/session-167-adhoc-fixes` (merged). S168 = the founder-named follow-up. S170 = the
  mandatory NO-CODE Ground Truth.

## Goal
Every project that uses Vajra — this repo included — gets demos that tell the whole story in the
terminal, from the version people actually install.

## Deliverables
- `scripts/demo-kit.sh` — the drawing kit, hardened from the prototype; embedded and scaffolded
  by `vajra init`.
- `scripts/demo-session-template.sh` — rewritten as the rich deck outline on the kit.
- The new rules — the terminal demo IS the human demo — in the template note, `.ai/AGENTS.md`
  step 5, `.ai/CONSTRAINTS.yaml#demo`, the scaffolded constitution and `demo:` section in
  `src/cli/init.rs`, and the `src/demoer/mod.rs` header comment.
- The `demo-producer` brief (`src/fleet/mod.rs`) proposes the full outline; its rendered agent
  file re-synced in this repo.
- `src/cli/init.rs`: the template and the kit join `SYNC_HOOKS` (stamped); `Cargo.toml`
  un-excludes `scripts/demo-kit.sh`.
- A new decision record in `docs/decisions/` (next free number).
- `scripts/demo-session-167.sh` — the first real demo built on the kit.
- `scripts/verify-session-167.sh` (exits 0; behavioral).
- The release: the next version (proposed `0.2.0`) on GitHub Releases, crates.io and the Homebrew
  tap — after merge, on the founder's go.
- `sessions/session-167-summary.md` + exactly 3 ranked next candidates (S168 first).

## Acceptance (what must be answered — testable, EARS-style)

| AC | Criterion |
|----|-----------|
| AC1 | WHEN `vajra init` runs in an empty directory THEN `scripts/demo-kit.sh` exists; AND a sample deck sourced from it, run under `/bin/bash` with no terminal, exits 0 with every box straight at widths 100 and 72, and prints zero escape bytes under `NO_COLOR=1`. A Rust test runs the embedded kit through bash, so CI checks Linux as well as macOS. |
| AC2 | WHEN the new template is copied to a session demo and run unedited THEN it exits non-zero and names each unfilled section (an empty outline cannot pass as a demo); WHEN every section is filled THEN it exits 0 and its non-terminal output carries all four `demo:` elements. Outline = headline + number tiles + one-breath verdict · the story · before → after (live) · the rule in plain words · cases (live) · scorecard (live vs recorded, honest notes, what the demo does not show) · next + small-words helper. |
| AC3 | WHEN `vajra init` scaffolds a project THEN neither its demo template nor its constitution tells the agent to make an HTML slide deck, and both say the terminal demo is the human demo; this repo's `.ai/AGENTS.md` step 5 and `.ai/CONSTRAINTS.yaml#demo` say the same (`interactive_html` retired); AND the scaffolded `.claude/agents/demo-producer.md` proposes every outline section, still names the four scanned elements, and still has `tools: Read, Grep, Glob`. |
| AC4 | WHEN `vajra init --sync-fleet` runs THEN (a) a fresh scaffold reports the template and the kit `UpToDate`; (b) a missing kit is created; (c) a stamped older render of either file is upgraded without `--overwrite-drifted`; (d) a copy Vajra cannot prove untouched, or a hand-edited copy, is REFUSED with the exact flag named — never silently overwritten; `--dry-run` writes nothing. |
| AC5 | WHEN `vajra init --sync-fleet --dry-run` runs inside chitra with this session's binary THEN it lists the template and the kit with their real states, AND chitra is provably untouched (`HEAD`, `git status --porcelain`, `git stash list` identical before and after). |
| AC6 | `scripts/demo-session-167.sh` is built on the kit with every section filled; its before → after runs the pre-session template out of git history (a real before); it plays as a deck in a pseudo-terminal with scripted keys; AND `vajra next --check-demo 167` exits 0 with the Demo-er gate's logic unchanged (header comment only). |
| AC7 | The new decision record states: the terminal demo is the human demo; the kit is a scaffolded helper the demo script calls, not a Darshan renderer; the rejected alternatives with reasons (keep agent-made HTML · a renderer inside the binary · Vajra-built slides now); and it names S168. |
| AC8 | `cargo test --lib` passes (487 + the new tests), `cargo clippy` and `cargo fmt --check` are clean, `scripts/stranger-check.sh` and `scripts/scaffold-drift.sh` are green, and `cargo package --list` includes `scripts/demo-kit.sh` (a published crate can still build). |
| AC9 | `scripts/verify-session-167.sh` exits 0; every check runs the real binary or script (no source-proximity greps); each check names the failure it would catch. |
| AC10 | WHEN the founder gives the go in chat, after the PR is merged, THEN the next version is live on GitHub Releases (3 tarballs + sha256), crates.io and the Homebrew tap; `scripts/install-smoke.sh` passes with `VAJRA_SMOKE_SOURCE=release`, `crates` and `brew`; a fresh `vajra init` from the published crate scaffolds `scripts/demo-kit.sh`; the README names the new version. If the founder says "not yet", this is graded NOT-BUILT with that reason — never dropped silently. |
| AC11 | The summary states plainly: a lazy agent can still fill the outline thinly and pass (S168's job); which existing projects need `--overwrite-drifted` and why; that crates.io and Homebrew users get this only by upgrading; and what was not tested. |

## Design (the Architect gate — record the decision, cite the ADR/DECISION it rests on)
- design-significant: yes — the demo contract every Vajra project inherits changes (a new
  scaffolded file, a rewritten template, the `interactive_html` rule retired), and the
  `--sync-fleet` target set widens.
- Rests on **DECISION-007** (agent fleet) and its upgrade-path addenda: S136 (`--sync-fleet`),
  S141 (the render stamp — `StaleRender` auto-upgrades; an unstamped file stays `Drifted`), S142
  (stamped shell scripts join `SYNC_HOOKS`), S143 (the constitution body; `CONSTRAINTS.yaml`
  deliberately never synced). The kit and the template join `SYNC_HOOKS` the way the hooks did —
  no new sync machinery, no new file state.
- Rests on **DECISION-008** (demo marker enforcement): the four `demo:` elements and the Demo-er
  gate stay as they are. The kit's section functions emit each marker where that section really
  renders, and only when not in a terminal — which is how the gate runs a demo.
- Why a scaffolded bash kit and not a renderer inside the binary: the demo script stays the ONE
  source (the gate re-runs exactly what the human watches), no 8th command, no new dependency, and
  a project's demo keeps working with whatever `vajra` it has installed. The rejected alternatives
  go in the new decision record (step 1).
- Darshan stays a skill (`darshan/SKILL.md` unchanged): Darshan is how the agent talks; the kit is
  a helper the agent's demo script calls.
- An unfilled outline must FAIL (AC2): a pretty empty deck would be a worse hollow green than
  today's plain log.
- **Open question for the design review — decide it on the record.** Every existing project's
  template is unstamped (it was scaffolded with `fx`, not `fxs`), so under today's rules every
  existing project needs one `--overwrite-drifted` — and that flag also overwrites any OTHER
  drifted file the user customised. Either accept that and disclose it, or treat an exact byte
  match with a template Vajra itself once shipped as a provable old render.

## Crew
- `tech-lead` FIRST (mandatory) — its verdict binds.
- `design-advisor` — required (design-significant: yes); dispatch it before step 2.
- `fidelity-reviewer` — required; cold, BEFORE merge.
- For the tech-lead to weigh: `implementation-advisor` (the `SYNC_HOOKS` change, stamping,
  fill-transparency, packaging) · `demo-producer` (run its NEW brief on this session's own demo) ·
  `release-coordinator` (the three-channel release order, and the shared `session-167-` prefix) ·
  `qa-specialist` (exec vs hollow checks in the verify script).

## Plan (ordered steps — cite the acceptance criteria each step covers, e.g. `covers: 1, 3`)
1. Dispatch `tech-lead` first, then `design-advisor`; write the new decision record in `docs/decisions/`, including the open question's answer. covers: 7
2. Harden the prototype kit into `scripts/demo-kit.sh`; add a Rust test that runs the embedded kit through bash and checks straight boxes and no-color output. covers: 1
3. Rewrite `scripts/demo-session-template.sh` on the kit as the rich outline, where any unfilled section fails by name. covers: 2
4. Change the rules — template note, `.ai/AGENTS.md` step 5, `.ai/CONSTRAINTS.yaml#demo`, the scaffolded constitution and `demo:` section in `src/cli/init.rs`, the `src/demoer/mod.rs` header — and update the `demo-producer` brief in `src/fleet/mod.rs`, re-rendering its agent file. covers: 3
5. In `src/cli/init.rs`, scaffold the kit and move the template and the kit onto `SYNC_HOOKS` (stamped); add `!scripts/demo-kit.sh` to `Cargo.toml`; test Missing, UpToDate, StaleRender and Drifted. covers: 4, 8
6. Run `vajra init --sync-fleet --dry-run` inside chitra with the new binary; record the output and the untouched-proof. covers: 5
7. Build `scripts/demo-session-167.sh` on the kit (the before runs the old template out of git) and run `vajra next --check-demo 167`. covers: 6
8. Write `scripts/verify-session-167.sh` and run the full non-regression set (tests, clippy, fmt, stranger-check, scaffold-drift, `cargo package --list`). covers: 8, 9
9. Cold `fidelity-reviewer` pass on the branch, write the summary with the honest limits, open the PR and merge. covers: 11
10. After the merge and the founder's go: bump the version, tag, publish to crates.io, update the Homebrew tap, update the README, and run `install-smoke.sh` for each channel. covers: 10

## Execution (the Coder gate — record each plan step's landing commit as work lands)
- step 1 — done: d6806f5
- step 2 — done: 374840c
- step 3 — done: 8c65e79
- step 4 — done: 1343f5b
- step 5 — done: 8c6ccea
- step 6 — done: cb6de81
- step 7 — done: 117230d
- step 8 — done: cb6de81
- step 9 — done: cb6de81
- step 10 — pending: the release waits for the merge and the founder's go in chat (AC10; order in `.ai/handoffs/session-167-release-coordinator.md`)


## Advice (every recorded recommendation, answered)
- tech-lead rec 1 — obeyed: d6806f5
- tech-lead rec 2 — obeyed: cb6de81
- tech-lead rec 3 — obeyed: cb6de81
- tech-lead rec 4 — obeyed: cb6de81
- design-advisor rec 1 — obeyed: d6806f5
- design-advisor rec 2 — obeyed: d6806f5
- design-advisor rec 3 — obeyed: d6806f5
- design-advisor rec 4 — obeyed: d6806f5
- design-advisor rec 5 — obeyed: 8c6ccea
- design-advisor rec 6 — obeyed: 8c6ccea
- design-advisor rec 7 — obeyed: d6806f5
- release-coordinator rec 1 — deferred: .ai/ROADMAP.md
  reason: the version bump is a separate post-merge release PR by design (row S167-release); it cannot land before the merge.
- release-coordinator rec 2 — refused: already true — `git branch --list 'session-167-*'` shows only session-167-rich-terminal-demo (checked 2026-09-14), so there is nothing to prune.
- release-coordinator rec 3 — deferred: .ai/ROADMAP.md
  reason: pinning the smoke tag and tap formula happens at the release step (row S167-release).
- release-coordinator rec 4 — deferred: .ai/ROADMAP.md
  reason: the published-crate `vajra init` check happens at the release step (row S167-release).
- release-coordinator rec 5 — deferred: .ai/ROADMAP.md
  reason: `cargo publish` is typed by the founder at the release step (row S167-release); no agent publishes.

## Guardrails
- ONE story: the rich terminal demo for every Vajra user. No 8th command, no new crate
  dependency, no renderer inside the binary.
- The Demo-er gate's logic and the four `demo:` elements do not change (header comment only).
  Vajra filling in slides itself, and the Demo-er checking that way, is S168 — not here.
- The gate must never hang: deck mode only when stdin AND stdout are both terminals;
  `DEMO_MODE=stream` forces the plain run.
- Start from the local prototype; harden it, don't paste it. bash 3.2 must work.
- `SYNC_HOOKS` templates must come out of `fill()` byte-identical (the invariant at the top of
  `src/cli/init.rs`), and the kit is full of `${...}` bash expansions — prove it with a test.
- `.ai/AGENTS.md` and `.ai/CONSTRAINTS.yaml` are compile inputs (`build.rs`): no stray `{`. Keep
  the hand-typed scaffold twin of the `demo:` section in `src/cli/init.rs` in step with the live
  file; `scripts/scaffold-drift.sh` stays green.
- Every newly embedded script needs its `!scripts/...` line in `Cargo.toml`'s exclude list,
  proven with `cargo package --list`.
- Two branches share the `session-167-` prefix: never let the old merged
  `origin/session-167-adhoc-fixes` satisfy THIS session's ship checks — prove each check reads this
  branch, or prune the old remote branch first, with founder approval.
- chitra: `--dry-run` only. Write nothing there, commit nothing there.
- Release is a human act. Prepare and dry-run it (`cargo package --list`, `cargo publish
  --dry-run`, release notes since `v0.1.0`); publish ONLY after the PR is merged and the founder
  says go in chat. A crates.io publish cannot be undone.
- Order matters: cold review BEFORE merge (the attested closeout check needs the branch); release
  AFTER merge, from `main`.
- Max 3 files per commit · ~2h cap. If the cap hits, stop at a clean commit and carry the rest
  to a named session — never half a release.
- Darshan every human reply; plain English for the founder.

## Non-goals (named, not dropped)
- **S168 (founder-named, 2026-09-14):** Vajra fills in the number tiles and the scorecard slides
  itself, from checks it already runs, so those parts cannot be skipped or faked — and the
  Demo-er check works that way.
- No HTML output, no Windows support, no light-background tuning — disclosed as untested.
- `darshan/SKILL.md` is unchanged.

## Delta (vs ROADMAP — OpenSpec markers)
- `+` `scripts/demo-kit.sh` — the terminal deck drawing kit (headline · tiles · verdict · before/after · tables · scorecard · deck pager · three tiers), scaffolded by `vajra init`
- `+` a new decision record: the terminal demo is the human demo
- `~` `scripts/demo-session-template.sh` — the rich deck outline on the kit; an unfilled section fails by name
- `~` `vajra init --sync-fleet` — also updates the demo template and the kit in existing projects
- `~` `demo-producer` — proposes the full outline, not only the four scanned elements
- `~` `vajractl` `0.1.0` → the next version (proposed `0.2.0`) on GitHub Releases, crates.io and Homebrew
- `-` the "present the demo as an interactive HTML slide deck" rule (`demo.presentation: interactive_html`, its `presentation_rules`, the template note, `.ai/AGENTS.md` step 5)
