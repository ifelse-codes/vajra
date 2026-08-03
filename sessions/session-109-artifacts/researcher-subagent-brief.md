# Findings Brief: Headless `claude -p` Authentication for CI/Cron

## Answer
**`ANTHROPIC_API_KEY` is the most reliable option for an unattended, no-TTY, no-keychain shell.** It is a plain environment variable, is read directly by the CLI with no local state file, and — critically — in non-interactive mode (`-p`) it is *always* used when present, with **no approval prompt** (the one-time "approve this key?" prompt only fires in interactive mode). Nothing to provision on disk, nothing that expires, nothing that depends on an OS keychain.

`CLAUDE_CODE_OAUTH_TOKEN` (from `claude setup-token`) is the correct second choice **only if Vajra needs to run under a Pro/Max/Team/Enterprise subscription instead of Console API billing** — it also survives a bare env-var-only shell, but comes with more caveats (below).

Interactive `/login` OAuth is **not viable** for a fresh, unattended shell — it depends on state (keychain or credentials file) that a clean environment won't have, and even when pre-provisioned it decays over time with no unattended recovery path.

## Why `ANTHROPIC_API_KEY` wins for "fresh shell, no TTY, no keychain"
- Sent as the `X-Api-Key` header directly; no dependency on `~/.claude/.credentials.json` or macOS Keychain at all.
- Official precedence order (highest to lowest): cloud-provider creds → `ANTHROPIC_AUTH_TOKEN` → **`ANTHROPIC_API_KEY`** → `apiKeyHelper` → `CLAUDE_CODE_OAUTH_TOKEN` → `/login` subscription OAuth. It sits above both other options.
- No expiry to manage, no browser step ever required, works identically in Docker/cron/CI runners with zero prior state.
- Trade-off: bills as direct Anthropic API/Console usage (pay-per-token), not against a Pro/Max seat.

## `CLAUDE_CODE_OAUTH_TOKEN` (`claude setup-token`) — the subscription alternative
- One-time setup requires a **browser** (run `claude setup-token` once, anywhere with a browser, on a machine that already has a Pro/Max/Team/Enterprise login) — it prints a token to the terminal but **does not save it anywhere**. You copy that token and set it as `CLAUDE_CODE_OAUTH_TOKEN` in the CI/cron environment.
- After that one-time generation, it is a pure env var at runtime — also survives a fresh shell with no keychain, no TTY, no browser needed again.
- Caveats: token is long-lived but expires in **one year** (manual regeneration, needs a browser again); it **cannot be used with `--bare` mode** (bare mode ignores this var — must fall back to `ANTHROPIC_API_KEY`/`apiKeyHelper` there); it can't establish Remote Control sessions or fetch claude.ai connectors (local MCP servers still work fine).
- Use this only if the goal is to consume subscription seat capacity rather than Console API $.

## Interactive `/login` OAuth — why it doesn't survive a fresh shell
- Credentials live in the **macOS Keychain** (macOS) or `~/.claude/.credentials.json` (Linux/Windows, mode 0600) — both are local persistent state that a genuinely fresh shell/container will not have.
- Establishing it requires a browser + either a TTY or a manually pasted callback code — not scriptable unattended.
- Even if you smuggle the credentials file into the container, subscription logins **expire** (warning shown 3 days out) and once expired, "each request fails with `Login expired` until you sign in again" — there is no unattended renewal path. A long-running cron job on this method will eventually go dark with no self-recovery.

## Recommendation for Vajra
Default to `ANTHROPIC_API_KEY` for CI/cron headless runs — simplest, zero local state, no expiry, works with `--bare` too. Only reach for `CLAUDE_CODE_OAUTH_TOKEN` if Vajra explicitly needs to bill against a human's Pro/Max/Team/Enterprise subscription instead of a Console API key, and build in a yearly-token-rotation reminder since it isn't self-renewing. Treat `/login`-based OAuth as interactive-only — do not design any unattended Vajra path around it.

Sources:
- Authentication — Claude Code Docs (code.claude.com/docs/en/authentication)
