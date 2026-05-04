"""Direct simulation of SHB on a worst-case 1-D quadratic at high β, large T.

For SHB on f(x) = (L/2) x², the iterate is:
   x_{t+1} = x_t - η L x_t + β (x_t - x_{t-1})
          = (1 - η L + β) x_t - β x_{t-1}

This is a 2-step linear recurrence. The eigenvalues of the companion matrix tell us
the asymptotic decay rate.

For 1-D quadratic, this is exactly solvable. Compare with the LMI's bound.
"""
from pathlib import Path
import numpy as np


def simulate_1d_quadratic(L, beta, eta, x0, T):
    """Simulate SHB on f(x) = (L/2) x²."""
    x = [x0, x0]  # x_{-1} = x_0
    for t in range(T):
        x_new = (1 - eta * L + beta) * x[-1] - beta * x[-2]
        x.append(x_new)
    return np.array(x[1:])  # x_0, x_1, ..., x_T


def main():
    L = 1.0
    print("Comparing LMI bound C(β) with actual 1-D quadratic worst case at large T:")
    print()
    cases = [
        (0.93, 0.02),    # LMI says C(0.93) ≈ 8.26
        (0.95, 0.03),    # C(0.95) ≈ 13.66
        (0.97, 0.02),    # LMI INFEASIBLE; PEP says τ·T~1.5 at T=12
        (0.99, 0.005),   # Way past LMI frontier
    ]

    for beta, eta in cases:
        x0 = 1.0
        T_list = [10, 30, 100, 300, 1000, 3000]
        max_T = max(T_list)
        xs = simulate_1d_quadratic(L, beta, eta, x0, max_T)
        f_at_T = (L/2) * xs**2  # f(x) - f* = (L/2) x²
        # The "rate" is (f_T - f*) / (LD²/T) = (L/2 x²_T) / (L · 1 / T) = x²_T · T / 2
        # We want the maximum over t ≤ T, since worst-case may not be at t=T.
        x_norm_2 = xs**2

        print(f"β={beta}, η={eta}:")
        print(f"  T : f(x_T)-f* : f(x_T)·T/D² : max f over t≤T : max f·t/D²")
        for T in T_list:
            f_T = (L/2) * xs[T]**2
            f_T_T = f_T * T   # if rate is C/T, this should saturate at C·LD²/2 → C/2
            # Take max over t ≤ T
            f_max = (L/2) * np.max(xs[:T+1]**2)
            f_max_T = f_max * T
            print(f"   T={T:>4}  f={f_T:.4e}  f·T={f_T_T:.4e}  max f={f_max:.4e}  max f·T={f_max_T:.4e}")

        # Asymptotic decay rate from companion matrix
        # x_{t+1} = a x_t - b x_{t-1}, a = 1 - ηL + β, b = β
        # Char poly: λ² - aλ + b = 0; eigenvalues:
        a = 1 - eta * L + beta
        b = beta
        disc = a**2 - 4*b
        if disc < 0:
            mag = np.sqrt(b)  # complex roots, magnitude = √β
            print(f"  Complex eigenvalues; magnitude = √β = {mag:.6f}")
            print(f"  Asymptotic rate: |x_t| ~ |λ|^t = {mag**100:.4e} at t=100")
        else:
            lam1 = (a + np.sqrt(disc)) / 2
            lam2 = (a - np.sqrt(disc)) / 2
            print(f"  Real eigenvalues: λ1={lam1:.6f}, λ2={lam2:.6f}, ρ=max|λ|={max(abs(lam1), abs(lam2)):.6f}")
        print()


if __name__ == "__main__":
    main()
