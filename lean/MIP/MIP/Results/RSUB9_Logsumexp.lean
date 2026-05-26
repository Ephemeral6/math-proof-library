/-
Result R-SUB.9 — Subdomain logsumexp / softmin free-energy law.

Reference: `workspace/subdomain_competition.md` §6.9 (A 无条件).

**Statement (decomposability part).** Under the subdomain-decomposable
assumption (no cross-subdomain explanations: `ℛ_cross(p) = ∅`), the
partition function decomposes as

    Z(X, p) = Σ_i Z_i(X, p),  with  Z_i := Σ_{R ∈ ℛ_i(p), R ⊆ K(X)} exp(-Φ₀(R)).

Consequently `F := -log Z = softmin_i F_i = -log (Σ_i exp(-F_i))`
where `F_i := -log Z_i`. The β-generalisation is the LogSumExp identity.

**Strategy.** The MIP-specific piece (existence of a feasible-path
partition by subdomain) is opaque. The **pure-math kernel** is the
LogSumExp identity, fully proved.
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

open scoped BigOperators
open Real

namespace LogsumexpKernel

/-- **softmin identity.** For any function `F : Fin m → ℝ`,
`-log (Σ exp(-F i)) = "softmin" F` is exactly the LogSumExp value.

This is just unfolding: `-log (Σ exp(-F i))` is what we call the
softmin; the equation is `rfl`-true at the level of the def below. -/
noncomputable def softmin {ι : Type*} (s : Finset ι) (F : ι → ℝ) : ℝ :=
  -Real.log (∑ i ∈ s, Real.exp (-F i))

/-- Direct algebraic form of the softmin decomposition:

If the global partition function `Z` equals `Σᵢ Zᵢ` and each `Zᵢ = exp(-Fᵢ)`,
then `-log Z = softmin F`. -/
theorem softmin_of_partition
    {ι : Type*} (s : Finset ι) (Z : ℝ) (F : ι → ℝ)
    (hZ : Z = ∑ i ∈ s, Real.exp (-F i)) :
    -Real.log Z = softmin s F := by
  unfold softmin; rw [hZ]

/-- **β-form (LogSumExp).** For any `β ≠ 0`:
`(-1/β) · log (Σ exp(-β · F i))`. The classical LogSumExp formula is the
function on which we read off

* β → ∞: tends to `min F i`,
* β → 0⁺: tends to `-log |s|` (degenerate case excluded).

The two limits are not proved here (they need topology); we give the
β-form as a definition. -/
noncomputable def softminBeta
    {ι : Type*} (s : Finset ι) (β : ℝ) (F : ι → ℝ) : ℝ :=
  -(1/β) * Real.log (∑ i ∈ s, Real.exp (-β * F i))

/-- **β = 1 reduces to the unscaled softmin.** -/
theorem softminBeta_one {ι : Type*} (s : Finset ι) (F : ι → ℝ) :
    softminBeta s 1 F = softmin s F := by
  unfold softminBeta softmin
  simp [one_mul]

/-- **Subadditivity / softmin upper bound:**
`softmin s F ≤ F i` for every `i ∈ s`, provided `s` is nonempty and the
sum of exponentials is positive (always true for finite sums of positive
reals).

This is the analogue of "min ≤ each component". -/
theorem softmin_le {ι : Type*} (s : Finset ι) (F : ι → ℝ)
    (i : ι) (hi : i ∈ s) :
    softmin s F ≤ F i := by
  unfold softmin
  -- Sum ≥ exp(-F i), so log Sum ≥ -F i, so -log Sum ≤ F i.
  have hpos : (0 : ℝ) < ∑ j ∈ s, Real.exp (-F j) := by
    apply Finset.sum_pos (fun j _ => Real.exp_pos _)
    exact ⟨i, hi⟩
  have hsingle : Real.exp (-F i) ≤ ∑ j ∈ s, Real.exp (-F j) := by
    apply Finset.single_le_sum (f := fun j => Real.exp (-F j))
      (fun j _ => (Real.exp_pos _).le) hi
  have hlog : Real.log (Real.exp (-F i)) ≤
      Real.log (∑ j ∈ s, Real.exp (-F j)) :=
    Real.log_le_log (Real.exp_pos _) hsingle
  rw [Real.log_exp] at hlog
  linarith

end LogsumexpKernel

end MIP
