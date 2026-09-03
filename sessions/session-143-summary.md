# Session 143 — The constitution joins the smooth upgrade (split fill from governed body)

**Type:** CODE. **Branch:** `session-143-constitution-upgrade`. **Story (1):** split the scaffolded
`.ai/AGENTS.md` into a user-owned FILLED header + a byte-identical GOVERNED body divided by a boundary
sentinel, and widen the SINGLE `vajra init --sync-fleet` so the constitution's governed body gains the
same four-state smooth upgrade — the body auto-upgrades in place while the header is preserved verbatim;
a pre-S143 boundaryless constitution is refused. No 8th command.

## Goal achieved? YES.

The constitution was the last pure-ish render Vajra owned that could not upgrade in place — the named
S142 deferral. S143 makes it upgrade: `vajra init --sync-fleet` now upgrades the governed BODY of
`.ai/AGENTS.md` while preserving the project's own filled header BYTE-FOR-BYTE. **"One command upgrades
everything" is now literally true for every pure render Vajra owns** — roles (S141) + hooks (S142) + the
constitution's governed body (S143) — with `CONSTRAINTS.yaml` the only add-only scaffold file left, by
design (user-tuned, no canonical).

## Evidence (live, not claims)

- **`verify-session-143.sh` 13/13** (11 execute-based · 2 structural · 1 nested), RESULT: PASS.
- **`fixture-session-143.sh` 9/9** — the five `--sync-fleet` states on the CONSTITUTION against the REAL
  binary: POS/UTD/STA + **HDR (the header survives byte-for-byte, `cmp -s`)** + RRS/EDT (the body stamp is
  load-bearing — an unstamped/edited body is refused) + **NB (a boundaryless constitution refused even
  with `--overwrite-drifted`, sentinel printed, header untouched)** + MIG (the one-time migration) + END
  (clean exit-0 positive control).
- **469 lib tests** pass (8 new: five-state body-scoped classify · body_region · no-fill body · sentinel
  HTML-legal · scaffold stamped+UpToDate · header-preserved-on-upgrade · boundaryless-refused-even-forced ·
  missing-constitution-warns-skips); **fmt + clippy clean.**
- **Independent QA (cold `qa-specialist`, has a shell):** ran verify (13/13), fixture (9/9), 469 tests
  LIVE; classified **0 hollow**; ran a REAL falsification — clobbered the header in `write_target`,
  rebuilt, fixture went RED on HDR + MIG for the exact right reason, then reverted, tree byte-clean.
- **Cold `fidelity-reviewer`: ACCEPT**, all 15 `obeyed:` dispositions judged `implemented:`
  (`sessions/session-143-review.md`). Named the fakest green + found 3 under-disclosed gaps → all closed
  in-session (`b9679b5`).
- **Live proof (real release binary):** a fresh `vajra init` scaffolds a stamped, bounded constitution;
  an immediate `--sync-fleet` reports `10 roles + 6 hooks + 1 constitution` all UpToDate (0/0/0, no
  churn); a stamped OLDER body under a custom header auto-upgrades preserving the header; a boundaryless
  legacy constitution is refused with the exact sentinel to paste, then migrates smoothly.

## Fidelity map — every numbered acceptance criterion

| # | Acceptance | Status | Evidence |
|---|---|---|---|
| 1 | scaffold: filled header + boundary sentinel + governed body carrying a round-tripping stamp; inert to markdown | **SHIPPED** | `f_constitution()` / `governed_body_canonical()`; `scaffolded_constitution_is_stamped_and_immediately_up_to_date`, `constitution_body_carries_no_fill_placeholders`, `governed_body_sentinel_is_html_legal_and_fill_free` |
| 2 | body-scoped classify returns the states as a pure function on the body region alone; no-boundary refused | **SHIPPED** | `classify_fleet_file(_,_,_,boundary)` + `body_region`; `classify_constitution_names_the_five_states_on_the_body_region` (the fifth state `NeedsBoundary` supersedes AC2's "no boundary → Drifted" — safer; reconciled by the Design section) |
| 3 | StaleRender body auto-upgrades, header preserved byte-for-byte; Drifted refused; CONSTRAINTS untouched; fixture RED for the right reason + clean-exit control + header-survives | **SHIPPED** | `sync_fleet`/`write_target`; `governed_body_upgrade_preserves_the_user_header_verbatim`; fixture RRS/EDT/HDR/END; `sync_fleet_touches_only_roles_hooks_and_the_constitution` |
| 4 | fresh init + immediate sync → roles+hooks+constitution ALL UpToDate, nothing rewritten — LIVE with the real binary | **SHIPPED** | `live-constitution-round-trip` (asserts `0 created, 0 upgraded, 0 refreshed` + mtime unchanged); `sync_fleet_is_idempotent…` |
| 5 | `## Design` + DECISION-007 S143 addendum record sentinel, body-scope, legacy migration, why header untouched | **SHIPPED** | prompt `## Design decision`; DECISION-007 S143 addendum |
| 6 | verify + demo (≥4 markers) + summary (fidelity map + 3 candidates); cold `fidelity-reviewer` ACCEPT; every obeyed judged by a different role | **SHIPPED** | this file; `demo-session-143.sh` (4 markers, 4 live cases); `sessions/session-143-review.md` (ACCEPT, 15 obeyed-checks) |

**6 of 6 SHIPPED.**

## What I did NOT build (stated plainly)

- **The sentinel is located by an EXACT-match `find`, first occurrence.** A user who mangles the sentinel
  prose gets `NeedsBoundary` (restore the exact line), not a fuzzy re-match; a header that *quotes* the
  exact sentinel line would have everything after it treated as the governed body (pathological — the
  sentinel says "do not edit below" — but disclosed in the addendum). Chosen for a simpler, safer pure
  function.
- **The constitution write is not atomic.** `write_target` bails BEFORE writing on a missing sentinel
  (the fill is never destroyed), but once it commits it does a non-atomic `fs::write` — an interrupted
  `--sync-fleet` could leave a half-written body. qa rec 4, deferred (a temp-file+rename hardening).
- **No double-sentinel falsification fixture.** The first-occurrence contract is disclosed but not pinned
  by a red-going plant. qa rec 2, deferred.
- **Legacy backward-compat stays honest, not retroactive.** Every pre-S143 install has a boundaryless
  constitution → `NeedsBoundary` on first contact → one manual sentinel paste + `--overwrite-drifted`.
  Smooth going forward, not backward (the S141/S142 limit, restated).
- **The stamp is a content hash, not a keyed signature** — tamper-EVIDENT, not tamper-PROOF (S141).

## The fakest green (named by the reviewer)

Not the one the prompt feared — the clobber-the-fill risk is thoroughly nailed (write_target bails on a
missing sentinel; `NeedsBoundary` refuses even forced; three independent checks go red if the header is
touched, and qa proved it live). The hollowest CHECK is `source-has-boundary-wiring` — a structural grep
that passes if the identifiers were merely typed; honestly labeled `struct`, with the real behavior
proven by the exec/nested checks beside it (reviewer rec 5, refused as cosmetic).

## Advice (advisors, answered)

- **tech-lead** bound the crew FIRST: required = design-advisor · qa-specialist · fidelity-reviewer; six
  deferred-budget (money facts under the $20/mo cap). 7 recs answered in `## Advice`; the substantive
  design directives obeyed 08824c3/3afd229, the QA/budget process recs deferred to this summary.
- **design-advisor** (10 recs): settled all four forks (boundary sentinel · body-scoped classify/rewrite ·
  legacy migration as a fifth state · CONSTRAINTS out) + the S143 addendum. All 10 obeyed; judged
  `implemented:` by the fidelity-reviewer (a different role — S131).
- **qa-specialist** (4 recs): rec 1 (absent-constitution coverage) + rec 3 (keep struct labels) were
  addressed in-session (b9679b5 — the missing-constitution test + verify check); rec 2 (double-sentinel) +
  rec 4 (atomic write) deferred. All four recorded `deferred:` to this summary — a rec's own advisor role
  cannot independently judge the builder's obedience of it, and no fourth judge was dispatched (budget).
- **fidelity-reviewer** (5 recs): recs 1–4 (AC4 all-UpToDate · addendum contradiction · first-occurrence
  disclosure · write summary+review) were done in-session (b9679b5) and recorded `deferred:` to the review
  (the reviewer cannot self-judge its own recs' obedience); rec 5 (relabel a struct check) refused as
  cosmetic. The fidelity-reviewer's independent `obeyed-check` judgments cover the design-advisor's + the
  tech-lead's dispositions (all 15 `implemented:`), which is what `--check-obeyed 143` verifies.

## Cost

Interactive session; four subagent dispatches (tech-lead, design-advisor, qa-specialist,
fidelity-reviewer), each on a tight named-files brief (~42K / 74K / 43K / 103K subagent tokens ≈ 262K
total). No `vajra claude` paid run this session. Metered $: interactive, ~$0.

## Exactly 3 ranked next candidates (A/B/C)

- **A — the chitra dogfood: the FULL upgrade loop on a real brownfield repo (RECOMMENDED, founder's #2
  completeness priority).** *Goal:* run `vajra claude` inside chitra and exercise S141+S142+S143 end to
  end — its unstamped roles + hooks + boundaryless constitution all classify Drifted/NeedsBoundary on
  first contact → the one-time migration (paste the sentinel, `--overwrite-drifted`) → prove the next
  `--sync-fleet` is smooth for roles AND hooks AND the constitution. *Why:* the upgrade arc is now
  complete for every pure render Vajra owns; the first real-world test of the whole loop is the natural
  next step, and S140 ranked it #2. *Risk:* a paid run; chitra must be left undisturbed (four-ways proof);
  the constitution migration is the newest, least-exercised path outside this repo.
- **B — the 5 quiet fleet roles: prove a bound dispatch gives GOOD advice (S140 open).** *Goal:* observe
  the under-exercised roles (requirements-analyst, plan-advisor, implementation-advisor, demo-producer,
  release-coordinator) on a real session and measure whether their advice changed the work — every one was
  deferred-budget again this session. *Why:* "installed + dispatchable ≠ proven to give good advice"
  (S140). *Risk:* the fleet already deepens governance-of-governance while adoption is flat — another
  inward turn.
- **C — harden the S143 machinery (atomic write + double-sentinel falsification).** *Goal:* make the
  constitution write atomic (temp file + rename) so an interrupted `--sync-fleet` can never leave a
  half-written body (qa rec 4), and add a double-sentinel red-going plant to pin the first-occurrence
  contract (qa rec 2). *Why:* closes the two disclosed S143 remainders. *Risk:* both are robustness
  polish that would close green — "cleanup is not a session"; only worth it if a real user hits it.

**Next GT: S145.**
