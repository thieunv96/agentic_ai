# Framework ML/AI Cá Nhân

Framework phát triển ML/AI cá nhân, dạng module, được hỗ trợ bởi AI — chuyên dụng cho **Computer Vision** và **Vision-Language Model (VLM)**.

> 🇬🇧 [Read in English](README.md)

---

## Tổng Quan

Framework này cung cấp quy trình làm việc có cấu trúc cho phát triển mô hình ML/AI — từ ý tưởng, nghiên cứu, huấn luyện, đánh giá, tối ưu hóa (quantization) đến phát hành. Được triển khai vào `.github/` của bất kỳ dự án ML nào và tích hợp trực tiếp với GitHub Copilot.

```
ai_team/  →  triển khai vào  →  .github/
```

---

## Bắt Đầu Nhanh

1. Sao chép nội dung `ai_team/` vào `.github/` của dự án ML
2. Khởi tạo version mới: `/my-new-version`
3. Nạp ngữ cảnh (papers, code refs, ý tưởng): `/my-provide-context`
4. Theo vòng lặp workflow bên dưới

---

## Quy Trình Chính

```
/my-new-version          → Khởi tạo version/milestone mới
/my-provide-context      → Nạp papers, code refs, ý tưởng → KNOWLEDGE.md + ROADMAP.md
/my-discuss <phase>      → Thảo luận và chốt quyết định của phase → CONTEXT.md
/my-plan <phase>         → Tạo kế hoạch chi tiết → PLAN.md
/my-implement <phase>    → Thực thi kế hoạch → code + commits
/my-evaluate <phase>     → Đánh giá metrics so với mục tiêu → EVALUATION.md
/my-debug [vấn đề]       → Debug có hệ thống với trạng thái bền vững
/my-status               → Trạng thái hiện tại và bước tiếp theo
/my-continue             → Tiếp tục từ checkpoint cuối
/my-release-version <v>  → Đóng version với tóm tắt + git tag
```

---

## Sơ Đồ Workflow

```
┌─────────────────────────────────────────────────────────────────────┐
│                  FRAMEWORK ML/AI CÁ NHÂN — QUY TRÌNH               │
└─────────────────────────────────────────────────────────────────────┘

  /my-new-version
      Hỏi các câu setup (mỗi câu có giải thích TẠI SAO)
      Hỏi: "Có gì cần bổ sung không?"
      Tạo: PROJECT.md, STATE.md
      ✗ Không commit

  /my-provide-context [--papers] [--refs] [--idea]
      Nạp: papers / code refs / ý tưởng → KNOWLEDGE.md
      Hỏi: "Có gì muốn thêm trước khi tạo roadmap không?"
      Hỏi: "Có chạy research không?" ──────────────────────[Tùy chọn]
              ├─ Quick research  (gợi ý: chủ đề quen/rõ ràng)
              ├─ Deep research   (gợi ý: phức tạp/chưa chắc)
              └─ Skip            (gợi ý: context đã đủ rõ)
      Tạo: ROADMAP.md
      ✅ COMMIT #1 ── "docs: setup context"

  ╔══════════════════════════════════════════╗
  ║         VÒNG LẶP PHASE (lặp N lần)      ║
  ╚══════════════════════════════════════════╝

  /my-discuss N
      Trình bày các lĩnh vực quyết định (kèm bối cảnh + trade-offs)
      Thảo luận từng lĩnh vực (giải thích TẠI SAO trước mỗi câu hỏi)
      Hỏi: "Có gì cần thêm trước khi chốt context không?"
      Tạo: N-CONTEXT.md, N-DISCUSSION-LOG.md
      ✗ Không commit

  /my-plan N
      Hỏi: "Có chạy research cho phase này không?" ─────────[Tùy chọn]
              ├─ Quick / Deep / Skip
      Spawn my-planner → PLAN.md
      Xác minh với my-plan-checker
      Hỏi: "Có gì cần điều chỉnh trước khi chốt không?"
      ✅ COMMIT #2 ── "docs: plan phase N"

  /my-implement N
      Spawn my-executor agents (song song theo wave)
      Executor viết code vào disk  ✗ không commit từng task
      Tất cả waves xong → SUMMARY.md
      ✅ COMMIT #3 ── "feat/train/data(phase-N): implement ..."

  /my-evaluate N
      Kiểm tra metrics so với mục tiêu trong CONTEXT.md
      Tạo: EVALUATION.md với quyết định go/no-go
      ✗ Không commit
      │
      ├─ ✅ Go  → phase tiếp theo (/my-discuss N+1)
      └─ ❌ No-go → /my-debug hoặc lặp lại

  └──────── lặp cho đến khi hết phases ───────────────────┘

  /my-release-version vX.X.X
      Tạo: VERSION-SUMMARY.md + git tag
      ✅ COMMIT ── "chore: release vX.X.X"
```

> **Kỷ luật commit:** Chỉ có 3 điểm commit cho mỗi phase (roadmap / plan / implementation).
> Không commit trong: discuss, evaluate, research, debug, hoặc status session.

---

## Toàn Bộ 15 Lệnh

### Quản Lý Version

| Lệnh | Mô tả |
|------|-------|
| `/my-new-version` | Bắt đầu version hoặc milestone mới. Tạo cấu trúc `.planning/`, PROJECT.md, STATE.md, ROADMAP.md. |
| `/my-provide-context [--papers] [--refs] [--idea] [--update]` | Nạp tài liệu ML (papers, code refs, ý tưởng) → KNOWLEDGE.md + ROADMAP.md ban đầu. Hỏi người dùng trước khi chạy research. |
| `/my-release-version <v>` | Đóng version với VERSION-SUMMARY.md, git tag và lưu trữ planning artifacts. |

### Vòng Lặp Phase

| Lệnh | Mô tả |
|------|-------|
| `/my-discuss <phase>` | Chốt quyết định triển khai cho một phase → CONTEXT.md + DISCUSSION-LOG.md. Dùng `--auto` để agent tự chọn mặc định, `--batch` để quyết định tất cả cùng lúc. |
| `/my-plan <phase>` | Tạo PLAN.md với danh sách task và tiêu chí xác minh thông qua agent `my-planner`. |
| `/my-implement <phase>` | Thực thi PLAN.md theo từng bước nguyên tử qua agent `my-executor`. Tạo SUMMARY.md + commits cho từng task. |
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
| `/my-research [--quick\|--deep] <chủ đề>` | Nghiên cứu ML frontier/gray-area. `--quick`: 3-5 papers + khuyến nghị. `--deep`: khảo sát tài liệu đầy đủ, phân tích khoảng trống, tổng hợp. Output: `.planning/research/{slug}-RESEARCH.md` |
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

| Agent | Vai Trò |
|-------|---------|
| `my-planner` | Tạo PLAN.md với phân tích task theo chuẩn ML |
| `my-executor` | Triển khai code Python/PyTorch/ML |
| `my-roadmapper` | Tạo roadmap các phase từ yêu cầu ML |
| `my-researcher` | Nghiên cứu papers CV/VLM, kiến trúc, SOTA |
| `my-research-synthesizer` | Tổng hợp nghiên cứu thành insights thực tế |
| `my-evaluator` | Đánh giá mô hình: metrics, benchmarks, go/no-go |
| `my-data-analyst` | Phân tích dataset CV (COCO, ImageNet, VQA...) |
| `my-data-engineer` | Xây dựng pipeline dữ liệu, chuyển đổi định dạng |
| `my-debugger` | Debug vấn đề training/CUDA/data pipeline |
| `my-plan-checker` | Kiểm tra chất lượng plan trước khi thực thi |
| `my-codebase-mapper` | Phân tích codebase/code reference |
| `my-quantizer` | Quantize mô hình (FP16/INT8/ONNX/TensorRT/CoreML) |

---

## Cấu Trúc `.planning/`

```
.planning/
├── PROJECT.md              # Task, dataset, metrics mục tiêu, compute
├── ROADMAP.md              # Các phase với mục tiêu
├── STATE.md                # Trạng thái dự án — phase hiện tại, metric tốt nhất
├── KNOWLEDGE.md            # Papers, code refs, insights chính
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
train(phase-N): mô tả       — code training
data(phase-N): mô tả        — dataset/pipeline
model(phase-N): mô tả       — kiến trúc
eval(phase-N): mô tả        — code đánh giá
experiment(phase-N): mô tả  — config/kết quả thí nghiệm
docs: mô tả                 — tài liệu planning
feat(phase-N): mô tả        — tính năng mới
fix(phase-N): mô tả         — sửa lỗi
```

---

## Cấu Trúc Repository

```
ai_team/                       ← triển khai vào .github/
├── skills/my-*/SKILL.md       ← điểm vào slash command
├── agents/my-*.agent.md       ← agent ML chuyên biệt
├── my/
│   ├── workflows/*.md         ← logic workflow
│   ├── references/*.md        ← cơ sở kiến thức ML
│   ├── templates/             ← template artifact
│   └── bin/my-tools.cjs       ← CLI quản lý state, commits, config
├── hooks/pre-tool-use.json    ← hook an toàn
└── scripts/                   ← tiện ích Python
```
