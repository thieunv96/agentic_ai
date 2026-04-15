# Model Evaluation Report Template

Template for `.planning/phases/{phase}/EVALUATION.md`

---

## Template

```markdown
# Evaluation Report — Phase [N]: [Phase Name]

**Date:** [YYYY-MM-DD]
**Model checkpoint:** [path]
**Evaluator:** my-evaluator

---

## Summary

**Decision: GO / NO-GO**

Primary metric: [metric] = [value] vs target [target] → [PASS/FAIL]

---

## Quantitative Results

### Main Benchmarks
| Benchmark | Metric | Target | Achieved | Status |
|-----------|--------|--------|----------|--------|
| [name] | [metric] | [target] | [value] | ✅/❌ |

### Baseline Comparison
| | This Model | Baseline | Delta |
|-|-----------|----------|-------|
| [metric1] | [value] | [value] | [+/-] |

---

## Training Analysis

**Final training loss:** [value]
**Convergence:** [description — e.g., "converged at epoch 35, plateau after"]
**Overfitting:** [none / mild / severe]
**Best checkpoint:** epoch [N] at [metric]=[value]

---

## Qualitative Analysis

### Success Cases
[3-5 examples where model works well]
- Input: [description] → Output: [model output]

### Failure Cases
[3-5 examples where model fails or struggles]
- Input: [description] → Output: [model output] | Expected: [ground truth]
- Pattern: [what these failures have in common]

### Edge Cases
[Unusual inputs and model behavior]

---

## Gap Analysis

[If NO-GO only]

| Metric | Target | Achieved | Gap | Proposed Fix |
|--------|--------|----------|-----|--------------|
| [metric] | [target] | [value] | [gap] | [fix] |

Gap closure plans created: [Y/N]

---

## Recommendation

[GO: Proceed to next phase / Release version]
[NO-GO: Run /my-implement N --gaps-only to fix [list of gaps]]
```
