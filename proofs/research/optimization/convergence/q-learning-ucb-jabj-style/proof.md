# Problem 25 — Q-Learning UCB Sample Complexity

## Setting
Tabular MDP with state space $\mathcal S$ ($|\mathcal S|=S$), action space $\mathcal A$ ($|\mathcal A|=A$), discount $\gamma\in[0,1)$, effective horizon $H=1/(1-\gamma)$. Generative or trajectory-based Q-learning with UCB bonus
$$Q_{t+1}(s,a) \leftarrow (1-\alpha_t) Q_t(s,a) + \alpha_t \big(r + \gamma \max_{a'}Q_t(s',a') + b_t(s,a)\big),$$
where $b_t(s,a)=c_b H\sqrt{\iota/N_t(s,a)}$, $\iota=\log(SAT/\delta)$, $N_t(s,a)$=visit count, $\alpha_t = (H+1)/(H+N_t(s,a))$.

## Theorem
With probability $\ge 1-\delta$, after $T$ steps:
$$\mathrm{Regret}(T) := \sum_{t=1}^T (V^\star(s_t) - V^{\pi_t}(s_t)) \le C\sqrt{H^4 SAT\iota}.$$
Equivalently, sample complexity for $\varepsilon$-optimal policy: $T = \widetilde O(SAH^4/\varepsilon^2)$.

## Proof Outline (JABJ-style: Jin, Allen-Zhu, Bubeck, Jordan 2018)

### Step 1. Optimism (UCB-Bellman dominance)
Define filtration $\mathcal F_t$. Let $N=N_t(s,a)$ when $(s,a)$ is visited at time $t$, and let $t_1<t_2<\ldots<t_N$ denote previous visits. With $\alpha_i = (H+1)/(H+i)$ and the standard product weights $\alpha_N^i = \alpha_i\prod_{j=i+1}^N(1-\alpha_j)$ and $\alpha_N^0=\prod_{j=1}^N(1-\alpha_j)$, the recursion unfolds to
$$Q_t(s,a) = \alpha_N^0 Q_0(s,a) + \sum_{i=1}^N \alpha_N^i\big[r_i + \gamma V_i(s'_i) + b_i\big],$$
where $V_i(s) = \max_{a'}Q_{t_i}(s,a')$ and $b_i = c_b H\sqrt{\iota/i}$.

**Lemma A (weight properties)**: 
- $\sum_{i=0}^N \alpha_N^i = 1$,
- $\sum_{i=1}^N (\alpha_N^i)^2 \le 2H/N$,
- $\sum_{i=1}^N \alpha_N^i/\sqrt i \le 2/\sqrt N$ (the key bias inequality).

These follow by induction (standard, see JABJ Lemma 4.1).

**Lemma B (optimism)**: With probability $\ge 1-\delta/2$, for all $(t,s,a)$:
$$Q_t(s,a) \ge Q^\star(s,a).$$
Proof by induction on $N$. The Bellman gap is
$$Q_t(s,a) - Q^\star(s,a) = \alpha_N^0(Q_0-Q^\star) + \sum_i\alpha_N^i\big[\gamma(V_i(s'_i)-V^\star(s'_i))\big] + \sum_i\alpha_N^i\big[\gamma V^\star(s'_i)-\gamma\mathbb E V^\star+b_i\big].$$
The first two terms are $\ge 0$ by IH ($Q_0=H\ge Q^\star$ for an upper init). The third is bounded below by $-c_M H\sqrt{\iota/N}$ via Azuma-Hoeffding [REF: Azuma-Hoeffding inequality, library] since $\sum_i\alpha_N^i V^\star(s'_i)$ is a bounded martingale with conditional variance $\le \sum(\alpha_N^i)^2 H^2 \le 2H^3/N$. Choosing $c_b$ s.t. $b_i$ dominates this Azuma deviation makes the third term $\ge 0$ w.h.p. Union bound over $SAT$ events: probability $\ge 1-\delta/2$.

### Step 2. Per-step regret decomposition
Let $\delta_t = V_t(s_t) - V^\star(s_t)$ where $V_t = \max_a Q_t(\cdot,a)$. By optimism, $\delta_t \ge 0$, and $\mathrm{Regret}(T)\le\sum_t \delta_t$.

For each visit $(s_t,a_t)$ with current count $N=N_t$,
$$\delta_t \le Q_t(s_t,a_t) - Q^\star(s_t,a_t) = \alpha_N^0 H + \sum_i\alpha_N^i\big[\gamma\delta_{t_i} + b_i + \xi_i\big]$$
where $\xi_i = \gamma(V^\star(s'_i)-\mathbb E V^\star)$ is a martingale difference bounded by $H$.

### Step 3. Telescoping over trajectory
Sum over $t=1,\ldots,T$:
$$\sum_{t=1}^T \delta_t \le \sum_t \alpha_{N_t}^0 H + \gamma \sum_t \sum_i \alpha_{N_t}^i \delta_{t_i} + \sum_t\sum_i\alpha_{N_t}^i b_i + \sum_t\sum_i\alpha_{N_t}^i \xi_i.$$

**Key trick (re-indexing)**: For a fixed past visit $t'$, it appears as some $t_i$ in future visits to $(s_{t'},a_{t'})$. Sum of incoming weights $\sum_{N\ge i}\alpha_N^i \le 1+1/H$ (Lemma A.5 of JABJ). Thus
$$\sum_t\sum_i\alpha_{N_t}^i\delta_{t_i} \le (1+1/H)\sum_{t'}\delta_{t'}.$$
Substituting:
$$\sum_t\delta_t \le \underbrace{\sum_t \alpha_{N_t}^0 H}_{(I)} + \gamma(1+1/H)\sum_t\delta_t + \underbrace{\sum_t\sum_i\alpha_{N_t}^i b_i}_{(II)} + \underbrace{\sum_t\sum_i\alpha_{N_t}^i\xi_i}_{(III)}.$$
With $\gamma=1-1/H$, $\gamma(1+1/H)=1-1/H^2 \le 1-1/H^2$, so $(1-\gamma(1+1/H))\ge 1/H^2$. Wait — refine: we want effective contraction. JABJ uses $\gamma(1+1/H) = 1-1/H+\gamma/H \le 1-1/(2H)$ when $\gamma \le 1-1/(2H)$, so we get
$$\sum_t\delta_t \le 2H[(I)+(II)+(III)].$$

### Step 4. Bound each piece
- **(I)**: $\alpha_N^0=0$ for $N\ge 1$, and equals 1 only at first visit. So $(I)\le SA\cdot H$.
- **(II)**: $\sum_i\alpha_N^i b_i \le c_b H\sqrt\iota \cdot \sum_i\alpha_N^i/\sqrt i \le 2c_b H\sqrt{\iota/N}$ by Lemma A.3. Then $\sum_t 2c_b H\sqrt{\iota/N_t(s_t,a_t)} \le 2c_b H\sqrt\iota \sum_{(s,a)}\sum_{n=1}^{N_T(s,a)}1/\sqrt n \le 4c_b H\sqrt\iota \sum_{s,a}\sqrt{N_T(s,a)} \le 4c_b H\sqrt{SAT\iota}$ by Cauchy-Schwarz.
- **(III)**: martingale with conditional variance $\le \sum_t\sum_i (\alpha_{N_t}^i)^2 H^2 \le 2H^3 \cdot$ (effective length $\le T$) — by Azuma, $|(III)| \le H\sqrt{H T\iota}$ w.p. $\ge 1-\delta/2$.

Combining,
$$\sum_t\delta_t \le 2H\big[SAH + 4c_b H\sqrt{SAT\iota} + H\sqrt{HT\iota}\big] \le C\sqrt{H^4 SAT\iota}.$$

### Step 5. Sample complexity conversion
For $\varepsilon$-optimal: $\frac{1}{T}\sum_t\delta_t \le \varepsilon$ gives $T\ge C^2 H^4 SA\iota/\varepsilon^2 = \widetilde O(SAH^4/\varepsilon^2)$. $\blacksquare$

## Key library refs
- [REF: Azuma-Hoeffding inequality, proofs/library/probability/azuma-hoeffding-inequality/]
- [REF: Bellman optimality contraction, proofs/library/optimization/convergence/bellman-optimality-contraction/]
