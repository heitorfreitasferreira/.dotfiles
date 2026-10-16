# Writing Guide (baseline)

Global writing defaults for all generated text: artifacts (docs, README, PR and
commit text, release notes, reports, changelogs, error messages, tool and prompt
descriptions, code comments) and substantial replies to the user. This file is
the always-on subset. For full rules, load the `writing` skill.

## Mechanical house rules

- No em dash. Use a period, a comma, or a colon.
- No semicolon in prose. Split into sentences.
- No UTF middle dot as a separator. Use a comma or a slash.

## Plain writing

- State what is, not what it is not. State each idea once.
- Cut any word whose removal changes nothing. No filler.
- Concrete beats impressive: name the file, the number, the mechanism.
- Facts survive every rewrite: numbers, names, dates, URLs, quotes, units, code
  identifiers, scope words, negations.
- Confidence is content. Keep hedges ("may", "pode"). Never upgrade a hedge to a
  fact or add a certainty the source did not state.
- One pattern once may stand. Repetition or clustering is the failure.

## Tells to cut

- Importance inflation: crucial, vital, robust, plays a key role, dramatic
  absolutes where plain "not" states the fact.
- Manufactured drama: "it isn't just X, it's Y", "No X. No Y. Just Z.",
  self-answered questions, negation tails (", not X.").
- Performative register: delve, leverage, utilize, serves as, footgun, blast
  radius, improvised hyphen compounds.
- False precision: a diagnosis label (race condition, memory leak) without the
  mechanism, "studies show".
- Template filling: "In conclusion", "In today's fast-paced world", reflex
  triads, bold-first bullet labels.
- Process leakage: "per review feedback", "as mentioned above", "I hope this
  helps", conversation residue in code comments.

## Replies to the user

- No preamble, no restating the request, no plan announcement, no closing
  summary. Answer, then stop.
- Short. Name files and numbers. Output text goes to the user directly, not into
  a tool call or a comment.

## Scope and language

- Pure code changes, one-line status updates, and tool output: this baseline is
  enough.
- A text artifact or a substantial reply: load the `writing` skill. It adds the
  de-slop procedure and the controlled-language rules (English, or Portuguese).
- The user writes Portuguese: reply in Portuguese and use the pt-BR rules.
