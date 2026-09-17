# S171 — the receipt against Claude Code's own figure (derived record)

Acceptance 3 says the receipt lands within ~10% of Claude Code's own number. This is the evidence
for that sentence: two real sessions the founder ran in his own project (`rudra`), measured before
and after the one-charge-per-message fix (`src/meter/mod.rs`). Raw transcripts stay local; this
record carries only the numbers, and every one of them is reproducible with the command below.

| Session | Vajra BEFORE the fix | Vajra AFTER | Claude Code's own "Est. usage" | Gap after |
|---|---|---|---|---|
| rudra session 00 (`f6a2cec4`) | $19.33 | **$7.78** | $8.38 | **7.2% low** |
| rudra session 02 (`6ba9a831`), live receipt at exit — main transcript + the crew's subagent transcripts | (would have been ~$45) | **$19.25** | $19.56 | **1.6% low** |
| rudra session 02, main transcript only (what the command below meters) | — | $17.75 | — | the crew's own transcripts are the difference |

Why it was wrong: Claude Code writes one JSONL line per content block of an assistant reply, and
every one of those lines repeats that message's whole `usage`. Session 00: 128 usage lines, 56 real
messages. Summing the lines charged a three-part reply three times — the 2.3× the founder spotted.

Reproduce (any transcript on disk):

    cargo run --example receipt_for -- ~/.claude/projects/<slug>/<uuid>.jsonl

The regression fixture `fixtures/s171-multiblock-message.jsonl` is four lines lifted from session
00 — ids, model and `usage` only, no content: one message Claude Code wrote across three lines,
plus a different message. `a_real_multiblock_message_from_the_founders_transcript_is_charged_once`
reads it.

Honest limit: Claude Code's "Est. usage" is itself an estimate, and it was read off the status line
at exit; neither number is the invoice. What this shows is that the two now agree, where before
they differed by 2.3×.
