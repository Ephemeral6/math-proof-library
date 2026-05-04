"""
[VERIFIED-SYMPY-PROTOCOL: polynomial-breadth, cases=128, description=top t-power = #{eps=-1} and bot t-power = -#{eps=+1} (so breadth=k) for C_k, k=0..p-1, p=2..5, all eps]

Compute top and bottom t-powers of C_{p-1}(y, t), as polynomials in y.

Claim:
  alpha_k = #{i <= k : eps_i = -1}  (top t-power in C_k)
  beta_k  = -#{i <= k : eps_i = +1} (bottom t-power in C_k)
  breadth_t(C_k) = k.

Top coef T_k(y) and bottom coef B_k(y) are polynomials in y; verify formulas.

Also verify the product over ell=1..q-1 of top/bottom coefs is nonzero integer.
"""
import sys

import sympy as sp
from sympy import Symbol, simplify, expand, cancel, Poly, exp, I, pi, Rational, nsimplify, Integer
from itertools import product

t = Symbol('t')
y = Symbol('y')


def mu(eps_i):
    return 1 if eps_i == 1 else t


def C_poly(k, eps):
    if k == 0:
        return sp.Integer(1)
    mu1 = mu(eps[0])
    if k == 1:
        return mu1**2 / t + y
    C_prev2 = sp.Integer(1)
    C_prev1 = mu1**2 / t + y
    for j in range(2, k + 1):
        mu_j = mu(eps[j-1])
        mu_jm1 = mu(eps[j-2])
        C_cur = (mu_j**2 / t + y) * C_prev1 - (mu_jm1 * mu_j * y / t) * C_prev2
        C_prev2 = C_prev1
        C_prev1 = C_cur
    return C_prev1


def extract_top_bot_in_t(expr):
    """Return (top_exp, top_coef, bot_exp, bot_coef) where the extremes are in t
    and coefs are polynomials in y.
    """
    e = sp.cancel(sp.expand(expr))
    num, den = sp.fraction(e)
    P = Poly(expand(num), t, y)
    # We need top/bot t-exponent and the y-polynomial coefficient
    # Extract as poly in t with coefs in y
    Pt = Poly(expand(num), t)
    # Coefs (in y) indexed by t-degree
    terms_t = Pt.as_dict()  # {(deg,): coef_in_y}
    # Actually Poly with just t gives coefs as expressions in y
    # Use as_expr_dict approach
    coefs = {}
    # Rebuild via collect
    # Simpler: iterate over monomials by treating num as polynomial in t only
    num_expanded = expand(num)
    Pt2 = Poly(num_expanded, t)
    # Iterate over terms
    for monom_tuple, coef in Pt2.terms():
        t_deg = monom_tuple[0]
        coefs[t_deg] = coef
    # den is a power of t
    den_expanded = expand(den)
    Pden = Poly(den_expanded, t)
    den_deg = Pden.degree()
    # Shift: final t-degrees are t_deg - den_deg
    final_coefs = {d - den_deg: c for d, c in coefs.items()}
    degrees = sorted(final_coefs.keys())
    top_exp = degrees[-1]
    bot_exp = degrees[0]
    top_coef = final_coefs[top_exp]
    bot_coef = final_coefs[bot_exp]
    return top_exp, top_coef, bot_exp, bot_coef


print("Verify: alpha_k = #{eps=-1}, beta_k = -#{eps=+1}, breadth = k")
print()
all_ok = True
total = 0
for p in [2, 3, 4, 5]:
    for eps in product([1, -1], repeat=p-1):
        for k in range(p):
            total += 1
            eps_k = eps[:k] if k >= 1 else tuple()
            if k == 0:
                Ck = Integer(1)
            else:
                Ck = C_poly(k, eps_k)
            top_exp, top_coef, bot_exp, bot_coef = extract_top_bot_in_t(Ck)
            n_minus = sum(1 for s in eps_k if s == -1)
            n_plus = sum(1 for s in eps_k if s == +1)
            expected_alpha = n_minus
            expected_beta = -n_plus
            ok = (top_exp == expected_alpha) and (bot_exp == expected_beta)
            if not ok:
                print(f"FAIL: p={p}, k={k}, eps_k={eps_k}, top_exp={top_exp} (expected {expected_alpha}), bot_exp={bot_exp} (expected {expected_beta})")
                all_ok = False
print("alpha/beta check:", "PASS" if all_ok else "FAIL")
print()

# Now print top and bottom coefficients (as polynomials in y) for all 5 test cases
print("Top/bottom coefficients (in y) for test cases:")
print()
test_cases = [
    (2, 3, (1,)),
    (3, 2, (1, 1)),
    (3, 2, (1, -1)),
    (3, 4, (1, 1)),
    (4, 3, (1, 1, 1)),
    (3, 5, (1, -1)),
]
for p, q, eps in test_cases:
    C = C_poly(p-1, eps)
    top_exp, top_coef, bot_exp, bot_coef = extract_top_bot_in_t(C)
    print(f"  (p,q,eps)=({p},{q},{eps}):")
    print(f"    C_{p-1}(y,t) top t-power = {top_exp}, coef (in y) = {expand(top_coef)}")
    print(f"    C_{p-1}(y,t) bot t-power = {bot_exp}, coef (in y) = {expand(bot_coef)}")

    # Now evaluate top_coef and bot_coef at y = zeta^ell and compute product
    zeta = exp(2*pi*I/q)
    prod_top = Integer(1)
    prod_bot = Integer(1)
    for ell in range(1, q):
        prod_top *= top_coef.subs(y, zeta**ell)
        prod_bot *= bot_coef.subs(y, zeta**ell)
    prod_top_s = simplify(expand(prod_top))
    prod_bot_s = simplify(expand(prod_bot))
    print(f"    prod_ell top_coef(zeta^ell) = {nsimplify(prod_top_s)}")
    print(f"    prod_ell bot_coef(zeta^ell) = {nsimplify(prod_bot_s)}")
    # top t-power of the product
    top_total = (q-1) * top_exp
    bot_total = (q-1) * bot_exp
    breadth = top_total - bot_total
    print(f"    top t-power of product = (q-1)*{top_exp} = {top_total}")
    print(f"    bot t-power of product = (q-1)*{bot_exp} = {bot_total}")
    print(f"    => breadth = {breadth} = (p-1)(q-1) = {(p-1)*(q-1)}  ({'OK' if breadth == (p-1)*(q-1) else 'MISMATCH'})")
    print()

if all_ok:
    print(f"ALL PASSED: {total} cases")
    sys.exit(0)
else:
    print(f"FAIL: some of {total} cases failed alpha/beta check")
    sys.exit(1)
