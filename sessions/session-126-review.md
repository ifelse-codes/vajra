# Session 126 — independent cold fidelity review

**Reviewer:** the `fidelity-reviewer` fleet role, dispatched by name as a native Claude Code
subagent from this session (agent id `a84434f6d18414285`). It did not build this work and was fed
exactly two things: the session prompt `prompts/126-task-finish-the-fleet.md` and the branch diff
`sessions/session-126-artifacts/review-input.diff` (2,363 lines, HEAD vs the merge-base with
`main`). Excluded from that diff for SIZE ONLY, and named to the reviewer so nothing was hidden:
the five raw subagent transcripts and the five headless `-run.json` result streams (~600KB of
Claude-Code-written JSONL), all committed and readable on disk.

**The brief below is the reviewer's own, landed as returned.** The builder did not edit its
grades, its fakest-green call, or its findings.

> **Reading note (added when pass 2 landed).** Pass 1 below describes the suite **as it stood at
> commit `8783a01`**. After that verdict the founder directed that session artifacts must not be
> pushed to git, which replaced two checks and moved the class tally. Pass 1's words are left
> exactly as returned — they are the record of what was judged — and **§Pass 2 at the end of this
> file is the current description.** Check names `five-dispatches-cross-check` and
> `cross-check-has-teeth`, the tally `11 · 2 · 1 · 1`, and the path
> `sessions/session-126-artifacts/review-input.diff` all refer to that earlier state.

---

**Method controls (reviewer's own words).** Cold pass, fresh context, no builder narrative
available or consumed (`sessions/session-126-summary.md` did not exist; neither did
`session-126-review.md`). Adversarial corroboration was performed against the repo, **not** against
any builder prose: every marker the five new role prompts cite was independently confirmed to
exist in station source (`src/demoer/mod.rs:433`, `src/releaser/mod.rs:51-53`,
`src/analyst/mod.rs:206-213,829-850`, plus `src/architect` / `src/coder`), `scripts/verify-closeout.sh:139-185`
was read, suite nesting was grepped, and the untracked run logs `verify-run-1.txt` and
`demo-run-1.txt` were read.

## Per-requirement verdicts

| # | Requirement | Verdict | Evidence in the diff |
|---|---|---|---|
| 1 | Five roles in `fleet::ROLES`, distinct keys, each collision resolved in writing with the rejected alternative | SHIPPED | `src/fleet/mod.rs` adds 5 `Role{}` entries; the `DECISION-007` S126 addendum carries a 5-row table naming each rejected alternative (`analyst`, `architect`/`solution-architect`, `coder`/`implementer`, `demoer`/`demo`, `releaser`/`release-engineer`); `the_last_five_roles_are_registered_with_non_colliding_keys` asserts both directions, and `verify-session-126.sh::no_station_collision` runs the real binary on 8 station words plus a positive control |
| 2 | Each system prompt cites the exact marker its station's gate parses, and states propose-not-author | SHIPPED | Five new `const *_SYSTEM_PROMPT` blocks; each cited marker was verified to exist in station code, so this is not a self-referential claim; every prompt ends "Your output is a PROPOSAL, never the … of record"; the render is byte-diffed against the committed `.claude/agents/*.md` |
| 3 | Tool grants per role, read-only default; any non-read-only grant carries a written rationale | SHIPPED | All five `tools: "Read, Grep, Glob"`; inline rationale at the `implementation-advisor` fork plus the addendum section; the test asserts `ROLES.len()==9` and exactly one role holding `Bash`; `execution_allowlist_did_not_grow` token-parses the RENDERED files against `FORBIDDEN="Bash Write Edit NotebookEdit Task"` |
| 4 | **Traced, not asserted:** nine scaffolded, `next --role` governs a handoff for each, `--stations` reports an unchanged `K of 8` | SHIPPED | The trace is the diff itself: the only `src/` file touched is `src/fleet/mod.rs` — no CLI, gate, counter or command code. Backed by `init-scaffolds-nine-roles`, `new-roles-govern-handoffs` (real `source-sha`, session, delta, plus a fail-closed unknown-role probe), `k_of_8_unchanged`, and the nested LIVE re-run of `verify-session-122.sh` (which re-runs S121) |
| 5 | All five proven dispatched by name from a fresh session, each with the S111 two-file cross-check | SHIPPED | Five `*-parent-tooluse.json` / `*-subagent-meta.json` pairs agreeing on random `toolu_…` ids, five distinct `parent_sessionId`s, `harvest.py` failing closed on mismatch, and `cross-check-has-teeth` planting TWO forgeries (mutated `toolUseId`; mutated `subagent_type`) requiring RED on each and GREEN on the control. Corroborated independently: `requirements-analyst-run.json`'s `session_id` matches the harvested parent id and its `result` is byte-for-byte the shipped handoff |
| 6 | `DECISION-007` S126 addendum recorded, including the residual risk | SHIPPED | +115 lines to `docs/decisions/DECISION-007-agent-fleet.md`: the one-pass rationale, the key table, the per-role marker contracts, the grant decision, the out-of-fleet edit, and "Residual risk — stated, not softened" plus a second residual (dispatch proves the wire, not the demand) |
| 7 | `verify-session-126.sh` and `demo-session-126.sh` both exit 0, with a printed check-class tally | SHIPPED | Both scripts land and use the shared `lib-tally.sh`; run logs show `ALL GREEN (15 pass, 0 fail)` with `execute-based: 11 · structural: 2 · behavioral: 1 · nested: 1`, and `DEMO GREEN (7 pass, 0 fail)`, all four `[demo:…]` elements emitted. Caveat: those logs are untracked, so from the diff alone this rests on the QA station's live re-run |
| 8 | Independent cold `fidelity-reviewer` verdict ACCEPT, attested | PARTIAL | At review time no `sessions/session-126-review.md` existed and `## Execution` step 8 still read `done: <sha>`. This pass IS criterion 8 being executed; the attested record did not yet exist, and `check_execution_shas` blocks until both remaining shas land |
| 9 | The residual is stated plainly in the summary, never softened | PARTIAL | The closeout-record half is genuinely shipped and unsoftened — the addendum's "Nothing depends on it… nine decorations", the demo printing it in the HEADER block rather than a footnote, and the verify suite closing with "'Done' is tested here. 'Working' is not, and is not claimed." The summary half was not built at review time: `sessions/session-126-summary.md` did not exist and step 9's sha was still a placeholder |

**7 of 9 SHIPPED** (2 PARTIAL, 0 NOT-BUILT).

## The fakest green

**`five-dispatches-cross-check` + `cross-check-has-teeth`, both labelled `exec`.** These carry
criterion 5 — the session's headline claim — and they run entirely over five JSON files **the
session itself copied into the repo**. Nothing in the repo binds those copies to the runtime
originals in `~/.claude/projects/`; the originals are not committed and `harvest.py` is never
re-run by the suite. The falsifiability fixture forges one field of a copy and proves the checker
notices an INCONSISTENT copy — it cannot, by construction, notice a CONSISTENT fabrication: had
the five dispatches never happened and the ten JSON files been typed by hand with matching ids,
the cross-check and both planted-forgery probes would go green exactly as they do now. The demo
narrates this as "a tool-call id neither side chose", which reads as proved provenance; what is
checked is internal consistency. What actually makes fabrication implausible here is OFF-CHECK:
five `-run.json` result streams with per-model usage, distinct session ids, $4.45 of metered
spend, and ~600KB of transcripts — evidence a reader must weigh, not something a green check
asserts.

Second place, honestly labelled by the author: `residual-is-recorded` (`struct`) greps
DECISION-007 for phrases the author typed — it would pass unchanged if the entire fleet were
decoration, which the addendum concedes it is.

## Other findings — filed into S127, deliberately NOT fixed after the ACCEPT

1. **`K of 8` is compared at a degenerate baseline.** `k_of_8_unchanged` runs `--stations 126` in a
   bare `mktemp` repo where K is `0 of 8` before and after. It proves handoffs do not move K at
   K=0 and that the counter discloses "NOT counted in it" — but "unchanged `K of 8`" against the
   real repo's K is never shown. The load-bearing trace for criterion 4 is the diff's own `src/`
   scope, not this check.
2. **The demo overrode its own role's advice, silently.** The `demo-producer` brief named the
   `verify-session-121.sh` unpin as "the one change that is otherwise invisible in a roster demo".
   The shipped `demo:before_after` shows only the roster (4→9); the out-of-fleet edit is invisible
   in the demo. (It IS covered by the nested live chain in verify, so this is presentation, not
   proof.)
3. **The S121 weakening is acceptable and disclosed, but the names now lie.** `[ "$N" = "4" ]` →
   `[ "$N" -ge 4 ]` leaves the substance (per-role presence, byte-identity, set equality) intact
   and count-independent, and S126 pins `= 9` itself — but the check's name and function
   (`init-scaffolds-four-roles`, `scaffolds_four_roles`) now misdescribe what they assert.
4. **Recorded decay, not repaired.** `verify-session-114.sh` / `verify-session-116.sh` still pin 2
   and 3 scaffolded roles and are now permanently red if anyone runs them. No live chain runs
   them; consistent with the prompt's "record, don't repair" non-goal.
5. **The in-session prompt edit is legitimate and disclosed.** Plan step 9 was added because the
   Planner gate itself reported `plan misses criteria 9`; it adds no scope, since criterion 9
   predates it. That is the pipeline catching its own brief.
6. **Attestation ordering hazard (recurring, structural).** Steps 8 and 9 land after this verdict,
   so the prompt half of `sha256(prompt ‖ diff)` changes after the reviewer read it. Recompute
   `Review-Inputs-SHA` strictly last, confirm two consecutive `verify-closeout.sh --inputs-sha 126`
   runs agree, and state plainly that the attested inputs differ from the inputs this pass consumed
   by exactly those sha lines.

## Verdict

Is the real scope "one narrow slice presented as the whole"? No. This is a faithful build of the
contract: five roles with genuinely distinct contracts pointed at markers that provably exist in
the stations, read-only grants enforced by a test that fails on any new grant, dispatch evidence
with a fixture that goes red for the right reason, a live nested re-run proving the one
out-of-fleet edit harmless, and a residual printed in the demo's header rather than a footnote.
Two criteria are PARTIAL only because they are the closing acts (the review record and the
summary) and cannot exist in the reviewed diff — but they were not yet built, and closeout blocks
until the summary lands with the residual stated plainly and both `<sha>` placeholders are filled.

**Verdict:** ACCEPT

**Review-Inputs-SHA:** `9d7ae228e34f4238382b167d3c8b925170558072deef7ccfbece5fee33b76126`

*(Recomputed strictly last — after the post-review artifact removal landed, since that change
touched `scripts/` and `.gitignore`, which the attested inputs include — and confirmed identical on
two consecutive `verify-closeout.sh --inputs-sha 126` runs. The superseded pass-1 hash was
`39d7030955ac…`; it is recorded here rather than quietly overwritten. Stated plainly, as the reviewer's own
finding 6 required: the attested inputs differ from the inputs this pass actually consumed by
exactly the two closing sha lines in the prompt's `## Execution` section — steps 8 and 9 could not
have landed before the verdict that is step 8. This is the recurring, structural ordering hazard,
recorded rather than papered over.)*


---

# Pass 2 — the post-review delta: session artifacts un-tracked, evidence rewired

**Why a second pass exists.** After pass 1's ACCEPT the founder directed that session artifacts must
not be pushed to git. `sessions/session-126-artifacts/` (1.1 MB, 810 KB of it raw subagent JSONL)
was removed from tracking, `sessions/session-*-artifacts/` was ignored, and the evidence the suites
read became an 8 KB derived record. That touched **reviewed code**, so it was cold-reviewed again
rather than attested on pass 1's reading. The reviewer was fed the prompt and the delta since
`8783a01`, and asked one question: does the delta weaken anything pass 1 graded SHIPPED?

**The brief below is the reviewer's own, landed as returned.**

| # | Criterion (re-examined for delta damage) | Verdict | Evidence / reasoning |
|---|---|---|---|
| 5 | Five proven dispatched by name, S111 two-file cross-check | SHIPPED | The check got **stronger**, the evidence base got **weaker**, and the repo says so in three places. Stronger: 10 required fields, both-direction role agreement, id uniqueness, **distinct `parent_session_id`s**, sha256 shape, handoff-exists-and-names-the-role, fail-closed on an unparseable record, and 6 planted-drift cases (was 2). Weaker: the transcript "real assistant usage line" check and the five `-run.json` streams — the off-check ballast pass 1 leaned on — are no longer in git. Not softened: the record's own "**Does not prove**… that this record was derived from them rather than written", the demo's replacement of "an id neither side chose" with "from the committed record", and the suite header's "Neither mode proves provenance" |
| 7 | Both suites exit 0 with a printed check-class tally | SHIPPED | The real record was hand-traced through the real function: five roles ✓, all 10 fields non-empty ✓, ids equal and unique ✓, five distinct session ids ✓, 64-hex shas ✓, all five handoffs exist with `role:` ✓; every fixture case provably reddens the same function. Tally infra untouched, 15 checks preserved. The class mix moved: `exec 11 · struct 2` → **`exec 10 · struct 3`** |
| 4 | Traced, not asserted: nothing else moved | SHIPPED | The delta touches `scripts/`, `.gitignore`, one new `sessions/` record. Zero `src/` |
| 8 | Cold `fidelity-reviewer` ACCEPT, **attested** | PARTIAL | The attested inputs include `scripts/` and `.gitignore`, both changed after `8783a01`, so pass 1's embedded hash was stale by construction and the gate would BLOCK. (Resolved at closeout: recomputed above, twice agreeing, after the delta's last commit.) |
| 9 | Residual stated plainly, never softened | SHIPPED | Strengthened by the delta: "Say plainly what that costs", "a clean clone checks the RECORD, never the runtime's own files", S127 candidate B named |
| 1/2/3/6 | Roster keys · marker-citing prompts · tool grants · DECISION-007 addendum | SHIPPED | Untouched by the delta and free of collateral |

**5 of 6 SHIPPED** (1 PARTIAL, 0 NOT-BUILT). No criterion graded SHIPPED at pass 1 is weakened
below the line; criterion 8 was already PARTIAL at pass 1 and stays PARTIAL for a new, mechanical
reason.

## The fakest green of the delta

**The "STRONG path" — `if os.path.isdir(raw_dir)`.** It is the one genuinely provenance-bearing
thing the delta added (re-derive ids and re-hash the transcript from the runtime's own files,
require a match), and the very policy that motivated the delta guarantees it **can never run
anywhere except the machine that made the artifacts**. In a clean clone it takes the `else` branch,
prints a disclosure, and the check goes **green with an identical exit code** — a `struct` check
that would pass unchanged if the five dispatches had never happened and the record had been typed.
The fixture's strong case is gated the same way and is **not scored**, so no tally row anywhere
records whether the strong path ran. The S69 hollow-green class, re-created honestly rather than
hidden: the check discloses its mode in prose, but the score does not.

Second, and a real overclaim: the comment "This is the one field a purely invented record cannot
satisfy silently" is **false** — `vajra next --role <name> --from <any file>` mints a governed
handoff with no dispatch, so handoff-existence costs a fabricator one command. Meanwhile the record
carries a `brief_sha256` per role that **exactly equals that handoff's `source-sha`** (verified on
all five) — a real in-repo binding that costs nothing to check, is not in the required-field list,
and is never compared. **The strongest available check was left on the table while the weaker one
was labelled the strong one.**

Third: `evidence-record-has-teeth` keeps the `exec` label after its subject was honestly demoted to
`struct`; it runs the suite's own shell function over text files and never touches the `vajra`
binary. Credit where due on the S122 lesson: the fixture drives the **real** function, not a
retyped copy, and mutates a *copy* of the real record.

## Other findings — filed into S127, deliberately NOT fixed after this pass

1. **`.gitignore` semantics bug (introduced by this delta).** `sessions/session-*-artifacts/`
   excludes the parent directory of the S76/S77 carve-outs above it. Git cannot re-include a file
   whose parent directory is excluded, so `!sessions/session-76-artifacts/fixtures` is now **inert
   for untracked files**. Nothing is red today (those files are tracked), but regenerate or re-add
   one and `verify-session-77.sh` / `verify-session-78.sh` go red on a fresh clone with no obvious
   cause.
2. **The new rule contradicts live suites.** `demo-session-111.sh` reads a *committed*
   `researcher-subagent-meta.json`, and `verify-session-117/122/123/76/78` all read tracked
   per-session artifact dirs — precisely the shape the new rule forbids going forward. The
   `.gitignore` comment says tracked files are unaffected (true) but never says the repo's own
   precedent now violates its new rule.
3. **The governance chain's human-readable input dangles.** `sessions/session-126-review.md` cites
   the diff the pass-1 ACCEPT was based on; that file is now untracked. The attestation mechanism
   survives (it recomputes from git); the citation does not.
4. **The unused binding.** Add `brief_sha256 == the handoff's source-sha` to the record check — the
   one in-repo tie between the record and something Vajra itself wrote.

## Verdict

The delta is a faithful, disclosed re-basing of one check, not a quiet weakening: the record check
is materially harder to satisfy than what it replaced, its fixture drives the real function, the
class label on the record check was voluntarily *downgraded* to `struct`, and every honesty line
probed says "record, not proof" rather than implying proved provenance. What it costs — third-party
re-derivability of criterion 5 — is stated plainly in four places and correctly routed to S127
candidate B.

**Verdict:** ACCEPT
