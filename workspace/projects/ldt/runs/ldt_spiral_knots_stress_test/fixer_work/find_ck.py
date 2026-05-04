"""
Characterize c_k precisely: c_k = column k+1 (1-indexed) of A_k (truncated to top k entries).
Conjecture based on initial data: c_k depends only on eps_{1..k-1} (not on eps_k).
Let's verify and find a formula.
"""

import sympy as sp
from sympy import Matrix, eye, Symbol, simplify
from itertools import product
import sys
sys.path.insert(0, '.')
from verify_p5 import sigma_matrix, burau_product, mu

t = Symbol('t')


def partial_burau_in_p(eps_partial, k, p):
    n = p - 1
    M = eye(n)
    for i in range(1, k + 1):
        M = M * sigma_matrix(i, p, eps_partial[i - 1])
    return M


# Extract c_k for various eps, at fixed p large
def get_ck(eps_full, k, p):
    """Return column k+1 (1-indexed, 0-indexed k) of A_k, truncated to top k entries."""
    A = partial_burau_in_p(eps_full, k, p)
    return A[:k, k]


# Test: does c_k depend on eps_k?
print("=== Does c_k depend on eps_k? ===")
# Fix eps_{1..k-1}, vary eps_k
for prefix in [(1,), (-1,), (1, 1), (1, -1), (-1, 1), (-1, -1), (1, 1, 1), (1, -1, 1)]:
    k = len(prefix) + 1  # we're looking at c_k with eps_{1..k-1} = prefix, and eps_k varies
    if k >= 5:
        continue
    p = k + 3
    results = []
    for s in [1, -1]:
        eps_full = prefix + (s,) + (1,) * (p - 1 - k)  # pad with +1 for the rest
        ck = get_ck(eps_full, k, p)
        results.append((s, list(ck)))
    # Compare
    prefix_str = str(prefix)
    print(f"  prefix {prefix_str}, k={k}:")
    for s, v in results:
        print(f"    eps_k = {s:+d}: c_k = {v}")
    # If they match, c_k doesn't depend on eps_k
    if simplify(sp.Matrix(results[0][1]) - sp.Matrix(results[1][1])).norm() == 0:
        print(f"    -> c_k does NOT depend on eps_k  [confirmed]")
    else:
        print(f"    -> c_k DOES depend on eps_k")
    print()


# Now determine the formula for c_k in terms of eps_{1..k-1}
print("=== Collecting c_k for various prefixes eps_{1..k-1} ===")
# For each possible prefix of length k-1, get c_k
for k in range(1, 5):
    print(f"k = {k}:")
    for pref in product([1, -1], repeat=k - 1):
        eps_full = pref + (1,) + (1,) * (10 - k)  # pad to safely have p
        p = k + 3
        eps_full = pref + (1,) + (1,) * (p - 1 - k)
        ck = get_ck(eps_full, k, p)
        # Simplify entries
        entries = [simplify(e) for e in ck]
        # Hypothesis: c_k = (f_1, f_2, ..., f_k) where f_i depends on eps_{i..k-1}
        # Specifically: f_i = prod over j=i..k-1 of (some factor depending on eps_j)
        # Let's see: at each transition from eps_j = +1 to -1 we pick up a 1/t
        # Looking at data: eps prefix (-1,+1) gives c_2 = (1/t, 1); eps (+1,-1) gives (1/t, 1/t); eps (+1) gives (1).
        # So f_i = prod_{j=i}^{k-1} t^{(eps_j - 1)/2}? Let's check: eps_j=+1: factor 1; eps_j=-1: factor 1/t.
        # prefix (-1,+1): f_1 = (eps_1=-1 factor)(eps_2=+1 factor) = (1/t)(1) = 1/t. f_2 = eps_2 factor = 1. Matches!
        # prefix (+1,-1): f_1 = 1 * 1/t = 1/t. f_2 = 1/t. Matches!
        # prefix (-1,-1): f_1 = 1/t * 1/t = 1/t^2. f_2 = 1/t. Let's check.
        pred = []
        for i in range(1, k + 1):
            f = sp.Integer(1)
            for j in range(i, k):
                if pref[j - 1] == -1:
                    f = f / t
            pred.append(f)
        match = all(simplify(entries[i] - pred[i]) == 0 for i in range(k))
        tag = "MATCH" if match else "MISMATCH"
        print(f"  prefix {pref}: c_k = {entries}   predicted = {pred}   [{tag}]")
