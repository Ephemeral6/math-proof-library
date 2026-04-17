# Proof Report: Chambolle-Pock PDHG O(1/N) Saddle-Point Convergence

## 1. Problem Statement

Let X, Y be finite-dimensional real Hilbert spaces. Let K: X→Y be bounded linear with ‖K‖=L. Let g, f* be proper convex lsc. Consider the PDHG algorithm with τσL²<1:

y^{n+1} = prox_{σf*}(y^n + σKx̄^n)
x^{n+1} = prox_{τg}(x^n - τK*y^{n+1})
x̄^{n+1} = 2x^{n+1} - x^n

**Theorem:** The ergodic averages X^N, Y^N satisfy G_B(X^N, Y^N) ≤ (1/N)(‖x-x⁰‖²/(2τ) + ‖y-y⁰‖²/(2σ)) for all (x,y)∈B.

**Source:** Chambolle & Pock, JMIV 2011 / Math. Programming 2016.

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 5 routes proposed |
| Explorer | Opus | 4 proofs attempted, 4 succeeded |
| Judge | Sonnet | Route 2 selected (score: 29/40) |
| Audit | Opus | PASS (1 round, all steps VALID) |
| Fix | — | Not needed |

## 3. Proof Routes Explored

| Route | Approach | Score | Outcome |
|-------|----------|-------|---------|
| 1 | Prox VI + Lyapunov Telescoping | 25/40 | Complete, correct but verbose with false starts |
| 2 | Monotone Operator / VI Reformulation | 29/40 | ★ Winner. Clean, concise, well-organized |
| 3 | He-Yuan Diagonal Lyapunov Framework | 18/40 | Complete but extremely messy (1937 lines, 6+ restarts) |
| 4 | Fenchel Duality + KKT Residuals | 29/40 | Complete and correct, tied with Route 2 |

## 4. Final Proof

See `best_proof.md` (= `proof_route_2.md`).

**Key proof structure:**
1. Reformulate saddle-point as monotone inclusion 0 ∈ (A+B)(z)
2. Derive variational inequalities from prox characterization (VI-x, VI-y)
3. Verify M ≻ 0 via Schur complement ⟺ τσL² < 1
4. Per-step bound: three-point identity + coupling decomposition (telescoping bracket + Young remainder)
5. Sum over N: absorb all cross terms using τσL² < 1, apply Jensen → O(1/N)

## 5. Audit Result

**PASS** — All 5 steps VALID. No HIGH/MEDIUM issues found.

Key verifications:
- Coupling simplification S_K^n = ⟨K(x^{n+1}-x̄^n), y-y^{n+1}⟩ verified by direct expansion
- Young's inequality with α=σ correctly chosen to cancel y-difference terms
- Boundary term handling verified numerically
- Jensen's inequality correctly applied (convexity in x, concavity in y)
- Edge cases (N=1, L=0, τσL²→1) all consistent

## 6. Fix History

No fixes needed.
