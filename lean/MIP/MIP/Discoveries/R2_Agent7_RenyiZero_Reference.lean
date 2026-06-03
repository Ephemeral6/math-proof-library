/-
  STATUS: DISCOVERY
  AGENT: R2-7
  DIRECTION: α = 0 Renyi divergence (Hartley) with uniform reference.
  SUMMARY:
    The α = 0 Renyi divergence (a.k.a. Hartley divergence) of `d`
    against `q` is
        D_0(d ‖ q) := -log (∑_{ω ∈ supp d} q.p ω) = -log q(supp d).

    Specialised to uniform `q.p ω = 1/|Ω|` on a finite universe:
        D_0(d ‖ uniform) = -log (|supp d| / |Ω|) = log |Ω| - log |supp d|.

    Two named results:

      • `Renyi_zero_to_uniform_nonneg`
          `D_0(d ‖ uniform) ≥ 0`        (since `|supp d| ≤ |Ω|`).
      • `Renyi_zero_to_uniform_le_log_card`
          `D_0(d ‖ uniform) ≤ log |Ω|`  (since `|supp d| ≥ 1` for any
                                          normalised d).
      • `Renyi_zero_to_uniform_max_iff_point_mass`
          `D_0 = log |Ω| ⟺ |supp d| = 1`  (point-mass distribution).
      • `Renyi_zero_to_uniform_zero_iff_full_supp`
          `D_0 = 0 ⟺ |supp d| = |Ω|`     (every mass strictly positive).

    Reuses Agent 6's support `Finset` and the support-nonemptiness lemma.
-/
import MIP.Defs.Knowledge
import MIP.Discoveries.Agent6_HK_Nonneg
import MIP.Discoveries.Agent6_HK_LogCard
import MIP.Discoveries.Agent6_HK_Support

namespace MIP

namespace R2_Agent7_RenyiZero_Reference

open scoped BigOperators
open MIP.Agent6 (supp supp_nonempty)

variable {Ω : Type} [Fintype Ω] [DecidableEq Ω]

/-- **α = 0 Renyi (Hartley) divergence with uniform reference (closed
form).**

`D_0(d ‖ uniform) := log |Ω| - log |supp d|`. -/
noncomputable def Renyi_zero_to_uniform (d : ActivationDist Ω) : ℝ :=
  Real.log (Fintype.card Ω : ℝ) - Real.log ((supp d).card : ℝ)

/-- **`|supp d|.card ≤ Fintype.card Ω`** (the support is a subset of
`univ`). -/
private lemma supp_card_le_card (d : ActivationDist Ω) :
    (supp d).card ≤ Fintype.card Ω := by
  unfold supp
  rw [← Finset.card_univ]
  exact Finset.card_filter_le _ _

/-- **`|supp d| ≥ 1`** (the support of a normalised distribution is
nonempty). -/
private lemma supp_card_pos (d : ActivationDist Ω) :
    0 < (supp d).card := Finset.card_pos.mpr (supp_nonempty d)

/-! ### Renyi-0 bracket. -/

/-- **D_0(d ‖ uniform) ≥ 0.**

`|supp d| ≤ |Ω|` ⟹ `log |supp d| ≤ log |Ω|` ⟹ difference ≥ 0. -/
theorem Renyi_zero_to_uniform_nonneg (d : ActivationDist Ω) :
    0 ≤ Renyi_zero_to_uniform d := by
  unfold Renyi_zero_to_uniform
  have h_card_pos : (0 : ℝ) < ((supp d).card : ℝ) := by
    exact_mod_cast supp_card_pos d
  have h_le_card : ((supp d).card : ℝ) ≤ (Fintype.card Ω : ℝ) := by
    exact_mod_cast supp_card_le_card d
  have h_log_le : Real.log ((supp d).card : ℝ)
                    ≤ Real.log (Fintype.card Ω : ℝ) :=
    Real.log_le_log h_card_pos h_le_card
  linarith

/-- **D_0(d ‖ uniform) ≤ log |Ω|.**

`|supp d| ≥ 1` ⟹ `log |supp d| ≥ log 1 = 0`, so the difference
`log |Ω| - log |supp d| ≤ log |Ω|`. -/
theorem Renyi_zero_to_uniform_le_log_card (d : ActivationDist Ω) :
    Renyi_zero_to_uniform d ≤ Real.log (Fintype.card Ω : ℝ) := by
  unfold Renyi_zero_to_uniform
  have h_card_pos : (0 : ℝ) < ((supp d).card : ℝ) := by
    exact_mod_cast supp_card_pos d
  have h_ge_one : (1 : ℝ) ≤ ((supp d).card : ℝ) := by
    exact_mod_cast supp_card_pos d
  have h_log_nonneg : 0 ≤ Real.log ((supp d).card : ℝ) :=
    Real.log_nonneg h_ge_one
  linarith

/-- **Bracket: `0 ≤ D_0(d ‖ uniform) ≤ log |Ω|`.** -/
theorem Renyi_zero_to_uniform_bracket (d : ActivationDist Ω) :
    0 ≤ Renyi_zero_to_uniform d
      ∧ Renyi_zero_to_uniform d ≤ Real.log (Fintype.card Ω : ℝ) :=
  ⟨Renyi_zero_to_uniform_nonneg d, Renyi_zero_to_uniform_le_log_card d⟩

/-! ### Equality cases. -/

/-- **`D_0 = log |Ω| ⟺ |supp d| = 1`** (point-mass distribution). -/
theorem Renyi_zero_to_uniform_max_iff_point_mass (d : ActivationDist Ω) :
    Renyi_zero_to_uniform d = Real.log (Fintype.card Ω : ℝ)
      ↔ (supp d).card = 1 := by
  unfold Renyi_zero_to_uniform
  constructor
  · intro h
    -- log |Ω| - log |supp d| = log |Ω| ⟹ log |supp d| = 0 ⟹ |supp d| = 1.
    have h_log_zero : Real.log ((supp d).card : ℝ) = 0 := by linarith
    have h_card_pos : (0 : ℝ) < ((supp d).card : ℝ) := by
      exact_mod_cast supp_card_pos d
    -- log x = 0 with x > 0 ⟹ x = 1.
    have h_eq_one : ((supp d).card : ℝ) = 1 := by
      rcases Real.log_eq_zero.mp h_log_zero with h | h | h
      · linarith
      · exact h
      · linarith
    exact_mod_cast h_eq_one
  · intro h_eq
    rw [h_eq]
    simp [Real.log_one]

/-- **`D_0 = 0 ⟺ |supp d| = |Ω|`** (full support, every mass strictly
positive). -/
theorem Renyi_zero_to_uniform_zero_iff_full_supp (d : ActivationDist Ω) :
    Renyi_zero_to_uniform d = 0
      ↔ (supp d).card = Fintype.card Ω := by
  unfold Renyi_zero_to_uniform
  have h_card_pos : (0 : ℝ) < ((supp d).card : ℝ) := by
    exact_mod_cast supp_card_pos d
  -- Ω is nonempty (since supp d ⊆ Ω is nonempty), so |Ω| > 0.
  have h_card_Ω_pos : (0 : ℝ) < (Fintype.card Ω : ℝ) := by
    have h_le : (supp d).card ≤ Fintype.card Ω := supp_card_le_card d
    have h_pos := supp_card_pos d
    have : 0 < Fintype.card Ω := lt_of_lt_of_le h_pos h_le
    exact_mod_cast this
  constructor
  · intro h
    have h_log_eq : Real.log ((supp d).card : ℝ) = Real.log (Fintype.card Ω : ℝ) := by
      linarith
    have h_inj := Real.log_injOn_pos
      (Set.mem_Ioi.mpr h_card_pos) (Set.mem_Ioi.mpr h_card_Ω_pos) h_log_eq
    exact_mod_cast h_inj
  · intro h_eq
    rw [h_eq]; ring

end R2_Agent7_RenyiZero_Reference

end MIP
