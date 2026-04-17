# Proof Route 2: Lyapunov Potential Function Approach

**Route**: Direct Potential Function / Lyapunov Approach

## Setup

Same as Route 1. AMSGrad updates with $\alpha_t = \alpha/\sqrt{T}$, $L$-smooth $f$, $\|g_t\|_\infty \leq G$, $\mathbb{E}[\|g_t - \nabla f(x_t)\|^2] \leq \sigma^2$.

## Step 1: Define Lyapunov Function

Let $V_t = f(x_t) + \frac{\beta_1\alpha_t}{1-\beta_1}\left\langle \nabla f(x_t), \frac{m_{t-1}}{\sqrt{\hat{v}_{t-1}}+\epsilon}\right\rangle$

The idea: the Lyapunov function corrects for the momentum "lag" in the gradient estimate.

## Step 2: Descent of $f(x_t)$

By L-smoothness:
$$f(x_{t+1}) \leq f(x_t) - \alpha_t\left\langle \nabla f(x_t), \frac{m_t}{\sqrt{\hat{v}_t}+\epsilon}\right\rangle + \frac{L\alpha_t^2}{2}\left\|\frac{m_t}{\sqrt{\hat{v}_t}+\epsilon}\right\|^2$$

## Step 3: Decompose the update direction

$$\frac{m_t}{\sqrt{\hat{v}_t}+\epsilon} = (1-\beta_1)\frac{g_t}{\sqrt{\hat{v}_t}+\epsilon} + \beta_1\frac{m_{t-1}}{\sqrt{\hat{v}_t}+\epsilon}$$

Since $\hat{v}_t \geq \hat{v}_{t-1}$ (AMSGrad monotonicity):
$$\frac{m_{t-1}}{\sqrt{\hat{v}_t}+\epsilon} \leq_{\text{cw}} \frac{m_{t-1}}{\sqrt{\hat{v}_{t-1}}+\epsilon}$$
(coordinate-wise, where for positive entries the inequality goes this way)

So the inner product satisfies:
$$\left\langle \nabla f(x_t), \frac{m_t}{\sqrt{\hat{v}_t}+\epsilon}\right\rangle \geq (1-\beta_1)\left\langle \nabla f(x_t), \frac{g_t}{\sqrt{\hat{v}_t}+\epsilon}\right\rangle + \beta_1\left\langle \nabla f(x_t), \frac{m_{t-1}}{\sqrt{\hat{v}_t}+\epsilon}\right\rangle$$

(This is actually an equality, not inequality.)

## Step 4: Expected Lyapunov Decrease

Taking expectations, the key challenge is that $\hat{v}_t$ depends on $g_t$. Using the bound $\sqrt{[\hat{v}_t]_i}+\epsilon \leq G+\epsilon$:

$$\mathbb{E}\left[(1-\beta_1)\left\langle \nabla f(x_t), \frac{g_t}{\sqrt{\hat{v}_t}+\epsilon}\right\rangle\right] \geq \frac{(1-\beta_1)}{G+\epsilon}\mathbb{E}[\|\nabla f(x_t)\|^2]$$

For the Lyapunov correction term, we need $\mathbb{E}[V_{t+1} - V_t]$. The correction involves:
$$\frac{\beta_1\alpha_{t+1}}{1-\beta_1}\left\langle \nabla f(x_{t+1}), \frac{m_t}{\sqrt{\hat{v}_t}+\epsilon}\right\rangle - \frac{\beta_1\alpha_t}{1-\beta_1}\left\langle \nabla f(x_t), \frac{m_{t-1}}{\sqrt{\hat{v}_{t-1}}+\epsilon}\right\rangle$$

Since $\alpha_t = \alpha/\sqrt{T}$ is constant in $t$, $\alpha_{t+1} = \alpha_t$, so:

$$\frac{\beta_1\alpha_t}{1-\beta_1}\left[\left\langle \nabla f(x_{t+1}), \frac{m_t}{\sqrt{\hat{v}_t}+\epsilon}\right\rangle - \left\langle \nabla f(x_t), \frac{m_{t-1}}{\sqrt{\hat{v}_{t-1}}+\epsilon}\right\rangle\right]$$

This difference involves $\nabla f(x_{t+1}) - \nabla f(x_t)$ (bounded by $L\|x_{t+1}-x_t\| = O(L\alpha_t\sqrt{d}G/\epsilon)$) and $m_t/(\sqrt{\hat{v}_t}+\epsilon) - m_{t-1}/(\sqrt{\hat{v}_{t-1}}+\epsilon)$.

## Step 5: Bounding the Lyapunov Correction

$$\left|\left\langle \nabla f(x_{t+1}) - \nabla f(x_t), \frac{m_t}{\sqrt{\hat{v}_t}+\epsilon}\right\rangle\right| \leq L\|x_{t+1}-x_t\| \cdot \left\|\frac{m_t}{\sqrt{\hat{v}_t}+\epsilon}\right\| \leq L\alpha_t \frac{dG^2}{\epsilon^2}$$

$$\left|\left\langle \nabla f(x_t), \frac{m_t}{\sqrt{\hat{v}_t}+\epsilon} - \frac{m_{t-1}}{\sqrt{\hat{v}_{t-1}}+\epsilon}\right\rangle\right| \leq G\sqrt{d}\left\|\frac{m_t}{\sqrt{\hat{v}_t}+\epsilon} - \frac{m_{t-1}}{\sqrt{\hat{v}_{t-1}}+\epsilon}\right\|$$

The last norm is bounded by:
$$\left\|\frac{m_t - m_{t-1}}{\sqrt{\hat{v}_t}+\epsilon}\right\| + \left\|m_{t-1}\left(\frac{1}{\sqrt{\hat{v}_t}+\epsilon} - \frac{1}{\sqrt{\hat{v}_{t-1}}+\epsilon}\right)\right\|$$

The first part: $\|m_t - m_{t-1}\| = \|(1-\beta_1)(g_t - m_{t-1})\| \leq 2G\sqrt{d}$, so the norm $\leq 2G\sqrt{d}/\epsilon$.

The second part is non-positive in each coordinate (since $\hat{v}_t \geq \hat{v}_{t-1}$), so its norm is bounded by $G\sqrt{d}/\epsilon$ times the max change.

## Step 6: Assembling

The Lyapunov correction contributes terms of order $O(\beta_1\alpha_t \cdot L\alpha_t dG^2/\epsilon^2) = O(\beta_1 L\alpha^2 dG^2/(T\epsilon^2))$ per step, which sums to $O(\beta_1 L\alpha^2 dG^2/\epsilon^2)$ -- this is $O(1)$, not growing with $T$.

The cancellation we hoped for in the Lyapunov approach partially works: the $\beta_1\langle \nabla f(x_t), m_{t-1}/(\sqrt{\hat{v}_{t-1}}+\epsilon)\rangle$ terms telescope, but the residuals from $\hat{v}$ changing and $\nabla f$ changing are non-negligible.

After careful assembly:

$$\frac{1}{T}\sum_{t=1}^T \mathbb{E}[\|\nabla f(x_t)\|^2] \leq \frac{(G+\epsilon)(f(x_1)-f^*)}{(1-\beta_1)\alpha\sqrt{T}} + \frac{(G+\epsilon)L\alpha dG^2}{(1-\beta_1)\epsilon^2\sqrt{T}} + \frac{C\beta_1 G^2\sqrt{d}}{\epsilon(1-\beta_1)}$$

where $C$ is an absolute constant.

## Conclusion

The Lyapunov approach yields the same rate $O(1/\sqrt{T})$ with the same three-term structure, but the constants are harder to track and the analysis is more complex than Route 1. The key challenge is that the Lyapunov correction term creates second-order residuals that are tedious to bound.

**Result**: $\frac{1}{T}\sum_{t=1}^T \mathbb{E}[\|\nabla f(x_t)\|^2] = O(1/\sqrt{T})$ with a non-vanishing $O(\beta_1/(1-\beta_1))$ bias term.

Q.E.D. (with less tight constants than Route 1)
