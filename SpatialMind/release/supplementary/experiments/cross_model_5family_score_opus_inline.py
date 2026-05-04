"""Cross-model 5-family scoring — Opus 4.7 inline grading.

Bypasses the Anthropic API. Scores for each DeepSeek and Qwen-Max trial were
assigned directly by Claude Opus 4.7 (this assistant) reading the response
text and applying the same 0-4 rubric used in the prior cross-model studies:

    0 = completely wrong / no real reasoning
    1 = wrong conclusion or fundamentally confused
    2 = correct conclusion but weak / hand-wavy reasoning
    3 = correct conclusion + sound reasoning
    4 = correct + rigorous explicit verification + invariant identification

Reads cross_model_multi_family_responses.json, attaches the inline scores
to each trial, computes per-condition / per-domain summaries, and renders
the 5-family comparison table (DeepSeek + Qwen-Max on full 8-domain;
Haiku 4.5 / Sonnet 4.6 / Opus 4.7 on 3-domain matched subset from prior
runs).

Outputs:
  - cross_model_5family_results.json
  - cross_model_5family_summary.md
"""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
RESPONSES_PATH = ROOT / "cross_model_multi_family_responses.json"
OUT_PATH = ROOT / "cross_model_5family_results.json"
SUMMARY_PATH = ROOT / "cross_model_5family_summary.md"

JUDGE_MODEL = "claude-opus-4-7 (inline, no API)"

RUBRIC = {
    0: "completely wrong / no real reasoning",
    1: "wrong conclusion or fundamentally confused",
    2: "correct conclusion but weak / hand-wavy reasoning",
    3: "correct conclusion + sound reasoning",
    4: "correct + rigorous explicit verification + invariant identification",
}

# 3-domain matched subset (symmetry + knot_theory + graph_connectivity), 9 trials
# per condition, copied from cross_model_results.json / cross_model_sonnet_results.json
PRIOR_RESULTS_3DOMAIN = {
    "Haiku 4.5":  {"baseline_mean": 3.000, "rtc_mean": 3.667, "rtc_lift": 0.667},
    "Sonnet 4.6": {"baseline_mean": 3.111, "rtc_mean": 3.889, "rtc_lift": 0.778},
    "Opus 4.7":   {"baseline_mean": 3.333, "rtc_mean": 4.000, "rtc_lift": 0.667},
}

# Inline scores keyed by (model, trial_index_within_model).
# Trial index 0..47 follows the order in cross_model_multi_family_responses.json:
# even indices are 'baseline', odd are 'rtc'; domain blocks of 6 in this order:
#   symmetry, knot_theory, graph_connectivity, boundary_interior,
#   discrete_curvature, projection, surface_topology, surface_topology_s21
# A score of None means the response was empty (API call failed) and is
# excluded from the means.
SCORES = {
    "deepseek": [
        # symmetry
        2, 3,   # same-006   baseline / rtc
        3, 3,   # diff-163
        4, 4,   # same-028
        # knot_theory
        3, 4,   # 3_1-r2-3
        3, 4,   # 4_1-r2-4
        3, 4,   # 5_2-r2-5
        # graph_connectivity
        1, 4,   # R16_n12-t1
        1, 4,   # R02_n12-t4
        3, 4,   # R00_n8-t3
        # boundary_interior
        1, 4,   # crosspair-4-L_shape-vs-staircase
        2, 4,   # rectangle_4x3-shear-0
        4, 4,   # unit_square-shear-0
        # discrete_curvature
        3, 4,   # cross-octahedron-vs-icosahedron-f1-1
        2, 4,   # cube_triangulated-subdiv-f0-0
        3, 4,   # tetrahedron-subdiv-f3-3
        # projection
        3, 4,   # self-triangular_prism-yz
        2, 4,   # self-cube-diagonal
        1, 4,   # cross-octahedron-xzvsyz
        # surface_topology (g=2 closed)
        3, 4,   # a331-b69
        3, 4,   # a62-b12
        3, 4,   # a12-b1
        # surface_topology_s21 (g=2, 1 puncture)
        3, 2,   # a151-b6           (rtc claims i flips to 0 after surgery — wrong)
        3, 4,   # a122-b28
        3, 4,   # a215-b1
    ],
    "qwen": [
        # symmetry
        3, 1,    # same-006  (rtc asserts wrong witness g_idx=3)
        4, 4,    # diff-163  (clean color-count blocker)
        4, 4,    # same-028
        # knot_theory
        3, 4,    # 3_1-r2-3
        3, None, # 4_1-r2-4 rtc empty
        None, None, # 5_2-r2-5 both empty
        # graph_connectivity
        None, None, # R16_n12-t1 both empty
        2, 4,    # R02_n12-t4 (baseline correct on q1,q2 but wrong on bridge count)
        2, 4,    # R00_n8-t3  (baseline hedges on q3)
        # boundary_interior
        2, 4,    # crosspair-4-L_shape-vs-staircase
        2, 4,    # rectangle_4x3-shear-0
        1, 4,    # unit_square-shear-0  (baseline literally reads 0 deltas → "Pick fails")
        # discrete_curvature
        2, 4,    # cross-octahedron-vs-icosahedron-f1-1
        2, 4,    # cube_triangulated-subdiv-f0-0
        2, 4,    # tetrahedron-subdiv-f3-3
        # projection
        2, 4,    # self-triangular_prism-yz
        1, 4,    # self-cube-diagonal (baseline misreads delta as degenerate)
        2, 4,    # cross-octahedron-xzvsyz
        # surface_topology
        3, 4,    # a331-b69
        3, 4,    # a62-b12
        1, 4,    # a12-b1  (baseline asserts i=0, ignoring metadata i=1)
        # surface_topology_s21
        3, 1,    # a151-b6  (rtc boxes i=0, wrong)
        3, 4,    # a122-b28
        3, 4,    # a215-b1
    ],
}

# Brief one-sentence rationale for each score (for the audit trail).
RATIONALES = {
    ("deepseek", 0):  "Correct (same orbit, rotation by 2) but reasoning confused along the way about g_idx=3.",
    ("deepseek", 1):  "Correct (same orbit, witness g_idx=2). Mentions invariants but verification is brief.",
    ("deepseek", 2):  "Correct (different orbit). Identifies cyclic-pattern blocker, though color-count is the cleaner invariant.",
    ("deepseek", 3):  "Correct (different orbit). Sound reasoning with counterfactuals, but doesn't name color-count blocker crisply.",
    ("deepseek", 4):  "Correct + explicit step-by-step verification of g_idx=5 applied to a yields b.",
    ("deepseek", 5):  "Correct + invariants (orbit size, stabilizer, color count) + counterfactuals.",
    ("deepseek", 6):  "Correct (R2 valid, all invariants preserved). Sound but no explicit pre/post numerical values.",
    ("deepseek", 7):  "Correct + explicit signature, det, Alexander pre/post + counterfactual analysis.",
    ("deepseek", 8):  "Correct (R2 valid, 4_1 invariants). Tabular sound reasoning.",
    ("deepseek", 9):  "Correct + explicit pre/post for all 4 invariants (incl. normalized Alexander).",
    ("deepseek", 10): "Correct (R2 valid for 5_2) and brief but sound.",
    ("deepseek", 11): "Correct + explicit pre/post for all invariants + counterfactuals.",
    ("deepseek", 12): "Wrong on Q2 (claims graph was disconnected; actually connected) — misreads delta encoding.",
    ("deepseek", 13): "All correct: not bridge, still connected, bridges 0→2, articulation 0→2.",
    ("deepseek", 14): "Wrong on connectivity (claims disconnected). Hedges on bridge classification.",
    ("deepseek", 15): "All correct: not bridge, still connected, bridges 5→7, articulation unchanged.",
    ("deepseek", 16): "Correct (bridge, disconnected). Hedges on articulation but in right direction.",
    ("deepseek", 17): "All correct: bridge, disconnected, bridges 1→0, articulation 1→0.",
    ("deepseek", 18): "Wrong — claims Pick fails because reads delta=0 as actual values.",
    ("deepseek", 19): "Correct: identifies polygons identical, A=12 B=16 I=5, Pick verified.",
    ("deepseek", 20): "Hedges 'data unclear' but does note shear det=1; weak.",
    ("deepseek", 21): "Correct: A=12 B=14 I=6, Pick verified, counterfactual analysis.",
    ("deepseek", 22): "Correct using external knowledge: B=4 I=0 A=1, Pick verified explicitly.",
    ("deepseek", 23): "Correct + extensive analysis with single-modular framing.",
    ("deepseek", 24): "Correct (χ=2 for both, total curv 4π). Sound but largely from external knowledge.",
    ("deepseek", 25): "Correct + explicit Δχ=1−3+2=0 + new vertex defect=0.",
    ("deepseek", 26): "Confused about delta encoding but conclusion (preserved) correct.",
    ("deepseek", 27): "Correct + explicit V/E/F pre/post, χ=2, total curv=4π.",
    ("deepseek", 28): "Correct (χ=2 from V−E+F=4−6+4=2, preserved).",
    ("deepseek", 29): "Correct + explicit ΔV=1, ΔE=3, ΔF=2 + invariants identified.",
    ("deepseek", 30): "Correct (dim drops, points unchanged, diameter ↓, no edge crossings). Sound.",
    ("deepseek", 31): "Correct + explicit collisions + counterfactuals + numerical values.",
    ("deepseek", 32): "Confused about delta encoding for self_pair; conclusion roughly right.",
    ("deepseek", 33): "Correct + explicit collision identification + counterfactual analysis.",
    ("deepseek", 34): "Wrong — interprets summary deltas as projections being degenerate.",
    ("deepseek", 35): "Correct + explicit symmetric structure, 1 collision, 4 crossings, 40% distance preserved.",
    ("deepseek", 36): "Correct (i=1 from metadata) + weight Δ=−12 noted.",
    ("deepseek", 37): "Correct + Hatcher surgery analysis + counterfactual key-condition identification.",
    ("deepseek", 38): "Correct (i=1) + weight Δ=−16 noted.",
    ("deepseek", 39): "Correct + comprehensive Hatcher analysis + bigon-with-puncture explanation.",
    ("deepseek", 40): "Correct (i=1) + flags the i_alpha_beta vs intersection_number distinction.",
    ("deepseek", 41): "Correct + bigon analysis + counterfactual key-condition.",
    ("deepseek", 42): "Correct (i=1) + weight Δ=−9; correctly notes intersection_number=−1 is delta.",
    ("deepseek", 43): "Confused: claims i drops from 1 to 0 after surgery, but i is invariant under surgery.",
    ("deepseek", 44): "Correct (i=1, weight Δ=−14) + flags metadata vs delta distinction.",
    ("deepseek", 45): "Correct + comprehensive analysis + descent-link identified as critical condition.",
    ("deepseek", 46): "Correct (i=1, weight Δ=−22).",
    ("deepseek", 47): "Correct + explicit weight sum 27→5 verification + bigon-with-puncture surgery.",

    ("qwen", 0):  "Correct conclusion (same orbit) but witness verification is asserted, not computed.",
    ("qwen", 1):  "Confused — claims g_idx=3 takes a→b but trace shows g·a=a (fixed), contradicts itself.",
    ("qwen", 2):  "Correct + explicit color-count blocker (2,2,2) vs (3,1,2) + tries all 6 rotations.",
    ("qwen", 3):  "Correct + color-count + Hamming distance + counterfactual analysis.",
    ("qwen", 4):  "Correct + explicit step-by-step verification of g^5(a)=b.",
    ("qwen", 5):  "Correct + 5/6 vertices changed + counterfactual key-condition.",
    ("qwen", 6):  "Correct (R2 valid, all preserved). Sound but no explicit pre/post values.",
    ("qwen", 7):  "Correct + explicit signature, det, Alexander pre/post.",
    ("qwen", 8):  "Correct (R2 valid for 4_1).",
    ("qwen", 9):  "(empty response — API failure)",
    ("qwen", 10): "(empty response — API failure)",
    ("qwen", 11): "(empty response — API failure)",
    ("qwen", 12): "(empty response — API failure)",
    ("qwen", 13): "(empty response — API failure)",
    ("qwen", 14): "Correct on Q1 (not bridge) + Q2 (still connected) but wrong on Q3 bridge count change.",
    ("qwen", 15): "All correct + explicit bridge count 5→7 + articulation set unchanged.",
    ("qwen", 16): "Correct on Q1 (bridge) + Q2 (disconnected) but hedges on Q3.",
    ("qwen", 17): "All correct: bridge, disconnected, bridges 1→0, articulation 1→0.",
    ("qwen", 18): "Correct conclusion (Pick holds, equal attributes) but argues from delta=0 abstractly without computing A,B,I.",
    ("qwen", 19): "Correct: A=12 B=16 I=5, Pick verified, comprehensive counterfactuals.",
    ("qwen", 20): "Verifies initial Pick (12=6+7−1) but mistakenly flags post-shear data as anomaly.",
    ("qwen", 21): "Correct: A=12 B=14 I=6, Pick verified pre & post.",
    ("qwen", 22): "Wrong — literally reads delta values as A=B=I=0 and concludes Pick fails.",
    ("qwen", 23): "Correct: A=1 B=4 I=0, Pick verified, unimodular framing.",
    ("qwen", 24): "Confused (computes χ from delta values) but reaches 'preserved' conclusion in right direction.",
    ("qwen", 25): "Correct + explicit V=6→7, E=12→15, F=8→10, χ=2, total curv=4π.",
    ("qwen", 26): "Confused about delta encoding but ends at correct 'preserved' conclusion.",
    ("qwen", 27): "Correct + explicit V=8→9, E=18→21, F=12→14, χ=2, total curv=4π.",
    ("qwen", 28): "Confused interpretation but conclusion (preserved) directionally correct.",
    ("qwen", 29): "Correct + explicit V=4→5, E=6→9, F=4→6, χ=2, total curv=4π.",
    ("qwen", 30): "Identifies dim drop and rough direction but hand-wavy on collisions/diameter.",
    ("qwen", 31): "Correct + explicit collision pairs + 20% distance preserved.",
    ("qwen", 32): "Wrong — interprets dim_b=0 as second projection being degenerate (it's a delta).",
    ("qwen", 33): "Correct + explicit collision (0,6) + 21.43% distance preserved + 2 crossings.",
    ("qwen", 34): "Hedges, partial credit for noticing edge_crossings difference 4 vs 0.",
    ("qwen", 35): "Correct + 1 collision (pair 2-3) + 4 crossings + 40% distance preserved.",
    ("qwen", 36): "Correct (i=1 from metadata) + flags intersection_number=0 as different metric.",
    ("qwen", 37): "Correct + Hatcher surgery + bigons-with-puncture explanation + counterfactual.",
    ("qwen", 38): "Correct (i=1) + weight Δ=−16 noted.",
    ("qwen", 39): "Correct + explicit weight sum 26→10 verification + Hatcher analysis.",
    ("qwen", 40): "Wrong — boxes i(α,β)=0, ignoring metadata i_alpha_beta=1.",
    ("qwen", 41): "Correct + bigon analysis + counterfactual key-condition.",
    ("qwen", 42): "Correct (i=1, weight Δ=−9).",
    ("qwen", 43): "Wrong — boxes 'i(α,β)=0 after surgery'. Surgery doesn't change i(α,β).",
    ("qwen", 44): "Correct (i=1, weight Δ=−14).",
    ("qwen", 45): "Correct + comprehensive Hatcher analysis + weight redistribution.",
    ("qwen", 46): "Correct (i=1, weight Δ=−22).",
    ("qwen", 47): "Correct + explicit weight sum 27→5 verification + minimal-position attainment.",
}


def mean(xs):
    xs = [x for x in xs if x is not None]
    return round(sum(xs) / len(xs), 3) if xs else float("nan")


def summarise(trials):
    by_cond = {"baseline": [], "rtc": []}
    by_domain = {}
    for t in trials:
        s = t.get("score")
        if s is None:
            continue
        by_cond[t["condition"]].append(s)
        by_domain.setdefault(t["domain"], {"baseline": [], "rtc": []})[t["condition"]].append(s)
    bm = mean(by_cond["baseline"])
    rm = mean(by_cond["rtc"])
    lift = round(rm - bm, 3) if not (bm != bm or rm != rm) else None
    return {
        "baseline_mean": bm,
        "rtc_mean": rm,
        "rtc_lift": lift,
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


def restrict_to_three_domain(trials):
    keep = {"symmetry", "knot_theory", "graph_connectivity"}
    return [t for t in trials if t["domain"] in keep]


def render_table(model_summaries, model_summaries_3domain):
    deepseek_full = model_summaries.get("deepseek", {})
    qwen_full     = model_summaries.get("qwen", {})
    deepseek_3d   = model_summaries_3domain.get("deepseek", {})
    qwen_3d       = model_summaries_3domain.get("qwen", {})

    def fmt(v):
        if v is None:
            return "n/a"
        if isinstance(v, float) and v != v:
            return "n/a"
        return f"{v:.3f}"

    def fmt_lift(v):
        if v is None:
            return "n/a"
        return f"+{v:.3f}" if v >= 0 else f"{v:.3f}"

    lines = []
    lines.append("### Full 8-domain (new models)")
    lines.append("")
    lines.append("| Model      | Baseline | +RTC  | RTC lift | n_base / n_rtc |")
    lines.append("|------------|----------|-------|----------|----------------|")
    for name, s in [("DeepSeek", deepseek_full), ("Qwen-Max", qwen_full)]:
        nb = s.get("n_per_condition", {}).get("baseline", "?")
        nr = s.get("n_per_condition", {}).get("rtc", "?")
        lines.append(
            f"| {name:<10} | {fmt(s.get('baseline_mean')):<8} | {fmt(s.get('rtc_mean')):<5} | {fmt_lift(s.get('rtc_lift')):<8} | {nb} / {nr}            |"
        )
    lines.append("")
    lines.append("### 3-domain matched subset (symmetry + knot_theory + graph_connectivity)")
    lines.append("")
    lines.append("| Model      | Baseline | +RTC  | RTC lift |")
    lines.append("|------------|----------|-------|----------|")
    rows = [
        ("DeepSeek",   deepseek_3d.get("baseline_mean"), deepseek_3d.get("rtc_mean"), deepseek_3d.get("rtc_lift")),
        ("Qwen-Max",   qwen_3d.get("baseline_mean"),     qwen_3d.get("rtc_mean"),     qwen_3d.get("rtc_lift")),
        ("Haiku 4.5",  PRIOR_RESULTS_3DOMAIN["Haiku 4.5"]["baseline_mean"],  PRIOR_RESULTS_3DOMAIN["Haiku 4.5"]["rtc_mean"],  PRIOR_RESULTS_3DOMAIN["Haiku 4.5"]["rtc_lift"]),
        ("Sonnet 4.6", PRIOR_RESULTS_3DOMAIN["Sonnet 4.6"]["baseline_mean"], PRIOR_RESULTS_3DOMAIN["Sonnet 4.6"]["rtc_mean"], PRIOR_RESULTS_3DOMAIN["Sonnet 4.6"]["rtc_lift"]),
        ("Opus 4.7",   PRIOR_RESULTS_3DOMAIN["Opus 4.7"]["baseline_mean"],   PRIOR_RESULTS_3DOMAIN["Opus 4.7"]["rtc_mean"],   PRIOR_RESULTS_3DOMAIN["Opus 4.7"]["rtc_lift"]),
    ]
    for name, b, r, lift in rows:
        lines.append(f"| {name:<10} | {fmt(b):<8} | {fmt(r):<5} | {fmt_lift(lift):<8} |")
    return "\n".join(lines)


def main():
    with open(RESPONSES_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    out = {
        "experiment": "cross_model_5family_scored_opus_inline",
        "judge_model": JUDGE_MODEL,
        "rubric": RUBRIC,
        "scoring_method": "Opus 4.7 read each response and assigned a 0-4 score directly, no API call.",
        "models": {},
        "summary_8domain_full": {},
        "summary_3domain_matched": {},
        "prior_results_3domain_matched": PRIOR_RESULTS_3DOMAIN,
    }

    for model_key, model_block in data["models"].items():
        scores_for_model = SCORES.get(model_key, [])
        if len(scores_for_model) != len(model_block["trials"]):
            raise RuntimeError(
                f"Score list length {len(scores_for_model)} != trial count {len(model_block['trials'])} for {model_key}"
            )
        scored_trials = []
        for i, trial in enumerate(model_block["trials"]):
            score = scores_for_model[i]
            rationale = RATIONALES.get((model_key, i), "")
            scored_trials.append({
                **trial,
                "score": score,
                "rationale": rationale,
            })

        summary_full = summarise(scored_trials)
        summary_3d = summarise(restrict_to_three_domain(scored_trials))
        out["models"][model_key] = {
            "model_id": model_block["model_id"],
            "trials": scored_trials,
            "summary_8domain_full": summary_full,
            "summary_3domain_matched": summary_3d,
        }
        out["summary_8domain_full"][model_key] = summary_full
        out["summary_3domain_matched"][model_key] = summary_3d

    table_md = render_table(out["summary_8domain_full"], out["summary_3domain_matched"])
    out["comparison_table_md"] = table_md

    with open(OUT_PATH, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=2)
    with open(SUMMARY_PATH, "w", encoding="utf-8") as f:
        f.write("# Cross-model 5-family R-universality summary\n\n")
        f.write(
            "Scoring done inline by Claude Opus 4.7 (no API call) using the same 0-4 rubric "
            "as prior cross-model studies in this project. Two new model families "
            "(DeepSeek, Qwen-Max) ran the full 8-domain × 3-case × 2-condition protocol "
            "(48 trials each, with 5 empty Qwen responses from API failures). Prior models "
            "(Haiku 4.5, Sonnet 4.6, Opus 4.7) report on the 3-domain matched subset "
            "(symmetry + knot_theory + graph_connectivity) used in the original "
            "cross_model_results.json so the comparison is apples-to-apples.\n\n"
        )
        f.write(table_md + "\n")

    print(f"Wrote {OUT_PATH}")
    print(f"Wrote {SUMMARY_PATH}")
    print()
    print(table_md)


if __name__ == "__main__":
    main()
