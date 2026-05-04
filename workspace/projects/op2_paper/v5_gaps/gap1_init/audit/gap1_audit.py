"""
Gap 1 self-audit — Audits 2, 3, 4.

Audit 2: cycling threshold sensitivity. The original M3 grid scan classifies a
parameter point as 'cycle' iff |||x_T|| - lam| / lam < 0.01 (relative norm
deviation, NOT ||x_{T+3} - x_T|| < eps). We rerun the same grid with a tighter
criterion that DOES use both norm-deviation AND period-3 closure, and sweep a
range of thresholds eps in {1e-2, 1e-6, 1e-8, 1e-10, 1e-20, 1e-30, 1e-40}.

Audit 3: stochastic robustness. SHB at anchor (0.8, 3.247, 0.387) with additive
gradient noise N(0, sigma^2 I_2). For sigma in {0.01, 0.1, 0.5, 1.0}, 200 samples,
T = 10000 steps. Report E[||grad f_0(x_T)||^2], E[||x_T||], and orbit-norm
trajectory.

Audit 4: transient vulnerability. Compute ||x_4|| at the anchor to 50-digit
precision (deterministic). Then with 200 stochastic samples count the fraction
that have ||x_T|| > 0.5 * lam at T=10000 (i.e., did NOT decay to 0).
"""

import json
import time
from pathlib import Path

import mpmath as mp
import numpy as np


HERE = Path(__file__).parent
mp.mp.dps = 50

# ---------------------------------------------------------------------------
# High-precision (mpmath) Goujaud SHB
# ---------------------------------------------------------------------------

K = 3
L_val_mp = mp.mpf(1)
D_val_mp = mp.mpf(1)
lam_mp = D_val_mp / mp.sqrt(2)


def e_vec_mp(t):
    ang = 2 * mp.pi * (t % K) / K
    return mp.matrix([[mp.cos(ang)], [mp.sin(ang)]])


def Rmat_mp(theta):
    c, s = mp.cos(theta), mp.sin(theta)
    return mp.matrix([[c, -s], [s, c]])


def goujaud_M_mp(beta, eta, mu):
    theta3 = 2 * mp.pi / 3
    I2 = mp.matrix([[1, 0], [0, 1]])
    R_pos = Rmat_mp(theta3)
    R_neg = Rmat_mp(-theta3)
    A = (1 + beta - mu * eta) * I2 - R_pos - beta * R_neg
    return A / ((L_val_mp - mu) * eta)


def goujaud_vertices_mp(beta, eta, mu):
    M = goujaud_M_mp(beta, eta, mu)
    return [lam_mp * (M * e_vec_mp(t)) for t in range(K)]


def project_triangle_mp(x, verts):
    v0, v1, v2 = verts[0], verts[1], verts[2]

    def signed_area(a, b, c):
        return (b[0, 0] - a[0, 0]) * (c[1, 0] - a[1, 0]) - (b[1, 0] - a[1, 0]) * (
            c[0, 0] - a[0, 0]
        )

    A = signed_area(v0, v1, v2)
    s1 = signed_area(v0, v1, x) / A
    s2 = signed_area(v1, v2, x) / A
    s3 = signed_area(v2, v0, x) / A
    if s1 >= 0 and s2 >= 0 and s3 >= 0:
        return x

    best_d2 = None
    best_p = None
    for (a, b) in [(v0, v1), (v1, v2), (v2, v0)]:
        ab = b - a
        denom = (ab[0, 0]) ** 2 + (ab[1, 0]) ** 2
        d = x - a
        t = (d[0, 0] * ab[0, 0] + d[1, 0] * ab[1, 0]) / denom
        if t < 0:
            t = mp.mpf(0)
        elif t > 1:
            t = mp.mpf(1)
        p = a + ab * t
        diff = x - p
        d2 = diff[0, 0] ** 2 + diff[1, 0] ** 2
        if best_d2 is None or d2 < best_d2:
            best_d2 = d2
            best_p = p
    return best_p


def grad_f0_mp(x, mu, verts):
    Pc = project_triangle_mp(x, verts)
    return mu * x + (L_val_mp - mu) * Pc


def shb_step_mp(x, x_prev, eta, mu, beta, verts):
    return x - eta * grad_f0_mp(x, mu, verts) + beta * (x - x_prev)


def matnorm_mp(v):
    return mp.sqrt(v[0, 0] ** 2 + v[1, 0] ** 2)


# ---------------------------------------------------------------------------
# Float64 (numpy) SHB — for stochastic Monte Carlo
# ---------------------------------------------------------------------------

L_val = 1.0
D_val = 1.0
lam_val = D_val / np.sqrt(2)


def e_vec_np(t):
    ang = 2 * np.pi * (t % 3) / 3.0
    return np.array([np.cos(ang), np.sin(ang)])


def Rmat_np(theta):
    c, s = np.cos(theta), np.sin(theta)
    return np.array([[c, -s], [s, c]])


def goujaud_vertices_np(beta, eta, mu):
    theta3 = 2 * np.pi / 3
    I2 = np.eye(2)
    R_pos = Rmat_np(theta3)
    R_neg = Rmat_np(-theta3)
    A = (1 + beta - mu * eta) * I2 - R_pos - beta * R_neg
    M = A / ((L_val - mu) * eta)
    return [lam_val * (M @ e_vec_np(t)) for t in range(3)]


def project_triangle_np(x, verts):
    v0, v1, v2 = verts

    def signed_area(a, b, c):
        return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])

    A = signed_area(v0, v1, v2)
    s1 = signed_area(v0, v1, x) / A
    s2 = signed_area(v1, v2, x) / A
    s3 = signed_area(v2, v0, x) / A
    if s1 >= 0 and s2 >= 0 and s3 >= 0:
        return x.copy()

    best_d2 = None
    best_p = None
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
            best_d2 = d2
            best_p = p
    return best_p


def grad_f0_np(x, mu, verts):
    Pc = project_triangle_np(x, verts)
    return mu * x + (L_val - mu) * Pc


def shb_step_np_stochastic(x, x_prev, eta, mu, beta, verts, noise):
    """Stochastic SHB: noise added to gradient (each step gets fresh noise)."""
    g = grad_f0_np(x, mu, verts)
    g_noisy = g + noise
    return x - eta * g_noisy + beta * (x - x_prev)


def shb_step_np(x, x_prev, eta, mu, beta, verts):
    g = grad_f0_np(x, mu, verts)
    return x - eta * g + beta * (x - x_prev)


# ---------------------------------------------------------------------------
# Reused from gap1_verify.py
# ---------------------------------------------------------------------------

def feasible_kappa_mp(beta, etaL):
    a = etaL ** 2 - 2 * etaL * (1 + beta / 2)
    b = -2 * etaL * (beta + mp.mpf(1) / 2) + 3 * (1 + beta + beta ** 2)
    if a > 0:
        kappa_max = -b / a
        if kappa_max <= 0:
            return None
        return min(kappa_max / 2, mp.mpf("0.5"))
    elif a < 0:
        kappa_min = -b / a
        if kappa_min >= 1:
            return None
        return (kappa_min + 1) / 2
    else:
        return mp.mpf("0.5") if b < 0 else None


def gamma_crit_mp(beta):
    return 3 * (1 + beta + beta ** 2) / (1 + 2 * beta)


# ---------------------------------------------------------------------------
# AUDIT 2: cycling threshold sensitivity
# ---------------------------------------------------------------------------

def audit2_threshold_sensitivity():
    """Rerun the same M3 grid (54 points). For each parameter point, compute
    BOTH:
      (a) relative final-norm deviation: rel_diff = |||x_T|| - lam| / lam
      (b) period-3 closure error: ||x_T - x_{T-3}|| / lam
    Then for a sweep of thresholds eps, count how many points have BOTH
    metrics below eps (strictest cycling test).

    We use mpmath dps = 50 and T = 5000 (same as M3).
    """
    print("=" * 72)
    print("AUDIT 2: cycling threshold sensitivity")
    print("=" * 72)
    print()
    print("Original M3 criterion (gap1_verify.py, line 446):")
    print("  rel_diff = |||x_T|| - lam| / lam  with threshold 0.01 (1%)")
    print("  decay: ||x_T|| < 1e-4")
    print("Tightened criterion (this audit):")
    print("  must satisfy rel_diff < eps AND ||x_T - x_{T-3}|| / lam < eps")
    print()

    beta_grid = [mp.mpf(b) for b in [0.4, 0.5, 0.6, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95]]
    eta_steps = 6
    T = 5000

    target_R = lam_mp
    points = []  # (beta, etaL, kappa, rel_diff, period3_err_relative, final_norm)

    for beta in beta_grid:
        gc = gamma_crit_mp(beta)
        eta_max = 2 * (1 + beta)
        if eta_max <= gc:
            continue
        for j in range(eta_steps):
            t_frac = mp.mpf(j + 0.5) / eta_steps
            etaL = gc + t_frac * (eta_max - gc)
            kappa = feasible_kappa_mp(beta, etaL)
            if kappa is None:
                continue
            mu = kappa * L_val_mp
            eta = etaL / L_val_mp
            verts = goujaud_vertices_mp(beta, eta, mu)
            x_prev = lam_mp * e_vec_mp(0)
            x_curr = lam_mp * e_vec_mp(0)

            # iterate to T-3
            for _ in range(T - 3):
                x_new = shb_step_mp(x_curr, x_prev, eta, mu, beta, verts)
                x_prev = x_curr
                x_curr = x_new

            # save x_{T-3}
            x_minus3 = x_curr.copy() if hasattr(x_curr, 'copy') else \
                       mp.matrix([[x_curr[0, 0]], [x_curr[1, 0]]])
            xp_minus3 = x_prev.copy() if hasattr(x_prev, 'copy') else \
                        mp.matrix([[x_prev[0, 0]], [x_prev[1, 0]]])

            # iterate 3 more steps to T
            for _ in range(3):
                x_new = shb_step_mp(x_curr, x_prev, eta, mu, beta, verts)
                x_prev = x_curr
                x_curr = x_new

            final_norm = matnorm_mp(x_curr)
            if final_norm < mp.mpf("1e-100"):
                rel_diff = mp.mpf(1)
            else:
                rel_diff = abs(final_norm - target_R) / target_R
            diff_vec = x_curr - x_minus3
            p3_err = matnorm_mp(diff_vec) / target_R if target_R > 0 else mp.mpf("inf")

            points.append({
                "beta": float(beta),
                "etaL": float(etaL),
                "kappa": float(kappa),
                "rel_diff_norm": float(rel_diff) if rel_diff < mp.mpf("1e300") else 1.0,
                "period3_err_rel": float(p3_err) if p3_err < mp.mpf("1e300") else 1.0,
                "final_norm": float(final_norm) if final_norm < mp.mpf("1e300") else 0.0,
            })

    # Summarize: for each threshold, count how many points have BOTH metrics
    # below threshold.
    thresholds = [1e-2, 1e-6, 1e-8, 1e-10, 1e-20, 1e-30, 1e-40]
    summary = {}
    print(f"{'eps':>10s}  {'cycle (both<eps)':>20s}  {'cycle (rel<eps)':>20s}  {'cycle (p3<eps)':>20s}")
    n_total = len(points)
    for eps in thresholds:
        n_both = sum(1 for p in points
                     if p["rel_diff_norm"] < eps and p["period3_err_rel"] < eps)
        n_rel = sum(1 for p in points if p["rel_diff_norm"] < eps)
        n_p3 = sum(1 for p in points if p["period3_err_rel"] < eps)
        summary[str(eps)] = {"both": n_both, "rel": n_rel, "p3": n_p3, "total": n_total}
        print(f"{eps:10.0e}  {n_both:>4d}/{n_total:>4d} ({100*n_both/n_total:5.1f}%)  "
              f"{n_rel:>4d}/{n_total:>4d} ({100*n_rel/n_total:5.1f}%)  "
              f"{n_p3:>4d}/{n_total:>4d} ({100*n_p3/n_total:5.1f}%)")
    print()
    print("Original M3 'cycle' count (rel<0.01, no p3 check):", summary["0.01"]["rel"])
    print()

    # Print per-point details for a few notable points
    print("Per-point details (first 5 cycle-classified points under original 0.01):")
    cyc_orig = [p for p in points if p["rel_diff_norm"] < 0.01][:5]
    for p in cyc_orig:
        print(f"  beta={p['beta']:.3f} etaL={p['etaL']:.4f} kappa={p['kappa']:.4f}: "
              f"rel_diff={p['rel_diff_norm']:.2e}  p3_err_rel={p['period3_err_rel']:.2e}")
    print()

    return summary, points


# ---------------------------------------------------------------------------
# AUDIT 3 + 4: stochastic robustness + transient vulnerability
# ---------------------------------------------------------------------------

def audit3_4_stochastic():
    """At anchor (0.8, 3.247, 0.387), run 200 stochastic samples per sigma in
    {0.01, 0.1, 0.5, 1.0} for T = 10000 steps. Each step:
        x_{t+1} = x_t - eta (grad f_0(x_t) + xi_t) + beta (x_t - x_{t-1})
    where xi_t ~ N(0, sigma^2 I_2) is fresh per step.

    Report:
      - E[||x_T||]: mean final norm
      - E[||grad f_0(x_T)||^2]: mean final gradient-norm-squared
      - fraction of samples with ||x_T|| > 0.5 * lam (i.e., did NOT decay)
      - mean orbit norm trajectory at a few snapshot times
    """
    print("=" * 72)
    print("AUDIT 3 + 4: stochastic robustness + transient vulnerability")
    print("=" * 72)
    print()
    print("Anchor: (beta, etaL, kappa) = (0.8, 3.247, 0.387)")
    print("Stochastic update: x_{t+1} = x_t - eta (grad f + xi_t) + beta (x_t - x_{t-1})")
    print("  xi_t ~ N(0, sigma^2 I_2), fresh per step")
    print()

    beta = 0.8
    etaL = 3.247
    kappa = 0.387
    eta = etaL / L_val
    mu = kappa * L_val
    verts = goujaud_vertices_np(beta, eta, mu)

    # First: deterministic transient |x_4| at anchor (Audit 4 part 1)
    print("--- Audit 4 part 1: deterministic ||x_4|| at anchor (mpmath dps=50) ---")
    beta_mp = mp.mpf("0.8")
    etaL_mp = mp.mpf("3.247")
    kappa_mp = mp.mpf("0.387")
    eta_mp = etaL_mp / L_val_mp
    mu_mp = kappa_mp * L_val_mp
    verts_mp = goujaud_vertices_mp(beta_mp, eta_mp, mu_mp)
    x_prev_mp = lam_mp * e_vec_mp(0)
    x_curr_mp = lam_mp * e_vec_mp(0)
    norm_log_mp = [matnorm_mp(x_curr_mp)]
    for t in range(1, 11):
        x_new_mp = shb_step_mp(x_curr_mp, x_prev_mp, eta_mp, mu_mp, beta_mp, verts_mp)
        x_prev_mp = x_curr_mp
        x_curr_mp = x_new_mp
        norm_log_mp.append(matnorm_mp(x_curr_mp))
    print(f"  ||x_t|| for t=0..10 (mpmath dps=50):")
    for t, n in enumerate(norm_log_mp):
        print(f"    t={t:2d}: {mp.nstr(n, 30)}")
    x4_norm_det = float(norm_log_mp[4])
    print(f"  ||x_4|| (deterministic) = {x4_norm_det}")
    print(f"  lam = {float(lam_mp)}")
    print(f"  ||x_4|| / lam = {x4_norm_det / float(lam_mp):.4f}")
    print()

    sigmas = [0.01, 0.1, 0.5, 1.0]
    n_samples = 200
    T_max = 10000
    snapshot_times = [0, 5, 10, 100, 1000, 5000, 10000]

    np.random.seed(20260429)

    audit3_results = {}
    audit4_results = {}

    for sigma in sigmas:
        print(f"--- sigma = {sigma} ---")
        t0 = time.time()
        # Storage
        final_norms = np.zeros(n_samples)
        final_grad_sq = np.zeros(n_samples)
        snapshot_norms = {t: np.zeros(n_samples) for t in snapshot_times}
        # Transient stats (Audit 4): track min ||x_t|| in t in [1, 100]
        min_norm_transient = np.zeros(n_samples)

        for s in range(n_samples):
            x_prev = lam_val * e_vec_np(0)
            x_curr = lam_val * e_vec_np(0)
            min_norm_t = np.linalg.norm(x_curr)

            for t in range(1, T_max + 1):
                xi = np.random.randn(2) * sigma
                x_new = shb_step_np_stochastic(x_curr, x_prev, eta, mu, beta, verts, xi)
                x_prev = x_curr
                x_curr = x_new
                if t <= 100:
                    n = np.linalg.norm(x_curr)
                    if n < min_norm_t:
                        min_norm_t = n
                if t in snapshot_times:
                    snapshot_norms[t][s] = np.linalg.norm(x_curr)

            final_norms[s] = np.linalg.norm(x_curr)
            g_final = grad_f0_np(x_curr, mu, verts)
            final_grad_sq[s] = g_final[0] ** 2 + g_final[1] ** 2
            min_norm_transient[s] = min_norm_t

        # Stats
        E_norm = np.mean(final_norms)
        E_grad_sq = np.mean(final_grad_sq)
        frac_above_half_lam = np.mean(final_norms > 0.5 * lam_val)
        frac_below_eps = np.mean(final_norms < 0.01)
        median_min_transient = np.median(min_norm_transient)

        snapshot_means = {t: float(np.mean(snapshot_norms[t])) for t in snapshot_times}

        elapsed = time.time() - t0
        print(f"  {n_samples} samples x T={T_max}, elapsed {elapsed:.1f}s")
        print(f"  E[||x_T||]              = {E_norm:.5f}   (lam = {lam_val:.5f})")
        print(f"  E[||grad f_0(x_T)||^2]  = {E_grad_sq:.5e}")
        print(f"  P(||x_T|| > 0.5 lam)    = {frac_above_half_lam:.3f}  ({int(frac_above_half_lam*n_samples)}/{n_samples})")
        print(f"  P(||x_T|| < 0.01)       = {frac_below_eps:.3f}  (decayed-to-0 fraction)")
        print(f"  median min ||x_t|| over t in [0,100] = {median_min_transient:.5f}")
        print(f"  mean ||x_t|| at snapshots:")
        for t in snapshot_times:
            print(f"    t={t:>5d}: {snapshot_means[t]:.5f}")

        audit3_results[str(sigma)] = {
            "E_norm_final": float(E_norm),
            "E_grad_sq_final": float(E_grad_sq),
            "frac_above_half_lam": float(frac_above_half_lam),
            "frac_decay_to_0": float(frac_below_eps),
            "snapshot_means": snapshot_means,
        }
        audit4_results[str(sigma)] = {
            "median_min_transient": float(median_min_transient),
            "frac_above_half_lam_at_T": float(frac_above_half_lam),
        }
        print()

    return audit3_results, audit4_results, x4_norm_det


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main():
    t0 = time.time()
    out = {}

    s2_summary, s2_points = audit2_threshold_sensitivity()
    out["audit2_threshold_sensitivity"] = {
        "summary_by_threshold": s2_summary,
        "points": s2_points,
    }

    a3, a4, x4_det = audit3_4_stochastic()
    out["audit3_stochastic"] = a3
    out["audit4_transient"] = a4
    out["audit4_x4_norm_deterministic"] = x4_det

    print("=" * 72)
    print("AUDIT FINAL JSON SAVED")
    print("=" * 72)

    out_path = HERE / "gap1_audit_results.json"
    with open(out_path, "w", encoding="utf-8") as fp:
        json.dump(out, fp, indent=2, default=str)
    print(f"Saved: {out_path}")
    print(f"Total wall time: {time.time() - t0:.1f}s")


if __name__ == "__main__":
    main()
