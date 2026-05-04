"""Test CLARABEL solver on 2-step LMI to see if it gives cleaner results than SCS."""
from pathlib import Path
import sys
import numpy as np
sys.path.insert(0, str(Path(__file__).parent))

# Re-import the 2-step LMI builder, but solve with CLARABEL
from importlib import import_module
m = import_module("11_two_step_lmi_corrected")

# Monkeypatch: replace the SCS solve with CLARABEL.
import cvxpy as cp
import sympy as sp

def build_lmi_clarabel(L_val, beta_val, eta_val, fix_alpha=1.0, minimize="C"):
    """Same LMI as 11, but solved with CLARABEL and minimizing C directly."""
    diff, S = m.build_diff_polynomial_with_smoothness_explicit(L_val, beta_val, eta_val)
    L = sp.S(L_val)
    g_t, g_p1, g_p2 = S["g_t"], S["g_p1"], S["g_p2"]
    X_t, X_p1, X_p2 = S["X_t"], S["X_p1"], S["X_p2"]
    FE_t, FE_p1, FE_p2, FE_t1 = S["FE_t"], S["FE_p1"], S["FE_p2"], S["FE_t1"]
    half_inv_L = sp.Rational(1, 2) / L
    eta_s = sp.S(eta_val); beta_s = sp.S(beta_val)
    dy_t = -eta_s * g_t + beta_s * (X_t - X_p1)

    G = {}
    G["S"] = FE_t - FE_t1 + g_t * dy_t + sp.Rational(1, 2) * L * dy_t**2
    G["IV_t"]  = g_t  * X_t  - FE_t  - half_inv_L * g_t**2
    G["IV_p1"] = g_p1 * X_p1 - FE_p1 - half_inv_L * g_p1**2
    G["IV_p2"] = g_p2 * X_p2 - FE_p2 - half_inv_L * g_p2**2
    G["C_t_p1"]   = (FE_t - FE_p1) - g_p1 * (X_t - X_p1)   - half_inv_L * (g_t - g_p1)**2
    G["C_p1_t"]   = (FE_p1 - FE_t) - g_t * (X_p1 - X_t)    - half_inv_L * (g_p1 - g_t)**2
    G["C_p1_p2"]  = (FE_p1 - FE_p2) - g_p2 * (X_p1 - X_p2) - half_inv_L * (g_p1 - g_p2)**2
    G["C_p2_p1"]  = (FE_p2 - FE_p1) - g_p1 * (X_p2 - X_p1) - half_inv_L * (g_p2 - g_p1)**2
    G["C_t_p2"]   = (FE_t - FE_p2) - g_p2 * (X_t - X_p2)   - half_inv_L * (g_t - g_p2)**2
    G["C_p2_t"]   = (FE_p2 - FE_t) - g_t * (X_p2 - X_t)    - half_inv_L * (g_p2 - g_t)**2

    a0_v = cp.Variable(); a1_v = cp.Variable(); a2_v = cp.Variable()
    c01_v = cp.Variable(); c02_v = cp.Variable(); c12_v = cp.Variable()
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

    poly_vars = [FE_t, FE_p1, FE_p2, FE_t1, g_t, g_p1, g_p2, X_t, X_p1, X_p2]
    poly = sp.Poly(pos_combo, *poly_vars)
    FE_list = [FE_t, FE_p1, FE_p2, FE_t1]
    other_list = [g_t, g_p1, g_p2, X_t, X_p1, X_p2]

    sym_to_cp = {
        S["a0"]: a0_v, S["a1"]: a1_v, S["a2"]: a2_v,
        S["c01"]: c01_v, S["c02"]: c02_v, S["c12"]: c12_v,
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
    monoms_zero = list(FE_list)
    for fe in FE_list:
        for v in other_list:
            monoms_zero.append(fe * v)
    for i in range(4):
        monoms_zero.append(FE_list[i]**2)
    for i in range(4):
        for j in range(i+1, 4):
            monoms_zero.append(FE_list[i] * FE_list[j])

    for mm in monoms_zero:
        try:
            cf = poly.coeff_monomial(mm)
        except Exception:
            cf = sp.S(0)
        cf = sp.expand(cf)
        if cf == 0: continue
        constraints.append(sym_to_cp_expr(cf) == 0)

    M = cp.Variable((6, 6), symmetric=True)
    for i in range(6):
        for j in range(i, 6):
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
        constraints.append(cp.abs(v) <= 1e3)

    if minimize == "W":
        if fix_alpha is None:
            constraints.append(alpha_v == 1.0)
        objective = cp.Minimize(W_v)
    elif minimize == "C":
        S_expr = a0_v + a1_v + a2_v + c01_v + c02_v + c12_v
        if fix_alpha is None:
            constraints.append(alpha_v == 1.0)
        objective = cp.Minimize((W_v - 1.0) * (L_val / 2.0) + S_expr)

    prob = cp.Problem(objective, constraints)
    try:
        prob.solve(solver=cp.CLARABEL, verbose=False)
        solver_used = "CLARABEL"
    except Exception as e:
        prob.solve(solver=cp.SCS, verbose=False, eps=1e-9, max_iters=200000)
        solver_used = f"SCS-fallback ({e})"

    out = {
        "solver": solver_used,
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
    return out


def main():
    L = 1.0
    print("CLARABEL test on 2-step LMI:")
    print("-" * 60)
    cases = [
        (0.0, 1.0, "plain GD η=1/L (expect ~0.5 textbook)"),
        (0.0, 1.5, "plain GD η=1.5/L (expect lower)"),
        (0.5, 1.5, "β=0.5, η=1.5/L (PEP says ~0.24)"),
        (0.5, 0.7, "β=0.5, η=0.7/L (PEP optimal η)"),
    ]
    for beta, eta, desc in cases:
        r = build_lmi_clarabel(L, beta, eta, fix_alpha=1.0, minimize="C")
        print(f"β={beta}, η={eta}: {desc}")
        print(f"  solver={r['solver']}, status={r['status']}")
        print(f"  W={r.get('W')}, S={r.get('S')}, C_Lya={r.get('C_Lya')}")


if __name__ == "__main__":
    main()
