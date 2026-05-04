"""
Tasks 4.4 and 4.5: boundary points + precision sensitivity test.
"""

import mpmath as mp
import json
import time
from pathlib import Path

L_const_str = "1"; D_const_str = "1"; K = 3

def gamma_crit(beta):
    return 3 * (1 + beta + beta**2) / (1 + 2*beta)

def setup_problem():
    L = mp.mpf(L_const_str); D = mp.mpf(D_const_str)
    theta_K = 2 * mp.pi / K
    return L, D, theta_K

def goujaud_M(beta, eta, mu, theta_K, L):
    cos_t, sin_t = mp.cos(theta_K), mp.sin(theta_K)
    R_pos = mp.matrix([[cos_t, -sin_t], [sin_t, cos_t]])
    R_neg = mp.matrix([[cos_t, sin_t], [-sin_t, cos_t]])
    I2 = mp.matrix([[1, 0], [0, 1]])
    A = (1 + beta - mu*eta) * I2 - R_pos - beta * R_neg
    return A / ((L - mu) * eta)

def goujaud_polytope_vertices(beta, eta, mu, theta_K, L, D):
    M = goujaud_M(beta, eta, mu, theta_K, L)
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

def shb_step(x_t, x_tm1, beta, eta, mu, L_v, vertices):
    Pc = project_to_polygon(x_t, vertices)
    g = mu*x_t + (L_v-mu)*Pc
    return x_t - eta*g + beta*(x_t - x_tm1)

def feasible_kappa(beta, eta_L, L_v):
    eta = eta_L / L_v
    a = eta_L**2 - 2*eta_L*(1 + beta/2)
    b = -2*eta_L*(beta + mp.mpf(1)/2) + 3*(1 + beta + beta**2)
    if a > 0:
        kappa_max = -b/a
        if kappa_max <= 0: return None
        return min(kappa_max/2, mp.mpf("0.5"))
    elif a < 0:
        kappa_min = -b/a
        if kappa_min >= 1: return None
        return (kappa_min + 1)/2
    else:
        if b < 0: return mp.mpf("0.5")
        return None

def run_zero_init(beta_v, eta_L_v, kappa_v, T):
    L, D, theta_K = setup_problem()
    beta = mp.mpf(beta_v) if not isinstance(beta_v, mp.mpf) else beta_v
    eta_L = mp.mpf(eta_L_v) if not isinstance(eta_L_v, mp.mpf) else eta_L_v
    kappa = mp.mpf(kappa_v) if not isinstance(kappa_v, mp.mpf) else kappa_v
    eta = eta_L / L
    mu = kappa * L
    vertices = goujaud_polytope_vertices(beta, eta, mu, theta_K, L, D)
    e0 = mp.matrix([[mp.cos(mp.mpf(0))], [mp.sin(mp.mpf(0))]])
    R = D / mp.sqrt(2)
    x_init = R * e0
    x_tm1 = x_init.copy(); x_t = x_init.copy()
    for t in range(T):
        x_next = shb_step(x_t, x_tm1, beta, eta, mu, L, vertices)
        x_tm1 = x_t; x_t = x_next
    final = mp.sqrt(x_t[0,0]**2 + x_t[1,0]**2)
    return float(final), float(R)

def classify_strict(final, R, D_v=1.0):
    rel_diff = abs(final - R) / R
    if final < 1e-4 * D_v: return "decay", rel_diff
    if rel_diff < 0.01: return "cycling", rel_diff
    return "other", rel_diff

# ===========================================================================
# Task 4.4: edge of cycling region
# ===========================================================================

def task_4_4():
    print("\n" + "=" * 70)
    print("TASK 4.4 — Edge of cycling region")
    print("=" * 70)
    mp.mp.dps = 100
    edge_points = [
        ("(beta=0.7, etaL=3.4) [upper stab=3.4]", 0.7, 3.4),
        ("(beta=0.8, etaL=3.6) [upper stab=3.6]", 0.8, 3.6),
        ("(beta=0.65, etaL=3.0) [just below 0.7]", 0.65, 3.0),
    ]
    results = []
    for label, b_v, el_v in edge_points:
        beta = mp.mpf(str(b_v))
        eta_L = mp.mpf(str(el_v))
        gc = float(gamma_crit(beta))
        eta_max = 2*(1 + b_v)
        # Check feasibility
        if el_v >= eta_max or el_v <= gc:
            print(f"  {label}: NOT in stability strip ({gc:.4f}, {eta_max:.4f}). Skipping classification but running anyway.")
        # Pick kappa
        L_v = mp.mpf(1)
        kappa = feasible_kappa(beta, eta_L, L_v)
        if kappa is None:
            # use kappa = 0.3 fallback
            kappa = mp.mpf("0.3")
        T = 10000
        final, R = run_zero_init(beta, eta_L, kappa, T)
        cls, rel = classify_strict(final, R)
        print(f"  {label}: kappa={float(kappa):.4f}, final={final:.5e}, target_R={R:.4f}, rel_diff={rel:.4e} -> {cls}")
        results.append({
            "label": label, "beta": b_v, "eta_L": el_v,
            "kappa": float(kappa), "T": T,
            "final": final, "rel_diff": rel, "classification": cls,
            "stability_strip": (gc, eta_max),
        })
    return results

# ===========================================================================
# Task 4.5: precision sensitivity
# ===========================================================================

def task_4_5():
    print("\n" + "=" * 70)
    print("TASK 4.5 — Precision sensitivity at boundary point")
    print("=" * 70)
    # Pick a boundary point: just BELOW the cycling region.
    # Original 8 cycling points start at beta=0.8, etaL=3.090 (the 4th eta step).
    # The 3rd eta step at beta=0.8 (etaL=3.0115, kappa~0.4032) was "decay".
    # Let's pick (beta=0.8, etaL=3.0115). Actually let's be smarter and use
    # exactly the value where we expect ambiguity: beta=0.8, etaL=3.05.
    beta_v = 0.8
    eta_L_v = 3.05
    print(f"Boundary point: beta={beta_v}, etaL={eta_L_v}")
    L_v = mp.mpf(1)
    results = []
    for dps in [20, 50, 100, 200]:
        mp.mp.dps = dps
        beta = mp.mpf(str(beta_v))
        eta_L = mp.mpf(str(eta_L_v))
        kappa = feasible_kappa(beta, eta_L, L_v)
        if kappa is None:
            print(f"  dps={dps}: infeasible kappa, skipping")
            continue
        T = 10000
        final, R = run_zero_init(beta, eta_L, kappa, T)
        cls, rel = classify_strict(final, R)
        print(f"  dps={dps:3d}: kappa={float(kappa):.6f}, final={final:.5e}, rel_diff={rel:.4e} -> {cls}")
        results.append({
            "dps": dps, "beta": beta_v, "eta_L": eta_L_v,
            "kappa": float(kappa), "T": T,
            "final": final, "rel_diff": rel, "classification": cls,
        })
    return results

def main():
    t0 = time.time()
    r44 = task_4_4()
    r45 = task_4_5()
    out = Path(r"C:\Users\12729\Desktop\Math\workspace\active\li_xiao_directions\reaudit_boundary_precision_results.json")
    with open(out, "w", encoding="utf-8") as fp:
        json.dump({"task_4_4": r44, "task_4_5": r45}, fp, indent=2)
    print(f"\nElapsed: {time.time()-t0:.1f}s. Saved to {out}")

if __name__ == "__main__":
    main()
