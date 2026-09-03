# Session 143 — Independent Fidelity Review (cold pass)

**Verdict:** ACCEPT

Independent adversarial cold review by the `fidelity-reviewer` role (a different role from the graded
design-advisor / tech-lead — the S131/S132 pattern), fed the prompt + the diff. Judged 5 of 6 SHIPPED at
review time (AC6 PARTIAL only because this file + the summary were downstream of the review); both now
exist, so **6 of 6 at close**. Three under-disclosed gaps the review found were closed in-session
(`b9679b5`). All fifteen `obeyed:` dispositions judged `implemented:`.

## Per-requirement verdict

| # | Requirement | Verdict | Evidence in the diff |
|---|---|---|---|
| 1 | scaffold: filled header + boundary sentinel + governed body carrying a round-tripping stamp; inert to markdown | ACCEPT | `f_constitution()` = `fill(TPL_AGENTS_HEADER) ++ governed_body_canonical()`; stamp preimage covers the sentinel; `scaffolded_constitution_is_stamped_and_immediately_up_to_date`, `constitution_body_carries_no_fill_placeholders`, `governed_body_sentinel_is_html_legal_and_fill_free` |
| 2 | body-scoped classify returns the states as a pure function of (on-disk, canonical body); no-boundary/unverifiable refused | ACCEPT | `classify_fleet_file(_,_,_,boundary)` pure, routes through `body_region`; `classify_constitution_names_the_five_states_on_the_body_region` incl. the boundary-None-vs-Some cross-check. The literal "no boundary → Drifted" was superseded by the safer fifth state `NeedsBoundary` (reconciled by the Design section + addendum) |
| 3 | StaleRender body auto-upgrades, header preserved byte-for-byte; Drifted refused; CONSTRAINTS untouched; fixture RED for the right reason + clean-exit control + header-survives | ACCEPT | `sync_fleet` StaleRender arm; `write_target` keeps `on_disk[..idx] ++ canonical`; `governed_body_upgrade_preserves_the_user_header_verbatim`; fixture RRS/EDT/HDR(`cmp -s`)/END; `sync_fleet_touches_only_roles_hooks_and_the_constitution` |
| 4 | fresh init + immediate sync → roles+hooks+constitution ALL UpToDate, nothing rewritten, LIVE real binary | ACCEPT | `live-constitution-round-trip` (real binary, real dir), widened in-session to assert `0 created, 0 upgraded, 0 refreshed` end-to-end (not just constitution mtime); `sync_fleet_is_idempotent…` |
| 5 | `## Design` + DECISION-007 S143 addendum record sentinel, body-scope, migration (honest), header untouched | ACCEPT | prompt `## Design decision`; DECISION-007 S143 addendum (sentinel literal, `boundary: Option`, `body_region`, `NeedsBoundary`, one-time paste, header verbatim, CONSTRAINTS out, 7 rejected alternatives, honest limits) |
| 6 | verify (exit 0, class tally) + demo (≥4 markers) + summary (fidelity map + 3 candidates) + cold ACCEPT + obeyed judged by a different role | ACCEPT (was PARTIAL at review) | `verify-session-143.sh` 13/13 · `demo-session-143.sh` 4 markers, 4 live cases · this review + `sessions/session-143-summary.md` now written |

**6 of 6 SHIPPED at close.**

## The fakest green (named)

The clobber-the-fill risk — the one the prompt feared — is thoroughly nailed: `write_target` bails on a
missing sentinel, `NeedsBoundary` refuses even under `--overwrite-drifted`, and three independent checks
(the header-verbatim unit test, fixture `HDR` with `cmp -s`, and the live `python` byte-compare) each go
red if the header is touched (qa proved it live). The hollowest CHECK is `source-has-boundary-wiring` — a
structural grep that passes if the identifiers were merely typed and would stay green if `body_region`
always returned the whole file. It is honestly labeled `struct`, and the real behavior is proven by the
exec/nested checks beside it, so the suite as a whole is not hollow — but that grep is the one that cannot
fail on the feature being broken. Kept, honestly labeled (reviewer rec 5, refused as cosmetic).

## Gaps found and CLOSED in-session (b9679b5)

- AC4's LIVE no-churn was asserted for the constitution mtime only → widened to assert every line
  UpToDate (`0 created, 0 upgraded, 0 refreshed`).
- The addendum said editing the boundary → `Drifted`; with exact-match `find`, a sentinel-LINE edit →
  `NeedsBoundary`, a body edit below an intact sentinel → `Drifted` → corrected, contradiction removed.
- The first-occurrence hazard (a header quoting the exact sentinel) → disclosed in the addendum limits.
- The absent-constitution branch had zero coverage → `a_missing_constitution_warns_and_is_skipped_not_created`
  unit test + a verify check added.

## `obeyed:` dispositions — independently judged (a different role from the graded advisors)

obeyed-check design-advisor rec 1 — implemented: 3afd229 — the S143 addendum records the settled design (sentinel, body-scope, migration, header preservation).
obeyed-check design-advisor rec 2 — implemented: 08824c3 — `GOVERNED_BODY_SENTINEL` is an HTML comment, single-hyphen, fill-free; asserted by `governed_body_sentinel_is_html_legal_and_fill_free`.
obeyed-check design-advisor rec 3 — implemented: 08824c3 — `body_region` slices from the sentinel; classify runs the state machine on the body region alone against a body-only canonical.
obeyed-check design-advisor rec 4 — implemented: 08824c3 — `boundary: Option<&'static str>` on SyncTarget/FleetSyncItem; roles/hooks pass None (unchanged whole-file path), the constitution passes Some.
obeyed-check design-advisor rec 5 — implemented: 08824c3 — `governed_body_canonical()` is the ONE source both `files()` and `sync_targets()` derive the constitution body from; scaffolded already stamped.
obeyed-check design-advisor rec 6 — implemented: 08824c3 — `write_target` boundary branch keeps `on_disk[..idx]` verbatim and appends the canonical body; bails if the sentinel is absent.
obeyed-check design-advisor rec 7 — implemented: 08824c3 — `FleetFileState::NeedsBoundary` is a distinct fifth state; `sync_fleet` refuses it even under `--overwrite-drifted` and prints the sentinel.
obeyed-check design-advisor rec 8 — implemented: 3afd229 — the addendum + the `needs_boundary` refusal message spell out the one-time paste-then-`--overwrite-drifted` migration exactly.
obeyed-check design-advisor rec 9 — implemented: 08824c3 — `CONSTRAINTS.yaml` stays absent from `sync_targets()`; `sync_fleet_touches_only_roles_hooks_and_the_constitution` asserts it is untouched.
obeyed-check design-advisor rec 10 — implemented: 3afd229 — the addendum names 7 rejected alternatives incl. whole-file rewrite, un-fill/scavenge, auto-insert-heuristic, force-a-boundaryless-file.
obeyed-check tech-lead rec 1 — implemented: 3afd229 — the design-advisor was dispatched FIRST and the design settled before code; the addendum records it.
obeyed-check tech-lead rec 2 — implemented: 08824c3 — the legacy migration is the `NeedsBoundary` state, refused even under `--overwrite-drifted`; a manual paste is required and disclosed.
obeyed-check tech-lead rec 3 — implemented: 08824c3 — reuses `StampSyntax::MarkdownComment` (one of three branches in fleet/mod.rs); no fourth stamp path.
obeyed-check tech-lead rec 4 — implemented: 08824c3 — classify/write are body-scoped via `body_region`; `write_target` preserves the header verbatim and bails on a missing sentinel.
obeyed-check tech-lead rec 6 — implemented: 08824c3 — `UpToDate` never rewritten; the constitution rides the existing `--sync-fleet` flag (7 commands held); `CONSTRAINTS.yaml` confirmed out.

## Reviewer recommendations

rec 1 — Widen the AC4 LIVE assertion to all-UpToDate (0/0/0), not just constitution mtime. (DONE b9679b5.)
rec 2 — Fix the addendum contradiction: sentinel-line edit → NeedsBoundary; body edit below an intact sentinel → Drifted. (DONE b9679b5.)
rec 3 — Disclose the first-occurrence hazard (a header quoting the exact sentinel is partially rewritten). (DONE b9679b5.)
rec 4 — Write session-143 summary + review before closeout (AC6). (DONE.)
rec 5 — Relabel `source-has-boundary-wiring` so its green is never read as behavioral fidelity. (REFUSED — cosmetic; stays `struct`, behavior proven by the exec/nested checks.)
