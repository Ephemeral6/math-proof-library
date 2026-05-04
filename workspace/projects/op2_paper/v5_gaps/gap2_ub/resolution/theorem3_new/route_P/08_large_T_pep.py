"""Large-T PEP at critical β to distinguish:
   A) τ·T → finite C(β)  (i.e., O(1/T) for all β < 1, just bigger constant)
   B) τ·T → ∞ as T → ∞   (i.e., true sub-O(1/T) rate above some β*)

Strategy: at each β, find the optimal η near the predicted minimum from prior data,
then run T sweep up to T_max. Plot τ·T trajectory.
"""
from pathlib import Path
import sys, json, time
import numpy as np
sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
m = import_module("04_pep_sdp_fast")
primal_pep_shb_fast = m.primal_pep_shb_fast


def find_optimal_eta_at_T(L, beta, T, eta_grid):
    best = (np.inf, None)
    for eta in eta_grid:
        try:
            t0 = time.time()
            tau, _, _, _ = primal_pep_shb_fast(L, beta, eta, T, verbose=False)
            elapsed = time.time() - t0
            if tau is None or not np.isfinite(tau): continue
            if tau < best[0]:
                best = (float(tau), float(eta))
        except Exception:
            pass
    return best


def main():
    L = 1.0
    # At large β, η_opt is small. From prior LMI data:
    #  β=0.85: LMI η_opt=0.08, β=0.90: 0.08, β=0.95: 0.03
    # PEP η_opt may differ but is similar; we try 0.005..0.30
    eta_grid = [0.005, 0.01, 0.02, 0.03, 0.05, 0.08, 0.10, 0.15, 0.20, 0.30]

    betas = [0.93, 0.95, 0.97, 0.99]
    Ts = [10, 20, 30, 50, 80]

    print(f"η grid: {eta_grid}")
    print(f"β grid: {betas}")
    print(f"T grid: {Ts}")
    print()

    rows = []
    for beta in betas:
        print(f"\n=== β = {beta} ===")
        beta_data = {"beta": beta, "results": []}
        for T in Ts:
            t0 = time.time()
            tau, eta_star = find_optimal_eta_at_T(L, beta, T, eta_grid)
            elapsed = time.time() - t0
            tauT = tau * T
            print(f"  T={T:>3}  τ={tau:.4e}  η*={eta_star:.3f}  τ·T={tauT:.4f}  ({elapsed:.1f}s)")
            beta_data["results"].append({
                "T": T, "tau": float(tau), "tau_T": float(tauT),
                "eta_star": float(eta_star), "elapsed_s": float(elapsed)
            })
            # Save partial results after each T so we don't lose data on timeout
            rows_partial = rows + [beta_data]
            partial_out = Path(__file__).parent / "08_large_T_pep_partial.json"
            partial_out.write_text(json.dumps(rows_partial, indent=2))
        # log-log slope
        Ts_arr = np.array([r["T"] for r in beta_data["results"]])
        taus_arr = np.array([r["tau"] for r in beta_data["results"]])
        mask = np.isfinite(taus_arr) & (taus_arr > 0)
        if mask.sum() >= 3:
            slope, _ = np.polyfit(np.log(Ts_arr[mask]), np.log(taus_arr[mask]), 1)
            beta_data["slope"] = float(slope)
            print(f"  slope = {slope:.3f}  ({'O(1/T)' if slope < -0.85 else 'TRANSITION/SUB' if slope < -0.5 else 'NON-1/T'})")
        rows.append(beta_data)

    out = Path(__file__).parent / "08_large_T_pep_results.json"
    out.write_text(json.dumps(rows, indent=2))
    print(f"\nSaved: {out}")


if __name__ == "__main__":
    main()
