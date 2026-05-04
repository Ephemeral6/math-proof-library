"""Route T, step #5: ONE-STEP descent LMI for the twisted Lyapunov.

We formulate, AS AN LMI, the question:
    "Given a Lyapunov V_t = w_t (f - f*) + 0.5 ||alpha (y-y*) + (y-y_prev)/eta||^2 + (gamma/2) ||y-y*||^2,
     what (w_t, gamma, eta, beta) make V_{t+1} - V_t <= -c (f(y_t)-f*) hold for ALL L-smooth convex f?"

The state at time t is described by (G, W, X) := (g, y - y_prev, y - y_*) and FE := f - f*.
Plus FP := f(y_prev) - f* and Gprev := g(y_prev), if we want to use convexity at y_prev.

The interpolation conditions are:
  (IV)   G * X >= FE + (1/(2L)) G^2.
  (IV')  Gprev * Xprev >= FP + (1/(2L)) Gprev^2,  where Xprev = y_prev - y_* = X - W.
  (C2)   <g, y - y_prev> = G * W >= FE - FP.    [convexity of f at y_prev wrt y]
  (S)    f_next - FE <= G * dy + (L/2) dy^2,    where dy = -eta G + beta W.

We test:  V_{t+1} <= V_t - c * FE,  for c = c(eta, beta, w_t, gamma) > 0.

Approach: write V_{t+1} - V_t as a quadratic form in (G, W, X, Gprev, FE, FP), substitute
out the f_next via (S), and try to write the form as a non-negative combination of the LHS
of (IV), (IV'), (C2) plus a -c FE.

This is exactly the WEIGHTED-SUM-OF-SQUARES / dual SDP feasibility problem for SHB.

For each (eta, beta, w_t, gamma), we solve:
    Find lambda_IV, lambda_IV', lambda_C2 >= 0 (Lagrange multipliers)
    such that
       V_{t+1} - V_t + c * FE
    = lambda_IV * (G X - FE - (1/(2L)) G^2)
    + lambda_IV' * (Gprev * (X - W) - FP - (1/(2L)) Gprev^2)
    + lambda_C2 * (G W - FE + FP)
    + lambda_S * (G dy + (L/2) dy^2 - (f_next - FE))    (this one's an equality at f_next; just substitute)

with the residual being a NEGATIVE quadratic form in (G, W, X, Gprev) -- i.e., expressible as
- (some positive semi-definite matrix in (G, W, X, Gprev))^T (...).

If feasible: descent is proven with constant c, AND we obtain the lambdas (which give the
Lyapunov coefficients explicitly).

If infeasible: that particular (w_t, gamma, eta, beta) does not give a one-step descent
with this constant c.

Implementation: cvxpy + SDP.
"""
from pathlib import Path
import json
import numpy as np
import cvxpy as cp
import sympy as sp


def one_step_descent_lmi(L, beta, eta, w_t, gamma, c_target, w_next=None, verbose=False):
    """Try to certify V_{t+1} - V_t <= -c_target * FE.

    If w_next is None, default to w_t (constant weights).
    """
    if w_next is None:
        w_next = w_t

    # Build symbolic V_{t+1} - V_t as a polynomial in (G, W, X, Gp, FE, FP).
    # Then represent each generator (IV, IV', C2) as a polynomial.

    G, W, X, Gp, FE, FP = sp.symbols("G W X Gp FE FP", real=True)
    alpha = (1 - beta) / eta
    dy = -eta * G + beta * W
    Xprev = X - W

    # Lyapunov values
    twist_curr = alpha * X + W / eta
    twist_next = alpha * (X + dy) + dy / eta

    V_curr = w_t * FE + sp.Rational(1, 2) * twist_curr ** 2 + sp.Rational(1, 2) * gamma * X ** 2
    # Smoothness sub: f_next - f* <= FE + G dy + (L/2) dy^2 - s_S; use slack s_S in (G, W, X, Gp, FE, FP) variables.
    # Equivalently: replace (f_next - f*) by upper bound, with a non-negative slack (which we'll absorb into the LMI).
    f_next_ub = FE + G * dy + sp.Rational(1, 2) * L * dy ** 2  # this is (f_next - f*) "upper bound"

    V_next = w_next * f_next_ub + sp.Rational(1, 2) * twist_next ** 2 + sp.Rational(1, 2) * gamma * (X + dy) ** 2

    diff = sp.expand(V_next - V_curr + c_target * FE)
    # Note: by replacing f_next with its upper bound, V_next is an upper bound on the actual V_next;
    # so showing diff <= 0 with this substitution is sufficient (slack s_S is implicitly absorbed
    # in lambda_S below; we don't need it as a separate variable).

    # Generators:
    g_IV  = G * X - FE - sp.Rational(1, 2) / L * G ** 2          # >= 0
    g_IVp = Gp * Xprev - FP - sp.Rational(1, 2) / L * Gp ** 2    # >= 0
    g_C2  = G * W - FE + FP                                       # >= 0
    g_C1p = Gp * (- Xprev) - FP - sp.Rational(1, 2) / L * Gp ** 2  # not standard, we drop
    # Also need (* relation for FP):  -Gp * Xprev >= -(f_prev - f*) + (1/(2L)) ||Gp||^2 -- this is  the OTHER direction
    # of interpolation.  Actually: from interpolation at (*, prev): 0 - FP - <Gp, x* - x_prev> >= (1/2L)||Gp||^2
    # ie -FP + Gp*Xprev >= (1/2L) ||Gp||^2 -- same as g_IVp. So g_IVp covers it.

    # We'd like:  diff = - lambda_IV * g_IV - lambda_IVp * g_IVp - lambda_C2 * g_C2 - <residual quadratic>
    # i.e., diff + lambda_IV * g_IV + lambda_IVp * g_IVp + lambda_C2 * g_C2 = - residual quadratic <= 0.
    # The residual quadratic is in (G, W, X, Gp).

    # Set up cvxpy:
    lam_IV = cp.Variable(nonneg=True)
    lam_IVp = cp.Variable(nonneg=True)
    lam_C2 = cp.Variable(nonneg=True)
    # Residual matrix M in S^4 (variables ordered as G, W, X, Gp).
    M = cp.Variable((4, 4), symmetric=True)

    # Residual quadratic form: -[G W X Gp] M [G W X Gp]^T  (we want this to be the residual, M >= 0)
    # i.e., diff + lam_IV * g_IV + lam_IVp * g_IVp + lam_C2 * g_C2  =  -[v]^T M [v]
    # where v = (G, W, X, Gp).

    # We need ZERO terms involving FE, FP (since they're not part of v).
    # So the FE coefficient in (diff + lam_IV * g_IV + lam_IVp * g_IVp + lam_C2 * g_C2) must be 0;
    # similarly FP. Let's compute these.

    pos_combo = (diff
                 + lam_IV_sym * g_IV
                 + lam_IVp_sym * g_IVp
                 + lam_C2_sym * g_C2) if False else None  # placeholder; we'll do via sympy

    lam_IV_sym, lam_IVp_sym, lam_C2_sym = sp.symbols("lIV lIVp lC2", nonnegative=True)
    pos_combo = sp.expand(diff
                           + lam_IV_sym * g_IV
                           + lam_IVp_sym * g_IVp
                           + lam_C2_sym * g_C2)

    # Coefficients of FE, FP, FE^2, FP^2, FE*FP must all be zero.
    monoms_zero = [FE, FP, FE * G, FE * W, FE * X, FE * Gp,
                   FP * G, FP * W, FP * X, FP * Gp,
                   FE * FE, FP * FP, FE * FP]
    eqns = []
    poly = sp.Poly(pos_combo, FE, FP, G, W, X, Gp)
    for m in monoms_zero:
        try:
            eqns.append(sp.simplify(poly.coeff_monomial(m)))
        except Exception:
            eqns.append(sp.S(0))

    # Quadratic-form coefficients in (G, W, X, Gp) — these become entries of M.
    var_list = [G, W, X, Gp]
    quad_entries = sp.zeros(4, 4)
    for i in range(4):
        for j in range(i, 4):
            if i == j:
                m = var_list[i] ** 2
                c_ij = poly.coeff_monomial(m)
            else:
                m = var_list[i] * var_list[j]
                c_ij = poly.coeff_monomial(m)
            # We want pos_combo's quadratic part = -[v]^T M [v].
            # quadratic part has G^2 coefficient = -M[0,0]; G*W coeff = -2 M[0,1]; etc.
            if i == j:
                quad_entries[i, j] = -c_ij  # M[i,i]
            else:
                quad_entries[i, j] = -c_ij / 2
                quad_entries[j, i] = -c_ij / 2

    # Build cvxpy constraints from these symbolic equations.
    # Substitute lambda symbols by cvxpy variables.
    sub_map = {lam_IV_sym: lam_IV, lam_IVp_sym: lam_IVp, lam_C2_sym: lam_C2}

    def sym_to_cp(expr):
        # Convert a linear sympy expression in (lIV, lIVp, lC2) to a cvxpy expression.
        expr = sp.simplify(expr)
        if expr == 0:
            return cp.Constant(0.0)
        terms = expr.as_ordered_terms() if expr.is_Add else [expr]
        out = cp.Constant(0.0)
        for t in terms:
            # t = coef * sym, or t = coef * 1
            const_part = sp.S(1); var_part = None
            for f in t.as_ordered_factors():
                if f in sub_map:
                    var_part = f
                else:
                    const_part = const_part * f
            const_val = float(const_part)
            if var_part is None:
                out = out + cp.Constant(const_val)
            else:
                out = out + const_val * sub_map[var_part]
        return out

    constraints = []
    for eq in eqns:
        constraints.append(sym_to_cp(eq) == 0)

    # M entries: convert each entry's symbolic value to cvxpy expression,
    # and require M[i,j] == that expression.
    M_entries_eqs = []
    for i in range(4):
        for j in range(4):
            entry = sp.simplify(quad_entries[i, j])
            constraints.append(M[i, j] == sym_to_cp(entry))

    constraints.append(M >> 0)

    objective = cp.Minimize(0)  # feasibility
    problem = cp.Problem(objective, constraints)
    try:
        problem.solve(solver=cp.SCS, verbose=verbose)
    except Exception as e:
        return {"feasible": False, "error": str(e)}

    if problem.status not in ("optimal", "optimal_inaccurate"):
        return {"feasible": False, "status": problem.status}

    return {
        "feasible": True,
        "status": problem.status,
        "lam_IV": float(lam_IV.value),
        "lam_IVp": float(lam_IVp.value),
        "lam_C2": float(lam_C2.value),
        "M": M.value.tolist() if M.value is not None else None,
        "c_target": c_target,
    }


def main():
    L = 1.0
    print("Probing one-step descent LMI feasibility:")
    print("Sweep over (beta, eta) at gamma=0, w_t=1, w_next=1, find max c with feasible LMI.")

    grid = []
    for beta in [0.0, 0.1, 0.3, 0.5]:
        for eta_factor in [0.5, 0.8, 1.0, 1.2, 1.5, 1.8, 2.0]:
            for c_target_div_L in [0.0, 0.1, 0.5, 1.0, 1.5, 2.0]:
                eta = eta_factor / L
                c_target = c_target_div_L * L  # absolute c
                grid.append((beta, eta, c_target))

    rows = []
    print(f"{'beta':>6} {'eta':>6} {'c':>6} {'feasible':>10} {'lam_IV':>10} {'lam_IVp':>10} {'lam_C2':>10}")
    for beta, eta, c_target in grid:
        try:
            r = one_step_descent_lmi(L, beta, eta, w_t=1.0, gamma=0.0, c_target=c_target, w_next=1.0)
        except Exception as e:
            r = {"feasible": False, "error": str(e)[:60]}
        rows.append({"beta": beta, "eta": eta, "c": c_target, "result": r})
        if r.get("feasible"):
            print(f"{beta:>6.2f} {eta:>6.3f} {c_target:>6.3f} {'YES':>10} "
                  f"{r['lam_IV']:>10.4f} {r['lam_IVp']:>10.4f} {r['lam_C2']:>10.4f}")
        else:
            print(f"{beta:>6.2f} {eta:>6.3f} {c_target:>6.3f} {'no':>10}    {r.get('error', r.get('status',''))[:30]}")

    out = Path(__file__).parent / "05_one_step_lmi_results.json"
    out.write_text(json.dumps(rows, indent=2, default=str))
    print(f"\nResults: {out}")


if __name__ == "__main__":
    main()
