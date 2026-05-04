# Garrigos-Cortild-Ketels-Peypouquet 2025 — Structural Summary

**Paper:** "Last-Iterate Complexity of SGD for Convex and Smooth Stochastic Problems"
arXiv:2507.14122v1 [math.OC] 18 July 2025

## Setting

- $f(x) = \mathbb{E}_{i \sim D}[f_i(x)]$, each $f_i$ convex L-smooth.
- SGD: $x_{t+1} = x_t - \eta \nabla f_{i_t}(x_t)$, $i_t \sim D$ iid.
- $\sigma^2 := \inf_{x^* \in \arg\min f} \mathbb{E}\|\nabla f_i(x^*)\|^2$ (variance at the minimum, NOT a uniform variance bound).
- Assumption 2.1: each $f_i$ convex L-smooth.
- Assumption 2.2: $\sigma^2 < \infty$ (just at one optimal point — auto-extends).

## Theorem 3.1 (main)

For $\eta L \in (0,1)$, $T \geq 3$:
$$\mathbb{E}[f(x_T) - \inf f] \leq T^\theta \cdot \left[\frac{2 D^2}{(1-\eta L) T} + \frac{8 \ln(T+1)}{(1-\eta L)^2} \eta \sigma^2\right]$$
where $\theta = \frac{2\eta L}{1+\eta L} \in (0,1)$, $D^2 = \mathbb{E}\|x_0 - x^*\|^2$.

For $\eta = 1/(C\sqrt{LT})$ with $C \geq 2$, Lemma 3.2 gives $T^\theta = O(1)$:
$$\mathbb{E}[f(x_T) - \inf f] \leq O\left(\frac{LD^2 + \sqrt{L} \cdot \ln(T+1) \cdot \sigma^2/\sqrt{T}}{\sqrt{T}}\right) = \tilde{O}(T^{-1/2}).$$

## Three-step proof structure

### Step 1 — Lemma 4.1 (Variance Transfer) [the new tool]
For any $x^* \in \arg\min f$, any $x \in H$, any $\varepsilon > 0$:
$$\mathbb{E}\|\nabla f_i(x)\|^2 \leq 2L(1+\varepsilon) (f(x) - \inf f) + (1 + \varepsilon^{-1}) \mathbb{E}\|\nabla f_i(x^*)\|^2.$$

**Proof technique:** Fenchel-Young $\|a+b\|^2 \leq (1+\varepsilon)\|a\|^2 + (1+\varepsilon^{-1})\|b\|^2$ applied to $\nabla f_i(x) = (\nabla f_i(x) - \nabla f_i(x^*)) + \nabla f_i(x^*)$, then "expected smoothness" $\frac{1}{2L}\mathbb{E}\|\nabla f_i(x) - \nabla f_i(x^*)\|^2 \leq f(x) - \inf f$ (Garrigos-Gower 2024 Lemma 4.8).

**Key insight:** The variance of stochastic gradients at $x$ is automatically bounded by (function gap) + (variance at the minimum). No bounded-variance assumption needed.

### Step 2 — Lemma 4.2 (Bounded linear combination of function values)
For SGD with $\eta L < 1$, choose $\varepsilon = (1-\eta L)/(1+\eta L)$. Then for any F-measurable $z_t$:
$$\mathbb{E}[a f(x_t) + b f(z_t) + c \inf f] \leq \tfrac{1}{2} \mathbb{E}\|x_t - z_t\|^2 - \tfrac{1}{2}\mathbb{E}\|x_{t+1} - z_t\|^2 + v$$
with
$$a = \frac{1-\eta L}{1+\eta L}, \quad b = -1, \quad c = \frac{2\eta L}{1+\eta L}, \quad v = \frac{\eta^2 \sigma^2}{1-\eta L}.$$
Note $a + b + c = 0$ and $a > 0$ when $\eta L < 1$.

**Proof:**
- Standard descent: $\|x_{t+1} - z_t\|^2 - \|x_t - z_t\|^2 = \eta^2 \|\nabla f_{i_t}(x_t)\|^2 + 2\eta \langle \nabla f_{i_t}(x_t), z_t - x_t\rangle$.
- Convexity of $f_i$: $\langle \nabla f_{i_t}(x_t), z_t - x_t\rangle \leq f_{i_t}(z_t) - f_{i_t}(x_t)$.
- Take $\mathbb{E}_t$: get $\mathbb{E}_t\|x_{t+1} - z_t\|^2 \leq \|x_t - z_t\|^2 + \eta^2 \mathbb{E}_t\|\nabla f_{i_t}(x_t)\|^2 + 2\eta(f(z_t) - f(x_t))$.
- Apply variance transfer to $\eta^2 \mathbb{E}_t\|\nabla f_{i_t}(x_t)\|^2$.
- Reorganize, divide.

### Step 3 — Lemma 4.3 (Zamani-Glineur auxiliary sequence to last iterate)
Given the descent inequality with $-a < b \leq 0$, $a+b+c = 0$:
$$\mathbb{E}[f(x_T) - \inf f] \leq \frac{\|x_0 - x^*\|^2}{2 a \theta_{T-1}} + \frac{v}{a} \cdot \frac{\theta_{T-1} + \sum_{t=0}^{T-1}\theta_t}{\theta_{T-1}}$$
where $\theta_{-1} = 1$ and $\theta_t = \frac{T-t+1}{T-t+1+a/b} \theta_{t-1}$ for $t \geq 1$.

**Proof technique:**
1. Use auxiliary $z_t = (1-p_t) x_t + p_t z_{t-1}$ with $z_{-1} := x^*$ and $p_t \in [0,1]$.
2. $\|x_t - z_t\|^2 = p_t^2 \|x_t - z_{t-1}\|^2 \leq p_t \|x_t - z_{t-1}\|^2$.
3. Multiply descent by $\theta_t \geq 0$ chosen so $\theta_t p_t = \theta_{t-1}$, i.e., $p_t = \theta_{t-1}/\theta_t$.
4. After summation, the quadratic terms telescope.
5. Use Jensen on $f(z_t) \leq \sum q_s f(x_s) + q'_t \cdot \inf f$ (since $z_t$ is convex combination).
6. Choose $\theta_t$ so the coefficients of $r_s = f(x_s) - \inf f$ for $s < T$ vanish; only $r_T$ survives.
7. Recursion (10) in the paper: $a t \theta_t = -b(\theta_t - \theta_{t-1})(T-t+1)$ ⟹ $\theta_t = \frac{T-t+1}{T-t+1+a/b}\theta_{t-1}$.

### Lemma A.3 (asymptotics of θ via Gautschi's inequality)
$\theta_{T-1} \geq (T+1)^{1-\gamma}/2$ and $\sum_{t=0}^{T-1} \theta_t \leq 2 T \theta_{T-1}/(1+\gamma)$
where $\gamma = 1 + a/b \in [0,1]$ (in the SGD case $\gamma = \theta = 2\eta L/(1+\eta L)$).

For $\eta = 1/(C\sqrt{LT})$, $\gamma = O(1/\sqrt{T})$ which is small, so $\theta_{T-1} = \Omega(\sqrt{T})$ and the leading term is $D^2/\sqrt{T}$. ✓

## What breaks for SHB

The SHB iteration is $y_{t+1} = y_t - \eta \nabla f_{i_t}(y_t) + \beta(y_t - y_{t-1})$. With Iouditski-Polyak COV $w_t := y_t + a(y_t - y_{t-1})$, $a = \beta/(1-\beta)$, $\eta' = \eta/(1-\beta)$:
$$w_{t+1} = w_t - \eta' \nabla f_{i_t}(y_t).$$

This is "biased SGD": gradient evaluated at $y_t \neq w_t$.

**The bias** $\nabla f(y_t) - \nabla f(w_t)$ has $\|y_t - w_t\| = a \|y_t - y_{t-1}\|$ which is the momentum length.

When we redo Lemma 4.2 for SHB:
$$\mathbb{E}_t\|w_{t+1} - z_t\|^2 \leq \|w_t - z_t\|^2 - 2\eta'(f(y_t) - f(z_t)) - 2\eta'\langle \nabla f(y_t), w_t - y_t\rangle + \eta'^2 \mathbb{E}_t\|g_t\|^2.$$

The **cross-term** $-2\eta'\langle \nabla f(y_t), w_t - y_t\rangle = -2\eta' a \langle \nabla f(y_t), y_t - y_{t-1}\rangle$.

By convexity (applied at $y_t$ to $y_{t-1}$): $\langle \nabla f(y_t), y_t - y_{t-1}\rangle \geq f(y_t) - f(y_{t-1})$.

So:
$$\mathbb{E}_t\|w_{t+1} - z_t\|^2 \leq \|w_t - z_t\|^2 - 2\eta'(1+a) r_t + 2\eta' a r_{t-1} + 2\eta'(f(z_t) - \inf f) + \eta'^2 \mathbb{E}_t\|g_t\|^2$$
where $r_t = f(y_t) - \inf f$.

Apply variance transfer at $y_t$:
$$\eta'^2 \mathbb{E}_t\|g_t\|^2 \leq 2\eta'^2 L(1+\varepsilon) r_t + \eta'^2(1+\varepsilon^{-1}) \sigma^2.$$

So the SHB descent inequality is:
$$A r_t - B r_{t-1} - C(f(z_t) - \inf f) \leq \|w_t - z_t\|^2 - \mathbb{E}_t\|w_{t+1} - z_t\|^2 + V$$
with
- $A = 2\eta'[(1+a) - \eta' L(1+\varepsilon)]$
- $B = 2\eta' a$
- $C = 2\eta'$
- $V = \eta'^2 (1+\varepsilon^{-1}) \sigma^2$
- $A - B - C = -2\eta'^2 L(1+\varepsilon)$, so the inf-f offset is $c'' = 2\eta'^2 L(1+\varepsilon)$.

**The new structural feature** is the $-B r_{t-1}$ term (compared to Garrigos who has just $A f(x_t)$).

## Plan to handle the $r_{t-1}$ term

Two options:

**Option α (Lyapunov augmentation):** Add $\gamma \|y_t - y_{t-1}\|^2$ to the squared distance and absorb the cross term differently — but this is what Liu-Gao 2025 already did and gave $T^{-1/3}$.

**Option β (Telescope-and-shift):** When summing with weights $\theta_t$:
$$\sum_t \theta_t (A r_t - B r_{t-1}) = A \theta_{T-1} r_{T-1} + \sum_{t=0}^{T-2}(A \theta_t - B \theta_{t+1}) r_t - B \theta_0 r_{-1}.$$

The Garrigos-style choice $\theta_{t+1}/\theta_t = A/B > 1$ would make middle terms vanish but $\theta_t$ would grow geometrically — incompatible with the quadratic-telescope constraint $\theta_t p_t = \theta_{t-1}$ which requires $\theta_{t-1}/\theta_t = p_t \in [0,1]$, i.e., $\theta_t$ non-decreasing-or-stable.

**Option γ (Combined ZG-weight):** Allow the middle terms $A \theta_t - B \theta_{t+1} \neq 0$ but show they're nonnegative and bounded — they then appear as additional positive function-value terms summed against the telescope. Set:
$$\theta_t = \frac{T-t+1}{T-t+1 + A/(-B)} \theta_{t-1}, \quad \theta_{-1} = 1$$
analogous to Garrigos but with $a/b \to A/(-B)$. Wait — but $b = -1$ in Garrigos, and we have a "compound" $b$ structure. The right substitution is $a \to A$ (the coefficient on $r_t$) and $b \to -B - C$ (or similar — needs careful calculation).

Actually the cleanest path: rewrite the descent so it's of the form
$$\mathbb{E}[a f(y_t) + b f(z_t) + c \inf f] \leq \text{quadratic gap} + v$$

To absorb $-B r_{t-1}$, use **convexity in time**: $r_{t-1} \leq r_t + L \|y_{t-1} - y_t\| \cdot D + ...$. Or shift: define $\tilde r_t := r_t - \alpha r_{t-1}$ for some $\alpha$ and find a recursion.

**Cleanest approach (route G1'):**  Use $\langle \nabla f(y_t), y_t - y_{t-1}\rangle \leq f(y_t) - f(y_{t-1}) + (L/2)\|y_t - y_{t-1}\|^2$ (smoothness of $f$ at $y_{t-1}$), giving an upper bound on $-2\eta' a\langle \nabla f(y_t), y_t-y_{t-1}\rangle$ instead of using convexity. This gives:

$$-2\eta'\langle \nabla f(y_t), w_t - y_t\rangle = -2\eta' a\langle \nabla f(y_t), y_t - y_{t-1}\rangle$$

We want a clean **upper bound** on this. Use Young: 
$$|2\eta' a\langle \nabla f(y_t), y_t - y_{t-1}\rangle| \leq \eta' a (\mu \|\nabla f(y_t)\|^2 + \mu^{-1}\|y_t - y_{t-1}\|^2)$$

By smoothness, $\|\nabla f(y_t)\|^2 \leq 2L r_t$. So:
$$-2\eta' a \langle \cdot, \cdot\rangle \leq 2\eta' a \mu L r_t + (\eta' a / \mu)\|y_t - y_{t-1}\|^2.$$

Then we need to absorb $(\eta' a /\mu) \|y_t - y_{t-1}\|^2$ via a Lyapunov.

This is the path. Let me formalize via a Lyapunov function next.
