<!-- AI Framework Configuration — managed by ai installer -->
# Instructions for AI Framework (ML/AI Edition)

- Use the AI framework skill when the user asks for AI framework or uses a `ai-*` command.
- Treat `/ai-...` or `ai-...` as command invocations and load the matching file from `.github/skills/ai-*`.
- When a command says to spawn a subagent, prefer a matching custom agent from `.github/agents`.
- Do not apply AI framework workflows unless the user explicitly asks for them.
- After completing any `ai-*` command (or any deliverable it triggers), ALWAYS offer the user the next step by prompting via `ask_user`; repeat this feedback loop until the user explicitly indicates they are done.
- This framework is optimized for ML/AI development (Computer Vision, VLMs). The 10 commands are: ai-new-version, ai-provide-context, ai-discuss, ai-plan, ai-implement, ai-evaluate, ai-debug, ai-status, ai-continue, ai-release-version.
<!-- /AI Framework Configuration -->
