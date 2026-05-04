"""
Section C: Nesterov-cycling polytope construction attempt.

We seek M^Nes such that (i) M^Nes commutes with R = R_{theta_K}
(equivalently M^Nes is a scaled-rotation in 2D), and (ii) the projection
identity P_{C^Nes}(lambda u_t) = lambda M^Nes u_t holds for u_t = (1+beta)e_t - beta e_{t-1}
where e_t = R^t e_0, and (iii) the gradient identity gives x_{t+1} = lambda e_{t+1}.

Algebra: NAG cycling identity becomes
   M^Nes = [(1 - eta*mu) I - R * ((1+beta) I - beta R^{-1})^{-1}] / (eta (L - mu))
provided this M^Nes commutes with R. Since R^{-1} commutes with R, and
((1+beta)I - beta R^{-1}) is a polynomial in R, its inverse is also a polynomial
in R, so M^Nes IS a polynomial in R, hence commutes with R. Good.

We then check whether
   P^Nes := { lambda M^Nes u_t : t = 0,..,K-1 }
is a valid Goujaud-style polytope: its vertices must be the projections, which
requires that the KKT projection condition holds. We test this NUMERICALLY by:
(a) computing M^Nes,
(b) computing the candidate vertex set V_t := M^Nes u_t,
(c) checking whether P_{conv(V)}(u_t) = V_t (i.e., the points u_t actually project
    onto V_t when projecting onto conv(V)).

If yes, we have a Nesterov-cycling instance.
If no (KKT fails), we report the algebraic obstruction.
"""

import numpy as np
from itertools import product

def R(theta):
    return np.array([[np.cos(theta), -np.sin(theta)],
                     [np.sin(theta),  np.cos(theta)]])

def project_onto_polygon(p, vertices):
    """
    Closed-form projection of point p onto convex hull of vertices.
    For arbitrary K, we use the analytic check: the projection is the
    closest point on the polygon (vertex, edge, or interior).
    Vertices given in CCW order.
    """
    K = len(vertices)
    # Check if p is inside the polygon (via half-plane tests).
    # For convex CCW polygon, p is inside iff it's on the left of every edge.
    inside = True
    for i in range(K):
        a = vertices[i]
        b = vertices[(i + 1) % K]
        edge = b - a
        normal_outward = np.array([edge[1], -edge[0]])  # right of edge (outward for CCW)
        if np.dot(p - a, normal_outward) > 1e-12:
            inside = False
            break
    if inside:
        return p.copy()
    # Otherwise project onto each edge segment, take closest.
    best = None
    best_dist = np.inf
    for i in range(K):
        a = vertices[i]
        b = vertices[(i + 1) % K]
        # project p onto segment ab
        ab = b - a
        t = np.dot(p - a, ab) / np.dot(ab, ab)
        t_clamped = max(0.0, min(1.0, t))
        q = a + t_clamped * ab
        d = np.linalg.norm(p - q)
        if d < best_dist:
            best_dist = d
            best = q
    return best


def order_ccw(vertices):
    """Sort vertices in CCW order around their centroid."""
    c = np.mean(vertices, axis=0)
    angles = [np.arctan2(v[1] - c[1], v[0] - c[0]) for v in vertices]
    idx = np.argsort(angles)
    return [vertices[i] for i in idx]


def construct_M_Nes(beta, eta, mu, L, K):
    """Compute M^Nes for Nesterov cycling identity."""
    theta = 2 * np.pi / K
    Rmat = R(theta)
    Rinv = R(-theta)
    I = np.eye(2)
    A = (1 + beta) * I - beta * Rinv
    Ainv = np.linalg.inv(A)
    M_Nes = ((1 - eta * mu) * I - Rmat @ Ainv) / (eta * (L - mu))
    return M_Nes


def construct_M_HB(beta, eta_L, mu_L, K):
    """Polyak HB cycling: M = ((1+beta - eta mu)I - R - beta R^{-1}) / (eta (L - mu)).
    eta_L = eta*L, mu_L = mu/L. We set L=1 internally."""
    L = 1.0
    mu = mu_L * L
    eta = eta_L / L
    theta = 2 * np.pi / K
    Rmat = R(theta)
    Rinv = R(-theta)
    I = np.eye(2)
    return ((1 + beta - eta * mu) * I - Rmat - beta * Rinv) / (eta * (L - mu))


def test_nesterov_cycling(beta, eta_L, mu_L, K, lam=1.0, verbose=True):
    """
    For given (beta, eta*L, mu/L, K), check whether the candidate Nesterov-cycling
    polytope actually realizes a projection identity.
    """
    L = 1.0
    mu = mu_L * L
    eta = eta_L / L

    M_Nes = construct_M_Nes(beta, eta, mu, L, K)
    theta = 2 * np.pi / K

    # Cycle points e_t = R^t (1, 0)^T
    e0 = np.array([1.0, 0.0])
    e = [np.linalg.matrix_power(R(theta), t) @ e0 for t in range(K)]
    # Lookahead points u_t = (1+beta) e_t - beta e_{t-1}
    u = [(1 + beta) * e[t] - beta * e[(t - 1) % K] for t in range(K)]

    # Vertex set: V_t = M_Nes @ u_t  (rescaled by lam later, but lam=1 for this test)
    V = [M_Nes @ ut for ut in u]
    V_ccw = order_ccw(V)

    # Test: does P_{conv(V)}(u_t) = V_t?
    results = []
    for t in range(K):
        p_proj = project_onto_polygon(u[t], V_ccw)
        target = V[t]
        err = np.linalg.norm(p_proj - target)
        results.append((t, np.linalg.norm(u[t]), np.linalg.norm(target), err))

    if verbose:
        print(f"  beta={beta}, eta*L={eta_L}, mu/L={mu_L}, K={K}:")
        print(f"    M_Nes =\n      {M_Nes[0]}\n      {M_Nes[1]}")
        print(f"    Vertex norms: {[np.linalg.norm(v) for v in V]}")
        print(f"    Lookahead norms |u_t|: {[np.linalg.norm(ut) for ut in u]}")
        for t, nu, nv, err in results:
            print(f"    t={t}: |u_t|={nu:.4f}, |V_t|={nv:.4f}, "
                  f"||P_conv(V)(u_t) - V_t|| = {err:.6e}")

    max_err = max(r[3] for r in results)
    cycling_holds = max_err < 1e-8
    return cycling_holds, max_err, M_Nes, V


def feasibility_region_Nes(K=3, mu_L=0.25, n_grid=80, verbose=False):
    """Scan (beta, eta*L) to find Nesterov-cycling feasibility region."""
    betas = np.linspace(0.05, 0.95, n_grid)
    etaLs = np.linspace(0.1, 4.0, n_grid)
    feas_pairs = []
    for beta in betas:
        for eta_L in etaLs:
            try:
                ok, err, _, _ = test_nesterov_cycling(beta, eta_L, mu_L, K, verbose=False)
                if ok:
                    feas_pairs.append((beta, eta_L, err))
            except np.linalg.LinAlgError:
                continue
    return feas_pairs


if __name__ == "__main__":
    print("=" * 70)
    print("Section C — Nesterov cycling polytope construction (algebraic check)")
    print("=" * 70)

    # First, check feasibility at the same parameter triples used in OP-2 / D5.
    test_cases = [
        (0.5, 3.0, 0.25, 3),
        (0.7, 2.9, 0.337, 3),
        (0.9, 3.5, 0.398, 3),
        (0.5, 1.0, 0.25, 3),
        (0.5, 2.0, 0.25, 3),
        (0.3, 1.5, 0.1, 3),
        (0.5, 3.0, 0.25, 4),
        (0.5, 3.0, 0.25, 5),
    ]

    print("\n[1] At specific (beta, eta*L, mu/L, K):")
    for beta, eta_L, mu_L, K in test_cases:
        ok, err, M_Nes, V = test_nesterov_cycling(beta, eta_L, mu_L, K, verbose=False)
        verdict = "CYCLES" if ok else "FAILS"
        # Compare to Polyak feasibility
        try:
            M_HB = construct_M_HB(beta, eta_L, mu_L, K)
            theta = 2 * np.pi / K
            e0 = np.array([1.0, 0.0])
            e = [np.linalg.matrix_power(R(theta), t) @ e0 for t in range(K)]
            V_HB = [M_HB @ et for et in e]
            V_HB_ccw = order_ccw(V_HB)
            # check Polyak projection identity
            errs_HB = [np.linalg.norm(project_onto_polygon(et, V_HB_ccw) - vt)
                       for et, vt in zip(e, V_HB)]
            hb_ok = max(errs_HB) < 1e-8
        except Exception:
            hb_ok = False

        print(f"  beta={beta}, eta*L={eta_L}, mu/L={mu_L}, K={K}: "
              f"NAG-cycle {verdict} (max err {err:.3e}), Polyak-cycle {'YES' if hb_ok else 'NO'}")

    print("\n[2] Scanning (beta, eta*L) for Nesterov-cycling region (K=3, mu/L=0.25):")
    feas = feasibility_region_Nes(K=3, mu_L=0.25, n_grid=40)
    print(f"  Found {len(feas)} feasible (beta, eta*L) pairs out of 40x40 = 1600")
    if feas:
        print(f"  Sample: {feas[:5]}")

    print("\n[3] Diagnostic: examine WHY the projection identity fails (if it does)")
    # Take a parameter where Polyak feasibility holds; check NAG side carefully.
    beta, eta_L, mu_L, K = 0.5, 3.0, 0.25, 3
    ok, err, M_Nes, V = test_nesterov_cycling(beta, eta_L, mu_L, K, verbose=True)

    # Separately verify: for HB, M @ e_t for the *same* (beta, eta, mu, L, K)
    M_HB = construct_M_HB(beta, eta_L, mu_L, K)
    theta = 2 * np.pi / K
    e0 = np.array([1.0, 0.0])
    e = [np.linalg.matrix_power(R(theta), t) @ e0 for t in range(K)]
    V_HB = [M_HB @ et for et in e]
    print(f"\n  Polyak vertex norms: {[np.linalg.norm(v) for v in V_HB]}")
    print(f"  Polyak vertex angles (deg): "
          f"{[np.degrees(np.arctan2(v[1], v[0])) % 360 for v in V_HB]}")
    print(f"  Nesterov candidate vertex norms: {[np.linalg.norm(v) for v in V]}")
    print(f"  Nesterov candidate vertex angles (deg): "
          f"{[np.degrees(np.arctan2(v[1], v[0])) % 360 for v in V]}")

    # The lookahead points u_t — where do they sit relative to candidate polytope?
    u = [(1 + beta) * e[t] - beta * e[(t - 1) % K] for t in range(K)]
    V_ccw = order_ccw(V)
    print(f"\n  Lookahead u_t norms: {[np.linalg.norm(ut) for ut in u]}")
    print(f"  Lookahead u_t angles (deg): "
          f"{[np.degrees(np.arctan2(ut[1], ut[0])) % 360 for ut in u]}")
    print(f"  M_Nes @ u_t (target projections) angles (deg): "
          f"{[np.degrees(np.arctan2(v[1], v[0])) % 360 for v in V]}")
