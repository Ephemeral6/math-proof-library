/-
Result R.123 — two-temperature duality `T_kin · T_ent ≥ Φ_per_barrier`.

Reference: `branches/thermodynamics/workspace/new_results.md` R.123 (B).

**Statement.**

With `⟨Φ̇⟩ = −1/Z` (steady descent, `T.8: N = Φ₀·Z`) and intervention
variance `σ² = Var(Φ̇) ≥ 0`:

    ⟨Φ̇²⟩ = ⟨Φ̇⟩² + σ² = 1/Z² + σ² ,
    T_kin = Z·⟨Φ̇²⟩ = 1/Z + Z·σ²                         (★)
    T_ent = N/|B| = Φ₀·Z/|B|                             (★★)

Defining the per-barrier potential `Φ_per_barrier := Φ₀/|B|`, the product

    T_kin · T_ent = (Φ₀/|B|)·(1 + Z²·σ²) = Φ_per_barrier·(1 + Z²·σ²)

so, since `σ² ≥ 0`,

    T_kin · T_ent ≥ Φ_per_barrier                        (♢)

with equality iff `σ² = 0` (deterministic questioner).  The steady-state
degeneration (`σ² = 0`) gives `T_kin · Z = 1`, i.e. `T_kin = 1/Z`, the
impedance lower bound `ΔΦ = 1/Z` (D.3.2).

**This file is `axiom`-free.**  The physics (`Z` impedance, `Φ₀` initial
potential, `|B|` barrier count, `σ²` questioner variance) enters only as
real-valued data; we formalize the product identity and the `σ² ≥ 0`
inequality.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace TwoTemperature

/-- **Kinetic temperature** `T_kin = 1/Z + Z·σ²` (R.123 (★)). -/
noncomputable def Tkin (Z σ2 : ℝ) : ℝ := 1 / Z + Z * σ2

/-- **Entanglement temperature** `T_ent = Φ₀·Z/|B|` (R.123 (★★)). -/
noncomputable def Tent (Φ₀ Z Babs : ℝ) : ℝ := Φ₀ * Z / Babs

/-- **Per-barrier potential** `Φ_per_barrier = Φ₀/|B|` (R.123). -/
noncomputable def PhiPerBarrier (Φ₀ Babs : ℝ) : ℝ := Φ₀ / Babs

/-- **R.123 — `T_kin = 1/Z + Z·σ²` from `⟨Φ̇²⟩ = 1/Z² + σ²`.**

The kinetic temperature `T_kin = Z·⟨Φ̇²⟩` with `⟨Φ̇²⟩ = 1/Z² + σ²` equals
`1/Z + Z·σ²` for `Z ≠ 0`.  Algebraic identity (★). -/
theorem R_123_Tkin_expand (Z σ2 : ℝ) (hZ : Z ≠ 0) :
    Z * (1 / Z ^ 2 + σ2) = Tkin Z σ2 := by
  unfold Tkin
  field_simp

/-- **R.123 — product identity `T_kin·T_ent = Φ_per_barrier·(1+Z²σ²)`.**

The core duality identity (♢, equality part).  Requires `Z ≠ 0`,
`|B| ≠ 0`. -/
theorem R_123_product_identity
    (Φ₀ Z Babs σ2 : ℝ) (hZ : Z ≠ 0) (hB : Babs ≠ 0) :
    Tkin Z σ2 * Tent Φ₀ Z Babs
      = PhiPerBarrier Φ₀ Babs * (1 + Z ^ 2 * σ2) := by
  unfold Tkin Tent PhiPerBarrier
  field_simp

/-- **R.123 (♢) — temperature-potential uncertainty inequality.**

`T_kin · T_ent ≥ Φ_per_barrier`.  From the product identity and
`σ² ≥ 0`, `Z² ≥ 0`, the factor `(1 + Z²·σ²) ≥ 1`, provided
`Φ_per_barrier ≥ 0` (positive per-barrier potential). -/
theorem R_123_uncertainty
    (Φ₀ Z Babs σ2 : ℝ) (hZ : Z ≠ 0) (hB : Babs ≠ 0)
    (hσ : 0 ≤ σ2) (hppb : 0 ≤ PhiPerBarrier Φ₀ Babs) :
    PhiPerBarrier Φ₀ Babs ≤ Tkin Z σ2 * Tent Φ₀ Z Babs := by
  rw [R_123_product_identity Φ₀ Z Babs σ2 hZ hB]
  -- Φ_per_barrier ≤ Φ_per_barrier·(1 + Z²·σ²) since the factor ≥ 1.
  have hfac : 1 ≤ 1 + Z ^ 2 * σ2 := by
    have : 0 ≤ Z ^ 2 * σ2 := mul_nonneg (by positivity) hσ
    linarith
  nlinarith [hppb, hfac]

/-- **R.123 — equality iff deterministic questioner (`σ² = 0`).**

When `σ² = 0`, the product `T_kin·T_ent = Φ_per_barrier` exactly. -/
theorem R_123_equality_at_zero_variance
    (Φ₀ Z Babs : ℝ) (hZ : Z ≠ 0) (hB : Babs ≠ 0) :
    Tkin Z 0 * Tent Φ₀ Z Babs = PhiPerBarrier Φ₀ Babs := by
  rw [R_123_product_identity Φ₀ Z Babs 0 hZ hB]
  ring

/-- **R.123 — steady-state degeneration `T_kin·Z = 1`.**

At `σ² = 0`, `T_kin = 1/Z`, so `T_kin·Z = 1` for `Z ≠ 0` — the impedance
lower bound `ΔΦ = 1/Z` (D.3.2). -/
theorem R_123_steady_state_impedance (Z : ℝ) (hZ : Z ≠ 0) :
    Tkin Z 0 * Z = 1 := by
  unfold Tkin
  field_simp
  ring

end TwoTemperature

end MIP
