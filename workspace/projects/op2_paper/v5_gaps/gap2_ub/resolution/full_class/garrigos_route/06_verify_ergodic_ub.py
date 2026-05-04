"""
Verify the rigorous ERGODIC last-iterate UB derived from Garrigos descent (★).

Theorem (Ergodic UB):
    min_{0<=t<=T-2} E[f(y_t) - inf f] <= (D^2 + B*r_0 + T*V') / ((A-B)*(T-1))

with horizon-tuned eta = (1-beta)/(C0 * sqrt(L*T)), C0 >= 2.
This gives O((LD^2 + sigma^2) / ((1-beta) sqrt(LT))).

We compare:
  (1) Empirical min_t E[r_t] from MC
  (2) Predicted UB
  (3) Standard SGD-style UB at beta=0 (sanity)
"""

import numpy as np
import sys
import json

rng = np.random.default_rng(20260429)

# Problem: f(x) = (1/m) sum_i Huber_delta(<a_i, x> - b_i), L-smooth via Huber smoothness
def make_problem(d=20, m=200, delta=0.1, seed=42):
    rng_p = np.random.default_rng(seed)
    A = rng_p.standard_normal((m, d)) / np.sqrt(d)
    x_true = rng_p.standard_normal(d)
    b = A @ x_true + 0.05 * rng_p.standard_normal(m)
    L_max = float(np.max(np.linalg.eigvalsh(A.T @ A)) / m)
    return {"A": A, "b": b, "delta": delta, "L_max": L_max,
            "x_star_approx": x_true}

def huber_grad(A, b, x, delta):
    r = A @ x - b
    s = np.where(np.abs(r) <= delta, r, delta * np.sign(r))
    return (A.T @ s) / A.shape[0]

def huber_loss(A, b, x, delta):
    r = A @ x - b
    return np.mean(np.where(np.abs(r) <= delta, 0.5 * r * r, delta * (np.abs(r) - 0.5 * delta)))

def stochastic_grad(A, b, x, delta, batch=10):
    idx = rng.integers(0, A.shape[0], size=batch)
    r = A[idx] @ x - b[idx]
    s = np.where(np.abs(r) <= delta, r, delta * np.sign(r))
    return A[idx].T @ s / batch

def shb_run(prob, beta, eta, T, n_traj=100, seed=0):
    """Returns array (T, n_traj) of f(y_t) - inf f."""
    A, b, delta = prob["A"], prob["b"], prob["delta"]
    d = A.shape[1]
    f_inf_approx = huber_loss(A, b, prob["x_star_approx"], delta)
    rng_run = np.random.default_rng(seed)

    y_prev = rng_run.standard_normal((n_traj, d))
    y_curr = y_prev.copy()

    r_traj = np.zeros((T, n_traj))
    for t in range(T):
        gb = np.array([stochastic_grad(A, b, y_curr[k], delta, batch=10) for k in range(n_traj)])
        y_next = y_curr - eta * gb + beta * (y_curr - y_prev)
        for k in range(n_traj):
            r_traj[t, k] = huber_loss(A, b, y_curr[k], delta) - f_inf_approx
        y_prev = y_curr
        y_curr = y_next
    return r_traj

def predicted_ergodic_ub(D2, r_0, sigma2, L, T, beta, C0=2.0):
    """Predicted ergodic UB from Theorem (Garrigos route §1.2)."""
    eta = (1 - beta) / (C0 * np.sqrt(L * T))
    eta_p = eta / (1 - beta)
    a = beta / (1 - beta)
    # Choose epsilon = (1 - eta_p L) / (1 + eta_p L) so eta_p L (1+eps) = 2 eta_p L / (1 + eta_p L)
    eta_pL = eta_p * L
    eps = (1 - eta_pL) / (1 + eta_pL) if eta_pL < 1 else 0.5
    eta_pL_one_plus_eps = eta_pL * (1 + eps)
    A_coef = 2 * eta_p * ((1 + a) - eta_pL_one_plus_eps)
    B_coef = 2 * eta_p * a
    V_prime = eta_p**2 * (1 + 1/eps) * sigma2
    A_minus_B = A_coef - B_coef

    ub = (D2 + B_coef * r_0 + T * V_prime) / (A_minus_B * max(T - 1, 1))
    return {"ub": ub, "eta": eta, "A": A_coef, "B": B_coef, "V_prime": V_prime}


def main():
    prob = make_problem(d=20, m=200, delta=0.1)
    A, b, delta = prob["A"], prob["b"], prob["delta"]
    L = prob["L_max"]

    # Estimate sigma^2 = E ||grad f_i(x*)||^2 (variance of single sample at x_star)
    n_var = 5000
    grads_at_star = []
    for _ in range(n_var):
        idx = rng.integers(0, A.shape[0])
        r = A[idx] @ prob["x_star_approx"] - b[idx]
        s = r if np.abs(r) <= delta else delta * np.sign(r)
        grads_at_star.append(A[idx] * s)
    sigma2 = float(np.mean([np.linalg.norm(g)**2 for g in grads_at_star]))

    print(f"L_max={L:.4f}, sigma^2={sigma2:.4f}")

    results = []
    for beta in [0.0, 0.5, 0.9]:
        for T in [100, 400, 1600]:
            ub_data = predicted_ergodic_ub(D2=20.0, r_0=0.5, sigma2=sigma2,
                                           L=L, T=T, beta=beta)
            r_traj = shb_run(prob, beta=beta, eta=ub_data["eta"], T=T, n_traj=120,
                            seed=int(1000 * beta) + T)
            E_rt_per_t = r_traj.mean(axis=1)  # E[r_t] for each t
            E_rt_sem = r_traj.std(axis=1, ddof=1) / np.sqrt(r_traj.shape[1])

            min_E_rt = float(np.min(E_rt_per_t))
            argmin_t = int(np.argmin(E_rt_per_t))
            E_r_T_minus_1 = float(E_rt_per_t[-1])
            sem_T_minus_1 = float(E_rt_sem[-1])

            results.append({
                "beta": beta, "T": T, "eta": ub_data["eta"],
                "predicted_ergodic_ub": ub_data["ub"],
                "min_E_rt": min_E_rt, "argmin_t": argmin_t,
                "E_r_T_minus_1": E_r_T_minus_1, "sem_T_minus_1": sem_T_minus_1,
                "ratio_min_to_ub": min_E_rt / ub_data["ub"],
                "ratio_last_to_ub": E_r_T_minus_1 / ub_data["ub"],
            })

            print(f"  beta={beta:.1f} T={T:5d} eta={ub_data['eta']:.5f}: "
                  f"min_t E[r_t]={min_E_rt:.4f} (t*={argmin_t}), "
                  f"E[r_{{T-1}}]={E_r_T_minus_1:.4f}±{sem_T_minus_1:.4f}, "
                  f"UB={ub_data['ub']:.4f}, "
                  f"min/UB={min_E_rt/ub_data['ub']:.3f}, "
                  f"last/UB={E_r_T_minus_1/ub_data['ub']:.3f}")

    # Sanity: as T grows, both min and last should decay; min must always be <= UB.
    print("\n=== Verification ===")
    all_pass = True
    for r in results:
        if r["ratio_min_to_ub"] > 1.0:
            print(f"  ❌ FAIL: beta={r['beta']}, T={r['T']}: min/UB={r['ratio_min_to_ub']:.3f} > 1")
            all_pass = False

    if all_pass:
        print("  ✅ All min_t E[r_t] <= predicted ergodic UB across all (beta, T) settings.")

    # Last-iterate scaling check (separate):
    print("\n=== Empirical last-iterate scaling ===")
    for beta in [0.0, 0.5, 0.9]:
        rows = [r for r in results if r["beta"] == beta]
        Ts = np.array([r["T"] for r in rows])
        last = np.array([r["E_r_T_minus_1"] for r in rows])
        slope = np.polyfit(np.log(Ts), np.log(last), 1)[0]
        print(f"  beta={beta:.1f}: log-log slope of E[r_{{T-1}}] vs T = {slope:.3f} (predict -0.5 for last-iterate $T^{{-1/2}}$ conjecture)")

    with open("06_verify_ergodic_ub_results.json", "w") as f:
        json.dump({"sigma2": sigma2, "L": L, "results": results}, f, indent=2)

    return all_pass

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
