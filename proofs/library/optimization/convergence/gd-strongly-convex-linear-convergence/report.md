# Proof Report: Gradient Descent Linear Convergence for Strongly Convex Functions

## 1. Problem Statement

Let $f: \mathbb{R}^d \to \mathbb{R}$ be $\mu$-strongly convex and $L$-smooth. Consider gradient descent with step size $\eta = 1/L$: $x_{k+1} = x_k - \frac{1}{L}\nabla f(x_k)$. Prove:

(a) $f(x_k) - f(x^*) \leq (1 - \mu/L)^k (f(x_0) - f(x^*))$

(b) $\|x_k - x^*\|^2 \leq (1 - \mu/L)^k \|x_0 - x^*\|^2$

Source: Nesterov 2004 Theorem 2.1.15; Bubeck 2015 survey.

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 3 routes proposed |
| Explorer | Opus | 3 proofs attempted, 2 fully succeeded, 1 partial |
| Judge | Sonnet | Combined Route 1+2 selected (score: 37/40) |
| Audit | Opus | PASS (1 round, 0 issues of HIGH/MEDIUM severity) |
| Fix | Opus | Not needed |

## 3. Proof Routes Explored

### Route 1: Descent Lemma + PL Inequality (Score: 37/40)
- Part (a): Fully proved with sharp $(1-\mu/L)^k$ rate via descent lemma + PL inequality
- Part (b): Proved with $\kappa$ prefactor (suboptimal); acknowledged limitation
- **Selected as primary for Part (a)**

### Route 2: Cocoercivity + Direct Iterate Contraction (Score: 36/40)
- Part (b): Proved with tighter $((L-\mu)/(L+\mu))^k$ rate via interpolation inequality
- Part (a): Indirect derivation from iterates gives $\kappa$ prefactor
- **Selected as primary for Part (b)**

### Route 3: Direct Quadratic Bound Recursion (Score: 31/40)
- Part (a): Essentially same as Route 1
- Part (b): Only achieved $(1-\mu^2/L^2)^k$ rate (suboptimal)
- **Not selected**

## 4. Final Proof

The final proof combines Route 1 (Steps 1-4 for function value convergence) with Route 2 (Steps 5-7 for iterate convergence):

**Part (a)** — Descent Lemma + PL:
1. Descent lemma: $f(x_{k+1}) \leq f(x_k) - \frac{1}{2L}\|\nabla f(x_k)\|^2$
2. PL inequality: $\|\nabla f(x)\|^2 \geq 2\mu(f(x) - f(x^*))$
3. Combine: $f(x_{k+1}) - f(x^*) \leq (1-\mu/L)(f(x_k) - f(x^*))$
4. Telescope to get $(1-\mu/L)^k$ rate

**Part (b)** — Interpolation + Cocoercivity:
5. Interpolation inequality: $\langle \nabla f(x) - \nabla f(y), x-y \rangle \geq \frac{\mu L}{\mu+L}\|x-y\|^2 + \frac{1}{\mu+L}\|\nabla f(x)-\nabla f(y)\|^2$
6. Apply to GD iterate: $\|x_{k+1}-x^*\|^2 \leq \frac{L-\mu}{L+\mu}\|x_k-x^*\|^2$
7. Note $\frac{L-\mu}{L+\mu} \leq 1-\mu/L$, yielding the claimed rate

Full proof text: see `best_proof.md`

## 5. Audit Result

**PASS** after 1 round.
- 7/7 steps verified VALID
- 4 critical algebraic steps verified by SymPy
- 3 LOW severity presentational notes (edge case $L=\mu$, Baillon-Haddad cited not proved, minor clarity)
- No HIGH or MEDIUM issues

## 6. Fix History

No fixes needed. Proof passed audit on first round.
