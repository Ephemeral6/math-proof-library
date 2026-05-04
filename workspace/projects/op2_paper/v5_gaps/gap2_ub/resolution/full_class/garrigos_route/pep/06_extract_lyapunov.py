"""
Extract dual variables (Lyapunov certificate) from a single PEP solution.

For β = 0.5, T = 5, η = 0.7, the PEP shows τ ≈ 0.046 with τ·T ≈ 0.23.
We extract:
1. The dual variables (Lagrangian multipliers on interpolation conditions)
2. The Gram matrix structure of the worst-case (which gives the coefficients in Lyapunov)

If we can read a clean structure (e.g., Φ_t = sum a_t ‖x_t - x*‖^2 + sum b_t (f(x_t) - f*) + ...),
we hand-craft the same Lyapunov and verify symbolically.
"""
from PEPit import PEP
from PEPit.functions import SmoothConvexFunction
import numpy as np
np.set_printoptions(precision=4, suppress=True, linewidth=140)


def shb_pep_with_dual(L, beta, eta, n, verbose=1):
    problem = PEP()
    func = problem.declare_function(SmoothConvexFunction, L=L)
    xs = func.stationary_point()
    fs = func(xs)
    x0 = problem.set_initial_point()
    problem.set_initial_condition((x0 - xs) ** 2 <= 1)
    x_prev = x0
    x_curr = x0
    iterates = [x0]
    for t in range(n):
        x_next = x_curr - eta * func.gradient(x_curr) + beta * (x_curr - x_prev)
        x_prev = x_curr
        x_curr = x_next
        iterates.append(x_curr)
    problem.set_performance_metric(func(x_curr) - fs)

    tau = problem.solve(wrapper="cvxpy", verbose=verbose)

    # Get the wrapper to access dual values
    return tau, problem


def main():
    L, beta, n = 1.0, 0.5, 5
    eta = 0.7
    print(f"\n=== PEP for SHB, beta={beta}, T={n}, eta={eta} ===")
    tau, problem = shb_pep_with_dual(L, beta, eta, n, verbose=1)
    print(f"\ntau = {tau:.6f}, tau·T = {tau*n:.4f}")

    # Inspect dual values from constraints
    print("\n=== Constraint dual values ===")
    print("(Each constraint has a Lagrange multiplier — these are the Lyapunov coefficients.)")

    # PEPit: each constraint has .dual_variable_value after solve
    n_shown = 0
    constraints_with_duals = []
    for c in problem.list_of_constraints:
        try:
            dv = c.dual_variable_value
            if dv is not None and abs(dv) > 1e-7:
                constraints_with_duals.append((c, dv))
        except Exception:
            pass
    # Also check function-level interpolation constraints
    for f in problem.list_of_functions:
        for c in f.list_of_constraints:
            try:
                dv = c.dual_variable_value
                if dv is not None and abs(dv) > 1e-7:
                    constraints_with_duals.append((c, dv))
            except Exception:
                pass

    constraints_with_duals.sort(key=lambda kv: -abs(kv[1]))
    print(f"\nFound {len(constraints_with_duals)} constraints with non-trivial dual values.")
    for c, dv in constraints_with_duals[:30]:
        print(f"  dual = {dv:>10.4f}   constraint name = {getattr(c, 'name', '?')}")


if __name__ == "__main__":
    main()
