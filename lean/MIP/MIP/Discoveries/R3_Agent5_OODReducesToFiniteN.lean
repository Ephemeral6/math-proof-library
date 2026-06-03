/-
  STATUS: DISCOVERY
  AGENT: R3 Agent 5
  DIRECTION: T.18.1 + T.18.6 — FiniteN ≤₀ OOD strengthened form (distinct from R2 Agent 9).

  SUMMARY:
    R2 Agent 9 (`Agent9_T18_1_T18_6_OOD_Uncomputable.lean`) established the
    *structural* identity `IsOOD c ↔ ¬ FiniteN c`. That file stops at the
    image-level complementarity and explicitly does NOT carry the
    computability transfer.

    This file *closes that gap* under the natural surjectivity hypothesis on
    `enc`. Concretely, we show:

    1. The OOD-set (as a subset of `Problem α × Agent α`) equals the
       complement of the FiniteN-set: `{c | IsOOD c} = {c | ¬ FiniteN c}`.
    2. On the `enc`-image, `PredOnOOD` and `PredOnN` are *complementary*
       predicates on ℕ — i.e. exactly one of them holds at every coded
       point.
    3. Under surjectivity of `enc` (the "every ℕ-code is a real config" axis
       of T.18.1's setting), `PredOnOOD enc = fun n => ¬ PredOnN enc n` as
       predicates on all of ℕ. Hence `PredOnOOD` is computable iff
       `PredOnN` is — and since the latter is uncomputable (T.18.1),
       **OOD-detection on the ℕ-coded configurations is also uncomputable**.
    4. **FiniteN reduces to OOD via complementation** at the structural
       level: many-one reductions between a predicate and its complement
       are routine, so finiteN ≤₀ ¬OOD ≤₀ OOD when OOD's complement is
       computable — but the cleaner *positive* form is the equivalence we
       give below, which is the strengthened form requested.

  R-DEPS:
    • MIP.Theorems.T18_1_Uncomputability (FiniteN, PredOnN, T18_1_N_uncomputable)
    • MIP.Theorems.T18_6_ExtrapolationWall (T18_6_extrapolation_wall)
    • MIP.Axioms.A2 (cover ↔ N finite)
-/
import MIP.Axioms
import MIP.Theorems.T18_1_Uncomputability
import MIP.Theorems.T18_6_ExtrapolationWall

namespace MIP

namespace R3_Agent5_OODReducesToFiniteN

open MIP.Axioms

variable {α : Type} {Ω : Type}

/-! ## OOD predicate (re-stated locally to avoid hard-import dependency on R2). -/

/-- **OOD predicate.** `IsOOD c` iff no admissible cover of `c.1` lies in `K c.2`. -/
def IsOOD (c : Problem α × Agent α) : Prop :=
  ∀ R' ∈ (demandFamily c.1 : Set (Set Ω)), ¬ R' ⊆ (K c.2 : Set Ω)

/-- **ℕ-coded OOD predicate.** -/
def PredOnOOD (enc : (Problem α × Agent α) → ℕ) (n : ℕ) : Prop :=
  ∃ c : Problem α × Agent α, enc c = n ∧ IsOOD (Ω := Ω) c

/-! ## (1) Set-level complementarity: `OODSet = (FiniteN-set)ᶜ`. -/

/-- **Strengthened form #1 — set-level complementarity.**
The OOD set and the FiniteN set are *literal* complements in
`Problem α × Agent α`. -/
theorem OODSet_eq_compl_FiniteN :
    {c : Problem α × Agent α | IsOOD (Ω := Ω) c}
      = {c | MIP.Uncomputability.FiniteN c}ᶜ := by
  ext c
  simp only [Set.mem_setOf_eq, Set.mem_compl_iff]
  constructor
  · intro hOOD hFin
    obtain ⟨R', hR', hSub⟩ := (Axioms.A2 (Ω := Ω) c.1 c.2).mp hFin
    exact hOOD R' hR' hSub
  · intro hNotFin R' hR' hSub
    apply hNotFin
    show N c.1 c.2 ≠ ⊤
    exact (Axioms.A2 (Ω := Ω) c.1 c.2).mpr ⟨R', hR', hSub⟩

/-- **Strengthened form #2 — pointwise complementarity.**
`IsOOD c ↔ ¬ FiniteN c` (the R2 Agent 9 identity re-derived from set-level form). -/
theorem IsOOD_iff_not_FiniteN (c : Problem α × Agent α) :
    IsOOD (Ω := Ω) c ↔ ¬ MIP.Uncomputability.FiniteN c := by
  have h := OODSet_eq_compl_FiniteN (Ω := Ω) (α := α)
  have := congrArg (fun S => c ∈ S) h
  simpa using this

/-! ## (2) ℕ-image complementarity. -/

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

/-- **`PredOnOOD` and `PredOnN` are complementary on the image of `enc`.** -/
theorem PredOnOOD_iff_not_PredOnN_on_image
    (enc : (Problem α × Agent α) → ℕ) (hEnc : Function.Injective enc) :
    ∀ c : Problem α × Agent α,
      PredOnOOD (Ω := Ω) enc (enc c) ↔ ¬ MIP.Uncomputability.PredOnN enc (enc c) := by
  intro c
  rw [PredOnOOD_faithful (Ω := Ω) enc hEnc, IsOOD_iff_not_FiniteN (Ω := Ω)]
  constructor
  · intro hNotFin hPred
    obtain ⟨c', hc', hFin'⟩ := hPred
    rw [hEnc hc'] at hFin'
    exact hNotFin hFin'
  · intro hNotPred hFin
    exact hNotPred ⟨c, rfl, hFin⟩

/-! ## (3) **The strengthening over R2 Agent 9**: under surjectivity, global complementarity. -/

/-- **Global complementarity under surjective + injective `enc`.**

When `enc` is bijective onto ℕ (the "every ℕ-code is a real configuration"
hypothesis), `PredOnOOD` and `PredOnN` are exactly each other's
complements as predicates on *all* of ℕ. -/
theorem PredOnOOD_eq_compl_PredOnN
    (enc : (Problem α × Agent α) → ℕ)
    (hEnc : Function.Injective enc)
    (hSurj : Function.Surjective enc) :
    ∀ n : ℕ, PredOnOOD (Ω := Ω) enc n ↔ ¬ MIP.Uncomputability.PredOnN enc n := by
  intro n
  obtain ⟨c, hc⟩ := hSurj n
  subst hc
  exact PredOnOOD_iff_not_PredOnN_on_image (Ω := Ω) enc hEnc c

/-! ## (4) **FiniteN ≤₀ OOD** — many-one reduction via complementation. -/

/-- **Computability of `PredOnOOD` ↔ Computability of `PredOnN`.**

Under bijective encoding, deciding OOD is *exactly* deciding the
complement of FiniteN. So `PredOnOOD` is computable iff `PredOnN` is. -/
theorem PredOnOOD_computable_iff_PredOnN_computable
    (enc : (Problem α × Agent α) → ℕ)
    (hEnc : Function.Injective enc) (hSurj : Function.Surjective enc) :
    ComputablePred (PredOnOOD (Ω := Ω) enc)
      ↔ ComputablePred (MIP.Uncomputability.PredOnN (α := α) enc) := by
  -- Both predicates differ by negation on the whole of ℕ, and negation
  -- preserves computability.
  have hcompl :
      PredOnOOD (Ω := Ω) enc = fun n => ¬ MIP.Uncomputability.PredOnN enc n := by
    funext n
    exact propext (PredOnOOD_eq_compl_PredOnN (Ω := Ω) enc hEnc hSurj n)
  constructor
  · intro h
    rw [hcompl] at h
    -- `h` says `¬P` is computable; apply `not` again to get `¬¬P` and use
    -- the propositional equivalence with `P` to transport.
    have hnn := ComputablePred.not h
    -- `hnn : ComputablePred (fun n => ¬¬PredOnN enc n)`. Rewrite via `not_not`.
    have heq :
        (fun n => ¬¬MIP.Uncomputability.PredOnN enc n)
          = MIP.Uncomputability.PredOnN enc := by
      funext n; exact propext not_not
    rw [heq] at hnn
    exact hnn
  · intro h
    rw [hcompl]
    exact ComputablePred.not h

/-- **R3 Agent 5 headline (this file): OOD-detection is uncomputable**.

Composes T.18.1 (uncomputability of `PredOnN`) with the global
complementarity of §(3) above. Under bijective encoding `enc` and the
halting-reduction bundle, `PredOnOOD` is itself uncomputable. This is
the strengthened "FiniteN reduces to OOD" form. -/
theorem T18_1_T18_6_OOD_uncomputable
    (enc : (Problem α × Agent α) → ℕ)
    (hEnc : Function.Injective enc) (hSurj : Function.Surjective enc)
    (n : ℕ) (hbundle : MIP.Uncomputability.HaltReductionBundle (α := α) enc n) :
    ¬ ComputablePred (PredOnOOD (Ω := Ω) enc) := by
  intro hcomp
  -- The bridge: PredOnOOD computable ⟹ PredOnN computable.
  have hPN :
      ComputablePred (MIP.Uncomputability.PredOnN (α := α) enc) :=
    (PredOnOOD_computable_iff_PredOnN_computable (Ω := Ω)
      enc hEnc hSurj).mp hcomp
  -- T.18.1: PredOnN is *not* computable.
  exact
    (MIP.Uncomputability.T18_1_N_uncomputable (α := α) enc hEnc n hbundle).2 hPN

/-- **Equivalent: FiniteN-detection many-one reduces to OOD-detection**
under bijective encoding.

Computability of OOD would imply computability of FiniteN, so any
"oracle" for OOD lets us decide FiniteN — i.e. `FiniteN ≤ OOD` in the
strong sense that we can answer FiniteN by consulting OOD and negating. -/
theorem FiniteN_decidable_from_OOD_decidable
    (enc : (Problem α × Agent α) → ℕ)
    (hEnc : Function.Injective enc) (hSurj : Function.Surjective enc)
    (h_OOD_dec : ComputablePred (PredOnOOD (Ω := Ω) enc)) :
    ComputablePred (MIP.Uncomputability.PredOnN (α := α) enc) :=
  (PredOnOOD_computable_iff_PredOnN_computable (Ω := Ω) enc hEnc hSurj).mp h_OOD_dec

end R3_Agent5_OODReducesToFiniteN

end MIP
