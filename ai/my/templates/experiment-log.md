# Experiment Log Template

Template for `.note/phases/{phase}/EXPERIMENT-LOG.md` — tracks individual experiment runs.

---

## Template

```markdown
# Experiment Log — Phase [N]: [Phase Name]

---

## Experiment [N]-[run_id]: [Brief Description]

**Date:** [YYYY-MM-DD HH:MM]
**Branch/Commit:** [git ref]
**Wandb Run:** [run URL or run ID]

### Configuration
```yaml
model:
  type: [model type]
  backbone: [backbone]
  pretrained: [checkpoint path or "scratch"]
training:
  optimizer: AdamW
  lr: 1e-4
  batch_size: 32
  epochs: 50
  scheduler: cosine
  warmup_steps: 100
data:
  dataset: [dataset name]
  train_size: [N]
  val_size: [N]
  augmentation: [list]
```

### Results
| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| [metric1] | [value] | [target] | ✅/❌ |
| [metric2] | [value] | [target] | ✅/❌ |

**Primary metric:** [metric] = [value] ([direction vs target])

### Observations
[What happened — did loss converge? Any unexpected behavior?]

### Qualitative Samples
[Sample model outputs — 2-3 representative examples]
- Input: [description]  Output: [model output]  Expected: [ground truth]

### Conclusion
[One paragraph: what worked, what didn't, what to try next]

### Next Experiment
[Specific change to try based on this result]

---
```

## Rules
- One entry per experiment run
- Link to wandb/tensorboard run for full logs
- Always include a "Next Experiment" conclusion
- Tag with commit hash for reproducibility
