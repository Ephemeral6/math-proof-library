# Proof: Denoising Score Matching Equivalence

## Setup
$q_\sigma(x) = \int p_{\text{data}}(y)\mathcal{N}(x;y,\sigma^2I)dy$, $\nabla_x\log p(x|y) = -(x-y)/\sigma^2 = -\varepsilon/\sigma$.

## Step 1: Expand $J_{\text{ESM}}$

$$J_{\text{ESM}} = \underbrace{\tfrac{1}{2}\mathbb{E}_{q_\sigma}[\|s_\theta\|^2]}_{A(\theta)} - \underbrace{\mathbb{E}_{q_\sigma}[\langle s_\theta, \nabla\log q_\sigma\rangle]}_{B(\theta)} + \underbrace{\tfrac{1}{2}\mathbb{E}_{q_\sigma}[\|\nabla\log q_\sigma\|^2]}_{C_1}$$

## Step 2: Expand $J_{\text{DSM}}$

$$J_{\text{DSM}} = \underbrace{\tfrac{1}{2}\mathbb{E}_{q_\sigma}[\|s_\theta\|^2]}_{A(\theta)} + \underbrace{\mathbb{E}_{p(y)\mathcal{N}(\varepsilon)}[\langle s_\theta(y+\sigma\varepsilon), \varepsilon/\sigma\rangle]}_{D(\theta)} + \underbrace{d/(2\sigma^2)}_{C_2}$$

## Step 3: Key identity $B(\theta) = -D(\theta)$

**Regularity justification (Leibniz/DCT).** The kernel $p(x|y) = \mathcal{N}(x;y,\sigma^2 I)$ satisfies $|\nabla_x p(x|y)| = \frac{\|x-y\|}{\sigma^2}p(x|y)$, which is integrable against $p_{\text{data}}(y)$ for every $x$ since $\int p_{\text{data}}(y)\frac{\|x-y\|}{\sigma^2}p(x|y)\,dy \leq \frac{1}{\sigma^2}\bigl(\|x\| + \mathbb{E}_{p(y|x)}[\|y\|]\bigr)q_\sigma(x) < \infty$. Moreover, $q_\sigma(x) = \int p_{\text{data}}(y)p(x|y)\,dy > 0$ for all $x$ (strict positivity of the Gaussian convolution). Since the integrand $p_{\text{data}}(y)\nabla_x p(x|y)$ is dominated by the integrable function $p_{\text{data}}(y)\cdot\frac{\|x-y\|+1}{\sigma^2}p(x|y)$ uniformly in a neighborhood of each $x$, the dominated convergence theorem justifies exchanging $\nabla_x$ and $\int$:

$$\nabla_x q_\sigma(x) = \int p_{\text{data}}(y)\,\nabla_x p(x|y)\,dy.$$

Dividing both sides by $q_\sigma(x) > 0$ yields the **score-of-a-mixture identity**:

$$\nabla_x\log q_\sigma(x) = \mathbb{E}_{p(y|x)}[\nabla_x\log p(x|y)]$$

Therefore:

$$B(\theta) = \mathbb{E}_{p(y)p(x|y)}[\langle s_\theta(x), \nabla_x\log p(x|y)\rangle] = \mathbb{E}_{p(y)\mathcal{N}(\varepsilon)}[\langle s_\theta(y+\sigma\varepsilon), -\varepsilon/\sigma\rangle] = -D(\theta)$$

## Step 4: Conclude

$$J_{\text{ESM}} - J_{\text{DSM}} = (A + D + C_1) - (A + D + C_2) = C_1 - C_2$$

$$\boxed{J_{\text{ESM}}(\theta) = J_{\text{DSM}}(\theta) + C}, \quad C = \tfrac{1}{2}\mathbb{E}_{q_\sigma}[\|\nabla\log q_\sigma\|^2] - \tfrac{d}{2\sigma^2}$$

$C$ is independent of $\theta$. **Q.E.D.**
