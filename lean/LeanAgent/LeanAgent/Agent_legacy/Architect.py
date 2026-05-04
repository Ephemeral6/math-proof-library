"""
Stage 0 — Architect.

Input  : JSON spec (theorem_name, theorem_nl, assumptions, conclusion, steps).
Output : Blueprint dataclass + blueprint.json with
           * lemma list (id, NL statement, source = NEW | MATHLIB | REGISTRY,
                         reuse potential, abstraction level, ...)
           * dependency DAG
           * topological build order
           * parallel layers
           * file-structure plan (one Lean file per NEW lemma + Main.lean)

Pipeline:
  1. Ask the LLM to decompose the structured proof into a small set of
     reusable auxiliary lemmas plus the main theorem. Each candidate
     comes with NL statement, assumptions, dependencies, Mathlib name
     guesses, and a reuse-potential assessment.
  2. Probe Mathlib for each guessed name by writing
     `output_dir / .architect_probe.lean` with a single
     `import Mathlib` + `#check @<name>` per candidate, then running
     `lake env lean`. Names that resolve are stamped MATHLIB; the rest stay
     NEW. Probing is automatically skipped in stub mode.
  3. Build the lemma DAG, topologically sort with Kahn's algorithm
     (parallel layers = nodes ready in the same round), and lay out the
     file structure under `LeanAgent/Generated/<TheoremName>/`.
  4. Write blueprint.json into the output directory and return the
     in-memory Blueprint.

Stage 0 NEVER edits files in `LeanAgent/Generated/`; it only writes
`output/.../blueprint.json` and the temp Mathlib-probe file.

Stub keys (in Tests/stubs/<theorem>.json):
  architect::extract_lemmas    -- canned JSON decomposition (required)
  architect::reuse_<lemma_id>  -- per-lemma reuse override (optional)
  architect::reuse_any         -- fallback reuse blob       (optional)
"""

from __future__ import annotations

import json
import re
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Iterable

from . import Utils
from .LLM import LLM


# --------------------------------------------------------------------------- #
# Result types
# --------------------------------------------------------------------------- #


@dataclass
class Lemma:
    id: str
    name: str
    statement_nl: str = ""
    assumptions_nl: list[str] = field(default_factory=list)
    conclusion_nl: str = ""
    source: str = "NEW"  # NEW | MATHLIB | REGISTRY
    mathlib_name: str | None = None
    mathlib_candidates: list[str] = field(default_factory=list)
    depends_on: list[str] = field(default_factory=list)
    reuse_potential: str = "medium"
    reuse_reason: str = ""
    abstraction_level: str = ""
    minimal_assumptions: bool = True
    estimated_difficulty: str = "medium"
    step_ids: list[int] = field(default_factory=list)


@dataclass
class Blueprint:
    theorem_name: str
    main_id: str
    lemmas: list[Lemma]
    dag: dict[str, list[str]]
    build_order: list[str]
    parallel_groups: list[list[str]]
    file_structure: dict[str, str]  # path -> lemma_id
    history: list[dict] = field(default_factory=list)
    probe: dict[str, bool] = field(default_factory=dict)

    def to_json(self) -> dict:
        return {
            "theorem_name": self.theorem_name,
            "main_id": self.main_id,
            "lemmas": [asdict(l) for l in self.lemmas],
            "dag": self.dag,
            "build_order": self.build_order,
            "parallel_groups": self.parallel_groups,
            "file_structure": self.file_structure,
            "probe": self.probe,
            "history": self.history,
        }


# --------------------------------------------------------------------------- #
# Prompts
# --------------------------------------------------------------------------- #

EXTRACT_SYSTEM = """\
You are a Lean 4 / Mathlib expert AND a research mathematician. Given a
structured natural-language proof, decompose it into a SMALL set of reusable
auxiliary lemmas plus the main theorem.

Design principles:
  * MINIMAL ASSUMPTIONS: each lemma should make the weakest hypothesis that
    still supports its conclusion. If a step only needs Lipschitz gradient,
    do not require convexity even if the surrounding proof is convex.
  * MAXIMAL ABSTRACTION: prefer typeclass-level statements (e.g.
    `InnerProductSpace ℝ E`) over concrete spaces (ℝⁿ).
  * Recognize textbook facts (FTC, Cauchy-Schwarz, ...) — propose Mathlib
    name guesses for them in `mathlib_candidates`. Do NOT carve them out as
    NEW lemmas — they should be linked to Mathlib at the import level.
  * Do NOT turn every proof step into its own lemma. Merge trivial
    computations into the main proof body. A lemma is justified only if it
    is either reused, non-trivial, or genuinely independent.

Output format: STRICT JSON, no prose, no code fences. Schema:

{
  "lemmas": [
    {
      "id": "lem_<short_snake_case>",
      "name": "<snake_case_name>",
      "statement_nl": "...",
      "assumptions_nl": ["..."],
      "conclusion_nl": "...",
      "depends_on": ["lem_..."],
      "mathlib_candidates": ["<MathlibFullyQualifiedName>", ...],
      "reuse_potential": "high" | "medium" | "low",
      "reuse_reason": "...",
      "abstraction_level": "<typeclass-level description>",
      "minimal_assumptions": true,
      "estimated_difficulty": "trivial" | "easy" | "medium" | "hard",
      "step_ids": [<int>, ...]
    }
  ],
  "main": {
    "id": "main",
    "name": "<theorem_name>",
    "depends_on": ["lem_...", "..."]
  }
}
"""

EXTRACT_PROMPT = """\
Theorem name: {theorem_name}

Theorem (NL): {theorem_nl}

Assumptions:
{assumptions_block}

Conclusion: {conclusion}

Structured proof steps:
{steps_block}

Decompose into auxiliary lemmas + main theorem. Return STRICT JSON only.
"""


# --------------------------------------------------------------------------- #
# JSON / formatting helpers
# --------------------------------------------------------------------------- #

_FENCE_RE = re.compile(r"```(?:json)?\s*\n(.*?)```", re.DOTALL)


def _strip_json(text: str) -> str:
    m = _FENCE_RE.search(text)
    if m:
        return m.group(1).strip()
    return text.strip()


def _safe_json_loads(text: str) -> dict | None:
    """Best-effort JSON parse. Tolerates fences and trailing prose."""
    s = _strip_json(text)
    try:
        return json.loads(s)
    except json.JSONDecodeError:
        i = s.find("{")
        j = s.rfind("}")
        if i >= 0 and j > i:
            try:
                return json.loads(s[i : j + 1])
            except json.JSONDecodeError:
                return None
    return None


def _format_assumptions(assumptions: list[str]) -> str:
    return "\n".join(f"  - {a}" for a in assumptions) or "  (none)"


def _format_steps(steps: list[dict]) -> str:
    out = []
    for s in steps:
        ext = s.get("external_theorem")
        ext_str = f"  [external: {ext}]" if ext else ""
        uses = ", ".join(str(u) for u in s.get("uses", [])) or "—"
        out.append(
            f"step {s.get('id')} (method={s.get('method')}, uses={uses}){ext_str}\n"
            f"    {s.get('description', '')}"
        )
    return "\n".join(out) if out else "(no structured steps)"


def _camelize(s: str) -> str:
    parts = re.split(r"[_\-\s]+", s.strip())
    return "".join(p[:1].upper() + p[1:] for p in parts if p)


# --------------------------------------------------------------------------- #
# Mathlib probe
# --------------------------------------------------------------------------- #

PROBE_HEADER = "import Mathlib\n\n"


def _normalize_name(name: str) -> str:
    return name.strip().lstrip("@").strip()


def probe_mathlib_names(
    names: Iterable[str], *, output_dir: Path, timeout: int = 600
) -> dict[str, bool]:
    """Run `lake env lean` on a probe file with `#check @<name>` per candidate.

    Returns {original_name -> True if Mathlib resolves it}. If the probe
    fails for a non-name reason (import error, timeout), every candidate is
    reported False — we never claim Mathlib has something we couldn't
    actually verify.
    """
    cleaned = list(dict.fromkeys(_normalize_name(n) for n in names if n.strip()))
    if not cleaned:
        return {}

    body_lines = [PROBE_HEADER]
    for n in cleaned:
        body_lines.append(f"#check @{n}\n")
    probe_file = Path(output_dir) / ".architect_probe.lean"
    probe_file.parent.mkdir(parents=True, exist_ok=True)
    Utils.write_text(probe_file, "".join(body_lines))

    res = Utils.compile_lean(probe_file, timeout=timeout)

    failed: set[str] = set()
    name_pat = re.compile(r"unknown (?:identifier|constant)\s+['`]([^'`]+)['`]")
    for err in res.errors + res.warnings:
        for m in name_pat.finditer(err.get("message", "")):
            failed.add(m.group(1))

    # If the probe blew up entirely (e.g. import Mathlib failed), the only
    # errors won't match name_pat — be conservative and mark everything False.
    structural_failure = (not res.success) and not failed
    if structural_failure:
        return {n: False for n in cleaned}
    return {n: (n not in failed) for n in cleaned}


# --------------------------------------------------------------------------- #
# DAG / topological sort
# --------------------------------------------------------------------------- #


def _topological_layers(
    dag: dict[str, list[str]],
) -> tuple[list[str], list[list[str]]]:
    """Kahn's algorithm with parallel layers (nodes ready in same round)."""
    indeg: dict[str, int] = {n: 0 for n in dag}
    rev: dict[str, list[str]] = {n: [] for n in dag}
    for n, deps in dag.items():
        for d in deps:
            if d not in indeg:
                indeg[d] = 0
                rev[d] = []
            indeg[n] = indeg.get(n, 0) + 1
            rev[d].append(n)

    order: list[str] = []
    layers: list[list[str]] = []
    ready = sorted([n for n, d in indeg.items() if d == 0])
    while ready:
        layers.append(list(ready))
        order.extend(ready)
        nxt: list[str] = []
        for n in ready:
            for m in rev.get(n, []):
                indeg[m] -= 1
                if indeg[m] == 0:
                    nxt.append(m)
        ready = sorted(nxt)
    if len(order) != len(dag):
        # cycle detected; surface remaining nodes as a final degenerate layer
        missing = [n for n in dag if n not in order]
        layers.append(missing)
        order.extend(missing)
    return order, layers


# --------------------------------------------------------------------------- #
# Lemma construction helpers
# --------------------------------------------------------------------------- #


def _coerce_lemma(raw: dict, fallback_idx: int) -> Lemma:
    lid = str(raw.get("id") or raw.get("name") or f"lem_{fallback_idx}")
    name = str(raw.get("name") or raw.get("id") or f"lem_{fallback_idx}")
    return Lemma(
        id=lid,
        name=name,
        statement_nl=str(raw.get("statement_nl", "")),
        assumptions_nl=[str(x) for x in (raw.get("assumptions_nl") or [])],
        conclusion_nl=str(raw.get("conclusion_nl", "")),
        depends_on=[str(x) for x in (raw.get("depends_on") or [])],
        mathlib_candidates=[str(x) for x in (raw.get("mathlib_candidates") or [])],
        reuse_potential=str(raw.get("reuse_potential", "medium")),
        reuse_reason=str(raw.get("reuse_reason", "")),
        abstraction_level=str(raw.get("abstraction_level", "")),
        minimal_assumptions=bool(raw.get("minimal_assumptions", True)),
        estimated_difficulty=str(raw.get("estimated_difficulty", "medium")),
        step_ids=[int(x) for x in (raw.get("step_ids") or []) if str(x).strip().lstrip("-").isdigit()],
    )


def _fallback_blueprint(spec: dict, history: list[dict]) -> Blueprint:
    theorem_name = spec["theorem_name"]
    main_id = "main"
    main_lemma = Lemma(
        id=main_id,
        name=theorem_name,
        statement_nl=spec.get("theorem_nl", ""),
        assumptions_nl=list(spec.get("assumptions", []) or []),
        conclusion_nl=spec.get("conclusion", ""),
        source="NEW",
        reuse_potential="high",
        reuse_reason="the main theorem itself (architect fallback — no decomposition available)",
    )
    base = f"LeanAgent/Generated/{_camelize(theorem_name)}"
    return Blueprint(
        theorem_name=theorem_name,
        main_id=main_id,
        lemmas=[main_lemma],
        dag={main_id: []},
        build_order=[main_id],
        parallel_groups=[[main_id]],
        file_structure={f"{base}/Main.lean": main_id},
        history=history,
    )


# --------------------------------------------------------------------------- #
# Main entry
# --------------------------------------------------------------------------- #


def run_architect(
    spec: dict,
    *,
    output_dir: Path,
    llm: LLM,
    probe_mathlib: bool | None = None,
    probe_timeout: int = 600,
) -> Blueprint:
    """Run Stage 0. Writes blueprint.json into output_dir."""
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    history: list[dict] = []

    if probe_mathlib is None:
        # Default: probe in real-LLM mode, skip in stub mode (offline tests).
        probe_mathlib = llm.provider != "stub"

    theorem_name = spec["theorem_name"]

    # 1. Ask the LLM to decompose.
    extract_prompt = EXTRACT_PROMPT.format(
        theorem_name=theorem_name,
        theorem_nl=spec.get("theorem_nl", ""),
        assumptions_block=_format_assumptions(spec.get("assumptions", []) or []),
        conclusion=spec.get("conclusion", ""),
        steps_block=_format_steps(spec.get("steps", []) or []),
    )
    decomp: dict | None = None
    try:
        resp = llm.ask(
            stage="architect",
            task="extract_lemmas",
            prompt=extract_prompt,
            system=EXTRACT_SYSTEM,
            max_tokens=4096,
        )
        history.append({"step": "extract_lemmas", "provider": resp.provider})
        decomp = _safe_json_loads(resp.text)
        if decomp is None:
            history.append({"step": "extract_lemmas_parse_failed",
                            "raw_head": resp.text[:200]})
    except KeyError as e:
        history.append({"step": "extract_lemmas_stub_missing", "error": str(e)})

    if decomp is None or not isinstance(decomp.get("lemmas"), list):
        history.append({"step": "fallback_single_lemma"})
        bp = _fallback_blueprint(spec, history)
        _write_blueprint(bp, output_dir)
        return bp

    # 2. Build Lemma objects.
    lemmas: list[Lemma] = []
    for i, raw in enumerate(decomp["lemmas"], 1):
        if isinstance(raw, dict):
            lemmas.append(_coerce_lemma(raw, i))

    main_raw = decomp.get("main") or {}
    main_id = str(main_raw.get("id") or "main")
    main_lemma = Lemma(
        id=main_id,
        name=str(main_raw.get("name") or theorem_name),
        statement_nl=spec.get("theorem_nl", ""),
        assumptions_nl=list(spec.get("assumptions", []) or []),
        conclusion_nl=spec.get("conclusion", ""),
        source="NEW",
        depends_on=[
            str(x) for x in (main_raw.get("depends_on") or [l.id for l in lemmas])
        ],
        reuse_potential=str(main_raw.get("reuse_potential", "high")),
        reuse_reason=str(main_raw.get("reuse_reason", "the main theorem itself")),
        abstraction_level=str(main_raw.get("abstraction_level", "")),
    )

    # 3. Probe Mathlib for guessed names.
    probe: dict[str, bool] = {}
    all_candidates: list[str] = []
    for l in lemmas:
        all_candidates.extend(l.mathlib_candidates)
    if probe_mathlib and all_candidates:
        try:
            probe = probe_mathlib_names(
                all_candidates, output_dir=output_dir, timeout=probe_timeout
            )
            history.append({"step": "mathlib_probe", "checked": len(probe),
                            "resolved": sum(1 for v in probe.values() if v)})
        except Exception as e:  # never fail the whole pipeline on a probe error
            history.append({"step": "mathlib_probe_failed", "error": str(e)})

    for l in lemmas:
        for cand in l.mathlib_candidates:
            normalized = _normalize_name(cand)
            if probe.get(normalized):
                l.source = "MATHLIB"
                l.mathlib_name = normalized
                break

    # 4. Build DAG (clamp deps to known ids; main always lives in the graph).
    valid: set[str] = {l.id for l in lemmas} | {main_id}
    dag: dict[str, list[str]] = {}
    for l in lemmas:
        dag[l.id] = [d for d in l.depends_on if d in valid and d != l.id]
    dag[main_id] = [d for d in main_lemma.depends_on if d in valid and d != main_id]

    build_order, parallel_groups = _topological_layers(dag)
    history.append(
        {"step": "topological_sort", "layers": len(parallel_groups),
         "nodes": len(dag)}
    )

    # 5. Plan file structure (NEW lemmas only get files; MATHLIB ones import-only).
    base_dir = f"LeanAgent/Generated/{_camelize(theorem_name)}"
    file_structure: dict[str, str] = {}
    for l in lemmas:
        if l.source == "NEW":
            file_structure[f"{base_dir}/{_camelize(l.name)}.lean"] = l.id
    file_structure[f"{base_dir}/Main.lean"] = main_id

    bp = Blueprint(
        theorem_name=theorem_name,
        main_id=main_id,
        lemmas=lemmas + [main_lemma],
        dag=dag,
        build_order=build_order,
        parallel_groups=parallel_groups,
        file_structure=file_structure,
        history=history,
        probe=probe,
    )
    _write_blueprint(bp, output_dir)
    return bp


def _write_blueprint(bp: Blueprint, output_dir: Path) -> None:
    out = Path(output_dir) / "blueprint.json"
    out.write_text(
        json.dumps(bp.to_json(), indent=2, ensure_ascii=False),
        encoding="utf-8",
    )
