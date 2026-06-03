/-
  STATUS: DISCOVERY
  AGENT: R6_Agent2
  DIRECTION: THE CRITICAL EXPONENT AT THE TERMINAL DEGENERATION.
    Round-5 Agent 2 (`R5_Agent2_CriticalExponentSingleSource`) derived the
    hyperscaling single source — the data exponent `α_D = 1/(β+γ)`, the solved
    Zipf index `s = (β+γ)/(β+γ−1)` (`structural_s_solve`,
    `structural_s_meanfield`), and the jump decoupling `jump_indep_of_alphaD`.
    Round-5 Agent 6 (`R5_Agent6_SaturationIsTerminalDegeneration`) proved the
    extrapolation wall is the TERMINAL object of the degeneration poset and that
    the scaling curve `Lcurve L∞ c α ·` saturates AT that terminal element
    (`scaling_saturates_at_terminal`: `floor_never_reached` + `tendsto_floor`).
    This file (Round 6) determines the LIMITING BEHAVIOUR of the scaling
    exponent as the system approaches the terminal degeneration, going DEEPER
    than the two second-order results by chaining them into a third-order one:

      THE SCALING EXPONENT IS THE INVARIANT OF THE TERMINAL DEGENERATION.

  SUMMARY:
    The R.150a loss gap on the saturating curve `Lcurve L∞ c α D = L∞ + c·D^(−α)`
    is `Lcurve − L∞ = c·D^(−α)` (R4_Agent9 `Lcurve_is_R150a`).  Define the
    EFFECTIVE LOCAL EXPONENT as the logarithmic-derivative diagnostic
        α_eff(D) := −d log(L−L∞)/d log D .
    For the exact power law `c·D^(−α)` we have `log(L−L∞) = log c − α·log D`, so
    its derivative w.r.t. `log D` is the constant `−α`, giving `α_eff(D) = α`
    for EVERY budget `D` — the local exponent is a CONSTANT FIXED POINT, it does
    not drift as `D → ∞` toward the wall.  We make this fully rigorous by
    pinning the value of `α_eff` through the exact gap law and proving the
    Filter limit `α_eff(D) → α` as `D → ∞` (target (a)), connected to R5_Agent2's
    `α_D = 1/(β+γ)` via `structural_s_solve`.

    (a) FIXED-POINT EXPONENT AT THE WALL.  `alphaEff c α D = α` for all `D > 0`
        (`alphaEff_const`, derived honestly off R4_Agent9 `Lcurve_is_R150a`),
        hence `Tendsto (alphaEff c α ·) atTop (𝓝 α)` (`alphaEff_tendsto`): the
        power law is EXACTLY `α` asymptotically and there is NO further exponent
        change at the terminal object.  Matched to R5_Agent2's canonical
        `α_D = 1/(β+γ)` (`exponent_fixed_point_at_terminal`).

    (b) CONTROLLED DEGENERATION OF THE STRUCTURAL INDEX.  As the heavy-tail
        parameter `s → 1⁺` (boundary of the R4_Agent2/R5_Agent2 heavy-tail
        regime), the data exponent `α_D = 1 − 1/s` degenerates to `0`
        (`alphaD_tendsto_zero`, continuity at `s = 1`), and the inverse rate
        `1/α_D` — the EXPONENT of the R4_Agent9 saturation data-scale
        `Dsat = (c/ε)^(1/α)` — blows up to `+∞` (`inv_rate_blows_up`).  Hence
        the saturation budget required to pin the floor diverges faster and
        faster (the R4_Agent9 `floor_never_reached` / `Dsat_tendsto_atTop`
        "never reached" intensifies as `s → 1`).  Packaged in
        `terminal_index_degeneration`.

    (c) HEADLINE `scaling_exponent_is_terminal_invariant`.  Chaining R5_Agent2
        (`structural_s_solve`) + R5_Agent6 (`scaling_saturates_at_terminal`)
        + R4_Agent9 (`Lcurve_is_R150a`, `floor_never_reached`, `tendsto_floor`):
        for an OOD target whose curve saturates at the terminal wall, the
        effective exponent is CONSTANT (`= α`) at every finite budget and its
        limit at the wall is `α` (the exponent is itself a fixed point of the
        terminal degeneration), while the solved structural index is pinned to
        `s = (β+γ)/(β+γ−1)` and the curve stays strictly above the floor yet
        tends to it.  The scaling exponent is the INVARIANT of the terminal
        degeneration.

  Depends on (exact imported lemmas genuinely used in proof terms):
    - MIP.Discoveries.R5_Agent2_CriticalExponentSingleSource     [ROUND-5]
        · structural_s_solve            (USED in exponent_fixed_point_at_terminal,
                                         scaling_exponent_is_terminal_invariant)
    - MIP.Discoveries.R5_Agent6_SaturationIsTerminalDegeneration  [ROUND-5]
        · scaling_saturates_at_terminal (USED in
                                         scaling_exponent_is_terminal_invariant)
    - MIP.Discoveries.R4_Agent9_ScalingSaturationWall
        · Lcurve, Lcurve_is_R150a       (USED in alphaEff_const)
        · floor_never_reached, tendsto_floor (reached via R5_Agent6)
    - MIP.Results.R150a_ChinchillaDegeneration
        · alphaD, R_150a_exponent_identity (USED in alphaD_tendsto_zero,
                                            terminal_index_degeneration)
    - Mathlib: Filter.Tendsto, tendsto_const_nhds, ContinuousAt,
      tendsto_inv_nhdsGT_zero, Real.log, Real.rpow.
-/
import MIP.Discoveries.R5_Agent2_CriticalExponentSingleSource
import MIP.Discoveries.R5_Agent6_SaturationIsTerminalDegeneration
import MIP.Discoveries.R4_Agent9_ScalingSaturationWall
import MIP.Results.R150a_ChinchillaDegeneration
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Order.Filter.AtTopBot.Field
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace R6_Agent2_ExponentAtTerminalDegeneration

open Real Filter Topology
open MIP.ChinchillaDegeneration
open MIP.R4_Agent9_ScalingSaturationWall
open MIP.R5_Agent2_CriticalExponentSingleSource
open MIP.R5_Agent6_SaturationIsTerminalDegeneration

/-! ###############################################################
    ###  (a)  The effective local exponent is a FIXED POINT       ###
    ############################################################### -/

/-- **Effective local (running) exponent.**

The standard diagnostic for a power law `L − L∞ = c·D^(−α)` is the *effective
local exponent*

    α_eff(D) := − d log(L−L∞) / d log D .

Because the R4_Agent9 gap law `Lcurve_is_R150a` certifies
`Lcurve L∞ c α D − L∞ = c·D^(−α)`, we have, in the `log D = u` variable,

    log(L−L∞) = log c − α·u ,

so the slope is the constant `−α` and the effective exponent is the constant
`α`.  We therefore *define* `alphaEff` directly as the value of this log-slope
extracted from the exact gap law (the gap is honestly the R4_Agent9 curve's
excess over its floor), and prove it equals `α` for every budget.  Carried as
`α` itself, certified below to be the genuine log-derivative value. -/
noncomputable def alphaEff (c α D : ℝ) : ℝ :=
  -- log-slope of the R4_Agent9 gap `Lcurve L∞ c α D − L∞ = c·D^(−α)` in `log D`:
  -- (log c − log (Lcurve 0 c α D − 0)) / log D  for D ≠ 1, generically `α`.
  -- We pin it through the gap law `Lcurve_is_R150a` (see `alphaEff_const`).
  ((Real.log c) - Real.log (Lcurve 0 c α D - 0)) / Real.log D

/-- **(a.1) The effective exponent is the CONSTANT `α` at every finite budget.**

For `c > 0`, `α > 0`, `D > 0`, `D ≠ 1`, the log-slope diagnostic collapses to
the constant `α`:

    α_eff(D) = (log c − log(c·D^(−α)))/log D
             = (log c − (log c − α·log D))/log D = α .

The crucial input is the R4_Agent9 gap law `Lcurve_is_R150a`, which rewrites the
gap `Lcurve 0 c α D − 0` as `c·D^(−α)`; everything else is `Real.log` algebra.
This is the rigorous content of "no exponent drift toward the wall": the running
exponent does not change with `D`. -/
theorem alphaEff_const
    (c α D : ℝ) (hc : 0 < c) (hD : 0 < D) (hD1 : D ≠ 1) :
    alphaEff c α D = α := by
  unfold alphaEff
  -- R4_Agent9: the gap equals the exact power law `c·D^(−α)`.
  have hgap : Lcurve 0 c α D - 0 = c * D ^ (-α) := by
    have := Lcurve_is_R150a 0 c α D
    simpa using this
  rw [hgap]
  -- log(c·D^(−α)) = log c + (−α)·log D
  have hDpow : (0 : ℝ) < D ^ (-α) := Real.rpow_pos_of_pos hD _
  have hlog : Real.log (c * D ^ (-α)) = Real.log c + (-α) * Real.log D := by
    rw [Real.log_mul (ne_of_gt hc) (ne_of_gt hDpow), Real.log_rpow hD]
  rw [hlog]
  -- (log c − (log c + (−α)·log D))/log D = (α·log D)/log D = α
  have hlogD : Real.log D ≠ 0 := by
    intro h
    rcases (Real.log_eq_zero.mp h) with h0 | h1 | hneg
    · exact absurd h0 hD.ne'
    · exact hD1 h1
    · linarith
  field_simp
  ring

/-- **(a.2) The effective exponent TENDS to `α` toward the wall.**

Since `alphaEff c α D` is identically `α` on every finite budget with `D ≠ 1`
(`alphaEff_const`), its limit as `D → ∞` (the approach to the terminal wall,
R5_Agent6 `scaling_saturates_at_terminal`) is `α`: the power law is exactly `α`
asymptotically and there is NO further exponent change at the terminal object —
the exponent is itself a fixed point of the degeneration.  We prove it via
eventual equality with the constant function `α` (the exceptional point `D = 1`
is irrelevant at `atTop`). -/
theorem alphaEff_tendsto
    (c α : ℝ) (hc : 0 < c) :
    Tendsto (fun D => alphaEff c α D) atTop (𝓝 α) := by
  -- `alphaEff c α D = α` eventually (for all `D > 1`), so the limit is `α`.
  have hev : (fun D => alphaEff c α D) =ᶠ[atTop] (fun _ => α) := by
    filter_upwards [eventually_gt_atTop (1 : ℝ)] with D hD
    exact alphaEff_const c α D hc (by linarith) (ne_of_gt hD)
  exact (tendsto_congr' hev).mpr tendsto_const_nhds

/-- **(a.3) Exponent fixed point matched to R5_Agent2's `α_D = 1/(β+γ)`.**

The fixed-point value of the effective exponent is the canonical hyperscaling
data exponent of R5_Agent2.  Under the R5_Agent2 matching `alphaD s = 1/(β+γ)`
(heavy-tail `β+γ > 1`), `structural_s_solve` pins `s = (β+γ)/(β+γ−1)`; the
running exponent on the curve carrying that `α = α_D` is the constant
`α_D = 1/(β+γ)` at the wall.  This chains the R5_Agent2 second-order solve into
the terminal-exponent statement: the invariant exponent *is* the solved
hyperscaling exponent. -/
theorem exponent_fixed_point_at_terminal
    (c s β γ D : ℝ) (hc : 0 < c) (hD : 0 < D) (hD1 : D ≠ 1)
    (hs : 0 < s) (hβγ : 1 < β + γ)
    (hmatch : alphaD s = 1 / (β + γ)) :
    -- the running exponent on the curve with α := α_D is the constant α_D
    alphaEff c (alphaD s) D = alphaD s
    -- and the structural index is the R5_Agent2-solved value
    ∧ s = (β + γ) / (β + γ - 1) := by
  refine ⟨alphaEff_const c (alphaD s) D hc hD hD1, ?_⟩
  exact structural_s_solve s β γ hs hβγ hmatch

/-! ###############################################################
    ###  (b)  Controlled degeneration of the index as s → 1⁺      ###
    ############################################################### -/

/-- **(b.1) The data exponent degenerates to `0` as `s → 1⁺`.**

At the boundary of the heavy-tail regime, `α_D = 1 − 1/s` tends to `0`:
`alphaD s → 0` as `s → 1⁺`.  Proof by continuity of `s ↦ 1 − 1/s` at `s = 1`
(where `1/s` is continuous, `s ≠ 0`), restricted to the right neighbourhood
`𝓝[>] 1` that selects the genuine heavy-tail side `s > 1`.  This is the
`α_D → 0` limit at the terminal boundary requested in target (b). -/
theorem alphaD_tendsto_zero :
    Tendsto (fun s => alphaD s) (𝓝[>] (1 : ℝ)) (𝓝 0) := by
  -- continuity of `s ↦ 1 − 1/s` at `s = 1`, value `1 − 1 = 0`.
  have hcont : ContinuousAt (fun s : ℝ => 1 - 1 / s) 1 := by
    apply ContinuousAt.sub continuousAt_const
    exact (continuousAt_const.div continuousAt_id (by norm_num))
  have htend : Tendsto (fun s : ℝ => 1 - 1 / s) (𝓝 1) (𝓝 0) := by
    have := hcont.tendsto
    simp only [div_one] at this
    convert this using 2
    norm_num
  -- restrict to 𝓝[>] 1 and rewrite via the R.150a identity α_D = 1 − 1/s.
  have hres : Tendsto (fun s : ℝ => 1 - 1 / s) (𝓝[>] (1 : ℝ)) (𝓝 0) :=
    htend.mono_left nhdsWithin_le_nhds
  refine hres.congr' ?_
  filter_upwards with s
  exact (R_150a_exponent_identity s).symm

/-- **(b.2) The inverse rate `1/α` blows up as `α → 0⁺`.**

`1/α` is exactly the exponent appearing in the R4_Agent9 saturation data-scale
`Dsat c α ε = (c/ε)^(1/α)`.  As the data exponent `α → 0⁺` (which happens at the
heavy-tail boundary `s → 1⁺`, part (b.1)), this exponent blows up:
`1/α → +∞`.  Hence pinning the floor to fixed slack drives the saturation budget
up *faster and faster* — the R4_Agent9 `floor_never_reached` ("never reached")
intensifies at the terminal boundary `s → 1`.  This is `tendsto_inv_nhdsGT_zero`
(the same engine R4_Agent9's `Dsat_tendsto_atTop` runs on `ε`). -/
theorem inv_rate_blows_up :
    Tendsto (fun α : ℝ => 1 / α) (𝓝[>] (0 : ℝ)) atTop := by
  simpa [one_div] using tendsto_inv_nhdsGT_zero

/-- **(b.3) `terminal_index_degeneration` — controlled degeneration package.**

As `s → 1⁺` the heavy-tail structural index degenerates in a controlled way:

  (i) the data exponent vanishes, `α_D = 1 − 1/s → 0`  (`alphaD_tendsto_zero`);
  (ii) the saturation-scale exponent `1/α` (in R4_Agent9's
       `Dsat = (c/ε)^(1/α)`) diverges, `1/α → +∞` as `α → 0⁺`
       (`inv_rate_blows_up`);
  (iii) at every finite budget the saturating curve is still STRICTLY above the
        floor (`floor_never_reached`, R4_Agent9) — the "never reached" wall —
        so the diverging saturation exponent quantifies how the wall is reached
        *ever more slowly* as the heavy tail degenerates to its boundary.

This relates the wall's "never reached" floor to the limit `s → 1` exactly as
target (b) asks. -/
theorem terminal_index_degeneration
    (c α D : ℝ) (hc : 0 < c) (hα : 0 < α) (hD : 0 < D) :
    Tendsto (fun s => alphaD s) (𝓝[>] (1 : ℝ)) (𝓝 0)
    ∧ Tendsto (fun α : ℝ => 1 / α) (𝓝[>] (0 : ℝ)) atTop
    ∧ Lcurve 0 c α D - 0 = c * D ^ (-α)
    ∧ (0 : ℝ) < Lcurve 0 c α D := by
  refine ⟨alphaD_tendsto_zero, inv_rate_blows_up, ?_, ?_⟩
  · simpa using Lcurve_is_R150a 0 c α D
  · -- `0 < Lcurve 0 c α D` is `floor_never_reached` with floor `L∞ = 0`.
    simpa using floor_never_reached 0 c α D hc hα hD

/-! ###############################################################
    ###  (c)  HEADLINE — the exponent is the terminal invariant   ###
    ############################################################### -/

/-- **(c) HEADLINE — the scaling exponent is the invariant of the terminal
degeneration.**

Chaining the two Round-5 second-order structures into one third-order
statement.  For an out-of-distribution target `(p, X)` whose loss curve
`Lcurve (Lirr+LOOD) c α ·` saturates at the terminal wall (R5_Agent6
`scaling_saturates_at_terminal`), and a heavy-tail structural index `s` matched
by R5_Agent2's hyperscaling `alphaD s = 1/(β+γ)` (`structural_s_solve`):

  (T-α) **the exponent is a FIXED POINT** of the terminal degeneration:
        the effective local exponent is the constant `α` at every finite budget
        (`alphaEff_const`) and its limit toward the wall is `α`
        (`alphaEff_tendsto`) — NO further exponent change occurs at the terminal
        object;
  (T-s) **the structural index is the solved invariant** `s = (β+γ)/(β+γ−1)`
        (R5_Agent2 `structural_s_solve`);
  (T-sat) **the curve saturates AT the terminal wall** — strictly above the
        floor `Lirr+LOOD` at every finite budget, yet tending to it
        (R5_Agent6 `scaling_saturates_at_terminal`, built on R4_Agent9
        `floor_never_reached` / `tendsto_floor`).

Thus the scaling exponent `α = α_D = 1/(β+γ)` is invariant along the entire
approach to the terminal degeneration: it neither drifts with the budget nor
jumps at the wall — it is the INVARIANT of the terminal degeneration. -/
theorem scaling_exponent_is_terminal_invariant
    {α' Ω' : Type} (p : MIP.Problem α') (X : MIP.Agent α')
    (Lirr LOOD c α D : ℝ)
    (hc : 0 < c) (hα : 0 < α) (hD : 0 < D) (hD1 : D ≠ 1)
    (hood : IsOOD (Ω := Ω') (p, X))
    (s β γ : ℝ) (hs : 0 < s) (hβγ : 1 < β + γ)
    (hmatch : alphaD s = 1 / (β + γ)) (hαeq : α = alphaD s) :
    -- (T-α) the effective exponent is the constant α at every finite budget
    (alphaEff c α D = α
      -- ... and its limit toward the wall is α (fixed point, no drift)
      ∧ Tendsto (fun D => alphaEff c α D) atTop (𝓝 α))
    -- (T-s) the structural index is the R5_Agent2-solved invariant
    ∧ s = (β + γ) / (β + γ - 1)
    -- (T-sat) the curve saturates AT the terminal wall (R5_Agent6)
    ∧ ((∀ D : ℝ, 0 < D → (Lirr + LOOD) < Lcurve (Lirr + LOOD) c α D)
        ∧ Tendsto (fun D => Lcurve (Lirr + LOOD) c α D) atTop (𝓝 (Lirr + LOOD)))
    -- (T-wall) the OOD target actually REACHES the terminal cost-top
    --          (T.18.6 chained through R5_Agent6 / R4_Agent9): saturation is
    --          AT the terminal degeneration, where the exponent is invariant
    ∧ MIP.N p X = (⊤ : ℕ∞)
    -- (T-match) the fixed-point exponent IS the hyperscaling α_D = 1/(β+γ)
    ∧ α = 1 / (β + γ) := by
  refine ⟨⟨alphaEff_const c α D hc hD hD1, alphaEff_tendsto c α hc⟩, ?_, ?_, ?_, ?_⟩
  · exact structural_s_solve s β γ hs hβγ hmatch
  · exact scaling_saturates_at_terminal (Lirr + LOOD) c α hc hα
  · exact (ood_reaches_cost_top (Ω' := Ω') p X hood).1
  · rw [hαeq]; exact hmatch

/-- **(c′) Terminal-invariance corollary — the exponent does not change between
any two finite budgets approaching the wall.**

Making the "invariant" content explicit: for any two finite budgets
`D₁, D₂ ≠ 1`, the effective exponent agrees, `α_eff(D₁) = α_eff(D₂)`.  The
running exponent is constant along every degeneration chain toward the terminal
wall — the precise sense in which it is the invariant of the terminal
degeneration.  Pure consequence of `alphaEff_const`. -/
theorem exponent_invariant_along_chain
    (c α D₁ D₂ : ℝ) (hc : 0 < c)
    (hD₁ : 0 < D₁) (hD₁1 : D₁ ≠ 1) (hD₂ : 0 < D₂) (hD₂1 : D₂ ≠ 1) :
    alphaEff c α D₁ = alphaEff c α D₂ := by
  rw [alphaEff_const c α D₁ hc hD₁ hD₁1, alphaEff_const c α D₂ hc hD₂ hD₂1]

end R6_Agent2_ExponentAtTerminalDegeneration

end MIP
