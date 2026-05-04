"""
Append a list of case-evaluations to repeated_ablation_results.json.
Usage: python append_ratings.py path/to/payload.json
where payload.json is a list of {domain, case_id, case_summary, evaluations} blocks.
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RESULTS = ROOT / "experiments" / "repeated_ablation_results.json"

LABEL_BY_SCORE = {0: "NO_SIGNAL", 1: "WRONG_PATTERN", 2: "PATTERN", 3: "ARGUMENT", 4: "PROOF"}


def main(payload_path):
    with open(payload_path, "r", encoding="utf-8") as f:
        new = json.load(f)
    with open(RESULTS, "r", encoding="utf-8") as f:
        cur = json.load(f)
    # Validate
    for r in new:
        assert "domain" in r and "case_id" in r and "evaluations" in r
        for cond, ev in r["evaluations"].items():
            assert "score" in ev
            ev.setdefault("label", LABEL_BY_SCORE[ev["score"]])
    cur["ratings"].extend(new)
    with open(RESULTS, "w", encoding="utf-8") as f:
        json.dump(cur, f, ensure_ascii=False, indent=2)
    print(f"Appended {len(new)} cases. Total: {len(cur['ratings'])} cases.")


if __name__ == "__main__":
    main(sys.argv[1])
