# Tracked Git Hooks

Activate once per clone:

```bash
git config core.hooksPath .githooks
```

| Hook | Blocks |
|---|---|
| `pre-commit` | Commits on `main`/`master`; commits with >3 staged files; `.ai/` drift |
| `pre-push` | Pushes to `main`/`master` |

Fast local feedback only. Server-side branch protection and CI provide the real guarantees.
