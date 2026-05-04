"""
Top-level runner — per-lemma loop driven by Stage 0's Blueprint.

Pipeline:
  Stage 0  — Architect  : decompose into a lemma DAG.
  Stage 1  — Decomposer : per-NEW-lemma atomic step list.
  For each lemma in build_order (skipping MATHLIB ones):
    Stage 2 — Aligner   : signature + back-translation.
    Stage 3 — Skeleton  : `have`-chain skeleton.
    Stage 4 — Filler    : close sorries (with persistence playbook).
    Stage 5 — Verifier  : sorry/compile/back-translation verdict.
    Stage 6 — Linter    : docstring / naming / PR-ready (only on CERTIFIED).
    Persist : translation-pair, lemma metadata, tactic plays, failures.
  Main theorem runs last with imports of all CERTIFIED auxiliary lemmas.

Outputs land in `output/<theorem>_<ts>/`:
  blueprint.json
  lemma_specs/<lemma_id>.json
  per_lemma/<lemma_id>/{report.json,report.md, copied .lean}
  main/{report.json, report.md, copied .lean}
  registry/                       (also written to LeanAgent/registry/)

Usage:
  python scripts/run.py Tests/test_descent_lemma.json [--provider stub|anthropic|auto]
                                                       [--stub PATH]
                                                       [--output DIR]
"""

from __future__ import annotations

import argparse
import json
import sys
import time
from dataclasses import asdict, is_dataclass
from pathlib import Path
from typing import Any

from . import Utils
from .Architect import Blueprint, Lemma, run_architect
from .Decomposer import LemmaSpec, run_decomposer
from .Aligner import run_aligner, AlignerResult
from .Skeleton import run_skeleton, SkeletonResult
from .Filler import run_filler, FillerResult
from .Verifier import run_verifier, VerifierResult
from .Linter import run_linter, LintResult
from .Persistence import PersistenceManager
from .LLM import LLM


# --------------------------------------------------------------------------- #
# Serialization
# --------------------------------------------------------------------------- #


def _to_serializable(obj: Any) -> Any:
    if is_dataclass(obj):
        return {k: _to_serializable(v) for k, v in asdict(obj).items()}
    if isinstance(obj, Path):
        return str(obj)
    if isinstance(obj, dict):
        return {k: _to_serializable(v) for k, v in obj.items()}
    if isinstance(obj, (list, tuple)):
        return [_to_serializable(x) for x in obj]
    return obj


# --------------------------------------------------------------------------- #
# Per-lemma stages
# --------------------------------------------------------------------------- #


def _run_one_lemma(
    *,
    lemma_id: str,
    lemma_spec_dict: dict,
    target_lean_path: Path,
    output_dir: Path,
    llm: LLM,
    persistence: PersistenceManager,
) -> dict:
    """Run Stage 2-5 (+ Stage 6 + persist) for one lemma. Returns a summary."""
    output_dir.mkdir(parents=True, exist_ok=True)

    print(Utils.banner(f"LEMMA: {lemma_id}"))
    summary: dict[str, Any] = {
        "lemma_id": lemma_id,
        "lean_file": str(target_lean_path),
        "verdict": "FAIL_BEFORE_ALIGNER",
    }

    aligner = run_aligner(
        lemma_spec_dict,
        output_dir=output_dir,
        llm=llm,
        lean_file_override=target_lean_path,
    )
    summary["aligner"] = _to_serializable(aligner)
    print(f"  STAGE 2 — ALIGNER  iter={aligner.iterations} "
          f"compiled={aligner.success} NL-aligned={aligner.nl_alignment_ok}")
    if not aligner.success:
        summary["verdict"] = "FAIL_ALIGNER"
        _write_lemma_artifacts(output_dir, summary, aligner.lean_file)
        return summary

    skeleton = run_skeleton(
        aligner.lean_file, steps=lemma_spec_dict["steps"], llm=llm
    )
    summary["skeleton"] = _to_serializable(skeleton)
    print(f"  STAGE 3 — SKELETON iter={skeleton.iterations} "
          f"compiled={skeleton.success} sorries={skeleton.sorry_count}")
    if not skeleton.success:
        summary["verdict"] = "FAIL_SKELETON"
        _write_lemma_artifacts(output_dir, summary, aligner.lean_file)
        return summary

    filler = run_filler(
        aligner.lean_file,
        steps=lemma_spec_dict["steps"],
        llm=llm,
        persistence=persistence,
    )
    summary["filler"] = _to_serializable(filler)
    print(f"  STAGE 4 — FILLER   closed={filler.closed} stuck={filler.stuck} "
          f"final_sorries={filler.final_sorry_count}")

    verifier = run_verifier(aligner.lean_file, spec=lemma_spec_dict, llm=llm)
    summary["verifier"] = _to_serializable(verifier)
    summary["verdict"] = verifier.verdict
    print(f"  STAGE 5 — VERIFIER verdict={verifier.verdict} "
          f"errors={verifier.compile_errors}")

    if verifier.verdict == "CERTIFIED":
        lint = run_linter(aligner.lean_file, llm=llm)
        summary["linter"] = _to_serializable(lint)
        summary["pr_ready"] = lint.pr_ready
        print(f"  STAGE 6 — LINTER   issues={len(lint.issues)} "
              f"auto_fixed={len(lint.auto_fixed)} pr_ready={lint.pr_ready}")
    else:
        summary["pr_ready"] = False

    _persist_lemma(
        spec=lemma_spec_dict,
        verifier=verifier,
        filler=filler,
        aligner=aligner,
        persistence=persistence,
        lemma_id=lemma_id,
        pr_ready=summary.get("pr_ready", False),
    )

    _write_lemma_artifacts(output_dir, summary, aligner.lean_file)
    return summary


def _persist_lemma(
    *,
    spec: dict,
    aligner: AlignerResult,
    filler: FillerResult | None,
    verifier: VerifierResult,
    persistence: PersistenceManager,
    lemma_id: str,
    pr_ready: bool,
) -> None:
    domain = spec.get("domain", "unknown")
    if verifier.verdict == "CERTIFIED":
        persistence.save_lemma(
            theorem_name=spec["theorem_name"],
            lean_file=aligner.lean_file,
            nl_statement=spec.get("theorem_nl", ""),
            assumptions=list(spec.get("assumptions", []) or []),
            verdict=verifier.verdict,
            pr_ready=pr_ready,
            domain=domain,
            extra={"lemma_id": lemma_id},
        )
    if aligner and aligner.success:
        persistence.save_translation_pair(
            nl=spec.get("theorem_nl", ""),
            lean=Utils.read_text(aligner.lean_file),
            difficulty="unknown",
            domain=domain,
            theorem_name=spec["theorem_name"],
        )
    if filler:
        for r in filler.reports:
            if r.closed and r.tactic:
                persistence.save_tactic_success(
                    goal_pattern=r.goal_state or r.description,
                    tactic=r.tactic,
                    domain=domain,
                    theorem_name=spec["theorem_name"],
                )
            elif not r.closed:
                persistence.save_failure(
                    goal_state=r.goal_state or r.description,
                    tried=r.attempts,
                    root_cause=r.method,
                    resolved=False,
                    theorem_name=spec["theorem_name"],
                )


def _write_lemma_artifacts(
    output_dir: Path, summary: dict, lean_file: Path | str
) -> None:
    (output_dir / "report.json").write_text(
        json.dumps(summary, indent=2, ensure_ascii=False, default=str),
        encoding="utf-8",
    )
    p = Path(lean_file)
    if p.exists():
        (output_dir / p.name).write_text(
            Utils.read_text(p), encoding="utf-8"
        )


# --------------------------------------------------------------------------- #
# Main spec assembly
# --------------------------------------------------------------------------- #


def _build_main_spec(
    original_spec: dict,
    blueprint: Blueprint,
    lemma_results: dict[str, dict],
) -> dict:
    """Return a copy of the original spec with imports of CERTIFIED aux lemmas.

    Lean imports are not put inside the spec text directly — instead we add an
    `available_imports` / `available_lemma_names` annotation that downstream
    Aligner prompts can pick up. (For MVP the Aligner stub does not consume
    these fields, but keeping them in the spec is forward-compatible.)
    """
    imports: list[str] = []
    lemma_names: list[str] = []
    for lemma_id, result in lemma_results.items():
        if result.get("verdict") != "CERTIFIED":
            continue
        lf = result.get("lean_file")
        if not lf:
            continue
        try:
            module = Utils.lean_module_for(Path(lf))
        except Exception:
            continue
        imports.append(f"import {module}")
        lemma_names.append(lemma_id)
    enriched = dict(original_spec)
    enriched["available_imports"] = imports
    enriched["available_lemma_names"] = lemma_names
    return enriched


# --------------------------------------------------------------------------- #
# Main entry
# --------------------------------------------------------------------------- #


def run(
    input_json: str | Path,
    *,
    provider: str = "auto",
    stub_path: str | Path | None = None,
    output_dir: str | Path | None = None,
) -> dict:
    spec = json.loads(Path(input_json).read_text(encoding="utf-8"))
    theorem_name = spec["theorem_name"]
    timestamp = time.strftime("%Y%m%d_%H%M%S")
    out_root = Path(output_dir) if output_dir else Utils.project_root() / "output"
    out = out_root / f"{theorem_name}_{timestamp}"
    out.mkdir(parents=True, exist_ok=True)

    llm = LLM(provider=provider, stub_path=stub_path)
    persistence = PersistenceManager(
        registry_dir=Utils.project_root() / "LeanAgent" / "registry"
    )

    # ===================== STAGE 0 =====================
    print(Utils.banner("STAGE 0 — ARCHITECT"))
    blueprint = run_architect(spec, output_dir=out, llm=llm)
    aux_lemmas = [l for l in blueprint.lemmas if l.id != blueprint.main_id]
    mathlib_aux = sum(1 for l in aux_lemmas if l.source == "MATHLIB")
    new_aux = sum(1 for l in aux_lemmas if l.source == "NEW")
    print(f"  lemmas: {len(aux_lemmas)} aux ({mathlib_aux} MATHLIB / {new_aux} NEW) + main")
    print(f"  layers: {len(blueprint.parallel_groups)}  "
          f"build_order: {' -> '.join(blueprint.build_order)}")
    print(f"  blueprint: {out / 'blueprint.json'}")

    # ===================== STAGE 1 =====================
    print(Utils.banner("STAGE 1 — DECOMPOSER"))
    decomposer = run_decomposer(
        blueprint, parent_spec=spec, output_dir=out, llm=llm
    )
    for lid, ls in decomposer.specs.items():
        marker = f"({ls.source}"
        if ls.template_name:
            marker += f":{ls.template_name}"
        marker += ")"
        print(f"  {lid}: {len(ls.steps)} steps {marker}")
    if not decomposer.specs:
        print("  (no NEW auxiliary lemmas — main theorem only)")

    # ===================== Per-lemma loop =====================
    # Map lemma_id -> Path (from blueprint.file_structure path-keyed dict).
    id_to_path: dict[str, Path] = {}
    for path_str, lemma_id in blueprint.file_structure.items():
        id_to_path[lemma_id] = Utils.project_root() / Path(path_str)

    lemma_results: dict[str, dict] = {}
    aux_dir = out / "per_lemma"
    aux_dir.mkdir(parents=True, exist_ok=True)

    for lemma_id in blueprint.build_order:
        if lemma_id == blueprint.main_id:
            continue
        lemma = next((l for l in blueprint.lemmas if l.id == lemma_id), None)
        if lemma is None:
            continue
        if lemma.source == "MATHLIB":
            print(Utils.banner(f"LEMMA: {lemma_id}"))
            print(f"  source=MATHLIB ({lemma.mathlib_name}) — import only, "
                  f"skipping Stage 2-5.")
            lemma_results[lemma_id] = {
                "verdict": "MATHLIB",
                "mathlib_name": lemma.mathlib_name,
                "lean_file": None,
            }
            continue
        spec_obj = decomposer.specs.get(lemma_id)
        if spec_obj is None:
            print(Utils.banner(f"LEMMA: {lemma_id}"))
            print("  no decomposer spec — skipping.")
            lemma_results[lemma_id] = {"verdict": "SKIPPED_NO_SPEC"}
            continue

        target_path = id_to_path.get(lemma_id)
        if target_path is None:
            target_path = (
                Utils.generated_dir() / f"{spec_obj.theorem_name}.lean"
            )
        result = _run_one_lemma(
            lemma_id=lemma_id,
            lemma_spec_dict=spec_obj.to_spec_dict(),
            target_lean_path=target_path,
            output_dir=aux_dir / lemma_id,
            llm=llm,
            persistence=persistence,
        )
        lemma_results[lemma_id] = result

    # ===================== Main theorem =====================
    main_spec = _build_main_spec(spec, blueprint, lemma_results)
    main_target = id_to_path.get(blueprint.main_id)
    if main_target is None:
        main_target = Utils.generated_dir() / f"{spec['theorem_name']}.lean"
    main_result = _run_one_lemma(
        lemma_id=blueprint.main_id,
        lemma_spec_dict=main_spec,
        target_lean_path=main_target,
        output_dir=out / "main",
        llm=llm,
        persistence=persistence,
    )
    lemma_results[blueprint.main_id] = main_result

    # ===================== Finalize =====================
    return _finalize(
        out=out,
        spec=spec,
        blueprint=blueprint,
        decomposer=decomposer,
        lemma_results=lemma_results,
        main_id=blueprint.main_id,
        llm=llm,
        persistence=persistence,
    )


def _finalize(
    *,
    out: Path,
    spec: dict,
    blueprint: Blueprint,
    decomposer,
    lemma_results: dict[str, dict],
    main_id: str,
    llm: LLM,
    persistence: PersistenceManager,
) -> dict:
    main_summary = lemma_results.get(main_id, {})
    main_verdict = main_summary.get("verdict", "FAIL_BEFORE_VERIFIER")
    summary = {
        "theorem_name": spec["theorem_name"],
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
        "verdict": main_verdict,
        "blueprint_summary": {
            "lemma_count": len(blueprint.lemmas) - 1,
            "build_order": blueprint.build_order,
            "parallel_groups": blueprint.parallel_groups,
            "sources": {l.id: l.source for l in blueprint.lemmas},
        },
        "decomposer_summary": {
            lid: {"source": ls.source, "n_steps": len(ls.steps),
                  "template": ls.template_name, "notes": ls.notes}
            for lid, ls in decomposer.specs.items()
        },
        "lemma_results": {
            lid: {k: v for k, v in res.items() if k in
                  ("verdict", "lean_file", "pr_ready", "mathlib_name")}
            for lid, res in lemma_results.items()
        },
        "registry_summary": persistence.summary(),
        "llm": llm.report() if llm else None,
    }
    (out / "report.json").write_text(
        json.dumps(summary, indent=2, ensure_ascii=False, default=str),
        encoding="utf-8",
    )
    (out / "report.md").write_text(
        _markdown_overview(summary), encoding="utf-8"
    )

    print(Utils.banner("DONE"))
    print(f"  output: {out}")
    print(f"  registry: {persistence.registry_dir}  ({persistence.summary()})")
    print(f"  per-lemma verdicts: " + ", ".join(
        f"{lid}={res['verdict']}" for lid, res in lemma_results.items()
    ))
    return summary


def _markdown_overview(summary: dict) -> str:
    lines = [f"# Lean Formalization Report — `{summary['theorem_name']}`",
             "",
             f"**Verdict (main)**: `{summary['verdict']}`",
             f"**Timestamp**: {summary['timestamp']}",
             "",
             "## Blueprint",
             ""]
    bp = summary["blueprint_summary"]
    lines.append(f"- {bp['lemma_count']} auxiliary lemmas, "
                 f"{len(bp['parallel_groups'])} layers")
    lines.append(f"- build_order: {', '.join(bp['build_order'])}")
    lines.append("- sources: " + ", ".join(
        f"{k}={v}" for k, v in bp["sources"].items()
    ))
    lines.append("")
    lines.append("## Per-lemma verdicts")
    lines.append("")
    lines.append("| lemma | verdict | pr_ready | lean_file |")
    lines.append("|-------|---------|----------|-----------|")
    for lid, res in summary["lemma_results"].items():
        lines.append(
            f"| `{lid}` | `{res.get('verdict', '?')}` | "
            f"{res.get('pr_ready', False)} | "
            f"`{res.get('lean_file') or '—'}` |"
        )
    lines.append("")
    reg = summary.get("registry_summary") or {}
    lines.append("## Registry footprint")
    lines.append("")
    for k, v in reg.items():
        lines.append(f"- {k}: {v}")
    lines.append("")
    return "\n".join(lines) + "\n"


# --------------------------------------------------------------------------- #
# CLI
# --------------------------------------------------------------------------- #


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description="Lean Formalization Agent runner")
    p.add_argument("input_json", help="Path to a JSON spec for the theorem")
    p.add_argument("--provider", default="auto",
                   choices=["auto", "anthropic", "stub"],
                   help="LLM provider (auto: anthropic if env+SDK, else stub)")
    p.add_argument("--stub", default=None,
                   help="Path to a stub-responses JSON (for stub provider)")
    p.add_argument("--output", default=None, help="Output directory")
    args = p.parse_args(argv)

    stub_path = args.stub
    if stub_path is None:
        spec = json.loads(Path(args.input_json).read_text(encoding="utf-8"))
        candidate = (
            Path(args.input_json).parent / "stubs" / f"{spec['theorem_name']}.json"
        )
        if candidate.exists():
            stub_path = str(candidate)

    summary = run(
        args.input_json,
        provider=args.provider,
        stub_path=stub_path,
        output_dir=args.output,
    )
    print()
    print(f"Verdict: {summary.get('verdict')}")
    return 0 if summary.get("verdict", "FAIL").startswith(("CERTIFIED", "PARTIAL")) else 1


if __name__ == "__main__":
    sys.exit(main())
