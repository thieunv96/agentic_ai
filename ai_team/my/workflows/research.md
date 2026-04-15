<purpose>
Perform focused ML/CV/VLM research on a topic. Two modes: quick (fast scan) or deep (full survey).
Prioritizes gray-area / frontier research — techniques not yet mainstream, recent papers, promising directions.
Output: .planning/research/{slug}-RESEARCH.md
</purpose>

<process>

## 1. Setup

```bash
INIT=$(node ".github/my/bin/my-tools.cjs" init research "0")
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Parse from $ARGUMENTS:
- Mode: `--quick`, `--deep`, or unspecified
- Topic: remaining text

Read: STATE.md, PROJECT.md, KNOWLEDGE.md (if exists — to avoid re-researching known material).

Create topic slug: lowercase, hyphens (e.g., "LoRA for vision encoders" → `lora-vision-encoders`).

## 1b. Confirm Mode with User

If mode is **not** specified in $ARGUMENTS, assess the topic complexity and ask the user:

> "I'll research: **{topic}**
>
> [Recommendation: **{Quick|Deep}** — {brief reason based on topic complexity, e.g., "topic is well-defined and specific" / "topic is broad or frontier — a deep survey would find more nuanced options"}]
>
> Options:
> - **Quick** (~10 min): 3-5 key papers, top findings, one recommendation
> - **Deep** (~30 min): full literature survey, approach comparison, gap analysis, synthesis
>
> Which mode would you prefer?"

If mode **is** specified in $ARGUMENTS, proceed directly without asking.

Recommendation guidelines:
- Recommend **Quick** when: topic is well-known, specific technique, user seems confident
- Recommend **Deep** when: topic is broad, frontier/novel, or involves architectural trade-offs
- Do NOT recommend research at all if KNOWLEDGE.md already contains thorough coverage of the topic

## 2. Spawn my-researcher

**For `--quick` mode:**

```
<files_to_read>
.planning/STATE.md
.planning/PROJECT.md
</files_to_read>

Task: QUICK RESEARCH — {topic}

Gray-area focus: look for techniques/papers that are cutting-edge but not yet mainstream.
Time budget: ~10 minutes of focused research.

Produce a compact RESEARCH.md covering:
1. **Key Papers** (3-5): title, year, core contribution, why relevant
2. **Key Repos** (2-3): GitHub repos, stars, key patterns
3. **Key Findings**: 3-5 bullet points — what actually matters
4. **Recommendation**: One clear recommendation for this project

Save to: .planning/research/{slug}-RESEARCH.md
Keep the document under 300 lines.
```

**For `--deep` mode:**

```
<files_to_read>
.planning/STATE.md
.planning/PROJECT.md
.planning/KNOWLEDGE.md
</files_to_read>

Task: DEEP RESEARCH — {topic}

Gray-area focus: map the frontier of this field, not just the well-known approaches.
Conduct thorough literature survey.

Produce a comprehensive RESEARCH.md with sections:

## Overview
Brief orientation to the field as it stands today.

## Landscape Map
All major approaches, organized by paradigm.
For each: core idea, key papers, implementation complexity, trade-offs.

## Gray Area / Frontier
What's emerging but not yet mainstream:
- Recent papers (last 6-12 months) that challenge assumptions
- Techniques with promising results but limited adoption
- Open research questions

## Approach Comparison
Table: approach | accuracy | efficiency | implementation difficulty | when to use

## Gaps & Opportunities  
What's missing? What hasn't been tried? What would be novel?

## Recommendation
For this specific project context — what approach and why.
Include: starting point, expected timeline, key risks.

## References
All papers with links.

Save to: .planning/research/{slug}-RESEARCH.md
```

## 3. Collect Results

After my-researcher writes the file, read it back.

Run my-research-synthesizer to extract actionable insights if `--deep` mode:

```
<files_to_read>
.planning/research/{slug}-RESEARCH.md
.planning/KNOWLEDGE.md
</files_to_read>

Task: Synthesize RESEARCH.md into KNOWLEDGE.md additions.
Identify:
1. 3-5 key insights to add to KNOWLEDGE.md → Papers or Ideas sections
2. Any implementation patterns to track

Append findings to .planning/KNOWLEDGE.md under:
## Research Findings
### {date} — {topic}
[findings]
```

## 4. Show Summary

Output to user:
```
---
## 🔬 Research Complete: {topic}

**Mode:** {quick|deep}
**File:** `.planning/research/{slug}-RESEARCH.md`

### Key Findings
[3-5 bullet points from RESEARCH.md]

### Recommendation
[single recommendation]

---
```

</process>
