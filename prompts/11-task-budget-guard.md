# Session 11 — Budget Guard

## Goal
Add `budget_cap_usd` to CONSTRAINTS.yaml and enforce it in the launcher. When cumulative spend exceeds the cap, warn or kill the session.

## Context
- The meter already parses session JSONL and calculates cost (ADR-0004, proven S07).
- GSD and SuperClaude have no cost enforcement — this is a differentiator.
- Budget check lives in the launcher run loop, not a separate command.

## Deliverables
1. Add `budget_cap_usd` field to CONSTRAINTS.yaml schema
2. Launcher reads the cap before spawning `claude`
3. After session exit, meter checks cumulative spend against cap
4. If over cap: print warning + exit non-zero (kill mode) or warning-only (warn mode)
5. Tests for cap enforcement logic

## Cleanup from S10 Audit
- Fix STATE.md test count (32 → 71)
- Fix ROADMAP.md "What Does NOT Work Yet" section (move done items out)
- Investigate and resolve missing session-06-summary.md

## Constraints
- Max 1 story
- Max 3 files per atomic commit
- Branch: `session-11-budget-guard`
