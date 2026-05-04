"""Faster β* localization using PEP. Smaller T grid (T ≤ 12) and smaller η grid.

Goal: identify β* between 0.5 and 0.9 where rate transitions from O(1/T) to O(T^{-1/3}).
"""
from pathlib import Path
import sys, json
import numpy as np
sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
m = import_module("04_pep_sdp_fast")
primal_pep_shb_fast = m.primal_pep_shb_fast


def find_optimal_eta(L, beta, T, eta_grid):
    best = (np.inf, None)
    for eta in eta_grid:
        try:
            tau, _, _, _ = primal_pep_shb_fast(L, beta, eta, T, verbose=False)
            if tau is None or not np.isfinite(tau): continue
            if tau < best[0]:
                best = (float(tau), float(eta))
        except Exception:
            pass
    return best


def main():
    L = 1.0
    # Small grids
    eta_grid = list(np.linspace(0.1, 0.9, 9)) + list(np.linspace(1.0, 1.8, 9))
    print(f"η grid: {len(eta_grid)} points")

    # T grid: small (PEP is O(T³) per SDP)
    Ts = [4, 6, 8, 10, 12]
    betas = [0.50, 0.55, 0.60, 0.65, 0.70, 0.75, 0.80, 0.85]
    print(f"β grid: {betas}")
    print(f"T grid: {Ts}")
    print()

    print(f"{'β':>5}", end="")
    for T in Ts: print(f"  τ·T(T={T:>2})", end="")
    print(f"  {'slope':>8}  {'τ·T^{1/3} mean':>18}  {'rate':>15}")
    print("-" * 110)

    results = []
    for beta in betas:
        taus = []
        etas = []
        for T in Ts:
            tau, eta_star = find_optimal_eta(L, beta, T, eta_grid)
            taus.append(tau)
            etas.append(eta_star)
        Ts_arr = np.array(Ts); taus_arr = np.array(taus)
        mask = np.isfinite(taus_arr) & (taus_arr > 0)
        if mask.sum() < 3:
            slope = float("nan"); intercept = float("nan")
        else:
            x = np.log(Ts_arr[mask]); y = np.log(taus_arr[mask])
            slope, intercept = np.polyfit(x, y, 1)
        const_O1T = taus_arr * Ts_arr
        const_T13 = taus_arr * (Ts_arr ** (1/3))
        rate_class = ("O(1/T)" if slope < -0.85 else
                      ("O(T^-1/3)" if slope > -0.5 else "TRANSITION"))

        print(f"{beta:>5.2f}", end="")
        for c in const_O1T:
            print(f"   {c:>9.4f}", end="")
        print(f"  {slope:>8.3f}  {np.nanmean(const_T13):>18.4f}  {rate_class:>15}")
        results.append({
            "beta": beta, "T_grid": Ts, "etas": etas,
            "taus": [float(t) for t in taus],
            "tau_T": [float(t * T) for t, T in zip(taus, Ts)],
            "slope": float(slope), "intercept": float(intercept),
            "const_T13_mean": float(np.nanmean(const_T13)),
            "rate_class": rate_class,
        })

    out = Path(__file__).parent / "07_beta_star_localization_fast_results.json"
    out.write_text(json.dumps(results, indent=2))
    print(f"\nSaved: {out}")

    # Identify β* transition
    print("\n" + "=" * 80)
    print("β* localization summary")
    print("=" * 80)
    for r in results:
        print(f"  β={r['beta']:.2f}  slope={r['slope']:.3f}  rate={r['rate_class']}  "
              f"τ·T(T_max)={r['tau_T'][-1]:.4f}")

    # Locate transition: smallest β where slope crosses -0.85 (i.e., no longer in O(1/T))
    transitions = [(r["beta"], r["slope"], r["rate_class"]) for r in results]
    print()
    last_clean_O1T = None
    first_transition = None
    for beta, slope, rc in transitions:
        if rc == "O(1/T)":
            last_clean_O1T = beta
        else:
            if first_transition is None:
                first_transition = beta
    print(f"Last β with rate = O(1/T): {last_clean_O1T}")
    print(f"First β with non-O(1/T) rate: {first_transition}")


if __name__ == "__main__":
    main()
