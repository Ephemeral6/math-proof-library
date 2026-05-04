"""Route T, step #7: TIME-VARYING parametric Lyapunov.

We allow:
   V_t = w_t (f - f*) + a ||y - y*||^2 + b ||y - y_prev||^2 + d <y - y*, y - y_prev>
with a, b, d FIXED (constant Lyapunov in the quadratic part), but w_t = w_0 + t * delta_w (linear growth).

The descent inequality V_{t+1} - V_t <= 0  becomes (after substituting w_{t+1} = w_t + delta_w):
   delta_w * (f - f*) + (constant-w descent) <= 0
i.e., the standard one-step descent of constant Lyapunov gives:
   constant-w descent <= -delta_w * (f - f*)
i.e., the constant Lyapunov gives us c = delta_w in the bound V_{t+1} - V_t <= -c (f - f*).

So if we can find (a, b, d, w) such that V_{t+1} - V_t <= 0 in the constant-w version, then with
w_t = w + delta_w * t, we get
   V_T <= V_0 - delta_w * sum_{t=0}^{T-1} (f_t - f*)
   w_T (f_T - f*) <= V_T  <=  V_0
   (f_T - f*) <= V_0 / w_T = (w + delta_w * 0) * 0 + initial quadratic / (w + delta_w * T)
                     = O(D^2 / T)
provided V_0 = O(D^2) and w + delta_w T = Theta(T).

So we want: max delta_w such that the constant-w LMI (V_{t+1} - V_t + delta_w (f - f*) <= 0)
is feasible.

This is exactly what we computed in step 06 — except we got c = 0 everywhere.

Let me check whether allowing time-varying QUADRATIC coefficients (a, b, d, w varying linearly in t)
plus delta_w > 0 yields a feasible LMI.
"""
from pathlib import Path
import json
import numpy as np
import cvxpy as cp
import sympy as sp


def build_descent_polynomial_growing(L_val, beta_val, eta_val):
    """V_t with QUADRATIC coefficients possibly growing linearly in t.

    V_t = w_t (f - f*) + (a + a' t) X^2 + (b + b' t) W^2 + (d + d' t) X W
    where X = y - y*, W = y - y_prev.

    With w_t = w_0 + delta_w * t.

    The descent at time t (substituting t = 0 wlog after shift):
       V_{t+1} - V_t = delta_w (f - f*) + a' X^2 + b' W^2 + d' X W   <- LINEAR in t = 0
                     + [constant terms from V_{t+1} - V_t structure]
    Hmm, but a' X_{t+1}^2 - a X_t^2 has TWO contributions: one from (a+a') X_{t+1}^2 - (a) X_t^2 = a (X_{t+1}^2 - X_t^2) + a' X_{t+1}^2.

    OK to keep this clean, let me parameterize as:
      V_t = w_t (f - f*) + (a_now) X^2 + (b_now) W^2 + (d_now) X W
    and (a_now, b_now, d_now, w_now) are NUMBERS at time t, while at time t+1 they're (a_next, b_next, d_next, w_next).
    The LMI checks one-step descent for each (a_now, ..., a_next, ...).
    """
    G, W, X, Gp, FE, FP = sp.symbols("G W X Gp FE FP", real=True)
    a, b, d, w = sp.symbols("a b d w", real=True)
    a2, b2, d2, w2 = sp.symbols("a2 b2 d2 w2", real=True)
    L, beta, eta = sp.S(L_val), sp.S(beta_val), sp.S(eta_val)

    dy = -eta * G + beta * W

    V_curr = w * FE + a * X ** 2 + b * W ** 2 + d * X * W
    Xnext = X + dy
    Wnext = dy
    f_next_minus_f_star = FE + G * dy + sp.Rational(1, 2) * L * dy ** 2
    V_next = w2 * f_next_minus_f_star + a2 * Xnext ** 2 + b2 * Wnext ** 2 + d2 * Xnext * Wnext

    diff = sp.expand(V_next - V_curr)
    return diff, (G, W, X, Gp, FE, FP), (a, b, d, w, a2, b2, d2, w2)


def build_lmi(L_val, beta_val, eta_val, w_growth=1.0):
    """w_growth = w_next - w. Find max delta_w such that V_{t+1} - V_t + delta_w * (f - f*) <= 0.

    Equivalently, set w_next = w + w_growth and find feasible (a, b, d, w, a_next, b_next, d_next).
    """
    diff, (G, W, X, Gp, FE, FP), (a, b, d, w, a2, b2, d2, w2) = \
        build_descent_polynomial_growing(L_val, beta_val, eta_val)

    a_v = cp.Variable()
    b_v = cp.Variable()
    d_v = cp.Variable()
    w_v = cp.Variable(nonneg=True)
    a2_v = cp.Variable()
    b2_v = cp.Variable()
    d2_v = cp.Variable()
    # w2 = w + w_growth
    w_growth_var = cp.Variable(nonneg=True)  # we want this to be > 0

    lam_IV = cp.Variable(nonneg=True)
    lam_IVp = cp.Variable(nonneg=True)
    lam_C2 = cp.Variable(nonneg=True)

    lam_IV_s = sp.symbols("lam_IV", real=True)
    lam_IVp_s = sp.symbols("lam_IVp", real=True)
    lam_C2_s = sp.symbols("lam_C2", real=True)
    g_IV = G * X - FE - sp.Rational(1, 2) / sp.S(L_val) * G ** 2
    g_IVp = Gp * (X - W) - FP - sp.Rational(1, 2) / sp.S(L_val) * Gp ** 2
    g_C2 = G * W - FE + FP

    # We want:  diff - lam_IV g_IV - lam_IVp g_IVp - lam_C2 g_C2  =  -[v]^T M [v], M >= 0.
    pos_combo = sp.expand(diff
                          - lam_IV_s * g_IV
                          - lam_IVp_s * g_IVp
                          - lam_C2_s * g_C2)

    poly = sp.Poly(pos_combo, FE, FP, G, W, X, Gp)

    var_list = [G, W, X, Gp]
    quad_monoms = {}
    for i in range(4):
        for j in range(i, 4):
            quad_monoms[(i, j)] = var_list[i] ** 2 if i == j else var_list[i] * var_list[j]

    sym_to_cp_map = {
        lam_IV_s: lam_IV, lam_IVp_s: lam_IVp, lam_C2_s: lam_C2,
        a: a_v, b: b_v, d: d_v, w: w_v,
        a2: a2_v, b2: b2_v, d2: d2_v,
    }
    # w2 = w + w_growth_var
    w2_value = w_v + w_growth_var

    def sym_to_cp_expr(expr):
        expr = sp.expand(expr)
        if expr == 0:
            return cp.Constant(0.0)
        terms = expr.as_ordered_terms() if expr.is_Add else [expr]
        out = cp.Constant(0.0)
        for term in terms:
            const_part = sp.S(1)
            cv_factors = []
            for f in term.as_ordered_factors():
                if f == w2:
                    cv_factors.append(("w2", None))
                elif f in sym_to_cp_map:
                    cv_factors.append(("var", sym_to_cp_map[f]))
                else:
                    const_part = const_part * f
            const_val = float(const_part)
            if not cv_factors:
                out = out + cp.Constant(const_val)
            elif len(cv_factors) == 1:
                kind, var = cv_factors[0]
                if kind == "w2":
                    out = out + const_val * w2_value
                else:
                    out = out + const_val * var
            else:
                # Multiple cvxpy factors → bilinear → cvxpy can't handle.
                # Print warning and skip (this should not occur for our setup).
                raise RuntimeError(f"Bilinear in cvxpy variables: {term}")
        return out

    constraints = []
    monoms_FE_FP = [FE, FE * G, FE * W, FE * X, FE * Gp, FE ** 2, FE * FP,
                    FP, FP * G, FP * W, FP * X, FP * Gp, FP ** 2]
    for m in monoms_FE_FP:
        try:
            coeff = poly.coeff_monomial(m)
        except Exception:
            coeff = sp.S(0)
        coeff = sp.expand(coeff)
        if coeff == 0:
            continue
        constraints.append(sym_to_cp_expr(coeff) == 0)

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
            constraints.append(M[i, j] == -sym_to_cp_expr(coeff) / 2)
            constraints.append(M[j, i] == -sym_to_cp_expr(coeff) / 2)

    constraints.append(M >> 0)
    # Force w_v small to make solution numerically stable; main objective is to maximize w_growth.
    constraints.append(w_v <= 1e3)

    objective = cp.Maximize(w_growth_var)
    prob = cp.Problem(objective, constraints)
    prob.solve(solver=cp.SCS, verbose=False)

    return {
        "status": prob.status,
        "w_growth": float(w_growth_var.value) if w_growth_var.value is not None else None,
        "w": float(w_v.value) if w_v.value is not None else None,
        "a": float(a_v.value) if a_v.value is not None else None,
        "b": float(b_v.value) if b_v.value is not None else None,
        "d": float(d_v.value) if d_v.value is not None else None,
        "a2": float(a2_v.value) if a2_v.value is not None else None,
        "b2": float(b2_v.value) if b2_v.value is not None else None,
        "d2": float(d2_v.value) if d2_v.value is not None else None,
        "lam_IV": float(lam_IV.value) if lam_IV.value is not None else None,
        "lam_IVp": float(lam_IVp.value) if lam_IVp.value is not None else None,
        "lam_C2": float(lam_C2.value) if lam_C2.value is not None else None,
    }


def main():
    L = 1.0
    print("Time-varying parametric Lyapunov: maximize w_growth (i.e., descent rate) per step.\n")
    print(f"{'beta':>5} {'eta':>5} {'status':>14} {'w_growth':>10} {'w':>8} {'a':>8} {'b':>8} {'d':>8} "
          f"{'a2':>8} {'b2':>8} {'d2':>8} {'lam_IV':>8} {'lam_IVp':>8} {'lam_C2':>8}")
    rows = []
    for beta in [0.0, 0.1, 0.2, 0.3, 0.4, 0.5]:
        for eta_factor in [0.5, 0.7, 1.0, 1.2, 1.5, 1.7, 2.0]:
            eta = eta_factor / L
            try:
                r = build_lmi(L, beta, eta)
            except Exception as e:
                r = {"status": f"err:{str(e)[:40]}"}
            status = r.get("status", "?")
            wg = r.get("w_growth")
            row = {"beta": beta, "eta": eta, **r}
            rows.append(row)
            if status in ("optimal", "optimal_inaccurate") and wg is not None and wg > 1e-6:
                print(f"{beta:>5.2f} {eta:>5.2f} {status:>14} {wg:>10.5f} "
                      f"{r['w']:>8.3f} {r['a']:>8.3f} {r['b']:>8.3f} {r['d']:>8.3f} "
                      f"{r['a2']:>8.3f} {r['b2']:>8.3f} {r['d2']:>8.3f} "
                      f"{r['lam_IV']:>8.3f} {r['lam_IVp']:>8.3f} {r['lam_C2']:>8.3f}")
            else:
                wg_str = f"{wg:.4f}" if isinstance(wg, float) else str(wg)
                print(f"{beta:>5.2f} {eta:>5.2f} {status:>14} {wg_str:>10}  (zero or fail)")

    out = Path(__file__).parent / "07_time_varying_lmi_results.json"
    out.write_text(json.dumps(rows, indent=2, default=str))
    print(f"\nResults: {out}")


if __name__ == "__main__":
    main()
