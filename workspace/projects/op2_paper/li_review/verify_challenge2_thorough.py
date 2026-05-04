"""
Challenge 2 thorough check: with zero-momentum init x_0 = x_{-1} = (D/sqrt2) e_0,
does f_0(x_T) >= (kappa/4) L D^2 / T hold for EVERY T?

The OP-2 cycling LB μD^2/4 = κLD^2/4 is constant; the per-T LB is c·LD^2/T = (κ/4)LD^2/T.
We track f_0(x_T) for every T from 1 to 500 and check the ratio f_0(x_T) / [(κ/4)LD^2/T].
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

def project_to_polygon(x, vertices):
    K = vertices.shape[0]
    def obj(w):
        v = vertices.T @ w
        return np.sum((v - x)**2)
    cons = [{'type': 'eq', 'fun': lambda w: w.sum() - 1}]
    bnds = [(0, 1)] * K
    res = minimize(obj, x0=np.ones(K)/K, method='SLSQP', constraints=cons, bounds=bnds, tol=1e-14)
    return vertices.T @ res.x

def make_grad_f0(beta, eta, mu, M):
    P_vertices = (M @ e.T).T
    tilde_P = lam * P_vertices

    def grad_f0(x):
        return mu * x + (L - mu) * project_to_polygon(x, tilde_P)
    def f0(x):
        p = project_to_polygon(x, tilde_P)
        return (L/2) * x @ x - (L - mu)/2 * np.sum((x - p)**2)
    return grad_f0, f0, tilde_P

def run_shb(beta, eta, mu, T_max, init_type='cycling'):
    M = ((1 + beta - mu*eta)*I2 - R_pos - beta*R_neg) / ((L - mu)*eta)
    grad_f0, f0, tilde_P = make_grad_f0(beta, eta, mu, M)
    if init_type == 'cycling':
        x_minus1 = lam * e[K-1]
        x_0 = lam * e[0]
    elif init_type == 'zero_momentum':
        x_minus1 = lam * e[0]
        x_0 = lam * e[0]
    elif init_type == 'zero':
        x_minus1 = np.zeros(2)
        x_0 = np.zeros(2)
    xs = [x_minus1, x_0]
    fs = [f0(x_minus1), f0(x_0)]
    for t in range(T_max):
        g = grad_f0(xs[-1])
        new = xs[-1] - eta * g + beta * (xs[-1] - xs[-2])
        xs.append(new)
        fs.append(f0(new))
    return np.array(xs), np.array(fs)

# Test cases
cases = [
    {'beta': 0.5, 'eta': 3.0, 'mu': 0.25, 'name': '(β=0.5, ηL=3, κ=0.25)'},
    {'beta': 0.9, 'eta': 3.5, 'mu': 0.45, 'name': '(β=0.9, ηL=3.5, κ=0.45)'},
    {'beta': 0.7, 'eta': 2.9, 'mu': 0.336, 'name': '(β=0.7, ηL=2.9, κ=0.336)'},
]

T_max = 200
for case in cases:
    beta, eta, mu = case['beta'], case['eta'], case['mu']
    print(f"\n=== {case['name']} ===")
    print(f"  Cycling LB target μD²/4 = {mu*D**2/4:.6f}")

    # Cycling init
    xs_c, fs_c = run_shb(beta, eta, mu, T_max, init_type='cycling')
    # Zero-momentum init
    xs_z, fs_z = run_shb(beta, eta, mu, T_max, init_type='zero_momentum')

    # OP-2 per-T target: (kappa/4) L D^2 / T
    kappa = mu / L
    print(f"  per-T LB target c(β,η)·LD²/T = ({kappa/4:.4f})·LD²/T")

    # For each T from 1 to T_max, check ratio
    bad_T = []
    for T in range(1, T_max+1):
        target = (kappa/4) * L * D**2 / T
        f_c = fs_c[T+1]   # x_T is xs[T+1] because xs starts with x_{-1}, x_0
        f_z = fs_z[T+1]
        if f_z < target:
            bad_T.append((T, f_z, target, f_c))

    print(f"  Cycling init: f_0(x_T) at T=1,2,5,10,50,100,200:")
    for T in [1,2,5,10,50,100,200]:
        if T+1 < len(fs_c):
            tgt = (kappa/4) * L * D**2 / T
            print(f"    T={T:>3}: f_0(x_T) = {fs_c[T+1]:.6e},  target = {tgt:.6e},  ratio = {fs_c[T+1]/tgt:.4f}")

    print(f"  Zero-momentum init: f_0(x_T) at T=1,2,5,10,50,100,200:")
    for T in [1,2,5,10,50,100,200]:
        if T+1 < len(fs_z):
            tgt = (kappa/4) * L * D**2 / T
            print(f"    T={T:>3}: f_0(x_T) = {fs_z[T+1]:.6e},  target = {tgt:.6e},  ratio = {fs_z[T+1]/tgt:.4f}")

    if bad_T:
        print(f"  ** Bad T (f_0(x_T) < target) under zero-momentum init: {len(bad_T)} of {T_max}")
        for T, fz, tgt, fc in bad_T[:5]:
            print(f"     T={T}: f_0={fz:.4e}, target={tgt:.4e}")
    else:
        print(f"  ✓ Zero-momentum init satisfies LB for ALL T in [1, {T_max}]")
