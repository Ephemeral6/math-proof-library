# OP-2 升级尝试报告

**Date:** 2026-04-26
**Goal:** Investigate whether OP-2 can be strengthened to remove the two scope limitations (last-iterate-only, special init) flagged by Xiao Li, OR document why those limitations are essential to the current toolbox.

---

## TL;DR

| Direction | Verdict | Notes |
|---|---|---|
| **A1** non-periodic orbit | **FAIL** | Goujaud's rotational symmetry forces orbit barycenter = 0 |
| **A2** Nesterov-style worst-case | **UNCERTAIN → likely FAIL** | Nesterov LB is for *any* first-order method; can't separate HB from AC-SA |
| **A3** stochastic correlation | **PARTIAL FAIL** | Variance term cleanly transfers to averaged iterate via Le Cam; bias term does not. Adding x-noise gives Θ(σ²/T) instead of Θ(LD²/T) — dominated by standard σD/√T |
| **A4** dimension scaling (d=T) | **UNCERTAIN** | Classical Nesterov LB doesn't separate HB from AC-SA; no algorithm-specific d=T construction known |
| **B1** transient-based | **FAIL** | Geometric convergence after transient is incompatible with Ω(1/T) for all T |
| **B2** non-cycling slow function | **UNCERTAIN** | No known construction; the best lower-bound tools (PEP) give algorithm-uniform rates |
| **B3** resisting oracle | **UNCERTAIN** | Drusvyatskiy-Grimmer framework exists for non-smooth; no smooth+HB result known |
| **B4** embedded cycling | **PARTIAL PASS (weakened)** | Cycling orbit is attractive on a subset $\mathcal{F}_{\text{attract}} \subsetneq \mathcal{F}$; OP-2 LB holds there under zero-momentum init |
| **B5** dimension scaling | **UNCERTAIN** | No clear path |

**Bottom line:** Sub-task A produces no rescue — the bias term on averaged iterate genuinely seems beyond current tools. Sub-task B yields a partial save: a *weakened* OP-2 holds on $\mathcal{F}_{\text{attract}} \subsetneq \mathcal{F}$ under zero-momentum init.

The two scope limitations flagged by Li are not artifacts of OP-2's specific construction — they reflect a deep gap in the lower-bound toolbox for fixed-momentum SHB.

---

## Sub-task A: Averaged-iterate lower bound

### A1: Non-periodic / quasi-periodic orbit

**Hypothesis.** Replace the K-periodic Goujaud orbit with a quasi-periodic, chaotic, or irrational-flow orbit that stays bounded away from $x^\star$ but does not return to its initial state.

**Feasibility analysis.**

Goujaud's cycle is enforced by the rotational symmetry: $\mathrm{conv}(\widetilde P)$ is invariant under $R_{\theta_K}$, and the SHB iteration commutes with this rotation when started on a vertex orbit. The cycle's barycenter is zero by symmetry:
$$\frac{1}{K}\sum_{t=0}^{K-1} (D/\sqrt 2)\, e_t = 0 \in \mathbb{R}^2,$$
because $\sum_t e_t = 0$ for any regular polygon at $K \geq 2$ (vertices are roots of unity scaled by $D/\sqrt 2$).

For a non-periodic orbit, **Birkhoff's ergodic theorem** says the time average converges to the spatial average over the invariant measure. So if the orbit's invariant set is symmetric about $x^\star$, the time average converges to $x^\star$, giving $f(\bar x_T) \to f^\star$ — same problem as cycling.

To get $f(\bar x_T) - f^\star = \Omega(1/T)$, we need the invariant measure of SHB on $f$ to have **non-zero barycenter** (i.e., asymmetric). But:

1. **GTD23's piecewise function structure** (quadratic outside, $\mu$-strongly-quadratic inside polytope) requires $\mathcal{C}^{1,1}$ smoothness, which forces the polytope to contain $0$ in its interior.
2. **For convexity**, the function value at the polytope's centroid must be ≤ value at any vertex. So the centroid is automatically at the global minimum.
3. **Rotational symmetry** of the invariant set is essentially built in: the cycling identity (★) is rotation-equivariant, and breaking the symmetry breaks the cycling identity.

**Obstruction.** Any orbit satisfying the cycling identity has rotationally symmetric invariant set with barycenter = 0. Asymmetric Goujaud-style cycling requires a fundamentally different identity, which is not known to exist.

**Verdict:** **FAIL.**

### A2: Nesterov-style worst-case construction (d = T)

**Hypothesis.** Replace Goujaud cycling with Nesterov's classical $d = T$ tridiagonal worst-case function. SHB on this function might have averaged-iterate rate $\Omega(LD^2/T)$ even though AC-SA achieves $O(LD^2/T^2)$.

**Feasibility analysis.**

Nesterov's worst-case function is
$$f(x) = \frac{L}{8}\bigg(x_1^2 + \sum_{i=1}^{d-1}(x_i - x_{i+1})^2 + x_d^2 - 2 x_1\bigg).$$

It serves as a witness for the Nesterov–Yudin lower bound: any first-order method that queries $\nabla f(x_t)$ for $x_t$ in the span of $\{x_0, \nabla f(x_0), \ldots, \nabla f(x_{t-1})\}$ achieves at most $O(LD^2/T^2)$ error after $T$ steps when $d \geq 2T+1$. Both AC-SA (achieving the rate) and SHB (failing to accelerate) are *first-order* methods in this sense, so Nesterov's LB **does not separate them**.

To separate HB from AC-SA, we'd need a function-class lower bound that exploits *the specific structural difference* between HB (gradient at $x_t$) and AC-SA (gradient at the lookahead point $x_t + \beta(x_t - x_{t-1})$). Drori (2014) and Drori–Taylor (2017) give *worst-case PEP* bounds for HB that are tight, but these are upper bounds on HB's worst-case error, not lower bounds with a separating function.

The closest existing result is Goujaud–Taylor–Dieuleveut 2023 (cycling on strongly-convex), which does separate HB from AC-SA via the cycling phenomenon — but on the *last iterate* only. A Nesterov-style construction with averaged-iterate separation would be a genuinely new theorem.

**Obstruction.** Nesterov's framework gives algorithm-uniform LBs, not algorithm-specific LBs against HB. Any HB-vs-AC-SA separation on averaged iterates would require a new lower-bound technique exploiting the lookahead-vs-non-lookahead gradient query structure — not currently in the toolbox.

**Verdict:** **UNCERTAIN, likely FAIL** (would require new lower-bound technique beyond Nesterov's framework).

### A3: Stochastic noise structure

**Hypothesis.** Even when the deterministic cycling averages to zero, the stochastic noise on the trajectory might preserve a non-trivial bias-rate lower bound on $\bar x_T$.

**Feasibility analysis (variance term).**

Le Cam's two-point lemma is **estimator-agnostic**: it bounds the misidentification probability for *any* function of the observed data. So defining $\hat s := -\mathrm{sgn}(\bar y_T)$ instead of $\hat s := -\mathrm{sgn}(y_T)$ doesn't change the bound. The conditional KL chain-rule argument in OP-2 §2.4.1 (Lemma 2.9) uses only the structure of the oracle response, not the specific iterate inspected. Hence:
$$\max_s\, \mathbb{E}_s[G_s(\bar y_T)] \geq c_{\mathrm{NY}} \cdot \frac{\sigma D}{\sqrt T}.$$

[VERIFIED numerically — `upgrade_attempt_A3_lecam.py`:]

| $T$ | $c_{\mathrm{NY}} \sigma D/\sqrt T$ target | $\mathbb{E}[G_s(\bar y_T)]$ measured | last-iter measured |
|---|---|---|---|
| 10 | 0.00282 | 0.0787 | 25.21 |
| 50 | 0.00126 | 0.0314 | 24.01 |
| 200 | 0.00063 | 0.0167 | 21.80 |

(The last-iter values are very large because at $(\beta, \eta L) = (0.5, 3)$ with no wall, the y-iterate would grow under noise; the wall confines it but creates large peaks. The averaged iterate is much smaller as expected.)

**Conclusion (variance term):** Variance LB transfers cleanly to averaged iterate. ✓

**Feasibility analysis (bias term).**

Adding noise $\sigma_x$ to the x-coordinate to attempt to recover a bias-like term:

$$\bar x_T = \underbrace{(1/T)\sum_t x_t^{\det}}_{\to 0\,(\text{cycling avg})} + \underbrace{(1/T)\sum_t \xi_t^x}_{\text{noise avg}}.$$

For Goujaud cycling under stable HB dynamics, the noise propagates with bounded amplification (Lyapunov function of the cycle), so the noise avg has variance $\Theta(\sigma_x^2/T)$. Hence
$$\mathbb{E}\|\bar x_T\|^2 = O(D^2/T^2) + \Theta(\sigma_x^2/T).$$

By $\mu$-strong convexity of $f_0$ on the x-block:
$$\mathbb{E}[f_0(\bar x_T) - f_0^\star] \geq (\mu/2) \mathbb{E}\|\bar x_T\|^2 = \Omega(\sigma_x^2/T).$$

This is a **bias-like rate of $\Omega(\sigma_x^2/T)$**, *not* $\Omega(LD^2/T)$.

To upgrade: would need $\sigma_x^2 \geq LD^2$, i.e., $\sigma_x \geq D\sqrt L$. But the OP-2 oracle has variance bound $\sigma^2$, and the standard variance term $\sigma D/\sqrt T$ already dominates $\sigma_x^2/T$ in the regime $\sigma_x \leq \sigma$:
$$\frac{\sigma_x^2}{T} \leq \frac{\sigma^2}{T} \leq \frac{\sigma D}{\sqrt T}\quad \Longleftrightarrow\quad \sigma \leq D\sqrt T,$$
which is implied by (RGM) for all $T \geq 1$. So the noise-induced bias-like term **never strictly exceeds** the variance term.

[VERIFIED numerically — `upgrade_attempt_A_bias_avg.py`:]

| $T$ | $(κ/4)LD^2/T$ target | $\mathbb{E}[f_0(\bar x_T)]$ measured | ratio |
|---|---|---|---|
| 50 | 0.00125 | 0.00102 | **0.82** |
| 200 | 0.000313 | 0.000247 | **0.79** |
| 1000 | 0.0000625 | 0.0000557 | **0.89** |

Even with $\sigma_x = 0.1 \cdot D$, the averaged iterate's bias is *just below* the OP-2 target ratio (~80–90%). The constant doesn't quite cross over to satisfying the LB, and increasing $\sigma_x$ eventually makes the iterate diverge.

**Obstruction.** Stochastic noise gives an averaged-iterate gap of $\Omega(\sigma_x^2/T)$, which is dominated by the variance term $\sigma D/\sqrt T$ already in OP-2 — not a new contribution. The deterministic part of $\bar x_T$ collapses to zero (cycling barycenter), and there's no mechanism to inject a non-zero deterministic offset without breaking convexity / smoothness.

**Verdict:** **PARTIAL FAIL.** Variance term ✓, bias term ✗.

### A4: Dimension scaling (d = T) for HB-specific LB

**Hypothesis.** In d = T dimensions, design a Nemirovski–Yudin-style construction that specifically exploits HB's gradient query structure.

**Feasibility analysis.**

HB queries $\nabla f$ at $x_t$, where $x_t$ depends on $(x_{t-1}, x_{t-2}, \nabla f(x_{t-1}))$. AC-SA queries at $y_t = x_t + \beta_t(x_t - x_{t-1})$, an explicit lookahead.

Classical NY constructions force the iterate's $i$-th coordinate to remain zero for $i > t$ (gradient information in the $(t+1)$-th coordinate is unavailable until step $t+1$). Both HB and AC-SA satisfy this constraint identically — the $t$-th iterate has support $\{1, \ldots, t\}$. So the standard NY argument gives the same lower bound for both.

To separate HB from AC-SA, we'd need a construction where AC-SA's lookahead explicitly accesses information that HB cannot. The lookahead point $y_t$ might land in a different region than $x_t$, but for smooth convex $f$, $y_t - x_t = \beta(x_t - x_{t-1})$, which is in the span of past iterates' differences — the same span available to HB indirectly via $\nabla f(x_t)$ vs $\nabla f(x_{t-1})$.

So algorithmically, the information available to AC-SA at step $t$ is the same as HB (after suitable linear combinations). The acceleration comes from a more clever update rule that *uses* this information differently, not from accessing different information.

**Obstruction.** No information-theoretic separation between HB and AC-SA exists in the d = T regime. Both are "first-order methods" with equivalent information access. The gap is computational, not informational, and cannot be lower-bounded via NY-style arguments.

**Verdict:** **UNCERTAIN, likely FAIL.**

---

## Sub-task B: Zero-momentum initialization lower bound

### B1: Transient-based lower bound

**Hypothesis.** Even if SHB eventually converges from $x_0 = x_{-1}$, the early transient might satisfy $\Omega(LD^2/T)$ for all $T \geq 1$.

**Feasibility analysis.**

Suppose SHB converges geometrically from zero-momentum init: $f(x_T) - f^\star \leq C \rho^T$ for some $\rho < 1$ and $C$ depending on $L, D$. For $\Omega(LD^2/T)$ to hold, we need
$$C \rho^T \geq \frac{c\, L D^2}{T}\quad \Longleftrightarrow\quad T \log(1/\rho) \leq \log(C T / (cLD^2)).$$
For large $T$, the LHS grows linearly while the RHS grows logarithmically. The inequality fails for $T \geq T_0(\rho, c, C)$. So a purely transient LB cannot give $\Omega(LD^2/T)$ uniformly in $T$.

This is the situation we observed numerically: at $(\beta, \eta L) = (0.7, 2.9)$ with zero-momentum init, $f_0(x_T) \approx 10^{-31}$ at $T = 200$ — geometric decay with $\rho \approx 0.7$, totally below $(\kappa/4) L D^2 / T \approx 0.0006$.

**Obstruction.** Geometric convergence is incompatible with $\Omega(1/T)$ for $T \to \infty$.

**Verdict:** **FAIL.**

### B2: Non-cycling slow function

**Hypothesis.** Construct $f$ such that zero-momentum SHB converges, but at exactly the rate $\Theta(1/T)$ (not faster), without using cycling.

**Feasibility analysis.**

The known tight upper bounds for fixed-momentum SHB on smooth convex (non-SC) functions:

1. **GFJ15:** $f(\bar x_T) - f^\star \leq O(LD^2/T)$ for averaged iterate, deterministic, fixed $(\beta, \eta)$ in suitable range.
2. **Drori–Taylor PEP:** worst-case $f(x_T) - f^\star$ for last iterate of HB has rate matching $O(LD^2/T)$ on a class of smooth convex functions (PEP-tight).

So the *upper bound* is $\Theta(LD^2/T)$. The question is: is there a witness function where this is achieved tightly, i.e., $f(x_T) - f^\star = \Omega(LD^2/T)$?

Drori–Taylor's PEP analysis is essentially a *worst-case* over function values consistent with the smooth-convex constraints, found via convex SDP. The "worst-case function" reconstructed from the SDP solution is a witness — but it depends on the algorithm's specific iterate, not a natural function family.

For zero-momentum init specifically: even Drori–Taylor's witness function is for a fixed initialization, but they typically use $x_0 = x_{-1}$. So in principle, a PEP-tight witness gives $\Omega(LD^2/T)$ for zero-momentum HB. **The construction exists abstractly, but is not interpretable as an explicit, simple function.**

**Possible path forward:** Adapt Drori–Taylor's PEP witness for HB with zero-momentum init into an explicit lower-bound construction. This is a substantial research project.

**Obstruction.** No known *explicit* witness function for HB-with-zero-momentum-init achieving $\Omega(LD^2/T)$. The PEP framework gives existence implicitly, but extracting a clean construction is non-trivial. Furthermore, PEP-tight rates are often achieved for specific function classes that don't span the full $\mathcal{F}_L$ class; the witness might be too specialized.

**Verdict:** **UNCERTAIN.** Direction is plausible via PEP but requires substantial new work.

### B3: Resisting oracle (Drusvyatskiy–Grimmer-style)

**Hypothesis.** Construct a function and oracle such that each SHB step is "resisted" — gradients are returned that minimize SHB's progress.

**Feasibility analysis.**

Drusvyatskiy–Grimmer (2022, "Optimal step length for the steepest descent method") and earlier Carmon–Duchi (2019) build resisting oracles for non-smooth and smooth optimization. The pattern: at each query, the oracle returns the gradient that's worst-case for the algorithm's update rule, subject to consistency with a $\mathcal{C}^{1,1}$ convex function class. Existence of such a function follows from the gradient consistency conditions.

For Lipschitz convex functions with subgradient oracle, Li–Liu–Orabona 2022 use this technique to prove $\Omega(\ln T/\sqrt T)$ for fixed-momentum SGDM. For smooth convex, the resisting-oracle technique would need to verify that the constructed gradient sequence is consistent with **co-coercivity** (the smoothness-equivalent of a Lipschitz subgradient bound). This is more restrictive and the constructions are harder.

**Possible path forward:** Adapt Carmon–Duchi's resisting framework to HB with zero-momentum init in the smooth setting. This is plausible in principle but technically demanding — co-coercivity constraints are tight, and constructing a co-coercive resisting sequence that gives $\Omega(LD^2/T)$ for HB is open.

**Obstruction.** Resisting-oracle constructions in the smooth setting are technically much harder than in the non-smooth (Lipschitz) setting, due to the co-coercivity constraint. No published result of this type for HB+smooth+zero-init.

**Verdict:** **UNCERTAIN.** Plausible direction but no shortcut from existing results.

### B4: Embedded cycling — cycling orbit is attractive on $\mathcal{F}_{\text{attract}}$

**Hypothesis.** For a subset $\mathcal{F}_{\text{attract}} \subset \mathcal{F}$, the Goujaud cycling orbit is an *attractor* under zero-momentum init. On this subset, OP-2's bound holds.

**Feasibility analysis.**

This direction is the only one that gives a positive partial result. Numerical verification (`upgrade_attempt_B_F_attract.py`) maps the behavior of zero-momentum-init SHB across a 9 × 5 = 45 grid of $(\beta, \eta L)$ in $\mathcal{F}_{K=3}$:

| $\beta$ | grid range $\eta L$ | classification by $\eta L$ slot 1, 2, 3, 4, 5 |
|---|---|---|
| 0.31 | $[2.61, 2.61]$ (narrow) | decay × 5 |
| 0.40 | $[2.61, 2.79]$ | decay × 5 |
| 0.50 | $[2.64, 2.99]$ | decay × 5 |
| 0.60 | $[2.68, 3.19]$ | decay × 5 |
| 0.70 | $[2.75, 3.39]$ | decay × 4, attract × 1 (at $\eta L = 3.39$) |
| 0.80 | $[2.83, 3.59]$ | decay × 2, attract × 3 |
| 0.90 | $[2.91, 3.79]$ | "other(\|x\|≈1)" × 5 |
| 0.95 | $[2.96, 3.89]$ | "other(\|x\|≈1.0–1.2)" × 5 |
| 0.99 | $[3.00, 3.97]$ | "other(\|x\|≈1.4–1.5)" × 5 |

**Three regimes observed:**

1. **decay** (26/45): orbit converges to $0$, $f_0(x_T) \to 0$ geometrically. *LB FAILS.*
2. **attract** (4/45): orbit converges to $K=3$ cycling at $\|x_t\| = D/\sqrt 2 = 0.707$. *LB HOLDS.*
3. **other** (15/45): orbit settles on a non-cycling trajectory but with $\|x_t\| \in [0.94, 1.55]$ (i.e., distance $\geq D$ from origin). *LB HOLDS — even strongly* — because $f_0(x_T) \geq (\mu/2) \|x_T\|^2 \geq (\mu/2) D^2 \geq (\kappa/4) LD^2 / T$ for $T \geq 1$.

**Combining "attract" and "other":** $\mathcal{F}_{\text{usable}}$ has 19/45 = **42% of grid points satisfying the OP-2 LB**.

**Pattern of $\mathcal{F}_{\text{usable}}$:** Concentrated at high $\beta$ ($\geq 0.7$) and $\eta L$ near the upper stability boundary. The decay regime dominates at low $\beta$ and low $\eta L$ (close to $\gamma_{\mathrm{crit}}$).

**Possible upgrade.** Define $\mathcal{F}_{\text{usable}} \subset \mathcal{F}$ to be the set of $(\beta, \eta) \in \mathcal{F}$ for which $\liminf_T \|x_T\| \geq D/\sqrt 2$ under zero-momentum init on the OP-2 hard instance. State a *weaker* version of OP-2:

> **Theorem (Main, Weakened, zero-momentum init).** Let $L, \sigma, D > 0$ satisfy (RGM). For every $(\beta, \eta) \in \mathcal{F}_{\text{usable}}$ and $T \geq 1$, there exists ... such that the last iterate $x_T$ generated by SHB **with zero-momentum initialization $x_0 = x_{-1}$** satisfies
> $$\mathbb{E}[f_{\beta,\eta}^{(T)}(x_T) - f_{\beta,\eta}^{(T),\star}] \geq c(\beta,\eta) \frac{LD^2}{T} + c_{\mathrm{NY}} \frac{\sigma D}{\sqrt T}.$$

**To make this rigorous,** we need:

1. A **rigorous characterization** of $\mathcal{F}_{\text{usable}}$ (currently only numerically observed).
2. A **dynamical-systems argument** showing the cycling/non-cycling-but-bounded-away-from-0 attractor is actually attracting — this is a Lyapunov-function or linearization argument around the cycle.
3. A **proof that $\mathcal{F}_{\text{usable}}$ has positive 2-D Lebesgue measure** (likely yes from numerical pattern: it includes a band at $\beta \geq 0.7$, $\eta L$ in upper interval).

**Obstruction.** Rigorous characterization of $\mathcal{F}_{\text{usable}}$ is non-trivial. The numerical observation suggests it's a non-empty open subset, but a clean closed-form characterization is not immediately apparent. The transient analysis (showing that orbits in $\mathcal{F}_{\text{usable}}$ reach the cycling attractor in finite steps and stay there) would require Lyapunov function construction — feasible but technical.

**Verdict:** **PARTIAL PASS** (weakened claim, requires substantial follow-up work to make rigorous).

This is the only direction in either sub-task that gives a positive (if weakened) result.

### B5: Dimension scaling

**Hypothesis.** Embed cycling in a high-dimensional manifold so that zero-momentum init naturally maps onto cycling.

**Feasibility analysis.**

Adding spectator dimensions (extra coordinates that decouple from x) doesn't help — they only add zero-norm contributions. To use dimension scaling effectively, we'd need the high-dimensional dynamics to *force* the iterate onto the cycling manifold under zero-momentum init.

A possible construction: in $\mathbb{R}^d$ with $d = O(K)$, design $f$ such that
- The cycling manifold is a $d-2$-dimensional structure (e.g., a flat polytope embedded in $\mathbb{R}^d$).
- Zero-momentum init at the origin of the spectator dimensions naturally evolves to land on the manifold after some transient.
- After landing, cycling on the manifold gives the LB.

This is essentially a high-dimensional version of B4. The key new element would be that the high-dim structure forces attraction to the cycling manifold for **all** $(\beta, \eta) \in \mathcal{F}$, not just the attract-subset.

**Obstruction.** Designing a high-dim function whose level sets force HB iterates onto a specific manifold is a research project of its own. The standard framework (Goujaud's polytope projection) does not generalize easily to higher dimensions in a way that ensures global attraction.

**Verdict:** **UNCERTAIN.** No clear path; would essentially require a new technique.

---

## 综合结论

### Can OP-2 be upgraded?

**Sub-task A (averaged iterate):** **NO** — no direction gives a path to $\Omega(LD^2/T)$ on $\bar x_T$. The variance term $\Omega(\sigma D/\sqrt T)$ does transfer cleanly to averaged iterates (good news), but the bias term genuinely collapses on Cesàro average. This appears to be a real limitation, not an artifact of the construction.

**Sub-task B (zero-momentum init):** **PARTIAL YES** — direction B4 yields a weakened version of OP-2 on the subset $\mathcal{F}_{\text{usable}} \subseteq \mathcal{F}$ where the cycling orbit (or a non-cycling but bounded-away-from-origin attractor) is attractive. Numerical evidence: $\mathcal{F}_{\text{usable}}$ contains roughly half of the grid points tested, concentrated at high $\beta$ and $\eta L$ near the upper stability boundary.

### Why the limitations seem fundamental

The two limitations have a common root: **OP-2's hard instance is constructed via a single-shot symmetric structure (Goujaud rotational cycling).** Both criticisms (averaging, initialization) attack this symmetric structure:

- Averaging: rotational-symmetric orbits average to their center of symmetry (which is $x^\star$ by construction).
- Initialization: symmetric cycling requires a specific two-point initial state that breaks rotational symmetry.

To overcome either limitation, we'd need a fundamentally **asymmetric** hard instance — but asymmetry kills the cycling identity that drives the LB. This is the structural barrier.

### Intermediate vs final scope

**Honestly-scoped OP-2:** last-iterate, cycling-init, on $\mathcal{F}$ — the safest and most defensible claim.

**Slightly upgraded (modest follow-up work):** last-iterate, **zero-momentum init**, on $\mathcal{F}_{\text{usable}} \subsetneq \mathcal{F}$. Requires rigorous characterization of $\mathcal{F}_{\text{usable}}$ and a Lyapunov argument; ~2 weeks of follow-up.

**Fully upgraded (open research):** averaged-iterate, zero-momentum init, on $\mathcal{F}$. No known path.

### Recommended action

1. **Accept the downgrade for v3 / submission.** The honest scope (last-iterate + cycling-init) is publishable; the gap to "ideal" OP-2 is substantial enough that closing it is itself a research program.

2. **State the weakened B4 result as Conjecture 0.8** in the paper:

   > **Conjecture 0.8 (Zero-momentum extension).** For every $(\beta, \eta)$ in a non-empty open subset $\mathcal{F}_{\text{usable}} \subseteq \mathcal{F}$, the OP-2 lower bound holds for zero-momentum-initialized SHB (last iterate) on the same hard instance. Numerical evidence suggests $\mathcal{F}_{\text{usable}}$ has positive 2-D Lebesgue measure and includes a band around $\beta \in [0.7, 0.99]$, $\eta L$ in the upper portion of $[\gamma_{\mathrm{crit}}(\beta), 2(1+\beta))$.

3. **Document directions A1–A4, B1–B5 in the failure-pattern archive** (`workspace/failure_patterns.md`), as these are likely starting points for future research on accelerated lower-bound techniques.

### New failure patterns (to archive)

1. **Symmetric-orbit-averaging-collapse:** Any rotationally-symmetric cycling-style hard instance has time-average $= x^\star$, killing the bias term on averaged iterate. To get a non-zero bias on averaged iterate, need an asymmetric construction — but asymmetry breaks the cycling identity.

2. **Geometric-decay-vs-1/T-rate incompatibility:** If SHB converges geometrically (which it can under zero-momentum init for some $(\beta, \eta) \in \mathcal{F}$), no transient-based argument can give $\Omega(1/T)$ uniformly in $T$. This rules out short-window LB tricks.

3. **Cycling-attractor-region-dependence:** The cycling orbit's basin of attraction under zero-momentum init depends on $(\beta, \eta)$ in a non-trivial way. Numerical evidence shows it's a strict subset of $\mathcal{F}$, with the basin shrinking near the lower boundary $\eta L = \gamma_{\mathrm{crit}}(\beta)$ and growing near the upper boundary $\eta L = 2(1+\beta)$.

4. **Information-vs-computation-equivalence of HB and AC-SA:** Both methods access the same gradient information; the acceleration gap is in *how* they use it. Information-theoretic LBs (Nemirovski–Yudin, Agarwal) cannot separate them.

5. **PEP-witness inexplicitness:** PEP gives algorithm-tight upper bounds with implicit witnesses, but extracting an *explicit, simple* function class realizing the worst case is a separate (and often harder) problem.

---

*End of upgrade report.*
