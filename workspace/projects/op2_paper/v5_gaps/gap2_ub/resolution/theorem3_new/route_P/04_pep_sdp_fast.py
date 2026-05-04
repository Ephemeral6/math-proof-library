"""Route P, step #4: vectorized cvxpy SDP for PEP. Same math as 02 but with cp.trace
on precomputed matrix coefficients - avoids nested Python loops.

Constraint:  F[i] - F[j] - trace(M_ij @ G) - (1/(2L)) * trace(N_ij @ G) >= 0
where
  M_ij  = symmetrize(g_j_vec * (x_i - x_j)_vec.T)
  N_ij  = (g_i - g_j)_vec * (g_i - g_j)_vec.T
and G is the (T+2) x (T+2) Gram matrix of [g_0, ..., g_T, x_0 - x_*].

For each anchor i in {0, ..., T, *}:
  g_i_vec = e_i  (i in 0..T) or 0 (i = *)
  x_i_vec = e_x0_xs + sum_s c[i,s] e_s   (i in 0..T) or 0 (i = *)

This is the standard Taylor-Hendrickx-Glineur formulation, vectorized.
"""
from pathlib import Path
import json
import numpy as np
import cvxpy as cp


def shb_iterate_coeffs(beta, eta, T):
    delta = np.zeros((T + 1, T + 1))
    for t in range(T):
        delta[t + 1] = beta * delta[t]
        delta[t + 1, t] += -eta
    return np.cumsum(delta, axis=0)  # x_t - x_0 = sum_s c[t, s] g_s


def primal_pep_shb_fast(L, beta, eta, T, verbose=False):
    N = T + 2
    c = shb_iterate_coeffs(beta, eta, T)

    star = T + 1

    def g_vec(idx):
        v = np.zeros(N)
        if idx == star:
            return v
        v[idx] = 1.0
        return v

    def x_vec(idx):  # x_idx - x_*
        if idx == star:
            return np.zeros(N)
        v = np.zeros(N)
        v[T + 1] = 1.0
        for s in range(T + 1):
            v[s] += c[idx, s]
        return v

    G = cp.Variable((N, N), symmetric=True)
    F = cp.Variable(T + 1)

    constraints = [G >> 0]

    # Initial condition: ||x_0 - x_*||^2 <= 1, i.e., G[T+1, T+1] <= 1.
    constraints.append(G[T + 1, T + 1] <= 1)

    pair_ineqs = []  # list of (i, j, ineq) for dual extraction
    anchors = list(range(T + 1)) + [star]

    for i in anchors:
        for j in anchors:
            if i == j:
                continue
            gj = g_vec(j)
            xij = x_vec(i) - x_vec(j)
            gigj = g_vec(i) - g_vec(j)

            # M_ij such that trace(M_ij G) = <g_j, x_i - x_j> = sum_{a,b} gj[a]*xij[b]*G[a,b].
            # Using symmetric G, this equals (1/2) * trace((gj xij^T + xij gj^T) @ G)
            # = (1/2) * (gj^T G xij + xij^T G gj) = gj^T G xij  (already symmetric).
            # We can build the asymmetric form gj * xij^T and take trace; cvxpy is OK with that.
            M_ij = np.outer(gj, xij)
            M_sym = (M_ij + M_ij.T) / 2  # symmetric form (equivalent under symmetric G)
            N_ij = np.outer(gigj, gigj)  # already symmetric

            f_i = F[i] if i != star else cp.Constant(0.0)
            f_j = F[j] if j != star else cp.Constant(0.0)

            lhs = f_i - f_j - cp.trace(M_sym @ G) - (1.0 / (2.0 * L)) * cp.trace(N_ij @ G)
            ineq = lhs >= 0
            constraints.append(ineq)
            pair_ineqs.append((i, j, ineq))

    objective = cp.Maximize(F[T])
    problem = cp.Problem(objective, constraints)
    tau = problem.solve(solver=cp.SCS, verbose=verbose)

    duals = []
    for i, j, ineq in pair_ineqs:
        dv = ineq.dual_value
        if dv is None: continue
        if abs(dv) < 1e-7: continue
        duals.append((i, j, float(dv)))

    return tau, duals, G.value, F.value


def find_optimal_eta(L, beta, T, eta_grid):
    best = (np.inf, None)
    for eta in eta_grid:
        try:
            tau, _, _, _ = primal_pep_shb_fast(L, beta, eta, T, verbose=False)
            if tau is None or not np.isfinite(tau): continue
            if tau < best[0]:
                best = (float(tau), float(eta))
        except Exception as e:
            print(f"   eta={eta}: error {e}")
    return best


def label(idx, T):
    return "*" if idx == T + 1 else f"x{idx}"


def main():
    L = 1.0
    eta_grid = list(np.linspace(0.4, 1.0, 7)) + list(np.linspace(1.1, 2.0, 10)) + list(np.linspace(2.2, 3.5, 7))
    print(f"eta grid size: {len(eta_grid)}")

    all_results = {}
    for beta in [0.0, 0.1, 0.3, 0.5]:
        for T in [3, 4, 5, 6, 7]:
            print(f"\n=== beta={beta}, T={T} ===", flush=True)
            tau_best, eta_star = find_optimal_eta(L, beta, T, eta_grid)
            print(f"   tau* = {tau_best:.5e}, tau*T = {tau_best*T:.4f}, eta* = {eta_star:.3f}", flush=True)
            tau_check, duals, G_val, F_val = primal_pep_shb_fast(L, beta, eta_star, T, verbose=False)

            chain_fwd = []; chain_bwd = []; star_out = []; star_in = []; long_range = []
            star_idx = T + 1
            duals_dict = {(i, j): dv for (i, j, dv) in duals}
            for t in range(1, T + 1):
                chain_fwd.append((t, duals_dict.get((t - 1, t), 0.0)))
                chain_bwd.append((t, duals_dict.get((t, t - 1), 0.0)))
            for t in range(0, T + 1):
                star_out.append((t, duals_dict.get((star_idx, t), 0.0)))
                star_in.append((t, duals_dict.get((t, star_idx), 0.0)))
            for (i, j), v in duals_dict.items():
                if i == star_idx or j == star_idx: continue
                if abs(i - j) >= 2:
                    long_range.append((i, j, v))

            print(f"   Chain fwd  λ(x_{{t-1}}, x_t):  {[(t, round(v, 4)) for t, v in chain_fwd]}", flush=True)
            print(f"   Chain bwd  λ(x_t, x_{{t-1}}):  {[(t, round(v, 4)) for t, v in chain_bwd]}", flush=True)
            print(f"   Star out   λ(*, x_t):           {[(t, round(v, 4)) for t, v in star_out]}", flush=True)
            print(f"   Star in    λ(x_t, *):           {[(t, round(v, 4)) for t, v in star_in]}", flush=True)
            long_range.sort(key=lambda kv: -abs(kv[2]))
            print(f"   Top 5 long-range (|i-j|>=2): {len(long_range)} non-zero", flush=True)
            for i, j, v in long_range[:5]:
                print(f"     λ(x_{i}, x_{j}) = {v:.4f}", flush=True)

            all_results[f"beta={beta}_T={T}"] = {
                "beta": beta, "T": T,
                "eta_star": float(eta_star),
                "tau": float(tau_check),
                "tau_T": float(tau_check * T),
                "chain_fwd": [{"t": t, "dual": float(v)} for t, v in chain_fwd],
                "chain_bwd": [{"t": t, "dual": float(v)} for t, v in chain_bwd],
                "star_out": [{"t": t, "dual": float(v)} for t, v in star_out],
                "star_in":  [{"t": t, "dual": float(v)} for t, v in star_in],
                "long_range": [{"i": int(i), "j": int(j), "dual": float(v)}
                               for i, j, v in sorted(long_range, key=lambda kv: -abs(kv[2]))],
            }

    out = Path(__file__).parent / "04_pep_sdp_fast_results.json"
    out.write_text(json.dumps(all_results, indent=2))
    print(f"\nWritten: {out}")


if __name__ == "__main__":
    main()
