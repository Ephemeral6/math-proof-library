"""
Section A: High-precision re-check of the previous numerical claims.

The first pass used SLSQP for projection onto the Goujaud polytope.
For K=3 the polytope is a triangle, and projection has a closed form.
We re-run NAG at the same parameter triples with the closed-form projection,
at T = 500, 2000, 10000, and compare.

Result targets to verify or correct:
  - (0.5, 3.0): claimed period-2 orbit at norms {0.187, 0.919}
  - (0.7, 2.9): claimed fixed point at |x|=1.091
  - (0.9, 3.5): claimed divergence
"""

import numpy as np
from section_C_nag_polytope import R, project_onto_polygon, order_ccw, construct_M_HB


def run_NAG_on_f0(beta, eta_L, mu_L, K, T, init="cycling", D=1.0):
    L = 1.0
    mu = mu_L * L
    eta = eta_L / L
    lam = D / np.sqrt(2)
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

    if init == "cycling":
        x_prev = lam * e[(K - 1) % K]
        x_curr = lam * e[0]
    else:
        x_prev = np.zeros(2)
        x_curr = np.array([D, 0.0])

    norms = [np.linalg.norm(x_curr)]
    f_history = [fval(x_curr)]
    for t in range(T):
        y_t = x_curr + beta * (x_curr - x_prev)
        x_next = y_t - eta * grad(y_t)
        x_prev = x_curr
        x_curr = x_next
        norms.append(np.linalg.norm(x_curr))
        f_history.append(fval(x_curr))
        if np.linalg.norm(x_curr) > 1e30:
            break
    return norms, f_history, x_curr


def analyze_orbit(norms, tail=50):
    """Detect the asymptotic structure of an orbit."""
    tail_norms = norms[-tail:]
    if any(np.isinf(n) or np.isnan(n) for n in tail_norms):
        return "inf/nan", None
    if max(tail_norms) > 1e15:
        return "divergent", max(tail_norms)
    # Check period-1
    if max(tail_norms) - min(tail_norms) < 1e-10:
        return "period-1 fixed point", np.mean(tail_norms)
    # Check period-2
    even = tail_norms[::2]
    odd = tail_norms[1::2]
    if max(even) - min(even) < 1e-10 and max(odd) - min(odd) < 1e-10:
        return "period-2", (np.mean(odd), np.mean(even))
    # Check period-3
    n0 = tail_norms[::3]
    n1 = tail_norms[1::3]
    n2 = tail_norms[2::3]
    if (max(n0) - min(n0) < 1e-10 and max(n1) - min(n1) < 1e-10
            and max(n2) - min(n2) < 1e-10):
        return "period-3", (np.mean(n0), np.mean(n1), np.mean(n2))
    # Check period-6
    if len(tail_norms) >= 12:
        per6 = [tail_norms[i::6] for i in range(6)]
        if all(max(s) - min(s) < 1e-9 for s in per6):
            return "period-6", tuple(np.mean(s) for s in per6)
    return "non-periodic / chaotic", (min(tail_norms), max(tail_norms))


def analyze_x_orbit(x_history, tail=50):
    """For x trajectory directly."""
    pass


if __name__ == "__main__":
    print("=" * 75)
    print("Section A — High-precision NAG on f_0 (closed-form triangle projection)")
    print("=" * 75)

    cases = [
        (0.5, 3.0, 0.250, 3),
        (0.7, 2.9, 0.337, 3),   # match the eta = 2.9 used in first pass
        (0.9, 3.5, 0.398, 3),
    ]

    for beta, eta_L, mu_L, K in cases:
        print(f"\n--- (beta={beta}, eta*L={eta_L}, mu/L={mu_L}, K={K}) ---")
        for T in [500, 2000, 10000]:
            try:
                norms, fhist, xT = run_NAG_on_f0(beta, eta_L, mu_L, K, T)
                kind, info = analyze_orbit(norms, tail=60)
                print(f"  T={T:5d}: |x_T|={np.linalg.norm(xT):.6e}, "
                      f"f(x_T)={fhist[-1]:.6e}")
                print(f"           orbit type: {kind}, info: {info}")
                # Detailed f-history Cesaro average
                cesaro = np.mean(fhist[-200:]) if len(fhist) > 200 else np.mean(fhist)
                print(f"           Cesaro f over last 200: {cesaro:.6e}")
            except Exception as ex:
                print(f"  T={T}: error {ex}")

    # Cross-check: explicitly compute period-2 and period-1 orbits as fixed points
    print("\n" + "=" * 75)
    print("Cross-check: closed-form vs SLSQP on the same orbit")
    print("=" * 75)
    try:
        from scipy.optimize import minimize
        def slsqp_proj(p, vertices):
            V = np.array(vertices)
            K = len(vertices)
            x0 = np.mean(V, axis=0)
            cons = [{'type': 'ineq', 'fun': lambda w, i=i: w[i]} for i in range(K)] \
                 + [{'type': 'eq', 'fun': lambda w: np.sum(w) - 1.0}]
            def obj(w):
                pt = w @ V
                return np.sum((pt - p) ** 2)
            res = minimize(obj, np.ones(K) / K, method='SLSQP', constraints=cons,
                           options={'ftol': 1e-15, 'maxiter': 500})
            return res.x @ V

        # Reproduce first-pass setup at (0.5, 3.0)
        beta, eta_L, mu_L, K = 0.5, 3.0, 0.25, 3
        L_v = 1.0; mu_v = mu_L; eta_v = eta_L
        lam = 1.0 / np.sqrt(2)
        M_HB = construct_M_HB(beta, eta_L, mu_L, K)
        theta = 2 * np.pi / K
        e0 = np.array([1.0, 0.0])
        e = [np.linalg.matrix_power(R(theta), t) @ e0 for t in range(K)]
        V = [lam * (M_HB @ et) for et in e]
        V_ccw = order_ccw(V)

        # Compare: at a few test points, SLSQP vs closed-form
        print("\nTest points and projection consistency:")
        test_pts = [
            np.array([0.1, 0.1]),
            np.array([0.5, 0.5]),
            np.array([1.0, 0.0]),
            np.array([2.0, 1.5]),
            np.array([-0.4, -0.3]),
        ]
        for p in test_pts:
            cf = project_onto_polygon(p, V_ccw)
            sl = slsqp_proj(p, V_ccw)
            err = np.linalg.norm(cf - sl)
            print(f"  p={p}: closed-form={cf}, slsqp={sl}, ||diff||={err:.3e}")
    except ImportError:
        print("scipy not available for cross-check")
