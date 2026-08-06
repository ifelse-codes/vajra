# Session 113 — Independent fidelity review (cold, two passes)

> **DECISION-002 artifact.** The builder does not grade itself. Two separate cold subagents were run,
> each in its own fresh context, each fed EXACTLY two files — the contract
> (`prompts/113-task-fleet-counter-and-second-role.md`) and the delivery diff — and denied everything
> else: no summary, no `.ai/` state, no roadmap, no git, no build. Neither was told the expected
> verdict. Both were framed adversarially: *assume the builder silently re-scoped to whatever yields
> a green checkmark; find the fakest checkmark.*

## Method controls

| Control | Pass 1 | Pass 2 |
|---|---|---|
| Contract fed | `prompts/113-task-fleet-counter-and-second-role.md` | same |
| Diff fed | 615 lines (excludes `sessions/`, `prompts/`, `.ai/`) | 685 lines — the same diff plus pass 1's fixes |
| Denied | repo, git, build, all self-narrative | same |
| Told the answer? | no | no |
| Verdict | **ACCEPT** | **ACCEPT** |

**Stated cost of the controls (both reviewers raised it):** a cold reviewer cannot observe greenness.
"`cargo test --lib` green" and "both scripts exit 0" are claims a diff cannot settle; they graded the
*assertions*, never the *outcomes*. The builder's own live runs: **317 lib tests, 0 failed** ·
`scripts/verify-session-113.sh` **14/14 ALL GREEN** · `scripts/demo-session-113.sh` **7/7, exit 0**.
CI on both OS is unevidenced pre-merge — structurally impossible before the PR runs (the standing
PARTIAL carried since S109).

## Pass 1 — ACCEPT, with four real holes

| Requirement | Pass 1 verdict |
|---|---|
| Deliverables 1, 2, 3 | SHIPPED |
| Deliverable 4 (scripts) | built; greenness unverifiable from a diff |
| Deliverable 5 (summary + review) | outside the diff window |
| Criteria 1, 2, 3, 4 | SHIPPED |
| Criteria 5, 6 | unverifiable / this document |
| Non-goals | all honored |

Findings fixed in-session (`94f369a`):

1. **F3 — the not-built guard had no teeth on macOS.** `grep -qE '^\s*name: "reviewer"'` — BSD/macOS
   `grep -E` reads `\s` as a literal `s`, so an *indented* reviewer role would not have matched and
   the guard would have reported "no role code shipped" while a role existed. Now `[[:space:]]`,
   searched across all of `src/`, plus a guard-on-the-guard: the same pattern must match the
   researcher role that DOES exist.
2. **F2 — the headline byte-identity check ran in a repo where every station sat at its floor**, so
   "nothing else moved" was trivially true. Both scripts now scaffold a real prompt (K=2, live) and
   FAIL outright if K is 0.
3. **F8 — "the fleet line" was a bare `grep -v "fleet:"` substring filter**, which would silently
   swallow any future line containing the word — turning the suite's strongest check into one that
   hides the difference it exists to catch. Now anchored (`strip_fleet`).
4. **F7 — a tautological assertion** (a deterministic function compared to itself on unchanged disk)
   dressed as a control. Replaced with a real one.
5. **F1 (honesty) — the demo claimed S111's fleet line proved a by-name subagent dispatch.** It
   proves a contract-valid handoff exists. Label rewritten to say exactly that.

Carried, not fixed: **F4** (`no-eighth-command` greps a usage banner — house-wide weak check, named
at S111 and S112) and **F9** (a decision record is graded by prose greps — inherent).

## Pass 2 — a fresh reviewer on the updated diff: ACCEPT

Pass 2 confirmed pass 1's fixes (it independently cleared the `[[:space:]]` portability, the
`local rc=$?` capture, the BRE `|` literal in the usage grep, `named_test_passed`'s teeth, and
bash-3.2 safety) and then found its own, sharper hole:

1. **F1 — the `>= 2` hole. MEDIUM, fixed (`993cd71`).** Every check in the suite — shell and Rust —
   wrote at most **one** handoff. A station rewired to PASS when `governed.len() >= 2` would have
   kept the entire suite green, and **two handoffs is the normal state the moment the second role
   this session just chose gets built**. Fixed where the invariant actually lives: a test asserts
   `K` is unchanged under *any* fleet evidence (3 governed + 1 malformed, injected directly) and
   exercises the plural render path, which nothing else reached. Wired into verify as
   `test-k-invariant-any-fleet`.
2. **F2 — the doc-comment overclaimed. Fixed (`993cd71`).** `FleetEvidence` was documented as "what
   the fleet demonstrably did"; it records that a **contract-valid handoff exists**. The reviewer
   noted the verify script itself demonstrates the gap — its passing input is hand-typed prose piped
   through the real writer, with no agent anywhere. Doc-comment now says so.
3. **F7 — name collision. Fixed in the record (`993cd71`).** A fleet role keyed `reviewer` collides
   with the **Reviewer station** already counted in `K of 8`. The addendum now requires the build
   session to pick a distinct key or state explicitly that the role *is* the station's agent.
4. **F4 — "is the real-data check machine-local?" CLEARED with evidence.** `.ai/handoffs/*` are
   **tracked** (`git ls-files .ai/handoffs/` lists both S109's and S111's), so `real-handoff-beside-k`
   holds on a fresh clone and in CI.
5. **F3 — no `.ai/` changes despite the Delta claiming retirements.** Correct observation, and it is
   closeout timing: STATE.md and ROADMAP.md are synced at closeout, after the review, by design (the
   attestation hash excludes them so it stays stable). Both retirements are recorded there.

Carried, not fixed: **F5/F6** (prose greps; a hand-counted "46 reviews" figure) and **F8**
(`strip_fleet` assumes a one-line record — fails RED, never green, if a reason ever contains a
newline).

## The fakest green (both passes agreed, in different words)

**`fleet: 1 governed handoff(s) — researcher` counts an ARTIFACT, not an agent.** This passes:

```
printf 'anything at all\n' > findings.md
vajra next --role researcher --from findings.md
vajra next --stations 113        # → fleet: 1 governed handoff(s) — researcher
```

No subagent, no dispatch, no research. The self-assertion moved out of the prompt and into a
`--from` file — one honest step above a typed marker (it must round-trip through the real writer and
satisfy a parser), but the contract's phrase "never a self-asserted marker" oversells the distance.
Anyone pitching this line must say **"a contract-valid handoff exists"**, never "an agent was
dispatched". Disclosed in the summary, in the demo's own case 4, and now in the code's doc-comment.

## Verdict

**ACCEPT** — all five deliverables built with two-sided, behaviour-proving checks; every non-goal
honored (the second role is chosen and a guard fails if it appears in code); K's preservation is
settled by the diff's structure, not merely by a script; and both passes' real findings were closed
in-session rather than argued away.

**Review-Inputs-SHA:** d478a0225ba3ebf9ca6f884796d5c60789f920283ede9ee24d2cf47215faa187
