"""Route T, step #3: symbolic expansion of V_{t+1} - V_t for the twisted Lyapunov.

Twisted Lyapunov (constant w_t = 1, constant gamma; we'll re-introduce time-variation later):
  V(y, y_prev) = (f(y) - f*) + 0.5 * || alpha (y - y*) + (y - y_prev)/eta ||^2 + (gamma/2) ||y - y*||^2
where alpha = (1 - beta) / eta, and (y - y_prev)/eta is the discrete velocity v.

For the deterministic (no-noise) case, the SHB recursion is:
  y_next = y - eta * g + beta * (y - y_prev)
         = y + beta * (y - y_prev) - eta * g
where g = nabla f(y). We want a sufficient condition for
  V(y_next, y) - V(y, y_prev) <= - C (f(y) - f*).

Approach
--------
1. Symbolically expand the difference using the SHB recursion.
2. Group into known structural pieces:
     - <g, y - y*>:           bound below by (f(y) - f*) (convexity)
     - ||g||^2:                bound above by 2L (f(y) - f*) (smoothness, when ||g||^2 <= 2L (f(y) - f*))
     - <g, y - y_prev>:        bound below by (f(y) - f(y_prev)) (convexity)
                              OR upper bounded via cocoercivity / Young
     - ||y - y_prev||^2:        velocity-magnitude squared
3. Substitute these bounds and check whether V_{t+1} - V_t <= -C (f(y) - f*) is feasible.

We work in 1D (scalar y, y_prev, y*); since both V and the SHB recursion are coordinate-wise
linear/quadratic, the 1D analysis covers higher dimensions.
"""
import sympy as sp


def main():
    # Variables
    y, y_prev, y_star = sp.symbols("y y_prev y_star", real=True)
    g = sp.symbols("g", real=True)               # = nabla f(y), unknown but bounded
    f_val, f_star, f_prev = sp.symbols("f_val f_star f_prev", real=True)
    eta, beta, gamma = sp.symbols("eta beta gamma", positive=True)
    L = sp.symbols("L", positive=True)
    alpha = (1 - beta) / eta

    # SHB step
    y_next = y - eta * g + beta * (y - y_prev)
    # f_next = f(y_next), unknown. We treat (f_val - f_star) explicitly.

    # Lyapunov (constant w = 1, gamma free)
    # Velocity at state (y, y_prev): v = (y - y_prev)/eta
    v = (y - y_prev) / eta
    # Velocity at next state (y_next, y): v_next = (y_next - y)/eta = -g + (beta/eta)(y - y_prev)
    v_next = (y_next - y) / eta

    twist_curr = alpha * (y - y_star) + v
    twist_next = alpha * (y_next - y_star) + v_next

    V_curr = (f_val - f_star) + sp.Rational(1, 2) * twist_curr ** 2 + sp.Rational(1, 2) * gamma * (y - y_star) ** 2
    # We replace f(y_next) by f_next placeholder, but we keep it as an unknown linear in (f_next - f_star).
    f_next = sp.symbols("f_next", real=True)
    V_next = (f_next - f_star) + sp.Rational(1, 2) * twist_next ** 2 + sp.Rational(1, 2) * gamma * (y_next - y_star) ** 2

    diff = sp.expand(V_next - V_curr)
    print("=== Raw V_{t+1} - V_t ===")
    print(sp.collect(diff, [g, (y - y_star), (y - y_prev)]))

    # Now apply DESCENT-LEMMA style bounds:
    # (S) L-smoothness: f_next - f_val <= <g, y_next - y> + (L/2) ||y_next - y||^2.
    # (C) Convexity at y wrt y*: f_val - f_star <= <g, y - y*>.    (we use this in REVERSE: <g, y - y*> >= f_val - f_star)
    # (C') Convexity at y wrt y_prev: f_prev - f_val >= <g, y_prev - y>, i.e., <g, y - y_prev> >= f_val - f_prev.

    # We'll use (S) to upper bound (f_next - f_star) <= (f_val - f_star) + <g, y_next - y> + (L/2)||y_next - y||^2.
    f_next_bound = (f_val - f_star) + g * (y_next - y) + sp.Rational(1, 2) * L * (y_next - y) ** 2
    diff_after_S = sp.expand(diff.subs(f_next, f_next_bound + f_star))
    print("\n=== After applying L-smoothness on (f_next - f_val) ===")
    print(sp.collect(diff_after_S, [g, (y - y_star), (y - y_prev)]))

    # Substitute y_next - y = -eta g + beta(y - y_prev). Call this dy.
    dy = -eta * g + beta * (y - y_prev)
    # Make sure substitution gives same expression
    expr1 = sp.expand((y_next - y).subs(y_next, y - eta * g + beta * (y - y_prev)))
    print("\nSanity y_next - y =", sp.simplify(expr1 - dy))  # should be 0

    # Now we can collect terms in g, (y - y*), (y - y_prev):
    expr = sp.expand(diff_after_S)
    expr = sp.collect(expr, [g, (y - y_star), (y - y_prev)])
    print("\n=== Collected ===")
    print(expr)

    # Decompose via convexity bound: <g, y - y*> >= (f_val - f_star).
    # We'll use a SLACK variable to convert ">=" to equality:
    #   <g, y - y*> = (f_val - f_star) + s_C, with s_C >= 0.
    # Substitute g*(y - y_star) = (f_val - f_star) + s_C in the expression.
    s_C = sp.symbols("s_C", nonnegative=True)
    # In 1D, <g, y - y*> = g*(y - y_star).
    expr_subst = expr.subs(g * (y - y_star), (f_val - f_star) + s_C)
    expr_subst = sp.expand(expr_subst)
    # But sympy.subs is symbolic — only direct match works. We need to extract the coefficient
    # of g*(y - y_star) in expr first.
    print("\n=== Test the convexity substitution by direct coefficient extraction ===")

    # Strategy: multiply out diff_after_S, write as polynomial in g and (y - y_star) and (y - y_prev).
    # Express using new variables: G := g, X := (y - y_star), W := (y - y_prev).
    G, X, W, FE = sp.symbols("G X W FE")  # FE := f_val - f_star
    # We cannot directly substitute (y - y_star) -> X because of expansions, but we can express
    # the relevant pieces. Actually let's restate manually.
    #
    # twist_curr = alpha * X + W/eta  (since v = W/eta and y - y* = X)
    # twist_next = alpha * (y_next - y*) + v_next.
    # y_next - y* = X + dy = X - eta*G + beta*W.
    # v_next = dy/eta = -G + (beta/eta) W.
    # twist_next = alpha * (X - eta G + beta W) + (-G + (beta/eta) W)
    #            = alpha * X - alpha*eta*G + alpha*beta*W - G + (beta/eta) W
    #            = alpha * X - (alpha*eta + 1) G + (alpha*beta + beta/eta) W
    twist_next_sym = alpha * X - (alpha * eta + 1) * G + (alpha * beta + beta / eta) * W

    twist_curr_sym = alpha * X + W / eta

    # f_next - f_star <= (f_val - f_star) + G * (y_next - y) + (L/2) ||y_next - y||^2
    # y_next - y = dy = -eta G + beta W.
    f_diff = G * (-eta * G + beta * W) + sp.Rational(1, 2) * L * (-eta * G + beta * W) ** 2

    # V_next: f_diff + (f_val - f_star) + 0.5 * twist_next^2 + 0.5 * gamma * (X - eta G + beta W)^2
    # V_curr: (f_val - f_star) + 0.5 * twist_curr^2 + 0.5 * gamma * X^2
    V_next_sym = (FE) + f_diff + sp.Rational(1, 2) * twist_next_sym ** 2 + sp.Rational(1, 2) * gamma * (X - eta * G + beta * W) ** 2
    V_curr_sym = FE + sp.Rational(1, 2) * twist_curr_sym ** 2 + sp.Rational(1, 2) * gamma * X ** 2

    descent_with_S = sp.expand(V_next_sym - V_curr_sym)

    print("\n=== Symbolic V_{t+1} - V_t after L-smoothness bound ===")
    desc_collected = sp.collect(descent_with_S, [G * X, G * W, G ** 2, X * W, X ** 2, W ** 2, FE, G])
    print(desc_collected)

    # Apply convexity:  G * X = FE + s_C, with s_C >= 0.
    # Substitute G*X -> FE + s_C in descent.
    descent_sub_C = descent_with_S.subs(G * X, FE + s_C)
    descent_sub_C = sp.expand(descent_sub_C)
    print("\n=== After applying G*X >= FE (convexity at y wrt y*) ===")
    desc_C = sp.collect(descent_sub_C, [G * W, G ** 2, X * W, X ** 2, W ** 2, FE, s_C])
    print(desc_C)

    # Now we'd like: descent <= -c * FE + (terms <= 0 already) + (positive multiple of s_C dropped)
    # Specifically, we want the COEFFICIENT OF s_C to be NON-POSITIVE (so we can drop the s_C term),
    # and the rest to be a NEGATIVE quadratic form in (G, W) plus a (-c) multiple of FE.

    print("\n=== Coefficients in (G, W, GW, FE, X*W, X^2) ===")
    poly = sp.Poly(desc_C, G, W, X, s_C, FE)
    coeff_s_C = desc_C.coeff(s_C)
    coeff_FE = desc_C.coeff(FE)
    coeff_G_sq = desc_C.coeff(G, 2).coeff(W, 0).coeff(X, 0)
    coeff_W_sq = desc_C.coeff(W, 2).coeff(G, 0).coeff(X, 0)
    coeff_GW = desc_C.coeff(G, 1).coeff(W, 1).coeff(X, 0)
    coeff_X_sq = desc_C.coeff(X, 2).coeff(G, 0).coeff(W, 0)
    coeff_XW = desc_C.coeff(X, 1).coeff(W, 1).coeff(G, 0)

    print(f"coeff[s_C]  = {sp.simplify(coeff_s_C)}")
    print(f"coeff[FE]   = {sp.simplify(coeff_FE)}")
    print(f"coeff[G^2]  = {sp.simplify(coeff_G_sq)}")
    print(f"coeff[W^2]  = {sp.simplify(coeff_W_sq)}")
    print(f"coeff[GW]   = {sp.simplify(coeff_GW)}")
    print(f"coeff[X^2]  = {sp.simplify(coeff_X_sq)}")
    print(f"coeff[XW]   = {sp.simplify(coeff_XW)}")

    # For descent <= -c FE we need:
    # (1) coeff[s_C] <= 0  (so the convexity slack helps).
    # (2) The (G, W) quadratic form must be PSD's complement, i.e., coeff_G_sq <= 0, etc.
    # (3) coeff_FE <= -c < 0  (the negative drift on FE).
    # (4) X^2 / XW pieces should also be a quadratic form with non-positive eigenvalues.

    # Specialize: try gamma = 0
    print("\n=== Specialize gamma = 0 ===")
    for name, c in [("s_C", coeff_s_C), ("FE", coeff_FE), ("G^2", coeff_G_sq),
                    ("W^2", coeff_W_sq), ("GW", coeff_GW),
                    ("X^2", coeff_X_sq), ("XW", coeff_XW)]:
        c0 = sp.simplify(c.subs(gamma, 0))
        print(f"   coeff[{name}] @ gamma=0 = {c0}")

    # Specialize: try gamma = 1/eta
    print("\n=== Specialize gamma = 1/eta ===")
    for name, c in [("s_C", coeff_s_C), ("FE", coeff_FE), ("G^2", coeff_G_sq),
                    ("W^2", coeff_W_sq), ("GW", coeff_GW),
                    ("X^2", coeff_X_sq), ("XW", coeff_XW)]:
        c0 = sp.simplify(c.subs(gamma, 1 / eta))
        print(f"   coeff[{name}] @ gamma=1/eta = {c0}")

    # Specialize:  beta = 0 (gives plain GD).
    print("\n=== Specialize beta = 0, gamma = 0 (plain GD) ===")
    for name, c in [("s_C", coeff_s_C), ("FE", coeff_FE), ("G^2", coeff_G_sq),
                    ("W^2", coeff_W_sq), ("GW", coeff_GW),
                    ("X^2", coeff_X_sq), ("XW", coeff_XW)]:
        c0 = sp.simplify(c.subs([(beta, 0), (gamma, 0)]))
        print(f"   coeff[{name}] @ beta=0,gamma=0 = {c0}")


if __name__ == "__main__":
    main()
