# Vajra

> One CLI for AI coding sessions — today: `vajra claude` for Claude Code and `vajra next` for agent handoff context.

## Current Status

- `vajra claude` works today for Claude Code: it injects Vajra's hook, compresses successful Bash output, and prints a receipt.
- `vajra next` now prints the current `.ai/` handoff packet, `VISION.md`, and the active prompt pointer for any agent.
- Not done yet: automatic session advancement, non-Claude launchers, and full cross-agent workflow enforcement.

## What It Does

Vajra intercepts successful tool output *before the model reads it*. A 180-line `cargo build` becomes one line. A passing test suite becomes a summary. Failures always pass through untouched — the agent must see real errors.

This is fundamentally different from telling the agent to "ignore verbose output" in a prompt. That still bills every token. Vajra's PostToolUse hook fires before the model ingests the output, so compressed tokens are never billed.

After the session, Vajra prints an honest receipt: actual tokens, actual dollars, lines folded. No vibes — real numbers you can verify against your Claude dashboard.

## Quick Start

```bash
cargo install vajractl
vajra claude    # Claude Code with Vajra's hook injected
vajra next      # print the current agent handoff packet
```

`vajra launch` still works as a legacy alias. `vajra claude` injects a PostToolUse hook via `claude --settings`, compresses successful Bash output, and cleans up on exit.

## What Gets Compressed

| Tool output | What happens |
|---|---|
| `cargo build` (180 lines, exit 0) | `✓ cargo build — Finished dev profile (180 crates compiled)` |
| `cargo test` (84 lines, all pass) | `✓ cargo test — test result: ok. 41 passed` |
| `git log` (long) | First 10 commits + count |
| `npm test` / `pytest` (pass) | One-line summary |
| Any command (exit ≠ 0) | **Verbatim — never compressed** |
| Any command (< 30 lines) | **Verbatim — too short to bother** |
| Non-Bash tools (Read, Edit, etc.) | **Verbatim — not touched** |
| `VAJRA_RAW=1 vajra launch` | **Everything verbatim — full bypass** |

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

## Honest Savings

Blended savings are modest — roughly 6-8% of input token cost. On a $20/month Claude Pro plan, that's small. On higher-volume usage, it scales. The receipt shows you the real number; decide for yourself if it's worth it.

The bigger value is context window space: compressed output means more room for the agent to think before hitting the context limit.

## Known Limitations

- **`vajra claude` is Claude Code only today** — it uses the CC PostToolUse hook mechanism. `vajra next` is agent-agnostic because it only prints repo workflow context.
- **Vendor-contract dependency** — `updatedToolOutput` is a CC hook feature with no stability guarantee. If Anthropic changes it, Vajra falls back to passthrough (fail-open, never breaks your session).
- **Exit 0 with stderr warnings** — `cargo build` that succeeds with warnings: the warnings summary is preserved in stderr, but individual warning details in stdout are folded. The agent knows warnings exist but may need to re-run to see specifics.
- **Savings estimates are rough** — the "tokens saved" number uses ~12 tokens/line as an estimate. Actual savings depend on your workload.

## How It Works

1. `vajra launch` reads your Claude Code hook config from `~/.claude/settings.json` and `.claude/settings.json`
2. Merges Vajra's PostToolUse hook entry (never clobbers your existing hooks)
3. Writes a temp settings file, spawns `claude --settings <tempfile>`
4. On every Bash tool call, the hook compresses successful output and passes failures through
5. On exit, reads the session JSONL and prints the receipt
6. Cleans up the temp file

## Environment Variables

| Variable | Effect |
|---|---|
| `VAJRA_RAW=1` | Disable all compression — full output passthrough |
| `VAJRA_QUIET=1` | Suppress the end-of-session receipt |
| `VAJRA_DEBUG=1` | Print temp settings path and merge details |
| `VAJRA_VERBOSE=1` | Expanded per-model receipt breakdown |

## Roadmap

Audit ledger (v2) earns its way in once it exists. No governance claims until there's a working tamper-evident ledger to back them up.

## License

Apache-2.0
