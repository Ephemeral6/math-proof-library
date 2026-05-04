# B9 — SPIDER/SARAH variance reduction nonconvex

**Verdict**: CONFIRMED-WEAKER (constant; rate matches)

**Source**: Fang et al. 2018 (1807.01695) and Nguyen et al. 2017 (SARAH, arXiv:1703.00102) — note the cited 1703.00102 paper proves SARAH's strong-convex linear rate; the nonconvex SARAH analysis is in Nguyen et al. 2019 "SARAH: simplification + nonconvex extension" (arXiv:1901.07648 / NeurIPS 2018).

## OUR statement
Finite-sum $f = \frac1n\sum f_i$, individual $L$-smooth. SPIDER/SARAH with $\eta = 1/(10L\sqrt q)$, $q = \lfloor\sqrt n\rfloor$:
$$\mathbb{E}\|\nabla f(\hat x)\|^2 \le \frac{1000L\sqrt q\,\Delta_f}{22T}.$$
Total: $O(n + \sqrt n/\varepsilon^2)$.

## Paper statement
SPIDER (Fang Thm 1) and nonconvex SARAH (Nguyen 2019 Thm 3): same $O(n + \sqrt n/\varepsilon^2)$ complexity with $\eta = O(1/(L\sqrt q))$ and $q = \sqrt n$.

## Comparison
- Algorithm: standard SARAH/SPIDER recursion $v_{t+1} = \nabla f_{i}(x_{t+1})-\nabla f_i(x_t)+v_t$ — matches.
- Step size $\eta = 1/(10L\sqrt q)$ — published is typically $\eta = 1/(2L\sqrt q)$ or $\eta = 1/(L\sqrt q)$. Ours is **5x more conservative**.
- Final complexity $O(n + \sqrt n/\varepsilon^2)$: **matches**.
- Constants: ours has explicit $1000/22 \approx 45$ — published constants are typically $4$ or $8$. So our hidden constant is ~10x looser, but big-O is identical.
- Technique: variance recursion (Lemma 1, identical to Fang/Nguyen) + descent lemma using Young's instead of polarization (less tight than B8 = SPIDER, hence the looser constants). Proof correctly notes this in its commentary.

## Verdict
**CONFIRMED-WEAKER**: optimal complexity rate $O(n+\sqrt n/\varepsilon^2)$ matches Fang/Nguyen exactly; constant ~10x looser due to Young's-rather-than-polarization in the descent step (deliberate, since this proof is the SARAH-route variant; the polarization-route SPIDER gets tight constants in B8).
