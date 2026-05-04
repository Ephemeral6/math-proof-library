"""
Numerical pre-check for Route 6 (Compositional) of the SHB Polyak-Ruppert
kappa-blow-up theorem.

Route 6 splits the proof into three lemmas:
    L1  (Part A)  — last-iterate UB:        |x_T^{(lambda)}|  <=  C1 * beta^{T/2}
    L2  (Part B)  — PR-average LB:          |tilde x_{T,lambda}|  >=  C2 / (eta*lambda*T^2)  (T >= T_0)
    L3  (Part C)  — composition + crossover

Theoretical L3 ratio (mu-coordinate dominates numerator, L-coordinate dominates denominator):

    f(tilde x_T) / f(x_T)
        =  [ (mu/2) tilde x_{T,mu}^2 + (L/2) tilde x_{T,L}^2 ]
         / [ (L/2) x_T^{(L)2}      + (mu/2) x_T^{(mu)2}     ]
        ~  C3 * kappa / (T^4 * eta^2 * L^2 * beta^T)              (Part C(i))

Crossover T*(kappa) defined by  beta^{T*} ~ T*^{-4}  (no kappa dependence in T* itself for the
"pure-power-law" crossover — but the actual crossover where empirical f(x_T) hits machine zero is
T_machine ~ -ln(eps) / -ln(beta)  ≈  16 * ln(10) / 0.105 ≈ 350  for beta = 0.9.)

This script:
  (i)  computes empirical kappa-exponent of f(tilde x_T)/f(x_T) at T in {50, 100, 200, 300};
  (ii) compares to the L3 prediction (kappa-exponent should be 1 in the regime where Part A is
       tight, since ratio ~ kappa^1 * (T-dependent stuff));
  (iii) detects machine-precision floor on f(x_T) and reports T-window where Part C(ii) crossover
        regime kicks in;
  (iv) checks the L1 constant C1 by tracking max_{t<=T} |x_t / beta^{t/2}| at multiple T;
  (v)  checks the L2 constant C2 by tracking |tilde x_{T,lambda}| * eta*lambda*T^2 vs T;
  (vi) reports raw kappa-exponent table to verify Honest-scope claim.
"""
import numpy as np
import os
import csv

OUT_DIR = os.path.dirname(os.path.abspath(__file__))


def shb_scalar_trajectory(lam, beta, eta, T, x0=1.0, x_minus1=1.0):
    """Run scalar SHB for T steps; return arrays x[0..T] (length T+1)."""
    x = np.empty(T + 1)
    x[0] = x0
    x_prev = x_minus1
    for t in range(T):
        x[t + 1] = (1 + beta - eta * lam) * x[t] - beta * x_prev
        x_prev = x[t]
    return x


def shb_pr_avg(x_traj, T):
    """Compute linearly-weighted PR average tilde x_T = (2/(T(T+1))) sum_{t=0}^{T-1} (t+1) x_t."""
    weights = np.arange(1, T + 1, dtype=float)  # (1, 2, ..., T) for x_0,...,x_{T-1}
    return float(np.sum(weights * x_traj[:T]) * 2.0 / (T * (T + 1)))


def f_value(L, mu, x):
    """Quadratic f(x) = (L/2) x_1^2 + (mu/2) x_2^2."""
    return 0.5 * (L * x[0] ** 2 + mu * x[1] ** 2)


def angle_theta(beta, lam, eta):
    """SHB under-damped angle theta_lambda = arccos((1+beta-eta*lambda)/(2 sqrt(beta)))."""
    arg = (1 + beta - eta * lam) / (2 * np.sqrt(beta))
    if abs(arg) >= 1:
        return None  # not under-damped
    return float(np.arccos(arg))


def main():
    L = 1.0
    beta = 0.9
    etaL = 2.9
    eta = etaL / L

    # ============== Sanity: under-damped check for both lam = L, mu ==============
    print("=" * 78)
    print("Under-damped regime check (need (1+beta-eta*lam)^2 < 4 beta = 3.6)")
    print("=" * 78)
    for kappa in [10, 100, 1000]:
        mu = 1.0 / kappa
        for tag, lam in [("L", L), ("mu", mu)]:
            disc = (1 + beta - eta * lam) ** 2 - 4 * beta
            theta = angle_theta(beta, lam, eta)
            print(f"  kappa={kappa:4d} lam={tag:2s}={lam:.4e}: "
                  f"disc={disc:+.4f}, theta={theta if theta is None else f'{theta:.4f}'}")

    # ============== Lemma L1 numerical check: |x_T| <= C1 * beta^{T/2} ==============
    print()
    print("=" * 78)
    print("L1 check: max_{0<=t<=T} |x_t^{(lam)}| / beta^{t/2}  for lam in {L, mu}")
    print("    (should be bounded by an explicit C1(beta, theta_lam))")
    print("=" * 78)
    Ts_check = [50, 100, 200, 300]
    print(f"{'kappa':>6} {'lam':>4} {'T':>4} {'sup |x_t|/beta^{t/2}':>22} "
          f"{'C1_pred':>12} {'theta':>10}")
    for kappa in [10, 100, 1000]:
        mu = 1.0 / kappa
        for tag, lam in [("L", L), ("mu", mu)]:
            theta = angle_theta(beta, lam, eta)
            if theta is None:
                continue
            for T in Ts_check:
                x_traj = shb_scalar_trajectory(lam, beta, eta, T)
                ts = np.arange(T + 1)
                ratio = np.abs(x_traj) / (beta ** (ts / 2.0))
                sup_ratio = float(np.max(ratio))
                # Predicted C1 from closed form (see proof Lemma L1):
                # x_t = (sqrt(beta))^t * [A cos(t*theta) + B sin(t*theta)]
                # with A = 1, B = (1 - sqrt(beta) cos(theta))/(sqrt(beta) sin(theta))
                # so |x_t|/beta^{t/2} <= sqrt(A^2 + B^2)
                A = 1.0
                B = (1 - np.sqrt(beta) * np.cos(theta)) / (np.sqrt(beta) * np.sin(theta))
                C1_pred = np.sqrt(A ** 2 + B ** 2)
                print(f"{kappa:>6} {tag:>4} {T:>4} {sup_ratio:>22.5f} "
                      f"{C1_pred:>12.5f} {theta:>10.5f}")

    # ============== Lemma L2 numerical check: |tilde x_{T,lambda}| * eta*lambda*T^2 -> C2 ==============
    print()
    print("=" * 78)
    print("L2 check: |tilde x_{T,lam}| * eta * lam * T^2  (should approach C2 for T -> infty)")
    print("=" * 78)
    print(f"{'kappa':>6} {'lam':>4} {'T':>4} "
          f"{'|PR| * eta lam T^2':>22} {'C2_pred':>12} {'theta':>10}")
    for kappa in [10, 100, 1000]:
        mu = 1.0 / kappa
        for tag, lam in [("L", L), ("mu", mu)]:
            theta = angle_theta(beta, lam, eta)
            if theta is None:
                continue
            for T in Ts_check:
                x_traj = shb_scalar_trajectory(lam, beta, eta, T)
                tilde_x = shb_pr_avg(x_traj, T)
                # |tilde_x| * (eta * lam * T^2)
                product = abs(tilde_x) * eta * lam * T ** 2
                # Predicted C2 from L2 (asymptotic from the closed-form geometric series):
                # tilde x_T -> -2 * x_0 / (eta lam T^2) * Re[ z / (1-z)^2 * (something order 1) ]
                # Simpler: the leading constant comes from
                #   sum_{t>=0}(t+1) z^t = 1/(1-z)^2  (|z|<1, T -> infty)
                # times 2/T^2 prefactor.  With |1-z|^2 = eta*lam, the magnitude of
                #   2 * Re[ A_lam / (1 - z_lam)^2 ]
                # where A_lam is the fundamental solution coefficient.  We use the simpler
                # absolute prediction:
                #   |PR| * eta lam T^2  ->  |2 * A_lam|  (constant of order 1)
                # Predicted from closed form:  for x_0 = x_{-1} = 1, A_lam = 1.
                C2_pred = 2.0  # |2 * 1| = 2 in leading order
                print(f"{kappa:>6} {tag:>4} {T:>4} "
                      f"{product:>22.6f} {C2_pred:>12.4f} {theta:>10.5f}")

    # ============== Lemma L3 / Part C numerical check: kappa-exponent of f(PR)/f(last) ==============
    print()
    print("=" * 78)
    print("L3 / Part C check: empirical kappa-exponent of f(tilde x_T) / f(x_T)")
    print("    at T in {50, 100, 200, 300} with beta=0.9, eta L = 2.9.")
    print("    Theoretical L3 prediction: kappa-exponent = 1 (in the regime where Part A is tight).")
    print("=" * 78)
    Ts_kappa = [50, 100, 200, 300]
    kappas = [4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096]

    rows = []
    print(f"{'T':>5}", *[f"{'k=' + str(k):>10}" for k in kappas])
    for T in Ts_kappa:
        ratios = []
        f_xTs = []
        f_PRs = []
        for kappa in kappas:
            mu = 1.0 / kappa
            x1 = shb_scalar_trajectory(L, beta, eta, T)
            x2 = shb_scalar_trajectory(mu, beta, eta, T)
            x_T = np.array([x1[T], x2[T]])
            tilde_x = np.array([shb_pr_avg(x1, T), shb_pr_avg(x2, T)])
            f_x = f_value(L, mu, x_T)
            f_p = f_value(L, mu, tilde_x)
            ratio = f_p / f_x if f_x > 0 else float("inf")
            ratios.append(ratio)
            f_xTs.append(f_x)
            f_PRs.append(f_p)
            rows.append({"T": T, "kappa": kappa, "f_xT": f_x, "f_PR": f_p,
                         "ratio": ratio, "log10_ratio": np.log10(ratio)})
        print(f"T={T:3d} log10(ratio):  " + " ".join(f"{np.log10(r):>8.3f}" for r in ratios))

    print()
    print("Empirical kappa-exponent (slope of log(ratio) vs log(kappa)):")
    print(f"{'T':>5} {'all-kappa exp':>15} {'large-kappa exp (k>=64)':>27} {'beta^T':>14}")
    for T in Ts_kappa:
        rs = np.array([r["ratio"] for r in rows if r["T"] == T])
        ks_arr = np.array(kappas, dtype=float)
        mask = np.isfinite(rs) & (rs > 0)
        slope_all, _ = np.polyfit(np.log(ks_arr[mask]), np.log(rs[mask]), 1)
        mask_large = (ks_arr >= 64) & mask
        if mask_large.sum() >= 2:
            slope_large, _ = np.polyfit(np.log(ks_arr[mask_large]), np.log(rs[mask_large]), 1)
        else:
            slope_large = float("nan")
        print(f"{T:>5} {slope_all:>15.4f} {slope_large:>27.4f} {beta**T:>14.3e}")

    # ============== Crossover T* check: beta^T = T^{-4} ==============
    print()
    print("=" * 78)
    print("Crossover T* defined by beta^{T*} = T*^{-4} (no kappa in pure-power crossover):")
    print("=" * 78)
    T_grid = np.arange(1, 1000)
    diff = beta ** T_grid - T_grid.astype(float) ** -4
    sign_change = np.where(np.diff(np.sign(diff)) != 0)[0]
    if len(sign_change) > 0:
        T_star = T_grid[sign_change[0]]
        print(f"  T* ~= {T_star},  beta^T* = {beta**T_star:.3e},  T*^-4 = {T_star**-4.0:.3e}")
    else:
        print("  (no crossover found in [1, 1000])")

    # Machine-precision floor T_machine: smallest T with beta^T < 1e-16
    T_machine = int(np.ceil(-16 * np.log(10) / np.log(beta)))
    print(f"  T_machine (beta^T < 1e-16): T_machine ~= {T_machine}")

    # ============== Summary verdict ==============
    print()
    print("=" * 78)
    print("VERDICT (Route 6 / L3):")
    print("=" * 78)
    print("Theoretical L3 (under L1, L2 tight) predicts kappa-exponent  c = 1  in the")
    print("regime where f(x_T) is well-resolved (T <= T_machine ~ 350 for beta=0.9).")
    print("Empirical kappa-exponent observed:")
    for T in Ts_kappa:
        rs = np.array([r["ratio"] for r in rows if r["T"] == T])
        ks_arr = np.array(kappas, dtype=float)
        mask = (ks_arr >= 64) & np.isfinite(rs) & (rs > 0)
        if mask.sum() >= 2:
            slope, _ = np.polyfit(np.log(ks_arr[mask]), np.log(rs[mask]), 1)
            verdict = "matches L3 (= 1)" if abs(slope - 1.0) < 0.3 else (
                f"DEVIATES from L3 (excess = {slope - 1.0:+.2f})")
            print(f"  T = {T}:  large-kappa exp = {slope:.3f}  -->  {verdict}")

    # CSV output for inclusion in proof
    csv_path = os.path.join(OUT_DIR, "verify_route6.csv")
    with open(csv_path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)
    print(f"\nCSV saved to {csv_path}")


if __name__ == "__main__":
    main()
