# D2 — SHB with Polyak Step-Size

**Date:** 2026-04-26
**Status:** OPEN — neither (a) nor (b) of the original question can be settled with current tools

## Verdict

**Polyak-step SHB does NOT inherit OP-2's $\Omega(LD^2/T)$ lower bound on $\mathcal{F}$.** The cycling identity is broken because the Polyak step computed on the cycling orbit $\eta_*$ lies far outside $\mathcal{F}$. **However**, Polyak-SHB also does NOT provably accelerate to $O(LD^2/T^2)$: the literature (Loizou et al. 2021; Schaipp et al. 2024 = arXiv:2406.04142) only proves $O(1/T)$ to a neighbourhood or $O(1/\sqrt T)$ to exact in non-interpolation — no acceleration is known.

## Sub-question 1 — Polyak step on the cycle (closed form)

On the cycling orbit $x_t = \lambda e_t$ with $\lambda = D/\sqrt 2$, the cycling identity (GRAD-f0) gives
$$\eta\,\nabla f_0(\lambda e_t) = \lambda\bigl[(1+\beta)e_t - e_{t+1} - \beta e_{t-1}\bigr],$$

so $\|\nabla f_0(\lambda e_t)\|^2 = \frac{\lambda^2}{\eta^2}\|(1+\beta)e_t - e_{t+1} - \beta e_{t-1}\|^2$, and $f_0(\lambda e_t)$ is rotation-invariant by Goujaud structure.

Therefore Polyak step on the cycle IS constant:
$$\eta_*(\beta,\eta;K) = \frac{f_0(\lambda e_t)}{\|\nabla f_0(\lambda e_t)\|^2}.$$

| $(\beta, \eta)$ used to set up cycle | $\kappa$ | $f_0(\lambda e_0)$ | $\|\nabla f_0\|^2$ | $\eta_* = f_0/\|\nabla\|^2$ | $L\eta_*$ vs $\gamma_\text{crit}(\beta)$ | $(\beta, \eta_*) \in \mathcal F_{K=3}$? |
|---|---|---|---|---|---|---|
| $(0.5, 3.0)$ | 0.250 | 0.2222 | 0.2917 | **0.7619** | 0.762 vs 2.625 | **NO** |
| $(0.5, 2.8)$ | 0.208 | 0.2303 | 0.3348 | **0.6877** | 0.688 vs 2.625 | **NO** |
| $(0.7, 2.9)$ | 0.336 | 0.2415 | 0.3906 | **0.6182** | 0.618 vs 2.738 | **NO** |
| $(0.9, 3.0)$ | 0.450 | 0.2485 | 0.4517 | **0.5502** | 0.550 vs 2.904 | **NO** |
| $(0.9, 3.5)$ | 0.398 | 0.2354 | 0.3318 | **0.7095** | 0.710 vs 2.904 | **NO** |

In every case $L\eta_* < \gamma_\text{crit}(\beta)$ — by a factor of 3 to 5. **The Polyak step lies entirely outside the cycling-feasibility region $\mathcal F_{K=3}$**.

## Sub-question 2 — Off-cycle simulation

Polyak-SHB with cycling-init on $f_0$ (rescaled Goujaud, $L=D=1$, $K=3$):

| $(\beta, \eta_\text{init})$ | $\|x_{10}\|$ | $\|x_{50}\|$ | $\|x_{100}\|$ | $f_0(x_{100})$ |
|---|---|---|---|---|
| $(0.5, 3.0)$ | $3.86\times 10^{-2}$ | $2.66\times 10^{-8}$ | $9.50\times 10^{-16}$ | $1.5\times 10^{-31}$ |
| $(0.9, 3.0)$ | $9.07\times 10^{-1}$ | $7.60\times 10^{-2}$ | $2.88\times 10^{-3}$ | $4.0\times 10^{-6}$ |
| $(0.9, 3.5)$ | $8.92\times 10^{-1}$ | $9.82\times 10^{-2}$ | $4.31\times 10^{-3}$ | $9.3\times 10^{-6}$ |

Cycling **destroyed** at iteration 1: the Polyak step at $t=1$ is $\approx 0.55$–$0.76$ (much less than the cycle-inducing $\eta=3$). After a transient, geometric decay much faster than $O(1/T)$.

## Sub-question 3 — Literature

| Paper | Setting | Rate proved | Acceleration? |
|---|---|---|---|
| Loizou et al. 2021 (arXiv:2002.10542) | SGD-SPS, smooth convex, no momentum | $O(1/T)$ to nbhd (interp.); $O(1/\sqrt T)$ general | No |
| Berrada et al. 2020 (ALI-G) | SHB-Polyak with momentum, interpolation | empirical only | — |
| **Schaipp et al. 2024** (arXiv:2406.04142, ICLR 2025) — canonical SHB-Polyak | SHB-Polyak, smooth convex, non-interp. | MomSPSmax: $O(1/T + \sigma^2)$ to nbhd; MomDecSPS: $O(1/\sqrt T)$; MomAdaSPS: $O(1/T + \sigma/\sqrt T)$ | **Explicitly NO $O(1/T^2)$** |
| Wang–Johansson 2023 (arXiv:2305.12939) | "Generalized Polyak step" with momentum | $O(1/T)$ class | No |

**Key takeaway:** No paper proves $O(LD^2/T^2)$ for SHB-Polyak in the smooth convex non-SC setting. State of the art is $O(1/T)$ bias.

## Sub-question 4 — Well-definedness on flat region

$w'(y) = 0$ for $|y| \leq R$, so $\partial_y f^{(s)} = \alpha_s$, a small constant. At $y_0 = 0$:
$$\eta_t^\text{(y)}\big|_{y=0} \approx \frac{\alpha D/\sqrt 2}{\alpha^2} = \frac{D}{\alpha\sqrt 2} = \Theta(\sqrt T \cdot D/\sigma).$$
**Polyak step on flat region scales like $\sqrt T$.** The first step jumps directly across the flat region into the wall portion — "feature, not bug" in idealised oracle. Realistic version (with capped $\eta_\text{max}$) is more conservative.

## Sub-question 5 — Conclusion

- **(a) — does OP-2's $\Omega(LD^2/T)$ inherit?** **NO.** The cycling Polyak step $\eta_*$ falls strictly outside $\mathcal F$. Cycle broken at iteration 1.
- **(b) — does Polyak SHB achieve $O(LD^2/T^2)$?** **NO known result.** Literature ceiling is $O(1/T)$.

**The honest answer:** OP-2's lower bound is fundamentally tied to fixed $(\beta,\eta)$. Polyak step-size sidesteps OP-2 by self-adapting away from $\mathcal F$. Whether SHB-Polyak truly accelerates on smooth convex non-SC functions is **OPEN** — no upper bound stronger than $O(1/T)$ is proved, no lower bound forbidding $O(1/T^2)$ is known. Constructing a hard instance for SHB-Polyak would need a fundamentally different mechanism than Goujaud cycling — one that survives step-size adaptation.

## Sources

- [Loizou et al. 2021](https://arxiv.org/abs/2002.10542)
- [Schaipp et al. 2024](https://arxiv.org/abs/2406.04142) (ICLR 2025)
- [Wang–Johansson 2023](https://arxiv.org/pdf/2305.12939)
