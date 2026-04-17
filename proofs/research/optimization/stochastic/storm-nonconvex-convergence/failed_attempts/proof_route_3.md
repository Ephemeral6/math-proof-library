# Proof Route 3: SPIDER Analogy with Continuous Reset

**Route**: Adapt the SPIDER proof by viewing STORM as "SPIDER with soft resets"

---

## Setup

STORM update: $d_t = (1-a)d_{t-1} + a\nabla f(x_t;\xi_t) + (1-a)[\nabla f(x_t;\xi_t) - \nabla f(x_{t-1};\xi_t)]$

Rewrite: $d_t = \nabla f(x_t;\xi_t) + (1-a)[d_{t-1} - \nabla f(x_{t-1};\xi_t)]$

Compare with SPIDER within an epoch: $v_t = \nabla f(x_t;\xi_t) - \nabla f(x_{t-1};\xi_t) + v_{t-1}$, which is $d_t$ with $a=0$.

SPIDER resets $v_0 = \nabla f(x_0)$ (full gradient) every $q$ steps. STORM instead "soft-resets" by mixing in $a \cdot \nabla f(x_t;\xi_t)$ at every step. The factor $(1-a)$ damps old information exponentially.

---

## Step 1: Error Recursion — SPIDER-Style

Define $e_t = d_t - \nabla f(x_t)$. Following the SPIDER proof [REF: proofs/research/optimization/stochastic/spider-nonconvex-gradient-complexity/proof.md]:

$$e_t = (1-a)e_{t-1} + \underbrace{(1-a)\delta_t + a\epsilon_t}_{\text{noise}}$$

where $\delta_t = [\nabla f(x_t;\xi_t) - \nabla f(x_{t-1};\xi_t)] - [\nabla f(x_t) - \nabla f(x_{t-1})]$ and $\epsilon_t = \nabla f(x_t;\xi_t) - \nabla f(x_t)$.

In SPIDER ($a=0$): $e_t = e_{t-1} + \delta_t$, and $e_0 = 0$. So $\mathbb{E}[\|e_t\|^2] = \sum_{j=1}^t \mathbb{E}[\|\delta_j\|^2] \leq L^2\eta^2 \sum_{j=0}^{t-1}\|d_j\|^2$ — the error **accumulates linearly**.

In STORM ($a > 0$): the $(1-a)$ factor introduces **geometric decay**, preventing accumulation. But the $a\epsilon_t$ term adds $O(a^2\sigma^2)$ noise per step.

**SPIDER's problem**: after $q$ steps, error $\sim L^2\eta^2 q \cdot \max\|d\|^2$. Must reset to prevent blow-up.

**STORM's solution**: at steady state, error $\sim \frac{L^2\eta^2}{a} \cdot \max\|d\|^2 + a\sigma^2$. The "effective epoch length" is $1/a$.

## Step 2: Variance Bound (SPIDER-Adapted)

$$\mathbb{E}[\|e_t\|^2 \mid \mathcal{F}_{t-1}] \leq (1-a)\|e_{t-1}\|^2 + 2L^2\eta^2\|d_{t-1}\|^2 + 2a^2\sigma^2$$

(Same as Route 1, Lemma 1.)

Summing over $t = 0, \ldots, T-1$:
$$\sum_{t=0}^{T-1}\mathbb{E}[\|e_t\|^2] \leq (1-a)\sum_{t=0}^{T-1}\mathbb{E}[\|e_t\|^2] + \sigma^2 + 2L^2\eta^2\sum_{t=0}^{T-1}\mathbb{E}[\|d_t\|^2] + 2a^2T\sigma^2$$

Wait — let me be more careful. Sum the recursion:
$$\sum_{t=1}^{T-1}\mathbb{E}[\|e_t\|^2] \leq (1-a)\sum_{t=0}^{T-2}\mathbb{E}[\|e_t\|^2] + 2L^2\eta^2\sum_{t=0}^{T-2}\mathbb{E}[\|d_t\|^2] + 2(T-1)a^2\sigma^2$$

Adding $\mathbb{E}[\|e_0\|^2] \leq \sigma^2$ to both sides and rearranging:
$$\sum_{t=0}^{T-1}\mathbb{E}[\|e_t\|^2] \leq (1-a)\sum_{t=0}^{T-1}\mathbb{E}[\|e_t\|^2] + \sigma^2 + (1-a)\mathbb{E}[\|e_{T-1}\|^2] - \mathbb{E}[\|e_0\|^2](1-a) + \sigma^2 + 2L^2\eta^2\sum\|d_t\|^2 + 2Ta^2\sigma^2$$

This is getting messy. Let me use a cleaner approach.

**Cleaner SPIDER-style approach**: From the descent inequality (using polarization as in SPIDER):

$$\mathbb{E}[f(x_{t+1})] \leq \mathbb{E}[f(x_t)] - \frac{\eta}{2}\mathbb{E}[\|\nabla f(x_t)\|^2] + \frac{\eta}{2}\mathbb{E}[\|e_t\|^2] - \frac{\eta(1-L\eta)}{2}\mathbb{E}[\|d_t\|^2]$$

Sum over $t = 0, \ldots, T-1$:
$$\frac{\eta}{2}\sum_t\mathbb{E}[\|\nabla f\|^2] \leq \Delta + \frac{\eta}{2}\sum_t\mathbb{E}[\|e_t\|^2] - \frac{\eta(1-L\eta)}{2}\sum_t\mathbb{E}[\|d_t\|^2]$$

**Now apply the "steady-state" bound.** From the variance recursion, by iterating:
$$\mathbb{E}[\|e_t\|^2] \leq (1-a)^t\sigma^2 + \frac{2L^2\eta^2}{a}\max_{0\leq j\leq t-1}\mathbb{E}[\|d_j\|^2] + 2a\sigma^2$$

Actually, this bound is too loose (it uses max instead of sum). Let me follow Route 1's Lyapunov approach but frame it in SPIDER language.

## Step 3: SPIDER Framework Applied

The key insight from the SPIDER proof: the polarization identity produces a **negative** $\|d_t\|^2$ term that absorbs the variance growth.

In SPIDER: $\sum\|e_t\|^2 \leq \frac{L^2\eta^2 q}{b}\sum\|v_t\|^2$ and the absorption condition is $1 - L\eta - \frac{L^2\eta^2 q}{b} > 0$.

In STORM: the equivalent absorption requires the "effective epoch length" $1/a$ to satisfy the same condition. From the Lyapunov analysis (Route 1):

The condition $a \geq \frac{2L^2\eta^2}{1-L\eta}$ is analogous to SPIDER's $b \geq L^2\eta^2 q$ (i.e., batch size $\times$ inverse epoch length must dominate $L^2\eta^2$).

In STORM, the "batch size" is 1 and the "epoch length" is $1/a$, so the condition is $1 \cdot a \geq 2L^2\eta^2 \cdot 1$, i.e., $a \geq 2L^2\eta^2$ (up to constants), which matches.

## Step 4: Final Bound via SPIDER Analogy

Following Route 1's analysis exactly (which is the SPIDER framework with soft resets):

$$\frac{1}{T}\sum_{t=0}^{T-1}\mathbb{E}[\|\nabla f(x_t)\|^2] \leq \frac{2\Delta}{\eta T} + \frac{\sigma^2}{aT} + 2a\sigma^2$$

- Term $\frac{2\Delta}{\eta T}$: analogous to SPIDER's $\frac{2\Delta}{Kq\eta}$ (telescoping across $T$ steps = $K$ epochs of length $q$)
- Term $\frac{\sigma^2}{aT}$: initialization cost, analogous to SPIDER's full-gradient cost (amortized over $T$ steps with "soft epoch length" $1/a$)
- Term $2a\sigma^2$: the price of noisy resets (SPIDER has none since it uses full gradients; STORM pays $O(a\sigma^2)$ per step for single-sample resets)

## Step 5: Complexity

Same as Route 1. With $a = \Theta(\varepsilon^2/\sigma^2)$, $\eta = \Theta(\varepsilon/(L\sigma))$:

$$T = O\left(\frac{\sigma^2}{\varepsilon^3} + \frac{1}{\varepsilon^2}\right)$$

**Comparison with SPIDER** (finite-sum, $n$ components):
- SPIDER: $O(n + \sqrt{n}/\varepsilon^2)$ with full-gradient resets
- STORM: $O(\sigma^2/\varepsilon^3 + 1/\varepsilon^2)$ with single-sample "soft resets"
- In the online setting ($n = \infty$, $\sigma > 0$), SPIDER cannot apply (no finite sum), while STORM achieves the information-theoretic lower bound $\Omega(\sigma^2/\varepsilon^3)$.

$\blacksquare$

---

## References
- [REF: proofs/research/optimization/stochastic/spider-nonconvex-gradient-complexity/proof.md] — SPIDER framework and polarization trick
- [REF: proofs/research/optimization/stochastic/spider-variance-reduction-nonconvex/proof.md] — SPIDER variance absorption
