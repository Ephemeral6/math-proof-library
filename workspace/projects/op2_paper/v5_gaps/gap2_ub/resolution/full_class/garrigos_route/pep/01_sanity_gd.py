"""
Sanity check: PEP framework on plain gradient descent (no momentum) for L-smooth convex.
Known result (Drori-Teboulle 2014, Taylor 2017): worst-case f(x_T) - f* = LD^2 / (4T+2).

If we recover this rate, the framework is set up correctly for L-smooth convex.
"""
from PEPit import PEP
from PEPit.functions import SmoothConvexFunction


def wc_gd_smooth_convex(L, eta, n, verbose=0):
    """Worst-case f(x_n) - f_* for GD, ||x_0 - x*||^2 <= 1."""
    problem = PEP()
    func = problem.declare_function(SmoothConvexFunction, L=L)
    xs = func.stationary_point()
    fs = func(xs)
    x0 = problem.set_initial_point()
    # Initial condition: ||x0 - xs||^2 <= 1 (D^2 = 1 normalization)
    problem.set_initial_condition((x0 - xs) ** 2 <= 1)
    x = x0
    for _ in range(n):
        x = x - eta * func.gradient(x)
    problem.set_performance_metric(func(x) - fs)
    return problem.solve(wrapper="cvxpy", verbose=verbose)


if __name__ == "__main__":
    L = 1.0
    print(f"{'T':>4} {'eta':>10} {'PEP τ':>14} {'L D^2/(4T+2)':>14} {'ratio':>10}")
    for n in [1, 2, 3, 5, 10, 20]:
        eta = 1.0 / L  # standard GD step size
        tau = wc_gd_smooth_convex(L, eta, n, verbose=-1)
        target = L / (4 * n + 2)
        print(f"{n:>4} {eta:>10.4f} {tau:>14.6e} {target:>14.6e} {tau/target:>10.4f}")
