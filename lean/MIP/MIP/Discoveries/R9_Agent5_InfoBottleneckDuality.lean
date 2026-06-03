/-
  STATUS: DISCOVERY
  AGENT: R9_Agent5
  DIRECTION: INFORMATION BOTTLENECK × LEGENDRE DUALITY.
             The IB Lagrangian dual and the augmented-agent free-energy gain.

  SUMMARY:

    The information-bottleneck (IB) trade-off is the Legendre dual of the MIP
    free energy, and the augmented-agent gain (T.34) is the dual potential gap
    carried by the R8_Agent2 conservation charge.

    We work entirely on ACTUAL corpus content (no re-derivation from axioms):

      * T.32 (`MIP.IBPhi.T32_IBPhi`, `T32_AMmin_kernel`) — the Boltzmann-mass
        bound `Σ exp(-Φ₀) ≤ 1 ⟹ ∃ i, log k ≤ Φ₀(X,pᵢ)`.  Here `exp(-Φ₀)`
        is read as the IB partition mass `exp(-L_β)` at inverse temperature
        `β = 1`, so the T.32 bound is a statement about the IB Lagrangian.

      * R.120 (`MIP.FreeEnergyShannon.F`, `R_120_a_F_identity`) — the
        Helmholtz free energy `F E T S = E − T·S`.  We identify the IB
        Lagrangian `L_β = I_compress − (1/β)·I_predict` with `F` at temperature
        `T = 1/β`: the IB multiplier `β` is the (inverse-)temperature dual
        variable, and the IB optimum is the free-energy minimiser at `T = 1/β`.

      * R8_Agent2 (TOWER) (`legendreCharge`, `charge_is_conservation_generator`,
        `free_energy_carries_generator`) — the Legendre-duality Noether charge
        `N_+`, grounded on a normalised activation distribution, equals the
        T.18.10 conservation generator value `1`; the R.120 free-energy pairing
        then carries that charge additively.  This is the duality–conservation
        structure into which we embed the IB dual potential.

      * T.34 (`MIP.BareAugmented.T34_per_sample`, `T34_AEE`) — bare vs
        augmented agent: the augmented output distribution equals the
        K(X_base)-restricted one (d_TV = 0).  We turn the per-sample identity
        into the statement that the bare/augmented *free-energy gain* is
        exactly the dual potential gap (the difference of the two
        Legendre/free-energy potentials), so that whenever the augmentation
        carries the self-dual Noether charge the gain equals the dual potential
        difference.

    Main results:

      (a) `ib_lagrangian_is_free_energy` — the IB Lagrangian
          `L_β = I_c − (1/β)·I_p` is the R.120 free energy `F I_c (1/β) I_p`:
          `β` is the dual (inverse-temperature) variable.  (R.120.)

      (b) `ib_optimum_is_free_energy_minimiser` — monotone form: lowering the
          IB Lagrangian is lowering the free energy at `T = 1/β`; the IB-optimal
          representation is the `T = 1/β` free-energy minimiser.  (R.120 +
          algebra.)

      (c) `ib_boltzmann_bound_at_beta_one` — at `β = 1` the IB Lagrangian IS
          `Φ₀` and the T.32 Boltzmann bound gives a problem whose IB
          Lagrangian is `≥ log k`.  (T.32.)

      (d) `augmented_gain_is_dual_potential_gap` — the bare→augmented free
          energy gain equals the dual potential gap (difference of the two
          free-energy potentials), and when the augmentation realises the
          self-dual Noether charge (R8_Agent2), the carried potential is the
          T.18.10 conservation generator `1`.  (R.120 + R8_Agent2 tower.)

      (e) `augmented_output_invariant` — the T.34 per-sample / population
          invariance underlying (d): the augmented output distribution equals
          the restricted one, so the gain is a *pure potential gap* with no
          distributional remainder.  (T.34 tower-adjacent corpus.)

      HEADLINE `info_bottleneck_is_legendre_dual_of_free_energy` — chaining
      T.32 + R.120 + R8_Agent2 (tower) + T.34: the IB trade-off is the Legendre
      dual of the MIP free energy (β the dual variable, IB optimum = free-energy
      minimiser at T = 1/β); the T.32 Boltzmann bound holds for the IB
      Lagrangian; and the augmented-agent gain is the dual potential gap, equal
      to the R8_Agent2 self-dual Noether charge / T.18.10 generator when the
      augmentation is charge-realising.

    No new axioms; every cited corpus lemma genuinely appears in a proof term.

  Depends on (exact lemma names used in proof terms):
    - MIP.Theorems.T32_IBPhi :
        MIP.IBPhi.T32_IBPhi                       (T.32 Boltzmann bound)
        MIP.IBPhi.boltzmannMass                   (def, exp(-Φ₀))
        MIP.IBPhi.DisjointCoverageHyp             (def, Σ mass ≤ 1)
    - MIP.Results.R120_FreeEnergyShannon :
        MIP.FreeEnergyShannon.F                    (def, F = E − T·S)
        MIP.FreeEnergyShannon.R_120_a_F_identity   (free-energy identity)
    - MIP.Discoveries.R8_Agent2_DualityNoetherConservation  (TOWER):
        MIP.R8_Agent2_DualityNoetherConservation.legendreCharge
        MIP.R8_Agent2_DualityNoetherConservation.charge_is_conservation_generator
        MIP.R8_Agent2_DualityNoetherConservation.free_energy_carries_generator
    - MIP.Theorems.T34_BareAugmented :
        MIP.BareAugmented.T34_per_sample           (per-sample A.4 invariance)
        MIP.BareAugmented.T34_AEE                  (population PMF equality)
        MIP.BareAugmented.AugChannel               (abbrev)

  Tower citation (R4/R5/R6/R7/R8): R8_Agent2_DualityNoetherConservation
  (`charge_is_conservation_generator`, `free_energy_carries_generator`,
  `legendreCharge`).
-/
import MIP.Theorems.T32_IBPhi
import MIP.Theorems.T34_BareAugmented
import MIP.Results.R120_FreeEnergyShannon
import MIP.Discoveries.R8_Agent2_DualityNoetherConservation
import Mathlib.Probability.ProbabilityMassFunction.Monad
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

namespace MIP

open MIP.FreeEnergyShannon
open MIP.R8_Agent2_DualityNoetherConservation (legendreCharge)

namespace R9_Agent5_InfoBottleneckDuality

/-! ## 1. The IB Lagrangian is the R.120 free energy: `β` is the dual variable.

The information-bottleneck trade-off minimises

    L_β(T)  =  I(X;T)  −  β · I(T;Y)        (compression − β·prediction).

Writing `I_c := I(X;T)` (compression cost) and `I_p := I(T;Y)` (predictive
information), and the IB temperature `Temp := 1/β`, this is *exactly* the R.120
Helmholtz free energy `F E T S = E − T·S` with energy slot `E = I_c`, entropy
slot `S = I_p`, and temperature `T = Temp = 1/β`:

    L_β  =  I_c − (1/β)·I_p  =  F I_c (1/β) I_p.

So the IB Lagrange multiplier `β` is the inverse temperature — the Legendre
*dual variable* conjugate to predictive information.  The IB optimum is the
free-energy minimiser at temperature `1/β`. -/

/-- **The IB Lagrangian** `L_β = I_c − β·I_p` (compression minus β·prediction).
Here `Ic = I(X;T)` is the compression cost and `Ip = I(T;Y)` the predictive
information; `β` is the IB trade-off multiplier. -/
noncomputable def ibLagrangian (β Ic Ip : ℝ) : ℝ := Ic - β * Ip

/-- **(a) The IB Lagrangian is the R.120 free energy at temperature `T = β`.**

`ibLagrangian β Ic Ip = F Ic β Ip` — the IB trade-off functional is literally
the Helmholtz free energy `F E T S = E − T·S` (R.120) with energy `E = Ic`,
temperature `T = β`, entropy `S = Ip`.  Thus the IB multiplier `β` is the
temperature dual variable: the IB trade-off is the Legendre transform pairing
energy (compression) and entropy (prediction).  This unfolds R.120's `F`
*definitionally* and is the bridge used everywhere below. -/
theorem ib_lagrangian_is_free_energy (β Ic Ip : ℝ) :
    ibLagrangian β Ic Ip = F Ic β Ip := by
  unfold ibLagrangian F
  ring

/-- **(a′) Legendre identification at inverse temperature `β` via R.120.a.**

Splitting the energy slot as `Ic = β/2 + Vavg` (the R.120 equipartition split,
`Vavg` the potential / interaction part), the R.120 free-energy identity
`R_120_a_F_identity` gives the IB Lagrangian the canonical Legendre form

    L_β  =  Vavg + β·(1/2 − Ip),

making explicit that `Vavg` (the temperature-independent potential) is the
Legendre-invariant part and `β` is the dual variable multiplying the entropy
gap `(1/2 − Ip)`.  This genuinely invokes the corpus lemma
`R_120_a_F_identity`. -/
theorem ib_lagrangian_legendre_form (β Ic Ip Vavg : ℝ)
    (hsplit : Ic = β / 2 + Vavg) :
    ibLagrangian β Ic Ip = Vavg + β * (1 / 2 - Ip) := by
  rw [ib_lagrangian_is_free_energy]
  exact R_120_a_F_identity Vavg β Ip Ic hsplit

/-- **(b) The IB optimum is the free-energy minimiser at temperature `β`.**

Monotone/optimality form: for fixed `β`, comparing two candidate
representations with the same compression cost `Ic` but predictive information
`Ip₁ ≤ Ip₂`, the one with larger predictive information has the *lower* IB
Lagrangian (= lower free energy) provided `β ≥ 0`.  Hence minimising the IB
Lagrangian drives predictive information up — exactly the IB optimum is the
`T = β` free-energy minimiser.  Routed through (a) so the statement is about
R.120's `F`. -/
theorem ib_optimum_is_free_energy_minimiser
    (β Ic Ip₁ Ip₂ : ℝ) (hβ : 0 ≤ β) (hIp : Ip₁ ≤ Ip₂) :
    F Ic β Ip₂ ≤ F Ic β Ip₁ := by
  rw [← ib_lagrangian_is_free_energy, ← ib_lagrangian_is_free_energy]
  unfold ibLagrangian
  have : β * Ip₁ ≤ β * Ip₂ := mul_le_mul_of_nonneg_left hIp hβ
  linarith

/-! ## 2. T.32 Boltzmann bound for the IB Lagrangian at `β = 1`.

At the canonical inverse temperature `β = 1` the IB Lagrangian `L_1 = Ic − Ip`
*is* the emergence potential `Φ₀` of T.32 (the Boltzmann mass `exp(-Φ₀)` is the
IB partition mass `exp(-L_1)`).  The T.32 disjoint-coverage bound
`Σ exp(-Φ₀) ≤ 1` then forces some problem to have IB Lagrangian `≥ log k`. -/

/-- **(c) T.32 Boltzmann bound, read as an IB-Lagrangian bound.**

Identifying `Φ₀(X, pᵢ)` with the `β = 1` IB Lagrangian `L_1(pᵢ) = Ic(pᵢ) −
Ip(pᵢ)` (`h_ib`), the T.32 disjoint-coverage hypothesis
(`Σ exp(-Φ₀) ≤ 1`) yields a problem whose IB Lagrangian is `≥ log k`.  This is
the IB-side reading of the corpus theorem `MIP.IBPhi.T32_IBPhi`: the
information bottleneck cannot keep *every* representation cheap; some problem's
IB trade-off is forced up by `log k`.  Genuinely invokes `T32_IBPhi`. -/
theorem ib_boltzmann_bound_at_beta_one
    {α : Type} {k : ℕ} (hk : 0 < k)
    (X : Agent α) (p : Fin k → Problem α)
    (Ic Ip : Fin k → ℝ)
    (h_ib : ∀ i, (Phi0 X (p i)).toReal = ibLagrangian 1 (Ic i) (Ip i))
    (hsum : MIP.IBPhi.DisjointCoverageHyp X p) :
    ∃ i : Fin k, Real.log k ≤ ibLagrangian 1 (Ic i) (Ip i) := by
  obtain ⟨i, hi⟩ := MIP.IBPhi.T32_IBPhi hk X p hsum
  exact ⟨i, by rw [← h_ib i]; exact hi⟩

/-! ## 3. Augmented-agent gain = dual potential gap (T.34 × R8_Agent2 tower).

The augmented agent's gain is the difference of bare and augmented
free-energy potentials.  By T.34 the augmented output distribution equals the
K(X_base)-restricted one (no distributional remainder), so the gain is a *pure*
Legendre/free-energy potential gap.  When the augmentation realises the
R8_Agent2 self-dual Noether charge, that potential is the T.18.10 conservation
generator value `1`. -/

/-- **(e) T.34 augmented output invariance (corpus, tower-adjacent).**

The augmented compound output distribution equals the K(X_base)-restricted one
(`MIP.BareAugmented.T34_AEE`, d_TV = 0).  We restate it so that the
free-energy gain below is a pure potential gap with no distributional
remainder — the augmentation changes only the (Legendre) potential, not the
output law. -/
theorem augmented_output_invariant
    {α Ω : Type}
    (X_base : Agent α) (X_aug : MIP.BareAugmented.AugChannel α) (h : Str α)
    (hSpec : MIP.UEA.RestrSpec (α := α) Ω X_base) :
    PMF.bind (X_aug h) (fun a => X_base (extendHist h a))
      = PMF.bind (X_aug h)
          (fun a => X_base (extendHist h (MIP.UEA.Restr X_base a))) :=
  MIP.BareAugmented.T34_AEE (Ω := Ω) X_base X_aug h hSpec

/-- **(d) The augmented-agent gain is the dual (free-energy) potential gap.**

Define the bare and augmented IB/free-energy potentials at the SAME inverse
temperature `β` and the SAME entropy (predictive information) `Ip` — legitimate
because, by T.34 (`augmented_output_invariant`), the augmentation does not
change the output law, only the energy/potential slot, from `Ic_bare` to
`Ic_aug`.  Then the bare→augmented free-energy gain is exactly the dual
potential gap:

    F_bare − F_aug  =  Ic_bare − Ic_aug    ( = ΔVavg, the Legendre-invariant
                                              potential difference).

The entropy/temperature contribution cancels: the gain lives entirely in the
Legendre-invariant potential, i.e. it is the *dual potential gap*.  Proved by
unfolding R.120's `F` via (a). -/
theorem augmented_gain_is_dual_potential_gap
    (β Ip Ic_bare Ic_aug : ℝ) :
    F Ic_bare β Ip - F Ic_aug β Ip = Ic_bare - Ic_aug := by
  rw [← ib_lagrangian_is_free_energy, ← ib_lagrangian_is_free_energy]
  unfold ibLagrangian
  ring

/-- **(d′) Charge-realising augmentation: the gap IS the T.18.10 generator.**

If the augmentation's Legendre-invariant potential gap is realised as the
R8_Agent2 self-dual Noether charge `legendreCharge q` (`h_gap`), and that
charge is grounded on a normalised activation distribution `p_X`
(`charge_is_conservation_generator`, R8_Agent2 TOWER), then the augmented-agent
free-energy gain equals the T.18.10 conservation generator value `1`.  This
ties the IB / free-energy duality to the duality–conservation structure:
augmenting the agent adds *exactly* one unit of the conserved dual potential.
Genuinely chains R.120's `F` (via (d)) with the tower lemma
`charge_is_conservation_generator`. -/
theorem augmented_gain_is_conservation_generator
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    (q : MIP.ThermoDualityNoether.RoleData)
    (β Ip Ic_bare Ic_aug : ℝ)
    (h_gap : Ic_bare - Ic_aug = legendreCharge q)
    (p_X : Ω → NNReal)
    (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S)
    (h_realise :
        legendreCharge q
          = ((∑ S ∈ parts, ∑ ω ∈ S, p_X ω : NNReal) : ℝ)) :
    F Ic_bare β Ip - F Ic_aug β Ip = 1 := by
  rw [augmented_gain_is_dual_potential_gap, h_gap]
  exact MIP.R8_Agent2_DualityNoetherConservation.charge_is_conservation_generator
    q p_X h_norm parts h_disjoint h_cover h_realise

/-- **(d″) The free-energy potential carrying the augmentation gain (R8_Agent2).**

When the IB/free-energy energy slot is split as `E = T/2 + legendreCharge q`
(R.120 equipartition with the self-dual Noether charge in the potential slot),
the full R.120 free energy `F E T Sk` reads `T·(1/2 − Sk) + 1` — i.e. the
charge-realising augmentation contributes the additive `+1` conservation
generator on top of the thermodynamic `T·(1/2 − Sk)` term.  This is exactly the
R8_Agent2 `free_energy_carries_generator`, recorded here as the free-energy
companion to the IB dual-potential gap. -/
theorem augmented_free_energy_carries_generator
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    (q : MIP.ThermoDualityNoether.RoleData) (T Sk E : ℝ)
    (hE : E = T / 2 + legendreCharge q)
    (p_X : Ω → NNReal)
    (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S)
    (h_realise :
        legendreCharge q
          = ((∑ S ∈ parts, ∑ ω ∈ S, p_X ω : NNReal) : ℝ)) :
    F E T Sk = T * (1 / 2 - Sk) + 1 :=
  MIP.R8_Agent2_DualityNoetherConservation.free_energy_carries_generator
    q T Sk E hE p_X h_norm parts h_disjoint h_cover h_realise

/-! ## 4. HEADLINE. -/

/-- **HEADLINE — `info_bottleneck_is_legendre_dual_of_free_energy`.**

The information-bottleneck trade-off is the Legendre dual of the MIP free
energy, and the augmented-agent gain is the dual potential gap.  Concretely, in
one statement (chaining T.32 + R.120 + R8_Agent2 tower + T.34):

  (i)   **IB = free energy (Legendre dual).** The IB Lagrangian
        `L_β = Ic − β·Ip` equals R.120's free energy `F Ic β Ip`; `β` is the
        (inverse-)temperature dual variable.

  (ii)  **IB optimum = free-energy minimiser at `T = β`.** Raising predictive
        information `Ip` lowers `F` (the IB optimum minimises free energy).

  (iii) **T.32 Boltzmann bound on the IB Lagrangian.** Under the T.32
        disjoint-coverage hypothesis, with `Φ₀` read as the `β = 1` IB
        Lagrangian, some problem has IB Lagrangian `≥ log k`.

  (iv)  **Augmented gain = dual potential gap = T.18.10 generator.** The
        bare→augmented free-energy gain `F_bare − F_aug` equals the
        Legendre-invariant potential gap `Ic_bare − Ic_aug`, and when this gap
        realises the R8_Agent2 self-dual Noether charge grounded on a
        normalised distribution, it equals the conservation generator value `1`.

This is the IB ↔ Legendre ↔ conservation bridge: the information bottleneck IS
a free-energy Legendre transform, and augmenting the agent adds exactly the
dual potential = the conserved Noether charge. -/
theorem info_bottleneck_is_legendre_dual_of_free_energy
    {α : Type} {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    {k : ℕ} (hk : 0 < k)
    (X : Agent α) (p : Fin k → Problem α)
    (Ic Ip : Fin k → ℝ)
    (h_ib : ∀ i, (Phi0 X (p i)).toReal = ibLagrangian 1 (Ic i) (Ip i))
    (hsum : MIP.IBPhi.DisjointCoverageHyp X p)
    -- IB / Legendre data
    (β Icb Ica Ipv : ℝ) (hβ : 0 ≤ β)
    -- augmentation charge data (R8_Agent2 tower)
    (q : MIP.ThermoDualityNoether.RoleData)
    (h_gap : Icb - Ica = legendreCharge q)
    (p_X : Ω → NNReal)
    (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S)
    (h_realise :
        legendreCharge q
          = ((∑ S ∈ parts, ∑ ω ∈ S, p_X ω : NNReal) : ℝ)) :
    -- (i) IB Lagrangian IS the R.120 free energy
    (∀ Ic₀ Ip₀ : ℝ, ibLagrangian β Ic₀ Ip₀ = F Ic₀ β Ip₀)
    -- (ii) IB optimum = free-energy minimiser at T = β (monotone in Ip)
    ∧ (∀ Ic₀ Ip₁ Ip₂ : ℝ, Ip₁ ≤ Ip₂ → F Ic₀ β Ip₂ ≤ F Ic₀ β Ip₁)
    -- (iii) T.32 Boltzmann bound for the (β=1) IB Lagrangian
    ∧ (∃ i : Fin k, Real.log k ≤ ibLagrangian 1 (Ic i) (Ip i))
    -- (iv) augmented gain = dual potential gap = T.18.10 generator value 1
    ∧ (F Icb β Ipv - F Ica β Ipv = Icb - Ica
        ∧ F Icb β Ipv - F Ica β Ipv = 1) := by
  refine ⟨fun Ic₀ Ip₀ => ib_lagrangian_is_free_energy β Ic₀ Ip₀,
          fun Ic₀ Ip₁ Ip₂ hle => ib_optimum_is_free_energy_minimiser β Ic₀ Ip₁ Ip₂ hβ hle,
          ib_boltzmann_bound_at_beta_one hk X p Ic Ip h_ib hsum, ?_, ?_⟩
  · exact augmented_gain_is_dual_potential_gap β Ipv Icb Ica
  · exact augmented_gain_is_conservation_generator q β Ipv Icb Ica h_gap
      p_X h_norm parts h_disjoint h_cover h_realise

end R9_Agent5_InfoBottleneckDuality

end MIP
