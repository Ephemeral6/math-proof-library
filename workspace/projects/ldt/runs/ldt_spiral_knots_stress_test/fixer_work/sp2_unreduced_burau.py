"""
SP-2 verification: figure out unreduced Burau in the Birman-Weinberg convention
and verify the factorization det(I_p - rho(beta)) = (1 - t^?) * det(I_{p-1} - rho_bar(beta)) * (factor)

The standard Burau representation (unreduced) rho: B_p -> GL_p(Z[t,t^{-1}]) is:
  rho(sigma_i) = I_{i-1} + block + I_{p-i-1}
where the block at rows/cols (i, i+1) is [[1-t, t], [1, 0]] (one common convention).
This has the common eigenvector (1,1,...,1)^T: row i of the block acts as
  (1-t, t) -> (1-t) + t = 1, and (1, 0) -> 1. So yes, (1,...,1)^T is preserved.

The reduced Burau rho_bar is obtained by quotienting by this invariant line.
In the "lower" triangular presentation (what Birman uses), this gives (p-1)x(p-1) matrices.

However, our convention from best_proof.md Step 4 uses DIFFERENT matrices — the
Birman-Weinberg convention has reduced-Burau generator blocks
  U_1 = [[-t, 1], [0, 1]]
  U_{p-1} = [[1, 0], [t, -t]]
  U_i (middle) = [[1, 0, 0], [t, -t, 1], [0, 0, 1]]   (2 <= i <= p-2)

Let me first establish the unreduced Burau in this convention by extending each
generator. The "extended" matrices should be (p x p) and have a common eigenvector.

Strategy: try several candidate unreduced forms and check which one
(i) reduces to our rho_bar after quotienting by a common eigenvector,
(ii) produces the desired factorization.

Key goal: verify explicitly that
  det(I_p - rho(beta_spiral)) = (1 - t) * det(I_{p-1} - rho_bar(beta_spiral)) * Phi_p(t) / (appropriate factor)
...actually the cleaner statement is:

Standard fact (Birman 1974, Thm 3.11):
  det(I_p - rho(beta)) = (1 - t^{e(beta)}) * det(I_{p-1} - rho_bar(beta)) / (1 + t + ... + t^{p-1})  ???

Hmm, let me just compute directly and see.
"""

import sympy as sp
from sympy import Matrix, eye, Symbol, simplify, expand, cancel, Rational, factor
from itertools import product

t = Symbol('t')


def sigma_bar(i, p, sign):
    """Reduced Burau of sigma_i^sign, (p-1)x(p-1), Birman-Weinberg convention."""
    n = p - 1
    if p == 2:
        return Matrix([[-t]]) if sign == 1 else Matrix([[-1/t]])
    M = eye(n)
    if i == 1:
        block = Matrix([[-t, 1], [0, 1]])
        if sign == -1:
            block = block.inv()
        M[0, 0] = block[0, 0]; M[0, 1] = block[0, 1]
        M[1, 0] = block[1, 0]; M[1, 1] = block[1, 1]
        return M
    if i == p - 1:
        block = Matrix([[1, 0], [t, -t]])
        if sign == -1:
            block = block.inv()
        M[n-2, n-2] = block[0,0]; M[n-2, n-1] = block[0,1]
        M[n-1, n-2] = block[1,0]; M[n-1, n-1] = block[1,1]
        return M
    block = Matrix([[1, 0, 0], [t, -t, 1], [0, 0, 1]])
    if sign == -1:
        block = block.inv()
    for a in range(3):
        for b in range(3):
            M[(i-2)+a, (i-2)+b] = block[a, b]
    return M


def rho_bar(eps, p):
    """B = rho_bar(sigma_1^eps_1 ... sigma_{p-1}^eps_{p-1})."""
    n = p - 1
    B = eye(n)
    for i in range(1, p):
        B = B * sigma_bar(i, p, eps[i-1])
    return B


# Unreduced Burau (standard convention): rho(sigma_i) is p x p
# with block at rows/cols (i-1, i) being  [[1-t, t], [1, 0]]  (0-indexed)
# This has (1,1,...,1)^T as invariant under row action... wait, let's check:
# Row: (1-t, t) -> (1-t)*1 + t*1 = 1. (1, 0) -> 1. OK, row-stochastic on (1,...,1)^T => preserves (1,...,1)^T.

def sigma_unreduced_std(i, p, sign):
    """Standard unreduced Burau of sigma_i^sign, pxp, with block [[1-t, t], [1, 0]]."""
    M = eye(p)
    block = Matrix([[1-t, t], [1, 0]])
    if sign == -1:
        block = block.inv()
    M[i-1, i-1] = block[0,0]; M[i-1, i] = block[0,1]
    M[i, i-1] = block[1,0]; M[i, i] = block[1,1]
    return M


def rho_std(eps, p):
    M = eye(p)
    for i in range(1, p):
        M = M * sigma_unreduced_std(i, p, eps[i-1])
    return M


# Check invariant vector
for p in [3, 4]:
    print(f"--- p = {p} ---")
    for i in range(1, p):
        M = sigma_unreduced_std(i, p, 1)
        v = Matrix([1]*p)
        w = M * v
        print(f"  sigma_{i} * (1,...,1)^T = {w.T}  (invariant: {simplify(w - v) == sp.zeros(p, 1)})")

# For the spiral braid, compute det(I_p - rho(beta)) and compare to det(I_{p-1} - rho_bar(beta))
# BUT: the two representations use different conventions. The "standard" unreduced rho
# above might not reduce to our Birman-Weinberg rho_bar. Let's compute both and see the ratio.

print("\n--- Comparing det factors ---")
for p in [2, 3, 4]:
    for eps in product([1, -1], repeat=p-1):
        B_bar = rho_bar(eps, p)
        B = rho_std(eps, p)
        e = sum(eps)
        det_full = simplify(expand((eye(p) - B).det()))
        det_red = simplify(expand((eye(p-1) - B_bar).det()))
        # Check: det(I - rho(beta)) = 0 always, since (1,...,1) is invariant
        # So det_full should be 0 for all q=1. Let's check.
        print(f"p={p}, eps={eps}: det(I-rho(beta))={det_full}, det(I-rho_bar(beta))={factor(det_red)}")
