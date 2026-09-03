# Session 142 — Complete the upgrade loop for the pure-render scaffold files (hooks)

**Type:** CODE. **Branch:** `session-142-scaffold-upgrade`. **Story (1):** generalise the S141
`vajra-render-sha:` render stamp beyond YAML frontmatter to a comment-syntax abstraction, and widen
the SINGLE existing `vajra init --sync-fleet` so the shell **hooks** (`.ai/hooks/hook-*.sh`) gain the
same four-state smooth upgrade — an untouched old render auto-upgrades, a user edit / unstamped file
is refused. No 8th command.

## Goal achieved? YES — for the founder-confirmed scope (hooks now, constitution S143).

The founder picked B at the S141 close ("just a single update command… smooth and seamless"). At the
design fork the design-advisor found the constitution `.ai/AGENTS.md` is a per-install FILLED template
that `sync_fleet(root)` cannot reproduce, so it has no sound one-story upgrade. **The founder confirmed
in chat: "hooks now, constitution S143."** This session ships the generalised stamp + the hooks under
one command; the constitution is the named S143 follow-up (split its governed body from its user fill).

## Evidence (live, not claims)

- **`verify-session-142.sh` 12/12** (10 execute-based · 2 structural · 1 nested), RESULT: PASS.
- **`fixture-session-142.sh` 9/9** — the four `--sync-fleet` states on a HOOK against the REAL binary;
  RRS/EDT plants prove the shell stamp is load-bearing; POS/END positive controls assert clean exit 0.
- **461 lib tests** pass (4 new: per-file-type round-trip + hooks-no-fill + scaffold-stamped-UpToDate +
  hook four-state classify); **fmt + clippy clean.**
- **Independent QA (cold `qa-specialist`):** ran verify (11→12/12), fixture (9/9), 460→461 tests LIVE;
  classified **0 hollow**; ran a REAL falsification — forced `render_stamp_verifies` ShellComment→false,
  fixture went RED on STA for the exact right reason (stale hook reclassified Drifted → refused),
  reverted, tree clean, nothing committed. Handoff: `.ai/handoffs/session-142-qa-specialist.md`.
- **Cold `fidelity-reviewer`: ACCEPT**, all 9 `obeyed:` dispositions judged `implemented:`
  (`sessions/session-142-review.md`).
- **Live proof:** a fresh `--sync-fleet` creates 10 roles + 6 stamped hooks, idempotent (no mtime
  churn); a planted stamped OLDER hook upgrades EXACTLY it, reported by name + old→new stamp; a
  hand-edited / unstamped hook is refused unless `--overwrite-drifted`.

## Fidelity map — every numbered acceptance criterion

| # | Acceptance | Status | Evidence |
|---|---|---|---|
| 1 | hook carries a round-tripping shell-comment stamp, inert (parses, shebang line 1); per-file-type round-trip, frontmatter byte-identical to S141 | **SHIPPED** | `render_stamped_hook`/`stamp_render` ShellComment branch; `stamp_round_trips_per_file_type_and_frontmatter_is_byte_identical_to_s141`; live `live-stamp-inert-hook-still-runs` |
| 2 | `classify_fleet_file` returns FOUR states as a syntax-aware pure function | **SHIPPED** | `classify_fleet_file(_, _, StampSyntax)`; `classify_fleet_file_names_the_four_states` (frontmatter) + `classify_names_the_four_states_for_a_shell_hook` (hook, incl. cross-syntax safety) |
| 3 | StaleRender hook auto-upgrades (no flag, by name); Drifted refused exit 1 unless `--overwrite-drifted`; CONSTRAINTS.yaml/AGENTS.md never touched; fixture RED for the right reason + clean-exit-0 control | **SHIPPED** | `fixture-session-142.sh` 9/9 (STA/RRS/EDT/DRF/OVR/END); `sync_fleet_touches_only_roles_and_hooks_and_nothing_else` |
| 4 | fresh `init` → sync all role+hook UpToDate, nothing rewritten — LIVE with the real binary | **SHIPPED** | `live-hook-round-trip` (mtime-unchanged idempotence + exact-one stale upgrade); `scaffolded_hooks_are_stamped_and_immediately_up_to_date`; demo CASE 1 |
| 5 | `## Design` + DECISION-007 S142 addendum record the generalised stamp, in-scope set, why CONSTRAINTS.yaml excluded | **SHIPPED** | DECISION-007 S142 addendum (58b1033); prompt `## Design decision` |
| 6 | verify + demo (4 markers) + summary (fidelity map + 3 candidates); cold `fidelity-reviewer` ACCEPT | **SHIPPED** | this file; `demo-session-142.sh` (4 markers, 4 cases green); `sessions/session-142-review.md` (ACCEPT) |

**6 of 6 SHIPPED.**

## What I did NOT build (stated plainly)

- **The constitution `.ai/AGENTS.md` does NOT upgrade in place** — the headline scope cut, founder-
  confirmed. It is a per-install filled template (`{PROJECT_NAME}`×5, `{GOAL}`, `{MATURITY}`,
  `{FIRST_*}`); `sync_fleet(root)` has no sound way to reproduce the current template with this
  project's values in one story. StaleRender *detection* would work; the *rewrite* does not. Deferred
  to **S143**: split `TPL_AGENTS` into a user-owned filled header + a byte-identical governed body,
  stamp/upgrade only the body. The `MarkdownComment` stamp syntax is already built + unit-tested, so
  S143 is a small step, not a rebuild.
- **The `MarkdownComment` variant has no falsifiability fixture** — it is unit-tested for round-trip
  but no `--sync-fleet` fixture drives it (nothing is wired to a markdown scaffold file yet). qa rec 2.
- **No live check asserts `--sync-fleet` leaves CONSTRAINTS.yaml / a pre-existing AGENTS.md byte-
  unchanged** — the "user-owned / deferred" claim is recorded in the addendum + covered by the
  touches-only-roles-and-hooks unit test, but not driven end-to-end through the binary. qa rec 1.
- **The retroactive limit stays honest, not retroactive:** every pre-S142 install has UNSTAMPED hooks
  → `Drifted` on first contact → one `--overwrite-drifted` writes their first stamps. Smooth going
  forward, not backward (the S141 limit, restated for hooks).
- **The stamp is a content hash, not a keyed signature** — tamper-EVIDENT, not tamper-PROOF (S141).

## The fakest green (named by the reviewer, closed in-session)

`classify_fleet_file_names_the_four_states` was the fakest green: named after criterion 2 and wired in
as the four-state proof, yet every assertion passed `StampSyntax::Frontmatter` — the hook classify
path had no pure-unit guard and rode on the fixture/live layer. Real coverage one layer down, but a
hollow-looking unit marker. **Closed in-session (fidelity rec 1):**
`classify_names_the_four_states_for_a_shell_hook` drives a `ShellComment` hook through all four states
plus a cross-syntax-safety assertion; wired into verify (now 12 checks).

## Advice (advisors, answered)

- **tech-lead** bound the crew FIRST: required = design-advisor · qa-specialist · fidelity-reviewer;
  six deferred-budget (money facts under the $20/mo cap). Its 5 recs answered in `## Advice`: rec 5
  (reuse helpers, don't fork) obeyed 90105ca; the rest deferred to this summary / the design-advisor
  handoff.
- **design-advisor** (10 recs): settled both forks. recs 1–6 (StampSyntax one code path · trailing
  comment placement · golden frontmatter test · exact round-trip edge · scaffold-time stamp · single
  target table) obeyed 90105ca; rec 7 (constitution OUT, disclosed remainder) + rec 10 (retroactive
  limit) obeyed 58b1033; rec 8 (S143 fill-split follow-up) deferred to this summary; rec 9 refused
  (kept `--sync-fleet`, no rename/alias — cosmetic). recs 1–7,10 judged `implemented:` by the
  fidelity-reviewer (a different role — S131 pattern).
- **qa-specialist** (3 recs): all future work, deferred — rec 1 (live CONSTRAINTS.yaml/AGENTS.md
  untouched check), rec 2 (MarkdownComment fixture), rec 3 (a refuse-on-edit AGENTS.md fixture before
  S143 wires the filled template).
- **fidelity-reviewer** (4 recs): rec 1 (hook four-state unit test) DONE in-session; rec 2 (framing) +
  rec 3 (land the summary) honored here + in ROADMAP; rec 4 (a dedicated hook-drift stdout line)
  refused as cosmetic (the drifted branch already prints the `--overwrite-drifted` guidance).

## Cost

Interactive session; four subagent dispatches (tech-lead, design-advisor, qa-specialist,
fidelity-reviewer), each on a tight named-files brief (~38K / 73K / 38K / 92K subagent tokens). No
`vajra claude` paid run this session. Metered $: interactive, ~$0.

## Exactly 3 ranked next candidates (A/B/C)

- **A — S143: the constitution joins the smooth upgrade (RECOMMENDED, the promised follow-up).**
  *Goal:* split `TPL_AGENTS` into a user-owned filled header + a byte-identical governed body; stamp +
  auto-upgrade only the body (the `MarkdownComment` syntax is already built). *Why:* completes the
  founder's "one command upgrades everything" — the last pure-ish render Vajra owns; the honest debt
  this session named. *Risk:* a template restructuring + a one-time migration on every install; the
  filled/governed split must be clean or a legitimate user edit reads as drift.
- **B — the chitra dogfood full-loop upgrade (the founder's #2 completeness priority).**
  *Goal:* run `vajra claude` inside chitra; exercise S141+S142 on a real brownfield repo — its
  unstamped roles + hooks classify Drifted on first contact → one `--overwrite-drifted` writes the
  first stamps → prove the next `--sync-fleet` is smooth for roles AND hooks. *Why:* the first
  real-world test of the whole upgrade loop; the S140 #2 priority. *Risk:* a paid run; chitra must be
  left undisturbed (four-ways proof).
- **C — the 5 quiet fleet roles: prove a bound dispatch gives GOOD advice (S140 open).**
  *Goal:* observe the under-exercised roles (requirements-analyst, plan-advisor, implementation-
  advisor, demo-producer, release-coordinator) on a real session and measure whether their advice
  changed the work. *Why:* "installed + dispatchable ≠ proven to give good advice" (S140). *Risk:*
  the fleet already deepens governance-of-governance while adoption is flat — another inward turn.

**Next GT: S145.**
