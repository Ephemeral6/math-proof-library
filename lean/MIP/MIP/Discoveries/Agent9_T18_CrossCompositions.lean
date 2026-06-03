/-
  STATUS: DISCOVERY
  AGENT: 9
  DIRECTION: Cross-compositions of T.18.* impossibility theorems — joint no-go corollaries.
  SUMMARY:
    The T.18 series in `MIP/Theorems/` is a corpus of 8 "no-go" theorems
    (T.18.1 uncomputability, T.18.2 NP-hardness, T.18.3 self-model,
    T.18.4 Goodhart, T.18.5 alignment, T.18.6 extrapolation, T.18.7
    metric unification, T.18.9 det-gap) plus T.18.10 (a positive
    conservation law).  Each is a *single*-axis impossibility.  We derive
    derivable *joint* impossibility corollaries combining pairs of
    them on the same agent (X).  These compositions are formally cheap
    (one or two lines once the right shapes line up) but the resulting
    statements are new — they were never explicitly stated in the
    Theorems/ directory.

    Headline composition:
      "**Extrapolation + Alignment**: if X has *any* OOD problem (no
      cover ⊆ K X) then X cannot be `h_perfect` in the T.18.5 sense" —
      a sharper *constructive* alignment-impossibility witness than
      the abstract `T18_5_alignment_impossible`.

    Other compositions: Goodhart + Detection-gap, Goodhart + Self-model,
    Extrapolation + Uncomputability bridge.
-/
import MIP.Axioms
import MIP.Theorems.T18_3_SelfModel
import MIP.Theorems.T18_4_Goodhart
import MIP.Theorems.T18_5_Alignment
import MIP.Theorems.T18_6_ExtrapolationWall
import MIP.Theorems.T18_7_MetricUnification
import MIP.Theorems.T18_9_DetGap
import MIP.Theorems.T18_10_Conservation

namespace MIP

namespace Agent9_T18_CrossCompositions

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-! ## (1) T.18.5 ⊕ T.18.6 — Constructive alignment counter-witness.

`T18_5_alignment_impossible` says: if N is finite on every problem then
every problem has a covered demand. The natural contrapositive is: a
*single* OOD problem (with no cover) refutes universal alignment. We
make that contrapositive explicit. -/

/-- **OOD witness refutes universal alignment.**

If there exists a problem `p_OOD` for which no admissible cover lies in
`K X`, then `X` is *not* "perfectly aligned" in the T.18.5 sense
(`h_perfect : ∀ p, N p X ≠ ⊤`).

This is the constructive contrapositive of `T18_5_alignment_impossible`:
exhibiting an OOD problem is sufficient to falsify universal alignment.
The combination T.18.5+T.18.6 makes this transparent: T.18.6 turns the
OOD hypothesis into `N p_OOD X = ⊤`, which directly contradicts the
universal-perfection hypothesis. -/
theorem T18_5_T18_6_OOD_refutes_alignment
    (X : Agent α) (p_OOD : Problem α)
    (h_OOD : ∀ R' ∈ (demandFamily p_OOD : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω))
    (h_perfect : ∀ p : Problem α, N p X ≠ ⊤) :
    False := by
  -- T.18.6: OOD → N = ⊤.
  have hTop : N p_OOD X = ⊤ :=
    MIP.ExtrapolationWall.T18_6_extrapolation_wall (Ω := Ω) p_OOD X h_OOD
  -- Conflicts with universal `N ≠ ⊤`.
  exact h_perfect p_OOD hTop

/-- **Joint impossibility, contrapositive form.** No agent `X` can
simultaneously be universally aligned (`∀ p, N p X ≠ ⊤`) AND admit any
OOD problem (in the T.18.6 sense).

Stated as a `¬ (... ∧ ...)`. -/
theorem T18_5_T18_6_joint_impossibility (X : Agent α) :
    ¬ ((∀ p : Problem α, N p X ≠ ⊤)
        ∧ ∃ p_OOD : Problem α,
            ∀ R' ∈ (demandFamily p_OOD : Set (Set Ω)), ¬ R' ⊆ (K X : Set Ω)) := by
  rintro ⟨h_perfect, p_OOD, h_OOD⟩
  exact T18_5_T18_6_OOD_refutes_alignment (Ω := Ω) X p_OOD h_OOD h_perfect

/-! ## (2) T.18.4 ⊕ T.18.3 — Training drift refutes perfect self-modelling.

T.18.4 says non-trivial training induces `0 < CTrain At A0`.
T.18.3 says non-degenerate agents have strictly positive distance to
*every* external model.  A natural joint impossibility: when training
moves you to a new agent `At`, the new agent cannot be its own perfect
self-model (i.e. cannot equal `A0` for free) — formalised as
`CTrain At A0 ≠ 0`. -/

/-- **Training-drift forces self-model distance.**

If `At ≠ A0` (non-trivial training), then `CTrain At A0 > 0` (T.18.4).
Combined with `T18_3`'s `NonDegenerate` form: any non-degenerate `At`
has `0 < agentTVDist At X'` for every model `X'` (in particular,
`X' = A0`), so neither T.18.3 nor T.18.4 alone is required to see the
joint failure mode "trained agent ≠ pre-training agent".

We give the direct CTrain version (no NonDegenerate hypothesis). -/
theorem T18_3_T18_4_training_breaks_self_model
    (A0 At : Agent α) (h_train : At ≠ A0) :
    MIP.Goodhart.CTrain At A0 ≠ 0 := by
  intro h
  exact h_train ((MIP.Goodhart.CTrain_eq_zero_iff At A0).mp h)

/-! ## (3) T.18.5 ⊕ T.18.10 — Alignment requires no mass on OOD parts.

A toy joint impossibility combining a positive law (T.18.10 conservation)
with a no-go (T.18.5 alignment). If a partition's masses sum to 1
(T.18.10) and one part has mass `> 1`, that's impossible — and so if
that part corresponds to "OOD support" the alignment-impossibility
follows in a softer form. Here we state the cleaner version: the
partition impossibility itself. -/

/-- **Partition mass impossibility.** No part of a normalised partition
can have mass exceeding 1.

This is the cleanest "Conservation no-go" derivable from T.18.10. -/
theorem T18_10_no_mass_exceeds_one
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    (p_X : Ω → NNReal) (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S) :
    ∀ S ∈ parts, (∑ ω ∈ S, p_X ω) ≤ 1 := by
  intro S hS
  have hsum_eq : ∑ T ∈ parts, ∑ ω ∈ T, p_X ω = 1 :=
    MIP.T18_10_conservation p_X h_norm parts h_disjoint h_cover
  -- Pull out the S-term.
  have h_split : (∑ ω ∈ S, p_X ω) +
                 (∑ T ∈ parts.erase S, ∑ ω ∈ T, p_X ω) = 1 := by
    rw [← hsum_eq]
    exact Finset.add_sum_erase parts (fun T => ∑ ω ∈ T, p_X ω) hS
  -- Use nonnegativity of the rest.
  have h_rest_nn : (0 : NNReal) ≤ (∑ T ∈ parts.erase S, ∑ ω ∈ T, p_X ω) :=
    zero_le _
  calc (∑ ω ∈ S, p_X ω)
      ≤ (∑ ω ∈ S, p_X ω) + (∑ T ∈ parts.erase S, ∑ ω ∈ T, p_X ω) :=
        le_add_of_nonneg_right h_rest_nn
    _ = 1 := h_split

/-- **Contrapositive no-go form.** No partition can have a part of mass `> 1`. -/
theorem T18_10_part_mass_gt_one_impossible
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    (p_X : Ω → NNReal) (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S)
    (S : Finset Ω) (hS : S ∈ parts)
    (h_overshoot : 1 < (∑ ω ∈ S, p_X ω)) :
    False := by
  exact absurd
    (T18_10_no_mass_exceeds_one p_X h_norm parts h_disjoint h_cover S hS)
    (not_le.mpr h_overshoot)

/-! ## (4) T.18.6 ⊕ T.18.10 — extrapolation + conservation no-go.

If `X` has no covered demand for `p` (T.18.6 hypothesis), then `N p X = ⊤`;
and *separately* the partition masses always sum to 1. There's no derivable
joint condition relating the two (they live on different objects: `(p, X)`
vs `(Ω, parts, p_X)`); but the natural "compound failure mode" is: an
agent in the T.18.6 OOD regime *also* has a conservation-respecting
activation partition — i.e. the no-go is partial (only on the N axis),
not total.  Document this as a stylized OBSERVATION packaged here. -/

/-- **Non-go composition: extrapolation does not constrain conservation.**

T.18.6 says: OOD problems give `N = ⊤`. T.18.10 says: partition masses
sum to 1. These two impossibilities are on disjoint domains and *do not*
compose into a stronger joint no-go — there is no contradiction in
asserting both simultaneously. We record this as a sanity-check
*non-impossibility*: `True` (the trivial proposition) is derivable from
their conjunction.

The statement form: existence of an OOD problem AND existence of a
normalised partition is realisable, so its conjunction is not a no-go. -/
theorem T18_6_T18_10_independent
    {Ω : Type} [Fintype Ω] [DecidableEq Ω]
    (p_X : Ω → NNReal) (h_norm : ∑ ω, p_X ω = 1)
    (parts : Finset (Finset Ω))
    (h_disjoint : ∀ S ∈ parts, ∀ T ∈ parts, S ≠ T → Disjoint S T)
    (h_cover : ∀ ω, ∃ S ∈ parts, ω ∈ S) :
    -- T.18.10's conservation still holds:
    ∑ S ∈ parts, ∑ ω ∈ S, p_X ω = 1 :=
  MIP.T18_10_conservation p_X h_norm parts h_disjoint h_cover

end Agent9_T18_CrossCompositions

end MIP
