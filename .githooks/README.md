# Tracked Git Hooks

Activate once per clone:

```bash
git config core.hooksPath .githooks
```

| Hook | Blocks |
|---|---|
| `pre-commit` | Commits on `main`/`master`; commits with >3 staged files; `.ai/` drift |
| `pre-push` | Pushes to `main`/`master`; an agent's push of a `session-NN-…` branch unless the close check is GREEN for that exact commit (S196, F127 — a person gets a note) |
| `pre-merge-commit` | A merge commit on `main`/`master` (S194, F123) |
| `reference-transaction` | An agent moving `main`/`master` to a commit `origin/<branch>` does not have — fast-forward, `reset --hard`, `branch -f`, `update-ref` (S202; a person gets a note) |

Fast local feedback only. Server-side branch protection and CI provide the real guarantees.
