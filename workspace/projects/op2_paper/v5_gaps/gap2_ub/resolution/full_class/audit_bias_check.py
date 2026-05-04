"""
Critical numerical check for Audit 2:

The COV in Theorem 3 gives w_t = y_t + a(y_t - y_{t-1}). Then
    w_{t+1} - w_t = -nu g_t,   g_t = grad_f(y_t) + xi_t

This is "biased SGD" on w_t — gradient is at y_t, not w_t. The bias is
    b_t = grad_f(y_t) - grad_f(w_t),   ||b_t|| <= L ||y_t - w_t|| = L a eta ||m_t||.

For Liu-Zhou's analysis to apply, we need either unbiased SGD, OR bound the
cumulative bias contribution. The standard SGD analysis with biased gradient picks
up an additional term:
    bias contribution = sum_t nu_t E[<b_t, w_t - x*>] ~ sum_t nu_t * ||b_t|| * D

We numerically compute this cumulative bias contribution and check whether it
exceeds the LB rate sigma*D/sqrt(T). If it does, the proof in Step 2-3 is broken.

If the bias contribution decays at rate sigma*D/sqrt(T) or faster, the proof is
empirically valid (modulo formal derivation).
"""

import numpy as np


def quadratic_grad(x, L=1.0):
    return L * x


def quadratic_f(x, L=1.0):
    return 0.5 * L * x ** 2


def run_with_bias_tracking(beta, eta, T, sigma, D, L, trials, seed=42):
    """Run SHB and track:
       - <b_t, w_t - x*> per step (bias-iterate correlation, signed)
       - ||b_t|| per step
       - The cumulative R_bias = sum_t 2 nu_t |<b_t, w_t - x*>|
    """
    rng = np.random.default_rng(seed)
    x_t = np.full(trials, D)
    x_tm1 = np.full(trials, D)
    a = beta / (1 - beta) if beta < 1 else 0.0
    nu = eta / (1 - beta) if beta < 1 else eta

    cumulative_bias_signed = np.zeros(trials)  # Sum_t 2 nu <b_t, w_t - x*>
    cumulative_bias_abs = np.zeros(trials)     # Sum_t 2 nu |<b_t, w_t - x*>|
    cumulative_bias_norm = np.zeros(trials)    # Sum_t ||b_t||
    cumulative_g_norm_sq = np.zeros(trials)    # Sum_t ||g_t||^2

    for t in range(T):
        xi = rng.normal(0, sigma, size=trials)
        g_t = quadratic_grad(x_t, L) + xi
        # COV: w_t = x_t + a (x_t - x_{t-1})
        w_t = x_t + a * (x_t - x_tm1)
        # Bias: b_t = grad(y_t) - grad(w_t) = L*y_t - L*w_t = -L*(w_t - y_t) = -L*a*(x_t - x_{t-1})
        b_t = quadratic_grad(x_t, L) - quadratic_grad(w_t, L)
        # ⟨b_t, w_t - x*⟩, x* = 0
        bias_dot = b_t * w_t  # since 1D and x* = 0
        cumulative_bias_signed += 2 * nu * bias_dot
        cumulative_bias_abs += 2 * nu * np.abs(bias_dot)
        cumulative_bias_norm += np.abs(b_t)
        cumulative_g_norm_sq += g_t ** 2

        x_new = x_t - eta * g_t + beta * (x_t - x_tm1)
        x_tm1 = x_t
        x_t = x_new

    # Final f(y_T)
    f_y_T = quadratic_f(x_t, L)
    # Final f(w_T) where w_T = x_T + a(x_T - x_tm1)
    w_T = x_t + a * (x_t - x_tm1)
    f_w_T = quadratic_f(w_T, L)

    return {
        "f_y_T": float(np.mean(f_y_T)),
        "f_w_T": float(np.mean(f_w_T)),
        "y_minus_w_norm_sq": float(np.mean((x_t - w_T) ** 2)),
        "cumulative_bias_signed_mean": float(np.mean(cumulative_bias_signed)),
        "cumulative_bias_abs_mean": float(np.mean(cumulative_bias_abs)),
        "cumulative_bias_norm_mean": float(np.mean(cumulative_bias_norm)),
        "cumulative_g_norm_sq_mean": float(np.mean(cumulative_g_norm_sq)),
    }


def main():
    print("=" * 80)
    print("Critical Audit 2 check: bias contribution to SGD-on-w UB")
    print("=" * 80)
    print()
    print("Empirical question: at horizon-tuned eta_T = D(1-beta)/(sigma*sqrt(T)),")
    print("does the cumulative bias R_bias = sum_t 2 nu <b_t, w_t-x*> remain bounded")
    print("(i.e., O(sigma*D/sqrt(T)))? Or does it grow with T (refuting the rate)?")
    print()

    L, sigma, D = 1.0, 1.0, 1.0
    Ts = [100, 300, 1000, 3000, 10000]
    trials = 5000

    for beta in [0.5, 0.9]:
        print(f"\n=== beta = {beta} ===")
        print(f"  {'T':>6} {'eta':>10} {'<b,w>_abs':>14} {'<b,w>_signed':>14} "
              f"{'R_bias/T':>12} {'sigma*D/sqrt(T)':>16} {'ratio':>10}")
        for T in Ts:
            eta = D * (1 - beta) / (sigma * np.sqrt(T))
            if eta * L >= 2 * (1 + beta):
                continue
            res = run_with_bias_tracking(beta, eta, T, sigma, D, L, trials, seed=2026 + T)
            target = sigma * D / np.sqrt(T)
            R_bias_abs = res["cumulative_bias_abs_mean"]
            R_bias_signed = res["cumulative_bias_signed_mean"]
            ratio = R_bias_abs / target
            print(f"  {T:>6} {eta:>10.5f} {R_bias_abs:>14.5f} {R_bias_signed:>14.5f} "
                  f"{R_bias_abs/T:>12.6f} {target:>16.5f} {ratio:>10.4f}")

        # Compare R_bias_abs vs LD^2/T and sigma*D/sqrt(T) rates by log-log fit
        log_T = []
        log_R = []
        for T in Ts:
            eta = D * (1 - beta) / (sigma * np.sqrt(T))
            if eta * L >= 2 * (1 + beta):
                continue
            res = run_with_bias_tracking(beta, eta, T, sigma, D, L, trials, seed=2026 + T)
            log_T.append(np.log(T))
            log_R.append(np.log(max(res["cumulative_bias_abs_mean"], 1e-12)))
        if len(log_T) >= 3:
            slope, _ = np.polyfit(log_T, log_R, 1)
            print(f"  R_bias_abs scaling: T^({slope:.3f})")
            print(f"  Compare to: sigma*D/sqrt(T) ~ T^(-0.5), LD^2/T ~ T^(-1)")

    print()
    print("=" * 80)
    print("CONCLUSION:")
    print("=" * 80)
    print("If R_bias_abs ~ sigma*D/sqrt(T) (or smaller), the bias is absorbed in the rate")
    print("  -> proof can in principle be completed, Theorem 3 holds.")
    print("If R_bias_abs ~ constant (T-independent or slow-growing), the bias dominates")
    print("  -> proof in Step 2-3 has a fundamental gap.")


if __name__ == "__main__":
    main()
