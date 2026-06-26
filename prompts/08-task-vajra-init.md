# Session 08 — Build `vajra init` + Formalize Demo Scripts

## Trigger
User picked Option A from `sessions/session-07-summary.md`.

## Goal
Build `vajra init` — the most adoption-critical command. Scaffolds `.ai/` directory in a new repo so any coding agent can follow the Vajra workflow. Also formalize demo scripts as a first-class concept alongside verify scripts.

## Deliverables
- `vajra init` CLI command that scaffolds `.ai/` in the current directory.
- Files created: AGENTS.md, SESSION, SESSION-BOOT.md, TASK.md, STATE.md, CONSTRAINTS.yaml, KNOWLEDGE.md, ROADMAP.md, plus `scripts/`, `prompts/`, `sessions/` directories.
- Cross-agent pointers: CLAUDE.md, AGENTS.md (root), .cursorrules.
- Hook scripts for Claude Code: `.claude/settings.json` with session hooks.
- Interactive: asks project name + first session goal (max 2 questions).
- Idempotent: skips files that already exist.
- Tests for the scaffolding logic.
- **Demo script formalization:**
  - Add `demo:` section to `.ai/CONSTRAINTS.yaml`.
  - Add DEMO step to session loop in `.ai/AGENTS.md`.
  - Create `scripts/demo-session-template.sh` for scaffolded projects.
  - Write `scripts/demo-session-08.sh` — cumulative demo showing `vajra init` + prior capabilities.

## Demo Script Concept
- **Verify scripts** = correctness (exit 0/1, CI-safe, timestamped artifacts).
- **Demo scripts** = visual assurance (narrative, colored output, mock/real data).
- Demos are **cumulative** — each session's demo includes prior session capabilities.
- Required elements: header, labeled cases, summary table.
- Template: `scripts/demo-session-template.sh`.
- Pattern: `scripts/demo-session-{NN}.sh`.

## Design Rules (from competitive analysis)
- Max 2 questions — steal GSD's friction model.
- Must be as fast as `npx gsd init`.
- Generated files should be minimal — < 5% context footprint.
- Templates should be self-contained (no network calls).

## Constraints Operative
- Max 2 assumptions. Max 2 retries.
- Max 3 files per atomic commit.
- Generated AGENTS.md should be a simplified version of the current one, not a copy.
- No installer / release path work — just the command.

## Exit Criteria
- `vajra init` works in a fresh temp directory.
- Idempotent: running twice doesn't overwrite existing files.
- `cargo test`, `cargo clippy` pass.
- `scripts/demo-session-08.sh` runs and shows cumulative capabilities.
- Session verify script passes.
- Exactly 3 Session 09 options presented.

## Explicit Non-Goals
- `vajra check` or `vajra next` advancement
- Multi-agent launcher work
- Installer / release path
