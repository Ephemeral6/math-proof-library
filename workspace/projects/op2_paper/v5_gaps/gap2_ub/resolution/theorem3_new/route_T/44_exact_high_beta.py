"""Step 44: Exact rational certificates for Theorem 3 at HIGH beta (>0.5).

Baseline LMI (k=0) is infeasible above beta=0.5, so we use the 1-step LOOKAHEAD
LMI from 26_lookahead_lmi.py, which adds anchor t+1 (gradient g_{t+1}).

This script proceeds in three phases:

  Phase 1 -- INSPECT: solve the lookahead LMI numerically (CLARABEL high
             precision) at beta in {0.6, 0.7, 0.8, 0.9} and report which
             dual multipliers and Lyapunov coefficients are active. The
             goal is to find a SPARSE structure (few non-zero generators)
             we can leverage in Phase 2.

  Phase 2 -- PARAMETRIC: with the active-multiplier ansatz, build a small
             parametric M(beta, eta, free_vars) symbolically. The resulting
             (g, X)-quadratic form may live in a smaller subspace than 7x7.

  Phase 3 -- EXACT QQ SOLVE: for each rational beta, look for rational
             (a, c, lambda) satisfying M >= 0. Use:
              (a) closed-form rank-1 ansatz (M = u u^T) when applicable,
              (b) Sylvester / principal-minor inequalities solved via
                  SymPy reduce_rational_inequalities,
              (c) round CLARABEL output then verify in QQ.

The verification matches 40_exact_certificate.py: FE identities exact in QQ
(by construction via FE-elimination), Q PSD in QQ, M PSD in QQ.
"""
from pathlib import Path
import sys
import json
import warnings
sys.path.insert(0, str(Path(__file__).parent))
warnings.filterwarnings("ignore")
from fractions import Fraction
import sympy as sp
import cvxpy as cp


# ---------------------------------------------------------------------------
# Lookahead-LMI: numerical solve with high-precision CLARABEL
# ---------------------------------------------------------------------------

def lookahead_lmi_float(L_val, beta_val, eta_val, fix_alpha=1.0,
                        minimize="C", tol=1e-12):
    g_tp1, g_t, g_p1, g_p2 = sp.symbols("g_tp1 g_t g_p1 g_p2", real=True)
    X_t, X_p1, X_p2 = sp.symbols("X_t X_p1 X_p2", real=True)
    FE_tp1, FE_t, FE_p1, FE_p2 = sp.symbols("FE_tp1 FE_t FE_p1 FE_p2", real=True)
    a0, a1, a2 = sp.symbols("a0 a1 a2", real=True)
    c01, c02, c12 = sp.symbols("c01 c02 c12", real=True)
    W_s = sp.Symbol("W", real=True)
    alpha_s = sp.Symbol("alpha", real=True)

    L = sp.S(L_val); beta = sp.S(beta_val); eta = sp.S(eta_val)
    half_inv_L = sp.Rational(1, 2) / L
    dy_t = -eta * g_t + beta * (X_t - X_p1)
    X_tp1 = X_t + dy_t

    V_t = (a0 * X_t**2 + a1 * X_p1**2 + a2 * X_p2**2
           + c01 * X_t * X_p1 + c02 * X_t * X_p2 + c12 * X_p1 * X_p2)
    Q_next = (a0 * X_tp1**2 + a1 * X_t**2 + a2 * X_p1**2
              + c01 * X_tp1 * X_t + c02 * X_tp1 * X_p1 + c12 * X_t * X_p1)
    diff = sp.expand(W_s * FE_tp1 - (W_s - alpha_s) * FE_t + Q_next - V_t)

    G = {}
    G["S"]      = FE_t - FE_tp1 + g_t * dy_t + sp.Rational(1, 2) * L * dy_t**2
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
            if ni == nj:
                continue
            G[f"C_{ni}_{nj}"] = (Fi - Fj) - gj * (Xi - Xj) - half_inv_L * (gi - gj)**2

    a0_v = cp.Variable(); a1_v = cp.Variable(); a2_v = cp.Variable()
    c01_v = cp.Variable(); c02_v = cp.Variable(); c12_v = cp.Variable()
    W_v = cp.Variable(nonneg=True)
    alpha_const = cp.Constant(float(fix_alpha))
    lam = {n: cp.Variable(nonneg=True) for n in G.keys()}
    lam_syms = {n: sp.symbols(f"lam_{n}", real=True) for n in G.keys()}

    pos_combo = sp.expand(diff)
    for n, gen in G.items():
        pos_combo = sp.expand(pos_combo + lam_syms[n] * gen)

    poly_vars = [FE_tp1, FE_t, FE_p1, FE_p2,
                 g_tp1, g_t, g_p1, g_p2, X_t, X_p1, X_p2]
    poly = sp.Poly(pos_combo, *poly_vars)
    FE_list = [FE_tp1, FE_t, FE_p1, FE_p2]
    other_list = [g_tp1, g_t, g_p1, g_p2, X_t, X_p1, X_p2]

    sym_to_cp = {a0: a0_v, a1: a1_v, a2: a2_v,
                 c01: c01_v, c02: c02_v, c12: c12_v,
                 W_s: W_v, alpha_s: alpha_const}
    for n in G.keys():
        sym_to_cp[lam_syms[n]] = lam[n]

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
    monoms_zero = list(FE_list)
    for fe in FE_list:
        for v in other_list:
            monoms_zero.append(fe * v)
    for i in range(4):
        monoms_zero.append(FE_list[i]**2)
    for i in range(4):
        for j in range(i + 1, 4):
            monoms_zero.append(FE_list[i] * FE_list[j])
    for mm in monoms_zero:
        try:
            cf = poly.coeff_monomial(mm)
        except Exception:
            cf = sp.S(0)
        cf = sp.expand(cf)
        if cf == 0:
            continue
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
    constraints.append(W_v >= float(fix_alpha))

    Q_mat = cp.bmat([
        [a0_v,        c01_v / 2,  c02_v / 2],
        [c01_v / 2,   a1_v,       c12_v / 2],
        [c02_v / 2,   c12_v / 2,  a2_v     ],
    ])
    constraints.append(Q_mat >> 0)
    for v in [a0_v, a1_v, a2_v, c01_v, c02_v, c12_v]:
        constraints.append(cp.abs(v) <= 1e6)

    S_expr = a0_v + a1_v + a2_v + c01_v + c02_v + c12_v
    if minimize == "C":
        objective = cp.Minimize((W_v - 1.0) * (L_val / 2.0) + S_expr)
    else:
        objective = cp.Minimize(W_v)

    prob = cp.Problem(objective, constraints)
    try:
        prob.solve(solver=cp.CLARABEL, verbose=False,
                   tol_gap_abs=tol, tol_gap_rel=tol, tol_feas=tol)
    except Exception as e:
        return {"status": f"err:{e}"}
    if prob.status not in ("optimal", "optimal_inaccurate"):
        return {"status": prob.status}

    out = {
        "status": prob.status,
        "W": float(W_v.value),
        "a0": float(a0_v.value), "a1": float(a1_v.value), "a2": float(a2_v.value),
        "c01": float(c01_v.value), "c02": float(c02_v.value), "c12": float(c12_v.value),
        "lambdas": {n: (float(lam[n].value) if lam[n].value is not None else None)
                    for n in G.keys()},
    }
    out["S"] = sum(out[k] for k in ["a0", "a1", "a2", "c01", "c02", "c12"])
    out["C"] = (out["W"] - 1.0) * (L_val / 2.0) + out["S"]
    return out


# ---------------------------------------------------------------------------
# PHASE 1 -- inspect active multipliers
# ---------------------------------------------------------------------------

def best_eta_for_beta(L, beta, eta_grid):
    best = None
    for eta in eta_grid:
        r = lookahead_lmi_float(L, beta, eta, fix_alpha=1.0, minimize="C")
        if r.get("status") in ("optimal", "optimal_inaccurate"):
            C = r["C"]
            if best is None or C < best["C"]:
                best = {**r, "eta": eta, "beta": beta}
    return best


def report_active(label, r, lam_thresh=1e-4, lyap_thresh=1e-4):
    print(f"\n--- {label} ---")
    print(f"  status={r['status']}, eta={r.get('eta')}, beta={r.get('beta')}")
    print(f"  W={r['W']:.4f}, C={r['C']:.4f}")
    print("  Active Lyapunov:")
    for k in ["a0", "a1", "a2", "c01", "c02", "c12"]:
        if abs(r[k]) > lyap_thresh:
            print(f"    {k:>4} = {r[k]:.6f}")
        else:
            print(f"    {k:>4} ~ 0   ({r[k]:.2e})")
    print("  Active dual multipliers (|lambda| > {:.0e}):".format(lam_thresh))
    items = sorted(r["lambdas"].items(), key=lambda kv: -abs(kv[1] or 0))
    for n, v in items:
        if v is not None and abs(v) > lam_thresh:
            print(f"    lam_{n:8s} = {v:.6f}")
    zeros = [n for n, v in items if v is None or abs(v) < lam_thresh]
    print(f"  Inactive (~0): {', '.join(zeros)}")


def phase1_inspect(L=1.0):
    print("=" * 80)
    print("PHASE 1: inspect active-multiplier structure of the lookahead LMI")
    print("=" * 80)
    cases = [
        (0.6,  [0.5, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2]),
        (0.7,  [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]),
        (0.8,  [0.15, 0.2, 0.25, 0.3, 0.4, 0.5, 0.6]),
        (0.9,  [0.05, 0.07, 0.1, 0.15, 0.2, 0.25, 0.3]),
    ]
    summary = {}
    for beta, eta_grid in cases:
        best = best_eta_for_beta(L, beta, eta_grid)
        if best is None:
            print(f"\n[beta={beta}]  no feasible eta in {eta_grid}")
            continue
        report_active(f"beta={beta} (best at eta={best['eta']})", best)
        summary[beta] = best
    return summary


# ---------------------------------------------------------------------------
# PHASE 2 -- reduced LMI with active-multiplier ansatz {S, IV_t, C_t_tp1}
# Numerically solve it with CLARABEL high precision to obtain a starting point.
# ---------------------------------------------------------------------------

ACTIVE_LAMS = ["S", "IV_t", "C_t_tp1"]


def build_diff_sym(L, beta, eta, alpha, W, a0, a1, a2, c01, c02, c12):
    """All inputs are sp.Rational (or symbolic). Returns diff polynomial and
    a dict of state-symbols (g_*, X_*, FE_*).  W and alpha may be free symbols."""
    g_tp1 = sp.Symbol("g_tp1", real=True)
    g_t   = sp.Symbol("g_t",   real=True)
    g_p1  = sp.Symbol("g_p1",  real=True)
    g_p2  = sp.Symbol("g_p2",  real=True)
    X_t   = sp.Symbol("X_t",   real=True)
    X_p1  = sp.Symbol("X_p1",  real=True)
    X_p2  = sp.Symbol("X_p2",  real=True)
    FE_tp1 = sp.Symbol("FE_tp1", real=True)
    FE_t   = sp.Symbol("FE_t",   real=True)
    FE_p1  = sp.Symbol("FE_p1",  real=True)
    FE_p2  = sp.Symbol("FE_p2",  real=True)

    dy_t = -eta * g_t + beta * (X_t - X_p1)
    X_tp1 = X_t + dy_t

    V_t = (a0 * X_t**2 + a1 * X_p1**2 + a2 * X_p2**2
           + c01 * X_t * X_p1 + c02 * X_t * X_p2 + c12 * X_p1 * X_p2)
    Q_next = (a0 * X_tp1**2 + a1 * X_t**2 + a2 * X_p1**2
              + c01 * X_tp1 * X_t + c02 * X_tp1 * X_p1 + c12 * X_t * X_p1)
    diff = sp.expand(W * FE_tp1 - (W - alpha) * FE_t + Q_next - V_t)

    S = dict(g_tp1=g_tp1, g_t=g_t, g_p1=g_p1, g_p2=g_p2,
             X_t=X_t, X_p1=X_p1, X_p2=X_p2,
             FE_tp1=FE_tp1, FE_t=FE_t, FE_p1=FE_p1, FE_p2=FE_p2)
    return diff, S, X_tp1


def build_active_generators(L, beta, eta, S, X_tp1):
    g_tp1 = S["g_tp1"]; g_t = S["g_t"]
    X_t = S["X_t"]; X_p1 = S["X_p1"]
    FE_tp1 = S["FE_tp1"]; FE_t = S["FE_t"]
    half_inv_L = sp.Rational(1, 2) / L
    dy_t = -eta * g_t + beta * (X_t - X_p1)
    G = {}
    G["S"] = FE_t - FE_tp1 + g_t * dy_t + sp.Rational(1, 2) * L * dy_t**2
    G["IV_t"] = g_t * X_t - FE_t - half_inv_L * g_t**2
    G["C_t_tp1"] = (FE_t - FE_tp1) - g_tp1 * (X_t - X_tp1) - half_inv_L * (g_t - g_tp1)**2
    return {k: sp.expand(v) for k, v in G.items()}


def reduced_lmi_fixed_lambdas(L_val, beta_val, eta_val, fix_alpha,
                              s_fixed, c_fixed, tol=1e-10):
    """Reduced LMI with the two dual multipliers s = lam_S, c = lam_C_t_tp1
    PINNED to specific (rational-valued) floats. Solves only for the 6 Lyapunov
    coefficients (a0, a1, a2, c01, c02, c12). Minimises C."""
    a0_v = cp.Variable(); a1_v = cp.Variable(); a2_v = cp.Variable()
    c01_v = cp.Variable(); c02_v = cp.Variable(); c12_v = cp.Variable()
    alpha = float(fix_alpha)
    a0_s, a1_s, a2_s = sp.symbols("a0 a1 a2", real=True)
    c01_s, c02_s, c12_s = sp.symbols("c01 c02 c12", real=True)
    L = sp.S(L_val); beta = sp.S(beta_val); eta = sp.S(eta_val)
    alpha_s = sp.S(alpha)
    s_s = sp.S(float(s_fixed)); c_s = sp.S(float(c_fixed))

    diff, Ssym, X_tp1 = build_diff_sym(L, beta, eta, alpha_s, s_s + c_s,
                                       a0_s, a1_s, a2_s, c01_s, c02_s, c12_s)
    G = build_active_generators(L, beta, eta, Ssym, X_tp1)
    pos_combo = sp.expand(diff + s_s * G["S"] + alpha_s * G["IV_t"] + c_s * G["C_t_tp1"])

    poly_vars = [Ssym["FE_tp1"], Ssym["FE_t"], Ssym["FE_p1"], Ssym["FE_p2"],
                 Ssym["g_tp1"], Ssym["g_t"], Ssym["g_p1"], Ssym["g_p2"],
                 Ssym["X_t"], Ssym["X_p1"], Ssym["X_p2"]]
    poly = sp.Poly(pos_combo, *poly_vars)
    other_list = [Ssym["g_tp1"], Ssym["g_t"], Ssym["g_p1"], Ssym["g_p2"],
                  Ssym["X_t"], Ssym["X_p1"], Ssym["X_p2"]]

    sym_to_cp = {a0_s: a0_v, a1_s: a1_v, a2_s: a2_v,
                 c01_s: c01_v, c02_s: c02_v, c12_s: c12_v}

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

    Q_mat = cp.bmat([[a0_v, c01_v / 2, c02_v / 2],
                     [c01_v / 2, a1_v, c12_v / 2],
                     [c02_v / 2, c12_v / 2, a2_v]])
    constraints.append(Q_mat >> 0)
    for v in [a0_v, a1_v, a2_v, c01_v, c02_v, c12_v]:
        constraints.append(cp.abs(v) <= 1e8)

    if (float(s_fixed) + float(c_fixed)) < alpha - 1e-9:
        return {"status": "infeasible (W<alpha)"}

    S_expr_cv = a0_v + a1_v + a2_v + c01_v + c02_v + c12_v
    objective = cp.Minimize(S_expr_cv)
    prob = cp.Problem(objective, constraints)
    try:
        prob.solve(solver=cp.CLARABEL, verbose=False,
                   tol_gap_abs=tol, tol_gap_rel=tol, tol_feas=tol)
    except Exception:
        try:
            prob.solve(solver=cp.SCS, verbose=False, eps=1e-9, max_iters=200000)
        except Exception as e:
            return {"status": f"err:{e}"}
    if prob.status not in ("optimal", "optimal_inaccurate"):
        return {"status": prob.status}

    return {
        "status": prob.status,
        "s": float(s_fixed), "c": float(c_fixed),
        "W": float(s_fixed) + float(c_fixed),
        "a0": float(a0_v.value), "a1": float(a1_v.value), "a2": float(a2_v.value),
        "c01": float(c01_v.value), "c02": float(c02_v.value), "c12": float(c12_v.value),
        "C": float((float(s_fixed) + float(c_fixed) - 1.0) * (L_val / 2.0)
                   + a0_v.value + a1_v.value + a2_v.value
                   + c01_v.value + c02_v.value + c12_v.value),
    }


def reduced_lmi_float(L_val, beta_val, eta_val, fix_alpha=1.0,
                      tol=1e-12, M_slack=0.0, C_max=None):
    """Reduced LMI: only the three multipliers (S, IV_t, C_t_tp1) active.
    From FE identities: W = lam_S + lam_C_t_tp1; lam_IV_t = alpha (= 1).
    Free vars: lam_S = s, lam_C_t_tp1 = c, plus 6 Lyapunov coefficients.
    """
    a0_v = cp.Variable(); a1_v = cp.Variable(); a2_v = cp.Variable()
    c01_v = cp.Variable(); c02_v = cp.Variable(); c12_v = cp.Variable()
    s_v = cp.Variable(nonneg=True)
    c_v = cp.Variable(nonneg=True)
    alpha = float(fix_alpha)

    a0_s, a1_s, a2_s = sp.symbols("a0 a1 a2", real=True)
    c01_s, c02_s, c12_s = sp.symbols("c01 c02 c12", real=True)
    s_s, c_s = sp.symbols("s c", real=True)
    L = sp.S(L_val); beta = sp.S(beta_val); eta = sp.S(eta_val)
    alpha_s = sp.S(alpha)

    diff, Ssym, X_tp1 = build_diff_sym(L, beta, eta, alpha_s, s_s + c_s,
                                       a0_s, a1_s, a2_s, c01_s, c02_s, c12_s)
    G = build_active_generators(L, beta, eta, Ssym, X_tp1)
    pos_combo = sp.expand(diff + s_s * G["S"] + alpha_s * G["IV_t"] + c_s * G["C_t_tp1"])

    poly_vars = [Ssym["FE_tp1"], Ssym["FE_t"], Ssym["FE_p1"], Ssym["FE_p2"],
                 Ssym["g_tp1"], Ssym["g_t"], Ssym["g_p1"], Ssym["g_p2"],
                 Ssym["X_t"], Ssym["X_p1"], Ssym["X_p2"]]
    poly = sp.Poly(pos_combo, *poly_vars)
    other_list = [Ssym["g_tp1"], Ssym["g_t"], Ssym["g_p1"], Ssym["g_p2"],
                  Ssym["X_t"], Ssym["X_p1"], Ssym["X_p2"]]

    sym_to_cp = {a0_s: a0_v, a1_s: a1_v, a2_s: a2_v,
                 c01_s: c01_v, c02_s: c02_v, c12_s: c12_v,
                 s_s: s_v, c_s: c_v}

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
    # Sanity: FE identities should hold by construction since we substituted W = s + c
    # and alpha into G_IV_t weight. Just confirm there are no FE residues.
    # (optional check; for cvxpy we don't need to assert these — they vanish symbolically)

    n = len(other_list)  # 7
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
    if M_slack > 0.0:
        import numpy as _np
        constraints.append(M - float(M_slack) * _np.eye(n) >> 0)
    else:
        constraints.append(M >> 0)

    constraints.append(s_v + c_v >= alpha)  # W >= alpha
    Q_mat = cp.bmat([[a0_v,        c01_v / 2,  c02_v / 2],
                     [c01_v / 2,   a1_v,       c12_v / 2],
                     [c02_v / 2,   c12_v / 2,  a2_v     ]])
    constraints.append(Q_mat >> 0)
    for v in [a0_v, a1_v, a2_v, c01_v, c02_v, c12_v]:
        constraints.append(cp.abs(v) <= 1e6)

    S_expr_cv = a0_v + a1_v + a2_v + c01_v + c02_v + c12_v
    C_expr = (s_v + c_v - 1.0) * (L_val / 2.0) + S_expr_cv
    if C_max is not None:
        constraints.append(C_expr <= float(C_max))
        objective = cp.Minimize(cp.sum_squares(cp.hstack(
            [a0_v, a1_v, a2_v, c01_v, c02_v, c12_v])))
    else:
        objective = cp.Minimize(C_expr)
    prob = cp.Problem(objective, constraints)
    solver_used = None
    try:
        prob.solve(solver=cp.CLARABEL, verbose=False,
                   tol_gap_abs=tol, tol_gap_rel=tol, tol_feas=tol)
        solver_used = "CLARABEL"
    except Exception:
        try:
            prob.solve(solver=cp.SCS, verbose=False, eps=1e-9, max_iters=200000)
            solver_used = "SCS"
        except Exception as e:
            return {"status": f"err:{e}"}
    if prob.status not in ("optimal", "optimal_inaccurate"):
        return {"status": prob.status, "solver": solver_used}

    return {
        "status": prob.status, "solver": solver_used,
        "s": float(s_v.value), "c": float(c_v.value),
        "W": float(s_v.value) + float(c_v.value),
        "a0": float(a0_v.value), "a1": float(a1_v.value), "a2": float(a2_v.value),
        "c01": float(c01_v.value), "c02": float(c02_v.value), "c12": float(c12_v.value),
        "C": float(((s_v.value + c_v.value) - 1.0) * (L_val / 2.0)
                   + a0_v.value + a1_v.value + a2_v.value
                   + c01_v.value + c02_v.value + c12_v.value),
    }


# ---------------------------------------------------------------------------
# PHASE 3 -- Round to QQ and verify exactly
# ---------------------------------------------------------------------------

def to_rational(x, denom, snap_tol=1e-9):
    if abs(x) < snap_tol:
        return sp.Integer(0)
    f = Fraction(x).limit_denominator(denom)
    return sp.Rational(f.numerator, f.denominator)


def verify_reduced_in_QQ(L, beta, eta, alpha, cert_q):
    """Build pos_combo = diff + s G_S + 1 G_IV_t + c G_C_t_tp1 in QQ; check
    M (7x7 from quadratic part) PSD, Q (3x3) PSD, FE residues all 0."""
    a0 = cert_q["a0"]; a1 = cert_q["a1"]; a2 = cert_q["a2"]
    c01 = cert_q["c01"]; c02 = cert_q["c02"]; c12 = cert_q["c12"]
    s = cert_q["s"]; c = cert_q["c"]
    W = s + c

    diff, Ssym, X_tp1 = build_diff_sym(L, beta, eta, alpha, W,
                                       a0, a1, a2, c01, c02, c12)
    G = build_active_generators(L, beta, eta, Ssym, X_tp1)
    pos_combo = sp.expand(diff + s * G["S"] + alpha * G["IV_t"] + c * G["C_t_tp1"])

    poly_vars = [Ssym["FE_tp1"], Ssym["FE_t"], Ssym["FE_p1"], Ssym["FE_p2"],
                 Ssym["g_tp1"], Ssym["g_t"], Ssym["g_p1"], Ssym["g_p2"],
                 Ssym["X_t"], Ssym["X_p1"], Ssym["X_p2"]]
    poly = sp.Poly(pos_combo, *poly_vars)
    FE_list = [Ssym["FE_tp1"], Ssym["FE_t"], Ssym["FE_p1"], Ssym["FE_p2"]]
    other_list = [Ssym["g_tp1"], Ssym["g_t"], Ssym["g_p1"], Ssym["g_p2"],
                  Ssym["X_t"], Ssym["X_p1"], Ssym["X_p2"]]

    fe_violations = []
    monoms = list(FE_list)
    for fe in FE_list:
        for v in other_list:
            monoms.append(fe * v)
    for i in range(len(FE_list)):
        monoms.append(FE_list[i]**2)
    for i in range(len(FE_list)):
        for j in range(i + 1, len(FE_list)):
            monoms.append(FE_list[i] * FE_list[j])
    for mm in monoms:
        try:
            cf = sp.expand(poly.coeff_monomial(mm))
        except Exception:
            cf = sp.S(0)
        if cf != 0:
            fe_violations.append((str(mm), cf))

    n = len(other_list)
    M_mat = sp.zeros(n, n)
    for i in range(n):
        cf_ii = sp.expand(poly.coeff_monomial(other_list[i]**2))
        M_mat[i, i] = -cf_ii
    for i in range(n):
        for j in range(i + 1, n):
            cf_ij = sp.expand(poly.coeff_monomial(other_list[i] * other_list[j]))
            half = -cf_ij / sp.Integer(2)
            M_mat[i, j] = half
            M_mat[j, i] = half

    Q_mat = sp.Matrix([
        [a0,         c01 / 2,    c02 / 2],
        [c01 / 2,    a1,         c12 / 2],
        [c02 / 2,    c12 / 2,    a2     ],
    ])

    return {
        "fe_ok": len(fe_violations) == 0,
        "fe_violations": fe_violations,
        "M": M_mat,
        "M_psd": bool(M_mat.is_positive_semidefinite),
        "Q": Q_mat,
        "Q_psd": bool(Q_mat.is_positive_semidefinite),
        "lam_neg": (s < 0) or (c < 0) or (alpha < 0),
        "W_ok": (s + c) >= alpha,
    }


def fmt(r):
    if r == 0:
        return "0"
    if r.q == 1:
        return str(r.p)
    return f"{r.p}/{r.q}"


def round_cert(cert_fl, denom):
    out = {}
    for k in ["a0", "a1", "a2", "c01", "c02", "c12", "s", "c"]:
        out[k] = to_rational(cert_fl[k], denom)
    return out


def C_value(L, cert_q):
    return ((cert_q["s"] + cert_q["c"] - 1) * sp.Rational(1, 2) * L
            + cert_q["a0"] + cert_q["a1"] + cert_q["a2"]
            + cert_q["c01"] + cert_q["c02"] + cert_q["c12"])


def attempt_high_beta(L_int, beta_q, eta_q, alpha_int=1):
    L = sp.Integer(L_int)
    alpha = sp.Integer(alpha_int)
    beta = sp.Rational(beta_q.numerator, beta_q.denominator)
    eta = sp.Rational(eta_q.numerator, eta_q.denominator)

    print(f"\n{'='*78}\n[reduced LMI]  beta={beta_q}, eta={eta_q}, L={L_int}\n{'='*78}")
    cert_fl = reduced_lmi_float(float(L), float(beta), float(eta),
                                fix_alpha=float(alpha))
    if cert_fl.get("status") not in ("optimal", "optimal_inaccurate"):
        print(f"  [reduced] status={cert_fl.get('status')} -- skip")
        return None, {"status": cert_fl.get("status"), "strategy": "reduced"}
    print(f"  [reduced] status={cert_fl['status']}  s={cert_fl['s']:.4f}  c={cert_fl['c']:.4f}  "
          f"W={cert_fl['W']:.4f}  C={cert_fl['C']:.4f}")

    def _try(cert_source, denoms, label_solve):
        for denom in denoms:
            cert_q = round_cert(cert_source, denom)
            ver = verify_reduced_in_QQ(L, beta, eta, alpha, cert_q)
            ok = (ver["fe_ok"] and ver["M_psd"] and ver["Q_psd"]
                  and not ver["lam_neg"] and ver["W_ok"])
            why = []
            if not ver["fe_ok"]: why.append(f"FE({len(ver['fe_violations'])})")
            if not ver["M_psd"]: why.append("Mnpsd")
            if not ver["Q_psd"]: why.append("Qnpsd")
            if ver["lam_neg"]:   why.append("lam<0")
            if not ver["W_ok"]:  why.append("W<a")
            mark = "OK" if ok else "fail"
            print(f"  [{label_solve}] denom={denom:>5}  {mark}  "
                  f"s={fmt(cert_q['s'])}  c={fmt(cert_q['c'])}  "
                  f"W={fmt(cert_q['s'] + cert_q['c'])}  "
                  f"C={float(C_value(L, cert_q)):.4f}"
                  + (f"  [{','.join(why)}]" if why else ""))
            if ok:
                return cert_q, denom, ver
        return None, None, None

    cert_q, denom, ver = _try(cert_fl, [50, 100, 250, 500, 1000, 2500, 5000, 10000],
                              "tight")
    if cert_q is not None:
        return cert_q, {"strategy": "reduced+round", "denom": denom,
                        "C": C_value(L, cert_q), "C_float": cert_fl["C"]}

    print("  (tight rounding failed; C-pinned interior fallback)")
    deltas = [0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1.0, 2.0]
    for delta in deltas:
        C_max = cert_fl["C"] + delta
        cert_alt = reduced_lmi_float(float(L), float(beta), float(eta),
                                     fix_alpha=float(alpha), tol=1e-12,
                                     C_max=C_max)
        if cert_alt.get("status") not in ("optimal", "optimal_inaccurate"):
            print(f"  [Cmax={C_max:.4f}] -> {cert_alt.get('status')}")
            continue
        print(f"  [Cmax={C_max:.4f}]  W={cert_alt['W']:.4f}  C_achieved={cert_alt['C']:.4f}")
        cert_q, denom, ver = _try(cert_alt,
                                  [20, 50, 100, 250, 500, 1000, 2500, 5000, 10000],
                                  f"Cmax={C_max:.3f}")
        if cert_q is not None:
            return cert_q, {"strategy": "reduced+Cmax+round",
                            "denom": denom, "C_max": C_max,
                            "C": C_value(L, cert_q), "C_float": cert_fl["C"]}

    # Tertiary fallback: pin (s, c) to clean rationals and re-solve LMI for (a, c) only.
    # We pick a small-denom rational close to (s_clarabel, c_clarabel) and try several
    # nearby pairs so the LMI has room to manoeuvre.
    print("  (interior fallback failed; pinning (s, c) to clean rationals)")
    s_star = cert_fl["s"]; c_star = cert_fl["c"]
    pinned_pairs = []
    for ds in [50, 25, 20, 15, 10, 8, 5]:
        for delta_s in [0, 1, 2, -1, 3]:
            for delta_c in [0, 1, 2, -1, 3]:
                s_q = sp.Rational(int(round(s_star * ds)) + delta_s, ds)
                c_q = sp.Rational(int(round(c_star * ds)) + delta_c, ds)
                if s_q < 0 or c_q < 0:
                    continue
                if (float(s_q) + float(c_q)) < float(alpha):
                    continue
                pair = (s_q, c_q)
                if pair not in pinned_pairs:
                    pinned_pairs.append(pair)
    pinned_pairs = pinned_pairs[:25]
    print(f"  trying {len(pinned_pairs)} (s,c)-pin pairs near s*={s_star:.3f}, c*={c_star:.3f}")
    n_solved = 0; n_M_only = 0
    for s_q, c_q in pinned_pairs:
        cert_alt = reduced_lmi_fixed_lambdas(float(L), float(beta), float(eta),
                                             float(alpha), float(s_q), float(c_q))
        if cert_alt.get("status") not in ("optimal", "optimal_inaccurate"):
            continue
        n_solved += 1
        cert_alt["s"] = float(s_q); cert_alt["c"] = float(c_q)
        for denom in [20, 50, 100, 250, 500, 1000, 2500]:
            cert_q_partial = round_cert(cert_alt, denom)
            cert_q_partial["s"] = s_q; cert_q_partial["c"] = c_q
            ver = verify_reduced_in_QQ(L, beta, eta, alpha, cert_q_partial)
            ok = (ver["fe_ok"] and ver["M_psd"] and ver["Q_psd"]
                  and not ver["lam_neg"] and ver["W_ok"])
            if ok:
                C_q = C_value(L, cert_q_partial)
                print(f"  [pin (s,c)=({s_q},{c_q})]  denom={denom}  OK  C={float(C_q):.4f}")
                return cert_q_partial, {"strategy": "pin(s,c)+round(a,c)",
                                        "denom": denom, "s_q": str(s_q), "c_q": str(c_q),
                                        "C": C_q, "C_float": cert_fl["C"]}
            if ver["fe_ok"] and ver["Q_psd"] and not ver["lam_neg"] and ver["W_ok"]:
                n_M_only += 1
    print(f"  pin loop: {n_solved} feasible, {n_M_only} only-M-failed")

    print("  ALL FALLBACKS FAILED.")
    return None, {"strategy": "reduced+round", "denom": None, "C_float": cert_fl["C"]}


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

def main():
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument("--phase1", action="store_true",
                   help="run only Phase 1 (multiplier inspection)")
    args = p.parse_args()

    if args.phase1:
        summary = phase1_inspect(L=1.0)
        out = Path(__file__).parent / "44_phase1_inspect.json"
        out.write_text(json.dumps({str(k): {**v} for k, v in summary.items()},
                                  indent=2, default=str), encoding="utf-8")
        print(f"\n[saved] {out}")
        return

    # Phase 2 + 3 main run: target high-beta cases.
    cases = [
        # successes
        (Fraction(3, 5),  Fraction(1, 2)),
        (Fraction(4, 5),  Fraction(1, 5)),
        # representative failures (kept for documentation; the per-step output
        # explains *why* each fails -- M not PSD after rounding even with the
        # interior-point fallback and lambda-pinning)
        (Fraction(7, 10), Fraction(2, 5)),
        (Fraction(9, 10), Fraction(1, 5)),
    ]

    rows = []
    for beta_q, eta_q in cases:
        cert, info = attempt_high_beta(1, beta_q, eta_q, 1)
        if cert is None:
            rows.append({"beta": str(beta_q), "eta": str(eta_q),
                         "status": "FAIL", **info})
            continue
        rows.append({"beta": str(beta_q), "eta": str(eta_q),
                     "status": "EXACT_QQ_VERIFIED",
                     "strategy": info.get("strategy"),
                     "denom": info.get("denom"),
                     "s":   fmt(cert["s"]),  "c": fmt(cert["c"]),
                     "W":   fmt(cert["s"] + cert["c"]),
                     "a0":  fmt(cert["a0"]), "a1": fmt(cert["a1"]), "a2": fmt(cert["a2"]),
                     "c01": fmt(cert["c01"]), "c02": fmt(cert["c02"]), "c12": fmt(cert["c12"]),
                     "C":   fmt(info["C"]), "C_decimal": float(info["C"])})

    print(f"\n{'='*78}\nSUMMARY (Phase 3 — high-beta exact QQ certificates)\n{'='*78}")
    hdr = (f"{'beta':>7} {'eta':>6} {'status':>22} {'denom':>6} {'W':>10} "
           f"{'C':>10} {'C(decimal)':>12}")
    print(hdr); print("-" * len(hdr))
    for r in rows:
        if r["status"] != "EXACT_QQ_VERIFIED":
            print(f"{r['beta']:>7} {r['eta']:>6} {r['status']:>22} "
                  f"{'-':>6} {'-':>10} {'-':>10} {'-':>12}")
        else:
            print(f"{r['beta']:>7} {r['eta']:>6} {r['status']:>22} "
                  f"{str(r.get('denom','-')):>6} {r['W']:>10} {r['C']:>10} "
                  f"{r['C_decimal']:>12.4f}")

    out = Path(__file__).parent / "44_high_beta_results.json"
    out.write_text(json.dumps(rows, indent=2, default=str), encoding="utf-8")
    print(f"\nResults written to {out}")


if __name__ == "__main__":
    main()
