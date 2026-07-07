# Session 49 — Obedience baseline (direction B, founder pick A, CODE/reporting)

## Goal
Give the S48 `obedience %` a **yardstick**: run the metric across the project's past session transcripts
→ a ranked table + aggregate (median/range), so a single reading *means* something. Reporting only ($0),
descriptive not causal, reuses the S48 module. **Achieved.**

## What shipped
- **`vajra meter --all [dir]`** — a batch/present layer over the S48 `obedience_for`. Enumerates
  `*.jsonl` in a directory (default `~/.claude/projects/<cwd-slug>`, the meter's discovery layout),
  computes each session's obedience read-only, prints a **worst-first** ranked table + an aggregate
  (n / median / range / total blocks / empties skipped). No 8th command (rides `vajra meter`), no new
  dep, read-only.
- `src/obedience/mod.rs`: `BaselineRow` / `BaselineAggregate` + `baseline_for_dir` + `aggregate`
  (median/range; skips 0-tool-call transcripts) + `sort_rows` (worst-first) + `format_baseline`. **+5 unit tests.**
- `src/cli/meter.rs`: `--all` dispatch; table → **stdout** (the single-session receipt stays stderr).
- `scripts/verify-session-49.sh` **27/27 green**; `sessions/session-49-baseline.md` (committed artifact).

## Evidence (real transcripts)
- Ran over this project's **63 counted sessions** (+2 empty skipped). `cargo test` **129 lib** (+5); clippy+fmt clean.
- **The yardstick:** all-sessions median 100.0% is inflated (12 one-call + 33 fully-clean sessions). The
  honest view — **substantive sessions (≥10 tool calls), n=52 → median 98.9%, band 95–100%.**
  → **The S48 live reading of 98.9% was dead-on normal, not a smell.**
- **One outlier worth a look:** a 1-tool-call session at **0.0%** (blocked on its first move by
  `hook-copilot-loader.sh`); low n lets a single block dominate.
- **44 total blocks** across 63 sessions — all real Vajra rail fires (`copilot-loader` common; `publish-guard`
  = the moat, incl. the S46 isolation run). Commits `4717029` (feat) + `35e081c` (verify+artifact); ~$0.

## Honest read (the S47/S48 bar)
- **Descriptive, not causal.** It says what obedience *has been*, not that Vajra *caused* it.
- **Small n, high cluster** — blocks are rare in a governed chat → use the substantive ≥10-call view.
- **Still a floor, not a ceiling** — counts only hook-attributed blocks; a silently-worked-around rule or
  hook-less rework is invisible. **Obedience ≠ work-quality** — that is option B, still unmeasured.

## Self-review
What can break: a foreign/huge `--all` dir (per-file read is lazy + `flatten()` skips unreadable) · hidden
assumptions: `--all` surface + worst-first ranking (both prompt-sanctioned, stated at BOOT) · production-ready:
27/27 + 129 lib green, read-only · repro-evidence only: no defensive patches · scope intact: 1 story, ≤3 files/commit,
no 8th command, no new dep.

## Next — S50 is the mandatory NO-CODE ground-truth (every 5th; last = S45)
S50's *type* is fixed (NO-CODE GT, all 8 `required_audits`). The choice is the **lead lens**:

- **A (recommended) — Combined GT, direction-B value lead.**
  *Goal:* run the mandated 8 audits with the lead question "is work-quality (option B) still UNMEASURED, and
  was instrumenting the floor (S47 murmur → S48 metric → S49 baseline) the shortest path — or comfortable
  scope-creep away from 'make the AI do better work'?"
  *Why pick:* sharpest on the standing #1 gap while still discharging the every-5th mandate.
  *Risk:* a value-lead audit can under-weight discipline drift — the 8-audit checklist must still run in full.

- **B — Combined GT, dogfood/enforcement lead.**
  *Goal:* re-verify the moat is still live (`dogfood_check` 🟢 since S46) and cost discipline holds; has any
  real *paid* work run through `vajra claude` since S46?
  *Why pick:* keeps the hardest-won green (live-verified moat) honest; cost ledger is the only usage proof.
  *Risk:* the moat is "done"; may re-audit settled ground instead of the open value question.

- **C — Combined GT, process-cost + note-compression lead.**
  *Goal:* audit whether the backlog "every-5th session also compresses accumulated notes/memory" idea should
  activate now — is `.ai/` / KNOWLEDGE.md bloating; does the S49 baseline give a cheap drift sensor?
  *Why pick:* turns the GT into upkeep + dogfoods S49 as an audit instrument.
  *Risk:* narrowest; risks polishing process over interrogating direction.

**Then S51 resumes CODE** (founder pick from the S50 GT's ranked candidates).
