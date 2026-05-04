"""Auto-grader for the CoE Geometric Reasoning Benchmark (Dimension 4).

Parses an LLM response, extracts the `[ANSWER]...[/ANSWER]` block, and scores
each sub-question against the ground truth.

Per-question rubric (0-4):
  0 — no correct sub-answers
  1 — `direction_correct` heuristic fired but no value correct
  2 — about half of sub-answers correct  (rounded down for odd counts)
  3 — almost all correct (off by exactly one)
  4 — every sub-answer correct

Direction heuristic: presence of one of the keywords {"Burnside", "orbit-stabilizer",
"轨道-稳定子", "稳定子", "Stab", "Orbit"} in the [REASONING] block. This catches
responses that reach for the right tool but mis-compute.

Usage (programmatic):
  from grade_coe_reasoning_dim4 import grade_response
  result = grade_response(question_dict, response_text)

CLI:
  python grade_coe_reasoning_dim4.py path/to/responses.json
  where responses.json maps {question_id: {condition: response_text, ...}, ...}
"""

from __future__ import annotations

import json
import os
import re
import sys
from typing import Any

_THIS = os.path.dirname(os.path.abspath(__file__))
_ROOT = os.path.abspath(os.path.join(_THIS, "..", ".."))

ANSWER_BLOCK = re.compile(
    r"\[ANSWER\](.*?)\[/ANSWER\]", flags=re.DOTALL | re.IGNORECASE
)
REASONING_BLOCK = re.compile(
    r"\[REASONING\](.*?)\[/REASONING\]", flags=re.DOTALL | re.IGNORECASE
)
SUBQ_LINE = re.compile(r"\(([abcd])\)\s*(.+?)(?=\n\([a-d]\)|\Z)", flags=re.DOTALL)
INT_PATTERN = re.compile(r"-?\d+")
DIRECTION_KEYWORDS = (
    "burnside", "orbit-stabilizer", "轨道-稳定子", "稳定子",
    "stab(", "stabilizer", "orbit", "轨道", "fix(",
)


def _parse_answer_block(text: str) -> dict[str, str]:
    """Extract per-label raw answers from the [ANSWER] block."""
    m = ANSWER_BLOCK.search(text)
    if not m:
        return {}
    body = m.group(1).strip()
    found = {}
    for sm in SUBQ_LINE.finditer(body):
        label = sm.group(1).lower()
        value = sm.group(2).strip()
        # value may have multiple lines; take just the first non-empty line
        first_line = next((ln.strip() for ln in value.splitlines() if ln.strip()), "")
        found[label] = first_line
    return found


def _parse_integer(s: str):
    m = INT_PATTERN.search(s)
    return int(m.group(0)) if m else None


def _parse_int_set(s: str):
    """Extract a set of non-negative integers from arbitrary delimiters."""
    nums = INT_PATTERN.findall(s)
    return sorted({int(x) for x in nums})


def _parse_two_integers(s: str):
    nums = INT_PATTERN.findall(s)
    return [int(x) for x in nums[:2]] if len(nums) >= 2 else None


def _check(parsed, expected, answer_type) -> bool:
    if parsed is None:
        return False
    if answer_type == "integer":
        return parsed == expected
    if answer_type == "set_of_int":
        return parsed == sorted(expected)
    if answer_type == "two_integers":
        return parsed == list(expected)
    return False


def _normalize(raw: str, answer_type: str):
    if raw is None or raw == "":
        return None
    if answer_type == "integer":
        return _parse_integer(raw)
    if answer_type == "set_of_int":
        return _parse_int_set(raw)
    if answer_type == "two_integers":
        return _parse_two_integers(raw)
    return None


def _direction_hit(text: str) -> bool:
    low = text.lower()
    return any(k in low for k in DIRECTION_KEYWORDS)


def grade_response(question: dict, response_text: str) -> dict:
    """Score one (question, response) pair.

    Returns dict with per-subq correctness, raw parsed values, and a 0-4 score.
    """
    raw_answers = _parse_answer_block(response_text)
    reasoning_match = REASONING_BLOCK.search(response_text)
    reasoning_text = reasoning_match.group(1) if reasoning_match else ""

    per_subq = []
    for sq in question["subquestions"]:
        label = sq["label"].strip("()").lower()
        raw = raw_answers.get(label)
        parsed = _normalize(raw, sq["answer_type"]) if raw is not None else None
        correct = _check(parsed, sq["answer"], sq["answer_type"])
        per_subq.append({
            "label": sq["label"],
            "answer_type": sq["answer_type"],
            "expected": sq["answer"],
            "raw": raw,
            "parsed": parsed,
            "correct": correct,
        })

    n = len(per_subq)
    n_correct = sum(1 for r in per_subq if r["correct"])
    direction = _direction_hit(reasoning_text or response_text)

    if n_correct == n:
        rubric = 4
    elif n_correct == n - 1 and n >= 3:
        rubric = 3
    elif n_correct >= max(1, n // 2):
        rubric = 2
    elif n_correct >= 1:
        rubric = 2 if direction else 1
    elif direction:
        rubric = 1
    else:
        rubric = 0

    return {
        "question_id": question["question_id"],
        "type": question["type"],
        "n_subq": n,
        "n_correct": n_correct,
        "direction_hit": direction,
        "rubric_0_to_4": rubric,
        "per_subq": per_subq,
        "answer_block_found": bool(raw_answers),
    }


def grade_file(questions_path: str, responses_path: str) -> dict:
    with open(questions_path, "r", encoding="utf-8") as f:
        bench = json.load(f)
    with open(responses_path, "r", encoding="utf-8") as f:
        responses = json.load(f)

    by_qid = {q["question_id"]: q for q in bench["questions"]}
    by_condition: dict[str, list[dict]] = {}
    for qid, cond_to_resp in responses.items():
        if qid not in by_qid:
            continue
        for cond, resp in cond_to_resp.items():
            r = grade_response(by_qid[qid], resp)
            r["condition"] = cond
            by_condition.setdefault(cond, []).append(r)

    summary = {}
    for cond, results in by_condition.items():
        scores = [r["rubric_0_to_4"] for r in results]
        n_correct_total = sum(r["n_correct"] for r in results)
        n_subq_total = sum(r["n_subq"] for r in results)
        summary[cond] = {
            "n_questions": len(results),
            "mean_rubric": round(sum(scores) / max(1, len(scores)), 3),
            "subq_accuracy": round(n_correct_total / max(1, n_subq_total), 3),
            "rubric_dist": {
                str(k): sum(1 for s in scores if s == k) for k in range(5)
            },
        }
    return {"summary": summary, "results_by_condition": by_condition}


# Self-test ------------------------------------------------------------------

if __name__ == "__main__":
    if len(sys.argv) >= 3:
        out = grade_file(sys.argv[1], sys.argv[2])
        print(json.dumps(out["summary"], indent=2, ensure_ascii=False))
        sys.exit(0)

    # quick smoke test on a fake response
    bench_path = os.path.join(
        _ROOT, "SpatialMind", "benchmarks", "coe_reasoning",
        "dim4_symmetry", "questions.json"
    )
    with open(bench_path, "r", encoding="utf-8") as f:
        bench = json.load(f)
    q1 = bench["questions"][0]
    correct_response = """
我先分析。

[ANSWER]
(a) 3
(b) {0, 3}
(c) 130
[/ANSWER]

[REASONING]
对于 c = (0,1,2,0,1,2)，rotation by 3 fixes c, so Stab = {0, 3}.
轨道-稳定子定理：|Orbit| = |G| / |Stab| = 6/2 = 3.
Burnside: (729+3+9+27+9+3)/6 = 130.
[/REASONING]
"""
    wrong_response = """
[ANSWER]
(a) 6
(b) {0}
(c) 100
[/ANSWER]

[REASONING]
I think the orbit is the full group, so 6.
[/REASONING]
"""
    partial_response = """
[ANSWER]
(a) 3
(b) {0, 3}
(c) 200
[/ANSWER]

[REASONING]
Burnside lemma: orbit-stabilizer gives Stab = {0,3}, |Orbit| = 3.
Total orbits I'm not sure, guessing 200.
[/REASONING]
"""
    print("=== correct ===")
    print(json.dumps(grade_response(q1, correct_response), indent=2, ensure_ascii=False))
    print("\n=== wrong ===")
    print(json.dumps(grade_response(q1, wrong_response), indent=2, ensure_ascii=False))
    print("\n=== partial ===")
    print(json.dumps(grade_response(q1, partial_response), indent=2, ensure_ascii=False))
