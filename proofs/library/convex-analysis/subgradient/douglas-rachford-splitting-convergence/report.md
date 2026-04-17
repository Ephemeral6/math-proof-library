# Douglas-Rachford Splitting: Convergence for Maximal Monotone Operators

## Setup and Notation

Let $\mathcal{H}$ be a real Hilbert space with inner product $\langle \cdot, \cdot \rangle$ and induced norm $\|\cdot\|$. Let $A, B : \mathcal{H} \rightrightarrows \mathcal{H}$ be maximal monotone operators. Recall that $A$ is **monotone** if
$$
\langle u - v, x - y \rangle \geq 0 \quad \forall\, (x, u), (y, v) \in \text{gra}(A),
$$
and **maximal monotone** if no proper monotone extension exists.

The **resolvent** of $A$ is $J_A := (I + A)^{-1}$, and the **reflected resolvent** is $R_A := 2J_A - I$.

The **Douglas-Rachford operator** is
$$
T_{DR} := I + J_B(2J_A - I) - J_A.
$$

The **Douglas-Rachford iteration** is $x_{t+1} = T_{DR}(x_t)$ for $t = 0, 1, 2, \ldots$

We assume throughout that $\text{zer}(A + B) := \{z \in \mathcal{H} : 0 \in Az + Bz\} \neq \emptyset$.

---

## Part 1: The Resolvent is Firmly Nonexpansive

**Proposition 1.** *Let $A : \mathcal{H} \rightrightarrows \mathcal{H}$ be maximal monotone. Then $J_A = (I + A)^{-1}$ is firmly nonexpansive, i.e., for all $x, y \in \mathcal{H}$:*
$$
\|J_A x - J_A y\|^2 + \|(I - J_A)x - (I - J_A)y\|^2 \leq \|x - y\|^2.
$$

**Proof.** Let $u = J_A(x)$ and $v = J_A(y)$. By definition of the resolvent, $u \in (I + A)^{-1}(x)$ means $x \in (I + A)(u)$, i.e.,
$$
x - u \in A(u), \qquad y - v \in A(v).
$$

By monotonicity of $A$:
$$
\langle (x - u) - (y - v),\; u - v \rangle \geq 0.
$$

Expanding:
$$
\langle (x - y) - (u - v),\; u - v \rangle \geq 0,
$$
$$
\langle x - y,\; u - v \rangle - \|u - v\|^2 \geq 0,
$$
hence
$$
\langle x - y,\; u - v \rangle \geq \|u - v\|^2. \tag{1.1}
$$

Now we use the **parallelogram decomposition**. Write $x - y = (u - v) + \big((x - u) - (y - v)\big)$. Then:
$$
\|x - y\|^2 = \|u - v\|^2 + \|(x - u) - (y - v)\|^2 + 2\langle u - v,\; (x - u) - (y - v) \rangle.
$$

The cross term equals:
$$
2\langle u - v,\; (x - u) - (y - v) \rangle = 2\langle u - v,\; (x - y) - (u - v) \rangle = 2\langle u - v, x - y \rangle - 2\|u - v\|^2.
$$

Substituting back:
$$
\|x - y\|^2 = \|u - v\|^2 + \|(x - u) - (y - v)\|^2 + 2\langle u - v, x - y \rangle - 2\|u - v\|^2.
$$

Simplifying:
$$
\|x - y\|^2 = -\|u - v\|^2 + \|(x - u) - (y - v)\|^2 + 2\langle u - v, x - y \rangle.
$$

Using inequality (1.1), $\langle u - v, x - y \rangle \geq \|u - v\|^2$, so:
$$
\|x - y\|^2 \geq -\|u - v\|^2 + \|(x - u) - (y - v)\|^2 + 2\|u - v\|^2,
$$
$$
\|x - y\|^2 \geq \|u - v\|^2 + \|(x - u) - (y - v)\|^2.
$$

Since $u = J_A(x)$, $v = J_A(y)$, and $x - u = (I - J_A)(x)$, $y - v = (I - J_A)(y)$, this is exactly:
$$
\|J_A x - J_A y\|^2 + \|(I - J_A)x - (I - J_A)y\|^2 \leq \|x - y\|^2. \qquad \blacksquare
$$

---

## Part 2: The Reflected Resolvent is Nonexpansive

**Proposition 2.** *Let $A$ be maximal monotone. Then $R_A = 2J_A - I$ is nonexpansive, i.e.,*
$$
\|R_A x - R_A y\| \leq \|x - y\| \quad \forall\, x, y \in \mathcal{H}.
$$

**Proof.** By definition, $R_A = 2J_A - I$, so:
$$
\|R_A x - R_A y\|^2 = \|(2J_A - I)x - (2J_A - I)y\|^2 = \|2(J_A x - J_A y) - (x - y)\|^2.
$$

Let $p = J_A x - J_A y$ and $q = (I - J_A)x - (I - J_A)y = (x - y) - p$. Then:
$$
R_A x - R_A y = 2p - (x - y) = 2p - (p + q) = p - q.
$$

Therefore:
$$
\|R_A x - R_A y\|^2 = \|p - q\|^2 = \|p\|^2 + \|q\|^2 - 2\langle p, q \rangle.
$$

From firm nonexpansivity (Proposition 1):
$$
\|p\|^2 + \|q\|^2 \leq \|x - y\|^2 = \|p + q\|^2 = \|p\|^2 + \|q\|^2 + 2\langle p, q \rangle,
$$
which gives $\langle p, q \rangle \geq 0$. Hence:
$$
\|R_A x - R_A y\|^2 = \|p\|^2 + \|q\|^2 - 2\langle p, q \rangle \leq \|p\|^2 + \|q\|^2 \leq \|x - y\|^2. \qquad \blacksquare
$$

---

## Part 3: The DR Operator is Firmly Nonexpansive

**Proposition 3.** *The Douglas-Rachford operator satisfies*
$$
T_{DR} = \frac{1}{2}(I + R_B R_A),
$$
*and is firmly nonexpansive.*

**Proof.**

**Step 3a: Algebraic identity.** For any $x \in \mathcal{H}$, let $p = J_A(x)$. Then:
$$
T_{DR}(x) = x + J_B(2p - x) - p.
$$

Now compute $R_B R_A(x)$. We have $R_A(x) = 2J_A(x) - x = 2p - x$. Then:
$$
R_B(R_A(x)) = 2J_B(2p - x) - (2p - x).
$$

Therefore:
$$
\frac{1}{2}(I + R_B R_A)(x) = \frac{1}{2}\big(x + 2J_B(2p - x) - 2p + x\big) = x - p + J_B(2p - x) = T_{DR}(x).
$$

This confirms $T_{DR} = \frac{1}{2}(I + R_B R_A)$.

**Step 3b: $T_{DR}$ is firmly nonexpansive.** By Propositions 2, both $R_A$ and $R_B$ are nonexpansive. Since the composition of nonexpansive operators is nonexpansive, $S := R_B R_A$ is nonexpansive. We now show that $T = \frac{1}{2}(I + S)$ is firmly nonexpansive whenever $S$ is nonexpansive.

For any $x, y \in \mathcal{H}$:
$$
T(x) - T(y) = \frac{1}{2}\big((x - y) + (Sx - Sy)\big).
$$

We compute:
$$
\|T(x) - T(y)\|^2 = \frac{1}{4}\|x - y\|^2 + \frac{1}{4}\|Sx - Sy\|^2 + \frac{1}{2}\langle x - y, Sx - Sy \rangle. \tag{3.1}
$$

Also:
$$
(I - T)(x) - (I - T)(y) = \frac{1}{2}\big((x - y) - (Sx - Sy)\big),
$$
$$
\|(I - T)(x) - (I - T)(y)\|^2 = \frac{1}{4}\|x - y\|^2 + \frac{1}{4}\|Sx - Sy\|^2 - \frac{1}{2}\langle x - y, Sx - Sy \rangle. \tag{3.2}
$$

Adding (3.1) and (3.2):
$$
\|T(x) - T(y)\|^2 + \|(I - T)(x) - (I - T)(y)\|^2 = \frac{1}{2}\|x - y\|^2 + \frac{1}{2}\|Sx - Sy\|^2.
$$

Since $S$ is nonexpansive, $\|Sx - Sy\|^2 \leq \|x - y\|^2$, so:
$$
\|T(x) - T(y)\|^2 + \|(I - T)(x) - (I - T)(y)\|^2 \leq \|x - y\|^2. \qquad \blacksquare
$$

**Remark.** Firm nonexpansivity implies nonexpansivity: $\|T_{DR}(x) - T_{DR}(y)\| \leq \|x - y\|$.

---

## Part 4: Fixed Point Characterization

**Proposition 4.** *$x^* \in \text{Fix}(T_{DR})$ if and only if $J_A(x^*) \in \text{zer}(A + B)$.*

**Proof.**

$(\Rightarrow)$ Suppose $T_{DR}(x^*) = x^*$. Let $p^* = J_A(x^*)$. Then:
$$
x^* = x^* + J_B(2p^* - x^*) - p^*,
$$
which simplifies to:
$$
J_B(2p^* - x^*) = p^*. \tag{4.1}
$$

From $p^* = J_A(x^*)$:
$$
x^* \in (I + A)(p^*), \quad \text{i.e.,} \quad x^* - p^* \in A(p^*). \tag{4.2}
$$

From (4.1), $p^* = J_B(2p^* - x^*)$, so:
$$
2p^* - x^* \in (I + B)(p^*), \quad \text{i.e.,} \quad (2p^* - x^*) - p^* = p^* - x^* \in B(p^*),
$$
hence
$$
-(x^* - p^*) \in B(p^*), \quad \text{i.e.,} \quad x^* - p^* \in -B(p^*). \tag{4.3}
$$

Wait -- let us redo this carefully. From (4.1):
$$
p^* = (I + B)^{-1}(2p^* - x^*) \implies 2p^* - x^* \in (I + B)(p^*) = p^* + B(p^*),
$$
so
$$
2p^* - x^* - p^* \in B(p^*), \quad \text{i.e.,} \quad p^* - x^* \in B(p^*).
$$

But from (4.2), $x^* - p^* \in A(p^*)$, so $p^* - x^* = -(x^* - p^*)$.

Now set $w = x^* - p^*$. Then:
- $w \in A(p^*)$ from (4.2),
- $-w \in B(p^*)$, i.e., $-w \in B(p^*)$.

Therefore $0 = w + (-w) \in A(p^*) + B(p^*)$, which means $p^* \in \text{zer}(A + B)$.

$(\Leftarrow)$ Suppose $p^* \in \text{zer}(A + B)$, so there exists $w$ with $w \in A(p^*)$ and $-w \in B(p^*)$. Set $x^* = p^* + w$.

Then $x^* - p^* = w \in A(p^*)$, so $p^* = J_A(x^*)$.

Also, $-w \in B(p^*)$ means $p^* \in (I + B)^{-1}(p^* - w) = J_B(p^* - w)$. Note that:
$$
2p^* - x^* = 2p^* - (p^* + w) = p^* - w.
$$

So $J_B(2p^* - x^*) = J_B(p^* - w) = p^* = J_A(x^*)$.

Therefore:
$$
T_{DR}(x^*) = x^* + J_B(2J_A(x^*) - x^*) - J_A(x^*) = x^* + p^* - p^* = x^*,
$$
confirming $x^* \in \text{Fix}(T_{DR})$.

Moreover, $\text{zer}(A + B) \neq \emptyset$ implies $\text{Fix}(T_{DR}) \neq \emptyset$. $\qquad \blacksquare$

---

## Part 5: Weak Convergence of the DR Iteration

We now prove the main convergence theorem.

**Theorem (Douglas-Rachford Convergence).** *Let $A, B$ be maximal monotone on $\mathcal{H}$ with $\text{zer}(A+B) \neq \emptyset$. Let $x_0 \in \mathcal{H}$ and $x_{t+1} = T_{DR}(x_t)$. Then:*

1. *$\{x_t\}$ converges weakly to some $x^* \in \text{Fix}(T_{DR})$.*
2. *$\{J_A(x_t)\}$ converges weakly to $p^* = J_A(x^*) \in \text{zer}(A+B)$.*

**Proof.** We proceed in several steps.

### Step 5.1: Fej\'er Monotonicity

Let $z \in \text{Fix}(T_{DR})$ (which is nonempty by Proposition 4). Since $T_{DR}$ is firmly nonexpansive (Proposition 3), it is in particular nonexpansive:
$$
\|x_{t+1} - z\| = \|T_{DR}(x_t) - T_{DR}(z)\| \leq \|x_t - z\|.
$$

Therefore $\{\|x_t - z\|\}$ is a non-increasing sequence, bounded below by $0$, hence convergent. In particular:
$$
\lim_{t \to \infty} \|x_t - z\| \text{ exists for every } z \in \text{Fix}(T_{DR}). \tag{5.1}
$$

This is the **Fej\'er monotonicity** of $\{x_t\}$ with respect to $\text{Fix}(T_{DR})$.

**Consequence:** The sequence $\{x_t\}$ is bounded (since $\|x_t - z\| \leq \|x_0 - z\|$ for all $t$).

### Step 5.2: Asymptotic Regularity ($\|x_t - T_{DR}(x_t)\| \to 0$)

Since $T_{DR}$ is firmly nonexpansive:
$$
\|T_{DR}(x_t) - z\|^2 + \|(I - T_{DR})(x_t) - (I - T_{DR})(z)\|^2 \leq \|x_t - z\|^2.
$$

Since $z = T_{DR}(z)$, we have $(I - T_{DR})(z) = 0$, so:
$$
\|x_{t+1} - z\|^2 + \|x_t - x_{t+1}\|^2 \leq \|x_t - z\|^2.
$$

Rearranging:
$$
\|x_t - x_{t+1}\|^2 \leq \|x_t - z\|^2 - \|x_{t+1} - z\|^2. \tag{5.2}
$$

Summing from $t = 0$ to $T - 1$:
$$
\sum_{t=0}^{T-1} \|x_t - x_{t+1}\|^2 \leq \|x_0 - z\|^2 - \|x_T - z\|^2 \leq \|x_0 - z\|^2 < \infty.
$$

Since the partial sums are bounded, the series converges:
$$
\sum_{t=0}^{\infty} \|x_t - x_{t+1}\|^2 < \infty,
$$
which implies:
$$
\|x_t - x_{t+1}\| = \|x_t - T_{DR}(x_t)\| \to 0 \quad \text{as } t \to \infty. \tag{5.3}
$$

### Step 5.3: Demiclosedness of $I - T_{DR}$

We use the following classical result.

**Lemma (Demiclosedness Principle).** *Let $T : \mathcal{H} \to \mathcal{H}$ be nonexpansive. If $x_n \rightharpoonup \bar{x}$ (weak convergence) and $(I - T)x_n \to 0$ (strong convergence), then $T(\bar{x}) = \bar{x}$.*

*Proof of Lemma.* For any $y \in \mathcal{H}$, by nonexpansivity:
$$
\|Tx_n - Ty\| \leq \|x_n - y\|.
$$

Write $Tx_n = x_n - (x_n - Tx_n)$, so:
$$
\|x_n - (x_n - Tx_n) - Ty\| \leq \|x_n - y\|.
$$

Squaring both sides:
$$
\|x_n - Ty\|^2 - 2\langle x_n - Ty,\, x_n - Tx_n \rangle + \|x_n - Tx_n\|^2 \leq \|x_n - y\|^2.
$$

Since $x_n - Tx_n \to 0$ strongly and $\{x_n\}$ is bounded, the second term $\langle x_n - Ty, x_n - Tx_n \rangle \to 0$ and the third term $\|x_n - Tx_n\|^2 \to 0$. Taking $\liminf$:
$$
\liminf_{n \to \infty} \|x_n - Ty\|^2 \leq \liminf_{n \to \infty} \|x_n - y\|^2.
$$

Now choose $y = \bar{x}$ and $y = T\bar{x}$ respectively. Setting $y = T\bar{x}$:
$$
\liminf_n \|x_n - T(T\bar{x})\|^2 \leq \liminf_n \|x_n - T\bar{x}\|^2.
$$

We establish the result via Opial's property instead. Recall that a Hilbert space satisfies **Opial's property**: if $x_n \rightharpoonup \bar{x}$, then for any $y \neq \bar{x}$:
$$
\liminf_{n \to \infty} \|x_n - \bar{x}\| < \liminf_{n \to \infty} \|x_n - y\|. \tag{Opial}
$$

Suppose for contradiction that $T\bar{x} \neq \bar{x}$. Since $T$ is nonexpansive and $(I - T)x_n \to 0$:
$$
\|Tx_n - T\bar{x}\| \leq \|x_n - \bar{x}\|,
$$
$$
\liminf_n \|x_n - T\bar{x}\| = \liminf_n \|Tx_n + (x_n - Tx_n) - T\bar{x}\| = \liminf_n \|Tx_n - T\bar{x}\| \leq \liminf_n \|x_n - \bar{x}\|,
$$
where we used $\|x_n - Tx_n\| \to 0$ (the error vanishes in norm). But by Opial's property with $y = T\bar{x} \neq \bar{x}$:
$$
\liminf_n \|x_n - \bar{x}\| < \liminf_n \|x_n - T\bar{x}\|.
$$

This contradicts the inequality above. Hence $T\bar{x} = \bar{x}$. $\qquad \square$

### Step 5.4: Weak Convergence via Opial's Theorem

**Lemma (Opial's Weak Convergence Theorem).** *Let $C \subseteq \mathcal{H}$ be nonempty, and let $\{x_t\}$ be a sequence such that:*
1. *$\lim_{t \to \infty} \|x_t - z\|$ exists for every $z \in C$,*
2. *Every weak cluster point of $\{x_t\}$ belongs to $C$.*

*Then $\{x_t\}$ converges weakly to a point in $C$.*

*Proof.* Since $\{x_t\}$ is bounded (by condition 1), it has at least one weak cluster point (by the Banach-Alaoglu theorem in reflexive spaces). 

Suppose $\bar{x}$ and $\hat{x}$ are two weak cluster points, with subsequences $x_{t_k} \rightharpoonup \bar{x}$ and $x_{t_j} \rightharpoonup \hat{x}$. By condition 2, both $\bar{x}, \hat{x} \in C$.

By condition 1, $L_{\bar{x}} := \lim_t \|x_t - \bar{x}\|$ and $L_{\hat{x}} := \lim_t \|x_t - \hat{x}\|$ both exist. Suppose $\bar{x} \neq \hat{x}$. By Opial's property along $\{x_{t_k}\}$:
$$
L_{\bar{x}} = \lim_k \|x_{t_k} - \bar{x}\| < \lim_k \|x_{t_k} - \hat{x}\| = L_{\hat{x}}.
$$

By Opial's property along $\{x_{t_j}\}$:
$$
L_{\hat{x}} = \lim_j \|x_{t_j} - \hat{x}\| < \lim_j \|x_{t_j} - \bar{x}\| = L_{\bar{x}}.
$$

This gives $L_{\bar{x}} < L_{\hat{x}} < L_{\bar{x}}$, a contradiction. Hence $\bar{x} = \hat{x}$, and the weak cluster point is unique. Since $\{x_t\}$ is bounded and has a unique weak cluster point, the entire sequence converges weakly to that point. $\qquad \square$

**Completing the proof of weak convergence.** We apply Opial's Weak Convergence Theorem with $C = \text{Fix}(T_{DR})$:

- **Condition 1** holds by Step 5.1 (Fej\'er monotonicity).
- **Condition 2**: Let $\bar{x}$ be a weak cluster point, with $x_{t_k} \rightharpoonup \bar{x}$. From Step 5.2, $\|x_{t_k} - T_{DR}(x_{t_k})\| \leq \|x_{t_k} - x_{t_k+1}\| \to 0$. By the Demiclosedness Principle (Step 5.3) applied to $T_{DR}$ (which is nonexpansive), $\bar{x} \in \text{Fix}(T_{DR})$.

Therefore, $x_t \rightharpoonup x^*$ for some $x^* \in \text{Fix}(T_{DR})$.

### Step 5.5: Weak Convergence of the Shadow Sequence

Since $J_A$ is firmly nonexpansive, it is in particular nonexpansive and therefore **weakly continuous** in the following sense: if $x_t \rightharpoonup x^*$, then $J_A(x_t) \rightharpoonup J_A(x^*)$.

*Proof of weak continuity:* Let $x_t \rightharpoonup x^*$ and set $p_t = J_A(x_t)$, $p^* = J_A(x^*)$. Since $J_A$ is nonexpansive, $\{p_t\}$ is bounded. Let $\bar{p}$ be any weak cluster point: $p_{t_k} \rightharpoonup \bar{p}$. Since $x_{t_k} - p_{t_k} \in A(p_{t_k})$ and $A$ is maximal monotone, the graph of $A$ is **sequentially weakly-strongly closed** in the following sense: if $p_{t_k} \rightharpoonup \bar{p}$ and $x_{t_k} - p_{t_k} \rightharpoonup x^* - \bar{p}$, and we can show the resolvent relation persists.

More directly: from $x_t - T_{DR}(x_t) \to 0$ and the structure of $T_{DR}$, we use the fact that $J_A$ is nonexpansive. For the shadow sequence, note:

$$
\|J_A(x_t) - J_A(x^*)\| \leq \|x_t - x^*\|.
$$

However, we need the weak convergence argument. By Fej\'er monotonicity, $\|x_t - x^*\|$ converges. Consider: $p_t = J_A(x_t)$ satisfies $x_t - p_t \in A(p_t)$. The sequence $\{p_t\}$ is bounded. Let $p_{t_k} \rightharpoonup \bar{p}$ be any weakly convergent subsequence. 

Since $T_{DR}(x_t) = x_t + J_B(2p_t - x_t) - p_t$ and $x_{t+1} - x_t \to 0$, we get $J_B(2p_t - x_t) - p_t \to 0$ strongly, i.e., $J_B(2p_t - x_t) \to p_t$ (in the sense that the difference vanishes).

Define $q_t := J_B(2p_t - x_t)$. Then $\|q_t - p_t\| = \|x_{t+1} - x_t\| \to 0$.

Now, to show $p_t \rightharpoonup p^*$, we use the following approach. For any $z \in \text{Fix}(T_{DR})$ with shadow $\hat{p} = J_A(z)$:

$$
\|p_t - \hat{p}\|^2 = \|J_A(x_t) - J_A(z)\|^2 \leq \langle x_t - z,\; p_t - \hat{p} \rangle,
$$
where the last inequality is the **characterization of firm nonexpansivity**: $\langle J_A x - J_A y, x - y \rangle \geq \|J_A x - J_A y\|^2$.

This shows $\{p_t\}$ is bounded. Since $x_t \rightharpoonup x^*$ and $J_A$ is the resolvent of a maximal monotone operator, we can apply the weak-strong closedness of the graph: 

For any $(q, w) \in \text{gra}(A)$ (i.e., $w \in A(q)$), monotonicity gives:
$$
\langle x_t - p_t - w,\; p_t - q \rangle \geq 0 \quad \forall t.
$$

Taking a subsequence $x_{t_k} \rightharpoonup x^*$ and any corresponding weak cluster $p_{t_k} \rightharpoonup \bar{p}$:
$$
\langle x^* - \bar{p} - w,\; \bar{p} - q \rangle \geq 0 \quad \forall (q, w) \in \text{gra}(A).
$$

By maximality of $A$, this implies $x^* - \bar{p} \in A(\bar{p})$, i.e., $\bar{p} = J_A(x^*) = p^*$.

Since every weakly convergent subsequence of $\{p_t\}$ converges to the same limit $p^*$, and $\{p_t\}$ is bounded, we conclude $p_t \rightharpoonup p^*$.

By Proposition 4, $p^* = J_A(x^*) \in \text{zer}(A + B)$. $\qquad \blacksquare$

---

## Summary of the Complete Result

**Theorem (Douglas-Rachford Splitting Convergence).** *Let $\mathcal{H}$ be a real Hilbert space, $A, B : \mathcal{H} \rightrightarrows \mathcal{H}$ maximal monotone with $\text{zer}(A+B) \neq \emptyset$. For any $x_0 \in \mathcal{H}$, the Douglas-Rachford iteration*
$$
x_{t+1} = x_t + J_B(2J_A(x_t) - x_t) - J_A(x_t)
$$
*satisfies:*

1. *$T_{DR} = \frac{1}{2}(I + R_B R_A)$ is firmly nonexpansive with $\text{Fix}(T_{DR}) \neq \emptyset$.*
2. *$\{x_t\}$ is Fej\'er monotone w.r.t. $\text{Fix}(T_{DR})$ and converges weakly: $x_t \rightharpoonup x^* \in \text{Fix}(T_{DR})$.*
3. *The shadow sequence converges weakly to a solution: $J_A(x_t) \rightharpoonup p^* \in \text{zer}(A+B)$.* $\qquad \blacksquare$
