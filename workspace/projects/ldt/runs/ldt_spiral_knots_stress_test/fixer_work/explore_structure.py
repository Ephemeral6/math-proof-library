"""
Explore the structure of B_epsilon = rho_bar(sigma_1^{eps_1} ... sigma_{p-1}^{eps_{p-1}}).

Goals:
1. Compute B for various p, eps.
2. Check: is det(I_k - y * B^{[k]}) (leading principal k x k minor) related in a simple way to C_k?
3. Check the trailing-last-two-columns claim: is it true that B differs from B_prev (eps without last sign) in only last 2 columns? (where B_prev has the correct eps_{1..p-2} block structure).
"""

import sympy as sp
from sympy import Matrix, eye, Symbol, simplify, cancel, expand, pprint
from itertools import product

t = Symbol('t')
y = Symbol('y')

# Import sigma_matrix, burau_product, etc. from verify_p5
import sys
sys.path.insert(0, '.')
from verify_p5 import sigma_matrix, burau_product, C_poly, mu, e_eps


def leading_minor(M, k):
    """Return the top-left k x k submatrix of M."""
    return M[:k, :k]


def show_B(eps):
    p = len(eps) + 1
    B = burau_product(eps, p)
    print(f"p = {p}, eps = {eps}")
    print("B =")
    pprint(B)
    print()
    # Compare B to B' where B' = burau_product(eps[:-1], p).
    # But dimensions differ, so this is tricky. Instead, compare B to the product of just the first p-2 sigmas inside the p-strand Burau.
    if p >= 3:
        B_partial = eye(p - 1)
        for i in range(1, p - 1):  # sigma_1 ... sigma_{p-2}
            B_partial = B_partial * sigma_matrix(i, p, eps[i - 1])
        print("B_partial (product of first p-2 sigmas) =")
        pprint(B_partial)
        print("Diff B - B_partial =")
        pprint(sp.simplify(B - B_partial))
        print()


def study_principal_minors(eps):
    p = len(eps) + 1
    B = burau_product(eps, p)
    n = p - 1
    print(f"p = {p}, eps = {eps}, e(eps) = {e_eps(eps)}")
    for k in range(1, n + 1):
        Bk = leading_minor(B, k)
        Dk = simplify(expand((eye(k) - y * Bk).det()))
        Ck = C_poly(k, eps)
        ratio = simplify(cancel(Dk / Ck))
        e_k = sum(eps[:k])
        print(f"  k={k}: det(I_k - y B[:{k},:{k}]) = {Dk}")
        print(f"         C_{k}(y,t) = {sp.expand(Ck)}")
        print(f"         ratio = {ratio}, expected t^{e_k} = {t**e_k}")


if __name__ == "__main__":
    print("=== Studying B's structure for small p ===")
    for eps in [(1, 1, 1), (1, -1, 1), (-1, 1, -1)]:
        show_B(eps)

    print("=== Principal leading minors D_k versus C_k ===")
    for eps in [(1, 1, 1), (1, -1, 1), (1, 1, 1, 1), (1, -1, 1, -1), (-1, -1, 1, 1)]:
        study_principal_minors(eps)
        print()
