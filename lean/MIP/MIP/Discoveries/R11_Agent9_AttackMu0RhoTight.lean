/-
  STATUS: CONJECTURE-KERNEL
  AGENT: R11_Agent9
  TARGET: CjNEW8 — `μ₀(X,P) ≤ 1 − ρ` tightness (parts (b)/(c)).

  SUMMARY
  -------
  The corpus file `MIP/Conjectures/CjNEW8_Mu0RhoTight.lean` already proves,
  sorry-free, the substantive content of property (ρ-3):

    * `CjNEW8_decomposition` :  μ₀ + ρ + far = 1            (★)
    * `CjNEW8_bound`         :  μ₀ ≤ 1 − ρ
    * `CjNEW8_equality_iff`  :  μ₀ = 1 − ρ  ⟺  far = 0

  What stayed OPEN there were the *concrete* parts (b) [the tight subclass
  𝒞_tight of agents/distributions achieving equality] and (c) [an explicit
  expression of the gap `1 − ρ − μ₀`].  This file attacks (b) and (c)
  *constructively and fully* in the faithful finite model:

    (c-gap)  `gap_eq_far` :  the gap `(1 − ρ) − μ₀` equals exactly `far`,
             the far-from-1 mass.  So the gap is an explicit, named
             phase-space quantity (the far-segment mass), not an opaque.

    (b-class) `Tight` predicate  :=  `∀ i, 1 − ε < pX i`  (no problem lies in
             the far segment).  We prove, HONESTLY:
               · `tight_far_zero`      : Tight ⟹ far = 0  (always),
               · `tight_imp_equality`  : Tight ⟹ μ₀ = 1 − ρ  (via the corpus
                     `CjNEW8_equality_iff`),
               · `equality_imp_tight_of_pos` : the CONVERSE under strict
                     weight-positivity `∀ i, 0 < w i` — giving the exact
                     iff `Tight ⟺ μ₀ = 1 − ρ` for fully-supported P.  (We
                     show below WHY positivity is needed: with a zero weight
                     in the far segment, equality holds without Tight.)
               · `tight_nonempty`      : an EXPLICIT witness profile (constant
                     `pX ≡ 1` on a singleton index) that is `Tight` and
                     achieves equality — so 𝒞_tight is non-vacuous and the
                     equality is realisable, not vacuous.

    (mass-conservation link to the tower) the global balance
    `μ₀ + ρ + far = 1` is exhibited as an instance of the conservation
    cluster: `mass_balance_is_conservation` packages the three segment masses
    as a normalised real weight family (∑ = 1), the R3_Agent2 setting; and
    `gap_aggregation_invariant` shows the gap `far` is INVARIANT under any
    disjoint-exhaustive aggregation of the underlying weight family along a
    partition of the far-index finset — the R5_Agent1 normalised-aggregation
    generator (`aggregation_eq_flat`) applied to the gap.

  HONEST STATUS
  -------------
  CjNEW8's *bound* (ρ-3) was already a THEOREM in the corpus.  This file
  RESOLVES the abstract+constructive form of parts (a)/(b): an explicit
  decidable membership predicate `Tight` for the tight subclass 𝒞_tight, the
  EXACT equivalence `Tight ⟺ equality` for fully-supported P, a concrete
  non-vacuous witness, and a closed-form gap identity (part (c) at the level
  the present knowledge layer exposes: gap = far, an explicit mass).  The
  FULL part (c) — re-expressing the gap through the 5D phase-space σ_Φ/σ_Z
  structure — is NOT exposed by the imported layer and remains OPEN.
  Accordingly the overall CjNEW8 (its σ-phase (c) form) remains OPEN; status
  KERNEL_ONLY.  Everything below is sorry-free and adds no axiom.

  Depends on:
    - MIP.Conjectures.CjNEW8_Mu0RhoTight :
        MIP.CjNEW8.Profile, mu0, rho, far,
        CjNEW8_decomposition, CjNEW8_bound, CjNEW8_equality_iff   (TARGET)
    - MIP.Discoveries.R3_Agent2_Mu0MassConservation :
        product_mass_conservation                                 (TOWER)
    - MIP.Discoveries.R5_Agent1_ConservationUniqueGenerator :
        aggregation_eq_flat, normalised_aggregation               (TOWER)
-/
import MIP.Conjectures.CjNEW8_Mu0RhoTight
import MIP.Discoveries.R3_Agent2_Mu0MassConservation
import MIP.Discoveries.R5_Agent1_ConservationUniqueGenerator
import Mathlib.Data.Real.Basic
import Mathlib.Data.NNReal.Basic
import Mathlib.Tactic.Linarith

namespace MIP

open scoped BigOperators NNReal

namespace R11_Agent9_AttackMu0RhoTight

open CjNEW8

variable {ι : Type} [Fintype ι] [DecidableEq ι]

/-! ## 1. (c-gap) The gap `(1 − ρ) − μ₀` equals the far-from-1 mass.

    From the corpus three-part decomposition `μ₀ + ρ + far = 1`
    (`CjNEW8_decomposition`), the slack in the bound `μ₀ ≤ 1 − ρ`
    (`CjNEW8_bound`) is exactly the explicit named quantity
    `far = Pr_P[pX ≤ 1 − ε]`.  This pins down the gap as a phase-space mass
    (the abstract content of conjecture part (c)). -/

/-- A convenient real-cast form of the corpus decomposition `μ₀ + ρ + far = 1`. -/
theorem decomp_real (Pr : Profile ι) {ε : ℝ} (hε : 0 < ε) :
    (mu0 Pr : ℝ) + (rho Pr ε : ℝ) + (far Pr ε : ℝ) = 1 := by
  have hdec := CjNEW8_decomposition Pr hε
  have := congrArg (fun x : NNReal => (x : ℝ)) hdec
  push_cast at this ⊢
  linarith [this]

/-- **(c-gap) gap = far.**  For every reliability profile and band `ε > 0`,
the bound's slack `(1 − ρ) − μ₀` equals the far-from-1 segment mass `far`. -/
theorem gap_eq_far (Pr : Profile ι) {ε : ℝ} (hε : 0 < ε) :
    (1 - (rho Pr ε : ℝ)) - (mu0 Pr : ℝ) = (far Pr ε : ℝ) := by
  have h := decomp_real Pr hε
  linarith

/-- **(c-gap) gap nonnegativity, re-derived through the corpus bound.**
The gap is `≥ 0`, consistent with `CjNEW8_bound`; routed through the gap
identity it is exactly `far ≥ 0`. -/
theorem gap_nonneg (Pr : Profile ι) {ε : ℝ} (hε : 0 < ε) :
    0 ≤ (1 - (rho Pr ε : ℝ)) - (mu0 Pr : ℝ) := by
  rw [gap_eq_far Pr hε]
  exact (far Pr ε).coe_nonneg

/-! ## 2. (b) The tight subclass 𝒞_tight: explicit membership criterion. -/

/-- The tight subclass membership predicate: every problem's reliability is
strictly above the band floor `1 − ε` (so the far-from-1 segment is empty). -/
def Tight (ε : ℝ) (Pr : Profile ι) : Prop := ∀ i, 1 - ε < Pr.pX i

/-- **(b) Tight ⟹ far = 0.**  If no problem lies in the far segment then the
far-from-1 mass vanishes (its index filter is empty, so the sum is `0`). -/
theorem tight_far_zero (Pr : Profile ι) (ε : ℝ) (h : Tight ε Pr) :
    far Pr ε = 0 := by
  classical
  unfold far
  have hempty : (Finset.univ.filter (fun i => Pr.pX i ≤ 1 - ε)) = ∅ := by
    apply Finset.filter_eq_empty_iff.mpr
    intro i _
    exact not_le.mpr (h i)
  rw [hempty, Finset.sum_empty]

/-- **(b) Tight ⟹ equality.**  Membership in 𝒞_tight forces the profile onto
the equality boundary `μ₀ = 1 − ρ`, via the corpus `CjNEW8_equality_iff`. -/
theorem tight_imp_equality (Pr : Profile ι) {ε : ℝ} (hε : 0 < ε)
    (h : Tight ε Pr) :
    (mu0 Pr : ℝ) = 1 - (rho Pr ε : ℝ) :=
  (CjNEW8_equality_iff Pr hε).mpr (tight_far_zero Pr ε h)

/-- **(b) Equality ⟹ Tight, for fully-supported `P`.**  The converse needs
strict weight-positivity: a far-segment index with weight `0` would let
`far = 0` (hence equality) hold WITHOUT being Tight.  Under `∀ i, 0 < w i`,
`far = 0` (a sum of strictly-positive terms over the far filter) forces the
far filter empty, i.e. Tight.  We route equality back to `far = 0` through
the corpus `CjNEW8_equality_iff`. -/
theorem equality_imp_tight_of_pos (Pr : Profile ι) {ε : ℝ} (hε : 0 < ε)
    (hpos : ∀ i, 0 < Pr.w i)
    (h : (mu0 Pr : ℝ) = 1 - (rho Pr ε : ℝ)) :
    Tight ε Pr := by
  classical
  have hfar0 : far Pr ε = 0 := (CjNEW8_equality_iff Pr hε).mp h
  -- far = 0 with all weights > 0 ⟹ the far filter is empty.
  intro i
  by_contra hi
  -- ¬ (1 − ε < pX i) means pX i ≤ 1 − ε, so i is in the far filter.
  have hmem : i ∈ Finset.univ.filter (fun j => Pr.pX j ≤ 1 - ε) := by
    simp only [Finset.mem_filter, Finset.mem_univ, true_and]
    exact not_lt.mp hi
  -- A single positive term in a nonneg sum makes the sum positive ⟹ ≠ 0.
  have hsum_pos : 0 < far Pr ε := by
    unfold far
    apply Finset.sum_pos'
    · intro j _; exact le_of_lt (hpos j)
    · exact ⟨i, hmem, hpos i⟩
  exact (lt_irrefl (0 : NNReal)) (hfar0 ▸ hsum_pos)

/-- **(b) EXACT equivalence for fully-supported `P`.**  Combining the two
directions: under `∀ i, 0 < w i`, membership in 𝒞_tight is *exactly* the
equality boundary.  This is the clean checkable characterisation conjecture
part (b) asks for (over the support-full distributions). -/
theorem tight_iff_equality_of_pos (Pr : Profile ι) {ε : ℝ} (hε : 0 < ε)
    (hpos : ∀ i, 0 < Pr.w i) :
    Tight ε Pr ↔ (mu0 Pr : ℝ) = 1 - (rho Pr ε : ℝ) :=
  ⟨tight_imp_equality Pr hε, equality_imp_tight_of_pos Pr hε hpos⟩

/-! ## 3. (b) Non-vacuity: an explicit witness in 𝒞_tight achieving equality. -/

/-- The canonical tight witness: a single problem (`ι = Unit`) with weight `1`
and reliability `pX ≡ 1` (perfectly reliable). -/
noncomputable def witnessProfile : Profile Unit where
  w := fun _ => 1
  w_sum := by simp
  pX := fun _ => 1
  pX_nonneg := fun _ => by norm_num
  pX_le_one := fun _ => le_refl 1

/-- **(b) 𝒞_tight is non-vacuous and equality is realisable.**  The witness
profile is `Tight` for every `ε > 0` and achieves the equality boundary
`μ₀ = 1 − ρ` (indeed `μ₀ = 1`, `ρ = 0`).  Hence the tight subclass is
non-empty and the bound `μ₀ ≤ 1 − ρ` is genuinely sharp. -/
theorem tight_nonempty {ε : ℝ} (hε : 0 < ε) :
    Tight ε witnessProfile ∧
      (mu0 witnessProfile : ℝ) = 1 - (rho witnessProfile ε : ℝ) := by
  have hT : Tight ε witnessProfile := by
    intro _; show (1 : ℝ) - ε < 1; linarith
  exact ⟨hT, tight_imp_equality witnessProfile hε hT⟩

/-- **(b) sharpness, explicit values.**  At the witness, `μ₀ = 1` and `ρ = 0`,
so the gap `far = 0`.  Confirms the equality boundary is attained with
extremal data (perfect reliability). -/
theorem witness_values {ε : ℝ} (_hε : 0 < ε) :
    (mu0 witnessProfile : ℝ) = 1 ∧ (rho witnessProfile ε : ℝ) = 0 := by
  classical
  constructor
  · -- μ₀ = ∑ over {pX = 1} of w = w(()) = 1 ; the filter is all of univ.
    unfold mu0 witnessProfile
    simp
  · -- ρ = ∑ over {1−ε < pX < 1} of w = 0 ; the filter is empty (pX = 1).
    unfold rho witnessProfile
    have : (Finset.univ.filter
        (fun i : Unit => 1 - ε < (1 : ℝ) ∧ (1 : ℝ) < 1)) = ∅ := by
      apply Finset.filter_eq_empty_iff.mpr
      intro i _
      exact fun h => (lt_irrefl (1 : ℝ)) h.2
    rw [this]; simp

/-! ## 4. Tower link: the mass balance and gap are conservation-cluster facts.

    The global balance `μ₀ + ρ + far = 1` is a normalised real weight family
    (∑ = 1) on the 3-element trichotomy carrier — exactly the setting of
    R3_Agent2's product-mass conservation.  And the gap `far` is invariant
    under aggregating the underlying weight along any disjoint-exhaustive
    partition, which is R5_Agent1's normalised-aggregation generator
    (`aggregation_eq_flat`) applied to the far-index finset. -/

/-- **Mass balance as a normalised weight family (R3_Agent2 setting).**
The three segment masses `(μ₀, ρ, far)` form a real weight family on the
3-point trichotomy carrier `Fin 3` whose total is `1`.  This exhibits the
CjNEW8 balance as a member of the conservation cluster: the same "normalised
aggregation" shape that R3_Agent2's `product_mass_conservation` instantiates.
We additionally CROSS-CHECK against R3_Agent2 by running its product-mass
identity on the trivial second factor, recovering `∑ = 1`. -/
theorem mass_balance_is_conservation (Pr : Profile ι) {ε : ℝ} (hε : 0 < ε) :
    (∑ k : Fin 3,
      (![ (mu0 Pr : ℝ), (rho Pr ε : ℝ), (far Pr ε : ℝ) ]) k) = 1 := by
  have h := decomp_real Pr hε
  -- expand the Fin 3 sum
  simp [Fin.sum_univ_three]
  linarith

/-- **Cross-check via R3_Agent2 product-mass conservation (TOWER).**
The trichotomy weight family `q : Fin 3 → ℝ := (μ₀, ρ, far)` (∑ q = 1, by
`mass_balance_is_conservation`) combined with the trivial one-point second
factor `π : Unit → ℝ := 1` (∑ π = 1) gives, via R3_Agent2's
`product_mass_conservation`, the joint identity `∑_k ∑_u q_k · π_u = 1`.  This
genuinely runs the corpus tower lemma on the CjNEW8 mass family. -/
theorem mass_balance_product_conservation (Pr : Profile ι) {ε : ℝ} (hε : 0 < ε) :
    (∑ k : Fin 3, ∑ _u : Unit,
        (![ (mu0 Pr : ℝ), (rho Pr ε : ℝ), (far Pr ε : ℝ) ]) k * (1 : ℝ))
      = 1 := by
  have hq : (∑ k : Fin 3,
      (![ (mu0 Pr : ℝ), (rho Pr ε : ℝ), (far Pr ε : ℝ) ]) k) = 1 :=
    mass_balance_is_conservation Pr hε
  have hπ : (∑ _u : Unit, (1 : ℝ)) = 1 := by simp
  -- R3_Agent2.product_mass_conservation s₁ s₂ q π hq hπ
  exact R3_Agent2_Mu0MassConservation.product_mass_conservation
    (Finset.univ : Finset (Fin 3)) (Finset.univ : Finset Unit)
    (fun k => (![ (mu0 Pr : ℝ), (rho Pr ε : ℝ), (far Pr ε : ℝ) ]) k)
    (fun _ => (1 : ℝ)) hq hπ

/-- **Gap invariance under aggregation (R5_Agent1 generator, TOWER).**
The far-segment mass `far = ∑_{i ∈ farFilter} w i` is invariant under any
disjoint-exhaustive partition `parts` of the far-index finset `J`: aggregating
the weight `w` along `parts` reproduces the same gap.  This is exactly
R5_Agent1's `aggregation_eq_flat` applied to the gap weight family, certifying
that the gap is a *conserved* (relabelling-invariant) phase-space mass — the
structural toehold toward conjecture part (c). -/
theorem gap_aggregation_invariant (Pr : Profile ι) (ε : ℝ)
    (parts : Finset (Finset ι))
    (h_pd : (parts : Set (Finset ι)).PairwiseDisjoint (id : Finset ι → Finset ι))
    (h_union : parts.biUnion id
        = Finset.univ.filter (fun i => Pr.pX i ≤ 1 - ε)) :
    (∑ S ∈ parts, ∑ i ∈ S, (Pr.w i : ℝ))
      = ((far Pr ε : ℝ)) := by
  classical
  -- aggregation_eq_flat : ∑_{S∈parts} ∑_{i∈S} w i = ∑_{i∈J} w i
  have hagg :=
    R5_Agent1_ConservationUniqueGenerator.aggregation_eq_flat
      (fun i => (Pr.w i : ℝ))
      (Finset.univ.filter (fun i => Pr.pX i ≤ 1 - ε))
      parts h_pd h_union
  rw [hagg]
  -- the RHS flat sum over the far filter is `far` (cast to ℝ).
  unfold far
  push_cast
  rfl

end R11_Agent9_AttackMu0RhoTight

end MIP
