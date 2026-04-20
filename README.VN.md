# Framework ML/AI Cá Nhân

Framework phát triển ML/AI cá nhân, dạng module, được hỗ trợ bởi AI — chuyên dụng cho **Computer Vision** và **Vision-Language Model (VLM)**.

> 🇬🇧 [Read in English](README.md)

---

## Tổng Quan

Framework này cung cấp quy trình làm việc có cấu trúc cho phát triển mô hình ML/AI — từ ý tưởng, nghiên cứu, huấn luyện, đánh giá, tối ưu hóa (quantization) đến phát hành. Được triển khai vào `.github/` của bất kỳ dự án ML nào và tích hợp trực tiếp với GitHub Copilot.

```
ai/  →  triển khai vào  →  .github/
```

---

## Bắt Đầu Nhanh

1. Sao chép nội dung `ai/` vào `.github/` của dự án ML
2. Khởi tạo version mới: `/my-new-version`
3. Thảo luận phase đầu tiên (thu thập context đã tích hợp sẵn): `/my-discuss 1`
4. Theo vòng lặp phase: discuss → plan → implement → evaluate

---

## Quy Trình Chính

```
/my-new-version          → Khởi tạo version: PROJECT.md + ROADMAP.md  [COMMIT]
/my-discuss <phase>      → Thu thập context + chốt quyết định → KNOWLEDGE.md + CONTEXT.md  [COMMIT]
/my-plan <phase>         → Tạo kế hoạch chi tiết → các file PLAN.md
/my-implement <phase>    → Thực thi kế hoạch → code + per-task commits  [COMMITS]
/my-evaluate <phase>     → Đánh giá metrics so với mục tiêu → EVALUATION.md
/my-debug [vấn đề]       → Debug có hệ thống với trạng thái bền vững
/my-status               → Trạng thái hiện tại và bước tiếp theo
/my-continue             → Tiếp tục từ checkpoint cuối
/my-release-version <v>  → Đóng version với tóm tắt + git tag  [COMMIT]
```

---

## Sơ Đồ Workflow Chi Tiết

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                  FRAMEWORK ML/AI CÁ NHÂN — QUY TRÌNH ĐẦY ĐỦ                │
└─────────────────────────────────────────────────────────────────────────────┘

  /my-new-version
  ├─ AskUserQuestion: loại dự án, dataset, metrics mục tiêu, compute
  ├─ Spawn: my-roadmapper
  ├─ Tạo: PROJECT.md, ROADMAP.md, STATE.md
  └─ ✅ COMMIT #1 ── "docs: initialize [project] ([N] phases)"

  ╔═══════════════════════════════════════════════════╗
  ║         VÒNG LẶP PHASE  (lặp cho từng phase)     ║
  ╚═══════════════════════════════════════════════════╝

  /my-discuss N ──────────────────────────────── THẢO LUẬN & CHỐT
  │
  │  ── Bước 0: Thu Thập Context ───────────────────────────────
  │  │
  │  │  AskUserQuestion: "Có papers, code refs, hay ý tưởng nào cần thêm không?"
  │  │  ├─ Có → thu thập papers / code refs / ý tưởng (qua AskUserQuestion)
  │  │  │       → tạo hoặc cập nhật KNOWLEDGE.md
  │  │  └─ Bỏ qua → KNOWLEDGE.md đã cập nhật
  │  │
  │  ── Bước 1: Xác Định Lĩnh Vực Quyết Định (theo loại phase) ─
  │  │
  │  │  Data Pipeline:  định dạng · augmentation · DataLoader · splits
  │  │  Architecture:   backbone · pretrained weights · head · resolution
  │  │  Training:       optimizer · scheduler · batch · precision · LoRA
  │  │  Evaluation:     benchmarks · scripts · độ sâu phân tích
  │  │
  │  ── Bước 2: Quyết Định Hàng Loạt (MẶC ĐỊNH: tất cả cùng lúc) ─
  │  │
  │  │  Một AskUserQuestion duy nhất cho tất cả lĩnh vực
  │  │  Mỗi lĩnh vực: các lựa chọn + trade-offs + gợi ý
  │  │  --step flag → chế độ tuần tự (từng lĩnh vực một)
  │  │  --auto flag → tự chọn mặc định được gợi ý, bỏ qua hỏi
  │  │
  │  ── Bước 3: Chốt ─────────────────────────────────────────────
  │  │
  │  │  Tạo: N-CONTEXT.md     (quyết định đã chốt cho planner/executor)
  │  │  Tạo: N-DISCUSSION-LOG.md  (nhật ký kiểm toán)
  │  │
  └──└─ ✅ COMMIT #2 ── "docs: phase N context locked - [tên]"

  /my-plan N ──────────────────────────────────── LẬP KẾ HOẠCH
  │
  │  ── Bước 1: Research Tùy Chọn ───────────────────────────────
  │  │
  │  │  Tự động bỏ qua khi: KNOWLEDGE.md có ≥2 papers liên quan
  │  │                       VÀ CONTEXT.md rõ ràng và đầy đủ
  │  │  Ngược lại → AskUserQuestion:
  │  │  ├─ Quick (~10 phút): quét papers chính cho loại phase này
  │  │  ├─ Deep  (~30 phút): khảo sát đầy đủ, so sánh hướng tiếp cận
  │  │  └─ Skip:  đi thẳng vào lập kế hoạch
  │  │
  │  ── Bước 2: Lập Kế Hoạch — spawn my-planner ────────────────
  │  │
  │  │  Phân tách phase thành 2–4 file PLAN.md
  │  │  Mỗi kế hoạch: 2–3 task với  files + action + verify + done
  │  │  Gán execution waves theo dependency graph
  │  │
  │  ── Bước 3: Kiểm Tra — my-plan-checker (1 lần duy nhất) ───
  │  │
  │  │  Phát hiện vấn đề → my-planner sửa MỘT lần → tiếp tục
  │  │
  │  ── Bước 4: Điều Chỉnh ──────────────────────────────────────
  │  │
  │  │  AskUserQuestion: "Có gì cần điều chỉnh trước khi chốt không?"
  │  │
  └──└─ ✗ Không commit  (kế hoạch là artifact trung gian)

  /my-implement N ─────────────────────────────── THỰC THI
  │
  │  Khám phá: liệt kê file PLAN.md, xây dựng dependency graph, gán waves
  │
  │  Wave 1 ────────────── spawn song song ─────────────────────
  │  ├─ Executor A  (plan 01)  tasks → commit từng task
  │  ├─ Executor B  (plan 02)  tasks → commit từng task
  │  └─ Executor C  (plan 03)  tasks → commit từng task
  │          Mỗi commit task: feat/fix/train/data/model(N-P): mô tả
  │
  │  Wave 2 ────────────── spawn song song ─────────────────────
  │  ├─ Executor D  (plan 04, phụ thuộc plan 01)
  │  └─ Executor E  (plan 05, phụ thuộc plan 02)
  │  (chỉ bắt đầu sau khi tất cả Wave 1 hoàn thành)
  │
  │  Mỗi plan hoàn thành → metadata commit:
  │      docs(N-NN): complete [tên-kế-hoạch] plan
  │
  │  Quy tắc deviation (tự động áp dụng khi thực thi):
  │  Rule 1: Tự sửa bugs (hành vi sai, lỗi, output không đúng)
  │  Rule 2: Tự thêm critical còn thiếu (error handling, auth, CSRF/CORS)
  │  Rule 3: Tự sửa blockers (thiếu deps, sai types, broken imports)
  │  Rule 4: DỪNG → AskUserQuestion  (thay đổi kiến trúc → người dùng quyết định)
  │
  └─ ✅ COMMITS ── per-task + per-plan metadata (nhiều atomic commits)

  /my-evaluate N ──────────────────────────────── ĐÁNH GIÁ
  │
  │  Spawn: my-evaluator
  │  Kiểm tra: metrics so với mục tiêu trong CONTEXT.md
  │  Tạo: EVALUATION.md  (bảng metrics, ví dụ, go/no-go)
  │  ✗ Không commit
  │
  ├─ ✅ GO     → /my-discuss N+1   (phase tiếp theo)
  └─ ❌ NO-GO  → /my-implement N --gaps-only
                  (tạo gap-closure PLAN.md files, thực thi lại)
                hoặc /my-debug [vấn đề]  (điều tra khoa học)

  └──────── lặp cho đến khi hoàn thành tất cả phases ──────────

  /my-release-version vX.X.X
  ├─ Tạo: VERSION-SUMMARY.md + git tag
  └─ ✅ COMMIT ── "chore: release vX.X.X"
```

---

## Kỷ Luật Commit

Chỉ có **3 điểm commit được định nghĩa** trong vòng đời dự án:

| Điểm | Thời điểm | Định dạng message |
|------|-----------|-------------------|
| **#1 Khởi tạo version** | Sau `/my-new-version` | `docs: initialize [project] ([N] phases)` |
| **#2 Chốt context** | Sau `/my-discuss N` | `docs: phase N context locked - [tên]` |
| **#3 Thực thi** | Sau mỗi task trong `/my-implement N` | `feat/train/data(N-P): [tên task]` + plan metadata |

Không commit trong: plan, evaluate, research, debug, status, hoặc continue session.

---

## Thiết Kế Tương Tác

Tất cả tương tác với người dùng đều qua **AskUserQuestion** — hộp thoại có cấu trúc trình bày các lựa chọn kèm giải thích. Điều này áp dụng ngay cả khi người dùng muốn giải thích tự do:

```
Tương tác tiêu chuẩn:
  header: "Backbone"
  question: "Backbone nào cho Phase 2?"
  options: ["ViT-B/16 (cân bằng)", "ViT-L/14 (chất lượng cao nhất)", "ConvNeXt-B (hiệu quả)"]

Khi người dùng muốn giải thích tự do:
  header: "Giải thích thêm"
  question: "Hãy chia sẻ — bạn đang nghĩ gì?"
  options: ["Xong rồi"]   ← người dùng gõ tự do qua trường Other
```

Không có plain-text prompt. Tương tác có cấu trúc nhất quán xuyên suốt.

---

## Model Profiles

Các agent được gán model dựa trên profile đang hoạt động. Một số agent được **ghim vào Claude Opus 4.7** bất kể profile vì chất lượng công việc của họ có tác động downstream cao nhất.

| Agent | `quality` | `balanced` | `budget` | Vai trò |
|-------|-----------|------------|----------|---------|
| `my-planner` | opus | opus | sonnet | Quyết định kiến trúc |
| **`my-executor`** | **opus-4-7** | **opus-4-7** | **opus-4-7** | Quyết định deviation thời gian thực |
| **`my-debugger`** | **opus-4-7** | **opus-4-7** | **opus-4-7** | Điều tra theo giả thuyết |
| **`my-quantizer`** | **opus-4-7** | **opus-4-7** | **opus-4-7** | Đánh đổi accuracy/latency |
| **`ai-phase-researcher`** | **opus-4-7** | **opus-4-7** | **opus-4-7** | Tổng hợp tài liệu |
| `my-plan-checker` | sonnet | sonnet | haiku | Xác minh kế hoạch |
| `my-codebase-mapper` | sonnet | haiku | haiku | Khám phá |

> **Các agent ghim** dùng `claude-opus-4-7` ở tất cả profiles (fallback: `claude-opus-4-6`).
> Thiết lập profile trong `.note/config.json`: `{ "model_profile": "balanced" }`

---

## Toàn Bộ 14 Lệnh

### Quản Lý Version

| Lệnh | Mô tả |
|------|-------|
| `/my-new-version` | Bắt đầu version hoặc milestone mới. Tạo cấu trúc `.note/`, PROJECT.md, STATE.md, ROADMAP.md qua `my-roadmapper`. |
| `/my-release-version <v>` | Đóng version với VERSION-SUMMARY.md, git tag và lưu trữ planning artifacts. |

### Vòng Lặp Phase

| Lệnh | Mô tả |
|------|-------|
| `/my-discuss <phase>` | Thu thập context (papers, code refs, ý tưởng → KNOWLEDGE.md) rồi chốt quyết định → CONTEXT.md + DISCUSSION-LOG.md. Mặc định: batch mode. Dùng `--step` cho tuần tự, `--auto` cho agent tự chọn. |
| `/my-plan <phase>` | Tạo file PLAN.md qua agent `my-planner`. Tự động bỏ qua research khi KNOWLEDGE.md đầy đủ. Xác minh với `my-plan-checker` (1 lần). |
| `/my-implement <phase>` | Thực thi PLAN.md theo từng wave song song qua các agent `my-executor`. Per-task commits + plan metadata commits. |
| `/my-evaluate <phase> [--quick\|--full]` | Đánh giá mô hình so với mục tiêu trong CONTEXT.md → EVALUATION.md với quyết định go/no-go. |

### Debug & Điều Hướng

| Lệnh | Mô tả |
|------|-------|
| `/my-debug [vấn đề]` | Debug khoa học — bằng chứng → giả thuyết → kiểm tra. Duy trì qua `/clear`. Chạy không tham số để tiếp tục. |
| `/my-status` | Hiển thị phase hiện tại, metrics mới nhất, vấn đề mở, lệnh tiếp theo được đề xuất. |
| `/my-continue` | Tiếp tục từ checkpoint cuối dựa vào STATE.md. |

### Nghiên Cứu & Khám Phá

| Lệnh | Mô tả |
|------|-------|
| `/my-research [--quick\|--deep] <chủ đề>` | Nghiên cứu ML frontier/gray-area. `--quick`: 3-5 papers + khuyến nghị. `--deep`: khảo sát tài liệu đầy đủ, phân tích khoảng trống, tổng hợp. Output: `.note/research/{slug}-RESEARCH.md` |
| `/my-map-codebase [đường dẫn]` | Phân tích codebase thành 7 tài liệu có cấu trúc: STACK, ARCHITECTURE, STRUCTURE, CONVENTIONS, TESTING, INTEGRATIONS, CONCERNS. |

### Kỹ Thuật Dữ Liệu

| Lệnh | Mô tả |
|------|-------|
| `/my-data-prep <task> [--convert\|--split\|--pack\|--validate\|--push]` | Xây dựng pipeline dữ liệu CV/VLM. Chuyển đổi định dạng (COCO↔VOC↔YOLO↔HF), tách tập với stratification, đóng gói WebDataset/LMDB, kiểm tra tính toàn vẹn, đẩy lên HuggingFace Hub. |

### Tối Ưu Hóa Mô Hình

| Lệnh | Mô tả |
|------|-------|
| `/my-quantize <phase> [--fp16\|--int8\|--onnx\|--trt\|--all]` | Pipeline quantization đầy đủ: FP16, INT8 calibration, ONNX export, TensorRT engine. Benchmark độ chính xác vs độ trễ. Output: `QUANTIZATION-REPORT.md`. |

### Báo Cáo

| Lệnh | Mô tả |
|------|-------|
| `/my-report [session\|experiment\|version]` | `session`: tóm tắt công việc hôm nay. `experiment`: bảng so sánh metrics qua các lần chạy. `version`: tóm tắt đầy đủ với model card. |

---

## Các Agent

| Agent | Vai Trò | Model |
|-------|---------|-------|
| `my-planner` | Tạo PLAN.md với phân tích task theo chuẩn ML | opus |
| `my-executor` | Triển khai code Python/PyTorch/ML | **opus-4-7** |
| `my-roadmapper` | Tạo roadmap các phase từ yêu cầu ML | sonnet |
| `my-researcher` | Nghiên cứu papers CV/VLM, kiến trúc, SOTA | **opus-4-7** |
| `my-research-synthesizer` | Tổng hợp nghiên cứu thành insights thực tế | sonnet |
| `my-evaluator` | Đánh giá mô hình: metrics, benchmarks, go/no-go | sonnet |
| `my-data-analyst` | Phân tích dataset CV (COCO, ImageNet, VQA...) | sonnet |
| `my-data-engineer` | Xây dựng pipeline dữ liệu, chuyển đổi định dạng | sonnet |
| `my-debugger` | Debug vấn đề training/CUDA/data pipeline | **opus-4-7** |
| `my-plan-checker` | Kiểm tra chất lượng plan trước khi thực thi | sonnet |
| `my-codebase-mapper` | Phân tích codebase/code reference | haiku |
| `my-quantizer` | Quantize mô hình (FP16/INT8/ONNX/TensorRT/CoreML) | **opus-4-7** |

---

## Cấu Trúc `.note/`

```
.note/
├── PROJECT.md              # Task, dataset, metrics mục tiêu, compute
├── ROADMAP.md              # Các phase với mục tiêu
├── STATE.md                # Trạng thái dự án — phase hiện tại, metric tốt nhất
├── KNOWLEDGE.md            # Papers, code refs, insights chính (xây dựng trong /my-discuss)
├── DATA-PIPELINE.md        # Pipeline dữ liệu (nếu đã chạy)
├── VERSION-REPORT.md       # Tóm tắt version cuối (sau khi release)
├── research/
│   └── {slug}-RESEARCH.md
├── reports/
│   ├── session-{date}.md
│   ├── experiments-{date}.md
│   └── version-{v}-{date}.md
├── codebase/               # Bản đồ codebase (nếu đã map)
│   ├── STACK.md
│   ├── ARCHITECTURE.md
│   └── ...
├── debug/
│   └── resolved/
└── phases/
    └── 01-{tên}/
        ├── 01-CONTEXT.md
        ├── 01-DISCUSSION-LOG.md
        ├── 01-01-PLAN.md
        ├── 01-01-SUMMARY.md
        ├── EVALUATION.md
        └── QUANTIZATION-REPORT.md
```

---

## Quy Ước Commit

```
feat(phase-N): mô tả        — tính năng mới
fix(phase-N): mô tả         — sửa lỗi
train(phase-N): mô tả       — code training
data(phase-N): mô tả        — dataset/pipeline
model(phase-N): mô tả       — kiến trúc
eval(phase-N): mô tả        — code đánh giá
experiment(phase-N): mô tả  — config/kết quả thí nghiệm
docs(phase-N): mô tả        — metadata hoàn thành kế hoạch
docs: mô tả                 — tài liệu cấp dự án
chore: mô tả                — release, tooling
```

---

## Cấu Trúc Repository

```
ai/                            ← triển khai vào .github/
├── skills/my-*/SKILL.md       ← điểm vào slash command
├── agents/my-*.agent.md       ← agent ML chuyên biệt
├── my/
│   ├── workflows/*.md         ← logic workflow (discuss, plan, implement, v.v.)
│   ├── references/*.md        ← cơ sở kiến thức ML (model profiles, git, TDD, v.v.)
│   ├── templates/             ← template artifact
│   └── bin/my-tools.cjs       ← CLI quản lý state, commits, config
├── hooks/pre-tool-use.json    ← hook an toàn
└── scripts/                   ← tiện ích Python
```
