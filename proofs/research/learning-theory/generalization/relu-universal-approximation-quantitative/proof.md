# Proof: Quantitative Universal Approximation for ReLU Networks

## Theorem

Let $f: [0,1]^d \to \mathbb{R}$ be $L$-Lipschitz with respect to $\|\cdot\|_\infty$. For any $\varepsilon > 0$, there exists a two-layer ReLU network:
$$\hat{f}(x) = b_0 + w_0^\top x + \sum_{j=1}^N a_j \,\sigma(w_j^\top x + b_j), \quad \sigma(z) = \max(0,z),$$
with $N = O((L/\varepsilon)^d)$ neurons (constant depending only on $d$), such that $\|f - \hat{f}\|_\infty \leq \varepsilon$. Moreover, $\|w_j\|_\infty = O(L)$ and $|b_j| = O(L)$.

---

## Preliminaries

**Definition (Kuhn Triangulation).** Set $M = \lceil L/\varepsilon \rceil$, $\delta = 1/M$. For each cube $Q_\mathbf{k} = \prod_{i=1}^d [k_i\delta, (k_i+1)\delta]$, let $v_0 = \mathbf{k}\delta$. For each permutation $\pi \in S_d$, define:
$$\sigma_\pi = \operatorname{conv}\{v_0,\; v_0 + \delta e_{\pi(1)},\; v_0 + \delta(e_{\pi(1)} + e_{\pi(2)}),\; \ldots,\; v_0 + \delta \textstyle\sum_{j=1}^d e_{\pi(j)}\}.$$

**Lemma 1 (Kuhn Triangulation Properties).**
1. Each $\sigma_\pi$ is a non-degenerate $d$-simplex.
2. The $d!$ simplices tile $Q_\mathbf{k}$ with pairwise disjoint interiors.
3. Total simplices: $d! \cdot M^d$.

*Proof.* (1) Vertices $v_j = v_0 + \delta \sum_{i=1}^j e_{\pi(i)}$ are affinely independent (the edge matrix is lower-triangular with diagonal $\delta$). (2) Each interior point has a strict coordinate ordering determining $\pi$ uniquely. (3) $M^d$ cubes times $d!$. $\blacksquare$

**Lemma 2 (Conformality).** The Kuhn triangulation is conforming across adjacent cubes.

*Proof.* Adjacent cubes $Q_\mathbf{k}$, $Q_{\mathbf{k}+e_m}$ share face $F$ in $\{x_m = (k_m+1)\delta\}$. From $Q_\mathbf{k}$, vertices on $F$ are $v_0 + \delta\sum_{i \in S} e_i$ with $m \in S$. From $Q_{\mathbf{k}+e_m}$, vertices on $F$ are $(v_0+\delta e_m) + \delta\sum_{i \in S'} e_i$ with $m \notin S'$. These sets coincide. The induced $(d-1)$-simplices on $F$ from both sides form the unique $(d-1)$-dimensional Kuhn triangulation. $\blacksquare$

**Lemma 3 (Interpolation Error).** The piecewise affine interpolant $g$ ($g(v) = f(v)$ at grid vertices, affine on each simplex) satisfies $\|f - g\|_\infty \leq L\delta \leq \varepsilon$.

*Proof.* For $x$ in simplex $\sigma$ with vertices $v_0,\ldots,v_d$, write $x = \sum \lambda_i v_i$ (barycentric). Then:
$$|f(x) - g(x)| = \left|\sum \lambda_i(f(x) - f(v_i))\right| \leq \sum \lambda_i L\|x - v_i\|_\infty \leq L\delta. \qquad \blacksquare$$

By conformality, $g$ is globally continuous (shared faces use identical vertices and interpolation from both sides).

**Lemma 4 (1D CPL = Sum of ReLUs).** A CPL function with breakpoints $t_1 < \cdots < t_n$ and slopes $s_0,\ldots,s_n$ satisfies:
$$g(x) = g(0) + s_0 x + \sum_{i=1}^n (s_i - s_{i-1})\sigma(x - t_i).$$

*Proof.* Induction on intervals: slope of RHS on $(t_k, t_{k+1})$ is $s_0 + \sum_{i=1}^k(s_i - s_{i-1}) = s_k$ by telescoping. $\blacksquare$

**Theorem (CPL Representation -- Wang & Sun 2005; Arora et al. 2018).** Every CPL function $g: \mathbb{R}^d \to \mathbb{R}$ with $P$ linear regions can be represented as a single-hidden-layer ReLU network with $N \leq P$ neurons.

---

## Proof of Main Theorem

**Step 1.** Set $M = \lceil L/\varepsilon \rceil$, $\delta = 1/M$, grid $G = \{0,\delta,\ldots,1\}^d$.

**Step 2.** Apply Kuhn triangulation: $d! \cdot M^d$ conforming simplices (Lemmas 1--2).

**Step 3.** Define $g$ as the piecewise affine interpolant of $f$. By conformality, $g$ is continuous.

**Step 4.** $\|f - g\|_\infty \leq L\delta \leq \varepsilon$ (Lemma 3).

**Step 5.** $g$ is CPL with $P = d! \cdot M^d$ regions. By the CPL Representation Theorem, $g$ is a ReLU network with $N \leq d! \cdot M^d$.

**Step 6.** $N \leq d! \cdot \lceil L/\varepsilon \rceil^d = O((L/\varepsilon)^d)$.

**Step 7 (Weight bounds).** On simplex $\sigma_\pi$ with vertices $v_j = v_0 + \delta\sum_{i=1}^j e_{\pi(i)}$:
$$\frac{\partial g}{\partial x_{\pi(j)}} = \frac{f(v_j) - f(v_{j-1})}{\delta}.$$
Since $\|v_j - v_{j-1}\|_\infty = \delta$: $|\partial g/\partial x_i| \leq L$ for all $i$. Hence $\|\nabla g\|_\infty \leq L$, giving $\|w_j\|_\infty = O(L)$, $|b_j| = O(L)$. $\blacksquare$

---

## Self-Contained Proof for $d = 1$

Set $M = \lceil L/\varepsilon \rceil$, $\delta = 1/M$, $t_k = k\delta$. The interpolant $g$ with $g(t_k) = f(t_k)$ satisfies $|f(x)-g(x)| \leq 2\lambda(1-\lambda)L\delta \leq \varepsilon/2$. By Lemma 4: $g(x) = f(0) + s_0\sigma(x) + \sum_{k=1}^{M-1}(s_k-s_{k-1})\sigma(x-t_k)$ with $N = M = O(L/\varepsilon)$. $\blacksquare$
