# SHB Polyak-Ruppert κ²-Blow-Up on Strongly Convex Quadratics

## Source
- Internal Proposer Rank 1 (2026-04-27); empirical evidence A-6 in `workspace/proposer/anomalies.md` and `workspace/proposer/results/b1_2_iterates.csv` — CoV=0.002 across 30 seeds at $\beta=0.9, \eta L=2.9, \kappa=100$, observed PR/last ratio ≈ 1.33×10^6 ≈ κ^{2.94}.
- Companion to / dual of Problem I5 (`proofs/research/optimization/convergence/polyak-ruppert-shb-defeats-cycling/`), which proved PR averaging *defeats* SHB cycling on Goujaud's hard instance.

## Setting
Let $f(x) = \frac{L}{2}x_1^2 + \frac{\mu}{2}x_2^2$ be a 2D strongly convex quadratic with condition number $\kappa = L/\mu \ge 1$.

Run deterministic SHB with fixed momentum $\beta \in [0,1)$, fixed step size $\eta > 0$, and initialization $x_0 = x_{-1} = (1,1)$:
$$x_{t+1} = x_t - \eta\nabla f(x_t) + \beta(x_t - x_{t-1}).$$

Define the linearly-weighted Polyak-Ruppert average
$$\tilde x_T = \frac{\sum_{t=0}^{T-1}(t+1)x_t}{\sum_{t=0}^{T-1}(t+1)} = \frac{2}{T(T+1)}\sum_{t=0}^{T-1}(t+1)x_t.$$

Restrict attention to the **under-damped regime**, where $(\beta, \eta)$ is such that the SHB characteristic polynomial $z^2 - (1+\beta-\eta\lambda)z + \beta = 0$ has complex roots for both $\lambda \in \{L, \mu\}$, i.e., the discriminant $(1+\beta-\eta\lambda)^2 - 4\beta < 0$ for both eigenvalues. The user's empirical setting $(\beta=0.9, \eta L = 2.9, \kappa = 100)$ lies in this regime.

## Statement to prove

**Part A (last-iterate UB)**: There exists a constant $C_1 = C_1(\beta, \eta, L, \mu)$ such that for all $T \ge 0$,
$$f(x_T) \le C_1 \cdot \beta^T \cdot f(x_0).$$
(Spectral radius of the SHB iteration matrix equals $\sqrt\beta$ in the under-damped regime, so $|x_t|^2$ decays as $\beta^t$ and $f(x_t)$ as $\beta^t$.)

**Part B (PR-average LB)**: There exist constants $C_2, T_0 > 0$ such that for all $T \ge T_0$,
$$f(\tilde x_T) \ge C_2 \cdot \frac{\kappa}{T^4 \eta^2 L},$$
i.e., the PR average satisfies a polynomial-in-$T$ lower bound that is amplified by the condition number $\kappa$.

(Sketch of mechanism: $|\tilde x_{T,\lambda}| \ge c\sqrt\beta/(\eta\lambda \cdot T^2)$ via the geometric-series identity $|1 - z|^2 = \eta\lambda$ for the SHB roots, which gives $\sum_{\lambda}(\lambda/2)\tilde x_{T,\lambda}^2 \asymp \beta(1/L+1/\mu)/(\eta^2 T^4) \asymp \beta\kappa/(\eta^2 L T^4)$.)

**Part C (ratio characterization)**: Determine precisely the $\kappa$-exponent of the ratio $f(\tilde x_T)/f(x_T)$:

(i) For fixed $T$ in the regime where Part A is tight (i.e., $T \gtrsim T_0$ and $\beta^T$ is not yet at machine precision): 
$$\frac{f(\tilde x_T)}{f(x_T)} \asymp \frac{\kappa\,\beta^{-T}}{T^4 \eta^2 L^2}.$$

(ii) At the **crossover** $T^\star = T^\star(\kappa)$ defined by $\beta^{T^\star} \asymp 1/T^{\star 4}$ (i.e., $T^\star = O(\log T^\star/\log(1/\beta)) = O(1/(1-\beta) \cdot \log\kappa)$): 
$$\frac{f(\tilde x_{T^\star})}{f(x_{T^\star})} \asymp \kappa^c$$
for some explicit $c \in [1, 3]$ to be determined by the proof.

(iii) Honest scope-restriction: state the exact $T$-window where the empirical $\kappa^{2.94}$ exponent is observed (likely either at the crossover $T^\star(\kappa)$ or at $T$ where $f(x_T)$ has dropped to the machine-precision floor $\sim 10^{-16}$).

## ⚠️ Honest-scope alert (from orchestrator)

The user's literal claim of $\Theta(\kappa^2)$ may not hold uniformly in $T$. A back-of-envelope calculation (using the spectral identity $|1-z|^2 = \eta\lambda$ for SHB roots in the under-damped regime) gives $f(\tilde x_T) \asymp \kappa/T^4$ — **linear in $\kappa$**, not $\kappa^2$.

The empirical $\kappa^{2.94}$ exponent likely arises from one of:
- (a) Evaluating the ratio at $T$ where $f(x_T)$ has hit machine precision $\sim 10^{-16}$ (for $\beta=0.9$ this happens near $T=350$);
- (b) A non-trivial $T$-dependent crossover where the ratio's $T$-dependence couples with $\kappa$;
- (c) The linearly-weighted PR sum having a sharper $T$-window structure than the asymptotic $\sum_{t=0}^\infty t z^t$ limit.

The proof must:
1. **First numerically verify** the empirical claim at multiple $T$ values to determine the genuine $\kappa$-scaling and the $T$-regime where it holds.
2. If literal $\Theta(\kappa^2)$ does NOT hold uniformly, prove the **strongest honest variant**.
3. State the result with explicit $T$-window restriction.

## Required output

A self-contained proof of:
- (A) the spectral-radius-based last-iterate UB with explicit $C_1$;
- (B) the PR-average LB $f(\tilde x_T) \ge C_2 \kappa/(T^4 \eta^2 L)$ with explicit $C_2$ via the closed-form $\sum_t t z^t$ identity;
- (C) the ratio characterization with the exact $\kappa$-exponent and the exact $T$-window where the κ-amplification is observable.

## Difficulty

Research. Closed-form spectral algebra throughout; the genuine challenge is the honest scope of Part C and tracking the $T$-dependence of constants.
