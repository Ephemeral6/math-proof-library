"""Task 3.4: Re-classify the 'other' grid points at T_long to distinguish slow decay vs period-2/period-K."""
import sys
import mpmath as mp
import json
from pathlib import Path

mp.mp.dps = 30  # less precision needed for classification

L = mp.mpf(1)
D = mp.mpf(1)
K = 3
theta_K = 2 * mp.pi / K
LAMBDA = D / mp.sqrt(2)

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
        v = M * e_t * LAMBDA
        vertices.append(v)
    return vertices

def project_to_polygon(x, vertices):
    Kn = len(vertices); inside = True
    for i in range(Kn):
        v_i = vertices[i]; v_next = vertices[(i+1) % Kn]
        e = v_next - v_i; d = x - v_i
        cross = e[0,0]*d[1,0] - e[1,0]*d[0,0]
        if cross < 0:
            inside = False; break
    if inside: return x
    best_d = None; best_p = None
    for i in range(Kn):
        v_i = vertices[i]; v_next = vertices[(i+1) % Kn]
        e = v_next - v_i; e_norm2 = e[0,0]**2 + e[1,0]**2
        if e_norm2 == 0: p = v_i
        else:
            d = x - v_i
            t = (d[0,0]*e[0,0] + d[1,0]*e[1,0]) / e_norm2
            t = max(mp.mpf(0), min(mp.mpf(1), t))
            p = v_i + e * t
        diff = x - p; dist2 = diff[0,0]**2 + diff[1,0]**2
        if best_d is None or dist2 < best_d:
            best_d = dist2; best_p = p
    return best_p

def shb_step(x_t, x_tm1, beta, eta, mu, vertices):
    Pc = project_to_polygon(x_t, vertices)
    g = mu * x_t + (L - mu) * Pc
    return x_t - eta * g + beta * (x_t - x_tm1)

def run_zero(beta, eta_L, mu, T):
    eta = eta_L / L
    vertices = goujaud_polytope_vertices(beta, eta, mu)
    e0 = mp.matrix([[mp.mpf(1)], [mp.mpf(0)]])
    x_init = LAMBDA * e0
    x_tm1 = x_init.copy(); x_t = x_init.copy()
    norms = [mp.sqrt(x_t[0,0]**2 + x_t[1,0]**2)]
    for _ in range(T):
        x_next = shb_step(x_t, x_tm1, beta, eta, mu, vertices)
        x_tm1 = x_t; x_t = x_next
        norms.append(mp.sqrt(x_t[0,0]**2 + x_t[1,0]**2))
    return x_t, norms

def main():
    grid_path = Path(r"C:\Users\12729\Desktop\Math\workspace\active\li_xiao_directions\zero_momentum_grid_results.json")
    with open(grid_path, "r", encoding="utf-8") as fp:
        grid = json.load(fp)
    n_total = len(grid)
    print(f"Total grid points: {n_total}", flush=True)

    others = [r for r in grid if r["verdict_zero"] not in ("cycling", "decay")]
    print(f"'Other' points (not classified as cycling/decay at T=2000): {len(others)}", flush=True)

    T_long = 8000  # Longer than the 2000 used originally; keeps total runtime manageable

    detail = []
    counts = {"period-2": 0, "period-3": 0, "period-6": 0, "decay": 0,
              "other-bounded": 0}

    for i, r in enumerate(others):
        beta = mp.mpf(r['beta']); eta_L = mp.mpf(r['eta_L']); kappa = mp.mpf(r['kappa'])
        mu = kappa * L
        try:
            x_T, norms = run_zero(beta, eta_L, mu, T_long)
        except Exception as e:
            print(f"  ERR ({float(beta)}, {float(eta_L)}, {float(kappa)}): {e}", flush=True)
            continue

        # Detect period via norms (check if norms[T] ~ norms[T-p])
        # We need positions; let's run again 6 more steps and remember the last 7 positions
        # For period detection use last few norms.
        last_norms = [float(norms[T_long - k]) for k in range(7)]
        max_tail = max(float(n) for n in norms[-100:])
        min_tail = min(float(n) for n in norms[-100:])

        # Period from norm-equality (approximate; for noise just use 1e-10)
        period_found = None
        for p in [1, 2, 3, 6]:
            ok = all(abs(last_norms[k] - last_norms[k+p]) < 1e-10 for k in range(7-p))
            if ok and not (p == 1 and abs(last_norms[0] - last_norms[1]) > 1e-10):
                period_found = p; break

        if max_tail < 1e-10:
            cat = "decay"
        elif period_found == 1:
            cat = "decay" if max_tail < 1e-3 else "fixed"
        elif period_found == 3:
            cat = "period-3"
        elif period_found == 2:
            cat = "period-2"
        elif period_found == 6:
            cat = "period-6"
        else:
            cat = "other-bounded" if max_tail > 1e-3 else "decay"
        counts[cat] = counts.get(cat, 0) + 1

        nT = float(mp.sqrt(x_T[0,0]**2 + x_T[1,0]**2))
        detail.append({"beta": float(beta), "eta_L": float(eta_L), "kappa": float(kappa),
                       "category": cat, "period": period_found,
                       "max_tail": max_tail, "min_tail": min_tail, "final_norm": nT})
        print(f"  [{i+1}/{len(others)}] beta={float(beta):.3f}, eta_L={float(eta_L):.4f}, "
              f"kappa={float(kappa):.4f}: period={period_found}, "
              f"range=[{min_tail:.4g},{max_tail:.4g}], cat={cat}", flush=True)

    print(f"\nRe-classification of {len(others)} 'other' points at T={T_long}:", flush=True)
    for k, v in counts.items():
        print(f"  {k}: {v}", flush=True)
    n_per2 = counts.get("period-2", 0)
    pct = 100 * n_per2 / n_total
    print(f"\nTRUE period-2 fraction: {n_per2}/{n_total} = {pct:.1f}%", flush=True)
    print(f"Audit claimed: 19% (in 'other' category)", flush=True)

    # Also count period-6 separately (which the reduction document discusses)
    n_per6 = counts.get("period-6", 0)
    print(f"Period-6 fraction: {n_per6}/{n_total} = {100*n_per6/n_total:.1f}%", flush=True)

    out = Path(r"C:\Users\12729\Desktop\Math\workspace\active\li_xiao_directions\reaudit_reclassify.json")
    with open(out, "w", encoding="utf-8") as fp:
        json.dump({"counts": counts, "detail": detail, "T_long": T_long, "n_total": n_total,
                   "period2_count": n_per2, "period2_pct": pct}, fp, indent=2, default=str)
    print(f"\nSaved -> {out}", flush=True)

if __name__ == "__main__":
    main()
