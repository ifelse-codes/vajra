# Session 136 — `vajra init --sync-fleet`, and the fleet made real in chitra

**Type:** CODE · 1 story · branch `session-136-chitra-fleet-upgrade`
**Goal:** bring chitra to Vajra's full ten-role fleet, make the crew gate actually BIND there, and
resolve the upgrade path a real adopter needs.

---

## The headline finding — and it was not the one the prompt predicted

The prompt expected the finding to be *"Vajra has no upgrade command."* True, but shallow. The real
one was measured in the first ten minutes:

| chitra `.claude/agents/` | on disk | canonical render | state |
|---|---:|---:|---|
| `researcher.md` | 1,221 B | 3,270 B | **stale** |
| `plan-advisor.md` | 2,191 B | 4,240 B | **stale** |
| `qa-specialist.md` | 3,002 B | 5,051 B | **stale** |
| `fidelity-reviewer.md` | 2,712 B | 4,761 B | **stale** |
| the other six roles | — | — | absent |

The four *present* files were not merely old. Every one was missing the whole appended protocol
block — `## Numbered recommendations (Vajra parses these)` and `## Judging an obeyed: disposition` —
that teaches a role to emit the `rec N —` lines the Advice and Obedience gates parse.

**chitra's four installed roles could not have produced parseable advice.** Run `--check-advice`
there and it would have read nothing and reported nothing wrong. A silently degraded role is worse
than an absent one: an absent role is visibly absent.

**The structural cause: `skip-if-present` CAN ADD; it can never UPDATE.** That convention is right
for a file the user owns and wrong for a file Vajra renders. The fleet grew from four roles to ten
over eleven sessions and no adopter had any supported way to receive that growth.

---

## What shipped

**`vajra init --sync-fleet [--dry-run] [--overwrite-drifted]`** — a FLAG on an existing command, so
the seven-command ceiling holds. It re-enters the same `for role in fleet::ROLES` loop `files()`
already uses, scoped to the role definitions and nothing else: a project at session 16 asking for the
new roster must not also receive a `prompts/01-task-kickoff.md`.

| state | what it does |
|---|---|
| `Missing` | create from the canonical render, always |
| `UpToDate` | nothing — a no-op write still churns mtime and git status |
| `Drifted` | **report and refuse**; rewrite only under `--overwrite-drifted` |

Exit **0** when every role file is canonical; exit **1**, naming each file and the resolving flag,
when any is left drifted. `--dry-run` computes the identical plan, writes nothing, and returns the
code the real run would — a preview that exits 0 where the real run exits 1 previews a different
command.

**The one thing it cannot do, shipped as the answer rather than as a gap.** Vajra cannot tell a
STALE RENDER from a USER'S OWN EDIT. Both are the same single observable — bytes that differ from the
current render — and nothing on disk records which Vajra wrote a file. `FleetFileState` has exactly
three variants because only three are derivable. A classifier over git blame or timestamps was
considered and rejected: it would invent provenance that was never recorded. `--overwrite-drifted` is
not a convenience flag; it is where a human takes the judgement the machine cannot make.

*(The obvious fix, scoped and NOT built: stamp each rendered file with its own content hash, so a
later run can tell "an old render of mine" from "a file someone edited." That changes the render
format and every existing installation. It earns its own session.)*

---

## chitra, proven live

- **10 of 10 role files, byte-identical** to `fleet::render_subagent_definition` (`cmp` per file).
- **The crew gate BINDS there.** `vajra next --check-crew 16` inside chitra: **exit 1**, `NOT READY`,
  naming the tech-lead as the first-and-mandatory dispatch and resolving chitra's *own*
  `.ai/handoffs/session-16-tech-lead.md` path. The S135 no-threshold rule holding in a real
  brownfield project **117 sessions below** the old 133 threshold — not a fixture.
- **Idempotent:** the second run reports 10 already current and writes nothing.
- **chitra undisturbed**, four ways plus content: HEAD `12531f1f`, branch
  `session-16-sparkline-histogram-lock`, index tree `1ed655a7`, stash count 1 — all identical to the
  pre-write baseline; everything outside the ten pre-declared paths hashes the same.
- **Nothing was committed in chitra.** Its session-16 work is in flight and its constitution requires
  human approval, so the ten files sit as working-tree changes for the founder to commit or revert.
  All four refreshed files were tracked and clean, so each is reversible with one `git checkout`.

---

## The deviation, stated plainly

The prompt's inherited guardrail said *"do NOT disturb chitra's 4 existing role files."* Acceptance
criterion 1 said all ten must match the canonical render byte-for-byte, *"a drifted copy FAILS, never
a silent skip."* Given the measured drift **both cannot hold.**

Criterion 1 governs. `DECISION-007` defines every `.claude/agents/*.md` as a pure render that is never
hand-typed, so refreshing the four CLOSES a drift condition the record already forbids rather than
introducing one. Executed as a pre-declared, named action — all ten paths listed before a byte was
written. That reasoning is in the prompt's `## Design`, in the DECISION-007 S136 addendum, and here,
because it is a human's call about someone else's repository.

---

## Evidence

`scripts/verify-session-136.sh` — **11 checks, all execute-based, 11 passed, RESULT: PASS.**
454 lib tests green (8 new), `cargo fmt --check` clean on the files this session touched.

**Falsifiability probes, run live:**

| probe | planted defect | result |
|---|---|---|
| A | chitra absent (`VAJRA_CHITRA_ROOT` → empty dir) | 3 checks **RED** — absence fails, never skips (S69) |
| B | one chitra role file tampered | check 7 **RED** |
| C | append to a file chitra had *already* modified | **PASSED — a real hole in my own check** |
| C′ | same, after the fix | check 9 **RED** |
| D | a new undeclared untracked file | check 9 **RED** |

**Probe C found a genuine defect in this session's own verify suite.** `git status --porcelain`
records paths and status letters, so appending to an already-dirty file left the status hash
unchanged and the check passed a planted defect. Closed by also hashing the tracked diff and the
untracked file set outside the declared paths.

---

## What the independent judge caught — and it blocked the close

A cold `implementation-advisor` graded all 16 `obeyed:` dispositions: **13 implemented, 3 MISMATCH.**
`vajra next --check-obeyed 136` blocked. All three were real:

- **tech-lead rec 3 and rec 4** recorded `obeyed: <sha>` for claims about how a subagent was
  *briefed*. No Rust commit or shell script can carry that. The shas were **decorative** — an
  unverifiable process claim dressed in a git-checkable shape. Corrected to `deferred:` pointing at
  the provenance-verified handoffs where the dispatches actually live.
- **design-advisor rec 7** cited a commit containing only DECLARE lines and hashes, while the
  reasoning it claimed sits word-for-word in the DECISION-007 addendum. Sha corrected.

**This is the first time the obedience gate blocked on a disposition-SHAPE error rather than a
missing answer** — the judge found not "you didn't do it" but "your evidence could not possibly show
that you did."

### The judge's weakest-green finding, carried forward rather than buried

Verify **check 9** is the most likely false green. Its two CONTENT-level baselines were captured
AFTER the ten declared writes — chitra's session-16 work is uncommitted, so no pre-write content hash
can be reconstructed. The check would therefore still pass the exact defect probe C planted. The
path-level status hash and the four-way baselines ARE true pre-write ones and prove no path appeared,
vanished, or changed status; the content guarantee is frozen from mid-session onward rather than
closed. Recorded in three places on purpose.

---

## Cost

**731,943 raw subagent tokens** across 3 dispatches (`vajra next --crew-cost 136`):

| role | raw tokens | allowance | actual |
|---|---:|---:|---|
| implementation-advisor | 397,833 | 350,000 | **114%** — an overrun, recorded as a finding |
| design-advisor | 198,175 | 250,000 | 79% |
| tech-lead | 135,935 | — | **no budget recorded for itself** |

Against S135's 4,183,839 raw across 5 dispatches. The named-files discipline held: every brief named
its files and forbade a repo read, and the whole session's crew cost **5.7× less** than S135's.

**Two small gaps this exposes.** The `tech-lead` records a budget for all nine specialists and none
for itself, so `--crew-cost` can never report it against an allowance. And the S135 criterion-7 gap
is still open: nothing carries the recorded budget INTO a dispatch brief, so the 114% overrun was
only visible after the fact.

---

## Also found, not fixed (one story)

`cargo fmt --check` **FAILS on main** for three files S135 left unformatted (`src/cli/next.rs`,
`src/crew/mod.rs`, `src/fleet/mod.rs`). This session's own `cargo fmt` swept them up; they were
reverted to stay inside the 3-file cap. **This is a recurrence** — S96 was an entire session fixing
exactly this. It came back because nothing gates it every session, only two old per-session verify
scripts. Spun off as a separate task.

---

## Next — 3 ranked candidates

1. **S137 — the scatter dogfood** (`prompts/137-task-chitra-scatter-lock-dogfood.md`, already
   drafted). The paid run the whole arc was for: lock chitra's `scatter` chart to the reference
   design language with the FULL crew now able to run there, founder signing off on the rendered
   chart. **This is the founder-approved next step and it is now unblocked.**
2. **Close S135's criterion 7 — carry the budget INTO the dispatch brief.** The 114% overrun above is
   the argument: the allowance exists, is reported, and reaches nobody who could honour it. Small
   read surface, no ladder edit; also gives the tech-lead a budget for itself.
3. **Stamp the render with its own hash**, so `--sync-fleet` can finally tell a stale render from a
   user's edit. Turns today's honest refusal into a real answer — but it changes the render format
   and every installation, so it needs its own session and a migration story.
