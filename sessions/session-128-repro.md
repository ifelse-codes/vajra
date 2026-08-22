# S128 step 1 — first contact, reproduced before any fix

Recorded **before** a single line was changed, in a **real empty directory**
(`git init` + `vajra init </dev/null`, 36 files scaffolded), against the
**release binary** built from `main` at `11dbabb`. Date: 2026-08-22.

No fix in this session precedes its own red.

| # | Command | Observed | Wrong because |
|---|---|---|---|
| 1 | `vajra --version` | prints the help banner · **exit 0** | there is no version flag at all |
| 2 | `vajra chek && echo RAN` | prints the help banner · **`RAN` is printed** · exit 0 | the front door fails **OPEN**: `vajra <typo> && deploy` runs deploy |
| 3 | `vajra check` | **Score: 9/11 - 2 FAILED**, one of them `varta: matches render -> vajra.varta missing` | `init` never creates `vajra.varta`, so the product fails its own health check on arrival |
| 4 | `bash scripts/verify-closeout.sh` | `line 83: summaries[@]: unbound variable` - **shell abort, no summary** | `set -u` + an empty glob array on **bash 3.2**, the macOS default shell. The L4 fail-closed layer is broken on first contact |

## Raw

```
$ vajra --version
vajra <init|claude|check|next|estimate|hook|meter>
  init              Scaffold .ai/ workflow in the current repo
  ...
exit=0

$ vajra chek && echo RAN
vajra <init|claude|check|next|estimate|hook|meter>
  ...
RAN
exit=0

$ vajra check
branch: not main               FAIL   on main - branch before working
varta: matches render          FAIL   vajra.varta missing - run `vajra check --render`
Score: 9/11 - 2 FAILED

$ bash scripts/verify-closeout.sh
scripts/verify-closeout.sh: line 83: summaries[@]: unbound variable
```

Host shell: `GNU bash, version 3.2.57(1)-release (arm64-apple-darwin25)` - the macOS default,
first on `PATH`.

## Two notes that shape the fixes

- **`branch: not main` is a TRUE and actionable failure** for someone who just ran `git init`,
  and it stays. Criterion 5 names only `vajra.varta`.
- **The scaffolded `scripts/verify-closeout.sh` is byte-identical to this repo's**
  (`include_str!`, `src/cli/init.rs:1022`). One source - fixing the repo's copy fixes every
  future scaffold. Verified with `diff`.
