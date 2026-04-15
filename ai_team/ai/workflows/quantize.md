<purpose>
Model quantization pipeline: FP32 → FP16 → INT8 → ONNX → TensorRT/CoreML.
Benchmarks accuracy-latency tradeoff at each stage.
Produces QUANTIZATION-REPORT.md with go/no-go decision per format.
</purpose>

<process>

## 1. Setup

```bash
INIT=$(node ".github/ai/bin/ai-tools.cjs" init plan-phase "$PHASE")
if [[ "$INIT" == @file:* ]]; then INIT=$(cat "${INIT#@file:}"); fi
```

Parse from $ARGUMENTS:
- Phase number
- Flags: --fp16, --int8, --onnx, --trt, --all, --calibrate

Read: STATE.md, PROJECT.md, KNOWLEDGE.md, phase CONTEXT.md, EVALUATION.md (for baseline metrics).

Determine target formats (default: --all if no flag provided).

## 2. Spawn ai-quantizer

```
<files_to_read>
.planning/STATE.md
.planning/PROJECT.md
.planning/KNOWLEDGE.md
.planning/phases/[phase-dir]/[N]-CONTEXT.md
.planning/phases/[phase-dir]/EVALUATION.md
</files_to_read>

Task: Quantize Phase [N] model — [{formats}]

Target formats: {formats}
Project context: read from files above.
Baseline metrics: read from EVALUATION.md.

For each format, follow this pipeline:

### Baseline (FP32)
Run inference benchmark on validation set:
- Metrics: accuracy/mAP/other (from CONTEXT.md targets)
- Latency: average inference time per sample (ms)
- Memory: GPU/CPU memory usage (MB)
- Throughput: samples/sec

### FP16 (if selected)
Convert model to half precision:
```python
model = model.half()
```
Benchmark same metrics.

### INT8 (if selected)
Post-training quantization:
```python
# PyTorch: dynamic INT8
import torch.quantization
model_int8 = torch.quantization.quantize_dynamic(model, {torch.nn.Linear}, dtype=torch.qint8)

# Or: static INT8 with calibration
# Requires calibration dataset — sample 512-1024 representative images
```
If --calibrate flag: generate calibration dataset first (random sample from val set).
Benchmark same metrics.

### ONNX Export (if selected)
```python
torch.onnx.export(model, dummy_input, "model.onnx",
    input_names=["input"], output_names=["output"],
    dynamic_axes={"input": {0: "batch"}, "output": {0: "batch"}},
    opset_version=17)

# Graph optimization
import onnxruntime as ort
sess_options = ort.SessionOptions()
sess_options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL
session = ort.InferenceSession("model.onnx", sess_options)
```
Benchmark with ONNX Runtime.

### TensorRT (if selected and NVIDIA GPU available)
```python
import tensorrt as trt
# Build engine with FP16 or INT8 precision
# Run TRT benchmark
```

### CoreML (if selected and Apple target)
```python
import coremltools as ct
model_cml = ct.convert(model_onnx, inputs=[ct.TensorType(shape=(1, 3, H, W))])
```

Produce QUANTIZATION-REPORT.md:

## Model Info
- Architecture: {name}
- Task: {task}
- Original checkpoint: {path}

## Results

| Format | Accuracy | Latency (ms) | Memory (MB) | Size (MB) | Speedup vs FP32 | Accuracy Drop |
|--------|----------|--------------|-------------|-----------|-----------------|---------------|
| FP32 (baseline) | X | X | X | X | 1.0x | - |
| FP16 | X | X | X | X | Xx | X% |
| INT8 | X | X | X | X | Xx | X% |
| ONNX | X | X | X | X | Xx | X% |
| TensorRT | X | X | X | X | Xx | X% |

## Go/No-Go per Format

| Format | Decision | Reasoning |
|--------|---------|-----------|
| FP16 | ✅ GO | <2% accuracy drop, 1.8x speedup |
| INT8 | ⚠️ BORDERLINE | 3.5% drop — acceptable only if latency is critical |

## Recommended Deployment Format
{recommendation with reasoning}

## Files Produced
- `models/model_fp16.pt`
- `models/model_int8.pt`
- `models/model.onnx`
- `models/model_trt.engine` (if TensorRT)

Save to: .planning/phases/[phase-dir]/QUANTIZATION-REPORT.md
Also save optimized model files to: models/ directory
```

## 3. Commit Results

```bash
# Extract speedup and best format from report
node ".github/ai/bin/ai-tools.cjs" commit "model(phase-[N]): quantize [{formats}] - {best_format} {speedup}x speedup" --files .planning/phases/[phase-dir]/QUANTIZATION-REPORT.md models/
```

## 4. Show Summary

```
---
## ⚡ Quantization Complete

**Phase [N]** | Formats: {formats}

| Format | Speedup | Accuracy Drop |
|--------|---------|---------------|
[table rows for each format]

**Recommended:** {format} — {reasoning}
**Report:** `.planning/phases/[phase-dir]/QUANTIZATION-REPORT.md`

---
```

</process>
