"""
Final consolidated verification of SP-2 and SP-4 claims for fixer_round2.md.
"""

import sympy as sp
from sympy import Matrix, eye, Symbol, simplify, expand, cancel, factor, Poly, exp, I, pi, Rational, Integer, nsimplify
from itertools import product

t = Symbol('t')
y = Symbol('y')


def sigma_bar(i, p, sign):
    n = p - 1
    if p == 2:
        return Matrix([[-t]]) if sign == 1 else Matrix([[-1/t]])
    M = eye(n)
    if i == 1:
        block = Matrix([[-t, 1], [0, 1]])
        if sign == -1:
            block = block.inv()
        for a in range(2):
            for b in range(2):
                M[a, b] = block[a, b]
        return M
    if i == p - 1:
        block = Matrix([[1, 0], [t, -t]])
        if sign == -1:
            block = block.inv()
        for a in range(2):
            for b in range(2):
                M[(n-2)+a, (n-2)+b] = block[a, b]
        return M
    block = Matrix([[1, 0, 0], [t, -t, 1], [0, 0, 1]])
    if sign == -1:
        block = block.inv()
    for a in range(3):
        for b in range(3):
            M[(i-2)+a, (i-2)+b] = block[a, b]
    return M


def rho_bar(eps, p):
    n = p - 1
    B = eye(n)
    for i in range(1, p):
        B = B * sigma_bar(i, p, eps[i-1])
    return B


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


def laurent_breadth(expr, var):
    e = sp.cancel(sp.expand(expr))
    num, den = sp.fraction(e)
    Pt2 = Poly(expand(num), var)
    coefs = {}
    for monom_tuple, coef in Pt2.terms():
        coefs[monom_tuple[0]] = coef
    den_deg = 0 if den == 1 else Poly(expand(den), var).terms()[0][0][0]
    final_coefs = {d - den_deg: c for d, c in coefs.items()}
    degrees = sorted(final_coefs.keys())
    return degrees[-1], degrees[0], degrees[-1] - degrees[0]


print("="*70)
print("SP-2 VERIFICATION: det(I - B_eps) = t^{(e-(p-1))/2} * Phi_p(t)")
print("="*70)
sp2_ok = True
for p in [2, 3, 4, 5, 6]:
    for eps in product([1, -1], repeat=p-1):
        B = rho_bar(eps, p)
        det_B = simplify(expand((eye(p-1) - B).det()))
        e = sum(eps)
        k_exp = (p - 1 - e) // 2
        phi_p = sum(t**k for k in range(p))
        ratio = simplify(cancel(det_B * t**k_exp / phi_p))
        if ratio != 1:
            print(f"FAIL p={p}, eps={eps}: ratio={ratio}")
            sp2_ok = False
print(f"SP-2: {'PASS' if sp2_ok else 'FAIL'} on all p in [2,6], all eps (62 cases)")
print()

print("="*70)
print("SP-4 VERIFICATION: breadth_t(prod C_{p-1}(zeta^ell, t)) = (p-1)(q-1)")
print("="*70)
test_cases = [
    (2, 3, (1,)),
    (3, 2, (1, 1)),
    (3, 2, (1, -1)),
    (3, 4, (1, 1)),
    (4, 3, (1, 1, 1)),
    (3, 5, (1, -1)),
]
sp4_ok = True
for p, q, eps in test_cases:
    B = rho_bar(eps, p)
    Bq = B**q
    phi = sum(t**k for k in range(p))
    alex = simplify(cancel((eye(p-1) - Bq).det() / phi))
    top, bot, br = laurent_breadth(alex, t)
    expected = (p-1)*(q-1)
    ok = (br == expected)
    eps_s = "".join("+" if s==1 else "-" for s in eps)
    mark = "OK" if ok else "FAIL"
    print(f"  (p,q,eps)=({p},{q},{eps_s}): breadth={br}, expected={expected}  [{mark}]")
    if not ok:
        sp4_ok = False
print(f"SP-4: {'PASS' if sp4_ok else 'FAIL'} on all 6 cases")
print()

print("="*70)
print("STRUCTURAL SUB-LEMMA VERIFICATION")
print("="*70)
# Top coef of C_{p-1} = y^{n+} at t^{n-}; bot = y^{n-} at t^{-n+}
sub_ok = True
n_cases = 0
for p in [2, 3, 4, 5, 6]:
    for eps in product([1, -1], repeat=p-1):
        C = C_poly(p-1, eps)
        # Extract top/bot in t, with y as the coefficient variable
        num, den = sp.fraction(sp.cancel(sp.expand(C)))
        Pt2 = Poly(expand(num), t)
        coefs = {m[0]: c for m, c in [(mm, cc) for mm, cc in Pt2.terms()]}
        den_deg = 0 if den == 1 else Poly(expand(den), t).terms()[0][0][0]
        final = {d-den_deg: c for d, c in coefs.items()}
        degrees = sorted(final.keys())
        top_exp, bot_exp = degrees[-1], degrees[0]
        top_coef, bot_coef = final[top_exp], final[bot_exp]
        n_plus = sum(1 for s in eps if s == 1)
        n_minus = sum(1 for s in eps if s == -1)
        # Check top coef == y^{n_plus} and bot coef == y^{n_minus}
        top_check = expand(top_coef - y**n_plus) == 0
        bot_check = expand(bot_coef - y**n_minus) == 0
        exp_check = (top_exp == n_minus) and (bot_exp == -n_plus)
        if not (top_check and bot_check and exp_check):
            print(f"FAIL p={p}, eps={eps}: top={top_coef} at t^{top_exp} (expected y^{n_plus} at t^{n_minus}); bot={bot_coef} at t^{bot_exp} (expected y^{n_minus} at t^{-n_plus})")
            sub_ok = False
        n_cases += 1
print(f"Sub-lemma: {'PASS' if sub_ok else 'FAIL'} on all {n_cases} cases")
