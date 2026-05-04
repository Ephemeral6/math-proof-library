"""Route B variant: 1-step lookahead LMI.

Add anchor t+1 to the generator set (was {t, t-1, t-2}, now {t+1, t, t-1, t-2}).

Lyapunov stays the same: V_t = w_t F_t + Q(X_t, X_{t-1}, X_{t-2}).

New state variable: g_{t+1} (gradient at t+1).
Note: X_{t+1} is NOT a new state — it's determined by SHB recurrence.
Note: F_{t+1} already exists.

New generators:
- IV at t+1: g_{t+1}·X_{t+1} - F_{t+1} - (1/(2L)) g_{t+1}² ≥ 0
- Convexity (t+1, j) for j ∈ {t, t-1, t-2}: 3 generators
- Convexity (i, t+1) for i ∈ {t, t-1, t-2}: 3 generators
- Smoothness from t+1 side: f_t - f_{t+1} - g_{t+1}·dy + (L/2) dy² (UB on f_t given f_{t+1}'s gradient).
  This is essentially the same as G_S but using g_{t+1}. Skip for now if complex.

Total: 1 (existing S) + 3 (existing IV) + 6 (existing pairs) + 1 (new IV at t+1) + 6 (new convexity with t+1) = 17 generators.

Quadratic state vector: (g_{t+1}, g_t, g_{t-1}, g_{t-2}, X_t, X_{t-1}, X_{t-2}). 7-dim, M is 7×7.
"""
from pathlib import Path
import sys, json
import numpy as np
import cvxpy as cp
import sympy as sp


def build_lookahead_lmi(L_val, beta_val, eta_val, fix_alpha=1.0, minimize="C"):
    g_tp1, g_t, g_p1, g_p2 = sp.symbols("g_tp1 g_t g_p1 g_p2", real=True)
    X_t, X_p1, X_p2 = sp.symbols("X_t X_p1 X_p2", real=True)
    FE_tp1, FE_t, FE_p1, FE_p2 = sp.symbols("FE_tp1 FE_t FE_p1 FE_p2", real=True)

    a0, a1, a2 = sp.symbols("a0 a1 a2", real=True)
    c01, c02, c12 = sp.symbols("c01 c02 c12", real=True)
    W, alpha = sp.symbols("W alpha", real=True)

    L = sp.S(L_val); beta = sp.S(beta_val); eta = sp.S(eta_val)
    half_inv_L = sp.Rational(1, 2) / L
    dy_t = -eta * g_t + beta * (X_t - X_p1)
    X_tp1 = X_t + dy_t  # NOT a free variable; expressed in (g_t, X_t, X_p1)

    V_t = (a0 * X_t**2 + a1 * X_p1**2 + a2 * X_p2**2
           + c01 * X_t * X_p1 + c02 * X_t * X_p2 + c12 * X_p1 * X_p2)
    Q_next = (a0 * X_tp1**2 + a1 * X_t**2 + a2 * X_p1**2
              + c01 * X_tp1 * X_t + c02 * X_tp1 * X_p1 + c12 * X_t * X_p1)

    diff = sp.expand(W * FE_tp1 - (W - alpha) * FE_t + Q_next - V_t)

    # Generators
    G = {}
    # Smoothness UB: f_t - f_{t+1} + g_t·dy_t + (L/2) dy_t² ≥ 0
    G["S"]      = FE_t - FE_tp1 + g_t * dy_t + sp.Rational(1, 2) * L * dy_t**2
    # ALSO: smoothness UB from t+1 side: f_{t+1} - f_t + g_{t+1}·(x_t - x_{t+1}) + (L/2)|x_t - x_{t+1}|^2
    G["S_back"] = FE_tp1 - FE_t + g_tp1 * (-dy_t) + sp.Rational(1, 2) * L * dy_t**2
    # IV at all anchors
    G["IV_tp1"] = g_tp1 * X_tp1 - FE_tp1 - half_inv_L * g_tp1**2
    G["IV_t"]   = g_t   * X_t   - FE_t   - half_inv_L * g_t**2
    G["IV_p1"]  = g_p1  * X_p1  - FE_p1  - half_inv_L * g_p1**2
    G["IV_p2"]  = g_p2  * X_p2  - FE_p2  - half_inv_L * g_p2**2
    # Pairwise convexity at j wrt i (4×3 = 12 ordered pairs)
    anchors = [("tp1", g_tp1, X_tp1, FE_tp1),
               ("t",   g_t,   X_t,   FE_t),
               ("p1",  g_p1,  X_p1,  FE_p1),
               ("p2",  g_p2,  X_p2,  FE_p2)]
    for ni, gi, Xi, Fi in anchors:
        for nj, gj, Xj, Fj in anchors:
            if ni == nj: continue
            G[f"C_{ni}_{nj}"] = (Fi - Fj) - gj * (Xi - Xj) - half_inv_L * (gi - gj)**2

    # cvxpy variables
    a0_v = cp.Variable(); a1_v = cp.Variable(); a2_v = cp.Variable()
    c01_v = cp.Variable(); c02_v = cp.Variable(); c12_v = cp.Variable()
    W_v = cp.Variable(nonneg=True)
    alpha_v = cp.Constant(float(fix_alpha))
    lam = {name: cp.Variable(nonneg=True) for name in G.keys()}
    lam_syms = {name: sp.symbols(f"lam_{name}", real=True) for name in G.keys()}

    pos_combo = sp.expand(diff)
    for name, gen in G.items():
        pos_combo = sp.expand(pos_combo + lam_syms[name] * gen)

    poly_vars = [FE_tp1, FE_t, FE_p1, FE_p2,
                 g_tp1, g_t, g_p1, g_p2, X_t, X_p1, X_p2]
    poly = sp.Poly(pos_combo, *poly_vars)

    FE_list = [FE_tp1, FE_t, FE_p1, FE_p2]
    other_list = [g_tp1, g_t, g_p1, g_p2, X_t, X_p1, X_p2]  # 7 vars

    sym_to_cp = {a0: a0_v, a1: a1_v, a2: a2_v,
                 c01: c01_v, c02: c02_v, c12: c12_v,
                 W: W_v, alpha: alpha_v}
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
                        raise RuntimeError(f"Bilinear in cvxpy vars: {term}")
                else:
                    const_part = const_part * f
            cv = float(const_part)
            if cv_factor is None:
                out = out + cp.Constant(cv)
            else:
                out = out + cv * cv_factor
        return out

    constraints = []
    monoms_zero = list(FE_list)
    for fe in FE_list:
        for v in other_list:
            monoms_zero.append(fe * v)
    for i in range(len(FE_list)):
        monoms_zero.append(FE_list[i]**2)
    for i in range(len(FE_list)):
        for j in range(i+1, len(FE_list)):
            monoms_zero.append(FE_list[i] * FE_list[j])

    for mm in monoms_zero:
        try:
            cf = poly.coeff_monomial(mm)
        except Exception:
            cf = sp.S(0)
        cf = sp.expand(cf)
        if cf == 0: continue
        constraints.append(sym_to_cp_expr(cf) == 0)

    n = len(other_list)
    M = cp.Variable((n, n), symmetric=True)
    for i in range(n):
        for j in range(i, n):
            mon = other_list[i]**2 if i == j else other_list[i] * other_list[j]
            cf = sp.expand(poly.coeff_monomial(mon))
            if i == j:
                constraints.append(M[i, i] == -sym_to_cp_expr(cf))
            else:
                constraints.append(M[i, j] == -sym_to_cp_expr(cf) / 2)
                constraints.append(M[j, i] == -sym_to_cp_expr(cf) / 2)

    constraints.append(M >> 0)
    constraints.append(W_v >= alpha_v)
    Q_mat = cp.bmat([
        [a0_v,        c01_v / 2,  c02_v / 2],
        [c01_v / 2,   a1_v,       c12_v / 2],
        [c02_v / 2,   c12_v / 2,  a2_v     ]
    ])
    constraints.append(Q_mat >> 0)
    for v in [a0_v, a1_v, a2_v, c01_v, c02_v, c12_v]:
        constraints.append(cp.abs(v) <= 1e6)

    if minimize == "C":
        S_expr = a0_v + a1_v + a2_v + c01_v + c02_v + c12_v
        objective = cp.Minimize((W_v - 1.0) * (L_val / 2.0) + S_expr)
    elif minimize == "W":
        objective = cp.Minimize(W_v)

    prob = cp.Problem(objective, constraints)
    try:
        prob.solve(solver=cp.CLARABEL, verbose=False)
    except Exception as e:
        return {"status": f"clarabel_error: {str(e)[:60]}",
                "W": None, "a0": None, "a1": None, "a2": None,
                "c01": None, "c02": None, "c12": None}

    out = {
        "status": prob.status,
        "W": float(W_v.value) if W_v.value is not None else None,
        "a0": float(a0_v.value) if a0_v.value is not None else None,
        "a1": float(a1_v.value) if a1_v.value is not None else None,
        "a2": float(a2_v.value) if a2_v.value is not None else None,
        "c01": float(c01_v.value) if c01_v.value is not None else None,
        "c02": float(c02_v.value) if c02_v.value is not None else None,
        "c12": float(c12_v.value) if c12_v.value is not None else None,
    }
    if out["a0"] is not None:
        out["S"] = (out["a0"] + out["a1"] + out["a2"] + out["c01"] + out["c02"] + out["c12"])
        out["C_Lya"] = (out["W"] - 1.0) * (L_val / 2.0) + out["S"]
        out["lambdas"] = {name: (float(lam[name].value) if lam[name].value is not None else None)
                          for name in G.keys()}
    return out


def main():
    L = 1.0
    print("=" * 80)
    print("1-step lookahead LMI: add anchor at t+1.")
    print("=" * 80)
    print()

    # Sanity: β=0 (plain GD)
    print("Sanity: β=0, η=1.5/L (expect C ≈ 0.333)")
    r = build_lookahead_lmi(L, 0.0, 1.5, fix_alpha=1.0, minimize="C")
    print(f"  status={r['status']}, W={r.get('W')}, S={r.get('S')}, C={r.get('C_Lya')}")
    print()

    print("Sanity: β=0.5, η=0.5/L (2-step gives C=0.999)")
    r = build_lookahead_lmi(L, 0.5, 0.5, fix_alpha=1.0, minimize="C")
    print(f"  status={r['status']}, W={r.get('W')}, S={r.get('S')}, C={r.get('C_Lya')}")
    print()

    # Boundary sweep: track feasibility past β=0.957
    print("Boundary sweep: β ∈ [0.95, 0.99] step 0.01")
    for beta in [0.95, 0.96, 0.97, 0.98, 0.99]:
        best = None
        for eta in [0.005, 0.008, 0.01, 0.015, 0.02, 0.025, 0.03, 0.04, 0.05, 0.07, 0.10]:
            r = build_lookahead_lmi(L, beta, eta, fix_alpha=1.0, minimize="C")
            s = r.get('status'); C = r.get('C_Lya')
            if s in ("optimal", "optimal_inaccurate") and C is not None:
                if best is None or C < best[0]:
                    best = (C, r.get('W'), eta, s)
        if best:
            print(f"  β={beta:.3f}: best C={best[0]:.4f} at η={best[2]:.3f}, W={best[1]:.2f}, status={best[3]}")
        else:
            print(f"  β={beta:.3f}: NO FEASIBLE η found")


if __name__ == "__main__":
    main()
