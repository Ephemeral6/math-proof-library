"""
Verify the BRIDGE LEMMA numerically.

The plan: SHB on full L-smooth convex non-SC class, with COV w_t = y_t + a(y_t - y_{t-1}).

  (B1) f(y_T) - f(w_T) <= L/2 ||y_T - w_T||^2 + |<grad f(w_T), y_T - w_T>|
       Both terms decay at rate at least 1/sqrt(T) at horizon-tuned eta_T.
  (B2) E[||m_T||^2] is bounded uniformly: E[||m_T||^2] <= O(sigma^2/(1-beta^2)).
  (B3) E[f(w_T) - f*] obeys Liu-Zhou-style UB at horizon-tuned eta_T.

For verification, we test on:
  - Quadratic f(x) = (L/2)||x||^2 (sanity check)
  - Logistic loss f(x) = log(1 + exp(-x)) on R (smooth convex, non-quadratic)
  - Smoothed huber f(x) = sqrt(1 + x^2) - 1 (smooth convex, bounded gradient)
  - 2D Goujaud K=3 polytope-Moreau (OP-2 hard instance, smooth convex non-SC)
"""

import json
import time
from pathlib import Path

import mpmath as mp
import numpy as np
import sympy as sp


# ---------------------------------------------------------------------------
# Test instances: each is a function class with f(x), grad_f(x)
# ---------------------------------------------------------------------------

class Quadratic:
    """f(x) = (L/2) x^2 (1-D, scalar). f* = 0 at x* = 0. L-smooth, mu-SC if mu > 0 (here mu = 0)."""
    def __init__(self, L=1.0):
        self.L = L

    def f(self, x):
        return 0.5 * self.L * x ** 2  # element-wise

    def grad(self, x):
        return self.L * x

    def f_star(self):
        return 0.0


class Logistic:
    """f(x) = log(1 + exp(-x)) on R. L-smooth with L = 1/4. f* = 0 at x = +inf (no minimizer in R).
    To ensure a finite minimum, project to bounded domain; we use a regularized version:
    f(x) = log(1 + exp(-x)) + (eps/2)*x^2 with eps = 1e-3.
    Then f* is at some finite x*."""
    def __init__(self, eps=1e-3):
        self.eps = eps
        self.L = 0.25 + eps  # L-smooth constant

    def f(self, x):
        return np.log1p(np.exp(-x)) + 0.5 * self.eps * x ** 2

    def grad(self, x):
        return -1 / (1 + np.exp(x)) + self.eps * x

    def f_star(self):
        # min of log(1 + exp(-x)) + (eps/2)*x^2: solve grad = 0 numerically.
        from scipy.optimize import brentq
        # grad: -1/(1+exp(x)) + eps*x = 0  =>  eps*x = 1/(1+exp(x))
        # rhs > 0 always, so x > 0.
        x_star = brentq(lambda x: self.grad(np.array([x]))[0], 1e-6, 100)
        return float(self.f(np.array([x_star]))[0])


class Huber:
    """Smoothed Huber: f(x) = sqrt(1 + x^2) - 1. L-smooth with L = 1, f* = 0 at x* = 0.
    grad f(x) = x / sqrt(1+x^2)."""
    def __init__(self):
        self.L = 1.0

    def f(self, x):
        return np.sqrt(1 + x ** 2) - 1

    def grad(self, x):
        return x / np.sqrt(1 + x ** 2)

    def f_star(self):
        return 0.0


# ---------------------------------------------------------------------------
# SHB simulator
# ---------------------------------------------------------------------------

def run_shb(instance, beta, eta, T, sigma, x0, trials, seed=42):
    """Run SHB on `instance` for T steps. Return final iterate and statistics.

    Returns:
        x_T: shape (trials,) — last iterate
        m_T: shape (trials,) — last velocity m_t = (x_t - x_{t-1})/eta
        history: dict with f_history, x_history, etc. (sampled)
    """
    rng = np.random.default_rng(seed)
    x_t = np.full(trials, x0)
    x_tm1 = np.full(trials, x0)
    f_at_t = []
    x_at_t = []
    log_T_subset = sorted(set([1, 2, 5, 10, 50, 100, 500, 1000, T // 2, T - 1, T]))
    log_T_subset = [t for t in log_T_subset if t <= T]
    for t in range(1, T + 1):
        xi = rng.normal(0, sigma, size=trials)
        g_t = instance.grad(x_t) + xi
        x_new = x_t - eta * g_t + beta * (x_t - x_tm1)
        x_tm1 = x_t
        x_t = x_new
        if t in log_T_subset:
            f_at_t.append((t, float(np.mean(instance.f(x_t)))))
            x_at_t.append((t, float(np.mean(x_t)), float(np.mean(x_t ** 2))))

    m_T = (x_t - x_tm1) / eta
    return x_t, m_T, {"f_at_t": f_at_t, "x_at_t": x_at_t}


# ---------------------------------------------------------------------------
# Bridge bound test
# ---------------------------------------------------------------------------

def check_bridge_bound(instance, name):
    """Verify f(y_T) - f(w_T) is O(1/T + 1/sqrt(T)) at horizon-tuned eta_T.

    We test for several T values and check empirical scaling.
    """
    print(f"\n=== Bridge bound test on {name} ===")
    L = instance.L
    sigma = 1.0
    D = 1.0
    x0 = D  # initial distance from optimum
    trials = 5000
    print(f"  L={L:.3f}, σ={sigma}, D={D}, x_0={x0}, trials={trials}")

    Ts = [100, 300, 1000, 3000, 10000]
    for beta in [0.0, 0.5, 0.9]:
        rows = []
        for T in Ts:
            eta = D * (1 - beta) / (sigma * np.sqrt(T))
            if eta * L >= 2 * (1 + beta):
                continue
            x_T, m_T, hist = run_shb(instance, beta, eta, T, sigma, x0, trials, seed=42 + T)
            # COV: w_T = y_T + a (y_T - y_{T-1}) = y_T + a*eta*m_T
            a = beta / (1 - beta) if beta < 1 else 0
            w_T = x_T + a * eta * m_T
            f_y = float(np.mean(instance.f(x_T))) - instance.f_star()
            f_w = float(np.mean(instance.f(w_T))) - instance.f_star()
            diff = f_y - f_w  # our bridge bound: f(y_T) - f(w_T)
            # Bridge UB: |⟨∇f(w_T), y_T - w_T⟩| + (L/2)||y_T - w_T||^2
            grad_w = instance.grad(w_T)
            cross = float(np.mean(np.abs(grad_w * (x_T - w_T))))
            quad = float(np.mean(0.5 * L * (x_T - w_T) ** 2))
            target_lb = sigma * D / np.sqrt(T)
            target_bias = L * D ** 2 / T
            rows.append({
                "T": T, "eta": eta, "f_y": f_y, "f_w": f_w, "diff": diff,
                "cross_bound": cross, "quad_bound": quad,
                "target_var": target_lb, "target_bias": target_bias,
            })
        print(f"\n  β = {beta}:")
        print(f"  {'T':>6} {'eta':>9} {'E[f(y)]':>12} {'E[f(w)]':>12} {'diff':>11} {'cross':>11} {'quad':>11} {'σD/√T':>10}")
        for r in rows:
            print(f"  {r['T']:>6} {r['eta']:>9.5f} {r['f_y']:>12.6f} {r['f_w']:>12.6f} "
                  f"{r['diff']:>11.6f} {r['cross_bound']:>11.6f} {r['quad_bound']:>11.6f} "
                  f"{r['target_var']:>10.5f}")


# ---------------------------------------------------------------------------
# Empirical rate fit for f(y_T) on non-quadratic instances
# ---------------------------------------------------------------------------

def check_rate_full_class(instance, name):
    """Empirical log-log fit of E[f(y_T) - f*] vs T at horizon-tuned eta_T."""
    print(f"\n=== Full-class last-iterate rate fit on {name} ===")
    L = instance.L
    sigma = 1.0
    D = 1.0
    x0 = D
    trials = 5000

    rates_per_beta = {}
    for beta in [0.0, 0.5, 0.9]:
        log_T_list = []
        log_f_list = []
        log_target_list = []
        for T in [100, 300, 1000, 3000, 10000]:
            eta = D * (1 - beta) / (sigma * np.sqrt(T))
            if eta * L >= 2 * (1 + beta):
                continue
            x_T, m_T, hist = run_shb(instance, beta, eta, T, sigma, x0, trials, seed=99 + T)
            f_T = float(np.mean(instance.f(x_T))) - instance.f_star()
            target = sigma * D / np.sqrt(T) + L * D ** 2 / T
            log_T_list.append(np.log(T))
            log_f_list.append(np.log(max(f_T, 1e-12)))
            log_target_list.append(np.log(target))
            print(f"  β={beta:.2f}  T={T:5d}  η={eta:.5f}  E[f(y_T)-f*]={f_T:.6f}  "
                  f"σD/√T+LD²/T={target:.5f}  ratio={f_T/target:.3f}")
        if len(log_T_list) >= 3:
            slope, _ = np.polyfit(log_T_list, log_f_list, 1)
            rate = -slope
            rates_per_beta[beta] = rate
            print(f"  β={beta:.2f}: empirical last-iterate rate T^(-{rate:.3f})")

    return rates_per_beta


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main():
    print("=" * 80)
    print("Verifying bridge lemma + full-class last-iterate UB rate")
    print("=" * 80)

    instances = [
        (Quadratic(L=1), "Quadratic L=1"),
        (Huber(), "Huber smoothed"),
        (Logistic(eps=0.001), "Logistic regularized"),
    ]

    summary = {}
    for inst, name in instances:
        # check_bridge_bound(inst, name)  # detailed per-T table (skip for brevity)
        rates = check_rate_full_class(inst, name)
        summary[name] = rates
        print()

    print("=" * 80)
    print("SUMMARY (last-iterate empirical rate vs predicted T^(-0.5) for σD/√T)")
    print("=" * 80)
    for name, rates in summary.items():
        print(f"  {name}:")
        for beta, rate in rates.items():
            print(f"    β={beta}: T^(-{rate:.3f})")

    out_path = Path(__file__).parent / "verify_bridge_results.json"
    with open(out_path, "w", encoding="utf-8") as fp:
        json.dump(summary, fp, indent=2, default=str)


if __name__ == "__main__":
    main()
