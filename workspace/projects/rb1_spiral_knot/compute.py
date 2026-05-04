import sympy as sp

t = sp.symbols('t')

# Sanity check: Burau for T(3,3)
B1 = sp.Matrix([[-t, 1], [0, 1]])
B2 = sp.Matrix([[1, 0], [t, -t]])

beta_T33 = (B1 * B2)**3
det_T33 = (sp.eye(2) - beta_T33).det()
print("det(I - rho_3(T33)) =", sp.factor(sp.simplify(det_T33)))

delta_T33 = (1 - t**9) * (1 - t)**2 / ((1 - t**3)**2)
print("Formula Delta_{T(3,3)} =", sp.factor(sp.simplify(delta_T33)))

# Compute from Burau
delta_burau = sp.simplify(det_T33 / (1 + t + t**2))
print("Burau-derived Delta_{T(3,3)} =", sp.factor(delta_burau))

# Now S(3,3,(+,-)):
B1_inv = B1.inv()
B2_inv = B2.inv()
beta_spiral = (B1 * B2_inv)**3
det_spiral = (sp.eye(2) - beta_spiral).det()
print("\ndet(I - rho_3(S(3,3,(+,-)))) =", sp.factor(sp.simplify(det_spiral)))

delta_spiral = sp.simplify(det_spiral / (1 + t + t**2))
print("Delta_{S(3,3,(+,-))} =", sp.factor(delta_spiral))
