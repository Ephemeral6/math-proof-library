# Proof Report: Nesterov's Accelerated Gradient Descent O(1/k²) Convergence

## 1. Problem Statement

**Theorem (Nesterov's Accelerated Gradient).** Let $f: \mathbb{R}^d \to \mathbb{R}$ be convex with $L$-Lipschitz continuous gradient. Consider the accelerated gradient method (three-sequence form):

$$z_0 = x_0, \quad y_k = \frac{k}{k+2}x_k + \frac{2}{k+2}z_k, \quad x_{k+1} = y_k - \frac{1}{L}\nabla f(y_k), \quad z_{k+1} = z_k - \frac{k+1}{2L}\nabla f(y_k)$$

Then for all $k \geq 1$:

$$f(x_k) - f(x^*) \leq \frac{2L\|x_0 - x^*\|^2}{k(k+1)} = O\!\left(\frac{L\|x_0 - x^*\|^2}{k^2}\right)$$

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 4 routes proposed (Lyapunov, Estimate Sequence, Direct Lyapunov, FISTA parameterization) |
| Explorer | Opus | 4 proofs attempted, 2 succeeded (Routes 2 and 3), 2 failed (Routes 1 and 4) |
| Judge | Sonnet | Route 3 selected (score: 36/40) |
| Audit R1 | Opus | PASS with MEDIUM presentation issues |
| Fix R1 | Opus | 3 issues fixed (cleaned presentation, corrected bound statement) |
| Audit R2 | Opus | PASS (1 LOW issue only) |
| Numerical Verification | Python | All 50 iterations confirmed: ratio ≤ 0.073 (bound holds with large margin) |

## 3. Proof Routes Explored

1. **Route 1 (Lyapunov - Original Attempt)**: Failed. Got stuck on coefficient matching between the Lyapunov function and the momentum parameter. Score: 7/40.

2. **Route 2 (Estimate Sequence Framework)**: Succeeded with weaker constant. Proved O(1/k²) via Nesterov's abstract estimate sequence machinery with λ_k ≤ 4/(k+2)². The constant was 6L instead of 2L due to the f(x₀)-f* term in the initial estimate. Score: 26/40.

3. **Route 3 (Direct Lyapunov - Bansal-Gupta Style)**: **WINNER**. Clean Lyapunov function V_k = k(k+1)(f(x_k)-f*) + 2L||z_k-x*||² shown to be non-increasing. Elegant cancellations yield the bound directly. Score: 36/40.

4. **Route 4 (Tight FISTA Parameterization)**: Failed. Could not cleanly synchronize the t_k = (1+√(1+4t_k²))/2 sequence with the Lyapunov decrease. Score: 10/40.

## 4. Final Proof

### Setup

Let $f: \mathbb{R}^d \to \mathbb{R}$ be convex with $L$-Lipschitz continuous gradient:

**(S1)** $f(x) \leq f(y) + \langle\nabla f(y), x - y\rangle + \frac{L}{2}\|x - y\|^2$

**(S2)** $f(x) \geq f(y) + \langle\nabla f(y), x - y\rangle$

### Algorithm

$z_0 = x_0$. For $k \geq 0$:

$$y_k = \frac{k}{k+2}x_k + \frac{2}{k+2}z_k, \quad x_{k+1} = y_k - \frac{1}{L}\nabla f(y_k), \quad z_{k+1} = z_k - \frac{k+1}{2L}\nabla f(y_k)$$

### Lyapunov Function

$$V_k = k(k+1)(f(x_k) - f^*) + 2L\|z_k - x^*\|^2$$

### Key Steps

**Step 1 (Descent Lemma):**
$$f(x_{k+1}) \leq f(y_k) - \frac{1}{2L}\|\nabla f(y_k)\|^2 \tag{1}$$

**Step 2 (Convex Combination):** Using $y_k = \frac{k}{k+2}x_k + \frac{2}{k+2}z_k$ and convexity:
$$f(y_k) - f^* \leq \frac{k}{k+2}(f(x_k) - f^*) + \frac{2}{k+2}\langle\nabla f(y_k), z_k - x^*\rangle \tag{2}$$

**Step 3 (Multiply by (k+1)(k+2)):** Combining (1) and (2):
$$(k+1)(k+2)(f(x_{k+1}) - f^*) \leq k(k+1)(f(x_k) - f^*) + 2(k+1)\langle\nabla f(y_k), z_k - x^*\rangle - \frac{(k+1)(k+2)}{2L}\|\nabla f(y_k)\|^2 \tag{3}$$

**Step 4 (z_k expansion):** From $z_{k+1} = z_k - \frac{k+1}{2L}\nabla f(y_k)$:
$$2L\|z_{k+1} - x^*\|^2 = 2L\|z_k - x^*\|^2 - 2(k+1)\langle\nabla f(y_k), z_k - x^*\rangle + \frac{(k+1)^2}{2L}\|\nabla f(y_k)\|^2 \tag{4}$$

**Step 5 (Cancellation):** Adding (3) and (4):
- Inner product terms: $+2(k+1)\langle\cdot\rangle - 2(k+1)\langle\cdot\rangle = 0$
- Gradient norms: $-\frac{(k+1)(k+2)}{2L} + \frac{(k+1)^2}{2L} = -\frac{k+1}{2L}$

$$V_{k+1} \leq V_k - \frac{k+1}{2L}\|\nabla f(y_k)\|^2 \leq V_k$$

**Step 6 (Rate):** $V_0 = 2L\|x_0 - x^*\|^2$, so:
$$f(x_k) - f^* \leq \frac{2L\|x_0 - x^*\|^2}{k(k+1)} \leq \frac{2L\|x_0 - x^*\|^2}{k^2}$$

$\blacksquare$

## 5. Audit Result

- Round 1: PASS with MEDIUM issues (presentation only; core math correct)
- Round 2 (after fix): PASS with 1 LOW issue
- Numerical verification: PASS (50 iterations, all ratios < 0.08)
- Conclusion: **PROOF VERIFIED**

## 6. Fix History

Round 1 fixes:
1. Corrected the bound statement to match what is actually proved: $2L/[k(k+1)]$ not $2L/(k+1)^2$
2. Added clear remark about equivalence to the momentum form
3. Removed all "thinking out loud" scratch work, producing a clean 7-step proof
