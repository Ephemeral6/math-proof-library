"""Cross-model multi-family R-universality experiment.

Runs the same 8-domain x 3-case x 2-condition (baseline vs RTC) protocol used in
the Anthropic cross-model study against two non-Anthropic model families:
DeepSeek (deepseek-chat) and Qwen (qwen-max-latest). The OpenAI Python SDK is
used as a generic OpenAI-compatible client; both providers expose
OpenAI-compatible chat-completions endpoints.

Why this script lives outside the Claude Code environment:
  Claude Code does not have egress to api.deepseek.com / dashscope.aliyuncs.com,
  so this needs to be executed on the user's machine where those API keys are
  available.

Dependencies:
  pip install openai

Usage:
  DEEPSEEK_API_KEY=sk-xxx QWEN_API_KEY=sk-xxx python cross_model_multi_family.py

Output:
  cross_model_multi_family_responses.json (96 trials = 2 models x 48 trials each)

Note on case IDs:
  The user-specified projection IDs (prism_triangular-proj-yz-0, cube-proj-diag-0,
  octahedron-proj-cross-0) do not exist in benchmarks/projection/ablation/*.json.
  The canonical IDs from sampling_manifest.json (which the prior Haiku/Sonnet/Opus
  runs used) are substituted so the comparison stays apples-to-apples. If you
  really want different cases, edit the CASES dict below.
"""
from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path

# --------------------------------------------------------------------------- #
# Configuration
# --------------------------------------------------------------------------- #

ROOT = Path(__file__).resolve().parents[1]
BENCH = ROOT / "benchmarks"
OUT_PATH = Path(__file__).resolve().parent / "cross_model_multi_family_responses.json"

MODELS = {
    "deepseek": {
        "model_id": "deepseek-chat",
        "base_url": "https://api.deepseek.com/v1",
        "env_key": "DEEPSEEK_API_KEY",
    },
    "qwen": {
        "model_id": "qwen-max-latest",
        "base_url": "https://dashscope.aliyuncs.com/compatible-mode/v1",
        "env_key": "QWEN_API_KEY",
    },
}

CASES = {
    "symmetry": ["same-006", "diff-163", "same-028"],
    "knot_theory": ["3_1-r2-3", "4_1-r2-4", "5_2-r2-5"],
    "graph_connectivity": ["R16_n12-t1", "R02_n12-t4", "R00_n8-t3"],
    "boundary_interior": [
        "crosspair-4-L_shape-vs-staircase",
        "rectangle_4x3-shear-0",
        "unit_square-shear-0",
    ],
    "discrete_curvature": [
        "cross-octahedron-vs-icosahedron-f1-1",
        "cube_triangulated-subdiv-f0-0",
        "tetrahedron-subdiv-f3-3",
    ],
    # Projection: user spec referenced IDs that don't exist in the benchmark
    # (prism_triangular-proj-yz-0, cube-proj-diag-0, octahedron-proj-cross-0).
    # We use the canonical sampled IDs that the Haiku/Sonnet/Opus runs used.
    "projection": [
        "self-triangular_prism-yz",
        "self-cube-diagonal",
        "cross-octahedron-xzvsyz",
    ],
    "surface_topology": ["a331-b69", "a62-b12", "a12-b1"],
    "surface_topology_s21": ["a151-b6", "a122-b28", "a215-b1"],
}

# Question text per domain (kept in Chinese to match the existing experiment so
# Opus can score on identical content).
QUESTION_TEMPLATES = {
    "symmetry": (
        "正六边形顶点 3 色着色 a 与 b。考虑循环群 Z_6 在顶点上的作用。"
        "判断 a 与 b 是否在同一个 Z_6 轨道下；若同轨道，给出群元素见证；"
        "若不同轨道，说明哪个不变量阻断了等价。"
    ),
    "knot_theory": (
        "对一个结的图代码应用 R2（Reidemeister 2）变换：在图上插入一对相消的交叉。"
        "判断该 R2 应用是否合法（即结类型与所有标准不变量是否保持），"
        "并说明 signature / determinant / Alexander 多项式 / writhe 的变化情况。"
    ),
    "graph_connectivity": (
        "给定一个简单无向图，删除一条指定的边。判断：(1) 该边是否为桥；"
        "(2) 删除后图是否仍连通；(3) 删除后桥数与关节点（articulation point）的变化。"
    ),
    "boundary_interior": (
        "给定一个网格多边形（顶点为整点）。基于 Pick 定理 A = I + B/2 - 1，"
        "判断给定的多边形（或一对多边形）的面积、边界格点数 B、内部格点数 I 是否一致，"
        "Pick 关系是否成立。"
    ),
    "discrete_curvature": (
        "给定一个三角化的多面体（曲面）。基于离散 Gauss-Bonnet：sum 角度亏格 = 2π·χ。"
        "对一个变换（细分或两个不同多面体比较），判断 Euler 特征 χ、总曲率、"
        "以及 Gauss-Bonnet 比率是否被保持。"
    ),
    "projection": (
        "给定一个三维多面体在某个二维平面上的投影。比较两种投影（自配对或两不同物体配对）"
        "在维度、点数、直径、边交叉数方面的结构差异。"
    ),
    "surface_topology": (
        "给定一个亏格 g=2 的紧致定向曲面 S 上的两条简单闭曲线 alpha 和 beta（用 Dehn 扭转字"
        "在标准生成元 a_1, b_1, a_2, b_2 上的 word 表示）。判断 alpha 与 beta 的几何相交"
        "数 i(alpha, beta)，并讨论 weight 的变化。"
    ),
    "surface_topology_s21": (
        "给定一个亏格 g=2、带 1 个穿孔（边界）的曲面 S_{2,1} 上的两条简单闭曲线 alpha "
        "和 beta。判断几何相交数 i(alpha, beta)，并讨论 weight 的变化。"
    ),
}

BASELINE_HEADER = (
    "You are a mathematical reasoning assistant. Analyze the following "
    "geometric/topological problem and provide your reasoning and conclusion.\n\n"
)
RTC_HEADER = (
    "You are a mathematical reasoning assistant. A domain engine has computed "
    "structural data (R), transformation traces (T), and counterfactual "
    "comparisons (C) for the following problem. Use this data to reason and "
    "provide your conclusion.\n\n"
)

MAX_RETRIES = 3
RETRY_BACKOFF_SEC = 10
REQUEST_TIMEOUT = 180  # seconds; some models stream long completions


# --------------------------------------------------------------------------- #
# Prompt construction
# --------------------------------------------------------------------------- #

_ABLATION_CACHE: dict[tuple[str, str], dict] = {}


def load_ablation(domain: str, condition: str) -> dict:
    """Load and cache benchmarks/{domain}/ablation/{condition}.json."""
    key = (domain, condition)
    if key not in _ABLATION_CACHE:
        path = BENCH / domain / "ablation" / f"{condition}.json"
        with open(path, "r", encoding="utf-8") as f:
            _ABLATION_CACHE[key] = json.load(f)
    return _ABLATION_CACHE[key]


def find_case(ablation: dict, case_id: str) -> dict:
    for c in ablation["cases"]:
        if c["case_id"] == case_id:
            return c
    raise KeyError(
        f"case_id {case_id!r} not found in ablation file for "
        f"domain {ablation.get('domain')!r} (condition {ablation.get('condition')!r})"
    )


def build_baseline_prompt(domain: str, case_id: str) -> str:
    case = find_case(load_ablation(domain, "000"), case_id)
    payload = {
        "case_id": case_id,
        "summary_delta": case.get("summary_delta", {}),
        "metadata": case.get("metadata", {}),
    }
    body = (
        f"### 问题背景\n{QUESTION_TEMPLATES[domain]}\n\n"
        f"### 案例 {case_id} 的基础数据 (summary_delta + metadata)\n"
        f"```json\n{json.dumps(payload, ensure_ascii=False, indent=2)}\n```\n\n"
        f"### 任务\n请基于以上数据回答上述问题，给出结论与简要推理。"
    )
    return BASELINE_HEADER + body


def build_rtc_prompt(domain: str, case_id: str) -> str:
    ab = load_ablation(domain, "RTC")
    case = find_case(ab, case_id)
    rtc_payload = {
        "case_id": case_id,
        "summary_delta": case.get("summary_delta", {}),
        "metadata": case.get("metadata", {}),
        "detailed_comparison": case.get("detailed_comparison", {}),
        "structural_comparison": case.get("structural_comparison", {}),
        "transform_trace": case.get("transform_trace", {}),
    }
    if "reference_in_transform_region" in case:
        rtc_payload["reference_in_transform_region"] = case["reference_in_transform_region"]
    counterfactual = ab.get("counterfactual", [])
    body = (
        f"### 问题背景\n{QUESTION_TEMPLATES[domain]}\n\n"
        f"### 案例 {case_id} 的引擎结构数据 (R + T)\n"
        f"```json\n{json.dumps(rtc_payload, ensure_ascii=False, indent=2)}\n```\n\n"
        f"### 反事实对比 (C)\n"
        f"```json\n{json.dumps(counterfactual, ensure_ascii=False, indent=2)}\n```\n\n"
        f"### 任务\n请基于以上 R/T/C 数据回答问题，结合不变量、变换轨迹与反事实给出结论与推理。"
    )
    return RTC_HEADER + body


# --------------------------------------------------------------------------- #
# API call with retry
# --------------------------------------------------------------------------- #

def call_model(client, model_id: str, prompt: str) -> str:
    """One chat-completion call. Returns the assistant message text."""
    resp = client.chat.completions.create(
        model=model_id,
        messages=[{"role": "user", "content": prompt}],
        timeout=REQUEST_TIMEOUT,
    )
    choice = resp.choices[0]
    content = choice.message.content
    if content is None:
        # Some providers return reasoning_content or similar fields
        content = getattr(choice.message, "reasoning_content", "") or ""
    return content


def call_with_retry(client, model_id: str, prompt: str) -> tuple[str, str | None]:
    """Returns (response_text, error_message_or_None)."""
    last_err: Exception | None = None
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            return call_model(client, model_id, prompt), None
        except Exception as e:  # noqa: BLE001 - we want to catch any provider error
            last_err = e
            if attempt < MAX_RETRIES:
                print(f"    retry {attempt}/{MAX_RETRIES - 1} after error: {e!r}", flush=True)
                time.sleep(RETRY_BACKOFF_SEC)
    return "", f"{type(last_err).__name__}: {last_err}"


# --------------------------------------------------------------------------- #
# Main loop
# --------------------------------------------------------------------------- #

def build_trial_plan() -> list[tuple[str, str, str]]:
    """Returns ordered list of (domain, case_id, condition)."""
    plan: list[tuple[str, str, str]] = []
    for domain, case_list in CASES.items():
        for case_id in case_list:
            for cond in ("baseline", "rtc"):
                plan.append((domain, case_id, cond))
    return plan


def build_prompt(domain: str, case_id: str, condition: str) -> str:
    if condition == "baseline":
        return build_baseline_prompt(domain, case_id)
    if condition == "rtc":
        return build_rtc_prompt(domain, case_id)
    raise ValueError(f"unknown condition: {condition!r}")


def main() -> int:
    # 1. Verify env keys
    missing = [cfg["env_key"] for cfg in MODELS.values() if not os.environ.get(cfg["env_key"])]
    if missing:
        print(f"ERROR: missing env var(s): {', '.join(missing)}", file=sys.stderr)
        print(
            "Usage: DEEPSEEK_API_KEY=sk-xxx QWEN_API_KEY=sk-xxx "
            "python cross_model_multi_family.py",
            file=sys.stderr,
        )
        return 2

    # 2. Lazy-import openai (so the env-check error message is friendlier)
    try:
        from openai import OpenAI
    except ImportError:
        print("ERROR: the openai package is required: pip install openai", file=sys.stderr)
        return 2

    plan = build_trial_plan()
    n_per_model = len(plan)
    n_total = n_per_model * len(MODELS)
    print(
        f"Plan: {len(MODELS)} models x {n_per_model} trials = {n_total} total "
        f"(8 domains x 3 cases x 2 conditions per model)",
        flush=True,
    )

    out: dict = {
        "experiment": "cross_model_multi_family",
        "design": {
            "factors": "2 models x 8 domains x 3 cases x 2 conditions = 96 trials",
            "models": {k: v["model_id"] for k, v in MODELS.items()},
            "cases_per_domain": CASES,
            "conditions": ["baseline", "rtc"],
        },
        "models": {},
    }

    trial_idx = 0
    for model_key, cfg in MODELS.items():
        client = OpenAI(api_key=os.environ[cfg["env_key"]], base_url=cfg["base_url"])
        out["models"][model_key] = {"model_id": cfg["model_id"], "trials": []}

        for domain, case_id, condition in plan:
            trial_idx += 1
            prompt = build_prompt(domain, case_id, condition)
            t0 = time.time()
            print(
                f"[{trial_idx}/{n_total}] {model_key} | {domain} | {case_id} | "
                f"{condition} ...",
                end="",
                flush=True,
            )
            response, err = call_with_retry(client, cfg["model_id"], prompt)
            dt = time.time() - t0
            if err is None:
                print(f" done ({dt:.1f}s)", flush=True)
            else:
                print(f" FAILED ({dt:.1f}s): {err}", flush=True)
            trial_record = {
                "domain": domain,
                "case_id": case_id,
                "condition": condition,
                "response": response,
                "elapsed_sec": round(dt, 2),
            }
            if err is not None:
                trial_record["error"] = err
            out["models"][model_key]["trials"].append(trial_record)

            # Incremental save so a long-running failure doesn't lose all work
            with open(OUT_PATH, "w", encoding="utf-8") as f:
                json.dump(out, f, ensure_ascii=False, indent=2)

    print(f"\nDone. Wrote {OUT_PATH}", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
