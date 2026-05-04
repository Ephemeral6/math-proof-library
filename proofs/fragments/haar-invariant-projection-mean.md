# Fragment: haar-invariant-projection-mean

## Statement
Let $X \in \mathbb{R}^{n \times d}$ with $d > n$ be a random matrix whose distribution is right-rotation invariant (e.g., i.i.d. Gaussian entries). Let $P_X = X^\top (XX^\top)^{-1} X$ be the orthogonal projection onto the row space of $X$ (rank $n$). Then:
$$\mathbb{E}[I_d - P_X] \;=\; \tfrac{d-n}{d}\, I_d.$$

## Proof
For any orthogonal $Q \in O(d)$, $XQ$ has the same distribution as $X$ (right-rotation invariance). The projection transforms as $P_{XQ} = Q^\top P_X Q$. Therefore $\mathbb{E}[P_X] = Q^\top \mathbb{E}[P_X] Q$ for all $Q$, which forces $\mathbb{E}[P_X] = c I_d$ for some scalar $c$ (commutes with all rotations $\Rightarrow$ multiple of identity). Take traces: $cd = \mathbb{E}[\mathrm{tr}(P_X)] = \mathbb{E}[\mathrm{rank}(X)] = n$ (a.s.), so $c = n/d$ and $\mathbb{E}[I - P_X] = (1 - n/d) I_d$. $\square$

**Corollary** (overparameterized bias term in min-norm interpolation): for any signal $\beta^* \in \mathbb{R}^d$,
$$\mathbb{E}\,\|(I - P_X)\beta^*\|^2 = \beta^{*\top} \mathbb{E}[I - P_X]\beta^* = \tfrac{d-n}{d}\|\beta^*\|^2.$$

## Source
- `proofs/research/statistics/high-dimensional/double-descent-interpolation-threshold/proof.md` — Step 3 (bias term).

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (gives bias of min-norm interpolator in overparameterized regression)
- **Potential applications**:
  - Double descent / benign overfitting analyses
  - Random projection / sketching guarantees (Johnson-Lindenstrauss style)
  - Bias of min-norm OLS in overparameterized regression
  - Kernel regression generalization with random features
  - Any expectation involving uniformly random subspaces

## Tags
haar, rotation-invariance, projection, double-descent, min-norm, random-matrix
