"""Route C numerical: check whether f(y_t) is eventually monotone for SHB at high β.

Test on:
  T1: f(x) = (L/2) ||x||² (1-D quadratic). Iterate is exactly linear; complex eigenvalues
      with |λ| = √β; f(y_t) oscillates as ~ β^t · cos(ωt + φ)². NOT monotone.
  T2: f(x) = (L/2) ||x||² + ε ||x||^4 (smooth perturbation of quadratic). Slightly less linear.
  T3: f(x) = log(1 + e^{-y · x}) (logistic — non-quadratic smooth convex). Worst-case-ish.
  T4: PEP worst-case-style: f(x) = (L/2) ||x||² with skewed init (just to see behavior).

If even on these "easy" cases the iterate oscillates strongly past β = β*, then HB is NOT
eventually monotone, and Route C (Cesàro = last-iterate) doesn't work.
"""
import numpy as np


def test_quadratic(L, beta, eta, x0, T):
    """f(x) = (L/2) x², SHB iteration."""
    x = [x0, x0]
    fs = [(L/2) * x0**2]
    for t in range(T):
        x_new = (1 - eta * L + beta) * x[-1] - beta * x[-2]
        x.append(x_new)
        fs.append((L/2) * x_new**2)
    return np.array(fs)


def test_logistic(beta, eta, x0, T):
    """f(x) = log(1 + e^{-x}) on 1-D. Smoothness L = 1/4."""
    L = 0.25
    def grad(x):
        return -1.0 / (1.0 + np.exp(x))
    def f(x):
        return np.log(1.0 + np.exp(-x))
    x = [x0, x0]
    fs = [f(x0) - f(np.inf)]  # f* = 0 at infinity (asymptotically)
    f_star = 0.0
    for t in range(T):
        x_new = x[-1] - eta * grad(x[-1]) + beta * (x[-1] - x[-2])
        x.append(x_new)
        fs.append(f(x_new) - f_star)
    return np.array(fs)


def count_monotonicity_breaks(fs):
    """Count number of times f(y_t) increases (i.e., f_{t+1} > f_t)."""
    return int(np.sum(np.diff(fs) > 0))


def find_eventual_monotonicity(fs, tol=1e-12):
    """Find smallest T₀ such that f(y_t) is non-increasing for t ≥ T₀.

    Returns T₀ if found within len(fs), else -1.
    """
    diffs = np.diff(fs)
    # We want last index where diff > tol; T₀ = that index + 1.
    bad = np.where(diffs > tol)[0]
    if len(bad) == 0:
        return 0
    return int(bad[-1] + 1)


def main():
    L = 1.0
    print("=" * 80)
    print("Numerical check: is f(y_t) eventually monotone for SHB at high β?")
    print("=" * 80)
    print()

    for beta in [0.5, 0.9, 0.95, 0.97, 0.99]:
        eta = 0.5 * (1 - beta) / L  # rough optimal: η ~ (1-β)
        # Better: try a few etas, but keep it simple.
        T_max = 300
        x0 = 1.0

        print(f"\nβ = {beta}, η = {eta:.4f}")
        print(f"  Eigenvalue magnitude: √β = {np.sqrt(beta):.6f}")
        print()

        # Quadratic
        fs = test_quadratic(L, beta, eta, x0, T_max)
        breaks = count_monotonicity_breaks(fs)
        T0 = find_eventual_monotonicity(fs)
        print(f"  Quadratic f = (L/2)x²:")
        print(f"    monotonicity breaks = {breaks} / {T_max}")
        print(f"    eventually monotone after T₀ = {T0}")
        # Inspect a few late values
        late_indices = [50, 100, 150, 200, 250]
        print(f"    f(y_t) at t = {late_indices}:")
        for i in late_indices:
            if i < len(fs): print(f"      f({i}) = {fs[i]:.4e}")

        # Try multiple etas
        for eta_factor in [0.3, 0.5, 1.0, 2.0]:
            eta_test = eta_factor * (1-beta) / L
            fs = test_quadratic(L, beta, eta_test, x0, T_max)
            breaks = count_monotonicity_breaks(fs)
            T0 = find_eventual_monotonicity(fs)
            print(f"    η={eta_test:.4f} (factor {eta_factor}·(1-β)/L): breaks={breaks}, T₀={T0}")

    # Conclusion:
    print()
    print("=" * 80)
    print("CONCLUSION on Route C (monotonicity):")
    print("=" * 80)
    print("If breaks > 0 indefinitely, f(y_t) is NOT eventually monotone for HB at high β.")
    print("Route C requires monotonicity to translate Cesàro O(1/T) to last-iterate O(1/T).")


if __name__ == "__main__":
    main()
