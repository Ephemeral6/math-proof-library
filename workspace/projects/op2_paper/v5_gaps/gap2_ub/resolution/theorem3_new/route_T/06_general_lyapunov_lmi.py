"""Route T, step #6: GENERAL one-step descent LMI with parametric Lyapunov.

We allow the Lyapunov to take the most general 1-step form (in 4 free coefficients):
   V_t = w_t * (f - f*) + a_t * ||y - y*||^2 + b_t * ||y - y_prev||^2 + d_t * <y - y*, y - y_prev>

For one-step descent V_{t+1} - V_t <= -c * (f - f*), we use the inequalities:
  (IV)   <g, y - y*>  >= (f - f*) + (1/(2L)) ||g||^2
  (S)    f(y_next) - (f - f*) <= <g, y_next - y> + (L/2) ||y_next - y||^2 + f - f*  (smoothness)
  (IV')  <g_prev, y_prev - y*> >= (f_prev - f*) + (1/(2L)) ||g_prev||^2
  (C2)   <g, y - y_prev> >= (f - f*) - (f_prev - f*)
  (CHAIN) f_{t+1} - f_t - <g_{t+1}, y_t - y_{t+1}> - (1/(2L))||g_t - g_{t+1}||^2 >= 0
         (this is the dominant dual we observed)

We CONSTANT-W version: w_t = w_{t+1} = w (no time variation; we'll add t-dependence later).

The descent V_{t+1} - V_t = (V_{t+1} - V_t) [as polynomial in (G, W, X, Gp, FE, FP, Gnext, ...)].

Actually since y_next is determined by SHB, we can just substitute and use bounded f_next.
For one-step descent we don't need g_{next} explicitly; we use smoothness to bound f_next.

We solve: find (a_curr, b_curr, d_curr, a_next, b_next, d_next, w_curr, w_next, c, lam_IV, lam_IVp, lam_C2, lam_S) >= 0 (or with sign as appropriate)
such that
  V_{t+1} - V_t + c (f-f*)
  - lam_IV * (G X - FE - (1/2L)G^2)
  - lam_IVp * (Gp Xprev - FP - (1/2L)Gp^2)
  - lam_C2 * (G W - FE + FP)
  - lam_S * (... smoothness slack absorbed)
  is a non-positive quadratic form in (G, W, X, Gp).

For "one step", the next-state coefficients (a_next, b_next, d_next, w_next) appear linearly,
so we can include them as cvxpy variables.

For STEADY STATE, set a_next = a_curr etc. (constant Lyapunov).

For TIME VARYING, set w_next = w_curr + Δw, then this LMI gives us the constraint on Δw.
"""
from pathlib import Path
import json
import numpy as np
import cvxpy as cp
import sympy as sp


def build_descent_polynomial(L_val, beta_val, eta_val):
    """Symbolically build V_{t+1} - V_t + c FE as a polynomial, with free coefficients."""
    G, W, X, Gp, FE, FP = sp.symbols("G W X Gp FE FP", real=True)
    # Free Lyapunov coefficients: a_curr, b_curr, d_curr, w_curr at time t; a_next, b_next, d_next, w_next at t+1.
    a, b, d, w = sp.symbols("a b d w", real=True)
    a2, b2, d2, w2 = sp.symbols("a2 b2 d2 w2", real=True)
    c = sp.symbols("c", real=True)
    L, beta, eta = sp.S(L_val), sp.S(beta_val), sp.S(eta_val)

    # SHB step
    dy = -eta * G + beta * W
    Xprev = X - W   # y_prev - y_* = (y - y_*) - (y - y_prev)

    # Lyapunov values at current and next steps
    V_curr = w * FE + a * X ** 2 + b * W ** 2 + d * X * W
    # next state: y_next - y_* = X + dy; y_next - y = dy.
    Xnext = X + dy
    Wnext = dy
    f_next_minus_f_star = FE + G * dy + sp.Rational(1, 2) * L * dy ** 2  # smoothness UB
    V_next = w2 * f_next_minus_f_star + a2 * Xnext ** 2 + b2 * Wnext ** 2 + d2 * Xnext * Wnext

    diff = sp.expand(V_next - V_curr + c * FE)
    return diff, (G, W, X, Gp, FE, FP), (a, b, d, w, a2, b2, d2, w2, c)


def build_lmi(L_val, beta_val, eta_val, constant_lyapunov=True, fix_c=None, max_c=False):
    """Build the LMI feasibility problem.

    constant_lyapunov: True means a2 = a, b2 = b, d2 = d, w2 = w (steady-state Lyapunov).
                       False means free.
    fix_c: if not None, fix c to this value; otherwise treat as a variable.
    max_c: if True, maximize c (instead of feasibility).
    """
    diff, (G, W, X, Gp, FE, FP), (a, b, d, w, a2, b2, d2, w2, c_sym) = \
        build_descent_polynomial(L_val, beta_val, eta_val)

    # cvxpy variables
    a_v = cp.Variable()
    b_v = cp.Variable()
    d_v = cp.Variable()
    w_v = cp.Variable(nonneg=True)
    if constant_lyapunov:
        a2_v = a_v; b2_v = b_v; d2_v = d_v; w2_v = w_v
    else:
        a2_v = cp.Variable()
        b2_v = cp.Variable()
        d2_v = cp.Variable()
        w2_v = cp.Variable(nonneg=True)

    if fix_c is not None:
        c_v = cp.Constant(fix_c)
    else:
        c_v = cp.Variable(nonneg=True)

    lam_IV = cp.Variable(nonneg=True)
    lam_IVp = cp.Variable(nonneg=True)
    lam_C2 = cp.Variable(nonneg=True)
    # lam_S: implicit (we substituted upper bound on f_next; equivalent to lam_S = w2)

    # Generators g_IV, g_IVp, g_C2 must be subtracted from diff:
    g_IV = G * X - FE - sp.Rational(1, 2) / sp.S(L_val) * G ** 2
    g_IVp = Gp * (X - W) - FP - sp.Rational(1, 2) / sp.S(L_val) * Gp ** 2
    g_C2 = G * W - FE + FP

    # We want
    #   diff - lam_IV * g_IV - lam_IVp * g_IVp - lam_C2 * g_C2  =  -[v]^T M [v]
    # with M >= 0 (PSD); v = (G, W, X, Gp).
    # The coefficients of FE and FP (linear in F variables) must vanish.

    lam_IV_s = sp.symbols("lam_IV", real=True)
    lam_IVp_s = sp.symbols("lam_IVp", real=True)
    lam_C2_s = sp.symbols("lam_C2", real=True)

    pos_combo = sp.expand(diff
                          - lam_IV_s * g_IV
                          - lam_IVp_s * g_IVp
                          - lam_C2_s * g_C2)

    # Coefficients of FE, FP (and bilinears with quadratic vars) must be zero.
    # Identify monomials:
    poly = sp.Poly(pos_combo, FE, FP, G, W, X, Gp)

    # FE-related must vanish (coefficient on FE * (anything in v))
    # Since FE doesn't multiply v in (V_{t+1} - V_t) directly, only the constant FE coeff matters.
    monoms_FE = [FE, FE * G, FE * W, FE * X, FE * Gp, FE ** 2, FE * FP]
    monoms_FP = [FP, FP * G, FP * W, FP * X, FP * Gp, FP ** 2]
    monoms_zero = monoms_FE + monoms_FP

    # Quadratic-form monomials in v = (G, W, X, Gp); must equal -M[i,j].
    var_list = [G, W, X, Gp]
    quad_monoms = {}
    for i in range(4):
        for j in range(i, 4):
            if i == j:
                quad_monoms[(i, j)] = var_list[i] ** 2
            else:
                quad_monoms[(i, j)] = var_list[i] * var_list[j]

    # Convert sympy expressions involving (lam_IV, lam_IVp, lam_C2, a_v, b_v, d_v, w_v, a2_v, b2_v, d2_v, w2_v, c_v) to cvxpy.
    sym_to_cp_map = {
        lam_IV_s: lam_IV, lam_IVp_s: lam_IVp, lam_C2_s: lam_C2,
        a: a_v, b: b_v, d: d_v, w: w_v,
        a2: a2_v, b2: b2_v, d2: d2_v, w2: w2_v,
        c_sym: c_v,
    }

    def sym_to_cp_expr(expr):
        expr = sp.expand(expr)
        if expr == 0:
            return cp.Constant(0.0)
        # Collect terms.
        terms = expr.as_ordered_terms() if expr.is_Add else [expr]
        out = cp.Constant(0.0)
        for term in terms:
            const_part = sp.S(1)
            cv_factor = None
            for f in term.as_ordered_factors():
                if f in sym_to_cp_map:
                    if cv_factor is None:
                        cv_factor = sym_to_cp_map[f]
                    else:
                        # Two cvxpy vars multiplying: NLP — cvxpy can't handle this, reject.
                        raise RuntimeError(f"Bilinear in cvxpy variables: {term}")
                else:
                    const_part = const_part * f
            const_val = float(const_part)
            if cv_factor is None:
                out = out + cp.Constant(const_val)
            else:
                out = out + const_val * cv_factor
        return out

    constraints = []

    for m in monoms_zero:
        try:
            coeff = poly.coeff_monomial(m)
        except Exception:
            coeff = sp.S(0)
        coeff = sp.expand(coeff)
        if coeff == 0: continue
        constraints.append(sym_to_cp_expr(coeff) == 0)

    # Build M from quadratic coeffs.
    M = cp.Variable((4, 4), symmetric=True)
    for (i, j), m in quad_monoms.items():
        try:
            coeff = poly.coeff_monomial(m)
        except Exception:
            coeff = sp.S(0)
        coeff = sp.expand(coeff)
        if i == j:
            constraints.append(M[i, i] == -sym_to_cp_expr(coeff))
        else:
            half = -sym_to_cp_expr(coeff) / 2
            constraints.append(M[i, j] == half)
            constraints.append(M[j, i] == half)

    constraints.append(M >> 0)

    if max_c:
        objective = cp.Maximize(c_v)
    else:
        objective = cp.Minimize(0)

    prob = cp.Problem(objective, constraints)
    prob.solve(solver=cp.SCS, verbose=False)

    return {
        "status": prob.status,
        "c": float(c_v.value) if hasattr(c_v, "value") and c_v.value is not None else (fix_c if fix_c is not None else None),
        "a": float(a_v.value) if a_v.value is not None else None,
        "b": float(b_v.value) if b_v.value is not None else None,
        "d": float(d_v.value) if d_v.value is not None else None,
        "w": float(w_v.value) if w_v.value is not None else None,
        "a2": float(a2_v.value) if (not constant_lyapunov and a2_v.value is not None) else None,
        "b2": float(b2_v.value) if (not constant_lyapunov and b2_v.value is not None) else None,
        "d2": float(d2_v.value) if (not constant_lyapunov and d2_v.value is not None) else None,
        "w2": float(w2_v.value) if (not constant_lyapunov and w2_v.value is not None) else None,
        "lam_IV": float(lam_IV.value) if lam_IV.value is not None else None,
        "lam_IVp": float(lam_IVp.value) if lam_IVp.value is not None else None,
        "lam_C2": float(lam_C2.value) if lam_C2.value is not None else None,
    }


def main():
    L = 1.0
    print("Solving general parametric Lyapunov one-step descent LMI:")
    print("(constant Lyapunov; max c)\n")
    print(f"{'beta':>6} {'eta':>6} {'status':>14} {'c':>10} {'a':>10} {'b':>10} {'d':>10} {'w':>10} {'lam_IV':>10} {'lam_C2':>10}")

    rows = []
    for beta in [0.0, 0.1, 0.2, 0.3, 0.4, 0.5]:
        for eta_factor in [0.5, 0.7, 1.0, 1.2, 1.5, 1.7, 2.0]:
            eta = eta_factor / L
            try:
                r = build_lmi(L, beta, eta, constant_lyapunov=True, max_c=True)
            except Exception as e:
                r = {"status": f"err:{str(e)[:30]}"}
            status = r.get("status", "?")
            cv = r.get("c", None)
            cv_str = f"{cv:.4f}" if isinstance(cv, float) and np.isfinite(cv) else "-"
            row = {"beta": beta, "eta": eta, **r}
            rows.append(row)
            if status in ("optimal", "optimal_inaccurate") and cv is not None and cv > 0:
                print(f"{beta:>6.2f} {eta:>6.3f} {status:>14} {cv_str:>10} "
                      f"{r['a']:>10.3f} {r['b']:>10.3f} {r['d']:>10.3f} {r['w']:>10.3f} "
                      f"{r['lam_IV']:>10.3f} {r['lam_C2']:>10.3f}")
            else:
                print(f"{beta:>6.2f} {eta:>6.3f} {status:>14} {cv_str:>10}  (infeas or c<=0)")

    out = Path(__file__).parent / "06_general_lyapunov_lmi_results.json"
    out.write_text(json.dumps(rows, indent=2, default=str))
    print(f"\nResults: {out}")


if __name__ == "__main__":
    main()
