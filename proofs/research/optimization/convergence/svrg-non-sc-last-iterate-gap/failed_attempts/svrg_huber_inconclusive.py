"""SVRG last-iterate vs snapshot on a Huber-like piecewise-quadratic non-SC finite sum.

Construction:
  Let n = N samples, each f_i(x) = (1/2) * ( max(0, <a_i, x> - b_i) )^2  (one-sided squared hinge).
  Each f_i is L_i-smooth convex (with L_i = ||a_i||^2).
  f(x) = (1/n) * sum f_i(x).

  We design a_i, b_i so that:
    - f is convex but NOT strongly convex (a flat region around x*).
    - The SVRG inner-loop variance does NOT vanish at x* (because the active set
      at x_t differs from the active set at x_tilde, even when x_t and x_tilde
      are both near x*).

Concrete: 1-D problem.
  a_i = 1 for all i, b_i ~ Uniform({-1, +1}) (half/half).
  Then f_i(x) = (1/2)*max(0, x - b_i)^2.
    - For b_i = -1: f_i(x) = (1/2)*max(0, x+1)^2; gradient = max(0, x+1).
    - For b_i = +1: f_i(x) = (1/2)*max(0, x-1)^2; gradient = max(0, x-1).
  f(x) = (1/2)[ (1/2) max(0,x+1)^2 + (1/2) max(0,x-1)^2 ]
       = (1/4)[ max(0,x+1)^2 + max(0,x-1)^2 ].

  For x in [-1, 1], gradient = (1/2)[ (x+1) + 0 ] = (x+1)/2  (only b=-1 active)
    -> wait, for x in [-1,1]: x+1 >= 0, so max(0,x+1)=x+1; x-1 <= 0, so max(0,x-1)=0.
    f(x) = (1/4)(x+1)^2 for x in [-1,1].
    f'(x) = (1/2)(x+1).
    f'(x) = 0 only at x = -1.
  For x < -1: both inactive -> f(x) = 0, gradient 0. f* = 0 attained on (-inf, -1].
  For x > 1: both active -> f(x) = (1/4)[(x+1)^2 + (x-1)^2] = (1/2)(x^2+1).
    gradient = x.

  So f is convex non-SC, x* = -1 is the rightmost optimum, f* = 0.
  L = 1 (each f_i has Hessian <= 1 since a_i^2 = 1).

  SVRG noise: at x_t = x_tilde near 0, sampling i with b_i=+1 gives gradient 0,
  while b_i=-1 gives gradient x_t+1; the variance correction subtracts the same
  quantity at x_tilde. So v_t = grad_i(x_t) - grad_i(x_tilde) + grad(x_tilde).
  When x_t = x_tilde + delta with small delta:
    For b_i=-1: grad_i(x_t)-grad_i(x_tilde) = (x_t+1)-(x_tilde+1) = delta.
    For b_i=+1 with x_tilde > 1 and x_t > 1: same delta.
    But for x_t, x_tilde both in (-1,1): b=+1 component is 0 at both, so delta_i = 0.
    For x_t in (-1,1), x_tilde > 1: cross-active-set, noise is non-trivial.
  This is the kind of activation noise that SVRG cannot remove.

We track snapshot vs last-iterate suboptimality.
"""
import numpy as np
import math

def make_huber_problem(n=200, seed=0):
    rng = np.random.default_rng(seed)
    # n even, half b_i = -1, half = +1
    b = np.empty(n)
    b[:n//2] = -1.0
    b[n//2:] = 1.0
    rng.shuffle(b)
    a = np.ones(n)
    L_smooth_per_i = 1.0  # max ||a_i||^2

    def f_i(i, x):
        return 0.5 * max(0.0, a[i]*x - b[i])**2
    def grad_i(i, x):
        z = a[i]*x - b[i]
        return a[i] * max(0.0, z)
    def f(x):
        s = 0.0
        for i in range(n):
            z = a[i]*x - b[i]
            if z > 0:
                s += 0.5 * z*z
        return s / n
    def grad(x):
        s = 0.0
        for i in range(n):
            z = a[i]*x - b[i]
            if z > 0:
                s += a[i] * z
        return s / n
    return {"n": n, "L_smooth": L_smooth_per_i,
            "f": f, "grad": grad, "f_i": f_i, "grad_i": grad_i,
            "x_star": -1.0, "f_star": 0.0}

def run_svrg(prob, x0, m, S, eta=None, seed=0):
    rng_local = np.random.default_rng(seed)
    L = prob["L_smooth"]
    if eta is None:
        eta = 1.0 / (3.0 * L)
    n = prob["n"]
    grad_i = prob["grad_i"]
    grad = prob["grad"]
    f = prob["f"]
    fstar = prob["f_star"]

    x_tilde = float(x0)
    history = []
    for s in range(S):
        gtilde = grad(x_tilde)
        x_t = x_tilde
        # snapshot for next epoch: average iterate over the epoch
        running_sum = 0.0
        for t in range(m):
            i_t = int(rng_local.integers(n))
            v = grad_i(i_t, x_t) - grad_i(i_t, x_tilde) + gtilde
            x_next = x_t - eta * v
            running_sum += x_t   # average over t = 0..m-1
            x_t = x_next
        x_snapshot = running_sum / m
        x_last = x_t
        history.append((f(x_snapshot) - fstar, f(x_last) - fstar))
        x_tilde = x_snapshot
    return history

def main():
    L = 1.0
    prob = make_huber_problem(n=200, seed=42)
    x0 = 5.0   # well to the right of x*=-1
    D = abs(x0 - prob["x_star"])

    S = 4
    runs = 600
    print(f"D={D}, x*={prob['x_star']}, f(x0)={prob['f'](x0):.4f}")
    print(f"Compare snapshot vs last-iterate suboptimality after S={S} epochs")
    print()
    print(f"{'m':>6} {'snap':>10} {'last':>10} {'LD2/(Sm)':>10} {'snap/B':>8} {'last/B':>8} {'last/snap':>10} {'log m':>7}")
    for m in [16, 64, 256, 1024, 4096]:
        snap_avg = 0.0
        last_avg = 0.0
        for r in range(runs):
            hist = run_svrg(prob, x0, m=m, S=S, seed=10000 + r)
            snap_avg += hist[-1][0] / runs
            last_avg += hist[-1][1] / runs
        baseline = L * D*D / (S * m)
        print(f"{m:>6} {snap_avg:>10.5f} {last_avg:>10.5f} {baseline:>10.5f} "
              f"{snap_avg/baseline:>8.3f} {last_avg/baseline:>8.3f} "
              f"{last_avg/max(snap_avg,1e-12):>10.3f} {math.log(m):>7.3f}")

if __name__ == "__main__":
    main()
