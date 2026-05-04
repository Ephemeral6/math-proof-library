"""Scope Judge — distinguishes real falsification from scope limitation.

Spec: workspace/agents_spec/scope_judge.md.

Four-signal aggregation + optional LLM tiebreaker:
  signals = (boundary, structure, severity, scope_score)
  scope_score = 0.3 * boundary + 0.3 * structure + 0.4 * severity
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


_REPO_ROOT = Path(__file__).resolve().parents[4]
_DEFAULT_STUB_PATH = (
    _REPO_ROOT / "LeanAgent" / "LeanAgent" / "Agent" / "Scout"
    / "stubs" / "scope_judge.json"
)


# ────────────────────────────────────────────────────────────────────────────
# Dataclasses
# ────────────────────────────────────────────────────────────────────────────


@dataclass
class Workaround:
    exists: bool
    description: str = ""
    cost: str = "medium"                              # "low" | "medium" | "high"


@dataclass
class ScopeSignals:
    boundary: float = 0.0
    structure: float = 0.0
    severity: float = 0.0
    scope_score: float = 0.0


@dataclass
class ScopeVerdict:
    verdict: str                                      # "falsification" | "scope_limitation" | "uncertain"
    confidence: float
    rationale: str
    affected_scope: str
    unaffected_scope: str
    workaround: Workaround
    recommendation: str                               # "continue_with_scope_caveat" | "abandon" | "human_review"
    signals: ScopeSignals = field(default_factory=ScopeSignals)
    ts: str = field(default_factory=lambda: _dt.datetime.now(_dt.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))

    def to_dict(self) -> dict:
        d = asdict(self)
        return d


# ────────────────────────────────────────────────────────────────────────────
# Signal 1 — parameter boundary (§E.1)
# ────────────────────────────────────────────────────────────────────────────


def check_parameter_boundary(
    failing_instance: dict,
    passing_instances: list[dict],
) -> float:
    """Returns 0..1: fraction of numeric params on which the failing
    instance lies *outside* the passing-instance range."""
    fparams = failing_instance.get("params") or {}
    if not fparams:
        return 0.0
    numeric_keys = [k for k, v in fparams.items() if isinstance(v, (int, float))]
    if not numeric_keys:
        return 0.0
    pass_params = [pi.get("params", {}) for pi in passing_instances]
    if not pass_params:
        return 0.0
    outside_count = 0
    counted = 0
    for k in numeric_keys:
        vals = [p[k] for p in pass_params if k in p and isinstance(p[k], (int, float))]
        if not vals:
            continue
        counted += 1
        v = fparams[k]
        if v > max(vals) or v < min(vals):
            outside_count += 1
    if counted == 0:
        return 0.0
    return outside_count / counted


# ────────────────────────────────────────────────────────────────────────────
# Signal 2 — structural consistency (§E.2)
# ────────────────────────────────────────────────────────────────────────────


def check_structural_consistency(
    failing_evidence: dict,
    passing_evidence: list[str] | list[dict],
) -> float:
    """Higher → failing pattern is novel → more likely scope_limitation."""
    pattern = (failing_evidence.get("structural_pattern") or "").strip()
    if not pattern:
        return 0.5
    blob_parts: list[str] = []
    for pe in passing_evidence:
        if isinstance(pe, str):
            blob_parts.append(pe)
        elif isinstance(pe, dict):
            blob_parts.append(str(pe.get("actual_evidence", "")))
            blob_parts.append(str(pe.get("structural_pattern", "")))
    blob = " ".join(blob_parts).lower()
    pl = pattern.lower()
    if pl in blob:
        return 0.3                                    # pattern was already seen → falsification-leaning
    # Token-level partial overlap: penalise high overlap.
    pat_tokens = set(re.findall(r"[A-Za-z0-9_]+", pl))
    blob_tokens = set(re.findall(r"[A-Za-z0-9_]+", blob))
    if not pat_tokens:
        return 0.5
    overlap = len(pat_tokens & blob_tokens) / len(pat_tokens)
    if overlap > 0.7:
        return 0.4
    return 1.0 - 0.3 * overlap                       # most tokens novel → strong scope signal


# ────────────────────────────────────────────────────────────────────────────
# Signal 3 — failure severity (§E.3)
# ────────────────────────────────────────────────────────────────────────────


def check_failure_severity(n_failing: int, n_total: int) -> float:
    """Lower failure ratio → higher scope-limitation signal.
    < 10% fail → ~1.0; 50%+ fail → 0.0."""
    if n_total <= 0:
        return 0.0
    ratio = n_failing / n_total
    return max(0.0, 1.0 - min(ratio / 0.5, 1.0))


# ────────────────────────────────────────────────────────────────────────────
# Signal 4 — proof-dependency check + workaround search (§E.4)
# ────────────────────────────────────────────────────────────────────────────


def _stub_mode() -> bool:
    return os.environ.get("SCOUT_STUB") == "1"


def _make_llm() -> LLM:
    return LLM(provider="stub" if _stub_mode() else "auto", stub_path=_DEFAULT_STUB_PATH)


_WORKAROUND_PROMPT = """\
You are a math research Scope Judge. Determine whether a structural failure
on one instance of a conjecture has a *workaround* — an alternative proof
path that bypasses the failing assumption.

[conjecture]
{conjecture_form}

[failing instance]
{failing_instance_text}

[failing evidence]
{failing_evidence_text}

[proof dependency graph]
{deps_text}

OUTPUT JSON ONLY:

{{
  "exists"     : true|false,
  "description": "<one-line description, or empty>",
  "cost"       : "low"|"medium"|"high"
}}
"""


def _extract_json(text: str) -> dict:
    text = text.strip()
    if text.startswith("```"):
        text = re.sub(r"^```(?:json)?\s*", "", text)
        text = re.sub(r"\s*```\s*$", "", text)
    start = text.find("{")
    if start < 0:
        raise ValueError(f"no JSON in scope_judge response: {text[:200]!r}")
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
        raise ValueError("unbalanced braces in scope_judge response")
    return json.loads(text[start:end])


def check_proof_dependency(
    *,
    conjecture: dict,
    failing_instance: dict,
    falsification_evidence: dict,
    proof_deps: dict | None,
    llm: LLM | None = None,
) -> Workaround:
    """1 LLM call to identify workaround (skipped if no proof_deps)."""
    if not proof_deps:
        return Workaround(exists=False, description="", cost="medium")
    if llm is None:
        llm = _make_llm()
    prompt = _WORKAROUND_PROMPT.format(
        conjecture_form=conjecture.get("form", ""),
        failing_instance_text=failing_instance.get("instance", ""),
        failing_evidence_text=falsification_evidence.get("structural_pattern", ""),
        deps_text=json.dumps(proof_deps, ensure_ascii=False)[:1000],
    )
    try:
        resp: LLMResponse = llm.ask(stage="scope_judge", task="workaround", prompt=prompt)
        obj = _extract_json(resp.text)
        return Workaround(
            exists=bool(obj.get("exists", False)),
            description=str(obj.get("description", "")),
            cost=str(obj.get("cost", "medium")),
        )
    except Exception:
        return Workaround(exists=False, description="(workaround LLM call failed)", cost="medium")


# ────────────────────────────────────────────────────────────────────────────
# LLM tiebreaker for ambiguous middle band (§E.5)
# ────────────────────────────────────────────────────────────────────────────


_TIEBREAK_PROMPT = """\
You are a math research Scope Judge. Four signals on a failing instance of
a conjecture have produced an ambiguous score. Make a final call.

[signals]
boundary  : {boundary:.2f}     (1.0 → failing instance outside passing range)
structure : {structure:.2f}     (1.0 → failing pattern absent from passing)
severity  : {severity:.2f}     (1.0 → low failure ratio)
score     : {score:.2f}     (weighted sum; 0.7+ scope_limitation, 0.3- falsification)
workaround_exists : {workaround_exists}

[conjecture]
{conjecture_form}

[failing instance]
{failing_instance}

[failing evidence]
{failing_evidence}

OUTPUT JSON ONLY:

{{
  "verdict"   : "falsification" | "scope_limitation" | "uncertain",
  "confidence": 0.0..1.0,
  "rationale" : "<one-line reasoning>"
}}
"""


def llm_scope_tiebreak(
    *,
    conjecture: dict,
    failing_instance: dict,
    falsification_evidence: dict,
    signals: ScopeSignals,
    workaround: Workaround,
    llm: LLM | None = None,
) -> tuple[str, float, str]:
    if llm is None:
        llm = _make_llm()
    prompt = _TIEBREAK_PROMPT.format(
        boundary=signals.boundary,
        structure=signals.structure,
        severity=signals.severity,
        score=signals.scope_score,
        workaround_exists=str(workaround.exists).lower(),
        conjecture_form=conjecture.get("form", ""),
        failing_instance=failing_instance.get("instance", ""),
        failing_evidence=falsification_evidence.get("structural_pattern", "")[:300],
    )
    try:
        resp: LLMResponse = llm.ask(stage="scope_judge", task="tiebreak", prompt=prompt)
        obj = _extract_json(resp.text)
        v = obj.get("verdict", "uncertain")
        if v not in ("falsification", "scope_limitation", "uncertain"):
            v = "uncertain"
        return v, float(obj.get("confidence", 0.5)), str(obj.get("rationale", ""))
    except Exception as e:
        return "uncertain", 0.5, f"(tiebreak LLM failed: {type(e).__name__})"


# ────────────────────────────────────────────────────────────────────────────
# Top-level
# ────────────────────────────────────────────────────────────────────────────


def has_prior_passes(state: Any) -> bool:
    """True iff the State's current_conjecture has at least one prior
    plan-step that returned `actual_outcome = "pass"`. Caller may pass
    a TrackerState or a dict with the same shape."""
    cc = getattr(state, "current_conjecture", None) or (state or {}).get("current_conjecture")
    if cc is None:
        return False
    plan = getattr(cc, "test_plan", None) or (cc or {}).get("test_plan")
    if not plan:
        return False
    steps = plan.get("steps") if isinstance(plan, dict) else getattr(plan, "steps", [])
    if not steps:
        return False
    for s in steps:
        if isinstance(s, dict) and s.get("actual_outcome") == "pass":
            return True
        if hasattr(s, "actual_outcome") and getattr(s, "actual_outcome") == "pass":
            return True
    return False


def run_scope_judge(
    *,
    conjecture: dict,
    passing_instances: list[dict],
    failing_instance: dict,
    falsification_evidence: dict,
    proof_deps: dict | None = None,
    llm: LLM | None = None,
) -> ScopeVerdict:
    """Combine the four signals + optional LLM tiebreak into a verdict."""
    boundary = check_parameter_boundary(failing_instance, passing_instances)
    passing_evidence = [pi for pi in passing_instances]
    structure = check_structural_consistency(falsification_evidence, passing_evidence)
    n_fail = int(falsification_evidence.get("n_failing", 0))
    n_total = int(falsification_evidence.get("n_total", max(n_fail, 1)))
    severity = check_failure_severity(n_fail, n_total)
    scope_score = 0.3 * boundary + 0.3 * structure + 0.4 * severity

    workaround = check_proof_dependency(
        conjecture=conjecture,
        failing_instance=failing_instance,
        falsification_evidence=falsification_evidence,
        proof_deps=proof_deps,
        llm=llm,
    )

    signals = ScopeSignals(
        boundary=boundary, structure=structure, severity=severity,
        scope_score=scope_score,
    )

    affected = failing_instance.get("instance", "<unknown>")
    unaffected = ", ".join(
        pi.get("instance", "?") for pi in passing_instances[:5]
    ) or "<none recorded>"

    if scope_score >= 0.7 and workaround.exists:
        verdict = "scope_limitation"
        confidence = scope_score
        rationale = (
            f"scope_score={scope_score:.2f} ≥ 0.7 with workaround. "
            f"signals: boundary={boundary:.2f}, structure={structure:.2f}, "
            f"severity={severity:.2f}."
        )
        recommendation = "continue_with_scope_caveat"
    elif scope_score <= 0.3:
        verdict = "falsification"
        confidence = 1.0 - scope_score
        rationale = (
            f"scope_score={scope_score:.2f} ≤ 0.3 — failure mode shared "
            f"with passing region. signals: boundary={boundary:.2f}, "
            f"structure={structure:.2f}, severity={severity:.2f}."
        )
        recommendation = "abandon"
    else:
        # Tiebreak via LLM.
        v, c, r = llm_scope_tiebreak(
            conjecture=conjecture,
            failing_instance=failing_instance,
            falsification_evidence=falsification_evidence,
            signals=signals,
            workaround=workaround,
            llm=llm,
        )
        verdict = v
        confidence = c
        rationale = r or f"LLM tiebreak at scope_score={scope_score:.2f}"
        if confidence < 0.6 or v == "uncertain":
            recommendation = "human_review"
            verdict = "uncertain" if confidence < 0.6 else verdict
        elif v == "scope_limitation":
            recommendation = "continue_with_scope_caveat"
        else:
            recommendation = "abandon"

    return ScopeVerdict(
        verdict=verdict,
        confidence=confidence,
        rationale=rationale,
        affected_scope=affected,
        unaffected_scope=unaffected,
        workaround=workaround,
        recommendation=recommendation,
        signals=signals,
    )
