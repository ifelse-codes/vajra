# Vajra

> One command-line tool that guides any AI coding agent through your project, step by step.

## Install

**Works today** — install straight from source with [Rust](https://rustup.rs) 1.70+. No clone needed:

```bash
cargo install --git https://github.com/ifelse-codes/vajra
```

Or clone first, then install from the checkout:

```bash
git clone https://github.com/ifelse-codes/vajra && cd vajra && cargo install --path .
```

Both build the `vajractl` crate and drop a `vajra` binary on your PATH. This path is checked end-to-end by [`scripts/install-smoke.sh`](scripts/install-smoke.sh): a fresh-directory install → `vajra init` → `vajra next`, asserting each step succeeds inside a time budget and **exiting non-zero if anything is broken**. Run it yourself — every "it installs" claim here is re-derivable, not a feeling.

**No Rust? Download a prebuilt binary** — from the [`v0.1.0` release](https://github.com/ifelse-codes/vajra/releases/latest), which ships a self-contained `vajra` for macOS (Apple Silicon + Intel) and Linux (x86_64). Pick your platform's tarball:

```bash
# macOS Apple Silicon — for Intel or Linux swap in x86_64-apple-darwin / x86_64-unknown-linux-gnu
curl -fsSL https://github.com/ifelse-codes/vajra/releases/latest/download/vajra-aarch64-apple-darwin.tar.gz | tar xz
sudo mv vajra /usr/local/bin/
```

Each tarball ships a `.sha256` beside it, and this path is proven by the same instrument: `VAJRA_SMOKE_SOURCE=release scripts/install-smoke.sh` downloads the tarball for your host, verifies its sha256, then runs `vajra init` → `vajra next`, **exiting non-zero on any broken step**.

Two more channels — both **published and proven** by the same instrument ([`scripts/install-smoke.sh`](scripts/install-smoke.sh), modes `VAJRA_SMOKE_SOURCE=crates` and `=brew`): each installs from the real channel, then runs `vajra init` → `vajra next`, **exiting non-zero on any broken step**. The crate name is settled in [`DECISION-006`](docs/decisions/DECISION-006-crate-name.md); the Homebrew formula lives in the [`ifelse-codes/homebrew-tap`](https://github.com/ifelse-codes/homebrew-tap) repo and installs the sha256-verified `v0.1.0` release binary.

```bash
# crates.io (needs Rust)
cargo install vajractl

# macOS / Linux Homebrew
brew install ifelse-codes/tap/vajra
```

## What Vajra Is

Vajra is the coach. The AI agent (Claude Code, Codex, Cursor, others) is the worker. You are the boss.

You run `vajra init` to set up the workflow. You run `vajra <agent>` to start a session. You run `vajra next` to move one step forward. Vajra hands the agent the right context, the right rules, and the right step — the agent does the actual coding.

**Vendor-neutral is the whole point.** GSD and SuperClaude are prompt libraries — they suggest rules, but agents can ignore them. Vajra is a Rust binary that actually enforces rules via hooks, fails closed on violations, and meters cost honestly. Ship narrow, ship enforced, show receipts.

**Direction (2026-07):** the product is **provable agent governance**, shaped as a **governed multi-agent SDLC pipeline** — a specialised agent per stage with enforced, delta-tracked handoffs — **sold as the autopilot trust layer**: leave your agent working, come back, and trust the result. All **8 stations ship today** (Analyst · Architect · Planner · Coder · QA · Demo-er · Releaser · Reviewer); `vajra next --stations NN` reads how many a session passed (K-of-8). The independent **fidelity / acceptance auditor** is **shipped** — every verdict is attested (`sha256(prompt‖diff)`) and chained tamper-evident in an append-only ledger. The pipeline is the engine; the trust is the pitch. See [`VISION.md`](VISION.md), [`DECISION-005`](docs/decisions/DECISION-005-autopilot-trust.md), and `docs/decisions/`.

## Current Status

Seven top-level commands (`vajra --help`):

| Command | Status |
|---|---|
| `vajra init` | **Works** — scaffolds `.ai/` workflow + hooks + cross-agent pointers (interactive, idempotent) |
| `vajra claude` | **Works** — launches Claude Code with the compression hook and prints an honest receipt |
| `vajra next` | **Works** — prints the `.ai/` handoff packet; `--advance` bumps the session (gated on an approved prompt); `--stations NN` reads the pipeline K-of-8; `--scaffold`/`--validate` drive the Analyst stage |
| `vajra check` | **Works** — drift detection + readiness scoring (**11 checks**, pass/fail + score; `--render` regenerates `vajra.varta`) |
| `vajra estimate` | **Works** — predicts token spend and cost before a session |
| `vajra meter` | **Works** — prints the cost receipt for any past session (`vajra meter <session.jsonl>`) |
| `vajra hook` | **Works** — the Claude Code PostToolUse hook entrypoint (invoked by `vajra claude`; not run directly) |
| `vajra <agent>` | **Not built yet** — only Claude Code is wired; Codex and Cursor are planned |

> **Honest note on the receipt:** the headline figure is the tool's own authoritative `total_cost_usd` when the run provides it (fixed in S66/S78), and Vajra says so plainly when it does not (S77) rather than guessing. A secondary token-based figure is printed only as a labeled `[estimate]`, never as the headline. The old cache-pricing overstatement is retired. Fidelity of what we *claim* is the whole point — so the receipt shows the real number either way.

## The Workflow (the product)

Vajra enforces disciplined sessions: the `.ai/` rules, one branch per session, a verify gate that fails closed, drift detection, a NO-CODE audit every 5th session.

| # | Job | Plain meaning |
|---|---|---|
| 1 | **Guides the workflow** | Tells the agent the right step, in the right order, start to finish |
| 2 | **Keeps memory** | Feeds the agent what the product is, the roadmap, the rules — so it never forgets between chats |
| 3 | **Enforces discipline** | One branch per step, one step at a time — no drift, no chaos |
| 4 | **Saves a few tokens** *(bonus — unproven)* | The trim mechanism ships, but the last measured real run folded 0 lines and saved $0 (S63) — an aspiration we're working on, not a claim |

## How You Use It

```bash
vajra init              # scaffold .ai/ workflow in any repo
vajra claude            # launch Claude Code with workflow hook + receipt
vajra next              # print the current step + all its context
vajra next --scaffold 56 planner-stage   # Analyst: generate the next governed prompt
vajra next --validate 56 # is that prompt well-formed + approved? (READY / NOT-READY)
vajra next --advance    # bump to the next session (gated on an approved prompt)
vajra check             # drift detection + readiness score
vajra meter session.jsonl  # cost receipt for a past session
```

## How Saving Works (the quiet bonus)

Vajra intercepts successful tool output *before the model reads it* via a PostToolUse hook. A 180-line `cargo build` becomes one line. A passing test suite becomes a summary. Failures always pass through untouched.

This is different from prompting the agent to "ignore verbose output" — that still bills every token. Vajra's hook fires before the model ingests the output, so compressed tokens are never billed.

| Tool output | What happens |
|---|---|
| `cargo build` (180 lines, exit 0) | `✓ cargo build — Finished dev profile (180 crates compiled)` |
| `cargo test` (84 lines, all pass) | `✓ cargo test — test result: ok. 41 passed` |
| `git log` (long) | First 10 commits + count |
| `npm test` / `pytest` (pass) | One-line summary |
| Any command (exit ≠ 0) | **Verbatim — never compressed** |
| Any command (< 30 lines) | **Verbatim — too short to bother** |
| Non-Bash tools (Read, Edit, etc.) | **Verbatim — not touched** |
| `VAJRA_RAW=1 vajra claude` | **Everything verbatim — full bypass** |

**Honest status (measured, not estimated): the last paid real run (S63) folded 0 lines and saved $0.** The mechanism works on long successful output, but real agent sessions rarely produce output that triggers it. We do not claim savings until a measured run shows them — the receipt prints the real number either way. When a fold does land, the bigger value is context-window space, not dollars.

## The Receipt

After every session — a real captured receipt from the S97 paid run on chitra (2026-07-23):

```
─── vajra · 24ca508 ───────────────────────────────────────────
 $1.2758  total  (fable-5 28 lines)
         $4.8765  token estimate  [estimate]
         input $0.4172 · output $0.9323 · cache-r $0.6743 · cache-w $2.8527
─────────────────────────────────────────────────────────
```

The headline `$1.2758 total` is the run's authoritative `total_cost_usd`. The `$4.8765 token estimate` is a secondary token-price recompute, printed **only** with the `[estimate]` label so it is never mistaken for the real cost. When a run provides no `total_cost_usd`, the headline says so honestly instead of guessing.

Run `vajra meter <path-to-session.jsonl>` to meter any past session.

## Known Limitations

- **Only Claude Code today** — `vajra claude` uses the CC PostToolUse hook. `vajra next` is agent-agnostic (it only prints repo context). Other agent launchers are planned but not built.
- **`vajra next --advance`** — bumps the session but requires interactive confirmation (no `--yes` flag yet).
- **Vendor-contract dependency** — `updatedToolOutput` is a CC hook feature with no stability guarantee. If Anthropic changes it, Vajra falls back to passthrough (fail-open, never breaks your session).
- **Savings estimates are rough** — the "tokens saved" number uses ~12 tokens/line as an estimate.

## Environment Variables

| Variable | Effect |
|---|---|
| `VAJRA_RAW=1` | Disable all compression — full output passthrough |
| `VAJRA_QUIET=1` | Suppress the end-of-session receipt |
| `VAJRA_DEBUG=1` | Print temp settings path and merge details |
| `VAJRA_VERBOSE=1` | Expanded per-model receipt breakdown |

## License

Apache-2.0
