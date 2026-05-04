# 8.9 — Geometric / Riemannian Interpretation of SHB Cycling

**Date:** 2026-04-26
**Status:** NEGATIVE (clean) — SHB cycling has no Riemannian-geodesic interpretation. The right framework is **discrete equivariant dynamics + convex analysis on polytopes**.

## Verdict

**SHB cycling is Euclidean-algebraic, not Riemannian-geometric.** Cycling is a discrete-time resonance phenomenon driven by the algebraic identity between (i) the rotation $R_{\theta_K}$ acting on the regular $K$-gon polytope $\widetilde P$ and (ii) the SHB recursion's response on the piecewise-linear-gradient regions of the Moreau-envelope function $f_0$.

## Three pieces of evidence for the negative verdict

### 1. Continuous limit kills cycling

The SHB ODE $\ddot x + \gamma \dot x = -\nabla f_0(x)$ has Lyapunov function $E(x, \dot x) = \tfrac{1}{2}\|\dot x\|^2 + f_0(x)$ with
$$\dot E = -\gamma \|\dot x\|^2 \le 0.$$
For $\gamma > 0$ (positive damping), $\dot E < 0$ unless $\dot x \equiv 0$, so the only $\omega$-limit set is $\{0\}$. **The continuous heavy-ball ODE on $f_0$ admits no nontrivial limit cycle.** Cycling lives strictly in discrete time.

### 2. Hessian of $f_0$ at cycle is rank-1 perturbation, supported on a stratification

At cycle vertex $\lambda e_t$:
$$\nabla^2 f_0(\lambda e_t) = \mu I_2 + (L-\mu) u_t u_t^\top,$$
where $u_t$ = unit tangent to the active edge. Eigenvalues: $L$ (along edge tangent), $\mu$ (along outward normal). Conditioning $L/\mu$ is fixed, with the soft direction always pointing radially outward.

Critical issue: $\nabla^2 f_0$ is **piecewise constant with jumps** on the polytope-distance stratification. The cycle vertices lie *exactly on the discontinuity locus*. Christoffel symbols of any "metric" $g = \nabla^2 f_0$ are distributional — no classical Riemannian geometry.

### 3. No geodesic equation matches

Discrete geodesic on $(\mathbb{R}^2, g)$:
$$x_{t+1} - 2 x_t + x_{t-1} + \tau^2 \Gamma^k_{ij}(x_t)(x_{t+1} - x_t)^i(x_t - x_{t-1})^j = 0.$$
SHB:
$$x_{t+1} - 2 x_t + x_{t-1} = -\eta\nabla f_0(x_t) + (\beta - 1)(x_t - x_{t-1}).$$
The damping term $(\beta - 1)(x_t - x_{t-1})$ is **first-order in velocity**, while Christoffel terms are quadratic. **Velocity-linear damping cannot be matched by Christoffel symbols.** SHB is a damped second-order discrete system, not a geodesic.

## What IS preserved geometrically

The cycle orbit lies on the Euclidean circle $S^1(\lambda)$, traces equal arcs, and is mapped to itself by the isometry $R_{\theta_K} \in \mathrm{SO}(2)$. The cycle is a **discrete one-parameter orbit of a finite cyclic isometry group** $\mathbb{Z}/K$ — the relevant structure-preserving theory is **equivariant dynamical systems** (representation theory of $\mathbb{Z}/K$ on $\mathbb{R}^2$), not Riemannian geometry.

## Bregman attempt

With $\phi := f_0$, $D_\phi(\lambda e_{t+1}, \lambda e_t)$ is constant along the cycle (rotation invariance) and bounded — but $D_\phi$ is asymmetric, doesn't yield a metric.

## Failed metric candidates

| Candidate | Why it fails |
|---|---|
| $g = \nabla^2 f_0$ | Discontinuous on polytope stratification |
| $g = $ smoothed Hessian | Curvature concentrates on measure-zero set |
| $g = $ constant rescaling | Cycle isn't geodesic on $(\mathbb{R}^2, \mu I)$ |
| $g = $ round $S^2$ | Only great circles geodesic; cycle is small circle |

## Take-away

**Cycling is structurally Euclidean and discrete.** The right framework:
- **Equivariant dynamics:** discrete $\mathbb{Z}/K$ symmetry of the orbit.
- **Convex analysis on polytopes:** Moreau envelope structure + rotation-invariant polytopes.

A Riemannian story would require continuous-time geodesic flow, conservative dynamics, and smooth metric — all incompatible with SHB cycling's discrete, dissipative, piecewise-flat nature.

This is a clean *negative* result with publication value as a remark/note. Save the geometers' time: don't search for a Riemannian framework.
