"""Run 6-condition accuracy eval on MCQ benchmarks against Anthropic Claude.

Conditions:
  Baseline  - question + options only
  CoT       - question + options + "think step by step"
  CoE-R     - + Relation data (detailed_comparison, structural_comparison)
  CoE-RT    - + Relation + Transform (transform_trace, reference_in_transform_region)
  CoE-RC    - + Relation + Contrastive (counterfactual)
  CoE-CTR   - + Relation + Transform + Contrastive

Usage:
  ANTHROPIC_API_KEY=... python -m scripts.coe_accuracy.run_accuracy_eval --domain graph_connectivity
  ANTHROPIC_API_KEY=... python -m scripts.coe_accuracy.run_accuracy_eval --all

Output: SpatialMind/benchmarks/<domain>/mcq/results_<condition>.json
        SpatialMind/benchmarks/<domain>/mcq/summary.json
"""

import os
import re
import json
import time
import argparse
import concurrent.futures as cf
from pathlib import Path

from anthropic import Anthropic, APIError, APIStatusError

ROOT = Path(__file__).resolve().parents[2]
BENCH = ROOT / "benchmarks"
MODEL = "claude-sonnet-4-6"
MAX_TOKENS = 1024

CONDITIONS = ["Baseline", "CoT", "R", "RT", "RC", "RTC"]
LABEL = {
    "Baseline": "Baseline",
    "CoT": "CoT",
    "R": "CoE-R",
    "RT": "CoE-RT",
    "RC": "CoE-RC",
    "RTC": "CoE-CTR",
}

SYSTEM_PROMPT = (
    "你是一位严谨的数学专家。下面会给你一道多选题, 你需要选出最准确的答案 (A/B/C/D)。\n"
    "回答规则:\n"
    "1. 如果给了 \"engine 数据\" (Relation/Transform/Contrastive), 优先基于数据推理。\n"
    "2. 推理简明, 但答案必须明确。\n"
    "3. 你的回答最后一行必须只包含一个字母: A、B、C 或 D。"
)

ANSWER_LINE_RE = re.compile(r'^\s*\(?([ABCD])\)?\s*[\.。\)]?\s*$')
ANSWER_INLINE_RE = re.compile(r'\b([ABCD])\b')
ANSWER_LABELED_RE = re.compile(r'答案[:：\s]*\(?([ABCD])\)?')


def parse_answer(text):
    if not text:
        return None
    lines = [l.strip() for l in text.strip().split("\n") if l.strip()]
    for line in reversed(lines[-3:]):
        m = ANSWER_LINE_RE.match(line)
        if m:
            return m.group(1)
    m = ANSWER_LABELED_RE.search(text)
    if m:
        return m.group(1)
    if lines:
        m = ANSWER_INLINE_RE.search(lines[-1])
        if m:
            return m.group(1)
    return None


def build_user_message(q, condition):
    parts = [f"题目: {q['question']}", "", "选项:"]
    for k, v in q["options"].items():
        parts.append(f"{k}. {v}")

    coe = q["coe_data"]

    if condition in ("Baseline", "CoT"):
        pass
    else:
        sections = []
        if "R" in condition:
            sections.append(("Relation 数据 (结构比较, 关键字段直接给出)", coe["R"]))
        if "T" in condition:
            sections.append(("Transform 数据 (变换轨迹与受影响区域)", coe["T"]))
        if "C" in condition:
            sections.append(("Contrastive 数据 (反事实对比)", coe["C"]))
        for title, data in sections:
            parts.append("")
            parts.append(f"## {title}")
            parts.append("```json")
            parts.append(json.dumps(data, ensure_ascii=False, indent=2))
            parts.append("```")

    if condition == "CoT":
        parts.append("")
        parts.append("请一步一步推理, 推理结束后另起一行只写答案的字母 (A、B、C 或 D)。")
    else:
        parts.append("")
        parts.append("基于以上信息选出答案。最后一行只写答案的字母 (A、B、C 或 D)。")

    return "\n".join(parts)


def call_claude(client, system, user, max_retries=3):
    delay = 2.0
    last_err = None
    for attempt in range(max_retries):
        try:
            resp = client.messages.create(
                model=MODEL,
                max_tokens=MAX_TOKENS,
                system=[{"type": "text", "text": system, "cache_control": {"type": "ephemeral"}}],
                messages=[{"role": "user", "content": user}],
            )
            text = "".join(blk.text for blk in resp.content if blk.type == "text")
            usage = {
                "input_tokens": resp.usage.input_tokens,
                "output_tokens": resp.usage.output_tokens,
                "cache_creation": getattr(resp.usage, "cache_creation_input_tokens", 0),
                "cache_read": getattr(resp.usage, "cache_read_input_tokens", 0),
            }
            return text, usage, None
        except (APIError, APIStatusError) as e:
            last_err = e
            time.sleep(delay)
            delay *= 2
        except Exception as e:
            last_err = e
            time.sleep(delay)
            delay *= 2
    return None, None, str(last_err)


def eval_one(client, q, condition):
    user = build_user_message(q, condition)
    text, usage, err = call_claude(client, SYSTEM_PROMPT, user)
    if err:
        return {
            "question_id": q["question_id"],
            "condition": condition,
            "predicted": None,
            "correct": q["answer"],
            "is_correct": False,
            "raw": None,
            "error": err,
            "usage": None,
        }
    pred = parse_answer(text)
    return {
        "question_id": q["question_id"],
        "condition": condition,
        "predicted": pred,
        "correct": q["answer"],
        "is_correct": (pred == q["answer"]),
        "raw": text,
        "error": None,
        "usage": usage,
    }


def run_domain(client, domain, conditions, max_workers=8, limit=None):
    qs_path = BENCH / domain / "mcq" / "questions.json"
    with open(qs_path, "r", encoding="utf-8") as f:
        qs = json.load(f)["questions"]
    if limit:
        qs = qs[:limit]
    out_dir = BENCH / domain / "mcq"
    out_dir.mkdir(parents=True, exist_ok=True)

    summary = {"domain": domain, "n_questions": len(qs), "conditions": {}}

    for cond in conditions:
        results = [None] * len(qs)
        t0 = time.time()
        with cf.ThreadPoolExecutor(max_workers=max_workers) as ex:
            fut_to_idx = {ex.submit(eval_one, client, q, cond): i for i, q in enumerate(qs)}
            done = 0
            for fut in cf.as_completed(fut_to_idx):
                idx = fut_to_idx[fut]
                results[idx] = fut.result()
                done += 1
                if done % 10 == 0 or done == len(qs):
                    print(f"  [{domain}/{LABEL[cond]}] {done}/{len(qs)}", flush=True)
        elapsed = time.time() - t0
        n_correct = sum(1 for r in results if r["is_correct"])
        n_err = sum(1 for r in results if r["error"] is not None)
        acc = n_correct / len(results) if results else 0.0
        with open(out_dir / f"results_{cond}.json", "w", encoding="utf-8") as f:
            json.dump({
                "domain": domain,
                "condition": cond,
                "label": LABEL[cond],
                "n": len(results),
                "n_correct": n_correct,
                "n_error": n_err,
                "accuracy": acc,
                "elapsed_sec": round(elapsed, 1),
                "results": results,
            }, f, ensure_ascii=False, indent=2)
        summary["conditions"][cond] = {
            "label": LABEL[cond],
            "accuracy": acc,
            "n_correct": n_correct,
            "n": len(results),
            "n_error": n_err,
            "elapsed_sec": round(elapsed, 1),
        }
        print(f"  [{domain}/{LABEL[cond]}] acc={acc:.3f} ({n_correct}/{len(results)}, errs={n_err}) in {elapsed:.1f}s")

    with open(out_dir / "summary.json", "w", encoding="utf-8") as f:
        json.dump(summary, f, ensure_ascii=False, indent=2)
    return summary


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--domain", default=None)
    p.add_argument("--all", action="store_true")
    p.add_argument("--conditions", nargs="+", default=CONDITIONS)
    p.add_argument("--workers", type=int, default=8)
    p.add_argument("--limit", type=int, default=None, help="cap questions per domain (smoke test)")
    args = p.parse_args()

    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        raise SystemExit("ANTHROPIC_API_KEY not set in environment.")
    client = Anthropic(api_key=api_key)

    if args.all:
        domains = sorted(d.name for d in BENCH.iterdir()
                         if d.is_dir() and (d / "mcq" / "questions.json").exists())
    else:
        if not args.domain:
            raise SystemExit("Specify --domain X or --all.")
        domains = [args.domain]

    all_summaries = []
    for dom in domains:
        print(f"\n=== Running {dom} ===")
        s = run_domain(client, dom, args.conditions, max_workers=args.workers, limit=args.limit)
        all_summaries.append(s)

    # Print pretty summary table
    print("\n" + "=" * 70)
    header = f"{'domain':<28}" + "".join(f"{LABEL[c]:>10}" for c in args.conditions)
    print(header)
    print("-" * len(header))
    for s in all_summaries:
        row = f"{s['domain']:<28}" + "".join(
            f"{s['conditions'][c]['accuracy']*100:>9.1f}%" for c in args.conditions if c in s['conditions']
        )
        print(row)


if __name__ == "__main__":
    main()
