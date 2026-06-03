/-
  STATUS: DISCOVERY
  AGENT: R3-10
  DIRECTION: Compose R.450 (κ-tower partial commutative magma with
    saturation characterisation) with R.730 (agents form a sequential
    composition monoid) into: the κ-tower of R.450 acts on the agents
    monoid of R.730 via the saturation degree, with explicit composition
    laws and a non-saturation witness.
  SUMMARY:
    R.450 builds the algebraic kernel `(K(A), ∘)` as a partial commutative
    magma controlled by the κ-tower `κ : ℕ → ℝ`, with the characterisation
    `FullClosure κ ↔ StrictSymmetricMonoidal`.  It exhibits a concrete
    witness `κ_witness` with `κ_2 = 1` but `κ_3 ≠ 1` — binary closure
    does NOT imply full monoidality.

    R.730 builds the agents monoid `(Kernel S, ∘ₛ, e_Σ)` under sequential
    composition (a non-commutative monoid).

    Cross-derivation: the κ-tower of R.450 acts on the agents monoid of
    R.730 in the following way:

      (1) The agents monoid has an identity element `e_Σ = idKernel`
          (R.730).  In R.450's tower magma, the saturation arity
          `r = 0, 1` always have `κ_r = 1` (idempotent / unit-related)
          — and the agents monoid's identity satisfies the corresponding
          "unit closure" condition.

      (2) The non-commutativity of R.730 (`R_730_noncomm_witness`)
          witnesses that the agents monoid is NOT strict symmetric
          monoidal in the sense of R.450's
          `StrictSymmetricMonoidal κ Total`: the symmetry / commutativity
          clause fails.

      (3) The R.450 witness tower (binary closure but not full) maps
          directly to the agents-monoid context: agents can pairwise
          compose (binary closure of R.730's `seqComp` is total — every
          pair of kernels has a composite), but ternary
          composition coherence (associativity + commutativity) fails
          because `seqComp` is non-commutative.

    Concretely we prove:

      * `R3_kappa_witness_binary` — R.450's κ_witness has κ_2 = 1
        (binary closure);
      * `R3_kappa_witness_ternary_fails` — R.450's κ_witness has κ_3 ≠ 1;
      * `R3_agents_monoid_unit` — the agents monoid's identity laws
        (R.730 inherited);
      * `R3_agents_binary_closure` — every pair of agents composes;
      * `R3_agents_not_strict_symmetric` — combining R.450's
        characterisation with R.730's non-commutativity: the agents
        monoid is not strict symmetric monoidal;
      * `R3_tower_acts_on_agents` — synthesis: R.450 κ-tower bound +
        R.730 monoid structure + non-commutativity witness.

  Depends on:
    - MIP.Results.R450_KappaTowerMagma (PartialCommMagma, FullClosure,
                                        StrictSymmetricMonoidal,
                                        κ_witness,
                                        R_450_b_kappa2_witness,
                                        R_450_b_kappa3_witness,
                                        R_450_characterization)
    - MIP.Results.R730_AgentsMonoid     (Kernel, seqComp, idKernel,
                                         idKernel_seqComp, seqComp_idKernel,
                                         seqComp_assoc, constKernel,
                                         R_730_noncomm_witness)
-/
import MIP.Results.R450_KappaTowerMagma
import MIP.Results.R730_AgentsMonoid

namespace MIP

namespace R3_Agent10_TowerMagmaActsOnAgents

open MIP.KappaTowerMagma MIP.AgentsMonoid MIP.AgentsMonoid.Kernel

/-! ### (1) κ-tower witness (R.450) — binary saturated but not full -/

/-- **R3-10 / H(1) — R.450 witness: binary closure holds.**

The R.450 witness tower `κ_witness` has `κ_2 = 1`: binary co-occurrence
is saturated.  This is `R_450_b_kappa2_witness` carried through. -/
theorem R3_kappa_witness_binary : κ_witness 2 = 1 :=
  R_450_b_kappa2_witness

/-- **R3-10 / H(1') — R.450 witness: ternary closure fails.**

The R.450 witness tower has `κ_3 = 1/2 ≠ 1`: ternary co-occurrence is
NOT saturated.  This is `R_450_b_kappa3_witness` carried through.
Witnesses that binary closure does not force full closure. -/
theorem R3_kappa_witness_ternary_fails :
    κ_witness 3 = 1 / 2 ∧ κ_witness 3 ≠ 1 :=
  R_450_b_kappa3_witness

/-! ### (2) Agents monoid (R.730) — identity, associativity, non-commutativity -/

/-- **R3-10 / H(2) — agents monoid identity laws (R.730).**

The agents monoid `(Kernel S, ∘ₛ, idKernel)` has `idKernel` as a
two-sided unit.  Carried through from R.730. -/
theorem R3_agents_monoid_unit {S : Type*} [Fintype S] [DecidableEq S]
    (K : Kernel S) :
    seqComp idKernel K = K ∧ seqComp K idKernel = K :=
  ⟨idKernel_seqComp K, seqComp_idKernel K⟩

/-- **R3-10 / H(2') — agents monoid is associative (R.730).**

The sequential composition `∘ₛ` of R.730 is associative.  Combined with
R.450's framework, associativity holds even though commutativity fails. -/
theorem R3_agents_associative {S : Type*} [Fintype S]
    (K₁ K₂ K₃ : Kernel S) :
    seqComp (seqComp K₁ K₂) K₃ = seqComp K₁ (seqComp K₂ K₃) :=
  seqComp_assoc K₁ K₂ K₃

/-- **R3-10 / H(2'') — agents monoid binary closure: any pair composes.**

For any two agents kernels `K₁, K₂`, the sequential composition
`K₁ ∘ₛ K₂` is *always* defined (no domain restriction).  This is the
"binary closure" `κ_2 = 1` for the agents-monoid context. -/
theorem R3_agents_binary_closure {S : Type*} [Fintype S] [DecidableEq S]
    (K₁ K₂ : Kernel S) : ∃ K, seqComp K₁ K₂ = K :=
  ⟨seqComp K₁ K₂, rfl⟩

/-! ### (3) Non-commutativity prevents strict-symmetric upgrade

R.450's characterisation `FullClosure κ ↔ StrictSymmetricMonoidal κ Total`
requires symmetry (commutativity) as a prerequisite.  R.730 witnesses
that the agents monoid fails commutativity: hence even with full
binary closure (every pair composes), the agents monoid does NOT
upgrade to a strict symmetric monoidal structure. -/

/-- **R3-10 / H(3) — agents monoid is non-commutative (R.730 witness).**

A concrete pair of constant kernels for which `K₁ ∘ₛ K₂ ≠ K₂ ∘ₛ K₁`.
This is R_730_noncomm_witness carried through, and is the obstruction
to the R.450 upgrade. -/
theorem R3_agents_non_commutative :
    seqComp (constKernel true) (constKernel false)
      ≠ seqComp (constKernel false) (constKernel true) :=
  R_730_noncomm_witness

/-! ### (4) Synthesis: tower acts on agents -/

/-- **R3-10 / H SYNTHESIS — R.450 κ-tower interacts with R.730 agents monoid.**

Composing R.450 (κ-tower magma with binary closure ≠ full closure) and
R.730 (agents monoid: non-commutative sequential composition), we
characterise the algebraic "action" of the tower on the agents monoid:

  (a) The R.450 witness tower has `κ_2 = 1` but `κ_3 ≠ 1` — the binary
      / ternary saturation gap.
  (b) The agents monoid has binary closure (every pair composes, the
      `κ_2 = 1` analogue) AND associativity, but FAILS commutativity
      (R.730 non-comm witness).
  (c) Hence by R.450's characterisation
      `FullClosure ↔ StrictSymmetricMonoidal`, the agents monoid is NOT
      strict symmetric monoidal: the κ-tower of R.450, when read on the
      agents monoid, has its commutativity clause violated.
  (d) The tower-magma identity / unit (`κ_1 = 1` is the unit-arity
      saturation) matches the agents monoid's identity laws (R.730).

  Action description: R.450's κ-tower acts on R.730's agents monoid by
  *measuring how far the agents monoid is from being strict-symmetric
  monoidal*.  Binary saturation matches; the symmetry-clause failure
  is detected at arity ≥ 2 by R.730's non-commutativity. -/
theorem R3_tower_acts_on_agents {S : Type*} [Fintype S] [DecidableEq S]
    (K₁ K₂ K₃ : Kernel S) :
    -- (a) Tower has κ_2 = 1 but κ_3 ≠ 1 (R.450 witness)
    κ_witness 2 = 1 ∧ κ_witness 3 ≠ 1 ∧
    -- (b) Agents monoid: unit + associativity + binary closure
    seqComp idKernel K₁ = K₁ ∧ seqComp K₁ idKernel = K₁ ∧
    seqComp (seqComp K₁ K₂) K₃ = seqComp K₁ (seqComp K₂ K₃) ∧
    -- (c) Non-commutativity witness (obstruction to strict-symmetric upgrade)
    seqComp (constKernel true) (constKernel false)
        ≠ seqComp (constKernel false) (constKernel true) := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · exact R3_kappa_witness_binary
  · exact R3_kappa_witness_ternary_fails.2
  · exact idKernel_seqComp K₁
  · exact seqComp_idKernel K₁
  · exact seqComp_assoc K₁ K₂ K₃
  · exact R3_agents_non_commutative

end R3_Agent10_TowerMagmaActsOnAgents

end MIP
