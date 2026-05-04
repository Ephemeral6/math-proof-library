"""
Drill into the 19 "other" points: are they period-2, period-something, or chaotic?
For each suspect point, run T=5000 at dps=100, examine last 30 norms in detail
and check periodicity at p=2,3,4,5,6.
"""
import mpmath as mp
import math

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
    A = (1 + beta - mu*eta) * I2 - R_pos - beta * R_neg
    return A / ((L - mu) * eta)

def vertices(beta, eta, mu):
    M = goujaud_M(beta, eta, mu)
    R = D / mp.sqrt(2)
    out = []
    for t in range(K):
        angle = t * theta_K
        e_t = mp.matrix([[mp.cos(angle)], [mp.sin(angle)]])
        out.append(M * e_t * R)
    return out

def project(x, V):
    Kn = len(V)
    inside = True
    for i in range(Kn):
        v_i, v_n = V[i], V[(i+1)%Kn]
        e = v_n - v_i; d = x - v_i
        c = e[0,0]*d[1,0] - e[1,0]*d[0,0]
        if c < 0:
            inside = False
            break
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
        diff = x - p
        d2 = diff[0,0]**2 + diff[1,0]**2
        if bd is None or d2 < bd:
            bd, bp = d2, p
    return bp

def step(xt, xtm1, beta, eta, mu, V):
    Pc = project(xt, V)
    g = mu*xt + (L-mu)*Pc
    return xt - eta*g + beta*(xt - xtm1)

def run(beta_v, etaL_v, kap_v, T):
    beta = mp.mpf(str(beta_v)); eta = mp.mpf(str(etaL_v)); mu = mp.mpf(str(kap_v))
    V = vertices(beta, eta, mu)
    e0 = mp.matrix([[mp.mpf(1)], [mp.mpf(0)]])
    R = D/mp.sqrt(2)
    x_init = R*e0
    xtm1, xt = x_init.copy(), x_init.copy()
    norms, xs = [mp.sqrt(xt[0,0]**2+xt[1,0]**2)], [(xt[0,0], xt[1,0])]
    for _ in range(T):
        xn = step(xt, xtm1, beta, eta, mu, V)
        xtm1, xt = xt, xn
        norms.append(mp.sqrt(xt[0,0]**2+xt[1,0]**2))
        xs.append((xt[0,0], xt[1,0]))
    return norms, xs

def check_period(xs, p, tail_len=20):
    """Check if x_t = x_{t+p} for the last `tail_len` indices, in 2D."""
    tail = xs[-tail_len:]
    err = 0
    for i in range(len(tail) - p):
        d0 = tail[i+p][0] - tail[i][0]
        d1 = tail[i+p][1] - tail[i][1]
        e = mp.sqrt(d0**2 + d1**2)
        if e > err: err = e
    return float(err)

# Suspect points (from previous output)
suspects = [
    (0.900, 3.038, 0.4489),
    (0.900, 3.128, 0.4406),
    (0.900, 3.217, 0.4302),
    (0.900, 3.307, 0.4196),
    (0.900, 3.397, 0.4092),
    (0.900, 3.486, 0.3991),
    (0.900, 3.576, 0.3894),
    (0.900, 3.666, 0.3802),
    (0.900, 3.755, 0.3713),
    (0.950, 2.998, 0.4750),
    (0.950, 3.093, 0.4659),
    (0.950, 3.188, 0.4532),
    (0.950, 3.283, 0.4405),
    (0.950, 3.378, 0.4284),
    (0.950, 3.473, 0.4168),
    (0.950, 3.568, 0.4058),
    (0.950, 3.663, 0.3954),
    (0.950, 3.758, 0.3855),
    (0.950, 3.853, 0.3760),
]

print("="*80)
print("Period analysis of the 19 'other' points (T=5000, dps=100)")
print("="*80)
print(f"{'beta':>5} {'etaL':>6} {'kappa':>7} {'final':>8} | err(p=2) err(p=3) err(p=4) err(p=6)")
print("-"*80)

cls = {2:0, 3:0, 4:0, 5:0, 6:0, "none":0}

for (b, eL, k) in suspects:
    norms, xs = run(b, eL, k, T=3000)
    final = float(norms[-1])
    e2 = check_period(xs, 2)
    e3 = check_period(xs, 3)
    e4 = check_period(xs, 4)
    e6 = check_period(xs, 6)
    # tolerance
    tol = 1e-5
    is_p2 = e2 < tol
    is_p3 = e3 < tol
    is_p4 = e4 < tol
    is_p6 = e6 < tol
    if is_p2:
        cls[2] += 1; tag = "PERIOD-2"
    elif is_p3:
        cls[3] += 1; tag = "PERIOD-3"
    elif is_p4:
        cls[4] += 1; tag = "PERIOD-4"
    elif is_p6:
        cls[6] += 1; tag = "PERIOD-6"
    else:
        cls["none"] += 1; tag = "non-periodic/long"
    print(f"{b:5.3f} {eL:6.3f} {k:7.4f} {final:8.4f} | {e2:8.2g} {e3:8.2g} {e4:8.2g} {e6:8.2g}  {tag}")

print()
print("Classification of the 19 'other' points:")
for k, v in cls.items():
    print(f"  period-{k}: {v}")
