# S129 step 1 — the fork, measured before it was touched

**Method:** a real `mktemp -d`, a real `git init`, the real `target/release/vajra init`
(commit `e3b1fa3`, the S128 merge). The scaffold side is read from the FILES A STRANGER
RECEIVES, never from the template constants that produce them.

## Headline

| | a stranger receives | this repo runs on | verdict |
|---|---|---|---|
| constitution | `.ai/AGENTS.md`, **66** lines | `.ai/AGENTS.md`, **183** lines | fork |
| binding rules (Hard Rules table) | **8** | **13** | **5 missing, 2 renamed** |
| `required_audits` | **7** | **11** | **4 missing** |

## Rule by rule

| live rule (`.ai/AGENTS.md`) | in the scaffold? |
|---|---|
| Max 2 assumptions | carried, verbatim |
| Max 2 error retries | carried, **RENAMED** → "Max 2 retries" |
| No autonomous commits | carried, verbatim |
| No `main` commits | carried, verbatim |
| No code in Ground Truth | **MISSING** |
| Verification = exit 0 | carried, verbatim |
| State is snapshot | **MISSING** |
| Max 1 story per session | **MISSING** |
| Max 3 files per atomic commit | carried, **RENAMED** → "Max 3 files per commit" |
| ~2h per session cap | **MISSING** |
| One vajra-session per chat | **MISSING** |
| **Fidelity ≠ discipline** | carried, de-bolded, detail shortened |
| **No self-certification** | carried, de-bolded, detail shortened |

**None of the five omissions has a reason on record, and every one of them is already
true of the scaffold elsewhere.** Its `CONSTRAINTS.yaml` sets `forbid_code_changes: true`,
`max_stories_per_session: 1`, `cap_hours_per_session: 2`, `one_session_per_chat: true` and
`state_md_mode: snapshot`; its `hook-session-start.sh` prints the ground-truth NO-CODE
reminder; its `.githooks/pre-commit` blocks a `main` commit. **The scaffold's prose
contradicts the scaffold's own machine-readable rules.** That is drift, not design.

The two renames are worse than cosmetic: they are why no equality check was ever possible.

## Audit by audit

| live audit | in the scaffold? | portable? |
|---|---|---|
| vision_alignment · roadmap_alignment · state_drift · knowledge_staleness · constraint_violation_review · constitution_review · cost_review | carried (7) | yes |
| dogfood_check | **MISSING** | yes — the question list asks whether real work ran through `vajra claude`; every stranger has that binary |
| pipeline_advance_check | **MISSING** | yes — evidence is `vajra next --stations NN`, a command the stranger's binary already has |
| dogfood_staleness | **MISSING** | yes — evidence is `vajra next --dogfood-age`, same |
| stranger_check | **MISSING** | **NO** — its evidence is `scripts/stranger-check.sh`, Vajra's own first-contact harness, which the scaffold does not ship |

Three of the four are missing for no reason at all. The fourth is the one S128 refused to
add, and its refusal was right — but the refusal was recorded in a prompt, where nothing
reads it, instead of in a declaration a check can enforce.

## What the measurement proves about the class

`scripts/verify-closeout.sh` is `include_str!`'d into the scaffold and is byte-identical in
both places, so S128's bash-3.2 fix reached every future scaffold for free. Everything that
drifted is hand-typed. **The mechanism is the whole difference.**
