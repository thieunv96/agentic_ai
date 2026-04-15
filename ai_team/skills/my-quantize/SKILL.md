---
name: my-quantize
description: Model quantization and optimization — FP16/INT8/ONNX/TensorRT with accuracy-latency tradeoff analysis
argument-hint: "<phase> [--fp16|--int8|--onnx|--trt|--all] [--calibrate]"
agent: my-quantizer
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task
---

<objective>
Quantize and optimize a trained model for deployment.
Runs the quantization pipeline and produces a QUANTIZATION-REPORT.md with tradeoff analysis.

Stages (select via flags or run all):
- `--fp16`: Half-precision conversion (fastest, minimal accuracy drop)
- `--int8`: INT8 calibration with representative dataset
- `--onnx`: Export to ONNX with graph optimization
- `--trt`: TensorRT engine compilation (NVIDIA GPU)
- `--all`: Run full pipeline (default if no flag specified)

Output: `.planning/phases/[phase-dir]/QUANTIZATION-REPORT.md`

Commit: `model(phase-N): quantize to {formats} - {speedup}x speedup {delta}% accuracy`
</objective>

<execution_context>
@.github/my/workflows/quantize.md
@.github/my/references/ml-quantization.md
</execution_context>

<context>
Phase: $ARGUMENTS

Flags:
- --fp16        FP16 half-precision only
- --int8        INT8 calibration
- --onnx        ONNX export + graph optimization
- --trt         TensorRT engine
- --all         Full pipeline (default)
- --calibrate   Run calibration data generation step
</context>

<process>
Execute the quantize workflow from @.github/my/workflows/quantize.md end-to-end.
Always benchmark before and after to measure accuracy-latency tradeoff.
</process>
