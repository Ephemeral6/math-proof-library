"""Route T, step #10: Diagnostic — verify the 2-step LMI with FIXED standard Lyapunov.

Set the Lyapunov to V_t = w_t (f-f*) + (L/2) ||y - y*||^2.
i.e., a_0 = L/2, a_1 = a_2 = 0, c_01 = c_02 = c_12 = 0, alpha = 1 (per-step weight increment).
For one-step descent V_{t+1} <= V_t, we should be able to verify by hand.

We will:
1. Run the LMI with these Lyapunov coefficients FIXED (only duals free).
2. Check feasibility: at α = 1, what is the minimum W = w_{t+1}?

If the LMI returns infeasible, my construction has a bug.
If it returns finite W: the LMI is correct, and we need a different Lyapunov class.
"""
from pathlib import Path
import json
import numpy as np
import cvxpy as cp
import sympy as sp


def diagnostic_lmi(L_val, beta_val, eta_val, a0_val, a1_val, a2_val,
                   c01_val, c02_val, c12_val, alpha_val):
    """Given fixed Lyapunov coefficients and alpha, find the smallest feasible W."""
    g_t, g_p1, g_p2 = sp.symbols("g_t g_p1 g_p2", real=True)
    X_t, X_p1, X_p2 = sp.symbols("X_t X_p1 X_p2", real=True)
    FE_t, FE_p1, FE_p2 = sp.symbols("FE_t FE_p1 FE_p2", real=True)
    W = sp.symbols("W", real=True)

    L, beta, eta = sp.S(L_val), sp.S(beta_val), sp.S(eta_val)
    a0, a1, a2 = sp.S(a0_val), sp.S(a1_val), sp.S(a2_val)
    c01, c02, c12 = sp.S(c01_val), sp.S(c02_val), sp.S(c12_val)
    alpha = sp.S(alpha_val)

    dy_t = -eta * g_t + beta * (X_t - X_p1)
    X_t1 = X_t + dy_t

    V_t = (a0 * X_t ** 2 + a1 * X_p1 ** 2 + a2 * X_p2 ** 2
           + c01 * X_t * X_p1 + c02 * X_t * X_p2 + c12 * X_p1 * X_p2)
    Q_next = (a0 * X_t1 ** 2 + a1 * X_t ** 2 + a2 * X_p1 ** 2
              + c01 * X_t1 * X_t + c02 * X_t1 * X_p1 + c12 * X_t * X_p1)

    diff = sp.expand(alpha * FE_t + W * (g_t * dy_t + sp.Rational(1, 2) * L * dy_t ** 2)
                     + Q_next - V_t)

    half_inv_L = sp.Rational(1, 2) / L
    G = {}
    G["IV_t"]  = g_t * X_t   - FE_t   - half_inv_L * g_t ** 2
    G["IV_p1"] = g_p1 * X_p1 - FE_p1  - half_inv_L * g_p1 ** 2
    G["IV_p2"] = g_p2 * X_p2 - FE_p2  - half_inv_L * g_p2 ** 2
    G["C_t_p1"]   = (FE_t - FE_p1) - g_p1 * (X_t - X_p1)   - half_inv_L * (g_t - g_p1) ** 2
    G["C_p1_t"]   = (FE_p1 - FE_t) - g_t * (X_p1 - X_t)    - half_inv_L * (g_p1 - g_t) ** 2
    G["C_p1_p2"]  = (FE_p1 - FE_p2) - g_p2 * (X_p1 - X_p2) - half_inv_L * (g_p1 - g_p2) ** 2
    G["C_p2_p1"]  = (FE_p2 - FE_p1) - g_p1 * (X_p2 - X_p1) - half_inv_L * (g_p2 - g_p1) ** 2
    G["C_t_p2"]   = (FE_t - FE_p2) - g_p2 * (X_t - X_p2)   - half_inv_L * (g_t - g_p2) ** 2
    G["C_p2_t"]   = (FE_p2 - FE_t) - g_t * (X_p2 - X_t)    - half_inv_L * (g_p2 - g_t) ** 2

    W_v = cp.Variable(nonneg=True)
    lam = {name: cp.Variable(nonneg=True) for name in G.keys()}
    lam_syms = {name: sp.symbols(f"lam_{name}", real=True) for name in G.keys()}
    pos_combo = sp.expand(diff)
    for name, gen in G.items():
        pos_combo = sp.expand(pos_combo - lam_syms[name] * gen)

    poly_vars = [FE_t, FE_p1, FE_p2, g_t, g_p1, g_p2, X_t, X_p1, X_p2]
    poly = sp.Poly(pos_combo, *poly_vars)
    FE_list = [FE_t, FE_p1, FE_p2]
    other_list = [g_t, g_p1, g_p2, X_t, X_p1, X_p2]

    sym_to_cp = {W: W_v}
    for name in G.keys():
        sym_to_cp[lam_syms[name]] = lam[name]

    def sym_to_cp_expr(expr):
        expr = sp.expand(expr)
        if expr == 0:
            return cp.Constant(0.0)
        terms = expr.as_ordered_terms() if expr.is_Add else [expr]
        out = cp.Constant(0.0)
        for term in terms:
            const_part = sp.S(1)
            cv_factor = None
            for f in term.as_ordered_factors():
                if f in sym_to_cp:
                    if cv_factor is None:
                        cv_factor = sym_to_cp[f]
                    else:
                        raise RuntimeError(f"Bilinear: {term}")
                else:
                    const_part = const_part * f
            cv = float(const_part)
            if cv_factor is None:
                out = out + cp.Constant(cv)
            else:
                out = out + cv * cv_factor
        return out

    constraints = []
    # FE coefficients = 0
    for fe in FE_list:
        cf = poly.coeff_monomial(fe)
        constraints.append(sym_to_cp_expr(sp.expand(cf)) == 0)

    # Build M PSD on (g_t, g_p1, g_p2, X_t, X_p1, X_p2).
    M = cp.Variable((6, 6), symmetric=True)
    for i in range(6):
        for j in range(i, 6):
            mon = other_list[i] ** 2 if i == j else other_list[i] * other_list[j]
            cf = sp.expand(poly.coeff_monomial(mon))
            if i == j:
                constraints.append(M[i, i] == -sym_to_cp_expr(cf))
            else:
                constraints.append(M[i, j] == -sym_to_cp_expr(cf) / 2)
                constraints.append(M[j, i] == -sym_to_cp_expr(cf) / 2)
    constraints.append(M >> 0)

    objective = cp.Minimize(W_v)
    prob = cp.Problem(objective, constraints)
    prob.solve(solver=cp.SCS, verbose=False, max_iters=50000)

    return {
        "status": prob.status,
        "W_min": float(W_v.value) if W_v.value is not None else None,
        "lambdas": {k: (float(v.value) if v.value is not None else None) for k, v in lam.items()},
    }


def main():
    L = 1.0
    print("=" * 70)
    print("Diagnostic: plain GD (β=0, η=1/L) with V_t = t(f-f*) + (L/2)||y-y*||^2")
    print("Expected: W_min = 1 (corresponds to t=0, w_0=0, w_1=1).")
    print("=" * 70)
    r = diagnostic_lmi(L, beta_val=0.0, eta_val=1.0/L,
                       a0_val=L/2, a1_val=0, a2_val=0,
                       c01_val=0, c02_val=0, c12_val=0,
                       alpha_val=1.0)
    print(f"Status: {r['status']}")
    print(f"W_min:  {r['W_min']}")
    print(f"Active duals (>1e-3):")
    for k, v in sorted(r["lambdas"].items(), key=lambda kv: -abs(kv[1] or 0)):
        if v is not None and abs(v) > 1e-3:
            print(f"  λ_{k:12s} = {v:.4f}")

    print("\n" + "=" * 70)
    print("Diagnostic: SHB at β=0.3, η=1.2/L with V_t = t(f-f*) + (L/2)||y-y*||^2")
    print("=" * 70)
    r = diagnostic_lmi(L, beta_val=0.3, eta_val=1.2/L,
                       a0_val=L/2, a1_val=0, a2_val=0,
                       c01_val=0, c02_val=0, c12_val=0,
                       alpha_val=1.0)
    print(f"Status: {r['status']}")
    print(f"W_min:  {r['W_min']}")
    print(f"Active duals (>1e-3):")
    for k, v in sorted(r["lambdas"].items(), key=lambda kv: -abs(kv[1] or 0)):
        if v is not None and abs(v) > 1e-3:
            print(f"  λ_{k:12s} = {v:.4f}")

    print("\n" + "=" * 70)
    print("Diagnostic: SHB at β=0.5, η=0.6/L with V_t = t(f-f*) + (L/2)||y-y*||^2")
    print("=" * 70)
    r = diagnostic_lmi(L, beta_val=0.5, eta_val=0.6/L,
                       a0_val=L/2, a1_val=0, a2_val=0,
                       c01_val=0, c02_val=0, c12_val=0,
                       alpha_val=1.0)
    print(f"Status: {r['status']}")
    print(f"W_min:  {r['W_min']}")
    print(f"Active duals (>1e-3):")
    for k, v in sorted(r["lambdas"].items(), key=lambda kv: -abs(kv[1] or 0)):
        if v is not None and abs(v) > 1e-3:
            print(f"  λ_{k:12s} = {v:.4f}")


if __name__ == "__main__":
    main()
