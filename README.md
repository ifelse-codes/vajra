# Vajra

> One command-line tool that guides any AI coding agent through your project, step by step.

## Install

```bash
# From crates.io
cargo install vajractl

# From source
git clone https://github.com/ifelse-codes/vajra && cd vajra && cargo install --path .

# macOS (Homebrew)
brew install suman/tap/vajra

# Prebuilt binary (macOS arm64 example)
curl -fsSL https://github.com/ifelse-codes/vajra/releases/latest/download/vajra-aarch64-apple-darwin.tar.gz | tar xz
sudo mv vajra /usr/local/bin/
```

## What Vajra Is

Vajra is the coach. The AI agent (Claude Code, Codex, Cursor, others) is the worker. You are the boss.

You run `vajra init` to set up the workflow. You run `vajra <agent>` to start a session. You run `vajra next` to move one step forward. Vajra hands the agent the right context, the right rules, and the right step — the agent does the actual coding.

**Vendor-neutral is the whole point.** GSD and SuperClaude are prompt libraries — they suggest rules, but agents can ignore them. Vajra is a Rust binary that actually enforces rules via hooks, fails closed on violations, and meters cost honestly. Ship narrow, ship enforced, show receipts.

## Current Status

| Command | Status |
|---|---|
| `vajra init` | **Works** — scaffolds `.ai/` workflow + hooks + cross-agent pointers (16 files, interactive, idempotent) |
| `vajra next` | **Works** — prints `.ai/` handoff packet; `--advance` bumps session + pointers |
| `vajra check` | **Works** — drift detection + readiness scoring (10 checks, pass/fail + score) |
| `vajra claude` | **Works** — launches Claude Code with compression hook and prints a receipt |
| `vajra meter` | **Works** — prints cost receipt for any past session |
| `vajra <agent>` | **Not built yet** — only Claude Code is wired; Codex and Cursor planned |

## The Workflow (the product)

Vajra enforces disciplined sessions: the `.ai/` rules, one branch per session, a verify gate that fails closed, drift detection, a NO-CODE audit every 5th session.

| # | Job | Plain meaning |
|---|---|---|
| 1 | **Guides the workflow** | Tells the agent the right step, in the right order, start to finish |
| 2 | **Keeps memory** | Feeds the agent what the product is, the roadmap, the rules — so it never forgets between chats |
| 3 | **Enforces discipline** | One branch per step, one step at a time — no drift, no chaos |
| 4 | **Saves a few tokens** *(bonus)* | Trims long successful output before the agent sees it; failures pass through untouched |

## How You Use It

```bash
vajra init              # scaffold .ai/ workflow in any repo
vajra claude            # launch Claude Code with workflow hook + receipt
vajra next              # print the current step + all its context
vajra next --advance    # bump to the next session
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

Blended savings are modest — roughly 6-8% of input token cost. The receipt shows you the real number; decide for yourself if it's worth it. The bigger value is context window space: compressed output means more room for the agent to think before hitting the context limit.

## The Receipt

After every session:

```
─── vajra · f69a7a7 ───────────────────────────────────────────
 $33.4976  total  (opus-4-6 90 lines)
         input $0.0019 · output $5.7320 · cache-r $12.1255 · cache-w $15.6383
         262 lines folded across 12 tool calls
         ~$0.0491 saved (est. ~3144 input tokens not billed)
─────────────────────────────────────────────────────────
```

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
