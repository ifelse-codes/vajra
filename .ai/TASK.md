# Current Task Pointer

**Thin pointer. Real session briefs live under `prompts/`.**

## Session 144 — the chitra FULL-LOOP dogfood (upgrade + govern a build to close) — COMPLETE

- Brief: `prompts/144-task-chitra-fullloop-dogfood.md`. **ACCEPT** (cold `fidelity-reviewer`, **6 of 7
  SHIPPED · 1 PARTIAL · 0 NOT-BUILT**), attested (see review). Reports: `sessions/session-144-summary.md`
  + `sessions/session-144-review.md`. **PAID: `$11.742472` authoritative + 875,548 RAW subagent tokens.**
- **Proven on a REAL brownfield adopter (chitra):** the installed binary upgraded 10 roles + 6 hooks + the
  boundaryless constitution under one command (first contact `16 drifted, 1 needs-boundary` → one migration
  → repeat sync `0 churn`), header preserved byte-for-byte. A chitra build (`horizontalBar` lock) governed
  by chitra's own fleet+hooks to a GREEN `verify-closeout.sh 19` (13/13 incl. `required-crew PASS` — tech-lead
  FIRST, 4 required, 4 handoffs). chitra undisturbed four ways.
- **🔴 Two findings for the follow-up:** `--sync-fleet` doesn't propagate `verify-closeout.sh`; the gate
  hardcodes `BIN="target/release/vajra"`. Worked around by a disclosed manual patch; follow-up spawned.
- **Founder:** deferred the `horizontalBar` textured-vs-solid aesthetic to its own chitra design session
  (see memory `chitra-bar-family-textured-fill`). **Next GT: S145 (mandatory NO-CODE).**

## Session 138 — THE REAL DOGFOOD: `vajra claude` run from INSIDE chitra — COMPLETE

- Brief: `prompts/138-task-real-dogfood-inside-chitra.md`. **ACCEPT** (cold `fidelity-reviewer`,
  **4 of 5 SHIPPED · 1 PARTIAL**), attested `840e64d9…`. The S137 correction shipped: the heatmap lock
  was a **native chitra session** governed from the inside, not a Vajra chat reaching across the fence.
- **Vajra works as chitra's resident manager, run from inside** — a monitored headless `vajra claude -p`
  with cwd=chitra fired chitra's SessionStart boot, dispatched chitra's **tech-lead FIRST**
  (unprompted), **blocked the first commit (copilot-loader, exit 2)** until STATE was surfaced, gated
  commits on the launch marker, and dispatched a fidelity-reviewer. `heatmap()` locked (rainbow →
  grey ramp + one accent `#8B7CF6` once on the peak cell + footer echo); founder signed off on the
  render. **$2.988 authoritative** + 237,584 RAW subagent tokens. chitra undisturbed four ways
  (session-16 restored byte-identical, tree `1c276700`). `verify-session-138.sh` **10/10**.
- **The one PARTIAL + the REAL finding (corrected post-close, S138B):** criterion 4 ran headless not
  interactive (founder redirect → hook gates proven, not the approval flow). And — found when the
  founder pushed — the tech-lead marked **4 roles required**; the main session ran **1**, did the rest
  itself, and self-certified. Running it **end to end** proved the gap is ARCHITECTURAL: it closed
  12/12 green + merged to chitra main (PR #20) with **nothing** checking the crew (the binding lives
  only in `--advance`, never in the close). (My first write-up wrongly blamed the design-advisor, which
  the tech-lead correctly deferred.) Reports: `sessions/session-138-summary.md` +
  `sessions/session-138-review.md`. **Next GT: S140.**

## Session 139 — make "required" bind at CLOSE — COMPLETE

- Brief: `prompts/139-task-required-crew-at-close.md`. **ACCEPT** (cold `fidelity-reviewer`, **5 of 5
  SHIPPED**), attested `5631e7a1…`. Reports: `sessions/session-139-summary.md` +
  `sessions/session-139-review.md`. **CODE** (shell-gate wiring + fixture + scripts, 0 Rust).
- **Shipped:** `check_required_crew` in `scripts/verify-closeout.sh` runs the real
  `vajra next --check-crew N` and BINDS — a session cannot close green with the tech-lead's handoff
  missing or a `required` role's handoff absent (the S138B hole, closed for the close path). Header
  guard against a `run_dump` exit-0 false green; fails closed on a missing binary; honors
  `VAJRA_CLOSEOUT_WAIVER`; propagates to adopters via `include_str!`. All three binary-backed close
  checks made `set -e`-safe (a blocking verdict aborted the run before printing its FAIL reason).
- **Bound on S139 itself:** tech-lead dispatched FIRST marked 3 roles `required` (design-advisor ·
  implementation-advisor · fidelity-reviewer); all produced provenance-verified handoffs; S139's own
  `verify-closeout.sh` passes the new gate. Fixture 8/8 (deterministic), verify 7/7. Cold review named
  the P2/P3 needle as the fakest green — **fixed in-session** (`3a9852e`).
- **Disclosed remainder:** reviewer-independence self-certification (S138B) stays OPEN — ranked
  candidate 1 for S141.

## Session 140 — mandatory NO-CODE Ground Truth (`140 % 5 == 0`) — COMPLETE

- **GT session.** All 12 required audits run live. **Lead-lens verdict: 🟡 PARTIAL PASS.** Report:
  `sessions/session-140-ground-truth.md`. NO CODE, NO PR — closeout on `session-140-closeout`.
- **Discipline 🟢** (stranger 21/21 · scaffold-drift 17/17 · fmt clean · stations 4→6→8/8). **Direction
  🟡 inward** — 0 stars / 19 downloads flat / 0 issues; the machinery deepens while nobody outside runs
  it. **Headline meta-finding (audit 10):** `--dogfood-age` is blind to dogfoods run INSIDE the target
  repo, so it reports S124 forever — LOW priority per founder ("makes an audit lie, not the product
  worse"). **Founder completeness order:** fresh-user/upgrade first (S141) → chitra dogfoods → prove-then-
  cut-cost (after S145) → gauge someday. See `[[vajra-s140-completeness-priorities]]`.

## Session 141 — CODE: best install + upgrade-in-place — COMPLETE

- Brief: `prompts/141-task-best-install-upgrade.md`. **ACCEPT** (cold `fidelity-reviewer`, 5 of 6 SHIPPED
  at review → 6/6 at close), attested `69f94543…`. Reports: `sessions/session-141-summary.md` +
  `sessions/session-141-review.md`.
- **Shipped:** every fleet role render carries a recorded `vajra-render-sha:` stamp (sha256 of the render
  minus the stamp line, written at render time); `FleetFileState` gains the fourth, now-DERIVABLE state
  `StaleRender`; `vajra init --sync-fleet` auto-upgrades an untouched old render WITHOUT
  `--overwrite-drifted` (reported by name, old→new) and still refuses a user edit / unstamped file.
  Closes the S136 "stale-vs-edited not derivable" floor by RECORDING the provenance (DECISION-007 S141
  addendum), not inferring it. `verify-session-141.sh` 10/10 · `fixture-141` 8/8 · 457 lib tests.
- **Governance:** tech-lead FIRST bound the crew (design-advisor · qa-specialist · fidelity-reviewer
  required; six deferred-budget); all three required handoffs recorded; 3 design-advisor `obeyed:`
  dispositions judged `implemented:` by the fidelity-reviewer. Close passes `check_required_crew`.
- **Disclosed:** legacy unstamped files stay `Drifted` on first contact (first upgrade needs one
  `--overwrite-drifted`; smoothness is going-forward); content hash not a keyed signature; "CC ignores an
  unknown frontmatter key" proven by placement, not a live dispatch; non-fleet scaffold files add-only.

## Session 142 — CODE: complete the upgrade loop for the pure-render scaffold files (hooks) — COMPLETE

- Brief: `prompts/142-task-scaffold-upgrade.md`. **ACCEPT** (cold `fidelity-reviewer`, 6 of 6 SHIPPED at
  close), all 9 `obeyed:` dispositions `implemented:`. Reports: `sessions/session-142-summary.md` +
  `sessions/session-142-review.md`.
- **Shipped:** the S141 render stamp generalises beyond frontmatter via `StampSyntax` (one code path,
  frontmatter byte-identical); the SINGLE `vajra init --sync-fleet` widens to the shell hooks
  (`.ai/hooks/hook-*.sh`, shell-comment stamp) — scaffolded stamped, four-state smooth upgrade, no 8th
  command. `verify-session-142.sh` 12/12 · `fixture-142` 9/9 · 461 lib tests · fmt+clippy clean.
- **Founder-confirmed scope:** hooks now; `.ai/AGENTS.md` (a filled template) DEFERRED to S143 (the
  fill-split); `CONSTRAINTS.yaml` user-owned. **Next GT: S145.**

## Session 143 — CODE: the constitution joins the smooth upgrade (split fill from governed body) — COMPLETE

- Brief: `prompts/143-task-constitution-upgrade.md`. **ACCEPT** (cold `fidelity-reviewer`, 6 of 6 SHIPPED at
  close), all 15 `obeyed:` dispositions `implemented:`, attested `173da680`. Reports:
  `sessions/session-143-summary.md` + `sessions/session-143-review.md`.
- **Shipped:** `.ai/AGENTS.md` splits into a user-owned FILLED header + a byte-identical GOVERNED body
  divided by `GOVERNED_BODY_SENTINEL`; the SINGLE `vajra init --sync-fleet` upgrades ONLY the body (a
  boundary target — `boundary: Option<&str>` + `body_region`), preserving the header VERBATIM, via the S142
  `MarkdownComment` stamp (no fourth path). Fifth state `NeedsBoundary` (a pre-S143 boundaryless
  constitution) refused even under `--overwrite-drifted`. `verify-session-143.sh` 13/13 · `fixture-143` 9/9
  · 469 lib tests · fmt+clippy clean. DECISION-007 S143 addendum. **The fresh-user/upgrade arc is COMPLETE**
  (roles S141 · hooks S142 · constitution S143); only `CONSTRAINTS.yaml` stays add-only, by design.

## Session 145 — mandatory NO-CODE Ground Truth — COMPLETE

- Brief: GT, no prompt file. **🟡 PARTIAL PASS.** Report: `sessions/session-145-ground-truth.md`.
  NO CODE · NO PR · closeout on `session-145-closeout`. **Founder pick: A.**
- **12 audits run live:** stranger 21/21 · scaffold-drift 17/17 · fmt clean · 469 tests ·
  3×8/8 CODE pipeline (S141-S143) · S144 2/8 expected (dogfood) · 0 stars · 0 forks.
- **🟢 Discipline.** No constraint violations S141-S144. All three mandatory roles dispatched
  each CODE session. Closeout gates passed before merge each session.
- **🟡 Direction.** Vision coherent, founder's order followed. F2f gap (advice-influence)
  and 0 external adoption remain open.
- **🔴 Cost.** $11.74/session (S144). Prove phase done; cut phase mandatory next.
- **Dogfood tool blind spot:** `--dogfood-age` reads S124 (this repo's last local receipt);
  S144 ran inside chitra. Known since S140, LOW priority.
- **Next: S146 — A: propagate close-gate to adopters.** Prompt:
  `prompts/146-task-closeout-propagation.md`. **Start in a FRESH chat.**

## NEXT: Session 144 — pending founder pick

- Three candidates in `sessions/session-143-summary.md`: **A (recommended)** the chitra FULL-LOOP dogfood
  (run `vajra claude` inside chitra; exercise S141+S142+S143 end to end on a real brownfield repo — the
  founder's #2 completeness priority now #1 is done); **B** prove the 5 quiet fleet roles give good advice
  (S140 open); **C** harden S143 (atomic constitution write + double-sentinel falsification). **Start in a
  FRESH chat** once picked. **Next GT: S145.**

## Session 137 — PAID DOGFOOD: chitra's `scatter` locked to the reference language — COMPLETE

- **ACCEPT** (cold `fidelity-reviewer`, **5 of 5 SHIPPED** after the in-session partial-close). The
  first time Vajra governed a real BUILD in an outside project (S134 was read-only). Code landed in
  chitra on `session-17-scatter-lock` (3 commits); this Vajra session is the wrapper.
- `scatter()` joins the locked family: dashed frame · eyebrow · `+`/`│` guide · grey ramp · ONE
  accent on the primary series' max-y point (single braille cell) · `n·x-range·y-range·peak` footer,
  no Pearson r. Raw-RGB verified accent=1/other=0 both paths. Founder signed off (seen, not read).
- **Governance USED (first evidence):** tech-lead bound the crew (6 required/3 skip); advice CHANGED
  the work (S133 open question, first data). Receipt: authoritative $ = honest NULL (S77 interactive),
  RAW subagent tokens 486,695 (new-tokens figure understated ~4.3×). chitra undisturbed four ways.
- **CORRECTED (founder, post-close):** this was NOT the real dogfood — it ran INSIDE the Vajra repo
  and reached into chitra from the outside, instead of `vajra claude` INSIDE chitra. The cross-repo
  "blind spot" is an ARTIFACT of the wrong setup, NOT a Vajra failure. **S138 = RUN THE REAL DOGFOOD:
  `vajra claude` inside chitra.**
- `verify-session-137.sh` **10/10** (6 EXEC · 3 STRUCT · 1 BEHAV), runs chitra's own 14 tests LIVE.
  Reports: `sessions/session-137-summary.md` + `sessions/session-137-review.md`. **Next GT: S140.**

## Session 136 — `vajra init --sync-fleet`, and the fleet made REAL in chitra — COMPLETE

- **ACCEPT** (cold `fidelity-reviewer`, **6 of 9 SHIPPED · 3 PARTIAL · 0 NOT-BUILT**). Ships the
  first UPGRADE path Vajra has ever had, as a FLAG on an existing command — the seven-command ceiling
  is untouched.
- **The headline finding was not the one the prompt predicted.** chitra's four *present* role files
  were **stale renders**, each missing the protocol block that teaches a role to emit the `rec N —`
  lines the Advice and Obedience gates parse. **Its installed roles could not have produced parseable
  advice.** Structural cause: **`skip-if-present` CAN ADD; it can never UPDATE.**
- **Proven live in chitra:** 10 of 10 byte-identical · `--check-crew 16` **exits 1** naming the
  tech-lead (the S135 no-threshold rule in a real brownfield project, 117 sessions below the old
  threshold) · undisturbed four ways outside ten pre-declared paths · **nothing committed there**.
- **The limit shipped AS the answer:** Vajra cannot tell a stale render from a user's edit. Three
  `FleetFileState` variants because only three are derivable; a git-blame/timestamp classifier was
  rejected as invented provenance.
- **The independent judge BLOCKED the close TWICE and was right both times** — three `obeyed:`
  dispositions cited shas for claims about how a subagent was *briefed* (decorative, corrected to
  `deferred:`), and the command-ceiling "fix" merely parsed another hand-typed string in `main.rs`
  (the hole MOVED, closed by check 12 reading the real dispatch table).
- **The cold review named a fakest green ahead of the builder's own:** `canonical_roles()` derived
  the roster from the product's own output, so a typo'd or swapped role NAME would have been
  re-checked against itself. Closed by `CRITERION_ROLES`.
- Live: `verify-session-136.sh` **12/12** (11 exec, 1 struct), `demo-session-136.sh` 4/4 markers,
  454 lib tests (8 new), **8 falsifiability probes — two found real holes in this session's own
  checks**. **731,943 raw subagent tokens / 3 dispatches, 5.7× less than S135.**
- Reports: `sessions/session-136-summary.md`, `sessions/session-136-review.md`.

**⚠ ONE THING WAITING ON THE FOUNDER:** chitra's ten role files are UNCOMMITTED. Four were refreshed,
overriding a guardrail. Undo: `git -C /Users/suman/playground/chitra checkout -- .claude/agents`.

**Next: Session 137 — the PAID scatter dogfood**, drafted and now unblocked
(`prompts/137-task-chitra-scatter-lock-dogfood.md`). Candidates 2 and 3 are recorded in
`.ai/SESSION-BOOT.md` and the S136 summary. **Next GT: S140.**

## Session 135 — the `tech-lead` + the binding `--check-crew` gate — COMPLETE

- **ACCEPT** (cold `fidelity-reviewer`, two passes; pass 2 **11/12 SHIPPED · 1 PARTIAL**), attested
  `d538f522…`. The tenth role decides which of the nine specialists a task needs and its verdict
  BINDS. The S133 genericity falsification test HELD — **0 lines added to the shared mandate ladder**.
- **Headline finding: the bootstrapping wall** (a new native-subagent role is normally not
  dispatchable in the session that creates it).
- **Its disclosed gap is now CLOSED:** the `tech-lead` was a Vajra-only feature until S136 brought
  chitra to the full roster.

## Session 134 — PAID DOGFOOD (the mudra chart review in chitra) — COMPLETE

- **Goal achieved.** One real paid session ran in `/Users/suman/playground/chitra` through
  `vajra claude` — **`$1.6103385` authoritative**, 25 turns — reviewing every mudra-locked chart by
  **rendering and looking at each one**, and reported both verdicts the founder was owed.
- **Design verdict: IMPRESSIVE**, with two cheap blemishes. Verified at raw-RGB level: one accent
  hue spent exactly once, the literal documented grey ramp everywhere else, across four unrelated
  geometries. Weakest chart `area`; highest-impact fix = un-crush the bar x-axis (`JaFeMaApMaJuJuA`).
  Full deck + review in chitra at `sessions/mudra-chart-review-2026-08-26.md`.
- **The finding this repo could not manufacture — the BROWNFIELD THRESHOLD HOLE.** chitra's session
  16 is actively locking chart families to a design language and the S133 mandate returns
  `verdict: READY`, `handoff: (none)` — it sits below the migration threshold of 133. The threshold
  counts the wrong units. **DECISION-007 S134 addendum**, three fixes named, none picked (n=1).
- **Worse: `--stations 16` reads `0 of 8`** at `maturity: L3`. The governance is installed and unused.
- **The mandate also paid for itself.** Dispatched FIRST; 22 recs; found the brief factually wrong in
  **seven** places (including a locked chart family the brief omitted) before a paid minute was spent.
- **chitra undisturbed, proved four ways** — HEAD, index hash, stash list, branch identical; exactly
  one pre-declared new path.
- **Evidence:** verify **29/29**, demo all-pass, fixture **10/10**. Three dispatches, three different
  roles: design-advisor → fidelity-reviewer (**ACCEPT**) → implementation-advisor as JUDGE of all 34
  `obeyed:` claims (32 implemented, 2 mismatch, plus a fixture bug the cold pass missed — all fixed).
- Reports: `sessions/session-134-summary.md`, `sessions/session-134-review.md`.

**Next: Session 135 — the `tech-lead`.** Prompt: `prompts/135-task-tech-lead-mandatory.md`.
**REPLACES the previously locked S135** (`implementation-advisor` mandatory) — founder's decision in
chat at this closeout, after S134 showed the harness is real here and decorative everywhere else.

**The evidence that forced it.** S134 counted every dispatch in 134 sessions: the three GATED roles
account for 15, the six ungated ones for **9 between them, ever**. A role is used exactly as often
as a gate forces it. And chitra — the one real outside project — has 0 dispatches, 4 of 9 role
files, 0 of 8 stations.

**What S135 builds:** `tech-lead`, the tenth role and the first that is not a specialist. It is the
FIRST and MANDATORY dispatch of every session; it records for each of the nine specialists whether
this task needs it, why, and what it may spend; **and its verdict BINDS** — a role it marks required
must produce a real governed handoff or the session cannot close. `implementation-advisor` therefore
becomes mandatory automatically, which is why the old S135 is replaced rather than delayed.

**Phase 1 has NO off switch, deliberately.** Every role is `required`, always. Six of the nine have
been dispatched twice or fewer in 134 sessions — nobody knows how they behave, and you cannot tune
what you have never observed. Phase 2 grants the discretion, only after the observation sessions.

**The budget is an INSTRUCTION, not a fence** (founder, same conversation). Vajra cannot hard-stop a
dispatch and will not pretend to: the role is told its allowance and trusted to work within it, and
`--crew-cost` reports actual against allowance to LEARN, never to block. An overrun is a finding,
usually meaning the budget was wrong.

**chitra gets Vajra's scaffold upgraded to all ten roles in the same session** — otherwise this is a
Vajra-only feature again, which is the exact thing the founder called out.

**New chat.**

## Always-True Reminders

- **A session that BUILDS a gate must make that gate BIND ON ITSELF before it closes (S134).**
  Not on future sessions — on this one. This repo's oldest and most-repeated failure is shipping
  machinery nobody runs: *"a role no gate consumes is decoration"* (S125), *"a registered gate
  nobody executes is not a gate"* (S129). If the only proof a gate works is a test, it is not yet
  in use. Make the closing session pass through its own new gate.
- **Budget every subagent dispatch TIGHT: a narrow brief and NAMED FILES, never "read the repo"
  (S134).** Of S134's 19,192,697 raw subagent tokens, **17.5M were CACHE READS** — the cost of a
  subagent re-reading a large accumulated context. Three broad dispatches hit the account's monthly
  limit. A role given one question and three named files costs a fraction of one told to read
  everything. This is the difference between a fleet that is affordable and one that is not.
- **If a dispatch DIES mid-flight — a spend limit, an API error — record the result as INCOMPLETE
  (S134, live).** Never let the builder's confidence upgrade an unjudged item to a pass. S134's
  judge died on a monthly spend limit while re-grading two `mismatch:` verdicts that had since been
  fixed; those verdicts were left standing as `deferred:` and explicitly marked UNJUDGED rather than
  self-certified. **A fix the builder verified is not a fix an independent role confirmed.**
- **Report subagent cost as the RAW token total, never a new-tokens-only figure (S134).** S134
  published `421,739` when the truth was `19,192,697` — wrong by ~45×, because the first figure
  silently dropped cache reads. **No instrument in this repo caught it**; it surfaced by hand.
  Derive it from `~/.claude/projects/*/*/subagents/agent-<id>.jsonl`, the files `vajra meter`
  already folds.
- **A dogfood's most valuable finding is the one the repo could not have written itself (S134).**
  Nine sessions of machinery, all exercised against fixtures this repo wrote. The first time the
  S133 mandate met a real outside project it returned READY on the exact session it exists for.
- **A migration threshold measured in the governed project's session numbers is wrong for every
  brownfield adopter (S134).** For this repo it is a closing window; for a project that adopts at
  its session 40 it is a permanent exemption with nothing to end it.
- **A gate suite can be fully installed and score `0 of 8` (S134).** chitra runs at `maturity: L3`
  and passes zero stations. Installed ≠ used; surfacing calls exit 0 by design and bind only at
  `--advance` and `verify-closeout.sh`, so nobody sees the zero unless they go and ask.
- **A check that greps a literal the agent typed, in a file the agent wrote, is not attestation
  (S134).** `c_binary_recorded` was the fakest green of the session and the builder did not spot it.
  An unexpanded `$(...)` in a "captured" artifact is the tell that it was hand-written.
- **A check that evaluates zero rows is indistinguishable from a deleted check (S134).** Print the
  row count, or declare the tooth dormant in the comment.
- **A fixture's positive control must assert a clean exit 0, not just one green line (S134).**
  S134's sandbox omitted a file the verify script needed, so verify failed on every fixture run and
  the `exit != 0` half of each defect assertion proved nothing. The judge caught it; the cold
  fidelity pass did not.
- **A forward reference is not a number (S134).** The summary said "see review", the review said
  "see summary", and the third figure existed nowhere.
- **Three consecutive judges have had no shell (S133, S134 ×2).** Every "verify N/N" claim in those
  sessions was executed only by the builder. The independent pass reads scripts; it does not run them.
- **When a pre-commitment looks like it came true, check whether it was sidestepped (S134).** The
  advisor predicted an honest-null receipt for an interactive run; the run was made headless, and
  reporting the real cost as the prediction failing would have been spin.

- Load order: `.ai/AGENTS.md` + `.ai/CONSTRAINTS.yaml#load_order`.
- Branch: `session-NN-<slug>`. Never work on `main`.
- Approval tokens: `approved`, `lgtm`, `ship it`, `yes commit`, `go ahead and commit`, `go ahead`.
- **Commits are ENFORCED (S93):** on a session branch, supply the un-forgeable marker —
  `VAJRA_ALLOW_COMMIT=NN git commit …`. Max 3 files per commit, hook-enforced.
- **A GT session (`NN % 5 == 0`) cannot commit on its own branch** — closeout commits ride a
  `session-NN-closeout` branch (the exempt suffix).
- **Attest LAST (S69), hashing the LIVE PROMPT (S131):** recompute `--inputs-sha NN` after every
  edit to the prompt, and run the full `verify-closeout.sh` on the branch BEFORE merging (S83).
- **The judge may not be the graded advisor's role (S132).** S133 used `implementation-advisor` to
  judge both `design-advisor` and `fidelity-reviewer`; when S134 makes `implementation-advisor`
  mandatory, the judge for ITS advice must be a third role again.
- **Land every commit an `obeyed:` will cite BEFORE the judging dispatch (S132)** — one pass then
  grades them all and no regress restarts.
- **A wrapped prose line that BEGINS with a code fence hides every `rec N` after it (S133).** It
  happened to S133's own cold-review handoff; the Advice gate reported ten ORPHAN answers and was
  right. When a brief discusses fence syntax, never let a line start with the fence characters.
- **A guard bound to a spelling fires on prose ABOUT the spelling (S132, hit again at S133).** The
  session-guard blocked a `python3` heredoc that merely quoted the advance command inside
  backticks — `SCAN` strips quoted spans, not backticked ones. Write such docs with a dedicated
  file-write tool, or use a placeholder and `sed` it afterwards.
- **A skip must cost a sentence (S133).** `<role-name>: skipped — <reason>` in the prompt. There is
  no environment variable for the Mandate gate, on purpose — the escape has to leave a trace.
- **A worktree under `$TMPDIR` is pathologically slow to build here (S132):** ~12s inside the repo's
  gitignored `target/`, >10 minutes under `$TMPDIR`. `vajra next --stations` costs ~30s per call
  and >10 minutes inside ANY worktree. Keep the suite under `verify.timeout_secs` (600).
- **The closing advance blocks on stdin** — non-interactive callers need `</dev/null`.
- **An unrecognised `vajra next` flag falls through to `run_dump()` and exits 0 (S132)** — require
  the gate's own header string, never just the exit code.
- **A recorded claim and a verified one are not the same thing, and this repo keeps re-discovering
  it one layer down.** S127: an `obeyed:` sha resolves ≠ the commit does what it claims (closed at
  S132). S131: a real dispatch occurred ≠ its findings are what got ingested (open, F2). S132: an
  independent judge graded it ≠ the judge read the diff (open). **S133: a role was dispatched ≠ its
  advice reached the design (open, F2f).**
- **`cargo test` accepts exactly ONE `TESTNAME` filter (S131).**
- **`grep -F` with a MULTI-LINE pattern is an alternation of its LINES, not one literal (S133).**
- **Dispatch evidence is UNSIGNED and hand-fabricable by anyone with shell access (S131).**
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)**; the overall verdict must
  be a bare `**Verdict:** ACCEPT` line.
- **A falsifiability fixture must fail for the RIGHT reason (S122), a probe must assert its own
  pattern matched (S127) including the positive control (S132), and a rename control is meaningless
  unless the unit tests bind to VALUES rather than to message text (S133).**
- **Never test the product only in the repo that builds it (S125).**
- **A role no gate consumes is decoration (S125); a registered gate nobody executes is not a gate
  (S129); a check that cannot evaluate FAILS (S69).**
- **Max 7 top-level commands.** S133 added none — `--check-design-handoff` rides `vajra next`.
- **Direction:** product = **provable agent governance** (`DECISION-001`). The fleet stands at nine
  roles with **TWO mandatory** — `fidelity-reviewer` (S131, grades finished work) and
  `design-advisor` (S133, must be consulted or the skip must cost a recorded sentence).
