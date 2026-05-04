"""B1.2 Iterate-type comparison.

For SHB(0.5), SHB(0.9), NAG(0.5), Adam on:
  (i) Goujaud-style cycling instance: 2D quadratic with carefully chosen condition number
      where SHB exhibits non-monotone last-iterate behavior.
  (ii) smooth SC quadratic in d=10.
Compute last_iterate, cesaro_avg, pr_avg (linear weights), best_iterate, suffix_avg (k=sqrt(T)) gaps.
T in {100, 1000, 10000}.
Look for ranking changes (phase transitions) and acceleration cases.
"""
import numpy as np
import csv
import os

OUT_DIR = "workspace/proposer/results"
os.makedirs(OUT_DIR, exist_ok=True)


def make_goujaud_2d():
    """A 2x2 with eigenvalues that cause SHB cycling.
    Goujaud et al. 2022: SHB does not accelerate on smooth convex non-SC; here we use a SC variant
    with very ill-conditioned spectrum to exhibit cycling for moderate T.
    """
    L = 1.0; mu = 1e-3
    A = np.diag([L, mu])
    return A, np.zeros(2), 0.0, L


def make_sc_quad(d=10, seed=0):
    rng = np.random.default_rng(seed)
    Q, _ = np.linalg.qr(rng.standard_normal((d, d)))
    eigs = rng.uniform(0.05, 1.0, size=d)
    eigs[0] = 0.05; eigs[-1] = 1.0
    A = (Q * eigs) @ Q.T
    A = 0.5 * (A + A.T)
    return A, np.zeros(d), 0.0, eigs.max()


# f(x) = 0.5 x^T A x ; gradient = A x ; minimizer 0.

def f(A, x):
    return 0.5 * x @ A @ x


def collect_iterates(alg_step, x0, T):
    xs = np.zeros((T + 1, x0.size))
    xs[0] = x0
    state = None
    for t in range(T):
        xs[t + 1], state = alg_step(xs[t], t, state)
    return xs


def shb_step_factory(A, eta, beta):
    def step(x, t, state):
        if state is None:
            xp = x.copy()
        else:
            xp = state
        g = A @ x
        xn = x - eta * g + beta * (x - xp)
        return xn, x.copy()
    return step


def nag_step_factory(A, eta, beta):
    def step(x, t, state):
        if state is None:
            xp = x.copy()
        else:
            xp = state
        y = x + beta * (x - xp)
        xn = y - eta * (A @ y)
        return xn, x.copy()
    return step


def adam_step_factory(A, eta, beta1=0.9, beta2=0.999, eps=1e-8):
    def step(x, t, state):
        if state is None:
            m = np.zeros_like(x); v = np.zeros_like(x)
        else:
            m, v = state
        g = A @ x
        m = beta1 * m + (1 - beta1) * g
        v = beta2 * v + (1 - beta2) * g * g
        mh = m / (1 - beta1 ** (t + 1))
        vh = v / (1 - beta2 ** (t + 1))
        xn = x - eta * mh / (np.sqrt(vh) + eps)
        return xn, (m, v)
    return step


def gaps(A, xs):
    return np.array([f(A, x) for x in xs])


def cesaro(xs):
    return np.cumsum(xs, axis=0) / np.arange(1, len(xs) + 1)[:, None]


def pr_weights(T):
    # linear weights w_t = t+1
    w = np.arange(1, T + 1)
    return w / w.sum()


def main():
    settings = []
    A_g, x0_g, fs_g, L_g = make_goujaud_2d()
    settings.append(("Goujaud2D", A_g, np.array([1.0, 1.0]), fs_g, L_g))
    A_q, x0_q, fs_q, L_q = make_sc_quad(d=10)
    settings.append(("SCQuad10", A_q, np.ones(10) * 0.5, fs_q, L_q))

    algs = {
        "SHB_0.5":  lambda A, L: shb_step_factory(A, 1.0 / L, 0.5),
        "SHB_0.9":  lambda A, L: shb_step_factory(A, 1.0 / L, 0.9),
        "NAG_0.5":  lambda A, L: nag_step_factory(A, 1.0 / L, 0.5),
        "Adam":     lambda A, L: adam_step_factory(A, 1.0 / L),
    }

    Ts = [100, 1000, 10000]
    rows = [["setting", "alg", "T", "last", "cesaro", "pr", "best", "suffix_sqrtT"]]

    phenomena = []

    for name, A, x0, fs, L in settings:
        for alg_name, step_factory in algs.items():
            for T in Ts:
                step = step_factory(A, L)
                xs = collect_iterates(step, x0.copy(), T)
                gs = gaps(A, xs[1:])  # 1..T
                last = gs[-1]
                ces = cesaro(xs[1:])
                ces_gap = f(A, ces[-1])
                w = pr_weights(T)
                pr = (w[:, None] * xs[1:]).sum(axis=0)
                pr_gap = f(A, pr)
                best = gs.min()
                k = max(1, int(np.sqrt(T)))
                suffix_x = xs[-k:].mean(axis=0)
                suffix_gap = f(A, suffix_x)
                rows.append([name, alg_name, T,
                             f"{last:.3e}", f"{ces_gap:.3e}", f"{pr_gap:.3e}", f"{best:.3e}", f"{suffix_gap:.3e}"])
                # phenomena detection:
                # acceleration: pr or cesaro 10x better than last (i.e. ratio < 0.1)
                if last > 0 and pr_gap / last < 0.1:
                    phenomena.append(f"ACCEL_PR  {name} {alg_name} T={T}: PR_gap/last_gap={pr_gap/last:.2e}")
                if last > 0 and ces_gap / last < 0.1:
                    phenomena.append(f"ACCEL_CES {name} {alg_name} T={T}: Ces_gap/last_gap={ces_gap/last:.2e}")
                # cycling/bouncing: best <<< last
                if last > 0 and best / last < 0.05:
                    phenomena.append(f"CYCLING   {name} {alg_name} T={T}: best/last={best/last:.2e}")
                print(f"{name:10s} {alg_name:8s} T={T:5d}: last={last:.3e} ces={ces_gap:.3e} pr={pr_gap:.3e} best={best:.3e} suf={suffix_gap:.3e}")

    out_csv = os.path.join(OUT_DIR, "b1_2_iterates.csv")
    with open(out_csv, "w", newline="") as f_:
        w_ = csv.writer(f_)
        w_.writerows(rows)
    print(f"\nSaved {out_csv}")

    out_md = os.path.join(OUT_DIR, "b1_2_phenomena.md")
    with open(out_md, "w") as f_:
        f_.write("# B1.2 Phenomena observed\n\n")
        f_.write("Codes:\n- ACCEL_PR / ACCEL_CES : averaged iterate at least 10x better than last iterate\n- CYCLING : best iterate at least 20x better than last iterate (= bouncing past optimum)\n\n")
        for p in phenomena:
            f_.write(f"- {p}\n")
        if not phenomena:
            f_.write("(none flagged)\n")
    print(f"Saved {out_md}")


if __name__ == "__main__":
    main()
