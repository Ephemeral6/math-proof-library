"""
[VERIFIED-SYMPY-PROTOCOL: identity-over-parameter-family, cases=258, description=C_k(1,t) = t^{-(e_k+k)/2} * Phi_{k+1}(t) for p=2..6, k=1..p-1, all eps]

Verify C_k(1, t) = t^{-(e_k + k)/2} * Phi_{k+1}(t) up to sign, for all prefixes.
"""
import sys

import sympy as sp
from sympy import Matrix, eye, Symbol, simplify, expand, cancel, factor, Rational
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


print("Verifying C_k(1,t) = t^{-(e_k+k)/2} * Phi_{k+1}(t)")
print()
all_ok = True
count = 0
for p in [2, 3, 4, 5, 6]:
    for eps in product([1, -1], repeat=p-1):
        # Test for every prefix k = 1, ..., p-1
        for k in range(1, p):
            eps_k = eps[:k]
            e_k = sum(eps_k)
            Ck = C_poly(k, eps_k).subs(y, 1)
            Ck = simplify(cancel(Ck))
            phi_kp1 = sum(t**j for j in range(k+1))
            # Expected
            exp_power = -(e_k + k) // 2
            if (e_k + k) % 2 != 0:
                print(f"Parity issue: k={k}, e_k={e_k}, eps={eps_k}")
                all_ok = False
                continue
            predicted = t**exp_power * phi_kp1
            diff = simplify(expand(Ck - predicted))
            ok = (diff == 0)
            count += 1
            if not ok:
                eps_str = "".join("+" if s == 1 else "-" for s in eps_k)
                print(f"FAIL: p={p}, eps_k={eps_str}, k={k}, Ck={Ck}, predicted={predicted}, diff={diff}")
                all_ok = False
print(f"Total {count} checks. All OK: {all_ok}")
if all_ok:
    print(f"ALL PASSED: {count} cases")
    sys.exit(0)
else:
    print(f"FAIL: some of {count} cases failed")
    sys.exit(1)
