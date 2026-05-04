"""
Caveat 1 v2 — strengthen the C4 (basin extension) argument.

Two upgrades over caveat1_verify.py:
  (D1) Dense 4³ = 64 grid inside R* = [0.78,0.82]×[3.20,3.32]×[0.375,0.40].
       Verify cycling at every grid point with mpmath dps=50, T=3000.
       Period-3 residual + relative-norm both < 1e-30.
  (D2) Numerical Lipschitz-constant estimate for the orbit-at-time-T map
       Φ^T(p) (where p = (β,ηL,κ)). Use central differences at the box
       center; report the Frobenius norm of the parameter-Jacobian.
       Combined with the box diagonal, this gives a quantitative extension
       argument: the orbit at time T is uniformly close to the cycle on R*
       with controlled deviation.
"""

import json
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


def goujaud_vertices(beta, eta, mu):
    theta3 = 2 * mp.pi / 3
    I2 = mp.matrix([[1, 0], [0, 1]])
    R_pos = Rmat(theta3)
    R_neg = Rmat(-theta3)
    A = (1 + beta - mu * eta) * I2 - R_pos - beta * R_neg
    M = A / ((L_val - mu) * eta)
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


def run_orbit(beta, etaL, kappa, T):
    """Return (x_T, x_{T-1}) from zero-momentum init."""
    eta = etaL / L_val
    mu = kappa * L_val
    verts = goujaud_vertices(beta, eta, mu)
    x_prev = lam_mp * e_vec(0)
    x_curr = lam_mp * e_vec(0)
    for _ in range(T):
        x_new = shb_step(x_curr, x_prev, eta, mu, beta, verts)
        x_prev = x_curr
        x_curr = x_new
    return x_curr, x_prev


def cycling_diagnostics(beta, etaL, kappa, T=3000):
    """Both period-3 closure and relative-norm deviation."""
    x_T, _ = run_orbit(beta, etaL, kappa, T)
    # 3 more steps for period-3 closure
    eta = etaL / L_val
    mu = kappa * L_val
    verts = goujaud_vertices(beta, eta, mu)
    x_prev_save = x_T.copy() if hasattr(x_T, 'copy') else mp.matrix([[x_T[0,0]], [x_T[1,0]]])
    # Re-run from x_T
    x_T2, _ = run_orbit(beta, etaL, kappa, T + 3)
    final_norm = matnorm(x_T2)
    rel_diff = abs(final_norm - lam_mp) / lam_mp
    p3_err_rel = matnorm(x_T2 - x_prev_save) / lam_mp
    return float(rel_diff) if rel_diff < mp.mpf("1e300") else 1e300, \
           float(p3_err_rel) if p3_err_rel < mp.mpf("1e300") else 1e300, \
           float(final_norm)


# ---------------------------------------------------------------------------
# (D1) dense grid verification
# ---------------------------------------------------------------------------

def dense_grid_verify(box, n_per_dim=4, T=3000, threshold=1e-30):
    print(f"--- (D1) Dense grid verification: {n_per_dim}^3 = {n_per_dim**3} points ---")
    print(f"  Box: β∈[{float(box['beta'][0])},{float(box['beta'][1])}], "
          f"ηL∈[{float(box['etaL'][0])},{float(box['etaL'][1])}], "
          f"κ∈[{float(box['kappa'][0])},{float(box['kappa'][1])}]")
    print(f"  T = {T}, threshold for cycling = {threshold}")
    print()

    b1, b2 = box["beta"]
    e1, e2 = box["etaL"]
    k1, k2 = box["kappa"]
    points = []
    for i in range(n_per_dim):
        for j in range(n_per_dim):
            for k in range(n_per_dim):
                tb = mp.mpf(i) / (n_per_dim - 1) if n_per_dim > 1 else mp.mpf("0.5")
                te = mp.mpf(j) / (n_per_dim - 1) if n_per_dim > 1 else mp.mpf("0.5")
                tk = mp.mpf(k) / (n_per_dim - 1) if n_per_dim > 1 else mp.mpf("0.5")
                bb = b1 + tb * (b2 - b1)
                ee = e1 + te * (e2 - e1)
                kk = k1 + tk * (k2 - k1)
                points.append((bb, ee, kk))

    n_total = len(points)
    n_cycle = 0
    max_rel = 0.0
    max_p3 = 0.0
    failures = []
    t0 = time.time()
    for idx, (bb, ee, kk) in enumerate(points):
        rel, p3, fnorm = cycling_diagnostics(bb, ee, kk, T)
        is_cycle = rel < threshold and p3 < threshold
        if is_cycle:
            n_cycle += 1
            max_rel = max(max_rel, rel)
            max_p3 = max(max_p3, p3)
        else:
            failures.append({"beta": float(bb), "etaL": float(ee), "kappa": float(kk),
                             "rel": rel, "p3": p3, "final_norm": fnorm})
        if (idx + 1) % 8 == 0:
            elapsed = time.time() - t0
            print(f"    [{idx+1}/{n_total}] {n_cycle} cycle so far, t={elapsed:.1f}s")
    elapsed = time.time() - t0
    print()
    print(f"  RESULT: {n_cycle}/{n_total} cycle (mpmath dps=50, T={T})")
    print(f"  Max rel_diff among cycling: {max_rel:.2e}")
    print(f"  Max p3_err_rel among cycling: {max_p3:.2e}")
    print(f"  Failures: {len(failures)}")
    for f in failures:
        print(f"    {f}")
    print(f"  Wall time: {elapsed:.1f}s")
    return {
        "n_total": n_total,
        "n_cycle": n_cycle,
        "max_rel_diff": float(max_rel),
        "max_p3_err": float(max_p3),
        "failures": failures,
        "wall_time": elapsed,
    }


# ---------------------------------------------------------------------------
# (D2) Lipschitz constant estimate
# ---------------------------------------------------------------------------

def lipschitz_at_center(box, T=10):
    """Central-differences Jacobian of x_T w.r.t. (β, ηL, κ) at box center.
       At T=10 the orbit is in/near the cycle (after a few cycle periods at
       the anchor). The Lipschitz constant of x_T(p) in p tells us how a
       parameter perturbation propagates over T steps.

       Reports ||∂x_T / ∂p||_F (Frobenius norm of 2x3 Jacobian).
    """
    print(f"--- (D2) Lipschitz constant of x_T(p) at box center, T = {T} ---")
    b1, b2 = box["beta"]
    e1, e2 = box["etaL"]
    k1, k2 = box["kappa"]
    bc = (b1 + b2) / 2
    ec = (e1 + e2) / 2
    kc = (k1 + k2) / 2

    h = mp.mpf("1e-6")  # finite-difference step

    def x_T_at(beta, etaL, kappa):
        x, _ = run_orbit(beta, etaL, kappa, T)
        return mp.matrix([[x[0, 0]], [x[1, 0]]])

    # Central differences
    x0 = x_T_at(bc, ec, kc)
    print(f"  Center: (β,ηL,κ) = ({float(bc):.4f}, {float(ec):.4f}, {float(kc):.4f})")
    print(f"  x_T at center: ({float(x0[0,0]):.6f}, {float(x0[1,0]):.6f}); "
          f"||x_T||={float(matnorm(x0)):.6f}, λ={float(lam_mp):.6f}")

    dx_db = (x_T_at(bc + h, ec, kc) - x_T_at(bc - h, ec, kc)) / (2 * h)
    dx_de = (x_T_at(bc, ec + h, kc) - x_T_at(bc, ec - h, kc)) / (2 * h)
    dx_dk = (x_T_at(bc, ec, kc + h) - x_T_at(bc, ec, kc - h)) / (2 * h)

    # Jacobian columns
    J = [dx_db, dx_de, dx_dk]
    j_norms = [float(matnorm(j)) for j in J]
    j_frob = float(mp.sqrt(sum(matnorm(j) ** 2 for j in J)))

    print(f"  ||∂x_T/∂β||  = {j_norms[0]:.4f}")
    print(f"  ||∂x_T/∂ηL|| = {j_norms[1]:.4f}")
    print(f"  ||∂x_T/∂κ||  = {j_norms[2]:.4f}")
    print(f"  ||J||_F    = {j_frob:.4f}")

    box_diag = float(mp.sqrt((b2-b1)**2 + (e2-e1)**2 + (k2-k1)**2))
    print(f"  Box diagonal = {box_diag:.4f}")
    deviation = j_frob * box_diag
    print(f"  Maximum orbit deviation across box = ||J||_F × diag = {deviation:.4f}")
    print(f"  λ = {float(lam_mp):.4f}")
    print(f"  Deviation as fraction of λ: {deviation / float(lam_mp):.4f}")
    print()

    # Also report at 4 box corners for max
    corner_devs = []
    for bb in [b1, b2]:
        for ee in [e1, e2]:
            for kk in [k1, k2]:
                xc = x_T_at(bb, ee, kk)
                dist_from_center = float(matnorm(xc - x0))
                corner_devs.append({
                    "beta": float(bb), "etaL": float(ee), "kappa": float(kk),
                    "x_T_dist_from_center": dist_from_center,
                    "x_T_norm": float(matnorm(xc)),
                })
    max_corner_dev = max(c["x_T_dist_from_center"] for c in corner_devs)
    print(f"  Empirical max ||x_T(corner) - x_T(center)|| over 8 corners = {max_corner_dev:.4f}")
    print(f"    (linear extrapolation from Jacobian predicts {deviation/2:.4f} at half-diagonal)")

    return {
        "center_point": [float(bc), float(ec), float(kc)],
        "x_T_center": [float(x0[0, 0]), float(x0[1, 0])],
        "jacobian_col_norms": j_norms,
        "jacobian_frobenius": j_frob,
        "box_diagonal": box_diag,
        "predicted_deviation": float(deviation),
        "lambda_val": float(lam_mp),
        "empirical_corner_max_dev": max_corner_dev,
        "corner_orbits": corner_devs,
    }


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    t0 = time.time()
    out = {}
    print("=" * 72)
    print("Caveat 1 v2: dense grid + Lipschitz extension argument")
    print(f"mpmath dps = {mp.mp.dps}")
    print("=" * 72)
    print()

    box = {
        "beta":  (mp.mpf("0.78"), mp.mpf("0.82")),
        "etaL":  (mp.mpf("3.20"), mp.mpf("3.32")),
        "kappa": (mp.mpf("0.375"), mp.mpf("0.400")),
    }
    out["box"] = {
        "beta": [float(box["beta"][0]), float(box["beta"][1])],
        "etaL": [float(box["etaL"][0]), float(box["etaL"][1])],
        "kappa": [float(box["kappa"][0]), float(box["kappa"][1])],
        "volume": float((box["beta"][1]-box["beta"][0]) *
                        (box["etaL"][1]-box["etaL"][0]) *
                        (box["kappa"][1]-box["kappa"][0])),
    }

    d1 = dense_grid_verify(box, n_per_dim=4, T=3000, threshold=1e-30)
    out["D1_dense_grid"] = d1
    print()

    d2 = lipschitz_at_center(box, T=10)
    out["D2_lipschitz"] = d2

    print()
    print("=" * 72)
    print("SUMMARY")
    print("=" * 72)
    print(f"  D1: dense {d1['n_total']}-point grid: {d1['n_cycle']}/{d1['n_total']} cycle"
          f" ({100*d1['n_cycle']/d1['n_total']:.1f}%)")
    print(f"  D2: orbit-map Lipschitz at T=10: ||J||_F = {d2['jacobian_frobenius']:.2f}")
    print(f"      predicted box-uniform deviation = {d2['predicted_deviation']:.4f} ({d2['predicted_deviation']/d2['lambda_val']:.2f}λ)")
    print()
    print(f"  Wall time total: {time.time() - t0:.1f}s")

    out_path = HERE / "caveat1_v2_results.json"
    with open(out_path, "w", encoding="utf-8") as fp:
        json.dump(out, fp, indent=2, default=str)
    print(f"  Saved: {out_path}")


if __name__ == "__main__":
    main()
