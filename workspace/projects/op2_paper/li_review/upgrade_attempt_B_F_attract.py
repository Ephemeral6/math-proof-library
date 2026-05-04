"""
Sub-task B: characterize F_attract subset of F where the cycling orbit is
ATTRACTIVE under zero-momentum initialization x_0 = x_{-1}.

If F_attract is non-empty (and ideally has positive measure), then OP-2's bound
holds on F_attract under standard zero-momentum init.

We do a grid search over (beta, eta L) in [0.31, 0.99] x [gamma_crit(beta), 2(1+beta)]
and classify each as 'attract' or 'decay' based on whether ||x_T|| -> D/sqrt(2)
or ||x_T|| -> 0 over T = 500 steps.
"""

import numpy as np
from scipy.optimize import minimize

L = 1.0
D = 1.0
K = 3
theta = 2*np.pi/K
e = np.array([
    [np.cos(theta*t), np.sin(theta*t)] for t in range(K)
])
R_pos = np.array([[np.cos(theta), -np.sin(theta)], [np.sin(theta), np.cos(theta)]])
R_neg = np.array([[np.cos(-theta), -np.sin(-theta)], [np.sin(-theta), np.cos(-theta)]])
I2 = np.eye(2)
lam = D / np.sqrt(2)

def project_to_polygon_simple(x, vertices):
    K = vertices.shape[0]
    def obj(w):
        v = vertices.T @ w
        return np.sum((v - x)**2)
    cons = [{'type': 'eq', 'fun': lambda w: w.sum() - 1}]
    bnds = [(0, 1)] * K
    res = minimize(obj, x0=np.ones(K)/K, method='SLSQP', constraints=cons, bounds=bnds, tol=1e-12)
    return vertices.T @ res.x

def gamma_crit(beta):
    return 3 * (1 + beta + beta**2) / (1 + 2*beta)

def find_kappa(beta, eta_L):
    """Find feasible kappa for K=3 cycling: solve quadratic in h = kappa eta L."""
    # ★_3:  h^2 - 2[(beta+1/2) + kappa(1+beta/2)] h + 3 kappa (1+beta+beta^2) <= 0
    # Substitute h = kappa eta L:
    # (kappa eta L)^2 - 2[(beta+1/2) + kappa(1+beta/2)](kappa eta L) + 3 kappa (1+beta+beta^2) = 0
    # divide by kappa:
    # kappa (eta L)^2 - 2[(beta+1/2)/kappa + (1+beta/2)](eta L) + 3(1+beta+beta^2) = 0
    # kappa (eta L)^2 - 2(beta+1/2)(eta L)/kappa - 2(1+beta/2)(eta L) + 3(1+beta+beta^2) = 0
    # multiply by kappa:
    # kappa^2 (eta L)^2 - 2(beta+1/2)(eta L) - kappa[2(1+beta/2)(eta L) - 3(1+beta+beta^2)] = 0
    # actually this is messy; let's just use the discriminant approach
    # We have ★_3 in kappa: kappa (eta L)^2 - 2[beta+1/2 + kappa(1+beta/2)] eta L + 3 kappa(1+beta+beta^2) <= 0
    # Reorganize as quadratic in kappa: kappa^2 [...] + ... let's just use numerical search
    from scipy.optimize import brentq
    def lhs(kappa):
        h = kappa * eta_L
        return h**2 - 2*((beta - (-0.5)) + kappa*(1 + beta*(-0.5))*(-1))*h + 2*kappa*(1 - (-0.5))*(1+beta**2 - 2*beta*(-0.5))
    # Actually use the simplified ★_3 form from line 502 of proof:
    # h^2 - 2[(beta+1/2) + kappa(1+beta/2)] h + 3 kappa (1+beta+beta^2) <= 0
    def cyc_lhs(kappa):
        h = kappa * eta_L
        return h**2 - 2*((beta + 0.5) + kappa*(1 + beta/2)) * h + 3*kappa*(1 + beta + beta**2)

    # Find kappa where this = 0 (boundary of feasibility), pick midpoint
    # cyc_lhs(0) = 0 (degenerate); try kappa in (0.001, 0.999)
    try:
        ks = np.linspace(0.001, 0.999, 100)
        vals = [cyc_lhs(k) for k in ks]
        feasible_ks = [k for k, v in zip(ks, vals) if v <= 0]
        if not feasible_ks:
            return None
        return feasible_ks[len(feasible_ks)//2]  # midpoint
    except:
        return None

def classify(beta, eta, T=500):
    """Run zero-momentum init and classify orbit."""
    eta_L = eta * L
    kappa = find_kappa(beta, eta_L)
    if kappa is None:
        return 'no_kappa', None
    mu = kappa * L
    M = ((1 + beta - mu*eta)*I2 - R_pos - beta*R_neg) / ((L - mu)*eta)
    P_vertices = (M @ e.T).T
    tilde_P = lam * P_vertices

    def grad_f0(x):
        return mu * x + (L - mu) * project_to_polygon_simple(x, tilde_P)

    x_minus1 = lam * e[0]
    x_0 = lam * e[0]
    xs = [x_minus1, x_0]
    for t in range(T):
        g = grad_f0(xs[-1])
        new = xs[-1] - eta * g + beta * (xs[-1] - xs[-2])
        xs.append(new)
        if np.linalg.norm(new) > 100:
            return 'diverge', kappa

    final_norm = np.linalg.norm(xs[-1])
    target = lam  # D/sqrt(2)
    if abs(final_norm - target) < 0.01:
        return 'attract', kappa
    elif final_norm < 0.01:
        return 'decay', kappa
    else:
        return f'other(|x|={final_norm:.3f})', kappa

# Grid search
print(f"Grid search over (beta, eta L) in F_K=3 (K=3).")
print(f"{'beta':>6} | {'eta L':>6} | {'kappa':>6} | classification")
print("-" * 60)

beta_grid = [0.31, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.95, 0.99]
eta_grid_count = 5

results = {}
for beta in beta_grid:
    g = gamma_crit(beta)
    s = 2 * (1 + beta)
    for eta_L in np.linspace(g + 0.01, s - 0.01, eta_grid_count):
        eta = eta_L / L
        cls, kappa = classify(beta, eta)
        marker = "✓" if cls == 'attract' else ("✗" if cls == 'decay' else "?")
        print(f"{beta:>6.2f} | {eta_L:>6.3f} | {kappa if kappa else 'NA':>6} | {marker} {cls}")
        results[(beta, eta_L)] = cls

# Summary
n_total = len(results)
n_attract = sum(1 for v in results.values() if v == 'attract')
n_decay = sum(1 for v in results.values() if v == 'decay')
print(f"\nSummary: {n_attract}/{n_total} attract, {n_decay}/{n_total} decay")
