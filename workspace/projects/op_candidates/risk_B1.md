# Risk Assessment: B1 — Bilevel Optimization Last-Iterate Lower Bound

Date: 2026-04-28

---

## Early-Exit Check

**Has anyone proved a bilevel last-iterate LB?**

Confirmed: NO. Search of 2023-2026 literature finds:
- Ji 2511.19656 (Nov 2025): oracle complexity LB for standard SFO. Not last-iterate.
- Chen-Zhang 2511.22331 (Nov 2025): oracle complexity LB on κ-dependence. Not last-iterate.
- Kwon et al. 2402.07101 (2024): oracle LB for y*-aware oracle. Not last-iterate.
- Ji-Liang JMLR 2023: oracle LB for SC-SC and convex-SC. Not last-iterate.
- No paper in arXiv/JMLR/NeurIPS/ICML/ICLR as of April 2026 proves a bilevel last-iterate LB.

**EARLY-EXIT CONDITION NOT TRIGGERED. Direction remains open.**

---

## Threat Landscape

### Known Obstructions

**O1. Hypergradient is not a direct gradient.**
The hypergradient ∇φ(x) involves an implicit function inversion. This means:
- The bilevel oracle is not a standard SFO; it has nested structure.
- Standard LB proof templates (Nemirovski-Yudin, Le Cam for smooth nonconvex) assume a clean gradient oracle. For bilevel, the algorithm receives gradients of f and g separately, not of φ directly.
- **Implication**: Must either (a) reduce to single-level by constructing instances where ∇φ(x) has a clean form (quadratic lower level), or (b) prove LB directly at the level of the composite oracle. Route (a) is the safer bet.

**O2. Two-timescale coupling complicates clean iteration analysis.**
Last-iterate LBs in single-level optimization track the trajectory of a single sequence x_t. In bilevel, x_t and y_t are coupled and updated on different timescales. The "last iterate" could mean (x_T, y_T) or (x_T, y*(x_T)). Need to clarify which is the target and ensure the LB applies.
- **Implication**: Most natural formulation is last x_T with inner loop run to convergence (y approximated to precision δ per outer step). This is the AID/ITD regime. Fixing this avoids most coupling complications.

**O3. Hard instance must survive the nested structure.**
The OP-2 hard instance (cycling quadratic) must be embeddable into a bilevel problem such that the induced hyper-objective φ(x) retains the oscillating structure. For quadratic lower level g(x,y) = ½‖y - Cx‖², we have φ(x) = f(x, Cx), reducing to a modified single-level problem. The hard instance works IF f(x, Cx) oscillates — which it does if f has the right x-dependence. This reduction is clean but must be verified.
- **Implication**: The construction is likely straightforward, but requires a careful proof that the bilevel oracle in this instance provides no more information than the single-level oracle for φ.

**O4. Oracle complexity LBs already exist (Ji 2511.19656).**
Ji's Nov 2025 paper already establishes the first stochastic oracle complexity LB for bilevel. This means:
- The result exists but is NOT last-iterate.
- A last-iterate extension is a natural follow-up but could be perceived as incremental.
- **Implication**: Need to explicitly articulate the gap: oracle complexity LBs count total steps to ε-stationarity, but last-iterate LBs say something stronger — the final output of any online method cannot be simultaneously at an ε-stationary point without Ω(T) steps per output, even with optimal averaging. This is a qualitatively different and stronger statement with direct algorithmic consequences.

---

## 6-Week Feasibility: MEDIUM

### Week-by-Week Plan

**Week 1**: Formalize the problem. Choose oracle model (standard SFO, fully first-order). State the precise last-iterate LB theorem. Identify quadratic lower-level reduction. Verify numerically that the OP-2 hard instance lifts to bilevel via φ(x) = f(x, Cx).

**Week 2**: Prove the hard instance reduction theorem. Show: if φ(x) = f(x, Cx) and the bilevel algorithm uses standard SFO for f and g, then any algorithm for bilevel induces an algorithm for minimizing φ with the same oracle efficiency. Le Cam two-point on φ.

**Week 3**: Extend Le Cam argument to show last-iterate x_T cannot achieve ε-stationarity faster than averaging. This is essentially OP-2's argument applied to φ — the main new work is (a) verifying φ has the right smoothness/structure, and (b) bounding how much the hypergradient approximation error contaminates the hard instance.

**Week 4**: Handle hypergradient bias bookkeeping. Prove that the hypergradient estimator in the hard instance has bounded bias that does not help the last iterate escape the oscillation. This is the highest-risk week.

**Week 5**: Write up. Numerical verification in NumPy/SymPy.

**Week 6**: Revise, sharpen bounds, compare with Ji 2511.19656 (oracle LB), articulate contribution clearly.

### Feasibility Assessment

- If the quadratic lower-level reduction (Week 2) goes through cleanly: MEDIUM-HIGH. Weeks 3-4 are extensions of proven OP-2 techniques.
- If the reduction fails (φ loses the right structure): LOW. Would need a fundamentally new hard instance.
- The main uncertainty is Week 4 (hypergradient bias). If the bias term can be made negligible in the quadratic case (very plausible), the proof closes. If not, the argument requires a new angle.

Overall: **MEDIUM** (60-65% probability of a complete proof in 6 weeks).

---

## Top 3 Risks

### Risk 1: Quadratic Reduction Breaks the Hard Instance
**Probability**: 25%
**Description**: The oscillating structure of the OP-2 hard instance may be destroyed when composed with y*(x) = Cx. Specifically, if C has large spectral norm, the Hessian of φ(x) = f(x, Cx) may be dominated by the y-curvature term rather than the designed x-oscillation, and the cycling instance collapses.
**Mitigation**: Choose C with small spectral norm (e.g., C = εI for small ε). Verify numerically in Week 1. Fallback: construct φ directly (not via f composition) — but then need to prove φ is realizable by a bilevel instance, which is harder.

### Risk 2: Hypergradient Bias Contaminates the LB Argument
**Probability**: 30%
**Description**: In the hard instance, the algorithm observes noisy hypergradient estimates. If the bias from inner-loop approximation is O(ε) per step and has systematic structure (e.g., always pointing away from the oscillation axis), it could accidentally "help" the last iterate converge, invalidating the LB.
**Mitigation**: Choose the hard instance such that the hypergradient bias is zero on the oscillation axis (orthogonal decomposition). For quadratic lower level, bias can be computed exactly and verified to be orthogonal to the cycling direction. This is non-trivial but feasible.

### Risk 3: Perceived Incrementalism over Ji 2511.19656
**Probability**: 35% (as a paper acceptance risk, not a mathematical risk)
**Description**: Ji's Nov 2025 paper already proves oracle complexity LB for bilevel with standard SFO. Reviewers may see a last-iterate extension as a minor variant ("just apply OP-2 ideas to bilevel"). This is a positioning risk, not a proof risk.
**Mitigation**: Explicitly prove that the last-iterate LB is NOT implied by oracle complexity LBs (they are logically independent). Show an algorithm that achieves optimal oracle complexity but has bad last-iterate behavior — this separation is the novel contribution. Also emphasize the algorithmic consequence: practitioners who use the last iterate of bilevel SGD (common in meta-learning) have no guarantee without new upper bounds.

---

## Summary

| Dimension | Assessment |
|---|---|
| Early-exit triggered? | NO — direction open |
| Key mathematical risk | Quadratic reduction + bias bookkeeping |
| Key strategic risk | Incrementalism over Ji 2511.19656 |
| 6-week feasibility | MEDIUM (60-65%) |
| Recommended go/no-go | CONDITIONAL GO — green if Week 1 numerical check passes |
