<!-- AI Framework Configuration — managed by ai installer -->
# Instructions for AI Framework (ML/AI Edition)

- Use the my framework skill when the user asks for my framework or uses a `my-*` command.
- Treat `/my-...` or `my-...` as command invocations and load the matching file from `.github/skills/my-*`.
- When a command says to spawn a subagent, prefer a matching custom agent from `.github/agents`.
- Do not apply my framework workflows unless the user explicitly asks for them.
- After completing any `my-*` command (or any deliverable it triggers), ALWAYS offer the user the next step by prompting via `ask_user`; repeat this feedback loop until the user explicitly indicates they are done.
- This framework is optimized for ML/AI development (Computer Vision, VLMs). The 15 commands are: my-new-version, my-discuss, my-plan, my-implement, my-evaluate, my-doc, my-debug, my-status, my-continue, my-release-version, my-research, my-map-codebase, my-data-prep, my-quantize, my-report.

## Behavior Principles

**Explain before asking:**
- When asking the user a question, always include WHY you need that information and how the answer affects the workflow.
- When requesting to run a command or script, briefly explain what it does and why it's needed at this point.
- When requesting access to a file or directory, state what information you're looking for and why.
- When presenting options, always explain the trade-offs of each choice — don't just list them.

**Research is optional:**
- Never auto-run research. Always ask the user first (quick / deep / skip).
- Include a recommendation with brief reasoning based on the complexity and clarity of the current context.
- Only recommend research when there are genuine knowledge gaps or uncertainty. If context is clear, recommend skip.

**Commit discipline:**
- Only commit at three defined points:
  1. Version init — after `/my-new-version` finalizes ROADMAP.md
  2. Context locked — after `/my-discuss N` locks KNOWLEDGE.md and phase CONTEXT.md
  3. Phase implementation complete — after `/my-implement N` finishes all waves
- Do NOT commit during: plan, evaluate, research, debug, status, or continue sessions.

**Always offer to add more:**
- During context collection (`/my-discuss`, `/my-new-version`) and planning (`/my-plan`), always ask the user if there's anything else they want to add before proceeding.
<!-- /AI Framework Configuration -->
