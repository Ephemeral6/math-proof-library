"""
Variance check with Gaussian noise (so KL/Le Cam analysis is valid).

Test: does E[min_t g_y(y_t) - min g_y] >= c * sigma*D / sqrt(T) for several (β, η) and T?

If YES for Gaussian (and FAILS for Rademacher), the Le Cam argument needs Gaussian noise.
"""
import numpy as np

L = 1.0
D = 1.0
sigma = 1.0


def g_y(y, alpha, L, D):
    base = alpha * y
    wall = (L / 2) * max(abs(y) - D / np.sqrt(2), 0) ** 2
    return base + wall


def g_y_min(alpha, L, D):
    return -abs(alpha) * D / np.sqrt(2) - alpha**2 / (2 * L)


def grad_g_y(y, alpha, L, D):
    base = alpha
    if abs(y) > D / np.sqrt(2):
        wall = L * (abs(y) - D / np.sqrt(2)) * np.sign(y)
    else:
        wall = 0.0
    return base + wall


def run_shb_y(beta, eta, T, sigma_oracle, L, D, s, seed=0, noise_type='gauss'):
    rng = np.random.default_rng(seed)
    alpha = s * sigma_oracle / (2 * np.sqrt(2 * T))
    y_prev, y_curr = 0.0, 0.0
    gaps = [g_y(y_curr, alpha, L, D) - g_y_min(alpha, L, D)]
    if noise_type == 'gauss':
        noise = rng.normal(0, sigma_oracle, size=T)
    elif noise_type == 'rad':
        noise = sigma_oracle * (2 * rng.integers(0, 2, size=T) - 1)
    for t in range(T):
        g = grad_g_y(y_curr, alpha, L, D) + noise[t]
        y_next = y_curr - eta * g + beta * (y_curr - y_prev)
        y_prev = y_curr
        y_curr = y_next
        gaps.append(g_y(y_curr, alpha, L, D) - g_y_min(alpha, L, D))
    return np.array(gaps)


for noise_type in ['gauss', 'rad']:
    print()
    print("=" * 80)
    print(f"Noise = {noise_type}")
    print("=" * 80)
    print(f"{'(β,η/L)':<14}{'T':>8}{'max_s E[min gap]':>20}{'σD/(12.4√T)':>14}{'σD/(56√T)':>13}{'pass(12.4)':>11}")
    n_trials = 400
    for beta, etaL in [(0.5, 1.0), (0.5, 0.1), (0.0, 1.0)]:
        eta = etaL / L
        for T in [10, 100, 1000]:
            means_per_s = {}
            for s in [-1, 1]:
                min_gaps = []
                for trial in range(n_trials):
                    gaps = run_shb_y(beta, eta, T, sigma, L, D, s,
                                     seed=trial * 4 + (s + 1), noise_type=noise_type)
                    min_gaps.append(gaps.min())
                means_per_s[s] = np.mean(min_gaps)
            max_mean = max(means_per_s.values())
            target_124 = sigma * D / (12.4 * np.sqrt(T))
            target_56 = sigma * D / (56 * np.sqrt(T))
            pass124 = "YES" if max_mean >= target_124 else "NO"
            print(f"  ({beta:.1f},{etaL:.1f}) {T:>10}{max_mean:>20.6f}{target_124:>14.6f}{target_56:>13.6f}{pass124:>11}")

print("\nDone.")
