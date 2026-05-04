"""
Numerical verification of S4 Part (B): variance impossibility under interpolation.

Setup:
  f(x) = (L/2) ||x||^2 on R^d
  Oracle: g_t = L*x_t + sigma * ||x_t|| * epsilon_t,
          epsilon_t ~ Uniform on unit sphere in R^d
  SHB:    x_{t+1} = x_t - eta * g_t + beta * (x_t - x_{t-1})
          beta = 0, eta = 1/(2L)  (vanilla GD, contraction = 1/2)

Predicted rate (theory):
  E||x_t||^2 = ((1 + sigma^2/L^2)/4)^t * D^2
  E[f(x_t)]  = (L/2) * E||x_t||^2

We test sigma = 0.0, 0.5, 1.0, 1.5 (all < L*sqrt(3) ~ 1.732 for L=1).
"""

import numpy as np

np.random.seed(42)

L = 1.0
D = 1.0
d = 10
N = 20000   # number of trajectories
T = 50

beta = 0.0
eta = 1.0 / (2.0 * L)

print(f"L={L}, D={D}, d={d}, N_trajectories={N}, T={T}")
print(f"SHB params: beta={beta}, eta={eta}")
print(f"Theoretical contraction rate: rho = (1 + sigma^2/L^2)/4")
print()

for sigma in [0.0, 0.5, 1.0, 1.5]:
    rho_theory = (1 + sigma**2 / L**2) / 4
    print(f"--- sigma = {sigma} ---")
    print(f"  Theoretical rho = {rho_theory:.6f}")

    # Initialize: ||x_0|| = D, random direction
    x_init = np.random.randn(N, d)
    x_init = x_init / np.linalg.norm(x_init, axis=1, keepdims=True) * D
    x_prev = x_init.copy()
    x_curr = x_init.copy()

    sq_norms = np.zeros(T + 1)
    sq_norms[0] = np.mean(np.sum(x_curr**2, axis=1))

    for t in range(T):
        # Sample epsilon: Uniform on unit sphere in R^d, independent for each trajectory
        eps = np.random.randn(N, d)
        eps = eps / np.linalg.norm(eps, axis=1, keepdims=True)
        # Magnitude: ||x_t||
        norm_x = np.linalg.norm(x_curr, axis=1, keepdims=True)
        # Stochastic gradient
        g = L * x_curr + sigma * norm_x * eps
        # SHB update
        x_next = x_curr - eta * g + beta * (x_curr - x_prev)
        x_prev = x_curr.copy()
        x_curr = x_next
        sq_norms[t + 1] = np.mean(np.sum(x_curr**2, axis=1))

    # Empirical contraction
    # Look at last 10 ratios for stable estimate
    ratios = sq_norms[20:T] / sq_norms[19:T-1]
    rho_emp = np.mean(ratios[ratios > 0])
    print(f"  Empirical rho (avg over t=20..50): {rho_emp:.6f}")
    print(f"  E||x_T||^2 at T={T}: {sq_norms[T]:.4e}")
    print(f"  Predicted: D^2 * rho^T = {rho_theory**T:.4e}")
    print(f"  Ratio empirical/predicted: {sq_norms[T] / rho_theory**T:.4f}")

    # Comparison with sigma*D/sqrt(T)
    if sigma > 0:
        f_T = (L / 2) * sq_norms[T]
        polynomial_target = sigma * D / np.sqrt(T)
        print(f"  E[f(x_T)] = {f_T:.4e}")
        print(f"  sigma*D/sqrt(T) = {polynomial_target:.4e}")
        print(f"  Ratio f(x_T)/(sigma D/sqrt T) = {f_T / polynomial_target:.4e}  (small means LB violated)")
    print()

# Refutation summary
print("=" * 60)
print("REFUTATION OF VARIANCE LOWER BOUND")
print("=" * 60)
print(f"At sigma=1.0, T={T}:")
print(f"  E[f(x_T)] / (sigma*D/sqrt(T)) ratio shows polynomial LB violated.")
print(f"  Linear convergence beats any polynomial rate for T large enough.")
