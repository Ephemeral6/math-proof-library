# Notes: Clipped SGD Heavy-Tail Convergence

## Proof technique

**Winning route:** Descent lemma + bias-variance decomposition + case analysis on $\|\nabla_t\|$ vs $\tau$.

The proof introduces the surrogate stationarity measure $\phi_t = \min(\|\nabla_t\|^2, \tau\|\nabla_t\|)$, bounds its average via telescoping, then recovers the full $\|\nabla_t\|^2$ bound through a separate telescoping argument for the "excess" term $\|\nabla_t\|(\|\nabla_t\|-\tau)_+$.

## Key steps

1. **Clipping bias decomposition:** $(\|g_t\|-\tau)_+ \le (\|\nabla_t\|-\tau)_+ + \|\xi_t\|$ via sub-additivity of $(\cdot)_+$, combined with Jensen bound $\mathbb{E}[\|\xi_t\|] \le \sigma$.

2. **Case analysis:** Small gradient ($\|\nabla_t\| \le \tau$) uses Young to absorb the $\sigma\|\nabla_t\|$ term. Large gradient ($\|\nabla_t\| > \tau$) uses $\tau \ge 2\sigma$ to get descent $\ge \frac{\eta\tau}{2}\|\nabla_t\|$.

3. **$\|\nabla_t\|^2$ recovery (the hardest step):** For Type B steps, $\|\nabla_t\| > \tau \ge 2\sigma > \sigma$ implies $\|\nabla_t\|^2 - \sigma\|\nabla_t\| > 0$. This makes the "excess" term $\eta\|\nabla_t\|(\|\nabla_t\|-\tau)_+$ directly bounded by the per-step function decrease plus $\frac{L\eta^2\tau^2}{2}$, yielding a telescopable sum.

## Audit result

All 6 numerical checks passed. End-to-end simulation with Pareto noise ($p = 1.5$) confirmed the $O(T^{-1/3})$ rate within 8% of theoretical prediction.

## Related results

- **$p = 2$ recovery:** For bounded variance, the bound reduces to $O((\Delta_f L + L\sigma^2)/\sqrt{T})$, matching classical non-convex SGD (Ghadimi & Lan, 2013).
- **Lower bound:** The rate $O(T^{-(1-1/p)})$ is known to be optimal for $p$-th moment noise (Zhang et al., ICML 2020).
- **Coordinate-wise clipping:** Variants with per-coordinate clipping achieve the same rate with better constants (Gorbunov et al., 2020).
- **Momentum extensions:** Clipped SGD with momentum under heavy tails achieves the same rate with potential practical speedup (Cutkosky & Mehta, ICML 2021).
- **Connection to Adam:** Adaptive methods like Adam achieve similar robustness to heavy tails through implicit gradient normalization (cf. Adam non-convex convergence proof in this library).
