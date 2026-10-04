# Session 186 — CODE: the fixes from the S185 ground truth (F113, F110, F114, F115, N1)

> **Status:** DRAFT — written by the S185 agent from the founder's picks (2026-10-04: report "approved",
> option A, F110 option b). He approves it with `vajra approve 186` in his own terminal; the gate reads the
> approval record, not this line.

## Type
session_type: CODE
- **CODE.** Max 2 assumptions · 2 retries · ~2h · 1 story (the S185 fix list) · ≤3 files per commit · new chat.

## Goal
Build the designs the S185 ground truth picked (`sessions/session-185-ground-truth.md`, Goal 0 + F114/F115 +
N1), each with a test that fails without it. If F110 (b) grows past the session, ship everything else and
split (b) into its own session — say so; do not ship half a guard.

## Deliverables
1. **F113 — `obeyed_blocks_from: N`.** A strict key in `.ai/CONSTRAINTS.yaml`; only Vajra's own file sets it
   (132); `vajra init` never scaffolds it. Absent → unchecked `obeyed:` claims WARN forever, and the warning
   says so ("this project does not block on unchecked `obeyed:` claims (no `obeyed_blocks_from:` in
   .ai/CONSTRAINTS.yaml)"). Malformed, empty or duplicated → BLOCK naming the line (never a quiet default).
   Replaces `OBEYED_JUDGMENT_FROM_SESSION` as the blocking switch (`src/obeyed/mod.rs:76, :499`); restore the
   honest comment at ~517, and make verify-132's `pre-threshold-warns-and-names-the-exemption` check the new
   words say WHY it does not block (line 241 today checks only that it says it does not block).
   The design-advisor threshold (133) keeps its number; only its printed words stop quoting Vajra's numbering
   (`src/mandate/mod.rs:428`).
2. **F110 (b) — the approvals guard reads where a redirect really writes** (`scripts/hook-approvals-guard.sh`).
   On the de-quoted copy, for each `>`, `>>`, `>|`, `&>`, `<>`, `>&word`: no next word at all (end, `;&|`) →
   not a redirect; a literal target → normalised (`//`, `./`, `..`, case) and resolved against the hook
   input's `cwd` → block only if inside `$ROOT/.ai/approvals`. **Fail closed (block as today)** on a target
   holding `$` `` ` `` `(` `{` `*` `?` `[` `~`, on `>(…)`, on any `cd`/`pushd`/`popd`/`-C`/`--chdir`/`env -C`
   in the command, on a symlink in the target's parent path. Whatever still blocks gets (a)'s message: "put
   the text in a file with the Write tool, then `git commit -F <file>`".
3. **S182 guard recs (all ADD-only):** rec 1 — `..` segments + `approvals` count as the folder in BOTH the
   Write branch and the names test; delete the "a spelling cannot step around it" comment · rec 5 — add
   `git (checkout|restore|clean|reset|stash|apply)`, `find … -delete|-exec|-execdir`, `rsync`, `curl -o`,
   `wget`, `tar`, `unzip`, `patch` to the writers and `sh`, `bash`, `zsh`, `dash`, `eval`, `source`, `xargs`
   to the interpreters · rec 2 — `merge_claude_settings` (`src/cli/init.rs:988`) pushes a matcher with only
   the missing hooks, never a hook already wired under another matcher.
4. **F114** — a fresh project's `scripts/verify-closeout.sh --ledger` with no review files prints "ledger: no
   reviewed sessions yet" and exits 0 (this repo's script and the scaffold's).
5. **F115** — verify-132's `advance-really-binds-on-an-unjudged-obeyed` fixture records a tech-lead (or a
   `tech-lead: skipped — <reason>`) so the obeyed gate gets its turn, and tests both sides of F113: no key →
   WARN and advances; `obeyed_blocks_from: 132` → blocks with `[vajra obeyed]`.
6. **N1** — every `[HOOK BLOCK]` line in `scripts/hook-pre-bash.sh` (39, 77) and `scripts/hook-pre-write.sh`
   (38, 72), and their scaffold copies, goes to stderr, so the agent sees why it was blocked.

## Acceptance
| AC | Check |
|---|---|
| AC1 | A fresh `vajra init` project at session 132 with an unjudged `obeyed:` advances with a WARN naming "does not block"; the same project with `obeyed_blocks_from: 132` refuses; `obeyed_blocks_from: x` refuses naming the line. Vajra's own repo still blocks from 132. |
| AC2 | The guard passes: a heredoc body naming the folder written to `notes.md`; `git commit -m "… .ai/approvals … <noreply@x>"`; a markdown `> quote` line. It still blocks: `echo x > .ai/approvals/y`, `echo x >> .AI//Approvals/../approvals/y`, `cd .ai && echo x > approvals/y`, `echo x > $D/y` naming the folder, `env -C .ai/approvals sh -c 'echo > x'`, `sh -c "echo >"' .ai/approvals/x'`. |
| AC3 | Every command the S182 guard (e1c348e) blocks still blocks with the new guard, except a named, listed set of proven non-writes (a corpus test, design-advisor S185 rec 11). |
| AC4 | `.ai/hooks/../approvals/x` is blocked for the Write tool and for Bash; `find .ai/approvals -delete`, `git checkout -- .ai/approvals`, `sh x.sh .ai/approvals` are blocked. |
| AC5 | `--sync-fleet` on a project whose hook is already wired under another matcher adds no duplicate (a test that fails at e1c348e). |
| AC6 | Fresh project: `bash scripts/verify-closeout.sh --ledger` exits 0 and prints the "no reviewed sessions yet" line. |
| AC7 | `bash scripts/verify-session-132.sh` is fully green, including `advance-really-binds-on-an-unjudged-obeyed`. |
| AC8 | A GT-blocked Write and a GT-blocked `git commit` reach the agent with their `[HOOK BLOCK]` reason on stderr (not "No stderr output"). |

## Design
design-significant: yes
- Cites `docs/decisions/DECISION-007-*.md` and `docs/decisions/DECISION-011-*.md`; picked in S185
  (`sessions/session-185-ground-truth.md`, design-advisor S185 recs 1–12). Land an S185/S186 addendum in each
  (rec 12) — **F113 DEVIATES from DECISION-007's S132 clause**: 132+ blocks only where the key is declared.
- F110 (b) only stops blocking redirects it can PROVE do not write into the folder — the same rule the guard
  already applies to `/dev/null` and `>&N` (line 68); anything unresolvable blocks as today (S173: guard
  changes only add; never hide text from the guard).
- This session's design-advisor checks the S185 picks against the code as it is, not re-opens them.

## Carried in
- **Founder rulings to respect:** no per-claim `obeyed:` judge (2026-10-03); Vajra's close does not run
  `cargo test` (2026-10-04); no new policing of Vajra's own paperwork (2026-09-15); obeyed claims are not a
  blocking gate for projects (2026-10-03).
- **S185 findings NOT in this session:** N2 (GT guards block work outside the project, F56 class) · N3
  checklist line (re-run the verify script of any gate touched since the last GT) · N4 (`--steps` names a
  missing approval record) · N5 (`--dogfood-age` blind to rudra) · N6 (hand-kept headers) · N7 (verify
  checkouts in one known folder). Parked: F67, non-Claude tools (F91/F94/F95), release.
- **rudra:** after merge, `vajra init --sync-fleet` in rudra ships the new guard and messages (founder runs it).

## Guardrails
- ≤3 files per commit; every fix has a test that goes red on e1c348e/8e22f16 for the NAMED reason.
- Guard: ADD-only except the listed proven non-writes (AC3). No hiding text from the guard.
- If (b) is not green with its corpus by the ~1h30 mark, stop it, ship 1 + 3–6, and split (b).

## Plan
<the S186 agent writes this after the tech-lead and design-advisor, each step citing `covers: N`>

## Delta
- `+` `obeyed_blocks_from:` key (Vajra's own CONSTRAINTS only) and its strict reader
- `+` a target-reading approvals guard with a fail-closed list; `..`, writer and interpreter additions
- `+` F114 first-run ledger fix · F115 fixture rebuilt · hook block messages on stderr
- `-` `OBEYED_JUDGMENT_FROM_SESSION` as the blocking switch for every project
