---
role: researcher
session: 111
agent: claude-code-subagent
source-sha: 756bdbc66ba1d8df0035ef300d93c8477d588a17c2554d05563bdfba75d44ba1
captured: 2026-08-03T11:59:27Z
cost_usd: null
---

# Researcher handoff — session 111

# anyhow — Findings Brief

**Bottom line:** `anyhow` is the de-facto standard crate for **ergonomic, type-erased error handling in Rust applications** (binaries, CLIs, top-level `main`). Use it when you just need errors to propagate with context and print nicely — not when you're building a library whose callers must match on distinct error variants. For libraries, pair it with (or replace by) `thiserror`. Current version: **1.0.x** on crates.io (dtolnay).

## 1. Core problem it solves
Idiomatic Rust error propagation with `?` requires every error to convert into a single declared error type. In an application you often don't care about a precise typed error taxonomy — you just want to bubble any error up, attach human-readable context, and print a clean report (with backtrace) at the top. `anyhow` provides one universal error type so you stop hand-writing enums and `From` impls for that purpose.

## 2. Key features
- **`anyhow::Error`** — a trait-object-like wrapper around any `E: std::error::Error + Send + Sync + 'static`. Single concrete type, so any error works with `?`. Stores a backtrace; only one pointer wide.
- **`anyhow::Result<T>`** — alias for `Result<T, anyhow::Error>`. Common `fn foo() -> anyhow::Result<T>`.
- **`Context` trait** — `.context("msg")` / `.with_context(|| ...)` on `Result`/`Option` to attach a message, producing an error chain (low-level cause preserved).
- **`bail!(...)`** — early return with a formatted error (`return Err(anyhow!(...))`).
- **`ensure!(cond, ...)`** — assert-like; returns an error if the condition is false.
- **`anyhow!(...)`** — construct an ad-hoc error from a message or format string.
- **Backtraces** — captured automatically; shown when `RUST_BACKTRACE=1` (or `RUST_LIB_BACKTRACE=1`). On stable Rust via `std::backtrace::Backtrace`.
- **Downcasting** — `err.downcast_ref::<T>()` / `downcast::<T>()` to recover the original concrete error when needed.
- **`no_std` support** via a feature flag (disable default `std` feature).

## 3. When to use it vs. alternatives
The standard "library vs application" guidance (from the crate author, dtolnay):

| Approach | Use when | Cost |
|---|---|---|
| **`anyhow`** | **Applications / binaries** — you don't need callers to distinguish error kinds; you want context + easy propagation + clean reports. | Errors are type-erased; callers can't easily `match` on variants (must downcast). |
| **`thiserror`** | **Libraries** — you want to expose a well-defined, `match`-able error enum with `#[error(...)]` messages and `#[from]` conversions, without boilerplate. | You define the error type; more upfront design. |
| **std only** (`Box<dyn Error>` or hand-rolled enums) | Zero extra deps, or very simple cases. | `Box<dyn Error>` lacks `.context()`, ergonomic backtraces, and downcast convenience; hand-rolled enums are a lot of boilerplate. |

`anyhow` and `thiserror` are complementary and by the same author: define typed errors with `thiserror` in your library, and use `anyhow` at the application boundary. They interop cleanly because a `thiserror` enum implements `std::error::Error`, so it slots into `anyhow::Error` and survives downcasting.

## 4. Minimal idiomatic example
```rust
use anyhow::{Context, Result, bail, ensure};
use std::fs;

fn load_config(path: &str) -> Result<String> {
    ensure!(!path.is_empty(), "config path must not be empty");

    let contents = fs::read_to_string(path)
        .with_context(|| format!("failed to read config from {path}"))?;

    if contents.trim().is_empty() {
        bail!("config at {path} was empty");
    }
    Ok(contents)
}

fn main() -> Result<()> {
    let cfg = load_config("app.toml")?; // error chain + backtrace printed on failure
    println!("{cfg}");
    Ok(())
}
```
Returning `anyhow::Result<()>` from `main` prints the full error chain (`Caused by:` sections) and, with `RUST_BACKTRACE=1`, the backtrace.

## 5. Trade-offs / caveats
- **Type erasure**: callers cannot `match` on error variants; they must `downcast_ref::<T>()`. This is why it's discouraged for library public APIs.
- **Backtrace visibility**: captured but only *printed* when env vars are set; forgetting `RUST_BACKTRACE=1` is a common "why no backtrace" gotcha.
- **Context discipline**: without `.context(...)` the chain can be terse; good messages are on you.
- **Not for `no_std` by default** — works but requires disabling the `std` feature and gives reduced functionality.
- **Alternatives to be aware of**: `eyre`/`color-eyre` (fork of anyhow with customizable, prettier reports) and `snafu` (typed, context-selector style). `anyhow` remains the simplest and most widely adopted default for applications.

**Note on sources:** The above reflects the well-established, stable public API of `anyhow` 1.0 as documented on docs.rs. I did not fetch the live pages in this session, so treat exact wording as from memory of the standard docs — verify at the citations below if any detail is load-bearing.

Sources:
- [docs.rs/anyhow](https://docs.rs/anyhow) — API reference (`Error`, `Result`, `Context`, `anyhow!`, `bail!`, `ensure!`)
- [crates.io/crates/anyhow](https://crates.io/crates/anyhow) — versions, README, "library vs application" guidance
- [docs.rs/thiserror](https://docs.rs/thiserror) — complementary library-error crate

## Handoff Delta
- `+` new: first researcher handoff for this session (5329 bytes of findings)
- prior stage: the session prompt (Analyst WHAT) — no prior handoff to diff against
