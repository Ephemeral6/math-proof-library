"""
PEP / SDP numerical UB for fixed-momentum SHB last iterate, stochastic
L-smooth convex.

Variables in the PEP lift (Gram matrix):
  vectors  v_0,...,v_{T-1}   = gradients g_t = nabla f(x_t)
           v_T                = x_0 - x*
           v_{T+1},...,v_{2T} = noise xi_0,...,xi_{T-1}
  scalars  F_0,...,F_T        = f(x_t) - f^*

So Gram matrix G has size N = 2T + 1.

Iterates (linear in lift vectors):
  x_t - x_0  = - sum_{s<t} eta * c_{t,s} * (g_s + xi_s)
  with c_{t,s} = sum of beta^k over feasible k = (1 - beta^{t-s})/(1-beta)
  (one-step expansion of fixed-momentum SHB with x_{-1} = x_0)
  x_t - x* = (x_0 - x*) - eta * sum_{s<t} c_{t,s} (g_s + xi_s)

Each x_t - x* is a known LINEAR combination of the Gram-matrix vectors.

L-smooth convex interpolation (Taylor-Hendrickx-Glineur):
  For all i, j in {0,...,T, *}:
    f_i >= f_j + <g_j, x_i - x_j> + (1/(2L)) ||g_i - g_j||^2.
  with f_* = 0 and g_* = 0.

Initial condition: ||x_0 - x*||^2 <= D^2.
Noise: E ||xi_t||^2 <= sigma^2 (treat as one-shot worst-case bound on the
diagonal of G corresponding to xi_t; this is the deterministic-noise
relaxation that gives a valid UB on the expectation).
Independence: xi_t independent across t and of g_s, x_0 - x*.  In the
PEP lift, independence in expectation is encoded by setting the
corresponding off-diagonal Gram entries to 0 (for the expectation, the
cross moments vanish).  This gives the *expectation* PEP.

Objective: maximize f_T - f^* = F_T.

We implement two variants:
 - "expectation" mode: zero out cross-Gram entries between xi_t and
   anything else; off-diag between xi_s, xi_t (s != t) are 0.  This is
   the correct stochastic PEP for E[f_T - f*] under the i.i.d.
   zero-mean variance-sigma^2 noise.
 - "worstcase" mode: do not zero noise correlations; gives a (loose)
   adversarial-noise UB.

We always require G >= 0 PSD.

Author: Explorer 5 (Direction 2, Route E)
"""

import numpy as np
import cvxpy as cp
import json
import sys


def solve_pep(T, beta, eta, L=1.0, D=1.0, sigma=1.0, mode="expectation",
              solver="SCS", verbose=False):
    """Solve the stochastic PEP SDP for SHB."""
    # Indices in the lift:
    #   g_0,...,g_{T-1}            -> 0..T-1
    #   x0_minus_xstar             -> T
    #   xi_0,...,xi_{T-1}          -> T+1..2T
    N = 2 * T + 1

    # Coefficients c_{t,s} = (1 - beta^{t-s}) / (1 - beta), for s < t
    # x_t - x* = (x_0 - x*) - eta * sum_{s=0}^{t-1} c_{t,s} (g_s + xi_s)
    def c(t, s):
        # s < t; expand the SHB one-step recursion x_{t+1} = x_t - eta g_t
        # + beta(x_t - x_{t-1}); with x_{-1} = x_0 the closed form for the
        # iterate update is sum_{k=0}^{t-1-s} beta^k = (1-beta^{t-s})/(1-beta).
        if abs(1.0 - beta) < 1e-12:
            return float(t - s)
        return (1.0 - beta ** (t - s)) / (1.0 - beta)

    # Build a (2T+1)-vector that represents x_t - x* in the lift basis.
    def x_minus_xstar(t):
        v = np.zeros(N)
        v[T] = 1.0   # x_0 - x*
        for s in range(t):
            cs = c(t, s)
            v[s] -= eta * cs           # gradient component
            v[T + 1 + s] -= eta * cs   # noise component
        return v

    # Lift vectors: g_t -> e_t, x_0-x* -> e_T, xi_t -> e_{T+1+t}.
    def grad_vec(t):
        v = np.zeros(N)
        v[t] = 1.0
        return v

    # PSD Gram matrix
    G = cp.Variable((N, N), symmetric=True)

    # Function values f_t - f^*
    F = cp.Variable(T + 1)

    constraints = [G >> 0]

    # Initial distance: ||x_0 - x*||^2 = G[T,T] <= D^2
    constraints.append(G[T, T] <= D ** 2)

    # Noise constraints: E ||xi_t||^2 = G[T+1+t, T+1+t] <= sigma^2
    for t in range(T):
        idx = T + 1 + t
        constraints.append(G[idx, idx] <= sigma ** 2)

    if mode == "expectation":
        # In expectation, xi_t is zero-mean, independent of x_0-x*, of g_s
        # for s <= t (g_s is measurable w.r.t. F_s, xi_t for t >= s is
        # independent of g_s only if t >= s; but in the PEP formulation we
        # treat the *full* Gram matrix and the lift point representation
        # x_t - x* = ... so that g_s = nabla f(x_s) sees noise xi_{s-1}
        # but is independent of xi_s, xi_{s+1},...
        # For a clean valid relaxation, we zero cross moments between xi_t
        # and xi_s for s != t, and between xi_t and (g_s, x_0-x*) for ALL s.
        # This is conservative: it forces xi to be a martingale-difference
        # noise that is uncorrelated with the iterate-dependent objects.
        # In reality g_s depends on xi_0..xi_{s-1}, but those cross moments
        # have a definite sign in the worst case, so dropping them gives an
        # UB on E[f_T - f*].  (Standard stochastic-PEP convention.)
        for t in range(T):
            it = T + 1 + t
            # xi_t orthogonal to x_0 - x*
            constraints.append(G[it, T] == 0)
            # xi_t orthogonal to all gradients g_s
            for s in range(T):
                constraints.append(G[it, s] == 0)
            # xi_t orthogonal to xi_s for s != t
            for s in range(t + 1, T):
                js = T + 1 + s
                constraints.append(G[it, js] == 0)
    # else mode == "worstcase": no extra zero-correlation constraints.

    # Smooth-convex interpolation constraints (Taylor-Hendrickx-Glineur):
    # f_i >= f_j + <g_j, x_i - x_j> + (1/(2L)) ||g_i - g_j||^2.
    # Indices i, j in {0,...,T, *}.  We set f_* = 0 and g_* = 0.
    # Helpers to compute Gram inner products as cvxpy expressions.
    def ip(u_vec, w_vec):
        # u, w are (N,) numpy arrays of coefficients
        # returns u^T G w as cvxpy scalar
        return cp.sum(cp.multiply(np.outer(u_vec, w_vec), G))

    # Pre-compute x_t - x* coefficient vectors
    Xmx = [x_minus_xstar(t) for t in range(T + 1)]
    # Gradients g_t for t < T are basis e_t; we don't have g_T because the
    # algorithm terminates at x_T (no gradient query at last point).
    # But the interpolation constraint requires g_T to encode f at x_T.
    # We add an extra gradient variable g_T in the lift.  For PEP, we add
    # one more dimension to the Gram matrix.
    # --> Re-do with N' = 2T+2.
    pass  # See refactored version below.

    # NOTE: the formulation above forgot to include g_T (the gradient at x_T).
    # We refactor.
    raise RuntimeError("Use solve_pep_v2 below; this version is incomplete.")


def solve_pep_v2(T, beta, eta, L=1.0, D=1.0, sigma=1.0, mode="expectation",
                 solver="SCS", verbose=False, max_iters=20000):
    """Refined PEP SDP for SHB last iterate, including g_T = nabla f(x_T)."""
    # Lift dimensions:
    #   g_0,...,g_T            : indices 0..T
    #   (x_0 - x*)             : index T+1
    #   xi_0,...,xi_{T-1}      : indices T+2..2T+1
    N = 2 * T + 2

    def c(t, s):
        if abs(1.0 - beta) < 1e-12:
            return float(t - s)
        return (1.0 - beta ** (t - s)) / (1.0 - beta)

    def x_minus_xstar(t):
        """Coefficient vector for x_t - x* in the lift basis (length N)."""
        v = np.zeros(N)
        v[T + 1] = 1.0   # x_0 - x*
        for s in range(t):
            cs = c(t, s)
            v[s] -= eta * cs              # gradient g_s
            v[T + 2 + s] -= eta * cs      # noise xi_s
        return v

    def grad_vec(t):
        """g_t in the lift basis."""
        v = np.zeros(N)
        v[t] = 1.0
        return v

    G = cp.Variable((N, N), symmetric=True)
    F = cp.Variable(T + 1)  # F[t] = f(x_t) - f^*

    cons = [G >> 0]
    cons.append(G[T + 1, T + 1] <= D ** 2)
    for t in range(T):
        idx = T + 2 + t
        cons.append(G[idx, idx] <= sigma ** 2)

    if mode == "expectation":
        # Martingale-difference noise:
        #   xi_t is independent of (x_0 - x*, xi_0, ..., xi_{t-1}, g_0,...,g_t)
        # because g_s = nabla f(x_s) depends on xi_0,...,xi_{s-1} (NOT on
        # xi_s and later).  So xi_t is uncorrelated with g_s for s <= t,
        # but xi_t IS correlated with g_s for s > t (noise propagation).
        for t in range(T):
            it = T + 2 + t
            cons.append(G[it, T + 1] == 0)             # xi_t _|_ x_0-x*
            for s in range(t + 1):                     # g_s for s <= t
                cons.append(G[it, s] == 0)
            for s in range(t):                         # xi_s for s < t
                js = T + 2 + s
                cons.append(G[it, js] == 0)
            # NOTE: G[it, T+2+t] is the diagonal, bounded by sigma^2 above.
            # For s > t, leave G[it, T+2+s] free.

    Xmx = [x_minus_xstar(t) for t in range(T + 1)]

    def ip_GG(u, w):
        return cp.sum(cp.multiply(np.outer(u, w), G))

    # Interpolation: for all i, j in {0,...,T, *}:
    # f_i - f_j >= <g_j, x_i - x_j> + (1/(2L)) ||g_i - g_j||^2.
    # We use indices 0..T and the special '*' index.
    # f_* = 0, g_* = 0, x_* - x* = 0.
    Fext = list(F) + [0.0]
    Gvec = [grad_vec(t) for t in range(T + 1)] + [np.zeros(N)]
    Xext = Xmx + [np.zeros(N)]

    M = T + 2  # 0..T plus *
    for i in range(M):
        for j in range(M):
            if i == j:
                continue
            xi_xj = Xext[i] - Xext[j]
            gi_gj = Gvec[i] - Gvec[j]
            rhs = ip_GG(Gvec[j], xi_xj) + (1.0 / (2.0 * L)) * ip_GG(gi_gj, gi_gj)
            cons.append(Fext[i] - Fext[j] >= rhs)

    obj = cp.Maximize(F[T])
    prob = cp.Problem(obj, cons)

    try:
        prob.solve(solver=solver, verbose=verbose, max_iters=max_iters)
    except Exception as e:
        return {"status": "error", "error": str(e)}

    return {
        "T": T, "beta": beta, "eta": eta, "L": L, "D": D, "sigma": sigma,
        "mode": mode,
        "status": prob.status,
        "value": float(prob.value) if prob.value is not None else None,
    }


def lyapunov_shb_simulate(T, beta, eta, L=1.0, D=1.0, sigma=1.0,
                          n_trials=20000, instance="quadratic",
                          rng=None):
    """
    Empirical worst-case simulation of fixed-momentum SHB on a fixed
    instance (used as a fallback / sanity check).  Returns
    E[f(x_T) - f*] under i.i.d. Gaussian noise.

    instance:
      "quadratic"  : f(x) = (L/2) x^2 on R, x_0 = D, x* = 0
      "huber"      : f(x) = D L (|x| - D/2) for |x|>D, else (L/2) x^2;
                     a smoothed absolute value
    """
    if rng is None:
        rng = np.random.default_rng(0)
    f_T = np.empty(n_trials)
    for k in range(n_trials):
        if instance == "quadratic":
            x = D
            x_prev = D
            for _ in range(T):
                g = L * x + sigma * rng.standard_normal()
                x_new = x - eta * g + beta * (x - x_prev)
                x_prev = x
                x = x_new
            f_T[k] = 0.5 * L * x ** 2
        else:
            raise ValueError(instance)
    return float(np.mean(f_T)), float(np.std(f_T) / np.sqrt(n_trials))


# -- Driver -------------------------------------------------------------

def main():
    rows = []
    L = D = sigma = 1.0
    Ts = [3, 5, 8, 10]   # keep small for SDP tractability
    betas = [0.0, 0.5, 0.9]
    etas_in_units_of_1_over_L = [0.5, 1.0, 1.5]

    print("# Stochastic PEP for fixed-momentum SHB last iterate")
    print(f"# L={L}, D={D}, sigma={sigma}, mode=expectation")
    print()
    print(f"{'beta':>5} {'etaL':>5} {'T':>3} {'PEP_UB':>10} "
          f"{'LD2/T+sD/sqT':>14} {'ratio':>7}")
    for T in Ts:
        for beta in betas:
            for etaL in etas_in_units_of_1_over_L:
                eta = etaL / L
                # Stability check (necessary spectral condition for SHB on
                # quadratic): eta L < 2(1+beta).  We are loose; PEP will
                # tell us if any worst-case blows up.
                res = solve_pep_v2(T, beta, eta, L=L, D=D, sigma=sigma,
                                   mode="expectation", solver="SCS",
                                   verbose=False, max_iters=30000)
                ub = res.get("value", None)
                ref = L * D ** 2 / T + sigma * D / np.sqrt(T)
                ratio = (ub / ref) if (ub is not None) else None
                row = {**res, "ref_rate": ref, "ratio": ratio}
                rows.append(row)
                ub_str = f"{ub:10.4f}" if ub is not None else "    -     "
                ratio_str = f"{ratio:7.3f}" if ratio is not None else "   -   "
                print(f"{beta:5.2f} {etaL:5.2f} {T:3d} {ub_str} "
                      f"{ref:14.4f} {ratio_str}")

    # Empirical sanity check on the quadratic for one config
    print()
    print("# Empirical Monte-Carlo simulation on f(x) = (L/2)x^2, x_0 = D")
    print(f"{'beta':>5} {'etaL':>5} {'T':>4} {'E[f(x_T)]':>10} {'sderr':>10}")
    for T in [10, 30, 100, 300, 1000]:
        for beta in [0.0, 0.5, 0.9]:
            for etaL in [0.5, 1.0]:
                eta = etaL / L
                m, se = lyapunov_shb_simulate(
                    T, beta, eta, L=L, D=D, sigma=sigma, n_trials=8000)
                print(f"{beta:5.2f} {etaL:5.2f} {T:4d} {m:10.4f} {se:10.4g}")
                rows.append({"sim": True, "T": T, "beta": beta, "eta": eta,
                             "mean_fT": m, "stderr": se})

    with open("d2_e5_pep_results.json", "w") as f:
        json.dump(rows, f, indent=2, default=str)
    print()
    print("Saved results to d2_e5_pep_results.json")


if __name__ == "__main__":
    main()
