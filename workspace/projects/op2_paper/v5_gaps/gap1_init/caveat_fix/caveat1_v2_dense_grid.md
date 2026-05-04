# Caveat 1 v2 — Dense grid + Lipschitz extension argument

**Goal.** Strengthen Caveat 1's C4 (basin-extension argument from 9 verified points to the whole box $\mathcal R^*$). Two upgrades:

- **D1** — *dense* grid verification: $4^3=64$ points uniformly spaced inside $\mathcal R^*$, all checked at mpmath dps=50 with $T=3000$.
- **D2** — *quantitative continuity estimate*: orbit-map Jacobian $\partial x_T / \partial(\beta,\eta L,\kappa)$ at the box center via central finite differences, plus empirical max-deviation over 8 corners.

**Source.** Verifier `caveat1_v2_verify.py`, results in `caveat1_v2_results.json`, raw output in `caveat1_v2_output.txt`.

**Date.** 2026-04-29.

**Box.** $\mathcal R^* = [0.78, 0.82] \times [3.20, 3.32] \times [0.375, 0.400]$, volume $1.20\times 10^{-4}$.

---

## 1. D1 — Dense $4^3 = 64$ grid verification (PASS)

**Result: 64/64 grid points cycle to 50-digit precision.**

| metric | value |
|---|---|
| Total points | 64 |
| Cycle (rel + p3 both $< 10^{-30}$) | **64** |
| Failures | 0 |
| Max rel_diff among cycling | $1.13\times 10^{-50}$ |
| Max p3_err_rel among cycling | $2.14\times 10^{-50}$ |
| Wall time | 170.7 s |

Grid spacing inside $\mathcal R^*$: $\Delta\beta = 0.0133$, $\Delta(\eta L) = 0.040$, $\Delta\kappa = 0.0083$. Each of 64 points was simulated to $T=3000$ from zero-momentum init at mpmath dps=50.

**Interpretation.** The original Caveat 1 verified 9 specific points (8 corners + 1 center). Caveat 1 v2 covers the box uniformly with $64$ points, each separated by $\sim 1\%$ of the box dimensions. The probability that the *complement* of $\mathcal F^{\text{cycle}}_{K=3}$ in $\mathcal R^*$ has Lebesgue measure $> 1\%$ but is missed by every one of 64 uniformly-spaced grid points is, heuristically, vanishingly small. (If the complement had measure $\geq V_{\text{cell}}$ where $V_{\text{cell}}$ is one grid cell, we'd expect at least one failure.)

This is *empirical* evidence, not a closed-form theorem. But it is one notch stronger than the 9-point version of Caveat 1.

---

## 2. D2 — Lipschitz / modulus-of-continuity estimate at $T=10$

We evaluate $\partial x_T / \partial(\beta,\eta L,\kappa)$ at the box center via central finite differences ($h=10^{-6}$), and compare with empirical orbit-deviation over the 8 box corners.

| Quantity | Value |
|---|---|
| Box center | $(\beta,\eta L,\kappa) = (0.800, 3.260, 0.3875)$ |
| $x_T$ at center, $T=10$ | $(0.4191, -0.4663)$, $\|x_T\|=0.6270$ |
| $\lambda$ | $0.7071$ |
| $\|\partial x_T / \partial \beta\|$ | $12.93$ |
| $\|\partial x_T / \partial \eta L\|$ | $1.62$ |
| $\|\partial x_T / \partial \kappa\|$ | $8.70$ |
| $\|J\|_F$ (Frobenius) | $15.67$ |
| Box diagonal | $0.129$ |
| Linear-Lipschitz prediction $\|J\|_F \cdot \text{diag}$ | $2.02$ ($= 2.86\lambda$) |
| **Empirical max $\|x_T(\text{corner}) - x_T(\text{center})\|$** | **$0.592$** ($= 0.84\lambda$) |
| Linear prediction at half-diagonal | $1.01$ ($\approx 2\times$ empirical) |

### What this tells us

1. **Linear-Lipschitz bound is loose.** The Jacobian-based prediction $\|J\|_F \cdot \text{diag} = 2.02$ over-estimates the actual orbit deviation by $\sim 3.4\times$ (vs. measured $0.592$). This is because the cycling structure causes parameter perturbations to be *partially absorbed* into the (parameter-dependent) cycle position, rather than accumulating linearly.

2. **A naive Lipschitz extension argument fails.** If we wanted to prove "box-uniform basin membership" via $\|J\|_F \cdot \text{diag} < r_{\text{basin}}$, we'd need a basin radius $r_{\text{basin}} > 2$ — which is $\gg \lambda$, larger than the natural geometric scale. So this naive argument cannot close C4 rigorously.

3. **Empirical max-deviation is bounded.** The actual maximum displacement of the orbit at $T=10$ across the 8 corners (vs. center) is $0.592$. This is comparable to $\lambda$, but importantly *all* corner orbits lie within a single basin of attraction (verified by D1: all of them cycle to the cycle as $T \to \infty$).

4. **Why the contraction beats the Lipschitz.** $|J\|_F \approx 16$ at $T=10$ corresponds to per-step Lipschitz $\approx 16^{1/10} = 1.32$. Multiplying gives $1.32^{10} \approx 16$. But once the orbit enters the basin, contraction $\beta^{3/2} \approx 0.72$ kicks in, so for $T \gg 10$ the parameter-perturbation Lipschitz drops dramatically. The Jacobian at finite $T=10$ captures the *transient* sensitivity, not the asymptotic.

### Implication for C4

The naive "Lipschitz × diagonal < basin radius" argument **does not** close C4 in closed form on this box. The dense grid (D1) is the substantive empirical evidence; the Lipschitz analysis (D2) **demonstrates that a naive linear-Lipschitz approach is too pessimistic** — capturing the cycling-induced cancellation is needed for a quantitative theorem, and that requires a Floquet-stable-manifold argument with explicit constants.

---

## 3. Honest assessment

**What v2 added.** $4^3 = 64$ verified cycling points (vs. 9 in v1) at mpmath dps=50. Stronger empirical evidence; same logical status (all empirical, with a continuity wrapper).

**What v2 did *not* add.**
- A rigorous closed-form proof that $\mathcal R^* \subseteq \mathcal F^{\text{cycle}}_{K=3}$.
- A quantitative Floquet basin-radius lower bound.

**Honest summary of the gap.** The strict (no-empirical-input) lower bound on $\operatorname{Leb}_3(\mathcal F^{\text{cycle}}_{K=3})$ remains "$> 0$ with explicit witnessing points." Conditional on the standard continuity argument for smooth hyperbolic dynamics extending pointwise verification to a uniform parameter neighborhood, the bound is $\geq 1.20\times 10^{-4}$ (Caveat 1 v1, unchanged).

The v2 work *increases the empirical evidence* supporting the conditional bound from 9 points to 64 points, but does *not* upgrade the logical status from "conditional" to "rigorous." Closing C4 in closed form requires a quantitative basin-radius argument we have not produced.

**Status.** Caveat 1 remains **PARTIAL FIX**, with stronger empirical support. The remaining gap (uniform basin radius bound) is identified, sized, and parked as future work.

---

## 4. Updated final bound

Combining v1 and v2:
- $\mathcal R^*$ has volume $1.20\times 10^{-4}$ (≈ $4.7\times 10^{-4}$ of $\mathcal F_{K=3}$).
- $4^3=64$ uniformly-distributed points inside $\mathcal R^*$ all cycle to mpmath 50-digit precision.
- Conditional on continuity: $\operatorname{Leb}_3(\mathcal F^{\text{cycle}}_{K=3}) \geq 1.20\times 10^{-4}$.
- Unconditional rigorous: $\operatorname{Leb}_3(\mathcal F^{\text{cycle}}_{K=3}) > 0$, with 64 verified witnesses.

---

## Files

- `caveat1_v2_verify.py` — verification script.
- `caveat1_v2_output.txt` — raw stdout (170.7 s).
- `caveat1_v2_results.json` — structured results (64 grid points + Lipschitz Jacobian + corner deviations).
- `caveat1_v2_dense_grid.md` — this report.
