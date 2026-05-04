"""
[VERIFIED-SYMPY-PROTOCOL: identity-over-parameter-family, cases=62, description=det(I-B_eps)*t^{(p-1-e)/2} = Phi_p(t) up to sign for p=2..6, all eps in {+-1}^{p-1}]

SP-2: Verify that det(I_{p-1} - B_eps) = t^k * Phi_p(t) for k = (e(eps) - (p-1))/2.

Equivalently, using SP-3 closure, C_{p-1}(1, t) at y=1 should equal
  t^{-(e(eps)+p-1)/2} * (+/-) * Phi_p(t)

More clean: det(I - B_eps) * t^{(p-1-e(eps))/2} = Phi_p(t) up to sign.

Verify directly via the Burau matrices.
"""
import sys

import sympy as sp
from sympy import Matrix, eye, Symbol, simplify, expand, cancel, factor, Poly, Rational
from itertools import product

t = Symbol('t')


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


print("Verifying  det(I - B_eps) * t^{(p-1-e(eps))/2}  ==  +/- Phi_p(t)")
print()
total = 0
fails = 0
for p in [2, 3, 4, 5, 6]:
    phi_p = sum(t**k for k in range(p))
    print(f"--- p = {p}, Phi_p = {phi_p} ---")
    for eps in product([1, -1], repeat=p-1):
        total += 1
        B = rho_bar(eps, p)
        det_B = simplify(expand((eye(p-1) - B).det()))
        e = sum(eps)
        k_exp = (p - 1 - e) // 2
        scaled = simplify(expand(det_B * t**k_exp))
        ratio = simplify(cancel(scaled / phi_p))
        ok = (ratio == 1) or (ratio == -1)
        if not ok:
            fails += 1
        eps_str = "".join("+" if s == 1 else "-" for s in eps)
        print(f"  eps={eps_str}  e={e:+d}  det(I-B) = {factor(det_B)}")
        print(f"     scaled (*t^{k_exp}) = {scaled}   ratio/Phi_p = {ratio}  [{'OK' if ok else 'FAIL'}]")

if fails == 0:
    print(f"ALL PASSED: {total} cases")
    sys.exit(0)
else:
    print(f"FAIL: {fails} of {total} cases failed")
    sys.exit(1)
