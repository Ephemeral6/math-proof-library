# Proof Report: ADMM Ergodic O(1/T) Convergence Rate

## 1. Problem Statement

Prove the classical ADMM ergodic O(1/T) convergence theorem (He–Yuan 2012 SIOPT): for the 2-block convex composite problem
$$\min_{x,z}\ f(x)+g(z)\quad\text{s.t.}\quad Ax+Bz=c,$$
with standard ADMM iterates and penalty $\beta>0$, the ergodic averages $(\bar x_T,\bar z_T,\bar\lambda_T)$ satisfy, for every $T\ge 1$, every $\tilde\lambda\in\mathbb{R}^m$, and every **feasible** test point $A\tilde x+B\tilde z=c$:
$$\Phi(\bar w_T;\tilde w)\;\le\;\frac{1}{T}\left[\tfrac{\beta}{2}\|B(\tilde z-z^0)\|^2+\tfrac{1}{2\beta}\|\tilde\lambda-\lambda^0\|^2\right].$$

See `problem.md` for the full statement.

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 4 routes proposed (He-Yuan VI / DR-dual / Direct Lagrangian / Proximal-point) |
| Explorer | Opus × 4 | 2 fully valid (R1, R3) + 2 structurally valid with caveats (R2, R4) |
| Judge | Sonnet | Route 3 selected (29/40, tied with R1, wins tie-break on lagged-dual handling) |
| Audit | Opus | PASS round 1 — all 11 steps VALID, 7 numerical check families passed |
| Fix | — | Not needed |

## 3. Proof Routes Explored

- **Route 1 (He-Yuan VI framework)**: Reformulate ADMM as a monotone VI $F(w)\in-\partial\theta(w)$ with skew-linear $F$, derive the $H$-weighted per-step inequality, telescope, apply Jensen + skew-affine averaging. **Valid**, 29/40.
- **Route 2 (DR-on-dual equivalence)**: Derive the Gabay correspondence (ADMM = DR on the dual problem) from first principles, identifying $s^k=\lambda^k+\beta Bz^k$ as the DR running iterate. **Partial** — exact for feasible test points, leaves surplus terms for infeasible ones. 18/40.
- **Route 3 (Direct Lagrangian saddle analysis)**: Work directly with the augmented Lagrangian; use subgradient inequalities + polarization + perfect-square absorption. **Selected winner**, 29/40.
- **Route 4 (Proximal-point in H-semi-norm)**: Factor into an abstract ergodic theorem for PSD semi-norms + ADMM-satisfies-hypothesis verification. **Valid but overcomplicated**, 25/40.

**Convergent finding**: all 4 routes independently identified that the originally-stated theorem was false for infeasible test points. The problem statement was amended mid-workflow to add $A\tilde x+B\tilde z=c$, matching the original He-Yuan 2012 formulation.

## 4. Final Proof

See `proof.md`.

Overview:
1. Derive the optimality conditions $(O_x)$ and $(O_z)$ from the ADMM subproblems.
2. Combine with subgradient inequality + the dual update to produce a per-step inequality on the gap function aligned to the lagged dual $\lambda^k$.
3. Apply three polarization identities (Dual-ID for the $\lambda$ cross-term, B-pol for the $Bz$ cross-term, Sq perfect-square absorption) to get
   $\widehat\Phi^{k+1}\le\mathcal E^k-\mathcal E^{k+1}-\tfrac\beta 2\|s^{k+1}\|^2+\beta\langle s^{k+1},d\rangle$
   where $\mathcal E^k=\tfrac{1}{2\beta}\|\tilde\lambda-\lambda^k\|^2+\tfrac\beta 2\|B(\tilde z-z^k)\|^2$ and $d=A\tilde x+B\tilde z-c$.
4. Under feasibility $d=0$, the cross term vanishes. Discard the nonnegative $-\tfrac\beta 2\|s^{k+1}\|^2$ term. Telescope.
5. Apply Jensen on $\theta=f+g$ (convexity) and linearity on the dual pairing to convert the average to the ergodic average.
6. Divide by $T$, expand the $H$-norm to get the stated constants.

## 5. Audit Result

**PASS round 1.** All 11 steps VALID. 7 numerical check families passed. Cross-verification CONSISTENT with sister results (full-rank ADMM, Chambolle-Pock). No HIGH/MEDIUM severity issues. Only LOW-severity readability nits.

## 6. Fix History

No fixes needed. Clean PASS on first audit round.
