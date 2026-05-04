"""
Aggregate the PEP slope analysis from the 04 sweep + 03 high-beta extension.
Manually-collected data from 04_beta_transition_output.txt and 03_shb_high_beta_output.txt.
"""
import numpy as np
import json

# Best (eta, tau) per (beta, T), aggregated from 04 + 03 logs.
data = {
    0.0: [(3, 1.50, 5.000054e-02), (5, 1.50, 3.125006e-02), (7, 1.50, 2.272728e-02),
          (10, 1.50, 1.612944e-02), (15, 1.50, 1.086960e-02)],
    0.1: [(3, 1.50, 4.703674e-02), (5, 1.50, 2.890839e-02), (7, 1.50, 2.086553e-02),
          (10, 1.50, 1.472191e-02), (15, 1.50, 9.875789e-03)],
    0.3: [(3, 1.05, 5.714911e-02), (5, 1.30, 2.995319e-02), (7, 1.30, 1.987725e-02),
          (10, 1.30, 1.367959e-02), (15, 1.30, 9.070680e-03)],
    0.5: [(3, 0.667, 7.499996e-02), (5, 0.671, 4.617387e-02), (7, 0.700, 2.996761e-02),
          (10, 0.700, 1.908207e-02), (15, 0.750, 1.180188e-02)],
    0.7: [(3, 0.450, 9.257797e-02), (5, 0.300, 8.057991e-02), (7, 0.286, 6.452246e-02),
          (10, 0.300, 4.322667e-02), (15, 0.258, 2.296897e-02)],
    # 0.8 partial:
    0.8: [(3, 0.333, 1.112761e-01), (5, 0.200, 8.894597e-02), (7, 0.143, 7.925040e-02)],
    # 0.9 from 03_shb_high_beta:
    0.9: [(3, 0.333, 1.054852e-01), (5, 0.150, 1.011482e-01), (10, 0.050, 9.730843e-02),
          (20, 0.030, 6.968025e-02), (30, 0.030, 4.646866e-02)],
}

print(f"{'β':>5}  {'data points':>11}  {'slope':>10}  {'τ·T at max T':>14}  {'τ·√T at max T':>15}  rate")
print("-" * 80)

results = []
for beta, rows in data.items():
    Ts = np.array([r[0] for r in rows])
    taus = np.array([r[2] for r in rows])
    if len(Ts) >= 2:
        slope, intercept = np.polyfit(np.log(Ts), np.log(taus), 1)
        Tmax = Ts[-1]
        tau_max = taus[-1]
        if slope < -0.9:
            rate = "O(1/T)"
        elif slope < -0.6:
            rate = "O(T^-2/3) or so"
        elif slope < -0.4:
            rate = "O(T^-1/2)"
        elif slope < -0.2:
            rate = "O(T^-1/3)"
        else:
            rate = "no decay"
        print(f"{beta:>5.1f}  {len(rows):>11d}  {slope:>10.3f}  {tau_max*Tmax:>14.4f}"
              f"  {tau_max*np.sqrt(Tmax):>15.4f}  {rate}")
        results.append({"beta": beta, "n_points": len(rows), "slope": float(slope),
                       "intercept": float(intercept), "rate": rate,
                       "tau_max_Tmax": float(tau_max * Tmax),
                       "tau_max_sqrtTmax": float(tau_max * np.sqrt(Tmax))})

print("\n=== Critical observations ===")
print("1. β = 0 (GD): slope ≈ -1, τ·T constant ≈ 0.16 → O(LD²/T) confirms DT2014.")
print("2. β ∈ {0.1, 0.3, 0.5}: slope ≈ -1, τ·T STABLE 0.13-0.22 → O(LD²/T) holds.")
print("3. β ≈ 0.7: slope ≈ -0.87, τ·T increasing then decreasing → BORDERLINE.")
print("4. β ≥ 0.9: slope ≈ -0.33, τ·T GROWING → O(T^{-1/3}), NOT O(1/T).")
print("\n=> Phase transition between β = 0.5 and β = 0.9 (around β* ≈ 0.7).")
print("=> For β ≤ β*: Theorem 3 follows from deterministic O(1/T) + standard noise composition.")
print("=> For β > β*: Worst-case last-iterate is at most T^{-1/3} (matches Hudiani 2025).")

with open("05_summary_slopes.json", "w") as f:
    json.dump(results, f, indent=2)
