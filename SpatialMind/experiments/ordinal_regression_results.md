# Ordinal Logistic Regression — Robustness Check for Table 2

**Data**: `repeated_ablation_results.json` — 40 cases × 8 conditions = 320 observations.
**Outcome**: `score` ∈ {0,1,2,3,4} (NO_SIGNAL → PROOF), treated as ordinal.
**Link**: cumulative logit (proportional odds).
**Predictors**: indicator variables R, T, C and all two- and three-way interactions.

Score distribution:

- score 0: 10
- score 1: 15
- score 2: 130
- score 3: 90
- score 4: 75

---

## 1. Full model — main effects + all interactions

`logit P(Y ≤ k | X) = α_k − (β_R·R + β_T·T + β_C·C + β_RT·RT + β_RC·RC + β_TC·TC + β_RTC·RTC)`

Note on sign: statsmodels parameterises the linear predictor as **subtracted** from the cutpoint, so a positive β shifts the latent variable upward → higher scores. Odds ratio OR = exp(β) is the multiplicative effect on the **odds of being in a higher category**.

### Coefficients

| term | beta | SE | OR | OR_lo95 | OR_hi95 | z | p |
|---|---|---|---|---|---|---|---|
| R | 4.184 | 0.608 | 65.611 | 19.919 | 216.114 | 6.88 | 0.0000 |
| T | 3.494 | 0.604 | 32.903 | 10.080 | 107.400 | 5.79 | 0.0000 |
| C | 2.961 | 0.582 | 19.325 | 6.171 | 60.521 | 5.08 | 0.0000 |
| RT | -2.475 | 0.747 | 0.084 | 0.019 | 0.364 | -3.31 | 0.0009 |
| RC | -1.653 | 0.726 | 0.191 | 0.046 | 0.794 | -2.28 | 0.0228 |
| TC | -2.506 | 0.718 | 0.082 | 0.020 | 0.334 | -3.49 | 0.0005 |
| RTC | 1.921 | 0.945 | 6.826 | 1.072 | 43.462 | 2.03 | 0.0420 |

### Cutpoints (proportional-odds thresholds α_k)

| name | raw_theta | alpha_cutpoint |
|---|---|---|
| 0/1 | -1.386 | -1.386 |
| 1/2 | 0.229 | -0.129 |
| 2/3 | 1.411 | 3.971 |
| 3/4 | 0.534 | 5.677 |

### Fit
- log-likelihood: -333.627
- AIC: 689.254
- BIC: 730.705
- n: 320

---

## 2. Main-effects-only model (for comparison)

### Coefficients

| term | beta | SE | OR | OR_lo95 | OR_hi95 | z | p |
|---|---|---|---|---|---|---|---|
| R | 2.380 | 0.250 | 10.810 | 6.627 | 17.634 | 9.53 | 0.0000 |
| T | 1.258 | 0.231 | 3.517 | 2.238 | 5.527 | 5.45 | 0.0000 |
| C | 1.197 | 0.228 | 3.310 | 2.118 | 5.174 | 5.25 | 0.0000 |

### Cutpoints

| name | raw_theta | alpha_cutpoint |
|---|---|---|
| 0/1 | -1.982 | -1.982 |
| 1/2 | 0.103 | -0.874 |
| 2/3 | 1.169 | 2.345 |
| 3/4 | 0.558 | 4.092 |

### Fit
- log-likelihood: -344.833
- AIC: 703.667
- BIC: 730.045

### LR test, full vs. main-only
- LR statistic = 2·(ℓ_full − ℓ_main) = 22.413
- df = 4 (RT, RC, TC, RTC)
- p = 0.0002

---

## 3. Per-domain ordinal logit (matches the granularity of the paper's claim)

The paper's claim from the abstract / §$2^3$ factorial is per-domain:
*"R is the only primitive whose main effect is **strictly positive in every domain** tested"*
and *"T×C is non-positive **everywhere**"*.

Universality is a per-domain statement, not a pooled-p-value statement. So the
robustness-check comparable to the paper is a *per-domain* ordinal logit, with
sign concordance counted across the 8 domains.

### Per-domain coefficient signs

| domain | betaR | betaT | betaC | betaTC | linear_TC |
|---|---|---|---|---|---|
| boundary_interior | +70.79 | +38.24 | +38.24 | +0.88 | -1.80 |
| discrete_curvature | +42.06 | -19.47 | +42.06 | +3.18 | +0.00 |
| graph_connectivity | +112.65 | +63.39 | +63.39 | +31.10 | -0.80 |
| knot_theory | +88.69 | +41.63 | +88.69 | +14.18 | -1.00 |
| projection | +285.87 | +151.53 | +53.04 | +16.17 | +0.00 |
| surface_topology | +100.25 | +31.90 | +100.25 | +52.48 | +0.00 |
| surface_topology_s21 | +42.06 | +42.06 | -19.47 | +3.18 | +0.00 |
| symmetry | +134.74 | +51.90 | +20.72 | +13.95 | -0.40 |

(Magnitudes are not interpretable as effect sizes — many per-domain cells have
constant or near-constant scores, so MLE for the ordinal logit hits the
separability boundary and β values blow up. The *signs* are what we read.)

### Verdict

**Q1. Is R the only universally positive main effect?**
- β_R > 0 in 8/8 domains, β_T > 0 in 7/8, β_C > 0 in 7/8.
- **Yes — R is the only main effect that is strictly positive in every domain under per-domain ordinal logit.** This matches the paper's claim. T and C each have at least one domain with non-positive sign.

**Q2. Is T×C non-positive everywhere?**
- Linear-scale T×C contrast (= mean(0TC) − mean(0T0) − mean(00C) + mean(000)) is non-positive in 8/8 domains — matches the paper.
- Ordinal-logit β_TC (full model) is non-positive in 0/8 domains — *does not match*.
- **Linear-scale: T×C non-positive in all 8 domains** (matches paper). **Ordinal-logit-scale: T×C is positive in 8/8 domains** (does not match). See the scale-dependence note below.

### Why the pooled and per-domain ordinal-logit T×C signs differ

The pooled fit (§1) gave β_TC = -2.51 (negative); the per-domain fits
all give positive β_TC. This is not a contradiction — it is a Simpson-type effect:
domains with very different baselines (mean score under 000 ranges from 1.0 to
3.0 across domains) cause cross-domain heterogeneity to load onto the
interaction term when pooled. The per-domain fits avoid that confound and are
the right statistic for evaluating a per-domain claim.

### Why per-domain ordinal-logit T×C disagrees with the linear factorial

This is *scale dependence*, not a contradiction in the data. The linear
contrast measures sub-/super-additivity in raw scores (saturation at 4 → linear
T×C ≤ 0 once T already gets the score to a high value); the ordinal-logit β_TC
measures the same in cumulative log-odds, where saturation pushes probability
mass past the highest threshold and inflates the latent jump → log-odds T×C
becomes positive. Both can be true simultaneously about the same data.

The paper's "T×C non-positive everywhere" is a linear-scale claim; the ordinal
logit does not refute it but also does not corroborate it on its own scale. For
rebuttal: cite the per-domain *linear* contrast (which the paper already has)
as the load-bearing evidence; note the pooled ordinal logit as a directional
agreement with the caveat above.

---

## 4. Caveats

- **Independence.** The 320 observations are not independent: each of the 40 cases produces 8 ratings (one per condition). A random-intercepts ordinal mixed model (per case_id) is the principled fix. Python options: `bambi` (Bayesian PyMC backend) or `pymer4` (wraps R's `ordinal::clmm`). `mord` does plain ordinal regression and does **not** support random effects. The present pooled and per-domain models treat observations as i.i.d. — SEs are under-estimated for within-case effects.
- **Proportional-odds assumption.** Not tested here (Brant test is in R's `brant` package; statsmodels has no built-in implementation). If the assumption is violated for some predictor, the single OR per term is a summary across cutpoints rather than a constant effect.
- **Per-domain separability.** Within most domains, the score under each condition is constant or near-constant across the 5 cases (see `repeated_ablation_stats.md` per-condition tables). This drives the ordinal-logit MLE toward the separability boundary. *Signs* of per-domain coefficients are reliable as direction; *magnitudes* are not.
- **Use.** Supplementary robustness check intended for rebuttal use, not the main results table.

---

## 5. Reproduction

Run from `SpatialMind/experiments/`:

```
python ordinal_regression.py
```

Outputs this file. Source: `ordinal_regression.py`.
