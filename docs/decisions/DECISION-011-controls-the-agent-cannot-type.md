# DECISION-011 — Controls the agent cannot type

**Status:** Accepted
**Date:** 2026-09-30
**Session:** S181
**Supersedes in part:** DECISION-008 (the prose search for `**CODE**` is now only a dated fallback)
**Extends:** DECISION-007 (S169 waiver addendum, S173 launch approval), DECISION-003 (hash binding), DECISION-002

---

## Context

S180's ground truth found one root cause behind F77–F80, F84, F85 and F92: a control means something
only if the agent cannot produce it. Four of Vajra's founder controls were text the agent could write —
the `APPROVED` word in a brief, the "verified" stamp on a helper's record, `VAJRA_CLOSEOUT_WAIVER=N`
typed inline, and the session type read from prose.

## Decision

1. **Session type is one strict field.** `session_type: CODE | DOCUMENT | GROUND_TRUTH | INTERACTIVE` on
   a line of its own. Missing, unknown or conflicting fails the close gate. `INTERACTIVE` gets the CODE
   checks. A session cannot label itself `GROUND_TRUTH` off the cadence. No prose is read.
2. **Approval is a record, never words.** From the project's `session_rules_from` the gate reads
   `.ai/approvals/session-NN.json`, written by `vajra approve NN` (refused when the process carries
   `VAJRA_AGENT_MARK`, which `vajra claude` sets on everything it spawns, and when stdin is not a
   terminal), by `VAJRA_APPROVE=NN` at launch, or by `vajra claude --allow-all` (live only while that
   launch runs). The agent's Write and Bash hooks refuse to write there.
3. **A waiver names what it skips.** `VAJRA_WAIVE=<check>,…` with a required `VAJRA_WAIVE_REASON`,
   logged as launch-time (a copy `vajra claude` took from the founder's terminal) or set later.
   `VAJRA_CLOSEOUT_WAIVER=N` keeps working with a printed warning until the founder says remove it.
   No waiver path exists for `claimed-evidence-real` (unchanged, S169).
4. **A stamp is bound to its text.** The `verified:` stamp carries `text-sha:` of the findings as
   written; the mandate, obeyed and fidelity gates recompute it. This extends DECISION-003's hash binding
   from the verdict to helper records (F84).
5. **Old work keeps working, loudly.** Everything below a project's `session_rules_from` (default 181, new
   scaffolds 1) reads the old way through a dated fallback that prints its name every time it is used.

## Proof recorded for the cadence part

With `.ai/CONSTRAINTS.yaml` still saying `ground_truth_next_session: 180` and `sessions/session-180-ground-truth.md`
present, session 181 is NOT a review-only session and session 185 IS — with no edit to the key
(`tests/gt_cadence_shared.rs`, and the old-vs-new Stop-hook check in `scripts/verify-session-181.sh`). A passed
override with no report rolls forward to the next multiple of 5 and says so at session start, prompt submit,
the Stop hook and both close gates.

## Limit — stated where a reader will see it

Bar-raising, **not tamper-proof.** The agent runs as the same OS user. It can strip the mark
(`env -u`), fake a terminal, write the record with a shell path the hook does not match, set both waiver
variables, or re-record its own text through `vajra next --role` and receive a fresh stamp for text the
helper never wrote. What the controls buy: the easy paths are closed, every use is labelled, and the
trail is a file in git a reviewer can read. ~~Scaffolded projects do not yet get the Write/Bash hooks that
guard `.ai/approvals/`.~~ (S182: they do — see the addendum.)

## Alternatives rejected

- Signed approvals or stamps — need a key store the agent could also read (DECISION-003 rejected the same).
- A second environment-variable scheme — the existing `VAJRA_ALLOW_COMMIT` refuse-agent-set pattern is reused.
- Removing the old waiver now — the founder has not said to.
- Guessing the type from more keywords — still text guessing.

---

## S182 addendum — the controls reach existing projects (2026-10-01)

**Follows** this record; **deviates from** DECISION-007's S136 addendum (`--sync-fleet` touches rendered files only).

1. **One guard, one source.** `scripts/hook-approvals-guard.sh` checks Bash commands and Edit/Write/
   MultiEdit/NotebookEdit paths. Vajra's own `hook-pre-bash.sh` / `hook-pre-write.sh` call it; `vajra init`
   ships the same bytes stamped as `.ai/hooks/hook-approvals-guard.sh`, registered as its own PreToolUse
   group. Its block message goes to stderr — the S181 one went to stdout, which Claude Code does not hand
   the agent on exit 2 (it saw "No stderr output").
2. **Block by whether a command can write, not on any `>`.** A command naming the folder (or `cd`-ing into
   `.ai` / the folder) blocks on any redirect left after the provable non-writes are removed (`N>&M`, `>&N`,
   `N>&-`, a redirect to `/dev/null`), a file-writing tool, or an interpreter. Everything the S181 line
   blocked still blocks except those non-writes (S173: guard changes only add); `cd .ai && echo x >
   approvals/x`, an S181 gap, is now blocked. Over-block kept: a command naming the folder that redirects
   elsewhere (`cat <folder>/x > /tmp/y`) still blocks, and says to split the read off.
3. **`--sync-fleet` wires the guard (the deviation).** A file nobody's settings run is not a guard (S129).
   `--sync-fleet` now adds Vajra's missing hook groups to an existing `.claude/settings.json` through the S44
   add-only merge — every user key and hook kept, `--dry-run` honoured, never creating the file.
4. **Report, never edit, `session_rules_from`.** With no key, `--sync-fleet` prints the exact line and
   N = `.ai/SESSION` + 1. The project's `.ai/CONSTRAINTS.yaml` is never written — the founder's policy call.
5. **`--allow-all=NN` (narrows decision 2).** The record stores `session` next to `pid`; it approves session
   NN only, while that launch runs. A bare `--allow-all` is refused before anything starts; a pre-S182
   record naming no session approves nothing. Not the branch name: the agent usually types it.

**After the cold review (pass 1, ACCEPT with a mismatch):** the fd-dup strip is anchored on its right
(`>&1/../<folder>/x` writes a file and was let through), and "only add" is now CHECKED — a test runs every
listed command through the S181 hook from git and the new one. The folder is matched case-insensitively and
with quotes removed. Without jq the guard advises at L1, like every other shipped hook. A partly wired
hook group (a pre-S93 Bash group) gets only its missing entries, so `--sync-fleet` never lists a hook twice.

**Limit, unchanged in kind:** a folder path assembled at run time (`d=.ai; … $d/appr…`) or a glob
(`.ai/a*/x` onto an existing file) gets past the guard; still bar-raising, not tamper-proof. The settings
rewrite keeps the project's key order (serde_json `preserve_order`, founder yes 2026-10-01), so the diff in a
project shows only what Vajra added.

## S183 addendum — the close check lints like CI, on CI's toolchain (2026-10-03)

**Why here:** this record's rule — a project switch is one strict field in `.ai/CONSTRAINTS.yaml`, read by
exact key, never worked out from prose or YAML text — is what the scaffold half of this fix borrows. No
record covered the toolchain, so it is written here rather than in a new DECISION.

**Problem (F101).** S182 closed green on its branch, then CI failed `cargo clippy --all-targets -- -D
warnings` (clippy 1.99, `useless_format`). The close gate ran only `cargo fmt --check`, and the local clippy
was older than CI's moving `dtolnay/rust-toolchain@stable`. Adding the command alone would not have caught
it: the same command on the older clippy passes.

1. **One toolchain, written once.** `rust-toolchain.toml` pins `channel = "1.99.0"` (+ clippy, rustfmt).
   rustup obeys it locally; CI and Release run `rustup toolchain install`, which reads the same file (Release
   adds `rustup target add <target>`). No version number in any YAML. Moving to a newer Rust is one edit to
   that file, with any new lints fixed in the same commit.
2. **One lint command.** `scripts/ci-lint.sh` prints `rustc -V` / `cargo clippy -V`, FAILS when the running
   rustc is not the pinned version (a cargo outside rustup or a `RUSTUP_TOOLCHAIN` override ignores the file),
   FAILS on a missing file or a non-exact channel, then runs `cargo clippy --all-targets -- -D warnings`.
   CI runs it; Vajra's close gate runs it as `cargo-clippy-clean`.
3. **A project names its lint.** The scaffold gate reads `lint_command:` from `.ai/CONSTRAINTS.yaml`: set →
   run it, FAIL on non-zero (waivable like the other checks); `none` → N/A; missing → a WARN row in the
   results table that names the line to add. Never derived from CI files or from which files exist (S177).
   These two new rows (`project-lint-clean`, and `obeyed-judgments` for F104) show WARN and N/A as themselves,
   not under PASS (the S178 trap); the scaffold's older log-only N/A/WARN paths still record PASS (cold review). New scaffolds carry the
   line commented out; existing projects add it themselves (Vajra never edits their CONSTRAINTS).

**Rejected:** comparing the local version against "CI's" (with `@stable` nothing records CI's version — a
network call or a hand-kept copy); `dtolnay@master` with `toolchain: 1.99.0` beside the toml (two copies);
`rustup update` inside the gate (network, changes the founder's machine, still a race); command + logged
version only (leaves the S182 gap); the per-session verify script for project lint (opt-in every session);
guessing the lint from CI YAML or `Cargo.toml` (S177).

**Fakest green — stated where a reader will see it:** the agent can type `lint_command: true` or `none`
(only the diff shows it); "matches CI" means "clean on the pinned version", not on today's stable — the pin
ages until someone bumps it; `#[allow(clippy::…)]` still silences any lint. **Not checked live:** the
Release workflow's `rustup toolchain install && rustup target add` runs only on a tag (CI's runs on the PR).
