## Implementation brief — `vajra next --list-roles`

### 1. Where the pieces live (real file:line citations)

- **The registry (single source of truth):** `src/fleet/mod.rs:401` — `pub const ROLES: &[Role]`, nine entries, each carrying `name`, `description`, `system_prompt`, and `tools` (the tool grant). The `Role` struct is at `src/fleet/mod.rs:77-93`; `tools` is the grant field (`src/fleet/mod.rs:92`).
- **Existing pure helpers over `ROLES`:** `resolve_role` (`src/fleet/mod.rs:517`), `known_roles` (`src/fleet/mod.rs:522` — `ROLES.iter().map(|r| r.name)...join(", ")`). These are the house pattern to copy: pure, `#[cfg(test)]`-friendly functions that iterate `ROLES` and return a `String`.
- **`next` arg parse/dispatch:** `src/cli/next.rs:32` (`pub fn run(args: &[String])`). Every read-only flag is a `position(|a| a == "--flag")` probe that early-returns. The closest precedents are `--stations` (`src/cli/next.rs:88-91` → `run_stations`) and `--dogfood-age` (`src/cli/next.rs:93-95` → `run_dogfood_age`, a no-argument read-only report).
- **The `--role` branch is exact-match** (`src/cli/next.rs:97`, `a == "--role"`), so it will NOT swallow `--list-roles`. Confirmed: no footgun there.

### 2. Proposed shape — Plan step 1 (registry-side formatter, in `src/fleet/mod.rs`)

Add ONE pure function next to `known_roles` (`src/fleet/mod.rs:522`), reusing `ROLES` — do **not** introduce a second list:

```rust
/// Every registered role and its tool grant, one per line — the read-only `--list-roles` report.
/// Reads `ROLES` (the one source), so a role added there appears here with no second edit.
pub fn format_roles_listing() -> String {
    let mut s = String::new();
    for r in ROLES {
        s.push_str(&format!("  {:<22} {}\n", r.name, r.tools));
    }
    s
}
```

This mirrors `known_roles`'s "iterate `ROLES`, build a `String`" shape and the block-building style of `format_handoff_brief` (`src/fleet/mod.rs:852`). Keeping it in `fleet` (not `cli`) keeps it unit-testable without a repo/`current_dir`, matching how the module header states its pure/impure split (`src/fleet/mod.rs:15-17`).

### 3. Proposed shape — Plan step 2 (wire the flag, in `src/cli/next.rs`)

Add a dispatch probe in `run` alongside the other read-only reports. Best placement is right after the `--stations` block (`src/cli/next.rs:91`), because `--list-roles` is the same class (read-only, prints a report, exits 0), and it must sit **before** the `--role` branch at line 97 for readability (they are visually adjacent flag families):

```rust
// The fleet roster (S126+): print every registered role + its tool grant. Read-only, no arg.
if args.iter().any(|a| a == "--list-roles") {
    return run_list_roles();
}
```

and the handler, modelled on `run_stations` (`src/cli/next.rs:138`) and `run_dogfood_age` (`src/cli/next.rs:152`) — but note it needs **no repo root** (it reads a compiled-in `const`), so it is even simpler:

```rust
/// `vajra next --list-roles` — print every registered fleet role and its tool grant, read from
/// the canonical `fleet::ROLES` (S126). Read-only; nothing executes. Always exits 0 (a report).
fn run_list_roles() -> Result<()> {
    println!("=== fleet: registered roles ===");
    print!("{}", fleet::format_roles_listing());
    Ok(())
}
```

`fleet` is already imported (`src/cli/next.rs:13`). The `=== ... ===` header + `print!(body)` shape matches `run_role_handoff` (`src/cli/next.rs:288`) and the other reports.

### 4. Output format

One header line, then one indented line per role: left-padded `name` then its `tools` grant, e.g.

```
=== fleet: registered roles ===
  researcher             Read, Grep, Glob, WebSearch, WebFetch
  fidelity-reviewer      Read, Grep, Glob
  ...
  qa-specialist          Bash, Read, Grep, Glob
  ...
```

This is consistent with the two-space indentation the other `next` reports use (`  handoff:` etc. at `src/cli/next.rs:291`).

### 5. The single test that would fail without this — Plan step 1

Put it in the `fleet` test module (`src/fleet/mod.rs:896`), next to `resolve_role_knows_researcher...` (`src/fleet/mod.rs:899`). Name and assertions:

```rust
#[test]
fn format_roles_listing_covers_every_registered_role_with_its_grant() {
    let listing = format_roles_listing();
    // Every registered role appears with its OWN grant — driven off ROLES, so a new role
    // can never silently drop out of the listing (the drift footgun below).
    for r in ROLES {
        assert!(listing.contains(r.name), "listing omits role {}", r.name);
        assert!(
            listing.contains(r.tools),
            "listing omits {}'s tool grant {:?}",
            r.name, r.tools
        );
    }
    // The one executing role's Bash grant is visible (the governance fact this report exists to show).
    assert!(listing.contains("qa-specialist") && listing.lines()
        .any(|l| l.contains("qa-specialist") && l.contains("Bash")));
}
```

This follows the existing convention of iterating `ROLES` in a test so a future role cannot regress it (identical pattern to `compute_delta_names_the_producing_role_not_a_hardcoded_one` at `src/fleet/mod.rs:954` and the tool-grant test at `src/fleet/mod.rs:1097`). It fails today because `format_roles_listing` does not exist (won't compile), and would fail later if anyone hardcoded a subset instead of iterating `ROLES`.

### 6. House-pattern notes and footguns

- **The one real footgun — a hardcoded role list.** Do NOT build the listing from a literal array of role names/grants in `cli/next.rs`; that is exactly the drift `src/fleet/mod.rs:26-27` and the S114 per-role fix exist to prevent (the `tools` field was once hardcoded to the Researcher's grant). The formatter must iterate `ROLES`. The step-1 test above is what keeps it honest.
- **Grant is data, print it verbatim.** `r.tools` is already the exact string rendered into subagent frontmatter (`render_subagent_definition`, `src/fleet/mod.rs:548`). Reusing the same field means the listing can never disagree with what `vajra init` actually scaffolds.
- **Read-only, exits 0.** Match `--stations`/`--dogfood-age`: a report, never a gate. No `std::process::exit`.
- **No new top-level command.** Riding `vajra next` respects the max-7-commands cap noted throughout `run` (e.g. `src/cli/next.rs:33`, `:88`).

### 7. Plan-step mapping (for the author's `## Execution` trace)

- **Step 1** — add `fleet::format_roles_listing` + its test in `src/fleet/mod.rs`. One file. Landable alone (compiles and tests pass without the CLI wiring).
- **Step 2** — add the `--list-roles` probe + `run_list_roles` in `src/cli/next.rs`. One file. Depends on step 1's function existing.

Two files total, one per commit — well within the three-files-per-commit limit; no need to split. I am not proposing any sha; record `step N — done: <sha>` only after each commit exists (`src/coder/mod.rs` gate resolves every sha against git).

### Files relevant to this task
- `/Users/suman/playground/vajra/src/fleet/mod.rs` (registry + where step 1 lands)
- `/Users/suman/playground/vajra/src/cli/next.rs` (dispatch + where step 2 lands)

One thing I did **not** independently verify: whether a verify script (`scripts/verify-session-NN.sh`) for this session should also assert the live `vajra next --list-roles` output end-to-end. The in-code test above is the falsifiable unit; if this session's acceptance criteria call for a live CLI check too, that is a separate plan step and I would need to read the session's prompt (`prompts/126-*` or the current session's prompt) to shape it — I have not been given a numbered acceptance list here.