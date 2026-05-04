# Fragment: opial-weak-convergence

## Statement
Let $\mathcal{H}$ be a Hilbert space, $C \subseteq \mathcal{H}$ nonempty, and $\{z_k\} \subset \mathcal{H}$ a sequence such that:
1. $\lim_{k\to\infty}\|z_k - z^*\|$ exists for every $z^* \in C$ (Fejér monotonicity-type condition);
2. Every weak cluster point of $\{z_k\}$ belongs to $C$.

Then $z_k \rightharpoonup \bar{z}$ for some $\bar{z} \in C$.

**Demiclosedness principle (Browder).** Let $T: \mathcal{H} \to \mathcal{H}$ be nonexpansive. If $w_n \rightharpoonup w$ and $(I - T)w_n \to 0$ strongly, then $w \in \mathrm{Fix}(T)$.

## Proof
For Opial's theorem: by condition 1, $\{z_k\}$ is bounded, so it has weak cluster points (Banach-Alaoglu in reflexive spaces). Suppose $\bar{z}, \hat{z}$ are two weak cluster points (both in $C$ by condition 2) with $\bar{z} \ne \hat{z}$. Apply Opial's property (in any Hilbert space, $\liminf_n \|w_n - w\| < \liminf_n \|w_n - y\|$ for $w_n \rightharpoonup w$, $y \ne w$) along the respective subsequences:
$$\lim_k\|z_k - \bar{z}\| < \lim_k\|z_k - \hat{z}\| < \lim_k\|z_k - \bar{z}\|,$$
contradiction. So the weak cluster point is unique. $\square$

For demiclosedness: if $Tw \ne w$, the Opial property with $y = Tw$ and triangle-bounding $\|w_n - Tw\| \le \|w_n - Tw_n\| + \|Tw_n - Tw\|$ (using nonexpansiveness on the second term and $\|w_n - Tw_n\| \to 0$) gives a contradiction. $\square$

## Source
- `proofs/research/convex-analysis/subgradient/douglas-rachford-splitting-rate/proof.md` — Steps 5b and 5c.

## Status
- **Correctness**: VERIFIED (standard, classical results made self-contained)
- **Used in final proof**: YES (used for weak convergence of DR iterates)
- **Potential applications**:
  - Convergence of Krasnoselskii-Mann, Douglas-Rachford, ADMM in infinite dimensions
  - Weak convergence of forward-backward splitting iterates
  - Proximal point method convergence
  - Any FNE/nonexpansive map in Hilbert space
  - Useful template: Fejér monotonicity + asymptotic regularity + demiclosedness ⇒ weak convergence

## Tags
opial, demiclosedness, weak-convergence, nonexpansive, fejer, hilbert
