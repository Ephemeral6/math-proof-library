"""
[VERIFIED-SYMPY-PROTOCOL: identity-over-parameter-family, cases=11, description=Q_k/F_{k-1} = 1/mu(k) on 11 sign-prefixes of length 2..5]

Find the relationship: Q_k := det[cols 1..k-1 of (I_k - y A'_k), c_k].

For epsilon prefix = eps_{1..k}, c_k is the "column k+1 of A'_k^{lift} = A_k^{lift}"
which is computable as column k+1 of the partial Burau product in B_{p} for p large.

We want to express Q_k in terms of F_{k-1} = det(I_{k-1} - y A'_{k-1}) and F_{k-2}.

Alternative: look for a formula for Q_k as a polynomial in y, and guess.

Conjecture (Lemma Q): Q_k = F_{k-1} / mu(k), so Q_k/F_{k-1} = 1/mu(k).
"""

import sympy as sp
from sympy import Symbol, Matrix, eye, simplify, cancel, expand, zeros
from itertools import product
import sys
sys.path.insert(0, '.')
from verify_p5 import sigma_matrix, burau_product, C_poly, mu

t = Symbol('t')
y = Symbol('y')


def A_prime(eps_prefix):
    k = len(eps_prefix)
    return burau_product(eps_prefix, k + 1)


def get_ck(eps_prefix):
    """Last column of A'_k^{lift} in B_{k+2}, restricted to top k entries.
    That's column k+1 of A_k (as partial Burau in B_{k+2})."""
    k = len(eps_prefix)
    p = k + 2
    # Compute A_k in B_p
    n = p - 1
    M = eye(n)
    for i in range(1, k + 1):
        M = M * sigma_matrix(i, p, eps_prefix[i - 1])
    # col k+1 (1-indexed) = col index k (0-indexed), top k entries
    return M[:k, k]


def Q_k(eps_prefix):
    """Q_k = det of k x k matrix with cols 1..k-1 from I - y A'_k, last col = c_k."""
    k = len(eps_prefix)
    Ak = A_prime(eps_prefix)
    M = eye(k) - y * Ak  # the I - y A'_k matrix
    ck = get_ck(eps_prefix)
    # Replace last column
    Mnew = M.copy()
    for i in range(k):
        Mnew[i, k - 1] = ck[i]
    return simplify(expand(Mnew.det()))


def F_k(eps_prefix):
    k = len(eps_prefix)
    if k == 0:
        return sp.Integer(1)
    Ak = A_prime(eps_prefix)
    return simplify(expand((eye(k) - y * Ak).det()))


# Conjecture: Q_k = F_{k-1} / mu(k).
total = 0
fails = 0
for eps_full in [
    (1, 1),
    (1, -1),
    (-1, 1),
    (1, 1, 1),
    (1, -1, 1),
    (-1, 1, -1),
    (1, 1, 1, 1),
    (-1, -1, 1, 1),
    (1, -1, 1, -1),
    (1, 1, 1, 1, 1),
    (1, -1, -1, 1, -1),
]:
    total += 1
    k = len(eps_full)
    Q = Q_k(eps_full)
    F_prev = F_k(eps_full[:-1])  # F_{k-1}
    mu_k = 1 if eps_full[-1] == 1 else t
    mu_km1 = 1 if eps_full[-2] == 1 else t if k >= 2 else 1
    ratio = simplify(cancel(Q / F_prev))
    # Check conjecture: ratio == 1/mu_k
    expected = sp.Rational(1) / mu_k if mu_k == 1 else 1 / mu_k
    diff = simplify(ratio - expected)
    ok = (diff == 0)
    tag = "OK" if ok else "FAIL"
    if not ok:
        fails += 1
    print(f"k={k}, eps={eps_full}: Q_k/F_{{k-1}} = {ratio}   (mu(k)={mu_k}, mu(k-1)={mu_km1})   [{tag}]")

if fails == 0:
    print(f"ALL PASSED: {total} cases")
    sys.exit(0)
else:
    print(f"FAIL: {fails} of {total} cases failed")
    sys.exit(1)
