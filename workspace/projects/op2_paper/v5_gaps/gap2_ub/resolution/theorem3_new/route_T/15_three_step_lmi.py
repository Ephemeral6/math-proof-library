"""Route T, step #15: 3-state Lyapunov LMI (extending #11 by one more anchor).

State Lyapunov:
   V_t = w_t (f_t - f*)
        + a_0 ||X_t||² + a_1 ||X_{t-1}||² + a_2 ||X_{t-2}||² + a_3 ||X_{t-3}||²
        + c_01 X_t·X_{t-1} + c_02 X_t·X_{t-2} + c_03 X_t·X_{t-3}
        + c_12 X_{t-1}·X_{t-2} + c_13 X_{t-1}·X_{t-3} + c_23 X_{t-2}·X_{t-3}

Anchor set: {t, t-1, t-2, t-3}. Generators:
  - S: smoothness on f_{t+1}.
  - IV_i: tangent-from-* at i (4 generators).
  - C_{i,j}: pairwise convexity at j wrt i (12 generators, all ordered pairs).
Total: 17 generators.

Same Positivstellensatz form as #11 (CORRECTED sign):
   pos_combo = diff + Σ λ_i G_i ≤ 0 globally  ⇔ FE coefs vanish AND quadratic form NSD.

The quadratic state vector v has 8 entries: (g_t, g_p1, g_p2, g_p3, X_t, X_p1, X_p2, X_p3).
M is 8x8 PSD.
"""
from pathlib import Path
import json
import numpy as np
import cvxpy as cp
import sympy as sp


def build_diff_polynomial(L_val, beta_val, eta_val):
    g_t, g_p1, g_p2, g_p3 = sp.symbols("g_t g_p1 g_p2 g_p3", real=True)
    X_t, X_p1, X_p2, X_p3 = sp.symbols("X_t X_p1 X_p2 X_p3", real=True)
    FE_t, FE_p1, FE_p2, FE_p3, FE_t1 = sp.symbols("FE_t FE_p1 FE_p2 FE_p3 FE_t1", real=True)

    a0, a1, a2, a3 = sp.symbols("a0 a1 a2 a3", real=True)
    c01, c02, c03 = sp.symbols("c01 c02 c03", real=True)
    c12, c13, c23 = sp.symbols("c12 c13 c23", real=True)
    W, alpha = sp.symbols("W alpha", real=True)

    L = sp.S(L_val); beta = sp.S(beta_val); eta = sp.S(eta_val)

    dy_t = -eta * g_t + beta * (X_t - X_p1)
    X_t1 = X_t + dy_t

    # V_t in (X_t, X_p1, X_p2, X_p3)
    V_t = (a0 * X_t**2 + a1 * X_p1**2 + a2 * X_p2**2 + a3 * X_p3**2
           + c01 * X_t * X_p1 + c02 * X_t * X_p2 + c03 * X_t * X_p3
           + c12 * X_p1 * X_p2 + c13 * X_p1 * X_p3 + c23 * X_p2 * X_p3)

    # Q_next: V_{t+1}'s quadratic part. Shift indices: t→t+1 (=X_t1), t-1→t (=X_t),
    # t-2→t-1 (=X_p1), t-3→t-2 (=X_p2). The X_p3 anchor is dropped.
    Q_next = (a0 * X_t1**2 + a1 * X_t**2 + a2 * X_p1**2 + a3 * X_p2**2
              + c01 * X_t1 * X_t + c02 * X_t1 * X_p1 + c03 * X_t1 * X_p2
              + c12 * X_t * X_p1 + c13 * X_t * X_p2 + c23 * X_p1 * X_p2)

    diff = sp.expand(W * FE_t1 - (W - alpha) * FE_t + Q_next - V_t)

    return diff, {
        "g_t": g_t, "g_p1": g_p1, "g_p2": g_p2, "g_p3": g_p3,
        "X_t": X_t, "X_p1": X_p1, "X_p2": X_p2, "X_p3": X_p3,
        "FE_t": FE_t, "FE_p1": FE_p1, "FE_p2": FE_p2, "FE_p3": FE_p3, "FE_t1": FE_t1,
        "a0": a0, "a1": a1, "a2": a2, "a3": a3,
        "c01": c01, "c02": c02, "c03": c03,
        "c12": c12, "c13": c13, "c23": c23,
        "W": W, "alpha": alpha,
    }


def build_lmi_three_step(L_val, beta_val, eta_val, fix_alpha=1.0, minimize="W"):
    diff, S = build_diff_polynomial(L_val, beta_val, eta_val)
    L = sp.S(L_val)
    half_inv_L = sp.Rational(1, 2) / L

    g_t, g_p1, g_p2, g_p3 = S["g_t"], S["g_p1"], S["g_p2"], S["g_p3"]
    X_t, X_p1, X_p2, X_p3 = S["X_t"], S["X_p1"], S["X_p2"], S["X_p3"]
    FE_t, FE_p1, FE_p2, FE_p3, FE_t1 = S["FE_t"], S["FE_p1"], S["FE_p2"], S["FE_p3"], S["FE_t1"]
    eta_s = sp.S(eta_val); beta_s = sp.S(beta_val)
    dy_t = -eta_s * g_t + beta_s * (X_t - X_p1)

    # Generators
    G = {}
    G["S"] = FE_t - FE_t1 + g_t * dy_t + sp.Rational(1, 2) * L * dy_t**2
    G["IV_t"]  = g_t  * X_t  - FE_t  - half_inv_L * g_t**2
    G["IV_p1"] = g_p1 * X_p1 - FE_p1 - half_inv_L * g_p1**2
    G["IV_p2"] = g_p2 * X_p2 - FE_p2 - half_inv_L * g_p2**2
    G["IV_p3"] = g_p3 * X_p3 - FE_p3 - half_inv_L * g_p3**2

    # Pairwise convexity at j w.r.t. i: f_i - f_j - <g_j, x_i - x_j> - (1/2L)(g_i - g_j)^2 >= 0
    anchors = [("t", g_t, X_t, FE_t), ("p1", g_p1, X_p1, FE_p1),
               ("p2", g_p2, X_p2, FE_p2), ("p3", g_p3, X_p3, FE_p3)]
    for ni, gi, Xi, Fi in anchors:
        for nj, gj, Xj, Fj in anchors:
            if ni == nj: continue
            G[f"C_{ni}_{nj}"] = (Fi - Fj) - gj * (Xi - Xj) - half_inv_L * (gi - gj)**2

    # cvxpy variables
    a0_v = cp.Variable(); a1_v = cp.Variable(); a2_v = cp.Variable(); a3_v = cp.Variable()
    c01_v = cp.Variable(); c02_v = cp.Variable(); c03_v = cp.Variable()
    c12_v = cp.Variable(); c13_v = cp.Variable(); c23_v = cp.Variable()
    W_v = cp.Variable(nonneg=True)
    if fix_alpha is None:
        alpha_v = cp.Variable(nonneg=True)
    else:
        alpha_v = cp.Constant(float(fix_alpha))

    lam = {name: cp.Variable(nonneg=True) for name in G.keys()}
    lam_syms = {name: sp.symbols(f"lam_{name}", real=True) for name in G.keys()}

    pos_combo = sp.expand(diff)
    for name, gen in G.items():
        pos_combo = sp.expand(pos_combo + lam_syms[name] * gen)

    poly_vars = [FE_t, FE_p1, FE_p2, FE_p3, FE_t1,
                 g_t, g_p1, g_p2, g_p3, X_t, X_p1, X_p2, X_p3]
    poly = sp.Poly(pos_combo, *poly_vars)

    FE_list = [FE_t, FE_p1, FE_p2, FE_p3, FE_t1]
    other_list = [g_t, g_p1, g_p2, g_p3, X_t, X_p1, X_p2, X_p3]

    sym_to_cp = {
        S["a0"]: a0_v, S["a1"]: a1_v, S["a2"]: a2_v, S["a3"]: a3_v,
        S["c01"]: c01_v, S["c02"]: c02_v, S["c03"]: c03_v,
        S["c12"]: c12_v, S["c13"]: c13_v, S["c23"]: c23_v,
        S["W"]: W_v, S["alpha"]: alpha_v,
    }
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
                        raise RuntimeError(f"Bilinear in cvxpy variables: {term}")
                else:
                    const_part = const_part * f
            cv = float(const_part)
            if cv_factor is None:
                out = out + cp.Constant(cv)
            else:
                out = out + cv * cv_factor
        return out

    constraints = []
    # FE coefs zero: linear, FE×FE products, and FE×other products
    monoms_zero = list(FE_list)
    for fe in FE_list:
        for v in other_list:
            monoms_zero.append(fe * v)
    for i in range(len(FE_list)):
        monoms_zero.append(FE_list[i]**2)
    for i in range(len(FE_list)):
        for j in range(i+1, len(FE_list)):
            monoms_zero.append(FE_list[i] * FE_list[j])

    for m in monoms_zero:
        try:
            cf = poly.coeff_monomial(m)
        except Exception:
            cf = sp.S(0)
        cf = sp.expand(cf)
        if cf == 0:
            continue
        constraints.append(sym_to_cp_expr(cf) == 0)

    # M PSD on the 8-dim (g, X) state
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

    # Q PSD: 4x4 quadratic form in V_t over (X_t, X_p1, X_p2, X_p3)
    Q_mat = cp.bmat([
        [a0_v,        c01_v / 2,  c02_v / 2,  c03_v / 2],
        [c01_v / 2,   a1_v,       c12_v / 2,  c13_v / 2],
        [c02_v / 2,   c12_v / 2,  a2_v,       c23_v / 2],
        [c03_v / 2,   c13_v / 2,  c23_v / 2,  a3_v]
    ])
    constraints.append(Q_mat >> 0)

    # Magnitude bounds
    for v in [a0_v, a1_v, a2_v, a3_v, c01_v, c02_v, c03_v, c12_v, c13_v, c23_v]:
        constraints.append(cp.abs(v) <= 1e6)

    if minimize == "W":
        if fix_alpha is None:
            constraints.append(alpha_v == 1.0)
        objective = cp.Minimize(W_v)
    elif minimize == "C":
        # minimize C = (W-1)/2 + S where S = sum of all coefs in Q
        S_expr = a0_v + a1_v + a2_v + a3_v + c01_v + c02_v + c03_v + c12_v + c13_v + c23_v
        if fix_alpha is None:
            constraints.append(alpha_v == 1.0)
        objective = cp.Minimize((W_v - 1.0) * (L_val / 2.0) + S_expr)

    prob = cp.Problem(objective, constraints)
    # CLARABEL for tight precision. SCS gave invalid certificates ("optimal_inaccurate"
    # with C below the PEP lower bound — not a valid Lyapunov).
    prob.solve(solver=cp.CLARABEL, verbose=False)

    out = {
        "status": prob.status,
        "alpha": float(alpha_v.value) if hasattr(alpha_v, "value") and alpha_v.value is not None else (float(fix_alpha) if fix_alpha is not None else None),
        "W": float(W_v.value) if W_v.value is not None else None,
        "a0": float(a0_v.value) if a0_v.value is not None else None,
        "a1": float(a1_v.value) if a1_v.value is not None else None,
        "a2": float(a2_v.value) if a2_v.value is not None else None,
        "a3": float(a3_v.value) if a3_v.value is not None else None,
        "c01": float(c01_v.value) if c01_v.value is not None else None,
        "c02": float(c02_v.value) if c02_v.value is not None else None,
        "c03": float(c03_v.value) if c03_v.value is not None else None,
        "c12": float(c12_v.value) if c12_v.value is not None else None,
        "c13": float(c13_v.value) if c13_v.value is not None else None,
        "c23": float(c23_v.value) if c23_v.value is not None else None,
        "lambdas": {name: (float(lam[name].value) if lam[name].value is not None else None)
                    for name in G.keys()},
    }
    if out["a0"] is not None:
        out["S"] = (out["a0"] + out["a1"] + out["a2"] + out["a3"]
                    + out["c01"] + out["c02"] + out["c03"]
                    + out["c12"] + out["c13"] + out["c23"])
        out["C_Lya"] = (out["W"] - 1.0) * (L_val / 2.0) + out["S"]
    return out


def main():
    L = 1.0

    print("=" * 80)
    print("3-step LMI sanity: plain GD (β=0, η=1/L)")
    print("Expected: feasible at W = 1, C_Lya ≈ L/2 (matches plain GD's standard).")
    print("=" * 80)
    r = build_lmi_three_step(L, 0.0, 1.0/L, fix_alpha=1.0, minimize="C")
    print(f"Status: {r['status']}, W = {r['W']}, C_Lya = {r.get('C_Lya')}")

    print("\n" + "=" * 80)
    print("3-step LMI sweep: β ∈ {0.0, 0.1, ..., 0.5} × η; min C_Lya")
    print("=" * 80)
    header = f"{'beta':>5} {'eta':>5} {'status':>16} {'W':>7} {'S':>7} {'C_Lya':>7}"
    print(header); print("-" * len(header))
    rows = []
    for beta in [0.0, 0.1, 0.2, 0.3, 0.4, 0.5]:
        best = None
        best_C = float("inf")
        for eta_factor in [0.7, 1.0, 1.2, 1.5, 1.7, 2.0]:
            eta = eta_factor / L
            try:
                r = build_lmi_three_step(L, beta, eta, fix_alpha=1.0, minimize="C")
            except Exception as e:
                print(f"{beta:>5.2f} {eta:>5.2f} {'err: '+str(e)[:30]:>16}")
                continue
            row = {"beta": beta, "eta": eta, **r}
            rows.append(row)
            if r["status"] in ("optimal", "optimal_inaccurate") and r.get("C_Lya") is not None:
                C = r["C_Lya"]
                if C < best_C:
                    best_C = C
                    best = r
                print(f"{beta:>5.2f} {eta:>5.2f} {r['status']:>16} {r['W']:>7.4f} {r['S']:>7.4f} {C:>7.4f}")
            else:
                print(f"{beta:>5.2f} {eta:>5.2f} {r['status']:>16}    (no soln)")
        if best is not None:
            print(f"  → BEST for β={beta}: C_Lya = {best_C:.4f}")
        print()

    out = Path(__file__).parent / "15_three_step_lmi_results.json"
    out.write_text(json.dumps(rows, indent=2, default=str))
    print(f"Results: {out}")


if __name__ == "__main__":
    main()
