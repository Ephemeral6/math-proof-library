/-
Result R.421 — R-primitive (knowledge injection) always has non-negative effect.

Reference: `workspace/coe_mip_unification.md` §R.421 ("R 总是正效应" 定理,
A 级: case 1 严格 / case 2 在 "R 至少覆盖差集" 前提下严格).

**Statement (CoE × MIP mapping).** The R-primitive injects base knowledge
elements into the agent's knowledge set `K`. Map the relevant model
conditions into hypotheses:

* `K_A`   — `|K(A)|` of the baseline agent,
* `K_AR`  — `|K(A_R)|` after R injection,
* the *monotone knowledge expansion* `K(A_R) ⊇ K(A) ∪ K(e_R)`, encoded as
  the cardinality inequality `K_A ≤ K_AR`,
* the emergence cost `N` is determined by the central relation
  `N ≈ r · |log κ| · Z` where `r := r(K)` is the *uncovered* requirement
  count, a **non-increasing** function of `|K|` (more knowledge never
  increases the residual requirement),
* `ΔN_R := N(A) − N(A_R)` is the R-effect.

The theorem: under coverage `R(p) ⊆ K(A_R)` and the monotone-cost premise,
`ΔN_R ≥ 0` **unconditionally** — knowledge injection never hurts emergence.

**Pure-math content.** The kernel is a monotonicity/sign statement:

* (i) `K_A ≤ K_AR` (knowledge expands).
* (ii) Given a non-increasing cost map `N` of the knowledge level, the
  effect `ΔN_R = N(K_A) − N(K_AR) ≥ 0`.

We encode the cost as an arbitrary antitone real map of the knowledge
level, so the sign result holds for *any* model obeying R.058
("`≼` ⟹ `N` monotone"). We additionally encode the central-relation
form `N = r · |log κ| · Z` and show that when only the requirement factor
`r` drops (`r_AR ≤ r_A`) with `|log κ|, Z ≥ 0` fixed, the effect is
non-negative — the algebraic kernel behind "R drops `r`".

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Order.Monotone.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace RPrimitive

/-- **R.421 (i) — knowledge expansion is monotone.**

If `K(A_R) ⊇ K(A) ∪ K(e_R)` (encoded as the union-cardinality lower bound
on `K_AR`), then in particular `K_A ≤ K_AR`: R never shrinks the
knowledge set. -/
theorem R_421_knowledge_expands
    (K_A K_eR K_overlap K_AR : ℝ)
    (h_union_lb : K_A + K_eR - K_overlap ≤ K_AR)
    (h_overlap_le : K_overlap ≤ K_eR) :
    K_A ≤ K_AR := by
  -- |K(A) ∪ K(e_R)| = |K_A| + |K_eR| − |overlap| ≥ |K_A|  since overlap ≤ |K_eR|.
  have : K_A ≤ K_A + K_eR - K_overlap := by linarith
  linarith

/-- **R.421 (iii) — non-negative effect for any antitone cost map.**

Model the emergence cost `N` as an antitone (non-increasing) function `cost`
of the knowledge level (R.058: `K(A) ⊆ K(A_R)` ⟹ `A ≼ A_R` ⟹
`N(A_R) ≤ N(A)`). Then with `K_A ≤ K_AR`, the R-effect
`ΔN_R := cost K_A − cost K_AR ≥ 0`.

This is the unconditional-sign theorem: more knowledge never increases `N`. -/
theorem R_421_effect_nonneg
    (cost : ℝ → ℝ) (h_anti : Antitone cost)
    (K_A K_AR : ℝ) (h_expand : K_A ≤ K_AR) :
    0 ≤ cost K_A - cost K_AR := by
  have : cost K_AR ≤ cost K_A := h_anti h_expand
  linarith

/-- **R.421 — central-relation algebraic kernel (`R` drops `r`).**

With the central relation `N = r · |log κ| · Z` and `|log κ|, Z ≥ 0`, if R
reduces the uncovered-requirement factor `r_AR ≤ r_A` (its primary effect
on `|K|`, leaving `|log κ|` and `Z` fixed at first order), then

    ΔN_R = N_A − N_AR = (r_A − r_AR) · |log κ| · Z ≥ 0 . -/
theorem R_421_central_relation_effect_nonneg
    (r_A r_AR absLogκ Z N_A N_AR : ℝ)
    (h_NA  : N_A  = r_A  * absLogκ * Z)
    (h_NAR : N_AR = r_AR * absLogκ * Z)
    (h_r_drop : r_AR ≤ r_A)
    (h_logκ_nonneg : 0 ≤ absLogκ) (h_Z_nonneg : 0 ≤ Z) :
    0 ≤ N_A - N_AR := by
  have h_diff : N_A - N_AR = (r_A - r_AR) * absLogκ * Z := by
    rw [h_NA, h_NAR]; ring
  rw [h_diff]
  apply mul_nonneg
  · apply mul_nonneg
    · linarith
    · exact h_logκ_nonneg
  · exact h_Z_nonneg

/-- **R.421.a — Type III → Type I/II (∞ → finite as a sign statement).**

Encode the finiteness dichotomy of R.421 (ii) case 2 numerically: before R,
the cost takes a sentinel "infinite" value `N_inf` (a fixed large bound);
after R, coverage `R(p) ⊆ K(A_R)` makes the cost finite, `N_AR ≤ N_inf`.
The effect is still non-negative. -/
theorem R_421_a_type3_to_finite
    (N_inf N_AR : ℝ) (h_finite : N_AR ≤ N_inf) :
    0 ≤ N_inf - N_AR := by
  linarith

end RPrimitive

end MIP
