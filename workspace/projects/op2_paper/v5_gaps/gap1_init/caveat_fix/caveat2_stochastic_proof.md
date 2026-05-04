# Caveat 2 — Rigorous stochastic gradient-floor theorem

**Goal.** The Gap 1 audit flagged that the cycling-bias lower bound under stochastic gradient noise was supported only by 800 empirical Monte-Carlo paths (Audit 3), not by a closed-form theorem. This document supplies a rigorous closed-form theorem, verified numerically, plus a tighter conditional version that recovers the cycling content under an empirical input on $\mathbb E[\|x_T\|^2]$.

**Source.** Verifier `caveat2_verify.py`, results in `caveat2_results.json`, raw output in `caveat2_output.txt`.

**Date.** 2026-04-29.

---

## 1. Setup

Let $f_0:\mathbb R^2\to\mathbb R$ be the **Goujaud K=3 polytope-Moreau function** (cf. [Goujaud–Taylor–Dieuleveut, *Provable non-accelerations of the heavy-ball method*, Math. Programming 2025]). $f_0$ is constructed to be:
- **$\mu$-strongly convex** with $\mu = \kappa L > 0$;
- **$L$-smooth**;
- with global minimum $f_0^* = 0$ at $x^* = 0$ (verified: the polytope $\widetilde P$ contains $0$ as an interior point by 3-fold symmetry).

Stochastic heavy-ball (SHB) iterates from arbitrary $(x_0, x_{-1})$ are
$$
x_{t+1} = x_t \;-\; \eta\bigl(\nabla f_0(x_t) + \sigma z_t\bigr) \;+\; \beta(x_t - x_{t-1}), \qquad z_t \overset{\text{iid}}{\sim}\mathcal N(0, I_2),\; \sigma\ge 0. \tag{SHB}
$$

Let $\mathcal F_t = \sigma(x_0, x_{-1}, z_0, \ldots, z_{t-1})$ be the natural filtration; $z_t \perp \mathcal F_t$.

---

## 2. The rigorous theorem (Route C + noise floor)

**Theorem 1 (Stochastic gradient-norm floor — fully rigorous).**
For SHB on the Goujaud K=3 function $f_0$ with $\sigma > 0$ and arbitrary initialization, for every $T\ge 1$:
$$
\boxed{\;\mathbb E\bigl[\|\nabla f_0(x_T)\|^2\bigr]\;\ge\; \mu^2\cdot\mathbb E\bigl[\|x_T\|^2\bigr]\;\ge\; 2\,\mu^2\eta^2\sigma^2\;>\;0.\;}
$$

### Proof

#### Step 1 (PL + strong convexity).

Since $f_0$ is $\mu$-strongly convex, the **Polyak–Łojasiewicz inequality** holds with constant $\mu$ ([Karimi–Nutini–Schmidt 2016]):
$$
\frac12\|\nabla f_0(x)\|^2 \;\ge\; \mu\bigl(f_0(x) - f_0^*\bigr). \tag{PL}
$$
The strong-convexity quadratic lower bound gives
$$
f_0(x) - f_0^* \;\ge\; \frac{\mu}{2}\|x - x^*\|^2 \;=\; \frac{\mu}{2}\|x\|^2. \tag{SC}
$$
Combining (PL) and (SC):
$$
\|\nabla f_0(x)\|^2 \;\ge\; 2\mu\bigl(f_0(x) - f_0^*\bigr) \;\ge\; \mu^2\|x\|^2. \tag{1}
$$

(1) holds **pointwise for all $x \in \mathbb R^2$**, not in expectation.

#### Step 2 (Conditional variance accumulation).

Write the SHB update in the form $x_T = m_T - \eta\sigma z_{T-1}$, where
$$
m_T \;=\; x_{T-1} - \eta\,\nabla f_0(x_{T-1}) + \beta(x_{T-1} - x_{T-2}).
$$
$m_T$ is $\mathcal F_{T-1}$-measurable, while $z_{T-1}\sim\mathcal N(0, I_2)$ is independent of $\mathcal F_{T-1}$. Therefore conditional on $\mathcal F_{T-1}$:
- $\mathbb E[x_T \mid \mathcal F_{T-1}] = m_T$,
- $\operatorname{Cov}(x_T \mid \mathcal F_{T-1}) = \eta^2\sigma^2 I_2$,
- $\mathbb E[\|x_T\|^2 \mid \mathcal F_{T-1}] = \|m_T\|^2 + \operatorname{tr}(\eta^2\sigma^2 I_2) = \|m_T\|^2 + 2\eta^2\sigma^2$.

Taking unconditional expectation:
$$
\mathbb E[\|x_T\|^2] \;=\; \mathbb E[\|m_T\|^2] \;+\; 2\eta^2\sigma^2 \;\ge\; 2\eta^2\sigma^2. \tag{2}
$$

#### Step 3 (Combine).

Take expectations of (1) and apply (2):
$$
\mathbb E[\|\nabla f_0(x_T)\|^2] \;\ge\; \mu^2\,\mathbb E[\|x_T\|^2] \;\ge\; \mu^2\cdot 2\eta^2\sigma^2 \;=\; 2\mu^2\eta^2\sigma^2.
$$
$\square$

### Comments on Theorem 1

1. **Fully rigorous.** No empirical input. Both inequalities use only standard textbook results ((PL) and (SC) for $\mu$-strongly convex $f_0$) and the basic conditional-variance identity for additive Gaussian noise.
2. **Vanishes as $\sigma\to 0$.** The bound is positive only when $\sigma > 0$; for $\sigma = 0$ it is vacuous (Theorem 1 says $\mathbb E[\|\nabla f_0\|^2]\ge 0$, which is trivial). The deterministic cycling content from Gap 1 is **not** captured by this theorem alone; see Theorem 2 below.
3. **Loose at small $\sigma$.** Empirically (Audit 3 and below), $\mathbb E[\|\nabla f_0(x_T)\|^2]$ is dominated by the deterministic cycle floor $\approx \mu^2\lambda^2 = \kappa^2 L^2 D^2/2$ when $\sigma$ is small. Theorem 1 gives only $2\mu^2\eta^2\sigma^2$, which is $\ll \mu^2\lambda^2$ when $\eta\sigma \ll \lambda$. To recover the cycle content, use Theorem 2.

---

## 3. The conditional theorem (recovers cycling content)

**Theorem 2 (Conditional gradient-norm floor).** Under the setup of Section 1, assume $\mathbb E[\|x_T\|^2] \ge \delta^2$ for some $\delta > 0$ (no further conditions on the noise). Then
$$
\mathbb E[\|\nabla f_0(x_T)\|^2] \;\ge\; \mu^2\delta^2.
$$

**Proof.** Take expectations of (1): $\mathbb E[\|\nabla f_0(x_T)\|^2] \ge \mu^2\,\mathbb E[\|x_T\|^2] \ge \mu^2\delta^2$. $\square$

The condition $\mathbb E[\|x_T\|^2]\ge \delta^2$ is the *only* empirical input needed. From Audit 3 (200 samples × T=10000):

| $\sigma$ | $\mathbb E[\|x_T\|]$ (Audit 3) | $\mathbb E[\|x_T\|^2]\ge(\mathbb E\|x_T\|)^2$ (Jensen) | $\mu^2\delta^2$ from Thm 2 |
|---|---|---|---|
| 0.01 | 0.656 | $\delta^2 \ge 0.430$ | $\ge 0.064$ |
| 0.10 | 0.868 | $\ge 0.753$ | $\ge 0.113$ |
| 0.50 | 3.717 | $\ge 13.82$ | $\ge 2.07$ |
| 1.00 | 6.989 | $\ge 48.85$ | $\ge 7.32$ |

These bounds are within $5\times$ of measured $\mathbb E[\|\nabla f_0\|^2]$ in Audit 3 — much tighter than Theorem 1.

**The empirical input has been transformed.** Previously the audit's empirical input was directly on the gradient quantity $\mathbb E[\|\nabla f\|^2]$. Theorem 2 transforms this to an empirical input on the simpler *iterate* quantity $\mathbb E[\|x_T\|^2]$, which is more interpretable ("the iterate does not collapse to 0") and easier to verify by direct measurement.

---

## 4. Numerical verification

Verifier: `caveat2_verify.py`, anchor $(\beta,\eta L,\kappa) = (0.8, 3.247, 0.387)$.

### V1. PL inequality on Goujaud $f_0$ (sanity check)

Sampled 20000 points $x \in [-3,3]^2$ uniformly. For each $x$:
- $\|\nabla f_0(x)\|^2 / \|x\|^2 \ge \mu^2 = 0.1498$:
  - **min over samples = 0.1841** $\ge$ 0.1498 ✓
- $(1/2)\|\nabla f_0(x)\|^2 / (f_0(x) - f_0^*) \ge \mu = 0.387$:
  - **min = 0.393** $\ge$ 0.387 ✓
- $(f_0(x) - f_0^*) / (\|x\|^2/2) \ge \mu$ (strong convexity):
  - **min = 0.467** $\ge$ 0.387 ✓

All three textbook inequalities hold with margin on the Goujaud K=3 function.

### V2, V3. Monte Carlo verification of Theorems 1 and 2

200 samples × T=10000 at the anchor; both theoretical lower bounds vs measured. Theoretical $2\eta^2 = 21.086$ and $2\mu^2\eta^2 = 3.158$.

| $\sigma$ | Thm 1 LB $\mathbb E[\|x_T\|^2]$ | Measured | Thm 1 LB $\mathbb E[\|\nabla f_0\|^2]$ | Measured | V2 | V3 | tight $\|x\|^2$ | tight $\|\nabla f\|^2$ |
|---|---|---|---|---|---|---|---|---|
| 0.010 | 0.0021 | 0.4522 | 0.00032 | 0.3106 | ✓ | ✓ | 214.5× | 983.4× |
| 0.100 | 0.2109 | 0.9005 | 0.03158 | 0.3595 | ✓ | ✓ | 4.3× | 11.4× |
| 0.500 | 5.2715 | 16.8099 | 0.7895 | 3.3549 | ✓ | ✓ | 3.2× | 4.2× |
| 1.000 | 21.086 | 60.6953 | 3.158 | 10.5678 | ✓ | ✓ | 2.9× | 3.3× |

**Pattern.** The Theorem 1 bound is *very* loose at small $\sigma$ (1000× loose at $\sigma=0.01$ — because the deterministic cycle floor $\mu^2\lambda^2 = 0.075$ dominates) and *moderately* loose at large $\sigma$ (3× loose at $\sigma=1$ — because the noise term is dominant and the linearized variance amplification by $1/(1-\beta^3)$ is missing). Theorem 2 with empirical $\mathbb E[\|x_T\|^2]$ closes most of this gap (giving e.g. $\mu^2\cdot 0.4522 = 0.0677$ at $\sigma=0.01$, only $4.6\times$ loose vs measured $0.3106$).

### V4. $\sigma\to 0$ limit (deterministic)

- Measured deterministic $\|x_T\|^2 = 0.5000 = \lambda^2$ exactly (cycle radius).
- Measured deterministic $\|\nabla f_0(x_T)\|^2 = 0.3471$ (the cycle's gradient floor).
- Theorem 1 LBs both vanish: $2\eta^2\sigma^2 \to 0$ and $2\mu^2\eta^2\sigma^2 \to 0$.

Theorem 1 is **vacuous** at $\sigma = 0$. The deterministic cycling content from Gap 1 is *not* captured. The conditional Theorem 2, on the other hand, gives the right answer: $\mathbb E[\|\nabla f_0\|^2] \ge \mu^2\cdot 0.5 = 0.075$ — within $4.6\times$ of measured $0.347$. So Theorem 2 inherits Gap 1's cycling content directly.

---

## 5. Verdict

**FIX SUPPLIED, with one identified gap on the cycling-stochastic interaction.**

### What was upgraded

The audit's "stochastic robustness is empirical only" caveat is partially closed:

1. **A fully rigorous theorem.** $\mathbb E[\|\nabla f_0(x_T)\|^2] \ge 2\mu^2\eta^2\sigma^2$ for all $T \ge 1$, $\sigma > 0$, with **no empirical input**. This is positive whenever the stochastic noise is non-trivial. (Theorem 1.)

2. **A conditional theorem.** $\mathbb E[\|\nabla f_0(x_T)\|^2] \ge \mu^2 \mathbb E[\|x_T\|^2]$ — fully rigorous, with the empirical input transformed from $\mathbb E[\|\nabla f\|^2]$ to the more interpretable $\mathbb E[\|x_T\|^2]$. (Theorem 2.)

3. **Empirical verification of the chain.** All inequalities hold numerically with the predicted ordering $\text{Thm 1 LB} \le \mu^2 \mathbb E[\|x\|^2] \le \mathbb E[\|\nabla f\|^2]$ across $\sigma\in\{0.01, 0.1, 0.5, 1.0\}$.

### What remains conditional

A *tight* rigorous bound that captures both deterministic cycling and stochastic noise — i.e.,
$$
\mathbb E[\|x_T\|^2] \;\ge\; \lambda^2 + 2\eta^2\sigma^2 - O(\eta^2\sigma^2/(1-\beta^3))
$$
— would require a Foster–Lyapunov-type argument tracking the noise propagation around the deterministic cycle. We did not attempt this; the empirical input from Audit 3 (which gives $\mathbb E[\|x_T\|^2] \approx \lambda^2 + O(\eta^2\sigma^2)$) closes this gap empirically.

### Summary table

| Statement | Status |
|---|---|
| $f_0$ is $\mu$-strongly convex | textbook (Goujaud construction) |
| $\|\nabla f_0(x)\|^2 \ge \mu^2\|x\|^2$ pointwise | textbook (PL + SC) |
| $\mathbb E[\|x_T\|^2] \ge 2\eta^2\sigma^2$ | rigorous (this document) |
| $\mathbb E[\|\nabla f_0(x_T)\|^2] \ge 2\mu^2\eta^2\sigma^2$ | **Theorem 1, rigorous** |
| $\mathbb E[\|\nabla f_0(x_T)\|^2] \ge \mu^2\mathbb E[\|x_T\|^2]$ | **Theorem 2, rigorous** |
| $\mathbb E[\|\nabla f_0(x_T)\|^2] \ge \mu^2(\lambda^2 + 2\eta^2\sigma^2)$ | empirical (cycling content) |
| Foster–Lyapunov bound capturing both | future work |

---

## Sources

- B. Goujaud, A. Taylor, A. Dieuleveut. *Provable non-accelerations of the heavy-ball method.* Math. Programming, 2025. [Springer](https://link.springer.com/article/10.1007/s10107-025-02269-2).
- H. Karimi, J. Nutini, M. Schmidt. *Linear Convergence of Gradient and Proximal-Gradient Methods Under the Polyak-Łojasiewicz Condition.* ICML 2016. [arXiv:1608.04636](https://arxiv.org/pdf/1608.04636).

## Files

- `caveat2_verify.py` — verification script.
- `caveat2_output.txt` — raw stdout.
- `caveat2_results.json` — structured results.
- `caveat2_stochastic_proof.md` — this report.
