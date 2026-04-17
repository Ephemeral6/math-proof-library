## Proof

**Route**: Chebyshev Polynomial / Conjugate Gradient Optimality

**Theorem.** For any $k \le (d-1)/2$ and any first-order method, there exists an $L$-smooth convex function such that $f(x_k) - f(x^*) \ge \frac{3L\|x_0 - x^*\|^2}{32(k+1)^2}$.

---

### Step 1: Reduction to quadratic optimization over Krylov subspaces

Consider the class of $L$-smooth convex quadratics $f(x) = \frac{1}{2}x^T H x - b^T x$ where $0 \preceq H \preceq L \cdot I$.

A first-order method starting from $x_0 = 0$ generates iterates in the Krylov subspace:

$$x_k \in \mathcal{K}_k(H, b) := \operatorname{span}\{b, Hb, H^2 b, \ldots, H^{k-1}b\}.$$

This is because $\nabla f(x_0) = -b$, and by induction, if $x_t \in \mathcal{K}_t(H,b)$, then $\nabla f(x_t) = Hx_t - b \in \mathcal{K}_{t+1}(H,b)$.

Any $x_k \in \mathcal{K}_k(H, b)$ can be written as $x_k = p_k(H)b$ for some polynomial $p_k$ of degree $\le k-1$.

### Step 2: Express the function gap in terms of polynomials

The optimal solution is $x^* = H^{-1}b$ (assuming $H$ is positive definite). The error is:

$$x_k - x^* = p_k(H)b - H^{-1}b = (p_k(H)H - I)H^{-1}b = -r_k(H)H^{-1}b$$

where $r_k(\lambda) = 1 - \lambda p_k(\lambda)$ is a "residual polynomial" of degree $\le k$ with $r_k(0) = 1$.

The function gap:

$$f(x_k) - f(x^*) = \frac{1}{2}(x_k - x^*)^T H(x_k - x^*) = \frac{1}{2}\|x_k - x^*\|_H^2$$

$$= \frac{1}{2}b^T H^{-1} r_k(H)^T H \cdot r_k(H) H^{-1} b = \frac{1}{2}b^T H^{-1} r_k(H)^2 b.$$

Using the spectral decomposition $H = \sum_i \lambda_i u_i u_i^T$:

$$f(x_k) - f(x^*) = \frac{1}{2}\sum_i \frac{(b^T u_i)^2}{\lambda_i} r_k(\lambda_i)^2.$$

### Step 3: Lower bound via worst-case polynomial

The best first-order method minimizes over all residual polynomials $r_k$ with $r_k(0) = 1$:

$$\min_{r_k: \deg \le k, r_k(0)=1} f(x_k) - f(x^*) = \min_{r_k} \frac{1}{2}\sum_i \frac{(b^T u_i)^2}{\lambda_i} r_k(\lambda_i)^2.$$

To construct a lower bound, we need to show that for a specific choice of $H$ and $b$, this minimum is large.

### Step 4: Nesterov's worst-case spectrum

Choose $H = \frac{L}{4}A_k$ where $A_k$ is the $(2k+1) \times (2k+1)$ tridiagonal matrix $\operatorname{tridiag}(-1,2,-1)$ (embedded in $\mathbb{R}^d$), and $b = \frac{L}{4}e_1$.

The eigenvalues of $A_k$ are $\mu_j = 2 - 2\cos\frac{\pi j}{2k+2}$ for $j = 1, \ldots, 2k+1$, so the eigenvalues of $H$ are $\lambda_j = \frac{L}{4}\mu_j \in (0, L)$.

With $b = \frac{L}{4}e_1$, the Krylov subspace $\mathcal{K}_k(H, b) = \operatorname{span}\{e_1, \ldots, e_k\}$ due to the tridiagonal structure.

### Step 5: Connection to Chebyshev polynomials

The best residual polynomial for the eigenvalues $\{\lambda_1, \ldots, \lambda_{2k+1}\}$ is related to Chebyshev polynomials. The minimum of $\max_j |r_k(\lambda_j)|$ over residual polynomials of degree $k$ with $r_k(0) = 1$ is achieved by the shifted Chebyshev polynomial:

$$r_k^*(\lambda) = \frac{T_k\!\left(\frac{L - 2\lambda}{L}\right)}{T_k(1)}$$

where $T_k$ is the Chebyshev polynomial of the first kind.

However, for $\lambda \in [0, L]$, we use:

$$r_k^*(\lambda) = \frac{T_k\!\left(1 - \frac{2\lambda}{L}\right)}{T_k(1)} = \frac{T_k(1 - 2\lambda/L)}{1}$$

Wait — $T_k(1) = 1$, so this reduces to $T_k(1 - 2\lambda/L)$. But $1 - 2\lambda/L \in [-1, 1]$ for $\lambda \in [0, L]$, and $|T_k(x)| \le 1$ for $x \in [-1,1]$, so $|r_k^*| \le 1$. This doesn't help — we need a LOWER bound.

**Correction**: For the lower bound, we don't minimize over polynomials. Instead, we show that for the specific spectrum of $A_k$, ANY residual polynomial of degree $k$ must be large at some eigenvalue.

The key fact: $A_k$ has $2k+1$ eigenvalues, but a polynomial of degree $k$ has only $k$ free parameters (with the constraint $r_k(0) = 1$). So $r_k$ has at most $k$ zeros, and with $2k+1$ eigenvalues, it cannot vanish at all of them.

More precisely, the eigenvalues are $\mu_j = 4\sin^2\frac{\pi j}{2(2k+2)}$ for $j = 1, \ldots, 2k+1$.

For the smallest eigenvalue $\mu_1 = 2(1 - \cos\frac{\pi}{2k+2})$, we use the bound: any residual polynomial of degree $k$ must satisfy

$$|r_k(\mu_1)| \ge \frac{1}{T_k\!\left(\frac{\mu_{2k+1} + \mu_1}{\mu_{2k+1} - \mu_1}\right)}$$

but this goes in the wrong direction for our purposes.

### Step 5 (revised): Direct computation via the tridiagonal structure

Rather than the Chebyshev polynomial approach for a general bound, let's use the explicit Schur complement computation.

This is equivalent to Route 1's computation. For the specific tridiagonal construction:

$$\min_{x \in \mathcal{K}_k} f(x) - f(x^*) = \frac{L}{8} \cdot v^T S v = \frac{L}{16(k+1)}$$

where the Schur complement calculation gives $v^T S v = \frac{1}{2(k+1)}$ (as computed in Route 1).

### Step 6: Complete the bound

Combined with $\|x^*\|^2 \le \frac{2(k+1)}{3}$ (verified in Route 1):

$$f(x_k) - f(x^*) \ge \frac{L}{16(k+1)} = \frac{L}{16(k+1)} \cdot \frac{3\|x^*\|^2}{2(k+1)} \cdot \frac{2(k+1)}{3\|x^*\|^2} \ge \frac{3L\|x^*\|^2}{32(k+1)^2}.$$

$\blacksquare$

**Note**: This route ultimately relies on the same Schur complement computation as Route 1. The Chebyshev polynomial framework provides insight into *why* $\Omega(1/k^2)$ is optimal (it's the best polynomial approximation rate) but doesn't simplify the constant computation for this specific construction.
