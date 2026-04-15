<!-- Asilla Configuration — managed by asilla installer -->
# Instructions for Asilla (ML/AI Edition)

- Use the asilla skill when the user asks for Asilla or uses a `asilla-*` command.
- Treat `/asilla-...` or `asilla-...` as command invocations and load the matching file from `.github/skills/asilla-*`.
- When a command says to spawn a subagent, prefer a matching custom agent from `.github/agents`.
- Do not apply Asilla workflows unless the user explicitly asks for them.
- After completing any `asilla-*` command (or any deliverable it triggers), ALWAYS offer the user the next step by prompting via `ask_user`; repeat this feedback loop until the user explicitly indicates they are done.
- This framework is optimized for ML/AI development (Computer Vision, VLMs). The 10 commands are: asilla-new-version, asilla-provide-context, asilla-discuss, asilla-plan, asilla-implement, asilla-evaluate, asilla-debug, asilla-status, asilla-continue, asilla-release-version.
<!-- /Asilla Configuration -->
