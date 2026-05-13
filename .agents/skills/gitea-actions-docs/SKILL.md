---
name: gitea-actions-docs
description: Use when users ask how to write, explain, customize, secure, or troubleshoot Gitea Actions workflows (and act_runner). Ground answers in official Gitea docs first, and use GitHub Actions docs as a fallback for GitHub-compatible YAML when Gitea docs don't cover the topic.
---

Gitea Actions is similar and mostly compatible with GitHub Actions, but there are important differences. Use this skill to ground answers in official Gitea documentation first, and only fall back to GitHub docs when Gitea documentation does not cover the needed GitHub-compatible workflow syntax.

## When to Use

Use this skill when the request is about:

- Gitea Actions concepts, terminology, or product boundaries
- Enabling Actions and where workflows live (`.gitea/workflows/`)
- Workflow YAML: triggers/events, jobs/steps, matrices, concurrency, contexts, variables, secrets, and expressions
- act runner (`act_runner`): install, registration, labels, Docker/host modes, and security considerations
- Built-in job token behavior (`GITEA_TOKEN`) and `permissions:` in workflows
- Compatibility questions (what is supported or unsupported vs GitHub Actions)
- Using the Gitea CLI (`tea`) to gather context about Actions (workflows, runs, logs, secrets, variables) to answer questions grounded in real instance data

Do not use this skill for:

- Repo-specific CI failure triage where you should start from run logs and reproduction, not documentation
- General Gitea usage questions unrelated to Actions

## Workflow

### 1. Classify the request

Decide which bucket the question belongs to before searching:

- Getting started / enabling Actions
- Workflow authoring and syntax
- Runners and execution environment
- Security (secrets, tokens, permissions)
- Compatibility vs GitHub Actions
- Monitoring, logs, and troubleshooting

If you need a quick starting point, load `references/topic-map.md` and jump to the closest section.

### 2. Gather context with `tea` (Gitea CLI) when available

If the user wants debugging, verification, or instance-specific answers ("what ran?", "why failed?", "what secrets/vars exist?"), prefer collecting evidence with `tea` before relying on documentation.

Notes:

- `tea` tries to use the git repo in the current working directory for context.
- If you are not in the right repo directory, or want to override, use `--repo` (path or `owner/name`), `--remote`, and/or `--login`.

Common context commands:

- Identity and auth sanity:
  - `tea whoami`
  - `tea logins ls`
- Workflows:
  - `tea actions workflows list`
  - `tea actions workflows view <workflow>`
  - `tea actions workflows dispatch <workflow> --ref <branch-or-tag> --input key=value`
- Runs and logs:
  - `tea actions runs list --limit 30` (add filters like `--branch`, `--event`, `--status`, `--since`)
  - `tea actions runs view <run> --jobs`
  - `tea actions runs logs <run> --job <job-id>` (omit `--job` to show all)
- Secrets and variables (when the question is about configuration):
  - `tea actions secrets list`
  - `tea actions variables list`

If there is no dedicated `tea` subcommand for what you need, use `tea api` as a last resort to call the Gitea API (authenticated), but keep answers anchored in the most authoritative source available.

### 3. Search official Gitea docs first

- Treat `docs.gitea.com` as the source of truth for Gitea Actions behavior.
- Prefer pages under <https://docs.gitea.com/usage/actions>.
- Docs are versioned; if behavior may differ, ask for the user's Gitea version and act runner version.
- Search with the user's exact terms plus focused phrases like `GITEA_TOKEN`, `permissions`, `act runner`, `labels`, `secrets`, `variables`, or `compared to GitHub`.

### 4. Use GitHub docs as a fallback (with explicit compatibility checks)

- Use GitHub Actions docs for GitHub-compatible YAML reference when the Gitea docs do not cover the needed detail.
- Always validate the suggestion against Gitea compatibility docs before presenting it as supported.
- If you rely on GitHub docs, label it explicitly as fallback and include at least one Gitea link that anchors the compatibility claim (comparison/FAQ/variables/token permissions).

### 5. Open the best page before answering

- Read the most relevant page, and the exact section when practical.
- If a page appears renamed, moved, or incomplete, say that explicitly and return the nearest authoritative pages instead of guessing.

### 6. Answer with docs-grounded guidance

- Start with a direct answer in plain language.
- Include exact docs links, not just landing pages.
- Prefer Gitea links; include GitHub links only when used as fallback.
- Only provide YAML or step-by-step examples when the user asks for them or when the docs make an example necessary.
- Make inference explicit (for example: `According to Gitea docs, ...` / `GitHub docs fallback: ...` / `Inference: ...`).

## Answer Shape

Use a compact structure unless the user asks for depth:

1. Direct answer
2. Relevant docs (Gitea first; GitHub only if used as fallback)
3. Example YAML or steps, only if needed
4. Explicit inference callout, only if you had to connect multiple pages or extrapolate

Keep citations close to the claim they support.

## Common Mistakes

- Answering from memory without verifying current Gitea support
- Assuming all GitHub Actions features work on Gitea (validate with `Compared to GitHub Actions`)
- Using `.github/workflows/` paths instead of `.gitea/workflows/`
- Suggesting advanced GitHub expressions or permission scopes without checking Gitea compatibility
- Linking a landing page when a narrower page exists
- Skipping available instance evidence: if `tea` is available and the user is asking about what actually ran/failed, prefer `tea actions runs view/logs` output over guesswork

## Bundled Reference

Read `references/topic-map.md` only as a compact index of likely doc entry points. It is intentionally incomplete and should never replace the live Gitea docs as the final authority.
