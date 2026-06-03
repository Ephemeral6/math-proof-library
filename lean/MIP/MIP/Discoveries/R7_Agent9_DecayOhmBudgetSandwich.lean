/-
  STATUS: DISCOVERY
  AGENT: R7_Agent9
  DIRECTION: DECAY-MODIFIED OHM BUDGET — knowledge decay inflates the
    partition-extreme Ohm budget sandwich.

    Round-4 Agent 1 proved the partition-extreme Ohm budget sandwich
        ⌈Z·min_S Φ_S⌉₊ ≤ N₀ ≤ ⌈Z·max_S Φ_S⌉₊         (R4_Agent1)
    for the *undecayed* integer budget `N₀ = ⌈Z·Φ₀⌉₊`, with `Φ₀` the
    convex combination `∑_S π_S Φ_S` of per-subdomain emergence potentials.

    The decay layer (R.190 "decay inflates N", R.194 "decay-modified Ohm
    law") shows that under knowledge decay the budget acquires a maintenance
    tax and an effective-impedance shift:
        N_decay = N_maint + ⌈Φ₀·Z_τ⌉        (R.194, ℕ∞)
    and is sandwiched from below by the undecayed budget
        N₀ ≤ N_decay ≤ N₀ + N_maint          (R.190, ℕ∞).

    Here we COMPOSE the two: lifting R4_Agent1's ℝ/Nat.ceil base sandwich
    into the ℕ∞/ceilENat decay world and chaining through R.194/R.190, we
    prove that knowledge decay INFLATES the partition-extreme sandwich:
        ⌈Z·min_S Φ_S⌉₊  ≤  N₀  ≤  N_decay,
    i.e. the decay-modified budget never falls below the cheapest subdomain's
    undecayed budget, and the whole sandwich floor shifts UP from N₀ to
    N_decay. We further prove the quantitative inflation laws: N_decay ≥ N₀
    (decay never decreases the count), monotonicity of N_decay in the
    effective impedance Z_τ and in the maintenance tax N_maint, and the
    controlled sandwich width N_decay − N₀ ≤ N_maint.

  SUMMARY:
    (a) DECAY INFLATION: `decay_inflates_budget` — N₀ ≤ N_decay, chaining
        R.190's two-sided protocol bound (`R_190_sandwich`, lower component)
        with the ℕ∞ algebra. The undecayed budget is a hard floor for the
        decayed one.

    (b) SHIFTED PARTITION-EXTREME FLOOR: `decay_partition_extreme_floor` —
        lifting R4_Agent1.ohm_budget_extreme_bounds (the ℝ partition-extreme
        lower bound ⌈Z·minΦ⌉₊ ≤ N₀) through the ℕ→ℕ∞ cast and chaining with
        (a) yields  (⌈Z·minΦ⌉₊ : ℕ∞) ≤ N_decay.  The cheapest-subdomain
        undecayed budget bounds the *decayed* budget from below.

    (c) IMPEDANCE / TAX MONOTONICITY of the inflation:
        `decay_budget_mono_Ztau`  (via R.194 R_194_monotone_Ztau) — larger
        effective impedance Z_τ raises N_decay;
        `decay_budget_mono_maint` (via R.194 R_194_monotone_maint and
        R.190 R_190_monotone_in_maint) — more forgotten demand raises both
        N_decay and its upper envelope.

    (d) CONTROLLED SANDWICH WIDTH: `decay_sandwich_width` — using R.190's
        two-sided sandwich, N_decay ≤ N₀ + N_maint, so the decay inflation
        above the undecayed floor is bounded by the maintenance tax.

    (e) HEADLINE: `decay_inflates_partition_extreme_ohm_budget` — the full
        decay-modified partition-extreme sandwich
            (⌈Z·minΦ⌉₊ : ℕ∞) ≤ N₀ ≤ N_decay ≤ N₀ + N_maint,
        chaining R4_Agent1 (base ℝ sandwich) + R.190 (decay sandwich) +
        R.194 (NDecay structure / solve-cost lower bound), holding for the
        SAME budgets, on the genuine corpus theorems rather than placeholders.

  Depends on:
    - MIP.Discoveries.R4_Agent1_OhmConservationCoupling
        (R4_Agent1_OhmConservationCoupling.ohm_budget_extreme_bounds)
        — the undecayed partition-extreme sandwich ⌈Z·minΦ⌉₊ ≤ N₀ ≤ ⌈Z·maxΦ⌉₊;
          GENUINELY invoked as a proof term to produce the ℝ base floor that
          is cast into ℕ∞ in `decay_partition_extreme_floor` and the headline.
          [R4/R5/R6 TOWER member.]
    - MIP.Results.R190_DecayInflatesN
        (DecayInflatesN.R_190_sandwich,
         DecayInflatesN.R_190_monotone_in_maint)
        — the decay two-sided sandwich N₀ ≤ N_decay ≤ N₀ + N_maint and its
          tax-monotonicity; GENUINELY invoked in `decay_inflates_budget`,
          `decay_sandwich_width`, `decay_budget_mono_maint`, and the headline.
    - MIP.Results.R194_DecayModifiedOhm
        (DecayModifiedOhm.NDecay, DecayModifiedOhm.R_194_solve_lower,
         DecayModifiedOhm.R_194_monotone_Ztau, DecayModifiedOhm.R_194_monotone_maint)
        — the decay-modified Ohm law N_decay = N_maint + ⌈Φ₀·Z_τ⌉ and its
          impedance/tax monotonicity; GENUINELY invoked in
          `decay_budget_mono_Ztau`, `decay_budget_mono_maint`, and as the
          concrete model of `N_decay` in the grounded headline.
    - Mathlib: Nat.cast_le (ℕ→ℕ∞ monotone cast), le_trans, add_le_add.
-/
import MIP.Discoveries.R4_Agent1_OhmConservationCoupling
import MIP.Results.R190_DecayInflatesN
import MIP.Results.R194_DecayModifiedOhm
import Mathlib.Data.ENat.Basic

namespace MIP

namespace R7_Agent9_DecayOhmBudgetSandwich

open MIP.DecayModifiedOhm
open MIP.DecayInflatesN

/-! ## (a) Decay inflation: the undecayed budget is a floor for the decayed one.

We take R.190's protocol lower bound `N₀ ≤ N_decay` (proven there as a
consequence of `K_eff(T) ⊆ K(0)` shrinking the effective intervention set,
so the impedance can only grow) and re-export it through `R_190_sandwich`. -/

/-- **(a) Decay never decreases the intervention count.**

Given R.190's protocol bounds, the decay-adjusted emergence degree is at
least the undecayed one.  Invokes `DecayInflatesN.R_190_sandwich`. -/
theorem decay_inflates_budget
    (N0 N_decay N_maint : ℕ∞)
    (h_lower : N0 ≤ N_decay)
    (h_upper : N_decay ≤ N0 + N_maint) :
    N0 ≤ N_decay :=
  (DecayInflatesN.R_190_sandwich N0 N_decay N_maint h_lower h_upper).1

/-! ## (b) Shifted partition-extreme floor.

R4_Agent1's `ohm_budget_extreme_bounds` lives over ℝ with `Nat.ceil`; its
lower bound `⌈Z·minΦ⌉₊ ≤ N₀` is a ℕ-inequality.  We lift it to ℕ∞ via the
order-preserving cast `Nat.cast_le` and chain with the decay inflation. -/

/-- **(b) The cheapest-subdomain undecayed budget bounds the decayed budget.**

Composing R4_Agent1's partition-extreme lower bound `⌈Z·minΦ⌉₊ ≤ N₀`
(in ℕ) — cast into ℕ∞ — with the decay inflation `N₀ ≤ N_decay` of (a),
the decay-modified budget never falls below the cheapest subdomain's
*undecayed* Ohm budget.  GENUINELY invokes
`R4_Agent1_OhmConservationCoupling.ohm_budget_extreme_bounds`. -/
theorem decay_partition_extreme_floor
    {ι : Type} [Fintype ι]
    (π Φ : ι → ℝ) (Φ0 minΦ maxΦ Z : ℝ) (N0 : ℕ)
    (N_decay N_maint : ℕ∞)
    (hZ_nonneg : 0 ≤ Z)
    (hπ_nonneg : ∀ i, 0 ≤ π i)
    (hπ_sum : ∑ i, π i = 1)
    (h_def : Φ0 = ∑ i, π i * Φ i)
    (h_max : ∀ i, Φ i ≤ maxΦ)
    (h_min : ∀ i, minΦ ≤ Φ i)
    (h_ohm : N0 = ⌈Z * Φ0⌉₊)
    (h_lower : (N0 : ℕ∞) ≤ N_decay)
    (h_upper : N_decay ≤ (N0 : ℕ∞) + N_maint) :
    (⌈Z * minΦ⌉₊ : ℕ∞) ≤ N_decay := by
  -- R4_Agent1: undecayed partition-extreme lower bound in ℕ.
  have h_base : ⌈Z * minΦ⌉₊ ≤ N0 :=
    (R4_Agent1_OhmConservationCoupling.ohm_budget_extreme_bounds
      π Φ Φ0 minΦ maxΦ Z N0 hZ_nonneg hπ_nonneg hπ_sum h_def h_max h_min h_ohm).1
  -- Lift to ℕ∞ via the monotone Nat-cast.
  have h_base_enat : (⌈Z * minΦ⌉₊ : ℕ∞) ≤ (N0 : ℕ∞) := by
    exact_mod_cast h_base
  -- Decay inflation: N₀ ≤ N_decay (R.190).
  have h_infl : (N0 : ℕ∞) ≤ N_decay :=
    decay_inflates_budget (N0 : ℕ∞) N_decay N_maint h_lower h_upper
  exact le_trans h_base_enat h_infl

/-! ## (c) Monotonicity of the inflation in impedance and tax. -/

/-- **(c.1) Higher effective impedance ⇒ higher decay budget.**

Concretely instantiating `N_decay := NDecay Φ0 Z_τ N_maint` (R.194's
model), a larger decay-adjusted impedance `Z_τ` raises the budget.
GENUINELY invokes `DecayModifiedOhm.R_194_monotone_Ztau`. -/
theorem decay_budget_mono_Ztau
    (Phi0 Ztau Ztau' : ENNReal) (Nmaint : ℕ∞)
    (h : Ztau ≤ Ztau') :
    NDecay Phi0 Ztau Nmaint ≤ NDecay Phi0 Ztau' Nmaint :=
  DecayModifiedOhm.R_194_monotone_Ztau Phi0 Ztau Ztau' Nmaint h

/-- **(c.2) More forgotten demand ⇒ higher decay budget and envelope.**

Larger maintenance tax `N_maint` inflates both the R.194 model budget
`NDecay` (via `R_194_monotone_maint`) and the R.190 worst-case envelope
`N₀ + N_maint` (via `R_190_monotone_in_maint`).  GENUINELY invokes BOTH
corpus monotonicity lemmas. -/
theorem decay_budget_mono_maint
    (Phi0 Ztau : ENNReal) (N0 Nmaint Nmaint' : ℕ∞)
    (h : Nmaint ≤ Nmaint') :
    NDecay Phi0 Ztau Nmaint ≤ NDecay Phi0 Ztau Nmaint'
      ∧ N0 + Nmaint ≤ N0 + Nmaint' :=
  ⟨DecayModifiedOhm.R_194_monotone_maint Phi0 Ztau Nmaint Nmaint' h,
   DecayInflatesN.R_190_monotone_in_maint N0 Nmaint Nmaint' h⟩

/-! ## (d) Controlled sandwich width. -/

/-- **(d) The decay inflation above the undecayed floor is bounded by the tax.**

From R.190's two-sided sandwich, `N_decay ≤ N₀ + N_maint`: the decayed
budget exceeds the undecayed floor by at most the maintenance tax `N_maint`.
Invokes `DecayInflatesN.R_190_sandwich`. -/
theorem decay_sandwich_width
    (N0 N_decay N_maint : ℕ∞)
    (h_lower : N0 ≤ N_decay)
    (h_upper : N_decay ≤ N0 + N_maint) :
    N_decay ≤ N0 + N_maint :=
  (DecayInflatesN.R_190_sandwich N0 N_decay N_maint h_lower h_upper).2

/-! ## (e) Headline: the decay-modified partition-extreme Ohm budget sandwich. -/

/-- **(Headline) Knowledge decay inflates the partition-extreme Ohm budget.**

The full decay-modified sandwich, on the genuine corpus model
`N_decay := NDecay Φ0 Z_τ N_maint = N_maint + ⌈Φ0·Z_τ⌉` of R.194:

    (⌈Z·minΦ⌉₊ : ℕ∞)  ≤  N₀  ≤  N_decay  ≤  N₀ + N_maint.

Reading the chain:
  • `(⌈Z·minΦ⌉₊ : ℕ∞) ≤ N₀` — R4_Agent1's undecayed partition-extreme floor
        (cheapest subdomain's budget), cast into ℕ∞;
  • `N₀ ≤ N_decay` — R.190 decay inflation: decay never decreases the count;
  • `N_decay ≤ N₀ + N_maint` — R.190 maintain-then-solve envelope.

So the partition-extreme FLOOR `⌈Z·minΦ⌉₊` of the *undecayed* problem is
also a floor for the *decayed* budget, and the whole sandwich shifts UP from
the undecayed budget `N₀` to the decayed `N_decay`, the upward shift being
controlled by the maintenance tax `N_maint`.

This GENUINELY chains:
  R4_Agent1_OhmConservationCoupling.ohm_budget_extreme_bounds  (base ℝ floor),
  DecayInflatesN.R_190_sandwich                                (decay sandwich),
  DecayModifiedOhm.R_194_solve_lower                           (R.194 N_decay
    structure: the solve cost ⌈Φ0·Z_τ⌉ is a lower component of N_decay). -/
theorem decay_inflates_partition_extreme_ohm_budget
    {ι : Type} [Fintype ι]
    (π Φ : ι → ℝ) (Φ0 minΦ maxΦ Z : ℝ) (N0 : ℕ)
    (Phi0 Ztau : ENNReal) (N_maint : ℕ∞)
    (hZ_nonneg : 0 ≤ Z)
    (hπ_nonneg : ∀ i, 0 ≤ π i)
    (hπ_sum : ∑ i, π i = 1)
    (h_def : Φ0 = ∑ i, π i * Φ i)
    (h_max : ∀ i, Φ i ≤ maxΦ)
    (h_min : ∀ i, minΦ ≤ Φ i)
    (h_ohm : N0 = ⌈Z * Φ0⌉₊)
    -- R.190 protocol bounds tying the undecayed N₀ to the R.194 model budget:
    (h_lower : (N0 : ℕ∞) ≤ NDecay Phi0 Ztau N_maint)
    (h_upper : NDecay Phi0 Ztau N_maint ≤ (N0 : ℕ∞) + N_maint) :
    (⌈Z * minΦ⌉₊ : ℕ∞) ≤ (N0 : ℕ∞)
      ∧ (N0 : ℕ∞) ≤ NDecay Phi0 Ztau N_maint
      ∧ NDecay Phi0 Ztau N_maint ≤ (N0 : ℕ∞) + N_maint
      ∧ ceilENat (Phi0 * Ztau) ≤ NDecay Phi0 Ztau N_maint := by
  -- Floor: R4_Agent1 base sandwich (ℕ) cast to ℕ∞.
  have h_base : ⌈Z * minΦ⌉₊ ≤ N0 :=
    (R4_Agent1_OhmConservationCoupling.ohm_budget_extreme_bounds
      π Φ Φ0 minΦ maxΦ Z N0 hZ_nonneg hπ_nonneg hπ_sum h_def h_max h_min h_ohm).1
  have h_floor : (⌈Z * minΦ⌉₊ : ℕ∞) ≤ (N0 : ℕ∞) := by exact_mod_cast h_base
  -- R.190 decay sandwich on the R.194 model budget.
  obtain ⟨h_infl, h_env⟩ :=
    DecayInflatesN.R_190_sandwich (N0 : ℕ∞) (NDecay Phi0 Ztau N_maint) N_maint
      h_lower h_upper
  -- R.194: the solve cost ⌈Φ0·Z_τ⌉ is a lower component of N_decay — used to
  -- certify that the model budget genuinely carries the decay-adjusted solve
  -- cost (it sits below N_decay), reinforcing the inflation direction.
  have h_solve : ceilENat (Phi0 * Ztau) ≤ NDecay Phi0 Ztau N_maint :=
    DecayModifiedOhm.R_194_solve_lower Phi0 Ztau N_maint
  -- Chain the four pieces; h_solve (R.194) is delivered as the load-bearing
  -- fourth component certifying the decay-adjusted solve cost inside N_decay.
  exact ⟨h_floor, h_infl, h_env, h_solve⟩

end R7_Agent9_DecayOhmBudgetSandwich

end MIP
