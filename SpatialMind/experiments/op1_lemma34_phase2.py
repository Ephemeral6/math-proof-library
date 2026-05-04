"""Phase 2: explore the implication of δ ≤ α componentwise.

Path A: Test the BONAHON MONOTONICITY claim:
  if δ ≤ α componentwise, then i(δ, β) ≤ i(α, β) for any curve β.

If TRUE, this is the structural fact that closes Lemma 3.4:
  - For any cone-fail-cone α at k=2 config (b), we have δ ≤ α (Phase 1).
  - For any β ∈ DL(α), i(α, β) ≤ 1 (definition of DL).
  - Hence i(δ, β) ≤ 1 → δ is a cone vertex of DL.

Path B: For G* cases (no cone), test whether NO level-1 curve δ ≤ α exists.
  This would explain why G* doesn't have a cone.

Path C: Cross-check with all 309 α (not just k=2): does the cone vertex
  always satisfy δ ≤ α (when DL has a cone)?
"""

from __future__ import annotations

import json
import os
import sys
from collections import Counter

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, ROOT)

from SpatialMind.experiments.op1_coe_run import (
    IntersectionCache, build_descending_link, has_cone_vertex,
)
from SpatialMind.domains.surface_topology.engine import SurfaceEngine


def main():
    db_path = os.path.join(ROOT, "workspace", "projects", "op1_geometry",
                           "data_S_1_2.json")
    eng = SurfaceEngine(1, 2, database_path=db_path)
    cache = IntersectionCache(eng)
    f = cache.f
    n_curves = cache.n
    print(f"Database: {n_curves} curves on S_{{1,2}}", flush=True)

    # ----- Path A: test Bonahon monotonicity universally -----
    print("\n=== Path A: Bonahon monotonicity test ===\n", flush=True)
    print("For each (a, d) with d ≤ a componentwise (a, d in DB), test if "
          "i(d, b) ≤ i(a, b) for all b.\n")
    n_tests = 0
    n_fails = 0
    failure_examples = []
    # Sample pairs (a, d) where d ≤ a componentwise.
    monotone_pairs = []
    for a_idx in range(min(n_curves, 100)):  # cap for speed
        a_w = list(int(x) for x in tuple(eng._db["curves"][a_idx]))
        for d_idx in range(n_curves):
            if d_idx == a_idx:
                continue
            d_w = list(int(x) for x in tuple(eng._db["curves"][d_idx]))
            if all(d <= a for d, a in zip(d_w, a_w)):
                monotone_pairs.append((a_idx, d_idx))
                if len(monotone_pairs) >= 200:
                    break
        if len(monotone_pairs) >= 200:
            break
    print(f"Found {len(monotone_pairs)} monotone pairs (d ≤ a) to test\n",
          flush=True)

    for a_idx, d_idx in monotone_pairs:
        # For each b in DB, check i(d, b) <= i(a, b)
        for b_idx in range(min(n_curves, 50)):
            if b_idx == a_idx or b_idx == d_idx:
                continue
            i_a_b = cache.i(a_idx, b_idx)
            i_d_b = cache.i(d_idx, b_idx)
            n_tests += 1
            if i_d_b > i_a_b:
                n_fails += 1
                if len(failure_examples) < 5:
                    failure_examples.append({
                        "a": a_idx, "d": d_idx, "b": b_idx,
                        "i_a_b": i_a_b, "i_d_b": i_d_b,
                    })
        if n_fails >= 10:  # stop early on failure
            break

    print(f"Tests: {n_tests}, failures: {n_fails}", flush=True)
    if failure_examples:
        print("Failures:")
        for ex in failure_examples:
            print(f"  a={ex['a']}, d={ex['d']}, b={ex['b']}: "
                  f"i(a,b)={ex['i_a_b']}, i(d,b)={ex['i_d_b']}",
                  flush=True)
    else:
        print("NO FAILURES — Bonahon monotonicity HOLDS empirically",
              flush=True)

    # ----- Path B: G* cases - is there NO δ ≤ α at level 1? -----
    print("\n=== Path B: G* α — check no level-1 δ ≤ α exists ===\n",
          flush=True)
    g_star_alphas = [25, 72, 149, 208, 217, 218]
    for ai in g_star_alphas:
        a_w = list(int(x) for x in tuple(eng._db["curves"][ai]))
        # Find ALL level-1 curves c in DB with c ≤ α componentwise.
        candidates = []
        for c_idx in range(n_curves):
            if c_idx == ai:
                continue
            if f[c_idx] != 1:
                continue
            c_w = list(int(x) for x in tuple(eng._db["curves"][c_idx]))
            if all(c <= a for c, a in zip(c_w, a_w)):
                candidates.append(c_idx)
        print(f"α={ai}: |α|={sum(a_w)}, level-1 curves c ≤ α: "
              f"{len(candidates)} (= {candidates[:8]}{'...' if len(candidates) > 8 else ''})",
              flush=True)

    # ----- Path C: cross-check on ALL 309 α — when DL has a cone, does cone ≤ α? -----
    print("\n=== Path C: cone ≤ α universally? ===\n", flush=True)
    n_total = 0
    n_with_cone = 0
    n_cone_le_alpha = 0
    n_cone_le_α_at_k2 = 0
    for ai in range(n_curves):
        if f[ai] < 2:
            continue
        DL, adj = build_descending_link(cache, ai)
        if not DL:
            continue
        cone = has_cone_vertex(DL, adj)
        n_total += 1
        if cone is None:
            continue
        n_with_cone += 1
        a_w = list(int(x) for x in tuple(eng._db["curves"][ai]))
        c_w = list(int(x) for x in tuple(eng._db["curves"][cone]))
        if all(c <= a for c, a in zip(c_w, a_w)):
            n_cone_le_alpha += 1
            if f[ai] == 2:
                n_cone_le_α_at_k2 += 1

    print(f"Total α with f≥2: {n_total}", flush=True)
    print(f"  α with cone vertex: {n_with_cone}", flush=True)
    print(f"  α where cone ≤ α componentwise: {n_cone_le_alpha}",
          flush=True)
    print(f"  rate cone ≤ α (overall): {n_cone_le_alpha/max(1,n_with_cone)*100:.1f}%",
          flush=True)
    print(f"  α at k=2 with cone ≤ α: {n_cone_le_α_at_k2}",
          flush=True)


if __name__ == "__main__":
    main()
