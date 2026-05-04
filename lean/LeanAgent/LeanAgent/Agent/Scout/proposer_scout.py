"""Proposer (scout variant) — produces (conjecture, 1-step test_plan, WH-1 seed).

Spec: workspace/agents_spec/scout_mode.md §C — Proposer emits a test_plan
capped at max_steps=1 and an initial WH-1 seed (or, more precisely, the
seed prompt fires after Verifier; the Proposer's job is just the
conjecture + 1-step plan).

This module is the *Proposer-side* call. The seed prompt itself fires
later (explain_why_seed.py); they are decoupled.
"""

from __future__ import annotations

import json
import os
import re
from pathlib import Path

from LeanAgent.LeanAgent.Agent_legacy.LLM import LLM, LLMResponse


_REPO_ROOT = Path(__file__).resolve().parents[4]
_DEFAULT_STUB_PATH = _REPO_ROOT / "LeanAgent" / "LeanAgent" / "Agent" / "Scout" / "stubs" / "proposer_scout.json"


PROPOSER_PROMPT_TEMPLATE = """\
You are a math research Proposer in SCOUT mode. Your output gates a
1-step tractability probe of an open problem. Be conservative with claims;
the goal is to start with the SMALLEST instance that is informative.

[problem statement]
{goal}

[available representations]
Preferred starting rep: {rep_id}.
Domain: {domain}. Object keywords: {object_keywords}.

[literature in scope]
{literature}

[your task]
Emit a JSON object with three top-level fields:

1. "conjecture": a single sentence stating the testable claim. Must be
   strictly weaker than or equal to the problem statement (no new
   assumptions). Include `object` (short keyword) and `domain` (one of
   optimization, convex_analysis, geometric_topology, combinatorial_topology,
   learning_theory, statistics, linear_algebra, probability, meta).

2. "test_plan": EXACTLY 1 step (scout cap). Each step has:
     - step (int, 1)
     - instance (NL identifier of the smallest informative case)
     - complexity (float, 0..1; arbitrary on the smallest case, e.g. 0.05)
     - complexity_rationale (one sentence)
     - predicted_outcome ∈ {{pass, fail, mixed, unknown}}
     - verifier_command: a string (CLI) OR
                         a dict {{kind: python_cli, argv: [...]}} OR
                         a dict {{kind: lean_compile, path: "..."}} OR
                         a dict {{kind: engine_call, engine, op, kwargs}}.

3. "object_for_rep_select": short keyword for the Rep Selector's `object`
   parameter (used downstream).

Output JSON ONLY (no prose, no code fence):

{{
  "conjecture": {{"form": "...", "object": "...", "domain": "..."}},
  "test_plan": {{"max_steps": 1, "steps": [ {{...}} ]}},
  "object_for_rep_select": "..."
}}
"""


def build_proposer_prompt(
    *,
    goal: str,
    rep_id: str,
    domain: str,
    object_keywords: str = "",
    literature_in_scope: list | None = None,
) -> str:
    lit = "(none provided)"
    if literature_in_scope:
        lit = "\n  - " + "\n  - ".join(
            (l.get("title") if isinstance(l, dict) else str(l))
            for l in literature_in_scope
        )
    return PROPOSER_PROMPT_TEMPLATE.format(
        goal=goal,
        rep_id=rep_id or "(none — Rep Selector will pick after Proposer emission)",
        domain=domain,
        object_keywords=object_keywords or "(unspecified)",
        literature=lit,
    )


def _extract_json(text: str) -> dict:
    text = text.strip()
    if text.startswith("```"):
        text = re.sub(r"^```(?:json)?\s*", "", text)
        text = re.sub(r"\s*```\s*$", "", text)
    start = text.find("{")
    if start < 0:
        raise ValueError(f"no JSON found in proposer response: {text[:200]!r}")
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
        raise ValueError("unbalanced braces in proposer response")
    return json.loads(text[start:end])


def parse_proposer_response(text: str) -> dict:
    obj = _extract_json(text)
    if "conjecture" not in obj:
        raise ValueError("proposer response missing 'conjecture'")
    if "test_plan" not in obj:
        raise ValueError("proposer response missing 'test_plan'")
    obj.setdefault("object_for_rep_select", "")
    return obj


def validate_scout_output(output: dict) -> bool:
    """Per scout_mode.md §I rule 4 — test_plan must have exactly 1 step."""
    plan = output.get("test_plan") or {}
    steps = plan.get("steps") or []
    if len(steps) != 1:
        raise ValueError(
            f"scout proposer: test_plan length {len(steps)} != 1 (scout caps at 1 step)"
        )
    s = steps[0]
    if s.get("step") != 1:
        raise ValueError(f"scout proposer: step.step={s.get('step')!r}, expected 1")
    if "instance" not in s or "verifier_command" not in s:
        raise ValueError("scout proposer: step missing 'instance' or 'verifier_command'")
    return True


def _stub_mode() -> bool:
    return os.environ.get("SCOUT_STUB") == "1"


def _make_llm(stub_path: Path | None = None) -> LLM:
    provider = "stub" if _stub_mode() else "auto"
    sp = stub_path or _DEFAULT_STUB_PATH
    return LLM(provider=provider, stub_path=sp)


def run_proposer_scout(
    *,
    goal: str,
    rep_id: str = "",
    domain: str = "meta",
    object_keywords: str = "",
    literature_in_scope: list | None = None,
    llm: LLM | None = None,
) -> dict:
    """Build prompt → call LLM → parse → validate scout cap. Returns dict
    with keys (conjecture, test_plan, object_for_rep_select)."""
    prompt = build_proposer_prompt(
        goal=goal,
        rep_id=rep_id,
        domain=domain,
        object_keywords=object_keywords,
        literature_in_scope=literature_in_scope,
    )
    if llm is None:
        llm = _make_llm()
    resp: LLMResponse = llm.ask(stage="proposer_scout", task="emit", prompt=prompt)
    obj = parse_proposer_response(resp.text)
    validate_scout_output(obj)
    return obj
