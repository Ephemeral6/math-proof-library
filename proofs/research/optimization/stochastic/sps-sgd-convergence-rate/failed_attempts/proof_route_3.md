# Route 3: Regret-Style Analysis via Online Convex Optimization Framework

## Proof

**Route**: Route 3 - Regret-Style Analysis via OGD Framework

**Step 1 (OGD distance identity).** For the SGD update $x_{k+1} = x_k - \gamma_k\nabla f_{i_k}(x_k)$:

$$\|x_{k+1}-x^*\|^2 = \|x_k-x^*\|^2 - 2\gamma_k\langle \nabla f_{i_k}(x_k), x_k-x^*\rangle + \gamma_k^2\|\nabla f_{i_k}(x_k)\|^2$$

**Step 2 (Convexity + interpolation).**

$$f_{i_k}(x_k) \leq \langle \nabla f_{i_k}(x_k), x_k - x^*\rangle$$

**Step 3 (Substitute SPS and simplify).**

$\gamma_k^2\|\nabla f_{i_k}(x_k)\|^2 = \frac{\gamma_k f_{i_k}(x_k)}{c}$

$$(2-1/c)\gamma_k f_{i_k}(x_k) \leq \|x_k-x^*\|^2 - \|x_{k+1}-x^*\|^2$$

Since $c \geq 1$, $2-1/c \geq 1$:

$$\gamma_k f_{i_k}(x_k) \leq \|x_k-x^*\|^2 - \|x_{k+1}-x^*\|^2 \qquad (\dagger)$$

**Step 4 (Lower bound on $\gamma_k$).**

$$\|\nabla f_{i_k}(x)\|^2 \leq 2Lf_{i_k}(x) \implies \gamma_k \geq \frac{1}{2cL}$$

**Step 5 (Per-step bound).**

$$\frac{f_{i_k}(x_k)}{2cL} \leq \|x_k-x^*\|^2 - \|x_{k+1}-x^*\|^2$$

**Step 6 (Telescope, expectation, Jensen).**

$$\mathbb{E}[f(\bar{x}_T)] \leq \frac{2cL\|x_0-x^*\|^2}{T}$$

**Tighter with full coefficient:**

$$\mathbb{E}[f(\bar{x}_T)] \leq \frac{2c^2 L\|x_0-x^*\|^2}{(2c-1)T}$$

## Route Failure Report (Partial)
- **Achieved**: $\frac{2c^2 L}{(2c-1)T}\|x_0 - x^*\|^2 \leq \frac{2cL}{T}\|x_0 - x^*\|^2$
- **Target**: $\frac{cL}{2T}\|x_0 - x^*\|^2$
- **Gap**: Factor of 4. The regret route requires lower-bounding $\gamma_k \geq 1/(2cL)$, introducing irrecoverable slack.
