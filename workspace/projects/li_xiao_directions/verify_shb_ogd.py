import sympy as sp

print("=" * 50)
print("SHB-to-OGD Change of Variables Verification")
print("=" * 50)
pass_count = 0
total = 0

# Symbols
x_tm1, x_t, g_t, eta, beta = sp.symbols('x_tm1 x_t g_t eta beta', real=True)

# SHB recursion
x_tp1 = x_t - eta*g_t + beta*(x_t - x_tm1)

# Change of variables: a = beta/(1-beta)
a = beta/(1-beta)
z_t = x_t + a*(x_t - x_tm1)
z_tp1 = x_tp1 + a*(x_tp1 - x_t)

# Step 1: verify z_{t+1} - z_t = -(eta/(1-beta)) g_t
total += 1
print(f"[Step {total}] z_{{t+1}} - z_t = -(eta/(1-beta)) g_t")
diff = sp.simplify(z_tp1 - z_t)
expected = sp.simplify(-(eta/(1-beta))*g_t)
result = sp.simplify(diff - expected) == 0
print(f"  computed: {diff}")
print(f"  expected: {expected}")
print(f"  difference: {sp.simplify(diff - expected)}")
if result: pass_count += 1
print(f"  -> {'PASS' if result else 'FAIL'}")

# Step 2: verify ||z_t - x_t||^2 = (beta/(1-beta))^2 ||x_t - x_{t-1}||^2 (in 1D, square)
total += 1
print(f"[Step {total}] (z_t - x_t)^2 = (beta/(1-beta))^2 (x_t - x_{{t-1}})^2")
lhs = sp.expand((z_t - x_t)**2)
rhs = sp.expand((beta/(1-beta))**2 * (x_t - x_tm1)**2)
result = sp.simplify(lhs - rhs) == 0
print(f"  lhs: {lhs}")
print(f"  rhs: {rhs}")
if result: pass_count += 1
print(f"  -> {'PASS' if result else 'FAIL'}")

# Step 3: derive (1+a)*beta - a should equal 0 for residual to vanish
total += 1
print(f"[Step {total}] (1+a) beta - a = 0 with a = beta/(1-beta)")
expr = (1 + a)*beta - a
result = sp.simplify(expr) == 0
print(f"  expression: {sp.simplify(expr)}")
if result: pass_count += 1
print(f"  -> {'PASS' if result else 'FAIL'}")

# Step 4: verify (1+a) eta = eta/(1-beta)
total += 1
print(f"[Step {total}] (1+a) eta = eta/(1-beta)")
lhs = sp.simplify((1 + a)*eta)
rhs = sp.simplify(eta/(1-beta))
result = sp.simplify(lhs - rhs) == 0
print(f"  lhs: {lhs}")
print(f"  rhs: {rhs}")
if result: pass_count += 1
print(f"  -> {'PASS' if result else 'FAIL'}")

print(f"\nSummary: {pass_count}/{total} passed")
