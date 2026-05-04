# SurfaceGeo Rich Geometry Extension — Final Report

**Date:** 2026-05-01
**Surface tested:** S_{1,2} (genus-1, doubly-punctured torus; 4 triangles, 6 unsigned edges, 2 puncture-vertices)
**curver version:** 0.5.1

---

## Status table

| Functionality                               | Status       | LOC  | Notes |
|---------------------------------------------|--------------|------|-------|
| Step 1 — curver API audit                   | **DONE**     | —    | Report at `audit/step1_curver_api.md`. curver exposes triangulation, weights, lookups, and exact i(α,β); does NOT expose per-crossing locations or surgery primitives. |
| `decompose_curve` (per-triangle Bonahon arcs) | **DONE**   | ~50  | Built on existing `surface_geo._passage_counts`. Self-test verifies sum(mult) = sum(weights). |
| `find_crossings`                            | **DONE**     | ~50  | Returns candidate per-triangle (α-arc, β-arc) crossings. Upper bound on geometric intersection (some cancel via bigons). |
| `trace_surgery`                             | **DONE**     | ~70  | Records α-γ₀ candidate crossings + surgery region (triangles where α and γ₀ coexist) + per-triangle weight delta short/long arc triangles + puncture count. |
| `analyze_surgery_intersection`              | **DONE**     | ~75  | Compares (α, β) ↔ (σ, β) crossings, partitions in/out of region, tracks β's overlap with surgery region. |
| `detect_bigons`                             | **DONE**     | ~50  | Heuristic: pairs of candidate crossings in adjacent triangles sharing an edge that all four arcs cross. |
| 99-pair full-DL validation                  | **PASS**     | —    | All 99 (α, β) DL pairs have `net_change == 0`. 60 of those are in induced 4-cycles. |
| 5 benchmark JSONs                           | **DONE**     | ~200 | `benchmark/benchmark_{1..5}_*.json` |

---

## curver API support summary (from Step 1)

| Datum                                    | curver direct? | How |
|------------------------------------------|----------------|-----|
| Triangle list                            | ✓              | `T.triangles` |
| Edges per triangle (unsigned)            | ✓              | `tri.indices` |
| Signed-edge → triangle / vertex          | ✓              | `T.triangle_lookup`, `T.vertex_lookup` |
| Train-track weight on edge e             | ✓              | `tuple(curve)[e]` or `c.geometric` |
| Per-triangle dual-edge weight            | ✓              | `c.dual_weight(edge, double=True)` |
| Per-triangle (α,β) candidate crossings   | ✗ (compute)    | Bonahon `n_{ij} = max(0, (w_i+w_j-w_k)//2)` |
| Cyclic triangle path of a curve          | ✗ (compute)    | stitch arcs across shared edges (deferred) |
| Geometric i(α,β) (exact)                 | ✓              | `α.intersection(β)` — uses Mosher shorten |
| Hatcher α-on-γ₀ surgery                  | ✗ (DIY)        | Reused existing `SurfaceGeo.cut_glue` (search-fallback in curve database) |
| Bigon detection                          | ✗ (compute)    | New `detect_bigons` — pairs of candidate crossings in adjacent triangles |

**Key insight from audit**: curver computes i(α,β) by reducing to a parallel-component form via `shorten()` rather than enumerating crossings on the static triangulation. Per-crossing geometric data therefore must be reconstructed by us. The candidate-crossing list is an *upper bound* on true crossings; the deficit equals the number of bigons cancelled by reduction.

---

## Validation result

**99/99 pairs pass `net_change == 0`.**

| Bucket                                | count |
|---------------------------------------|-------|
| Non-chordal α (k = 4..8)              | 12    |
| Total (α, β) pairs in their DLs       | 99    |
| Pairs participating in induced 4-cycle| 60    |
| Pairs with `net_change == 0`          | **99/99** |
| Distribution of pre i(α, β)           | 12 with 0, 87 with 1 |
| Distribution of post i(σ, β)          | 12 with 0, 87 with 1 |

The post-distribution **equals** the pre-distribution pointwise — not just net_change=0 but i(σ, β) = i(α, β) for every pair. This is a stronger property than the user spec demanded, and a clean target for the agent to discover.

> Note on user spec: the task description mentioned "6 non-chordal DLs / 49 pairs". Empirical enumeration finds 12 non-chordal α and 99 DL pairs (60 in induced 4-cycles). The earlier 49 number likely came from MCG-orbit deduplication of the cycles. The conservation property holds on the full set, which is more.

---

## Counterfactual finding

For α=38 we found 6 β with i(α, β) = 2 (β NOT in α's descending link):

| pair | i(α,β) | i(σ,β) | net |
|------|--------|--------|-----|
| a38-cf-b2  | 2 | 2 | 0  |
| a38-cf-b3  | 2 | 2 | 0  |
| a38-cf-b9  | 2 | 2 | 0  |
| **a38-cf-b13** | **2** | **0** | **−2** |
| a38-cf-b20 | 2 | 2 | 0  |
| a38-cf-b30 | 2 | 2 | 0  |

Pair `a38-cf-b13` exhibits **net_change = −2**, demonstrating that the conservation property fails outside the descending link (i.e., when `i(α, β) ≥ 2`). This is the counterfactual the benchmark needs: an agent who hypothesises "i(σ, β) = i(α, β) always" should be falsified by this case.

---

## Note on weight-additive surgery

`σ_α` produced by `SurfaceGeo.cut_glue` (search-fallback in curve database) is the canonical Hatcher filler — disjoint from α, level ≤ k − 2, universal on the descending link — but it is **not** a literal weight-additive Hatcher replacement. As a consequence, in 12 of 12 cases we have train-track weight `||σ|| < ||α||` globally, so `long_arc_triangles` (triangles where σ has *more* normal-arc bundles than α) is empty. `short_arc_triangles` covers all triangles where the bundle count decreased.

This is consistent with §11.8.5(a) of the OP-1 manuscript: the existence of a level-(k − 2) filler is what's required, not an explicit train-track-additive surgery. An agent reasoning from the benchmark must account for this — surgery on the curve complex is a topological operation, not literal arithmetic on edge weights.

---

## Benchmark files (Step 6)

All in `workspace/projects/op1_geometry/benchmark/`:

| File                                    | Size      | Adds |
|-----------------------------------------|-----------|------|
| `benchmark_1_numbers_only.json`         | 22 KB     | 99 pairs of `{i(α,β), i(σ,β), i(α,γ₀), i(σ,γ₀)}` only |
| `benchmark_2_crossing_locations.json`   | 945 KB    | + per-pair `pre_crossings`, `post_crossings`, full curve decompositions |
| `benchmark_3_surgery_region.json`       | 989 KB    | + surgery_region_triangles, surgery_region_punctures, β's overlap with region |
| `benchmark_4_bigons.json`               | 1.2 MB    | + detected bigons before & after surgery, candidate-crossing totals |
| `benchmark_5_with_counterfactual.json`  | 1.3 MB    | + 6 counterfactual i(α, β) = 2 pairs, including a `net=−2` example |

Each level subsumes the previous; the agent test-rig can pick the level that matches the difficulty step it's testing for.

---

## Files added in this op

```
workspace/projects/op1_geometry/
├── rich_geometry.py                        (new, ~530 LOC)
├── run_step5_validation.py                 (new, ~190 LOC)
├── run_step6_benchmarks.py                 (new, ~170 LOC)
├── audit/
│   ├── step1_curver_api.md                 (new)
│   ├── step5_validation_report.md          (new)
│   ├── surgery_analyses_full.json          (new — per-pair data)
│   └── final_report.md                     (this file)
└── benchmark/
    ├── benchmark_1_numbers_only.json       (new)
    ├── benchmark_2_crossing_locations.json (new)
    ├── benchmark_3_surgery_region.json     (new)
    ├── benchmark_4_bigons.json             (new)
    └── benchmark_5_with_counterfactual.json (new)
```

`surface_geo.py`'s `count_incidence` interface is unchanged; the new module
extends rather than replaces.
