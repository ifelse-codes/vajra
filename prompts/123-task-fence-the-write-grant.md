# Session 123 — CODE: fence the `Write`/`Edit` grant

> **Status:** APPROVED (founder blanket approval at the S122 close; option A of three).
> **Founder directive in force (S118):** `README.md` / `VISION.md` claims are the **target spec**.
> Do NOT soften them. No release until reality meets them.

## Type
CODE — one story, ≤3 files per atomic commit, ~2h cap, new chat.
Branch: `session-123-fence-the-write-grant`.

## Why this session

`qa-specialist` is the fleet's only executing role. It holds `Bash, Read, Write, Edit, Grep, Glob`
and its prompt tells it not to touch the product under test. On both live runs the working tree was
byte-identical before and after — **verified, not trusted.** But in the agent's own words at S121:
*"that constraint held because I chose to hold it, which is not a control."*

That is the last self-granted jurisdiction in the fleet. A role that can edit the code it is
judging can, in principle, repair a check and then report it green. Nothing structurally stops it.

**Founder decision at the S122 close:** the fence rides the **existing clean-room runner** (S119,
`src/gate_run.rs`) — a disposable `git worktree` checkout the QA role is pointed at instead of the
real tree. Narrowing the tool grant is kept only as a cheap second layer; a write-blocking hook is
rejected outright. Reasoning in plan step 3, residual risk in its own section below.

**Do not soften, and repeat wherever the QA role is described:** the S121 executor thesis — *an
executor cannot fake a pass* — is **UNPROVEN**, and `DECISION-007`'s S122 addendum retracts it.
Across two live runs the role found seven real defects and every one came from independent READING.
What is evidenced is INDEPENDENCE, not execution. **This session does not prove the thesis either.**
It removes one specific way the role could cheat; it does not establish that it cannot.

## Plan (ordered — cite the acceptance criteria each step covers)

1. **Clear this session's own debt first** (the S122 fakest green, cheap and certain). Two fixtures
   end on a "fail-closed" tooth that cannot fail: `read_only_guard_has_teeth` writes its
   `tools:`-less `mystery.md` into the directory that still holds the planted `Write` leak, and
   `execution_policy_guard_has_teeth` runs its fail-closed case against a copy still carrying
   planted drift 3. Both must be shown RED for the RIGHT reason — delete the fail-closed branch and
   the assertion must go green→red. `covers: 1`
2. **Bind the duplicated tally.** `print_tally()` and `tally_discloses_nesting()` are byte-duplicated
   across `verify-session-121.sh` and `verify-session-122.sh` with nothing binding them — S122
   fixed drift-by-copy for the execution policy and created it for the tally in the same diff.
   One source, or a check that fails when the copies diverge. `covers: 2`
3. **Test the assumption, then record the decision.** Two parts, in this order.
   **(a)** Nobody has ever verified that the harness ENFORCES a role's `tools:` line. The
   `qa-specialist`'s own S122 report named it: *"Nothing proves the runtime honours `tools:`."*
   Dispatch a throwaway role granted `Read, Grep, Glob` and have it attempt a `Write`. Record what
   actually happens. **If the grant is not enforced, narrowing it is worth zero** and that must be
   said out loud rather than assumed away.
   **(b)** Record the fence in a `DECISION-007` S123 addendum. **The mechanism is founder-picked at
   the S122 close: ride the EXISTING clean-room runner** (`src/gate_run.rs`, built S119 — `git
   worktree add --detach` materialises `HEAD` into a temp dir). The QA role runs against a
   disposable copy; the real tree is not the thing it is pointed at. Record BOTH rejected
   alternatives and why:
   - **Rejected — narrow the grant alone** (drop `Write`/`Edit`). The role needs `Bash` to run the
     suite, and anything that can run a command can write a file (`echo x > src/foo.rs`). A fence
     that only closes the tool path while leaving the command path open is theatre — the exact
     fake-green class S122 spent four review passes removing. **Kept as a cheap SECOND layer, never
     as the fence.**
   - **Rejected — a hook that blocks writes during a QA run.** It is the only option that requires
     GUESSING INTENT: the guard must know the write came from the subagent (unverified — see 3a),
     and to catch the command path it would have to parse shell for "is this a write?", which is
     unwinnable. A fence made of rules has to be right about everything; a fence made of walls only
     has to exist.
   `covers: 3`
4. **Build it.** Route the `qa-specialist` dispatch through the clean room, plus the cheap second
   layer (drop `Write`/`Edit` from the grant IF 3a shows the grant is enforced; if it is not, say so
   and do not pretend the layer exists). `covers: 4`
5. **`scripts/verify-session-123.sh` + `scripts/demo-session-123.sh`**, each classifying its own
   checks and disclosing nesting in the S122 shape. **The load-bearing fixture: a QA run that
   ATTEMPTS to modify the real tree must be shown NOT modifying it** — the write must land in the
   disposable copy, and the source repo's HEAD sha, `git ls-files -s` hash and
   `git status --porcelain` must be byte-identical before and after. A fence never seen to stop
   anything is not a fence. **And per S122: the fixture must fail for the RIGHT reason** — restore
   the subject to a known-clean state between assertions, or the tooth is glued on. `covers: 5`
6. **Dispatch `qa-specialist` by name against this session's own suite**, then a cold
   `fidelity-reviewer` pass by name; summary with the per-requirement fidelity map + the fakest
   green. `covers: 6`

## Acceptance criteria

1. Both S122 fixtures fail for the right reason, proven by removing the guarded branch and showing
   the assertion flip.
2. The tally implementation is one source across both suites, or divergence between the copies turns
   a check RED.
3. Whether the harness enforces a role's `tools:` line is MEASURED and recorded, not assumed; and
   the clean-room fence is recorded in a `DECISION-007` S123 addendum with BOTH rejected
   alternatives and the residual risk below stated plainly.
4. The QA role's dispatch runs against a disposable clean-room checkout, on the real path, not a
   flag nobody sets.
5. `verify-session-123.sh` exits 0 with its own tally; the fence is proven by a fixture in which a
   write is ATTEMPTED during a QA run and the source repo is shown byte-identical before and after
   — never by asserting the fence's own source text exists.
6. Cold `fidelity-reviewer` ACCEPT.

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>
- step 5 — done: <sha>
- step 6 — done: <sha>

**Record a real commit sha for every step.** Prose in place of a sha breaks `git cat-file` and goes
Coder-dark (the S119 defect S120 filed, hit again at S122 until it was corrected).

## Design
- design-significant: **yes** — step 3 picks between narrowing a recorded tool grant and extending
  the L3 hook surface. Either changes the fleet's security posture. `docs/decisions/DECISION-007-agent-fleet.md`
  is the spine record; the S123 addendum must exist before step 4 lands.

## Residual risk — state it in the addendum, do NOT soften it

**The clean room isolates the REPO, not the MACHINE.** The QA role still holds `Bash`, and the real
repo still exists on disk at a known absolute path. Nothing stops
`cd /path/to/real/repo && echo x > src/foo.rs`. What the clean room does is remove every *legitimate
reason* to touch the original and make any touch **detectable** — the source repo's HEAD sha, index
hash and porcelain are compared before and after, exactly as the S121 and S122 live runs did.

So the honest claim is **isolation by default plus tamper-evidence as the backstop** — the same
posture as the verdict ledger (`DECISION-004`), which is tamper-EVIDENT, not tamper-PROOF. **Do not
write "the QA role cannot modify the repo."** Write what is true: it is not pointed at the repo, and
if it reaches for it anyway, that is visible. Anything stronger needs OS-level sandboxing, which is
a different session and probably a different product.

## Non-goals (not built this session)

- **Proving the executor thesis.** Fencing removes one way to cheat; it does not establish that an
  executor cannot fake a pass. Never restate the S121 claim as measured.
- **Making the check-class label EARNED** — the four-times-disclosed fakest green (S64, S67, S121,
  S122). Standing backlog, still unpicked, still not this session.
- The `no-eighth-command` banner grep. Still hollow, still labelled honestly, still unfixed.
- A fifth fleet role, parallel dispatch, multi-stage orchestration.
- No 8th top-level command.

## Guardrails
- Max 2 assumptions, max 2 retries, 1 story, ≤3 files/commit, ~2h cap.
- Approval token required before any commit (`VAJRA_ALLOW_COMMIT=123 git commit …`).
- **Every fix needs a falsifiability fixture**, and after S122 the bar is higher: the fixture must
  fail for the RIGHT reason. Clean the planted defect out of the directory before testing the next
  branch, or the tooth is glued on.
- **`vajra init` blocks forever on stdin without EOF** — any caller needs `</dev/null`. This defect
  cost 10 minutes at S121 and 20 at S122. `verify-session-113.sh` is fixed; older scripts are not.
- **Attest LAST**: `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff); compute strictly after the
  `## Execution` shas are committed; two consecutive `verify-closeout.sh --inputs-sha 123` runs must
  agree before embedding.
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)**, and the canonical
  `**Verdict:** ACCEPT` must be its own bare line, never inside a table cell.
- **Expect more than one cold pass.** S122 needed four (REJECT → ACCEPT-with-findings → REJECT →
  ACCEPT) and every rejection was correct. Budget for it; do not treat pass 1 as a formality.
