# Douglas-Rachford Splitting O(1/k) Convergence for Monotone Inclusions

## Proof

**Route**: Resolvent Composition + Fejér Monotonicity

### Setting

Let $\mathcal{H}$ be a real Hilbert space with inner product $\langle \cdot, \cdot \rangle$ and norm $\|\cdot\|$. Let $A, B: \mathcal{H} \rightrightarrows \mathcal{H}$ be maximal monotone operators with $\text{zer}(A+B) \neq \emptyset$.

The Douglas-Rachford iteration: given $z_0 \in \mathcal{H}$,
$$
x_k = J_{\gamma B}(z_k), \quad y_k = J_{\gamma A}(2x_k - z_k), \quad z_{k+1} = z_k + y_k - x_k.
$$

Equivalently, $z_{k+1} = T_{DR}(z_k)$ where $T_{DR} = \text{Id} + J_{\gamma A}(2J_{\gamma B} - \text{Id}) - J_{\gamma B}$.

**Notation.** Throughout, $J_A := J_{\gamma A} = (\text{Id} + \gamma A)^{-1}$ and $J_B := J_{\gamma B} = (\text{Id} + \gamma B)^{-1}$ denote the resolvents, and $R_A := 2J_A - \text{Id}$, $R_B := 2J_B - \text{Id}$ denote the reflected resolvents.

---

### Step 1: Resolvents are firmly nonexpansive; reflected resolvents are nonexpansive

**Proposition 1.** For any maximal monotone $A$ and $\gamma > 0$, $J_A$ is firmly nonexpansive (FNE):
$$
\|J_A u - J_A v\|^2 + \|(\text{Id} - J_A)u - (\text{Id} - J_A)v\|^2 \leq \|u - v\|^2 \quad \forall u, v \in \mathcal{H}.
$$

**Proof.** Set $p = J_A(u)$ and $q = J_A(v)$. Then $u \in p + \gamma A(p)$ and $v \in q + \gamma A(q)$, i.e., $u - p \in \gamma A(p)$ and $v - q \in \gamma A(q)$.

By monotonicity of $A$ (equivalently $\gamma A$):
$$
\langle (u - p) - (v - q),\, p - q \rangle \geq 0.
$$
Expanding: $\langle u - v, p - q \rangle - \|p - q\|^2 \geq 0$, hence:
$$
\langle u - v,\, p - q \rangle \geq \|p - q\|^2. \tag{1.1}
$$

Decompose $u - v = (p - q) + \big((u - p) - (v - q)\big)$. By the Pythagorean-like expansion:
$$
\|u - v\|^2 = \|p - q\|^2 + \|(u-p)-(v-q)\|^2 + 2\langle p - q,\, (u-p)-(v-q)\rangle.
$$

The cross term equals $2\langle p-q, u-v\rangle - 2\|p-q\|^2 \geq 0$ by (1.1). Therefore:
$$
\|u - v\|^2 \geq \|p - q\|^2 + \|(u-p)-(v-q)\|^2. \qquad \blacksquare
$$

**Corollary 2.** $R_A = 2J_A - \text{Id}$ is nonexpansive.

**Proof.** Write $J_A u - J_A v = p - q$ and $(\text{Id} - J_A)u - (\text{Id} - J_A)v = (u-v) - (p-q)$. Then $R_A u - R_A v = 2(p-q) - (u-v) = (p-q) - \big((u-v) - (p-q)\big)$. So:
$$
\|R_A u - R_A v\|^2 = \|p-q\|^2 + \|(u-v)-(p-q)\|^2 - 2\langle p-q,\, (u-v)-(p-q)\rangle.
$$

From FNE of $J_A$: $\langle p-q, (u-v)-(p-q)\rangle = \langle p-q, u-v\rangle - \|p-q\|^2 \geq 0$ by (1.1). Hence:
$$
\|R_A u - R_A v\|^2 \leq \|p-q\|^2 + \|(u-v)-(p-q)\|^2 \leq \|u-v\|^2. \qquad \blacksquare
$$

---

### Step 2: $T_{DR}$ is firmly nonexpansive

**Proposition 3.** $T_{DR} = \frac{1}{2}(\text{Id} + R_A \circ R_B)$, and $T_{DR}$ is FNE.

**Proof.**

**Step 2a (Algebraic identity).** For any $z \in \mathcal{H}$, let $x = J_B(z)$. Then:
$$
T_{DR}(z) = z + J_A(2x - z) - x = z + J_A(R_B(z)) - x.
$$

Since $x = J_B(z) = \frac{z + R_B(z)}{2}$ (from $R_B = 2J_B - \text{Id}$):
$$
T_{DR}(z) = z - \frac{z + R_B(z)}{2} + J_A(R_B(z)) = \frac{z - R_B(z)}{2} + J_A(R_B(z)).
$$

Now $J_A(R_B(z)) = \frac{R_B(z) + R_A(R_B(z))}{2}$ (again from $R_A = 2J_A - \text{Id}$). Substituting:
$$
T_{DR}(z) = \frac{z - R_B(z)}{2} + \frac{R_B(z) + R_A(R_B(z))}{2} = \frac{z + R_A(R_B(z))}{2}.
$$

Therefore:
$$
\boxed{T_{DR} = \frac{\text{Id} + R_A \circ R_B}{2}.}
$$

**Step 2b ($T_{DR}$ is FNE).** Let $S := R_A \circ R_B$. Since $R_A$ and $R_B$ are both nonexpansive (Corollary 2), $S$ is nonexpansive. We show $T = \frac{1}{2}(\text{Id} + S)$ is FNE.

For any $u, v \in \mathcal{H}$, set $d = u - v$ and $\delta = Su - Sv$. Then:
$$
Tu - Tv = \frac{d + \delta}{2}, \qquad (\text{Id} - T)u - (\text{Id} - T)v = \frac{d - \delta}{2}.
$$

Compute:
$$
\|Tu - Tv\|^2 + \|(\text{Id}-T)u - (\text{Id}-T)v\|^2 = \frac{\|d+\delta\|^2 + \|d-\delta\|^2}{4} = \frac{2\|d\|^2 + 2\|\delta\|^2}{4} = \frac{\|d\|^2 + \|\delta\|^2}{2}.
$$

(Using the parallelogram law: $\|a+b\|^2 + \|a-b\|^2 = 2\|a\|^2 + 2\|b\|^2$.)

Since $S$ is nonexpansive: $\|\delta\|^2 = \|Su - Sv\|^2 \leq \|u - v\|^2 = \|d\|^2$, so:
$$
\|Tu - Tv\|^2 + \|(\text{Id}-T)u - (\text{Id}-T)v\|^2 \leq \frac{\|d\|^2 + \|d\|^2}{2} = \|d\|^2 = \|u - v\|^2.
$$

This is exactly the FNE condition. $\qquad \blacksquare$

---

### Step 3: Fixed point characterization

**Proposition 4.** $\text{Fix}(T_{DR}) \neq \emptyset$, and $z^* \in \text{Fix}(T_{DR})$ if and only if $x^* := J_B(z^*) \in \text{zer}(A+B)$.

**Proof.**

$(\Rightarrow)$ Let $T_{DR}(z^*) = z^*$. Set $x^* = J_B(z^*)$ and $y^* = J_A(2x^* - z^*)$. Then:
$$
z^* = z^* + y^* - x^* \implies y^* = x^*.
$$

From $x^* = J_B(z^*)$: $z^* - x^* \in \gamma B(x^*)$.

From $y^* = J_A(2x^* - z^*)$: $(2x^* - z^*) - y^* \in \gamma A(y^*)$. Since $y^* = x^*$:
$$
x^* - z^* \in \gamma A(x^*).
$$

Set $w = (z^* - x^*)/\gamma$. Then $w \in B(x^*)$ and $-w \in A(x^*)$, so $0 = w + (-w) \in A(x^*) + B(x^*)$.

$(\Leftarrow)$ Let $p \in \text{zer}(A+B)$: there exist $a \in A(p)$, $b \in B(p)$ with $a + b = 0$. Set $z^* = p + \gamma b$.

Then $z^* - p = \gamma b \in \gamma B(p)$, so $p = J_B(z^*)$, i.e., $x^* = p$.

Also $2p - z^* = p - \gamma b = p + \gamma a$, so $(2p - z^*) - p = \gamma a \in \gamma A(p)$, giving $p = J_A(2p - z^*)$, i.e., $y^* = p$.

Since $y^* = x^* = p$: $T_{DR}(z^*) = z^* + p - p = z^*$. $\qquad \blacksquare$

---

### Step 4: Fejér monotonicity and the O(1/k) convergence rate

**Step 4a (Fejér inequality with residual).** Let $z^* \in \text{Fix}(T_{DR})$. Since $T_{DR}$ is FNE:
$$
\|T_{DR}(z) - z^*\|^2 + \|T_{DR}(z) - z\|^2 \leq \|z - z^*\|^2 \quad \forall z \in \mathcal{H}. \tag{4.1}
$$

*Derivation.* FNE gives $\|T_{DR}(z) - T_{DR}(z^*)\|^2 + \|(z - T_{DR}(z)) - (z^* - T_{DR}(z^*))\|^2 \leq \|z - z^*\|^2$. Since $T_{DR}(z^*) = z^*$, the second term is $\|z - T_{DR}(z)\|^2$. $\square$

Applying (4.1) at iteration $k$ with $z_{k+1} = T_{DR}(z_k)$:
$$
\|z_{k+1} - z^*\|^2 + \|z_{k+1} - z_k\|^2 \leq \|z_k - z^*\|^2. \tag{4.2}
$$

**Consequences of (4.2):**

(i) **Fejér monotonicity:** $\|z_k - z^*\|$ is nonincreasing, hence $\lim_{k\to\infty}\|z_k - z^*\|$ exists.

(ii) **Boundedness:** $\|z_k - z^*\| \leq \|z_0 - z^*\|$ for all $k$.

**Step 4b (Telescoping sum).** Rearranging (4.2):
$$
\|z_{k+1} - z_k\|^2 \leq \|z_k - z^*\|^2 - \|z_{k+1} - z^*\|^2.
$$

Summing from $k = 0$ to $K-1$:
$$
\sum_{k=0}^{K-1} \|z_{k+1} - z_k\|^2 \leq \|z_0 - z^*\|^2 - \|z_K - z^*\|^2 \leq \|z_0 - z^*\|^2.
$$

Taking the infimum over $z^* \in \text{Fix}(T_{DR})$:
$$
\sum_{k=0}^{K-1} \|z_{k+1} - z_k\|^2 \leq \text{dist}(z_0,\, \text{Fix}(T_{DR}))^2 =: D^2. \tag{4.3}
$$

**Step 4c (Monotonicity of residuals).** Since $T_{DR}$ is nonexpansive (FNE $\implies$ nonexpansive):
$$
\|z_{k+1} - z_k\| = \|T_{DR}(z_k) - T_{DR}(z_{k-1})\| \leq \|z_k - z_{k-1}\|. \tag{4.4}
$$

The sequence of residuals $\|z_{k+1} - z_k\|$ is **nonincreasing**.

**Step 4d (O(1/k) rate).** From (4.4), for each $j \in \{1, \ldots, k\}$:
$$
\|z_k - z_{k-1}\|^2 \leq \|z_j - z_{j-1}\|^2.
$$

Hence:
$$
k \cdot \|z_k - z_{k-1}\|^2 \leq \sum_{j=1}^{k} \|z_j - z_{j-1}\|^2 \leq D^2,
$$

where the second inequality is (4.3) (the sum from $j=0$ to $k-1$ with index shift). Therefore:

$$
\boxed{\|z_k - z_{k-1}\|^2 \leq \frac{\text{dist}(z_0,\, \text{Fix}(T_{DR}))^2}{k}.} \tag{4.5}
$$

This gives $\|z_k - z_{k-1}\| = O(1/\sqrt{k})$, i.e., the squared residual converges at rate $O(1/k)$.

**Corollary.** $\|z_{k+1} - z_k\| \to 0$ as $k \to \infty$ (asymptotic regularity). $\qquad \blacksquare$

---

### Step 5: Weak convergence of $\{x_k\}$ to a point in $\text{zer}(A+B)$

**Step 5a (Boundedness).** From Fejér monotonicity, $\{z_k\}$ is bounded. Since $J_B$ is nonexpansive, $\{x_k\} = \{J_B(z_k)\}$ is bounded. Since $y_k - x_k = z_{k+1} - z_k \to 0$, $\{y_k\}$ is also bounded.

**Step 5b (Demiclosedness principle).** We use the classical result:

**Lemma (Browder 1965).** Let $T: \mathcal{H} \to \mathcal{H}$ be nonexpansive. If $w_n \rightharpoonup w$ and $(I - T)w_n \to 0$ strongly, then $w \in \text{Fix}(T)$.

*Proof.* Suppose $Tw \neq w$. By Hilbert space Opial property: if $w_n \rightharpoonup w$, then $\liminf_n \|w_n - w\| < \liminf_n \|w_n - y\|$ for any $y \neq w$.

Since $(I-T)w_n \to 0$: $\|Tw_n - w_n\| \to 0$. By nonexpansivity of $T$:
$$
\liminf_n \|w_n - Tw\| = \liminf_n \|Tw_n - Tw\| \leq \liminf_n \|w_n - w\|,
$$
where the equality uses $\|w_n - Tw\| = \|(w_n - Tw_n) + (Tw_n - Tw)\|$ and $\|w_n - Tw_n\| \to 0$.

But Opial's property with $y = Tw \neq w$ gives:
$$
\liminf_n \|w_n - w\| < \liminf_n \|w_n - Tw\|.
$$

Contradiction. Hence $Tw = w$. $\square$

**Step 5c (Opial's weak convergence theorem).** We apply:

**Lemma (Opial).** Let $C \subseteq \mathcal{H}$ be nonempty, $\{z_k\}$ a sequence such that:
1. $\lim_{k\to\infty} \|z_k - z^*\|$ exists for every $z^* \in C$,
2. Every weak cluster point of $\{z_k\}$ belongs to $C$.

Then $z_k \rightharpoonup$ some point in $C$.

*Proof.* $\{z_k\}$ is bounded (condition 1), so weak cluster points exist (Banach-Alaoglu in reflexive spaces). If $\bar{z}, \hat{z}$ are two weak cluster points (both in $C$ by condition 2) with $\bar{z} \neq \hat{z}$, Opial's property along the respective subsequences gives:
$$
\lim_k \|z_k - \bar{z}\| < \lim_k \|z_k - \hat{z}\| < \lim_k \|z_k - \bar{z}\|,
$$
a contradiction. Hence the weak cluster point is unique. $\square$

**Step 5d (Application to $\{z_k\}$).** Set $C = \text{Fix}(T_{DR})$.

- Condition 1: Fejér monotonicity (Step 4a).
- Condition 2: Let $z_{k_n} \rightharpoonup \bar{z}$. From asymptotic regularity $\|z_{k_n} - T_{DR}(z_{k_n})\| = \|z_{k_n} - z_{k_n+1}\| \to 0$. By demiclosedness (Step 5b) applied to $T_{DR}$ (nonexpansive), $\bar{z} \in \text{Fix}(T_{DR})$.

By Opial's theorem: $z_k \rightharpoonup z^* \in \text{Fix}(T_{DR})$.

**Step 5e (Strong convergence of $\{x_k\}$).** Set $p^* = J_B(z^*) \in \text{zer}(A+B)$ (by Proposition 4). By FNE of $J_B$:
$$
\|x_k - p^*\|^2 = \|J_B(z_k) - J_B(z^*)\|^2 \leq \langle J_B(z_k) - J_B(z^*),\, z_k - z^*\rangle = \langle x_k - p^*,\, z_k - z^*\rangle. \tag{5.1}
$$

Since $z_k \rightharpoonup z^*$ (weak) and $\{x_k - p^*\}$ is bounded, the right side converges to 0:
$$
\langle x_k - p^*,\, z_k - z^*\rangle \to 0.
$$

Therefore $\|x_k - p^*\| \to 0$, i.e., $x_k \to p^*$ **strongly**.

In particular, $x_k \rightharpoonup p^* \in \text{zer}(A+B)$ (strong convergence implies weak convergence).

$$
\boxed{x_k \to p^* \in \text{zer}(A+B).}
$$

$\qquad \blacksquare$

---

## Summary

| Result | Statement | Key tool |
|--------|-----------|----------|
| (1) $T_{DR}$ is FNE | $T_{DR} = \frac{1}{2}(\text{Id} + R_A R_B)$, average of Id and nonexpansive | Resolvent FNE $\Rightarrow$ reflected resolvent NE |
| (2) O(1/k) rate | $\|z_k - z_{k-1}\|^2 \leq D^2/k$ | Fejér inequality + monotone residuals + telescoping |
| (3) Weak convergence | $x_k \to p^* \in \text{zer}(A+B)$ (actually strong!) | Opial + demiclosedness + FNE of $J_B$ |
