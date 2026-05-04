# Step 1 — curver API audit (read-only)

**Environment:** curver 0.5.1 at
`C:\Users\12729\AppData\Local\Programs\Python\Python313\Lib\site-packages\curver`

**Surface used for probing:** `S = curver.load(1, 2)` — once-doubly-punctured torus
(`zeta = 6` unsigned edges, 4 triangles, 2 vertices).

---

## 1A. Triangulation (curver.kernel.Triangulation)

### Direct exposure

| Attribute / method        | Type   | Returns                                              |
|---------------------------|--------|------------------------------------------------------|
| `T.zeta`                  | int    | number of unsigned edges (= `S.zeta`)                |
| `T.num_triangles`         | int    | number of triangles                                  |
| `T.num_vertices`          | int    | number of vertices (= punctures, on a closed-up surface) |
| `T.triangles`             | list   | list of `Triangle` objects, each = ordered triple of signed edges |
| `T.indices`               | list   | unsigned edge indices `[0..zeta-1]`                  |
| `T.labels`                | list   | signed edge labels `[-zeta..-1, 0..zeta-1]` (`~i = -i-1`) |
| `T.positive_edges`        | list   | unsigned indices = positive labels                   |
| `T.edges`                 | list   | all `Edge` objects                                   |
| `T.vertices`              | set    | each vertex = cyclic tuple of signed edges around it (a "corner cycle") |
| `T.triangle_lookup[lbl]`  | dict   | signed edge → containing `Triangle`                  |
| `T.vertex_lookup[lbl]`    | dict   | signed edge → tail vertex (corner cycle)             |
| `T.corner_lookup[lbl]`    | dict   | signed edge → tuple of three signed edges of its corner |
| `T.is_flippable`          | method | edge flip availability                               |
| `T.encode_flip(e)`        | method | mapping class for a single flip                      |
| `T.euler_characteristic`  | int    | χ                                                    |

### Triangle object

`Triangle` exposes only three attributes:

```python
tri.edges   # list of 3 signed Edge objects (cyclic order)
tri.indices # list of 3 unsigned indices (= the unsigned edges of the triangle)
tri.labels  # list of 3 signed labels
```

There is **no** `Triangle.corners` and no per-corner-vertex pointer. To
obtain the vertex at a corner, use `T.vertex_lookup[signed_label]`, which
returns the corner cycle the *tail* of that signed edge sits at.

### Signed-edge convention

`~i` in display = signed label `-i-1`. So the unsigned edge `e ∈ [0, zeta)`
has two signed copies: `+e` (= label `e`) and `~e` (= label `-e-1`). Each
signed copy sits in exactly one triangle.

### Concrete S_{1,2} numbers

```
zeta = 6,  num_triangles = 4,  num_vertices = 2,  euler = -2
triangles = [(~5, ~2, ~0), (~4, ~3, 5), (~1, 3, 4), (0, 1, 2)]
vertices  = { (~3, 4),                                       # 2-gon  (puncture A)
              (~5, 0, ~2, 5, 3, 1, ~0, 2, ~1, ~4) }          # 10-gon (puncture B)
```

---

## 1B. Curves (`curver.kernel.Curve` ≤ `MultiCurve` ≤ `IntegralLamination` ≤ `Lamination`)

### Direct exposure

| Attribute / method         | Returns                                              |
|----------------------------|------------------------------------------------------|
| `tuple(c)` / `c.geometric` | the train-track edge-weight vector (length `zeta`)   |
| `c.weight()`               | `sum(weights)`                                       |
| `c.dual_weight(edge)`      | normal-arc count *dual* to the given signed edge (= count of arcs in the unique triangle containing that signed edge whose third edge is this one) |
| `c.dual_weight(e, double=True)` | sum of `dual_weight(+e)` + `dual_weight(~e)` (i.e., total dual arcs across both adjacent triangles) |
| `c.left_weight(edge)`      | per-side passage count along the signed edge (left side) |
| `c.right_weight(edge)`     | per-side passage count along the signed edge (right side) |
| `c.intersection(other)`    | exact geometric intersection number                  |
| `c.is_separating()`        | bool                                                 |
| `c.is_peripheral()`        | bool                                                 |
| `c.shorten(drop=0.1)`      | `(short_form, encoding)` — Mosher flip reduction     |
| `c.encode_twist(power=1)`  | mapping class of a Dehn twist around `c`             |
| `c.topological_type()`     | combinatorial signature                              |

### Verified train-track formula

For triangle `(a, b, c)` with weights `(w_a, w_b, w_c)`, the Bonahon
passage count from edge `i` to edge `j` (the count of normal arcs whose
endpoints lie on edges `i` and `j`) is:

```
n_{i,j} = max(0, (w_i + w_j - w_k) // 2)            where {i,j,k} = {a,b,c}
```

Verified against `c.dual_weight(k)` on `a_0` and `b_0` of S_{1,2} —
matches (modulo the per-side-vs-doubled distinction). The existing
`surface_geo._passage_counts(weights, triangle)` helper computes this
directly and is correct.

### What curver does NOT directly expose

- **The triangle-by-triangle path of a curve (an ordered cyclic sequence
  of triangles the curve visits).** Must be reconstructed by stitching
  adjacent normal arcs across shared edges.
- **Per-crossing locations of two curves.** `intersection()` is computed
  via `shorten()` (Mosher reduction to a parallel-component form), not
  by enumerating crossings on the original triangulation. We must
  reconstruct candidate crossings from per-triangle passage counts.

---

## 1C. Intersection implementation

```python
def intersection(self, *laminations):
    short, conjugator = self.shorten()
    short_laminations = [conjugator(L) for L in laminations]
    # ...sums contributions over peripheral and parallel components...
```

**Implication:** curver's intersection number is exact, but obtaining
*per-crossing geometric data* requires us to compute it ourselves from
the train-track decomposition. Since two curves α, β with
`i(α, β) = k` may have `> k` candidate crossings in the triangulation
(extra ones cancel pairwise via bigons), our reconstructed `crossings`
list is an **upper bound**; the true count is `i(α, β)`.

For the OP-1 benchmark, this is acceptable — Hatcher surgery cancels
exactly the bigons, so the *upper-bound* list is the correct geometric
ground-truth that an agent would see in a triangulation diagram.

---

## 1D. Surgery / twist primitives

| Primitive                   | Available?                                          |
|-----------------------------|-----------------------------------------------------|
| Dehn twist                  | ✓ `c.encode_twist(power)` — mapping class          |
| Half-twist                  | ✓ `curver.kernel.HalfTwist` (used in encodings)    |
| Apply mapping to lamination | ✓ `encoding(lamination)`                            |
| Hatcher α-on-γ₀ surgery     | ✗ — must DIY                                        |
| Bigon detection             | ✗ — must DIY                                        |

The existing `SurfaceGeo.cut_glue` already implements a working
search-based surgery (the search fallback is used in production —
all 12 non-chordal S_{1,2} DLs reproduce the canonical σ_α via the
attached curve database). Step 3 will reuse this infrastructure.

---

## 1E. Normal-arc decomposition — feasibility

| Datum                                            | curver direct? | how to obtain                          |
|--------------------------------------------------|----------------|----------------------------------------|
| List of triangles in triangulation               | ✓              | `T.triangles`, `T.indices`             |
| Edges of each triangle (unsigned)                | ✓              | `tri.indices`                          |
| Signed-edge → triangle                           | ✓              | `T.triangle_lookup`                    |
| Signed-edge → tail vertex                        | ✓              | `T.vertex_lookup`                      |
| Train-track weight on edge e                     | ✓              | `c.geometric[e]`                       |
| Per-triangle normal-arc count `n_{ij}`           | ✓ (compute)    | Bonahon formula                        |
| Per-triangle (curve-A,curve-B) candidate crossings | ✓ (compute)  | for each triangle, every (`n_{ij}^A` × `n_{kl}^B`) pair with `{i,j} ∩ {k,l} = 1` produces `min(...)` crossings |
| Cyclic triangle path of a single curve component | ✓ (compute, harder) | stitch arcs across shared edges, walking the cyclic order |
| Crossing sign (±1) in oriented context           | partial        | curve has no algebraic intersection on punctured surface in general; we'll fix a convention |
| Surgery region (between α-short-arc and γ₀-arc)  | ✓ (compute)    | the set of triangles enclosed; bounded by short_arc + γ₀_arc |
| Punctures inside surgery region                  | ✓ (compute)    | check `T.vertex_lookup` of bounding signed edges |
| Bigon detection                                  | ✓ (compute)    | bigon = pair of crossings (p,q) bounding a disk in two adjacent triangles |

---

## 1F. Verdict

curver gives us all the **raw structural data** we need (triangulation,
weights, lookups, intersection numbers). It does **not** give us
preprocessed crossing-location, surgery-region, or bigon data — those
must be reconstructed from the train-track decomposition.

**Plan for Step 2+:** build `rich_geometry.py` on top of the existing
`surface_geo._passage_counts` and `SurfaceGeo.cut_glue`, focusing on:

1. Stitching per-triangle normal arcs into cyclic triangle paths (curve
   walk).
2. Listing candidate crossings between two curves at the per-triangle
   level, yielding an upper bound on crossings (the true exact count is
   already `c.intersection(c')`).
3. Tracing surgery: identify two crossings of α with γ₀, the short and
   long subarcs of α, the corresponding γ₀ subarc, the enclosed
   surgery region (set of triangles + punctures).
4. Computing the "before vs after" of i(σ_α, β) and which crossings
   live on which subarc, plus where β enters/exits the surgery region.

No fundamental blocker. Reconstruction is mechanical from the train-track
weights and triangulation lookups.
