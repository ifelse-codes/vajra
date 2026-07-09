# Session 54 — The governed-session ledger: extract from the trace + Darshan-present (A-thin)

> **S53 reframe (DECISION-001):** the product is **provable agent governance**, and the thing that makes it
> *sellable* is making governance **visible** to a buyer. S54 builds the first visible slice: a **ledger view** that
> reads a past session's Claude trace and shows — beautifully — *"your AI provably followed these rules; here's what
> it did, what got blocked, and why."* **This is A-thin: extract + present, so the user gets the FEEL.**

## Type
- **CODE** (first governance-visible feature). Max **2** assumptions · **2** retries · **~2h** · **1** story ·
  **new chat** · approval token before any commit.

## The honest scope line (do not cross it)
- **A-thin (THIS session):** extract from `~/.claude/projects/<slug>/*.jsonl` + **Darshan-present** the governed
  session. Makes governance **VISIBLE** (the sellable feel).
- **A-full (S56, NOT now):** persist that record into the repo, **git-tied + hash-chained** = tamper-**evident**
  audit *evidence*. **S55 is the mandatory NO-CODE ground-truth** — so A-full is S56, not S55.
- **Honest tag to carry in output:** A-thin is a *log viewer for governance*, not yet *evidence*. If it looks like
  "just a nicer `git log` for agents," record that — it is the signal the ledger isn't the moat (DECISION-001 revisit).

## The job
A **ledger view** over a past session's trace showing, per session:
1. **Rules in force** — the guards/policy that were active (`.ai/CONSTRAINTS.yaml` + the wired hooks).
2. **What the agent DID** — tool calls / edits / commands / PRs (from the JSONL).
3. **What was BLOCKED + which guard fired + why** — reuse the S48 block-detection (a Vajra rail block already
   surfaces as `tool_result{is_error,"PreToolUse:… hook error … [vajra …]"}`; `src/obedience/mod.rs` already mines it).
4. **Cost / turns** — from the trace (authoritative `total_cost_usd`, NOT the ~8× receipt).
Rendered in **Darshan** (rich/terminal/plain tiers) — glanceable, nothing dropped.

## Design constraints
- **Reuse, don't rebuild:** `vajra meter` + `src/obedience/mod.rs` already parse `~/.claude/projects/*.jsonl` and
  detect blocks. The ledger is a **presentation over that same parse** — extend it, don't fork it.
- **RESPECT THE MAX-7 COMMAND CAP.** Do **NOT** add an 8th top-level command without explicit approval — **ride
  `vajra meter`** (e.g. `vajra meter --ledger`), mirroring how `--all` (S49) rode `meter`. If a standalone
  `vajra ledger` is truly wanted, that needs founder approval first (it is the 8th command).
- **Read-only.** No hook change, runs on past sessions (like the obedience metric). No new heavy dep.
- **Honest cost:** use `total_cost_usd`; do not surface the known-wrong receipt number.

## What S54 must answer (in the summary)
1. Does the ledger view make governance **visible** — can a non-author glance at it and see "the AI followed the
   rules / here's what got blocked"? Show a real captured session, not a mock.
2. Is it **more than a script over the JSONL** yet? (Honest answer: **no, not until A-full** — say so.)
3. Does it stay within the command cap + read-only + reuse constraints?

## Deliverables
- The ledger view (riding `vajra meter`) + Darshan rendering.
- `scripts/verify-session-54.sh` (exits 0): runs the ledger over a real captured trace; asserts rules/actions/
  blocks/cost present; asserts no 8th command; asserts read-only.
- `scripts/demo-session-54.sh` + the interactive HTML demo when asked.
- `sessions/session-54-summary.md` + 3 ranked S55… wait — **S55 is the mandatory NO-CODE ground-truth**, so
  present 3 ranked candidates for **S56** (top = A-full, the durable/hash-chained evidence step).
- Update memory `vajra-direction-b-copilot` / `vajra-positioning` with the honest "extraction is a script; the
  moat is durability" finding (from the S53 discussion).

## Guardrails
- CODE session — but **slice tightly to A-thin**; do NOT drift into persistence/hash-chaining (that is S56).
- Darshan every human reply · Varta against the live `.ai/`.
- Do not overclaim: "visible" ≠ "tamper-evident evidence." Keep the honest tag.

## Output
- A working `vajra meter --ledger` (or approved surface) that extracts a real session's trace and Darshan-presents
  the governed record + `verify-session-54.sh` green + summary with the honest "visible-not-yet-evidence" verdict +
  3 ranked S56 candidates (top = A-full durability).
