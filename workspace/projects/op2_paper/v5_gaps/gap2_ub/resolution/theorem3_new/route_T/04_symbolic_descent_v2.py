"""Route T, step #4: redo descent expansion with the stronger interpolation inequality.

For L-smooth convex f, the SHARP interpolation inequality is:
  (IV)  <g, y - y*>  >=  (f(y) - f*) + (1/(2L)) ||g||^2.

This comes from Taylor at y_*:  f* >= f + <g, y* - y> + (1/(2L)) ||g||^2,
i.e., <g, y - y*> >= (f - f*) + (1/(2L)) ||g||^2.

We ALSO use the smoothness upper bound for f(y_next):
  (S)   f(y_next) - f(y) <= <g, y_next - y> + (L/2) ||y_next - y||^2.

Strategy:
  Substitute (IV) in the form  G*X = FE + (1/(2L)) G^2 + s_C, with s_C >= 0.
  Substitute (S) for f_next as before.
  Then check if descent <= -c FE + (negative quadratic in G, W).

Also try an additional inequality:
  (IV') At y_prev:  <g_prev, y_prev - y*> >= (f_prev - f*) + (1/(2L)) ||g_prev||^2.
  Plus  (C2) <g, y - y_prev> >= f - f_prev.

We work in 1D (since both V and SHB are coordinate-wise quadratic).
"""
import sympy as sp


def main():
    # Symbols
    G, X, W, FE = sp.symbols("G X W FE", real=True)  # FE = f - f*, G = grad f(y), X = y - y*, W = y - y_prev
    eta, beta, gamma, w_t = sp.symbols("eta beta gamma w_t", positive=True)
    L = sp.symbols("L", positive=True)
    s_C = sp.symbols("s_C", nonnegative=True)         # slack from interpolation (IV)

    alpha = (1 - beta) / eta

    # SHB step: y_next - y = dy = -eta G + beta W
    dy = -eta * G + beta * W

    # Lyapunov:  V = w_t * FE + 0.5 || alpha X + W/eta ||^2 + (gamma/2) X^2
    twist_curr = alpha * X + W / eta
    V_curr = w_t * FE + sp.Rational(1, 2) * twist_curr ** 2 + sp.Rational(1, 2) * gamma * X ** 2

    # State at t+1:  X_next = X + dy,  W_next = y_next - y = dy.
    # Velocity at next step:  v_next = (y_next - y)/eta = dy/eta = -G + (beta/eta) W.
    # Twist at next step: alpha * (X + dy) + dy / eta = alpha * X + (alpha + 1/eta) * dy
    #                  = alpha * X + (alpha + 1/eta) * (-eta G + beta W)
    #                  = alpha * X - (alpha * eta + 1) G + ((alpha + 1/eta) * beta) W
    twist_next = alpha * (X + dy) + dy / eta

    # Smoothness bound:  f_next - f <= <g, dy> + (L/2) ||dy||^2.
    # i.e., (f_next - f*) <= FE + G * dy + (L/2) dy^2.
    # We use this as EQUALITY with slack s_S >= 0:  (f_next - f*) = FE + G dy + (L/2) dy^2 - s_S, s_S >= 0.
    s_S = sp.symbols("s_S", nonnegative=True)
    FE_next = FE + G * dy + sp.Rational(1, 2) * L * dy ** 2 - s_S

    # Lyapunov at next step. We use weight w_{t+1} = w_t + Δw (free at this stage; later we'll set Δw).
    delta_w = sp.symbols("delta_w", real=True)
    w_next = w_t + delta_w
    V_next = w_next * FE_next + sp.Rational(1, 2) * twist_next ** 2 + sp.Rational(1, 2) * gamma * (X + dy) ** 2

    diff = sp.expand(V_next - V_curr)

    # Now apply (IV) :  G * X >= FE + (1/(2L)) G^2.
    # Equality form:  G * X = FE + (1/(2L)) G^2 + s_IV, with s_IV >= 0.
    s_IV = sp.symbols("s_IV", nonnegative=True)
    diff_after_IV = diff.subs(G * X, FE + (1 / (2 * L)) * G ** 2 + s_IV)
    diff_after_IV = sp.expand(diff_after_IV)

    print("=" * 70)
    print("V_{t+1} - V_t after applying (IV) and (S)")
    print("=" * 70)
    coll = sp.collect(diff_after_IV, [FE, G**2, W**2, G*W, X**2, X*W, s_S, s_IV, delta_w])
    print(coll)

    print("\n--- Coefficients at TOP-LEVEL (in FE, G, W, X, slacks) ---")
    monomials = {
        "FE": FE,
        "G^2": G**2,
        "G*W": G * W,
        "G*X": G * X,
        "W^2": W**2,
        "W*X": W * X,
        "X^2": X**2,
        "s_S": s_S,
        "s_IV": s_IV,
        "delta_w": delta_w,
        "delta_w*FE": delta_w * FE,
        "delta_w*G^2": delta_w * G**2,
        "delta_w*G*W": delta_w * G * W,
        "delta_w*G*dy": delta_w * G * dy,
        "delta_w*dy": delta_w * dy,
        "delta_w*dy^2": delta_w * dy ** 2,
        "delta_w*s_S": delta_w * s_S,
    }

    # We need to extract coefficients carefully because diff_after_IV has products.
    # Strategy: regard diff_after_IV as polynomial in (G, W, X, s_S, s_IV, delta_w, FE), with coefficients
    # in (eta, beta, gamma, w_t, L).

    poly_vars = [FE, G, W, X, s_S, s_IV, delta_w]
    p = sp.Poly(diff_after_IV, *poly_vars)
    print("\nPoly structure (degrees):", p.degree_list(), "vars:", poly_vars)

    def coeff_of(monomial):
        # extract coefficient using sympy's coeff_monomial after expressing as polynomial.
        try:
            return sp.simplify(p.coeff_monomial(monomial))
        except Exception:
            return sp.S(0)

    # Build a table of monomials of interest.
    monoms_of_interest = [
        ("FE",        FE),
        ("FE * delta_w", FE * delta_w),
        ("G^2",       G**2),
        ("G^2 * delta_w", G**2 * delta_w),
        ("G * W",     G * W),
        ("G * W * delta_w", G * W * delta_w),
        ("G * X",     G * X),
        ("G * X * delta_w", G * X * delta_w),
        ("W^2",       W**2),
        ("W * X",     W * X),
        ("X^2",       X**2),
        ("s_S",       s_S),
        ("s_S * delta_w", s_S * delta_w),
        ("s_IV",      s_IV),
        ("delta_w",   delta_w),
        ("1",         sp.S(1)),
    ]

    print("\nCoefficient table (after IV substitution):")
    for name, mon in monoms_of_interest:
        c = coeff_of(mon)
        print(f"   coeff[{name:18s}] = {sp.simplify(c)}")

    print("\n" + "=" * 70)
    print("Sanity check: SET delta_w = 0 (constant w_t = 1 say); should reduce to "
          "the constant-w Lyapunov.")
    print("=" * 70)
    diff_at_const_w = diff_after_IV.subs(delta_w, 0)
    diff_at_const_w = sp.expand(diff_at_const_w)
    p2 = sp.Poly(diff_at_const_w, FE, G, W, X, s_S, s_IV)
    monoms2 = [("FE", FE), ("G^2", G**2), ("G*W", G*W), ("G*X", G*X),
               ("W^2", W**2), ("W*X", W*X), ("X^2", X**2),
               ("s_S", s_S), ("s_IV", s_IV), ("1", sp.S(1))]
    for name, mon in monoms2:
        c = sp.simplify(p2.coeff_monomial(mon))
        print(f"   const-w coeff[{name:6s}] = {c}")

    print("\n--- Specialize: beta = 0, gamma = 0 (plain GD), constant w_t = 1, eta = 1/L ---")
    sub = [(beta, 0), (gamma, 0), (delta_w, 0), (eta, 1 / L), (w_t, 1)]
    for name, mon in monoms2:
        c = sp.simplify(p2.coeff_monomial(mon).subs(sub))
        print(f"   coeff[{name:6s}] = {c}")

    print("\n--- Specialize: beta = 0.3, gamma = 0, w_t = 1, eta = 1/L ---")
    sub = [(beta, sp.Rational(3, 10)), (gamma, 0), (delta_w, 0), (eta, 1 / L), (w_t, 1)]
    for name, mon in monoms2:
        c = sp.simplify(p2.coeff_monomial(mon).subs(sub))
        print(f"   coeff[{name:6s}] = {c}")

    print("\n--- Specialize: beta = 0.5, gamma = 0, w_t = 1, eta = 1/L ---")
    sub = [(beta, sp.Rational(1, 2)), (gamma, 0), (delta_w, 0), (eta, 1 / L), (w_t, 1)]
    for name, mon in monoms2:
        c = sp.simplify(p2.coeff_monomial(mon).subs(sub))
        print(f"   coeff[{name:6s}] = {c}")

    # The remaining residual is (with delta_w = 0):
    # descent = a_FE * FE + a_GG * G^2 + a_GW * GW + a_WW * W^2 + a_WX * WX + a_X * X^2
    #          + a_sS * s_S + a_sIV * s_IV
    # with the constraints s_S >= 0 and s_IV >= 0.
    # We want descent <= -c * FE  (with c > 0).
    #
    # For any feasible state (G, W, X, FE) satisfying the SHB recursion AND the bounds,
    # we have s_S, s_IV >= 0; so we need a_sS, a_sIV <= 0 (otherwise we can choose them large).
    #
    # Then  descent <= a_FE FE + (G,W,X-quadratic).
    # The (G, W, X)-quadratic must have coefficient matrix that is negative semi-definite, OR
    # we need additional inequalities.
    #
    # We'll print which specializations yield "good" structure.


if __name__ == "__main__":
    main()
