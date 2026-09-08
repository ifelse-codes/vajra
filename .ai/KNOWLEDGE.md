# Vajra — Knowledge Base

**Permanent facts only.** §1–§5 are the reloaded-at-boot core; **§6 is an append-only decision log,
NOT reloaded in full every session** (282 lines as of S156 — pruned from 1364 lines at S155 GT; read
the relevant entry on demand). GT results live in `sessions/` and `SESSION-BOOT.md`.

## 1. System Information

| Item | Value |
|---|---|
| Working directory | /Users/suman/playground/vajra |
| OS | macOS |
| Shell | /bin/zsh |
| Git | initialized 2026-06-17 |
| Claude CLI | `/opt/homebrew/bin/claude` present as of 2026-06-24 |
| Owner | Suman — suman@sumanairbook.local |

## 2. Product Identity

- **Name:** Vajra
- **Positioning:** One CLI that guides any AI coding agent through a project step by step. Vendor-neutral workflow coaching is the product; token saving is the quiet bonus.
- **Implemented slices today:** `vajra claude` (launches Claude Code with workflow context + compression hook + receipt) + `vajra next` (prints `.ai/` handoff packet or advances via `--advance`) + `vajra check` (drift detection + readiness scoring) + `vajra init` (scaffolds `.ai/` workflow). Only Claude Code is wired; other agents are planned.

## 3. Repo Layout (Agent Workflow)

```
.ai/             Agent constitution + machine state
varta/           Varta language — SKILL.md (grammar) + GRAMMAR.varta (spec); spoken from live .ai/
darshan/         Darshan — SKILL.md: the human's glanceable output skill (skill, not renderer; 3 surface tiers)
.claude/         Claude Code config (settings.json)
.githooks/       Tracked git hooks (pre-commit, pre-push)
scripts/         hook-*.sh, verify-session-NN.sh, verify-closeout.sh, init-session.sh, rollback-closeout.sh
prompts/         Session input contracts (NN-task-<slug>.md)
sessions/        Session output reports (session-NN-summary.md)
docs/adr/        Architecture decision records
research/        Competitor teardown, Headroom lessons, JSONL recon, compression fixtures
AGENTS.md        Root pointer (Codex)
CLAUDE.md        Root pointer (Claude Code)
.cursorrules     Root pointer (Cursor)
```

## 4. Planned Tech Stack

Rust, single static binary (package `vajractl`, binary `vajra`), Apache-2.0 OSS

## 5. Source Documents

- VISION.md (target product vision)
- VAJRA-MASTER.md (single source of truth for the original compression-first thesis)
- DESIGN-BRIEF.html (visual design brief)
- docs/adr/0001-compression-delivery-mechanism.md
- docs/adr/0002-engine-trait-adapter-contract-module-layout.md
- docs/adr/0003-settings-injector-and-compression-heuristics.md
- docs/adr/0004-meter-receipt-design.md
- research/HEADROOM-LESSONS.md (learn-only reference; no code/docs/names/claims copied)
- research/COMPETITIVE-LEARNINGS.md (GSD/SuperClaude/Loop teardown — what to steal, what to avoid, expert panel consensus on build order)
- research/COMPETITOR-TEARDOWN.md (AxonFlow + agent-trace spec analysis)

## 6. Solved Problems / Decisions Made

- ADR-0001: Hook wins over shim for v1 compression delivery
- ADR-0002: Engine trait + enum return + single crate + no adapter trait in v1
- ADR-0003: Tempfile settings merge + LINE_CAP=30 + FAIL_PASSTHROUGH_CAP=400
- ADR-0004: On-exit receipt to stderr + sidecar env var + compiled-in pricing
- ADR-0005: Pre-run cost estimate — chars/4 for input tokens, 3:1 output ratio (placeholder heuristic, not validated), Opus pricing default. Output ratio is low-confidence; treat as order-of-magnitude guidance until historical JSONL ratios replace it.
- **Founder direction (2026-06-24):** `vajra next` + cross-agent workflow coach is the north star; current repo is a partial foundation, not the finished product.
- **S07 — `claude --settings <file>` is additive:** merges with project `.claude/settings.json`, does not replace. All hook types from both sources fire. Verified via `--output-format stream-json --include-hook-events`.
- **Varta (S19) — skill, not compiler:** grammar frozen at 9 constructs (`⚡project ⚡forbid ⚡require ⚡max ⚡pipeline ⚡final ⚡on ⚡assert ⚡enum`). Varta is a language the agent speaks from the live `.ai/`, NOT a persisted file — a hand-written `.varta` companion drifts silently from `.ai/` and is forbidden.
- **Co-pilot loader (S21) — `⚡on(cond) ⚡include "files"` fires mid-session** via `hook-copilot-loader.sh` (PreToolUse Bash/Edit/Write). L1 advises (stdout, exit 0); L2/L3 blocks (stderr, exit 2). Per-session debounce keyed on `session_id`. Decision gate answered: Varta ENFORCES → on-wedge.
- **Packaging gotcha (S22 — permanent rule):** any file `include_str!`'d from outside `src/` must be in the crate package. `Cargo.toml` excludes `scripts/*`, so each included script needs a per-file negation `!scripts/hook-name.sh`. Same applies to `.githooks/*` (S43). Verified via `cargo package --list`.
- **Darshan (S27) — skill, not renderer:** 3 surface tiers: rich chat (HTML/SVG) · terminal (ANSI + box-drawing) · plain (structured markdown). One rule: render the richest visual the surface can handle; never drop meaning. Wired via Speaking Skills table in `.ai/AGENTS.md`. Propagated into `vajra init` via `include_str!` (S28).
- **`grep -q` SIGPIPE gotcha (S32 — permanent):** `bash hook | grep -q MARKER` under `set -euo pipefail` gives a false RED — `grep -q` closes the pipe on match → producer takes SIGPIPE (exit 141) → pipefail fails. Fix: capture output first (`OUT=$(hook)`) then `grep -q ... <<<"$OUT"`; grepping a file is also safe.
- **Real CC hook envelope shape (S31/S33 — permanent):** `HookInput` top level is **snake_case** (`tool_name/tool_input/tool_response`); only `HookToolResponse` keeps `#[serde(rename_all = "camelCase")]` (its nested keys — `isImage/noOutputExpected` — really are camelCase). Real CC **never sends `exit_code` for Bash** → `Option<i32>` → `None`. The pre-S33 bug: `rename_all="camelCase"` on `HookInput` → serde failed on every real payload → silent `"{}"` passthrough.
- **Compression fail-gate (S41 — permanent):** `git` family heuristics override `preserves_failure_signal()→true` and fold regardless of `exit_code`. Generic/unknown path stays gated (`!is_success && lines < 400` → passthrough). Cargo/npm/pytest branch on `exit_code == Some(0)` directly → never fold under real CC (separate carry).
- **jq-preflight (S42 — permanent):** all 5 Vajra hooks have a self-contained fail-closed preflight block right after `set -euo pipefail`. With `jq` absent: L1 advises (exit 0), L2/L3 blocks (exit 2). Block is byte-identical across hooks and travels inside `include_str!`'d scaffold copies.
- **Publish-guard approval signal (S37 — permanent):** approval env var is `VAJRA_ALLOW_PUBLISH=1`, NOT a token file — the agent cannot mutate the hook's launch environment from inside a Bash tool call. Command classification strips quoted spans first (`sed -E "s/'[^']*'//g; s/\"[^\"]*\"//g"`) to avoid false-blocking messages containing trigger phrases.
- **S43 — `.githooks/pre-commit`/`pre-push` scaffolded into `vajra init`** via `include_str!` + `configure_githooks_path(root)`. Closes raw-write bypass at git layer. `.githooks/` must be in SCAFFOLD_OWNED list; Cargo.toml excludes `.githooks/` → needs per-file negation.
- **S44 — `vajra init` merges into pre-existing `.claude/settings.json`** (additive, idempotent). Malformed/non-object existing JSON → leave untouched + warn. `serde_json` sorts top-level keys (no preserve_order enabled) — content and array/hook execution order preserved.
- **S46 — enforcement moat LIVE-VERIFIED:** at L3, governance-in-context causes the agent to self-refuse; hook backstop (isolation harness, governance stripped) blocked a real `git push` at exit 2 (committed artifact). Both layers held live. The S37→S46 guard arc is COMPLETE.
- **S70 permanent decisions (binding until revisited):** (1) dogfood deferred by decision — finish the crew, then the founder runs it manually; (2) compression NEVER claimed in README/marketing until measured real; (3) pipeline-payload counter = BACKLOG.
- **ARCHITECT station (S67) — permanent contract:** `design-significant: yes|no` recorded marker; substance = non-placeholder `## Design` citing a spine record that EXISTS (`docs/adr/NNNN-*.md` / `docs/decisions/DECISION-NNN-*.md`). Made-up ids BLOCK. Empty-spine repo waives citation. Existence-gating recorded markers is the house pattern.
- **CODER station (S68) — permanent contract:** `step N — done: <sha>` in `## Execution`; sha must exist via `git cat-file -e <sha>^{commit}`; `<...>` placeholder records nothing; numbered plan steps only. Absent states WARN (legacy compat); present-but-incomplete BLOCKS. Binds on session being CLOSED.
- **QA station (S69) — permanent contract:** live re-executes `scripts/verify-session-NN.sh` — recorded runs never trusted as proof. No exit code (signal-kill) → `LiveRed(None)` BLOCKS. `VAJRA_SKIP_QA_GATE=1` skips the live run itself. `demo:` section also carries `script_pattern:` key → section-scoping mandatory when a key name repeats across YAML sections.
- **Demo-er station (S71) — permanent contract:** required demo element = emitted `demo:<element>` marker in LIVE output scan (hollow exit-0 demo dies on element scan). `is_file()` not readability — `chmod 000` → bash 126 → BLOCK. `${2:-default-with-{NN}.sh}` truncates at first `}` — assign brace-y defaults in a separate statement.
- **Releaser station (S72) — permanent contract:** merged = `merge-base --is-ancestor` over `session-NN-*` refs; sync = `rev-list --left-right --count main...origin/main`; ahead-only discloses, never blocks (publishing is a human act). Gate NEVER mutates. Verify scripts must be BRANCH-AGNOSTIC — `git diff main`-shaped assertions go red post-merge.
- **S85 permanent nuance:** raw K-of-8 cannot distinguish "counter got more accurate" from "pipeline stalled." Read the SHAPE (which station, why), not just the digit.
- **S97/S99 — Coder-dark root cause fixed:** `vajra init` session-01 kickoff now rendered from ONE canonical `analyst::PROMPT_TEMPLATE` carrying `## Acceptance/Design/Plan/Execution/Delta` markers. `Outcome::Legacy` = prompt exists but has ZERO marker headings → reports `[LEGACY]` with cause+remedy, never `[ABSENT]`.
- **S112 — `cargo test --lib <filter>` exits 0 when filter matches nothing** ("running 0 tests … ok"). Every verify check naming a single test must assert `test result: ok. N passed` with N ≥ 1 via `named_test_passed()`.
- **S113 — `grep -E '\s'` is NOT portable on BSD/macOS** — `\s` is a literal `s`. Use `[[:space:]]`. Pair negative guards with a positive control asserting the pattern matches a known-present case.
- **S114 — fidelity-reviewer permanent contracts:** role key is `fidelity-reviewer`, never `reviewer`. Governed handoff is a PRE-STAGE INPUT; `sessions/session-NN-review.md` is the single record of record. `reviewer/SKILL.md` is the canonical reviewer contract, bound by a check reading both files. Closeout gate counts verdict words ONLY on `|`-delimited rows and needs ≥3 — per-requirement bullet list is BLOCKED. `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ delivery-diff) — attest LAST, after the prompt is final and committed, and confirm two consecutive `--inputs-sha` runs agree.

## 7. Engine + Adapter Type Shapes (S03 — permanent)

```rust
// EngineDecision — Compress renamed Compressed; carries lines_removed
pub enum EngineDecision {
    Passthrough,
    Compressed { output: String, lines_removed: usize },
}

// ToolOutput — tool field removed; interrupted + Option<i32> added
pub struct ToolOutput {
    pub stdout: String,
    pub stderr: String,
    pub exit_code: Option<i32>,
    pub interrupted: bool,
}

// CompressionRequest — command is the shell command string (was tool_output.tool)
pub struct CompressionRequest {
    pub command: String,
    pub tool_output: ToolOutput,
}
```

- `DefaultEngine` returns `Passthrough` (not `Compressed`) when `lines_removed == 0`.
- `ClaudeCodeHookAdapter` lives in `src/adapter/claude_code.rs`.
- Hook wire types (corrected S33): `HookInput` top level is **snake_case** (`tool_name/tool_input/tool_response` — real CC's envelope); only `HookToolResponse` keeps `#[serde(rename_all = "camelCase")]` (its nested keys — `isImage/noOutputExpected` — really are camelCase). No `exit_code` is sent for Bash (`Option<i32>` → `None`).
- Breadcrumb format: `[vajra: N lines folded — VAJRA_RAW=1 before 'vajra claude' to see full output]` (appended to stdout).

## 8. Maturity Levels

| Level | Name | `vajra check` | Hooks | `vajra next --advance` |
|---|---|---|---|---|
| L1 | Report | WARN (exit 0) | Log violations, never block | Interactive confirm |
| L2 | Gated | FAIL (exit 1) | Can reject (exit 2) | Interactive confirm |
| L3 | Auto | FAIL (exit 1) | Strict enforcement | Skips confirm |

- Set via `maturity: L1|L2|L3` in `.ai/CONSTRAINTS.yaml`. Default: L2.
- `vajra init` prompts for maturity level during scaffolding.
- Hook scripts (`hook-pre-bash.sh`, `hook-pre-write.sh`) read `maturity:` and downgrade blocks to warnings at L1.

## 9. Known Limitations

- **stderr-on-exit-0:** `cargo build` with warnings (exit 0) compresses stdout, folding individual warning details. stderr summary ("N warnings emitted") is preserved. Agent may need to re-run to see warning specifics.
- **Savings estimate:** receipt uses ~12 tokens/line to estimate saved tokens. Rough, labeled as estimate.
- **Pricing compiled-in:** binary update needed when Anthropic changes pricing. Stale pricing shows slightly wrong numbers but the receipt's `[estimated]` marker flags schema drift.
- **Receipt authoritative-first (S66, permanent):** the receipt headline is the JSONL's own `total_cost_usd` (the headless `type:"result"` line) when present — `SessionCost::billed_dollars()` = authoritative-or-estimate. The compiled-in token recompute is a **labeled `[estimate]` fallback**, never "the bill." A model absent from `MODEL_PRICING` is estimated at opus upper bound but **flagged** (`not in pricing table` warning), never silently billed as opus.
- **`vajra init` BLOCKS FOREVER on stdin when its runner sends no EOF (S121, permanent).** It reads three interactive prompts. Under a TTY or with `</dev/null` it takes defaults; launched from a background/detached shell whose stdin stays open, it hangs — cost 10+ minutes live. **Any script invoking `vajra init` non-interactively must redirect `</dev/null`.**
- **Exactly ONE fleet role may execute (S121, permanent).** `qa-specialist` alone holds `Bash, Read, Write, Edit, Grep, Glob`; every other role is `Read, Grep, Glob` (+ web for the Researcher). Enforced in `fleet::tests::tool_grants_are_per_role_and_execution_is_the_qa_specialists_alone`.
- **A newly-scaffolded fleet role IS dispatchable in its own creating session (S121, permanent — supersedes the S111 rule).** `fidelity-reviewer` and `qa-specialist` both resolved by name inside their creating sessions. Do not plan around the S111 limit without re-testing. Evidence: `sessions/session-121-artifacts/qa-specialist-live-run.md`.

## 10. Ground-Truth Track Record

GT results live in `sessions/session-NN-ground-truth.md` and `SESSION-BOOT.md`. Key permanent findings have been distilled into §6 above and §9. Three durable meta-findings: (1) **test-green ≠ live-verified** — the same class that hid the compression bug (S31), the guard leak (S36), and the Coder-dark bug (S97); (2) **`dogfood_check` is a durable non-redundant audit axis** — caught false-green 4 consecutive GTs (S30/S35/S40/S45) while other audits stayed green; (3) **an instrument built for one session type goes blind when the process changes which type is normal** (S100 — `--stations` went blind to DOGFOOD+GT sessions; `--dogfood-age` went blind to in-target-repo dogfoods at S140).

## S118 — permanent facts

- **A grep-only verify suite can report 100% green over a broken product.** chitra's `verify-session-11.sh` reported 14/14 while 19 of 20 chart pages errored; all 11 checks grepped source strings. Fix pattern: execute the thing AND prove the check FAILS when the defect is reintroduced (mutation test).
- **Artifact bundles (~16 files) need ≥6 atomic commits** due to the 3-files-per-commit gate. Plan the commit sequence up front.
- **`claude` in this build has no `--max-turns`.** A `-p` stage runs to completion — only a wall-clock watchdog can bound spend within a stage.
- **`VAJRA_CLOSEOUT_WAIVER=NN` on a DOGFOOD session should cover exactly ONE check** (`verify-demo-scripts-present`). If it also covers `fidelity-review-accept`, the gate is being bypassed, not waived.

## S119 — permanent facts (clean-room runner)

- **Clean-room isolation = `git worktree add --detach HEAD <temp_path>`.** Not `git clone`; faster (no object copy), simpler cleanup (`git worktree remove --force`), genuinely absent of uncommitted + gitignored files. RAII: `CleanRoom` struct with a `Drop` impl that reclaims automatically.
- **Bootstrap failure → `CannotEvaluate` → BLOCK.** A check that cannot evaluate its preconditions must never silently pass.
- **Falsifiability fixture pattern:** assert BOTH directions. (1) Old path PASSES when artifact present; (2) new path FAILS when artifact absent. A check that always returns the same result regardless has zero detection power.
- **`clean_room_config()` is a line-scanner, not a YAML parser.** Reads `verify.clean_room.*` via two-space indent nesting. Adds no `serde_yaml` dep. Defaults `(false, None)`.

## S120 — permanent facts

- **Two classes of source-grep verify checks:** STRUCTURAL (check code architecture — acceptable) vs BEHAVIORAL (check a feature works by finding its message string in source — hollow class; never exercises the code path). Name which class when disclosing a fakest green.
- **QA STATION ≠ QA ROLE.** `src/qa/mod.rs` = pipeline station (governs process). `qa-specialist` fleet role = QA agent (does the work). Same separation as Reviewer STATION vs `fidelity-reviewer` role.

## S122 — permanent facts

- **A falsifiability fixture must fail for the RIGHT REASON.** Restore the fixture's subject to a known-clean state between assertions — a planted defect from an earlier assertion that leaks into a later one's baseline makes the tooth glued on.
- **Widening an exclusion list is not a fix.** The exclusion list IS the hole. Repair the new file so it does not carry the string; assert on a FRAGMENT, or read from the canonical source at runtime.
- **A guard bound to a SPELLING gets escaped by the next instance.** Derive what you police from the source of truth so a new field is covered the day it is added.
- **Do not fix findings after ACCEPT.** `Review-Inputs-SHA` hashes the reviewed diff; a post-ACCEPT repair attests something no reviewer saw. File it into the next session's prompt instead.

## S123 — permanent facts

- **A role's `tools:` grant IS enforced at the tool-definition level, not prompt-level.** Dispatching a read-only role and instructing it to attempt a write — the function was simply absent from its callable schema.
- **A granted `Bash` can still write a file by shell redirection** with no `Write`/`Edit` tool involved. Narrowing `Write`/`Edit` does not close every write path for a role that keeps `Bash`.
- **Mid-session role-definition changes (including edits to existing files) are invisible to that session's dispatch.** Claude Code snapshots `.claude/agents/*.md` once at session boot. Confirmed for brand-new files (S111) and in-place edits equally (S123, second confirmation).
- **`gate_run::CleanRoom` has two lifetimes:** `new()` (RAII via Drop, single-process) vs `open_persistent()`/`remove_persistent()` (PathBuf only, for work in a separate longer-lived process like a dispatched subagent).

## S124 — permanent facts

- **A Vajra `PreToolUse` hook fires and is obeyed even under `claude --dangerously-skip-permissions`.** Measured live: the copilot-loader hook denied a `Write` mid-run, unattended; the agent retried and succeeded.
- **`vajra init`'s skip-if-present logic is file-granularity, not key-granularity.** Adding a new key to the CONSTRAINTS.yaml template does not retrofit into a target repo whose file already exists.
- **A dogfood harness's wall-clock watchdog can fail to kill the process it targets.** `(cmd) &` captures the subshell PID, not the exec'd child's; `kill -TERM $RUNPID` may terminate the subshell without terminating `claude` underneath.

## S125 — permanent facts

- **bash 3.2 — `"${arr[@]}"` on an empty array under `set -u` ABORTS** (`unbound variable`). Guard: `${arr[@]+"${arr[@]}"}`. bash 3.2 reports the function's definition line, not the failing line, for such an abort. **Measure the shell; do not reason about it.**
- **`set -u` + empty glob is fatal on bash 3.2** (`local a=(nomatch*)` → `${#a[@]}` aborts). Fires only on fresh-init repos (no session summaries) — invisible in this repo which has hundreds.
- **Unknown subcommands exit 0** (`src/main.rs:36`, `_ => Subcommand::Help`). `vajra chek && deploy` runs deploy.
- **`hook-pre-write.sh` exit 2 reason goes to stdout, not stderr — agent receives `No stderr output`.** A block whose reason goes to stdout is invisible. Exit 2 stops the action; **stderr is what teaches** (one-line fix: `1>&2`).

## S126 — permanent facts (fleet roster)

- **The fleet is NINE roles, one per station plus the station-less `researcher`:** `requirements-analyst` · `design-advisor` · `plan-advisor` · `implementation-advisor` · `qa-specialist` · `demo-producer` · `release-coordinator` · `fidelity-reviewer` · `researcher`.
- **A role key NEVER shadows a station's own word.** `verify-session-126.sh::no_station_collision` runs the real binary over all eight station words.
- **Exactly ONE role may execute** (qa-specialist alone holds Bash; narrowed at S123). Three-copy policy bound by `verify-session-122.sh::execution_policy_one_source`.
- **A roster-SIZE pin in an old verify suite is a booby-trap** for the session that grows the roster. Pin SUBSTANCE (byte-identity, set equality); keep a count only as a non-vacuity floor.

## S127 — permanent facts (Advice gate)

- **Rec format:** `rec N — <one line>` in a governed handoff; disposition in `## Advice` section of the prompt: `- <role> rec N — obeyed: <sha> | refused: <reason> | deferred: <path>`. Fenced code blocks skipped on BOTH sides.
- **`obeyed:` sha must resolve via `git cat-file -e <sha>^{commit}`.** A bare `HEAD` yields an empty hex run and records nothing.
- **`refused:` — non-empty, not a placeholder. That is the whole rule.** A one-word reason passes by decision; the test asserts it so nobody can claim more.
- **`deferred:` — an in-repo relative path that EXISTS.** Absolute paths and `..` escapes refused before touching the fs.
- **`fleet::handoff_body` drops every `#` line.** For marker counting, use `fleet::handoff_findings_raw` / `Handoff.raw_body`.
- **Locating a section must skip fences.** A `## Advice` heading inside a fenced block is otherwise counted as the real section.
- **`pipefail` makes `vajra --check-advice … | grep -q …` inherit the gate's exit 1.** Capture into a variable, then match.
- **Never cite an advice ledger's count as evidence advice was followed.** Four `obeyed:` labels in S127's own 51-answer ledger were factually wrong and passed.

## S128 — permanent facts (first-contact / stranger)

- **`scripts/stranger-check.sh` = the correction** for every instrument measuring Vajra governing itself: real `mktemp -d`, real `git init`, the release binary, 16 checks, registered in `CONSTRAINTS.yaml#ground_truth.required_audits`.
- **An unescaped backtick inside a double-quoted `echo` is a COMMAND SUBSTITUTION.** Single-quote any `echo` that quotes a command.
- **`vajra init` scaffolds into its CWD.** Any script that drives it must `cd` into a temp directory AND assert it is not at the repo root, plus `</dev/null`.
- **`grep FAIL` catches the tally line** (`Score: 10/11 — 1 FAILED`). Match the STATUS COLUMN (`grep -E '[[:space:]]FAIL[[:space:]]'`), never a bare `grep -v` naming the tally.
- **`.ai/AGENTS.md` and `.ai/CONSTRAINTS.yaml` are COMPILE INPUTS shipped in the published crate** (`build.rs` reads them). A parse failure or stray `{` in either file breaks a stranger's `cargo install`. `scripts/scaffold-drift.sh` asserts `cargo package --list` carries both.
- **`absent` and `stale` are not the same failure.** A drift guard should PASS when nothing exists to drift; teeth apply to committed-but-vanished and present-but-different. Git tracking is the discriminator.

## S129 — permanent facts

- **`.contains()` heading match is a CLASS, not a one-off.** Planner's `heading.contains("acceptance")` bug recurs verbatim in the Analyst's `parse_delta()` at `src/analyst/mod.rs:318`. Any substring-match heading/marker parser is suspect until tested against its own trigger word appearing in a title, not just a body line.

## S130 — permanent facts

- **A session's own verify script cannot be meaningfully re-run once its branch is merged.** `git merge-base main HEAD` resolves differently after `main` absorbs the branch — `git diff main`-shaped assertions go red post-merge. Write cumulative-safe assertions: empty-diff-OR-exactly-my-change.

## S131 — permanent facts

- **A Claude Code subagent's transcript records `gitBranch` on its FIRST JSONL line** (measured, not assumed). Free, forger-independent fact for binding a dispatch to the session that made it.
- **`verify-closeout.sh --inputs-sha N` preimage = `<HEAD:prompt file bytes> \0 <diff>`.** Filling `## Execution`/`## Advice`/`## Design` in the prompt AFTER computing `--inputs-sha` changes the hash even though `prompts/` is excluded from the diff half. Attest LAST — after EVERY prompt edit, recompute twice to confirm stability.
- **`cargo test` accepts exactly ONE `TESTNAME` filter positional argument.** Two module names → error. Two modules need two invocations joined by `&&`.

## S132 — permanent facts

- **The judge of an `obeyed:` disposition may NEVER be the graded advisor's role** (`obeyed::admit` rule 1). Since `fidelity-reviewer` is the mandatory role every session hears from, its own advice needs a DIFFERENT role's dispatch to grade it.
- **Land every commit an `obeyed:` will cite BEFORE the judging dispatch.** A fix committed after the last judge mints a claim nobody can grade without another dispatch.
- **`git worktree` under `$TMPDIR` is pathologically slow** (~10+ min for `cargo test` vs ~12s inside the repo's gitignored `target/`). Put probe worktrees inside the repo.
- **The sanctioned advance command blocks on stdin** once it actually advances — non-interactive callers need `</dev/null`.
- **An unrecognised `vajra next` flag falls through to `run_dump()` and exits 0.** Assert on the gate's own header line, not the exit code.
- **`hook-session-guard.sh` false-fires on prose ABOUT the advance phrase.** Heredoc bodies describing the command trip the N→N+1 block. Workaround: write a placeholder, `sed` it afterwards.

## S133 — permanent facts

- **A wrapped prose line that BEGINS with a code fence silently hides every `rec N` after it.** `advice::skip_fenced` toggles on any line whose first non-space characters are `` ``` `` or `~~~`. When a brief discusses fence syntax, never let a line start with the fence characters.
- **`grep -F` with a MULTI-LINE pattern is an alternation of its LINES, not one literal.** Use perl's `index($_, $target)` on a slurped file instead.
- **A session-NUMBER migration threshold is perverse in a freshly `vajra init`-ed project** — sessions 1..N all sit below it. Use marker-based enforcement: the scaffolded prompt carries the marker as a template placeholder, which blocks at any session number.

## S134 — permanent facts (paid dogfood)

- **`vajra claude -p ... --output-format stream-json` yields a real `total_cost_usd`.** An interactive run does not. If a session needs an authoritative dollar figure, it must run headless.
- **A broad subagent dispatch costs millions of tokens, nearly all CACHE READS.** The `Agent` tool's reported `subagent_tokens` counts NEW tokens only — understated by ~45× in S134. Never publish that figure as the session's subagent cost.
- **The per-dispatch raw total is readable from disk:** `~/.claude/projects/<project>/<session-uuid>/subagents/agent-<agentId>.jsonl`, summing `message.usage` across all four token fields per turn.
- **ANSI escapes break `grep` for a marked label.** Strip with `sed 's/\x1b\[[0-9;]*m//g'` before grepping a script's own coloured output.

## S135 — permanent facts (tech-lead)

- **`tech-lead` is the tenth fleet role** — decides which specialists are `required` / `deferred-budget`; verdict BINDS via `vajra next --check-crew NN`. Only `required` and `deferred-budget` are admitted (no off switch in phase 1). `deferred-budget` is a money fact carrying arithmetic, never a usefulness judgment.
- **THE BOOTSTRAPPING WALL (reliable rule):** a native-subagent role is NOT dispatchable in the session that creates it — Claude Code snapshots `.claude/agents/` at session START. A mid-session registry refresh is not guaranteed. **First reliable bind = the session AFTER creation.**
- **`--crew-cost` caught the 45× understatement live** (Agent tool: 98,758 new tokens; RAW on-disk: 2,003,866). Reading `input + output + cache_read + cache_creation` per turn is the instrument.

## S140 — permanent facts

- **`vajra next --dogfood-age` is blind to in-target-repo dogfoods.** Receipts for `vajra claude` runs INSIDE chitra land in chitra's tree, never in Vajra's git — so `--dogfood-age` reports S124 forever regardless. Fix = teach `--dogfood-age` to see receipts in a governed target repo, or record each dogfood's cost in Vajra's own git.

## S141 — permanent facts (recorded provenance)

- **To distinguish "a stale render of mine" from "a file someone edited": RECORD provenance, do not INFER it.** `fleet::render_subagent_definition` writes a `vajra-render-sha: <hex>` stamp as the LAST frontmatter line.
- **Stamp placement is load-bearing.** Goes in YAML frontmatter as an UNKNOWN key — CC's subagent loader reads only `name`/`description`/`tools`/`model` and strips frontmatter — the stamp is inert. Pre-S141 installs are unstamped → `Drifted` on first contact.

## S142 — permanent facts

- **The frontmatter stamp variant MUST stay byte-identical to S141** (a golden unit assertion pins the exact insertion string). A refactor that "moves one byte" of a stamped render silently re-classifies all existing files as `StaleRender` and causes mass churn.
- **`parse_crew` SKIPS lines inside a code fence.** If the `tech-lead` subagent wraps its crew rows in a fence, `--check-crew` reads ZERO rows. Strip fences before `vajra next --role tech-lead --from`.
- **`--check-advice` `deferred: <path>` takes the WHOLE rest of the line as the path.** A trailing parenthetical makes it "a file that does not exist." Keep `deferred:` lines to a bare path.
- **`obeyed-check` judgments must live in an independent role's GOVERNED HANDOFF**, not only in `sessions/session-NN-review.md`. `--check-obeyed` reads the handoff; a review file alone leaves every `obeyed:` "carries no independent judgment."

## S143 — permanent facts

- **`.ai/AGENTS.md` split: user-owned FILLED header + byte-identical GOVERNED body** divided by `GOVERNED_BODY_SENTINEL`. `sync_fleet` upgrades only the body; header preserved verbatim. A pre-S143 boundaryless constitution is `FleetFileState::NeedsBoundary` — refused even under `--overwrite-drifted`.
- **THE ATTESTATION GOTCHA: `canonical_inputs_sha` EXCLUDES `sessions/`, `prompts/`, six `.ai/` closeout files, `.ai/verify` — but NOT `.ai/handoffs/`.** Commit ALL code + ALL `.ai/handoffs/*` FIRST, THEN compute `--inputs-sha`, THEN embed in the review.
- **A rec's OWN advisor role cannot judge the builder's obedience of it.** The qa-specialist's and fidelity-reviewer's own recs that the builder acts on are recorded `deferred:` (to the summary/review that documents the fix + sha), NOT `obeyed:`.
