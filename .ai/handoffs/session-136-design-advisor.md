---
role: design-advisor
session: 136
agent: claude-code-subagent (verified: toolu_01Vm6P9VswDBmZoPqKHVHNAt)
source-sha: 7928937277a87bce133d889c3ac3f2fd61c69c559972f5a698492790795383d2
captured: 2026-08-28T08:33:22Z
cost_usd: null
---

# Design-advisor handoff — session 136

# Design Advisory — Session 136 (chitra fleet upgrade path)

## Q1 — BUILD or DOCUMENT

**Verdict: BUILD.** Not a menu.

The reason this is bounded rather than open-ended is structural, not aspirational: `src/cli/init.rs:594-599` already contains the exact loop an upgrade mechanism needs — `for role in crate::fleet::ROLES { entries.push(f(&role.subagent_rel(), &crate::fleet::render_subagent_definition(role))); }` — and `scaffold()` (init.rs:59-105) already contains the per-entry exists-check/write/skip branching that would drive it. An upgrade command for the fleet specifically is not new machinery; it is the same loop, re-entered and scoped down from the ~40-entry `files()` list to just `fleet::ROLES`. That is a small, well-understood diff (roughly one new function plus a thin CLI flag), fits the ~2h/1-story/3-files cap, and closes the session's own headline finding ("no upgrade path exists") instead of merely writing it down again. DOCUMENT-only would be the honest fallback only if the mechanism were genuinely unbounded — it isn't.

## Q2 — Smallest correct surface

- **Rides a flag, not a new command.** `vajra init --sync-fleet` (reuses init.rs's own mechanism directly) or `vajra next --sync-fleet` (matches the stated "new surfaces ride `next --flag`" convention) — either keeps the command count at 7. I lean toward `init` because the code it reuses already lives there, but this is a builder call, not a fence.
- **Re-enters `fleet::ROLES` / `render_subagent_definition`, never a second scaffolding path** — this is the tech-lead's rec 2 and I concur; it is also the only way the change stays inside 3 files.
- **MISSING files** (the six roles + tech-lead): auto-create unconditionally. This is the existing, already-safe skip-if-present "create" branch, just scoped to the fleet loop.
- **Files that already byte-match canonical**: no-op, reported as "up to date."
- **STALE / drifted files** (chitra's four): the command must default to **WARN, never silently overwrite**. A real overwrite needs an explicit second flag (`--overwrite-drifted` / `--force`).
- **Needs a dry-run.** `--dry-run` should preview create/skip/drift-warn with zero writes — the guardrail explicitly makes clobbering a local edit worse than no command, so the default run of `--sync-fleet` (no force flag) should itself already be non-destructive by construction, and `--dry-run` is a cheap second belt.

## Q3 — Can the command tell MISSING / STALE-UNMODIFIED / USER-EDITED apart?

**MISSING vs PRESENT: yes, trivially** (file exists or not). **STALE-UNMODIFIED vs USER-EDITED: no.** Both produce the identical observable signal — on-disk bytes differ from `render_subagent_definition`'s current output — and nothing in the repo stores which render produced a given file (no embedded version stamp, no manifest, no git-attributable "generated-by" marker). A byte diff cannot carry provenance it was never given.

**Safe behaviour, given that:** never auto-overwrite on drift. Report it and stop; require an explicit human-authorized flag to proceed. Do not attempt to build a heuristic classifier (git blame, commit message sniffing, timestamp heuristics) inside this session — that is unbounded and exactly the kind of speculative machinery DECISION-007's own addenda (S122, S123) repeatedly reject in favor of a disclosed floor over an overclaimed guess.

**The one exception, argued not assumed:** for *this session*, chitra's four specific files are not an unknown case — the founder-supplied measurement already establishes they are stale *renders* (missing a whole protocol block that only ever arrives via `render_subagent_definition`), and DECISION-007 defines every `.claude/agents/*.md` file as a pure rendering that is "never hand-typed" (the S104/S99 no-drift rule, stated in the decision's own text). A file that violates that contract by definition cannot be a legitimate user customization — DECISION-007 doesn't permit one to exist. So the session may treat these four as a **named, pre-declared refresh**, decided by a human reading the measurement, not by the command inferring it. The *command* itself still defaults to WARN-and-refuse for the general case, because it has no way to know that fact about some other user's project.

## Q4 — design-significant, and the citation

**design-significant: yes.** This adds a changed interface (a new `--sync-fleet` flag surface) and makes a real classification decision (stale-vs-edited, and how to resolve it) — squarely S133's "yes" bar (new/changed interface, or a deviation from a locked record), not a pure fix.

**Cite:** `docs/decisions/DECISION-007-agent-fleet.md` — confirmed to exist, read in full through its S131 addendum. It already locks the mechanism this session extends (canonical `fleet::ROLES`, `render_subagent_definition`, skip-if-present via `vajra init`).

**New addendum, not a new DECISION-008.** DECISION-007 already extends itself by addendum nine times (S111 through S131) for exactly this shape of change — adding a role, adding a capability, closing a gap the original text didn't cover — without opening a new decision file each time. This session's two open questions (does a resync-of-an-installed-project surface exist at all; how does it resolve stale-vs-edited) are narrow extensions of the same locked mechanism, not a new fork. Recommend an **"S136 addendum"** appended to `docs/decisions/DECISION-007-agent-fleet.md`, following the file's own established shape (what changed, alternatives rejected, residual risk stated plainly). A new DECISION-008 would only be warranted if this were a *general* file-drift/upgrade mechanism for all scaffold types — explicitly out of scope here (fleet-only).

**Deviation to record explicitly:** the session's own guardrail ("do NOT disturb chitra's 4 existing role files," inherited verbatim from S134) and acceptance criterion 1 (all ten files byte-for-byte, "a drifted copy FAILS, never a silent skip") cannot both hold for those four files. **Acceptance criterion 1 governs** — refreshing the four stale files is not "disturbing" chitra's work product, it is closing a drift condition DECISION-007 itself forbids existing. This must be written into the `## Design` section as a stated deviation, not left for the gate to infer, per the standing rule that the gate checks the *form* of a citation, never whether the design obeys it.

## Recommendations

rec 1 — design-significant: yes; cite `docs/decisions/DECISION-007-agent-fleet.md` (confirmed to exist) and append a new "S136 addendum" section to it — not a new DECISION-008 — mirroring the file's own established addendum pattern (S111/S113/S114/S116/S121/S122/S123/S126/S127/S131).

rec 2 — Verdict is BUILD, not document-only: the mechanism is bounded because it re-enters the existing `for role in crate::fleet::ROLES` / `render_subagent_definition(role)` loop at `src/cli/init.rs:594-599` plus the existing exists-check/write/skip branching in `scaffold()` (init.rs:59-105) — no new scaffolding logic, only a scoped-down re-entry.

rec 3 — Surface it as a flag on an existing command (`vajra init --sync-fleet` preferred, reusing init.rs's own code directly; `vajra next --sync-fleet` acceptable if the builder prefers the stated "next carries new flags" convention) — either way, do not add an 8th top-level command.

rec 4 — For MISSING files (the six roles + `tech-lead`): auto-create unconditionally on every run — the same skip-if-present "create" branch already proven safe, just scoped to `fleet::ROLES` instead of the full ~40-entry `files()` list.

rec 5 — For files whose on-disk bytes already match the canonical render: no-op, report "up to date" — never rewrite a file that needs no change.

rec 6 — For files that differ from canonical (chitra's four researcher/plan-advisor/qa-specialist/fidelity-reviewer land here): the command cannot distinguish STALE-UNMODIFIED from USER-EDITED from bytes alone (no provenance is stored anywhere on disk). Default to WARN-and-refuse; require an explicit second flag (`--overwrite-drifted` / `--force`) to actually rewrite, and support `--dry-run` to preview create/skip/drift-warn with zero writes.

rec 7 — For this session specifically, acceptance criterion 1 (byte-for-byte, all ten, no silent skip on drift) governs over the inherited "do not disturb the 4 existing role files" guardrail — resolve by treating the four-file refresh as a PRE-DECLARED, named scaffold action (list the exact four paths before writing, per the tech-lead's rec 6), so the S134 four-way undisturbed check verifies against a declared list rather than flagging undeclared drift.

rec 8 — Write the deviation into the `## Design` section explicitly, in words a human will read: this design deviates from the S134-inherited "do not disturb" guardrail for the four stale files, because DECISION-007 defines every `.claude/agents/*.md` file as a pure render that must never hand-drift — refreshing them closes a drift condition the record already forbids, it does not introduce one.

rec 9 — Do not build a general stale-vs-edited classifier (git blame, timestamps, commit-message sniffing) inside this session — unbounded, and exactly the class of speculative machinery DECISION-007's own S122/S123 addenda reject in favor of a disclosed floor. Ship "cannot distinguish, default to WARN" as the honest limit, not a guess dressed as detection.

rec 10 — Keep the Vajra-side diff to the 3-file cap: expect roughly `src/cli/init.rs` (or one small new module) + one test file + `docs/decisions/DECISION-007-agent-fleet.md` (the addendum). Do not wire `--sync-fleet` into any broader `--advance` gate flow this session — that is a separate, larger decision, out of scope here the same way S126 kept its five-role addition to table-only changes with no new gate wiring.

## Handoff Delta
- `+` new: first design-advisor handoff for this session (9880 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
