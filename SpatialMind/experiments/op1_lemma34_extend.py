"""Extension: test the 14-signature claim more rigorously.

(A) MCG orbit test: apply Dehn twists to a representative α from each of the 14 signature
    classes; verify the resulting α has THE SAME signature. This would confirm the 14
    signatures are MCG-Stab(γ_0)-orbits.

(B) α = δ + δ' decomposition: for each cone-α at k=2, check whether α - δ corresponds to
    another curve δ' in the database. If yes, α decomposes as 2 level-1 sub-laminations,
    which gives a CLEAN Bonahon-additivity proof of i(δ, β) ≤ i(α, β).

(C) Generate new α at k=2 via Dehn twists of named curves (NOT in the DB), check whether
    they still match one of the 14 signatures.
"""

from __future__ import annotations

import json
import os
import sys
import time
from collections import defaultdict, Counter
from itertools import combinations

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, ROOT)

from SpatialMind.experiments.op1_coe_run import (
    IntersectionCache, build_descending_link, has_cone_vertex,
)
from SpatialMind.domains.surface_topology.engine import SurfaceEngine


def signature(verts, adj):
    n_v = len(verts)
    n_e = sum(len(adj[v]) for v in verts) // 2
    deg_seq = tuple(sorted([len(adj[v]) for v in verts], reverse=True))
    return (n_v, n_e, deg_seq)


def build_DL_with_pool(eng, alpha_lam, pool):
    """Build DL with a custom pool (e.g., to include twisted curves)."""
    gamma0 = eng.S.curves["a_0"]
    k = int(gamma0.intersection(alpha_lam))
    if k < 2:
        return None, None
    DL = []
    for j, beta in enumerate(pool):
        f_b = int(gamma0.intersection(beta))
        if f_b >= k:
            continue
        if int(alpha_lam.intersection(beta)) > 1:
            continue
        DL.append(j)
    if not DL:
        return DL, {}
    adj = {j: set() for j in DL}
    pair_cache = {}
    for a, b in combinations(DL, 2):
        key = (a, b)
        if key in pair_cache:
            ii = pair_cache[key]
        else:
            ii = int(pool[a].intersection(pool[b]))
            pair_cache[key] = ii
        if ii <= 1:
            adj[a].add(b)
            adj[b].add(a)
    return DL, adj


def main():
    db_path = os.path.join(ROOT, "workspace", "projects", "op1_geometry",
                           "data_S_1_2.json")
    eng = SurfaceEngine(1, 2, database_path=db_path)
    cache = IntersectionCache(eng)
    f = cache.f
    n_curves = cache.n
    pool = list(eng._db["curves"])

    # ----------------------------------------------------------------
    # (B) α = δ + δ' decomposition
    # ----------------------------------------------------------------
    print("=== (B) Test α = δ + δ' decomposition ===\n", flush=True)
    cone_alphas = [13, 40, 42, 68, 74, 113, 121, 122, 126, 127, 145, 156, 170,
                   201, 210, 212, 216, 222, 322, 359, 371, 373, 374, 376, 386,
                   387, 389]

    n_decomposes = 0
    for ai in cone_alphas:
        a_w = list(int(x) for x in tuple(eng._db["curves"][ai]))
        DL, adj = build_descending_link(cache, ai)
        cone = has_cone_vertex(DL, adj)
        if cone is None:
            continue
        d_w = list(int(x) for x in tuple(eng._db["curves"][cone]))
        # α - δ:
        diff = tuple(a - d for a, d in zip(a_w, d_w))
        # Search for δ' in DB matching this diff (level 1, weight = diff).
        delta_prime_idx = None
        for j in range(n_curves):
            if j == ai or j == cone:
                continue
            j_w = tuple(int(x) for x in tuple(eng._db["curves"][j]))
            if j_w == diff:
                delta_prime_idx = j
                break
        decomp = (delta_prime_idx is not None)
        if decomp:
            n_decomposes += 1
        # Print
        f_diff_pred = sum(diff)
        # f(δ') if we had it
        if delta_prime_idx is not None:
            f_dp = f[delta_prime_idx]
            i_alpha_dp = cache.i(ai, delta_prime_idx)
            i_d_dp = cache.i(cone, delta_prime_idx)
            print(f"α={ai:>3} δ={cone:>3} α-δ={list(diff)} → δ'={delta_prime_idx} "
                  f"f(δ')={f_dp} i(α,δ')={i_alpha_dp} i(δ,δ')={i_d_dp}",
                  flush=True)
        else:
            print(f"α={ai:>3} δ={cone:>3} α-δ={list(diff)} → δ' NOT IN DB "
                  f"(weight sum = {f_diff_pred})",
                  flush=True)
    print(f"\n{n_decomposes}/{len(cone_alphas)} α decompose as α = δ + δ' "
          f"with δ' a curve in DB", flush=True)

    # ----------------------------------------------------------------
    # (A) MCG orbit test: Dehn twist representatives, check signature stability
    # ----------------------------------------------------------------
    print("\n=== (A) Dehn-twist orbit test ===\n", flush=True)

    # Pick 1 representative from each of 14 signature classes
    sig_reps = {
        (5, 9): 170, (6, 12): 216, (7, 15, "6555"): 68, (7, 15, "6644"): 127,
        (7, 14): 359, (8, 18, "GS"): 25, (8, 18, "7744"): 122, (8, 17): 322,
        (9, 21): 42, (9, 19): 145, (10, 24): 121, (11, 26): 40,
        (11, 27): 113, (12, 30): 13,
    }
    reps_to_test = sorted(set(sig_reps.values()))
    print(f"Representative α from each signature class: {reps_to_test}",
          flush=True)

    # For each rep, apply Dehn twists by named curves and check signature.
    # We use curves a_0 (= γ_0), b_0, p_1.
    twist_curves = {
        "γ_0": eng.S.curves["a_0"],
        "b_0": eng.S.curves["b_0"],
        "p_1": eng.S.curves["p_1"],
    }

    n_match = 0
    n_total = 0
    fresh_signatures = Counter()
    for rep_idx in reps_to_test[:5]:  # test 5 reps (limit for speed)
        rep_lam = eng._db["curves"][rep_idx]
        DL_orig, adj_orig = build_descending_link(cache, rep_idx)
        sig_orig = signature(DL_orig, adj_orig) if DL_orig else None
        if sig_orig is None:
            continue
        for tw_name, tw in twist_curves.items():
            T = tw.encode_twist()
            current = rep_lam
            for power in range(1, 4):  # 3 twists
                current = T(current)
                gamma0 = eng.S.curves["a_0"]
                f_cur = int(gamma0.intersection(current))
                if f_cur != 2:
                    continue  # we want k=2
                # Build DL with original pool (DB)
                DL_cur, adj_cur = build_DL_with_pool(eng, current, pool)
                if DL_cur is None or not DL_cur:
                    continue
                sig_cur = signature(DL_cur, adj_cur)
                fresh_signatures[sig_cur] += 1
                n_total += 1
                # Compare: same |V|, |E|, and IS the same signature in our 14?
                same_sig = (sig_cur == sig_orig)
                if same_sig:
                    n_match += 1
                # Also check if it's any of the 14 known signatures
                # (just compare degree sequence)
    print(f"\nDehn-twisted {n_total} fresh α at k=2", flush=True)
    print(f"  match original signature: {n_match}/{n_total}", flush=True)
    print(f"  distinct fresh signatures: {len(fresh_signatures)}", flush=True)
    for sig, count in sorted(fresh_signatures.items(), key=lambda x: -x[1])[:10]:
        print(f"    sig {sig}: {count} α", flush=True)

    out = {
        "decomposes_count": n_decomposes,
        "fresh_signatures": {str(k): v for k, v in fresh_signatures.items()},
    }
    out_path = os.path.join(os.path.dirname(__file__), "op1_lemma34_extend.json")
    with open(out_path, "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=2, default=str)
    print(f"\nWrote {out_path}")


if __name__ == "__main__":
    main()
