# Direction 4 — Last-iterate in strongly convex regime

**Verdict: FEASIBLE but OUT OF SCOPE for closing the OP-2 v5 gap.** The strongly convex (SC) setting has well-established matching UBs/LBs in the literature; this would be a *supplementary* result, not an answer to Li Xiao's specific critique.

**Effort:** Low (1 week; mostly literature consolidation, not new analysis).

## Question

Does the last iterate of fixed-momentum SHB on $\mu$-strongly-convex $L$-smooth $f$ satisfy a UB matching OP-2's LB framework specialized to SC?

## Brief literature scan

The SC stochastic optimization picture is well-known:

| Result | Reference |
|---|---|
| Lower bound: $\Omega\bigl(\frac{\sigma^2}{\mu T}\bigr)$ for SC stochastic optimization | Nemirovski–Yudin 1983 (classical); Agarwal et al. 2012 |
| SGD with $\eta_t = c/t$ achieves $O\bigl(\frac{\sigma^2}{\mu T}\bigr)$ on last iterate | Bach–Moulines 2013 |
| SHB with time-varying schedule achieves $O\bigl(\frac{\sigma^2}{\mu T}\bigr)$ + accelerated linear bias term $O((1-\sqrt{\mu/L})^T)$ | Sebbouh–Gower–Defazio 2021 [arXiv:2006.07867](https://arxiv.org/abs/2006.07867) |
| SHB at fixed $(\beta, \eta)$: same noise floor obstruction as non-SC, scaled differently | Direct Lyapunov on $f(x) = (\mu/2)x^2$ |

## Analysis at fixed $(\beta, \eta)$ in SC

For $f(x) = (\mu/2) x^2$ (pure SC quadratic), the Lyapunov analysis from `gap2_proof.md` Theorem A.1 generalizes by replacing $L$ with $\mu$ in the recursion. The closed-form noise floor becomes
$$
\mathrm{Var}_\infty[x]\big|_{\text{SC}} \;=\; \frac{\eta\,\sigma^2\,(1+\beta)}{\mu\,(1-\beta)(2(1+\beta) - \eta\mu)}.
$$
Hence $\mathbb E[f(x_T) - f^\star] \to (\mu/2)\mathrm{Var}_\infty = \Theta\bigl(\frac{\sigma^2 \eta}{1-\beta}\bigr) > 0$, **same constant noise-floor obstruction** as the non-SC setting. So fixed-$(\beta, \eta)$ doesn't escape the floor in SC either.

For the bias term: with $f$ strongly convex, the deterministic part of SHB has linear convergence at rate $\rho = \sqrt\beta$ (under-damped) or worse, depending on the eigenstructure. Specifically, the Floquet rate at a smooth strict-minimum is $|\lambda_{\max}(M_\mu)| = \sqrt\beta$ if underdamped — so $f(x_T) - f^\star = O(\beta^T)$ for the deterministic case, accelerated relative to $1/T$.

## Why this doesn't close OP-2's gap

OP-2 v5 is explicitly about **convex non-SC** (Goujaud-class instance with $\mu = \Theta(\kappa L)$ but with $\kappa = \mu/L$ being a small constant — the function class allows $\mu = 0$ but the lower-bound construction uses positive $\mu$ to enable cycling). Li Xiao's review concerns matching UB to LB in this non-SC class.

A SC-class result would be:
- **Lower bound (SC)**: $\Omega(\sigma^2 / (\mu T))$ — different rate, different functional class.
- **Upper bound (SC, time-varying $\eta_t$)**: $O(\sigma^2/(\mu T))$ — matches.
- **Upper bound (SC, fixed $\eta$)**: same noise-floor obstruction $\Omega(1)$.

So even in SC, fixed $(\beta, \eta)$ has the noise floor; only time-varying schedule recovers $O(1/T)$. The picture matches non-SC qualitatively.

## What it could add to OP-2

If OP-2 v6 wants to claim a unified tightness picture:
- Non-SC convex (main result): LB $\Omega(LD^2/T + \sigma D/\sqrt T)$, no fixed-$(\beta,\eta)$ matching UB; matching with $\eta_t \to 0$ (Direction 2).
- SC convex (extension): LB $\Omega(\sigma^2/(\mu T))$, no fixed-$(\beta,\eta)$ matching UB; matching with Sebbouh-Gower-Defazio-style time-varying schedule.

This would be a "for all $\mu \ge 0$" statement, which is more general than the non-SC focus.

## Recommendation

**LOW PRIORITY for closing the v5 gap.** The SC result is well-known and doesn't directly answer Li Xiao's critique (which is about non-SC). However, it could be a useful **appendix** in OP-2 v6 demonstrating that the noise-floor obstruction is robust across $\mu \in [0, L]$, not specific to non-SC.

If pursued: 1 week for literature consolidation + 1-page proof; goes in OP-2 v6 §6 (extensions / open problems) as "the same obstruction extends to the SC setting".
