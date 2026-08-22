# Session 128 — CODE: first contact works — fix what a stranger actually hits

> **Status:** APPROVED — founder, 2026-08-22, opening S128: *"start session 128, all approved."*
>
> **Founder pick at the S127 closeout: candidate C.** The reasoning, in their words, is worth
> carrying: a mechanical guardrail is the wrong tool for an agent that reads advice and then
> reports it did something it did not — *"we can and should not build a mechanical guardrail to
> it."* Candidate B was rejected on that ground and the rejection is correct: a model that will
> write "did it" when it didn't will write whatever the checker wants. Candidate A was set aside
> because it extends a team **nobody outside this repo can use yet**. **C is the only option where
> a stranger notices the difference.**
>
> **This UNPARKS part of the S125 reboot backlog** (parked 2026-08-20 pending "the fleet is done AND
> working"). The founder unparked it at the S127 closeout. The rest of that backlog stays parked.
>
> **Founder directive in force (S118):** `README.md` / `VISION.md` claims are the **target spec**,
> not a status report. Do NOT soften them. **No release** until reality meets them.

## Type

**CODE. Max 2 assumptions · 2 retries · 1 story · ~2h · new chat.** One story: *a fresh
`vajra init` repo is not broken on arrival.* Commits need the un-forgeable marker —
`VAJRA_ALLOW_COMMIT=128 git commit …`.

## Why this session

Vajra has been public for 57 days. **0 stars · 0 forks · 0 issues · 0 external contributors ·
19 downloads.** The last change a new user could reach was **S108, 2026-08-01** — 19 sessions ago.

Every one of the defects below was **re-confirmed live at the S127 closeout, in an empty directory**,
using the release binary — not copied from the S125 audit:

| What a stranger does | What happens today |
|---|---|
| `vajra --version` | prints the help banner, **exit 0**. There is no version flag at all. |
| `vajra chek` (a typo) | prints the help banner, **exit 0**. So `vajra chek && deploy` **runs deploy.** |
| `vajra check` on a fresh init | **9/11, 2 FAILED** — one is `vajra.varta missing`, a file `init` never creates. The product fails its own health check on first run. |
| `bash scripts/verify-closeout.sh` | **crashes**: `line 83: summaries[@]: unbound variable` — `set -u` + an empty glob on bash 3.2, the macOS default shell. The L4 fail-closed layer is broken on first contact. |

**These hid for 125 sessions because no audit ever ran `vajra init` in an empty directory** (S125's
own finding, and S127 is the third session in a row to prove the lesson by needing it). That is why
deliverable 5 is not optional garnish — it is the thing that stops this class recurring.

## Goal

Make the first ten minutes with Vajra work: a version flag that exists, a front door that fails
CLOSED on a typo, a health check that is honest on a fresh repo, and a closeout script that does
not crash on the default macOS shell — each proven by running the real binary **in an empty
directory**, and each protected by a check that would have caught it.

## Deliverables

- `vajra --version` / `-V` printing the crate version, exit 0. (**Not** an 8th subcommand — a flag.)
- An unknown subcommand exits **non-zero** with a message naming the unknown word, so
  `vajra <typo> && <anything>` cannot run `<anything>`.
- `scripts/verify-closeout.sh` runs to completion on a fresh `vajra init` repo under `bash 3.2`
  with `set -u`. It may report RED; it may not CRASH.
- `vajra check` on a fresh `vajra init` repo reports only failures that are **true and actionable**.
  The `vajra.varta missing` failure is either fixed (init creates it) or retired (check stops
  demanding a file init never makes) — decide in `## Design` and record which and why.
- **A `stranger_check`**: an execute-based check that scaffolds into a REAL empty directory and
  asserts first contact works. Added to `CONSTRAINTS.yaml#ground_truth.required_audits` so every
  future ground-truth session must run it.
- `scripts/verify-session-128.sh` + `scripts/demo-session-128.sh`, both exit 0, with the
  check-class tally.
- `sessions/session-128-summary.md` + exactly 3 ranked next candidates.

## Acceptance (testable, EARS-style)

1. **WHEN** `vajra --version` is run **THEN** it prints the version from `Cargo.toml` and exits 0 —
   asserted on the real binary, and the version is READ from the crate, never typed into a string.
2. **WHEN** any unknown subcommand is run **THEN** the process exits **non-zero** and the message
   names the unrecognised word. **Proven by the shell semantics that matter:**
   `vajra <typo> && echo RAN` must NOT print `RAN`.
3. **WHEN** `vajra --help` or `vajra` with no arguments is run **THEN** it still exits 0 — asking
   for help is not an error, and criterion 2 must not break it.
4. **WHEN** `scripts/verify-closeout.sh` runs in a directory freshly created by `vajra init`
   **THEN** it completes and prints its summary, with **no** `unbound variable` and no shell abort
   — asserted under `bash 3.2` semantics (`set -u` + empty glob), not only under the author's bash.
5. **WHEN** `vajra check` runs in a directory freshly created by `vajra init` **THEN** every
   reported FAIL is one a new user can act on, and `vajra.varta missing` is no longer among them.
6. **WHEN** the `stranger_check` runs **THEN** it creates a real empty directory, runs the real
   `vajra init` there, and asserts criteria 1–5 end-to-end — **it must fail if any of them
   regresses**, proven by planting each regression in turn.
7. `CONSTRAINTS.yaml#ground_truth.required_audits` contains `stranger_check`, and its question list
   says plainly what it is for: *every instrument in this repo measures Vajra governing itself.*
8. **Traced, not asserted:** `K of 8` unchanged in derivation and shape, the command count stays
   **7** (a version FLAG is not a command), and no gate's evidence contract moves.
9. A falsifiability fixture turns the suite RED **for the right reason** (S122) — reverting a fix,
   not renaming a message — **and every probe asserts its own pattern matched** (S127: two probes
   silently no-opped after `cargo fmt` reflowed the lines and printed GREEN).
10. `verify-session-128.sh` and `demo-session-128.sh` both exit 0 with a printed check-class tally,
    every check execute-based or honestly labelled.
11. Independent cold `fidelity-reviewer` verdict **ACCEPT**, attested.
12. **The summary states plainly what a stranger still gets wrong after this session** — in
    particular that the scaffolded constitution is still a hand-maintained fork (66 lines vs this
    repo's 183), which this session does **not** fix.

## Plan (ordered — cite the acceptance criteria each step covers)

1. **Reproduce all four in an empty directory first**, with the release binary, and record the exact
   output. No fix before its own red. `covers: 6`
2. **The front door:** unknown subcommand exits non-zero; `--help` and bare `vajra` still exit 0.
   `covers: 2, 3`
3. **`--version` / `-V`,** read from the crate, not typed. `covers: 1`
4. **The `set -u` empty-glob crash** in `verify-closeout.sh`. `covers: 4`
5. **The `vajra.varta` failure** — fix it or retire it, and record which in `## Design`. `covers: 5`
6. **The `stranger_check`**, driving a real empty directory end-to-end. `covers: 6`
7. **Wire it into `required_audits`** with its question list. `covers: 7`
8. **Prove nothing else moved** — `K of 8`, still 7 commands. `covers: 8`
9. **The falsifiability fixture:** plant each regression in turn, watch it go red, assert every
   probe pattern matched. `covers: 9`
10. **`scripts/verify-session-128.sh` + `scripts/demo-session-128.sh`.** `covers: 10`
11. **Independent cold `fidelity-reviewer` pass.** `covers: 11`
12. **Say in the summary what is still broken for a stranger.** `covers: 12`

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: `f83f9c67b74418432c2261a23d1788ffbe5a8500`
- step 2 — done: `8204ff4bd71bde71da441f78b70f058ab3ea53a2`
- step 3 — done: `7ca125f11ef344dab7b5c73d39ae422558decb7d`
- step 4 — done: `fcb22e908c39ca6c3954c9968dcb1e09fb63a7b9`
- step 5 — done: `9dba06dca7d8b4f7b0f7352b6bf049fd7ab0fff1`
- step 6 — done: `156b96f4b4a8269f74102e0af6d0663fe73dcfa3`
- step 7 — done: `73e9bae70a47035b759327e4fea280986decef09`
- step 8 — done: `3bf5b03064442b23ce25722cc345a2c19cfd20cc`
- step 9 — done: `93ca02425e8ca943a08eb6e9e425606f8d1a2a8a`
- step 10 — done: `7319e12e9540ef6686b4261026d21153268053b0`
- step 11 — done: `<sha>`
- step 12 — done: `<sha>`

> **Fill these with real landing shas before closeout.** S119, S122 and S124 each left `<sha>`
> placeholders and only an independent cold review caught it — never self-noticed. **And do not
> record a sha that does not contain the work: S127 did that three times.**

## Advice (every recommendation from this session's advisors, answered)

> The S127 contract. One line per recorded recommendation: `- <role> rec N — obeyed: <sha>` /
> `refused: <reason>` / `deferred: <path>`. `vajra next --check-advice 128` BLOCKS the close until
> every one is answered.
>
> **Read S127's residual before trusting this section's count.** Four `obeyed:` labels in its
> 51-answer ledger were factually wrong and passed the gate: three named a commit that could not
> contain the work, one relabelled a deliberate refusal as obedience. **A disposition certifies a
> typed word and a resolving sha, and nothing else.** The founder's standing position, recorded at
> the S127 closeout: **this is a truthfulness problem and a guardrail is the wrong tool for it.**
> If you did not do it, write `refused:` and say why — that is a pass by design, and it is the
> only honest option.

**No advisor was dispatched this session, and that is the honest record — not an empty
section waiting to be filled.** `vajra next --check-advice 128` returns `READY` by the
`NoRecommendations` path, which is the gate NAMING ITS OWN DODGE (`advice::DODGE`), not the gate
being satisfied. Written plainly because S127's lesson is that a clean advice ledger proves a word
was typed, nothing more.

- *(no recommendations recorded — no role was dispatched for S128)*

**Why none:** the four defects were already reproduced live in an empty directory at the S127
closeout and re-reproduced here as step 1 before any fix; the design fork was a two-option
decision the prompt already framed and the founder already scoped. Dispatching an advisor to
restate a settled scope would have produced a handoff whose only function was to make this
section longer. **The cost of that choice, stated:** nothing independent shaped the build before
the cold review at step 11 — the S128 build is one agent's judgement until that pass reads it.

## Design

- design-significant: **yes** — criterion 2 changes the CLI's failure posture from fail-OPEN to
  fail-CLOSED, which is a behaviour change for anyone already scripting `vajra`.
- **Spine record cited:** `docs/decisions/DECISION-001-governance-as-product.md` — governance
  that fails open at the front door is not governance. (path verified to exist at
  the S127 closeout. **The Architect gate checks that a cited record EXISTS, not that the design
  obeys it — a citation is not permission.**)
- **The fork, DECIDED: (b) — `check` stops demanding a file `init` never makes.**
  (Recorded here at the cold reviewer's rec 2: the reasoning shipped in `src/cli/check.rs:64-83`
  but deliverable 4 asked for it in `## Design`, and `## Design` is where the Architect gate and
  every future reader look.)
  - **Why not (a), `init` renders a `vajra.varta`:** the render is DERIVED and one-way. Scaffolding
    one plants an artifact that goes stale on the user's very next `.ai/` edit — trading one false
    red on day zero for a recurring one forever, and hand-maintaining a derived copy is the trap
    this repo already named.
  - **Why not the third option, leaving a new user red on arrival — rejected out loud:** a health
    check that is wrong on first run teaches strangers to ignore it, and an ignored check protects
    nothing. That is worse than having no check.
  - **What (b) does NOT do — it is not a weakening.** The guard keeps its teeth wherever drift can
    actually exist: `absent + tracked by git` FAILS (a committed render vanished), `present +
    different` FAILS (hand-edited or stale). Only `absent + untracked` — where nothing exists and
    so nothing can have drifted — became a labelled PASS. Both retained failures are driven live in
    `demo-session-128.sh` cases 9 and 10, precisely so "we relaxed a guard" cannot be asserted
    without evidence either way.
- **Scope discipline:** the scaffolded constitution being a hand-maintained fork (S125's F1,
  `include_str!`) is **deliberately NOT in this session.** It is the deeper problem and it is a
  whole story of its own. Say so in the summary; do not quietly widen into it.

## Non-goals (not built this session)

- **Not the constitution fork.** 66 lines vs 183 stays broken this session, stated plainly.
- **No 8th top-level command.** `--version` is a flag.
- Not the rest of the S125 reboot backlog — only the first-contact slice the founder unparked.
- Not a second consuming gate (S127 candidate A), not a stronger `obeyed:` check (candidate B —
  rejected on principle by the founder, and the rejection is recorded).
- No release, no crates.io action (founder directive, and `vajractl` is already burned at 0.1.0).

## Delta (vs ROADMAP — OpenSpec markers)

- **ADDED:** `vajra --version`; a fail-CLOSED front door; a `stranger_check` in the required GT
  audits.
- **MODIFIED:** `verify-closeout.sh` survives a fresh repo on bash 3.2; `vajra check` is honest on
  first run.
- **UNCHANGED:** the 8 stations, the 9 roles, the 7 commands, `K of 8`'s derivation, every gate's
  evidence contract — and the scaffolded constitution, which is still a fork.

## Guardrails

- **`VAJRA_ALLOW_COMMIT=128`** on every commit. Max 3 files per atomic commit. Never `--no-verify`.
- **Never test the product only in the repo that builds it (S125).** Every criterion here is
  asserted in an EMPTY directory against the release binary.
- **A check that cannot evaluate FAILS** (S69). **A fixture must fail for the RIGHT reason (S122),
  and a probe must assert its own pattern matched (S127).**
- **Do not widen.** Four bugs and one audit. If the constitution fork starts looking tempting, stop
  — it is the next session, and saying so is the deliverable.
- **Answer this session's own advisors in `## Advice`, honestly.** A `refused:` with a reason beats
  an `obeyed:` that is not true.
- **Attest LAST (S69):** recompute `Review-Inputs-SHA` strictly after the Execution shas land; two
  consecutive closeout runs with `--inputs-sha 128` must agree before embedding. **Run the full
  `verify-closeout.sh` on the branch BEFORE merging the PR (S83)** — merge-base collapses after.
