"""Route P, step #2: manual cvxpy SDP for SHB worst-case last-iterate, with dual extraction.

PEPit's high-level API didn't expose the duals (step 01 found 0 non-zero duals),
so we set up the SDP by hand following Taylor-Hendrickx-Glineur 2017 (Theorem 4 / Algo 4.1).

Setup
-----
- Function class: 1-smooth convex on R^infty (no SC).
- Algorithm: SHB. Iterates y_0, y_1, ..., y_T. Zero-momentum init y_{-1} = y_0.
- Recursion: y_{t+1} = y_t - eta * g_t + beta * (y_t - y_{t-1}), where g_t = nabla f(y_t).
- Initial condition: ||y_0 - x*||^2 <= D^2 (we set D=1, L=1 normalization).
- Performance metric: f(y_T) - f(x*).

Decision variables of the (primal) SDP
--------------------------------------
We collect "anchor points" x_0, x_1, ..., x_T, x_* (T+2 points). For each anchor we have a
function value f_i and a gradient g_i = nabla f(x_i). At x_* we set g_* = 0.

Define the vector P = [g_0, ..., g_T, x_0 - x_*] (length T+2, each entry conceptually a vector;
in the SDP we work with the Gram matrix G in S^{T+2}, G_{ij} = <P_i, P_j>).

The iterate x_t can be expressed as a linear combination of g's and x_0 - x_*:
   x_t - x_* = (x_0 - x_*) - eta * sum_{s in chain} c_{t,s} g_s
For SHB, the coefficients satisfy:
   x_0 = x_0,                         coeffs c_0 = 0
   x_1 - x_0 = -eta g_0,              c_1 = (eta, 0, ..., 0)
   x_{t+1} - x_t = -eta g_t + beta (x_t - x_{t-1})
   so coeffs of g_s in (x_{t+1} - x_t) = -eta * 1{s=t} + beta * (coeffs in x_t - x_{t-1})

Function-value variables F = [f_0 - f*, ..., f_T - f*] (length T+1) directly enter the
constraints linearly.

Constraints
-----------
Interpolation conditions (Theorem 4, THG 2017): for every i, j in {0,...,T,*},
   f_i - f_j - <g_j, x_i - x_j> >= (1/(2L)) * ||g_i - g_j||^2.
With f_* = 0 and g_* = 0, these become quadratic forms in P (encoded via the Gram matrix G).

Plus initial condition ||x_0 - x*||^2 <= 1 i.e. G[T+1, T+1] <= 1 (with our convention that the
last entry of P is x_0 - x_*).

Objective
---------
Maximize f_T (= f(x_T) - f*) over (G PSD) and (F real) subject to interpolation.

The dual SDP gives Lagrange multipliers lambda_{ij} on each interpolation constraint,
which are the Lyapunov coefficients: any feasible dual provides a valid worst-case bound,
and the optimal dual gives the exact PEP rate.

Output
------
1. Primal optimum tau = max f_T (compare against PEPit's value)
2. Dual variables lambda_{ij} (the matrix of multipliers on interpolation constraints).
3. Display the structurally important duals (sorted by magnitude).

Sanity: at beta=0, eta=1/L, T=5, optimal lambda's should reproduce DT2014's chain Lyapunov.
"""
from pathlib import Path
import json
import numpy as np
import cvxpy as cp

np.set_printoptions(precision=4, suppress=True, linewidth=180)


def shb_iterate_coeffs(beta, eta, T):
    """Return c in R^{(T+1) x (T+1)} where x_t - x_0 = sum_s c[t,s] * g_s.

    c is signed: c[t, s] is negative for SHB (steps point downhill).

    Increments delta[t, :] = coeffs of g_s in (x_t - x_{t-1}), with x_{-1} = x_0:
        delta[0] = 0
        delta[t+1] = beta * delta[t] + (-eta) * e_t

    Then c[t, :] = sum_{r=0}^{t} delta[r, :].
    """
    delta = np.zeros((T + 1, T + 1))
    for t in range(0, T):
        delta[t + 1] = beta * delta[t]
        delta[t + 1, t] += -eta
    c = np.cumsum(delta, axis=0)
    return c


def primal_pep_shb(L, beta, eta, T, verbose=False):
    """Set up and solve the primal PEP SDP for SHB worst-case f(x_T) - f*.

    Variables:
      - G in S^{N} PSD,   N = T + 2  (anchor points: x_0, x_1, ..., x_T plus x_*-relative direction)
        Convention: P = [g_0, g_1, ..., g_T, x_0 - x_*]. Len = T+2.
      - F = [f_0 - f*, f_1 - f*, ..., f_T - f*] real (length T+1).
        f_* = 0 always.

    All linear functionals on x_t - x_* are expressed as e_x0_minus_xs - sum_s c[t,s] e_{g_s}.
    Quadratic forms <a, b> = a^T G b.
    """
    N = T + 2
    c = shb_iterate_coeffs(beta, eta, T)  # (T+1) x (T+1)

    # Index helpers
    def e_g(s):
        v = np.zeros(N); v[s] = 1.0; return v
    def e_x0_xs():
        v = np.zeros(N); v[T + 1] = 1.0; return v
    def e_xt_xs(t):
        # x_t - x* = (x_0 - x*) + (x_t - x_0) = e_x0_xs + sum_s c[t,s] e_g(s)
        v = e_x0_xs()
        for s in range(T + 1):
            v[s] += c[t, s]
        return v

    # f_i - f* for i=0..T are F[i]; f_* = 0 separately.
    G = cp.Variable((N, N), symmetric=True)
    F = cp.Variable(T + 1)

    constraints = [G >> 0]
    # initial condition <x_0 - x*, x_0 - x*> <= 1
    e0 = e_x0_xs()
    constraints.append(cp.quad_form(e0, cp.psd_wrap(G)) <= 1)

    # Index pair labels for interpolation constraints
    # Order anchors: 0, 1, ..., T (these are x_0, ..., x_T), and "*" denoted by T+1.
    pair_labels = []  # list of (i, j) anchor labels with i!=j; '*' is index T+1.

    def feature_for_anchor(idx):
        # returns (g_vec, x_vec, f_val) where g_vec is the linear functional for nabla f(x_idx),
        # x_vec is the linear functional for x_idx - x_*, f_val is the scalar f_idx - f_*.
        if idx <= T:
            g_vec = e_g(idx)
            x_vec = e_xt_xs(idx)
            f_val = F[idx]
        else:
            g_vec = np.zeros(N)
            x_vec = np.zeros(N)
            f_val = cp.Constant(0.0)
        return g_vec, x_vec, f_val

    def interp_lhs_quad(i_label, j_label):
        # Returns:  f_i - f_j - <g_j, x_i - x_j> - (1/(2L)) ||g_i - g_j||^2
        # which must be >= 0.
        gi, xi, fi = feature_for_anchor(i_label)
        gj, xj, fj = feature_for_anchor(j_label)
        # <g_j, x_i - x_j>:
        diff_x = xi - xj
        inner = sum(gj[a] * diff_x[a] for a in range(N))   # this is a vector of coefficients
        # The "<gj, xi - xj>" maps to <gj_vec, xi_minus_xj_vec> in the Gram inner product
        inner_form = 0
        for a in range(N):
            for b in range(N):
                inner_form = inner_form + gj[a] * diff_x[b] * G[a, b]
        # ||gi - gj||^2 -> quad_form(gi-gj, G)
        d = gi - gj
        quad_diff = 0
        for a in range(N):
            for b in range(N):
                quad_diff = quad_diff + d[a] * d[b] * G[a, b]
        return fi - fj - inner_form - (1.0 / (2.0 * L)) * quad_diff

    interp_constraints = []
    # All pairs i, j over anchors {0,...,T,*} with i != j
    anchors = list(range(T + 1)) + [T + 1]  # T+1 = star index
    for i in anchors:
        for j in anchors:
            if i == j:
                continue
            ineq = interp_lhs_quad(i, j) >= 0
            constraints.append(ineq)
            interp_constraints.append((i, j, ineq))
            pair_labels.append((i, j))

    # Performance: maximize F[T] = f_T - f*
    objective = cp.Maximize(F[T])
    problem = cp.Problem(objective, constraints)
    tau = problem.solve(solver=cp.SCS, verbose=verbose)

    # Extract duals (each scalar inequality in `interp_constraints` has a dual scalar).
    duals = []
    for (i, j, ineq) in interp_constraints:
        dv = ineq.dual_value
        if dv is None:
            continue
        if abs(dv) < 1e-7:
            continue
        duals.append((i, j, float(dv)))

    return tau, duals, G.value, F.value, c


def label(i_or_j, T):
    return "*" if i_or_j == T + 1 else f"x{i_or_j}"


def main():
    L = 1.0

    # Sanity: GD (beta=0, eta=1/L, T=5) -> tau = L/(4T+2) = 1/22 ~ 0.04545
    print("=" * 70)
    print("Sanity: SHB at beta=0 (GD), T=5, eta=1/L")
    print("=" * 70)
    tau, duals, G_val, F_val, c = primal_pep_shb(L, 0.0, 1.0 / L, 5, verbose=False)
    target = L / (4 * 5 + 2)
    print(f"primal tau = {tau:.6e},  predicted L/(4T+2) = {target:.6e},  "
          f"ratio = {tau/target:.4f}")

    print(f"\nNon-trivial duals on interpolation: {len(duals)} pairs")
    duals.sort(key=lambda kv: -abs(kv[2]))
    for i, j, dv in duals[:20]:
        print(f"  lambda_{{{label(i,5)}, {label(j,5)}}} = {dv:>10.5f}")

    # Now the main case: beta=0.3, T=5
    print("\n" + "=" * 70)
    print("Main: SHB at beta=0.3, T=5, eta optimal")
    print("=" * 70)
    # Try a few etas, pick the one giving max tau (worst case is sup over (f, x0); we take a small
    # eta sweep and report the best — actually for the worst-case we want max tau, but here
    # the SDP is already maximizing; we want to MINIMIZE over eta to find best-step worst-case.
    # We'll do a small grid.
    etas = [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
    best = None
    for eta in etas:
        tau, _, _, _, _ = primal_pep_shb(L, 0.3, eta, 5, verbose=False)
        print(f"  eta={eta:.2f}  tau={tau:.5e}  tau*T={tau*5:.4f}")
        if best is None or tau < best[0]:
            best = (tau, eta)
    eta_star = best[1]
    print(f"\nBest eta at beta=0.3, T=5: eta* = {eta_star}, tau = {best[0]:.5e}")

    print("\nRe-solving at eta* and extracting duals...")
    tau_star, duals, G_val, F_val, c = primal_pep_shb(L, 0.3, eta_star, 5, verbose=True)
    print(f"\ntau* = {tau_star:.5e}, tau* * T = {tau_star * 5:.4f}")

    print(f"\nNon-trivial duals on interpolation at beta=0.3, T=5, eta={eta_star}: {len(duals)} pairs")
    duals.sort(key=lambda kv: -abs(kv[2]))
    out_rows = []
    for i, j, dv in duals[:30]:
        print(f"  lambda_{{{label(i,5)}, {label(j,5)}}} = {dv:>10.5f}")
        out_rows.append({"i": int(i), "j": int(j), "dual": dv})

    out = Path(__file__).parent / "02_manual_pep_sdp_results.json"
    out.write_text(json.dumps({
        "sanity_beta0_T5_tau": float(tau),
        "predicted_LD2_4T_2": float(target),
        "main_beta03_T5_eta_star": float(eta_star),
        "main_tau_star": float(tau_star),
        "main_duals": out_rows,
    }, indent=2))
    print(f"\nResults: {out}")


if __name__ == "__main__":
    main()
