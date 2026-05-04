"""Quantitative probe of three proof-paths for the dismantlability of
DL(α) on S_{1,2}, S_{1,1}, S_{2,1}.

Path A (pigeonhole):  |DL| vs k.
Path B (third-vertex): for non-adjacent (β1, β2) in DL, is there β3 with
        N[β1] ⊆ N[β3] (so β1 is dominated)?
Path C (surgery σ_α):  does σ_α exist and is it a cone vertex of DL?

For Task 1 we additionally record the GEOMETRY of the first dominator
(v*, u*): i(α, v*), i(α, u*), i(v*, u*), f(v*), f(u*), and whether v*
matches σ_α from the engine.
"""

from __future__ import annotations

import json
import os
import sys
import time
from collections import Counter, defaultdict
from itertools import combinations

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, ROOT)

from SpatialMind.experiments.op1_coe_run import (
    IntersectionCache, build_descending_link,
    is_chordal_peo, has_cone_vertex, is_dismantlable,
)
from SpatialMind.domains.surface_topology.engine import SurfaceEngine


# ============================================================================
# Helpers.
# ============================================================================

def first_dominator(verts, adj):
    """Return (u*, v*) — the first u dominated by some v in lexicographic
    order. None if no dominator exists.
    """
    A = {v: set(adj[v]) | {v} for v in verts}
    for u in verts:
        for v in verts:
            if u == v:
                continue
            if A[u] <= A[v]:
                return u, v
    return None, None


def all_dominator_pairs(verts, adj):
    A = {v: set(adj[v]) | {v} for v in verts}
    pairs = []
    for u in verts:
        for v in verts:
            if u == v:
                continue
            if A[u] <= A[v]:
                pairs.append((u, v))
    return pairs


def find_sigma_idx(cache, alpha_idx):
    """Cache-based version of engine's canonical σ search. The engine's
    `_search_canonical_sigma` recomputes curver intersections — that's
    way too slow over many α. We replicate the algorithm using the
    precomputed cache.
    """
    f = cache.f
    n_curves = cache.n
    k = f[alpha_idx]
    if k < 2:
        return None
    # Build DL of α: vertices β with f(β) < k and i(α, β) ≤ 1.
    DL = []
    for b in range(n_curves):
        if b == alpha_idx:
            continue
        if f[b] < k and cache.i(alpha_idx, b) <= 1:
            DL.append(b)
    if not DL:
        return None
    # Walk down levels k-2, k-3, ... looking for σ disjoint from α and
    # universal on DL.
    for target_level in range(k - 2, -1, -1):
        for cand in range(n_curves):
            if cand == alpha_idx:
                continue
            if f[cand] != target_level:
                continue
            if cache.i(alpha_idx, cand) != 0:
                continue
            if all(cache.i(cand, b) <= 1 for b in DL):
                return cand
    return None


# ============================================================================
# Driver.
# ============================================================================

def main():
    db_root = os.path.join(ROOT, "workspace", "projects", "op1_geometry")

    # We focus mostly on S_{1,2} (the main target of OP-1).
    surfaces = [
        ("S_1_2", 1, 2, os.path.join(db_root, "data_S_1_2.json")),
        ("S_1_1", 1, 1, os.path.join(db_root, "data_S_1_1.json")),
        ("S_2_1", 2, 1, os.path.join(db_root, "data_S_2_1.json")),
    ]

    out = {"per_surface": {}, "task1_dominator_geometry": {},
           "pathA_pigeonhole": {}, "pathB_third_vertex": {},
           "pathC_sigma_cone": {}}

    for label, g, n, path in surfaces:
        print(f"\n=== {label} ===", flush=True)
        eng = SurfaceEngine(g, n, database_path=path)
        cache = IntersectionCache(eng)
        gamma0 = eng.S.curves["a_0"]
        f = cache.f
        n_curves = cache.n

        # ---- pre-collect alphas at level >= 2 (the ones we care about) ----
        alphas = [i for i in range(n_curves) if f[i] >= 2]

        # ---- Task 1 + Path C: per-α dominator geometry & σ check ----
        rows = []
        sigma_succeeds = sigma_in_DL = sigma_is_cone = 0
        sigma_v_match = 0
        v_star_min_level_count = 0
        v_star_intersect_alpha_one = 0
        v_star_intersect_alpha_zero = 0
        n_with_dominator = 0
        n_total = 0

        # Cap: keep this fast. Stratified sample by level.
        if label == "S_1_2":
            # Sample 6 per level for k = 2..12, then a couple at higher k.
            by_level = defaultdict(list)
            for ai in alphas:
                by_level[f[ai]].append(ai)
            sampled = []
            for k in sorted(by_level):
                if k <= 12:
                    sampled.extend(by_level[k][:6])
                else:
                    sampled.extend(by_level[k][:2])
        elif label == "S_1_1":
            sampled = alphas[:40]
        else:  # S_2_1
            sampled = alphas[:30]

        t0 = time.time()
        for ai in sampled:
            verts, adj = build_descending_link(cache, ai)
            if not verts:
                continue
            n_total += 1
            cone_v = has_cone_vertex(verts, adj)
            chord, _ = is_chordal_peo(verts, adj)
            disman = is_dismantlable(verts, adj)
            u_star, v_star = first_dominator(verts, adj)

            # σ search (cache-based; safe to call many times)
            try:
                sig_idx = find_sigma_idx(cache, ai)
            except Exception:
                sig_idx = None
            if sig_idx is not None:
                sigma_succeeds += 1
                if sig_idx in verts:
                    sigma_in_DL += 1
                    if cone_v == sig_idx:
                        sigma_is_cone += 1

            row = {
                "alpha": ai, "level": f[ai],
                "DL_size": len(verts),
                "DL_edges": sum(len(adj[v]) for v in verts) // 2,
                "max_degree": max((len(adj[v]) for v in verts), default=0),
                "cone": cone_v, "chordal": chord, "dismantlable": disman,
                "sigma": sig_idx,
                "u_star": u_star, "v_star": v_star,
            }
            if u_star is not None:
                n_with_dominator += 1
                row["i_alpha_v"] = cache.i(ai, v_star)
                row["i_alpha_u"] = cache.i(ai, u_star)
                row["i_v_u"] = cache.i(v_star, u_star)
                row["f_v"] = f[v_star]
                row["f_u"] = f[u_star]
                # Is v* the min-level vertex of DL?
                min_f_in_DL = min(f[v] for v in verts)
                row["v_is_min_level"] = (f[v_star] == min_f_in_DL)
                if f[v_star] == min_f_in_DL:
                    v_star_min_level_count += 1
                # i(α, v*) — is it 1 or 0?
                if row["i_alpha_v"] == 1:
                    v_star_intersect_alpha_one += 1
                elif row["i_alpha_v"] == 0:
                    v_star_intersect_alpha_zero += 1
                # Does v* match σ?
                if sig_idx is not None and v_star == sig_idx:
                    sigma_v_match += 1
            rows.append(row)

        elapsed = time.time() - t0

        out["task1_dominator_geometry"][label] = {
            "n_alphas_tested": n_total,
            "n_with_dominator": n_with_dominator,
            "v_star_min_level_count": v_star_min_level_count,
            "v_star_min_level_rate": v_star_min_level_count / max(1, n_with_dominator),
            "v_star_i_alpha_eq_1": v_star_intersect_alpha_one,
            "v_star_i_alpha_eq_0": v_star_intersect_alpha_zero,
            "rows_sample": rows[:30],  # first 30 for inspection
        }

        out["pathC_sigma_cone"][label] = {
            "n_alphas_tested": n_total,
            "sigma_succeeds": sigma_succeeds,
            "sigma_succeeds_rate": sigma_succeeds / max(1, n_total),
            "sigma_in_DL": sigma_in_DL,
            "sigma_is_cone": sigma_is_cone,
            "sigma_is_cone_rate_given_succeed": sigma_is_cone / max(1, sigma_succeeds),
            "v_star_eq_sigma": sigma_v_match,
        }

        # ---- Path A: |DL| vs k distribution ----
        by_level_size = defaultdict(list)
        for r in rows:
            by_level_size[r["level"]].append(r["DL_size"])
        path_a = {}
        for k in sorted(by_level_size):
            sizes = by_level_size[k]
            path_a[k] = {
                "n": len(sizes),
                "min_DL": min(sizes), "max_DL": max(sizes),
                "mean_DL": sum(sizes) / len(sizes),
                "trend_indicator": (max(sizes) <= 2 * (k + 1)),
            }
        out["pathA_pigeonhole"][label] = path_a

        # ---- Path B: non-adjacent pair domination ----
        # For each α: count non-adjacent pairs (β1, β2) in DL.
        # For each such pair, check: does there exist β3 with N[β1] ⊆ N[β3]?
        # Equivalently: is β1 dominated by SOME other vertex?
        # Path B's claim: yes, always.
        path_b = {
            "alphas_tested": 0,
            "alphas_with_nonadj_pair": 0,
            "alphas_with_nonadj_pair_dominated": 0,
            "nonadj_total": 0,
            "nonadj_dominated": 0,
        }
        for r in rows:
            ai = r["alpha"]
            verts, adj = build_descending_link(cache, ai)
            if len(verts) < 2:
                continue
            path_b["alphas_tested"] += 1
            A = {v: set(adj[v]) | {v} for v in verts}
            non_adj = [(b1, b2) for b1 in verts for b2 in verts
                       if b1 < b2 and b2 not in adj[b1]]
            if not non_adj:
                continue
            path_b["alphas_with_nonadj_pair"] += 1
            all_dom_b1 = True
            for b1, b2 in non_adj:
                path_b["nonadj_total"] += 1
                # Is b1 dominated by some w ≠ b1?
                dominated = any(A[b1] <= A[w] for w in verts if w != b1)
                if dominated:
                    path_b["nonadj_dominated"] += 1
                else:
                    all_dom_b1 = False
            if all_dom_b1:
                path_b["alphas_with_nonadj_pair_dominated"] += 1
        out["pathB_third_vertex"][label] = path_b

        print(f"  tested {n_total} α in {elapsed:.1f}s; "
              f"with-dominator={n_with_dominator}, v*=min-level={v_star_min_level_count}, "
              f"i(α,v*)=1: {v_star_intersect_alpha_one}; "
              f"σ-succeeds={sigma_succeeds}, σ=cone={sigma_is_cone}, σ=v*: {sigma_v_match}",
              flush=True)

    out_path = os.path.join(os.path.dirname(__file__), "op1_proof_probe.json")
    with open(out_path, "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=2, default=str)
    print(f"\nWrote {out_path}")


if __name__ == "__main__":
    main()
