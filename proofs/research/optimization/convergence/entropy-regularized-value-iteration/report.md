# Entropy-Regularized Bellman Operator: Complete Proof

## Route: Operator Theory via Log-Sum-Exp Properties

### Setup and Notation

We work with a finite tabular MDP $(S, A, P, r, \gamma)$ where $|S| = S$, $|A| = A$, $\gamma \in (0,1)$, $r(s,a) \in [0,1]$.

The $\tau$-entropy-regularized Bellman operator $T_\tau : \mathbb{R}^S \to \mathbb{R}^S$ is defined by:

$$
(T_\tau V)(s) = \tau \log\!\Bigl(\sum_{a \in A} \exp\!\bigl((r(s,a) + \gamma \sum_{s'} P(s'|s,a) V(s'))/\tau\bigr)\Bigr).
$$

We denote $\|V\|_\infty = \max_{s \in S} |V(s)|$ throughout.

---

## Part (i): $T_\tau$ is a $\gamma$-contraction in $\ell^\infty$

### Key Lemma: Log-Sum-Exp is 1-Lipschitz in $\ell^\infty$

**Lemma 1.** Define $\mathrm{LSE}: \mathbb{R}^n \to \mathbb{R}$ by $\mathrm{LSE}(x) = \log\bigl(\sum_{i=1}^n \exp(x_i)\bigr)$. Then for all $x, y \in \mathbb{R}^n$:

$$
|\mathrm{LSE}(x) - \mathrm{LSE}(y)| \leq \|x - y\|_\infty.
$$

**Proof of Lemma 1.** It suffices to show $\mathrm{LSE}(x) - \mathrm{LSE}(y) \leq \|x - y\|_\infty$; the reverse direction follows by symmetry (swapping $x$ and $y$).

Let $\delta = \|x - y\|_\infty$. Then for every $i \in \{1, \ldots, n\}$, we have $x_i \leq y_i + \delta$. Therefore:

$$
\sum_{i=1}^n \exp(x_i) \leq \sum_{i=1}^n \exp(y_i + \delta) = e^\delta \sum_{i=1}^n \exp(y_i).
$$

Taking logarithms of both sides (both sides are positive since they are sums of exponentials):

$$
\log\!\Bigl(\sum_{i=1}^n \exp(x_i)\Bigr) \leq \log\!\Bigl(e^\delta \sum_{i=1}^n \exp(y_i)\Bigr) = \delta + \log\!\Bigl(\sum_{i=1}^n \exp(y_i)\Bigr).
$$

That is, $\mathrm{LSE}(x) - \mathrm{LSE}(y) \leq \delta = \|x - y\|_\infty$.

By the same argument with roles of $x$ and $y$ exchanged: $\mathrm{LSE}(y) - \mathrm{LSE}(x) \leq \|x - y\|_\infty$.

Combining: $|\mathrm{LSE}(x) - \mathrm{LSE}(y)| \leq \|x - y\|_\infty$. $\blacksquare$

### Factoring $T_\tau$ through LSE

For each state $s$ and value function $V$, define the vector $q^V_s \in \mathbb{R}^A$ with components indexed by $a \in A$:

$$
q^V_s(a) = \frac{1}{\tau}\bigl(r(s,a) + \gamma \sum_{s'} P(s'|s,a) V(s')\bigr).
$$

Then the operator can be written as:

$$
(T_\tau V)(s) = \tau \cdot \mathrm{LSE}(q^V_s).
$$

This factors $T_\tau$ as the composition: $V \mapsto q^V_s \mapsto \mathrm{LSE}(q^V_s) \mapsto \tau \cdot \mathrm{LSE}(q^V_s)$.

### Contraction Proof

**Theorem (Part i).** For all $V, U \in \mathbb{R}^S$:
$$
\|T_\tau V - T_\tau U\|_\infty \leq \gamma \|V - U\|_\infty.
$$

**Proof.** Fix any state $s \in S$. We have:

$$
|(T_\tau V)(s) - (T_\tau U)(s)| = \tau \cdot |\mathrm{LSE}(q^V_s) - \mathrm{LSE}(q^U_s)|.
$$

By Lemma 1:

$$
|\mathrm{LSE}(q^V_s) - \mathrm{LSE}(q^U_s)| \leq \|q^V_s - q^U_s\|_\infty.
$$

Now we bound $\|q^V_s - q^U_s\|_\infty$. For each $a \in A$:

$$
|q^V_s(a) - q^U_s(a)| = \frac{1}{\tau}\Bigl|r(s,a) + \gamma \sum_{s'} P(s'|s,a) V(s') - r(s,a) - \gamma \sum_{s'} P(s'|s,a) U(s')\Bigr|
$$

$$
= \frac{\gamma}{\tau} \Bigl|\sum_{s'} P(s'|s,a) \bigl(V(s') - U(s')\bigr)\Bigr|.
$$

Since $P(\cdot|s,a)$ is a probability distribution over $S$ (i.e., $P(s'|s,a) \geq 0$ for all $s'$ and $\sum_{s'} P(s'|s,a) = 1$), we apply the triangle inequality weighted by this distribution:

$$
\Bigl|\sum_{s'} P(s'|s,a)(V(s') - U(s'))\Bigr| \leq \sum_{s'} P(s'|s,a) |V(s') - U(s')| \leq \sum_{s'} P(s'|s,a) \|V - U\|_\infty = \|V - U\|_\infty.
$$

Therefore:

$$
|q^V_s(a) - q^U_s(a)| \leq \frac{\gamma}{\tau} \|V - U\|_\infty, \quad \forall a \in A.
$$

Taking the maximum over $a$:

$$
\|q^V_s - q^U_s\|_\infty \leq \frac{\gamma}{\tau} \|V - U\|_\infty.
$$

Substituting back:

$$
|(T_\tau V)(s) - (T_\tau U)(s)| \leq \tau \cdot \frac{\gamma}{\tau} \|V - U\|_\infty = \gamma \|V - U\|_\infty.
$$

Since this holds for every $s \in S$, taking the maximum over $s$:

$$
\|T_\tau V - T_\tau U\|_\infty = \max_{s \in S} |(T_\tau V)(s) - (T_\tau U)(s)| \leq \gamma \|V - U\|_\infty.
$$

$\blacksquare$

---

## Part (ii): Convergence of Value Iteration

**Theorem (Part ii).** Let $V_0 \in \mathbb{R}^S$ be arbitrary. Define $V_{k+1} = T_\tau V_k$. Then $T_\tau$ has a unique fixed point $V^*_\tau \in \mathbb{R}^S$ and:

$$
\|V_k - V^*_\tau\|_\infty \leq \gamma^k \|V_0 - V^*_\tau\|_\infty.
$$

**Proof.** We apply the Banach Fixed-Point Theorem. We verify the hypotheses:

**1. The space $(\mathbb{R}^S, \|\cdot\|_\infty)$ is a complete metric space.**

$\mathbb{R}^S$ is a finite-dimensional normed space (isomorphic to $\mathbb{R}^{|S|}$), hence complete (every Cauchy sequence converges). The metric is $d(V, U) = \|V - U\|_\infty$.

**2. $T_\tau$ maps $\mathbb{R}^S$ to $\mathbb{R}^S$.**

For any $V \in \mathbb{R}^S$ and any $s \in S$, the sum $\sum_a \exp(\cdots)$ is a finite sum of positive real numbers, hence positive and finite. Therefore $\tau \log(\cdot)$ is a well-defined real number. Thus $T_\tau V \in \mathbb{R}^S$.

**3. $T_\tau$ is a contraction with factor $\gamma \in (0,1)$.**

This was established in Part (i): $\|T_\tau V - T_\tau U\|_\infty \leq \gamma \|V - U\|_\infty$ with $\gamma < 1$.

By the Banach Fixed-Point Theorem, $T_\tau$ has a unique fixed point $V^*_\tau \in \mathbb{R}^S$, i.e., $T_\tau V^*_\tau = V^*_\tau$.

Moreover, for the iterates $V_{k+1} = T_\tau V_k$, we have by induction:

**Base case** ($k=0$): $\|V_0 - V^*_\tau\|_\infty \leq \gamma^0 \|V_0 - V^*_\tau\|_\infty = \|V_0 - V^*_\tau\|_\infty$. ✓

**Inductive step**: Assume $\|V_k - V^*_\tau\|_\infty \leq \gamma^k \|V_0 - V^*_\tau\|_\infty$. Then:

$$
\|V_{k+1} - V^*_\tau\|_\infty = \|T_\tau V_k - T_\tau V^*_\tau\|_\infty \leq \gamma \|V_k - V^*_\tau\|_\infty \leq \gamma \cdot \gamma^k \|V_0 - V^*_\tau\|_\infty = \gamma^{k+1} \|V_0 - V^*_\tau\|_\infty.
$$

The first inequality uses the $\gamma$-contraction property from Part (i), and the second uses the inductive hypothesis. This completes the induction.

Since $\gamma \in (0,1)$, we have $\gamma^k \to 0$ as $k \to \infty$, so $V_k \to V^*_\tau$ in $\ell^\infty$. $\blacksquare$

---

## Part (iii): Optimal Policy is Gibbs (Softmax)

### Variational Characterization of Log-Sum-Exp

**Lemma 2 (Variational Representation of LSE).** For any $z \in \mathbb{R}^n$:

$$
\log\!\Bigl(\sum_{i=1}^n \exp(z_i)\Bigr) = \max_{\pi \in \Delta_n} \Bigl\{\sum_{i=1}^n \pi_i z_i + H(\pi)\Bigr\},
$$

where $\Delta_n = \{\pi \in \mathbb{R}^n : \pi_i \geq 0,\, \sum_i \pi_i = 1\}$ is the probability simplex and $H(\pi) = -\sum_{i=1}^n \pi_i \log \pi_i$ is the Shannon entropy (with the convention $0 \log 0 = 0$).

Furthermore, the unique maximizer is $\pi^*_i = \frac{\exp(z_i)}{\sum_{j=1}^n \exp(z_j)}$ (the softmax distribution).

**Proof of Lemma 2.** Define $f(\pi) = \sum_i \pi_i z_i + H(\pi) = \sum_i \pi_i z_i - \sum_i \pi_i \log \pi_i$ over $\Delta_n$.

We first verify that $f$ is strictly concave on $\Delta_n$. The linear term $\sum_i \pi_i z_i$ does not affect concavity, so it suffices to show that the Shannon entropy $H(\pi) = -\sum_i \pi_i \log \pi_i$ is strictly concave on the interior of $\Delta_n$. The Hessian of $H$ is the diagonal matrix $\nabla^2 H = -\mathrm{diag}(1/\pi_1, \ldots, 1/\pi_n)$. The tangent space of $\Delta_n$ is $T = \{v \in \mathbb{R}^n : \sum_i v_i = 0\}$. For any $v \in T$ with $v \neq 0$:

$$
v^\top \nabla^2 H \, v = -\sum_{i=1}^n \frac{v_i^2}{\pi_i} < 0,
$$

since $\pi_i > 0$ for all $i$ in the interior and $v \neq 0$ implies at least one $v_i \neq 0$. Therefore $\nabla^2 H$ is negative definite on $T$, confirming that $H$ (and hence $f$) is strictly concave on the relative interior of $\Delta_n$. Any critical point in the relative interior is therefore the unique global maximizer.

Setting up the Lagrangian with constraint $\sum_i \pi_i = 1$:

$$
\mathcal{L}(\pi, \lambda) = \sum_i \pi_i z_i - \sum_i \pi_i \log \pi_i - \lambda\bigl(\sum_i \pi_i - 1\bigr).
$$

Taking the partial derivative with respect to $\pi_i$ and setting it to zero:

$$
\frac{\partial \mathcal{L}}{\partial \pi_i} = z_i - \log \pi_i - 1 - \lambda = 0.
$$

This gives $\log \pi_i = z_i - 1 - \lambda$, i.e., $\pi_i = \exp(z_i - 1 - \lambda)$.

Applying the constraint $\sum_i \pi_i = 1$:

$$
\sum_i \exp(z_i - 1 - \lambda) = 1 \implies \exp(1 + \lambda) = \sum_i \exp(z_i).
$$

Therefore:

$$
\pi^*_i = \frac{\exp(z_i)}{\sum_j \exp(z_j)}.
$$

Note $\pi^*_i > 0$ for all $i$, so this is in the relative interior of $\Delta_n$, confirming it is the unique global maximizer.

Now we compute the maximum value:

$$
f(\pi^*) = \sum_i \pi^*_i z_i - \sum_i \pi^*_i \log \pi^*_i.
$$

We have $\log \pi^*_i = z_i - \log\bigl(\sum_j \exp(z_j)\bigr)$, so:

$$
\sum_i \pi^*_i \log \pi^*_i = \sum_i \pi^*_i \Bigl(z_i - \log\bigl(\sum_j \exp(z_j)\bigr)\Bigr) = \sum_i \pi^*_i z_i - \log\bigl(\sum_j \exp(z_j)\bigr).
$$

Therefore:

$$
f(\pi^*) = \sum_i \pi^*_i z_i - \sum_i \pi^*_i z_i + \log\bigl(\sum_j \exp(z_j)\bigr) = \log\bigl(\sum_j \exp(z_j)\bigr) = \mathrm{LSE}(z).
$$

$\blacksquare$

### Deriving the Optimal Policy

**Theorem (Part iii).** The optimal policy for the entropy-regularized MDP is:

$$
\pi^*_\tau(a|s) = \frac{\exp(Q^*_\tau(s,a)/\tau)}{\sum_{a'} \exp(Q^*_\tau(s,a')/\tau)},
$$

where $Q^*_\tau(s,a) = r(s,a) + \gamma \sum_{s'} P(s'|s,a) V^*_\tau(s')$.

**Proof.** Define $Q^V_\tau(s,a) = r(s,a) + \gamma \sum_{s'} P(s'|s,a) V(s')$ for any value function $V$. Then:

$$
(T_\tau V)(s) = \tau \log\!\Bigl(\sum_a \exp\bigl(Q^V_\tau(s,a)/\tau\bigr)\Bigr).
$$

Applying Lemma 2 with $z_a = Q^V_\tau(s,a)/\tau$ and $n = A$:

$$
(T_\tau V)(s) = \tau \cdot \max_{\pi(\cdot|s) \in \Delta_A} \Bigl\{\sum_a \pi(a|s) \frac{Q^V_\tau(s,a)}{\tau} + H(\pi(\cdot|s))\Bigr\}
$$

$$
= \max_{\pi(\cdot|s) \in \Delta_A} \Bigl\{\sum_a \pi(a|s) Q^V_\tau(s,a) + \tau H(\pi(\cdot|s))\Bigr\}
$$

$$
= \max_{\pi(\cdot|s) \in \Delta_A} \Bigl\{\sum_a \pi(a|s) \bigl[r(s,a) + \gamma \sum_{s'} P(s'|s,a) V(s')\bigr] + \tau H(\pi(\cdot|s))\Bigr\}.
$$

This is the one-step entropy-regularized Bellman equation: at each state $s$, the agent maximizes the expected immediate reward plus discounted future value, with a bonus of $\tau H(\pi(\cdot|s))$ encouraging exploration.

At the fixed point $V^*_\tau = T_\tau V^*_\tau$, define $Q^*_\tau(s,a) = Q^{V^*_\tau}_\tau(s,a) = r(s,a) + \gamma \sum_{s'} P(s'|s,a) V^*_\tau(s')$.

By Lemma 2, the unique maximizer of $\sum_a \pi(a|s) Q^*_\tau(s,a)/\tau + H(\pi(\cdot|s))$ over $\pi(\cdot|s) \in \Delta_A$ is:

$$
\pi^*_\tau(a|s) = \frac{\exp(Q^*_\tau(s,a)/\tau)}{\sum_{a'} \exp(Q^*_\tau(s,a')/\tau)}.
$$

This is the Gibbs (softmax) policy. It is the unique optimal policy for the entropy-regularized MDP.

**Verification that this policy achieves $V^*_\tau$:** Under policy $\pi^*_\tau$, the entropy-regularized Bellman equation reads:

$$
V^*_\tau(s) = \sum_a \pi^*_\tau(a|s)\bigl[r(s,a) + \gamma \sum_{s'} P(s'|s,a) V^*_\tau(s')\bigr] + \tau H(\pi^*_\tau(\cdot|s)),
$$

which is precisely $V^*_\tau(s) = (T_\tau V^*_\tau)(s)$, the fixed-point equation. $\blacksquare$

---

## Part (iv): Approximation Error Bound

**Theorem (Part iv).** Let $V^*$ be the optimal value function of the unregularized MDP and $V^*_\tau$ be the fixed point of $T_\tau$. Then:

$$
\|V^*_\tau - V^*\|_\infty \leq \frac{\tau \log A}{1 - \gamma}.
$$

**Proof.** The proof proceeds in three steps: (1) relate $T_\tau$ to the standard Bellman optimality operator $T$, (2) bound the per-step difference, and (3) propagate through the geometric series.

**Step 1: Define the standard Bellman optimality operator.**

$$
(TV)(s) = \max_{a \in A}\bigl\{r(s,a) + \gamma \sum_{s'} P(s'|s,a) V(s')\bigr\}.
$$

We verify that $T$ is a $\gamma$-contraction in $\ell^\infty$. For any $V, U \in \mathbb{R}^S$ and any $s \in S$, let $Q_a^V = r(s,a) + \gamma \sum_{s'} P(s'|s,a) V(s')$. Then:

$$
|(TV)(s) - (TU)(s)| = |\max_a Q_a^V - \max_a Q_a^U| \leq \max_a |Q_a^V - Q_a^U|,
$$

where the inequality holds because $|\max_a f(a) - \max_a g(a)| \leq \max_a |f(a) - g(a)|$ for any real-valued functions $f, g$. Now for each $a$:

$$
|Q_a^V - Q_a^U| = \gamma \Bigl|\sum_{s'} P(s'|s,a)(V(s') - U(s'))\Bigr| \leq \gamma \sum_{s'} P(s'|s,a) |V(s') - U(s')| \leq \gamma \|V - U\|_\infty,
$$

since $P(\cdot|s,a)$ is a probability distribution. Taking the maximum over $s$ gives $\|TV - TU\|_\infty \leq \gamma \|V - U\|_\infty$. By Banach's theorem, $T$ has a unique fixed point $V^*$.

**Step 2: Bound $T_\tau V - TV$ pointwise.**

For any $V \in \mathbb{R}^S$ and any $s \in S$, define $z_a = r(s,a) + \gamma \sum_{s'} P(s'|s,a) V(s')$ for each $a$. Then:

$$
(TV)(s) = \max_a z_a, \quad (T_\tau V)(s) = \tau \log\!\Bigl(\sum_a \exp(z_a/\tau)\Bigr).
$$

**Upper bound:** Since the sum has $A$ terms and each $\exp(z_a/\tau) \leq \exp(\max_{a'} z_{a'}/\tau)$:

$$
\sum_a \exp(z_a/\tau) \leq A \cdot \exp(\max_{a'} z_{a'}/\tau).
$$

Taking $\tau \log$:

$$
(T_\tau V)(s) \leq \tau \log\!\bigl(A \cdot \exp(\max_{a'} z_{a'}/\tau)\bigr) = \tau \log A + \max_{a'} z_{a'} = (TV)(s) + \tau \log A.
$$

**Lower bound:** Since $\sum_a \exp(z_a/\tau) \geq \max_a \exp(z_a/\tau) = \exp(\max_a z_a/\tau)$:

$$
(T_\tau V)(s) \geq \tau \log\!\bigl(\exp(\max_a z_a/\tau)\bigr) = \max_a z_a = (TV)(s).
$$

Combining the upper and lower bounds:

$$
0 \leq (T_\tau V)(s) - (TV)(s) \leq \tau \log A, \quad \forall s \in S, \; \forall V \in \mathbb{R}^S. \tag{$\star$}
$$

**Step 3: Propagate the per-step bound to the fixed points.**

We show $V^*_\tau(s) \geq V^*(s)$ and $V^*_\tau(s) \leq V^*(s) + \frac{\tau \log A}{1 - \gamma}$ for all $s$.

**Lower bound ($V^*_\tau \geq V^*$):** From ($\star$), $T_\tau V \geq TV$ pointwise for all $V$. We use this to show by induction that if $V_0 = V^*$ and $V_{k+1} = T_\tau V_k$, then $V_k \geq V^*$ for all $k$.

$T_\tau$ is monotone: if $V \geq U$ pointwise, then for each $(s, a)$ the Q-value $z_a(s) = r(s,a) + \gamma \sum_{s'} P(s'|s,a) V(s')$ satisfies $z_a^V(s) \geq z_a^U(s)$ (since $P(s'|s,a) \geq 0$). Moreover, $\mathrm{LSE}$ is strictly increasing in each argument: $\partial \mathrm{LSE}(x)/\partial x_i = \exp(x_i)/\sum_j \exp(x_j) = \mathrm{softmax}(x)_i > 0$. Therefore $T_\tau V \geq T_\tau U$ pointwise. Equivalently, $\partial(T_\tau V)(s)/\partial V(s') = \gamma \sum_a \pi_\tau(a|s) P(s'|s,a) \geq 0$, where $\pi_\tau(a|s) = \mathrm{softmax}(z/\tau)_a > 0$ is the softmax policy with all components strictly positive.

Base case: $V_0 = V^* \geq V^*$. ✓

Inductive step: If $V_k \geq V^*$, then by monotonicity of $T_\tau$:

$$
V_{k+1} = T_\tau V_k \geq T_\tau V^* \geq TV^* = V^*.
$$

The last inequality uses ($\star$) with "$\geq$" and the last equality uses the fact that $V^*$ is the fixed point of $T$.

By Part (ii), $V_k \to V^*_\tau$, and since $V_k \geq V^*$ for all $k$ and limits preserve weak inequalities, $V^*_\tau \geq V^*$.

**Upper bound ($V^*_\tau \leq V^* + \frac{\tau \log A}{1 - \gamma}$):** Define $W = V^* + \frac{\tau \log A}{1 - \gamma} \mathbf{1}$, where $\mathbf{1}$ is the all-ones vector. We show $T_\tau W \leq W$ (i.e., $W$ is a "super-fixed-point" of $T_\tau$).

For any state $s$:

$$
(T_\tau W)(s) \leq (TW)(s) + \tau \log A,
$$

by the upper bound in ($\star$).

Now, since $T$ is a $\gamma$-contraction with fixed point $V^*$, and $W = V^* + c\mathbf{1}$ where $c = \frac{\tau \log A}{1 - \gamma}$:

$$
(TW)(s) = \max_a \Bigl\{r(s,a) + \gamma \sum_{s'} P(s'|s,a) W(s')\Bigr\} = \max_a \Bigl\{r(s,a) + \gamma \sum_{s'} P(s'|s,a)\bigl(V^*(s') + c\bigr)\Bigr\}.
$$

Since $\sum_{s'} P(s'|s,a) = 1$:

$$
(TW)(s) = \max_a \Bigl\{r(s,a) + \gamma \sum_{s'} P(s'|s,a) V^*(s') + \gamma c\Bigr\} = (TV^*)(s) + \gamma c = V^*(s) + \gamma c.
$$

Therefore:

$$
(T_\tau W)(s) \leq V^*(s) + \gamma c + \tau \log A = V^*(s) + \gamma \cdot \frac{\tau \log A}{1 - \gamma} + \tau \log A.
$$

$$
= V^*(s) + \tau \log A \Bigl(\frac{\gamma}{1-\gamma} + 1\Bigr) = V^*(s) + \tau \log A \cdot \frac{1}{1 - \gamma} = W(s).
$$

So $T_\tau W \leq W$ pointwise.

Now we iterate: starting from $W$ and applying $T_\tau$ repeatedly, using monotonicity of $T_\tau$:

- $T_\tau W \leq W$
- $T^2_\tau W = T_\tau(T_\tau W) \leq T_\tau W \leq W$ (monotonicity of $T_\tau$ applied to $T_\tau W \leq W$)
- By induction: $T^k_\tau W \leq W$ for all $k \geq 0$.

By Part (ii), $T^k_\tau W \to V^*_\tau$ as $k \to \infty$. Since $T^k_\tau W \leq W$ for all $k$ and limits preserve weak inequalities:

$$
V^*_\tau \leq W = V^* + \frac{\tau \log A}{1 - \gamma} \mathbf{1}.
$$

**Combining:** $V^* \leq V^*_\tau \leq V^* + \frac{\tau \log A}{1 - \gamma}\mathbf{1}$, hence:

$$
0 \leq V^*_\tau(s) - V^*(s) \leq \frac{\tau \log A}{1 - \gamma}, \quad \forall s \in S.
$$

Taking the $\ell^\infty$ norm:

$$
\|V^*_\tau - V^*\|_\infty \leq \frac{\tau \log A}{1 - \gamma}.
$$

$\blacksquare$

---

## Summary of Results

| Part | Statement | Key technique |
|------|-----------|---------------|
| (i) | $\|T_\tau V - T_\tau U\|_\infty \leq \gamma \|V - U\|_\infty$ | LSE is 1-Lipschitz in $\ell^\infty$; factor $T_\tau = \tau \cdot \mathrm{LSE} \circ (\text{affine map with coefficient } \gamma/\tau)$ |
| (ii) | $\|V_k - V^*_\tau\|_\infty \leq \gamma^k \|V_0 - V^*_\tau\|_\infty$ | Banach Fixed-Point Theorem on complete space $(\mathbb{R}^S, \|\cdot\|_\infty)$ |
| (iii) | $\pi^*_\tau(a|s) = \frac{\exp(Q^*_\tau(s,a)/\tau)}{\sum_{a'}\exp(Q^*_\tau(s,a')/\tau)}$ | Variational characterization $\mathrm{LSE}(z) = \max_\pi \{\langle \pi, z\rangle + H(\pi)\}$; strict concavity gives unique maximizer |
| (iv) | $\|V^*_\tau - V^*\|_\infty \leq \frac{\tau \log A}{1 - \gamma}$ | Per-step bound $0 \leq T_\tau V - TV \leq \tau\log A$; monotone iteration with super-fixed-point argument |

**Proof status: COMPLETE. All four parts proved rigorously. All audit fixes applied.**
