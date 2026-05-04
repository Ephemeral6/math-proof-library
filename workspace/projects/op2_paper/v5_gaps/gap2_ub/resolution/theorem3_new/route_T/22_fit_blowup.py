"""Fit C(β) blow-up rate.

Combine all CLARABEL-tight C(β) data and fit:
  Model 1: C(β) = K * (β* - β)^{-p}
  Model 2: C(β) = K * (1 - β)^{-q}
  Model 3: log C(β) = a + b/(β* - β) + c/(1-β)
"""
from pathlib import Path
import json
import numpy as np

ROOT = Path(__file__).parent

# Collect all CLARABEL-tight C(β) data from steps 17, 19, 20, 21
data = []
for fname in ["17_clarabel_2step_sweep_results.json",
              "19_clarabel_dense_finer_results.json",
              "20_lmi_boundary_extreme_results.json",
              "21_lmi_boundary_precise_results.json"]:
    p = ROOT / fname
    if not p.exists(): continue
    j = json.loads(p.read_text())
    if isinstance(j, dict) and "region_A" in j:
        items = j["region_A"] + j["region_B"]
    else:
        items = j
    for r in items:
        if r.get("feasible") is False: continue
        if r.get("C_Lya") is None: continue
        data.append({"beta": r["beta"], "C": r["C_Lya"], "W": r.get("W"), "eta": r.get("eta_opt")})

# Dedupe (keep the smallest C per β within tolerance)
by_beta = {}
for d in data:
    b = round(d["beta"], 4)
    if b not in by_beta or d["C"] < by_beta[b]["C"]:
        by_beta[b] = d
betas = sorted(by_beta)
data = [by_beta[b] for b in betas]

print(f"# unique β values: {len(data)}")
print()
print(f"{'β':>6} {'C':>10} {'log10 C':>10} {'(1-β)':>10} {'-log(1-β)':>10}")
print("-" * 60)
for d in data:
    b = d["beta"]; C = d["C"]
    if 1 - b > 0:
        print(f"{b:>6.3f} {C:>10.4f} {np.log10(C):>10.3f} {1-b:>10.4f} {-np.log(1-b):>10.4f}")

# Model fitting
betas_arr = np.array([d["beta"] for d in data])
C_arr = np.array([d["C"] for d in data])
mask = (betas_arr > 0) & np.isfinite(C_arr)

# Model: C = K (β* - β)^{-p}; log C = log K - p log(β* - β)
# Try β* = 0.957 (LMI infeasibility frontier).
print(f"\n{'='*60}")
print("Model 1: C(β) = K · (β* - β)^{-p} with β* = 0.957")
print(f"{'='*60}")
beta_star = 0.957
delta = beta_star - betas_arr
mask1 = (delta > 0) & (betas_arr >= 0.30)  # restrict to where blow-up is visible
log_delta = np.log(delta[mask1])
log_C = np.log(C_arr[mask1])
slope, intercept = np.polyfit(log_delta, log_C, 1)
print(f"  Fit on β ∈ [0.30, 0.956]:")
print(f"  log C = {intercept:.3f} + {slope:.3f} · log(β* - β)")
print(f"  ⇒ C ≈ {np.exp(intercept):.4f} · (β* - β)^{slope:.3f}")
print(f"  i.e., p ≈ {-slope:.3f}, K ≈ {np.exp(intercept):.4f}")

# Model 2: C = K (1-β)^{-q}
print(f"\n{'='*60}")
print("Model 2: C(β) = K · (1 - β)^{-q}")
print(f"{'='*60}")
mask2 = (betas_arr >= 0.30) & (betas_arr < 1)
log_om = np.log(1 - betas_arr[mask2])
log_C = np.log(C_arr[mask2])
slope2, intercept2 = np.polyfit(log_om, log_C, 1)
print(f"  Fit on β ∈ [0.30, 0.956]:")
print(f"  log C = {intercept2:.3f} + {slope2:.3f} · log(1 - β)")
print(f"  ⇒ C ≈ {np.exp(intercept2):.4f} · (1-β)^{slope2:.3f}")
print(f"  i.e., q ≈ {-slope2:.3f}, K ≈ {np.exp(intercept2):.4f}")

# Plot residuals
print(f"\nResiduals (log C - fit) for Model 2:")
for d in data:
    b = d["beta"]; C = d["C"]
    if b < 0.30 or 1-b <= 0: continue
    pred = intercept2 + slope2 * np.log(1-b)
    res = np.log(C) - pred
    print(f"  β={b:.3f}: log C = {np.log(C):.3f}, pred = {pred:.3f}, res = {res:+.3f}")

# Try mixed model: C = K (1-β)^{-q} (β* - β)^{-p}
print(f"\n{'='*60}")
print("Model 3: C(β) = K · (1-β)^{-q} · (β* - β)^{-p}")
print(f"{'='*60}")
beta_star = 0.957
mask3 = (betas_arr >= 0.30) & (betas_arr < beta_star - 0.001)
log_om = np.log(1 - betas_arr[mask3])
log_delta = np.log(beta_star - betas_arr[mask3])
log_C = np.log(C_arr[mask3])
A = np.column_stack([np.ones_like(log_om), log_om, log_delta])
coefs, *_ = np.linalg.lstsq(A, log_C, rcond=None)
log_K, slope_om, slope_delta = coefs
print(f"  Fit on β ∈ [0.30, 0.956]:")
print(f"  log C = {log_K:.3f} + {slope_om:.3f}·log(1-β) + {slope_delta:.3f}·log(β*-β)")
print(f"  ⇒ C ≈ {np.exp(log_K):.4f} · (1-β)^{slope_om:.3f} · (β*-β)^{slope_delta:.3f}")
print(f"  i.e., q ≈ {-slope_om:.3f}, p ≈ {-slope_delta:.3f}, K ≈ {np.exp(log_K):.4f}")

# Save final table
final = [{"beta": d["beta"], "C": d["C"], "W": d["W"], "eta_opt": d["eta"]} for d in data]
out = ROOT / "22_fit_blowup_results.json"
out.write_text(json.dumps(final, indent=2))
print(f"\nSaved table: {out}")
