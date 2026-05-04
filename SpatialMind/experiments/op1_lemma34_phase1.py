"""Phase 1: comprehensive pattern enumeration for the 27 σ-fail-cone α at k=2.

For each α, dump:
  - α weights, total weight |α|
  - δ (cone vertex) weights, |δ|
  - α - δ (componentwise), checking if non-negative
  - DL minimum-weight vertex: is it δ?
  - δ's level, i(α, δ), i(γ_0, δ)

Then look for INVARIANT pattern across all 27.
"""

from __future__ import annotations

import json
import os
import sys
from collections import Counter
from itertools import combinations

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, ROOT)

from SpatialMind.experiments.op1_coe_run import (
    IntersectionCache, build_descending_link, has_cone_vertex,
)
from SpatialMind.domains.surface_topology.engine import SurfaceEngine


CONE_ALPHAS = [13, 40, 42, 68, 74, 113, 121, 122, 126, 127, 145, 156, 170,
               201, 210, 212, 216, 222, 322, 359, 371, 373, 374, 376, 386,
               387, 389]


def main():
    db_path = os.path.join(ROOT, "workspace", "projects", "op1_geometry",
                           "data_S_1_2.json")
    eng = SurfaceEngine(1, 2, database_path=db_path)
    cache = IntersectionCache(eng)
    f = cache.f
    gamma0 = eng.S.curves["a_0"]
    g0_w = list(int(x) for x in tuple(gamma0))
    print(f"γ_0 = {g0_w}, |γ_0| = {sum(g0_w)}", flush=True)
    print()

    # Pattern hunt: δ as minimum-weight vertex in DL?
    n_min_weight = 0
    n_alpha_minus_delta_nonneg = 0
    n_delta_le_alpha = 0
    n_pseudo_subseq = 0  # whether δ is "supported on a subset of α's edges"

    rows = []
    print(f"{'α':>4} {'k':>2} {'|α|':>4} {'δ':>4} {'|δ|':>4} {'min_w_DL?':>9} "
          f"{'δ≤α?':>5} {'α-δ ≥0':>6} {'α-δ':>20} {'edge support':>15}",
          flush=True)
    for ai in CONE_ALPHAS:
        DL, adj = build_descending_link(cache, ai)
        cone = has_cone_vertex(DL, adj)
        if cone is None:
            continue
        a_w = list(int(x) for x in tuple(eng._db["curves"][ai]))
        d_w = list(int(x) for x in tuple(eng._db["curves"][cone]))
        # min-weight in DL
        DL_weights = [(b, sum(int(x) for x in tuple(eng._db["curves"][b]))) for b in DL]
        DL_weights.sort(key=lambda kv: kv[1])
        is_min = (DL_weights[0][0] == cone)

        diff = [a - d for a, d in zip(a_w, d_w)]
        is_le = all(d <= a for a, d in zip(a_w, d_w))
        is_nonneg = all(x >= 0 for x in diff)

        # Edge support: which edges does δ use? Subset of α's edges?
        d_support = set(i for i, w in enumerate(d_w) if w > 0)
        a_support = set(i for i, w in enumerate(a_w) if w > 0)
        is_subset = d_support <= a_support

        if is_min:
            n_min_weight += 1
        if is_nonneg:
            n_alpha_minus_delta_nonneg += 1
        if is_le:
            n_delta_le_alpha += 1
        if is_subset:
            n_pseudo_subseq += 1

        print(f"{ai:>4} {f[ai]:>2} {sum(a_w):>4} {cone:>4} {sum(d_w):>4} "
              f"{str(is_min):>9} {str(is_le):>5} {str(is_nonneg):>6} "
              f"{str(diff):>20} d_supp⊆α_supp:{str(is_subset)}",
              flush=True)
        rows.append({
            "alpha": ai, "delta": cone,
            "a_w": a_w, "d_w": d_w, "diff": diff,
            "is_min_weight": is_min, "delta_le_alpha": is_le,
            "is_subset_support": is_subset,
        })

    print(f"\n=== Summary ===")
    print(f"  δ = min-weight vertex in DL: {n_min_weight}/{len(rows)}")
    print(f"  δ ≤ α componentwise:         {n_delta_le_alpha}/{len(rows)}")
    print(f"  α - δ ≥ 0 (same as above):   {n_alpha_minus_delta_nonneg}/{len(rows)}")
    print(f"  supp(δ) ⊆ supp(α):           {n_pseudo_subseq}/{len(rows)}")

    out = {"rows": rows, "summary": {
        "delta_le_alpha": n_delta_le_alpha,
        "delta_min_weight": n_min_weight,
        "support_subset": n_pseudo_subseq,
    }}
    out_path = os.path.join(os.path.dirname(__file__), "op1_lemma34_phase1.json")
    with open(out_path, "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=2, default=str)
    print(f"\nWrote {out_path}")


if __name__ == "__main__":
    main()
