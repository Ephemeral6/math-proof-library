"""
Finer eta sweep for high beta (0.9), to confirm the O(1/T) rate holds.

We try a wider range of eta, including very small eta = c/(LT) and intermediate values.
"""
import numpy as np
from PEPit import PEP
from PEPit.functions import SmoothConvexFunction
import json


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


def fine_sweep(L, beta, n):
    # Wider eta range, focused on small eta for high beta
    etas = []
    # 1) eta proportional to 1/L (constant scaling)
    etas += [c / L for c in [0.01, 0.03, 0.05, 0.1, 0.15, 0.2, 0.3, 0.5, 0.7, 1.0, 1.5]]
    # 2) eta proportional to (1-beta)/L (heavy-ball-stable-region)
    etas += [c * (1 - beta) / L for c in [0.5, 1.0, 1.5, 2.0]]
    # 3) eta proportional to 1/(L*T)
    etas += [c / (L * n) for c in [0.5, 1.0, 2.0, 5.0]]
    # 4) eta proportional to 1/(L*sqrt(T))
    etas += [c / (L * np.sqrt(n)) for c in [0.5, 1.0, 1.5, 2.0]]
    etas = sorted(set([e for e in etas if 0 < e < 2 * (1 + beta) / L]))

    results = []
    for eta in etas:
        tau = wc_shb(L, beta, eta, n, verbose=-1)
        if tau is not None:
            results.append({"eta": eta, "tau": tau})
    return results


def main():
    L = 1.0
    rows = []
    for beta in [0.9]:
        print(f"\n=== beta = {beta} ===")
        for n in [3, 5, 10, 20, 30]:
            results = fine_sweep(L, beta, n)
            best = min(results, key=lambda r: r["tau"])
            print(f"\nT = {n}:")
            for r in sorted(results, key=lambda r: r["tau"])[:6]:
                marker = " <-- best" if r is best else ""
                print(f"  eta={r['eta']:.6f}  tau={r['tau']:.6e}  tau*T={r['tau']*n:.4f}  tau*sqrt(T)={r['tau']*np.sqrt(n):.4f}{marker}")
            rows.append({"beta": beta, "T": n, "best_eta": best["eta"], "best_tau": best["tau"]})

    print("\n=== Slope analysis (best τ over wide grid) ===")
    Ts = np.array([r["T"] for r in rows])
    taus = np.array([r["best_tau"] for r in rows])
    slope, intercept = np.polyfit(np.log(Ts), np.log(taus), 1)
    print(f"  beta=0.9: τ ~ T^{slope:.3f} · exp({intercept:.3f})")

    with open("03_shb_high_beta_results.json", "w") as f:
        json.dump(rows, f, indent=2)


if __name__ == "__main__":
    main()
