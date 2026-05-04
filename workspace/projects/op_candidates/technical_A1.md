# Technical Assessment: A1 — Adam Last-Iterate Lower Bound

**Date**: 2026-04-28

---

## 1. Which Technique Fits?

### Ranking by fit

| Technique | Fit score | Notes |
|-----------|-----------|-------|
| Le Cam two-point (as in OP-2) | 7/10 | Works for SGD-class methods; adapts cleanly to smooth convex setting |
| Cycling / hard-instance construction (Goujaud-Taylor-Dieuleveut style) | 5/10 | **Major obstruction**: v_t normalization breaks standard cycling recurrence (see §3) |
| Oracle-restriction (Arjevani-Carmon-Duchi-Foster-Srebro-Woodworth) | 4/10 | Designed for general first-order methods, not algorithm-specific |
| Minimax / hypothesis testing | 7/10 | Natural for stochastic convex; pairs with Le Cam |
| IQC/PEP (Integral Quadratic Constraints) | 3/10 | PEP is primarily for deterministic/UB proofs; stochastic LB needs different tools |
| Descent-lemma-telescope (for UB, not LB) | 1/10 | Wrong direction |

**Recommended primary route**: **Le Cam two-point test on a stochastic smooth convex instance**, adapted from OP-2's variance term proof. This is the natural vehicle for Ω(σD/√T) last-iterate lower bounds.

**Secondary route**: **Bias-variance hard instance** — construct an explicit 1D function where Adam's EMA normalization creates a persistent bias in the last iterate. Analogous to the AdaGrad-Norm construction in 2604.10728.

---

## 2. Reusable Components from Existing Toolbox

### Directly reusable (high confidence)

**`shb-cycling-critical-momentum/`** — NOT directly reusable for Adam LB, but:
- The polynomial algebra toolkit (Lemma 1: factorization identity) is reusable for analyzing adaptive recurrences.
- The critical-threshold analysis structure (reducing feasibility to a 1D inequality) is a template.

**`shb-no-acceleration-best-iterate/` (OP-2 lineage)**:
- **Le Cam two-point framework**: The test function pairing $\{f_+, f_-\}$ with $f_\pm(x) = \frac{L}{2}(x \mp s)^2$ directly adapts. For Adam, the key question is whether the $v_t$ EMA distinguishes $f_+$ from $f_-$ — it likely cannot if the noise structure is symmetric.
- **Initialization trick**: Starting on-cycle or at $x_0 = 0$ to eliminate transient behavior.
- **Rademacher oracle construction**: The $\xi_k = \pm \sigma$ noise in OP-2's variance proof works identically for Adam's stochastic oracle.

**`adagrad-norm-last-iterate-lb/`**:
- The "constant gradient + trivial lower bound" observation: $\mu = c\sigma/N^{1/4}$ gives a trivial $\Omega(\sigma^2/\sqrt{N})$ LB for AdaGrad-Norm. The **same construction applied to Adam** would give the identical trivial lower bound, because Adam with small signal reduces to a noise-dominated random walk with $v_t \asymp \sigma^2$ (EMA of constant squared noise).
- This is a **quick win**: the trivial LB $\Omega(\sigma^2/\sqrt{T})$ for Adam last iterate in smooth convex is likely straightforward by direct transplant.

**`shb-interpolation-regime-lb/`**:
- The interpolation-regime technique (variance term via martingale argument) is directly analogous to what's needed for Adam.

### Partially reusable (needs adaptation)

**`shb-pr-average-kappa-blowup/`** and **`shb-pr-cesaro-kappa-separation/`**:
- Cesaro/average vs last-iterate separation structure is useful for showing Adam's last-iterate is strictly worse than its average — this is the analog of the gap shown for AdaGrad-Norm in 2604.10728.

---

## 3. What Needs New Development

### Critical new challenge: v_t EMA in cycling construction

The core difficulty for an **Adam-specific** (vs. general SGD) lower bound is that Adam normalizes by $\hat{v}_t^{1/2}$ where:
$$v_t = \beta_2 v_{t-1} + (1-\beta_2) g_t^2, \quad \hat{v}_t = v_t / (1 - \beta_2^t)$$

In OP-2's cycling construction, the hard instance works because the gradient at the cycle vertex has magnitude $\Theta(LD)$, and SHB's fixed step size amplifies the bias. For Adam:
- **Normalization kills cycling**: At any cycle vertex, $g_t \approx Lx_t$, so $v_t^{1/2} \approx L|x_t|$, and Adam's effective step is $\eta/(v_t^{1/2}) \approx \eta/(L|x_t|)$. This is a **self-normalizing step** that adapts to the gradient magnitude.
- Consequence: Adam's iterates on a quadratic function contract toward the optimum at a rate that **does not depend on L in the same way**, making the OP-2 cycling lemma's recurrence invalid.
- **Key open sub-problem**: Does there exist a deterministic convex smooth function on which Adam cycles (in the large-$T$ limit) with a constant-magnitude orbit? Or does Adam always contract to the optimum in the deterministic smooth convex setting?

If Adam always contracts deterministically, then the lower bound must come purely from the **stochastic variance term** (Le Cam route), not from cycling. This is fundamentally different from SHB.

### What to develop from scratch

1. **Adam stochastic perturbation lemma**: For the Le Cam test on $f_\pm(x) = \frac{L}{2}(x \mp s)^2$ with $s = \sigma D/\sqrt{T}$, prove that Adam's last iterate $x_T$ satisfies $\Pr[\text{sgn}(x_T) \neq \text{sgn}(s)] \geq c$ for some constant $c > 0$. This requires analyzing the EMA in the presence of stochastic noise.

2. **EMA bias computation**: Show that $\mathbb{E}[x_T] = \Theta(s) \cdot \text{(decay factor)}$ where the decay factor accounts for $\beta_1, \beta_2$. The bias term for Adam is more complex than for SGD due to bias correction in $\hat{v}_t$.

3. **v_t concentration around $\sigma^2$**: In the noise-dominated regime, $v_t \approx (1-\beta_2^t)\sigma^2/(1-\beta_2)$, so $\hat{v}_t \to \sigma^2/(1-\beta_2)$ is essentially deterministic. This **simplification** is the key: in the noise-dominated regime, Adam effectively reduces to SGD with step $\eta(1-\beta_2)^{1/2}/\sigma$, and the Le Cam argument goes through identically to OP-2.

4. **Separation from averaged iterate**: To produce a result analogous to 2604.10728 (showing last iterate is provably slower than average), need a 1D construction showing Adam's last iterate is $\Omega(1/\sqrt{T})$ while its average can achieve $O(1/\sqrt{T})$ or better. This would be a **novel contribution** not directly in the toolbox.

---

## 4. SymPy/mpmath Numerical Verification Feasibility

**YES — straightforward.**

- The noise-dominated regime ($v_t \approx \sigma^2$ deterministic) allows direct simulation of Adam's 1D iteration as a scalar recurrence.
- Standard mpmath precision (50 decimal digits) sufficient to verify that $\mathbb{E}[x_T^2] \geq c \sigma^2 / T$ for concrete $\beta_1, \beta_2$ choices.
- Monte Carlo verification: $N=10^4$ samples, $T \in \{100, 1000, 10000\}$, plotting $\mathbb{E}[f(x_T) - f^*]$ vs $T$ on log-log scale. Rate $-1/2$ slope confirms $\Omega(\sigma^2/\sqrt{T})$.
- The AdaGrad-Norm verify script pattern (already in the toolbox) requires only minor modifications.

**Estimated coding time**: 30–60 minutes for a definitive numerical check.

---

## 5. Route Priority Summary

| Route | Difficulty | Novelty | Toolbox reuse | Recommended |
|-------|-----------|---------|--------------|-------------|
| Le Cam + noise-dominated v_t reduction | Medium | Medium | HIGH (OP-2 + AdaGrad-Norm LB) | **YES — primary** |
| Explicit bias hard instance (trivial LB) | Low | Low | HIGH | YES — quick warm-up |
| Last-iterate vs average-iterate separation | Medium-High | HIGH | Medium (SHB Cesaro) | YES — main contribution |
| Cycling-based Adam-specific LB | Very High | HIGH | LOW (v_t breaks it) | RISKY — secondary only |
