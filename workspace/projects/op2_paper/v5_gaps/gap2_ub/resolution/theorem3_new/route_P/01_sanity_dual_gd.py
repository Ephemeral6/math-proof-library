"""Route P, sanity #1.

Goal:
- At beta=0 (= GD), reproduce Drori-Teboulle exact rate L D^2/(4T+2).
- Verify we can ALSO read out the dual variables of interpolation constraints
  (these are the Lyapunov coefficients in the closed-form quadratic certificate).

Plan:
1. Build PEP problem for SHB at beta=0, eta=1/L, T=5.
2. Solve.
3. Read the duals on every interpolation constraint of the smooth-convex function class.
4. Report (i, j, dual_value) for the non-zero ones, sorted.
   For GD, the structurally non-zero pairs should be (i, i+1) - i.e. consecutive iterates -
   which is consistent with the chain-form Lyapunov used by Drori-Teboulle.

If duals are accessible: route is unblocked, we move on to beta=0.3.
If duals are not accessible from PEPit alone: we fall back to a manual cvxpy SDP in step 02.
"""
from PEPit import PEP
from PEPit.functions import SmoothConvexFunction
import numpy as np

np.set_printoptions(precision=4, suppress=True, linewidth=160)


def build_shb_pep(L, beta, eta, n):
    problem = PEP()
    func = problem.declare_function(SmoothConvexFunction, L=L)
    xs = func.stationary_point()
    fs = func(xs)
    x0 = problem.set_initial_point()
    problem.set_initial_condition((x0 - xs) ** 2 <= 1)

    iterates = [x0]
    x_prev = x0
    x_curr = x0
    for _ in range(n):
        g = func.gradient(x_curr)
        x_next = x_curr - eta * g + beta * (x_curr - x_prev)
        x_prev = x_curr
        x_curr = x_next
        iterates.append(x_curr)

    problem.set_performance_metric(func(x_curr) - fs)
    return problem, iterates, func, xs


def main():
    L = 1.0
    beta = 0.0
    n = 5
    eta = 1.0 / L

    print(f"\n=== Sanity (β=0=GD): T={n}, eta={eta}, L={L} ===")
    problem, iterates, func, xs = build_shb_pep(L, beta, eta, n)
    tau = problem.solve(wrapper="cvxpy", verbose=1)
    target = L / (4 * n + 2)
    print(f"PEP τ              = {tau:.8e}")
    print(f"L/(4T+2) predicted = {target:.8e}")
    print(f"ratio              = {tau/target:.6f}")
    assert abs(tau / target - 1) < 1e-3, "GD sanity FAILED"
    print("OK: GD sanity passed.")

    # Now extract the dual values on interpolation constraints of `func`.
    # PEPit stores them in func.list_of_class_constraints (or list_of_constraints) after solve.
    print("\n=== Interpolation-constraint duals on `func` ===")
    candidate_lists = []
    for attr in ("list_of_class_constraints", "list_of_constraints"):
        if hasattr(func, attr):
            candidate_lists.append((attr, getattr(func, attr)))
    print(f"Found attributes: {[a for a,_ in candidate_lists]}")

    duals = []
    for attr, lst in candidate_lists:
        for c in lst:
            dv = getattr(c, "dual_variable_value", None)
            if dv is None:
                continue
            if abs(dv) < 1e-10:
                continue
            name = getattr(c, "name", None) or repr(c)[:80]
            duals.append((attr, name, float(dv)))

    duals.sort(key=lambda x: -abs(x[2]))
    print(f"Total non-trivial duals: {len(duals)}")
    for attr, name, dv in duals[:60]:
        print(f"  [{attr}] dual={dv:>10.5f}   {name}")

    # Also count per-attribute summaries
    if hasattr(problem, "list_of_constraints"):
        outer_duals = []
        for c in problem.list_of_constraints:
            dv = getattr(c, "dual_variable_value", None)
            if dv is None or abs(dv) < 1e-10:
                continue
            outer_duals.append((getattr(c, "name", "?"), float(dv)))
        print(f"\nOuter problem constraints with duals: {len(outer_duals)}")
        for name, dv in outer_duals:
            print(f"  outer dual={dv:>10.5f}   {name}")


if __name__ == "__main__":
    main()
