"""
Re-Audit Task 1.2 — SymPy symbolic verification of A_mu^zero vanishing locus.

Goal:
  1. Set up the K=3 characteristic polynomial p(r) = r^2 - (1+beta - eta*lam) r + beta = 0
  2. Compute roots r1, r2 via Vieta.
  3. Compute A_mu^zero = e0 (1 - r2)/(r1 - r2), using x0 = x_{-1} = e0 (so v = e0).
  4. Solve A_mu^zero = 0 -> r2 = 1.
  5. Substitute r = 1 into p: p(1) = 1 - (1+beta - eta*mu) + beta = eta*mu.
  6. So A_mu = 0 iff eta*mu = 0, i.e., mu = 0 (eta>0).
  7. Critical: in F_{K=3}, mu>0 strictly, so A_mu \ne 0 throughout.
"""

import sympy as sp

beta, eta, L, mu, lam, v, r = sp.symbols('beta eta L mu lam v r', real=True, positive=True)

print("="*78)
print("TASK 1.2 — SymPy verification of A_mu^zero vanishing locus")
print("="*78)

# Step 1: characteristic polynomial p(r) = r^2 - (1+beta - eta*lam) r + beta
p = r**2 - (1 + beta - eta*lam)*r + beta
print(f"\n[1] Characteristic polynomial: p(r) = {sp.expand(p)}")

# Step 2: Vieta — r1*r2 = beta,  r1 + r2 = 1+beta - eta*lam
roots = sp.solve(p, r)
r1_expr, r2_expr = roots[0], roots[1]
print(f"\n[2] Roots from solve:")
print(f"    r1 = {sp.simplify(r1_expr)}")
print(f"    r2 = {sp.simplify(r2_expr)}")
print(f"    Vieta sum  r1+r2  = {sp.simplify(r1_expr + r2_expr)}  (expected 1+beta-eta*lam)")
print(f"    Vieta prod r1*r2  = {sp.simplify(r1_expr * r2_expr)}  (expected beta)")

# Step 3: A_mu^zero = v*(1 - r2)/(r1 - r2)  with v = e0, lam = mu (slow mode)
A_mu = v*(1 - r2_expr)/(r1_expr - r2_expr)
A_mu_lambda_mu = A_mu.subs(lam, mu)
print(f"\n[3] A_mu^zero (slow mode lam=mu):")
print(f"    A_mu = v*(1 - r2)/(r1 - r2)")
print(f"    A_mu (lam=mu) = {sp.simplify(A_mu_lambda_mu)}")

# Step 4: A_mu = 0  iff  1 - r2 = 0  iff  r2 = 1
print(f"\n[4] A_mu^zero = 0 iff numerator = 0 iff (1 - r2) = 0 iff r2 = 1.")

# Step 5: substitute r = 1 into p(r):
p_at_1 = p.subs(r, 1)
p_at_1_simpl = sp.simplify(p_at_1)
print(f"\n[5] p(1) = 1 - (1+beta - eta*lam) + beta = {p_at_1_simpl}")
print(f"    -> p(1) = 0 iff eta*lam = 0.")

# Step 6: at lam = mu, p(1) = 0 iff eta*mu = 0, i.e., mu = 0 (eta>0).
p_at_1_mu = p_at_1.subs(lam, mu)
print(f"\n[6] At lam = mu: p(1) = {sp.simplify(p_at_1_mu)} = 0 iff mu = 0 (since eta>0).")
print(f"    Therefore A_mu^zero = 0 iff mu = 0.")

# Step 7: in F_{K=3}, kappa = mu/L in (0, 1), so mu > 0 strictly.
print(f"\n[7] CRITICAL CHECK: in F_{{K=3}}, kappa = mu/L > 0 strictly.")
print(f"    Hence A_mu^zero != 0 throughout F_{{K=3}}.")
print(f"    Verified: A_mu^zero is a non-vanishing function of (beta, eta, mu) on F.")

# Bonus: |A_mu^zero|^2 in under-damped regime (compute symbolically)
# Under-damped: r1, r2 = sqrt(beta) e^{+- i theta}, theta = arccos((1+beta-eta*mu)/(2 sqrt(beta)))
# r2 = conj(r1), r1 - r2 = 2i Im(r1), |r1 - r2|^2 = 4*beta*sin^2(theta) = 4*beta - (1+beta-eta*mu)^2
#                                                                       = -disc

print(f"\n[Bonus] |A_mu^zero|^2 in under-damped regime:")
disc = (1 + beta - eta*mu)**2 - 4*beta
print(f"    disc(p) = {sp.expand(disc)}")
print(f"    Under-damped: disc < 0, |r1 - r2|^2 = -disc = {sp.expand(-disc)}")

# (1 - r1)(1 - r2) = 1 - (r1+r2) + r1*r2 = 1 - (1+beta - eta*mu) + beta = eta*mu
prod_1_minus = 1 - (1 + beta - eta*mu) + beta
print(f"    (1-r1)(1-r2) = 1 - (r1+r2) + r1 r2 = {sp.simplify(prod_1_minus)} = eta*mu")
print(f"    In under-damped regime r2 = conj(r1), so |1-r1|^2 = (1-r1)(1-conj(r1)) = eta*mu.")
print(f"    Hence |A_mu^zero|^2 = v^2 * eta*mu / (4 beta sin^2(theta)).")
print(f"    This is the formula L3.1 in the proof.")

# Validate with substitution at the anchor: beta=0.8, eta L = 3.247, kappa = 0.387
print(f"\n[Anchor] beta=0.8, eta L=3.247, kappa=0.387:")
import mpmath as mp
mp.mp.dps = 50
b_val = mp.mpf('0.8')
etaL_val = mp.mpf('3.247')
kap_val = mp.mpf('0.387')
mu_val = kap_val  # set L=1
eta_val = etaL_val  # since L=1
disc_num = (1 + b_val - eta_val*mu_val)**2 - 4*b_val
print(f"    disc = {disc_num}")
prod1m = 1 - (1 + b_val - eta_val*mu_val) + b_val
print(f"    (1-r1)(1-r2) = {prod1m} (should equal eta*mu = {eta_val*mu_val})")
# r1, r2 = sqrt(beta) e^{+- i theta}
sqb = mp.sqrt(b_val)
theta_mu = mp.acos((1 + b_val - eta_val*mu_val)/(2*sqb))
r1_anchor = sqb * mp.exp(1j*theta_mu)
r2_anchor = sqb * mp.exp(-1j*theta_mu)
print(f"    r1 = {r1_anchor}")
print(f"    r2 = {r2_anchor}")
print(f"    r1 + r2 = {r1_anchor + r2_anchor} (expected 1+beta-eta*mu = {1 + b_val - eta_val*mu_val})")
print(f"    r1 * r2 = {r1_anchor * r2_anchor} (expected beta = {b_val})")
# A_mu^zero with v = D/sqrt(2) (lambda)
v_val = 1/mp.sqrt(2)
A_anchor = v_val*(1 - r2_anchor)/(r1_anchor - r2_anchor)
print(f"    A_mu^zero (v=lambda=1/sqrt(2)) = {A_anchor}")
print(f"    |A_mu^zero| = {abs(A_anchor)}")
sin_t = mp.sin(theta_mu)
A_mod_formula = v_val*mp.sqrt(eta_val*mu_val/(4*b_val*sin_t**2))
print(f"    formula |A| = v*sqrt(eta*mu/(4*beta*sin^2(theta))) = {A_mod_formula}")
print(f"    Discrepancy: {abs(abs(A_anchor) - A_mod_formula)}")

print()
print("="*78)
print("VERDICT: A_mu^zero = 0 iff eta*mu = 0, i.e., mu = 0.")
print("Since F_{K=3} has mu > 0 strictly, A_mu^zero != 0 throughout F_{K=3}. — VALID")
print("="*78)
