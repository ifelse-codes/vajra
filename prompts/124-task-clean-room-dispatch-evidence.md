# Session 124 — CODE: close the clean-room dispatch gap

> **Status:** APPROVED (founder pick B of three at the S123 close).
> **Founder directive in force (S118):** `README.md` / `VISION.md` claims are the **target spec**.
> Do NOT soften them. No release until reality meets them.

## Type
CODE — one story, ≤3 files per atomic commit, ~2h cap, new chat.
Branch: `session-124-clean-room-dispatch-evidence`.

## Why this session

S123 built real machinery: `vajra next --role qa-specialist --clean-room-open`/`--clean-room-close`
materialise and remove a disposable `git worktree` checkout, and `qa-specialist`'s own system prompt
now instructs it to work inside that path. But `vajra next --role qa-specialist --from <file>` — the
command that actually GOVERNS a finding into `.ai/handoffs/session-NN-qa-specialist.md` — accepts
any findings file, from any working directory, whether or not a clean room was ever opened. The
fence exists; nothing checks it was used. S123's own review named this plainly: *"nothing in code
structurally forces a dispatch to call `--clean-room-open` first."*

**Do not repeat the self-asserted-marker mistake.** This class of hole has been disclosed FIVE
times now: `covers: N` (S64), `design-significant: yes` (S67), the check-class tally (S121, S122,
S123). Each is a claim the AUTHOR typed, unchecked against reality. A field like
`clean-room: yes` in a findings file, believed on its own word, would be a sixth instance of the
exact same defect — worse here, because the whole point of this session is to stop trusting an
agent's own report.

## Recommended mechanism (design-significant — confirm or revise in a `DECISION-007` S124 addendum)

**A Vajra-written receipt, not an agent-written marker.** `--clean-room-open` already runs inside
this process and already has everything needed to record real facts: the worktree path, the SOURCE
repo's `HEAD` sha / `git ls-files -s` hash / `git status --porcelain` at open time, and a random
nonce Vajra generates (never the agent). Write these to a receipt file
(e.g. `.ai/.clean-room-receipts/<role>-<nonce>.json`) that the AGENT never authors and cannot forge
by typing text into its own findings.

`--clean-room-close` re-captures the same three source-repo fingerprints at close time and appends
them to the SAME receipt — which makes the receipt double as the tamper-evidence record S123's
`clean-room-fence-has-teeth` fixture already proves the technique for, now persisted instead of
just printed to a throwaway fixture's stdout.

`--from`, when governing a role that holds `Bash` (today, only `qa-specialist`), requires a
`--clean-room-receipt <path>` argument (or `--from` fails closed with a clear message naming the
missing evidence). Vajra reads the receipt itself — not the findings file — and rejects the handoff
if: the receipt doesn't exist, doesn't belong to this role, is stale past a recorded bound, or (the
load-bearing check) its open/close fingerprints show the SOURCE repo changed during the run. **The
findings file itself never has to say anything about clean rooms at all** — that is the whole point;
nothing here is a claim the agent can make true by typing it.

**Rejected up front — do not build this instead:** a `clean-room: <path>` line inside the findings
file, checked by grepping for it. This is the self-asserted-marker class by definition; note it
explicitly as rejected in the `DECISION-007` addendum rather than silently avoiding it.

## Plan (ordered — cite the acceptance criteria each step covers)

1. **Confirm or revise the mechanism above**, then record it in a `DECISION-007` S124 addendum
   before code lands — the receipt shape, what it records, why a Vajra-written file beats an
   agent-written marker, and the residual risk (a receipt proves the recorded fingerprints matched
   at the time Vajra wrote them; it does not prove the agent ran INSIDE the clean room the whole
   time rather than, say, `cd`-ing out and back — name this plainly, do not oversell it).
   `covers: 1`
2. **Build the receipt write path.** `--clean-room-open` writes it; `--clean-room-close` appends the
   close-time fingerprints. Both real files, real hashes — reuse the exact
   `git rev-parse HEAD` / `git ls-files -s` / `git status --porcelain` technique
   `clean_room_fence_has_teeth` (S123) already proved. `covers: 2`
3. **Gate `--from` on the receipt for Bash-holding roles.** Missing / role-mismatched / stale /
   fingerprint-changed receipt → fail closed, clear message. A role with no `Bash` grant is
   unaffected (nothing to gate — same scoping S123 used for `--clean-room-open` itself). `covers: 3`
4. **`scripts/verify-session-124.sh` + `scripts/demo-session-124.sh`.** The load-bearing fixture:
   drive the REAL compiled binary through open → (simulate a run) → close → `--from`, and separately
   assert `--from` REJECTS when no receipt is supplied, when a stale/forged receipt is supplied, and
   when the receipt's own recorded fingerprints show the source repo changed mid-run. Per S122/S123:
   each fixture must fail for the RIGHT reason — isolate planted defects, don't let one assertion's
   setup leak into the next's. `covers: 4`
5. **Dispatch `qa-specialist` by name against this session's own suite**, then a cold
   `fidelity-reviewer` pass by name; summary with the per-requirement fidelity map + the fakest
   green. Same S111 caveat as S123: if this session edits the role's prompt or grant again, the
   dispatch inside THIS session still runs the pre-edit version — disclose it, don't hide it.
   `covers: 5`

## Acceptance criteria

1. The mechanism (or a deliberate, reasoned revision of it) is recorded in a `DECISION-007` S124
   addendum before step 2 lands, including the residual risk stated plainly.
2. `--clean-room-open`/`--clean-room-close` write and update a real receipt file, never an
   agent-authored marker; the receipt's fingerprints are captured by Vajra itself, not supplied by
   any caller.
3. `vajra next --role qa-specialist --from <file>` fails closed without a valid, matching,
   fresh, fingerprint-clean receipt; a role with no `Bash` grant is unaffected.
4. `verify-session-124.sh` exits 0; the load-bearing fixture proves REJECTION on at least three
   distinct bad-receipt shapes (missing, stale/wrong-role, fingerprint-mismatched) against the real
   binary, never by asserting the gate's own source text exists.
5. Cold `fidelity-reviewer` ACCEPT.

## Execution (the Coder gate — record each plan step's landing commit as work lands)

- step 1 — done: <sha>
- step 2 — done: <sha>
- step 3 — done: <sha>
- step 4 — done: <sha>
- step 5 — done: <sha>

**Record a real commit sha for every step.** Prose in place of a sha breaks `git cat-file` and goes
Coder-dark (the S119 defect, hit again at S122 until corrected).

## Design
- design-significant: **yes** — the receipt mechanism (or its in-session revision) is a real
  architecture decision about how dispatch evidence gets trusted. `DECISION-007` S124 addendum
  required before step 2 lands.

## Non-goals (not built this session)

- **Proving an agent stayed inside the clean room the whole time.** The receipt proves the SOURCE
  repo's fingerprint matched at open and at close; it does not trace every command the agent ran in
  between. Say this plainly in the addendum — it is the same isolation-not-proof posture S123's own
  residual risk section already stated for the clean room itself.
- **Making the check-class label EARNED.** Standing backlog (S124 option A), still not picked.
- **A paid dogfood run.** Standing backlog (S124 option C), still not picked.
- **Extending the receipt requirement to any role other than the ones holding `Bash`.** Read-only
  roles have nothing to isolate; do not widen the gate to them "for consistency."
- No 8th top-level command; no new flag family outside `--role`/`--from`/`--clean-room-*`.

## Guardrails
- Max 2 assumptions, max 2 retries, 1 story, ≤3 files/commit, ~2h cap.
- Approval token required before any commit (`VAJRA_ALLOW_COMMIT=124 git commit …`).
- **Every fix needs a falsifiability fixture, and it must fail for the RIGHT reason** — isolate
  planted defects between assertions (S122 lesson, reapplied cleanly at S123 to a brand-new fixture;
  do the same here from the start).
- **`vajra init` blocks forever on stdin without EOF** — any caller needs `</dev/null`.
- **Attest LAST**: `Review-Inputs-SHA` = sha256(HEAD:prompt ‖ diff); compute strictly after the
  `## Execution` shas are committed; two consecutive `verify-closeout.sh --inputs-sha 124` runs must
  agree before embedding.
- **The closeout gate counts verdict words ONLY on `|` table rows (≥3)**, and the canonical
  `**Verdict:** ACCEPT` must be its own bare line, never inside a table cell.
- **Expect more than one cold pass.** S122 needed four, S123 needed two, and both rejections that
  happened were correct. Budget for it; do not treat pass 1 as a formality.
- **A durable measurement claim needs a committed artifact, not prose** (S123 lesson) — if this
  session cites a live dispatch as evidence for anything, capture it the way
  `sessions/session-123-artifacts/tools-enforcement-measurement.md` did, not as unfalsifiable prose.
