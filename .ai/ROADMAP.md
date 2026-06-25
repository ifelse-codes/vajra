# Vajra — Working Roadmap

**Updated:** 2026-06-25 · Vision alignment pass.

**North star:** `vajra next` as the cross-agent workflow coach. One command that advances the agent to the next step with the right context.

## Where We Are

| Field | Value |
|---|---|
| Today | 2026-06-25 |
| Current phase | Phase 0 — Foundation |
| Last closed session | Session 05 — Ground Truth audit |
| Active session | Session 06 — vision alignment |
| Crate | package `vajractl` · binary `vajra` |

## What Works Today

| Component | Status |
|---|---|
| Engine trait + heuristics | [x] done — compresses cargo/git/npm/pytest output, tests pass against fixtures |
| Claude Code hook adapter | [x] done — reads CC PostToolUse JSON, returns compressed output |
| Launcher + settings injector | [x] done — merges hook config, spawns `claude --settings <tmpfile>` |
| `vajra claude` command | [x] done — launches Claude Code with hook injection, prints receipt on exit |
| Meter + receipt | [x] done — parses session JSONL, prints honest cost breakdown |
| `vajra next` (read-only) | [x] done — prints `.ai/` handoff packet + VISION.md + prompt pointer |

## What Does NOT Work Yet

| Component | Status |
|---|---|
| `vajra next` session advancement | [ ] stub — prints the packet, does not advance the loop |
| `vajra init` | [ ] not built |
| `vajra verify` / `vajra check` | [ ] not built (scripts exist, no CLI) |
| Settings injection — live proof | [ ] unproven — never tested in a full real session |
| Second agent launcher | [ ] not built — only Claude Code is wired |
| Installer / release pipeline | [ ] not built |

## Roadmap (in priority order)

### Phase 1 — Prove the core works for real

1. **Prove `vajra claude` in a real session** — run `vajra claude` on this repo, confirm: (a) existing user hooks survive the merge (additive `--settings`), (b) the PostToolUse hook fires and compresses real output, (c) the receipt prints real dollar numbers. Pass/fail is binary.

2. **Build `vajra init`** — scaffolds the `.ai/` directory in a new repo: creates `AGENTS.md`, `SESSION`, `SESSION-BOOT.md`, `TASK.md`, `STATE.md`, `CONSTRAINTS.yaml`, `KNOWLEDGE.md`, `ROADMAP.md`, plus `scripts/verify-closeout.sh` and `prompts/` dir. Interactive: asks project name, first session goal. Idempotent: skips files that already exist.

3. **Build `vajra verify`** — runs `scripts/verify-session-{NN}.sh` for the current session (reads `.ai/SESSION`). Exits 0 if the script passes, exits 1 if it fails. If no verify script exists, prints a warning and exits 1. This is the CLI wrapper around the existing verify scripts.

4. **Build `vajra check`** — drift detection: reads `.ai/STATE.md` and compares claims against actual repo state (branch name, session number, file existence). Prints a pass/fail checklist. No side effects.

5. **Make `vajra next` advance the session** — the single most important feature. Today it dumps the packet. It needs to: (a) bump `.ai/SESSION`, (b) update `SESSION-BOOT.md` pointer, (c) print the next step's context. Move from "dump" to "advance."

6. **Prove `vajra next` walks a real session start to finish** — the north star test. Run a real multi-step project where `vajra next` drives the loop. If it doesn't work end-to-end, it's not done.

### Phase 2 — Prove vendor-neutral is real

7. **Add a second agent** (e.g., Codex, Cursor, or Aider) — prove `vajra <agent>` works with something other than Claude Code. The workflow commands (`init`, `next`, `verify`, `check`) must work identically. The launcher is agent-specific.

8. **`vajra next` works identically across both agents** — the agent changes, the workflow doesn't. This is the proof that vendor-neutral is real, not a claim.

### Phase 3 — Ship it

9. **Installer / release path** — `cargo install vajractl`, Homebrew, signed releases, `curl | bash` installer with SHA-256 verification.
10. **Clean legacy references** — remove `vajra launch` alias and all references from code and docs.

### Phase 4 — Earn the next features

9. **Audit ledger (v2)** — git-native provenance, agent-trace format. Earns its way in once a working ledger exists. No governance claims until then.
10. **Multi-agent launchers** — Kimi, Kilo, Aider, Cursor, others.
11. **Policy enforcement, governed memory, MCP tools** — only after the core loop is proven.

## Rules For This Document

1. Update at every closeout.
2. NO-CODE audit sessions at 05, 10, 15, 20, 25.
3. Mark items `[x]` only when they work in a real session, not just in tests.
