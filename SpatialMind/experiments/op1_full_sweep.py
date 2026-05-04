"""Exhaustive sweep on S_{1,2}: classify EVERY α at f≥2 in the database
into {chordal-only, cone-only, both, neither} and verify dismantlability.

Also probes the link between σ_α failure and chordal/cone status.
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
    IntersectionCache, build_descending_link,
    is_chordal_peo, has_cone_vertex, is_dismantlable,
    detect_induced_cycles,
)
from SpatialMind.experiments.op1_proof_probe import find_sigma_idx
from SpatialMind.domains.surface_topology.engine import SurfaceEngine


def main():
    db_path = os.path.join(
        ROOT, "workspace", "projects", "op1_geometry", "data_S_1_2.json")
    eng = SurfaceEngine(1, 2, database_path=db_path)
    cache = IntersectionCache(eng)
    f = cache.f

    alphas = [i for i in range(cache.n) if f[i] >= 2]
    print(f"Total α with f≥2: {len(alphas)}", flush=True)

    by_level = defaultdict(list)
    for ai in alphas:
        by_level[f[ai]].append(ai)

    rows = []
    counters = defaultdict(lambda: {
        "total": 0,
        "chordal_only": 0, "cone_only": 0, "both": 0, "neither": 0,
        "dismantlable": 0,
        "sigma_exists": 0, "sigma_is_cone": 0,
        "DL_size_min": None, "DL_size_max": None,
    })

    t0 = time.time()
    for ai in alphas:
        verts, adj = build_descending_link(cache, ai)
        if not verts:
            continue
        chordal, _ = is_chordal_peo(verts, adj)
        cone = has_cone_vertex(verts, adj)
        disman = is_dismantlable(verts, adj)
        sig = find_sigma_idx(cache, ai)
        sig_is_cone = (sig is not None and sig == cone)

        cat = ("chordal_only" if chordal and cone is None
               else "cone_only" if (not chordal) and cone is not None
               else "both" if chordal and cone is not None
               else "neither")

        rows.append({
            "alpha": ai, "level": f[ai], "DL_size": len(verts),
            "chordal": chordal, "cone": cone, "category": cat,
            "dismantlable": disman, "sigma": sig, "sigma_is_cone": sig_is_cone,
        })

        b = counters[f[ai]]
        b["total"] += 1
        b[cat] += 1
        if disman: b["dismantlable"] += 1
        if sig is not None: b["sigma_exists"] += 1
        if sig_is_cone: b["sigma_is_cone"] += 1
        ds = len(verts)
        if b["DL_size_min"] is None or ds < b["DL_size_min"]: b["DL_size_min"] = ds
        if b["DL_size_max"] is None or ds > b["DL_size_max"]: b["DL_size_max"] = ds

    elapsed = time.time() - t0
    print(f"Sweep done in {elapsed:.1f}s\n", flush=True)

    # Headline: per-level counts
    print(f"  k | n  | chord_only | cone_only | both | neither | disman | σ-exist | σ-cone | DL_size")
    print(f"----|----|------------|-----------|------|---------|--------|---------|--------|--------")
    for k in sorted(counters):
        b = counters[k]
        print(f"  {k:>2} | {b['total']:>2} | {b['chordal_only']:>10} | {b['cone_only']:>9} | {b['both']:>4} | {b['neither']:>7} | {b['dismantlable']:>6} | {b['sigma_exists']:>7} | {b['sigma_is_cone']:>6} | [{b['DL_size_min']},{b['DL_size_max']}]",
              flush=True)

    # Total
    total = sum(b["total"] for b in counters.values())
    total_neither = sum(b["neither"] for b in counters.values())
    total_disman = sum(b["dismantlable"] for b in counters.values())
    total_chord_or_cone = total - total_neither
    print(f"\nTOTAL: {total} α, {total_chord_or_cone} chordal-or-cone "
          f"({total_chord_or_cone/total*100:.1f}%), {total_disman} dismantlable "
          f"({total_disman/total*100:.1f}%), {total_neither} neither", flush=True)

    # Cross-tabulate σ-exists × category
    cross = defaultdict(int)
    for r in rows:
        cross[(r["category"], r["sigma"] is not None)] += 1
    print("\nCross-tab category × σ-exists:")
    for cat in ["chordal_only", "cone_only", "both", "neither"]:
        sig_yes = cross.get((cat, True), 0)
        sig_no = cross.get((cat, False), 0)
        print(f"  {cat:>13}: σ-exists={sig_yes}, σ-fails={sig_no}")

    # Save full data
    out = {
        "n_total": total,
        "by_level": {str(k): v for k, v in counters.items()},
        "rows": rows,
        "summary": {
            "total": total,
            "chordal_or_cone": total_chord_or_cone,
            "dismantlable": total_disman,
            "neither": total_neither,
        },
    }
    out_path = os.path.join(os.path.dirname(__file__), "op1_full_sweep.json")
    with open(out_path, "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=2, default=str)
    print(f"\nWrote {out_path}")


if __name__ == "__main__":
    main()
