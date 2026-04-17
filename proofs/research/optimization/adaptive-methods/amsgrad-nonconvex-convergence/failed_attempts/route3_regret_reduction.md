# Proof Route 3: Regret-to-Convergence Reduction

**Route**: Online Regret Bound + Reduction to Non-Convex Convergence

## Step 1: AMSGrad Regret Bound (Convex Setting)

First, we establish the regret bound from Reddi et al. (2018) Theorem 4. For convex functions $f_1,...,f_T$ on a domain $\mathcal{X}$ with diameter $D$, AMSGrad achieves:

$$\text{Regret}_T = \sum_{t=1}^T [f_t(x_t) - f_t(x^*)] \leq \sum_{i=1}^d \frac{D^2\sqrt{T[\hat{v}_T]_i}}{2\alpha(1-\beta_1)} + \frac{\alpha}{(1-\beta_1)\epsilon}\sum_{t=1}^T \sum_{i=1}^d \frac{[g_t]_i^2}{\sqrt{[\hat{v}_t]_i}}$$

Using $[\hat{v}_T]_i \leq G^2$ and the key lemma $\sum_t a_t/\sqrt{S_t} \leq 2\sqrt{S_T}$ [REF: proofs/library/optimization/adaptive-methods/adagrad-sparse-regret/proof.md, Step 4]:

$$\text{Regret}_T \leq \frac{D^2 dG\sqrt{T}}{2\alpha(1-\beta_1)} + \frac{2\alpha dG}{(1-\beta_1)\epsilon}\sqrt{T}$$

## Step 2: Attempt to Convert to Non-Convex Setting

For non-convex $f$, define linear surrogates $f_t(x) = \langle g_t, x \rangle$. Then:
$$\sum_{t=1}^T \langle g_t, x_t - x^* \rangle = \text{Regret}_T$$

Taking expectations:
$$\sum_{t=1}^T \mathbb{E}[\langle \nabla f(x_t), x_t - x^* \rangle] = \mathbb{E}[\text{Regret}_T]$$

By $L$-smoothness and convexity of the quadratic upper bound:
$$f(x_t) - f(x^*) \leq \langle \nabla f(x_t), x_t - x^* \rangle$$
**But this requires convexity of $f$!**

For non-convex $f$, we only have:
$$\langle \nabla f(x_t), x_t - x^* \rangle \geq f(x_t) - f(x^*) - \frac{L}{2}\|x_t - x^*\|^2 + \frac{1}{2L}\|\nabla f(x_t)\|^2$$

Wait, this isn't right either. The standard online-to-batch conversion [REF: proofs/library/learning-theory/generalization/online-to-batch-conversion/proof.md] requires convexity.

## Step 3: Non-Convex Regret Reduction (Alternative)

For non-convex optimization, we can use a different reduction. Instead of comparing to a fixed $x^*$, use the descent lemma directly.

From L-smoothness:
$$f(x_{t+1}) - f(x_t) \leq -\alpha_t\left\langle \nabla f(x_t), \frac{m_t}{\sqrt{\hat{v}_t}+\epsilon}\right\rangle + \frac{L\alpha_t^2}{2}\left\|\frac{m_t}{\sqrt{\hat{v}_t}+\epsilon}\right\|^2$$

This brings us back to the descent lemma framework of Route 1. The regret perspective doesn't provide a clean alternative for non-convex objectives.

## Route Failure Report

- **Route**: Regret-to-Convergence Reduction
- **Failed at**: Step 2-3
- **Obstacle**: The online-to-batch conversion requires convexity. For non-convex optimization, the regret bound cannot be directly translated to gradient norm bounds because:
  1. $\langle \nabla f(x_t), x_t - x^* \rangle$ does NOT lower-bound $f(x_t) - f(x^*)$ without convexity
  2. The non-convex reduction inevitably falls back to the descent lemma framework
  3. The momentum term $m_t$ vs $g_t$ creates additional complications in the regret framework
  
- **Partial result**: The convex regret bound $O(\sqrt{d}G\sqrt{T}/(1-\beta_1))$ is established but cannot be converted to non-convex convergence rate.

- **Suggestion**: This route might work if combined with a non-convex online-to-offline conversion (e.g., Harvey et al. 2019 style), but this would be a fundamentally different and more complex proof.
