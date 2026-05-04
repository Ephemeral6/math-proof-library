"""Route P, step #3: scan duals across T = 3, 4, 5, 6, 7 at beta in {0.0, 0.3, 0.5},
extended eta grid, look for closed-form pattern.

Outputs a structured table of duals organized as:
  - chain duals lambda(x_{t-1}, x_t)
  - reverse duals lambda(x_t, x_{t-1})
  - star-out duals lambda(*, x_t)
  - star-in duals lambda(x_t, *)
  - "long-range" duals lambda(x_i, x_j), |i-j| >= 2

For closed-form extraction: report whether the dual pattern is "clean" (chain-only)
or "thick" (skip-pairs significant).

Saves all duals to JSON for later closed-form fitting.
"""
from pathlib import Path
import json
import numpy as np
import cvxpy as cp
import sys

sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
m = import_module("02_manual_pep_sdp")  # reuse primal_pep_shb

primal_pep_shb = m.primal_pep_shb


def find_optimal_eta(L, beta, T, eta_grid):
    best = (np.inf, None)
    for eta in eta_grid:
        tau, _, _, _, _ = primal_pep_shb(L, beta, eta, T, verbose=False)
        if tau < best[0]:
            best = (tau, eta)
    return best


def label(idx, T):
    return "*" if idx == T + 1 else f"x{idx}"


def main():
    L = 1.0
    eta_grid = np.concatenate([
        np.array([0.4, 0.6, 0.8, 1.0]),
        np.linspace(1.1, 2.0, 10),
        np.linspace(2.2, 3.5, 7),
    ])
    print(f"eta grid size: {len(eta_grid)}")

    all_results = {}
    for beta in [0.0, 0.1, 0.3, 0.5]:
        for T in [3, 4, 5, 6, 7]:
            print(f"\n=== beta={beta}, T={T} ===")
            tau_best, eta_star = find_optimal_eta(L, beta, T, eta_grid)
            print(f"   tau* = {tau_best:.5e}, tau*T = {tau_best * T:.4f}, eta* = {eta_star:.3f}")
            tau_check, duals, G_val, F_val, c_mat = primal_pep_shb(L, beta, eta_star, T, verbose=False)

            # Organize duals
            chain_fwd = []   # (t, lambda(x_{t-1}, x_t))
            chain_bwd = []   # (t, lambda(x_t, x_{t-1}))
            star_out = []    # (t, lambda(*, x_t))
            star_in  = []    # (t, lambda(x_t, *))
            long_range = []  # (i, j, lambda(x_i, x_j))

            star_idx = T + 1
            duals_dict = {(i, j): dv for (i, j, dv) in duals}
            for t in range(1, T + 1):
                v = duals_dict.get((t - 1, t), 0.0)
                chain_fwd.append((t, v))
                v = duals_dict.get((t, t - 1), 0.0)
                chain_bwd.append((t, v))
            for t in range(0, T + 1):
                v = duals_dict.get((star_idx, t), 0.0)
                star_out.append((t, v))
                v = duals_dict.get((t, star_idx), 0.0)
                star_in.append((t, v))
            for (i, j), v in duals_dict.items():
                if i == star_idx or j == star_idx: continue
                if abs(i - j) >= 2:
                    long_range.append((i, j, v))

            print(f"   Chain fwd lambda(x_{{t-1}}, x_t): {[(t, round(v, 4)) for t, v in chain_fwd]}")
            print(f"   Chain bwd lambda(x_t, x_{{t-1}}): {[(t, round(v, 4)) for t, v in chain_bwd]}")
            print(f"   Star out lambda(*, x_t):         {[(t, round(v, 4)) for t, v in star_out]}")
            print(f"   Star in  lambda(x_t, *):         {[(t, round(v, 4)) for t, v in star_in]}")
            long_range.sort(key=lambda kv: -abs(kv[2]))
            print(f"   Top long-range pairs (|i-j|>=2): {len(long_range)} non-zero, top 5:")
            for i, j, v in long_range[:5]:
                print(f"     lambda(x_{i}, x_{j}) = {v:.4f}")

            all_results[f"beta={beta}_T={T}"] = {
                "beta": beta, "T": T,
                "eta_star": float(eta_star),
                "tau": float(tau_check),
                "tau_T": float(tau_check * T),
                "chain_fwd": [{"t": t, "dual": float(v)} for t, v in chain_fwd],
                "chain_bwd": [{"t": t, "dual": float(v)} for t, v in chain_bwd],
                "star_out": [{"t": t, "dual": float(v)} for t, v in star_out],
                "star_in":  [{"t": t, "dual": float(v)} for t, v in star_in],
                "long_range": [
                    {"i": int(i), "j": int(j), "dual": float(v)}
                    for i, j, v in sorted(long_range, key=lambda kv: -abs(kv[2]))
                ],
            }

    out = Path(__file__).parent / "03_dual_pattern_scan_results.json"
    out.write_text(json.dumps(all_results, indent=2))
    print(f"\nWritten: {out}")


if __name__ == "__main__":
    main()
