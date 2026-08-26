# Session 134 — PAID DOGFOOD: a real governed session in chitra, reviewing the mudra charts

**Goal achieved.** One real paid session ran inside `/Users/suman/playground/chitra` through
`vajra claude`, reviewed every chart chitra has locked to its mudra reference design language by
**rendering and looking at each one**, and produced both deliverables: the founder's design verdict
and a measured account of what Vajra's governance actually did.

**Cost: `$1.6103385`, authoritative.** 25 turns, 329s. The S77/S78 receipt arc paid off — a real
figure from the `-p` result stream, not the honest null the design-advisor predicted was likely.

---

## The headline finding — the one this repo could not have manufactured

Nine sessions of governance machinery had only ever been exercised against fixtures this repo wrote.
The first time the S133 mandate was pointed at a real outside project, it found a hole in itself.

    === mandate: design-advisor for session 16 ===
    prompt:  prompts/16-task-sparkline-histogram-lock.md
    handoff: (none)
    verdict: READY
      ⚠ session 16 predates the design-advisor mandate (threshold 133) — silence is exempt
        below it, and only below it.

chitra's session 16 is **actively locking two more chart families to a reference design language.**
It is the exact session the design-advisor mandate exists for. It gets READY, with no handoff at all.

S133 disclosed and closed the **fresh-project** case (a scaffolded prompt carries the marker as a
placeholder, so session 1 of a new repo blocks). It never reasoned about the **brownfield** case: an
already-governed project sitting below 133, whose prompts were all written before the marker
existed. For Vajra the threshold is a closing window — we are at 134 and every future session is
above the line. For a project that adopts Vajra at its session 40, it is a **permanent exemption**
with nothing in the mechanism that ever ends it.

**The threshold counts the wrong units.** It counts the governed project's session numbers, when
what it means is "prompts written before this rule existed."

Recorded as the **DECISION-007 S134 addendum**, with three candidate fixes named and **none picked**
— n=1 does not earn a mechanism. S135 makes `implementation-advisor` mandatory on this same
mechanism and will inherit this hole from birth; it must either fix the units or record in writing
why it ships a second mandatory role with a known permanent gap.

---

## Did the governance make this real piece of work better? — yes, measurably, once

The falsifiable answer criterion 9 demands, in three parts rather than an adjective.

**(a) The advice preceded the work.** The F2f hand-check (F2f is *not* built this session):

| | |
|---|---|
| handoff `captured:` | `2026-08-26T14:23:27Z` |
| first substantive commit `dca0a85` | `2026-08-26T14:26:31Z` |

Three minutes apart, and the entire diff between them **is** the advisor's corrections.

**(b) One named thing that is different because of the advice.** Commit `dca0a85`. The
`design-advisor` returned 22 recommendations and found the session brief itself **factually wrong in
seven places** — before a paid minute was spent:

| The brief said | The truth on disk | Cost if unfixed |
|---|---|---|
| 3 locked families | chitra's README locks **4** — it omits `area` entirely | the founder's flagship question answered about the wrong set |
| `horizontalBar` is in the S12 bar lock | the README's bar section never names it | a pre-mudra chart reviewed as if locked |
| "`scripts/` has per-chart demo scripts" | there are none — only per-*session* scripts | paid minutes burned discovering it |
| "`pnpm check:catalog`" | it is a docs-**package** script, not a root one | same |
| criterion 9: "governed in BOTH repos" | **impossible** — chitra has no `design-advisor.md` and its S16 is below the threshold | a self-granted-jurisdiction green |
| criterion 6: diff `git status --short` | breaks **by construction** — the deliverable lands in chitra | a criterion that cannot pass honestly |
| "the weakest chart of the six" | a pre-baked count that criterion 2 forbids trusting | contradicting our own instruction |

Rec 19 also caught a **pre-existing stash in chitra that `git status --short` never shows**. Without
the four-way fingerprint, "chitra was not disturbed" would have been a claim about three of the four
things that could have moved.

**(c) One rec that changed nothing — the honest null.** **rec 8** (put captures under
`chitra/.ai/verify/…` because `.gitignore` already ignores it). Correct, and it changed no decision:
that is where they were going anyway, since chitra's own S15 artifacts already live there. Recorded
as obeyed because it *is* what happened, not because the advice caused it.

**And one rec obeyed with a deviation, stated rather than buried.** **rec 14** asked for the manifest
at `sessions/session-134-artifacts/seen-manifest.tsv`. That exact path is **gitignored**
(`sessions/session-*-artifacts/*`), so it could never be the *committed* file the rec required. It
landed one directory up at `sessions/session-134-seen-manifest.tsv` — committed, small, derived,
which is what the founder's S126 rule actually allows. The advisor was right about the mechanism and
wrong about the path.

---

## Where the governance cost more than it gave

A dogfood whose findings are all favourable has not been run honestly.

- **The co-pilot loader blocked a compliant commit.** `⚡on(cmd:git commit)` fired demanding
  `.ai/STATE.md` be loaded — a file already printed by the SessionStart hook and already in the
  mandatory load order. The gate cannot distinguish "read at boot" from "not read", so it fires on
  the first commit of every session regardless. Cost: one retry. Value on this run: **zero.**
  Captured in `gate-log/copilot-loader-git-commit.txt`.
- **The whole ~2h session produced governance evidence and one review file.** The review is real and
  the founder wanted it — but nothing shipped that a *stranger* can reach. That is now ten
  consecutive sessions with nothing in a user's hands.
- **Two mandatory roles, and the one that fired is the one we dispatched ourselves.** The mandate
  proves a dispatch occurred and that its provenance verifies. It still cannot prove the advice
  reached the design — F2f, still unbuilt, still the highest-value open governance item. This
  session did F2f's comparison **by hand** and it was genuinely informative, which is an argument
  for building it, not a substitute.
- **`$1.61` bought a chart review.** Honest framing: the same review was within reach of a person
  with a terminal and twenty minutes. What Vajra added was that the review is *attested* — every
  chart re-hashable, every gate outcome captured verbatim, the untouched-repo claim mechanically
  checkable. Whether that is worth $1.61 is the founder's call, not this summary's.

---

## Cost, stated the way the last two sessions did not

| | |
|---|---|
| **Metered, authoritative (the paid chitra run)** | **`$1.6103385`** |
| Unmetered Vajra-side subagent tokens | design-advisor **133,297** · fidelity-reviewer + judge (see review) |
| Vajra-side build cost | interactive, `$0` metered |

S132 recorded ~367k and S133 ~550k unmetered subagent tokens against "$0 metered for build". A
headline of "$1.61" that omits the Vajra-side dispatches understates reality the same way. It is
stated here beside the figure, per design-advisor rec 20.

---

## The design verdict (the thing the founder actually asked for)

**IMPRESSIVE — with two cheap, fixable blemishes.**

The mudra language is not a coat of paint; it is an **enforced** system, and that was verified at the
raw-RGB level rather than by eye: every locked chart spends **one** accent hue (`#8B7CF6`) exactly
once and paints everything else with the *literal* documented grey ramp
(`#ECECEF #C6C6CE #A4A4AE #6A6A75`), hex-for-hex. That discipline holding across four unrelated
geometries — a braille circle, a filled area, a spline line, block bars — is the genuinely impressive
part.

| Family | Seen how | Verdict |
|---|---|---|
| circular (pie/donut) S09 | fresh-render-terminal | strongest work — a genuinely *round* braille disc, donut total in the hole. Cost: font-fragile |
| line S10 | fresh-render-terminal | cleanest tone+dash+glyph; multi-series recedes to grey, no fourth hue |
| bar S12 | fresh-render-terminal | textbook one-accent-on-peak — but x-labels crush to `JaFeMaApMaJuJuA` |
| area S09 | fresh-render-terminal | correct colours, **ragged y-labels** zig-zag the `│` guide; only locked chart with no x-axis |
| sparkline + histogram | fresh-render-terminal | **IN FLIGHT, NOT MERGED** — both faithfully wrapped in the locked panel |
| horizontalBar | fresh-render-terminal | **negative control** — genuinely pre-mudra: no frame, `░` filler, zero 24-bit colour |

- **Weakest chart:** `area`.
- **Single highest-impact change:** un-crush the bar x-axis labels. It is the flagship chart and the
  one thing that looks *broken* rather than merely unfinished.
- **Findings handed to chitra's maintainers:** `.ai/STATE.md:22` omits `area` from the locked
  families that `README.md:132` explicitly locks — real documentation drift. Two defects written up
  as **ranked proposals, not fixed** (the Non-goal held).
- **One thing the paid run did not catch, found on my own read of the renders:** `area`'s summary row
  reads `series · max 61 · min 12 · last 58` — max-before-min, and **no `avg`** — while `bar` reads
  `· min 31 · max 72 · avg 51 · last 58`. The README states the summary cells as a locked element.
  That is a third (minor) inconsistency, and it is offered as a proposal, unfixed.

Full review, with every render inline: `chitra/sessions/mudra-chart-review-2026-08-26.md`.

---

## Fidelity map — every numbered requirement

| # | Requirement | Status | Evidence |
|---|---|---|---|
| 1 | Real run through `vajra claude`, binary + version recorded | SHIPPED | `binary-provenance.txt`: installed release `~/.cargo/bin/vajra` 0.1.0, sha `f622648d…`, byte-identical to the repo build |
| 2 | Chart list re-derived live, disagreements recorded | SHIPPED | README locks 4 families incl. `area`; STATE.md omits it; `horizontalBar` not in the lock — all three recorded |
| 3 | Every chart SEEN, method stated per family | SHIPPED | 10 rows, all `fresh-render-terminal`; no chart judged from a stale S15 PNG |
| 4 | Verdict takes a POSITION + weakest + top change | SHIPPED | IMPRESSIVE; weakest `area`; fix = bar x-labels |
| 5 | Merged vs in-flight reported SEPARATELY | SHIPPED | Part A / Part B in the review; verify binds to it |
| 6 | chitra's in-flight state not disturbed | SHIPPED | four-way fingerprint identical; exactly one pre-declared new path |
| 7 | Receipt reports a real cost, or records why not | SHIPPED | `$1.6103385` authoritative |
| 8 | Every gate that fired recorded, with whether it was right | SHIPPED | `gate-log/` — 4 captures, exit code line 1; the co-pilot block judged RIGHT-but-zero-value |
| 9 | Mandate exercised for real + measured in chitra + falsifiable "did it help" | SHIPPED | Vajra side READY w/ verified provenance; chitra side WARN captured verbatim; (a)(b)(c) above |
| 10 | verify + demo exit 0 with a printed check-class tally | SHIPPED | verify 28/28, demo all-pass, tally 9 exec / 15 byte-bound / 4 grep |
| 11 | Cold `fidelity-reviewer` ACCEPT, attested; judge ≠ advisor | see `sessions/session-134-review.md` | |
| 12 | What is still not fixed + did any of it help | SHIPPED | this summary, both sections above |
| 13 | Both design questions decided, loser's reason recorded | SHIPPED | `## Design` Q1 (read-only pass) + Q2 (D1/D2 split), each with its rejected option |
| 14 | Criterion 3 machine-checkable + stale-screenshot tooth + fixture | SHIPPED | manifest + 4-defect fixture 10/10 |
| 15 | Every gate invocation's raw stdout + exit code captured | SHIPPED | `gate-log/`, verify binds to it |

**The fakest green here, named plainly:** *criterion 3's manifest proves the bytes exist and hash
correctly — never that anyone looked at them with judgement.* A row saying
`fresh-render-terminal` with a valid sha is satisfied by a file that was rendered and never read.
The stale-screenshot tooth closes the *timing* dodge; nothing closes the *attention* dodge. The
honest mitigation is that the review quotes each render inline and reasons about specific pixels
(`JaFeMaApMaJuJuA`, the zig-zag `│`), which I independently confirmed against the renders myself —
but that is a human reading a document, not a gate.

**Second-fakest:** `K of 8` was **not** re-derived for chitra, because the read-only station
derivation for a repo mid-session with an occupied counter would report on someone else's work. The
station reading Q1's rejected option would have bought is genuinely **not** recovered.

---

## Three ranked next candidates

**S135 is already LOCKED by the founder** — `implementation-advisor` mandatory, as a call site on
`mandate`. A locked next session is a default, not a gag order, so: **nothing this dogfood found
outranks it, but this dogfood changed what it must contain.** S135 now inherits a named, recorded
hole and has to answer for it.

**A. `implementation-advisor` mandatory — AND fix the threshold units (the locked pick, amended).**
*Goal:* make the third role mandatory as a call site on `mandate`, and decide the brownfield
threshold: fix the units, or record in writing why a second mandatory role ships with a permanent
exemption for every adopter. *Why:* it is the founder's locked sequence, it is an hour's work, and
S134 handed it a concrete input it did not have before. *Risk:* the tidy half closes green while the
threshold decision gets deferred again — the ROADMAP already carries F2e/F2f/F2g unbuilt.

**B. F2f — the rubber-stamp detector.** *Goal:* automate the comparison this session did by hand —
handoff `captured:` vs the first code commit — and WARN when advice arrives after the work.
*Why:* still the highest-value open governance item, and S134 is direct evidence it is informative
rather than theoretical. *Risk:* a WARN nobody reads is decoration (S125); it needs to bind
somewhere that blocks.

**C. D2 — the fresh-scaffold first-contact paid dogfood.** *Goal:* a brand-new project, `vajra init`,
paid, driven to a **close** under two mandatory roles. *Why:* Q2 split the roadmap item and D2 is now
explicitly outstanding; it is the only instrument aimed at strangers, and 0 stars / 19 downloads has
not moved in 57+ days. *Risk:* it is the tenth-plus session with nothing a user can reach, and D2
measures readiness, not adoption.
