"""
Task 4.3: Re-classify "other" points (19 points at beta in {0.9, 0.95}) at T=100000.

Determine for each:
  - period-2 attractor: ||x_{t+2} - x_t|| < 1e-30 at large t
  - period-K (K>2): smallest K with ||x_{t+K} - x_t|| < 1e-30
  - slow decay: ||x_t|| eventually < 1e-30
  - quasi-periodic: bounded but no exact period
"""

import mpmath as mp
import json
import time
from pathlib import Path

mp.mp.dps = 70

L = mp.mpf(1); D = mp.mpf(1); K = 3
theta_K = 2 * mp.pi / K

def gamma_crit(beta):
    return 3 * (1 + beta + beta**2) / (1 + 2*beta)

def goujaud_M(beta, eta, mu):
    cos_t, sin_t = mp.cos(theta_K), mp.sin(theta_K)
    R_pos = mp.matrix([[cos_t, -sin_t], [sin_t, cos_t]])
    R_neg = mp.matrix([[cos_t, sin_t], [-sin_t, cos_t]])
    I2 = mp.matrix([[1, 0], [0, 1]])
    A = (1 + beta - mu*eta) * I2 - R_pos - beta * R_neg
    return A / ((L - mu) * eta)

def goujaud_polytope_vertices(beta, eta, mu):
    M = goujaud_M(beta, eta, mu)
    vertices = []
    for t in range(K):
        angle = t * theta_K
        e_t = mp.matrix([[mp.cos(angle)], [mp.sin(angle)]])
        v = M * e_t * (D / mp.sqrt(2))
        vertices.append(v)
    return vertices

def project_to_polygon(x, vertices):
    Kn = len(vertices)
    inside = True
    for i in range(Kn):
        v_i = vertices[i]; v_next = vertices[(i+1) % Kn]
        e = v_next - v_i; d = x - v_i
        cross = e[0,0]*d[1,0] - e[1,0]*d[0,0]
        if cross < 0: inside = False; break
    if inside: return x
    best_d=None; best_p=None
    for i in range(Kn):
        v_i=vertices[i]; v_next=vertices[(i+1)%Kn]
        e=v_next-v_i; e_norm2=e[0,0]**2+e[1,0]**2
        if e_norm2==0: p=v_i
        else:
            d=x-v_i; t=(d[0,0]*e[0,0]+d[1,0]*e[1,0])/e_norm2
            t=max(mp.mpf(0),min(mp.mpf(1),t))
            p=v_i+e*t
        diff=x-p; dist2=diff[0,0]**2+diff[1,0]**2
        if best_d is None or dist2<best_d:
            best_d=dist2; best_p=p
    return best_p

def shb_step(x_t, x_tm1, beta, eta, mu, vertices):
    Pc = project_to_polygon(x_t, vertices)
    g = mu*x_t + (L-mu)*Pc
    return x_t - eta*g + beta*(x_t - x_tm1)

def matnorm(d):
    return mp.sqrt(d[0,0]**2 + d[1,0]**2)

def matsub(a, b):
    return mp.matrix([[a[0,0]-b[0,0]], [a[1,0]-b[1,0]]])

def run_long(beta, eta_L, kappa, T_max):
    """Run SHB. Return list of (t, x_t copy) for last few thousand steps and final norms."""
    eta = eta_L / L
    mu = kappa * L
    vertices = goujaud_polytope_vertices(beta, eta, mu)
    e0 = mp.matrix([[mp.cos(mp.mpf(0))], [mp.sin(mp.mpf(0))]])
    R = D / mp.sqrt(2)
    x_init = R * e0
    x_tm1 = x_init.copy()
    x_t = x_init.copy()

    # Capture last 200 iterates with t indices
    snapshot_size = 200
    snapshots = []  # list of x_t (mp matrices)
    final_norm = matnorm(x_t)

    for t in range(T_max):
        x_next = shb_step(x_t, x_tm1, beta, eta, mu, vertices)
        x_tm1 = x_t
        x_t = x_next
        if T_max - t <= snapshot_size:
            snapshots.append(mp.matrix([[x_t[0,0]], [x_t[1,0]]]))
    final_norm = matnorm(snapshots[-1])
    return snapshots, final_norm

def classify_long(snapshots, final_norm, D_val):
    """Classify based on snapshots = last 200 iterates."""
    final = float(final_norm)
    Dv = float(D_val)
    target_R = Dv / mp.sqrt(2)

    # Test for slow decay first
    if final < 1e-25:
        return "slow_decay", final, None, None

    # For period detection, look at consecutive distances at the end
    # snapshots[i] vs snapshots[i+K] for K=2,3,...,20
    n = len(snapshots)
    if n < 60:
        return "indeterminate", final, None, None

    # Use last 50 iterates for period testing
    tail = snapshots[-50:]
    # threshold depends on precision; for dps=70 use 1e-30
    tol = mp.mpf("1e-30")
    period_found = None
    period_residual = None
    for K_test in range(1, 25):
        if 50 - K_test < 5: break
        max_diff = mp.mpf(0)
        for i in range(50 - K_test):
            d = matsub(tail[i + K_test], tail[i])
            nd = matnorm(d)
            if nd > max_diff: max_diff = nd
        if max_diff < tol:
            period_found = K_test
            period_residual = float(max_diff)
            break
        # also record best so far
        if period_residual is None or max_diff < period_residual:
            period_residual = float(max_diff)

    if period_found is not None:
        if period_found == 2:
            return "period_2", final, period_found, period_residual
        else:
            return f"period_{period_found}", final, period_found, period_residual
    # No exact period within 50-iterate window at tol=1e-30
    # Check if relatively bounded with small variation -> quasi-periodic
    norms_tail = [float(matnorm(s)) for s in tail]
    mean_n = sum(norms_tail)/len(norms_tail)
    var_n = sum((x-mean_n)**2 for x in norms_tail)/len(norms_tail)
    std_n = var_n**0.5
    # Find best period residual we observed; if it's small relative to scale, quasi-periodic
    return "quasi_periodic", final, None, period_residual

# 19 "other" points from original results
other_points = [
    (0.900, 3.0380, 0.4489),
    (0.900, 3.1277, 0.4406),
    (0.900, 3.2173, 0.4302),
    (0.900, 3.3070, 0.4196),
    (0.900, 3.3966, 0.4092),
    (0.900, 3.4863, 0.3991),
    (0.900, 3.5759, 0.3894),
    (0.900, 3.6655, 0.3802),
    (0.900, 3.7552, 0.3713),
    (0.950, 2.9983, 0.4750),
    (0.950, 3.0932, 0.4659),
    (0.950, 3.1881, 0.4532),
    (0.950, 3.2831, 0.4405),
    (0.950, 3.3780, 0.4284),
    (0.950, 3.4729, 0.4168),
    (0.950, 3.5678, 0.4058),
    (0.950, 3.6627, 0.3954),
    (0.950, 3.7576, 0.3855),
    (0.950, 3.8525, 0.3760),
]

def main():
    print(f"# RE-AUDIT Task 4.3: long-horizon for 19 'other' points")
    print(f"# mpmath dps={mp.mp.dps}, T=100000")
    print(f"{'beta':>6} {'etaL':>7} {'kappa':>8} {'classification':>16} {'final':>14} {'period':>7} {'residual':>14}")

    results = []
    t_start = time.time()
    for (b, el, k) in other_points:
        beta = mp.mpf(str(b)); eta_L = mp.mpf(str(el)); kappa = mp.mpf(str(k))
        snaps, fn = run_long(beta, eta_L, kappa, T_max=100000)
        cls, final_f, period, residual = classify_long(snaps, fn, D)
        per_str = str(period) if period else "-"
        res_str = f"{residual:.4e}" if residual is not None else "-"
        print(f"{b:6.3f} {el:7.4f} {k:8.4f} {cls:>16s} {final_f:14.6e} {per_str:>7} {res_str:>14}")
        results.append({
            "beta": b, "eta_L": el, "kappa": k,
            "classification_T100000": cls,
            "final_norm": final_f,
            "period": period,
            "period_residual": residual,
        })
    print(f"\nElapsed: {time.time()-t_start:.1f}s")
    out = Path(r"C:\Users\12729\Desktop\Math\workspace\active\li_xiao_directions\reaudit_long_horizon_results.json")
    with open(out, "w", encoding="utf-8") as fp:
        json.dump(results, fp, indent=2)
    print(f"Saved to {out}")

if __name__ == "__main__":
    main()
