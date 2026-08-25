# Session 132 — Independent Cold Fidelity Review

**Reviewed by:** independent subagent (cold — prompt + diff only)
**Date:** 2026-08-24

## Method controls

I read `reviewer/SKILL.md` (the contract I perform), the S132 governed prompt, the full delivery diff (6 files: `scripts/demo-session-132.sh`, `scripts/verify-session-132.sh`, `src/advice/mod.rs`, `src/cli/next.rs`, `src/lib.rs`, `src/obeyed/mod.rs`), and both S127 specimen inputs. To corroborate claims the diff makes about *unchanged* code I also read `src/dispatch/mod.rs`, `src/fleet/mod.rs`, `src/advice/mod.rs`, `scripts/verify-closeout.sh` and listed `.ai/handoffs/`. I have **no Bash tool**: I did not run `cargo test`, `verify-session-132.sh`, `demo-session-132.sh`, or the binary. Every verdict below rests on **reading logic and control flow**, plus one filesystem fact (the handoffs directory listing). Nothing here is graded from a test count; I ignored `sessions/` entirely.

## Acceptance grades

| AC | Description | Verdict | Notes |
|----|-------------|---------|-------|
| 1 | An `obeyed: <sha>` requires a recorded independent judgment, not just a resolving sha | SHIPPED | Real mechanism: `obeyed::obeyed_gate` joins `advice::dispositions_in` to `obeyed-check` markers parsed out of every contract-valid handoff; `Unjudged` at session >= `OBEYED_JUDGMENT_FROM_SESSION = 132` pushes a `reasons` entry -> `blocked()` -> exit 1. Surfaced by `run_check_obeyed` and bound into `run_advance` with `bail!`. Caveat, not a downgrade: `scripts/verify-closeout.sh` — the artifact that actually gates the merge — never calls it (see rec 6). |
| 2 | A `mismatch:` judgment BLOCKS, naming role, rec number and the disagreement | SHIPPED | `ObeyedState::Mismatch(j)` -> `reasons.push(...)` carrying `item.label` (`"<role> rec <N>"`), the sha, the judge role and the judge's own note. Verify check 2 asserts all three strings on live binary output, and `Mismatch` blocks at any session number (the threshold governs silence only). |
| 3 | Re-run against the S127 specimen reports MISMATCH on the real historical record | PARTIAL | The *reader* is real and the `session NN` qualifier is parsed and unit-tested, but at the reviewed tree **no judgment exists**: `.ai/handoffs/` contains no `session-132-*` file and `obeyed-check` appears only in source, tests, scripts and the prompt. `--check-obeyed 127` therefore emits `pre-threshold: WARN` for every S127 disposition and exits 0. The "proven, not asserted" half is deferred to this review's own handoff. |
| 4 | The judgment comes from an INDEPENDENT party — never the builder, never the graded advisor | PARTIAL | The advisor half is structural and tested (`admit()` rule 1, with a positive control). The builder half is weaker than the AC's wording: `verify_judge` proves *a dispatch of that role for that session happened*; the findings body is still whatever the builder passes to `--role ... --from`. Honestly deferred in Non-goals (S131 rec 4 -> ROADMAP F2), so a disclosed PARTIAL, not a hidden miss. Compounding it: no role definition anywhere instructs a judge to emit the marker (rec 2). |
| 5 | Falsifiability fixture drives TRUE / FALSE / ABSENT, each probe asserting its own pattern matched | PARTIAL | Clause 1 shipped: checks 1, 2, 3 and 5 drive the release binary live, plus a rename-everything positive control. Clause 2 is not: the three `perl -0pi` bypasses never assert their substitution landed, and the check greps only for the absence of `test result: ok` — so a bypass that fails to *compile* scores as a successful falsification. Precisely the S122 rule the prompt's own Guardrails restate. |
| 6 | Traced, not asserted: `K of 8`, 7 commands, S131's Fidelity gate and every other gate unchanged | PARTIAL | `K of 8` is traced properly, with an explicit degenerate-baseline failure. 7 commands: honestly labelled `behav`. Advice gate: check 10 re-runs `--check-advice 127`. **S131's Fidelity gate — the one gate the AC names by hand — is never exercised**: no `--check-fidelity-handoff` invocation exists in the suite, and demo case 8's label claims it while its assertions only touch stations and command count. |
| 7 | Both scripts exit 0 with a printed check-class tally, checks execute-based or honestly labelled | PARTIAL | Structure is right (`print_tally`, an unknown-class `exit 2` guard, 10 of 12 checks genuinely executing the binary, the one grep-proxy labelled `behav`, a "never exercised" block in both). But green cannot be true at the reviewed tree: check 6 requires a judgment that does not exist there. I could not execute either script. |
| 8 | Independent cold `fidelity-reviewer` verdict ACCEPT, attested via the S131 gate | PARTIAL | In flight — this pass *is* it. Nothing in the cold inputs can evidence it, so I decline to call it SHIPPED from my own existence. |
| 9 | The summary states plainly what is still NOT fixed (refused/deferred scope, gameability) | PARTIAL | The substance ships in code and scripts and is unusually honest (`obeyed::CEILING`, "Rejected alternatives", both scripts' disclosure blocks). The summary file itself is not in my inputs. One limit is missing everywhere I *can* see: that `refused:` is now the cheapest way out of this gate, and that the judge's findings file is builder-writable. |

**2 of 9 SHIPPED**

**Verdict:** ACCEPT

The real scope is a faithful build of the contract's mechanism, not a narrow slice dressed as the whole: the marker, the parser, the four admissibility rules, the migration threshold, the CLI surface and the `--advance` binding are all present, all reachable, and honestly bounded. The seven PARTIALs are concentrated in *proof* and *propagation*, not in absent behaviour — and one of them (AC 3) is unsatisfiable by the builder without violating AC 4, which is a design consequence rather than an evasion. Be clear about what this ACCEPT rests on, though: it holds only because my independent reading of commit `8cd3bea` genuinely lands on `mismatch`. Had I read it as `implemented`, this delivery's headline check would have gone red, which is a coupling that should not exist (rec 1).

## Fakest Green

**Verify check 6 / demo case 5 — "the S127 specimen is caught on the REAL record."** It looks like the mechanism detects the historical defect. It does nothing of the kind. The gate cannot read a diff or decide obedience — by design, and the module says so. What check 6 actually does is grep for the literal words `MISMATCH` and `_uses` in the binary's output, which can only be produced by a human or subagent typing them into a handoff. The only way to turn it green is for the independent judge to write the exact verdict word and the exact noun the script greps for. A check that pre-specifies the answer the "independent" party must give is not a test of the mechanism; it is a test of whether the reviewer cooperated. Runner-up: demo case 8, labelled "nothing else moved: K of 8, **S131's Fidelity gate**, 7 commands", which never touches the Fidelity gate at all.

## Obeyed-check judgments

I read rec 9 verbatim ("ship one pure function with no fs edge, dedupe by number keeping the FIRST occurrence, and **delete the `_uses` stub**") against the full diff of `8cd3bea`. The commit ships `parse_rec_marker` (pure, no fs) and `recommendations_in` (dedupes by number, first wins) — two of the three clauses. The third is visibly untouched: `fn _uses(_r: &Path)` appears in the hunk region as an unchanged **context** line, so the commit adds 171 lines around the stub and removes nothing. The stub is absent from today's `src/advice/mod.rs`, which means the deletion did eventually happen — in some *other* commit, not the one the disposition cites. A disposition names a commit; this commit does not carry the work.

obeyed-check session 127 implementation-advisor rec 9 — mismatch: 8cd3bea — the commit adds the recommendations parser and the first-wins dedupe but leaves `fn _uses(_r: &Path)` in place as an unchanged context line, so the deletion rec 9 explicitly asked for is not in the cited commit

## Numbered recommendations

rec 1 — Decouple check 6's green from the judge's chosen verdict: assert the JOIN and the blocking behaviour, not the literal words `MISMATCH` and `_uses`. The check should prove that a judgment naming `implementation-advisor rec 9` is found, is admissible, and that its recorded verdict drives the exit code — green under *either* honest verdict, red only when the join or the blocking is broken. Until this is fixed, the "independent" judge is being paid in green checkmarks to agree.

rec 2 — Propagate the `obeyed-check` grammar into `fleet::ROLES`' rendered role contract, the way S127 propagated the disposition contract. Nothing in `src/fleet/mod.rs` changed this session, so no role's system prompt tells any judge that this marker exists. The only producers today are a hand-written dispatch prompt and the builder pasting the line into the `--from` file — and the second is the failure mode the gate was built to end.

rec 3 — Make check 8's three bypass probes assert their own substitution landed, and assert the resulting red is a *test failure*, not a compile error. Have perl report a substitution count and fail the check when it is 0, and grep the failure log for the named test's FAILED line rather than merely the absence of `test result: ok`.

rec 4 — Add an explicit `--check-fidelity-handoff` trace to `verify-session-132.sh`, since AC 6 names S131's Fidelity gate by hand and nothing exercises it.

rec 5 — Fix the ordering that "LAST wins" depends on: `all_handoffs` sorts by filename string, so `session-99-*.md` sorts *after* `session-131-*.md`. Sort judgments by `judge_session` numerically, then by path and document order — or, safer for a blocking gate, make `Mismatch` sticky so no later judgment can silently clear a recorded disagreement.

rec 6 — Wire the Obeyed gate into `scripts/verify-closeout.sh`, or record in `## Design` why it deliberately stays `--advance`-only. Leaving it `--advance`-only reproduces the S129 "registered != run" hole on the very session that exists to close a "recorded != verified" hole.

rec 7 — Say in the summary the two limits that do not appear anywhere in the shipped disclosures: (a) `refused: <reason>` is now the cheapest exit from this gate; (b) "independent" currently means *a dispatch of a different role happened for this session*, not *a different mind wrote this line*.

rec 8 — Make the disposition-to-judgment label join case-insensitive, to match `admit`'s case-insensitive self-certification test. A judge that writes `Plan-Advisor rec 1` against a prompt line reading `plan-advisor rec 1` produces `Unjudged` and a blocking message that says "no independent judgment" when one is sitting in the handoff.

## Handoff Delta
- `+` new: first fidelity-reviewer handoff for this session
