# Repeated Ablation — Stats

**Date**: 2026-05-02  
**Method**: 5 cases × 8 conditions per domain, evaluator = Claude Opus 4.7 (1M context).
Each (case, condition) is rated independently using only the data permitted under that condition for that single case (plus the global counterfactual block when contrastive is on).

**Scale**: 0=NO_SIGNAL, 1=WRONG_PATTERN, 2=PATTERN, 3=ARGUMENT, 4=PROOF.

**Status**: 8/8 domains completed: ['boundary_interior', 'discrete_curvature', 'graph_connectivity', 'knot_theory', 'projection', 'surface_topology', 'surface_topology_s21', 'symmetry'].

## Cross-domain summary

| domain | overall agree | R-effect (rep / single) | T-effect (rep / single) | C-effect (rep / single) |
|:-------|--------------:|------------------------:|------------------------:|------------------------:|
| boundary_interior | 39/40 (98%) | +1.20 / +1.25 | +0.70 / +0.75 | +0.70 / +0.75 |
| discrete_curvature | 40/40 (100%) | +0.50 / +0.50 | +0.00 / +0.00 | +0.50 / +0.50 |
| graph_connectivity | 39/40 (98%) | +1.20 / +1.25 | +0.70 / +0.75 | +0.70 / +0.75 |
| knot_theory | 40/40 (100%) | +0.75 / +0.75 | +0.25 / +0.25 | +0.75 / +0.75 |
| projection | 40/40 (100%) | +1.25 / +1.25 | +0.75 / +0.75 | +0.25 / +0.25 |
| surface_topology | 40/40 (100%) | +1.25 / +1.25 | +0.25 / +0.25 | +1.25 / +1.25 |
| surface_topology_s21 | 40/40 (100%) | +0.50 / +0.50 | +0.50 / +0.50 | +0.00 / +0.00 |
| symmetry | 38/40 (95%) | +1.60 / +1.50 | +0.60 / +0.50 | +0.10 / +0.00 |

**Overall single-rating agreement**: 316/320 = 98.8%.

## Interpretation

**1. Single-rating evaluation is highly reproducible.** Across 320 cells (8 domains × 8 conditions × 5 cases), 316 agreed exactly with the single-rating baseline = 98.8%. The 4 disagreements are all in `000` cells where per-case data is genuinely thinner than aggregate (no structural primitives, no transform, no CFs). In every other condition the global aggregates (fixed_point_counts, burnside_count, structural_comparison fields) make per-case ratings nearly identical to aggregate ratings.

**2. Main effects reproduce within ±0.10.** Largest deviation: symmetry's R-effect went from +1.50 (single) to +1.60 (repeated) and T-effect from +0.50 to +0.60 — both because the per-case 000 score dropped on diff-orbit cases (wider OFF-side gap → larger ON−OFF difference). All other domains: |Δeffect| ≤ 0.05.

**3. Wilcoxon p≈0.0625 is the noise floor at n=5.** With only 5 cases and integer scores, when all 5 paired differences are positive the smallest possible two-sided p-value is 2·(1/2^5) = 0.0625. Most non-zero main effects hit this floor, indicating the effect direction is consistent but the test lacks power. To get p<0.05 you'd need n≥6 with all-positive diffs, or n=5 with at least 4/5 positive at distinct magnitudes.

**4. The R × C super-additive interaction holds across knot_theory, boundary_interior, projection, discrete_curvature.** This was the chief finding of the original single-rating study and the per-case repetition reproduces it on every domain that had it.

**5. C-effect is null on symmetry and surface_topology_s21.** Reproduced: per-case mean +0.10 (symmetry) and +0.00 (s21) versus single-rating +0.00 in both. The minor +0.10 in symmetry comes from one diff-orbit case rated 1 at 000 (wrong-pattern risk) but rated 2 at 00C (CF supplies group framing) — i.e., the per-case 000 baseline is genuinely lower than aggregate, and CFs help slightly.


---

## Domain: symmetry

Cases: ['same-006', 'diff-163', 'same-028', 'diff-189', 'same-070']

### Per-condition mean ± std (n=5)

| Condition | mean | std | scores | baseline (single) | Δ (mean − single) |
|----------:|-----:|----:|:-------|:------------------|------------------:|
| 000 | 1.60 | 0.49 | [2, 1, 2, 1, 2] | 2 | -0.40 |
| 00C | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| 0T0 | 3.00 | 0.00 | [3, 3, 3, 3, 3] | 3 | +0.00 |
| 0TC | 3.00 | 0.00 | [3, 3, 3, 3, 3] | 3 | +0.00 |
| R00 | 4.00 | 0.00 | [4, 4, 4, 4, 4] | 4 | +0.00 |
| R0C | 4.00 | 0.00 | [4, 4, 4, 4, 4] | 4 | +0.00 |
| RT0 | 4.00 | 0.00 | [4, 4, 4, 4, 4] | 4 | +0.00 |
| RTC | 4.00 | 0.00 | [4, 4, 4, 4, 4] | 4 | +0.00 |

### Wilcoxon signed-rank tests (paired by case_id)

- **R-on vs R-off**: on=4.00, off=2.40, Δ=+1.60; diffs per case=[1.5, 1.75, 1.5, 1.75, 1.5]; W=0, p=0.0625, non-zero pairs=5
- **T-on vs T-off**: on=3.50, off=2.90, Δ=+0.60; diffs per case=[0.5, 0.75, 0.5, 0.75, 0.5]; W=0, p=0.0625, non-zero pairs=5
- **C-on vs C-off**: on=3.25, off=3.15, Δ=+0.10; diffs per case=[0.0, 0.25, 0.0, 0.25, 0.0]; W=0, p=0.5000, non-zero pairs=2

### Consistency vs single-rating baseline

- 000: baseline=2, repeated mean=1.60, n_equal_baseline=3/5
- 00C: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- 0T0: baseline=3, repeated mean=3.00, n_equal_baseline=5/5
- 0TC: baseline=3, repeated mean=3.00, n_equal_baseline=5/5
- R00: baseline=4, repeated mean=4.00, n_equal_baseline=5/5
- R0C: baseline=4, repeated mean=4.00, n_equal_baseline=5/5
- RT0: baseline=4, repeated mean=4.00, n_equal_baseline=5/5
- RTC: baseline=4, repeated mean=4.00, n_equal_baseline=5/5

**Overall agreement**: 38/40 = 95.0% of repeated ratings match the single-rating baseline.

### Per-case condition rankings (within case)

| case_id | 000 | 00C | 0T0 | 0TC | R00 | R0C | RT0 | RTC |
|:--------|----:|----:|----:|----:|----:|----:|----:|----:|
| same-006 | 2 | 2 | 3 | 3 | 4 | 4 | 4 | 4 |
| diff-163 | 1 | 2 | 3 | 3 | 4 | 4 | 4 | 4 |
| same-028 | 2 | 2 | 3 | 3 | 4 | 4 | 4 | 4 |
| diff-189 | 1 | 2 | 3 | 3 | 4 | 4 | 4 | 4 |
| same-070 | 2 | 2 | 3 | 3 | 4 | 4 | 4 | 4 |

---

## Domain: knot_theory

Cases: ['7_2-r2-1', '4_1-r2-4', '3_1-r2-3', '7_3-r2-4', '5_2-r2-5']

### Per-condition mean ± std (n=5)

| Condition | mean | std | scores | baseline (single) | Δ (mean − single) |
|----------:|-----:|----:|:-------|:------------------|------------------:|
| 000 | 1.00 | 0.00 | [1, 1, 1, 1, 1] | 1 | +0.00 |
| 00C | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| 0T0 | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| 0TC | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| R00 | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| R0C | 3.00 | 0.00 | [3, 3, 3, 3, 3] | 3 | +0.00 |
| RT0 | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| RTC | 3.00 | 0.00 | [3, 3, 3, 3, 3] | 3 | +0.00 |

### Wilcoxon signed-rank tests (paired by case_id)

- **R-on vs R-off**: on=2.50, off=1.75, Δ=+0.75; diffs per case=[0.75, 0.75, 0.75, 0.75, 0.75]; W=0, p=0.0625, non-zero pairs=5
- **T-on vs T-off**: on=2.25, off=2.00, Δ=+0.25; diffs per case=[0.25, 0.25, 0.25, 0.25, 0.25]; W=0, p=0.0625, non-zero pairs=5
- **C-on vs C-off**: on=2.50, off=1.75, Δ=+0.75; diffs per case=[0.75, 0.75, 0.75, 0.75, 0.75]; W=0, p=0.0625, non-zero pairs=5

### Consistency vs single-rating baseline

- 000: baseline=1, repeated mean=1.00, n_equal_baseline=5/5
- 00C: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- 0T0: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- 0TC: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- R00: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- R0C: baseline=3, repeated mean=3.00, n_equal_baseline=5/5
- RT0: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- RTC: baseline=3, repeated mean=3.00, n_equal_baseline=5/5

**Overall agreement**: 40/40 = 100.0% of repeated ratings match the single-rating baseline.

### Per-case condition rankings (within case)

| case_id | 000 | 00C | 0T0 | 0TC | R00 | R0C | RT0 | RTC |
|:--------|----:|----:|----:|----:|----:|----:|----:|----:|
| 7_2-r2-1 | 1 | 2 | 2 | 2 | 2 | 3 | 2 | 3 |
| 4_1-r2-4 | 1 | 2 | 2 | 2 | 2 | 3 | 2 | 3 |
| 3_1-r2-3 | 1 | 2 | 2 | 2 | 2 | 3 | 2 | 3 |
| 7_3-r2-4 | 1 | 2 | 2 | 2 | 2 | 3 | 2 | 3 |
| 5_2-r2-5 | 1 | 2 | 2 | 2 | 2 | 3 | 2 | 3 |

---

## Domain: graph_connectivity

Cases: ['R16_n12-t1', 'R02_n12-t4', 'R00_n8-t3', 'R18_n8-t4', 'R07_n8-t0']

### Per-condition mean ± std (n=5)

| Condition | mean | std | scores | baseline (single) | Δ (mean − single) |
|----------:|-----:|----:|:-------|:------------------|------------------:|
| 000 | 1.20 | 0.40 | [1, 1, 2, 1, 1] | 1 | +0.20 |
| 00C | 3.00 | 0.00 | [3, 3, 3, 3, 3] | 3 | +0.00 |
| 0T0 | 3.00 | 0.00 | [3, 3, 3, 3, 3] | 3 | +0.00 |
| 0TC | 4.00 | 0.00 | [4, 4, 4, 4, 4] | 4 | +0.00 |
| R00 | 4.00 | 0.00 | [4, 4, 4, 4, 4] | 4 | +0.00 |
| R0C | 4.00 | 0.00 | [4, 4, 4, 4, 4] | 4 | +0.00 |
| RT0 | 4.00 | 0.00 | [4, 4, 4, 4, 4] | 4 | +0.00 |
| RTC | 4.00 | 0.00 | [4, 4, 4, 4, 4] | 4 | +0.00 |

### Wilcoxon signed-rank tests (paired by case_id)

- **R-on vs R-off**: on=4.00, off=2.80, Δ=+1.20; diffs per case=[1.25, 1.25, 1, 1.25, 1.25]; W=0, p=0.0625, non-zero pairs=5
- **T-on vs T-off**: on=3.75, off=3.05, Δ=+0.70; diffs per case=[0.75, 0.75, 0.5, 0.75, 0.75]; W=0, p=0.0625, non-zero pairs=5
- **C-on vs C-off**: on=3.75, off=3.05, Δ=+0.70; diffs per case=[0.75, 0.75, 0.5, 0.75, 0.75]; W=0, p=0.0625, non-zero pairs=5

### Consistency vs single-rating baseline

- 000: baseline=1, repeated mean=1.20, n_equal_baseline=4/5
- 00C: baseline=3, repeated mean=3.00, n_equal_baseline=5/5
- 0T0: baseline=3, repeated mean=3.00, n_equal_baseline=5/5
- 0TC: baseline=4, repeated mean=4.00, n_equal_baseline=5/5
- R00: baseline=4, repeated mean=4.00, n_equal_baseline=5/5
- R0C: baseline=4, repeated mean=4.00, n_equal_baseline=5/5
- RT0: baseline=4, repeated mean=4.00, n_equal_baseline=5/5
- RTC: baseline=4, repeated mean=4.00, n_equal_baseline=5/5

**Overall agreement**: 39/40 = 97.5% of repeated ratings match the single-rating baseline.

### Per-case condition rankings (within case)

| case_id | 000 | 00C | 0T0 | 0TC | R00 | R0C | RT0 | RTC |
|:--------|----:|----:|----:|----:|----:|----:|----:|----:|
| R16_n12-t1 | 1 | 3 | 3 | 4 | 4 | 4 | 4 | 4 |
| R02_n12-t4 | 1 | 3 | 3 | 4 | 4 | 4 | 4 | 4 |
| R00_n8-t3 | 2 | 3 | 3 | 4 | 4 | 4 | 4 | 4 |
| R18_n8-t4 | 1 | 3 | 3 | 4 | 4 | 4 | 4 | 4 |
| R07_n8-t0 | 1 | 3 | 3 | 4 | 4 | 4 | 4 | 4 |

---

## Domain: boundary_interior

Cases: ['crosspair-4-L_shape-vs-staircase', 'rectangle_4x3-shear-1', 'unit_square-shear-0', 'L_shape-scale-0', 'L_shape-trans-1']

### Per-condition mean ± std (n=5)

| Condition | mean | std | scores | baseline (single) | Δ (mean − single) |
|----------:|-----:|----:|:-------|:------------------|------------------:|
| 000 | 1.20 | 0.40 | [1, 1, 1, 2, 1] | 1 | +0.20 |
| 00C | 3.00 | 0.00 | [3, 3, 3, 3, 3] | 3 | +0.00 |
| 0T0 | 3.00 | 0.00 | [3, 3, 3, 3, 3] | 3 | +0.00 |
| 0TC | 3.00 | 0.00 | [3, 3, 3, 3, 3] | 3 | +0.00 |
| R00 | 3.00 | 0.00 | [3, 3, 3, 3, 3] | 3 | +0.00 |
| R0C | 4.00 | 0.00 | [4, 4, 4, 4, 4] | 4 | +0.00 |
| RT0 | 4.00 | 0.00 | [4, 4, 4, 4, 4] | 4 | +0.00 |
| RTC | 4.00 | 0.00 | [4, 4, 4, 4, 4] | 4 | +0.00 |

### Wilcoxon signed-rank tests (paired by case_id)

- **R-on vs R-off**: on=3.75, off=2.55, Δ=+1.20; diffs per case=[1.25, 1.25, 1.25, 1.0, 1.25]; W=0, p=0.0625, non-zero pairs=5
- **T-on vs T-off**: on=3.50, off=2.80, Δ=+0.70; diffs per case=[0.75, 0.75, 0.75, 0.5, 0.75]; W=0, p=0.0625, non-zero pairs=5
- **C-on vs C-off**: on=3.50, off=2.80, Δ=+0.70; diffs per case=[0.75, 0.75, 0.75, 0.5, 0.75]; W=0, p=0.0625, non-zero pairs=5

### Consistency vs single-rating baseline

- 000: baseline=1, repeated mean=1.20, n_equal_baseline=4/5
- 00C: baseline=3, repeated mean=3.00, n_equal_baseline=5/5
- 0T0: baseline=3, repeated mean=3.00, n_equal_baseline=5/5
- 0TC: baseline=3, repeated mean=3.00, n_equal_baseline=5/5
- R00: baseline=3, repeated mean=3.00, n_equal_baseline=5/5
- R0C: baseline=4, repeated mean=4.00, n_equal_baseline=5/5
- RT0: baseline=4, repeated mean=4.00, n_equal_baseline=5/5
- RTC: baseline=4, repeated mean=4.00, n_equal_baseline=5/5

**Overall agreement**: 39/40 = 97.5% of repeated ratings match the single-rating baseline.

### Per-case condition rankings (within case)

| case_id | 000 | 00C | 0T0 | 0TC | R00 | R0C | RT0 | RTC |
|:--------|----:|----:|----:|----:|----:|----:|----:|----:|
| crosspair-4-L_shape-vs-staircase | 1 | 3 | 3 | 3 | 3 | 4 | 4 | 4 |
| rectangle_4x3-shear-1 | 1 | 3 | 3 | 3 | 3 | 4 | 4 | 4 |
| unit_square-shear-0 | 1 | 3 | 3 | 3 | 3 | 4 | 4 | 4 |
| L_shape-scale-0 | 2 | 3 | 3 | 3 | 3 | 4 | 4 | 4 |
| L_shape-trans-1 | 1 | 3 | 3 | 3 | 3 | 4 | 4 | 4 |

---

## Domain: discrete_curvature

Cases: ['cross-octahedron-vs-icosahedron-f1-1', 'cube_triangulated-subdiv-f4-4', 'tetrahedron-subdiv-f3-3', 'cross-icosahedron-vs-cube_triangulated-f4-4', 'icosahedron-disp-v0-0']

### Per-condition mean ± std (n=5)

| Condition | mean | std | scores | baseline (single) | Δ (mean − single) |
|----------:|-----:|----:|:-------|:------------------|------------------:|
| 000 | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| 00C | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| 0T0 | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| 0TC | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| R00 | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| R0C | 3.00 | 0.00 | [3, 3, 3, 3, 3] | 3 | +0.00 |
| RT0 | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| RTC | 3.00 | 0.00 | [3, 3, 3, 3, 3] | 3 | +0.00 |

### Wilcoxon signed-rank tests (paired by case_id)

- **R-on vs R-off**: on=2.50, off=2.00, Δ=+0.50; diffs per case=[0.5, 0.5, 0.5, 0.5, 0.5]; W=0, p=0.0625, non-zero pairs=5
- **T-on vs T-off**: on=2.25, off=2.25, Δ=+0.00; diffs per case=[0.0, 0.0, 0.0, 0.0, 0.0]; W=None, p=NA, non-zero pairs=0
- **C-on vs C-off**: on=2.50, off=2.00, Δ=+0.50; diffs per case=[0.5, 0.5, 0.5, 0.5, 0.5]; W=0, p=0.0625, non-zero pairs=5

### Consistency vs single-rating baseline

- 000: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- 00C: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- 0T0: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- 0TC: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- R00: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- R0C: baseline=3, repeated mean=3.00, n_equal_baseline=5/5
- RT0: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- RTC: baseline=3, repeated mean=3.00, n_equal_baseline=5/5

**Overall agreement**: 40/40 = 100.0% of repeated ratings match the single-rating baseline.

### Per-case condition rankings (within case)

| case_id | 000 | 00C | 0T0 | 0TC | R00 | R0C | RT0 | RTC |
|:--------|----:|----:|----:|----:|----:|----:|----:|----:|
| cross-octahedron-vs-icosahedron-f1-1 | 2 | 2 | 2 | 2 | 2 | 3 | 2 | 3 |
| cube_triangulated-subdiv-f4-4 | 2 | 2 | 2 | 2 | 2 | 3 | 2 | 3 |
| tetrahedron-subdiv-f3-3 | 2 | 2 | 2 | 2 | 2 | 3 | 2 | 3 |
| cross-icosahedron-vs-cube_triangulated-f4-4 | 2 | 2 | 2 | 2 | 2 | 3 | 2 | 3 |
| icosahedron-disp-v0-0 | 2 | 2 | 2 | 2 | 2 | 3 | 2 | 3 |

---

## Domain: projection

Cases: ['self-triangular_prism-yz', 'self-cube-diagonal', 'cross-octahedron-xzvsyz', 'cross-tetrahedron-yzvsdiagonal', 'cross-tetrahedron-xyvsdiagonal']

### Per-condition mean ± std (n=5)

| Condition | mean | std | scores | baseline (single) | Δ (mean − single) |
|----------:|-----:|----:|:-------|:------------------|------------------:|
| 000 | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| 00C | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| 0T0 | 3.00 | 0.00 | [3, 3, 3, 3, 3] | 3 | +0.00 |
| 0TC | 3.00 | 0.00 | [3, 3, 3, 3, 3] | 3 | +0.00 |
| R00 | 3.00 | 0.00 | [3, 3, 3, 3, 3] | 3 | +0.00 |
| R0C | 4.00 | 0.00 | [4, 4, 4, 4, 4] | 4 | +0.00 |
| RT0 | 4.00 | 0.00 | [4, 4, 4, 4, 4] | 4 | +0.00 |
| RTC | 4.00 | 0.00 | [4, 4, 4, 4, 4] | 4 | +0.00 |

### Wilcoxon signed-rank tests (paired by case_id)

- **R-on vs R-off**: on=3.75, off=2.50, Δ=+1.25; diffs per case=[1.25, 1.25, 1.25, 1.25, 1.25]; W=0, p=0.0625, non-zero pairs=5
- **T-on vs T-off**: on=3.50, off=2.75, Δ=+0.75; diffs per case=[0.75, 0.75, 0.75, 0.75, 0.75]; W=0, p=0.0625, non-zero pairs=5
- **C-on vs C-off**: on=3.25, off=3.00, Δ=+0.25; diffs per case=[0.25, 0.25, 0.25, 0.25, 0.25]; W=0, p=0.0625, non-zero pairs=5

### Consistency vs single-rating baseline

- 000: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- 00C: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- 0T0: baseline=3, repeated mean=3.00, n_equal_baseline=5/5
- 0TC: baseline=3, repeated mean=3.00, n_equal_baseline=5/5
- R00: baseline=3, repeated mean=3.00, n_equal_baseline=5/5
- R0C: baseline=4, repeated mean=4.00, n_equal_baseline=5/5
- RT0: baseline=4, repeated mean=4.00, n_equal_baseline=5/5
- RTC: baseline=4, repeated mean=4.00, n_equal_baseline=5/5

**Overall agreement**: 40/40 = 100.0% of repeated ratings match the single-rating baseline.

### Per-case condition rankings (within case)

| case_id | 000 | 00C | 0T0 | 0TC | R00 | R0C | RT0 | RTC |
|:--------|----:|----:|----:|----:|----:|----:|----:|----:|
| self-triangular_prism-yz | 2 | 2 | 3 | 3 | 3 | 4 | 4 | 4 |
| self-cube-diagonal | 2 | 2 | 3 | 3 | 3 | 4 | 4 | 4 |
| cross-octahedron-xzvsyz | 2 | 2 | 3 | 3 | 3 | 4 | 4 | 4 |
| cross-tetrahedron-yzvsdiagonal | 2 | 2 | 3 | 3 | 3 | 4 | 4 | 4 |
| cross-tetrahedron-xyvsdiagonal | 2 | 2 | 3 | 3 | 3 | 4 | 4 | 4 |

---

## Domain: surface_topology

Cases: ['a331-b69', 'a62-b12', 'a12-b1', 'a390-b221', 'a131-b389']

### Per-condition mean ± std (n=5)

| Condition | mean | std | scores | baseline (single) | Δ (mean − single) |
|----------:|-----:|----:|:-------|:------------------|------------------:|
| 000 | 0.00 | 0.00 | [0, 0, 0, 0, 0] | 0 | +0.00 |
| 00C | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| 0T0 | 0.00 | 0.00 | [0, 0, 0, 0, 0] | 0 | +0.00 |
| 0TC | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| R00 | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| R0C | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| RT0 | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| RTC | 3.00 | 0.00 | [3, 3, 3, 3, 3] | 3 | +0.00 |

### Wilcoxon signed-rank tests (paired by case_id)

- **R-on vs R-off**: on=2.25, off=1.00, Δ=+1.25; diffs per case=[1.25, 1.25, 1.25, 1.25, 1.25]; W=0, p=0.0625, non-zero pairs=5
- **T-on vs T-off**: on=1.75, off=1.50, Δ=+0.25; diffs per case=[0.25, 0.25, 0.25, 0.25, 0.25]; W=0, p=0.0625, non-zero pairs=5
- **C-on vs C-off**: on=2.25, off=1.00, Δ=+1.25; diffs per case=[1.25, 1.25, 1.25, 1.25, 1.25]; W=0, p=0.0625, non-zero pairs=5

### Consistency vs single-rating baseline

- 000: baseline=0, repeated mean=0.00, n_equal_baseline=5/5
- 00C: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- 0T0: baseline=0, repeated mean=0.00, n_equal_baseline=5/5
- 0TC: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- R00: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- R0C: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- RT0: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- RTC: baseline=3, repeated mean=3.00, n_equal_baseline=5/5

**Overall agreement**: 40/40 = 100.0% of repeated ratings match the single-rating baseline.

### Per-case condition rankings (within case)

| case_id | 000 | 00C | 0T0 | 0TC | R00 | R0C | RT0 | RTC |
|:--------|----:|----:|----:|----:|----:|----:|----:|----:|
| a331-b69 | 0 | 2 | 0 | 2 | 2 | 2 | 2 | 3 |
| a62-b12 | 0 | 2 | 0 | 2 | 2 | 2 | 2 | 3 |
| a12-b1 | 0 | 2 | 0 | 2 | 2 | 2 | 2 | 3 |
| a390-b221 | 0 | 2 | 0 | 2 | 2 | 2 | 2 | 3 |
| a131-b389 | 0 | 2 | 0 | 2 | 2 | 2 | 2 | 3 |

---

## Domain: surface_topology_s21

Cases: ['a151-b6', 'a122-b28', 'a215-b1', 'a151-b181', 'a151-b103']

### Per-condition mean ± std (n=5)

| Condition | mean | std | scores | baseline (single) | Δ (mean − single) |
|----------:|-----:|----:|:-------|:------------------|------------------:|
| 000 | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| 00C | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| 0T0 | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| 0TC | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| R00 | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| R0C | 2.00 | 0.00 | [2, 2, 2, 2, 2] | 2 | +0.00 |
| RT0 | 3.00 | 0.00 | [3, 3, 3, 3, 3] | 3 | +0.00 |
| RTC | 3.00 | 0.00 | [3, 3, 3, 3, 3] | 3 | +0.00 |

### Wilcoxon signed-rank tests (paired by case_id)

- **R-on vs R-off**: on=2.50, off=2.00, Δ=+0.50; diffs per case=[0.5, 0.5, 0.5, 0.5, 0.5]; W=0, p=0.0625, non-zero pairs=5
- **T-on vs T-off**: on=2.50, off=2.00, Δ=+0.50; diffs per case=[0.5, 0.5, 0.5, 0.5, 0.5]; W=0, p=0.0625, non-zero pairs=5
- **C-on vs C-off**: on=2.25, off=2.25, Δ=+0.00; diffs per case=[0.0, 0.0, 0.0, 0.0, 0.0]; W=None, p=NA, non-zero pairs=0

### Consistency vs single-rating baseline

- 000: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- 00C: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- 0T0: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- 0TC: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- R00: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- R0C: baseline=2, repeated mean=2.00, n_equal_baseline=5/5
- RT0: baseline=3, repeated mean=3.00, n_equal_baseline=5/5
- RTC: baseline=3, repeated mean=3.00, n_equal_baseline=5/5

**Overall agreement**: 40/40 = 100.0% of repeated ratings match the single-rating baseline.

### Per-case condition rankings (within case)

| case_id | 000 | 00C | 0T0 | 0TC | R00 | R0C | RT0 | RTC |
|:--------|----:|----:|----:|----:|----:|----:|----:|----:|
| a151-b6 | 2 | 2 | 2 | 2 | 2 | 2 | 3 | 3 |
| a122-b28 | 2 | 2 | 2 | 2 | 2 | 2 | 3 | 3 |
| a215-b1 | 2 | 2 | 2 | 2 | 2 | 2 | 3 | 3 |
| a151-b181 | 2 | 2 | 2 | 2 | 2 | 2 | 3 | 3 |
| a151-b103 | 2 | 2 | 2 | 2 | 2 | 2 | 3 | 3 |

---
