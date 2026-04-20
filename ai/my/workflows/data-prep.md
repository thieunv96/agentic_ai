<purpose>
Build and execute data preparation pipelines for CV/VLM projects.
Handles format conversion, splits, preprocessing, efficient storage packing, and HF Hub push.
Produces DATA-PIPELINE.md documenting steps for reproducibility.
</purpose>

<process>

## 1. Setup

```bash
INIT=$(node ".github/my/bin/my-tools.cjs" init data-prep "0")
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Parse from $ARGUMENTS:
- Task description
- Flags: --convert, --split, --pack, --validate, --push

Read: STATE.md, PROJECT.md, KNOWLEDGE.md → Code References section.

Determine which pipeline stages to run (if no flag: ask user or infer from task description).

Always run `--validate` as final step regardless of flags.

## 2. Spawn my-data-engineer

```
<files_to_read>
.note/STATE.md
.note/PROJECT.md
.note/KNOWLEDGE.md
</files_to_read>

Task: Data Pipeline — {task}

Stages to run: {flags}
Project context: read from files above.

For each stage:

### --validate (always run last)
Check dataset integrity:
```python
# Schema validation
import json
from pathlib import Path
from PIL import Image
import hashlib

# Run checks:
# 1. Every annotation file is valid JSON
# 2. Every referenced image exists and is readable
# 3. No duplicate images (hash-based)
# 4. Annotation schema consistency (required fields present)
# 5. Class distribution check (flag severe imbalance)
# 6. Image format consistency

# Report:
validation_report = {
    "total_samples": N,
    "corrupt_images": [],
    "missing_images": [],
    "duplicate_images": [],
    "schema_errors": [],
    "class_distribution": {},
    "validation_passed": True/False
}
```

### --convert (if selected)
Format conversion between:
- COCO JSON ↔ custom JSON
- VOC XML → COCO JSON
- YOLO txt → COCO JSON
- COCO JSON → HuggingFace datasets format
- Custom → VQA format (for VLM tasks)
- Custom → instruction-tuning JSONL format

```python
# Example: COCO → HuggingFace datasets
from datasets import Dataset
import json

def convert_coco_to_hf(coco_json_path, images_dir):
    with open(coco_json_path) as f:
        coco = json.load(f)
    # Build records...
    return Dataset.from_list(records)
```

### --split (if selected)
Create train/val/test splits with:
- Stratification by class (classification) or category (detection)
- Default ratio: 80/10/10 (configurable from PROJECT.md)
- Verify class balance across splits (no more than 2x imbalance)
- Save split indices to splits.json for reproducibility

```python
from sklearn.model_selection import StratifiedShuffleSplit
import json

# stratify by label for classification
# or by image_id for detection (no leakage)
split_config = {"train": 0.8, "val": 0.1, "test": 0.1, "seed": 42}
```

### --pack (if selected)
Efficient storage for fast training I/O:

**WebDataset (for large image datasets):**
```python
import webdataset as wds
import io

# Pack into sharded .tar files (~1GB per shard)
# Naming: data-{000000..000999}.tar
# Inside each tar: {key}.jpg, {key}.json (or .txt for captions)
with wds.TarWriter(f"data-{shard_idx:06d}.tar") as sink:
    for sample in batch:
        sink.write({"__key__": sample["id"],
                    "jpg": encode_image(sample["image"]),
                    "json": json.dumps(sample["annotation"])})
```

**LMDB (for fast random access, small-medium datasets):**
```python
import lmdb
import pickle

env = lmdb.open("dataset.lmdb", map_size=50*1024**3)  # 50GB
with env.begin(write=True) as txn:
    for idx, sample in enumerate(dataset):
        txn.put(str(idx).encode(), pickle.dumps(sample))
```

### --push (if selected)
Push to HuggingFace Hub:
```python
from datasets import DatasetDict, Dataset
from huggingface_hub import HfApi

# Create dataset card automatically from DATA-PIPELINE.md
dataset_dict = DatasetDict({"train": train_ds, "val": val_ds, "test": test_ds})
dataset_dict.push_to_hub("org/dataset-name", private=True)
```

After all stages, produce DATA-PIPELINE.md:

```markdown
## Data Pipeline

*Generated: {date}*

### Source Data
- Location: {path}
- Format: {format}
- Total samples: {N}

### Pipeline Stages Run
{for each stage: what was done, input → output, key parameters}

### Validation Results
{validation report summary}

### Output
- Format: {final format}
- Location: {path or HF repo}
- Statistics:
  - Total: {N} samples
  - Train: {N} ({%})
  - Val: {N} ({%})
  - Test: {N} ({%})
  - Classes: {class distribution}

### Reproducibility
```bash
# To reproduce this pipeline:
python scripts/data_prep.py \
  --input {input_path} \
  --output {output_path} \
  --split-seed 42 \
  --stages {stages}
```

### Notes
{any issues found, decisions made, warnings}
```

Save to: .note/DATA-PIPELINE.md
Also save pipeline script to: scripts/data_prep.py
```

## 3. Commit

```bash
node ".github/my/bin/my-tools.cjs" commit "data: {task_description} - {N} samples {split_ratio} split" --files .note/DATA-PIPELINE.md scripts/data_prep.py
```

## 4. Show Summary

```
---
## 🗃️ Data Pipeline Complete

**Stages:** {stages run}
**Samples:** {train}/{val}/{test}
**Format:** {output format}
**Location:** {path}

**Validation:** {✅ PASSED | ⚠️ N issues found}

**Report:** `.note/DATA-PIPELINE.md`
**Script:** `scripts/data_prep.py`

---
```

</process>
