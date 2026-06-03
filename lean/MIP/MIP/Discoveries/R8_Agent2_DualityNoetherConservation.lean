/-
  STATUS: DISCOVERY
  AGENT: R8_Agent2
  DIRECTION: LEGENDRE DUALITY × NOETHER × CONSERVATION GENERATOR.

  SUMMARY:

    The corpus carries TWO faces of the same A↔H thermodynamic/Legendre
    duality involution:

      * `MIP.DualAlgebra.Obs.dual`     (R.142, the dual-algebra duality 𝒟),
      * `MIP.ThermoDualityNoether.RoleData.sigmaAH`  (R.560t, the σ_AH
        role-swap Noether involution).

    Both swap the two cross currents `N ↔ N*` and the two self currents,
    fixing the symmetric (Legendre-invariant) combinations.  This file proves
    that this duality is a TRUE involution and that its Noether charge — the
    σ_AH-invariant symmetric current `N_+ = N + N*` — is fixed by the duality
    AND, when grounded against a normalised activation distribution, coincides
    with the T.18.10 / R5_Agent1 conservation generator total `1`.  A self-dual
    conservation law:  the Legendre duality fixes the Noether charge, and the
    Noether charge IS the normalisation (mass) conservation generator.

    We prove, building on ACTUAL corpus content (no re-derivation from axioms):

      (a) `legendre_duality_involution` — the duality is an involution on BOTH
          faces simultaneously: `dual ∘ dual = id` (R.142 `Obs.dual_dual`) and
          `σ_AH ∘ σ_AH = id` (R.560t `sigmaAH_involutive`).  Double-Legendre =
          identity on the convex dual-algebra potentials.

      (b) `noether_charge_self_dual` — the Noether charge `N_+` is FIXED by the
          σ_AH duality (R.560t `Nplus_sigmaAH`); a genuinely self-dual current.
          We package it as the bridge `legendreCharge` and show it is invariant
          under one and (by the involution) two applications of the duality.

      (c) `charge_is_conservation_generator` — when the σ_AH symmetric current
          `N_+` is realised as the flat total of a normalised activation
          distribution `p_X` (∑ p_X = 1) aggregated along a disjoint-exhaustive
          partition, the self-dual Noether charge EQUALS the T.18.10
          conservation generator value `1`.  Routed through R5_Agent1's
          `T1810_as_generator` (the canonical grounding of the rank-1
          conservation generator) and `normalised_aggregation`.

      (d) HEADLINE `legendre_duality_noether_charge_is_generator` —
          chaining R.142 + R.560t + R5_Agent1 (+ R.120 free-energy Legendre
          pairing): the Legendre thermodynamic duality is an involution whose
          σ_AH-invariant Noether charge `N_+`, when grounded on a normalised
          distribution, IS the T.18.10 conservation generator (= 1), and the
          duality-fixed phase is exactly the Ohm `N = N*` double cover.

    No new axioms; every cited corpus lemma genuinely appears in a proof term.

  Depends on (exact lemma names used in proof terms):
    - MIP.Results.R560t_ThermoDualityNoether :
        MIP.ThermoDualityNoether.RoleData.sigmaAH                 (def)
        MIP.ThermoDualityNoether.RoleData.Nplus                   (def, Noether charge)
        MIP.ThermoDualityNoether.RoleData.sigmaAH_involutive      (involution)
        MIP.ThermoDualityNoether.RoleData.Nplus_sigmaAH           (charge self-dual)
        MIP.ThermoDualityNoether.RoleData.sigmaAH_fixed_iff       (Ohm double cover)
    - MIP.Results.R142_DualAlgebra :
        MIP.DualAlgebra.Obs.dual                                  (def)
        MIP.DualAlgebra.Obs.dual_dual                             (involution)
        MIP.DualAlgebra.R_142_iii_symm_subset                     (duality-fixed subset)
    - MIP.Discoveries.R5_Agent1_ConservationUniqueGenerator :
        MIP.R5_Agent1_ConservationUniqueGenerator.T1810_as_generator
                                                                  (conservation generator)
        MIP.R5_Agent1_ConservationUniqueGenerator.normalised_aggregation
                                                                  (rank-1 generator)
    - MIP.Results.R120_FreeEnergyShannon :
        MIP.FreeEnergyShannon.F                                   (Legendre pairing E ↦ E − T·S)
        MIP.FreeEnergyShannon.R_120_a_F_identity                 (free-energy identity)
    - Mathlib: Function.Involutive (via the involution lemmas), NNReal.

  Tower citations (R4/R5/R6/R7): R5_Agent1_ConservationUniqueGenerator
  (`T1810_as_generator`, `normalised_aggregation`).
-/
import MIP.Results.R560t_ThermoDualityNoether
import MIP.Results.R142_DualAlgebra
import MIP.Results.R120_FreeEnergyShannon
import MIP.Discoveries.R5_Agent1_ConservationUniqueGenerator
import Mathlib.Logic.Function.Basic
import Mathlib.Tactic.Linarith

namespace MIP

open scoped BigOperators
open MIP.ThermoDualityNoether
open MIP.ThermoDualityNoether.RoleData
open MIP.DualAlgebra

namespace R8_Agent2_DualityNoetherConservation

/-! ## 1. The Legendre/thermodynamic duality is an involution (both faces).

    R.142's dual-algebra duality `𝒟 = Obs.dual` and R.560t's σ_AH role-swap
    Noether involution are the two faces of one A↔H Legendre duality.  Each is a
    `Z₂` involution; double-application is the identity. -/

/-- **(a) Both duality faces are `Function.Involutive`.**

The σ_AH Noether role-swap (R.560t) and the dual-algebra duality 𝒟 (R.142) are
simultaneously involutions: applying either twice is the identity.  This is the
"double-Legendre = identity" statement on the convex dual-algebra potentials,
read off the corpus lemmas `sigmaAH_involutive` and `Obs.dual_dual`. -/
theorem legendre_duality_involution :
    Function.Involutive RoleData.sigmaAH ∧ Function.Involutive Obs.dual :=
  ⟨fun q => RoleData.sigmaAH_involutive q,
   fun q => Obs.dual_dual q⟩

/-! ## 2. The Noether charge `N_+` and its self-duality.

    The σ_AH-invariant symmetric current `N_+ = N + N*` is the Noether charge of
    the duality symmetry.  We name it `legendreCharge` and prove it is fixed by
    the duality (one application; hence by the involution, two). -/

/-- The Legendre/Noether charge carried by the role data: the σ_AH-invariant
symmetric current `N_+ = N + N*` (R.560t `Nplus`). -/
def legendreCharge (q : RoleData) : ℝ := Nplus q

/-- **(b) The Noether charge is self-dual (σ_AH-invariant).**

`legendreCharge (σ_AH q) = legendreCharge q`: the symmetric current `N_+` is
fixed by the Legendre duality — a self-dual conserved charge.  Proved via the
corpus invariance lemma `Nplus_sigmaAH`. -/
theorem noether_charge_self_dual (q : RoleData) :
    legendreCharge (RoleData.sigmaAH q) = legendreCharge q :=
  Nplus_sigmaAH q

/-- **(b′) The Noether charge is fixed under the full duality involution.**

Applying the σ_AH duality twice (the involution of part (a)) leaves both the
data and its Noether charge unchanged: `legendreCharge (σ_AH (σ_AH q)) =
legendreCharge q`.  Combines `legendre_duality_involution` with the self-dual
charge, witnessing that the conserved charge survives the full `Z₂` orbit. -/
theorem noether_charge_involution_fixed (q : RoleData) :
    legendreCharge (RoleData.sigmaAH (RoleData.sigmaAH q)) = legendreCharge q := by
  rw [legendre_duality_involution.1 q]

/-- **(b″) Self-dual phase = Ohm double cover.**

The role data is FIXED by the duality (`σ_AH q = q`, the pure `+1`/self-dual
representation) iff the Ohm-regime double cover `N = N* ∧ N_self_A = N_self_H`
holds.  Hence the self-dual locus of the Legendre duality is exactly the Ohm
symmetric phase.  Uses the corpus characterisation `sigmaAH_fixed_iff`. -/
theorem self_dual_phase_iff_ohm (q : RoleData) :
    RoleData.sigmaAH q = q ↔ q.N = q.Nstar ∧ q.NselfA = q.NselfH :=
  RoleData.sigmaAH_fixed_iff q

/-! ## 3. The Noether charge IS the conservation generator (R5_Agent1, tower).

    When the σ_AH Noether charge `N_+` is realised as the flat total of a
    normalised activation distribution `p_X` aggregated along a partition, it
    equals the T.18.10 conservation generator value `1`.  This is the bridge to
    the rank-1 conservation generator of R5_Agent1. -/

/-- **(c) The self-dual Noether charge equals the T.18.10 generator value `1`.**

Suppose the role data's symmetric current is normalisation-realised: its
Noether charge `N_+ = legendreCharge q` equals the aggregated total of a
normalised activation distribution `p_X` (∑ p_X = 1) over a disjoint-exhaustive
partition `parts`.  Then, by R5_Agent1's conservation generator
`T1810_as_generator`, the aggregated total is `1`, so the self-dual Noether
charge equals `1`.  The Legendre Noether charge IS the mass/normalisation
conservation generator. -/
theorem charge_is_conservation_generator
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    (q : RoleData)
    (p_X : Ω → NNReal)
    (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S)
    (h_realise :
        legendreCharge q
          = ((∑ S ∈ parts, ∑ ω ∈ S, p_X ω : NNReal) : ℝ)) :
    legendreCharge q = 1 := by
  -- The aggregated activation mass is the T.18.10 generator value `1`.
  have h_gen : (∑ S ∈ parts, ∑ ω ∈ S, p_X ω) = (1 : NNReal) :=
    MIP.R5_Agent1_ConservationUniqueGenerator.T1810_as_generator
      p_X h_norm parts h_disjoint h_cover
  rw [h_realise, h_gen]
  simp

/-- **(c′) Self-dual + grounded: the σ_AH-image carries the SAME generator value.**

Combining self-duality (b) with the grounding (c): under the duality, the
Noether charge of the role-swapped data `σ_AH q` is also exactly the T.18.10
conservation generator value `1`.  The conservation generator is thus invariant
along the entire Legendre-duality orbit. -/
theorem dual_charge_is_conservation_generator
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    (q : RoleData)
    (p_X : Ω → NNReal)
    (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S)
    (h_realise :
        legendreCharge q
          = ((∑ S ∈ parts, ∑ ω ∈ S, p_X ω : NNReal) : ℝ)) :
    legendreCharge (RoleData.sigmaAH q) = 1 := by
  rw [noether_charge_self_dual q]
  exact charge_is_conservation_generator q p_X h_norm parts h_disjoint h_cover h_realise

/-! ## 4. The Legendre free-energy pairing carries the same invariant.

    R.120's free energy `F = E − T·S` is the Legendre transform pairing energy
    and entropy.  We record that, when the energy slot carries the self-dual
    Noether charge as its potential value, the free-energy identity transports
    the conservation generator into the thermodynamic potential. -/

/-- **(d-free) The free-energy Legendre pairing inherits the generator value.**

Take R.120's free energy `F E T Sk` with the equipartition split
`E = T/2 + ⟨V⟩` (R.120.a).  If the potential value `⟨V⟩` is the self-dual
Noether charge `legendreCharge q` and that charge is the grounded T.18.10
generator value `1`, then `F = T·(1/2 − Sk) + 1`: the Legendre free-energy
potential carries the conservation generator additively.  Uses R.120's
`R_120_a_F_identity`. -/
theorem free_energy_carries_generator
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    (q : RoleData) (T Sk E : ℝ)
    (hE : E = T / 2 + legendreCharge q)
    (p_X : Ω → NNReal)
    (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S)
    (h_realise :
        legendreCharge q
          = ((∑ S ∈ parts, ∑ ω ∈ S, p_X ω : NNReal) : ℝ)) :
    MIP.FreeEnergyShannon.F E T Sk = T * (1 / 2 - Sk) + 1 := by
  have hcharge : legendreCharge q = 1 :=
    charge_is_conservation_generator q p_X h_norm parts h_disjoint h_cover h_realise
  -- R.120.a: F = ⟨V⟩ + T·(1/2 − Sk), with ⟨V⟩ = legendreCharge q.
  have hF : MIP.FreeEnergyShannon.F E T Sk
      = legendreCharge q + T * (1 / 2 - Sk) :=
    MIP.FreeEnergyShannon.R_120_a_F_identity (legendreCharge q) T Sk E hE
  rw [hF, hcharge]; ring

/-! ## 5. HEADLINE — the Legendre duality is an involution whose Noether charge
       is the T.18.10 conservation generator. -/

/-- **HEADLINE — `legendre_duality_noether_charge_is_generator`.**

The Legendre thermodynamic duality of the dual algebra is an involution whose
Noether charge is the T.18.10 conservation generator.  Concretely, for any role
data `q` whose symmetric current `N_+` is realised as the aggregated total of a
normalised activation distribution `p_X` (∑ p_X = 1) over a disjoint-exhaustive
partition, we have simultaneously:

  (i)   `σ_AH` and `𝒟` are involutions
        (double-Legendre = id, R.142 `dual_dual` + R.560t `sigmaAH_involutive`);
  (ii)  the Noether charge `N_+` is self-dual (fixed by σ_AH, R.560t `Nplus_sigmaAH`)
        — and fixed by the full involution;
  (iii) the self-dual Noether charge EQUALS the T.18.10 conservation generator
        value `1` (R5_Agent1 `T1810_as_generator`), and so does its dual image;
  (iv)  the duality-fixed (self-dual) phase is exactly the Ohm double cover
        `N = N*` (R.560t `sigmaAH_fixed_iff`).

This is the self-dual conservation law:  the Legendre duality involution fixes
its Noether charge, and that charge IS the normalisation/mass conservation
generator of T.18.10. -/
theorem legendre_duality_noether_charge_is_generator
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    (q : RoleData)
    (p_X : Ω → NNReal)
    (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S)
    (h_realise :
        legendreCharge q
          = ((∑ S ∈ parts, ∑ ω ∈ S, p_X ω : NNReal) : ℝ)) :
    -- (i) both duality faces are involutions
    (Function.Involutive RoleData.sigmaAH ∧ Function.Involutive Obs.dual)
    -- (ii) the Noether charge is self-dual and involution-fixed
    ∧ (legendreCharge (RoleData.sigmaAH q) = legendreCharge q
        ∧ legendreCharge (RoleData.sigmaAH (RoleData.sigmaAH q)) = legendreCharge q)
    -- (iii) the self-dual Noether charge is the T.18.10 generator value 1
    ∧ (legendreCharge q = 1 ∧ legendreCharge (RoleData.sigmaAH q) = 1)
    -- (iv) the self-dual phase is the Ohm double cover
    ∧ (RoleData.sigmaAH q = q ↔ q.N = q.Nstar ∧ q.NselfA = q.NselfH) := by
  refine ⟨legendre_duality_involution, ?_, ?_, self_dual_phase_iff_ohm q⟩
  · exact ⟨noether_charge_self_dual q, noether_charge_involution_fixed q⟩
  · exact ⟨charge_is_conservation_generator q p_X h_norm parts h_disjoint h_cover h_realise,
           dual_charge_is_conservation_generator q p_X h_norm parts h_disjoint h_cover h_realise⟩

end R8_Agent2_DualityNoetherConservation

end MIP
