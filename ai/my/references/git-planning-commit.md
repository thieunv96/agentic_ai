# Git Planning Commit

Commit planning artifacts using the ai-tools CLI, which automatically checks `commit_docs` config and gitignore status.

## Commit via CLI

Always use `my-tools.cjs commit` for `.note/` files — it handles `commit_docs` and gitignore checks automatically:

```bash
node ".github/my/bin/my-tools.cjs" commit "docs({scope}): {description}" --files .note/STATE.md .note/ROADMAP.md
```

The CLI will return `skipped` (with reason) if `commit_docs` is `false` or `.note/` is gitignored. No manual conditional checks needed.

## Amend previous commit

To fold `.note/` file changes into the previous commit:

```bash
node ".github/my/bin/my-tools.cjs" commit "" --files .note/codebase/*.md --amend
```

## Commit Message Patterns

| Command | Scope | Example |
|---------|-------|---------|
| discuss-phase | phase | `docs: phase 03 context locked - authentication` |
| execute-phase | phase | `docs(phase-03): complete authentication phase` |
| new-milestone | milestone | `docs: start milestone v1.1` |
| remove-phase | chore | `chore: remove phase 17 (dashboard)` |
| insert-phase | phase | `docs: insert phase 16.1 (critical fix)` |
| add-phase | phase | `docs: add phase 07 (settings page)` |

## When to Skip

- `commit_docs: false` in config
- `.note/` is gitignored
- No changes to commit (check with `git status --porcelain .note/`)
