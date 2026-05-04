# Fragment: monotone-residual-implies-O-1-over-k-rate

## Statement
Let $T: \mathcal{H} \to \mathcal{H}$ be a firmly-nonexpansive (FNE) map on a Hilbert space, with $\mathrm{Fix}(T) \neq \emptyset$. Iterate $z_{k+1} := T(z_k)$. Then:

1. **Fejér residual identity** (FNE bound): $\|z_{k+1} - z^*\|^2 + \|z_{k+1} - z_k\|^2 \le \|z_k - z^*\|^2$ for any $z^* \in \mathrm{Fix}(T)$.

2. **Telescoping summability**: $\sum_{k=0}^\infty \|z_{k+1} - z_k\|^2 \le D^2 := \mathrm{dist}(z_0, \mathrm{Fix}(T))^2$.

3. **Monotone residuals**: $\|z_{k+1} - z_k\| \le \|z_k - z_{k-1}\|$ (since $T$ is nonexpansive).

4. **$O(1/k)$ rate**: $\|z_k - z_{k-1}\|^2 \le D^2 / k$.

This is the canonical "FNE iteration $\Rightarrow$ $O(1/k)$ residual" template.

## Proof
**Residual identity (1)**: Apply FNE definition with $u = z_k$, $v = z^*$, using $T(z^*) = z^*$:
$$\|T(z_k) - z^*\|^2 + \|(I-T)(z_k) - 0\|^2 \le \|z_k - z^*\|^2.$$

**Telescoping (2)**: From (1), $\|z_{k+1} - z_k\|^2 \le \|z_k - z^*\|^2 - \|z_{k+1} - z^*\|^2$. Sum from $k=0$ to $K-1$ to telescope; take infimum over $z^* \in \mathrm{Fix}(T)$.

**Monotone residuals (3)**: $\|z_{k+1} - z_k\| = \|T(z_k) - T(z_{k-1})\| \le \|z_k - z_{k-1}\|$ (FNE implies nonexpansive).

**$O(1/k)$ rate (4)**: From (3), $\|z_k - z_{k-1}\|^2 \le \|z_j - z_{j-1}\|^2$ for $j \le k$. Hence
$$k \cdot \|z_k - z_{k-1}\|^2 \le \sum_{j=1}^k \|z_j - z_{j-1}\|^2 \le D^2. \qquad \square$$

## Source
- `proofs/research/convex-analysis/subgradient/douglas-rachford-splitting-rate/proof.md` — Step 4 (Fejér + telescope + monotonicity).

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (delivers $O(1/k)$ rate for Douglas-Rachford)
- **Potential applications**:
  - Convergence rates for ALL averaged-iteration / FNE schemes
    (Krasnoselskii-Mann, Douglas-Rachford, ADMM, Chambolle-Pock, forward-backward)
  - Best-iterate / "monotone-by-some-criterion" $O(1/k)$ proofs
  - Generic template: FNE + Fejér + telescope + monotone residuals → $O(1/k)$
  - Easily generalized to $\alpha$-averaged maps with constants depending on $\alpha$

## Tags
fejer, FNE, monotone-residual, O-1-over-k, splitting, krasnoselskii-mann
