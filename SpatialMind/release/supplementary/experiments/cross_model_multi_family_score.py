"""Score the cross-model multi-family responses with Opus 4.7.

Reads cross_model_multi_family_responses.json, asks Claude (claude-opus-4-7) to
rate each response on the 0-4 rubric used in the prior cross-model studies,
then writes cross_model_5family_results.json with per-trial scores plus a
five-row summary table (DeepSeek, Qwen-Max, Haiku 4.5, Sonnet 4.6, Opus 4.7).

Dependencies:
  pip install anthropic

Usage:
  ANTHROPIC_API_KEY=sk-ant-xxx python cross_model_multi_family_score.py
"""
from __future__ import annotations

import json
import os
import re
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent
RESPONSES_PATH = ROOT / "cross_model_multi_family_responses.json"
OUT_PATH = ROOT / "cross_model_5family_results.json"
SUMMARY_PATH = ROOT / "cross_model_5family_summary.md"

JUDGE_MODEL = "claude-opus-4-7"

# 0-4 rubric, identical wording to cross_model_results.json["design"]["rubric_0_to_4"]
RUBRIC = {
    0: "completely wrong / no real reasoning",
    1: "wrong conclusion or fundamentally confused",
    2: "correct conclusion but weak / hand-wavy reasoning",
    3: "correct conclusion + sound reasoning",
    4: "correct + rigorous explicit verification + invariant identification",
}

# Reference rows from prior runs (cross_model_results.json + cross_model_sonnet_results.json),
# computed on the matched 9-trial-per-condition subset (symmetry+knot+graph) so all
# 5 models compare on equal footing on those 3 domains. The summary table reports
# *full 8-domain* numbers for the new 2 models and the 3-domain matched subset for
# the prior 3 models (since that's all that's available for Haiku and Opus 4.7).
PRIOR_RESULTS_3DOMAIN = {
    "Haiku 4.5": {"baseline_mean": 3.000, "rtc_mean": 3.667, "rtc_lift": 0.667},
    "Sonnet 4.6": {"baseline_mean": 3.111, "rtc_mean": 3.889, "rtc_lift": 0.778},
    "Opus 4.7": {"baseline_mean": 3.333, "rtc_mean": 4.000, "rtc_lift": 0.667},
}

DOMAIN_QUESTIONS = {
    "symmetry": "正六边形顶点 3 色着色 a 与 b。判断 a 与 b 是否在同一个 Z_6 轨道下。",
    "knot_theory": "对一个结的图代码应用 R2 变换，判断该 R2 应用是否合法（保持结类型与不变量）。",
    "graph_connectivity": "给定图删除一条边，判断该边是否为桥、删除后是否仍连通、桥/关节点变化。",
    "boundary_interior": "基于 Pick 定理 A = I + B/2 - 1，判断格点多边形的 A/I/B 是否一致。",
    "discrete_curvature": "基于离散 Gauss-Bonnet 判断 Euler 特征 χ、总曲率、GB 比率是否被保持。",
    "projection": "比较两种 3D->2D 投影在维度、点数、直径、边交叉数方面的结构差异。",
    "surface_topology": "亏格 g=2 闭曲面上两条简单闭曲线的几何相交数 i(alpha, beta)。",
    "surface_topology_s21": "亏格 g=2 带 1 穿孔曲面 S_{2,1} 上两条简单闭曲线的几何相交数。",
}

JUDGE_SYSTEM = (
    "You are an expert mathematical-reasoning grader. You will read a model's "
    "response to a structured math problem and assign an integer score 0-4 using "
    "this rubric:\n"
    "  0 = completely wrong / no real reasoning\n"
    "  1 = wrong conclusion or fundamentally confused\n"
    "  2 = correct conclusion but weak / hand-wavy reasoning\n"
    "  3 = correct conclusion + sound reasoning\n"
    "  4 = correct + rigorous explicit verification + invariant identification\n"
    "Be calibrated against the prior cross-model studies in this project: a "
    "response that just states the right label without computing the witness or "
    "checking invariants is a 2 or 3, not a 4. A 4 requires explicit invariant "
    "computation or witness verification.\n"
    "Output exactly two lines:\n"
    "SCORE: <integer 0-4>\n"
    "RATIONALE: <one sentence>"
)


def build_judge_user_prompt(domain: str, case_id: str, condition: str, response: str) -> str:
    q = DOMAIN_QUESTIONS.get(domain, "(see project docs)")
    return (
        f"Domain: {domain}\n"
        f"Case: {case_id}\n"
        f"Condition: {condition}  (baseline = summary_delta+metadata only; "
        f"rtc = full R/T/C structured data)\n"
        f"Question: {q}\n\n"
        f"Model response:\n"
        f"```\n{response}\n```\n\n"
        f"Score this response 0-4 per the rubric. Output exactly:\n"
        f"SCORE: <int>\nRATIONALE: <one sentence>"
    )


_SCORE_RE = re.compile(r"SCORE\s*:\s*([0-4])\b", re.IGNORECASE)
_RATIONALE_RE = re.compile(r"RATIONALE\s*:\s*(.+)", re.IGNORECASE | re.DOTALL)


def parse_score(text: str) -> tuple[int | None, str]:
    m = _SCORE_RE.search(text)
    score = int(m.group(1)) if m else None
    r = _RATIONALE_RE.search(text)
    rationale = r.group(1).strip().splitlines()[0].strip() if r else text.strip().splitlines()[-1]
    return score, rationale


def score_response(client, domain: str, case_id: str, condition: str, response: str) -> dict:
    if not response:
        return {"score": None, "rationale": "empty response (API call failed)"}
    msg = client.messages.create(
        model=JUDGE_MODEL,
        max_tokens=300,
        system=JUDGE_SYSTEM,
        messages=[{"role": "user", "content": build_judge_user_prompt(domain, case_id, condition, response)}],
    )
    text = "".join(b.text for b in msg.content if getattr(b, "type", None) == "text")
    score, rationale = parse_score(text)
    return {"score": score, "rationale": rationale, "judge_raw": text.strip()}


def mean(xs: list[int]) -> float:
    xs = [x for x in xs if x is not None]
    return round(sum(xs) / len(xs), 3) if xs else float("nan")


def summarise(trials: list[dict]) -> dict:
    by_cond: dict[str, list[int]] = {"baseline": [], "rtc": []}
    by_domain: dict[str, dict[str, list[int]]] = {}
    for t in trials:
        cond = t["condition"]
        s = t.get("score")
        if s is None:
            continue
        by_cond[cond].append(s)
        by_domain.setdefault(t["domain"], {"baseline": [], "rtc": []})[cond].append(s)
    bm = mean(by_cond["baseline"])
    rm = mean(by_cond["rtc"])
    return {
        "baseline_mean": bm,
        "rtc_mean": rm,
        "rtc_lift": round(rm - bm, 3) if not (bm != bm or rm != rm) else None,  # noqa: PLR1714
        "baseline_scores": by_cond["baseline"],
        "rtc_scores": by_cond["rtc"],
        "n_per_condition": {"baseline": len(by_cond["baseline"]), "rtc": len(by_cond["rtc"])},
        "per_domain": {
            d: {
                "baseline": s["baseline"],
                "rtc": s["rtc"],
                "baseline_mean": mean(s["baseline"]),
                "rtc_mean": mean(s["rtc"]),
            }
            for d, s in by_domain.items()
        },
    }


def render_table(model_summaries: dict[str, dict]) -> str:
    """Render the 5-row comparison markdown table."""
    rows = []
    # New models (full 8-domain)
    deepseek = model_summaries.get("deepseek", {})
    qwen = model_summaries.get("qwen", {})
    rows.append(("DeepSeek", deepseek.get("baseline_mean"), deepseek.get("rtc_mean"), deepseek.get("rtc_lift")))
    rows.append(("Qwen-Max", qwen.get("baseline_mean"), qwen.get("rtc_mean"), qwen.get("rtc_lift")))
    # Prior models (3-domain matched subset)
    for name, vals in PRIOR_RESULTS_3DOMAIN.items():
        rows.append((name, vals["baseline_mean"], vals["rtc_mean"], vals["rtc_lift"]))

    def fmt(v):
        if v is None or (isinstance(v, float) and v != v):  # NaN
            return "n/a"
        if isinstance(v, (int, float)):
            return f"{v:+.3f}" if isinstance(v, float) and v < 0 else f"{v:.3f}"
        return str(v)

    lines = [
        "|            | Baseline | +RTC  | RTC lift |",
        "|------------|----------|-------|----------|",
    ]
    for name, b, r, lift in rows:
        lift_s = f"+{lift:.3f}" if isinstance(lift, (int, float)) and lift >= 0 else fmt(lift)
        lines.append(f"| {name:<10} | {fmt(b):<8} | {fmt(r):<5} | {lift_s:<8} |")
    return "\n".join(lines)


def main() -> int:
    if not os.environ.get("ANTHROPIC_API_KEY"):
        print("ERROR: ANTHROPIC_API_KEY not set", file=sys.stderr)
        return 2
    if not RESPONSES_PATH.exists():
        print(f"ERROR: {RESPONSES_PATH} not found. Run cross_model_multi_family.py first.", file=sys.stderr)
        return 2

    try:
        from anthropic import Anthropic
    except ImportError:
        print("ERROR: the anthropic package is required: pip install anthropic", file=sys.stderr)
        return 2

    client = Anthropic()

    with open(RESPONSES_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    out: dict = {
        "experiment": "cross_model_multi_family_scored",
        "judge_model": JUDGE_MODEL,
        "rubric": RUBRIC,
        "models": {},
        "summary": {},
        "prior_results_3domain_matched": PRIOR_RESULTS_3DOMAIN,
    }

    n_total = sum(len(m["trials"]) for m in data["models"].values())
    idx = 0
    for model_key, model_block in data["models"].items():
        scored_trials = []
        for trial in model_block["trials"]:
            idx += 1
            t0 = time.time()
            print(
                f"[{idx}/{n_total}] scoring {model_key} | {trial['domain']} | "
                f"{trial['case_id']} | {trial['condition']} ...",
                end="",
                flush=True,
            )
            try:
                judge = score_response(
                    client,
                    trial["domain"],
                    trial["case_id"],
                    trial["condition"],
                    trial.get("response", ""),
                )
            except Exception as e:  # noqa: BLE001
                judge = {"score": None, "rationale": f"judge error: {e!r}", "judge_raw": ""}
            dt = time.time() - t0
            print(f" {judge['score']} ({dt:.1f}s)", flush=True)
            scored_trials.append({**trial, **judge})

        summary = summarise(scored_trials)
        out["models"][model_key] = {
            "model_id": model_block["model_id"],
            "trials": scored_trials,
            "summary": summary,
        }
        out["summary"][model_key] = summary

    # Render and save markdown table
    table = render_table(out["summary"])
    out["comparison_table_md"] = table

    with open(OUT_PATH, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=2)
    with open(SUMMARY_PATH, "w", encoding="utf-8") as f:
        f.write("# Cross-model 5-family R-universality summary\n\n")
        f.write(
            "Two new model families (DeepSeek, Qwen-Max) scored on full 8-domain x "
            "3-case x 2-condition protocol (48 trials each).\n\n"
            "Prior models (Haiku 4.5, Sonnet 4.6, Opus 4.7) reported on the 3-domain "
            "matched subset (symmetry + knot_theory + graph_connectivity) used in the "
            "original cross_model_results.json so the comparison is apples-to-apples.\n\n"
        )
        f.write(table + "\n")

    print(f"\nWrote {OUT_PATH}")
    print(f"Wrote {SUMMARY_PATH}")
    print()
    print(table)
    return 0


if __name__ == "__main__":
    sys.exit(main())
