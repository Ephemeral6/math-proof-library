"""
Detailed analysis of Route B: direct Lyapunov on (y_t, m_t).

We showed in resolution.md (Theorem 1) that the Lyapunov V_t = ||w_t - w*||^2 = ||y_t + a(y_t - y_{t-1}) - y*||^2
gives Cesàro UB matching LB in rate, but not last-iterate.

Here we analyze whether using the convexity LB on the bias term
    <∇f(y_t), u_t> >= f(y_t) - f(y_{t-1})    (where u_t = y_t - y_{t-1})
leads to a telescope that gives last-iterate UB.

Key claim from the audit-fix attempt:
  -a <∇f(y_t), u_t>  <=  -a (f(y_t) - f(y_{t-1}))    (signed UB on bias contribution)

When summed with constant weight C:
  Sum_t C * (-a (f(y_t) - f(y_{t-1}))) = -aC (f(y_T) - f(y_0))

This is BOUNDED (at most a*C*LD^2/2 in absolute value), but it does NOT decay in T.

Question: does this help us close the proof gap?

Numerical check on quadratic at horizon-tuned eta_T:
  - Compute Sum_t -a <∇f(y_t), u_t> directly
  - Compare to LD^2/2 (the upper bound from convexity telescope)
  - Compare to actual rate of f(y_T) - f*

If the empirical sum is much smaller than aLD^2/2, then there's additional cancellation
beyond what convexity gives. This means the telescope-based proof is NOT sufficient,
even with signed analysis.
"""

import numpy as np


def quadratic_grad(x, L=1.0):
    return L * x


def quadratic_f(x, L=1.0):
    return 0.5 * L * x ** 2


def main():
    print("=" * 80)
    print("Route B analysis: convexity-based signed bias bound")
    print("=" * 80)
    print()
    print("Convexity LB: <∇f(y_t), u_t> >= f(y_t) - f(y_{t-1})")
    print("Sum: Σ -a <∇f(y_t), u_t> <= -a (f(y_T) - f(y_0))")
    print("Worst case: |bias_sum| <= a * LD^2/2  (if f(y_T) -> f^* and f(y_0) ~ LD^2/2)")
    print()
    print("Empirical check: actual signed sum vs convexity-telescope upper bound")
    print()

    L, sigma, D = 1.0, 1.0, 1.0
    Ts = [100, 300, 1000, 3000, 10000]
    trials = 5000

    for beta in [0.0, 0.5, 0.9]:
        if beta == 0:
            continue  # SGD case, Liu-Zhou directly applies, no bias
        a = beta / (1 - beta)
        print(f"--- beta = {beta} (a = {a:.3f}) ---")
        print(f"Convexity-telescope UB on |bias_sum|: a*LD^2/2 = {a * L * D**2 / 2:.4f}")
        print()
        print(f"  {'T':>6} {'eta':>10} {'a*Σ<∇f,u>':>15} {'-a(f(y_T)-f(y_0))':>20} "
              f"{'∇f·u/T (per step)':>20}")

        for T in Ts:
            eta = D * (1 - beta) / (sigma * np.sqrt(T))
            if eta * L >= 2 * (1 + beta):
                continue
            rng = np.random.default_rng(2026 + T)
            x_t = np.full(trials, D)
            x_tm1 = np.full(trials, D)

            sum_grad_u = np.zeros(trials)  # Σ <∇f(y_t), u_t>
            for t in range(T):
                xi = rng.normal(0, sigma, size=trials)
                u_t = x_t - x_tm1
                grad_t = quadratic_grad(x_t, L)
                sum_grad_u += grad_t * u_t  # <∇f(y_t), u_t>
                g_t = grad_t + xi
                x_new = x_t - eta * g_t + beta * (x_t - x_tm1)
                x_tm1 = x_t
                x_t = x_new

            f_y_T = quadratic_f(x_t, L)
            f_y_0 = 0.5 * L * D ** 2
            empirical_bias_sum = -a * float(np.mean(sum_grad_u))
            telescope_bound = -a * (float(np.mean(f_y_T)) - f_y_0)
            per_step = float(np.mean(sum_grad_u)) / T

            print(f"  {T:>6} {eta:>10.5f} {empirical_bias_sum:>15.5f} "
                  f"{telescope_bound:>20.5f} {per_step:>20.6e}")

        print()

    print("=" * 80)
    print("CONCLUSION:")
    print("=" * 80)
    print("If empirical |bias_sum| << a*LD^2/2 with strong T-decay, the convexity-telescope")
    print("UB is much looser than reality. Closing the proof requires showing the actual")
    print("signed sum decays faster.")
    print()
    print("If empirical |bias_sum| ~ a*LD^2/2 (constant), the convexity telescope is tight")
    print("but gives a constant offset that doesn't help for last-iterate decay.")
    print()
    print("The numerical evidence will tell us which route to pursue.")


if __name__ == "__main__":
    main()
