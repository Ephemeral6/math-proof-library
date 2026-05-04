# Gap 2 Self-Audit Report

**Date:** 2026-04-29
**Subject:** Theorem 3 (Full-Class Last-Iterate UB) in `resolution_full_class.md`
**Auditor:** self-audit per user request

**Verdict:** **NEEDS_FIX** — Theorem 3 is empirically supported but the proof has a **fundamental gap** in Step 2-3. The asserted bound on the bias-induced residual $\mathcal R_{\text{bias}}$ is **too crude** (uses triangle inequality where signed-cancellation is essential). The theorem's rate claim is robust empirically; rigorously closing the proof requires non-trivial additional work.

---

## Audit 1 — Proof chain integrity

| Step | Content | Rigorous? | Gap? |
|:---:|---|:---:|---|
| **Step 1** | COV identity $w_{t+1} - w_t = -\nu g_t$ | ✓ PASS | None — verified by SymPy in `gap2_verify.py` (S4) and `verify_theorem_1.py` (V1). |
| **Step 2** | Liu-Zhou 2024 Theorem 3.1 transfer + bias-induced residual | ✗ **FAIL** | **Major**: the "Lemma 4.1 adapted" formula (eq line 47-49 of `resolution_full_class.md`) is asserted but not derived from Liu-Zhou's eq (5)-(11). The bias bound $\mathcal R_{\text{bias}} \le C_3 L\beta D^2 \eta T v_T \alpha_T/(1-\beta)^2$ (line 64) is conjectured. |
| **Step 3** | Bound on $f(w_{T+1})$ | ✗ FAIL (depends on Step 2) | The "third term" calculation at horizon-tuned $\eta$ uses the UN-DERIVED Step 2 bound. Even if accepted, line 75-76 has hand-wavy reasoning ("Actually the bias adds a term of order $LD^2/(\sqrt T (1-\beta))$, which is comparable to $LD^2/T$ for $\sqrt T \asymp 1$" — internally inconsistent). |
| **Step 4** | Bridge $f(y_T) \to f(w_T)$ via L-smoothness | ✓ PASS | Uses standard Cauchy-Schwarz; rate analysis is correct. |
| **Step 5** | Combine | ✓ Conditional PASS | Algebraically correct **assuming Steps 2-3 hold**. |

**Audit 1 Verdict:** Steps 1, 4, 5 are sound. **Steps 2 and 3 are critically incomplete.** The asserted form of $\mathcal R_{\text{bias}}$ is plausible by analogy but not derived.

---

## Audit 2 — The bias problem (CRITICAL)

### Setup recap

The COV gives $w_{t+1} - w_t = -\nu g_t$ where $g_t = \nabla f(y_t) + \xi_t$. So $w_t$ evolves by **biased SGD**:
$$w_{t+1} = w_t - \nu[\nabla f(z_t) + b_t + \xi_t], \qquad b_t := \nabla f(y_t) - \nabla f(z_t).$$
For Liu-Zhou Theorem 3.4 to apply directly, we need $E[g_t | F_{t-1}] = \nabla f(z_t)$ — UNBIASED SGD. We have $E[g_t | F_{t-1}] = \nabla f(y_t) = \nabla f(z_t) + b_t$ — biased.

### Numerical check (`audit_bias_check.py`)

We empirically computed both the **absolute** and **signed** cumulative bias contributions on $f(x) = x^2/2$ at horizon-tuned $\eta_T$:

$$R_{\text{bias}}^{\text{abs}} := \sum_{t=1}^T 2\nu_t |\langle b_t, w_t - x^\star\rangle| \quad\text{(triangle-style bound)}$$
$$R_{\text{bias}}^{\text{signed}} := \sum_{t=1}^T 2\nu_t \langle b_t, w_t - x^\star\rangle \quad\text{(actual descent contribution)}$$

| $\beta$ | $T$ | $R_{\text{bias}}^{\text{abs}}$ | $R_{\text{bias}}^{\text{signed}}$ | $\sigma D/\sqrt T$ | abs scaling |
|:---:|:---:|:---:|:---:|:---:|:---:|
| 0.5 | 100 | 0.246 | -0.020 | 0.100 | |
| 0.5 | 1000 | 0.126 | -0.002 | 0.032 | |
| 0.5 | 10000 | 0.064 | -0.0002 | 0.010 | $T^{-0.294}$ |
| 0.9 | 100 | 1.460 | -0.811 | 0.100 | |
| 0.9 | 1000 | 0.588 | -0.088 | 0.032 | |
| 0.9 | 10000 | 0.280 | -0.009 | 0.010 | $T^{-0.353}$ |

### Two key findings

**Finding 1: $R_{\text{bias}}^{\text{abs}}$ scales as $T^{-0.3}$, not $T^{-0.5}$.**

The triangle-inequality-bounded cumulative bias decays SLOWER than the LB rate. At $T = 10^4$:
- $\beta = 0.5$: $R_{\text{bias}}^{\text{abs}} = 6.4 \times \sigma D/\sqrt T$
- $\beta = 0.9$: $R_{\text{bias}}^{\text{abs}} = 28 \times \sigma D/\sqrt T$

If the proof bounds the bias contribution by $R_{\text{bias}}^{\text{abs}}$ (Cauchy-Schwarz / triangle), the resulting upper bound is **larger than the LB rate** for any non-trivial $\beta$. **This refutes the proof technique**, though not the theorem.

**Finding 2: $R_{\text{bias}}^{\text{signed}}$ is near-zero, with strong sign cancellation.**

The actual signed cumulative bias is essentially zero at large $T$: $-0.0002$ at $T = 10^4, \beta = 0.5$, vs. the rate target $0.01$. So the **actual bias contribution to the descent identity is much smaller** than what triangle-inequality bounds give.

This is consistent with the **structural sign of the bias** for quadratic $f(x) = (L/2)x^2$:
$$\langle b_t, w_t - x^\star\rangle = -L \cdot \langle a u_t, y_t + a u_t\rangle = -La \langle u_t, y_t\rangle - La^2 \|u_t\|^2,$$
where $u_t = y_t - y_{t-1}$. The second term is **always negative**; the first is signed but typically small in stationarity.

### Audit 2 Verdict

**FAIL — the proof in Step 2-3 has a fundamental gap.** The asserted $\mathcal R_{\text{bias}}$ bound (line 64 of `resolution_full_class.md`) is **plausible only via signed cancellation**, not via triangle inequality. The proof as written:
- Uses Cauchy-Schwarz/triangle to bound $\mathcal R_{\text{bias}}$ (implicit in line 60-61: "By Cauchy-Schwarz on $\mathcal R_{\text{bias}}$").
- This gives a $T^{-0.3}$-decaying error, which **does not** match the LB rate $T^{-0.5}$.

To rigorously close the gap, a correct proof would need to either:
- **(A)** Track the SIGNED $\langle b_t, w_t - x^\star\rangle$ explicitly through Liu-Zhou's eq (5)-(11), exploiting the structural sign $-L a (\dots)$. This is not just "tracking the bias"—it requires showing that the cumulative SIGNED bias is $o(\sigma D/\sqrt T)$, which empirically holds but is not standard.
- **(B)** Use a different proof approach entirely, e.g., direct Lyapunov on the $(y_t, m_t)$ state, OR Sebbouh-Gower-Defazio's stochastic-noise analysis, OR an SHB-specific PEP/SDP construction.

**The empirical evidence is overwhelming** (Audit 3 below) — the rate $T^{-0.5}$ is observed across 3 function classes × 3 momentum values. So the theorem's CLAIM is empirically supported. But the PROOF as written does not rigorously establish it.

---

## Audit 3 — Numerical verification credibility

### Setup of `verify_bridge.py`

- $T \in \{100, 300, 1000, 3000, 10000\}$ — 5 points, log-spread, sufficient for log-log slope fitting.
- $\beta \in \{0.0, 0.5, 0.9\}$ — sweep including high-momentum.
- 3 function classes: quadratic $(L/2)x^2$, smoothed Huber $\sqrt{1+x^2}-1$, regularized logistic $\log(1+e^{-x}) + (\epsilon/2)x^2$.
- $\sigma = 1$, $D = 1$, $L = 1$, trials $= 5000$.
- Stepsize: **horizon-tuned constant** $\eta_T = D(1-\beta)/(\sigma\sqrt T)$.

### Concerns

**Concern 1: Stepsize matches Theorem 3 setup, not Liu-Zhou Theorem 3.4.** Theorem 3 uses *constant* $\eta_T = D(1-\beta)/(\sigma\sqrt T)$. Liu-Zhou Theorem 3.4 (without log $T$) uses the *linearly-decaying* Zamani-Glineur schedule $\alpha_t = (T-t+1)/(\dots)$. So the numerical setup is consistent with Theorem 3's *statement* but **does not validate Liu-Zhou's specific schedule** — the numerical evidence is for our claimed rate, not Liu-Zhou's.

**Concern 2: Log-log fit goodness.** $R^2$ of the slope fit was not reported. With 5 points the fit is plausible but uncertainty bands are not given. Visual inspection of the ratio columns shows monotone increase in `f_y / target` (e.g., quadratic $\beta=0$: 0.241, 0.242, 0.248, 0.251, 0.258), consistent with a small (sub-log) factor not captured by pure $T^{-0.5}$. Could indicate:
- Hidden $\log T$ factor (but very small — only 7% growth from $T=10^2$ to $10^4$).
- Sub-asymptotic behavior.
- Statistical noise.

**Concern 3: $\beta = 0.9$ has $(1-\beta)^3 = 0.001$ in the proven UB.** With $LD^2/T \cdot 1000 = 1$ at $T=1000$ and $\sigma D/\sqrt T \cdot 10 = 0.32$, the proven UB is $\approx 1.32$. Empirical $f(y_T) \approx 0.018$ — UB is **75× loose** at $T=1000$. The proven $1/(1-\beta)^3$ factor is therefore **highly conservative** — empirical evidence suggests the true UB is $\beta$-independent or has a much weaker $\beta$-dependence.

**Concern 4: Range of $T$.** $T_{\max} = 10^4$. For asymptotic rate determination this is sufficient; for distinguishing $T^{-0.5}$ vs $T^{-0.5}\log T$ we'd want $T$ up to $10^6+$.

### Audit 3 Verdict

**PASS with concerns.** The numerical setup is sound for the stated theorem. The empirical rate $T^{-0.5}$ is robust. The setup does NOT directly validate Liu-Zhou's specific stepsize schedule (which is constant or Zamani-Glineur, not the horizon-tuned constant we tested). The proven $1/(1-\beta)^3$ factor in the UB is empirically much looser than tight — actual UB constants are $\beta$-near-independent.

---

## Audit 4 — $\beta$-dependence comparison vs OP-2 LB

### OP-2 LB constants (from `gap2_proof.md` and OP-2 v5)

OP-2 LB has constant $c_2 = \sqrt 2/27 \approx 0.052$ for the variance term $\sigma D/\sqrt T$. This constant is **$\beta$-independent** — see OP-2 v5 §4.2.

For the bias term $LD^2/T$, OP-2's lower-bound construction uses the Goujaud K=3 hard instance with bounded $\kappa$ (not $\beta$-dependent in a degrading way at $\beta \to 1$). OP-2's bias-term constant is $\kappa/4$ (or $\kappa/10$ in our Gap 1 corrected analysis), which depends on the hard instance's strong-convexity parameter $\kappa$ but not directly on $\beta$.

### Theorem 3 UB constants

- Variance: $C_2/(1-\beta)$
- Bias: $C_1/(1-\beta)^3$

### Comparison at extremes

| $\beta$ | UB/LB ratio (variance) | UB/LB ratio (bias) |
|:---:|:---:|:---:|
| 0.0 | $C_2/c_2 \approx 19$ | $C_1$ |
| 0.5 | $2 C_2/c_2 \approx 38$ | $8 C_1$ |
| 0.9 | $10 C_2/c_2 \approx 190$ | $1000 C_1$ |

But empirically the UB constants are **$\beta$-near-independent** (~0.25 across all tested $\beta$). So the *proven* $\beta$-dependence is artifact of the proof, not real.

### Audit 4 Verdict

**The $\beta$-poly factors $1/(1-\beta)^3$ and $1/(1-\beta)$ are looseness of the analysis, NOT true degradation.** Empirically the UB constants are nearly $\beta$-independent. A tight proof would give UB constants that match OP-2's LB constants up to absolute factors (not $\beta$-poly).

This is consistent with Concern 3 of Audit 3.

---

## Final verdict

### Summary

| Aspect | Status |
|:---:|:---:|
| **Theorem statement** (rate $T^{-0.5}$) | Empirically **CONFIRMED** |
| **Proof Step 1** (COV) | ✓ PASS |
| **Proof Step 2-3** (Liu-Zhou + bias) | ✗ **FAIL** (asserted bound; triangle bound on signed-canceling sum) |
| **Proof Step 4** (Bridge) | ✓ PASS |
| **Proof Step 5** (Combine) | ✓ Conditional PASS |
| **$\beta$-poly factors in UB** | Looseness of proof, not real |
| **Numerical verification** | PASS with concerns (Concerns 2-4) |

### Honest verdict: **NEEDS_FIX**

**Theorem 3 is empirically true but its proof in `resolution_full_class.md` is INCOMPLETE.** Specifically:

1. **Step 2's $\mathcal R_{\text{bias}}$ bound is asserted, not derived.** A naive Cauchy-Schwarz / triangle bound gives $T^{-0.3}$ decay, which does NOT match the LB rate $T^{-0.5}$. Numerical check: $R_{\text{bias}}^{\text{abs}} = 6$-$28 \times \sigma D/\sqrt T$ at $T = 10^4$, growing in $T$.

2. **The actual bias contribution has SIGNED cancellation** ($R_{\text{bias}}^{\text{signed}} \approx 0$ for large $T$), which the proof technique does not exploit. To make the proof work, one would need to track the signed cumulative bias and show it's $o(\sigma D/\sqrt T)$ — a non-trivial analysis.

3. **The proof's $\beta$-poly factors are loose.** Empirically the UB is nearly $\beta$-independent.

4. **Numerical evidence is strong** (9 independent rate measurements all consistent with $T^{-0.5}$), so the theorem CLAIM stands.

### What needs to happen

To upgrade Theorem 3 from "empirically supported, proof has gaps" to "rigorously proven":

**Option A (refine the proof):** Track the signed bias correlation through Liu-Zhou's analysis. The structural sign $\langle b_t, w_t - x^\star\rangle = -La \langle u_t, y_t\rangle - La^2 \|u_t\|^2$ for quadratic suggests the second term is always negative (helpful), and the first term has stationary expectation zero. Showing this rigorously requires careful conditional-expectation analysis, likely 5-15 pages.

**Option B (different approach):** Adapt Sebbouh-Gower-Defazio 2021's stochastic-noise analysis (which handles SHB directly without going through OGD on $z_t$). Their schedule is time-varying but their technique might transfer to fixed $\beta$ with horizon-tuned $\eta$.

**Option C (concede):** State Theorem 3 as a CONJECTURE supported by overwhelming empirical evidence, with the proof technique providing a heuristic argument. This is the honest current state.

### What this means for OP-2 v6

For a SIOPT/MP submission, the user's goal:
- The CONJECTURE Theorem 3 is publishable as "We empirically establish, and conjecture, that fixed-$\beta$ SHB at horizon-tuned $\eta_T$ achieves the optimal rate $O(LD^2/T + \sigma D/\sqrt T)$ on the full class, matching OP-2's LB."
- A FULL PROOF requires the technical work in Option A or B.
- Without a full proof, the SIOPT/MP submission is weaker than Li Xiao's standard ("would be a major upgrade").

### Recommendation

**Do NOT submit Theorem 3 as a proven theorem in OP-2 v6.** Instead:
- Keep the existing rigorous results: closed-form noise floor (Theorem A.1, gap2_proof.md), Cesàro tightness (Theorem 1, resolution.md), quadratic-class tightness (Theorem 2, resolution.md).
- State Theorem 3 as a conjecture with empirical support.
- Acknowledge in the discussion that the full proof for the L-smooth convex non-SC class with fixed $\beta$ and horizon-tuned $\eta$ remains open.

This is the honest and peer-review-defensible position.

$\blacksquare$

---

## Appendix: scripts and artifacts

- `audit_bias_check.py` — empirical computation of $R_{\text{bias}}^{\text{abs}}$ vs $R_{\text{bias}}^{\text{signed}}$
- `audit_bias_check_output.txt` — full output showing the $T^{-0.3}$ scaling of triangle-bounded bias

The audit tool reveals the gap: the cumulative absolute bias decays at $T^{-0.3}$ at $\beta = 0.5$ and $T^{-0.35}$ at $\beta = 0.9$, both **slower** than the target $T^{-0.5}$. The signed bias has cancellation that the proof technique doesn't exploit.
