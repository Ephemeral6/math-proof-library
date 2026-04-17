# GD with Polyak-Lojasiewicz: Exact Linear Convergence — Proof

**Setup.** Let $f: \mathbb{R}^d \to \mathbb{R}$ be $L$-smooth, meaning $\nabla f$ is $L$-Lipschitz continuous:

$$\|\nabla f(x) - \nabla f(y)\| \leq L\|x - y\| \quad \forall x, y \in \mathbb{R}^d$$

and let $f$ satisfy the $\mu$-PL condition:

$$\frac{1}{2}\|\nabla f(x)\|^2 \geq \mu(f(x) - f^*) \quad \forall x \in \mathbb{R}^d$$

where $f^* = \inf_x f(x)$ and $0 < \mu \leq L$. Consider gradient descent with step size $\eta = 1/L$:

$$x_{k+1} = x_k - \frac{1}{L}\nabla f(x_k)$$

---

**Step 1: Descent Lemma from $L$-smoothness.**

Since $f$ is $L$-smooth, for any $x, y \in \mathbb{R}^d$:

$$f(y) \leq f(x) + \langle \nabla f(x), y - x \rangle + \frac{L}{2}\|y - x\|^2$$

*Proof*: By the fundamental theorem of calculus:

$$f(y) = f(x) + \int_0^1 \langle \nabla f(x + t(y-x)), y-x \rangle \, dt$$

$$= f(x) + \langle \nabla f(x), y-x \rangle + \int_0^1 \langle \nabla f(x + t(y-x)) - \nabla f(x), y-x \rangle \, dt$$

By Cauchy-Schwarz and $L$-Lipschitz continuity of $\nabla f$:

$$\left|\int_0^1 \langle \nabla f(x + t(y-x)) - \nabla f(x), y-x \rangle \, dt\right| \leq \int_0^1 Lt\|y-x\|^2 \, dt = \frac{L}{2}\|y-x\|^2$$

Note: This uses only $L$-smoothness, not convexity. $\square$

---

**Step 2: Apply to the GD iterate.**

Set $x = x_k$ and $y = x_{k+1} = x_k - \frac{1}{L}\nabla f(x_k)$, so $y - x = -\frac{1}{L}\nabla f(x_k)$:

$$f(x_{k+1}) \leq f(x_k) + \left\langle \nabla f(x_k), -\frac{1}{L}\nabla f(x_k) \right\rangle + \frac{L}{2}\left\|\frac{1}{L}\nabla f(x_k)\right\|^2$$

$$= f(x_k) - \frac{1}{L}\|\nabla f(x_k)\|^2 + \frac{1}{2L}\|\nabla f(x_k)\|^2 = f(x_k) - \frac{1}{2L}\|\nabla f(x_k)\|^2 \tag{Descent}$$

---

**Step 3: Apply the PL inequality.**

By the $\mu$-PL condition: $\|\nabla f(x_k)\|^2 \geq 2\mu(f(x_k) - f^*)$

Substituting into (Descent):

$$f(x_{k+1}) \leq f(x_k) - \frac{1}{2L} \cdot 2\mu(f(x_k) - f^*) = f(x_k) - \frac{\mu}{L}(f(x_k) - f^*)$$

Subtracting $f^*$ from both sides:

$$f(x_{k+1}) - f^* \leq f(x_k) - f^* - \frac{\mu}{L}(f(x_k) - f^*) = \left(1 - \frac{\mu}{L}\right)(f(x_k) - f^*) \tag{Contraction}$$

Since $0 < \mu \leq L$, we have $0 \leq 1 - \mu/L < 1$.

---

**Step 4: Iterate to get geometric convergence.**

Applying (Contraction) recursively from $k-1$ down to $0$:

$$f(x_k) - f^* \leq \left(1 - \frac{\mu}{L}\right)(f(x_{k-1}) - f^*) \leq \cdots \leq \left(1 - \frac{\mu}{L}\right)^k (f(x_0) - f^*)$$

$$\boxed{f(x_k) - f^* \leq \left(1 - \frac{\mu}{L}\right)^k (f(x_0) - f^*)}$$

This establishes exact linear convergence at rate $(1 - \mu/L)$ per step. $\blacksquare$

---

**Remark 1 (No convexity).** The proof uses only two properties: (i) $L$-smoothness for the descent lemma, and (ii) the PL condition for gradient lower-bounding. Neither step invokes convexity.

**Remark 2 (Iteration complexity).** To achieve $f(x_k) - f^* \leq \epsilon$, we need $k \geq \frac{L}{\mu}\ln\frac{f(x_0) - f^*}{\epsilon}$, giving $O(\kappa \log(1/\epsilon))$ complexity where $\kappa = L/\mu$.
