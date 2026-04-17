# Proof Route 4: Dual Certificate / KKT Approach

**Route**: Construct a dual certificate to verify optimality of x* for the ℓ1 minimization.

## Proof Attempt

**Setting.** Let $A \in \mathbb{R}^{m \times n}$ satisfy RIP of order $2s$ with $\delta_{2s} < \sqrt{2}-1$. Let $x^*$ be $s$-sparse with support $S = \text{supp}(x^*)$.

**Step 1: KKT conditions for ℓ₁ minimization.**

The problem $\min\|x\|_1$ s.t. $Ax = b$ has $x^*$ as the unique solution if and only if there exists a dual vector $\nu \in \mathbb{R}^m$ such that:
- $A^T\nu = \text{sign}(x^*)$ on $S$ (i.e., $(A^T\nu)_i = \text{sign}(x^*_i)$ for $i \in S$)
- $|(A^T\nu)_i| < 1$ for $i \notin S$ (strict inequality for uniqueness)

where $\text{sign}(x^*_i) \in \{-1, +1\}$ for $i \in S$.

**Step 2: Construct the dual certificate.**

Define $\nu = A(A_S^T A_S)^{-1} \text{sign}(x^*_S)$, where $A_S$ denotes the columns of $A$ indexed by $S$.

First, we need $(A_S^T A_S)$ to be invertible. By RIP of order $s \leq 2s$:
$$(1-\delta)\|z\|_2^2 \leq \|A_S z\|_2^2 = z^T A_S^T A_S z \leq (1+\delta)\|z\|_2^2$$

for all $z \in \mathbb{R}^{|S|}$. This means $A_S^T A_S$ has eigenvalues in $[1-\delta, 1+\delta]$, hence invertible. ✓

**Step 3: Verify the on-support condition.**

For $i \in S$:
$$(A^T\nu)_S = A_S^T A_S (A_S^T A_S)^{-1}\text{sign}(x^*_S) = \text{sign}(x^*_S) \quad \checkmark$$

**Step 4: Verify the off-support condition.**

For $j \notin S$, let $e_j$ be the $j$-th standard basis vector restricted to $S^c$:
$$(A^T\nu)_j = a_j^T A_S(A_S^T A_S)^{-1}\text{sign}(x^*_S)$$

where $a_j$ is the $j$-th column of $A$.

We need $|(A^T\nu)_j| < 1$ for all $j \notin S$.

**Step 5: Bound the off-support entries using RIP.**

Let $w = (A_S^T A_S)^{-1}\text{sign}(x^*_S) \in \mathbb{R}^{|S|}$. Then $(A^T\nu)_j = a_j^T A_S w = \langle Ae_j', Aw'\rangle$ where $e_j'$ is the $j$-th coordinate vector and $w'$ has $w$ on $S$ and $0$ elsewhere.

Wait, more precisely: $a_j^T A_S w = \sum_{i \in S} w_i (a_j^T a_i)$. This is the inner product of column $j$ with $A_S w$.

By the ROP: for $j \notin S$, $e_j$ and $w'$ (supported on $S$) are disjointly supported with $|\{j\} \cup S| \leq s+1 \leq 2s$ (for $s \geq 1$).

So: $|a_j^T A_S w - e_j^T w'| = |a_j^T A_S w - 0| = |a_j^T A_S w| = |\langle Ae_j, Aw'\rangle|$

But by ROP: $|\langle Ae_j, Aw'\rangle - \langle e_j, w'\rangle| \leq \delta_{s+1}\|e_j\|_2\|w'\|_2$. Since $\langle e_j, w'\rangle = 0$ (disjoint supports):

$$|a_j^T A_S w| \leq \delta_{s+1}\|w'\|_2 \leq \delta_{2s}\|w\|_2$$

Now bound $\|w\|_2 = \|(A_S^T A_S)^{-1}\text{sign}(x^*_S)\|_2 \leq \|(A_S^T A_S)^{-1}\|\cdot\|\text{sign}(x^*_S)\|_2 = \frac{\sqrt{s}}{1-\delta}$

(using that the smallest eigenvalue of $A_S^TA_S$ is $\geq 1-\delta$, so $\|(A_S^TA_S)^{-1}\| \leq \frac{1}{1-\delta}$, and $\|\text{sign}(x^*_S)\|_2 = \sqrt{|S|} \leq \sqrt{s}$).

Therefore:
$$|(A^T\nu)_j| \leq \frac{\delta\sqrt{s}}{1-\delta}$$

For the off-support condition, we need $\frac{\delta\sqrt{s}}{1-\delta} < 1$, i.e., $\delta\sqrt{s} < 1-\delta$, i.e., $\delta < \frac{1}{1+\sqrt{s}}$.

**Step 6: Problem with this bound.**

The condition $\delta < \frac{1}{1+\sqrt{s}}$ depends on $s$ and becomes very restrictive for large $s$. This is NOT the condition $\delta_{2s} < \sqrt{2}-1$ that we want.

The dual certificate approach with the simple "pseudoinverse" certificate $\nu = A_S(A_S^TA_S)^{-1}\text{sign}(x^*_S)$ gives a bound that depends on $s$, while the theorem requires a bound independent of $s$ (only depending on $\delta_{2s}$).

More sophisticated dual certificate constructions (e.g., the "golfing scheme" of Gross 2011 or the "iterative thresholding" approach) can achieve $s$-independent bounds, but they are significantly more complex and typically used for random measurement matrices, not the deterministic RIP setting.

## Route Failure Report
- Route: Direct dual certificate construction
- Failed at: Step 6 — the pseudoinverse dual certificate gives an $s$-dependent bound
- Obstacle: The simple dual certificate $\nu = A_S(A_S^TA_S)^{-1}\text{sign}(x_S^*)$ requires $\delta_{2s} < \frac{1}{1+\sqrt{s}}$, which is much more restrictive than $\delta_{2s} < \sqrt{2}-1$ and depends on $s$. The correct proof of the RIP recovery guarantee uses the primal analysis (block decomposition + RIP/ROP) rather than the dual certificate approach. The dual certificate approach is better suited for random measurement matrices with incoherence conditions.
