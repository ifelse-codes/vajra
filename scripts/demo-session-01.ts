#!/usr/bin/env -S npx deno run --allow-run --allow-read --allow-env

const ROOT = "/Users/suman/playground/vajra";
const BOLD = "\x1b[1m";
const CYAN = "\x1b[36m";
const GREEN = "\x1b[32m";
const YELLOW = "\x1b[33m";
const DIM = "\x1b[2m";
const RESET = "\x1b[0m";

function header(text: string) {
  console.log(`${CYAN}${BOLD}══ ${text} ══${RESET}`);
}

function label(text: string) {
  console.log(`${YELLOW}${BOLD}▸ ${text}${RESET}`);
}

function code(content: string, lang = "rust") {
  console.log(`${DIM}\`\`\`${lang}${RESET}`);
  console.log(content.trimEnd());
  console.log(`${DIM}\`\`\`${RESET}`);
}

function cmdOutput(name: string, out: string, err: string, code: number) {
  console.log(`${GREEN}✓ ${name}${RESET} (exit ${code})`);
  if (out) console.log(out.trimEnd());
  if (err) console.log(`${DIM}${err.trimEnd()}${RESET}`);
}

function readFile(path: string): string {
  try {
    return Deno.readTextFileSync(`${ROOT}/${path}`);
  } catch {
    return "(file not found)";
  }
}

async function run(name: string, ...args: string[]): Promise<{ out: string; err: string; code: number }> {
  const cmd = new Deno.Command(args[0], {
    args: args.slice(1),
    cwd: ROOT,
    stdout: "piped",
    stderr: "piped",
  });
  const { code, stdout, stderr } = await cmd.output();
  return { out: new TextDecoder().decode(stdout), err: new TextDecoder().decode(stderr), code };
}

// ──────────────────────────────────────────────
console.log(`${CYAN}${BOLD}`);
console.log("  ██╗   ██╗ █████╗      ██╗██████╗  █████╗ ");
console.log("  ██║   ██║██╔══██╗     ██║██╔══██╗██╔══██╗");
console.log("  ██║   ██║███████║     ██║██████╔╝███████║");
console.log("  ╚██╗ ██╔╝██╔══██║██   ██║██╔══██╗██╔══██║");
console.log("   ╚████╔╝ ██║  ██║╚█████╔╝██║  ██║██║  ██║");
console.log("    ╚═══╝  ╚═╝  ╚═╝ ╚════╝ ╚═╝  ╚═╝╚═╝  ╚═╝");
console.log(`  Session 01 Demo — Cargo Scaffold + Engine Trait${RESET}`);
console.log();

// 1. Source tree
header("Source Tree");
const tree = `
Cargo.toml
src/
├── main.rs       ← entry point (Subcommand enum, fail-open)
├── lib.rs        ← library re-exports
├── engine/
│   └── mod.rs    ← Engine trait + types + constants
└── cli/
    ├── mod.rs    ← module declarations
    ├── hook.rs   ← stub: StubEngine → passthrough
    ├── launch.rs ← stub: spawn + wait
    └── meter.rs  ← placeholder
tests/
└── shim_stub.rs  ← G3 conformance test
`;
console.log(tree.trimEnd());

// 2. Engine trait
header("Engine Contract");
label("src/engine/mod.rs");
code(readFile("src/engine/mod.rs"));

// 3. CLI skeleton
header("CLI Skeleton");
label("src/main.rs");
code(readFile("src/main.rs"));

// 4. G3 conformance test
header("G3 Conformance Test");
label("tests/shim_stub.rs");
code(readFile("tests/shim_stub.rs"));

// 5. cargo test
header("Verification");
console.log("Running cargo test --all-targets …");
const testResult = await run("cargo test", "cargo", "test", "--all-targets");
cmdOutput("cargo test", testResult.out, testResult.err, testResult.code);
console.log();

// 6. cargo check / fmt
const checkResult = await run("cargo check", "cargo", "check", "--all-targets");
cmdOutput("cargo check", checkResult.out, checkResult.err, checkResult.code);
console.log();

const fmtResult = await run("cargo fmt", "cargo", "fmt", "--", "--check");
cmdOutput("cargo fmt --check", fmtResult.out, fmtResult.err, fmtResult.code);
console.log();

// 7. Binary demos
header("Binary Demos");

const hook = await run("vajra hook", "cargo", "run", "--", "hook");
cmdOutput("vajra hook", hook.out, hook.err, hook.code);
console.log();

const launch = await run("vajra launch", "cargo", "run", "--", "launch");
cmdOutput("vajra launch", launch.out, launch.err, launch.code);
console.log();

const meter = await run("vajra meter", "cargo", "run", "--", "meter");
cmdOutput("vajra meter", meter.out, meter.err, meter.code);
console.log();

// 8. Architecture
header("Architecture");
console.log(`
        ┌─────────────────────────────────────┐
        │   vajra [hook | launch | meter]    │
        └──────────────┬──────────────────────┘
                       │
        ┌──────────────▼──────────────────────┐
        │         src/cli/*.rs                │
        │  hook.rs ──→ StubEngine::decide()   │
        │  launch.rs ──→ spawn + wait         │
        │  meter.rs ──→ placeholder           │
        └──────────────┬──────────────────────┘
                       │
        ┌──────────────▼──────────────────────┐
        │         src/engine/mod.rs           │
        │  Engine trait + CompressionRequest  │
        │  ToolOutput + EngineDecision        │
        │  LINE_CAP = 200                     │
        │  FAIL_PASSTHROUGH_CAP = 50          │
        └──────────────┬──────────────────────┘
                       │
        ┌──────────────┴──────────────────────┐
        │  StubEngine      │  DefaultEngine   │
        │  → Passthrough   │  → Passthrough   │
        │  (G3 conformant) │  (placeholder)   │
        └──────────────────┴──────────────────┘
`.trimEnd());

console.log();
console.log(`${GREEN}${BOLD}Session 01 complete.${RESET} Session 02 adds compression heuristics.`);
