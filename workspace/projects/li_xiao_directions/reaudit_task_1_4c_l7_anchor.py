"""Verify L7's claimed period-2 anchors (0.9, 3.78, 0.05) and (0.95, 3.85, 0.10)."""
import mpmath as mp
mp.mp.dps = 100

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
        if e[0,0]*d[1,0] - e[1,0]*d[0,0] < 0:
            inside = False; break
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
    g = mu*xt + (L-mu)*Pc
    return xt - eta*g + beta*(xt - xtm1)

def run(b, eL, k, T):
    beta=mp.mpf(str(b)); eta=mp.mpf(str(eL)); mu=mp.mpf(str(k))
    V = vertices(beta, eta, mu)
    e0 = mp.matrix([[mp.mpf(1)],[mp.mpf(0)]])
    R = D/mp.sqrt(2)
    xtm1 = R*e0; xt = R*e0
    norms = [mp.sqrt(xt[0,0]**2+xt[1,0]**2)]
    xs = [(xt[0,0],xt[1,0])]
    for _ in range(T):
        xn = step(xt, xtm1, beta, eta, mu, V)
        xtm1, xt = xt, xn
        norms.append(mp.sqrt(xt[0,0]**2+xt[1,0]**2))
        xs.append((xt[0,0],xt[1,0]))
    return norms, xs

for (b, eL, k) in [(0.9, 3.78, 0.05), (0.95, 3.85, 0.10), (0.9, 3.7, 0.1)]:
    norms, xs = run(b, eL, k, 3000)
    print(f"\n=== ({b}, {eL}, {k}) ===")
    print(f"final ||x|| = {float(norms[-1]):.6f}")
    # Check periods 2,3,4
    for p in (2,3,4,6):
        err = max(float(mp.sqrt((xs[i+p][0]-xs[i][0])**2+(xs[i+p][1]-xs[i][1])**2))
                  for i in range(len(xs)-p-50, len(xs)-p))
        print(f"  err(p={p}) = {err:.4e}")
    # Show last 10 norms
    print(f"  Last 10 ||x_t||: {[float(n) for n in norms[-10:]]}")
