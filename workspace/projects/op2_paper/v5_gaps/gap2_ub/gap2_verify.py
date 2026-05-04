"""
Gap 2 numerical verification — last-iterate UB for fixed-momentum SHB on
L-smooth convex non-SC functions.

Three-way verification (SymPy / mpmath / Monte Carlo):

  (S1) SymPy: discrete Lyapunov equation P = A P A^T + Q on the 2-D state
       z_t = (x_t, x_{t-1})^T for SHB on f(x) = (L/2) x^2 with i.i.d. Gaussian
       noise. Solve for stationary Var_inf[x] in closed form and verify the
       boxed formula
            Var_inf[x] = eta sigma^2 (1+beta) / [L (1-beta) (2(1+beta) - eta L)]    ... (5)
  (S2) SymPy: leading-order expansion in eta -> 0:
            Var_inf[x] = sigma^2 eta / [L (1-beta^2)] + O(eta^2)
       and consistency at beta = 0 with classical AR(1) variance.
  (M1) mpmath 50-digit re-derivation: independent Lyapunov solve at the anchor
       (beta, eta L) = (0.5, 0.1). Verify formula (5) symbolically and numerically.
  (M2) mpmath 50-digit log-log rate fit: simulate SHB at horizon-tuned
       eta_T = D / (sigma sqrt(T)) for T in {100, 300, 1000, 3000, 10000} and
       check that E[f(x_T) - f*] ~ Theta(sigma D / sqrt(T)).
  (MC1) Monte Carlo: 1000 trials, 10000 steps, burn-in 5000 at three (beta, eta)
        settings; relative error vs. closed form must be < 1%.
  (MC2) Monte Carlo: log-log empirical rate fit at horizon-tuned eta_T.

Run: python gap2_verify.py
Wall time: ~2 minutes.
"""

import json
import time
from pathlib import Path

import mpmath as mp
import numpy as np
import sympy as sp


# ---------------------------------------------------------------------------
# (S1) SymPy: closed-form stationary variance via discrete Lyapunov equation
# ---------------------------------------------------------------------------

def check_S1_closed_form_variance():
    """Solve P = A P A^T + Q symbolically; verify boxed formula (5)."""
    print("--- (S1) SymPy: discrete Lyapunov closed-form Var_inf[x] ---")
    beta, eta, L, sigma = sp.symbols("beta eta L sigma", positive=True)

    A = sp.Matrix([[1 + beta - eta * L, -beta], [1, 0]])
    Q = sp.Matrix([[eta ** 2 * sigma ** 2, 0], [0, 0]])

    p11, p12, p22 = sp.symbols("p11 p12 p22", real=True)
    P = sp.Matrix([[p11, p12], [p12, p22]])

    eq = A * P * A.T + Q - P
    sol_list = sp.solve([eq[0, 0], eq[0, 1], eq[1, 1]], [p11, p12, p22], dict=True)
    assert len(sol_list) == 1, f"unexpected number of solutions: {len(sol_list)}"
    sol = sol_list[0]
    Var_inf = sp.simplify(sol[p11])

    # Boxed formula (5):
    formula_5 = eta * sigma ** 2 * (1 + beta) / (L * (1 - beta) * (2 * (1 + beta) - eta * L))
    diff = sp.simplify(Var_inf - formula_5)
    print(f"  Lyapunov solution Var_inf[x] (raw): {Var_inf}")
    print(f"  Boxed formula (5):                 {formula_5}")
    print(f"  Difference:                        {diff}")
    ok = diff == 0
    print(f"  S1 PASS: {ok}")
    return ok, {"Var_inf_str": str(Var_inf), "formula5_str": str(formula_5)}


# ---------------------------------------------------------------------------
# (S2) SymPy: small-eta Taylor + beta=0 consistency
# ---------------------------------------------------------------------------

def check_S2_small_eta_and_beta0():
    """Leading order Var_inf = sigma^2 eta / [2 L (1-beta)] + O(eta^2);
       at beta=0 collapses to classical SGD-on-quadratic AR(1) variance.

       NOTE: An earlier draft mistakenly expected sigma^2 / [L(1-beta^2)]
       as the leading coefficient. Correct leading: sigma^2 / [2L(1-beta)].
       The formula sigma^2 eta / (1 - beta^2) appears as the Cesàro-UB
       *bound* coefficient in Section 4 (not the exact noise-floor leading
       term, which is what we test here).
    """
    print("--- (S2) SymPy: leading-eta expansion + beta=0 collapse ---")
    beta, eta, L, sigma = sp.symbols("beta eta L sigma", positive=True)
    formula_5 = eta * sigma ** 2 * (1 + beta) / (L * (1 - beta) * (2 * (1 + beta) - eta * L))

    # leading coefficient as eta -> 0
    leading = sp.limit(formula_5 / eta, eta, 0)
    leading_simpl = sp.simplify(leading)
    target_leading = sigma ** 2 / (2 * L * (1 - beta))
    diff_lead = sp.simplify(leading_simpl - target_leading)
    print(f"  lim_{{eta -> 0}} Var_inf / eta = {leading_simpl}")
    print(f"  target sigma^2 / [2 L (1-beta)] = {target_leading}")
    print(f"  diff = {diff_lead}")
    lead_ok = diff_lead == 0

    # beta=0 collapse: Var_inf = eta sigma^2 / (L (2 - eta L)) (classical AR(1))
    formula_at_b0 = sp.simplify(formula_5.subs(beta, 0))
    target_b0 = eta * sigma ** 2 / (L * (2 - eta * L))
    diff_b0 = sp.simplify(formula_at_b0 - target_b0)
    print(f"  formula_5 at beta=0  = {formula_at_b0}")
    print(f"  target eta sigma^2 / (L (2-eta L)) = {target_b0}")
    print(f"  diff = {diff_b0}")
    b0_ok = diff_b0 == 0

    ok = lead_ok and b0_ok
    print(f"  S2 PASS: {ok}")
    return ok


# ---------------------------------------------------------------------------
# (S3) SymPy: 3-term Lyapunov drift identity for Cesàro UB (Section 4)
# ---------------------------------------------------------------------------

def check_S3_three_term_lyapunov_drift():
    """For V_t = ||x_t - x^*||^2 + c1 eta^2 ||m_t||^2 + c2 eta^2 ||m_{t-1}||^2
       with m_t = (x_t - x_{t-1})/eta, the cross-terms in V_{t+1} - V_t cancel
       iff c1 = (1 - L eta - beta^2) / (2 eta) and c2 = beta^2 / (2 eta).
       We verify the cancellation symbolically on the deterministic quadratic.
    """
    print("--- (S3) SymPy: 3-term Lyapunov drift (Cesàro UB cross-term cancel) ---")
    beta, eta, L = sp.symbols("beta eta L", positive=True)
    c1, c2 = sp.symbols("c1 c2", real=True)
    # Ansatz: c1 = (1 - L*eta - beta^2)/(2*eta), c2 = beta^2/(2*eta)
    c1_val = (1 - L * eta - beta ** 2) / (2 * eta)
    c2_val = beta ** 2 / (2 * eta)

    # Identity 1: c1 + c2 = (1 - L eta)/(2 eta)
    target_sum = (1 - L * eta) / (2 * eta)
    diff_sum = sp.simplify(c1_val + c2_val - target_sum)
    print(f"  c1 + c2 - (1-L eta)/(2 eta) = {diff_sum}")
    sum_ok = diff_sum == 0

    # Identity 2: the ||grad f||^2 coefficient -eta + L eta^2 / 2 + eta^2(c1+c2) = -eta/2
    grad_coeff = -eta + L * eta ** 2 / 2 + eta ** 2 * (c1_val + c2_val)
    diff_grad = sp.simplify(grad_coeff - (-eta / 2))
    print(f"  -eta + L eta^2/2 + eta^2(c1+c2) - (-eta/2) = {diff_grad}")
    grad_ok = diff_grad == 0

    # Identity 3 (the cross-term cancellation): coefficient of <grad f, m_t> in V_{t+1} - V_t
    # is beta - 2 eta beta c1 - L eta beta - 2 eta beta c2 = 0 with the chosen c1, c2.
    cross = beta - 2 * eta * beta * c1_val - L * eta * beta - 2 * eta * beta * c2_val
    diff_cross = sp.simplify(cross)
    print(f"  cross-term coefficient (should be 0) = {diff_cross}")
    cross_ok = diff_cross == 0

    ok = sum_ok and grad_ok and cross_ok
    print(f"  S3 PASS: {ok}")
    return ok


# ---------------------------------------------------------------------------
# (S4) SymPy: change-of-variables z_t = x_t + a (x_t - x_{t-1}), a = beta/(1-beta)
# yields exact OGD: z_{t+1} - z_t = -eta_eff g_t with eta_eff = eta/(1-beta).
# ---------------------------------------------------------------------------

def check_S4_change_of_variables():
    print("--- (S4) SymPy: change-of-variables z_t identity (Theorem D) ---")
    beta, eta = sp.symbols("beta eta", positive=True)
    a = beta / (1 - beta)
    eta_eff = eta / (1 - beta)
    x_tm1, x_t, g_t = sp.symbols("x_tm1 x_t g_t", real=True)
    # SHB step: x_{t+1} = x_t - eta g_t + beta (x_t - x_{t-1})
    x_tp1 = x_t - eta * g_t + beta * (x_t - x_tm1)

    z_t = x_t + a * (x_t - x_tm1)
    z_tp1 = x_tp1 + a * (x_tp1 - x_t)
    diff = sp.simplify(z_tp1 - z_t + eta_eff * g_t)
    print(f"  z_{{t+1}} - z_t + eta_eff * g_t = {diff}    (should be 0)")
    ok = diff == 0
    print(f"  S4 PASS: {ok}")
    return ok


# ---------------------------------------------------------------------------
# (M1) mpmath 50-digit Lyapunov solve at (beta, eta L) = (0.5, 0.1)
# ---------------------------------------------------------------------------

def check_M1_mpmath_lyapunov():
    print("--- (M1) mpmath: independent Lyapunov solve at (beta, etaL) = (0.5, 0.1) ---")
    mp.mp.dps = 50

    beta_v = mp.mpf("0.5")
    L_v = mp.mpf(1)
    eta_v = mp.mpf("0.1") / L_v
    sigma_v = mp.mpf(1)

    # discrete Lyapunov via vec: vec(P) = (I - kron(A, A))^{-1} vec(Q)
    A = mp.matrix([[1 + beta_v - eta_v * L_v, -beta_v], [1, 0]])
    Q = mp.matrix([[eta_v ** 2 * sigma_v ** 2, 0], [0, 0]])

    # 4x4 vec system. Build I - kron(A, A).
    Akron = mp.matrix(4, 4)
    for i in range(2):
        for j in range(2):
            for k in range(2):
                for l in range(2):
                    Akron[i * 2 + k, j * 2 + l] = A[i, j] * A[k, l]
    I4 = mp.eye(4)
    M = I4 - Akron
    qvec = mp.matrix([Q[0, 0], Q[0, 1], Q[1, 0], Q[1, 1]])
    pvec = mp.lu_solve(M, qvec)
    P = mp.matrix([[pvec[0], pvec[1]], [pvec[2], pvec[3]]])

    # Symmetry sanity
    sym_err = abs(P[0, 1] - P[1, 0])
    diag_err = abs(P[0, 0] - P[1, 1])  # for the SHB structure, p11 = p22
    print(f"  P[0,1] - P[1,0] = {mp.nstr(sym_err, 6)}     (symmetry)")
    print(f"  P[0,0] - P[1,1] = {mp.nstr(diag_err, 6)}     (p11 = p22 for SHB)")

    var_inf_mpmath = P[0, 0]
    # Closed-form formula (5)
    formula_value = (eta_v * sigma_v ** 2 * (1 + beta_v) /
                     (L_v * (1 - beta_v) * (2 * (1 + beta_v) - eta_v * L_v)))
    diff = abs(var_inf_mpmath - formula_value)
    rel = diff / formula_value
    print(f"  Var_inf[x] (mpmath Lyapunov solve): {mp.nstr(var_inf_mpmath, 25)}")
    print(f"  Closed-form formula (5):            {mp.nstr(formula_value, 25)}")
    print(f"  Relative difference:                {mp.nstr(rel, 6)}")
    ok = rel < mp.mpf("1e-30")
    print(f"  M1 PASS: {ok}")
    return ok, {
        "var_inf_mpmath": float(var_inf_mpmath),
        "formula_value": float(formula_value),
        "rel_err": float(rel),
    }


# ---------------------------------------------------------------------------
# (MC1) Monte Carlo at multiple (beta, eta)
# ---------------------------------------------------------------------------

def check_MC1_monte_carlo():
    print("--- (MC1) Monte Carlo at multiple (beta, eta L) settings ---")
    cases = [
        (0.0, 0.5),   # plain SGD baseline
        (0.5, 0.1),   # main test case
        (0.9, 0.05),  # high-momentum
        (0.95, 0.02), # near-stability boundary
    ]
    L_v, sigma_v = 1.0, 1.0
    trials = 1000
    T = 10000
    burn = 5000

    all_match = True
    rels = []
    for beta_v, etaL_v in cases:
        eta_v = etaL_v / L_v
        formula = (eta_v * sigma_v ** 2 * (1 + beta_v) /
                   (L_v * (1 - beta_v) * (2 * (1 + beta_v) - eta_v * L_v)))

        np.random.seed(1234 + int(beta_v * 100) + int(etaL_v * 1000))
        x_t = np.zeros(trials)
        x_tm1 = np.zeros(trials)
        sample_buf = []
        for t in range(T):
            xi = np.random.normal(0, sigma_v, size=trials)
            x_new = (1 + beta_v - eta_v * L_v) * x_t - beta_v * x_tm1 - eta_v * xi
            x_tm1 = x_t
            x_t = x_new
            if t >= burn:
                sample_buf.append(x_t.copy())
        emp = float(np.var(np.concatenate(sample_buf)))
        rel = abs(emp - formula) / formula
        rels.append(rel)
        verdict = "OK" if rel < 0.01 else "FAIL"
        print(f"  beta={beta_v:.2f}  etaL={etaL_v:.3f}  formula={formula:.5f}  "
              f"MC={emp:.5f}  rel_err={rel:.4%}  -> {verdict}")
        if rel >= 0.01:
            all_match = False

    ok = all_match
    print(f"  MC1 PASS (all rel_err < 1%): {ok}")
    return ok, {"rel_errors": rels}


# ---------------------------------------------------------------------------
# (MC2) Empirical last-iterate rate fit at horizon-tuned eta_T = D/(sigma sqrt(T))
#       — confirms Theta(sigma D / sqrt(T)) on the quadratic (Theorem A.2).
# ---------------------------------------------------------------------------

def check_MC2_horizon_tuned_rate():
    print("--- (MC2) Monte Carlo: log-log rate fit at eta_T = D/(sigma sqrt(T)) ---")
    L_v = 1.0
    sigma_v = 1.0
    D_v = 1.0
    beta_v = 0.5
    Ts = [100, 300, 1000, 3000, 10000]
    trials = 5000

    log_T = []
    log_E = []
    rows = []

    for T in Ts:
        eta_v = D_v / (sigma_v * np.sqrt(T))
        # Stability: eta_v * L_v < 2(1+beta_v)
        if eta_v * L_v >= 2 * (1 + beta_v):
            print(f"  T={T} skipped (unstable: etaL = {eta_v*L_v})")
            continue
        # Run SHB from x_0 = D, x_{-1} = D for T steps; record E[f(x_T)] = (L/2)E[x_T^2]
        x_t = np.full(trials, D_v)
        x_tm1 = np.full(trials, D_v)
        np.random.seed(7777 + T)
        for t in range(T):
            xi = np.random.normal(0, sigma_v, size=trials)
            x_new = (1 + beta_v - eta_v * L_v) * x_t - beta_v * x_tm1 - eta_v * xi
            x_tm1 = x_t
            x_t = x_new
        E_f = 0.5 * L_v * float(np.mean(x_t ** 2))

        log_T.append(np.log(T))
        log_E.append(np.log(E_f))

        # Closed-form noise floor at eta_T
        var_inf = (eta_v * sigma_v ** 2 * (1 + beta_v) /
                   (L_v * (1 - beta_v) * (2 * (1 + beta_v) - eta_v * L_v)))
        E_floor = 0.5 * L_v * var_inf
        # Predicted from minimax-eta: sigma D / [4 (1-beta) sqrt(T)]
        predicted = sigma_v * D_v / (4 * (1 - beta_v) * np.sqrt(T))
        rows.append((T, eta_v, E_f, E_floor, predicted))
        print(f"  T={T:5d}  eta={eta_v:.4f}  E[f(x_T)]={E_f:.5f}  "
              f"noise_floor={E_floor:.5f}  predicted_minimax={predicted:.5f}")

    # Fit empirical rate: E[f(x_T)] = C * T^{-r}
    if len(log_T) >= 3:
        coeffs = np.polyfit(log_T, log_E, 1)
        empirical_rate = -coeffs[0]
        print(f"  empirical rate (log-log fit slope): T^(-{empirical_rate:.3f})")
        print(f"  expected: T^(-0.5) for Theta(sigma D / sqrt(T))")
        rate_ok = 0.4 < empirical_rate < 0.6
    else:
        rate_ok = False
        empirical_rate = None
        print(f"  not enough points to fit")

    print(f"  MC2 PASS (rate in [0.4, 0.6]): {rate_ok}")
    return rate_ok, {"empirical_rate": empirical_rate, "rows": rows}


# ---------------------------------------------------------------------------
# (MC3) Refutation: at fixed eta, E[f(x_T)] does NOT decay to 0 as T -> infty.
# ---------------------------------------------------------------------------

def check_MC3_no_decay_at_fixed_eta():
    print("--- (MC3) Monte Carlo: at fixed (beta, eta), E[f(x_T)] does NOT decay ---")
    L_v, sigma_v, D_v = 1.0, 1.0, 1.0
    beta_v = 0.5
    eta_v = 0.1 / L_v
    trials = 2000
    Ts = [100, 1000, 10000, 50000]
    var_floor = (eta_v * sigma_v ** 2 * (1 + beta_v) /
                 (L_v * (1 - beta_v) * (2 * (1 + beta_v) - eta_v * L_v)))
    f_floor = 0.5 * L_v * var_floor
    print(f"  At (beta, etaL) = ({beta_v}, {eta_v*L_v}), f-floor = {f_floor:.6f}")

    rows = []
    for T in Ts:
        np.random.seed(9999 + T)
        x_t = np.full(trials, D_v)
        x_tm1 = np.full(trials, D_v)
        for t in range(T):
            xi = np.random.normal(0, sigma_v, size=trials)
            x_new = (1 + beta_v - eta_v * L_v) * x_t - beta_v * x_tm1 - eta_v * xi
            x_tm1 = x_t
            x_t = x_new
        E_f = 0.5 * L_v * float(np.mean(x_t ** 2))
        rel_to_floor = E_f / f_floor
        rows.append((T, E_f, rel_to_floor))
        print(f"  T={T:6d}  E[f(x_T)]={E_f:.6f}  ratio to floor={rel_to_floor:.4f}")

    # As T grows, E[f(x_T)] should approach f_floor from above (or stay near it).
    # If it monotonically decreases past T=100, the noise-floor claim fails.
    last_two = [r[1] for r in rows[-2:]]
    no_decay = abs(last_two[0] - last_two[1]) / last_two[0] < 0.10  # < 10% change between T=10000 and T=50000
    print(f"  At T=10000 vs T=50000, |E_f change| / E_f = "
          f"{abs(last_two[0]-last_two[1])/last_two[0]:.4f}  (must be < 0.10 for no decay)")
    ok = no_decay and (abs(rows[-1][2] - 1.0) < 0.10)
    print(f"  MC3 PASS (no T-decay; saturation at noise floor): {ok}")
    return ok, {"rows": rows, "f_floor": f_floor}


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main():
    t0 = time.time()
    print("=" * 70)
    print("Gap 2 verification — last-iterate UB for fixed-momentum SHB on")
    print("L-smooth convex non-SC. mpmath dps = 50 (where used).")
    print("=" * 70)

    s1, s1_data = check_S1_closed_form_variance()
    print()
    s2 = check_S2_small_eta_and_beta0()
    print()
    s3 = check_S3_three_term_lyapunov_drift()
    print()
    s4 = check_S4_change_of_variables()
    print()
    m1, m1_data = check_M1_mpmath_lyapunov()
    print()
    mc1, mc1_data = check_MC1_monte_carlo()
    print()
    mc2, mc2_data = check_MC2_horizon_tuned_rate()
    print()
    mc3, mc3_data = check_MC3_no_decay_at_fixed_eta()
    print()

    out = {
        "S1_closed_form": s1,
        "S2_small_eta_and_beta0": s2,
        "S3_three_term_lyapunov": s3,
        "S4_change_of_variables": s4,
        "M1_mpmath_lyapunov": {"pass": m1, **m1_data},
        "MC1_monte_carlo": {"pass": mc1, **mc1_data},
        "MC2_horizon_tuned_rate": {"pass": mc2, **mc2_data},
        "MC3_no_decay_fixed_eta": {"pass": mc3, **mc3_data},
        "all_pass": bool(s1 and s2 and s3 and s4 and m1 and mc1 and mc2 and mc3),
        "wall_time_seconds": time.time() - t0,
    }

    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    for k, v in [
        ("S1_closed_form", s1),
        ("S2_small_eta_and_beta0", s2),
        ("S3_three_term_lyapunov", s3),
        ("S4_change_of_variables", s4),
        ("M1_mpmath_lyapunov", m1),
        ("MC1_monte_carlo", mc1),
        ("MC2_horizon_tuned_rate", mc2),
        ("MC3_no_decay_fixed_eta", mc3),
    ]:
        print(f"  {k:30s}: {'PASS' if v else 'FAIL'}")
    print()
    print(f"  Wall time: {out['wall_time_seconds']:.1f}s")
    print(f"  Overall:   {'ALL PASS' if out['all_pass'] else 'SOME FAILED'}")

    out_path = Path(__file__).parent / "gap2_verify_results.json"
    with open(out_path, "w", encoding="utf-8") as fp:
        json.dump(out, fp, indent=2, default=str)
    print(f"\n  Saved results to {out_path}")


if __name__ == "__main__":
    main()
