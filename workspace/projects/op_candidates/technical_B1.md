# Technical Analysis: B1 — Bilevel Optimization Last-Iterate Lower Bound

Date: 2026-04-28

---

## Problem Setup (Proposed)

Standard nonconvex-SC bilevel:

    min_{x} φ(x) := f(x, y*(x))
    s.t.  y*(x) = argmin_y g(x, y)

where f is nonconvex in x, g is μ_y-strongly convex in y (κ = L_y/μ_y). Stochastic oracle model: at each step receive noisy (∇_x f, ∇_y f, ∇_x g, ∇_y g) estimates.

Target: prove that no (zero-respecting) stochastic first-order algorithm can guarantee ‖∇φ(x_T)‖ ≤ ε (last iterate, high probability or in expectation) without Ω(f(κ, ε)) oracle calls, with a rate strictly worse than what averaging achieves.

---

## Reusable Pipeline Tools from OP-2

### Directly Transferable

1. **Le Cam two-point argument**: Already know how to construct two problem instances (P+, P-) that are indistinguishable for T steps and diverge on the quantity of interest. For bilevel: P+/P- differ in the upper-level function f; the lower level g is shared → same y*(x) → hypergradient oracle looks identical for T steps. This transfer looks clean.

2. **Zero-respecting algorithm framework**: Standard Nesterov span argument. Works for any oracle model where algorithm outputs lie in the span of received gradient vectors. Bilevel zero-respecting: output x_t lies in span{∇_x f(x_s, y_s), ∇_y g(x_s, y_s) : s < t}. This is well-defined and the framework applies directly.

3. **Cycling hard instance (oscillation construction)**: OP-2's ln-cosh construction or quadratic cycling. For bilevel: need to embed cycling at the level of φ(x) = f(x, y*(x)), not f directly. Since y*(x) is smooth in x (SC lower level), φ(x) inherits Lipschitz-smooth structure from f. Cycling on φ is achievable via quadratic lower level (y*(x) = A⁻¹b(x)) and oscillating upper level f.

4. **Descent-lemma telescope**: For the auditor/upper bound side. Not needed for LB, but useful for verifying the gap.

### Partially Transferable (Requires Adaptation)

5. **SHB momentum analysis**: In OP-2, the heavy-ball specific structure was crucial. For bilevel, the "algorithm" is more general (AID/ITD/penalty-gradient), so OP-2's momentum-specific tricks may not be needed. The LB should be algorithm-agnostic.

6. **Information-theoretic lower bound (Fano/Le Cam)**: OP-2 used Le Cam for the last-iterate specifically. Extension to bilevel requires showing the Fisher information of the bilevel oracle is bounded — this needs new work because the hypergradient oracle is composite (implicit function).

---

## New Development Required

### 1. Hypergradient Bias Bookkeeping (HIGH EFFORT)

The hypergradient is:
    ∇φ(x) = ∇_x f(x, y*(x)) - ∇²_{xy}g(x,y*(x)) [∇²_{yy}g(x,y*(x))]⁻¹ ∇_y f(x,y*(x))

In practice the algorithm only has access to noisy, approximate versions of each term. The bias from approximating y*(x) propagates into the hypergradient estimate.

For a last-iterate LB, you need to track how this bias accumulates vs. how an averaging argument might cancel it. Key challenge: **the bias is state-dependent** (depends on x_t), so standard i.i.d. noise models for single-level SGD don't apply.

Approach: Use the parametric structure. For quadratic g(x,y) = ½y^T A y - b(x)^T y, we have y*(x) = A⁻¹b(x) and ∇φ(x) = ∇_x f(x, A⁻¹b(x)) - (∇b(x))^T A⁻¹ ∇_y f(x, A⁻¹b(x)). The bias bookkeeping simplifies dramatically in this quadratic case, which is also the natural hard instance class.

### 2. Nested Oracle Complexity Accounting (MEDIUM EFFORT)

Existing LBs (Ji 2511.19656, Kwon 2402.07101) count total oracle calls across both levels. A last-iterate LB must bound the number of outer steps T (iterations of x-update) separately from inner approximation steps.

Two-timescale structure: typical bilevel algorithms run K inner steps per outer step. The LB argument must be stated either in terms of (T, K) jointly or under a specific scheduling assumption. Recommendation: fix the two-timescale ratio K = O(log(1/ε)/μ_y) as is standard, and prove the LB in terms of outer iterations T, matching the "per outer step" cost of best-iterate methods.

### 3. Last-Iterate Separation Mechanism (HIGH EFFORT, CORE NOVELTY)

The key technical question: **why does last-iterate do worse than averaging for bilevel?**

Hypothesis: The hypergradient noise has state-dependent variance that cannot be cancelled by last-iterate but can be cancelled by averaging. Specifically, the variance of the hypergradient estimator at step t depends on ‖x_t - x*‖, making the effective noise heteroscedastic. Averaging smooths this; last-iterate must "land" in the noise regime.

Candidate construction:
- Upper level: f(x) = quadratic with oscillating gradient near x* (OP-2 cycling structure on φ).
- Lower level: g(x,y) = ½‖y - Cx‖² with C chosen so that y*(x) = Cx and ∇φ(x) = (∇f)(x) - C^T ∇_y f(x, Cx). This makes the bilevel problem equivalent to a single-level problem with modified gradient. The hard instance for single-level (OP-2) then lifts directly.

If this reduction works: the bilevel last-iterate LB reduces to the OP-2 result under appropriate parameter matching. This would be a powerful structural theorem.

### 4. Oracle Model Clarification (MEDIUM EFFORT)

Must decide: standard SFO (unbiased for both f and g gradients), y*-aware oracle (Kwon 2024), or AID-style (Hessian-vector products available). The LB should target the weakest oracle (standard SFO) to be most impactful. But the reduction in point 3 above suggests working with fully first-order SFO.

---

## Numerical Verification Feasibility

**Assessment: HARD but not impossible.**

- Single-level OP-2 cycling instances were verified by SymPy/NumPy: track x_t trajectory, verify oscillation, confirm averaging converges faster. This required ~50-100 lines of Python.
- Bilevel numerical simulation: need to simulate inner loop (gradient descent on g) + outer step. For quadratic lower level, this is exact (y*(x) = A⁻¹b(x) is computable). Verification is feasible in NumPy.
- Hypergradient bias tracking: can track the bias term ‖ŷ_t - y*(x_t)‖ numerically to verify it feeds into last-iterate oscillation.
- SymPy symbolic verification: only feasible for 2D toy instances (1D x, 1D y). Higher dimensions require numerical.

Recommendation: 2D symbolic verification + 5D numerical verification as the two-mode check. This is non-standard compared to OP-2 but doable.

---

## Summary Table of Tool Reuse

| Tool | OP-2 Status | B1 Reuse | Modification Needed |
|---|---|---|---|
| Le Cam two-point | Proven | Direct | Hard instance construction on φ |
| Cycling construction | Proven | Partial | Lift from f to φ via quadratic LL |
| Zero-respecting framework | Proven | Direct | Extend span definition to bilevel oracle |
| Momentum SHB analysis | Proven (OP-2 specific) | Not needed | LB is algorithm-agnostic |
| Descent telescope | Proven | Not needed | Only for UB side |
| Hypergradient bias | Not in OP-2 | New | Core new development |
| Two-timescale accounting | Not in OP-2 | New | Medium effort |
| Last-iterate separation mechanism | Proven (OP-2) | Partial | Reduction to single-level is the key bet |
