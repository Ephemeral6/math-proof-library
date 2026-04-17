# Proof Route 1: Candes-Tao Block Decomposition

**Route**: Standard block decomposition with direct RIP argument

## Proof

**Setting.** Let $A \in \mathbb{R}^{m \times n}$ satisfy RIP of order $2s$ with constant $\delta := \delta_{2s} < \sqrt{2} - 1$. Let $x^* \in \mathbb{R}^n$ be $s$-sparse with $b = Ax^*$, and let $\hat{x}$ solve $\min \|x\|_1$ subject to $Ax = b$.

**Step 1: Setup and error vector.**

Define the error vector $h = \hat{x} - x^*$. Since $A\hat{x} = Ax^* = b$, we have $Ah = 0$, i.e., $h \in \ker(A)$.

**Step 2: Block decomposition of h.**

Let $T_0 \subset \{1, \ldots, n\}$ be the support of $x^*$, with $|T_0| \leq s$.

Partition $T_0^c$ into blocks of size $s$:
- $T_1$: indices of the $s$ largest entries of $h_{T_0^c}$ (in absolute value)
- $T_2$: indices of the next $s$ largest entries of $h_{T_0^c}$
- $T_3, T_4, \ldots$: continuing in decreasing order of $|h_i|$

Each block satisfies $|T_j| \leq s$ for all $j \geq 0$.

**Step 3: Cone constraint from ℓ₁ optimality.**

Since $\hat{x}$ minimizes $\|x\|_1$ subject to $Ax = b$ and $x^*$ is feasible:
$$\|\hat{x}\|_1 \leq \|x^*\|_1$$

Write $\hat{x} = x^* + h$. On $T_0$: $\hat{x}_{T_0} = x^*_{T_0} + h_{T_0}$. On $T_0^c$: $\hat{x}_{T_0^c} = h_{T_0^c}$ (since $x^*_{T_0^c} = 0$).

By triangle inequality:
$$\|x^*_{T_0} + h_{T_0}\|_1 + \|h_{T_0^c}\|_1 \leq \|x^*_{T_0}\|_1$$

This gives (using reverse triangle inequality on $T_0$):
$$\|x^*_{T_0}\|_1 - \|h_{T_0}\|_1 + \|h_{T_0^c}\|_1 \leq \|x^*_{T_0}\|_1$$

Therefore:
$$\|h_{T_0^c}\|_1 \leq \|h_{T_0}\|_1 \quad \text{(cone constraint)} \tag{1}$$

**Step 4: Tail bound via sorting.**

For $j \geq 2$, since entries in $T_j$ are smaller in absolute value than all entries in $T_{j-1}$ (which has $s$ entries):
$$\|h_{T_j}\|_\infty \leq \frac{1}{s}\|h_{T_{j-1}}\|_1$$

Therefore:
$$\|h_{T_j}\|_2^2 \leq s \cdot \|h_{T_j}\|_\infty^2 \leq \frac{1}{s}\|h_{T_{j-1}}\|_1^2$$

Taking square roots and summing:
$$\|h_{T_j}\|_2 \leq \frac{1}{\sqrt{s}}\|h_{T_{j-1}}\|_1 \tag{2}$$

Summing over $j \geq 2$:
$$\sum_{j \geq 2} \|h_{T_j}\|_2 \leq \frac{1}{\sqrt{s}} \sum_{j \geq 1} \|h_{T_j}\|_1 = \frac{1}{\sqrt{s}} \|h_{T_0^c}\|_1 \leq \frac{1}{\sqrt{s}} \|h_{T_0}\|_1 \leq \|h_{T_0}\|_2 \tag{3}$$

where the last step uses $\|h_{T_0}\|_1 \leq \sqrt{s}\|h_{T_0}\|_2$ (Cauchy-Schwarz, since $|T_0| \leq s$).

**Step 5: Key identity from Ah = 0.**

Let $T_{01} = T_0 \cup T_1$, so $|T_{01}| \leq 2s$. Since $Ah = 0$:
$$A h_{T_{01}} = -\sum_{j \geq 2} A h_{T_j}$$

Taking the inner product with $Ah_{T_{01}}$:
$$\|Ah_{T_{01}}\|_2^2 = -\sum_{j \geq 2} \langle Ah_{T_{01}}, Ah_{T_j} \rangle \tag{4}$$

**Step 6: Lower bound via RIP.**

Since $|T_{01}| \leq 2s$, RIP gives:
$$\|Ah_{T_{01}}\|_2^2 \geq (1 - \delta)\|h_{T_{01}}\|_2^2 \tag{5}$$

**Step 7: Upper bound on cross-terms.**

For each $j \geq 2$, the vectors $h_{T_{01}}$ and $h_{T_j}$ have disjoint supports, and each has support size $\leq 2s$ (since $|T_{01}| \leq 2s$ and $|T_j| \leq s$). We need the Restricted Orthogonality Property.

**Lemma (ROP from RIP).** If $u, v$ have disjoint supports with $|\text{supp}(u)| + |\text{supp}(v)| \leq 2s$, then:
$$|\langle Au, Av \rangle - \langle u, v \rangle| \leq \delta_{2s} \|u\|_2 \|v\|_2$$

*Proof of Lemma.* By polarization: $\langle Au, Av \rangle = \frac{1}{4}[\|A(u+v)\|_2^2 - \|A(u-v)\|_2^2]$. Since $u+v$ and $u-v$ both have support contained in $\text{supp}(u) \cup \text{supp}(v)$ with size $\leq 2s$:
$$\|A(u \pm v)\|_2^2 \leq (1+\delta)\|u \pm v\|_2^2, \quad \|A(u \pm v)\|_2^2 \geq (1-\delta)\|u \pm v\|_2^2$$

Since $u, v$ have disjoint supports, $\langle u, v \rangle = 0$ and $\|u \pm v\|_2^2 = \|u\|_2^2 + \|v\|_2^2$. Thus:
$$|\langle Au, Av \rangle| = \frac{1}{4}|\|A(u+v)\|_2^2 - \|A(u-v)\|_2^2|$$
$$\leq \frac{1}{4}[(1+\delta) - (1-\delta)](\|u\|_2^2 + \|v\|_2^2) = \frac{\delta}{2}(\|u\|_2^2 + \|v\|_2^2)$$
$$\leq \delta \|u\|_2 \|v\|_2$$

where the last step uses AM-GM: $\frac{1}{2}(a^2 + b^2) \geq ab$ for $a, b \geq 0$. But wait, we need $\leq$ not $\geq$. Actually: $\frac{\delta}{2}(\|u\|_2^2 + \|v\|_2^2) \leq \delta \|u\|_2\|v\|_2$ is WRONG in general. The correct bound is $\frac{\delta}{2}(\|u\|_2^2 + \|v\|_2^2)$.

Actually, let me reconsider. We need a sharper approach. For the cross-terms in (4), we don't need the ROP bound per se. Let me use a different decomposition.

**Step 7 (revised): Direct bound on cross-terms.**

For $j \geq 2$, since $T_j$ and $T_{01}$ are disjoint and $|T_j \cup T_{01}| \leq s + 2s = 3s$:

We actually need $|T_j \cup T_0| \leq 2s$ or use a different pairing. Let me refine.

Consider instead: pair $T_0$ with $T_1$. We have $|T_0 \cup T_1| \leq 2s$, so RIP applies to $h_{T_0 \cup T_1}$.

From $Ah = 0$: $Ah_{T_0} + Ah_{T_1} + \sum_{j \geq 2} Ah_{T_j} = 0$.

Take inner product with $Ah_{T_0 \cup T_1}$:
$$\langle Ah_{T_{01}}, Ah_{T_{01}} \rangle = -\sum_{j \geq 2} \langle Ah_{T_{01}}, Ah_{T_j} \rangle$$

For the RHS, use Cauchy-Schwarz:
$$|\langle Ah_{T_{01}}, Ah_{T_j} \rangle| \leq \|Ah_{T_{01}}\|_2 \|Ah_{T_j}\|_2$$

By RIP (since $|T_j| \leq s \leq 2s$):
$$\|Ah_{T_j}\|_2 \leq \sqrt{1+\delta} \|h_{T_j}\|_2$$

So:
$$\|Ah_{T_{01}}\|_2^2 \leq \|Ah_{T_{01}}\|_2 \cdot \sqrt{1+\delta} \sum_{j \geq 2} \|h_{T_j}\|_2$$

Dividing by $\|Ah_{T_{01}}\|_2$ (assuming it's nonzero; if zero then $h_{T_{01}} = 0$ by RIP and we can proceed directly):

$$\|Ah_{T_{01}}\|_2 \leq \sqrt{1+\delta} \sum_{j \geq 2} \|h_{T_j}\|_2 \tag{6}$$

**Step 8: Combining bounds.**

From (5): $(1-\delta)\|h_{T_{01}}\|_2^2 \leq \|Ah_{T_{01}}\|_2^2$

From (6) squared: $\|Ah_{T_{01}}\|_2^2 \leq (1+\delta)\left(\sum_{j \geq 2}\|h_{T_j}\|_2\right)^2$

Therefore:
$$(1-\delta)\|h_{T_{01}}\|_2^2 \leq (1+\delta)\left(\sum_{j \geq 2}\|h_{T_j}\|_2\right)^2$$

Using (3): $\sum_{j \geq 2}\|h_{T_j}\|_2 \leq \frac{1}{\sqrt{s}}\|h_{T_0^c}\|_1$

And for the exactly sparse case, using cone constraint (1): $\|h_{T_0^c}\|_1 \leq \|h_{T_0}\|_1 \leq \sqrt{s}\|h_{T_0}\|_2$

So: $\sum_{j \geq 2}\|h_{T_j}\|_2 \leq \|h_{T_0}\|_2$

Therefore:
$$(1-\delta)\|h_{T_{01}}\|_2^2 \leq (1+\delta)\|h_{T_0}\|_2^2$$

Since $\|h_{T_{01}}\|_2^2 = \|h_{T_0}\|_2^2 + \|h_{T_1}\|_2^2$:

$$(1-\delta)(\|h_{T_0}\|_2^2 + \|h_{T_1}\|_2^2) \leq (1+\delta)\|h_{T_0}\|_2^2$$

$$(1-\delta)\|h_{T_1}\|_2^2 \leq [(1+\delta) - (1-\delta)]\|h_{T_0}\|_2^2 = 2\delta\|h_{T_0}\|_2^2$$

$$\|h_{T_1}\|_2^2 \leq \frac{2\delta}{1-\delta}\|h_{T_0}\|_2^2 \tag{7}$$

**Step 9: Use the cone constraint more carefully.**

From (1): $\|h_{T_1}\|_1 + \sum_{j \geq 2}\|h_{T_j}\|_1 = \|h_{T_0^c}\|_1 \leq \|h_{T_0}\|_1$

But we also need to go back and use $Ah = 0$ more effectively. Let me use the tube constraint differently.

From $Ah = 0$ and RIP on $T_{01}$:
$$0 = \|Ah\|_2^2 = \|Ah_{T_{01}} + \sum_{j \geq 2} Ah_{T_j}\|_2^2$$

This means:
$$\|Ah_{T_{01}}\|_2^2 = -2\sum_{j \geq 2}\langle Ah_{T_{01}}, Ah_{T_j}\rangle - \|\sum_{j \geq 2} Ah_{T_j}\|_2^2$$

This isn't leading to a cleaner bound. Let me go back to the approach of Step 7-8 but be more careful.

**Step 9 (revised): Final contradiction.**

We need to show $h = 0$. From (7), if we also had $\|h_{T_0}\|_2 = 0$, then $\|h_{T_1}\|_2 = 0$, and by (2), $\|h_{T_j}\|_2 = 0$ for all $j \geq 2$, giving $h = 0$.

So suppose $h_{T_0} \neq 0$. We established:
$$(1-\delta)\|h_{T_{01}}\|_2^2 \leq (1+\delta)\|h_{T_0}\|_2^2$$

But we can get a tighter bound. Going back to $Ah = 0$:

$$Ah_{T_{01}} = -\sum_{j \geq 2} Ah_{T_j}$$

Using a sharper analysis: apply RIP to $h_{T_0 \cup T_1}$ directly.

$$\|Ah_{T_0} + Ah_{T_1}\|_2^2 = \|Ah_{T_{01}}\|_2^2 \geq (1-\delta)\|h_{T_{01}}\|_2^2$$

And:
$$\|Ah_{T_{01}}\|_2 = \|\sum_{j \geq 2} Ah_{T_j}\| \leq \sum_{j \geq 2} \|Ah_{T_j}\|_2 \leq \sqrt{1+\delta}\sum_{j \geq 2}\|h_{T_j}\|_2$$

Now, for the exactly sparse case ($x^*$ is $s$-sparse), using (3):
$$\sum_{j \geq 2}\|h_{T_j}\|_2 \leq \frac{1}{\sqrt{s}}\|h_{T_0^c}\|_1 \leq \frac{1}{\sqrt{s}} \cdot \|h_{T_0}\|_1 \leq \|h_{T_0}\|_2$$

So:
$$\sqrt{(1-\delta)} \|h_{T_{01}}\|_2 \leq \|Ah_{T_{01}}\|_2 \leq \sqrt{1+\delta}\|h_{T_0}\|_2$$

Wait, $(1-\delta)\|h_{T_{01}}\|_2^2 \leq \|Ah_{T_{01}}\|_2^2$ implies $\sqrt{1-\delta}\|h_{T_{01}}\|_2 \leq \|Ah_{T_{01}}\|_2$.

And $\|Ah_{T_{01}}\|_2 \leq \sqrt{1+\delta}\|h_{T_0}\|_2$.

So: $\sqrt{1-\delta}\sqrt{\|h_{T_0}\|_2^2 + \|h_{T_1}\|_2^2} \leq \sqrt{1+\delta}\|h_{T_0}\|_2$

Squaring: $(1-\delta)(\|h_{T_0}\|_2^2 + \|h_{T_1}\|_2^2) \leq (1+\delta)\|h_{T_0}\|_2^2$

So: $(1-\delta)\|h_{T_1}\|_2^2 \leq 2\delta\|h_{T_0}\|_2^2$

Let $\alpha = \|h_{T_1}\|_2 / \|h_{T_0}\|_2$. Then $\alpha^2 \leq \frac{2\delta}{1-\delta}$.

Now, we also need to use $Ah = 0$ in a different way. Take the inner product of $Ah_{T_{01}} = -\sum_{j \geq 2} Ah_{T_j}$ with $Ah_{T_0}$:

$$\langle Ah_{T_0}, Ah_{T_0}\rangle + \langle Ah_{T_0}, Ah_{T_1}\rangle = -\sum_{j \geq 2}\langle Ah_{T_0}, Ah_{T_j}\rangle$$

By RIP: $\|Ah_{T_0}\|_2^2 \geq (1-\delta)\|h_{T_0}\|_2^2$.
By ROP: $|\langle Ah_{T_0}, Ah_{T_1}\rangle| \leq \delta\|h_{T_0}\|_2\|h_{T_1}\|_2$ (since $T_0, T_1$ are disjoint, $|T_0 \cup T_1| \leq 2s$, so we can use the ROP bound we derived: $\frac{\delta}{2}(\|u\|^2 + \|v\|^2)$, but actually let me use the tighter version).

Actually, the ROP bound from polarization gives: $|\langle Au, Av\rangle| \leq \frac{\delta}{2}(\|u\|_2^2 + \|v\|_2^2)$ for disjointly supported $u, v$ with $|\text{supp}(u) \cup \text{supp}(v)| \leq 2s$.

So: $(1-\delta)\|h_{T_0}\|_2^2 - \frac{\delta}{2}(\|h_{T_0}\|_2^2 + \|h_{T_1}\|_2^2) \leq \sum_{j \geq 2}\frac{\delta}{2}(\|h_{T_0}\|_2^2 + \|h_{T_j}\|_2^2)$

This is getting complicated. Let me simplify and use the cleaner approach that directly leads to the result.

**Step 9 (clean version): Completing the proof for the exactly sparse case.**

We have shown:
1. $Ah = 0$ and $h \in \ker(A)$
2. Cone constraint: $\|h_{T_0^c}\|_1 \leq \|h_{T_0}\|_1$ 
3. $(1-\delta)\|h_{T_{01}}\|_2^2 \leq (1+\delta)\|h_{T_0}\|_2^2$

From (3): $\|h_{T_0}\|_2^2 + \|h_{T_1}\|_2^2 \leq \frac{1+\delta}{1-\delta}\|h_{T_0}\|_2^2$

Now we need another relation. From $Ah = 0$, take inner product with $Ah_{T_0}$:
$$\langle Ah_{T_0}, Ah_{T_0}\rangle + \langle Ah_{T_0}, Ah_{T_1}\rangle + \sum_{j \geq 2}\langle Ah_{T_0}, Ah_{T_j}\rangle = 0$$

Actually, let me use the cleanest known proof strategy (Candes 2008). 

**Clean approach**: We want to bound $\|h_{T_{01}}\|_2$ and then show the tail is also small, giving $\|h\|_2 = 0$.

From $Ah = 0$ and the triangle inequality:
$$\|Ah_{T_{01}}\|_2 = \|\sum_{j \geq 2} Ah_{T_j}\|_2 \leq \sum_{j \geq 2}\|Ah_{T_j}\|_2 \leq \sqrt{1+\delta}\sum_{j \geq 2}\|h_{T_j}\|_2$$

From (3) in the exactly sparse case: $\sum_{j \geq 2}\|h_{T_j}\|_2 \leq \|h_{T_0}\|_2$.

From RIP lower bound: $\|Ah_{T_{01}}\|_2 \geq \sqrt{1-\delta}\|h_{T_{01}}\|_2$.

So: $\sqrt{1-\delta}\|h_{T_{01}}\|_2 \leq \sqrt{1+\delta}\|h_{T_0}\|_2$

Let $\rho = \sqrt{\frac{1+\delta}{1-\delta}}$. Then $\|h_{T_{01}}\|_2 \leq \rho\|h_{T_0}\|_2$.

Since $\|h_{T_{01}}\|_2^2 = \|h_{T_0}\|_2^2 + \|h_{T_1}\|_2^2$:
$$\|h_{T_1}\|_2^2 \leq (\rho^2 - 1)\|h_{T_0}\|_2^2 = \frac{2\delta}{1-\delta}\|h_{T_0}\|_2^2$$

Now, $\|h\|_2^2 = \|h_{T_0}\|_2^2 + \|h_{T_1}\|_2^2 + \sum_{j \geq 2}\|h_{T_j}\|_2^2$. 

For the tail: $\sum_{j \geq 2}\|h_{T_j}\|_2^2 \leq (\sum_{j \geq 2}\|h_{T_j}\|_2)^2$ is FALSE. We need: $\sum_{j \geq 2}\|h_{T_j}\|_2 \leq \|h_{T_0}\|_2$, but we need the square sum.

Actually, we can bound: $\|h\|_2 \leq \|h_{T_{01}}\|_2 + \sum_{j \geq 2}\|h_{T_j}\|_2 \leq \rho\|h_{T_0}\|_2 + \|h_{T_0}\|_2 = (1+\rho)\|h_{T_0}\|_2$.

But this doesn't give $h = 0$ by itself. We need to use $Ah = 0$ and the cone constraint together more tightly.

**Step 10: The key inequality.**

Let me use a different strategy. From $Ah = 0$:
$$0 = \|Ah\|_2^2$$

We can write $h = h_{T_{01}} + h_{T_{01}^c}$ where $T_{01}^c = \bigcup_{j \geq 2} T_j$.

$$0 = \|Ah_{T_{01}} + Ah_{T_{01}^c}\|_2^2 = \|Ah_{T_{01}}\|_2^2 + 2\langle Ah_{T_{01}}, Ah_{T_{01}^c}\rangle + \|Ah_{T_{01}^c}\|_2^2$$

So: $\|Ah_{T_{01}}\|_2^2 \leq -2\langle Ah_{T_{01}}, Ah_{T_{01}^c}\rangle$

By Cauchy-Schwarz: $\|Ah_{T_{01}}\|_2^2 \leq 2\|Ah_{T_{01}}\|_2\|Ah_{T_{01}^c}\|_2$

If $Ah_{T_{01}} \neq 0$: $\|Ah_{T_{01}}\|_2 \leq 2\|Ah_{T_{01}^c}\|_2$.

But $T_{01}^c$ need not have bounded support, so we can't directly apply RIP to $h_{T_{01}^c}$.

However: $\|Ah_{T_{01}^c}\|_2 \leq \sum_{j \geq 2}\|Ah_{T_j}\|_2 \leq \sqrt{1+\delta}\sum_{j \geq 2}\|h_{T_j}\|_2$.

OK, this is still giving the same bound. Let me try the definitive approach.

**Step 10 (definitive): Using Candes' 2008 approach properly.**

The key insight is that we need to establish the **Robust Null Space Property**: for $h \in \ker(A)$, $\|h_S\|_2 \leq C\frac{\|h_{S^c}\|_1}{\sqrt{s}}$ for all $|S| \leq s$.

From the analysis above, for any $|S| \leq s$, decompose $S^c$ into blocks $T_1, T_2, \ldots$ of size $s$:

$$\sqrt{1-\delta}\|h_{S \cup T_1}\|_2 \leq \sqrt{1+\delta} \sum_{j \geq 2}\|h_{T_j}\|_2 \leq \sqrt{1+\delta} \cdot \frac{1}{\sqrt{s}}\|h_{S^c}\|_1$$

So $\|h_S\|_2 \leq \|h_{S \cup T_1}\|_2 \leq \frac{\sqrt{1+\delta}}{\sqrt{1-\delta}} \cdot \frac{\|h_{S^c}\|_1}{\sqrt{s}}$.

For the exactly sparse case with $S = T_0 = \text{supp}(x^*)$, using cone constraint $\|h_{T_0^c}\|_1 \leq \|h_{T_0}\|_1 \leq \sqrt{s}\|h_{T_0}\|_2$:

$$\|h_{T_0}\|_2 \leq \rho \cdot \|h_{T_0}\|_2$$

where $\rho = \sqrt{\frac{1+\delta}{1-\delta}}$.

For this to force $h_{T_0} = 0$, we need $\rho < 1$, i.e., $\frac{1+\delta}{1-\delta} < 1$, i.e., $\delta < 0$. But $\delta \geq 0$!

This means the simple Cauchy-Schwarz bound is too loose. We need the more refined analysis.

**I acknowledge this route has hit an obstacle at this point — the naive Cauchy-Schwarz approach on cross-terms is too loose to close the argument. The correct proof requires a more refined treatment of the cross-terms. See Route 3 for the correct treatment.**

## Route Failure Report
- Route: Block decomposition with naive Cauchy-Schwarz cross-term bound
- Failed at: Step 10 — the cross-term bound via Cauchy-Schwarz is too loose
- Obstacle: The bound $\sqrt{1-\delta}\|h_{T_{01}}\|_2 \leq \sqrt{1+\delta}\|h_{T_0}\|_2$ requires $\rho = \sqrt{(1+\delta)/(1-\delta)} < 1$ to close, which is impossible for $\delta > 0$. A more refined treatment of the cross-terms using ROP directly (not via Cauchy-Schwarz on $\|Ah\|$) is needed.
