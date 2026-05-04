# 8.7 — Finite-Sum Extension of OP-2

**Date:** 2026-04-26
**Status:** PASS (with caveats) — OP-2 LB transfers to finite-sum oracle modulo a Gaussian-mollification step.

## Verdict

OP-2's $\Omega(LD^2/T + \sigma D/\sqrt T)$ **transfers cleanly to the finite-sum oracle**, with $\sigma$ taken as the (uniform) per-sample variance bound, after a small mollification step to make the discrete oracle laws absolutely continuous.

**In the interpolation regime** ($\nabla f_i(x^\star) = 0$ for all $i$), the construction cannot simultaneously enforce interpolation and $\sigma > 0$ at the optimum. The variance term degrades, but the bias term $\Omega(LD^2/T)$ survives.

## Construction

Pick $n \ge 2$, choose $(\epsilon_i)_{i=1}^n$ with $\sum_i \epsilon_i = 0$, $\frac{1}{n}\sum_i \epsilon_i^2 = \sigma^2$. Define
$$f_i^{(s)}(x, y) := f_0(x) + \alpha_{s,i}\,y + w(y), \qquad \alpha_{s,i} := s\alpha + \epsilon_i,$$
where $\alpha = \sigma/(2\sqrt{2T})$ (or $\sigma/(3\sqrt T)$ for v4 sharpening).

**Properties:**
- Mean: $f^{(s)} = \frac{1}{n}\sum_i f_i^{(s)} = f_0 + s\alpha\,y + w(y)$ — exactly OP-2's hard instance.
- Variance at every point: $\sigma^2_\mathrm{FS}(x,y) = \frac{1}{n}\sum_i (\epsilon_i)^2 = \sigma^2$ — uniform across domain.
- Smoothness: each $f_i^{(s)}$ is $L$-smooth (additive linear shift preserves smoothness).

## Le Cam in finite-sum setting

The naive finite-sum oracle gives discrete laws with singular support; KL between $\mathbb{P}_+^T$ and $\mathbb{P}_-^T$ is technically $\infty$.

**Fix (Gaussian mollification).** Add small Gaussian noise $\zeta_t \sim \mathcal{N}(0, \delta^2)$ on the y-coord. With $\delta = \sigma$, we have absolutely continuous laws and (by KL convexity)
$$\mathrm{KL}(p_+ \| p_-) \leq \frac{(2\alpha)^2}{2\delta^2} = \frac{2\alpha^2}{\sigma^2} = \frac{1}{4T}.$$
Same as OP-2's bound. Total per-step variance becomes $2\sigma^2$ (mollification doubles), absorbing into a $\sqrt 2$ factor in $c_\mathrm{NY}$.

## Result

$$\mathbb{E}[f_{\beta,\eta}^{(T),\mathrm{FS}}(x_T) - f^{(T),\mathrm{FS},\star}_{\beta,\eta}] \geq c(\beta,\eta) \frac{LD^2}{T} + c_\mathrm{NY}^\mathrm{FS} \frac{\sigma D}{\sqrt T}, \qquad c_\mathrm{NY}^\mathrm{FS} = \Theta(c_\mathrm{NY}).$$

The $\Omega$-rate is identical to OP-2's; only constants degrade by a $\sqrt 2$ factor (absorbable).

## Interpolation caveat

At the optimum $x^\star_s = (0, y^\star_s)$:
$$\nabla f_i^{(s)}(x^\star_s) = (0,\ s\alpha + \epsilon_i + w'(y^\star_s)) = (0,\ \epsilon_i)$$
(using $s\alpha + w'(y^\star_s) = 0$ from optimality of the averaged $f^{(s)}$).

**Interpolation requires $\epsilon_i = 0$ for all $i$, which forces $\sigma = 0$.** So the construction cannot deliver a nontrivial $\sigma D/\sqrt T$ LB in the interpolation regime — consistent with the well-known fact that interpolation breaks the standard $\Omega(\sigma/\sqrt T)$ floor (Vaswani–Bach–Schmidt 2019).

The bias term $LD^2/T$ does survive in the interpolation regime.

## Comparison with SVRG / Katyusha

- SVRG / SAGA achieve $O(LD^2/T + \sigma D/\sqrt T)$.
- Katyusha (accelerated finite-sum) achieves $O(nLD^2/T^2)$.

Our finite-sum LB **rules out fixed-momentum SHB matching Katyusha's accelerated rate**, exactly mirroring OP-2's non-acceleration vs AC-SA. **Variance reduction does not rescue fixed-momentum SHB from non-acceleration.**

## Recommended additions to OP-2 §0.2

1. Add an "Oracle generality" clause noting the finite-sum oracle is a valid instantiation.
2. Add a remark to §2.1.3 with the Gaussian-mollified finite-sum realization.
3. Add to §0.6 (scope): "Not claimed under interpolation"; bias term survives but variance term does not.
