"""
Empirically test whether F_k := det(I_k - y A'_k) satisfies, under right-multiplication
of A'_k by rho_bar(sigma_k^{eps_k}) to form A'_k', a three-term recursion of the form:

   F_{k}(y) = alpha(k) F_{k-1}(y) + beta(k) F_{k-2}(y)

matching the C_k recursion (scaled by t^{e(eps)}).

Recall C_k = (mu(k)^2/t + y) C_{k-1} - (mu(k-1) mu(k) y/t) C_{k-2}.

We expect, given E_k = t^{e_k} C_k where e_k = eps_1+...+eps_k:
  E_k = (mu(k)^2/t + y) * t^{e_k - e_{k-1}} * E_{k-1}/t^{e_{k-1}} + ...
No wait — we have E_k = t^{e_k} C_k, so C_k = E_k / t^{e_k}. The recursion C_k = alpha C_{k-1} - beta C_{k-2} becomes
  E_k / t^{e_k} = alpha (k) * E_{k-1}/t^{e_{k-1}} - beta(k) * E_{k-2}/t^{e_{k-2}}
  E_k = alpha(k) t^{e_k - e_{k-1}} E_{k-1} - beta(k) t^{e_k - e_{k-2}} E_{k-2}
  E_k = alpha(k) t^{eps_k} E_{k-1} - beta(k) t^{eps_k + eps_{k-1}} E_{k-2}
with alpha(k) = mu(k)^2/t + y, beta(k) = mu(k-1) mu(k) y / t.

Let's check empirically by computing F_k := E_k directly and asking if
  F_k - (mu(k)^2/t + y) t^{eps_k} F_{k-1} + (mu(k-1) mu(k) y / t) t^{eps_k + eps_{k-1}} F_{k-2} = 0.
"""

import sympy as sp
from sympy import Symbol, Matrix, eye, simplify, cancel, expand
from itertools import product
import sys
sys.path.insert(0, '.')
from verify_p5 import sigma_matrix, burau_product, C_poly, mu

t = Symbol('t')
y = Symbol('y')


def A_prime(eps_prefix):
    k = len(eps_prefix)
    return burau_product(eps_prefix, k + 1)


def F(eps_prefix):
    k = len(eps_prefix)
    A = A_prime(eps_prefix)
    return simplify(expand((eye(k) - y * A).det()))


def test_recursion_for(eps_prefix_full):
    K = len(eps_prefix_full)
    # Build F_0, F_1, ..., F_K
    Fs = []
    Fs.append(sp.Integer(1))  # F_0 = det(0x0) = 1
    for k in range(1, K + 1):
        Fs.append(F(eps_prefix_full[:k]))
    # Check the recursion at each k >= 2
    for k in range(2, K + 1):
        eps_k = eps_prefix_full[k - 1]
        eps_km1 = eps_prefix_full[k - 2]
        mu_k = 1 if eps_k == 1 else t
        mu_km1 = 1 if eps_km1 == 1 else t
        alpha = mu_k**2 / t + y
        beta = mu_km1 * mu_k * y / t
        # E_k = alpha * t^{eps_k} E_{k-1} - beta * t^{eps_k + eps_{km1}} E_{k-2}
        predicted = alpha * t**eps_k * Fs[k - 1] - beta * t**(eps_k + eps_km1) * Fs[k - 2]
        diff = simplify(cancel(expand(Fs[k] - predicted)))
        tag = "OK" if diff == 0 else "FAIL"
        if tag == "FAIL":
            print(f"  k={k}, eps_prefix={eps_prefix_full[:k]}: diff = {diff}  [{tag}]")
        else:
            print(f"  k={k}, eps_prefix={eps_prefix_full[:k]}: recursion HOLDS  [{tag}]")


if __name__ == "__main__":
    for eps_full in [
        (1, 1, 1, 1, 1),
        (1, -1, 1, -1, 1),
        (-1, 1, -1, 1, -1),
        (1, 1, -1, -1, 1),
        (-1, -1, -1, -1, -1),
        (1, -1, -1, 1, 1),
    ]:
        print(f"eps_full = {eps_full}:")
        test_recursion_for(eps_full)
        print()
