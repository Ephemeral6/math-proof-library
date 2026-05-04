"""
Challenge 2 verification: Does cycling hold with x_0 = x_{-1} (zero momentum init)?

Setup: simulate deterministic HB on the rescaled Goujaud function f_0
- Initialization A (special, used by OP-2): x_0 = (D/sqrt2) e_0, x_{-1} = (D/sqrt2) e_{K-1}
  → cycling: x_t = (D/sqrt2) e_{t mod K}.  ||x_t|| = D/sqrt2 forever.
- Initialization B (zero momentum, "standard SHB"): x_0 = x_{-1} = (D/sqrt2) e_0
  → check whether x_t cycles or decays.

We use a feasible (beta, eta) pair: (0.5, 3/L), kappa = 0.25, K=3.
"""

import numpy as np

# Parameters
L = 1.0
mu_over_L = 0.25
mu = mu_over_L * L
beta = 0.5
eta = 3.0 / L  # eta L = 3 > gamma_crit(0.5) = 2.625
D = 1.0
K = 3

# Rescaled Goujaud polytope
theta = 2*np.pi/K
e = np.array([
    [np.cos(theta*t), np.sin(theta*t)] for t in range(K)
])

# M matrix for projection identity P_C(e_t) = M e_t
# M = [(1+beta-mu*eta) I - R_theta - beta R_{-theta}] / [(L-mu) eta]
R_pos = np.array([[np.cos(theta), -np.sin(theta)], [np.sin(theta), np.cos(theta)]])
R_neg = np.array([[np.cos(-theta), -np.sin(-theta)], [np.sin(-theta), np.cos(-theta)]])
I2 = np.eye(2)
M = ((1 + beta - mu*eta)*I2 - R_pos - beta*R_neg) / ((L - mu)*eta)

# Verify: M e_t should equal P_{conv(P)}(e_t) per GTD23 Thm 3.5(iii)
# Polytope P = {M e_t : t}; rescaled to lam * P.
lam = D / np.sqrt(2)
P_vertices = (M @ e.T).T          # shape (K, 2)
tilde_P = lam * P_vertices         # shape (K, 2)

print("Polytope P vertices (M e_t):")
for t in range(K):
    print(f"  M e_{t} = {P_vertices[t]}")
print("Rescaled tilde_P vertices (lam * M e_t):")
for t in range(K):
    print(f"  tilde_v_{t} = {tilde_P[t]}")

# Distance from origin to tilde_P:
print(f"\n||tilde_v_0|| = {np.linalg.norm(tilde_P[0]):.6f}")

def project_to_polygon(x, vertices):
    """Project x onto convex hull of vertices. Use a simple QP via per-edge projection.
    For a convex polygon containing origin, do iterative refinement."""
    # Simple implementation: project onto each edge and onto each vertex; take closest point that is in the polytope.
    # For this triangular polytope with origin inside, we can use the standard barycentric / quadratic-programming approach.
    # Using cvxpy would be cleaner; here we use a small custom QP solver.
    from scipy.optimize import minimize
    K = vertices.shape[0]
    def obj(w):
        v = vertices.T @ w
        return np.sum((v - x)**2)
    cons = [
        {'type': 'eq', 'fun': lambda w: w.sum() - 1},
    ]
    bnds = [(0, 1)] * K
    res = minimize(obj, x0=np.ones(K)/K, method='SLSQP', constraints=cons, bounds=bnds, tol=1e-14)
    return vertices.T @ res.x

def grad_f0(x):
    """grad f_0(x) = mu * x + (L - mu) * P_{tilde_P}(x)"""
    return mu * x + (L - mu) * project_to_polygon(x, tilde_P)

def f0(x):
    """f_0(x) = (L/2) ||x||^2 - (L-mu)/2 d_{tilde_P}(x)^2"""
    p = project_to_polygon(x, tilde_P)
    return (L/2) * x @ x - (L - mu)/2 * np.sum((x - p)**2)

# Sanity: gradient at lam * e_0 should be (lam) * grad_psi(e_0), and the cycling should yield x_1 = lam e_1
print("\n--- Sanity check: cycling init ---")
x_minus1 = lam * e[K-1]
x_0 = lam * e[0]
g0 = grad_f0(x_0)
x_1 = x_0 - eta * g0 + beta * (x_0 - x_minus1)
print(f"x_0 = {x_0},  x_{{-1}} = {x_minus1}")
print(f"x_1 (predicted lam*e_1) = {lam*e[1]}")
print(f"x_1 (actual)            = {x_1}")
print(f"||x_1 - lam*e_1|| = {np.linalg.norm(x_1 - lam*e[1]):.2e}")

# Now run with cycling init for 100 steps
print("\n--- Run 1: cycling init x_0 = lam e_0, x_{-1} = lam e_{K-1} ---")
xs = [x_minus1, x_0]
fs = [f0(x_minus1), f0(x_0)]
for t in range(50):
    g = grad_f0(xs[-1])
    new = xs[-1] - eta * g + beta * (xs[-1] - xs[-2])
    xs.append(new)
    fs.append(f0(new))
norms_run1 = [np.linalg.norm(x) for x in xs]
print(f"||x_t|| at t=0,5,10,20,50: {[norms_run1[i+1] for i in [0,5,10,20,49]]}")
print(f"f_0(x_t) at t=0,5,10,20,50: {[fs[i+1] for i in [0,5,10,20,49]]}")
print(f"max ||x_t|| - D/sqrt(2): {max(abs(n - lam) for n in norms_run1[2:]):.2e}")

# Run with zero-momentum init: x_0 = x_{-1} = lam e_0
print("\n--- Run 2: zero-momentum init x_0 = x_{-1} = lam e_0 ---")
x_minus1 = lam * e[0]
x_0 = lam * e[0]
xs = [x_minus1, x_0]
fs = [f0(x_minus1), f0(x_0)]
for t in range(200):
    g = grad_f0(xs[-1])
    new = xs[-1] - eta * g + beta * (xs[-1] - xs[-2])
    xs.append(new)
    fs.append(f0(new))

norms_run2 = [np.linalg.norm(x) for x in xs]
print(f"||x_t|| at t=0,1,5,10,50,100,200:")
for tt in [0, 1, 5, 10, 50, 100, 200]:
    if tt + 1 < len(norms_run2):
        print(f"  t={tt:>3}: ||x_t|| = {norms_run2[tt+1]:.6e},  f_0(x_t) = {fs[tt+1]:.6e}")

# Verify what's happening: does ||x_t|| stay bounded? Does f_0(x_t) decay?
print(f"\nfinal f_0(x_T) at T=200: {fs[-1]:.6e}")
print(f"final ||x_T|| at T=200: {norms_run2[-1]:.6e}")
print(f"Ratio f_0(x_200) / (mu D^2 / 4) [last-iter LB target]: {fs[-1] / (mu * D**2 / 4):.6e}")

# Check: does the orbit cycle or converge?
last_few_norms = norms_run2[-10:]
print(f"\nLast 10 ||x_t||: {[f'{n:.4e}' for n in last_few_norms]}")

# To make the picture clearer, also try (beta, eta L) = (0.9, 3.5) -- another feasible point
print("\n\n========= REPLICATE WITH (beta, eta L) = (0.9, 3.5), kappa = 0.45 =========")
beta = 0.9
eta = 3.5 / L
mu = 0.45 * L
M = ((1 + beta - mu*eta)*I2 - R_pos - beta*R_neg) / ((L - mu)*eta)
P_vertices = (M @ e.T).T
tilde_P = lam * P_vertices

def grad_f0_b(x):
    return mu * x + (L - mu) * project_to_polygon(x, tilde_P)
def f0_b(x):
    p = project_to_polygon(x, tilde_P)
    return (L/2) * x @ x - (L - mu)/2 * np.sum((x - p)**2)

# Cycling init sanity
x_minus1 = lam * e[K-1]
x_0 = lam * e[0]
g0 = grad_f0_b(x_0)
x_1 = x_0 - eta * g0 + beta * (x_0 - x_minus1)
print(f"Cycling init sanity: ||x_1 - lam*e_1|| = {np.linalg.norm(x_1 - lam*e[1]):.2e}")

# Zero momentum init
x_minus1 = lam * e[0]
x_0 = lam * e[0]
xs = [x_minus1, x_0]
fs = [f0_b(x_minus1), f0_b(x_0)]
for t in range(500):
    g = grad_f0_b(xs[-1])
    new = xs[-1] - eta * g + beta * (xs[-1] - xs[-2])
    xs.append(new)
    fs.append(f0_b(new))

norms = [np.linalg.norm(x) for x in xs]
print(f"\nZero-momentum init, beta=0.9, eta L=3.5, kappa=0.45:")
for tt in [1, 5, 10, 50, 100, 200, 500]:
    if tt + 1 < len(norms):
        print(f"  t={tt:>3}: ||x_t|| = {norms[tt+1]:.6e},  f_0(x_t) = {fs[tt+1]:.6e}")

print(f"\n  mu D^2 / 4 (cycling LB target) = {mu * D**2 / 4:.6e}")
print(f"  f_0(x_500) / target = {fs[-1] / (mu*D**2/4):.6e}")
