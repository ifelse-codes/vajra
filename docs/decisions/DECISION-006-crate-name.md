# DECISION-006 — v0.1 crate name: `vajractl` (crate) + `vajra` (binary)

- **Date:** 2026-07-25 (Session 101)
- **Status:** ACCEPTED
- **Type:** release/packaging decision (not an architecture ADR)
- **Relates to:** DECISION-005 (autopilot trust / release backstop) — the 2026-09-15 backstop requires
  Vajra be "installable by a stranger," which needs a settled, available crate name. This decision
  records the name **on paper only**; it publishes, tags, and renames **nothing**.

---

## Context — why decide now

The README promised `cargo install vajractl`, but the name had never been checked against crates.io
in a recorded way, and the 45-session-stale note "crate name taken" lived only in memory. The
release backstop cannot ship an install command that 404s or, worse, installs someone else's crate.
So: check both candidate names live, and write the answer down.

## The live availability check (re-runnable evidence)

Command (crates.io requires a User-Agent header; a bare `curl` returns 403 from its edge):

```bash
UA="vajra-availability-check (kissan.suman@gmail.com)"
curl -fsS -A "$UA" https://crates.io/api/v1/crates/vajractl -o /dev/null -w "%{http_code}\n"  # -> 404
curl -fsS -A "$UA" https://crates.io/api/v1/crates/vajra    -o /dev/null -w "%{http_code}\n"  # -> 200
```

Result (2026-07-25):

| Candidate | crates.io | Meaning |
|---|---|---|
| `vajra` | **HTTP 200** — exists, `max_version` 0.1.0, 1487 downloads (an unrelated crate) | **TAKEN** — cannot publish under it |
| `vajractl` | **HTTP 404** — no such crate | **AVAILABLE** |

## Decision

- **Crate (crates.io package): `vajractl`.** It is available today, and `vajra` + `ctl` follows the
  established Unix control-tool convention (`kubectl`, `systemctl`) — self-describing as a CLI.
- **Binary: `vajra`.** Binary names are not globally namespaced the way crate names are, so the short,
  memorable command users actually type is unaffected by the crate collision. `cargo install vajractl`
  installs a binary named `vajra`.
- This matches the repo's current `Cargo.toml` (`[package] name = "vajractl"` · `[[bin]] name =
  "vajra"`) — so this decision **ratifies the de-facto state on paper**. No `Cargo.toml` edit is made
  in S101.

## What this does NOT do (honesty preserved, per DECISION-001)

- **Nothing is published.** `cargo publish` is a release *action* for a later session; running it now
  is out of scope (and the machinery-freeze exemption S101 was granted covers docs + a decision only).
- **Nothing is tagged or renamed.** The README's crates.io / Homebrew / prebuilt lines remain marked
  **NOT YET PUBLISHED** until a release session makes them true.
- **The name is not reserved.** `vajractl` is available *as of 2026-07-25*; a release session must
  re-run the check immediately before `cargo publish`, since availability can change.

## Revisit if

- A pre-publish re-check shows `vajractl` has since been taken → pick the next available `vajra*` name
  and update this record + the README before publishing.
- The founder wants the binary renamed too (e.g. to avoid any confusion with the taken `vajra` crate)
  → that is a separate, larger decision touching every doc and the scaffold; not assumed here.
