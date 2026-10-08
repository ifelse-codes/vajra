# DECISION-011 — Controls the agent cannot type

**Status:** Accepted
**Date:** 2026-09-30
**Session:** S181
**Supersedes in part:** DECISION-008 (the prose search for `**CODE**` is now only a dated fallback)
**Extends:** DECISION-007 (S169 waiver addendum, S173 launch approval), DECISION-003 (hash binding), DECISION-002

---

## Context

S180's ground truth found one root cause behind F77–F80, F84, F85 and F92: a control means something
only if the agent cannot produce it. Four of Vajra's founder controls were text the agent could write —
the `APPROVED` word in a brief, the "verified" stamp on a helper's record, `VAJRA_CLOSEOUT_WAIVER=N`
typed inline, and the session type read from prose.

## Decision

1. **Session type is one strict field.** `session_type: CODE | DOCUMENT | GROUND_TRUTH | INTERACTIVE` on
   a line of its own. Missing, unknown or conflicting fails the close gate. `INTERACTIVE` gets the CODE
   checks. A session cannot label itself `GROUND_TRUTH` off the cadence. No prose is read.
2. **Approval is a record, never words.** From the project's `session_rules_from` the gate reads
   `.ai/approvals/session-NN.json`, written by `vajra approve NN` (refused when the process carries
   `VAJRA_AGENT_MARK`, which `vajra claude` sets on everything it spawns, and when stdin is not a
   terminal), by `VAJRA_APPROVE=NN` at launch, or by `vajra claude --allow-all` (live only while that
   launch runs). The agent's Write and Bash hooks refuse to write there.
3. **A waiver names what it skips.** `VAJRA_WAIVE=<check>,…` with a required `VAJRA_WAIVE_REASON`,
   logged as launch-time (a copy `vajra claude` took from the founder's terminal) or set later.
   `VAJRA_CLOSEOUT_WAIVER=N` keeps working with a printed warning until the founder says remove it.
   No waiver path exists for `claimed-evidence-real` (unchanged, S169).
4. **A stamp is bound to its text.** The `verified:` stamp carries `text-sha:` of the findings as
   written; the mandate, obeyed and fidelity gates recompute it. This extends DECISION-003's hash binding
   from the verdict to helper records (F84).
5. **Old work keeps working, loudly.** Everything below a project's `session_rules_from` (default 181, new
   scaffolds 1) reads the old way through a dated fallback that prints its name every time it is used.

## Proof recorded for the cadence part

With `.ai/CONSTRAINTS.yaml` still saying `ground_truth_next_session: 180` and `sessions/session-180-ground-truth.md`
present, session 181 is NOT a review-only session and session 185 IS — with no edit to the key
(`tests/gt_cadence_shared.rs`, and the old-vs-new Stop-hook check in `scripts/verify-session-181.sh`). A passed
override with no report rolls forward to the next multiple of 5 and says so at session start, prompt submit,
the Stop hook and both close gates.

## Limit — stated where a reader will see it

Bar-raising, **not tamper-proof.** The agent runs as the same OS user. It can strip the mark
(`env -u`), fake a terminal, write the record with a shell path the hook does not match, set both waiver
variables, or re-record its own text through `vajra next --role` and receive a fresh stamp for text the
helper never wrote. What the controls buy: the easy paths are closed, every use is labelled, and the
trail is a file in git a reviewer can read. ~~Scaffolded projects do not yet get the Write/Bash hooks that
guard `.ai/approvals/`.~~ (S182: they do — see the addendum.)

## Alternatives rejected

- Signed approvals or stamps — need a key store the agent could also read (DECISION-003 rejected the same).
- A second environment-variable scheme — the existing `VAJRA_ALLOW_COMMIT` refuse-agent-set pattern is reused.
- Removing the old waiver now — the founder has not said to.
- Guessing the type from more keywords — still text guessing.

---

## S182 addendum — the controls reach existing projects (2026-10-01)

**Follows** this record; **deviates from** DECISION-007's S136 addendum (`--sync-fleet` touches rendered files only).

1. **One guard, one source.** `scripts/hook-approvals-guard.sh` checks Bash commands and Edit/Write/
   MultiEdit/NotebookEdit paths. Vajra's own `hook-pre-bash.sh` / `hook-pre-write.sh` call it; `vajra init`
   ships the same bytes stamped as `.ai/hooks/hook-approvals-guard.sh`, registered as its own PreToolUse
   group. Its block message goes to stderr — the S181 one went to stdout, which Claude Code does not hand
   the agent on exit 2 (it saw "No stderr output").
2. **Block by whether a command can write, not on any `>`.** A command naming the folder (or `cd`-ing into
   `.ai` / the folder) blocks on any redirect left after the provable non-writes are removed (`N>&M`, `>&N`,
   `N>&-`, a redirect to `/dev/null`), a file-writing tool, or an interpreter. Everything the S181 line
   blocked still blocks except those non-writes (S173: guard changes only add); `cd .ai && echo x >
   approvals/x`, an S181 gap, is now blocked. Over-block kept: a command naming the folder that redirects
   elsewhere (`cat <folder>/x > /tmp/y`) still blocks, and says to split the read off.
3. **`--sync-fleet` wires the guard (the deviation).** A file nobody's settings run is not a guard (S129).
   `--sync-fleet` now adds Vajra's missing hook groups to an existing `.claude/settings.json` through the S44
   add-only merge — every user key and hook kept, `--dry-run` honoured, never creating the file.
4. **Report, never edit, `session_rules_from`.** With no key, `--sync-fleet` prints the exact line and
   N = `.ai/SESSION` + 1. This key in the project's `.ai/CONSTRAINTS.yaml` is never written — the founder's policy call. *(S187: the file itself may now gain missing ground-truth audits and question blocks, which no gate reads — DECISION-007 S187 addendum; this key, and every key a gate reads, is still never written.)*
5. **`--allow-all=NN` (narrows decision 2).** The record stores `session` next to `pid`; it approves session
   NN only, while that launch runs. A bare `--allow-all` is refused before anything starts; a pre-S182
   record naming no session approves nothing. Not the branch name: the agent usually types it.

**After the cold review (pass 1, ACCEPT with a mismatch):** the fd-dup strip is anchored on its right
(`>&1/../<folder>/x` writes a file and was let through), and "only add" is now CHECKED — a test runs every
listed command through the S181 hook from git and the new one. The folder is matched case-insensitively and
with quotes removed. Without jq the guard advises at L1, like every other shipped hook. A partly wired
hook group (a pre-S93 Bash group) gets only its missing entries, so `--sync-fleet` never lists a hook twice.

**Limit, unchanged in kind:** a folder path assembled at run time (`d=.ai; … $d/appr…`) or a glob
(`.ai/a*/x` onto an existing file) gets past the guard; still bar-raising, not tamper-proof. The settings
rewrite keeps the project's key order (serde_json `preserve_order`, founder yes 2026-10-01), so the diff in a
project shows only what Vajra added.

## S183 addendum — the close check lints like CI, on CI's toolchain (2026-10-03)

**Why here:** this record's rule — a project switch is one strict field in `.ai/CONSTRAINTS.yaml`, read by
exact key, never worked out from prose or YAML text — is what the scaffold half of this fix borrows. No
record covered the toolchain, so it is written here rather than in a new DECISION.

**Problem (F101).** S182 closed green on its branch, then CI failed `cargo clippy --all-targets -- -D
warnings` (clippy 1.99, `useless_format`). The close gate ran only `cargo fmt --check`, and the local clippy
was older than CI's moving `dtolnay/rust-toolchain@stable`. Adding the command alone would not have caught
it: the same command on the older clippy passes.

1. **One toolchain, written once.** `rust-toolchain.toml` pins `channel = "1.99.0"` (+ clippy, rustfmt).
   rustup obeys it locally; CI and Release run `rustup toolchain install`, which reads the same file (Release
   adds `rustup target add <target>`). No version number in any YAML. Moving to a newer Rust is one edit to
   that file, with any new lints fixed in the same commit.
2. **One lint command.** `scripts/ci-lint.sh` prints `rustc -V` / `cargo clippy -V`, FAILS when the running
   rustc is not the pinned version (a cargo outside rustup or a `RUSTUP_TOOLCHAIN` override ignores the file),
   FAILS on a missing file or a non-exact channel, then runs `cargo clippy --all-targets -- -D warnings`.
   CI runs it; Vajra's close gate runs it as `cargo-clippy-clean`.
3. **A project names its lint.** The scaffold gate reads `lint_command:` from `.ai/CONSTRAINTS.yaml`: set →
   run it, FAIL on non-zero (waivable like the other checks); `none` → N/A; missing → a WARN row in the
   results table that names the line to add. Never derived from CI files or from which files exist (S177).
   These two new rows (`project-lint-clean`, and `obeyed-judgments` for F104) show WARN and N/A as themselves,
   not under PASS (the S178 trap); the scaffold's older log-only N/A/WARN paths still record PASS (cold review). New scaffolds carry the
   line commented out; existing projects add it themselves (Vajra never writes this key into their CONSTRAINTS; S187 adds only ground-truth audits and question blocks — DECISION-007 S187 addendum).

**Rejected:** comparing the local version against "CI's" (with `@stable` nothing records CI's version — a
network call or a hand-kept copy); `dtolnay@master` with `toolchain: 1.99.0` beside the toml (two copies);
`rustup update` inside the gate (network, changes the founder's machine, still a race); command + logged
version only (leaves the S182 gap); the per-session verify script for project lint (opt-in every session);
guessing the lint from CI YAML or `Cargo.toml` (S177).

**Fakest green — stated where a reader will see it:** the agent can type `lint_command: true` or `none`
(only the diff shows it); "matches CI" means "clean on the pinned version", not on today's stable — the pin
ages until someone bumps it; `#[allow(clippy::…)]` still silences any lint. **Not checked live:** the
Release workflow's `rustup toolchain install && rustup target add` runs only on a tag (CI's runs on the PR).

## S186 addendum — F110 (b) split out; the guard only adds; a project declares its own obeyed switch (2026-10-04)

**Follows** this record's S183 rule (a project switch is one strict field in `.ai/CONSTRAINTS.yaml`, read by
exact key) for F113's `obeyed_blocks_from:` (the gate change itself is recorded in DECISION-007's S186
addendum). **Amends** the S182 addendum once (§3 below). Picked by the S185 ground truth (founder: F110 b).

1. **F110 (b) was built, reviewed twice, and SPLIT OUT by the founder (2026-10-04).** The design: block a
   redirect only when its target lands in the folder or cannot be proven not to (target read from the
   de-quoted and the written command, resolved against the hook's `cwd` with `cd -P`). Two cold reviews
   each found writes into the folder it let through that the S182 rule blocks — pass 1: a backslash-newline
   after `>`, awk's own `>`, a `cd` spelled to dodge a word match; pass 2, after fixes for those exact
   spellings: zsh's `>>!`/`>&|`/`>>|`, a hidden `cd` after `if`/`{`/`builtin`, awk by full path, a link
   made earlier in the same command. Each fix closed the spelling, not the class. **The S182 §2 rule stands
   unchanged:** a command that names the folder and redirects anywhere still blocks (F110's false blocks
   remain); the block now names the way past, `git commit -F <file>`. Lesson for the (b) session: loosening
   a text guard is a REMOVAL; it needs a class-level argument (what the shell can do with a `>`), not a
   corpus that grows one probe at a time.
2. **S182 review recs 1 and 5 — only adds.** A `..` segment next to the word `approvals`, or a hook `cwd`
   inside the folder, counts as naming it, for the Write tools and in the "names it?" test. A copy with
   backslash-newlines joined is APPENDED as extra lines — never in place of the command (S186 pass 3: in
   place, it hid `rm` behind a `#x\` comment line). The S182 word lists also read the de-quoted copy.
   Why this only adds: every S182 check is a line-by-line match over the command as written; S186 gives it
   more lines and more patterns, never different ones. The folder lookup never exits early (an
   unenterable folder once made the guard exit 1, which does not block).
   **Exit status, not just matching (passes 4 and 5).** A check that matches but cannot finish is a pass:
   `printf | grep -q` under pipefail failed open on a large command (grep quits early, printf gets
   SIGPIPE) — **the S182 guard on main and in rudra lets a ~60 KB write into the folder through this way**
   until `--sync-fleet`. Every check is now `printf | grep -c … >/dev/null` (grep reads all input; no
   temp file, unlike a here-string, which fails on a full disk). The join is one awk pass: bash 3.2's
   `${var//…/}` was quadratic in backslashes (10,000 took over 120 s, past a hook timeout). Measured on
   /bin/bash 3.2: 10–120 KB and 30,000 backslashes all exit 2 in under 0.1 s. New writers (`git checkout|restore|clean|reset|stash|apply`,
   `find … -delete|-exec…`, `rsync`, `curl -o`, `wget`, `tar`, `unzip`, `patch`) and shells (`sh`, `bash`,
   `zsh`, `dash`, `ksh`, `fish`, `eval`, `source`, `.`, `xargs`) and programs that write by their own syntax
   (`awk` and kin, editors, `sqlite3`, `php`, `lua`, …) match where a command starts — after `;&|(`, a
   backtick, a line start, `if`/`then`/`do`/`!`/`{`, `NAME=value`, a wrapper (`xargs`, `env`, `exec`,
   `command`, `builtin`, `nohup`, `sudo`, `time` — not `timeout`, `nice` or others yet), with or without a path in front — so `hook.sh` or the word "source" in prose is not one.
3. **Corrected — "`--sync-fleet` never lists a hook twice" was false (S182 review rec 2).** A hook wired
   under a matcher that covers the template group's tools (`Bash|Edit|Write|MultiEdit` covers `Bash`) is
   wired; the merge adds only the missing hooks. A matcher that is not a plain `A|B` list covers nothing,
   so the hook is added rather than a tool left unguarded.

**For the (b) session, recorded:** a quote-aware tokenizer fails on one apostrophe in a heredoc; refusing
every symlink blocks macOS's `/tmp`; `realpath` is not in bash 3.2. P1–P7 are in `tests/approvals_guard.rs`.

**Limit, unchanged in kind:** a path assembled at run time, or a writer no list names with no redirect,
still gets past; the guard reads text, it is not a sandbox. A hook killed by its timeout does not block —
the guard is now linear, but a slow machine and a huge command still meet that limit somewhere.

## S188 addendum — the approvals folder: check what changed, not what the words say (2026-10-05)

**Deviates from** §2's last sentence ("The agent's Write and Bash hooks refuse to write there") for Bash: the Bash
hook no longer refuses a write, it catches one after it runs (the Write hook still refuses). **Reverses, for Bash,**
the S182 addendum §2 and the S186 addendum §1–2 — block a command by reading its text — and the S173 rule that a
guard change only adds. **Keeps** the rest of §2: only the founder's own process writes an approval record that
counts. Founder's decision, 2026-10-05: in S187 alone the text guard blocked plain reads five times (F110),
and S186's two cold reviews kept finding spellings it missed. The class-level argument S186 asked for before any
loosening: the check no longer reads the command, it reads the folder — so every write the shell can make, by any
spelling, a path built at run time, or an interpreter, changes what it sees.

1. **Before and after every AI tool call the guard sees.** PreToolUse saves the folder's state under
   `${TMPDIR:-/tmp}/vajra-approvals-UID/` (mode 700), named by a checksum of the project root plus the call's
   `tool_use_id`: the folder's own type, then each entry's name, type and `git hash-object --no-filters` hash (a
   link's target), NUL-separated. PostToolUse (the call succeeded) and PostToolUseFailure (it failed) save it again
   and compare byte for byte. Same → silent. Different → the void (2), a plain message on stderr, exit 2. On these
   two events exit 2 cannot block — the tool already ran — it is how the agent is told. The before record lives
   outside the folder and the tracked tree; the after hook never deletes it (two after runs for one call give the
   same answer); records older than a day are pruned. The after groups use exactly the Pre matcher of their
   settings file: an after event with no Pre hook would void every call.
2. **The void is a file inside the folder.** `.ai/approvals/voided.json` — gitignored, this machine's state like
   `.ai/.session-owner` — lists every record present after the change. `approved()` reads a listed record
   (`session-NN.json`, or `allow-all.launch` for the allow-all branch) as missing, comparing names lower-cased
   (macOS's disk is case-insensitive); an unreadable marker makes every approval missing. `vajra approve NN`
   rewrites `session-NN.json` and un-lists it and every `session-MM.json` with MM below NN; the launch-time writers
   un-list what they write; an empty list removes the marker; an unreadable one is rebuilt from what is present.
   Removing or editing the marker is itself a change, so the next pair re-lists everything present. Keyed on names,
   not times: a same-second approve cannot race it. `vajra next --steps` and the Analyst gate say why a record on
   disk does not count. Only record-based approvals are voided; sessions below `session_rules_from` still read the
   dated fallback.
3. **No before record → counted as a change** (L2/L3). Deleting the before record, the cheapest dodge, is caught;
   the message says Vajra could not compare. A call with no `tool_use_id` is treated the same, and the message says
   to update Claude Code. A state that cannot be saved at PreToolUse exits 0 — Vajra's hook-pre-bash.sh and
   hook-pre-write.sh skip their later checks on a non-zero exit — and the after hook counts it. **L1:** one report
   line, exit 0, no void — the report-only posture of the rest of this guard.
4. **The Bash word checks are removed** (the redirect rule, the writer, interpreter and program lists, the
   "names the folder" test). The Edit/Write/MultiEdit/NotebookEdit path block stays, unchanged, and still blocks
   before the tool runs; a write through a link the path check cannot see is caught by (1).
5. **Order with the other hooks: none assumed.** Relied on only: Claude Code starts the tool after every
   PreToolUse hook returns, and runs the after events once it ends. No other Vajra hook writes the folder.
6. **Projects.** `vajra init` ships the same bytes; `--sync-fleet` adds the PostToolUse and PostToolUseFailure
   groups through the S182 add-only merge (a project's own after hooks stay as they were). Claude Code reads hooks
   when it starts: the after check runs from the next launch — but the upgraded script is live at once, so between
   a `--sync-fleet` and that restart, Bash writes into `.ai/approvals` are neither blocked nor caught; `--sync-fleet`
   says "restart Claude Code in this project now" (cold review rec 2). The `.gitignore` line for the void reaches a new
   project; an existing project's ignore block is appended once and never again (S171), so there the void shows as
   an untracked file — named, rare.
7. **The constitution says it.** A Hard Rule in `.ai/AGENTS.md` ("Approvals are the founder's"), carried into
   every scaffold by build.rs: the AI never writes there; a change is caught after it runs and voids those
   approvals; stop and tell the founder.

**Docs facts relied on** (code.claude.com/docs/en/hooks, read 2026-10-05; Claude Code 2.1.280): PostToolUse
fires on success and PostToolUseFailure after a tool call fails; PreToolUse, PostToolUse and PostToolUseFailure
inputs all carry `tool_use_id`; exit 2 on the two after events shows stderr to Claude and cannot block; hooks fire
for subagent tool calls; matching hooks run in parallel with no order between them; hooks are read once at start.
Not documented: when PostToolUse fires for `run_in_background`. **Checked live (design-advisor rec 11, founder's yes,
2026-10-05):** a throwaway `vajra init` project, `vajra claude -p --model haiku` (Claude Code 2.1.280, $0.03), a
logger hook beside the guard in every group. `cp forged.json .ai/approvals/session-02.json; false` fired PreToolUse
then PostToolUseFailure once each, with the same `tool_use_id`; the agent received the `[vajra] CAUGHT` message
verbatim; `voided.json` listed both records; `vajra next --steps` showed ✗. `ls .ai/approvals` fired PreToolUse and
PostToolUse once each and raised nothing. Under `vajra claude` the after check ran once, not twice.

**What moves from before to after — counted, not stated.** `tests/approvals_guard.rs`
(`every_command_the_start_guard_blocked_is_caught_after_if_it_wrote`) runs the whole S181–S187 corpus for real
between a real before call and a real after call. The guard S188 started from (43305fd) blocked 76 of them before
they ran: **45 really write the folder and are now caught after they run** (the record may be changed or gone, the
approval stops counting, the founder runs `vajra approve NN` again — Vajra undoes nothing); **31 wrote nothing in
the folder and now pass** — F110's false blocks (a heredoc or commit message naming the folder, a read joined to
another command) and commands that fail or write elsewhere.

**Rejected:** one marker that voids everything until the next approve (a forged record for a later session counts
again once the founder approves this one); a void kept outside the folder (one more unwatched command deletes it);
the before record inside the folder or the tracked tree; keeping the word checks too (F110); pairing Bash only
(a Write through a link into the folder lands between pairs); Claude Code's sandbox and Vajra's own OS box
(founder, 2026-10-05); a hash crate (git is already required).

**Limit — bar-raising, not tamper-proof. Named, not closed:**
- **A gate run in the same command as the forge** reads the forged record as approved, removed afterwards or not:
  the void lands only after the command ends, when the gate has already acted (the AI is told CAUGHT, but the gate's
  pass and its side effects stand). A change undone within one command is not seen at all. The old guard blocked the
  plain spelling of both. (The sharpest gap; a later fix could have the approval reader compare the folder against
  the open before record.)
- **The void belongs to this machine** (`voided.json` is gitignored), while a caught forged record stays on disk —
  Vajra undoes nothing. If that record is committed, it counts in every other checkout: CI, a fresh clone, a `git
  worktree`, or after `git clean -fdX`.
- The before record can be edited during the command.
- A write between pairs looks like the founder: a background job (`(sleep 5; cp …) &`, `run_in_background`), what
  an interrupted command or a child it left behind writes after the call returns, a hook killed by its own timeout.
  Caught only if it lands inside a later pair; otherwise missed.
- Only this project's folder is watched: a write into another project's `.ai/approvals` (`cd ../rudra && cp …`),
  once blocked by its text, is now neither blocked nor caught.
- Tools outside the paired ones (an MCP server that writes files) are not watched.
- Pairs overlap (subagents, parallel calls): a change is reported by every open pair, sometimes against an innocent
  command; the void is the same.
- Un-listing every session below NN means a forged record for a session still open counts again if the founder
  approves a later session before closing it.
- The founder is flagged when his `vajra approve` lands while an AI command or a background subagent's command is
  running — the message tells him to run it again; and a `git checkout`/`pull`/`stash` that moves a committed
  record counts as a change (`git checkout main && git pull --ff-only` as one command does not).
- A file's mode change (`chmod`) is not itself a change. S188's cold review (rec 1) found that a forge plus
  `chmod a-w .ai/approvals`, or a file named `--x` (read by jq as an option), stopped the void being written while
  the message said the approvals no longer counted. Fixed in-session: the names reach jq on stdin, the folder is made
  writable again first, and a void that still cannot be written (a folder replaced by a file, `chflags uchg`) is
  reported as "NOT voided — these approvals STILL count".
- The hook scripts (Stop, UserPromptSubmit, SessionStart, or a PreToolUse hook racing the save) are files the AI can
  edit, and what they write lands outside any pair (the same class as a write between pairs).

## S191 addendum — two guards loosened, each for one stated class (2026-10-08)

DECISION-011's S186 addendum set the rule: loosening a text or path guard is a REMOVAL and needs a class-level
argument. S191 loosens two guards. Each argument is here, next to that rule.

### §1 — the ground-truth Write guard lets a write outside the project through (N2)

This records the guard's outside-pass for the first time; no earlier record holds the ground-truth Write guard's
design, so nothing here amends one. Designed at S187 (`.ai/handoffs/session-187-design-advisor.md` recs 12–20),
built at S191 (`.ai/handoffs/session-191-design-advisor.md` recs 2–6).

- **Before:** during a ground truth, `scripts/hook-pre-write.sh` blocked every Write not on its allowlist — including
  a scratch note or a throwaway test file outside the project (N2, found S185, hit live S190).
- **Now:** a Write passes when the guard can PROVE the target is outside the project folder. Both the project root
  and the target's folder are resolved through every symlink (`CDPATH= cd -P -- … && pwd -P`); then the target's
  folder is walked up to `/` and any step that IS the root by device and inode (`[ "$d" -ef "$r" ]`) refuses —
  this catches spellings `cd -P` does not resolve, such as macOS's `/System/Volumes/Data/…` firmlink (found by
  S191's cold review: the first build passed an inside file spelled that way; verify row red at 64248b9). Only an absolute,
  printable-ASCII path with no `.` or `..` part qualifies — refused before the allowlist runs, which also closes
  `/proj/.ai/../src/x.rs` passing as `*/.ai/*` (open before S191). A leaf that is a link, has more than one hard
  link, or is not a plain file refuses. The compare is lower-cased on both sides (macOS disks ignore case) and needs
  a `/` boundary (`proj2` is not inside `proj`). A root that resolves to `/` or not at all refuses. Every step fails
  closed (exit 2; exit 1 does not block). A folder that does not exist yet refuses, and the message says the way
  past: `mkdir -p` it in Bash, then write again. Placement: inside the `GT_PW=1` branch, which runs after the
  approvals guard on every Write, so the approvals guard is never skipped.
- **Class-level argument:** in a ground truth, Bash blocks only commit, push and PR, so the agent can already write
  any path — inside or outside — through the shell. Letting an outside Write through gives it no write path Bash
  does not already have. The guard is a speed bump for the Write tool, not a sandbox.
- **Limits, named, not closed:** a parallel tool call can swap a checked folder for a link between the check and the
  write; "outside the folder" is not "outside the repo" (another worktree or clone of the same repo counts as
  outside); a link inside the project that points out (`/proj/vendor -> /elsewhere`) counts as outside, because the
  write really lands outside; a link on the allowlisted paths (`.ai/`, `scripts/`, …) is not checked, as before
  S191; a non-ASCII path refuses even when it is outside — but that refusal covers only the TYPED path: a symlink
  target or a project root with non-ASCII in it is folded by ASCII-only `tr`, so the inode walk is the only
  check that sees a differently-normalised spelling of an inside folder. `hook-pre-write.sh` is Vajra's own — `vajra init` ships no
  copy, so this changes nothing in a project.
- **Rejected:** walking up to the nearest folder that exists (the rest of the path goes unchecked); refusing every
  link in the path (blocks macOS `/tmp`, S186); `realpath`/`readlink -f` (not in macOS bash 3.2 / BSD); folding case
  with a Unicode table (cannot match the disk's own rules; refusing a non-ASCII TYPED path closes it for the typed path only; the inode walk covers the rest).
- **Proof:** `scripts/verify-session-191.sh` runs 21 cases (the firmlink row against 64248b9) against the real hook at the start commit and at the tip:
  four outside writes block at the start and pass now; the `..` path passes at the start and blocks now; every
  inside spelling (logical, physical, root given physically, changed case, a linked ancestor, a leaf link, a hard
  link) blocks at both.

### §2 — the one-session-per-chat guard stops reading ONE heredoc shape's body (N13)

- **Before:** `scripts/hook-session-guard.sh` read a heredoc body as command text. Writing a note that only
  mentions `git checkout -b session-NN-…` or `vajra next --advance` (`cat > notes.md <<'EOF' … EOF`) could block as
  starting the next session — it blocked S187's own TASK.md edit (N13).
- **Now:** one shape loses its body from what the guard reads (SCAN): the WHOLE command is a single `cat > PATH`,
  `cat >> PATH`, `cat <<'W' > PATH`, `cat <<'W' >> PATH`, `tee [-a] PATH` (with an optional `> /dev/null`) writing a
  heredoc whose delimiter is QUOTED (`'W'` or `"W"`) to one plain path (`[A-Za-z0-9_./-]`, an optional `~/`), and
  nothing but whitespace comes after the first line exactly equal to the delimiter. Opener and terminator lines are
  still read. Every other shape is read exactly as before: an unquoted delimiter, `<<-`, two heredocs, a pipe, `;`,
  `&&`, `$`, a backtick or quote on the opener line, anything after the terminator. EXTRA (every `$( )`, backtick,
  `eval`/`sh -c` body) is still read from the raw command and can only add a reason to block. No perl → nothing is
  removed.
- **This deviates from the S173 rule** that this guard's reading may only ever add (KNOWLEDGE, S173: a heredoc
  exception was tried and removed, "each version hid something a shell runs"). It deviates for this one guard and
  this one shape only.
- **Class-level argument (three parts):** (1) with a quoted delimiter neither bash nor zsh expands anything in the
  body — no `$( )`, backticks or variables — so the body is literal data, the same text the Write tool could write,
  and this guard never reads Write calls; (2) only the opener line can hand the body to a program, and the strict
  shape hands it only to `cat`/`tee` and one plain file; (3) nothing after the terminator rules out
  `cat > run.sh <<'W' … W` then `bash run.sh` in the same command. S173's breaks were all `$( … )`-wrapped or
  unquoted heredocs; none of them fits the shape.
- **Limits, named, not closed:** the guard trusts that `cat` and `tee` are the real programs — a shell function or
  alias of that name in the user's shell is not seen; a quoted-heredoc note whose body has a backticked or
  `$( )`-wrapped checkout still blocks through EXTRA (a false block kept on purpose — removing it is a second
  loosening); zsh is not exercised by the proof (its heredoc rules are the same for this shape). The hook ships to
  projects (`vajra init`, and `--sync-fleet` rewrites an unedited copy), so a project gets this change on its next
  sync with a binary built from S191 or later.
- **Proof:** `scripts/verify-session-191.sh` under macOS `/bin/bash` 3.2: seven declared-shape commands pass now and
  blocked at the start commit; 25 named must-block cases (the design-advisor's rec 10, one per clause) block at both;
  S173's whole list × both triggers plus three heredoc-then-run shapes (66 commands) give the SAME exit at both; with
  perl gone the declared shape still blocks; a note from another chat records no owner.
