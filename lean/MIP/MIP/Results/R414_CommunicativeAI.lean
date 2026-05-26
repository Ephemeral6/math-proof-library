/-
Result R.414 — Communicative active inference as the degeneration of MIP
bidirectional emergence.

Reference: `workspace/multiagent_fep_mip.md` §R.414 (A 无条件 after
(F4-multi-resp) upgrade, 2026-05-16 multi-agent FEP-MIP block).

**Statement (three formalizable kernels).**

* **(step 1) Communicative AI = `argmin Z_q`.** Friston's altruistic action
  `m* = argmax ΔΦ*(m, s_{Y_j})` minimizes the D.3.9 dual-emergence
  impedance `Z_q(Y_j | Y_i)`. (Encoded in companion result R.412; here we
  use it as the role identification.)

* **(step 3) Communication efficiency = Jaccard similarity.** The
  efficiency `1 / Z_q(Y_j | Y_i)` is the Jaccard similarity of the two
  metacognitive-knowledge sets:
        `J(S, T) := |S ∩ T| / |S ∪ T| ∈ [0, 1]`.
  We prove the range `0 ≤ J(S,T) ≤ 1`, plus the symmetry `J(S,T)=J(T,S)`
  and the diagonal value `J(S,S)=1` for nonempty `S`.

* **(step 4) Teaching cost ≥ Asym/2 (uncompressible).** From the R.132
  conservation law `N + N* = 2·N_bi + Asym`, the unidirectional teaching
  cost `N*` (the costlier direction, `N ≤ N*`) satisfies the *strict*
  lower bound
        `N* ≥ N_bi + Asym/2`,
  i.e. there is an uncompressible `Asym/2` of "cognitive-gap tax" that no
  optimal teaching strategy can remove.

This is the A-grade core. The Jaccard part is proved fully for `Finset`s;
the teaching-cost part is the algebraic consequence of R.132 plus the
direction ordering.

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Finset.Card
import Mathlib.Data.Finset.Lattice.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace CommunicativeAI

/-! ## Part (a): Jaccard similarity of metacognitive-knowledge finsets -/

variable {α : Type*} [DecidableEq α]

/-- **Jaccard similarity** of two finite knowledge sets:
`J(S, T) := |S ∩ T| / |S ∪ T|`. By the Lean `0/0 = 0` convention this is
`0` when both sets are empty. This is the MIP communication-efficiency
functional (R.414 step 3). -/
noncomputable def jaccard (S T : Finset α) : ℝ :=
  (S ∩ T).card / (S ∪ T).card

/-- **R.414 (step 3) — Jaccard is nonnegative.** `J(S,T) ≥ 0`. -/
theorem R_414_jaccard_nonneg (S T : Finset α) : 0 ≤ jaccard S T := by
  unfold jaccard
  positivity

/-- **R.414 (step 3) — Jaccard is at most 1.** `J(S,T) ≤ 1`, since
`|S ∩ T| ≤ |S ∪ T|` (the intersection is contained in the union). -/
theorem R_414_jaccard_le_one (S T : Finset α) : jaccard S T ≤ 1 := by
  unfold jaccard
  rcases Nat.eq_zero_or_pos (S ∪ T).card with hzero | hpos
  · -- empty union: |S ∩ T| ≤ |S ∪ T| = 0 forces numerator 0, so J = 0/0 = 0 ≤ 1.
    have hsub : (S ∩ T).card ≤ (S ∪ T).card :=
      Finset.card_le_card Finset.inter_subset_union
    rw [hzero] at hsub ⊢
    simp [Nat.le_zero.mp hsub]
  · -- positive union: |S ∩ T| ≤ |S ∪ T| ⟹ ratio ≤ 1.
    have hsub : (S ∩ T).card ≤ (S ∪ T).card :=
      Finset.card_le_card Finset.inter_subset_union
    have hposR : (0 : ℝ) < ((S ∪ T).card : ℝ) := by exact_mod_cast hpos
    rw [div_le_one hposR]
    exact_mod_cast hsub

/-- **R.414 (step 3) — Jaccard range.** `J(S,T) ∈ [0, 1]`. -/
theorem R_414_jaccard_mem_unit (S T : Finset α) :
    0 ≤ jaccard S T ∧ jaccard S T ≤ 1 :=
  ⟨R_414_jaccard_nonneg S T, R_414_jaccard_le_one S T⟩

/-- **R.414 (step 3) — Jaccard is symmetric.** `J(S,T) = J(T,S)`:
communication efficiency does not depend on the labelling of the two
agents (it is a similarity, not a directed quantity, at the set level). -/
theorem R_414_jaccard_comm (S T : Finset α) : jaccard S T = jaccard T S := by
  unfold jaccard
  rw [Finset.inter_comm, Finset.union_comm]

/-- **R.414 (step 3) — perfect overlap gives `J = 1`.** For nonempty `S`,
`J(S, S) = 1`: an agent has perfect communication efficiency with itself
(the R.131 symmetric-saturation limit `M_{Y_1} = M_{Y_2}`). -/
theorem R_414_jaccard_self (S : Finset α) (hS : S.Nonempty) :
    jaccard S S = 1 := by
  unfold jaccard
  rw [Finset.inter_self, Finset.union_self]
  have hpos : (0 : ℝ) < (S.card : ℝ) := by
    exact_mod_cast Finset.card_pos.mpr hS
  exact div_self (ne_of_gt hpos)

/-! ## Part (b): Uncompressible teaching cost `≥ Asym/2` (from R.132) -/

/-- **R.414 (step 4) — uncompressible teaching cost.**

From the R.132 conservation law `N + N* = 2·N_bi + Asym`, with `N*` the
unidirectional teaching direction taken to be the costlier one
(`N ≤ N*`, the cognitive-asymmetry premise), the teaching cost obeys
        `N* ≥ N_bi + Asym/2`.

**Proof.** `2·N* ≥ N + N* = 2·N_bi + Asym`, so `N* ≥ N_bi + Asym/2`. The
`Asym/2` term is the uncompressible cognitive-gap tax. -/
theorem R_414_teaching_cost_lower_bound
    (N N_star N_bi Asym : ℝ)
    (h_R132 : N + N_star = 2 * N_bi + Asym)
    (h_dir : N ≤ N_star) :
    N_star ≥ N_bi + Asym / 2 := by
  -- 2·N* ≥ N + N* = 2 N_bi + Asym.
  linarith

/-- **R.414 (step 4) corollary — the gap tax is exactly `Asym/2` at the
symmetric (Type-S) limit.**

When teaching is symmetric (`N = N*`, R.131 symmetric saturation), the
conservation law forces `N* = N_bi + Asym/2` *with equality*: the
uncompressible tax `Asym/2` is then the entire excess over `N_bi`. -/
theorem R_414_teaching_cost_symmetric_eq
    (N N_star N_bi Asym : ℝ)
    (h_R132 : N + N_star = 2 * N_bi + Asym)
    (h_symm : N = N_star) :
    N_star = N_bi + Asym / 2 := by
  linarith

/-- **R.414 (step 4) — nonnegativity of the tax.** When the asymmetry is
nonnegative (`Asym ≥ 0`, the D.4.15 sign convention), the uncompressible
overhead `Asym/2 ≥ 0`: teaching never costs *less* than the bidirectional
optimum `N_bi`. -/
theorem R_414_tax_nonneg
    (N N_star N_bi Asym : ℝ)
    (h_R132 : N + N_star = 2 * N_bi + Asym)
    (h_dir : N ≤ N_star) (h_Asym : 0 ≤ Asym) :
    N_bi ≤ N_star := by
  have h := R_414_teaching_cost_lower_bound N N_star N_bi Asym h_R132 h_dir
  linarith

end CommunicativeAI

end MIP
