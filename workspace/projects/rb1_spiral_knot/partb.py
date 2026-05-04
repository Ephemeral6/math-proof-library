"""
Part (b): For S(p, 2, eps) with q=2, derive closed-form Alexander polynomial.

S(p, 2, eps) = closure of beta = (sigma_1^{eps_1} sigma_2^{eps_2} ... sigma_{p-1}^{eps_{p-1}})^2
on p strands.

The Seifert matrix is (p-1)(q-1) x (p-1)(q-1) = (p-1) x (p-1) tridiagonal.

Let me first derive the Seifert matrix for S(p, 2, eps).

Braid: sigma_1^{e_1} sigma_2^{e_2} ... sigma_{p-1}^{e_{p-1}} sigma_1^{e_1} sigma_2^{e_2} ... sigma_{p-1}^{e_{p-1}}
on p strands (e_i = eps_i for short).

There are 2(p-1) crossings, p strands. Bands:
  Row 1: bands b_1, b_2, ..., b_{p-1} (one per generator)
  Row 2: bands b_p, b_{p+1}, ..., b_{2(p-1)}

For each generator j ∈ {1, ..., p-1}, there are exactly 2 bands of that type:
  - In row 1: b_j (with sign e_j)
  - In row 2: b_{p-1+j} (with sign e_j)

Cycle basis: gamma_j = b_{p-1+j} - b_j for j = 1, ..., p-1.
This gives p-1 cycles, matching size (p-1) of Seifert matrix.

Now compute V_{ij} = lk(gamma_i^+, gamma_j) for i, j ∈ {1, ..., p-1}.

GEOMETRIC SETUP:
Place braid horizontally with strands going top-to-bottom. Each band has a small twist
(half-twist of sign e_j) at the crossing. Cycle gamma_j goes:
  - From band b_j up through the surface to b_{p-1+j}, around through D_j and D_{j+1},
    and back.

For computing lk(gamma_i^+, gamma_j):
  - gamma_i^+ = push-off in +z (above) the surface.
  - The linking number lk(gamma_i^+, gamma_j) is given by counting signed crossings in a
    standard projection.

For a TORUS KNOT T(p, 2) (all e_j = +1), the Seifert matrix in this basis is known to be:
  V_{T(p,2)} = -tridiag(p-1) where tridiag has -1 on diagonal and +1 on superdiagonal,
  giving Alexander polynomial Δ(t) = (t^p + (-1)^{p-1}) / (t + 1) for T(2, p) or similar.

Wait, T(2, p) and T(p, 2) are equivalent knots. For p odd, T(2,p) is a knot; for p even,
it's a 2-component link.

T(p, 2) Alexander = T(2, p) Alexander = (t^p + 1)/(t+1) for p odd... no wait, that's not
quite right. Let me recompute.

Δ_{T(2,n)}(t) = (1-t^{2n})(1-t)/((1-t^2)(1-t^n)) = (1+t^n)(1-t)/(1-t^2) ... hmm complicated.

For T(2, n) with n odd: Δ = 1 - t + t^2 - t^3 + ... + t^{n-1} (alternating sum).
For n=3: 1 - t + t^2 ✓ (trefoil).

OK so for T(p, 2) (which equals T(2, p)) we have Δ = sum_{k=0}^{p-1} (-t)^k = (1 - (-t)^p)/(1-(-t)) = (1 + (-t)^p)/(1+t).

For S(p, 2, eps), with mixed signs, the Seifert matrix should be tridiagonal with diagonal
entries depending on eps_j (sign of band j) and off-diagonal entries depending on adjacent eps.

Let's compute Seifert matrix explicitly for small cases.

For p=2 (i.e., S(2, 2, (eps_1))):
  beta = (sigma_1^{eps_1})^2 = sigma_1^{2 eps_1}.
  Closure = T(2, 2 eps_1) (Hopf link if eps_1 = +1, mirror Hopf if -1).
  Seifert matrix: 1x1 = [-eps_1].
  Alexander: det([-eps_1] - t[-eps_1]) = -eps_1(1-t) = eps_1(t-1).
  Up to units: Δ(t) = t - 1, OR for the link, often Δ_{Hopf}(t) = (t-1) (or t-1 times unit).

For p=3, q=2:
  beta = (sigma_1^{e_1} sigma_2^{e_2})^2 on 3 strands.
  4 crossings, 3 strands. Permutation = ((1 2)(2 3))^2 = (1 3 2)(no wait), let me recompute.
  As permutation: sigma_1 = (12), sigma_2 = (23). sigma_1*sigma_2 = (12)(23) = (1 2 3) cycle.
  Squared: (1 3 2) -- still a 3-cycle. So 1 component, KNOT.

For (e_1, e_2) = (+1, +1) (= T(3, 2) = trefoil): Δ = t^2 - t + 1. ✓
For (e_1, e_2) = (+1, -1): Δ = ?

Let me compute via Burau.
"""

import sympy as sp
import numpy as np

t = sp.symbols('t')

# Burau in B_3:
B1 = sp.Matrix([[-t, 1], [0, 1]])
B2 = sp.Matrix([[1, 0], [t, -t]])

# Test all S(3, 2, eps):
for e1, e2 in [(1, 1), (1, -1), (-1, 1), (-1, -1)]:
    M1 = B1 if e1 == 1 else B1.inv()
    M2 = B2 if e2 == 1 else B2.inv()
    beta = (M1 * M2)**2
    det_b = sp.simplify((sp.eye(2) - beta).det())
    delta = sp.simplify(det_b / (1 + t + t**2))
    print(f"S(3, 2, ({e1:+d}, {e2:+d})): Δ(t) =", sp.factor(delta))

print()

# Now S(4, 2, eps): braid (sigma_1^{e_1} sigma_2^{e_2} sigma_3^{e_3})^2 on 4 strands.
# Reduced Burau in B_4:
# rho_4(sigma_i) is 3x3 matrix
def burau_B4_sigma_i(i, e):
    """Reduced Burau matrix of sigma_i^e in B_4."""
    M = sp.eye(3)
    if e == 1:
        if i == 1:
            M = sp.Matrix([
                [-t, 1, 0],
                [0, 1, 0],
                [0, 0, 1]
            ])
        elif i == 2:
            M = sp.Matrix([
                [1, 0, 0],
                [t, -t, 1],
                [0, 0, 1]
            ])
        elif i == 3:
            M = sp.Matrix([
                [1, 0, 0],
                [0, 1, 0],
                [0, t, -t]
            ])
    elif e == -1:
        # Inverses
        if i == 1:
            M = sp.Matrix([
                [-sp.Rational(1)/t, sp.Rational(1)/t, 0],
                [0, 1, 0],
                [0, 0, 1]
            ])
        elif i == 2:
            M = sp.Matrix([
                [1, 0, 0],
                [1, -sp.Rational(1)/t, sp.Rational(1)/t],
                [0, 0, 1]
            ])
        elif i == 3:
            M = sp.Matrix([
                [1, 0, 0],
                [0, 1, 0],
                [0, 1, -sp.Rational(1)/t]
            ])
    return M

# Verify by checking sigma_i * sigma_i^{-1} = I
print("Verify Burau B_4 inverses:")
for i in [1,2,3]:
    A = burau_B4_sigma_i(i, 1) * burau_B4_sigma_i(i, -1)
    A_simplified = sp.simplify(A)
    print(f"sigma_{i} * sigma_{i}^(-1) = ")
    sp.pprint(A_simplified)

print()
# Now compute S(4, 2, eps)
print("S(4, 2, eps):")
for e1, e2, e3 in [(1,1,1), (1,1,-1), (1,-1,1), (1,-1,-1), (-1,1,1), (-1,1,-1), (-1,-1,1), (-1,-1,-1)]:
    beta_word = (burau_B4_sigma_i(1, e1) * burau_B4_sigma_i(2, e2) * burau_B4_sigma_i(3, e3))**2
    det_b = sp.simplify((sp.eye(3) - beta_word).det())
    delta = sp.simplify(det_b / (1 + t + t**2 + t**3))
    print(f"  eps=({e1:+d},{e2:+d},{e3:+d}): Δ =", sp.factor(delta))
