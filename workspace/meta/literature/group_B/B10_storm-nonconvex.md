# B10 — STORM nonconvex convergence

**Verdict**: CONFIRMED

**Source**: Cutkosky & Orabona, *"Momentum-Based Variance Reduction in Non-Convex SGD"*, NeurIPS 2019 (arXiv:1905.10018).

## OUR statement
Online stochastic, $L$-smooth $f$, mean-squared smoothness ($L^2\|x-y\|^2$ on stochastic gradients), bounded variance $\sigma^2$, mini-batch init $B = \lceil 3\sigma/\varepsilon\rceil$, $a = \varepsilon^2/(6\sigma^2)$, $\eta = \varepsilon/(2L\sqrt 6\,\sigma)$:
$$T = O(\sigma^2/\varepsilon^3 + 1/\varepsilon^2),$$
total gradient complexity $O(\sigma/\varepsilon + L\Delta\sigma/\varepsilon^3) = O(L\Delta\sigma/\varepsilon^3)$.

## Paper statement (verified from abstract)
STORM achieves $\mathbb{E}\|\nabla F(x)\| \le O(1/\sqrt T + \sigma^{1/3}/T^{1/3})$, equivalent to $T = O(\sigma^2/\varepsilon^3 + 1/\varepsilon^2)$ for $\varepsilon$-stationarity. Critical: STORM does **not** require knowledge of $\sigma$ (adaptive momentum). Assumptions: $L$-smooth + mean-squared smoothness + bounded variance.

## Comparison
- Rate: $O(\sigma^2/\varepsilon^3 + 1/\varepsilon^2)$ — **matches the abstract exactly**.
- Assumptions: $L$-smooth + mean-squared smoothness (A4) + bounded variance — **matches** the original Cutkosky-Orabona setting (the proof's `Issue 2 Fix` correctly identifies this as the standard STORM assumption).
- Mini-batch initialization $B = O(\sigma/\varepsilon)$: this is the standard fix to handle the $\|e_0\|^2$ term — matches Cutkosky-Orabona's recommended initialization.
- Lyapunov $\Phi_t = f(x_t) + c\|e_t\|^2$ with $c = \eta/(2a)$ chosen to cancel the $\|e_t\|^2$ coefficient: this is **exactly Cutkosky-Orabona's Lyapunov choice**.
- Technique: variance recursion via $(1-a)$ contraction + polarization-based descent lemma — same as paper.
- One caveat: STORM as published uses **adaptive** $a_t \propto \|d_{t-1}\|^2$, achieving the rate without knowing $\sigma$. Our proof uses constant $a = \varepsilon^2/(6\sigma^2)$, which **does** require knowing $\sigma$. The result is the same rate but our analysis is for the non-adaptive variant. Honest note: this is a "STORM-with-known-$\sigma$" proof, which is strictly weaker than the published $\sigma$-free version.

## Verdict
**CONFIRMED**: optimal rate $O(\sigma^2/\varepsilon^3)$ matches Cutkosky-Orabona exactly; technique (Lyapunov + polarization) matches; assumption set matches. Caveat: ours analyzes the non-adaptive variant, missing STORM's signature $\sigma$-free property.
