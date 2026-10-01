---
role: design-advisor
session: 182
agent: claude-code-subagent (verified: toolu_01SBy6UMX7JbEJJNxBP88wek; text-sha: 747bddf33d6c7cce76f890dc9e2cce3eaf1e26ab13e6f0a2936315f51a14bc92)
source-sha: 26e6c9c3315da37dee2a2b1c4139673772af51233341487712f28b3218dbd8f9
captured: 2026-10-01T07:40:00Z
cost_usd: null
---

# Design-advisor handoff — session 182

# Design-advisor handoff — session 182

Two things first:
- Part 3 as written would ship a guard that never runs. `--sync-fleet` would copy the hook file into rudra, but nothing tells Claude Code to run it: rudra's `.claude/settings.json` lists only the hooks from its first install, and `--sync-fleet` never changes that file. Acceptance 3 and 8 could pass on file presence alone (rec 3).
- "Settings file" in the prompt is ambiguous. Part 4's settings file is `.ai/CONSTRAINTS.yaml`; Part 3 has to edit `.claude/settings.json` (rec 4).

## Proposed Design

design-significant: yes

Why yes: a new hook file shipped to every project, `--sync-fleet` now touching a project's `.claude/settings.json`, a changed `--allow-all` flag, and a new field in the allow-all record. None of this is a pure fix.

Follows docs/decisions/DECISION-011-controls-the-agent-cannot-type.md: it closes the Limit's last sentence ("Scaffolded projects do not yet get the Write/Bash hooks") and narrows decision 2 (`--allow-all` now approves one named session). Deviates from docs/decisions/DECISION-007-agent-fleet.md, S136 addendum, which kept `--sync-fleet` to rendered files; this session lets it also add Vajra's hook entries to `.claude/settings.json`, using the same add-only merge `vajra init` has used since S44. Recorded as an S182 addendum in DECISION-011.

Part 3 — one guard, one source. New `scripts/hook-approvals-guard.sh` checks both Bash commands and Edit/Write/MultiEdit/NotebookEdit paths. Built into the binary (`include_str!`) and added to SYNC_HOOKS as the stamped `.ai/hooks/hook-approvals-guard.sh`. Vajra's own hook-pre-bash.sh and hook-pre-write.sh call the same file. In the scaffold settings it is its own PreToolUse group (matcher "Bash|Edit|Write|MultiEdit|NotebookEdit"). `--sync-fleet` adds that group to an existing `.claude/settings.json` through the S44 add-only merge, keeps every user key, follows --dry-run. Rejected: file without settings entry (never runs, S129); hiding it inside hook-copilot-loader.sh; a manual "add this by hand" step.

Part 4 — report, never edit. `--sync-fleet` reads `.ai/CONSTRAINTS.yaml`; with no `session_rules_from:` line it prints the exact line to add, N = the next session that has not started (current + 1), reusing `approval::rules_from_hint`. It never writes the file. Rejected: auto-inserting (the founder's policy call; would switch a running session mid-way).

Part 5 — the session is named at launch. `vajra claude --allow-all=NN`. The record stores `session: NN` next to `pid`; it approves session N only while that launch is running. A bare `--allow-all` refuses before Claude starts and prints the form to type. Rejected: reading the session from the branch name (agent-typeable; `main` has no number).

Part 6 — block by where the write lands. Block when (1) a redirect (`>`, `>>`, `>|`, `&>`, `N>`) writes to a path under `.ai/approvals` (`N>&M`, `>&N` are not writes); or (2) a file-writing command (tee, cp, mv, rm, touch, sed -i, dd, install, ln, truncate) names the folder; or (3) the command `cd`s into the folder and contains any write word; or (4) an interpreter (python3, perl, node, ruby) names the folder — blocked with a message naming read-only alternatives (cat, ls, jq). Known gap, written down: a path hidden in a shell variable (`> "$D"/x`) gets through — bar-raising, not tamper-proof.

rec 1 — Record `design-significant: yes`. Cite DECISION-011 (followed) and DECISION-007's S136 addendum (deviated from), and write an S182 addendum in DECISION-011 rather than a new DECISION-012; it should also rewrite DECISION-011's Limit line about scaffolded projects.

rec 2 — Part 3: build one `scripts/hook-approvals-guard.sh` for Bash and Write-type tools, ship it stamped as `.ai/hooks/hook-approvals-guard.sh` via SYNC_HOOKS, and have Vajra's own hook-pre-bash.sh and hook-pre-write.sh call it (one source, S19).

rec 3 — Part 3: have `--sync-fleet` add the new guard to an old project's `.claude/settings.json` using the existing S44 merge (`merge_claude_settings`, `src/cli/init.rs:834`), as its own PreToolUse group, respecting `--dry-run`. `sync_fleet` (`init.rs:412`) never touches settings today; only plain `init` merges them (`init.rs:665`).

rec 4 — Change "settings file" in Deliverable 4 and Acceptance 4 and 8 to `.ai/CONSTRAINTS.yaml`.

rec 5 — Part 4: report only; reuse `approval::rules_from_hint`; suggest N = the next session that has not started.

rec 6 — Part 5: require the session number at launch (`--allow-all=NN`), store `session` in the allow-all record next to `pid`, and make a bare `--allow-all` refuse before Claude starts.

rec 7 — Part 6: block by where the write lands, using the four-part rule above; keep blocking interpreters naming the folder; add the `cd`-into-the-folder case; write down the shell-variable gap.

rec 8 — Add a fixture: merge an old project's existing settings file with the new template and assert every `.ai/hooks/*.sh` is listed exactly once (`init.rs:884` treats a group as present only if it lists every script the template group lists).

## Handoff Delta
- `+` new: first design-advisor handoff for this session (5098 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
