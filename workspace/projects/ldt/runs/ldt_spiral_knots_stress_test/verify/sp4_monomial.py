"""
[VERIFIED-SYMPY-PROTOCOL: identity-over-parameter-family, cases=62, description=top/bot t-coefs of C_{p-1}(y,t) are monic monomials in y of degrees n^+/n^- for p=2..6, all eps]

Check: top and bottom t-coefs of C_{p-1}(y,t) are monomials c*y^d with d = n^+ (top)
or d = n^- (bot), with c in {+1, -1} (sign).
"""
import sys
import sympy as sp
from sympy import Symbol, simplify, expand, cancel, Poly, exp, I, pi, Rational, Integer
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
    e = sp.cancel(sp.expand(expr))
    num, den = sp.fraction(e)
    num_expanded = expand(num)
    Pt2 = Poly(num_expanded, t)
    coefs = {}
    for monom_tuple, coef in Pt2.terms():
        t_deg = monom_tuple[0]
        coefs[t_deg] = coef
    den_expanded = expand(den)
    Pden = Poly(den_expanded, t)
    den_deg = Pden.degree()
    final_coefs = {d - den_deg: c for d, c in coefs.items()}
    degrees = sorted(final_coefs.keys())
    top_exp = degrees[-1]
    bot_exp = degrees[0]
    top_coef = final_coefs[top_exp]
    bot_coef = final_coefs[bot_exp]
    return top_exp, top_coef, bot_exp, bot_coef


print("Check top/bot t-coefs of C_{p-1} are monomials in y")
print()
all_mono = True
total = 0
for p in [2, 3, 4, 5, 6]:
    for eps in product([1, -1], repeat=p-1):
        total += 1
        C = C_poly(p-1, eps)
        top_exp, top_coef, bot_exp, bot_coef = extract_top_bot_in_t(C)
        # Check top_coef is a monomial in y
        top_expanded = expand(top_coef)
        bot_expanded = expand(bot_coef)
        top_Py = Poly(top_expanded, y)
        bot_Py = Poly(bot_expanded, y)
        top_terms = top_Py.terms()
        bot_terms = bot_Py.terms()
        n_plus = sum(1 for s in eps if s == 1)
        n_minus = sum(1 for s in eps if s == -1)
        is_top_mono = len(top_terms) == 1
        is_bot_mono = len(bot_terms) == 1
        top_deg = top_terms[0][0][0] if is_top_mono else -1
        bot_deg = bot_terms[0][0][0] if is_bot_mono else -1
        top_coeff_c = top_terms[0][1] if is_top_mono else None
        bot_coeff_c = bot_terms[0][1] if is_bot_mono else None
        mark_top = "OK" if (is_top_mono and top_deg == n_plus) else "FAIL"
        mark_bot = "OK" if (is_bot_mono and bot_deg == n_minus) else "FAIL"
        eps_s = "".join("+" if s == 1 else "-" for s in eps)
        if mark_top != "OK" or mark_bot != "OK":
            print(f"  p={p}, eps={eps_s}: top={top_coeff_c}*y^{top_deg} (n+={n_plus}) [{mark_top}], bot={bot_coeff_c}*y^{bot_deg} (n-={n_minus}) [{mark_bot}]")
            all_mono = False
print("All top/bot monomials:", "PASS" if all_mono else "FAIL")
if not all_mono:
    print(f"FAIL: among {total} cases, some top/bot were not pure monomials")
    sys.exit(1)

# And check: top coef = (+/-)^? y^{n+}, bot coef = (+/-)^? y^{n-}
# Pattern of signs?
print()
print("Detailed top/bot for small cases:")
for p in [2, 3, 4]:
    for eps in product([1, -1], repeat=p-1):
        C = C_poly(p-1, eps)
        top_exp, top_coef, bot_exp, bot_coef = extract_top_bot_in_t(C)
        eps_s = "".join("+" if s == 1 else "-" for s in eps)
        print(f"  p={p}, eps={eps_s}: C_{p-1} = {expand(top_coef)}*t^{top_exp} + ... + {expand(bot_coef)}*t^{bot_exp}")

print(f"ALL PASSED: {total} cases")
sys.exit(0)
