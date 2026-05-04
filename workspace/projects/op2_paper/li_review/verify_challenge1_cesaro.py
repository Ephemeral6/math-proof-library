"""
Challenge 1 verification: Does Cesaro average kill the bias term?

OP-2's bias LB is for last iterate x_T cycling on K=3 polygon.
We check: if x_T = (D/sqrt2) e_{T mod 3}, what is f_0(x_bar_T) where
x_bar_T = (1/T) sum_{t=1}^{T} x_t?

Setup:
- K = 3, e_0 = (1,0), e_1 = (-1/2, sqrt(3)/2), e_2 = (-1/2, -sqrt(3)/2)
- e_0 + e_1 + e_2 = 0
- So Cesaro average over full periods is exactly 0.
- f_0 is mu-strongly convex, so f_0(0) = f_0^* = 0.
- Hence f_0(x_bar_T) <= (L/2) ||x_bar_T||^2.

We compute this for T = 100, 1000, 10000.
"""

import numpy as np

# Parameters from a sample feasible point: (beta, eta L) = (0.5, 3), K=3, kappa=0.25
L = 1.0
D = 1.0
mu_over_L = 0.25
mu = mu_over_L * L

# Goujaud cycle vertices
e = np.array([
    [np.cos(2*np.pi*t/3), np.sin(2*np.pi*t/3)] for t in range(3)
])
print("Vertices e_t:")
for t, v in enumerate(e):
    print(f"  e_{t} = {v},  ||e_{t}|| = {np.linalg.norm(v):.6f}")
print(f"Sum: e_0 + e_1 + e_2 = {e.sum(axis=0)}")

lam = D / np.sqrt(2)
print(f"\nx_t = (D/sqrt(2)) e_{{t mod 3}} = lam * e_{{t mod 3}}, lam = {lam:.6f}")
print(f"||x_t|| = {lam:.6f} = D/sqrt(2)")

# f_0 lower bound (last iterate): mu/2 * ||x_T||^2 = mu * D^2 / 4
last_iterate_lb = mu * D**2 / 4
print(f"\nLast-iterate LB: f_0(x_T) - f_0* >= mu D^2 / 4 = {last_iterate_lb:.6f}")

# Now compute Cesaro average for various T
print("\n" + "="*70)
print(f"{'T':>8} {'||x_bar_T||':>14} {'f_0_upper':>14} {'f_0_lower(via mu||.||^2/2)':>30}")
print("="*70)

for T in [10, 99, 100, 101, 999, 1000, 1001, 9999, 10000, 10001, 99999, 100000]:
    # x_t for t=1..T
    iterates = np.array([lam * e[t % 3] for t in range(1, T+1)])
    x_bar = iterates.mean(axis=0)
    norm_xbar = np.linalg.norm(x_bar)

    # Upper bound on f_0: L/2 ||x_bar||^2  (since f_0 is L-smooth, f_0(x) <= f_0(0) + 0 + L/2 ||x||^2 = L/2||x||^2)
    f0_upper = (L/2) * norm_xbar**2
    # Lower bound on f_0: mu/2 ||x_bar||^2  (mu-SC of f_0)
    f0_lower = (mu/2) * norm_xbar**2

    print(f"{T:>8} {norm_xbar:>14.8e} {f0_upper:>14.8e} {f0_lower:>30.8e}")

# T-scaling of f_0(x_bar): for T=3k+r, x_bar = (lam/T) * sum_{partial} e_t
# norm <= (lam/T) * 2 (worst-case partial sum bound), so f_0(x_bar) <= L/2 * (2*lam/T)^2 = 2 L lam^2 / T^2 = L D^2 / T^2
print("\nClaim: ||x_bar_T|| <= 2 lam / T = D*sqrt(2) / T, hence f_0(x_bar_T) <= L D^2 / T^2.")
print("Verify constant: at T=99 (=3*33), x_bar = 0 exactly; at T=100, x_bar = lam*e_0/T.")
print(f"  T=100: predicted ||x_bar|| = lam/100 = {lam/100:.6e}")
print(f"  T=99 (full period): predicted ||x_bar|| = 0")

# Compare last-iterate vs Cesaro-average rates
print("\n" + "="*70)
print(f"{'T':>8} {'last-iter LB':>15} {'Cesaro f0(x_bar)':>20} {'ratio Cesaro/LastIter':>25}")
print("="*70)
for T in [100, 1000, 10000, 100000]:
    iterates = np.array([lam * e[t % 3] for t in range(1, T+1)])
    x_bar = iterates.mean(axis=0)
    norm_xbar = np.linalg.norm(x_bar)
    f0_xbar_upper = (L/2) * norm_xbar**2
    print(f"{T:>8} {last_iterate_lb:>15.6e} {f0_xbar_upper:>20.6e} {f0_xbar_upper/last_iterate_lb:>25.6e}")

print("\nCONCLUSION: Cesaro average KILLS the bias term.")
print("f_0(x_bar_T) -> 0 like O(1/T^2), NOT Omega(1/T).")
print("In fact, for T = multiple of K=3, x_bar_T = 0 exactly, so f_0(x_bar_T) = 0.")
