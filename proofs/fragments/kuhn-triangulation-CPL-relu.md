# Fragment: kuhn-triangulation-CPL-relu

## Statement
Let $f: [0,1]^d \to \mathbb{R}$ be $L$-Lipschitz with respect to $\|\cdot\|_\infty$. Set $M = \lceil L/\varepsilon\rceil$, $\delta = 1/M$, and define the **Kuhn triangulation** of $[0,1]^d$: each unit cube $Q_\mathbf{k}$ is partitioned into $d!$ simplices $\sigma_\pi$ (one per permutation $\pi \in S_d$), each with vertices $v_j = v_0 + \delta\sum_{i=1}^j e_{\pi(i)}$.

The piecewise-affine interpolant $g$ at the grid vertices satisfies:
1. **Conformality**: $g$ is globally continuous (adjacent cubes' simplices match on shared faces).
2. **Approximation**: $\|f - g\|_\infty \le L\delta \le \varepsilon$.
3. **Region count**: $g$ is CPL with $P = d! \cdot M^d$ linear regions.
4. **Slope bound**: $\|\nabla g\|_\infty \le L$.

By the Wang-Sun / Arora et al. CPL representation theorem, $g$ can be expressed as a 2-layer ReLU network with $N \le P = O((L/\varepsilon)^d)$ neurons.

## Proof
**Conformality**: Adjacent cubes $Q_\mathbf{k}, Q_{\mathbf{k}+e_m}$ share face $\{x_m = (k_m + 1)\delta\}$. From either side, the simplices restricted to this face form the unique $(d-1)$-dimensional Kuhn triangulation, hence match identically.

**Approximation**: For $x = \sum_j \lambda_j v_j$ in barycentric coordinates on a simplex,
$$|f(x) - g(x)| = \bigl|\sum_j \lambda_j(f(x) - f(v_j))\bigr| \le \sum_j \lambda_j L\|x - v_j\|_\infty \le L\delta.$$

**Region count**: $M^d$ cubes $\times\, d!$ simplices each.

**Slope bound**: On simplex $\sigma_\pi$, $\partial g/\partial x_{\pi(j)} = (f(v_j) - f(v_{j-1}))/\delta$, with $\|v_j - v_{j-1}\|_\infty = \delta$, so $|\partial g/\partial x_i| \le L$.

**1D CPL → ReLU lemma**: A CPL function with breakpoints $t_1 < \cdots < t_n$ and slopes $s_0, \ldots, s_n$ satisfies $g(x) = g(0) + s_0 x + \sum_i (s_i - s_{i-1})\sigma(x - t_i)$ (telescoping verification). Multivariate CPL with $P$ regions extends via the Wang-Sun construction. $\square$

## Source
- `proofs/research/learning-theory/generalization/relu-universal-approximation-quantitative/proof.md` — Lemmas 1-4 + main theorem.

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (delivers $O((L/\varepsilon)^d)$ width for ReLU universal approximation)
- **Potential applications**:
  - Quantitative universal approximation theorems
  - Constructive proofs of expressivity for piecewise-linear nets
  - Lower bounds against approximation by sums of ridge functions
  - Mesh-based discretization for PDEs / FEM-style ML
  - Discretizing Lipschitz functions for compression or sketching

## Tags
kuhn-triangulation, ReLU, CPL, universal-approximation, lipschitz, mesh
