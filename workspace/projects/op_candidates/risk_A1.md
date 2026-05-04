# Risk Assessment: A1 — Adam Last-Iterate Lower Bound

**Date**: 2026-04-28

---

## 1. Has the Gap Been Silently Closed?

**Answer: NO — with high confidence as of April 2026.**

### Evidence for gap being open

- **2604.10728** (Preobrazhenskaia et al., Apr 2026) — the most recent paper directly on adaptive method last-iterate LBs — treats AdaGrad-Norm in the convex non-smooth setting and explicitly lists "investigating the last-iterate convergence of related methods such as RMSProp and Adam" as open future work. A paper published 2 weeks ago would not have omitted Adam results if they existed.

- **NeurIPS 2024 papers** (#3 and #4 in literature) prove Adam achieves O(poly(log T)/√T) in non-convex; no companion LB for convex smooth last-iterate is given.

- **No paper found** using queries: "Adam last iterate lower bound stochastic convex smooth matching" (Apr 2026), "Adam last iterate Omega sigma D sqrt T" — zero hits. The non-convex O(ε⁻⁴) LB (Arjevani et al.) is cited but that is a *gradient oracle* LB for all first-order methods, not an *Adam-specific last-iterate* LB.

- **ICML 2025** and **ICLR 2025** proceedings checked via indirect searches; no Adam-specific last-iterate LB in convex setting found.

### Scenario that could invalidate (risk level: LOW)

A workshop paper or unpublished arXiv preprint from late 2025 / early 2026 could exist but not yet be indexed. Given the small community working on this exact question, this is unlikely but non-zero.

**Verdict**: Gap is **genuinely open** as of April 2026. Probability of silent closure: ~10%.

---

## 2. Known Technical Obstructions

### Obstruction 1: v_t EMA breaks the cycling lemma's recurrence (MAJOR)

**Severity**: HIGH for cycling-based Adam-specific LB; LOW for Le Cam route.

The SHB cycling LB (Goujaud-Taylor-Dieuleveut 2023 + OP-2's extension) relies on a fixed linear recurrence:
$$x_{t+1} = (1+\beta)x_t - \beta x_{t-1} - \eta \nabla f(x_t)$$
whose eigenvalue structure admits period-K cycling. Adam's update is:
$$x_{t+1} = x_t - \frac{\alpha \hat{m}_t}{\hat{v}_t^{1/2} + \epsilon}$$
where both $\hat{m}_t$ and $\hat{v}_t$ are state-dependent. On a quadratic $f(x) = \frac{L}{2}x^2$, in the deterministic setting, Adam's dynamics reduce to a **nonlinear time-varying** system. Period-K cycling with exact recurrence is not available unless $v_t$ stabilizes — which it does at $v_\infty = L^2 x_\infty^2$, but this is the fixed-point value at convergence, not at a cycle vertex.

**Implication**: The cycling route for an Adam-specific LB (as opposed to a general first-order LB) is blocked. The Le Cam route is unaffected.

### Obstruction 2: Bias correction $1/(1-\beta_2^t)$ creates time-varying effective step

**Severity**: MEDIUM.

Adam's bias correction means the effective step size changes over time even on the same instance. This complicates martingale arguments (as in OP-2's variance proof) because the effective learning rate is not monotonically decreasing. However, for large $t$, $(1-\beta_2^t) \to 1$ and the correction vanishes. A clean proof would restrict attention to $t \geq T_0 = O(\log(1/\delta)/(1-\beta_2))$ epochs where correction is negligible.

**Implication**: Manageable with $T_0$ transient burn-in argument. Minor complication, not a blocker.

### Obstruction 3: Algorithm-specific vs. class LB ambiguity

**Severity**: MEDIUM.

The Arjevani et al. 2023 LB is for ALL first-order methods with bounded variance. An Adam-specific LB (showing Adam is suboptimal relative to some other method) would require a **separation** result: a class of functions where Adam provably does worse than the minimax-optimal algorithm. This is a much harder statement.

The more feasible goal is: an Adam-specific hard instance where the last iterate of Adam achieves only $\Omega(\sigma D / \sqrt{T})$, which matches (rather than beats) the information-theoretic lower bound. This would show Adam's last iterate is **tight at the optimal rate** — not suboptimal, just not better than the LB. This is still publishable as "Adam achieves the minimax LB for last iterates in smooth convex stochastic optimization."

### Obstruction 4: β₁ momentum term creates compounding bias

**Severity**: LOW (manageable by setting β₁ = 0).

The $\beta_1$-momentum ($\hat{m}_t$ term) makes Adam harder to analyze than AdaGrad-Norm or RMSProp. Setting $\beta_1 = 0$ (pure RMSProp) eliminates the $m_t$ state, making the analysis tractable. A lower bound for RMSProp ($\beta_1 = 0$) with $\beta_2 > 0$ is a legitimate, publishable result that is a strict sub-case of Adam.

---

## 3. 6-Week Publication-Quality Feasibility

**Assessment: MEDIUM**

### Supporting factors

- Trivial lower bound ($\Omega(\sigma^2/\sqrt{T})$ via constant-gradient instance) is achievable in **days** by direct transplant from AdaGrad-Norm LB in toolbox.
- Le Cam route in noise-dominated regime reduces to OP-2's variance term proof (already verified, PASS audit). Adaptation for Adam likely takes **1–2 weeks**.
- The key technical novelty (v_t concentration in noise-dominated regime) is a standard concentration argument — not fundamentally new mathematics.
- SymPy/mpmath numerical verification is quick (30–60 min), enabling rapid iteration.

### Blocking factors

- **What's genuinely new**: The separation between Adam last-iterate and SGD last-iterate (showing Adam's last iterate doesn't benefit from adaptivity), or more ambitiously, showing Adam's last iterate is O(1/T^{1/4}) in convex non-smooth (like AdaGrad-Norm). If the target is only matching the SGD lower bound (not beating it), the result may be seen as incremental.
- **The interesting result requires convex smooth + last iterate vs average separation**: analogous to AdaGrad-Norm's O(1/N^{1/4}) last-iterate vs O(1/√N) average result. This requires a dedicated hard instance analysis — not straightforward in 6 weeks for a polished paper.
- **Risk of incremental outcome**: If the result is "Adam achieves the same Ω(σD/√T) LB as SGD in smooth convex," reviewers may ask: what's new? The answer is "it's algorithm-specific proof, not just oracle complexity," but this may not be enough for top venues without the separation result.

**Verdict**: A 6-week timeline can produce **a sound theorem and proof** (medium complexity). Getting it to **top-venue publication quality** (ICML/NeurIPS) likely needs 10–12 weeks for the separation result. As a **workshop paper or collaboration-seed**, 6 weeks is feasible.

---

## 4. Top 3 Risks Ranked

### Risk 1 (HIGHEST): Result is technically correct but narratively underwhelming (probability: 50%)

The most likely outcome in 6 weeks is: Ω(σD/√T) last-iterate LB for Adam in smooth stochastic convex, matching the general SGD lower bound. This is **correct and non-trivial** but may be perceived as "applying the OP-2 technique to a slightly different algorithm." Without a **separation result** (Adam last-iterate is provably worse than Adam average, or worse than a different adaptive method), reviewers may rate it as incremental.

**Mitigation**: Frame the contribution as establishing the first algorithm-specific last-iterate LB for Adam in the smooth convex setting, emphasizing that existing LBs (Arjevani et al.) do not distinguish last iterate from average iterate.

### Risk 2 (MEDIUM): v_t cycling obstruction turns out to be insurmountable for interesting cases (probability: 30%)

If the only achievable LB via the Le Cam route matches the SGD lower bound (not better), and the cycling route is completely blocked, then the result has limited novelty. The interesting result — that Adam's last iterate is O(1/T^{1/4}) in convex non-smooth (like AdaGrad-Norm) — requires a different analysis that may take 3+ months.

**Mitigation**: Target the smooth convex case (where AdaGrad-Norm achieves O(1/√N) anyway), and show Adam's last iterate also achieves the matching Ω(1/√N) LB. This is a positive, tight result.

### Risk 3 (LOWER): Silent closure by a concurrent preprint (probability: 10–15%)

Given the Apr 2026 AdaGrad-Norm paper explicitly listing Adam as future work, someone may be working on this right now. A simultaneous submission to NeurIPS 2026 could scoop the result.

**Mitigation**: Move quickly. The trivial LB can be posted as a short arXiv note within 2–3 weeks to establish priority on the basic result.
