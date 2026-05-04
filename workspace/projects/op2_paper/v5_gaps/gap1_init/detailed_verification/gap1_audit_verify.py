"""
Gap 1 final audit verification.

Tasks:
  1. Expand R* in 6 directions, find tipping point in each.
  2. (combined with Task 1's kappa-lo scan) test cycling at small kappa.
  3. (combined with Task 1's kappa-lo scan, plus dedicated points)
  4. Verify 1/23 constant: at each of 8 R* corners, T=1..20 ratio table.

Reuses geometry from gap1_detailed_verify.py.

Run: python gap1_audit_verify.py
Output: gap1_audit_output.txt + gap1_audit_results.json
"""

from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path
from multiprocessing import Pool, cpu_count

import mpmath as mp

# Re-use the simulator from gap1_detailed_verify.py
sys.path.insert(0, str(Path(__file__).parent))
from gap1_detailed_verify import (
    init_worker, simulate_point, lam_val, e_vec, goujaud_vertices,
    f0_grad, f0_value, shb_step, matnorm, DPS, T_MAX,
)


# Original R*
R_BETA  = (0.78, 0.82)
R_ETAL  = (3.20, 3.32)
R_KAPPA = (0.375, 0.400)


# ============================================================
# Helpers
# ============================================================

def gen_box_9(beta_range, etaL_range, kappa_range, tag_prefix=""):
    """Generate 8 corners + 1 center of a 3-D box."""
    pts = []
    for i, b in enumerate(beta_range):
        for j, e in enumerate(etaL_range):
            for k, kk in enumerate(kappa_range):
                pid = f"{tag_prefix}corner_{i}{j}{k}"
                pts.append((pid, b, e, kk, T_MAX, DPS))
    bc = (beta_range[0]  + beta_range[1]) / 2
    ec = (etaL_range[0]  + etaL_range[1]) / 2
    kc = (kappa_range[0] + kappa_range[1]) / 2
    pts.append((f"{tag_prefix}center", bc, ec, kc, T_MAX, DPS))
    return pts


def is_F_feasible(beta, etaL):
    """OP-2 v5 §1.3: gamma_c(beta) < etaL < 2(1+beta) for K=3 cycling."""
    gc = 3 * (1 + beta + beta**2) / (1 + 2 * beta)
    return (etaL > gc) and (etaL < 2 * (1 + beta))


# ============================================================
# Task 1: Expand R* in 6 directions
# ============================================================

# Step plans for each direction. If a step makes the box infeasible
# (corner outside F_{K=3}), stop early.
STEPS = {
    "beta_lo":  [0.77, 0.76, 0.75, 0.74, 0.73, 0.72, 0.70, 0.65, 0.60, 0.55],
    "beta_hi":  [0.83, 0.84, 0.85, 0.86, 0.87, 0.88, 0.89, 0.90, 0.92, 0.95],
    "etaL_lo":  [3.19, 3.18, 3.15, 3.10, 3.05, 3.00, 2.95, 2.90, 2.85, 2.80],
    "etaL_hi":  [3.33, 3.35, 3.40, 3.45, 3.50, 3.55],   # bounded by 2(1+β_lo)
    "kappa_lo": [0.37, 0.36, 0.35, 0.30, 0.25, 0.20, 0.15, 0.10, 0.05, 0.02, 0.01],
    "kappa_hi": [0.41, 0.42, 0.45, 0.50, 0.55, 0.60],
}


def expand_one_direction(direction, pool):
    """Try expanding one boundary, step by step. Return last-cycling boundary
    and full per-step results (so we can audit).
    """
    print(f"\n--- Expanding {direction} ---")
    history = []
    last_ok = {
        "beta_lo":  R_BETA[0],
        "beta_hi":  R_BETA[1],
        "etaL_lo":  R_ETAL[0],
        "etaL_hi":  R_ETAL[1],
        "kappa_lo": R_KAPPA[0],
        "kappa_hi": R_KAPPA[1],
    }[direction]

    for step in STEPS[direction]:
        # Build candidate box: replace one boundary with `step`, others = R* values
        b_lo, b_hi = R_BETA
        e_lo, e_hi = R_ETAL
        k_lo, k_hi = R_KAPPA
        if direction == "beta_lo":  b_lo = step
        if direction == "beta_hi":  b_hi = step
        if direction == "etaL_lo":  e_lo = step
        if direction == "etaL_hi":  e_hi = step
        if direction == "kappa_lo": k_lo = step
        if direction == "kappa_hi": k_hi = step

        # Order check
        if b_lo >= b_hi or e_lo >= e_hi or k_lo >= k_hi:
            print(f"  step {step}: candidate box invalid (lo >= hi). STOP.")
            history.append({"step": step, "feasible": False, "reason": "box_invalid"})
            break

        # F-feasibility check on the 4 (β, ηL) corners (κ doesn't enter feasibility)
        feas_corners = [(b_lo, e_lo), (b_lo, e_hi), (b_hi, e_lo), (b_hi, e_hi)]
        infeasible = [pq for pq in feas_corners if not is_F_feasible(*pq)]
        if infeasible:
            print(f"  step {step}: F-infeasible at {infeasible[0]}. STOP.")
            history.append({"step": step, "feasible": False, "reason": "F_infeasible",
                            "infeasible_corner": infeasible[0]})
            break

        # Run 9 simulations
        pts = gen_box_9((b_lo, b_hi), (e_lo, e_hi), (k_lo, k_hi),
                        tag_prefix=f"{direction}_{step}_")
        results = list(pool.imap_unordered(simulate_point, pts, chunksize=1))
        results.sort(key=lambda r: r["id"])

        n_cycle = sum(1 for r in results if r["verdict"] == "cycle")
        verdicts = [r["verdict"] for r in results]
        all_ok = all(v == "cycle" for v in verdicts)

        # Pretty print
        print(f"  step {step}:  box=[{b_lo}, {b_hi}]x[{e_lo}, {e_hi}]x[{k_lo}, {k_hi}]  "
              f"9-cycle: {n_cycle}/9  verdicts: {verdicts}")
        history.append({"step": step,
                        "box": [(b_lo, b_hi), (e_lo, e_hi), (k_lo, k_hi)],
                        "results_summary": {"cycle": n_cycle, "decay": sum(1 for v in verdicts if v=="decay"),
                                            "other": sum(1 for v in verdicts if v=="other")},
                        "verdicts": verdicts,
                        "feasible": True})

        if all_ok:
            last_ok = step
        else:
            # Find which corners failed for diagnostic
            failed = [r for r in results if r["verdict"] != "cycle"]
            print(f"    FAIL at step {step}. Failed points:")
            for r in failed:
                print(f"      {r['id']}: b={r['beta']} etaL={r['etaL']} kap={r['kappa']}  "
                      f"|x_T|={r['norm_T'][:12]}  verdict={r['verdict']}")
            print(f"  STOP. Last valid {direction} = {last_ok}.")
            history[-1]["fail_details"] = [
                {"id": r["id"], "beta": r["beta"], "etaL": r["etaL"], "kappa": r["kappa"],
                 "norm_T": r["norm_T"][:25], "verdict": r["verdict"]} for r in failed
            ]
            break
    else:
        print(f"  All {len(STEPS[direction])} steps passed. Last valid {direction} = {last_ok}.")

    return last_ok, history


# ============================================================
# Task 4: Bias-ratio table at 8 R* corners, T=1..20
# ============================================================

def task4_bias_ratio_table():
    """For each of 8 R* corners + the anchor (0.8, 3.247, 0.387), sweep
    T=1..20 and compute ratio = T * (mu/2)|x_T|^2 / (kappa L D^2).

    Returns: dict {corner_id: {T: ratio}}.
    """
    print("\n" + "=" * 72)
    print("Task 4: Bias-ratio table at 8 R* corners, T=1..20  (dps=100)")
    print("=" * 72)

    mp.mp.dps = DPS
    L = mp.mpf(1)
    D = mp.mpf(1)
    lam = lam_val()

    corners = []
    for i, bs in enumerate(R_BETA):
        for j, es in enumerate(R_ETAL):
            for k, ks in enumerate(R_KAPPA):
                corners.append((f"corner_{i}{j}{k}", bs, es, ks))
    corners.append(("anchor", 0.8, 3.247, 0.387))

    table = {}  # {corner_id: {t: ratio}}

    print(f"\n{'corner':14s} {'beta':6s} {'etaL':7s} {'kap':6s}  ", end="")
    for t in range(1, 21):
        print(f"  T={t:2d}    ", end="")
    print()

    for (cid, bs, es, ks) in corners:
        beta = mp.mpf(str(bs))
        etaL = mp.mpf(str(es))
        kappa = mp.mpf(str(ks))
        eta = etaL / L
        mu = kappa * L
        verts = goujaud_vertices(beta, eta, mu, L)

        x_prev = lam * e_vec(0)
        x_curr = lam * e_vec(0)
        ratios = {}
        for t in range(1, 21):
            x_new = shb_step(x_curr, x_prev, eta, mu, beta, verts, L)
            x_prev = x_curr
            x_curr = x_new
            n2 = x_curr[0,0]**2 + x_curr[1,0]**2
            f_floor = (mu / 2) * n2
            ratio = t * f_floor / (kappa * L * D * D)
            ratios[t] = float(ratio)
        table[cid] = {"beta": bs, "etaL": es, "kappa": ks, "ratios": ratios}

        print(f"{cid:14s} {bs:<6} {es:<7} {ks:<6}  ", end="")
        for t in range(1, 21):
            print(f"{ratios[t]:>8.4f}  ", end="")
        print()

    # Per-corner binding T and min ratio
    print(f"\n{'corner':14s}  binding T   min ratio   c (=1/min ratio)")
    binding_summary = {}
    for cid, d in table.items():
        rs = d["ratios"]
        binding_t = min(rs, key=lambda t: rs[t])
        min_r = rs[binding_t]
        binding_summary[cid] = {"binding_t": binding_t, "min_ratio": min_r}
        print(f"{cid:14s}  {binding_t:>6d}      {min_r:>8.4f}    {1/min_r:>8.4f}")

    # T>=10 worst across all corners
    t10_min = min(table[cid]["ratios"][t] for cid in table for t in range(10, 21))
    print(f"\nMin ratio over t in [10, 20] across all 9 corners+anchor: {t10_min:.4f}")
    print(f"So c >= 1/10 valid for T >= 10? {t10_min >= 0.1}")

    return {"table": table, "binding_summary": binding_summary,
            "min_ratio_t_geq_10_all_corners": t10_min}


# ============================================================
# Task 3: Small-κ at anchor (covered in Task 1 kappa_lo, but add specific points)
# ============================================================

def task3_small_kappa(pool):
    """Test cycling at (β=0.80, ηL=3.26, κ ∈ {0.3, 0.2, 0.1, 0.05, 0.01})."""
    print("\n" + "=" * 72)
    print("Task 3: Small-κ tests at (β=0.80, ηL=3.26)")
    print("=" * 72)
    pts = []
    for k in [0.3, 0.2, 0.1, 0.05, 0.01]:
        pts.append((f"smallk_{k}", 0.80, 3.26, k, T_MAX, DPS))
    results = list(pool.imap_unordered(simulate_point, pts, chunksize=1))
    results.sort(key=lambda r: r["id"])
    print(f"{'id':14s}  {'kappa':6s}  {'norm_T':14s} {'p3_res':14s} {'rel_norm':14s}  verdict")
    for r in results:
        print(f"{r['id']:14s}  {r['kappa']:<6s}  {r['norm_T'][:13]:14s} {r['period3_residual'][:13]:14s} "
              f"{r['rel_norm_dev'][:13]:14s}  {r['verdict']}")
    return results


# ============================================================
# Driver
# ============================================================

def main():
    here = Path(__file__).parent
    log_path = here / "gap1_audit_output.txt"

    class Tee:
        def __init__(self, *streams):
            self.streams = streams
        def write(self, s):
            for st in self.streams:
                st.write(s); st.flush()
        def flush(self):
            for st in self.streams:
                st.flush()

    log_f = open(log_path, "w", encoding="utf-8")
    sys.stdout = Tee(sys.__stdout__, log_f)

    t0 = time.time()
    print("=" * 72)
    print(f"Gap 1 final audit — mpmath dps={DPS}, T={T_MAX}")
    print(f"R* = {R_BETA} x {R_ETAL} x {R_KAPPA}")
    print(f"Wall start: {time.strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 72)

    out = {"R_star": {"beta": list(R_BETA), "etaL": list(R_ETAL), "kappa": list(R_KAPPA),
                     "volume": (R_BETA[1]-R_BETA[0])*(R_ETAL[1]-R_ETAL[0])*(R_KAPPA[1]-R_KAPPA[0])}}

    n_workers = max(1, cpu_count() - 1)
    print(f"Using {n_workers} worker processes.")

    with Pool(processes=n_workers, initializer=init_worker, initargs=(DPS,)) as pool:
        # Task 1: expansion in 6 directions
        print("\n" + "=" * 72)
        print("Task 1: Expand R* in 6 directions")
        print("=" * 72)
        expansion = {}
        for direction in ["beta_lo", "beta_hi", "etaL_lo", "etaL_hi", "kappa_lo", "kappa_hi"]:
            last_ok, history = expand_one_direction(direction, pool)
            expansion[direction] = {"last_valid": last_ok, "history": history}
        out["task1_expansion"] = expansion

        # Form R*_extended
        ext_box = {
            "beta":  (expansion["beta_lo"]["last_valid"],  expansion["beta_hi"]["last_valid"]),
            "etaL":  (expansion["etaL_lo"]["last_valid"],  expansion["etaL_hi"]["last_valid"]),
            "kappa": (expansion["kappa_lo"]["last_valid"], expansion["kappa_hi"]["last_valid"]),
        }
        ext_vol = ((ext_box["beta"][1] - ext_box["beta"][0]) *
                   (ext_box["etaL"][1] - ext_box["etaL"][0]) *
                   (ext_box["kappa"][1] - ext_box["kappa"][0]))
        out["task1_R_star_extended_univariate"] = {
            "beta": list(ext_box["beta"]),
            "etaL": list(ext_box["etaL"]),
            "kappa": list(ext_box["kappa"]),
            "volume": ext_vol,
            "expansion_factor": ext_vol / out["R_star"]["volume"],
        }
        print("\n" + "=" * 72)
        print("Univariate expansion result:")
        print(f"  R*_ext = β:[{ext_box['beta'][0]}, {ext_box['beta'][1]}]  "
              f"ηL:[{ext_box['etaL'][0]}, {ext_box['etaL'][1]}]  "
              f"κ:[{ext_box['kappa'][0]}, {ext_box['kappa'][1]}]")
        print(f"  Volume: {ext_vol:.5e}")
        print(f"  Expansion vs R*: {ext_vol / out['R_star']['volume']:.2f}x")
        print("=" * 72)

        # Verify R*_extended's 8 corners + 1 center as a JOINT box (not univariate)
        print("\nVerifying R*_extended jointly (8 corners + center):")
        joint_pts = gen_box_9(ext_box["beta"], ext_box["etaL"], ext_box["kappa"],
                              tag_prefix="ext_joint_")
        # Re-check F-feasibility
        feas_ok = all(is_F_feasible(b, e) for b in ext_box["beta"] for e in ext_box["etaL"])
        if not feas_ok:
            print("  WARNING: R*_extended joint corners NOT all F-feasible.")
        joint_results = list(pool.imap_unordered(simulate_point, joint_pts, chunksize=1))
        joint_results.sort(key=lambda r: r["id"])
        for r in joint_results:
            print(f"  {r['id']:24s}  b={r['beta']} etaL={r['etaL']} kap={r['kappa']}  "
                  f"|x_T|={r['norm_T'][:11]}  p3={r['period3_residual'][:11]}  {r['verdict']}")
        n_joint_cycle = sum(1 for r in joint_results if r["verdict"] == "cycle")
        out["task1_R_star_extended_joint_check"] = {
            "n_cycle": n_joint_cycle,
            "n_total": len(joint_results),
            "results": [{"id": r["id"], "beta": r["beta"], "etaL": r["etaL"],
                         "kappa": r["kappa"], "norm_T": r["norm_T"],
                         "period3_residual": r["period3_residual"],
                         "verdict": r["verdict"]} for r in joint_results],
        }
        print(f"\nR*_extended joint cycling: {n_joint_cycle}/{len(joint_results)}")

        # Task 3: Small-κ
        out["task3_small_kappa"] = task3_small_kappa(pool)

    # Task 4: bias ratio table (no pool, sequential since fast)
    out["task4_bias_table"] = task4_bias_ratio_table()

    out["wall_time"] = time.time() - t0
    print(f"\nTotal wall time: {out['wall_time']:.1f} s")

    out_path = here / "gap1_audit_results.json"
    with open(out_path, "w", encoding="utf-8") as fp:
        json.dump(out, fp, indent=2, default=str)
    print(f"Saved JSON to {out_path}")

    sys.stdout = sys.__stdout__
    log_f.close()


if __name__ == "__main__":
    main()
