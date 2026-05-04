"""Final decisive test: PEP at β > β*_LMI = 0.957 with T up to 30.

If τ·T stays bounded at T=30 for β = 0.97 (well past LMI infeasibility),
that's strong evidence for option (A): rate is O(1/T) for all β < 1.
"""
from pathlib import Path
import sys, json, time
import numpy as np
sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
m = import_module("04_pep_sdp_fast")
primal_pep_shb_fast = m.primal_pep_shb_fast


def main():
    L = 1.0
    eta_grid = [0.001, 0.003, 0.005, 0.008, 0.01, 0.02, 0.03, 0.05]
    Ts = [10, 15, 20, 25, 30]
    betas = [0.97, 0.99]

    print(f"η grid: {eta_grid}")
    print(f"β grid: {betas}")
    print(f"T grid: {Ts}")
    print()
    print(f"{'β':>5} {'T':>4} {'τ':>10} {'η_opt':>7} {'τ·T':>8} {'time':>6}")
    print("-" * 50)
    rows = []
    for beta in betas:
        beta_data = {"beta": beta, "results": []}
        for T in Ts:
            t0 = time.time()
            best = (np.inf, None)
            for eta in eta_grid:
                try:
                    tau, _, _, _ = primal_pep_shb_fast(L, beta, eta, T, verbose=False)
                    if tau is None or not np.isfinite(tau): continue
                    if tau < best[0]:
                        best = (float(tau), float(eta))
                except Exception:
                    pass
            tau, eta_star = best
            elapsed = time.time() - t0
            print(f"{beta:>5.2f} {T:>4} {tau:>10.4e} {eta_star:>7.3f} {tau*T:>8.4f} {elapsed:>5.1f}s")
            beta_data["results"].append({"T": T, "tau": tau, "eta_star": eta_star,
                                          "tau_T": tau*T, "elapsed_s": elapsed})
        # slope
        Ts_arr = np.array([r["T"] for r in beta_data["results"]])
        taus = np.array([r["tau"] for r in beta_data["results"]])
        mask = np.isfinite(taus) & (taus > 0)
        if mask.sum() >= 3:
            slope = np.polyfit(np.log(Ts_arr[mask]), np.log(taus[mask]), 1)[0]
            beta_data["slope"] = float(slope)
            rate_class = ("O(1/T)" if slope < -0.85 else
                          ("O(T^-1/3)" if slope > -0.5 else "TRANSITION"))
            print(f"  → β={beta}: slope = {slope:.3f}, rate ≈ {rate_class}")
            print()
        rows.append(beta_data)

    out = Path(__file__).parent / "10_pep_high_beta_T30_results.json"
    out.write_text(json.dumps(rows, indent=2))
    print(f"Saved: {out}")


if __name__ == "__main__":
    main()
