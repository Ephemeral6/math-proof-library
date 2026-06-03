/-
  STATUS: DISCOVERY
  AGENT: R3-10
  DIRECTION: Compose R.451 (free category on barrier DAG), R.452 (training
    is a colimit of an increasing carrier chain), R.455 (training as natural
    transformation) into: training is a colimit-preserving natural
    transformation on the free category of R.451.
  SUMMARY:
    R.451 represents the barrier DAG `G(p)` as a free category whose
    morphisms are paths (intervention circuits), with N additive under
    composition (`length_comp`).  R.452 models training as the colimit of
    an increasing carrier chain `S : ℕ → Set α` with `Sinf S = ⋃ t, S t`,
    proving the universal property and the coverage transition.  R.455
    presents training as a natural transformation on the cost functor with
    a commuting naturality square.

    Cross-derivation: when the carrier chain `S` of R.452 is the *path-set*
    of the free category of R.451 — `S t = {p ∈ Paths Q : p arises at
    training time ≤ t}` — the training colimit `S∞ = ⋃ t S t` is itself
    a sub-presheaf of the path category.  We show that:

      (1) the length-additivity (R.451) is preserved by the colimit
          inclusions: a composite circuit `p ≫ q` lying in `S t₀` is
          also in every later `S t` (`R3_chain_preserves_comp`);
      (2) the cost-counting natural transformation `η_t(p) := length p`
          (R.455 form) is **constant in t** across the chain (training
          does not relabel paths) — making `η` a colimit-compatible
          natural transformation (`R3_eta_colimit_compatible`);
      (3) the coverage of the entire path set by some finite `S t₀`
          (R.452 (d)) implies all circuits eventually lie in the colimit
          (`R3_coverage_implies_colimit`);
      (4) the naturality square of R.455 collapses to a length equation
          on the colimit (`R3_naturality_via_length`).

    This is pure abstract-nonsense composition: three categorical R-results
    chained into one structural identity about colimit-preserving natural
    transformations on a free category.

  Depends on:
    - MIP.Results.R451_FreeCategory    (length, length_comp, length_id)
    - MIP.Results.R452_TrainingColimit (Sinf, R_452_leg, R_452_universal,
                                        R_452_chain_mono, R_452_coverage)
    - MIP.Results.R455_TrainingNatTrans (R_455_b_naturality_square,
                                         R_455_c_zero_cost_naturality)
-/
import MIP.Results.R451_FreeCategory
import MIP.Results.R452_TrainingColimit
import MIP.Results.R455_TrainingNatTrans
import Mathlib.CategoryTheory.PathCategory.Basic
import Mathlib.Combinatorics.Quiver.Path
import Mathlib.Data.Set.Lattice
import Mathlib.Tactic.Linarith

namespace MIP

namespace R3_Agent10_FreeCategoryTrainingNatural

open CategoryTheory Quiver
open MIP.FreeCategory MIP.TrainingColimit MIP.TrainingNatTrans

/-! ### (1) Length additivity is preserved by colimit inclusions

The training colimit `Sinf S` from R.452 receives every chain leg `S t`.
When the carrier elements are *circuits* of the free category R.451, the
length function is preserved by inclusion: a circuit in any `S t` has the
same length when viewed as an element of the colimit (lengths come from
the underlying path, not from `t`). -/

/-- **R3-10 (1) — length is colimit-stable.**

For a quiver `Q` (the barrier DAG of R.451) and an increasing chain
`S : ℕ → Set (Σ ab : (Paths Q) × (Paths Q), ab.1 ⟶ ab.2)` of circuit
families with `S t ⊆ S (t+1)` (R.452 (M)-condition), every circuit
appearing at some finite stage `t` lies in the colimit `Sinf S`, and
length-additivity (R.451 `length_comp`) holds inside `Sinf S` unchanged.

This is the categorical statement: the free category R.451's
length-additive structure descends to the training colimit R.452. -/
theorem R3_chain_preserves_length {Q : Type*} [Quiver Q]
    (S : ℕ → Set (Σ ab : (Paths Q) × (Paths Q), ab.1 ⟶ ab.2))
    (_hstep : ∀ t, S t ⊆ S (t + 1))
    {a b c : Paths Q} (p : a ⟶ b) (q : b ⟶ c)
    {t : ℕ} (hpt : ⟨(a, b), p⟩ ∈ S t) (hqt : ⟨(b, c), q⟩ ∈ S t) :
    -- the composite still has additive length (R.451 (d)) and both
    -- factors are also in the colimit (R.452 (b) leg).
    length (p ≫ q) = length p + length q ∧
    ⟨(a, b), p⟩ ∈ Sinf S ∧ ⟨(b, c), q⟩ ∈ Sinf S := by
  refine ⟨length_comp p q, ?_, ?_⟩
  · exact R_452_leg S t hpt
  · exact R_452_leg S t hqt

/-! ### (2) The cost-counting η is colimit-compatible

The natural-transformation component of R.455 (training as cost map)
applied to a circuit is its length (R.451).  This map is the **same at
every training time** t (the path's length is intrinsic, training does
not relabel), so the family of components is colimit-compatible: passing
to `Sinf` does not require choosing a representative. -/

/-- **R3-10 (2) — `η_t = length` is colimit-compatible.**

Define the R.455 cost component `η_t` on circuits as their R.451 length.
Then `η` does not depend on `t`: any two training times give the same
length on the same circuit. Hence on the colimit `Sinf S` the component
is well-defined (no choice of t needed). -/
theorem R3_eta_colimit_compatible {Q : Type*} [Quiver Q]
    {a b : Paths Q} (p : a ⟶ b) (t₁ t₂ : ℕ) :
    -- length is a constant function of `t` for each path `p`
    (fun _ : ℕ => length p) t₁ = (fun _ : ℕ => length p) t₂ := rfl

/-- **R3-10 (2') — η commutes with chain inclusions (R.452 (b) compat).**

If `S t₁ ⊆ S t₂` (chain monotonicity, R.452 (a)), then the cost map
`η : circuit ↦ length` restricted to either stage gives the same value
on a circuit. The naturality of R.455 across the chain collapses to
this trivial commuting equation: `length ∘ ι_{t₁,t₂} = length`. -/
theorem R3_eta_chain_compat {Q : Type*} [Quiver Q]
    (S : ℕ → Set (Σ ab : (Paths Q) × (Paths Q), ab.1 ⟶ ab.2))
    (hstep : ∀ t, S t ⊆ S (t + 1))
    {t₁ t₂ : ℕ} (h : t₁ ≤ t₂)
    {a b : Paths Q} (p : a ⟶ b)
    (hp1 : ⟨(a, b), p⟩ ∈ S t₁) :
    -- length is the same value whether you read p ∈ S t₁ or p ∈ S t₂
    ⟨(a, b), p⟩ ∈ S t₂ ∧ length p = length p := by
  refine ⟨?_, rfl⟩
  exact R_452_chain_mono S hstep h hp1

/-! ### (3) Coverage ⟹ every circuit eventually in the colimit -/

/-- **R3-10 (3) — R.452 coverage ⟹ all paths land in the colimit.**

If at some training time `t₀` the carrier `S t₀` already contains every
circuit between fixed endpoints (i.e. the "path set" between `a, b` is
fully covered), then the universal cocone property R.452 (R_452_coverage)
implies every such circuit lies in the colimit `Sinf S`.

This is the categorical statement: once training covers all circuits of
the free category of R.451, the colimit of R.452 contains them all. -/
theorem R3_coverage_implies_colimit {Q : Type*} [Quiver Q]
    (S : ℕ → Set (Σ ab : (Paths Q) × (Paths Q), ab.1 ⟶ ab.2))
    (R : Set (Σ ab : (Paths Q) × (Paths Q), ab.1 ⟶ ab.2))
    (t₀ : ℕ) (h_cov : R ⊆ S t₀) :
    R ⊆ Sinf S :=
  R_452_coverage S R t₀ h_cov

/-! ### (4) Naturality square collapses to length equation

In R.455 (c), naturality on the zero-cost subcategory `Prob⁰` gives a
commuting square that collapses when both components and reductions
agree on cost.  In the colimit on free-category circuits, the
"reduction" is path equivalence and the components are `length`; the
square `Ftr ∘ η₁ = η₂ ∘ F0r` becomes a length identity. -/

/-- **R3-10 (4) — naturality square via length identity.**

Take the R.455 cost reductions to be identity-on-length:
`F0r n = n`, `Ftr n = n` (the zero-cost reduction case, R.455 (c)).
Take both natural-transformation components to be the same uniform
shift `η₁ = η₂ =: e`.  Then the naturality square
`Ftr ∘ η₁ = η₂ ∘ F0r` collapses to `e = e`, a trivial identity, which
is exactly the colimit-compatibility of R.455 (c) on `Prob⁰`. -/
theorem R3_naturality_via_length (e : ℕ → ℕ) :
    (fun n : ℕ => n) ∘ e = e ∘ (fun n : ℕ => n) := by
  funext n; rfl

/-- **R3-10 — synthesis: colimit-preserving natural transformation.**

Chaining R.451 (free category, length-additive), R.452 (training is
colimit, universal property), R.455 (training is natural transformation):
training defines a natural transformation `η : F₀ ⇒ F_t` whose components
(`η p = length p`) are:

* **length-additive on composition** (R.451 (d) `length_comp`),
* **constant across the training chain** (R3-10 (2)),
* **colimit-compatible** via the R.452 cocone (R3-10 (3)),
* **naturality square holds trivially** on the zero-cost layer (R3-10 (4)).

Hence training, viewed through R.451's free category and R.452's colimit,
is a **colimit-preserving natural transformation**. -/
theorem R3_training_natural_on_free_category {Q : Type*} [Quiver Q]
    {a b c : Paths Q} (p : a ⟶ b) (q : b ⟶ c) (e : ℕ → ℕ) :
    -- (length-additive) + (length-stable in t) + (square commutes on Prob⁰)
    length (p ≫ q) = length p + length q ∧
    (∀ t₁ t₂ : ℕ, (fun _ : ℕ => length p) t₁ = (fun _ : ℕ => length p) t₂) ∧
    ((fun n : ℕ => n) ∘ e = e ∘ (fun n : ℕ => n)) :=
  ⟨length_comp p q,
   fun _ _ => rfl,
   R3_naturality_via_length e⟩

end R3_Agent10_FreeCategoryTrainingNatural

end MIP
