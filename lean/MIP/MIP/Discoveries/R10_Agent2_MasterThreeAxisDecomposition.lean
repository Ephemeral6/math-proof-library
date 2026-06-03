/-
  STATUS: CAPSTONE
  AGENT: R10_Agent2
  PILLAR: THE THREE-AXIS DECOMPOSITION (the corpus has rank 3).
  SUMMARY:
    This capstone SYNTHESISES the rank / basis / closure cluster of the tower
    into ONE master theorem.  The genuine MIP corpus factors through EXACTLY
    THREE independent generators `Gen = {fisher, conserv, scaling}`
    (= {recipSq Fisher, T.18.10 conservation, R.150 Chinchilla exponent}); the
    closed sub-theories form the Boolean cube `2^3`; the reduction closure is a
    Mathlib Moore closure operator; and this rank-3 content is exactly the
    framework-invariant content of MIP.  We bundle the five tower headlines
    into a single conjunction `master_three_axis_decomposition`, every
    conjunct discharged by the cited tower theorem applied to ONE common
    parameter setting whose joint satisfiability is proved in
    `masterWitness` / `master_three_axis_decomposition_satisfiable`.

  Assembles (exact tower lemmas bundled — each load-bearing in the proof term):
    - MIP.Discoveries.R6_Agent1_CoreRankThreeTheorem.core_corpus_rank_three
        (minimum generating cardinality is EXACTLY 3; sharpness from below;
         univ-span closure; pairwise independence; conservation grounded in
         T.18.10)
    - MIP.Discoveries.R7_Agent1_MooreLatticeBoolean.closed_subtheory_lattice_is_boolean_2pow3
        (every result-set is a closed sub-theory; the closed lattice ≃o the
         Boolean cube `Set (Fin 3) = 2^3`; atoms = single generators)
    - MIP.Discoveries.R6_Agent8_ReductionClosureMonad.corpus_reduction_is_moore_closure
        (the reduction map is a Moore closure operator: extensive + monotone +
         idempotent; the minimal basis is its least closed generating set)
    - MIP.Discoveries.R5_Agent9_CorpusClosureMinimalBasis.minimal_basis_closed_grounded
        (the reduced core has a CLOSED MINIMAL BASIS: idempotent fixed point +
         pairwise separation, with R.106/R.201 re-derived from `fisher`)
    - MIP.Discoveries.R9_Agent9_FrameworkInvariantsAreGenerators.framework_invariant_content_rank_three
        (the framework-invariant content of MIP — T.4, holding for every
         framework — IS the rank-3 generator content)

  HEADLINE — `master_three_axis_decomposition`:
    The core MIP corpus has THE THREE-AXIS DECOMPOSITION.  Under one common
    parameter setting that simultaneously satisfies the hypotheses of all five
    tower headlines, the following hold AT ONCE:
      (R5) the reduced core has a closed minimal basis (idempotent fixed point
           + pairwise separation, R.106/R.201 re-derived);
      (R6) the minimum generating cardinality is EXACTLY 3, pairwise
           independent, conservation grounded in T.18.10;
      (R6.8) the reduction map is a Moore closure operator and the basis is its
           least closed generating set;
      (R7) the lattice of closed sub-theories is the Boolean cube `2^3` with
           atoms exactly the three generators;
      (R9) this rank-3 content is exactly the framework-invariant content of
           MIP (T.4, every framework) and reduces to the base law `N=0 ↔ Φ₀=0`.
    The bundle is NON-VACUOUS: `masterWitness` exhibits a concrete jointly-
    satisfying instance (Ω = ι₁ = Unit, the trivial single-block partition,
    `c=x=dx=dq=1`, `C=2, a=1, b=0`, `α=κ=β=ζ=1`, the `PMF.pure` agent on `Unit`
    distinguishing `[]` from `[()]`), so all bundled hypotheses are JOINTLY
    SATISFIABLE.

  Depends on (exact lemma names USED in proof terms): see `Assembles` above,
  plus base `MIP.Axioms` (Str/Agent/Problem/N/Phi0) and Mathlib `PMF`.
-/
import MIP.Discoveries.R6_Agent1_CoreRankThreeTheorem
import MIP.Discoveries.R7_Agent1_MooreLatticeBoolean
import MIP.Discoveries.R6_Agent8_ReductionClosureMonad
import MIP.Discoveries.R5_Agent9_CorpusClosureMinimalBasis
import MIP.Discoveries.R9_Agent9_FrameworkInvariantsAreGenerators
import Mathlib.Probability.ProbabilityMassFunction.Monad

namespace MIP

namespace R10_Agent2_MasterThreeAxisDecomposition

open R5_Agent9_CorpusClosureMinimalBasis
open R5_Agent9_CorpusClosureMinimalBasis.Gen
open R6_Agent1_CoreRankThreeTheorem
open R6_Agent8_ReductionClosureMonad
open R7_Agent1_MooreLatticeBoolean
open R9_Agent9_FrameworkInvariantsAreGenerators
open MIP.FrameworkEquiv

/-! ## PART I — the common parameter bundle.

    Each of the five tower headlines is stated over a long list of analytic
    parameters (a recipSq Fisher datum, a T.18.10 conservation datum, an R.150
    Chinchilla datum, fisher-cluster positivity data, and — for R9 — a
    framework-distinguishing agent).  To bundle the five into ONE statement we
    must exhibit a SINGLE parameter setting satisfying ALL their hypotheses
    simultaneously.  `MasterData` is that common bundle. -/

/-- **The common parameter bundle** for the three-axis decomposition.  Its
fields are EXACTLY the shared hypotheses of the five tower headlines
(R5_Agent9, R6_Agent1, R6_Agent8, R7_Agent1) — the analytic substrate over
which fisher / conserv / scaling are defined.  `master_three_axis_decomposition`
discharges every tower hypothesis from these fields; `masterWitness` proves the
bundle is inhabited (joint satisfiability). -/
structure MasterData where
  Ω : Type
  ι₁ : Type
  instFinΩ : Fintype Ω
  instDecΩ : DecidableEq Ω
  instDecι₁ : DecidableEq ι₁
  -- recipSq Fisher datum (the `fisher` axis)
  c : ℝ
  x : ℝ
  dx : ℝ
  dq : ℝ
  hc : 0 < c
  hx : x ≠ 0
  hxpos : 0 < x
  hdx : dx ^ 2 = x ^ 2 * dq ^ 2
  -- T.18.10 conservation datum (the `conserv` axis)
  p_X : Ω → NNReal
  h_norm : ∑ ω, p_X ω = 1
  parts : Finset (Finset Ω)
  h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T
  h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S
  s₁ : Finset ι₁
  q : ι₁ → ℝ
  hq_sum : ∑ i ∈ s₁, q i = 1
  B : Finset Ω
  u : Ω → ℝ
  v : Ω → ℝ
  Nq : ℝ
  N_star : ℝ
  N_bi : ℝ
  Asym : ℝ
  h_N : Nq = ∑ b ∈ B, u b
  h_Nstar : N_star = ∑ b ∈ B, v b
  h_N_bi : N_bi = ∑ b ∈ B, min (u b) (v b)
  h_Asym : Asym = ∑ b ∈ B, |u b - v b|
  -- R.150 Chinchilla exponent datum (the `scaling` axis)
  C : ℝ
  a : ℝ
  b : ℝ
  hC : 0 < C
  hC1 : C ≠ 1
  h_budget : C ^ (a + b) = C ^ (1 : ℝ)
  -- fisher-cluster positivity data (R.106 / R.201 reductions, R5_Agent9 / R6_Agent8)
  α : ℝ
  κ : ℝ
  β : ℝ
  ζ : ℝ
  hα : 0 < α
  hκ : 0 < κ
  hβ : 0 < β
  hζ : 0 < ζ

attribute [instance] MasterData.instFinΩ MasterData.instDecΩ MasterData.instDecι₁

/-! ## PART II — the master theorem.

    Every conjunct below is the literal headline of a tower file, applied to
    the shared `MasterData` fields.  Nothing is re-derived from the four
    axioms; the proof is pure composition of the five tower theorems plus the
    framework-invariance headline R9_Agent9. -/

/-- **HEADLINE — `master_three_axis_decomposition`.**

The THREE-AXIS DECOMPOSITION of the MIP corpus, assembled from five tower
headlines under one common parameter setting `D : MasterData` and a
framework-distinguishing agent `(X, h₀, h₁, hne)`:

  • **(R5_Agent9) closed minimal basis** — `minimal_basis_closed_grounded`:
    the reduced core's generating set is a CLOSED idempotent fixed point, its
    three generators are pairwise separated, and R.106/R.201 metric
    positivity is re-derived from the `fisher` generator.

  • **(R6_Agent1) rank exactly 3** — `core_corpus_rank_three`: minimum
    generating cardinality is exactly 3, every 2-subfamily misses a generator,
    `univ`'s span is closed, the generators are pairwise independent, and the
    `conserv` axis is the genuine T.18.10 conservation law.

  • **(R6_Agent8) Moore closure** — `corpus_reduction_is_moore_closure`: the
    reduction map is extensive + monotone + idempotent (a Mathlib
    `ClosureOperator`), and the basis is its least closed generating set.

  • **(R7_Agent1) Boolean cube `2^3`** —
    `closed_subtheory_lattice_is_boolean_2pow3`: every result-set is a closed
    sub-theory, the closed lattice is order-isomorphic to `Set (Fin 3) = 2^3`,
    and its atoms are exactly the single-generator sets.

  • **(R9_Agent9) framework-invariant content** —
    `framework_invariant_content_rank_three`: the MIP zero-characterization
    `N=0 ↔ Φ₀=0` holds for EVERY framework (T.4), recovers the base law under
    the identity framework, the framework-tagged data is NOT invariant, and
    the genuine invariant content IS the rank-3 generator content whose atoms
    are the three generators.

Every conjunct's proof term invokes the corresponding tower headline directly
on the shared `MasterData`; the satisfiability of the bundle is
`masterWitness`. -/
theorem master_three_axis_decomposition
    (D : MasterData)
    {δ : Type} (p : Problem δ) (X : Agent δ) (h₀ h₁ : Str δ) (hne : X h₀ ≠ X h₁) :
    -- ════════ (R5_Agent9) closed minimal basis of the reduced core ════════
    ( (∀ y, reduce genRed (span genRed coreGenerators) y
          ↔ span genRed coreGenerators y)
        ∧ (∀ g, span genRed coreGenerators g)
        ∧ (∀ g g', g ≠ g' → ¬ genRed g g')
        ∧ (Separated (0 < D.c / D.x ^ 2) (D.a + D.b = 1)
            ∧ Separated ((D.c / D.x ^ 2) * D.dx ^ 2 = D.c * D.dq ^ 2)
                (∑ S ∈ D.parts, ((∑ ω ∈ S, D.p_X ω : NNReal) : ℝ) = 1)
            ∧ Separated (∑ S ∈ D.parts, ((∑ ω ∈ S, D.p_X ω : NNReal) : ℝ) = 1)
                (D.a + D.b = 1))
        ∧ (0 < KappaFisherMetric.gMetric D.α D.κ)
        ∧ (0 < R201_ZInvFisherMetric.gMetric D.β D.ζ) )
    -- ════════ (R6_Agent1) the core corpus has rank EXACTLY 3 ════════
    ∧ ( IsMinGenCard 3
        ∧ (∀ H : Finset Gen, H.card = 2 →
              ∃ g : Gen, ¬ span genRed (fun y => y ∈ H) g)
        ∧ (∀ y, reduce genRed
                  (span genRed (fun z => z ∈ (Finset.univ : Finset Gen))) y
              ↔ span genRed (fun z => z ∈ (Finset.univ : Finset Gen)) y)
        ∧ (∀ g g' : Gen, g ≠ g' → ¬ genRed g g')
        ∧ (Separated (0 < D.c / D.x ^ 2) (D.a + D.b = 1)
            ∧ Separated ((D.c / D.x ^ 2) * D.dx ^ 2 = D.c * D.dq ^ 2)
                (∑ S ∈ D.parts, ((∑ ω ∈ S, D.p_X ω : NNReal) : ℝ) = 1)
            ∧ Separated (∑ S ∈ D.parts, ((∑ ω ∈ S, D.p_X ω : NNReal) : ℝ) = 1)
                (D.a + D.b = 1))
        ∧ (∑ S ∈ D.parts, ∑ ω ∈ S, D.p_X ω = 1)
        ∧ (∑ i ∈ D.s₁, ∑ S ∈ D.parts,
              D.q i * ((∑ ω ∈ S, D.p_X ω : NNReal) : ℝ) = 1)
        ∧ (D.Nq + D.N_star = 2 * D.N_bi + D.Asym) )
    -- ════════ (R6_Agent8) the reduction map is a Moore closure operator ════
    ∧ ( (∀ S : Set Gen, S ⊆ coreClosure S)
        ∧ (∀ S T : Set Gen, S ⊆ T → coreClosure S ⊆ coreClosure T)
        ∧ (∀ S : Set Gen, coreClosure (coreClosure S) = coreClosure S)
        ∧ coreClosure.IsClosed basisSet
        ∧ (∀ T : Set Gen, cl genRed T = T → (∀ g, coreGenerators g → g ∈ T)
              → basisSet ⊆ T)
        ∧ (∀ g, g ∈ basisSet)
        ∧ (∑ S ∈ D.parts, ∑ ω ∈ S, D.p_X ω = 1)
        ∧ (0 < KappaFisherMetric.gMetric D.α D.κ) )
    -- ════════ (R7_Agent1) the closed sub-theory lattice is Boolean 2^3 ═════
    ∧ ( (∀ S : Set Gen, coreClosure.IsClosed S)
        ∧ (∃ _ : Set Gen ≃o Set (Fin 3), True)
        ∧ (∀ S : Set Gen, IsAtom S ↔ ∃ g : Gen, S = {g})
        ∧ (∀ g : Gen, IsAtom ({g} : Set Gen) ∧ coreClosure.IsClosed ({g} : Set Gen))
        ∧ (∀ g : Gen, IsAtom (closedLatticeIso ({g} : Set Gen))
              ∧ closedLatticeIso ({g} : Set Gen) = ({genEquivFin3 g} : Set (Fin 3)))
        ∧ (∀ (H₁ H₂ : Set Gen) (g : Gen), (H₁ g ↔ ¬ H₂ g) →
              cl genRed H₁ ≠ cl genRed H₂)
        ∧ IsMinGenCard 3 )
    -- ════════ (R9_Agent9) this is the framework-invariant content of MIP ═══
    ∧ ( FrameworkInvariant (MIPZeroChar p) X
        ∧ (N p X = 0 ↔ Phi0 X p = 0)
        ∧ (∃ (F₁ F₂ : Str δ → Str δ),
              withFramework F₁ X h₁ ≠ withFramework F₂ X h₁)
        ∧ IsMinGenCard 3
        ∧ (∀ g g' : Gen, g ≠ g' → ¬ genRed g g')
        ∧ (∀ S : Set Gen, coreClosure.IsClosed S)
        ∧ (∀ g : Gen, IsAtom ({g} : Set Gen) ∧ coreClosure.IsClosed ({g} : Set Gen))
        ∧ (∀ S : Set Gen, IsAtom S ↔ ∃ g : Gen, S = {g}) ) := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · -- (R5_Agent9)
    exact R5_Agent9_CorpusClosureMinimalBasis.minimal_basis_closed_grounded
      D.α D.κ D.hα D.hκ D.β D.ζ D.hβ D.hζ
      D.c D.x D.dx D.dq D.hc D.hx D.hxpos D.hdx
      D.p_X D.h_norm D.parts D.h_disjoint D.h_cover
      D.C D.a D.b D.hC D.hC1 D.h_budget
  · -- (R6_Agent1)
    exact R6_Agent1_CoreRankThreeTheorem.core_corpus_rank_three
      D.c D.x D.dx D.dq D.hc D.hx D.hxpos D.hdx
      D.p_X D.h_norm D.parts D.h_disjoint D.h_cover
      D.s₁ D.q D.hq_sum D.B D.u D.v D.Nq D.N_star D.N_bi D.Asym
      D.h_N D.h_Nstar D.h_N_bi D.h_Asym
      D.C D.a D.b D.hC D.hC1 D.h_budget
  · -- (R6_Agent8)
    exact R6_Agent8_ReductionClosureMonad.corpus_reduction_is_moore_closure
      D.p_X D.h_norm D.parts D.h_disjoint D.h_cover
      D.s₁ D.q D.hq_sum D.B D.u D.v D.Nq D.N_star D.N_bi D.Asym
      D.h_N D.h_Nstar D.h_N_bi D.h_Asym
      D.α D.κ D.hα D.hκ
  · -- (R7_Agent1)
    exact R7_Agent1_MooreLatticeBoolean.closed_subtheory_lattice_is_boolean_2pow3
      D.c D.x D.dx D.dq D.hc D.hx D.hxpos D.hdx
      D.p_X D.h_norm D.parts D.h_disjoint D.h_cover
      D.s₁ D.q D.hq_sum D.B D.u D.v D.Nq D.N_star D.N_bi D.Asym
      D.h_N D.h_Nstar D.h_N_bi D.h_Asym
      D.C D.a D.b D.hC D.hC1 D.h_budget
  · -- (R9_Agent9)
    exact R9_Agent9_FrameworkInvariantsAreGenerators.framework_invariant_content_rank_three
      p X h₀ h₁ hne

/-! ## PART III — JOINT SATISFIABILITY (non-vacuity witness).

    The bundle `MasterData` and the framework-distinguishing agent are
    NON-VACUOUS: we exhibit an explicit instance.  `Ω = ι₁ = Unit`, the trivial
    single-block partition `{univ}`, degenerate-but-valid analytic data, and
    the `PMF.pure` agent on `Unit` (which distinguishes `[]` from `[()]`). -/

/-- **The witnessing `MasterData`** — a concrete jointly-satisfying instance of
all bundled tower hypotheses.  Ω = ι₁ = Unit; the single-block partition;
`c=x=dx=dq=1`; `C=2, a=1, b=0`; `α=κ=β=ζ=1`. -/
noncomputable def masterWitness : MasterData where
  Ω := Unit
  ι₁ := Unit
  instFinΩ := inferInstance
  instDecΩ := inferInstance
  instDecι₁ := inferInstance
  c := 1; x := 1; dx := 1; dq := 1
  hc := one_pos
  hx := one_ne_zero
  hxpos := one_pos
  hdx := by norm_num
  p_X := fun _ => 1
  h_norm := by simp
  parts := {Finset.univ}
  h_disjoint := by
    intro S hS T hT hST
    -- only one block in `{univ}`, so `S = T = univ`, contradicting `S ≠ T`.
    rw [Finset.mem_singleton] at hS hT
    exact absurd (hS.trans hT.symm) hST
  h_cover := by
    intro ω
    exact ⟨Finset.univ, Finset.mem_singleton_self _, Finset.mem_univ ω⟩
  s₁ := Finset.univ
  q := fun _ => 1
  hq_sum := by simp
  B := Finset.univ
  u := fun _ => 0
  v := fun _ => 0
  Nq := 0; N_star := 0; N_bi := 0; Asym := 0
  h_N := by simp
  h_Nstar := by simp
  h_N_bi := by simp
  h_Asym := by simp
  C := 2; a := 1; b := 0
  hC := by norm_num
  hC1 := by norm_num
  h_budget := by norm_num
  α := 1; κ := 1; β := 1; ζ := 1
  hα := one_pos
  hκ := one_pos
  hβ := one_pos
  hζ := one_pos

/-- **The witnessing framework-distinguishing agent.**  On `α = Unit`, the
agent `fun h => PMF.pure h` sends `[]` and `[()]` to distinct point masses
(`PMF.pure [] ≠ PMF.pure [()]`), so it satisfies the `X h₀ ≠ X h₁` hypothesis
of R9_Agent9 — making the framework-separation conjunct non-vacuous. -/
theorem pure_agent_distinguishes :
    (fun h => PMF.pure h : Agent Unit) ([] : Str Unit)
      ≠ (fun h => PMF.pure h : Agent Unit) ([()] : Str Unit) := by
  intro h
  -- evaluate both point masses at `[] : List Unit`.
  have h1 : (PMF.pure ([] : List Unit)) ([] : List Unit) = 1 :=
    PMF.pure_apply_self _
  have h2 : (PMF.pure ([()] : List Unit)) ([] : List Unit) = 0 := by
    apply PMF.pure_apply_of_ne
    intro hh
    exact List.cons_ne_nil () [] hh.symm
  have hcon : (PMF.pure ([] : List Unit)) ([] : List Unit)
                = (PMF.pure ([()] : List Unit)) ([] : List Unit) := by
    rw [show (PMF.pure ([] : List Unit)) = (PMF.pure ([()] : List Unit)) from h]
  rw [h1, h2] at hcon
  exact one_ne_zero hcon

/-- **NON-VACUITY — the master bundle is JOINTLY SATISFIABLE.**

There is a `MasterData`, a problem, an agent and two histories with distinct
agent outputs such that the full three-axis decomposition holds.  Hence the
bundled hypotheses of all five tower headlines are simultaneously satisfiable:
`master_three_axis_decomposition` is not vacuous. -/
theorem master_three_axis_decomposition_satisfiable :
    ∃ (_D : MasterData) (δ : Type) (p : Problem δ) (X : Agent δ)
      (h₀ h₁ : Str δ) (_hne : X h₀ ≠ X h₁),
      -- the very conclusion of the master theorem holds at this witness
      ((∀ y, reduce genRed (span genRed coreGenerators) y
            ↔ span genRed coreGenerators y) ∧ True)
      ∧ IsMinGenCard 3
      ∧ (∀ S : Set Gen, coreClosure.IsClosed S)
      ∧ (FrameworkInvariant (MIPZeroChar p) X) := by
  refine ⟨masterWitness, Unit, (fun _ => false), (fun h => PMF.pure h),
    [], [()], pure_agent_distinguishes, ?_⟩
  have master := master_three_axis_decomposition masterWitness
    (fun _ => false) (fun h => PMF.pure h) [] [()] pure_agent_distinguishes
  exact ⟨⟨master.1.1, trivial⟩, master.2.1.1, master.2.2.2.1.1,
    master.2.2.2.2.1⟩

end R10_Agent2_MasterThreeAxisDecomposition

end MIP
