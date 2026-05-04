"""B1.1 Convergence rate sweep.

Algorithms: SGD, SHB(beta=0.5), SHB(beta=0.9), NAG(0.5), NAG(0.9), Adam, AdaGrad
Functions:
  Q-SC: f(x) = 0.5 x^T A x with A = diag(1, 2, ..., d)/d (strongly convex, mu=1/d, L=1)
  Huber: smooth convex Huber loss, sum_i huber(x_i)
  Quartic: f(x) = (1/4) ||x||^4   (convex, but Hessian degenerate at 0)
d in {2, 10, 50}; T in {1000, 10000}
Metric: empirical alpha from log(f(x_T) - f^*) / log T

Theoretical alpha values:
  - Q-SC: GD/SHB/NAG: linear convergence -> log(gap)/log(T) huge negative; we don't flag these.
  - Huber smooth convex: GD: O(1/T) so alpha=-1. NAG: 1/T^2 so alpha=-2. Adam worst case alpha=-0.5.
  - Quartic f(x)=||x||^4/4: f-gap = ||x||^4/4. ||x_{k+1}|| = ||x_k|| - eta ||x_k||^2 ||x_k|| (negligible)
    so for GD ||x||^2 ~ 1/k => f ~ 1/k^2 => alpha=-2 (this is f-value not ||x||).
    Adam may differ; AdaGrad rescaling may slow it down.
"""
import numpy as np
import csv
import os

OUT_DIR = "workspace/proposer/results"
os.makedirs(OUT_DIR, exist_ok=True)


# ---------- functions ----------

class QuadSC:
    name = "Q-SC"
    def __init__(self, d):
        self.d = d
        self.eigs = np.arange(1, d + 1) / d  # in (0, 1]
        self.L = 1.0
        self.mu = 1.0 / d
    def f(self, x):
        return 0.5 * np.sum(self.eigs * x * x)
    def g(self, x):
        return self.eigs * x
    def x_star(self):
        return np.zeros(self.d)
    def f_star(self):
        return 0.0


def huber(x, delta=1.0):
    abs_x = np.abs(x)
    quad = abs_x <= delta
    out = np.where(quad, 0.5 * x * x, delta * (abs_x - 0.5 * delta))
    return out


def huber_grad(x, delta=1.0):
    return np.clip(x, -delta, delta)


class HuberConvex:
    name = "Huber"
    def __init__(self, d, delta=1.0):
        self.d = d
        self.delta = delta
        self.L = 1.0  # Lipschitz of huber'
    def f(self, x):
        return np.sum(huber(x, self.delta))
    def g(self, x):
        return huber_grad(x, self.delta)
    def x_star(self):
        return np.zeros(self.d)
    def f_star(self):
        return 0.0


class Quartic:
    name = "Quartic"
    def __init__(self, d):
        self.d = d
        # f = 1/4 ||x||^4 = 1/4 (sum x_i^2)^2
        # gradient = ||x||^2 * x
        # NOT globally L-smooth; we set effective L to 4 * R^2 where R = ||x_0||
        self.L = None
    def f(self, x):
        s = float(np.sum(x * x))
        return 0.25 * s * s
    def g(self, x):
        s = float(np.sum(x * x))
        return s * x
    def x_star(self):
        return np.zeros(self.d)
    def f_star(self):
        return 0.0


# ---------- algorithms ----------

def alg_sgd(prob, x0, T, eta):
    x = x0.copy()
    for _ in range(T):
        x = x - eta * prob.g(x)
    return x


def alg_shb(prob, x0, T, eta, beta):
    x = x0.copy(); xp = x0.copy()
    for _ in range(T):
        g = prob.g(x)
        xn = x - eta * g + beta * (x - xp)
        xp = x; x = xn
    return x


def alg_nag(prob, x0, T, eta, beta):
    """Standard Nesterov: y = x + beta(x - x_prev); x_new = y - eta * grad(y)."""
    x = x0.copy(); xp = x0.copy()
    for _ in range(T):
        y = x + beta * (x - xp)
        xn = y - eta * prob.g(y)
        xp = x; x = xn
    return x


def alg_adam(prob, x0, T, eta, beta1=0.9, beta2=0.999, eps=1e-8):
    x = x0.copy(); m = np.zeros_like(x); v = np.zeros_like(x)
    for t in range(1, T + 1):
        g = prob.g(x)
        m = beta1 * m + (1 - beta1) * g
        v = beta2 * v + (1 - beta2) * g * g
        mh = m / (1 - beta1 ** t); vh = v / (1 - beta2 ** t)
        x = x - eta * mh / (np.sqrt(vh) + eps)
    return x


def alg_adagrad(prob, x0, T, eta, eps=1e-8):
    x = x0.copy(); G = np.zeros_like(x)
    for _ in range(T):
        g = prob.g(x)
        G = G + g * g
        x = x - eta * g / (np.sqrt(G) + eps)
    return x


# theoretical alpha for log(gap)/log(T)
# For Huber, with x0 outside the quadratic regime, GD enters quadratic basin in O(1) steps and then
# linear convergence -> very fast. To get the true 1/T behavior we must use ||x0||>>delta and observe
# the linear-regime descent. With delta=1 and large x0, the gradient is sign(x_i) so f(x_k)~f(x_0)-k*eta*d.
# That linear-in-k decrease means gap hits 0 in finite time; not a great rate testbed. We DROP Huber.
THEORY = {
    ("Quartic", "SGD"):     -2.0,   # f = ||x||^4/4 -> alpha = -2
    ("Quartic", "SHB_0.5"): -2.0,
    ("Quartic", "SHB_0.9"): -2.0,
    ("Quartic", "NAG_0.5"): -2.0,
    ("Quartic", "NAG_0.9"): -2.0,
    ("Quartic", "Adam"):    -2.0,   # naive theory; Adam may differ
    ("Quartic", "AdaGrad"): -2.0,
    # Q-SC: linear conv -> not parametrized as alpha. We track for Adam to see if SC fails.
}


def run_one(prob, alg_name, x0, T):
    L = prob.L if prob.L else 4.0 * float(np.sum(x0 * x0))
    eta = 1.0 / L
    if alg_name == "SGD":
        return alg_sgd(prob, x0, T, eta)
    if alg_name == "SHB_0.5":
        return alg_shb(prob, x0, T, eta, 0.5)
    if alg_name == "SHB_0.9":
        return alg_shb(prob, x0, T, eta, 0.9)
    if alg_name == "NAG_0.5":
        return alg_nag(prob, x0, T, eta, 0.5)
    if alg_name == "NAG_0.9":
        return alg_nag(prob, x0, T, eta, 0.9)
    if alg_name == "Adam":
        return alg_adam(prob, x0, T, eta)
    if alg_name == "AdaGrad":
        return alg_adagrad(prob, x0, T, eta)
    raise ValueError(alg_name)


def main():
    algs = ["SGD", "SHB_0.5", "SHB_0.9", "NAG_0.5", "NAG_0.9", "Adam", "AdaGrad"]
    dims = [2, 10, 50]
    Ts = [1000, 10000]

    rows = [["fn", "alg", "d", "T", "f_gap", "alpha_emp", "alpha_theory", "deviation", "flag"]]

    rng = np.random.default_rng(0)

    for d in dims:
        x0_quad = rng.standard_normal(d)
        x0_huber = rng.standard_normal(d) * 0.5  # within huber quadratic regime initially
        x0_quartic = rng.standard_normal(d) * 0.5

        for ProbCls, x0 in [(QuadSC, x0_quad.copy()), (HuberConvex, x0_huber.copy()), (Quartic, x0_quartic.copy())]:
            prob = ProbCls(d)
            for alg in algs:
                # measure two T values
                gaps = {}
                for T in Ts:
                    try:
                        xT = run_one(prob, alg, x0.copy(), T)
                        gap = float(prob.f(xT) - prob.f_star())
                        gap = max(gap, 1e-300)
                        gaps[T] = gap
                    except Exception as e:
                        gaps[T] = None
                        print(f"{prob.name:8s} {alg:8s} d={d:3d} T={T:5d}: FAILED {e}")
                # alpha empirical from log(gap)/log(T) at T=10000
                gap_T = gaps[10000]
                if gap_T is None or gap_T <= 0:
                    alpha_emp = None
                else:
                    # Use ratio between two T's: gap(T) ~ C T^alpha => alpha = (log gap10k - log gap1k) / (log 10k - log 1k)
                    if gaps[1000] is not None and gaps[1000] > 0 and gap_T > 0:
                        alpha_emp = (np.log(gap_T) - np.log(gaps[1000])) / (np.log(10000) - np.log(1000))
                    else:
                        alpha_emp = None
                key = (prob.name, alg)
                alpha_theory = THEORY.get(key, None)
                if alpha_theory is not None and alpha_emp is not None:
                    dev = alpha_emp - alpha_theory
                    flag = "YES" if abs(dev) > 0.15 else "no"
                else:
                    dev = None; flag = "n/a"
                rows.append([prob.name, alg, d, 10000, gap_T,
                             None if alpha_emp is None else round(alpha_emp, 3),
                             alpha_theory,
                             None if dev is None else round(dev, 3),
                             flag])
                print(f"{prob.name:8s} {alg:8s} d={d:3d}: gap={gap_T:.3e}  alpha_emp={alpha_emp}  theory={alpha_theory}  flag={flag}")

    out_csv = os.path.join(OUT_DIR, "b1_1_rates.csv")
    with open(out_csv, "w", newline="") as f:
        w = csv.writer(f)
        w.writerows(rows)
    print(f"\nSaved {out_csv}")

    flags_path = os.path.join(OUT_DIR, "b1_1_flags.md")
    with open(flags_path, "w") as f:
        f.write("# B1.1 Flagged anomalies (|alpha_emp - alpha_theory| > 0.15)\n\n")
        f.write("| fn | alg | d | T | gap | alpha_emp | alpha_theory | deviation |\n|---|---|---|---|---|---|---|---|\n")
        for r in rows[1:]:
            if r[8] == "YES":
                f.write(f"| {r[0]} | {r[1]} | {r[2]} | {r[3]} | {r[4]:.3e} | {r[5]} | {r[6]} | {r[7]} |\n")
    print(f"Saved {flags_path}")


if __name__ == "__main__":
    main()
