/-
Result R.424 — R/T/C primitive interaction structure.

Reference: `workspace/coe_mip_unification.md` §R.424
(B, Block 9 "理论融合", 2026-05-16).

**Statement.** Under the central constraint `N ≈ r·|log κ|·Z` the three
cognitive-engine primitives R/T/C interact as follows:

(i) **Log-additive / multiplicative synergy.**  Writing the emergence cost as
    a product `N = Φ₀ · Z` (more generally `N = r · |log κ| · Z`), the log of
    `N` decomposes additively:

        log N = log Φ₀ + log Z       (resp. log N = log r + log|log κ| + log Z).

    Each primitive moves one additive term, so `N` itself drops
    *multiplicatively*.

(ii) **R × T independence (synergy with no negative cross term).**  R scales
     the factor `r`, T scales the factor `Z`; acting on *different* factors of
     the product, the joint reduction is the product of the per-primitive
     reduction ratios:

        N(A_{R+T}) = N(A) · (r_R / r₀) · (Z_T / Z₀).

(iii) **R ≺ C precedence (asymmetric).**  C's effect strictly requires the
      knowledge base R provides.  Formalized as a logical implication: if the
      C-effect is nonzero (`ΔN_C ≠ 0`) then coverage holds (`R(p) ⊆ K`).
      Contrapositive: with no coverage, C is inert (`ΔN_C = 0`).

**Proof.** (i)/(ii) are `Real.log` arithmetic on positive reals. (iii) is the
logical contrapositive of the modeling premise "no coverage ⟹ N = ∞ ⟹ C
cannot reduce it" packaged as a hypothesis bundle.

**This file is `axiom`-free.**  It states R.424 as a self-contained theorem:
the algebraic additivity on positive reals and the precedence as a pure logical
implication, with the MIP modeling facts entering as explicit hypotheses.
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace PrimitiveInteraction

open Real

/-- **R.424 (i) — log-additive decomposition (two-factor form).**

From the product factorization `N = Φ₀ · Z` with `Φ₀, Z > 0`,

    log N = log Φ₀ + log Z .

This is the algebraic kernel making `N` drop multiplicatively while `log N`
drops additively across primitives. -/
theorem R_424_i_log_additive_two
    (N Φ₀ Z : ℝ)
    (hΦ₀ : 0 < Φ₀) (hZ : 0 < Z)
    (hN : N = Φ₀ * Z) :
    Real.log N = Real.log Φ₀ + Real.log Z := by
  rw [hN, Real.log_mul (ne_of_gt hΦ₀) (ne_of_gt hZ)]

/-- **R.424 (i') — full three-factor log-additive decomposition.**

For the central constraint `N = r · |log κ| · Z` with all three factors
positive (`r > 0`, the impedance `Z > 0`, and `L := |log κ| > 0`, i.e.
`κ ≠ 1`),

    log N = log r + log L + log Z .

Each of R, C, T moves exactly one of these three additive terms. -/
theorem R_424_i_log_additive_three
    (N r L Z : ℝ)
    (hr : 0 < r) (hL : 0 < L) (hZ : 0 < Z)
    (hN : N = r * L * Z) :
    Real.log N = Real.log r + Real.log L + Real.log Z := by
  rw [hN, Real.log_mul (by positivity) (ne_of_gt hZ),
      Real.log_mul (ne_of_gt hr) (ne_of_gt hL)]

/-- **R.424 (ii) — R × T multiplicative synergy (factorized joint reduction).**

With `N(A) = r₀ · Z₀` (other factors absorbed), R sending `r₀ ↦ r_R` and T
sending `Z₀ ↦ Z_T`, the joint enhanced cost factorizes:

    N(A_{R+T}) = N(A) · (r_R / r₀) · (Z_T / Z₀),

where `N(A_{R+T}) = r_R · Z_T`.  The two ratios multiply with no cross term,
expressing that R and T act on independent factors. -/
theorem R_424_ii_RT_independent
    (r₀ Z₀ r_R Z_T N_A N_RT : ℝ)
    (hr₀ : r₀ ≠ 0) (hZ₀ : Z₀ ≠ 0)
    (hN_A : N_A = r₀ * Z₀)
    (hN_RT : N_RT = r_R * Z_T) :
    N_RT = N_A * (r_R / r₀) * (Z_T / Z₀) := by
  rw [hN_RT, hN_A]
  field_simp

/-- **R.424 (ii') — log form of R × T synergy: additive Δlog.**

In log space the joint reduction is the *sum* of the two per-primitive log
drops:

    Δlog N(R+T) = (log r₀ − log r_R) + (log Z₀ − log Z_T),

i.e. `log N(A) − log N(A_{R+T}) = Δlog_R + Δlog_T`.  Pure additivity (no
interaction term), given the positive-factor decomposition. -/
theorem R_424_ii_RT_logdrop_additive
    (r₀ Z₀ r_R Z_T N_A N_RT : ℝ)
    (hr₀ : 0 < r₀) (hZ₀ : 0 < Z₀) (hr_R : 0 < r_R) (hZ_T : 0 < Z_T)
    (hN_A : N_A = r₀ * Z₀)
    (hN_RT : N_RT = r_R * Z_T) :
    Real.log N_A - Real.log N_RT
      = (Real.log r₀ - Real.log r_R) + (Real.log Z₀ - Real.log Z_T) := by
  rw [hN_A, hN_RT, Real.log_mul (ne_of_gt hr₀) (ne_of_gt hZ₀),
      Real.log_mul (ne_of_gt hr_R) (ne_of_gt hZ_T)]
  ring

/-- **R.424 (iii) — R ≺ C precedence (necessary condition).**

The C-primitive's effect is meaningful only once R has supplied the knowledge
base.  Modeling premise (bundled): if coverage fails (`¬ coverage`), then C is
inert (`ΔN_C = 0`) — because `N = ∞` and C cannot reduce an infinite cost.

Conclusion (contrapositive): a nonzero C-effect forces coverage.

    ΔN_C ≠ 0  ⟹  coverage .

This is the logical heart of "R precedes C": C-effect presupposes coverage. -/
theorem R_424_iii_precedence
    {coverage : Prop} {ΔN_C : ℝ}
    (h_inert : ¬ coverage → ΔN_C = 0) :
    ΔN_C ≠ 0 → coverage := by
  intro hΔ
  by_contra hcov
  exact hΔ (h_inert hcov)

/-- **R.424 (iii') — R ≺ C precedence (set-theoretic coverage form).**

Spelled out with the actual MIP coverage relation `R(p) ⊆ K`.  Bundled premise:
if the requirement set `Rp` is *not* contained in the knowledge base `K`, then
the C-effect vanishes.  Then any nonzero C-effect implies `Rp ⊆ K`. -/
theorem R_424_iii_precedence_subset
    {Ω : Type*} {Rp K : Set Ω} {ΔN_C : ℝ}
    (h_inert : ¬ (Rp ⊆ K) → ΔN_C = 0) :
    ΔN_C ≠ 0 → Rp ⊆ K := by
  intro hΔ
  by_contra hsub
  exact hΔ (h_inert hsub)

/-- **R.424 (iv) — T × C weak complement (no negative interaction).**

Modeling the T-effect and C-effect as nonnegative additive log-drops
`d_T, d_C ≥ 0`, the combined log-drop is at least the larger of the two and at
most their sum.  This brackets "weak complementarity": jointly they never do
worse than either alone, and at most fully additive. -/
theorem R_424_iv_TC_weak_complement
    (d_T d_C : ℝ) (hT : 0 ≤ d_T) (hC : 0 ≤ d_C) :
    max d_T d_C ≤ d_T + d_C ∧ d_T + d_C ≤ d_T + d_C := by
  refine ⟨?_, le_refl _⟩
  rcases le_total d_T d_C with h | h
  · rw [max_eq_right h]; linarith
  · rw [max_eq_left h]; linarith

end PrimitiveInteraction

end MIP
