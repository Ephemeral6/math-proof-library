# Step 5 — surgery validation on non-chordal (α, β) pairs of S_{1,2}

- Non-chordal α count: **12**
- Total (α, β) pairs analysed: **99**
- Pairs in induced 4-cycle: **60**
- net_change == 0: **99/99** (PASS)

## i(α, β) distribution

| pre_i | count |
|---|---|
| 0 | 12 |
| 1 | 87 |

## i(σ, β) distribution

| post_i | count |
|---|---|
| 0 | 12 |
| 1 | 87 |

## Per-α summary

| α | k | f(σ) | DL size | induced 4-cycle β count | net=0 |
|---|---|---|---|---|---|
| 38 | 4 | 2 | 9 | 5 | 9/9 |
| 88 | 6 | 2 | 9 | 5 | 9/9 |
| 105 | 4 | 2 | 8 | 5 | 8/8 |
| 117 | 4 | 2 | 8 | 5 | 8/8 |
| 118 | 5 | 3 | 8 | 5 | 8/8 |
| 119 | 4 | 2 | 8 | 5 | 8/8 |
| 186 | 6 | 4 | 8 | 5 | 8/8 |
| 236 | 8 | 2 | 9 | 5 | 9/9 |
| 253 | 6 | 2 | 8 | 5 | 8/8 |
| 268 | 6 | 2 | 8 | 5 | 8/8 |
| 269 | 7 | 3 | 8 | 5 | 8/8 |
| 270 | 6 | 2 | 8 | 5 | 8/8 |

## Note on short/long arc triangles

The σ_α found by `SurfaceGeo.cut_glue` (search-fallback) is the canonical Hatcher filler matched against the curve database — not a literal weight-additive surgical result. As a consequence its train-track weight is globally smaller than α (since it sits at level f(σ) ≤ k − 2). The `long_arc_triangles` field, defined as triangles where σ has *more* normal-arc bundles than α, will typically be empty; `short_arc_triangles` covers all triangles where α has more bundles than σ. This is a **finding**: the canonical filler search produces a curve that satisfies the surgery acceptance criteria (disjoint from α, level ≤ k−2, universal on the descending link) without being a literal weight-additive Hatcher replacement.
