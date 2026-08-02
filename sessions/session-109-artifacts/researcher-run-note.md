# S109 — live Researcher subagent run (the headline proof)

- **Date:** 2026-08-02 (session 109)
- **Mechanism:** a REAL native subagent dispatched via the Claude Code Task tool, scoped by the
  canonical Researcher role prompt (`fleet::ROLES`). It ran INSIDE the authenticated session — no
  headless `claude -p` auth wall (the wall the first build hit; see DECISION-007's rejected
  alternative and the brief itself, which researched exactly that auth problem).
- **Model:** sonnet · **tool_uses:** 4 · **subagent_tokens:** 58,669 · **duration:** ~67s.
- **Cost:** rolled into this session's parent receipt (subagent cost is not itemized per-run); the
  handoff records `cost_usd: null` (S77 honest null). Session total is disclosed in the summary.
- **Governed handoff:** `.ai/handoffs/session-109-researcher.md` — written by
  `vajra next --role researcher --from sessions/session-109-artifacts/researcher-subagent-brief.md`.
  `source-sha` = `ffa5b3fda7e05077d8521f4c031b49616dfcc41480c3755fe89eb8f070a49016`
  (sha256 of the brief body), so the handoff is verifiably derived from the exact findings.
  `fleet::validate_handoff` passed (frontmatter + non-empty body + `## Handoff Delta`).
- **Raw brief (verbatim subagent output):** `researcher-subagent-brief.md` in this dir.
- **Question asked:** the most reliable way to authenticate an unattended `claude -p` headless run
  (CI/cron) — directly useful for DECISION-007's deferred "unattended dispatch mode."
- **Headline finding:** `ANTHROPIC_API_KEY` is the only option that survives a fresh shell with no
  TTY and no keychain; `claude setup-token` is the subscription-billing alternative; interactive
  `/login` OAuth is not viable unattended.
