"""Task 3.1 + 3.2: verify period-2 attractor at the two anchors."""
import sys
import mpmath as mp
import json
from pathlib import Path

mp.mp.dps = 50

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
    Kn = len(vertices)
    inside = True
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
        diff = x - p
        dist2 = diff[0,0]**2 + diff[1,0]**2
        if best_d is None or dist2 < best_d:
            best_d = dist2; best_p = p
    return best_p

def shb_step(x_t, x_tm1, beta, eta, mu, vertices):
    Pc = project_to_polygon(x_t, vertices)
    g = mu * x_t + (L - mu) * Pc
    return x_t - eta * g + beta * (x_t - x_tm1)

def run_anchor(beta, eta_L, kappa, label, T=10000):
    print(f"\n{'='*70}", flush=True)
    print(f"  {label}: anchor (beta, eta L, kappa) = ({float(beta)}, {float(eta_L)}, {float(kappa)})", flush=True)
    print(f"  T = {T}, mpmath dps = {mp.mp.dps}, lambda = D/sqrt(2) = {float(LAMBDA):.10f}", flush=True)
    print('='*70, flush=True)
    mu = kappa * L
    eta = eta_L / L
    vertices = goujaud_polytope_vertices(beta, eta, mu)

    e0 = mp.matrix([[mp.mpf(1)], [mp.mpf(0)]])
    x_init = LAMBDA * e0
    x_tm1 = x_init.copy(); x_t = x_init.copy()
    xs = [(x_t[0,0], x_t[1,0])]
    norms = [mp.sqrt(x_t[0,0]**2 + x_t[1,0]**2)]

    for t in range(T):
        x_next = shb_step(x_t, x_tm1, beta, eta, mu, vertices)
        x_tm1 = x_t; x_t = x_next
        xs.append((x_t[0,0], x_t[1,0]))
        norms.append(mp.sqrt(x_t[0,0]**2 + x_t[1,0]**2))

    print("\nFirst 20 ||x_t||:", flush=True)
    for t in range(20):
        print(f"  t={t:2d}: {float(norms[t]):.10f}", flush=True)
    print("\nLast 20 ||x_t||:", flush=True)
    for t in range(T-19, T+1):
        print(f"  t={t:5d}: {float(norms[t]):.10f}", flush=True)

    last100 = [round(float(norms[t]), 10) for t in range(T-99, T+1)]
    distinct = sorted(set(last100))
    print(f"\nDistinct ||x_t|| values in last 100 steps: {len(distinct)}", flush=True)
    for v in distinct:
        print(f"   {v:.10f}", flush=True)

    # period detection
    print("\nPeriod detection (||x_T - x_{T-p}||):", flush=True)
    period_found = None
    for p in [1, 2, 3, 4, 5, 6]:
        x_T = xs[T]; x_Tmp = xs[T-p]
        diff = mp.sqrt((x_T[0]-x_Tmp[0])**2 + (x_T[1]-x_Tmp[1])**2)
        print(f"   p={p}: {float(diff):.3e}", flush=True)
        if period_found is None and float(diff) < 1e-30:
            period_found = p

    print(f"\nDetected period: {period_found}", flush=True)
    result = {"period": period_found}

    if period_found == 2:
        x_a = xs[T]; x_b = xs[T-1]
        n_a = float(mp.sqrt(x_a[0]**2 + x_a[1]**2))
        n_b = float(mp.sqrt(x_b[0]**2 + x_b[1]**2))
        print(f"\n*** PERIOD-2 CONFIRMED ***", flush=True)
        print(f"  x^a = ({float(x_a[0]):.12f}, {float(x_a[1]):.12f}), ||x^a||={n_a:.10f}", flush=True)
        print(f"  x^b = ({float(x_b[0]):.12f}, {float(x_b[1]):.12f}), ||x^b||={n_b:.10f}", flush=True)
        print(f"  ||x^a||/lambda = {n_a/float(LAMBDA):.6f}", flush=True)
        print(f"  ||x^b||/lambda = {n_b/float(LAMBDA):.6f}", flush=True)
        result["norms"] = (n_a, n_b)
        result["points"] = ((float(x_a[0]), float(x_a[1])), (float(x_b[0]), float(x_b[1])))
    elif period_found == 6:
        print(f"\n*** PERIOD-6 (visits 6 distinct points) ***", flush=True)
        norms6 = []
        for k in range(6):
            x_k = xs[T-k]
            n_k = float(mp.sqrt(x_k[0]**2 + x_k[1]**2))
            print(f"  x^{k} = ({float(x_k[0]):.12f}, {float(x_k[1]):.12f}), ||x^{k}||={n_k:.10f}", flush=True)
            norms6.append(n_k)
        result["norms6"] = norms6
    else:
        print(f"\nPeriod not in {{1..6}} or larger:", flush=True)
        max_tail = max(float(n) for n in norms[-100:])
        min_tail = min(float(n) for n in norms[-100:])
        print(f"  Max ||x|| (last 100): {max_tail:.6f}", flush=True)
        print(f"  Min ||x|| (last 100): {min_tail:.6f}", flush=True)
        result["max"] = max_tail; result["min"] = min_tail

    return result

def main():
    res_31 = run_anchor(mp.mpf("0.9"), mp.mpf("3.78"), mp.mpf("0.05"),
                        "Task 3.1", T=10000)
    res_32 = run_anchor(mp.mpf("0.95"), mp.mpf("3.85"), mp.mpf("0.10"),
                        "Task 3.2", T=10000)

    # Bias floor
    print(f"\n{'='*70}", flush=True)
    print(f"  Task 3.3: Bias bound for period-2 attractor", flush=True)
    print('='*70, flush=True)
    for label, kappa, res in [("(0.9, 3.78, 0.05)", 0.05, res_31),
                              ("(0.95, 3.85, 0.10)", 0.10, res_32)]:
        if res["period"] == 2:
            n_a, n_b = res["norms"]
            n_min = min(n_a, n_b)
            c = n_min  # since D=1
            bias_per_muD2 = 0.5 * n_min**2
            print(f"\n  {label}, kappa={kappa}:", flush=True)
            print(f"    ||x^a||={n_a:.6f}, ||x^b||={n_b:.6f}", flush=True)
            print(f"    min(||x_a||, ||x_b||) = {n_min:.6f}", flush=True)
            print(f"    c = ||x_min||/D = {c:.6f}", flush=True)
            print(f"    bias floor / (mu D^2) = c^2/2 = {bias_per_muD2:.6f}", flush=True)
            print(f"    Audit's claim: bias floor >= 0.37 mu D^2", flush=True)
            print(f"    -> {'VALID' if bias_per_muD2 >= 0.37 else 'NEEDS_CORRECTION'} (computed: {bias_per_muD2:.4f} mu D^2)", flush=True)
        else:
            print(f"\n  {label}: NOT period-2 ({res['period']}), skip", flush=True)

    out = Path(r"C:\Users\12729\Desktop\Math\workspace\active\li_xiao_directions\reaudit_period2_anchors.json")
    json_safe = {
        "task_31": {"period": res_31.get("period"),
                    "norms": res_31.get("norms"), "points": res_31.get("points"),
                    "norms6": res_31.get("norms6")},
        "task_32": {"period": res_32.get("period"),
                    "norms": res_32.get("norms"), "points": res_32.get("points"),
                    "norms6": res_32.get("norms6")},
    }
    with open(out, "w", encoding="utf-8") as fp:
        json.dump(json_safe, fp, indent=2, default=str)
    print(f"\nSaved -> {out}", flush=True)

if __name__ == "__main__":
    main()
