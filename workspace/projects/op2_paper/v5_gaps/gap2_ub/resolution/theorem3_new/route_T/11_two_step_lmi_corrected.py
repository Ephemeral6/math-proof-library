"""Route T, step #11: 2-step LMI with CORRECTED sign on dual multipliers.

Bug found in steps 06-09: the S-procedure / Positivstellensatz form is
   d(x) + Σ λ_i G_i(x) = -SOS  (≤ 0 globally),  λ_i ≥ 0
NOT
   d(x) - Σ λ_i G_i(x) = -SOS.

With the correct sign:
   pos_combo = diff + Σ λ_i G_i ≤ 0 globally
   ⇔ FE coefficients in pos_combo = 0
   ⇔ quadratic form in v is NSD (i.e., -[v]^T M [v] with M PSD).

Re-derivation of FE constraints:
   pos_combo's FE_t coef = α + λ_IV_t * (-1) + λ_C_t_p1 * (+1) + λ_C_p1_t * (-1) + λ_C_t_p2 * (+1) + λ_C_p2_t * (-1)
                        = α - λ_IV_t + λ_C_t_p1 - λ_C_p1_t + λ_C_t_p2 - λ_C_p2_t = 0
   ⇒  λ_IV_t + λ_C_p1_t + λ_C_p2_t = α + λ_C_t_p1 + λ_C_t_p2
   ⇒ for α > 0:  λ_IV_t (or chain backward) > 0.

This is consistent with backward chain or IV being the "dominant" multiplier.

Also: the smoothness substitution `V_{t+1} = w_{t+1} (FE_t + g dy + (L/2) dy²) + Q_{t+1}` was
EQUIVALENT to "subtracting" w_{t+1} G_S (with G_S = FE_t - FE_{t+1} + g dy + (L/2) dy²).
With sign flipped: it's "adding" w_{t+1} G_S. So the substitution is consistent with the
correct sign convention if we relabel.

For simplicity, we now treat G_S explicitly as a generator (with free multiplier μ_S ≥ 0).
"""
from pathlib import Path
import json
import numpy as np
import cvxpy as cp
import sympy as sp


def build_diff_polynomial_with_smoothness_explicit(L_val, beta_val, eta_val):
    """V_{t+1} - V_t with f_{t+1} TREATED AS FREE VARIABLE (no smoothness substitution).

    V_t = w_t (f_t - f*) + Q(X_t, X_{t-1}, X_{t-2})
    V_{t+1} = w_{t+1} (f_{t+1} - f*) + Q(X_{t+1}, X_t, X_{t-1})

    With w_{t+1} = w_t + alpha (alpha >= 0).
    Define W := w_{t+1} (free non-negative variable).

    Variables:  g_t, g_p1, g_p2, X_t, X_p1, X_p2, FE_t, FE_p1, FE_p2, FE_t1.
    """
    g_t, g_p1, g_p2 = sp.symbols("g_t g_p1 g_p2", real=True)
    X_t, X_p1, X_p2 = sp.symbols("X_t X_p1 X_p2", real=True)
    FE_t, FE_p1, FE_p2, FE_t1 = sp.symbols("FE_t FE_p1 FE_p2 FE_t1", real=True)

    a0, a1, a2 = sp.symbols("a0 a1 a2", real=True)
    c01, c02, c12 = sp.symbols("c01 c02 c12", real=True)
    W, alpha = sp.symbols("W alpha", real=True)

    L, beta, eta = sp.S(L_val), sp.S(beta_val), sp.S(eta_val)

    dy_t = -eta * g_t + beta * (X_t - X_p1)
    X_t1 = X_t + dy_t

    V_t = (a0 * X_t ** 2 + a1 * X_p1 ** 2 + a2 * X_p2 ** 2
           + c01 * X_t * X_p1 + c02 * X_t * X_p2 + c12 * X_p1 * X_p2)
    Q_next = (a0 * X_t1 ** 2 + a1 * X_t ** 2 + a2 * X_p1 ** 2
              + c01 * X_t1 * X_t + c02 * X_t1 * X_p1 + c12 * X_t * X_p1)

    # w_{t+1} = W = w_t + alpha. We'll use alpha as the per-step weight increment.
    # V_{t+1} = W * FE_{t+1} + Q_next.
    # V_t = (W - alpha) * FE_t + Q_t.
    diff = sp.expand(W * FE_t1 - (W - alpha) * FE_t + Q_next - V_t)

    return diff, {
        "g_t": g_t, "g_p1": g_p1, "g_p2": g_p2,
        "X_t": X_t, "X_p1": X_p1, "X_p2": X_p2,
        "FE_t": FE_t, "FE_p1": FE_p1, "FE_p2": FE_p2, "FE_t1": FE_t1,
        "a0": a0, "a1": a1, "a2": a2,
        "c01": c01, "c02": c02, "c12": c12,
        "W": W, "alpha": alpha,
    }


def build_generators_with_smoothness(L_val, S):
    L = sp.S(L_val)
    g_t, g_p1, g_p2 = S["g_t"], S["g_p1"], S["g_p2"]
    X_t, X_p1, X_p2 = S["X_t"], S["X_p1"], S["X_p2"]
    FE_t, FE_p1, FE_p2, FE_t1 = S["FE_t"], S["FE_p1"], S["FE_p2"], S["FE_t1"]
    half_inv_L = sp.Rational(1, 2) / L
    eta, beta = sp.symbols("eta beta", positive=True)
    # We'll inline eta, beta below by passing them, but keep the dy_t computation here.
    # Actually let me re-build dy_t locally:
    # dy_t depends on eta, beta — use S's L_val implicitly.

    # Need eta, beta as numerical from outer; pass via closure.
    return None  # placeholder; we'll define inline.


def build_lmi_corrected(L_val, beta_val, eta_val, fix_alpha=None, minimize="W"):
    diff, S = build_diff_polynomial_with_smoothness_explicit(L_val, beta_val, eta_val)

    L = sp.S(L_val)
    g_t, g_p1, g_p2 = S["g_t"], S["g_p1"], S["g_p2"]
    X_t, X_p1, X_p2 = S["X_t"], S["X_p1"], S["X_p2"]
    FE_t, FE_p1, FE_p2, FE_t1 = S["FE_t"], S["FE_p1"], S["FE_p2"], S["FE_t1"]
    half_inv_L = sp.Rational(1, 2) / L

    eta_s = sp.S(eta_val); beta_s = sp.S(beta_val)
    dy_t = -eta_s * g_t + beta_s * (X_t - X_p1)

    # Generators (all should be >= 0 for valid (g, X, FE) on L-smooth convex class).
    G = {}
    # Smoothness UB on f_{t+1}: f_t - f_{t+1} + g_t dy_t + (L/2) dy_t² >= 0
    G["S"]      = FE_t - FE_t1 + g_t * dy_t + sp.Rational(1, 2) * L * dy_t ** 2
    # Interpolation at *
    G["IV_t"]   = g_t * X_t   - FE_t   - half_inv_L * g_t ** 2
    G["IV_p1"]  = g_p1 * X_p1 - FE_p1  - half_inv_L * g_p1 ** 2
    G["IV_p2"]  = g_p2 * X_p2 - FE_p2  - half_inv_L * g_p2 ** 2
    # Pair (i, j): convexity at j wrt i: f_i >= f_j + <g_j, x_i - x_j> + (1/(2L))||g_i - g_j||^2
    G["C_t_p1"]   = (FE_t - FE_p1) - g_p1 * (X_t - X_p1)   - half_inv_L * (g_t - g_p1) ** 2
    G["C_p1_t"]   = (FE_p1 - FE_t) - g_t * (X_p1 - X_t)    - half_inv_L * (g_p1 - g_t) ** 2
    G["C_p1_p2"]  = (FE_p1 - FE_p2) - g_p2 * (X_p1 - X_p2) - half_inv_L * (g_p1 - g_p2) ** 2
    G["C_p2_p1"]  = (FE_p2 - FE_p1) - g_p1 * (X_p2 - X_p1) - half_inv_L * (g_p2 - g_p1) ** 2
    G["C_t_p2"]   = (FE_t - FE_p2) - g_p2 * (X_t - X_p2)   - half_inv_L * (g_t - g_p2) ** 2
    G["C_p2_t"]   = (FE_p2 - FE_t) - g_t * (X_p2 - X_t)    - half_inv_L * (g_p2 - g_t) ** 2
    # Pair involving t+1 (we may need these for the smoothness/interpolation interplay)
    # G["C_t1_t"]   = (FE_t1 - FE_t) - g_t * (X_t + dy_t - X_t)   - half_inv_L * (g_{t+1} - g_t) ** 2
    # We don't have g_{t+1} as a separate symbol since the LMI doesn't track it.
    # We could include G_C_t_t1 (convexity at y_t wrt y_{t+1} using just f_t1):
    # f_t1 - f_t - <g_t, x_{t+1} - x_t> - (1/(2L))(g_{t+1} - g_t)^2 >= 0
    # Without g_{t+1}, drop the last term (it's >= 0 anyway, so weaker bound).
    # Actually that's just smoothness from t+1 side, which we're not using.

    a0_v = cp.Variable()
    a1_v = cp.Variable()
    a2_v = cp.Variable()
    c01_v = cp.Variable()
    c02_v = cp.Variable()
    c12_v = cp.Variable()
    W_v = cp.Variable(nonneg=True)
    if fix_alpha is None:
        alpha_v = cp.Variable(nonneg=True)
    else:
        alpha_v = cp.Constant(float(fix_alpha))

    lam = {name: cp.Variable(nonneg=True) for name in G.keys()}
    lam_syms = {name: sp.symbols(f"lam_{name}", real=True) for name in G.keys()}

    # CORRECTED SIGN: pos_combo = diff + Σ λ G  (Positivstellensatz)
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
    # FE coefficients (linear in each FE) and FE × FE products and FE × v products must vanish.
    monoms_zero = list(FE_list)
    for fe in FE_list:
        for v in other_list:
            monoms_zero.append(fe * v)
    for i in range(4):
        monoms_zero.append(FE_list[i] ** 2)
    for i in range(4):
        for j in range(i + 1, 4):
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

    # Build M PSD on (g_t, g_p1, g_p2, X_t, X_p1, X_p2): pos_combo's quadratic part = -[v]^T M [v]
    # i.e., M[i,i] = -coef of v_i^2, etc. Since pos_combo <= 0 globally <=> -pos_combo is SOS,
    # we need pos_combo's quadratic form = -[v]^T M [v] with M PSD.
    M = cp.Variable((6, 6), symmetric=True)
    for i in range(6):
        for j in range(i, 6):
            mon = other_list[i] ** 2 if i == j else other_list[i] * other_list[j]
            cf = sp.expand(poly.coeff_monomial(mon))
            if i == j:
                constraints.append(M[i, i] == -sym_to_cp_expr(cf))
            else:
                constraints.append(M[i, j] == -sym_to_cp_expr(cf) / 2)
                constraints.append(M[j, i] == -sym_to_cp_expr(cf) / 2)

    constraints.append(M >> 0)

    # Validity constraints for Lyapunov:
    # 1. w_t = W - alpha >= 0, i.e., W >= alpha (so V_t has non-negative weight on FE_t).
    constraints.append(W_v >= alpha_v)
    # 2. Q (the quadratic part of V_t in (X_t, X_p1, X_p2)) must be PSD, so V_t >= w_t FE_t >= 0.
    Q_mat = cp.bmat([
        [a0_v,        c01_v / 2,  c02_v / 2],
        [c01_v / 2,   a1_v,       c12_v / 2],
        [c02_v / 2,   c12_v / 2,  a2_v     ]
    ])
    constraints.append(Q_mat >> 0)

    # Bound to keep numerical stability.
    constraints.append(cp.abs(a0_v) <= 1e6)
    constraints.append(cp.abs(a1_v) <= 1e6)
    constraints.append(cp.abs(a2_v) <= 1e6)
    constraints.append(cp.abs(c01_v) <= 1e6)
    constraints.append(cp.abs(c02_v) <= 1e6)
    constraints.append(cp.abs(c12_v) <= 1e6)

    if minimize == "W":
        # Fix alpha = 1, minimize W (= w_{t+1}).
        if fix_alpha is None:
            constraints.append(alpha_v == 1.0)
        objective = cp.Minimize(W_v)
    elif minimize == "alpha":
        # Fix W = 1, maximize alpha.
        constraints.append(W_v <= 1.0)
        objective = cp.Maximize(alpha_v)

    prob = cp.Problem(objective, constraints)
    prob.solve(solver=cp.SCS, verbose=False, max_iters=50000)

    return {
        "status": prob.status,
        "alpha": float(alpha_v.value) if hasattr(alpha_v, "value") and alpha_v.value is not None else (float(fix_alpha) if fix_alpha is not None else None),
        "W": float(W_v.value) if W_v.value is not None else None,
        "a0": float(a0_v.value) if a0_v.value is not None else None,
        "a1": float(a1_v.value) if a1_v.value is not None else None,
        "a2": float(a2_v.value) if a2_v.value is not None else None,
        "c01": float(c01_v.value) if c01_v.value is not None else None,
        "c02": float(c02_v.value) if c02_v.value is not None else None,
        "c12": float(c12_v.value) if c12_v.value is not None else None,
        "lambdas": {name: (float(lam[name].value) if lam[name].value is not None else None)
                    for name in G.keys()},
    }


def main():
    L = 1.0

    # Sanity: plain GD (β=0, η=1/L). Standard analysis works with V = t (f-f*) + (L/2)||y-y*||².
    print("=" * 80)
    print("Diagnostic: plain GD (β=0, η=1/L) — fix α=1, min W")
    print("Expected: feasible at W = 1 (matches V_t = t (f-f*) + (L/2) ||y-y*||²).")
    print("=" * 80)
    r = build_lmi_corrected(L, 0.0, 1.0/L, fix_alpha=1.0, minimize="W")
    print(f"Status: {r['status']}, W_min = {r['W']}, alpha = {r['alpha']}")
    if r['a0'] is not None:
        print(f"Lyapunov: a0={r['a0']:.4f}, a1={r['a1']:.4f}, a2={r['a2']:.4f}, "
              f"c01={r['c01']:.4f}, c02={r['c02']:.4f}, c12={r['c12']:.4f}")
        print("Active duals (>1e-3):")
        for k, v in sorted(r["lambdas"].items(), key=lambda kv: -abs(kv[1] or 0))[:8]:
            if v is not None and abs(v) > 1e-3:
                print(f"  λ_{k:12s} = {v:.4f}")

    # Full sweep
    print("\n" + "=" * 80)
    print("Sweep: β × η, fix α=1, min W")
    print("=" * 80)
    header = (f"{'beta':>5} {'eta':>5} {'status':>16} {'W_min':>9} "
              f"{'a0':>7} {'a1':>7} {'a2':>7} {'c01':>7} {'c02':>7} {'c12':>7}  λ_skip2")
    print(header); print("-" * len(header))
    rows = []
    for beta in [0.0, 0.1, 0.2, 0.3, 0.4, 0.5]:
        for eta_factor in [0.5, 0.7, 1.0, 1.2, 1.5, 1.7, 2.0]:
            eta = eta_factor / L
            try:
                r = build_lmi_corrected(L, beta, eta, fix_alpha=1.0, minimize="W")
            except Exception as e:
                r = {"status": f"err:{str(e)[:40]}", "W": None, "alpha": None}
            row = {"beta": beta, "eta": eta, **r}
            rows.append(row)
            status = r["status"]
            W = r.get("W")
            if isinstance(W, float) and 0 < W < 1e6 and status in ("optimal", "optimal_inaccurate"):
                lam_skip2 = (r["lambdas"].get("C_t_p2", 0.0) or 0) + (r["lambdas"].get("C_p2_t", 0.0) or 0)
                print(f"{beta:>5.2f} {eta:>5.2f} {status:>16} {W:>9.4f} "
                      f"{r['a0']:>7.3f} {r['a1']:>7.3f} {r['a2']:>7.3f} "
                      f"{r['c01']:>7.3f} {r['c02']:>7.3f} {r['c12']:>7.3f}  {lam_skip2:>6.3f}")
            else:
                W_str = f"{W:.4f}" if isinstance(W, float) else str(W)
                print(f"{beta:>5.2f} {eta:>5.2f} {status:>16} {W_str:>9}    (infeas)")

    out = Path(__file__).parent / "11_two_step_lmi_corrected_results.json"
    out.write_text(json.dumps(rows, indent=2, default=str))
    print(f"\nResults: {out}")


if __name__ == "__main__":
    main()
