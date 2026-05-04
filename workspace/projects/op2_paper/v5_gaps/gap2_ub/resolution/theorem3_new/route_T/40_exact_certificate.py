"""Step 40: EXACT rational certificates for Theorem 3 (baseline 2-step LMI, beta <= 0.5).

Goal
----
Replace 1e-8-precision CLARABEL output with mathematically rigorous rational
certificates verified in SymPy exact (QQ) arithmetic.

LMI structural fact
-------------------
With diff = W*FE_{t+1} - (W-alpha)*FE_t + Q_next - Q_t and the 10 generators
{S, IV_t, IV_p1, IV_p2, C_t_p1, C_p1_t, C_p1_p2, C_p2_p1, C_t_p2, C_p2_t},
the FE-coefficient identities reduce to FOUR linear equations in (W, alpha, lambda):

    (FE_{t+1}) W = lam_S
    (FE_t)     alpha - W + lam_S - lam_IV_t + lam_C_t_p1 - lam_C_p1_t
                                    + lam_C_t_p2 - lam_C_p2_t = 0
    (FE_p1)   -lam_IV_p1 - lam_C_t_p1 + lam_C_p1_t + lam_C_p1_p2 - lam_C_p2_p1 = 0
    (FE_p2)   -lam_IV_p2 - lam_C_t_p2 + lam_C_p2_t - lam_C_p1_p2 + lam_C_p2_p1 = 0

There are no FE x v cross-monomials (none of the generators contain FE*X or FE*g
products), so all the FE x v coefficients are identically zero in QQ.

Pipeline per beta
-----------------
  (1) Solve baseline LMI with high-precision CLARABEL; collect floats.
  (2) Round (lam_S, lam_C_*) and (a, c) to sp.Rational with denominator <= N.
  (3) Compute (lam_IV_t, lam_IV_p1, lam_IV_p2) EXACTLY from the FE identities.
      W = lam_S.  This makes all FE identities hold in QQ by construction.
  (4) Verify lam_IV_* >= 0, W >= alpha, all original lambdas >= 0.
  (5) Build M (6x6 QQ-symmetric) from the (g, X)-quadratic part of pos_combo,
      check M is PSD in exact QQ via Matrix.is_positive_semidefinite.
  (6) Check Q (3x3 QQ-symmetric Lyapunov coercivity matrix) is PSD in QQ.

Special case beta = 0, eta = 1, L = 1: use closed-form textbook certificate
  W=1, a0=1/2, all others = 0, lam_S=1, lam_IV_t=1, all others = 0.
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


GENERATOR_NAMES = ["S", "IV_t", "IV_p1", "IV_p2",
                   "C_t_p1", "C_p1_t",
                   "C_p1_p2", "C_p2_p1",
                   "C_t_p2", "C_p2_t"]


# ---------------------------------------------------------------------------
# Symbolic builders (work in QQ when inputs are sp.Rational)
# ---------------------------------------------------------------------------

def setup_symbols():
    g_t, g_p1, g_p2 = sp.symbols("g_t g_p1 g_p2", real=True)
    X_t, X_p1, X_p2 = sp.symbols("X_t X_p1 X_p2", real=True)
    FE_t, FE_p1, FE_p2, FE_t1 = sp.symbols("FE_t FE_p1 FE_p2 FE_t1", real=True)
    return dict(g_t=g_t, g_p1=g_p1, g_p2=g_p2,
                X_t=X_t, X_p1=X_p1, X_p2=X_p2,
                FE_t=FE_t, FE_p1=FE_p1, FE_p2=FE_p2, FE_t1=FE_t1)


def build_diff(L, beta, eta, alpha, W, a0, a1, a2, c01, c02, c12, S):
    g_t = S["g_t"]
    X_t, X_p1, X_p2 = S["X_t"], S["X_p1"], S["X_p2"]
    FE_t, FE_t1 = S["FE_t"], S["FE_t1"]

    dy_t = -eta * g_t + beta * (X_t - X_p1)
    X_t1 = X_t + dy_t

    Q_t = (a0 * X_t**2 + a1 * X_p1**2 + a2 * X_p2**2
           + c01 * X_t * X_p1 + c02 * X_t * X_p2 + c12 * X_p1 * X_p2)
    Q_next = (a0 * X_t1**2 + a1 * X_t**2 + a2 * X_p1**2
              + c01 * X_t1 * X_t + c02 * X_t1 * X_p1 + c12 * X_t * X_p1)
    return sp.expand(W * FE_t1 - (W - alpha) * FE_t + Q_next - Q_t)


def build_generators(L, beta, eta, S):
    g_t, g_p1, g_p2 = S["g_t"], S["g_p1"], S["g_p2"]
    X_t, X_p1, X_p2 = S["X_t"], S["X_p1"], S["X_p2"]
    FE_t, FE_p1, FE_p2, FE_t1 = S["FE_t"], S["FE_p1"], S["FE_p2"], S["FE_t1"]
    half_inv_L = sp.Rational(1, 2) / L
    dy_t = -eta * g_t + beta * (X_t - X_p1)

    G = {}
    G["S"]       = FE_t - FE_t1 + g_t * dy_t + sp.Rational(1, 2) * L * dy_t**2
    G["IV_t"]    = g_t   * X_t   - FE_t   - half_inv_L * g_t**2
    G["IV_p1"]   = g_p1  * X_p1  - FE_p1  - half_inv_L * g_p1**2
    G["IV_p2"]   = g_p2  * X_p2  - FE_p2  - half_inv_L * g_p2**2
    G["C_t_p1"]  = (FE_t  - FE_p1) - g_p1 * (X_t  - X_p1) - half_inv_L * (g_t  - g_p1)**2
    G["C_p1_t"]  = (FE_p1 - FE_t)  - g_t  * (X_p1 - X_t)  - half_inv_L * (g_p1 - g_t)**2
    G["C_p1_p2"] = (FE_p1 - FE_p2) - g_p2 * (X_p1 - X_p2) - half_inv_L * (g_p1 - g_p2)**2
    G["C_p2_p1"] = (FE_p2 - FE_p1) - g_p1 * (X_p2 - X_p1) - half_inv_L * (g_p2 - g_p1)**2
    G["C_t_p2"]  = (FE_t  - FE_p2) - g_p2 * (X_t  - X_p2) - half_inv_L * (g_t  - g_p2)**2
    G["C_p2_t"]  = (FE_p2 - FE_t)  - g_t  * (X_p2 - X_t)  - half_inv_L * (g_p2 - g_t)**2
    return {k: sp.expand(v) for k, v in G.items()}


# ---------------------------------------------------------------------------
# Numerical solve (CLARABEL) to obtain a starting point
# ---------------------------------------------------------------------------

def solve_lmi_float(L_val, beta_val, eta_val, alpha_val=1.0, tol=1e-12,
                    M_slack=0.0, C_max=None):
    L = sp.S(L_val); beta = sp.S(beta_val); eta = sp.S(eta_val); alpha = sp.S(alpha_val)
    S = setup_symbols()

    a0_s, a1_s, a2_s = sp.symbols("a0 a1 a2", real=True)
    c01_s, c02_s, c12_s = sp.symbols("c01 c02 c12", real=True)
    W_s = sp.Symbol("W", real=True)
    alpha_s = sp.Symbol("alpha", real=True)

    diff = build_diff(L, beta, eta, alpha_s, W_s,
                      a0_s, a1_s, a2_s, c01_s, c02_s, c12_s, S)
    G = build_generators(L, beta, eta, S)

    a0_v = cp.Variable(); a1_v = cp.Variable(); a2_v = cp.Variable()
    c01_v = cp.Variable(); c02_v = cp.Variable(); c12_v = cp.Variable()
    W_v = cp.Variable(nonneg=True)
    alpha_const = cp.Constant(float(alpha_val))
    lam = {n: cp.Variable(nonneg=True) for n in G.keys()}
    lam_syms = {n: sp.symbols(f"lam_{n}", real=True) for n in G.keys()}

    pos_combo = sp.expand(diff)
    for n, gen in G.items():
        pos_combo = sp.expand(pos_combo + lam_syms[n] * gen)

    poly_vars = [S["FE_t"], S["FE_p1"], S["FE_p2"], S["FE_t1"],
                 S["g_t"], S["g_p1"], S["g_p2"], S["X_t"], S["X_p1"], S["X_p2"]]
    poly = sp.Poly(pos_combo, *poly_vars)
    FE_list = [S["FE_t"], S["FE_p1"], S["FE_p2"], S["FE_t1"]]
    other_list = [S["g_t"], S["g_p1"], S["g_p2"], S["X_t"], S["X_p1"], S["X_p2"]]

    sym_to_cp = {a0_s: a0_v, a1_s: a1_v, a2_s: a2_v,
                 c01_s: c01_v, c02_s: c02_v, c12_s: c12_v,
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
    if M_slack > 0.0:
        import numpy as _np
        constraints.append(M - float(M_slack) * _np.eye(6) >> 0)
    else:
        constraints.append(M >> 0)

    constraints.append(W_v >= float(alpha_val))
    Q_mat = cp.bmat([
        [a0_v,        c01_v / 2,  c02_v / 2],
        [c01_v / 2,   a1_v,       c12_v / 2],
        [c02_v / 2,   c12_v / 2,  a2_v     ],
    ])
    constraints.append(Q_mat >> 0)
    for v in [a0_v, a1_v, a2_v, c01_v, c02_v, c12_v]:
        constraints.append(cp.abs(v) <= 1e3)

    S_expr_cv = a0_v + a1_v + a2_v + c01_v + c02_v + c12_v
    C_expr = (W_v - 1.0) * (L_val / 2.0) + S_expr_cv
    if C_max is not None:
        # interior-point variant: pin C to target, minimize a coercive proxy
        constraints.append(C_expr <= float(C_max))
        objective = cp.Minimize(cp.sum_squares(cp.hstack(
            [a0_v, a1_v, a2_v, c01_v, c02_v, c12_v])))
    else:
        objective = cp.Minimize(C_expr)
    prob = cp.Problem(objective, constraints)
    try:
        prob.solve(solver=cp.CLARABEL, verbose=False,
                   tol_gap_abs=tol, tol_gap_rel=tol, tol_feas=tol)
    except Exception as e:
        return {"status": f"err: {str(e)[:60]}"}
    if prob.status not in ("optimal", "optimal_inaccurate"):
        return {"status": prob.status}

    return {
        "status": prob.status,
        "W": float(W_v.value),
        "a0": float(a0_v.value), "a1": float(a1_v.value), "a2": float(a2_v.value),
        "c01": float(c01_v.value), "c02": float(c02_v.value), "c12": float(c12_v.value),
        "lambdas": {n: float(lam[n].value) for n in G.keys()},
    }


# ---------------------------------------------------------------------------
# Rounding & exact-FE adjustment
# ---------------------------------------------------------------------------

def to_rational(x, denom, snap_tol=1e-9):
    if abs(x) < snap_tol:
        return sp.Integer(0)
    f = Fraction(x).limit_denominator(denom)
    return sp.Rational(f.numerator, f.denominator)


def round_lambdas(cert_float, denom):
    """Round all 10 lambdas to QQ; the IV ones get OVERWRITTEN by the exact solve."""
    return {n: to_rational(cert_float["lambdas"][n], denom) for n in GENERATOR_NAMES}


def enforce_fe_identity(lambdas_q, alpha):
    """Solve for (lam_IV_t, lam_IV_p1, lam_IV_p2) in QQ from the FE identities,
    treating the other 7 lambdas + alpha as inputs. Also W = lam_S.
    Returns (lambdas_full, W). Note these solved IV lambdas may turn out negative."""
    lam = dict(lambdas_q)  # mutable copy
    # E_t identity: alpha = lam_IV_t - lam_C_t_p1 + lam_C_p1_t - lam_C_t_p2 + lam_C_p2_t
    # (using W = lam_S after E_{t+1} substitution; alpha - W + lam_S = alpha)
    lam["IV_t"] = (alpha
                   + lam["C_t_p1"] - lam["C_p1_t"]
                   + lam["C_t_p2"] - lam["C_p2_t"])
    # E_p1: 0 = -lam_IV_p1 - lam_C_t_p1 + lam_C_p1_t + lam_C_p1_p2 - lam_C_p2_p1
    lam["IV_p1"] = (- lam["C_t_p1"] + lam["C_p1_t"]
                    + lam["C_p1_p2"] - lam["C_p2_p1"])
    # E_p2: 0 = -lam_IV_p2 - lam_C_t_p2 + lam_C_p2_t - lam_C_p1_p2 + lam_C_p2_p1
    lam["IV_p2"] = (- lam["C_t_p2"] + lam["C_p2_t"]
                    - lam["C_p1_p2"] + lam["C_p2_p1"])
    W = lam["S"]
    return lam, W


def round_cert_and_enforce(cert_float, denom, alpha):
    """Round Lyapunov + 7 free lambdas, solve for the 3 IV lambdas, return rational cert."""
    lam_q = round_lambdas(cert_float, denom)
    lam_full, W = enforce_fe_identity(lam_q, alpha)
    cert_q = {
        "W":   W,
        "a0":  to_rational(cert_float["a0"], denom),
        "a1":  to_rational(cert_float["a1"], denom),
        "a2":  to_rational(cert_float["a2"], denom),
        "c01": to_rational(cert_float["c01"], denom),
        "c02": to_rational(cert_float["c02"], denom),
        "c12": to_rational(cert_float["c12"], denom),
        "lambdas": lam_full,
    }
    return cert_q


# ---------------------------------------------------------------------------
# Exact verification
# ---------------------------------------------------------------------------

def verify_exact(L, beta, eta, alpha, cert_q):
    """All inputs sp.Rational. Returns full verification dict."""
    S = setup_symbols()
    diff = build_diff(L, beta, eta, alpha,
                      cert_q["W"], cert_q["a0"], cert_q["a1"], cert_q["a2"],
                      cert_q["c01"], cert_q["c02"], cert_q["c12"], S)
    G = build_generators(L, beta, eta, S)

    pos_combo = sp.expand(diff)
    for n in GENERATOR_NAMES:
        pos_combo = sp.expand(pos_combo + cert_q["lambdas"][n] * G[n])

    poly_vars = [S["FE_t"], S["FE_p1"], S["FE_p2"], S["FE_t1"],
                 S["g_t"], S["g_p1"], S["g_p2"], S["X_t"], S["X_p1"], S["X_p2"]]
    poly = sp.Poly(pos_combo, *poly_vars)
    FE_list = [S["FE_t"], S["FE_p1"], S["FE_p2"], S["FE_t1"]]
    other_list = [S["g_t"], S["g_p1"], S["g_p2"], S["X_t"], S["X_p1"], S["X_p2"]]

    fe_violations = []
    monoms = list(FE_list)
    for fe in FE_list:
        for v in other_list:
            monoms.append(fe * v)
    for i in range(4):
        monoms.append(FE_list[i]**2)
    for i in range(4):
        for j in range(i + 1, 4):
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

    # Q matrix (Lyapunov coercivity)
    Q_mat = sp.Matrix([
        [cert_q["a0"],          cert_q["c01"] / 2, cert_q["c02"] / 2],
        [cert_q["c01"] / 2,     cert_q["a1"],      cert_q["c12"] / 2],
        [cert_q["c02"] / 2,     cert_q["c12"] / 2, cert_q["a2"]     ],
    ])

    # Lambda non-negativity
    lam_neg = {k: v for k, v in cert_q["lambdas"].items() if v < 0}

    return {
        "fe_ok":        len(fe_violations) == 0,
        "fe_violations": fe_violations,
        "M":            M_mat,
        "M_psd":        bool(M_mat.is_positive_semidefinite),
        "Q":            Q_mat,
        "Q_psd":        bool(Q_mat.is_positive_semidefinite),
        "lam_neg":      lam_neg,
        "W_ok":         cert_q["W"] >= alpha,
    }


# ---------------------------------------------------------------------------
# Closed-form textbook certificate (beta=0, eta=1/L)
# ---------------------------------------------------------------------------

def textbook_cert(L):
    """V_t = t (f - f*) + (L/2) ||x_t - x*||^2 ; for plain GD (beta=0, eta=1/L)."""
    cert = {
        "W":   sp.Integer(1),
        "a0":  sp.Rational(1, 2) * L,
        "a1":  sp.Integer(0), "a2": sp.Integer(0),
        "c01": sp.Integer(0), "c02": sp.Integer(0), "c12": sp.Integer(0),
        "lambdas": {n: sp.Integer(0) for n in GENERATOR_NAMES},
    }
    cert["lambdas"]["S"] = sp.Integer(1)
    cert["lambdas"]["IV_t"] = sp.Integer(1)
    return cert


# ---------------------------------------------------------------------------
# Per-beta orchestration
# ---------------------------------------------------------------------------

def C_value(L, cert_q):
    return ((cert_q["W"] - 1) * sp.Rational(1, 2) * L
            + cert_q["a0"] + cert_q["a1"] + cert_q["a2"]
            + cert_q["c01"] + cert_q["c02"] + cert_q["c12"])


def fmt(r):
    if r == 0:
        return "0"
    if r.q == 1:
        return str(r.p)
    return f"{r.p}/{r.q}"


def solve_one(L_int, beta_q, eta_q, alpha_int=1, label=""):
    L = sp.Integer(L_int)
    alpha = sp.Integer(alpha_int)
    beta = sp.Rational(beta_q.numerator, beta_q.denominator)
    eta = sp.Rational(eta_q.numerator, eta_q.denominator)

    print(f"\n{'='*78}\n{label}  beta={beta_q}, eta={eta_q}, L={L_int}\n{'='*78}")

    # (A) try textbook for beta=0, eta=1/L
    if beta == 0 and eta * L == 1:
        cert = textbook_cert(L)
        ver = verify_exact(L, beta, eta, alpha, cert)
        if (ver["fe_ok"] and ver["M_psd"] and ver["Q_psd"]
                and not ver["lam_neg"] and ver["W_ok"]):
            C = C_value(L, cert)
            print(f"[textbook]  PSD verified in QQ.  C = {fmt(C)} = {float(C):.4f}")
            return cert, {"strategy": "textbook", "C": C, "denom": None}, ver
        else:
            print(f"[textbook]  verification FAILED: fe_ok={ver['fe_ok']}, "
                  f"M_psd={ver['M_psd']}, Q_psd={ver['Q_psd']}, lam_neg={ver['lam_neg']}")

    # (B) CLARABEL → round → enforce FE identity → verify
    cert_fl = solve_lmi_float(float(L), float(beta), float(eta),
                              alpha_val=float(alpha), tol=1e-12)
    if cert_fl.get("status") not in ("optimal", "optimal_inaccurate"):
        print(f"[clarabel]  status={cert_fl.get('status')} -- skip")
        return None, {"strategy": "clarabel", "status": cert_fl.get("status")}, None
    C_float = ((cert_fl["W"] - 1) * 0.5
               + sum(cert_fl[k] for k in ["a0", "a1", "a2", "c01", "c02", "c12"]))
    print(f"[clarabel]  status={cert_fl['status']}  W={cert_fl['W']:.6f}  "
          f"C_float={C_float:.6f}")

    def _try_round(cert_source, denoms, label_solve):
        for denom in denoms:
            cert_q = round_cert_and_enforce(cert_source, denom, alpha)
            ver = verify_exact(L, beta, eta, alpha, cert_q)
            ok = (ver["fe_ok"] and ver["M_psd"] and ver["Q_psd"]
                  and not ver["lam_neg"] and ver["W_ok"])
            marker = "OK" if ok else "fail"
            why = []
            if not ver["fe_ok"]:
                why.append(f"FE({len(ver['fe_violations'])})")
            if not ver["M_psd"]:
                why.append("Mnpsd")
            if not ver["Q_psd"]:
                why.append("Qnpsd")
            if ver["lam_neg"]:
                why.append(f"lam<0:{list(ver['lam_neg'].keys())}")
            if not ver["W_ok"]:
                why.append("W<a")
            print(f"  [{label_solve}] denom={denom:>5}  {marker}  W={fmt(cert_q['W'])}  "
                  f"C={float(C_value(L, cert_q)):.4f}"
                  + (f"  [{','.join(why)}]" if why else ""))
            if ok:
                return cert_q, denom, ver
        return None, None, None

    cert_q, denom, ver = _try_round(cert_fl, [50, 100, 250, 500, 1000, 2500, 5000, 10000],
                                     "tight")
    if cert_q is not None:
        return cert_q, {"strategy": "clarabel+round", "denom": denom,
                        "C": C_value(L, cert_q), "C_float": C_float,
                        "M_slack": 0.0, "C_max": None}, ver

    # ---- fallback: pin C to a slightly looser rational, minimize least-norm
    # (gives an interior point of the feasibility region; M strictly PSD there) ----
    print("  (tight rounding failed; trying interior-point fallbacks)")
    # try a sequence of clean rational C-targets above C_float
    C_targets = []
    for delta in [0.01, 0.02, 0.05, 0.1, 0.2, 0.5, 1.0]:
        C_targets.append(C_float + delta)
    # also try snap-to-clean-rational at low denominators
    for d_snap in [10, 20, 50, 100]:
        snapped = float(Fraction(C_float + 0.0005).limit_denominator(d_snap)) + 0.0
        if snapped > C_float:
            C_targets.append(snapped)
    seen = set()
    C_targets = [c for c in C_targets if not (c in seen or seen.add(round(c, 6)))]

    for C_max in C_targets:
        cert_alt = solve_lmi_float(float(L), float(beta), float(eta),
                                   alpha_val=float(alpha), tol=1e-12,
                                   M_slack=0.0, C_max=C_max)
        if cert_alt.get("status") not in ("optimal", "optimal_inaccurate"):
            print(f"  [Cmax={C_max:.4f}] -> {cert_alt.get('status')}")
            continue
        # quick feasibility report
        achieved = ((cert_alt["W"] - 1) * 0.5
                    + sum(cert_alt[k] for k in ["a0","a1","a2","c01","c02","c12"]))
        print(f"  [Cmax={C_max:.4f}]  W={cert_alt['W']:.6f}  achieved C={achieved:.6f}")
        cert_q, denom, ver = _try_round(cert_alt,
                                        [20, 50, 100, 250, 500, 1000, 2500, 5000, 10000],
                                        f"Cmax={C_max:.3f}")
        if cert_q is not None:
            return cert_q, {"strategy": "clarabel+Cmax+round",
                            "denom": denom, "C_max": C_max,
                            "C": C_value(L, cert_q), "C_float": C_float}, ver

    print("  ALL FALLBACKS FAILED.")
    return None, {"strategy": "clarabel+round", "denom": None, "C_float": C_float}, None


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    L_int = 1
    alpha_int = 1
    cases = [
        (Fraction(0),       Fraction(1),     "[beta=0    eta=1   textbook]"),
        (Fraction(0),       Fraction(3, 2),  "[beta=0    eta=3/2 (lower C)]"),
        (Fraction(1, 10),   Fraction(1),     "[beta=1/10 eta=1]"),
        (Fraction(1, 5),    Fraction(1),     "[beta=1/5  eta=1]"),
        (Fraction(3, 10),   Fraction(1),     "[beta=3/10 eta=1]"),
        (Fraction(2, 5),    Fraction(1),     "[beta=2/5  eta=1]"),
        # baseline at eta=1 is infeasible at beta=1/2; try smaller eta then larger eta
        (Fraction(1, 2),    Fraction(1, 2),  "[beta=1/2  eta=1/2]"),
        (Fraction(1, 2),    Fraction(7, 10), "[beta=1/2  eta=7/10]"),
        (Fraction(1, 2),    Fraction(3, 2),  "[beta=1/2  eta=3/2]"),
    ]

    out_rows = []
    for beta_q, eta_q, label in cases:
        cert, info, _ = solve_one(L_int, beta_q, eta_q, alpha_int, label)
        if cert is None:
            out_rows.append({
                "beta": str(beta_q), "eta": str(eta_q),
                "strategy": info.get("strategy"),
                "status": "FAIL",
            })
            continue
        out_rows.append({
            "beta": str(beta_q), "eta": str(eta_q),
            "strategy": info.get("strategy"),
            "denom": info.get("denom"),
            "W":   fmt(cert["W"]),
            "a0":  fmt(cert["a0"]),  "a1": fmt(cert["a1"]),  "a2": fmt(cert["a2"]),
            "c01": fmt(cert["c01"]), "c02": fmt(cert["c02"]), "c12": fmt(cert["c12"]),
            "C":   fmt(info["C"]),
            "C_decimal": float(info["C"]),
            "lambdas": {n: fmt(cert["lambdas"][n]) for n in GENERATOR_NAMES},
            "status": "EXACT_QQ_VERIFIED",
        })

    print(f"\n{'='*78}\nSUMMARY\n{'='*78}")
    hdr = (f"{'beta':>6} {'eta':>5} {'status':>22} {'denom':>6} "
           f"{'W':>8} {'C':>10} {'C(decimal)':>12}")
    print(hdr); print("-" * len(hdr))
    for r in out_rows:
        if r["status"] != "EXACT_QQ_VERIFIED":
            print(f"{r['beta']:>6} {r['eta']:>5} {r['status']:>22} "
                  f"{'-':>6} {'-':>8} {'-':>10} {'-':>12}")
        else:
            print(f"{r['beta']:>6} {r['eta']:>5} {r['status']:>22} "
                  f"{str(r.get('denom', '-')):>6} {r['W']:>8} {r['C']:>10} "
                  f"{r['C_decimal']:>12.4f}")

    out = Path(__file__).parent / "40_exact_certificate_results.json"
    out.write_text(json.dumps(out_rows, indent=2, default=str), encoding="utf-8")
    print(f"\nResults written to {out}")


if __name__ == "__main__":
    main()
