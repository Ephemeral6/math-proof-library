"""Test Bonahon ADDITIVITY: for α = δ + δ' (componentwise), does it hold that
i(α, β) = i(δ, β) + i(δ', β) for all curves β?

If YES for cone cases (27 α): this PROVES Lemma 3.4 via Bonahon additivity.
If FAILS for G* cases (6 α): this confirms G* lacks the lamination decomp.

For each (α, δ, δ') decomposition triple, verify the additivity over all curves
in the DB.
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

    # (α, δ, δ') triples from Phase B for cone-α
    cone_triples = [
        (13, 1, 4), (40, 1, 5), (42, 6, 14), (68, 1, 22), (74, 6, 1),
        (113, 8, 24), (121, 5, 16), (122, 6, 17), (126, 18, 24), (127, 15, 19),
        (145, 4, 48), (156, 8, 51), (170, 8, 56), (201, 1, 65), (210, 6, 69),
        (212, 4, 14), (216, 14, 15), (222, 19, 6), (322, 22, 67), (359, 15, 114),
        (371, 16, 47), (373, 17, 49), (374, 18, 50), (376, 19, 52), (386, 54, 67),
        (387, 18, 135), (389, 45, 57),
    ]

    # G* α with their componentwise decompositions
    gstar_triples = [
        (25, 1, 8),    # α=25 weights [1,1,2,0,1,1] = c_1 + c_8
        # We need to find decomps for the other G* α
    ]
    # Find all decompositions for G*
    gstar = [25, 72, 149, 208, 217, 218]
    found_decomps = {}
    for ai in gstar:
        a_w = list(int(x) for x in tuple(eng._db["curves"][ai]))
        # Find a single (d1, d2) pair
        decomp = None
        for d1 in range(n_curves):
            if d1 == ai or f[d1] != 1:
                continue
            d1_w = list(int(x) for x in tuple(eng._db["curves"][d1]))
            target = tuple(a - d for a, d in zip(a_w, d1_w))
            if any(t < 0 for t in target):
                continue
            for d2 in range(n_curves):
                if d2 == ai or d2 == d1 or f[d2] != 1:
                    continue
                d2_w = tuple(int(x) for x in tuple(eng._db["curves"][d2]))
                if d2_w == target:
                    decomp = (ai, d1, d2)
                    break
            if decomp:
                break
        if decomp:
            found_decomps[ai] = decomp
    gstar_triples = list(found_decomps.values())

    # Bonahon additivity test:
    print("=== Bonahon additivity test ===\n")
    print("For (α, δ, δ'): test i(α, β) = i(δ, β) + i(δ', β) across all β in DB.\n")

    def test_triple(triple, name=""):
        ai, d1, d2 = triple
        n_pass = 0
        n_total = 0
        fails = []
        for b in range(n_curves):
            if b in (ai, d1, d2):
                continue
            i_a_b = cache.i(ai, b)
            i_d1_b = cache.i(d1, b)
            i_d2_b = cache.i(d2, b)
            n_total += 1
            if i_a_b == i_d1_b + i_d2_b:
                n_pass += 1
            else:
                if len(fails) < 3:
                    fails.append({"β": b, "i_α_β": i_a_b,
                                  "i_δ1_β": i_d1_b, "i_δ2_β": i_d2_b})
        print(f"  {name} (α={ai}, δ={d1}, δ'={d2}): "
              f"{n_pass}/{n_total} pass ({n_pass/n_total*100:.0f}%)",
              flush=True)
        if fails:
            for f_info in fails:
                print(f"    fail: β={f_info['β']}: "
                      f"i(α,β)={f_info['i_α_β']}, "
                      f"i(δ,β)+i(δ',β)={f_info['i_δ1_β']}+{f_info['i_δ2_β']}={f_info['i_δ1_β']+f_info['i_δ2_β']}",
                      flush=True)
        return n_pass == n_total

    print("-- Cone α (expected: additivity HOLDS) --")
    cone_pass = 0
    for triple in cone_triples:
        ok = test_triple(triple, name="cone")
        if ok:
            cone_pass += 1
    print(f"\n  Cone α additivity holds: {cone_pass}/{len(cone_triples)}\n",
          flush=True)

    print("-- G* α (expected: additivity FAILS) --")
    gstar_pass = 0
    for triple in gstar_triples:
        ok = test_triple(triple, name="G*")
        if ok:
            gstar_pass += 1
    print(f"\n  G* α additivity holds: {gstar_pass}/{len(gstar_triples)}",
          flush=True)

    out = {
        "cone_pass": cone_pass, "cone_total": len(cone_triples),
        "gstar_pass": gstar_pass, "gstar_total": len(gstar_triples),
    }
    out_path = os.path.join(os.path.dirname(__file__), "op1_lemma34_bonahon.json")
    with open(out_path, "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=2, default=str)
    print(f"\nWrote {out_path}")


if __name__ == "__main__":
    main()
