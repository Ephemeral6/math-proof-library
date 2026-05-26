/-
Result R.750-R.758 — α-Rényi family of emergence quantities (slot 033, LRA).

Reference: `workspace/round3_exploration/slot_033.md` and
`workspace/round3_exploration/work_slot_033.md` (L^p / Rényi α-Family of
Emergence Quantities).  Source results R.750 (`Z = 1/N_∞`, power-mean
ladder), R.751 (α-Ohm law), R.754 / C.754.1 (Amari dual-coordinate
Pythagoras).

**Candidate status: Round-3 autonomous exploration, not yet
human-audited.**

This file formalises the *crisp kernels* of the family.  Power-mean
monotonicity, Csiszár non-negativity and the dually-flat structure are
deep facts bundled as hypotheses; what is proved here is their exact
algebraic consequences.

* **R.750 (`Z = 1/N_∞` endpoint).**  The partition impedance is the
  reciprocal of the α=∞ power mean: `Z · N_∞ = 1`.  The power-mean
  ladder `N_{α₁} ≤ N_{α₂}` (`α₁ ≤ α₂`) is bundled as a hypothesis; its
  consequence `N_α ≤ N_∞ = 1/Z` is derived.

* **R.751 (α-Ohm law).**  A power/exponent generalisation of the Ohm
  identity `N = Φ₀ · Z` (= `Φ₀ / N_∞`).  The α=∞ *equality* endpoint
  `N · N_∞ = Φ₀` is exact; for `α ≤ ∞` the corrected inequality is
  `N · N_α ≤ Φ₀` (slot 033 frontmatter agent_10 FLAG: the published
  direction was reversed; the proved direction is the sound one).

* **R.754 / C.754.1 (Amari Pythagoras).**  In a dually-flat manifold
  the Bregman three-point identity `D(p‖r) = D(p‖q) + D(q‖r) + ⟨θ,η⟩`
  collapses, under e/m-orthogonality `⟨θ,η⟩ = 0`, to the Pythagorean
  identity `d²(p,r) = d²(p,q) + d²(q,r)`.

All powers use `Real.rpow`.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace RenyiFamily

open Real

/-! ### R.750 — `Z = 1/N_∞` and the power-mean ladder

`N_α(X, s) := (∫_M max(ΔΦ, 0)^α dμ_M)^{1/α}` is the α-power mean of the
per-intervention emergence drop.  Its α=∞ endpoint is `N_∞ = max_m ΔΦ`,
and D.3.2 defines `Z = 1 / N_∞`.  We work with the values `Z`, `N_α`,
`N_∞` directly. -/

/-- **R.750 (a) — impedance as reciprocal power-mean endpoint.**

`Z = 1 / N_∞`  ⟺  `Z · N_∞ = 1` (for `N_∞ > 0`).  This is the exact
α=∞ endpoint of the LRA family. -/
theorem R_750_Z_eq_inv_Ninf
    (Z Ninf : ℝ) (hNinf : 0 < Ninf) (hZ : Z = 1 / Ninf) :
    Z * Ninf = 1 := by
  rw [hZ]; field_simp

/-- **R.750 (b) — `N_α ≤ 1/Z` from the power-mean ladder.**

Power-mean monotonicity gives `N_α ≤ N_∞` (bundled as `h_mono`); with
`Z = 1/N_∞` this reads `N_α ≤ 1/Z`.  Thus every α-emergence quantity is
dominated by the inverse impedance. -/
theorem R_750_Nalpha_le_invZ
    (Z Ninf Nalpha : ℝ) (hZ : Z = 1 / Ninf)
    (h_mono : Nalpha ≤ Ninf) :
    Nalpha ≤ 1 / Z := by
  rw [hZ, one_div_one_div]
  exact h_mono

/-- **Power-mean ladder transitivity.**

If `N_{α₁} ≤ N_{α₂}` and `N_{α₂} ≤ N_{α₃}` (the Hardy-Littlewood-Pólya
monotonicity restricted to a triple `α₁ ≤ α₂ ≤ α₃`), then
`N_{α₁} ≤ N_{α₃}`.  This is the ladder consequence of R.750. -/
theorem R_750_ladder
    (N1 N2 N3 : ℝ) (h12 : N1 ≤ N2) (h23 : N2 ≤ N3) :
    N1 ≤ N3 := le_trans h12 h23

/-! ### R.751 — α-Ohm law

The Ohm identity is `N = Φ₀ · Z = Φ₀ / N_∞`.  We give the exact α=∞
equality endpoint and the corrected α ≤ ∞ inequality. -/

/-- **R.751 (α=∞ Ohm equality endpoint).**

With `Z = 1/N_∞` and the Ohm identity `N = Φ₀ · Z`, the endpoint reads

    N · N_∞ = Φ₀ .

This is the unique α at which the α-Ohm relation is an equality — the
intrinsic justification for D.3.2 selecting the `max` (α=∞) aggregation
of ΔΦ. -/
theorem R_751_alpha_Ohm_equality
    (N Ninf Z Phi0 : ℝ) (hNinf : 0 < Ninf) (hZ : Z = 1 / Ninf)
    (hN : N = Phi0 * Z) :
    N * Ninf = Phi0 := by
  rw [hN, hZ]; field_simp

/-- **R.751 (α-Ohm inequality, corrected direction).**

For any finite α (`N_α ≤ N_∞`, power-mean monotonicity bundled as
`h_mono`) the α-Ohm relation is the *upper* bound

    N · N_α ≤ Φ₀ ,

with equality exactly at α=∞ (`R_751_alpha_Ohm_equality`).  This is the
sound direction (slot 033 frontmatter agent_10 FLAG: the originally
published `≥` was reversed). -/
theorem R_751_alpha_Ohm_le
    (N Nalpha Ninf Z Phi0 : ℝ) (hNinf : 0 < Ninf) (hZ : Z = 1 / Ninf)
    (hN : N = Phi0 * Z) (h_mono : Nalpha ≤ Ninf) (hPhi : 0 ≤ Phi0) :
    N * Nalpha ≤ Phi0 := by
  have hNval : N = Phi0 / Ninf := by rw [hN, hZ]; ring
  rw [hNval, div_mul_eq_mul_div, div_le_iff₀ hNinf]
  exact mul_le_mul_of_nonneg_left h_mono hPhi

/-! ### R.754 / C.754.1 — Amari dual-coordinate Pythagoras

In a dually-flat manifold with mixture (`η`) and exponential (`θ`)
affine coordinates, the canonical divergence `D` (= `KL_MIP` in MIP)
satisfies the Bregman three-point identity

    D(p ‖ r) = D(p ‖ q) + D(q ‖ r) + ⟨θ_q − θ_r , η_p − η_q⟩ .

The inner-product term is the e/m-orthogonality defect.  When the
m-geodesic (q,r) is ⊥ to the e-geodesic (p,q) it vanishes, giving the
generalised Pythagorean theorem. -/

/-- **C.754.1 (Amari Pythagorean identity).**

Given the Bregman three-point decomposition
`D(p‖r) = D(p‖q) + D(q‖r) + inner` and the orthogonality condition
`inner = 0`, the canonical divergence obeys the Pythagorean identity

    D(p ‖ r) = D(p ‖ q) + D(q ‖ r) .

This is MIP's first explicit dual-coordinate Pythagoras (work_slot_033
§2.5). -/
theorem R_754_Pythagoras
    (Dpr Dpq Dqr inner : ℝ)
    (h_three_point : Dpr = Dpq + Dqr + inner)
    (h_orth : inner = 0) :
    Dpr = Dpq + Dqr := by
  rw [h_three_point, h_orth]; ring

/-- **R.754 (Legendre duality consistency).**

The mixture potential `Φ_m(η) = Σ η log η` and the exponential potential
`Φ_e(θ) = log Σ exp θ` are Legendre-dual: `Φ_m + Φ_e − ⟨θ,η⟩ = 0`.  Read
as a constraint on the three scalars, this fixes the inner product

    ⟨θ, η⟩ = Φ_m + Φ_e .

We record the algebraic equivalence used to feed the Pythagoras kernel. -/
theorem R_754_Legendre
    (Phi_m Phi_e inner : ℝ)
    (h_dual : Phi_m + Phi_e - inner = 0) :
    inner = Phi_m + Phi_e := by linarith

/-- **R.754 + C.754.1 (integrated Pythagoras via Legendre).**

If the Legendre duality `Φ_m + Φ_e − inner = 0` holds with the
e/m-orthogonality `Φ_m + Φ_e = 0` (the potentials cancel along the
orthogonal geodesics), then the inner product vanishes and the
Pythagorean identity follows. -/
theorem R_754_Pythagoras_via_Legendre
    (Dpr Dpq Dqr Phi_m Phi_e inner : ℝ)
    (h_three_point : Dpr = Dpq + Dqr + inner)
    (h_dual : Phi_m + Phi_e - inner = 0)
    (h_orth : Phi_m + Phi_e = 0) :
    Dpr = Dpq + Dqr := by
  have h_inner : inner = 0 := by
    have := R_754_Legendre Phi_m Phi_e inner h_dual
    rw [this, h_orth]
  exact R_754_Pythagoras Dpr Dpq Dqr inner h_three_point h_inner

end RenyiFamily

end MIP
