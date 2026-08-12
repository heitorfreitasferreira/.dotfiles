> Extracted from council/SKILL.md on 2026-04-11.

# Council Flags & Environment Variables

> **OpenCode note:** In OpenCode, subagents inherit the model from the parent session. Env vars like `COUNCIL_CLAUDE_MODEL`, `COUNCIL_EXPLORER_MODEL`, and `COUNCIL_CODEX_MODEL` have **no effect**. Keep them empty. Use `--deep` instead of `--mixed`. `--debate` is unavailable (no inter-agent messaging). The `--profile` flag maps to Claude models and should not be used.

## Environment Variables

| Variable | Default | Description | OpenCode |
|----------|---------|-------------|----------|
| `COUNCIL_TIMEOUT` | 120 | Agent timeout in seconds | ✅ |
| `COUNCIL_CODEX_MODEL` | gpt-5.3-codex | Override Codex model for --mixed | ❌ Sem Codex CLI |
| `COUNCIL_CLAUDE_MODEL` | sonnet | Claude model for judges | ❌ Modelo herdado do pai |
| `COUNCIL_EXPLORER_MODEL` | sonnet | Model for explorer sub-agents | ❌ Modelo herdado do pai |
| `COUNCIL_EXPLORER_TIMEOUT` | 60 | Explorer timeout in seconds | ✅ |
| `COUNCIL_R2_TIMEOUT` | 90 | Maximum wait time for R2 debate | ❌ Debate não disponível |
| `AGENTOPS_MODEL_TIER` | (none) | Global default model tier | ❌ Sem efeito |
| `AGENTOPS_COUNCIL_MODEL_TIER` | (none) | Council-specific model tier override | ❌ Sem efeito |

## Flags

| Flag | Description | OpenCode |
|------|-------------|----------|
| `--deep` | 3 judges instead of 2 | ✅ |
| `--mixed` | Add 3 Codex agents for cross-vendor consensus | ❌ Sem Codex CLI |
| `--debate` | Enable adversarial debate round (2 rounds via backend messaging) | ❌ Sem inter-agent messaging |
| `--evidence` | **Falsifiable-assertion mode** (alias: `--tdd`). Requires every finding to include `test_assertions` — concrete, mechanical checks (grep, stat, go test, etc.) that would prove the finding is real. | ✅ |
| `--commit-ready` | Also write the consolidated report to `docs/council-log/YYYY-MM-DD-<mode>-<target-slug>.md` | ✅ |
| `--timeout=N` | Override timeout in seconds (default: 120) | ✅ |
| `--perspectives="a,b,c"` | Custom perspective names | ✅ |
| `--perspectives-file=<path>` | Load named perspectives from a YAML file | ✅ |
| `--preset=<name>` | Built-in persona preset (security-audit, architecture, research, ops, code-review, plan-review, doc-review, retrospective, product, developer-experience) | ✅ |
| `--count=N` | Override agent count (max 12) | ✅ |
| `--explorers=N` | Explorer sub-agents per judge (default: 0, max: 5) | ✅ |
| `--explorer-model=M` | Override explorer model | ❌ Modelo herdado do pai |
| `--technique=<name>` | Brainstorm technique (scamper, six-hats, reverse) | ✅ |
| `--profile=<name>` | Model quality profile (balanced, budget, fast, inherit, quality, thorough) | ❌ Mapeia para Claude — não usar |
| `--tier=<name>` | Cost tier alias for --profile | ❌ Mapeia para Claude — não usar |
