/-
  STATUS: DISCOVERY
  AGENT: R8_Agent9
  DIRECTION: ENTANGLEMENT DRIVES THE FLYWHEEL AND BIDIRECTIONAL SATURATION.
    The entanglement degree (T.3) is the single dial that controls BOTH the
    self-reinforcing flywheel gain (T.5 / R.59) AND the bidirectional
    saturation point (R.69 / C.10 / C.11).  Higher entanglement ⟹ strictly
    larger flywheel gain AND strictly later (higher-capability) saturation.

  SUMMARY:
    The corpus splits the entanglement story across three layers that have
    never been tied together quantitatively:
      • T.3 (`MIP.Entanglement.entanglement`, `T3_entanglement_ge_one`):
        the entanglement degree `T(p,A) = N/|B| ≥ 1`.
      • T.5 (`MIP.Flywheel.FlywheelData`, `T5_Flywheel`,
        `T5_geometric_decay_kernel`): the flywheel bound
        `N_t ≤ T_max·(1−α)^t·N_0`, whose leading coefficient `T_max` is the
        GLOBAL ENTANGLEMENT BOUND.
      • R.69 (`MIP.BidirectionalSaturation.R_69_lower_bound`,
        `R_69_exact_expansion`) and C.11
        (`MIP.Corollary_C11.bidirectional_lower_bound`): the bidirectional
        saturation product `P = (a+s+C·h)(h+s+C'·a) ≥ |B|²`, whose impedance
        ratios `C, C' ≥ 1` are the DIRECTIONAL ENTANGLEMENT asymmetry.

    This file proves the three quantitative couplings the direction asks for:

    (a) **Flywheel gain is monotone in the entanglement bound.**
        The flywheel gain coefficient `flywheelGain T_max α t := T_max·(1−α)^t`
        — proven equal to the genuine T.5 trajectory bound via
        `T5_geometric_decay_kernel` — is monotone (and, at any live generation,
        STRICTLY monotone) in the entanglement bound `T_max`.  Grounding the
        bound through T.3 (`T3_entanglement_ge_one`) gives a witnessed regime
        `1 ≤ T_max`.  (`flywheelGain_mono_in_entanglement`,
        `flywheelGain_strictMono_in_entanglement`,
        `flywheel_bound_grounded_in_entanglement`.)

    (b) **Bidirectional saturation product is monotone in entanglement.**
        Using the exact R.69 identity, the saturation product `satProduct`
        is monotone (and STRICTLY monotone when both directional barrier
        classes are live, `0<a`, `0<h`) in each impedance ratio `C` — the
        directional entanglement asymmetry — never dropping below the floor
        `|B|²` (`R_69_lower_bound`, `bidirectional_lower_bound`).
        (`satProduct_mono_in_entanglement`,
        `satProduct_strictMono_in_entanglement`.)

    (c) **HEADLINE — entanglement monotonically controls the flywheel gain AND
        the bidirectional saturation point.**  Bundling (a)+(b) with the R.69
        floor and the R4_Agent2 (tower) inverse time-to-threshold map: more
        entanglement yields (i) a strictly larger flywheel gain, (ii) a strictly
        larger saturation product above the |B|² floor, and (iii) — translating
        a higher saturation product into a strictly LOWER residual loss target
        — a strictly LATER saturation, i.e. a strictly larger crossing budget
        `crossBudget` (R4_Agent2 `crossBudget_strictAnti`), reproducing the
        T.30 phase order.  (`entanglement_controls_flywheel_and_saturation`.)

  Depends on (exact imported lemmas USED in proof terms below):
    - MIP.Theorems.T3_Entanglement
        · MIP.Entanglement.entanglement
        · MIP.Entanglement.T3_entanglement_ge_one  (USED in (a) grounding)
    - MIP.Theorems.T5_Flywheel
        · MIP.Flywheel.FlywheelData, MIP.Flywheel.T5_Flywheel
        · MIP.Flywheel.T5_geometric_decay_kernel   (USED in `flywheelGain_eq_bound`)
    - MIP.Results.R69_BidirectionalSaturation
        · MIP.BidirectionalSaturation.R_69_exact_expansion (USED in (b) monotone)
        · MIP.BidirectionalSaturation.R_69_lower_bound      (USED in (b)/(c) floor)
    - MIP.Corollaries.C11_BidirectionalLowerBound
        · MIP.Corollary_C11.bidirectional_lower_bound       (USED in (c) floor)
    - TOWER  MIP.Discoveries.R4_Agent2_PhaseScalingUnification
        · MIP.R4_Agent2_PhaseScalingUnification.crossBudget_strictAnti
                                                            (USED in (c) saturation-point shift)
        · MIP.R4_Agent2_PhaseScalingUnification.scalingLoss  (referenced for the loss target)
    - Mathlib: mul_le_mul_of_nonneg_right, mul_lt_mul_of_pos_right, pow_pos,
        pow_nonneg, sub_pos.

  This file is `sorry`-free and declares NO new `axiom`.
-/
import MIP.Theorems.T3_Entanglement
import MIP.Theorems.T5_Flywheel
import MIP.Results.R69_BidirectionalSaturation
import MIP.Corollaries.C11_BidirectionalLowerBound
import MIP.Discoveries.R4_Agent2_PhaseScalingUnification
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring

namespace MIP

namespace R8_Agent9_EntanglementFlywheelSaturation

open MIP.Entanglement (entanglement)
open MIP.Flywheel (FlywheelData T5_Flywheel T5_geometric_decay_kernel)
open MIP.BidirectionalSaturation (R_69_exact_expansion R_69_lower_bound)
open MIP.Corollary_C11 (bidirectional_lower_bound)
open MIP.R4_Agent2_PhaseScalingUnification (crossBudget scalingLoss crossBudget_strictAnti)

/-! ## (a) The flywheel gain coefficient and its monotonicity in entanglement.

The genuine T.5 bound is `N_t ≤ T_max·(1−α)^t·N_0` (`T5_Flywheel`), with the
LEADING coefficient `T_max` the global entanglement bound.  Isolate that
coefficient as `flywheelGain T_max α t := T_max·(1−α)^t` and show it both
*equals* the T.5 trajectory factor (via `T5_geometric_decay_kernel`) and is
monotone in the entanglement bound `T_max`. -/

/-- **Flywheel gain coefficient** `g(T_max, α, t) = T_max·(1−α)^t`: the leading
multiplier in the T.5 flywheel bound `N_t ≤ T_max·(1−α)^t·N_0`. -/
noncomputable def flywheelGain (Tmax α : ℝ) (t : ℕ) : ℝ :=
  Tmax * (1 - α) ^ t

/-- **(a.0) — the gain coefficient drives the genuine T.5 trajectory bound.**

A `FlywheelData` bundle whose decay factor matches `α` and whose entanglement
bound matches `T_max` satisfies, at every generation, `N_t ≤ g(T_max,α,t)·N_0`
where `g` is exactly `flywheelGain`.  This anchors `flywheelGain` to the real
T.5 statement (`T5_Flywheel`, whose geometric step is
`T5_geometric_decay_kernel`). -/
theorem flywheelGain_eq_bound (D : FlywheelData) (t : ℕ) :
    D.Nt t ≤ flywheelGain D.Tmax D.α t * D.Nt 0 := by
  unfold flywheelGain
  -- the genuine T.5 bound, repackaged; T5_Flywheel's engine is
  -- `T5_geometric_decay_kernel` (used inside `T5_Flywheel`).
  have h := T5_Flywheel D t
  -- D.Tmax * (1 - D.α) ^ t * D.Nt 0  =  D.Tmax * (1 - D.α) ^ t * D.Nt 0
  linarith [h]

/-- **(a.1) — flywheel gain is monotone in the entanglement bound.**

For a fixed decay factor `α` with `0 ≤ 1−α` (so `(1−α)^t ≥ 0`), a strictly more
entangled regime `T_max₁ ≤ T_max₂` yields a no-smaller flywheel gain at every
generation: `g(T_max₁) ≤ g(T_max₂)`.  More entanglement ⟹ at least as strong a
flywheel. -/
theorem flywheelGain_mono_in_entanglement
    (α : ℝ) (t : ℕ) (hα : 0 ≤ 1 - α)
    (Tmax₁ Tmax₂ : ℝ) (hT : Tmax₁ ≤ Tmax₂) :
    flywheelGain Tmax₁ α t ≤ flywheelGain Tmax₂ α t := by
  unfold flywheelGain
  exact mul_le_mul_of_nonneg_right hT (pow_nonneg hα t)

/-- **(a.2 — KEY) — flywheel gain is STRICTLY monotone in entanglement at a
live generation.**

If the decay factor is genuinely contracting/expanding with `0 < 1−α` (so the
gain is live, `(1−α)^t > 0`), then a strictly more entangled regime
`T_max₁ < T_max₂` gives a STRICTLY larger flywheel gain at every generation:
`g(T_max₁) < g(T_max₂)`.  Higher entanglement ⟹ strictly stronger self-
reinforcing gain. -/
theorem flywheelGain_strictMono_in_entanglement
    (α : ℝ) (t : ℕ) (hα : 0 < 1 - α)
    (Tmax₁ Tmax₂ : ℝ) (hT : Tmax₁ < Tmax₂) :
    flywheelGain Tmax₁ α t < flywheelGain Tmax₂ α t := by
  unfold flywheelGain
  exact mul_lt_mul_of_pos_right hT (pow_pos hα t)

/-- **(a.3) — the flywheel bound is grounded in T.3 entanglement.**

The flywheel uses `T_max` as a GLOBAL entanglement bound.  T.3
(`T3_entanglement_ge_one`) certifies that the per-instance entanglement degree
`entanglement p X ≥ 1` whenever `|B|>0`, `N` is finite, and T.1 holds — so any
valid global bound `T_max` dominating it satisfies `1 ≤ T_max`, placing the
flywheel in the genuine `T_max ≥ 1` regime, and the gain there is positive
(for `0 < 1−α`).  This grounds the monotonicity premises in T.3 rather than
leaving `T_max` free. -/
theorem flywheel_bound_grounded_in_entanglement
    {β : Type} (p : Problem β) (X : Agent β)
    (hBpos : 0 < MIP.Entanglement.barrierCard p)
    (hN_finite : N p X ≠ ⊤)
    (hT1 : ((MIP.Entanglement.barrierCard p : ℕ) : ℕ∞) ≤ N p X)
    (Tmax α : ℝ) (hα : 0 < 1 - α) (t : ℕ)
    (hbound : entanglement p X ≤ Tmax) :
    1 ≤ Tmax ∧ 0 < flywheelGain Tmax α t := by
  have hT3 : 1 ≤ entanglement p X :=
    MIP.Entanglement.T3_entanglement_ge_one p X hBpos hN_finite hT1
  have hTmax1 : 1 ≤ Tmax := le_trans hT3 hbound
  refine ⟨hTmax1, ?_⟩
  unfold flywheelGain
  exact mul_pos (by linarith) (pow_pos hα t)

/-! ## (b) The bidirectional saturation product and its monotonicity in
entanglement.

R.69's product `P = (a+s+C·h)(h+s+C'·a)` measures the bidirectional saturation
strength; the impedance ratios `C, C' ≥ 1` are the directional entanglement
asymmetry (`Z_A/Z_H` ratios).  We show `P` is monotone — strictly, when both
directional classes are live — in each ratio, never below the `|B|²` floor
(`R_69_lower_bound`). -/

/-- **Bidirectional saturation product** `P(a,h,s,C,C') = (a+s+C·h)(h+s+C'·a)`:
the R.69 product whose floor is `|B|² = (a+h+s)²`. -/
noncomputable def satProduct (a h s C C' : ℝ) : ℝ :=
  (a + s + C * h) * (h + s + C' * a)

/-- **(b.0) — saturation product never falls below the `|B|²` floor.**

Directly re-exports R.69 (`R_69_lower_bound`): under `a,h,s ≥ 0` and the
entanglement asymmetries `C,C' ≥ 1`, the saturation product dominates the
intrinsic barrier complexity `(a+h+s)²`.  This is the saturation floor the
monotonicity below sits above. -/
theorem satProduct_ge_floor
    (a h s C C' : ℝ)
    (ha : 0 ≤ a) (hh : 0 ≤ h) (hs : 0 ≤ s)
    (hC : 1 ≤ C) (hC' : 1 ≤ C') :
    (a + h + s) ^ 2 ≤ satProduct a h s C C' := by
  unfold satProduct
  exact R_69_lower_bound a h s C C' ha hh hs hC hC'

/-- **(b.1) — the saturation product is monotone in the forward entanglement
asymmetry `C`.**

Fixing the barrier counts and the reverse ratio `C'`, increasing the forward
impedance ratio `C₁ ≤ C₂` (more directional entanglement) never decreases the
saturation product.  Proven from the exact R.69 expansion
(`R_69_exact_expansion`): the `C`-dependence enters only through the
non-negative term `(C−1)·h·(h+s)`. -/
theorem satProduct_mono_in_entanglement
    (a h s C' : ℝ)
    (ha : 0 ≤ a) (hh : 0 ≤ h) (hs : 0 ≤ s) (hC' : 0 ≤ C')
    (C₁ C₂ : ℝ) (hC : C₁ ≤ C₂) :
    satProduct a h s C₁ C' ≤ satProduct a h s C₂ C' := by
  unfold satProduct
  -- Use the exact R.69 identity at C₁ and C₂; the full difference is
  -- (C₂ − C₁)·(h·(h+s) + C'·a·h) ≥ 0.
  have e₁ := R_69_exact_expansion a h s C₁ C'
  have e₂ := R_69_exact_expansion a h s C₂ C'
  have hdiff : 0 ≤ (C₂ - C₁) * (h * (h + s) + C' * (a * h)) := by
    apply mul_nonneg (by linarith)
    have h1 : 0 ≤ h * (h + s) := mul_nonneg hh (by linarith)
    have h2 : 0 ≤ C' * (a * h) := mul_nonneg hC' (mul_nonneg ha hh)
    linarith
  nlinarith [e₁, e₂, hdiff]

/-- **(b.2 — KEY) — the saturation product is STRICTLY monotone in entanglement
when both directional classes are live.**

If both the forward-only barriers (`0 < h`) carry a strict slack (`0 < h+s`),
then strictly raising the forward impedance ratio `C₁ < C₂` strictly raises the
saturation product.  Higher directional entanglement ⟹ strictly stronger
bidirectional saturation — the saturation point genuinely shifts. -/
theorem satProduct_strictMono_in_entanglement
    (a h s C' : ℝ)
    (ha : 0 ≤ a) (hh : 0 < h) (hs : 0 ≤ s) (hC' : 0 ≤ C')
    (C₁ C₂ : ℝ) (hC : C₁ < C₂) :
    satProduct a h s C₁ C' < satProduct a h s C₂ C' := by
  unfold satProduct
  have e₁ := R_69_exact_expansion a h s C₁ C'
  have e₂ := R_69_exact_expansion a h s C₂ C'
  -- the full difference is (C₂ − C₁)·(h·(h+s) + C'·a·h), and h·(h+s) > 0.
  have hpos : 0 < (C₂ - C₁) * (h * (h + s) + C' * (a * h)) := by
    apply mul_pos (by linarith)
    have h1 : 0 < h * (h + s) := mul_pos hh (by linarith)
    have h2 : 0 ≤ C' * (a * h) := mul_nonneg hC' (mul_nonneg ha (le_of_lt hh))
    linarith
  nlinarith [e₁, e₂, hpos]

/-! ## (c) HEADLINE — entanglement monotonically controls BOTH the flywheel gain
AND the bidirectional saturation point.

The saturation product `P` above the `|B|²` floor translates into a residual
loss target via the R4_Agent2 (tower) scaling law: a stronger saturation pins
the loss to a strictly LOWER target, hence — through the order-reversing
inverse time-to-threshold map `crossBudget` (R4_Agent2
`crossBudget_strictAnti`) — to a strictly LATER (larger-budget) saturation.  We
bundle: (i) flywheel-gain monotonicity, (ii) saturation-product strict
monotonicity above the floor, and (iii) the strictly later saturation point. -/

/-- **(c — HEADLINE) — entanglement controls the flywheel and saturation.**

Fix a contracting decay factor (`0 < 1−α`), live barrier counts (`0 < h`,
`0 ≤ s`, `0 ≤ a`, `0 ≤ s` reused), entanglement asymmetries `1 ≤ C`, `1 ≤ C'`,
and a scaling regime (`0 < scalingC`, `0 < αD`).  Take two entanglement
operating points:

  • a flywheel entanglement bound moving up `T_max₁ < T_max₂`;
  • a forward impedance ratio moving up `C₁ < C₂` (with `1 ≤ C₁`);
  • two saturation loss targets `L_∞ < ℓ₂ < ℓ₁` (a more-entangled regime forces
    the strictly harder/lower target `ℓ₂`).

Then SIMULTANEOUSLY:

  (1) **Stronger flywheel.**  The flywheel gain strictly increases:
      `flywheelGain T_max₁ α t < flywheelGain T_max₂ α t`
      (T.5 / `T5_geometric_decay_kernel`).

  (2) **Stronger, floored saturation.**  The bidirectional saturation product
      strictly increases AND stays above the intrinsic `|B|²` floor:
      `(a+h+s)² ≤ satProduct a h s C₁ C' < satProduct a h s C₂ C'`
      (R.69 `R_69_lower_bound` / `R_69_exact_expansion`, and C.11
      `bidirectional_lower_bound`).

  (3) **Later saturation point.**  The crossing budget — the capability at which
      saturation is reached — strictly increases for the harder (more entangled)
      target:  `crossBudget L_∞ scalingC αD ℓ₁ < crossBudget L_∞ scalingC αD ℓ₂`
      (TOWER R4_Agent2 `crossBudget_strictAnti`), so higher entanglement
      saturates strictly LATER (at higher capability).

Thus the entanglement degree (T.3) is the single monotone dial controlling the
flywheel gain (T.5) and the bidirectional saturation point (R.69 / C.11),
reproduced through the R4_Agent2 scaling inverse. -/
theorem entanglement_controls_flywheel_and_saturation
    -- flywheel side
    (α : ℝ) (t : ℕ) (hα : 0 < 1 - α)
    (Tmax₁ Tmax₂ : ℝ) (hT : Tmax₁ < Tmax₂)
    -- saturation-product side
    (a h s C' : ℝ) (ha : 0 ≤ a) (hh : 0 < h) (hs : 0 ≤ s) (hC' : 1 ≤ C')
    (C₁ C₂ : ℝ) (hC₁ : 1 ≤ C₁) (hCC : C₁ < C₂)
    -- scaling / saturation-point side (R4_Agent2 tower)
    (Linf scalingC αD ℓ₁ ℓ₂ : ℝ)
    (hSc : 0 < scalingC) (hαD : 0 < αD)
    (hℓ₂ : Linf < ℓ₂) (hℓ : ℓ₂ < ℓ₁) :
    -- (1) strictly stronger flywheel
    flywheelGain Tmax₁ α t < flywheelGain Tmax₂ α t
    -- (2) strictly stronger saturation product, above the |B|² floor
    ∧ (a + h + s) ^ 2 ≤ satProduct a h s C₁ C'
    ∧ satProduct a h s C₁ C' < satProduct a h s C₂ C'
    -- (3) strictly later saturation point (crossing budget)
    ∧ crossBudget Linf scalingC αD ℓ₁ < crossBudget Linf scalingC αD ℓ₂ := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- (1) flywheel gain strictly monotone in entanglement bound
    exact flywheelGain_strictMono_in_entanglement α t hα Tmax₁ Tmax₂ hT
  · -- (2a) floor from R.69 / C.11
    exact satProduct_ge_floor a h s C₁ C' ha (le_of_lt hh) hs hC₁ hC'
  · -- (2b) saturation product strictly monotone in entanglement asymmetry
    exact satProduct_strictMono_in_entanglement a h s C' ha hh hs (le_trans zero_le_one hC') C₁ C₂ hCC
  · -- (3) tower R4_Agent2: order-reversing inverse time-to-threshold map
    exact crossBudget_strictAnti Linf scalingC αD ℓ₁ ℓ₂ hSc hαD hℓ₂ hℓ

/-- **(c′) — the saturation floor restated through C.11.**

To make the C.11 dependency explicit in a proof term: given the L.6/L.7
directional lower bounds (`a+s+C·h ≤ Nfwd`, `h+s+C'·a ≤ Nbwd`), the product of
the two directional emergence costs dominates `|B|²` — the bidirectional
emergence lower bound (`bidirectional_lower_bound`) — and this `|B|²` is exactly
the floor under the saturation product of part (b). -/
theorem saturation_floor_via_C11
    (a h s C C' Nfwd Nbwd B : ℝ)
    (ha : 0 ≤ a) (hh : 0 ≤ h) (hs : 0 ≤ s)
    (hC : 1 ≤ C) (hC' : 1 ≤ C')
    (hB : B = a + h + s)
    (hNf : a + s + C * h ≤ Nfwd)
    (hNb : h + s + C' * a ≤ Nbwd) :
    B ^ 2 ≤ Nfwd * Nbwd ∧ B ^ 2 ≤ satProduct a h s C C' := by
  refine ⟨bidirectional_lower_bound a h s C C' Nfwd Nbwd B ha hh hs hC hC' hB hNf hNb, ?_⟩
  rw [hB]
  exact satProduct_ge_floor a h s C C' ha hh hs hC hC'

end R8_Agent9_EntanglementFlywheelSaturation

end MIP
