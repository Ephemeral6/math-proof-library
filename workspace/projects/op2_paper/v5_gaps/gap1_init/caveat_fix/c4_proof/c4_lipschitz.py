"""
Lipschitz estimate at T=100 for the orbit map x_T(p), at box center and
at corners. Used to quantify the per-cell extension argument.
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
        t_param = (d[0, 0] * ab[0, 0] + d[1, 0] * ab[1, 0]) / denom
        if t_param < 0:
            t_param = mp.mpf(0)
        elif t_param > 1:
            t_param = mp.mpf(1)
        p = a + ab * t_param
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


def x_T_at(beta, etaL, kappa, T):
    eta = etaL / L_val
    mu = kappa * L_val
    verts = goujaud_vertices(beta, eta, mu)
    x_prev = lam_mp * e_vec(0)
    x_curr = lam_mp * e_vec(0)
    for _ in range(T):
        x_new = shb_step(x_curr, x_prev, eta, mu, beta, verts)
        x_prev = x_curr
        x_curr = x_new
    return x_curr


def lipschitz_at(beta, etaL, kappa, T, h=mp.mpf("1e-6")):
    """Central differences for ‖∂x_T/∂(β,ηL,κ)‖_F."""
    x_T_b_p = x_T_at(beta + h, etaL, kappa, T)
    x_T_b_m = x_T_at(beta - h, etaL, kappa, T)
    x_T_e_p = x_T_at(beta, etaL + h, kappa, T)
    x_T_e_m = x_T_at(beta, etaL - h, kappa, T)
    x_T_k_p = x_T_at(beta, etaL, kappa + h, T)
    x_T_k_m = x_T_at(beta, etaL, kappa - h, T)
    db = (x_T_b_p - x_T_b_m) / (2 * h)
    de = (x_T_e_p - x_T_e_m) / (2 * h)
    dk = (x_T_k_p - x_T_k_m) / (2 * h)
    nb = float(matnorm(db))
    ne = float(matnorm(de))
    nk = float(matnorm(dk))
    j_frob = (nb ** 2 + ne ** 2 + nk ** 2) ** 0.5
    return nb, ne, nk, j_frob


def main():
    t0 = time.time()
    box = {
        "beta":  (mp.mpf("0.78"), mp.mpf("0.82")),
        "etaL":  (mp.mpf("3.20"), mp.mpf("3.32")),
        "kappa": (mp.mpf("0.375"), mp.mpf("0.400")),
    }
    bc = (box["beta"][0] + box["beta"][1]) / 2
    ec = (box["etaL"][0] + box["etaL"][1]) / 2
    kc = (box["kappa"][0] + box["kappa"][1]) / 2
    cell_radius = float(((box["beta"][1]-box["beta"][0])/10)**2 +
                        ((box["etaL"][1]-box["etaL"][0])/10)**2 +
                        ((box["kappa"][1]-box["kappa"][0])/10)**2) ** 0.5
    cone_margin = 0.5566  # min over 216 grid (from c4_main_results)

    print(f"Box center: (β,ηL,κ) = ({float(bc):.4f}, {float(ec):.4f}, {float(kc):.4f})")
    print(f"Cell radius (half-diagonal of grid cell at 6³ resolution): {cell_radius:.4f}")
    print(f"Cone margin (min over 216 grid): {cone_margin:.4f}")
    print()

    # Test points: center + 8 corners
    test_points = [(bc, ec, kc, "center")]
    for bb in box["beta"]:
        for ee in box["etaL"]:
            for kk in box["kappa"]:
                test_points.append((bb, ee, kk, "corner"))

    out = {}
    for T in [10, 30, 100, 200]:
        print(f"=" * 60)
        print(f"Lipschitz at T = {T}")
        print(f"=" * 60)
        out[f"T_{T}"] = {}
        max_jfrob = 0.0
        for bb, ee, kk, kind in test_points:
            nb, ne, nk, j_frob = lipschitz_at(bb, ee, kk, T)
            kind_label = f"({float(bb):.3f},{float(ee):.4f},{float(kk):.4f})"
            print(f"  {kind:6s} {kind_label}: ‖J‖_F = {j_frob:.4f}  "
                  f"(∂β={nb:.2f}, ∂ηL={ne:.2f}, ∂κ={nk:.2f})")
            out[f"T_{T}"][kind_label] = {"jfrob": j_frob, "nb": nb, "ne": ne, "nk": nk}
            max_jfrob = max(max_jfrob, j_frob)
        out[f"T_{T}"]["max_jfrob"] = max_jfrob
        deviation_per_cell = max_jfrob * cell_radius
        deviation_per_box = max_jfrob * float((((box["beta"][1]-box["beta"][0]))**2 +
                                                ((box["etaL"][1]-box["etaL"][0]))**2 +
                                                ((box["kappa"][1]-box["kappa"][0]))**2) ** 0.5)
        print(f"  max ‖J‖_F over test points = {max_jfrob:.4f}")
        print(f"  predicted orbit deviation per cell = {deviation_per_cell:.4f}")
        print(f"  predicted orbit deviation across box = {deviation_per_box:.4f}")
        print(f"  cone margin = {cone_margin:.4f}")
        per_cell_OK = deviation_per_cell < cone_margin
        print(f"  per-cell extension VALID: {per_cell_OK}")
        out[f"T_{T}"]["deviation_per_cell"] = deviation_per_cell
        out[f"T_{T}"]["per_cell_OK"] = per_cell_OK
        print()

    out["box"] = {"beta": [float(box["beta"][0]), float(box["beta"][1])],
                  "etaL": [float(box["etaL"][0]), float(box["etaL"][1])],
                  "kappa": [float(box["kappa"][0]), float(box["kappa"][1])],
                  "cell_radius": cell_radius,
                  "cone_margin": cone_margin}
    out["wall_time"] = time.time() - t0

    out_path = HERE / "c4_lipschitz_results.json"
    with open(out_path, "w", encoding="utf-8") as fp:
        json.dump(out, fp, indent=2, default=str)
    print(f"Saved: {out_path}")
    print(f"Total wall time: {time.time() - t0:.1f}s")


if __name__ == "__main__":
    main()
