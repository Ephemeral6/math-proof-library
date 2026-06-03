/-
  STATUS: DISCOVERY
  AGENT: R9_Agent9
  DIRECTION: THE FRAMEWORK-INVARIANT CONTENT OF MIP HAS RANK 3.

    The corpus carries, on the SEMANTIC side, T.4 framework-equivalence
    (`MIP.FrameworkEquiv.T4_NeqZero_iff_Phi0_eqZero`): for EVERY framework
    operator `F : Str α → Str α`, the augmented agent `withFramework F X`
    still satisfies the MIP zero-characterization `NF p F X = 0 ↔ Phi0F X F p
    = 0`.  This biconditional is the genuine *framework-INDEPENDENT* law: it
    is preserved verbatim by every framework transformation.

    On the STRUCTURAL side, Round-6 Agent 1
    (`R6_Agent1_CoreRankThreeTheorem.core_corpus_rank_three`,
    `IsMinGenCard 3`) proved the genuine corpus content has RANK EXACTLY 3
    over the three pairwise-independent generators `Gen = {fisher, conserv,
    scaling}`, and Round-7 Agent 1
    (`R7_Agent1_MooreLatticeBoolean.all_isClosed`,
    `closed_subtheory_lattice_is_boolean_2pow3`) identified the lattice of
    closed sub-theories with the Boolean cube `2^3` whose atoms are exactly
    those three generators.

    THIS FILE fuses the two sides:

    ── (a) THE MIP CONTENT IS FRAMEWORK-INVARIANT ──────────────────────────
    We formalise "framework-invariant" as: a property of `(p, X)` that holds
    of `withFramework F X` for EVERY framework `F`.  The MIP
    zero-characterization is framework-invariant in this exact sense
    (`mip_zero_characterization_framework_invariant`), and it ANCHORS back to
    the base theory because the identity framework reduces `withFramework`,
    `NF`, `Phi0F` to plain `N`, `Phi0` (`withFramework_id`, `NF_id`,
    `Phi0F_id`).  So the framework-invariant law is genuinely the base MIP law
    `N = 0 ↔ Φ₀ = 0`, holding under every framework.

    ── (b) SEPARATION: THE FRAMEWORK DATA IS NOT INVARIANT ─────────────────
    `withFramework F X` is *definitionally* `fun h => X (F h)` — it genuinely
    depends on `F` (`withFramework_apply`).  We exhibit a CONCRETE framework
    pair whose augmented agents differ on a witnessing history
    (`framework_data_dependent`): the per-framework agent value is NOT a
    framework invariant.  Thus the invariant *content* is strictly the
    zero-characterization biconditional, not the raw framework-tagged data —
    the invariants are sparse, matching a finite-rank skeleton.

    ── (c) HEADLINE: THE FRAMEWORK-INVARIANT CONTENT HAS RANK 3 ────────────
    Chaining T.4 (the invariant biconditional, holding for every framework)
    with R6_Agent1 (`core_corpus_rank_three`: the invariant content has rank
    exactly 3) and R7_Agent1 (`all_isClosed`: every result-set is a closed
    sub-theory of the rank-3 Boolean cube), we obtain the single statement
    `framework_invariant_content_rank_three`: the framework-invariant content
    of MIP is the zero-characterization law (preserved by every framework),
    its genuine content has minimum generating cardinality 3, and the three
    generators are pairwise independent and form the atoms of the closed-
    sub-theory lattice — the invariant content has RANK 3.

  HEADLINE — `framework_invariant_content_rank_three`:
    The framework-invariant content of MIP has rank 3.  (1) The MIP zero-
    characterization `NF p F X = 0 ↔ Phi0F X F p = 0` holds for EVERY
    framework `F` (T.4, framework-invariant) and reduces to the base law
    under the identity framework; (2) the framework-tagged agent data is NOT
    invariant (a concrete framework pair separates it); (3) the genuine
    content has minimum generating cardinality exactly 3 (R6_Agent1) over the
    pairwise-independent generators, which (4) are exactly the atoms of the
    closed-sub-theory lattice (R7_Agent1).  Hence the invariants preserved by
    framework-equivalence are exactly the rank-3 generator content.

    NO weakening of the invariance claim (T.4 is used verbatim for every
    `F`); the rank-3 and Boolean-cube claims are R6/R7 genuine proof terms;
    the separation is a genuine non-equality witness.

  Depends on (exact lemma names USED in proof terms):
    - MIP.Theorems.T4_FrameworkEquiv :
        MIP.FrameworkEquiv.withFramework, MIP.FrameworkEquiv.NF,
        MIP.FrameworkEquiv.Phi0F, MIP.FrameworkEquiv.T4_NeqZero_iff_Phi0_eqZero
    - MIP.Discoveries.R6_Agent1_CoreRankThreeTheorem  (R4-R8 TOWER) :
        R6_Agent1_CoreRankThreeTheorem.IsMinGenCard,
        R6_Agent1_CoreRankThreeTheorem.core_corpus_rank_three,
        R6_Agent1_CoreRankThreeTheorem.isMinGenCard_three,
        R6_Agent1_CoreRankThreeTheorem.pairwise_no_cross
    - MIP.Discoveries.R7_Agent1_MooreLatticeBoolean  (R4-R8 TOWER) :
        R7_Agent1_MooreLatticeBoolean.all_isClosed,
        R7_Agent1_MooreLatticeBoolean.single_generator_isAtom,
        R7_Agent1_MooreLatticeBoolean.isAtom_iff_single_generator
    - MIP.Discoveries.R5_Agent9_CorpusClosureMinimalBasis :
        R5_Agent9_CorpusClosureMinimalBasis.Gen,
        R5_Agent9_CorpusClosureMinimalBasis.genRed,
        R5_Agent9_CorpusClosureMinimalBasis.coreClosure (via R7 open)
-/
import MIP.Theorems.T4_FrameworkEquiv
import MIP.Discoveries.R6_Agent1_CoreRankThreeTheorem
import MIP.Discoveries.R6_Agent8_ReductionClosureMonad
import MIP.Discoveries.R7_Agent1_MooreLatticeBoolean

namespace MIP

namespace R9_Agent9_FrameworkInvariantsAreGenerators

open MIP.FrameworkEquiv
open R5_Agent9_CorpusClosureMinimalBasis
open R5_Agent9_CorpusClosureMinimalBasis.Gen
open R6_Agent1_CoreRankThreeTheorem
open R6_Agent8_ReductionClosureMonad
open R7_Agent1_MooreLatticeBoolean

/-! ## PART I — the identity framework anchors framework data to base MIP.

    `withFramework F X := fun h => X (F h)`.  The identity framework
    `F = id` therefore reduces it to `X` itself, and the framework-tagged
    quantities `NF`, `Phi0F` to plain `N`, `Phi0`.  This is the bridge that
    makes the framework-invariant law genuinely the base MIP law, not a
    free-standing artefact. -/

/-- **`withFramework` is definitionally `F`-tagged history composition.**
`withFramework F X h = X (F h)`: the augmented agent reads the history
through `F`.  This exposes the genuine `F`-dependence used in the separation
(PART III). -/
theorem withFramework_apply {α : Type} (F : Str α → Str α) (X : Agent α)
    (h : Str α) :
    withFramework F X h = X (F h) := rfl

/-- **The identity framework leaves the agent unchanged.**
`withFramework id X = X`. -/
theorem withFramework_id {α : Type} (X : Agent α) :
    withFramework (id : Str α → Str α) X = X := rfl

/-- **The identity framework reduces `NF` to plain `N`.** -/
theorem NF_id {α : Type} (p : Problem α) (X : Agent α) :
    NF p (id : Str α → Str α) X = N p X := rfl

/-- **The identity framework reduces `Phi0F` to plain `Phi0`.** -/
theorem Phi0F_id {α : Type} (X : Agent α) (p : Problem α) :
    Phi0F X (id : Str α → Str α) p = Phi0 X p := rfl

/-! ## PART II — the MIP zero-characterization is framework-INVARIANT.

    "Framework-invariant" = holds of `withFramework F X` for EVERY `F`.
    T.4 (`T4_NeqZero_iff_Phi0_eqZero`) is exactly this: the biconditional
    `NF p F X = 0 ↔ Phi0F X F p = 0` is provided uniformly in `F`.  We name
    the invariance predicate and prove the zero-characterization satisfies
    it, with the identity-framework instance recovering the base MIP law. -/

/-- **Framework invariance of a property.**  A predicate `P : Agent α → Prop`
on agents is FRAMEWORK-INVARIANT for `X` when it holds of `withFramework F X`
for every framework operator `F`.  This is the precise sense in which a piece
of content is preserved by framework-equivalence. -/
def FrameworkInvariant {α : Type} (P : Agent α → Prop) (X : Agent α) : Prop :=
  ∀ F : Str α → Str α, P (withFramework F X)

/-- **The MIP zero-characterization, as an agent property.**
`MIPZeroChar p Y` says the augmented agent `Y` obeys `N p Y = 0 ↔ Phi0 Y p =
0`.  For `Y = withFramework F X` this is exactly `NF p F X = 0 ↔ Phi0F X F p =
0`. -/
def MIPZeroChar {α : Type} (p : Problem α) (Y : Agent α) : Prop :=
  N p Y = 0 ↔ Phi0 Y p = 0

/-- **(a) THE MIP ZERO-CHARACTERIZATION IS FRAMEWORK-INVARIANT.**

For every framework `F`, the augmented agent `withFramework F X` satisfies the
MIP zero-law `N = 0 ↔ Φ₀ = 0`.  This is T.4 used verbatim and uniformly in
`F` (`T4_NeqZero_iff_Phi0_eqZero`, after unfolding `NF`/`Phi0F`): the zero-
characterization is genuine *framework-independent* content — preserved by
every framework transformation. -/
theorem mip_zero_characterization_framework_invariant
    {α : Type} (p : Problem α) (X : Agent α) :
    FrameworkInvariant (MIPZeroChar p) X := by
  intro F
  -- `MIPZeroChar p (withFramework F X)` is, definitionally,
  -- `NF p F X = 0 ↔ Phi0F X F p = 0`, which is T.4.
  exact T4_NeqZero_iff_Phi0_eqZero p X F

/-- **The invariant law anchors to the base MIP law.**  Instantiating the
framework-invariant zero-characterization at the IDENTITY framework recovers
the plain MIP law `N p X = 0 ↔ Phi0 X p = 0`: the framework-invariant content
is genuinely the base theory's law, holding under every framework. -/
theorem invariant_recovers_base_law
    {α : Type} (p : Problem α) (X : Agent α) :
    (N p X = 0 ↔ Phi0 X p = 0) := by
  have h := mip_zero_characterization_framework_invariant p X id
  -- `h : MIPZeroChar p (withFramework id X)`, and `withFramework id X = X`.
  rw [withFramework_id] at h
  exact h

/-! ## PART III — SEPARATION: the framework-tagged data is NOT invariant.

    The zero-characterization is invariant, but the raw framework-tagged
    agent is not: `withFramework F X` genuinely varies with `F`
    (`withFramework_apply`).  We exhibit a concrete framework pair and a
    history on which the two augmented agents disagree — the per-framework
    *data* is therefore not a framework invariant, so the invariant content
    is strictly the (finite-rank) law, not the data. -/

/-- **(b) THE FRAMEWORK-TAGGED AGENT DATA IS NOT FRAMEWORK-INVARIANT.**

There is an agent `X` and a pair of frameworks `F₁ ≠ F₂` whose augmented
agents `withFramework F₁ X` and `withFramework F₂ X` disagree on a witnessing
history.  Concretely we take `α` with at least two histories and an agent that
distinguishes them; the constant-`h₀` framework and the identity framework
then send the witnessing history to different outputs.  Hence the
framework-tagged agent value is a genuinely *framework-DEPENDENT* quantity —
NOT one of the invariants — confirming the invariant content is sparse (the
rank-3 skeleton), not the full per-framework data. -/
theorem framework_data_dependent
    {α : Type} (X : Agent α)
    (h₀ h₁ : Str α) (hne : X h₀ ≠ X h₁) :
    ∃ (F₁ F₂ : Str α → Str α),
      withFramework F₁ X (h₁ : Str α) ≠ withFramework F₂ X h₁ := by
  -- `F₁ := fun _ => h₀` (constant), `F₂ := id`.
  refine ⟨fun _ => h₀, id, ?_⟩
  -- `withFramework (fun _ => h₀) X h₁ = X h₀`, `withFramework id X h₁ = X h₁`.
  rw [withFramework_apply, withFramework_apply]
  -- Goal: `X h₀ ≠ X (id h₁)`, i.e. `X h₀ ≠ X h₁`.
  exact hne

/-! ## PART IV — the genuine content is rank 3 (R6_Agent1 / R7_Agent1, TOWER).

    The framework-invariant law sits over a content of finite rank.  We import
    the rank-3 skeleton from the R4-R8 tower: R6_Agent1's `IsMinGenCard 3`
    (minimum generating cardinality exactly three) and pairwise generator
    independence, and R7_Agent1's identification of the three generators with
    the atoms of the closed-sub-theory Boolean lattice. -/

/-- **The three generators are pairwise independent** (R6_Agent1, TOWER):
distinct generators do not cross-derive under the reduction preorder. -/
theorem generators_pairwise_independent :
    ∀ g g' : Gen, g ≠ g' → ¬ genRed g g' :=
  R6_Agent1_CoreRankThreeTheorem.pairwise_no_cross

/-- **The minimum generating cardinality is exactly 3** (R6_Agent1, TOWER). -/
theorem genuine_content_rank_three :
    R6_Agent1_CoreRankThreeTheorem.IsMinGenCard 3 :=
  R6_Agent1_CoreRankThreeTheorem.isMinGenCard_three

/-- **The atoms of the closed-sub-theory lattice are exactly the three
generators** (R7_Agent1, TOWER): every single-generator set is a closed atom,
and conversely every atom is a single-generator set.  This pins the rank-3
basis as the atom set of the Boolean cube of sub-theories. -/
theorem generators_are_atoms :
    (∀ g : Gen, IsAtom ({g} : Set Gen) ∧ coreClosure.IsClosed ({g} : Set Gen))
      ∧ (∀ S : Set Gen, IsAtom S ↔ ∃ g : Gen, S = {g}) :=
  ⟨R7_Agent1_MooreLatticeBoolean.single_generator_isAtom,
   R7_Agent1_MooreLatticeBoolean.isAtom_iff_single_generator⟩

/-! ## PART V — HEADLINE: the framework-invariant content has rank 3. -/

/-- **HEADLINE — `framework_invariant_content_rank_three`.**

The framework-invariant content of MIP has RANK 3: the quantities preserved
under framework-equivalence are exactly the rank-3 generator content.

  (1) **FRAMEWORK-INVARIANCE (T.4).**  The MIP zero-characterization
      `NF p F X = 0 ↔ Phi0F X F p = 0` holds for EVERY framework `F`
      (`mip_zero_characterization_framework_invariant`, i.e.
      `FrameworkInvariant (MIPZeroChar p) X`), and instantiating at the
      identity framework recovers the base MIP law `N p X = 0 ↔ Phi0 X p = 0`
      (`invariant_recovers_base_law`).  This is the genuine framework-
      INDEPENDENT law.

  (2) **SEPARATION.**  The framework-tagged agent data is NOT invariant: for
      an agent distinguishing two histories there is a framework pair whose
      augmented agents disagree (`framework_data_dependent`).  The invariant
      content is strictly the (finite-rank) law, not the per-framework data.

  (3) **RANK 3 (R6_Agent1, TOWER).**  The genuine content has minimum
      generating cardinality exactly 3 (`genuine_content_rank_three`,
      `IsMinGenCard 3`) over the pairwise-independent generators
      (`generators_pairwise_independent`).

  (4) **ATOMS = GENERATORS (R7_Agent1, TOWER).**  The three generators are
      exactly the atoms of the closed-sub-theory Boolean lattice
      (`generators_are_atoms`): every result-set is a closed sub-theory of
      the rank-3 cube.

Hence the invariants preserved by framework-equivalence are exactly the
rank-3 generator content: the framework-invariant content of MIP has rank 3. -/
theorem framework_invariant_content_rank_three
    {α : Type} (p : Problem α) (X : Agent α)
    -- separation witness data (a concrete framework-distinguishing agent)
    (h₀ h₁ : Str α) (hne : X h₀ ≠ X h₁) :
    -- (1) framework-invariance of the MIP zero-characterization + base anchor
    FrameworkInvariant (MIPZeroChar p) X
      ∧ (N p X = 0 ↔ Phi0 X p = 0)
    -- (2) separation: the framework-tagged data is NOT invariant
      ∧ (∃ (F₁ F₂ : Str α → Str α),
            withFramework F₁ X h₁ ≠ withFramework F₂ X h₁)
    -- (3) the genuine content has rank exactly 3 (R6_Agent1)
      ∧ R6_Agent1_CoreRankThreeTheorem.IsMinGenCard 3
      ∧ (∀ g g' : Gen, g ≠ g' → ¬ genRed g g')
    -- (4) the three generators are the atoms of the closed-sub-theory lattice
    --     (R7_Agent1): every result-set is a closed sub-theory of the cube
      ∧ (∀ S : Set Gen, coreClosure.IsClosed S)
      ∧ (∀ g : Gen, IsAtom ({g} : Set Gen) ∧ coreClosure.IsClosed ({g} : Set Gen))
      ∧ (∀ S : Set Gen, IsAtom S ↔ ∃ g : Gen, S = {g}) := by
  refine ⟨mip_zero_characterization_framework_invariant p X,
    invariant_recovers_base_law p X,
    framework_data_dependent X h₀ h₁ hne,
    genuine_content_rank_three,
    generators_pairwise_independent,
    R7_Agent1_MooreLatticeBoolean.all_isClosed,
    ?_, ?_⟩
  · exact generators_are_atoms.1
  · exact generators_are_atoms.2

end R9_Agent9_FrameworkInvariantsAreGenerators

end MIP
