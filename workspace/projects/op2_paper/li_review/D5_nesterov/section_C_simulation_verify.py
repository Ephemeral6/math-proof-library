"""
Section C verification: confirm the NAG cycling identity by running NAG with
cycling-init on f^Nes for several (beta, eta*L, mu/L, K), and verify
|x_t| = lambda exactly for many T.

Also: characterize F^Nes more precisely by varying K and mu/L.
"""

import numpy as np
from section_C_nag_polytope import R, project_onto_polygon, order_ccw, construct_M_Nes


def fNes_setup(beta, eta_L, mu_L, K, D=1.0):
    L = 1.0; mu = mu_L * L; eta = eta_L / L; lam = D / np.sqrt(2)
    M_Nes = construct_M_Nes(beta, eta, mu, L, K)
    theta = 2 * np.pi / K
    e0 = np.array([1.0, 0.0])
    e = [np.linalg.matrix_power(R(theta), t) @ e0 for t in range(K)]
    u = [(1+beta)*e[t] - beta*e[(t-1)%K] for t in range(K)]
    V = [lam * (M_Nes @ ut) for ut in u]
    V_ccw = order_ccw(V)
    return e, u, V_ccw, lam, mu, eta, L


def run_NAG_on_fNes(beta, eta_L, mu_L, K, T):
    e, u, V_ccw, lam, mu, eta, L = fNes_setup(beta, eta_L, mu_L, K)
    def grad(x):
        return mu*x + (L-mu) * project_onto_polygon(x, V_ccw)
    def fval(x):
        Px = project_onto_polygon(x, V_ccw)
        return 0.5*L*np.dot(x,x) - 0.5*(L-mu)*np.dot(x-Px, x-Px)

    x_prev = lam * e[(K-1)%K]
    x_curr = lam * e[0]
    norms = [np.linalg.norm(x_curr)]
    f_hist = [fval(x_curr)]
    deviations = [0.0]
    for t in range(T):
        y_t = x_curr + beta * (x_curr - x_prev)
        x_next = y_t - eta * grad(y_t)
        x_prev, x_curr = x_curr, x_next
        norms.append(np.linalg.norm(x_curr))
        f_hist.append(fval(x_curr))
        # check whether x_curr matches lam * e[(t+1)%K]
        target = lam * e[(t+1) % K]
        deviations.append(np.linalg.norm(x_curr - target))
    return norms, f_hist, deviations, x_curr


def kkt_check_nesterov_quick(beta, eta_L, mu_L, K):
    M_Nes = construct_M_Nes(beta, eta_L/1.0, mu_L*1.0, 1.0, K)
    theta = 2*np.pi/K
    e0 = np.array([1.0,0.0])
    e = [np.linalg.matrix_power(R(theta), t) @ e0 for t in range(K)]
    u = [(1+beta)*e[t] - beta*e[(t-1)%K] for t in range(K)]
    V = [M_Nes @ ut for ut in u]
    V_ccw = order_ccw(V)
    errs = [np.linalg.norm(project_onto_polygon(ut, V_ccw) - vt) for ut, vt in zip(u, V)]
    return max(errs) < 1e-9, max(errs)


if __name__ == "__main__":
    print("Section C verification — confirm NAG cycling identity holds at machine precision")
    print("=" * 75)

    # Pick several NAG-feasible points, verify identity at T=2000.
    nag_test = [
        (0.85, 2.4, 0.25, 3),
        (0.78, 2.3, 0.25, 3),
        (0.92, 2.7, 0.25, 3),
        (0.85, 2.5, 0.25, 3),
        # try other K
        (0.85, 2.0, 0.20, 4),  # may or may not be feasible
        (0.85, 1.8, 0.20, 5),
    ]

    for beta, eta_L, mu_L, K in nag_test:
        ok, err = kkt_check_nesterov_quick(beta, eta_L, mu_L, K)
        print(f"\n(beta={beta}, eta*L={eta_L}, mu/L={mu_L}, K={K}):")
        print(f"  KKT check: feasible={ok}, max err = {err:.3e}")
        if ok:
            for T in [100, 2000, 10000]:
                norms, fhist, devs, xT = run_NAG_on_fNes(beta, eta_L, mu_L, K, T)
                print(f"  T={T}: |x_T|={np.linalg.norm(xT):.10f} "
                      f"(target {1/np.sqrt(2):.10f}), "
                      f"max ||x_t - lam*e[t mod K]|| = {max(devs):.3e}, "
                      f"f(x_T)={fhist[-1]:.6f}")

    # Final: characterize the exact F^Nes for K=3 over a fine grid
    print("\n" + "=" * 75)
    print("F^Nes region characterization for K=3 (fine grid)")
    print("=" * 75)
    for mu_L in [0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40]:
        feas = []
        for beta in np.linspace(0.05, 0.99, 100):
            for eta_L in np.linspace(0.1, 4.0, 100):
                ok, _ = kkt_check_nesterov_quick(beta, eta_L, mu_L, 3)
                if ok:
                    feas.append((beta, eta_L))
        if feas:
            betas = sorted(set(b for b, e in feas))
            beta_min = min(betas); beta_max = max(betas)
            etas = sorted(set(e for b, e in feas))
            eta_min = min(etas); eta_max = max(etas)
            print(f"  mu/L={mu_L}: |F^Nes|={len(feas)}, "
                  f"beta in [{beta_min:.3f}, {beta_max:.3f}], "
                  f"eta*L in [{eta_min:.3f}, {eta_max:.3f}]")
        else:
            print(f"  mu/L={mu_L}: F^Nes is empty in scan range")
