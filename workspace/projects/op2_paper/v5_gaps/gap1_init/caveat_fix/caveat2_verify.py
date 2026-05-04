"""
Caveat 2 verification — rigorous stochastic gradient-floor theorem.

Theorem (rigorous, no empirical input):
  For SHB on the Goujaud K=3 polytope-Moreau function f_0 (μ-strongly convex,
  L-smooth, minimum at x* = 0) with i.i.d. Gaussian gradient noise
  ξ_t ~ N(0, σ² I_2) (σ > 0):
    E[‖∇f_0(x_T)‖²] ≥ 2 μ² η² σ²    for all T ≥ 1.

Proof chain:
  (a) PL inequality + strong convexity ⇒ ‖∇f_0(x)‖² ≥ μ²‖x − x*‖² (textbook).
  (b) x_T conditional on F_{T-1} has variance η²σ²·I_2 along each component
      (since x_T = m_T - ησ z_{T-1} with z_{T-1} ⊥ F_{T-1}).
      Hence Var(x_T) ≥ tr(η²σ²·I_2) = 2η²σ², so E[‖x_T - x*‖²] ≥ 2η²σ².
  (c) Combine (a) and (b): E[‖∇f_0(x_T)‖²] ≥ μ² · 2η²σ² = 2μ²η²σ².

This script verifies the chain numerically:
  (V1) Sanity: ‖∇f_0(x)‖² / ‖x‖² ≥ μ² over a random sample of x ∈ R².
  (V2) E[‖x_T‖²] ≥ 2η²σ² (Monte Carlo, 200 samples × T=10000).
  (V3) E[‖∇f_0(x_T)‖²] ≥ 2μ²η²σ² (same MC).
  (V4) Conditional theorem comparison (using empirical E[‖x_T‖²] in place
       of the rigorous floor 2η²σ²).
"""

import json
import sys
import time
from pathlib import Path

import numpy as np


sys.stdout.reconfigure(line_buffering=True)
HERE = Path(__file__).parent

L_val = 1.0
D_val = 1.0
lam_val = D_val / np.sqrt(2)


def e_vec(t):
    ang = 2 * np.pi * (t % 3) / 3.0
    return np.array([np.cos(ang), np.sin(ang)])


def Rmat(theta):
    c, s = np.cos(theta), np.sin(theta)
    return np.array([[c, -s], [s, c]])


def goujaud_vertices(beta, eta, mu):
    theta3 = 2 * np.pi / 3
    I2 = np.eye(2)
    R_pos = Rmat(theta3)
    R_neg = Rmat(-theta3)
    A = (1 + beta - mu * eta) * I2 - R_pos - beta * R_neg
    M = A / ((L_val - mu) * eta)
    return [lam_val * (M @ e_vec(t)) for t in range(3)]


def project_triangle(x, verts):
    v0, v1, v2 = verts

    def signed_area(a, b, c):
        return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])

    A = signed_area(v0, v1, v2)
    s1 = signed_area(v0, v1, x) / A
    s2 = signed_area(v1, v2, x) / A
    s3 = signed_area(v2, v0, x) / A
    if s1 >= 0 and s2 >= 0 and s3 >= 0:
        return x.copy()

    best_d2, best_p = None, None
    for (a, b) in [(v0, v1), (v1, v2), (v2, v0)]:
        ab = b - a
        denom = ab[0] ** 2 + ab[1] ** 2
        d = x - a
        t = (d[0] * ab[0] + d[1] * ab[1]) / denom
        t = max(0.0, min(1.0, t))
        p = a + ab * t
        diff = x - p
        d2 = diff[0] ** 2 + diff[1] ** 2
        if best_d2 is None or d2 < best_d2:
            best_d2, best_p = d2, p
    return best_p


def grad_f0(x, mu, verts):
    Pc = project_triangle(x, verts)
    return mu * x + (L_val - mu) * Pc


def f0_value(x, mu, verts):
    """f_0(x) = (L/2)‖x‖² - ((L-μ)/2) d_C(x)²."""
    Pc = project_triangle(x, verts)
    d2 = (x[0] - Pc[0]) ** 2 + (x[1] - Pc[1]) ** 2
    return (L_val / 2) * (x[0] ** 2 + x[1] ** 2) - ((L_val - mu) / 2) * d2


# ---------------------------------------------------------------------------
# (V1) sanity check: PL inequality on Goujaud K=3 function
# ---------------------------------------------------------------------------

def check_V1_PL_inequality(mu, eta, beta, n=20000, seed=42):
    """Sample x uniformly in [-3, 3]² (well outside the polytope) and check
       ‖∇f_0(x)‖² ≥ μ² ‖x‖²."""
    print("--- (V1) PL inequality sanity check ---")
    print(f"  μ = {mu}, μ² = {mu**2}")
    print(f"  Goujaud f_0 should satisfy ‖∇f_0(x)‖² ≥ μ² ‖x‖² for all x.")
    rng = np.random.default_rng(seed)
    verts = goujaud_vertices(beta, eta, mu)
    pts = rng.uniform(-3, 3, size=(n, 2))
    ratios = np.zeros(n)
    f_minus_min = np.zeros(n)
    for i in range(n):
        x = pts[i]
        g = grad_f0(x, mu, verts)
        gnorm2 = g[0] ** 2 + g[1] ** 2
        xnorm2 = x[0] ** 2 + x[1] ** 2
        ratios[i] = gnorm2 / max(xnorm2, 1e-30)
        f_minus_min[i] = f0_value(x, mu, verts) - 0.0  # f_min = 0 at origin
    min_ratio = ratios.min()
    print(f"  min over {n} samples of ‖∇f_0(x)‖² / ‖x‖² = {min_ratio:.6f}")
    print(f"  μ² target                                  = {mu**2:.6f}")
    print(f"  PL holds: {min_ratio >= mu**2 - 1e-10}")
    # Also check (1/2)‖∇f‖² ≥ μ(f - f*)
    pl_form_ratios = []
    for i in range(n):
        x = pts[i]
        g = grad_f0(x, mu, verts)
        gnorm2 = g[0] ** 2 + g[1] ** 2
        if f_minus_min[i] > 1e-12:
            pl_form_ratios.append(0.5 * gnorm2 / f_minus_min[i])
    pl_form_ratios = np.array(pl_form_ratios)
    print(f"  min over {len(pl_form_ratios)} non-trivial samples of "
          f"(1/2)‖∇f_0‖² / (f_0 - f_0*) = {pl_form_ratios.min():.6f}")
    print(f"  μ target                                                  = {mu:.6f}")
    print(f"  PL form (μ-PL) holds: {pl_form_ratios.min() >= mu - 1e-10}")
    print(f"  Strong convexity check: min over {n} samples of "
          f"(f_0 - f_0*) / ((1/2)‖x‖²) = "
          f"{2 * np.min(f_minus_min / np.maximum(np.sum(pts**2, axis=1), 1e-30)):.6f}")
    print(f"  μ target                                                          = {mu:.6f}")
    return {
        "n": n,
        "min_ratio_grad_sq_over_x_sq": float(min_ratio),
        "mu_squared": float(mu ** 2),
        "PL_holds": bool(min_ratio >= mu ** 2 - 1e-10),
        "min_pl_form_ratio": float(pl_form_ratios.min()),
        "mu_target": float(mu),
    }


# ---------------------------------------------------------------------------
# (V2, V3) Monte Carlo: stochastic SHB with various σ
# ---------------------------------------------------------------------------

def check_V2_V3_monte_carlo(mu, eta, beta, sigmas, n_samples=200, T_max=10000, seed=20260429):
    """For each σ, run 200 samples × T_max steps. Measure E[‖x_T‖²] and
       E[‖∇f_0(x_T)‖²]; compare with theoretical lower bounds 2η²σ² and 2μ²η²σ²."""
    print("--- (V2, V3) Monte Carlo: rigorous bounds vs measured ---")
    print(f"  Anchor: μ = {mu}, η = {eta}, β = {beta}")
    print(f"  Theoretical: E[‖x_T‖²] ≥ 2η²σ² = {2 * eta**2:.4f} σ²")
    print(f"               E[‖∇f₀‖²] ≥ 2μ²η²σ² = {2 * mu**2 * eta**2:.4f} σ²")
    print()
    verts = goujaud_vertices(beta, eta, mu)

    rng = np.random.default_rng(seed)
    results = {}
    print(f"  {'σ':>6s}  {'2η²σ² LB':>10s}  {'E[‖x_T‖²] meas':>14s}  "
          f"{'2μ²η²σ² LB':>11s}  {'E[‖∇f‖²] meas':>13s}  {'V2 OK':>6s}  {'V3 OK':>6s}")
    for sigma in sigmas:
        x_norm_sq = np.zeros(n_samples)
        grad_norm_sq = np.zeros(n_samples)
        for s in range(n_samples):
            x_prev = lam_val * e_vec(0)
            x_curr = lam_val * e_vec(0)
            for t in range(1, T_max + 1):
                xi = rng.standard_normal(2) * sigma
                g = grad_f0(x_curr, mu, verts)
                x_new = x_curr - eta * (g + xi) + beta * (x_curr - x_prev)
                x_prev = x_curr
                x_curr = x_new
            x_norm_sq[s] = x_curr[0] ** 2 + x_curr[1] ** 2
            g_final = grad_f0(x_curr, mu, verts)
            grad_norm_sq[s] = g_final[0] ** 2 + g_final[1] ** 2
        E_x_sq = float(np.mean(x_norm_sq))
        E_grad_sq = float(np.mean(grad_norm_sq))
        # Theoretical lower bounds
        LB_x_sq = 2 * eta ** 2 * sigma ** 2
        LB_grad_sq = 2 * mu ** 2 * eta ** 2 * sigma ** 2
        # Conditional bound: μ² · E_x_sq (uses measured E[‖x‖²])
        conditional_LB = mu ** 2 * E_x_sq
        v2_ok = E_x_sq >= LB_x_sq
        v3_ok = E_grad_sq >= LB_grad_sq
        # Also check conditional inequality E[‖∇f‖²] ≥ μ² E[‖x‖²]
        cond_ok = E_grad_sq >= conditional_LB - 1e-6
        print(f"  {sigma:6.3f}  {LB_x_sq:10.4f}  {E_x_sq:14.4f}  "
              f"{LB_grad_sq:11.4f}  {E_grad_sq:13.4f}  "
              f"{'✓' if v2_ok else '✗':>6s}  {'✓' if v3_ok else '✗':>6s}")
        results[str(sigma)] = {
            "sigma": float(sigma),
            "LB_x_sq_2eta2sigma2": float(LB_x_sq),
            "E_x_sq_measured": E_x_sq,
            "LB_grad_sq_2mu2eta2sigma2": float(LB_grad_sq),
            "E_grad_sq_measured": E_grad_sq,
            "conditional_LB_mu2_E_x_sq": float(conditional_LB),
            "V2_OK": bool(v2_ok),
            "V3_OK": bool(v3_ok),
            "conditional_OK": bool(cond_ok),
            "tightness_x_sq": E_x_sq / LB_x_sq if LB_x_sq > 0 else float("inf"),
            "tightness_grad_sq": E_grad_sq / LB_grad_sq if LB_grad_sq > 0 else float("inf"),
        }
    return results


# ---------------------------------------------------------------------------
# (V4) σ → 0 limit consistency: Theorem 1 says LB → 0, but Audit 3
#       showed E[‖∇f‖²] → 0.347 (deterministic cycle floor). This isn't a
#       contradiction — Theorem 1 is just a loose lower bound.
# ---------------------------------------------------------------------------

def check_V4_sigma_zero_limit(mu, eta, beta, n_samples=200, T_max=10000, seed=20260430):
    """Run with σ = 0 (no noise). Theoretical LB = 0, but empirically should
       give E[‖∇f‖²] = (deterministic cycle gradient norm)² ≈ 0.347."""
    print("--- (V4) σ → 0 limit (deterministic) ---")
    verts = goujaud_vertices(beta, eta, mu)
    x_norm_sq = []
    grad_norm_sq = []
    for s in range(n_samples):
        x_prev = lam_val * e_vec(0)
        x_curr = lam_val * e_vec(0)
        for t in range(1, T_max + 1):
            g = grad_f0(x_curr, mu, verts)
            x_new = x_curr - eta * g + beta * (x_curr - x_prev)
            x_prev = x_curr
            x_curr = x_new
        x_norm_sq.append(x_curr[0] ** 2 + x_curr[1] ** 2)
        g_final = grad_f0(x_curr, mu, verts)
        grad_norm_sq.append(g_final[0] ** 2 + g_final[1] ** 2)
        break  # deterministic, only need 1 sample
    E_x_sq = x_norm_sq[0]
    E_grad_sq = grad_norm_sq[0]
    LB_x_sq = 0.0
    LB_grad_sq = 0.0
    print(f"  σ = 0 (deterministic):")
    print(f"    Rigorous LB E[‖x‖²] = 2·0² = 0 (vacuous)")
    print(f"    Measured ‖x_T‖²       = {E_x_sq:.4f}  (= λ² = {lam_val**2:.4f} on cycle)")
    print(f"    Rigorous LB E[‖∇f‖²] = 0 (vacuous)")
    print(f"    Measured ‖∇f(x_T)‖²  = {E_grad_sq:.4f}")
    print()
    print(f"  → Theorem 1 (2μ²η²σ²) is loose at σ=0. Cycling content (Gap 1)")
    print(f"    is needed to close the gap, captured by the conditional theorem.")
    return {
        "x_sq_at_sigma_0": float(E_x_sq),
        "grad_sq_at_sigma_0": float(E_grad_sq),
        "lambda_sq": float(lam_val ** 2),
    }


def main():
    t0 = time.time()
    out = {}

    print("=" * 72)
    print("Caveat 2 verification: rigorous stochastic gradient-floor theorem")
    print("=" * 72)
    print()

    # Anchor
    mu = 0.387
    eta = 3.247
    beta = 0.8
    sigmas = [0.01, 0.1, 0.5, 1.0]

    out["params"] = {"mu": mu, "eta": eta, "beta": beta, "sigmas": sigmas}

    v1 = check_V1_PL_inequality(mu, eta, beta)
    out["V1_PL_inequality"] = v1
    print()

    v23 = check_V2_V3_monte_carlo(mu, eta, beta, sigmas)
    out["V2_V3_monte_carlo"] = v23
    print()

    v4 = check_V4_sigma_zero_limit(mu, eta, beta)
    out["V4_sigma_zero_limit"] = v4
    print()

    print("=" * 72)
    print("Summary")
    print("=" * 72)
    print(f"  V1 (PL inequality on Goujaud f_0): {'PASS' if v1['PL_holds'] else 'FAIL'}")
    all_v23 = all(r["V2_OK"] and r["V3_OK"] for r in v23.values())
    print(f"  V2 (E[‖x_T‖²] ≥ 2η²σ²):           {'PASS' if all_v23 else 'FAIL'}  ({len(v23)} σ tested)")
    all_v3 = all(r["V3_OK"] for r in v23.values())
    print(f"  V3 (E[‖∇f‖²] ≥ 2μ²η²σ²):          {'PASS' if all_v3 else 'FAIL'}")
    print(f"  V4 (σ→0 limit ↔ Gap 1 cycling):    deterministic ‖∇f‖² = {v4['grad_sq_at_sigma_0']:.4f}")
    print()
    print(f"  Tightness ratios (measured / theoretical) at each σ:")
    print(f"    {'σ':>6s}  {'E[‖x‖²] tightness':>18s}  {'E[‖∇f‖²] tightness':>20s}")
    for sigma_str, r in v23.items():
        print(f"    {float(sigma_str):6.3f}  {r['tightness_x_sq']:18.1f}×  "
              f"{r['tightness_grad_sq']:20.1f}×")

    out["wall_time"] = time.time() - t0
    out_path = HERE / "caveat2_results.json"
    with open(out_path, "w", encoding="utf-8") as fp:
        json.dump(out, fp, indent=2, default=str)
    print()
    print(f"  Wall time: {out['wall_time']:.1f}s")
    print(f"  Saved to {out_path}")


if __name__ == "__main__":
    main()
