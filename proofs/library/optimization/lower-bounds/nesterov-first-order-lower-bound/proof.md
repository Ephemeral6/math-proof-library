# Proof: Nesterov's First-Order Lower Bound

**Theorem.** For any integer $k$ with $1 \le k \le (d-1)/2$ and any first-order method generating iterates $x_t \in x_0 + \operatorname{span}\{\nabla f(x_0), \nabla f(x_1), \ldots, \nabla f(x_{t-1})\}$, there exists an $L$-smooth convex function $f: \mathbb{R}^d \to \mathbb{R}$ such that

$$f(x_k) - f(x^*) \ge \frac{3L\|x_0 - x^*\|^2}{32(k+1)^2}.$$

---

## Step 1: Construct the worst-case function

Define the tridiagonal matrix $A_k \in \mathbb{R}^{d \times d}$ with nonzero entries only in the leading $(2k+1) \times (2k+1)$ block:

$$(A_k)_{ij} = \begin{cases} 2 & \text{if } i = j, \\ -1 & \text{if } |i-j| = 1, \\ 0 & \text{otherwise}, \end{cases} \quad \text{for } 1 \le i,j \le 2k+1.$$

Define the worst-case function:

$$f_k(x) = \frac{L}{4}\left(\frac{1}{2}x^T A_k x - e_1^T x\right)$$

where $e_1 = (1, 0, \ldots, 0)^T$.

**Smoothness and convexity**: The Hessian is $\nabla^2 f_k = \frac{L}{4}A_k$. The eigenvalues of the $(2k+1)$-dimensional tridiagonal block are $\mu_j = 2 - 2\cos\frac{\pi j}{2k+2}$ for $j = 1, \ldots, 2k+1$, satisfying $0 < \mu_j < 4$. Therefore $0 \prec \nabla^2 f_k \prec L \cdot I$, so $f_k$ is $L$-smooth and strictly convex.

## Step 2: Compute the optimal solution

Setting $\nabla f_k(x^*) = \frac{L}{4}(A_k x^* - e_1) = 0$ gives $A_k x^* = e_1$.

The solution is $x_i^* = 1 - \frac{i}{2k+2}$ for $i = 1, \ldots, 2k+1$ and $x_i^* = 0$ for $i > 2k+1$.

**Verification** (with $q = 2k+2$):
- $i = 1$: $2(1-\frac{1}{q}) - (1-\frac{2}{q}) = 1$. ✓
- $2 \le i \le 2k$: $-(1-\frac{i-1}{q}) + 2(1-\frac{i}{q}) - (1-\frac{i+1}{q}) = 0$. ✓
- $i = 2k+1$: $-(1-\frac{2k}{q}) + 2(1-\frac{2k+1}{q}) = 0$. ✓

## Step 3: Compute auxiliary quantities

**Optimal value**: Since $A_k x^* = e_1$:

$$f_k(x^*) = \frac{L}{4}\left(\frac{1}{2}(x^*)^T e_1 - x_1^*\right) = \frac{L}{4}\left(\frac{1}{2} \cdot \frac{q-1}{q} - \frac{q-1}{q}\right) = -\frac{L(q-1)}{8q}.$$

**Distance to optimum**: With $x_0 = 0$:

$$\|x_0 - x^*\|^2 = \sum_{i=1}^{2k+1}\left(\frac{q-i}{q}\right)^2 = \frac{1}{q^2}\sum_{j=1}^{q-1}j^2 = \frac{(q-1)(2q-1)}{6q}.$$

## Step 4: Subspace restriction via induction

**Claim**: For any first-order method starting at $x_0 = 0$, we have $x_t \in \operatorname{span}\{e_1, \ldots, e_t\}$ for all $t \ge 1$.

*Proof by induction*:
- **Base**: $\nabla f_k(0) = -\frac{L}{4}e_1 \in \operatorname{span}\{e_1\}$, so $x_1 \in \operatorname{span}\{e_1\}$.
- **Inductive step**: If $x_s \in \operatorname{span}\{e_1, \ldots, e_s\}$ for $s < t$, then $\nabla f_k(x_s) = \frac{L}{4}(A_k x_s - e_1) \in \operatorname{span}\{e_1, \ldots, e_{s+1}\}$ by the tridiagonal structure of $A_k$ (multiplying by $A_k$ extends the support by at most one coordinate). Therefore $x_t \in x_0 + \operatorname{span}\{\nabla f_k(x_0), \ldots, \nabla f_k(x_{t-1})\} \subseteq \operatorname{span}\{e_1, \ldots, e_t\}$. ✓

## Step 5: Lower bound via Schur complement

Since $x_k \in \operatorname{span}\{e_1, \ldots, e_k\}$, the function gap satisfies:

$$f_k(x_k) - f_k(x^*) \ge \min_{\substack{x \in \mathbb{R}^d \\ x_i = 0, i > k}} \frac{L}{8}(x - x^*)^T A_k(x - x^*)$$

using the quadratic identity $f_k(x) - f_k(x^*) = \frac{L}{8}\|x - x^*\|_{A_k}^2$.

Partition coordinates into $\{1, \ldots, k\}$ and $\{k+1, \ldots, 2k+1\}$. Write $x - x^* = (u, v)$ where $v_i = -x_{k+i}^* = -\frac{k+2-i}{q}$ is fixed and $u$ is free. Block-partition:

$$A_k = \begin{pmatrix} A_{11} & A_{12} \\ A_{12}^T & A_{22} \end{pmatrix}$$

where $A_{11} = T_k$, $A_{22} = T_{k+1}$ are tridiagonal matrices of sizes $k$ and $k+1$, and $A_{12}$ has a single nonzero entry $(A_{12})_{k,1} = -1$.

Minimizing over $u$ gives the Schur complement:

$$\min_u (u,v)^T A_k (u,v) = v^T S v, \quad S = A_{22} - A_{12}^T A_{11}^{-1} A_{12}.$$

Using $(T_k^{-1})_{kk} = \frac{k}{k+1}$ (from the well-known inverse formula $(T_k^{-1})_{ij} = \frac{\min(i,j)(k+1-\max(i,j))}{k+1}$):

$$S = T_{k+1} - \frac{k}{k+1}e_1 e_1^T.$$

**Computing $v^T S v$**: Using $w^T T_m w = \sum_{i=1}^{m-1}(w_i - w_{i+1})^2 + w_1^2 + w_m^2$, with $v_i = \frac{k+2-i}{q}$:

- $v_i - v_{i+1} = \frac{1}{q}$, so $\sum_{i=1}^k(v_i - v_{i+1})^2 = \frac{k}{q^2}$
- $v_1 = \frac{k+1}{q}$, $v_{k+1} = \frac{1}{q}$

$$v^T T_{k+1} v = \frac{k + (k+1)^2 + 1}{q^2} = \frac{(k+1)(k+2)}{q^2}$$

$$v^T S v = \frac{(k+1)(k+2) - k(k+1)}{q^2} = \frac{2(k+1)}{4(k+1)^2} = \frac{1}{2(k+1)}.$$

Therefore:

$$\min_{\substack{x \in \mathbb{R}^d \\ x_i = 0, i > k}} f_k(x) - f_k(x^*) = \frac{L}{8} \cdot \frac{1}{2(k+1)} = \frac{L}{16(k+1)}.$$

## Step 6: Final inequality

We show $\frac{L}{16(k+1)} \ge \frac{3L\|x^*\|^2}{32(k+1)^2}$, equivalently $\|x^*\|^2 \le \frac{2(k+1)}{3}$.

From Step 3: $\|x^*\|^2 = \frac{(2k+1)(4k+3)}{12(k+1)}$.

Expanding: $(2k+1)(4k+3) = 8k^2 + 10k + 3$ and $8(k+1)^2 = 8k^2 + 16k + 8$.

Since $8k^2 + 10k + 3 \le 8k^2 + 16k + 8$ (equivalently $6k + 5 \ge 0$), the inequality holds. ✓

## Conclusion

For any first-order method starting at $x_0 = 0$:

$$f_k(x_k) - f_k(x^*) \ge \frac{L}{16(k+1)} \ge \frac{3L\|x_0 - x^*\|^2}{32(k+1)^2}.$$

The case $x_0 \ne 0$ follows by translation invariance. This establishes the $\Omega(1/k^2)$ lower bound, proving that Nesterov's accelerated gradient descent achieves the optimal rate for first-order methods on $L$-smooth convex functions.

$\blacksquare$
