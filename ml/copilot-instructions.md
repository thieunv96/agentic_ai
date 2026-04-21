<!-- AI Framework Configuration — managed by ai installer -->
# Instructions for AI Framework

- Use the ml framework skill when the user asks for ml framework or uses a `ml-*` command.
- Treat `/ml-...` or `ml-...` as command invocations and load the matching file from `.github/skills/ml-*`.
- When a command says to spawn a subagent, prefer a matching custom agent from `.github/agents`. If none exists, spawn a default agent with the provided instructions.
- After completing any `ml-*` command (or any deliverable it triggers), ALWAYS offer the user the next step by prompting via `ask_user`; repeat this feedback loop until the user explicitly indicates they are done.
- This framework is optimized for ML/AI development (Computer Vision, VLMs). The available commands are: ml-discuss, ml-plan, ml-implement, ml-doc, ml-debug, ml-status, ml-continue, ml-release-version, ml-research, ml-map-codebase, ml-data-prep, ml-quantize, ml-report.

## Behavior Principles

**Explain before asking:**
- When asking the user a question, always include WHY you need that information and how the answer affects the workflow in the important things. 
- Usually providing few recommendation or guidance along with the question is helpful.
- When requesting to run a command or script, briefly explain what it does and why it's needed at this point.
- When requesting access to a file or directory, state what information you're looking for and why.
- When presenting options, always explain the trade-offs of each choice — don't just list them.

**Research is optional:**
- Never auto-run research. Always ask the user first (quick / deep / skip).
- Include few recommendation with brief reasoning based on the complexity and clarity of the current context.
- Only recommend research when there are genuine knowledge gaps or uncertainty. If context is clear, recommend skip.

**Commit discipline:**
- Only commit at few defined points:
  1. Phase implementation complete — after `/ml-implement` finishes all waves
  2. Phase documentation complete — after `/ml-docs` finishes all waves
- Do NOT commit during: plan, evaluate, research, debug, status, or continue sessions.

** Write / update documentation:**
- Always ask the user if they want to update documentation after implementation, debugging, or research sessions. If yes, run `/ml-doc` to generate docs based on the current context and implementation.
- When generating docs, explain to the user that this will create or update documentation files (e.g., README.md, USAGE.md) based on the current state of the project, including new features, changes, and any relevant information that should be documented for users or developers.

**Always offer to add more:**
- During context collection (`/ml-discuss`) and planning (`/ml-plan`), always ask the user if there's anything else they want to add before proceeding.
<!-- /AI Framework Configuration -->
