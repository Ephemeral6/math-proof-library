"""Detailed probe of k=2,3,4 on S_{1,2}:

(1) For each α, determine whether the *topological* Hatcher σ_α exists
    by checking whether there's a level-(k-2) curve in the DB with
    i(α, σ) ≤ 1 (relaxing the engine's strict i=0 condition) AND σ
    universal on DL.

(2) Identify the K_4+4leaves topological pattern: do all 7 chordal-only
    α have the same MCG-type? Compare their DL graph structures.

(3) For k=2 config (b) cases with non-σ cone vertex, identify the cone:
    is it a "separator" (curve enclosing both punctures)?
"""

from __future__ import annotations

import json
import os
import sys
from collections import defaultdict, Counter
from itertools import combinations

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, ROOT)

from SpatialMind.experiments.op1_coe_run import (
    IntersectionCache, build_descending_link,
    is_chordal_peo, has_cone_vertex,
)
from SpatialMind.domains.surface_topology.engine import SurfaceEngine


def find_relaxed_sigma(cache, alpha_idx):
    """Find a curve σ in DB at level k-2 with i(α, σ) ≤ 1 and σ universal on DL.
    This is the *relaxed* version of the engine's strict search.
    Returns sigma_idx or None."""
    f = cache.f
    k = f[alpha_idx]
    if k < 2:
        return None
    # Build DL.
    DL = []
    for j in range(cache.n):
        if j == alpha_idx:
            continue
        if f[j] < k and cache.i(alpha_idx, j) <= 1:
            DL.append(j)
    if not DL:
        return None
    # Try level k-2 first; allow i(α, σ) ≤ 1.
    for target_level in range(k - 2, -1, -1):
        for cand in range(cache.n):
            if cand == alpha_idx:
                continue
            if f[cand] != target_level:
                continue
            if cache.i(alpha_idx, cand) > 1:
                continue
            if all(cache.i(cand, b) <= 1 for b in DL):
                return cand
    return None


def isomorphism_signature(verts, adj):
    """Compute a graph isomorphism signature: degree sequence + canonical
    form (tries small permutations).

    For our purposes, the K_4+4leaves graph has degree sequence (6,6,6,6,3,3,3,3).
    """
    degs = sorted([len(adj[v]) for v in verts], reverse=True)
    n_e = sum(len(adj[v]) for v in verts) // 2
    return (len(verts), n_e, tuple(degs))


def main():
    db_path = os.path.join(
        ROOT, "workspace", "projects", "op1_geometry", "data_S_1_2.json")
    eng = SurfaceEngine(1, 2, database_path=db_path)
    cache = IntersectionCache(eng)
    f = cache.f

    # 1. For each α at k=2,3,4: determine if relaxed σ-search succeeds.
    print("=== Phase 1: relaxed σ-search per level ===\n", flush=True)
    out = {"per_level": {}, "k2_chordal_only_signatures": [],
           "k2_cone_only_cones": [], "phase4_cone_topology": []}
    for k in [2, 3, 4]:
        alphas_k = [i for i in range(cache.n) if f[i] == k]
        n_strict = 0
        n_relaxed = 0
        n_neither = 0
        for ai in alphas_k:
            verts, adj = build_descending_link(cache, ai)
            if not verts:
                continue
            cone = has_cone_vertex(verts, adj)
            chord, _ = is_chordal_peo(verts, adj)
            # Strict: engine's σ-search (i=0)
            from SpatialMind.experiments.op1_proof_probe import find_sigma_idx
            sig_strict = find_sigma_idx(cache, ai)
            # Relaxed: i(α, σ) ≤ 1
            sig_relaxed = find_relaxed_sigma(cache, ai)

            if sig_strict is not None:
                n_strict += 1
            elif sig_relaxed is not None:
                n_relaxed += 1
            else:
                n_neither += 1
        print(f"  k={k}: total={len(alphas_k)}, "
              f"σ-strict-success={n_strict}, "
              f"σ-relaxed-only={n_relaxed}, "
              f"σ-neither={n_neither}",
              flush=True)
        out["per_level"][f"k_{k}"] = {
            "total": len(alphas_k),
            "sigma_strict": n_strict,
            "sigma_relaxed_only": n_relaxed,
            "sigma_neither": n_neither,
        }

    # 2. K_4+4leaves signature check.
    print("\n=== Phase 2: K_4+4leaves uniqueness ===\n", flush=True)
    chord_only_alphas = [25, 72, 149, 189, 208, 217, 218]
    sigs = []
    for ai in chord_only_alphas:
        verts, adj = build_descending_link(cache, ai)
        sig = isomorphism_signature(verts, adj)
        sigs.append((ai, sig))
        print(f"  α={ai} k={f[ai]}: signature = (nv={sig[0]}, ne={sig[1]}, degs={sig[2]})",
              flush=True)
    # Same signature?
    sig_set = set(s for _, s in sigs)
    print(f"\n  Distinct signatures: {len(sig_set)}", flush=True)
    print(f"  Set: {sig_set}", flush=True)
    out["k2_chordal_only_signatures"] = [{"alpha": a, "sig": str(s)} for a, s in sigs]

    # 3. For k=2 σ-fail-but-cone cases, identify the cone vertex's level.
    print("\n=== Phase 3: k=2 σ-fail cone vertex topology ===\n", flush=True)
    cone_levels = []
    for r_idx in range(cache.n):
        if f[r_idx] != 2:
            continue
        verts, adj = build_descending_link(cache, r_idx)
        if not verts:
            continue
        cone = has_cone_vertex(verts, adj)
        from SpatialMind.experiments.op1_proof_probe import find_sigma_idx
        sig = find_sigma_idx(cache, r_idx)
        if cone is not None and sig is None:
            # σ-fail-but-cone case
            cone_levels.append({
                "alpha": r_idx,
                "cone": cone,
                "f_cone": f[cone],
                "i_alpha_cone": cache.i(r_idx, cone),
            })
    print(f"  k=2 σ-fail cone cases: {len(cone_levels)}")
    cone_lvl_freq = Counter(r["f_cone"] for r in cone_levels)
    cone_alpha_int = Counter(r["i_alpha_cone"] for r in cone_levels)
    print(f"  cone level distribution: {sorted(cone_lvl_freq.items())}")
    print(f"  i(α, cone) distribution: {sorted(cone_alpha_int.items())}")
    out["k2_cone_only_cones"] = cone_levels

    # 4. For cone vertices, look at their geometry.
    # Specifically, for k=2 σ-fail-cone cases: the cone vertex is at level 0 or 1.
    # If at level 1: how does it relate to α geometrically?
    print("\n=== Phase 4: cone vertex geometric type ===\n", flush=True)
    # Inspect first 10 cones
    for r in cone_levels[:10]:
        cv = r["cone"]
        # Weights of cone curve
        cw = list(int(x) for x in tuple(eng._db["curves"][cv]))
        f_cv = f[cv]
        # Weights summary
        wt_total = sum(cw)
        print(f"  α={r['alpha']}: cone={cv} f={f_cv} i(α, cone)={r['i_alpha_cone']} weights total={wt_total}",
              flush=True)
        out["phase4_cone_topology"].append({
            "alpha": r['alpha'], "cone": cv, "f_cone": f_cv,
            "weights_total": wt_total,
        })

    out_path = os.path.join(os.path.dirname(__file__), "op1_small_k_probe.json")
    with open(out_path, "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=2, default=str)
    print(f"\nWrote {out_path}")


if __name__ == "__main__":
    main()
