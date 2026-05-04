"""Check whether M (the PSD matrix in the LMI) is ACTUALLY PSD for the extracted certificate.

Method:
1. Extract (a₀, a₁, a₂, c₀₁, c₀₂, c₁₂, W, λ_i) from CLARABEL solve.
2. Re-compute the M matrix symbolically using exact substitution.
3. Compute M's eigenvalues. If smallest < 0, the certificate is NOT a valid Lyapunov.

If M's smallest eigenvalue is slightly negative (e.g., -1e-3), this explains the
1-6% V violation: the LMI is approximately feasible but not strictly.
"""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).parent))
import warnings; warnings.filterwarnings("ignore")
import numpy as np
import sympy as sp
import cvxpy as cp
from importlib import import_module

# Import the LMI builder but instrument it to return M and lambdas
# Easier: re-derive M from the certificate using the same symbolic structure as 26.

m1 = import_module("26_lookahead_lmi")


def reconstruct_M(L_val, beta_val, eta_val, cert):
    """Given certificate (a, c, λ, W), substitute into the LMI's diff polynomial,
    extract the quadratic form in (g_tp1, g_t, g_p1, g_p2, X_t, X_p1, X_p2),
    and return the corresponding M matrix.

    Use mpmath for high precision."""
    g_tp1, g_t, g_p1, g_p2 = sp.symbols("g_tp1 g_t g_p1 g_p2", real=True)
    X_t, X_p1, X_p2 = sp.symbols("X_t X_p1 X_p2", real=True)
    FE_tp1, FE_t, FE_p1, FE_p2 = sp.symbols("FE_tp1 FE_t FE_p1 FE_p2", real=True)
    a0, a1, a2 = sp.symbols("a0 a1 a2", real=True)
    c01, c02, c12 = sp.symbols("c01 c02 c12", real=True)
    W, alpha = sp.symbols("W alpha", real=True)
    L = sp.S(L_val); beta = sp.S(beta_val); eta = sp.S(eta_val)
    half_inv_L = sp.Rational(1, 2) / L

    dy_t = -eta * g_t + beta * (X_t - X_p1)
    X_tp1 = X_t + dy_t

    V_t = (a0 * X_t**2 + a1 * X_p1**2 + a2 * X_p2**2
           + c01 * X_t * X_p1 + c02 * X_t * X_p2 + c12 * X_p1 * X_p2)
    Q_next = (a0 * X_tp1**2 + a1 * X_t**2 + a2 * X_p1**2
              + c01 * X_tp1 * X_t + c02 * X_tp1 * X_p1 + c12 * X_t * X_p1)
    diff = sp.expand(W * FE_tp1 - (W - alpha) * FE_t + Q_next - V_t)

    G = {}
    # Note: original 26_lookahead_lmi.py uses "S" not "S_fwd" — match it
    G["S"] = FE_t - FE_tp1 + g_t * dy_t + sp.Rational(1, 2) * L * dy_t**2
    G["S_back"] = FE_tp1 - FE_t + g_tp1 * (-dy_t) + sp.Rational(1, 2) * L * dy_t**2
    G["IV_tp1"] = g_tp1 * X_tp1 - FE_tp1 - half_inv_L * g_tp1**2
    G["IV_t"]   = g_t   * X_t   - FE_t   - half_inv_L * g_t**2
    G["IV_p1"]  = g_p1  * X_p1  - FE_p1  - half_inv_L * g_p1**2
    G["IV_p2"]  = g_p2  * X_p2  - FE_p2  - half_inv_L * g_p2**2
    anchors = [("tp1", g_tp1, X_tp1, FE_tp1),
               ("t",   g_t,   X_t,   FE_t),
               ("p1",  g_p1,  X_p1,  FE_p1),
               ("p2",  g_p2,  X_p2,  FE_p2)]
    for ni, gi, Xi, Fi in anchors:
        for nj, gj, Xj, Fj in anchors:
            if ni == nj: continue
            G[f"C_{ni}_{nj}"] = (Fi - Fj) - gj * (Xi - Xj) - half_inv_L * (gi - gj)**2

    # Get lambdas
    lams = cert.get("lambdas", {})

    # Build pos_combo with substituted values
    subs = {a0: cert["a0"], a1: cert["a1"], a2: cert["a2"],
            c01: cert["c01"], c02: cert["c02"], c12: cert["c12"],
            W: cert["W"], alpha: 1.0}
    pos_combo = sp.expand(diff.subs(subs))
    for name, gen in G.items():
        lam_val = lams.get(name, 0.0) if lams else 0.0
        pos_combo = sp.expand(pos_combo + lam_val * gen.subs(subs))

    # Build Poly for proper monomial coefficient extraction.
    state = [g_tp1, g_t, g_p1, g_p2, X_t, X_p1, X_p2]
    FE_vars = [FE_tp1, FE_t, FE_p1, FE_p2]
    all_vars = FE_vars + state
    P = sp.Poly(pos_combo, *all_vars)
    n = len(state)
    M = np.zeros((n, n))

    # Each state var index in P is offset by len(FE_vars)
    for i in range(n):
        for j in range(i, n):
            # Build monomial: state[i] * state[j], with all FE = 0.
            # Monomial degrees = (FE: 0,0,0,0; state[i]: 1, state[j]: 1 if i!=j else state[i]: 2)
            deg = [0]*len(all_vars)
            if i == j:
                deg[len(FE_vars) + i] = 2
            else:
                deg[len(FE_vars) + i] = 1
                deg[len(FE_vars) + j] = 1
            cf = float(P.coeff_monomial(tuple(deg)))
            if i == j:
                M[i, i] = -cf
            else:
                M[i, j] = -cf / 2
                M[j, i] = -cf / 2

    # FE residuals: monomial FE_i alone (state=0)
    FE_violations = {}
    for k, f in enumerate(FE_vars):
        deg = [0]*len(all_vars)
        deg[k] = 1
        cf = float(P.coeff_monomial(tuple(deg)))
        FE_violations[str(f)] = cf

    return M, FE_violations


def main():
    L = 1.0
    points = [
        ("k=1, β=0.5, η=0.3", 0.5, 0.3),
        ("k=1, β=0.7, η=0.15", 0.7, 0.15),
        ("k=1, β=0.95, η=0.02", 0.95, 0.02),
        ("k=1, β=0.97, η=0.025", 0.97, 0.025),
    ]
    print("=" * 100)
    print("Direct M PSD check on extracted certificates")
    print("=" * 100)
    for name, beta, eta in points:
        cert = m1.build_lookahead_lmi(L, beta, eta, fix_alpha=1.0, minimize="C")
        if cert.get("a0") is None:
            print(f"\n{name}: cert failed")
            continue
        print(f"\n{name}: status={cert['status']}, C={cert['C_Lya']:.4f}")
        M, FE_viol = reconstruct_M(L, beta, eta, cert)
        eigs = np.linalg.eigvalsh(M)
        print(f"  M matrix (7x7) eigenvalues:")
        print(f"    min: {eigs[0]:.4e}")
        print(f"    max: {eigs[-1]:.4e}")
        print(f"    all eigs: {eigs}")
        print(f"  FE coefficient residuals:")
        for k, v in FE_viol.items():
            print(f"    {k} coef: {v:.4e}")
        print(f"  Is M actually PSD? {eigs[0] >= -1e-9}")


if __name__ == "__main__":
    main()
