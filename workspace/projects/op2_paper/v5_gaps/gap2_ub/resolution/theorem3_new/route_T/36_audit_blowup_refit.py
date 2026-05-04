"""Audit 4: Re-fit C(β) blow-up using k=1 and k=2 lookahead data, check if power law is consistent.

Compare:
  - Round-2 fit (k=0): C(β) ≈ 0.39 · (1-β)^{-1.245}
  - Round-3 fit (k=1): re-fit using lookahead data
  - Round-4 fit (k=2): re-fit using 2-step lookahead data

If p (exponent) varies significantly between fits, the blow-up is NOT a clean power law.
"""
import numpy as np
import json
from pathlib import Path

ROOT = Path(__file__).parent

# Load data: k=0 (baseline)
data_k0 = []
for p in [ROOT / "17_clarabel_2step_sweep_results.json",
          ROOT / "19_clarabel_dense_finer_results.json",
          ROOT / "20_lmi_boundary_extreme_results.json",
          ROOT / "21_lmi_boundary_precise_results.json"]:
    if not p.exists(): continue
    j = json.loads(p.read_text())
    items = j.get("region_A", []) + j.get("region_B", []) if isinstance(j, dict) else j
    for r in items:
        if not r.get("feasible"): continue
        if r.get("C_Lya") is None: continue
        data_k0.append({"beta": r["beta"], "C": r["C_Lya"]})

# Dedupe k=0
by_beta_k0 = {}
for d in data_k0:
    b = round(d["beta"], 4)
    if b not in by_beta_k0 or d["C"] < by_beta_k0[b]["C"]:
        by_beta_k0[b] = d
data_k0 = sorted(by_beta_k0.values(), key=lambda x: x["beta"])

# k=1 (1-step lookahead) — from 28_lookahead_summary_results.json
data_k1 = []
p = ROOT / "28_lookahead_summary_results.json"
if p.exists():
    items = json.loads(p.read_text())
    for r in items:
        if r.get("feasible") is False: continue
        if r.get("C") is None: continue
        data_k1.append({"beta": r["beta"], "C": r["C"]})

# k=1 boundary extension — 27_lookahead_boundary_results.json
p = ROOT / "27_lookahead_boundary_results.json"
if p.exists():
    items = json.loads(p.read_text())
    for r in items:
        if not r.get("feasible"): continue
        if r.get("C_Lya") is None: continue
        # Skip the noisy ones in [0.98, 0.984]
        if r["beta"] > 0.978: continue
        data_k1.append({"beta": r["beta"], "C": r["C_Lya"]})

# k=2 — from inline data (2-step sweep at high β)
data_k2 = list(data_k1)  # k=2 ≥ k=1 always
data_k2.extend([
    {"beta": 0.97, "C": 31.73},
    {"beta": 0.98, "C": 38.40},
    {"beta": 0.985, "C": 63.80},
    {"beta": 0.99, "C": 57.73},
    {"beta": 0.992, "C": 156.58},
])
# dedupe
by_beta_k2 = {}
for d in data_k2:
    b = round(d["beta"], 4)
    if b not in by_beta_k2 or d["C"] < by_beta_k2[b]["C"]:
        by_beta_k2[b] = d
data_k2 = sorted(by_beta_k2.values(), key=lambda x: x["beta"])


def fit_powerlaw(data, beta_min=0.30):
    pts = [(d["beta"], d["C"]) for d in data if d["beta"] >= beta_min and d["beta"] < 1.0]
    if len(pts) < 3: return None
    betas = np.array([p[0] for p in pts])
    Cs = np.array([p[1] for p in pts])
    log_om = np.log(1 - betas)
    log_C = np.log(Cs)
    slope, intercept = np.polyfit(log_om, log_C, 1)
    K = np.exp(intercept); p = -slope
    return {"K": K, "p": p, "n_points": len(pts), "betas": list(betas)}


print("=" * 80)
print("Audit 4: Re-fit C(β) blow-up")
print("=" * 80)

print("\nFit C(β) ≈ K (1-β)^{-p}, restricted to β ∈ [0.30, ~max]:\n")
for label, data in [("k=0 (baseline)", data_k0), ("k=1 (1-step lookahead)", data_k1),
                    ("k=2 (2-step lookahead)", data_k2)]:
    fit = fit_powerlaw(data)
    if fit:
        bmax = max(fit["betas"])
        print(f"  {label}: K = {fit['K']:.4f}, p = {fit['p']:.3f} ({fit['n_points']} pts, β ≤ {bmax:.3f})")
    else:
        print(f"  {label}: insufficient data")

print("\nFit also on β ∈ [0.7, ~max] (frontier regime only):\n")
for label, data in [("k=0", data_k0), ("k=1", data_k1), ("k=2", data_k2)]:
    fit = fit_powerlaw(data, beta_min=0.7)
    if fit:
        bmax = max(fit["betas"])
        print(f"  {label}: K = {fit['K']:.4f}, p = {fit['p']:.3f} ({fit['n_points']} pts, β ∈ [0.7, {bmax:.3f}])")

# Print the actual data
print("\n" + "-" * 80)
print(f"{'β':>6} {'C(k=0)':>10} {'C(k=1)':>10} {'C(k=2)':>10}")
print("-" * 80)
all_betas = sorted(set([round(d["beta"], 3) for d in data_k0 + data_k1 + data_k2]))
by_beta = {("k0", round(d["beta"],3)): d["C"] for d in data_k0}
by_beta.update({("k1", round(d["beta"],3)): d["C"] for d in data_k1})
by_beta.update({("k2", round(d["beta"],3)): d["C"] for d in data_k2})
for b in all_betas:
    if b > 0.998: continue
    c0 = by_beta.get(("k0", b), None)
    c1 = by_beta.get(("k1", b), None)
    c2 = by_beta.get(("k2", b), None)
    s0 = f"{c0:.3f}" if c0 else "-"
    s1 = f"{c1:.3f}" if c1 else "-"
    s2 = f"{c2:.3f}" if c2 else "-"
    print(f"{b:>6.3f} {s0:>10} {s1:>10} {s2:>10}")
