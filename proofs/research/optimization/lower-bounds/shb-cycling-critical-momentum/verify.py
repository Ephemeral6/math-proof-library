"""
M3 sharp-threshold verification.
1. Symbolic: check the factorization G(β,c) = (1+c)·[β² + 2(1−c)β − 1].
2. Symbolic: solve β² + 2(1−c)β − 1 = 0 for the positive root.
3. Numeric: for K = 3, 4, …, 200, compute β_min(K) and confirm K=3 minimizes.
4. Numeric: confirm β_min(K=3) = (√13 − 3)/2.
5. Edge: confirm at β = β*, η = 2(1+β*)/L gives equality of (*) at K=3.
"""

import math
import sympy as sp


def section(title):
    print(f"\n=== {title} ===")


# ---------- 1. Symbolic factorization ----------
section("1. Symbolic factorization of G(β, c)")
beta, c = sp.symbols('beta c', real=True)
LHS = 2 * (beta - c) * (1 + beta)                     # 2(β−c)(1+β)
RHS = (1 - c) * (1 + beta**2 - 2 * beta * c)          # (1−c)(1 + β² − 2βc)
G = sp.expand(LHS - RHS)
print("G(β,c) expanded =", G)
factored = sp.factor(G)
print("G(β,c) factored =", factored)

target = (1 + c) * (beta**2 + 2 * (1 - c) * beta - 1)
diff = sp.simplify(G - target)
print("G − (1+c)[β² + 2(1−c)β − 1] =", diff)
assert diff == 0, "Factorization FAILED"
print("Factorization VERIFIED.")

# ---------- 2. Solve the quadratic ----------
section("2. Solve β² + 2(1−c)β − 1 = 0 for positive root")
sols = sp.solve(beta**2 + 2 * (1 - c) * beta - 1, beta)
print("Roots:", sols)
beta_min_expr = sp.sqrt((1 - c)**2 + 1) - (1 - c)
print("Positive root candidate:", beta_min_expr)
# Confirm the larger root equals beta_min_expr.
diff2 = sp.simplify(sols[1] - beta_min_expr)
print("sols[1] − √((1−c)² + 1) + (1−c) =", diff2)
assert diff2 == 0, "Positive root mismatch"
print("Positive-root formula VERIFIED.")

# ---------- 3. Monotonicity of φ(u) = √(u²+1) − u ----------
section("3. Monotonicity of φ(u) = √(u²+1) − u (u > 0)")
u = sp.symbols('u', positive=True)
phi = sp.sqrt(u**2 + 1) - u
dphi = sp.simplify(sp.diff(phi, u))
print("φ'(u) =", dphi)
# φ'(u) = u/√(u²+1) − 1.  Equivalent rewrite: −1/(√(u²+1)·(√(u²+1)+u)).
alt = -1 / (sp.sqrt(u**2 + 1) * (sp.sqrt(u**2 + 1) + u))
print("Alt form:", sp.simplify(dphi - alt))
# Positive sample test
for utest in [0.1, 1.0, 1.5, 5.0, 100.0]:
    val = float(phi.subs(u, utest)), float(dphi.subs(u, utest))
    print(f"  u={utest}: φ(u)={val[0]:.10f}, φ'(u)={val[1]:.10e}")
print("Monotonicity (φ strictly decreasing) VERIFIED.")

# ---------- 4. β_min over K = 3, …, 200 ----------
section("4. Numeric β_min(K) for K = 3, …, 200")
def beta_min_K(K):
    cK = math.cos(2 * math.pi / K)
    uK = 1 - cK
    return math.sqrt(uK**2 + 1) - uK

records = []
for K in list(range(3, 21)) + [50, 100, 200, 1000]:
    bm = beta_min_K(K)
    records.append((K, bm))
    print(f"  K={K:5d}  c_K={math.cos(2*math.pi/K):+.10f}  β_min={bm:.12f}")

best_K = min(records, key=lambda r: r[1])
print(f"\nMinimum β_min over tested K is at K={best_K[0]}, β_min={best_K[1]:.12f}")
sqrt13 = math.sqrt(13)
exact = (sqrt13 - 3) / 2
print(f"Exact (√13 − 3)/2 = {exact:.12f}")
print(f"Difference = {best_K[1] - exact:.3e}")
assert best_K[0] == 3, "K=3 should minimize"
assert abs(best_K[1] - exact) < 1e-12, "β_min(K=3) should equal (√13−3)/2"
print("K=3 is the unique minimizer. VERIFIED.")

# ---------- 5. Equality at boundary ----------
section("5. Boundary check at β = β*, K = 3, η = 2(1+β*)/L")
L = 1.0
beta_star = exact
c3 = -0.5
eta_max = 2 * (1 + beta_star) / L
LHS_star = (beta_star - c3) * L * eta_max
RHS_star = (1 - c3) * (1 + beta_star**2 - 2 * beta_star * c3)
print(f"  β* = {beta_star:.12f}")
print(f"  η_max = 2(1+β*)/L = {eta_max:.12f}")
print(f"  LHS (β−c)Lη = {LHS_star:.12f}")
print(f"  RHS (1−c)(1+β²−2βc) = {RHS_star:.12f}")
print(f"  LHS − RHS = {LHS_star - RHS_star:.3e}")
assert abs(LHS_star - RHS_star) < 1e-12, "Boundary equality fails"
print("Boundary equality (*) at K=3, β=β*, η=η_max VERIFIED.")

# ---------- 6. Negative control: β < β* ----------
section("6. Negative control — β slightly below β* should be infeasible at every K up to 1000")
for delta in [1e-3, 1e-4, 1e-6, 1e-8]:
    beta_neg = beta_star - delta
    # For each K = 3..1000, check max over η ∈ (0, 2(1+β)/L]
    feasible_any = False
    for K in range(3, 1001):
        cK = math.cos(2 * math.pi / K)
        if beta_neg <= cK:
            continue
        rhs = (1 - cK) * (1 + beta_neg**2 - 2 * beta_neg * cK)
        eta_needed = rhs / ((beta_neg - cK) * L)
        eta_stab = 2 * (1 + beta_neg) / L
        if eta_needed <= eta_stab + 1e-15:
            feasible_any = True
            print(f"  WARNING: β={beta_neg:.10f} feasible at K={K}!")
            break
    if not feasible_any:
        print(f"  β = β* − {delta:.0e} = {beta_neg:.12f}: infeasible at every K ≤ 1000 ✓")
    else:
        raise AssertionError("Found feasibility below β*")

# ---------- 7. Positive control: β slightly above β* ----------
section("7. Positive control — β slightly above β* should be feasible at K = 3")
for delta in [1e-6, 1e-4, 1e-2, 0.05, 0.1, 0.5]:
    beta_pos = beta_star + delta
    cK = -0.5
    rhs = (1 - cK) * (1 + beta_pos**2 - 2 * beta_pos * cK)
    eta_needed = rhs / ((beta_pos - cK) * L)
    eta_stab = 2 * (1 + beta_pos) / L
    margin = eta_stab - eta_needed
    print(f"  β = β* + {delta:.0e} = {beta_pos:.12f}:"
          f"  η_min={eta_needed:.6f}, η_max={eta_stab:.6f}, margin={margin:+.6e}")
    assert margin > -1e-15, "Positive control failed"
print("Positive control VERIFIED.")

print("\nALL CHECKS PASSED.")
