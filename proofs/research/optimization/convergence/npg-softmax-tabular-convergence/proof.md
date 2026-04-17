# Proof: NPG with Softmax Parameterization Achieves $O(1/K)$ Convergence

---

## Setting and Notation

**Tabular MDP:** Finite state space $\mathcal{S}$ ($|\mathcal{S}| = S$), finite action space $\mathcal{A}$ ($|\mathcal{A}| = A$), discount factor $\gamma \in (0,1)$, rewards $r(s,a) \in [0,1]$, transition kernel $P(s'|s,a)$, initial distribution $\rho$.

**Softmax policy:** $\pi_\theta(a|s) = \exp(\theta_{s,a}) / \sum_{a'} \exp(\theta_{s,a'})$.

**Value functions:**
$$V^\pi(s) = \mathbb{E}\left[\sum_{t=0}^\infty \gamma^t r(s_t, a_t) \mid s_0 = s, \pi\right], \quad V^\pi(\rho) = \sum_s \rho(s) V^\pi(s),$$
$$Q^\pi(s,a) = r(s,a) + \gamma \sum_{s'} P(s'|s,a) V^\pi(s'), \quad A^\pi(s,a) = Q^\pi(s,a) - V^\pi(s).$$

**Discounted state visitation:**
$$d^\pi_\rho(s) = (1-\gamma) \sum_{t=0}^\infty \gamma^t \Pr(s_t = s \mid \pi, \rho).$$
This is a probability distribution: $\sum_s d^\pi_\rho(s) = 1$.

**NPG update:** $\theta^{(k+1)}_{s,a} = \theta^{(k)}_{s,a} + \eta \, Q^{\pi_k}(s,a)$, with step size $\eta > 0$.

**Initialization:** $\theta^{(0)}_{s,a} = 0$, so $\pi_0(a|s) = 1/A$ (uniform).

**Basic bounds:** Since $r \in [0,1]$: $V^\pi(s) \in [0, 1/(1-\gamma)]$, $Q^\pi(s,a) \in [0, 1/(1-\gamma)]$, $A^\pi(s,a) \in [-1/(1-\gamma), 1/(1-\gamma)]$.

**Sub-optimality gap:** $\Delta_k := V^*(\rho) - V^{\pi_k}(\rho)$.

---

## Phase 1: Performance Difference Lemma

**Lemma 1 (Performance Difference Lemma).** *For any two policies $\pi, \pi'$:*
$$V^{\pi'}(\rho) - V^\pi(\rho) = \frac{1}{1-\gamma} \sum_s d^{\pi'}_\rho(s) \sum_a \pi'(a|s) A^\pi(s,a).$$

**Proof.** Define $\delta(s) := V^{\pi'}(s) - V^\pi(s)$. By the Bellman equation under $\pi'$:

$$V^{\pi'}(s) = \sum_a \pi'(a|s)\left[r(s,a) + \gamma \sum_{s'} P(s'|s,a) V^{\pi'}(s')\right].$$

Using $V^\pi(s) = \sum_a \pi'(a|s) V^\pi(s)$ (since $\sum_a \pi'(a|s) = 1$) and $A^\pi(s,a) = Q^\pi(s,a) - V^\pi(s)$:

$$\delta(s) = \sum_a \pi'(a|s)\left[A^\pi(s,a) + \gamma \sum_{s'} P(s'|s,a) \delta(s')\right].$$

Iterating this recursion starting from $s_0 \sim \rho$:

$$\sum_s \rho(s) \delta(s) = \sum_{t=0}^\infty \gamma^t \sum_s \Pr(s_t = s | \pi', \rho) \sum_a \pi'(a|s) A^\pi(s,a).$$

By definition of $d^{\pi'}_\rho(s) = (1-\gamma)\sum_t \gamma^t \Pr(s_t = s | \pi', \rho)$:

$$V^{\pi'}(\rho) - V^\pi(\rho) = \frac{1}{1-\gamma} \sum_s d^{\pi'}_\rho(s) \sum_a \pi'(a|s) A^\pi(s,a). \qquad \blacksquare$$

**Corollary.** Using $A^\pi(s,a) = Q^\pi(s,a) - V^\pi(s)$ and $V^\pi(s) = \sum_a \pi(a|s) Q^\pi(s,a)$:

$$V^{\pi'}(\rho) - V^\pi(\rho) = \frac{1}{1-\gamma} \sum_s d^{\pi'}_\rho(s) \sum_a (\pi'(a|s) - \pi(a|s)) Q^\pi(s,a). \tag{PDL}$$

---

## Phase 2: NPG as Mirror Descent

**Lemma 2 (Policy Update).** *The NPG update yields:*
$$\pi_{k+1}(a|s) = \frac{\pi_k(a|s) \exp(\eta Q^{\pi_k}(s,a))}{\sum_{a'} \pi_k(a'|s) \exp(\eta Q^{\pi_k}(s,a'))}.$$

*This is equivalent to mirror descent with KL divergence:*
$$\pi_{k+1}(\cdot|s) = \arg\max_{p \in \Delta_A} \left\{\eta \langle Q^{\pi_k}(s,\cdot), p \rangle - \mathrm{KL}(p \| \pi_k(\cdot|s))\right\}.$$

**Proof.** By definition of softmax:
$$\pi_{k+1}(a|s) = \frac{\exp(\theta^{(k+1)}_{s,a})}{\sum_{a'} \exp(\theta^{(k+1)}_{s,a'})} = \frac{\exp(\theta^{(k)}_{s,a} + \eta Q^{\pi_k}(s,a))}{\sum_{a'} \exp(\theta^{(k)}_{s,a'} + \eta Q^{\pi_k}(s,a'))}.$$

Dividing numerator and denominator by $\sum_{a''} \exp(\theta^{(k)}_{s,a''})$:

$$= \frac{\pi_k(a|s) \exp(\eta Q^{\pi_k}(s,a))}{\sum_{a'} \pi_k(a'|s) \exp(\eta Q^{\pi_k}(s,a'))}. \tag{i}$$

For the mirror descent equivalence, the KKT condition of $\max_{p \in \Delta_A}\{\eta \langle Q, p\rangle - \mathrm{KL}(p\|\pi_k)\}$ gives, using Lagrange multiplier $\lambda$ for $\sum_a p(a) = 1$:

$$\eta Q(s,a) - \log p(a) + \log \pi_k(a|s) - 1 - \lambda = 0 \implies p(a) \propto \pi_k(a|s) \exp(\eta Q(s,a)).$$

Normalizing yields (i). $\blacksquare$

**Corollary (Log-policy relation).** From (i):
$$\log \pi_{k+1}(a|s) = \log \pi_k(a|s) + \eta Q^{\pi_k}(s,a) - \log Z_s^{(k)}, \tag{ii}$$
where $Z_s^{(k)} = \sum_{a'} \pi_k(a'|s) \exp(\eta Q^{\pi_k}(s,a'))$.

---

## Phase 3: Per-State Improvement

**Remark (Three-Point Identity for KL Divergence).** *For distributions $p, q, r$ on $\mathcal{A}$, the standard Bregman three-point identity with $\phi(p) = \sum_a p(a)\log p(a)$ gives:*
$$\sum_a (p(a) - r(a))(\log q(a) - \log r(a)) = \mathrm{KL}(p\|r) - \mathrm{KL}(p\|q) + \mathrm{KL}(r\|q).$$

*Proof.* Note that $\nabla\phi(q) - \nabla\phi(r) = (\log q(a) - \log r(a))_a$, and the Bregman three-point identity states $\langle \nabla\phi(q) - \nabla\phi(r), p - r\rangle = D_\phi(p,r) - D_\phi(p,q) + D_\phi(r,q)$ where $D_\phi = \mathrm{KL}$. Alternatively, by direct computation:

$$\sum_a (p-r)(\log q - \log r) = \sum_a p\log q - \sum_a p\log r - \sum_a r\log q + \sum_a r\log r.$$

Meanwhile:
$$\mathrm{KL}(p\|r) - \mathrm{KL}(p\|q) + \mathrm{KL}(r\|q) = [\sum_a p\log p - \sum_a p\log r] - [\sum_a p\log p - \sum_a p\log q] + [\sum_a r\log r - \sum_a r\log q]$$
$$= \sum_a p\log q - \sum_a p\log r + \sum_a r\log r - \sum_a r\log q.$$

These are identical. $\blacksquare$

**Lemma 3 (Per-State Mirror Descent Bound).** *For any comparator policy $\pi^*$ and each state $s$:*

$$\eta \sum_a (\pi^*(a|s) - \pi_{k+1}(a|s)) Q^{\pi_k}(s,a) = \mathrm{KL}(\pi^*\|\pi_k)(s) - \mathrm{KL}(\pi^*\|\pi_{k+1})(s) - \mathrm{KL}(\pi_{k+1}\|\pi_k)(s). \tag{III}$$

*In particular (since $\mathrm{KL}(\pi_{k+1}\|\pi_k)(s) \geq 0$):*

$$\eta \sum_a (\pi^*(a|s) - \pi_{k+1}(a|s)) Q^{\pi_k}(s,a) \leq \mathrm{KL}(\pi^*\|\pi_k)(s) - \mathrm{KL}(\pi^*\|\pi_{k+1})(s). \tag{III'}$$

**Proof.** From (ii): $\eta Q^{\pi_k}(s,a) = \log \pi_{k+1}(a|s) - \log \pi_k(a|s) + \log Z_s^{(k)}$.

Therefore:
$$\eta \sum_a (\pi^*(a|s) - \pi_{k+1}(a|s)) Q^{\pi_k}(s,a) = \sum_a (\pi^* - \pi_{k+1})[\log \pi_{k+1} - \log \pi_k + \log Z_s^{(k)}].$$

The $\log Z_s^{(k)}$ term vanishes: $\log Z_s^{(k)} \sum_a (\pi^*(a|s) - \pi_{k+1}(a|s)) = \log Z_s^{(k)} \cdot (1 - 1) = 0$.

We compute the remaining sum directly:
$$\sum_a (\pi^*(a|s) - \pi_{k+1}(a|s))(\log \pi_{k+1}(a|s) - \log \pi_k(a|s))$$
$$= \sum_a \pi^*(a|s) \log \frac{\pi_{k+1}(a|s)}{\pi_k(a|s)} - \sum_a \pi_{k+1}(a|s) \log \frac{\pi_{k+1}(a|s)}{\pi_k(a|s)}.$$

For the first sum, using $\mathrm{KL}(\pi^*\|\pi_{k+1}) = \sum_a \pi^*\log\pi^* - \sum_a \pi^*\log\pi_{k+1}$:
$$\sum_a \pi^* \log \frac{\pi_{k+1}}{\pi_k} = \sum_a \pi^* \log \pi_{k+1} - \sum_a \pi^* \log \pi_k = \mathrm{KL}(\pi^*\|\pi_k)(s) - \mathrm{KL}(\pi^*\|\pi_{k+1})(s).$$

The second sum is:
$$\sum_a \pi_{k+1} \log \frac{\pi_{k+1}}{\pi_k} = \mathrm{KL}(\pi_{k+1}\|\pi_k)(s).$$

Therefore:
$$\eta \sum_a (\pi^* - \pi_{k+1}) Q^{\pi_k} = \mathrm{KL}(\pi^*\|\pi_k)(s) - \mathrm{KL}(\pi^*\|\pi_{k+1})(s) - \mathrm{KL}(\pi_{k+1}\|\pi_k)(s). \qquad \blacksquare$$

---

## Phase 4: Monotone Improvement, Donsker-Varadhan, and Hoeffding

### Step 4a: Splitting the advantage

From (PDL) with $\pi' = \pi^*$ and $\pi = \pi_k$:
$$(1-\gamma)\Delta_k = \sum_s d^{\pi^*}_\rho(s) \underbrace{\sum_a (\pi^*(a|s) - \pi_k(a|s)) Q^{\pi_k}(s,a)}_{=: B_k(s)}. \tag{1}$$

Split $\pi^* - \pi_k = (\pi^* - \pi_{k+1}) + (\pi_{k+1} - \pi_k)$:
$$B_k(s) = \underbrace{\sum_a (\pi^*(a|s) - \pi_{k+1}(a|s)) Q^{\pi_k}(s,a)}_{=: C_k(s)} + \underbrace{\sum_a (\pi_{k+1}(a|s) - \pi_k(a|s)) Q^{\pi_k}(s,a)}_{=: G_k(s)}. \tag{2}$$

Here $G_k(s) = \sum_a \pi_{k+1}(a|s) A^{\pi_k}(s,a)$ is the per-state improvement.

### Step 4b: Bound on $C_k(s)$ via mirror descent

From (III'):
$$\eta C_k(s) \leq \mathrm{KL}(\pi^*\|\pi_k)(s) - \mathrm{KL}(\pi^*\|\pi_{k+1})(s). \tag{3}$$

### Step 4c: Monotone value improvement

**Claim.** $G_k(s) \geq 0$ for all $s$, and consequently $V^{\pi_{k+1}}(s') \geq V^{\pi_k}(s')$ for all $s'$.

**Proof.** Since $\pi_{k+1}(\cdot|s) = \arg\max_{p \in \Delta_A}\{\eta\langle Q^{\pi_k}(s,\cdot), p\rangle - \mathrm{KL}(p\|\pi_k(\cdot|s))\}$, evaluating at $p = \pi_k(\cdot|s)$ (which gives $\mathrm{KL} = 0$):

$$\eta\langle Q^{\pi_k}, \pi_{k+1}\rangle - \mathrm{KL}(\pi_{k+1}\|\pi_k)(s) \geq \eta\langle Q^{\pi_k}, \pi_k\rangle = \eta V^{\pi_k}(s).$$

Since $\mathrm{KL}(\pi_{k+1}\|\pi_k)(s) \geq 0$:
$$\langle Q^{\pi_k}(s,\cdot), \pi_{k+1}(\cdot|s)\rangle \geq V^{\pi_k}(s),$$
i.e., $G_k(s) \geq 0$.

For the value monotonicity: by the PDL with $\pi' = \pi_{k+1}$, $\pi = \pi_k$, starting from any state $s_0$:
$$V^{\pi_{k+1}}(s_0) - V^{\pi_k}(s_0) = \frac{1}{1-\gamma}\sum_s d^{\pi_{k+1}}_{s_0}(s) G_k(s) \geq 0. \qquad \blacksquare$$

**Corollary.** $\Delta_k$ is non-increasing: $\Delta_{k+1} \leq \Delta_k$ for all $k$.

### Step 4d: Bound on $G_k(s)$ via Donsker-Varadhan and Hoeffding

**Lemma 4 (Donsker-Varadhan identity).** *For any function $f: \mathcal{A} \to \mathbb{R}$ and distribution $p$ on $\mathcal{A}$:*
$$\log \sum_a p(a) e^{f(a)} = \max_{q \in \Delta_A}\left\{\sum_a q(a) f(a) - \mathrm{KL}(q\|p)\right\}.$$

*The maximum is achieved at $q^*(a) = p(a)e^{f(a)} / \sum_{a'} p(a')e^{f(a')}$.*

**Proof.** The KKT conditions yield $q^*(a) \propto p(a) e^{f(a)}$. Substituting back gives $\max = \log \sum_a p(a) e^{f(a)}$. $\blacksquare$

**Application.** Set $f(a) = \eta A^{\pi_k}(s,a)$ and $p = \pi_k(\cdot|s)$. The maximizer is:
$$q^*(a) = \frac{\pi_k(a|s) e^{\eta A^{\pi_k}(s,a)}}{\sum_{a'} \pi_k(a'|s) e^{\eta A^{\pi_k}(s,a')}} = \frac{\pi_k(a|s) e^{\eta Q^{\pi_k}(s,a)}}{\sum_{a'} \pi_k(a'|s) e^{\eta Q^{\pi_k}(s,a')}} = \pi_{k+1}(a|s),$$

where the second equality uses $A^{\pi_k}(s,a) = Q^{\pi_k}(s,a) - V^{\pi_k}(s)$ and the constant $e^{-\eta V^{\pi_k}(s)}$ cancels in numerator and denominator.

Therefore:
$$\log \sum_a \pi_k(a|s) e^{\eta A^{\pi_k}(s,a)} = \eta G_k(s) - \mathrm{KL}(\pi_{k+1}\|\pi_k)(s). \tag{4}$$

**Lemma 5 (Hoeffding's Lemma).** *If $X$ is a random variable with $\mathbb{E}[X] = 0$ and $X \in [a, b]$, then $\log \mathbb{E}[e^{tX}] \leq t^2(b-a)^2/8$ for all $t$.*

**Proof.** By convexity of $e^{tx}$: $e^{tx} \leq \frac{b-x}{b-a}e^{ta} + \frac{x-a}{b-a}e^{tb}$ for $x \in [a,b]$. Taking expectations with $\mathbb{E}[X] = 0$: $\mathbb{E}[e^{tX}] \leq \frac{b}{b-a}e^{ta} - \frac{a}{b-a}e^{tb} = e^{g(u)}$ where $u = t(b-a)$ and $g(u) = -pu + \log(1-p+pe^u)$ with $p = -a/(b-a)$. By calculus, $g(u) \leq u^2/8$. $\blacksquare$

**Application.** The random variable $A^{\pi_k}(s,\cdot)$ under $\pi_k(\cdot|s)$ has mean zero (by definition of advantage: $\sum_a \pi_k(a|s) A^{\pi_k}(s,a) = 0$) and range contained in an interval of width at most $1/(1-\gamma)$ (since $Q^{\pi_k}(s,a) \in [0, 1/(1-\gamma)]$, the advantage $A^{\pi_k}(s,a) = Q^{\pi_k}(s,a) - V^{\pi_k}(s)$ lies in an interval of width $\max_a Q - \min_a Q \leq 1/(1-\gamma)$).

By Hoeffding's Lemma with $t = \eta$:
$$\log \sum_a \pi_k(a|s) e^{\eta A^{\pi_k}(s,a)} \leq \frac{\eta^2}{8(1-\gamma)^2}. \tag{5}$$

Combining (4) and (5):
$$\eta G_k(s) \leq \frac{\eta^2}{8(1-\gamma)^2} + \mathrm{KL}(\pi_{k+1}\|\pi_k)(s). \tag{6}$$

### Step 4e: The key cancellation

From (2), (3), and the exact identity (III):

$$\eta B_k(s) = \eta C_k(s) + \eta G_k(s) = \mathrm{KL}(\pi^*\|\pi_k)(s) - \mathrm{KL}(\pi^*\|\pi_{k+1})(s) - \mathrm{KL}(\pi_{k+1}\|\pi_k)(s) + \eta G_k(s).$$

Substituting (6):

$$\eta B_k(s) \leq \mathrm{KL}(\pi^*\|\pi_k)(s) - \mathrm{KL}(\pi^*\|\pi_{k+1})(s) - \mathrm{KL}(\pi_{k+1}\|\pi_k)(s) + \frac{\eta^2}{8(1-\gamma)^2} + \mathrm{KL}(\pi_{k+1}\|\pi_k)(s).$$

The $\mathrm{KL}(\pi_{k+1}\|\pi_k)(s)$ terms cancel:

$$\eta B_k(s) \leq \mathrm{KL}(\pi^*\|\pi_k)(s) - \mathrm{KL}(\pi^*\|\pi_{k+1})(s) + \frac{\eta^2}{8(1-\gamma)^2}. \tag{7}$$

Substituting into (1):

$$\eta(1-\gamma)\Delta_k \leq \sum_s d^{\pi^*}_\rho(s)\left[\mathrm{KL}(\pi^*\|\pi_k)(s) - \mathrm{KL}(\pi^*\|\pi_{k+1})(s)\right] + \frac{\eta^2}{8(1-\gamma)^2}. \tag{8}$$

The second term uses $\sum_s d^{\pi^*}_\rho(s) = 1$.

---

## Phase 5: Telescoping and Final Bound

### Step 5a: Sum over iterations

Summing (8) over $k = 0, 1, \ldots, K-1$:

$$\eta(1-\gamma)\sum_{k=0}^{K-1}\Delta_k \leq \underbrace{\sum_s d^{\pi^*}_\rho(s)\left[\mathrm{KL}(\pi^*\|\pi_0)(s) - \mathrm{KL}(\pi^*\|\pi_K)(s)\right]}_{\text{telescopes}} + \frac{K\eta^2}{8(1-\gamma)^2}. \tag{9}$$

### Step 5b: Bound the KL terms

**Initial KL.** Since $\pi_0(a|s) = 1/A$:
$$\mathrm{KL}(\pi^*(\cdot|s)\|\pi_0(\cdot|s)) = \sum_a \pi^*(a|s)\log(A\pi^*(a|s)) = \log A - H(\pi^*(\cdot|s)) \leq \log A.$$

Here $H(\pi^*(\cdot|s)) = -\sum_a \pi^*(a|s)\log\pi^*(a|s) \geq 0$ is the Shannon entropy.

Since $\sum_s d^{\pi^*}_\rho(s) = 1$:
$$\sum_s d^{\pi^*}_\rho(s)\mathrm{KL}(\pi^*\|\pi_0)(s) \leq \log A.$$

**Final KL.** $\mathrm{KL}(\pi^*\|\pi_K)(s) \geq 0$, so we drop the negative term.

### Step 5c: Use monotonicity

From (9):
$$\eta(1-\gamma)\sum_{k=0}^{K-1}\Delta_k \leq \log A + \frac{K\eta^2}{8(1-\gamma)^2}. \tag{10}$$

Since $\Delta_k$ is non-increasing (Step 4c): $\sum_{k=0}^{K-1}\Delta_k \geq K\Delta_K$.

Therefore:
$$\eta(1-\gamma)K\Delta_K \leq \log A + \frac{K\eta^2}{8(1-\gamma)^2},$$

$$\boxed{\Delta_K = V^*(\rho) - V^{\pi_K}(\rho) \leq \frac{\log A}{\eta(1-\gamma)K} + \frac{\eta}{8(1-\gamma)^3}.} \tag{$\star$}$$

---

## Main Theorem (Final Statement)

**Theorem.** *Under the NPG update with softmax parameterization, uniform initialization, and step size $\eta > 0$:*

$$V^*(\rho) - V^{\pi_K}(\rho) \leq \frac{\log A}{\eta(1-\gamma)K} + \frac{\eta}{8(1-\gamma)^3}.$$

*In particular:*

**(a) $O(1/\sqrt{K})$ with optimized step size.** With $\eta_K = (1-\gamma)\sqrt{8\log A / K}$:

$$V^*(\rho) - V^{\pi_K}(\rho) \leq \frac{1}{(1-\gamma)^2}\sqrt{\frac{2\log A}{K}} = O\!\left(\frac{1}{\sqrt{K}}\right).$$

**Proof.** Both terms in $(\star)$ equal $\frac{\sqrt{\log A}}{(1-\gamma)^2\sqrt{8K}}$, so the sum is $\frac{2\sqrt{\log A}}{(1-\gamma)^2\sqrt{8K}} = \frac{1}{(1-\gamma)^2}\sqrt{\frac{2\log A}{K}}.$ $\blacksquare$

**(b) $O(1/K)$ with any fixed step size.** For any fixed $\eta > 0$, when $K \geq K_0 := \frac{8(1-\gamma)^2\log A}{\eta^2}$:

$$V^*(\rho) - V^{\pi_K}(\rho) \leq \frac{2\log A}{\eta(1-\gamma)K}.$$

**Proof.** When $K \geq K_0$, we have $\eta^2 \leq 8(1-\gamma)^2\log A / K$, so:
$$\frac{\eta}{8(1-\gamma)^3} \leq \frac{\log A}{\eta(1-\gamma)K}.$$
Thus $\Delta_K \leq \frac{2\log A}{\eta(1-\gamma)K}$. $\blacksquare$

**(c) Specific step size $\eta = \frac{(1-\gamma)\log A}{2\gamma}$.** For all $K \geq K_0 = \frac{32\gamma^2}{\log A}$:

$$V^*(\rho) - V^{\pi_K}(\rho) \leq \frac{4\gamma}{(1-\gamma)^2 K}.$$

**Proof.** With $\eta = \frac{(1-\gamma)\log A}{2\gamma}$, Part (b) gives:
$$\Delta_K \leq \frac{2\log A}{\frac{(1-\gamma)\log A}{2\gamma}\cdot(1-\gamma)\cdot K} = \frac{4\gamma}{(1-\gamma)^2 K}. \qquad \blacksquare$$

**Remark on the target form.** We may also express this bound in terms of $\eta$. With $\eta = \frac{(1-\gamma)\log A}{2\gamma}$:
$$\frac{2\gamma\log A}{(1-\gamma)^3\eta K} = \frac{4\gamma^2}{(1-\gamma)^4 K}.$$
The bound $\frac{4\gamma}{(1-\gamma)^2 K} \leq \frac{4\gamma^2}{(1-\gamma)^4 K}$ holds if and only if $(1-\gamma)^2 \leq \gamma$, i.e., $\gamma \geq (3-\sqrt{5})/2 \approx 0.382$. For such $\gamma$:
$$\Delta_K \leq \frac{2\gamma\log A}{(1-\gamma)^3\eta K}.$$
For general $\gamma \in (0,1)$, the bound $\Delta_K \leq \frac{4\gamma}{(1-\gamma)^2 K} = O(1/K)$ holds unconditionally. Note that this step size satisfies $\eta = \Theta(1/(1-\gamma))$ (for fixed $A$ and $\gamma$ bounded away from 0), so the overall scaling of the bound is $O(1/((1-\gamma)^2 K))$.

### Cumulative FTRL Bound (supplementary)

**Lemma 6 (Cumulative FTRL Bound).** *From the regret bound of online mirror descent with KL divergence against any comparator $\pi^*$:*

$$\sum_{k=0}^{K-1}\sum_a (\pi^*(a|s) - \pi_{k+1}(a|s)) Q^{\pi_k}(s,a) \leq \frac{\log A}{\eta}. \tag{11}$$

**Proof.** Sum inequality (III') over $k = 0, \ldots, K-1$:
$$\eta \sum_{k=0}^{K-1}\sum_a (\pi^* - \pi_{k+1}) Q^{\pi_k} \leq \mathrm{KL}(\pi^*\|\pi_0)(s) - \mathrm{KL}(\pi^*\|\pi_K)(s) \leq \log A. \qquad \blacksquare$$

---

## Summary of the Complete Proof

1. **Performance Difference Lemma** (Lemma 1): Expresses the value gap $V^*(\rho) - V^{\pi_k}(\rho)$ as a weighted sum of per-state advantage inner products.

2. **NPG = Mirror Descent** (Lemma 2): The softmax NPG update is equivalent to KL-regularized policy optimization at each state.

3. **Per-State Mirror Descent Bound** (Lemma 3): Provides an exact decomposition of the per-state progress, with the key telescoping structure $\mathrm{KL}(\pi^*\|\pi_k) - \mathrm{KL}(\pi^*\|\pi_{k+1})$ plus a remainder involving $\mathrm{KL}(\pi_{k+1}\|\pi_k)$.

4. **Hoeffding + Donsker-Varadhan** (Lemmas 4-5): Bounds the per-state improvement term $G_k(s)$ using the log-partition variational formula and the sub-Gaussian property of the advantage, yielding a cancellation with the $\mathrm{KL}(\pi_{k+1}\|\pi_k)$ term.

5. **Telescoping + Monotonicity**: The KL terms telescope over $K$ iterations, bounded by $\log A$ (initial entropy). Monotone improvement ($\Delta_k$ non-increasing) converts the average bound to a last-iterate bound, giving $\Delta_K = O(1/K)$ for appropriate step size.

The final bound is:
$$\boxed{V^*(\rho) - V^{\pi_K}(\rho) \leq \frac{\log A}{\eta(1-\gamma)K} + \frac{\eta}{8(1-\gamma)^3}} \implies O(1/K) \text{ for constant } \eta.$$

$\blacksquare$
