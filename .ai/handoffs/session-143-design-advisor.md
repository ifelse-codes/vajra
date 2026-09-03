---
role: design-advisor
session: 143
agent: claude-code-subagent (verified: toolu_015jt35sEWyvutbaBxLEBoDb)
source-sha: f0d80c3f8cd28d2a6dac26e59dcec07fbd43ead973c33153690d3a0e9a0e410c
captured: 2026-09-03T14:27:24Z
cost_usd: null
---

# Design-advisor handoff — session 143

# Design-advisor brief — Vajra S143 (constitution header/body split)

Confirmed: `StampSyntax::MarkdownComment` (`<!-- vajra-render-sha: <hex> -->`, trailing line) is built + unit-tested (src/fleet/mod.rs:684-728) and all four helpers take it. `classify_fleet_file` (src/cli/init.rs:131-144) compares whole-file `body == canonical`; `SyncTarget`/`FleetSyncItem` carry one `canonical` string; `write_target` (:356-369) writes the whole file. The S142 addendum (DECISION-007:1225-1232) pre-scoped exactly this session, so this addendum CASHES a pre-declared deferral — not a deviation.

## Recommendations

rec 1 — Record `design-significant: yes`, cite `docs/decisions/DECISION-007-agent-fleet.md` + its S141 and S142 addenda, AND author a NEW S143 addendum. `yes` because this changes the on-disk shape of every install's constitution (a new boundary sentinel) and extends the four-state machine from whole-file to body-scoped compare+rewrite. State in `## Design` that this does NOT deviate — S142's addendum text is precisely this work.

rec 2 — Adopt this EXACT boundary sentinel literal (ASCII, no illegal `--` inside the HTML comment, no fill token, unique machine key):
`<!-- vajra:governed-body - do not edit below this line - vajra owns and upgrades these bytes -->`
Inert to markdown, stable across installs (no {PROJECT_NAME}), self-evidently "do not edit below", unambiguous via the invariant key `vajra:governed-body`. Avoid `--` double-hyphen (illegal in strict HTML comments) — single spaced hyphens. Locate in a file by the invariant opening token `<!-- vajra:governed-body` (match to `-->`); canonical write normalizes back to the exact literal.

rec 3 — The sentinel is the FIRST line of the governed body region and the `<!-- vajra-render-sha: <hex> -->` stamp is the LAST line. Compute the stamp over `sentinel + "\n" + governed_content` via `stamp_render(_, StampSyntax::MarkdownComment)` — so the stamp COVERS the sentinel (editing the sentinel breaks the stamp → Drifted; tamper-evident on the boundary too). Reuse `MarkdownComment` verbatim — no fourth StampSyntax, no bespoke constitution stamp path. The sentinel is not a stamp line: `line_hex(MarkdownComment)` returns None for it (no `vajra-render-sha:` key), so strip/extract/verify never confuse the two.

rec 4 — Make classify body-scoped by carrying the sentinel LITERAL (not a bare bool) as `boundary: Option<&'static str>` on `SyncTarget`/`FleetSyncItem`. Roles and hooks pass `None` and hit today's exact whole-file path byte-for-byte (no behavior change, no churn). The constitution passes `Some(GOVERNED_BODY_SENTINEL)`. Add one pure helper `fn body_region<'a>(on_disk: &'a str, boundary: Option<&str>) -> Option<&'a str>`: None → Some(whole file); Some(sentinel) → `on_disk.find(sentinel).map(|i| &on_disk[i..])`. Classify runs the SAME four-state logic on the returned region against a body-scoped `canonical`. Prefer body-extraction-by-literal over a `boundary_aware` bool.

rec 5 — For the constitution target, `canonical` is the canonical BODY only: `stamp_render(SENTINEL + "\n" + governed_body, MarkdownComment)` — sentinel first, governed content (load order · session loop · hard rules via the existing include_str! · comms), stamp last, NO {PROJECT_NAME} fill anywhere in it. Restructure `TPL_AGENTS` (init.rs:948-1011) so the `# {PROJECT_NAME}` header + the fill-bearing preamble (What This Repo Is / Speaking Skills / Fidelity Review) sit ABOVE the sentinel, and everything from `## Mandatory Load Order` down sits BELOW it. `scaffold()` emits the file already stamped so a fresh init + immediate --sync-fleet reports UpToDate (acceptance 4).

rec 6 — On UPGRADE, preserve the header VERBATIM: `write_target` for a boundary target must re-read the on-disk file, split at the sentinel, keep `on_disk[..idx]` byte-for-byte, and write `header ++ canonical_body`. Do NOT reuse the whole-file `fs::write(item.canonical)` path for a boundary target. Defense in depth: if `write_target` is asked to write a boundary target whose on-disk bytes contain NO sentinel, it must bail rather than write the headerless canonical — that write is the session's fakest-green (destroys {PROJECT_NAME}).

rec 7 — Handle the legacy migration with a dedicated state, not by overloading `Drifted`. Add a fifth `FleetFileState` (e.g. `NeedsBoundary`): present, boundary expected, sentinel absent (`body_region` returned None). `--overwrite-drifted` does NOT satisfy it — sync REFUSES to write and prints a dedicated message containing the exact sentinel literal and where to paste it. Without a sentinel there is no sound way to know where the user's header ends, so rewriting is never safe; routing through ordinary `Drifted` would invite `--overwrite-drifted`, which here must refuse. Every pre-S143 install (chitra incl.) hits this on first contact — disclose as the honest, non-retroactive limit.

rec 8 — Spell out the one-time legacy step exactly in the addendum + the refusal message: (1) paste the sentinel line immediately ABOVE the `## Mandatory Load Order` heading in `.ai/AGENTS.md`; (2) run `vajra init --sync-fleet --overwrite-drifted` ONCE. After step 1 the body region = sentinel + old governed text (no stamp) → Drifted; step 2 splits at the now-present sentinel, preserves the filled header verbatim, writes the current governed body + first stamp. Do NOT auto-insert the sentinel by guessing where the header ends (the infer-intent-from-bytes move refused since S136).

rec 9 — Confirm `CONSTRAINTS.yaml` stays OUT — user-tuned, no canonical, not a pure render; absent from sync_targets(). No sentinel, no stamp.

rec 10 — Record rejected alternatives in the addendum. Carry S142's four (rewrite whole file incl. header → destroys identity; un-fill on-disk → lossy inverse; scavenge fill values → correlated-signal classifier S136 rejected; second command/8th surface → one-command directive + max-7). Carry S141's sidecar manifest (a store that drifts). New ones: a fourth/bespoke stamp path (reuse MarkdownComment); a `boundary_aware` bool (duplicates the sentinel literal); auto-inserting the sentinel by heuristic (guessing the boundary); making --overwrite-drifted rewrite a boundaryless file (silently destroys the header — the fakest green).

## Handoff Delta
- `+` new: first design-advisor handoff for this session (6303 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
