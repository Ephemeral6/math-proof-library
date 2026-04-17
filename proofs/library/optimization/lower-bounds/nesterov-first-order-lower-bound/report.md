# Proof Report: Nesterov's First-Order Lower Bound for Smooth Convex Optimization

## 1. Problem Statement

**Theorem (Nesterov's Lower Bound).** For any $k \le (d-1)/2$ and any first-order method that generates iterates $x_t \in x_0 + \operatorname{span}\{\nabla f(x_0), \nabla f(x_1), \ldots, \nabla f(x_{t-1})\}$, there exists an $L$-smooth convex function $f: \mathbb{R}^d \to \mathbb{R}$ such that:

$$f(x_k) - f(x^*) \ge \frac{3L \|x_0 - x^*\|^2}{32(k+1)^2}.$$

Source: Nesterov 2004 "Introductory Lectures on Convex Optimization" (Theorem 2.1.7)

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 5 routes proposed (pre-existing) |
| Explorer | Opus | 4 proofs attempted: Route 1 succeeded, Route 2 partial (defers to Route 1), Route 3 partial (defers to Route 1), Route 5 failed |
| Judge | Sonnet | Route 1 selected (score: 34/40) |
| Audit | Opus | **PASS** (1 round, 0 issues of HIGH/MEDIUM severity) |
| Fix | Opus | Not needed |

## 3. Proof Routes Explored

### Route 1: Nesterov's Original Tridiagonal Construction (Direct) — SUCCEEDED (34/40)
Constructs the tridiagonal worst-case quadratic, proves the subspace restriction by induction, computes the optimal restricted value via Schur complement, and verifies the final inequality algebraically. All computations verified numerically.

### Route 2: Resisting Oracle / Information-Theoretic — PARTIAL (28/40)
Provides excellent conceptual motivation (adversarial oracle reveals one coordinate per step) but defers all quantitative analysis to Route 1.

### Route 3: Chebyshev Polynomial / Conjugate Gradient Optimality — PARTIAL (25/40)
Establishes the Krylov subspace / polynomial framework but fails to complete the proof via Chebyshev polynomials alone; falls back to the Schur complement.

### Route 5: 1D Reduction + Tensorization — FAILED (8/40)
The lower bound mechanism is inherently multi-dimensional; 1D base case is trivial.

## 4. Final Proof

### Step 1: Construct the worst-case function

Define the tridiagonal matrix $A_k \in \mathbb{R}^{d \times d}$ with nonzero entries only in the leading $(2k+1) \times (2k+1)$ block, where

$$(A_k)_{ij} = \begin{cases} 2 & \text{if } i = j, \\ -1 & \text{if } |i-j| = 1, \\ 0 & \text{otherwise}, \end{cases} \quad \text{for } 1 \le i,j \le 2k+1.$$

Define: $f_k(x) = \frac{L}{4}\left(\frac{1}{2}x^T A_k x - e_1^T x\right)$.

**Smoothness/convexity**: $\nabla^2 f_k = \frac{L}{4}A_k$, eigenvalues $\frac{L}{4}(2 - 2\cos\frac{\pi j}{2k+2}) \in (0, L)$. ✓

### Step 2: Optimal solution

$A_k x^* = e_1$ gives $x_i^* = 1 - \frac{i}{2k+2}$ for $i = 1, \ldots, 2k+1$.

### Step 3: Auxiliary quantities

- $f_k(x^*) = -\frac{L(q-1)}{8q}$ where $q = 2k+2$
- $\|x^*\|^2 = \frac{(q-1)(2q-1)}{6q}$

### Step 4: Subspace restriction

By induction on the tridiagonal structure: $x_t \in \operatorname{span}\{e_1, \ldots, e_t\}$.

### Step 5: Schur complement computation

Block-partition $A_k$ at index $k$. The Schur complement gives:

$$\min_{x_i=0, i>k} f_k(x) - f_k(x^*) = \frac{L}{8} v^T S v = \frac{L}{16(k+1)}$$

where $v^T S v = \frac{1}{2(k+1)}$ via explicit computation.

### Step 6: Final inequality

$\frac{L}{16(k+1)} \ge \frac{3L\|x^*\|^2}{32(k+1)^2}$ iff $\|x^*\|^2 \le \frac{2(k+1)}{3}$ iff $8k^2+10k+3 \le 8k^2+16k+8$ iff $6k+5 \ge 0$. ✓

$$\boxed{f(x_k) - f(x^*) \ge \frac{3L\|x_0 - x^*\|^2}{32(k+1)^2}} \qquad \blacksquare$$

## 5. Audit Result

**PASS** after 1 round. All 7 steps marked VALID. Three LOW-severity notes (presentation only):
1. Tridiagonal quadratic form identity stated without inline derivation
2. Tridiagonal inverse formula cited without proof
3. Translation argument for $x_0 \ne 0$ is brief

All key computations numerically verified for $k \in \{1, 2, 3, 5, 10, 20\}$.

## 6. Fix History

No fixes needed.
