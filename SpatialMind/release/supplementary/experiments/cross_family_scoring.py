"""Cross-family re-scoring of Opus responses by DeepSeek + Qwen.

Goal: audit "same-family self-rating bias". The original n10 sweep had Opus
respond AND Opus self-score. This script keeps the responses but re-scores them
with two outside families (DeepSeek, Qwen). The downstream analysis then asks:
does Opus systematically inflate its scores on the RTC condition relative to
external graders?

Slice: 48 trials = 8 domains x 2 conditions (zero_cot baseline, coe_rtc) x 3 cases.
The 3 cases per domain are the first 3 in the n10 design's cases_per_domain.

Dependencies: pip install openai
Usage:
    DEEPSEEK_API_KEY=sk-xxx QWEN_API_KEY=sk-xxx python cross_family_scoring.py
"""
from __future__ import annotations

import json
import os
import re
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SOURCE_PATH = ROOT / "method_comparison_n10_results.json"
OUT_PATH = ROOT / "cross_family_scoring_responses.json"

GRADERS = {
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

CONDITIONS = ("zero_cot", "coe_rtc")
CASES_PER_DOMAIN = 3

PROMPT_TEMPLATE = (
    "You are an expert mathematical reasoning evaluator. Rate the following response "
    "on a 0-4 scale:\n"
    "0 = NO_SIGNAL: no usable hypothesis\n"
    "1 = WRONG_PATTERN: hypothesis contradicted by evidence\n"
    "2 = PATTERN: correct structural observation without justification\n"
    "3 = ARGUMENT: explicit chain hypothesis -> observation -> conclusion with correct key steps\n"
    "4 = PROOF: fully verifiable proof\n\n"
    "Problem domain: {domain}\n"
    "Condition: {condition}\n\n"
    "Response to evaluate:\n"
    "{response}\n\n"
    "Output ONLY a single integer 0-4, nothing else."
)

MAX_RETRIES = 3
RETRY_BACKOFF_SEC = 8
REQUEST_TIMEOUT = 120
MAX_TOKENS = 8

_SCORE_RE = re.compile(r"[0-4]")


def build_slice() -> list[dict]:
    with open(SOURCE_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)
    cases_by_domain: dict[str, list[str]] = {
        d: cs[:CASES_PER_DOMAIN] for d, cs in data["design"]["cases_per_domain"].items()
    }
    out: list[dict] = []
    for t in data["trials"]:
        if t["condition"] not in CONDITIONS:
            continue
        if t["case_id"] not in cases_by_domain[t["domain"]]:
            continue
        out.append(
            {
                "trial_id": t["trial_id"],
                "domain": t["domain"],
                "case_id": t["case_id"],
                "condition": t["condition"],
                "response": t["response"],
                "opus_score": t["score"],
                "opus_rationale": t.get("score_rationale", ""),
            }
        )
    return out


def parse_score(text: str) -> int | None:
    """Pull the first 0-4 integer out of the grader's reply."""
    if not text:
        return None
    m = _SCORE_RE.search(text.strip())
    return int(m.group(0)) if m else None


def call_grader(client, model_id: str, prompt: str) -> str:
    resp = client.chat.completions.create(
        model=model_id,
        messages=[{"role": "user", "content": prompt}],
        max_tokens=MAX_TOKENS,
        temperature=0,
        timeout=REQUEST_TIMEOUT,
    )
    choice = resp.choices[0]
    content = choice.message.content
    if content is None:
        content = getattr(choice.message, "reasoning_content", "") or ""
    return content


def call_with_retry(client, model_id: str, prompt: str) -> tuple[str, str | None]:
    last_err: Exception | None = None
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            return call_grader(client, model_id, prompt), None
        except Exception as e:  # noqa: BLE001
            last_err = e
            if attempt < MAX_RETRIES:
                print(f"    retry {attempt}/{MAX_RETRIES - 1} after error: {e!r}", flush=True)
                time.sleep(RETRY_BACKOFF_SEC)
    return "", f"{type(last_err).__name__}: {last_err}"


def main() -> int:
    missing = [cfg["env_key"] for cfg in GRADERS.values() if not os.environ.get(cfg["env_key"])]
    if missing:
        print(f"ERROR: missing env var(s): {', '.join(missing)}", file=sys.stderr)
        print(
            "Usage: DEEPSEEK_API_KEY=sk-xxx QWEN_API_KEY=sk-xxx "
            "python cross_family_scoring.py",
            file=sys.stderr,
        )
        return 2

    if not SOURCE_PATH.exists():
        print(f"ERROR: {SOURCE_PATH} not found", file=sys.stderr)
        return 2

    try:
        from openai import OpenAI
    except ImportError:
        print("ERROR: pip install openai", file=sys.stderr)
        return 2

    trials = build_slice()
    print(
        f"Slice: {len(trials)} trials "
        f"(8 domains x {len(CONDITIONS)} conditions x {CASES_PER_DOMAIN} cases)",
        flush=True,
    )
    if len(trials) != 8 * len(CONDITIONS) * CASES_PER_DOMAIN:
        print(
            f"WARNING: expected 48 trials, got {len(trials)}. "
            "Check method_comparison_n10_results.json shape.",
            flush=True,
        )

    clients = {
        name: OpenAI(api_key=os.environ[cfg["env_key"]], base_url=cfg["base_url"])
        for name, cfg in GRADERS.items()
    }

    out: dict = {
        "experiment": "cross_family_scoring",
        "design": {
            "purpose": (
                "Audit Opus self-rating bias by re-scoring the same Opus responses "
                "with two outside model families."
            ),
            "n_trials": len(trials),
            "factors": "8 domains x 2 conditions (zero_cot baseline, coe_rtc) x 3 cases",
            "graders": {k: v["model_id"] for k, v in GRADERS.items()},
            "rubric": {
                0: "NO_SIGNAL: no usable hypothesis",
                1: "WRONG_PATTERN: hypothesis contradicted by evidence",
                2: "PATTERN: correct structural observation without justification",
                3: "ARGUMENT: hypothesis -> observation -> conclusion with correct key steps",
                4: "PROOF: fully verifiable proof",
            },
            "source_file": SOURCE_PATH.name,
        },
        "trials": [],
    }

    n_total = len(trials) * len(GRADERS)
    idx = 0
    for trial in trials:
        prompt = PROMPT_TEMPLATE.format(
            domain=trial["domain"],
            condition=trial["condition"],
            response=trial["response"],
        )
        record = dict(trial)
        record["scores"] = {}
        record["raw"] = {}
        record["errors"] = {}

        for grader_name, cfg in GRADERS.items():
            idx += 1
            t0 = time.time()
            print(
                f"[{idx}/{n_total}] {grader_name} | trial {trial['trial_id']} | "
                f"{trial['domain']} | {trial['case_id']} | {trial['condition']} ...",
                end="",
                flush=True,
            )
            text, err = call_with_retry(clients[grader_name], cfg["model_id"], prompt)
            dt = time.time() - t0
            score = parse_score(text)
            if err is not None:
                print(f" FAILED ({dt:.1f}s): {err}", flush=True)
                record["errors"][grader_name] = err
            else:
                print(f" {score} ({dt:.1f}s)", flush=True)
            record["scores"][grader_name] = score
            record["raw"][grader_name] = text

        out["trials"].append(record)

        # Incremental save so a long-running failure doesn't lose progress.
        with open(OUT_PATH, "w", encoding="utf-8") as f:
            json.dump(out, f, ensure_ascii=False, indent=2)

    # Quick sanity summary
    n_scored = {g: sum(1 for r in out["trials"] if r["scores"].get(g) is not None) for g in GRADERS}
    print(
        f"\nDone. Wrote {OUT_PATH}\n"
        f"Scored: " + ", ".join(f"{g}={n}/{len(trials)}" for g, n in n_scored.items()),
        flush=True,
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
