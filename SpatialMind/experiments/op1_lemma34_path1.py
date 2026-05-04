"""Path 1: extract DT/weight coordinates of (α, δ, γ_0) for the 27 σ-fail-cone
α at k=2 in S_{1,2}, and look for a uniform formula δ = F(α).

For each α ∈ {27 cases}: print:
  - α weights, level f(α) = 2
  - cone curve δ weights, level f(δ) = 1
  - i(α, δ) = 1 (always)
  - α and δ as combinatorial objects (passage counts in each triangle)
  - is δ obtainable from α by a specific transformation?
"""

from __future__ import annotations

import json
import os
import sys
from collections import Counter, defaultdict

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, ROOT)

from SpatialMind.experiments.op1_coe_run import (
    IntersectionCache, build_descending_link,
    is_chordal_peo, has_cone_vertex,
)
from SpatialMind.experiments.op1_proof_probe import find_sigma_idx
from SpatialMind.domains.surface_topology.engine import SurfaceEngine
from SpatialMind.domains.surface_topology.engine import _passage_counts


CONE_ALPHAS = [
    13, 40, 42, 68, 74, 113, 121, 122, 126, 127, 145, 156, 170,
    201, 210, 212, 216, 222, 322, 359, 371, 373, 374, 376, 386,
    387, 389,
]


def passage_dict(weights, tri_indices):
    """Per-triangle passage counts."""
    d = {}
    for t_idx, edges in enumerate(tri_indices):
        d[t_idx] = _passage_counts(weights, edges)
    return d


def main():
    db_path = os.path.join(ROOT, "workspace", "projects", "op1_geometry",
                           "data_S_1_2.json")
    eng = SurfaceEngine(1, 2, database_path=db_path)
    cache = IntersectionCache(eng)
    f = cache.f
    gamma0 = eng.S.curves["a_0"]
    print(f"S_{{1,2}}: triangles = {len(eng._tri_indices)}", flush=True)
    print(f"  triangle edges: {eng._tri_indices}", flush=True)
    print(f"  γ_0 weights: {list(int(x) for x in tuple(gamma0))}", flush=True)
    print()

    rows = []
    for ai in CONE_ALPHAS:
        verts, adj = build_descending_link(cache, ai)
        cone = has_cone_vertex(verts, adj)
        if cone is None:
            print(f"α={ai}: NO cone (skip)")
            continue
        a_lam = eng._db["curves"][ai]
        d_lam = eng._db["curves"][cone]
        a_w = list(int(x) for x in tuple(a_lam))
        d_w = list(int(x) for x in tuple(d_lam))
        # Verify levels and intersections.
        f_a = f[ai]
        f_d = f[cone]
        i_ad = cache.i(ai, cone)
        # Per-triangle passages
        a_pass = passage_dict(a_w, eng._tri_indices)
        d_pass = passage_dict(d_w, eng._tri_indices)
        rows.append({
            "alpha": ai, "delta": cone,
            "f_a": f_a, "f_d": f_d, "i_ad": i_ad,
            "a_w": a_w, "d_w": d_w,
            "a_pass": a_pass, "d_pass": d_pass,
        })

    # Print compact
    print("Per-α data (α, δ):\n")
    for r in rows:
        print(f"α={r['alpha']:>3} δ={r['delta']:>3}  α_w={r['a_w']}  δ_w={r['d_w']}")

    # Look for uniform δ candidates: how many distinct δ values?
    delta_freq = Counter(r["delta"] for r in rows)
    print(f"\nDistinct δ values: {len(delta_freq)}")
    print(f"Top δ values:")
    for d, c in delta_freq.most_common(10):
        d_w = list(int(x) for x in tuple(eng._db["curves"][d]))
        print(f"  δ={d} (count={c}, weights={d_w})")

    # For each (α, δ), look at the relation a_w to d_w.
    # Specifically: where does d differ from a in train-track terms?
    print("\nRelation between α and δ weights (per-edge differences):")
    for r in rows[:10]:
        diff = [a - b for a, b in zip(r["a_w"], r["d_w"])]
        print(f"  α={r['alpha']:>3} δ={r['delta']:>3}  diff (α-δ)= {diff}")

    # Save for later analysis.
    out = {"rows": rows, "delta_freq": dict(delta_freq)}
    out_path = os.path.join(os.path.dirname(__file__), "op1_lemma34_path1.json")
    with open(out_path, "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=2, default=str)
    print(f"\nWrote {out_path}")


if __name__ == "__main__":
    main()
