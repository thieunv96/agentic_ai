<purpose>
Surface real painpoints, research them, and refine to final locked requirements for a Work item, Bug, or Version issue.
Command: `/ml-discuss [N]` or `/ml-discuss [issue-name]`
Reads: `.works/[v]/KNOWLEDGE.md`, prior `[N]-CONTEXT.md`, `ROADMAP.md`, `REQUIREMENTS.md`, recent `EVALUATION.md` files
Writes: `.works/[version]/[N]-CONTEXT.md`, `.works/[version]/KNOWLEDGE.md` (if research run)
Commit: none — per commit discipline
</purpose>

<context_management>

## Context Rules (apply throughout this workflow)

**Load from files, not memory.** Before asking any question, read `.works/[v]/STATE.md` and existing CONTEXT.md. Never ask something already recorded in these files.

**Codebase map:** If `.works/[v]/codebase/MANIFEST.md` exists, read it during Step 3 (Load Existing Context). It gives instant understanding of the current baseline without grepping source — use it to anchor painpoint questions to real components (e.g., "your loss is in utils/losses.py:focal_loss — is that the function producing wrong gradients?").

**Spawn ml-context-keeper when:** context window feels ~70% full, or at the end of this session before handing off to `/ml-plan`.

**Pass context to agents via `<files_to_read>` blocks**, not by pasting content inline.

**Question discipline:** Use the `ml-ask` skill format for all `ask_user` blocks (context panel → WHY → question → choices with tradeoffs → recommendation).

**Agent spawn — ml-researcher (Step 5):**
```
<files_to_read>
- .works/$VERSION/KNOWLEDGE.md
- .works/$VERSION/[N]-CONTEXT.md
- REQUIREMENTS.md
</files_to_read>
Specific question to answer: [question from Step 4]
Research depth: Quick / Deep (as chosen by user)
```

</context_management>

<process>

## 1. Identify Version

Before writing any files, establish which version this discussion belongs to.

```
ask_user:
  WHY: All context files, plans, and state are stored under `.works/[version]/`.
       Knowing the version upfront ensures everything lands in the right place and
       avoids mixing context from different releases.
  question: "Which version does this discussion belong to?"
  choices:
    - "[List existing dirs found under .works/, e.g. v1.0, v1.1]"
    - "New version — I'll specify the name"
    - "Other — I'll describe"
```

If "New version" or "Other": ask for the version string (e.g., `v1.1`, `sprint-3`, `experiment-rag`).
Set `VERSION` and `WORKS_DIR=.works/$VERSION/` for all subsequent file paths.

## 2. Identify Issue Type

```
ask_user:
  WHY: The question set differs radically by type. A bug discussion needs reproduction
       steps and root cause; a version discussion needs scope and success criteria;
       a work item needs user story and constraints. Knowing the type upfront lets me
       ask the right questions without wasting your time.
  question: "What kind of issue are we discussing?"
  choices:
    - "Work item — new feature or capability to build"
    - "Bug — something broken in production or evaluation"
    - "Version planning — scoping a full release or milestone"
    - "Research spike — exploring a technique or approach before committing"
    - "Other — I'll describe"
```

## 3. Load Existing Context

Read the following in parallel (skip any that do not exist):

- `$WORKS_DIR/KNOWLEDGE.md` — papers, code refs, and insights already collected
- `$WORKS_DIR/[N]-CONTEXT.md` — prior context if resuming a discussion
- `ROADMAP.md` — overall project direction and phase structure
- `REQUIREMENTS.md` — project-wide hard constraints and target metrics
- Most recent `$WORKS_DIR/*-EVALUATION.md` — current model performance baseline

Summarize explicitly: what is already known, and what is still unknown or unresolved.

## 4. Surface Painpoints — Deep-Dive Questions

Ask each question in a separate `ask_user` block to avoid overwhelming the user.
Each block includes a WHY explaining how the answer shapes what gets planned.

---

**If Work item:**

```
ask_user:
  WHY: Understanding the actual problem (not the stated requirement) prevents building
       the wrong thing. The answer will anchor the success criteria and determine
       whether we need a new model capability or a pipeline fix.
  question: "Q1. What specific problem does a user or pipeline face today without this feature?"
  allow_freeform: true
  example: "Our detector flags 0 detections on images with objects smaller than 32px — we have to manually review 2000 frames/day."
```

```
ask_user:
  WHY: Knowing what was already tried tells me which approaches are off-limits and
       which partial solutions exist. This prevents re-exploring dead ends.
  question: "Q2. What has already been tried, and why did it fall short?"
  allow_freeform: true
```

```
ask_user:
  WHY: Vague done criteria lead to scope creep and "done" debates. A measurable
       criterion becomes the acceptance test for this phase.
  question: "Q3. How will you know this is done? What metric or behavior changes?"
  allow_freeform: true
  example: "mAP@0.5 on the small-object validation split goes from 0.32 to ≥ 0.45"
```

```
ask_user:
  WHY: Hard constraints shape the entire implementation strategy. Missing one here
       causes costly rework after planning is complete.
  question: "Q4. What are the hard constraints for this work?"
  choices:
    - "Latency — inference must stay under a target ms"
    - "Memory — must fit within a target VRAM budget"
    - "Dataset — cannot add new training data"
    - "Framework — must use the existing stack (no new dependencies)"
    - "Compatibility — must not break existing API or output format"
    - "No hard constraints — optimize freely"
    - "Multiple — I'll describe"
    - "Other — I'll describe"
```

```
ask_user:
  WHY: The riskiest assumption is the one nobody has tested. Surfacing it now
       lets us validate or de-risk it before committing to a plan.
  question: "Q5. What is the riskiest assumption in this work item?"
  allow_freeform: true
  example: "We assume the backbone already learned enough small-object features — but we haven't verified this with a feature visualization."
```

---

**If Bug:**

```
ask_user:
  WHY: Vague bug reports produce vague fixes. Reproducing the failure precisely —
       input, environment, actual vs expected — is the only reliable path to root cause.
  question: "Q1. Describe the failure exactly: what input, what environment, what do you get vs. what you expected?"
  allow_freeform: true
```

```
ask_user:
  WHY: Knowing when the regression started tells us where to look: a recent commit,
       a data shift, or an environment change. This narrows the search space dramatically.
  question: "Q2. When did this start? Was it always broken, or did it regress?"
  choices:
    - "Always broken — never worked correctly"
    - "Regressed after a model update"
    - "Regressed after a data pipeline change"
    - "Regressed after a dependency or environment update"
    - "Started appearing with a new data distribution or edge case"
    - "Unsure — appeared suddenly"
    - "Other — I'll describe"
```

```
ask_user:
  WHY: Impact determines priority and acceptable fix scope. A critical blocker
       justifies a targeted patch; a low-severity issue can wait for a clean fix.
  question: "Q3. What is the production or evaluation impact?"
  choices:
    - "Critical — blocking the pipeline, zero valid outputs"
    - "High — affects > 10% of inference cases"
    - "Medium — edge cases only, partial degradation"
    - "Low — cosmetic or minor metric regression"
    - "Other — I'll describe"
```

```
ask_user:
  WHY: Even a wrong hypothesis is useful — it tells us what to rule out first
       and avoids re-exploring obvious dead ends.
  question: "Q4. What is your hypothesis for the root cause? Even a guess helps."
  allow_freeform: true
```

```
ask_user:
  WHY: A fix that introduces a new bug is worse than no fix. Knowing what must
       stay intact defines the regression test surface.
  question: "Q5. What existing behavior must NOT break during the fix?"
  allow_freeform: true
```

---

**If Version planning:**

```
ask_user:
  WHY: A version with multiple "most important" outcomes usually fails to deliver any
       of them. One concrete, measurable outcome keeps the scope honest and achievable.
  question: "Q1. What is the single most important outcome this version must deliver?"
  allow_freeform: true
  example: "A quantized VLM that runs at < 50ms on edge hardware with < 3% accuracy drop"
```

```
ask_user:
  WHY: Explicit out-of-scope prevents scope creep mid-sprint and lets me focus
       planning on what actually matters.
  question: "Q2. What is explicitly OUT OF SCOPE for this version?"
  allow_freeform: true
```

```
ask_user:
  WHY: Target metrics are the acceptance test for the version. Quantitative targets
       prevent "good enough" debates at release time.
  question: "Q3. What are the target metrics? (quantitative, with current baseline)"
  allow_freeform: true
```

```
ask_user:
  WHY: Timeline constraints affect wave sequencing and determine which phases can
       run in parallel. A tight deadline forces different tradeoffs than a flexible one.
  question: "Q4. What is the deadline or target release window?"
  choices:
    - "1-week sprint"
    - "2-week sprint"
    - "1 month"
    - "Flexible — no hard deadline"
    - "Other — I'll specify"
```

```
ask_user:
  WHY: Version-level risks can invalidate the entire plan. Surfacing the biggest one
       now lets us sequence phases to de-risk early, before committing all waves.
  question: "Q5. What is the biggest risk that could derail this version?"
  allow_freeform: true
```

---

**If Research spike:**

```
ask_user:
  WHY: A spike without a clear question wastes time. The answer will scope the
       research depth and determine what a successful spike looks like.
  question: "Q1. What specific question does this spike need to answer?"
  allow_freeform: true
  example: "Can SDPA attention replace FlashAttention in our training loop without throughput regression?"
```

```
ask_user:
  WHY: Knowing what you already know prevents re-reading papers you've already evaluated
       and focuses the spike on genuine unknowns.
  question: "Q2. What do you already know or have tried in this area?"
  allow_freeform: true
```

```
ask_user:
  WHY: The decision this spike informs determines how deeply we need to research.
       If it's a minor optimization, quick is enough. If it changes the architecture, deep is warranted.
  question: "Q3. What decision does this spike feed into, and when does that decision need to be made?"
  allow_freeform: true
```

---

After collecting answers, present a brief synthesis:

```
---
Here is what I heard:

• Problem / question: [one sentence]
• What's been tried: [summary]
• Success looks like: [measurable criterion or answer]
• Key constraints: [list]
• Biggest risk / unknown: [one sentence]
---
```

## 5. Optional Research — BEFORE Finalizing Requirements

```
ask_user:
  WHY: Research at this stage can validate assumptions, surface prior art, or reveal
       constraints that change the requirements — cheaper to discover now than mid-implementation.
       If the context is already clear, skipping is the right call.

  question: "Should I research this area before we finalize requirements?"

  Recommendation: [Skip / Quick / Deep] — [1-sentence reasoning based on Step 4 answers.
    Recommend Skip if the approach is well-understood.
    Recommend Quick if there are 1-2 specific unknowns worth a fast scan.
    Recommend Deep if the core technique is novel or the risk is high.]

  choices:
    - "Skip — context is clear, proceed to refining requirements"
    - "Quick — scan relevant papers and existing implementations (5–10 min)"
    - "Deep — full survey with code references and comparisons (20–30 min)"
    - "Other — I'll describe what I need"
```

If Quick or Deep: spawn **ml-researcher** agent with:
```
<files_to_read>
- .works/$VERSION/KNOWLEDGE.md
- .works/$VERSION/[N]-CONTEXT.md
- REQUIREMENTS.md
</files_to_read>
Specific question: [exact question from Step 4]
Depth: [Quick / Deep]
```
The agent updates `.works/$VERSION/KNOWLEDGE.md` and returns 2–4 bullets:
  - What was confirmed
  - What was challenged or contradicted
  - What new constraints or tradeoffs were found
  - Recommended approach based on findings

## 6. Deeper Discussion and Recommendations — BEFORE Locking

Based on the raw answers (Step 4) and research findings (Step 5, if run):

Present to the user:

```
---
Based on what we've discussed:

**Recommended approach:**
[1-2 sentences — the approach most likely to succeed given the constraints and risk profile]
Reasoning: [why this is preferred over alternatives]

**Alternative worth considering:**
[Only if one exists with meaningfully different tradeoffs]
Tradeoff: [what you gain vs. what you give up]

**Open risks not yet resolved:**
- [Risk 1 — what could still go wrong]
- [Risk 2 if applicable]

**Suggested refinements to the stated requirements:**
- [e.g., "The success criterion of 'mAP ≥ 0.45' should also include a latency budget,
  otherwise a correct but 2x slower model would pass"]
---
```

```
ask_user:
  question: "Do these recommendations change anything before we finalize requirements?"
  choices:
    - "No — the recommendations look right, proceed to locking requirements"
    - "Yes — I want to adjust something (describe below)"
    - "Let's dig deeper into one specific area first"
    - "Other — I have more context to add"
```

Iterate until the user confirms. No cap on rounds.

## 7. Finalize and Present Requirements

Synthesize everything into a structured summary and show it to the user:

```
---
**Final Requirements for Phase [N]: [Name]**

Problem Statement:
[One paragraph — the real painpoint, not just the stated requirement]

Locked Decisions:
| ID   | Decision                     | Rationale          |
|------|------------------------------|--------------------|
| D-01 | [Hard constraint or approach] | [Why]             |

Success Criteria:
- [ ] [Measurable criterion 1]
- [ ] [Measurable criterion 2]

Hard Constraints:
[List from Step 4]

Riskiest Assumption:
[From Step 4 Q5 — what must be validated first]

Out of Scope:
[Explicit exclusions]

Open Questions:
[Anything still unresolved — carries into planning]
---
```

```
ask_user:
  question: "Does this capture the full requirements correctly?"
  choices:
    - "Yes — lock these requirements"
    - "No — something is missing or wrong (describe)"
    - "Almost — one thing needs updating"
    - "Other — I want to add something specific"
```

Iterate until confirmed.

## 8. Write `[N]-CONTEXT.md`

Write to: `.works/$VERSION/[N]-CONTEXT.md`

```markdown
# Phase [N] Context: [Issue Name]

**Date:** [date]
**Version:** [version]
**Issue type:** Work item / Bug / Version planning / Research spike

## Problem Statement

[One paragraph — the real painpoint behind the stated requirement, not a restatement of the feature]

## Locked Decisions

| ID | Decision | Rationale |
|----|----------|-----------|
| D-01 | [Hard constraint or chosen approach] | [Why] |

## Success Criteria

- [ ] [Measurable criterion 1]
- [ ] [Measurable criterion 2]

## Hard Constraints

[List]

## Riskiest Assumption

[What must be validated first before committing to the full plan]

## Out of Scope

[Explicit exclusions — anything that was considered and decided against]

## Open Questions

[Anything unresolved — these carry into the planning session]

## Research Findings

[If research was run: key findings, confirmed approaches, new constraints discovered]
[If skipped: "Research skipped — context was sufficient."]
```

**No commit** — per commit discipline (only commit at phase implement complete and phase docs complete).

## 9. Offer Next Step

```
---
✓ Requirements locked → .works/$VERSION/[N]-CONTEXT.md

To plan this phase:
  /ml-plan [N]

To add more context or revisit:
  /ml-discuss [N]
---
```

```
ask_user:
  question: "What would you like to do next?"
  choices:
    - "Plan this phase — /ml-plan [N]"
    - "Add more context or research first"
    - "Stop here"
    - "Other — I'll describe what I need"
```

</process>
