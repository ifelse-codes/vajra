# Session 49 — Obedience baseline (the yardstick for the S48 number)

**Snapshot:** 2026-07-07 · **Source:** `~/.claude/projects/-Users-suman-playground-vajra/*.jsonl`
**Regenerate:** `vajra meter --all` (from the repo root) — this is a point-in-time capture; the live
directory keeps growing as sessions run.

## What this is

S48 shipped `obedience % = clean ÷ (clean + blocked)` for **one** session. A single reading had no
context — is 98.9% good, or is 100% the norm and 98.9% already a smell? This baseline runs the S48 metric
over **every past transcript** of this project and shows the distribution, so a reading has a yardstick.

**Descriptive, not causal.** It says what obedience *has been*, not that Vajra *caused* it. The S48 floor
caveat carries: obedience = obeyed the **rails**, NOT proof the work was better (first rung of the ladder).

## The yardstick (the headline)

| View | n | median | range | reading |
|---|---|---|---|---|
| **All sessions** | 63 | **100.0%** | 0.0–100.0% | inflated — 12 one-call + 33 fully-clean sessions pin the median at 100% |
| **Substantive (≥10 tool calls)** | 52 | **98.9%** | 0.0–100.0% | the honest band — real working sessions |

- **A healthy Vajra session runs 95–100%.** Of the 52 substantive sessions, **51 sit in 95.2–100.0%**;
  the median is **98.9%** — i.e. the S48 live reading of 98.9% was **dead-on normal, not a smell.**
- **One outlier worth a look:** `ffd0d34d…` = **0.0%** — a **1-tool-call** session whose first action was
  blocked by `hook-copilot-loader.sh` (the co-pilot fired immediately; the session was redirected). Low n
  makes a single block dominate — read it as "blocked on the first move", not "a defiant session".
- **44 total blocks across 63 sessions.** Every block is a real Vajra rail fire: `hook-copilot-loader.sh`
  (context-surfacing, the common one) and `hook-publish-guard.sh` (the moat, e.g. the S46 isolation run).
  Blocks are *rare in a governed chat* → the distribution clusters high; take the small n seriously.

## The baseline table (worst-first — outliers on top)

```
     n=63 sessions · median 100.0% · range 0.0–100.0% · 44 total block(s) · 2 empty transcript(s) skipped
```

<details><summary>full ranked table (63 counted sessions + 2 empty skipped)</summary>

```
 session         calls  clean  blkd   obed%   top blocking hook
 ffd0d34d-dd7…       1      0     1    0.0%   hook-copilot-loader.sh
 88f4aa35-222…      62     59     3   95.2%   hook-publish-guard.sh
 af8cc700-5c5…      85     81     4   95.3%   hook-publish-guard.sh
 044d25de-ea9…      48     46     2   95.8%   hook-copilot-loader.sh
 71dcb13f-9fa…      76     73     3   96.1%   hook-copilot-loader.sh
 0a56a38b-a73…      56     54     2   96.4%   hook-copilot-loader.sh
 187649ea-5c6…      85     82     3   96.5%   hook-publish-guard.sh
 eefb0be1-980…      63     61     2   96.8%   hook-copilot-loader.sh
 1016da95-1c4…      79     77     2   97.5%   hook-copilot-loader.sh
 5dfda948-744…      41     40     1   97.6%   hook-copilot-loader.sh
 7c38d939-d79…      44     43     1   97.7%   hook-copilot-loader.sh
 d060823d-eda…      44     43     1   97.7%   hook-copilot-loader.sh
 ea7c9e91-727…      45     44     1   97.8%   hook-copilot-loader.sh
 983ebc21-58c…      97     95     2   97.9%   hook-copilot-loader.sh
 7d10282b-760…      53     52     1   98.1%   hook-copilot-loader.sh
 4b3f6bbd-82e…      59     58     1   98.3%   hook-copilot-loader.sh
 9fd2aa98-ab1…      63     62     1   98.4%   hook-copilot-loader.sh
 dcb41b23-0ec…      64     63     1   98.4%   hook-copilot-loader.sh
 e5530615-d48…      68     67     1   98.5%   hook-copilot-loader.sh
 ac8d2fb3-65d…      70     69     1   98.6%   hook-copilot-loader.sh
 64ba9ab3-5ff…      75     74     1   98.7%   hook-copilot-loader.sh
 ac556b83-847…      75     74     1   98.7%   hook-copilot-loader.sh
 431d6c80-2a4…      79     78     1   98.7%   hook-copilot-loader.sh
 e945ebd6-2b8…      79     78     1   98.7%   hook-copilot-loader.sh
 933f6198-c54…      88     87     1   98.9%   hook-copilot-loader.sh
 44ae8662-439…      91     90     1   98.9%   hook-copilot-loader.sh
 27034d07-868…      93     92     1   98.9%   hook-copilot-loader.sh
 b57a8177-d7e…      93     92     1   98.9%   hook-copilot-loader.sh
 31f65e2d-7b2…     101    100     1   99.0%   hook-copilot-loader.sh
 d227b79e-014…     106    105     1   99.1%   hook-copilot-loader.sh
 05937a35-c37…     123    123     0  100.0%   —
 … (33 fully-clean sessions at 100.0%, incl. 12 one-call sessions) …
 ────────────────────────────────────────────────────────────────────────
 n=63 sessions · median 100.0% · range 0.0–100.0% · 44 total block(s) · 2 empty transcript(s) skipped
 descriptive, not causal · small n · obedience = obeyed the rails, NOT proof the work was better (a floor, S48)
```

</details>

## Honesty read (the S47/S48 bar)

- **Descriptive, not causal.** Baseline = what obedience *has been*. It cannot attribute the number to
  Vajra vs. a well-behaved model vs. the task mix.
- **Small n, high cluster.** Blocks are rare in a governed chat → numbers pile near 100%; the all-sessions
  median is a weak statistic (use the substantive ≥10-call view: **median 98.9%**, band **95–100%**).
- **Still a floor, not a ceiling (S48 carry).** Counts only **hook-attributed** blocks. A rule silently
  worked around, or rework with no hook fire, is invisible. Obedience ≠ work-quality — that is option B,
  the harder, truer measurement the direction-B thesis still needs.
- **Blind spots inherited from S48:** coupled to CC's `hook error` wording + Vajra's `[vajra …]` marker;
  a truncated/cross-chat session (like the 0% outlier) can read extreme on tiny n.

**Bottom line:** `98.9%` now has a yardstick — it is the median of real working sessions, and the healthy
band is **95–100%**. Anything materially below 95% (or a low reading on a substantive session) is the tail
worth a look.
