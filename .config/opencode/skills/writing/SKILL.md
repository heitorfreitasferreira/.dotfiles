---
name: writing
description: "Unified writing guide. Use for any text artifact (docs, README, PR or commit text, release notes, reports, changelogs, error messages, tool and prompt descriptions, inter-agent instructions, code comments) and for substantial replies to the user. Covers two intents: de-slop (remove AI tells, state the plain version, any language) and controlled technical language (English or Portuguese shaped so a machine or non-native reader cannot misread it). Triggers: de-slop, humanize, simplify, clarify, disambiguate, plain language, apply STE100, controlled language, rewrite so an agent cannot misread this."
metadata:
  version: "1.0.0"
  custom: "true"
  languages: "en, pt-BR"
---

# writing

One guide for all text this agent produces. Two intents, two languages, one core.

- **de-slop**: remove AI writing tells. State the plain version. Any language, any prose artifact, and substantial replies to the user.
- **controlled**: text a machine or a non-native reader cannot misread. Language-specific and structural. English or Portuguese, in a strict or a flavored strength.

Both intents flag the same things most of the time: nominalization, marketing adjectives, phrasal verbs, synonym rotation, hedge stacking. Learn one core, then apply the extra structural rules the controlled intent needs.

## When to load

Load this skill when a text artifact is the deliverable or a major part of one:

- docs, README, changelog, release notes, report, PR or commit text.
- an error message, log line, tool or function description, system prompt, or inter-agent instruction.
- a substantial reply to the user where the wording itself matters.
- the user asks to de-slop, humanize, simplify, disambiguate, or apply controlled technical English or Portuguese.

Skip it for pure code changes with no prose, one-line status updates, and tool output. Those follow the always-on baseline in `instructions/writing.md`, which is a condensed subset of this skill.

## Route: intent, then language

1. Pick the intent from the request and the text type. If unsure, de-slop for prose and replies, controlled-strict for strings a program or another agent reads.
2. Pick the language. English artifact, English controlled rules. Portuguese artifact, Portuguese controlled rules. The de-slop rules and examples are language-neutral, but write them out in the artifact's language.
3. In **controlled** mode, pick the strength. Strict covers procedures, error messages, tool descriptions, inter-agent instructions, safety text. Flavored covers READMEs, PR descriptions, client-facing prose: keep the structural rules, treat the lexical rules as advisory.

The user speaking Portuguese is the pt-BR escape. When the user writes in Portuguese, reply in Portuguese and use the pt-BR rules and linter, even if this file is English.

Say which mode and strength you picked only when the user asks to see the reasoning.

## Mechanical house rules

These apply to every text and are removed on sight, no reasoning needed:

- No em dash. Use a period, a comma, or a colon.
- No semicolon in prose. Split into sentences.
- No UTF middle dot as a separator. Use a comma or a slash.

## Shared core

### The six failure modes

Every flag below is a question, not an automatic cut. One instance may stand. Repetition or clustering is the failure. Ask whether the flagged form is the exact word for the case, and whether a plain phrase does the same job.

1. **Importance inflation.** Rating words stand in for shown weight. Test: delete the rating word. If the meaning survives, it was decoration. Watch: crucial, essential, vital, paramount, cannot be overstated, plays a key role, dramatic absolutes (cannot, never, always) where plain "not" states the fact. Escape: a dependency you name in the same sentence.
2. **Manufactured drama.** Tension staged where none exists. Test: does the sentence promise a reveal the facts do not earn? Watch: "it isn't just X, it's Y", "No X. No Y. Just Z.", self-answered questions, mic-drop fragments, negation tails (", not X.") where the positive statement carries the fact.
3. **Performative register.** Prestige words chosen for sound. Test: would a plain verb say it? Watch: delve, seamless, leverage, robust, utilize, facilitate, serves as, footgun, blast radius, and improvised hyphen compounds. Escape: a term used for its literal meaning, or an established compound the audience shares (copy-on-write). Several compounds in one paragraph fail even when each passes alone.
4. **False precision.** Confident labels with no mechanism. Test: name the mechanism, source, or number, or cut the claim. Watch: diagnosis labels (race condition, memory leak) without the mechanism, "studies show", invented concept labels.
5. **Template filling.** Openings and closings on reflex. Test: does the sentence carry content or fill a slot the form expects? Watch: "In conclusion", "In today's fast-paced world", reflex triads, bold-first bullet labels.
6. **Process leakage.** The seams of production left in the artifact. Test: would this text exist if the document had always looked finished? Watch: "per review feedback", "as mentioned above", "I hope this helps", conversation residue in code comments.

`references/patterns.md` expands each mode with examples and sources. `scripts/scan.sh` finds the literal phrase-level tells at zero reasoning cost. Its hits are questions to answer per instance, not findings to report.

### Controlled structural rules (added on top of the six)

Full detail in `references/ste-en.md` (English) and `references/ste-pt.md` (Portuguese). The core rules:

English:

| Rule | Do | Do not |
|---|---|---|
| Active voice | "The agent deletes the file." | "The file is deleted" unless the actor is unknown or irrelevant |
| No phrasal verbs | "Start the job." | "Spin up the job." |
| One instruction per sentence | "Open the file. Read line 3." | "Open the file and read line 3, then check it." |
| Sentence length | at most 20 words for instructions, 25 for descriptions | Long compound sentences |
| No semicolon | separate sentences | any semicolon at all |
| Noun cluster | at most 3 stacked nouns ("fuel pump valve") | 4 or more stacked nouns |
| No ellipsis | keep subject, verb, article explicit | "Files not backed up will be lost" |
| Keep modality | "The request may have failed." | "The request failed." |
| One word, one meaning | pick one verb and reuse it | rotate synonyms for the same action |
| Verb, not noun | "Analyze the log." | "Perform an analysis of the log." |

Portuguese (pt-BR escape):

| Regra | Faca | Nao faca |
|---|---|---|
| Voz ativa | "O agente apaga o arquivo." | "O arquivo e apagado" sem agente desconhecido |
| Uma instrucao por frase | "Abra o arquivo. Leia a linha 3." | "Abra o arquivo e leia a linha 3, depois confira." |
| Tamanho da frase | ate 20 palavras em instrucoes, 25 em descricoes | Frases com subordinadas encadeadas |
| Sem ponto e virgula | frases separadas | qualquer ponto e virgula |
| Sem gerundio encadeado | "Vou enviar o relatorio." | "Vou estar enviando o relatorio." |
| Grupo nominal | ate 3 nomes | 4 ou mais nomes empilhados |
| Preserve a modalidade | "A requisicao pode ter falhado." | "A requisicao falhou." |
| Verbo, nao substantivo | "Analise o log." | "Realize uma analise do log." |
| Uma palavra, um sentido | escolha um verbo e repita | alternar "verificar", "conferir", "checar" |
| Sem perifrase vaga | "Leia o arquivo." | "De uma olhada no arquivo." |

### Modality and hedges (both intents)

Confidence is content. "may have failed" and "pode ter falhado" stay. Do not upgrade a hedge to a fact and do not add a certainty the source did not state. Both linters refuse to flag modality, including modal plus compound tenses. A shorter sentence that promotes a hedge is a different claim, not a simplification. This is the most common way a well-intentioned rewrite goes wrong.

### Rules that depend on a dictionary (controlled mode)

The lexical rules (which exact word is approved) come from ASD-STE100's ~900-word dictionary, which is English-only and not redistributable. This skill applies the principle (plainest available word, used the same way every time) and never claims dictionary compliance. For certified aerospace-grade wording, get the standard at asd-ste100.org. Portuguese has no official approved dictionary, so the pt-BR rules are an adaptation.

## Context rules

Apply the matching block in addition to the core.

**Prose**: lead with the specific fact. Vary sentence length. Cut adverbs that rate instead of measure. One metaphor per idea. If the ending restates, stop at the last real point.

**Docs**: open with what the thing does or how to run it. Prefer the imperative ("Run X" over "You can run X"). No feature gets a benefit tail it did not earn. One worked example beats three sentences of description. Headings name content, not "Overview" filler.

**PR and commit text**: the subject states the change on its own terms, readable by someone who never saw the plan. No plan labels or session-only references. Name the actual mechanism. Add a body only when the subject cannot carry the reason.

**Code comments**: necessity gate first. A comment says what the code cannot show. Delete it if the code shows it. No banner or divider comments, no value echoes beside the literal they restate, no review history. State what the code does, not what it does not do, unless the negative preempts a real misreading.

**Academic**: keep hedges that carry real uncertainty. Cite the specific study, sample, and finding, not "research suggests". Define a coined term in plain words on first use.

**Agent replying to the user**: same rules, lower ceremony. Plain and direct. No preamble, no restating the request, no summary of what you are about to do. Short. Name files and numbers. When the reply is substantial, it is an artifact and gets the full treatment.

## Guards

Precedence when rules collide: factual meaning beats quoted material beats the user's requested voice beats domain register beats any anti-slop or controlled rule.

- Facts survive every rewrite: numbers, names, dates, URLs, quotes, units, code identifiers, scope words, negations.
- Keep hedges that carry content (legal, medical, security, academic).
- Do not overcorrect into anti-slop register. Staccato punch endings, "Not X. Y." fragments, and forced bluntness are tells too.
- Quoted slop being discussed stays as quoted.
- Dose rule: one pattern once might be fine. A pattern repeated, or several together, is the failure. Write varied, specific, plain.

## Procedure

**De-slop:**
1. Name the context (prose, docs, PR or commit, comments, academic, reply). Apply its block while writing.
2. Immediately before the final text, re-read the six failure modes. Rules read early fade in a long session.
3. Self-scan against the six tests. Sweep for hyphens between words and spell each compound out.
4. For an existing document, run `scripts/scan.sh file`, read the structure once for repeated shapes, then rewrite from a findings list.

**Controlled:**
1. Pick strength (strict or flavored).
2. Read the input once for meaning. Do not rewrite before you know what it must still say.
3. Run the language linter for a first mechanical pass: `scripts/lint.sh --lang en FILE` or `--lang pt`. Then work sentence by sentence against the tables.
4. Check modality before committing each rewrite. Keep any phrasing whose shortening would drop precision, and flag the trade-off. Never add a fact.

## Output format

**Default: the rewritten text and nothing else.** No preamble, no mode announcement, no violation count, no change summary. Most callers paste the result straight into a tool description, an error string, or a prompt.

The one permitted addition: if a longer phrasing was kept on purpose, add a single line after the text, prefixed `Kept as-is:`, naming the phrase and the precision it protects. Omit it when there is nothing to report.

**On request: the rule table.** When the user asks to see the reasoning ("show the diff", "which rules did it break", "explain the changes", "before/after"), output a table with columns `Rule violated | Original | Simplified`, then one line: mode, strength, and violation count. Follow it with a one-line note on anything you deliberately did not simplify and why.

## Scripts

From the skill root:

- `scripts/lint.sh [--lang en|pt|auto] [FILE...]`: dispatcher. Auto-detects the language when a file is given or text is piped in, then runs the right structural linter. For linter flags (`--json`, `--baseline N`, `--disable RULE`), call `ste-lint.py` or `pt-lint.py` directly.
- `scripts/ste-lint.py`: English structural linter. Semicolon, sentence length, phrasal verbs, nominalization, marketing adjectives, synonym rotation, dangling conjunction, passive voice, compound tenses. Advisory findings never fail the run.
- `scripts/pt-lint.py`: Portuguese structural linter. Ponto e virgula, frase longa, gerundismo, futuro perifrastico, nominalizacao, adjetivo de marketing, perifrase vaga, rotacao de sinonimos, conjuncao solta, voz passiva, locucao verbal.
- `scripts/scan.sh [FILE...]`: phrase-level slop scanner over `references/phrases.txt`. Hits are triage questions.
- Both linters never flag hedges or modality. `--selftest` asserts that "may have failed" and "pode ter falhado" pass clean.

## References

- `references/patterns.md`: every slop pattern, expanded, with sources. Load for deep audits.
- `references/phrases.txt`: the phrase list the scanner uses.
- `references/ste-en.md`: full ASD-STE100 rule summary and sources (English).
- `references/ste-pt.md`: full Portuguese adaptation and sources.
- `examples/before-after-en.md`, `examples/antes-depois-pt.md`: worked examples.
