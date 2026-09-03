---
role: design-advisor
session: 142
agent: claude-code-subagent (verified: toolu_01N5HfeczKBkbsLTo2mQiZSU)
source-sha: fa9460c617b737850bd78037a5476454030d22f4bb1e16e3606d28d7e38c5dd2
captured: 2026-09-03T05:09:06Z
cost_usd: null
---

# Design-advisor handoff — session 142

# Design Advisor brief — Vajra S142 (generalise the render stamp to hooks + constitution)

## design-significant marker
**design-significant: yes** — adds new file TYPES (shell, markdown) to the stamp domain, forcing a comment-syntax abstraction in the helper API (stamp_render/strip_render_stamp/extract_render_stamp/render_stamp_verifies gain a syntax parameter) and widening the domain the single sync command governs. A changed interface + a widened contract = the `yes` trigger. Cite DECISION-007 + its S141 addendum (the recorded-provenance design being extended), add an S142 addendum. Real spine records, not invented; NOT a deviation — S141 pre-declared the extension.

## Key facts the forks must respect
- S141 helpers are hard-wired to frontmatter (split on `\n---\n`, bare-key line, search block before closing `---`). A shell `# vajra-render-sha:` and a markdown `<!-- vajra-render-sha: -->` match none of the three — helpers must be PARAMETERISED, not reused as-is.
- classify_fleet_file/plan_fleet_sync are single-code-path over a table; extending to hooks widens the table; render_stamp_verifies/extract/strip all need the file's comment syntax.
- Scaffold `files()` writes hooks as RAW templates (unstamped). For fresh init + immediate sync to report hooks UpToDate (acceptance #4), the builder must stamp hooks at scaffold time on the post-fill bytes.
- chitra: six hooks byte-shape-identical to TPL_HOOK_* templates, no fill → clean fit. Its `.ai/AGENTS.md` is project-specific ("chitra") AND structurally diverged → would classify Drifted; a naive rewrite would clobber chitra's own constitution.
- S141 addendum ALREADY pre-declared: "the same stamp pattern can extend to [the constitution, CONSTRAINTS.yaml, hooks] in a later session." S142 = that later session, an EXTENSION not a deviation from the record.

## Recommendations
rec 1 — Adopt a comment-syntax parameter (`StampSyntax` enum: Frontmatter | ShellComment | MarkdownComment) on the four S141 helpers, not a second copy. Role call site passes Frontmatter (current behavior verbatim). Answers fork #1, honors "reuse don't fork."
rec 2 — Place each stamp as the TRAILING line for comment styles; keep frontmatter stamp where S141 put it. Shell: appended `# vajra-render-sha:` at EOF (never line 1 — shebang stays first). Markdown: appended `<!-- … -->` at EOF (HTML comments don't render). Last-but-inert in all three.
rec 3 — Pin the frontmatter variant byte-identical to S141 with a golden test, so no already-stamped role file churns. If any byte moves, every stamped role re-classifies StaleRender and re-upgrades — churn the no-churn property forbids.
rec 4 — Make `strip(stamp(x)) == x` exact across the trailing-newline edge, unit-tested per file type. The append path must add exactly one newline + stamp line and strip remove exactly that; a file already ending in `\n` must not gain a stray blank line. Most likely correctness bug.
rec 5 — Stamp the hooks at scaffold time in `files()`, on post-fill bytes (fill first, then stamp_render(…, ShellComment)), so a fresh install is UpToDate with zero churn (acceptance #4). Confirm the executable bit is untouched and the stamped hook still runs.
rec 6 — Model the sync target as a small table of {rel, syntax, render-fn} descriptors covering roles + hooks; keep classify_fleet_file/plan_fleet_sync/sync_fleet iterating that ONE table. Thread the file's StampSyntax into the render_stamp_verifies call. Hooks inherit the four-state machine + `--overwrite-drifted` refusal for free.
rec 7 — RULE ON FORK #2: scope `.ai/AGENTS.md` auto-rewrite OUT this session (option c); ship hooks + the generalized stamp; record the constitution as a named disclosed remainder. This DEVIATES from the brief's stated scope (which lists the constitution as a target) — record the deviation consciously. Reason: the filled constitution has no sound one-session upgrade — un-fill needs the old template Vajra doesn't carry; scavenging re-opens the S136/S141 inference classifier; a naive rewrite clobbers chitra's identity + violates S118. Founder's "one command upgrades everything" honored structurally (one widened command, no sibling) + honestly (roles + hooks now, constitution next), not faked by guessing project values. The author may refuse in writing (e.g. the founder insists the fill-split ships now).
rec 8 — Record the constitution's real fix as the named follow-up: split TPL_AGENTS into a user-owned filled header + a byte-identical governed body; stamp/auto-upgrade only the body. The constitution's fill becomes user-owned like CONSTRAINTS.yaml; its load order / hard rules / session loop (what Vajra improves) become a pure render that upgrades smoothly. A template restructuring + migration affecting every install = a separate story. Name it now so "the constitution upgrades too" is a scheduled promise, not a silent drop.
rec 9 — Keep `--sync-fleet` as the invocation this session; do NOT rename to `--sync` (churns help/tests/chitra references for cosmetic accuracy). Optional low-priority: add `--sync` as an alias to the same handler (a flag spelling, not an 8th command) + update the report line to "roles + hooks".
rec 10 — State the retroactive limit in the sync output for hooks, exactly as S141 does for roles: every pre-S142 install has unstamped hooks → Drifted on first contact → one `--overwrite-drifted` to receive the first stamp. Smooth going forward, never retroactive.

## Proposed S142 DECISION-007 addendum (author records)
Title: the render stamp generalises to shell + markdown; hooks join the smooth upgrade, the constitution is deferred. Status ACCEPTED (session 142). An addendum (not DECISION-008) cashing the S141 pre-declaration. Stamp is now comment-syntax-aware (Frontmatter unchanged byte-for-byte / ShellComment / MarkdownComment), one parameterised code path. In scope: hooks (no fill, byte-identical, clean fit). Deferred: constitution (per-install fill sync_fleet can't reproduce). CONSTRAINTS.yaml stays user-owned permanently. Rejected alternatives: un-fill on-disk (lossy, needs old template); scavenge fill values (re-opens inference classifier); naive rewrite (clobbers identity, violates S118); second `--sync-scaffold`/per-type commands (founder: one command; max-7 line); stamp CONSTRAINTS.yaml (user-tuned); sidecar manifest (S141-rejected). Honest limit: unstamped hooks Drifted on first contact, one `--overwrite-drifted`, smooth going forward not retroactive.

## Handoff Delta
- `+` new: first design-advisor handoff for this session (6495 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
