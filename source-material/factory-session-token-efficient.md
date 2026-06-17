# Factory Session — Token-Efficient AI Workflow

> **Same discipline, fewer tokens.**
> A lean scaffold that enforces session governance without burning context window on ceremony.

---

## The Token Problem with the Original

| Original Practice | Token Cost | Why It Hurts |
|---|---|---|
| Printing 5 `.ai/` files on every `SessionStart` | ~2-5K tokens/session | STATE.md + SESSION-BOOT.md + TASK.md + CONSTRAINTS.yaml all printed every boot |
| Verbose `AGENTS.md` constitution | ~3-4K tokens | Read every session; most content is static boilerplate |
| `hook-stop.sh` running verify on every stop | ~500-2K tokens | Bash output floods context with PASS/FAIL tables |
| Ground-truth audits re-reading entire `.ai/` directory | ~5-8K tokens | Full constitution + all state files re-scanned |
| 200-word response limit in constitution | N/A (constraint, not cost) | Actually *saves* tokens — keep this |

**Net effect:** Original scaffold costs **~5-10K tokens/session** in overhead. On a 200K context model, that's 2.5-5% per session. On Claude's context-limited tiers, it compounds fast.

---

## Token-Efficient Redesign Principles

| Principle | Implementation |
|---|---|
| **Lazy load** | Only print files that *changed* since last session |
| **Hash-based diff** | Track SHA256 of `.ai/` files; skip unchanged content |
| **Single-file constitution** | Merge AGENTS.md rules into CONSTRAINTS.yaml; agents read ONE file |
| **Silent hooks** | Hooks return exit codes only; no stdout unless blocking |
| **Compressed state** | STATE.md → bullet-only, no tables, <50 lines |
| **Ground truth = diff audit** | Only audit *changes* since last GT, not full re-read |
| **Verify on demand** | `hook-stop.sh` only warns; explicit `/verify` command runs checks |

---

## New Directory Structure (Lean)

```
.ai/
  SESSION              # 1 line: "00"
  MANIFEST             # 1 file: hashes of all .ai/ files + last boot session
  STATE.md             # <50 lines, bullets only, no tables
  TASK.md              # <20 lines, thin pointer only
  CONSTRAINTS.yaml     # constitution + machine rules merged (~80 lines)
  KNOWLEDGE.md         # append-only, loaded on demand
  ROADMAP.md           # loaded on demand
  verify/              # timestamped artifacts
.claude/
  settings.json        # 3 hooks only: Start (silent), PreBash (block), Stop (silent)
.githooks/
  pre-commit           # blocks main, >3 files, drift (no output on success)
  pre-push             # blocks main push (no output on success)
scripts/
  boot.sh              # silent hash-check; only prints diffs
  guard.sh             # exit code only; zero stdout on success
  verify.sh            # on-demand verification (not auto-run)
  init.sh              # one-time repo setup
  ai-session           # generic wrapper (prints only if hash changed)
prompts/
  00-task.md
sessions/
  00-summary.md
AGENTS.md              # 5-line pointer only
CLAUDE.md              # 5-line pointer only
.cursorrules           # 5-line pointer only
```

**File count:** ~15 files vs. ~25. **Token overhead:** ~500-1K/session vs. ~5-10K.

---

## The 3-Hook System (Silent by Default)

### `.claude/settings.json`

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "hooks": {
    "SessionStart": [{
      "hooks": [
        {"type": "command", "command": "bash "$CLAUDE_PROJECT_DIR/scripts/boot.sh""}
      ]
    }],
    "PreToolUse": [
      {"matcher": "Bash", "hooks": [
        {"type": "command", "command": "bash "$CLAUDE_PROJECT_DIR/scripts/guard.sh""}
      ]}
    ]
  }
}
```

**No `UserPromptSubmit` hook. No `Stop` hook. No `PreToolUse(Edit|Write)`.**

Why: Every hook that prints to stdout consumes tokens. We only keep:
- `SessionStart` — prints *diffs only* (not full files)
- `PreToolUse(Bash)` — blocks destructive commands silently (exit 2 = block, no message needed)

---

## Core Files (Token-Optimized)

### `.ai/SESSION`

```
00
```

**1 token.** No newline games.

### `.ai/MANIFEST`

```yaml
# SHA256 hashes of .ai/ files. Updated at every closeout.
# If hash matches last_boot, file is skipped on SessionStart.
last_boot_session: 00
files:
  STATE.md: abc123...
  TASK.md: def456...
  CONSTRAINTS.yaml: ghi789...
  KNOWLEDGE.md: jkl012...
  ROADMAP.md: mno345...
```

**~10 lines.** Single source of "what changed."

### `.ai/CONSTRAINTS.yaml` (Merged Constitution)

```yaml
version: 4

# === CONSTITUTION (was AGENTS.md) ===
project:
  name: {{PROJECT_NAME}}
  purpose: {{ONE_LINE_PURPOSE}}
  stack: {{PRIMARY_STACK}}
  owner: {{OWNER_NAME}}

agent_style:
  max_words: 200
  formats: [bullets, tables, code]
  forbid: [filler, greetings, trailing_summaries, narration]
  max_bullets_per_section: 5

# === SESSION RULES ===
session:
  max_assumptions: 2
  max_retries: 2
  max_files_per_change: 3
  max_stories: 1
  cap_hours: 2
  ground_truth_every_n: {{GROUND_TRUTH_N}}

branch:
  forbid: [main, master]
  pattern: '^session-\d{2,}-[a-z0-9-]+$'

commit:
  autonomous: false
  approval_tokens: [approved, lgtm, "ship it", yes, "go ahead"]
  forbid_force_push: [main, master]

# === LOAD ORDER ===
load_order:
  - .ai/CONSTRAINTS.yaml    # everything is here
  - .ai/SESSION             # current number
  - .ai/MANIFEST            # what changed
  - .ai/STATE.md            # current state
  - .ai/TASK.md             # current task
  - prompts/NN-task.md      # session brief

# === GROUND TRUTH ===
ground_truth:
  forbid_code: true
  forbid_commits: true
  audits: [drift, stale_facts, roadmap, costs]

# === TRUST ===
trust:
  forbidden_phrases: {{FORBIDDEN_PHRASES}}
```

**~60 lines.** One file replaces AGENTS.md + CONSTRAINTS.yaml. Agents read this first.

### `.ai/STATE.md` (Compressed)

```markdown
# State (snapshot)

## Branch
session-00-discovery

## PRs
none

## Works
- .ai/ scaffold installed
- Hooks active (silent)

## Broken
nothing

## In Progress
Session 00 closeout

## Costs
S00: $0.00 | Total: $0.00
```

**~15 lines.** No tables. Bullets only. <300 tokens.

### `.ai/TASK.md` (Thin Pointer)

```markdown
# Task

S00: Bootstrap — IN PROGRESS
Pick A/B/C from sessions/00-summary.md
```

**~5 lines.** <50 tokens.

---

## Scripts (Silent)

### `scripts/boot.sh`

```bash
#!/usr/bin/env bash
# Silent boot. Only prints files that changed since last session.
set -euo pipefail
ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

MANIFEST=".ai/MANIFEST"
CURRENT_SESSION="$(cat .ai/SESSION | tr -d ' \t\n\r')"

# If no manifest, first boot — print everything
if [ ! -f "$MANIFEST" ]; then
  echo "[boot] First boot. Reading all files..."
  for f in .ai/CONSTRAINTS.yaml .ai/STATE.md .ai/TASK.md; do
    echo "--- $f ---"
    cat "$f"
    echo ""
  done
  # Write initial manifest
  echo "last_boot_session: $CURRENT_SESSION" > "$MANIFEST"
  echo "files:" >> "$MANIFEST"
  for f in .ai/CONSTRAINTS.yaml .ai/STATE.md .ai/TASK.md .ai/KNOWLEDGE.md .ai/ROADMAP.md; do
    if [ -f "$f" ]; then
      h="$(sha256sum "$f" | cut -d' ' -f1)"
      echo "  $(basename $f): $h" >> "$MANIFEST"
    fi
  done
  exit 0
fi

# Check if session changed
LAST_BOOT="$(grep '^last_boot_session:' "$MANIFEST" | awk '{print $2}')"
if [ "$LAST_BOOT" != "$CURRENT_SESSION" ]; then
  echo "[boot] New session: $CURRENT_SESSION (was $LAST_BOOT)"
fi

# Check each file for changes
echo ""
CHANGED=0
for f in .ai/CONSTRAINTS.yaml .ai/STATE.md .ai/TASK.md; do
  if [ ! -f "$f" ]; then continue; fi
  CURRENT_HASH="$(sha256sum "$f" | cut -d' ' -f1)"
  STORED_HASH="$(grep "$(basename $f):" "$MANIFEST" | awk '{print $2}' || true)"
  if [ "$CURRENT_HASH" != "$STORED_HASH" ]; then
    echo "--- $f (CHANGED) ---"
    cat "$f"
    echo ""
    CHANGED=1
  fi
done

if [ "$CHANGED" -eq 0 ]; then
  echo "[boot] No changes since last boot. Session $CURRENT_SESSION ready."
fi

# Update manifest
sed -i "s/^last_boot_session:.*/last_boot_session: $CURRENT_SESSION/" "$MANIFEST"
for f in .ai/CONSTRAINTS.yaml .ai/STATE.md .ai/TASK.md .ai/KNOWLEDGE.md .ai/ROADMAP.md; do
  if [ ! -f "$f" ]; then continue; fi
  h="$(sha256sum "$f" | cut -d' ' -f1)"
  if grep -q "$(basename $f):" "$MANIFEST"; then
    sed -i "s|  $(basename $f):.*|  $(basename $f): $h|" "$MANIFEST"
  else
    echo "  $(basename $f): $h" >> "$MANIFEST"
  fi
done

BRANCH=$(git branch --show-current 2>/dev/null || echo "?")
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "[REMINDER] On $BRANCH. Branch session-NN-<slug> first."
fi
```

### `scripts/guard.sh`

```bash
#!/usr/bin/env bash
# Silent guard. Exit 2 = block. No stdout unless blocking.
set -euo pipefail

INPUT=$(cat 2>/dev/null || echo "{}")
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

ROOT="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
BRANCH=$(cd "$ROOT" && git branch --show-current 2>/dev/null || echo "?")

# Block commits on main
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  case "$CMD" in
    *"git commit"*|*"git push"*) exit 2 ;;
  esac
fi

# Ground truth block
GT_N={{GROUND_TRUTH_N}}
SNUM=$(echo "$BRANCH" | grep -oE 'session-[0-9]+' | grep -oE '[0-9]+' | head -1 || true)
if [[ "$SNUM" =~ ^[0-9]+$ ]] && [ "$((10#$SNUM))" -gt 0 ] && [ "$((10#$SNUM % GT_N))" -eq 0 ]; then
  case "$CMD" in
    *"git commit"*|*"git push"*|*"git merge"*|*"git rebase"*) exit 2 ;;
  esac
fi

exit 0
```

**Zero stdout on success.** Only exit codes matter.

### `scripts/verify.sh`

```bash
#!/usr/bin/env bash
# On-demand verification. NOT auto-run. User calls: /verify
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

N="$(cat .ai/SESSION | tr -d ' \t\n\r')"
PASS=0; FAIL=0

ok() { echo "✓ $1"; PASS=$((PASS+1)); }
bad() { echo "✗ $1"; FAIL=$((FAIL+1)); }

[ -f .ai/SESSION ] && ok "session-file" || bad "session-file"
[ -f .ai/CONSTRAINTS.yaml ] && ok "constitution" || bad "constitution"
[ -f .ai/STATE.md ] && ok "state" || bad "state"
[ -f .ai/TASK.md ] && ok "task" || bad "task"

BOOT_N="$(grep -m1 'last_boot_session:' .ai/MANIFEST | awk '{print $2}')"
[ "$BOOT_N" = "$N" ] && ok "manifest-sync" || bad "manifest-sync"

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "ALL GREEN ($PASS/5)"
  exit 0
else
  echo "RED ($FAIL fail)"
  exit 1
fi
```

**Only runs when user types `/verify`.** Not on every stop.

---

## Git Hooks (Silent)

### `.githooks/pre-commit`

```bash
#!/usr/bin/env bash
# Silent pre-commit. Exit 1 = block. No output on success.
set -euo pipefail
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || echo DETACHED)"
case "$branch" in main|master) exit 1 ;; esac

staged="$(git diff --cached --name-only --diff-filter=ACMR | wc -l | tr -d ' ')"
[ "${staged:-0}" -le {{MAX_FILES}} ] || exit 1

exit 0
```

### `.githooks/pre-push`

```bash
#!/usr/bin/env bash
# Silent pre-push.
set -euo pipefail
blocked=0
while read -r localref localsha remoteref remotesha; do
  case "$remoteref" in refs/heads/main|refs/heads/master) blocked=1 ;; esac
done
exit "$blocked"
```

**Zero output on success.** Fast. Silent.

---

## Ground Truth (Diff-Only Audit)

Instead of re-reading entire `.ai/` directory, GT sessions only audit *changes*:

```bash
# In GT session, run:
git diff session-$((NN - GT_N))-closeout..HEAD -- .ai/
```

This shows only what changed since last GT. **~200-500 tokens** vs. **~5-8K** for full re-read.

---

## Token Savings Summary

| Component | Original | Token-Efficient | Savings |
|---|---|---|---|
| Session boot | 5 files printed (~3K) | Diffs only (~200-500) | **~85%** |
| Constitution | AGENTS.md (~3K) + CONSTRAINTS.yaml (~1K) | Merged (~1K) | **~75%** |
| Hooks | 6 hooks, verbose output | 2 hooks, silent | **~90%** |
| Verify | Auto-run every stop (~1K) | On-demand only | **~95%** |
| Ground truth | Full re-read (~6K) | Diff-only (~400) | **~93%** |
| STATE.md | Verbose with tables (~1K) | Bullets only (~300) | **~70%** |
| **TOTAL/session** | **~10-15K tokens** | **~1-2K tokens** | **~85-90%** |

On a 200K context model running 50 sessions: **500K-750K tokens saved**.
At $3/M tokens (Claude 3.5 Sonnet): **$1.50-2.25 saved per project**.

At scale (Factory managing 100 projects × 50 sessions): **$150-225 saved**.

---

## What You Lose (And Why It's OK)

| Lost Feature | Impact | Mitigation |
|---|---|---|
| `hook-stop.sh` auto-verify | Must remember to `/verify` | Habit-forming; constitution reminds |
| `hook-pre-write.sh` GT block | Could edit files during GT | `guard.sh` blocks git ops; manual discipline for edits |
| `hook-prompt-submit.sh` main warning | Less nagging | `boot.sh` prints branch reminder once |
| `hook-drift-guard.sh` cross-check | No auto drift detection | `/verify` catches it; GT audit catches it |
| Verbose `hook-pre-bash.sh` warnings | No "are you sure?" prompts | Silent block is actually cleaner |

**Trade-off:** Slightly more manual discipline for **~85% token savings**.

---

## Quick Start (Token-Efficient)

```bash
# One-time setup
curl -fsSL ... | bash

# Per session
# 1. Agent reads .ai/CONSTRAINTS.yaml (1 file, ~1K tokens)
# 2. Agent reads .ai/STATE.md if hash changed (~300 tokens)
# 3. Agent reads .ai/TASK.md if hash changed (~50 tokens)
# 4. Work happens
# 5. User types: /verify (only if needed)
# 6. Closeout updates MANIFEST + STATE (no re-print)
```

---

## License

MIT
