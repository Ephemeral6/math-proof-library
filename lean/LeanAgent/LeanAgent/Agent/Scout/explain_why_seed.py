"""Explain-Why seed-prompt invocation.

Spec: workspace/agents_spec/explain_why_prompt.md §A.1.

Reuses LeanAgent/LeanAgent/Agent_legacy/LLM.py for the Anthropic / stub provider.

Stub mode: when env var SCOUT_STUB=1 is set OR the LLM falls back to stub
(no ANTHROPIC_API_KEY), the prompt is not sent; a fixture JSON is returned
keyed by stage="explain_why" task="seed".
"""

from __future__ import annotations

import json
import os
import re
from pathlib import Path

# Reuse the legacy LLM facade.
from LeanAgent.LeanAgent.Agent_legacy.LLM import LLM, LLMResponse


_REPO_ROOT = Path(__file__).resolve().parents[4]
_DEFAULT_STUB_PATH = _REPO_ROOT / "LeanAgent" / "LeanAgent" / "Agent" / "Scout" / "stubs" / "explain_why_seed.json"


SEED_PROMPT_TEMPLATE = """\
You are analysing a single verified instance.

[anchor result]
On {anchor_case}, the conjecture "{conjecture}" holds.
Verifier evidence: {actual_evidence}
Current representation: {rep_id}.
Known failed forms in this representation's history:
  {failed_attempts}

[step 1 — enumerate candidate properties]
List >= 3 candidate properties P_i, each of the shape "{anchor_case} has
specific feature F_i which is sufficient to imply {conjecture}". Be
concrete: name the feature in the verifier-readable language (vertex count,
edge density, intersection-number bound, eigenvalue magnitude, etc.), not
a generic descriptor.

For each P_i, also record:
  - is_strictly_stronger_than_conjecture: bool
  - depends_on_anchor_size: bool
  - rooted_in_representation_choice: bool

[step 2 — predict on the next instance]
The next instance to be verified is {next_case}. For each P_i, predict:
  (a) does P_i still hold on {next_case}? (yes / no / partial / unknown)
  (b) if P_i holds, does {conjecture} still hold? (yes / no / unclear)
  (c) if you predicted P_i fails: give a plausible structural counterexample.

[step 3 — rank by informativeness]
Rank P_1, ..., P_n by: "if P_i fails on {next_case} but {conjecture} still
holds, how much do we learn about why {conjecture} actually holds?"

The top-ranked P_i becomes the candidate WH. Output JSON ONLY (no prose):

{{
  "candidate_properties": [
    {{ "id": "P1", "feature": "...", "is_strictly_stronger": false,
       "depends_on_anchor_size": true, "rooted_in_rep_choice": false,
       "prediction_on_next": "no",
       "prediction_rationale": "...",
       "informativeness_rank": 1 }}
  ],
  "top_ranked_id": "P1",
  "wh_seed": {{
    "claim": "<one-line statement combining the top P_i with the conjecture>",
    "candidate_property": "<P_i.feature verbatim>"
  }}
}}
"""


def build_seed_prompt(
    *,
    conjecture: str,
    actual_evidence: str,
    rep_id: str,
    anchor_case: str,
    next_case: str = "(none — scout has only 1 step)",
    failed_attempts: list | None = None,
) -> str:
    fa_summary = "(none)"
    if failed_attempts:
        fa_summary = "; ".join(
            (fa.get("form", "") if isinstance(fa, dict) else str(fa))[:120]
            for fa in failed_attempts
        )
    return SEED_PROMPT_TEMPLATE.format(
        anchor_case=anchor_case,
        conjecture=conjecture,
        actual_evidence=actual_evidence,
        rep_id=rep_id,
        next_case=next_case,
        failed_attempts=fa_summary,
    )


def _extract_json(text: str) -> dict:
    """Robustly extract a JSON object from LLM text. Looks for the first
    balanced top-level { ... } and parses it. Raises on malformed."""
    text = text.strip()
    if text.startswith("```"):
        # Strip code-fence markers.
        text = re.sub(r"^```(?:json)?\s*", "", text)
        text = re.sub(r"\s*```\s*$", "", text)
    # Find the first '{' and the matching closing brace.
    start = text.find("{")
    if start < 0:
        raise ValueError(f"no JSON object found in response: {text[:200]!r}")
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
        raise ValueError("unbalanced braces in response")
    return json.loads(text[start:end])


def parse_seed_response(text: str) -> dict:
    """Parse the LLM output into the seed-JSON schema. Validates required keys."""
    obj = _extract_json(text)
    if "wh_seed" not in obj:
        raise ValueError("seed response missing 'wh_seed'")
    wh_seed = obj["wh_seed"]
    if not isinstance(wh_seed, dict):
        raise ValueError("'wh_seed' is not an object")
    if "claim" not in wh_seed or "candidate_property" not in wh_seed:
        raise ValueError("seed response missing 'wh_seed.claim' or 'wh_seed.candidate_property'")
    obj.setdefault("candidate_properties", [])
    obj.setdefault("top_ranked_id", None)
    return obj


def _stub_mode() -> bool:
    return os.environ.get("SCOUT_STUB") == "1"


def _make_llm(stub_path: Path | None = None) -> LLM:
    if _stub_mode():
        provider = "stub"
    else:
        provider = "auto"
    sp = stub_path or _DEFAULT_STUB_PATH
    return LLM(provider=provider, stub_path=sp)


def run_seed(
    *,
    conjecture: str,
    actual_evidence: str,
    rep_id: str,
    anchor_case: str,
    next_case: str = "(none — scout has only 1 step)",
    failed_attempts: list | None = None,
    llm: LLM | None = None,
) -> dict:
    """Build prompt → call LLM → parse. Returns the seed JSON dict."""
    prompt = build_seed_prompt(
        conjecture=conjecture,
        actual_evidence=actual_evidence,
        rep_id=rep_id,
        anchor_case=anchor_case,
        next_case=next_case,
        failed_attempts=failed_attempts,
    )
    if llm is None:
        llm = _make_llm()
    resp: LLMResponse = llm.ask(stage="explain_why", task="seed", prompt=prompt)
    return parse_seed_response(resp.text)
