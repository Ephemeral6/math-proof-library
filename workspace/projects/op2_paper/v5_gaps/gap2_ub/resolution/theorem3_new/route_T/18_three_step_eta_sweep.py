"""3-step LMI: sweep η at fixed β to find any feasible (β, η)."""
from pathlib import Path
import sys, json
sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
m = import_module("15_three_step_lmi")
build_lmi_three_step = m.build_lmi_three_step

L = 1.0
results = []
for beta in [0.0, 0.1, 0.2, 0.3, 0.4, 0.5]:
    print(f"\n=== β = {beta} ===")
    for eta in [0.3, 0.5, 0.7, 0.9, 1.0, 1.1, 1.2, 1.3, 1.5, 1.7, 1.9]:
        try:
            r = build_lmi_three_step(L, beta, eta, fix_alpha=1.0, minimize="C")
        except Exception as e:
            print(f"  η={eta:.2f}: error {str(e)[:50]}")
            continue
        if r["status"] == "optimal" and r.get("W") and r["W"] >= 0.999 and r.get("C_Lya"):
            print(f"  η={eta:.2f}: optimal, W={r['W']:.4f}, C={r['C_Lya']:.4f}")
            results.append({"beta": beta, "eta": eta, "W": r["W"], "C_Lya": r["C_Lya"], "S": r["S"]})
        else:
            print(f"  η={eta:.2f}: {r['status']}")

out = Path(__file__).parent / "18_three_step_eta_sweep_results.json"
out.write_text(json.dumps(results, indent=2))
print(f"\nSaved: {out}")
