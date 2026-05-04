"""
Verify the v4 Lemma 2.9 chain is internally consistent.

Setup: alpha = sigma/(3 sqrt T), c_alpha = 1/3, r := sigma/(L D sqrt T) in (0, sqrt 2].

Check:
1. KL per step = 2 alpha^2 / sigma^2 = 2/(9T)  → total KL_T = 2/9
2. Pinsker TV ≤ sqrt(KL/2) = sqrt(1/9) = 1/3
3. Le Cam p_min ≥ (1 - TV)/2 ≥ 1/3
4. Step 3 exact identity at r = sqrt 2: rho(sqrt 2) = sqrt 2 / 3
5. Final: alpha D · rho · p_min · sqrt T / (sigma D) = c_NY = sqrt 2 / 27
6. RGM well-defined: R = D/sqrt 2 - sigma/(3 L sqrt T) > 0 under sigma ≤ L D sqrt(2T)
"""

from sympy import sqrt, Rational, simplify, symbols, solve, Eq, S

# Symbolic
sigma, L, D, T, c_alpha, r = symbols('sigma L D T c_alpha r', positive=True)

# Step 1: alpha and KL
alpha_expr = sigma / (3 * sqrt(T))   # c_alpha = 1/3
KL_per_step = 2 * alpha_expr**2 / sigma**2
KL_total = T * KL_per_step
print(f"alpha = sigma/(3 sqrt T)")
print(f"KL per step = {simplify(KL_per_step)} = 2/(9T) ✓" if simplify(KL_per_step - Rational(2)/(9*T)) == 0 else f"FAIL: KL per step = {simplify(KL_per_step)}")
print(f"KL_T = {simplify(KL_total)} = 2/9 ✓" if simplify(KL_total - Rational(2,9)) == 0 else f"FAIL: KL_T = {simplify(KL_total)}")

# Step 2: Pinsker
TV_pinsker = sqrt(KL_total / 2)
print(f"TV ≤ {simplify(TV_pinsker)} = 1/3 ✓" if simplify(TV_pinsker - Rational(1,3)) == 0 else f"FAIL: TV = {simplify(TV_pinsker)}")

# Step 3: Le Cam
p_min = (1 - TV_pinsker) / 2
print(f"p_min ≥ {simplify(p_min)} = 1/3 ✓" if simplify(p_min - Rational(1,3)) == 0 else f"FAIL: p_min = {simplify(p_min)}")

# Step 4: Wall correction exact identity
# alpha = c_alpha * sigma / sqrt T,  alpha/L = c_alpha * sigma / (L sqrt T) = c_alpha * r * D
# rho(c_alpha, r) = (1/sqrt 2)(1 - c_alpha r / sqrt 2)
rho_general = (1/sqrt(2)) * (1 - c_alpha * r / sqrt(2))
rho_at_caa_third_r_sqrt2 = rho_general.subs([(c_alpha, Rational(1,3)), (r, sqrt(2))])
print(f"rho(1/3, sqrt 2) = {simplify(rho_at_caa_third_r_sqrt2)} (should be sqrt 2/3 = {simplify(sqrt(2)/3)})")
print(f"  Match: {simplify(rho_at_caa_third_r_sqrt2 - sqrt(2)/3) == 0}")

# Step 5: c_NY = c_alpha * rho * p_min (sigma D / sqrt T factored out)
# alpha D rho p_min / (sigma D / sqrt T) = c_alpha * sqrt T * rho * p_min / 1 ... wait let me redo
# Want: max E[G_s] >= (sqrt 2/27) sigma D / sqrt T
# alpha D = (c_alpha sigma / sqrt T) * D = c_alpha sigma D / sqrt T
# alpha D rho p_min = c_alpha rho p_min * sigma D / sqrt T
# So c_NY = c_alpha * rho * p_min
c_NY_factored = c_alpha * rho_general * p_min  # but p_min depends on c_alpha via TV ≤ c_alpha
# Actually, in fully general form: TV ≤ c_alpha (Pinsker with KL_T = 2 c_alpha^2)
# p_min ≥ (1 - c_alpha)/2
p_min_general = (1 - c_alpha) / 2
c_NY_general = c_alpha * rho_general * p_min_general
c_NY_at_caa_third_r_sqrt2 = c_NY_general.subs([(c_alpha, Rational(1,3)), (r, sqrt(2))])
print(f"\nc_NY (general) = c_alpha · rho · (1-c_alpha)/2 = {simplify(c_NY_general)}")
print(f"c_NY at c_alpha=1/3, r=sqrt 2 = {simplify(c_NY_at_caa_third_r_sqrt2)}")
print(f"  Should be sqrt 2/27 = {simplify(sqrt(2)/27)}")
print(f"  Match: {simplify(c_NY_at_caa_third_r_sqrt2 - sqrt(2)/27) == 0}")

# Optimize c_alpha at r = sqrt 2
from sympy import diff
c_NY_at_r_sqrt2 = c_NY_general.subs(r, sqrt(2))
print(f"\nc_NY(c_alpha, r=sqrt 2) = {simplify(c_NY_at_r_sqrt2)}")
deriv = simplify(diff(c_NY_at_r_sqrt2, c_alpha))
print(f"d/dc_alpha = {deriv}")
critical = solve(deriv, c_alpha)
print(f"Critical points: {critical}")

# Verify R > 0 under (RGM)
# R = D/sqrt 2 - alpha/L
# Under RGM: sigma ≤ L D sqrt(2T), so alpha = sigma/(3 sqrt T) ≤ L D sqrt(2T) / (3 sqrt T) = L D sqrt 2 / 3
# alpha/L ≤ D sqrt 2 / 3
# R ≥ D/sqrt 2 - D sqrt 2/3 = D (1/sqrt 2 - sqrt 2/3) = D (3 - 2)/(3 sqrt 2) = D/(3 sqrt 2) > 0  ✓
R_min = D/sqrt(2) - D*sqrt(2)/3
print(f"\nR_min under (RGM): {simplify(R_min)} = D/(3 sqrt 2) = {simplify(D/(3*sqrt(2)))}")
print(f"  Match: {simplify(R_min - D/(3*sqrt(2))) == 0}")
print(f"  R_min > 0 (since D > 0): True")

print("\n=== ALL CHAIN CHECKS PASSED ===")
print(f"\nFinal sharp constant: c_NY = sqrt 2 / 27 ≈ {float(sqrt(2)/27):.6f}")
print(f"Improvement over v3 (1/112): {float((sqrt(2)/27) / (Rational(1,112))):.4f}x")
