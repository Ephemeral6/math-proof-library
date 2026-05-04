"""
PEP for deterministic SHB on L-smooth convex (NOT strongly convex), zero-momentum init.

Algorithm:
    y_0 given, y_{-1} = y_0
    y_{t+1} = y_t - eta * grad f(y_t) + beta * (y_t - y_{t-1})

Initial condition: ||y_0 - x_*||^2 <= 1 (D^2 = 1 normalization)
Performance metric: f(y_T) - f_*
We sweep T = 2, 3, 4, 5, 7, 10 and check the scaling:
  - If τ(T) ≈ C/T → Theorem 3 (det) holds: O(LD^2/T) → adding noise gives O(σD/√T) UB.
  - If τ(T) ≈ C/T^α with α < 1 → tighter analysis required.

For each (β, T) we sweep eta to find the BEST eta (minimum τ).
"""
import numpy as np
from PEPit import PEP
from PEPit.functions import SmoothConvexFunction


def wc_shb(L, beta, eta, n, verbose=-1):
    problem = PEP()
    func = problem.declare_function(SmoothConvexFunction, L=L)
    xs = func.stationary_point()
    fs = func(xs)
    x0 = problem.set_initial_point()
    problem.set_initial_condition((x0 - xs) ** 2 <= 1)
    x_prev = x0
    x_curr = x0  # zero-momentum init: y_{-1} = y_0
    for _ in range(n):
        x_next = x_curr - eta * func.gradient(x_curr) + beta * (x_curr - x_prev)
        x_prev = x_curr
        x_curr = x_next
    problem.set_performance_metric(func(x_curr) - fs)
    try:
        return problem.solve(wrapper="cvxpy", verbose=verbose)
    except Exception as e:
        return None


def best_eta_sweep(L, beta, n, eta_grid=None, verbose=False):
    """Find the eta that minimizes the PEP worst-case for given beta, n."""
    if eta_grid is None:
        # Try eta proportional to 1/L, 1/(L*sqrt(T)), 1/(LT)
        eta_grid = sorted(set(
            [c / L for c in [0.1, 0.25, 0.5, 1.0, 1.5]]
            + [c / (L * np.sqrt(n)) for c in [0.5, 1.0, 1.5, 2.0]]
            + [c / (L * n) for c in [1.0, 2.0, 3.0]]
        ))
    best_tau = float("inf")
    best_eta = None
    for eta in eta_grid:
        if eta <= 0 or eta * L >= 2 * (1 + beta):  # SHB stability
            continue
        tau = wc_shb(L, beta, eta, n, verbose=-1)
        if tau is not None and tau < best_tau:
            best_tau = tau
            best_eta = eta
        if verbose:
            print(f"    eta={eta:.6f} -> tau={tau}")
    return best_tau, best_eta


def main():
    L = 1.0
    print(f"L = {L}")
    print(f"{'beta':>5} {'T':>4} {'best η':>10} {'PEP τ':>14} {'τ·T':>10} {'τ·sqrt(T)':>12}")
    rows = []
    for beta in [0.0, 0.5, 0.9]:
        for n in [2, 3, 5, 7, 10, 15]:
            tau, eta = best_eta_sweep(L, beta, n)
            ratio_T = tau * n if tau and np.isfinite(tau) else None
            ratio_sqrtT = tau * np.sqrt(n) if tau and np.isfinite(tau) else None
            print(f"{beta:>5.1f} {n:>4d} {eta if eta else 0:>10.5f} "
                  f"{tau if tau else 0:>14.6e} "
                  f"{ratio_T if ratio_T else 0:>10.4f} "
                  f"{ratio_sqrtT if ratio_sqrtT else 0:>12.4f}")
            rows.append({"beta": beta, "T": n, "eta": eta, "tau": tau,
                         "tau_T": ratio_T, "tau_sqrtT": ratio_sqrtT})

    # Log-log slope analysis per beta
    print("\n=== Log-log slope of best τ vs T ===")
    for beta in [0.0, 0.5, 0.9]:
        sub = [r for r in rows if r["beta"] == beta and r["tau"] is not None and r["tau"] > 0]
        Ts = np.array([r["T"] for r in sub])
        taus = np.array([r["tau"] for r in sub])
        if len(Ts) >= 3:
            slope, intercept = np.polyfit(np.log(Ts), np.log(taus), 1)
            print(f"  beta={beta:.1f}: τ ~ T^{slope:.3f} · exp({intercept:.3f}) "
                  f"({'O(1/T)' if abs(slope+1) < 0.1 else 'O(1/sqrt(T))' if abs(slope+0.5) < 0.1 else 'OTHER'})")

    import json
    # Make rows JSON-serializable (replace inf/nan)
    for r in rows:
        for k in ["tau", "tau_T", "tau_sqrtT", "eta"]:
            v = r.get(k)
            if v is None or (isinstance(v, float) and (np.isinf(v) or np.isnan(v))):
                r[k] = None
    with open("02_shb_deterministic_results.json", "w") as f:
        json.dump(rows, f, indent=2)


if __name__ == "__main__":
    main()
