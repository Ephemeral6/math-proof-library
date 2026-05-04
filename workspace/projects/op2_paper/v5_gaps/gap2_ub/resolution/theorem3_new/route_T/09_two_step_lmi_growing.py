"""Route T, step #9: 2-step state Lyapunov with LINEARLY-GROWING front weight.

Setup:
  V_t = w_t (f(y_t) - f*) + Q(X_t, X_{t-1}, X_{t-2})
where w_t = w_0 + alpha * t,  Q is constant in t.

Then V_{t+1} - V_t involves:
  V_{t+1} uses (w_0 + alpha (t+1)) on (f_{t+1} - f*).
  After smoothness UB:  (f_{t+1} - f*) <= FE_t + g_t dy + (L/2) dy^2.

So V_{t+1} - V_t (with smoothness UB) = (w_0 + alpha(t+1)) [FE_t + g_t dy + (L/2) dy^2]
                                         - (w_0 + alpha t) FE_t
                                         + Q(X_{t+1}, X_t, X_{t-1}) - Q(X_t, X_{t-1}, X_{t-2})

  = alpha FE_t + (w_0 + alpha(t+1)) [g_t dy + (L/2) dy^2] + Q-diff

For the LMI to be feasible UNIFORMLY in t, we treat w_0 + alpha(t+1) as a single free
variable W (representing the "current weight" at time t+1). The LMI is then:

  alpha FE_t + W [g_t dy + (L/2) dy^2] + Q-diff <= sum lambda_i G_i  (with lambda_i >= 0, M PSD).

Feasibility/scaling: if (alpha, W, a's, c's, lambdas) is feasible, so is (c alpha, c W, c a, c c, c lambdas) for c > 0.
So feasibility is a CONE; we can NORMALIZE W = 1 (or any positive constant) and ask: max alpha?

If alpha > 0 is feasible at W = 1, then for any t the choice (W = w_0 + alpha(t+1), alpha) is
proportional and also feasible. Hence uniform-in-t feasibility.

For last-iterate rate: w_T = w_0 + alpha T;  V_T >= w_T FE_T (if Q is PSD on the X-state);
                          V_T <= V_0 = w_0 FE_0 + Q(X_0, X_-1, X_-2) <= O(D^2 + w_0 FE_0).
                       So  FE_T <= V_0 / w_T = O(D^2 / (alpha T)).

Hence the rate is O(D^2 / (alpha T)) = O(1/T) provided alpha > 0.

Implementation: take the 2-step LMI from step 08 but replace `w0 * f_t1_minus_fstar_UB`
with `W * f_t1_minus_fstar_UB` where W is a new cvxpy variable. Drop w1 and friends (just
keep the front weight). Q has 6 free coefficients (a_0, a_1, a_2, c_01, c_02, c_12).
"""
from pathlib import Path
import json
import numpy as np
import cvxpy as cp
import sympy as sp


def build_diff_polynomial_growing(L_val, beta_val, eta_val):
    g_t, g_p1, g_p2 = sp.symbols("g_t g_p1 g_p2", real=True)
    X_t, X_p1, X_p2 = sp.symbols("X_t X_p1 X_p2", real=True)
    FE_t, FE_p1, FE_p2 = sp.symbols("FE_t FE_p1 FE_p2", real=True)

    a0, a1, a2 = sp.symbols("a0 a1 a2", real=True)
    c01, c02, c12 = sp.symbols("c01 c02 c12", real=True)
    W, alpha = sp.symbols("W alpha", real=True)

    L, beta, eta = sp.S(L_val), sp.S(beta_val), sp.S(eta_val)

    dy_t = -eta * g_t + beta * (X_t - X_p1)
    X_t1 = X_t + dy_t
    f_t1_UB = FE_t + g_t * dy_t + sp.Rational(1, 2) * L * dy_t ** 2

    # V_t  uses no FE-weight on y_{t-1} or y_{t-2} (drop w1; we capture it via Q only).
    V_t = (a0 * X_t ** 2 + a1 * X_p1 ** 2 + a2 * X_p2 ** 2
           + c01 * X_t * X_p1 + c02 * X_t * X_p2 + c12 * X_p1 * X_p2)
    Q_next = (a0 * X_t1 ** 2 + a1 * X_t ** 2 + a2 * X_p1 ** 2
              + c01 * X_t1 * X_t + c02 * X_t1 * X_p1 + c12 * X_t * X_p1)

    # V_{t+1} - V_t (with growing front weight handled separately):
    # V_{t+1} - V_t  =  W * (f_{t+1} - f*)_UB - 0 * FE_t  +  Q_next - Q_t  +  alpha * FE_t   (for the linear-w drift)
    #               =  W * f_t1_UB + Q_next - Q_t + alpha * FE_t
    # (We absorb -alpha t * FE_t cancellations into the +alpha * FE_t standalone term.)
    diff = sp.expand(W * f_t1_UB + Q_next - V_t + alpha * FE_t)
    # Wait: the actual V_t has w_t * FE_t = (w_0 + alpha t) * FE_t.
    # So V_t = (w_0 + alpha t) FE_t + Q_t.
    # V_{t+1} = (w_0 + alpha (t+1)) FE_{t+1} + Q_{t+1}
    #        ≤ (w_0 + alpha (t+1)) [FE_t + g dy + (L/2) dy²] + Q_{t+1}
    # V_{t+1} - V_t ≤ (w_0 + alpha (t+1)) [FE_t + ...] - (w_0 + alpha t) FE_t + (Q_{t+1} - Q_t)
    #               = alpha FE_t + (w_0 + alpha (t+1)) [...] + (Q diff)
    # Setting W := w_0 + alpha (t+1) (free):
    #               = alpha FE_t + W * [g dy + (L/2) dy²] + (Q diff)
    #
    # Note: the FE_t coefficient from the smoothness UB is W (not w_0). So the FE_t TOTAL coefficient is
    #     alpha + W (from substituting f_{t+1}_UB) .... wait need to redo.
    #
    # f_{t+1}_UB = FE_t + g dy + (L/2) dy²  has FE_t coefficient = 1.
    # So W * f_{t+1}_UB has FE_t coefficient W.
    #
    # V_t has FE_t coefficient (w_0 + alpha t).
    #
    # V_{t+1}_UB - V_t  has FE_t coefficient = W - (w_0 + alpha t).
    #   With W = w_0 + alpha (t+1) = w_0 + alpha t + alpha: W - (w_0 + alpha t) = alpha.
    #
    # So FE_t coefficient = alpha, as expected.
    #
    # The smoothness UB also contributes W on g_t dy, (L/2) dy² terms.
    #
    # Above expression `diff = W*f_t1_UB + Q_next - V_t + alpha*FE_t` treats this as:
    #   V_{t+1}_UB - V_t = W*f_t1_UB - 0 + Q_next - V_t (V_t doesn't have FE_t in its symbolic def above,
    #     since I dropped it — we put FE_t IN diff via "+alpha FE_t" instead).
    #
    # Equivalently: my current formula diff = W*f_t1_UB + Q_next - V_t + alpha*FE_t evaluates to:
    #   W * (FE_t + g dy + (L/2) dy²) + Q_next - Q_t + alpha FE_t
    # = (W + alpha) FE_t + W (g dy + (L/2) dy²) + Q_next - Q_t
    #
    # But the CORRECT expression should be alpha FE_t + W (g dy + ...) + Q diff.
    # I'm OVER by W * FE_t.
    #
    # FIX: subtract W * FE_t at the end. Or equivalently, replace V_t in `diff` with V_t + W*FE_t (so V_t
    # carries the FE_t weight).
    #
    # Cleaner: explicitly separate. Let me redo.
    pass

    # CORRECTED:
    # V_t (full) = w_t * FE_t + Q_t,  w_t free (cvxpy var)
    # V_{t+1} = w_{t+1} * FE_{t+1} + Q_{t+1};  set w_{t+1} = w_t + alpha (free).
    #         <= w_{t+1} * f_t1_UB + Q_{t+1}
    # V_{t+1} - V_t <= w_{t+1} f_t1_UB + Q_{t+1} - w_t FE_t - Q_t
    #               = w_{t+1} (FE_t + g dy + (L/2) dy²) - w_t FE_t + Q_{t+1} - Q_t
    #               = (w_{t+1} - w_t) FE_t + w_{t+1} (g dy + (L/2) dy²) + Q diff
    #               = alpha FE_t + w_{t+1} (g dy + (L/2) dy²) + Q diff.
    # Define W := w_{t+1} (free). Then diff = alpha FE_t + W (g dy + (L/2) dy²) + Q diff.

    diff_correct = sp.expand(alpha * FE_t + W * (g_t * dy_t + sp.Rational(1, 2) * L * dy_t ** 2)
                              + Q_next - V_t)

    return diff_correct, {
        "g_t": g_t, "g_p1": g_p1, "g_p2": g_p2,
        "X_t": X_t, "X_p1": X_p1, "X_p2": X_p2,
        "FE_t": FE_t, "FE_p1": FE_p1, "FE_p2": FE_p2,
        "a0": a0, "a1": a1, "a2": a2,
        "c01": c01, "c02": c02, "c12": c12,
        "W": W, "alpha": alpha,
    }


def build_generators(L_val, S):
    L = sp.S(L_val)
    g_t, g_p1, g_p2 = S["g_t"], S["g_p1"], S["g_p2"]
    X_t, X_p1, X_p2 = S["X_t"], S["X_p1"], S["X_p2"]
    FE_t, FE_p1, FE_p2 = S["FE_t"], S["FE_p1"], S["FE_p2"]
    half_inv_L = sp.Rational(1, 2) / L

    G = {}
    G["IV_t"]  = g_t * X_t   - FE_t   - half_inv_L * g_t ** 2
    G["IV_p1"] = g_p1 * X_p1 - FE_p1  - half_inv_L * g_p1 ** 2
    G["IV_p2"] = g_p2 * X_p2 - FE_p2  - half_inv_L * g_p2 ** 2
    G["C_t_p1"]   = (FE_t - FE_p1) - g_p1 * (X_t - X_p1)   - half_inv_L * (g_t - g_p1) ** 2
    G["C_p1_t"]   = (FE_p1 - FE_t) - g_t * (X_p1 - X_t)    - half_inv_L * (g_p1 - g_t) ** 2
    G["C_p1_p2"]  = (FE_p1 - FE_p2) - g_p2 * (X_p1 - X_p2) - half_inv_L * (g_p1 - g_p2) ** 2
    G["C_p2_p1"]  = (FE_p2 - FE_p1) - g_p1 * (X_p2 - X_p1) - half_inv_L * (g_p2 - g_p1) ** 2
    G["C_t_p2"]   = (FE_t - FE_p2) - g_p2 * (X_t - X_p2)   - half_inv_L * (g_t - g_p2) ** 2  # skip-2
    G["C_p2_t"]   = (FE_p2 - FE_t) - g_t * (X_p2 - X_t)    - half_inv_L * (g_p2 - g_t) ** 2  # skip-2
    return G


def build_lmi(L_val, beta_val, eta_val):
    diff, S = build_diff_polynomial_growing(L_val, beta_val, eta_val)
    Gens = build_generators(L_val, S)

    a0_v = cp.Variable()
    a1_v = cp.Variable()
    a2_v = cp.Variable()
    c01_v = cp.Variable()
    c02_v = cp.Variable()
    c12_v = cp.Variable()
    W_v = cp.Variable(nonneg=True)
    alpha_v = cp.Variable(nonneg=True)
    lam = {name: cp.Variable(nonneg=True) for name in Gens.keys()}

    lam_syms = {name: sp.symbols(f"lam_{name}", real=True) for name in Gens.keys()}
    pos_combo = sp.expand(diff)
    for name, gen in Gens.items():
        pos_combo = sp.expand(pos_combo - lam_syms[name] * gen)

    poly_vars = [S["FE_t"], S["FE_p1"], S["FE_p2"],
                 S["g_t"], S["g_p1"], S["g_p2"],
                 S["X_t"], S["X_p1"], S["X_p2"]]
    poly = sp.Poly(pos_combo, *poly_vars)

    FE_list = [S["FE_t"], S["FE_p1"], S["FE_p2"]]
    other_list = [S["g_t"], S["g_p1"], S["g_p2"], S["X_t"], S["X_p1"], S["X_p2"]]

    FE_monoms = []
    for fe in FE_list:
        FE_monoms.append(fe)
        for x in other_list:
            FE_monoms.append(fe * x)
    for fe in FE_list:
        FE_monoms.append(fe ** 2)
    for i in range(3):
        for j in range(i + 1, 3):
            FE_monoms.append(FE_list[i] * FE_list[j])

    quad_v_monoms = []
    for i in range(6):
        for j in range(i, 6):
            if i == j:
                quad_v_monoms.append((i, j, other_list[i] ** 2))
            else:
                quad_v_monoms.append((i, j, other_list[i] * other_list[j]))

    sym_to_cp = {
        S["a0"]: a0_v, S["a1"]: a1_v, S["a2"]: a2_v,
        S["c01"]: c01_v, S["c02"]: c02_v, S["c12"]: c12_v,
        S["W"]: W_v, S["alpha"]: alpha_v,
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
    for m in FE_monoms:
        try:
            cf = poly.coeff_monomial(m)
        except Exception:
            cf = sp.S(0)
        cf = sp.expand(cf)
        if cf == 0: continue
        constraints.append(sym_to_cp_expr(cf) == 0)

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

    # alpha = 1; W free (positive); we MINIMIZE W subject to feasibility.
    # If feasible at finite W, then for any t >= W-1, V_{t+1} <= V_t holds (uniform-in-t).
    constraints.append(alpha_v == 1.0)
    constraints.append(cp.abs(a0_v) <= 1000)
    constraints.append(cp.abs(a1_v) <= 1000)
    constraints.append(cp.abs(a2_v) <= 1000)
    constraints.append(cp.abs(c01_v) <= 1000)
    constraints.append(cp.abs(c02_v) <= 1000)
    constraints.append(cp.abs(c12_v) <= 1000)

    objective = cp.Minimize(W_v)
    prob = cp.Problem(objective, constraints)
    try:
        prob.solve(solver=cp.SCS, verbose=False, max_iters=50000)
    except Exception:
        # Try different solver
        prob.solve(solver=cp.CLARABEL, verbose=False)

    return {
        "status": prob.status,
        "alpha": float(alpha_v.value) if alpha_v.value is not None else None,
        "W": float(W_v.value) if W_v.value is not None else None,
        "a0": float(a0_v.value) if a0_v.value is not None else None,
        "a1": float(a1_v.value) if a1_v.value is not None else None,
        "a2": float(a2_v.value) if a2_v.value is not None else None,
        "c01": float(c01_v.value) if c01_v.value is not None else None,
        "c02": float(c02_v.value) if c02_v.value is not None else None,
        "c12": float(c12_v.value) if c12_v.value is not None else None,
        "lambdas": {name: (float(lam[name].value) if lam[name].value is not None else None)
                    for name in Gens.keys()},
    }


def main():
    L = 1.0
    print("2-step state Lyapunov: alpha=1, minimize W (= w_{t+1}). Smaller W means tighter Lyapunov.")
    print("If W = w_min < ∞, then for t >= w_min - 1, V_{t+1} <= V_t holds, so f_T <= V_0 / (αT) = O(1/T).\n")
    header = (f"{'beta':>5} {'eta':>5} {'status':>16} {'W_min':>9} "
              f"{'a0':>7} {'a1':>7} {'a2':>7} {'c01':>7} {'c02':>7} {'c12':>7}  λ_skip2")
    print(header); print("-" * len(header))
    rows = []
    for beta in [0.0, 0.1, 0.2, 0.3, 0.4, 0.5]:
        for eta_factor in [0.5, 0.7, 1.0, 1.2, 1.5, 1.7, 2.0]:
            eta = eta_factor / L
            try:
                r = build_lmi(L, beta, eta)
            except Exception as e:
                r = {"status": f"err:{str(e)[:40]}", "W": None, "alpha": None}
            row = {"beta": beta, "eta": eta, **r}
            rows.append(row)
            status = r["status"]
            W = r.get("W")
            if isinstance(W, float) and W < 1e6 and W > 0 and status in ("optimal", "optimal_inaccurate"):
                lam_skip2 = (r["lambdas"].get("C_t_p2", 0.0) or 0) + (r["lambdas"].get("C_p2_t", 0.0) or 0)
                print(f"{beta:>5.2f} {eta:>5.2f} {status:>16} {W:>9.4f} "
                      f"{r['a0']:>7.3f} {r['a1']:>7.3f} {r['a2']:>7.3f} "
                      f"{r['c01']:>7.3f} {r['c02']:>7.3f} {r['c12']:>7.3f}  {lam_skip2:>6.3f}")
            else:
                W_str = f"{W:.4f}" if isinstance(W, float) else str(W)
                print(f"{beta:>5.2f} {eta:>5.2f} {status:>16} {W_str:>9}    (infeas)")

    out = Path(__file__).parent / "09_two_step_lmi_growing_results.json"
    out.write_text(json.dumps(rows, indent=2, default=str))
    print(f"\nResults: {out}")


if __name__ == "__main__":
    main()
