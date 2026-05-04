"""Stage the supplementary release.

Run from the SpatialMind/ directory or anywhere — paths are resolved
relative to this file. Produces:

  SpatialMind/release/supplementary/        cleaned tree (no __pycache__/tests/etc.)
  SpatialMind/release/supplementary.zip     final archive

Usage:  python SpatialMind/release/stage.py
"""
from __future__ import annotations
import os
import re
import shutil
import sys
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent           # SpatialMind/release
SRC = HERE.parent                                # SpatialMind/
STAGE = HERE / "supplementary"
ZIP_OUT = HERE / "supplementary.zip"

# ----- what to copy -----------------------------------------------------

CORE_FILES = [
    "engine.py", "relation.py", "transform.py", "comparison.py",
    "counterfactual.py", "evaluator.py", "prompt.py",
    "benchmark.py", "ablation.py", "__init__.py",
]

DOMAIN_DIRS = [
    "boundary_interior",
    "discrete_curvature",
    "graph_connectivity",
    "knot_theory",
    "projection",
    "surface_topology",
    "symmetry",
]

# Each engine ships engine.py, counterfactual.py, prompts.py, __init__.py.
# We deliberately skip tests/ (contains absolute paths from the dev box).
# surface_topology/data/s21_curves.json is needed by the s21 generator.
DOMAIN_KEEP_FILES = {"engine.py", "counterfactual.py", "prompts.py", "__init__.py"}
DOMAIN_KEEP_DATA = {"surface_topology": ["data/s21_curves.json"]}

# Files that live outside SpatialMind/ but are needed by generators.
# Bundled into the release tree at the listed in-package destination.
EXTRA_DATA_FILES = [
    # source path (relative to SpatialMind's parent), destination inside stage
    ("workspace/projects/op1_geometry/data_S_1_2.json",
     "domains/surface_topology/data/data_S_1_2.json"),
]

SCRIPT_NAMES = [
    # per-domain generators
    "generate_curvature_benchmark.py",   "generate_curvature_ablation.py",
    "generate_graph_benchmark.py",       "generate_graph_ablation.py",
    "generate_knot_benchmark.py",        "generate_knot_ablation.py",
    "generate_polygon_benchmark.py",     "generate_polygon_ablation.py",
    "generate_projection_benchmark.py",  "generate_projection_ablation.py",
    "generate_symmetry_benchmark.py",    "generate_symmetry_ablation.py",
    # surface_topology uses the "full benchmarks" pair (S_{1,2} and S_{2,1})
    "generate_full_benchmarks.py",       "generate_full_benchmarks_s21.py",
    "generate_ablation.py",              "generate_ablation_s21.py",
    "generate_ablation_prompts.py",      "generate_ablation_prompts_s21.py",
    "__init__.py",
]

EXPERIMENT_FILES = [
    # original (re-pointable from benchmark cells)
    "sample_cases.py", "compute_stats.py",
    # repeated-rater variance + multi-run statistics (paper §4.6 mitigation)
    "repeated_ablation_results.json", "repeated_ablation_stats.md",
    # supplementary self-experiments A / A_hard / B / C (paper §4.6, §5)
    "supplementary_experiments.md",
    "exp_a_results.json", "exp_a_hard_results.json",
    "exp_b_results.json", "exp_c_results.json",
    # cross-model evaluator (Opus / Sonnet 3-way; mitigates §4.6 caveat #3)
    # NOTE: superseded by cross_eval/ (Opus/GPT-5.5/Gemini 3, paper §5.8) but
    # retained here as an additional independent rater check.
    "cross_model_results.json", "cross_model_sonnet_results.json",
    "cross_model_3way_summary.md", "sonnet_prompts.json",
    # method-comparison + ReAct baseline (paper §6.4 Tool-augmented LLMs)
    "method_comparison_results.json",
    "react_comparison_results.json", "react_engine_log.jsonl",
    "react_agent.py",
    # n=10 method comparison: Table 4 in paper (320 trials = 8 domains x 4
    # methods x 10 cases). Generates the prompts used and the rated outputs.
    "method_comparison_n10_prompts.json",
    "method_comparison_n10_results.json",
    "run_n10_method_comparison.py",
    "build_n10_prompts.py",
    # CoT+Code+Hint condition (Table 4 row): explicit library hints
    # (curver, snappy, networkx) + usage examples. Lifts overall 2.42 -> 2.79.
    "library_hint_results.json",
    "build_library_hint_results.py",
    # ReAct prompt-sensitivity (paper §5.6 "supplementary"): tests how much
    # of the ReAct/CoE gap on knot_theory is prompt-engineering vs architecture.
    "react_prompt_sensitivity.md",
    # Token-budget analysis (paper §5.6 paragraph): rules out the
    # length-confound hypothesis; reports rho(prompt_len, score) per condition.
    "token_budget_analysis.json",
    "token_budget_analysis.md",
    "token_budget_analysis.py",
    # Scrambled-R control (paper §5.7): randomise R numeric values, keep JSON
    # structure intact. Drops CoE-R from 3.75 to 2.46 (-34%).
    "scrambled_r_prompts.json",
    "scrambled_r_results.json",
    "build_scrambled_r_prompts.py",
    "run_scrambled_r_responses.py",
    # Cross-family RTC ablation across 8 domains (paper §5.5 final paragraph,
    # also paper §6 L2 mitigation: "RTC >= baseline in all 24 cells").
    "cross_model_gpt_ablation.json",
    "cross_model_gemini_ablation.json",
    "cross_model_ablation_summary.md",
    # Five-model-family extension (DeepSeek + Qwen-Max alongside Haiku/Sonnet/
    # Opus/GPT/Gemini). Strengthens L2 from 3 families to 5.
    "cross_model_5family_results.json",
    "cross_model_5family_summary.md",
    "cross_model_5family_score_opus_inline.py",
    "cross_model_multi_family.py",
    "cross_model_multi_family_responses.json",
    "cross_model_multi_family_score.py",
    # Ordinal regression on the 0-4 rubric: robustness check against treating
    # the scale as interval-level.
    "ordinal_regression.py",
    "ordinal_regression_results.md",
    # DeepSeek/Qwen rescoring of Opus's responses (alternative cross-rater
    # configuration to cross_eval/, kept for completeness; see §9 of README).
    "cross_family_scoring.py",
    "cross_family_scoring_analysis.py",
    "cross_family_scoring_analysis.json",
    "cross_family_scoring_analysis.md",
    "cross_family_scoring_responses.json",
    # external-benchmark validation (paper §4.5 / §6.2)
    "external_benchmark_results.json", "external_benchmark_v2_results.json",
    "external_benchmark_setup.json",
    "external_benchmark_run.py", "external_benchmark_setup.py",
    "external_benchmark_v2.py",
]

# Cross-rater blind-scoring directory (Opus / GPT-5.5 / Gemini 3 each rate the
# same 48 Opus-generated responses). Canonical source for paper §5.8 numbers
# (Cohen's kappa, Spearman rho, per-condition lifts and p-values).
CROSS_EVAL_DIR = "cross_eval"

# Fixed-seed sampled subset for human-rater verification.
# Bundled as experiments/sampled/{domain}/{case_id}__{cell}.json + manifest.
SAMPLED_DIR = "sampled"

# OP-1 case study (paper Discussion / Appendix). Copied to experiments/op1/.
OP1_FILES = [
    "op1_lemma34_proof.md",
    "op1_lemma34_proof_verify.py",
    "op1_small_k_attempt.md",
    "op1_close_attempt.md",
    "op1_lemma34_attempt.md",
    "op1_coe_exploration.md",
    "op1_coe_data.json",
    "op1_full_sweep.json",
    "op1_homology_check.py",
    "op1_homology.json",
]

# Benchmark top-level summary files (paper §4.5 cross-domain analysis).
BENCHMARK_TOP_FILES = [
    "coe_accuracy_summary.md",
    "cross_domain_analysis.md",
    "cross_domain_stats_auto.md",
]

# CoE reasoning sub-benchmark (6 dimensions × {questions,responses}.json),
# self-administered by Claude (paper §4.5).
COE_REASONING_DIR = "coe_reasoning"

# Per-domain ablation extras: the rubric summary + raw prompts + evaluator
# rationales (paper Appendix A — full evaluation transcripts).
ABLATION_EXTRA_FILES = ["ablation_results.md"]
ABLATION_EXTRA_SUBDIRS = ["prompts", "evaluations"]
ABLATION_EXTRA_CELL_NAMES = [c.replace(".json", ".md") for c in
                             ["000.json", "00C.json", "0T0.json", "0TC.json",
                              "R00.json", "R0C.json", "RT0.json", "RTC.json"]]

# Per-domain ablation directories. Only the eight 2^3 cell JSONs are kept.
ABLATION_DOMAINS = [
    "boundary_interior", "discrete_curvature", "graph_connectivity",
    "knot_theory", "projection", "surface_topology",
    "surface_topology_s21", "symmetry",
]
ABLATION_CELLS = ["000.json", "00C.json", "0T0.json", "0TC.json",
                  "R00.json", "R0C.json", "RT0.json", "RTC.json"]

# ----- scrubbing --------------------------------------------------------

# Patterns that look like a developer absolute path.  We replace them with
# a placeholder rather than silently dropping them, so a reviewer can see
# what was redacted.
PERSONAL_PATTERNS = [
    re.compile(r"/mnt/c/Users/[^/\s\"']+/[^\s\"']*"),
    re.compile(r"C:\\\\Users\\\\[^\\\\\s\"']+\\\\[^\s\"']*"),
    re.compile(r"C:/Users/[^/\s\"']+/[^\s\"']*"),
    re.compile(r"/home/[A-Za-z0-9_.-]+/[^\s\"']*"),
    re.compile(r"/Users/[A-Za-z0-9_.-]+/[^\s\"']*"),
]


def scrub_text(text: str) -> tuple[str, int]:
    n = 0
    for pat in PERSONAL_PATTERNS:
        new, k = pat.subn("<REDACTED_LOCAL_PATH>", text)
        n += k
        text = new
    return text, n


def copy_file(src: Path, dst: Path) -> int:
    """Copy file, scrubbing if it's text. Returns number of redactions."""
    dst.parent.mkdir(parents=True, exist_ok=True)
    if src.suffix in {".py", ".md", ".txt", ".tex", ".cfg", ".toml", ".json", ".jsonl"}:
        try:
            text = src.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            shutil.copy2(src, dst)
            return 0
        new, n = scrub_text(text)
        dst.write_text(new, encoding="utf-8")
        return n
    shutil.copy2(src, dst)
    return 0


def main() -> int:
    if STAGE.exists():
        shutil.rmtree(STAGE)
    if ZIP_OUT.exists():
        ZIP_OUT.unlink()
    STAGE.mkdir(parents=True)

    redactions = 0
    n_files = 0

    # core/
    for fn in CORE_FILES:
        s = SRC / "core" / fn
        if s.exists():
            redactions += copy_file(s, STAGE / "core" / fn)
            n_files += 1

    # domains/
    (STAGE / "domains").mkdir(parents=True, exist_ok=True)
    (STAGE / "domains" / "__init__.py").write_text("", encoding="utf-8")
    for dname in DOMAIN_DIRS:
        d_src = SRC / "domains" / dname
        d_dst = STAGE / "domains" / dname
        d_dst.mkdir(parents=True, exist_ok=True)
        for entry in d_src.iterdir():
            if entry.is_dir():
                continue
            if entry.name in DOMAIN_KEEP_FILES:
                redactions += copy_file(entry, d_dst / entry.name)
                n_files += 1
        for rel in DOMAIN_KEEP_DATA.get(dname, []):
            s = d_src / rel
            if s.exists():
                redactions += copy_file(s, d_dst / rel)
                n_files += 1

    # scripts/
    for fn in SCRIPT_NAMES:
        s = SRC / "scripts" / fn
        if s.exists():
            redactions += copy_file(s, STAGE / "scripts" / fn)
            n_files += 1

    # experiments/
    for fn in EXPERIMENT_FILES:
        s = SRC / "experiments" / fn
        if s.exists():
            redactions += copy_file(s, STAGE / "experiments" / fn)
            n_files += 1
        else:
            print(f"  warn: missing experiment file {s}", file=sys.stderr)
    (STAGE / "experiments" / "__init__.py").write_text("", encoding="utf-8")

    # experiments/op1/  — OP-1 lemma-3.4 case study (paper Discussion / Appendix)
    op1_dst = STAGE / "experiments" / "op1"
    op1_dst.mkdir(parents=True, exist_ok=True)
    for fn in OP1_FILES:
        s = SRC / "experiments" / fn
        if s.exists():
            redactions += copy_file(s, op1_dst / fn)
            n_files += 1
        else:
            print(f"  warn: missing op1 file {s}", file=sys.stderr)

    # experiments/sampled/  — fixed-seed per-domain sub-sample
    sampled_src = SRC / "experiments" / SAMPLED_DIR
    sampled_dst = STAGE / "experiments" / SAMPLED_DIR
    if sampled_src.exists():
        for p in sampled_src.rglob("*"):
            if p.is_file():
                rel = p.relative_to(sampled_src)
                redactions += copy_file(p, sampled_dst / rel)
                n_files += 1
    else:
        print(f"  warn: missing sampled dir {sampled_src}", file=sys.stderr)

    # experiments/cross_eval/ — Opus / GPT-5.5 / Gemini 3 blind rescoring of 48
    # Opus-generated responses (paper §5.8). Whole directory, including raw
    # responses, per-rater score JSONs, rubric, instructions, and analysis.
    cross_eval_src = SRC / "experiments" / CROSS_EVAL_DIR
    cross_eval_dst = STAGE / "experiments" / CROSS_EVAL_DIR
    if cross_eval_src.exists():
        for p in cross_eval_src.rglob("*"):
            if p.is_file():
                rel = p.relative_to(cross_eval_src)
                redactions += copy_file(p, cross_eval_dst / rel)
                n_files += 1
    else:
        print(f"  warn: missing cross_eval dir {cross_eval_src}", file=sys.stderr)

    # benchmarks/  top-level cross-domain summaries (paper §4.5)
    for fn in BENCHMARK_TOP_FILES:
        s = SRC / "benchmarks" / fn
        if s.exists():
            redactions += copy_file(s, STAGE / "benchmarks" / fn)
            n_files += 1
        else:
            print(f"  warn: missing benchmark summary {s}", file=sys.stderr)

    # benchmarks/coe_reasoning/  — 6-dim self-administered reasoning benchmark
    coe_src = SRC / "benchmarks" / COE_REASONING_DIR
    coe_dst = STAGE / "benchmarks" / COE_REASONING_DIR
    if coe_src.exists():
        for p in coe_src.rglob("*"):
            if p.is_file():
                rel = p.relative_to(coe_src)
                redactions += copy_file(p, coe_dst / rel)
                n_files += 1
    else:
        print(f"  warn: missing coe_reasoning dir {coe_src}", file=sys.stderr)

    # benchmarks/{domain}/ablation/  the 8-cell JSON payload + extras
    # (rubric summary + raw prompts + per-cell evaluator rationales)
    for dname in ABLATION_DOMAINS:
        s_dir = SRC / "benchmarks" / dname / "ablation"
        if not s_dir.exists():
            print(f"  warn: missing {s_dir}", file=sys.stderr)
            continue
        d_dir = STAGE / "benchmarks" / dname / "ablation"
        # cell payloads
        for cell in ABLATION_CELLS:
            s = s_dir / cell
            if s.exists():
                redactions += copy_file(s, d_dir / cell)
                n_files += 1
            else:
                print(f"  warn: missing {s}", file=sys.stderr)
        # rubric summary
        for fn in ABLATION_EXTRA_FILES:
            s = s_dir / fn
            if s.exists():
                redactions += copy_file(s, d_dir / fn)
                n_files += 1
            else:
                print(f"  warn: missing extra {s}", file=sys.stderr)
        # prompts/ + evaluations/ subdirs (8 cell .md each)
        for sub in ABLATION_EXTRA_SUBDIRS:
            for cell_md in ABLATION_EXTRA_CELL_NAMES:
                s = s_dir / sub / cell_md
                if s.exists():
                    redactions += copy_file(s, d_dir / sub / cell_md)
                    n_files += 1
                else:
                    print(f"  warn: missing extra {s}", file=sys.stderr)

    # extra (out-of-tree) data files
    math_root = SRC.parent
    for rel_src, rel_dst in EXTRA_DATA_FILES:
        s = math_root / rel_src
        if s.exists():
            redactions += copy_file(s, STAGE / rel_dst)
            n_files += 1
        else:
            print(f"  warn: missing extra data {s}", file=sys.stderr)

    # Patch generate_full_benchmarks.py so it looks for the bundled
    # S_{1,2} data file inside the package rather than at MATH_ROOT.
    patch_target = STAGE / "scripts" / "generate_full_benchmarks.py"
    if patch_target.exists():
        text = patch_target.read_text(encoding="utf-8")
        old_block = (
            'def find_database() -> str:\n'
            '    candidates = [\n'
            '        os.path.join(MATH_ROOT, "workspace/projects/op1_geometry/data_S_1_2.json"),\n'
            '        "<REDACTED_LOCAL_PATH>",\n'
            '    ]\n'
            '    for p in candidates:\n'
            '        if os.path.exists(p):\n'
            '            return p\n'
            '    raise SystemExit("[FAIL] Cannot find data_S_1_2.json")'
        )
        new_block = (
            'def find_database() -> str:\n'
            '    candidates = [\n'
            '        os.path.join(ROOT, "domains/surface_topology/data/data_S_1_2.json"),\n'
            '    ]\n'
            '    for p in candidates:\n'
            '        if os.path.exists(p):\n'
            '            return p\n'
            '    raise SystemExit("[FAIL] Cannot find data_S_1_2.json")'
        )
        if old_block in text:
            patch_target.write_text(text.replace(old_block, new_block), encoding="utf-8")
        else:
            print("  warn: could not patch find_database() in generate_full_benchmarks.py",
                  file=sys.stderr)

    # __init__.py for the package shell
    (STAGE / "__init__.py").write_text("", encoding="utf-8")

    # Top-level README.md (source lives next to stage.py as supplementary_README.md)
    readme_src = HERE / "supplementary_README.md"
    if readme_src.exists():
        redactions += copy_file(readme_src, STAGE / "README.md")
        n_files += 1
    else:
        print(f"  warn: missing README source {readme_src}", file=sys.stderr)

    # Final scrub sweep — defence in depth.
    leaked = []
    for p in STAGE.rglob("*"):
        if not p.is_file() or p.suffix not in {".py", ".md", ".txt", ".json", ".tex"}:
            continue
        try:
            text = p.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for pat in PERSONAL_PATTERNS:
            if pat.search(text):
                leaked.append(p)
                break

    print(f"staged {n_files} files into {STAGE}")
    print(f"redactions applied: {redactions}")
    if leaked:
        print(f"  WARN: {len(leaked)} files still contain path-like patterns:")
        for p in leaked[:10]:
            print(f"    {p}")
    else:
        print("  scrub: clean")

    # zip
    with zipfile.ZipFile(ZIP_OUT, "w", zipfile.ZIP_DEFLATED) as zf:
        for p in sorted(STAGE.rglob("*")):
            if p.is_file():
                zf.write(p, p.relative_to(STAGE.parent))
    print(f"zip: {ZIP_OUT}  ({ZIP_OUT.stat().st_size/1024:.1f} KiB)")
    return 0 if not leaked else 2


if __name__ == "__main__":
    sys.exit(main())
