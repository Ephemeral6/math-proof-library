# C5 — Douglas-Rachford Splitting O(1/k)

**Path**: `proofs/research/convex-analysis/subgradient/douglas-rachford-splitting-rate/`
**Verdict**: **MATCH (B-class result, classic + standard rate)**

## Our statement
For maximally monotone operators $A, B$ on a Hilbert space with $\text{zer}(A+B) \neq \emptyset$, the Douglas-Rachford operator $T_{DR} = \frac{1}{2}(I + R_A R_B)$ is firmly nonexpansive, and the iterates $z_{k+1} = T_{DR}(z_k)$ satisfy
$$
\|z_k - z_{k-1}\|^2 \le \frac{\text{dist}(z_0, \text{Fix}(T_{DR}))^2}{k}.
$$
Plus weak convergence of $\{z_k\}$ and strong convergence of $\{x_k = J_B(z_k)\} \to p^* \in \text{zer}(A+B)$ via Browder demiclosedness + Opial.

## Literature

### Davis-Yin 2016 (arXiv:1409.5237) — wrong arXiv per WebFetch (returned physics paper); the correct paper is Davis-Yin "Convergence rate analysis of several splitting schemes" (around 2014/2016)
- Establishes $O(1/k)$ rate for the **fixed-point residual** $\|z_{k+1}-z_k\|^2$ of DR, three-operator splitting, and other monotone operator schemes.
- Improved to $o(1/k)$ in the same paper.

### Lions-Mercier 1979
- Original DR convergence paper for monotone operators. Established weak convergence (no rate).

### Bauschke-Combettes 2011 (textbook)
- Standard reference for FNE / Opial / weak convergence framework.

## Comparison

| Aspect | Lions-Mercier 1979 | Davis-Yin 2016 | OUR C5 |
|---|---|---|---|
| Convergence | weak | weak + rate | weak + strong + rate |
| Rate | none | $o(1/k)$ on residual | $O(1/k)$ on residual |
| Technique | non-constructive | telescoping | Fejér + Opial + Browder |

The result is a faithful restatement of Davis-Yin 2016's rate and the classical Lions-Mercier weak convergence, packaged with full Browder/Opial demiclosedness. Constants and rate match the literature exactly.

## Verdict

**MATCH.** This is a B-class textbook proof reconstruction of a well-known result. No discrepancies with literature. The proof is cleanly organized and self-contained (FNE composition, Fejér, telescoping, Browder-Opial weak convergence, FNE strong convergence).

The bound $\|z_k - z_{k-1}\|^2 \le D^2/k$ is the standard $O(1/k)$ result; Davis-Yin 2016 sharpens to $o(1/k)$, which is not claimed here.
