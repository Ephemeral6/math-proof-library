# B5 — Momentum SGD interpolation contraction

**Verdict**: CONFIRMED-WEAKER

**Source**: Vaswani et al. 2019 (1810.07288); Liu-Belkin 2020 (2003.00307, "Loss landscapes and optimization in over-parameterized non-linear systems and neural networks"). [ARXIV-UNREACHABLE detailed theorems; from training-data.]

## OUR statement
Setting: convex $L$-smooth $f_i$, $\mu$-SC $f$, interpolation. Polyak momentum, $\gamma=1/(4L)$, $\beta=1/(8\kappa)$. Lyapunov $\Phi_t = \|e_t\|^2 + \gamma^2\|v_t\|^2$:
$$\mathbb{E}[\Phi_{t+1}] \le (1 - 1/(4\kappa) + 1/(32\kappa^2))\Phi_t,$$
giving $\mathbb{E}\|x_t-x^*\|^2 \le (1-1/(4\kappa)+\cdots)^t \|x_0-x^*\|^2$.

## Paper statement
Vaswani 2019 Thm: under SGC, momentum SGD achieves rate $1-c/\kappa$ for vanilla regime, $1-c/\sqrt\kappa$ for accelerated regime when $\gamma$ and $\beta$ are tuned with momentum closer to $((\sqrt\kappa-1)/(\sqrt\kappa+1))^2$. Liu-Belkin Thm 3 (PL* condition): SGD attains $1-O(\mu/L)$ on overparameterized models.

## Comparison
- Same setup, same algorithm.
- Step $\gamma=1/(4L)$ matches Liu-Belkin range $\gamma \le 1/L$.
- Momentum $\beta=1/(8\kappa)$ — moderate, gives rate $1-1/(4\kappa)$ same as vanilla SGD (no acceleration).
- Variance handled via "split co-coercivity" with $\alpha=1/2$ — this is the core Vaswani trick (called "automatic variance reduction" in their paper).
- Rate $1-1/(4\kappa) = 1 - O(1/\kappa)$ matches Liu-Belkin and the vanilla-momentum branch of Vaswani.

## Verdict
**CONFIRMED-WEAKER** for the constant: same rate $1-O(1/\kappa)$ as published Vaswani vanilla/Liu-Belkin, but the explicit constant $1/4$ in front of $1/\kappa$ may be looser than Vaswani's tightest. No acceleration claimed; explicitly noted in proof Step 3 ("not an accelerated rate"). Technique (split co-coercivity Lyapunov) is the published Vaswani 2019 mechanism.
