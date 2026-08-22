# Session 127 — CODE: every recommendation must be ANSWERED

**Prompt:** `prompts/127-task-answer-every-recommendation.md` · **Review:** `sessions/session-127-review.md`
**Branch:** `session-127-answer-every-recommendation` · **Date:** 2026-08-22

**Verdict:** ACCEPT

---

## What shipped, in one line

When this team asks a role for advice, the session must now answer **every numbered recommendation
in writing** — `obeyed: <sha>` that resolves, `refused: <reason>` that is written, or
`deferred: <path>` that exists — or `vajra next --advance` refuses to close it.

**This is the first gate that consumes a governed handoff as a binding input.** Eight station gates
read a marker inside the session's own prompt; this one reads `.ai/handoffs/session-NN-<role>.md`
too, and binds the two together. `DECISION-007`'s S116 addendum marked exactly that an *"explicitly
deferred… non-goal"*; the S127 addendum **lifts that deferral out loud**, rather than citing around
it — a distinction that matters because the Architect gate checks that a cited record EXISTS, not
that the design obeys it.

## The floor, stated plainly and never softened

**This proves every recommendation was ANSWERED. It does not prove the answer was good.** That an
`obeyed:` commit really implements the advice, or that a `refused:` reason is sound, stays a
judgement only an independent reader can make. **Required ≠ obeyed; answered ≠ obeyed well.**

It does not force obedience and must never be sold as if it did. A refusal with a written reason is
honest disobedience and **passes** — that is correct and intended. What becomes impossible is the
silent version, which is the one that actually cost S126 twice.

**And the sharper form, which this session proved on its own body:** *a wrong `obeyed:` is
indistinguishable from a right one, to this gate.* The cold review's pass 1 found
`implementation-advisor rec 9 — obeyed: 8cd3bea` sitting in the ledger while the stub that rec told
this session to delete was still in the shipped file. The sha resolved, so the gate scored it
ANSWERED. The disposition word carries all the meaning and none of the checking. **The only thing
that caught it was a reader.**

## The dodge, repeated here as criterion 6 requires — not buried

> NO numbered `rec N —` recommendations are recorded, so this gate has nothing to enforce. Say it
> plainly: **DELETING THE NUMBERS DODGES THIS GATE.** Like every marker gate here, its jurisdiction
> is self-granted (S68/S71) — an advisor that never numbers its advice cannot be made to, and advice
> dropped from an unnumbered brief stays exactly as invisible as it was before S127.

That is not a hypothetical. **Run against S126's own five committed handoffs, this gate exits 0.**
It would **not** have caught either of the two drops that motivated the entire session. Demo case 10
shows that live and scores it as a disclosed limit. Retroactively, S127's evidence is a WARN.

## Fidelity map — every numbered acceptance criterion

| # | Requirement | Verdict | Evidence |
|---|---|---|---|
| 1 | Unanswered rec BLOCKS via the real binary, naming role + number + path | SHIPPED | `src/advice/mod.rs` `advice_gate`; verify `unanswered-rec-blocks-the-close` |
| 2 | All answered → passes, one line per rec showing its disposition | SHIPPED | `src/cli/next.rs` `run_check_advice`; verify `every-rec-answered-passes` |
| 3 | `obeyed:` sha that does not resolve → unanswered, BLOCKS | SHIPPED | `check_evidence` + `coder::commit_exists`; a bare `HEAD` is rejected too |
| 4 | Empty / placeholder `refused:` → BLOCKS | SHIPPED | `substantive_reason`; the one-word floor asserted, not implied |
| 5 | `deferred:` to a non-existent file → BLOCKS | SHIPPED | `check_evidence`, plus absolute-path and `..` refusal |
| 6 | Zero numbered recs → WARN, dodge named; summary repeats it | SHIPPED | `advice::DODGE` (one const); demo case 10; quoted above |
| 7 | Every role taught the marker shape, asserted per role | SHIPPED | `RECOMMENDATION_NUMBERING_RULE` + per-role and round-trip tests |
| 8 | `K of 8` and the command count unmoved; no other contract moves | SHIPPED | `s127_added_no_station_and_did_not_move_k_of_8`; verify at a **non-degenerate** `8 of 8` baseline |
| 9 | Falsifiability fixture RED for the right reason | SHIPPED | `mod falsifiability`; both deletions RED, every message renamed → still GREEN |
| 10 | Both scripts exit 0 with a check-class tally | SHIPPED | verify **10/10** (9 exec · 1 behav, labelled) · demo **13/13** (all exec) |
| 11 | Independent cold `fidelity-reviewer` ACCEPT, attested | SHIPPED | `sessions/session-127-review.md` — pass 1 REJECT, fixed, pass 2 ACCEPT |
| 12 | Summary states the floor, unsoftened | SHIPPED | this file, above |

**12 SHIPPED · 0 PARTIAL · 0 NOT-BUILT** after the pass-1 fixes. Pass 1's own count was
8 SHIPPED · 2 PARTIAL · 2 NOT-BUILT, and it was right.

## What I did NOT build

- **No judge of whether advice was followed WELL.** Explicitly a non-goal, and the one thing this
  session most looks like it does.
- **Only ONE gate consumes handoffs.** The other seven do not. The fleet is one notch more wired in
  than S126, not ten.
- **No new role, no 8th command, no new artifact type or store.** The disposition lives in the
  prompt's `## Advice`, beside `## Execution`, for the same reason.
- **No S125 reboot-backlog item.** Still parked.
- **Nothing dispatches an advisor unprompted.** The standing S111 limit, undisturbed.

## The fakest green

**The one the reviewer named, and it survives the fix.** `obeyed:` certifies that a human typed a
word and named a commit that exists. Nothing checks that the commit does what the advice asked.
41 of this session's 43 answers are `obeyed:`, 22 of them pointing at a single commit. One of them
was **wrong** and passed. It was caught by a reader, not by the gate — which is precisely what the
gate's own documentation says will happen, and is why criterion 12 forbids the stronger claim.

Second: the verify suite's one behavioral check (the hardcoded usage-banner grep, named since S69).

## Dogfood — this session is the first subject of its own gate

Three roles were dispatched by name and returned **51 numbered recommendations**:
`implementation-advisor` (19) · `demo-producer` (24) · `fidelity-reviewer` (8). Every one is
answered in the prompt's `## Advice`. Two are `refused:` with written reasons that match the code.
Two partial obediences are disclosed in the section itself rather than hidden behind an `obeyed:`.

**The mechanism found two real defects in its own author while being built:**
1. `fleet::handoff_body` drops every `#` line, so a `### rec 3 — …` heading-form recommendation was
   being silently under-counted — the exact class of invisible loss the session exists to end.
   Fixed by `handoff_findings_raw` (the `implementation-advisor`'s rec 3).
2. The prompt demonstrates the contract in a **fenced example containing a literal `## Advice`
   heading**, and the section locator picked up the example instead of the real section — so 43
   real answers went unread while three fake ones were counted. Found by running the gate on this
   session's own prompt.

## Next — three ranked candidates

**A · Make a second gate consume its role's handoff (RECOMMENDED).**
*Goal:* pick one more station — QA or Demo-er, both of which already have a live re-run — and make
its `--check-*` path bind on the matching role's governed handoff, so skipping that role has a
consequence.
*Why:* S127 proved the pattern on one gate and the addendum lifted the deferral narrowly. The
honest headline today is still "one of eight". The second one is where "the fleet works" starts
being a claim about the fleet rather than about a gate.
*Risk:* the S126 lesson repeating one level up — a second consumer that nothing reaches for is a
second decoration. Pick the station whose role is actually dispatched.

**B · Close the `obeyed:` hole — bind the disposition to the diff.**
*Goal:* make `obeyed: <sha>` check something beyond existence — that the named commit touches a
file the recommendation names, or that it is one of this session's own commits.
*Why:* it is this session's disclosed fakest green, with a live specimen behind it. Even a weak
binding (the sha must be an ancestor of HEAD and not on `main`) turns a typed word into a claim
with a shape.
*Risk:* the honest ceiling is low and easy to oversell. "The commit touches a file the advice
mentions" is still not "the commit implements the advice", and criterion 12's line must hold.

**C · The S125 reboot backlog — unpark it.**
*Goal:* the founder's gate was *the SDLC agent fleet is done AND working*. S126 closed *done*; S127
made one gate depend on a role's output. Take the parked findings: the 55-line scaffolded
constitution, `verify-closeout.sh` crashing on a fresh `vajra init`, unknown subcommands exiting 0.
*Why:* those are the only items on the list that a stranger would ever notice, and adoption is flat
at 0 stars after 55 days public.
*Risk:* it is the founder's call whether one consuming gate satisfies *working*. It may not — in
which case A comes first.
