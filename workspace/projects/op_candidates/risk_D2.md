# Risk Assessment: D2 — Symbolic Regression Sample Complexity Lower Bound

**Date**: 2026-04-28

---

## Top 3 risks

### Risk 1 (HIGH): Existing PAC theory already implicitly covers restricted S

**Description**: For finite hypothesis class S with |S| = M, the standard PAC lower bound gives n* = Ω(log M / ε^2) and the standard ERM upper bound gives n* = O(log M / ε^2). If D2 only achieves this, the result is a corollary of Blumer et al. (1987) applied to a finite class — not novel.

**What makes D2 non-trivial**: The interesting regime is when S is infinite (real-valued leaf constants). Here VC dimension is Ω(s), but the VC argument loses the combinatorial structure of expression trees. The novel contribution is obtaining a lower bound that explicitly depends on (s, d, Σ) — i.e., on the symbolic structure — rather than just a dimension count.

**Mitigation**: Frame the result as tight dependence on (s, log|Σ|) simultaneously, not just on one parameter. The Fano + packing approach (Route A in technical_D2.md) achieves this. The finite-class PAC bound does not show the log|Σ| factor explicitly.

**Residual risk level**: Medium. If the referee argues that the enumeration bound M = exp(Ω(s log|Σ|)) is "obvious" and applies standard PAC directly, the novelty rests on the tightness and on the L^2 separation lemma. Need to ensure the separation lemma is genuinely non-trivial.

---

### Risk 2 (HIGH): Result is class S-dependent and unmotivated without a canonical choice

**Description**: Any result will have the form "for S with parameters (d, s, Σ), n* = f(d, s, Σ)." If the choice of S is arbitrary, the result feels like a parameterized exercise rather than a conceptual contribution. Reviewers will ask: "What is the 'right' S?"

**Mitigation options**:

(a) **AI Feynman class**: S = expressions appearing in the Feynman symbolic regression benchmark (Udrescu & Tegmark 2020). This is a concrete, community-accepted benchmark class. Depth ≤ 6, size ≤ 20, Σ = {+, ×, ÷, sqrt, exp, log, sin, cos}. Motivated by physics.

(b) **Minimal class for universality**: S = depth-d expressions over {+, ×, const} are closely related to sparse polynomial classes; one can show they are dense in L^2 for d large enough. This connects SR to polynomial approximation theory.

(c) **Operator complexity class**: S parameterized by |Σ| only (e.g., Σ = {+, ×, σ} for some nonlinear σ). Lower bound in terms of |Σ| alone.

**Recommended choice**: Option (a) with a rigorous definition. This maximizes community relevance (AI4Math angle), anchors the result to real data, and gives the endorsers (陈小杨 AI4Math, 袁洋 AI theory) a concrete hook.

**Residual risk level**: Medium-low if (a) is adopted.

---

### Risk 3 (MEDIUM): L^2 separation lemma for operator perturbations fails for certain P_X

**Description**: The packing construction (replace sin by exp in one leaf node) works only if the resulting function pair is Δ-separated in L^2(P_X). For P_X heavily concentrated near x = 0 (where sin(x) ≈ x ≈ exp(x) − 1 to first order), the two functions are nearly indistinguishable, and Δ can be arbitrarily small.

**Mitigation**: 

(a) Choose P_X = Uniform[a, b]^k with a > 1 (so sin and exp differ substantially). E.g., P_X = Uniform[1, 2] gives |sin(t) − exp(t)| ≥ 0.5 on [1,2] — this is verifiable numerically.

(b) Alternatively, state the lower bound conditionally on P_X satisfying a "non-degeneracy" condition (a separation margin condition), and show this is satisfied for natural distributions.

(c) Use a different operator pair for packing: sin(x) vs. x^2 (polynomial vs. trigonometric). These are always Ω(1)-separated on Uniform[0,1] for a wide range of subtree inputs.

**Residual risk level**: Low — this is a concrete technical lemma that can be handled by choosing P_X or operator pair appropriately.

---

## Additional risks (lower severity)

### Risk 4: Upper bound is harder than expected

The matching upper bound (n = O(s log|Σ|) suffices via ERM) requires a Rademacher or covering number bound for S. For expression trees with real constants, this is a VC-dimension-style bound and is likely in the literature (e.g., via Bartlett-Maiorov covering numbers for neural-network-like classes). Failure here means D2 has only the lower bound, which is a valid but weaker paper.

**Assessment**: Manageable. Lower bound alone is publishable at COLT/NeurIPS level if the tight matching structure is clear.

### Risk 5: Noise model dependence

Results may differ significantly between noiseless recovery and noisy (Gaussian additive) recovery. The noiseless case is cleaner for the exact recovery question but less physically motivated. Noisy case requires specifying σ explicitly.

**Assessment**: Standard — state both clearly, primary result for noiseless (ε-recovery), secondary for noisy case.

---

## 6-week feasibility assessment

| Week | Task | Feasibility |
|---|---|---|
| 1 | Fix class S (Feynman-inspired); prove enumeration bound on \|S(d,s,Σ)\| | High |
| 2 | Construct explicit packing set; prove L^2 separation lemma for chosen P_X | Medium-high |
| 3 | Apply Fano's inequality (pipeline reuse from xu-raginsky); derive n* = Ω(s log\|Σ\|) | High |
| 4 | Prove PAC realizability lower bound as alternative route; noiseless exact recovery | Medium |
| 5 | Draft matching upper bound sketch (Rademacher complexity of S) | Medium — may be skipped |
| 6 | Numerical verification (PySR/gplearn experiments); write up | High |

**Overall 6-week feasibility**: **Medium-high**. The core lower bound (Weeks 1–3) is achievable in 3 weeks given pipeline infrastructure. The main risk is Week 2 (separation lemma). The upper bound (Week 5) can be deferred to a follow-up.

**Minimum viable result**: Lower bound n* = Ω(s log|Σ|) for noiseless exact recovery on Feynman-class expressions, proved via Fano + packing, with verified empirical phase transition via PySR. This is a complete, submittable result.

---

## Comparison to OP-2 risk profile

OP-2 (SHB stochastic non-SC last-iterate lower bound) was a pure optimization theory result with a well-defined reduction route. D2 has a broader risk surface because it touches three fields (combinatorics, learning theory, symbolic regression). However, the central technical difficulty is lower (Fano + packing is less subtle than lower bound for last-iterate) and the literature gap is more clearly open.

**Risk verdict**: D2 is lower technical risk and higher positioning risk (need to pick the right S). OP-2 was the reverse.
