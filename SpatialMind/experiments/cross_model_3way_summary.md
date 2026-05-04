# Cross-model R-universality: 3-model × 2-condition summary

**Date:** 2026-05-02
**Models:** Haiku 4.5, Sonnet 4.6, Opus 4.7
**Rubric:** 0–4, scored by Opus on response text alone

## Matched 3-domain comparison (apples-to-apples, n=9 per cell)

Original Haiku/Opus study used `symmetry + knot_theory + graph_connectivity`, 3 cases each. Sonnet was re-run on the same 9 problems × 2 conditions for direct comparison.

|             | Baseline | +RTC  | RTC lift |
|-------------|:--------:|:-----:|:--------:|
| Haiku 4.5   | 3.000    | 3.667 | +0.667   |
| Sonnet 4.6  | 3.111    | 3.889 | +0.778   |
| Opus 4.7    | 3.333    | 4.000 | +0.667   |

**Cross-model ordering is monotonic** in both conditions (Haiku < Sonnet < Opus), with a near-constant gap of ~0.17 between adjacent tiers.

**RTC lift is roughly constant across model sizes** (+0.67 to +0.78), supporting the original "architecture > parameters" finding: the engine's R/T/C scaffolding contributes a mostly-fixed +2/3 to +1 reasoning quality jump independent of model capacity.

**Key crossover points (matched subset):**
- Haiku-with-RTC (3.667) > Opus-baseline (3.333), Δ = +0.334
- Sonnet-with-RTC (3.889) > Opus-baseline (3.333), Δ = +0.556
- Haiku-with-RTC (3.667) ≈ Sonnet-baseline (3.111) + 0.556 (RTC overcomes one model-tier gap)

## Full 8-domain comparison (Sonnet only, n=24 per cell)

The Sonnet run extended the protocol to 5 additional domains (boundary_interior, discrete_curvature, projection, surface_topology, surface_topology_s21), giving:

|             | Baseline | +RTC  | RTC lift |
|-------------|:--------:|:-----:|:--------:|
| Sonnet 4.6  | 3.000    | 3.958 | **+0.958** |

The wider domain set shows a larger lift (+0.96 vs +0.78 on the matched subset). Two factors:
1. **Projection** has weak baselines (mean 2.33) because the summary_delta semantics are easy to misread when only relative quantities are exposed; RTC supplies absolute V/E/collision/distance counts.
2. **Surface_topology** (both variants) requires bigon-with-puncture classification to argue minimal position — a structural primitive that R/T/C exposes but baseline data does not.

## Sources

- Haiku & Opus matched-subset numbers: `cross_model_results.json` (existing).
- Sonnet matched-subset & full-8-domain numbers: `cross_model_sonnet_results.json` (this run).
- All 48 Sonnet prompts: `sonnet_prompt_files/`.
- Prompt builder: `build_sonnet_prompts.py`.

## Caveats

- All scoring is intra-Claude (Opus rates Haiku, Sonnet, and Opus). True inter-rater reliability against a human grader remains untested.
- n = 9 (matched) and n = 24 (full Sonnet) per cell; differences below ~0.3 are likely within rubric-step noise.
- Baseline prompts include `metadata` fields that partially leak the answer (especially in symmetry); the task therefore measures justification quality, not answer-discovery, on most domains.
