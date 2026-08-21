# Session 126 — CODE: finish the SDLC agent fleet (the last five roles)

**Verdict: ACCEPT** (independent cold `fidelity-reviewer` pass, **7 of 9 SHIPPED**, 2 PARTIAL,
0 NOT-BUILT — the two PARTIALs were this record and the review record, which by construction could
not exist in the diff the reviewer read). Full brief: `sessions/session-126-review.md`.

## The headline, and the residual in the same breath

**The fleet roster is COMPLETE: four named roles became nine, in one pass.** Every one of the
eight pipeline stations now has a named agent role behind it, plus the station-less `researcher`.

**And nothing depends on any of them.** No gate consumes a handoff. The shipped scaffold never
asks for a role. S125 established that the four existing roles are never reached for on real work,
and five more roles inherit that unchanged. **Nine roles that nothing depends on is nine
decorations.** This session closes the *done* half of the founder's gate ("the fleet is done AND
working"); the *working* half is not built here, is not claimed here, and is S127's subject.

## What shipped

| # | Acceptance criterion | Verdict |
|---|---|---|
| 1 | Five roles registered, distinct keys, each collision resolved in writing | SHIPPED |
| 2 | Each prompt cites the exact marker its station's gate parses; proposes, never authors | SHIPPED |
| 3 | Tool grants per role, read-only by default; the one fork argued in the addendum | SHIPPED |
| 4 | Traced, not asserted: nine scaffolded · handoff per role · `K of 8` unchanged | SHIPPED |
| 5 | All five dispatched BY NAME from a fresh session, S111 two-file cross-check each | SHIPPED |
| 6 | `DECISION-007` S126 addendum recorded, residual included | SHIPPED |
| 7 | `verify-session-126.sh` + `demo-session-126.sh` both exit 0 with a class tally | SHIPPED |
| 8 | Independent cold `fidelity-reviewer` verdict ACCEPT, attested | SHIPPED (this record) |
| 9 | The residual stated plainly, never softened | SHIPPED (this record) |

**The five roles, and the station each serves** — every key resolves the STATION-vs-ROLE collision
the S114/S116/S121 way (never the station's own word), and every one is read-only:

| station (`K of 8`) | role key | the marker its prompt cites | rejected key |
|---|---|---|---|
| Analyst | `requirements-analyst` | the four required prompt sections · `Status:` · `## Delta` OpenSpec bullets · exactly-3 options | `analyst` |
| Architect | `design-advisor` | `design-significant: yes\|no` + a `## Design` citing a record that EXISTS | `architect` |
| Coder | `implementation-advisor` | `step N — done: <sha>`, every sha resolved against git | `coder`, `implementer` |
| Demo-er | `demo-producer` | `demo:header` · `demo:cases` · `demo:summary_table` · `demo:before_after` in the LIVE re-run | `demoer`, `demo` |
| Releaser | `release-coordinator` | `require_merged_prior` · `require_main_synced` · `require_pruned`, re-derived from git | `releaser`, `release-engineer` |

**Five roles added, ZERO new grants of `Bash`.** The one real fork — does the Coder role get
`Write`/`Edit`? — was resolved **read-only** and argued in the addendum: granting it would reverse
S123 (which narrowed the only executing role's grant) and the S122 retraction of the executor
thesis in the same session that ships it. "Grant the implementation role write access" is recorded
as a separate, founder-gated decision.

**Evidence, not assertion:** each of the five was dispatched by name from a **separate headless
`claude -p` session** — the S111 session boundary, crossed five times without waiting five
sessions — and each dispatch is cross-checked against two files Claude Code itself wrote, agreeing
on a random tool-call id (`sessions/session-126-dispatch-evidence.md`). The five
briefs were landed as governed handoffs through the unchanged S109 path.

## Numbers

- 341 lib tests green · `verify-session-126.sh` **15 checks, ALL GREEN** (11 exec · 2 struct ·
  1 behav · 1 nested) · `demo-session-126.sh` **7 executed cases, GREEN**.
- The nested check re-runs `verify-session-122.sh` LIVE, which itself re-runs the S121 suite — the
  chain this session's one out-of-fleet edit could have broken, proven green rather than assumed.
- `vajra next --stations 126` → **5 of 8 stations passed**, with the five handoffs reported beside
  K and explicitly not counted in it.
- **Metered cost of the five live dispatches: $4.4482** (each figure is the run's own
  `total_cost_usd`, the authoritative source — not a token estimate). The orchestrating session's
  own cost is not metered here.

## The fakest green (the reviewer's call, landed unedited)

**The dispatch cross-check runs over copies.** `five-dispatches-cross-check` and
`cross-check-has-teeth` verify that the committed JSON files are internally consistent; nothing
binds them to the runtime originals in `~/.claude/projects/`, so a *consistent* fabrication would
pass exactly as a real dispatch does. The fixture proves the checker catches an inconsistent copy,
not a fabricated one. What makes fabrication implausible is off-check: five result streams with
per-model usage, five distinct session ids, $4.45 of metered spend, ~600KB of transcripts.

## Post-review, founder-directed: session artifacts are no longer pushed

At the founder's call after the ACCEPT, `sessions/session-126-artifacts/` (1.1 MB, of which 810 KB
was raw JSONL) was **removed from git** and `sessions/session-*-artifacts/` is now ignored. The
files stay on disk; nothing was deleted locally. What git carries instead is an 8 KB derived
record, `sessions/session-126-dispatch-evidence.md`, holding every field the cross-check reads —
ids in both directions, distinct parent session ids, transcript sha256s, real costs — and stating
what the removal costs: **a clean clone can check the record, never the runtime's own files.**
That loss is small precisely because the cold review had already shown the check proved
consistency, not provenance. Binding evidence to the runtime is S127's candidate B.

The verify and demo suites were rewired to the record and re-run green (15/15 · 7/7), with six
planted-drift cases required to turn the record check RED, plus a strong path that re-derives from
the raw files when they are present locally. **This change touched reviewed code, so a second cold
pass was run over it** — see `sessions/session-126-review.md` §pass 2 — and the attestation was
recomputed afterwards.

## Two things this session did to itself, disclosed

1. **The Planner gate blocked this session's own prompt** — `plan misses criteria 9`. Plan step 9
   was added in-session to cover criterion 9 (no new scope; criterion 9 predates it), and the edit
   is disclosed inside the prompt.
2. **One file outside the fleet was touched:** `scripts/verify-session-121.sh` pinned `N = 4`
   scaffolded agent files. That pin measured the roster SIZE of its day, not the check's substance
   (byte-identity + set equality, both count-independent), and `verify-session-122.sh` re-runs the
   S121 suite live, so the breakage chained. Now a floor (`-ge 4`). The reviewer's note stands:
   the check's NAME still says "four".

## Three ranked next-session candidates

1. **A — the WORKING half: make a gate consume a handoff.** S116's own unpicked candidate C plus
   S125's F2. Pick one station and make its `--check-*` path read the matching role's handoff as
   evidence, so skipping the role has a consequence. This is the founder's gate for unparking the
   S125 reboot backlog, and it is the only candidate that changes "nine decorations" into a fleet.
2. **B — bind the dispatch evidence to the runtime.** Close the fakest green this session shipped:
   have the cross-check re-harvest from `~/.claude/projects/` at verification time (or record a
   hash of the original alongside the copy), so a consistent fabrication fails. Smaller, and it
   hardens the evidence every future fleet session will lean on.
3. **C — the S127 findings sweep.** The reviewer's six filed findings (degenerate `K of 8`
   baseline, the demo omitting the out-of-fleet edit, the S121 check name that now lies, the
   S114/S116 stale pins, the attestation ordering hazard). Real, small, and none of them changes
   whether the fleet works.

**Recommended: A.** B and C harden a fleet nothing depends on yet. A is the one that closes the
founder's gate.
