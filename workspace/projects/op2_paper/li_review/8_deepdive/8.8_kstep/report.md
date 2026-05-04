# 8.8 — k-step Memory Methods

**Date:** 2026-04-26
**Status:** PASS (with one open step) — k-step cycling identity derived in clean closed form; $\mathcal{F}^{(2)}$ verified non-empty numerically.

## Headline result

**The OP-2 cycling phenomenon generalizes verbatim to k-step memory methods.** The $k$-step cycling identity has clean closed form:
$$\boxed{\eta\,\nabla f(e_t) = (I - R)\Bigl[I - \sum_{j=1}^{k}\beta_j R^{-j}\Bigr] e_t,}$$
and the corresponding Goujaud-style polytope generator is
$$\boxed{M^{(k)} = \frac{(1-\mu\eta+\beta_1)I - R - \sum_{j=1}^{k-1}(\beta_j-\beta_{j+1})R^{-j} - \beta_k R^{-k}}{(L-\mu)\eta}.}$$
$M^{(k)}$ commutes with $R = R_{\theta_K}$ (polynomial in $R$), so the polytope is rotation-invariant exactly as in OP-2 Lemma 1.3.

## $k = 1$ reduction sanity

$M^{(1)} = \frac{(1+\beta_1-\mu\eta)I - R - \beta_1 R^{-1}}{(L-\mu)\eta}$ — identical to OP-2's (M-def). Numerical residual: $3.1 \times 10^{-16}$.

## $k = 2$ numerical verification

Four configurations, $T = 1000$, max iterate-cycle error:

| $(\beta_1, \beta_2)$ | $K$ | $\eta$ | $\kappa$ | Max err |
|---|---|---|---|---|
| (0.7, 0.2) | 4 | 3.0 | 0.001 | $7.5 \times 10^{-14}$ |
| (0.8, 0.1) | 3 | 3.0 | 0.05 | $3.1 \times 10^{-15}$ |
| (0.6, 0.2) | 6 | 3.0 | 0.01 | $7.7 \times 10^{-15}$ |
| (0.9, -0.1) | 4 | 2.0 | 0.01 | $7.4 \times 10^{-15}$ |

**All cycle to machine precision.** All are Schur-stable. $\mathcal{F}^{(2)}$ contains a positive-measure 2-D wedge in $(\eta, \kappa)$.

## Acceleration conjecture (d)

**Conjecture (8.8-d):** *No fixed-coefficient k-step gradient-at-iterate method accelerates on smooth convex non-SC.*

Heuristic argument:
1. Cycling extends to all $k \ge 1$ (proved §a-c).
2. $\mathcal{F}^{(k-1)} \times \{0\} \subseteq \mathcal{F}^{(k)}$ — extra memory cannot help.
3. **LTI argument:** On a quadratic, fixed-coefficient k-step iteration is a stationary linear filter with characteristic polynomial $p(z)$ independent of $t$. The convergence rate is $\rho < 1$ (Schur-stable) — but acceleration requires $\rho \to 1 - O(1/T)$ effectively, which a fixed polynomial cannot deliver. Stationary linear filters cannot reproduce Nesterov's $1 - O(\sqrt{\mu/L})$ rate when $\mu = 0$.

## Connection to Nesterov (f)

Nesterov NAG has two features distinguishing it from (kSHB):
1. Time-varying $\beta_t = (t-1)/(t+2)$.
2. **Lookahead**: gradient evaluated at $y_t = x_t + \beta_t(x_t - x_{t-1}) \neq x_t$.

The (kSHB) family has neither. Hypothesis: **acceleration requires either time-varying coefficients OR lookahead** — fixed-coefficient gradient-at-iterate methods cannot accelerate, regardless of memory $k$.

## What's proven vs. conjectural

- **Proven:** k-step cycling identity (a); $M^{(k)}$ formula (b); polytope rotation invariance; $k=1$ reduction.
- **Numerical evidence:** $\mathcal{F}^{(2)}$ non-empty on grid; cycling at machine precision in 4/4 configs.
- **Conjectural with strong heuristic:** Conjecture (d) — full $\Omega(LD^2/T)$ for any fixed-coefficient k-step method.
- **Open step:** Closed-form analog of (★) at general $k$, characterizing $\mathcal{F}^{(k)}$ explicitly. Reduces to a quadratic in $\eta L$ with coefficients polynomial in $(\beta_1, \ldots, \beta_k, \kappa, \cos\theta_K)$.

## Bottom line

**The k=1 → k=2 generalization of OP-2 is algebraically clean and numerically robust.** A full k-step lower-bound theorem is a feasible follow-up (~ 1-2 person-month), reducing OP-2's machinery transplant to deriving the closed-form analog of (★) at $k=2$. **No counterexample to non-acceleration was found.**

This is the **highest-value direction** in the deep-dive — a generalization to all stationary first-order methods would significantly strengthen OP-2's contribution.
