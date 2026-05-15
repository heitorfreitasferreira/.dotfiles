---
description: Run multi-judge consensus for validation, brainstorming, or research
argument-hint: "[validate|brainstorm|research] [target]"
tools:
  task: true
  read: true
  write: true
  bash: true
  grep: true
  glob: true
---

<objective>
Load and execute the council skill — spawn parallel judges with different perspectives and consolidate into consensus.

Works for validation, research, and brainstorming. Infers task type from natural language.
</objective>

<process>
1. Load the council skill via `skill({ name: "council" })`
2. Follow the skill's instructions to execute the user's request
3. Council supports: validate, brainstorm, research, --quick, --deep, --debate, --preset, --explorers
</process>
