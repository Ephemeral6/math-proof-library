# Proof Route 2: Null Space Property via RIP

**Route**: Show RIP ⟹ Null Space Property ⟹ Exact Recovery

## Proof

**Setting.** Let $A \in \mathbb{R}^{m \times n}$ satisfy RIP of order $2s$ with constant $\delta := \delta_{2s} < \sqrt{2} - 1$.

**Step 1: Null Space Property (NSP).**

**Definition.** $A$ satisfies the Null Space Property of order $s$ if for all $h \in \ker(A) \setminus \{0\}$ and all sets $S \subset \{1,...,n\}$ with $|S| \leq s$:
$$\|h_S\|_1 < \|h_{S^c}\|_1$$

**Step 2: NSP implies exact sparse recovery.**

*Claim.* If $A$ satisfies NSP of order $s$, then every $s$-sparse vector $x^*$ is the unique solution of $\min\|x\|_1$ s.t. $Ax = Ax^*$.

*Proof.* Let $\hat{x}$ be any feasible point with $A\hat{x} = Ax^*$ and $\hat{x} \neq x^*$. Let $h = \hat{x} - x^*$, so $h \in \ker(A)\setminus\{0\}$ and $S = \text{supp}(x^*)$ with $|S| \leq s$.

$$\|\hat{x}\|_1 = \|x^* + h\|_1 = \|x^*_S + h_S\|_1 + \|h_{S^c}\|_1 \geq \|x^*_S\|_1 - \|h_S\|_1 + \|h_{S^c}\|_1$$

By NSP: $\|h_{S^c}\|_1 > \|h_S\|_1$, so:
$$\|\hat{x}\|_1 > \|x^*_S\|_1 = \|x^*\|_1$$

Therefore $x^*$ is the unique minimizer. □

**Step 3: RIP implies NSP — Setup.**

We need to show: for all $h \in \ker(A)\setminus\{0\}$ and all $|S| \leq s$, $\|h_S\|_1 < \|h_{S^c}\|_1$.

Equivalently, we show the stronger **Robust NSP**: there exists $0 < \rho < 1$ and $\tau > 0$ such that for all $h \in \ker(A)$:
$$\|h_S\|_2 \leq \frac{\rho}{\sqrt{s}}\|h_{S^c}\|_1 + \tau\|Ah\|_2$$

Since $Ah = 0$ for $h \in \ker(A)$, this reduces to $\|h_S\|_2 \leq \frac{\rho}{\sqrt{s}}\|h_{S^c}\|_1$ with $\rho < 1$.

By Cauchy-Schwarz: $\|h_S\|_1 \leq \sqrt{s}\|h_S\|_2 \leq \rho\|h_{S^c}\|_1$, which gives NSP (since $\rho < 1$).

**Step 4: Block decomposition for RIP ⟹ Robust NSP.**

Fix $h \in \ker(A)$ and $S$ with $|S| \leq s$. Decompose $S^c$ into blocks:
- $T_1$: indices of the $s$ largest entries of $h_{S^c}$
- $T_2$: next $s$ largest, etc.

Set $T_0 = S$ (note: $h_{T_0}$ is not necessarily the "best" block, but $|T_0| \leq s$).

From sorting (same as Route 1, Step 4):
$$\sum_{j \geq 2}\|h_{T_j}\|_2 \leq \frac{1}{\sqrt{s}}\|h_{S^c}\|_1 \tag{*}$$

From $Ah = 0$: $Ah_{T_0 \cup T_1} = -\sum_{j \geq 2} Ah_{T_j}$.

**Step 5: Core RIP estimate.**

Since $|T_0 \cup T_1| \leq 2s$, by RIP:
$$\|Ah_{T_0 \cup T_1}\|_2 \geq \sqrt{1 - \delta}\|h_{T_0 \cup T_1}\|_2$$

Since $|T_j| \leq s \leq 2s$ for each $j \geq 2$:
$$\|\sum_{j \geq 2}Ah_{T_j}\|_2 \leq \sum_{j \geq 2}\|Ah_{T_j}\|_2 \leq \sqrt{1+\delta}\sum_{j \geq 2}\|h_{T_j}\|_2$$

Combining: $\sqrt{1-\delta}\|h_{T_0 \cup T_1}\|_2 \leq \sqrt{1+\delta}\sum_{j \geq 2}\|h_{T_j}\|_2$

Using (*): $\sqrt{1-\delta}\|h_{T_0 \cup T_1}\|_2 \leq \sqrt{1+\delta}\cdot\frac{1}{\sqrt{s}}\|h_{S^c}\|_1$

Since $\|h_S\|_2 = \|h_{T_0}\|_2 \leq \|h_{T_0 \cup T_1}\|_2$:

$$\|h_S\|_2 \leq \frac{\sqrt{1+\delta}}{\sqrt{1-\delta}} \cdot \frac{1}{\sqrt{s}}\|h_{S^c}\|_1 = \rho \cdot \frac{\|h_{S^c}\|_1}{\sqrt{s}}$$

where $\rho = \sqrt{\frac{1+\delta}{1-\delta}}$.

**Step 6: Check the condition.**

For NSP we need $\rho < 1$, i.e., $\frac{1+\delta}{1-\delta} < 1$, i.e., $\delta < 0$.

**This fails!** For any $\delta > 0$, we have $\rho > 1$, and this approach cannot establish NSP.

The same obstacle as Route 1: the triangle inequality + Cauchy-Schwarz on the tail is too loose.

## Route Failure Report
- Route: NSP via RIP with Cauchy-Schwarz bounds
- Failed at: Step 6 — the ratio ρ = √((1+δ)/(1-δ)) > 1 for all δ > 0
- Obstacle: Same fundamental issue as Route 1. The Cauchy-Schwarz bounding of cross-terms is too loose. A more refined inner-product based argument (using ROP to get cancellation, not just upper bounds) is needed. This is why the condition δ_{2s} < √2 - 1 specifically appears — it comes from balancing the RIP and ROP terms.
