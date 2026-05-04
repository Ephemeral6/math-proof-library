"""SVRG last-iterate vs snapshot experiment.

Construction:
  n components in R^d. Each f_i is convex L-smooth.
  We want a setup where:
    (1) The SVRG variance correction is *not* perfect (so inner loop has noise).
    (2) f is convex but NOT strongly convex, so last iterate can lag log m.

Concrete construction A (heterogeneous quadratics, null direction):
  d = 2. n = 2.
    f_1(x) = (L/2) * x_1^2
    f_2(x) = (L/2) * x_2^2
  Then f(x) = (L/4)(x_1^2 + x_2^2). Smoothness L/2, but actually
  the per-component smoothness is L (max eigenvalue of L*e_1 e_1^T is L).

  Note: this f IS strongly convex with parameter L/2, but the SVRG inner-loop
  variance is non-trivial, which is what we want to test the inner dynamics.
  For the "non-SC" requirement we'll use construction B below.

Construction B (true non-SC + noise in the inner loop):
  d = 3. n = 2.
    f_1(x) = (L/2) * (x_1 + x_3)^2
    f_2(x) = (L/2) * (x_2 + x_3)^2
  Then f(x) = (L/4) * [(x_1+x_3)^2 + (x_2+x_3)^2].
  Hessian = (L/2) * diag-like with rank 2, kernel spanned by (1, 1, -1) (when
  (x1+x3)=(x2+x3)=0 -> x1=x2=-x3). Actually kernel is 1-d so f is convex but
  NOT strongly convex. f* = 0, attained on the line {x1=x2=-x3}.

  Per-component L-smoothness:
    Hess f_1 = L * [[1,0,1],[0,0,0],[1,0,1]]; eigvals 0,0,2L => smoothness 2L.
    To have each f_i be L-smooth, scale by 1/2:
      f_1(x) = (L/4)(x_1+x_3)^2,  f_2(x) = (L/4)(x_2+x_3)^2
    Hess f_1 has top eigval L. Good. f = (1/2)(f_1+f_2) -> wait avg over n=2 gives
    f(x) = (1/2)*[ (L/4)(x_1+x_3)^2 + (L/4)(x_2+x_3)^2 ] = (L/8)*((x_1+x_3)^2+(x_2+x_3)^2)
    This is L/2-smooth.

We compare:
  - Snapshot rate: f(x_tilde_s) - f* averaged across runs.
  - Last-iterate rate: f(x_m^{(s)}) - f* (the very last x in epoch s) averaged across runs.
"""

import numpy as np
import math

rng = np.random.default_rng(0)

def make_problem_B(L=1.0, d=3):
    # n=2 components, see header.
    A1 = np.zeros((d, d)); A1[0,0]=1; A1[0,d-1]=1; A1[d-1,0]=1; A1[d-1,d-1]=1
    A2 = np.zeros((d, d)); A2[1,1]=1; A2[1,d-1]=1; A2[d-1,1]=1; A2[d-1,d-1]=1
    H1 = (L/2.0) * A1   # Hess of f_1(x) = (L/4)(x1+x_d)^2 -> Hess = (L/2)*A1
    H2 = (L/2.0) * A2
    Hbar = 0.5 * (H1 + H2)  # Hess of f
    def f_i(i, x):
        if i == 0:
            return 0.25 * L * (x[0] + x[d-1])**2
        else:
            return 0.25 * L * (x[1] + x[d-1])**2
    def grad_i(i, x):
        if i == 0:
            return H1 @ x
        else:
            return H2 @ x
    def f(x):
        return 0.5 * x @ (Hbar @ x)
    def grad(x):
        return Hbar @ x
    return {
        "L_smooth": L,    # per-component L_i = L (top eigval of H_i)
        "f": f, "grad": grad, "f_i": f_i, "grad_i": grad_i,
        "n": 2, "d": d,
    }

def project_x_star(x):
    # nearest point on {x1=x2=-x3}
    # parameterize as (a, a, -a). Minimize ||x - (a,a,-a)||^2 over a.
    # 2(a-x1) + 2(a-x2) + 2(-(-x3)-(-a))*... let me just do it.
    # f(a) = (a-x1)^2 + (a-x2)^2 + (-a-x3)^2; df/da = 2(a-x1)+2(a-x2)+2(-a-x3)*(-1)*... wait
    # d/da (-a-x3)^2 = 2(-a-x3)*(-1) = -2(-a-x3) = 2(a+x3)
    # df/da = 2(a-x1) + 2(a-x2) + 2(a+x3) = 0 -> 3a = x1+x2-x3 -> a = (x1+x2-x3)/3
    a = (x[0] + x[1] - x[2]) / 3.0
    return np.array([a, a, -a])

def run_svrg(prob, x0, m, S, eta=None, seed=0):
    """Run SVRG for S epochs of length m. Snapshot = uniform random pick within epoch.
       Returns: list of (snapshot_subopt, last_iterate_subopt) per epoch."""
    rng_local = np.random.default_rng(seed)
    L = prob["L_smooth"]
    if eta is None:
        eta = 1.0 / (3.0 * L)
    n = prob["n"]
    grad_i = prob["grad_i"]
    grad = prob["grad"]
    f = prob["f"]

    x_tilde = x0.copy()
    history = []
    for s in range(S):
        gtilde = grad(x_tilde)
        xs = [x_tilde.copy()]
        for t in range(m):
            x_t = xs[-1]
            i_t = rng_local.integers(n)
            v = grad_i(i_t, x_t) - grad_i(i_t, x_tilde) + gtilde
            x_next = x_t - eta * v
            xs.append(x_next)
        # snapshot for next epoch: uniform random pick from xs[0..m-1]
        idx = rng_local.integers(m)
        x_snapshot = xs[idx]
        x_last = xs[-1]
        history.append((float(f(x_snapshot)), float(f(x_last))))
        x_tilde = x_snapshot
    return history

def main():
    L = 1.0
    prob = make_problem_B(L=L)
    # initial point with both null and non-null components
    x0 = np.array([1.0, 1.0, 1.0])  # NOT in null space
    # x* = projection of x0 onto null line
    xstar = project_x_star(x0)
    D = np.linalg.norm(x0 - xstar)
    print(f"x* approx {xstar}, D={D:.4f}, f(x0)-f*={prob['f'](x0):.4f}")

    S = 5
    runs = 400
    for m in [16, 64, 256, 1024]:
        snap_avg = np.zeros(S)
        last_avg = np.zeros(S)
        for r in range(runs):
            hist = run_svrg(prob, x0, m=m, S=S, seed=10000 + r)
            for s, (snap, last) in enumerate(hist):
                snap_avg[s] += snap / runs
                last_avg[s] += last / runs
        # compare last vs snapshot at epoch S
        s_idx = S - 1
        # Theoretical baseline LD^2/(s*m), where s = S
        baseline = L * D*D / ((s_idx+1) * m)
        # Ratios
        snap_ratio = snap_avg[s_idx] / baseline
        last_ratio = last_avg[s_idx] / baseline
        log_factor = math.log(m)
        print(f"m={m:5d}  snap={snap_avg[s_idx]:.6f}  last={last_avg[s_idx]:.6f}  "
              f"baseline={baseline:.6f}  snap/baseline={snap_ratio:.3f}  "
              f"last/baseline={last_ratio:.3f}  last/(log m * baseline)={last_ratio/log_factor:.3f}")

if __name__ == "__main__":
    main()
