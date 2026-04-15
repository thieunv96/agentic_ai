<!-- AI Framework Configuration — managed by ai installer -->
# Instructions for AI Framework (ML/AI Edition)

- Use the my framework skill when the user asks for my framework or uses a `my-*` command.
- Treat `/my-...` or `my-...` as command invocations and load the matching file from `.github/skills/my-*`.
- When a command says to spawn a subagent, prefer a matching custom agent from `.github/agents`.
- Do not apply my framework workflows unless the user explicitly asks for them.
- After completing any `my-*` command (or any deliverable it triggers), ALWAYS offer the user the next step by prompting via `ask_user`; repeat this feedback loop until the user explicitly indicates they are done.
- This framework is optimized for ML/AI development (Computer Vision, VLMs). The 10 commands are: my-new-version, my-provide-context, my-discuss, my-plan, my-implement, my-evaluate, my-debug, my-status, my-continue, my-release-version.
<!-- /AI Framework Configuration -->
