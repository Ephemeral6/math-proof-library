"""
Verify the descent inequality (★) numerically:

  E_t[A r_t - B r_{t-1} - C(f(z_t) - inf f)] <= ||w_t - z_t||^2 - E_t||w_{t+1}-z_t||^2 + V

where for SHB with COV w_t = y_t + a(y_t - y_{t-1}), a = β/(1-β), η' = η/(1-β):
  A = 2η'[(1+a) - η'L(1+ε)]
  B = 2η' a
  C = 2η'
  V = η'² (1+1/ε) σ²

We sample many trajectories and many random z_t (F_t-measurable) and verify
  LHS_avg <= RHS_avg  (with margin)

The strong form: LHS - RHS should be ≤ 0 in expectation.
"""
import numpy as np
import json

rng = np.random.default_rng(7)

def make_problem(d=10, m=100):
    A = rng.standard_normal((m, d)) / np.sqrt(d)
    x_true = rng.standard_normal(d)
    b = A @ x_true + rng.standard_normal(m)
    xstar = np.linalg.lstsq(A, b, rcond=None)[0]
    finf = 0.5 * np.mean((A @ xstar - b) ** 2)
    Lmax = float(np.max(np.sum(A * A, axis=1)))
    res = A @ xstar - b
    sigma2 = float(np.mean((np.sum(A * A, axis=1)) * res ** 2))
    return dict(A=A, b=b, xstar=xstar, finf=finf, Lmax=Lmax, sigma2=sigma2, d=d, m=m)

def fval(prob, x):
    return 0.5 * np.mean((prob['A'] @ x - prob['b']) ** 2)

def grad_full(prob, x):
    return prob['A'].T @ (prob['A'] @ x - prob['b']) / prob['m']

def grad_stoch(prob, x, i):
    ai = prob['A'][i]; bi = prob['b'][i]
    return ai * (np.dot(ai, x) - bi)

def main():
    prob = make_problem(d=10, m=100)
    L = prob['Lmax']
    sigma2 = prob['sigma2']
    finf = prob['finf']
    print(f"L_max={L:.4f}, sigma^2={sigma2:.4f}, finf={finf:.4f}")

    # Test parameters
    beta = 0.5
    eta = 0.01
    a = beta / (1 - beta)
    eta_p = eta / (1 - beta)
    eps = (1 - eta_p * L) / (1 + eta_p * L)  # Garrigos optimal
    if eps <= 0:
        eps = 0.5
    print(f"beta={beta}, eta={eta}, a={a:.4f}, eta'={eta_p:.4f}, eps={eps:.4f}, eta'L(1+eps)={eta_p*L*(1+eps):.4f}")

    A = 2 * eta_p * ((1+a) - eta_p * L * (1+eps))
    B = 2 * eta_p * a
    C = 2 * eta_p
    V = eta_p**2 * (1 + 1/eps) * sigma2
    print(f"A={A:.5f}, B={B:.5f}, C={C:.5f}, V={V:.5f}")
    print(f"A-B={A-B:.5f}, A-B-C+c''={A-B-C+2*eta_p**2*L*(1+eps):.5e} (should be 0)")
    print()

    # Run trajectories. For each trajectory, sample t random "current state" instances,
    # then sample z_t random F_t-measurable, compute both sides and check.
    n_trajectories = 80
    T_max = 30
    n_z = 5  # z_t samples per state

    diffs = []
    for traj in range(n_trajectories):
        y_prev = rng.standard_normal(prob['d']) * 0.5
        y = y_prev.copy()  # y_{-1} = y_0 conv
        for t in range(T_max):
            # State (y_prev = y_{t-1}, y = y_t)
            w = y + a * (y - y_prev)
            r_t = fval(prob, y) - finf
            r_tm1 = fval(prob, y_prev) - finf
            # Sample n_z random z_t
            for _ in range(n_z):
                # F_t-measurable z_t: use a random combination of y_prev, y, x*
                u = rng.dirichlet(np.ones(3))
                z_t = u[0] * y + u[1] * y_prev + u[2] * prob['xstar']
                # E_t [...] : average over 32 stochastic gradient samples
                n_inner = 32
                cur_ws = np.empty(n_inner)
                for k in range(n_inner):
                    i = rng.integers(0, prob['m'])
                    g = grad_stoch(prob, y, i)
                    w_next = w - eta_p * g
                    cur_ws[k] = np.linalg.norm(w_next - z_t)**2
                Ew_next_sq = float(np.mean(cur_ws))
                Ew_now_sq = np.linalg.norm(w - z_t)**2

                f_z_t = fval(prob, z_t) - finf
                LHS = A * r_t - B * r_tm1 - C * f_z_t
                RHS = Ew_now_sq - Ew_next_sq + V
                diffs.append(LHS - RHS)

            # Step (advance the trajectory)
            i = rng.integers(0, prob['m'])
            g = grad_stoch(prob, y, i)
            y_new = y - eta * g + beta * (y - y_prev)
            y_prev = y; y = y_new

    diffs = np.array(diffs)
    print(f"\nVerified inequality on {len(diffs)} samples.")
    print(f"  LHS - RHS:")
    print(f"    mean = {np.mean(diffs):.6e}  (should be <= 0)")
    print(f"    median = {np.median(diffs):.6e}")
    print(f"    max = {np.max(diffs):.6e}")
    print(f"    std  = {np.std(diffs):.6e}")
    pos_frac = float(np.mean(diffs > 0))
    print(f"  Fraction with LHS > RHS: {pos_frac*100:.2f}%")
    # If E[LHS - RHS] <= 0, ratio of mean to std should be ≤ 0
    n = len(diffs)
    sem = np.std(diffs) / np.sqrt(n)
    z_score = np.mean(diffs) / sem if sem > 0 else 0
    print(f"  z-score (mean/sem): {z_score:.3f}")
    if np.mean(diffs) > 2 * sem:
        print("  *** WARNING: LHS - RHS appears positive in expectation. Inequality may not hold. ***")
    else:
        print("  Result: E[LHS] <= E[RHS] holds (within MC error). ★ verified.")

    # Three-way verification: try multiple (η, β, ε) combos
    print("\n--- Multi-parameter sweep ---")
    parms = [
        (0.3, 0.005),
        (0.7, 0.005),
        (0.5, 0.02),
        (0.9, 0.001),
    ]
    for beta, eta in parms:
        a = beta / (1 - beta)
        eta_p = eta / (1 - beta)
        eps_loc = (1 - eta_p * L) / (1 + eta_p * L)
        if eps_loc <= 0: eps_loc = 0.5
        A = 2 * eta_p * ((1+a) - eta_p * L * (1+eps_loc))
        B = 2 * eta_p * a
        C = 2 * eta_p
        V = eta_p**2 * (1 + 1/eps_loc) * sigma2
        diffs2 = []
        for traj in range(40):
            y_prev = rng.standard_normal(prob['d']) * 0.5
            y = y_prev.copy()
            for t in range(20):
                w = y + a * (y - y_prev)
                r_t = fval(prob, y) - finf
                r_tm1 = fval(prob, y_prev) - finf
                for _ in range(3):
                    u = rng.dirichlet(np.ones(3))
                    z_t = u[0] * y + u[1] * y_prev + u[2] * prob['xstar']
                    n_inner = 24
                    cur_ws = np.empty(n_inner)
                    for k in range(n_inner):
                        i = rng.integers(0, prob['m'])
                        g = grad_stoch(prob, y, i)
                        w_next = w - eta_p * g
                        cur_ws[k] = np.linalg.norm(w_next - z_t)**2
                    Ew_next_sq = float(np.mean(cur_ws))
                    Ew_now_sq = np.linalg.norm(w - z_t)**2
                    f_z_t = fval(prob, z_t) - finf
                    LHS = A * r_t - B * r_tm1 - C * f_z_t
                    RHS = Ew_now_sq - Ew_next_sq + V
                    diffs2.append(LHS - RHS)
                i = rng.integers(0, prob['m'])
                g = grad_stoch(prob, y, i)
                y_new = y - eta * g + beta * (y - y_prev)
                y_prev = y; y = y_new
        diffs2 = np.array(diffs2)
        print(f"  beta={beta:.2f} eta={eta:.4f}: LHS-RHS mean={np.mean(diffs2):.4e}, max={np.max(diffs2):.4e}, frac>0={np.mean(diffs2>0)*100:.1f}%")

if __name__ == '__main__':
    main()
