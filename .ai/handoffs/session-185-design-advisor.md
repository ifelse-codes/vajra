---
role: design-advisor
session: 185
agent: claude-code-subagent (verified: toolu_01Ua1JHQ8LSUQaAFkAegUqLq; text-sha: 20854da650407ee89dfc892dc4727458da28c9c4c15fd36c0845b080723e6960)
source-sha: 9154d7665af0aeef8e73d2ea2f1a60224eef6fc158505df9a4527a628b14dac6
captured: 2026-10-04T05:22:34Z
cost_usd: null
---

# Design-advisor handoff — session 185

Design-advisor brief, S185. Everything I cite I read: obeyed.rs:72-76 and 498-529, mandate.rs:61-72 and 415-431, approval.rs:26-43, the whole guard, init.rs:918-998, the DECISION-007 S134 and S135 addenda, and the ROADMAP S182 row.

rec 1 — F113: build your pick. Add `obeyed_blocks_from: N` to `.ai/CONSTRAINTS.yaml`. If it is absent, unchecked claims only WARN, forever. Only Vajra's own file sets it (132), and `vajra init` never scaffolds it.
Rejected: (a) reusing `session_rules_from`, because a fresh project (rules_from 1) would block from session 1, the opposite of the founder's ruling. (b) Spotting "is this Vajra's own repo?" from files or text, which is text guessing. Disclosed limit: the agent can delete the key. That is visible in the diff, and it is the same class as `session_rules_from`.

rec 2 — F113: the new parser must not copy `rules_from`'s silent fallback (approval.rs:37 drops a malformed value and uses the default). A non-integer, empty or duplicate key must BLOCK and name the line.

rec 3 — F113: when the key is absent, the WARN says "this project does not block on unchecked `obeyed:` claims (no `obeyed_blocks_from:` in .ai/CONSTRAINTS.yaml)". Bring back `pre-threshold-warns-and-names-the-exemption` against that wording, and rewrite the comment at obeyed.rs:517-519.

rec 4 — design-advisor threshold 133: leave the number and do NOT read `session_rules_from`. That key was typed (rudra: 16) to opt into S181's approval rules. Giving it a second meaning would quietly opt rudra into a new block from 16 without asking. That is more blocking for projects, against the 2026-10-03 direction. Only fix the words: mandate.rs:428 prints "threshold 133", which is Vajra's own session numbering, the F107 class.

rec 5 — F110, my call: fix it in the MESSAGE first (the S173 rule). Keep the block. The message names the way out: write the commit message with the Write tool, then run `git commit -F <file>`.
Rejected: stripping `<…@…>`, because `echo <a@b> .ai/approvals/x` is a real write. Also rejected: a quote-aware lexer that treats quoted `>` as harmless, because `sh -c "…> .ai/approvals/x"` is a write.

rec 6 — F110 target-reader, if you refuse rec 5. Your sketch, tightened:
- Read targets on the DE-QUOTED copy and skip whitespace after the operator. Your "empty target means no redirect" rule leaks: `sh -c "echo >"' .ai/approvals/x'` is a write.
- "No redirect" only when there is no next word at all (end of text or `;&|`).
- Add `<>` and `>&word` to the operators.
- Fail closed (block) on any of: a target holding `$ \` ( { * ? [ ~`; `>(…)`; any cd, pushd, popd, `-C`, `--chdir` or `env -C` in the command (`env -C .ai/approvals sh -c 'echo > x'`); any symlink in the parent path (resolve it with `cd -P`).
- Disclosed: a script that changes its own directory is out of reach, the same as DECISION-011's `d=$d/appr…`.

rec 7 — S182 rec 1, medium (a real Write-tool hole): in both the Write branch and the names test, a `..` segment plus `approvals` counts as the folder. That is ADD-only and needs no path resolver. Fix the comment at line 43, "a spelling cannot step around it".

rec 8 — S182 rec 2, low: it is mostly fixed. What remains is init.rs:988, where `_ => arr.push(group.clone())` still duplicates hooks that are already wired under a different matcher. Push the matcher with only the `missing` hooks.

rec 9 — S182 rec 5: medium for `git (checkout|restore|clean|reset|stash|apply)` and `find … -delete|-exec|-execdir`; low for rsync, curl -o, wget, tar, unzip and patch. One ADD-only regex line covers all of them.

rec 10 — add sh, bash, zsh, dash, eval, source and xargs to the interpreter list. It is ADD-only and closes `sh script.sh .ai/approvals` (no `>`, no listed writer).

rec 11 — test any guard change against a corpus: every command the S182 guard blocks must still block, except an explicitly listed set of known non-writes.

rec 12 — no new DECISION file. Add an S185 addendum to DECISION-007 (F113 and rec 4) and to DECISION-011 (F110 and the S182 carries).

**Proposed `## Design`:**

design-significant: yes

Cites DECISION-007 and DECISION-011 (both exist under docs/decisions/). This NO-CODE session picks designs that S186 builds.

F113 adds a new project-facing key, `obeyed_blocks_from:`. It is strict-parsed: if absent, the gate warns and says so; if malformed, it blocks. **This DEVIATES from DECISION-007's S132 clause**: sessions at or after 132 no longer block in every project, only where the key is declared. Rejected: reusing `session_rules_from`, and spotting the repo from text.

The design-advisor threshold stays 133 with honest wording. The S134 brownfield gap stays open on purpose.

F110 is fixed in the guard's message: the block stays. The target-reader is designed with its fail-closed rules but not built. Rejected: stripping emails, and treating quoted text as harmless (S173).

The S182 carries are all ADD-only. Both addenda record this.

## Handoff Delta
- `+` new: first design-advisor handoff for this session (4972 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
