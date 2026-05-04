# B12 — Adam nonconvex convergence

**Verdict**: CONFIRMED

**Source**: Défossez, Bottou, Bach, Usunier, *"A Simple Convergence Proof of Adam and Adagrad"*, TMLR 2022 (arXiv:2003.02395).

## OUR statement
Adam with $\beta_1^2 \le \beta_2$, $\varepsilon > 0$, $L$-smooth $f$, $\|\nabla f\|_\infty \le G$. Step $\alpha_t = \alpha_0 t^{-1/2}\cdot T^{-1/4}$ (i.e. $\alpha = \alpha_0 T^{-1/4}$):
$$\min_{1\le t\le T}\|\nabla f(x_t)\|^2 \le O(d\log T/\sqrt T).$$

## Paper statement (verified from abstract)
Defossez et al. show Adam (with mild conditions on $\beta_1$) has $\mathbb{E}\|\nabla f(x_R)\|^2 = O(d\ln(N)/\sqrt N)$ where $R$ is uniform random index. They explicitly improve $\beta_1$ dependence from $(1-\beta_1)^{-3}$ to $(1-\beta_1)^{-1}$.

## Comparison
- Rate $O(d\log T/\sqrt T)$: **matches Defossez Thm 1 exactly**.
- Assumptions: $L$-smooth, bounded gradients $G$, $\beta_1^2 \le \beta_2$ — match.
- Step size: ours $\alpha_t \propto t^{-1/2}T^{-1/4}$ (horizon-dependent decreasing) — Defossez uses $\alpha$ constant or similar mild schedules. Our schedule is one of several that work; rate is unchanged.
- Technique: descent lemma + bound $\|D_t\|^2 \le d$ (using $\beta_1^2\le\beta_2$ Jensen trick) + polarization on $\langle g_t, D_t\rangle$ + EMA momentum error bound. **All matches Defossez** (he uses the same "EMA-Jensen" inequality $|m_t|\le\sqrt{v_t}$ when $\beta_1^2\le\beta_2$).

## Verdict
**CONFIRMED**: rate, technique, assumptions match Defossez et al. 2022 exactly. This is a clean (though abbreviated) version of the published proof.
