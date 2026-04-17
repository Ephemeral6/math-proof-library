# Proof Report: SGD with Stochastic Polyak Step-size Convergence

## 1. Problem Statement

Consider the stochastic optimization problem $\min_x f(x) = \mathbb{E}[f_i(x)]$ where each $f_i$ is convex, $L$-smooth, and the problem is interpolation-consistent ($f_i(x^*) = 0$ for all $i$). With the Stochastic Polyak Step-size $\gamma_k = \frac{f_{i_k}(x_k)}{c \|\nabla f_{i_k}(x_k)\|^2}$, $c \geq 1$, prove the convergence rate for the average iterate $\bar{x}_T$.

**Source**: Loizou, Vaswani, Laradji, Lacoste-Julien (2021), AISTATS 2021.
**Difficulty**: advanced

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 3 routes proposed (Descent+Telescope, Lyapunov, Regret-OGD) |
| Explorer | Opus | 3 proofs attempted; all achieved $2cL/T$ (not $cL/(2T)$) |
| Judge | Sonnet | Route 1 selected (score 21/40, most correct and honest) |
| Audit | Opus | PASS — 7/7 steps VALID, 0 INVALID |
| Fix | — | Not needed |

## 3. Proof Routes Explored

**Route 1 (Descent Lemma + Telescoping Sum)**: Squared distance recursion → convexity + interpolation → SPS substitution → L-smoothness lower bound on γ_k → telescope. Achieves $2cL/T$. Selected as best.

**Route 2 (Lyapunov / Squared Distance)**: Same core structure as Route 1. Claimed to achieve $cL/(2T)$ but contained arithmetic error ($2cL/T \neq cL/(2T)$). Actually achieves $2cL/T$.

**Route 3 (Regret-Style OGD)**: Same telescoping idea reframed as online learning regret. Achieves tighter $2c^2L/((2c-1)T)$ but this is worse than $2cL/T$ for $c \geq 1$. Partial failure.

## 4. Final Proof

**Theorem.** Under the stated assumptions, SGD with SPS satisfies:

$$\mathbb{E}[f(\bar{x}_T)] \leq \frac{2cL \|x_0 - x^*\|^2}{T}$$

**Proof.** The SGD update $x_{k+1} = x_k - \gamma_k \nabla f_{i_k}(x_k)$ with $\gamma_k = \frac{f_{i_k}(x_k)}{c\|\nabla f_{i_k}(x_k)\|^2}$ gives:

$$\|x_{k+1} - x^*\|^2 = \|x_k - x^*\|^2 - 2\gamma_k \langle \nabla f_{i_k}(x_k), x_k - x^*\rangle + \gamma_k^2 \|\nabla f_{i_k}(x_k)\|^2$$

By convexity + interpolation: $\langle \nabla f_{i_k}(x_k), x_k - x^*\rangle \geq f_{i_k}(x_k)$.

By SPS substitution: $\gamma_k^2\|\nabla f_{i_k}\|^2 = \gamma_k f_{i_k}/c$.

Combined: $\|x_{k+1}-x^*\|^2 \leq \|x_k-x^*\|^2 - \gamma_k f_{i_k}(x_k)(2-1/c) \leq \|x_k-x^*\|^2 - \gamma_k f_{i_k}(x_k)$.

By $L$-smoothness + interpolation: $\|\nabla f_i\|^2 \leq 2Lf_i$, so $\gamma_k \geq 1/(2cL)$.

Therefore: $f_{i_k}(x_k)/(2cL) \leq \|x_k-x^*\|^2 - \|x_{k+1}-x^*\|^2$.

Summing, taking expectations ($\mathbb{E}_{i_k}[f_{i_k}(x_k)] = f(x_k)$), telescoping:

$$\frac{1}{2cL}\sum_{k=0}^{T-1}\mathbb{E}[f(x_k)] \leq \|x_0-x^*\|^2$$

By Jensen's inequality: $\mathbb{E}[f(\bar{x}_T)] \leq \frac{1}{T}\sum \mathbb{E}[f(x_k)] \leq \frac{2cL\|x_0-x^*\|^2}{T}$. **Q.E.D.**

## 5. Audit Result

**PASS** — All 7 steps verified (4 symbolically/numerically, 3 by logical review). 0 invalid steps. Medium-priority notes: interpolation assumption strength and implicit non-negativity of $f_i$.

## 6. Fix History

No fixes needed — audit passed on first round.

## 7. Note on Constants

The target bound $cL\|x_0-x^*\|^2/(2T)$ is tighter than the proven $2cL\|x_0-x^*\|^2/T$ by a factor of 4. The $2cL/T$ bound is tight for the standard proof technique (equality achieved by quadratics). The tighter constant may reflect a different $L$-smoothness convention or additional structural conditions in the original paper.
