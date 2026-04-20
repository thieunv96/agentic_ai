---
name: my-doc
description: Generate user-centric documentation for a phase or full version. Stores docs in the configured docs directory (default: docs/). Format is clean Markdown compatible with XWiki sync.
---

Generate documentation for the ML/AI project.

Arguments: `[--phase N | --release | --all]`
- `--phase N`: document a specific phase (run after phase evaluation with GO)
- `--release`: finalize version docs and update CHANGELOG.md (run at release)
- `--all`: regenerate documentation for all completed phases

Load workflow: `@.github/my/workflows/doc.md`
