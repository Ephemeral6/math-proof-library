"""Run the auto-grader across every dimension's questions × responses and
emit a single dimension × condition summary as Markdown + JSON.
"""

from __future__ import annotations

import json
import os
import sys

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.abspath(os.path.join(_THIS, "..", ".."))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from SpatialMind.scripts.grade_coe_reasoning_dim4 import grade_response

DIMS = [
    ("dim1_invariants", "Dim 1 (invariants — knot)"),
    ("dim2_graph",      "Dim 2 (graph connectivity)"),
    ("dim3_curvature",  "Dim 3 (discrete curvature)"),
    ("dim4_symmetry",   "Dim 4 (symmetry / Burnside)"),
    ("dim5_projection", "Dim 5 (projection)"),
    ("dim6_boundary",   "Dim 6 (boundary / Pick)"),
]
CONDS = ["baseline", "cot", "coe_r", "coe_ctr"]


def grade_dim(bench_dir):
    with open(os.path.join(bench_dir, "questions.json"), encoding="utf-8") as f:
        bench = json.load(f)
    with open(os.path.join(bench_dir, "responses.json"), encoding="utf-8") as f:
        responses = json.load(f)
    by_qid = {q["question_id"]: q for q in bench["questions"]}

    per_cond = {c: [] for c in CONDS}
    detail_per_q = []
    for qid, q in by_qid.items():
        if qid not in responses:
            continue
        row = {"qid": qid, "type": q["type"], "scores": {}, "subq_correct": {}}
        for cond in CONDS:
            resp = responses[qid].get(cond, "")
            r = grade_response(q, resp)
            per_cond[cond].append(r)
            row["scores"][cond] = r["rubric_0_to_4"]
            row["subq_correct"][cond] = f"{r['n_correct']}/{r['n_subq']}"
        detail_per_q.append(row)

    cond_summary = {}
    for cond, results in per_cond.items():
        if not results:
            continue
        scores = [r["rubric_0_to_4"] for r in results]
        n_correct = sum(r["n_correct"] for r in results)
        n_total = sum(r["n_subq"] for r in results)
        cond_summary[cond] = {
            "n_questions": len(results),
            "mean_rubric": round(sum(scores) / max(1, len(scores)), 3),
            "subq_accuracy": round(n_correct / max(1, n_total), 3),
            "rubric_dist": {str(k): sum(1 for s in scores if s == k)
                            for k in range(5)},
        }
    return cond_summary, detail_per_q


def main():
    root = os.path.join(_ROOT, "SpatialMind", "benchmarks", "coe_reasoning")
    full = {}
    for slug, label in DIMS:
        path = os.path.join(root, slug)
        if not os.path.isdir(path):
            continue
        full[slug] = {"label": label, **dict(zip(
            ("summary", "detail"), grade_dim(path)))}

    # ---- Markdown table ----
    lines = []
    lines.append("# CoE Reasoning Benchmark — Dimension × Condition Summary\n")
    lines.append("Self-administered by Claude (Opus 4.7, 1M context). Each question "
                 "has 3 sub-parts; per-question rubric is 0–4 (see scoring spec). "
                 "Rows: dimension; columns: condition.\n")

    # Mean rubric (0–4) table
    lines.append("## Mean rubric per (dimension, condition)\n")
    header = "| Dimension | n | " + " | ".join(CONDS) + " |"
    sep = "|" + "|".join(["---"] * (len(CONDS) + 2)) + "|"
    lines.append(header)
    lines.append(sep)
    for slug, label in DIMS:
        if slug not in full:
            continue
        s = full[slug]["summary"]
        n = next(iter(s.values()))["n_questions"] if s else 0
        cells = [f"{s.get(c, {}).get('mean_rubric', '?'):.2f}" for c in CONDS]
        lines.append(f"| {full[slug]['label']} | {n} | " + " | ".join(cells) + " |")

    lines.append("\n## Sub-question accuracy per (dimension, condition)\n")
    lines.append(header)
    lines.append(sep)
    for slug, label in DIMS:
        if slug not in full:
            continue
        s = full[slug]["summary"]
        n = next(iter(s.values()))["n_questions"] if s else 0
        cells = [f"{s.get(c, {}).get('subq_accuracy', 0)*100:.1f}%" for c in CONDS]
        lines.append(f"| {full[slug]['label']} | {n} | " + " | ".join(cells) + " |")

    # Per-question detail table for transparency
    lines.append("\n## Per-question rubric details\n")
    lines.append("| Dimension | Question | Type | base | cot | coe_r | coe_ctr |")
    lines.append("|---|---|---|---|---|---|---|")
    for slug, label in DIMS:
        if slug not in full:
            continue
        for row in full[slug]["detail"]:
            cells = [str(row["scores"][c]) for c in CONDS]
            lines.append(f"| {full[slug]['label']} | {row['qid']} | {row['type']} | "
                         + " | ".join(cells) + " |")

    md = "\n".join(lines) + "\n"
    out_md = os.path.join(root, "SUMMARY.md")
    with open(out_md, "w", encoding="utf-8") as f:
        f.write(md)
    out_json = os.path.join(root, "summary.json")
    with open(out_json, "w", encoding="utf-8") as f:
        json.dump({slug: full[slug]["summary"] for slug in full}, f,
                  ensure_ascii=False, indent=2)

    print(f"Wrote {out_md}")
    print(f"Wrote {out_json}\n")
    print(md)


if __name__ == "__main__":
    main()
