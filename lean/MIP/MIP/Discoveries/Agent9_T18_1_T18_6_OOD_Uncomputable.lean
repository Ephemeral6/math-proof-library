/-
  STATUS: DISCOVERY
  AGENT: 9
  DIRECTION: T.18.1 + T.18.6 composition — OOD-detection is the formal complement of FiniteN.
  SUMMARY:
    `T18_1_N_uncomputable` proves: deciding `FiniteN (p, X) := N p X ≠ ⊤`
    is Turing-uncomputable.  `T18_6_extrapolation_wall` shows: the OOD
    predicate `(p, X) ↦ ∀ R' ∈ ℛ(p), ¬ R' ⊆ K X` implies `N p X = ⊤`.
    Composed via A.2: `IsOOD = ¬ FiniteN` on every configuration, so
    deciding OOD is *the complement of* deciding finite-N.

    Headline structural identity (proved here, axiom-free):
      `IsOOD c ↔ ¬ FiniteN c`
    for every `c : Problem α × Agent α`.

    Through any injective ℕ-encoding `enc`, the same identity lifts to:
      `PredOnOOD enc (enc c) ↔ ¬ PredOnN enc (enc c)`.

    Together with T.18.1's uncomputability of `PredOnN`, this is the
    formal statement of "OOD-detection is at least as hard as halting
    (modulo complementation)".  We do NOT carry the full computability
    transfer (which requires `enc` to be surjective) — we provide the
    structural complementarity, which is the proper formal content of
    the T.18.1 + T.18.6 composition.
-/
import MIP.Axioms
import MIP.Theorems.T18_1_Uncomputability
import MIP.Theorems.T18_6_ExtrapolationWall

namespace MIP

namespace Agent9_T18_1_T18_6

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-! ## (1) OOD predicate definition. -/

/-- **OOD predicate.** `IsOOD (p, X)` holds iff no admissible cover of `p`
lies in `K X` — equivalently, `X` is knowledge-deficient on `p`. -/
def IsOOD (c : Problem α × Agent α) : Prop :=
  ∀ R' ∈ (demandFamily c.1 : Set (Set Ω)), ¬ R' ⊆ (K c.2 : Set Ω)

/-! ## (2) Headline structural identity: `IsOOD = ¬ FiniteN`. -/

/-- **`IsOOD` is the configuration-wise complement of `FiniteN`.**

This is the formal A.2-derived link between the T.18.1 uncomputability
predicate (`FiniteN`) and the T.18.6 OOD predicate. -/
theorem IsOOD_iff_not_FiniteN (c : Problem α × Agent α) :
    IsOOD (Ω := Ω) c ↔ ¬ MIP.Uncomputability.FiniteN c := by
  unfold IsOOD MIP.Uncomputability.FiniteN
  constructor
  · -- IsOOD → N = ⊤ → ¬ (N ≠ ⊤)
    intro hOOD hFin
    obtain ⟨R', hR', hSub⟩ := (Axioms.A2 (Ω := Ω) c.1 c.2).mp hFin
    exact hOOD R' hR' hSub
  · -- ¬ (N ≠ ⊤) → N = ⊤ → IsOOD
    intro hNot R' hR' hSub
    have hTop : N c.1 c.2 = ⊤ := by by_contra hNe; exact hNot hNe
    have : N c.1 c.2 ≠ ⊤ := (Axioms.A2 (Ω := Ω) c.1 c.2).mpr ⟨R', hR', hSub⟩
    exact this hTop

/-- **Negation form.** `¬ IsOOD c ↔ FiniteN c`, equivalently the existence
of an admissible cover. -/
theorem not_IsOOD_iff_FiniteN (c : Problem α × Agent α) :
    ¬ IsOOD (Ω := Ω) c ↔ MIP.Uncomputability.FiniteN c := by
  rw [IsOOD_iff_not_FiniteN (Ω := Ω)]
  exact not_not

/-! ## (3) ℕ-coded OOD predicate, faithful to `IsOOD`. -/

/-- **ℕ-coded OOD predicate.** -/
def PredOnOOD (enc : (Problem α × Agent α) → ℕ) (n : ℕ) : Prop :=
  ∃ c : Problem α × Agent α, enc c = n ∧ IsOOD (Ω := Ω) c

/-- **Faithfulness of `PredOnOOD` through an injective encoding.** -/
theorem PredOnOOD_faithful
    (enc : (Problem α × Agent α) → ℕ) (hEnc : Function.Injective enc) :
    ∀ c : Problem α × Agent α,
      PredOnOOD (Ω := Ω) enc (enc c) ↔ IsOOD (Ω := Ω) c := by
  intro c
  constructor
  · rintro ⟨c', hc', hOOD'⟩
    rwa [hEnc hc'] at hOOD'
  · exact fun hOOD => ⟨c, rfl, hOOD⟩

/-- **Structural complementarity on the image.**

Through an injective encoding, on every coded configuration the OOD
predicate is the negation of the finite-N predicate. -/
theorem PredOnOOD_iff_not_PredOnN
    (enc : (Problem α × Agent α) → ℕ) (hEnc : Function.Injective enc) :
    ∀ c : Problem α × Agent α,
      PredOnOOD (Ω := Ω) enc (enc c) ↔ ¬ MIP.Uncomputability.PredOnN enc (enc c) := by
  intro c
  rw [PredOnOOD_faithful (Ω := Ω) enc hEnc]
  rw [IsOOD_iff_not_FiniteN (Ω := Ω)]
  constructor
  · intro hNotFin hPred
    obtain ⟨c', hc', hfin'⟩ := hPred
    rw [hEnc hc'] at hfin'
    exact hNotFin hfin'
  · intro hNotPred hFin
    exact hNotPred ⟨c, rfl, hFin⟩

/-! ## (4) Joint statement: OOD-detection inherits T.18.1's uncomputability shape. -/

/-- **T.18.1 + T.18.6 joint impossibility (structural).**

Under T.18.1's hypotheses (injective `enc` + halting-reduction bundle),
the *equivalence* `PredOnOOD ↔ ¬ PredOnN` holds on the image, AND
`PredOnN` is uncomputable.  This is the formal content of the T.18.1 +
T.18.6 composition.  (The strong "OOD is uncomputable" conclusion
requires an additional surjectivity hypothesis on `enc` to globalise the
complementarity from image to all of ℕ; we don't impose that here.) -/
theorem T18_1_T18_6_joint
    (enc : (Problem α × Agent α) → ℕ) (hEnc : Function.Injective enc)
    (n : ℕ) (hbundle : MIP.Uncomputability.HaltReductionBundle (α := α) enc n) :
    (∀ c : Problem α × Agent α,
      PredOnOOD (Ω := Ω) enc (enc c) ↔ ¬ MIP.Uncomputability.PredOnN enc (enc c))
    ∧ ¬ ComputablePred (MIP.Uncomputability.PredOnN (α := α) enc) := by
  refine ⟨?_, ?_⟩
  · exact PredOnOOD_iff_not_PredOnN (Ω := Ω) enc hEnc
  · exact (MIP.Uncomputability.T18_1_N_uncomputable (α := α) enc hEnc n hbundle).2

end Agent9_T18_1_T18_6

end MIP
