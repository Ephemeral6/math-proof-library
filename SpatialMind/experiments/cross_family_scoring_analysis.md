# Cross-Family Scoring Analysis

**Question.** When DeepSeek and Qwen rescore Opus's responses, do they agree with Opus's self-ratings? And does Opus systematically inflate the RTC condition relative to the baseline (zero_cot) condition?

- Aligned trials (all three scores present): **48**
- Trials dropped (a score was missing): **0**

## Headline table

Δ = Opus_score − External_score, computed per trial then averaged.

| Rater pair | Cohen's κ (unweighted) | Cohen's κ (quadratic) | Spearman ρ | Mean Δ (baseline) | Mean Δ (RTC) | Δ_RTC − Δ_baseline |
|---|---|---|---|---|---|---|
| opus vs deepseek | 0.152 | 0.071 | 0.311 | -1.750 | -0.250 | 1.500 |
| opus vs qwen | 0.457 | 0.380 | 0.801 | -1.333 | 0.000 | 1.333 |
| deepseek vs qwen | 0.313 | 0.313 | 0.431 | — | — | — |

## Per-condition agreement

How much do the raters agree separately on the baseline and RTC slices?

| Rater pair | Condition | n | κ (unweighted) | κ (quadratic) | Spearman ρ |
|---|---|---|---|---|---|
| opus vs deepseek | zero_cot | 24 | 0.106 | -0.021 | -0.082 |
| opus vs deepseek | coe_rtc | 24 | 0.000 | 0.000 | n/a |
| opus vs qwen | zero_cot | 24 | 0.099 | 0.183 | 0.569 |
| opus vs qwen | coe_rtc | 24 | 1.000 | 1.000 | 1.000 |
| deepseek vs qwen | zero_cot | 24 | 0.290 | 0.290 | 0.412 |
| deepseek vs qwen | coe_rtc | 24 | 0.000 | 0.000 | n/a |

## Bias-direction test (the key question)

If Opus's self-rating bias on RTC is real, **Δ_RTC > Δ_baseline** (Opus says RTC is better than outsiders think it is, more than it does for baseline). If the two Δ's are comparable, no preferential RTC inflation is evident — the apparent RTC lift in the original n10 sweep would survive an outside grader.

### Opus vs deepseek

- Δ (baseline) = -1.750 (SD 1.482, n=24)
- Δ (RTC) = -0.250 (SD 0.442, n=24)
- Δ_RTC − Δ_baseline = 1.500 (Welch t = 4.752, two-sided p ≈ 0.000)

### Opus vs qwen

- Δ (baseline) = -1.333 (SD 1.167, n=24)
- Δ (RTC) = 0.000 (SD 0.000, n=24)
- Δ_RTC − Δ_baseline = 1.333 (Welch t = 5.596, two-sided p ≈ 0.000)


## Per-domain Δ breakdown (Opus vs each external)

### Opus vs deepseek

| Domain | Δ baseline (n) | Δ RTC (n) |
|---|---|---|
| boundary_interior | -2.333 (3) | 0.000 (3) |
| discrete_curvature | -2.000 (3) | 0.000 (3) |
| graph_connectivity | -1.000 (3) | 0.000 (3) |
| knot_theory | 0.000 (3) | 0.000 (3) |
| projection | -1.000 (3) | 0.000 (3) |
| surface_topology | -3.667 (3) | -1.000 (3) |
| surface_topology_s21 | -4.000 (3) | -1.000 (3) |
| symmetry | 0.000 (3) | 0.000 (3) |

### Opus vs qwen

| Domain | Δ baseline (n) | Δ RTC (n) |
|---|---|---|
| boundary_interior | -2.000 (3) | 0.000 (3) |
| discrete_curvature | -1.000 (3) | 0.000 (3) |
| graph_connectivity | -0.667 (3) | 0.000 (3) |
| knot_theory | 0.000 (3) | 0.000 (3) |
| projection | -1.000 (3) | 0.000 (3) |
| surface_topology | -3.000 (3) | 0.000 (3) |
| surface_topology_s21 | -3.000 (3) | 0.000 (3) |
| symmetry | 0.000 (3) | 0.000 (3) |
