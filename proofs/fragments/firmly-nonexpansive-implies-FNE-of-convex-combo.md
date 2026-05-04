# Fragment: firmly-nonexpansive-implies-FNE-of-convex-combo

## Statement
Let $S: \mathcal{H} \to \mathcal{H}$ be **nonexpansive** ($\|Su - Sv\| \le \|u - v\|$). Then $T := \tfrac{1}{2}(\mathrm{Id} + S)$ is **firmly nonexpansive (FNE)**:
$$\|Tu - Tv\|^2 + \|(\mathrm{Id} - T)u - (\mathrm{Id} - T)v\|^2 \;\le\; \|u - v\|^2.$$

In particular, this delivers the **Fejér residual identity** for any FNE map $T$ with fixed point $z^*$:
$$\|T(z) - z^*\|^2 + \|T(z) - z\|^2 \;\le\; \|z - z^*\|^2.$$

## Proof
Set $d := u - v$ and $\delta := Su - Sv$. Then $Tu - Tv = (d + \delta)/2$ and $(\mathrm{Id}-T)u - (\mathrm{Id}-T)v = (d - \delta)/2$. By the parallelogram law:
$$\|Tu - Tv\|^2 + \|(\mathrm{Id}-T)u-(\mathrm{Id}-T)v\|^2 = \tfrac{\|d+\delta\|^2 + \|d-\delta\|^2}{4} = \tfrac{2\|d\|^2 + 2\|\delta\|^2}{4} = \tfrac{\|d\|^2 + \|\delta\|^2}{2}.$$
Since $S$ is nonexpansive, $\|\delta\| \le \|d\|$, so this is $\le \|d\|^2 = \|u-v\|^2$. $\square$

For the Fejér residual: apply FNE with $u = z$, $v = z^*$, using $T(z^*) = z^*$ to identify the second term as $\|T(z) - z\|^2$.

## Source
- `proofs/research/convex-analysis/subgradient/douglas-rachford-splitting-rate/proof.md` — Step 2b.

## Status
- **Correctness**: VERIFIED
- **Used in final proof**: YES (key to Douglas-Rachford $O(1/k)$ rate)
- **Potential applications**:
  - Douglas-Rachford, ADMM, Chambolle-Pock convergence rates
  - Krasnoselskii-Mann iteration analysis
  - Resolvent splitting methods (forward-backward, three-operator)
  - Any time you average a nonexpansive map with identity to get convergence
  - Proving sublinear rates from monotone-residual + telescoping

## Tags
firmly-nonexpansive, FNE, fejer, splitting, douglas-rachford, parallelogram
