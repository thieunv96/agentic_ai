# ML Experiment Tracking

Reference for experiment tracking with wandb, tensorboard, and MLflow in Asilla workflows.

## Weights & Biases (wandb) — Primary

```python
import wandb

# Initialize run
wandb.init(
    project="your-project-name",
    name=f"phase-{phase}-{run_name}",
    config={
        "learning_rate": 1e-4,
        "batch_size": 32,
        "model": "ViT-B/16",
        "dataset": "COCO",
        "epochs": 50,
    }
)

# Log metrics during training
wandb.log({
    "train/loss": loss.item(),
    "train/accuracy": acc,
    "val/loss": val_loss,
    "val/mAP": map_score,
    "epoch": epoch,
})

# Log model checkpoint
wandb.save("checkpoints/best.pth")

# Log evaluation artifacts
wandb.log({"eval/predictions": wandb.Table(data=predictions, columns=["image", "pred", "gt"])})

# Finish run
wandb.finish()
```

## TensorBoard — Secondary

```python
from torch.utils.tensorboard import SummaryWriter

writer = SummaryWriter(f"runs/phase-{phase}-{run_name}")

# Scalars
writer.add_scalar("Loss/train", loss, global_step)
writer.add_scalar("Metrics/mAP", map_score, epoch)

# Images
writer.add_images("Predictions/batch", pred_images, global_step)

# Hyperparameters
writer.add_hparams(
    {"lr": lr, "batch_size": bs},
    {"hparam/mAP": best_map}
)

writer.close()
```

## MLflow — Lightweight Tracking

```python
import mlflow

with mlflow.start_run(run_name=f"phase-{phase}-{experiment_name}"):
    mlflow.log_params({
        "learning_rate": 1e-4,
        "model": "ViT-B/16",
    })
    mlflow.log_metric("val_mAP", map_score, step=epoch)
    mlflow.pytorch.log_model(model, "model")
```

## Checkpoint Management

```python
# Save checkpoint
torch.save({
    "epoch": epoch,
    "model_state_dict": model.state_dict(),
    "optimizer_state_dict": optimizer.state_dict(),
    "best_metric": best_map,
    "config": config,
}, f"checkpoints/epoch_{epoch:03d}.pth")

# Save best separately
if current_map > best_map:
    best_map = current_map
    torch.save(checkpoint, "checkpoints/best.pth")

# Load checkpoint
checkpoint = torch.load("checkpoints/best.pth", map_location="cpu")
model.load_state_dict(checkpoint["model_state_dict"])
```

## Reproducibility

```python
import random, numpy as np, torch

def set_seed(seed: int = 42):
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False

set_seed(42)
```

## Docker Pattern for Reproducible Training

```dockerfile
FROM pytorch/pytorch:2.2.0-cuda11.8-cudnn8-runtime

WORKDIR /workspace

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD ["python", "train.py", "--config", "configs/default.yaml"]
```

## Commit Convention for Experiments

| Type | When | Example |
|------|------|---------|
| `feat({phase})` | New feature/component | `feat(03): add LoRA adapter to vision encoder` |
| `train({phase})` | Training run changes | `train(03): increase batch size to 64, add warmup` |
| `data({phase})` | Dataset/preprocessing | `data(01): add random horizontal flip augmentation` |
| `model({phase})` | Architecture changes | `model(02): replace linear head with MLP projection` |
| `eval({phase})` | Evaluation additions | `eval(04): add TextVQA benchmark` |
| `fix({phase})` | Bug fixes | `fix(03): fix NaN in loss when padding tokens present` |
