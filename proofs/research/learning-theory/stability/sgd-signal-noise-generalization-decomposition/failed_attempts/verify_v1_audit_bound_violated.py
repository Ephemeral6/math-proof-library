"""
Numerical verification for Problem 2.1: Signal-Noise Decomposition for SGD Generalization.

Setup: Convex L-smooth quadratic loss with controllable signal/noise ratio.
- Population loss L_S(θ) = (1/2) θ^T H θ - b^T θ + c
- Per-sample noise: ℓ(θ;z) - L_S(θ) = <z, θ> + scalar offset, where z ~ N(0, σ_N^2 I)
  Then ∇ℓ(θ;z) = H θ - b + z, so ∇L_S(θ) = H θ - b, ∇L_N(θ;z) = z.
  E_z‖∇L_N‖^2 = d σ_N^2.

We compare:
- Empirical generalization gap: |E_S[L_S(θ_T)] - E_S Ê_S L(θ_T;·)|
- Our bound: 4 L (G_S^2 + σ_N_eff^2) η^2 T / m (1 + T/m)
- HRS bound: 2 (G_S^2 + σ_N_eff^2) η T / m

over many trials.
"""

import numpy as np

rng = np.random.default_rng(42)


def run_sgd_trial(d, m, T, eta, H, b, sigma_N, S):
    """Run SGD on dataset S of size m, T steps, return θ_T and empirical loss."""
    theta = np.zeros(d)
    for t in range(T):
        i = rng.integers(0, m)
        z = S[i]
        # gradient: ∇ℓ(θ;z) = H θ - b + z
        g = H @ theta - b + z
        theta = theta - eta * g
    # population loss L_S(θ) = (1/2) θ^T H θ - b^T θ
    L_S_theta = 0.5 * theta @ H @ theta - b @ theta
    # empirical loss = L_S(θ) + (1/m) Σ <z_i, θ>
    L_emp = L_S_theta + np.mean([z @ theta for z in S])
    return theta, L_S_theta, L_emp


def experiment(d=5, m=100, T=50, eta=0.05, sigma_N=1.0, G_S_target=0.1, n_trials=400):
    """Run n_trials of SGD and estimate generalization gap."""
    # Construct H (PSD, condition number controlled)
    eigs = np.linspace(0.1, 1.0, d)
    Q = rng.standard_normal((d, d))
    Q, _ = np.linalg.qr(Q)
    H = Q @ np.diag(eigs) @ Q.T
    L_smooth = max(eigs)  # smoothness constant of L_S
    # b chosen so that ‖∇L_S(0)‖ = ‖b‖ ≈ G_S_target
    b = rng.standard_normal(d)
    b = b / np.linalg.norm(b) * G_S_target

    diffs = []
    L_S_vals = []
    L_emp_vals = []
    for trial in range(n_trials):
        # Fresh dataset
        S = rng.standard_normal((m, d)) * sigma_N
        _, L_S_theta, L_emp = run_sgd_trial(d, m, T, eta, H, b, sigma_N, S)
        L_S_vals.append(L_S_theta)
        L_emp_vals.append(L_emp)
        diffs.append(L_S_theta - L_emp)

    gen_gap = np.abs(np.mean(diffs))

    # Bounds
    # Per-sample Lipschitz: G ≤ G_S + ‖z‖_max; use second moment
    # G^2 ≈ G_S^2 + d * sigma_N^2  (since E‖z‖^2 = d σ_N^2)
    sigma_N_eff_sq = d * sigma_N ** 2
    G_S_sq = G_S_target ** 2
    # smoothness of per-sample loss: same H, so L_total = L_smooth
    L_total = L_smooth

    G_S_bound = 4 * L_total * G_S_sq * eta**2 * T / m * (1 + T / m)
    G_N_bound = 4 * L_total * sigma_N_eff_sq * eta**2 * T / m * (1 + T / m)
    our_bound = G_S_bound + G_N_bound
    hrs_bound = 2 * (G_S_sq + sigma_N_eff_sq) * eta * T / m

    return {
        'gen_gap_empirical': gen_gap,
        'G_S_bound': G_S_bound,
        'G_N_bound': G_N_bound,
        'our_bound_total': our_bound,
        'HRS_bound': hrs_bound,
        'ratio_ours_over_HRS': our_bound / hrs_bound,
        'gap_within_our_bound': gen_gap <= our_bound,
        'gap_within_HRS_bound': gen_gap <= hrs_bound,
        'sigma_N_eff_sq': sigma_N_eff_sq,
        'G_S_sq': G_S_sq,
        'L_total': L_total,
        'eta_L': eta * L_total,
    }


print("=" * 75)
print("Experiment 1: Noise-dominated regime (G_S ≪ σ_N), small step")
print("=" * 75)
res1 = experiment(d=5, m=200, T=100, eta=0.02, sigma_N=1.0, G_S_target=0.05, n_trials=600)
for k, v in res1.items():
    print(f"  {k}: {v}")

print()
print("=" * 75)
print("Experiment 2: Signal-dominated regime (G_S ≫ σ_N)")
print("=" * 75)
res2 = experiment(d=5, m=200, T=100, eta=0.02, sigma_N=0.1, G_S_target=2.0, n_trials=600)
for k, v in res2.items():
    print(f"  {k}: {v}")

print()
print("=" * 75)
print("Experiment 3: Larger T (T > m), check 1+T/m factor")
print("=" * 75)
res3 = experiment(d=5, m=50, T=200, eta=0.02, sigma_N=1.0, G_S_target=0.05, n_trials=600)
for k, v in res3.items():
    print(f"  {k}: {v}")

print()
print("=" * 75)
print("Experiment 4: Very small step, check ηL → 0 tightening")
print("=" * 75)
res4 = experiment(d=5, m=200, T=100, eta=0.005, sigma_N=1.0, G_S_target=0.05, n_trials=600)
for k, v in res4.items():
    print(f"  {k}: {v}")

print()
print("=" * 75)
print("Summary: ratios of our_bound / HRS_bound (lower is better)")
print(f"  Exp 1 (noise-dom, ηL={res1['eta_L']:.4f}): {res1['ratio_ours_over_HRS']:.4f}")
print(f"  Exp 2 (signal-dom, ηL={res2['eta_L']:.4f}): {res2['ratio_ours_over_HRS']:.4f}")
print(f"  Exp 3 (T>m, ηL={res3['eta_L']:.4f}):       {res3['ratio_ours_over_HRS']:.4f}")
print(f"  Exp 4 (small η, ηL={res4['eta_L']:.4f}):   {res4['ratio_ours_over_HRS']:.4f}")
print("=" * 75)
