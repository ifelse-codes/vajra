---
role: design-advisor
session: 183
agent: claude-code-subagent (verified: toolu_01RVRj637HbvLeh9sN2UAHKd; text-sha: 681e2807f4a7a4fc36281c4a7f5c2d8e710470baaebac925d18c08cfe0a8bc21)
source-sha: cda3b399f763dfa7d7bf29632cb8a21ded4b4cafa64bb7d05bb43992dfe70974
captured: 2026-10-02T18:46:09Z
cost_usd: null
---

# Design-advisor handoff — session 183

# Design-advisor brief: session 183, F101 only

This covers F101 only. The rudra S16 findings (F102…) don't exist yet. If any of them needs design, it gets its own addendum pass later. Nothing below has been run yet: the rustup behaviour in rec 2 is checked on the PR's first CI run, and every fixture in rec 5 still has to be built.

## What I checked
- **No `rust-toolchain.toml` or `rust-toolchain`** exists in the repo. I globbed for both.
- **CI and Release both use `dtolnay/rust-toolchain@stable`.** That means "whatever stable is newest today", and no version is written down anywhere.
  - `.github/workflows/ci.yml:24-31` runs fmt, then `cargo clippy --all-targets -- -D warnings`, then test.
  - `.github/workflows/release.yml:30-32` uses the same action with a per-job target for the cross builds.
- **Vajra's own close gate runs no clippy.** `scripts/verify-closeout.sh:187-194` (`check_cargo_fmt`, called at :1349) runs only `cargo fmt --check`.
- **The scaffold's close gate runs no lint at all.** `scripts/verify-closeout-scaffold.sh` (shipped via `src/cli/init.rs:1896`) has only `ok()` and `bad()` (lines 46 and 60). Its WARN and N/A notes go only to the log, so the results table still says PASS. That is the S178 trap: green on the table, not checked underneath.
- **The per-session template** (`src/cli/init.rs:1924-1929`) has clippy only as a commented-out example under "EDIT PER SESSION".
- **There is a precedent for strict switches in `.ai/CONSTRAINTS.yaml`.** `scripts/lib-ground-truth.sh:129-135` reads `session_rules_from:` and `ground_truth_next_session:` by an exact key match. DECISION-011 records that pattern.

## Proposed marker
```
design-significant: yes
```
Why it's `yes`:
- It adds a new close-gate check.
- It adds a new project-facing field to the scaffold's `.ai/CONSTRAINTS.yaml`.
- It changes where CI and Release get their toolchain from.

That is a changed interface plus a new contract, not a pure fix. No locked record covers pinning the toolchain today, so this needs a recorded addendum (rec 6), not just a citation.

## Proposed `## Design` text

> design-significant: yes
>
> Cites: `docs/decisions/DECISION-011-controls-the-agent-cannot-type.md` (a project switch is one strict field in `.ai/CONSTRAINTS.yaml`, read by exact key; nothing is worked out from prose or YAML text). This session records an S183 addendum there, because no record yet covers the toolchain pin.
>
> **Problem.** S182 closed green and then failed CI. The local clippy was older than CI's moving `@stable`. Adding the clippy command alone would not have caught it, because the same command on the older clippy passes.
>
> **Vajra's own gate: one toolchain, written once.** A new `rust-toolchain.toml` pins `channel = "1.99.0"` with `clippy` and `rustfmt`. Local rustup obeys it automatically. CI and Release stop using `dtolnay/rust-toolchain@stable` and run `rustup toolchain install`, which reads the same file. Release adds `rustup target add ${{ matrix.target }}` to that pinned toolchain. No version number is typed into YAML.
>
> One script, `scripts/ci-lint.sh`, holds the clippy command. CI runs it, and the close gate's new `cargo-clippy-clean` check runs it too, so the command also lives in one place. The script:
> - prints `rustc -V` and `cargo clippy -V` first;
> - FAILS when the running `rustc` version is not the file's `channel` (this catches a non-rustup cargo, or a `RUSTUP_TOOLCHAIN` override, where the file is silently ignored);
> - then runs `cargo clippy --all-targets -- -D warnings`.
>
> Moving to a newer Rust is one deliberate edit to one file, and any new lints get fixed in that same commit. A new stable release can no longer turn an unchanged branch red.
>
> **Scaffold gate: the project says what its lint is.** One optional field goes in `.ai/CONSTRAINTS.yaml`: `lint_command: <command>`.
> - Set: the close gate runs it, records the command in the log, and FAILS if it exits non-zero.
> - `lint_command: none`: an honest "this project has no linter". The row reads N/A.
> - Missing: the results table row reads WARN, not PASS, and names the field to add.
>
> The gate never works out a command from CI files or from which files a project has.
>
> **Rejected.**
> 1. Compare the local version against "CI's version". With `@stable` there is no recorded version to compare against. You would need a network call (`rustup check`) or a hand-typed copy that drifts.
> 2. `dtolnay@master` with `toolchain: 1.99.0` next to the toml. That is two copies of one number.
> 3. `rustup update` inside the close gate. It needs the network, changes the founder's machine, and is still a race, because CI's stable can move between close and push.
> 4. Command plus logged version only (tech-lead's fallback). It leaves the exact gap S182 fell into.
> 5. Scaffold: use the per-session verify script. That gets copied and edited every session, so lint would be opt-in each time and drop off silently. Lint belongs to the project, not to a session.
> 6. Scaffold: work out the lint from the CI YAML or from `Cargo.toml` being present. That is guessing (S177, DECISION-008's rejected path).
>
> **Not a deviation, but stated.** `lint_command` is a project setting the agent *can* edit. It is not one of DECISION-011's founder controls, and it borrows only that record's "strict field, never prose" rule.
>
> **Fakest green.**
> - In a scaffolded project, `lint_command: true` (or `none`) passes. The only defence is that the line sits in the git diff in front of the cold reviewer.
> - "Matches CI" means "clean on the pinned version", not "clean on today's stable". The pin ages until someone bumps it.
> - `#[allow(clippy::…)]` in the code still silences any lint.

## Recommendations

rec 1 — Add `rust-toolchain.toml` pinning `channel = "1.99.0"` with `components = ["clippy", "rustfmt"]` as the only place Vajra's toolchain version is written.
It is one file that rustup reads locally and in CI, so there is no second copy to drift. Pin the exact version; `channel = "stable"` would bring back the S182 gap.

rec 2 — In `ci.yml` and `release.yml`, replace `dtolnay/rust-toolchain@stable` with `run: rustup toolchain install`, which reads the toml. In Release, add `rustup target add ${{ matrix.target }}`. Do not put a version number in either YAML.
Leaving `@stable` in place would install a toolchain nothing uses, and the step would claim "stable" while 1.99.0 actually runs. The risk: `rustup toolchain install` with no arguments needs rustup 1.28 or newer, which is on hosted runners as far as I know. The PR's first CI run is the test. If that step fails, it is safe to keep the dtolnay step as harmless setup, because rec 3's version check still fails loudly on any mismatch. Also confirm that the x86_64-apple-darwin cross build still links on the pinned toolchain; the release only runs on a tag, so try it once by hand or note it as not checked.

rec 3 — Put the version check and the clippy command in one script, `scripts/ci-lint.sh`, that CI calls and that the new `cargo-clippy-clean` check in `scripts/verify-closeout.sh` (next to `check_cargo_fmt`) calls. It prints the `rustc` and `clippy` versions first and FAILS when `rustc` differs from the toml's `channel`.
This removes the second copy of the command (ci.yml and the gate), it covers F101's "names the toolchain it used", and it gives rec 5's fixture one unit to run. Read `channel` by an exact key match, and FAIL if the toml is missing, because a check that cannot evaluate must fail. Leave `check_cargo_fmt` alone to keep the change small.

rec 4 — In the scaffold, add one optional field `lint_command:` to `.ai/CONSTRAINTS.yaml`.
- Set: `verify-closeout-scaffold.sh` runs it, logs it word for word, and FAILS if it exits non-zero.
- `none`: the row reads N/A.
- Missing: the row reads `WARN` in the results table (a small `warn()` next to `ok()` and `bad()`, counted as not-failed).

Add a commented `# lint_command:` line to the CONSTRAINTS template that `vajra init` writes. This is tech-lead rec 2 with two changes. First, `none` is the house "recorded reasoned skip" (S133), so a project with no linter isn't nagged at every close. Second, the WARN has to show in the table, because WARNs that only reach the log are exactly what S178 missed. Do not edit the per-session verify template. Adding `lint_command:` to rudra is the founder's own commit (Acceptance 3).

rec 5 — Build the fixtures in the scratchpad with `RUSTUP_AUTO_INSTALL=0`, each with a passing control.
- (a) A tiny crate with a copy of Vajra's toml and one `format!("x")` (`useless_format`): `ci-lint.sh` FAILS and its log names `useless_format`. The control is the same crate without that line, which passes.
- (b) The same crate with its toml set to `channel = "1.98.0"`, run with `RUSTUP_TOOLCHAIN=1.99.0`: FAILS, naming both versions. This is the "toml ignored" case.
- (c) A scaffolded scratch repo: `lint_command: false` FAILS, `lint_command: true` PASSES, and with no field the row reads WARN.

The scratch crate sits outside Vajra's tree, so Vajra's toml does not apply there; copy it in, or (a) runs on whatever toolchain is the default. `RUSTUP_AUTO_INSTALL=0` stops a wrong channel from quietly downloading a toolchain. Without it, a missing toolchain or a network error would turn the fixture red for the wrong reason (S122).

rec 6 — Record this design as an "S183 addendum" in `docs/decisions/DECISION-011-controls-the-agent-cannot-type.md` (toolchain pin, shared lint script, `lint_command:` field, and the fakest green), and cite that file in `## Design`.
No record covers the toolchain pin today. The S182 addendum shows an addendum in this record is accepted practice, and it is cheaper than a new DECISION-012. If the founder would rather keep DECISION-011 only for "controls the agent cannot type", a new DECISION-012 is the honest alternative. The citation must point at a file that exists either way.

rec 7 — Put the fakest green in the session summary and in the fidelity-reviewer's brief, word for word:
- the agent can type `lint_command: true` or `none`;
- "matches CI" means "matches the pinned version", not today's stable;
- `#[allow]` still silences any lint.

Those are the three ways this green can be hollow. Naming them stops the reviewer and the founder reading `cargo-clippy-clean PASS` as "CI will pass on any toolchain".

## Files
- /Users/suman/playground/vajra/prompts/183-task-rudra-s16-new-rules.md (its `## Design` section is what this proposes)
- /Users/suman/playground/vajra/.github/workflows/ci.yml
- /Users/suman/playground/vajra/.github/workflows/release.yml
- /Users/suman/playground/vajra/scripts/verify-closeout.sh (lines 187-194, call site 1349)
- /Users/suman/playground/vajra/scripts/verify-closeout-scaffold.sh (lines 46, 60; log-only WARN and N/A at 206, 448, 881)
- /Users/suman/playground/vajra/scripts/lib-ground-truth.sh (lines 129-135, the strict CONSTRAINTS field reader)
- /Users/suman/playground/vajra/src/cli/init.rs (lines 1896, 1924-1929)
- /Users/suman/playground/vajra/docs/decisions/DECISION-011-controls-the-agent-cannot-type.md (the cited record)
- /Users/suman/playground/vajra/.ai/handoffs/session-183-tech-lead.md (recs 1-3; this brief follows rec 1's toolchain framing and refines rec 2 and rec 3)

## Handoff Delta
- `+` new: first design-advisor handoff for this session (11290 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
