# Proximal Point Method: Convergence Rate via Firm Nonexpansiveness

## Setting

Let $T: \mathbb{R}^d \rightrightarrows \mathbb{R}^d$ be a maximal monotone operator, $\eta > 0$, and $T^{-1}(0) \neq \emptyset$. Let $x^* \in T^{-1}(0)$. The proximal point iteration is:
$$x_{k+1} = J_{\eta T}(x_k) = (I + \eta T)^{-1}(x_k)$$

## Theorem

**(a) Fejér monotonicity**: $\|x_{k+1} - x^*\| \leq \|x_k - x^*\|$ for all $k \geq 0$.

**(b) Residual rate**: $\min_{0 \leq j \leq k} \|x_j - x_{j+1}\| \leq \frac{\|x_0 - x^*\|}{\sqrt{k+1}}$.

In particular, $\min_{0 \leq j \leq k} \operatorname{dist}(0, T(x_{j+1})) \leq \frac{\|x_0 - x^*\|}{\eta\sqrt{k+1}}$.

**(c) Function value rate** (when $T = \partial f$ for convex $f$): $f(x_k) - f(x^*) \leq \frac{\|x_0 - x^*\|^2}{2\eta k}$.

---

## Proof

### Step 1: The resolvent $J_{\eta T}$ is firmly nonexpansive

**Claim**: For all $x, y \in \mathbb{R}^d$:
$$\|J_{\eta T}(x) - J_{\eta T}(y)\|^2 + \|(I - J_{\eta T})(x) - (I - J_{\eta T})(y)\|^2 \leq \|x - y\|^2$$

**Proof**: Let $p = J_{\eta T}(x)$ and $q = J_{\eta T}(y)$. By definition of the resolvent, there exist $u \in T(p)$ and $v \in T(q)$ such that:
$$x = p + \eta u, \quad y = q + \eta v$$

Expanding:
$$\|x - y\|^2 = \|(p - q) + \eta(u - v)\|^2 = \|p - q\|^2 + 2\eta\langle u - v, p - q\rangle + \eta^2\|u - v\|^2$$

Since $T$ is monotone: $\langle u - v, p - q\rangle \geq 0$. Therefore:
$$\|x - y\|^2 \geq \|p - q\|^2 + \eta^2\|u - v\|^2 = \|J_{\eta T}(x) - J_{\eta T}(y)\|^2 + \|(I - J_{\eta T})(x) - (I - J_{\eta T})(y)\|^2$$

where the last equality uses $(I - J_{\eta T})(x) - (I - J_{\eta T})(y) = (x-p) - (y-q) = \eta(u - v)$. $\square$

### Step 2: $x^*$ is a fixed point of $J_{\eta T}$

Since $0 \in T(x^*)$, we have $x^* = x^* + \eta \cdot 0 \in (I + \eta T)(x^*)$, so $x^* = J_{\eta T}(x^*)$. $\square$

### Step 3: Per-step descent inequality — proves part (a)

Apply Step 1 with $y = x^*$ and $J_{\eta T}(x^*) = x^*$:
$$\|x_{k+1} - x^*\|^2 + \|x_k - x_{k+1}\|^2 \leq \|x_k - x^*\|^2 \quad \quad (\star)$$

In particular, $\|x_{k+1} - x^*\| \leq \|x_k - x^*\|$ (Fejér monotonicity). $\square$

### Step 4: Telescoping and pigeonhole — proves part (b)

Denote $d_k = \|x_k - x^*\|^2$ and $r_k = \|x_k - x_{k+1}\|^2$. From $(\star)$: $r_k \leq d_k - d_{k+1}$.

Summing from $k = 0$ to $K$:
$$\sum_{k=0}^{K} r_k \leq d_0 - d_{K+1} \leq d_0 = \|x_0 - x^*\|^2$$

By the pigeonhole principle: $(K+1) \cdot \min_{0 \leq k \leq K} r_k \leq \|x_0 - x^*\|^2$.

Taking square roots:
$$\min_{0 \leq k \leq K} \|x_k - x_{k+1}\| \leq \frac{\|x_0 - x^*\|}{\sqrt{K+1}}$$

Since $x_k = x_{k+1} + \eta u_k$ with $u_k \in T(x_{k+1})$, we have $\|x_k - x_{k+1}\| = \eta\|u_k\| \geq \eta \cdot \operatorname{dist}(0, T(x_{k+1}))$, giving:
$$\min_{0 \leq k \leq K} \operatorname{dist}(0, T(x_{k+1})) \leq \frac{\|x_0 - x^*\|}{\eta\sqrt{K+1}} \quad \square$$

### Step 5: Function value rate — proves part (c)

Assume $T = \partial f$ for a proper closed convex function $f$. The proximal optimality condition gives $\frac{1}{\eta}(x_k - x_{k+1}) \in \partial f(x_{k+1})$.

By convexity, for $y = x^*$:
$$f(x^*) \geq f(x_{k+1}) + \frac{1}{\eta}\langle x_k - x_{k+1}, x^* - x_{k+1}\rangle$$

Using the three-point identity $2\langle a - b, c - b\rangle = \|a - c\|^2 - \|a - b\|^2 - \|b - c\|^2$ with $a = x_k$, $b = x_{k+1}$, $c = x^*$:

$$f(x_{k+1}) - f(x^*) \leq \frac{1}{\eta}\langle x_k - x_{k+1}, x_{k+1} - x^*\rangle = \frac{1}{2\eta}\left(d_k - r_k - d_{k+1}\right) \leq \frac{d_k - d_{k+1}}{2\eta}$$

Since $f(x_{k+1}) \leq f(x_k)$ (by the proximal minimization: $f(x_{k+1}) + \frac{1}{2\eta}\|x_{k+1}-x_k\|^2 \leq f(x_k)$), the sequence $f(x_k) - f(x^*)$ is non-increasing.

Summing from $k = 0$ to $K-1$ and using monotonicity:
$$K(f(x_K) - f(x^*)) \leq \sum_{k=0}^{K-1}(f(x_{k+1}) - f(x^*)) \leq \frac{d_0 - d_K}{2\eta} \leq \frac{\|x_0 - x^*\|^2}{2\eta}$$

Therefore: $f(x_K) - f(x^*) \leq \frac{\|x_0 - x^*\|^2}{2\eta K}$. $\square$

---

## Counterexample for the distance rate

The bound $\|x_k - x^*\| \leq \|x_0 - x^*\|/\sqrt{k+1}$ is **false** in general.

**Counterexample**: Let $f(x) = |x|$ on $\mathbb{R}$ (so $T = \partial|{\cdot}|$), $\eta = 0.1$, $x_0 = 10$, $x^* = 0$. Then $x_{k+1} = \text{sign}(x_k)\max(|x_k| - \eta, 0)$, giving $x_k = 10 - 0.1k$ for $k \leq 100$. At $k = 10$: $|x_{10}| = 9.0$ but $10/\sqrt{11} \approx 3.02$. The distance bound is violated by a factor of 3.

Q.E.D.
