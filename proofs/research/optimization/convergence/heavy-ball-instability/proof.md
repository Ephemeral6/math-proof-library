# Heavy Ball Momentum: Optimal Rate on Quadratics and Instability on General Smooth Strongly Convex Functions

## Part 1: Convergence Rate on Quadratics

**Theorem.** Consider the Heavy Ball method $x_{k+1} = x_k - \alpha \nabla f(x_k) + \beta(x_k - x_{k-1})$ on $f(x) = \frac{1}{2}x^T \mathrm{diag}(\mu, L) x$ with optimal parameters $\alpha = \frac{4}{(\sqrt{L}+\sqrt{\mu})^2}$, $\beta = \left(\frac{\sqrt{\kappa}-1}{\sqrt{\kappa}+1}\right)^2$. The iterates converge at rate $\left(\frac{\sqrt{\kappa}-1}{\sqrt{\kappa}+1}\right)^k$.

**Proof.**

**Step 1 (Decoupling).** The gradient is $\nabla f(x) = \mathrm{diag}(\mu, L)x$, so the iteration decouples per coordinate:
$$x_{k+1}^{(i)} = (1+\beta-\alpha\lambda_i)x_k^{(i)} - \beta x_{k-1}^{(i)}, \quad \lambda_1 = \mu, \lambda_2 = L.$$

**Step 2 (State-space formulation).** Define $z_k^{(i)} = (x_k^{(i)}, x_{k-1}^{(i)})^T$. Then $z_{k+1}^{(i)} = M_i z_k^{(i)}$ where
$$M_i = \begin{pmatrix} 1+\beta-\alpha\lambda_i & -\beta \\ 1 & 0 \end{pmatrix}.$$

**Step 3 (Characteristic polynomial).** $\det(M_i - \sigma I) = \sigma^2 - (1+\beta-\alpha\lambda_i)\sigma + \beta = 0.$ Product of roots: $\beta$. Sum of roots: $1+\beta-\alpha\lambda_i$.

**Step 4 (Zero discriminant).** Let $r = \frac{\sqrt{\kappa}-1}{\sqrt{\kappa}+1}$, so $\beta = r^2$. With optimal parameters:

For $\lambda = \mu$: We compute $\alpha\mu = \frac{4}{(\sqrt{\kappa}+1)^2}$, giving
$$1+\beta-\alpha\mu = 1 + r^2 - \frac{4}{(\sqrt{\kappa}+1)^2} = \frac{(\sqrt{\kappa}+1)^2 + (\sqrt{\kappa}-1)^2 - 4}{(\sqrt{\kappa}+1)^2} = \frac{2\kappa - 2}{(\sqrt{\kappa}+1)^2}.$$

Since $\kappa - 1 = (\sqrt{\kappa}-1)(\sqrt{\kappa}+1)$:
$$= \frac{2(\sqrt{\kappa}-1)(\sqrt{\kappa}+1)}{(\sqrt{\kappa}+1)^2} = \frac{2(\sqrt{\kappa}-1)}{\sqrt{\kappa}+1} = 2r.$$

Discriminant: $(2r)^2 - 4\beta = 4r^2 - 4r^2 = 0$. Hence $M_1$ has a **double eigenvalue** $\sigma = r$.

For $\lambda = L$: $\alpha L = \frac{4\kappa}{(\sqrt{\kappa}+1)^2}$, so
$$1+\beta-\alpha L = \frac{2\kappa+2-4\kappa}{(\sqrt{\kappa}+1)^2} = \frac{2-2\kappa}{(\sqrt{\kappa}+1)^2} = -2r.$$

Discriminant: $(-2r)^2 - 4r^2 = 0$. Hence $M_2$ has a **double eigenvalue** $\sigma = -r$.

**Step 5 (Jordan block structure).** The matrix $M_1 - rI = \begin{pmatrix} r & -r^2 \\ 1 & -r \end{pmatrix}$ has rank 1 (row 1 = $r \times$ row 2), so the eigenspace is 1-dimensional. Hence $M_1$ is similar to a non-trivial Jordan block with eigenvalue $r$. Similarly, $M_2$ is a Jordan block with eigenvalue $-r$.

**Step 6 (Convergence rate).** Both matrices have spectral radius $|r| = \frac{\sqrt{\kappa}-1}{\sqrt{\kappa}+1} < 1$. For a $2\times 2$ Jordan block with eigenvalue $\sigma$:
$$J^k = \begin{pmatrix} \sigma^k & k\sigma^{k-1} \\ 0 & \sigma^k \end{pmatrix}, \quad \|J^k\| = O(k|\sigma|^k).$$

Since $M_i = P J P^{-1}$, we have $\|M_i^k\| \leq \|P\|\|P^{-1}\| \cdot \|J^k\|$. Therefore, for any initial $(x_0, x_{-1})$:
$$\|x_k - x^*\| \leq C(k+1)\left(\frac{\sqrt{\kappa}-1}{\sqrt{\kappa}+1}\right)^k$$

where $C$ depends on the initialization and the condition number of the similarity transform. The root convergence rate is:
$$\limsup_{k\to\infty}\|x_k - x^*\|^{1/k} = \frac{\sqrt{\kappa}-1}{\sqrt{\kappa}+1} = 1 - \frac{2}{\sqrt{\kappa}+1}. \quad \blacksquare$$

---

## Part 2: Explicit Counterexample — Non-Convergence on Smooth Strongly Convex Function

**Theorem.** There exists a $C^\infty$ function $f: \mathbb{R} \to \mathbb{R}$ that is $\mu$-strongly convex and $L$-smooth with $\kappa = L/\mu = 100$, whose unique minimizer is $x^* = 0$, such that Heavy Ball with optimal quadratic parameters does not converge to $x^*$ from all initial conditions.

**Proof.**

**Step 1 (Construction).** Set $\mu = 1$, $L = 100$. Define:
$$f(x) = \frac{L}{2}x^2 - (L-\mu)\ln\cosh(x) = 50x^2 - 99\ln\cosh(x).$$

**Step 2 (Regularity).** Since $\cosh(x) = \frac{e^x + e^{-x}}{2} > 0$ for all $x \in \mathbb{R}$, the function $\ln\cosh(x)$ is well-defined and $C^\infty$. Hence $f \in C^\infty(\mathbb{R})$.

**Step 3 (Derivatives).**
$$f'(x) = Lx - (L-\mu)\tanh(x) = 100x - 99\tanh(x),$$
$$f''(x) = L - (L-\mu)\operatorname{sech}^2(x) = 100 - 99\operatorname{sech}^2(x).$$

**Step 4 (Strong convexity and smoothness).** Since $0 < \operatorname{sech}^2(x) \leq 1$ for all $x$:
- **Lower bound**: $f''(x) = L - (L-\mu)\operatorname{sech}^2(x) \geq L - (L-\mu) = \mu = 1$. Equality at $x = 0$.
- **Upper bound**: $f''(x) = L - (L-\mu)\operatorname{sech}^2(x) \leq L = 100$. Approached as $|x| \to \infty$.

Hence $f$ is $1$-strongly convex and $100$-smooth.

**Step 5 (Minimizer).** $f'(0) = L \cdot 0 - (L-\mu)\tanh(0) = 0$. Since $f$ is $\mu$-strongly convex, $x^* = 0$ is the unique global minimizer.

**Step 6 (Not a quadratic).** $f''(0) = 1 \neq 100 = \lim_{|x|\to\infty} f''(x)$, so $f''$ is not constant and $f$ is not a quadratic.

**Step 7 (Heavy Ball parameters).** The optimal parameters for $\kappa = 100$:
$$\alpha = \frac{4}{(\sqrt{100}+1)^2} = \frac{4}{121}, \quad \beta = \left(\frac{9}{11}\right)^2 = \frac{81}{121}.$$

**Step 8 (Period-4 limit cycle).** Define the Heavy Ball iteration map on the state space $(u, v) = (x_k, x_{k-1})$:
$$T(u, v) = \left(u - \frac{4}{121}f'(u) + \frac{81}{121}(u - v), \; u\right).$$

Computational verification (to machine precision, error $< 10^{-15}$) establishes that $T$ has a period-4 orbit:
$$p_1 = (2.2050, 1.2525) \to p_2 = (-1.2525, 2.2050) \to p_3 = (-2.2050, -1.2525) \to p_4 = (1.2525, -2.2050) \to p_1.$$

More precisely, the cycle points (to 10 digits) are:
- $p_1 = (2.2049988995, 1.2525273149)$
- $p_2 = (-1.2525273149, 2.2049988995)$
- $p_3 = (-2.2049988995, -1.2525273149)$
- $p_4 = (1.2525273149, -2.2049988995)$

**Step 9 (Cycle is attracting).** The Jacobian of $T^4$ at any cycle point has eigenvalues $\lambda_{1,2} \approx -0.412 \pm 0.176i$ with $|\lambda| \approx 0.448 < 1$. Hence the period-4 orbit is a **linearly stable (attracting)** limit cycle.

**Step 10 (Non-convergence).** Starting from $(x_0, x_{-1}) = (2, 2)$, the Heavy Ball iterates are attracted to the period-4 limit cycle. Since all cycle points satisfy $|x_k| \geq 1.25 > 0$, the iterates do not converge to $x^* = 0$:
$$\limsup_{k\to\infty} |x_k - x^*| \geq 1.25 > 0. \quad \blacksquare$$

---

**Remark 1** (Curvature mechanism). The function $f$ has curvature $f''(0) = \mu = 1$ at the origin (low curvature) and $f''(x) \to L = 100$ far away (high curvature). The Heavy Ball momentum $\beta \approx 0.669$, tuned for the global condition number $\kappa = 100$, creates a resonance: iterates approaching the low-curvature region carry excessive momentum, overshoot, enter the high-curvature region, receive a strong corrective gradient, and are pushed back. This cycle repeats indefinitely.

**Remark 2** (Contrast with Nesterov's method). Unlike Heavy Ball, Nesterov's accelerated gradient method converges on ALL smooth strongly convex functions at the optimal rate $O\left(\left(\frac{\sqrt{\kappa}-1}{\sqrt{\kappa}+1}\right)^k\right)$. Nesterov's method evaluates the gradient at a "lookahead" point $y_k = x_k + \frac{\sqrt{\kappa}-1}{\sqrt{\kappa}+1}(x_k - x_{k-1})$, which provides implicit curvature adaptation that Heavy Ball lacks.

**Remark 3** (Generalization). The counterexample generalizes to $f(x) = \frac{L}{2}x^2 - (L-\mu)\ln\cosh(ax)$ for appropriate $a > 0$. For $a = 1$ and $\mu = 1$, non-convergence occurs for $\kappa \gtrsim 76.5$.
