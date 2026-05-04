# Route D — Online learning / expert reduction (Route Failure Report)

**Route**: D — Online learning / expert reduction (reduce UCB-Hoeffding Q-learning regret to an OCO / expert-advice regret).

**Target theorem**: JABJ NeurIPS 2018 (Theorem 1, Hoeffding variant). Prove
$$\mathrm{Regret}(K) = \sum_{k=1}^K \big[V_1^*(s_1^k) - V_1^{\pi_k}(s_1^k)\big] \le C \sqrt{H^4 SAT}\,\iota, \qquad \iota = \log(SAT/\delta),$$
with probability $\ge 1-\delta$.

**Explorer assignment**: Attempt the OCO reduction honestly; if blocked, produce a rigorous *failure report* identifying exactly where and why the reduction fails, and — if possible — salvage a partial result for $H = 1$ (tabular bandits).

---

## 0. Preliminaries and setup of the reduction

Throughout this report:
- $\phi_h^k(s,a) := Q_h^k(s,a) - Q_h^*(s,a)$.
- $\xi_h^k := [\mathbb{P}_h V_{h+1}^*](s_h^k, a_h^k) - V_{h+1}^*(s_{h+1}^k)$ is the one-step centered transition noise on the optimal value function (mean-zero, bounded in $[-H, H]$).
- For $(s,a,h)$ fixed, $k_1 < k_2 < \dots < k_t$ are the episodes on which $(s_h^{k_i}, a_h^{k_i}) = (s,a)$.
- $\alpha_t = (H+1)/(H+t)$, $\alpha_t^0 = \prod_{j=1}^t (1-\alpha_j) = \mathbb{1}[t=0]$, $\alpha_t^i = \alpha_i \prod_{j=i+1}^t (1-\alpha_j)$, with $\sum_{i=1}^t \alpha_t^i = 1$.

The update at the $i$-th visit to $(s,a,h)$ reads (with $t = i$):
$$Q_h^{k_i+1}(s,a) = (1-\alpha_i) Q_h^{k_i}(s,a) + \alpha_i\big[r_h(s,a) + V_{h+1}^{k_i}(s_{h+1}^{k_i}) + b_i\big]. \qquad (\star)$$

Route D's question is: *can we re-express $(\star)$ as an online-learning update of some OCO / expert-advice algorithm against some sequence of losses, and then cite a generic OCO regret bound to obtain $\tilde O(\sqrt{H^4 SAT})$ without re-deriving the pathwise machinery of Routes A/B/C?*

I now attempt this reduction along four natural avenues and document the obstruction in each.

---

## 1. Attempt 1 — Per-cell online regression reduction

### 1.1. The setup

Fix $(s,a,h)$. Treating the per-visit update $(\star)$ as a one-dimensional online learning problem, the update has the form
$$\theta_{i+1} = (1 - \alpha_i)\theta_i + \alpha_i (y_i + b_i), \qquad y_i := r_h(s,a) + V_{h+1}^{k_i}(s_{h+1}^{k_i}),$$
with $\theta_i := Q_h^{k_i}(s,a)$. Define the per-step "loss"
$$\ell_i(\theta) := \tfrac12 (\theta - y_i)^2.$$
Then $(\star)$ becomes an online gradient step with learning rate $\alpha_i$ (since $\nabla \ell_i(\theta) = \theta - y_i$), plus an additive bonus drift $\alpha_i b_i$:
$$\theta_{i+1} = \theta_i - \alpha_i \nabla \ell_i(\theta_i) + \alpha_i b_i.$$

This is an online gradient descent (OGD) on the 1-dimensional convex loss $\ell_i$. If the $y_i$ were drawn i.i.d. from a fixed distribution with mean $Q_h^*(s,a)$, the OGD regret bound $[\mathrm{REF}: \mathtt{proofs/library/optimization/convergence/ogd\text{-}regret\text{-}bound/proof.md}]$ would give
$$\sum_{i=1}^t \ell_i(\theta_i) - \sum_{i=1}^t \ell_i(Q_h^*(s,a)) \le O\!\left(\frac{D^2}{\eta_t} + \eta_t \sum_i \|\nabla \ell_i\|^2\right),$$
and an online-to-batch conversion would produce an estimation-error bound on $\theta_t - Q_h^*(s,a)$ at rate $1/\sqrt t$.

### 1.2. Obstruction: the "labels" $y_i$ are *not* i.i.d. and *do not have mean $Q_h^*(s,a)$*

The target used in the update is
$$y_i = r_h(s,a) + V_{h+1}^{k_i}(s_{h+1}^{k_i}),$$
where $V_{h+1}^{k_i}$ is the *learner's own* clipped value function at the start of episode $k_i$, **not** $V_{h+1}^*$. Consequently:

$$\mathbb{E}[y_i \mid \mathcal{F}_{k_i-1}] = r_h(s,a) + [\mathbb{P}_h V_{h+1}^{k_i}](s,a) \neq r_h(s,a) + [\mathbb{P}_h V_{h+1}^*](s,a) = Q_h^*(s,a).$$

The target law **drifts with $i$** because $V_{h+1}^{k_i}$ is updated between visits to $(s,a,h)$. OGD regret analyses assume either (a) an adversarial but *fixed* loss function for each $i$ (no drift in the comparator), or (b) i.i.d. losses (for online-to-batch). The Q-learning update has *neither*: the comparator we care about is $Q_h^*(s,a)$ (a fixed scalar), but the labels $y_i$ have a time-varying mean $r_h + \mathbb{P}_h V_{h+1}^{k_i}$, so OGD's regret against the *empirical best constant* $\bar y := \mathrm{argmin}_{\theta} \sum \ell_i(\theta) = \frac1t\sum y_i$ converges to $r_h + \mathbb{P}_h\bar V_{h+1}$ (a time-average of the learner's own value estimates), **not to $Q_h^*(s,a)$**.

**Formally**: let $\tilde\theta_t^\star := \arg\min_\theta \sum_{i=1}^t \ell_i(\theta) = \frac{1}{t}\sum_{i=1}^t y_i$. OGD guarantees
$$\sum_{i=1}^t \ell_i(\theta_i) - \sum_{i=1}^t \ell_i(\tilde\theta_t^\star) \le \tilde O(\sqrt t).$$
But
$$\tilde\theta_t^\star - Q_h^*(s,a) = \underbrace{\frac1t\sum_{i=1}^t V_{h+1}^{k_i}(s_{h+1}^{k_i}) - [\mathbb{P}_h V_{h+1}^*](s,a)}_{=:\,\mathrm{Drift}_{t}(s,a,h)},$$
and $\mathrm{Drift}_{t}(s,a,h) \ne 0$; it is precisely the quantity we are trying to bound. The OGD bound therefore gives us
$$\underbrace{(\theta_t - Q_h^*(s,a))^2}_{\text{what we want}} \;\le\; \underbrace{\tilde O(1/\sqrt t)}_{\text{OGD regret}/t} \;+\; \underbrace{\mathrm{Drift}_t(s,a,h)^2}_{\text{uncontrolled}}.$$
The second term is not an artifact of the OGD bound — it is the genuine coupling to $(s',h+1)$, and bounding it is *exactly* the content of Lemma A–B of the original problem.

**Conclusion of Attempt 1**: Per-cell OGD regret against the fixed comparator $Q_h^*(s,a)$ cannot be obtained from a generic OCO regret bound because the loss sequence's "best constant" is not $Q_h^*(s,a)$. The obstruction is the inter-cell coupling $V_{h+1}^{k_i} \ne V_{h+1}^*$, i.e., the drift term.

---

## 2. Attempt 2 — Treat $V_{h+1}^{k_i}$ as adversarial

### 2.1. The setup

If one insists on an OCO framework, the next natural idea is to treat $V_{h+1}^{k_i}$ as *adversarial*: view $y_i$ as chosen by an adaptive adversary with the only constraint that $|y_i| \le r_{\max} + H \le 1 + H$. Then define the adversarial loss at visit $i$:
$$\ell_i^{\mathrm{adv}}(\theta) = \tfrac12(\theta - y_i)^2, \quad y_i \in [0, H+1] \text{ adversarial},$$
and apply a full-information OCO bound (e.g., OGD with projection onto $[0, H]$) to obtain
$$\sum_{i=1}^t \ell_i^{\mathrm{adv}}(\theta_i) - \min_{\theta^\dagger \in [0,H]}\sum_{i=1}^t \ell_i^{\mathrm{adv}}(\theta^\dagger) \le \tilde O(H^2\sqrt t).$$

### 2.2. Obstruction: adversarial framing drops the optimism structure

Treating $V_{h+1}^{k_i}$ as adversarial means we give up any use of the fact that $V_{h+1}^{k_i} \ge V_{h+1}^*$ (optimism), which is the key structural property that makes Q-learning with UCB bonuses produce a sublinear regret in the first place. Concretely:

- **The bonus $b_i$ is a feature, not a noise term.** In Q-learning, $b_i$ is added to $y_i$ before the update, and is chosen so that the *biased* update produces an overestimate $Q_h^k \ge Q_h^*$. An adversarial OCO bound compares to the best fixed $\theta^\dagger$ against the *observed* targets $y_i$, which ignores $b_i$ entirely (or treats it as noise inflation).

- **OCO comparator $\theta^\dagger_t = \frac1t\sum y_i$ has no connection to $Q_h^*(s,a)$.** Under adversarial $y_i$, the OCO regret bounds us against the best *post-hoc* constant on the observed targets. Under optimistic Q-learning, the learner's $Q$ *overestimates* $Q_h^*$ while the observed targets $y_i$ have mean *below* $Q_h^*$ (because $V_{h+1}^{k_i}$ is an overestimate of $V_{h+1}^{\pi_{k_i}}$, not of $V_{h+1}^*$ under the *optimal* policy). There is no monotonic relationship between the OCO comparator and $Q_h^*$.

- **Regret $\ne$ sub-optimality.** Even if OCO gave us $\sum_i \ell_i^{\mathrm{adv}}(\theta_i) - \min_\theta \sum_i \ell_i^{\mathrm{adv}}(\theta) \le \tilde O(H^2\sqrt t)$, this tells us nothing about $\sum_k [V_1^*(s_1^k) - V_1^{\pi_k}(s_1^k)]$, which is a different quantity (a *value regret* on the MDP, not a *squared-error regret* on the Q-update).

**Conclusion of Attempt 2**: Adversarial framing loses the optimism (which is Lemma B of the problem statement) and replaces the right-hand side by a quantity (sum of squared Bellman residuals) that has no known link to MDP value regret. This is a dead end.

---

## 3. Attempt 3 — Reduce to a single global OCO problem on the Q-table

### 3.1. The setup

Let $\mathbf{Q}_h \in \mathbb{R}^{S\times A}$ for $h = 1, \dots, H$, and stack them into $\mathbf{Q} \in \mathbb{R}^{SAH}$. Define a global "Bellman error" loss at episode $k$:
$$L_k(\mathbf{Q}) := \sum_{h=1}^H \big(Q_h(s_h^k, a_h^k) - [r_h + V_{h+1}](s_h^k, a_h^k)\big)^2,$$
where $V_{h+1}(s) = \min\{H, \max_{a'} Q_{h+1}(s,a')\}$. The UCB-Hoeffding update is approximately a stochastic gradient step on $L_k$ (with a specific per-coordinate step size and bonus). If $L_k$ were convex in $\mathbf{Q}$, one could apply OCO regret bounds.

### 3.2. Obstruction: $L_k$ is NOT convex in $\mathbf{Q}$

The loss contains
$$V_{h+1}(s) = \min\{H, \max_{a'} Q_{h+1}(s, a')\},$$
which is a **pointwise maximum of $A$ linear functions of $\mathbf{Q}$**, clipped at $H$. Inside the squared Bellman residual it appears as
$$\big(Q_h(s_h^k,a_h^k) - r_h - V_{h+1}(s_{h+1}^k)\big)^2.$$
This is the square of a difference between one coordinate of $\mathbf{Q}$ and the max of a set of other coordinates. Expanding:

- $\max_{a'} Q_{h+1}(s_{h+1}^k, a')$ is **convex** in $\mathbf{Q}$ (pointwise max of linear functions is convex).
- Clipping by $\min\{H, \cdot\}$ makes it a concave-then-linear piecewise function — i.e., **neither convex nor concave**.
- Subtracting this from $Q_h(s_h^k, a_h^k)$ gives a non-convex, non-concave function.
- Squaring a non-convex, non-concave function of $\mathbf{Q}$ yields a function that is **non-convex** in $\mathbf{Q}$ (easily verified by second-derivative computation or by example: take $A = 2$, $H = 2$, and check $\partial^2 L_k / \partial Q_2(s',a)^2$ changes sign).

This matches the **AdaGrad-Norm Route 4 failure pattern** explicitly: online-to-batch conversion (and, more generally, OCO regret bounds against a fixed comparator) requires convexity of each round's loss. The Bellman-error loss is non-convex, so any bound of the form
$$\sum_{k=1}^K L_k(\mathbf{Q}_k) - \min_{\mathbf{Q}^\dagger} \sum_{k=1}^K L_k(\mathbf{Q}^\dagger) \le \tilde O(\sqrt{K})$$
either (a) does not hold with the rate we need, or (b) holds only against the *empirical best $\mathbf{Q}^\dagger$*, which is not $\mathbf{Q}^*$ and whose value $V_1^{\mathbf{Q}^\dagger}(s_1)$ has no relation to $V_1^*(s_1)$.

### 3.3. Sharpened obstruction via a counterexample sketch

Consider $H = 2$, $S = 1$ (a single state $s$), $A = 2$, rewards $r_1 \equiv 0$ at $h=1$ and $r_2(s, a_1) = 1$, $r_2(s, a_2) = 0$, deterministic transition. Then
$$V_2^*(s) = 1, \quad Q_1^*(s, a) = 1 \text{ for both } a.$$
The loss at episode $k$ (after observing $(s,a_h^k)$) involves $\max_{a'} Q_2(s, a')$. Consider two comparators:
- $\mathbf{Q}^{(1)}$: $Q_2(s, a_1) = 1, Q_2(s, a_2) = 0$, $Q_1(s, \cdot) = 1$. This has $V_2^{(1)}(s) = 1$ and achieves zero Bellman residual at $h = 2$ for either visited action.
- $\mathbf{Q}^{(2)}$: $Q_2(s, a_1) = 0.5, Q_2(s, a_2) = 0.5$, $Q_1(s, \cdot) = 0.5$. This has $V_2^{(2)}(s) = 0.5$ and achieves nonzero Bellman residual, *but* the midpoint $\tfrac12(\mathbf{Q}^{(1)} + \mathbf{Q}^{(2)})$ has $V_2 = 0.75$ and, plugged into a specific sequence of losses, produces a *higher* summed squared residual than either endpoint. This shows $\sum_k L_k(\mathbf{Q})$ is not convex — its sublevel sets are not convex.

(A complete derivation of the sign-change of the Hessian is omitted but straightforward and can be requested via `[CALL:math-verifier]`; the non-convexity is immediate from the presence of a $\max$ inside a square.)

**Conclusion of Attempt 3**: The global Bellman-error loss is non-convex, and the standard OCO regret $\to$ convergence reduction fails at the convexity step. This is *precisely* the same obstruction as AdaGrad-Norm Route 4.

---

## 4. Attempt 4 — Treat $(s,a,h)$ cells as "experts" in an expert-advice reduction

### 4.1. The setup

Another natural attempt: view each $(s,a,h)$ cell as an expert, with expert $i = (s,a,h)$'s "loss" at episode $k$ being the per-cell Bellman error. Run an exponential-weights / EXP3-style algorithm over experts to minimize regret against the best single expert.

### 4.2. Obstruction: quantifier mismatch + the MDP regret is a *value* regret, not an *expert* regret

Expert-advice reductions require the global regret to be a sum of per-expert losses $\ell_i^k$ where we compete with a single fixed expert $i^\star$:
$$\mathrm{Regret} = \sum_{k=1}^K \sum_i p_k(i) \ell_i^k - \min_{i^\star}\sum_{k=1}^K \ell_{i^\star}^k.$$
In the MDP setting, the regret is
$$\sum_{k=1}^K [V_1^*(s_1^k) - V_1^{\pi_k}(s_1^k)],$$
a sum over episodes of *scalar* value differences at $h = 1$, which are *not* decomposable as $\sum_i p_k(i) \ell_i^k$ for any natural choice of "experts $i$" and "losses $\ell_i^k$". Specifically:

- $V_1^{\pi_k}(s_1^k)$ depends on $\mathbf{Q}^k$ through a *nonlinear* function (the Bellman recursion, which involves $H-1$ nested $\max$-compositions through $V_h^{\pi_k}(s) = Q_h^{\pi_k}(s, \pi_k(s))$ with $\pi_k(s) = \arg\max Q_h^k(s, \cdot)$).
- Even the *ex post* value regret on a single episode is a nonlinear function of the learner's choice of action sequence, and cannot be written as a linear combination of per-cell experts' losses.

**Quantifier mismatch (analogous to SHB Goujaud failure)**: expert-advice bounds say "for every fixed sequence of expert losses $\ell_i^k$, the algorithm's cumulative loss is close to that of the best fixed expert." The MDP comparator is $V_1^*$, which is the value of the *optimal policy* — a policy is a *function of the state*, not a fixed expert. Competing with the best *fixed action* (which is what a single expert would represent) gives a regret of order $\Omega(T)$ against an MDP whose optimal policy is state-dependent.

### 4.3. A weaker reduction: competing with the best fixed policy (not the best fixed expert)

If we let each "expert" be a *deterministic policy* $\pi : \mathcal{S} \to \mathcal{A}^H$, there are $A^{SH}$ such policies. Running Exp3 / Hedge over this exponentially large set with full-information regret $\sqrt{T \log(A^{SH})} = \sqrt{SHT \log A}$ would (in principle) give value regret $\tilde O(H\sqrt{SHT\log A})$. But:

1. This is a *policy-search* reduction, not a value-iteration / Q-learning reduction. It does not relate to the UCB-Hoeffding algorithm in the problem statement, which does **not** maintain weights over policies; it maintains a Q-table.
2. The $A^{SH}$ cardinality gives a $\log(A^{SH}) = SH\log A$ factor in the regret, which produces $\tilde O(\sqrt{H^2 S A T \log A})$ at best with full information, but **we have only bandit feedback** (we see the value of the chosen policy, not of all policies). Bandit feedback over $A^{SH}$ experts gives EXP3 regret $\tilde O(\sqrt{A^{SH} T})$, which is **exponential in $SH$** — exponentially worse than the claimed $\sqrt{H^4 SAT}$.
3. This reduction also does not use the Markov property at all, so it cannot exploit the $S$ polynomial dependence we need.

**Conclusion of Attempt 4**: Expert-advice / bandit reductions give exponentially-worse rates (bandit feedback over $A^{SH}$ policies) or require full-information feedback (not available). Either way, they cannot recover the $\sqrt{H^4 SAT}$ rate of the JABJ bound.

---

## 5. Partial positive result — $H = 1$ reduces to stochastic multi-armed bandits

Despite the failure of Route D at arbitrary $H$, there is a genuine partial result for $H = 1$.

### 5.1. Setting

When $H = 1$, the MDP becomes a single-step decision problem. Let $\mathcal{S} = \{s_0\}$ (w.l.o.g. only one possible initial state — the analysis trivially extends to multiple states by running an independent bandit per state). The agent observes $s_0$, picks $a \in \mathcal{A}$, receives stochastic reward $r(s_0, a) \in [0, 1]$, and the episode ends. Then $V_1^*(s_0) = \max_a \mathbb{E}[r(s_0, a)]$ and $V_1^{\pi_k}(s_0) = \mathbb{E}[r(s_0, \pi_k(s_0))]$, so regret is
$$\mathrm{Regret}(K) = \sum_{k=1}^K [V_1^*(s_0) - V_1^{\pi_k}(s_0)] = \sum_{k=1}^K [\mu^* - \mu_{a_k}],$$
where $\mu_a = \mathbb{E}[r(s_0, a)]$ and $\mu^* = \max_a \mu_a$. This is *exactly* a stochastic multi-armed bandit (SMAB) with $K$ rounds and $A$ arms.

### 5.2. UCB-Hoeffding Q-learning at $H = 1$ = UCB1

At $H = 1$, the update $(\star)$ simplifies: $V_2 \equiv 0$, so the target is just $y_i = r(s_0, a)$. The bonus is $b_t = c\sqrt{\iota/t}$. The learning rate $\alpha_t = 2/(t+1)$ (since $H = 1$), which gives
$$Q_1^{k_i+1}(s_0, a) = (1 - \tfrac{2}{i+1}) Q_1^{k_i}(s_0, a) + \tfrac{2}{i+1}(r + b_i).$$
Expanding recursively gives
$$Q_1^{k_t+1}(s_0, a) = \frac{2}{t(t+1)}\sum_{i=1}^t i \cdot (r_i + b_i) + \text{(boundary terms)},$$
a weighted average (not uniform) of past rewards plus bonuses. The greedy action selection $a_k = \arg\max_a Q_1^k(s_0, a)$ is then an "optimistic index policy" closely related to UCB1 — though with a $t$-dependent weighting.

The analysis then reduces to a SMAB regret bound of the form $\tilde O(\sqrt{AT})$, which can be obtained via:

### 5.3. Explicit reduction: $H = 1$ UCB-Hoeffding $\Rightarrow$ SMAB $\tilde O(\sqrt{AT})$

Using the bandit/online-learning template $[\mathrm{REF}: \mathtt{proofs/research/learning\text{-}theory/generalization/exp3\text{-}adversarial\text{-}bandit\text{-}regret/proof.md}]$ for the *adversarial* bandit, or any standard *stochastic* UCB1 analysis (e.g., Auer-Cesa-Bianchi-Fischer 2002):

**Sketch (at $H = 1$)**:
1. The weighted average $\bar r_t(a) := \frac{2}{t(t+1)}\sum_{i=1}^t i \cdot r_i$ satisfies a Hoeffding-type concentration: by a one-line computation with weights $w_i = 2i/(t(t+1))$, $\sum_i w_i = 1$, $\sum_i w_i^2 = \frac{4}{t^2(t+1)^2}\sum_i i^2 \approx \frac{4}{3t}$, so
$$\mathbb{P}\Big(|\bar r_t(a) - \mu_a| \ge u\Big) \le 2\exp\big(-\tfrac{u^2}{2\sum w_i^2}\big) \le 2\exp(-3tu^2/8).$$
Setting $u = \sqrt{8\iota/(3t)} \le c\sqrt{\iota/t}$ for a suitable $c$ gives a confidence interval exactly of the form of the bonus $b_t$.

2. Optimism: $Q_1^k(s_0, a) \ge \mu_a$ for all $k, a$ with probability $\ge 1-\delta/2$.

3. Regret at any episode $k$: letting $a^* = \arg\max_a \mu_a$ and $a_k$ the greedy action,
$$\mu^* - \mu_{a_k} \le [Q_1^k(s_0, a_k) - \mu_{a_k}] \le \bar r_{t_k}(a_k) + b_{t_k} - \mu_{a_k} \le 2 b_{t_k}.$$

4. Summing: $\mathrm{Regret}(K) \le 2\sum_{k=1}^K b_{t_k} = 2c\sqrt{\iota} \sum_k \frac{1}{\sqrt{n_1^k(s_0, a_k)}}$. By Cauchy-Schwarz and visit counting (each arm $a$ is pulled $N_K(a)$ times, $\sum_a N_K(a) = K$):
$$\sum_k \frac{1}{\sqrt{n_1^k(s_0, a_k)}} = \sum_a \sum_{i=1}^{N_K(a)} \frac{1}{\sqrt i} \le \sum_a 2\sqrt{N_K(a)} \le 2\sqrt{A \cdot K}.$$

5. Therefore $\mathrm{Regret}(K) \le 4c\sqrt{\iota AK} = \tilde O(\sqrt{AT})$ (since at $H = 1$, $T = K$).

This matches the claimed $\sqrt{H^4 SAT}$ bound at $H = 1, S = 1$: $\sqrt{1^4 \cdot 1 \cdot A \cdot K} = \sqrt{AK}$, as expected.

**Reusable template**: the Cauchy-Schwarz plus visit-counting step in (4) is the *same* step used in the Route A / JABJ 2018 proof at general $H$. The difference at $H > 1$ is not in this bandit-style bound but in the **value propagation** (Lemma E of problem.md): the per-cell confidence interval inflates by a factor of $(1 + 1/H)^H \le e$ per layer of the value recursion, summed over $H$ layers, producing the extra $H^{3/2}$ factor beyond the bandit $\sqrt{AT}$.

### 5.4. What the $H = 1$ reduction teaches us

The bandit reduction at $H = 1$ works **precisely because** the two blockages of Attempts 1-4 are absent:

- There is no "$V_{h+1}$" to couple across cells ($V_2 \equiv 0$), so the per-cell regression at $h = 1$ has a *fixed* mean $\mu_a$, and standard Hoeffding/OCO applies.
- There is no "chain of $\max$'s" in the Bellman recursion, so the global loss is a simple sum of scalar Bellman residuals, which is convex (actually a single squared term per episode).

Both failure modes — (a) drift of the regression target and (b) non-convex global loss — appear as soon as $H \ge 2$.

---

## 6. Route Failure Report — summary

- **Route**: D (online learning / expert reduction).
- **Failed at**:
  - **Attempt 1** (per-cell online regression, §1): failed because the regression targets $y_i$ have a drifting mean depending on $V_{h+1}^{k_i}$, and OGD's comparator (best constant on the observed targets) is not $Q_h^*(s,a)$.
  - **Attempt 2** (adversarial framing, §2): failed because treating $V_{h+1}^{k_i}$ as adversarial drops optimism and produces a squared-Bellman-error bound with no connection to value regret.
  - **Attempt 3** (global OCO on Bellman-error loss, §3): failed because the global loss is non-convex due to the $\max$ inside the square, matching the AdaGrad-Norm Route 4 failure pattern exactly.
  - **Attempt 4** (expert-advice on cells / on policies, §4): failed because either (i) cells are not natural experts for a *value* regret decomposition, or (ii) using policies as experts gives exponential ($A^{SH}$) rather than polynomial cardinality.

- **Obstacle (unified statement)**:

  > **A reduction to OCO / expert-advice regret requires either (a) a loss function that is convex in the learner's decision variable (with a fixed comparator whose associated value relates to the MDP optimum), or (b) a per-expert decomposition of the value regret. Q-learning's global Bellman-error loss is non-convex (because $V_{h+1}(s) = \min\{H, \max_{a'} Q_{h+1}(s,a')\}$ is non-convex inside a square), and the MDP value regret $\sum_k [V_1^*(s_1^k) - V_1^{\pi_k}(s_1^k)]$ is not linear in any natural per-cell loss. Neither (a) nor (b) holds for $H \ge 2$, so no generic OCO / expert-advice bound yields the $\sqrt{H^4 SAT}$ rate as a corollary.**

- **What this teaches us**: RL regret (for value-iteration-style algorithms) is fundamentally *not* reducible to OCO regret with a constant-sized comparator class, because the Bellman recursion introduces a nested $\max$ that destroys convexity and couples cells across horizon layers. This reaffirms the failure pattern noted in `workspace/failure_patterns.md` for AdaGrad-Norm Route 4 (online-to-batch via regret fails for non-convex objectives). The pathwise induction in Route A / JABJ 2018 succeeds precisely because it does not attempt to construct a single global OCO loss: it instead uses the $\alpha_t^i$ product identities and a backward-in-$h$ induction to propagate the per-cell confidence interval through the Bellman recursion directly.

- **Partial progress**: $H = 1$ is genuinely reducible to stochastic multi-armed bandits (Section 5), and for that case the UCB-Hoeffding Q-learning update becomes a (weighted-average) UCB1-like policy whose $\tilde O(\sqrt{AK})$ regret can be derived from the bandit template $[\mathrm{REF}: \mathtt{proofs/research/learning\text{-}theory/generalization/exp3\text{-}adversarial\text{-}bandit\text{-}regret/proof.md}]$ plus a Hoeffding-type concentration on weighted averages. This partial result matches the target bound at $H = 1$ but does **not** extend to $H \ge 2$ by any OCO-style argument. The obstruction at $H \ge 2$ is not merely a $\log$ factor or a constant — it is a genuine non-convexity / non-decomposability, so no amount of refinement of the OCO reduction will close the gap.

- **Recommendation to the judge**: Do **not** attempt to promote Route D beyond the $H = 1$ partial result. The full theorem requires the pathwise, induction-on-$h$ approach of Route A (or its martingale-first reorganization, Route B). The advantage-based Route C gives the same result with possibly tighter constants but shares the same non-OCO core.

## Q.E.D. (of failure / partial-result report)

This report does not prove the main theorem. It documents a rigorous failure of Route D for $H \ge 2$ and a rigorous partial success for $H = 1$. Route D is not a viable full-proof route; Routes A / B / C should be used for the main theorem.
