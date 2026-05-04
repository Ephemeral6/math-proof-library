"""
Symbolic derivation of the Lyapunov drift for SHB.

We try several Lyapunov candidates and identify which (a) gives a clean drift
inequality V_{t+1} - V_t <= -eta * (f(x_t) - f*) + variance_term, and (b) is
valid for which range of beta.

This drives the design of the resolution theorem.
"""

import sympy as sp


def expand_drift(V_t_func, V_tp1_func):
    """Compute V_{t+1} - V_t symbolically and group terms."""
    diff = sp.expand(V_tp1_func - V_t_func)
    return sp.simplify(diff)


def main():
    print("=" * 80)
    print("Symbolic Lyapunov drift derivation for SHB")
    print("=" * 80)

    # Parameters
    beta, eta, L = sp.symbols("beta eta L", positive=True, real=True)
    sigma = sp.symbols("sigma", positive=True)

    # 1-D state for simplicity. x_t real, x_star = 0, m_t = (x_t - x_{t-1})/eta.
    # Generic gradient g_t = h_t + xi_t where E[h_t] = nabla f(x_t), E[xi_t] = 0.
    # For descent identity, we work with the MEAN, treating g_t = nabla f(x_t).
    # The stochastic part contributes E[xi_t^2] = sigma^2.

    # Actually for the symbolic drift, treat g_t generically; later we substitute
    # E[g_t^2] = E[(h+xi)^2] = h^2 + sigma^2 and use convexity.

    x_t, x_tm1, g_t = sp.symbols("x_t x_tm1 g_t", real=True)
    f_t, f_star = sp.symbols("f_t f_star", real=True)  # f(x_t), f*

    # SHB updates:
    # x_{t+1} = x_t - eta*g_t + beta*(x_t - x_{t-1})
    x_tp1 = x_t - eta * g_t + beta * (x_t - x_tm1)

    # m_t = (x_t - x_{t-1})/eta, m_{t+1} = (x_{t+1} - x_t)/eta = beta*m_t - g_t
    m_t = (x_t - x_tm1) / eta
    m_tp1 = beta * m_t - g_t

    print("\n--- Candidate 1: V_t = ||x_t - x*||^2 + (β/(1-β)) η^2 ||m_t||^2 ---")
    V1_t = x_t ** 2 + beta / (1 - beta) * eta ** 2 * m_t ** 2
    V1_tp1 = x_tp1 ** 2 + beta / (1 - beta) * eta ** 2 * m_tp1 ** 2
    drift1 = sp.simplify(V1_tp1 - V1_t)
    drift1_expanded = sp.expand(drift1)
    # Collect by g_t and m_t:
    coeff_g2 = drift1_expanded.coeff(g_t, 2)
    coeff_g1 = drift1_expanded.coeff(g_t, 1)
    coeff_g0 = drift1_expanded - coeff_g2 * g_t ** 2 - coeff_g1 * g_t
    coeff_g0 = sp.simplify(coeff_g0)
    print(f"  Coefficient of g_t^2: {sp.simplify(coeff_g2)}")
    print(f"  Coefficient of g_t (linear): {sp.simplify(coeff_g1)}")
    print(f"  Constant (no g_t):    {coeff_g0}")

    print("\n--- Candidate 2: V_t = ||x_t - x*||^2 + c1 η² ||m_t||^2 + c2 η² ||m_{t-1}||^2 ---")
    print("  with c1 = (1-Lη-β²)/(2η), c2 = β²/(2η)  (per direction_2 §4)")

    c1 = (1 - L * eta - beta ** 2) / (2 * eta)
    c2 = beta ** 2 / (2 * eta)

    # need m_{t-1} = (x_{t-1} - x_{t-2})/eta — introduce x_tm2
    x_tm2 = sp.symbols("x_tm2", real=True)
    m_tm1 = (x_tm1 - x_tm2) / eta

    V2_t = x_t ** 2 + c1 * eta ** 2 * m_t ** 2 + c2 * eta ** 2 * m_tm1 ** 2
    V2_tp1 = x_tp1 ** 2 + c1 * eta ** 2 * m_tp1 ** 2 + c2 * eta ** 2 * m_t ** 2

    drift2 = sp.simplify(V2_tp1 - V2_t)
    drift2_expanded = sp.expand(drift2)
    coeff_g2_v2 = sp.simplify(drift2_expanded.coeff(g_t, 2))
    coeff_g1_v2 = sp.simplify(drift2_expanded.coeff(g_t, 1))
    coeff_g0_v2 = sp.simplify(drift2_expanded - coeff_g2_v2 * g_t ** 2 - coeff_g1_v2 * g_t)
    print(f"  Coefficient of g_t^2: {coeff_g2_v2}")
    print(f"  Coefficient of g_t (linear): {coeff_g1_v2}")
    print(f"  Constant (no g_t):    {coeff_g0_v2}")

    # Check: the "constant in g_t" should reduce to terms in (x_t - x*) and m_t, m_{t-1}.
    # If the cross-term (x_t)(m_t) and (x_t)(m_{t-1}) vanish, we get a clean descent.
    # Substitute m_t = (x_t - x_{t-1})/eta, m_{t-1} = (x_{t-1}-x_{t-2})/eta:
    coeff_g0_v2_sub = coeff_g0_v2.subs([(x_tm1, x_t - eta * sp.Symbol("mu_t")),
                                         (x_tm2, x_t - eta * sp.Symbol("mu_t") - eta * sp.Symbol("mu_tm1"))])
    # Hmm, this is awkward. Let me directly compute.
    print("\n  Re-derive with m_t, m_{t-1} kept symbolic (treat as independent variables):")
    mu_t, mu_tm1 = sp.symbols("mu_t mu_tm1", real=True)  # placeholder symbols for m_t, m_{t-1}
    # x_{t-1} = x_t - eta*m_t, x_{t-2} = x_{t-1} - eta*m_{t-1} = x_t - eta*m_t - eta*m_{t-1}
    V2_t_sym = x_t ** 2 + c1 * eta ** 2 * mu_t ** 2 + c2 * eta ** 2 * mu_tm1 ** 2
    # x_{t+1} = x_t + eta(beta*m_t - g_t)
    # m_{t+1} = beta*m_t - g_t (when m_t is the symbol)
    x_tp1_sym = x_t + eta * (beta * mu_t - g_t)
    m_tp1_sym = beta * mu_t - g_t
    V2_tp1_sym = x_tp1_sym ** 2 + c1 * eta ** 2 * m_tp1_sym ** 2 + c2 * eta ** 2 * mu_t ** 2
    drift2_sym = sp.expand(V2_tp1_sym - V2_t_sym)
    coeff_g2_sym = sp.simplify(drift2_sym.coeff(g_t, 2))
    coeff_g1_sym = sp.simplify(drift2_sym.coeff(g_t, 1))
    coeff_g0_sym = sp.simplify(drift2_sym - coeff_g2_sym * g_t ** 2 - coeff_g1_sym * g_t)
    print(f"  Coeff g_t^2:   {coeff_g2_sym}")
    print(f"  Coeff g_t (linear): {coeff_g1_sym}")
    print(f"  Constant:      {coeff_g0_sym}")

    # The cross-term in coeff_g0 should be of form A*x_t*m_t + B*m_t^2 + ... — find A.
    coeff_xt_mt_v2 = coeff_g0_sym.coeff(x_t, 1).coeff(mu_t, 1)
    coeff_mt2 = coeff_g0_sym.coeff(mu_t, 2)
    coeff_mtm1_2 = coeff_g0_sym.coeff(mu_tm1, 2)
    coeff_xt_mtm1 = coeff_g0_sym.coeff(x_t, 1).coeff(mu_tm1, 1)
    coeff_mt_mtm1 = coeff_g0_sym.coeff(mu_t, 1).coeff(mu_tm1, 1)
    print(f"  → cross-term x_t·m_t coefficient: {sp.simplify(coeff_xt_mt_v2)}")
    print(f"  → cross-term x_t·m_{{t-1}} coefficient: {sp.simplify(coeff_xt_mtm1)}")
    print(f"  → cross-term m_t·m_{{t-1}} coefficient: {sp.simplify(coeff_mt_mtm1)}")
    print(f"  → coefficient of m_t^2: {sp.simplify(coeff_mt2)}")
    print(f"  → coefficient of m_{{t-1}}^2: {sp.simplify(coeff_mtm1_2)}")

    # The coefficient of x_t * m_t should be 2*beta*eta (from the (x_t)(eta*beta*m_t) cross term),
    # which is positive — does NOT vanish. So the V2 Lyapunov leaves a x_t*m_t cross term.
    # This means we can't get a clean descent without further bounding.

    # The "magic" choice in direction_2 is to bound the cross term via the conv-smooth
    # inequality: 2 beta eta x_t m_t = 2 beta eta x_t * (x_t - x_{t-1})/eta = 2 beta x_t (x_t - x_{t-1})
    # which gets absorbed into the V_t (||x_t||^2 - ||x_{t-1}||^2)/(2)... anyway not entirely clean.

    print("\n--- Candidate 3: clean Lyapunov via change-of-variables z_t ---")
    print("  z_t = x_t + a (x_t - x_{t-1}) = (1+a) x_t - a x_{t-1},  a = β/(1-β)")
    print("  z_{t+1} - z_t = -ν g_t  where ν = η/(1-β)  (verified in gap2_verify.py S4)")
    a = beta / (1 - beta)
    nu = eta / (1 - beta)

    # OGD on z_t: ||z_{t+1} - x*||^2 = ||z_t - x*||^2 - 2ν⟨z_t - x*, g_t⟩ + ν²g_t²
    # Convexity at x_t: ⟨∇f(x_t), x_t - x*⟩ ≥ f(x_t) - f*
    # ⟨g_t, z_t - x*⟩ = ⟨g_t, x_t - x*⟩ + ⟨g_t, z_t - x_t⟩
    # = ⟨g_t, x_t - x*⟩ + a η ⟨g_t, m_t⟩
    # The cross-term ⟨g_t, m_t⟩ is the obstacle: it can be positive or negative.

    # Strategy: bound it using L-smoothness on the full sequence.

    z_t = x_t + a * (x_t - x_tm1)  # = (1+a) x_t - a x_tm1
    z_tp1 = x_tp1 + a * (x_tp1 - x_t)  # similarly
    z_diff = sp.simplify(z_tp1 - z_t + nu * g_t)
    print(f"  z_{{t+1}} - z_t + ν g_t = {z_diff}    (must be 0)")

    # Lyapunov for z_t plus a velocity term to control the cross:
    # V_t = (1/2) ||z_t - x*||^2 + γ (η^2 ||m_t||^2)
    # We want γ to absorb the cross term.

    print()
    print("  → The change-of-variables converts SHB into OGD-with-bias on z_t. The bias")
    print("    is L||z_t - x_t|| = L*a*η*|m_t|.  At horizon-tuned η = D/(σ√T), and using")
    print("    the velocity-recursion bound ||m_t||^2 ≤ Σ β^{2(t-k)} ||g_k||^2 / (1-β^2)")
    print("    (Cauchy-Schwarz), the bias decays as O(1/T) for the bias term and O(1/√T)")
    print("    for the variance.")

    # Velocity bound check: ||m_t||^2 ≤ (1/(1-β)) Σ β^{t-k} ||g_k||^2
    # by weighted Cauchy-Schwarz (Section 5 of gap2_proof.md).

    print()
    print("  This derivation is what direction_2 §5 (Theorem D, projected) does. For")
    print("  unprojected, the same argument needs an additional step: bound ||x_t - x*||")
    print("  uniformly in t. We use the noise-floor bound: at horizon-tuned η,")
    print("  ||x_t - x*||^2 ≤ D^2 + Tη²σ² ≤ 2D^2 since Tη²σ² = T·D²/T = D².")


if __name__ == "__main__":
    main()
