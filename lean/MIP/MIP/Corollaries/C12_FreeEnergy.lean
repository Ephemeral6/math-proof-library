/-
Corollary C.12 — MIP Free Energy Inequality.

Reference: `workspace/partition_function_theorem.md` §4.6 (A 无条件).

**Statement.** For all `X` and `p ∈ P_sol` with `η_cov(p, X) > 0`:

    Φ₀(X, p)  ≥  E_R[Φ₀(X, p; R)]  -  S_R(X, p),

where for the path-Boltzmann distribution `p_R := exp(-Φ₀(R))/Z`,
`E_R[Φ₀] := Σ_R p_R · Φ₀(R)` and `S_R := -Σ_R p_R · log p_R`.

**Proof.**
1. Z-entropy expansion (lemma): `-log Z = E_R[Φ₀] - S_R` (standard
   stat-mech identity).
2. Partition function lower bound (T.35): `Φ₀ ≥ -log Z`.
3. Combine.

**Strategy.** The Z-entropy expansion is a *pure-math identity*, fully
proved here. The application to MIP's `Phi0` requires T.35 (sorried).
-/
import MIP.Theorems.T35_PartitionFunction
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

namespace MIP

open scoped BigOperators
open Real

namespace FreeEnergy

/-- **Z-entropy expansion lemma (pure math).**

For any finite indexing set with weights `b_R := exp(-φ_R)` and `Z := Σ b_R`
with `Z > 0`, set `p_R := b_R / Z` (Boltzmann distribution). Then

    -log Z = (Σ p_R · φ_R) - (-Σ p_R · log p_R)
           = E_p[φ] - S(p).

The proof: `log p_R = log b_R - log Z = -φ_R - log Z`. Multiply by `p_R`
and sum: `Σ p_R · log p_R = -Σ p_R · φ_R - log Z · Σ p_R = -E[φ] - log Z`.
Hence `-S(p) = Σ p_R log p_R = -E[φ] - log Z`, so
`log Z = E[φ] - S(p)`, equivalently `-log Z = -E[φ] + S(p)`.

NOTE on sign: the standard MIP statement uses `Φ ≥ E[Φ_R] - S` which
combined with `Φ ≥ -log Z` (T.35 lower) requires `-log Z = E[Φ] - S`.
The argument above gives `-log Z = ... S - E[Φ]` (opposite sign), so
checking: writing `log p_R = -φ_R - log Z`:

* `Σ p_R log p_R = -Σ p_R φ_R - log Z`
* `S = -Σ p_R log p_R = Σ p_R φ_R + log Z = E[φ] + log Z`
* `log Z = S - E[φ]`
* `-log Z = E[φ] - S`. ✓ -/
theorem Z_entropy_expansion {ι : Type*} (s : Finset ι) (φ : ι → ℝ)
    (hZ_pos : 0 < ∑ R ∈ s, Real.exp (-φ R)) :
    let Z := ∑ R ∈ s, Real.exp (-φ R);
    let p := fun R => Real.exp (-φ R) / Z;
    -Real.log Z
      = (∑ R ∈ s, p R * φ R) - (-∑ R ∈ s, p R * Real.log (p R)) := by
  set Z := ∑ R ∈ s, Real.exp (-φ R) with hZ
  set p := fun R => Real.exp (-φ R) / Z with hp
  have hZne : Z ≠ 0 := ne_of_gt hZ_pos
  -- Step 1: log p_R = -φ R - log Z.
  have hlog_p : ∀ R ∈ s, Real.log (p R) = -φ R - Real.log Z := by
    intro R _
    have hbpos : 0 < Real.exp (-φ R) := Real.exp_pos _
    rw [hp]
    rw [Real.log_div (ne_of_gt hbpos) hZne]
    rw [Real.log_exp]
  -- Step 2: Σ p_R log p_R = -Σ p_R φ_R - log Z · Σ p_R.
  -- Step 2a: Σ p_R = 1.
  have hsum_p : ∑ R ∈ s, p R = 1 := by
    have hstep : ∑ R ∈ s, p R = (∑ R ∈ s, Real.exp (-φ R)) / Z := by
      rw [hp]
      rw [eq_div_iff hZne, Finset.sum_mul]
      apply Finset.sum_congr rfl
      intro R _
      rw [div_mul_cancel₀ _ hZne]
    rw [hstep, div_self hZne]
  -- Step 2b: Σ p_R log p_R via hlog_p.
  have hkey : ∑ R ∈ s, p R * Real.log (p R)
      = -∑ R ∈ s, p R * φ R - Real.log Z := by
    have : ∑ R ∈ s, p R * Real.log (p R)
        = ∑ R ∈ s, p R * (-φ R - Real.log Z) := by
      apply Finset.sum_congr rfl
      intro R hR
      rw [hlog_p R hR]
    rw [this]
    have hdist : ∀ R ∈ s, p R * (-φ R - Real.log Z)
        = -(p R * φ R) - p R * Real.log Z := by
      intros; ring
    rw [Finset.sum_congr rfl hdist]
    rw [Finset.sum_sub_distrib]
    rw [Finset.sum_neg_distrib]
    rw [← Finset.sum_mul]
    rw [hsum_p, one_mul]
  -- Step 3: -log Z = E[φ] - S. From hkey, -hkey gives:
  --   -Σ p_R log p_R = Σ p_R φ_R + log Z
  -- i.e. S = E[φ] + log Z, so log Z = S - E[φ], -log Z = E[φ] - S.
  linarith [hkey]

end FreeEnergy

end MIP
