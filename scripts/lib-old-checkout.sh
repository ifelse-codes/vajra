#!/usr/bin/env bash
# S187 (S185 N7): the old-version checkouts verify and demo scripts make, in ONE known folder.
#
# A verify script checks each fix at the commit its session started from, in a `git worktree` of that
# commit. It removes the worktree on exit — but a run that is killed (the close gate's 600 s bound,
# a hang, ^C twice) never reaches its trap, and the checkout stays: 11 were found on 2026-10-04, each
# in its own `mktemp -d` folder, 4 still registered as worktrees. Here every checkout is named
# <owning pid>-<sha> under $VAJRA_OLD_CHECKOUTS, and each new one first clears those whose owner is
# gone — so a killed run's leftover is removed by the next run, and the folder says where to look.
#
#   . scripts/lib-old-checkout.sh
#   OLD=$(vajra_old_checkout b10a1a6) || exit 1        # path of a detached checkout of b10a1a6
#   trap 'vajra_old_checkout_remove "$OLD"' EXIT

VAJRA_OLD_CHECKOUTS="${VAJRA_OLD_CHECKOUTS:-${TMPDIR:-/tmp}/vajra-old-checkouts}"
VAJRA_OLD_CHECKOUTS="${VAJRA_OLD_CHECKOUTS%/}"

# Remove every checkout in the folder whose owning process is gone. A pid that was reused keeps its
# leftover one run longer — never the other way round (a live run's checkout is never removed).
# S187 cold review rec 4: only a folder named <pid>-<hex sha> that IS a worktree (a `.git` file) is
# touched, so a folder pointed at by VAJRA_OLD_CHECKOUTS that holds anything else is left alone; and a
# pid we may not signal (EPERM — another user's process) counts as alive.
vajra_old_checkout_sweep() {
  local d name pid err
  for d in "$VAJRA_OLD_CHECKOUTS"/*; do
    [ -d "$d" ] && [ -f "$d/.git" ] || continue
    name="${d##*/}"
    printf '%s' "$name" | grep -cE '^[0-9]+-[0-9a-f]{7,40}$' >/dev/null || continue
    pid="${name%%-*}"
    err=$(kill -0 "$pid" 2>&1) && continue
    case "$err" in *ermitted*) continue ;; esac
    git worktree remove --force "$d" >/dev/null 2>&1 || rm -rf "$d"
    echo "[vajra] cleared a leftover old-version checkout (its run was killed): $d" >&2
  done
  git worktree prune >/dev/null 2>&1 || true
}

# vajra_old_checkout SHA [OWNER_PID] → prints the checkout's path. OWNER_PID defaults to the calling
# script ($$ — in a `$( … )` it is still the script, not the subshell).
vajra_old_checkout() {
  local sha="$1" owner="${2:-$$}" path
  mkdir -p "$VAJRA_OLD_CHECKOUTS" || return 1
  vajra_old_checkout_sweep
  path="$VAJRA_OLD_CHECKOUTS/$owner-$sha"
  git worktree add --detach "$path" "$sha" >/dev/null 2>&1 || return 1
  printf '%s\n' "$path"
}

vajra_old_checkout_remove() {
  [ -n "${1:-}" ] || return 0
  git worktree remove --force "$1" >/dev/null 2>&1 || rm -rf "$1"
  git worktree prune >/dev/null 2>&1 || true
}
