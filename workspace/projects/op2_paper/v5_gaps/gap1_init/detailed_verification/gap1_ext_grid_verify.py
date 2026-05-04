"""
R*_ext 1000-grid verification.

R*_ext = [0.77, 0.82] x [3.18, 3.36] x [0.30, 0.42]

Same protocol as R* 1000-grid in gap1_detailed_verify.py:
  - 10x10x10 = 1000 grid points
  - mpmath dps = 100, T = 10000
  - 6 metrics per point
  - Multiprocessing (cpu_count - 1 workers)

Output: gap1_ext_grid_output.txt + gap1_ext_grid_results.json
"""

from __future__ import annotations

import json
import sys
import time
import statistics
from pathlib import Path
from multiprocessing import Pool, cpu_count

import mpmath as mp

sys.path.insert(0, str(Path(__file__).parent))
from gap1_detailed_verify import init_worker, simulate_point, DPS, T_MAX


# R*_ext box
EXT_BETA  = (0.77, 0.82)
EXT_ETAL  = (3.18, 3.36)
EXT_KAPPA = (0.30, 0.42)


def gen_grid_1000(beta_range, etaL_range, kappa_range):
    bmin, bmax = beta_range
    emin, emax = etaL_range
    kmin, kmax = kappa_range
    n = 10
    bs = [bmin + (bmax - bmin) * i / (n - 1) for i in range(n)]
    es = [emin + (emax - emin) * i / (n - 1) for i in range(n)]
    ks = [kmin + (kmax - kmin) * i / (n - 1) for i in range(n)]
    pts = []
    for i, b in enumerate(bs):
        for j, e in enumerate(es):
            for k, kp in enumerate(ks):
                pid = f"ext_grid_{i:02d}{j:02d}{k:02d}"
                pts.append((pid, b, e, kp, T_MAX, DPS))
    return pts


def gen_corners_box(beta_range, etaL_range, kappa_range):
    pts = []
    for i, b in enumerate(beta_range):
        for j, e in enumerate(etaL_range):
            for k, kk in enumerate(kappa_range):
                pid = f"ext_corner_{i}{j}{k}"
                pts.append((pid, b, e, kk, T_MAX, DPS))
    return pts


def main():
    here = Path(__file__).parent
    log_path = here / "gap1_ext_grid_output.txt"

    class Tee:
        def __init__(self, *streams): self.streams = streams
        def write(self, s):
            for st in self.streams: st.write(s); st.flush()
        def flush(self):
            for st in self.streams: st.flush()
    log_f = open(log_path, "w", encoding="utf-8")
    sys.stdout = Tee(sys.__stdout__, log_f)

    t0 = time.time()
    print("=" * 72)
    print(f"R*_ext 1000-grid verification — mpmath dps={DPS}, T={T_MAX}")
    print(f"R*_ext = {EXT_BETA} x {EXT_ETAL} x {EXT_KAPPA}")
    print(f"Volume = {(EXT_BETA[1]-EXT_BETA[0])*(EXT_ETAL[1]-EXT_ETAL[0])*(EXT_KAPPA[1]-EXT_KAPPA[0]):.4e}")
    print(f"Wall start: {time.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"CPU count: {cpu_count()}")
    print("=" * 72)

    corners = gen_corners_box(EXT_BETA, EXT_ETAL, EXT_KAPPA)
    grid = gen_grid_1000(EXT_BETA, EXT_ETAL, EXT_KAPPA)
    all_pts = corners + grid
    n_pts = len(all_pts)

    print(f"\nRunning {len(corners)} corner + {len(grid)} grid = {n_pts} points")
    n_workers = max(1, cpu_count() - 1)
    print(f"Using {n_workers} worker processes")
    print()

    t_sim = time.time()
    results = []
    with Pool(processes=n_workers, initializer=init_worker, initargs=(DPS,)) as pool:
        completed = 0
        for r in pool.imap_unordered(simulate_point, all_pts, chunksize=4):
            results.append(r)
            completed += 1
            if completed % 50 == 0 or completed == n_pts:
                el = time.time() - t_sim
                eta = el / completed * (n_pts - completed)
                print(f"  [{completed:4d}/{n_pts}]  elapsed={el:7.1f}s  eta={eta:7.1f}s  "
                      f"last={r['id']}  verdict={r['verdict']}")

    results.sort(key=lambda r: r["id"])
    corner_results = [r for r in results if r["id"].startswith("ext_corner_")]
    grid_results = [r for r in results if r["id"].startswith("ext_grid_")]

    # Summary
    print()
    print("=" * 72)
    print("SUMMARY")
    print("=" * 72)
    n_cycle_c = sum(1 for r in corner_results if r["verdict"] == "cycle")
    n_cycle_g = sum(1 for r in grid_results if r["verdict"] == "cycle")
    n_decay_g = sum(1 for r in grid_results if r["verdict"] == "decay")
    n_other_g = sum(1 for r in grid_results if r["verdict"] == "other")
    print(f"  Corners: {n_cycle_c}/{len(corner_results)} cycle")
    print(f"  Grid:    {n_cycle_g}/{len(grid_results)} cycle  "
          f"({n_decay_g} decay, {n_other_g} other)")

    # Failures detail
    failures = [r for r in grid_results if r["verdict"] != "cycle"]
    if failures:
        print(f"\n  GRID FAILURES ({len(failures)} points):")
        for r in failures:
            print(f"    {r['id']}  b={r['beta']} etaL={r['etaL']} kap={r['kappa']}  "
                  f"|x_T|={r['norm_T'][:30]}  {r['verdict']}")
    else:
        print("\n  ALL 1000 GRID POINTS CYCLE ✓")

    # Statistics
    p3s = [float(r['period3_residual']) for r in grid_results]
    rels = [float(r['rel_norm_dev']) for r in grid_results]
    print(f"\n  Grid period-3 residual: min={min(p3s):.3e} max={max(p3s):.3e} "
          f"mean={statistics.mean(p3s):.3e} median={statistics.median(p3s):.3e}")
    print(f"  Grid rel norm dev:      min={min(rels):.3e} max={max(rels):.3e} "
          f"mean={statistics.mean(rels):.3e} median={statistics.median(rels):.3e}")

    # Cone distribution
    from collections import Counter
    cones_g = Counter(r['cone_membership'] for r in grid_results)
    print(f"  Grid cone distribution: {dict(cones_g)}")

    # Detail corner table
    print("\n--- Corner detail (8 corners) ---")
    print(f"  {'id':18s}  {'beta':6s} {'etaL':6s} {'kap':6s}  {'norm_T':14s} {'p3_res':14s} cone v")
    for r in corner_results:
        print(f"  {r['id']:18s}  {r['beta']:6s} {r['etaL']:6s} {r['kappa']:6s}  "
              f"{r['norm_T'][:13]:14s} {r['period3_residual'][:13]:14s} "
              f"{r['cone_membership']:>2}  {r['verdict']}")

    out = {
        "R_star_ext": {"beta": list(EXT_BETA), "etaL": list(EXT_ETAL), "kappa": list(EXT_KAPPA),
                       "volume": (EXT_BETA[1]-EXT_BETA[0])*(EXT_ETAL[1]-EXT_ETAL[0])*(EXT_KAPPA[1]-EXT_KAPPA[0])},
        "corners": corner_results,
        "grid": grid_results,
        "summary": {
            "corner_cycle": n_cycle_c, "corner_total": len(corner_results),
            "grid_cycle": n_cycle_g, "grid_decay": n_decay_g, "grid_other": n_other_g,
            "grid_total": len(grid_results),
            "all_pass": n_cycle_c == len(corner_results) and n_cycle_g == len(grid_results),
            "grid_failures": [{"id": r["id"], "beta": r["beta"], "etaL": r["etaL"],
                                "kappa": r["kappa"], "norm_T": r["norm_T"],
                                "verdict": r["verdict"]} for r in failures],
            "p3_max": max(p3s), "p3_mean": statistics.mean(p3s),
            "rel_max": max(rels), "rel_mean": statistics.mean(rels),
        },
        "wall_time": time.time() - t0,
    }

    print(f"\nTotal wall time: {out['wall_time']:.1f} s")
    out_path = here / "gap1_ext_grid_results.json"
    with open(out_path, "w", encoding="utf-8") as fp:
        json.dump(out, fp, indent=2, default=str)
    print(f"Saved JSON to {out_path}")

    sys.stdout = sys.__stdout__
    log_f.close()


if __name__ == "__main__":
    main()
