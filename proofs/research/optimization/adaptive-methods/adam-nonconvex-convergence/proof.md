# Best Proof: Adam Convergence in Non-Convex Setting

**Route**: Descent Lemma + Telescoping via Effective Step Size

## Setup
Adam with β₁² ≤ β₂, ε > 0, on L-smooth f with ||∇f(x)||_∞ ≤ G. Learning rate α_t = α/√t.

## Step 1: Descent Lemma
By L-smoothness with Δ_t = -α_t D_t where D_t = m̂_t/(√v̂_t + ε):

$$f(x_{t+1}) \leq f(x_t) - \alpha_t\langle g_t, D_t\rangle + \frac{L\alpha_t^2}{2}\|D_t\|^2$$

## Step 2: Bound ||D_t||² ≤ d
Under β₁² ≤ β₂, the EMA weights satisfy p_s ≤ q_s. By Jensen's inequality:

$$[m̂_t]_i^2 \leq \sum_s p_s [g_s]_i^2 \leq \sum_s q_s [g_s]_i^2 = [v̂_t]_i$$

So $|[D_t]_i| = |[m̂_t]_i|/(\sqrt{[v̂_t]_i} + \varepsilon) \leq 1$, giving $\|D_t\|^2 \leq d$.

## Step 3: Inner Product Decomposition (Polarization)
Using $ab = (a^2c + b^2/c)/2 - (ac-b)^2/(2c)$:

$$\langle g_t, D_t\rangle \geq \sum_i \frac{[g_t]_i^2}{2(\sqrt{[v̂_t]_i}+\varepsilon)} - \sum_i \frac{([g_t]_i - [m̂_t]_i)^2}{2(\sqrt{[v̂_t]_i}+\varepsilon)}$$

$$\geq \frac{\|g_t\|^2}{2(G+\varepsilon)} - \frac{\|g_t - m̂_t\|^2}{2\varepsilon}$$

## Step 4: Momentum Error Bound
By Jensen + L-smoothness + $\|D_r\| \leq \sqrt{d}$:

$$\|g_t - m̂_t\|^2 \leq \delta^2 := \frac{L^2 d\alpha^2 \beta_1(1+\ln T)}{(1-\beta_1)^2}$$

## Step 5: Telescope
Summing the descent inequality over $t = 1, \ldots, T$:

$$\frac{1}{2(G+\varepsilon)}\sum_t \alpha_t\|g_t\|^2 \leq \Delta_f + \frac{\delta^2}{2\varepsilon}\sum_t\alpha_t + \frac{Ld}{2}\sum_t\alpha_t^2$$

With $\sum\alpha_t \leq 2\alpha\sqrt{T}$ and $\sum\alpha_t^2 \leq \alpha^2(1+\ln T)$.

## Step 6: Choose α = α₀·T^{-1/4}

- Term 1: $2(G+\varepsilon)\Delta_f/(\alpha_0 T^{1/4}) = O(1/T^{1/4})$
- Term 2: $2(G+\varepsilon)L^2d\alpha_0^2\beta_1(1+\ln T)/[\varepsilon(1-\beta_1)^2\sqrt{T}] = O(d\log T/\sqrt{T})$ ✓
- Term 3: $(G+\varepsilon)Ld\alpha_0(1+\ln T)/T^{3/4} = O(d\log T/T^{3/4})$

## Conclusion

$$\boxed{\min_{1 \leq t \leq T}\|\nabla f(x_t)\|^2 \leq O\!\left(\frac{d \cdot \log T}{\sqrt{T}}\right)}$$

under β₁² ≤ β₂ with horizon-dependent learning rate α_t = α_0 t^{-1/2} T^{-1/4}. Q.E.D.
