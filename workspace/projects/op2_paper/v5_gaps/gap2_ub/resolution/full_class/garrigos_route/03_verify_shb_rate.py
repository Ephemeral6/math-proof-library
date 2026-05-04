"""
Numerical verification: does fixed-β SHB on L-smooth convex (no SC) achieve
last-iterate rate ~ 1/sqrt(T) under Garrigos's Assumption 2.2 (sigma^2 finite at
the optimum, no uniform variance bound)?

Test problem: f(x) = (1/2) E_i (a_i^T x - b_i)^2 = (1/2) ||A x - b||^2 / m  (mean over i).
Each f_i(x) = (1/2)(a_i^T x - b_i)^2 is convex L_i-smooth where L_i = ||a_i||^2.
Stochastic gradient: pick random i, return a_i (a_i^T x - b_i).
At the optimum x* (least squares solution):
  E_i ||grad f_i(x*)||^2 = (1/m) sum_i ||a_i (a_i^T x* - b_i)||^2 = sigma^2  (finite, NOT zero in general).

We sweep T over a wide range and measure E[f(y_T) - inf f] via Monte Carlo.

If the route is sound, we expect log10(gap) ~ -0.5 log10(T) + const.
"""
import numpy as np
import json, sys, time

rng = np.random.default_rng(42)

def make_problem(d=20, m=200, noise_lvl=1.0):
    A = rng.standard_normal((m, d)) / np.sqrt(d)
    # Random target with noise -> ensures sigma^2 > 0 at optimum.
    x_true = rng.standard_normal(d)
    b = A @ x_true + noise_lvl * rng.standard_normal(m)
    # x* = least squares
    xstar = np.linalg.lstsq(A, b, rcond=None)[0]
    finf = 0.5 * np.mean((A @ xstar - b) ** 2)
    # L_max := max_i ||a_i||^2 (smoothness of f_i)
    Lmax = float(np.max(np.sum(A * A, axis=1)))
    # L_avg := smoothness of f (= max eigval of A^T A / m)
    L = float(np.linalg.eigvalsh(A.T @ A / m)[-1])
    # sigma^2 = E_i ||grad f_i(x*)||^2 = mean over i of ||a_i||^2 (a_i^T x* - b_i)^2
    res = A @ xstar - b
    grad_norms = (np.sum(A * A, axis=1)) * (res ** 2)
    sigma2 = float(np.mean(grad_norms))
    return dict(A=A, b=b, xstar=xstar, finf=finf, L=L, Lmax=Lmax, sigma2=sigma2, d=d, m=m)

def f_value(prob, x):
    return 0.5 * np.mean((prob['A'] @ x - prob['b']) ** 2)

def run_shb(prob, T, beta, eta, x0=None, n_trajectories=128, seed=0):
    """Run SHB with fixed beta, stepsize eta, for T iterations. Return mean f(y_T) - finf."""
    A = prob['A']; b = prob['b']; m = prob['m']
    if x0 is None:
        x0 = np.zeros(prob['d'])
    rng_local = np.random.default_rng(seed)
    gaps_T = np.empty(n_trajectories)
    for traj in range(n_trajectories):
        y_prev = x0.copy()
        y = x0.copy()
        for t in range(T):
            # Pick random i
            i = rng_local.integers(0, m)
            ai = A[i]
            bi = b[i]
            # f_i gradient at y: a_i (a_i^T y - b_i)
            g = ai * (np.dot(ai, y) - bi)
            y_new = y - eta * g + beta * (y - y_prev)
            y_prev = y
            y = y_new
        gaps_T[traj] = f_value(prob, y) - prob['finf']
    return gaps_T

def main():
    prob = make_problem(d=20, m=200, noise_lvl=1.0)
    print(f"problem: d={prob['d']}, m={prob['m']}")
    print(f"  L (avg)={prob['L']:.4f}, Lmax={prob['Lmax']:.4f}, sigma^2={prob['sigma2']:.4f}, finf={prob['finf']:.4f}")

    # Use Lmax for stepsize (per-sample smoothness bound).
    Lref = prob['Lmax']

    Ts = [50, 100, 200, 400, 800, 1600, 3200]
    betas = [0.0, 0.5, 0.9]
    n_trajectories = 64

    results = {}
    for beta in betas:
        per_beta = []
        for T in Ts:
            # stepsize: η = (1-β)/(C sqrt(Lref T)) with C=2
            C = 2.0
            eta = (1 - beta) / (C * np.sqrt(Lref * T))
            t0 = time.time()
            gaps = run_shb(prob, T, beta, eta,
                           x0=np.zeros(prob['d']),
                           n_trajectories=n_trajectories,
                           seed=int(1000*beta + T))
            mean_gap = float(np.mean(gaps))
            stderr = float(np.std(gaps) / np.sqrt(len(gaps)))
            per_beta.append((T, mean_gap, stderr, time.time() - t0))
            print(f"  beta={beta:4.2f}  T={T:5d}  η={eta:.5f}  E[r_T]={mean_gap:.5f} ± {stderr:.5f}  ({time.time()-t0:.1f}s)")
        results[beta] = per_beta

    # Fit log-log slope: log(gap) vs log(T)
    print("\nLog-log slopes (excluding smallest T):")
    for beta, vals in results.items():
        Ts_arr = np.array([v[0] for v in vals])
        gaps_arr = np.array([v[1] for v in vals])
        # Use last 5 points for the slope
        log_T = np.log(Ts_arr[-5:])
        log_gap = np.log(gaps_arr[-5:])
        slope, intercept = np.polyfit(log_T, log_gap, 1)
        # Predicted: slope = -0.5
        print(f"  beta={beta}: slope={slope:.4f}, intercept={intercept:.4f}")
        print(f"          (predict slope=-0.5 if E[r_T]~T^(-1/2))")

    with open('03_verify_shb_rate_results.json', 'w') as fh:
        json.dump({str(k): [list(map(float, v)) for v in vs] for k, vs in results.items()}, fh, indent=2)
    print("\nSaved JSON to 03_verify_shb_rate_results.json")

if __name__ == '__main__':
    main()
