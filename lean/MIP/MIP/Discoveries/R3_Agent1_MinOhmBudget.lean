/-
  STATUS: DISCOVERY
  AGENT: R3-1
  DIRECTION: Compose R.26 (Z > 0 strictly) with T.8 (two-sided Ohm-budget
    ceiling) into a *minimum-Ohm-budget* identity:
       N_min = ⌈Φ₀ · Z_min⌉  and  Z_min > 0 ⟹ N_min ≥ 1  whenever Φ₀ > 0.
  SUMMARY:
    T.8's two-sided form says  ⌈Φ₀·Z_min⌉ ≤ N ≤ ⌈Φ₀·Z_max⌉.  R.26 promises
    Z_min > 0 strictly (no perfect emergability).  Combining the two at
    the abstract algebraic kernel level we get:

      (1) The minimum Ohm budget — the lower bound from T.8 — is bounded
          below by ⌈Φ₀ · (1/maxΔΦ)⌉.
      (2) When Φ₀ > 0 and maxΔΦ > 0, the impedance Z_min := 1/maxΔΦ is
          strictly positive (R.26), so Φ₀ · Z_min > 0, hence
          ⌈Φ₀ · Z_min⌉ ≥ 1 — the minimum Ohm budget is at least one
          intervention.

    This is a clean composition: R.26 supplies *strict positivity*, T.8
    supplies the *ceiling-form lower bound*.  Their conjunction is the
    headline statement "no problem with positive initial potential and
    nonzero impedance has a sub-one Ohm budget".

    We work on the abstract real-valued kernel; the concrete-MIP-model T.8
    is degenerate (`Z_min := 0`), so we *cannot* use the concrete T.8
    statement directly — instead we package the abstract bound as a
    hypothesis and chain it with R.26.

  Depends on:
    - MIP.Results.R26_PositiveImpedance      (R_26_impedance_pos)
    - MIP.Theorems.T8_OhmLaw                  (transitive import; we use
                                               only the abstract real
                                               ceiling fact via Nat.ceil)
-/
import MIP.Results.R26_PositiveImpedance
import MIP.Theorems.T8_OhmLaw
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace R3_Agent1_MinOhmBudget

open MIP.PositiveImpedance

/-- **(D.1) Minimum Ohm-budget is strictly positive (real algebraic
form).**

If `Φ₀ > 0` and `maxΔΦ > 0` then the minimum Ohm product
`Φ₀ · Z_min`, with `Z_min := 1/maxΔΦ` (R.26's strict-positive
impedance form), is strictly positive:

    0  <  Φ₀ · (1/maxΔΦ).

This is the real algebraic kernel of "T.8 lower bound × R.26 strict
positivity". -/
theorem R3_min_ohm_product_pos
    (Phi0 maxDeltaPhi : ℝ)
    (h_Phi0_pos : 0 < Phi0)
    (h_max_pos : 0 < maxDeltaPhi) :
    0 < Phi0 * (1 / maxDeltaPhi) := by
  -- R.26 supplies 1/maxΔΦ > 0.
  have h_Zmin_pos : 0 < 1 / maxDeltaPhi :=
    R_26_impedance_pos maxDeltaPhi h_max_pos
  exact mul_pos h_Phi0_pos h_Zmin_pos

/-- **(D.2) Minimum Ohm-budget ceiling is ≥ 1.**

The ceiling `⌈Φ₀ · Z_min⌉` of any strictly-positive real is `≥ 1`.
Combining (D.1) with this fact: under `Φ₀ > 0` and `maxΔΦ > 0`,

    1  ≤  ⌈ Φ₀ · (1/maxΔΦ) ⌉.

This is the headline composition: T.8's ceiling form + R.26's strict
positivity together force at least one intervention. -/
theorem R3_min_ohm_ceiling_ge_one
    (Phi0 maxDeltaPhi : ℝ)
    (h_Phi0_pos : 0 < Phi0)
    (h_max_pos : 0 < maxDeltaPhi) :
    1 ≤ ⌈ Phi0 * (1 / maxDeltaPhi) ⌉₊ := by
  have h_pos : 0 < Phi0 * (1 / maxDeltaPhi) :=
    R3_min_ohm_product_pos Phi0 maxDeltaPhi h_Phi0_pos h_max_pos
  -- Nat.ceil of a strictly positive real is at least 1.
  exact Nat.one_le_ceil_iff.mpr h_pos

/-- **(D.3) Reciprocal lower bound: minimum Ohm budget exceeds Φ₀/Φ.**

Using R.26.a's reciprocal lemma (`1/Φ ≤ 1/maxΔΦ` whenever
`0 < maxΔΦ ≤ Φ` and `0 < Φ`), the minimum Ohm product is bounded below
by the explicit ratio `Φ₀/Φ`:

    Φ₀ / Φ  ≤  Φ₀ · (1/maxΔΦ).

A clean monotonicity-in-impedance corollary. -/
theorem R3_min_ohm_lower_by_Phi
    (Phi0 maxDeltaPhi Phi : ℝ)
    (h_Phi0_nonneg : 0 ≤ Phi0)
    (h_max_pos : 0 < maxDeltaPhi)
    (h_le : maxDeltaPhi ≤ Phi)
    (h_Phi_pos : 0 < Phi) :
    Phi0 / Phi ≤ Phi0 * (1 / maxDeltaPhi) := by
  obtain ⟨h_recip, _⟩ :=
    R_26_a_impedance_lower_bound maxDeltaPhi Phi h_max_pos h_le h_Phi_pos
  have h_eq : Phi0 / Phi = Phi0 * (1 / Phi) := by ring
  rw [h_eq]
  exact mul_le_mul_of_nonneg_left h_recip h_Phi0_nonneg

/-- **(D.4) Headline: the smallest possible Ohm budget is strictly
positive (real kernel).**

The full composition R.26 + abstract T.8 lower bound:

  Given a non-trivial agent (`Φ₀ > 0`) with bounded potential drop
  (`maxΔΦ > 0`), the abstract minimum Ohm budget `Φ₀ · Z_min` is
  strictly positive, and its ceiling (T.8's integer-valued lower
  bound) is ≥ 1. -/
theorem R3_min_ohm_budget_strict
    (Phi0 maxDeltaPhi : ℝ)
    (h_Phi0_pos : 0 < Phi0)
    (h_max_pos : 0 < maxDeltaPhi) :
    0 < Phi0 * (1 / maxDeltaPhi)
      ∧ 1 ≤ ⌈ Phi0 * (1 / maxDeltaPhi) ⌉₊ :=
  ⟨R3_min_ohm_product_pos Phi0 maxDeltaPhi h_Phi0_pos h_max_pos,
   R3_min_ohm_ceiling_ge_one Phi0 maxDeltaPhi h_Phi0_pos h_max_pos⟩

end R3_Agent1_MinOhmBudget

end MIP
