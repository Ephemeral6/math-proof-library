# 8.5 — SHB Implicit Bias on Underdetermined Linear Regression

**Date:** 2026-04-26
**Status:** NEGATIVE (clean) — SHB on linear regression converges to $x_\mathrm{MN}$, no cycling.

## Verdict

**SHB on underdetermined linear regression with $x_0 = x_{-1} = 0$ converges to the minimum-norm solution $x_\mathrm{MN} = A^\dagger b$.** Same implicit bias as gradient descent. No cycling, no implicit-bias deviation.

## Mechanism: row-space invariance

**Lemma.** For $f(x) = \frac{1}{2}\|Ax - b\|^2$ with $x_{-1} = x_0 = 0$, the SHB iterate $x_t \in \mathrm{range}(A^\top)$ for all $t \ge 0$.

*Proof.* Induction. Base: $0 \in \mathrm{range}(A^\top)$. Step: $\nabla f(x_t) = A^\top(Ax_t - b) \in \mathrm{range}(A^\top)$, and the SHB update is a linear combination of $x_t, x_{t-1}, \nabla f(x_t)$, all in $\mathrm{range}(A^\top)$. $\square$

**Corollary.** Restricted to $\mathrm{range}(A^\top)$, $f$ is $\sigma_\min(A)^2$-strongly-convex (for full-row-rank $A$). Standard SHB convergence on smooth strongly convex objectives yields geometric convergence to the unique minimizer of $f|_{\mathrm{range}(A^\top)}$, which is $x_\mathrm{MN}$.

## Why cycling does not manifest

OP-2's hard instance $f^{(s)}(x, y) = f_0(x) + \alpha_s y + w(y)$ has cycling because:
1. $f$ has a flat direction (the $y$-coord with $w''(y) = 0$ on $|y| < R$).
2. The dynamics enter that flat region (since $y_0 = 0$ is inside).

On linear regression, the flat directions are $\mathrm{null}(A)$, but the row-space invariant prevents the trajectory from ever reaching them. **Cycling needs flat directions that are reachable from the trajectory.**

## Cesàro average

Since $x_t \to x_\mathrm{MN}$ geometrically, $\bar x_T \to x_\mathrm{MN}$ as well (Cesàro mean of a convergent sequence). No averaging-induced deviation.

## Open variant: adding null-space drift

To recover cycling on a regression-like problem, one must explicitly break the row-space invariant by:
- Adding a null-space linear tilt $\langle\alpha_s, P_\mathrm{null} x\rangle$ (re-encodes OP-2's hard instance), or
- Initializing $x_0$ with a null-space component.

Adding a *purely null-space* convex regularizer $w(P_\mathrm{null} x)$ does NOT break the invariant by itself: $\nabla w(0) = 0$ keeps the gradient in $\mathrm{range}(A^\top)$.

## Take-away

**Linear regression is a "structural limit" of OP-2's framework.** SHB cycling requires flat directions that are *dynamically reachable*, not just present in the function class. Overparameterized linear regression with standard zero initialization does not satisfy reachability. SHB inherits GD's implicit bias intact.
