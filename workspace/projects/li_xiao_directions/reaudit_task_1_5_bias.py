"""
Re-Audit Task 1.5 — verify the bias constant kappa/8 numerically.

For the cycling anchor (0.8, 3.247, 0.387):
  Compute f_0(x_T) - f_0^* for T = 1, 2, ..., 1000.
  Compute c_T = T * (f_0(x_T) - f_0^*) / (kappa L D^2).
  Find min_T c_T, the smallest valid bias constant.

If min_T c_T >= 1/8, the kappa/8 claim is VALID.
If min_T c_T < 1/8, the claim is INVALID; report the actual constant.

Also compute the same for OP-2 init at the same anchor (should give kappa/4).
"""
import mpmath as mp
mp.mp.dps = 50

L = mp.mpf(1)
D = mp.mpf(1)
K = 3
theta_K = 2*mp.pi/K

def goujaud_M(beta, eta, mu):
    cos_t, sin_t = mp.cos(theta_K), mp.sin(theta_K)
    R_pos = mp.matrix([[cos_t, -sin_t], [sin_t, cos_t]])
    R_neg = mp.matrix([[cos_t, sin_t], [-sin_t, cos_t]])
    I2 = mp.matrix([[1,0],[0,1]])
    A = (1+beta-mu*eta)*I2 - R_pos - beta*R_neg
    return A/((L-mu)*eta)

def vertices(beta, eta, mu):
    M = goujaud_M(beta, eta, mu)
    R = D/mp.sqrt(2)
    return [M * mp.matrix([[mp.cos(t*theta_K)],[mp.sin(t*theta_K)]]) * R for t in range(K)]

def project(x, V):
    Kn = len(V); inside = True
    for i in range(Kn):
        v_i, v_n = V[i], V[(i+1)%Kn]
        e = v_n - v_i; d = x - v_i
        if e[0,0]*d[1,0] - e[1,0]*d[0,0] < 0: inside = False; break
    if inside: return x
    bd, bp = None, None
    for i in range(Kn):
        v_i, v_n = V[i], V[(i+1)%Kn]
        e = v_n - v_i; en2 = e[0,0]**2 + e[1,0]**2
        if en2 == 0: p = v_i
        else:
            d = x - v_i
            t = (d[0,0]*e[0,0] + d[1,0]*e[1,0])/en2
            t = max(mp.mpf(0), min(mp.mpf(1), t))
            p = v_i + e*t
        diff = x - p; d2 = diff[0,0]**2 + diff[1,0]**2
        if bd is None or d2 < bd: bd, bp = d2, p
    return bp

def step(xt, xtm1, beta, eta, mu, V):
    Pc = project(xt, V)
    return xt - eta*(mu*xt + (L-mu)*Pc) + beta*(xt - xtm1)

def f0(x, beta, eta, mu, V):
    """f_0(x) = (L/2)|x|^2 - ((L-mu)/2) d_C(x)^2"""
    Pc = project(x, V)
    nrm2 = x[0,0]**2 + x[1,0]**2
    diff = x - Pc
    d2 = diff[0,0]**2 + diff[1,0]**2
    return (L/2)*nrm2 - ((L-mu)/2)*d2

def run(b, eL, k, T, init):
    beta = mp.mpf(str(b)); eta = mp.mpf(str(eL)); mu = mp.mpf(str(k))
    V = vertices(beta, eta, mu)
    e0 = mp.matrix([[mp.mpf(1)],[mp.mpf(0)]])
    eKm1 = mp.matrix([[mp.cos((K-1)*theta_K)],[mp.sin((K-1)*theta_K)]])
    R = D/mp.sqrt(2)
    if init == "zero":
        xtm1 = R*e0; xt = R*e0
    else:
        xtm1 = R*eKm1; xt = R*e0
    rows = []
    for t in range(T+1):
        nrm2 = xt[0,0]**2 + xt[1,0]**2
        f_val = f0(xt, beta, eta, mu, V)
        rows.append((t, mp.sqrt(nrm2), f_val))
        if t < T:
            xn = step(xt, xtm1, beta, eta, mu, V)
            xtm1, xt = xt, xn
    return rows, beta, eta, mu

print("="*78)
print("Task 1.5 — Bias constant verification at anchor (0.8, 3.247, 0.387)")
print("="*78)

for label, init in [("zero-momentum", "zero"), ("OP-2", "op2")]:
    rows, beta, eta, mu = run(0.8, 3.247, 0.387, T=200, init=init)
    print(f"\n--- {label} init ---")

    # f_0^* = 0 since 0 is the minimizer of strongly convex f_0 with f_0(0)=0
    # Compute c_T = T * (f_0(x_T) - 0) / (kappa * L * D^2) = T * f_0 / kappa
    kap = mu  # since L=1, D=1
    print(f"  {'T':>5} {'||x_T||':>12} {'f_0(x_T)':>14} {'c_T = T f_0 / kappa':>22}")
    cT_min = None
    cT_argmin = None
    for (t, nrm, f_val) in rows[:20]:
        cT = t * f_val / kap if t > 0 else mp.inf
        cT_f = float(cT)
        print(f"  {t:5d} {float(nrm):12.6f} {float(f_val):14.6e} {cT_f:22.6f}")
        if t > 0 and (cT_min is None or cT_f < cT_min):
            cT_min = cT_f; cT_argmin = t

    # Scan all T = 1..200
    for (t, nrm, f_val) in rows[1:]:
        cT = float(t * f_val / kap)
        if cT_min is None or cT < cT_min:
            cT_min = cT; cT_argmin = t

    print(f"\n  min over T=1..200 of c_T = {cT_min:.6f} at T = {cT_argmin}")
    print(f"  Threshold for kappa/8: c_T >= 0.125. ", "VALID" if cT_min >= 0.125 else "FAILS")
    print(f"  Threshold for kappa/4: c_T >= 0.250. ", "VALID" if cT_min >= 0.250 else "FAILS")

    # Restricted to T >= T_0 for various T_0
    for T0 in [10, 20, 30, 50, 100]:
        cT_min_post = None
        cT_arg_post = None
        for (t, nrm, f_val) in rows[T0:]:
            cT = float(t * f_val / kap)
            if cT_min_post is None or cT < cT_min_post:
                cT_min_post = cT; cT_arg_post = t
        print(f"  For T >= {T0}: min c_T = {cT_min_post:.6f} at T = {cT_arg_post} -> ", end='')
        print("kappa/8 VALID" if cT_min_post >= 0.125 else "kappa/8 FAILS")
