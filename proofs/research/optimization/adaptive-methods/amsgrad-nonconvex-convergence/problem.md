# AMSGrad Convergence for Non-Convex Stochastic Optimization

## Source
- Paper: "On the Convergence of Adam and Beyond" (Reddi, Kale, Kumar, 2018, ICLR)
- Context: AMSGrad fixes Adam's convergence issues by maintaining the maximum of past squared gradients

## Statement

Consider the AMSGrad algorithm for minimizing a non-convex function $f: \mathbb{R}^d \to \mathbb{R}$:

Given stochastic gradients $g_t$ with $\mathbb{E}[g_t | x_t] = \nabla f(x_t)$, AMSGrad updates:
$$m_t = \beta_1 m_{t-1} + (1-\beta_1) g_t$$
$$v_t = \beta_2 v_{t-1} + (1-\beta_2) g_t^2$$
$$\hat{v}_t = \max(\hat{v}_{t-1}, v_t) \quad \text{(element-wise)}$$
$$x_{t+1} = x_t - \alpha_t \frac{m_t}{\sqrt{\hat{v}_t} + \epsilon}$$

**Assumptions:**
- $f$ is $L$-smooth: $\|\nabla f(x) - \nabla f(y)\| \leq L\|x-y\|$
- Bounded gradients: $\|g_t\|_\infty \leq G$ almost surely
- Bounded variance: $\mathbb{E}[\|g_t - \nabla f(x_t)\|^2] \leq \sigma^2$
- Step size $\alpha_t = \alpha / \sqrt{T}$, $\beta_1 < \sqrt{\beta_2} < 1$

**Prove:** AMSGrad achieves
$$\frac{1}{T}\sum_{t=1}^{T} \mathbb{E}[\|\nabla f(x_t)\|^2] \leq O\left(\frac{1}{\sqrt{T}}\right)$$

More precisely, show that after $T$ iterations:
$$\frac{1}{T}\sum_{t=1}^{T} \mathbb{E}[\|\nabla f(x_t)\|^2] \leq \frac{2\sqrt{d}G(f(x_1)-f^*)}{\alpha\sqrt{T}} + \frac{L\alpha\sigma^2\sqrt{d}}{(1-\beta_1)\sqrt{T}} + \frac{G\beta_1}{1-\beta_1}$$

## Difficulty
research
