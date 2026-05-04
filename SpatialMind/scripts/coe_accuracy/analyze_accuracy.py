"""Aggregate per-domain summary.json files into a cross-domain accuracy table.

Usage:
  python -m scripts.coe_accuracy.analyze_accuracy
  python -m scripts.coe_accuracy.analyze_accuracy --out benchmarks/coe_accuracy_summary.md
"""

import json
import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BENCH = ROOT / "benchmarks"

CONDITIONS = ["Baseline", "CoT", "R", "RT", "RC", "RTC"]
LABEL = {
    "Baseline": "Baseline",
    "CoT": "CoT",
    "R": "CoE-R",
    "RT": "CoE-RT",
    "RC": "CoE-RC",
    "RTC": "CoE-CTR",
}


def load_summaries():
    out = []
    for d in sorted(BENCH.iterdir()):
        s = d / "mcq" / "summary.json"
        if s.exists():
            with open(s, "r", encoding="utf-8") as f:
                out.append(json.load(f))
    return out


def render_markdown(summaries):
    lines = []
    lines.append("# CoE+CTR Accuracy Benchmark")
    lines.append("")
    subj = next((s.get("subject") for s in summaries if s.get("subject")), "claude-sonnet-4-6")
    lines.append(f"Cross-domain accuracy comparison, subject = `{subj}`.")
    lines.append("")
    header = "| Domain | N | " + " | ".join(LABEL[c] for c in CONDITIONS) + " | Best |"
    sep = "|" + "---|" * (3 + len(CONDITIONS))
    lines.append(header)
    lines.append(sep)
    col_acc = {c: [] for c in CONDITIONS}
    for s in summaries:
        row = [s["domain"], str(s["n_questions"])]
        best_cond, best_acc = None, -1.0
        for c in CONDITIONS:
            if c not in s["conditions"]:
                row.append("-")
                continue
            acc = s["conditions"][c]["accuracy"]
            col_acc[c].append(acc)
            row.append(f"{acc*100:.1f}%")
            if acc > best_acc:
                best_acc = acc
                best_cond = LABEL[c]
        row.append(best_cond or "-")
        lines.append("| " + " | ".join(row) + " |")
    lines.append("")
    avg_row = ["**average**", "-"]
    for c in CONDITIONS:
        if col_acc[c]:
            avg = sum(col_acc[c]) / len(col_acc[c])
            avg_row.append(f"**{avg*100:.1f}%**")
        else:
            avg_row.append("-")
    avg_row.append("-")
    lines.append("| " + " | ".join(avg_row) + " |")
    lines.append("")
    lines.append("## Per-condition breakdown")
    lines.append("")
    for s in summaries:
        lines.append(f"### {s['domain']}")
        lines.append("")
        lines.append("| Condition | Accuracy | Correct/N | Errors |")
        lines.append("|---|---|---|---|")
        for c in CONDITIONS:
            if c not in s["conditions"]:
                continue
            cs = s["conditions"][c]
            lines.append(f"| {LABEL[c]} | {cs['accuracy']*100:.1f}% | {cs['n_correct']}/{cs['n']} | {cs.get('n_error', 0)} |")
        lines.append("")
    return "\n".join(lines)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--out", default=str(BENCH / "coe_accuracy_summary.md"))
    args = p.parse_args()
    summaries = load_summaries()
    if not summaries:
        print("No summary.json found yet. Run run_accuracy_eval.py first.")
        return
    md = render_markdown(summaries)
    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(md, encoding="utf-8")
    print(f"Wrote {out.relative_to(ROOT)}")
    print()
    print(md)


if __name__ == "__main__":
    main()
