# First-order convergence to general (non-strict) local minimax optima

## Source
- Paper: Chae–Kim–Kim, COLT 2023 (stated open problem)
- Context: open since Jin–Netrapalli–Jordan 2019 introduced the local-minimax notion

## Statement

**Definitions (Jin et al. 2019).** Let $f \in C^2(\mathbb{R}^m \times \mathbb{R}^n; \mathbb{R})$.
- A point $(x^\*, y^\*)$ is a **local maximum of $f(x^\*, \cdot)$** at $y^\*$ if there is $\delta_y > 0$ with $f(x^\*, y) \le f(x^\*, y^\*)$ for all $\|y - y^\*\| \le \delta_y$.
- Define $\Phi_\delta(x) := \max_{\|y - y^\*\| \le \delta} f(x, y)$.
- $(x^\*, y^\*)$ is a **local minimax optimum** if $y^\*$ is a local maximum of $f(x^\*, \cdot)$ AND there exists $\delta > 0$ and $\delta_x > 0$ such that $\Phi_\delta(x) \ge \Phi_\delta(x^\*)$ for all $\|x - x^\*\| \le \delta_x$.
- A local minimax optimum is **strict** if both inner local-max and outer local-min are strict (second-order: $\nabla^2_y f(x^\*, y^\*) \prec 0$ and the implicit-function-derived outer Hessian is $\succ 0$).

**Known.** Two-timescale GDA with step ratio $\eta_x / \eta_y \to 0$ is provably attracted to strict local minimax optima (Jin–Netrapalli–Jordan 2019).

**Open problem (Chae–Kim–Kim 2023).** Does there exist a first-order method (only gradient access, no Hessian) that converges to ALL local minimax optima — including non-strict ones where one or both Hessian conditions are degenerate?

**Required outcome.** Prove ONE of:
1. **Positive.** Exhibit a first-order algorithm $\mathcal{A}$ and prove that, under reasonable regularity (e.g., $f \in C^2$, gradients Lipschitz on compact sets, Sard-type conditions ruling out pathologies), the iterates of $\mathcal{A}$ converge to a (general) local minimax optimum from a generic initialization.
2. **Negative.** Prove that no first-order algorithm achieves this — typically by exhibiting a $C^\infty$ instance with a non-strict local minimax optimum that is unstable under any first-order update operator (or at which any first-order method fails to converge from positive-measure initializations).
3. **Partial.** Prove convergence to non-strict local minimax optima under additional structural assumptions (e.g., the inner problem is KL/PL on a neighbourhood; the outer envelope is weakly convex).

## Difficulty
conjecture

## Why this is hard

1. The local-minimax notion is **asymmetric** in $x$ and $y$ (inner max, outer min) — standard saddle-point analysis (e.g., extragradient, OGDA) gives convergence to first-order Nash, not local minimax.
2. **Non-strict** means at least one Hessian eigenvalue is zero — degenerate fixed points are typically saddles for two-timescale GDA flow, so they are repelling.
3. Any positive result must exploit MORE than first-order information at the limit — the algorithm must use first-order queries during execution, but the analysis must somehow distinguish a non-strict local minimax from a non-minimax stationary point.
4. The Jin et al. notion has many degenerate cases: e.g., $f(x, y) = x^2 y$ at $(0, 0)$ is a non-strict local minimax that is not even a critical point in $y$ direction.

## Stuck points anticipated by Scout

1. Building a positive algorithm: any sensible first-order method tracks the Hessian implicitly via finite differences. Without a 2nd-order assumption, finite differences scale badly.
2. Building an impossibility: must rule out all first-order methods, including history-dependent ones — usually requires a Le Cam-style two-point construction within the local-minimax class.
3. The notion's pathologies: $\Phi_\delta(x)$ depends on $\delta$, so the outer problem is parameterized; what is the "right" outer step?
