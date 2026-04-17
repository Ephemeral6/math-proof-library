# Route 3: Weighted Sup-Norm Approach

## Setup

Same MDP as before. For a weight function $w: \mathcal{S} \times \mathcal{A} \to (0, \infty)$, define the weighted sup-norm:

$$\|Q\|_{w,\infty} = \max_{(s,a)} \frac{|Q(s,a)|}{w(s,a)}.$$

For this problem, we specialize to $w \equiv 1$, recovering $\|Q\|_{1,\infty} = \|Q\|_\infty$.

---

## Lemma 3 (Well-Definedness)

**Statement.** $\mathcal{T}^*$ maps $\mathbb{R}^{|\mathcal{S}||\mathcal{A}|}$ to itself.

**Proof.** Since $\mathcal{S}$ and $\mathcal{A}$ are finite, $r(s,a)$ is bounded and $\max_{a'} Q(s',a')$ is well-defined for any $Q \in \mathbb{R}^{|\mathcal{S}||\mathcal{A}|}$. The sum $\sum_{s'} P(s'|s,a) \max_{a'} Q(s',a')$ is a finite sum of bounded terms, hence finite. Therefore $(\mathcal{T}^* Q)(s,a) \in \mathbb{R}$ for all $(s,a)$. $\blacksquare$

---

## Theorem 6 (Contraction in Weighted Norm)

**Statement.** For any weight function $w \geq 1$ satisfying the Lyapunov-type condition $\gamma \sum_{s'} P(s'|s,a) w(s') \leq \beta \cdot w(s,a)$ for some $\beta < 1$ and all $(s,a)$, we have $\|\mathcal{T}^* Q_1 - \mathcal{T}^* Q_2\|_{w,\infty} \leq \beta \|Q_1 - Q_2\|_{w,\infty}$.

In the special case $w \equiv 1$: the condition becomes $\gamma \cdot 1 \leq \beta \cdot 1$, so $\beta = \gamma$, yielding $\|\mathcal{T}^* Q_1 - \mathcal{T}^* Q_2\|_\infty \leq \gamma \|Q_1 - Q_2\|_\infty$.

**Proof (general case).** Fix $(s,a)$. By the same calculation as Route 1:

$$|(\mathcal{T}^* Q_1)(s,a) - (\mathcal{T}^* Q_2)(s,a)| \leq \gamma \sum_{s'} P(s'|s,a) \max_{a'} |Q_1(s',a') - Q_2(s',a')|.$$

Now,

$$\max_{a'} |Q_1(s',a') - Q_2(s',a')| = \max_{a'} \frac{|Q_1(s',a') - Q_2(s',a')|}{w(s',a')} \cdot w(s',a') \leq \|Q_1 - Q_2\|_{w,\infty} \cdot w(s'),$$

where $w(s') := \max_{a'} w(s',a')$ (or simply $w(s')$ if the weight depends only on state).

Substituting:

$$|(\mathcal{T}^* Q_1)(s,a) - (\mathcal{T}^* Q_2)(s,a)| \leq \gamma \|Q_1 - Q_2\|_{w,\infty} \sum_{s'} P(s'|s,a) w(s').$$

By the Lyapunov condition:

$$\leq \beta \|Q_1 - Q_2\|_{w,\infty} \cdot w(s,a).$$

Dividing both sides by $w(s,a) > 0$ and taking sup over $(s,a)$:

$$\|\mathcal{T}^* Q_1 - \mathcal{T}^* Q_2\|_{w,\infty} \leq \beta \|Q_1 - Q_2\|_{w,\infty}. \quad \blacksquare$$

**Special case $w \equiv 1$:** The Lyapunov condition reads $\gamma \sum_{s'} P(s'|s,a) \cdot 1 = \gamma \leq \beta$, which is satisfied with $\beta = \gamma$. The proof specializes to exactly the same result as Route 1.

---

## Theorem 7 (Fixed Point and Convergence)

**Statement.** $\mathcal{T}^*$ has a unique fixed point $Q^*$ in $(\mathbb{R}^{|\mathcal{S}||\mathcal{A}|}, \|\cdot\|_\infty)$, and $\|Q_k - Q^*\|_\infty \leq \gamma^k \|Q_0 - Q^*\|_\infty$.

**Proof.** 

**Completeness:** $(\mathbb{R}^{|\mathcal{S}||\mathcal{A}|}, \|\cdot\|_\infty)$ is a Banach space (finite-dimensional).

**Contraction:** Theorem 6 with $w \equiv 1$ gives the $\gamma$-contraction.

**Banach Fixed-Point Theorem:** Yields existence and uniqueness of $Q^* = \mathcal{T}^* Q^*$.

**Convergence rate:** By induction, $\|Q_k - Q^*\|_\infty \leq \gamma^k \|Q_0 - Q^*\|_\infty$, hence $Q_k \to Q^*$ geometrically. $\blacksquare$

---

## Remark

The weighted-norm framework is useful when the state space is countably infinite and rewards are unbounded (Hernández-Lerma & Lasserre 1996). In the finite case with $w \equiv 1$, it collapses to the standard proof.
