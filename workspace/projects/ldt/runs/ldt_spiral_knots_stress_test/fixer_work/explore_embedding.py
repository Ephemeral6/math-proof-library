"""
Explore: how does A_k = rho_bar_p(sigma_1^e1 ... sigma_k^ek) in B_p relate to
         A'_k = rho_bar_{k+1}(sigma_1^e1 ... sigma_k^ek) in B_{k+1}?

Hypothesis: A_k has block form [[A'_k, 0 or v], [0 or w, I_{p-1-k}]] — i.e.,
top-left k x k block equals A'_k, bottom-right is identity, and there are
some off-block terms. Let's test.
"""

import sympy as sp
from sympy import Matrix, eye, Symbol, simplify, cancel, expand, zeros
from itertools import product
import sys
sys.path.insert(0, '.')
from verify_p5 import sigma_matrix, burau_product, C_poly, mu, e_eps

t = Symbol('t')
y = Symbol('y')


def partial_burau_in_p(eps_partial, k, p):
    """Compute rho_bar_p(sigma_1^{e_1} ... sigma_k^{e_k}) as a (p-1) x (p-1) matrix."""
    n = p - 1
    M = eye(n)
    for i in range(1, k + 1):
        M = M * sigma_matrix(i, p, eps_partial[i - 1])
    return M


def study_embedding(eps_full, p):
    """For each k = 1..p-1, compute A_k in B_p and compare to A'_k in B_{k+1}."""
    print(f"=== p = {p}, eps = {eps_full} ===")
    for k in range(1, p):
        A_in_p = partial_burau_in_p(eps_full, k, p)
        A_in_small = partial_burau_in_p(eps_full[:k], k, k + 1)
        print(f"k = {k}:")
        print("  A_k in B_p =")
        sp.pprint(A_in_p)
        print(f"  A'_k in B_{k+1} =")
        sp.pprint(A_in_small)
        # Compare top-left k x k
        topleft = A_in_p[:k, :k]
        diff = simplify(topleft - A_in_small)
        print(f"  A_k[:{k},:{k}] - A'_k =")
        sp.pprint(diff)
        print()


if __name__ == "__main__":
    study_embedding((1, 1, 1), 4)
    study_embedding((1, -1, 1), 4)
    study_embedding((1, 1, 1, 1), 5)
    study_embedding((1, -1, 1, -1), 5)
