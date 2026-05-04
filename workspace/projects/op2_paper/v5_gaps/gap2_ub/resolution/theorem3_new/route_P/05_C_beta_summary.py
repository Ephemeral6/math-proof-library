"""Compile the refined C_beta table from 04_pep_sdp_fast_results.json."""
from pathlib import Path
import json
import numpy as np


def main():
    data = json.loads(
        Path(__file__).with_name("04_pep_sdp_fast_results.json").read_text()
    )

    rows_by_beta = {}
    for key, rec in data.items():
        beta = rec["beta"]; T = rec["T"]
        rows_by_beta.setdefault(beta, []).append((T, rec["tau"], rec["tau_T"], rec["eta_star"]))

    print("=" * 60)
    print("C_β  table (tau · T  for each (β, T) at the PEP-optimal η)")
    print("=" * 60)
    print(f"{'β':>5}  " + "  ".join(f"T={T}" for T in [3, 4, 5, 6, 7]))
    for beta in sorted(rows_by_beta):
        rows_by_beta[beta].sort()
        cells = {T: tT for T, _, tT, _ in rows_by_beta[beta]}
        print(f"{beta:>5.2f}  " + "  ".join(f"{cells.get(T, np.nan):.4f}" for T in [3, 4, 5, 6, 7]))

    print("\n\nOptimal η_β (per β, averaged across T):")
    for beta in sorted(rows_by_beta):
        etas = [eta for _, _, _, eta in rows_by_beta[beta]]
        print(f"  β = {beta:.2f}:  η ∈ {min(etas):.2f}–{max(etas):.2f}  (mean {np.mean(etas):.3f})")

    # Compute the global C_β bound for β ≤ 1/2.
    relevant = []
    for beta, recs in rows_by_beta.items():
        if beta > 0.5: continue
        for T, tau, tT, eta in recs:
            relevant.append(tT)
    print(f"\n--- For β ∈ [0, 1/2] across T ∈ {{3,4,5,6,7}} ---")
    print(f"  Min  tau·T = {min(relevant):.4f}")
    print(f"  Max  tau·T = {max(relevant):.4f}    ← C_β upper bound")
    print(f"  Mean tau·T = {np.mean(relevant):.4f}")

    # Bias-variance composition with NEW C_β:
    C_beta = max(relevant)
    print(f"\nBias-variance composition with C_β = {C_beta:.4f}:")
    print(f"  Stochastic UB: E[f(y_T) - f*] ≤ 2 D σ √(C_β L / ((1-β) T))")
    print(f"               = {2*np.sqrt(C_beta):.4f} · D σ √(L / ((1-β) T))")
    print(f"  At β = 1/2:  constant = {2*np.sqrt(C_beta) / np.sqrt(0.5):.4f}")
    print(f"  At β = 0:    constant = {2*np.sqrt(C_beta):.4f}")


if __name__ == "__main__":
    main()
