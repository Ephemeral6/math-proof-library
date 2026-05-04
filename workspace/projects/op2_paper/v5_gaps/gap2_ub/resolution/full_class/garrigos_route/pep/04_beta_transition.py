"""
Comprehensive beta sweep for deterministic SHB on L-smooth convex.

For each beta in {0, 0.1, 0.3, 0.5, 0.7, 0.9}, find the best worst-case rate
exponent: slope of log(τ) vs log(T), where τ is the PEP optimum at the best eta.

Hypothesis: there is a critical beta* below which the rate is O(1/T) and above
which the rate degrades. This would explain:
1. Why elementary Lyapunov-based routes fail for β close to 1
2. The Hudiani 2025 T^{-1/3} rate for general β
"""
import numpy as np
from PEPit import PEP
from PEPit.functions import SmoothConvexFunction
import json
import warnings
warnings.filterwarnings("ignore")


def wc_shb(L, beta, eta, n, verbose=-1):
    problem = PEP()
    func = problem.declare_function(SmoothConvexFunction, L=L)
    xs = func.stationary_point()
    fs = func(xs)
    x0 = problem.set_initial_point()
    problem.set_initial_condition((x0 - xs) ** 2 <= 1)
    x_prev = x0
    x_curr = x0
    for _ in range(n):
        x_next = x_curr - eta * func.gradient(x_curr) + beta * (x_curr - x_prev)
        x_prev = x_curr
        x_curr = x_next
    problem.set_performance_metric(func(x_curr) - fs)
    try:
        return problem.solve(wrapper="cvxpy", verbose=verbose)
    except Exception:
        return None


def best_tau(L, beta, n):
    """Fine eta grid: include 1/L, (1-beta)/L, c/T, c/sqrt(T)."""
    etas = []
    etas += [c / L for c in [0.05, 0.1, 0.2, 0.3, 0.5, 0.7, 1.0, 1.3, 1.5]]
    etas += [c * (1 - beta) / L for c in [0.5, 1.0, 1.5]]
    etas += [c / (L * n) for c in [0.5, 1.0, 2.0]]
    etas += [c / (L * np.sqrt(n)) for c in [0.5, 1.0, 1.5]]
    etas = sorted(set([e for e in etas if 0 < e < 2 * (1 + beta) / L]))
    best, best_e = float("inf"), None
    for eta in etas:
        tau = wc_shb(L, beta, eta, n, verbose=-1)
        if tau is not None and tau < best:
            best, best_e = tau, eta
    return best, best_e


def main():
    L = 1.0
    Ts = [3, 5, 7, 10, 15]
    betas = [0.0, 0.1, 0.3, 0.5, 0.7, 0.8, 0.9]
    table = {}
    for beta in betas:
        print(f"\n[beta = {beta}]")
        rows = []
        for n in Ts:
            tau, eta = best_tau(L, beta, n)
            print(f"  T={n:3d}  best η={eta:.5f}  τ={tau:.6e}  τ·T={tau*n:.4f}  τ·√T={tau*np.sqrt(n):.4f}")
            rows.append({"T": n, "eta": eta, "tau": tau})
        table[beta] = rows

    print(f"\n{'='*60}")
    print(f"{'β':>6}  {'slope (log τ vs log T)':>22}  {'rate':>15}")
    print(f"{'='*60}")
    summary = []
    for beta in betas:
        rows = table[beta]
        Ts_arr = np.array([r["T"] for r in rows])
        taus_arr = np.array([r["tau"] for r in rows])
        slope, intercept = np.polyfit(np.log(Ts_arr), np.log(taus_arr), 1)
        rate = "O(1/T)" if slope < -0.9 else ("O(T^-2/3)" if -0.85 < slope < -0.55 else
                ("O(T^-1/2)" if -0.55 <= slope < -0.4 else
                ("O(T^-1/3)" if -0.4 <= slope < -0.2 else "no decay")))
        print(f"{beta:>6.1f}  {slope:>22.4f}  {rate:>15}")
        summary.append({"beta": beta, "slope": slope, "intercept": intercept, "rate_class": rate})

    with open("04_beta_transition_results.json", "w") as f:
        json.dump({"table": {str(k): v for k, v in table.items()},
                   "summary": summary}, f, indent=2)

if __name__ == "__main__":
    main()
