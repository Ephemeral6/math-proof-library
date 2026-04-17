# Route 2: Monotonicity + Contraction via Value Function Reduction

## Setup

Same MDP setup as Route 1. We define two operators:

- **Value-function Bellman operator:** $(\mathcal{T}_V^* V)(s) = \max_{a \in \mathcal{A}} \left[r(s,a) + \gamma \sum_{s'} P(s'|s,a) V(s')\right]$
- **Q-function Bellman operator:** $(\mathcal{T}^* Q)(s,a) = r(s,a) + \gamma \sum_{s'} P(s'|s,a) \max_{a'} Q(s',a')$

We work in $(\mathbb{R}^{|\mathcal{S}|}, \|\cdot\|_\infty)$ and $(\mathbb{R}^{|\mathcal{S}||\mathcal{A}|}, \|\cdot\|_\infty)$ respectively.

---

## Lemma 2 (Monotonicity of $\mathcal{T}_V^*$)

**Statement.** If $V_1(s) \leq V_2(s)$ for all $s \in \mathcal{S}$, then $(\mathcal{T}_V^* V_1)(s) \leq (\mathcal{T}_V^* V_2)(s)$ for all $s$.

**Proof.** For each $s$:

$$(\mathcal{T}_V^* V_1)(s) = \max_a \left[r(s,a) + \gamma \sum_{s'} P(s'|s,a) V_1(s')\right] \leq \max_a \left[r(s,a) + \gamma \sum_{s'} P(s'|s,a) V_2(s')\right] = (\mathcal{T}_V^* V_2)(s).$$

The inequality holds because $V_1(s') \leq V_2(s')$ for all $s'$, $P(s'|s,a) \geq 0$, and the max preserves the inequality since it holds for each $a$. $\blacksquare$

---

## Theorem 3 ($\gamma$-Contraction of $\mathcal{T}_V^*$)

**Statement.** $\|\mathcal{T}_V^* V_1 - \mathcal{T}_V^* V_2\|_\infty \leq \gamma \|V_1 - V_2\|_\infty$.

**Proof.** Let $\epsilon = \|V_1 - V_2\|_\infty$. Then $V_2(s) - \epsilon \leq V_1(s) \leq V_2(s) + \epsilon$ for all $s$.

By monotonicity (Lemma 2):

$$\mathcal{T}_V^* (V_2 - \epsilon \mathbf{1}) \leq \mathcal{T}_V^* V_1 \leq \mathcal{T}_V^* (V_2 + \epsilon \mathbf{1}).$$

Now we compute the shift property. For any constant $c$:

$$(\mathcal{T}_V^* (V + c\mathbf{1}))(s) = \max_a \left[r(s,a) + \gamma \sum_{s'} P(s'|s,a)(V(s') + c)\right] = (\mathcal{T}_V^* V)(s) + \gamma c.$$

(Here we used $\sum_{s'} P(s'|s,a) = 1$.)

Therefore:

$$(\mathcal{T}_V^* V_2)(s) - \gamma \epsilon \leq (\mathcal{T}_V^* V_1)(s) \leq (\mathcal{T}_V^* V_2)(s) + \gamma \epsilon, \quad \forall s.$$

This gives $\|\mathcal{T}_V^* V_1 - \mathcal{T}_V^* V_2\|_\infty \leq \gamma \epsilon = \gamma \|V_1 - V_2\|_\infty$. $\blacksquare$

---

## Theorem 4 (Contraction of $\mathcal{T}^*$ on Q-functions)

**Statement.** $\|\mathcal{T}^* Q_1 - \mathcal{T}^* Q_2\|_\infty \leq \gamma \|Q_1 - Q_2\|_\infty$.

**Proof.** Define $V_Q(s) = \max_{a} Q(s,a)$ for any Q-function. Note that

$$(\mathcal{T}^* Q)(s,a) = r(s,a) + \gamma \sum_{s'} P(s'|s,a) V_Q(s').$$

For any $(s,a)$:

$$|(\mathcal{T}^* Q_1)(s,a) - (\mathcal{T}^* Q_2)(s,a)| = \gamma \left|\sum_{s'} P(s'|s,a) [V_{Q_1}(s') - V_{Q_2}(s')]\right|$$

$$\leq \gamma \sum_{s'} P(s'|s,a) |V_{Q_1}(s') - V_{Q_2}(s')|.$$

By the max-nonexpansiveness property (Lemma 1 from Route 1):

$$|V_{Q_1}(s') - V_{Q_2}(s')| = \left|\max_{a'} Q_1(s',a') - \max_{a'} Q_2(s',a')\right| \leq \max_{a'} |Q_1(s',a') - Q_2(s',a')| \leq \|Q_1 - Q_2\|_\infty.$$

Therefore:

$$|(\mathcal{T}^* Q_1)(s,a) - (\mathcal{T}^* Q_2)(s,a)| \leq \gamma \|Q_1 - Q_2\|_\infty.$$

Taking the supremum over $(s,a)$ gives the result. $\blacksquare$

---

## Theorem 5 (Unique Fixed Point and Convergence)

**Statement.** $\mathcal{T}^*$ has a unique fixed point $Q^*$, and value iteration converges: $\|Q_k - Q^*\|_\infty \leq \gamma^k \|Q_0 - Q^*\|_\infty$.

**Proof.** Identical to Theorem 2 in Route 1: apply Banach Fixed-Point Theorem to the $\gamma$-contraction $\mathcal{T}^*$ on the complete metric space $(\mathbb{R}^{|\mathcal{S}||\mathcal{A}|}, \|\cdot\|_\infty)$, then iterate the contraction inequality. $\blacksquare$

---

## Additional Insight: $V$-$Q$ Correspondence

The unique fixed points are related by:
- $V^*(s) = \max_a Q^*(s,a)$
- $Q^*(s,a) = r(s,a) + \gamma \sum_{s'} P(s'|s,a) V^*(s')$

This follows because if $Q^* = \mathcal{T}^* Q^*$, then setting $V^*(s) = \max_a Q^*(s,a)$ yields $V^* = \mathcal{T}_V^* V^*$.
