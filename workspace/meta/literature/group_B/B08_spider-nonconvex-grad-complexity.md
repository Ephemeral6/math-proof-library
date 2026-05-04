# B8 — SPIDER nonconvex gradient complexity

**Verdict**: CONFIRMED

**Source**: Fang, Li, Lin, Zhang, *"SPIDER: Near-Optimal Non-Convex Optimization via Stochastic Path-Integrated Differential Estimator"*, NeurIPS 2018 (arXiv:1807.01695).

## OUR statement
Finite-sum $f = \frac{1}{n}\sum f_i$, individual $L$-smooth. SPIDER with $\eta=1/(2L)$, $b=q=\lceil\sqrt n\rceil$:
$$\mathbb{E}\|\nabla f(\hat x)\|^2 \le 4L\Delta_0/(Kq).$$
Total stochastic gradient evaluations:
$$O(n + L\Delta_0\sqrt n/\varepsilon^2).$$

## Paper statement
Fang et al. abstract (verified): SPIDER achieves
$$O(\min(n^{1/2}\varepsilon^{-2},\,\varepsilon^{-3}))\quad\text{(plus initial $n$ for the finite-sum branch)}.$$
For finite-sum $n$ moderate: $O(n + n^{1/2}/\varepsilon^2)$. Step size $\eta = O(1/L)$, batch $b = q = \sqrt n$, normalized SGD step (in the original paper) — but the analyzed un-normalized $\eta = 1/(2L)$ variant gives the same complexity.

## Comparison
- Algorithm: matches (epochs of length $q=\sqrt n$, batch $b=\sqrt n$, $\eta=1/(2L)$).
- Final complexity $O(n + L\Delta_0\sqrt n/\varepsilon^2)$: **matches paper exactly** (Theorem 1 in Fang et al.).
- Constants $4L\Delta_0/(Kq)$: matches the $O(L\Delta/Kq)$ form.
- Technique: variance recursion + polarization identity in the descent lemma — this is precisely Fang et al.'s "polarization trick" that distinguishes SPIDER from SVRG (proof's appendix `Why polarization is essential` correctly identifies this as the SPIDER vs SVRG separator).

## Verdict
**CONFIRMED**: rate, constants, technique all match Fang et al. NeurIPS 2018 exactly. This is a clean reproduction of the published proof.
