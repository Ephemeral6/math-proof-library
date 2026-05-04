"""
Feasibility check for routes A, B, C, D toward C4 rigorous proof.

Each route gets ~1 minute of compute to assess viability.

Route A: Hessian Lipschitz of Goujaud f_0?
  Test: compute Hessian at x = (cycle vertex ± δ direction) for various δ.
        Check if Hessian is Lipschitz in x. Goujaud f_0 has piecewise constant
        Hessian (μI in vertex region, LI inside polytope), so it's NOT
        C² → Standard Floquet basin theorem doesn't apply directly.

Route B: Lyapunov function V(x, x_prev) = ‖x - λe_{t mod 3}‖² + α‖x - x_prev‖²
  Test: check if E[V_{t+1}] / V_t < 1 (contraction) at the anchor.

Route C: Interval arithmetic with mpmath.iv on SHB.
  Test: run 1 SHB step with parameter intervals; see if interval blows up.

Route D: Track ξ_t = x_t - λMe_{t mod 3} (relative-to-cycle coordinate).
  Test: check Lipschitz of ξ_T(p) — should be small (cycle absorbs param shift).
        This is what I suspect WILL work.
"""

import sys
import time
from pathlib import Path

import mpmath as mp


sys.stdout.reconfigure(line_buffering=True)
HERE = Path(__file__).parent
mp.mp.dps = 50

K = 3
L_val = mp.mpf(1)
D_val = mp.mpf(1)
lam_mp = D_val / mp.sqrt(2)


def e_vec(t):
    ang = 2 * mp.pi * (t % K) / K
    return mp.matrix([[mp.cos(ang)], [mp.sin(ang)]])


def Rmat(theta):
    c, s = mp.cos(theta), mp.sin(theta)
    return mp.matrix([[c, -s], [s, c]])


def goujaud_M_matrix(beta, eta, mu):
    """Returns the matrix M in cycling identity (M @ e_t = polytope vertex / λ)."""
    theta3 = 2 * mp.pi / 3
    I2 = mp.matrix([[1, 0], [0, 1]])
    R_pos = Rmat(theta3)
    R_neg = Rmat(-theta3)
    A = (1 + beta - mu * eta) * I2 - R_pos - beta * R_neg
    return A / ((L_val - mu) * eta)


def goujaud_vertices(beta, eta, mu):
    M = goujaud_M_matrix(beta, eta, mu)
    return [lam_mp * (M * e_vec(t)) for t in range(K)]


def project_triangle(x, verts):
    v0, v1, v2 = verts[0], verts[1], verts[2]

    def signed_area(a, b, c):
        return (b[0, 0] - a[0, 0]) * (c[1, 0] - a[1, 0]) - (b[1, 0] - a[1, 0]) * (
            c[0, 0] - a[0, 0]
        )

    A = signed_area(v0, v1, v2)
    s1 = signed_area(v0, v1, x) / A
    s2 = signed_area(v1, v2, x) / A
    s3 = signed_area(v2, v0, x) / A
    if s1 >= 0 and s2 >= 0 and s3 >= 0:
        return x

    best_d2, best_p = None, None
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
            best_d2, best_p = d2, p
    return best_p


def grad_f0(x, mu, verts):
    Pc = project_triangle(x, verts)
    return mu * x + (L_val - mu) * Pc


def shb_step(x, x_prev, eta, mu, beta, verts):
    return x - eta * grad_f0(x, mu, verts) + beta * (x - x_prev)


def matnorm(v):
    return mp.sqrt(v[0, 0] ** 2 + v[1, 0] ** 2)


# ---------------------------------------------------------------------------
# Route A: Hessian Lipschitz check
# ---------------------------------------------------------------------------

def feasibility_A():
    print("=" * 60)
    print("Route A — Hessian Lipschitz check")
    print("=" * 60)
    beta = mp.mpf("0.8")
    etaL = mp.mpf("3.247")
    kappa = mp.mpf("0.387")
    eta = etaL / L_val
    mu = kappa * L_val
    verts = goujaud_vertices(beta, eta, mu)

    # Compute gradient at several points and check Hessian (finite difference)
    h = mp.mpf("1e-10")
    test_points = [
        ("cycle vertex λe_0", lam_mp * e_vec(0)),
        ("inside C̃ at origin", mp.matrix([[mp.mpf("0.001")], [mp.mpf("0")]])),
        ("inside C̃ small", mp.matrix([[mp.mpf("0.1")], [mp.mpf("0.05")]])),
        ("just outside polytope", mp.matrix([[mp.mpf("0.5")], [mp.mpf("0")]])),
    ]
    for name, x in test_points:
        # Compute Hessian via finite difference of gradient
        g0 = grad_f0(x, mu, verts)
        ex = mp.matrix([[h], [0]])
        ey = mp.matrix([[0], [h]])
        gx = grad_f0(x + ex, mu, verts)
        gy = grad_f0(x + ey, mu, verts)
        Hx = (gx - g0) / h  # column 1 of Hessian
        Hy = (gy - g0) / h  # column 2
        H_diag = (float(Hx[0, 0]) + float(Hy[1, 0])) / 2  # half-trace ~ diagonal
        print(f"  {name}: Hessian ~ diag {H_diag:.4f} (μ={float(mu):.3f}, L={float(L_val):.3f})")
        # Eigenvalues of [[Hxx, Hxy], [Hyx, Hyy]]
        Hxx, Hyx = float(Hx[0, 0]), float(Hx[1, 0])
        Hxy, Hyy = float(Hy[0, 0]), float(Hy[1, 0])
        tr = Hxx + Hyy
        det = Hxx * Hyy - Hxy * Hyx
        disc = max(tr ** 2 / 4 - det, 0)
        e1 = tr / 2 + mp.sqrt(disc)
        e2 = tr / 2 - mp.sqrt(disc)
        print(f"      eigvals: ({float(e1):.4f}, {float(e2):.4f})")
    print("  → Goujaud f_0 has piecewise-constant Hessian (μI outside, ~LI inside).")
    print("  → NOT C², so standard Floquet basin theorem doesn't directly apply.")
    print("  → Route A: NOT VIABLE without modification.")
    print()


# ---------------------------------------------------------------------------
# Route C: interval arithmetic
# ---------------------------------------------------------------------------

def feasibility_C():
    print("=" * 60)
    print("Route C — interval arithmetic feasibility")
    print("=" * 60)
    try:
        # mpmath.iv arithmetic
        beta = mp.iv.mpf([0.795, 0.805])  # interval
        etaL = mp.iv.mpf([3.20, 3.29])
        kappa = mp.iv.mpf([0.385, 0.39])
        eta = etaL  # since L = 1
        mu = kappa
        # Try to compute Goujaud M
        # M = ((1+β-μη)I - R - βR^T) / ((L-μ)η) where R = R_{2π/3}
        theta3 = 2 * mp.iv.mpf(mp.pi) * 2 / 3
        cos_th = mp.iv.cos(theta3)
        sin_th = mp.iv.sin(theta3)
        # Compute one entry of M as test
        a = 1 + beta - mu * eta  # (1+β-ημ)
        denom = (1 - mu) * eta  # (L-μ)η with L=1
        # M[0,0] = (a - cos_th(2π/3) - β cos_th(-2π/3)) / denom
        # cos(2π/3) = -1/2, cos(-2π/3) = -1/2
        M_00_num = a - cos_th - beta * cos_th  # = a - (1+β)cos_th = a + (1+β)/2
        M_00 = M_00_num / denom
        print(f"  beta interval: [{beta.a}, {beta.b}] (width {beta.b - beta.a:.4f})")
        print(f"  eta interval: [{eta.a}, {eta.b}]")
        print(f"  M[0,0] interval: [{M_00.a}, {M_00.b}] (width {M_00.b - M_00.a:.4f})")
        if (M_00.b - M_00.a) < 5:
            print("  → Single-step interval: tractable.")
        # Try a few SHB steps with x as 2D interval
        x0_iv = mp.iv.mpf(["0.7071067811865475", "0.7071067811865476"])
        # Just one component
        x_curr = x0_iv
        x_prev = x0_iv
        # 1-step SHB on scalar (for testing): gradient = μx + (L-μ)·P_C(x)
        # But P_C requires deciding which region — too hard for intervals
        # Just verify that primitive interval operations don't blow up
        for t in range(10):
            x_new = (1 + beta) * x_curr - beta * x_prev - eta * mu * x_curr
            x_prev, x_curr = x_curr, x_new
            width = x_curr.b - x_curr.a
            print(f"  step {t+1}: interval width = {width:.6f}")
            if width > 100:
                print("  → blow-up at step", t+1)
                break
        print("  → Route C feasibility: linear part doesn't blow up rapidly.")
        print("    But projection P_C̃ is HARD with intervals (region branching).")
        print("    Route C: PARTIALLY VIABLE (would need careful region tracking).")
    except Exception as e:
        print(f"  ERROR: {e}")
        print("  → Route C: NOT VIABLE without significant infrastructure.")
    print()


# ---------------------------------------------------------------------------
# Route D: track ξ_t = x_t - λMe_{t mod 3} (relative-to-cycle coord)
# ---------------------------------------------------------------------------

def feasibility_D():
    print("=" * 60)
    print("Route D — relative-to-cycle coordinate ξ_t = x_t - cycle_vertex")
    print("=" * 60)
    box = {
        "beta":  (mp.mpf("0.78"), mp.mpf("0.82")),
        "etaL":  (mp.mpf("3.20"), mp.mpf("3.32")),
        "kappa": (mp.mpf("0.375"), mp.mpf("0.400")),
    }
    # Compute orbit at T_0=30 from zero-momentum init at center & 8 corners,
    # measure ξ_T(p) = x_T(p) - λ·M(p)·e_{T mod 3}
    T_0 = 30
    bc = (box["beta"][0] + box["beta"][1]) / 2
    ec = (box["etaL"][0] + box["etaL"][1]) / 2
    kc = (box["kappa"][0] + box["kappa"][1]) / 2
    test_points = [(bc, ec, kc, "center")]
    for bb in box["beta"]:
        for ee in box["etaL"]:
            for kk in box["kappa"]:
                test_points.append((bb, ee, kk, "corner"))

    def orbit_xi_T(beta, etaL, kappa, T):
        eta = etaL / L_val
        mu = kappa * L_val
        verts = goujaud_vertices(beta, eta, mu)
        x_prev = lam_mp * e_vec(0)
        x_curr = lam_mp * e_vec(0)
        for _ in range(T):
            x_new = shb_step(x_curr, x_prev, eta, mu, beta, verts)
            x_prev = x_curr
            x_curr = x_new
        # ξ = x_T - λ·M·e_{T mod 3}
        M_mat = goujaud_M_matrix(beta, eta, mu)
        cycle_vertex_T = lam_mp * (M_mat * e_vec(T))
        # Also track distance to OP-2 cycle position λe_{T mod 3}
        cycle_op2_T = lam_mp * e_vec(T)
        xi_polytope = x_curr - cycle_vertex_T  # x - polytope vertex
        xi_op2 = x_curr - cycle_op2_T  # x - OP-2 cycle position
        return x_curr, xi_polytope, xi_op2

    print(f"  T_0 = {T_0}")
    center_x, center_xi_poly, center_xi_op2 = orbit_xi_T(bc, ec, kc, T_0)
    print(f"  Center orbit x_T: ({float(center_x[0,0]):.6f}, {float(center_x[1,0]):.6f}), ‖x_T‖={float(matnorm(center_x)):.6f}")
    print(f"  Center ξ (vs polytope vertex): ‖ξ_polytope‖ = {float(matnorm(center_xi_poly)):.4e}")
    print(f"  Center ξ (vs OP-2 cycle λe_T): ‖ξ_op2‖     = {float(matnorm(center_xi_op2)):.4e}")
    print()
    print("  Comparison across 8 corners:")
    print(f"  {'corner':30s}  {'‖ξ_op2‖':>12s}  {'‖x - x_center‖':>15s}  {'‖ξ_op2 - ξ_op2_center‖':>22s}")
    max_xi_op2 = float(matnorm(center_xi_op2))
    max_dx = 0.0
    max_dxi = 0.0
    for bb, ee, kk, kind in test_points[1:]:  # skip center
        x_c, xi_poly, xi_op2 = orbit_xi_T(bb, ee, kk, T_0)
        n_xi_op2 = float(matnorm(xi_op2))
        n_dx = float(matnorm(x_c - center_x))
        n_dxi = float(matnorm(xi_op2 - center_xi_op2))
        max_xi_op2 = max(max_xi_op2, n_xi_op2)
        max_dx = max(max_dx, n_dx)
        max_dxi = max(max_dxi, n_dxi)
        label = f"({float(bb):.2f},{float(ee):.2f},{float(kk):.3f})"
        print(f"  {label:30s}  {n_xi_op2:12.4e}  {n_dx:15.4e}  {n_dxi:22.4e}")
    print()
    print(f"  Max ‖ξ_op2‖ over corners = {max_xi_op2:.4e}")
    print(f"  Max ‖x - x_center‖     = {max_dx:.4e}")
    print(f"  Max ‖ξ_op2 - ξ_op2_center‖ = {max_dxi:.4e}")
    print()
    if max_dxi < max_dx / 5:
        print(f"  → Route D: VIABLE. ξ-Lipschitz is {max_dx / max_dxi:.1f}× tighter than x-Lipschitz.")
    elif max_dxi < max_dx:
        print(f"  → Route D: PROMISING. ξ-Lipschitz is {max_dx / max_dxi:.1f}× tighter.")
    else:
        print(f"  → Route D: ξ-Lipschitz NOT tighter than x-Lipschitz.")
    return max_xi_op2, max_dx, max_dxi


def main():
    t0 = time.time()
    print("Caveat 1 C4 — Route feasibility checks")
    print(f"mpmath dps = {mp.mp.dps}")
    print()
    feasibility_A()
    feasibility_C()
    feasibility_D()
    print(f"Total wall time: {time.time() - t0:.1f}s")


if __name__ == "__main__":
    main()
