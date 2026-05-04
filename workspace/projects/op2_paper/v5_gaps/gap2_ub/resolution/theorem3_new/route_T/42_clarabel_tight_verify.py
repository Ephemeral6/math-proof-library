"""Plan A success: CLARABEL with tol=1e-12 gives M_min_eig ≈ -1e-5 (was -1e-3 at default).

Re-extract certificates at all key points, verify V_{t+1} - V_t numerically.
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).parent))
import warnings; warnings.filterwarnings("ignore")
import numpy as np
import cvxpy as cp
import sympy as sp


def build_lookahead_lmi_tight(L_val, beta_val, eta_val, fix_alpha=1.0, minimize="C"):
    """1-step lookahead LMI with CLARABEL high-precision (tol=1e-12)."""
    g_tp1, g_t, g_p1, g_p2 = sp.symbols("g_tp1 g_t g_p1 g_p2", real=True)
    X_t, X_p1, X_p2 = sp.symbols("X_t X_p1 X_p2", real=True)
    FE_tp1, FE_t, FE_p1, FE_p2 = sp.symbols("FE_tp1 FE_t FE_p1 FE_p2", real=True)
    a0, a1, a2 = sp.symbols("a0 a1 a2", real=True)
    c01, c02, c12 = sp.symbols("c01 c02 c12", real=True)
    W, alpha = sp.symbols("W alpha", real=True)
    L = sp.S(L_val); beta = sp.S(beta_val); eta = sp.S(eta_val)
    half_inv_L = sp.Rational(1, 2) / L
    dy_t = -eta * g_t + beta * (X_t - X_p1)
    X_tp1 = X_t + dy_t
    V_t = (a0 * X_t**2 + a1 * X_p1**2 + a2 * X_p2**2
           + c01 * X_t * X_p1 + c02 * X_t * X_p2 + c12 * X_p1 * X_p2)
    Q_next = (a0 * X_tp1**2 + a1 * X_t**2 + a2 * X_p1**2
              + c01 * X_tp1 * X_t + c02 * X_tp1 * X_p1 + c12 * X_t * X_p1)
    diff = sp.expand(W * FE_tp1 - (W - alpha) * FE_t + Q_next - V_t)
    G = {}
    G["S"] = FE_t - FE_tp1 + g_t * dy_t + sp.Rational(1, 2) * L * dy_t**2
    G["S_back"] = FE_tp1 - FE_t + g_tp1 * (-dy_t) + sp.Rational(1, 2) * L * dy_t**2
    G["IV_tp1"] = g_tp1 * X_tp1 - FE_tp1 - half_inv_L * g_tp1**2
    G["IV_t"]   = g_t   * X_t   - FE_t   - half_inv_L * g_t**2
    G["IV_p1"]  = g_p1  * X_p1  - FE_p1  - half_inv_L * g_p1**2
    G["IV_p2"]  = g_p2  * X_p2  - FE_p2  - half_inv_L * g_p2**2
    anchors = [("tp1", g_tp1, X_tp1, FE_tp1),
               ("t",   g_t,   X_t,   FE_t),
               ("p1",  g_p1,  X_p1,  FE_p1),
               ("p2",  g_p2,  X_p2,  FE_p2)]
    for ni, gi, Xi, Fi in anchors:
        for nj, gj, Xj, Fj in anchors:
            if ni == nj: continue
            G[f"C_{ni}_{nj}"] = (Fi - Fj) - gj * (Xi - Xj) - half_inv_L * (gi - gj)**2
    a0_v = cp.Variable(); a1_v = cp.Variable(); a2_v = cp.Variable()
    c01_v = cp.Variable(); c02_v = cp.Variable(); c12_v = cp.Variable()
    W_v = cp.Variable(nonneg=True)
    alpha_v = cp.Constant(float(fix_alpha))
    lam = {name: cp.Variable(nonneg=True) for name in G.keys()}
    lam_syms = {name: sp.symbols(f"lam_{name}", real=True) for name in G.keys()}
    pos_combo = sp.expand(diff)
    for name, gen in G.items(): pos_combo = sp.expand(pos_combo + lam_syms[name] * gen)
    poly_vars = [FE_tp1, FE_t, FE_p1, FE_p2, g_tp1, g_t, g_p1, g_p2, X_t, X_p1, X_p2]
    poly = sp.Poly(pos_combo, *poly_vars)
    FE_list = [FE_tp1, FE_t, FE_p1, FE_p2]
    other_list = [g_tp1, g_t, g_p1, g_p2, X_t, X_p1, X_p2]
    sym_to_cp = {a0: a0_v, a1: a1_v, a2: a2_v,
                 c01: c01_v, c02: c02_v, c12: c12_v,
                 W: W_v, alpha: alpha_v}
    for name in G.keys(): sym_to_cp[lam_syms[name]] = lam[name]
    def s2c(expr):
        expr = sp.expand(expr)
        if expr == 0: return cp.Constant(0.0)
        terms = expr.as_ordered_terms() if expr.is_Add else [expr]
        out = cp.Constant(0.0)
        for term in terms:
            const_part = sp.S(1); cv_factor = None
            for f in term.as_ordered_factors():
                if f in sym_to_cp:
                    if cv_factor is None: cv_factor = sym_to_cp[f]
                    else: raise RuntimeError(f"Bilinear: {term}")
                else: const_part = const_part * f
            cv = float(const_part)
            if cv_factor is None: out = out + cp.Constant(cv)
            else: out = out + cv * cv_factor
        return out
    constraints = []
    monoms_zero = list(FE_list)
    for fe in FE_list:
        for v in other_list: monoms_zero.append(fe * v)
    for i in range(len(FE_list)): monoms_zero.append(FE_list[i]**2)
    for i in range(len(FE_list)):
        for j in range(i+1, len(FE_list)): monoms_zero.append(FE_list[i] * FE_list[j])
    for mm in monoms_zero:
        try: cf = poly.coeff_monomial(mm)
        except: cf = sp.S(0)
        cf = sp.expand(cf)
        if cf == 0: continue
        constraints.append(s2c(cf) == 0)
    n = len(other_list)
    M = cp.Variable((n, n), symmetric=True)
    for i in range(n):
        for j in range(i, n):
            mon = other_list[i]**2 if i == j else other_list[i] * other_list[j]
            cf = sp.expand(poly.coeff_monomial(mon))
            if i == j: constraints.append(M[i, i] == -s2c(cf))
            else:
                constraints.append(M[i, j] == -s2c(cf) / 2)
                constraints.append(M[j, i] == -s2c(cf) / 2)
    constraints.append(M >> 0)
    constraints.append(W_v >= alpha_v)
    Q_mat = cp.bmat([[a0_v, c01_v / 2, c02_v / 2],
                     [c01_v / 2, a1_v, c12_v / 2],
                     [c02_v / 2, c12_v / 2, a2_v]])
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
        # TIGHT TOLERANCES
        prob.solve(solver=cp.CLARABEL, verbose=False,
                   tol_gap_abs=1e-12, tol_gap_rel=1e-12, tol_feas=1e-12,
                   tol_infeas_abs=1e-12, tol_infeas_rel=1e-12,
                   max_iter=10000)
    except Exception as e:
        return {"status": f"err: {str(e)[:60]}", "W": None,
                "a0": None, "a1": None, "a2": None,
                "c01": None, "c02": None, "c12": None}
    out = {"status": prob.status,
           "W": float(W_v.value) if W_v.value is not None else None}
    for nm, vr in [("a0", a0_v),("a1", a1_v),("a2", a2_v),
                    ("c01", c01_v),("c02", c02_v),("c12", c12_v)]:
        out[nm] = float(vr.value) if vr.value is not None else None
    if out["a0"] is not None:
        out["S"] = sum(out[k] for k in ["a0","a1","a2","c01","c02","c12"])
        out["C_Lya"] = (out["W"] - 1.0) * (L_val / 2.0) + out["S"]
        out["M_min_eig"] = float(np.linalg.eigvalsh(M.value)[0])
    return out


def numerical_violation(L, beta, eta, cert):
    a0, a1, a2 = cert["a0"], cert["a1"], cert["a2"]
    c01, c02, c12 = cert["c01"], cert["c02"], cert["c12"]
    W = cert["W"]; w0 = W - 1.0
    x0 = 1.0
    xs = [x0, x0]
    for t in range(200):
        x_new = xs[-1] * (1 - eta * L + beta) - beta * xs[-2]
        xs.append(x_new)
    xs = np.array(xs[1:])
    Vs = []
    for t in range(len(xs)):
        x_t = xs[t]; x_tm1 = xs[max(0, t-1)]; x_tm2 = xs[max(0, t-2)]
        f_val = 0.5 * L * x_t**2
        Q = (a0 * x_t**2 + a1 * x_tm1**2 + a2 * x_tm2**2
             + c01 * x_t * x_tm1 + c02 * x_t * x_tm2 + c12 * x_tm1 * x_tm2)
        Vs.append((w0 + 1.0 * t) * f_val + Q)
    Vs = np.array(Vs)
    return {"max_V_violation": float(np.max(np.diff(Vs[2:]))),
            "max_V": float(np.max(np.abs(Vs)))}


def main():
    L = 1.0
    print("=" * 100)
    print("Plan A success: CLARABEL tol=1e-12 — re-verify all key points")
    print("=" * 100)
    print(f"\n{'point':>30} {'status':>22} {'C_old':>10} {'C_new':>10} {'M_min_old':>14} {'M_min_new':>14} {'V_viol_old':>14} {'V_viol_new':>14}")
    print("-" * 130)

    # Old certificates from Audit 2 (default tolerance)
    old_data = {
        ("0.5", "0.3"): {"C": 0.833, "M_min": -3.07e-7, "V_viol": 9.85e-4},
        ("0.7", "0.15"): {"C": 1.715, "M_min": -1.28e-1, "V_viol": 5.58e-3},
        ("0.9", "0.02"): {"C": 5.800, "M_min": None, "V_viol": 4.73e-2},
        ("0.95", "0.02"): {"C": 12.084, "M_min": -7.79e-3, "V_viol": 2.55e-1},
        ("0.97", "0.025"): {"C": 26.99, "M_min": -1.76e+0, "V_viol": 6.92e-1},
        ("0.978", "0.02"): {"C": 39.61, "M_min": None, "V_viol": 8.86e-1},
    }

    points = [(0.5, 0.3), (0.7, 0.15), (0.9, 0.02),
              (0.95, 0.02), (0.97, 0.025), (0.978, 0.02)]
    for beta, eta in points:
        r = build_lookahead_lmi_tight(L, beta, eta)
        if r.get("a0") is None:
            print(f"  β={beta}, η={eta}: tight LMI failed")
            continue
        v = numerical_violation(L, beta, eta, r)
        old = old_data.get((str(beta), str(eta)), {})
        print(f"β={beta:.3f},η={eta:>5}  {r['status']:>22} "
              f"{old.get('C', 0):>10.3f} {r['C_Lya']:>10.3f} "
              f"{old.get('M_min', 0) or 0:>14.3e} {r.get('M_min_eig', 0):>14.3e} "
              f"{old.get('V_viol', 0):>14.3e} {v['max_V_violation']:>14.3e}")


if __name__ == "__main__":
    main()
