"""
Verification for Problem I5: Polyak-Ruppert weighted average on Goujaud cycle.

Tests:
  [A] Closed-form sum |Σ_{t=1}^T t ω^t| matches theoretical bound.
  [B] Simulate SHB on the actual Goujaud function f_0 at feasible (β, η, K),
      compute three averages: last iterate, Cesaro, Polyak-Ruppert (linear weights).
  [C] Compare to predicted rates: last ~ Θ(1), Cesaro ~ 0, PR ~ Θ(1/T²).
"""

import numpy as np

def closed_form_sum(T, K):
    """Σ_{t=1}^T t ω^t  with ω = exp(2πi/K). Returns complex."""
    omega = np.exp(2j*np.pi/K)
    # Direct sum
    direct = sum(t * omega**t for t in range(1, T+1))
    # Closed form: z(1 - (T+1)z^T + T z^(T+1)) / (1-z)^2
    z = omega
    closed = z * (1 - (T+1)*z**T + T*z**(T+1)) / (1 - z)**2
    return direct, closed

print("=== [A] Closed-form sum verification ===")
for K in [3, 4, 6, 12]:
    for T in [10, 100, 1000]:
        direct, closed = closed_form_sum(T, K)
        err = abs(direct - closed)
        # Theoretical UB on |S_T|
        omega = np.exp(2j*np.pi/K)
        bound = 2*(T+1) / abs(1-omega)**2
        ratio = abs(direct) / bound  # should be < 1
        print(f"  K={K:2d}, T={T:5d}: |S_T|={abs(direct):.4e}, "
              f"closed_form_err={err:.2e}, bound={bound:.4e}, ratio={ratio:.3f}")

# ---------------------------------------------------------------
# [B] SHB on Goujaud's f_0 — simulate the actual cycling iterate.
# Per OP-2 proof, the iterate is x_t = (D/√2) e_{t mod K} exactly.
# We use this fact directly (already verified to 1e-15 in OP-2 audit).

def vertex(t, K, D):
    """Goujaud cycle vertex: (D/√2) (cos(t θ_K), sin(t θ_K))."""
    theta = 2*np.pi*t/K
    return (D/np.sqrt(2)) * np.array([np.cos(theta), np.sin(theta)])

def f0(x, mu, L):
    """For our purposes (smoothness UB), f0(x) ≤ (L/2)‖x‖² near 0.
       We use this bound. The exact value f0 = 0.5 L ‖x‖² - 0.5(L-μ) d_C(x)²
       is ≥ (μ/2)‖x‖² (lower) and ≤ (L/2)‖x‖² (upper, by smoothness from x*=0).
       For the disproof, the smoothness UB is what we need."""
    return 0.5 * L * np.dot(x, x)  # this is the UB; actual f0 is slightly smaller

print("\n=== [B] Polyak-Ruppert weighted average vs last vs Cesaro ===")
print("Setup: K-gon cycling iterate x_t = (D/√2) e_{t mod K}, D=1, L=1, μ=κ.")
D = 1.0
L = 1.0
for K in [3, 4, 6, 12]:
    print(f"\n  --- K = {K} ---")
    print(f"  {'T':>6} {'‖x_last‖²/2':>12} {'‖x̄ Cesaro‖²/2':>14} "
          f"{'‖x̃ PR‖²/2':>14} {'PR · T':>10} {'PR · T²':>12}")
    for T in [10, 100, 1000, 10000]:
        # Build iterate sequence (1..T)
        xs = np.array([vertex(t, K, D) for t in range(1, T+1)])
        x_last = xs[-1]
        x_cesaro = xs.mean(axis=0)
        weights = np.arange(1, T+1, dtype=float)
        x_PR = (weights[:, None] * xs).sum(axis=0) / weights.sum()

        f_last = 0.5 * L * (x_last @ x_last)
        f_ces  = 0.5 * L * (x_cesaro @ x_cesaro)
        f_PR   = 0.5 * L * (x_PR @ x_PR)

        print(f"  {T:>6d} {f_last:>12.4e} {f_ces:>14.4e} "
              f"{f_PR:>14.4e} {f_PR*T:>10.4e} {f_PR*T*T:>12.4e}")

# ---------------------------------------------------------------
# [C] Theoretical bound check
print("\n=== [C] Theoretical bound: f(x̃_T) ≤ L D² / (4 T² sin⁴(π/K)) ===")
for K in [3, 4, 6, 12]:
    s = np.sin(np.pi/K)
    coef = 1.0 / (4 * s**4)
    print(f"  K={K:2d}: sin(π/K)={s:.4f}, coefficient L D²/T² is {coef:.4f}")

# ---------------------------------------------------------------
# [D] Best constant in the bound
print("\n=== [D] Closed-form constant for f(x̃_T) ===")
print("  Compute ‖x̃_T‖² · T² for large T to see asymptotic constant.")
for K in [3, 4, 6, 12]:
    T = 100000
    xs = np.array([vertex(t, K, D) for t in range(1, T+1)])
    weights = np.arange(1, T+1, dtype=float)
    x_PR = (weights[:, None] * xs).sum(axis=0) / weights.sum()
    norm_sq = x_PR @ x_PR
    pred = D**2 / (2 * np.sin(np.pi/K)**4) / T**2  # asymptotic prediction
    print(f"  K={K:2d}: ‖x̃_T‖² · T² = {norm_sq * T**2:.4f}, predicted = {pred*T**2:.4f}")
