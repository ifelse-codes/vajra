---
role: design-advisor
session: 192
agent: claude-code-subagent (verified: toolu_01J2imh6eDAYdN2x7sEWBnfi; text-sha: e9dec9389c8d01867d18d736ed99133c1ecb574e3e32512920e569aa5a26d01e)
source-sha: c99eca738017b666bab47f8ca2c8b501ee26d351573a9ba1e786642706730b44
captured: 2026-10-08T21:20:28Z
cost_usd: null
---

# Design-advisor handoff — session 192

Design-advisor brief for session 192 (prove the receipt; fix the transcript folder name)

Here is what I read: the prompt, the S189 addendum in ADR-0004 and its §2.2 and G10, src/meter/mod.rs (lines 140–341 and 872–930), src/cli/meter.rs:58–64, src/dispatch/mod.rs:248–271, the tech-lead handoff, and the section headers of ADR-0003. I did not re-check the facts you gave me (CC 2.1.280, the folder names on disk, the resolved cwd, the resume lines).

**Recommended marker: `design-significant: yes`.** It is not a pure fix, for three reasons:
- There is a new shared interface. Three call sites will route through one function, and the meter will honour a new env var, `CLAUDE_CONFIG_DIR`.
- There is a new fail-closed rule for names over 200 characters.
- It **deviates from a locked record**. ADR-0004 §2.2 locks `derive_cwd_slug` as `cwd.to_string_lossy().replace('/', "-")` (lines 68–71), and §2.2 also specifies a "search every project, pick the newest" fallback (line 78). This session replaces the first and rejects the second.

The prompt's current `## Design` cites only the S189 addendum. It does not say that it deviates from §2.2. The gate will not catch that, so the author has to write it.

---

rec 1 — Put ONE helper in `src/meter/mod.rs` and route all three copies through it. Pure functions take the root as an argument; thin wrappers read the env.
Why: the meter already owns transcript discovery, and `cli/meter.rs` already imports `crate::meter`. A new module would add `lib.rs` wiring and a third file to the first commit, and nothing else would own it.

Proposed shape:
```rust
/// Claude Code's folder name for a project path; None when Claude Code would shorten it (over 200).
pub fn claude_project_folder_name(project_path: &Path) -> Option<String>
/// Pure: the projects root from the values Claude Code reads.
pub fn claude_projects_root_from(config_dir: Option<&OsStr>, home: Option<&OsStr>) -> Option<PathBuf>
/// Impure: reads CLAUDE_CONFIG_DIR, then HOME.
pub fn claude_projects_root() -> Option<PathBuf>
/// Pure: <root>/<folder name>, or the named reason it cannot be named.
pub fn claude_project_dir_in(projects_root: &Path, project_path: &Path) -> Result<PathBuf, ProjectDirError> // TooLong
```
- `find_session_jsonl(start)` becomes a wrapper over `find_session_jsonl_in(projects_root, cwd, start)`.
- `cli/meter.rs::default_project_dir` and `dispatch::project_dir_for` call `claude_project_dir_in`.
- Commit split: commit 1 is `src/meter/mod.rs` alone (the helper, find_session_jsonl, unit tests). Commit 2 is `cli/meter.rs` plus `dispatch/mod.rs`.

rec 2 — The order: the meter and `vajra meter --all` use `$CLAUDE_CONFIG_DIR/projects` then `$HOME/.claude/projects`. Only dispatch keeps `VAJRA_CLAUDE_PROJECTS_DIR` first, before that same order. The meter should NOT honour `VAJRA_CLAUDE_PROJECTS_DIR`.
Why:
- The meter's job is to find the folder Claude Code actually wrote to, so its order should be exactly Claude Code's.
- `VAJRA_CLAUDE_PROJECTS_DIR` is a test seam for the provenance gates, and it is already a disclosed redirect hole (verify-session-133.sh:289–303). Letting the meter use it would widen that hole to the receipt and to ADR-0005's budget check (`billed_dollars`).
- Tests don't need it. Pure tests pass the root in. An end-to-end check in `verify-session-192.sh` can set `CLAUDE_CONFIG_DIR` in a subprocess, which tests the variable Claude Code really reads.
- dispatch must gain `CLAUDE_CONFIG_DIR` as well. A user who sets it has their subagent transcripts there, so today's provenance lookup would fail for them.
- One open detail: if `CLAUDE_CONFIG_DIR` is set but empty, copy what Claude Code's code does once you have it open. If unsure, an empty value gives no root (no receipt) rather than a guess.

rec 3 — The naming rule: keep `[A-Za-z0-9]` (`is_ascii_alphanumeric`, NOT `char::is_alphanumeric`). Every other UTF-16 code unit becomes `-`, so a character outside the BMP (an emoji) becomes `--`. Do not canonicalize the path.
Why:
- A JS `replace(/[^a-zA-Z0-9]/g,'-')` without the `u` flag works per UTF-16 unit, so Rust's per-`char` loop would undercount. This is conditional on the regex having no `u` flag. Confirm that in CC's code, and pin it with one test (`é` gives `-`, an emoji gives `--`).
- `char::is_alphanumeric` keeps `é`, which Claude Code replaces.
- You established that the cwd is already the resolved path, so canonicalizing again could only introduce a mismatch.

rec 4 — For a folder name over 200 characters: no receipt, plus a named `[vajra warn]`, for example "this project's path is longer than Claude Code's 200-character folder limit; Claude Code shortens it with a hash Vajra does not reproduce, so there is no receipt." Do not reproduce the hash, do not prefix-match, and do not use §2.2's newest-anywhere fallback. Dispatch fails closed the same way, with the same reason in its message. Test at exactly 200 and 201 characters, using CC's exact comparison (`>` or `>=`, from its code).
Why:
- Unverified recollection, check it in CC's code: the hash is computed by the runtime (Bun's hash vs a JS fallback), so even an exact port could differ between CC builds.
- A prefix match can pick a sibling project whose first 200 characters are the same, which is the wrong-number-with-a-right-label failure the guardrail forbids.
- Such paths are rare. An honest "no receipt, here is why" costs nothing.
- Rejected, could be revisited later: prefix match plus checking the candidate transcript's `cwd` field against the real cwd. It is safe but larger, and it depends on a transcript field Vajra has never pinned.

rec 5 — Turn G10's conformance test into evidence on this machine, not a cargo test. For each folder in `~/.claude/projects`, read one real transcript line's `cwd` field and check that `claude_project_folder_name(cwd)` equals the folder name. Record the match count in the summary. Unit tests use literal path → folder pairs taken from that run, plus `.`, `_`, space, `.claude` and `/private/tmp` cases.
Why:
- ADR-0004 G10 (line 345) asked for a real-CC conformance check, and it was never built. That is how the `/`-only rule survived.
- The folder `-Users-suman--claude-projects-…` alone makes the old rule red for the right reason.
- First confirm that real lines carry `cwd`. The committed fixture `cost-state-2.1.280.jsonl` has none.
- No transcript gets committed, only the counts and the pairs (founder rule, S126).

rec 6 — Settle the resume question with four `cost_state_record` tests built from hand-written lines. Reading the code, the S189 rule already gives the right answer, so these tests make that a fact on record rather than a fix.
Why: lines 240–248 never let a cost-state line set the cut; they are skipped before the cut check. A resume therefore takes as its base the last total written before the first post-launch timestamped line.
- (a) Resume, no new spend: run-1 lines dated before launch, then two cost-state lines (22.9620, startTime S). Then resume lines dated at or after launch, then two cost-state lines (22.9620, same S). Expect `ThisRun{dollars: 0.0}`, and the receipt renders ` $0.00  what this run cost — Claude Code's own figure`. Never $22.96.
- (b) Resume that appended ONLY cost-state lines (nothing dated at or after launch): expect `None`, so the receipt says "no cost from Claude Code for this run". `cost_state_warning` also returns `None`, because no versioned line comes after the cut. That is quiet, but it fails in the safe direction. Record it as known behaviour.
- (c) Resume with new spend (22.9620 then 24.4620): expect `ThisRun{1.50}` (within float tolerance), not 24.46.
- (d) Earlier records missing, startTime S before launch: expect `IncludesEarlierSpend{22.962}` with no headline figure. This may already be covered near line 1648; if so, cite it rather than duplicating it.
- If the live `--continue` run disagrees with (a) or (c), that disagreement is the Deliverable 5 fix.

rec 7 — The SessionStart session-id gap: "named, not closed" is enough this session, with the founder's call recorded in his words. Do not write an ADR-0003 addendum and do not build a hook.
Why: S189 already names the gap and records the hook as deferred (ADR-0004 lines 452 and 461–462), and nothing in this session changes that. The `/clear` live run should be recorded as live confirmation: expect "multiple sessions detected". A future addendum would have to decide three things, and each is a deviation:
- adding a hook event beyond ADR-0003 §2.1.3/§2.1.4's `PostToolUse` payload and merge algorithm;
- storing a per-launch record, which breaks the S189 line "Nothing new is stored";
- what happens when the hook did not run.
Naming those is enough; designing them is not this session's job.

rec 8 — Append an "S192 addendum" to `docs/adr/0004-meter-receipt-design.md`. Do not edit the locked text. It records:
- (i) **Deviates from §2.2**: the folder name is Claude Code's own rule from rec 3, under `$CLAUDE_CONFIG_DIR/projects`, else `$HOME/.claude/projects`. `derive_cwd_slug` and §2.2's newest-anywhere fallback are replaced and rejected. This closes S189's named limit at lines 466–468.
- (ii) The new fail-closed rule for names over 200 characters (rec 4), as a named limit.
- (iii) `VAJRA_CLAUDE_PROJECTS_DIR` is scoped to provenance and is not read by the meter (rec 2).
- (iv) A new named limit: Claude Code itself maps different paths to one folder (`/x/my.app`, `/x/my_app` and `/x/my app` all become `-x-my-app`). The exactly-one-new-transcript rule skips the concurrent case. A run that wrote no transcript while another project sharing the folder did would still read the other's transcript. Named, not closed. The `cwd`-field check from rec 4 is the deferred fix.
- (v) The live results: what the fork showed about `startTime`. Either replace line 428's "Assumed, not verified" with the evidence, or say plainly that it is still unverified. Also the resume behaviour from rec 6, replacing line 472's "stand-in only" limit with what was actually run.
Why: the gate checks only that the citation exists, not that the design obeys it. A §2.2 deviation that is not written down is the "form floor" fakest-green S67 disclosed. The share rule itself (lines 417–427) does not change, so the S189 addendum is extended, not contradicted.

---

**Proposed `## Design` body.** The author records it; I do not write it.

```
## Design
design-significant: yes
- Cites `docs/adr/0004-meter-receipt-design.md` — its S189 addendum (resolver order, fail-closed share
  rule, the named fork assumption) and **deviates from its §2.2**: `derive_cwd_slug` (replace only `/`)
  and §2.2's "newest JSONL anywhere" fallback are replaced. The transcript folder is named the way Claude
  Code names it — every UTF-16 unit outside [A-Za-z0-9] becomes `-` — under `$CLAUDE_CONFIG_DIR/projects`,
  else `$HOME/.claude/projects`. One helper in `src/meter/mod.rs` (root passed in, so tests never set env
  vars) serves the meter, `vajra meter --all` and dispatch's provenance lookup. Only dispatch keeps its
  `VAJRA_CLAUDE_PROJECTS_DIR` test override; the meter does not read it.
- A folder name Claude Code would shorten (over 200 characters, hash suffix) gets no receipt and a named
  warning — never a reproduced hash or a prefix match.
- The S189 share rule is unchanged; a resume with no new spend is pinned as $0.00 by test.
- Recorded in a new "S192 addendum" in ADR-0004 (deviation from §2.2, the 200-character limit, the
  shared-folder limit, and the live /clear, --continue and fork results).
- Rejected: three separate edits (three copies of one rule, which is how dispatch inherited the bug);
  reproducing Claude Code's long-name hash (computed by the runtime, not portable); a prefix match on long
  names (can pick a sibling project); §2.2's newest-anywhere fallback (reads another project's
  transcript); letting the meter read `VAJRA_CLAUDE_PROJECTS_DIR` (widens a disclosed redirect to the
  receipt and the budget cap); a SessionStart hook for the /clear gap (needs an ADR-0003 addendum and the
  founder's yes; named, not closed, with his call recorded).
```

**On a new record:** no new ADR file is needed. The house pattern is an addendum appended to ADR-0004 (rec 8). An ADR-0003 addendum is needed only if the founder says yes to the hook, and rec 7 says not this session.

Files referenced:
- /Users/suman/playground/vajra/prompts/192-task-prove-the-receipt.md
- /Users/suman/playground/vajra/docs/adr/0004-meter-receipt-design.md (§2.2 lines 33–78, G10 line 345, S189 addendum lines 385–475)
- /Users/suman/playground/vajra/docs/adr/0003-settings-injector-and-compression-heuristics.md (§2.1.3–2.1.4)
- /Users/suman/playground/vajra/src/meter/mod.rs (cost_state_record 226–281, cost_state_warning 289–341, headline_dollars 172–177, find_session_jsonl 874–930)
- /Users/suman/playground/vajra/src/cli/meter.rs (58–64)
- /Users/suman/playground/vajra/src/dispatch/mod.rs (254–271)
- /Users/suman/playground/vajra/scripts/verify-session-133.sh (289–303, the disclosed `VAJRA_CLAUDE_PROJECTS_DIR` redirect)
- /Users/suman/playground/vajra/.ai/handoffs/session-192-tech-lead.md

## Handoff Delta
- `+` new: first design-advisor handoff for this session (13230 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
