"""
Direction 1 numerical experiment: Zero-momentum (x_0 = x_{-1}) cycling in Goujaud F.

Setup:
  Goujaud K=3 hard instance: f_0(x) = (L/2)|x|^2 - ((L-mu)/2) d_{conv(P)}(x)^2
  with cycle-radius D/sqrt(2) on a regular K-gon.
  Standard OP-2 init: x_0 = (D/sqrt 2) e_0,  x_{-1} = (D/sqrt 2) e_{K-1}
  ZERO-momentum  init: x_0 = (D/sqrt 2) e_0,  x_{-1} = (D/sqrt 2) e_0   (so x_0 = x_{-1})

For each (beta, eta L) in F (the K=3 feasibility region), run T=10,000 SHB steps
under zero-momentum init and classify the orbit:
  - "cycling": ||x_t|| stays close to D/sqrt 2 with small variation, picks up the K-cycle
  - "decay":   ||x_t|| -> 0
  - "diverge": ||x_t|| -> infinity (shouldn't happen in S, but check)

Use mpmath at 50-digit precision throughout (no rounding artefacts).
Also compute the characteristic-polynomial roots r_1, r_2 for each lambda eigenvalue
to diagnose under-damped vs over-damped, plus the slow-mode amplitude A_mu under
zero-momentum init (vs OP-2 init).
"""

import mpmath as mp
import math
import json
from pathlib import Path

mp.mp.dps = 50  # 50-digit precision

# Parameters
L = mp.mpf(1)
D = mp.mpf(1)
K = 3
theta_K = 2 * mp.pi / K  # 2pi/3
c_K = mp.cos(theta_K)    # -1/2

# F_{K=3} feasibility region (sufficient): beta > beta_star, eta L in (gamma_crit(beta), 2(1+beta))
beta_star = (mp.sqrt(13) - 3) / 2  # ~0.3028

def gamma_crit(beta):
    return 3 * (1 + beta + beta**2) / (1 + 2*beta)

def goujaud_M(beta, eta, mu):
    """Goujaud's matrix M = ((1+beta-mu*eta) I - R_theta_K - beta R_-theta_K) / ((L-mu) eta)"""
    cos_t, sin_t = mp.cos(theta_K), mp.sin(theta_K)
    R_pos = mp.matrix([[cos_t, -sin_t], [sin_t, cos_t]])
    R_neg = mp.matrix([[cos_t, sin_t], [-sin_t, cos_t]])
    I2 = mp.matrix([[1, 0], [0, 1]])
    A = (1 + beta - mu*eta) * I2 - R_pos - beta * R_neg
    return A / ((L - mu) * eta)

def feasible_kappa(beta, eta_L):
    """
    Find a feasible kappa = mu/L in (0,1) for which the cycling inequality holds.
    Use bisection on the quadratic in kappa from (star_3):
       h^2 - 2[(beta+1/2) + kappa(1+beta/2)] h + 3 kappa (1+beta+beta^2) <= 0
    where h = kappa * eta_L.
    Return midpoint of feasible interval, or None.
    """
    eta = eta_L / L
    # The quadratic in h: h^2 - 2*A(kappa)*h + B(kappa) <= 0, with
    # A(kappa) = (beta + 1/2) + kappa*(1 + beta/2)
    # B(kappa) = 3 kappa (1 + beta + beta^2)
    # Discriminant: A^2 >= B
    # Substitute h = kappa * eta_L:
    # (kappa eta_L)^2 - 2 A(kappa) kappa eta_L + B(kappa) <= 0
    # i.e., kappa^2 eta_L^2 - 2 kappa eta_L [(beta+1/2) + kappa(1+beta/2)] + 3 kappa (1+beta+beta^2) <= 0
    # Expand: kappa^2 [eta_L^2 - 2 eta_L (1+beta/2)] + kappa [-2 eta_L (beta+1/2) + 3(1+beta+beta^2)] <= 0
    # Quadratic in kappa: a*kappa^2 + b*kappa <= 0 with kappa > 0 means a*kappa + b <= 0
    a = eta_L**2 - 2*eta_L*(1 + beta/2)
    b = -2*eta_L*(beta + mp.mpf(1)/2) + 3*(1 + beta + beta**2)
    # a kappa + b <= 0 => kappa <= -b/a (if a > 0) or kappa >= -b/a (if a < 0).
    # We need kappa in (0,1).
    if a > 0:
        kappa_max = -b/a
        if kappa_max <= 0:
            return None
        return min(kappa_max/2, mp.mpf("0.5"))  # midpoint or 0.5
    elif a < 0:
        kappa_min = -b/a
        if kappa_min >= 1:
            return None
        return (kappa_min + 1)/2
    else:  # a == 0
        if b < 0:
            return mp.mpf("0.5")
        return None

def char_roots(beta, eta, lam):
    """Roots of r^2 - (1 + beta - eta lam) r + beta = 0"""
    a1 = 1 + beta - eta*lam
    disc = a1**2 - 4*beta
    if disc >= 0:
        s = mp.sqrt(disc)
        return (a1 + s)/2, (a1 - s)/2
    else:
        s = mp.sqrt(-disc)
        return mp.mpc(a1/2, s/2), mp.mpc(a1/2, -s/2)

def goujaud_polytope_vertices(beta, eta, mu):
    """Compute the K vertices Me_t of the rescaled polytope (D/sqrt 2) M e_t."""
    M = goujaud_M(beta, eta, mu)
    vertices = []
    for t in range(K):
        angle = t * theta_K
        e_t = mp.matrix([[mp.cos(angle)], [mp.sin(angle)]])
        v = M * e_t * (D / mp.sqrt(2))
        vertices.append(v)
    return vertices

def project_to_polygon(x, vertices):
    """Project x onto convex hull of polygon vertices (2D K-gon).
    For a regular K-gon centered at origin, project onto each edge,
    take the closest point inside or on boundary.
    """
    # Convex K-gon with K vertices in CCW order.
    # Approach: for each edge (v_i, v_{i+1}), project x onto the line segment.
    # Then check if x is inside the polygon (then projection = x).
    # Take the closest of: x (if inside) or closest segment projection.

    # First check if inside: for a CCW convex polygon, point is inside iff it lies
    # on the left of every edge. For our K-gon with vertices at angles theta_K * t,
    # the centered K-gon contains origin in its interior.

    # Inside test: For each edge (v_i, v_{i+1}), check if (v_{i+1} - v_i) x (x - v_i) >= 0.
    Kn = len(vertices)
    inside = True
    for i in range(Kn):
        v_i = vertices[i]
        v_next = vertices[(i+1) % Kn]
        # 2D cross product
        e = v_next - v_i
        d = x - v_i
        cross = e[0,0]*d[1,0] - e[1,0]*d[0,0]
        if cross < 0:  # to the right of edge => outside (assuming CCW)
            inside = False
            break
    if inside:
        return x
    # Else: find closest point on boundary
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
    """Gradient of rescaled Goujaud f_0(x) = (L/2)|x|^2 - ((L-mu)/2) d_C(x)^2.
       grad f_0(x) = mu*x + (L-mu) * P_C(x)
    """
    Pc = project_to_polygon(x, vertices)
    return mu * x + (L - mu) * Pc

def shb_step(x_t, x_tm1, beta, eta, mu, vertices):
    """One SHB iteration on f_0 (deterministic; for Direction 1 cycling check)."""
    g = grad_f0(x_t, beta, eta, mu, vertices)
    return x_t - eta * g + beta * (x_t - x_tm1)

def run_shb_zero_init(beta, eta_L, mu, T):
    """Run SHB on f_0 for T steps with x_0 = x_{-1} = (D/sqrt 2) e_0 (zero-momentum init)."""
    eta = eta_L / L
    vertices = goujaud_polytope_vertices(beta, eta, mu)

    e0 = mp.matrix([[mp.cos(mp.mpf(0))], [mp.sin(mp.mpf(0))]])
    R = D / mp.sqrt(2)
    x_init = R * e0

    x_tm1 = x_init.copy()  # x_{-1} = x_0  ZERO MOMENTUM
    x_t = x_init.copy()    # x_0

    norms = []
    norms.append(mp.sqrt(x_t[0,0]**2 + x_t[1,0]**2))

    for t in range(T):
        x_next = shb_step(x_t, x_tm1, beta, eta, mu, vertices)
        x_tm1 = x_t
        x_t = x_next
        norms.append(mp.sqrt(x_t[0,0]**2 + x_t[1,0]**2))

    return norms

def run_shb_op2_init(beta, eta_L, mu, T):
    """Run SHB on f_0 with OP-2 init: x_0 = R e_0, x_{-1} = R e_{K-1}."""
    eta = eta_L / L
    vertices = goujaud_polytope_vertices(beta, eta, mu)

    e0 = mp.matrix([[mp.cos(mp.mpf(0))], [mp.sin(mp.mpf(0))]])
    eKm1 = mp.matrix([[mp.cos((K-1)*theta_K)], [mp.sin((K-1)*theta_K)]])
    R = D / mp.sqrt(2)

    x_tm1 = R * eKm1
    x_t = R * e0

    norms = []
    norms.append(mp.sqrt(x_t[0,0]**2 + x_t[1,0]**2))

    for t in range(T):
        x_next = shb_step(x_t, x_tm1, beta, eta, mu, vertices)
        x_tm1 = x_t
        x_t = x_next
        norms.append(mp.sqrt(x_t[0,0]**2 + x_t[1,0]**2))

    return norms

def classify_orbit(norms, target_R):
    """Classify orbit:
       - cycling: final norms stay near target_R (relative deviation < 0.05)
       - decay:   final norm < 0.05 * target_R
       - diverge: final norm > 100 * target_R
       - other:   anything else
    """
    final = float(norms[-1])
    target = float(target_R)

    # Look at last 1000 entries (or all if fewer)
    tail = norms[-min(len(norms), 1000):]
    tail_floats = [float(n) for n in tail]

    if max(tail_floats) > 100 * target:
        return "diverge", final
    if max(tail_floats) < 0.05 * target:
        return "decay", final

    # Compute mean and std of tail norms
    mean_tail = sum(tail_floats) / len(tail_floats)
    var_tail = sum((x - mean_tail)**2 for x in tail_floats) / len(tail_floats)
    std_tail = math.sqrt(var_tail)

    if abs(mean_tail - target) / target < 0.10 and std_tail / target < 0.15:
        return "cycling", final

    if mean_tail < 0.5 * target and std_tail / max(mean_tail, 1e-30) < 0.5:
        return "decay", final

    return "other", final

def main():
    results = []
    target_R = float(D / mp.sqrt(2))

    # Build a 100-point grid in F_{K=3}
    # beta in (beta_star, 0.99), eta_L in (gamma_crit(beta), 2(1+beta))
    # Use ~10 betas x 10 eta_Ls
    beta_grid = [mp.mpf(b) for b in [0.31, 0.35, 0.40, 0.45, 0.50, 0.60, 0.70, 0.80, 0.90, 0.95]]
    eta_steps_per_beta = 10

    print(f"# Zero-Momentum Grid Scan (mpmath, dps=50)")
    print(f"# K={K}, beta_star = {float(beta_star):.6f}")
    print(f"# Target cycle radius R = D/sqrt(2) = {target_R:.6f}")
    print()
    print(f"{'beta':>6} {'eta_L':>7} {'kappa':>8} {'verdict_zero':>14} {'final_zero':>12} {'verdict_op2':>14} {'final_op2':>12} {'r1_mu':>10} {'r2_mu':>10} {'r1_L':>10}")

    for beta in beta_grid:
        gc = gamma_crit(beta)
        eta_max = 2 * (1 + beta)
        if eta_max <= gc:
            continue
        for j in range(eta_steps_per_beta):
            t_frac = mp.mpf(j + 0.5) / eta_steps_per_beta
            eta_L = gc + t_frac * (eta_max - gc)

            kappa = feasible_kappa(beta, eta_L)
            if kappa is None:
                continue
            mu = kappa * L
            eta = eta_L / L

            # Run T=2000 (mpmath is slow); enough to see attractor
            T = 2000
            norms_zero = run_shb_zero_init(beta, eta_L, mu, T)
            norms_op2  = run_shb_op2_init(beta, eta_L, mu, T)

            v_zero, f_zero = classify_orbit(norms_zero, D/mp.sqrt(2))
            v_op2,  f_op2  = classify_orbit(norms_op2,  D/mp.sqrt(2))

            # Char roots for diagnostic
            r1_mu, r2_mu = char_roots(beta, eta, mu)
            r1_L, r2_L = char_roots(beta, eta, L)

            def r_str(z):
                if isinstance(z, mp.mpc):
                    return f"|{float(abs(z)):.4f}|"
                return f"{float(z):.4f}"

            print(f"{float(beta):6.3f} {float(eta_L):7.3f} {float(kappa):8.4f} {v_zero:>14s} {f_zero:12.5g} {v_op2:>14s} {f_op2:12.5g} {r_str(r1_mu):>10s} {r_str(r2_mu):>10s} {r_str(r1_L):>10s}")

            results.append({
                "beta": float(beta),
                "eta_L": float(eta_L),
                "kappa": float(kappa),
                "verdict_zero": v_zero,
                "final_zero": f_zero,
                "verdict_op2": v_op2,
                "final_op2": f_op2,
                "r1_mu_abs": float(abs(r1_mu)),
                "r2_mu_abs": float(abs(r2_mu)),
                "r1_L_abs": float(abs(r1_L)),
                "r2_L_abs": float(abs(r2_L)),
                "r1_mu_complex": isinstance(r1_mu, mp.mpc),
                "r1_L_complex": isinstance(r1_L, mp.mpc),
            })

    # Save JSON
    out_path = Path(r"C:\Users\12729\Desktop\Math\workspace\active\li_xiao_directions\zero_momentum_grid_results.json")
    with open(out_path, "w", encoding="utf-8") as fp:
        json.dump(results, fp, indent=2)
    print(f"\nSaved {len(results)} grid points to {out_path}")

    # Summary
    n_total = len(results)
    n_zero_cycle = sum(1 for r in results if r["verdict_zero"] == "cycling")
    n_zero_decay = sum(1 for r in results if r["verdict_zero"] == "decay")
    n_zero_other = n_total - n_zero_cycle - n_zero_decay
    n_op2_cycle = sum(1 for r in results if r["verdict_op2"] == "cycling")

    print(f"\n=== SUMMARY ===")
    print(f"Total grid points in F_{{K=3}}: {n_total}")
    print(f"OP-2 init  cycling:      {n_op2_cycle}/{n_total}")
    print(f"Zero-init  cycling:      {n_zero_cycle}/{n_total}  <-- KEY METRIC")
    print(f"Zero-init  decay:        {n_zero_decay}/{n_total}")
    print(f"Zero-init  other:        {n_zero_other}/{n_total}")

    # Pattern: which (beta, eta_L) give zero-init cycling?
    print(f"\nGrid points where zero-momentum init STILL cycles:")
    print(f"{'beta':>6} {'eta_L':>7} {'kappa':>8} {'r1_mu_complex':>14}")
    for r in results:
        if r["verdict_zero"] == "cycling":
            print(f"{r['beta']:6.3f} {r['eta_L']:7.3f} {r['kappa']:8.4f} {str(r['r1_mu_complex']):>14}")

    print(f"\nGrid points where zero-momentum init DECAYS (LB fails):")
    print(f"{'beta':>6} {'eta_L':>7} {'kappa':>8} {'r1_mu_complex':>14}")
    for r in results:
        if r["verdict_zero"] == "decay":
            print(f"{r['beta']:6.3f} {r['eta_L']:7.3f} {r['kappa']:8.4f} {str(r['r1_mu_complex']):>14}")

if __name__ == "__main__":
    main()
