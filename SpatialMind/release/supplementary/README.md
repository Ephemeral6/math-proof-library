# SpatialMind — Supplementary Material

This archive contains the engines, benchmark/ablation generators, the
exact pre-computed ablation cells used to produce the main results table
of the paper, and the supporting raw data, transcripts, and follow-up
experiments referenced from §4–§6 and the Appendix.

## 1. Contents

```
supplementary/
├── README.md                      this file
│
├── core/                          Domain-agnostic engine protocol + ablation harness
│   ├── engine.py                  GeometricEngine / GeometricObject protocols
│   ├── relation.py                RelationData (R-primitive output)
│   ├── transform.py               TransformTrace / TransformResult (T-primitive output)
│   ├── comparison.py              RelationComparison (cross-instance compare)
│   ├── counterfactual.py          Counterfactual-bundle plumbing (C-primitive)
│   ├── evaluator.py               0–4 rubric scoring of model responses
│   ├── prompt.py                  Prompt assembly: 2^3 (R,T,C) ablation cells
│   ├── benchmark.py               Suite serialiser
│   └── ablation.py                2^3 cell sweep + factorial analysis
│
├── domains/                       Per-domain external engines
│   ├── boundary_interior/         Polygon / Pick's theorem
│   ├── discrete_curvature/        Combinatorial Gauss–Bonnet / vertex curvature
│   ├── graph_connectivity/        Cuts, blocks, planarity, all-pairs shortest paths
│   ├── knot_theory/               Knot/link invariants (uses snappy + sage if available)
│   ├── projection/                Orthographic / multi-view projection
│   ├── surface_topology/          Mapping-class-group / curve graph (uses curver)
│   └── symmetry/                  Point/wallpaper-group classification
│
├── scripts/                       Generators (one per domain + the surface pair)
│   ├── generate_curvature_benchmark.py   / _ablation.py
│   ├── generate_graph_benchmark.py       / _ablation.py
│   ├── generate_knot_benchmark.py        / _ablation.py
│   ├── generate_polygon_benchmark.py     / _ablation.py     (boundary_interior)
│   ├── generate_projection_benchmark.py  / _ablation.py
│   ├── generate_symmetry_benchmark.py    / _ablation.py
│   ├── generate_full_benchmarks.py       / generate_full_benchmarks_s21.py
│   │                                       (surface_topology — S_{1,2} and S_{2,1})
│   ├── generate_ablation.py              / generate_ablation_s21.py
│   └── generate_ablation_prompts.py      / generate_ablation_prompts_s21.py
│
├── experiments/
│   ├── sample_cases.py            Fixed-seed (42) per-domain case sampler
│   ├── compute_stats.py           Wilcoxon signed-rank + per-cell mean/std
│   │
│   ├── repeated_ablation_results.json    5-rerun raw rubric scores per (domain, cell)
│   ├── repeated_ablation_stats.md        Per-cell mean/std/Wilcoxon table
│   │
│   ├── supplementary_experiments.md      Write-up of Experiments A / A_hard / B / C
│   ├── exp_a_results.json                A: CoT+Code vs CoE-RTC, 18 trials
│   ├── exp_a_hard_results.json           A_hard: harder questions, 3-condition follow-up
│   ├── exp_b_results.json                B: weak-model + RTC vs strong baseline, 12 trials
│   ├── exp_c_results.json                C: re-rater agreement (Cohen's κ), 16 ratings
│   │
│   ├── cross_model_results.json          Opus-as-rater raw scores  [earlier check; see §9]
│   ├── cross_model_sonnet_results.json   Sonnet-as-rater raw scores [earlier check; see §9]
│   ├── cross_model_3way_summary.md       Opus / Sonnet / 3-way agreement table
│   ├── sonnet_prompts.json               Prompt bundle dispatched to Sonnet
│   │
│   ├── cross_eval/                       Opus / GPT-5.5 / Gemini 3 blind rescoring (paper §5.8)
│   │   ├── responses.json                48 Opus-generated responses (8 dom × 3 case × 2 cond)
│   │   ├── scores_opus.json              Opus self-rating
│   │   ├── scores_gpt.json               GPT-5.5 blind rating
│   │   ├── scores_gemini.json            Gemini 3 blind rating
│   │   ├── rubric.md                     0–4 rubric handed to external raters
│   │   ├── instructions_for_external.md  Verbatim instructions sent to GPT-5.5 / Gemini
│   │   ├── analysis.md                   κ / ρ tables, per-condition lifts, p-values
│   │   └── _analysis_numbers.json        Machine-readable form of analysis.md
│   │
│   ├── cross_model_gpt_ablation.json     GPT-5.5 8-domain × 2-cond ablation (paper §5.5)
│   ├── cross_model_gemini_ablation.json  Gemini 3 8-domain × 2-cond ablation (paper §5.5)
│   ├── cross_model_ablation_summary.md   24-cell zero-reversal summary (paper §5.5 + L2)
│   │
│   ├── cross_model_5family_results.json  + _summary.md + _score_opus_inline.py
│   │                                     5-family ablation: Haiku/Sonnet/Opus/DeepSeek/Qwen
│   ├── cross_model_multi_family.py       + _responses.json + _score.py
│   │                                     Multi-family runner + responses + scoring driver
│   │
│   ├── ordinal_regression.py             Ordinal-regression robustness check on 0–4 scores
│   ├── ordinal_regression_results.md     Effect sizes, AIC, etc.
│   │
│   ├── cross_family_scoring*.{py,json,md}  DeepSeek/Qwen rescoring of Opus responses
│   │                                     (alternative cross-rater config; see §9)
│   │
│   ├── method_comparison_results.json    CoE-RTC vs CoT vs Code vs Hybrid head-to-head
│   ├── method_comparison_n10_prompts.json  n=10 prompts (Table 4 source, paper §5.6)
│   ├── method_comparison_n10_results.json  n=10 rated outputs (Table 4 source)
│   ├── run_n10_method_comparison.py        n=10 runner
│   ├── build_n10_prompts.py                n=10 prompt builder
│   │
│   ├── library_hint_results.json         Table 4 row "CoT+Code+Hint" (curver/snappy/networkx)
│   ├── build_library_hint_results.py     Builder for the hint condition
│   │
│   ├── react_comparison_results.json     ReAct-style trajectories on the same cases
│   ├── react_engine_log.jsonl            Per-step engine-call log under ReAct loop
│   ├── react_agent.py                    ReAct harness used to generate the above
│   ├── react_prompt_sensitivity.md       ReAct prompt-sensitivity analysis (paper §5.6)
│   │
│   ├── token_budget_analysis.{json,md,py}  Length-confound check (paper §5.6)
│   │
│   ├── scrambled_r_prompts.json          Scrambled-R control prompts (paper §5.7)
│   ├── scrambled_r_results.json          Scrambled-R control rated outputs
│   ├── build_scrambled_r_prompts.py      Scramble-rule implementation
│   ├── run_scrambled_r_responses.py      Driver
│   │
│   ├── external_benchmark_results.json   v1 run on out-of-distribution problems
│   ├── external_benchmark_v2_results.json v2 run after schema extension
│   ├── external_benchmark_setup.json     Fixed problem set + condition matrix
│   ├── external_benchmark_setup.py       Setup builder
│   ├── external_benchmark_run.py         v1 runner
│   ├── external_benchmark_v2.py          v2 runner
│   │
│   ├── sampled/                          Fixed-seed 5-case sub-sample per domain
│   │   ├── sampling_manifest.json        Which case_ids were drawn per domain
│   │   └── {domain}/{case_id}__{cell}.json   8 cells × 5 cases × 8 domains
│   │
│   └── op1/                              OP-1 lemma 3.4 case study (Discussion)
│       ├── op1_lemma34_proof.md          Final write-up of the proof
│       ├── op1_lemma34_proof_verify.py   Numerical verification driver
│       ├── op1_lemma34_attempt.md        Iterative attempt log
│       ├── op1_small_k_attempt.md        Small-k probe write-up
│       ├── op1_close_attempt.md          Closing-the-gap attempt notes
│       ├── op1_coe_exploration.md        CoE-driven exploration narrative
│       ├── op1_coe_data.json             Engine-extracted R/T/C data backing the above
│       ├── op1_full_sweep.json           Parameter sweep for the lemma's hypothesis
│       ├── op1_homology_check.py         Homology consistency check
│       └── op1_homology.json             Output of the homology check
│
└── benchmarks/
    ├── coe_accuracy_summary.md           Cross-domain accuracy table (CoE-CTR vs Baseline)
    ├── cross_domain_analysis.md          Narrative cross-domain analysis
    ├── cross_domain_stats_auto.md        Auto-generated cross-domain stats table
    │
    ├── coe_reasoning/                    6-dim self-administered reasoning benchmark
    │   ├── SUMMARY.md                    Per-(dim, condition) rubric and accuracy
    │   ├── summary.json                  Same as machine-readable JSON
    │   └── dim{1..6}_*/{questions,responses}.json
    │
    └── {domain}/ablation/                The 8 ablation cells per domain
        ├── {000,00C,0T0,0TC,R00,R0C,RT0,RTC}.json   prompt + reference trace
        ├── ablation_results.md           rubric summary table (median over 5 runs)
        ├── prompts/{cell}.md             rendered prompt sent to the rater
        └── evaluations/{cell}.md         per-cell evaluator rationale
```

The eight rows of the main results table correspond to seven engine
directories under `domains/` plus a second configuration of the
`surface_topology` engine (`S_{2,1}` instead of `S_{1,2}`); this second
configuration ships its data file at
`domains/surface_topology/data/s21_curves.json` and is built by
`generate_full_benchmarks_s21.py` / `generate_ablation_s21.py`. Hence
seven engines, eight columns.

## 2. Mapping from supplementary files to paper sections

The paper draws on the following supplementary artefacts. Reviewers can
trace any quoted number or transcript back to its source through this
table.

| Paper location | Supplementary path | What it contains |
|---|---|---|
| §4.2–§4.4 main results table (Table 2) | `benchmarks/{domain}/ablation/{cell}.json` + `ablation_results.md` | Per-cell prompts and the rubric summary that fills the table |
| §4.4 per-case replication (320 cells, 98.8%) | `experiments/repeated_ablation_results.json`, `repeated_ablation_stats.md`, `experiments/sampled/` | 5 reruns per cell + fixed-seed sampled sub-sample |
| §5.5 cross-model lift (Haiku/Sonnet/Opus, Table 3) | `experiments/cross_model_results.json`, `cross_model_sonnet_results.json` | Within-Claude-family RTC lift |
| **§5.5 cross-family RTC ablation (GPT-5.5/Gemini 3, all 8 domains)** | `experiments/cross_model_gpt_ablation.json`, `cross_model_gemini_ablation.json`, `cross_model_ablation_summary.md` | 24-cell GPT/Gemini RTC ablation; "RTC ≥ baseline in all 24 cells" |
| **§5.6 method comparison (Table 4, n=10)** | `experiments/method_comparison_results.json`, `method_comparison_n10_{prompts,results}.json`, `run_n10_method_comparison.py`, `build_n10_prompts.py` | The 320-trial n=10 head-to-head (CoE vs Zero-CoT vs CoT+Code vs ReAct) |
| **§5.6 CoT+Code+Hint condition (Table 4)** | `experiments/library_hint_results.json`, `build_library_hint_results.py` | Explicit library-hint condition (curver / snappy / networkx) |
| **§5.6 prompt-sensitivity (ReAct)** | `experiments/react_prompt_sensitivity.md` | Knot-theory ReAct variants (few-shot, explicit-C, full-hint) |
| **§5.6 token-budget analysis** | `experiments/token_budget_analysis.{json,md,py}` | Per-condition prompt/response lengths + ρ(length, score) |
| **§5.7 scrambled-R control** | `experiments/scrambled_r_{prompts,results}.json`, `build_scrambled_r_prompts.py`, `run_scrambled_r_responses.py` | Random R numerics drop CoE-R from 3.75 → 2.46 (−34%) |
| **§5.8 cross-family blind scoring (Opus / GPT-5.5 / Gemini 3)** | `experiments/cross_eval/` (responses, per-rater scores, rubric, instructions, analysis) | Source of κ=0.79 / 0.43 / 0.63 and per-rater RTC lifts in §5.8 |
| §4.5 cross-domain analysis | `benchmarks/cross_domain_analysis.md`, `cross_domain_stats_auto.md`, `coe_accuracy_summary.md` | Spearman / accuracy tables across domains |
| §4.5 CoE reasoning sub-benchmark | `benchmarks/coe_reasoning/` | 6-dim self-administered protocol + responses |
| §4.5 / §6.2 external validation | `experiments/external_benchmark_{,v2_}results.json`, `external_benchmark_*.py`, `external_benchmark_setup.json` | Out-of-distribution validation on independently sourced problems |
| §4.6 caveat #4 / §5.3 superadditivity | `experiments/exp_a_results.json`, `exp_a_hard_results.json`, `exp_b_results.json`, `supplementary_experiments.md` | A: ceiling effect; A_hard: schema-extension reversal; B: weak-model recovery |
| §6 (L1) self-rating bias | `experiments/cross_eval/analysis.md` | Three-rater confirmation (Opus / GPT / Gemini); +1.79 / +0.67 / +1.42 lifts all p < 0.01 |
| §6 (L2) cross-model coverage | `experiments/cross_model_ablation_summary.md` | "RTC ≥ baseline in all 24 cells" across Opus / GPT-5.5 / Gemini 3 |
| §6 (L2) extended robustness | `experiments/cross_model_5family_{results.json,summary.md}`, `cross_model_multi_family*` | DeepSeek + Qwen-Max as 4th and 5th families |
| §6 (L3) ordinal robustness | `experiments/ordinal_regression.{py,_results.md}` | 0–4 rubric refit as ordinal model |
| Appendix A full transcripts | `benchmarks/{domain}/ablation/prompts/{cell}.md` and `evaluations/{cell}.md` | Verbatim prompt + evaluator rationale per cell (8 × 8 each) |
| Discussion / OP-1 case study (309-curve verification) | `experiments/op1/` | Full proof write-up, homology checks, sweeps; backs the 309-curve claim and the two open lemmas (ℓ ≤ 1 contractibility, Bonahon $d$-evenness) |

## 3. Environment

- **Python**: 3.10 or newer (developed on 3.13).
- Required PyPI packages:
  - `numpy`, `scipy`, `networkx`, `sympy`, `matplotlib`
- Optional, only needed if you want to regenerate certain benchmarks
  from scratch (the pre-computed cells in `benchmarks/` do not require
  these to *evaluate*):
  - **`curver`** — used by `domains/surface_topology/engine.py` for
    mapping-class-group / curve-graph computations.
    `pip install curver`
  - **`snappy`** — used by `domains/knot_theory/engine.py` for hyperbolic
    knot invariants.  Install per the SnapPy docs
    (`https://snappy.computop.org/`).  A pure-PyPI fallback is
    `pip install snappy-manifolds`; a few invariants are unavailable
    without the full SnapPy.

A minimal installer that is enough to score the shipped cells:

```bash
pip install numpy scipy networkx sympy matplotlib
```

To also regenerate cells:

```bash
pip install curver snappy-manifolds   # plus full SnapPy if needed
```

## 4. Layout assumed by the scripts

The scripts use `from SpatialMind.<sub>...` imports.  Place the
unpacked archive so that `supplementary/` is importable as a package
named `SpatialMind`:

```bash
unzip supplementary.zip
mv supplementary SpatialMind          # rename: import path is SpatialMind.*
export PYTHONPATH=$PWD                # so `import SpatialMind` works
```

(Equivalently: keep the `supplementary/` name and edit `sys.path`.)

## 5. Reproducing the ablation cells

Each domain's `ablation/{000,00C,0T0,0TC,R00,R0C,RT0,RTC}.json` is a
list of one entry per benchmark case, holding the prompt + reference
trace for that 2^3 cell.  To rebuild them from scratch:

```bash
# (1) raw benchmarks (geometric objects + relations)
python -m SpatialMind.scripts.generate_curvature_benchmark
python -m SpatialMind.scripts.generate_graph_benchmark
python -m SpatialMind.scripts.generate_knot_benchmark
python -m SpatialMind.scripts.generate_polygon_benchmark      # boundary_interior
python -m SpatialMind.scripts.generate_projection_benchmark
python -m SpatialMind.scripts.generate_symmetry_benchmark
python -m SpatialMind.scripts.generate_full_benchmarks        # surface_topology  S_{1,2}
python -m SpatialMind.scripts.generate_full_benchmarks_s21    # surface_topology  S_{2,1}

# (2) the 2^3 ablation slicing per domain
python -m SpatialMind.scripts.generate_curvature_ablation
python -m SpatialMind.scripts.generate_graph_ablation
python -m SpatialMind.scripts.generate_knot_ablation
python -m SpatialMind.scripts.generate_polygon_ablation
python -m SpatialMind.scripts.generate_projection_ablation
python -m SpatialMind.scripts.generate_symmetry_ablation
python -m SpatialMind.scripts.generate_ablation               # surface_topology  S_{1,2}
python -m SpatialMind.scripts.generate_ablation_s21           # surface_topology  S_{2,1}
```

Output is written into `benchmarks/{domain}/ablation/`.  Generation is
deterministic given the seeds embedded in each script (default `42`),
so the rebuilt JSONs are byte-identical to the ones shipped here modulo
key ordering.

## 6. Reproducing the main results table

The table reports, per domain × per ablation cell, a 0–4 rubric score
on the prompts in `benchmarks/{domain}/ablation/{cell}.json`.  Scoring
is done by an LLM rater according to the rubric in
`core/evaluator.py` (anchors: 0=NO_ATTEMPT, 1=RECALL, 2=COMPUTATION,
3=ARGUMENT, 4=PROOF).  The table value is the median over five
independent runs; raw runs are released alongside the per-domain
summary files referenced from the paper.

To recompute the per-cell statistics (mean, std, Wilcoxon signed-rank
across the R/T/C dimensions) from
`experiments/repeated_ablation_results.json`:

```bash
python -m SpatialMind.experiments.compute_stats
```

To draw a fixed-seed sub-sample of 5 cases per domain (for human-rater
verification or qualitative case studies):

```bash
python -m SpatialMind.experiments.sample_cases
# writes experiments/sampled/{domain}/{case_id}__{cell}.json
```

The sub-sample produced by the seed shipped here is the one already
materialised under `experiments/sampled/`.

The eight rows of the main results table (and the corresponding columns
of main effects R, T, C and two-way interactions R×T, R×C, T×C) are
direct functions of the eight cells per domain — see
`core/ablation.py:factorial_decompose` for the closed-form formulae
(standard Yates-style 2^3 decomposition).

## 7. Reproducing the supplementary experiments

The four self-experiments described in `experiments/supplementary_experiments.md`
(A, A_hard, B, C) use the same prompts and the same rubric as the main
table; the difference is the condition matrix (CoT-with-code, weak-model
persona, and re-rater respectively). The raw JSONs hold one record per
trial: `{question_id, condition, response, score, rationale}`.

The cross-rater experiment (Opus vs Sonnet) uses the prompts in
`experiments/sonnet_prompts.json`; the Sonnet outputs and re-scored
ratings are in `cross_model_sonnet_results.json`; the Opus baseline is
in `cross_model_results.json`; the agreement table is in
`cross_model_3way_summary.md`.

The method-comparison and ReAct experiments are driven by
`react_agent.py` (which exposes the engine through a tool-call loop)
and the runner code embedded in `method_comparison_results.json`'s
header. Replays are deterministic given the cached engine traces.

The external-benchmark experiment uses `external_benchmark_setup.py` to
build a fixed problem set (`external_benchmark_setup.json`) drawn from
out-of-distribution sources, then `external_benchmark_run.py` /
`external_benchmark_v2.py` to evaluate. v2 differs from v1 by including
the all-pairs-shortest-paths schema extension reported in §A_hard of
`supplementary_experiments.md`.

## 8. OP-1 case study (`experiments/op1/`)

The Discussion section refers to the OP-1 lemma 3.4 case study as an
illustration of CoE-driven exploration on an open mathematical problem.
The directory bundles:

- `op1_lemma34_proof.md` — the final proof of lemma 3.4.
- `op1_lemma34_proof_verify.py` — numerical verification of the key
  identity invoked in the proof.
- `op1_lemma34_attempt.md` — the iterative attempt log that preceded
  the final proof.
- `op1_small_k_attempt.md`, `op1_close_attempt.md` — earlier targeted
  attempts on the small-k regime and on closing the residual gap.
- `op1_coe_exploration.md` — the narrative of how engine-extracted R/T/C
  data shaped the proof strategy.
- `op1_coe_data.json` — the engine output that the exploration consumed.
- `op1_full_sweep.json` — the parameter sweep used to falsify earlier
  conjectures and pin down the lemma's hypothesis.
- `op1_homology_check.py` + `op1_homology.json` — independent homology
  consistency check that the proof's invariants are well-defined.

The case study is included so reviewers can verify the Discussion's
claim that CoE-RTC supports not just rubric-scored answers but also
the iterative structure of an actual proof.

## 9. Multiple cross-rater configurations

Three independent cross-rater experiments are bundled. The **paper's
§5.8 numbers come exclusively from `cross_eval/`**; the other two are
earlier or alternative configurations retained for reviewer reference.

| Where | Raters | Scope | Notes |
|-------|--------|-------|-------|
| `cross_eval/` (canonical) | Opus / GPT-5.5 / Gemini 3 | 48 responses (8 dom × 3 case × 2 cond) | **Source of paper §5.8 κ / ρ / p values.** Three model families across both decision boundaries. |
| `cross_model_{results,sonnet_results,3way_summary}` | Opus / Sonnet | full 8-domain × 8-cell sweep | Earlier within-Claude-family check; all-positive but limited to one family. |
| `cross_family_scoring*` | Opus self / DeepSeek / Qwen-Max as raters | 48 responses (same Opus outputs as `cross_eval/`) | Alternative cross-family rater configuration; reproduces the RTC > baseline direction with smaller (DeepSeek) and stronger (Qwen) raters. **Not** the source of any paper number — kept for completeness only. |

The L1 (self-rating bias) mitigation that the paper cites is
`cross_eval/analysis.md`. The Sonnet and DeepSeek/Qwen rescoring
experiments converge on the same direction but are bundled as
robustness rather than headline.

## 10. Notes on what was removed

- `__pycache__/`, `tests/`, raw per-question LLM completion logs, and
  the intermediate `level_{1..5}.json` files (which run to ~80 MB and
  are reproducible from the generators in §5) are not included.
- The `op1_*` directory ships the curated subset listed in §8 only;
  the full OP-1 working tree (≈ 30 files of probes, drafts, and logs)
  was filtered down to the proof, the verifier, and the data files
  that the proof and the Discussion explicitly cite.
- A one-time prompt-splitting helper (`split_prompts.py`,
  `build_sonnet_prompts.py`, `append_ratings.py`) and the per-prompt
  `sonnet_prompt_files/` shards are excluded — `sonnet_prompts.json`
  already holds the canonical prompt bundle.
- Absolute filesystem paths from the development machine were
  programmatically scrubbed; the staging script (`stage.py`,
  retained at the top of the release directory) prints the redaction
  count.
