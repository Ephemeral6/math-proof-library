# Proof Report: Proximal Gradient Method O(1/T) Convergence

## 1. Problem Statement

Minimize $F(x) = f(x) + g(x)$ where $f$ is convex, $L$-smooth and $g$ is convex, proper, lsc.

Proximal gradient: $x_{t+1} = \mathrm{prox}_{(1/L)g}(x_t - \frac{1}{L}\nabla f(x_t))$

**Theorem:** $F(x_T) - F(x^*) \leq \frac{L\|x_0 - x^*\|^2}{2T}$

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 5 routes proposed |
| Explorer | Opus | 4 proofs attempted, all succeeded |
| Judge | Sonnet | Route 2 selected (Lyapunov, score: 35/40) |
| Audit | Opus | PASS (all steps valid, 1 round) |
| Fix | — | Not needed |

## 3. Proof Routes Explored

1. **Descent + Telescope** (29/40): Correct but had to restart mid-proof. Gets the key per-step inequality via polarization identity.
2. **Lyapunov Potential** (35/40, WINNER): Key insight that the optimality gap upper bound and the Lyapunov decrease are the same expression.
3. **Bregman/Mirror** (34/40): Rigorous, uses three-point identity. More verbose but correctly handles ergodic vs last-iterate distinction.
4. **Gradient Mapping** (28/40): Clean Q_L model approach but some steps underspecified.

## 4. Final Proof

### Setup
$G_t = L(x_t - x_{t+1})$, $\Phi_t = \frac{L}{2}\|x_t - x^*\|^2$

### Key per-step inequality
From descent lemma + convexity + proximal optimality:

$$F(x_{t+1}) - F(x^*) \leq \frac{1}{2L}\|G_t\|^2 + \langle G_t, x_{t+1} - x^* \rangle \tag{A}$$

From algebra on $\Phi_t - \Phi_{t+1}$:

$$\Phi_t - \Phi_{t+1} = \frac{1}{2L}\|G_t\|^2 + \langle G_t, x_{t+1} - x^* \rangle \tag{B}$$

Since (A) = (B): $F(x_{t+1}) - F(x^*) \leq \Phi_t - \Phi_{t+1}$

### Monotonicity
Setting $x^* = x_t$ in (A): $F(x_{t+1}) - F(x_t) \leq -\frac{1}{2L}\|G_t\|^2 \leq 0$

### Telescope
$T(F(x_T) - F(x^*)) \leq \Phi_0 = \frac{L}{2}\|x_0 - x^*\|^2$

$$\boxed{F(x_T) - F(x^*) \leq \frac{L\|x_0 - x^*\|^2}{2T}}$$

## 5. Audit Result

PASS on first round. All steps verified correct. The key insight that (A) holds for any point $u$ (not just $x^*$) enables both the Lyapunov telescoping and the monotonicity argument.

## 6. Fix History

No fixes needed.
