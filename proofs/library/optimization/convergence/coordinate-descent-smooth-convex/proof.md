# Randomized Coordinate Descent Convergence Rate

## Theorem

Let $f:\mathbb{R}^n \to \mathbb{R}$ be convex with coordinate-wise separable smoothness:
$$f(x + h) \leq f(x) + \langle \nabla f(x), h \rangle + \frac{1}{2}\sum_{i=1}^n L_i h_i^2$$

Randomized coordinate descent with uniform selection and step $1/L_i$ satisfies:

$$\mathbb{E}[f(x_T) - f^*] \leq \frac{n\|x_0 - x^*\|_L^2}{T + n}$$

where $\|x\|_L^2 = \sum_{i=1}^n L_i x_i^2$.

## Proof

**Notation**: $\delta_t = f(x_t) - f^*$, $S_t = \sum_i (\nabla_i f(x_t))^2 / L_i$.

**Step 1 (Coordinate descent lemma).** By separable smoothness with $h = te_i$, optimizing $t = -\nabla_i f(x)/L_i$:

$$f(x - \frac{\nabla_i f(x)}{L_i}e_i) \leq f(x) - \frac{(\nabla_i f(x))^2}{2L_i}$$

**Step 2 (Expected descent).** Over $i_t \sim \text{Uniform}\{1,\ldots,n\}$:

$$\mathbb{E}[f(x_{t+1}) | x_t] \leq f(x_t) - \frac{S_t}{2n}$$

**Step 3 (Weighted distance evolution).** Only coordinate $i_t$ changes:

$$\mathbb{E}[\|x_{t+1} - x^*\|_L^2 | x_t] = \|x_t - x^*\|_L^2 - \frac{2}{n}\langle \nabla f(x_t), x_t - x^*\rangle + \frac{S_t}{n}$$

*Derivation*: The $L_{i_t}$-weighted squared change in coordinate $i_t$ is:
$$L_{i_t}\left[-\frac{2\nabla_{i_t}f}{L_{i_t}}(x_{t,i_t}-x_{i_t}^*) + \frac{(\nabla_{i_t}f)^2}{L_{i_t}^2}\right] = -2\nabla_{i_t}f(x_{t,i_t}-x_{i_t}^*) + \frac{(\nabla_{i_t}f)^2}{L_{i_t}}$$

Taking $\mathbb{E}_{i_t}$ with probability $1/n$ each gives the formula.

**Step 4 (Lyapunov function).** Define:

$$\Phi_t = (t+n)\,\delta_t + \frac{n}{2}\|x_t - x^*\|_L^2$$

**Claim**: $\mathbb{E}[\Phi_{t+1}|x_t] \leq \Phi_t$ for all $t \geq 0$.

*Proof of claim*: Using Steps 2-3 and convexity ($\langle \nabla f(x_t), x_t-x^*\rangle \geq \delta_t$):

$$\mathbb{E}[\Phi_{t+1}|x_t] \leq (t+n+1)(\delta_t - \frac{S_t}{2n}) + \frac{n}{2}(\|x_t-x^*\|_L^2 - \frac{2\delta_t}{n} + \frac{S_t}{n})$$

$$= (t+n)\delta_t + \underbrace{[\delta_t - \langle \nabla f, x_t-x^*\rangle]}_{\leq\,0} + \frac{n}{2}\|x_t-x^*\|_L^2 - \underbrace{\frac{t+1}{2n}S_t}_{\geq\,0} \leq \Phi_t$$

The $S_t$ coefficient: $-\frac{t+n+1}{2n} + \frac{1}{2} = -\frac{t+1}{2n} \leq 0$ for $t \geq 0$. $\square$

**Step 5 (Convergence bound).** Iterating Step 4:

$$\mathbb{E}[\Phi_T] \leq \Phi_0 = n\,\delta_0 + \frac{n}{2}\|x_0-x^*\|_L^2$$

Since $\Phi_T \geq (T+n)\,\mathbb{E}[\delta_T]$:

$$\mathbb{E}[\delta_T] \leq \frac{n\,\delta_0 + \frac{n}{2}\|x_0-x^*\|_L^2}{T+n}$$

By separable smoothness at $x^*$ (where $\nabla f(x^*)=0$): $\delta_0 = f(x_0)-f^* \leq \frac{1}{2}\|x_0-x^*\|_L^2$.

$$\boxed{\mathbb{E}[f(x_T)-f^*] \leq \frac{n\|x_0-x^*\|_L^2}{T+n}}$$

**Step 6 (Euclidean form).** Since $(x_{0,i}-x_i^*)^2 \leq \|x_0-x^*\|^2$ for each $i$:

$$\|x_0-x^*\|_L^2 \leq \left(\sum_i L_i\right)\|x_0-x^*\|^2 = n\bar{L}\|x_0-x^*\|^2$$

Therefore: $\mathbb{E}[f(x_T)-f^*] \leq \frac{n^2\bar{L}\|x_0-x^*\|^2}{T+n}$, giving rate $O(n\bar{L}\|x_0-x^*\|_L^2/\varepsilon)$ or $O(n^2\bar{L}\|x_0-x^*\|^2/\varepsilon)$ in Euclidean norm. $\blacksquare$

## Remarks

1. **Tightness**: The weighted-norm bound is tight for diagonal quadratics $f(x) = \frac{1}{2}\sum L_i x_i^2$.

2. **Equal smoothness**: When all $L_i = L$, the bound simplifies to $\frac{nL\|x_0-x^*\|^2}{T+n}$, matching the $O(n\bar{L}/\varepsilon)$ rate exactly.

3. **Importance sampling**: Choosing $p_i = L_i/(n\bar{L})$ yields $\frac{2n\bar{L}\|x_0-x^*\|^2}{T+4}$, eliminating the extra factor of $n$ in the Euclidean norm conversion.

4. **Comparison with full GD**: Full gradient descent with step $1/L_{\max}$ gives $O(L_{\max}\|x_0-x^*\|^2/\varepsilon)$ iterations, each costing $n$ gradient evaluations. Total: $O(nL_{\max}/\varepsilon)$. Coordinate descent uses $O(n\bar{L}/\varepsilon)$ evaluations with $\bar{L} \leq L_{\max}$, giving an advantage when Lipschitz constants are heterogeneous.
