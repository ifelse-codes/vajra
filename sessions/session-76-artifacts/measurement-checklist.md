# S76 dogfood ride-along — measurement checklist (written BEFORE any paid token)

> Per prompt step 1: stage capture paths + write this checklist before spending. The agent
> prepares/captures/derives/reports; **the founder issues the paid prompt(s)** (founder-led is
> load-bearing — the run measures the product, not the agent).

## Pre-run harness facts (established this session, $0)

| Fact | Evidence | Consequence for capture |
|---|---|---|
| Interactive CC JSONL carries **no** `total_cost_usd` and **no** `type:"result"` line | 89 session JSONLs under `~/.claude/projects/-Users-suman-playground-vajra/`, all zero (grep) | Authoritative cost (crit 1/3) exists **only in headless `claude -p`** → founder must drive **`vajra claude -p "<task>"`** (S63's mode; its $1.2662 came from a `type:"result"` line) |
| vajra reads authoritative cost **only** from `type:"result"` | `src/meter/mod.rs:241` (`parse_jsonl`) | Confirms the above — an interactive run's receipt would fall back to labeled `[estimate]` + "no total_cost_usd" warning |
| Compression sidecar `$TMPDIR/vajra-stats-<pid>-<ns>.jsonl` is **auto-deleted** after the receipt prints | `src/cli/launch.rs:121` | Raw fold file is not capturable post-run; the **receipt stderr** reports the fold total (or omits the line ⇒ 0 folds). Capture stderr. |
| Governance hooks (session-guard, pre-bash/no-commit, copilot-loader, drift-guard, stop) come from the **project's** `.claude/settings.json`, NOT from vajra's inject | `src/launcher/mod.rs` injects only the PostToolUse compression hook | Governance FIRES only inside a **vajra-governed repo** (has `.claude/settings.json`). In a foreign repo those hooks are **DORMANT** (a real, recordable reading). |
| Receipt prints to **stderr** on exit | `src/cli/launch.rs:175` (`eprint!`) | Capture with `2> >(tee ...)`. |
| Binary: `~/.cargo/bin/vajra` (installed) + `target/release/vajra` (built 07-18) | `command -v` / `ls` | Confirm the run uses a **current** binary (`cargo install --path .` or `target/release/vajra`) so we measure today's pipeline, not a stale install. |

## Resolved run setup (founder pick + agent prep)
- **Target repo:** `/Users/suman/playground/chitra` — L3, vajra-governed (subset: session-start·copilot-loader·session-guard wired; **no-commit/pre-bash NOT wired** → a real DORMANT cell).
- **Task (natural progression):** chitra **S07 = CI workflows** — the next roadmap item after S06's dist build. Derived by the agent from chitra's own ROADMAP/state; issued by the founder. Full text: `task-prompt.txt`.
- **Run shape:** headless (`vajra claude -p`) via `capture.sh`, from a **clean chitra main** (S06 done; partial S07 WIP backed up to scratchpad, junk moved aside, empty session-07 branch dropped).
- **Binary:** `target/release/vajra` (current, sha `d913848…`) — NOT the stale Jul-2 install.
- **Scope guard:** task tells the governed instance to STOP before push/PR (founder reviews the branch).

## Capture targets (each cell of the report must trace to a file here)
1. **Cost (crit 1,3):** `receipt.stderr.txt` (receipt block) + `run.jsonl` (copied transcript) + `total_cost_usd.txt` (the verbatim `type:"result"` line).
2. **Gates-fired table (crit 2):** `hooks.log` — Darshan ack · Varta copilot-loader · session-guard · no-commit (pre-bash) · compression fold count · receipt → FIRED/DORMANT + helped/neutral/hindered, each from an artifact.
3. **Compression (crit 3):** fold count read from the receipt (0 = a recorded 0; never-claim-until-measured holds either way).
4. **Obedience:** did the governed instance follow the governed workflow? note + evidence line.
5. **Bugs:** recorded as S77 candidates, **not fixed** (1-story / S63 stance).

## Honest-nulls rule (S63)
"No gate fired" and "0 folds" are RESULTS — recorded plainly, never dressed up, never omitted.
