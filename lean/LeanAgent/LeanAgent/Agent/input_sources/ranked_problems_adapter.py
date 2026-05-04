"""Adapter for `workspace/projects/proposer/ranked_problems.md`.

Parses the markdown's `### Rank N:` blocks and emits the unified
problem dict shape consumed by `LeanAgent.LeanAgent.Agent.runner`.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


_RANK_HEADER = re.compile(r"^###\s+Rank\s+(\d+)\s*:\s*(.*)$", re.IGNORECASE)
_DIFFICULTY = re.compile(r"\*\*Estimated Difficulty\*\*\s*:\s*([^\n\[]+)")
_PROBLEM_HEADER = re.compile(r"\*\*Problem\s+Statement\*\*\s*:\s*", re.IGNORECASE)


def _slug(text: str) -> str:
    out: list[str] = []
    for ch in text.lower():
        if ch.isalnum():
            out.append(ch)
        elif ch in (" ", "-", "_"):
            out.append("-")
    return re.sub(r"-+", "-", "".join(out)).strip("-")


def _split_rank_blocks(md: str) -> list[tuple[int, str, str]]:
    """Return [(rank_num, title, body)] per `### Rank N: <title>` block."""
    lines = md.splitlines()
    blocks: list[tuple[int, str, list[str]]] = []
    cur: tuple[int, str, list[str]] | None = None
    for line in lines:
        m = _RANK_HEADER.match(line.strip())
        if m:
            if cur is not None:
                blocks.append(cur)
            cur = (int(m.group(1)), m.group(2).strip(), [])
            continue
        if cur is not None:
            # Stop at the next top-level heading (## ...)
            if line.startswith("## ") and not line.startswith("### "):
                blocks.append(cur)
                cur = None
                continue
            cur[2].append(line)
    if cur is not None:
        blocks.append(cur)
    return [(rk, title, "\n".join(body)) for rk, title, body in blocks]


def _extract_problem_statement(body: str) -> str:
    m = _PROBLEM_HEADER.search(body)
    if not m:
        return body.strip()[:300]
    rest = body[m.end():]
    # The problem statement runs until the next bold heading.
    end = re.search(r"\n\s*\*\*[A-Z]", rest)
    chunk = rest[: end.start()] if end else rest
    return chunk.strip()


def _classify_domain(title: str) -> str:
    t = title.lower()
    # Cheap keyword routing — the orchestrator only needs a coarse bucket.
    if any(k in t for k in ("shb", "adam", "sgd", "gd ", "momentum",
                             "polyak", "ruppert", "convergence", "rate",
                             "stochastic", "optimization")):
        return "optimization"
    if any(k in t for k in ("rademacher", "generalization", "pac",
                             "stability", "learning")):
        return "learning_theory"
    if any(k in t for k in ("hoeffding", "bernstein", "sub-gaussian",
                             "concentration")):
        return "statistics"
    if any(k in t for k in ("graph", "covering", "combinator")):
        return "combinatorics"
    return "optimization"  # default — most ranked_problems entries are opt


@dataclass
class _Problem:
    problem_id: str
    goal: str
    domain: str
    lean_statement: str | None
    source: str
    literature_in_scope: list[str]
    title: str
    rank: int
    difficulty: str


def _to_dict(p: _Problem) -> dict:
    return {
        "problem_id": p.problem_id,
        "goal": p.goal,
        "domain": p.domain,
        "lean_statement": p.lean_statement,
        "source": p.source,
        "literature_in_scope": list(p.literature_in_scope),
        "title": p.title,
        "rank": p.rank,
        "estimated_difficulty": p.difficulty,
    }


def parse_ranked_problems(
    path: Path | str,
    *,
    limit: int | None = None,
) -> list[dict]:
    """Parse `ranked_problems.md` into a list of problem dicts."""
    text = Path(path).read_text(encoding="utf-8")
    out: list[dict] = []
    for rank, title, body in _split_rank_blocks(text):
        problem_id = f"RANKED-{rank:02d}-{_slug(title)[:48]}"
        goal = _extract_problem_statement(body) or title
        diff_match = _DIFFICULTY.search(body)
        difficulty = (
            diff_match.group(1).strip().split("\n")[0]
            if diff_match else "unknown"
        )
        prob = _Problem(
            problem_id=problem_id,
            goal=goal,
            domain=_classify_domain(title),
            lean_statement=None,
            source="ranked_problems",
            literature_in_scope=[],
            title=title,
            rank=rank,
            difficulty=difficulty,
        )
        out.append(_to_dict(prob))
        if limit is not None and len(out) >= limit:
            break
    return out
