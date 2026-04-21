<purpose>
A reusable interaction pattern for all user-facing questions in the ML framework.
Ensures every question is beautiful, efficient, and user-centric.
Load this skill when any workflow step needs to ask the user a question.
</purpose>

<principles>

## The Four Rules of a Good ML Question

**1. Context before question.**
Never ask a question cold. Always show what you already know and what you need to know — before you ask.

**2. One clear ask per block.**
One decision per question. Multiple unrelated questions in a single block overwhelm and produce low-quality answers. If you have 3 questions, send 3 separate blocks.

**3. Always explain the WHY.**
Show exactly how the answer changes what happens next. "This affects X" is better than "I need to know X."

**4. Give a recommendation.**
When choices have a clearly better option given the current context, mark it. The user shouldn't have to pick blind.

</principles>

<question_format>

## Standard Question Block

```
┌─────────────────────────────────────────────────────────────┐
│ WHY THIS MATTERS                                            │
│ [1-2 sentences: how the answer changes what happens next]   │
└─────────────────────────────────────────────────────────────┘

[Question — specific and answerable in one sentence]

  [A] [Option label] — [tradeoff or implication]
  [B] [Option label] — [tradeoff or implication]  ← Recommended
  [C] [Option label] — [tradeoff or implication]
  [D] Other — I'll describe

[Optional recommendation line:]
→ Recommendation: [B] because [brief evidence-based reason]
```

</question_format>

<question_types>

## Type 1 — Decision Question

Use when: choosing between approaches with real tradeoffs.

```
┌──────────────────────────────────────────────────────────────┐
│ WHY THIS MATTERS                                             │
│ The fine-tuning strategy determines VRAM usage, training     │
│ time, and adapter portability. Choosing now avoids a         │
│ mid-implementation pivot.                                    │
└──────────────────────────────────────────────────────────────┘

Which fine-tuning approach do you want to use?

  [A] Full SFT — highest quality, requires ~40 GB VRAM, slow
  [B] LoRA (r=16) — good quality, ~16 GB VRAM, fast  ← Recommended
  [C] QLoRA (4-bit) — slight quality trade-off, ~8 GB VRAM, fastest
  [D] Other — I'll describe my constraints

→ Recommendation: [B] given your 16 GB VRAM constraint from CONTEXT.md
```

## Type 2 — Confirmation Question

Use when: verifying understanding before proceeding to a large operation.

```
┌──────────────────────────────────────────────────────────────┐
│ WHY THIS MATTERS                                             │
│ Confirming scope prevents running a 4-hour training job on   │
│ the wrong objective.                                         │
└──────────────────────────────────────────────────────────────┘

Is this the scope for Phase 2?

  Problem: Small objects (< 32px) are missed by the current detector
  Approach: Add multi-scale feature fusion to the backbone
  Target: mAP@0.5 on small-object split ≥ 0.45
  Constraint: Must not increase inference time > 10%

  [A] Yes — this is correct, proceed
  [B] Adjust scope — something needs changing
  [C] Not enough context yet — run /ml-discuss 2 first
  [D] Other — I'll clarify
```

## Type 3 — Issue/Blocker Question

Use when: something failed or needs human judgment to proceed.

```
┌──────────────────────────────────────────────────────────────┐
│ ISSUE                                                        │
│ Evaluation failed: mAP@0.5 = 0.38 (target: ≥ 0.45)         │
│ 3 of 8 tasks completed successfully.                         │
│ Human judgment needed before proceeding.                     │
└──────────────────────────────────────────────────────────────┘

How do you want to handle the evaluation result?

  Failed criterion: mAP@0.5 = 0.38 vs target 0.45
  Root cause (analysis): Feature fusion layers not connected to detector head
  Gap plan ready: Wave 2 → Task 2.3 — rewire head connections

  [A] Fix the gap now — /ml-implement 2 --gaps-only
  [B] Accept this result and proceed to documentation
  [C] Dig into why — show me the failure analysis
  [D] Other — I have additional context about this failure
```

## Type 4 — Freeform Input

Use when: no set of choices captures the answer (e.g., naming things, describing a problem).

```
┌──────────────────────────────────────────────────────────────┐
│ WHY THIS MATTERS                                             │
│ The more specific your answer, the more targeted the         │
│ research will be — a vague question produces vague results.  │
└──────────────────────────────────────────────────────────────┘

Q3. What is the riskiest assumption in this work item?

[Describe in your own words. A good answer is 1-2 sentences naming
the specific assumption and what would happen if it's wrong.]

Example: "We assume the backbone already has enough small-object
features — but this hasn't been validated with feature visualization."
```

## Type 5 — Next Step Question (End of Pipeline Stage)

Use when: a stage completed successfully and the user decides what's next.

```
┌──────────────────────────────────────────────────────────────┐
│ PIPELINE STATUS                                              │
│ ✓ Implementation committed (feat(phase-2): small object fix) │
│ ✓ Evaluation: GO — mAP@0.5 = 0.47 (target: ≥ 0.45)         │
│ ✓ Documentation committed (docs(v1.1): detection phase 2)    │
│ ✓ Session report: .works/reports/session-2025-04-21.md       │
└──────────────────────────────────────────────────────────────┘

Pipeline complete for Phase 2. What next?

  Based on findings:
  → Recommendation [A]: Phase 3 targets inference latency, which is now
    the main bottleneck after the accuracy improvement.

  [A] Start Phase 3 — /ml-discuss 3  ← Recommended
  [B] Run experiment comparison — /ml-report experiment
  [C] Start a new version — /ml-new-version
  [D] Stop here
  [E] Other — I'll describe what I need
```

</question_types>

<batching_rules>

## When to Batch vs When to Separate

**Batch** (ask together in one message, clearly numbered) when:
- Questions are about the same topic and answers don't depend on each other
- All answers are needed before ANY work can begin
- Asking separately would create unnecessary back-and-forth
- Max 3 questions per batch

**Separate** (one ask_user block per question) when:
- Answer to Q1 determines whether Q2 is even relevant
- Questions are about different topics (constraints vs timeline vs risk)
- Each answer deserves a focused response

**Never batch**:
- Blocker/issue questions with routine questions
- Freeform input questions with choice questions
- More than 3 questions at once

</batching_rules>

<response_handling>

## When User Answers "Other"

When the user selects "Other — I'll describe":
1. Treat their description as higher-fidelity input than any of the preset choices
2. Acknowledge what they said specifically ("Got it — you want X rather than Y")
3. Update your understanding before proceeding
4. Do NOT ask them to re-select from the original choices

## When User Gives an Unexpected Answer

If the user's answer doesn't fit the expected pattern:
1. Paraphrase what you understood ("It sounds like you mean X — is that right?")
2. State what you'll do with that information
3. Proceed — don't loop asking for clarification more than once

</response_handling>

<context_efficiency>

## Questions That Should NOT Be Asked

Do not ask if the answer is already in a file:
- Hard constraints → CONTEXT.md
- Target metrics → CONTEXT.md or REQUIREMENTS.md
- Version → STATE.md
- Phase status → STATE.md

Read the file first. Ask only what is genuinely unknown.

## Question Budget

In any single workflow step, use at most:
- 1 question for `confirm/proceed` decisions
- 3 questions for a deep-dive (discuss) session
- 1 question at the end of a pipeline stage (next step)

If you need more, consider whether the context collection (ml-discuss) was incomplete.

</context_efficiency>
