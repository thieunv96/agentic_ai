# Model Profiles

Model profiles control which the agent model each AI agent uses. This allows balancing quality vs token spend, or inheriting the currently selected session model.

## Profile Definitions

| Agent | `quality` | `balanced` | `budget` | `inherit` |
|-------|-----------|------------|----------|-----------|
| my-planner | opus | opus | sonnet | inherit |
| my-roadmapper | opus | sonnet | sonnet | inherit |
| my-executor | claude-opus-4-7 | claude-opus-4-7 | claude-opus-4-7 | inherit |
| ai-phase-researcher | claude-opus-4-7 | claude-opus-4-7 | claude-opus-4-7 | inherit |
| ai-project-researcher | claude-opus-4-7 | claude-opus-4-7 | claude-opus-4-7 | inherit |
| my-research-synthesizer | sonnet | sonnet | haiku | inherit |
| my-debugger | claude-opus-4-7 | claude-opus-4-7 | claude-opus-4-7 | inherit |
| my-quantizer | claude-opus-4-7 | claude-opus-4-7 | claude-opus-4-7 | inherit |
| my-codebase-mapper | sonnet | haiku | haiku | inherit |
| ai-verifier | sonnet | sonnet | haiku | inherit |
| my-plan-checker | sonnet | sonnet | haiku | inherit |
| ai-integration-checker | sonnet | sonnet | haiku | inherit |
| ai-nyquist-auditor | sonnet | sonnet | haiku | inherit |

> **Pinned agents:** `my-executor`, `my-debugger`, `my-quantizer`, `ai-phase-researcher`, `ai-project-researcher` always use `claude-opus-4-7` regardless of profile. If `claude-opus-4-7` is unavailable, fall back to `claude-opus-4-6`.

## Profile Philosophy

**quality** - Maximum reasoning power
- Opus for all decision-making agents
- Sonnet for read-only verification
- Use when: quota available, critical architecture work

**balanced** (default) - Smart allocation
- Opus only for planning (where architecture decisions happen)
- Opus 4.7 pinned for executor, debugger, quantizer, researcher (critical work regardless of cost)
- Sonnet for verification (needs reasoning, not just pattern matching)
- Use when: normal development, good balance of quality and cost

**budget** - Minimal Opus usage
- Sonnet for anything that writes code
- Haiku for research and verification
- Use when: conserving quota, high-volume work, less critical phases

**inherit** - Follow the current session model
- All agents resolve to `inherit`
- Best when you switch models interactively (for example OpenCode `/model`)
- **Required when using non-Anthropic providers** (OpenRouter, local models, etc.) — otherwise AI may call Anthropic models directly, incurring unexpected costs
- Use when: you want AI to follow your currently selected runtime model

## Using Non-the agent Runtimes (Codex, OpenCode, Gemini CLI)

When installed for a non-the agent runtime, the AI framework installer sets `resolve_model_ids: "omit"` in `~/.ai/defaults.json`. This returns an empty model parameter for all agents, so each agent uses the runtime's default model. No manual setup is needed.

To assign different models to different agents, add `model_overrides` with model IDs your runtime recognizes:

```json
{
  "resolve_model_ids": "omit",
  "model_overrides": {
    "my-planner": "o3",
    "my-executor": "o4-mini",
    "my-debugger": "o3",
    "my-codebase-mapper": "o4-mini"
  }
}
```

The same tiering logic applies: stronger models for planning and debugging, cheaper models for execution and mapping.

## Using Claude Code with Non-Anthropic Providers (OpenRouter, Local)

If you're using Claude Code with OpenRouter, a local model, or any non-Anthropic provider, set the `inherit` profile to prevent AI from calling Anthropic models for subagents:

```bash
# Via settings command
/my-settings
# → Select "Inherit" for model profile

# Or manually in .note/config.json
{
  "model_profile": "inherit"
}
```

Without `inherit`, AI's default `balanced` profile spawns specific Anthropic models (`opus`, `sonnet`, `haiku`) for each agent type, which can result in additional API costs through your non-Anthropic provider.

## Resolution Logic

Orchestrators resolve model before spawning:

```
1. Read .note/config.json
2. Check model_overrides for agent-specific override
3. If no override, look up agent in profile table
4. Pass model parameter to Task call
```

## Per-Agent Overrides

Override specific agents without changing the entire profile:

```json
{
  "model_profile": "balanced",
  "model_overrides": {
    "my-executor": "opus",
    "my-planner": "haiku"
  }
}
```

Overrides take precedence over the profile. Valid values: `opus`, `sonnet`, `haiku`, `inherit`, or any fully-qualified model ID (e.g., `"o3"`, `"openai/o3"`, `"google/gemini-2.5-pro"`).

## Switching Profiles

Runtime: `/my-set-profile <profile>`

Per-project default: Set in `.note/config.json`:
```json
{
  "model_profile": "balanced"
}
```

## Design Rationale

**Why Opus for my-planner?**
Planning involves architecture decisions, goal decomposition, and task design. This is where model quality has the highest impact.

**Why Opus 4.7 for my-executor?**
Executors must make real-time deviation decisions (Rules 1-4), handle unexpected file states, and commit atomic changes. These in-the-moment judgments benefit from maximum reasoning, not just instruction-following.

**Why Opus 4.7 for my-debugger?**
Debugging is hypothesis-driven investigation. Finding the root cause of a subtle ML bug (NaN gradients, shape mismatches, precision loss) requires the deepest reasoning available.

**Why Opus 4.7 for my-quantizer?**
Quantization involves multi-dimensional tradeoffs (accuracy vs. latency vs. memory vs. hardware compatibility). Wrong decisions here are hard to reverse and costly to re-run.

**Why Opus 4.7 for researchers (ai-phase-researcher, ai-project-researcher)?**
Research quality determines plan quality. A shallow literature review leads to wrong architectural choices that cascade through all downstream phases.

**Why Sonnet (not Haiku) for verifiers in balanced?**
Verification requires goal-backward reasoning - checking if code *delivers* what the phase promised, not just pattern matching. Sonnet handles this well; Haiku may miss subtle gaps.

**Why Haiku for my-codebase-mapper?**
Read-only exploration and pattern extraction. No reasoning required, just structured output from file contents.

**Why `inherit` instead of passing `opus` directly?**
Claude Code's `"opus"` alias maps to a specific model version. Organizations may block older opus versions while allowing newer ones. AI returns `"inherit"` for opus-tier agents, causing them to use whatever opus version the user has configured in their session. This avoids version conflicts and silent fallbacks to Sonnet.

**Why `inherit` profile?**
Some runtimes (including OpenCode) let users switch models at runtime (`/model`). The `inherit` profile keeps all AI subagents aligned to that live selection.
