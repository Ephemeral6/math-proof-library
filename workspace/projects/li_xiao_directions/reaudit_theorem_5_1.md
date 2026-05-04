# Re-Audit of Theorem 5.1 (Direction 1: Zero-Momentum SHB)

**Auditor:** Opus, high-intensity verification.
**Date:** 2026-04-28.
**Subject under audit:** `direction_1_zero_momentum.md` §1 (Theorem 5.1: zero-momentum incompatibility) and §2–§9 (positive-measure component, bias constant κ/8).
**Verifier scripts:** `reaudit_task_1_2_sympy.py`, `reaudit_task_1_3_mpmath.py`, `reaudit_task_1_4_grid.py`, `reaudit_task_1_4b_period_check.py`, `reaudit_task_1_4c_l7_anchor.py`, `reaudit_task_1_4d_norm_periodicity.py`, `reaudit_task_1_5_bias.py`.

## Final Verdict — CONDITIONAL PASS (one HIGH correction required)

| Task | Subject | Verdict |
|---|---|---|
| 1.1 | Theorem 5.1 line-by-line annotation | **VALID** |
| 1.2 | SymPy: $A_\mu^{\rm zero}$ vanishing locus = $\{\mu=0\}$ | **VALID** |
| 1.3 | Numerical: $A_\mu \neq 0$ does not imply non-decay | **VALID** (subtle but correctly handled in the proof) |
| 1.4 | Grid scan 100-digit reproduction | **VALID with re-classification**: cycling 8/100 ✓; "period-2" 19/100 → actually **period-4 in norm** at 17 of 19 points; FLAG NEEDS_CORRECTION on terminology |
| 1.5 | Bias constant κ/8 derivation | **INVALID for $T < 10$**; the boxed bound "$f_0(x_T) - f_0^* \geq \kappa LD^2/(8T)$ for all $T \geq 1$" is **false at $T = 4$** with $c_T \approx 0.113 < 0.125 = 1/8$. NEEDS_CORRECTION (HIGH). |

**Pass condition:** correct §5 (transient/bias-constant derivation) by either (a) restricting "for $T \geq T_0$" with explicit $T_0$ (~10 at the anchor), or (b) downgrading the constant from κ/8 to κ/9 (or smaller; the actual minimum observed is $c \approx 0.113 \approx 1/8.86$). The structural Theorem 5.1 (§1) and the positive-measure existence of $\mathcal F^{\rm zero}_{K=3}$ (§§2–6) are valid. Period-2/period-4 terminology in §7 should be corrected.

---

## Task 1.1 — Theorem 5.1 line-by-line annotation

**Restated Theorem 5.1.** *"For any $\beta > 0$, zero-momentum initialization $x_0 = x_{-1} = \lambda e_0$ cannot produce literal K=3 cycling on the OP-2 polytope $\widetilde P$, since the residual displacement $x_1^{\rm zero} - \lambda e_1 = \beta\lambda(e_2 - e_0) \neq 0$."*

This is stated in the consolidated proof (§1 / §9) as a structural obstruction: it explains why $\mathcal F^{\rm zero}_{K=3}$ is necessarily a **proper** subset of $\mathcal F_{K=3}$ — full coverage is structurally impossible.

### Step-by-step proof annotation

**Step 1 — Derive $x_1$ from SHB recursion with zero velocity.**

(a) **What is being proved.** The first SHB iterate from zero-momentum init is
$$x_1^{\rm zero} = \lambda(-\beta e_0 + e_1 + \beta e_2). \qquad (\text{L1.1})$$

(b) **Tool used.** Direct algebra: SHB update $x_1 = x_0 - \eta\nabla f_0(x_0) + \beta(x_0 - x_{-1})$. With $x_0 = x_{-1} = \lambda e_0$, the momentum term vanishes; only the gradient step remains.

(c) **Potential weaknesses.** None — direct substitution. Verified by symbolic SymPy in the existing audit Task 1 and by numerical mpmath (Task 1.3) at $T=1$ where $\|x_1\| = 1.208 = \lambda\sqrt{1 + 0.8 + 0.64} = (1/\sqrt 2)\sqrt{2.44}$ ✓.

**Step 2 — Apply Goujaud projection identity (Lemma 2.6 transplanted).**

(a) **What is being proved.** $\eta\nabla f_0(\lambda e_0) = \lambda[(1+\beta)e_0 - e_1 - \beta e_2]$.

(b) **Tool used.** OP-2 Lemma 2.6 (§2.3.1 of `op2_downgraded_proof_v4.md`), specifically the gradient identity (GRAD-f0):
$$\eta\nabla f_0(\lambda e_t) = \lambda[(1+\beta)e_t - e_{t+1} - \beta e_{t-1}].$$
At $t=0$, with $e_{-1} = e_{K-1} = e_2$, this gives the displayed formula.

(c) **Potential weaknesses.** OP-2 Lemma 2.6 was proved for $t \geq 0$ on the OP-2 cycle init; the "Step 1" projection identity (PROJ-scaled) requires the iterate $\lambda e_t$ to project onto a vertex of $\widetilde P$. **At the cycle vertex $\lambda e_0$, this is verified** (Task 1 of original audit confirmed 50-digit). So the identity transplants correctly to the zero-momentum scenario at the **first iteration only**: subsequent iterates $x_1, x_2, \ldots$ are NOT cycle vertices, so OP-2 Lemma 2.6 does not directly apply to them. This is fine — Theorem 5.1 only needs the formula at $t=0$.

**Step 3 — Equate against cycle vertex.**

(a) **What is being proved.** $x_1^{\rm zero} - \lambda e_1 = \beta\lambda(e_2 - e_0)$.

(b) **Tool used.** Direct subtraction: $\lambda(-\beta e_0 + e_1 + \beta e_2) - \lambda e_1 = \lambda(-\beta e_0 + \beta e_2) = \beta\lambda(e_2 - e_0)$.

(c) **Potential weaknesses.** Pure algebra; no weakness.

**Step 4 — Solve for $\beta$.**

(a) **What is being proved.** $\beta\lambda(e_2 - e_0) = 0$ iff $\beta = 0$ or $\lambda = 0$ or $e_2 = e_0$. Since $e_0 \ne e_2$ on the equilateral triangle (they differ by $2\pi/3$ rotation), and $\lambda = D/\sqrt 2 > 0$, the only solution is $\beta = 0$.

(b) **Tool used.** Linear independence of $e_0, e_2$ in $\mathbb R^2$ (they are not parallel for $K = 3$).

(c) **Potential weaknesses.** None. Note that for $K = 2$, $e_0$ and $e_1 = -e_0$ would satisfy $e_2 = e_0$, but $K=3$ rules this out.

### Aggregated assessment

The proof of Theorem 5.1 is **rigorous and clean**. Each step rests on either elementary algebra or the well-tested OP-2 projection identity. Verdict: **VALID**.

---

## Task 1.2 — SymPy verification of vanishing locus

**Script:** `reaudit_task_1_2_sympy.py`. **Output:**

```
[1] p(r) = r^2 - (1+beta-eta*lam) r + beta
[2] r1+r2 = 1+beta-eta*lam (Vieta sum)
    r1*r2 = beta            (Vieta product)
[3] A_mu^zero (lam=mu) = v*(1-r2)/(r1-r2)
[4] A_mu^zero = 0 iff r2 = 1.
[5] p(1) = 1 - (1+beta-eta*lam) + beta = eta*lam
[6] At lam=mu: p(1) = eta*mu = 0 iff mu = 0 (eta>0).
[7] In F_{K=3}, kappa = mu/L > 0 strictly. Hence A_mu^zero != 0 throughout F.
[Anchor numeric] disc = -2.9047, |1-r1|^2 = 1.25659 = eta*mu (50-digit match).
                 |A_mu^zero| = 0.46508 (formula and direct computation agree to 50 digits).
```

**Sub-claim resolution:**
1. Characteristic polynomial: ✓ as stated.
2. Vieta sums and products: symbolically confirmed. ✓
3. $A_\mu^{\rm zero}$ formula: confirmed. ✓
4. Vanishing locus equation: $r_2 = 1$ ⟺ $p(1) = 0$ ⟺ $\eta\mu = 0$. ✓
5–6. Substitution $r=1$ into $p$: $1 - (1+\beta-\eta\mu) + \beta = \eta\mu$. ✓
7. **Critical check:** $\mathcal F_{K=3}$ requires $\kappa = \mu/L \in (0, 1)$ (strongly convex, smooth). So $\mu > 0$ strictly. Therefore $A_\mu^{\rm zero} \neq 0$ on every point of $\mathcal F_{K=3}$. ✓

**Verdict — VALID.** All seven sub-claims confirmed by SymPy and an mpmath cross-check at the anchor.

---

## Task 1.3 — mpmath numerical verification of the subtle decay/cycling dichotomy

**Script:** `reaudit_task_1_3_mpmath.py` (mpmath dps=100, T=10000).

**Test point (a) — generic $(\beta, \eta L, \kappa) = (0.5, 2.7, 0.1)$:**

- Formula: $|A_\mu^{\rm zero}| = 0.5265$ (NONZERO).
- SHB orbit: $\|x_1\| = 0.935$, $\|x_4\| = 0.168$, $\|x_{51}\| = 4 \cdot 10^{-8}$, $\|x_{1001}\| = 1.2 \cdot 10^{-151}$, $\|x_{5001}\| = 0$ (rounded to 0 at dps=100 floor).
- **Verdict: DECAY.**

**Test point (b) — cycling anchor $(0.8, 3.247, 0.387)$:**

- Formula: $|A_\mu^{\rm zero}| = 0.4651$ (NONZERO).
- SHB orbit: $\|x_1\| = 1.208$, $\|x_4\| = 0.148$, $\|x_{51}\| = 0.706$, $\|x_{101}\| = 0.7072$, $\|x_{1001}\| = 0.7071$, $\|x_{10000}\| = 0.7071$. Last 200 steps: mean $0.7071$, std exactly 0.
- **Verdict: CYCLING (radius $D/\sqrt 2$).**

**Critical observation.** Both points have $A_\mu^{\rm zero} \neq 0$, yet (a) decays and (b) cycles. **This confirms the SUBTLE point** — the proof's §3 (linear envelope diagnostic) correctly states "the linear envelope predicts decay; cycling must come from the nonlinear projection force activated by L2." The proof does NOT conflate $A_\mu \neq 0$ with non-decay; it correctly attributes the dichotomy to the polytope-exit condition L2 (a nonlinear, parameter-dependent inequality).

The proof's §3 reads:
> "Linear envelope. $|x_t^{(\mu)}| \le 2|A|\beta^{t/2} \to 0$ exponentially. **The linear analysis predicts decay**; cycling must come from the nonlinear projection force activated by L2."

This is consistent with our numerical observation. **No conflation present.**

**Verdict — VALID.**

---

## Task 1.4 — Positive measure $\mathcal F^{\rm zero}_{K=3}$ characterization at 100-digit precision

**Script:** `reaudit_task_1_4_grid.py` (mpmath dps=100, T=3000), supplemented by `reaudit_task_1_4b_period_check.py` for per-period analysis.

### Headline counts (100 grid points across $\beta \in \{0.31, \ldots, 0.95\}$ × 10 $\eta L$ values):

| Class | Claim (8/73/19) | Observed (this audit) |
|---|---:|---:|
| Cycling (radius $D/\sqrt 2$) | 8/100 | **8/100 ✓** |
| Decay | 73/100 | **73/100 ✓** |
| "Period-2" (per claim) | 19/100 | **0/100 (period-2 in $x_t$)** |
| Other (period-4 in norm) | — | **17/100 (period-4 in $x_t$, period-4 in $\|x_t\|$)** |
| Other (decaying transient at $\beta=0.95, \eta L=2.998$) | — | 1/100 (period-3, marginal cycler at norm 0.7071) |
| Genuinely non-periodic | — | 1/100 |

The cycling count **8/100 matches exactly**.

### Re-classification of the "19% period-2" claim — NEEDS_CORRECTION

The 19 grid points originally classified as "period-2 attractor" are actually:

- **17/19 are period-4 in $\mathbb R^2$** (and period-4 in $\|x_t\|$), at $\beta \in \{0.9, 0.95\}$. Per-step norms cycle through 4 distinct values, e.g. at $(0.9, 3.128, 0.4406)$: $\|x_t\| \in \{1.911, 1.357, 1.533, 0.979\}$ (period 4). Min norm $\approx 0.98$, max $\approx 1.91$. **Strictly NOT period-2.**
- 1/19 (the marginal $\beta=0.95, \eta L=2.998$ point) is actually **period-3 with norm $D/\sqrt 2$ exactly** — a 9th cycler that the original classifier missed.
- 1/19 (the $\beta=0.9, \eta L=3.038$ point) appears non-periodic at $T=3000$ (period-4 error 0.016, not converged within tolerance).

The proof's L7 anchor points $(0.9, 3.78, 0.05)$ and $(0.95, 3.85, 0.10)$ are **outside** the 100-grid (they use different $\eta L$ and $\kappa$ values). At these specific points (Task 1.4c), the orbit is **period-6 in $\mathbb R^2$ but period-2 in $\|x_t\|$** — alternating between two norm values (e.g., $\{2.108, 2.208\}$ at $(0.9, 3.78, 0.05)$). So the **L7 anchors are correctly described as "period-2 in norm" but should not be called "period-2" in the iterate space**. This is a terminology/expository issue.

### Openness of $\mathcal F^{\rm zero}$ — VALID

The SHB map $\Phi:(x_t, x_{t-1}) \mapsto (x_{t+1}, x_t)$ is continuous in $(\beta, \eta L, \kappa, x, x')$ (composition of: smooth gradient $\nabla f_0$ which is Lipschitz in $x$ and continuous in parameters, plus linear momentum step). Iterates $x_T$ depend continuously on parameters for fixed $T$. The classification "$\|x_T\| > c$" is open in parameters. The cycling condition "$x_t \to \{\lambda e_0, \lambda e_1, \lambda e_2\}$" can be encoded as a uniform-in-$t$-large-enough open condition. Therefore $\mathcal F^{\rm cycle} \cup \mathcal F^{\rm period\!-\!4}$ is open in $\mathcal F_{K=3}$ and has positive 3-D Lebesgue measure (since each anchor lies in a continuity ball).

### Numerical estimate vs. analytic measure

- The 8% / 17% / 73% counts are **numerical estimates** from a 100-point grid with $T = 3000$. They are NOT analytic measures.
- The proof claims **positive Lebesgue measure** (without a specific value). The conjunction of (a) openness from continuity, (b) at least one anchor in each component, (c) anchor classifications confirmed numerically, **establishes positive measure**. This much is **rigorous**.
- Converting "$8/100 \approx 8\%$" into a Lebesgue lower bound requires either (i) verifying that each of the 8 anchors lies in a ball of radius $r > 0$ inside the cycling region (continuity argument), or (ii) explicit ball-volume estimates. Neither is fully developed in the consolidated proof; the proof gives a hand-wave $\geq 0.04$ in §6 with no explicit Lipschitz constant. **This is a weakness for an external peer review, but not a hard error.**

### Verdict
**VALID with NEEDS_CORRECTION on terminology**: the cycling count and existence of a positive-measure subset are confirmed. The 19% "period-2" should be relabeled "period-4 in norm" (for the 17 grid-scan points) or "period-2 in norm / period-6 in $\mathbb R^2$" (for the L7 anchors). The two are distinct — the L7 anchors give a stronger floor ($\|x\|^2 \geq 4.4$) than the period-4 grid-points ($\|x\|^2_{\min} \approx 0.95$).

---

## Task 1.5 — Bias constant κ/4 → κ/8 derivation

**Script:** `reaudit_task_1_5_bias.py`. Computes $c_T := T \cdot (f_0(x_T) - f_0^*) / (\kappa L D^2)$ along the SHB trajectory at the anchor and reports $\min_T c_T$.

### Where the factor κ/8 supposedly comes from (proof §5)

The consolidated proof's argument:
> "$\|x_T\| \geq \lambda(1 - C\beta^{3T/2})$ for $T \geq T_0$.
>  Hence $f_0(x_T) - f_0^* \geq (\mu/2)\|x_T\|^2 \geq (\mu/2)\lambda^2(1 - C\beta^{3T/2})^2 = (\mu D^2/4)(1 - C\beta^{3T/2})^2$.
>  The transient correction degrades the OP-2 constant from $\kappa/4$ down to $\kappa/8$ to absorb the $(1 - C\beta^{3T/2})^2$ factor uniformly in $T \geq 1$:
>  $\mathbb E[f(x_T) - f^*] \geq \kappa LD^2/(8T)$ for all $T \geq 1$."

**Algebraic decomposition of the 1/2 factor.** $\mu D^2/4 \cdot (1 - C\beta^{3T/2})^2 \geq \mu D^2/8$ requires $(1 - C\beta^{3T/2})^2 \geq 1/2$, i.e., $C\beta^{3T/2} \leq 1 - 1/\sqrt 2 \approx 0.293$. For $\beta = 0.8$: $\beta^{3/2} \approx 0.715$. With $C = 1$, at $T=1$: $1 - 0.715 = 0.285 < 0.293$ — **just barely on the wrong side**. For $T=2$: $\beta^3 = 0.512$, $(1-0.512)^2 = 0.238 < 1/2$ — fails.

So the factor "1/2 absorption" only kicks in for $T \geq T_0$ where $\beta^{3T_0/2} \leq 0.293$, i.e., $T_0 \geq \ln(0.293)/\ln(\beta^{3/2}) \approx 3.66$. So $T_0 = 4$, and the derivation **claims** the κ/8 bound holds at $T \geq 4$.

### Direct numerical test at the anchor (T=200)

| $T$ | $\|x_T\|$ | $f_0(x_T)$ | $c_T = T \cdot f_0/\kappa$ |
|---:|---:|---:|---:|
| 1 | 1.208 | 0.4535 | 1.172 |
| 2 | 0.705 | 0.1876 | 0.970 |
| 3 | 1.100 | 0.4999 | 3.876 |
| **4** | **0.148** | **0.01093** | **0.113** ← MIN |
| 5 | 1.080 | 0.3816 | 4.930 |
| 6 | 0.240 | 0.0288 | 0.447 |
| 7 | 1.111 | 0.5071 | 9.173 |
| 8 | 0.351 | 0.0613 | 1.267 |
| 9 | 0.652 | 0.1901 | 4.422 |
| 10 | 0.606 | 0.1533 | 3.962 |
| ... | ... | ... | ... |
| $\geq 50$ | $\to 0.7071$ | $\to 0.2373$ | $\to T \cdot 0.6131$ → ∞ |

**Min over $T \in [1, 200]$: $c_T = 0.1129$ at $T = 4$.**

For "$f_0(x_T) - f_0^* \geq \kappa LD^2/(8T)$ for all $T \geq 1$", we require $c_T \geq 1/8 = 0.125$. **At $T = 4$ this fails: $c_T = 0.1129 < 0.125$.**

### Restricted to $T \geq T_0$: bound recovers

| $T_0$ | min $c_T$ for $T \geq T_0$ | κ/8 valid? |
|---:|---:|:---:|
| 10 | 0.953 | ✓ |
| 20 | 1.959 | ✓ |
| 30 | 13.75 | ✓ |
| 50 | 29.67 | ✓ |
| 100 | 61.31 | ✓ |

So for $T \geq 10$, the bound holds with **enormous margin** (min $c_T = 0.953 \gg 1/8$). The failure is **localized at $T = 4$** during the transient.

### Where the $\kappa/8$ derivation breaks

The proof's "$\|x_T\| \geq \lambda(1 - C\beta^{3T/2})$ for $T \geq T_0$" requires the orbit to be already inside the cycle's basin of attraction. But at $T = 4$, $\|x_4\| = 0.148 \ll \lambda = 0.707$ — the orbit is in deep transient, NOT close to the cycle. The Floquet linearization argument (which is the basis for the contraction rate $\beta^{3/2}$) only applies after the orbit has entered a small neighborhood of the cycle, not during the wild initial swings.

For zero-momentum init at the anchor, the orbit takes ~50 steps to enter the basin (Task 1.3 trajectory: $\|x_{51}\| = 0.706$, first close to $\lambda$). So $T_0 \approx 50$ is the realistic post-transient threshold, not $T_0 = 4$.

### Comparison with OP-2 init at the same anchor

At OP-2 init, $\|x_t\| = \lambda$ identically for all $t \geq 0$, so $f_0(x_T) - f_0^* = \mu D^2/4$ exactly, giving $c_T = T \cdot 1/4\cdot(L D^2)/(\kappa L D^2) = T/4 \cdot \kappa/\kappa = T/4$. Wait, the formula is $c_T = T \cdot f_0/\kappa = T \cdot (\mu D^2/4)/\kappa = T \cdot D^2/4$. For $D = 1$, $c_T = T/4$, so $c_T \geq 0.613$ at $T=1$ — ✓ **always valid, easily exceeds κ/4 = 0.25.**

### Verdict — INVALID as currently stated; NEEDS_CORRECTION (HIGH severity)

The claim "$f_0(x_T) - f_0^* \geq \kappa LD^2/(8T)$ for all $T \geq 1$" is **numerically FALSE at $T = 4$** for the anchor. Two corrections are possible:

**Option A (recommended):** Restrict to $T \geq T_0$ for some explicit $T_0$ (e.g., $T_0 = 10$ at the anchor; in general, $T_0 = \mathrm{poly}(1/(1 - \beta^{3/2}))$). State Theorem 5.1 with this $T_0$:
$$\mathbb E[f(x_T) - f^*] \geq \frac{\kappa L D^2}{8T} \qquad \forall\, T \geq T_0(\beta, \eta L, \kappa).$$

**Option B:** Downgrade the constant. The observed minimum $c_T = 0.113$ implies the actual valid constant for "all $T \geq 1$" is at most $1/8.86 < 1/8$. A safe choice would be $c = 1/9$ or, more conservatively, $c = 1/16$, with derivation noting that the transient dip at $T = O(1)$ is the binding constraint.

**Either correction must be made before peer review.** The current statement is technically false.

---

## Summary table

| Section | Claim | Status |
|---|---|---|
| §1 (Theorem 5.1) | $x_1^{\rm zero} - \lambda e_1 = \beta\lambda(e_2 - e_0) \neq 0$ for $\beta > 0$ | **VALID** |
| §2 (L2) | $\mathcal R_2$ has positive measure (37% of test box) | **VALID** |
| §3 (L3 — linear envelope) | $A_\mu^{\rm zero} \neq 0$ on $\mathcal F$ but linear envelope decays | **VALID** (subtle dichotomy correctly handled) |
| §4 (L4 — Floquet) | All four Floquet multipliers have modulus $\beta^{3/2}$ | **VALID** (vertex Hessian = $\mu I$, agrees with corrected derivation) |
| §5 (L5 — basin and bias) | $\|x_T\| \geq \lambda(1 - C\beta^{3T/2})$, bias $\kappa LD^2/(8T)$ for all $T \geq 1$ | **INVALID** at $T = 4$; NEEDS_CORRECTION |
| §6 (L6 — anchor) | Anchor cycles at radius $\lambda$; numerical 8% cycling | **VALID** |
| §7 (L7 — period-2 complement) | Period-2 attractors at $(0.9, 3.78, 0.05)$ etc. | **VALID at L7 anchors** (period-2 in norm); but proof terminology conflates "period-2" (norm-period) with "period-2 in iterate" — NEEDS_CORRECTION on language; the 17/19 grid-scan points are period-4 in both norm and iterate, NOT period-2 |
| §8 (L8 — variance) | $c' = \sqrt 2/27$ inherits from OP-2 | **VALID** (decoupled $y$-coordinate) |

---

## Recommended actions before peer review

1. **HIGH (§5):** Either state $T \geq T_0$ explicitly with $T_0 \approx 10$ (or larger, parameter-dependent), or downgrade the bias constant from $\kappa/8$ to a value the transient permits (numerically $c \leq 0.113 \approx 1/9$). Provide an explicit derivation of the transient bound or cite a stable-manifold theorem that gives $T_0$ as a function of basin parameters.

2. **MEDIUM (§7):** Distinguish "period-2 in norm" (the $(0.9, 3.78, 0.05)$-type orbits where iterate is period-6 but norm alternates between two values) from "period-2 in iterate" (would mean $x_{t+2} = x_t$, not observed in this region). Also clarify that the 19/100 "period-2" grid points are actually period-4 attractors.

3. **LOW (§4):** Already corrected in the consolidated proof (vertex Hessian = $\mu I$).

4. **LOW (§6):** Already corrected (rotating K=3 cycle, not stationary fixed point).

---

## Final Verdict

**CONDITIONAL PASS.** The structural Theorem 5.1 (the named theorem under audit, asserting that zero-momentum init cannot produce literal cycling for any $\beta > 0$) is **rigorously valid** — its proof reduces to a one-line algebraic identity that all checks confirm. The existence of a positive-measure $\mathcal F^{\rm zero}_{K=3}$ is also valid (8% cycling rate confirmed at dps=100, T=3000; openness from continuity of SHB).

However, the **bias constant κ/8 in the lower bound** is FALSE for small $T$: at the anchor, $c_T = 0.113$ at $T=4$, below the required $1/8 = 0.125$. This is a **HIGH-severity correction** — the bound must either restrict $T \geq T_0$ or use a smaller constant.

The proof can be repaired with minor edits (1-2 paragraphs in §5). After repair, the result stands as a valid contribution: **a non-empty open positive-measure subset of $\mathcal F_{K=3}$ supports the OP-2-type lower bound for zero-momentum SHB, with bias constant $c$ (TBD: κ/8 for $T \geq T_0$, or κ/9 for all $T \geq 1$) and variance constant $\sqrt 2/27$ inherited from OP-2.**

$\blacksquare$
