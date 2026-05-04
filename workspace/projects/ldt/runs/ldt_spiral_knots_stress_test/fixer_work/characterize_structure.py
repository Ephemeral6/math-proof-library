"""
Characterize the block structure of A_k := rho_bar_p(sigma_1^e1 ... sigma_k^ek) in B_p.

Hypothesis (to test): A_k has the form
  [[A'_k, c_k, 0],
   [0,    d_k, 0],
   [0,    0,   I_{p-2-k}]]
where A'_k is (k x k), c_k is a k-vector (column), d_k is a scalar, and the last
p-2-k rows are [0 0 I].

Special case: when k = p-1, the block [[A'_k, c_k], [0, d_k]] should equal B_epsilon,
but we expect the "c_k, d_k" to still be meaningful — except at k=p-1 there's no
trailing I block.

Goal: find the explicit form of c_k (last column) and d_k (the (k+1,k+1) entry).
"""

import sympy as sp
from sympy import Matrix, eye, Symbol, simplify, cancel, expand, zeros, Rational
import sys
sys.path.insert(0, '.')
from verify_p5 import sigma_matrix, burau_product, C_poly, mu, e_eps

t = Symbol('t')
y = Symbol('y')


def partial_burau_in_p(eps_partial, k, p):
    n = p - 1
    M = eye(n)
    for i in range(1, k + 1):
        M = M * sigma_matrix(i, p, eps_partial[i - 1])
    return M


def examine(eps_full, p):
    print(f"\n=== p = {p}, eps = {eps_full} ===")
    for k in range(1, p):
        A = partial_burau_in_p(eps_full, k, p)
        # Check the structure
        n = p - 1
        print("k = %d, e(eps_1..k) = %d" % (k, sum(eps_full[:k])))
        # column k+1 (1-indexed) = column index k (0-indexed)
        if k < n:
            col = A[:, k]  # this is column k+1 (1-indexed)
            print(f"  column {k+1} (= c_k followed by d_k followed by 0s): {list(col)}")
            # column k+1 should be (c_k; d_k; 0; 0; ...)
            # and rows (k+2, ..., p-1) should be (0; ...; 1; 0; ... depending on position)
            for r in range(k + 1, n):
                print(f"  row {r+1}: {list(A[r, :])}")
        # Now, relate c_k to columns of A'_k: specifically to last column of A'_k
        if k >= 1:
            A_small = partial_burau_in_p(eps_full[:k], k, k + 1)
            print(f"  A'_k last column = {list(A_small[:, -1])}")


if __name__ == "__main__":
    for eps, p in [((1, 1, 1), 4), ((1, -1, 1), 4), ((-1, 1, -1), 4),
                   ((1, 1, 1, 1), 5), ((1, -1, 1, -1), 5), ((-1, 1, -1, 1), 5)]:
        examine(eps, p)
