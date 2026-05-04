# CoE Reasoning Benchmark — Dimension × Condition Summary

Self-administered by Claude (Opus 4.7, 1M context). Each question has 3 sub-parts; per-question rubric is 0–4 (see scoring spec). Rows: dimension; columns: condition.

## Mean rubric per (dimension, condition)

| Dimension | n | baseline | cot | coe_r | coe_ctr |
|---|---|---|---|---|---|
| Dim 1 (invariants — knot) | 16 | 4.00 | 4.00 | 4.00 | 4.00 |
| Dim 2 (graph connectivity) | 16 | 4.00 | 4.00 | 4.00 | 4.00 |
| Dim 3 (discrete curvature) | 16 | 4.00 | 4.00 | 4.00 | 4.00 |
| Dim 4 (symmetry / Burnside) | 18 | 4.00 | 4.00 | 4.00 | 4.00 |
| Dim 5 (projection) | 16 | 3.50 | 3.50 | 4.00 | 4.00 |
| Dim 6 (boundary / Pick) | 16 | 4.00 | 4.00 | 4.00 | 4.00 |

## Sub-question accuracy per (dimension, condition)

| Dimension | n | baseline | cot | coe_r | coe_ctr |
|---|---|---|---|---|---|
| Dim 1 (invariants — knot) | 16 | 100.0% | 100.0% | 100.0% | 100.0% |
| Dim 2 (graph connectivity) | 16 | 100.0% | 100.0% | 100.0% | 100.0% |
| Dim 3 (discrete curvature) | 16 | 100.0% | 100.0% | 100.0% | 100.0% |
| Dim 4 (symmetry / Burnside) | 18 | 100.0% | 100.0% | 100.0% | 100.0% |
| Dim 5 (projection) | 16 | 85.4% | 85.4% | 100.0% | 100.0% |
| Dim 6 (boundary / Pick) | 16 | 100.0% | 100.0% | 100.0% | 100.0% |

## Per-question rubric details

| Dimension | Question | Type | base | cot | coe_r | coe_ctr |
|---|---|---|---|---|---|---|
| Dim 1 (invariants — knot) | dim1_q01 | invariant_change | 4 | 4 | 4 | 4 |
| Dim 1 (invariants — knot) | dim1_q02 | invariant_change | 4 | 4 | 4 | 4 |
| Dim 1 (invariants — knot) | dim1_q03 | invariant_change | 4 | 4 | 4 | 4 |
| Dim 1 (invariants — knot) | dim1_q04 | invariant_change | 4 | 4 | 4 | 4 |
| Dim 1 (invariants — knot) | dim1_q05 | invariant_change | 4 | 4 | 4 | 4 |
| Dim 1 (invariants — knot) | dim1_q06 | invariant_change | 4 | 4 | 4 | 4 |
| Dim 1 (invariants — knot) | dim1_q07 | invariant_change | 4 | 4 | 4 | 4 |
| Dim 1 (invariants — knot) | dim1_q08 | invariant_change | 4 | 4 | 4 | 4 |
| Dim 1 (invariants — knot) | dim1_q09 | invariant_change | 4 | 4 | 4 | 4 |
| Dim 1 (invariants — knot) | dim1_q10 | invariant_change | 4 | 4 | 4 | 4 |
| Dim 1 (invariants — knot) | dim1_q11 | invariant_change | 4 | 4 | 4 | 4 |
| Dim 1 (invariants — knot) | dim1_q12 | invariant_change | 4 | 4 | 4 | 4 |
| Dim 1 (invariants — knot) | dim1_q13 | invariant_change | 4 | 4 | 4 | 4 |
| Dim 1 (invariants — knot) | dim1_q14 | invariant_change | 4 | 4 | 4 | 4 |
| Dim 1 (invariants — knot) | dim1_q15 | invariant_change | 4 | 4 | 4 | 4 |
| Dim 1 (invariants — knot) | dim1_q16 | invariant_change | 4 | 4 | 4 | 4 |
| Dim 2 (graph connectivity) | dim2_q01 | bridge_test | 4 | 4 | 4 | 4 |
| Dim 2 (graph connectivity) | dim2_q02 | bridge_test | 4 | 4 | 4 | 4 |
| Dim 2 (graph connectivity) | dim2_q03 | bridge_test | 4 | 4 | 4 | 4 |
| Dim 2 (graph connectivity) | dim2_q04 | bridge_test | 4 | 4 | 4 | 4 |
| Dim 2 (graph connectivity) | dim2_q05 | bridge_test | 4 | 4 | 4 | 4 |
| Dim 2 (graph connectivity) | dim2_q06 | bridge_test | 4 | 4 | 4 | 4 |
| Dim 2 (graph connectivity) | dim2_q07 | bridge_test | 4 | 4 | 4 | 4 |
| Dim 2 (graph connectivity) | dim2_q08 | bridge_test | 4 | 4 | 4 | 4 |
| Dim 2 (graph connectivity) | dim2_q09 | global_topology | 4 | 4 | 4 | 4 |
| Dim 2 (graph connectivity) | dim2_q10 | global_topology | 4 | 4 | 4 | 4 |
| Dim 2 (graph connectivity) | dim2_q11 | global_topology | 4 | 4 | 4 | 4 |
| Dim 2 (graph connectivity) | dim2_q12 | global_topology | 4 | 4 | 4 | 4 |
| Dim 2 (graph connectivity) | dim2_q13 | global_topology | 4 | 4 | 4 | 4 |
| Dim 2 (graph connectivity) | dim2_q14 | global_topology | 4 | 4 | 4 | 4 |
| Dim 2 (graph connectivity) | dim2_q15 | global_topology | 4 | 4 | 4 | 4 |
| Dim 2 (graph connectivity) | dim2_q16 | global_topology | 4 | 4 | 4 | 4 |
| Dim 3 (discrete curvature) | dim3_q01 | chi_genus | 4 | 4 | 4 | 4 |
| Dim 3 (discrete curvature) | dim3_q02 | chi_genus | 4 | 4 | 4 | 4 |
| Dim 3 (discrete curvature) | dim3_q03 | chi_genus | 4 | 4 | 4 | 4 |
| Dim 3 (discrete curvature) | dim3_q04 | chi_genus | 4 | 4 | 4 | 4 |
| Dim 3 (discrete curvature) | dim3_q05 | chi_genus | 4 | 4 | 4 | 4 |
| Dim 3 (discrete curvature) | dim3_q06 | chi_genus | 4 | 4 | 4 | 4 |
| Dim 3 (discrete curvature) | dim3_q07 | chi_genus | 4 | 4 | 4 | 4 |
| Dim 3 (discrete curvature) | dim3_q08 | chi_genus | 4 | 4 | 4 | 4 |
| Dim 3 (discrete curvature) | dim3_q09 | invariance | 4 | 4 | 4 | 4 |
| Dim 3 (discrete curvature) | dim3_q10 | invariance | 4 | 4 | 4 | 4 |
| Dim 3 (discrete curvature) | dim3_q11 | invariance | 4 | 4 | 4 | 4 |
| Dim 3 (discrete curvature) | dim3_q12 | invariance | 4 | 4 | 4 | 4 |
| Dim 3 (discrete curvature) | dim3_q13 | invariance | 4 | 4 | 4 | 4 |
| Dim 3 (discrete curvature) | dim3_q14 | invariance | 4 | 4 | 4 | 4 |
| Dim 3 (discrete curvature) | dim3_q15 | invariance | 4 | 4 | 4 | 4 |
| Dim 3 (discrete curvature) | dim3_q16 | invariance | 4 | 4 | 4 | 4 |
| Dim 4 (symmetry / Burnside) | dim4_q01 | orbit_stabilizer | 4 | 4 | 4 | 4 |
| Dim 4 (symmetry / Burnside) | dim4_q02 | orbit_stabilizer | 4 | 4 | 4 | 4 |
| Dim 4 (symmetry / Burnside) | dim4_q03 | orbit_stabilizer | 4 | 4 | 4 | 4 |
| Dim 4 (symmetry / Burnside) | dim4_q04 | orbit_stabilizer | 4 | 4 | 4 | 4 |
| Dim 4 (symmetry / Burnside) | dim4_q05 | orbit_stabilizer | 4 | 4 | 4 | 4 |
| Dim 4 (symmetry / Burnside) | dim4_q06 | group_switch | 4 | 4 | 4 | 4 |
| Dim 4 (symmetry / Burnside) | dim4_q07 | group_switch | 4 | 4 | 4 | 4 |
| Dim 4 (symmetry / Burnside) | dim4_q08 | group_switch | 4 | 4 | 4 | 4 |
| Dim 4 (symmetry / Burnside) | dim4_q09 | group_switch | 4 | 4 | 4 | 4 |
| Dim 4 (symmetry / Burnside) | dim4_q10 | equivalence_pair | 4 | 4 | 4 | 4 |
| Dim 4 (symmetry / Burnside) | dim4_q11 | equivalence_pair | 4 | 4 | 4 | 4 |
| Dim 4 (symmetry / Burnside) | dim4_q12 | equivalence_pair | 4 | 4 | 4 | 4 |
| Dim 4 (symmetry / Burnside) | dim4_q13 | equivalence_pair | 4 | 4 | 4 | 4 |
| Dim 4 (symmetry / Burnside) | dim4_q14 | burnside_reasoning | 4 | 4 | 4 | 4 |
| Dim 4 (symmetry / Burnside) | dim4_q15 | burnside_reasoning | 4 | 4 | 4 | 4 |
| Dim 4 (symmetry / Burnside) | dim4_q16 | burnside_reasoning | 4 | 4 | 4 | 4 |
| Dim 4 (symmetry / Burnside) | dim4_q17 | burnside_reasoning | 4 | 4 | 4 | 4 |
| Dim 4 (symmetry / Burnside) | dim4_q18 | burnside_reasoning | 4 | 4 | 4 | 4 |
| Dim 5 (projection) | dim5_q01 | projection_loss | 3 | 3 | 4 | 4 |
| Dim 5 (projection) | dim5_q02 | projection_loss | 0 | 0 | 4 | 4 |
| Dim 5 (projection) | dim5_q03 | projection_loss | 4 | 4 | 4 | 4 |
| Dim 5 (projection) | dim5_q04 | projection_loss | 4 | 4 | 4 | 4 |
| Dim 5 (projection) | dim5_q05 | projection_loss | 4 | 4 | 4 | 4 |
| Dim 5 (projection) | dim5_q06 | projection_loss | 2 | 2 | 4 | 4 |
| Dim 5 (projection) | dim5_q07 | projection_loss | 4 | 4 | 4 | 4 |
| Dim 5 (projection) | dim5_q08 | projection_loss | 3 | 3 | 4 | 4 |
| Dim 5 (projection) | dim5_q09 | diameter_compare | 4 | 4 | 4 | 4 |
| Dim 5 (projection) | dim5_q10 | diameter_compare | 4 | 4 | 4 | 4 |
| Dim 5 (projection) | dim5_q11 | diameter_compare | 4 | 4 | 4 | 4 |
| Dim 5 (projection) | dim5_q12 | diameter_compare | 4 | 4 | 4 | 4 |
| Dim 5 (projection) | dim5_q13 | diameter_compare | 4 | 4 | 4 | 4 |
| Dim 5 (projection) | dim5_q14 | diameter_compare | 4 | 4 | 4 | 4 |
| Dim 5 (projection) | dim5_q15 | diameter_compare | 4 | 4 | 4 | 4 |
| Dim 5 (projection) | dim5_q16 | diameter_compare | 4 | 4 | 4 | 4 |
| Dim 6 (boundary / Pick) | dim6_q01 | pick_basics | 4 | 4 | 4 | 4 |
| Dim 6 (boundary / Pick) | dim6_q02 | pick_basics | 4 | 4 | 4 | 4 |
| Dim 6 (boundary / Pick) | dim6_q03 | pick_basics | 4 | 4 | 4 | 4 |
| Dim 6 (boundary / Pick) | dim6_q04 | pick_basics | 4 | 4 | 4 | 4 |
| Dim 6 (boundary / Pick) | dim6_q05 | pick_basics | 4 | 4 | 4 | 4 |
| Dim 6 (boundary / Pick) | dim6_q06 | pick_basics | 4 | 4 | 4 | 4 |
| Dim 6 (boundary / Pick) | dim6_q07 | pick_basics | 4 | 4 | 4 | 4 |
| Dim 6 (boundary / Pick) | dim6_q08 | pick_basics | 4 | 4 | 4 | 4 |
| Dim 6 (boundary / Pick) | dim6_q09 | perturbation | 4 | 4 | 4 | 4 |
| Dim 6 (boundary / Pick) | dim6_q10 | perturbation | 4 | 4 | 4 | 4 |
| Dim 6 (boundary / Pick) | dim6_q11 | perturbation | 4 | 4 | 4 | 4 |
| Dim 6 (boundary / Pick) | dim6_q12 | perturbation | 4 | 4 | 4 | 4 |
| Dim 6 (boundary / Pick) | dim6_q13 | perturbation | 4 | 4 | 4 | 4 |
| Dim 6 (boundary / Pick) | dim6_q14 | perturbation | 4 | 4 | 4 | 4 |
| Dim 6 (boundary / Pick) | dim6_q15 | perturbation | 4 | 4 | 4 | 4 |
| Dim 6 (boundary / Pick) | dim6_q16 | perturbation | 4 | 4 | 4 | 4 |
