# Session 93 — Prove the commit gate has teeth

**Type:** CODE · **Branch:** `session-93-prove-commit-gate-teeth` · **Date:** 2026-07-21

## Goal

Turn `no-autonomous-commit` from **voluntary** (constitution-followed) into **enforced,
fail-closed**. Before S93, `.githooks/pre-commit` blocked only main / >3 files / `.ai` drift — an
autonomous commit on a clean session branch **passed**; the S76 + S92 dogfoods confirmed the agent
self-stopped at the commit boundary only by choice. Close the gap with approval evidence the agent
cannot self-grant.

## What shipped

| Layer | File | Behavior |
|---|---|---|
| **L2 belt** (git-native) | `.githooks/pre-commit` | On a `session-NN` branch, BLOCK (exit 1) unless env `VAJRA_ALLOW_COMMIT==NN`. Existing main/>3/drift checks untouched. |
| **L3 teeth** (un-forgeable) | `scripts/hook-commit-guard.sh` | PreToolUse(Bash): blocks `git commit` unless the marker is in the hook's **own launch env** — an inline prefix never reaches it (S37 proof), and it fires even on `--no-verify`. Also blocks an inline `VAJRA_ALLOW_COMMIT=` self-grant attempt explicitly. `commit_guard: off` in this repo; **ON in scaffolds**. |
| **Toggle** | `.ai/CONSTRAINTS.yaml` | `commit_guard: off` (build-agent exemption, mirrors `publish_guard: off`); re-arm with `VAJRA_ENFORCE_COMMIT=1`. |
| **Wiring + propagation** | `.claude/settings.json`, `src/cli/init.rs`, `Cargo.toml` | L3 joins the PreToolUse chain; `vajra init` scaffolds it byte-identical + ON; L2 propagates free (existing `include_str!`). |

**Marker design = the `VAJRA_CLOSEOUT_WAIVER` (S56) house pattern:** a founder-supplied env var
equal to the session number, session-scoped (a stale marker for another session does not apply),
never a tracked file the agent can `Write` (that would be in the diff and self-granted — the S69
"jurisdiction-self-granted" fakest-green class).

## Evidence

- **Live on this repo:** an autonomous `git commit` with no marker → `[pre-commit BLOCK] … exit 1`;
  the same commit with `VAJRA_ALLOW_COMMIT=93` → landed (commits `4142c1f`, `5a74322`, `044ae15`).
- **`scripts/verify-session-93.sh` → ALL GREEN (27/27):** L2 exercised by real commits in throwaway
  repos (block-without / allow-with / stale-rejected / main-blocked / non-session-untouched); L3 by
  synthetic payloads (no-marker / stale / inline-inject / `--no-verify` / compound / L1-advise /
  passthrough / off-toggle / off-toggle-rearm); e2e asserts `vajra init` inherits both byte-identical
  with L3 ON.
- **`cargo test --lib` = 286** (was 283; +3 scaffold tests). clippy clean.
- **Demo:** `scripts/demo-session-93.sh` exit 0, all four `demo:` markers.

## Fidelity Map (every AC → verdict + evidence)

| AC | Requirement | Verdict | Evidence |
|---|---|---|---|
| 1 | Autonomous commit on a session branch, no approval → BLOCKED, fail-closed, tracked hook | **SHIPPED** | `.githooks/pre-commit` exit 1; live block on this repo; `L2-block-no-marker` + `L2-main-blocked`. |
| 2 | Approval is an un-forgeable human env marker; commit WITH it passes | **SHIPPED (with disclosed layer caveat)** | `VAJRA_ALLOW_COMMIT==NN`; `L2-allow-with-marker`, `L3-allow-with-marker`, `L3-block-inline-inject`. Caveat: at **L2** an agent controlling the command line can inline the prefix (auditable, not impossible) — the truly un-forgeable layer is **L3** (its launch env is beyond inline reach). See Fakest Green. |
| 3 | Tests cover both paths, wired into `verify-session-93.sh`; `cargo test --lib` stays green | **SHIPPED** | 27/27 verify (L2 + L3 both paths); 286 lib tests. |
| 4 | `--no-verify` residual documented + mitigated, or disclosed with exact bypass | **SHIPPED** | L3 fires regardless of `--no-verify` (`L3-block-no-verify`); residual disclosed below. |
| 5 | `vajra init` scaffold carries the gate | **SHIPPED** | L2 propagates via existing `include_str!`; L3 added + 3 scaffold tests + Cargo negation; `e2e-guard-byte-identical` + `e2e-scaffold-guard-on`. |
| 6 | Summary maps every AC + names fakest green; independent cold review | **SHIPPED** | This file + `sessions/session-93-review.md` (cold subagent, prompt+diff only). |

## Fakest Green (stated plainly)

1. **The un-forgeability is real only at L3 — and L3 is OFF in this repo.** `commit_guard: off`
   (build-agent exemption) means vajra's own commits are gated only by the L2 belt, which an agent
   that controls the command line can satisfy by inlining `VAJRA_ALLOW_COMMIT=93` (that is exactly
   how *this* session committed, with founder approval). So in *this* repo the gate is
   **auditable, not un-forgeable**. The un-forgeable teeth are proven by payload test and shipped
   **ON in scaffolds** — where an unattended agent actually runs — not live-blocking here. This
   mirrors `publish_guard: off` precisely (S37/S47): proven by test + on in `init`, off in the repo
   that builds it, because a live L3 block would brick the build agent (it cannot set its own
   launch env mid-session).
2. **`git commit --no-verify` in this repo bypasses everything** — it skips the L2 git hook, and L3
   is off here. In a scaffolded project L3 is on and catches it; here it does not. Disclosed.

## Residual (exact bypasses)

- A commit made **outside** the Claude Code Bash tool path (a raw terminal, a different tool, CI)
  is not seen by L3 (PreToolUse) at all — only the L2 git hook governs it, and `--no-verify` skips
  that. This is out of an in-agent threat model but named for honesty.
- The marker equals a small integer (the session number); it is session-scoped but not a secret.
  The un-forgeability rests on *env-vs-command-line* separation at L3, not on secrecy.
- Pre-existing repo-wide **rustfmt 1.9.0 drift** in `next.rs` / `dogfood/mod.rs` / `stations/mod.rs`
  (S91-era commits, unrelated to S93) makes a repo-wide `cargo fmt -- --check` red; S93's fmt gate
  is scoped to its own change (`init.rs`, clean). Flagged for a housekeeping session.

## Next options (A/B/C, from ROADMAP)

**A — Nested-repo guard blindspot (S52 backlog, High).** *Goal:* teach the session-guard /
copilot-loader / **commit-guard** to distinguish Vajra's own `session-NN` branches from a subject
repo's identically-named branches during a dogfood. *Why:* the commit-guard now keys on
`session-NN` too, so this blindspot is directly load-bearing for governed dogfood runs. *Risk:*
branch-name heuristics are fuzzy; needs a reliable "which repo am I governing" signal.

**B — Compression exit-code fold gap (S33/S41 backlog, High).** *Goal:* make cargo/npm/pytest
output actually fold on real CC (they never send `exit_code`, so the `== Some(0)` path is dead).
*Why:* the "quiet bonus" has been 0-fold since S33. *Risk:* correctness-first (S36 directive) —
must never hide a failure; low daily-$ leverage per [[vajra-economics]].

**C — Repo-wide rustfmt drift cleanup (found this session).** *Goal:* reformat the three drifted
modules so `cargo fmt -- --check` is green crate-wide again. *Why:* small, restores a standard gate
before the **S95 ground truth**. *Risk:* touches files unrelated to any feature; pure housekeeping.

**Recommendation:** A — it is the highest-leverage governance-correctness item and the one this
session's change (commit-guard keying on `session-NN`) just made more relevant.
