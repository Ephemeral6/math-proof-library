"""Quick sanity test of 3-step LMI before launching full sweep."""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).parent))
from importlib import import_module
m = import_module("15_three_step_lmi")
build_lmi_three_step = m.build_lmi_three_step

L = 1.0
print("Test 1: β=0, η=1/L (plain GD).")
r = build_lmi_three_step(L, 0.0, 1.0/L, fix_alpha=1.0, minimize="C")
print(f"  status: {r['status']}")
print(f"  W: {r['W']}, C_Lya: {r.get('C_Lya')}")

print("\nTest 2: β=0.5, η=1.5/L.")
r = build_lmi_three_step(L, 0.5, 1.5/L, fix_alpha=1.0, minimize="C")
print(f"  status: {r['status']}")
print(f"  W: {r['W']}, C_Lya: {r.get('C_Lya')}")
print(f"  S: {r.get('S')}")
print(f"  Coeffs:")
for k in ["a0","a1","a2","a3","c01","c02","c03","c12","c13","c23"]:
    v = r.get(k)
    if v is not None: print(f"    {k} = {v:+.4f}")

print("\nTest 3: β=0.5, η=1.0/L.")
r = build_lmi_three_step(L, 0.5, 1.0/L, fix_alpha=1.0, minimize="C")
print(f"  status: {r['status']}, C_Lya: {r.get('C_Lya')}")
