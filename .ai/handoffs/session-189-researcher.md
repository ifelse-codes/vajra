---
role: researcher
session: 189
agent: claude-code-subagent (verified: toolu_01A1sCcY3XDwdEiRtHt8P1HN; text-sha: 1be4e5bde6ad03e5bc1caf2f077e6cb1972bd9443b9515aa467a5d2e75c39764)
source-sha: 291f8d2d70ae65329d5c67fc432b4c1882ac608beb629df3bf1e887b9edf626d
captured: 2026-10-07T02:10:54Z
cost_usd: null
---

# Researcher handoff — session 189

Researcher brief: use none of the four candidates as the primary. Claude Code 2.1.280 writes its own session total into the transcript as a `{"type":"cost-state", ...}` line when the process exits. That is the surface to read. S77 found no cost in the transcript because the line did not exist yet. Here it appears in 2.1.275 and 2.1.280 transcripts. Identify the run's session(s) by session id, using a SessionStart hook added to the `--settings` tempfile Vajra already injects. Do not pick the newest file. `~/.claude.json` `lastCost` carries the same numbers, but it has one slot per folder and is undocumented. Use it as a cross-check only.

**What I verified locally (read-only; no paid commands)**
- **The transcript line.** In rudra session `9b221da1-…`, near the end (lines 1637 and 1639) there are two lines like this: `{"type":"cost-state","sessionId":"9b221da1-…","totalCostUSD":29.88766520000001,"totalAPIDuration":…,"totalDuration":…,"startTime":1791048992170,"modelUsage":{"claude-haiku-4-5-20251001":{…"costUSD":0.474…},"claude-opus-5-5":{…"costUSD":29.413…}},"hasUnknownModelCost":false}`.
  - The two lines are identical except `totalDuration`, which differs by about 20 ms. One exit can write the line twice, so take the last one and never add them up.
- **It matches `~/.claude.json` exactly.**
  - `projects["/Users/suman/playground/rudra"]`: `lastSessionId` 9b221da1-…, `lastCost` 29.88766520000001, same `lastStartTime`, same per-model `costUSD`.
  - The vajra entry (session c6391916, $43.36776920000002) matches the same way.
  - So both files record the same totals; they are written at the same moment.
- **It is written at exit, not during the session.**
  - The current running session (60ab3ed6, started 2026-10-07 02:03Z) has no cost-state line yet.
  - The vajra entry in `~/.claude.json` still shows the previous session c6391916.
- **It survives an exit that was clean but not "graceful".** c6391916 has `lastGracefulShutdown: false` yet still has a cost-state line and a `lastCost`.
- **It adds up across resumes.** vajra `69ecb30e` has four cost-state lines, all with the same `startTime`: 4.65, then 13.94, then 17.51, then 25.60.
- **Coverage.**
  - 59 cost-state lines across 32 main transcripts; none in `subagents/*.jsonl`.
  - Each total includes subagent spend (SDK docs: `total_cost_usd` and `modelUsage` "Included" for subagents).
- **The folder key in `~/.claude.json` is the resolved real path.** Only `/private/tmp/...` keys exist, never `/tmp/...`.
- **CC's transcript folder name replaces every character that is not a letter or digit.** Example: the `-private-var-folders-0s-snr36g-x5kb…` folder.

**The four candidates compared**
1. **`~/.claude.json` → `projects[path].last*`**
   - Undocumented; only community gists describe it.
   - Written at exit, with the same numbers as cost-state.
   - One slot per folder: two sessions in the same folder overwrite each other, and only the last session to exit survives.
   - A global, contended file (concurrent-write corruption issue anthropics/claude-code#28837).
   - Key is the real path, and per the gist the git root.
   - I believe `CLAUDE_CONFIG_DIR` moves it to `$CLAUDE_CONFIG_DIR/.claude.json`, but I did not verify that.
   - Verdict: cross-check only.
2. **Status line `cost.total_cost_usd`**
   - Documented, live, includes subagents, resets on `/clear` (since 2.1.211).
   - Reading it means injecting a `statusLine`, which is a single setting and would replace the user's.
   - Verdict: rejected, per your constraint.
3. **Hook inputs (Stop, SubagentStop, SessionEnd)**
   - None carry cost or usage (hooks docs).
   - They do carry `session_id` and an absolute `transcript_path`. SessionEnd `reason` includes `clear` and `resume`.
   - Verdict: this is the matching tool, not the cost source.
4. **Transcript `cost-state`**
   - Documented in substance: the SDK cost-tracking docs say CC "saves the session's totals to its transcript when the process exits normally and restores them when a later call resumes or forks the session".
   - The sessions docs warn the line format "is internal … changes between versions".
   - Verdict: recommended.

**Known failure modes**
- **Crash or kill** (SIGKILL, power loss): no cost-state is written.
- **Resume / `--continue`:** the total includes all earlier spend in that conversation.
- **Fork (`--fork-session`, `/branch`):** a new id, with the parent's total carried in (per SDK docs). Whether the copied transcript also carries the parent's cost-state line is unverified.
- **`/clear`:**
  - It starts a new id and a new transcript, and the totals reset.
  - Unverified: whether the session before the `/clear` gets its own cost-state line when you clear. I found no local `/clear` example.
- **Concurrent sessions in the same folder:** the session-id match solves this. Today's newest-file approach and `~/.claude.json` both fail.
- **Same session resumed in two terminals:** both write into one transcript, so the run's share is unclear.
- **Background sessions:** if the user moves the session to the background (agent view), the process Vajra spawned exits before the cost is final.
- **`CLAUDE_CONFIG_DIR` / `CLAUDE_CODE_PROJECT_DIR_NAME`:** both move the transcripts.
  - The hook's absolute `transcript_path` is unaffected.
  - Vajra's current `find_session_jsonl` (`/Users/suman/playground/vajra/src/meter/mod.rs:609`) hard-codes `~/.claude/projects` and replaces only `/`. It will look in the wrong folder for paths containing `_`, `.` or spaces, or for names over 200 characters, which CC hashes.
- **It is an estimate, not a bill:** a client-side list-price figure. `hasUnknownModelCost: true` means a model was unpriced, which is the F67 class.
- **Older versions:** CC before about 2.1.275 has no cost-state line.

rec 1 — Make the transcript's last `{"type":"cost-state"}` line for the matched session the receipt's only cost source; do not use `~/.claude.json` or the status line as the source.
Same numbers, documented behaviour, keyed by `sessionId`, survives concurrency. Take the last line; never add the duplicates. Show the per-model `costUSD` split. If `hasUnknownModelCost` is true, say "includes an unpriced model".

rec 2 — Identify the run's sessions with a SessionStart hook added to Vajra's existing `--settings` tempfile, recording `session_id`, `source`, `transcript_path` and a baseline into a Vajra-owned sidecar; stop guessing by newest-file-in-cwd-slug.
Hooks merge with the user's own; nothing of the user's is replaced. A `/clear` triggers SessionStart again with the new id. Baseline = `totalCostUSD` of the last cost-state line already in that transcript for that id (0 if none) at hook time.

rec 3 — Compute run cost as the sum over recorded session ids of (last cost-state after the run minus the baseline).
If no baseline was found but `cost-state.startTime` is earlier than Vajra's launch time, the total includes earlier spend (fork, or a resume Vajra didn't see). Show it as "Claude Code's session total $X — includes spend from before this run; this run's share is unknown". Do not subtract by guesswork.

rec 4 — When no cost-state line matches, print an explicit no-cost line with the reason, and never fall back to a token-times-price headline.
Suggested wording: `cost: not recorded by Claude Code for session <id7> — <reason>`. The reason is one of:
- "it did not exit normally"
- "Claude Code <ver> predates cost records"
- "session moved to the background"
- "no session started"

Keep the existing `[estimate]` token line labelled as it is.

rec 5 — Before shipping, have the founder run one tiny interactive session (cheapest model, a few cents) that does a prompt, `/clear`, a prompt, exit, then `--continue` and exit, to confirm two things.
- Does the pre-`/clear` transcript get its own cost-state line? If not, spend before a `/clear` is lost, and the receipt must say so.
- Does the resume baseline subtract cleanly?

I did not run this; it is paid.

rec 6 — Use the hook's absolute `transcript_path` instead of `find_session_jsonl`'s hard-coded `~/.claude/projects` plus a slug that only replaces `/`; if it must stay as a fallback, fix the slug and honour `CLAUDE_CONFIG_DIR`.
The fallback slug should replace every character that is not a letter or digit, and hash names over 200 characters.

**Sources read**
- `/Users/suman/.claude.json`: only the `projects[...]` `last*` keys, lines 1420–2477; no account or oauth values used.
- `/Users/suman/.claude/projects/-Users-suman-playground-rudra/` (file listing; `9b221da1-6b2e-4821-9945-31712ccfabc2.jsonl` searched for cost keys and line types only).
- `/Users/suman/.claude/projects/-Users-suman-playground-vajra/{c6391916…,60ab3ed6…,69ecb30e…,8ff66ab8…,f12d9aa1…,3d63ece7…}.jsonl` (searched for cost-state, timestamps and version only).
- `/Users/suman/playground/vajra/src/meter/mod.rs` (lines 595–654).
- https://code.claude.com/docs/en/agent-sdk/cost-tracking
- https://code.claude.com/docs/en/statusline
- https://code.claude.com/docs/en/hooks
- https://code.claude.com/docs/en/sessions
- https://github.com/kontourai/station/issues/3320 (resume double-count)
- https://gist.github.com/samkeen/dc6a9771a78d1ecee7eb9ec1307f1b52 (`~/.claude.json` layout, from search snippet only)
- https://github.com/anthropics/claude-code/issues/28837 (concurrent `~/.claude.json` corruption, from search snippet only)
- https://github.com/StormKiln/headstate/pull/1227, https://github.com/evolv3ai/weawr/pull/13 and https://github.com/SergeiKireevDev/oyster/pull/65: third-party tools reading cost-state; no lifecycle detail.

## Handoff Delta
- `+` new: first researcher handoff for this session (9643 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
