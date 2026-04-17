# Nesterov's Accelerated Gradient Descent: O(1/k²) Convergence

## Setup and Notation

Let $f: \mathbb{R}^d \to \mathbb{R}$ be convex with $L$-Lipschitz continuous gradient. That is, for all $x, y \in \mathbb{R}^d$:

**(S1)** $f(x) \leq f(y) + \langle\nabla f(y), x - y\rangle + \frac{L}{2}\|x - y\|^2$  (L-smoothness / descent lemma)

**(S2)** $f(x) \geq f(y) + \langle\nabla f(y), x - y\rangle$  (convexity)

Let $x^*$ be a minimizer of $f$, $f^* = f(x^*)$.

## Algorithm (Three-Sequence Form)

Define the following iteration with arbitrary $x_0 \in \mathbb{R}^d$:

$$z_0 = x_0$$

For $k = 0, 1, 2, \ldots$:
$$y_k = \frac{k}{k+2}\,x_k + \frac{2}{k+2}\,z_k$$
$$x_{k+1} = y_k - \frac{1}{L}\nabla f(y_k)$$
$$z_{k+1} = z_k - \frac{k+1}{2L}\nabla f(y_k)$$

**Remark.** This three-sequence formulation is equivalent to Nesterov's momentum form $y_k = x_k + \frac{k}{k+2}(x_k - x_{k-1})$, $x_{k+1} = y_k - \frac{1}{L}\nabla f(y_k)$ up to an index shift. Both are standard forms of the accelerated gradient method.

**Theorem.** For all $k \geq 1$:
$$f(x_k) - f^* \leq \frac{2L\|x_0 - x^*\|^2}{k(k+1)} \leq \frac{2L\|x_0 - x^*\|^2}{k^2}$$

In particular, $f(x_k) - f^* = O(L\|x_0 - x^*\|^2 / k^2)$.

## Proof

### Step 1: Define the Lyapunov Function

Define for $k \geq 0$:
$$V_k = k(k+1)\bigl(f(x_k) - f^*\bigr) + 2L\|z_k - x^*\|^2$$

**Goal**: Show $V_{k+1} \leq V_k$ for all $k \geq 0$.

### Step 2: Descent Lemma for $f(x_{k+1})$

By (S1) with $x = x_{k+1} = y_k - \frac{1}{L}\nabla f(y_k)$ and $y = y_k$:

$$f(x_{k+1}) \leq f(y_k) + \langle\nabla f(y_k), -\frac{1}{L}\nabla f(y_k)\rangle + \frac{L}{2}\cdot\frac{1}{L^2}\|\nabla f(y_k)\|^2$$

$$= f(y_k) - \frac{1}{2L}\|\nabla f(y_k)\|^2 \tag{1}$$

### Step 3: Bound $f(y_k) - f^*$ via Convex Combination

By convexity (S2) at the point $y_k$:
- With $x = x_k$: $\quad f(y_k) \leq f(x_k) + \langle\nabla f(y_k), y_k - x_k\rangle$
- With $x = x^*$: $\quad f(y_k) \leq f^* + \langle\nabla f(y_k), y_k - x^*\rangle$

Since the weights $\frac{k}{k+2}$ and $\frac{2}{k+2}$ sum to 1 (with $k \geq 0$), take the convex combination:

$$f(y_k) \leq \frac{k}{k+2}\Bigl[f(x_k) + \langle\nabla f(y_k), y_k - x_k\rangle\Bigr] + \frac{2}{k+2}\Bigl[f^* + \langle\nabla f(y_k), y_k - x^*\rangle\Bigr]$$

$$= \frac{k}{k+2}f(x_k) + \frac{2}{k+2}f^* + \left\langle\nabla f(y_k),\; y_k - \frac{k}{k+2}x_k - \frac{2}{k+2}x^*\right\rangle$$

Since $y_k = \frac{k}{k+2}x_k + \frac{2}{k+2}z_k$, the inner product argument simplifies:

$$y_k - \frac{k}{k+2}x_k - \frac{2}{k+2}x^* = \frac{2}{k+2}(z_k - x^*)$$

Therefore, subtracting $f^*$:
$$f(y_k) - f^* \leq \frac{k}{k+2}(f(x_k) - f^*) + \frac{2}{k+2}\langle\nabla f(y_k), z_k - x^*\rangle \tag{2}$$

### Step 4: Upper Bound on $(k+1)(k+2)(f(x_{k+1}) - f^*)$

Combining (1) and (2):

$$(k+1)(k+2)(f(x_{k+1}) - f^*) \leq (k+1)(k+2)\left[\frac{k}{k+2}(f(x_k) - f^*) + \frac{2}{k+2}\langle\nabla f(y_k), z_k - x^*\rangle - \frac{1}{2L}\|\nabla f(y_k)\|^2\right]$$

$$= k(k+1)(f(x_k) - f^*) + 2(k+1)\langle\nabla f(y_k), z_k - x^*\rangle - \frac{(k+1)(k+2)}{2L}\|\nabla f(y_k)\|^2 \tag{3}$$

### Step 5: Expand $\|z_{k+1} - x^*\|^2$

From $z_{k+1} = z_k - \frac{k+1}{2L}\nabla f(y_k)$:

$$\|z_{k+1} - x^*\|^2 = \left\|z_k - x^* - \frac{k+1}{2L}\nabla f(y_k)\right\|^2$$

$$= \|z_k - x^*\|^2 - \frac{k+1}{L}\langle\nabla f(y_k), z_k - x^*\rangle + \frac{(k+1)^2}{4L^2}\|\nabla f(y_k)\|^2$$

Multiplying by $2L$:

$$2L\|z_{k+1} - x^*\|^2 = 2L\|z_k - x^*\|^2 - 2(k+1)\langle\nabla f(y_k), z_k - x^*\rangle + \frac{(k+1)^2}{2L}\|\nabla f(y_k)\|^2 \tag{4}$$

### Step 6: Prove $V_{k+1} \leq V_k$

Adding (3) and (4):

$$V_{k+1} = (k+1)(k+2)(f(x_{k+1}) - f^*) + 2L\|z_{k+1} - x^*\|^2$$

$$\leq \Bigl[k(k+1)(f(x_k) - f^*) + 2L\|z_k - x^*\|^2\Bigr]$$
$$\quad + \Bigl[2(k+1) - 2(k+1)\Bigr]\langle\nabla f(y_k), z_k - x^*\rangle$$
$$\quad + \Bigl[\frac{(k+1)^2}{2L} - \frac{(k+1)(k+2)}{2L}\Bigr]\|\nabla f(y_k)\|^2$$

The three groups:
1. **First group** $= V_k$
2. **Inner product terms cancel**: $2(k+1) - 2(k+1) = 0$
3. **Gradient norm coefficient**: $\frac{(k+1)}{2L}\bigl[(k+1) - (k+2)\bigr] = -\frac{k+1}{2L}$

Therefore:
$$\boxed{V_{k+1} \leq V_k - \frac{k+1}{2L}\|\nabla f(y_k)\|^2 \leq V_k} \tag{5}$$

### Step 7: Extract the Convergence Rate

From (5), $V_k \leq V_0$ for all $k$. At $k = 0$:

$$V_0 = 0 \cdot 1 \cdot (f(x_0) - f^*) + 2L\|x_0 - x^*\|^2 = 2L\|x_0 - x^*\|^2$$

Since $V_k = k(k+1)(f(x_k) - f^*) + 2L\|z_k - x^*\|^2 \geq k(k+1)(f(x_k) - f^*)$:

$$k(k+1)(f(x_k) - f^*) \leq 2L\|x_0 - x^*\|^2$$

$$\boxed{f(x_k) - f^* \leq \frac{2L\|x_0 - x^*\|^2}{k(k+1)} \leq \frac{2L\|x_0 - x^*\|^2}{k^2}} \quad \text{for all } k \geq 1$$

This establishes the $O(1/k^2)$ convergence rate, matching (up to constants) the $\Omega(1/k^2)$ lower bound for first-order methods on $L$-smooth convex functions (Nesterov 2004, Theorem 2.1.7). $\blacksquare$
