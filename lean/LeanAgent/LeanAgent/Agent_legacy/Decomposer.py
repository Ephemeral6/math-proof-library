"""
Stage 1 — Decomposer.

Input  : Stage 0 Blueprint + the original spec (theorem_name, theorem_nl,
         assumptions, conclusion, steps).
Output : One JSON spec per NEW lemma, written to
         `output/<run>/lemma_specs/<lemma_id>.json`. Each spec has the same
         schema as the original input spec and is fed straight into Stage
         2-5.

Decomposition strategy per NEW lemma:
  1. Try a **template match** — scan `LeanAgent/templates/<name>/template.json`
     for a `match_patterns` entry whose substring (case-insensitive) appears
     in the lemma's NL statement or `reuse_reason`. On a hit, use the
     template's `steps` verbatim.
  2. If no template hits, **harvest** the parent's structured steps that the
     Architect tagged with this lemma's id (`step_ids`). If at least one
     parent step matches, lift those into the lemma's spec — preserving id,
     description, method, uses, and any `external_theorem`.
  3. If neither template nor harvest produces steps, ask the LLM to
     decompose. Stub key: `decomposer::decompose` (wildcard). The LLM
     returns a JSON array of step objects.

Quality gates (logged, not enforced):
  * non-empty steps list
  * `method` ∈ {apply_theorem, direct_compute, contradiction, case_split,
                induction}  — anything else is normalized but flagged.
  * `uses` references resolve to earlier step ids (no forward refs, no cycles).

Stage 1 NEVER touches Lean files; it produces JSON only.
"""

from __future__ import annotations

import json
import re
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Any

from . import Utils
from .Architect import Blueprint, Lemma
from .LLM import LLM


VALID_METHODS = {
    "apply_theorem",
    "direct_compute",
    "contradiction",
    "case_split",
    "induction",
}


# --------------------------------------------------------------------------- #
# Result types
# --------------------------------------------------------------------------- #


@dataclass
class LemmaSpec:
    lemma_id: str
    theorem_name: str
    theorem_nl: str
    assumptions: list[str]
    conclusion: str
    steps: list[dict]
    source: str  # "template" / "harvest" / "llm" / "fallback"
    template_name: str | None = None
    notes: list[str] = field(default_factory=list)
    output_path: Path | None = None

    def to_spec_dict(self) -> dict:
        """Return a Stage-2-compatible spec dict (mirrors input JSON schema)."""
        return {
            "theorem_name": self.theorem_name,
            "theorem_nl": self.theorem_nl,
            "assumptions": self.assumptions,
            "conclusion": self.conclusion,
            "steps": self.steps,
            "_decomposer": {
                "lemma_id": self.lemma_id,
                "source": self.source,
                "template_name": self.template_name,
                "notes": self.notes,
            },
        }


@dataclass
class DecomposerResult:
    specs: dict[str, LemmaSpec] = field(default_factory=dict)
    history: list[dict] = field(default_factory=list)


# --------------------------------------------------------------------------- #
# Prompts
# --------------------------------------------------------------------------- #

DECOMPOSE_SYSTEM = """\
You are a mathematical proof decomposer. Given a lemma statement and a rough
proof sketch, break the proof into ATOMIC steps. Each step should correspond
to 1-3 Lean tactics — no larger.

For every step output:
  {
    "id": <int, 1-indexed>,
    "description": "<what this step does, short>",
    "method": "apply_theorem | direct_compute | contradiction | case_split | induction",
    "uses": [<earlier step ids this depends on>],
    "external_theorem": "<theorem name, or null>",
    "external_theorem_premises": "<premises required, or null>",
    "premise_verification": "<why those premises hold here, or null>"
  }

Output rules:
  * Output STRICT JSON: a top-level array of step objects, no surrounding
    object, no fences, no prose.
  * No forward references in `uses`.
  * Use `apply_theorem` whenever an external theorem is invoked; fill the
    premise + verification fields when you do.
"""

DECOMPOSE_PROMPT = """\
Lemma id: {lemma_id}
Lemma name: {lemma_name}

Statement: {statement_nl}
Assumptions:
{assumptions_block}
Conclusion: {conclusion}

Rough proof sketch (relevant steps lifted from the parent theorem):
{relevant_steps}

Decompose this lemma's proof into atomic steps (1-3 Lean tactics each).
Return STRICT JSON array.
"""


# --------------------------------------------------------------------------- #
# Helpers
# --------------------------------------------------------------------------- #

_FENCE_RE = re.compile(r"```(?:json)?\s*\n(.*?)```", re.DOTALL)


def _strip(text: str) -> str:
    m = _FENCE_RE.search(text)
    return (m.group(1).strip() if m else text.strip())


def _safe_load_array(text: str) -> list[dict] | None:
    s = _strip(text)
    try:
        v = json.loads(s)
        if isinstance(v, list):
            return v
        if isinstance(v, dict) and isinstance(v.get("steps"), list):
            return v["steps"]
    except json.JSONDecodeError:
        pass
    # Try to find an outer [...] block.
    i = s.find("[")
    j = s.rfind("]")
    if i >= 0 and j > i:
        try:
            v = json.loads(s[i : j + 1])
            if isinstance(v, list):
                return v
        except json.JSONDecodeError:
            pass
    return None


def _format_assumptions(items: list[str]) -> str:
    return "\n".join(f"  - {a}" for a in items) or "  (none)"


def _format_relevant_steps(steps: list[dict]) -> str:
    if not steps:
        return "(none — this lemma is not directly mapped to parent steps)"
    out = []
    for s in steps:
        ext = s.get("external_theorem")
        suffix = f"  [external: {ext}]" if ext else ""
        out.append(
            f"step {s.get('id')} (method={s.get('method')}){suffix}\n"
            f"    {s.get('description', '')}"
        )
    return "\n".join(out)


def _normalize_step(raw: dict, idx: int) -> dict:
    method = str(raw.get("method", "direct_compute") or "direct_compute").strip()
    if method not in VALID_METHODS:
        method = "direct_compute"
    return {
        "id": int(raw.get("id", idx) or idx),
        "description": str(raw.get("description", "")).strip(),
        "method": method,
        "uses": [int(u) for u in (raw.get("uses") or [])
                 if str(u).strip().lstrip("-").isdigit()],
        "external_theorem": raw.get("external_theorem") or None,
        "external_theorem_premises": raw.get("external_theorem_premises") or None,
        "premise_verification": raw.get("premise_verification") or None,
    }


def _validate_steps(steps: list[dict]) -> list[str]:
    """Returns a list of human-readable problems (not exceptions)."""
    issues: list[str] = []
    if not steps:
        issues.append("empty step list")
        return issues
    seen_ids: set[int] = set()
    for s in steps:
        sid = s["id"]
        if sid in seen_ids:
            issues.append(f"duplicate step id {sid}")
        seen_ids.add(sid)
        for u in s["uses"]:
            if u >= sid:
                issues.append(f"step {sid} uses {u} (forward/self ref)")
            if u not in seen_ids:
                issues.append(f"step {sid} uses unknown id {u}")
        if s["method"] not in VALID_METHODS:
            issues.append(f"step {sid} has invalid method {s['method']!r}")
    return issues


# --------------------------------------------------------------------------- #
# Template loading
# --------------------------------------------------------------------------- #


def _templates_dir() -> Path:
    return Utils.project_root() / "LeanAgent" / "templates"


def _load_templates() -> list[dict]:
    """Return list of {name, match_patterns, steps, param_slots} dicts."""
    root = _templates_dir()
    if not root.exists():
        return []
    out: list[dict] = []
    for sub in sorted(root.iterdir()):
        if not sub.is_dir():
            continue
        meta = sub / "template.json"
        if not meta.exists():
            continue
        try:
            data = json.loads(meta.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            continue
        data.setdefault("name", sub.name)
        out.append(data)
    return out


def _match_template(lemma: Lemma, templates: list[dict]) -> dict | None:
    haystack = " | ".join(
        [lemma.statement_nl, lemma.reuse_reason, lemma.name, lemma.id]
    ).lower()
    for tpl in templates:
        for pat in tpl.get("match_patterns") or []:
            if not pat:
                continue
            if str(pat).lower() in haystack:
                return tpl
    return None


# --------------------------------------------------------------------------- #
# Step harvesting from the parent spec
# --------------------------------------------------------------------------- #


def _harvest_parent_steps(lemma: Lemma, parent_steps: list[dict]) -> list[dict]:
    """Pull parent steps whose id appears in lemma.step_ids."""
    if not lemma.step_ids:
        return []
    wanted = set(lemma.step_ids)
    picked = [s for s in parent_steps if int(s.get("id", -1)) in wanted]
    if not picked:
        return []
    # Renumber to 1..N and rewrite `uses` to point to the new local indices.
    id_map = {int(s["id"]): i + 1 for i, s in enumerate(picked)}
    out: list[dict] = []
    for i, s in enumerate(picked, 1):
        new_uses = [id_map[u] for u in s.get("uses", []) if u in id_map]
        out.append(
            {
                "id": i,
                "description": s.get("description", ""),
                "method": s.get("method", "direct_compute"),
                "uses": new_uses,
                "external_theorem": s.get("external_theorem"),
                "external_theorem_premises": s.get("external_theorem_premises"),
                "premise_verification": s.get("premise_verification"),
            }
        )
    return [_normalize_step(x, i + 1) for i, x in enumerate(out)]


# --------------------------------------------------------------------------- #
# Main entry
# --------------------------------------------------------------------------- #


def run_decomposer(
    blueprint: Blueprint,
    *,
    parent_spec: dict,
    output_dir: Path,
    llm: LLM,
) -> DecomposerResult:
    output_dir = Path(output_dir)
    specs_dir = output_dir / "lemma_specs"
    specs_dir.mkdir(parents=True, exist_ok=True)

    parent_steps = list(parent_spec.get("steps") or [])
    templates = _load_templates()

    result = DecomposerResult()
    result.history.append(
        {"step": "load_templates", "count": len(templates),
         "names": [t.get("name") for t in templates]}
    )

    for lemma in blueprint.lemmas:
        if lemma.id == blueprint.main_id:
            continue
        if lemma.source != "NEW":
            result.history.append(
                {"step": "skip_lemma", "id": lemma.id, "reason": lemma.source}
            )
            continue
        spec = _decompose_one(
            lemma=lemma,
            parent_spec=parent_spec,
            parent_steps=parent_steps,
            templates=templates,
            llm=llm,
        )
        # Quality gates (log only)
        problems = _validate_steps(spec.steps)
        if problems:
            spec.notes.extend(problems)

        path = specs_dir / f"{lemma.id}.json"
        path.write_text(
            json.dumps(spec.to_spec_dict(), ensure_ascii=False, indent=2),
            encoding="utf-8",
        )
        spec.output_path = path
        result.specs[lemma.id] = spec
        result.history.append(
            {"step": "decomposed", "id": lemma.id, "source": spec.source,
             "n_steps": len(spec.steps), "issues": problems}
        )

    return result


def _decompose_one(
    *,
    lemma: Lemma,
    parent_spec: dict,
    parent_steps: list[dict],
    templates: list[dict],
    llm: LLM,
) -> LemmaSpec:
    base_kwargs = dict(
        lemma_id=lemma.id,
        theorem_name=lemma.name,
        theorem_nl=lemma.statement_nl,
        assumptions=list(lemma.assumptions_nl),
        conclusion=lemma.conclusion_nl,
    )

    # 1. template — highest priority when a known recipe matches.
    tpl = _match_template(lemma, templates)
    if tpl and isinstance(tpl.get("steps"), list) and tpl["steps"]:
        steps = [_normalize_step(s, i + 1) for i, s in enumerate(tpl["steps"])]
        return LemmaSpec(
            **base_kwargs,
            steps=steps,
            source="template",
            template_name=tpl.get("name"),
        )

    # 2. LLM decomposition — preferred for granularity (1-3 tactics/step).
    # Pass the harvested parent steps as a "rough sketch" context.
    relevant = [s for s in parent_steps if int(s.get("id", -1)) in set(lemma.step_ids)]
    prompt = DECOMPOSE_PROMPT.format(
        lemma_id=lemma.id,
        lemma_name=lemma.name,
        statement_nl=lemma.statement_nl,
        assumptions_block=_format_assumptions(lemma.assumptions_nl),
        conclusion=lemma.conclusion_nl,
        relevant_steps=_format_relevant_steps(relevant),
    )
    try:
        resp = llm.ask(
            stage="decomposer",
            task="decompose",
            prompt=prompt,
            system=DECOMPOSE_SYSTEM,
            max_tokens=2048,
        )
        arr = _safe_load_array(resp.text)
    except KeyError:
        arr = None
    if isinstance(arr, list) and arr:
        steps = [_normalize_step(s, i + 1) for i, s in enumerate(arr)]
        return LemmaSpec(**base_kwargs, steps=steps, source="llm")

    # 3. Harvest from parent — fallback when LLM is unavailable.
    harvested = _harvest_parent_steps(lemma, parent_steps)
    if harvested:
        return LemmaSpec(**base_kwargs, steps=harvested, source="harvest")

    # 4. Final fallback — single direct_compute step (keeps spec valid).
    return LemmaSpec(
        **base_kwargs,
        steps=[
            {
                "id": 1,
                "description": lemma.statement_nl
                or f"Prove {lemma.name} directly.",
                "method": "direct_compute",
                "uses": [],
                "external_theorem": None,
                "external_theorem_premises": None,
                "premise_verification": None,
            }
        ],
        source="fallback",
        notes=["decomposer fell through to single-step fallback"],
    )
