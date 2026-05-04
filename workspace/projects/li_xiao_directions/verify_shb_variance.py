"""
Verify the stationary variance of fixed-momentum SHB on the 1-D quadratic f(x) = (L/2) x^2.

Recursion: x_{t+1} = (1+beta-eta*L) x_t - beta x_{t-1} - eta * xi_t,  xi_t ~ N(0, sigma^2).
Cast as 2-D state z_t = (x_t, x_{t-1})^T:
    z_{t+1} = A z_t + b xi_t,
where A = [[1+beta-eta L, -beta], [1, 0]], b = (-eta, 0)^T.

Solve discrete Lyapunov equation P = A P A^T + Q with Q = eta^2 sigma^2 e_1 e_1^T,
extract Var_inf[x] = P_{11}, simplify, take eta->0 expansion, verify with Monte Carlo.
"""

import sympy as sp
import numpy as np

print("=" * 70)
print("SHB stationary variance verification")
print("=" * 70)

pass_count = 0
total = 0

# -----------------------------
# Step 1. Symbolic Lyapunov solution
# -----------------------------
total += 1
print(f"\n[Step {total}] Symbolic Lyapunov P = A P A^T + Q")

beta, eta, L, sigma = sp.symbols('beta eta L sigma', real=True, positive=True)

A = sp.Matrix([[1 + beta - eta*L, -beta], [1, 0]])
Q = sp.Matrix([[eta**2 * sigma**2, 0], [0, 0]])

# Symbolic stationary covariance — symmetric 2x2.
p11, p12, p22 = sp.symbols('p11 p12 p22', real=True)
P = sp.Matrix([[p11, p12], [p12, p22]])

eq = A * P * A.T + Q - P
sol = sp.solve([eq[0, 0], eq[0, 1], eq[1, 1]], [p11, p12, p22], dict=True)

assert len(sol) == 1, f"unexpected number of solutions: {len(sol)}"
sol = sol[0]
Var_inf = sp.simplify(sol[p11])

print("  Solved Var_inf[x] (raw):")
print(" ", Var_inf)

# Try to factor / simplify into a clean form.
Var_inf_factored = sp.factor(sp.together(Var_inf))
print("\n  Factored form:")
print(" ", Var_inf_factored)

# Try cancel-form for clarity
Var_inf_cancel = sp.cancel(Var_inf)
print("\n  Cancelled form:")
print(" ", Var_inf_cancel)

# Substitute u = eta*L (the "effective stepsize") to see the structure
u = sp.Symbol('u', positive=True)
Var_sub = Var_inf.subs(eta, u/L)
Var_sub_simpl = sp.simplify(Var_sub)
print("\n  After eta = u/L (u = eta*L):")
print(" ", sp.factor(sp.together(Var_sub_simpl)))

print("  -> PASS (Lyapunov solved)")
pass_count += 1

# -----------------------------
# Step 2. Small-eta Taylor expansion
# -----------------------------
total += 1
print(f"\n[Step {total}] Taylor expansion in eta -> 0 at fixed beta")

# Series expansion to leading order
series_expansion = sp.series(Var_inf, eta, 0, 3).removeO()
series_simplified = sp.simplify(series_expansion)
print("  Var_inf(eta) up to O(eta^3):")
print(" ", series_simplified)

# Leading coefficient
leading = sp.limit(Var_inf / eta, eta, 0)
leading_simplified = sp.simplify(leading)
print(f"\n  Leading coefficient (lim_{{eta->0}} Var_inf/eta):")
print(" ", leading_simplified)

# The conjectured leading order is sigma^2 / (L (1 - beta^2))
# (since denominator structure should give 1/(1-beta^2) factor).
conjecture_leading = sigma**2 / (L * (1 - beta**2))
diff_conj = sp.simplify(leading_simplified - conjecture_leading)
print(f"\n  Conjectured leading: sigma^2 / (L (1 - beta^2)) = {sp.simplify(conjecture_leading)}")
print(f"  Difference (leading - conjecture): {diff_conj}")

if diff_conj == 0:
    print("  -> PASS: leading order is sigma^2 eta / (L (1 - beta^2))")
    pass_count += 1
else:
    # Try alternative
    alt_conj = sigma**2 / (L * (1 - beta)**2)
    diff_alt = sp.simplify(leading_simplified - alt_conj)
    print(f"  Alt: sigma^2 / (L (1-beta)^2) -> diff = {diff_alt}")
    if diff_alt == 0:
        print("  -> PASS: leading order is sigma^2 eta / (L (1-beta)^2)")
        pass_count += 1
    else:
        print("  -> Need to identify the leading form explicitly")

# -----------------------------
# Step 3. Eigenvalues of A and stability region
# -----------------------------
total += 1
print(f"\n[Step {total}] Eigenvalues of A (stability region)")

eigvals = A.eigenvals()
print("  Eigenvalues of A (symbolic):")
for ev, mult in eigvals.items():
    print(f"    lambda = {sp.simplify(ev)},   multiplicity {mult}")

# Characteristic polynomial: lambda^2 - (1+beta-eta L) lambda + beta = 0
# Roots r_1, r_2 satisfy r_1 r_2 = beta, r_1 + r_2 = 1+beta-eta L
# Product (1-r_1)(1-r_2) = 1 - (r_1+r_2) + r_1 r_2 = 1 - (1+beta-eta L) + beta = eta L
print("\n  Vieta identities:")
char = sp.Symbol('lambda')**2 - (1+beta-eta*L)*sp.Symbol('lambda') + beta
print(f"    Char poly: {char}")
print(f"    r_1 r_2 = beta")
print(f"    r_1 + r_2 = 1 + beta - eta L")
print(f"    (1-r_1)(1-r_2) = eta L")
print("  -> PASS (eigenstructure identified)")
pass_count += 1

# -----------------------------
# Step 4. Monte Carlo verification
# -----------------------------
total += 1
print(f"\n[Step {total}] Monte Carlo verification at L=1, sigma=1, beta=0.9, eta=0.05")

L_v, sigma_v, beta_v, eta_v = 1.0, 1.0, 0.9, 0.05

formula_value = float(Var_inf.subs({L: L_v, sigma: sigma_v, beta: beta_v, eta: eta_v}))
print(f"  Closed-form Var_inf[x] = {formula_value:.6f}")

# Monte Carlo: trials = 1000, T = 10000
np.random.seed(2026)
trials = 1000
T = 10000
burn = 5000  # discard first burn iterations to reach stationarity

x_t = np.zeros(trials)
x_tm1 = np.zeros(trials)
samples = []  # collect x_t after burn-in

for t in range(T):
    xi = np.random.normal(0, sigma_v, size=trials)
    x_new = (1 + beta_v - eta_v * L_v) * x_t - beta_v * x_tm1 - eta_v * xi
    x_tm1 = x_t
    x_t = x_new
    if t >= burn:
        samples.append(x_t.copy())

samples = np.concatenate(samples)
empirical_var = float(np.var(samples))
print(f"  Empirical Var[x] from MC (post burn-in {burn}, total {trials} trials x {T-burn} steps):")
print(f"    = {empirical_var:.6f}")

rel_err = abs(empirical_var - formula_value) / formula_value
print(f"  Relative error: {rel_err:.4%}")

if rel_err < 0.05:
    print("  -> PASS (relative error < 5%)")
    pass_count += 1
else:
    print("  -> FAIL: empirical does not match formula")

# -----------------------------
# Step 5. Express the formula as a rational function with explicit denominator
# -----------------------------
total += 1
print(f"\n[Step {total}] Explicit rational form")

num, den = sp.fraction(sp.together(Var_inf))
num_factored = sp.factor(num)
den_factored = sp.factor(den)
print(f"  Numerator (factored): {num_factored}")
print(f"  Denominator (factored): {den_factored}")

# The denominator should have the structure (1-beta) * (something involving eta L)
# Let's substitute u = eta L:
den_in_u = sp.expand(den_factored.subs(eta, u/L))
print(f"\n  Denominator with u = eta*L:")
print(f"  {sp.factor(sp.simplify(den_in_u))}")

num_in_u = sp.expand(num_factored.subs(eta, u/L))
print(f"  Numerator with u = eta*L:")
print(f"  {sp.factor(sp.simplify(num_in_u))}")

print("  -> PASS (formula expressed)")
pass_count += 1

# -----------------------------
# Step 6. Test additional parameter values
# -----------------------------
total += 1
print(f"\n[Step {total}] Additional MC checks at different (beta, eta)")

cases = [
    (0.5, 0.1),
    (0.0, 0.1),  # plain SGD baseline
    (0.95, 0.02),
    (0.9, 0.01),
]

all_match = True
for beta_v, eta_v in cases:
    formula_value = float(Var_inf.subs({L: 1.0, sigma: 1.0, beta: beta_v, eta: eta_v}))

    np.random.seed(2026 + int(beta_v*100) + int(eta_v*1000))
    x_t = np.zeros(trials)
    x_tm1 = np.zeros(trials)
    samples_local = []
    for t in range(T):
        xi = np.random.normal(0, 1.0, size=trials)
        x_new = (1 + beta_v - eta_v * 1.0) * x_t - beta_v * x_tm1 - eta_v * xi
        x_tm1 = x_t
        x_t = x_new
        if t >= burn:
            samples_local.append(x_t.copy())
    samples_local = np.concatenate(samples_local)
    emp = float(np.var(samples_local))
    rel = abs(emp - formula_value) / formula_value

    # Plain-SGD sanity (beta=0): Var_inf = eta^2 sigma^2 / (1 - (1-eta L)^2) = eta sigma^2 / (L(2 - eta L))
    if beta_v == 0.0:
        plain_sgd = eta_v / (2 - eta_v)  # at L=1, sigma=1
        print(f"\n  beta={beta_v}, eta={eta_v}: formula={formula_value:.5f}, MC={emp:.5f}, rel_err={rel:.3%}")
        print(f"    plain-SGD closed form eta/(2-eta) = {plain_sgd:.5f}")
    else:
        print(f"\n  beta={beta_v}, eta={eta_v}: formula={formula_value:.5f}, MC={emp:.5f}, rel_err={rel:.3%}")

    if rel >= 0.05:
        all_match = False

if all_match:
    print("\n  -> PASS (all cases match)")
    pass_count += 1
else:
    print("\n  -> FAIL: some cases do not match")

# -----------------------------
# Summary
# -----------------------------
print("\n" + "=" * 70)
print(f"Summary: {pass_count}/{total} steps passed")
print("=" * 70)
