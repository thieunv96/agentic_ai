# ML Verification Patterns

How to verify ML phase outcomes are real implementations, not stubs or broken pipelines.

## Core Principle

**Training ran ≠ Model works.**

Verification must check:
1. **Exists** — Files at expected paths
2. **Runs** — Scripts execute without errors
3. **Converges** — Training loss decreased
4. **Metrics** — Evaluation metrics meet targets from CONTEXT.md
5. **Quality** — Qualitative output samples look reasonable

## 1. Model Existence Check

```bash
# Model files exist and are not empty
[ -f "src/models/vlm.py" ] || echo "MISSING: model file"
[ $(wc -l < "src/models/vlm.py") -gt 50 ] || echo "STUB: model too short"

# Check for stub patterns
grep -E "pass$|NotImplementedError|TODO|FIXME" src/models/*.py
grep -E "return None|raise NotImplementedError" src/models/*.py
```

## 2. Training Pipeline Check

```bash
# Smoke test: can training start without errors?
python train.py --config configs/default.yaml --max-steps 10 --dry-run

# Verify checkpoint was saved
[ -f "checkpoints/best.pth" ] || [ -f "checkpoints/epoch_001.pth" ]

# Verify training log exists
[ -f "logs/train.log" ] || ls runs/ 2>/dev/null | head -5
```

## 3. Convergence Check

```python
# Read training log and verify loss decreased
import json

def check_convergence(log_file: str, metric: str = "train/loss") -> bool:
    losses = []
    with open(log_file) as f:
        for line in f:
            entry = json.loads(line)
            if metric in entry:
                losses.append(entry[metric])
    
    if len(losses) < 10:
        return False, "Not enough training steps logged"
    
    early_avg = sum(losses[:5]) / 5
    late_avg = sum(losses[-5:]) / 5
    decreased = late_avg < early_avg * 0.9  # 10% decrease minimum
    
    return decreased, f"Loss: {early_avg:.4f} → {late_avg:.4f}"
```

## 4. Metric Verification

```python
# Compare eval metrics against targets from CONTEXT.md
def verify_metrics(eval_results: dict, targets: dict) -> dict:
    report = {}
    for metric, target in targets.items():
        achieved = eval_results.get(metric, None)
        if achieved is None:
            report[metric] = {"status": "MISSING", "target": target}
        elif achieved >= target:
            report[metric] = {"status": "PASS", "achieved": achieved, "target": target}
        else:
            report[metric] = {"status": "FAIL", "achieved": achieved, "target": target, 
                             "gap": target - achieved}
    return report
```

## 5. Data Pipeline Check

```python
# Verify dataloader works end-to-end
from torch.utils.data import DataLoader
from src.data.dataset import YourDataset

dataset = YourDataset("data/train", split="train")
assert len(dataset) > 0, "Dataset empty"

loader = DataLoader(dataset, batch_size=2, num_workers=0)
batch = next(iter(loader))

# Check shapes
assert batch["images"].shape[1:] == (3, 224, 224), f"Wrong image shape: {batch['images'].shape}"
assert "labels" in batch or "captions" in batch, "Missing labels"

print(f"✅ Data pipeline OK — {len(dataset)} samples, batch shape: {batch['images'].shape}")
```

## 6. VLM-Specific Checks

```python
# Verify model can process image+text input
from src.models.vlm import VLM
import torch

model = VLM.from_pretrained("checkpoints/best.pth")
model.eval()

# Test inference
with torch.no_grad():
    output = model.generate(
        images=torch.randn(1, 3, 336, 336),
        prompts=["Describe this image:"],
        max_new_tokens=50,
    )
    assert len(output[0]) > 0, "Empty output"
    assert not any(t.item() == model.eos_token_id for t in output[0][:-1]), "EOS too early"
```

## 7. Stub Detection for ML

```python
# RED FLAGS in ML code:

# Empty training loop
for batch in dataloader:
    pass  # ← STUB

# Fake metrics
return {"accuracy": 1.0}  # ← hardcoded

# Untrained model used for evaluation
model = Model()  # ← no checkpoint loaded
accuracy = evaluate(model)  # ← will be random

# DataLoader that returns dummy data
class Dataset:
    def __getitem__(self, idx):
        return torch.zeros(3, 224, 224), 0  # ← dummy data
```

## 8. Evaluation Checklist

For each phase type:

**Data Pipeline Phase:**
- [ ] Dataset loads without errors
- [ ] Correct number of samples (train/val/test)
- [ ] Images and labels are correctly paired
- [ ] Augmentations applied correctly (verify with visualization)
- [ ] DataLoader throughput acceptable (images/sec benchmark)

**Architecture Phase:**
- [ ] Forward pass runs without errors
- [ ] Output shapes are correct
- [ ] No NaN in outputs on normal inputs
- [ ] Parameter count matches expected
- [ ] Gradient flows (no dead weights)

**Training Phase:**
- [ ] Loss decreases over training
- [ ] No NaN/Inf in loss
- [ ] Learning rate schedule applies correctly
- [ ] Checkpoints saved at expected intervals
- [ ] Wandb/tensorboard logging active

**Evaluation Phase:**
- [ ] Evaluation script runs to completion
- [ ] Metrics match known baselines on reference data
- [ ] Results logged to wandb/tensorboard
- [ ] Qualitative samples look reasonable
