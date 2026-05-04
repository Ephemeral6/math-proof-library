"""
Compare the rates achieved by two stepsize schedules on SHB last iterate:

  Schedule A (horizon-tuned): eta_T = D(1-beta)/(sigma sqrt(T))   [our Theorem 3]
  Schedule B (Hudiani 2025):   eta_t = t^{-2/3}                    [optimal p for fixed-beta]

If Schedule A gives empirical T^{-1/2} and Schedule B gives T^{-1/3}, we
empirically confirm that horizon-tuning beats T-unaware decay.

This would resolve the apparent contradiction:
- Hudiani: T^{-1/3} for fixed β + decaying η_t
- Our Theorem 3 conjecture: T^{-1/2} for fixed β + horizon-tuned constant η_T

These ARE consistent because the schedules are different. Hudiani's bound
applies to T-UNAWARE schedules; horizon-tuning gives a faster rate.
"""

import numpy as np


def quadratic_grad(x, L=1.0):
    return L * x


def quadratic_f(x, L=1.0):
    return 0.5 * L * x ** 2


def f_star_quadratic():
    return 0.0


def run_shb_horizon_tuned(beta, T, sigma, D, L, trials, seed=42):
    """SHB with constant horizon-tuned η_T = D(1-β)/(σ√T)."""
    eta = D * (1 - beta) / (sigma * np.sqrt(T))
    if eta * L >= 2 * (1 + beta):
        return None  # unstable
    rng = np.random.default_rng(seed)
    x_t = np.full(trials, D)
    x_tm1 = np.full(trials, D)
    for t in range(T):
        xi = rng.normal(0, sigma, size=trials)
        g_t = quadratic_grad(x_t, L) + xi
        x_new = x_t - eta * g_t + beta * (x_t - x_tm1)
        x_tm1 = x_t
        x_t = x_new
    return float(np.mean(quadratic_f(x_t, L)))


def run_shb_hudiani(beta, T, sigma, D, L, trials, p=2/3, seed=42):
    """SHB with Hudiani's schedule η_t = c * t^{-p}, T-unaware.

    We pick c so that η_1 ≈ D(1-β)/(σ) (matching the early stage of horizon-tuned).
    """
    c = D * (1 - beta) / sigma
    rng = np.random.default_rng(seed)
    x_t = np.full(trials, D)
    x_tm1 = np.full(trials, D)
    for t in range(1, T + 1):
        eta_t = c * t ** (-p)
        if eta_t * L >= 2 * (1 + beta):
            eta_t = (1 + beta) / L  # cap at stability boundary
        xi = rng.normal(0, sigma, size=trials)
        g_t = quadratic_grad(x_t, L) + xi
        x_new = x_t - eta_t * g_t + beta * (x_t - x_tm1)
        x_tm1 = x_t
        x_t = x_new
    return float(np.mean(quadratic_f(x_t, L)))


def main():
    print("=" * 80)
    print("Compare horizon-tuned constant η_T vs Hudiani decaying η_t = t^{-2/3}")
    print("=" * 80)
    print()
    print("If horizon-tuning gives T^{-1/2} and Hudiani gives T^{-1/3}, this empirically")
    print("resolves the apparent contradiction.")
    print()

    L, sigma, D = 1.0, 1.0, 1.0
    Ts = [100, 300, 1000, 3000, 10000, 30000]
    trials = 4000

    for beta in [0.5, 0.9]:
        print(f"--- beta = {beta} ---")
        print(f"  {'T':>8} {'horizon-tuned':>15} {'Hudiani p=2/3':>15} {'σD/√T':>12}")
        log_T_HT, log_HT = [], []
        log_T_Hud, log_Hud = [], []
        for T in Ts:
            f_HT = run_shb_horizon_tuned(beta, T, sigma, D, L, trials, seed=2026 + T)
            f_Hud = run_shb_hudiani(beta, T, sigma, D, L, trials, p=2/3, seed=2026 + T)
            target = sigma * D / np.sqrt(T)
            print(f"  {T:>8} {f_HT:>15.6f} {f_Hud:>15.6f} {target:>12.5f}")
            if f_HT is not None and f_HT > 0:
                log_T_HT.append(np.log(T))
                log_HT.append(np.log(f_HT))
            if f_Hud is not None and f_Hud > 0:
                log_T_Hud.append(np.log(T))
                log_Hud.append(np.log(f_Hud))

        if len(log_T_HT) >= 3:
            slope_HT, _ = np.polyfit(log_T_HT, log_HT, 1)
            print(f"  Horizon-tuned: empirical rate T^({slope_HT:.3f})  [predicted: T^(-0.5)]")
        if len(log_T_Hud) >= 3:
            slope_Hud, _ = np.polyfit(log_T_Hud, log_Hud, 1)
            print(f"  Hudiani p=2/3: empirical rate T^({slope_Hud:.3f})  [predicted: T^(-1/3)]")
        print()

    print("=" * 80)
    print("Interpretation:")
    print("=" * 80)
    print("If horizon-tuned ~ T^{-1/2} and Hudiani ~ T^{-1/3}, the conjecture is consistent")
    print("with the literature. Horizon-tuning is strictly better than Hudiani's schedule,")
    print("and Theorem 3 (T^{-1/2} for horizon-tuned) is genuinely a NEW result.")
    print()
    print("If Hudiani's schedule also gives T^{-1/2} empirically, there's a broader phenomenon")
    print("not captured by Hudiani's theoretical bound.")


if __name__ == "__main__":
    main()
