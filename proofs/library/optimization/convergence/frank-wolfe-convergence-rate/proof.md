# Frank-Wolfe (Conditional Gradient) O(1/k) Convergence Rate

## Proof

**Setup.** Let $f$ be convex and $L$-smooth on $\mathbb{R}^d$, $\mathcal{D} \subset \mathbb{R}^d$ compact convex with diameter $D$, $x^* \in \arg\min_{\mathcal{D}} f$. Define $h_t = f(x_t) - f(x^*)$.

The Frank-Wolfe iterates are:
$$s_t = \arg\min_{s \in \mathcal{D}} \langle \nabla f(x_t), s \rangle, \quad x_{t+1} = x_t + \gamma_t(s_t - x_t), \quad \gamma_t = \frac{2}{t+2}.$$

---

**Step 1: Derive the fundamental recurrence.**

By $L$-smoothness (descent lemma): for any $x, y$,

$$f(y) \leq f(x) + \langle \nabla f(x), y - x \rangle + \frac{L}{2}\|y - x\|^2.$$

Apply with $x = x_t$, $y = x_{t+1} = x_t + \gamma_t(s_t - x_t)$:

$$f(x_{t+1}) \leq f(x_t) + \gamma_t \langle \nabla f(x_t), s_t - x_t \rangle + \frac{L\gamma_t^2}{2}\|s_t - x_t\|^2.$$

Since $s_t, x_t \in \mathcal{D}$ and $\text{diam}(\mathcal{D}) \leq D$, we have $\|s_t - x_t\| \leq D$:

$$f(x_{t+1}) \leq f(x_t) + \gamma_t \langle \nabla f(x_t), s_t - x_t \rangle + \frac{L\gamma_t^2 D^2}{2}. \tag{A}$$

By the linear minimization property, $\langle \nabla f(x_t), s_t \rangle \leq \langle \nabla f(x_t), x^* \rangle$, so:

$$\langle \nabla f(x_t), s_t - x_t \rangle \leq \langle \nabla f(x_t), x^* - x_t \rangle.$$

By convexity of $f$ (first-order characterization), $f(x^*) \geq f(x_t) + \langle \nabla f(x_t), x^* - x_t \rangle$, hence:

$$\langle \nabla f(x_t), x^* - x_t \rangle \leq f(x^*) - f(x_t) = -h_t.$$

Combining:

$$\langle \nabla f(x_t), s_t - x_t \rangle \leq -h_t. \tag{B}$$

Substituting (B) into (A) and subtracting $f(x^*)$ from both sides:

$$h_{t+1} \leq (1 - \gamma_t) h_t + \frac{L\gamma_t^2 D^2}{2}. \tag{R}$$

---

**Step 2: Verify the ansatz $h_t \leq \frac{2LD^2}{t+2}$.**

Define $\bar{h}_t = \frac{2LD^2}{t+2}$. Assuming $h_t \leq \bar{h}_t$ and substituting $\gamma_t = \frac{2}{t+2}$ into (R):

$$h_{t+1} \leq \left(1 - \frac{2}{t+2}\right) \frac{2LD^2}{t+2} + \frac{L}{2} \cdot \frac{4D^2}{(t+2)^2}$$

$$= \frac{2LD^2}{t+2} \cdot \frac{t}{t+2} + \frac{2LD^2}{(t+2)^2}$$

$$= \frac{2LD^2}{(t+2)^2}(t + 1).$$

We need this to be at most $\bar{h}_{t+1} = \frac{2LD^2}{t+3}$, equivalently:

$$(t+1)(t+3) \leq (t+2)^2.$$

Expanding: $t^2 + 4t + 3 \leq t^2 + 4t + 4$, i.e., $3 \leq 4$. $\checkmark$

---

**Step 3: Base case.**

At $t = 0$: $\gamma_0 = \frac{2}{0+2} = 1$, so $x_1 = s_0$. From recurrence (R):

$$h_1 \leq (1 - 1) \cdot h_0 + \frac{L \cdot 1^2 \cdot D^2}{2} = \frac{LD^2}{2}.$$

The ansatz requires $h_1 \leq \bar{h}_1 = \frac{2LD^2}{3}$. Since $\frac{1}{2} \leq \frac{2}{3}$, this holds. $\checkmark$

---

**Step 4: Conclusion.**

By Step 3, $h_1 \leq \bar{h}_1$. By Step 2, $h_t \leq \bar{h}_t \Rightarrow h_{t+1} \leq \bar{h}_{t+1}$. By induction:

$$\boxed{f(x_t) - f(x^*) \leq \frac{2LD^2}{t+2}, \qquad \forall\, t \geq 1.}$$

This establishes the $O(1/t)$ convergence rate of the Frank-Wolfe algorithm. To achieve $f(x_t) - f(x^*) \leq \varepsilon$, it suffices to run $t \geq \frac{2LD^2}{\varepsilon} - 2 = O\!\left(\frac{LD^2}{\varepsilon}\right)$ iterations.

$\blacksquare$
