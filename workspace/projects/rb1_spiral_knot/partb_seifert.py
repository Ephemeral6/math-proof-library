"""
Direct Seifert matrix construction for S(p, 2, eps).

Braid: beta = (sigma_1^{e_1} sigma_2^{e_2} ... sigma_{p-1}^{e_{p-1}})^2 on p strands.

Bands (in order top to bottom, k=1,...,2(p-1)):
  Row 1: b_k for k=1,...,p-1 with k corresponding to generator i_k = k, sign e_k.
  Row 2: b_k for k=p,...,2(p-1) with i_k = k - (p-1), sign e_{k-(p-1)}.

Cycle gamma_j (j = 1, ..., p-1): goes through bands at row 1 position j and row 2 position j
of the same generator type. So gamma_j uses b_j (row 1, gen j, sign e_j) and b_{p-1+j} (row 2,
gen j, sign e_j), forming a closed loop.

Compute Seifert matrix V_{ij} = lk(gamma_i^+, gamma_j).

For T(p, 2) = S(p, 2, (+,+,...,+)): the Seifert matrix is well-known. By analogy with T(2,n)
case: tridiagonal with diagonal -1, superdiagonal +1, subdiagonal 0:
  V_{T(p,2)} = upper bidiagonal: V_{ii} = -1, V_{i,i+1} = +1, else 0

Wait, but T(p, 2) and T(2, p) have the same Alexander polynomial since they're isotopic knots
(or links). So the Seifert matrix should give the same Alexander.

For T(2, n): V = upper bidiagonal with diagonal -1 superdiagonal +1, gives
Δ_{T(2,n)}(t) = det(M - tM^T) for the (n-1)x(n-1) matrix.
For n=3: M = [[-1,1],[0,-1]], Δ = t^2 - t + 1 ✓.
For n=4: M = [[-1,1,0],[0,-1,1],[0,0,-1]],
  M - tM^T = [[-1+t, 1, 0],[-t, -1+t, 1],[0, -t, -1+t]]
  det = (t-1)^3 + (t-1) - (-t)*(-(t-1)) - ... let me compute
"""

import sympy as sp

t = sp.symbols('t')

def trefoil_like(n):
    """T(2,n) Seifert matrix: (n-1)x(n-1) upper bidiagonal."""
    M = sp.zeros(n-1, n-1)
    for i in range(n-1):
        M[i, i] = -1
        if i+1 < n-1:
            M[i, i+1] = 1
    return M

# Verify for T(2,n):
for n in [2, 3, 4, 5, 6]:
    M = trefoil_like(n)
    A = M - t*M.T
    delta = sp.factor(A.det())
    print(f"T(2,{n}): Δ =", delta)

print()
# Now compare with our S(p, 2, (+,+,...,+)) values from Burau:
# S(3, 2, (+,+)) = T(3, 2) = T(2, 3): Δ = t^2 - t + 1 ✓
# S(4, 2, (+,+,+)) = T(4, 2) = T(2, 4): Δ should be (t^4+1)/(t+1)... hmm but T(2,4) is a 2-component link
#   T(2,4) Δ = -(t-1)(t^2+1) (matching our Burau result -(t-1)(t^2+1)) ✓

# So for SPIRAL knot S(p, 2, eps), generalize the tridiagonal Seifert matrix:
# Each band has a sign e_j.
# Diagonal entry V_{jj} = -e_j (self-linking from the twist).
# Off-diagonal V_{j,j+1}: depends on adjacent bands.

# CONJECTURE: The Seifert matrix of S(p, 2, eps) is upper bidiagonal:
#   V_{jj} = -e_j
#   V_{j, j+1} = +1 if e_j and e_{j+1} same sign (both + or both -)?
#              = ?  if opposite signs
#   V_{j+1, j} = 0 (or maybe nonzero for opposite signs)
#
# Let me TEST this conjecture by trying various forms and comparing to Burau-derived Alexander.

def alexander_poly(M):
    A = M - t*M.T
    return sp.factor(sp.expand(A.det()))

# Test for S(3, 2, (+, -)): expected Δ = -(t^2 - 3t + 1)/t^2 (from Burau)
# Up to units, Δ = t^2 - 3t + 1 (or its negative).

# Try various 2x2 candidates:
for V12 in [-1, 0, 1]:
    for V21 in [-1, 0, 1]:
        M = sp.Matrix([[-1, V12], [V21, +1]])  # diagonal e_1=+1, e_2=-1 → V_11=-1, V_22=+1
        d = alexander_poly(M)
        print(f"S(3,2,(+,-)) candidate V_12={V12}, V_21={V21}: M={M.tolist()}, Δ = {d}")
