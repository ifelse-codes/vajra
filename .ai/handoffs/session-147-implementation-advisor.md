# Session 147 — Implementation-Advisor Handoff

## Key recs for verify-session-147.sh

rec 1 — For each of the 5 roles, use awk to extract section content between its H2 header and the next H2; count non-blank non-header lines; assert >= 3. NOT a bare grep for role name.

awk idiom: `awk '/^## researcher/,/^## /' file | tail -n +2 | grep -v '^#' | grep -v '^[[:space:]]*$' | wc -l`

rec 2 — Check bold judgment label `\*\*(Changed|Noted|Hollow)\*\*` within each extracted role section, not across the whole file. Label this check struct (author typed the label, not that the judgment is correct).

rec 3 — Assert audit line count >= 100 with wc -l (not just file existence or -s).

rec 4 — Check for S148 prompt using glob array, assert count == 1 and file exists and is non-empty. On bash 3.2 an unmatched glob expands to the literal — also check `[ -f "${files[0]}" ]`.

rec 5 — Use `git diff --exit-code main -- src/` to assert no src/ changes (git, not grep). If merge-base needed: `git merge-base main HEAD` gives the right base.

rec 6 — Derive role-section presence from the awk extraction (not a separate grep for role names); implement as a loop over the 5 role names, fail on first empty section with the role name in the error message.

rec 7 — Label every check exec/struct in run_check call. Disclose judgment-label grep (rec 2) as fakest-green in script header.
