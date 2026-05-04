"""
Section E: Dynamical interpretation. Does NAG accelerate on f_0?

We compare:
  - Polyak HB: f_0(x_T) = mu D^2/4 = 0.25 * 0.25 / 4 ... well, f_0(lam e_t) computed
  - NAG period-2 / fixed point: avg f_0 (Cesaro)
  - AC-SA bound: O(LD^2/T^2)

If NAG's f-history Cesaro avg is bounded BELOW by a constant > 0 over T -> infinity,
then NAG does NOT accelerate either. Period structure shows this explicitly.

We also check the running min and the best-iterate min.
"""

import numpy as np
from section_C_nag_polytope import R, project_onto_polygon, order_ccw, construct_M_HB


def study_NAG_dynamics(beta, eta_L, mu_L, K, T_list=[500, 2000, 10000], D=1.0):
    L = 1.0; mu = mu_L * L; eta = eta_L / L; lam = D / np.sqrt(2)
    M_HB = construct_M_HB(beta, eta_L, mu_L, K)
    theta = 2 * np.pi / K
    e0 = np.array([1.0, 0.0])
    e = [np.linalg.matrix_power(R(theta), t) @ e0 for t in range(K)]
    V = [lam * (M_HB @ et) for et in e]
    V_ccw = order_ccw(V)
    def grad(x):
        Px = project_onto_polygon(x, V_ccw)
        return mu * x + (L - mu) * Px
    def fval(x):
        Px = project_onto_polygon(x, V_ccw)
        return 0.5 * L * np.dot(x, x) - 0.5 * (L - mu) * np.dot(x - Px, x - Px)

    x_prev = lam * e[(K - 1) % K]
    x_curr = lam * e[0]

    f_hist = [fval(x_curr)]
    x_avg = x_curr.copy()
    f_best = f_hist[0]
    f_history_full = []

    Tmax = max(T_list)
    for t in range(Tmax):
        y_t = x_curr + beta * (x_curr - x_prev)
        x_next = y_t - eta * grad(y_t)
        x_prev, x_curr = x_curr, x_next
        f_hist.append(fval(x_curr))
        f_best = min(f_best, f_hist[-1])
        if np.linalg.norm(x_curr) > 1e30:
            f_history_full = f_hist
            break
    f_history_full = f_hist

    print(f"\n(beta={beta}, eta*L={eta_L}, mu/L={mu_L}):")
    print(f"  Polyak f_0 ≡ μD²/4 = {mu * D**2 / 4:.6f} (constant, by Lemma 2.6)")

    for T in T_list:
        if T < len(f_history_full):
            f_T = f_history_full[T]
            f_min_to_T = min(f_history_full[:T+1])
            f_avg_to_T = np.mean(f_history_full[:T+1])
            f_cesaro_x = ...  # average of x_t, then f at the average — TODO
            ratio_AC = f_min_to_T * T**2 / (L * D**2)
            print(f"  T={T:5d}: f(x_T)={f_T:.4e}, "
                  f"min_t<=T f(x_t)={f_min_to_T:.4e}, "
                  f"avg f={f_avg_to_T:.4e}, "
                  f"min*Tsq/(LDsq)={ratio_AC:.3e}")
        else:
            print(f"  T={T}: (orbit diverged earlier)")

    return f_history_full


if __name__ == "__main__":
    print("Section E — Does NAG accelerate on f_0?")
    print("=" * 75)
    print("AC-SA bound: f(x_T) - f* ≤ c * L D²/T²; we test if min_t f(x_t) decays.")
    print("Polyak HB has f_0(x_t) ≡ μD²/4 ≡ const, so T*(f-f*)/LD² grows linearly.")
    cases = [
        (0.5, 3.0, 0.250, 3),
        (0.7, 2.9, 0.337, 3),
        (0.9, 3.5, 0.398, 3),
    ]
    for beta, eta_L, mu_L, K in cases:
        study_NAG_dynamics(beta, eta_L, mu_L, K)

    # Special: at the NAG-cycling case, what does f_0^Nes do?
    # Re-run a NAG-feasible point and report f^Nes
    print("\n" + "=" * 75)
    print("At a NAG-cycling parameter (mu/L=0.25, K=3): what is f^Nes(x_T)?")
    print("=" * 75)
    from section_C_nag_polytope import construct_M_Nes
    beta, eta_L, mu_L, K = 0.85, 2.4, 0.25, 3
    L = 1.0; mu = mu_L; eta = eta_L; D = 1.0; lam = D/np.sqrt(2)
    M_Nes = construct_M_Nes(beta, eta, mu, L, K)
    theta = 2*np.pi/K
    e0 = np.array([1.0,0.0])
    e = [np.linalg.matrix_power(R(theta), t) @ e0 for t in range(K)]
    u = [(1+beta)*e[t] - beta*e[(t-1)%K] for t in range(K)]
    V = [lam*(M_Nes @ ut) for ut in u]
    V_ccw = order_ccw(V)
    # Test KKT
    err_KKT = max(np.linalg.norm(project_onto_polygon(lam*ut, V_ccw) - lam*(M_Nes @ ut))
                  for ut in u)
    print(f"  (beta={beta}, eta*L={eta_L}): KKT err = {err_KKT:.3e}")
    if err_KKT > 1e-8:
        print("  WARNING: not actually NAG-feasible, picking from earlier scan")
        from section_C_explore import scan_F
        F_HB, F_Nes = scan_F(K=3, mu_L=0.25, n=60)
        beta, eta_L = F_Nes[len(F_Nes)//2]
        print(f"  Switched to: beta={beta:.4f}, eta*L={eta_L:.4f}")
        M_Nes = construct_M_Nes(beta, eta_L, mu_L, 1.0, K)
        u = [(1+beta)*e[t] - beta*e[(t-1)%K] for t in range(K)]
        V = [lam*(M_Nes @ ut) for ut in u]
        V_ccw = order_ccw(V)

    def grad(x):
        Px = project_onto_polygon(x, V_ccw)
        return mu * x + (L - mu) * Px
    def fval(x):
        Px = project_onto_polygon(x, V_ccw)
        return 0.5 * L * np.dot(x, x) - 0.5 * (L - mu) * np.dot(x - Px, x - Px)

    eta = eta_L  # L=1
    x_prev = lam * e[(K-1)%K]
    x_curr = lam * e[0]
    fh = [fval(x_curr)]
    for t in range(2000):
        y_t = x_curr + beta * (x_curr - x_prev)
        x_next = y_t - eta * grad(y_t)
        x_prev, x_curr = x_curr, x_next
        fh.append(fval(x_curr))
    print(f"  T=2000 on NAG-cycling instance: |x_T|={np.linalg.norm(x_curr):.6f}, "
          f"f^Nes(x_T)={fh[-1]:.6f}")
    print(f"  μD²/4 = {mu/4:.6f}")
    print(f"  T * f / (LD²) = {2000 * fh[-1]:.3e} (Polyak's lower-bound LHS)")
