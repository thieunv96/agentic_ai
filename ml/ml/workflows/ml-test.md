<purpose>
Autonomous validation of a completed phase implementation.
Covers: coding convention checks, requirements traceability, success criteria evaluation.
Command: `/ml-test [N]`
Reads: `.works/[v]/[N]-SUMMARY.md`, `.works/[v]/[N]-CONTEXT.md`, `.works/[v]/[N]-PLAN.md`, `REQUIREMENTS.md`, changed source files
Writes: `.works/[v]/[N]-EVALUATION.md`
Commit: none — per commit discipline
No user confirmation between steps.
</purpose>

<context_management>

## Context Rules (apply throughout this workflow)

**Spawn ml-evaluator for the full validation run.** Do NOT run checks inline — spawn **ml-evaluator** to keep the main context clean.

**Codebase map:** Pass `COMPONENTS.md` to ml-evaluator so it knows where eval scripts and metric functions are without having to grep for them. Pass specific chunk files for the changed functions rather than full source files.

**Agent spawn — ml-evaluator:**
```
<files_to_read>
- .works/[v]/[N]-SUMMARY.md
- .works/[v]/[N]-CONTEXT.md
- .works/[v]/[N]-PLAN.md
- REQUIREMENTS.md
- [source files listed under "Files Changed" in SUMMARY.md]
</files_to_read>
Run all validation checks: convention, traceability, success criteria.
Write EVALUATION.md and return: decision (GO/NO-GO/CONDITIONAL/BLOCKER) + key finding + recommended next command.
```

**Interrupt rules:** Only bring findings back to the main workflow if decision is NO-GO or BLOCKER. For GO and CONDITIONAL, the agent writes EVALUATION.md and the workflow auto-proceeds.

**Spawn ml-context-keeper after:** writing EVALUATION.md, before proceeding to ml-doc.

</context_management>

<process>

## 1. Setup

Read the following in parallel (skip files that do not exist):

- `.works/[v]/[N]-SUMMARY.md` — what was built, which tasks completed, which have gaps
- `.works/[v]/[N]-CONTEXT.md` — success criteria, hard constraints, locked decisions
- `.works/[v]/[N]-PLAN.md` — planned tasks and their acceptance criteria
- `REQUIREMENTS.md` — project-wide requirements (for traceability)
- Source files listed under "Files Changed" in SUMMARY.md

Determine `VERSION` from SUMMARY.md or STATE.md. Set `WORKS_DIR=.works/$VERSION/`.

If `[N]-SUMMARY.md` does not exist, stop and output:
```
Error: No SUMMARY.md found for phase [N].
Run /ml-implement [N] first.
```

## 2. Spawn ml-evaluator

Spawn **ml-evaluator** with:

```
<files_to_read>
- .works/$VERSION/[N]-SUMMARY.md
- .works/$VERSION/[N]-CONTEXT.md
- .works/$VERSION/[N]-PLAN.md
- REQUIREMENTS.md
- [source files from SUMMARY.md → Files Changed]
</files_to_read>
Run: convention checks, requirements traceability, success criteria evaluation.
Write: .works/$VERSION/[N]-EVALUATION.md
Return: decision (GO/NO-GO/CONDITIONAL/BLOCKER), key finding, recommended next command.
```

The ml-evaluator handles Steps 2–4 below autonomously. The results from the agent populate EVALUATION.md.

---

## 2. Coding Convention Checks — AUTO (handled by ml-evaluator)

Run the following checks automatically without asking. If a tool is not installed, record SKIP — do not fail the build for a missing linter.

**Python convention (if Python files changed):**

```bash
# Style
ruff check [changed files] || flake8 [changed files]

# Format
black --check [changed files]

# Types (changed files only, not full project)
mypy [changed files] --ignore-missing-imports
```

**Import discipline (grep-based, always run):**

```bash
# Wildcard imports in changed files
grep -n "^from .* import \*" [changed files]

# Unused imports — flag for manual review if count > 0
```

**Config hygiene (always run):**

```bash
# Hardcoded absolute paths
grep -rn '"/home/' [changed files]
grep -rn '"/Users/' [changed files]

# Hardcoded credentials — BLOCKER if found
grep -rn 'api_key\s*=\s*"' [changed files]
grep -rn 'password\s*=\s*"' [changed files]
grep -rn 'token\s*=\s*"' [changed files]
```

Record each check result:

| Check | Status | Notes |
|-------|--------|-------|
| Ruff / Flake8 | PASS / FAIL / SKIP | [error count or reason] |
| Black format | PASS / FAIL / SKIP | |
| Mypy types | PASS / FAIL / SKIP | |
| Wildcard imports | PASS / FAIL | [count] |
| Hardcoded paths | PASS / WARNING | [files] |
| Hardcoded credentials | PASS / **BLOCKER** | [files — stop immediately if BLOCKER] |

If BLOCKER (credentials found): stop all further checks, write EVALUATION.md with decision = NO-GO / BLOCKER, and report immediately. Do not continue to Steps 3–4.

## 3. Requirements Traceability — AUTO

For each requirement ID found in `REQUIREMENTS.md`:

1. Search `[N]-PLAN.md` for which task covers this requirement
2. Check the task's status in `[N]-SUMMARY.md` (DONE / PARTIAL / FAILED / not found)
3. Record:

| Requirement | Description | Plan Task | Task Status |
|-------------|-------------|-----------|-------------|
| REQ-01 | [brief] | Wave 1 / Task 1.1 | DONE |
| REQ-02 | [brief] | — | UNCOVERED |
| REQ-03 | [brief] | Wave 2 / Task 2.1 | PARTIAL |

If `REQUIREMENTS.md` does not exist or has no IDs: record "No project-level requirements file found — skipping traceability check."

## 4. Success Criteria Evaluation — AUTO

For each success criterion listed in `[N]-CONTEXT.md`:

**Metric-based criterion** (e.g., "mAP@0.5 ≥ 0.45"):
- Run the evaluation script specified in PLAN.md or CONTEXT.md
- Record actual value

**Artifact-based criterion** (e.g., "ONNX model at outputs/model.onnx"):
- Check file exists and is non-zero size

**Behavioral criterion** (e.g., "inference script runs without error"):
- Run the command and check exit code 0

Record each:

| Criterion | Target | Actual | Status |
|-----------|--------|--------|--------|
| mAP@0.5 small-object split | ≥ 0.45 | 0.47 | PASS |
| Inference latency | < 50ms | 62ms | FAIL |
| Checkpoint saved | file exists | ✓ | PASS |

If no evaluation script is specified in PLAN.md or CONTEXT.md for a metric criterion: record status as UNVERIFIED with a note to add the eval script.

## 5. Determine Decision

Based on all checks:

- **GO** — all success criteria PASS, no BLOCKER convention issues, no UNCOVERED critical requirements
- **NO-GO** — one or more success criteria FAIL, OR a BLOCKER issue found, OR a critical requirement is UNCOVERED
- **CONDITIONAL** — all success criteria PASS, but non-blocking issues noted (style warnings, UNCOVERED non-critical reqs, PARTIAL tasks that don't affect the metric targets)

## 6. Write `[N]-EVALUATION.md`

Write to: `.works/$VERSION/[N]-EVALUATION.md`

```markdown
# Evaluation: Phase [N] — [Phase Name]

**Date:** [date]
**Version:** [version]
**Decision:** GO / NO-GO / CONDITIONAL

---

## Coding Convention Checks

| Check | Status | Notes |
|-------|--------|-------|

## Requirements Traceability

| Requirement | Description | Plan Task | Task Status |
|-------------|-------------|-----------|-------------|

## Success Criteria

| Criterion | Target | Actual | Status |
|-----------|--------|--------|--------|

---

## Decision Rationale

**[GO / NO-GO / CONDITIONAL]**

[Plain explanation: why this decision was reached. Which criteria passed or failed.
For NO-GO: what specifically needs to be fixed.]

## Gap Plans (if NO-GO or CONDITIONAL)

- Gap 1: [what to fix — specific enough to act on]
- Gap 2: [what to fix]

## Next Steps

[GO path]: Run `/ml-doc [N]` to generate documentation.
[NO-GO path]: Run `/ml-implement [N] --gaps-only` to address the gaps above, then re-run `/ml-test [N]`.
[CONDITIONAL path]: Minor issues noted — review before proceeding to `/ml-doc [N]`.
```

**No commit** — per commit discipline.

## 7. Auto-Proceed or Pause

**If GO:** proceed automatically to `/ml-doc [N]` — no user prompt.

```
---
✓ Evaluation: GO — all criteria met
  Report: .works/$VERSION/[N]-EVALUATION.md

→ Proceeding to /ml-doc [N] ...
---
```

**If CONDITIONAL:** proceed automatically to `/ml-doc [N]` with a visible warning.

```
---
~ Evaluation: CONDITIONAL — core criteria met, non-blocking issues noted
  (see EVALUATION.md → Gap Plans for details)

→ Proceeding to /ml-doc [N] ...
---
```

**If NO-GO:** pause and ask — targets were not met and human judgment is needed.

```
ask_user:
  question: |
    Evaluation: NO-GO — one or more success criteria were not met.

    Failed criteria:
    [List each failed criterion: target vs actual]

    Gap plans:
    [List gap plans from EVALUATION.md]

    How do you want to proceed?
  choices:
    - "Fix gaps now — /ml-implement [N] --gaps-only"
    - "Review the full evaluation report"
    - "Accept partial result and proceed to docs — /ml-doc [N]"
    - "Stop here"
    - "Other — I'll provide more context"
```

**If BLOCKER (credentials found):** stop immediately — do not proceed to docs under any circumstance.

```
ask_user:
  question: |
    BLOCKER: Hardcoded credentials detected in changed files.
    This must be resolved before proceeding.

    Affected files: [list]

    Action required: remove credentials, add to .gitignore or use environment variables.
  choices:
    - "I'll fix the credentials, then re-run /ml-test [N]"
    - "Show me the exact lines to fix"
    - "Other — I'll describe the situation"
```

</process>
