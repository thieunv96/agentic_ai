<!-- AI Framework Configuration — managed by ai installer -->
# Instructions for AI Framework (ML / AI Development Lifecycle)

## How to resolve `ml-*` commands (READ FIRST)

Copilot CLI and most AI assistants do **not** have built-in slash commands. When the user types a `/ml-*` or `ml-*` command (with or without the leading slash), you must resolve it yourself by reading the matching workflow file and then following that file's `<process>` section step by step.

**Command → file mapping (relative to the directory that contains this file, e.g. `.github/`):**

| Command | File to read |
|---|---|
| `/ml-discuss [N]` | `ml/workflows/ml-discuss.md` |
| `/ml-plan [N]` | `ml/workflows/ml-planning.md` |
| `/ml-implement [N]` | `ml/workflows/ml-implement.md` |
| `/ml-test [N]` | `ml/workflows/ml-test.md` |
| `/ml-doc [N]` | `ml/workflows/ml-doc.md` |
| `/ml-report [type]` | `ml/workflows/ml-report.md` |
| `/ml-map-codebase` | `ml/workflows/ml-map-codebase.md` |
| `/ml-debug` | `ml/workflows/ml-debug.md` (if present) |
| `/ml-status` | `ml/workflows/ml-status.md` (if present) |
| `/ml-continue` | `ml/workflows/ml-continue.md` (if present) |
| `/ml-release-version` | `ml/workflows/ml-release-version.md` (if present) |
| `/ml-research` | spawn `agents/ml-researcher.agent.md` directly |
| `/ml-data-prep` | `ml/workflows/ml-data-prep.md` (if present) |
| `/ml-quantize` | `ml/workflows/ml-quantize.md` (if present) |

**Resolution protocol:**
1. Detect any message starting with `/ml-` or `ml-` (case-sensitive, hyphenated).
2. Look up the command in the table above. If the file does not exist, say so explicitly and offer the closest match — do NOT say "command not found" and stop.
3. Read the mapped file. Follow its `<purpose>`, `<context_management>`, and `<process>` sections.
4. When a workflow says to spawn a subagent, read `agents/<agent-name>.agent.md` and run it with the `<files_to_read>` block specified in the workflow.
5. When a workflow references a skill (`ml-ask`, `ml-doc`), read `skills/<skill-name>.md` and apply its format.

If the user types a command you don't recognize, search `ml/workflows/` and `agents/` for a close match before reporting an error.

## General framework rules

- Use this ML framework for any ML/AI development request (computer vision, VLMs, LLMs, data pipelines, evaluation, quantization, inference serving).
- After completing any `ml-*` command (or any deliverable it triggers), ALWAYS offer the user the next step via an `ask_user` block in the `ml-ask` skill format; repeat this feedback loop until the user explicitly indicates they are done.
- State directory: all working files live in `.works/[version]/` — ask for the version at the start of a new session if it isn't already known from `STATE.md`.

## Behavior Principles

**Explain before asking:**
- When asking the user a question, always include WHY you need that information and how the answer affects the workflow.
- Provide a recommendation with the question whenever one is reasonable — don't just list neutral choices.
- When requesting to run a command or script, briefly explain what it does and why it's needed at this point.
- When requesting access to a file or directory, state what information you're looking for and why.
- When presenting options, always explain the trade-offs of each choice — don't just list them.

**Research is optional:**
- Never auto-run research. Always ask the user first (Skip / Quick / Deep).
- Include a recommendation with brief reasoning based on the complexity and clarity of the current context.
- Only recommend research when there are genuine knowledge gaps or uncertainty. If context is clear, recommend Skip.

**Autopilot on implementation:**
- When `/ml-implement` starts, engage autopilot mode: print the autopilot banner, then run every wave end-to-end without step-by-step confirmation.
- Only pause for: missing pre-conditions (CONTEXT.md or PLAN.md absent), R4 architecture conflicts, PARTIAL/FAILED tasks at the end of implementation, or a NO-GO from `/ml-test`.
- The same spirit applies to `/ml-test` → `/ml-doc` → `/ml-report` on a clean-success path: auto-chain, don't interrupt.

**Commit discipline:**
- Commit ONLY at two defined points:
  1. Phase implementation complete — after `/ml-implement` finishes all waves (`feat(phase-N): implement [phase-name]`)
  2. Phase documentation complete — after `/ml-doc` finishes (`docs([version]): [phase-name] documentation`)
- Do NOT commit during: discuss, plan, test, research, debug, status, continue, or report.

**Write / update documentation:**
- Always ask the user if they want to update documentation after implementation, debugging, or research sessions. If yes, run `/ml-doc` to generate docs based on the current context and implementation.
- When generating docs, explain that this will create or update user-facing documentation files based on the current state of the project (new features, changes, configuration, results).

**Always offer to add more:**
- During context collection (`/ml-discuss`) and planning (`/ml-plan`), always ask the user if there's anything else they want to add before proceeding.

**Always offer an "Other" choice:**
- Every `ask_user` block with a `choices:` list must include an "Other — I'll describe" option so the user can break out of the menu and add custom input.
<!-- /AI Framework Configuration -->
