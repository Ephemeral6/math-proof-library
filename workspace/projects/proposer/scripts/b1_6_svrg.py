"""B1.6 SVRG snapshot frequency probe.

f(x) = (1/n) sum f_i(x), each f_i(x) = 0.5 (a_i x - b_i)^2  in d=10.
SVRG with snapshot frequency m in {n/4, n/2, n, 2n, 4n}, T fixed in inner-loop iterations.
We look for breakage at small m (snapshot too often -> noise-dominated) or large m (too stale -> divergence).
"""
import numpy as np
import csv
import os

OUT_DIR = "workspace/proposer/results"
os.makedirs(OUT_DIR, exist_ok=True)


def make_problem(n=200, d=10, seed=0):
    rng = np.random.default_rng(seed)
    A = rng.standard_normal((n, d)) / np.sqrt(d)
    x_star = rng.standard_normal(d)
    b = A @ x_star + 0.01 * rng.standard_normal(n)
    H = (A.T @ A) / n
    L_max = max(np.sum(A[i] ** 2) for i in range(n))  # max ||a_i||^2
    L_avg = np.linalg.eigvalsh(H).max()
    mu = np.linalg.eigvalsh(H).min()
    return A, b, x_star, L_max, L_avg, mu


def f_full(A, b, x):
    return 0.5 * np.mean((A @ x - b) ** 2)


def grad_i(A, b, x, i):
    return (A[i] @ x - b[i]) * A[i]


def grad_full(A, b, x):
    return A.T @ (A @ x - b) / A.shape[0]


def run_svrg(A, b, x0, m, total_iters, eta, seed=0):
    rng = np.random.default_rng(seed)
    n = A.shape[0]
    x = x0.copy()
    snap = x0.copy()
    full_grad_snap = grad_full(A, b, snap)
    fs = []
    cnt = 0
    while cnt < total_iters:
        # take m steps
        for _ in range(m):
            if cnt >= total_iters:
                break
            i = rng.integers(0, n)
            gi = grad_i(A, b, x, i)
            gi_snap = grad_i(A, b, snap, i)
            v = gi - gi_snap + full_grad_snap
            x = x - eta * v
            cnt += 1
            fs.append(f_full(A, b, x))
        snap = x.copy()
        full_grad_snap = grad_full(A, b, snap)
    return np.array(fs)


def main():
    n = 200; d = 10
    A, b, x_star, L_max, L_avg, mu = make_problem(n, d)
    f_star = f_full(A, b, x_star)
    print(f"L_max={L_max:.3f}, L_avg={L_avg:.3f}, mu={mu:.3f}")
    x0 = np.zeros(d)
    eta = 1.0 / (10 * L_max)  # safe SVRG stepsize ~ 1/(10 L)
    total = 5 * n  # 5 epochs

    rows = [["m_setting", "m_value", "iter", "f_gap"]]
    summary = []

    for label, m in [("n/4", n // 4), ("n/2", n // 2), ("n", n), ("2n", 2 * n), ("4n", 4 * n)]:
        fs = run_svrg(A, b, x0, m, total, eta, seed=0)
        gap = fs - f_star
        # log-spaced sample
        idxs = np.unique(np.round(np.linspace(0, len(gap) - 1, 20)).astype(int))
        for i in idxs:
            rows.append([label, m, i + 1, f"{gap[i]:.4e}"])
        final = gap[-1]; mn = gap.min()
        summary.append((label, m, final, mn, fs.shape[0]))
        print(f"m={label:5s} ({m}): final_gap={final:.4e}  min_gap={mn:.4e}")

    out_csv = os.path.join(OUT_DIR, "b1_6_svrg.csv")
    with open(out_csv, "w", newline="") as f:
        w = csv.writer(f)
        w.writerows(rows)
    print(f"Saved {out_csv}")

    out_md = os.path.join(OUT_DIR, "b1_6_svrg.md")
    with open(out_md, "w") as f:
        f.write("# B1.6 SVRG snapshot frequency\n\n")
        f.write(f"Problem: n={n}, d={d}, L_max={L_max:.3f}, L_avg={L_avg:.3f}, mu={mu:.4f}, eta=1/(10 L_max)={eta:.4e}\n")
        f.write(f"Total inner iters: {total} (= 5 epochs)\n\n")
        f.write("| m label | m | final f_gap | min f_gap |\n|---|---|---|---|\n")
        for label, m, fin, mn, _ in summary:
            f.write(f"| {label} | {m} | {fin:.4e} | {mn:.4e} |\n")
    print(f"Saved {out_md}")


if __name__ == "__main__":
    main()
