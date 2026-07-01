# Discovery — Headroom / obedience (2026-07-01)

**Type:** brainstorm + tool dogfood. **No code.** Pre-S33; does **not** consume the S33 build slot (compression schema fix stays pinned). Build order deferred to founder (see ROADMAP Backlog).

**One line:** ran `headroom learn` on this repo; it is a *detector*, Vajra is the *enforcer* — the two compose, and its output is a free map of where Vajra's co-pilot is silent.

---

## 1. The four OSS tools looked at

| Tool | Lane | License | Maps to Vajra | Verdict |
|---|---|---|---|---|
| **caveman** | output compression (CC skill) | MIT | old compression hook | skip / study `stats` idea |
| **headroom** | context/output compression + `learn` | Apache-2.0 | hook (compress) **+ co-pilot (learn)** | borrow the *pattern* of `learn`; parked for compression |
| **Zep / Graphiti** | temporal knowledge-graph memory | Apache-2.0 | ledger (recall side) | watch — competitor drifting to "governed" framing |
| **cmem / claude-mem** | agent note-taking memory | Apache-2.0 | ledger (capture side) | borrow capture pattern; own the governance layer |

**License reality:** all MIT/Apache → **fork/depend + attribute**, never reverse-engineer. Reverse-engineering is only for closed things (Zep Cloud, cmem Cloud). The permissive path is already open.

**Category trap:** caveman + headroom are *compression* = the lane [[vajra-economics]] already ruled commodity (~6–8% blended $, not the moat). Do **not** map them onto Varta/Darshan — Varta = enforcement, Darshan = human comprehension. The analogy (caveman≈Darshan, headroom≈Varta) *inverts*: compression shrinks for the machine; our two pillars are enforcement + comprehension.

---

## 2. The `headroom learn` run on this repo

`headroom learn` (dry-run) mined **67 sessions / 2730 calls / 122 failures** and produced evidence-backed, dollar-tagged waste patterns. Key output split by *cause*:

| Finding | ~tokens/session | Cause |
|---|---|---|
| ROADMAP.md re-read 11× | 12,067 | **agent** habit |
| Commit rules discovered late | 8,000 | **Vajra rules** (found late) |
| `tail -5` truncates → reruns | 4,873 | **agent** (bad pipe) |
| GitHub via Chrome MCP loops | 3,894 | **agent** |
| Wrong script paths | 3,055 | **agent** |
| Read-before-Write retries | 3,000 | **Claude Code's** rule |
| Push/PR rail | 500 | **Vajra rules** |

**The mirror:** the "Vajra rules" findings are Vajra's *own enforcement hooks* showing up as friction — the ≤3-file pre-commit block (violated 30+×), the co-pilot STATE-in-context requirement, the drift guard, no-main-push. Two signals at once:
- ✅ **Validation** — the hooks are real; they shape behavior across 2730 calls.
- ⚠️ **Gap** — the agent keeps *hitting* them → the co-pilot's proactive surfacing is incomplete (it blocks late instead of warning early).

**Of ~35k flagged, only ~8.5k traces to Vajra's rules — and that slice is "found late," not "wrong."** The majority is generic agent sloppiness Vajra didn't cause but *could* advise on.

---

## 3. The core reframe

| | headroom `learn` | Vajra |
|---|---|---|
| **Detect** waste from the trace | ✅ strong (Vajra lacks this) | ❌ done by feel in GT audits |
| **Remedy** | prose advice into `CLAUDE.local.md` (hope) | hook / co-pilot rule (block) |

**headroom detects; Vajra enforces.** Complementary, not competing. headroom's remedy (prose in a `.md`) is exactly the mechanism S31 proved weak ("Darshan not obeyed — prose pointer, not enforced"). So: take the *detection*, convert to *enforcement* — never `--apply`.

---

## 4. Why a rule that is *in context* still gets disobeyed

The rule was **already in AGENTS.md**, read at boot, and still blocked 30+×. Because **in context ≠ obeyed**:

- **Attention ≠ presence** — the model attends to the current step, not a rule 5k tokens back.
- **Lost in the middle** — rule read at turn 1; the commit is turn 80; the boot doc sags.
- **Goal tunneling** — under "finish closeout" pressure, sideways constraints drop.
- **Recognition is the hard step** — it knows "≤3 files"; it fails to notice *this* commit triggers it.
- **Dilution** — dozens of rules → any single one is low-salience.

> The rule is in the room. It's just not in front of the agent's face at the second it acts.

**This is the S18 thesis** (co-pilot, not cop) proven with 67 sessions of data. The doc holds the rule; the doc does not make the agent obey it. And "always in context" (compact Varta) does **not** escape it — it only raises the odds. This is the S20 fear ("a spoken language enforces nothing") that S21 resolved **via the loader that fires + blocks**, not via presence (see [[vajra-varta-wedge-risk]]).

---

## 5. The obedience ladder

| Rung | Mechanism | Vajra piece | Strength |
|---|---|---|---|
| 1 · **Tell** | rule in a doc, read at boot | `AGENTS.md` | hope — fades |
| 2 · **Remind** | fire the rule *at the trigger* | co-pilot `⚡on` (L1 print) | salient — still ignorable |
| 3 · **Block** | action can't complete until compliant | co-pilot / hook **exit 2** (L2/L3) | **structural — real obey** |
| 4 · **Automate** | compliant path is the default; no choice | *(mostly unbuilt)* | strongest — nothing to disobey |

**"Always obey" starts at rung 3.** Rewiring behavior = pushing each rule *up* this ladder — change what happens when the agent acts, not how the rule is worded. You don't rewire the model (it resets every session); you rewire the *loop* — rails that re-fire every session from the live `.ai/`.

**Split first:**
- **Checkable rules** (≤3 files, STATE-before-commit, no-main-push) → reach rung 3–4 → **100% achievable.**
- **Judgment/style rules** (Darshan "no wall of text") → no clean sensor → cap ~2.5, strong-bias only. This is the open frontier (S31 #1 / S32 `Stop`-heuristic follow-on).

---

## 6. The rally metaphor (honest limit)

| Rally | Vajra | Guarantees obey? |
|---|---|---|
| **Co-driver / pace-notes** — calls the corner before it arrives | co-pilot `⚡on` fires at the trigger | **No** — makes it likely + smooth |
| **Rev limiter / ABS / Armco** — mistake physically can't happen | hook **exit 2** | **Yes** — for anything with a sensor |

**Vajra is both.** "Every time" comes from the *limiter*, not the voice. The co-driver's job is to make the limiter almost never trip. headroom's 30+ blocks = the limiter doing the co-driver's job → the pace-notes are incomplete. No sensor (style) → no limiter → best-effort only, stated honestly. *That honesty is the moat.*

---

## 7. Measure it, don't guess

headroom hands us the method to close the S30/S31 "no metric measures usage" gap:

> **Obedience % ≈ clean actions ÷ (clean + blocked/retried actions)** — straight from the trace.

Turns 30 → 80 → 100 from felt numbers into a real dial that moves each session.

---

## 8. Candidate build (backlog — NOT scheduled here)

Staged, one story each:

| Stage | Goal | Move |
|---|---|---|
| 0 · Measure | baseline the real % | count clean-vs-blocked from the trace |
| 1 · Co-driver | 30 → 80 | mine headroom's 30+ blocks → missing `⚡on` **L1 advisories**; automate 2–3 worst habit-wastes |
| 2 · Limiter | 80 → ~100 (checkable) | promote the load-bearing few from L1 advise → **L2/L3 block** |
| 3 · Frontier | judgment rules | the Darshan `Stop`-heuristic R&D (best-effort) |

Note Stage 2 rules mostly *already block*; the work is wiring the co-pilot to warn *before* them so the block stops being the teacher.

---

## 9. Decisions locked today

- **Never `--apply`** headroom on this repo — its default target is `CLAUDE.local.md` (gitignored) **but the dry-run also appends to `MEMORY.md`** (the agent's memory index) → a second source of truth that drifts from `.ai/` (violates [[feedback-distill-no-drift]]). Use it **look-only**.
- **A `/tmp` copy won't teach `learn`** — headroom reads chat history from `~/.claude/…` keyed by the project's *original* path; a copy has no history ("No conversation data found", as `darpan`/`mannat` showed). Analyze the original path or not at all.
- **We have enough** from the one real run (67 sessions of data) — no more headroom runs needed.
- **Queue unchanged** — pinned S33 = compression schema fix stays; this discovery is backlog until the founder ranks it.
