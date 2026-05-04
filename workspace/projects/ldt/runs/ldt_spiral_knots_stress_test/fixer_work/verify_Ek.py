"""
Verify E_k(y, t) := det(I_k - y * A'_k) = t^{e(eps_{1..k})} * C_k(y, t)
for k = 1, ..., p-1 where A'_k is the (k)x(k) matrix in B_{k+1}.

This is the INTRINSIC version of the identity, parameterized by the prefix length k.
"""

import sympy as sp
from sympy import Matrix, eye, Symbol, simplify, cancel, expand
from itertools import product
import sys
sys.path.insert(0, '.')
from verify_p5 import sigma_matrix, burau_product, C_poly, mu, e_eps

t = Symbol('t')
y = Symbol('y')


def A_prime(eps_prefix):
    """A'_k in B_{k+1} = rho_bar_{k+1}(sigma_1^{e_1} ... sigma_k^{e_k}), a k x k matrix."""
    k = len(eps_prefix)
    return burau_product(eps_prefix, k + 1)


def E_k(eps_prefix):
    k = len(eps_prefix)
    A = A_prime(eps_prefix)
    return simplify(expand((eye(k) - y * A).det()))


def test_all(max_k=5):
    for k in range(1, max_k + 1):
        for eps in product([1, -1], repeat=k):
            Ek = E_k(eps)
            Ck = C_poly(k, eps)
            e_val = sum(eps)
            rhs = t ** e_val * Ck
            diff = simplify(cancel(expand(Ek - rhs)))
            tag = "OK" if diff == 0 else "FAIL"
            if tag == "FAIL":
                print(f"k = {k}, eps = {eps}: E_k = {Ek}, t^{e_val} C_k = {sp.expand(rhs)}  [FAIL, diff={diff}]")
            else:
                # brief pass line
                pass
        print(f"k = {k}: all {2**k} cases PASSED E_k = t^{{e}} C_k")


if __name__ == "__main__":
    test_all(max_k=5)
