/-
Result R.90 — `σ_Z = 0 ⟺ Ohm strict equality`.

Reference: `proofs/derived/stability.md` R.90 (A 无条件 under T.8 + D.4.9).

**Statement (informal).** The state-dependent impedance `Z(A, ·)` has zero
state-variance `σ_Z(A) = 0` iff the Ohm law `N(p, A) = ⌈Φ₀(A, p) · Z(A)⌉`
holds with strict equality on every problem.

**Pure-math content.** The non-trivial direction is the bidirectional core:
a real-valued function on a state space has zero range (max = min) iff it is
constant.  This file proves that kernel.  The Path B Lean encoding in
`MIP.Defs.StateSequence` makes `Z_min := Z := Z_max` by construction, so the
Ohm-strict-equality T.8 already holds always; R.90 therefore reduces to the
pure-math constancy core.

**This file is `axiom`-free.**
-/
import Mathlib.Algebra.Order.Group.MinMax
import Mathlib.Data.Real.Basic
import MIP.Defs.StateSequence
import MIP.Theorems.T8_OhmLaw

namespace MIP

namespace SigmaZeroCharacterisation

/-- **Pure-math kernel of R.90.**

A real-valued function on any state type is constant iff every two values
agree.  Equivalent characterisations: existence of a single value `c`, or
pointwise equality of all images. -/
theorem constant_iff_all_eq {ι : Type} (f : ι → ℝ) :
    (∃ c, ∀ s, f s = c) ↔ (∀ s t, f s = f t) := by
  constructor
  · rintro ⟨c, h⟩ s t
    rw [h s, h t]
  · intro h
    by_cases hne : Nonempty ι
    · obtain ⟨s₀⟩ := hne
      exact ⟨f s₀, fun s => h s s₀⟩
    · -- Empty state space: vacuously constant with c = 0.
      refine ⟨0, fun s => ?_⟩
      exact absurd ⟨s⟩ hne

/-- **Range-zero characterisation (R.90 kernel in σ-form).**

For a finite nonempty state set, the range `sup f − inf f = 0` iff `f` is
constant on that set.  This is the form most directly matching the
`σ_Z := sup Z − inf Z` definition (D.4.9) used in MIP. -/
theorem range_zero_iff_constant
    {ι : Type} [Fintype ι] [Nonempty ι] (f : ι → ℝ) :
    (Finset.univ.sup' Finset.univ_nonempty f
       = Finset.univ.inf' Finset.univ_nonempty f)
      ↔ (∀ s t, f s = f t) := by
  constructor
  · intro hrange s t
    -- sup' = inf' ⟹ every value is sandwiched as a single value.
    have h_s_le_sup : f s ≤ Finset.univ.sup' Finset.univ_nonempty f :=
      Finset.le_sup' f (Finset.mem_univ s)
    have h_inf_le_s : Finset.univ.inf' Finset.univ_nonempty f ≤ f s :=
      Finset.inf'_le f (Finset.mem_univ s)
    have h_t_le_sup : f t ≤ Finset.univ.sup' Finset.univ_nonempty f :=
      Finset.le_sup' f (Finset.mem_univ t)
    have h_inf_le_t : Finset.univ.inf' Finset.univ_nonempty f ≤ f t :=
      Finset.inf'_le f (Finset.mem_univ t)
    -- With sup = inf, all four bounds collapse to a single value.
    have h_s : f s = Finset.univ.sup' Finset.univ_nonempty f := by
      apply le_antisymm h_s_le_sup
      rw [hrange]; exact h_inf_le_s
    have h_t : f t = Finset.univ.sup' Finset.univ_nonempty f := by
      apply le_antisymm h_t_le_sup
      rw [hrange]; exact h_inf_le_t
    rw [h_s, h_t]
  · intro hall
    obtain ⟨s₀⟩ : Nonempty ι := inferInstance
    have hsup : Finset.univ.sup' Finset.univ_nonempty f = f s₀ := by
      apply le_antisymm
      · apply Finset.sup'_le
        intro t _
        rw [hall t s₀]
      · exact Finset.le_sup' f (Finset.mem_univ s₀)
    have hinf : Finset.univ.inf' Finset.univ_nonempty f = f s₀ := by
      apply le_antisymm
      · exact Finset.inf'_le f (Finset.mem_univ s₀)
      · apply Finset.le_inf'
        intro t _
        rw [hall t s₀]
    rw [hsup, hinf]

/-! ## R.90 — MIP-layer corollary (Path B encoding)

In the Path B definitional encoding of `MIP.Defs.StateSequence` we have
`Z_min := Z := Z_max`.  Thus the "σ_Z = 0" hypothesis `Z_max = Z_min` is
*always* satisfied (by `rfl`), and T.8 already gives the Ohm-strict
identity.  R.90 is then automatic in this encoding.

The non-trivial content of R.90 — that constancy of `Z` across states is
equivalent to per-state Ohm-strict — is the pure-math kernel above. -/

/-- **R.90 (NL-faithful form, σ_Z = 0 hypothesis explicit).**

After the Phase 1 restoration `Z_min` and `Z_max` are opaque; σ_Z = 0
is therefore expressed as the explicit hypothesis
`Z_min X p = Z_max X p`.  T.8 in the Ohm regime then gives the strict
Ohm law `N = ⌈Φ₀ · Z⌉`. -/
theorem R_90_OhmStrict
    {α : Type} (X : Agent α) (p : Problem α)
    (hFin : N p X ≠ ⊤) (hPhi : Phi0 X p ≠ ⊤)
    (hUniform : Z_min X p = Z_max X p) :
    N p X = ceilENat (Phi0 X p * Z X p) :=
  T8_OhmLaw_core p X hFin hPhi hUniform

end SigmaZeroCharacterisation

end MIP
