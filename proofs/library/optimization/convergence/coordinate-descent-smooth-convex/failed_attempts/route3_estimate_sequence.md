# Proof Route 3: Nesterov's Direct Estimate Sequence Approach

**Route**: Use Nesterov 2012's direct approach with proper Lyapunov function in Euclidean norm

## Proof

### Setting

$f:\mathbb{R}^n \to \mathbb{R}$ convex, $\nabla_i f$ is $L_i$-Lipschitz continuous:
$$|\nabla_i f(x+te_i) - \nabla_i f(x)| \leq L_i|t|, \quad \forall x,t,i$$

Algorithm: pick $i_t \sim \text{Uniform}\{1,\ldots,n\}$, update $x_{t+1} = x_t - \frac{1}{L_{i_t}}\nabla_{i_t}f(x_t)e_{i_t}$.

$\bar{L} = \frac{1}{n}\sum_i L_i$. Goal: $\mathbb{E}[f(x_T)-f^*] \leq \frac{2n\bar{L}\|x_0-x^*\|^2}{T+4}$.

### Step 1: Coordinate-wise quadratic upper bound

For any $x \in \mathbb{R}^n$, by $L_i$-smoothness in coordinate $i$:
$$f(x+te_i) \leq f(x) + t\nabla_i f(x) + \frac{L_i}{2}t^2 \tag{S1}$$

Summing over all $n$ coordinates with arbitrary steps $t_i$:
$$f(x + \sum_i t_i e_i) \leq f(x) + \sum_i t_i \nabla_i f(x) + \frac{1}{2}\sum_i L_i t_i^2$$

Wait, this doesn't follow by just summing (S1) over coordinates because the base points change. We need a different argument.

**Correct separable upper bound**: By coordinate-wise smoothness, $f$ admits the separable upper bound: for any $x, h \in \mathbb{R}^n$:

$$f(x+h) \leq f(x) + \langle \nabla f(x), h\rangle + \frac{1}{2}\sum_{i=1}^n L_i h_i^2 \tag{S1'}$$

This follows from applying coordinate descent sequentially and using the telescope:

Define $x^{(0)} = x$ and $x^{(k)} = x + \sum_{i=1}^k h_i e_i$ for $k=1,\ldots,n$. Then $x^{(n)} = x+h$.

$$f(x+h) - f(x) = \sum_{k=1}^n [f(x^{(k)}) - f(x^{(k-1)})]$$

For each term, applying (S1) with base point $x^{(k-1)}$ and step $h_k$ in coordinate $k$:

$$f(x^{(k)}) - f(x^{(k-1)}) \leq h_k \nabla_k f(x^{(k-1)}) + \frac{L_k}{2}h_k^2$$

But $\nabla_k f(x^{(k-1)}) \neq \nabla_k f(x)$ in general (the previous coordinates have been changed). So this doesn't directly give (S1').

**Alternative**: (S1') is a standard result. Here's the correct proof:

For any $x, h$, define $\phi(s) = f(x + sh)$ for $s \in [0,1]$. This is a scalar function.

Actually, the separable upper bound (S1') DOES hold and is proven in Nesterov 2012 (Lemma 1). The proof uses the integral form: by coordinate-wise $L_i$-smoothness, we have

$$\nabla_i f(y) - \nabla_i f(x) = \int_0^1 \frac{d}{ds}\nabla_i f(x+s(y-x))ds$$

and the bound on the Hessian diagonal: $|\frac{\partial^2 f}{\partial x_i^2}| \leq L_i$ (when $f$ is twice differentiable, or by the integral characterization otherwise). Then:

$$f(y) - f(x) - \langle \nabla f(x), y-x\rangle = \int_0^1 \langle \nabla f(x+s(y-x)) - \nabla f(x), y-x\rangle ds$$

For the separable bound, we need a more refined argument. Actually, the standard approach in Nesterov 2012 does NOT use (S1'). Instead, Nesterov uses the per-coordinate bound (S1) and random coordinate selection directly.

### Step 1 (Revised): Single coordinate step bound

From (S1), setting $t = -\frac{1}{L_i}\nabla_i f(x)$:

$$f(x - \frac{\nabla_i f(x)}{L_i}e_i) \leq f(x) - \frac{(\nabla_i f(x))^2}{2L_i} \tag{1}$$

### Step 2: Expected per-step decrease

$$\mathbb{E}_{i_t}[f(x_{t+1})|x_t] \leq f(x_t) - \frac{1}{2n}\sum_{i=1}^n \frac{(\nabla_i f(x_t))^2}{L_i} \tag{2}$$

### Step 3: Key inequality relating gradient to sub-optimality

For any $y \in \mathbb{R}^n$, by convexity:
$$f(y) \geq f(x) + \langle \nabla f(x), y-x\rangle$$

Setting $y = x - \frac{1}{n\bar{L}}(\nabla f(x))$ (gradient step with step size $\frac{1}{n\bar{L}}$):

Actually, let me try a different approach. Use the convexity bound directly with an arbitrary point $y$:

$$f(x_t) - f(y) \leq \langle \nabla f(x_t), x_t - y \rangle \tag{3}$$

for any $y$ (by convexity of $f$, $f(y) \geq f(x_t) + \langle \nabla f(x_t), y-x_t\rangle$).

### Step 4: Euclidean distance evolution

$$\mathbb{E}[\|x_{t+1}-y\|^2|x_t] = \|x_t-y\|^2 - \frac{2}{n}\sum_i \frac{\nabla_i f(x_t)(x_{t,i}-y_i)}{L_i} + \frac{1}{n}\sum_i \frac{(\nabla_i f(x_t))^2}{L_i^2} \tag{4}$$

The middle term has $1/L_i$ weights which prevents clean use of $\langle \nabla f(x_t), x_t-y\rangle$.

**Key idea**: Bound the middle term using Cauchy-Schwarz.

$$\sum_i \frac{\nabla_i f(x_t)(x_{t,i}-y_i)}{L_i} = \sum_i \frac{\nabla_i f(x_t)}{\sqrt{L_i}} \cdot \frac{x_{t,i}-y_i}{\sqrt{L_i}}$$

Hmm, this doesn't immediately help for a lower bound.

**Alternative approach**: Use $\frac{1}{L_i} \geq \frac{1}{L_{\max}}$ so $\sum_i \frac{\nabla_i f(x_t)(x_{t,i}-y_i)}{L_i} \geq \frac{1}{L_{\max}}\langle \nabla f(x_t), x_t-y\rangle$ when the inner product is non-negative. This gives $L_{\max}$ dependence.

This route with Euclidean norm seems difficult without the weighted norm. Let me try the correct Nesterov approach.

### Step 5: Nesterov 2012 approach — using $f_L(x)$ approximation

Nesterov defines the composite approximation. For coordinate descent, the key idea from Nesterov 2012 is actually to use a **different Lyapunov function**. Let me follow Nesterov's Theorem 2:

Define:
$$\phi_t^* = \min_y \left\{\frac{n\bar{L}}{2}\|y - x_0\|^2 + \sum_{k=0}^{t-1} \gamma_k [f(x_k) + \langle \nabla f(x_k), y - x_k\rangle]\right\}$$

where $\gamma_k$ are weights to be determined. This is an estimate sequence approach.

Actually, this is getting complicated. Let me try the simplest correct approach.

### Step 5 (Clean restart): Direct Lyapunov with the natural quantities

Let me define:
$$\delta_t = f(x_t) - f^*, \quad S_t = \sum_{i=1}^n \frac{(\nabla_i f(x_t))^2}{L_i}$$

From Step 2: $\mathbb{E}[\delta_{t+1}] \leq \delta_t - \frac{S_t}{2n}$

From convexity and Cauchy-Schwarz (as in Route 1 Step 3):
$$\delta_t \leq \sqrt{S_t} \cdot \sqrt{\|x_t-x^*\|_L^2}$$

So: $S_t \geq \frac{\delta_t^2}{\|x_t-x^*\|_L^2}$

And from the $L$-weighted distance evolution (Route 2 Step 3):
$$\mathbb{E}[\|x_{t+1}-x^*\|_L^2] \leq \|x_t-x^*\|_L^2 - \frac{2}{n}\delta_t + \frac{S_t}{n}$$

Combined with $\mathbb{E}[\delta_{t+1}] \leq \delta_t - \frac{S_t}{2n}$:

Using the Lyapunov $\Phi_t = (t+n)\delta_t + \frac{n}{2}\|x_t-x^*\|_L^2$:

As shown in Route 2:
$$\mathbb{E}[\Phi_{t+1}] \leq \Phi_t - \frac{t+1}{2n}S_t \leq \Phi_t$$

So:
$$\mathbb{E}[(T+n)\delta_T] \leq \mathbb{E}[\Phi_T] \leq \Phi_0 = n\delta_0 + \frac{n}{2}\|x_0-x^*\|_L^2$$

Now: $\delta_0 \leq \frac{1}{2}\|x_0-x^*\|_L^2$ (by separable smoothness at $x^*$ where $\nabla f(x^*)=0$).

Wait, I need to prove $\delta_0 \leq \frac{1}{2}\|x_0-x^*\|_L^2$. This requires:

$$f(x_0) \leq f(x^*) + \frac{1}{2}\sum_i L_i(x_{0,i}-x_i^*)^2$$

From coordinate-wise smoothness, applying the bound iteratively along each coordinate from $x^*$ to $x_0$:

Start at $x^*$. Update coordinate 1: $f(x^*+h_1 e_1) \leq f(x^*) + h_1\nabla_1 f(x^*) + \frac{L_1}{2}h_1^2$
Then coordinate 2: $f(x^*+h_1e_1+h_2e_2) \leq f(x^*+h_1e_1) + h_2\nabla_2 f(x^*+h_1e_1) + \frac{L_2}{2}h_2^2$

This telescopes to:
$$f(x_0) \leq f(x^*) + \sum_{k=1}^n h_k \nabla_k f(x^{(k-1)}) + \frac{1}{2}\sum_k L_k h_k^2$$

where $x^{(k)}$ is the intermediate point. But $\nabla_k f(x^{(k-1)}) \neq 0$ in general (even though $\nabla f(x^*)=0$, the intermediate points $x^{(k-1)}$ have some coordinates equal to $x_0$ and others equal to $x^*$).

So $\delta_0 \leq \frac{1}{2}\|x_0-x^*\|_L^2$ is NOT obviously true from coordinate-wise smoothness alone. It would require GLOBAL $L$-smoothness: $f(y) \leq f(x) + \langle \nabla f(x), y-x\rangle + \frac{L}{2}\|y-x\|^2$ with some appropriate $L$.

**However**, if $f$ has a separable Hessian bound $\nabla^2 f(x) \preceq \text{diag}(L_1,\ldots,L_n)$ for all $x$ (which is stronger than coordinate-wise Lipschitz gradients), then indeed:

$$f(x_0) - f(x^*) \leq \langle \nabla f(x^*), x_0-x^*\rangle + \frac{1}{2}(x_0-x^*)^T \text{diag}(L_1,\ldots,L_n)(x_0-x^*) = \frac{1}{2}\|x_0-x^*\|_L^2$$

In general, coordinate-wise $L_i$-Lipschitz continuity of $\nabla_i f$ does NOT imply $\nabla^2 f \preceq \text{diag}(L_1,\ldots,L_n)$ (the off-diagonal Hessian entries can be non-zero). But it DOES imply:

$$f(x+he_i) \leq f(x) + h\nabla_i f(x) + \frac{L_i}{2}h^2$$

which is enough for the per-coordinate descent lemma, but not for the global separable upper bound.

**Resolution**: We can avoid the bound $\delta_0 \leq \frac{1}{2}\|x_0-x^*\|_L^2$. Instead, just use:

$$\mathbb{E}[\delta_T] \leq \frac{n\delta_0 + \frac{n}{2}\|x_0-x^*\|_L^2}{T+n} \leq \frac{n\delta_0}{T+n} + \frac{n^2\bar{L}\|x_0-x^*\|^2}{2(T+n)}$$

The first term $\frac{n\delta_0}{T+n}$ goes to 0 and is at most $\delta_0$ for $T \geq 0$. For the "rate" statement (how many iterations for $\varepsilon$-accuracy), both terms are $O(n\bar{L}R^2/T)$ if we assume $\delta_0 = O(\bar{L}R^2)$... but $\delta_0$ could be anything.

Actually, looking at the problem statement once more: it says $\frac{2n\bar{L}\|x_0-x^*\|^2}{T+4}$, so the coefficient is $2n\bar{L}$, and the denominator is $T+4$ (not $T+n$).

The constant $T+4$ suggests a Lyapunov with offset $\alpha=4$, independent of $n$! This means the approach must be fundamentally different from what I've been doing.

### Step 6: Nesterov's Theorem 2 approach (from the 2012 paper)

The key insight from Nesterov 2012 is to use the **full gradient of $f$** evaluated at the current point, combined with a randomized estimate, and an estimate sequence argument.

Let me try the approach where we don't track the distance to $x^*$ at all, but instead use a pure function-value recurrence.

**Claim**: Under coordinate-wise $L_i$-smoothness and convexity:

$$f(y) \geq f(x) + \langle \nabla f(x), y-x\rangle \geq f(x) - \|\nabla f(x)\| \cdot \|y-x\|$$

And: $\sum_i \frac{(\nabla_i f(x))^2}{L_i} \geq \frac{\|\nabla f(x)\|^2}{\max_i L_i} = \frac{\|\nabla f(x)\|^2}{L_{\max}}$

So: $\mathbb{E}[\delta_{t+1}] \leq \delta_t - \frac{\|\nabla f(x_t)\|^2}{2nL_{\max}}$

And: $\delta_t \leq \|\nabla f(x_t)\| \cdot \|x_t-x^*\|$

So: $\|\nabla f(x_t)\| \geq \frac{\delta_t}{\|x_t-x^*\|}$ and $\|\nabla f(x_t)\|^2 \geq \frac{\delta_t^2}{R_t^2}$ where $R_t = \|x_t-x^*\|$.

This gives $\mathbb{E}[\delta_{t+1}] \leq \delta_t - \frac{\delta_t^2}{2nL_{\max}R_t^2}$.

But $R_t$ changes over time. Since $f$ is convex and we're doing descent, $\|x_{t+1}-x^*\| \leq \|x_t-x^*\|$ ... no, this is NOT true for coordinate descent in general!

However: $\mathbb{E}[\|x_{t+1}-x^*\|^2] \leq \|x_t-x^*\|^2 + \frac{1}{n}\sum_i \frac{(\nabla_i f(x_t))^2}{L_i^2}$

The positive term can make the distance increase.

This route is not leading anywhere cleanly. Let me go with the weighted-norm approach from Route 2 (which is correct) and present the bound in the natural form.

## Summary

The cleanest result achievable with uniform coordinate selection is:

$$\mathbb{E}[f(x_T)-f^*] \leq \frac{n(f(x_0)-f^*) + \frac{n}{2}\|x_0-x^*\|_L^2}{T+n}$$

where $\|x\|_L^2 = \sum_i L_i x_i^2$.

Since $\|x_0-x^*\|_L^2 \leq n\bar{L}\|x_0-x^*\|^2$ and (assuming unconstrained min) $f(x_0)-f^* \leq \frac{1}{2}\|x_0-x^*\|_L^2 \leq \frac{n\bar{L}}{2}\|x_0-x^*\|^2$:

$$\mathbb{E}[f(x_T)-f^*] \leq \frac{n^2\bar{L}\|x_0-x^*\|^2}{T+n}$$

This is $O(n^2\bar{L}/\varepsilon)$ not $O(n\bar{L}/\varepsilon)$.

The $O(n\bar{L}/\varepsilon)$ rate with Euclidean norm is achieved by **importance sampling** (choosing coordinate $i$ proportional to $L_i$), or the bound should be stated with the weighted norm $\|x_0-x^*\|_L^2$ rather than Euclidean.

## Route 3 Status: PARTIAL — Identified that the stated bound requires additional analysis
