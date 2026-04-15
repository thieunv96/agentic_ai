# update behavier for /my-new-version
Has $argument [version name]:

1. SETUP
- Run init checks (project existence, git, config)
- If project already exists → go to Exists Section .
- If no git → initialize git (continue here)

2. BROWNFIELD CHECK
- If existing code detected:
  - Ask user if they want to map codebase first
  - If yes → stop and run codebase mapping
- Else → continue

(Auto mode skips this step)

3. CONFIG (AUTO MODE ONLY)
- Collect:
  - Granularity (coarse / standard / fine)
  - Execution (parallel / sequential)
  - Git tracking (yes / no)
- Then:
  - Research (yes/no)
  - Plan check (yes/no)
  - Verifier (yes/no)
  - AI model profile

- Save to `.planning/config.json`
- Commit config

4. QUESTIONING / CONTEXT

If AUTO MODE:
- Extract context from provided document
- Skip questioning

Else:
- Ask: "What do you want to build?"
- Follow up deeply:
  - Clarify vague ideas
  - Make things concrete
  - Surface assumptions
  - Understand motivation
- Loop until clear understanding

Ask for confirmation:
- "Ready to create PROJECT.md?"
- Continue or refine

5. WRITE PROJECT.md

- Capture:
  - What the project is
  - Core value
  - Constraints
  - Initial requirements (as hypotheses)

Structure:
- Validated (empty for new project)
- Active (initial hypotheses)
- Out of scope

- Add Key Decisions
- Add Evolution section (version-aware)

Commit PROJECT.md

6. WORKFLOW CONFIG (INTERACTIVE MODE)

- Ask:
  - Mode (YOLO / Interactive)
  - Granularity
  - Parallelization
  - Git tracking
  - Research / Plan check / Verifier
  - Model profile

- Save `.planning/config.json`
- Commit

7. RESEARCH

If AUTO MODE → always research, quick or deep depend on the complexity

Else ask:
- "Research domain before defining requirements?"

If yes:
- Run 4 parallel research tracks:
  1. Stack
  2. Features
  3. Architecture
  4. Pitfalls

- Then synthesize into SUMMARY.md
- Show:
  - Stack
  - Table stakes
  - Pitfalls

8. DEFINE REQUIREMENTS (v1)

- Use:
  - PROJECT.md
  - Research (if exists)

If AUTO MODE:
- Include:
  - All table stakes
  - Features from idea document
- Skip confirmations

Else:
- Group features into categories
- Let user choose:
  - v1 (this version)
  - future versions
  - out of scope

- Ask for missing requirements

Create REQUIREMENTS.md:
- v1 requirements (with IDs like AUTH-01)
- Future requirements
- Out of scope
- Traceability section

Requirements must be:
- Specific
- Testable
- User-centric
- Atomic

Confirm (interactive only) → then commit

9. CREATE ROADMAP (VERSION v1)

- Split requirements into phases
- Each requirement belongs to EXACTLY one phase
- Each phase has:
  - Goal
  - Requirements
  - 2–5 success criteria

- Ensure 100% coverage

Generate:
- ROADMAP.md
- STATE.md
- Update REQUIREMENTS.md traceability

If AUTO MODE:
- Auto-approve

Else:
- Ask:
  - Approve
  - Adjust
  - Review

Loop until approved → commit

10. FINAL OUTPUT

Show:
- Project summary
- File locations
- Phase count + requirement count

Recommend Next step:
discuss or plan?

RULES:
- Always confirm before writing (unless auto mode)
- Commit after each major step
- Requirements must be atomic and testable
- Roadmap must cover 100% requirements
- Treat v1 as the first VERSION (not milestone)

## Exists Section
1. LOAD CONTEXT
- Read PROJECT.md, VERSIONS.md (or MILESTONES.md if not renamed), STATE.md
- Check for VERSION-CONTEXT.md (or existing context file)
- Parse arguments:
  - "--reset-phase-numbers" → reset phases to 1
  - remaining text → version name

2. GATHER VERSION GOALS
- If VERSION-CONTEXT.md exists → use it
- Else:
  - Summarize last version
  - Ask: "What do you want to build next?"
  - Clarify scope via follow-up questions

3. DETERMINE VERSION NUMBER
- Suggest next version (minor or major)
- Confirm with user

4. CONFIRM UNDERSTANDING
Show summary:
- Version number + name
- Goal (1 sentence)
- Target features
- Key context

Ask user to confirm:
- "Looks good, Let's go" → continue
- "Adjust somthing..." → refine until correct

5. UPDATE PROJECT.md
- Add "Current Version" section:
  - Goal
  - Target features
- Ensure "Evolution" section exists

6. UPDATE STATE.md
Set:
- Phase: Not started
- Status: Defining requirements
- Log version start

7. CLEANUP + COMMIT
- Delete VERSION-CONTEXT.md if exists
- Commit PROJECT.md + STATE.md

8. OPTIONAL RESEARCH
Ask user:
- Research first OR skip

If research:
- Run 4 parallel research tracks focus on CV/ML/VLM:
  - Stack
  - Features
  - Architecture
  - Pitfalls
- Then synthesize into SUMMARY.md
- Show key findings

9. DEFINE REQUIREMENTS
- Group features into categories
- Let user select which features are in-scope for this version
- Identify gaps

Generate REQUIREMENTS.md:
- Requirements with IDs (CAT-01 format)
- Future requirements
- Out of scope

Ensure requirements are:
- Specific
- User-centric
- Atomic
- Testable
- Clarity

Ask for confirmation → refine if needed → commit

10. CREATE ROADMAP
- Split requirements into phases
- Each requirement mapped to exactly ONE phase
- Each phase has:
  - Goal
  - Requirements
  - 2–5 success criteria

Respect phase numbering:
- Reset → start at 1
- Else → continue

Generate:
- ROADMAP.md
- Update STATE.md
- Add traceability

Ask user:
- Approve
- Adjust
- Review full file

Loop until approved → commit

11. FINAL OUTPUT
Show:
- Version summary
- File locations
- Phase count + requirement count
Recommend next step

Constraints:
- Commit after each major step
- Do not skip confirmation steps
- Ensure 100% requirement coverage in roadmap