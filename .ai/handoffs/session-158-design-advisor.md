---
role: design-advisor
session: 158
agent: claude-code-subagent (verified: toolu_01TmAhN4x384dKxeQRRQHYCo)
source-sha: ba1342ddd739ac2a649bfb0951fc850d89ca8b94971edd21af5a1a532f0c5607
captured: 2026-09-09T14:54:24Z
cost_usd: null
---

# Design-advisor handoff — session 158

## Session 158 Design-Advisor Handoff

**Session:** 158 — Demo enforcement
**Branch:** session-158-demo-enforcement

### Design-significance verdict: yes

`is_code_session()` is a new shared inference contract (two gate functions call it now; every future CODE-specific check will too). `check_demo_markers` adds a new enforcement surface to the Demo-er station. Both represent observable changes to `verify-closeout.sh` failure modes.

### Key finding: is_code_session() has a substring-matching hole

The current negative-exclusion approach (`grep -qiE 'document|no-code|...'`) fails silently when a CODE session's Type line contains a substring that matches an exclusion. Example: `- **CODE** (documentation fixes)` would be classified as non-CODE, silently exempting the session from demo enforcement with no error.

**Recommended fix (rec 2):** flip to affirmative matching — look for `**CODE**` in the Type section; return CODE if found; if prompt exists but keyword absent, return non-CODE; keep no-file default as CODE.

### check_demo_markers design: sound

- Marker format `demo:${el}` is the right pattern (not subject to free-text ambiguity)
- Separation between "script exists" (check_verify_demo_scripts) and "markers present" (check_demo_markers) is clean
- Waiver path correctly threaded through both failure modes
- `--demo-only` calls `check_demo_markers` which calls `is_code_session()` — no bypass

### No existing ADR/DECISION covers this

Closest: DECISION-002 (fidelity-over-discipline motivation). No record covers session-type detection or the demo marker contract.

### Recommendations

rec 1 — Record `design-significant: yes` in `## Design` section of the session prompt; `is_code_session()` is now a shared inference contract and `check_demo_markers` adds a new enforcement surface.

rec 2 — Flip `is_code_session()` from negative-exclusion to affirmative-inclusion: match `\*\*CODE\*\*` in the Type section; return CODE if found; return non-CODE if prompt exists but keyword absent; keep no-file default as CODE.

rec 3 — Confirm `--demo-only` still calls `is_code_session()` before running marker checks rather than bypassing type detection. (Confirmed: `check_demo_markers` calls `is_code_session()` at the top; `--demo-only` calls `check_demo_markers`.)

rec 4 — Write a new DECISION record for session-type detection contract and demo marker enforcement pattern, citing DECISION-002 as motivation.

rec 5 — Add a timeout guard to the `bash "$D" 2>&1` call in `check_demo_markers` (e.g., `timeout 60 bash "$D"`) to prevent a slow demo script from blocking closeout indefinitely.

## Handoff Delta
- `+` new: first design-advisor handoff for this session (2627 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
