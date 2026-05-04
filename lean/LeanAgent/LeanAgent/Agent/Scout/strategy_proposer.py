"""Strategy Proposer — generate-probe-rank candidate directions after a Diagnoser verdict.

Spec: workspace/agents_spec/strategy_proposer.md.

Pipeline:
  1. generate_candidates  (1 LLM call)
  2. probe_candidates     (N × scout_one)
  3. rank_candidates      (sort + dedup)
  4. recommend top-1
"""

from __future__ import annotations

import datetime as _dt
import json
import os
import re
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Any, Literal, Optional

from LeanAgent.LeanAgent.Agent_legacy.LLM import LLM, LLMResponse

from .orchestrator import ScoutConfig, scout_one
from .tractability_report import TractabilityReport


_REPO_ROOT = Path(__file__).resolve().parents[4]
_DEFAULT_STUB_PATH = (
    _REPO_ROOT / "LeanAgent" / "LeanAgent" / "Agent" / "Scout"
    / "stubs" / "strategy_proposer.json"
)


CANDIDATE_TYPES = (
    "weaken_property",
    "split_cases",
    "change_representation",
    "generalize_from_evidence",
    "bridge_to_literature",
)


# ────────────────────────────────────────────────────────────────────────────
# Dataclasses
# ────────────────────────────────────────────────────────────────────────────


@dataclass
class StrategyCandidate:
    id: str
    description: str
    type: str                                          # one of CANDIDATE_TYPES
    rationale: str = ""
    estimated_tractability: float = 0.5
    requires_literature_search: bool = False
    search_queries: list[str] = field(default_factory=list)
    probe_result: Optional[dict] = None                # serialized TractabilityReport
    is_dup_of_failed: bool = False

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class StrategyProposal:
    candidates: list[StrategyCandidate] = field(default_factory=list)
    recommended_id: Optional[str] = None
    recommendation_rationale: str = ""
    ts: str = field(default_factory=lambda: _dt.datetime.now(_dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))

    def to_dict(self) -> dict:
        return {
            "candidates": [c.to_dict() for c in self.candidates],
            "recommended_id": self.recommended_id,
            "recommendation_rationale": self.recommendation_rationale,
            "ts": self.ts,
        }

    def to_json(self) -> str:
        return json.dumps(self.to_dict(), ensure_ascii=False, indent=2)


# ────────────────────────────────────────────────────────────────────────────
# Prompt + parsing
# ────────────────────────────────────────────────────────────────────────────


_PROMPT_TEMPLATE = """\
You are a math research Strategy Proposer. The current conjecture has been
falsified at the explanation level (the conjecture itself may still hold —
only the candidate property failed). Generate 3..5 candidate DIRECTIONS for
the next conjecture, drawing from these five types:

  weaken_property            — drop / relax a condition
  split_cases                — partition into structurally distinct subsets
  change_representation      — switch to another rep in the registry
  generalize_from_evidence   — extract structural pattern from CEs
  bridge_to_literature       — populate search_queries for Bridge

[current conjecture]
form     : {form}
rep_id   : {rep_id}

[falsification evidence]
{falsification_summary}

[diagnoser]
binary   : {binary}
dispatch : {dispatch}
obstacle : {obstacle_class}

[failed attempts so far]
{failed_summary}

OUTPUT JSON ONLY (no prose, no fence):

{{
  "candidates": [
    {{
      "id": "S1",
      "description": "<one-line direction>",
      "type": "<one of: weaken_property, split_cases, change_representation, generalize_from_evidence, bridge_to_literature>",
      "rationale": "<one-line why this addresses the falsification>",
      "estimated_tractability": 0.0..1.0,
      "requires_literature_search": true|false,
      "search_queries": ["...", "..."]
    }}
  ]
}}

Rules:
- 3 to 5 candidates.
- At least one of `weaken_property` or `change_representation`.
- A candidate with type `bridge_to_literature` MUST have non-empty `search_queries`.
- Do not propose a direction whose `description` is verbatim a previously failed attempt.
"""


def _build_prompt(
    *,
    current_conjecture: dict,
    falsification_evidence: dict,
    diagnoser_output: dict,
    failed_attempts: list[dict] | None,
) -> str:
    fa = failed_attempts or []
    fa_text = "(none)" if not fa else "\n".join(
        f"  - {(a.get('form') or str(a))[:120]}" for a in fa[:8]
    )
    fe_text = json.dumps(
        {k: v for k, v in falsification_evidence.items()
         if k in ("n_failing", "n_total", "structural_pattern", "axis_uniformity")},
        ensure_ascii=False,
    )
    obstacle = (diagnoser_output.get("obstacle") or {}).get("obstruction_class", "(none)")
    return _PROMPT_TEMPLATE.format(
        form=current_conjecture.get("form", ""),
        rep_id=current_conjecture.get("rep_id", "(none)"),
        falsification_summary=fe_text,
        binary=diagnoser_output.get("binary", "(unknown)"),
        dispatch=diagnoser_output.get("dispatch", "(unknown)"),
        obstacle_class=obstacle,
        failed_summary=fa_text,
    )


def _extract_json(text: str) -> dict:
    text = text.strip()
    if text.startswith("```"):
        text = re.sub(r"^```(?:json)?\s*", "", text)
        text = re.sub(r"\s*```\s*$", "", text)
    start = text.find("{")
    if start < 0:
        raise ValueError(f"no JSON object in strategy response: {text[:200]!r}")
    depth = 0
    end = -1
    for i, ch in enumerate(text[start:], start):
        if ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                end = i + 1
                break
    if end < 0:
        raise ValueError("unbalanced braces in strategy response")
    return json.loads(text[start:end])


def _parse_candidates(text: str) -> list[StrategyCandidate]:
    obj = _extract_json(text)
    if "candidates" not in obj or not isinstance(obj["candidates"], list):
        raise ValueError("strategy response missing 'candidates' list")
    out: list[StrategyCandidate] = []
    for c in obj["candidates"]:
        ctype = c.get("type", "")
        if ctype not in CANDIDATE_TYPES:
            # Skip silently — LLM occasionally invents types.
            continue
        cand = StrategyCandidate(
            id=c.get("id", f"S{len(out)+1}"),
            description=c.get("description", ""),
            type=ctype,
            rationale=c.get("rationale", ""),
            estimated_tractability=float(c.get("estimated_tractability", 0.5)),
            requires_literature_search=bool(c.get("requires_literature_search", False)),
            search_queries=list(c.get("search_queries") or []),
        )
        # Hard-rule: bridge_to_literature must have search_queries.
        if cand.type == "bridge_to_literature" and not cand.search_queries:
            cand.search_queries = [cand.description[:120]] if cand.description else ["(unspecified)"]
        out.append(cand)
    if not out:
        raise ValueError("strategy response yielded zero valid candidates")
    return out


# ────────────────────────────────────────────────────────────────────────────
# Stage 1: generate
# ────────────────────────────────────────────────────────────────────────────


def _stub_mode() -> bool:
    return os.environ.get("SCOUT_STUB") == "1"


def _make_llm() -> LLM:
    return LLM(
        provider="stub" if _stub_mode() else "auto",
        stub_path=_DEFAULT_STUB_PATH,
    )


def generate_candidates(
    *,
    current_conjecture: dict,
    falsification_evidence: dict,
    diagnoser_output: dict,
    failed_attempts: list[dict] | None = None,
    registry_context: dict | None = None,
    llm: LLM | None = None,
) -> list[StrategyCandidate]:
    """One LLM call → 3-5 strategy candidates.

    `registry_context` is currently unused by the LLM prompt directly; it
    is kept in the signature for forward-compat with cross-checking
    `change_representation` candidates against the actual registry.
    """
    prompt = _build_prompt(
        current_conjecture=current_conjecture,
        falsification_evidence=falsification_evidence,
        diagnoser_output=diagnoser_output,
        failed_attempts=failed_attempts,
    )
    if llm is None:
        llm = _make_llm()
    resp: LLMResponse = llm.ask(stage="strategy_proposer", task="generate", prompt=prompt)
    return _parse_candidates(resp.text)


# ────────────────────────────────────────────────────────────────────────────
# Stage 2: probe
# ────────────────────────────────────────────────────────────────────────────


def _candidate_to_problem(
    candidate: StrategyCandidate,
    *,
    current_conjecture: dict,
) -> dict:
    return {
        "problem_id": f"strategy_{candidate.id}",
        "goal": candidate.description,
        "domain": current_conjecture.get("domain", "meta"),
        "object_keywords": current_conjecture.get("object", "")
                           or current_conjecture.get("rep_id", ""),
    }


def probe_candidates(
    candidates: list[StrategyCandidate],
    *,
    current_conjecture: dict,
    config: ScoutConfig,
    scout_one_fn=scout_one,                            # injectable for tests
) -> list[StrategyCandidate]:
    """Run scout_one() per candidate (skipping bridge_to_literature, which
    has no probe of its own — Bridge runs in a separate stage)."""
    for c in candidates:
        if c.type == "bridge_to_literature":
            c.probe_result = None
            continue
        problem = _candidate_to_problem(c, current_conjecture=current_conjecture)
        try:
            rpt: TractabilityReport = scout_one_fn(problem, config)
            c.probe_result = rpt.to_dict() if hasattr(rpt, "to_dict") else dict(rpt)  # type: ignore
        except Exception as e:                          # never break the rank pipeline
            c.probe_result = {"error": f"{type(e).__name__}: {str(e)[:200]}"}
    return candidates


# ────────────────────────────────────────────────────────────────────────────
# Stage 3: rank + recommend
# ────────────────────────────────────────────────────────────────────────────


_DIFFICULTY_RANK = {"shallow": 0, "medium": 1, "deep": 2, "intractable": 3}


def _jaccard_token_overlap(a: str, b: str) -> float:
    ta = set(re.findall(r"[A-Za-z0-9_]+", a.lower()))
    tb = set(re.findall(r"[A-Za-z0-9_]+", b.lower()))
    if not ta or not tb:
        return 0.0
    return len(ta & tb) / len(ta | tb)


def _is_dup_of_failed(
    candidate: StrategyCandidate,
    failed_attempts: list[dict] | None,
) -> bool:
    """§F.1 deduplication."""
    if not failed_attempts:
        return False
    desc = candidate.description.lower()
    for fa in failed_attempts:
        form = (fa.get("form") or "").lower()
        if not form:
            continue
        if _jaccard_token_overlap(desc, form) >= 0.80:
            return True
        if candidate.type == "weaken_property":
            # Cheap substring check on the property keyword.
            for tok in re.findall(r"[A-Za-z][A-Za-z_]+", desc):
                if tok in form and len(tok) > 4:
                    return True
    return False


def rank_candidates(
    candidates: list[StrategyCandidate],
    *,
    failed_attempts: list[dict] | None = None,
) -> StrategyProposal:
    for c in candidates:
        c.is_dup_of_failed = _is_dup_of_failed(c, failed_attempts)

    def _key(c: StrategyCandidate) -> tuple:
        probe = c.probe_result or {}
        outcome = probe.get("scout_outcome") if isinstance(probe, dict) else None
        difficulty = probe.get("estimated_difficulty") if isinstance(probe, dict) else None
        return (
            -int(c.is_dup_of_failed),                              # demote duplicates
            outcome == "pass",                                     # primary
            -_DIFFICULTY_RANK.get(difficulty or "intractable", 99),# secondary
            c.estimated_tractability,                              # tertiary
        )

    ordered = sorted(candidates, key=_key, reverse=True)
    proposal = StrategyProposal(candidates=ordered)
    if ordered:
        top = ordered[0]
        proposal.recommended_id = top.id
        bits: list[str] = []
        if top.probe_result and isinstance(top.probe_result, dict):
            outcome = top.probe_result.get("scout_outcome")
            difficulty = top.probe_result.get("estimated_difficulty")
            if outcome:
                bits.append(f"probe={outcome}")
            if difficulty:
                bits.append(f"difficulty={difficulty}")
        bits.append(f"tractability={top.estimated_tractability:.2f}")
        if top.type == "bridge_to_literature":
            bits.append(f"bridge_queries={len(top.search_queries)}")
        proposal.recommendation_rationale = (
            f"{top.id} ({top.type}): " + ", ".join(bits)
        )
    return proposal


# ────────────────────────────────────────────────────────────────────────────
# Top-level orchestration
# ────────────────────────────────────────────────────────────────────────────


def run_strategy_proposer(
    *,
    current_conjecture: dict,
    falsification_evidence: dict,
    diagnoser_output: dict,
    failed_attempts: list[dict] | None = None,
    registry_context: dict | None = None,
    config: ScoutConfig,
    llm: LLM | None = None,
    scout_one_fn=scout_one,
) -> StrategyProposal:
    candidates = generate_candidates(
        current_conjecture=current_conjecture,
        falsification_evidence=falsification_evidence,
        diagnoser_output=diagnoser_output,
        failed_attempts=failed_attempts,
        registry_context=registry_context,
        llm=llm,
    )
    candidates = probe_candidates(
        candidates,
        current_conjecture=current_conjecture,
        config=config,
        scout_one_fn=scout_one_fn,
    )
    return rank_candidates(candidates, failed_attempts=failed_attempts)
