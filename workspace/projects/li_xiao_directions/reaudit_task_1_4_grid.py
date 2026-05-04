"""
Re-Audit Task 1.4 — re-run grid scan at 100-digit precision.

Replicate the 10x10=100 grid in F_{K=3} with mpmath dps=100, T=10000.
Count: cycling / decay / period-2 / other.
Compare with claimed 8/73/19.
"""

import mpmath as mp
import math
import json

mp.mp.dps = 100

L = mp.mpf(1)
D = mp.mpf(1)
K = 3
theta_K = 2 * mp.pi / K

beta_star = (mp.sqrt(13) - 3) / 2

def gamma_crit(beta):
    return 3 * (1 + beta + beta**2) / (1 + 2*beta)

def goujaud_M(beta, eta, mu):
    cos_t, sin_t = mp.cos(theta_K), mp.sin(theta_K)
    R_pos = mp.matrix([[cos_t, -sin_t], [sin_t, cos_t]])
    R_neg = mp.matrix([[cos_t, sin_t], [-sin_t, cos_t]])
    I2 = mp.matrix([[1, 0], [0, 1]])
    A = (1 + beta - mu*eta) * I2 - R_pos - beta * R_neg
    return A / ((L - mu) * eta)

def feasible_kappa(beta, eta_L):
    eta = eta_L / L
    a = eta_L**2 - 2*eta_L*(1 + beta/2)
    b = -2*eta_L*(beta + mp.mpf(1)/2) + 3*(1 + beta + beta**2)
    if a > 0:
        kappa_max = -b/a
        if kappa_max <= 0:
            return None
        return min(kappa_max/2, mp.mpf("0.5"))
    elif a < 0:
        kappa_min = -b/a
        if kappa_min >= 1:
            return None
        return (kappa_min + 1)/2
    else:
        if b < 0:
            return mp.mpf("0.5")
        return None

def goujaud_polytope_vertices(beta, eta, mu):
    M = goujaud_M(beta, eta, mu)
    R = D / mp.sqrt(2)
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

def run_shb_zero_init(beta, eta_L, mu, T):
    eta = eta_L / L
    vertices = goujaud_polytope_vertices(beta, eta, mu)
    e0 = mp.matrix([[mp.mpf(1)], [mp.mpf(0)]])
    R = D / mp.sqrt(2)
    x_init = R * e0
    x_tm1 = x_init.copy()
    x_t = x_init.copy()
    norms = [mp.sqrt(x_t[0,0]**2 + x_t[1,0]**2)]
    for t in range(T):
        x_next = shb_step(x_t, x_tm1, beta, eta, mu, vertices)
        x_tm1 = x_t
        x_t = x_next
        norms.append(mp.sqrt(x_t[0,0]**2 + x_t[1,0]**2))
    return norms

def classify_orbit(norms, target_R):
    final = float(norms[-1])
    target = float(target_R)
    tail = norms[-min(len(norms), 1000):]
    tail_floats = [float(n) for n in tail]
    if max(tail_floats) > 100 * target:
        return "diverge"
    if max(tail_floats) < 0.05 * target:
        return "decay"
    mean_tail = sum(tail_floats)/len(tail_floats)
    var_tail = sum((x - mean_tail)**2 for x in tail_floats)/len(tail_floats)
    std_tail = math.sqrt(var_tail)
    # Check periodicity by looking at the last 6-step pattern
    last_norms = tail_floats[-50:]
    # period-3?
    is_p3 = True
    for i in range(len(last_norms)-3):
        if abs(last_norms[i] - last_norms[i+3]) > 1e-6 * target:
            is_p3 = False
            break
    if is_p3 and abs(mean_tail - target)/target < 0.05:
        return "cycling"
    # period-2?
    is_p2 = True
    for i in range(len(last_norms)-2):
        if abs(last_norms[i] - last_norms[i+2]) > 1e-6 * target:
            is_p2 = False
            break
    if is_p2 and mean_tail > 0.5 * target:
        return "period2"
    if mean_tail < 0.5 * target and std_tail / max(mean_tail, 1e-30) < 0.5:
        return "decay"
    return "other"

def main():
    target_R = D/mp.sqrt(2)
    beta_grid = [mp.mpf(b) for b in [0.31, 0.35, 0.40, 0.45, 0.50, 0.60, 0.70, 0.80, 0.90, 0.95]]
    results = []
    cls_count = {"cycling":0, "decay":0, "period2":0, "other":0, "diverge":0}

    for beta in beta_grid:
        gc = gamma_crit(beta)
        eta_max = 2*(1 + beta)
        if eta_max <= gc:
            continue
        for j in range(10):
            t_frac = mp.mpf(j + 0.5)/10
            eta_L = gc + t_frac*(eta_max - gc)
            kappa = feasible_kappa(beta, eta_L)
            if kappa is None:
                continue
            mu = kappa * L
            T = 3000
            norms = run_shb_zero_init(beta, eta_L, mu, T)
            v = classify_orbit(norms, target_R)
            cls_count[v] += 1
            results.append({"beta":float(beta),"eta_L":float(eta_L),"kappa":float(kappa),"verdict":v,"final":float(norms[-1])})

    print("\n" + "="*78)
    print("Re-Audit Task 1.4 — Grid scan at dps=100, T=10000")
    print("="*78)
    print(f"Total grid points: {len(results)}")
    for k, c in cls_count.items():
        print(f"  {k:>10s}: {c:>4d}/{len(results)}  ({100*c/max(1,len(results)):.0f}%)")

    # List cycling and period2 grid points
    print(f"\nCycling grid points:")
    for r in results:
        if r["verdict"] == "cycling":
            print(f"  beta={r['beta']:.3f}, etaL={r['eta_L']:.3f}, kappa={r['kappa']:.4f}")
    print(f"\nPeriod-2 grid points:")
    for r in results:
        if r["verdict"] == "period2":
            print(f"  beta={r['beta']:.3f}, etaL={r['eta_L']:.3f}, kappa={r['kappa']:.4f}, final={r['final']:.4f}")
    print(f"\nOther grid points (bounded non-cycle):")
    for r in results:
        if r["verdict"] == "other":
            print(f"  beta={r['beta']:.3f}, etaL={r['eta_L']:.3f}, kappa={r['kappa']:.4f}, final={r['final']:.4f}")

    # Compare with claim
    print(f"\nClaim summary:")
    print(f"  cycling   : claim 8/100, observed {cls_count['cycling']}/{len(results)}")
    print(f"  period-2  : claim 19/100, observed {cls_count['period2']}/{len(results)}")
    print(f"  decay     : claim 73/100, observed {cls_count['decay']}/{len(results)}")
    print(f"  other     : observed {cls_count['other']}/{len(results)}")

    # Save
    with open(r"C:\Users\12729\Desktop\Math\workspace\active\li_xiao_directions\reaudit_task_1_4_results.json", "w") as fp:
        json.dump({"counts": cls_count, "results": results}, fp, indent=2)

if __name__ == "__main__":
    main()
