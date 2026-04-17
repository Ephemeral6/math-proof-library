# Proof Route 4: Lyapunov / Potential Function Approach

**Route**: Construct a potential function measuring angular distance to $\hat{w}$ and show it decreases.

---

## Setup

Same notation. Data $\{(x_i, y_i)\}_{i=1}^n$, linearly separable. $L(w) = \frac{1}{n}\sum_i \log(1+e^{-y_i w^T x_i})$. GD: $w_{t+1} = w_t - \eta \nabla L(w_t)$.

Define $\hat{w} = w^*/\|w^*\|$ (max-margin unit vector), $\gamma^* = \min_i y_i \hat{w}^T x_i > 0$.

---

## Step 1: Define the angular potential

Let $\theta_t = \angle(w_t, \hat{w})$ be the angle between $w_t$ and $\hat{w}$. We want to show $\theta_t \to 0$.

Equivalently, define the cosine similarity:
$$\cos\theta_t = \frac{\langle w_t, \hat{w}\rangle}{\|w_t\|}$$

We aim to show $\cos\theta_t \to 1$.

---

## Step 2: Evolution of the numerator

$$\langle w_{t+1}, \hat{w}\rangle = \langle w_t, \hat{w}\rangle + \eta\langle -\nabla L(w_t), \hat{w}\rangle$$
$$= \langle w_t, \hat{w}\rangle + \frac{\eta}{n}\sum_i \sigma(-m_i(t)) y_i x_i^T \hat{w}$$
$$\geq \langle w_t, \hat{w}\rangle + \frac{\eta\gamma^*}{n}\sum_i \sigma(-m_i(t))$$

The last inequality uses $y_i x_i^T \hat{w} \geq \gamma^*$ for all $i$.

---

## Step 3: Evolution of the denominator (norm)

$$\|w_{t+1}\|^2 = \|w_t - \eta\nabla L(w_t)\|^2 = \|w_t\|^2 + 2\eta\langle w_t, -\nabla L(w_t)\rangle + \eta^2\|\nabla L(w_t)\|^2$$

Now:
$$\langle w_t, -\nabla L(w_t)\rangle = \frac{1}{n}\sum_i \sigma(-m_i(t)) y_i w_t^T x_i = \frac{1}{n}\sum_i \sigma(-m_i(t)) m_i(t)$$

So:
$$\|w_{t+1}\|^2 = \|w_t\|^2 + \frac{2\eta}{n}\sum_i \sigma(-m_i(t))m_i(t) + \eta^2\|\nabla L(w_t)\|^2$$

---

## Step 4: Comparing growth rates

Define $S_t = \frac{1}{n}\sum_i \sigma(-m_i(t))$ and $M_t = \frac{\sum_i \sigma(-m_i(t))m_i(t)}{\sum_i \sigma(-m_i(t))}$ (the weighted average margin).

Then:
- Numerator growth: $\langle w_{t+1}, \hat{w}\rangle \geq \langle w_t, \hat{w}\rangle + \eta\gamma^* S_t$
- Norm-squared growth: $\|w_{t+1}\|^2 \leq \|w_t\|^2 + 2\eta S_t M_t + \eta^2\|\nabla L(w_t)\|^2$

For $\cos\theta_t \to 1$, we need the numerator to grow "as fast as" the denominator (the norm).

Note: $\|w_{t+1}\| \leq \|w_t\| + \eta\|\nabla L(w_t)\|$ by triangle inequality.

So $\|w_{t+1}\| - \|w_t\| \leq \eta\|\nabla L(w_t)\| = \eta\left\|\frac{1}{n}\sum_i \sigma(-m_i(t))y_i x_i\right\|$.

By Cauchy-Schwarz: $\|\nabla L(w_t)\| \leq \frac{1}{n}\sum_i \sigma(-m_i(t))\|x_i\| \leq S_t \cdot \max_i\|x_i\|$.

Let $R = \max_i \|x_i\|$. Then $\|w_{t+1}\| - \|w_t\| \leq \eta R S_t$.

Meanwhile, $\langle w_{t+1}, \hat{w}\rangle - \langle w_t, \hat{w}\rangle \geq \eta\gamma^* S_t$.

So the ratio of growth in the $\hat{w}$ direction to the maximum possible norm growth is at least $\gamma^*/R > 0$.

---

## Step 5: Summing the growth rates

Summing from $t = 0$ to $T-1$:
$$\langle w_T, \hat{w}\rangle \geq \langle w_0, \hat{w}\rangle + \eta\gamma^* \sum_{t=0}^{T-1} S_t$$
$$\|w_T\| \leq \|w_0\| + \eta R \sum_{t=0}^{T-1} S_t$$

Let $\Sigma_T = \sum_{t=0}^{T-1} S_t$. Since $\|w_T\| \to \infty$, we need $\Sigma_T \to \infty$.

Indeed, $\Sigma_T \to \infty$ because the GD iterates satisfy $w_T = w_0 + \eta\sum_t(-\nabla L(w_t))$ and $\|w_T\| \to \infty$ requires the cumulative gradient norms to diverge. More precisely, $\|w_T - w_0\| \leq \eta R \Sigma_T$, and since $\|w_T\| \to \infty$, we need $\Sigma_T \to \infty$.

Now:
$$\cos\theta_T = \frac{\langle w_T, \hat{w}\rangle}{\|w_T\|} \geq \frac{\langle w_0, \hat{w}\rangle + \eta\gamma^*\Sigma_T}{\|w_0\| + \eta R \Sigma_T} \to \frac{\gamma^*}{R}$$

as $T \to \infty$. This gives $\liminf_{T\to\infty} \cos\theta_T \geq \gamma^*/R$.

---

## Step 6: Tightening the bound — this only gives a lower bound

The bound $\cos\theta_T \geq \gamma^*/R$ is not tight (we need $\cos\theta_T \to 1$). The issue is that the norm bound $\|w_{t+1}\| - \|w_t\| \leq \eta R S_t$ is too loose — it doesn't account for the fact that as $w_t$ aligns with $\hat{w}$, the norm growth is dominated by the $\hat{w}$ component.

**Attempt to improve**: We could track $\|w_t - (\langle w_t, \hat{w}\rangle)\hat{w}\|$ (the orthogonal component). The orthogonal component evolves as:
$$w_{t+1}^{\perp} = w_t^{\perp} - \eta(\nabla L(w_t))^{\perp}$$
where $v^{\perp} = v - \langle v, \hat{w}\rangle\hat{w}$.

So $\|w_{T}^{\perp}\| \leq \|w_0^{\perp}\| + \eta\sum_t \|(\nabla L(w_t))^{\perp}\|$.

We need $\|(\nabla L(w_t))^{\perp}\|$ to be small relative to $\|(\nabla L(w_t))^{\parallel}\|$ eventually. But this requires knowing which data points dominate the gradient, which brings us back to the margin analysis.

---

## Step 7: Attempting the orthogonal decomposition more carefully

The gradient projected onto $\hat{w}$ is:
$$\langle -\nabla L(w_t), \hat{w}\rangle = \frac{1}{n}\sum_i \sigma(-m_i(t))\gamma_i$$
where $\gamma_i = y_i \hat{w}^T x_i$.

The orthogonal component is:
$$(-\nabla L(w_t))^{\perp} = \frac{1}{n}\sum_i \sigma(-m_i(t))(y_i x_i - \gamma_i \hat{w})$$

For the max-margin solution, the KKT conditions give $\hat{w} = \sum_i \alpha_i^* y_i x_i$ with $\alpha_i^* > 0$ only for $i \in \mathcal{S}$ (support vectors with $\gamma_i = \gamma^*$). This means:
$$\sum_{i \in \mathcal{S}} \alpha_i^* (y_i x_i - \gamma^* \hat{w}) = \hat{w} - \gamma^*\hat{w}\sum_{i \in \mathcal{S}}\alpha_i^* = \hat{w}(1 - \gamma^*\|\hat{w}\|^2/\gamma^*) $$

Wait, let me recalculate. With the normalization $\hat{w} = w^*/\|w^*\|$ (unit vector) and the SVM: $w^* = \sum_i \alpha_i^* y_i x_i$. So $\hat{w} = w^*/\|w^*\|$. Then:

$$\sum_{i \in \mathcal{S}} \alpha_i^* y_i x_i = w^* = \|w^*\|\hat{w}$$

The orthogonal component of $\sum_{i \in \mathcal{S}} \alpha_i^*(y_i x_i)$ relative to $\hat{w}$ is zero.

So if the gradient is asymptotically dominated by support vectors with weights proportional to $\alpha_i^*$, then the orthogonal component of the gradient vanishes faster than the parallel component. But establishing this requires... the same margin analysis as Route 1.

---

## Route Failure Report

- **Route**: Lyapunov / Potential Function Approach
- **Failed at**: Step 6 — Could not close the gap between $\cos\theta_T \geq \gamma^*/R$ and the target $\cos\theta_T \to 1$
- **Obstacle**: The simple Lyapunov argument only gives a constant lower bound on $\cos\theta_T$, not convergence to 1. Tightening requires analyzing the orthogonal component of the gradient, which needs the detailed margin dynamics from Route 1. The approach provides a useful partial result but cannot be self-contained.
- **Partial results**: Proved $\liminf \cos\theta_T \geq \gamma^*/R > 0$, which at least shows the iterates don't go in a completely wrong direction. Also proved $\|w_t\| \to \infty$ via the same argument as Route 1.
