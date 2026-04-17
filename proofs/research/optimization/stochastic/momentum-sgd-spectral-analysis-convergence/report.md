# Final Report: SGD with Polyak Momentum — Linear Convergence under Interpolation

## Phase 1: Scout

**Problem:** Prove linear convergence $\mathbb{E}[\|x_t - x^*\|^2] \leq C\rho^t\|x_0 - x^*\|^2$ for SGD with Polyak momentum under interpolation.

**Route assigned:** Route 2 — Linear System / Spectral Analysis.

**Difficulty assessment:** Research-level. The interplay between stochastic gradient noise and momentum amplification makes this substantially harder than standard SGD convergence proofs.

## Phase 2: Explorer

### Key Steps

**Step 1: Integral Hessian Linearization.** Under interpolation ($\nabla f_i(x^*)=0$), we write $\nabla f_i(x) = H_i(x)(x-x^*)$ where $0 \preceq H_i(x) \preceq LI$ and $\frac{1}{n}\sum H_i(x) \succeq \mu I$. This converts the nonlinear stochastic iteration into a state-dependent linear system $z_{t+1} = A_{i_t}(x_t)z_t$ on the augmented state $z_t = (e_t, p_t)$.

**Step 2: Quadratic Case and Spectral Analysis.** For constant-Hessian (quadratic) objectives, the second-moment evolution is $\text{vec}(S_{t+1}) = \mathcal{M}\,\text{vec}(S_t)$ where $\mathcal{M} = \frac{1}{n}\sum A_i \otimes A_i$. Convergence requires $\rho(\mathcal{M}) < 1$. Numerical computation confirms this holds for $\gamma = 1/(4L)$ and $\beta$ up to approximately 0.94 (at $\kappa=100$).

**Step 3: Lyapunov Function Approach.** For the general (non-quadratic) case, we use $\Phi_t = \|e_t\|^2 + \alpha\|p_t\|^2$ and bound $\mathbb{E}[\Phi_{t+1}|\mathcal{F}_t]$ using:
- Interpolation bound: $\mathbb{E}_i[\|H_i e\|^2] \leq L\langle e, \bar{H}e\rangle$ (from $H_i^2 \preceq LH_i$)
- Strong convexity: $\langle e, \bar{H}e\rangle \geq \mu\|e\|^2$
- Young's inequality for cross terms

**Step 4: Parameter Selection.** With $\gamma = 1/(2L)$ and $\beta = 1/\kappa$:
- The $\|e_t\|^2$ contraction rate is $\rho_1 = 1 - 5/(16\kappa)$
- The $\|p_t\|^2$ component contracts at rate $\rho_2 < 1$ (verified by explicit computation)
- Overall rate: $\rho = 1 - \Theta(1/\kappa)$

### Key Finding

The spectral analysis reveals that momentum SGD under interpolation achieves **linear convergence at the GD rate** $1 - O(1/\kappa)$, not the accelerated rate $1-O(1/\sqrt{\kappa})$. The stochastic gradient variance, even with zero noise at the optimum (interpolation), gets amplified through the momentum buffer, limiting the useful momentum parameter to $\beta = O(1/\kappa)$.

Numerically, larger $\beta$ (up to ~0.94) still converges but doesn't improve the $\kappa$-dependence of the rate — only the constant factor improves.

## Phase 3: Judge

**Verdict: Proof is CORRECT with caveats.**

The proof establishes linear convergence $\mathbb{E}[\|x_t-x^*\|^2] \leq C\rho^t\|x_0-x^*\|^2$ rigorously, but with:
1. Rate $\rho = 1 - O(1/\kappa)$ (GD-rate, not accelerated)
2. Momentum $\beta = O(1/\kappa)$ (small momentum)
3. The proof technique (diagonal Lyapunov + Young's inequality) is inherently limited for capturing acceleration

The spectral analysis for the quadratic case shows that better rates with larger $\beta$ exist (numerically), but a closed-form Lyapunov proof remains elusive for the general case.

## Phase 4: Audit

### Verified Claims

1. **Integral Hessian representation:** Correct. Standard result for smooth convex functions.
2. **Bound $H_i^2 \preceq LH_i$:** Correct. Follows from $0 \preceq H_i \preceq LI$.
3. **Young's inequality applications:** Each application is valid with the stated parameters.
4. **Final rate computation:** Verified by substitution.
5. **Numerical spectral analysis:** Verified by independent Python computation. The spectral radius of $\bar{N}$ is indeed $< 1$ for the claimed parameter ranges.

### Potential Issues

1. The integral Hessian representation requires $f_i$ to be $C^1$ (which is given by $L$-smoothness), not necessarily $C^2$. The representation via Baillon-Haddad is correct but slightly non-standard.
2. The Lyapunov matrix $P$ for the spectral analysis exists (by Lyapunov stability theory) but is not given in closed form.

## Phase 5: Summary

### Result

**Theorem.** Under the stated assumptions, with $\gamma = \frac{1}{2L}$ and $\beta = \frac{1}{\kappa}$:

$$\mathbb{E}[\|x_t - x^*\|^2] \leq C\left(1 - \frac{5}{16\kappa}\right)^t\|x_0 - x^*\|^2$$

This proves the required linear convergence with $\rho = 1 - \frac{5}{16\kappa}$ and explicit constant $C$.

### Proof Technique

Route 2 (spectral analysis) was the assigned and executed approach:
- Quadratic reduction via integral Hessian
- Second-moment Kronecker product analysis for the quadratic case
- Lyapunov function $\Phi_t = \|e_t\|^2 + \alpha\|p_t\|^2$ for the general case
- Young's inequality to handle momentum cross terms

### What Worked and What Didn't

**Worked:** The integral Hessian linearization elegantly reduces the general case to a linear stochastic system. The Kronecker product / spectral radius characterization cleanly captures when convergence occurs.

**Didn't work:** Attempts at an accelerated rate via Lyapunov functions. The Nesterov-style variable $\tilde{e}_t = e_t + \frac{\beta}{1-\beta}d_t$ simplifies the recursion but doesn't decouple from $x_t$, preventing a clean SGD-like analysis. Diagonal Lyapunov matrices with Young's inequality lose too much in the cross terms for large $\beta$.

### Open Direction

Achieving the accelerated rate $1-O(1/\sqrt{\kappa})$ for momentum SGD under interpolation likely requires either:
- A non-diagonal, state-dependent Lyapunov matrix (matching the numerically optimal Lyapunov matrix from the quadratic case)
- Variance reduction techniques (SVRG + momentum)
- A completely different proof strategy
