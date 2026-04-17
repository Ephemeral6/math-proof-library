# Route 2: One-Step Progress via Squared Distance to Optimum

## Proof

**Route**: Route 2 - One-Step Progress via Squared Distance to Optimum

**Step 1: Expand the Lyapunov function.**

Track $\|x_k - x^*\|^2$. With SGD update $x_{k+1} = x_k - \gamma_k \nabla f_{i_k}(x_k)$:

$$\|x_{k+1} - x^*\|^2 = \|x_k - x^*\|^2 - 2\gamma_k \langle \nabla f_{i_k}(x_k), x_k - x^* \rangle + \gamma_k^2 \|\nabla f_{i_k}(x_k)\|^2. \tag{1}$$

**Step 2: Lower-bound the inner product using convexity and interpolation.**

Since $f_{i_k}$ is convex and $f_{i_k}(x^*) = 0$ (interpolation):

$$\langle \nabla f_{i_k}(x_k), x_k - x^* \rangle \geq f_{i_k}(x_k). \tag{2}$$

**Step 3: Substitute the SPS step-size into the quadratic term.**

$$\gamma_k^2 \|\nabla f_{i_k}(x_k)\|^2 = \gamma_k \cdot \frac{f_{i_k}(x_k)}{c}. \tag{3}$$

**Step 4: Combine to obtain one-step progress.**

Substituting (2) and (3) into (1):

$$\|x_{k+1} - x^*\|^2 \leq \|x_k - x^*\|^2 - \gamma_k f_{i_k}(x_k)\left(2 - \frac{1}{c}\right). \tag{4}$$

Since $c \geq 1$, $2 - 1/c \geq 1$:

$$\|x_{k+1} - x^*\|^2 \leq \|x_k - x^*\|^2 - \gamma_k f_{i_k}(x_k). \tag{5}$$

**Step 5: Lower-bound the step-size using L-smoothness.**

Since $f_{i_k}$ is convex, $L$-smooth, with $f_{i_k}(x^*) = 0$:

$$\|\nabla f_{i_k}(x_k)\|^2 \leq 2L \cdot f_{i_k}(x_k). \tag{6}$$

*Justification*: By $L$-smoothness, $f_{i_k}(x - \frac{1}{L}\nabla f_{i_k}(x)) \leq f_{i_k}(x) - \frac{1}{2L}\|\nabla f_{i_k}(x)\|^2$. Since $f_{i_k}(x^*) \leq f_{i_k}(y)$ for all $y$: $0 \leq f_{i_k}(x) - \frac{1}{2L}\|\nabla f_{i_k}(x)\|^2$.

Therefore: $\gamma_k \geq \frac{1}{2cL}. \tag{7}$

**Step 6: Extract per-step function value bound.**

From (5): $\gamma_k f_{i_k}(x_k) \leq \|x_k - x^*\|^2 - \|x_{k+1} - x^*\|^2$.

Using (7): $\frac{1}{2cL} f_{i_k}(x_k) \leq \|x_k - x^*\|^2 - \|x_{k+1} - x^*\|^2. \tag{8}$

**Step 7: Take expectations and telescope.**

Taking expectation using tower law ($\mathbb{E}_{i_k}[f_{i_k}(x_k)] = f(x_k)$) and summing:

$$\frac{1}{2cL} \sum_{k=0}^{T-1} \mathbb{E}[f(x_k)] \leq \|x_0 - x^*\|^2 - \mathbb{E}[\|x_T - x^*\|^2] \leq \|x_0 - x^*\|^2. \tag{10}$$

**Step 8: Apply Jensen's inequality and conclude.**

By convexity of $f$:

$$\mathbb{E}[f(\bar{x}_T)] \leq \frac{1}{T}\sum_{k=0}^{T-1} \mathbb{E}[f(x_k)] \leq \frac{2cL \cdot \|x_0 - x^*\|^2}{2T} = \frac{c \cdot L \cdot \|x_0 - x^*\|^2}{2T}$$

Wait — let me recheck: from (10), $\sum_{k=0}^{T-1} \mathbb{E}[f(x_k)] \leq 2cL\|x_0-x^*\|^2$, so $\frac{1}{T}\sum \leq \frac{2cL\|x_0-x^*\|^2}{T}$.

Hmm, the constant is $2cL/T$ not $cL/(2T)$.

Actually wait — re-reading the explorer output more carefully, at Step 8 the agent wrote: "Combining (10) and (11): $\mathbb{E}[f(\bar{x}_T)] \leq \frac{2cL \cdot \|x_0 - x^*\|^2}{2T} = \frac{c \cdot L \cdot \|x_0 - x^*\|^2}{2T}$"

This is wrong: from (10), $\frac{1}{2cL}\sum \leq \|x_0-x^*\|^2$, so $\sum \leq 2cL\|x_0-x^*\|^2$, and $\frac{1}{T}\sum \leq \frac{2cL}{T}\|x_0-x^*\|^2$. The agent wrote $2cL/(2T) = cL/(2T)$ which incorrectly divided by 2.

So actually all three routes got $2cL/T$, not $cL/(2T)$. Route 2 had an arithmetic error in the final step. The correct achievable bound is $2cL\|x_0-x^*\|^2/T$.

Let me save the proofs accurately and note this.
