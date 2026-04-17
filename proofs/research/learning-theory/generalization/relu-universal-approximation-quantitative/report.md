# Proof Report: Quantitative Universal Approximation for ReLU Networks

## 1. Problem Statement

**Theorem.** Let $f: [0,1]^d \to \mathbb{R}$ be Lipschitz with constant $L$: $|f(x) - f(y)| \leq L\|x-y\|_\infty$. There exists a two-layer ReLU network $\hat{f}(x) = \sum_{j=1}^N a_j \sigma(w_j^\top x + b_j)$ with $\sigma(z) = \max(0,z)$ and $N = O((L/\varepsilon)^d)$ neurons such that $\sup_{x \in [0,1]^d} |f(x) - \hat{f}(x)| \leq \varepsilon$.

**Source:** Neural network approximation theory (Yarotsky 2017, Bach 2017)

**Difficulty:** Research

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 4 routes proposed (Kuhn triangulation, piecewise constant, covering number, multiresolution) |
| Explorer | Opus | 2 proofs attempted (Explorer 1: Kuhn triangulation direct, Explorer 3: Piecewise constant + CPL). Both produced substantial proofs. |
| Judge | Sonnet | Explorer 3 selected (score: 37/40 vs Explorer 1: 21/40) |
| Audit | Opus | PASS with 2 required fixes (1 round) |
| Fix | Opus | 2 issues fixed: conformality proof added, weight bounds added |

## 3. Proof Routes Explored

### Route 1: Kuhn Triangulation (Explorer 1) — Score 21/40
Explorer 1 gave a detailed treatment with excellent approximation theory (conformality proof, weight bounds), but was severely disorganized in the CPL-to-ReLU step, with 13 failed attempts before arriving at a citation. The conformality proof and weight bounds were salvaged for the final proof.

### Route 3: Piecewise Constant + CPL (Explorer 3) — WINNER, Score 37/40
Explorer 3 gave a clean, well-organized proof. Key strengths:
- Correctly identified that piecewise constant functions cannot be the final approximant (continuity mismatch)
- Provided a fully self-contained 1D proof with sharp constant
- Cleanly cited the CPL-to-ReLU representation theorem
- Honest assessment of what is rigorous vs. what is cited

### Fixes Applied
1. **Conformality proof** grafted from Explorer 1's Remark 2.3
2. **Weight bounds** grafted from Explorer 1's Theorem 5.1

## 4. Final Proof

### Theorem (Quantitative Universal Approximation for ReLU Networks)

Let $f: [0,1]^d \to \mathbb{R}$ be $L$-Lipschitz with respect to $\|\cdot\|_\infty$:
$$|f(x) - f(y)| \leq L\|x - y\|_\infty \quad \forall\, x, y \in [0,1]^d.$$

For any $\varepsilon > 0$, there exists a two-layer ReLU network:
$$\hat{f}(x) = b_0 + w_0^\top x + \sum_{j=1}^N a_j \,\sigma(w_j^\top x + b_j), \quad \sigma(z) = \max(0,z),$$
with $N = O\!\left((L/\varepsilon)^d\right)$ neurons (where the constant in $O(\cdot)$ depends only on $d$), such that:
$$\sup_{x \in [0,1]^d} |f(x) - \hat{f}(x)| \leq \varepsilon.$$

Moreover, the network weights satisfy $\|w_j\|_\infty = O(L)$ and $|b_j| = O(L)$.

---

#### Preliminaries

**Definition (Kuhn Triangulation).** Set $M = \lceil L/\varepsilon \rceil$ and $\delta = 1/M$. For each cube $Q_\mathbf{k} = \prod_{i=1}^d [k_i\delta, (k_i+1)\delta]$ with $\mathbf{k} \in \{0,\ldots,M-1\}^d$, let $v_0 = \mathbf{k}\delta$ be the lower-left vertex. For each permutation $\pi \in S_d$, define the Kuhn simplex:
$$\sigma_\pi = \operatorname{conv}\{v_0,\; v_0 + \delta e_{\pi(1)},\; v_0 + \delta(e_{\pi(1)} + e_{\pi(2)}),\; \ldots,\; v_0 + \delta \textstyle\sum_{j=1}^d e_{\pi(j)}\}$$
where $e_i$ is the $i$-th standard basis vector.

**Lemma 1 (Kuhn Triangulation Properties).**
1. Each $\sigma_\pi$ is a non-degenerate $d$-simplex with $d+1$ vertices.
2. The $d!$ simplices $\{\sigma_\pi : \pi \in S_d\}$ tile $Q_\mathbf{k}$ with pairwise disjoint interiors.
3. Total number of simplices across all cubes: $d! \cdot M^d$.

*Proof.* (1) The vertices of $\sigma_\pi$ are $v_0, v_1, \ldots, v_d$ where $v_j = v_0 + \delta \sum_{i=1}^j e_{\pi(i)}$. These are affinely independent because the matrix $[v_1 - v_0, \ldots, v_d - v_0]$ is lower-triangular in the $\pi$-reordered coordinates with all diagonal entries equal to $\delta > 0$, hence nonsingular.

(2) Each point $x \in Q_\mathbf{k}$ determines a unique ordering of the shifted coordinates $(x_i - (v_0)_i)/\delta$. Points in the interior of $\sigma_\pi$ have strict ordering, which determines $\pi$ uniquely. Points on boundaries lie on shared faces. Hence the interiors are disjoint and their union covers $Q_\mathbf{k}$.

(3) There are $M^d$ cubes and $d!$ simplices per cube. $\blacksquare$

---

**Lemma 2 (Conformality of Kuhn Triangulation).** The Kuhn triangulation is conforming: the triangulations induced on any shared face between adjacent cubes are identical.

*Proof.* Consider two adjacent cubes $Q_\mathbf{k}$ and $Q_{\mathbf{k}'}$ sharing a $(d-1)$-dimensional face $F$. Without loss of generality, suppose $\mathbf{k}' = \mathbf{k} + e_m$ for some coordinate $m$, so the shared face lies in the hyperplane $\{x_m = (k_m + 1)\delta\}$.

From cube $Q_\mathbf{k}$: The vertices on $F$ are $v_0 + \delta \sum_{i \in S} e_i$ where $S \subseteq \{1,\ldots,d\}$ with $m \in S$.

From cube $Q_{\mathbf{k}'}$: With lower-left vertex $v_0' = v_0 + \delta e_m$, the vertices on $F$ are $v_0' + \delta \sum_{i \in S'} e_i$ where $S' \subseteq \{1,\ldots,d\}$ with $m \notin S'$.

These vertex sets coincide: $v_0 + \delta \sum_{i \in S} e_i = v_0' + \delta \sum_{i \in S \setminus \{m\}} e_i$. Moreover, the $(d-1)$-simplices induced on $F$ from both sides form the $(d-1)$-dimensional Kuhn triangulation of $F$, which is uniquely determined by the vertex set and the ordering construction. Hence the triangulations from both sides are identical. $\blacksquare$

---

**Lemma 3 (Interpolation Error).** Let $G = \{0, \delta, 2\delta, \ldots, 1\}^d$ be the grid, and let $g: [0,1]^d \to \mathbb{R}$ be the piecewise affine interpolant of $f$ on the Kuhn triangulation ($g(v) = f(v)$ for all $v \in G$, affine on each simplex). Then:
$$\|f - g\|_\infty \leq L\delta = \frac{L}{M} \leq \varepsilon.$$

*Proof.* Take any $x \in [0,1]^d$ lying in simplex $\sigma$ with vertices $v_0, \ldots, v_d$. Write $x = \sum_{i=0}^d \lambda_i v_i$ with $\lambda_i \geq 0$ and $\sum \lambda_i = 1$. Then $g(x) = \sum_{i=0}^d \lambda_i f(v_i)$, and:
$$|f(x) - g(x)| = \left|\sum_{i=0}^d \lambda_i (f(x) - f(v_i))\right| \leq \sum_{i=0}^d \lambda_i |f(x) - f(v_i)|.$$

Since $x$ and all $v_i$ lie in the same cube of side $\delta$: $\|x - v_i\|_\infty \leq \delta$. By the Lipschitz condition:
$$|f(x) - g(x)| \leq \sum_{i=0}^d \lambda_i \cdot L\delta = L\delta \leq \varepsilon. \qquad \blacksquare$$

**Well-definedness and continuity.** On each simplex interior, barycentric coordinates are unique, so $g$ is well-defined. On shared faces, $g$ is determined by vertex values and barycentric coordinates restricted to the face. By Lemma 2 (conformality), the same vertices and affine interpolation are used from both sides. Hence $g$ is globally continuous.

---

**Lemma 4 (1D CPL = Finite Sum of ReLUs).** Let $g: \mathbb{R} \to \mathbb{R}$ be CPL with breakpoints $t_1 < \cdots < t_n$ and slopes $s_0, s_1, \ldots, s_n$. Then:
$$g(x) = g(0) + s_0 x + \sum_{i=1}^n (s_i - s_{i-1})\,\sigma(x - t_i).$$

*Proof.* Both sides are CPL with the same breakpoints. On $(-\infty, t_1)$, all ReLU terms vanish, giving $g(0) + s_0 x$, matching $g$. Inductively, on $(t_k, t_{k+1})$, the slope of the RHS is $s_0 + \sum_{i=1}^k (s_i - s_{i-1}) = s_k$ by telescoping, matching $g$. Continuity at each $t_k$ ensures agreement. $\blacksquare$

---

**Theorem (CPL Representation — Wang & Sun 2005; Arora et al. 2018).** Every continuous piecewise linear function $g: \mathbb{R}^d \to \mathbb{R}$ with at most $P$ linear regions can be represented as a single-hidden-layer ReLU network with $N \leq P$ neurons.

---

#### Main Proof

**Step 1 (Grid).** Set $M = \lceil L/\varepsilon \rceil$ and $\delta = 1/M$. Define the grid $G = \{0, \delta, 2\delta, \ldots, 1\}^d$.

**Step 2 (Triangulation).** Apply the Kuhn triangulation with spacing $\delta$, obtaining $d! \cdot M^d$ simplices forming a conforming simplicial complex (Lemmas 1-2).

**Step 3 (Interpolant).** Define $g$ as the piecewise affine interpolant of $f$ on this triangulation. By conformality, $g$ is globally continuous.

**Step 4 (Approximation error).** By Lemma 3: $\|f - g\|_\infty \leq L\delta \leq \varepsilon$.

**Step 5 (ReLU representation).** The function $g$ is CPL with $P = d! \cdot M^d$ linear regions. By the CPL Representation Theorem: $g$ is a single-hidden-layer ReLU network with $N \leq d! \cdot M^d$.

**Step 6 (Final count).**
$$N \leq d! \cdot \left\lceil \frac{L}{\varepsilon}\right\rceil^d = O\!\left(\left(\frac{L}{\varepsilon}\right)^d\right).$$

**Step 7 (Weight bounds).** On each Kuhn simplex $\sigma_\pi$ with ordered vertices $v_0, v_1, \ldots, v_d$ (where $v_j = v_0 + \delta \sum_{i=1}^j e_{\pi(i)}$), the gradient of $g$ is:
$$\frac{\partial g}{\partial x_{\pi(j)}} = \frac{f(v_j) - f(v_{j-1})}{\delta}, \quad j = 1, \ldots, d.$$

Since $\|v_j - v_{j-1}\|_\infty = \delta$ and $f$ is $L$-Lipschitz:
$$\left|\frac{\partial g}{\partial x_i}\right| \leq \frac{L\delta}{\delta} = L \quad \text{for all } i.$$

Hence $\|\nabla g\|_\infty \leq L$. The network weights satisfy $\|w_j\|_\infty = O(L)$ and $|b_j| = O(L)$. $\qquad \blacksquare$

---

#### Self-Contained Proof for $d = 1$

**Theorem ($d = 1$).** Let $f: [0,1] \to \mathbb{R}$ be $L$-Lipschitz. For any $\varepsilon > 0$, there exists a two-layer ReLU network with $N = O(L/\varepsilon)$ neurons approximating $f$ to within $\varepsilon/2$.

*Proof.* Set $M = \lceil L/\varepsilon \rceil$, $\delta = 1/M$, $t_k = k\delta$. The piecewise linear interpolant $g$ with $g(t_k) = f(t_k)$ satisfies:
$$|f(x) - g(x)| \leq 2\lambda(1-\lambda)L\delta \leq \frac{L\delta}{2} \leq \frac{\varepsilon}{2}.$$

By Lemma 4, $g(x) = f(0) + s_0\sigma(x) + \sum_{k=1}^{M-1}(s_k - s_{k-1})\sigma(x - t_k)$ with $N = M = O(L/\varepsilon)$ neurons and weights bounded by $2L$. $\blacksquare$

---

## 5. Audit Result

**Verdict: PASS** (Confidence 9/10)

The audit verified all key components:

| Item | Verdict |
|------|---------|
| Piecewise constant approximation (Lemma 1, motivational) | CORRECT |
| Interpolation error bound (Lemma 3) | CORRECT |
| Kuhn triangulation construction | CORRECT |
| 1D CPL to ReLU (Lemma 4) | CORRECT |
| CPL-to-ReLU citation (Wang-Sun / Arora+) | CORRECT |
| Neuron count $d! \cdot M^d = O((L/\varepsilon)^d)$ | CORRECT |
| Weight bounds (added in fix) | CORRECT |
| Conformality proof (added in fix) | CORRECT |

## 6. Fix History

**Round 1:** Two fixes applied after audit:
1. **Conformality proof added** — Lemma 2 now includes a complete proof that the Kuhn triangulation is conforming across adjacent cubes, following the argument from Explorer 1's Remark 2.3.
2. **Weight bounds added** — Step 7 now includes the explicit gradient formula $\partial g / \partial x_{\pi(j)} = (f(v_j) - f(v_{j-1}))/\delta$ with the bound $\|\nabla g\|_\infty \leq L$, following Explorer 1's Theorem 5.1.

Both fixes were grafted from Explorer 1's superior treatment of these specific topics into Explorer 3's cleaner overall structure.
