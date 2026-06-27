# ADR-0005 — Pre-run cost estimate

- **Status:** ✅ **Accepted** — ratified by Suman 2026-06-27.
- **Date:** 2026-06-27
- **Phase:** Code · **Session 17.**
- **Depends on:** [ADR-0004](0004-meter-receipt-design.md) (compiled-in pricing, `pricing_for()` function).

---

## 1. Context

The meter (ADR-0004) shows cost *after* a session. The budget guard enforces caps *after* a session. Neither helps the user decide *before* committing to a session. `vajra estimate` fills this gap.

---

## 2. Decisions

### 2.1 Input token estimation

**Method:** count total characters across all context files, divide by 4.

| Factor | Value | Source |
|---|---|---|
| Chars per token | 4 | Industry standard for English text (Anthropic/OpenAI docs) |
| Files counted | PACKET_FILES + VISION.md + current prompt | Same set `vajra next` loads |

**Confidence:** High. Character-to-token ratio is well-established for English prose and code.

### 2.2 Output token estimation

**Method:** multiply input tokens by a fixed 3:1 ratio.

| Factor | Value | Source |
|---|---|---|
| Output:input ratio | 3:1 | Conservative heuristic; no empirical data yet |

**Confidence:** Low. Real sessions vary widely (1:1 for Q&A, 10:1+ for code generation). The 3:1 ratio is a placeholder until historical JSONL data can replace it.

**Known weakness:** This is the dominant cost term (output pricing is 5× input pricing for Opus), so inaccuracy here has large dollar impact. The estimate should be treated as order-of-magnitude guidance, not a budget commitment.

### 2.3 Pricing

Reuses `meter::pricing_for()` (now `pub(crate)`). Defaults to Opus pricing ($15/MTok input, $75/MTok output) since Claude Code defaults to Opus.

### 2.4 Budget integration

Compares estimated total against `budget.cap_usd` from CONSTRAINTS.yaml. Prints remaining budget or a warning if estimate exceeds cap. Does not block — advisory only.

### 2.5 Command surface

`vajra estimate` — no arguments. Reads context from the current repo's `.ai/` directory. This is command #7 (the design-rule maximum).

---

## 3. Future improvements (not in scope now)

| Improvement | What it would do | When to build |
|---|---|---|
| Historical ratio | Parse past JSONL files to compute actual output:input ratio for this repo | After 5+ metered sessions exist |
| Model detection | Read model from Claude config instead of assuming Opus | When multi-model sessions are common |
| Cache estimation | Factor in prompt cache hit rates from past sessions | After cache tier data is available |

---

## 4. Cost formula

```
input_tokens  = total_chars / 4
output_tokens = input_tokens × 3
total_cost    = (input_tokens × input_price + output_tokens × output_price) / 1,000,000
```

Where `input_price` and `output_price` come from `meter::pricing_for("claude-opus-4")`.
