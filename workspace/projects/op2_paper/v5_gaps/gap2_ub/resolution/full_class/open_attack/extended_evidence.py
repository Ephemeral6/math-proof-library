"""
Extended empirical evidence for Theorem 3 conjecture.

Test the rate at much larger T (up to 10^5) and on multiple non-quadratic instances
to see if the T^{-1/2} rate is robust.

If the rate breaks at some T, that's evidence that the conjecture is FALSE.
If it holds at T = 10^5, the conjecture is empirically robust.
"""

import numpy as np


class Quadratic:
    L = 1.0
    def f(self, x): return 0.5 * x ** 2
    def grad(self, x): return x
    def f_star(self): return 0.0


class Huber:
    """Smoothed Huber: sqrt(1+x^2) - 1, L = 1."""
    L = 1.0
    def f(self, x): return np.sqrt(1 + x ** 2) - 1
    def grad(self, x): return x / np.sqrt(1 + x ** 2)
    def f_star(self): return 0.0


class CubicSmooth:
    """f(x) = x^2/2 + x^4/(12 D^2) regularized to be L-smooth on |x| <= D.
    grad = x + x^3/(3 D^2). On |x| <= D: |Hessian| = 1 + x^2/D^2 <= 2, so L=2.
    """
    L = 2.0
    D = 1.0
    def f(self, x): return 0.5 * x ** 2 + x ** 4 / (12 * self.D ** 2)
    def grad(self, x): return x + x ** 3 / (3 * self.D ** 2)
    def f_star(self): return 0.0


def run_shb(instance, beta, eta_T, T, sigma, D, trials, seed):
    """SHB with constant horizon-tuned eta. Return E[f(y_T) - f*]."""
    rng = np.random.default_rng(seed)
    x_t = np.full(trials, D)
    x_tm1 = np.full(trials, D)
    L = instance.L
    if eta_T * L >= 2 * (1 + beta):
        return None
    for t in range(T):
        xi = rng.normal(0, sigma, size=trials)
        g_t = instance.grad(x_t) + xi
        x_new = x_t - eta_T * g_t + beta * (x_t - x_tm1)
        x_tm1 = x_t
        x_t = x_new
    return float(np.mean(instance.f(x_t))) - instance.f_star()


def main():
    print("=" * 80)
    print("Extended empirical evidence for Theorem 3 conjecture")
    print("=" * 80)
    print()

    sigma, D = 1.0, 1.0
    Ts = [100, 300, 1000, 3000, 10000, 30000, 100000]
    trials = 3000

    instances = [
        (Quadratic(), "Quadratic"),
        (Huber(), "Huber"),
        (CubicSmooth(), "Cubic-smooth (x^2/2 + x^4/(12 D^2))"),
    ]

    for inst, name in instances:
        print(f"--- {name} (L = {inst.L}) ---")
        for beta in [0.5, 0.9]:
            log_T, log_f = [], []
            print(f"  beta = {beta}:")
            print(f"    {'T':>8} {'eta':>10} {'E[f(y_T)-f*]':>14} {'σD/√T':>12} {'ratio':>10}")
            for T in Ts:
                eta_T = D * (1 - beta) / (sigma * np.sqrt(T))
                f_T = run_shb(inst, beta, eta_T, T, sigma, D, trials, seed=2026 + T + int(beta * 100))
                if f_T is None:
                    continue
                target = sigma * D / np.sqrt(T)
                ratio = f_T / target
                print(f"    {T:>8} {eta_T:>10.5f} {f_T:>14.6f} {target:>12.5f} {ratio:>10.4f}")
                if f_T > 0:
                    log_T.append(np.log(T))
                    log_f.append(np.log(f_T))
            if len(log_T) >= 3:
                slope, _ = np.polyfit(log_T, log_f, 1)
                print(f"  beta={beta}: empirical rate T^({slope:.3f})  [conjectured: T^(-0.5)]")
        print()

    print("=" * 80)
    print("If all empirical rates are close to T^{-0.5} and ratios stabilize at constants <= 1,")
    print("the conjecture is empirically robust at T up to 10^5.")


if __name__ == "__main__":
    main()
