# ML Data Engineering Reference

Patterns and best practices for CV/VLM data pipelines: format conversion, splits, storage optimization, and validation.

---

## Dataset Format Cheat Sheet

| Format | File Structure | Best For |
|--------|---------------|---------|
| COCO JSON | `{images, annotations, categories}` single JSON | Detection, segmentation |
| VOC XML | Per-image XML files | Detection (legacy) |
| YOLO txt | Per-image txt `class cx cy w h` | Detection, training |
| HuggingFace datasets | Arrow files + metadata.json | All tasks, fast loading |
| WebDataset | Sharded `.tar` files | Large-scale, streaming |
| LMDB | Binary key-value store | Random access, fast I/O |
| JSONL | One JSON per line | VLM instruction tuning |
| LLaVA JSON | `[{id, image, conversations}]` | VLM fine-tuning |

---

## HuggingFace Datasets Patterns

### Loading
```python
from datasets import load_dataset, Dataset, DatasetDict
from pathlib import Path

# From HF Hub
ds = load_dataset("HuggingFaceM4/NoCaps", split="validation")

# From local files
ds = load_dataset("json", data_files={"train": "train.jsonl", "val": "val.jsonl"})
ds = load_dataset("imagefolder", data_dir="images/")

# From custom Python generator
def gen_examples():
    for path in Path("images").glob("*.jpg"):
        label = path.parent.name
        yield {"image": str(path), "label": label}

ds = Dataset.from_generator(gen_examples)
```

### Image Loading Best Practices
```python
from datasets import Dataset, Image

# Use Image feature for lazy loading (don't decode until needed)
ds = ds.cast_column("image", Image())

# Batch decode with transforms
import torchvision.transforms as T

transform = T.Compose([T.Resize(224), T.ToTensor(), T.Normalize(mean=[0.485,0.456,0.406], std=[0.229,0.224,0.225])])

def transform_batch(examples):
    examples["pixel_values"] = [transform(img.convert("RGB")) for img in examples["image"]]
    return examples

ds = ds.with_transform(transform_batch)
```

### Memory-Efficient Processing
```python
# Process in batches, don't hold everything in RAM
ds_processed = ds.map(
    process_fn,
    batched=True,
    batch_size=1000,
    num_proc=4,        # Parallel processing
    remove_columns=["raw_annotation"],  # Drop columns not needed for training
    writer_batch_size=1000,
)

# Cache to disk to avoid reprocessing
ds_processed.save_to_disk("processed_dataset/")

# Reload
from datasets import load_from_disk
ds = load_from_disk("processed_dataset/")
```

---

## WebDataset Patterns

### Packing (Write)
```python
import webdataset as wds
import io
import json
from PIL import Image

def pack_to_webdataset(samples, output_dir, shard_size=1000):
    """Pack samples into sharded WebDataset tar files.
    
    Sample format: {"id": str, "image": PIL.Image, "metadata": dict}
    Output: {output_dir}/data-{000000..N}.tar
    """
    from pathlib import Path
    Path(output_dir).mkdir(exist_ok=True)
    
    shard_idx = 0
    sink = wds.TarWriter(f"{output_dir}/data-{shard_idx:06d}.tar")
    count = 0
    
    for sample in samples:
        if count > 0 and count % shard_size == 0:
            sink.close()
            shard_idx += 1
            sink = wds.TarWriter(f"{output_dir}/data-{shard_idx:06d}.tar")
        
        # Encode image
        buf = io.BytesIO()
        sample["image"].save(buf, format="JPEG", quality=95)
        
        sink.write({
            "__key__": sample["id"],
            "jpg": buf.getvalue(),
            "json": json.dumps(sample["metadata"]).encode("utf-8"),
        })
        count += 1
    
    sink.close()
    print(f"Wrote {count} samples into {shard_idx + 1} shards")

# Write index file for dataset info
with open(f"{output_dir}/stats.json", "w") as f:
    json.dump({"total": count, "shards": shard_idx + 1, "shard_size": shard_size}, f)
```

### Loading (Read)
```python
import webdataset as wds
from torchvision import transforms

preprocess = transforms.Compose([
    transforms.Resize(224),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])

def decode_sample(sample):
    image = preprocess(sample["jpg"])
    metadata = json.loads(sample["json"])
    return image, metadata["label"]

dataset = (
    wds.WebDataset("data/data-{000000..000099}.tar", shardshuffle=True)
    .shuffle(1000)
    .decode("pil")
    .map(decode_sample)
    .batched(32)
)

loader = wds.WebLoader(dataset, num_workers=4, batch_size=None)
```

---

## LMDB Patterns

### Write
```python
import lmdb
import pickle
import numpy as np
from PIL import Image

def build_lmdb(samples, output_path, map_size_gb=50):
    env = lmdb.open(output_path, map_size=map_size_gb * (1024 ** 3))
    
    with env.begin(write=True) as txn:
        for idx, sample in enumerate(samples):
            # Store as pickle or encode image separately
            key = f"{idx:08d}".encode()
            
            # Encode image as JPEG bytes (smaller than raw array)
            buf = io.BytesIO()
            sample["image"].save(buf, format="JPEG", quality=95)
            
            value = pickle.dumps({
                "image": buf.getvalue(),  # bytes
                "label": sample["label"],
                "metadata": sample.get("metadata", {}),
            })
            txn.put(key, value)
    
    # Store length
    with env.begin(write=True) as txn:
        txn.put(b"__len__", str(idx + 1).encode())
    
    env.close()
    print(f"LMDB built: {idx+1} samples at {output_path}")
```

### Read (PyTorch Dataset)
```python
import lmdb
import pickle
from torch.utils.data import Dataset
from PIL import Image
import io

class LMDBDataset(Dataset):
    def __init__(self, lmdb_path, transform=None):
        self.env = lmdb.open(lmdb_path, readonly=True, lock=False, create=False)
        with self.env.begin() as txn:
            self.length = int(txn.get(b"__len__").decode())
        self.transform = transform
    
    def __len__(self):
        return self.length
    
    def __getitem__(self, idx):
        with self.env.begin() as txn:
            data = pickle.loads(txn.get(f"{idx:08d}".encode()))
        
        image = Image.open(io.BytesIO(data["image"])).convert("RGB")
        if self.transform:
            image = self.transform(image)
        
        return image, data["label"]
```

---

## Validation Patterns

### Image Integrity Check
```python
from PIL import Image
import hashlib
from pathlib import Path
from collections import defaultdict
from tqdm import tqdm

def validate_images(image_paths):
    """Check all images for corruption, return issues dict."""
    issues = {"corrupt": [], "unreadable": [], "too_small": []}
    hashes = defaultdict(list)
    
    for path in tqdm(image_paths, desc="Validating images"):
        try:
            img = Image.open(path)
            img.verify()  # Check file integrity
            img = Image.open(path)  # Reopen after verify
            
            # Size check (flag very small images)
            if img.width < 32 or img.height < 32:
                issues["too_small"].append(str(path))
            
            # Hash for duplicate detection
            h = hashlib.md5(Path(path).read_bytes()).hexdigest()
            hashes[h].append(str(path))
            
        except Exception as e:
            issues["corrupt"].append(f"{path}: {e}")
    
    duplicates = {h: paths for h, paths in hashes.items() if len(paths) > 1}
    return issues, duplicates
```

### Annotation Schema Validation
```python
import jsonschema

COCO_ANNOTATION_SCHEMA = {
    "type": "object",
    "required": ["images", "annotations", "categories"],
    "properties": {
        "images": {"type": "array", "items": {"required": ["id", "file_name"]}},
        "annotations": {"type": "array", "items": {"required": ["id", "image_id", "category_id", "bbox"]}},
        "categories": {"type": "array", "items": {"required": ["id", "name"]}}
    }
}

def validate_coco_json(json_path):
    with open(json_path) as f:
        data = json.load(f)
    try:
        jsonschema.validate(data, COCO_ANNOTATION_SCHEMA)
        return True, None
    except jsonschema.ValidationError as e:
        return False, str(e)
```

### Class Distribution Analysis
```python
from collections import Counter
import matplotlib.pyplot as plt

def analyze_class_distribution(labels, split_name="train"):
    counter = Counter(labels)
    total = sum(counter.values())
    
    print(f"\n{split_name} Class Distribution ({total} total):")
    for cls, count in sorted(counter.items(), key=lambda x: -x[1]):
        pct = count / total * 100
        bar = "█" * int(pct / 2)
        print(f"  {cls:30s}: {count:6d} ({pct:5.1f}%) {bar}")
    
    # Imbalance ratio
    max_count = max(counter.values())
    min_count = min(counter.values())
    imbalance_ratio = max_count / min_count
    
    if imbalance_ratio > 10:
        print(f"\n⚠️  SEVERE imbalance: {imbalance_ratio:.1f}x (consider oversampling/class weights)")
    elif imbalance_ratio > 3:
        print(f"\n⚠️  Moderate imbalance: {imbalance_ratio:.1f}x")
    else:
        print(f"\n✅ Balanced: {imbalance_ratio:.1f}x ratio")
    
    return counter, imbalance_ratio
```

---

## Common Data Issues & Fixes

| Issue | Detection | Fix |
|-------|-----------|-----|
| Corrupt images | PIL verify fails | Remove or replace |
| Near-duplicates | MD5/perceptual hash | Dedup before split |
| Data leakage | Same image in train+val | Hash-based split by image_id |
| Label noise | Confidence analysis | Clean with confident learning |
| Severe class imbalance | Counter analysis | Oversample minority / class weights |
| EXIF rotation | PIL.Image.info | Apply EXIF rotation during load |
| Resolution mismatch | Size analysis | Resize to consistent size |
| Missing captions | Null check | Filter or generate with BLIP-2 |

---

## I/O Benchmark

| Storage Format | Random Access | Sequential | Write Speed | Use Case |
|---------------|---------------|------------|-------------|---------|
| Raw files | Medium | Fast | Fast | Prototyping |
| HF datasets (Arrow) | Fast | Very Fast | Medium | General purpose |
| WebDataset | Slow | Fastest | Medium | Large-scale streaming |
| LMDB | Fastest | Fast | Medium | Fast random access |
| Zip/tar | Slowest | Medium | Fast | Archival |

**Rule of thumb:**
- < 100K samples → HuggingFace datasets or raw files
- 100K–1M samples → HuggingFace datasets + map() cache
- > 1M samples → WebDataset (streaming) or LMDB (random access)
