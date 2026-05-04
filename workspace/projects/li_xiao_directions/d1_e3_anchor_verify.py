"""
Explorer 3 (NAIVE) - Anchor verification at (beta, eta L, kappa) = (0.8, 3.247, 0.387)
SHB on Goujaud K=3 polytope-Moreau function with zero-momentum init.

Goal: Verify orbit norm stays bounded away from 0 for large T, at high mpmath precision.
"""
from mpmath import mp, mpf, mpc, sqrt, cos, sin, pi, matrix, norm

mp.dps = 50  # 50-digit precision

# Anchor parameters
beta  = mpf("0.8")
etaL  = mpf("3.247")
kappa = mpf("0.387")
L     = mpf(1)
mu    = kappa * L
eta   = etaL / L
D     = mpf(1)
lam   = D / sqrt(2)  # cycle radius

# K=3 cycle vertices e_t in R^2
K = 3
def e_vec(t):
    ang = 2 * pi * (t % K) / K
    return matrix([cos(ang), sin(ang)])

# Goujaud K=3 polytope tilde P = {lam*M*e_t}_t. We need M.
# Per scout doc: M = ((1+beta - mu*eta) I - R_{2pi/3} - beta R_{-2pi/3}) / ((L-mu)*eta).
# Verify by checking the K=3 cycling identity numerically.
def Rmat(theta):
    c, s = cos(theta), sin(theta)
    return matrix([[c, -s], [s, c]])

theta3 = 2*pi/3
I2 = matrix([[1, 0], [0, 1]])
R3p = Rmat(theta3)
R3m = Rmat(-theta3)

M = ((1 + beta - mu*eta) * I2 - R3p - beta * R3m) * (1 / ((L - mu) * eta))

# Polytope vertices: v_t = lam * M * e_t
verts = [lam * (M * e_vec(t)) for t in range(K)]

def proj_polytope(x, verts):
    """Project x onto conv(verts) for a triangle in R^2 by checking sub-cases.
    For a triangle, return closest point: either x itself if interior, an edge projection,
    or a vertex.
    """
    # Compute closest point on triangle.  We handle generally by checking:
    # - If x lies inside the triangle, return x.
    # - Else, project to each edge (clamp to segment) and to each vertex,
    #   return the closest.
    v0, v1, v2 = verts[0], verts[1], verts[2]
    # Barycentric test for interior
    def signed_area(a, b, c):
        return (b[0]-a[0])*(c[1]-a[1]) - (b[1]-a[1])*(c[0]-a[0])
    A = signed_area(v0, v1, v2)
    s1 = signed_area(v0, v1, x) / A
    s2 = signed_area(v1, v2, x) / A
    s3 = signed_area(v2, v0, x) / A
    if s1 >= 0 and s2 >= 0 and s3 >= 0:
        return x  # interior
    # Else project to each edge
    candidates = []
    for (a, b) in [(v0, v1), (v1, v2), (v2, v0)]:
        ab = b - a
        denom = (ab.T * ab)[0, 0]
        t = ((x - a).T * ab)[0, 0] / denom
        if t < 0:
            t = mpf(0)
        elif t > 1:
            t = mpf(1)
        p = a + t * ab
        d = norm(x - p)
        candidates.append((d, p))
    candidates.sort(key=lambda z: z[0])
    return candidates[0][1]

def grad_f0(x):
    """f_0(x) = (L/2)|x|^2 - ((L-mu)/2) d_C(x)^2.
    d_C(x)^2 = |x - P_C(x)|^2, grad = 2(x - P_C(x)).
    grad f_0 = L*x - (L-mu)(x - P_C(x)) = mu*x + (L-mu)*P_C(x).
    """
    PC = proj_polytope(x, verts)
    return mu * x + (L - mu) * PC

# SHB step: x_{t+1} = x_t - eta*grad(x_t) + beta*(x_t - x_{t-1})
def shb_step(xt, xtm1):
    return xt - eta * grad_f0(xt) + beta * (xt - xtm1)

# Zero-momentum init
x_prev = lam * e_vec(0)
x_curr = lam * e_vec(0)

T_max = 2000
log_every = 100

print(f"# Anchor: beta={beta}, etaL={etaL}, kappa={kappa}")
print(f"# lam = D/sqrt(2) = {lam}")
print(f"# mu*eta = {mu*eta}, beta = {beta}")
print(f"# polytope vertices:")
for i, v in enumerate(verts):
    print(f"#   v_{i} = ({v[0]}, {v[1]}), |v_{i}| = {norm(v)}")

print()
print(f"# T  ||x_t||                                     ||x_t - lam*e_{{t mod K}}||")
norms_log = []
errs_to_cycle = []
for t in range(T_max + 1):
    xn = norm(x_curr)
    cycle_pt = lam * e_vec(t)
    err = norm(x_curr - cycle_pt)
    norms_log.append(xn)
    errs_to_cycle.append(err)
    if t % log_every == 0 or t in [1, 2, 3, 5, 10, 20, 50]:
        print(f"  {t:5d}   {mp.nstr(xn, 25):30s}  {mp.nstr(err, 15)}")
    x_new = shb_step(x_curr, x_prev)
    x_prev = x_curr
    x_curr = x_new

# Stats
min_norm = min(norms_log[1:])  # exclude t=0
max_norm = max(norms_log[1:])
print()
print(f"# Min ||x_t|| over t in [1, {T_max}]:  {mp.nstr(min_norm, 20)}")
print(f"# Max ||x_t|| over t in [1, {T_max}]:  {mp.nstr(max_norm, 20)}")
print(f"# lam = D/sqrt(2) = {mp.nstr(lam, 20)}")
print(f"# Ratio min ||x_t|| / lam: {mp.nstr(min_norm / lam, 15)}")

# Asymptotic: min over t >= 100
print(f"# Min ||x_t|| over t in [100, {T_max}]:  {mp.nstr(min(norms_log[100:]), 20)}")
print(f"# Min ||x_t|| over t in [200, {T_max}]:  {mp.nstr(min(norms_log[200:]), 20)}")

# Check whether min_norm > 0.5 * lam (the certificate threshold)
threshold = mpf("0.5") * lam
ok = min(norms_log[100:]) >= threshold
print(f"# min ||x_t||_{{t>=100}} >= 0.5 * lam ?  {ok}")

# Find first t such that ||x_t|| >= 0.99 * lam for all subsequent t
target99 = mpf("0.99") * lam
T_settle = None
for t in range(len(norms_log)):
    if all(n >= target99 for n in norms_log[t:]):
        T_settle = t
        break
print(f"# T_settle (first t such that ||x_s|| >= 0.99*lam for all s >= t): {T_settle}")

# Print the fixed point coordinates
print(f"# Final iterate at T={T_max}: x = ({mp.nstr(x_curr[0], 30)}, {mp.nstr(x_curr[1], 30)})")
print(f"# Final iterate norm: {mp.nstr(norm(x_curr), 30)}")
