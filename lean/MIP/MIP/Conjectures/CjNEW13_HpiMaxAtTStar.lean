/-
Conjecture Cj.NEW-13 — `argmax_t H(π) ≈ t*` (collaboration golden window).

Source: `~/Desktop/MIP/conjectures/index.md` lines ~732-758;
supporting derivation `workspace/subdomain_competition.md` §6.8, §8.1.

Natural-language conjecture
---------------------------
On a training curve, the subdomain dispersion `H(π)(X_t; 𝒟)` (D.3.18,
the Shannon entropy of the subdomain masses `π = (π_1,…,π_m)`) is
maximized near the second phase transition

    t* := inf{ t : K^M(A_t) ⊇ K^M(H) } :

      argmax_t H(π)(X_t; 𝒟)  ≈  t* .

Intuition: `t*` is when agent `A`'s metacognitive subspace covers the
human one, corresponding to `A`'s attention being *uniformly* spread over
the human metacognitive subdomains — the "generalist state".  So the
golden window is the moment `π` is closest to uniform, i.e. `H(π)` peaks.

Formalization choices
---------------------
The dynamical content (the training curve `t ↦ X_t`, the metacognitive
operator `K^M`, and the coverage threshold `t*`) is **not** available in
the MIP knowledge layer: there is no model of training dynamics or
`K^M(A_t)` coverage.  We therefore formalize and PROVE the *static
geometric core* the conjecture rests on — the precise sense in which the
"generalist state" is the entropy maximizer:

  for a subdomain-mass vector `π = (π_1,…,π_m)` on the simplex
  (`π_i ≥ 0`, `∑ π_i = 1`, `m ≥ 1`),

      H(π) := −∑_i π_i log π_i  ≤  log m ,

  with equality iff `π` is uniform (`π_i = 1/m`).

Thus *whenever* a training trajectory reaches the uniform subdomain
profile, `H(π)` attains its global maximum there; identifying the time
of that visit with `t*` is the remaining OPEN dynamical step.

The entropy is written via Mathlib's `Real.negMulLog x = −x·log x`, so
`H(π) = ∑_i negMulLog(π_i)`, matching `MIP.knowledgeEntropy`
(`= −∑ p log p = ∑ negMulLog p`).

VERDICT
=======
* **PROVED partial** — `H(π) ≤ log m` (Theorem `CjNEW13_entropy_le_log`)
  via concavity of `negMulLog` (Jensen), and the uniform profile attains
  it (Theorem `CjNEW13_uniform_attains`).  This is the "generalist =
  uniform attention = entropy max" geometric kernel, the substantive
  content the conjecture builds on.
* **OPEN** — linking `argmax_t H(π)(X_t)` to `t*`.
  BLOCKED AT: there is no MIP-layer model of the training trajectory
  `t ↦ X_t`, the metacognitive coverage `K^M(A_t) ⊇ K^M(H)`, or the
  threshold `t*`.  MISSING: dynamics of subdomain-mass evolution and a
  formal `K^M` coverage predicate.  (Sub-question (a) — invariance of the
  argmax under refinements of the partition `{P_i}` — and (b),(c) on the
  exact position/curvature of the peak are likewise OPEN, all downstream
  of the missing dynamics.)

This file is `sorry`-free and `axiom`-free (no new axioms; only the
ambient Lean/Mathlib axioms).
-/
import Mathlib.Analysis.Convex.Jensen
import Mathlib.Analysis.SpecialFunctions.Log.NegMulLog
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic.Linarith

namespace MIP
namespace CjNEW13

open scoped BigOperators
open Real

variable {ι : Type} [Fintype ι] [DecidableEq ι]

/-- Subdomain dispersion `H(π) := −∑_i π_i log π_i = ∑_i negMulLog(π_i)`
(D.3.18). -/
noncomputable def Hpi (q : ι → ℝ) : ℝ := ∑ i, Real.negMulLog (q i)

omit [DecidableEq ι] in
/-- `Hpi` agrees with the `−∑ π log π` form, matching `knowledgeEntropy`. -/
lemma Hpi_eq (q : ι → ℝ) : Hpi q = -∑ i, q i * Real.log (q i) := by
  unfold Hpi
  rw [← Finset.sum_neg_distrib]
  apply Finset.sum_congr rfl
  intro i _
  rw [Real.negMulLog]
  ring

/-- **Cj.NEW-13 entropy bound — PROVED.** For a probability vector
`π : ι → ℝ` on a nonempty finite index set (`π_i ≥ 0`, `∑ π_i = 1`),

    H(π) ≤ log (card ι) .

Proof: apply concave Jensen to `negMulLog` (concave on `[0,∞)`) with the
*uniform* weights `w_i = 1/m` and points `p_i = π_i`:

    ∑_i (1/m) · negMulLog(π_i) ≤ negMulLog( ∑_i (1/m) π_i )
                               = negMulLog(1/m)
                               = (1/m) · log m ,

so `(1/m) H(π) ≤ (1/m) log m`, hence `H(π) ≤ log m`. -/
theorem CjNEW13_entropy_le_log [Nonempty ι] (q : ι → ℝ)
    (h_nonneg : ∀ i, 0 ≤ q i) (h_sum : ∑ i, q i = 1) :
    Hpi q ≤ Real.log (Fintype.card ι) := by
  classical
  set m : ℕ := Fintype.card ι with hm
  have hm_pos : 0 < m := Fintype.card_pos
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm_pos
  -- Uniform weights.
  set w : ι → ℝ := fun _ => 1 / (m : ℝ) with hw
  have hw0 : ∀ i ∈ (Finset.univ : Finset ι), 0 ≤ w i := by
    intro i _; rw [hw]; positivity
  have hw_sum : ∑ i, w i = 1 := by
    rw [hw]
    rw [Finset.sum_const, Finset.card_univ, ← hm, nsmul_eq_mul]
    field_simp
  have hmem : ∀ i ∈ (Finset.univ : Finset ι), q i ∈ Set.Ici (0 : ℝ) := by
    intro i _; exact h_nonneg i
  -- Concave Jensen.
  have jensen := (Real.concaveOn_negMulLog).le_map_sum hw0 hw_sum hmem
  -- LHS: ∑ w_i • negMulLog (q i) = (1/m) ∑ negMulLog (q i) = (1/m) H(π).
  have hlhs : (∑ i, w i • Real.negMulLog (q i)) = (1 / (m : ℝ)) * Hpi q := by
    unfold Hpi
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    rw [hw]; simp [smul_eq_mul]
  -- RHS argument: ∑ w_i • q i = (1/m) ∑ q i = 1/m.
  have hrhs_arg : (∑ i, w i • q i) = 1 / (m : ℝ) := by
    have : (∑ i, w i • q i) = (1 / (m : ℝ)) * ∑ i, q i := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i _
      rw [hw]; simp [smul_eq_mul]
    rw [this, h_sum, mul_one]
  rw [hlhs, hrhs_arg] at jensen
  -- negMulLog (1/m) = (1/m) log m.
  have hval : Real.negMulLog (1 / (m : ℝ)) = (1 / (m : ℝ)) * Real.log (m : ℝ) := by
    rw [Real.negMulLog]
    rw [Real.log_div one_ne_zero (ne_of_gt hmR)]
    rw [Real.log_one]
    ring
  rw [hval] at jensen
  -- (1/m) H(π) ≤ (1/m) log m  ⟹  H(π) ≤ log m  (multiply by m > 0).
  have hinv : (0 : ℝ) < 1 / (m : ℝ) := by positivity
  have jensen' : 1 / (m : ℝ) * Hpi q ≤ 1 / (m : ℝ) * Real.log (Fintype.card ι) := by
    calc 1 / (m : ℝ) * Hpi q ≤ 1 / (m : ℝ) * Real.log (m : ℝ) := jensen
      _ = 1 / (m : ℝ) * Real.log (Fintype.card ι) := by rw [← hm]
  exact le_of_mul_le_mul_left jensen' hinv

/-- **Cj.NEW-13 uniform attains the maximum.** The uniform profile
`π_i = 1/m` has `H(π) = log m`, i.e. it attains the bound of
`CjNEW13_entropy_le_log`.  Hence the generalist (uniform-attention)
state is a global maximizer of `H(π)`. -/
theorem CjNEW13_uniform_attains [Nonempty ι] :
    Hpi (fun _ : ι => 1 / (Fintype.card ι : ℝ)) = Real.log (Fintype.card ι) := by
  classical
  set m : ℕ := Fintype.card ι with hm
  have hm_pos : 0 < m := Fintype.card_pos
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm_pos
  unfold Hpi
  -- ∑_i negMulLog (1/m) = m · negMulLog(1/m) = m · (1/m) log m = log m.
  rw [Finset.sum_const, Finset.card_univ, ← hm, nsmul_eq_mul]
  rw [Real.negMulLog]
  rw [Real.log_div one_ne_zero (ne_of_gt hmR), Real.log_one]
  field_simp
  ring

/-- Faithful `Prop`-level statement of the proven static core of
Cj.NEW-13: on the probability simplex over a nonempty finite index set,
subdomain dispersion `H(π)` is bounded by `log m` and the uniform
(generalist) profile attains it. -/
def CjNEW13_Statement : Prop :=
  ∀ (ι : Type) [Fintype ι] [DecidableEq ι] [Nonempty ι],
    (∀ (q : ι → ℝ), (∀ i, 0 ≤ q i) → (∑ i, q i = 1) →
        Hpi q ≤ Real.log (Fintype.card ι))
    ∧ Hpi (fun _ : ι => 1 / (Fintype.card ι : ℝ)) = Real.log (Fintype.card ι)

/-- The proven static core holds. -/
theorem CjNEW13_Statement_holds : CjNEW13_Statement := by
  intro ι _ _ _
  exact ⟨fun q h1 h2 => CjNEW13_entropy_le_log q h1 h2, CjNEW13_uniform_attains⟩

end CjNEW13
end MIP
