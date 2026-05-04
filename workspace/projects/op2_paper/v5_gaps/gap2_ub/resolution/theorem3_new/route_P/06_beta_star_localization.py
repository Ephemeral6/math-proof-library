"""Localize β* using PEP. Sweep β ∈ {0.50, 0.55, ..., 0.90}, fine T grid, log-log slope.

For each β, compute optimal η at each T, record τ(β, T). Then fit log-log slope of τ vs T:
  slope ≈ -1   →  O(1/T)   (β below transition)
  slope ≈ -1/3 →  O(T^{-1/3})  (β above transition)

The transition β* should appear as the β where the slope crosses (say) -2/3.
"""
from pathlib import Path
import json
import sys
import numpy as np
import cvxpy as cp

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


def loglog_slope(Ts, taus):
    Ts = np.array(Ts); taus = np.array(taus)
    mask = (Ts > 0) & (taus > 0) & np.isfinite(taus)
    if mask.sum() < 3:
        return float("nan"), float("nan")
    x = np.log(Ts[mask]); y = np.log(taus[mask])
    s, b = np.polyfit(x, y, 1)
    return float(s), float(b)


def main():
    L = 1.0
    eta_grid = np.concatenate([
        np.linspace(0.1, 1.0, 10),
        np.linspace(1.05, 2.0, 10),
    ])
    print(f"η grid: {len(eta_grid)} points in [{eta_grid.min():.2f}, {eta_grid.max():.2f}]/L")

    betas = [0.50, 0.55, 0.60, 0.65, 0.70, 0.75, 0.80, 0.85, 0.90]
    Ts = [5, 7, 10, 15, 20, 30]
    print(f"β grid: {betas}")
    print(f"T grid: {Ts}")

    results = []
    print(f"\n{'β':>5}", end="")
    for T in Ts: print(f"  τ·T(T={T:>2})", end="")
    print(f"  {'slope':>8}  {'τ·T^(1/3) const':>16}  {'rate':>15}")
    print("-" * 110)

    for beta in betas:
        row = {"beta": beta, "data": []}
        taus = []
        for T in Ts:
            tau, eta_star = find_optimal_eta(L, beta, T, eta_grid)
            row["data"].append({"T": T, "tau": tau, "eta_star": eta_star, "tau_T": tau * T})
            taus.append(tau)
        slope, b = loglog_slope(Ts, taus)
        # τ ~ T^slope. If slope = -1: τ·T = const. If slope = -1/3: τ·T^(1/3) = const.
        const_O1T = np.array([t * T for t, T in zip(taus, Ts)])
        const_T13 = np.array([t * (T ** (1/3)) for t, T in zip(taus, Ts)])
        rate_class = "O(1/T)" if slope < -0.85 else ("O(T^-1/3)" if slope > -0.5 else "transition")

        print(f"{beta:>5.2f}", end="")
        for c in const_O1T: print(f"   {c:>9.4f}", end="")
        print(f"  {slope:>8.3f}  {np.mean(const_T13):>16.4f}  {rate_class:>15}")

        row["taus"] = [float(t) for t in taus]
        row["slope"] = slope
        row["intercept"] = b
        row["const_T13_mean"] = float(np.mean(const_T13))
        row["const_T13_std"] = float(np.std(const_T13))
        row["const_O1T_max"] = float(np.max(const_O1T))
        row["rate_class"] = rate_class
        results.append(row)

    # Save
    out = Path(__file__).parent / "06_beta_star_localization_results.json"
    out.write_text(json.dumps(results, indent=2))
    print(f"\nResults: {out}")

    # Try to identify β* from the slope
    print("\n" + "=" * 80)
    print("β* localization summary")
    print("=" * 80)
    transitions = []
    for r in results:
        beta = r["beta"]; slope = r["slope"]
        transitions.append((beta, slope))
    print(f"{'β':>5}  {'slope':>8}  {'rate':>15}")
    for beta, slope in transitions:
        rate_class = "O(1/T)" if slope < -0.85 else ("O(T^-1/3)" if slope > -0.5 else "TRANSITION")
        print(f"{beta:>5.2f}  {slope:>8.3f}  {rate_class:>15}")

    # Specific candidates for β*
    candidates = {
        "1/2": 0.5,
        "(√5-1)/2 ≈ 0.618": (np.sqrt(5) - 1) / 2,
        "2/3": 2/3,
        "1/√2 ≈ 0.707": 1/np.sqrt(2),
        "3/4": 0.75,
        "√(1/2) (=0.707)": np.sqrt(0.5),
    }
    print(f"\nClean-number candidates for β*:")
    for name, val in candidates.items():
        print(f"  {name} = {val:.4f}")


if __name__ == "__main__":
    main()
