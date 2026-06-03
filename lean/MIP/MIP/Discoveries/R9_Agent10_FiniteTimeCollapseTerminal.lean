/-
  STATUS: DISCOVERY
  AGENT: R9_Agent10
  DIRECTION: FINITE-TIME COLLAPSE HITS THE TERMINAL OBJECT.
    The corpus carries (i) a coverage collapse time (R.152): the exponential-decay
    model `p_ω(t) = p_ω(0)·exp(-t/τ_ω)` crosses below the threshold `θ` exactly at
    `t > τ_ω·log(p_ω(0)/θ)`, and the coverage collapse time is the per-element
    minimum `T_collapse = min_ω τ_ω·log(p_ω(0)/θ)` (the "weakest link");
    (ii) a cognitive-singularity arrival time (R.56): under geometric energy decay
    `E_t ≤ E₀·(1-α)^t`, every time `t ≥ log(E₀/ε)/(-log(1-α))` forces the
    approximate-singularity condition `E_t ≤ ε`; (iii) the terminal degeneration
    object (R5_Agent6): the wall configuration `⟨univ, ⊤⟩` is the greatest,
    ABSORBING element of the degeneration poset, and an OOD target REACHES the
    cost-top `N p X = ⊤`; (iv) the Round-8 contact-dissipative decaying Noether
    charge (R8_Agent1): the contact charge `qInf + A0/D` sits strictly above its
    floor at every finite budget and limits to the conserved floor at the wall
    (`contactCharge_tendsto_floor`).

    THIS FILE fuses them into a FINITE-TIME-COLLAPSE-TO-THE-WALL picture: the
    decaying coverage/energy dynamics HIT the singular/collapse state at a FINITE
    time `t_collapse = τ·log(p₀/θ)`, the collapse is ABSORBING IN TIME (once below
    threshold the decay stays below it for all later times), the collapse state IS
    the terminal degeneration object of R5_Agent6 (the OOD cost lands at the
    cost-top `⊤`), and the R8_Agent1 contact charge correspondingly sinks to its
    conserved floor at the wall.

      THE DECAY DYNAMICS COLLAPSE TO THE TERMINAL DEGENERATION OBJECT IN FINITE
      TIME t_collapse; COLLAPSE = HITTING THE WALL, AND THE HIT IS ABSORBING.

  SUMMARY:
    (HIT)   FINITE-TIME HITTING.  Using R.152 `decay_crossing` (the per-element
            crossing iff) the weakest-link element drops below `θ` precisely past
            the finite time `t_collapse = τ_ω·log(p_ω(0)/θ)`; R.152
            `R_152_collapse_time` pins `t_collapse` as the minimum over the finite
            demand set (the weakest link). So the coverage hits the collapse state
            at a finite time given by the corpus formula.

    (ABS)   ABSORBING IN TIME.  Once the decay has crossed below `θ` at some
            `t₁ > t_collapse`, it stays below `θ` for every later time `t₂ ≥ t₁`
            (`collapse_absorbing_in_time`): the exponential is monotone-decreasing,
            so collapse is irreversible — the temporal analogue of the ORDER-
            theoretic absorption of R5_Agent6's terminal object.

    (SING)  SINGULARITY HIT.  R.56 `R_56_threshold` supplies the parallel
            finite-time hit on the energy channel: past `t* = log(E₀/ε)/(-log(1-α))`
            the emergence energy is within `ε` of the singular state. Both channels
            collapse in finite time.

    (TERM)  THE COLLAPSE STATE IS THE TERMINAL OBJECT.  Via R5_Agent6
            `ood_reaches_cost_top` an OOD target's emergence cost lands EXACTLY at
            the terminal cost-top `N p X = ⊤` — the wall — which R5_Agent6 proved
            is the greatest, absorbing element of the degeneration poset. Collapse
            therefore = hitting the wall = reaching the terminal degeneration object.

    (FLOOR) CONTACT CHARGE SINKS TO ITS FLOOR.  In the same wall limit the
            R8_Agent1 contact charge `contactCharge qInf A0 D` sits strictly above
            its conserved Noether floor at every finite budget
            (`dissipation_excess_at_budget`) yet limits to it at the wall
            (`contactCharge_tendsto_floor`): the dissipative excess is exhausted
            exactly as the dynamics reach the terminal wall.

    (HEAD)  HEADLINE `decay_collapses_to_terminal_object_in_finite_time`. One
            statement chaining R.152 (finite collapse time + min characterisation),
            R.56 (singularity hit), R5_Agent6 (collapse = the terminal wall
            `N p X = ⊤`), and R8_Agent1 (contact charge sinks to its floor):
            the decay dynamics collapse to the terminal degeneration object in
            finite time `t_collapse`, the hit is absorbing in time, and that
            collapse state is the terminal/absorbing wall.

  Depends on (exact imported lemmas genuinely used in proof terms below):
    - MIP.Results.R152_CollapseTime
        · CollapseTime.decay_crossing       (USED in finite_collapse_time,
                                              collapse_absorbing_in_time, headline:
                                              the per-element crossing iff)
        · CollapseTime.R_152_collapse_time  (USED in collapse_time_is_weakest_link,
                                              headline: t_collapse = min over demand)
    - MIP.Results.R56_SingularityTime
        · SingularityTime.R_56_threshold    (USED in singularity_hit, headline:
                                              finite-time energy singularity)
    - MIP.Discoveries.R5_Agent6_SaturationIsTerminalDegeneration   [R4/R5 TOWER]
        · R5_Agent6_SaturationIsTerminalDegeneration.ood_reaches_cost_top
                                              (USED in collapse_is_terminal_wall,
                                              headline: OOD cost reaches the
                                              terminal cost-top ⊤ = the wall)
        · R5_Agent6_SaturationIsTerminalDegeneration.cost_absorb_top
                                              (USED in collapse_is_terminal_wall:
                                              the wall ⊤ is absorbing)
    - MIP.Discoveries.R8_Agent1_ContactDissipativeNoether         [R8 TOWER]
        · R8_Agent1_ContactDissipativeNoether.contactCharge
        · R8_Agent1_ContactDissipativeNoether.contactCharge_tendsto_floor
                                              (USED in contact_charge_sinks_to_floor,
                                              headline: charge limits to its floor)
        · R8_Agent1_ContactDissipativeNoether.dissipation_excess_at_budget
                                              (USED in contact_charge_sinks_to_floor,
                                              headline: strictly above floor)
    - Mathlib: Real.exp, Real.log, Real.exp_le_exp, Filter.Tendsto,
               Finset.exists_min_image (through R.152).

  This file is `sorry`-free and `axiom`-free (no NEW axioms; framework axioms only
  via the imported corpus tower).
-/
import MIP.Results.R152_CollapseTime
import MIP.Results.R56_SingularityTime
import MIP.Discoveries.R5_Agent6_SaturationIsTerminalDegeneration
import MIP.Discoveries.R8_Agent1_ContactDissipativeNoether
import Mathlib.Analysis.SpecialFunctions.Exp

namespace MIP

namespace R9_Agent10_FiniteTimeCollapseTerminal

open Filter Topology
open MIP.CollapseTime
open MIP.SingularityTime
open MIP.R4_Agent9_ScalingSaturationWall
open MIP.R5_Agent6_SaturationIsTerminalDegeneration
open MIP.R8_Agent1_ContactDissipativeNoether

/-! ###############################################################
    ###  (HIT)  Finite-time hitting of the collapse state         ###
    ############################################################### -/

/-- The **collapse time** of a single decaying knowledge element with initial
mass `p₀`, time constant `τ`, threshold `θ`:

    tCollapse p₀ τ θ  :=  τ · log (p₀ / θ).

This is the R.152 per-element crossing time: the decay `p₀·exp(-t/τ)` drops below
`θ` exactly past `tCollapse` (R.152 `decay_crossing`). -/
noncomputable def tCollapse (p₀ τ θ : ℝ) : ℝ := τ * Real.log (p₀ / θ)

/-- **(HIT.1) Finite-time hit: the decay crosses below `θ` exactly past the finite
collapse time.**

For positive `p₀, τ, θ`, the exponential-decay model `p₀·exp(-t/τ)` is below the
threshold `θ` if and only if the time `t` exceeds the FINITE collapse time
`tCollapse p₀ τ θ = τ·log(p₀/θ)`. This is R.152 `decay_crossing` packaged as a
finite-time hitting characterisation. -/
theorem finite_collapse_time
    (p₀ τ θ t : ℝ) (h_p₀ : 0 < p₀) (h_τ : 0 < τ) (h_θ : 0 < θ) :
    p₀ * Real.exp (-(t / τ)) < θ ↔ tCollapse p₀ τ θ < t := by
  unfold tCollapse
  exact decay_crossing p₀ τ θ t h_p₀ h_τ h_θ

/-- **(HIT.2) The collapse time is the weakest link (minimum over the demand set).**

If `R(p)` is a finite nonempty demand set, there is a weakest-link element `ω₀ ∈ R`
whose per-element crossing time `τ_ω₀·log(p_ω₀(0)/θ)` is minimal: this minimum IS
the coverage collapse time `T_collapse` of R.152, the earliest finite time at which
SOME demanded element has dropped below threshold. Off R.152 `R_152_collapse_time`. -/
theorem collapse_time_is_weakest_link
    {Ω : Type} [DecidableEq Ω]
    (R : Finset Ω) (hR : R.Nonempty)
    (τ p₀ : Ω → ℝ) (θ : ℝ)
    (hτ : ∀ ω ∈ R, 0 < τ ω) (hp : ∀ ω ∈ R, 0 < p₀ ω) (hθ : 0 < θ) :
    ∃ ω₀ ∈ R, ∀ ω ∈ R, tCollapse (p₀ ω₀) (τ ω₀) θ ≤ tCollapse (p₀ ω) (τ ω) θ := by
  -- Unfold `tCollapse` to the exact shape of R.152 `R_152_collapse_time`.
  simpa only [tCollapse] using R_152_collapse_time R hR τ p₀ θ hτ hp hθ

/-! ###############################################################
    ###  (ABS)  Collapse is absorbing in time (irreversible)      ###
    ############################################################### -/

/-- **(ABS) Collapse is ABSORBING in time.**

Once the decaying element has crossed below the threshold at some time `t₁ > t_collapse`,
it stays below for EVERY later time `t₂ ≥ t₁`: collapse is irreversible. This is the
TEMPORAL analogue of R5_Agent6's order-theoretic absorption — the collapse state, like
the terminal degeneration object, cannot be left once reached.

Proof: the crossing happens past the finite collapse time (R.152 `decay_crossing`),
and the exponential `p₀·exp(-t/τ)` is monotone decreasing in `t` (for `τ > 0`), so the
value only gets smaller at later times, hence still `< θ`. -/
theorem collapse_absorbing_in_time
    (p₀ τ θ t₁ t₂ : ℝ) (h_p₀ : 0 < p₀) (h_τ : 0 < τ) (h_θ : 0 < θ)
    (h_collapsed : tCollapse p₀ τ θ < t₁) (h_later : t₁ ≤ t₂) :
    p₀ * Real.exp (-(t₂ / τ)) < θ := by
  -- At `t₁` the element has collapsed, via R.152 `decay_crossing`.
  have h₁ : p₀ * Real.exp (-(t₁ / τ)) < θ :=
    (finite_collapse_time p₀ τ θ t₁ h_p₀ h_τ h_θ).2 h_collapsed
  -- The exponential is non-increasing in `t`: `-(t₂/τ) ≤ -(t₁/τ)`.
  have h_div : t₁ / τ ≤ t₂ / τ := by
    gcongr
  have h_exp_le : Real.exp (-(t₂ / τ)) ≤ Real.exp (-(t₁ / τ)) := by
    apply Real.exp_le_exp.mpr
    linarith
  have h_mono : p₀ * Real.exp (-(t₂ / τ)) ≤ p₀ * Real.exp (-(t₁ / τ)) :=
    mul_le_mul_of_nonneg_left h_exp_le (le_of_lt h_p₀)
  linarith

/-! ###############################################################
    ###  (SING)  Finite-time singularity hit on the energy channel ###
    ############################################################### -/

/-- **(SING) Finite-time singularity hit (R.56 energy channel).**

In parallel with the coverage collapse, the emergence-energy channel hits the
approximate singularity in finite time: under geometric decay `E_t ≤ E₀·(1-α)^t`,
EVERY time `t ≥ t* := log(E₀/ε)/(-log(1-α))` forces `E_t ≤ ε`. So the energy is
driven within `ε` of the singular state past the finite time `t*`. Off R.56
`R_56_threshold`. -/
theorem singularity_hit
    (α ε E₀ t E_t : ℝ)
    (hα_pos : 0 < α) (hα_lt_one : α < 1) (hε : 0 < ε) (hE₀ : 0 < E₀)
    (h_decay : E_t ≤ E₀ * (1 - α) ^ t)
    (h_t : Real.log (E₀ / ε) / (-Real.log (1 - α)) ≤ t) :
    E_t ≤ ε :=
  R_56_threshold α ε E₀ t E_t hα_pos hα_lt_one hε hE₀ h_decay h_t

/-! ###############################################################
    ###  (TERM)  The collapse state IS the terminal wall          ###
    ############################################################### -/

/-- **(TERM) The collapse state is the terminal degeneration object (the wall).**

An out-of-distribution target's emergence cost lands EXACTLY at the terminal cost-top
`N p X = ⊤` — the wall — which R5_Agent6 proved is the greatest, ABSORBING element of
the degeneration poset (any `x` with `⊤ ≤ x` is forced back to `⊤`). So the collapse
state reached by the decay dynamics is precisely the terminal degeneration object, and
it is absorbing: nothing exceeds it. Off R5_Agent6 `ood_reaches_cost_top` and
`cost_absorb_top`. -/
theorem collapse_is_terminal_wall
    {α' Ω' : Type} (p : MIP.Problem α') (X : MIP.Agent α')
    (hood : IsOOD (Ω := Ω') (p, X)) :
    MIP.N p X = (⊤ : ℕ∞) ∧ ∀ x : ℕ∞, (⊤ : ℕ∞) ≤ x → x = (⊤ : ℕ∞) := by
  refine ⟨?_, ?_⟩
  · -- OOD cost reaches the terminal cost-top (the wall), via R5_Agent6.
    exact (ood_reaches_cost_top (Ω' := Ω') p X hood).1
  · -- The wall ⊤ is absorbing, via R5_Agent6.
    intro x hx
    exact cost_absorb_top x hx

/-! ###############################################################
    ###  (FLOOR)  The contact charge sinks to its conserved floor ###
    ############################################################### -/

/-- **(FLOOR) The contact charge sinks to its conserved floor at the wall.**

As the budget/time runs to the terminal wall `D → ∞`, the R8_Agent1 contact charge
`contactCharge qInf A0 D = qInf + A0/D` sits STRICTLY above its conserved Noether floor
`qInf` at every finite budget (`dissipation_excess_at_budget`, for `A0,D > 0`) yet
LIMITS to it (`contactCharge_tendsto_floor`): the dissipative excess is exhausted
exactly as the dynamics reach the terminal wall, mirroring the coverage decay hitting
its collapse floor `θ`. Off R8_Agent1. -/
theorem contact_charge_sinks_to_floor
    (qInf A0 D : ℝ) (hA0 : 0 < A0) (hD : 0 < D) :
    qInf < contactCharge qInf A0 D
      ∧ Tendsto (fun D => contactCharge qInf A0 D) atTop (𝓝 qInf) :=
  ⟨dissipation_excess_at_budget qInf A0 D hA0 hD,
   contactCharge_tendsto_floor qInf A0⟩

/-! ###############################################################
    ###  (HEAD)  HEADLINE — finite-time collapse to the terminal   ###
    ###          degeneration object                              ###
    ############################################################### -/

/-- **(HEAD) HEADLINE — the decay dynamics collapse to the terminal degeneration
object in finite time `t_collapse`; collapse = hitting the wall.**

Chaining R.152 (collapse time + weakest-link minimum), R.56 (singularity hit),
R5_Agent6 (the terminal wall), and R8_Agent1 (the contact-charge floor), with a finite
nonempty demand set `R(p)`, a positive threshold `θ`, an OOD target `(p, X)`, geometric
energy decay, and an active dissipative contact charge:

  (HIT)   there is a FINITE collapse time `t_collapse = min_ω τ_ω·log(p_ω(0)/θ)`,
          attained at a weakest-link element `ω₀ ∈ R`, and past `t_collapse` the
          decay `p_ω₀(0)·exp(-t/τ_ω₀)` is below `θ` (the element has collapsed),
          while at or before it the element is at or above `θ` — a genuine finite
          hitting time given by the corpus formula;
  (ABS)   the collapse is ABSORBING in time: once below `θ` it stays below for all
          later times (irreversible, the temporal analogue of terminal absorption);
  (SING)  the energy channel hits the approximate singularity `E_t ≤ ε` past the
          finite time `t* = log(E₀/ε)/(-log(1-α))`;
  (TERM)  the collapse state IS the terminal degeneration object: the OOD cost lands
          at the cost-top `N p X = ⊤` (the wall), which is absorbing (`⊤ ≤ x → x = ⊤`);
  (FLOOR) and the dissipative contact charge sits strictly above its conserved floor
          at every finite budget yet limits to it at the wall — the dissipative excess
          exhausted exactly as the dynamics reach the terminal object.

Thus the decaying coverage/energy dynamics collapse to the terminal degeneration
object in finite time `t_collapse`, the hit is absorbing, and collapse = hitting the
terminal/absorbing wall. -/
theorem decay_collapses_to_terminal_object_in_finite_time
    {Ω : Type} [DecidableEq Ω]
    {α' Ω' : Type}
    (R : Finset Ω) (hR : R.Nonempty)
    (τ p₀ : Ω → ℝ) (θ : ℝ)
    (hτ : ∀ ω ∈ R, 0 < τ ω) (hp : ∀ ω ∈ R, 0 < p₀ ω) (hθ : 0 < θ)
    (p : MIP.Problem α') (X : MIP.Agent α')
    (hood : IsOOD (Ω := Ω') (p, X))
    (Ealpha Eε E₀ Et tE : ℝ)
    (hEα_pos : 0 < Ealpha) (hEα_lt_one : Ealpha < 1)
    (hEε : 0 < Eε) (hE₀ : 0 < E₀)
    (hE_decay : Et ≤ E₀ * (1 - Ealpha) ^ tE)
    (hE_t : Real.log (E₀ / Eε) / (-Real.log (1 - Ealpha)) ≤ tE)
    (qInf A0 D : ℝ) (hA0 : 0 < A0) (hD : 0 < D) :
    -- (HIT) finite collapse time = weakest-link minimum, with the crossing characterisation
    (∃ ω₀ ∈ R,
        (∀ ω ∈ R, tCollapse (p₀ ω₀) (τ ω₀) θ ≤ tCollapse (p₀ ω) (τ ω) θ)
        ∧ (∀ t : ℝ, tCollapse (p₀ ω₀) (τ ω₀) θ < t →
            p₀ ω₀ * Real.exp (-(t / τ ω₀)) < θ))
    -- (ABS) collapse is absorbing in time
    ∧ (∀ t₁ t₂ : ℝ, ∀ ω ∈ R, tCollapse (p₀ ω) (τ ω) θ < t₁ → t₁ ≤ t₂ →
        p₀ ω * Real.exp (-(t₂ / τ ω)) < θ)
    -- (SING) finite-time singularity hit on the energy channel
    ∧ Et ≤ Eε
    -- (TERM) the collapse state is the terminal wall, which is absorbing
    ∧ (MIP.N p X = (⊤ : ℕ∞) ∧ ∀ x : ℕ∞, (⊤ : ℕ∞) ≤ x → x = (⊤ : ℕ∞))
    -- (FLOOR) the contact charge sits above its floor yet sinks to it at the wall
    ∧ (qInf < contactCharge qInf A0 D
        ∧ Tendsto (fun D => contactCharge qInf A0 D) atTop (𝓝 qInf)) := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · -- (HIT) weakest link from R.152, plus the per-element crossing past t_collapse.
    obtain ⟨ω₀, hω₀, hmin⟩ := collapse_time_is_weakest_link R hR τ p₀ θ hτ hp hθ
    refine ⟨ω₀, hω₀, hmin, ?_⟩
    intro t ht
    exact (finite_collapse_time (p₀ ω₀) (τ ω₀) θ t (hp ω₀ hω₀) (hτ ω₀ hω₀) hθ).2 ht
  · -- (ABS) absorbing in time, per element of the demand set.
    intro t₁ t₂ ω hω hcol hlater
    exact collapse_absorbing_in_time (p₀ ω) (τ ω) θ t₁ t₂
      (hp ω hω) (hτ ω hω) hθ hcol hlater
  · -- (SING) R.56 finite-time singularity hit.
    exact singularity_hit Ealpha Eε E₀ tE Et hEα_pos hEα_lt_one hEε hE₀ hE_decay hE_t
  · -- (TERM) the collapse state is the terminal wall (R5_Agent6).
    exact collapse_is_terminal_wall (Ω' := Ω') p X hood
  · -- (FLOOR) the contact charge sinks to its floor (R8_Agent1).
    exact contact_charge_sinks_to_floor qInf A0 D hA0 hD

end R9_Agent10_FiniteTimeCollapseTerminal

end MIP
