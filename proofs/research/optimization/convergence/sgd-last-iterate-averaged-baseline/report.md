# Proof Report: SGD Last-Iterate Convergence Rate (COLT 2020 Open Problem)

## 1. Problem Statement

Consider SGD on a convex Lipschitz function $f$ over a bounded domain $W = [a,b] \subset \mathbb{R}$ ($d=1$):

$$x_{t+1} = \Pi_W(x_t - \eta_t g_t)$$

where $g_t$ is an unbiased stochastic subgradient with $\mathbb{E}[\|g_t\|^2] \leq G^2$.

**Conjecture (Koren & Segal, COLT 2020):** The tight rate for the last iterate is $\Theta(1/\sqrt{T})$.

**Goal:** Prove or disprove: for $d=1$, $\mathbb{E}[f(x_T) - f^*] = O(1/\sqrt{T})$.

## 2. Phase Summary

| Phase | Model | Result |
|-------|-------|--------|
| Scout | Sonnet | 5 routes proposed |
| Explorer | Opus (×5 parallel) | 5 proofs attempted; all proved averaged-iterate O(1/√T); none proved last-iterate |
| Judge | Sonnet | Route 3 selected (Martingale, score: 24/40) |
| Audit | Opus | PASS (1 round, all 7 steps VALID) |
| Fix | — | Not needed |

## 3. Proof Routes Explored

| Route | Approach | Result | Key Insight |
|-------|----------|--------|-------------|
| 1: Constant η | Direct last-iterate via Markov chain | Averaged iterate O(1/√T) | Mixing time is Θ(T), so chain barely mixes |
| 2: Two-Phase | Phase 1 explore + Phase 2 constant | Phase 2 average O(1/√T) | Two-phase adds complexity without delivering last-iterate |
| 3: Martingale ★ | Decompose noise as martingale | Averaged iterate O(1/√T) | Martingale E[M_T]=0 cleanly eliminates noise cross-terms |
| 4: Suffix Avg | Suffix average + concentration | Suffix average O(1/√T), but x_T fails | x_T has O(D) spread around average — does not concentrate |
| 5: Lyapunov | Track V_t = E[(x_t-x*)²] | Averaged iterate O(1/√T) | Without strong convexity, no contraction on V_t |

**Critical Finding:** All 5 routes independently converge to the same conclusion — the averaged iterate achieves O(1/√T) with constant step size η = D/(G√T), but the last-iterate O(1/√T) cannot be proved by these techniques. This is consistent with the problem being open.

## 4. Final Proof

**Theorem.** For SGD on a convex, $G$-Lipschitz function $f$ over $W = [a, b] \subset \mathbb{R}$ with $D = b - a$, using constant step size $\eta = D/(G\sqrt{T})$, the averaged iterate $\bar{x}_T = (1/T)\sum_{t=1}^{T} x_t$ satisfies:

$$\mathbb{E}[f(\bar{x}_T) - f^*] \leq \frac{DG}{\sqrt{T}} = O\!\left(\frac{1}{\sqrt{T}}\right).$$

**Proof.**

**Step 1 (Setup).** Let $W = [a, b]$, $D = b-a$, $x^* \in \arg\min_W f$, $\eta = D/(G\sqrt{T})$.

**Step 2 (Decomposition).** Write $g_t = s_t + \xi_t$ where $s_t \in \partial f(x_t)$, $\mathbb{E}[\xi_t \mid \mathcal{F}_t] = 0$, $\mathbb{E}[g_t^2 \mid \mathcal{F}_t] \leq G^2$.

**Step 3 (Projection descent).** By non-expansiveness of $\Pi_W$ with $x^* \in W$:

$$(x_{t+1} - x^*)^2 \leq (x_t - x^*)^2 - 2\eta g_t(x_t - x^*) + \eta^2 g_t^2$$

**Step 4 (Martingale).** $Z_t = -2\eta \xi_t(x_t - x^*)$ satisfies $\mathbb{E}[Z_t \mid \mathcal{F}_t] = 0$, so $M_T = \sum Z_t$ is a martingale with $\mathbb{E}[M_T] = 0$.

**Step 5 (Telescope + convexity).** Summing Step 3, taking expectations, using $\mathbb{E}[M_T]=0$, $(x_{T+1}-x^*)^2 \geq 0$, $(x_1-x^*)^2 \leq D^2$, and the subgradient inequality $s_t(x_t - x^*) \geq f(x_t) - f^*$:

$$2\eta \sum_{t=1}^T \mathbb{E}[f(x_t) - f^*] \leq D^2 + \eta^2 T G^2$$

**Step 6 (Jensen).** By convexity: $\mathbb{E}[f(\bar{x}_T) - f^*] \leq \frac{D^2}{2\eta T} + \frac{\eta G^2}{2}$.

**Step 7 (Optimize).** $\eta = D/(G\sqrt{T})$ yields $\frac{D^2}{2\eta T} = \frac{DG}{2\sqrt{T}}$ and $\frac{\eta G^2}{2} = \frac{DG}{2\sqrt{T}}$. Therefore:

$$\boxed{\mathbb{E}[f(\bar{x}_T) - f^*] \leq \frac{DG}{\sqrt{T}}.} \qquad \blacksquare$$

## 5. Audit Result

**PASS.** All 7 steps VALID. 6 numerical checks passed. All constants traceable. Only LOW-severity issues (notation imprecision in Step 2, implicit initialization in Step 1).

## 6. Fix History

No fixes needed.

## 7. Discussion: Why the Last-Iterate Problem Remains Open

The five exploration routes collectively identified three fundamental barriers to proving last-iterate $O(1/\sqrt{T})$ for general convex Lipschitz functions:

### Barrier 1: No contraction without strong convexity
The Lyapunov recurrence $V_{t+1} \leq V_t - 2\eta(f(x_t) - f^*) + \eta^2 G^2$ cannot be turned into a contraction $V_{t+1} \leq (1-\alpha)V_t + \beta$ because $f(x_t) - f^*$ cannot be lower-bounded by $c \cdot V_t$ without a growth condition on $f$ near $x^*$. (Route 5)

### Barrier 2: No concentration of last iterate around average
With constant step size $\eta = D/(G\sqrt{T})$, the iterates execute a bounded random walk with $O(D)$ spread. The last iterate $x_T$ does not concentrate around the average $\bar{x}_T$ at rate better than $O(D)$. (Route 4)

### Barrier 3: Slow Markov chain mixing
The SGD iterates with constant step size form a Markov chain on $[a,b]$ with mixing time $\Theta(T)$, so at time $T$ the chain has barely mixed — the stationary distribution guarantee does not help. (Route 1)

### What would be needed
A proof of last-iterate $O(1/\sqrt{T})$ would require a fundamentally new technique beyond the standard Lyapunov/telescoping/martingale framework — possibly exploiting:
- The $d=1$ structure more deeply (e.g., order statistics of the iterates)
- A non-standard potential function that tracks something other than distance to $x^*$
- A coupling argument between the SGD chain and a reference process
- A step size schedule with non-monotone or problem-adaptive structure

The partial result (averaged iterate $O(1/\sqrt{T})$) is optimal and the proof is complete.
