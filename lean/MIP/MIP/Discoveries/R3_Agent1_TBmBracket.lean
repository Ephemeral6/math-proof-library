/-
  STATUS: DISCOVERY
  AGENT: R3-1
  DIRECTION: Compose R.25 (N = T·|B|) with R.26 (impedance positivity) into
    a real-valued T·|B| vs Φ₀·Z bracket.
  SUMMARY:
    R.25 gives the identity N = T·|B|.  R.26 says the impedance is strictly
    positive (1/maxΔΦ > 0).  We compose these into bracket statements that
    do not appear in either file alone:

      (1)  Given N = T·|B| (R.25) and a real Ohm-budget bound N ≤ Φ₀·Z + 1
           (the real-valued analogue of T.8's ceiling form ⌈Φ₀·Z⌉),
           we get  T·|B| ≤ Φ₀·Z + 1.
      (2)  Given N = T·|B| (R.25) and a real lower bound N ≥ Φ₀·Z_min,
           plus impedance positivity Z_min = 1/maxΔΦ > 0 (R.26), we get
           a *strictly positive* lower bound on T·|B|, namely
              T·|B| ≥ Φ₀ · (1/maxΔΦ) > 0   whenever Φ₀ > 0.
      (3)  The two-sided bracket
              Φ₀ · (1/maxΔΦ)  ≤  T·|B|  ≤  Φ₀·Z + 1,
           a "T·|B|–Φ₀·Z bracket" produced by composing R.25 + R.26.

    This is a clean real-valued algebraic composition.  The T.8 concrete
    model uses Z = 0, so we don't chain through that degenerate side;
    instead we use the abstract Ohm-budget form that any extension of the
    model will satisfy.

  Depends on:
    - MIP.Results.R25_SecondDifficultyDim (R_25_identity)
    - MIP.Results.R26_PositiveImpedance    (R_26_impedance_pos,
                                            R_26_a_impedance_lower_bound)
-/
import MIP.Results.R25_SecondDifficultyDim
import MIP.Results.R26_PositiveImpedance
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace R3_Agent1_TBmBracket

open MIP.SecondDifficultyDim MIP.PositiveImpedance

/-- **(A.1) Upper bracket from R.25 + a real Ohm-budget bound.**

If `N = T·|B|` (R.25's identity, valid for `|B| ≠ 0`) and `N` obeys the
real-valued Ohm-budget bound `N ≤ Φ₀·Z + 1` (the ENNReal-stripped
real-form of T.8's `N ≤ ⌈Φ₀·Z⌉`), then the difficulty product `T·|B|`
inherits the bound:

    T · |B|  ≤  Φ₀ · Z  +  1. -/
theorem R3_T_B_upper_bracket
    (N B T Phi0 Z : ℝ) (hB : B ≠ 0) (hT : T = N / B)
    (h_budget : N ≤ Phi0 * Z + 1) :
    T * B ≤ Phi0 * Z + 1 := by
  -- R.25 closes N = T · B.
  have h_identity : N = T * B := R_25_identity N B T hB hT
  -- Substitute and use the budget hypothesis.
  linarith [h_identity]

/-- **(A.2) Lower bracket from R.25 + R.26 (strict positivity).**

If `N = T·|B|` and `N ≥ Φ₀ · (1/maxΔΦ)` (the abstract real Ohm-lower
bound through impedance `Z = 1/maxΔΦ`), then for a non-trivial problem
(`Φ₀ > 0`) the product `T·|B|` is **strictly positive**.

The strict positivity is the R.26 contribution: even at the lowest
allowed impedance `Z_min = 1/maxΔΦ`, the bound is `> 0` because both
`Φ₀ > 0` and `1/maxΔΦ > 0`. -/
theorem R3_T_B_lower_strict
    (N B T Phi0 maxDeltaPhi : ℝ)
    (hB : B ≠ 0) (hT : T = N / B)
    (h_lower : Phi0 * (1 / maxDeltaPhi) ≤ N)
    (h_maxPos : 0 < maxDeltaPhi)
    (h_PhiPos : 0 < Phi0) :
    0 < T * B := by
  -- R.25 closes N = T · B.
  have h_identity : N = T * B := R_25_identity N B T hB hT
  -- R.26 gives 1/maxDeltaPhi > 0 strictly.
  have h_Zpos : 0 < 1 / maxDeltaPhi := R_26_impedance_pos maxDeltaPhi h_maxPos
  -- Φ₀ · (1/maxΔΦ) > 0 by product of positives.
  have h_RHS_pos : 0 < Phi0 * (1 / maxDeltaPhi) := mul_pos h_PhiPos h_Zpos
  -- Chain through h_lower and h_identity.
  linarith

/-- **(A.3) Two-sided T·|B|–Φ₀·Z bracket.**

The composition of (A.1) and (A.2): given the identity `N = T·|B|`,
the lower bound `Φ₀·(1/maxΔΦ) ≤ N`, and the upper bound `N ≤ Φ₀·Z + 1`,
together with positivity (Φ₀ > 0, maxΔΦ > 0) from R.26, the difficulty
product `T·|B|` is two-sided bracketed:

    Φ₀ · (1/maxΔΦ)  ≤  T · |B|  ≤  Φ₀ · Z  +  1,

and the lower side is **strictly positive**. -/
theorem R3_T_B_bracket
    (N B T Phi0 Z maxDeltaPhi : ℝ)
    (hB : B ≠ 0) (hT : T = N / B)
    (h_lower : Phi0 * (1 / maxDeltaPhi) ≤ N)
    (h_upper : N ≤ Phi0 * Z + 1)
    (h_maxPos : 0 < maxDeltaPhi)
    (h_PhiPos : 0 < Phi0) :
    Phi0 * (1 / maxDeltaPhi) ≤ T * B
      ∧ T * B ≤ Phi0 * Z + 1
      ∧ 0 < Phi0 * (1 / maxDeltaPhi) := by
  refine ⟨?_, ?_, ?_⟩
  · -- Lower side via R.25 identity.
    have h_id : N = T * B := R_25_identity N B T hB hT
    linarith
  · exact R3_T_B_upper_bracket N B T Phi0 Z hB hT h_upper
  · have h_Zpos : 0 < 1 / maxDeltaPhi :=
      R_26_impedance_pos maxDeltaPhi h_maxPos
    exact mul_pos h_PhiPos h_Zpos

/-- **(A.4) Corollary — explicit `1/Φ`-form of the lower bracket.**

When `maxΔΦ ≤ Φ` (R.26.a's potential-non-negativity hypothesis), the
lower bracket can be replaced by the explicit weaker bound `Φ₀/Φ`:

    T · |B|  ≥  Φ₀ / Φ.

This uses R.26.a's reciprocal bound `1/Φ ≤ 1/maxΔΦ`. -/
theorem R3_T_B_lower_via_Phi
    (N B T Phi0 maxDeltaPhi Phi : ℝ)
    (hB : B ≠ 0) (hT : T = N / B)
    (h_lower : Phi0 * (1 / maxDeltaPhi) ≤ N)
    (h_maxPos : 0 < maxDeltaPhi)
    (h_le : maxDeltaPhi ≤ Phi)
    (h_PhiPos : 0 < Phi)
    (h_Phi0Nonneg : 0 ≤ Phi0) :
    Phi0 / Phi ≤ T * B := by
  -- R.26.a: 1/Phi ≤ 1/maxΔΦ.
  obtain ⟨h_recip, _⟩ :=
    R_26_a_impedance_lower_bound maxDeltaPhi Phi h_maxPos h_le h_PhiPos
  -- R.25: N = T · B.
  have h_id : N = T * B := R_25_identity N B T hB hT
  -- Chain: Phi0/Phi = Phi0·(1/Phi) ≤ Phi0·(1/maxΔΦ) ≤ N = T·B.
  have h_mul : Phi0 * (1 / Phi) ≤ Phi0 * (1 / maxDeltaPhi) := by
    exact mul_le_mul_of_nonneg_left h_recip h_Phi0Nonneg
  have h_div : Phi0 / Phi = Phi0 * (1 / Phi) := by ring
  rw [h_div]
  linarith

end R3_Agent1_TBmBracket

end MIP
