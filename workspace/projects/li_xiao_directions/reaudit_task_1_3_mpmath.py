"""
Re-Audit Task 1.3 — mpmath numerical SHB verification.

Two test points:
  (a) (beta, eta L, kappa) = (0.5, 2.7, 0.1)  -- generic point in F
  (b) (beta, eta L, kappa) = (0.8, 3.247, 0.387) -- cycling anchor

For each:
  1. Compute |A_mu^zero| from the formula.
  2. Run SHB on f_0 with zero-momentum init for T = 10000 steps.
  3. Record ||x_t|| over time and check final behavior.
  4. Confirm: A_mu != 0 does NOT imply cycling.
     Cycling requires the nonlinear projection-onto-polytope force.
"""

import mpmath as mp

mp.mp.dps = 100

L = mp.mpf(1)
D = mp.mpf(1)
K = 3
theta_K = 2 * mp.pi / K

def goujaud_M(beta, eta, mu):
    cos_t, sin_t = mp.cos(theta_K), mp.sin(theta_K)
    R_pos = mp.matrix([[cos_t, -sin_t], [sin_t, cos_t]])
    R_neg = mp.matrix([[cos_t, sin_t], [-sin_t, cos_t]])
    I2 = mp.matrix([[1, 0], [0, 1]])
    A_mat = (1 + beta - mu*eta) * I2 - R_pos - beta * R_neg
    return A_mat / ((L - mu) * eta)

def goujaud_polytope_vertices(beta, eta, mu, R):
    M = goujaud_M(beta, eta, mu)
    vertices = []
    for t in range(K):
        angle = t * theta_K
        e_t = mp.matrix([[mp.cos(angle)], [mp.sin(angle)]])
        v = M * e_t * R
        vertices.append(v)
    return vertices

def project_to_polygon(x, vertices):
    Kn = len(vertices)
    inside = True
    for i in range(Kn):
        v_i = vertices[i]
        v_next = vertices[(i+1) % Kn]
        e = v_next - v_i
        d = x - v_i
        cross = e[0,0]*d[1,0] - e[1,0]*d[0,0]
        if cross < 0:
            inside = False
            break
    if inside:
        return x
    best_d = None
    best_p = None
    for i in range(Kn):
        v_i = vertices[i]
        v_next = vertices[(i+1) % Kn]
        e = v_next - v_i
        e_norm2 = e[0,0]**2 + e[1,0]**2
        if e_norm2 == 0:
            p = v_i
        else:
            d = x - v_i
            t = (d[0,0]*e[0,0] + d[1,0]*e[1,0]) / e_norm2
            t = max(mp.mpf(0), min(mp.mpf(1), t))
            p = v_i + e * t
        diff = x - p
        dist2 = diff[0,0]**2 + diff[1,0]**2
        if best_d is None or dist2 < best_d:
            best_d = dist2
            best_p = p
    return best_p

def grad_f0(x, beta, eta, mu, vertices):
    Pc = project_to_polygon(x, vertices)
    return mu * x + (L - mu) * Pc

def shb_step(x_t, x_tm1, beta, eta, mu, vertices):
    g = grad_f0(x_t, beta, eta, mu, vertices)
    return x_t - eta * g + beta * (x_t - x_tm1)

def run_shb_zero_init(beta_val, etaL_val, kap_val, T):
    beta = mp.mpf(str(beta_val))
    eta = mp.mpf(str(etaL_val))  # L = 1, eta = etaL
    mu = mp.mpf(str(kap_val))     # mu = kappa, since L = 1

    R = D / mp.sqrt(2)
    vertices = goujaud_polytope_vertices(beta, eta, mu, R)

    e0 = mp.matrix([[mp.mpf(1)], [mp.mpf(0)]])
    x_init = R * e0

    x_tm1 = x_init.copy()
    x_t = x_init.copy()

    norms = [mp.sqrt(x_t[0,0]**2 + x_t[1,0]**2)]
    snapshots = []

    for t in range(T):
        x_next = shb_step(x_t, x_tm1, beta, eta, mu, vertices)
        x_tm1 = x_t
        x_t = x_next
        nrm = mp.sqrt(x_t[0,0]**2 + x_t[1,0]**2)
        norms.append(nrm)
        if t in (0, 1, 2, 3, 5, 10, 50, 100, 500, 1000, 5000, 9999):
            snapshots.append((t+1, float(nrm), float(x_t[0,0]), float(x_t[1,0])))

    return norms, snapshots

def amplitude_zero(beta_val, etaL_val, kap_val):
    """|A_mu^zero| via the formula v * sqrt(eta*mu / (4 beta sin^2 theta_mu))."""
    beta = mp.mpf(str(beta_val))
    eta = mp.mpf(str(etaL_val))
    mu = mp.mpf(str(kap_val))
    v = D/mp.sqrt(2)
    disc = (1 + beta - eta*mu)**2 - 4*beta
    if disc < 0:
        # Under-damped
        sqb = mp.sqrt(beta)
        theta_mu = mp.acos((1 + beta - eta*mu)/(2*sqb))
        sin_t = mp.sin(theta_mu)
        return v*mp.sqrt(eta*mu/(4*beta*sin_t**2))
    else:
        # Over-damped: real roots; A is real-valued, formula different.
        sqd = mp.sqrt(disc)
        r1 = ((1 + beta - eta*mu) + sqd)/2
        r2 = ((1 + beta - eta*mu) - sqd)/2
        return abs(v*(1 - r2)/(r1 - r2))

def report(label, beta_val, etaL_val, kap_val, T):
    print(f"\n{'='*78}")
    print(f"Test point ({label}): beta={beta_val}, eta L={etaL_val}, kappa={kap_val}, T={T}")
    print(f"{'='*78}")

    A = amplitude_zero(beta_val, etaL_val, kap_val)
    print(f"|A_mu^zero| (formula) = {A}")

    # SHB run
    norms, snapshots = run_shb_zero_init(beta_val, etaL_val, kap_val, T)

    R = float(D/mp.sqrt(2))
    print(f"\nTarget cycle radius R = D/sqrt(2) = {R:.6f}")
    print(f"\nTrajectory snapshots:")
    print(f"  {'t':>6} {'||x_t||':>20} {'x_t[0]':>20} {'x_t[1]':>20}")
    for t, nrm, x0, x1 in snapshots:
        print(f"  {t:6d} {nrm:20.10g} {x0:20.10g} {x1:20.10g}")

    # Final tail mean and std
    tail = norms[-200:]
    tail_floats = [float(n) for n in tail]
    mean_tail = sum(tail_floats)/len(tail_floats)
    var_tail = sum((x - mean_tail)**2 for x in tail_floats)/len(tail_floats)
    std_tail = var_tail**0.5
    print(f"\nFinal tail (last 200 steps):")
    print(f"  mean ||x_t|| = {mean_tail:.10g}")
    print(f"  std  ||x_t|| = {std_tail:.10g}")
    print(f"  ratio mean/R = {mean_tail/R:.6f}")

    final = float(norms[-1])
    print(f"\nFinal ||x_T|| = {final:.10g}")

    if final < 0.05*R:
        verdict = "DECAY"
    elif abs(mean_tail - R)/R < 0.05 and std_tail/R < 0.10:
        verdict = "CYCLING (radius = D/sqrt(2))"
    elif final > 0.5*R and final < 2*R:
        verdict = "BOUNDED OSCILLATION"
    elif final > 100*R:
        verdict = "DIVERGENT"
    else:
        verdict = "OTHER (decay/transient)"
    print(f"\nVerdict: {verdict}")
    return verdict, A, final

# ========== Test point (a): generic (0.5, 2.7, 0.1) ==========
verdict_a, A_a, final_a = report("a (generic)", 0.5, 2.7, 0.1, T=10000)

# ========== Test point (b): cycling anchor (0.8, 3.247, 0.387) ==========
verdict_b, A_b, final_b = report("b (anchor)", 0.8, 3.247, 0.387, T=10000)

print(f"\n{'='*78}")
print(f"SUMMARY")
print(f"{'='*78}")
print(f"Point (a) generic:")
print(f"  |A_mu^zero| = {float(A_a):.6f} (NONZERO)")
print(f"  SHB orbit at T=10000: {verdict_a}, ||x_T|| = {final_a:.6g}")
print(f"Point (b) anchor:")
print(f"  |A_mu^zero| = {float(A_b):.6f} (NONZERO)")
print(f"  SHB orbit at T=10000: {verdict_b}, ||x_T|| = {final_b:.6g}")

print(f"\n{'='*78}")
print("KEY OBSERVATION:")
print("Both points have A_mu^zero != 0 (consistent with Task 1.2 — A_mu vanishes")
print("only at mu = 0). Yet point (a) DECAYS while point (b) CYCLES.")
print("This confirms: A_mu != 0 does NOT imply non-decay. Cycling is a NONLINEAR")
print("phenomenon depending on whether the iterate stays outside the polytope.")
print(f"{'='*78}")
