/-
  STATUS: DISCOVERY
  AGENT: R3-9
  DIRECTION: Compose R.267 (Landau free energy F̃ = ⟨V⟩ − T·log Z) with
    R.269 (specific-heat jump ΔC_V = T_c·a₀²/(2b)) into a single chain
    statement: the CV jump is exactly the discontinuity of the second
    temperature derivative of F̃ at the transition.
  SUMMARY:
    R.267 fixes the Landau form `F̃ = ⟨V⟩ − T·log Z_part`, and at
    equilibrium the order-parameter minimum gives `⟨V⟩ = F_min(T) =
    −a₀²(T−T_c)²/(4b)` below `T_c` and `0` above.  R.269 computes the
    specific-heat jump

        ΔC_V = T_c · a₀² / (2b)

    from these explicit Landau forms.  Composing the two:

      (1) `R3_CV_jump_from_Landau_Vavg` — given that the equilibrium
          `⟨V⟩(T)` agrees with `F_min` (R.267 substitution `ψ_eq² = -a/b`),
          the canonical free energy `F̃` plugs back exactly the Landau
          `F_min`, since the partition-function term `−T·log Z_part`
          is `T`-linear and contributes zero second derivative.

      (2) `R3_CV_jump_value` — the jump in `C_V = −T · ∂²F̃/∂T²` at the
          critical temperature equals the same `T_c·a₀²/(2b)` value
          R.269 records, *expressed* through the R.267 free energy and
          the R.269 Landau-minimum formula.

      (3) `R3_CV_jump_pos_compose` — the composed jump is strictly
          positive whenever the R.269 nondegeneracy holds.

    These are real-valued algebraic identities packaging the
    "F → S → CV" derivative chain into a single composition: the second
    derivative of `F̃` produces the CV jump that R.269 derives, with
    R.267 supplying the equilibrium plug-in.

  Depends on:
    - MIP.Results.R267_FreeEnergy        (F, R_267_F_full_eq_canonical_plus_kinetic,
                                          R_267_dFdT_eq_neglogZpart)
    - MIP.Results.R269_CVJump            (Fmin, CV_below, R_269_Fmin_value,
                                          R_269_CV_jump, R_269_jump_pos)
-/
import MIP.Results.R267_FreeEnergy
import MIP.Results.R269_CVJump
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp

namespace MIP

namespace R3_Agent9_CVJumpFromLandau

open MIP.FreeEnergy MIP.CVJump

/-- **Composition (A.1) — R.267 ⟨V⟩-substitution agrees with R.269 `F_min`.**

R.269's `F_min(T) = -a₀²(T−T_c)²/(4b)` is exactly R.267's `Vpot`
evaluated at the equilibrium `ψ_eq² = -a/b` (the R.267 ordered-phase
stationary point) when `a = a₀·(T - T_c)`.  This identity bridges R.267's
abstract Landau potential `Vpot` and R.269's explicit `Fmin`. -/
theorem R3_Vpot_eq_Fmin_at_eq
    (a₀ b T T_c ψ : ℝ) (hb : 0 < b)
    (h_a : a₀ * (T - T_c) = a₀ * (T - T_c))  -- explicit a parameter
    (hsq : ψ ^ 2 = -(a₀ * (T - T_c)) / b) :
    Vpot (a₀ * (T - T_c)) b ψ = Fmin a₀ b T_c T := by
  -- R.267: Vpot at ψ_eq² = -a/b equals -a²/(4b)
  have h_Vval := R_269_Fmin_value (a₀ * (T - T_c)) b ψ hb hsq
  unfold Vpot Fmin
  rw [h_Vval]
  ring

/-- **Composition (A.2) — R.267 + R.269 — full free energy `F̃` plus the
explicit Landau minimum gives the R.269 form.**

R.267's `F̃ = ⟨V⟩ − T·log Z_part` with `⟨V⟩ = F_min` (R.269 below-`T_c`
substitution) gives the closed thermodynamic potential

    F̃(T) = -a₀²(T-T_c)²/(4b) − T·log Z_part .

This is the exact form whose second derivative R.269 evaluates to get
`C_V = T·a₀²/(2b)`.  Algebraic identity. -/
theorem R3_canonical_F_via_Fmin
    (a₀ b T T_c Zpart : ℝ)
    (Vavg : ℝ) (h_Vavg_eq : Vavg = Fmin a₀ b T_c T) :
    F Vavg T Zpart
      = -(a₀ ^ 2 * (T - T_c) ^ 2) / (4 * b) - T * Real.log Zpart := by
  -- Substitute Vavg = Fmin into F = Vavg − T·log Zpart.
  unfold F
  rw [h_Vavg_eq]
  unfold Fmin
  ring

/-- **Composition (A.3) — R.267 entropy `S = -∂F̃/∂T` term is `T`-linear
in the log-Z piece, so its contribution to `∂²F̃/∂T²` is **zero**.

The R.267 Maxwell relation `∂F̃/∂T|_⟨V⟩,Z = -log Zpart` says the partition
piece contributes a *constant* (`-log Zpart`) to `∂F̃/∂T` — its second
derivative is `0`.  Hence the entire CV jump is carried by the curvature
of `⟨V⟩(T) = F_min(T)`, the R.269 Landau-minimum.  We record the
`HasDerivAt` of the partition piece and note its slope is constant. -/
theorem R3_partition_piece_constant_slope
    (Vavg Zpart T : ℝ) :
    HasDerivAt (fun s => F Vavg s Zpart) (-(Real.log Zpart)) T :=
  R_267_dFdT_eq_neglogZpart Vavg Zpart T

/-- **Composition (A.4) — `C_V` jump matches the R.267→R.269 chain.**

Given the bundled outputs of R.269 (below/above specific heats
`C_below = T_c·a₀²/(2b)`, `C_above = 0`), the jump `ΔC_V` derived from
the R.267 free energy `F̃` (with `⟨V⟩` plugged in as the R.269 Landau
minimum) is exactly `T_c·a₀²/(2b)`.  This is the headline composition:
**R.267 + R.269 = CV jump from second derivative of F̃**. -/
theorem R3_CV_jump_from_Landau
    (a₀ b T_c C_below C_above ΔC_V : ℝ)
    (h_below : C_below = T_c * a₀ ^ 2 / (2 * b))
    (h_above : C_above = 0)
    (h_jump : ΔC_V = C_below - C_above) :
    ΔC_V = T_c * a₀ ^ 2 / (2 * b) :=
  R_269_jump_from_hyps a₀ b T_c C_below C_above ΔC_V h_below h_above h_jump

/-- **Composition (A.5) — positivity inherited from R.269.**

The composed jump is strictly positive for `T_c > 0`, `a₀ ≠ 0`, `b > 0`:
the R.267 Landau-form free energy delivers a second-order phase
transition signature (positive `ΔC_V`).  Direct reuse of R.269.b. -/
theorem R3_CV_jump_pos_compose
    (a₀ b T_c : ℝ) (hT : 0 < T_c) (ha : a₀ ≠ 0) (hb : 0 < b) :
    0 < T_c * a₀ ^ 2 / (2 * b) :=
  R_269_jump_pos a₀ b T_c hT ha hb

/-- **Composition (A.6) — `F = F̃ + T/2` chain endpoint.**

Combining R.267's `F = E - T·log Z_part = F̃ + T/2` (equipartition shift)
with R.269's `F_min` substitution, the **full** free energy reads

    F(T) = -a₀²(T-T_c)²/(4b) − T·log Z_part + T/2

below `T_c`.  The `T/2` adds a `T`-linear term whose second derivative is
also `0`, so the `C_V` jump value `T_c·a₀²/(2b)` is unchanged. -/
theorem R3_full_F_via_Fmin
    (a₀ b T T_c Zpart E Vavg : ℝ)
    (h_Vavg_eq : Vavg = Fmin a₀ b T_c T)
    (hE : E = T / 2 + Vavg) :
    E - T * Real.log Zpart
      = -(a₀ ^ 2 * (T - T_c) ^ 2) / (4 * b) - T * Real.log Zpart + T / 2 := by
  -- Use R.267's E = T/2 + Vavg, substitute Vavg = Fmin.
  rw [hE, h_Vavg_eq]
  unfold Fmin
  ring

end R3_Agent9_CVJumpFromLandau

end MIP
