"""
Extra check: try several moderate joint expansions of R*, find the
largest one whose 8-corners + center all cycle.
"""
import json
import sys
import time
from pathlib import Path
from multiprocessing import Pool, cpu_count

import mpmath as mp

sys.path.insert(0, str(Path(__file__).parent))
from gap1_detailed_verify import init_worker, simulate_point, DPS, T_MAX
from gap1_audit_verify import gen_box_9


CANDIDATES = [
    # (label, beta_range, etaL_range, kappa_range)
    ("R*",              (0.78, 0.82),  (3.20, 3.32),  (0.375, 0.400)),
    ("R*_mod_a",        (0.77, 0.82),  (3.15, 3.40),  (0.35,  0.42)),
    ("R*_mod_b",        (0.77, 0.82),  (3.18, 3.36),  (0.30,  0.42)),
    ("R*_mod_c",        (0.78, 0.82),  (3.15, 3.40),  (0.30,  0.42)),
    ("R*_mod_d_beta",   (0.76, 0.82),  (3.20, 3.32),  (0.375, 0.400)),
    ("R*_mod_e_etaL",   (0.78, 0.82),  (3.15, 3.45),  (0.375, 0.400)),
    ("R*_mod_f_kappa",  (0.78, 0.82),  (3.20, 3.32),  (0.30,  0.42)),
    ("R*_mod_g",        (0.77, 0.82),  (3.18, 3.40),  (0.35,  0.42)),
    ("R*_mod_h",        (0.77, 0.82),  (3.18, 3.36),  (0.35,  0.41)),
    ("R*_mod_i_etaLk",  (0.78, 0.82),  (3.15, 3.45),  (0.30,  0.42)),
]


def test_candidate(label, b_range, e_range, k_range, pool):
    pts = gen_box_9(b_range, e_range, k_range, tag_prefix=f"{label}_")
    results = list(pool.imap_unordered(simulate_point, pts, chunksize=1))
    n_cycle = sum(1 for r in results if r["verdict"] == "cycle")
    vol = (b_range[1] - b_range[0]) * (e_range[1] - e_range[0]) * (k_range[1] - k_range[0])
    return n_cycle, len(results), vol, results


def main():
    here = Path(__file__).parent
    log_path = here / "gap1_audit_extra_output.txt"
    log_f = open(log_path, "w", encoding="utf-8")

    class Tee:
        def __init__(self, *streams): self.streams = streams
        def write(self, s):
            for st in self.streams: st.write(s); st.flush()
        def flush(self):
            for st in self.streams: st.flush()
    sys.stdout = Tee(sys.__stdout__, log_f)

    n_workers = max(1, cpu_count() - 1)
    print(f"Joint-expansion candidate audit (mpmath dps={DPS}, T={T_MAX})")
    print(f"Workers: {n_workers}")
    print()

    out = []
    with Pool(processes=n_workers, initializer=init_worker, initargs=(DPS,)) as pool:
        for (label, br, er, kr) in CANDIDATES:
            t0 = time.time()
            n_cycle, n_total, vol, results = test_candidate(label, br, er, kr, pool)
            ratio = vol / 1.20e-4
            ok = (n_cycle == n_total)
            elapsed = time.time() - t0
            print(f"{label:20s} β:{list(br)} ηL:{list(er)} κ:{list(kr)}  "
                  f"vol={vol:.4e} ({ratio:.2f}x)  9-cycle: {n_cycle}/{n_total}  "
                  f"{'PASS' if ok else 'FAIL'}  ({elapsed:.1f}s)")
            if not ok:
                fails = [r for r in results if r["verdict"] != "cycle"]
                for r in fails:
                    print(f"      FAIL: {r['id']} b={r['beta']} etaL={r['etaL']} kap={r['kappa']}  "
                          f"|x_T|={r['norm_T'][:14]}  {r['verdict']}")
            out.append({"label": label, "box": [list(br), list(er), list(kr)],
                        "volume": vol, "ratio_to_R_star": ratio,
                        "n_cycle": n_cycle, "n_total": n_total, "ok": ok,
                        "fails": [{"id": r["id"], "beta": r["beta"], "etaL": r["etaL"],
                                   "kappa": r["kappa"], "norm_T": r["norm_T"][:30],
                                   "verdict": r["verdict"]} for r in results if r["verdict"] != "cycle"]})

    print()
    # Find largest passing
    passing = [c for c in out if c["ok"]]
    if passing:
        best = max(passing, key=lambda c: c["volume"])
        print(f"BEST passing joint box: {best['label']}  vol={best['volume']:.4e}  ({best['ratio_to_R_star']:.2f}x R*)")
        print(f"  {best['box']}")
    else:
        print("Only R* itself passes.")

    out_path = here / "gap1_audit_extra_results.json"
    with open(out_path, "w", encoding="utf-8") as fp:
        json.dump(out, fp, indent=2, default=str)
    print(f"\nSaved results to {out_path}")

    sys.stdout = sys.__stdout__
    log_f.close()


if __name__ == "__main__":
    main()
