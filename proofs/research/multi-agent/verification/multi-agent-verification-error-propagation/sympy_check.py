"""Numerical verification for Problem 4.1 part (c)."""
from sympy import Rational, N
import numpy as np

# === Symbolic / exact ===
eps = Rational(14, 100)
k, T = 3, 10
single_shot = (1 - eps)**T
k_retry = (1 - eps**k)**T
print("=== Exact ===")
print(f"eps^k          = {eps**k} = {N(eps**k, 6)}")
print(f"(1-eps)^T      = {single_shot} ≈ {N(single_shot, 6)}")
print(f"(1-eps^k)^T    = {k_retry} ≈ {N(k_retry, 6)}")

# === Monte Carlo ===
rng = np.random.default_rng(42)
N_sim = 500_000
e = float(eps)

errs_ss = (rng.random((N_sim, T)) < e).any(axis=1)
p_ss = 1 - errs_ss.mean()

errs_kr = (rng.random((N_sim, T, k)) < e).all(axis=2).any(axis=1)
p_kr = 1 - errs_kr.mean()

print("\n=== Monte Carlo (500k trials) ===")
print(f"Single-shot empirical: {p_ss:.4f}, theory: {(1-e)**T:.4f}")
print(f"k-retry empirical:     {p_kr:.4f}, theory: {(1-e**k)**T:.4f}")
print(f"Reliability lift:      {p_kr/p_ss:.3f}x")
