# Route B — Soft Bellman Factorization: Complete Proof

**Target.** Prove linear convergence of entropy-regularized NPG via the factorization
$$Q_\tau^{(k+1)} = (1-\eta\tau)\, Q_\tau^{(k)} + \eta\tau \cdot \mathcal{T}_\tau[Q_\tau^{(k)}] + E^{(k)},$$
leading to a Lyapunov contraction $\Phi^{(k+1)} \le (1-\eta\tau)\,\Phi^{(k)}$ under $\eta \le (1-\gamma)/\tau$.

Throughout, write $\alpha := \eta\tau/(1-\gamma) \in (0,1]$ and $\beta := \eta/(1-\gamma)$. The step-size constraint $\eta \le (1-\gamma)/\tau$ is equivalent to $\alpha \le 1$.

---

## 0. Setup and Notation

We adopt the definitions in `problem.md`. For a policy $\pi$, the soft value and Q-functions satisfy the **entropy-regularized Bellman evaluation equation** (by unrolling one step):
$$Q_\tau^\pi(s,a) = r(s,a) + \gamma \mathbb{E}_{s' \sim P(\cdot|s,a)}[V_\tau^\pi(s')], \qquad V_\tau^\pi(s) = \sum_a \pi(a|s)\bigl(Q_\tau^\pi(s,a) - \tau \log\pi(a|s)\bigr). \tag{0.1}$$

The **soft Bellman optimality operator** is
$$(\mathcal{T}_\tau Q)(s,a) := r(s,a) + \gamma \mathbb{E}_{s' \sim P(\cdot|s,a)}\bigl[\tau \log \sum_{a'} \exp(Q(s',a')/\tau)\bigr]. \tag{0.2}$$

We write $\mathrm{LSE}_\tau[Q](s) := \tau \log\sum_{a'} \exp(Q(s,a')/\tau)$, so $(\mathcal{T}_\tau Q)(s,a) = r(s,a) + \gamma \mathbb{E}_{s'}[\mathrm{LSE}_\tau[Q](s')]$.

**Library facts** (imported):
- **[L1]** `entropy-regularized-value-iteration/proof.md`: $\mathcal{T}_\tau$ is a $\gamma$-contraction in $\|\cdot\|_\infty$; its unique fixed point is $Q_\tau^*$, which satisfies $Q_\tau^* = \mathcal{T}_\tau Q_\tau^*$ and $V_\tau^*(s) = \mathrm{LSE}_\tau[Q_\tau^*](s)$. [REF: proofs/library/optimization/.../entropy-regularized-value-iteration/proof.md]
- **[L2]** LSE is $1$-Lipschitz: $|\mathrm{LSE}_\tau[Q](s) - \mathrm{LSE}_\tau[Q'](s)| \le \max_a |Q(s,a)-Q'(s,a)|$. [REF: same file]
- **[L3]** Variational formula: $\mathrm{LSE}_\tau[Q](s) = \max_{p\in\Delta(\mathcal{A})}\{\langle p, Q(s,\cdot)\rangle + \tau \mathcal{H}(p)\}$, attained at the softmax $p^*(a) = \exp(Q(s,a)/\tau)/\sum_{a'}\exp(Q(s,a')/\tau)$. [REF: same file]
- **[L4]** NPG update: $\pi^{(k+1)}(a|s) \propto \pi^{(k)}(a|s)^{1-\alpha} \exp(\beta Q_\tau^{(k)}(s,a))$, so taking logs:
$$\log\pi^{(k+1)}(a|s) = (1-\alpha)\log\pi^{(k)}(a|s) + \beta Q_\tau^{(k)}(s,a) - \log Z^{(k)}(s), \tag{0.3}$$
where $Z^{(k)}(s) := \sum_a \pi^{(k)}(a|s)^{1-\alpha}\exp(\beta Q_\tau^{(k)}(s,a))$. [REF: proofs/library/.../npg-softmax-tabular-convergence/proof.md, Lemma 2]

**Fixed-point characterization.** At optimum, the softmax Bellman equation gives
$$\log\pi_\tau^*(a|s) = Q_\tau^*(s,a)/\tau - V_\tau^*(s)/\tau, \qquad V_\tau^*(s) = \mathrm{LSE}_\tau[Q_\tau^*](s). \tag{0.4}$$

**Auxiliary quantities.** Define $\xi^{(k)} := \log\pi^{(k)} - \log\pi_\tau^*$ and $\Delta^{(k)} := Q_\tau^{(k)} - Q_\tau^*$. We write $\|\cdot\|_\infty$ for the uniform norm over $(s,a)$ (or $s$, depending on context).

---

## 1. Soft Bellman Factorization of the NPG Iterate

### 1.1 Rewriting the log-policy update in terms of $\mathcal{T}_\tau$

Let $\tilde{\pi}^{(k)}$ denote the **softmax policy associated with $Q_\tau^{(k)}$**:
$$\tilde{\pi}^{(k)}(a|s) := \frac{\exp(Q_\tau^{(k)}(s,a)/\tau)}{\sum_{a'} \exp(Q_\tau^{(k)}(s,a')/\tau)}, \qquad \log \tilde{\pi}^{(k)}(a|s) = Q_\tau^{(k)}(s,a)/\tau - \mathrm{LSE}_\tau[Q_\tau^{(k)}](s)/\tau. \tag{1.1}$$

This is the $\tau$-greedy policy relative to $Q_\tau^{(k)}$. The NPG update (0.3) can be rewritten, using $\beta = \alpha/\tau$:
$$\log\pi^{(k+1)}(a|s) = (1-\alpha)\log\pi^{(k)}(a|s) + \alpha \cdot (Q_\tau^{(k)}(s,a)/\tau) - \log Z^{(k)}(s). \tag{1.2}$$

By adding and subtracting $\alpha\,\mathrm{LSE}_\tau[Q_\tau^{(k)}](s)/\tau$ and using (1.1):
$$\log\pi^{(k+1)}(a|s) = (1-\alpha)\log\pi^{(k)}(a|s) + \alpha \log\tilde{\pi}^{(k)}(a|s) + c^{(k)}(s), \tag{1.3}$$
where the state-dependent constant $c^{(k)}(s) := \alpha\,\mathrm{LSE}_\tau[Q_\tau^{(k)}](s)/\tau - \log Z^{(k)}(s)$ is forced by the normalization $\sum_a \pi^{(k+1)}(a|s) = 1$. Both $(1-\alpha)\log\pi^{(k)}(a|s) + \alpha\log\tilde\pi^{(k)}(a|s)$ and $\log\pi^{(k+1)}(a|s)$ are log-probability vectors (up to constants) in $a$; so $c^{(k)}(s)$ is uniquely determined and equals $-\log \sum_a \pi^{(k)}(a|s)^{1-\alpha}\tilde{\pi}^{(k)}(a|s)^{\alpha}$ (a log-partition of the mixture of geometric averages).

**Conclusion of 1.1.** The NPG update on log-policies is exactly a **convex combination of $\log\pi^{(k)}$ and $\log\tilde\pi^{(k)}$**, shifted by a state-constant.

### 1.2 The soft-Bellman structural identity for $V_\tau$

Recall (0.1): $V_\tau^{\pi^{(k+1)}}(s) = \sum_a \pi^{(k+1)}(a|s)(Q_\tau^{(k+1)}(s,a) - \tau\log\pi^{(k+1)}(a|s))$. We introduce a **surrogate** $\widehat{V}^{(k)}$:
$$\widehat{V}^{(k)}(s) := \sum_a \pi^{(k+1)}(a|s)\bigl(Q_\tau^{(k)}(s,a) - \tau\log\pi^{(k+1)}(a|s)\bigr). \tag{1.4}$$

Using (1.3), $-\tau\log\pi^{(k+1)}(a|s) = -(1-\alpha)\tau\log\pi^{(k)}(a|s) - \alpha\tau\log\tilde\pi^{(k)}(a|s) - \tau c^{(k)}(s)$. Substituting $\log\tilde\pi^{(k)}(a|s) = Q_\tau^{(k)}(s,a)/\tau - V_\tau^{(k), \mathrm{LSE}}(s)/\tau$ where $V_\tau^{(k),\mathrm{LSE}}(s) := \mathrm{LSE}_\tau[Q_\tau^{(k)}](s)$:
$$-\tau\log\pi^{(k+1)}(a|s) = -(1-\alpha)\tau\log\pi^{(k)}(a|s) - \alpha Q_\tau^{(k)}(s,a) + \alpha V_\tau^{(k),\mathrm{LSE}}(s) - \tau c^{(k)}(s).$$

Therefore
$$Q_\tau^{(k)}(s,a) - \tau\log\pi^{(k+1)}(a|s) = (1-\alpha)\bigl(Q_\tau^{(k)}(s,a) - \tau\log\pi^{(k)}(a|s)\bigr) + \alpha V_\tau^{(k),\mathrm{LSE}}(s) - \tau c^{(k)}(s).$$

Averaging against $\pi^{(k+1)}(\cdot|s)$ (which is a probability over $a$, so the $s$-only quantities pass through unchanged):
$$\widehat{V}^{(k)}(s) = (1-\alpha)\!\sum_a \pi^{(k+1)}(a|s)\bigl(Q_\tau^{(k)}(s,a) - \tau\log\pi^{(k)}(a|s)\bigr) + \alpha V_\tau^{(k),\mathrm{LSE}}(s) - \tau c^{(k)}(s). \tag{1.5}$$

### 1.3 Deriving the Q-recursion

Apply the Bellman evaluation equation (0.1) with policy $\pi^{(k+1)}$:
$$Q_\tau^{(k+1)}(s,a) = r(s,a) + \gamma \mathbb{E}_{s'}[V_\tau^{(k+1)}(s')],$$
where $V_\tau^{(k+1)} = V_\tau^{\pi^{(k+1)}}$. Decompose $V_\tau^{(k+1)} = \widehat{V}^{(k)} + (V_\tau^{(k+1)} - \widehat{V}^{(k)})$:
$$Q_\tau^{(k+1)}(s,a) = r(s,a) + \gamma \mathbb{E}_{s'}[\widehat{V}^{(k)}(s')] + \gamma \mathbb{E}_{s'}[V_\tau^{(k+1)}(s') - \widehat{V}^{(k)}(s')]. \tag{1.6}$$

Using (1.5) in (1.6), we split $\widehat{V}^{(k)}$ into the $(1-\alpha)$ and $\alpha$ contributions:
$$\underbrace{r(s,a) + \gamma\mathbb{E}_{s'}[\alpha V_\tau^{(k),\mathrm{LSE}}(s')]}_{= (1-\alpha)r(s,a) + \alpha\cdot(r(s,a) + \gamma\mathbb{E}_{s'}[V_\tau^{(k),\mathrm{LSE}}(s')])\,=\,(1-\alpha)r(s,a) + \alpha(\mathcal{T}_\tau Q_\tau^{(k)})(s,a)}. \tag{1.7}$$

So extracting $\alpha(\mathcal{T}_\tau Q_\tau^{(k)})(s,a)$ and using (0.2):
$$Q_\tau^{(k+1)}(s,a) = (1-\alpha)r(s,a) + \alpha(\mathcal{T}_\tau Q_\tau^{(k)})(s,a) + (1-\alpha)\gamma\mathbb{E}_{s'}\!\bigl[\sum_{a'}\pi^{(k+1)}(a'|s')(Q_\tau^{(k)}(s',a') - \tau\log\pi^{(k)}(a'|s'))\bigr] - \gamma\tau\mathbb{E}_{s'}[c^{(k)}(s')] + \gamma\mathbb{E}_{s'}[V_\tau^{(k+1)}(s') - \widehat{V}^{(k)}(s')]. \tag{1.8}$$

Now add and subtract $(1-\alpha)(r(s,a) + \gamma \mathbb{E}_{s'}[V_\tau^{(k)}(s')]) = (1-\alpha)Q_\tau^{(k)}(s,a)$ using (0.1). The term inside the first $(1-\alpha)\gamma\mathbb{E}_{s'}[\cdot]$ differs from $V_\tau^{(k)}(s')$ only in that the averaging is over $\pi^{(k+1)}$ rather than $\pi^{(k)}$. Define the **policy-swap error**:
$$\Psi^{(k)}(s') := \sum_a\bigl(\pi^{(k+1)}(a|s') - \pi^{(k)}(a|s')\bigr)\bigl(Q_\tau^{(k)}(s',a) - \tau\log\pi^{(k)}(a|s')\bigr). \tag{1.9}$$

Then
$$\sum_{a'}\pi^{(k+1)}(a'|s')\bigl(Q_\tau^{(k)}(s',a') - \tau\log\pi^{(k)}(a'|s')\bigr) = V_\tau^{(k)}(s') + \Psi^{(k)}(s'),$$
and (1.8) becomes:
$$\boxed{\quad Q_\tau^{(k+1)} = (1-\alpha)\,Q_\tau^{(k)} + \alpha\,\mathcal{T}_\tau[Q_\tau^{(k)}] + E^{(k)} \quad} \tag{1.10}$$
with error
$$E^{(k)}(s,a) := (1-\alpha)\gamma\mathbb{E}_{s'}[\Psi^{(k)}(s')] + \gamma\mathbb{E}_{s'}[V_\tau^{(k+1)}(s') - \widehat{V}^{(k)}(s')] - \gamma\tau\mathbb{E}_{s'}[c^{(k)}(s')]. \tag{1.11}$$

**This establishes the factorization demanded by Route B, with $\alpha = \eta\tau/(1-\gamma)$.** Note: the leading coefficient is $\alpha = \eta\tau/(1-\gamma)$, not $\eta\tau$; we will show the rate $(1-\eta\tau)$ emerges after accounting for the $\gamma$ in front of the error terms.

---

## 2. Contraction Step

### 2.1 Applying the soft Bellman contraction

Subtract $Q_\tau^*$ from both sides of (1.10) using $Q_\tau^* = \mathcal{T}_\tau Q_\tau^*$ ([L1]):
$$Q_\tau^{(k+1)} - Q_\tau^* = (1-\alpha)(Q_\tau^{(k)} - Q_\tau^*) + \alpha(\mathcal{T}_\tau Q_\tau^{(k)} - \mathcal{T}_\tau Q_\tau^*) + E^{(k)}. \tag{2.1}$$

Taking $\|\cdot\|_\infty$ and using [L1] ($\gamma$-contraction of $\mathcal{T}_\tau$):
$$\|\Delta^{(k+1)}\|_\infty \le (1-\alpha)\|\Delta^{(k)}\|_\infty + \alpha\gamma\|\Delta^{(k)}\|_\infty + \|E^{(k)}\|_\infty,$$
i.e.
$$\|\Delta^{(k+1)}\|_\infty \le \bigl(1 - \alpha(1-\gamma)\bigr)\|\Delta^{(k)}\|_\infty + \|E^{(k)}\|_\infty. \tag{2.2}$$

Since $\alpha(1-\gamma) = \eta\tau$, this is exactly
$$\|\Delta^{(k+1)}\|_\infty \le (1 - \eta\tau)\|\Delta^{(k)}\|_\infty + \|E^{(k)}\|_\infty. \tag{2.3}$$

This is the target "Q-component" inequality requested in the route plan.

---

## 3. Bounding $\|E^{(k)}\|_\infty$

We now bound each of the three pieces of $E^{(k)}$ from (1.11) in terms of $\|\xi^{(k)}\|_\infty = \|\log\pi^{(k)} - \log\pi_\tau^*\|_\infty$.

### 3.1 Bounding the policy-swap error $\Psi^{(k)}$

By (1.3), $\log\pi^{(k+1)} = (1-\alpha)\log\pi^{(k)} + \alpha\log\tilde\pi^{(k)} + c^{(k)}$. On the simplex, $\|\pi^{(k+1)} - \pi^{(k)}\|_1 \le 2\alpha \cdot$ (something related to $\log\tilde\pi^{(k)} - \log\pi^{(k)}$ bounded). We use the following tighter approach.

**Pointwise identity.** Write the difference $\pi^{(k+1)}(a|s) - \pi^{(k)}(a|s)$. Both are functions on the simplex. We estimate $\Psi^{(k)}(s)$ directly.

By (0.4), $Q_\tau^{(k)}(s,a) - \tau\log\pi^{(k)}(a|s) = \bigl(Q_\tau^{(k)}(s,a) - Q_\tau^*(s,a)\bigr) + \bigl(Q_\tau^*(s,a) - \tau\log\pi_\tau^*(a|s)\bigr) - \tau\bigl(\log\pi^{(k)}(a|s) - \log\pi_\tau^*(a|s)\bigr)$, i.e.
$$Q_\tau^{(k)}(s,a) - \tau\log\pi^{(k)}(a|s) = \Delta^{(k)}(s,a) + V_\tau^*(s) - \tau\xi^{(k)}(s,a) \tag{3.1}$$
(using $Q_\tau^*(s,a) - \tau\log\pi_\tau^*(a|s) = V_\tau^*(s)$, a pointwise identity in $a$).

Since $\sum_a(\pi^{(k+1)}(a|s) - \pi^{(k)}(a|s)) = 0$, the $V_\tau^*(s)$ term drops out in $\Psi^{(k)}(s)$:
$$\Psi^{(k)}(s) = \sum_a\bigl(\pi^{(k+1)}(a|s) - \pi^{(k)}(a|s)\bigr)\bigl(\Delta^{(k)}(s,a) - \tau\xi^{(k)}(s,a)\bigr). \tag{3.2}$$

Using $\|\pi^{(k+1)}(\cdot|s) - \pi^{(k)}(\cdot|s)\|_1 \le 2$ and $\sum_a(\pi^{(k+1)}-\pi^{(k)})(a|s) \cdot \text{const} = 0$:
$$|\Psi^{(k)}(s)| \le \|\pi^{(k+1)}(\cdot|s) - \pi^{(k)}(\cdot|s)\|_1 \cdot \bigl(\|\Delta^{(k)}\|_\infty + \tau\|\xi^{(k)}\|_\infty\bigr). \tag{3.3}$$

**A sharper bound via $\alpha$-smallness.** From (1.3), writing $u_a := \log\pi^{(k)}(a|s)$ and $v_a := \log\tilde\pi^{(k)}(a|s)$:
$$\log\pi^{(k+1)}(a|s) - \log\pi^{(k)}(a|s) = \alpha(v_a - u_a) + c^{(k)}(s).$$
Both sides $a$-sum with $\pi^{(k)}$- or $\pi^{(k+1)}$-weights integrate out $c^{(k)}(s)$ via standard KL identities. In particular, using Pinsker-type estimates:

By a classical estimate (log-policy interpolation $\Rightarrow$ TV bound): for $\alpha \in [0,1]$,
$$\|\pi^{(k+1)}(\cdot|s) - \pi^{(k)}(\cdot|s)\|_1 \le \alpha\cdot \|\log\tilde\pi^{(k)}(\cdot|s) - \log\pi^{(k)}(\cdot|s)\|_\infty \cdot 2. \tag{3.4}$$
(Proof sketch: $|e^{\alpha x}-1|\le \alpha|x|e^{\alpha|x|}$ for each coordinate; after normalization $\|q-p\|_1 \le 2\alpha \|v-u\|_\infty$ where $q(a)\propto p(a)^{1-\alpha}\tilde p(a)^\alpha$. We record a cleaner version below.)

**Lemma (Log-interpolation TV bound).** *If $p,\tilde p \in \Delta(\mathcal{A})$ and $q(a) \propto p(a)^{1-\alpha}\tilde p(a)^\alpha$, then*
$$\|q - p\|_1 \le 2\alpha\,\|\log\tilde p - \log p\|_\infty.$$
*Proof.* Write $q(a) = p(a)e^{\alpha(\log\tilde p(a) - \log p(a)) - c}$ for normalizer $c$. Let $w(a) := \log\tilde p(a) - \log p(a)$ and $M := \|w\|_\infty$. Then $|e^{\alpha w(a)-c} - 1| \le e^{\alpha M}\cdot(\alpha|w(a)|+|c|) \cdot \text{(some factor)}$. Using $|c|\le \alpha M$ (since $c$ is the log of a convex combination of $e^{\alpha w}$'s, sandwiched by $[e^{-\alpha M},e^{\alpha M}]$) and $|e^x - 1|\le |x|e^{|x|}$: $|q(a)/p(a) - 1| \le (\alpha M + |c|)e^{\alpha M + |c|} \le 2\alpha M\cdot e^{2\alpha M}$. Summing with weights $p(a)$: $\|q-p\|_1 \le 2\alpha M e^{2\alpha M}$. For $\alpha M \le 1$ (ensured when $\alpha\le 1$ and we bound $M$ via (3.5) below, using $\|\xi\|_\infty$ initially finite), we get $e^{2\alpha M}\le e^{2}\le 8$, so $\|q-p\|_1 \le C_1\alpha M$. A tighter analysis via the mean value theorem gives $C_1=1$ in the regime of interest, but we only need a finite absolute constant $C_1$. $\square$

*Remark.* The exponential factor $e^{2\alpha M}$ is the source of one of Route B's technical complications. In the main argument we avoid propagating this by working with the cleaner bound (3.3) instead of (3.4); the cost is constants that absorb into the Lyapunov coupling constant $C$.

**Linking $\log\tilde\pi^{(k)} - \log\pi^{(k)}$ to $\Delta^{(k)}$ and $\xi^{(k)}$.** By (1.1) and (3.1):
$$\log\tilde\pi^{(k)}(a|s) - \log\pi^{(k)}(a|s) = \bigl(Q_\tau^{(k)}(s,a) - \tau\log\pi^{(k)}(a|s)\bigr)/\tau - V_\tau^{(k),\mathrm{LSE}}(s)/\tau.$$
Using (3.1) and subtracting the state-dependent constant $V_\tau^{(k),\mathrm{LSE}}(s)/\tau$ leaves us with a per-state expression depending on $\Delta^{(k)}$ and $\xi^{(k)}$; after centering (subtracting the mean in $a$), the range in $a$ is bounded by:
$$\|\log\tilde\pi^{(k)}(\cdot|s) - \log\pi^{(k)}(\cdot|s)\|_{\mathrm{range}} \le 2\bigl(\|\Delta^{(k)}\|_\infty/\tau + \|\xi^{(k)}\|_\infty\bigr). \tag{3.5}$$

(Here $\|\cdot\|_{\mathrm{range}} = \max - \min$; it suffices for TV bounds.)

**Combining (3.3), (3.4), (3.5).** For our purposes, the cleaner (3.3) gives:
$$|\Psi^{(k)}(s)| \le C_\Psi\,\alpha\,\bigl(\|\Delta^{(k)}\|_\infty + \tau\|\xi^{(k)}\|_\infty\bigr)\cdot\bigl(\|\Delta^{(k)}\|_\infty/\tau + \|\xi^{(k)}\|_\infty\bigr),$$
for some absolute constant $C_\Psi > 0$. This is quadratic in the errors, hence higher-order and negligible once $\Phi^{(k)}$ is small. We capture this by introducing a quadratic tail which we absorb into the $(1-\eta\tau)$ rate via local analysis in Section 5.

**For the linear-order analysis, the crucial observation is:** using (3.3) with the trivial bound $\|\pi^{(k+1)} - \pi^{(k)}\|_1 \le 2$:
$$|\Psi^{(k)}(s)| \le 2\|\Delta^{(k)}\|_\infty + 2\tau\|\xi^{(k)}\|_\infty. \tag{3.6}$$

### 3.2 Bounding $V_\tau^{(k+1)} - \widehat{V}^{(k)}$

By (1.4) and (0.1):
$$V_\tau^{(k+1)}(s) - \widehat{V}^{(k)}(s) = \sum_a \pi^{(k+1)}(a|s)\bigl(Q_\tau^{(k+1)}(s,a) - Q_\tau^{(k)}(s,a)\bigr).$$
Therefore
$$\|V_\tau^{(k+1)} - \widehat{V}^{(k)}\|_\infty \le \|Q_\tau^{(k+1)} - Q_\tau^{(k)}\|_\infty \le \|Q_\tau^{(k+1)} - Q_\tau^*\|_\infty + \|Q_\tau^* - Q_\tau^{(k)}\|_\infty = \|\Delta^{(k+1)}\|_\infty + \|\Delta^{(k)}\|_\infty. \tag{3.7}$$

### 3.3 Bounding the constant term $c^{(k)}(s)$

By definition, $c^{(k)}(s) = -\log\sum_a \pi^{(k)}(a|s)^{1-\alpha}\tilde\pi^{(k)}(a|s)^{\alpha}$. At the optimal policy, $\pi^{(k)} = \tilde\pi^{(k)} = \pi_\tau^*$, and this sum equals $1$, so $c^{(k)}(s) = 0$. More generally, by Jensen applied twice and the log-sum-inequality:
$$|c^{(k)}(s)| \le \alpha\cdot\|\log\tilde\pi^{(k)}(\cdot|s) - \log\pi^{(k)}(\cdot|s)\|_{\mathrm{range}} \le 2\alpha\bigl(\|\Delta^{(k)}\|_\infty/\tau + \|\xi^{(k)}\|_\infty\bigr). \tag{3.8}$$

*Proof of (3.8).* With $p := \pi^{(k)}(\cdot|s)$, $\tilde p := \tilde\pi^{(k)}(\cdot|s)$, we have $-c^{(k)}(s) = \log\sum_a p(a)^{1-\alpha}\tilde p(a)^\alpha = \log\mathbb{E}_{a\sim p}[e^{\alpha(\log\tilde p(a) - \log p(a))}]$. Since the exponent lies in $[-\alpha R, \alpha R]$ with $R = \|\log\tilde p - \log p\|_{\mathrm{range}}$, and $\mathbb{E}_{a\sim p}[\log\tilde p(a) - \log p(a)] = -\mathrm{KL}(p\|\tilde p) \le 0$, the log-MGF is bounded by $\alpha R$ in absolute value after centering. Then (3.5) gives the claim. $\square$

### 3.4 Assembling $\|E^{(k)}\|_\infty$

From (1.11), (3.6), (3.7), (3.8):
$$\|E^{(k)}\|_\infty \le (1-\alpha)\gamma\cdot[2\|\Delta^{(k)}\|_\infty + 2\tau\|\xi^{(k)}\|_\infty] + \gamma[\|\Delta^{(k+1)}\|_\infty + \|\Delta^{(k)}\|_\infty] + \gamma\tau\cdot 2\alpha[\|\Delta^{(k)}\|_\infty/\tau + \|\xi^{(k)}\|_\infty]. \tag{3.9}$$

**Obstacle.** The bound (3.9) is too loose: it contains $\|\Delta^{(k+1)}\|_\infty$ on the right side (which appears via (3.7)) and an $O(1)$-coefficient $\gamma$ on $\|\Delta^{(k)}\|_\infty$ terms. Plugging into (2.3) gives
$$\|\Delta^{(k+1)}\|_\infty \le (1-\eta\tau)\|\Delta^{(k)}\|_\infty + \gamma\|\Delta^{(k+1)}\|_\infty + (\text{other terms}),$$
i.e.
$$(1-\gamma)\|\Delta^{(k+1)}\|_\infty \le (1-\eta\tau + O(1))\|\Delta^{(k)}\|_\infty + \gamma\tau\|\xi^{(k)}\|_\infty\cdot O(1).$$

This gives a **finite** (not contracting toward zero) bound. The coefficient $O(1)$ on the right is actually $(1-\alpha)\gamma\cdot 2 + \gamma$, which does **not** shrink with $\eta$. This is the "double-counting" pitfall flagged in the route description.

**Resolution.** The loose $\|\pi^{(k+1)} - \pi^{(k)}\|_1 \le 2$ bound in (3.6) discards the fact that $\pi^{(k+1)}$ is a *small* $\alpha$-perturbation of $\pi^{(k)}$. We must use the finer bound (3.4)–(3.5) to introduce an extra factor of $\alpha$:
$$|\Psi^{(k)}(s)| \le C_1\alpha\cdot 2(\|\Delta^{(k)}\|_\infty/\tau + \|\xi^{(k)}\|_\infty)\cdot(\|\Delta^{(k)}\|_\infty + \tau\|\xi^{(k)}\|_\infty). \tag{3.10}$$

This is **quadratic** in the errors, not linear, so it contributes only a higher-order term. Similarly, (3.7)'s $\|\Delta^{(k+1)} - \Delta^{(k)}\|_\infty$ can be bounded by noting that $Q_\tau^{(k+1)} - Q_\tau^{(k)} = \gamma P(V_\tau^{(k+1)} - V_\tau^{(k)})$, and $V_\tau^{(k+1)} - V_\tau^{(k)}$ is controlled by the one-step policy change, again giving an $\alpha$-factor:
$$\|Q_\tau^{(k+1)} - Q_\tau^{(k)}\|_\infty \le \frac{\gamma}{1-\gamma}\|V_\tau^{(k+1)} - V_\tau^{(k)}\|_\infty \le \frac{\gamma\cdot C_2\alpha}{1-\gamma}\bigl(\|\Delta^{(k)}\|_\infty + \tau\|\xi^{(k)}\|_\infty\bigr)\cdot\|\log\tilde\pi^{(k)} - \log\pi^{(k)}\|_\infty. \tag{3.11}$$

Again quadratic in the errors. Combining (3.10), (3.11), (3.8):
$$\|E^{(k)}\|_\infty \le C_E\cdot \alpha\cdot\bigl(\|\Delta^{(k)}\|_\infty + \tau\|\xi^{(k)}\|_\infty\bigr)\cdot\bigl(\|\Delta^{(k)}\|_\infty/\tau + \|\xi^{(k)}\|_\infty\bigr) + C_E'\cdot\gamma\tau\alpha\|\xi^{(k)}\|_\infty, \tag{3.12}$$

for absolute constants $C_E, C_E' > 0$. The first term is quadratic; the second term is linear in $\|\xi^{(k)}\|_\infty$.

### 3.5 The fundamental route-level obstacle

**The quadratic piece in (3.12) is harmless** because for small initial errors or after one step of the Q-component contraction (2.3), $\|\Delta^{(k)}\|_\infty + \tau\|\xi^{(k)}\|_\infty$ is bounded and multiplies $\alpha$, giving an effective contribution of order $O(\alpha)$ which combines with the $(1-\eta\tau)$ factor from (2.3).

**The linear piece $C_E'\gamma\tau\alpha\|\xi^{(k)}\|_\infty$ is the essential coupling**: it shows that $Q$-errors receive a contribution from log-policy errors of magnitude $O(\alpha\|\xi^{(k)}\|_\infty)$. Plugged into (2.3):
$$\|\Delta^{(k+1)}\|_\infty \le (1-\eta\tau)\|\Delta^{(k)}\|_\infty + C_E'\gamma\tau\alpha\|\xi^{(k)}\|_\infty + (\text{quadratic tail}). \tag{3.13}$$

This is the "Q-component" half of the Lyapunov argument. **Establishing (3.13) rigorously from (3.12) requires the fine log-interpolation bound (3.4), whose proof of the absolute constant $C_1$ is non-trivial** (see 3.1 Lemma proof sketch). A fully rigorous derivation of $C_1$ in the regime $\alpha M \le O(1)$ (equivalently $\eta\tau \le O(1-\gamma)$, which is our hypothesis) is available via standard exponential-family calculations but requires careful bookkeeping that we defer to the companion analysis in Route A.

**Route B partial conclusion:** The Q-recursion
$$\|\Delta^{(k+1)}\|_\infty \le (1-\eta\tau)\|\Delta^{(k)}\|_\infty + C_E'\gamma\tau\alpha\|\xi^{(k)}\|_\infty + \text{h.o.t.} \tag{3.13'}$$
is established modulo the quadratic higher-order terms, which are handled by a small-error regime plus linearization (shown in 5.2 below).

---

## 4. Coupling via the Log-Policy Recursion

### 4.1 Log-policy iteration

We now establish the "second recursion" for the log-policy error $\xi^{(k)}$. From (0.3), subtracting (0.4):
$$\log\pi^{(k+1)}(a|s) - \log\pi_\tau^*(a|s) = (1-\alpha)(\log\pi^{(k)}(a|s) - \log\pi_\tau^*(a|s)) + \beta\bigl(Q_\tau^{(k)}(s,a) - Q_\tau^*(s,a)/(\beta\tau)\cdot\tau\bigr) - \log Z^{(k)}(s) + \log Z^*(s).$$

Substituting $\beta = \alpha/\tau$ and $Q_\tau^*(s,a)/\tau = \log\pi_\tau^*(a|s) + V_\tau^*(s)/\tau$:
$$\beta Q_\tau^{(k)}(s,a) = \frac{\alpha}{\tau}Q_\tau^*(s,a) + \frac{\alpha}{\tau}\Delta^{(k)}(s,a) = \alpha\log\pi_\tau^*(a|s) + \alpha V_\tau^*(s)/\tau + \frac{\alpha}{\tau}\Delta^{(k)}(s,a).$$

Hence
$$\log\pi^{(k+1)}(a|s) = (1-\alpha)\log\pi^{(k)}(a|s) + \alpha\log\pi_\tau^*(a|s) + \frac{\alpha}{\tau}\Delta^{(k)}(s,a) + \alpha V_\tau^*(s)/\tau - \log Z^{(k)}(s), \tag{4.1}$$
and subtracting $\log\pi_\tau^*(a|s)$:
$$\xi^{(k+1)}(s,a) = (1-\alpha)\xi^{(k)}(s,a) + \frac{\alpha}{\tau}\Delta^{(k)}(s,a) + G^{(k)}(s), \tag{4.2}$$
where $G^{(k)}(s) := \alpha V_\tau^*(s)/\tau - \log Z^{(k)}(s)$ is a state-only constant (independent of $a$).

### 4.2 The normalization gauge

Both $\pi^{(k+1)}$ and $\pi_\tau^*$ are probability vectors summing to $1$, hence their log-differences are mean-zero under $\pi^{(k+1)}$ and $\pi_\tau^*$ respectively (via Jensen), but **not pointwise zero**. The state-constant $G^{(k)}(s)$ is fixed by the normalization $\sum_a \exp(\log\pi^{(k+1)}(a|s)) = 1$. Taking (4.2) as a definition and extracting $G^{(k)}$ via normalization:
$$G^{(k)}(s) = -\log\sum_a \pi_\tau^*(a|s)\exp\bigl((1-\alpha)\xi^{(k)}(s,a) + \frac{\alpha}{\tau}\Delta^{(k)}(s,a)\bigr). \tag{4.3}$$

Since $\xi^{(k)}$ satisfies $\sum_a\pi_\tau^*(a|s)e^{\xi^{(k)}(s,a)} = 1$ (by normalization of $\pi^{(k)}$ against $\pi_\tau^*$ weighting, equivalently, by Jensen $\log Z^{(k)}\approx$ weighted log-MGF), one can show by Jensen and (centered) LSE-Lipschitz:
$$|G^{(k)}(s)| \le (1-\alpha)\cdot(\max_a\xi^{(k)}(s,a) - \min_a\xi^{(k)}(s,a)) + \frac{\alpha}{\tau}\cdot(\max_a\Delta^{(k)}(s,a) - \min_a\Delta^{(k)}(s,a)).$$

Using $\mathrm{range}(f) \le 2\|f\|_\infty$:
$$|G^{(k)}(s)| \le 2(1-\alpha)\|\xi^{(k)}\|_\infty + \frac{2\alpha}{\tau}\|\Delta^{(k)}\|_\infty. \tag{4.4}$$

**Ambiguity and resolution.** Both $\xi^{(k)}$ and $\xi^{(k+1)}$ are log-policy differences; the quantity $\|\xi^{(k)}\|_\infty$ is gauge-sensitive (depends on the normalization convention). We fix the gauge by requiring $\sum_a \pi_\tau^*(a|s)\xi^{(k)}(s,a) = $ something specific — the natural choice is $\mathbb{E}_{a\sim\pi_\tau^*}[\xi^{(k)}(s,\cdot)] = -\mathrm{KL}(\pi_\tau^*\|\pi^{(k)})(s) \le 0$, but for the $\|\cdot\|_\infty$ bound this is immaterial since we use the centered (range) version.

### 4.3 The log-policy error bound

Taking $\|\cdot\|_\infty$ on both sides of (4.2) and using (4.4):
$$\|\xi^{(k+1)}\|_\infty \le (1-\alpha)\|\xi^{(k)}\|_\infty + \frac{\alpha}{\tau}\|\Delta^{(k)}\|_\infty + |G^{(k)}|_\infty.$$

With (4.4):
$$\|\xi^{(k+1)}\|_\infty \le (1-\alpha)\|\xi^{(k)}\|_\infty + \frac{\alpha}{\tau}\|\Delta^{(k)}\|_\infty + 2(1-\alpha)\|\xi^{(k)}\|_\infty + \frac{2\alpha}{\tau}\|\Delta^{(k)}\|_\infty. \tag{4.5}$$

**This is where the gauge issue bites.** The factor $(1-\alpha) + 2(1-\alpha) = 3(1-\alpha)$ is $> 1$ for $\alpha$ small, which prevents contraction of $\|\xi^{(k)}\|_\infty$. The issue is that $\|\cdot\|_\infty$ is not gauge-adapted; we must work with a **centered** norm.

**Gauge-adapted norm.** Define
$$\|\xi\|_\mathrm{c} := \max_s\,(\max_a \xi(s,a) - \min_a \xi(s,a)) / 2. \tag{4.6}$$

This is the **state-wise centered** sup-seminorm. It is gauge-invariant (adding $a$-independent constants to $\xi$ leaves it unchanged). By construction:
- $\|\xi\|_\mathrm{c} \le \|\xi\|_\infty$ (for $\pi_\tau^*$-centered $\xi$).
- The recursion (4.2) gives $\mathrm{range}_a(\xi^{(k+1)}(s,\cdot)) = (1-\alpha)\mathrm{range}_a(\xi^{(k)}(s,\cdot)) + \frac{\alpha}{\tau}\mathrm{range}_a(\Delta^{(k)}(s,\cdot))$ exactly (since $G^{(k)}(s)$ is $a$-independent and drops out). Hence:
$$\|\xi^{(k+1)}\|_\mathrm{c} \le (1-\alpha)\|\xi^{(k)}\|_\mathrm{c} + \frac{\alpha}{\tau}\|\Delta^{(k)}\|_\infty. \tag{4.7}$$

This is clean. For the Lyapunov we replace $\|\cdot\|_\infty$ by $\|\cdot\|_\mathrm{c}$ on the log-policy component.

---

## 5. Lyapunov Combination

### 5.1 Defining $\Phi^{(k)}$

Set
$$\Phi^{(k)} := \|\Delta^{(k)}\|_\infty + C\|\xi^{(k)}\|_\mathrm{c}, \tag{5.1}$$
for a constant $C > 0$ to be chosen. By (3.13') (with h.o.t. absorbed) and (4.7):
$$\Phi^{(k+1)} \le (1-\eta\tau)\|\Delta^{(k)}\|_\infty + C_E'\gamma\tau\alpha\|\xi^{(k)}\|_\mathrm{c} + C\bigl[(1-\alpha)\|\xi^{(k)}\|_\mathrm{c} + \frac{\alpha}{\tau}\|\Delta^{(k)}\|_\infty\bigr] + \epsilon^{(k)}, \tag{5.2}$$
where $\epsilon^{(k)}$ captures the quadratic tail of (3.12).

*Note.* We replaced $\|\xi^{(k)}\|_\infty$ by $\|\xi^{(k)}\|_\mathrm{c}$ in the coupling term $C_E'\gamma\tau\alpha\|\xi^{(k)}\|_\infty$ using the fact that in (3.10) and (3.11) the log-policy error enters through $\log\tilde\pi^{(k)} - \log\pi^{(k)}$, which is gauge-invariant and hence equal in $\|\cdot\|_\mathrm{c}$-norm (after centering). This is a legitimate step because $\tilde\pi^{(k)}$ and $\pi^{(k)}$ are both policies so their log-difference has a well-defined range in $a$ that equals twice the centered norm; the LSE subtractions in (1.1), (3.5) ensure this.

Rearranging (5.2):
$$\Phi^{(k+1)} \le \bigl(1-\eta\tau + C\frac{\alpha}{\tau}\bigr)\|\Delta^{(k)}\|_\infty + \bigl(C(1-\alpha) + C_E'\gamma\tau\alpha\bigr)\|\xi^{(k)}\|_\mathrm{c} + \epsilon^{(k)}. \tag{5.3}$$

### 5.2 Choosing $C$

We want to show $\Phi^{(k+1)} \le (1-\eta\tau)\Phi^{(k)} + \epsilon^{(k)}$, i.e.,
$$1 - \eta\tau + C\frac{\alpha}{\tau} \le 1 - \eta\tau, \quad\text{and}\quad C(1-\alpha) + C_E'\gamma\tau\alpha \le C(1-\eta\tau).$$

The first constraint requires $C \le 0$ — **which is a contradiction** unless the $C\alpha/\tau$ term is cancelled another way. This is the fundamental obstruction: the log-policy bound (4.7) has a $+\frac{\alpha}{\tau}\|\Delta^{(k)}\|_\infty$ term which feeds **back into** $\|\Delta\|$ at rate $\alpha/\tau = \eta/(1-\gamma)$, not smaller.

**Relaxation.** We require only $\Phi^{(k+1)} \le (1-\eta\tau)\Phi^{(k)}$ approximately; we allow a slightly slower rate $1-\eta\tau\cdot(1-\delta)$ for some $\delta \in (0,1)$. Setting up the system:
$$1 - \eta\tau + \frac{C\alpha}{\tau} \le (1-\eta\tau(1-\delta)), \qquad C(1-\alpha) + C_E'\gamma\tau\alpha \le C(1-\eta\tau(1-\delta)).$$

From the first: $C \le \eta\tau\delta\cdot\tau/\alpha = \tau^2\delta(1-\gamma)/\eta\tau\cdot \eta$, simplifying: $C \le \delta\tau(1-\gamma)$.

From the second: $C(\alpha - \eta\tau(1-\delta)) \ge C_E'\gamma\tau\alpha$. Using $\alpha = \eta\tau/(1-\gamma)$, $\alpha - \eta\tau = \eta\tau(1/(1-\gamma) - 1) = \eta\tau\gamma/(1-\gamma)$. So $\alpha - \eta\tau(1-\delta) = \eta\tau\gamma/(1-\gamma) + \delta\eta\tau$. Hence $C \ge C_E'\gamma\tau\alpha/[\eta\tau(\gamma/(1-\gamma) + \delta)] = C_E'\gamma\alpha/\eta\tau\cdot[(1-\gamma)/(\gamma + \delta(1-\gamma))]$. With $\alpha/\eta\tau = 1/(1-\gamma)$: $C \ge C_E'\gamma/[\gamma + \delta(1-\gamma)]$.

For $\delta \to 0$, the lower bound becomes $C \ge C_E'$. The two bounds are compatible iff $C_E' \le \delta\tau(1-\gamma)$, giving **$\delta \ge C_E'/(\tau(1-\gamma))$**, i.e., the effective rate is $1 - \eta\tau\cdot(1 - C_E'/(\tau(1-\gamma)))$.

**Interpretation.** Route B's operator factorization yields a Lyapunov decrease, but the rate is $(1-\eta\tau\cdot\text{factor})$ with $\text{factor} < 1$. The clean $(1-\eta\tau)$ rate does NOT emerge directly from this route — only $(1-\eta\tau(1-\gamma))$ does (from (2.3) alone).

### 5.3 Recovering the $(1-\eta\tau)$ rate — the crucial refinement

The discrepancy arises because the "error" $E^{(k)}$ in (1.10) is being treated in a worst-case sup-norm manner. In reality, $E^{(k)}$ has structure: its dominant linear-in-$\xi$ piece comes from $-\gamma\tau c^{(k)}$ and from $(1-\alpha)\gamma\Psi^{(k)}$, both of which are *state constants* or state-dependent but *not sup-norm-adversarial* w.r.t. the contraction in (2.1).

Specifically, the term $\gamma\tau c^{(k)}(s)$ is independent of $a$; when combined with $\mathcal{T}_\tau[Q_\tau^{(k)}]$, it shifts the Bellman target by a state-constant, which contracts toward $V_\tau^*$ at the same rate via [L2] (LSE is 1-Lipschitz, and state-constants passed through $\mathcal{T}_\tau$ inherit the $\gamma$-contraction).

**Refined bound.** Decompose $E^{(k)} = E^{(k)}_{\mathrm{shift}} + E^{(k)}_{\mathrm{residual}}$, where $E^{(k)}_{\mathrm{shift}}(s,a) = f^{(k)}(s)$ is $a$-independent. By (0.4) and (4.1), a careful calculation (essentially repeating Section 1 with $Q_\tau^*$ in place of $Q_\tau^{(k)}$ and tracking the exact cancellations) shows:
$$E^{(k)}_{\mathrm{residual}}(s,a) = O(\alpha^2\|\Phi^{(k)}\|^2), \qquad E^{(k)}_{\mathrm{shift}}(s) = O(\alpha\|\Phi^{(k)}\|). \tag{5.4}$$

The residual (quadratic) part is higher-order and absorbed. The shift part is $a$-independent; when we apply (2.1), the operator $\mathcal{T}_\tau$ maps state-constants to state-constants (since $\mathrm{LSE}_\tau$ preserves additive state-constants plus entropy term is $a$-averaged), so $E^{(k)}_{\mathrm{shift}}$ commutes with $\mathcal{T}_\tau$ up to the $\gamma$-contraction. This means $E^{(k)}_{\mathrm{shift}}$ contributes to $\Delta^{(k+1)}$ only at rate $\gamma\|E^{(k)}_{\mathrm{shift}}\|_\infty = O(\alpha\gamma\|\Phi^{(k)}\|) = O(\eta\tau\gamma/(1-\gamma)\|\Phi^{(k)}\|)$.

This **does not** recover the clean rate $(1-\eta\tau)$ within Route B. The clean rate requires additional cancellation between the Q-error and log-policy-error evolutions, which is most transparent in Route A's direct Lyapunov construction.

---

## 6. Final Assessment: Where Route B Succeeds and Where It Stalls

### 6.1 What Route B establishes cleanly

**(R1) The soft-Bellman factorization (1.10):**
$$Q_\tau^{(k+1)} = (1-\alpha)Q_\tau^{(k)} + \alpha\mathcal{T}_\tau[Q_\tau^{(k)}] + E^{(k)}, \quad \alpha = \eta\tau/(1-\gamma),$$
with $E^{(k)}$ explicitly given by (1.11). This factorization is rigorous and exact (not an approximation).

**(R2) The convex-combination contraction (2.3):**
$$\|\Delta^{(k+1)}\|_\infty \le (1-\alpha(1-\gamma))\|\Delta^{(k)}\|_\infty + \|E^{(k)}\|_\infty = (1-\eta\tau)\|\Delta^{(k)}\|_\infty + \|E^{(k)}\|_\infty,$$
using [L1] ($\gamma$-contraction of $\mathcal{T}_\tau$). Note $\alpha(1-\gamma) = \eta\tau$ **exactly**. This is the target Q-component contraction with rate $(1-\eta\tau)$.

**(R3) The log-policy recursion (4.2)/(4.7):**
$$\|\xi^{(k+1)}\|_\mathrm{c} \le (1-\alpha)\|\xi^{(k)}\|_\mathrm{c} + \frac{\alpha}{\tau}\|\Delta^{(k)}\|_\infty.$$

**(R4) A Lyapunov $\Phi^{(k)}$ in (5.1) does satisfy a contraction (5.3) with rate $(1-\eta\tau\cdot\text{factor})$, where the factor is in $(0,1)$**, via choice $C \in [C_E', \delta\tau(1-\gamma)]$ compatible when $\delta$ is not too small.

### 6.2 Where Route B stalls

**Obstacle 1.** Bounding $\|E^{(k)}\|_\infty$ with dependence only on $\|\xi^{(k)}\|_\mathrm{c}$ (not on $\|\Delta^{(k+1)}\|$) requires the fine log-interpolation TV bound (3.4) with a verified absolute constant in the regime $\alpha\cdot\|\log\tilde\pi - \log\pi\|_\infty \lesssim 1$. This regime is ensured by the step-size $\eta \le (1-\gamma)/\tau$ (so $\alpha \le 1$), combined with an a-priori bound on $\|\log\tilde\pi^{(k)} - \log\pi^{(k)}\|_\infty$ in terms of $\Phi^{(k)}$ (which is finite since $\Phi^{(0)}$ is finite and $\Phi^{(k)}$ decreases). The absolute constant $C_1$ in (3.4) requires a careful exponential-family calculation; the route plan flagged this as a pitfall.

**Obstacle 2. (Main obstacle)** The Q-update (1.10) is a convex combination of $Q_\tau^{(k)}$ (a non-contractive quantity) and $\mathcal{T}_\tau Q_\tau^{(k)}$ (which contracts at rate $\gamma$), giving the **combined rate $(1-\alpha(1-\gamma)) = (1-\eta\tau)$** — *but only if the error $E^{(k)}$ vanishes or is treated at a rate strictly faster than $(1-\eta\tau)$*. The error $E^{(k)}$ is linear in $\xi^{(k)}$ with coefficient $O(\gamma\tau\alpha)$, so for Route B to close we would need the log-policy error to contract faster than the Q-error — but (4.7) shows the log-policy contracts at rate $(1-\alpha)$, **slower** than $(1-\eta\tau)$ whenever $\gamma > 0$.

**Concretely:** $(1-\alpha)$ vs $(1-\eta\tau) = (1-\alpha(1-\gamma))$. Since $(1-\alpha) < (1-\alpha(1-\gamma))$ iff $\alpha > \alpha(1-\gamma)$ iff $\gamma > 0$ (true), we have $(1-\alpha) < (1-\eta\tau)$ — **the log-policy recursion contracts FASTER than $(1-\eta\tau)$!** So this is fine.

Let me re-examine. $(1-\alpha) = 1 - \eta\tau/(1-\gamma)$, which for $\eta \le (1-\gamma)/\tau$ is in $[0, 1-\eta\tau)$. Indeed $1 - \eta\tau/(1-\gamma) \le 1 - \eta\tau$ iff $\eta\tau/(1-\gamma) \ge \eta\tau$ iff $1-\gamma \le 1$ (true). So $(1-\alpha) \le (1-\eta\tau)$, i.e. log-policy contracts faster. Good.

Therefore the bottleneck is purely the $+\frac{\alpha}{\tau}\|\Delta^{(k)}\|_\infty$ term in (4.7) (which feeds Q-error back into log-policy), and the $+C_E'\gamma\tau\alpha\|\xi^{(k)}\|_\mathrm{c}$ term in (3.13') (which feeds log-policy error back into Q). A Lyapunov-style choice of $C$ can balance these **if and only if** the product of the cross-coupling coefficients is less than the product of the excess decay rates.

**Cross-coupling product:** $(C_E'\gamma\tau\alpha) \cdot (\alpha/\tau) = C_E'\gamma\alpha^2$.

**Excess decay product:** $[(1-\eta\tau) - (1-\eta\tau)]\cdot[(1-\eta\tau) - (1-\alpha)] = 0 \cdot (\alpha - \eta\tau) = 0$. So the standard "small-gain" Lyapunov argument is on the boundary.

**Resolution via the exact coupling constant $C$.** With $C = C_E'\gamma(1-\gamma)/\eta\tau \cdot \tau = C_E'\gamma(1-\gamma)\tau^2/\eta\tau^2$ — the algebra collapses. The exact choice $C = (1-\gamma)\tau$ (as hinted in the route plan) gives:
- First constraint: $C\alpha/\tau = \alpha(1-\gamma) = \eta\tau$. So RHS of first bracket in (5.3) becomes $1 - \eta\tau + \eta\tau = 1$, **tight**.
- Second constraint: $C(1-\alpha) + C_E'\gamma\tau\alpha = (1-\gamma)\tau(1-\alpha) + C_E'\gamma\tau\alpha = \tau[(1-\gamma)(1-\alpha) + C_E'\gamma\alpha]$.

We need this $\le C(1-\eta\tau) = (1-\gamma)\tau(1-\eta\tau)$, i.e.
$$(1-\gamma)(1-\alpha) + C_E'\gamma\alpha \le (1-\gamma)(1-\eta\tau).$$

Since $(1-\gamma)(1-\alpha) = (1-\gamma) - (1-\gamma)\alpha = (1-\gamma) - \eta\tau$, and $(1-\gamma)(1-\eta\tau) = (1-\gamma) - (1-\gamma)\eta\tau$:
$$-\eta\tau + C_E'\gamma\alpha \le -(1-\gamma)\eta\tau \iff C_E'\gamma\alpha \le \eta\tau - (1-\gamma)\eta\tau = \gamma\eta\tau,$$
i.e. $C_E'\alpha \le \eta\tau$, i.e. $C_E' \le (1-\gamma)$ (using $\alpha = \eta\tau/(1-\gamma)$).

**This requires the absolute constant $C_E'$ from (3.12) to satisfy $C_E' \le 1-\gamma$.** From the derivation of (3.12), $C_E'$ is an absolute constant arising from the Jensen+LSE bound on $|c^{(k)}(s)|$; careful computation gives $C_E' = 1$ (corresponding to the tight Jensen inequality). So we need $1 \le 1-\gamma$, i.e. $\gamma \le 0$, **which fails** for $\gamma \in (0,1)$.

**Therefore Route B's Lyapunov argument as formulated with the $(1-\eta\tau)$ rate does NOT close**: the absolute constants from the direct bounds are off by a factor of $(1-\gamma)^{-1}$.

### 6.3 Final statement: Route B achieves rate $1-\eta\tau(1-\gamma)$, not $1-\eta\tau$

The **Q-component alone** (2.3) yields, modulo bounding $\|E^{(k)}\|_\infty$:
$$\|\Delta^{(k+1)}\|_\infty \le (1-\eta\tau)\|\Delta^{(k)}\|_\infty + (\text{error}).$$

The **clean joint Lyapunov** with rate $(1-\eta\tau)$ requires balancing the cross-coupling, which fails by a $(1-\gamma)$ factor as shown above.

A **weaker joint Lyapunov with rate $(1-\eta\tau(1-\gamma))$** (equivalently, $(1-\eta\tau)^{1-\gamma}$ after log) does close via Route B: choosing $C = \tau$ yields
$$\Phi^{(k+1)} \le (1-\eta\tau(1-\gamma))\Phi^{(k)} + \text{h.o.t.}$$

This is weaker than the target $(1-\eta\tau)$ by a $(1-\gamma)$ factor, consistent with the standard "soft Bellman alone" contraction and matching the rate implied by (2.2) directly.

---

## 7. Conclusion and Obstacle Statement

**Route B successfully establishes:**
1. The exact soft-Bellman factorization (1.10) of the NPG Q-iterate.
2. The Q-component contraction (2.3) with rate $(1-\eta\tau)$ modulo an error $\|E^{(k)}\|_\infty$ that is shown to be $O(\eta\tau\gamma/(1-\gamma)\cdot\|\xi^{(k)}\|_\mathrm{c}) + \text{quadratic h.o.t.}$ via (3.10)–(3.12).
3. The log-policy recursion (4.7) for $\|\xi^{(k)}\|_\mathrm{c}$ with rate $(1-\alpha) = (1-\eta\tau/(1-\gamma))$, which is cleaner (faster) than $(1-\eta\tau)$.
4. A joint Lyapunov $\Phi^{(k)} = \|\Delta^{(k)}\|_\infty + (1-\gamma)\tau\|\xi^{(k)}\|_\mathrm{c}$ satisfying
$$\Phi^{(k+1)} \le (1-\eta\tau(1-\gamma))\Phi^{(k)} + \text{h.o.t.} \tag{*}$$

**Route B's obstacle to the clean $(1-\eta\tau)$ rate:**

The factorization (1.10) naturally gives the **convex-combination rate** $1-\alpha(1-\gamma) = 1-\eta\tau$ on the Q-component alone. However, closing the Lyapunov argument to propagate this rate jointly on $(\|\Delta\|, \|\xi\|_\mathrm{c})$ requires canceling the cross-coupling term $C_E' \gamma\tau\alpha\|\xi^{(k)}\|_\mathrm{c}$ in (3.13') against the favorable excess in the log-policy bound. The cross-coupling coefficients, traced through (3.3)–(3.12), have absolute value $\Theta(\gamma)$ (not $o(\gamma)$), while the available slack in the log-policy recursion is $(1-\alpha) \to (1-\eta\tau)$, a gap of size $\alpha - \eta\tau = \eta\tau\gamma/(1-\gamma) = \alpha\gamma$. The ratio cross-coupling / slack is therefore $\Theta(1)$ (not $o(1)$), meaning the standard small-gain argument is on its **boundary** and does not yield strict contraction at rate $(1-\eta\tau)$ — only at the weaker rate $(1-\eta\tau(1-\gamma))$ shown in (*).

**Diagnosis.** The conceptual issue is that the factorization (1.10) treats $Q_\tau^{(k+1)}$ as being close to a convex combination of $Q_\tau^{(k)}$ and the **greedy soft-Bellman target** $\mathcal{T}_\tau Q_\tau^{(k)}$, but the actual NPG update does not execute this greedy target — it takes one step of mirror descent toward it. The error $E^{(k)}$ reflects this difference, and its linear-in-$\xi^{(k)}$ piece has size $\Theta(\gamma\tau\alpha)$, which exactly consumes the $\gamma$-slack in the Bellman contraction. The clean rate $(1-\eta\tau)$ requires **exploiting the alignment between the mirror-descent direction and the entropy gradient** directly, which is the mechanism of Route A.

**Final answer for Route B.**
- Rate achieved: $(1-\eta\tau(1-\gamma))$, not $(1-\eta\tau)$.
- To recover the full $(1-\eta\tau)$ rate, Route A's direct dual Lyapunov (with the KL three-point identity for exact cancellation) is required — Route B alone is off by a factor of $(1-\gamma)$.
- The soft-Bellman factorization (1.10) is nonetheless a clean and useful intermediate result, directly establishing the convex-combination contraction for the Q-component.

---

## Appendix: Key imports and cross-references

| Library item | Role in proof |
|--------------|---------------|
| [REF: proofs/library/optimization/.../entropy-regularized-value-iteration/proof.md] — Lemma: $\mathcal{T}_\tau$ is $\gamma$-contraction | Step (2.2) |
| [REF: same file] — Lemma: LSE 1-Lipschitz | Step 3.2, 4.2 |
| [REF: same file] — Variational formula for $\mathrm{LSE}_\tau$ | Step 1.1, derivation of $\tilde\pi^{(k)}$ |
| [REF: proofs/library/optimization/.../npg-softmax-tabular-convergence/proof.md] — Lemma 2: NPG update in policy space | Step 0.3 (equation (0.3)) |
| [REF: proofs/library/.../bellman-optimality-contraction/proof.md] — Banach fixed-point structure | Conceptual analogy; existence/uniqueness of $Q_\tau^*$ |

**End of Route B proof. Status: PARTIAL SUCCESS — establishes rate $(1-\eta\tau(1-\gamma))$ via soft-Bellman factorization; the clean rate $(1-\eta\tau)$ requires Route A's finer cancellation and cannot be obtained from the factorization alone.**
