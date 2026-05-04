"""rich_geometry — extracts triangle-level geometric data from curver curves.

Layered on top of curver 0.5.1 and `surface_geo._passage_counts`.

Provided dataclasses (all JSON-friendly via .to_json()):
  TriangleInfo                — one triangle of the triangulation
  NormalArc                   — one normal-arc segment in one triangle
  CurveDecomposition          — a curve as per-triangle normal arcs + cyclic walk
  CrossingLocation            — one candidate (curve_a, curve_b) crossing
  DetailedIntersection        — full (α, β) crossing data + decompositions

Provided helpers:
  triangulation_info(S)       — list[TriangleInfo]
  decompose_curve(S, c, id)   — CurveDecomposition
  find_crossings(S, ca, cb, id_a, id_b) — DetailedIntersection
  edge_endpoints(S, c, e)     — ordered list of (arc_index, port) for edge e

Conventions:
  - Edge indices are unsigned (0 … zeta-1).
  - A `NormalArc` is identified within its triangle by (entry_edge, exit_edge),
    where `entry_edge < exit_edge` (unordered pair canonicalisation). The
    `multiplicity` is the train-track passage count `n_{entry,exit}`.
  - A "candidate crossing" is one pair (α-arc, β-arc) of normal arcs in the
    same triangle whose edge-pairs share exactly one common edge. The number
    of true (geometric) crossings between the two arcs in that triangle is
    `min(α_mult, β_mult)` if the two pairs share two edges (parallel) — but
    that case is actually `=` and produces zero crossings. The crossing
    contribution from a pair of distinct-but-overlapping pairs is `α_mult *
    β_mult` candidate crossings, of which `i(α, β)` survive bigon reduction.
  - For S_{1,2}: 4 triangles, 6 unsigned edges, 2 puncture-vertices.
"""
from __future__ import annotations

from dataclasses import dataclass, field, asdict
from typing import Any, Iterable

try:
    import curver  # type: ignore
    _DEPS = True
except Exception:
    curver = None  # type: ignore
    _DEPS = False

# Reuse the existing helpers from surface_geo. Try both relative (when imported
# as a package) and absolute (when run as a script in the same directory).
try:
    from .surface_geo import _passage_counts, _triangulation_data  # type: ignore  # noqa: F401
except ImportError:
    import os, sys
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    from surface_geo import _passage_counts, _triangulation_data  # type: ignore  # noqa: F401


# ============================================================================
# §1. Dataclasses
# ============================================================================

@dataclass(frozen=True)
class TriangleInfo:
    """One triangle of the surface triangulation."""
    index: int                              # triangle index 0..num_triangles-1
    edges: tuple[int, int, int]             # 3 unsigned edge indices
    signed_edges: tuple[int, int, int]      # 3 signed edge labels (cyclic order)
    corner_vertices: tuple[int, int, int]   # vertex-id at each of the 3 corners
    has_puncture: bool                      # any corner sits at a puncture-vertex

    def to_json(self) -> dict:
        return {
            "index": self.index,
            "edges": list(self.edges),
            "signed_edges": list(self.signed_edges),
            "corner_vertices": list(self.corner_vertices),
            "has_puncture": self.has_puncture,
        }


@dataclass(frozen=True)
class NormalArc:
    """A bundle of `multiplicity` parallel normal arcs in one triangle,
    connecting edges (entry_edge, exit_edge)."""
    triangle: int
    entry_edge: int                         # unsigned, smaller of the two
    exit_edge: int                          # unsigned, larger of the two
    multiplicity: int

    def to_json(self) -> dict:
        return {
            "triangle": self.triangle,
            "entry_edge": self.entry_edge,
            "exit_edge": self.exit_edge,
            "multiplicity": self.multiplicity,
        }


@dataclass(frozen=True)
class CurveDecomposition:
    """A curve's per-triangle normal-arc decomposition."""
    curve_id: str
    train_track_weights: tuple[int, ...]
    normal_arcs: tuple[NormalArc, ...]
    arcs_per_triangle: tuple[tuple[int, ...], ...]
    # ^ for each triangle index, the indices into normal_arcs of its arcs
    total_weight: int

    def to_json(self) -> dict:
        return {
            "curve_id": self.curve_id,
            "train_track_weights": list(self.train_track_weights),
            "normal_arcs": [a.to_json() for a in self.normal_arcs],
            "arcs_per_triangle": [list(t) for t in self.arcs_per_triangle],
            "total_weight": self.total_weight,
        }


@dataclass(frozen=True)
class CrossingLocation:
    """One candidate crossing between curve A's arc and curve B's arc inside
    the same triangle, sharing one common edge."""
    index: int
    triangle: int
    curve_a_arc: int                        # index into A.normal_arcs
    curve_b_arc: int                        # index into B.normal_arcs
    shared_edge: int                        # the common unsigned edge
    candidate_count: int                    # min(A_mult, B_mult) crossings
    sign: int                               # placeholder ±1 (we set +1)

    def to_json(self) -> dict:
        return {
            "index": self.index,
            "triangle": self.triangle,
            "curve_a_arc": self.curve_a_arc,
            "curve_b_arc": self.curve_b_arc,
            "shared_edge": self.shared_edge,
            "candidate_count": self.candidate_count,
            "sign": self.sign,
        }


@dataclass(frozen=True)
class DetailedIntersection:
    """Full crossing data for the pair (curve_a, curve_b)."""
    curve_a: str
    curve_b: str
    geometric_intersection: int             # exact i(α, β) from curver
    candidate_crossings_total: int          # sum of CrossingLocation.candidate_count
    crossings: tuple[CrossingLocation, ...]
    curve_a_decomposition: CurveDecomposition
    curve_b_decomposition: CurveDecomposition

    @property
    def upper_bound_consistent(self) -> bool:
        return self.candidate_crossings_total >= self.geometric_intersection

    def to_json(self) -> dict:
        return {
            "curve_a": self.curve_a,
            "curve_b": self.curve_b,
            "geometric_intersection": self.geometric_intersection,
            "candidate_crossings_total": self.candidate_crossings_total,
            "crossings": [c.to_json() for c in self.crossings],
            "curve_a_decomposition": self.curve_a_decomposition.to_json(),
            "curve_b_decomposition": self.curve_b_decomposition.to_json(),
            "upper_bound_consistent": self.upper_bound_consistent,
        }


# ============================================================================
# §2. Helpers — pull triangulation + vertex assignment from curver
# ============================================================================

def _vertex_index_table(S) -> dict[int, int]:
    """Map each signed-edge label to a vertex *index* (0..num_vertices-1).

    Vertex order: arbitrary but stable — sorted by min signed label in the
    cycle. This makes the assignment reproducible.
    """
    T = S.triangulation
    verts = list(T.vertices)
    # Sort by the min signed label in the cycle for stability
    verts_sorted = sorted(verts, key=lambda cyc: min(cyc))
    label_to_vidx: dict[int, int] = {}
    for vidx, cyc in enumerate(verts_sorted):
        for lbl in cyc:
            label_to_vidx[lbl] = vidx
    return label_to_vidx


def triangulation_info(S) -> list[TriangleInfo]:
    """Return one TriangleInfo per triangle of S.triangulation."""
    if not _DEPS:
        raise RuntimeError("curver not available")
    T = S.triangulation
    label_to_vidx = _vertex_index_table(S)
    out: list[TriangleInfo] = []
    for tri_idx, tri in enumerate(T):
        labels = tuple(tri.labels)         # 3 signed labels in cyclic order
        indices = tuple(tri.indices)       # 3 unsigned edge indices
        # Vertex at each corner = tail vertex of the corresponding signed edge.
        corners = tuple(label_to_vidx[L] for L in labels)
        out.append(TriangleInfo(
            index=tri_idx,
            edges=indices,
            signed_edges=labels,
            corner_vertices=corners,
            has_puncture=True,  # in a punctured surface every vertex IS a puncture
        ))
    return out


# ============================================================================
# §3. decompose_curve
# ============================================================================

def decompose_curve(S, curve, curve_id: str) -> CurveDecomposition:
    """Bonahon decomposition: for each triangle, list the (entry, exit, mult)
    bundles of parallel normal arcs."""
    if not _DEPS:
        raise RuntimeError("curver not available")
    weights = tuple(int(w) for w in tuple(curve))
    T = S.triangulation
    arcs: list[NormalArc] = []
    arcs_per_tri: list[list[int]] = []
    for tri_idx, tri in enumerate(T):
        edges = tuple(tri.indices)
        counts = _passage_counts(weights, edges)
        idxs_for_this_tri: list[int] = []
        # `counts` is keyed by `tuple(sorted((i, j)))` — already canonical.
        for (i, j), n in counts.items():
            if n > 0:
                arc = NormalArc(triangle=tri_idx, entry_edge=i, exit_edge=j,
                                multiplicity=int(n))
                idxs_for_this_tri.append(len(arcs))
                arcs.append(arc)
        arcs_per_tri.append(idxs_for_this_tri)
    return CurveDecomposition(
        curve_id=curve_id,
        train_track_weights=weights,
        normal_arcs=tuple(arcs),
        arcs_per_triangle=tuple(tuple(t) for t in arcs_per_tri),
        total_weight=sum(weights),
    )


# ============================================================================
# §4. find_crossings
# ============================================================================

def find_crossings(S, curve_a, curve_b, id_a: str, id_b: str
                   ) -> DetailedIntersection:
    """For each triangle, enumerate (α-arc, β-arc) pairs whose edge-pairs share
    exactly one edge: those produce candidate crossings.

    Two unordered pairs {i,j} and {k,l} (subsets of the triangle's 3 edges):
      - share 2 edges  ⇒ i=k,j=l (same pair) ⇒ parallel ⇒ no crossing.
      - share 1 edge   ⇒ "cross" pattern ⇒ candidate crossing.
      - share 0 edges  ⇒ impossible (two edge-pairs from a 3-edge set must
                         share at least one edge).
    """
    if not _DEPS:
        raise RuntimeError("curver not available")

    dec_a = decompose_curve(S, curve_a, id_a)
    dec_b = decompose_curve(S, curve_b, id_b)

    crossings: list[CrossingLocation] = []
    next_idx = 0
    for tri_idx in range(len(dec_a.arcs_per_triangle)):
        a_idxs = dec_a.arcs_per_triangle[tri_idx]
        b_idxs = dec_b.arcs_per_triangle[tri_idx]
        for ai in a_idxs:
            arc_a = dec_a.normal_arcs[ai]
            pair_a = frozenset((arc_a.entry_edge, arc_a.exit_edge))
            for bi in b_idxs:
                arc_b = dec_b.normal_arcs[bi]
                pair_b = frozenset((arc_b.entry_edge, arc_b.exit_edge))
                shared = pair_a & pair_b
                if len(shared) == 1:
                    # candidate crossings between these two arc bundles
                    cand = min(arc_a.multiplicity, arc_b.multiplicity)
                    if cand > 0:
                        crossings.append(CrossingLocation(
                            index=next_idx,
                            triangle=tri_idx,
                            curve_a_arc=ai,
                            curve_b_arc=bi,
                            shared_edge=int(next(iter(shared))),
                            candidate_count=int(cand),
                            sign=+1,
                        ))
                        next_idx += 1
    geom = int(curve_a.intersection(curve_b))
    cand_total = sum(c.candidate_count for c in crossings)
    return DetailedIntersection(
        curve_a=id_a,
        curve_b=id_b,
        geometric_intersection=geom,
        candidate_crossings_total=cand_total,
        crossings=tuple(crossings),
        curve_a_decomposition=dec_a,
        curve_b_decomposition=dec_b,
    )


# ============================================================================
# §5. self-test (run as: python -m workspace.projects.op1_geometry.rich_geometry)
# ============================================================================

def _self_test(verbose: bool = True) -> dict:
    if not _DEPS:
        raise RuntimeError("self-test requires curver")
    S = curver.load(1, 2)
    a0 = S.curves['a_0']
    b0 = S.curves['b_0']
    p1 = S.curves['p_1']

    tris = triangulation_info(S)
    if verbose:
        print(f"S_{{1,2}}: {len(tris)} triangles")
        for t in tris:
            print(f"  T{t.index}: edges={t.edges} corners={t.corner_vertices}")

    dec_a = decompose_curve(S, a0, 'a_0')
    if verbose:
        print(f"\na_0 decomposition: weights={dec_a.train_track_weights}, "
              f"{len(dec_a.normal_arcs)} arc bundles")
        for arc in dec_a.normal_arcs:
            print(f"  T{arc.triangle}: edges {arc.entry_edge}-{arc.exit_edge}, "
                  f"mult={arc.multiplicity}")
        # Each arc has 2 endpoints; each edge is shared by 2 triangles. So
        # summing over all (triangle, arc) gives sum(mult) = sum(weights).
        s_arc = sum(a.multiplicity for a in dec_a.normal_arcs)
        s_w = sum(dec_a.train_track_weights)
        print(f"  sanity: sum(mult)={s_arc}, sum(weights)={s_w} "
              f"({'OK' if s_arc == s_w else 'FAIL'})")

    di = find_crossings(S, a0, b0, 'a_0', 'b_0')
    if verbose:
        print(f"\na_0 vs b_0: i={di.geometric_intersection}, "
              f"candidate={di.candidate_crossings_total}, "
              f"crossings={len(di.crossings)}")
        for c in di.crossings:
            ar = di.curve_a_decomposition.normal_arcs[c.curve_a_arc]
            br = di.curve_b_decomposition.normal_arcs[c.curve_b_arc]
            print(f"  T{c.triangle}: a-arc({ar.entry_edge},{ar.exit_edge})×{ar.multiplicity} "
                  f"× b-arc({br.entry_edge},{br.exit_edge})×{br.multiplicity}, "
                  f"shared edge={c.shared_edge}, cand={c.candidate_count}")
        ok = di.upper_bound_consistent
        print(f"  upper_bound_consistent: {ok}")

    return {
        "n_triangles": len(tris),
        "a0_weights": list(dec_a.train_track_weights),
        "a0_n_arcs": len(dec_a.normal_arcs),
        "a0_b0_crossings": len(di.crossings),
        "a0_b0_geometric": di.geometric_intersection,
    }


# ============================================================================
# §6. Surgery trace (Step 3)
# ============================================================================

@dataclass(frozen=True)
class SurgeryTrace:
    """Hatcher-style surgery α  →  σ_α along γ₀.

    `σ_α` is provided by an external producer (e.g. SurfaceGeo.cut_glue) — we
    do not re-derive it here. The trace records the geometric data that
    distinguishes surgery from a generic curve replacement:

      • surgery_region_triangles: triangles where α and γ₀ share normal-arc
        candidates (where the surgery 'lives'). Defined as triangles where
        both α and γ₀ have a non-zero passage-count *and* their candidate
        crossing list is non-empty.

      • alpha_gamma_crossings: all candidate (α, γ₀) crossings.

      • short_arc_triangles / long_arc_triangles: triangles where, after
        surgery, the arc-multiplicity of σ decreased (short arc removed)
        vs increased (γ₀ piece added). Computed from per-triangle
        passage-count deltas between α and σ.

      • surgery_region_punctures: count of distinct puncture-vertex corners
        in surgery_region_triangles.

    These are the geometric witnesses that distinguish a Hatcher surgery
    from an arbitrary curve replacement — sufficient for the agent to
    notice the conserved bigon-cancellation structure.
    """
    alpha_id: str
    gamma0_id: str
    sigma_id: str
    alpha_weights: tuple[int, ...]
    gamma0_weights: tuple[int, ...]
    sigma_weights: tuple[int, ...]
    alpha_gamma_intersection: int
    sigma_gamma_intersection: int
    alpha_gamma_crossings: tuple[CrossingLocation, ...]
    surgery_region_triangles: tuple[int, ...]
    short_arc_triangles: tuple[int, ...]
    long_arc_triangles: tuple[int, ...]
    surgery_region_punctures: int

    def to_json(self) -> dict:
        return {
            "alpha_id": self.alpha_id,
            "gamma0_id": self.gamma0_id,
            "sigma_id": self.sigma_id,
            "alpha_weights": list(self.alpha_weights),
            "gamma0_weights": list(self.gamma0_weights),
            "sigma_weights": list(self.sigma_weights),
            "alpha_gamma_intersection": self.alpha_gamma_intersection,
            "sigma_gamma_intersection": self.sigma_gamma_intersection,
            "alpha_gamma_crossings": [c.to_json() for c in self.alpha_gamma_crossings],
            "surgery_region_triangles": list(self.surgery_region_triangles),
            "short_arc_triangles": list(self.short_arc_triangles),
            "long_arc_triangles": list(self.long_arc_triangles),
            "surgery_region_punctures": self.surgery_region_punctures,
        }


def _per_triangle_arc_count(decomp: CurveDecomposition) -> dict[int, int]:
    """Triangle index → total arc multiplicity (sum of bundle multiplicities)."""
    out: dict[int, int] = {}
    for tri_idx, idxs in enumerate(decomp.arcs_per_triangle):
        out[tri_idx] = sum(decomp.normal_arcs[i].multiplicity for i in idxs)
    return out


def trace_surgery(S, alpha, gamma0, sigma, alpha_id: str, gamma0_id: str,
                  sigma_id: str) -> SurgeryTrace:
    """Build a SurgeryTrace from given α, γ₀, σ."""
    if not _DEPS:
        raise RuntimeError("curver not available")

    dec_alpha = decompose_curve(S, alpha, alpha_id)
    dec_gamma = decompose_curve(S, gamma0, gamma0_id)
    dec_sigma = decompose_curve(S, sigma, sigma_id)

    di_ag = find_crossings(S, alpha, gamma0, alpha_id, gamma0_id)

    # Surgery region: triangles where α and γ₀ have a candidate crossing.
    region_tris = sorted(set(c.triangle for c in di_ag.crossings))

    # Short / long arc triangles: triangles where σ has FEWER (short) or MORE
    # (long, augmented by γ₀ piece) arc-bundles than α.
    cnt_alpha = _per_triangle_arc_count(dec_alpha)
    cnt_sigma = _per_triangle_arc_count(dec_sigma)
    short_tris: list[int] = []
    long_tris: list[int] = []
    for tri_idx in range(len(dec_alpha.arcs_per_triangle)):
        d = cnt_sigma.get(tri_idx, 0) - cnt_alpha.get(tri_idx, 0)
        if d < 0:
            short_tris.append(tri_idx)
        elif d > 0:
            long_tris.append(tri_idx)

    # Punctures in the surgery region: distinct puncture-vertex indices among
    # the corners of region triangles. (On S_{1,2} every triangulation vertex
    # is a puncture, so corner_vertices indices are puncture indices.)
    tri_info = triangulation_info(S)
    puncture_set: set[int] = set()
    for tri_idx in region_tris:
        for v in tri_info[tri_idx].corner_vertices:
            puncture_set.add(v)
    n_punctures = len(puncture_set)

    return SurgeryTrace(
        alpha_id=alpha_id,
        gamma0_id=gamma0_id,
        sigma_id=sigma_id,
        alpha_weights=dec_alpha.train_track_weights,
        gamma0_weights=dec_gamma.train_track_weights,
        sigma_weights=dec_sigma.train_track_weights,
        alpha_gamma_intersection=int(alpha.intersection(gamma0)),
        sigma_gamma_intersection=int(sigma.intersection(gamma0)),
        alpha_gamma_crossings=di_ag.crossings,
        surgery_region_triangles=tuple(region_tris),
        short_arc_triangles=tuple(short_tris),
        long_arc_triangles=tuple(long_tris),
        surgery_region_punctures=n_punctures,
    )


# ============================================================================
# §7. Surgery-aware intersection analysis (Step 4)
# ============================================================================

@dataclass(frozen=True)
class SurgeryIntersectionAnalysis:
    """Compares (α, β) ↔ (σ_α, β) crossing-by-crossing.

    Fields:
      pre_intersection         — DetailedIntersection of (α, β)
      post_intersection        — DetailedIntersection of (σ_α, β)
      pre_crossings_in_region  — α-β candidate crossings whose triangle is in
                                 the surgery region
      pre_crossings_outside    — same, outside the region
      post_crossings_in_region — σ-β candidate crossings whose triangle is in
                                 the surgery region (where the γ₀-piece sits)
      post_crossings_outside   — same, outside the region

      net_change               — i(σ, β) − i(α, β) (true geometric, not
                                 candidate)
      beta_in_surgery_region   — number of triangles where β has a normal arc
                                 AND that triangle is in the surgery region
      beta_through_short_arc   — overlap of β with short_arc_triangles
      beta_through_long_arc    — overlap of β with long_arc_triangles
    """
    surgery: SurgeryTrace
    beta_id: str
    beta_weights: tuple[int, ...]

    pre_intersection: DetailedIntersection
    post_intersection: DetailedIntersection

    pre_crossings_in_region: tuple[CrossingLocation, ...]
    pre_crossings_outside: tuple[CrossingLocation, ...]
    post_crossings_in_region: tuple[CrossingLocation, ...]
    post_crossings_outside: tuple[CrossingLocation, ...]

    net_change: int
    beta_triangles: tuple[int, ...]
    beta_in_surgery_region: int
    beta_through_short_arc: int
    beta_through_long_arc: int

    def to_json(self) -> dict:
        return {
            "surgery": self.surgery.to_json(),
            "beta_id": self.beta_id,
            "beta_weights": list(self.beta_weights),
            "pre_intersection": self.pre_intersection.to_json(),
            "post_intersection": self.post_intersection.to_json(),
            "pre_crossings_in_region":
                [c.to_json() for c in self.pre_crossings_in_region],
            "pre_crossings_outside":
                [c.to_json() for c in self.pre_crossings_outside],
            "post_crossings_in_region":
                [c.to_json() for c in self.post_crossings_in_region],
            "post_crossings_outside":
                [c.to_json() for c in self.post_crossings_outside],
            "net_change": self.net_change,
            "beta_triangles": list(self.beta_triangles),
            "beta_in_surgery_region": self.beta_in_surgery_region,
            "beta_through_short_arc": self.beta_through_short_arc,
            "beta_through_long_arc": self.beta_through_long_arc,
        }


def analyze_surgery_intersection(
    S, surgery: SurgeryTrace, alpha, sigma, beta, beta_id: str
) -> SurgeryIntersectionAnalysis:
    """Compute the SurgeryIntersectionAnalysis for fixed (α, σ_α, γ₀) and a
    given β.
    """
    if not _DEPS:
        raise RuntimeError("curver not available")
    pre = find_crossings(S, alpha, beta, surgery.alpha_id, beta_id)
    post = find_crossings(S, sigma, beta, surgery.sigma_id, beta_id)

    region = set(surgery.surgery_region_triangles)
    short_tris = set(surgery.short_arc_triangles)
    long_tris = set(surgery.long_arc_triangles)

    pre_in = tuple(c for c in pre.crossings if c.triangle in region)
    pre_out = tuple(c for c in pre.crossings if c.triangle not in region)
    post_in = tuple(c for c in post.crossings if c.triangle in region)
    post_out = tuple(c for c in post.crossings if c.triangle not in region)

    # β's triangles: triangles where β has positive arc-multiplicity
    dec_beta = decompose_curve(S, beta, beta_id)
    beta_tris = tuple(
        tri_idx
        for tri_idx, idxs in enumerate(dec_beta.arcs_per_triangle)
        if any(dec_beta.normal_arcs[i].multiplicity > 0 for i in idxs)
    )
    beta_tri_set = set(beta_tris)

    return SurgeryIntersectionAnalysis(
        surgery=surgery,
        beta_id=beta_id,
        beta_weights=dec_beta.train_track_weights,
        pre_intersection=pre,
        post_intersection=post,
        pre_crossings_in_region=pre_in,
        pre_crossings_outside=pre_out,
        post_crossings_in_region=post_in,
        post_crossings_outside=post_out,
        net_change=post.geometric_intersection - pre.geometric_intersection,
        beta_triangles=beta_tris,
        beta_in_surgery_region=len(beta_tri_set & region),
        beta_through_short_arc=len(beta_tri_set & short_tris),
        beta_through_long_arc=len(beta_tri_set & long_tris),
    )


# ============================================================================
# §8. Bigon detection (Step 6 helper)
# ============================================================================

@dataclass(frozen=True)
class Bigon:
    """A (potential) bigon between two curves: a pair of candidate crossings
    that bound a disk in two adjacent triangles via a shared edge.

    Detection is heuristic: we report (c1, c2) pairs of candidate crossings
    whose triangles share an edge AND whose involved arc-bundles cross the
    shared edge. The number of true bigons is bounded by `min(|candidate|,
    |candidate| − geometric_intersection)`.
    """
    crossing_a: int
    crossing_b: int
    triangle_a: int
    triangle_b: int
    shared_edge: int

    def to_json(self) -> dict:
        return {
            "crossing_a": self.crossing_a,
            "crossing_b": self.crossing_b,
            "triangle_a": self.triangle_a,
            "triangle_b": self.triangle_b,
            "shared_edge": self.shared_edge,
        }


def detect_bigons(S, di: DetailedIntersection) -> tuple[Bigon, ...]:
    """Find candidate bigons. Two candidate crossings (c1 in tri T1, c2 in
    tri T2) form a bigon when:
      • T1 ≠ T2 are adjacent (share an unsigned edge e)
      • each crossing's α-arc has e as one of its two edges
      • each crossing's β-arc has e as one of its two edges
      • the four arcs together close up: bundles in T1 connect to bundles in
        T2 across e on both curves
    """
    T = S.triangulation
    # Build edge-to-triangle map (each edge is shared by 2 triangles)
    edge_to_tris: dict[int, list[int]] = {}
    for tri_idx, tri in enumerate(T):
        for e in tri.indices:
            edge_to_tris.setdefault(int(e), []).append(tri_idx)
    bigons: list[Bigon] = []
    seen: set[tuple[int, int]] = set()
    for i, c1 in enumerate(di.crossings):
        a1 = di.curve_a_decomposition.normal_arcs[c1.curve_a_arc]
        b1 = di.curve_b_decomposition.normal_arcs[c1.curve_b_arc]
        a1_edges = {a1.entry_edge, a1.exit_edge}
        b1_edges = {b1.entry_edge, b1.exit_edge}
        for j in range(i + 1, len(di.crossings)):
            c2 = di.crossings[j]
            if c1.triangle == c2.triangle:
                continue
            a2 = di.curve_a_decomposition.normal_arcs[c2.curve_a_arc]
            b2 = di.curve_b_decomposition.normal_arcs[c2.curve_b_arc]
            a2_edges = {a2.entry_edge, a2.exit_edge}
            b2_edges = {b2.entry_edge, b2.exit_edge}
            # The two triangles must share an edge.
            t1_edges = set(T.triangles[c1.triangle].indices)
            t2_edges = set(T.triangles[c2.triangle].indices)
            shared = t1_edges & t2_edges
            for e in shared:
                e = int(e)
                # both α-arcs and both β-arcs must touch e
                if (e in a1_edges and e in a2_edges
                        and e in b1_edges and e in b2_edges):
                    key = (i, j)
                    if key in seen:
                        continue
                    seen.add(key)
                    bigons.append(Bigon(
                        crossing_a=i,
                        crossing_b=j,
                        triangle_a=c1.triangle,
                        triangle_b=c2.triangle,
                        shared_edge=e,
                    ))
                    break  # don't double-count if both shared edges qualify
    return tuple(bigons)


# ============================================================================
# §9. self-test
# ============================================================================

def _self_test(verbose: bool = True) -> dict:
    if not _DEPS:
        raise RuntimeError("self-test requires curver")
    S = curver.load(1, 2)
    a0 = S.curves['a_0']
    b0 = S.curves['b_0']
    p1 = S.curves['p_1']

    tris = triangulation_info(S)
    if verbose:
        print(f"S_{{1,2}}: {len(tris)} triangles")
        for t in tris:
            print(f"  T{t.index}: edges={t.edges} corners={t.corner_vertices}")

    dec_a = decompose_curve(S, a0, 'a_0')
    if verbose:
        print(f"\na_0 decomposition: weights={dec_a.train_track_weights}, "
              f"{len(dec_a.normal_arcs)} arc bundles")
        for arc in dec_a.normal_arcs:
            print(f"  T{arc.triangle}: edges {arc.entry_edge}-{arc.exit_edge}, "
                  f"mult={arc.multiplicity}")
        s_arc = sum(a.multiplicity for a in dec_a.normal_arcs)
        s_w = sum(dec_a.train_track_weights)
        print(f"  sanity: sum(mult)={s_arc}, sum(weights)={s_w} "
              f"({'OK' if s_arc == s_w else 'FAIL'})")

    di = find_crossings(S, a0, b0, 'a_0', 'b_0')
    if verbose:
        print(f"\na_0 vs b_0: i={di.geometric_intersection}, "
              f"candidate={di.candidate_crossings_total}, "
              f"crossings={len(di.crossings)}")
        for c in di.crossings:
            ar = di.curve_a_decomposition.normal_arcs[c.curve_a_arc]
            br = di.curve_b_decomposition.normal_arcs[c.curve_b_arc]
            print(f"  T{c.triangle}: a-arc({ar.entry_edge},{ar.exit_edge})×{ar.multiplicity} "
                  f"× b-arc({br.entry_edge},{br.exit_edge})×{br.multiplicity}, "
                  f"shared edge={c.shared_edge}, cand={c.candidate_count}")
        ok = di.upper_bound_consistent
        print(f"  upper_bound_consistent: {ok}")

    return {
        "n_triangles": len(tris),
        "a0_weights": list(dec_a.train_track_weights),
        "a0_n_arcs": len(dec_a.normal_arcs),
        "a0_b0_crossings": len(di.crossings),
        "a0_b0_geometric": di.geometric_intersection,
    }


if __name__ == "__main__":
    import sys
    verbose = "--quiet" not in sys.argv
    res = _self_test(verbose=verbose)
    if verbose:
        print()
        import json
        print(json.dumps(res, indent=2))
