"""B1.5 Deeper probe of Adam on strongly convex quadratic.

We observed Adam fails to drive f to 0 on SCQuad and even *diverges* late in training.
We probe:
  - Trajectory of f(x_t) over t for Adam vs SGD on the same SC quadratic
  - Different stepsizes
  - Different epsilons
"""
import numpy as np
import csv
import os

OUT_DIR = "workspace/proposer/results"
os.makedirs(OUT_DIR, exist_ok=True)


def make_sc_quad(d=10, seed=0):
    rng = np.random.default_rng(seed)
    Q, _ = np.linalg.qr(rng.standard_normal((d, d)))
    eigs = rng.uniform(0.05, 1.0, size=d)
    eigs[0] = 0.05; eigs[-1] = 1.0
    A = (Q * eigs) @ Q.T
    A = 0.5 * (A + A.T)
    return A, eigs.max()


def adam_traj(A, x0, T, eta, beta1=0.9, beta2=0.999, eps=1e-8):
    x = x0.copy(); m = np.zeros_like(x); v = np.zeros_like(x)
    fs = []
    for t in range(1, T + 1):
        g = A @ x
        m = beta1 * m + (1 - beta1) * g
        v = beta2 * v + (1 - beta2) * g * g
        mh = m / (1 - beta1 ** t); vh = v / (1 - beta2 ** t)
        x = x - eta * mh / (np.sqrt(vh) + eps)
        fs.append(0.5 * x @ A @ x)
    return np.array(fs)


def sgd_traj(A, x0, T, eta):
    x = x0.copy(); fs = []
    for _ in range(T):
        x = x - eta * (A @ x)
        fs.append(0.5 * x @ A @ x)
    return np.array(fs)


def main():
    A, L = make_sc_quad(d=10, seed=0)
    x0 = np.ones(10) * 0.5
    T = 10000
    rows = [["t", "Adam_eta=1/L", "Adam_eta=0.1/L", "Adam_eta=0.01/L", "SGD_eta=1/L"]]

    # Trajectories at log-spaced t
    a1 = adam_traj(A, x0, T, 1.0 / L)
    a2 = adam_traj(A, x0, T, 0.1 / L)
    a3 = adam_traj(A, x0, T, 0.01 / L)
    s1 = sgd_traj(A, x0, T, 1.0 / L)
    ts = np.unique(np.round(np.logspace(0, np.log10(T), 60)).astype(int))
    ts = ts[ts > 0]
    for t in ts:
        i = t - 1
        rows.append([t, f"{a1[i]:.4e}", f"{a2[i]:.4e}", f"{a3[i]:.4e}", f"{s1[i]:.4e}"])

    out_csv = os.path.join(OUT_DIR, "b1_5_adam_sc_traj.csv")
    with open(out_csv, "w", newline="") as f:
        w = csv.writer(f)
        w.writerows(rows)
    print(f"Saved {out_csv}")

    # Summary
    print(f"\nFinal gaps T={T}:")
    print(f"  Adam eta=1/L:     {a1[-1]:.4e}")
    print(f"  Adam eta=0.1/L:   {a2[-1]:.4e}")
    print(f"  Adam eta=0.01/L:  {a3[-1]:.4e}")
    print(f"  SGD  eta=1/L:     {s1[-1]:.4e}")

    # Min over t for each
    print(f"\nMin gap reached over t<=T:")
    print(f"  Adam eta=1/L:     {a1.min():.4e}  at t={int(np.argmin(a1)) + 1}")
    print(f"  Adam eta=0.1/L:   {a2.min():.4e}  at t={int(np.argmin(a2)) + 1}")
    print(f"  Adam eta=0.01/L:  {a3.min():.4e}  at t={int(np.argmin(a3)) + 1}")
    print(f"  SGD  eta=1/L:     {s1.min():.4e}  at t={int(np.argmin(s1)) + 1}")

    print(f"\nDivergence ratio (final / min) -- > 1 means Adam diverged after reaching its min:")
    print(f"  Adam eta=1/L:     {a1[-1]/a1.min():.4e}")
    print(f"  Adam eta=0.1/L:   {a2[-1]/a2.min():.4e}")
    print(f"  Adam eta=0.01/L:  {a3[-1]/a3.min():.4e}")
    print(f"  SGD  eta=1/L:     {s1[-1]/s1.min():.4e}")


if __name__ == "__main__":
    main()
