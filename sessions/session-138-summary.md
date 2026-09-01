# Session 138 — THE REAL DOGFOOD: `vajra claude` from INSIDE chitra — SUMMARY

**Goal achieved, with one criterion PARTIAL (cold review: ACCEPT, 4 of 5 SHIPPED).** For the first
time, Vajra governed a real BUILD **inside** an outside project as a native session — a `vajra claude`
run with cwd=chitra locked chitra's `heatmap` chart to the reference panel language, and chitra's own
hooks/gates demonstrably governed it. This Vajra session was the wrapper (prep + monitoring +
evidence); it never edited or committed inside chitra. The S137 mistake — a Vajra chat reaching across
the fence with plain git — was **not** repeated.

**Method, stated precisely (not overstated):** the build ran as a **wrapper-launched, headless
`vajra claude -p` subprocess with `--dangerously-skip-permissions`, and `VAJRA_ALLOW_COMMIT=18`
pre-set in the launch env** — the founder redirected the run mode from interactive to
"run-and-monitor-it-yourself" mid-session. So this proves the **hook gates** (copilot-loader blocked a
commit exit-2; commit-guard required the marker) governed a real native build — but it is NOT the
interactive, founder-at-the-keyboard run the prompt originally approved, and it does not exercise
Claude Code's permission-approval flow. "The way a user runs it" is therefore **unattended/CI-style,
not a human interactive session** — the honest next dogfood (candidate A).

## What happened

- The build ran as a **headless, monitored `vajra claude -p` subprocess with cwd=chitra**, on a fresh
  `session-18-heatmap-lock` branch off chitra `main`, launched with `VAJRA_ALLOW_COMMIT=18` (the
  founder-supplied launch marker — I drove it on the founder's explicit instruction to "run and
  monitor it yourself"). chitra governed its own session end-to-end.
- **The heatmap was locked**: the old 10-colour blue→orange→red rainbow (`HEAT_COLORS_DARK`) is gone;
  the intensity encoding is now the documented grey ramp `#ECECEF→#C6C6CE→#A4A4AE→#6A6A75`, with
  chitra's canonical accent `#8B7CF6` spent **once** on the peak cell (`███` at row 3, col 4) and
  echoed in the footer `peak (3,4)` label — the exact scatter-family contract. Dashed frame,
  `DENSITY` eyebrow, `+`/`│` guides, two rule separators, honest footer (`rows×cols · min..max ·
  peak`). 4 commits, 6 files, **zero stray files**, `.ai/` untouched, shared `types.ts`/`blocks.ts`
  untouched.
- **Founder signed off** on the rendered heatmap (seen, not read): *"this looks good and impressive."*

## Governance USED (the S138 headline — Vajra as chitra's resident manager)

The honest answer to *does Vajra work as the resident manager of a repo that isn't its own?* is **yes**:

- chitra's **SessionStart hook** booted chitra's own `.ai/AGENTS.md` + Darshan.
- chitra's **tech-lead mandate (S135)** dispatched the tech-lead **FIRST, unprompted** — chitra's own
  workflow enforced it.
- chitra's **copilot-loader hook BLOCKED the agent's first `git commit` (exit 2)** until it surfaced
  `.ai/STATE.md` — real enforcement, mid-build, inside chitra.
- chitra's **commit-guard** let commits through **only** via the launch marker `VAJRA_ALLOW_COMMIT=18`;
  the agent used a plain `git commit` (no inline prefix) and it passed because the marker was in the
  launch env, exactly as designed.
- a **fidelity-reviewer** was dispatched and hardened the falsifiability tests (commit `e2b6bb9`).
- scope held: **no push, no PR, no merge, no `.ai/` edits** — the agent stopped for the human sign-off.

**⚠ The design-advisor did NOT run (disclosed, the cold review's named fakest green).** Only two roles
were dispatched inside chitra — tech-lead (first, per the mandate) and fidelity-reviewer. chitra's
**design-advisor**, which the Architect gate mandates FIRST to *propose* the accent-cell rule and the
footer, was never dispatched. So the heatmap's visual design was authored by the headless build agent
and **rubber-stamped by the founder's sign-off** — it was not governed by the design role. The lock is
correct (criterion 1 verified independently), but "the fleet governed the design" is NOT true and must
not be implied. The design-governance mandate was silently skipped; this is recorded, not buried.

## Evidence

- **Authoritative cost: `$2.988433749999999`** (real `total_cost_usd` from the `-p` stream-json result
  event — the S78 path; NOT an honest null this time, because the run was headless stream-json). 45
  turns, ~8 min.
- **RAW subagent tokens: 237,584** across 2 dispatches (tech-lead 160,303 · fidelity-reviewer 77,281) —
  reported RAW (input+cache_creation+cache_read+output), never new-tokens-only (S134/S135 trap).
- Parent session usage: input 8,616 · cache-creation 72,814 · cache-read 2,124,779 · output 28,791.
- **chitra's 15 heatmap tests pass LIVE** (`pnpm --filter @chitra/core test -- heatmap`, run by me
  in-session — not self-certified): `15 passed (15)`.
- **Raw-RGB accent-once VERIFIED** (S134 method, independent of the unit tests): exactly ONE non-grey
  hue `#8B7CF6` on the committed locked preview, all 4 documented grey tones present.
- **chitra proven UNDISTURBED four ways:** session-16 WIP restored **byte-identical** (tracked-WIP
  tree `1c27670022b52acd800501d0473b26db56aff7a4`), HEAD unmoved (`462a27b`), the older kilo stash
  intact, only the intended `session-18-heatmap-lock` branch added. Every path pre-declared.
- `scripts/verify-session-138.sh` **10/10** (6 execute-based · 3 structural · 1 behavioral raw-RGB).

## Fidelity map (every prompt requirement → evidence)

| # | Acceptance criterion | Verdict | Evidence |
|---|---|---|---|
| 1 | heatmap carries the panel language; accent once + grey ramp, raw-RGB verified | **SHIPPED** | verify #6/#9; 15 tests live; render |
| 2 | chitra's own tests green + README `LOCKED: heatmap` block | **SHIPPED** | 15/15 live; verify #7; commit `22b34f9` |
| 3 | founder signs off on the rendered chart | **SHIPPED** | *"looks good and impressive"* |
| 4 | run the corrected way — inside chitra, **interactively**, hooks fired, fleet dispatched; authoritative $ + RAW tokens | **PARTIAL** | native-inside-chitra ✓ ($2.99, 237,584 RAW, hooks governed the build); BUT NOT interactive (headless `-p`, permissions bypassed, wrapper-driven — founder redirect), AND the mandated design-advisor did not run |
| 5 | session-16 + locked charts undisturbed (four ways); exactly the heatmap files changed | **SHIPPED** | byte-identical restore; verify #10 |

**Deliverables:** heatmap locked in chitra ✅ · founder verdict ✅ · resident-manager report (this file
+ review) ✅ · undisturbed proof ✅ · verify script + 3 candidates ✅. **4 of 5 SHIPPED · 1 PARTIAL**
(criterion 4: native + governed + costed, but not interactive and design-advisor absent). Cold
`fidelity-reviewer` **ACCEPT**.

## What I did NOT build / the fakest green

- **THE FAKEST GREEN (the cold review found it, ahead of the builder): the design-advisor never ran.**
  The Architect gate mandates chitra's design-advisor be dispatched FIRST to *propose* the design; it
  wasn't. The "Governance USED" section reads as "the fleet governed the build" while the specific
  design-governing role is absent — it would look identical if the mandate had been silently skipped,
  which is what happened. Corrected in this summary; recorded in the review. rec 2.
- **The run used `--dangerously-skip-permissions`.** A headless unattended run must — Claude Code has
  no approval channel without it. So this dogfood proves the **HOOK gates** (commit-guard required the
  marker; copilot-loader blocked a commit) but it does **not** exercise Claude Code's interactive
  permission-approval flow. "Run the way a user runs it" here means *unattended/CI-style*, not a human
  sitting at an interactive prompt. **This is the fakest green — named, not buried.** The
  human-interactive path is the honest next dogfood.
- **verify-session-138 does not re-execute chitra's vitest suite.** The 15/15 live run happened once,
  in-session, by me. The QA gate's re-run does a raw-RGB **behavioral** check on the committed locked
  preview (real, falsifiable) + structural checks — but not a live `pnpm test`, to avoid a slow/fragile
  cross-repo worktree (KNOWLEDGE: worktrees under `$TMPDIR` build in >10 min). Disclosed.
- Nothing merged in chitra; the heatmap lives on `session-18-heatmap-lock`, unmerged. PASS ≠ released.

## Next candidates (pick one; S140 is the next mandatory NO-CODE GT)

- **A (recommended) — prove the human-interactive path.** Run a real human-interactive `vajra claude`
  inside chitra (permission prompts, no `--dangerously-skip-permissions`) to close S138's fakest green:
  does the governance hold when a human approves each tool call? *Why:* it's the one thing this run
  didn't test, and it's literally "how a user runs it." *Risk:* interactive ⇒ honest-null cost (S77),
  and it needs the founder at the keyboard.
- **B — `vajra` opens the session.** The founder-flagged gap ("i should not do git checkout, vajra or
  claude should do it"): no command starts a session; the `session-NN-<slug>` branch is a raw
  `git checkout -b`. *Why:* user-facing, the founder hit it directly. *Risk:* the 7-command ceiling —
  must ride an existing command or justify an eighth.
- **C — close the cross-repo QA live-gate.** A worktree runner so verify re-executes a dogfood's real
  test suite live, retiring S138's second disclosed gap and the S137 live-test lesson for cross-repo
  work. *Why:* makes the QA gate genuinely re-prove outside builds. *Risk:* worktree+pnpm is slow and
  fragile here.

**Next GT: S140.** Independent cold review: `sessions/session-138-review.md`.
