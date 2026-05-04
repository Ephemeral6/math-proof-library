# A8: OGDA Bilinear Last-Iterate O(1/T)

**Proof path**: `proofs/research/optimization/convergence/ogda-bilinear-last-iterate/`
**Claimed source**: Mokhtari-Ozdaglar-Pattathil 2020 (arXiv:2002.00057)
**Verdict**: **CONFIRMED** with caveat on rate

## Our claim
For $\min_x\max_y x^T A y$, OGDA with $\eta\le 1/(4\|A\|)$ and $z_{-1}=z_0$:
$$\|z_T - z^*\|^2 \le \frac{C\kappa(A)^2}{T}\|z_0 - z^*\|^2$$
where $\kappa(A) = \sigma_{\max}/\sigma_{\min}$.

## Cross-check
[ARXIV-UNREACHABLE for theorem text] Mokhtari–Ozdaglar–Pattathil 2020 ("Convergence Rate of $\mathcal{O}(1/k)$ for Optimistic Gradient and Extragradient Methods in Smooth Convex-Concave Saddle Point Problems", SIAM J. Opt., arXiv:1906.01115 — note 2002.00057 is **Mokhtari–Ozdaglar–Pattathil 2020 AISTATS** "A Unified Analysis of Extra-gradient and Optimistic Gradient Methods..."). They prove $O(1/T)$ best-iterate; Golowich–Pattathil–Daskalakis–Ozdaglar 2020 (arXiv:2002.05950) prove the **last-iterate** $O(1/\sqrt T)$ for monotone smooth (and $O(1/T)$ for bilinear with restart / linear convergence with strong-monotonicity).

For pure bilinear games specifically, OGDA achieves **linear** rate $\|z_t - z^*\| \le C\rho^t$ where $\rho = 1 - \Omega(1/\kappa^2)$ (Liang-Stokes 2019, Daskalakis-Panageas 2018). The $O(\kappa^2/T)$ rate of our theorem is therefore CONFIRMED-WEAKER than the actually-known **linear** rate for non-degenerate bilinear games.

## Comparison
- **Assumptions**: match for the case $A$ has full rank (otherwise $\kappa(A)$ is undefined).
- **Constants**: $\kappa(A)^2$ factor is consistent.
- **Scope**: We prove $O(\kappa^2/T)$; literature has linear convergence for full-rank bilinear. Our bound is correct but not tight.
- **Technique**: Lyapunov $V_t = \|z_t\|^2 + 3\|z_t - z_{t-1}\|^2$ + telescoping is standard (Mokhtari et al. style).

## Verdict
**CONFIRMED-WEAKER**. The bound is mathematically correct and matches one slice of the OGDA literature (rate-1/T for the squared norm). However, the **best-known** rate for bilinear-with-full-rank-A is linear (geometric), which subsumes ours. Our proof is honest but not state-of-the-art.
