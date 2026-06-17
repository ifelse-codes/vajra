# ADR-0001 — Deliver v1 compression via the Claude Code `PostToolUse` hook (not a PATH-shim)

- **Status:** ✅ **Accepted** — ratified by Suman 2026-06-15 (panel-recommended same day).
- **Date:** 2026-06-15
- **Phase:** Design · **Design Session 1** (resolves the brainstorm's open *Tension B*).
- **Deciders:** Panel — Systems Architect · Principal Engineer · Agent-Practitioner; closed by Red-Team. Chair/facilitator: Claude Code. Ratifier: Suman.
- **Amends:** `VAJRA-MASTER.md` §6 (which named the *PATH-shim* as v1's delivery mechanism). **Resolves** §10 *Tension B*.

---

## 1. Context & the question

**Tension B:** by which mechanism does `vajra claude` turn a noisy `cargo test` **success** into a one-line summary *before* it reaches the model's context window?

- **Option SHIM** — launch Claude Code with a shim dir prepended to `PATH` (child-process env only). Shim binaries (`cargo`, `pytest`, `npm`, `git`…) shadow the real tools; each execs the real binary, captures stdout/stderr/exit, compresses, re-emits.
- **Option HOOK** — inject a `PostToolUse` hook on the Bash tool, **session-scoped via `claude --settings`**. After each Bash command the hook receives structured JSON and returns `hookSpecificOutput.updatedToolOutput` to **replace** the tool result the model sees.

The brainstorm left this open with two one-line positions (Practitioner→shim "it's the cross-agent rail"; Red-Team→hook "strictly better for compression alone"). Two locked constraints bound the choice: **v1's kill metric** (lower median blended-$ vs bare, *identical task success*, *zero forced `VAJRA_RAW=1`* — one dropped line the agent needed is the #1 product-killer) and the **company bet** (a later *cross-agent* governance + audit rail; compression is only ~6–8% and is explicitly proof-of-rail, not the product).

### What changed since the brainstorm (verified this session, primary source + experiment)

The brainstorm reasoned from assumptions. We verified the load-bearing facts against `code.claude.com/docs` and a live test on `claude` v2.1.177:

| Fact | Verified result | Source |
|---|---|---|
| Can `PostToolUse` truly compress (replace the result)? | **Yes** — `updatedToolOutput` *"replaces the tool's result"* | docs |
| Does replacement reduce **billed** tokens, or only the transcript? | **Reduces billed tokens** — see experiment below | experiment |
| Can a hook be injected per-session without editing user config? | **Yes** — `claude --settings <file-or-json>`, session-scoped | docs (CLI ref) |
| Does a PATH-shim intercept the Bash tool? | **Yes** for bare-name binaries (env-inherited PATH) | docs |
| Hook input / replacement schema | input `tool_response{stdout,stderr,interrupted,isImage,noOutputExpected}`; reply `hookSpecificOutput.updatedToolOutput` (same shape) | experiment |

**The experiment** (two arms, identical prompt `seq 1 5000`, only the hook differs):

| Arm | Model reported as "last line" | `cache_creation` input tokens | Cost |
|---|---|---|---|
| Passthrough hook | `5000` (raw) | 21,081 | $0.0467 |
| Replacing hook | **`COMPRESSED…SENTINEL`** | **6,734** | $0.0185 |

The model **saw the sentinel, not the raw output**, and the ~14,300-token raw payload was **never cache-written** → the replacement happens *before* context ingestion and genuinely saves dollars. (The 60% drop is a synthetic best case; realistic blended savings remain the ~6–8% from S3. This proves the *mechanism moves real dollars*, not the magnitude.)

This kills the strongest objection to the hook ("it's cosmetic / saves no real dollars") and sharpens the decisive engineering difference below.

## 2. Decision

1. **v1 delivers compression via the Claude Code `PostToolUse` hook**, injected session-scoped through `claude --settings`. **The PATH-shim is not in v1.**
2. **Compression logic is a reusable ENGINE behind the locked adapter trait** (`intercept(command, stdout, stderr, exit_code, …) -> replacement`). The hook is the *Claude Code delivery adapter*; the engine is agent-neutral.
3. **The PATH-shim is re-designated the future cross-agent governance/audit RAIL** (v2+), where its correctness requirements differ from compression's (see §4).

## 3. Rationale (decisive, ranked)

1. **Correctness at the right boundary — the kill metric.** The hook fires once at the **final tool-result boundary**, after the whole command/pipeline has run, with stdout/stderr/exit already separated as JSON. The shim sits at an **inner, per-binary boundary** and *structurally cannot tell whether its stdout feeds the agent or a downstream process* — so `cargo test | tail` feeds **compressed** bytes into `tail` and corrupts the result. That is the #1 product-killer (silent task-success regression) baked into the mechanism. The shim also has an open-ended coverage surface (absolute paths, `bash -c`, make/npm re-invocations, builtins/aliases) and must re-emit captured bytes (TTY/color/buffering/exit-code fidelity hazards). The hook has none of these; its failure modes are finite and testable.
2. **Empirically de-risked.** The mechanism is proven to reduce billed tokens with clean structured I/O — no terminal-byte parsing, fail-open is natural (return the original on any error).
3. **Minimal, ephemeral blast radius.** Session-scoped `--settings`; no persistent change to the user's machine; consistent with the locked trust posture.
4. **The ENGINE — not the delivery mechanism — is the transferable asset.** Conflating "how v1 delivers compression" with "the cross-agent rail" was a framing error in the original tension. **Compression** wants the *tool-result* boundary (hook); **governance/audit** wants the *action* boundary (a shim, or per-agent pre-hooks). Different jobs → different mechanisms → one shared trait + engine. Picking the hook for v1 forfeits nothing reusable.

## 4. What this costs — accepted trade-offs (honest)

- **v1 is proof-of-ENGINE, not proof-of-RAIL.** The cross-agent shim rail the company is bet on gets **no dogfooding in v1**. We accept this *only because* it is paired with guardrail G3 (keep the rail real in CI) and because the rail's correctness bar (audit/block actions) is genuinely different from compression's, so shim work deferred is not shim work wasted.
- **Vendor coupling to a proprietary, version-mutable contract** (`updatedToolOutput`, whose cross-version timing/stability Anthropic owes us no guarantee on). **This is the real risk** (see §6).
- **`--settings` replaces whole keys**, so a naive `hooks` injection would silently **shadow the user's own hooks** — invisible config corruption (see guardrail G2).

## 5. Guardrails this ADR MANDATES (release-blocking for v1)

- **G1 — Pin & assert the contract; fail safe.** Detect the `claude` version; verify `updatedToolOutput` behavior with a fixture/conformance test (same spirit as the JSONL schema tripwire in §7.5). On an unknown version, or an absent/changed field/shape, **fall back to passing the raw output through** — never emit a guessed replacement.
- **G2 — Merge, never clobber, settings.** Read the user's resolved hook config; compose Vajra's `PostToolUse` entry into it; **refuse to install (and fall back) if injection would shadow a user hook.** Covered by a conformance test.
- **G3 — Honest labeling + keep the rail real.** Relabel v1 as *proof-of-ENGINE*. The engine ships *behind the adapter trait* with a **stubbed shim conformance test in CI**, so the cross-agent rail is exercised (not fiction) before a 2nd agent exists.
- **G4 — Preserve the v1 invariants** (inherited, restated): `VAJRA_RAW=1` disables the hook (lossless on demand); a `[N lines hidden]` breadcrumb appears in any replaced output; **never compress small failing output** (`exit≠0` and small); fail-open everywhere.

## 6. The one condition that reverses this decision

If `updatedToolOutput`'s contract proves **unstable across Claude Code minor versions** — i.e., the kill metric fails *by construction* because replacements break or silently drop needed lines on CC updates — then **revert to shim-primary**. Tracked by the G1 conformance test in CI plus watching Claude Code releases.

## 7. Consequences (for the build)

- **v1 components:** compression **engine** (Rust lib) → **Claude Code hook adapter** (`updatedToolOutput`) → **`--settings` injector** (with the G2 merge) → token **measurement** from session JSONL → honest **meter/receipt**.
- **Adapter trait** mirrors the verified hook + `tool_response` schema, so other agents slot in later.
- **PATH-shim work** moves to the **v2 cross-agent rail** epic (governance/audit), not deleted — re-scoped.

## 8. Method note (process transparency)

Three lenses wrote **blind** (Round 1) and reached **unanimous** HYBRID(primary=HOOK). Because Round 1 was unanimous, the peer cross-examination (Round 2) was compressed; adversarial pressure was instead concentrated in a forceful **Red-Team** close that included an explicit **facilitator-bias check** (the briefing had framed shim flaws prominently) and a steelman of shim-primary. The Red-Team conceded the hook and contributed guardrails G1–G3 and the §6 reversal condition. The crux fact (does the hook save *billed* tokens) was resolved by **direct experiment**, not assumption.
