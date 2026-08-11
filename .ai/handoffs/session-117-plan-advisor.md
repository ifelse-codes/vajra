---
role: plan-advisor
session: 117
agent: claude-code-subagent
source-sha: 719d892f4fd2ab2b5fa41613dbd076e360e87558add6bfb49696acf831fe2c5a
captured: 2026-08-11T12:29:14Z
cost_usd: null
---

# Plan-advisor handoff — session 117

## Plan Advisor proposal — session goal: `vajra next --list-roles`

I read the three files that ground this: `/Users/suman/playground/vajra/src/fleet/mod.rs` (the `ROLES` registry, `pub const ROLES: &[Role]` at line 159, each `Role` carrying `name`/`description`), `/Users/suman/playground/vajra/src/cli/next.rs` (the `run()` dispatch table that every other read-only `next` flag — e.g. `--stations`, `--dogfood-age` — rides), and confirmed `/Users/suman/playground/vajra/src/cli/init.rs` line 594 (`for role in crate::fleet::ROLES { ... render_subagent_definition(role) ... }`) is the scaffolder criterion 1 must not drift from.

Two things worth flagging before the plan, per my instructions to say so plainly rather than guess:

- **Ambiguity on criterion 1's "exactly matches" check.** Since `vajra init` already iterates the literal `fleet::ROLES` constant to scaffold `.claude/agents/<key>.md`, sourcing `--list-roles` from that same constant makes no-drift true *by construction*, not just by a passing test. The author should decide whether the required test only needs to assert this structural fact (both code paths iterate `ROLES`) or must also spin up a tempdir, actually run `vajra init`, and diff the resulting filenames against the printed keys end-to-end. Either satisfies the criterion; I have not guessed which.
- **Ambiguity on "the repo's existing verify script."** This repo's house convention (seen across `scripts/verify-session-*.sh`) is that every session authors its own `scripts/verify-session-NN.sh`, separate from the generic `scripts/verify-closeout.sh` gate. Criterion 3 doesn't say which is meant. I've included a step for both, since neither is invented — one is the closeout gate that already exists, the other is this session's own script that becomes "existing" the moment it's authored.

No unit-test/subprocess harness for spawning the compiled binary currently exists in `src/` (no `assert_cmd`, no `CARGO_BIN_EXE` usage found) — the author will need to pick between a direct-tempdir-diff unit test or a subprocess-based one for criterion 2; I note this as an implementation choice, not a plan gap.

### Proposed ordered steps

1. Add a pure formatter to `src/fleet/mod.rs` (e.g. `format_roles_list() -> String`) that iterates `fleet::ROLES` and renders one line per entry with that role's `name` (key) and `description`. Pure, no `root`/no fs argument — sourcing directly from the same constant `init.rs` already iterates is what makes drift structurally impossible.
   covers: 1

2. Wire a `--list-roles` branch into `run()` in `src/cli/next.rs`, alongside the other flag checks (e.g. near `--dogfood-age`, which is the closest existing precedent: takes no session number, calls a pure formatter, prints to stdout only). It must call only the new formatter and `print!`/`println!` — no `repo_root()`, no `fs::` call, no `Command::new("git")` shell-out, matching the "no file I/O beyond stdout" requirement.
   covers: 1, 2

3. Add a unit test (in `fleet::tests` or `cli::next::tests`) asserting the formatter's output has exactly one line per `fleet::ROLES` entry and that each line contains that role's exact `name` and `description` — grounding "prints ... key and one-line description" concretely, not just "some output."
   covers: 1

4. Add a unit test asserting the *set* of keys the formatter prints equals the set `{ r.name for r in fleet::ROLES }` (same count, same keys) — and, per the ambiguity above, the author should decide whether to also assert this against a live `vajra init` scaffold run in a tempdir for an end-to-end no-drift proof, or rely on the structural argument that both paths iterate the same constant.
   covers: 1

5. Add a read-only regression test for criterion 2: snapshot a directory (fresh tempdir, or the working tree) before invoking the `--list-roles` code path, invoke it, snapshot again, and assert zero diff — no new/modified/deleted files anywhere, including no `.ai/handoffs/*` and no `.claude/agents/*`.
   covers: 2

6. Add the unit test criterion 3 explicitly names: assert the formatter's printed role count equals `fleet::ROLES.len()` exactly — phrased so it starts failing the day a fourth `Role` is added to `ROLES` without a corresponding update to the flag's rendering, per the deliberate-regression-guard intent stated in the criterion.
   covers: 3

7. Author (or extend, if one already exists for this session number) this session's `scripts/verify-session-NN.sh`, chaining `cargo test --lib` and re-running the new tests from steps 3–6, so the session's own verify script is the "existing verify script" criterion 3 requires to stay green.
   covers: 3

8. Run `cargo test --lib` and the repo's verify script(s) (both the session's own `scripts/verify-session-NN.sh` from step 7 and `scripts/verify-closeout.sh`) locally, confirm all green with zero regressions, before this proposal is considered satisfied.
   covers: 3

All three numbered criteria are cited by at least one step (criterion 1: steps 1–4; criterion 2: steps 2 and 5; criterion 3: steps 6–8), and each step only depends on steps already listed before it.

Relevant files read: `/Users/suman/playground/vajra/src/fleet/mod.rs`, `/Users/suman/playground/vajra/src/cli/next.rs`, `/Users/suman/playground/vajra/src/cli/init.rs` (line 592–598 region), `/Users/suman/playground/vajra/scripts/` (verify-script naming convention).

This is a proposal only — it is not written into any prompt file's `## Plan` section; that remains the session author's call.

## Handoff Delta
- `~` re-run: plan-advisor handoff replaced (5546 bytes now vs 5410 bytes prior)
- prior stage: this session's earlier plan-advisor handoff
