# AdaGrad complexity improvement over SGD in non-convex optimization

## Source
- Conjecture from COLT 2025
- Difficulty: conjecture (open-problem-level)
- Branch: optimization/adaptive-methods

## Setting

Let $f: \mathbb{R}^d \to \mathbb{R}$ be $L$-smooth with $f(x_0) - \inf f = \Delta_0$. Let the stochastic gradient oracle satisfy $\mathbb{E}[\xi_t]=0$ and $\mathbb{E}[\|\xi_t\|^2] \le \sigma^2$ (variance bound). The stochastic gradient at step $t$ is $g_t = \nabla f(x_t) + \xi_t$.

Consider **coordinate-wise AdaGrad**:
$$
x_{t+1,i} = x_{t,i} - \eta \cdot \frac{g_{t,i}}{\sqrt{v_{t,i}}}, \qquad v_{t,i} = v_{t-1,i} + g_{t,i}^2 \quad (i = 1, \dots, d).
$$
Initialize $v_{0,i} > 0$ as needed (constant or $\epsilon^2$).

## Claims

### (A) UPPER BOUND
There exists a choice of step-size $\eta$ (possibly depending on $L, \Delta_0, \sigma, d, T$) such that
$$
\min_{t \le T} \mathbb{E}\bigl[\|\nabla f(x_t)\|^2\bigr] \le O\!\left(\frac{(d \sigma^2 L \Delta_0)^{1/3}}{T^{2/3}}\right).
$$
This is **strictly better** than SGD's classical rate $O\!\left(\sigma \sqrt{L \Delta_0 / T}\right)$ whenever $d = o(\sigma^2 T / (L \Delta_0))$.

(Equivalently, the sample complexity to reach $\mathbb{E}[\|\nabla f\|^2] \le \varepsilon^2$ is $O((d\sigma^2 L\Delta_0)^{1/2} / \varepsilon^3)$ for AdaGrad vs. $O(\sigma^2 L\Delta_0 / \varepsilon^4)$ for SGD.)

### (B) LOWER BOUND
There exists an $L$-smooth function $f$ and stochastic oracle satisfying the variance bound such that any algorithm using **coordinate-wise adaptive step sizes** (i.e., the next iterate's $i$-th coordinate is a function only of past $i$-th-coordinate gradient information) requires at least
$$
\Omega\!\left(\frac{(d \sigma^2 L \Delta_0)^{1/2}}{\varepsilon^{3/2}}\right) \quad \text{queries to reach}\quad \mathbb{E}[\|\nabla f(x)\|^2] \le \varepsilon.
$$
(This matches Part A up to constants and shows that the $d^{1/3}/T^{2/3}$ scaling is tight in this oracle model.)

## Difficulty
- **conjecture** (open-problem-level): launch 6 Explorer frames with forced divergence

## Knowledge Reuse System (Layers 1-5) — instructions

The Explorer agents MUST consult and report back on:
1. **Layer 1 (strategy_index.md)**: existing AdaGrad-Norm and adaptive-methods signatures
2. **Layer 2 (failure_triggers.md)**: known failure modes for AdaGrad / coordinate-wise adaptive proofs (in particular legacy `AdaGrad-Norm O(log T/√T) Route 3` and `Route 4` failures, which are recorded)
3. **Layer 3 (proofs/fragments/)**: candidate fragments for self-bounding sums, Cauchy-Schwarz over coordinates, descent lemma applications
4. **Layer 4 (structure_map.md)**: structural cousins — AdaGrad-Norm, Adam, AMSGrad, SHB lower bounds (for Le Cam machinery in Part B)
5. **Layer 5 (meta_templates.md)**:
   - Part A (UB) candidates: MT1 (cancellation pair), MT2 (exp supermartingale), MT8 (per-coordinate algebraic identity)
   - Part B (LB) candidates: MT5 (adversarial polytope construction) or MT6 (Le Cam two-point testing)

The Hooks Report at the end of each Explorer's output is mandatory.

## Expected technical highlights

- **UB**: a per-coordinate self-bounding sum identity is the central trick. The classical AdaGrad-Norm sum $\sum_t g_t^2 / \sqrt{V_t} = O(\sqrt{V_T})$ generalizes per-coordinate to $\sum_t g_{t,i}^2 / \sqrt{v_{t,i}} = O(\sqrt{v_{T,i}})$. Then Cauchy-Schwarz over coordinates: $\sum_i \sqrt{v_{T,i}} \le \sqrt{d \sum_i v_{T,i}} = \sqrt{d (\sum_t \|g_t\|^2)}$. The AM-GM optimization of $\eta$ over $T$ yields the $T^{-2/3}$ rate.

- **LB**: a $d$-dimensional indistinguishability construction — orthogonal "needle" coordinates with gradient noise, where any coordinate-wise adaptive algorithm cannot distinguish the signal coordinate from the $d-1$ noise coordinates. The Le Cam two-point reduction (MT6) gives the $\sqrt{d}/\varepsilon^{3/2}$ scaling.
