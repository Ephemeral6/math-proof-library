"""
NumPy simulation: Best-iterate value of SHB on Goujaud's f for several (β, η) pairs in F.

Confirms:
1. Min-over-time f_0(x_t) ≥ κLD²/4 for all t ≥ 0 (no transient dip).
2. Stochastic best-iterate of g_y has gap ≥ c' σD/√T with constant c' bounded below.
"""
import numpy as np

np.random.seed(0)
L = 1.0
D = 1.0


def cyc_lhs(beta, eta, kappa, K):
    """Goujaud cycling LHS at given (β, η, κ, K). ≤ 0 means feasible."""
    cK = np.cos(2 * np.pi / K)
    z = kappa * eta * L
    return z**2 - 2 * (beta - cK + kappa * (1 - beta * cK)) * z + 2 * kappa * (1 - cK) * (1 + beta**2 - 2 * beta * cK)


def find_kappa(beta, eta, K, kappas=None):
    if kappas is None:
        kappas = np.linspace(1e-4, 0.999, 1000)
    feas = [k for k in kappas if cyc_lhs(beta, eta, k, K) <= 0]
    if not feas:
        return None
    return feas[len(feas) // 2]


def make_M(beta, eta, kappa, K, L=1.0):
    """Goujaud matrix M (2x2)."""
    th = 2 * np.pi / K
    R = np.array([[np.cos(th), -np.sin(th)], [np.sin(th), np.cos(th)]])
    Rm = R.T
    mu = kappa * L
    M = ((1 + beta - mu * eta) * np.eye(2) - R - beta * Rm) / ((L - mu) * eta)
    return M


def project_polytope(point, P_vertices):
    """Project point onto convex hull of P_vertices via QP. Use simple iterative for K small."""
    # For our cycling construction, x_t IS a vertex, so projection of x_t onto hull is x_t itself if x_t ∈ hull.
    # But we need to test arbitrary points. Use projection onto convex hull = scipy or quadprog.
    # For simplicity, use cvxpy if available, else manual.
    try:
        import cvxpy as cp
        K = P_vertices.shape[0]
        lam = cp.Variable(K, nonneg=True)
        obj = cp.Minimize(cp.sum_squares(P_vertices.T @ lam - point))
        prob = cp.Problem(obj, [cp.sum(lam) == 1])
        prob.solve()
        return P_vertices.T @ lam.value
    except ImportError:
        # Fallback: project via gradient descent
        K = P_vertices.shape[0]
        lam = np.ones(K) / K
        for _ in range(2000):
            x = P_vertices.T @ lam
            grad = 2 * P_vertices @ (x - point)
            lam = lam - 0.01 * grad
            lam = np.maximum(lam, 0)
            if lam.sum() > 0:
                lam = lam / lam.sum()
        return P_vertices.T @ lam


def grad_psi(x, P_vertices, mu, L=1.0):
    """grad psi(x) = mu*x + (L-mu)*P_C(x)."""
    pc = project_polytope(x, P_vertices)
    return mu * x + (L - mu) * pc


def psi_value(x, P_vertices, mu, L=1.0):
    """psi(x) = (L/2)||x||^2 - ((L-mu)/2)*d_C(x)^2."""
    pc = project_polytope(x, P_vertices)
    d_sq = np.sum((x - pc) ** 2)
    return 0.5 * L * np.sum(x**2) - 0.5 * (L - mu) * d_sq


def f0_value(x, P_vertices, mu, L=1.0, D=1.0):
    """f_0(x) = D^2 * psi(x/D)."""
    return D**2 * psi_value(x / D, P_vertices, mu, L)


def grad_f0(x, P_vertices, mu, L=1.0, D=1.0):
    """∇f_0(x) = D * ∇psi(x/D)."""
    return D * grad_psi(x / D, P_vertices, mu, L)


def run_shb_x(beta, eta, kappa, K, T, D=1.0, L=1.0):
    """Run SHB on f_0 for T steps, return list of f_0 values."""
    mu = kappa * L
    M = make_M(beta, eta, kappa, K, L)
    # vertices in scaled space (D/sqrt(2) circle, since the polytope conv(P) lives at unit circle in psi-space, rescaled by D)
    # In psi-space (unit circle): e_t = (cos(2πt/K), sin(2πt/K))
    e = np.array([[np.cos(2 * np.pi * t / K), np.sin(2 * np.pi * t / K)] for t in range(K)])
    # P vertices in psi-space:
    P_psi = e @ M.T  # shape (K, 2)
    # In f_0 space (rescaled by D): vertices at D * (1) circle (initialization at D/sqrt(2) in OP-2 scaling).
    # OP-2: x_0 = (D/sqrt 2) e_0, x_{-1} = (D/sqrt 2) e_{K-1}. Map y = x / (D/sqrt 2), so y starts at e_0.
    # Then y_t evolves under HB on psi. So x_t = (D/sqrt 2) e_t.
    # Let's track x in original space:
    x = np.zeros((T + 2, 2))
    x[0] = (D / np.sqrt(2)) * e[0]
    x[1] = (D / np.sqrt(2)) * e[0]  # x_0 (initial, but we want to also have x_{-1})
    # Wait, indexing: let x[0] = x_{-1}, x[1] = x_0.
    x[0] = (D / np.sqrt(2)) * e[(K - 1) % K]
    x[1] = (D / np.sqrt(2)) * e[0]
    f_vals = []
    P_vertices_scaled = (D / np.sqrt(2)) * P_psi  # scaled vertices in original space
    # Actually for psi rescaled to f_0: f_0(x) = D^2 psi(x/D). So conv(P) in psi-space scales to D*conv(P) in f_0 space.
    # But OP-2's rescaling factor was sqrt(2)/D not 1/D. Let me recheck.
    # OP-2 §3.2: λ = 1/D, f_0(x) = λ^{-2} ψ(λx) = D^2 ψ(x/D). Hessian is same as ψ. Cycle in ψ at unit radius → cycle in f_0 at radius D.
    # OP-2 §3.5: x_0 = (D/sqrt 2) e_0, where e_0 is unit. Hmm so cycle radius is D/sqrt 2, not D.
    # Why the sqrt 2: because in 3D, x and y each get D/sqrt 2 budget so total ||x_0 - x*|| = D.
    # So the cycle in 2D space lives at radius D/sqrt 2.
    # But Lemma 1 asserted cycling at unit radius for ψ. Cycling at radius D would require f_0(x) = D^2 ψ(x/D).
    # If we scale by sqrt 2 / D instead: f_0(x) = (D^2/2) ψ((sqrt 2 / D) x). Then cycle at radius D/sqrt 2 in f_0 space.
    # Hessian: ∇^2 f_0 = ∇^2 ψ — same spectrum [μ, L]. Smoothness/SC preserved.
    # This is a separate scaling choice; both work. Let's use OP-2's: f_0 scaled so cycle is at D/sqrt 2.
    # I.e., λ = sqrt(2)/D in OP-2 notation: f_0(x) = (1/λ^2) ψ(λx) = (D^2/2) ψ((sqrt 2/D) x).
    # Then ∇f_0(x) = (D/sqrt 2) ∇ψ((sqrt 2/D) x), and the polytope vertices in f_0 space are at (D/sqrt 2) * (psi-vertices on unit circle's M-image).
    # Vertices of polytope in f_0 space: (D/sqrt 2) * M e_t for t in 0..K-1.
    P_vertices_scaled = (D / np.sqrt(2)) * P_psi
    for t in range(1, T + 1):
        # SHB update: x[t+1] = x[t] - eta * grad_f0(x[t]) + beta*(x[t] - x[t-1])
        # Here x[t] corresponds to x_{t-1} in math (off-by-one).
        # Let me redo: math x_t = code x[t+1], math x_{t-1} = code x[t], math x_{-1} = code x[0], math x_0 = code x[1].
        # Update for math x_{t+1}: x_{t+1} = x_t - eta * grad(x_t) + beta*(x_t - x_{t-1})
        # In code: x[t+2] = x[t+1] - eta * grad(x[t+1]) + beta*(x[t+1] - x[t])
        # We want to compute x[t+2] for t=0..T-1, i.e., math x_1, x_2, ..., x_T.
        pass  # Restart loop more cleanly below.
    # Restart loop cleanly:
    x_prev = (D / np.sqrt(2)) * e[(K - 1) % K]  # x_{-1}
    x_curr = (D / np.sqrt(2)) * e[0]              # x_0
    f_vals.append(f0_scaled(x_curr, P_vertices_scaled, mu, L, D))
    for t in range(T):
        # Compute grad at x_curr (math x_t)
        g = grad_f0_scaled(x_curr, P_vertices_scaled, mu, L, D)
        x_next = x_curr - eta * g + beta * (x_curr - x_prev)
        x_prev = x_curr
        x_curr = x_next
        f_vals.append(f0_scaled(x_curr, P_vertices_scaled, mu, L, D))
    return np.array(f_vals)


def f0_scaled(x, P_vertices, mu, L=1.0, D=1.0):
    """Scaled f_0 with cycle at D/sqrt 2: f_0(x) = (D^2/2) psi((sqrt 2/D) x).
    But psi(x) = (L/2)||x||^2 - ((L-mu)/2)*d_C(x)^2 where C is unit-scale polytope.
    Equivalently: in original-coord, conv(P) is at (D/sqrt 2)*M*e_t, and we evaluate
        f_0(x) = (L/2) ||x||^2 - ((L-mu)/2) * d_{(D/sqrt 2)*conv(P_psi)}(x)^2
    Wait — when we scale ψ by λ: f_0(x) = (1/λ^2) ψ(λx) = (1/λ^2)[(L/2)||λx||^2 - ((L-μ)/2) d_C(λx)^2]
                                                       = (L/2)||x||^2 - ((L-μ)/(2λ^2)) d_C(λx)^2
    With λ = sqrt 2/D: 1/λ^2 = D^2/2.
    d_C(λx) = ||λx - P_C(λx)|| where C ⊂ unit-scale. For x in original-coord:
    d_{(1/λ)C}(x) = (1/λ) d_C(λx). So ((L-μ)/(2λ^2)) d_C(λx)^2 = ((L-μ)/2) ((1/λ)d_C(λx))^2 ⋅ 1
    Actually: ((L-μ)/(2λ^2)) d_C(λx)^2 = ((L-μ)/2) * (d_C(λx)/λ)^2 = ((L-μ)/2) * d_{(1/λ)C}(x)^2.
    So f_0(x) = (L/2)||x||^2 - ((L-μ)/2) d_{(1/λ)C}(x)^2 with (1/λ)C = (D/sqrt 2) * conv(P_psi).
    """
    pc = project_polytope(x, P_vertices)
    d_sq = np.sum((x - pc) ** 2)
    return 0.5 * L * np.sum(x**2) - 0.5 * (L - mu) * d_sq


def grad_f0_scaled(x, P_vertices, mu, L=1.0, D=1.0):
    pc = project_polytope(x, P_vertices)
    return mu * x + (L - mu) * pc


# ============================
# PART A: Bias bound (deterministic)
# ============================
print("=" * 70)
print("PART A: Min-over-time f_0(x_t) on the Goujaud cycle (deterministic)")
print("=" * 70)
print(f"{'(β,η/L)':<15}{'K':<4}{'κ':<10}{'μ':<10}{'min_t f_0':<14}{'κLD²/4':<10}{'pass'}")
test_cases = [
    (0.5, 3.0, 3),
    (0.7, 2.9, 3),
    (0.9, 3.5, 3),
    (0.4, 2.65, 3),
    (0.95, 3.85, 3),
]
for beta, etaL, K in test_cases:
    eta = etaL / L
    kappa = find_kappa(beta, eta, K)
    if kappa is None:
        print(f"  ({beta},{etaL})  K={K}  NO κ")
        continue
    mu = kappa * L
    T = 300
    f_vals = run_shb_x(beta, eta, kappa, K, T, D, L)
    min_f = f_vals.min()
    target = kappa * L * D**2 / 4
    ok = "YES" if min_f >= target * 0.999 else "NO"
    print(f"  ({beta},{etaL})  K={K}  κ={kappa:.4f}  μ={mu:.4f}  min={min_f:.5f}  target={target:.5f}  {ok}")


# ============================
# PART B: Variance bound (stochastic) — best-iterate Le Cam
# ============================
print()
print("=" * 70)
print("PART B: Best-iterate stochastic gap on g_y (Rademacher noise)")
print("=" * 70)
# Run SHB on the y-coordinate alone; track g_y(y_t) - min g_y over time.
# g_y(y) = alpha_s y + (L/2) max(|y| - D/sqrt 2, 0)^2
# alpha_s = s * sigma / (2 sqrt(2T))
# Oracle: alpha_s + sigma * eps_t (Rademacher)
sigma = 1.0


def g_y(y, alpha, L, D):
    base = alpha * y
    wall = (L / 2) * max(abs(y) - D / np.sqrt(2), 0) ** 2
    return base + wall


def g_y_min(alpha, L, D):
    """Minimum of g_y. Linear inside box, quadratic wall outside.
    For alpha > 0: derivative inside is +alpha; outside (y < -D/sqrt 2): alpha - L(|y| - D/sqrt 2).
    Setting to 0: |y| = D/sqrt 2 + alpha/L → y* = -(D/sqrt 2 + alpha/L), OUTSIDE box.
    g_y(y*) = alpha * y* + (L/2)(alpha/L)^2 = -alpha(D/sqrt 2 + alpha/L) + alpha^2/(2L)
            = -alpha*D/sqrt 2 - alpha^2/L + alpha^2/(2L) = -alpha*D/sqrt 2 - alpha^2/(2L)
    Symmetric for alpha < 0. So min = -|alpha|*D/sqrt 2 - alpha^2/(2L).
    """
    return -abs(alpha) * D / np.sqrt(2) - alpha**2 / (2 * L)


def grad_g_y(y, alpha, L, D):
    base = alpha
    wall = L * max(abs(y) - D / np.sqrt(2), 0) * np.sign(y) if abs(y) > D / np.sqrt(2) else 0
    return base + wall


def run_shb_y_stochastic(beta, eta, T, sigma, L, D, s, sigma_seed=0):
    np.random.seed(sigma_seed)
    alpha = s * sigma / (2 * np.sqrt(2 * T))
    y_prev, y_curr = 0.0, 0.0
    gaps = [g_y(y_curr, alpha, L, D) - g_y_min(alpha, L, D)]
    for t in range(T):
        eps = 2 * np.random.randint(2) - 1  # Rademacher
        g = grad_g_y(y_curr, alpha, L, D) + sigma * eps
        y_next = y_curr - eta * g + beta * (y_curr - y_prev)
        y_prev = y_curr
        y_curr = y_next
        gaps.append(g_y(y_curr, alpha, L, D) - g_y_min(alpha, L, D))
    return np.array(gaps)


print("Running Monte Carlo for best-iterate gap, T = 100, several (β,η):")
print(f"{'(β,η/L)':<15}{'T':<6}{'mean gap':<14}{'σD/(8√(2T))':<14}{'ratio'}")
np.random.seed(42)
for beta, etaL in [(0.5, 1.0), (0.7, 0.5), (0.9, 0.5)]:
    eta = etaL / L
    T = 100
    n_trials = 500
    min_gaps = []
    for trial in range(n_trials):
        s = np.random.choice([-1, 1])
        gaps = run_shb_y_stochastic(beta, eta, T, sigma, L, D, s, sigma_seed=trial)
        min_gaps.append(gaps.min())
    mean_min_gap = np.mean(min_gaps)
    target_ny = sigma * D / (8 * np.sqrt(2) * np.sqrt(T))
    ratio = mean_min_gap / target_ny
    print(f"  ({beta},{etaL})  T={T}  {mean_min_gap:.5f}  {target_ny:.5f}  {ratio:.3f}")

# Run with adversarial s (whichever is worse) - use the max over s
print("\nAdversarial s (max over s of E[min_t gap]):")
print(f"{'(β,η/L)':<15}{'T':<6}{'max_s mean min gap':<22}{'σD/(56√T)':<14}{'ratio'}")
for beta, etaL in [(0.5, 1.0), (0.7, 0.5), (0.9, 0.5), (0.5, 0.1), (0.9, 0.05)]:
    eta = etaL / L
    T = 100
    n_trials = 500
    means = {}
    for s in [-1, 1]:
        min_gaps = []
        for trial in range(n_trials):
            gaps = run_shb_y_stochastic(beta, eta, T, sigma, L, D, s, sigma_seed=trial * 2 + (s + 1) // 2)
            min_gaps.append(gaps.min())
        means[s] = np.mean(min_gaps)
    max_mean = max(means.values())
    target = sigma * D / (56 * np.sqrt(T))  # 1/56 from raw Le Cam
    ratio = max_mean / target
    print(f"  ({beta},{etaL})  T={T}  {max_mean:.5f}  {target:.5f}  {ratio:.3f}")

print("\nDone.")
