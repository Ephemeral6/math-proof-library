"""
Verified Seifert matrix for S(p, 2, eps):

V_{jj} = -e_j   (diagonal: self-linking from twist sign)
V_{j, j+1} = +1 (superdiagonal: adjacent bands always link by +1, regardless of signs)
V_{j+1, j} = 0  (subdiagonal: zero in Seifert convention)

Verify for all small cases that this matches Burau.
"""
import sympy as sp

t = sp.symbols('t')

def seifert_S_p_2(eps):
    """eps = list of ±1 of length p-1. Returns Seifert matrix."""
    n = len(eps)  # n = p-1
    M = sp.zeros(n, n)
    for j in range(n):
        M[j, j] = -eps[j]
        if j + 1 < n:
            M[j, j+1] = 1
    return M

def alex(M):
    A = M - t * M.T
    return sp.factor(sp.expand(A.det()))

# Verify against Burau values
print("p=2:")
for e1 in [1, -1]:
    M = seifert_S_p_2([e1])
    print(f"  S(2,2,({e1:+d})): Δ = {alex(M)}")

print("\np=3:")
for e1 in [1, -1]:
    for e2 in [1, -1]:
        M = seifert_S_p_2([e1, e2])
        print(f"  S(3,2,({e1:+d},{e2:+d})): Δ = {alex(M)}")

print("\np=4:")
for e1 in [1, -1]:
    for e2 in [1, -1]:
        for e3 in [1, -1]:
            M = seifert_S_p_2([e1, e2, e3])
            print(f"  S(4,2,({e1:+d},{e2:+d},{e3:+d})): Δ = {alex(M)}")

# Now derive closed form via Chebyshev-like recursion.
# Seifert matrix is upper bidiagonal with V_{jj} = -e_j, V_{j, j+1} = 1.
# det(M - tM^T) where M is upper bidiagonal:
# M - tM^T:
#   diagonal: -e_j - t*(-e_j) = -e_j(1-t) = e_j(t-1)
#   superdiagonal (j, j+1): 1 (from M)
#   subdiagonal (j+1, j): -t (from -tM^T which puts -t on subdiagonal)
# Other entries: 0.

# So A = M - tM^T is tridiagonal with:
#   A_{jj} = e_j(t-1)
#   A_{j, j+1} = 1
#   A_{j+1, j} = -t

# det of such tridiagonal matrix follows Chebyshev-like recursion:
# Let D_n = det of n x n version. Expanding along last row:
# D_n = A_{nn} * D_{n-1} - A_{n-1, n} * A_{n, n-1} * D_{n-2}
#     = e_n(t-1) * D_{n-1} - (1)(-t) * D_{n-2}
#     = e_n(t-1) * D_{n-1} + t * D_{n-2}

# With D_0 = 1, D_1 = e_1(t-1).

# Let's verify this recursion produces the right answers:
def chebyshev_alex(eps):
    """Compute Alexander polynomial via recursion."""
    p_minus_1 = len(eps)
    if p_minus_1 == 0:
        return sp.Integer(1)
    D = [sp.Integer(1), eps[0] * (t - 1)]
    for j in range(2, p_minus_1 + 1):
        # D_j = eps[j-1] * (t-1) * D_{j-1} + t * D_{j-2}
        D.append(sp.expand(eps[j-1] * (t-1) * D[j-1] + t * D[j-2]))
    return sp.factor(D[p_minus_1])

print("\n=== Chebyshev recursion verification ===")
for eps in [[1], [-1], [1,1], [1,-1], [-1,1], [-1,-1]]:
    M = seifert_S_p_2(eps)
    direct = alex(M)
    via_rec = chebyshev_alex(eps)
    match = sp.simplify(direct - via_rec) == 0
    print(f"  eps={eps}: direct={direct}, recursion={via_rec}, match={match}")

# Now, for ALL eps_j = +1 (T(p, 2) = T(2, p)):
# D_0 = 1, D_1 = t-1, D_n = (t-1) D_{n-1} + t D_{n-2}.
# This is a known recursion. Let's solve.

# Substituting D_n = (-1)^n p_n(-t) for some Chebyshev-like polynomial...
# Or directly: this is the recursion for T(2, p) Alexander.
# We know Δ_{T(2,p)}(t) = (t^p + (-1)^{p-1}) / (t + 1)...
# Hmm let me just check the pattern:
# D_0 = 1
# D_1 = t-1
# D_2 = (t-1)(t-1) + t*1 = t^2 - 2t + 1 + t = t^2 - t + 1 ✓ (trefoil)
# D_3 = (t-1)(t^2-t+1) + t(t-1) = t^3 - t^2 + t - t^2 + t - 1 + t^2 - t = t^3 - t^2 + t - 1 = (t-1)(t^2+1) ✓
# D_4 = (t-1)(t^3-t^2+t-1) + t(t^2-t+1) = ... = t^4 - t^3 + t^2 - t + 1 ✓

# Great. So for ε all +1, we recover T(2, p) Alexander.
# Closed form: D_n = (D_n where D_n satisfies the recursion).
# This is exactly a deformed Chebyshev.

# Closed form approach:
# The recursion D_n = a_n * D_{n-1} + t * D_{n-2} with a_n = eps_n * (t-1) is exactly the
# determinant of a tridiagonal matrix:
#       | a_1   1      0    0  ... |
#       | -t   a_2    1     0  ... |
#       | 0    -t    a_3    1 ... |
#       | ...                       |
#       | ...                a_n  |
#
# So Δ_{S(p,2,eps)}(t) = D_{p-1}(t; eps) where
#   D_0 = 1, D_1 = eps_1(t-1), D_j = eps_j(t-1) D_{j-1} + t D_{j-2}.

# This IS the closed form (Chebyshev-type recursion).

# Special cases:
# (1) All eps_j = +1: D_p satisfies D_n = (t-1) D_{n-1} + t D_{n-2}.
#     Closed form: D_n = (t^{n+1} - (-1)^{n+1}) / (t+1)
#                      = sum_{k=0}^n (-1)^k t^{n-k} ... let me verify
#     For n=1: D_1 = t - 1. (t^2 - 1)/(t+1) = t - 1 ✓
#     For n=2: D_2 = t^2 - t + 1. (t^3 + 1)/(t+1) = t^2 - t + 1 ✓
#     For n=3: D_3 = t^3 - t^2 + t - 1. (t^4 - 1)/(t+1) = t^3 - t^2 + t - 1 ✓
#     So D_n = (t^{n+1} - (-1)^{n+1}) / (t + 1) = sum_{k=0}^n (-t)^k * sign...
#     Actually D_n = sum_{k=0}^n (-1)^{n-k} t^k = sum_{k=0}^n (-1)^{n-k} t^k.
#     Equivalently D_n(t) = sum_{k=0}^n (-1)^k t^{n-k}.
#     For p-1 = n, S(p,2,(+,+,...,+)) = T(p,2) has Δ = D_{p-1}(t) = sum_{k=0}^{p-1} (-1)^k t^{p-1-k}.

# (2) For mixed eps, no simple closed form but the recursion is the closed form.

print("\n=== Closed-form Alexander for S(p, 2, eps) ===")
print("Recursive formula:")
print("  D_0(t) = 1")
print("  D_1(t) = eps_1 * (t-1)")
print("  D_j(t) = eps_j * (t-1) * D_{j-1}(t) + t * D_{j-2}(t)  for j >= 2")
print()
print("Then Δ_{S(p, 2, eps)}(t) = D_{p-1}(t)")
print()
print("Equivalently, Δ = det of (p-1)x(p-1) tridiagonal matrix T(eps) where:")
print("  T_{jj} = eps_j (t-1)")
print("  T_{j, j+1} = 1")
print("  T_{j+1, j} = -t")
print()

# Show the Seifert matrix structure once more:
print("Seifert matrix M = (p-1) x (p-1) upper bidiagonal:")
print("  M_{jj} = -eps_j")
print("  M_{j, j+1} = +1")
print("  Other entries = 0")
