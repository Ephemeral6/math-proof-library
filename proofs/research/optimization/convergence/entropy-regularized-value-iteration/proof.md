# Entropy-Regularized Bellman Operator

**Setting.** Finite tabular MDP $(S, A, P, r, \gamma)$, $\gamma \in (0,1)$, $r(s,a) \in [0,1]$, $\tau > 0$.

$$
(T_\tau V)(s) = \tau \log\!\Bigl(\sum_{a \in A} \exp\!\bigl((r(s,a) + \gamma \textstyle\sum_{s'} P(s'|s,a) V(s'))/\tau\bigr)\Bigr).
$$

---

## (i) $T_\tau$ is a $\gamma$-contraction in $\ell^\infty$

**Lemma 1.** $\mathrm{LSE}(x) = \log(\sum_i e^{x_i})$ satisfies $|\mathrm{LSE}(x) - \mathrm{LSE}(y)| \leq \|x-y\|_\infty$.

*Proof.* Let $\delta = \|x-y\|_\infty$. Then $x_i \leq y_i + \delta$ for all $i$, so $\sum e^{x_i} \leq e^\delta \sum e^{y_i}$, giving $\mathrm{LSE}(x) \leq \mathrm{LSE}(y) + \delta$. By symmetry, $|\mathrm{LSE}(x) - \mathrm{LSE}(y)| \leq \delta$. $\blacksquare$

Write $q_s^V(a) = \frac{1}{\tau}(r(s,a) + \gamma \sum_{s'} P(s'|s,a)V(s'))$, so $(T_\tau V)(s) = \tau \cdot \mathrm{LSE}(q_s^V)$.

For any $V, U$ and each $a$:

$$
|q_s^V(a) - q_s^U(a)| = \frac{\gamma}{\tau}\Bigl|\sum_{s'} P(s'|s,a)(V(s')-U(s'))\Bigr| \leq \frac{\gamma}{\tau}\|V-U\|_\infty,
$$

since $P(\cdot|s,a)$ is a distribution. Therefore $\|q_s^V - q_s^U\|_\infty \leq \frac{\gamma}{\tau}\|V-U\|_\infty$, and by Lemma 1:

$$
|(T_\tau V)(s) - (T_\tau U)(s)| = \tau|\mathrm{LSE}(q_s^V) - \mathrm{LSE}(q_s^U)| \leq \tau \cdot \frac{\gamma}{\tau}\|V-U\|_\infty = \gamma\|V-U\|_\infty.
$$

Taking $\max_s$ gives $\|T_\tau V - T_\tau U\|_\infty \leq \gamma\|V-U\|_\infty$. $\blacksquare$

---

## (ii) Convergence of Value Iteration

$(\mathbb{R}^S, \|\cdot\|_\infty)$ is a complete metric space (finite-dimensional). $T_\tau: \mathbb{R}^S \to \mathbb{R}^S$ is well-defined and is a $\gamma$-contraction with $\gamma < 1$. By the Banach Fixed-Point Theorem, $T_\tau$ has a unique fixed point $V_\tau^*$.

For $V_{k+1} = T_\tau V_k$, induction gives $\|V_k - V_\tau^*\|_\infty \leq \gamma^k \|V_0 - V_\tau^*\|_\infty$:

- Base: trivial.
- Step: $\|V_{k+1} - V_\tau^*\| = \|T_\tau V_k - T_\tau V_\tau^*\| \leq \gamma\|V_k - V_\tau^*\| \leq \gamma^{k+1}\|V_0 - V_\tau^*\|$.

Since $\gamma^k \to 0$, we have $V_k \to V_\tau^*$. $\blacksquare$

---

## (iii) Optimal Policy is Gibbs (Softmax)

**Lemma 2.** $\mathrm{LSE}(z) = \max_{\pi \in \Delta_n}\{\sum_i \pi_i z_i + H(\pi)\}$, where $H(\pi) = -\sum_i \pi_i \log \pi_i$. The unique maximizer is $\pi_i^* = e^{z_i}/\sum_j e^{z_j}$.

*Proof.* The objective $f(\pi) = \sum_i \pi_i z_i - \sum_i \pi_i \log \pi_i$ is strictly concave on $\Delta_n$: the Hessian of $H$ is $\nabla^2 H = -\mathrm{diag}(1/\pi_i)$, and for any $v$ with $\sum_i v_i = 0$, $v \neq 0$:

$$
v^\top \nabla^2 H\, v = -\sum_i \frac{v_i^2}{\pi_i} < 0
$$

since $\pi_i > 0$ in the interior. Hence $\nabla^2 H$ is negative definite on the tangent space of $\Delta_n$.

The Lagrangian first-order condition $z_i - \log\pi_i - 1 - \lambda = 0$ gives $\pi_i = e^{z_i - 1 - \lambda}$. Normalization yields $\pi_i^* = e^{z_i}/\sum_j e^{z_j}$, which lies in the interior ($\pi_i^* > 0$), confirming it is the unique maximizer. Direct computation: $f(\pi^*) = \mathrm{LSE}(z)$. $\blacksquare$

Applying Lemma 2: $(T_\tau V)(s) = \max_{\pi(\cdot|s) \in \Delta_A}\{\sum_a \pi(a|s) Q_\tau^V(s,a) + \tau H(\pi(\cdot|s))\}$ where $Q_\tau^V(s,a) = r(s,a) + \gamma \sum_{s'} P(s'|s,a)V(s')$.

At the fixed point $V_\tau^* = T_\tau V_\tau^*$, the unique maximizer is:

$$
\pi_\tau^*(a|s) = \frac{\exp(Q_\tau^*(s,a)/\tau)}{\sum_{a'}\exp(Q_\tau^*(s,a')/\tau)}.
$$

This Gibbs policy satisfies the entropy-regularized Bellman equation, confirming it achieves $V_\tau^*$. $\blacksquare$

---

## (iv) Approximation Error Bound

**Standard operator.** $(TV)(s) = \max_a\{r(s,a) + \gamma \sum_{s'} P(s'|s,a)V(s')\}$.

$T$ is a $\gamma$-contraction: for each $s$, $|(TV)(s) - (TU)(s)| = |\max_a Q_a^V - \max_a Q_a^U| \leq \max_a |Q_a^V - Q_a^U| \leq \gamma\|V-U\|_\infty$, since $P(\cdot|s,a)$ is a stochastic distribution. Its unique fixed point is $V^*$.

**Per-step bound.** With $z_a = r(s,a) + \gamma \sum_{s'} P(s'|s,a)V(s')$:

- Lower: $\sum_a e^{z_a/\tau} \geq e^{\max_a z_a/\tau}$, so $T_\tau V \geq TV$.
- Upper: $\sum_a e^{z_a/\tau} \leq A \cdot e^{\max_a z_a/\tau}$, so $T_\tau V \leq TV + \tau\log A$.

Hence: $0 \leq (T_\tau V)(s) - (TV)(s) \leq \tau\log A$ for all $s, V$. $\quad(\star)$

**Monotonicity of $T_\tau$.** If $V \geq U$ pointwise, then $z_a^V \geq z_a^U$ for each $a$ (since $P(s'|s,a) \geq 0$), and $\mathrm{LSE}$ is strictly increasing in each argument ($\partial\mathrm{LSE}/\partial x_i = \mathrm{softmax}(x)_i > 0$), so $T_\tau V \geq T_\tau U$. Equivalently, $\partial(T_\tau V)(s)/\partial V(s') = \gamma \sum_a \pi_\tau(a|s) P(s'|s,a) \geq 0$, where $\pi_\tau$ is the softmax policy with all components positive.

**Lower bound** ($V_\tau^* \geq V^*$): Set $V_0 = V^*$, $V_{k+1} = T_\tau V_k$. By induction using monotonicity and $(\star)$: $V_k \geq V^*$ for all $k$. Taking $k \to \infty$: $V_\tau^* \geq V^*$.

**Upper bound** ($V_\tau^* \leq V^* + \frac{\tau\log A}{1-\gamma}$): Let $W = V^* + \frac{\tau\log A}{1-\gamma}\mathbf{1}$. Then:

$$
(T_\tau W)(s) \leq (TW)(s) + \tau\log A = V^*(s) + \gamma \cdot \frac{\tau\log A}{1-\gamma} + \tau\log A = V^*(s) + \frac{\tau\log A}{1-\gamma} = W(s).
$$

So $T_\tau W \leq W$. By monotonicity, $T_\tau^k W \leq W$ for all $k$. Taking $k \to \infty$: $V_\tau^* \leq W$.

**Conclusion:** $0 \leq V_\tau^*(s) - V^*(s) \leq \frac{\tau\log A}{1-\gamma}$ for all $s$, hence $\|V_\tau^* - V^*\|_\infty \leq \frac{\tau\log A}{1-\gamma}$. $\blacksquare$
