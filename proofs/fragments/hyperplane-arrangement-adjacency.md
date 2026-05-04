# Fragment: hyperplane-arrangement-adjacency

## Statement
Let $x_1, \ldots, x_n \in \mathbb{R}^d \setminus \{0\}$ with $x_i \ne \pm x_j$ for all $i \ne j$. Consider the hyperplanes $\Pi_i := \{w \in \mathbb{R}^d : w^\top x_i = 0\}$ and the open cells $C_S := \{w : \mathrm{sign}(w^\top x_i) = (1 \text{ if } i \in S, -1 \text{ otherwise})\}$ partitioning $\mathbb{R}^d$ (modulo measure zero).

Then for every $k \in \{1, \ldots, n\}$ there exist activation patterns $S$ and $S' = S \setminus \{k\}$ such that **both** cells $C_S$ and $C_{S'}$ have positive Gaussian (Lebesgue) measure.

Equivalently: for every neuron index $k$, one can flip just the $k$-th coordinate of the activation pattern while remaining in a positive-measure cell.

## Proof
Since $x_k \ne \pm x_j$ for all $j \ne k$, the hyperplane $\Pi_k$ is **distinct** from every other $\Pi_j$. The set $\Pi_k \setminus \bigcup_{j \ne k} \Pi_j$ is therefore the complement in $\Pi_k$ of finitely many proper subspaces, hence dense and open in $\Pi_k$. Pick any $w^* \in \Pi_k \setminus \bigcup_{j \ne k} \Pi_j$. In a neighborhood of $w^*$:
- All signs $\mathrm{sign}(w^\top x_j)$ for $j \ne k$ are constant (since $w^* \notin \Pi_j$ implies $w^\top x_j$ is bounded away from 0 nearby);
- The sign of $w^\top x_k$ flips as $w$ crosses $\Pi_k$.

So the two sides of $\Pi_k$ near $w^*$ give two non-empty open cones $C_S$ (with $k \in S$) and $C_{S'}$ (with $S' = S \setminus \{k\}$), both with positive Gaussian measure. $\square$

## Source
- `proofs/research/learning-theory/generalization/ntk-gram-matrix-positive-definiteness/proof.md` — Step 4 ("Adjacent cell argument — the key lemma").

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (key combinatorial step in NTK Gram matrix PD proof, Du et al. style)
- **Potential applications**:
  - Positive-definiteness of NTK / NNGP Gram matrices
  - Linear independence arguments for ReLU activations
  - Counting cells in hyperplane arrangements (Zaslavsky's formula)
  - Generic-position arguments for piecewise-linear function classes
  - Showing that ReLU networks "see" all activation patterns

## Tags
hyperplane-arrangement, NTK, ReLU, positive-definite, gram-matrix, activation-pattern
