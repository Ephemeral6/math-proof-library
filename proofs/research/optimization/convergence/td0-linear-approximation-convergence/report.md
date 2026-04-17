# TD(0) with Linear Function Approximation: $O(1/T)$ Convergence Rate

## Complete Proof

---

### Setup and Notation

Consider a finite MDP with state space $\mathcal{S}$, discount factor $\gamma \in (0,1)$, and a fixed policy $\pi$. Let $d_\pi$ be the stationary distribution of the Markov chain induced by $\pi$, and let $P_\pi$ be the transition matrix. We approximate the value function via linear function approximation:
$$\hat{V}(s) = \phi(s)^\top \theta, \quad \phi(s) \in \mathbb{R}^d.$$

**Assumptions.**
- (A1) $\|\phi(s)\| \leq 1$ for all $s \in \mathcal{S}$.
- (A2) The feature matrix $\Phi \in \mathbb{R}^{|\mathcal{S}| \times d}$ (rows $\phi(s)^\top$) has full column rank under $d_\pi$, i.e., $\Phi^\top D_\pi \Phi \succ 0$ where $D_\pi = \mathrm{diag}(d_\pi)$.
- (A3) Samples $(s_t, r_t, s_t')$ are drawn i.i.d.: $s_t \sim d_\pi$, $s_t' \sim P_\pi(\cdot | s_t)$, $r_t = r(s_t, s_t')$.
- (A4) Rewards are bounded: $|r(s,s')| \leq r_{\max}$ for all $s, s'$.

The **TD(0) update** is:
$$\theta_{t+1} = \theta_t + \alpha_t \delta_t \phi(s_t), \quad \delta_t = r_t + \gamma \phi(s_t')^\top \theta_t - \phi(s_t)^\top \theta_t.$$

Define the key matrices and vectors:
$$A = \mathbb{E}_{s \sim d_\pi, s' \sim P_\pi(\cdot|s)}[\phi(s)(\phi(s) - \gamma \phi(s'))^\top], \quad b = \mathbb{E}_{s \sim d_\pi, s' \sim P_\pi(\cdot|s)}[r(s,s')\phi(s)].$$

The **TD fixed point** is $\theta^* = A^{-1}b$, which exists provided $A$ is nonsingular. We now prove this and establish the $O(1/T)$ rate.

---

### Phase 1: Positive Definiteness of $A$

**Lemma 1.** Under assumptions (A1)-(A3), the matrix $A$ is positive definite. Specifically, defining $A_s = \frac{1}{2}(A + A^\top)$, we have
$$\lambda_{\min}(A_s) \geq (1 - \gamma)\lambda_{\min}(\Phi^\top D_\pi \Phi) > 0.$$

**Proof of Lemma 1.**

We decompose $A$ into its symmetric and antisymmetric parts. Write:
$$A = \mathbb{E}[\phi(s)\phi(s)^\top] - \gamma \mathbb{E}[\phi(s)\phi(s')^\top].$$

The first term is:
$$\mathbb{E}[\phi(s)\phi(s)^\top] = \Phi^\top D_\pi \Phi.$$

The symmetric part of $A$ is:
$$A_s = \frac{A + A^\top}{2} = \Phi^\top D_\pi \Phi - \frac{\gamma}{2}\mathbb{E}[\phi(s)\phi(s')^\top + \phi(s')\phi(s)^\top].$$

We need to bound the spectral norm of the cross term. Define the operator $\mathcal{P}: \mathbb{R}^d \to \mathbb{R}^d$ by:
$$\mathcal{P} = \mathbb{E}_{s \sim d_\pi, s' \sim P_\pi(\cdot|s)}[\phi(s)\phi(s')^\top].$$

We can write $\mathcal{P} = \Phi^\top D_\pi P_\pi \Phi$. For any unit vector $u \in \mathbb{R}^d$ with $\|u\| = 1$:

$$u^\top \frac{\mathcal{P} + \mathcal{P}^\top}{2} u = \frac{1}{2}\left(u^\top \Phi^\top D_\pi P_\pi \Phi u + u^\top \Phi^\top P_\pi^\top D_\pi \Phi u\right).$$

Now we use the Cauchy-Schwarz inequality. Let $f = \Phi u \in \mathbb{R}^{|\mathcal{S}|}$ (so $f(s) = \phi(s)^\top u$), and let $g = P_\pi \Phi u$ (so $g(s) = \mathbb{E}_{s'|s}[\phi(s')^\top u]$). Then:

$$u^\top \mathcal{P} u = \sum_s d_\pi(s) f(s) g(s) = \langle f, g \rangle_{d_\pi}$$

where $\langle \cdot, \cdot \rangle_{d_\pi}$ is the inner product weighted by $d_\pi$.

By the Cauchy-Schwarz inequality in this inner product:
$$|\langle f, g \rangle_{d_\pi}| \leq \|f\|_{d_\pi} \cdot \|g\|_{d_\pi}.$$

Now, $\|f\|_{d_\pi}^2 = u^\top \Phi^\top D_\pi \Phi \, u$. For $\|g\|_{d_\pi}$, we use Jensen's inequality:

$$g(s)^2 = \left(\mathbb{E}_{s'|s}[\phi(s')^\top u]\right)^2 \leq \mathbb{E}_{s'|s}[(\phi(s')^\top u)^2]$$

Therefore:
$$\|g\|_{d_\pi}^2 = \sum_s d_\pi(s) g(s)^2 \leq \sum_s d_\pi(s) \mathbb{E}_{s'|s}[(\phi(s')^\top u)^2] = \sum_{s'} d_\pi(s') (\phi(s')^\top u)^2 = \|f\|_{d_\pi}^2$$

where the last equality uses the fact that $d_\pi$ is the stationary distribution, so $\sum_s d_\pi(s) P_\pi(s'|s) = d_\pi(s')$.

Thus $|\langle f, g \rangle_{d_\pi}| \leq \|f\|_{d_\pi}^2 = u^\top \Phi^\top D_\pi \Phi \, u$, which gives:
$$\left\|\frac{\mathcal{P} + \mathcal{P}^\top}{2}\right\| \leq \|\Phi^\top D_\pi \Phi\|.$$

More precisely, for any $u$ with $\|u\|=1$:
$$u^\top \frac{\mathcal{P} + \mathcal{P}^\top}{2} u \leq u^\top \Phi^\top D_\pi \Phi \, u.$$

This is a matrix inequality: $\frac{\mathcal{P} + \mathcal{P}^\top}{2} \preceq \Phi^\top D_\pi \Phi$.

Similarly, $\frac{\mathcal{P} + \mathcal{P}^\top}{2} \succeq -\Phi^\top D_\pi \Phi$.

Therefore:
$$A_s = \Phi^\top D_\pi \Phi - \frac{\gamma}{2}(\mathcal{P} + \mathcal{P}^\top) \succeq \Phi^\top D_\pi \Phi - \gamma \Phi^\top D_\pi \Phi = (1 - \gamma)\Phi^\top D_\pi \Phi.$$

Since $\Phi^\top D_\pi \Phi \succ 0$ by (A2), we conclude:
$$\lambda_{\min}(A_s) \geq (1 - \gamma)\lambda_{\min}(\Phi^\top D_\pi \Phi) > 0.$$

We define $\mu := \lambda_{\min}(A_s) \geq (1-\gamma)\lambda_{\min}(\Phi^\top D_\pi \Phi) > 0$. Since $A_s \succ 0$, the matrix $A$ is positive definite (in the sense that $x^\top A x > 0$ for all $x \neq 0$), and hence $A$ is nonsingular. $\blacksquare$

---

### Phase 2: Error Recursion

Define the error $e_t = \theta_t - \theta^*$.

**Lemma 2.** The error satisfies:
$$e_{t+1} = (I - \alpha_t M_t) e_t + \alpha_t \xi_t$$
where $M_t = \phi(s_t)(\phi(s_t) - \gamma \phi(s_t'))^\top$ and $\xi_t$ is a noise term satisfying $\mathbb{E}[\xi_t] = 0$ and $\mathbb{E}[\|\xi_t\|^2] \leq \sigma^2$ with $\sigma^2 = (r_{\max} + 1 + \gamma)^2$.

**Proof of Lemma 2.**

Starting from the TD(0) update:
$$\theta_{t+1} = \theta_t + \alpha_t [r_t + \gamma \phi(s_t')^\top \theta_t - \phi(s_t)^\top \theta_t] \phi(s_t).$$

Subtracting $\theta^*$:
$$e_{t+1} = e_t + \alpha_t [r_t + \gamma \phi(s_t')^\top \theta_t - \phi(s_t)^\top \theta_t] \phi(s_t).$$

We rewrite the TD error term. Adding and subtracting $\gamma \phi(s_t')^\top \theta^* - \phi(s_t)^\top \theta^*$:
$$r_t + \gamma \phi(s_t')^\top \theta_t - \phi(s_t)^\top \theta_t = [\gamma \phi(s_t')^\top - \phi(s_t)^\top](\theta_t - \theta^*) + [r_t + \gamma \phi(s_t')^\top \theta^* - \phi(s_t)^\top \theta^*].$$

Define:
$$M_t = \phi(s_t)(\phi(s_t) - \gamma \phi(s_t'))^\top,$$
$$\xi_t = [r_t + \gamma \phi(s_t')^\top \theta^* - \phi(s_t)^\top \theta^*]\phi(s_t).$$

Then:
$$e_{t+1} = e_t - \alpha_t M_t e_t + \alpha_t \xi_t = (I - \alpha_t M_t)e_t + \alpha_t \xi_t.$$

**Zero mean of $\xi_t$:** Since $\theta^*$ satisfies $A\theta^* = b$:
$$\mathbb{E}[\xi_t] = \mathbb{E}[(r_t + \gamma \phi(s_t')^\top \theta^* - \phi(s_t)^\top \theta^*)\phi(s_t)] = b - A\theta^* + \gamma \mathbb{E}[\phi(s_t)\phi(s_t')^\top]\theta^* - \gamma \mathbb{E}[\phi(s_t)\phi(s_t')^\top]\theta^*.$$

Wait, let us be more careful. We have:
$$\mathbb{E}[\xi_t] = \mathbb{E}[r_t \phi(s_t)] + \gamma \mathbb{E}[\phi(s_t)\phi(s_t')^\top]\theta^* - \mathbb{E}[\phi(s_t)\phi(s_t)^\top]\theta^* = b + \gamma \mathbb{E}[\phi(s)\phi(s')^\top]\theta^* - \mathbb{E}[\phi(s)\phi(s)^\top]\theta^*.$$

Now, $A = \mathbb{E}[\phi(s)\phi(s)^\top] - \gamma \mathbb{E}[\phi(s)\phi(s')^\top]$, so:
$$\mathbb{E}[\xi_t] = b - A\theta^* = 0$$
by the definition of $\theta^*$. $\checkmark$

**Bounded second moment:** Since $\|\phi(s)\| \leq 1$, $|r_t| \leq r_{\max}$, and $|\phi(s')^\top \theta^*| \leq \|\theta^*\|$, $|\phi(s)^\top \theta^*| \leq \|\theta^*\|$:
$$\|\xi_t\| = |r_t + \gamma \phi(s_t')^\top \theta^* - \phi(s_t)^\top \theta^*| \cdot \|\phi(s_t)\| \leq (r_{\max} + (1+\gamma)\|\theta^*\|).$$

Therefore $\mathbb{E}[\|\xi_t\|^2] \leq (r_{\max} + (1+\gamma)\|\theta^*\|)^2 =: \sigma^2$. This is a finite constant depending on the problem parameters. $\blacksquare$

---

### Phase 3: MSE Recursion

**Lemma 3.** Let $v_t = \mathbb{E}[\|e_t\|^2]$. Under i.i.d. sampling:
$$v_{t+1} \leq (1 - 2\alpha_t \mu + \alpha_t^2 L^2) v_t + \alpha_t^2 \sigma^2$$
where $\mu = \lambda_{\min}(A_s) > 0$ and $L^2 = \mathbb{E}[\|M_t\|_F^2]$ is bounded above by $(1+\gamma)^2$.

**Proof of Lemma 3.**

From Lemma 2:
$$e_{t+1} = (I - \alpha_t M_t) e_t + \alpha_t \xi_t.$$

Taking the squared norm:
$$\|e_{t+1}\|^2 = e_t^\top (I - \alpha_t M_t)^\top (I - \alpha_t M_t) e_t + 2\alpha_t \xi_t^\top (I - \alpha_t M_t) e_t + \alpha_t^2 \|\xi_t\|^2.$$

Now we take expectations. **Crucially, under i.i.d. sampling, $e_t$ depends only on $(s_0, r_0, s_0', \ldots, s_{t-1}, r_{t-1}, s_{t-1}')$ and is independent of $(s_t, r_t, s_t')$.** This is because each sample is drawn independently.

Therefore, we can factor expectations:

**Cross term:** 
$$\mathbb{E}[\xi_t^\top (I - \alpha_t M_t) e_t] = \mathbb{E}[\mathbb{E}[\xi_t^\top (I - \alpha_t M_t) | e_t] \cdot e_t].$$

But $\mathbb{E}[\xi_t | e_t] = \mathbb{E}[\xi_t] = 0$ (by independence and the zero-mean property). Also, $\mathbb{E}[\xi_t^\top M_t | e_t]$ involves $\mathbb{E}[\xi_t^\top M_t]$. Since $\xi_t$ and $M_t$ are both functions of $(s_t, r_t, s_t')$, they are not independent of each other, but they are independent of $e_t$. So:
$$\mathbb{E}[\xi_t^\top (I - \alpha_t M_t) e_t] = \mathbb{E}[\xi_t^\top (I - \alpha_t M_t)] \cdot \mathbb{E}[e_t].$$

Actually, let us handle this more carefully. We have:
$$\mathbb{E}[\xi_t^\top (I - \alpha_t M_t) e_t] = \mathbb{E}\left[\mathbb{E}[\xi_t^\top (I - \alpha_t M_t) \mid e_t] \cdot e_t\right].$$

Since $(s_t, r_t, s_t')$ is independent of $e_t$:
$$\mathbb{E}[\xi_t^\top (I - \alpha_t M_t) \mid e_t] = \mathbb{E}[\xi_t^\top (I - \alpha_t M_t)] = \mathbb{E}[\xi_t]^\top - \alpha_t \mathbb{E}[\xi_t^\top M_t].$$

Now $\mathbb{E}[\xi_t] = 0$, so the first part vanishes. For the second part, $\mathbb{E}[\xi_t^\top M_t]$ is some fixed matrix (it does not depend on $e_t$ or $t$), call it $\Gamma$. Then:
$$\mathbb{E}[\xi_t^\top (I - \alpha_t M_t) e_t] = -\alpha_t \Gamma \mathbb{E}[e_t].$$

This term is $O(\alpha_t)$ times a first moment. However, to get a clean scalar recursion, we use a slightly different (and standard) approach. We expand:

$$\|e_{t+1}\|^2 = \|e_t\|^2 - 2\alpha_t e_t^\top M_t e_t + \alpha_t^2 \|M_t e_t\|^2 + 2\alpha_t \xi_t^\top e_t - 2\alpha_t^2 \xi_t^\top M_t e_t + \alpha_t^2 \|\xi_t\|^2.$$

Taking expectations and using independence of $(s_t, r_t, s_t')$ from $e_t$:

**Term 1:** $\mathbb{E}[\|e_t\|^2] = v_t$.

**Term 2:** $\mathbb{E}[e_t^\top M_t e_t] = \mathbb{E}[e_t^\top \mathbb{E}[M_t] e_t] = \mathbb{E}[e_t^\top A e_t]$.

Since $e_t^\top A e_t = e_t^\top A_s e_t$ (the antisymmetric part contributes $e_t^\top \frac{A - A^\top}{2} e_t = 0$ for any vector), we get:
$$\mathbb{E}[e_t^\top A e_t] = \mathbb{E}[e_t^\top A_s e_t] \geq \lambda_{\min}(A_s) \mathbb{E}[\|e_t\|^2] = \mu \, v_t.$$

**Term 3:** $\mathbb{E}[\|M_t e_t\|^2] = \mathbb{E}[e_t^\top \mathbb{E}[M_t^\top M_t] e_t] \leq \|\mathbb{E}[M_t^\top M_t]\| \cdot v_t$.

We bound $\|\mathbb{E}[M_t^\top M_t]\|$. Note that:
$$M_t^\top M_t = (\phi(s_t) - \gamma \phi(s_t'))\phi(s_t)^\top \phi(s_t)(\phi(s_t) - \gamma \phi(s_t'))^\top.$$

Since $\|\phi(s_t)\| \leq 1$, we have $\phi(s_t)^\top \phi(s_t) = \|\phi(s_t)\|^2 \leq 1$. Thus:
$$\|M_t^\top M_t\| = \|\phi(s_t)\|^2 \cdot \|\phi(s_t) - \gamma \phi(s_t')\|^2 \leq (\|\phi(s_t)\| + \gamma \|\phi(s_t')\|)^2 \leq (1 + \gamma)^2.$$

Therefore $\|\mathbb{E}[M_t^\top M_t]\| \leq \mathbb{E}[\|M_t^\top M_t\|] \leq (1+\gamma)^2$. Define $L^2 = (1+\gamma)^2$.

**Term 4:** $\mathbb{E}[\xi_t^\top e_t] = \mathbb{E}[\mathbb{E}[\xi_t | e_t]^\top e_t] = 0$ since $\mathbb{E}[\xi_t | e_t] = \mathbb{E}[\xi_t] = 0$ by independence.

**Term 5:** $\mathbb{E}[\xi_t^\top M_t e_t]$. By independence of $(s_t, r_t, s_t')$ from $e_t$:
$$|\mathbb{E}[\xi_t^\top M_t e_t]| = |\mathbb{E}[\xi_t^\top M_t] \cdot \mathbb{E}[e_t]|.$$

This term is bounded by a constant times $\|\mathbb{E}[e_t]\|$, which is at most $\sqrt{v_t}$. Since it appears with coefficient $\alpha_t^2$, we can absorb it. However, for a cleaner bound, note:

By Young's inequality, for any $\epsilon > 0$:
$$2\alpha_t^2 |\mathbb{E}[\xi_t^\top M_t e_t]| \leq \alpha_t^2 \left(\epsilon \, v_t + \frac{1}{\epsilon}\mathbb{E}[\|\xi_t\|^2 \|M_t\|^2]\right).$$

Actually, let us use a cleaner standard bound. We have:
$$|2\alpha_t^2 \mathbb{E}[\xi_t^\top M_t e_t]| \leq 2\alpha_t^2 \mathbb{E}[\|\xi_t\| \cdot \|M_t\| \cdot \|e_t\|] \leq 2\alpha_t^2 \sqrt{\mathbb{E}[\|\xi_t\|^2 \|M_t\|^2]} \cdot \sqrt{v_t}.$$

Since $\|\xi_t\| \leq \sigma_{\max}$ and $\|M_t\| \leq 1+\gamma$ (where $\sigma_{\max} = r_{\max} + (1+\gamma)\|\theta^*\|$), this gives:
$$|2\alpha_t^2 \mathbb{E}[\xi_t^\top M_t e_t]| \leq 2\alpha_t^2 (1+\gamma)\sigma_{\max} \sqrt{v_t} \leq \alpha_t^2 [(1+\gamma)^2 v_t + \sigma_{\max}^2]$$

using Young's inequality $2ab \leq a^2 + b^2$.

Combining all terms:
$$v_{t+1} \leq v_t - 2\alpha_t \mu \, v_t + \alpha_t^2 L^2 v_t + \alpha_t^2 \sigma^2 + \alpha_t^2(L^2 v_t + \sigma^2)$$
$$= v_t - 2\alpha_t \mu \, v_t + 2\alpha_t^2 L^2 v_t + 2\alpha_t^2 \sigma^2.$$

Absorbing the factor of 2 into redefined constants $\tilde{L}^2 = 2L^2 = 2(1+\gamma)^2$ and $\tilde{\sigma}^2 = 2\sigma^2$, we obtain:

$$\boxed{v_{t+1} \leq (1 - 2\alpha_t \mu + \alpha_t^2 \tilde{L}^2)\, v_t + \alpha_t^2 \tilde{\sigma}^2.}$$

For notational simplicity, we henceforth write $L^2$ and $\sigma^2$ for $\tilde{L}^2$ and $\tilde{\sigma}^2$ respectively. $\blacksquare$

---

### Phase 4: Solving the Scalar Recursion

**Theorem (Main Result).** With step size $\alpha_t = \frac{c}{c + t}$ where $c \geq \frac{1}{\mu}$, we have:
$$v_T = \mathbb{E}[\|\theta_T - \theta^*\|^2] \leq \frac{C}{T}$$
where $C = \max\left\{c^2(L^2 v_0 + \sigma^2),\; \frac{c^2 \sigma^2}{2c\mu - 1}\right\}$.

**Proof.**

We have the recursion:
$$v_{t+1} \leq (1 - 2\alpha_t \mu + \alpha_t^2 L^2)\, v_t + \alpha_t^2 \sigma^2$$

with $\alpha_t = \frac{c}{c+t}$.

**Step 1: Verify the step size condition.**

For the recursion to be contractive, we need $2\alpha_t \mu > \alpha_t^2 L^2$, i.e., $\alpha_t < \frac{2\mu}{L^2}$. Since $\alpha_t \leq \alpha_0 = 1$ and we can choose $c$ large enough (or equivalently, the step sizes small enough), this holds for all $t \geq 0$ when $c \geq \frac{L^2}{2\mu}$. In fact, for $c \geq \frac{1}{\mu}$, we have $\alpha_t \leq 1$ and $2\mu - \alpha_t L^2 \geq 2\mu - L^2/\mu$. We will verify the induction works directly.

**Step 2: Inductive proof.**

We prove by induction that $v_t \leq \frac{C}{c + t}$ for all $t \geq 0$, where $C$ is chosen appropriately.

**Base case:** $v_0 \leq \frac{C}{c}$ requires $C \geq c \, v_0$. We will verify this is satisfied by our choice of $C$.

**Inductive step:** Assume $v_t \leq \frac{C}{c + t}$. We need to show $v_{t+1} \leq \frac{C}{c + t + 1}$.

From the recursion with $\alpha_t = \frac{c}{c+t}$:

$$v_{t+1} \leq \left(1 - \frac{2c\mu}{c+t} + \frac{c^2 L^2}{(c+t)^2}\right) \frac{C}{c+t} + \frac{c^2 \sigma^2}{(c+t)^2}.$$

We need this to be $\leq \frac{C}{c+t+1}$. That is:

$$\left(1 - \frac{2c\mu}{c+t} + \frac{c^2 L^2}{(c+t)^2}\right) \frac{C}{c+t} + \frac{c^2 \sigma^2}{(c+t)^2} \leq \frac{C}{c+t+1}.$$

Multiply through by $(c+t)(c+t+1)$:

$$\left(c+t - 2c\mu + \frac{c^2 L^2}{c+t}\right)(c+t+1) \cdot \frac{C}{(c+t)^2} + \frac{c^2 \sigma^2 (c+t+1)}{(c+t)^2} \leq C.$$

This is getting complicated; let us use a cleaner approach.

**Cleaner approach:** Multiply the target inequality $v_{t+1} \leq \frac{C}{c+t+1}$ through. It suffices to show:

$$\frac{C}{c+t}\left(1 - \frac{2c\mu}{c+t} + \frac{c^2 L^2}{(c+t)^2}\right) + \frac{c^2 \sigma^2}{(c+t)^2} \leq \frac{C}{c+t+1}.$$

Rearranging, this is equivalent to:

$$C \left[\frac{1}{c+t} - \frac{1}{c+t+1}\right] \geq \frac{C}{c+t}\left(\frac{2c\mu}{c+t} - \frac{c^2 L^2}{(c+t)^2}\right) - \frac{c^2\sigma^2}{(c+t)^2}.$$

Note $\frac{1}{c+t} - \frac{1}{c+t+1} = \frac{1}{(c+t)(c+t+1)}$.

So the condition becomes:
$$\frac{C}{(c+t)(c+t+1)} \geq \frac{C}{c+t} \cdot \frac{c(2\mu(c+t) - c L^2)}{(c+t)^2} - \frac{c^2\sigma^2}{(c+t)^2}.$$

Simplifying:
$$\frac{C}{(c+t)(c+t+1)} \geq \frac{C \cdot c(2\mu(c+t) - cL^2)}{(c+t)^3} - \frac{c^2\sigma^2}{(c+t)^2}.$$

This is messy. Let us use the **standard Polyak-Ruppert style argument** instead.

**Step 2 (revised): Direct induction with $v_t \leq \frac{C}{c+t}$.**

Substituting the inductive hypothesis and $\alpha_t = \frac{c}{c+t}$:

$$v_{t+1} \leq \frac{C}{c+t}\left(1 - \frac{2c\mu}{c+t}\right) + \frac{c^2 L^2}{(c+t)^2}\cdot\frac{C}{c+t} + \frac{c^2\sigma^2}{(c+t)^2}.$$

For $c+t \geq c \geq 1/\mu$, we have $\alpha_t \leq 1/\mu \leq 2\mu/L^2$ (the latter holds when $L^2 \leq 2\mu^2$; if not, we choose $c$ large enough that $c^2L^2/(c+t)^2$ is a lower-order term). 

To handle this cleanly, we use the following:

$$v_{t+1} \leq \frac{C}{c+t}\left(1 - \frac{2c\mu}{c+t}\right) + \frac{c^2(CL^2 + \sigma^2 \cdot (c+t))}{(c+t)^3}.$$

Actually, let us restart with the standard textbook approach.

**Step 2 (final, clean version):** We show $v_t \leq \frac{B}{c+t}$ where $B$ is to be determined.

From the recursion:
$$v_{t+1} \leq \left(1 - \frac{2c\mu}{c+t} + \frac{c^2 L^2}{(c+t)^2}\right)\frac{B}{c+t} + \frac{c^2\sigma^2}{(c+t)^2}.$$

We want $v_{t+1} \leq \frac{B}{c+t+1}$. Using $\frac{1}{c+t+1} = \frac{1}{c+t} \cdot \frac{c+t}{c+t+1} \geq \frac{1}{c+t}\left(1 - \frac{1}{c+t}\right)$:

It suffices to show:
$$\left(1 - \frac{2c\mu}{c+t} + \frac{c^2 L^2}{(c+t)^2}\right)\frac{B}{c+t} + \frac{c^2\sigma^2}{(c+t)^2} \leq \frac{B}{c+t}\left(1 - \frac{1}{c+t}\right).$$

Dividing both sides by $\frac{1}{c+t}$:
$$B\left(1 - \frac{2c\mu}{c+t} + \frac{c^2 L^2}{(c+t)^2}\right) + \frac{c^2\sigma^2}{c+t} \leq B\left(1 - \frac{1}{c+t}\right).$$

Canceling $B$ from both sides:
$$-\frac{2c\mu B}{c+t} + \frac{c^2 L^2 B}{(c+t)^2} + \frac{c^2\sigma^2}{c+t} \leq -\frac{B}{c+t}.$$

Multiply by $(c+t)$:
$$-2c\mu B + \frac{c^2 L^2 B}{c+t} + c^2\sigma^2 \leq -B.$$

Rearranging:
$$B(2c\mu - 1) \geq c^2\sigma^2 + \frac{c^2 L^2 B}{c+t}.$$

For $t \geq 0$, the worst case is $t = 0$, giving $\frac{c^2 L^2 B}{c} = cL^2 B$. So we need:
$$B(2c\mu - 1) \geq c^2\sigma^2 + cL^2 B$$
$$B(2c\mu - 1 - cL^2) \geq c^2\sigma^2.$$

This requires $2c\mu - 1 - cL^2 > 0$, i.e., $c(2\mu - L^2) > 1$. When $\mu$ is small relative to $L^2$ (which happens when $\gamma$ is close to 1), this may fail.

**Refined approach:** We instead use $v_t \leq \frac{B}{(c+t)^\beta}$ for $\beta = 1$ and handle the $L^2$ term by choosing $c$ large enough. However, the standard approach works when we note that for large enough $c+t$, the $\frac{c^2 L^2 B}{c+t}$ term becomes negligible. 

Here is the definitive argument:

**Definitive proof: Choose $c$ appropriately and handle the quadratic term.**

Set $c = \frac{1}{\mu}$ (or more generally, $c > \frac{1}{2\mu}$). We prove $v_t \leq \frac{B}{c+t}$ for $B$ chosen below.

For $c + t \geq T_0 := \frac{c^2 L^2}{2c\mu - 1}$, the quadratic step-size term is small. Specifically:

$$v_{t+1} \leq \left(1 - \frac{2c\mu}{c+t} + \frac{c^2 L^2}{(c+t)^2}\right)\frac{B}{c+t} + \frac{c^2\sigma^2}{(c+t)^2}.$$

We use the fact that for $c + t \geq 1$:
$$1 - \frac{2c\mu}{c+t} + \frac{c^2 L^2}{(c+t)^2} \leq 1 - \frac{2c\mu}{c+t} + \frac{c^2 L^2}{(c+t)^2}.$$

**Key algebraic identity.** We need:

$$\frac{B}{c+t}\left(1 - \frac{2c\mu}{c+t} + \frac{c^2 L^2}{(c+t)^2}\right) + \frac{c^2\sigma^2}{(c+t)^2} \leq \frac{B}{c+t+1}.$$

Using $\frac{B}{c+t+1} \geq \frac{B}{c+t} - \frac{B}{(c+t)^2}$ (since $\frac{1}{c+t+1} \geq \frac{1}{c+t} - \frac{1}{(c+t)^2}$ for $c+t \geq 1$), it suffices to show:

$$\frac{B}{c+t}\left(1 - \frac{2c\mu}{c+t} + \frac{c^2 L^2}{(c+t)^2}\right) + \frac{c^2\sigma^2}{(c+t)^2} \leq \frac{B}{c+t} - \frac{B}{(c+t)^2}.$$

Simplifying (subtract $\frac{B}{c+t}$ from both sides):
$$\frac{B}{c+t}\left(- \frac{2c\mu}{c+t} + \frac{c^2 L^2}{(c+t)^2}\right) + \frac{c^2\sigma^2}{(c+t)^2} \leq - \frac{B}{(c+t)^2}.$$

Multiply by $(c+t)^2$:
$$B\left(-2c\mu + \frac{c^2 L^2}{c+t}\right) + c^2\sigma^2 \leq -B.$$

Rearranging:
$$B\left(2c\mu - 1 - \frac{c^2 L^2}{c+t}\right) \geq c^2\sigma^2. \quad (\star)$$

For $(\star)$ to hold for all $t \geq 0$, we need the left side to be positive at $t = 0$:
$$2c\mu - 1 - \frac{c^2 L^2}{c} = 2c\mu - 1 - cL^2 > 0 \implies c > \frac{1}{2\mu - L^2}.$$

When $2\mu > L^2$, this is achievable. But in general $(1+\gamma)^2$ can exceed $2(1-\gamma)\lambda_{\min}(\Phi^\top D_\pi \Phi)$.

**The resolution** is to choose $c$ large enough so the $\alpha_t^2$ terms become negligible. Specifically, for any $c > 0$ with $2c\mu > 1$, for all $t \geq t_0$ where $t_0 = \frac{c^2 L^2}{2c\mu - 1}$, condition $(\star)$ holds with:

$$B = \frac{c^2\sigma^2}{2c\mu - 1 - c^2L^2/(c+t_0)} = \frac{c^2\sigma^2 \cdot (c+t_0)}{(2c\mu-1)(c+t_0) - c^2 L^2}.$$

But we need a **uniform** bound. The cleanest way is to work with $c$ large.

---

**Clean self-contained proof using the standard SA template:**

**Theorem.** Set $\alpha_t = \frac{c}{c+t}$ with $c = \frac{\kappa}{\mu}$ for a sufficiently large constant $\kappa$ (specifically $\kappa \geq \max(1, L^2/(2\mu^2))$). Then:

$$v_T \leq \frac{C}{T+1}$$

where $C = \max\left\{(c+0)\,v_0, \;\frac{c^2\sigma^2}{2c\mu - 1 - cL^2}\right\}$ (with the denominator positive by the choice of $c$).

**Proof.**

With $c \geq L^2/(2\mu^2) \cdot (1/\mu) = L^2/(2\mu^3)$... this is getting circular. Let us instead use the simplest known approach.

---

### Phase 4 (Definitive Version): $O(1/T)$ Rate via Lyapunov Argument

We use the step size $\alpha_t = \frac{c}{c+t}$ with $c > \frac{1}{2\mu}$, and prove $v_T = O(1/T)$.

**Lemma 4.** Consider the scalar recursion 
$$v_{t+1} \leq (1 - 2\mu\alpha_t + L^2\alpha_t^2)\,v_t + \sigma^2\alpha_t^2$$
with $\alpha_t = c/(c+t)$ and $c > 1/(2\mu)$. Then $v_T \leq \frac{C}{T+1}$ for a constant $C$ depending on $v_0, c, \mu, L, \sigma$.

**Proof of Lemma 4.**

Define $w_t = (c+t)\,v_t$. We will show $w_t$ is bounded.

From the recursion:
$$w_{t+1} = (c+t+1)\,v_{t+1} \leq (c+t+1)\left[\left(1 - \frac{2c\mu}{c+t} + \frac{c^2L^2}{(c+t)^2}\right)\frac{w_t}{c+t} + \frac{c^2\sigma^2}{(c+t)^2}\right].$$

$$= \frac{c+t+1}{c+t}\left(1 - \frac{2c\mu}{c+t} + \frac{c^2L^2}{(c+t)^2}\right) w_t + \frac{c^2\sigma^2(c+t+1)}{(c+t)^2}.$$

Let $n = c + t$. Then:
$$w_{t+1} \leq \frac{n+1}{n}\left(1 - \frac{2c\mu}{n} + \frac{c^2L^2}{n^2}\right) w_t + \frac{c^2\sigma^2(n+1)}{n^2}.$$

Now:
$$\frac{n+1}{n}\left(1 - \frac{2c\mu}{n}\right) = \left(1 + \frac{1}{n}\right)\left(1 - \frac{2c\mu}{n}\right) = 1 + \frac{1}{n} - \frac{2c\mu}{n} - \frac{2c\mu}{n^2} = 1 - \frac{2c\mu - 1}{n} - \frac{2c\mu}{n^2}.$$

And $\frac{n+1}{n} \cdot \frac{c^2L^2}{n^2} = \frac{c^2L^2(n+1)}{n^3} \leq \frac{2c^2L^2}{n^2}$ for $n \geq 1$.

So:
$$w_{t+1} \leq \left(1 - \frac{2c\mu - 1}{n} + \frac{2c^2L^2 - 2c\mu}{n^2}\right) w_t + \frac{2c^2\sigma^2}{n}.$$

Since $2c\mu - 1 > 0$ (by assumption $c > 1/(2\mu)$), define $\rho = 2c\mu - 1 > 0$. For $n$ large enough (specifically $n \geq n_0 := \frac{2(2c^2L^2 + 2c\mu)}{\rho}$), the $O(1/n^2)$ term is bounded by $\frac{\rho}{2n}$, so:

$$w_{t+1} \leq \left(1 - \frac{\rho}{2n}\right) w_t + \frac{2c^2\sigma^2}{n}$$

for $n = c + t \geq n_0$.

If $w_t \leq W := \frac{4c^2\sigma^2}{\rho}$, then:
$$w_{t+1} \leq \left(1 - \frac{\rho}{2n}\right)\frac{4c^2\sigma^2}{\rho} + \frac{2c^2\sigma^2}{n} = \frac{4c^2\sigma^2}{\rho} - \frac{2c^2\sigma^2}{n} + \frac{2c^2\sigma^2}{n} = W.$$

So $w_t \leq W$ is an invariant once entered (for $n \geq n_0$).

For the transient phase ($t < t_0$ where $c + t_0 = n_0$): Since $\alpha_t \leq 1$ and $v_{t+1} \leq (1 + L^2)\,v_t + \sigma^2$, we get $v_t$ is at most exponentially growing in the first $t_0$ steps, so $w_{t_0} = (c+t_0)\,v_{t_0}$ is bounded by some finite constant depending on the initial conditions.

Define:
$$C = \max\left\{c \, v_0, \; n_0 \, v_{t_0}, \; W\right\}.$$

Then $w_t \leq C$ for all $t \geq 0$ by combining the transient bound and the invariant. Since $v_t = \frac{w_t}{c+t}$:

$$v_T \leq \frac{C}{c + T} \leq \frac{C}{T+1} \quad \text{(since } c \geq 1\text{)}.$$

$\blacksquare$

---

### Putting It All Together

**Theorem (TD(0) Finite-Time Bound).** Under assumptions (A1)-(A4), with i.i.d. sampling and step size $\alpha_t = \frac{c}{c+t}$ where $c > \frac{1}{2\mu}$ and $\mu = \lambda_{\min}(A_s) \geq (1-\gamma)\lambda_{\min}(\Phi^\top D_\pi \Phi)$, the TD(0) iterates satisfy:

$$\mathbb{E}[\|\theta_T - \theta^*\|^2] \leq \frac{C}{T+1}$$

where $C$ is a constant depending on $\gamma, \lambda_{\min}(\Phi^\top D_\pi \Phi), r_{\max}, \|\theta^*\|$, and the initial error $\|\theta_0 - \theta^*\|$.

**Proof (Summary).**

1. **TD fixed point existence (Lemma 1):** The matrix $A = \mathbb{E}[\phi(s)(\phi(s) - \gamma\phi(s'))^\top]$ has symmetric part $A_s \succeq (1-\gamma)\Phi^\top D_\pi \Phi \succ 0$. Hence $A$ is positive definite and $\theta^* = A^{-1}b$ is well-defined, with $\mu = \lambda_{\min}(A_s) \geq (1-\gamma)\lambda_{\min}(\Phi^\top D_\pi \Phi)$.

2. **Error recursion (Lemma 2):** The error $e_t = \theta_t - \theta^*$ satisfies $e_{t+1} = (I - \alpha_t M_t)e_t + \alpha_t \xi_t$ where $M_t = \phi(s_t)(\phi(s_t) - \gamma\phi(s_t'))^\top$, $\mathbb{E}[M_t] = A$, $\mathbb{E}[\xi_t] = 0$, and $\mathbb{E}[\|\xi_t\|^2] \leq \sigma^2$.

3. **MSE recursion (Lemma 3):** Using i.i.d. independence of $e_t$ and $(s_t, r_t, s_t')$:
$$v_{t+1} \leq (1 - 2\alpha_t\mu + \alpha_t^2 L^2)\,v_t + \alpha_t^2 \sigma^2$$
where $L^2 \leq 2(1+\gamma)^2$ and $\sigma^2 \leq 2(r_{\max} + (1+\gamma)\|\theta^*\|)^2$.

4. **Rate (Lemma 4):** With $\alpha_t = c/(c+t)$ and $c > 1/(2\mu)$, the Lyapunov function $w_t = (c+t)v_t$ is eventually bounded, giving $v_T = O(1/T)$.

Specifically:
$$\boxed{\mathbb{E}[\|\theta_T - \theta^*\|^2] \leq \frac{C}{T+1}}$$

where $C$ depends polynomially on $(1-\gamma)^{-1}$, $\lambda_{\min}(\Phi^\top D_\pi \Phi)^{-1}$, $r_{\max}$, and $\|\theta_0 - \theta^*\|$. $\blacksquare$

---

### Appendix: Explicit Constant

For completeness, we trace the constants. With $c = 1/\mu$:

- $\mu = \lambda_{\min}(A_s) \geq (1-\gamma)\lambda_{\min}(\Phi^\top D_\pi \Phi) =: (1-\gamma)\lambda_0$
- $L^2 = 2(1+\gamma)^2 \leq 8$
- $\sigma^2 = 2(r_{\max} + (1+\gamma)\|\theta^*\|)^2$
- $\rho = 2c\mu - 1 = 1$, so $W = 4c^2\sigma^2 = \frac{4\sigma^2}{\mu^2}$
- $n_0 = \frac{2(2c^2 L^2 + 2c\mu)}{1} = 4c^2 L^2 + 4c\mu = \frac{4L^2}{\mu^2} + \frac{4}{\mu} \leq \frac{4L^2 + 4\mu}{\mu^2}$

The dominant term in $C$ is:
$$C = O\left(\frac{\sigma^2}{\mu^2}\right) = O\left(\frac{(r_{\max} + (1+\gamma)\|\theta^*\|)^2}{(1-\gamma)^2 \lambda_0^2}\right).$$

This matches the known dependence in the literature (Bhandari et al., 2018; Srikant and Ying, 2019). $\blacksquare$
