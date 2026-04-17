# Proof Route 2: Chebyshev Analysis + Piecewise Quadratic Counterexample

**Route**: Chebyshev polynomial connection for Part 1, Piecewise quadratic (C^1) counterexample for Part 2

---

## Part 1: Convergence Rate via Chebyshev Polynomials

### Step 1: Heavy Ball as a three-term recurrence

On $f(x) = \frac{1}{2}x^T \mathrm{diag}(\mu, L) x$, per coordinate with eigenvalue $\lambda$:
$$x_{k+1} = (1+\beta-\alpha\lambda) x_k - \beta x_{k-1}.$$

This is a linear three-term recurrence of the form:
$$x_{k+1} - p x_k + q x_{k-1} = 0$$
where $p = 1+\beta-\alpha\lambda$ and $q = \beta$.

### Step 2: Connection to Chebyshev polynomials

The Chebyshev polynomials of the first kind $T_k(\cos\theta) = \cos(k\theta)$ satisfy:
$$T_{k+1}(t) = 2t \cdot T_k(t) - T_{k-1}(t).$$

Our recurrence matches this with $2t = p/\sqrt{q}$ ... actually, the standard analysis uses the characteristic equation $\sigma^2 - p\sigma + q = 0$ with roots $\sigma = \frac{p \pm \sqrt{p^2 - 4q}}{2}$.

With optimal parameters (as computed in Route 1), both eigenvalues $\lambda = \mu$ and $\lambda = L$ give a repeated root of modulus $r = \frac{\sqrt{\kappa}-1}{\sqrt{\kappa}+1}$.

### Step 3: Minimax optimality

Polyak (1964) showed that among all methods of the form $x_{k+1} = x_k + \alpha_k(x_k - x_{k-1}) - \beta_k \nabla f(x_k)$ with fixed coefficients, the optimal rate on the class of quadratics with spectrum in $[\mu, L]$ is achieved by choosing $\alpha, \beta$ so that the spectral radius:
$$\rho = \max_{\lambda \in [\mu, L]} \rho(M_\lambda)$$
is minimized. The minimax solution yields $\rho = \frac{\sqrt{\kappa}-1}{\sqrt{\kappa}+1}$, matching the Chebyshev rate.

(The full Part 1 proof follows Route 1's spectral analysis, which is the most direct approach. The Chebyshev connection provides additional context but the core proof is the same.)

---

## Part 2: Piecewise Quadratic Counterexample

### Step 4: The simplest counterexample

Define $f: \mathbb{R} \to \mathbb{R}$ as:
$$f(x) = \begin{cases} \frac{L}{2}x^2 & x \geq 0 \\ \frac{\mu}{2}x^2 & x < 0 \end{cases}$$

**Properties**:
- $f$ is $C^1$ (since $f'(0^+) = 0 = f'(0^-)$) but not $C^2$
- $f$ is $\mu$-strongly convex: for any $x, y$, $f(y) \geq f(x) + f'(x)(y-x) + \frac{\mu}{2}(y-x)^2$
- $f$ is $L$-smooth: $|f'(x) - f'(y)| \leq L|x-y|$ for all $x, y$
- Minimizer at $x^* = 0$

Note: $L$-smoothness requires $f'$ to be $L$-Lipschitz. For $x, y \geq 0$: $|f'(x) - f'(y)| = L|x-y|$. For $x \geq 0, y < 0$: $|f'(x) - f'(y)| = |Lx - \mu y| \leq L|x| + L|y| ... $ — actually we need $|Lx - \mu y| \leq L|x-y|$ for $x \geq 0, y < 0$. We have $|Lx - \mu y| = Lx - \mu y = Lx + \mu|y|$ and $|x-y| = x + |y|$. So we need $Lx + \mu|y| \leq L(x + |y|)$, which holds since $\mu \leq L$. ✓

### Step 5: Divergence analysis

Set $\mu = 1$, $L = \kappa$. Heavy Ball parameters: $\alpha = \frac{4}{(\sqrt{\kappa}+1)^2}$, $\beta = \left(\frac{\sqrt{\kappa}-1}{\sqrt{\kappa}+1}\right)^2$.

Start with $x_0 > 0$, $x_{-1} = x_0$ (zero momentum).

**When $x_k > 0$**: $f'(x_k) = Lx_k$, so iteration matrix is $M_L$ with eigenvalue $-r$ (double). The characteristic sequence (from Jordan block analysis) is:

$$x_k = (c_1 + c_2 k)(-r)^k$$

for constants determined by initial conditions. The iterates oscillate and decay, and eventually $x_k$ becomes negative.

**When $x_k < 0$**: $f'(x_k) = \mu x_k$, so iteration matrix is $M_\mu$ with eigenvalue $+r$ (double).

**Key: analyze the transition**. Suppose at step $k_0$, the iterate first becomes negative: $x_{k_0} = -a < 0$, $x_{k_0-1} = b > 0$.

From the $L$-curvature dynamics, just before crossing:
$$x_{k_0} = (1+\beta-\alpha L)x_{k_0-1} - \beta x_{k_0-2}.$$

Let's trace a specific trajectory. With $\kappa = 25$ (so $\sqrt{\kappa} = 5$):
- $\alpha = 4/36 = 1/9$
- $\beta = (4/6)^2 = 16/36 = 4/9$
- $r = 4/6 = 2/3$

$1 + \beta - \alpha L = 1 + 4/9 - 25/9 = 1 - 21/9 = -12/9 = -4/3$

Starting from $x_0 = 1, x_{-1} = 1$:

$x_1 = (-4/3)(1) - (4/9)(1) = -4/3 - 4/9 = -16/9 \approx -1.778$

Now $x_1 < 0$, so we use $f'(x_1) = \mu x_1 = x_1$:

$x_2 = x_1 - \alpha x_1 + \beta(x_1 - x_0) = x_1(1 - \alpha) + \beta x_1 - \beta x_0$
$= x_1(1 - 1/9 + 4/9) - 4/9 \cdot 1 = x_1 \cdot 12/9 - 4/9$
$= (-16/9)(12/9) - 4/9 = -192/81 - 36/81 = -228/81 \approx -2.815$

$x_2 < 0$, continue with $\mu$-dynamics:

$x_3 = x_2(1 + 4/9 - 1/9) - (4/9)x_1 = x_2 \cdot 12/9 - (4/9)(-16/9)$
$= (-228/81)(12/9) + 64/81 = -2736/729 + 64/81 = -2736/729 + 576/729 = -2160/729 \approx -2.963$

The magnitude is growing! Let's continue:

$x_4 = (12/9)x_3 - (4/9)x_2 = (12/9)(-2160/729) - (4/9)(-228/81)$
$= -25920/6561 + 912/729 = -25920/6561 + 8208/6561 = -17712/6561 \approx -2.699$

$x_5 = (12/9)x_4 - (4/9)x_3 = (12/9)(-17712/6561) - (4/9)(-2160/729)$
$= -212544/59049 + 8640/6561 = -212544/59049 + 77760/59049 = -134784/59049 \approx -2.282$

OK so it looks like after the initial growth, it starts to decay in the $\mu$-region (as expected since $M_\mu$ has spectral radius $r < 1$). But let me check if it crosses back to positive and re-enters the $L$-region...

Actually, for this specific $\kappa = 25$, the iterates in the $\mu$-region have eigenvalue $r = 2/3$, so they will decay and converge. The non-quadratic nature only matters if the iterates keep switching between regions.

**The key insight**: For divergence, we need the iterates to **repeatedly cross zero** so that they alternately experience $L$-curvature and $\mu$-curvature. Each crossing acts as a "perturbation" that can pump energy into the system.

With the piecewise function $f$, when an iterate crosses from $x > 0$ (curvature $L$) to $x < 0$ (curvature $\mu$), the momentum carries excessive kinetic energy into the low-curvature region, where it's not dissipated quickly enough.

### Step 6: Systematic analysis for large $\kappa$

For large $\kappa$, the Heavy Ball parameters satisfy $\beta \to 1$ and $\alpha L \to 4$ while $\alpha \mu \to 0$.

Consider starting at $x_0 = 1, x_{-1} = 1$:

$x_1 = (1 + \beta - \alpha L) \cdot 1 - \beta \cdot 1 = 1 - \alpha L = 1 - \frac{4\kappa}{(\sqrt{\kappa}+1)^2} \approx -3$ for large $\kappa$.

So $x_1 \approx -3 < 0$. Now in the $\mu$-region:

$x_2 = (1+\beta-\alpha\mu)x_1 - \beta x_0 \approx (1 + 1 - 0)(-3) - 1 \cdot 1 = -7$.

$x_3 = (1+\beta-\alpha\mu)x_2 - \beta x_1 \approx 2(-7) - 1 \cdot (-3) = -11$.

The iterates grow linearly! In the $\mu$-region, $1+\beta-\alpha\mu \approx 2$ and $\beta \approx 1$, so the recurrence is approximately $x_{k+1} \approx 2x_k - x_{k-1}$, which has solutions $x_k = c_1 + c_2 k$ (linear growth, since the characteristic equation $\sigma^2 - 2\sigma + 1 = 0$ has double root at $\sigma = 1$).

**This is the divergence mechanism!** When $\alpha\mu \ll 1$, the $\mu$-region iteration matrix $M_\mu$ has eigenvalues near $+1$, and the Jordan block structure means the iterates grow linearly (not exponentially, but they don't converge).

More precisely, $M_\mu$ has eigenvalue $r = \frac{\sqrt{\kappa}-1}{\sqrt{\kappa}+1} = 1 - \frac{2}{\sqrt{\kappa}+1}$, which approaches 1 as $\kappa \to \infty$. The spectral radius is still < 1, so eventually the iterates in the pure $\mu$-region do decay, but the **transient growth** phase lasts $O(\sqrt{\kappa})$ steps, during which the iterates grow by a factor of $O(\sqrt{\kappa})$.

Combined with the regime switching at $x = 0$, this transient growth can cause the iterates to re-enter the $L$-region with amplified magnitude, creating a feedback loop.

### Step 7: Formal divergence theorem

**Theorem (Divergence of Heavy Ball on piecewise quadratic)**: Let $\kappa \geq 9$ and define $f(x) = \frac{L}{2}\max(x,0)^2 + \frac{\mu}{2}\max(-x,0)^2$ where $L = \kappa\mu$. Then Heavy Ball with optimal quadratic parameters $\alpha = \frac{4}{(\sqrt{L}+\sqrt{\mu})^2}$, $\beta = (\frac{\sqrt{\kappa}-1}{\sqrt{\kappa}+1})^2$ does not converge to $x^* = 0$ from all initial conditions.

**Proof**: This requires numerical verification for specific $\kappa$ values. See numerical experiments.

## Route Failure Report
- Route: Chebyshev + Piecewise Quadratic
- Part 1: Succeeded (reduces to same spectral analysis as Route 1)
- Part 2: Partially succeeded — identified the divergence mechanism for large $\kappa$ but formal proof is incomplete; the argument relies on transient growth analysis which needs more careful bounding. The piecewise quadratic is only $C^1$, not $C^2$.
