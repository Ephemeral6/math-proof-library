"""
Persistence layer.

Sediments reusable assets across runs into `LeanAgent/registry/`:

  registry/
    definitions/        future: per-definition metadata (currently empty)
    lemmas/             one JSON per CERTIFIED lemma (theorem_name as filename)
    playbook/           entries.jsonl — successful (goal_pattern, tactic) pairs
    failures/           entries.jsonl — STUCK goal-states + what was tried
    pairs/              entries.jsonl — NL ↔ Lean translation pairs

The MVP search uses simple substring matching. Vector search and Mathlib-side
deduplication are deliberate non-goals here — they belong in a Maintenance
agent, not in the hot pipeline path.
"""

from __future__ import annotations

import json
import re
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Any


# --------------------------------------------------------------------------- #
# Manager
# --------------------------------------------------------------------------- #


@dataclass
class PersistenceManager:
    registry_dir: Path

    def __post_init__(self):
        self.registry_dir = Path(self.registry_dir)
        for sub in ("definitions", "lemmas", "playbook", "failures", "pairs"):
            (self.registry_dir / sub).mkdir(parents=True, exist_ok=True)

    # ----- writers ------------------------------------------------------- #

    def save_lemma(
        self,
        *,
        theorem_name: str,
        lean_file: Path | str,
        nl_statement: str,
        assumptions: list[str],
        verdict: str,
        pr_ready: bool = False,
        domain: str = "unknown",
        source: str = "NEW",
        extra: dict | None = None,
    ) -> Path:
        record = {
            "theorem_name": theorem_name,
            "lean_file": str(lean_file),
            "nl_statement": nl_statement,
            "assumptions": list(assumptions or []),
            "verdict": verdict,
            "pr_ready": pr_ready,
            "domain": domain,
            "source": source,
            "saved_at": _now(),
        }
        if extra:
            record["extra"] = extra
        path = self.registry_dir / "lemmas" / f"{_safe_name(theorem_name)}.json"
        path.write_text(
            json.dumps(record, indent=2, ensure_ascii=False), encoding="utf-8"
        )
        return path

    def save_tactic_success(
        self,
        *,
        goal_pattern: str,
        tactic: str,
        domain: str = "unknown",
        time_ms: int = 0,
        theorem_name: str | None = None,
    ) -> None:
        self._append_jsonl(
            "playbook/entries.jsonl",
            {
                "goal_pattern": _truncate(goal_pattern, 2000),
                "tactic": tactic,
                "domain": domain,
                "time_ms": time_ms,
                "theorem_name": theorem_name,
                "saved_at": _now(),
            },
        )

    def save_failure(
        self,
        *,
        goal_state: str,
        tried: list[dict],
        root_cause: str,
        resolved: bool = False,
        theorem_name: str | None = None,
    ) -> None:
        self._append_jsonl(
            "failures/entries.jsonl",
            {
                "goal_state": _truncate(goal_state, 2000),
                "tried": tried,
                "root_cause": root_cause,
                "resolved": resolved,
                "theorem_name": theorem_name,
                "saved_at": _now(),
            },
        )

    def save_translation_pair(
        self,
        *,
        nl: str,
        lean: str,
        difficulty: str = "unknown",
        domain: str = "unknown",
        theorem_name: str | None = None,
    ) -> None:
        self._append_jsonl(
            "pairs/entries.jsonl",
            {
                "nl": nl,
                "lean": lean,
                "difficulty": difficulty,
                "domain": domain,
                "theorem_name": theorem_name,
                "saved_at": _now(),
            },
        )

    # ----- readers / search --------------------------------------------- #

    def search_playbook(
        self, goal_pattern: str, *, top_k: int = 5
    ) -> list[dict]:
        """Substring overlap on tokenized goal patterns. Cheap, deterministic."""
        return self._search_jsonl(
            "playbook/entries.jsonl", "goal_pattern", goal_pattern, top_k=top_k
        )

    def search_lemmas(self, query: str, *, top_k: int = 5) -> list[dict]:
        out: list[tuple[float, dict]] = []
        for path in (self.registry_dir / "lemmas").glob("*.json"):
            try:
                rec = json.loads(path.read_text(encoding="utf-8"))
            except json.JSONDecodeError:
                continue
            score = _overlap_score(query, rec.get("nl_statement", ""))
            if score > 0:
                out.append((score, rec))
        out.sort(key=lambda kv: kv[0], reverse=True)
        return [r for _, r in out[:top_k]]

    def search_failures(self, goal_state: str, *, top_k: int = 5) -> list[dict]:
        return self._search_jsonl(
            "failures/entries.jsonl", "goal_state", goal_state, top_k=top_k
        )

    # ----- summary ------------------------------------------------------- #

    def summary(self) -> dict:
        return {
            "lemmas": _count_files(self.registry_dir / "lemmas", "*.json"),
            "playbook": _count_lines(self.registry_dir / "playbook" / "entries.jsonl"),
            "failures": _count_lines(self.registry_dir / "failures" / "entries.jsonl"),
            "pairs": _count_lines(self.registry_dir / "pairs" / "entries.jsonl"),
        }

    # ----- helpers ------------------------------------------------------- #

    def _append_jsonl(self, rel: str, record: dict) -> None:
        path = self.registry_dir / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("a", encoding="utf-8") as f:
            f.write(json.dumps(record, ensure_ascii=False) + "\n")

    def _search_jsonl(
        self, rel: str, field: str, query: str, *, top_k: int
    ) -> list[dict]:
        path = self.registry_dir / rel
        if not path.exists():
            return []
        out: list[tuple[float, dict]] = []
        with path.open("r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    rec = json.loads(line)
                except json.JSONDecodeError:
                    continue
                score = _overlap_score(query, rec.get(field, ""))
                if score > 0:
                    out.append((score, rec))
        out.sort(key=lambda kv: kv[0], reverse=True)
        return [r for _, r in out[:top_k]]


# --------------------------------------------------------------------------- #
# Lightweight scoring (token overlap; punctuation stripped, case-folded)
# --------------------------------------------------------------------------- #

_TOKEN_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_]*|[一-鿿]+|[<>≤≥≠=∀∃∈∑∫∇‖]")


def _tokens(text: str) -> set[str]:
    return {t.lower() for t in _TOKEN_RE.findall(text or "")}


def _overlap_score(query: str, candidate: str) -> float:
    q = _tokens(query)
    c = _tokens(candidate)
    if not q or not c:
        return 0.0
    inter = len(q & c)
    if inter == 0:
        return 0.0
    return inter / (len(q) + len(c) - inter)  # Jaccard


# --------------------------------------------------------------------------- #
# Misc utilities
# --------------------------------------------------------------------------- #


def _now() -> str:
    return time.strftime("%Y-%m-%dT%H:%M:%S")


def _safe_name(name: str) -> str:
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", name).strip("_") or "unnamed"


def _truncate(s: str, n: int) -> str:
    s = s or ""
    return s if len(s) <= n else s[:n] + "…"


def _count_files(path: Path, pattern: str) -> int:
    if not path.exists():
        return 0
    return sum(1 for _ in path.glob(pattern))


def _count_lines(path: Path) -> int:
    if not path.exists():
        return 0
    n = 0
    with path.open("r", encoding="utf-8") as f:
        for _ in f:
            n += 1
    return n
