"""Dense LMI sweep over β ∈ [0, 0.5] step 0.02 (26 points).

For each β, find the η minimizing C_Lya(β, η) and record all Lyapunov coefficients.
Then look for closed-form patterns in (W, a₀, a₁, a₂, c₀₁, c₀₂, c₁₂)(β).
"""
from pathlib import Path
import json
import sys
import numpy as np

sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
m = import_module("11_two_step_lmi_corrected")
build_lmi_corrected = m.build_lmi_corrected


def main():
    L = 1.0
    betas = np.round(np.arange(0.00, 0.51, 0.02), 4).tolist()
    eta_grid = [0.5, 0.7, 0.9, 1.0, 1.1, 1.2, 1.3, 1.5, 1.7, 1.9]

    print(f"β grid: {len(betas)} points")
    print(f"η grid: {eta_grid}")

    results = []
    header = (f"{'β':>5} {'η*':>5} {'W':>7} {'a0':>7} {'a1':>7} {'a2':>7} "
              f"{'c01':>7} {'c02':>7} {'c12':>7} {'S':>7} {'C':>7}")
    print(header); print("-" * len(header))

    for beta in betas:
        candidates = []
        for eta in eta_grid:
            try:
                r = build_lmi_corrected(L, beta, eta, fix_alpha=1.0, minimize="W")
            except Exception:
                continue
            if r["status"] not in ("optimal", "optimal_inaccurate"):
                continue
            if r["W"] is None or r["a0"] is None:
                continue
            S = r["a0"] + r["a1"] + r["a2"] + r["c01"] + r["c02"] + r["c12"]
            C = (r["W"] - 1.0) * (L / 2) + S
            candidates.append((C, S, eta, r))
        candidates.sort()
        if not candidates:
            print(f"{beta:>5.2f}: no feasible LMI")
            continue
        C_best, S_best, eta_best, r_best = candidates[0]
        print(f"{beta:>5.2f} {eta_best:>5.2f} {r_best['W']:>7.4f} "
              f"{r_best['a0']:>7.3f} {r_best['a1']:>7.3f} {r_best['a2']:>7.3f} "
              f"{r_best['c01']:>7.3f} {r_best['c02']:>7.3f} {r_best['c12']:>7.3f} "
              f"{S_best:>7.4f} {C_best:>7.4f}")
        results.append({
            "beta": float(beta), "eta_opt": float(eta_best),
            "W": float(r_best["W"]),
            "a0": float(r_best["a0"]), "a1": float(r_best["a1"]), "a2": float(r_best["a2"]),
            "c01": float(r_best["c01"]), "c02": float(r_best["c02"]), "c12": float(r_best["c12"]),
            "S": float(S_best), "C_Lya": float(C_best),
        })

    out = Path(__file__).parent / "13_dense_lmi_sweep_results.json"
    out.write_text(json.dumps(results, indent=2))
    print(f"\nWritten: {out}")


if __name__ == "__main__":
    main()
