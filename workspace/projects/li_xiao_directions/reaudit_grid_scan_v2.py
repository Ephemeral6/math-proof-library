"""
RE-AUDIT v2: Direction 1 zero-momentum grid scan at higher precision.

Changes vs. zero_momentum_grid_scan.py:
  - mpmath dps: 50 -> 100
  - T (steps): 2000 -> 10000
  - cycle classification: |||x_T||-D/sqrt(2)|/(D/sqrt(2)) < 0.01 (was 0.10)
  - decay classification: ||x_T|| < 1e-4 * D       (was 0.05 * D/sqrt(2))

Same 100-point grid as before so we can directly compare counts.
"""

import mpmath as mp
import math
import json
import time
from pathlib import Path

mp.mp.dps = 100  # high precision

# Parameters
L = mp.mpf(1)
D = mp.mpf(1)
K = 3
theta_K = 2 * mp.pi / K
c_K = mp.cos(theta_K)

beta_star = (mp.sqrt(13) - 3) / 2

def gamma_crit(beta):
    return 3 * (1 + beta + beta**2) / (1 + 2*beta)

def goujaud_M(beta, eta, mu):
    cos_t, sin_t = mp.cos(theta_K), mp.sin(theta_K)
    R_pos = mp.matrix([[cos_t, -sin_t], [sin_t, cos_t]])
    R_neg = mp.matrix([[cos_t, sin_t], [-sin_t, cos_t]])
    I2 = mp.matrix([[1, 0], [0, 1]])
    A = (1 + beta - mu*eta) * I2 - R_pos - beta * R_neg
    return A / ((L - mu) * eta)

def feasible_kappa(beta, eta_L):
    eta = eta_L / L
    a = eta_L**2 - 2*eta_L*(1 + beta/2)
    b = -2*eta_L*(beta + mp.mpf(1)/2) + 3*(1 + beta + beta**2)
    if a > 0:
        kappa_max = -b/a
        if kappa_max <= 0:
            return None
        return min(kappa_max/2, mp.mpf("0.5"))
    elif a < 0:
        kappa_min = -b/a
        if kappa_min >= 1:
            return None
        return (kappa_min + 1)/2
    else:
        if b < 0:
            return mp.mpf("0.5")
        return None

def char_roots(beta, eta, lam):
    a1 = 1 + beta - eta*lam
    disc = a1**2 - 4*beta
    if disc >= 0:
        s = mp.sqrt(disc)
        return (a1 + s)/2, (a1 - s)/2
    else:
        s = mp.sqrt(-disc)
        return mp.mpc(a1/2, s/2), mp.mpc(a1/2, -s/2)

def goujaud_polytope_vertices(beta, eta, mu):
    M = goujaud_M(beta, eta, mu)
    vertices = []
    for t in range(K):
        angle = t * theta_K
        e_t = mp.matrix([[mp.cos(angle)], [mp.sin(angle)]])
        v = M * e_t * (D / mp.sqrt(2))
        vertices.append(v)
    return vertices

def project_to_polygon(x, vertices):
    Kn = len(vertices)
    inside = True
    for i in range(Kn):
        v_i = vertices[i]
        v_next = vertices[(i+1) % Kn]
        e = v_next - v_i
        d = x - v_i
        cross = e[0,0]*d[1,0] - e[1,0]*d[0,0]
        if cross < 0:
            inside = False
            break
    if inside:
        return x
    best_d = None
    best_p = None
    for i in range(Kn):
        v_i = vertices[i]
        v_next = vertices[(i+1) % Kn]
        e = v_next - v_i
        e_norm2 = e[0,0]**2 + e[1,0]**2
        if e_norm2 == 0:
            p = v_i
        else:
            d = x - v_i
            t = (d[0,0]*e[0,0] + d[1,0]*e[1,0]) / e_norm2
            t = max(mp.mpf(0), min(mp.mpf(1), t))
            p = v_i + e * t
        diff = x - p
        dist2 = diff[0,0]**2 + diff[1,0]**2
        if best_d is None or dist2 < best_d:
            best_d = dist2
            best_p = p
    return best_p

def grad_f0(x, beta, eta, mu, vertices):
    Pc = project_to_polygon(x, vertices)
    return mu * x + (L - mu) * Pc

def shb_step(x_t, x_tm1, beta, eta, mu, vertices):
    g = grad_f0(x_t, beta, eta, mu, vertices)
    return x_t - eta * g + beta * (x_t - x_tm1)

def run_shb_zero_init(beta, eta_L, mu, T, record_norms=True):
    eta = eta_L / L
    vertices = goujaud_polytope_vertices(beta, eta, mu)
    e0 = mp.matrix([[mp.cos(mp.mpf(0))], [mp.sin(mp.mpf(0))]])
    R = D / mp.sqrt(2)
    x_init = R * e0
    x_tm1 = x_init.copy()
    x_t = x_init.copy()

    # we only need tail for classification; record last 1000 norms + final
    norms_tail = []
    tail_size = 1000
    for t in range(T):
        x_next = shb_step(x_t, x_tm1, beta, eta, mu, vertices)
        x_tm1 = x_t
        x_t = x_next
        if T - t <= tail_size:
            norms_tail.append(mp.sqrt(x_t[0,0]**2 + x_t[1,0]**2))
    final_norm = norms_tail[-1] if norms_tail else mp.sqrt(x_t[0,0]**2 + x_t[1,0]**2)
    return norms_tail, final_norm

def classify_orbit_strict(norms_tail, final_norm, target_R, D_val):
    """Tightened classification:
       - cycling: |final - target_R|/target_R < 0.01
       - decay:   final < 1e-4 * D
       - other:   neither
    """
    final = float(final_norm)
    target = float(target_R)
    Dv = float(D_val)
    rel_diff = abs(final - target) / target
    if final < 1e-4 * Dv:
        return "decay", final, rel_diff
    if rel_diff < 0.01:
        return "cycling", final, rel_diff
    return "other", final, rel_diff

def main():
    results = []
    target_R = D / mp.sqrt(2)
    target_R_f = float(target_R)
    D_f = float(D)

    beta_grid = [mp.mpf(b) for b in [0.31, 0.35, 0.40, 0.45, 0.50, 0.60, 0.70, 0.80, 0.90, 0.95]]
    eta_steps_per_beta = 10
    T = 10000

    print(f"# RE-AUDIT v2: Zero-Momentum Grid Scan (mpmath dps={mp.mp.dps}, T={T})")
    print(f"# K={K}, beta_star = {float(beta_star):.6f}")
    print(f"# Target cycle radius R = D/sqrt(2) = {target_R_f:.6f}")
    print(f"# STRICT cycle cutoff: rel_diff < 0.01")
    print(f"# STRICT decay cutoff: final < 1e-4 * D = {1e-4*D_f}")
    print()
    print(f"{'beta':>6} {'eta_L':>7} {'kappa':>8} {'verdict_zero':>14} {'final_zero':>14} {'rel_diff':>10} {'r1mu_complex':>13}")

    t_start = time.time()
    pts_done = 0

    for beta in beta_grid:
        gc = gamma_crit(beta)
        eta_max = 2 * (1 + beta)
        if eta_max <= gc:
            continue
        for j in range(eta_steps_per_beta):
            t_frac = mp.mpf(j + 0.5) / eta_steps_per_beta
            eta_L = gc + t_frac * (eta_max - gc)

            kappa = feasible_kappa(beta, eta_L)
            if kappa is None:
                continue
            mu = kappa * L
            eta = eta_L / L

            norms_tail, final_zero = run_shb_zero_init(beta, eta_L, mu, T)
            v_zero, f_zero, rel = classify_orbit_strict(norms_tail, final_zero, target_R, D)

            r1_mu, r2_mu = char_roots(beta, eta, mu)
            r1_L, r2_L = char_roots(beta, eta, L)

            pts_done += 1
            print(f"{float(beta):6.3f} {float(eta_L):7.3f} {float(kappa):8.4f} {v_zero:>14s} {f_zero:14.6e} {rel:10.4e} {str(isinstance(r1_mu, mp.mpc)):>13}")

            results.append({
                "beta": float(beta),
                "eta_L": float(eta_L),
                "kappa": float(kappa),
                "verdict_zero_v2": v_zero,
                "final_zero_v2": f_zero,
                "rel_diff_v2": rel,
                "r1_mu_complex": isinstance(r1_mu, mp.mpc),
                "r1_L_complex": isinstance(r1_L, mp.mpc),
            })

    out_path = Path(r"C:\Users\12729\Desktop\Math\workspace\active\li_xiao_directions\reaudit_grid_v2_results.json")
    with open(out_path, "w", encoding="utf-8") as fp:
        json.dump(results, fp, indent=2)
    elapsed = time.time() - t_start
    print(f"\nSaved {len(results)} grid points to {out_path}  (elapsed {elapsed:.1f}s)")

    n_total = len(results)
    n_cyc = sum(1 for r in results if r["verdict_zero_v2"] == "cycling")
    n_dec = sum(1 for r in results if r["verdict_zero_v2"] == "decay")
    n_oth = n_total - n_cyc - n_dec
    print(f"\n=== V2 SUMMARY (dps=100, T=10000, strict cutoffs) ===")
    print(f"Total: {n_total}")
    print(f"  cycling: {n_cyc}/{n_total}   (original 8)")
    print(f"  decay:   {n_dec}/{n_total}   (original 73)")
    print(f"  other:   {n_oth}/{n_total}   (original 19)")

    print(f"\n=== Cycling points (v2) ===")
    for r in results:
        if r["verdict_zero_v2"] == "cycling":
            print(f"  beta={r['beta']:.3f}  etaL={r['eta_L']:.4f}  kappa={r['kappa']:.4f}")

    print(f"\n=== Other points (v2) ===")
    for r in results:
        if r["verdict_zero_v2"] == "other":
            print(f"  beta={r['beta']:.3f}  etaL={r['eta_L']:.4f}  kappa={r['kappa']:.4f}  final={r['final_zero_v2']:.5f}")

if __name__ == "__main__":
    main()
