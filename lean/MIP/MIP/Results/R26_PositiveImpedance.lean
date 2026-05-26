/-
Result R.26 — Emergence impedance is always strictly positive (`Z > 0`).

Reference: `proofs/derived/A_grade.md` R.26 (A 无条件, deps D.3.2, D.4.10).

**Statement.** For any non-trivial problem `p` (`Φ₀(A, p) > 0`): `Z(A) > 0`,
i.e. `Z = 0` is impossible ("no perfect emergability").

**NL core.** Emergence impedance is defined (D.3.2) as the reciprocal of the
maximal per-step potential drop:

    Z := (max_{m} ΔΦ(m, s))⁻¹ .

By D.4.10, `ΔΦ(m, s) = Φ(s) − E[Φ(s')]`, and by potential non-negativity
(D.3.1, `Φ = −log Pr ≥ 0`) we get `E[Φ(s')] ≥ 0`, hence

    ΔΦ(m, s) ≤ Φ(s)   ⟹   max_m ΔΦ(m, s) ≤ Φ(s) .

For a non-trivial problem `0 < max ΔΦ < ∞`, so `Z = 1 / max ΔΦ > 0`, and in
fact `Z ≥ 1/Φ(s) > 0` whenever `max ΔΦ ≤ Φ(s)` with `Φ(s) > 0`.

**Pure-math kernel.** `0 < x ⟹ 0 < 1/x`; and `0 < x ≤ Φ ⟹ 1/Φ ≤ 1/x`,
which combined with `0 < Φ ⟹ 0 < 1/Φ` gives the `Z ≥ 1/Φ > 0` chain.

**This file is `axiom`-free.**  It encodes the algebraic content of R.26 on a
real-valued input `maxDeltaPhi`, with the upstream bound `max ΔΦ ≤ Φ`
(D.4.10 + D.3.1) entering as an explicit hypothesis.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace PositiveImpedance

/-- **R.26 — positivity of emergence impedance.**

Given a strictly positive maximal per-step potential drop `maxDeltaPhi`, the
impedance `Z := 1 / maxDeltaPhi` is strictly positive.  In particular `Z = 0`
is impossible. -/
theorem R_26_impedance_pos
    (maxDeltaPhi : ℝ) (h_pos : 0 < maxDeltaPhi) :
    0 < 1 / maxDeltaPhi := by
  positivity

/-- **R.26 — impedance is never zero.**

A direct restatement: `Z ≠ 0`. -/
theorem R_26_impedance_ne_zero
    (maxDeltaPhi : ℝ) (h_pos : 0 < maxDeltaPhi) :
    (1 / maxDeltaPhi) ≠ 0 :=
  ne_of_gt (R_26_impedance_pos maxDeltaPhi h_pos)

/-- **R.26.a — explicit lower bound `Z ≥ 1/Φ > 0`.**

Reproduces the NL bound chain: from `0 < max ΔΦ ≤ Φ` (D.4.10 potential drop
bounded by the finite initial potential `Φ`, D.3.1 non-negativity) and `0 < Φ`,
the impedance `Z := 1 / max ΔΦ` satisfies `Z ≥ 1/Φ`, and `1/Φ > 0`. -/
theorem R_26_a_impedance_lower_bound
    (maxDeltaPhi Phi : ℝ)
    (h_pos : 0 < maxDeltaPhi)
    (h_le : maxDeltaPhi ≤ Phi)
    (h_Phi_pos : 0 < Phi) :
    1 / Phi ≤ 1 / maxDeltaPhi ∧ 0 < 1 / Phi := by
  refine ⟨?_, by positivity⟩
  -- Reciprocal reverses order on positives: 0 < a ≤ b ⟹ 1/b ≤ 1/a.
  exact one_div_le_one_div_of_le h_pos h_le

/-- **R.26.a (corollary) — strict positivity via the `1/Φ` bound.**

Combining the two parts of `R_26_a_impedance_lower_bound` gives directly
`0 < 1 / maxDeltaPhi`, exhibiting `1/Φ` as an explicit positive lower bound. -/
theorem R_26_a_impedance_pos_of_bound
    (maxDeltaPhi Phi : ℝ)
    (h_pos : 0 < maxDeltaPhi)
    (h_le : maxDeltaPhi ≤ Phi)
    (h_Phi_pos : 0 < Phi) :
    0 < 1 / maxDeltaPhi := by
  obtain ⟨h_bound, h_Phi_recip_pos⟩ :=
    R_26_a_impedance_lower_bound maxDeltaPhi Phi h_pos h_le h_Phi_pos
  linarith

end PositiveImpedance

end MIP
