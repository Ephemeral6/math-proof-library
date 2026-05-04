"""Quick PEP at the LMI infeasibility frontier (β=0.957, 0.96, 0.97) to check
whether PEP gives a different answer than LMI.

If LMI says β=0.96 is infeasible but PEP gives finite τ·T at all T, then the
LMI's failure is structural — the rate is still O(1/T).

Use small T (≤ 12) for speed.
"""
from pathlib import Path
import sys, json
import numpy as np
sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
m = import_module("04_pep_sdp_fast")
primal_pep_shb_fast = m.primal_pep_shb_fast


def main():
    L = 1.0
    eta_grid = [0.001, 0.003, 0.005, 0.008, 0.01, 0.02, 0.03, 0.05, 0.08, 0.10]
    Ts = [5, 8, 12]
    betas = [0.957, 0.960, 0.970, 0.985, 0.995]

    print(f"{'β':>6}", end="")
    for T in Ts: print(f"  τ·T(T={T:>2})", end="")
    print(f"  {'slope':>8}")
    print("-" * 60)
    rows = []
    for beta in betas:
        taus = []
        for T in Ts:
            best = (np.inf, None)
            for eta in eta_grid:
                try:
                    tau, _, _, _ = primal_pep_shb_fast(L, beta, eta, T, verbose=False)
                    if tau is None or not np.isfinite(tau): continue
                    if tau < best[0]:
                        best = (float(tau), float(eta))
                except Exception:
                    pass
            taus.append(best[0])
        Ts_arr = np.array(Ts); taus_arr = np.array(taus)
        mask = np.isfinite(taus_arr) & (taus_arr > 0)
        slope = np.polyfit(np.log(Ts_arr[mask]), np.log(taus_arr[mask]), 1)[0] if mask.sum() >= 2 else float("nan")
        print(f"{beta:>6.3f}", end="")
        for tau, T in zip(taus, Ts):
            tt = tau * T if np.isfinite(tau) else float("nan")
            print(f"  {tt:>9.4f}", end="")
        print(f"  {slope:>8.3f}")
        rows.append({"beta": beta, "Ts": Ts, "taus": [float(t) for t in taus],
                     "slope": float(slope) if np.isfinite(slope) else None})
    out = Path(__file__).parent / "09_pep_high_beta_quick_results.json"
    out.write_text(json.dumps(rows, indent=2))
    print(f"\nSaved: {out}")


if __name__ == "__main__":
    main()
