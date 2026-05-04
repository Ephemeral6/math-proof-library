"""
[VERIFIED-SYMPY-PROTOCOL: identity-over-parameter-family, cases=30, description=det(I - y*B_eps) = t^{e(eps)} * C_{p-1}(y, t) for p=2..5 and all eps in {+-1}^{p-1}]

Verify det(I - y*B_epsilon) = t^{e(epsilon)} * C_{p-1}(y, t) for p = 5.
Also verify for p = 2, 3, 4 as regression check.

Uses the Birman-Weinberg reduced-Burau convention from the Explorer's Step 4:
  rho_bar(sigma_i) = I_{i-2} oplus U_i oplus I_{p-i-2}
with
  U_1 = [[-t, 1], [0, 1]]        (2x2; for i=1)
  U_{p-1} = [[1, 0], [t, -t]]    (2x2; for i = p-1)
  U_i = [[1, 0, 0], [t, -t, 1], [0, 0, 1]]   (3x3; for 2 <= i <= p-2)

C_k(x, t) recursion:
  C_0 = 1, C_1 = mu(1)^2/t + x
  C_k = (mu(k)^2/t + x) * C_{k-1} - (mu(k-1)*mu(k)*x/t) * C_{k-2}
where mu(i) = 1 if eps_i = +1, and mu(i) = t if eps_i = -1.
"""

import sympy as sp
from sympy import Matrix, eye, Symbol, simplify, expand, cancel, zeros
from itertools import product

t = Symbol('t')
y = Symbol('y')


def sigma_matrix(i, p, sign):
    """Return the (p-1)x(p-1) reduced-Burau matrix of sigma_i^{sign}.
    i is 1-indexed from 1 to p-1.
    """
    n = p - 1
    # Special case p = 2: n = 1, only sigma_1, rho_bar(sigma_1) = [-t]
    if p == 2:
        if sign == 1:
            return Matrix([[-t]])
        else:
            return Matrix([[-1 / t]])
    M = eye(n)
    # Block position: U_i occupies rows/cols i-1, i (0-indexed) when i in the middle
    # For i = 1: U_1 is 2x2 at rows/cols (0, 1) — but since i-2 = -1, we take U_1 at (0, 1) only; the i-2 block is empty.
    # For i = p-1: U_{p-1} is 2x2 at rows/cols (p-3, p-2) — the trailing I block is empty.
    # For 2 <= i <= p-2: U_i is 3x3 at rows/cols (i-2, i-1, i), i.e. 1-indexed (i-1, i, i+1).
    # Let's verify by direct formula:

    if i == 1:
        # U_1 acts on (1, 2) in 1-indexed = (0, 1) in 0-indexed
        # U_1 = [[-t, 1], [0, 1]]
        block = Matrix([[-t, 1], [0, 1]])
        if sign == -1:
            block = block.inv()
        # Place block at rows/cols (0, 1)
        for a in range(2):
            for b in range(2):
                M[a, b] = block[a, b]
        # Ensure off-block entries are identity (already done via eye)
        # But we need to zero out M[0, b] for b >= 2 if block overwrites identity — identity is already placed; just set the 2x2 region.
        return M

    if i == p - 1:
        # U_{p-1} acts on (p-2, p-1) in 1-indexed = (p-3, p-2) in 0-indexed = (n-2, n-1)
        block = Matrix([[1, 0], [t, -t]])
        if sign == -1:
            block = block.inv()
        for a in range(2):
            for b in range(2):
                M[(n - 2) + a, (n - 2) + b] = block[a, b]
        return M

    # 2 <= i <= p-2: U_i is 3x3 acting on (i-1, i, i+1) in 1-indexed = (i-2, i-1, i) in 0-indexed
    block = Matrix([[1, 0, 0], [t, -t, 1], [0, 0, 1]])
    if sign == -1:
        block = block.inv()
    for a in range(3):
        for b in range(3):
            M[(i - 2) + a, (i - 2) + b] = block[a, b]
    return M


def burau_product(eps, p):
    """B = rho_bar(sigma_1^{eps_1} ... sigma_{p-1}^{eps_{p-1}})."""
    n = p - 1
    B = eye(n)
    for i in range(1, p):
        B = B * sigma_matrix(i, p, eps[i - 1])
    return B


def mu(eps_i):
    """mu: +1 -> 1, -1 -> t."""
    return 1 if eps_i == 1 else t


def C_poly(k, eps):
    """Compute C_k(y, t) via the recursion, for the given eps = (eps_1, ..., eps_{p-1}).
    C_0 = 1, C_1 = mu(1)^2/t + y.
    C_k = (mu(k)^2/t + y) C_{k-1} - (mu(k-1) mu(k) y / t) C_{k-2}.
    Here k ranges 1..p-1 and mu(k) = mu(eps_{k}) where eps is 1-indexed, so eps[k-1] in python.
    """
    if k == 0:
        return sp.Integer(1)
    mu1 = mu(eps[0])
    if k == 1:
        return mu1**2 / t + y
    # build iteratively
    C_prev2 = sp.Integer(1)  # C_0
    C_prev1 = mu1**2 / t + y  # C_1
    for j in range(2, k + 1):
        mu_j = mu(eps[j - 1])
        mu_jm1 = mu(eps[j - 2])
        C_cur = (mu_j**2 / t + y) * C_prev1 - (mu_jm1 * mu_j * y / t) * C_prev2
        C_prev2 = C_prev1
        C_prev1 = C_cur
    return C_prev1


def e_eps(eps):
    return sum(eps)


def verify_one(eps):
    p = len(eps) + 1
    B = burau_product(eps, p)
    n = p - 1
    lhs = (eye(n) - y * B).det()
    rhs = t ** e_eps(eps) * C_poly(p - 1, eps)
    diff = simplify(cancel(expand(lhs - rhs)))
    ratio = simplify(cancel(lhs / C_poly(p - 1, eps)))
    return diff == 0, ratio, lhs, rhs


def run_for_p(p):
    print(f"--- p = {p} ---")
    results = []
    for eps in product([1, -1], repeat=p - 1):
        ok, ratio, lhs, rhs = verify_one(eps)
        status = "OK" if ok else "FAIL"
        eps_str = "(" + ",".join(f"{'+' if s == 1 else '-'}1" for s in eps) + ")"
        print(f"  eps = {eps_str}  e(eps) = {e_eps(eps):+d}  ratio = {ratio}  [{status}]")
        results.append((eps, ok, ratio))
    n_ok = sum(1 for _, ok, _ in results if ok)
    print(f"  PASS: {n_ok}/{len(results)}")
    return results


if __name__ == "__main__":
    import sys
    total_ok = 0
    total = 0
    # regression check
    for p in [2, 3, 4]:
        results = run_for_p(p)
        total += len(results)
        total_ok += sum(1 for _, ok, _ in results if ok)
    print()
    # main deliverable: p = 5
    results = run_for_p(5)
    total += len(results)
    total_ok += sum(1 for _, ok, _ in results if ok)
    if total_ok == total:
        print(f"ALL PASSED: {total} cases")
        sys.exit(0)
    else:
        print(f"FAIL: {total - total_ok} of {total} cases failed")
        sys.exit(1)
