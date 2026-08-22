---
role: implementation-advisor
session: 127
agent: claude-code-subagent
source-sha: e2960d6780bcd35e7eac865e5b06f0d5658fbee23f28b32b01cf3ff07ed064d4
captured: 2026-08-22T02:33:52Z
cost_usd: null
---

# Implementation-advisor handoff — session 127

## Implementation Advisor brief — Session 127, plan steps 1–6

**What I read:** the S127 prompt in full, `src/advice/mod.rs`, `src/coder/mod.rs`, `src/architect/mod.rs`, `src/fleet/mod.rs` (write side + the S112 read side + its tests), `src/analyst/mod.rs` (`parse_delta`, `find_prompt_for`, `FLEET_HEAD_LINES`), `src/cli/next.rs`, `src/stations/mod.rs`, `src/main.rs`, `scripts/verify-session-121.sh`, `scripts/verify-session-126.sh`, `.ai/KNOWLEDGE.md` (S122/S123 fixture lessons), `.ai/handoffs/session-126-design-advisor.md` (a real handoff body, as a parser subject).

**State I could not verify:** I have no Bash, so I cannot read git. `src/advice/mod.rs` already exists and already carries the step-1 grammar decision, the rejected alternatives, and the types — so step 1 looks landed. I name no sha for it. Resolve the real commit yourself and only then write `step 1 — done: <sha>`.

### Step 1 — the marker grammar (covers: 7)

rec 1 — keep the landed grammar and pin it in code as one shared "strip then anchor" helper used by BOTH parsers, with the separator set em-dash / en-dash / hyphen / colon.

The anchor is the defence against `rec` in prose and against `record 7 items` parsing as `rec`+`ord`. Require a whitespace boundary after `rec`, then digits, then exactly one separator, then non-empty text. Bold wrappers, list markers and ordered items must all strip first.

rec 2 — adopt an explicit direction-of-error rule, different on each side, and write it into the module header: on the handoff side, when in doubt COUNT (more items to answer); on the prompt side, when in doubt DON'T CREDIT (fewer claimed answers).

Concretely this decides three ambiguous cases: fenced code blocks are skipped on BOTH sides (the S127 prompt itself contains example `rec 1 — …` lines inside fences, which would manufacture phantom recommendations and phantom answers on day one); blockquote lines are counted in the handoff but skipped in the prompt; `<...>` placeholders are never recorded.

rec 3 — parse recommendations out of the handoff's RAW findings region, not out of `fleet::Handoff.body` — `handoff_body` drops every `#` line, so a rec written as `### rec 3 — …` would be silently under-counted, which is the exact defect this session exists to kill.

Smallest honest fix: add `handoff_findings_raw` to `src/fleet/mod.rs`, have `handoff_body` call it (one span, one source of truth), and add `pub raw_body: String` to `fleet::Handoff`. `Handoff` is constructed in exactly one place (`parse_handoff`), and every consumer reads named fields, so adding a field compiles everywhere.

rec 4 — record two more rejected alternatives in the module header and the DECISION-007 addendum: bare ordinals (`1.` as the recommendation number) and a role-qualified number (`design-advisor/2`).

Bare ordinals would turn ordinary prose lists into gate-binding claims. A role-qualified number duplicates the `role:` frontmatter the gate already trusts as the placement source of truth, and lets a role mislabel itself.

rec 5 — add a fifth `AdviceState` variant for malformed handoffs; the landed enum cannot express the case the prompt's `## Design` requires to fail closed.

With four variants a malformed handoff collapses into `NoHandoffs` — a silent pass, and the fakest green a cold reviewer will find first. Add `Malformed(Vec<(String, String)>)` and extend `blocks()`. This is the first consumer for which a malformed handoff is binding rather than merely surfaced; say so in the addendum.

### Step 2 — teach the roles to number (covers: 7)

rec 6 — put the numbering rule in each role's own `system_prompt` const, not in `render_subagent_definition`, and make the "tenth role cannot skip it" tooth a loop test over `ROLES`.

Criterion 7 says "Every advisory role's system prompt instructs it… Asserted per role". Central injection into the renderer would make skipping structurally impossible — that is its real merit, and it deserves a sentence in the addendum as the rejected runner-up. I still recommend per-role text: `system_prompt` is the role's whole contract today and every existing content test reads it that way.

rec 7 — split step 2 across four commits: it touches TEN files, and this team's limit is three per commit.

`src/fleet/mod.rs` plus the nine committed renders under `.claude/agents/`. Regenerate by running `vajra init` into a throwaway directory and copying the nine files in, rather than running it in the repo. Record `step 2 — done: <sha>` against the commit that COMPLETES the step, not the first one.

rec 8 — bind the role text to the parser with a round-trip test, and do NOT grep that sentence from `scripts/verify-session-127.sh`.

For every `fleet::ROLES` entry, assert the rendered definition contains the marker fragment AND feed the literal example line from that prompt through the recommendation parser, asserting it yields exactly one item numbered 1. That is what makes the instruction and the parser one thing rather than two. A verify-script grep for the sentence is a hollow source grep and would also trip `verify-session-121.sh`'s one-source-of-role-text guards.

### Step 3 — parse recommendations out of a handoff (covers: 1)

rec 9 — ship one pure function with no fs edge, dedupe by number keeping the FIRST occurrence, and delete the `_uses` stub.

First-wins on a duplicate number is deliberately the opposite of `coder::execution_records`' last-wins, where authors append as work lands; say why in a comment so it does not read as an inconsistency. Clip nothing in the parser — clip in the formatter.

### Step 4 — parse the `## Advice` dispositions (covers: 1, 2)

rec 10 — split each disposition line at the FIRST `rec <digits>` boundary, take everything before it as the role key, and validate that key against `fleet::resolve_role` — an unknown key is an orphan, never a match.

Role keys contain hyphens but never the token `rec`, so the split is unambiguous. Reject a role half that `resolve_role` does not know and surface it in `orphans` — a typo'd role key must never silently answer a real recommendation.

rec 11 — last-wins on duplicate `<role> rec N` lines, and surface orphan dispositions as warnings that never create a pass.

Authors edit and append in `## Advice` exactly as they do in `## Execution`, so last-wins is right here — and is the opposite of rec 9's first-wins, for the same documented reason.

### Step 5 — existence-gate each disposition (covers: 3, 4, 5)

rec 12 — classify with INJECTED existence closures, exactly as `coder::exec_report` does, so the whole classification is unit-testable without a repo and without an fs.

At the edge, reuse what exists — write no new git code: `coder::commit_exists` is already `pub` and already runs `git cat-file -e <sha>^{commit}`.

rec 13 — the three evidence rules, precisely, with the `refused:` floor disclosed rather than invented.

For `refused:` apply the S61 rule verbatim and nothing more: non-empty after trimming, and not starting with `<`. Do NOT invent a word-count threshold and do NOT add a stop-word list ("tbd", "n/a") — S122's lesson is that a guard bound to a spelling gets escaped by the next instance, and a length threshold is a judgement dressed as a check. Disclose the floor instead: a one-word reason passes; the gate checks that a reason was written, never that it is sound. For `obeyed:` take the leading hex run so trailing punctuation falls off, and reject a placeholder. For `deferred:` reject an absolute path and any `..` component before touching the fs.

### Step 6 — wire `--advice` / `--check-advice` (covers: 2, 6)

rec 14 — compose `advice_report` + `advice_gate` + `format_advice_checklist` field-for-field on the Coder's shapes, with an explicit state precedence, and make the surface INLINE the recommendation text (a path is not consumption, S112).

Precedence, stated in the doc comment so it is a decision and not an accident: Malformed (BLOCK, fail closed), then Unanswered (BLOCK), then NoRecommendations (WARN, dodge named), then Answered (PASS), then NoHandoffs (silent). Malformed and Unanswered can coexist; push a reason for each. Criterion 1 requires the block message to name the role, the number and the handoff path — build it from parsed data, never from a hand-typed role name.

rec 15 — the `NoRecommendations` WARN must name the dodge in the gate's own output, in plain words, sourced from one string that the summary quotes.

Criterion 6 requires the summary to repeat it; write the sentence once in the gate and quote it there, rather than re-typing a second version that can drift.

rec 16 — CLI wiring: two arms in `cli::next::run` immediately after the `--check-exec` pair, and an `--advance` block immediately after the Coder gate, binding on `current`, with `VAJRA_SKIP_ADVICE_GATE=1`.

Bind on `current`, not `next` — the advice was given to, and answered by, the session being closed, the same argument the Coder block makes. Use a distinct env var so each stage overrides alone. Unlike QA/Demo-er, do not skip the check itself under the override: this gate is cheap and read-only.

### Step 8 — the falsifiability fixture for criterion 9

rec 17 — make the fixture a THREE-state drive of the real `advice_gate` over a rebuilt-clean subject, asserting `blocks()` behaviour and parsed labels — never a message string — so deleting the disposition-checking code turns it red and renaming a message does not.

State A (negative control, must be GREEN): one rec, one matching disposition with a real sha. Without this half, a gate that blocks unconditionally would pass the fixture. State B (must be RED): the same handoff, prompt rewritten from the template with the disposition line removed. State C (must be RED): disposition present but evidence unreal, in three sub-cases. Rewrite the prompt file from a single template string for every state; never mutate the previous state's file in place — that is the exact S122 defect.

rec 18 — add the execute-based twin in `scripts/verify-session-127.sh`: drive the REAL binary over the same three states in a temp repo and assert exit codes 0 / 1 / 1.

Criterion 1 says "proven by running the real binary, not by reading source", and this is also what keeps the suite out of the hollow-grep class. Assert on the exit code and on the presence of the parsed label in stdout — not on the prose around it.

### Trace honesty

rec 19 — record each `step N — done: <sha>` only after that commit exists, and answer every one of these recommendations in `## Advice` — including the ones you refuse.

Two specific traps in this session: step 2 lands as four commits (rec 7) — record the completing one; and this brief creates 19 numbered items, so the session's own `## Advice` needs 19 lines under the key `implementation-advisor`. I expect several to be answered `refused:` or `deferred:` — a refusal with a written reason is a pass by design.

**What I am not proposing:** any change to `src/stations/mod.rs`, to `K of 8`'s derivation, to `src/main.rs`, or to any other station's evidence contract.

## Handoff Delta
- `+` new: first implementation-advisor handoff for this session (11149 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
