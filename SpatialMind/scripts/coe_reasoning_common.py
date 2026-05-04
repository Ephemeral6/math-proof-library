"""Shared rendering / writing utilities for the CoE Geometric Reasoning Benchmark.

Used by `generate_coe_reasoning_dim{1,2,3,5,6}.py`. Dimension 4 has its own
inline copy (predates this module).
"""

from __future__ import annotations

import json
import os

ANSWER_FORMAT = """
请严格按照以下格式输出答案（这部分会被自动评分系统解析）：

[ANSWER]
(a) <答案>
(b) <答案>
(c) <答案>
[/ANSWER]

答案规范：
- 整数请直接写数字（如 3、130）。
- 集合/列表请用花括号或方括号，元素间用逗号分隔（如 {0, 3} 或 [0,3]）。
- 含多个整数的答案请用箭头或逗号分隔（如 130 -> 92 或 130, 92）。
- 字符串答案请直接写文字（如 yes / no, preserved / changed）。
- 不要在 [ANSWER] 块内添加解释。

随后用 [REASONING] ... [/REASONING] 提供推理过程。
"""


def render_baseline(stem, subqs):
    parts = [stem, ""]
    parts.append("请回答以下子问题：")
    for sq in subqs:
        parts.append(f"  {sq['label']} {sq['text']}")
    parts.append(ANSWER_FORMAT)
    return "\n".join(parts)


def render_cot(stem, subqs):
    parts = [stem, ""]
    parts.append("请回答以下子问题。Let's think step by step —— "
                 "请逐步推理，先分析每个子问题的关键概念，再给出答案。")
    for sq in subqs:
        parts.append(f"  {sq['label']} {sq['text']}")
    parts.append(ANSWER_FORMAT)
    return "\n".join(parts)


def render_coe_r(stem, subqs, R, R_label="Relation"):
    parts = [stem, ""]
    parts.append(f"以下是 CoE 引擎提供的关系数据 ({R_label})：")
    parts.append("```json")
    parts.append(json.dumps(R, ensure_ascii=False, indent=2))
    parts.append("```")
    parts.append("")
    parts.append("请基于上述数据回答以下子问题：")
    for sq in subqs:
        parts.append(f"  {sq['label']} {sq['text']}")
    parts.append(ANSWER_FORMAT)
    return "\n".join(parts)


def render_coe_ctr(stem, subqs, R, T, C):
    parts = [stem, ""]
    parts.append("以下是 CoE 引擎提供的完整数据。")
    parts.append("")
    parts.append("### Relation (R)")
    parts.append("```json")
    parts.append(json.dumps(R, ensure_ascii=False, indent=2))
    parts.append("```")
    parts.append("")
    parts.append("### Transform (T)")
    parts.append("```json")
    parts.append(json.dumps(T, ensure_ascii=False, indent=2))
    parts.append("```")
    parts.append("")
    parts.append("### Counterfactual (C)")
    parts.append("```json")
    parts.append(json.dumps(C, ensure_ascii=False, indent=2))
    parts.append("```")
    parts.append("")
    parts.append("请基于上述数据回答以下子问题：")
    for sq in subqs:
        parts.append(f"  {sq['label']} {sq['text']}")
    parts.append(ANSWER_FORMAT)
    return "\n".join(parts)


def make_question(qid, qtype, stem, subqs, ground_truth, R, T, C):
    """Assemble a question dict with all 4 prompts pre-rendered."""
    return {
        "question_id": qid,
        "type": qtype,
        "stem": stem,
        "subquestions": subqs,
        "ground_truth": ground_truth,
        "coe_data": {"R": R, "T": T, "C": C},
        "prompts": {
            "baseline": render_baseline(stem, subqs),
            "cot": render_cot(stem, subqs),
            "coe_r": render_coe_r(stem, subqs, R),
            "coe_ctr": render_coe_ctr(stem, subqs, R, T, C),
        },
    }


def write_benchmark(out_dir, dimension, dimension_name, questions, summary_keys=None):
    os.makedirs(out_dir, exist_ok=True)
    out = {
        "benchmark": "coe_reasoning",
        "dimension": dimension,
        "dimension_name": dimension_name,
        "n_questions": len(questions),
        "conditions": ["baseline", "cot", "coe_r", "coe_ctr"],
        "scoring": "0-4 per question via grade_coe_reasoning.py",
        "questions": questions,
    }
    out_path = os.path.join(out_dir, "questions.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=2)

    print(f"Wrote {len(questions)} questions to {out_path}")
    for q in questions:
        gt_short = {k: v for k, v in q["ground_truth"].items()
                    if k in (summary_keys or [])} \
            if summary_keys else q["ground_truth"]
        print(f"  {q['question_id']:14} [{q['type']:25}] gt={gt_short}")
    return out_path
