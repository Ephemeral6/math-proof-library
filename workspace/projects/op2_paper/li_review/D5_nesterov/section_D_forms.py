"""
Section D: Try Sutskever / PyTorch-style NAG and verify same conclusion.

Form 1 (canonical, used in first pass):
   y_t = x_t + beta(x_t - x_{t-1})
   x_{t+1} = y_t - eta * grad f(y_t)

Form 2 (Sutskever / PyTorch SGD-with-Nesterov):
   v_{t+1} = beta * v_t - eta * grad f(x_t + beta * v_t)
   x_{t+1} = x_t + v_{t+1}

Show that on f_0 with cycling-init these produce the same iterate sequence
(or differ by a known shift), and the qualitative conclusion is identical.
"""

import numpy as np
from section_C_nag_polytope import R, project_onto_polygon, order_ccw, construct_M_HB


def make_f0_setup(beta, eta_L, mu_L, K, D=1.0):
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
    return e, lam, eta, grad, fval


def run_form1(beta, eta_L, mu_L, K, T, D=1.0):
    """Canonical NAG: y_t = x_t + beta(x_t - x_{t-1})."""
    e, lam, eta, grad, fval = make_f0_setup(beta, eta_L, mu_L, K, D)
    x_prev = lam * e[(K - 1) % K]
    x_curr = lam * e[0]
    norms = [np.linalg.norm(x_curr)]
    for t in range(T):
        y_t = x_curr + beta * (x_curr - x_prev)
        x_next = y_t - eta * grad(y_t)
        x_prev, x_curr = x_curr, x_next
        norms.append(np.linalg.norm(x_curr))
        if norms[-1] > 1e30:
            break
    return norms, x_curr, fval(x_curr)


def run_form2(beta, eta_L, mu_L, K, T, D=1.0):
    """Sutskever NAG: v_{t+1} = beta v_t - eta grad(x_t + beta v_t); x_{t+1} = x_t + v_{t+1}."""
    e, lam, eta, grad, fval = make_f0_setup(beta, eta_L, mu_L, K, D)
    # Cycling-init: we want effective initial state to match Form 1.
    # In Form 1, (x_{-1}, x_0) = (lam e_{K-1}, lam e_0). Form 1's first iterate:
    #   y_0 = x_0 + beta(x_0 - x_{-1}) = lam[(1+beta)e_0 - beta e_{K-1}]
    # In Form 2, we need v_0 such that x_0 + beta v_0 = y_0, so v_0 = (x_0 - x_{-1}).
    x_curr = lam * e[0].copy()
    v = lam * (e[0] - e[(K - 1) % K])
    norms = [np.linalg.norm(x_curr)]
    for t in range(T):
        x_p_beta_v = x_curr + beta * v
        v = beta * v - eta * grad(x_p_beta_v)
        x_curr = x_curr + v
        norms.append(np.linalg.norm(x_curr))
        if norms[-1] > 1e30:
            break
    return norms, x_curr, fval(x_curr)


def analyze_orbit(norms, tail=60):
    tail_norms = norms[-tail:]
    if any(np.isinf(n) or np.isnan(n) for n in tail_norms):
        return "inf/nan", None
    if max(tail_norms) > 1e15:
        return "divergent", max(tail_norms)
    if max(tail_norms) - min(tail_norms) < 1e-10:
        return "period-1", np.mean(tail_norms)
    even = tail_norms[::2]; odd = tail_norms[1::2]
    if max(even) - min(even) < 1e-9 and max(odd) - min(odd) < 1e-9:
        return "period-2", (np.mean(odd), np.mean(even))
    return "other", (min(tail_norms), max(tail_norms))


if __name__ == "__main__":
    cases = [
        (0.5, 3.0, 0.250, 3),
        (0.7, 2.9, 0.337, 3),
        (0.9, 3.5, 0.398, 3),
    ]

    print("Section D — Form 1 (canonical) vs Form 2 (Sutskever/PyTorch) on f_0")
    print("=" * 70)
    for beta, eta_L, mu_L, K in cases:
        print(f"\n(beta={beta}, eta*L={eta_L}, mu/L={mu_L}, K={K})")
        for T in [500, 2000]:
            n1, xT1, f1 = run_form1(beta, eta_L, mu_L, K, T)
            n2, xT2, f2 = run_form2(beta, eta_L, mu_L, K, T)
            kind1, info1 = analyze_orbit(n1)
            kind2, info2 = analyze_orbit(n2)
            print(f"  T={T:5d}:")
            print(f"    Form 1: |x_T|={np.linalg.norm(xT1):.4e}, f={f1:.4e}, "
                  f"{kind1}, {info1}")
            print(f"    Form 2: |x_T|={np.linalg.norm(xT2):.4e}, f={f2:.4e}, "
                  f"{kind2}, {info2}")
