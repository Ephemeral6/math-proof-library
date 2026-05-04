"""
Verification round 2: corrected bound from proof_v3.md.

|gen| ≤ 12√2 · η · (G_S^2 + σ_N^2) · (√(T/m) + T/m)
     = G_S(T) + G_N(T)

with G_S(T) = 12√2 η G_S^2 (√(T/m)+T/m), G_N(T) = 12√2 η σ_N^2 (√(T/m)+T/m).

Compare with HRS = 4 (G_S^2 + σ_N^2) η T / m.
"""

import math
import numpy as np

rng = np.random.default_rng(42)
SQRT2 = math.sqrt(2)


def run_sgd_trial(d, m, T, eta, H, b, sigma_N, S):
    theta = np.zeros(d)
    for t in range(T):
        i = rng.integers(0, m)
        z = S[i]
        g = H @ theta - b + z
        theta = theta - eta * g
    L_S_theta = 0.5 * theta @ H @ theta - b @ theta
    L_emp = L_S_theta + np.mean([z @ theta for z in S])
    return L_S_theta, L_emp


def experiment(d=5, m=100, T=50, eta=0.05, sigma_N=1.0, G_S_target=0.1, n_trials=400):
    eigs = np.linspace(0.1, 1.0, d)
    Q = rng.standard_normal((d, d))
    Q, _ = np.linalg.qr(Q)
    H = Q @ np.diag(eigs) @ Q.T
    L_smooth = max(eigs)
    b = rng.standard_normal(d)
    b = b / np.linalg.norm(b) * G_S_target

    diffs = []
    for trial in range(n_trials):
        S = rng.standard_normal((m, d)) * sigma_N
        L_S_theta, L_emp = run_sgd_trial(d, m, T, eta, H, b, sigma_N, S)
        diffs.append(L_S_theta - L_emp)

    gen_gap = np.abs(np.mean(diffs))
    sigma_N_eff_sq = d * sigma_N ** 2
    G_S_sq = G_S_target ** 2

    factor = math.sqrt(T / m) + T / m
    G_S_bound = 12 * SQRT2 * eta * G_S_sq * factor
    G_N_bound = 12 * SQRT2 * eta * sigma_N_eff_sq * factor
    our_bound = G_S_bound + G_N_bound
    hrs_bound = 4 * (G_S_sq + sigma_N_eff_sq) * eta * T / m

    # Ratio
    return {
        'gen_gap_empirical': float(gen_gap),
        'G_S_bound': G_S_bound,
        'G_N_bound': G_N_bound,
        'our_bound_total': our_bound,
        'HRS_bound': hrs_bound,
        'ratio_ours_over_HRS': our_bound / hrs_bound,
        'gap/our_bound': gen_gap / our_bound,
        'gap_within_our_bound': gen_gap <= our_bound,
        'gap_within_HRS_bound': gen_gap <= hrs_bound,
    }


print("=" * 75)
print("Experiment 1: Noise-dominated, T < m")
print("=" * 75)
for k, v in experiment(d=5, m=200, T=100, eta=0.02, sigma_N=1.0, G_S_target=0.05, n_trials=600).items():
    print(f"  {k}: {v}")

print()
print("=" * 75)
print("Experiment 2: Signal-dominated")
print("=" * 75)
for k, v in experiment(d=5, m=200, T=100, eta=0.02, sigma_N=0.1, G_S_target=2.0, n_trials=600).items():
    print(f"  {k}: {v}")

print()
print("=" * 75)
print("Experiment 3: T > m (multi-epoch)")
print("=" * 75)
for k, v in experiment(d=5, m=50, T=200, eta=0.02, sigma_N=1.0, G_S_target=0.05, n_trials=600).items():
    print(f"  {k}: {v}")

print()
print("=" * 75)
print("Experiment 4: very small step")
print("=" * 75)
for k, v in experiment(d=5, m=200, T=100, eta=0.005, sigma_N=1.0, G_S_target=0.05, n_trials=600).items():
    print(f"  {k}: {v}")

print()
print("=" * 75)
print("Experiment 5: T = m exactly")
print("=" * 75)
for k, v in experiment(d=5, m=100, T=100, eta=0.02, sigma_N=1.0, G_S_target=0.05, n_trials=600).items():
    print(f"  {k}: {v}")

print()
print("=" * 75)
print("Experiment 6: large T = 5m")
print("=" * 75)
for k, v in experiment(d=5, m=50, T=250, eta=0.01, sigma_N=1.0, G_S_target=0.05, n_trials=600).items():
    print(f"  {k}: {v}")
