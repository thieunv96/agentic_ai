# ML Quantization Reference

Patterns and best practices for model quantization and deployment optimization in CV/VLM projects.

---

## Quantization Methods Overview

| Method | Framework | Accuracy Drop | Speedup | When to Use |
|--------|-----------|--------------|---------|-------------|
| FP16 | PyTorch, ONNX | Minimal (<1%) | 1.5-2x | First step, always safe |
| Dynamic INT8 | PyTorch, ONNX | Small (1-3%) | 2-4x | Linear-heavy models, no calibration data |
| Static INT8 | PyTorch, TensorRT | Small-medium (1-5%) | 2-4x | All layer types, have calibration data |
| GPTQ INT4 | AutoGPTQ | Medium (2-5%) | 4-8x | LLMs/VLMs, size-critical |
| AWQ INT4 | AWQ | Small-medium (1-4%) | 4-8x | LLMs/VLMs, better than GPTQ at same bits |
| bitsandbytes INT8 | bitsandbytes | Small (<2%) | 2x | Transformer models, easy integration |
| TensorRT FP16 | TensorRT | Minimal (<1%) | 2-5x | NVIDIA deployment, production |
| TensorRT INT8 | TensorRT | Small (1-3%) | 4-8x | NVIDIA deployment, latency-critical |
| CoreML FP16 | coremltools | Minimal | 2x | Apple Silicon deployment |

---

## Decision Tree

```
Is the model a Transformer/LLM/VLM with >1B params?
├── YES → Use bitsandbytes INT8 or AWQ INT4 first
│         Then try ONNX for cross-platform
└── NO (CNN, ViT, etc.) →
    Target NVIDIA GPU?
    ├── YES → FP16 → TensorRT FP16 → TensorRT INT8
    └── NO (CPU/Edge/Mobile) →
        PyTorch dynamic INT8 → ONNX INT8 → CoreML (Apple)
```

---

## PyTorch Quantization

### FP16 (Fastest, Safest)
```python
model = model.half().cuda()

# For inference only
with torch.cuda.amp.autocast():
    output = model(input.half())
```

### Dynamic INT8 (CPU, Linear layers)
```python
import torch.quantization as quant

model_int8 = quant.quantize_dynamic(
    model.cpu(),  # Must be CPU
    {torch.nn.Linear, torch.nn.LSTM},  # Target layers
    dtype=torch.qint8
)
```

### Static INT8 (requires calibration dataset)
```python
import torch.quantization as quant

# Prepare
model.eval()
model.qconfig = quant.get_default_qconfig('fbgemm')  # or 'qnnpack' for ARM
quant.prepare(model, inplace=True)

# Calibrate (100-1000 representative samples)
with torch.no_grad():
    for sample in calibration_loader:
        model(sample)

# Convert
quant.convert(model, inplace=True)
torch.save(model.state_dict(), "model_int8.pt")
```

### QAT (Quantization-Aware Training)
Only use if post-training quantization accuracy drop is unacceptable:
```python
model.train()
model.qconfig = quant.get_default_qat_qconfig('fbgemm')
quant.prepare_qat(model, inplace=True)

# Fine-tune for 1-5 epochs with smaller LR (1e-5)
# ...

model.eval()
quant.convert(model, inplace=True)
```

---

## bitsandbytes (Transformers/VLMs)

### INT8 Loading
```python
from transformers import AutoModelForCausalLM, BitsAndBytesConfig
import torch

bnb_config = BitsAndBytesConfig(load_in_8bit=True)
model = AutoModelForCausalLM.from_pretrained(
    model_name_or_path,
    quantization_config=bnb_config,
    device_map="auto"
)
```

### INT4 (NF4) — Smaller, Good Quality
```python
bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",         # NormalFloat4 — best quality
    bnb_4bit_compute_dtype=torch.bfloat16,
    bnb_4bit_use_double_quant=True,    # Additional memory savings
)
```

---

## AutoGPTQ (Weight-Only INT4)

```python
from auto_gptq import AutoGPTQForCausalLM, BaseQuantizeConfig
from datasets import load_dataset

quantize_config = BaseQuantizeConfig(
    bits=4,
    group_size=128,
    desc_act=False,     # True for better accuracy, False for faster inference
)

model = AutoGPTQForCausalLM.from_pretrained(model_path, quantize_config)

# Build calibration dataset (128 samples recommended)
traindataset = [tokenizer(example["text"])["input_ids"] for example in calibration_data[:128]]
model.quantize(traindataset)
model.save_quantized(output_dir, use_safetensors=True)
```

---

## AWQ (Activation-Aware Weight Quantization)

```python
from awq import AutoAWQForCausalLM
from transformers import AutoTokenizer

model = AutoAWQForCausalLM.from_pretrained(model_path)
tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True)

quant_config = {
    "zero_point": True,
    "q_group_size": 128,
    "w_bit": 4,
    "version": "GEMM"   # or "GEMV" for batch size 1
}

model.quantize(tokenizer, quant_config=quant_config)
model.save_quantized(output_dir)
tokenizer.save_pretrained(output_dir)
```

---

## ONNX Export & Optimization

### Export
```python
import torch
import onnx

model.eval()
dummy_input = torch.randn(1, 3, 224, 224)

torch.onnx.export(
    model, dummy_input, "model.onnx",
    export_params=True,
    opset_version=17,
    do_constant_folding=True,
    input_names=["input"],
    output_names=["output"],
    dynamic_axes={
        "input": {0: "batch_size"},
        "output": {0: "batch_size"}
    }
)

# Validate
onnx_model = onnx.load("model.onnx")
onnx.checker.check_model(onnx_model)
print(f"ONNX model size: {onnx_model.ByteSize() / 1e6:.1f} MB")
```

### Optimize with ONNX Runtime
```python
import onnxruntime as ort
from onnxruntime.transformers import optimizer

# Graph optimization
sess_options = ort.SessionOptions()
sess_options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL
sess_options.optimized_model_filepath = "model_optimized.onnx"

providers = ["CUDAExecutionProvider", "CPUExecutionProvider"]
session = ort.InferenceSession("model.onnx", sess_options, providers=providers)

# ONNX INT8 quantization
from onnxruntime.quantization import quantize_dynamic, quantize_static, QuantType, CalibrationDataReader

# Dynamic INT8
quantize_dynamic("model.onnx", "model_int8.onnx", weight_type=QuantType.QInt8)
```

---

## TensorRT

```python
import tensorrt as trt
import numpy as np
from pathlib import Path

TRT_LOGGER = trt.Logger(trt.Logger.WARNING)

def build_trt_engine(onnx_path: str, engine_path: str, fp16: bool = True, int8: bool = False):
    builder = trt.Builder(TRT_LOGGER)
    network = builder.create_network(1 << int(trt.NetworkDefinitionCreationFlag.EXPLICIT_BATCH))
    parser = trt.OnnxParser(network, TRT_LOGGER)
    
    with open(onnx_path, "rb") as f:
        parser.parse(f.read())
    
    config = builder.create_builder_config()
    config.max_workspace_size = 4 << 30  # 4GB
    
    if fp16:
        config.set_flag(trt.BuilderFlag.FP16)
    if int8:
        config.set_flag(trt.BuilderFlag.INT8)
        config.int8_calibrator = create_calibrator()  # Custom calibrator
    
    engine = builder.build_engine(network, config)
    with open(engine_path, "wb") as f:
        f.write(engine.serialize())
    
    return engine

def run_trt_inference(engine_path: str, input_data: np.ndarray) -> np.ndarray:
    with open(engine_path, "rb") as f, trt.Runtime(TRT_LOGGER) as runtime:
        engine = runtime.deserialize_cuda_engine(f.read())
    
    context = engine.create_execution_context()
    # Allocate buffers and run...
```

---

## Benchmarking Protocol

Always use this standard benchmark for fair comparison:
```python
import time
import torch
import numpy as np

def benchmark_model(inference_fn, input_data, n_warmup=20, n_runs=200, device="cuda"):
    """
    Standard benchmark with warmup and CUDA sync.
    Returns: dict with mean_ms, std_ms, min_ms, throughput_fps
    """
    # Warmup
    for _ in range(n_warmup):
        _ = inference_fn(input_data)
    
    if device == "cuda":
        torch.cuda.synchronize()
    
    times = []
    for _ in range(n_runs):
        if device == "cuda":
            torch.cuda.synchronize()
        t0 = time.perf_counter()
        _ = inference_fn(input_data)
        if device == "cuda":
            torch.cuda.synchronize()
        times.append((time.perf_counter() - t0) * 1000)
    
    mean_ms = np.mean(times)
    return {
        "mean_ms": mean_ms,
        "std_ms": np.std(times),
        "min_ms": np.min(times),
        "throughput_fps": 1000 / mean_ms
    }
```

---

## Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| INT8 accuracy drops >5% | Calibration dataset not representative | Use more diverse calibration samples (512-1024) |
| ONNX export fails | Unsupported ops | Update opset version, or replace with equivalent |
| TRT engine not building | ONNX has dynamic shapes | Fix shapes or use `create_optimization_profile` |
| bitsandbytes slow on CPU | INT8 only fast on CUDA | Use ONNX INT8 for CPU deployment instead |
| Quantized model NaN outputs | Activation range too large | Use per-channel quantization or clip activations |
