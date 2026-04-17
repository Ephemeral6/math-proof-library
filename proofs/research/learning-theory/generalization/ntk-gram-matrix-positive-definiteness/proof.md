# Best Proof: NTK Gram Matrix Positive Definiteness

**Route**: Route 4 — Quadratic Form + Hyperplane Arrangement Adjacency (Du et al. strategy)

## Proof

**Step 1: Rewrite the quadratic form as an expectation of a squared norm.**

For any $c = (c_1, \dots, c_n)^T \in \mathbb{R}^n$ with $c \neq 0$:

$$c^T H^\infty c = \mathbb{E}_{w \sim \mathcal{N}(0,I)}\!\left[\left\|\sum_{i=1}^n c_i \, \mathbf{1}\{w^T x_i \geq 0\} \, x_i\right\|^2\right] \geq 0. \tag{1}$$

This follows from expanding the squared norm and exchanging sum with expectation. Establishes $H^\infty \succeq 0$.

**Step 2: Characterize when the quadratic form equals zero.**

From (1), $c^T H^\infty c = 0$ iff:

$$\sum_{i=1}^n c_i \, \mathbf{1}\{w^T x_i \geq 0\} \, x_i = 0 \quad \text{for a.e. } w. \tag{2}$$

**Step 3: Partition into activation regions.**

The $n$ hyperplanes $\Pi_i = \{w : w^T x_i = 0\}$ partition $\mathbb{R}^d$ into open polyhedral cones (cells), each with a fixed sign pattern $S(w) = \{i : w^T x_i \geq 0\}$. Each non-empty open cone has positive Gaussian measure.

On cell $C_S$ with pattern $S$, equation (2) gives:

$$\sum_{i \in S} c_i x_i = 0 \quad \text{for every $S$ with positive-measure cell}. \tag{$\star$}$$

**Step 4: Adjacent cell argument — the key lemma.**

**Lemma.** For each $k \in \{1, \dots, n\}$, there exist activation patterns $S$ and $S' = S \setminus \{k\}$ such that both cells $C_S$ and $C_{S'}$ have positive Gaussian measure.

*Proof.* Since $x_k \neq \pm x_j$ for all $j \neq k$, the hyperplane $\Pi_k = \{w : w^T x_k = 0\}$ is **distinct** from every other $\Pi_j$. The set $\Pi_k \setminus \bigcup_{j \neq k} \Pi_j$ is dense and open in $\Pi_k$ (finitely many proper subspaces removed from a hyperplane). Take any point $w^* \in \Pi_k \setminus \bigcup_{j \neq k} \Pi_j$. In a neighborhood of $w^*$:
- All signs $\text{sign}(w^T x_j)$ for $j \neq k$ are constant (since $w^* \notin \Pi_j$)
- The sign of $w^T x_k$ flips as we cross $\Pi_k$

So the two sides of $\Pi_k$ near $w^*$ give two non-empty open cones $C_S$ (where $k \in S$) and $C_{S'}$ (where $S' = S \setminus \{k\}$), both with positive Gaussian measure. $\square$

**Step 5: Derive $c_k = 0$ for each $k$.**

From ($\star$) applied to the adjacent patterns $S$ and $S' = S \setminus \{k\}$:

$$\sum_{i \in S} c_i x_i = 0 \quad \text{and} \quad \sum_{i \in S'} c_i x_i = 0.$$

Subtracting: $c_k x_k = 0$. Since $\|x_k\| = 1 \neq 0$, we get $c_k = 0$.

This holds for every $k$, so $c = 0$.

**Step 6: Conclusion.**

For every $c \neq 0$, $c^T H^\infty c > 0$. Therefore $H^\infty$ is positive definite: $\lambda_{\min}(H^\infty) > 0$.

**Step 7: Necessity of conditions.**

- If $x_i = x_j$ for some $i \neq j$: then rows/columns $i,j$ of $H^\infty$ are identical, so $c = e_i - e_j$ gives $c^T H^\infty c = 0$. PD fails.
- If $x_i = -x_j$: then $\Pi_i = \Pi_j$, the adjacency argument breaks down, and $H^\infty_{ij} = -1 \cdot P(\cdot) \leq 0$ creates potential kernel matrix degeneracy.

The condition $x_i \neq \pm x_j$ is tight. $\blacksquare$

**Q.E.D.**
