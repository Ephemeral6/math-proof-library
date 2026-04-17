# Proof: Bellman Optimality Contraction and Uniqueness

## Setup

Consider a finite MDP with state space $\mathcal{S}$, action space $\mathcal{A}$, reward function $r: \mathcal{S} \times \mathcal{A} \to \mathbb{R}$, transition kernel $P(\cdot|s,a)$, and discount factor $\gamma \in [0,1)$.

The Bellman optimality operator $\mathcal{T}^*: \mathbb{R}^{|\mathcal{S}||\mathcal{A}|} \to \mathbb{R}^{|\mathcal{S}||\mathcal{A}|}$ is

$$(\mathcal{T}^* Q)(s,a) = r(s,a) + \gamma \sum_{s' \in \mathcal{S}} P(s'|s,a) \max_{a' \in \mathcal{A}} Q(s',a').$$

We work in the Banach space $(\mathbb{R}^{|\mathcal{S}||\mathcal{A}|}, \|\cdot\|_\infty)$.

---

## Lemma (Max-Nonexpansiveness)

For any $f, g: \mathcal{A} \to \mathbb{R}$ on a finite set $\mathcal{A}$,

$$\left|\max_{a \in \mathcal{A}} f(a) - \max_{a \in \mathcal{A}} g(a)\right| \leq \max_{a \in \mathcal{A}} |f(a) - g(a)|.$$

**Proof.** Let $a^* = \arg\max_a f(a)$. Then

$$\max_a f(a) - \max_a g(a) = f(a^*) - \max_a g(a) \leq f(a^*) - g(a^*) \leq |f(a^*) - g(a^*)| \leq \max_a |f(a) - g(a)|,$$

since $\max_a g(a) \geq g(a^*)$. By symmetry (swapping $f$ and $g$), the reverse direction also holds. Combining gives the result. $\blacksquare$

---

## Theorem 1 ($\gamma$-Contraction)

$\|\mathcal{T}^* Q_1 - \mathcal{T}^* Q_2\|_\infty \leq \gamma \|Q_1 - Q_2\|_\infty$ for all $Q_1, Q_2 \in \mathbb{R}^{|\mathcal{S}||\mathcal{A}|}$.

**Proof.** Fix $(s,a) \in \mathcal{S} \times \mathcal{A}$. Since $r(s,a)$ cancels:

$$|(\mathcal{T}^* Q_1)(s,a) - (\mathcal{T}^* Q_2)(s,a)| = \gamma \left|\sum_{s'} P(s'|s,a) \left[\max_{a'} Q_1(s',a') - \max_{a'} Q_2(s',a')\right]\right|.$$

By the triangle inequality (with $P(s'|s,a) \geq 0$) and the Lemma:

$$\leq \gamma \sum_{s'} P(s'|s,a) \left|\max_{a'} Q_1(s',a') - \max_{a'} Q_2(s',a')\right| \leq \gamma \sum_{s'} P(s'|s,a) \|Q_1 - Q_2\|_\infty = \gamma \|Q_1 - Q_2\|_\infty,$$

where the last step uses $\sum_{s'} P(s'|s,a) = 1$. Taking the supremum over $(s,a)$:

$$\|\mathcal{T}^* Q_1 - \mathcal{T}^* Q_2\|_\infty \leq \gamma \|Q_1 - Q_2\|_\infty. \quad \blacksquare$$

---

## Theorem 2 (Unique Fixed Point and Value Iteration Convergence)

$\mathcal{T}^*$ has a unique fixed point $Q^*$, and for any $Q_0$, $\|Q_k - Q^*\|_\infty \leq \gamma^k \|Q_0 - Q^*\|_\infty$.

**Proof.**

**Completeness.** $(\mathbb{R}^{|\mathcal{S}||\mathcal{A}|}, \|\cdot\|_\infty)$ is finite-dimensional, hence complete.

**Banach Fixed-Point Theorem.** $\mathcal{T}^*$ is a $\gamma$-contraction with $\gamma < 1$ on a complete metric space, so there exists a unique $Q^*$ with $\mathcal{T}^* Q^* = Q^*$.

**Convergence rate.** Define $Q_{k+1} = \mathcal{T}^* Q_k$. Using $\mathcal{T}^* Q^* = Q^*$:

$$\|Q_{k+1} - Q^*\|_\infty = \|\mathcal{T}^* Q_k - \mathcal{T}^* Q^*\|_\infty \leq \gamma \|Q_k - Q^*\|_\infty.$$

By induction: $\|Q_k - Q^*\|_\infty \leq \gamma^k \|Q_0 - Q^*\|_\infty$.

Since $\gamma < 1$, $\gamma^k \to 0$, so $Q_k \to Q^*$ at geometric rate. $\blacksquare$
