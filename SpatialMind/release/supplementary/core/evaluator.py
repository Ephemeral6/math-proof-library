"""core/evaluator.py — LLM evaluator for benchmark levels.

给 LLM benchmark 数据，让它尝试构造证明，收集评分。
支持 stub 模式（不调用 LLM，返回固定评分）用于测试。
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import IntEnum
from pathlib import Path
import json
import time
from typing import Any


class Score(IntEnum):
    NO_SIGNAL = 0
    WRONG_PATTERN = 1
    PATTERN = 2
    ARGUMENT = 3
    PROOF = 4


@dataclass
class LevelResult:
    level: int
    score: Score
    findings: str
    proof_attempt: str
    key_insight: str
    time_seconds: float
    raw_response: str = ""

    def to_json(self) -> dict:
        return {
            "level": self.level,
            "score": self.score.name,
            "score_value": int(self.score),
            "findings": self.findings,
            "proof_attempt": self.proof_attempt,
            "key_insight": self.key_insight,
            "time_seconds": self.time_seconds,
        }


@dataclass
class BenchmarkResult:
    domain: str
    levels: list[LevelResult]

    @property
    def pivot_level(self) -> int | None:
        for lr in self.levels:
            if lr.score >= Score.ARGUMENT:
                return lr.level
        return None

    @property
    def max_score(self) -> Score:
        if not self.levels:
            return Score.NO_SIGNAL
        return Score(max(lr.score for lr in self.levels))

    def to_json(self) -> dict:
        return {
            "domain": self.domain,
            "pivot_level": self.pivot_level,
            "max_score": self.max_score.name,
            "levels": [lr.to_json() for lr in self.levels],
        }

    def save(self, path: Path):
        with open(path, "w", encoding="utf-8") as f:
            json.dump(self.to_json(), f, indent=2, ensure_ascii=False)
