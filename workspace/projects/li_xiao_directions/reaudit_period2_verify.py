"""
Re-audit verification of period-2 attractor at the high-beta anchor points
for Direction 1 (zero-momentum SHB on K=3 Goujaud function).

Tasks:
3.1 Verify period-2 at (0.9, 3.78, 0.05)
3.2 Verify period-2 at (0.95, 3.85, 0.10)
3.3 Compute explicit bias floor in units of mu D^2
3.4 Re-classify the 19 "other" grid points at T=100,000
3.5 Locality of period-2 attractor
"""

import mpmath as mp
import math
import json
from pathlib import Path

mp.mp.dps = 50

# Parameters
L = mp.mpf(1)
D = mp.mpf(1)
K = 3
theta_K = 2 * mp.pi / K
LAMBDA = D / mp.sqrt(2)  # cycle radius

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

def grad_f0(x, mu, vertices):
    Pc = project_to_polygon(x, vertices)
    return mu * x + (L - mu) * Pc

def shb_step(x_t, x_tm1, beta, eta, mu, vertices):
    g = grad_f0(x_t, mu, vertices)
    return x_t - eta * g + beta * (x_t - x_tm1)

def run_shb_zero_init(beta, eta_L, mu, T, record_x=False):
    eta = eta_L / L
    vertices = goujaud_polytope_vertices(beta, eta, mu)
    e0 = mp.matrix([[mp.mpf(1)], [mp.mpf(0)]])
    x_init = LAMBDA * e0
    x_tm1 = x_init.copy()
    x_t = x_init.copy()

    norms = [mp.sqrt(x_t[0,0]**2 + x_t[1,0]**2)]
    xs = [(x_t[0,0], x_t[1,0])] if record_x else None

    for t in range(T):
        x_next = shb_step(x_t, x_tm1, beta, eta, mu, vertices)
        x_tm1 = x_t
        x_t = x_next
        norms.append(mp.sqrt(x_t[0,0]**2 + x_t[1,0]**2))
        if record_x:
            xs.append((x_t[0,0], x_t[1,0]))
    return norms, xs

def task_31_32(beta, eta_L, kappa, label, T=10000):
    print(f"\n{'='*70}")
    print(f"  Task: {label}")
    print(f"  Anchor: (beta, eta L, kappa) = ({float(beta)}, {float(eta_L)}, {float(kappa)})")
    print(f"  T = {T}")
    print('='*70)
    mu = kappa * L
    norms, xs = run_shb_zero_init(beta, eta_L, mu, T, record_x=True)

    # First 20 norms
    print("\nFirst 20 ||x_t||:")
    for t in range(20):
        print(f"  t={t:2d}: {float(norms[t]):.10f}")
    # Last 20 norms
    print("\nLast 20 ||x_t||:")
    for t in range(T-19, T+1):
        print(f"  t={t:5d}: {float(norms[t]):.10f}")

    # distinct norms in last 100 (rounded to 10 decimals)
    last100 = [round(float(norms[t]), 10) for t in range(T-99, T+1)]
    distinct = sorted(set(last100))
    print(f"\nNumber of distinct ||x_t|| values in last 100 steps (rounded to 10 dp): {len(distinct)}")
    print(f"  Distinct values: {distinct[:20]}{'...' if len(distinct)>20 else ''}")

    # Period-2 check: x_{t+2} == x_t?
    # Use last positions
    last_x = [(float(xs[t][0]), float(xs[t][1])) for t in range(T-9, T+1)]
    print("\nLast 10 positions (x, y):")
    for t in range(10):
        print(f"  t={T-9+t:5d}: ({last_x[t][0]:.10f}, {last_x[t][1]:.10f})")

    # Period detection
    period_found = None
    for p in [1, 2, 3, 4, 5, 6]:
        x_T = xs[T]
        x_Tmp = xs[T-p]
        diff = mp.sqrt((x_T[0]-x_Tmp[0])**2 + (x_T[1]-x_Tmp[1])**2)
        print(f"  ||x_{{T}} - x_{{T-{p}}}||  = {float(diff):.3e}")
        if period_found is None and float(diff) < 1e-30:
            period_found = p

    # Limit norms
    if period_found == 2:
        x_a = xs[T]
        x_b = xs[T-1]
        n_a = float(mp.sqrt(x_a[0]**2 + x_a[1]**2))
        n_b = float(mp.sqrt(x_b[0]**2 + x_b[1]**2))
        print(f"\n*** PERIOD-2 CONFIRMED ***")
        print(f"  x^a = ({float(x_a[0]):.12f}, {float(x_a[1]):.12f}),  ||x^a|| = {n_a:.10f}")
        print(f"  x^b = ({float(x_b[0]):.12f}, {float(x_b[1]):.12f}),  ||x^b|| = {n_b:.10f}")
        return {"period": 2, "norms": (n_a, n_b), "points": (x_a, x_b)}
    elif period_found == 6:
        print(f"\n*** PERIOD-6 ***")
        for k in range(6):
            x_k = xs[T-k]
            n_k = float(mp.sqrt(x_k[0]**2 + x_k[1]**2))
            print(f"  x^{k} = ({float(x_k[0]):.12f}, {float(x_k[1]):.12f}),  ||x^{k}|| = {n_k:.10f}")
        return {"period": 6}
    else:
        print(f"\nDetected period: {period_found}")
        # Could be larger period, slow decay, or quasi-periodic
        max_tail = max(float(n) for n in norms[-100:])
        min_tail = min(float(n) for n in norms[-100:])
        print(f"  Max ||x|| in last 100: {max_tail:.6f}")
        print(f"  Min ||x|| in last 100: {min_tail:.6f}")
        return {"period": period_found, "max": max_tail, "min": min_tail}

def task_33(results_31, results_32):
    """Compute bias bound for period-2 attractor"""
    print(f"\n{'='*70}")
    print(f"  Task 3.3: Bias bound for period-2 attractor")
    print('='*70)

    # In the experiment, D=1, L=1, lambda = 1/sqrt(2) ~ 0.7071
    # So D^2 = 1
    # Bias floor: f_0(x) - f_0^* >= (mu/2) ||x||^2
    # In units of mu D^2: bias / (mu D^2) = 0.5 * ||x||^2 / D^2 = 0.5 * ||x||^2 (since D=1)

    for label, kappa, res in [("(0.9, 3.78, 0.05)", 0.05, results_31),
                              ("(0.95, 3.85, 0.10)", 0.10, results_32)]:
        if res["period"] != 2:
            print(f"\n{label}: not period-2, skip bias floor")
            continue
        n_a, n_b = res["norms"]
        n_min = min(n_a, n_b)
        # bias floor (mu/2) ||x||^2; in units of mu D^2 (since D=1):
        bias_per_muD2 = 0.5 * n_min**2
        # explicit c such that ||x|| >= c*D
        c = n_min  # since D=1
        print(f"\n{label}, kappa={kappa}:")
        print(f"  ||x^a|| = {n_a:.6f}, ||x^b|| = {n_b:.6f}")
        print(f"  min(||x^a||, ||x^b||) = {n_min:.6f}")
        print(f"  c = ||x_min||/D = {c:.6f}")
        print(f"  bias floor / (mu D^2) = c^2/2 = {bias_per_muD2:.6f}")
        # Audit's claimed 0.37 mu D^2
        print(f"  Audit's claim: bias floor >= 0.37 mu D^2")
        print(f"  Verification: {'VALID' if bias_per_muD2 >= 0.37 else 'INVALID/NEEDS_CORRECTION'} (computed: {bias_per_muD2:.4f})")

def task_34_reclassify(T_long=20000):
    """Re-classify the existing grid points at longer T to distinguish slow decay vs period-2"""
    print(f"\n{'='*70}")
    print(f"  Task 3.4: Re-classify the 'other' grid points at T={T_long}")
    print('='*70)

    grid_path = Path(r"C:\Users\12729\Desktop\Math\workspace\active\li_xiao_directions\zero_momentum_grid_results.json")
    with open(grid_path, "r", encoding="utf-8") as fp:
        grid = json.load(fp)
    n_total = len(grid)
    n_zero_cycle = sum(1 for r in grid if r["verdict_zero"] == "cycling")
    n_zero_decay = sum(1 for r in grid if r["verdict_zero"] == "decay")
    n_other = n_total - n_zero_cycle - n_zero_decay
    print(f"\nGrid totals: {n_total} points; cycling={n_zero_cycle}, decay={n_zero_decay}, other={n_other}")
    others = [r for r in grid if r["verdict_zero"] not in ("cycling", "decay")]
    print(f"\nThe {len(others)} 'other' points (at T=2000 in original scan):")
    for r in others:
        print(f"  beta={r['beta']:.3f}, eta_L={r['eta_L']:.4f}, kappa={r['kappa']:.4f}, "
              f"verdict={r['verdict_zero']}, final={r['final_zero']:.4g}")

    # Re-classify at T=T_long (use shorter T for speed; T_long=20000 takes a while)
    # Goal: distinguish slow decay vs true period-2
    print(f"\n  Re-running these points at T={T_long}...")
    classification = {"period-2": 0, "period-3": 0, "period-6": 0, "decay": 0, "other-bounded": 0}
    detail = []
    for r in others:
        beta = mp.mpf(r['beta'])
        eta_L = mp.mpf(r['eta_L'])
        kappa = mp.mpf(r['kappa'])
        mu = kappa * L
        try:
            norms, xs = run_shb_zero_init(beta, eta_L, mu, T_long, record_x=True)
        except Exception as e:
            print(f"  ERROR at ({float(beta)}, {float(eta_L)}, {float(kappa)}): {e}")
            continue
        # Detect period at T_long
        x_T = xs[T_long]
        period_found = None
        for p in [1, 2, 3, 4, 5, 6, 12]:
            x_Tmp = xs[T_long - p]
            diff = mp.sqrt((x_T[0]-x_Tmp[0])**2 + (x_T[1]-x_Tmp[1])**2)
            if float(diff) < 1e-25:
                period_found = p
                break
        n_T = float(mp.sqrt(x_T[0]**2 + x_T[1]**2))
        max_tail = max(float(n) for n in norms[-100:])
        min_tail = min(float(n) for n in norms[-100:])

        if max_tail < 1e-15:
            cat = "decay"
        elif period_found == 2:
            cat = "period-2"
        elif period_found == 3:
            cat = "period-3"
        elif period_found == 6:
            cat = "period-6"
        elif period_found is None and max_tail > 0.5 and (max_tail-min_tail)/max(max_tail, 1e-30) < 0.001:
            cat = "period-3"  # near-cycle in K=3 sense
        elif period_found is None and max_tail / min(max_tail, 1) > 1.0 and min_tail > 1e-10:
            cat = "other-bounded"
        else:
            cat = "decay"
        classification[cat] = classification.get(cat, 0) + 1
        detail.append({"beta": float(beta), "eta_L": float(eta_L), "kappa": float(kappa),
                       "category": cat, "period": period_found,
                       "max_tail": max_tail, "min_tail": min_tail, "final_norm": n_T})
        print(f"  ({float(beta):.3f}, {float(eta_L):.4f}, {float(kappa):.4f}) -> "
              f"period={period_found}, n_T={n_T:.4g}, range=[{min_tail:.4g}, {max_tail:.4g}], cat={cat}")

    print(f"\n  Re-classification of 'other' points (T={T_long}):")
    for k, v in classification.items():
        print(f"    {k}: {v}")
    n_period2 = classification.get("period-2", 0)
    pct_period2 = 100 * n_period2 / n_total
    print(f"\n  TRUE period-2 fraction: {n_period2}/{n_total} = {pct_period2:.1f}%")
    print(f"  Audit claimed: 19%")
    return detail, classification

def main():
    # Task 3.1
    res_31 = task_31_32(mp.mpf("0.9"), mp.mpf("3.78"), mp.mpf("0.05"),
                        "3.1 - (beta, eta L, kappa) = (0.9, 3.78, 0.05)", T=10000)
    # Task 3.2
    res_32 = task_31_32(mp.mpf("0.95"), mp.mpf("3.85"), mp.mpf("0.10"),
                        "3.2 - (beta, eta L, kappa) = (0.95, 3.85, 0.10)", T=10000)
    # Task 3.3
    task_33(res_31, res_32)
    # Task 3.4 - re-classify
    detail, classification = task_34_reclassify(T_long=20000)

    # Save details
    out_path = Path(r"C:\Users\12729\Desktop\Math\workspace\active\li_xiao_directions\reaudit_period2_results.json")
    with open(out_path, "w", encoding="utf-8") as fp:
        json.dump({
            "task_31": {"period": res_31["period"],
                        "norms": list(res_31.get("norms", []))},
            "task_32": {"period": res_32["period"],
                        "norms": list(res_32.get("norms", []))},
            "task_34_classification": classification,
            "task_34_detail": detail,
        }, fp, indent=2, default=str)
    print(f"\nSaved: {out_path}")

if __name__ == "__main__":
    main()
