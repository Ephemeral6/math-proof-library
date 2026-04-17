# Proof Route 3: Gradient Alignment + Norm Divergence

**Route**: Two-part argument — (1) $\|w_t\| \to \infty$, (2) asymptotic gradient direction analysis

---

## Setup

Data $\{(x_i, y_i)\}_{i=1}^n$ with $x_i \in \mathbb{R}^d$, $y_i \in \{-1,+1\}$, linearly separable. Loss $L(w) = \frac{1}{n}\sum_i \log(1+e^{-y_i w^T x_i})$. GD: $w_{t+1} = w_t - \eta \nabla L(w_t)$.

Gradient: $\nabla L(w) = -\frac{1}{n}\sum_i \sigma(-y_i w^T x_i) y_i x_i$.

---

## Part 1: Norm Divergence

(Same as Route 1, Step 1.) $\|w_t\| \to \infty$ because the logistic loss on separable data has no finite critical points, and $\|\nabla L(w_t)\| \to 0$ by the descent lemma with summable squared gradients.

---

## Part 2: Direction of the gradient converges to the max-margin direction

## Step 1: Decompose the gradient by support vector contribution

Write $\hat{w} = w^*/\|w^*\|$. For any $w$ with large $\|w\|$ such that $w/\|w\|$ is close to some direction $v$ with $\min_i y_i v^T x_i > 0$:

$$-\nabla L(w) = \frac{1}{n}\sum_i \sigma(-m_i) y_i x_i = \frac{1}{n}\sum_i \frac{e^{-m_i}}{1+e^{-m_i}} y_i x_i$$

where $m_i = y_i w^T x_i$.

As $\|w\| \to \infty$ along a direction $v$, $m_i \approx \|w\| y_i v^T x_i$. The exponential weighting $e^{-m_i}$ favors data points with the smallest margins. Define:
$$\gamma_i(v) = y_i v^T x_i$$
the margin of point $i$ with respect to direction $v$.

Let $\gamma_{\min}(v) = \min_i \gamma_i(v)$ and $\mathcal{S}(v) = \{i : \gamma_i(v) = \gamma_{\min}(v)\}$ be the "support vectors" of direction $v$.

Then for $w = R \cdot v$ with $R \to \infty$:
$$-\nabla L(Rv) \approx \frac{1}{n} e^{-R\gamma_{\min}(v)} \sum_{i \in \mathcal{S}(v)} y_i x_i + O(e^{-R(\gamma_{\min}(v)+\delta)})$$
where $\delta > 0$ is the gap between the minimum and second-minimum margin.

So the gradient direction is:
$$\frac{-\nabla L(Rv)}{\|\nabla L(Rv)\|} \to \frac{\sum_{i \in \mathcal{S}(v)} y_i x_i}{\|\sum_{i \in \mathcal{S}(v)} y_i x_i\|}$$

## Step 2: Attempting to link gradient direction to iterate direction

The GD update $w_{t+1} = w_t + \eta(-\nabla L(w_t))$ adds a vector in the direction of $-\nabla L(w_t)$ at each step. If the gradient direction were constant, the iterate direction would converge to it. But the gradient direction depends on $w_t$, creating a coupled dynamical system.

**Difficulty**: The direction of $-\nabla L(w_t)$ depends on which points have minimum margin with respect to $w_t/\|w_t\|$. As $w_t/\|w_t\|$ changes, the set of "support vectors" can change, and the gradient direction can shift. This makes the argument circular: we need to know the limiting direction to determine which points are support vectors, but we need to know the support vectors to determine the limiting direction.

## Step 3: Breaking circularity via the variational characterization

The max-margin direction $\hat{w}$ satisfies: $\gamma^* = \max_{\|v\|=1} \min_i y_i v^T x_i = \min_i y_i \hat{w}^T x_i$.

**Key property**: $\hat{w}$ is the unique direction (up to sign) that maximizes the minimum margin. For the max-margin direction, the support vectors $\mathcal{S}(\hat{w})$ and the dual coefficients $\alpha_i^*$ satisfy:
$$\hat{w} \propto \sum_{i \in \mathcal{S}(\hat{w})} \alpha_i^* y_i x_i$$

Consider the inner product $\langle w_t, \hat{w} \rangle$. We have:
$$\langle w_{t+1}, \hat{w} \rangle - \langle w_t, \hat{w} \rangle = -\eta \langle \nabla L(w_t), \hat{w} \rangle = \frac{\eta}{n}\sum_i \sigma(-m_i(t)) y_i x_i^T \hat{w}$$

Since $y_i x_i^T \hat{w} \geq \gamma^* > 0$ for all $i$ (by definition of max margin):
$$\langle w_{t+1}, \hat{w}\rangle - \langle w_t, \hat{w}\rangle \geq \frac{\eta \gamma^*}{n}\sum_i \sigma(-m_i(t)) = \eta \gamma^* \cdot \frac{1}{n}\sum_i \sigma(-m_i(t))$$

Similarly, for any other unit direction $v$ with minimum margin $\gamma_v < \gamma^*$:
$$\langle w_{t+1}, v\rangle - \langle w_t, v\rangle = \frac{\eta}{n}\sum_i \sigma(-m_i(t)) y_i x_i^T v$$

The growth in the $\hat{w}$ direction is at least $\gamma^*$ times the "total weight" $\sum_i \sigma(-m_i(t))/n$, while the growth in direction $v$ involves $y_i x_i^T v$ which may be smaller for some points.

## Step 4: Relating norm growth to directional growth

We have $\|w_{t+1}\|^2 = \|w_t\|^2 + 2\eta \langle w_t, -\nabla L(w_t)\rangle + \eta^2 \|\nabla L(w_t)\|^2$.

Since $\|\nabla L(w_t)\| \to 0$ and $\|w_t\| \to \infty$, the dominant term in the norm growth is $2\eta \langle w_t, -\nabla L(w_t)\rangle$.

However, this approach does not easily yield the precise directional convergence without essentially reverting to the margin analysis of Route 1.

## Route Failure Report

- **Route**: Gradient Alignment + Norm Divergence
- **Failed at**: Step 4 — linking the gradient direction convergence to the iterate direction convergence
- **Obstacle**: The approach establishes that the growth rate in the max-margin direction $\hat{w}$ is at least $\gamma^*$ times the total sigmoid weight, but translating this into a convergence of $w_t/\|w_t\|$ to $\hat{w}$ requires the same detailed margin analysis as Route 1. The "gradient alignment" approach does not provide a self-contained shortcut. The gradient direction at any given $w_t$ depends on $w_t$ itself through the margins, creating a coupled system that requires tracking individual margin dynamics.
- **Partial results**: The inner product analysis (Step 3) provides a useful lower bound on the growth rate in the max-margin direction but is insufficient alone. Would need to combine with an upper bound on growth in orthogonal directions, which ultimately requires the $\log t$ asymptotics from Route 1.
