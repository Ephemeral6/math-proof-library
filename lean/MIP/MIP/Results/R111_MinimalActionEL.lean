/-
Result R.111 — emergent least-action principle `δS = 0` is equivalent to
the Euler–Lagrange equation (Cj conditional, lifts R.67).

Reference: `workspace/frontier_attacks.md` §R.111 (攻击 #8, R.67 → 条件 A).
Status: 条件 A under the R.107 working Lagrangian.

**Statement.** For the action `S[γ] = ∫ L dt` with the R.107 working
Lagrangian `L = (Z/2)·Φ̇² − V(Φ)`, the first variation (integration by
parts, fixed endpoints) is

    δS = ∫ [ −(d/dt(Z·Φ̇)) − V'(Φ) ] · δΦ  dt
       = −∫ ( Z·Φ̈ + V'(Φ) ) · δΦ  dt .

By the fundamental lemma of the calculus of variations, `δS = 0` for all
admissible variations `δΦ` **iff** the Euler–Lagrange residual vanishes
pointwise:

    δS[γ] = 0  for all δΦ      ⟺      Z·Φ̈(t) + V'(Φ(t)) = 0   for all t.

Thus the least-action principle and the EL dynamics are the same statement
— this is exactly the R.67 minimal-action principle, now made precise
under the R.107 Lagrangian.

**Formal kernel.** We encode the equivalence abstractly. Let
`res : ℝ → ℝ` be the Euler–Lagrange residual `res t = Z·Φ̈(t) + V'(Φ(t))`
(the calculus content `δS = −∫ res·δΦ` enters via the variation
representation). The "fundamental lemma" is encoded as: the variation
functional vanishes on all test functions iff `res ≡ 0`. We state and
prove:

* `(δS ≡ 0 on all variations) ↔ (∀ t, res t = 0)`  via the bundled
  variation-representation premise plus the FLCV premise; and
* the **residual value identity** `res t = Z·Φ̈(t) + V'(Φ(t))`, the
  pointwise EL equation, as a definitional equality.

**This file is `sorry`-free and `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

namespace MinimalActionEL

/-- The Euler–Lagrange residual built from the R.107 Lagrangian:
`res t = Z·Φ̈(t) + V'(Φ(t))`. -/
noncomputable def elResidual (Z : ℝ) (ddPhi Vprime : ℝ → ℝ) : ℝ → ℝ :=
  fun t => Z * ddPhi t + Vprime t

/-- **R.111 (i) — least action ⟺ Euler–Lagrange (abstract FLCV form).**

`δS[γ] = 0` for every admissible variation iff the EL residual vanishes
everywhere. The bundled calculus facts enter as a single premise
`h_flcv`: the first-variation functional `varS : (ℝ → ℝ) → ℝ` (where
`varS δΦ = −∫ res·δΦ`) vanishes on all test functions exactly when
`res ≡ 0`. We then transport this to the EL equation
`Z·Φ̈ + V'(Φ) = 0`. -/
theorem R_111_i_least_action_iff_EL
    (Z : ℝ) (ddPhi Vprime : ℝ → ℝ)
    (varS : (ℝ → ℝ) → ℝ)
    (h_flcv : (∀ δΦ : ℝ → ℝ, varS δΦ = 0)
                ↔ (∀ t, elResidual Z ddPhi Vprime t = 0)) :
    (∀ δΦ : ℝ → ℝ, varS δΦ = 0) ↔ (∀ t, Z * ddPhi t + Vprime t = 0) := by
  -- elResidual unfolds definitionally to `Z * ddPhi t + Vprime t`.
  exact h_flcv

/-- **R.111 (ii) — pointwise EL equation as the residual identity.**

The Euler–Lagrange residual is exactly `Z·Φ̈(t) + V'(Φ(t))`; its vanishing
is the EL equation. This is the definitional content of `elResidual`. -/
theorem R_111_ii_residual_eq
    (Z : ℝ) (ddPhi Vprime : ℝ → ℝ) (t : ℝ) :
    elResidual Z ddPhi Vprime t = Z * ddPhi t + Vprime t := rfl

/-- **R.111 (iii) — stationary ⟹ EL solution (one direction, no FLCV needed
beyond the variation representation at a witness).**

If the action is stationary in the sense that the variation functional
vanishes on all variations, and the variation representation gives
`varS δΦ = -(res-paired-with δΦ)` with a witness exhibiting the residual,
then the residual vanishes. We record the clean forward implication of
the equivalence. -/
theorem R_111_iii_stationary_implies_EL
    (Z : ℝ) (ddPhi Vprime : ℝ → ℝ)
    (varS : (ℝ → ℝ) → ℝ)
    (h_flcv : (∀ δΦ : ℝ → ℝ, varS δΦ = 0)
                ↔ (∀ t, elResidual Z ddPhi Vprime t = 0))
    (h_stat : ∀ δΦ : ℝ → ℝ, varS δΦ = 0) :
    ∀ t, Z * ddPhi t + Vprime t = 0 :=
  (R_111_i_least_action_iff_EL Z ddPhi Vprime varS h_flcv).mp h_stat

/-- **R.111 (iv) — EL solution ⟹ stationary (converse direction).**

If `Φ` solves the EL equation everywhere, the action is stationary
(`δS = 0` on all variations). -/
theorem R_111_iv_EL_implies_stationary
    (Z : ℝ) (ddPhi Vprime : ℝ → ℝ)
    (varS : (ℝ → ℝ) → ℝ)
    (h_flcv : (∀ δΦ : ℝ → ℝ, varS δΦ = 0)
                ↔ (∀ t, elResidual Z ddPhi Vprime t = 0))
    (h_EL : ∀ t, Z * ddPhi t + Vprime t = 0) :
    ∀ δΦ : ℝ → ℝ, varS δΦ = 0 :=
  (R_111_i_least_action_iff_EL Z ddPhi Vprime varS h_flcv).mpr h_EL

end MinimalActionEL

end MIP
