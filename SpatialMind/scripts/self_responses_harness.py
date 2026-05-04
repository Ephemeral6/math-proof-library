"""Convert structured self-answers into the responses JSON consumed by the grader.

Usage:
    from self_responses_harness import build_response, save_responses
    answers = {
      ("dim4_q01", "baseline"): {"a": 3, "b": [0, 3], "c": 130, "_r": "..."},
      ...
    }
    save_responses(answers, "all_responses.json")
"""

from __future__ import annotations

import json
import os


def _format_value(v):
    if isinstance(v, list):
        return "{" + ", ".join(str(x) for x in v) + "}"
    if isinstance(v, tuple) and len(v) == 2 and all(isinstance(x, (int, float)) for x in v):
        return f"{v[0]} -> {v[1]}"
    return str(v)


def build_response(per_subq: dict, reasoning: str = "") -> str:
    """Render a {label: value, "_r": reasoning} dict into [ANSWER]/[REASONING]."""
    lines = ["[ANSWER]"]
    for label in ("a", "b", "c", "d"):
        if label in per_subq:
            lines.append(f"({label}) {_format_value(per_subq[label])}")
    lines.append("[/ANSWER]")
    lines.append("")
    lines.append("[REASONING]")
    lines.append(reasoning or per_subq.get("_r", ""))
    lines.append("[/REASONING]")
    return "\n".join(lines)


def save_responses(answers: dict, out_path: str):
    """Group by qid → condition → response_string and dump JSON."""
    grouped: dict = {}
    for (qid, cond), per_subq in answers.items():
        reasoning = per_subq.pop("_r", "") if "_r" in per_subq else ""
        grouped.setdefault(qid, {})[cond] = build_response(
            {k: v for k, v in per_subq.items() if k in ("a", "b", "c", "d")},
            reasoning,
        )
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(grouped, f, ensure_ascii=False, indent=2)
    print(f"Wrote {sum(len(v) for v in grouped.values())} responses across "
          f"{len(grouped)} questions to {out_path}")


if __name__ == "__main__":
    # Smoke
    answers = {
        ("dim4_q01", "baseline"): {"a": 3, "b": [0, 3], "c": 130,
                                   "_r": "period-3 ⇒ stab={e,r^3}, orbit=6/2=3."},
    }
    save_responses(answers, "/tmp/test_responses.json")
