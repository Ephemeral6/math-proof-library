# RIP Sparse Recovery Guarantee — Proof

**Theorem.** Let $A \in \mathbb{R}^{m \times n}$ satisfy the Restricted Isometry Property of order $2s$ with constant $\delta_{2s} < \sqrt{2} - 1$. If $x^* \in \mathbb{R}^n$ is $s$-sparse and $b = Ax^*$, then $x^*$ is the unique solution to $\min_{x}\|x\|_1$ subject to $Ax = b$.

## Preliminaries

**Definition (RIP).** The matrix $A$ satisfies RIP of order $k$ with constant $\delta_k \in [0,1)$ if for all $k$-sparse vectors $x$:
$$(1-\delta_k)\|x\|_2^2 \leq \|Ax\|_2^2 \leq (1+\delta_k)\|x\|_2^2$$

**Lemma (Restricted Orthogonality Property).** If $u$ and $v$ have disjoint supports with $|\text{supp}(u) \cup \text{supp}(v)| \leq k$, then:
$$|\langle Au, Av\rangle| \leq \delta_k \|u\|_2\|v\|_2$$

*Proof.* For any $\lambda > 0$, define $\tilde{u} = \lambda u$ and $\tilde{v} = v/\lambda$. These have disjoint supports with combined support size $\leq k$, and $\|\tilde{u} \pm \tilde{v}\|_2^2 = \lambda^2\|u\|_2^2 + \|v\|_2^2/\lambda^2$ (orthogonality from disjoint supports).

By polarization and RIP:
$$\langle Au, Av\rangle = \langle A\tilde{u}, A\tilde{v}\rangle = \frac{1}{4}[\|A(\tilde{u}+\tilde{v})\|_2^2 - \|A(\tilde{u}-\tilde{v})\|_2^2] \leq \frac{\delta_k}{2}(\lambda^2\|u\|_2^2 + \|v\|_2^2/\lambda^2)$$

Optimizing over $\lambda > 0$: the minimum of $f(\lambda) = \lambda^2\|u\|_2^2 + \|v\|_2^2/\lambda^2$ is $2\|u\|_2\|v\|_2$, attained at $\lambda^2 = \|v\|_2/\|u\|_2$. Therefore:
$$\langle Au, Av\rangle \leq \delta_k \|u\|_2\|v\|_2$$

The lower bound follows symmetrically (swapping the RIP bounds in the polarization). If $u = 0$ or $v = 0$, the bound holds trivially. □

## Main Proof

Write $\delta = \delta_{2s}$ throughout. Let $\hat{x}$ solve $\min\|x\|_1$ s.t. $Ax = b$, and define $h = \hat{x} - x^*$.

**Step 1: Cone constraint.** Since $Ah = 0$ and $\|\hat{x}\|_1 \leq \|x^*\|_1$, with $T_0 = \text{supp}(x^*)$:

$$\|h_{T_0^c}\|_1 \leq \|h_{T_0}\|_1 \tag{C}$$

*Proof:* We have $\|x^*_{T_0}\|_1 \geq \|\hat{x}\|_1 = \|x^*_{T_0} + h_{T_0}\|_1 + \|h_{T_0^c}\|_1 \geq \|x^*_{T_0}\|_1 - \|h_{T_0}\|_1 + \|h_{T_0^c}\|_1$, where the first inequality is ℓ₁ optimality of $\hat{x}$, the equality uses $x^*_{T_0^c} = 0$, and the second inequality is the reverse triangle inequality.

**Step 2: Block decomposition and tail bound.** Partition $T_0^c$ into blocks $T_1, T_2, T_3, \ldots$ of size $s$, sorted by decreasing $|h_i|$. For $j \geq 2$:

$$\|h_{T_j}\|_2 \leq \frac{1}{\sqrt{s}}\|h_{T_{j-1}}\|_1 \tag{T}$$

since $\|h_{T_j}\|_\infty \leq \frac{1}{s}\|h_{T_{j-1}}\|_1$ (each entry of $T_j$ is at most the average absolute value of entries in $T_{j-1}$, which has $s$ entries all at least as large) and $\|h_{T_j}\|_2 \leq \sqrt{|T_j|}\|h_{T_j}\|_\infty \leq \sqrt{s}\|h_{T_j}\|_\infty$.

Summing over $j \geq 2$ and applying (C) then Cauchy-Schwarz ($\|h_{T_0}\|_1 \leq \sqrt{|T_0|}\|h_{T_0}\|_2 \leq \sqrt{s}\|h_{T_0}\|_2$):

$$\beta := \sum_{j \geq 2}\|h_{T_j}\|_2 \leq \frac{1}{\sqrt{s}}\sum_{j \geq 1}\|h_{T_j}\|_1 = \frac{1}{\sqrt{s}}\|h_{T_0^c}\|_1 \leq \frac{1}{\sqrt{s}}\|h_{T_0}\|_1 \leq \|h_{T_0}\|_2 \tag{B}$$

**Step 3: Inner product identity.** Let $T_{01} = T_0 \cup T_1$ with $|T_{01}| \leq 2s$. From $Ah = 0$:

$$Ah_{T_{01}} = -\sum_{j \geq 2} Ah_{T_j}$$

Taking the inner product with $Ah_{T_{01}}$:

$$\|Ah_{T_{01}}\|_2^2 = -\sum_{j \geq 2}\langle Ah_{T_{01}}, Ah_{T_j}\rangle \tag{I}$$

**Step 4: RIP lower bound.** Since $|T_{01}| \leq 2s$:

$$\|Ah_{T_{01}}\|_2^2 \geq (1-\delta)\|h_{T_{01}}\|_2^2 = (1-\delta)(a^2 + b^2) \tag{L}$$

where $a = \|h_{T_0}\|_2$ and $b = \|h_{T_1}\|_2$.

**Step 5: ROP upper bound on cross-terms.** For each $j \geq 2$, decompose:
$$\langle Ah_{T_{01}}, Ah_{T_j}\rangle = \langle Ah_{T_0}, Ah_{T_j}\rangle + \langle Ah_{T_1}, Ah_{T_j}\rangle$$

Since $|T_0 \cup T_j| \leq s + s = 2s$ and $|T_1 \cup T_j| \leq s + s = 2s$ (all blocks have size $\leq s$, and the pairs are disjoint), the ROP lemma gives:

$$|\langle Ah_{T_{01}}, Ah_{T_j}\rangle| \leq \delta a \|h_{T_j}\|_2 + \delta b \|h_{T_j}\|_2 = \delta(a + b)\|h_{T_j}\|_2$$

Summing over $j \geq 2$ via (I):

$$\|Ah_{T_{01}}\|_2^2 \leq \delta(a + b)\beta \tag{U}$$

**Step 6: Quadratic contradiction.** Combining (L) and (U) with $\beta \leq a$ from (B):

$$(1-\delta)(a^2 + b^2) \leq \delta a(a + b)$$

**Case $a = 0$:** $(1-\delta)b^2 \leq 0$ implies $b = 0$ (since $\delta < 1$). By (B), $\beta \leq a = 0$, so all $h_{T_j} = 0$ for $j \geq 2$. Hence $h = 0$.

**Case $a > 0$:** Divide by $a^2$ and set $t = b/a \geq 0$:

$$(1-\delta)t^2 - \delta t + (1-2\delta) \leq 0 \tag{Q}$$

Analyze this quadratic $f(t) = (1-\delta)t^2 - \delta t + (1-2\delta)$:
- **Leading coefficient:** $1-\delta > 0$ (since $\delta < 1$)
- **Value at $t = 0$:** $f(0) = 1-2\delta > 0$ (since $\delta < \sqrt{2}-1 < 1/2$)
- **Discriminant:** $\Delta = \delta^2 - 4(1-\delta)(1-2\delta) = -7\delta^2 + 12\delta - 4$

The discriminant $\Delta < 0$ iff $7\delta^2 - 12\delta + 4 > 0$. The roots of $7x^2 - 12x + 4 = 0$ are:
$$x = \frac{12 \pm \sqrt{144 - 112}}{14} = \frac{6 \pm 2\sqrt{2}}{7}$$

So $\Delta < 0$ for $\delta < \frac{6 - 2\sqrt{2}}{7} \approx 0.4525$.

Since $\delta < \sqrt{2} - 1 \approx 0.4142 < \frac{6 - 2\sqrt{2}}{7}$, we have $\Delta < 0$.

With positive leading coefficient and negative discriminant, $f(t) > 0$ for all $t \in \mathbb{R}$, so inequality (Q) has **no solution**. This contradicts $a > 0$.

**Step 7: Conclusion.** We must have $a = \|h_{T_0}\|_2 = 0$. By the cone constraint (C):

$$\|h_{T_0^c}\|_1 \leq \|h_{T_0}\|_1 = 0$$

Therefore $h = 0$, i.e., $\hat{x} = x^*$. The solution is unique.

**Q.E.D.** $\blacksquare$

---

## Proof Structure Summary

| Step | Content | Key Tool |
|------|---------|----------|
| 1 | Cone constraint from ℓ₁ optimality | Reverse triangle inequality |
| 2 | Block decomposition, tail bound $\beta \leq a$ | Sorting + Cauchy-Schwarz |
| 3 | Inner product identity from $Ah = 0$ | Kernel condition |
| 4 | Lower bound via RIP on $T_0 \cup T_1$ | RIP of order $2s$ |
| 5 | Upper bound via ROP on $(T_0, T_j)$ and $(T_1, T_j)$ | ROP (from RIP via polarization + rescaling) |
| 6 | Quadratic infeasibility | Discriminant $< 0$ under $\delta < \sqrt{2}-1$ |
| 7 | Cone constraint closes | $h_{T_0} = 0 \Rightarrow h = 0$ |

**Remark.** The proof establishes recovery under $\delta_{2s} < \frac{6-2\sqrt{2}}{7} \approx 0.4525$, which is slightly weaker than needed. The condition $\delta_{2s} < \sqrt{2}-1$ is sufficient since $\sqrt{2}-1 < \frac{6-2\sqrt{2}}{7}$.
