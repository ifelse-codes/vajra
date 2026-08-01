# Session 107 — Independent Cold Fidelity Review

**Reviewer:** independent adversarial subagent, fed ONLY the contract prompt
(`prompts/107-task-tagged-binary-release-v010.md`) + the delivery diff (`merge-base(main,HEAD)..HEAD`,
excluding `sessions/`, `prompts/`, `.ai/*` — = `release.yml` + `README.md` + the 3 scripts). Barred
from reading STATE, the summary, ROADMAP, KNOWLEDGE, or any prior review (cold). The reviewer
**executed every "proven live" claim** — downloaded all three released tarballs, ran `file` on each
binary, flipped a byte to test the sha256 gate — rather than trusting the delivery.

**Single pass = ACCEPT.** No code changes required. The findings below are honest, pre-disclosed
residuals **within** the ACCEPT, not defects. Nothing was patched after the verdict (a post-ACCEPT edit
would invalidate the input attestation and require re-review).

## Fidelity map (reviewer's verdict per requirement)

| AC | Requirement | Verdict | Evidence (reviewer-verified) |
|----|-------------|---------|------------------------------|
| AC1 | `v0.1.0` GH release with all 3 tarballs + `.sha256` | SHIPPED | `gh release view v0.1.0 --json tagName,assets` → tag `v0.1.0`, 6 assets (`vajra-{aarch64-apple-darwin,x86_64-apple-darwin,x86_64-unknown-linux-gnu}.tar.gz` + each `.sha256`), all `state:uploaded` |
| AC2 | Release smoke: download host tarball → verify sha256 → init→next; exits non-zero on any failure | SHIPPED | PASS live: `VAJRA_SMOKE_SOURCE=release VAJRA_SMOKE_RELEASE_TAG=v0.1.0 … install-smoke.sh` → 11 checks, `SMOKE PASS`, exit 0 (~78s). FAIL-CLOSED: nonexistent tag → `download-tarball FAIL` (curl 404) → `SMOKE FAIL`, exit 1. sha256 is REAL: byte-flip (`dd seek=100`) → `did NOT match`, exit 1 |
| AC3 | README un-marks prebuilt (real cmd); crates.io + brew stay NOT YET PUBLISHED; no faked paths | SHIPPED | "No Rust? Download a prebuilt binary" + live `curl …/releases/latest/download/vajra-aarch64-apple-darwin.tar.gz \| tar xz`; crates.io + brew still `# NOT YET PUBLISHED`. `latest` one-liner verified end-to-end (resolves to v0.1.0) |
| AC4 | `cargo test --lib` green; no pipeline-station logic changed | SHIPPED | `cargo test --lib` → 296 passed, 0 failed. Diff name-only = release.yml + README + 3 scripts — **no `src/`** |
| AC5 | Nothing published to crates.io | SHIPPED | No `cargo publish` anywhere; release.yml only uploads tarballs via `softprops/action-gh-release`. Sole outward artifact = git tag + GH release |
| AC6 | Independent cold review → ACCEPT, attested | SHIPPED | This review |

## release.yml scrutiny (x86_64-apple-darwin → macos-latest cross-compile)

**Sound; the wrong-architecture risk is disproven by direct inspection.** Proper rustup cross-compile
(`targets: ${{ matrix.target }}` + `cargo build --target x86_64-apple-darwin` on Apple Silicon). The
reviewer downloaded all three tarballs and ran `file`:
- `aarch64-apple-darwin` → `Mach-O 64-bit executable arm64` ✓
- `x86_64-apple-darwin` → `Mach-O 64-bit executable x86_64` ✓ (genuine x86_64, not a mislabeled arm64)
- `x86_64-unknown-linux-gnu` → `ELF 64-bit … x86-64` ✓

## Findings (disclosed residuals — within ACCEPT)

- **FAKEST GREEN — two of the three binaries are proven only by architecture + checksum, never by
  execution.** The README sends Intel-Mac and Linux users to the x86_64 tarballs, but no instrument
  *ran* them: the smoke tests only the host-platform tarball (aarch64 here), and the cross-compiled
  x86_64 macOS binary cannot run on the arm64 CI runner. `file` confirms correct arch and sha256 passes,
  so runtime failure is unlikely for a straightforward Rust cross-compile — but "an Intel-Mac stranger
  can install *and run*" is asserted, not executed. **Within contract** (AC2 scopes to "host-platform
  tarball"; demo case 4 flags the real download as informational) — honest, but it is the hollow spot.
- **The blocking close-gate omits the positive live download.** `verify-session-107.sh` + the demo's
  gating cases are offline (grep release-mode code, assert the 404→exit-1 fail-closed path); the AC2
  *pass* direction is deliberately left out "since a close-gate must not depend on the network." So the
  green gate alone never proves the positive path — the reviewer re-derived it live (no stale-green).
- **sha256 is integrity-in-transit, not tamper-proof.** The `.sha256` ships from the same release, so it
  catches corruption/truncation (verified) but not a maliciously re-published release. Standard for this
  mechanism; the contract only asked for corruption detection.

No defect breaks any acceptance criterion. All six SHIPPED with reviewer-run evidence.

**Review-Inputs-SHA:** 836cdfec4c53d07eba7740d74acc584589421241cf85afdb028cc8bb010b9d54

**Verdict:** ACCEPT
