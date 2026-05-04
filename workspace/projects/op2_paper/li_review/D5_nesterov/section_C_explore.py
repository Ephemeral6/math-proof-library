"""
Section C continued: Explore Nesterov cycling feasibility region in detail.

Goals:
1. Map out F^Nes (NAG-cycling region) for K=3 and various mu/L.
2. Compare with F^Polyak.
3. Verify the cycling identity numerically by running NAG with cycling-init.
"""

import numpy as np
from section_C_nag_polytope import (
    R, project_onto_polygon, order_ccw, construct_M_Nes, construct_M_HB,
    test_nesterov_cycling
)


def kkt_check_polyak(beta, eta_L, mu_L, K):
    """Check Polyak feasibility = projection identity P_C(e_t) = M e_t."""
    M = construct_M_HB(beta, eta_L, mu_L, K)
    theta = 2 * np.pi / K
    e0 = np.array([1.0, 0.0])
    e = [np.linalg.matrix_power(R(theta), t) @ e0 for t in range(K)]
    V = [M @ et for et in e]
    V_ccw = order_ccw(V)
    errs = [np.linalg.norm(project_onto_polygon(et, V_ccw) - vt)
            for et, vt in zip(e, V)]
    return max(errs) < 1e-8, max(errs)


def kkt_check_nesterov(beta, eta_L, mu_L, K):
    M_Nes = construct_M_Nes(beta, eta_L / 1.0, mu_L * 1.0, 1.0, K)
    theta = 2 * np.pi / K
    e0 = np.array([1.0, 0.0])
    e = [np.linalg.matrix_power(R(theta), t) @ e0 for t in range(K)]
    u = [(1 + beta) * e[t] - beta * e[(t - 1) % K] for t in range(K)]
    V = [M_Nes @ ut for ut in u]
    V_ccw = order_ccw(V)
    errs = [np.linalg.norm(project_onto_polygon(ut, V_ccw) - vt)
            for ut, vt in zip(u, V)]
    return max(errs) < 1e-8, max(errs)


def scan_F(K=3, mu_L=0.25, n=80):
    """Map F^HB and F^Nes."""
    betas = np.linspace(0.05, 0.95, n)
    etaLs = np.linspace(0.1, 4.0, n)
    F_HB, F_Nes = [], []
    for b in betas:
        for et in etaLs:
            try:
                hb_ok, _ = kkt_check_polyak(b, et, mu_L, K)
                ne_ok, _ = kkt_check_nesterov(b, et, mu_L, K)
            except Exception:
                continue
            if hb_ok:
                F_HB.append((b, et))
            if ne_ok:
                F_Nes.append((b, et))
    return F_HB, F_Nes


def simulate_NAG(beta, eta_L, mu_L, K, T=2000, lam=None, verbose=False):
    """Run NAG on f^Nes(x) = (mu/2)|x|^2 + (L-mu) Phi_{C^Nes}(x),
    starting from cycling-init (x_0, x_{-1}) = (lam e_0, lam e_{K-1}).
    Verify x_t = lam e_{t mod K}.

    Note: if Nesterov-feasible, the polytope is conv({lam V_t}) and
    f^Nes(x) = (L/2)|x|^2 - (L-mu)/2 d(x, conv(lam V))^2.
    """
    L = 1.0
    mu = mu_L * L
    eta = eta_L / L
    if lam is None:
        # default: lam = D / sqrt(2) with D=1
        lam = 1.0 / np.sqrt(2)

    M_Nes = construct_M_Nes(beta, eta, mu, L, K)
    theta = 2 * np.pi / K
    e0 = np.array([1.0, 0.0])
    e = [np.linalg.matrix_power(R(theta), t) @ e0 for t in range(K)]
    u = [(1 + beta) * e[t] - beta * e[(t - 1) % K] for t in range(K)]
    V = [lam * (M_Nes @ ut) for ut in u]   # rescale by lam since C^Nes = lam * conv(V_unit)
    V_ccw = order_ccw(V)

    def grad_fNes(x):
        Px = project_onto_polygon(x, V_ccw)
        return mu * x + (L - mu) * Px

    def fNes(x):
        Px = project_onto_polygon(x, V_ccw)
        return 0.5 * L * np.dot(x, x) - 0.5 * (L - mu) * np.dot(x - Px, x - Px)

    # Cycling-init for NAG
    x_prev = lam * e[(K - 1) % K]
    x_curr = lam * e[0]
    norms = [np.linalg.norm(x_prev), np.linalg.norm(x_curr)]
    for t in range(T):
        y_t = x_curr + beta * (x_curr - x_prev)
        x_next = y_t - eta * grad_fNes(y_t)
        x_prev = x_curr
        x_curr = x_next
        norms.append(np.linalg.norm(x_curr))

    final_norm = norms[-1]
    f_final = fNes(x_curr)
    f_init = fNes(lam * e[0])

    # Check if iterates stayed at amplitude lam (cycling)
    avg_dev = np.mean([abs(n - lam) for n in norms[2:]])
    max_dev = max([abs(n - lam) for n in norms[2:]])
    return final_norm, f_final, f_init, avg_dev, max_dev, norms


if __name__ == "__main__":
    print("=" * 70)
    print("Section C explore — Nesterov cycling region map and simulation")
    print("=" * 70)

    # Map regions for several mu/L
    for mu_L in [0.1, 0.25, 0.4]:
        print(f"\n[mu/L = {mu_L}, K = 3]")
        F_HB, F_Nes = scan_F(K=3, mu_L=mu_L, n=60)
        print(f"  |F_HB|  = {len(F_HB)} pairs")
        print(f"  |F_Nes| = {len(F_Nes)} pairs")
        # Intersection
        S_HB = set((round(b, 4), round(e, 4)) for b, e in F_HB)
        S_Nes = set((round(b, 4), round(e, 4)) for b, e in F_Nes)
        inter = S_HB & S_Nes
        print(f"  |F_HB ∩ F_Nes| = {len(inter)}")
        print(f"  |F_HB \\ F_Nes| = {len(S_HB - S_Nes)} (Polyak-only)")
        print(f"  |F_Nes \\ F_HB| = {len(S_Nes - S_HB)} (Nesterov-only)")

    # Show extent of F_Nes
    print("\n[Detailed F_Nes for K=3, mu/L=0.25]")
    F_HB, F_Nes = scan_F(K=3, mu_L=0.25, n=60)
    if F_Nes:
        betas = sorted(set(b for b, e in F_Nes))
        print(f"  beta range with NAG-cycle: [{min(betas):.3f}, {max(betas):.3f}]")
        for b in betas[::5]:
            ets = [e for bb, e in F_Nes if abs(bb - b) < 1e-8]
            if ets:
                print(f"  beta={b:.3f}: eta*L in [{min(ets):.3f}, {max(ets):.3f}]")

    # Pick a specific NAG-feasible point and run the simulation
    print("\n[Pick NAG-feasible (beta, eta*L) and run NAG]")
    if F_Nes:
        # Take a sample point
        beta_test, etaL_test = F_Nes[len(F_Nes) // 2]
        print(f"  Test point: beta={beta_test:.4f}, eta*L={etaL_test:.4f}")
        ok, err = kkt_check_nesterov(beta_test, etaL_test, 0.25, 3)
        print(f"  KKT check: ok={ok}, err={err:.3e}")

        for T in [100, 500, 2000]:
            fn, ff, fi, ad, md, _ = simulate_NAG(beta_test, etaL_test, 0.25, 3, T=T)
            print(f"  T={T}: |x_T|={fn:.6f} (target 1/sqrt(2)={1/np.sqrt(2):.6f}), "
                  f"f_final={ff:.6f}, max_dev={md:.3e}, avg_dev={ad:.3e}")

    # Also: a Polyak-feasible NAG-INFEASIBLE point — try running NAG, see what happens
    print("\n[Run NAG on Polyak-feasible-but-Nesterov-infeasible pair (the OP-2 case)]")
    print("  This tests: even though NAG cycling identity fails, does NAG iterate "
          "stay bounded on the (Polyak-built) f_0?")
    for beta_t, etaL_t in [(0.5, 3.0), (0.7, 2.9), (0.9, 3.5)]:
        # On f_0 (Polyak-built), use the Polyak vertex set but run NAG.
        L_v, mu_v = 1.0, 0.25
        eta_v = etaL_t / L_v
        M_HB = construct_M_HB(beta_t, etaL_t, mu_v, 3)
        theta = 2 * np.pi / 3
        e0 = np.array([1.0, 0.0])
        e = [np.linalg.matrix_power(R(theta), t) @ e0 for t in range(3)]
        lam = 1.0 / np.sqrt(2)
        V_hb = [lam * (M_HB @ et) for et in e]
        V_hb_ccw = order_ccw(V_hb)

        def gf0(x):
            Px = project_onto_polygon(x, V_hb_ccw)
            return mu_v * x + (L_v - mu_v) * Px

        def f0(x):
            Px = project_onto_polygon(x, V_hb_ccw)
            return 0.5 * L_v * np.dot(x, x) - 0.5 * (L_v - mu_v) * np.dot(x - Px, x - Px)

        x_prev = lam * e[2]
        x_curr = lam * e[0]
        norms_T = [np.linalg.norm(x_curr)]
        for T_max in [500, 2000, 10000]:
            x_p, x_c = x_prev.copy(), x_curr.copy()
            norms_traj = []
            for t in range(T_max):
                y_t = x_c + beta_t * (x_c - x_p)
                x_n = y_t - eta_v * gf0(y_t)
                x_p = x_c
                x_c = x_n
                norms_traj.append(np.linalg.norm(x_c))
                if np.linalg.norm(x_c) > 1e30:
                    break
            print(f"  beta={beta_t}, eta*L={etaL_t}, T={T_max}: "
                  f"|x_T|={np.linalg.norm(x_c):.4e}, f0={f0(x_c):.4e}, "
                  f"last 5 norms = {[f'{n:.4f}' for n in norms_traj[-5:]]}")
