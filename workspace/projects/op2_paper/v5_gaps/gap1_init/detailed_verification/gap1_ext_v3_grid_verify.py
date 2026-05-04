"""
R*_ext_v3 1000-grid verification.

R*_ext_v2 had 1 fail at (β=0.82, ηL=3.18, κ=0.414). Raise ηL_lo to 3.20.

R*_ext_v3 = [0.77, 0.82] x [3.20, 3.36] x [0.37, 0.42]
Volume = 0.05 * 0.16 * 0.05 = 4.0e-4 (3.33x R*).
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
from gap1_ext_grid_verify import gen_corners_box, gen_grid_1000


# R*_ext_v3 box
EXT3_BETA  = (0.77, 0.82)
EXT3_ETAL  = (3.20, 3.36)
EXT3_KAPPA = (0.37, 0.42)


def main():
    here = Path(__file__).parent
    log_path = here / "gap1_ext_v3_grid_output.txt"

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
    print(f"R*_ext_v3 1000-grid verification — mpmath dps={DPS}, T={T_MAX}")
    print(f"R*_ext_v3 = {EXT3_BETA} x {EXT3_ETAL} x {EXT3_KAPPA}")
    vol = (EXT3_BETA[1]-EXT3_BETA[0])*(EXT3_ETAL[1]-EXT3_ETAL[0])*(EXT3_KAPPA[1]-EXT3_KAPPA[0])
    print(f"Volume = {vol:.4e}  (R* = 1.20e-4, ratio = {vol/1.2e-4:.2f}x)")
    print(f"Wall start: {time.strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 72)

    corners = gen_corners_box(EXT3_BETA, EXT3_ETAL, EXT3_KAPPA)
    grid = gen_grid_1000(EXT3_BETA, EXT3_ETAL, EXT3_KAPPA)
    all_pts = corners + grid
    n_pts = len(all_pts)

    n_workers = max(1, cpu_count() - 1)
    print(f"\nRunning {n_pts} points on {n_workers} workers")
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
                      f"verdict={r['verdict']}")

    results.sort(key=lambda r: r["id"])
    corner_results = [r for r in results if r["id"].startswith("ext_corner_")]
    grid_results = [r for r in results if r["id"].startswith("ext_grid_")]

    n_cycle_c = sum(1 for r in corner_results if r["verdict"] == "cycle")
    n_cycle_g = sum(1 for r in grid_results if r["verdict"] == "cycle")
    n_decay_g = sum(1 for r in grid_results if r["verdict"] == "decay")
    n_other_g = sum(1 for r in grid_results if r["verdict"] == "other")

    print()
    print("=" * 72)
    print("SUMMARY")
    print("=" * 72)
    print(f"  Corners: {n_cycle_c}/{len(corner_results)} cycle")
    print(f"  Grid:    {n_cycle_g}/{len(grid_results)} cycle  ({n_decay_g} decay, {n_other_g} other)")

    failures = [r for r in grid_results if r["verdict"] != "cycle"]
    if failures:
        print(f"\n  GRID FAILURES ({len(failures)} points):")
        for r in failures:
            print(f"    {r['id']}  b={r['beta']} etaL={r['etaL']} kap={r['kappa']}  "
                  f"|x_T|={r['norm_T'][:30]}  {r['verdict']}")
    else:
        print("\n  ALL 1000 GRID POINTS CYCLE ✓")

    p3s = [float(r['period3_residual']) for r in grid_results]
    rels = [float(r['rel_norm_dev']) for r in grid_results]
    print(f"\n  Grid p3 res: max={max(p3s):.3e} mean={statistics.mean(p3s):.3e}")
    print(f"  Grid rel:    max={max(rels):.3e} mean={statistics.mean(rels):.3e}")

    out = {
        "R_star_ext_v3": {"beta": list(EXT3_BETA), "etaL": list(EXT3_ETAL), "kappa": list(EXT3_KAPPA),
                          "volume": vol, "ratio_to_R_star": vol/1.2e-4},
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
    out_path = here / "gap1_ext_v3_grid_results.json"
    with open(out_path, "w", encoding="utf-8") as fp:
        json.dump(out, fp, indent=2, default=str)
    print(f"Saved JSON to {out_path}")

    sys.stdout = sys.__stdout__
    log_f.close()


if __name__ == "__main__":
    main()
