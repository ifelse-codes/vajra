# Session 27 — Darshan: the human's glanceable output skill

**Type:** CODE/content · **Branch:** `session-27-darshan` · **PR:** [#18](https://github.com/ifelse-codes/vajra/pull/18) (open) · **Date:** 2026-06-29

## Goal achieved?

**Yes.** Built **Darshan** — Vajra's default, surface-adaptive, *glanceable* human-output skill. Skill, not a renderer (like Varta). Pairs with Varta: **the agent talks to itself (Varta); the user sees (Darshan).** Name confirmed at BOOT (founder: keep "Darshan").

## What shipped

| File | Change |
|---|---|
| `darshan/SKILL.md` (new) | Boot ritual (read→internalize→speak) · one rule (*render the richest visual this surface can handle; always glanceable; never drop meaning*) · 3-tier guide · worked before/after for chat + terminal · terminal-fallback + skill-not-renderer guardrails |
| `.ai/AGENTS.md` | Speaking Skills boot pointer — Darshan = default human output, Varta = agent's lane |
| `VISION.md` | Human lane made first-class, Varta's counterpart |
| `scripts/verify-session-27.sh` (new) | 18 checks |
| `scripts/demo-session-27.sh` (new) | wall-of-text → terminal/plain glance transform |

## Evidence

- `verify-session-27.sh` → **ALL GREEN (18 pass, 0 fail)** — incl. all 3 tiers, never-drop-meaning rule, terminal fallback, box-drawing example, skill-not-renderer, AGENTS.md boot wiring, no new command in `src/`.
- `cargo fmt`/`clippy`/`test` green. No `src/` touched, no new dep, no 8th command (max 7), ≤3 files/commit, 1 story.
- Dogfooded live: this session answered in Darshan form (rich-chat HTML card + terminal demo).
- Co-pilot loader fired on `git commit` (`⚡on(cmd:git commit) ⚡include STATE.md`) — enforcement working.

## Decisions

- **Name:** Darshan kept (founder confirmed at BOOT).
- **Boot wiring mechanism:** a Speaking Skills pointer in `.ai/AGENTS.md` (load-order file #1) — lightest, no 8th command, no Rust. Also closes a latent gap: Varta itself wasn't pointed-to from the constitution.
- **`vajra init` propagation: DEFERRED to S28** (same call S21→S22 made; kept this session to 1 story).

## Carry-forwards

- **`vajra init` scaffold propagation of Darshan (+ S26 session-guard)** — the highest-leverage next step (every project inherits the skill).
- **Second agent stays parked** — owner-gated on founder satisfaction with Vajra-on-Claude. Darshan is part of making Claude satisfying.
- **STATE.md PR-status drift** (4th time) — write "open (merge after closeout)" at closeout, not "pending merge".
- Still open: `vajra estimate` 3:1 ratio unvalidated; `vajra claude` no auth pre-check.

## Next session — pick one (A/B/C)

### A. Propagate Darshan + session-guard into `vajra init` (CODE) — *recommended*
- **Goal:** every scaffolded project inherits Darshan (the S27 deferral) and the S26 one-session-per-chat guard, so a fresh `vajra init` ships the full enforced + glanceable loop.
- **Why pick this:** closes two open deferrals at once (S27 + S26 rider); the S22 pattern is proven and low-risk; finishes the "make Claude satisfying" arc end-to-end.
- **Key risk:** `init.rs` propagation can spill past 1 story (two artifacts to emit) — may need to split Darshan-only vs guard-only.

### B. Dogfood Varta + Darshan on a real project (NO-CODE-ish content)
- **Goal:** run the full skill set on an actual outside task, log every friction point, fix-or-defer.
- **Why pick this:** the founder's "is Claude satisfying yet?" gate is answered by *use*, not more building; surfaces whether Darshan actually reduces load in practice.
- **Key risk:** findings may reopen Darshan/Varta scope; no shippable artifact guaranteed.

### C. Un-park the second agent (Codex or Cursor) (CODE)
- **Goal:** wire a second agent launcher, proving ADR-0002's adapter contract is vendor-neutral — the north-star gap.
- **Why pick this:** the only wedge pillar with zero code; the S25 audit's #1 pick.
- **Key risk:** **owner-gated** — only un-parks if the founder now declares Vajra-on-Claude satisfying. If not, stays parked.
