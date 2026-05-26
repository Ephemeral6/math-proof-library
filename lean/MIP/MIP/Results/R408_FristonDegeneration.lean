/-
Result R.408 — Friston Free Energy Principle as the MIP single-agent
degeneration.

Reference: `workspace/friston_mip_unification.md` §R.408
(A 条件 (Σ* 度量；仅步骤 3 残留), Stage 5.5 + Task 1.3 + Audit Fix 2,
2026-05-16 theory-unification block 9).

**Statement.** Under the four FEP-regime conditions (F1) X is inert,
(F2) Y is the sole active agent, (F3) continuous time, (F4) Y carries an
internal generative model `(K(Y), p_Y) ≅ p(s̃, ϑ | m)`, the variational
free energy `F` of Friston's framework coincides with the MIP free
energy, under the dictionary

* `Φ₀ = Surprise = −log p(s̃ | m)`           (step 1, definitional rewrite)
* `Z = 1/Π`        with `Π = precision`       (step 3, second-order regime)
* `κ ↔ hierarchical inter-level edge density` (step 4, structural)
* `H_K = H[q]`                                (step 5, definitional)
* `F = Φ₀ + C_train`                          (the main degeneration eqn)

and, via T.8 `N = Φ₀·Z`, the step-2 decomposition

    F  =  N · Π + C_train .

The (F1)-(F4) mapping enters as **explicit hypotheses** (the
homomorphism conditions); given them, each degeneration claim is an
algebraic identity over the real-valued observables.  This file encodes
the algebraic kernel: with `Surprise, Pi, Ctrain : ℝ`, `Pi > 0`,
`Z := 1/Pi`, `Phi0 := Surprise`, `F := Phi0 + Ctrain`, we prove the
degeneration equalities

    F = Surprise + Ctrain,    Z = 1/Pi,    Z * Pi = 1,
    F = N * Pi + Ctrain   (under T.8  N = Phi0 * Z).

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp

namespace MIP

namespace FristonDegeneration

/-- **(F1)-(F4) FEP-regime mapping bundle.**

Bundles the MIP-side observables together with the Friston-side
quantities they degenerate to, plus the (F4)-homomorphism identities
that the source establishes as the degeneration dictionary.  All
non-trivial content of R.408 is the set of equalities listed here being
mutually consistent; the theorems below derive the boxed equations of
§R.408 from this bundle. -/
structure FEPMap where
  /-- Surprise `S(s̃|m) = −log p(s̃|m)` (Friston side). -/
  Surprise : ℝ
  /-- Precision `Π = ∂²S/∂ϑ²` (Friston side); strictly positive. -/
  Pi : ℝ
  /-- The complexity / KL drift term `C_train` (D.3.10 object). -/
  Ctrain : ℝ
  /-- MIP free-energy potential `Φ₀(Y,p)`. -/
  Phi0 : ℝ
  /-- MIP emergence impedance `Z(Y)`. -/
  Z : ℝ
  /-- MIP intervention count `N(p,Y)` (T.8 discrete form). -/
  N : ℝ
  /-- MIP free energy `F` (= variational free energy after degeneration). -/
  F : ℝ
  /-- Precision is strictly positive (FEP standing assumption). -/
  Pi_pos : 0 < Pi
  /-- **Step 1 (F4):** `Φ₀ = Surprise` (definitional rewrite). -/
  step1 : Phi0 = Surprise
  /-- **Step 3 (F3 second-order regime):** `Z = 1/Π`. -/
  step3 : Z = 1 / Pi
  /-- **Main equation:** `F = Φ₀ + C_train` (variational free energy =
      MIP free energy). -/
  mainEq : F = Phi0 + Ctrain
  /-- **T.8 (Ohm's law):** `N = Φ₀ · Z`. -/
  T8 : N = Phi0 * Z

namespace FEPMap

variable (M : FEPMap)

/-- **R.408 main degeneration equation — `F = Surprise + C_train`.**

The variational free energy equals Surprise plus the complexity drift
term, i.e. the MIP free energy `Φ₀ + C_train` with `Φ₀ = Surprise`. -/
theorem R_408_free_energy : M.F = M.Surprise + M.Ctrain := by
  rw [M.mainEq, M.step1]

/-- **R.408 step 3 — impedance is the reciprocal of precision.** -/
theorem R_408_Z_eq_inv_Pi : M.Z = 1 / M.Pi := M.step3

/-- **R.408 step 3 — `Z · Π = 1` (the impedance–precision involution).**

Since `Z = 1/Π` and `Π > 0`, the product is exactly `1`: high emergence
impedance ⟺ low precision, in exact reciprocity. -/
theorem R_408_Z_mul_Pi : M.Z * M.Pi = 1 := by
  rw [M.step3]
  field_simp [ne_of_gt M.Pi_pos]

/-- **R.408 step 1 — `Φ₀ = Surprise` (definitional rewrite).** -/
theorem R_408_Phi0_eq_Surprise : M.Phi0 = M.Surprise := M.step1

/-- **R.408 step 2 — free-energy decomposition `F = N · Π + C_train`.**

Combining T.8 `N = Φ₀·Z`, step 3 `Z = 1/Π` and the main equation, the
free energy reads `F = "intervention count × precision" + "complexity
drift"`.  This is the §R.409 row-2 reading
`F = N·Π + C_train`: `N·Π = Φ₀·Z·Π = Φ₀` (since `Z·Π = 1`). -/
theorem R_408_step2_decomposition : M.F = M.N * M.Pi + M.Ctrain := by
  have hZPi : M.Z * M.Pi = 1 := R_408_Z_mul_Pi M
  have hN : M.N * M.Pi = M.Phi0 := by
    rw [M.T8]
    calc M.Phi0 * M.Z * M.Pi
        = M.Phi0 * (M.Z * M.Pi) := by ring
      _ = M.Phi0 * 1 := by rw [hZPi]
      _ = M.Phi0 := by ring
  rw [M.mainEq, ← hN]

/-- **R.408 step 2 (Surprise form) — `F = N · Π + C_train` with
`N · Π = Surprise`.**

Spelling out that the "Surprise term" of the variational free energy is
exactly `N·Π` after the T.8 degeneration. -/
theorem R_408_NPi_eq_Surprise : M.N * M.Pi = M.Surprise := by
  have hZPi : M.Z * M.Pi = 1 := R_408_Z_mul_Pi M
  rw [M.T8, M.step1]
  calc M.Surprise * M.Z * M.Pi
      = M.Surprise * (M.Z * M.Pi) := by ring
    _ = M.Surprise * 1 := by rw [hZPi]
    _ = M.Surprise := by ring

end FEPMap

/-- **R.408 — purely algebraic impedance–precision reciprocity.**

Stated free of the bundle: for any precision `Pi > 0`, the degeneration
impedance `Z := 1/Pi` satisfies `Z * Pi = 1`.  This is the kernel of
step 3 isolated from the rest of the dictionary. -/
theorem R_408_impedance_precision (Pi : ℝ) (hPi : 0 < Pi) :
    (1 / Pi) * Pi = 1 := by
  field_simp [ne_of_gt hPi]

end FristonDegeneration

end MIP
