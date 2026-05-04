"""B1.4 Dimension Scaling.

For SGD, SHB(beta=0.5), Adam, AdaGrad on a random L-smooth convex quadratic in R^d:
- d in {2, 10, 50, 200, 500}, T = 5000
- Plot log(f(x_T) - f^*) vs log d, fit slope
- Flag any algorithm where the slope deviates from theory by > 0.2

Theory expectation: for fixed L-smooth convex quadratic with consistent normalization,
SGD/SHB convergence in *function value* is dimension-independent for full-batch GD on
L-smooth (rate ~ L||x_0 - x*||^2 / T). So slope vs d should be ~ 0.
"""
import numpy as np
import csv
import os

OUT_DIR = "workspace/proposer/results"
os.makedirs(OUT_DIR, exist_ok=True)


def make_quadratic(d, L=1.0, mu_min=1e-3, seed=0):
    """Random PSD with eigenvalues in [mu_min, L]."""
    rng = np.random.default_rng(seed)
    Q, _ = np.linalg.qr(rng.standard_normal((d, d)))
    eigs = rng.uniform(mu_min, L, size=d)
    eigs[0] = mu_min
    eigs[-1] = L
    A = (Q * eigs) @ Q.T
    A = 0.5 * (A + A.T)
    x_star = rng.standard_normal(d)
    b = A @ x_star
    f_star = -0.5 * x_star @ A @ x_star + b @ x_star  # value of f at x_star = -1/2 x*^T A x*
    # f(x) = 1/2 x^T A x - b^T x ; gradient = Ax - b. f(x*) = -1/2 x*^T A x*.
    f_star = -0.5 * x_star @ b
    return A, b, x_star, f_star, eigs.max()


def f_val(A, b, x):
    return 0.5 * x @ A @ x - b @ x


def grad(A, b, x):
    return A @ x - b


def run_sgd(A, b, x0, L, T):
    eta = 1.0 / L
    x = x0.copy()
    for _ in range(T):
        x = x - eta * grad(A, b, x)
    return x


def run_shb(A, b, x0, L, T, beta=0.5):
    eta = 1.0 / L
    x = x0.copy()
    x_prev = x0.copy()
    for _ in range(T):
        g = grad(A, b, x)
        x_new = x - eta * g + beta * (x - x_prev)
        x_prev = x
        x = x_new
    return x


def run_adam(A, b, x0, L, T, beta1=0.9, beta2=0.999, eps=1e-8):
    eta = 1.0 / L
    x = x0.copy()
    m = np.zeros_like(x)
    v = np.zeros_like(x)
    for t in range(1, T + 1):
        g = grad(A, b, x)
        m = beta1 * m + (1 - beta1) * g
        v = beta2 * v + (1 - beta2) * g * g
        m_hat = m / (1 - beta1 ** t)
        v_hat = v / (1 - beta2 ** t)
        x = x - eta * m_hat / (np.sqrt(v_hat) + eps)
    return x


def run_adagrad(A, b, x0, L, T, eps=1e-8):
    eta = 1.0 / L
    x = x0.copy()
    G = np.zeros_like(x)
    for _ in range(T):
        g = grad(A, b, x)
        G = G + g * g
        x = x - eta * g / (np.sqrt(G) + eps)
    return x


def main():
    dims = [2, 10, 50, 200, 500]
    T = 5000
    seed = 0
    rows = []
    rows.append(["alg", "d", "T", "f_gap", "log10_f_gap"])

    for d in dims:
        np.random.seed(seed)
        A, b, x_star, f_star, L = make_quadratic(d, L=1.0, mu_min=1e-3, seed=seed)
        rng = np.random.default_rng(seed + 1)
        x0 = x_star + rng.standard_normal(d)

        for name, fn in [
            ("SGD", lambda: run_sgd(A, b, x0, L, T)),
            ("SHB_0.5", lambda: run_shb(A, b, x0, L, T, beta=0.5)),
            ("Adam", lambda: run_adam(A, b, x0, L, T)),
            ("AdaGrad", lambda: run_adagrad(A, b, x0, L, T)),
        ]:
            try:
                x_T = fn()
                gap = f_val(A, b, x_T) - f_star
                gap = max(gap, 1e-300)
                rows.append([name, d, T, gap, np.log10(gap)])
                print(f"d={d:4d} {name:10s}: gap={gap:.3e}")
            except Exception as e:
                print(f"d={d:4d} {name:10s}: FAILED {e}")
                rows.append([name, d, T, "FAILED", "FAILED"])

    out_csv = os.path.join(OUT_DIR, "b1_4_dimension.csv")
    with open(out_csv, "w", newline="") as f:
        w = csv.writer(f)
        w.writerows(rows)
    print(f"\nSaved {out_csv}")

    # Fit slopes
    obs_path = os.path.join(OUT_DIR, "b1_4_observations.md")
    with open(obs_path, "w") as f:
        f.write("# B1.4 Dimension scaling observations\n\n")
        f.write("Theory expectation: for fixed L-smooth convex quadratic, full-batch convergence is **dimension-independent** => slope vs log10(d) should be ~ 0.\n\n")
        f.write("Flag if |slope| > 0.2.\n\n")
        f.write("| Alg | slope log_gap vs log_d | flag |\n|---|---|---|\n")
        for alg in ["SGD", "SHB_0.5", "Adam", "AdaGrad"]:
            xs, ys = [], []
            for r in rows[1:]:
                if r[0] == alg and r[3] != "FAILED":
                    xs.append(np.log10(r[1]))
                    ys.append(r[4])
            if len(xs) >= 2:
                slope, intercept = np.polyfit(xs, ys, 1)
                flag = "YES" if abs(slope) > 0.2 else "no"
                f.write(f"| {alg} | {slope:+.3f} | {flag} |\n")
                print(f"{alg}: slope = {slope:+.3f}  flag={flag}")
            else:
                f.write(f"| {alg} | n/a | n/a |\n")
    print(f"Saved {obs_path}")


if __name__ == "__main__":
    main()
