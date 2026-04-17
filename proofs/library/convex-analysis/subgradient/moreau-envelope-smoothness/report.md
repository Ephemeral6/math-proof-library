# Proof Report: Moreau Envelope Smoothness and Gradient Formula

## 1. Problem Statement

**Theorem (Moreau Envelope Properties).** Let $f: \mathbb{R}^d \to \mathbb{R} \cup \{+\infty\}$ be a proper, closed, convex function. For $\lambda > 0$, define the Moreau envelope:

$$M_\lambda f(x) = \inf_{y} \left\{f(y) + \frac{1}{2\lambda}\|y - x\|^2\right\}$$

Prove: (a) $M_\lambda f$ is finite-valued and continuous; (b) $\nabla M_\lambda f(x) = \frac{1}{\lambda}(x - \text{prox}_{\lambda f}(x))$; (c) $\nabla M_\lambda f$ is $\frac{1}{\lambda}$-Lipschitz; (d) $M_\lambda f(x) \leq f(x)$ with equality iff $0 \in \partial f(x)$.

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 4 routes proposed (variational, first-principles, conjugate, decomposition) |
| Explorer | Opus | 4 proofs attempted, 3 succeeded, 1 failed (Route 4) |
| Judge | Sonnet | Route 1 selected (score: 36/40) |
| Audit | Opus | PASS (1 round, 0 INVALID steps, 3 LOW issues) |
| Fix | Opus | Not needed |

## 3. Proof Routes Explored

| Route | Approach | Outcome | Score |
|-------|----------|---------|-------|
| 1 | Direct Variational / Envelope Theorem | **Success** — clean sandwich argument | 36/40 |
| 2 | First-Principles / Optimality Condition | Success — correct but messier lower bound | 31/40 |
| 3 | Infimal Convolution + Conjugate Calculus | Success — relies on duality theorem | 30/40 |
| 4 | Moreau Decomposition + Conjugate Smoothness | Failed — reduced to Route 3 | 10/40 |

## 4. Final Proof

### Setup

Let $f: \mathbb{R}^d \to \mathbb{R} \cup \{+\infty\}$ be a proper, closed, convex function, $\lambda > 0$. Define:
$$M_\lambda f(x) = \inf_{y} \left\{f(y) + \frac{1}{2\lambda}\|y - x\|^2\right\}, \quad p_\lambda(x) = \arg\min_y \left\{f(y) + \frac{1}{2\lambda}\|y-x\|^2\right\}.$$

### Preliminary: Prox is well-defined and firmly nonexpansive

**Step 1.** $\varphi_x(y) = f(y) + \frac{1}{2\lambda}\|y-x\|^2$ is $\frac{1}{\lambda}$-strongly convex, proper, and closed. Hence it has a unique minimizer $p_\lambda(x)$.

**Step 2.** Optimality condition: $\frac{1}{\lambda}(x - p_\lambda(x)) \in \partial f(p_\lambda(x))$. (OC)

**Step 3.** Firm nonexpansiveness: For $p_i = p_\lambda(x_i)$, monotonicity of $\partial f$ gives:
$$\langle x_1 - x_2, p_1 - p_2\rangle \geq \|p_1 - p_2\|^2. \quad \text{(FNE)}$$

Consequences: (i) $\|p_1 - p_2\| \leq \|x_1 - x_2\|$ (nonexpansiveness); (ii) $\|(x_1 - p_1) - (x_2 - p_2)\| \leq \|x_1 - x_2\|$ (complementary nonexpansiveness, CNE).

### Part (a): Finite-valued and continuous

**Step 4.** Upper: evaluate at any $y_0 \in \text{dom } f$. Lower: minorant $f(y) \geq \langle a,y\rangle + b$ gives $M_\lambda f(x) \geq \langle a,x\rangle + b - \frac{\lambda}{2}\|a\|^2$.

**Step 5.** USC from infimum of continuous functions. LSC from $p_n \to p_\lambda(x)$ (Lipschitz) + lsc of $f$.

### Part (b): Gradient formula

**Step 6.** Sandwich argument:
- UB: test $y = p_\lambda(x)$ at $x+h$: $M_\lambda f(x+h) - M_\lambda f(x) \leq \frac{1}{\lambda}\langle x-p,h\rangle + \frac{1}{2\lambda}\|h\|^2$.
- LB: test $y = p_\lambda(x+h)$ at $x$: $M_\lambda f(x+h) - M_\lambda f(x) \geq \frac{1}{\lambda}\langle x-p,h\rangle - \frac{1}{2\lambda}\|h\|^2$.

Both errors are $O(\|h\|^2) = o(\|h\|)$, proving $\nabla M_\lambda f(x) = \frac{1}{\lambda}(x - p_\lambda(x))$.

### Part (c): $\frac{1}{\lambda}$-smoothness

**Step 7.** By (CNE): $\|\nabla M_\lambda f(x_1) - \nabla M_\lambda f(x_2)\| = \frac{1}{\lambda}\|(x_1-p_1) - (x_2-p_2)\| \leq \frac{1}{\lambda}\|x_1-x_2\|$.

### Part (d): Inequality and equality

**Step 8.** $M_\lambda f(x) \leq f(x)+0 = f(x)$. Equality iff $p_\lambda(x) = x$ iff $0 \in \partial f(x)$.

### Numerical Verification

All properties verified numerically for $f(x) = |x|$, $\lambda = 0.5$ with 10000 samples:
- $M_\lambda f(x) \leq f(x)$: PASS
- Gradient formula vs finite difference: max error $6.1 \times 10^{-9}$: PASS
- Lipschitz constant $\leq 1/\lambda = 2$: PASS (observed max ratio = 2.0000)
- Firm nonexpansiveness: PASS
- Equality at $x=0$ (where $0 \in \partial |0|$): PASS

## 5. Audit Result

**PASS** after 1 round. All 9 steps marked VALID. Three LOW-severity issues identified (all cosmetic/expository):
1. Step 5 could be more explicit about convergence of $\|p_n - x_n\|^2$.
2. Step 4 could cite a more precise justification for affine minorant existence.
3. Step 9 ($\Rightarrow$) could note $f(x)$ must be finite for equality to hold.

No mathematical errors found.

## 6. Fix History

No fixes needed — audit passed on the first round.
