"""
Sub-task A bias-term test: on the OP-2 hard instance with stochastic noise,
does E[f_0(bar_x_T)] satisfy Omega(LD^2/T)?

The hard instance: f^(s)(x, y) = f_0(x) + alpha_s y + w(y).
- x dynamics are deterministic on f_0 (Goujaud cycling)
- bar_x_T -> 0 deterministically as T -> inf (cycling averages to 0)

But: WITH stochastic noise on x-coordinate too, can we get a bias-term LB on bar_x_T?

Note: OP-2's oracle puts noise only on y. We test what happens if we put noise on x as well
(stronger oracle), and whether averaging still kills the bias.
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

beta = 0.5
eta = 3.0 / L
mu = 0.25 * L
M = ((1 + beta - mu*eta)*I2 - R_pos - beta*R_neg) / ((L - mu)*eta)
P_vertices = (M @ e.T).T
tilde_P = lam * P_vertices

def project_to_polygon(x, vertices):
    K = vertices.shape[0]
    def obj(w):
        v = vertices.T @ w
        return np.sum((v - x)**2)
    cons = [{'type': 'eq', 'fun': lambda w: w.sum() - 1}]
    bnds = [(0, 1)] * K
    res = minimize(obj, x0=np.ones(K)/K, method='SLSQP', constraints=cons, bounds=bnds, tol=1e-13)
    return vertices.T @ res.x

def grad_f0(x):
    return mu * x + (L - mu) * project_to_polygon(x, tilde_P)
def f0(x):
    p = project_to_polygon(x, tilde_P)
    return (L/2) * x @ x - (L - mu)/2 * np.sum((x - p)**2)

# OP-2 init: cycling
x_minus1 = lam * e[K-1]
x_0 = lam * e[0]

T_values = [50, 200, 1000]
sigma_x = 0.1   # noise on x-coordinate (stronger oracle than OP-2)

print(f"Test: averaged-iterate bias term on Goujaud cycling, with x-noise.")
print(f"Params: beta={beta}, eta L={eta*L}, kappa={mu}, sigma_x={sigma_x}")
print()

for T in T_values:
    n_trials = 200
    f0_lasts = []
    f0_avgs = []

    for trial in range(n_trials):
        rng = np.random.default_rng(trial)
        xs = [x_minus1.copy(), x_0.copy()]
        running_sum = np.zeros(2)
        for t in range(T):
            running_sum += xs[-1]
            g = grad_f0(xs[-1]) + sigma_x * rng.standard_normal(2)
            new = xs[-1] - eta * g + beta * (xs[-1] - xs[-2])
            xs.append(new)

        x_last = xs[-1]
        x_avg = running_sum / T
        f0_lasts.append(f0(x_last))
        f0_avgs.append(f0(x_avg))

    target_bias = (mu / 4) * L * D**2 / T   # OP-2 bias LB target
    print(f"T = {T}: target (kappa/4) LD^2/T = {target_bias:.6f}")
    print(f"  E[f_0(x_T)] last iter: {np.mean(f0_lasts):.6f}  (ratio to target: {np.mean(f0_lasts)/target_bias:.3f})")
    print(f"  E[f_0(bar_x_T)] avg iter: {np.mean(f0_avgs):.6f}  (ratio: {np.mean(f0_avgs)/target_bias:.3f})")
    print(f"  ||bar_x_T||^2 mean: {np.mean([np.sum(x**2) for x in [running_sum/T]]):.6f}")
    print()
