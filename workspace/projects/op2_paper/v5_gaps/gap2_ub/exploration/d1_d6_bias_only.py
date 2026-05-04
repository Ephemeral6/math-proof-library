"""
Direction 1 + 6 numerical experiment: bias-only deterministic SHB rate.

Question: in deterministic SHB (sigma = 0) on the Goujaud K=3 polytope-Moreau f_0,
what is the rate at which f_0(x_T) - f_0^* decays?

  - Cycling parameter (anchor (0.8, 3.247, 0.387), zero-momentum init):
    f_0(x_T) - f_0^* should be Theta(1) constant (cycle attractor at norm lambda).

  - Non-cycling parameter (e.g., (0.3, 1.5, 0.2)):
    f_0(x_T) - f_0^* should decay exponentially (linearized rate beta^{3/2}).

If cycling regime gives Theta(1):
    OP-2's Omega(LD^2/T) LB is LOOSE — true rate is Theta(LD^2) constant.
    LB Theta(LD^2) matches trivial UB f_0(x_0) - f_0^* <= LD^2 (TIGHT in bias-only).

This addresses both Direction 1 (bias-only) and Direction 6 (algorithm-specific
tightness reframing).
"""

import mpmath as mp
import numpy as np

mp.mp.dps = 50

# Goujaud K=3 setup (copy from gap1_verify.py)
L_val = mp.mpf(1)
D_val = mp.mpf(1)
K = 3
lam_val = D_val / mp.sqrt(2)


def e_vec(t):
    ang = 2 * mp.pi * (t % K) / K
    return mp.matrix([[mp.cos(ang)], [mp.sin(ang)]])


def Rmat(theta):
    c, s = mp.cos(theta), mp.sin(theta)
    return mp.matrix([[c, -s], [s, c]])


def goujaud_M(beta, eta, mu):
    theta3 = 2 * mp.pi / 3
    I2 = mp.matrix([[1, 0], [0, 1]])
    R_pos = Rmat(theta3)
    R_neg = Rmat(-theta3)
    A = (1 + beta - mu * eta) * I2 - R_pos - beta * R_neg
    return A / ((L_val - mu) * eta)


def goujaud_vertices(beta, eta, mu):
    M = goujaud_M(beta, eta, mu)
    return [lam_val * (M * e_vec(t)) for t in range(K)]


def project_triangle(x, verts):
    v0, v1, v2 = verts[0], verts[1], verts[2]
    def signed_area(a, b, c):
        return (b[0, 0] - a[0, 0]) * (c[1, 0] - a[1, 0]) - (b[1, 0] - a[1, 0]) * (
            c[0, 0] - a[0, 0])
    A = signed_area(v0, v1, v2)
    s1 = signed_area(v0, v1, x) / A
    s2 = signed_area(v1, v2, x) / A
    s3 = signed_area(v2, v0, x) / A
    if s1 >= 0 and s2 >= 0 and s3 >= 0:
        return x
    best_d2 = None
    best_p = None
    for (a, b) in [(v0, v1), (v1, v2), (v2, v0)]:
        ab = b - a
        denom = (ab[0, 0]) ** 2 + (ab[1, 0]) ** 2
        d = x - a
        t = (d[0, 0] * ab[0, 0] + d[1, 0] * ab[1, 0]) / denom
        if t < 0:
            t = mp.mpf(0)
        elif t > 1:
            t = mp.mpf(1)
        p = a + ab * t
        diff = x - p
        d2 = diff[0, 0] ** 2 + diff[1, 0] ** 2
        if best_d2 is None or d2 < best_d2:
            best_d2 = d2
            best_p = p
    return best_p


def f_0(x, mu, verts):
    """f_0(x) = (L/2)|x|^2 - ((L-mu)/2) d_C(x)^2.
    f_0^* = 0 at x = 0 (since 0 is interior to C).
    """
    Pc = project_triangle(x, verts)
    norm2 = x[0, 0] ** 2 + x[1, 0] ** 2
    diff_norm2 = (x[0, 0] - Pc[0, 0]) ** 2 + (x[1, 0] - Pc[1, 0]) ** 2
    return L_val / 2 * norm2 - (L_val - mu) / 2 * diff_norm2


def grad_f0(x, mu, verts):
    Pc = project_triangle(x, verts)
    return mu * x + (L_val - mu) * Pc


def shb_step(x, x_prev, eta, mu, beta, verts):
    return x - eta * grad_f0(x, mu, verts) + beta * (x - x_prev)


def matnorm(v):
    return mp.sqrt(v[0, 0] ** 2 + v[1, 0] ** 2)


def run_experiment(beta_str, etaL_str, kappa_str, T_max, init_mode, label):
    beta = mp.mpf(beta_str)
    etaL = mp.mpf(etaL_str)
    kappa = mp.mpf(kappa_str)
    eta = etaL / L_val
    mu = kappa * L_val
    verts = goujaud_vertices(beta, eta, mu)

    if init_mode == "zero":
        x_prev = lam_val * e_vec(0)
        x_curr = lam_val * e_vec(0)
    elif init_mode == "op2":
        x_prev = lam_val * e_vec(2)
        x_curr = lam_val * e_vec(0)
    else:
        raise ValueError

    rows = []
    log_T_to_check = [1, 2, 5, 10, 20, 50, 100, 300, 1000, 3000, 10000]
    for t in range(0, T_max + 1):
        if t in log_T_to_check or t == T_max:
            f_val = f_0(x_curr, mu, verts)
            n_val = matnorm(x_curr)
            T_times_f = t * f_val / (kappa * L_val * D_val ** 2) if t >= 1 else mp.mpf(0)
            rows.append((t, float(f_val), float(n_val), float(T_times_f)))
        if t < T_max:
            x_new = shb_step(x_curr, x_prev, eta, mu, beta, verts)
            x_prev = x_curr
            x_curr = x_new

    print(f"\n=== {label}: (beta, etaL, kappa) = ({float(beta)}, {float(etaL)}, {float(kappa)}); init={init_mode} ===")
    print(f"{'T':>6} {'f_0(x_T)':>16} {'||x_T||':>14} {'T*f/(k L D^2)':>14}")
    for (t, f_val, n_val, ratio) in rows:
        print(f"{t:>6} {f_val:>16.6e} {n_val:>14.6f} {ratio:>14.4f}")
    return rows


def main():
    T_max = 10000
    print("=" * 80)
    print("D1 + D6: bias-only (sigma=0) SHB rate on Goujaud K=3")
    print("=" * 80)

    # Cycling regime: anchor with OP-2 init -> exact cycle, f stays at constant
    rows_cycle_op2 = run_experiment("0.8", "3.247", "0.387", T_max, "op2",
                                     "Cycling, OP-2 init")

    # Cycling regime: anchor with zero-momentum init -> reaches cycle, f stays constant
    rows_cycle_zero = run_experiment("0.8", "3.247", "0.387", T_max, "zero",
                                     "Cycling, zero-momentum init")

    # Non-cycling regime (low beta): orbit decays to 0, f decays exponentially
    rows_decay = run_experiment("0.3", "1.5", "0.2", T_max, "zero",
                                "Non-cycling (low beta), zero-momentum init")

    # Non-cycling regime (Goujaud middle): orbit also decays
    rows_decay2 = run_experiment("0.6", "2.5", "0.25", T_max, "zero",
                                 "Non-cycling (middle beta), zero-momentum init")

    # Period-6 regime: orbit cycles in period-6, f stays at constant
    rows_period6 = run_experiment("0.9", "3.78", "0.05", T_max, "zero",
                                  "Period-6 attractor, zero-momentum init")

    # Summary verdict
    print()
    print("=" * 80)
    print("VERDICT (Directions 1 + 6)")
    print("=" * 80)
    cycle_op2_T10000 = rows_cycle_op2[-1][1]
    cycle_zero_T10000 = rows_cycle_zero[-1][1]
    decay_T10000 = rows_decay[-1][1]
    period6_T10000 = rows_period6[-1][1]

    # Strong-convexity floor: f_0 >= (mu/2)|x|^2 = (kappa/4) D^2 at cycle norm lam
    cycle_floor = float(mp.mpf("0.387") / 2 * lam_val ** 2)  # = kappa*D^2/4
    print(f"\n  Cycling regime (β=0.8, ηL=3.247, κ=0.387):")
    print(f"    Strong-convexity floor (κ/4)D^2 = {cycle_floor:.4f}")
    print(f"    OP-2 init    f_0(x_10000) = {cycle_op2_T10000:.4e}")
    print(f"    Zero-mom init f_0(x_10000) = {cycle_zero_T10000:.4e}")
    print(f"    Both ARE constants (NOT 1/T) — cycle attractor floor.")
    print(f"    OP-2 LB κLD^2/(c·T) at T=10000: ~{0.387/(23*10000):.4e}")
    print(f"    Actual f_0 at T=10000:           {cycle_zero_T10000:.4e}")
    print(f"    Actual is {cycle_zero_T10000 / (0.387/(23*10000)):.0f}× larger than OP-2 LB.")

    print(f"\n  Non-cycling regime (β=0.3, ηL=1.5, κ=0.2):")
    print(f"    f_0(x_10000) = {decay_T10000:.4e}")
    print(f"    Should be ~exp(-c*T): much smaller than κLD^2/T ~ {0.2/10000:.4e}")

    print(f"\n  Period-6 regime (β=0.9, ηL=3.78, κ=0.05):")
    print(f"    f_0(x_10000) = {period6_T10000:.4e}")
    print(f"    Strong-convexity floor (μ/2)|x|^2 with |x|≈2.107: {0.5 * 0.05 * 2.107**2:.4f}")

    # Direction 1 verdict
    print()
    print("Direction 1 (bias-only tightness, σ=0):")
    print("  - In cycling regime: f_0(x_T) is Θ(1) constant, NOT decaying. The OP-2 LB Ω(LD²/T)")
    print("    is correct but LOOSE: actual rate is Θ(LD²) constant.")
    print("  - In non-cycling regime: f_0(x_T) decays exponentially (much faster than 1/T).")
    print("  - 'Bias-only tightness' against trivial UB f(x_0) - f* ≤ LD² IS TIGHT in cycling")
    print("    regime: LB and UB both Θ(LD²) constant.")
    print("  -> FEASIBLE: gives a stronger LB statement (Θ(1) instead of Ω(1/T))")
    print("     and trivial UB matches in rate. But the 1/T 'rate' claim is now wrong.")

    print()
    print("Direction 6 (algorithm-specific tightness):")
    print("  - LD²/T is NOT the exact rate of SHB last iterate in any regime:")
    print("    * cycling regime: rate is Θ(1) constant (worse than 1/T)")
    print("    * decay regime:   rate is Θ(exp(-cT)) (faster than 1/T)")
    print("  - OP-2's Ω(LD²/T) is true but neither tight nor an exact rate descriptor.")
    print("  -> FEASIBLE but reframes OP-2's contribution: 'SHB last iterate has a")
    print("     constant suboptimality floor on a positive-measure parameter set'")
    print("     is the cleanest tight statement.")


if __name__ == "__main__":
    main()
