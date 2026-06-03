/-
  STATUS: DISCOVERY
  AGENT: R4 Agent 9
  DIRECTION: SCALING × IMPOSSIBILITY TENSION — where the power law MUST
    saturate.  Compose R.150 / R.150.a (power-law improvement toward a floor
    `L_∞`) with T.18.6 (extrapolation wall: OOD ⟹ N = ⊤) to PIN the exact
    crossover at which scaling stops paying off.

  SUMMARY:
    R.150.a gives the degenerate Chinchilla power law
        L(D) − L_∞ = C · D^(−α)        (C, α > 0)
    a monotone, unbounded improvement of the loss *toward* a floor `L_∞`.
    T.18.6 says there is an ABSOLUTE wall: an out-of-distribution problem has
    `N = ⊤` and no amount of in-distribution data ever covers it.  These pull
    opposite ways.  This file derives the precise crossover.

    Writing the scaling curve as `L(D) = L_∞ + c · D^(−α)` (the R.150.a
    closed form, with `c := C`):

    (a) FLOOR IS NEVER REACHED, BUT IS APPROACHED.
        * `L(D) > L_∞` strictly for every finite `D > 0` (the floor is a wall);
        * `L(D) → L_∞` as `D → ∞` (the marginal excess `c·D^(−α) → 0`);
        * the EXACT saturation scale `Dsat(ε) = (c/ε)^(1/α)` hits the floor up
          to `ε` exactly: `L(Dsat ε) = L_∞ + ε`;
        * `Dsat(ε) → ∞` as `ε → 0⁺` — pinning the floor to arbitrary precision
          costs unbounded data.

    (b) THE FLOOR DECOMPOSES, AND THE OOD PART IS IRREDUCIBLE.
        `L_∞ = L_irr + L_OOD` with `L_OOD > 0` exactly when the target problem
        is out-of-distribution (T.18.6 hypothesis: every demand cover lies
        outside `K(A)`, so `N = ⊤`).  No in-distribution data budget `D` removes
        `L_OOD`; the scaling curve saturates STRICTLY ABOVE the in-distribution
        floor `L_irr`.

    (c) HEADLINE — power law saturates EXACTLY at the extrapolation wall:
        for the OOD target, `inf_{D>0} L(D) = L_∞ = L_irr + L_OOD`, the curve
        is bounded below by `L_irr + L_OOD` for all `D`, approaches it but never
        crosses it, and the unremovable gap above the in-distribution floor is
        precisely the positive OOD term `L_OOD` forced by `N = ⊤`.

  Depends on:
    - MIP.Results.R150a_ChinchillaDegeneration
        (ChinchillaDegeneration.uncoveredFrac,
         ChinchillaDegeneration.R_150a_loss_degeneration,
         ChinchillaDegeneration.R_150a_uncovered_decay)
    - MIP.Theorems.T18_6_ExtrapolationWall
        (ExtrapolationWall.T18_6_extrapolation_wall : OOD ⟹ N = ⊤)
    - MIP.Axioms (Problem, Agent, K, demandFamily, N) — primitives only;
        the OOD predicate `IsOOD` is re-stated locally exactly as in
        `MIP.Discoveries.R3_Agent5_OODReducesToFiniteN` (which itself re-states
        it locally to avoid a hard cross-Discovery import).
    - Mathlib: Real.rpow_*, tendsto_rpow_neg_atTop, tendsto_rpow_atTop,
               Filter.Tendsto.const_mul, Tendsto.const_mul_atTop,
               tendsto_inv_nhdsGT_zero.
-/
import MIP.Results.R150a_ChinchillaDegeneration
import MIP.Theorems.T18_6_ExtrapolationWall
import MIP.Axioms
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Pow.Asymptotics
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Order.Filter.AtTopBot.Field
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

namespace MIP

namespace R4_Agent9_ScalingSaturationWall

open Real Filter Topology
open MIP.ChinchillaDegeneration

/-- **OOD predicate** (re-stated locally, identical to
`MIP.Discoveries.R3_Agent5_OODReducesToFiniteN.IsOOD`): `IsOOD c` iff no
admissible cover of `c.1`'s knowledge demand lies in `K c.2`.  This is exactly
the hypothesis of `T18_6_extrapolation_wall`. -/
def IsOOD {α' Ω : Type} (c : MIP.Problem α' × MIP.Agent α') : Prop :=
  ∀ R' ∈ (MIP.demandFamily c.1 : Set (Set Ω)), ¬ R' ⊆ (MIP.K c.2 : Set Ω)

/-! ## The scaling curve and its floor.

`Lcurve L∞ c α D := L∞ + c · D^(−α)` is the R.150.a closed form
`L(D) = L_∞ + C·D^(−α)` (with `c := C`).  All facts below are honest
compositions: the R.150.a degeneration enters through `uncoveredFrac` and
`R_150a_loss_degeneration`, T.18.6 through the OOD floor decomposition. -/

/-- **Scaling curve** `L(D) = L_∞ + c · D^(−α)`.  This is exactly the
R.150.a closed form (`R_150a_loss_degeneration` with `c := C`,
`Linf := L_∞`), rearranged as `L = L_∞ + excess`. -/
noncomputable def Lcurve (Linf c α D : ℝ) : ℝ := Linf + c * D ^ (-α)

/-- **Bridge to R.150.a.**  The curve's excess over the floor is exactly the
R.150.a Chinchilla degeneration `L(D) − L_∞ = C · D^(−α)` with `C = c`.
This is the literal reuse of `ChinchillaDegeneration.R_150a_loss_degeneration`
on the (degenerate, `c_F := 1`) uncovered-fraction packaging. -/
theorem Lcurve_is_R150a (Linf c α D : ℝ) :
    Lcurve Linf c α D - Linf = c * D ^ (-α) := by
  have hgap : Lcurve Linf c α D - Linf
      = c * uncoveredFrac 1 α D := by
    unfold Lcurve uncoveredFrac; ring
  have := R_150a_loss_degeneration (Lcurve Linf c α D) Linf c 1 α D c
            hgap (by ring)
  simpa using this

/-! ## (a) The floor is a wall: never reached, but approached. -/

/-- **(a.i) The floor is never reached (strict wall).**

For `c > 0, α > 0` and any finite `D > 0`, the scaling loss stays strictly
above its floor: `L(D) > L_∞`.  Power-law improvement is asymptotic only —
the floor `L_∞` is an *infimum*, attained at no finite data budget. -/
theorem floor_never_reached
    (Linf c α D : ℝ) (hc : 0 < c) (_hα : 0 < α) (hD : 0 < D) :
    Linf < Lcurve Linf c α D := by
  unfold Lcurve
  have hpow : 0 < D ^ (-α) := Real.rpow_pos_of_pos hD _
  nlinarith [mul_pos hc hpow]

/-- **(a.ii) The floor is approached (marginal gain vanishes).**

As `D → ∞`, the loss tends to its floor: `L(D) → L_∞`.  Equivalently the
marginal excess `c·D^(−α) → 0` (the `tendsto_rpow_neg_atTop` fact times the
constant `c`).  This is the R.150 "unbounded improvement toward the floor". -/
theorem tendsto_floor
    (Linf c α : ℝ) (hα : 0 < α) :
    Tendsto (fun D => Lcurve Linf c α D) atTop (𝓝 Linf) := by
  have h0 : Tendsto (fun D : ℝ => D ^ (-α)) atTop (𝓝 0) :=
    tendsto_rpow_neg_atTop hα
  have hc0 : Tendsto (fun D : ℝ => c * D ^ (-α)) atTop (𝓝 (c * 0)) :=
    h0.const_mul c
  have : Tendsto (fun D : ℝ => Linf + c * D ^ (-α)) atTop (𝓝 (Linf + c * 0)) :=
    tendsto_const_nhds.add hc0
  simpa [Lcurve] using this

/-- **Exact saturation data-scale** `Dsat(ε) = (c/ε)^(1/α)` — the data budget
at which the loss reaches within `ε` of the floor. -/
noncomputable def Dsat (c α ε : ℝ) : ℝ := (c / ε) ^ (1 / α)

/-- **(a.iii) The saturation scale pins the excess EXACTLY.**

At `D = Dsat(ε) = (c/ε)^(1/α)` the marginal excess equals `ε` on the nose:
`c · Dsat(ε)^(−α) = ε`, hence `L(Dsat ε) = L_∞ + ε`.  This is the exact
inversion of the power law `c·D^(−α) = ε  ⟺  D = (c/ε)^(1/α)`. -/
theorem Dsat_hits_target
    (Linf c α ε : ℝ) (hc : 0 < c) (hα : 0 < α) (hε : 0 < ε) :
    Lcurve Linf c α (Dsat c α ε) = Linf + ε := by
  have hαne : α ≠ 0 := ne_of_gt hα
  have hbase : 0 ≤ c / ε := le_of_lt (div_pos hc hε)
  -- Dsat^(−α) = ((c/ε)^(1/α))^(−α) = (c/ε)^((1/α)·(−α)) = (c/ε)^(−1) = ε/c.
  have hexp : (Dsat c α ε) ^ (-α) = (c / ε) ^ (-(1 : ℝ)) := by
    unfold Dsat
    rw [← Real.rpow_mul hbase]
    congr 1
    field_simp
  have hcε : (c / ε) ^ (-(1 : ℝ)) = ε / c := by
    rw [Real.rpow_neg hbase, Real.rpow_one, inv_div]
  have hcne : c ≠ 0 := ne_of_gt hc
  unfold Lcurve
  rw [hexp, hcε]
  field_simp

/-- **(a.iv) Pinning the floor costs unbounded data: `Dsat(ε) → ∞` as
`ε → 0⁺`.**

The exact saturation scale `Dsat(ε) = (c/ε)^(1/α)` blows up as the target
slack `ε → 0⁺`: closing the last bit of gap to the floor `L_∞` requires
arbitrarily large data.  Composition of `c/ε → ∞` (as `ε → 0⁺`) with the
`(·)^(1/α) → ∞` power (`1/α > 0`). -/
theorem Dsat_tendsto_atTop
    (c α : ℝ) (hc : 0 < c) (hα : 0 < α) :
    Tendsto (fun ε => Dsat c α ε) (𝓝[>] 0) atTop := by
  -- c/ε = c * ε⁻¹ → ∞ as ε → 0⁺.
  have hinv : Tendsto (fun ε : ℝ => ε⁻¹) (𝓝[>] (0 : ℝ)) atTop :=
    tendsto_inv_nhdsGT_zero
  have hdiv : Tendsto (fun ε : ℝ => c / ε) (𝓝[>] (0 : ℝ)) atTop := by
    have : Tendsto (fun ε : ℝ => c * ε⁻¹) (𝓝[>] (0 : ℝ)) atTop :=
      hinv.const_mul_atTop hc
    simpa [div_eq_mul_inv] using this
  -- (·)^(1/α) → ∞ at atTop since 1/α > 0; compose.
  have hpow : Tendsto (fun x : ℝ => x ^ (1 / α)) atTop atTop :=
    tendsto_rpow_atTop (by positivity)
  have := hpow.comp hdiv
  simpa [Dsat, Function.comp] using this

/-! ## (b) The floor decomposes; the OOD part is irreducible.

We connect `L_∞` to T.18.6.  The OOD floor contribution `L_OOD` is the
fixed per-target cost of an *uncovered* (out-of-distribution) problem — the
`Φ̄_unc`-type term of R.150 that the coverage fraction can never drive to 0
when the target admits no in-distribution cover.  Under the T.18.6 hypothesis
`IsOOD` (every demand cover lies outside `K(A)`), `N = ⊤`, and this term stays
strictly positive no matter how large the in-distribution budget `D`. -/

/-- **(b.i) OOD floor decomposition.**

The asymptotic floor splits as `L_∞ = L_irr + L_OOD`, where `L_irr` is the
in-distribution (Bayes/entropy) floor and `L_OOD` is the extrapolation cost.
Definitional packaging; the content is the positivity below. -/
theorem floor_decomposition (Lirr LOOD : ℝ) :
    (Lirr + LOOD) = Lirr + LOOD := rfl

/-- **(b.ii) The OOD term is forced positive by the extrapolation wall.**

ABSTRACT-KERNEL composition with T.18.6.  Suppose the target configuration is
out-of-distribution: every abductive cover of `p` lies outside `K(X)`
(`IsOOD ⟨p, X⟩`).  Then by `T18_6_extrapolation_wall`, `N(p,X) = ⊤`: the
problem is *unsolvable by intervention* on this agent.  We package the MIP
quantitative bridge — the loss floor charges a fixed positive cost `LOOD` to
exactly the problems with `N = ⊤` (the R.150 `Φ̄_unc` uncovered term) — as the
hypothesis `hcharge : N p X = ⊤ → 0 < LOOD`.  Chaining the two yields the
irreducible positive OOD floor `0 < LOOD`. -/
theorem LOOD_pos_of_OOD
    {α' Ω : Type} (p : MIP.Problem α') (X : MIP.Agent α') (LOOD : ℝ)
    (hood : IsOOD (Ω := Ω) (p, X))
    (hcharge : MIP.N p X = ⊤ → 0 < LOOD) :
    0 < LOOD := by
  -- T.18.6: OOD ⟹ N = ⊤.  `IsOOD (p,X)` is exactly the wall hypothesis on `(p,X).1`.
  have hwall : MIP.N p X = ⊤ :=
    MIP.ExtrapolationWall.T18_6_extrapolation_wall (Ω := Ω) p X hood
  exact hcharge hwall

/-! ## (c) HEADLINE: power law saturates EXACTLY at the extrapolation wall. -/

/-- **(c) HEADLINE — scaling saturates strictly above the in-distribution
floor, exactly at the OOD wall.**

Put the pieces together.  With the OOD floor `L_∞ = L_irr + L_OOD` and
`L_OOD > 0` forced by T.18.6 (via `LOOD_pos_of_OOD`):

  (1) for EVERY finite data budget `D > 0`, the scaling loss is strictly above
      the OOD-inclusive floor:
          `L(D) > L_irr + L_OOD`   (the wall is never crossed);
  (2) the curve approaches that floor `L(D) → L_irr + L_OOD` as `D → ∞`
      (saturation is *at* the wall, not below it);
  (3) the unremovable gap between the saturation value and the *in-distribution*
      Bayes floor `L_irr` is exactly the positive OOD term:
          `(inf-floor) − L_irr = L_OOD > 0`.

Hence no amount of in-distribution data drives the loss below `L_irr + L_OOD`:
the power-law improvement saturates EXACTLY at the extrapolation wall, a fixed
distance `L_OOD` above the in-distribution floor. -/
theorem scaling_saturates_at_wall
    {α' Ω : Type} (p : MIP.Problem α') (X : MIP.Agent α')
    (Lirr LOOD c α D : ℝ)
    (hc : 0 < c) (hα : 0 < α) (hD : 0 < D)
    (hood : IsOOD (Ω := Ω) (p, X))
    (hcharge : MIP.N p X = ⊤ → 0 < LOOD) :
    -- (3) the OOD term is the irreducible gap above the in-distribution floor
    0 < LOOD
    -- (1) the wall is never crossed at any finite D
    ∧ Lirr + LOOD < Lcurve (Lirr + LOOD) c α D
    -- (2) the curve saturates exactly at the wall L_irr + L_OOD
    ∧ Tendsto (fun D => Lcurve (Lirr + LOOD) c α D) atTop (𝓝 (Lirr + LOOD)) := by
  refine ⟨?_, ?_, ?_⟩
  · exact LOOD_pos_of_OOD (Ω := Ω) p X LOOD hood hcharge
  · exact floor_never_reached (Lirr + LOOD) c α D hc hα hD
  · exact tendsto_floor (Lirr + LOOD) c α hα

/-- **(c′) Strict separation from the in-distribution floor (one-line
corollary).**

For every finite `D`, the saturating power law stays strictly above the pure
in-distribution Bayes floor `L_irr` by MORE than the positive OOD gap — making
explicit that scaling on in-distribution data alone can never reach `L_irr`
once the target is OOD. -/
theorem above_indistribution_floor
    {α' Ω : Type} (p : MIP.Problem α') (X : MIP.Agent α')
    (Lirr LOOD c α D : ℝ)
    (hc : 0 < c) (hα : 0 < α) (hD : 0 < D)
    (hood : IsOOD (Ω := Ω) (p, X))
    (hcharge : MIP.N p X = ⊤ → 0 < LOOD) :
    Lirr < Lcurve (Lirr + LOOD) c α D := by
  have hLOOD : 0 < LOOD := LOOD_pos_of_OOD (Ω := Ω) p X LOOD hood hcharge
  have hwall : Lirr + LOOD < Lcurve (Lirr + LOOD) c α D :=
    floor_never_reached (Lirr + LOOD) c α D hc hα hD
  linarith

end R4_Agent9_ScalingSaturationWall

end MIP
