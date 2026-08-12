# Backend: OpenCode (task tool)

Concrete tool calls for spawning council judges using OpenCode's native `task` tool. This is the **first-class backend for OpenCode environments**.

**When detected:** `task` tool is available AND `TeamCreate` and `spawn_agent` are NOT available in the tool list.

---

## How OpenCode Differs from Claude/Codex Backends

| Aspect | Claude/Codex | OpenCode |
|--------|-------------|----------|
| Spawn primitive | `TeamCreate`+`Task`, `spawn_agent`, `codex exec` | `task(subagent_type="...", ...)` |
| Model selection | Explicit via env var (`COUNCIL_CLAUDE_MODEL`, etc.) | **Inherited** from the parent agent |
| Inter-agent messaging | `SendMessage`, `send_input` | Not available |
| Cleanup | `TeamDelete`, `close_agent`, `TaskStop` | Auto-terminating — no explicit cleanup needed |
| Parallelism | Multiple tool calls in one message | Multiple `task()` calls in one message |

---

## Pre-Flight

Before spawning judges, verify:

1. `task` tool is callable — it is in every OpenCode session
2. Output directory exists: `mkdir -p .agents/council` (use Bash tool)
3. Agent count: `judges * (1 + explorers) <= MAX_AGENTS (12)`
4. **`--debate` is unavailable** — no inter-agent messaging. If `--debate` is set, emit:
   ```
   Warning: --debate is not supported in OpenCode (no agent-to-agent messaging).
   Falling back to single-round review.
   ```
5. **`--mixed` is unavailable** — no Codex CLI. If `--mixed` is set, emit:
   ```
   Error: --mixed is not supported in OpenCode (no Codex CLI).
   Remove --mixed or use --deep for 3 judges instead.
   ```

---

## Spawn: Judges in Parallel

Spawn all judges in a **single message** using multiple `task()` calls. They execute in parallel.

### Validate / Research (independent judges with file write access)

```python
task(
    subagent_type="general",
    description="Council judge-1",
    prompt="You are judge-1.\n\nPerspective: Correctness & Completeness\n\n<PACKET>\n...\n</PACKET>\n\nWrite your verdict to .agents/council/2026-02-17-auth-judge-1.md\nFollow the schema: verdict (PASS/WARN/FAIL), confidence (HIGH/MEDIUM/LOW), findings, recommendation."
)

task(
    subagent_type="general",
    description="Council judge-error-paths",
    prompt="You are judge-error-paths.\n\nPerspective: Error Paths & Edge Cases\n\n<PACKET>\n...\n</PACKET>\n\nWrite your verdict to .agents/council/2026-02-17-auth-judge-error-paths.md"
)
```

Use `subagent_type="general"` — judges need to write files (verdict files to `.agents/council/`). The `general` subagent has full tool access including write/edit.

### Explorers (read-only research agents)

```python
task(
    subagent_type="explore",
    description="Research explorer-1",
    prompt="Thoroughly investigate: authentication patterns in this codebase\n\nWrite findings to .agents/research/2026-02-17-auth-explorer-1.md"
)
```

Use `subagent_type="explore"` for read-only exploration — it cannot modify files, which is appropriate for research.

---

## Wait: Collect Results

The `task()` tool returns a result when the subagent finishes. In OpenCode, all `task()` calls in a single message are dispatched in parallel, and results arrive asynchronously.

### Timeout handling

If `COUNCIL_TIMEOUT` (default: 120s) is exceeded for a judge:
1. Check if their output file exists: `Read(".agents/council/...")`
2. If file exists → use their verdict (they finished but result delivery was delayed)
3. If no file → judge failed silently. Proceed with remaining judges, note in the report.
4. Never wait indefinitely — enforce the timeout and move on.

Example wait loop:

```
# Results come back from parallel task() calls
# For each result:
#   1. Read the judge's verdict file:
Read(".agents/council/2026-02-17-auth-judge-1.md")
#   2. Extract JSON verdict from the file
#   3. Proceed to next judge
```

### Grace period

After all task results are received, wait an additional 5s for any slow file writes, then check for missing files.

---

## Consolidation (Inline)

The lead (this agent) consolidates inline — no separate chairman agent:

1. Read each judge's output file with `Read()`
2. Extract `verdict`, `confidence`, `findings`, and `recommendation`
3. Apply consensus rules (see `consensus-and-output.md`)
4. Synthesize the report
5. Write to `.agents/council/YYYY-MM-DD-<type>-<target>.md`

---

## No Debate Mode

OpenCode's `task` tool does not support sending messages to running agents. This means:

- **`--debate` is unavailable** — judges cannot see each other's verdicts and revise
- Fallback: Run a single round, note in the report that debate was unavailable
- Alternative: The lead can simulate debate by reading all verdicts, presenting disagreements in the report, and asking the user for a final call

---

## No Mixed Mode

OpenCode has no Codex CLI equivalent. If `--mixed` is set, emit a hard error:

```
Error: --mixed is not supported in OpenCode (requires Codex CLI).
Use --deep for 3-judge review instead.
```

---

## Model Inheritance (CRITICAL)

OpenCode subagents **inherit the model from the parent agent that spawned them**. There is no way to set a different model per subagent via the `task` tool.

- If your session runs deepseek-v4-flash-free: **all judges use deepseek-v4-flash-free**
- The env vars `COUNCIL_CLAUDE_MODEL`, `COUNCIL_EXPLORER_MODEL`, and `COUNCIL_CODEX_MODEL` have **no effect** in OpenCode
- To change the model for council judges, change your session's model (not a per-council setting)
- The `--profile` flag maps to Claude models and should NOT be used in OpenCode

**Recommendation:** Keep these env vars empty to prevent confusion:

```
export COUNCIL_CLAUDE_MODEL=
export COUNCIL_EXPLORER_MODEL=
```

---

## Cleanup

No explicit cleanup needed. OpenCode `task()` subagents self-terminate after completing their prompt. No `TeamDelete`, no `close_agent`, no `TaskStop` required.

If a judge is stuck beyond the timeout, simply proceed without them — the `task()` will eventually time out on its own.

---

## Key Rules

1. **All spawns in one message** — multiple `task()` calls in a single turn = parallel execution
2. **Subagent type matters** — `"general"` for write-access judges, `"explore"` for read-only research
3. **Filesystem is the communication channel** — judges write verdict files, lead reads them
4. **Always check output files after timeout** — the task may have completed but its result delivery may have been delayed
5. **No debate, no mixed** — document in the report when these are requested but unavailable
6. **Model is inherited** — do not try to set model via env vars or flags; change the session model instead
7. **Cleanup is automatic** — no shutdown/delete steps needed
