---
role: release-coordinator
session: 167
agent: claude-code-subagent (verified: toolu_01S3wXyQ5d8TGb1Xq8WbgNq6)
source-sha: 88ce9eee35ae02cd2582c0105a0cf131961ec1ea73ce54a640f9c5d58ec5a864
captured: 2026-09-14T08:23:02Z
cost_usd: null
---

# Release-coordinator handoff — session 167

**Brief:** Release plan for S167 (vajractl 0.1.0 → 0.2.0 on GitHub Releases, crates.io, Homebrew). Not shippable yet: the session is unmerged and the founder has not said go. The version bump belongs in a separate post-merge release PR; the tag must point at that merge; `cargo publish` is irreversible and founder-typed only.

Ordered steps (condensed): 1 open PR (founder — push guard) · 2 cold fidelity review + verify-closeout on the branch BEFORE merge (agent) · 3 merge (founder) · 4 checkout main, pull --ff-only, fetch --prune · 5 delete merged session branches · 6 bump Cargo.toml/Cargo.lock to 0.2.0 + README version on a fresh branch → PR → merge · 7 tag v0.2.0 on that merge + push (starts release.yml) — wait for founder go · 8 GitHub Release built by CI (3 tarballs + .sha256) · 9 `cargo publish --dry-run` (agent) then `cargo publish` (founder only) · 10 Homebrew tap formula version + 3 sha256 (founder) · 11 install-smoke release/crates/brew + `vajra init` shows scripts/demo-kit.sh (agent).

Recommendations:
1. rec 1 — Do the 0.1.0 → 0.2.0 bump in a separate release PR after the session merge, then tag that merge commit.
2. rec 2 — Before the final release check, confirm no local `session-167-adhoc-fixes` survives (it would block require_pruned and could mask an unmerged deletion of this branch).
3. rec 3 — Pin `VAJRA_SMOKE_RELEASE_TAG=v0.2.0` and point `VAJRA_SMOKE_FORMULA` at the tap's own formula file.
4. rec 4 — Check for `scripts/demo-kit.sh` after `vajra init` from the published crate by hand (install-smoke.sh never checks it).
5. rec 5 — Treat `cargo publish` as founder-typed only: hook-publish-guard.sh does not cover it.

## Handoff Delta
- `+` new: first release-coordinator handoff for this session (1691 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
