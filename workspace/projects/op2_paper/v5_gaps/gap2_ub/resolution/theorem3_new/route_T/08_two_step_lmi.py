"""Route T, step #8: 2-step state Lyapunov LMI.

Single-step LMI failed because PEP duals use skip-2 interpolation pairs.
2-step state Lyapunov V(y_t, y_{t-1}, y_{t-2}) can use them.

State: 9-dim symbolic vector
  (g_t, g_{t-1}, g_{t-2},  X_t, X_{t-1}, X_{t-2},  FE_t, FE_{t-1}, FE_{t-2})
where X_i = y_i - y* and FE_i = f(y_i) - f*.

Lyapunov:
  V_t = w_0 FE_t + w_1 FE_{t-1}
        + a_0 X_t^2 + a_1 X_{t-1}^2 + a_2 X_{t-2}^2
        + c_01 X_t X_{t-1} + c_02 X_t X_{t-2} + c_12 X_{t-1} X_{t-2}

V_{t+1} (with shifted indices):
  V_{t+1} = w_0 (f_{t+1} - f*) + w_1 FE_t
            + a_0 X_{t+1}^2 + a_1 X_t^2 + a_2 X_{t-1}^2
            + c_01 X_{t+1} X_t + c_02 X_{t+1} X_{t-1} + c_12 X_t X_{t-1}

Substitute X_{t+1} = X_t + dy_t where dy_t = -eta g_t + beta (X_t - X_{t-1}).
Substitute (f_{t+1} - f*) using L-smoothness UB:
  f_{t+1} - f* <= FE_t + g_t * dy_t + (L/2) dy_t^2.

Descent target: V_{t+1} - V_t + c_descent FE_t  <= 0   (over the L-smooth convex class).

Interpolation inequalities (each contributes a generator G_i, multiplied by lambda_i >= 0):
  (IV_t):    g_t * X_t      - FE_t     - (1/(2L)) g_t^2     >= 0
  (IV_{t-1}): g_{t-1} * X_{t-1} - FE_{t-1} - (1/(2L)) g_{t-1}^2 >= 0
  (IV_{t-2}): g_{t-2} * X_{t-2} - FE_{t-2} - (1/(2L)) g_{t-2}^2 >= 0
  (C_{t,t-1}):  g_t  * (X_t - X_{t-1})   - (FE_t - FE_{t-1}) - (1/(2L))(g_t - g_{t-1})^2     >= 0
  (C_{t-1,t}): g_{t-1}*(X_{t-1} - X_t)   - (FE_{t-1} - FE_t) - (1/(2L))(g_{t-1} - g_t)^2     >= 0
  (C_{t-1,t-2}): g_{t-1}*(X_{t-1}-X_{t-2}) - (FE_{t-1}-FE_{t-2}) - (1/(2L))(g_{t-1}-g_{t-2})^2 >= 0
  (C_{t-2,t-1}): g_{t-2}*(X_{t-2}-X_{t-1}) - (FE_{t-2}-FE_{t-1}) - (1/(2L))(g_{t-2}-g_{t-1})^2 >= 0
  (C_{t,t-2}):   g_t   *(X_t - X_{t-2})   - (FE_t - FE_{t-2})   - (1/(2L))(g_t - g_{t-2})^2     >= 0  ← skip-2!
  (C_{t-2,t}):   g_{t-2}*(X_{t-2} - X_t)   - (FE_{t-2} - FE_t)   - (1/(2L))(g_{t-2} - g_t)^2     >= 0  ← skip-2!

Total: 9 interpolation inequalities, 9 dual multipliers lambda_1..9 >= 0.

LMI: find (a_0, a_1, a_2, c_01, c_02, c_12, w_0, w_1, c_descent, lambda_1..9)
such that:
  diff(V_{t+1} - V_t + c_descent FE_t) - sum_i lambda_i G_i  = -[v]^T M [v],   M PSD,
  where v = (g_t, g_{t-1}, g_{t-2}, X_t, X_{t-1}, X_{t-2}) is 6-dim.

The (FE_t, FE_{t-1}, FE_{t-2})-coefficients in (diff - sum λ G) must be 0.

Workflow: sympy expand → coefficient extraction → cvxpy SDP.

Maximize: c_descent (subject to feasibility).
"""
from pathlib import Path
import json
import numpy as np
import cvxpy as cp
import sympy as sp


def build_diff_polynomial(L_val, beta_val, eta_val):
    """Build V_{t+1} - V_t + c_descent FE_t as sympy polynomial."""
    g_t, g_p1, g_p2 = sp.symbols("g_t g_p1 g_p2", real=True)        # _p1 = prev1, _p2 = prev2
    X_t, X_p1, X_p2 = sp.symbols("X_t X_p1 X_p2", real=True)
    FE_t, FE_p1, FE_p2 = sp.symbols("FE_t FE_p1 FE_p2", real=True)

    # Lyapunov coefficients
    a0, a1, a2 = sp.symbols("a0 a1 a2", real=True)
    c01, c02, c12 = sp.symbols("c01 c02 c12", real=True)
    w0, w1 = sp.symbols("w0 w1", real=True)
    c_descent = sp.symbols("c_descent", real=True)

    L, beta, eta = sp.S(L_val), sp.S(beta_val), sp.S(eta_val)

    # SHB: y_{t+1} = y_t - eta g_t + beta (y_t - y_{t-1}); equivalently dy_t = -eta g_t + beta (X_t - X_p1).
    dy_t = -eta * g_t + beta * (X_t - X_p1)
    X_t1 = X_t + dy_t  # X_{t+1}

    # Smoothness UB on f_{t+1} - f*:
    f_t1_minus_fstar_UB = FE_t + g_t * dy_t + sp.Rational(1, 2) * L * dy_t ** 2

    V_t = (w0 * FE_t + w1 * FE_p1
           + a0 * X_t ** 2 + a1 * X_p1 ** 2 + a2 * X_p2 ** 2
           + c01 * X_t * X_p1 + c02 * X_t * X_p2 + c12 * X_p1 * X_p2)
    V_t1 = (w0 * f_t1_minus_fstar_UB + w1 * FE_t
            + a0 * X_t1 ** 2 + a1 * X_t ** 2 + a2 * X_p1 ** 2
            + c01 * X_t1 * X_t + c02 * X_t1 * X_p1 + c12 * X_t * X_p1)

    diff = sp.expand(V_t1 - V_t + c_descent * FE_t)

    return diff, {
        "g_t": g_t, "g_p1": g_p1, "g_p2": g_p2,
        "X_t": X_t, "X_p1": X_p1, "X_p2": X_p2,
        "FE_t": FE_t, "FE_p1": FE_p1, "FE_p2": FE_p2,
        "a0": a0, "a1": a1, "a2": a2,
        "c01": c01, "c02": c02, "c12": c12,
        "w0": w0, "w1": w1,
        "c_descent": c_descent,
    }


def build_generators(L_val, S):
    """Build the 9 interpolation generators as sympy expressions."""
    L = sp.S(L_val)
    g_t, g_p1, g_p2 = S["g_t"], S["g_p1"], S["g_p2"]
    X_t, X_p1, X_p2 = S["X_t"], S["X_p1"], S["X_p2"]
    FE_t, FE_p1, FE_p2 = S["FE_t"], S["FE_p1"], S["FE_p2"]

    half_inv_L = sp.Rational(1, 2) / L

    G = {}
    # Interpolation at *
    G["IV_t"]   = g_t * X_t   - FE_t   - half_inv_L * g_t ** 2
    G["IV_p1"]  = g_p1 * X_p1 - FE_p1  - half_inv_L * g_p1 ** 2
    G["IV_p2"]  = g_p2 * X_p2 - FE_p2  - half_inv_L * g_p2 ** 2
    # Pair (i, j): convexity at j wrt i: f_i >= f_j + <g_j, x_i - x_j> + (1/(2L)) ||g_i - g_j||^2
    # Generator: f_i - f_j - <g_j, x_i - x_j> - (1/(2L))||g_i - g_j||^2 >= 0.
    # Below, "C_{i,j}" means generator with i in front position.
    G["C_t_p1"]   = (FE_t - FE_p1) - g_p1 * (X_t - X_p1) - half_inv_L * (g_t - g_p1) ** 2
    G["C_p1_t"]   = (FE_p1 - FE_t) - g_t * (X_p1 - X_t) - half_inv_L * (g_p1 - g_t) ** 2
    G["C_p1_p2"]  = (FE_p1 - FE_p2) - g_p2 * (X_p1 - X_p2) - half_inv_L * (g_p1 - g_p2) ** 2
    G["C_p2_p1"]  = (FE_p2 - FE_p1) - g_p1 * (X_p2 - X_p1) - half_inv_L * (g_p2 - g_p1) ** 2
    G["C_t_p2"]   = (FE_t - FE_p2) - g_p2 * (X_t - X_p2) - half_inv_L * (g_t - g_p2) ** 2  # skip-2
    G["C_p2_t"]   = (FE_p2 - FE_t) - g_t * (X_p2 - X_t) - half_inv_L * (g_p2 - g_t) ** 2  # skip-2

    return G


def build_lmi(L_val, beta_val, eta_val, fix_w_growth=None):
    """Build cvxpy LMI for given (L, beta, eta).

    fix_w_growth: if not None, fix c_descent = fix_w_growth (otherwise maximize).
    """
    diff, S = build_diff_polynomial(L_val, beta_val, eta_val)
    Gens = build_generators(L_val, S)

    # cvxpy variables for Lyapunov coefficients
    a0_v = cp.Variable()
    a1_v = cp.Variable()
    a2_v = cp.Variable()
    c01_v = cp.Variable()
    c02_v = cp.Variable()
    c12_v = cp.Variable()
    w0_v = cp.Variable(nonneg=True)
    w1_v = cp.Variable(nonneg=True)

    if fix_w_growth is None:
        c_descent_v = cp.Variable(nonneg=True)
    else:
        c_descent_v = cp.Constant(float(fix_w_growth))

    # Dual multipliers
    lam = {name: cp.Variable(nonneg=True) for name in Gens.keys()}

    # Build pos_combo = diff - sum lambda_i G_i  symbolically, with lambda symbols.
    lam_syms = {name: sp.symbols(f"lam_{name}", real=True) for name in Gens.keys()}
    pos_combo = sp.expand(diff)
    for name, gen in Gens.items():
        pos_combo = sp.expand(pos_combo - lam_syms[name] * gen)

    # We want pos_combo = -[v]^T M [v]   with M PSD, v = (g_t, g_p1, g_p2, X_t, X_p1, X_p2).
    # FE_t, FE_p1, FE_p2 coefficients (and their cross-products) must vanish.
    poly_vars = [S["FE_t"], S["FE_p1"], S["FE_p2"],
                 S["g_t"], S["g_p1"], S["g_p2"],
                 S["X_t"], S["X_p1"], S["X_p2"]]
    poly = sp.Poly(pos_combo, *poly_vars)

    # Vanishing monomials: anything involving FE_*.
    FE_monoms = []
    FE_list = [S["FE_t"], S["FE_p1"], S["FE_p2"]]
    other_list = [S["g_t"], S["g_p1"], S["g_p2"], S["X_t"], S["X_p1"], S["X_p2"]]
    # Linear FE
    for fe in FE_list:
        FE_monoms.append(fe)
        for x in other_list:
            FE_monoms.append(fe * x)
    # Quadratic FE
    for fe in FE_list:
        FE_monoms.append(fe ** 2)
    for i in range(3):
        for j in range(i + 1, 3):
            FE_monoms.append(FE_list[i] * FE_list[j])

    # Quadratic v-monomials: g_*^2, X_*^2, g_i g_j, X_i X_j, g_i X_j.
    quad_v_monoms = []
    for i in range(6):
        for j in range(i, 6):
            if i == j:
                quad_v_monoms.append((i, j, other_list[i] ** 2))
            else:
                quad_v_monoms.append((i, j, other_list[i] * other_list[j]))

    # Convert sympy expressions to cvxpy expressions.
    sym_to_cp = {
        S["a0"]: a0_v, S["a1"]: a1_v, S["a2"]: a2_v,
        S["c01"]: c01_v, S["c02"]: c02_v, S["c12"]: c12_v,
        S["w0"]: w0_v, S["w1"]: w1_v,
        S["c_descent"]: c_descent_v,
    }
    for name in Gens.keys():
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
            cval = float(const_part)
            if cv_factor is None:
                out = out + cp.Constant(cval)
            else:
                out = out + cval * cv_factor
        return out

    constraints = []

    # FE coefficients must be zero
    for m in FE_monoms:
        try:
            cf = poly.coeff_monomial(m)
        except Exception:
            cf = sp.S(0)
        cf = sp.expand(cf)
        if cf == 0:
            continue
        constraints.append(sym_to_cp_expr(cf) == 0)

    # Build M PSD
    M = cp.Variable((6, 6), symmetric=True)
    for i, j, mon in quad_v_monoms:
        try:
            cf = poly.coeff_monomial(mon)
        except Exception:
            cf = sp.S(0)
        cf = sp.expand(cf)
        if i == j:
            constraints.append(M[i, i] == -sym_to_cp_expr(cf))
        else:
            constraints.append(M[i, j] == -sym_to_cp_expr(cf) / 2)
            constraints.append(M[j, i] == -sym_to_cp_expr(cf) / 2)

    constraints.append(M >> 0)

    # Bound to keep numerical stability
    constraints.append(w0_v + w1_v <= 1e3)

    if fix_w_growth is None:
        objective = cp.Maximize(c_descent_v)
    else:
        objective = cp.Minimize(0)

    prob = cp.Problem(objective, constraints)
    prob.solve(solver=cp.SCS, verbose=False, max_iters=20000)

    return {
        "status": prob.status,
        "c_descent": float(c_descent_v.value) if hasattr(c_descent_v, "value") and c_descent_v.value is not None else
                     (float(fix_w_growth) if fix_w_growth is not None else None),
        "a0": float(a0_v.value) if a0_v.value is not None else None,
        "a1": float(a1_v.value) if a1_v.value is not None else None,
        "a2": float(a2_v.value) if a2_v.value is not None else None,
        "c01": float(c01_v.value) if c01_v.value is not None else None,
        "c02": float(c02_v.value) if c02_v.value is not None else None,
        "c12": float(c12_v.value) if c12_v.value is not None else None,
        "w0": float(w0_v.value) if w0_v.value is not None else None,
        "w1": float(w1_v.value) if w1_v.value is not None else None,
        "lambdas": {name: (float(lam[name].value) if lam[name].value is not None else None)
                    for name in Gens.keys()},
    }


def main():
    L = 1.0
    print("2-step state Lyapunov LMI: maximize c_descent.\n")
    header = (f"{'beta':>5} {'eta':>5} {'status':>14} {'c_desc':>9} "
              f"{'a0':>7} {'a1':>7} {'a2':>7} {'c01':>7} {'c02':>7} {'c12':>7} "
              f"{'w0':>7} {'w1':>7}  λ_skip2")
    print(header)
    print("-" * len(header))
    rows = []
    for beta in [0.0, 0.1, 0.3, 0.5]:
        for eta_factor in [0.5, 0.7, 1.0, 1.2, 1.5, 1.7, 2.0]:
            eta = eta_factor / L
            try:
                r = build_lmi(L, beta, eta)
            except Exception as e:
                r = {"status": f"err:{str(e)[:40]}", "c_descent": None}
            row = {"beta": beta, "eta": eta, **r}
            rows.append(row)
            status = r["status"]
            cd = r.get("c_descent")
            if isinstance(cd, float) and cd > 1e-5 and status in ("optimal", "optimal_inaccurate"):
                lam_skip2 = r["lambdas"].get("C_t_p2", 0.0) + r["lambdas"].get("C_p2_t", 0.0)
                print(f"{beta:>5.2f} {eta:>5.2f} {status:>14} {cd:>9.5f} "
                      f"{r['a0']:>7.3f} {r['a1']:>7.3f} {r['a2']:>7.3f} "
                      f"{r['c01']:>7.3f} {r['c02']:>7.3f} {r['c12']:>7.3f} "
                      f"{r['w0']:>7.3f} {r['w1']:>7.3f}  {lam_skip2:>6.3f}")
            else:
                cd_str = f"{cd:.4f}" if isinstance(cd, float) else str(cd)
                print(f"{beta:>5.2f} {eta:>5.2f} {status:>14} {cd_str:>9}    (zero or fail)")

    out = Path(__file__).parent / "08_two_step_lmi_results.json"
    out.write_text(json.dumps(rows, indent=2, default=str))
    print(f"\nResults: {out}")


if __name__ == "__main__":
    main()
