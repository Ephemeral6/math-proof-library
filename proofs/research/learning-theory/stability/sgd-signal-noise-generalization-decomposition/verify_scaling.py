"""
Verification round 3: Empirical scaling test of gen gap vs T, m, eta, sigma_N.

Test if gen gap actually scales as σ_N^2 η T/m  (linear)
                              or as σ_N^2 η^2 T/m  (η^2!)
                              or as σ_N^2 η /m    (no T)
                              or as σ_N^2 η √(T/m) (sqrt T)
"""

import math
import numpy as np

rng = np.random.default_rng(42)


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


def gen_gap(d, m, T, eta, sigma_N, G_S_target, n_trials=400):
    eigs = np.linspace(0.1, 1.0, d)
    Q = rng.standard_normal((d, d))
    Q, _ = np.linalg.qr(Q)
    H = Q @ np.diag(eigs) @ Q.T
    b = rng.standard_normal(d)
    b = b / np.linalg.norm(b) * G_S_target

    diffs = []
    for trial in range(n_trials):
        S = rng.standard_normal((m, d)) * sigma_N
        L_S_theta, L_emp = run_sgd_trial(d, m, T, eta, H, b, sigma_N, S)
        diffs.append(L_S_theta - L_emp)

    return abs(np.mean(diffs))


# Sweep T at fixed m, eta, sigma_N
print("Test 1: scaling with T (fixed m=200, η=0.02, σ_N=1, G_S=0.05)")
print(f"  {'T':<6} {'gen_gap':<12} {'gap/(η T/m)':<14} {'gap/(η^2 T/m)':<16} {'gap/(η √(T/m))':<16}")
for T in [25, 50, 100, 200, 400]:
    g = gen_gap(d=5, m=200, T=T, eta=0.02, sigma_N=1.0, G_S_target=0.05, n_trials=400)
    print(f"  {T:<6} {g:<12.6f} {g/(0.02*T/200):<14.6f} {g/(0.02**2 * T/200):<16.6f} {g/(0.02 * math.sqrt(T/200)):<16.6f}")

print()
print("Test 2: scaling with eta (fixed m=200, T=100, σ_N=1, G_S=0.05)")
print(f"  {'eta':<8} {'gen_gap':<12} {'gap/η':<14} {'gap/η^2':<16}")
for eta in [0.005, 0.01, 0.02, 0.04]:
    g = gen_gap(d=5, m=200, T=100, eta=eta, sigma_N=1.0, G_S_target=0.05, n_trials=400)
    print(f"  {eta:<8} {g:<12.6f} {g/eta:<14.6f} {g/eta**2:<16.6f}")

print()
print("Test 3: scaling with σ_N (fixed m=200, T=100, η=0.02, G_S=0.05)")
print(f"  {'σ_N':<8} {'gen_gap':<12} {'gap/σ_N^2':<14}")
for sN in [0.5, 1.0, 2.0, 4.0]:
    g = gen_gap(d=5, m=200, T=100, eta=0.02, sigma_N=sN, G_S_target=0.05, n_trials=400)
    print(f"  {sN:<8} {g:<12.6f} {g/(sN**2):<14.6f}")

print()
print("Test 4: scaling with m (fixed T=100, η=0.02, σ_N=1, G_S=0.05)")
print(f"  {'m':<6} {'gen_gap':<12} {'gap*m':<14}")
for m in [50, 100, 200, 400]:
    g = gen_gap(d=5, m=m, T=100, eta=0.02, sigma_N=1.0, G_S_target=0.05, n_trials=400)
    print(f"  {m:<6} {g:<12.6f} {g*m:<14.6f}")
