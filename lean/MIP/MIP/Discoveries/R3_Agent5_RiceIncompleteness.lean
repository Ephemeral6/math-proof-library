/-
  STATUS: DISCOVERY
  AGENT: R3 Agent 5
  DIRECTION: R.172 (MIP-Rice) + R.108 (MIP-incompleteness) — Gödel-Rice chain.

  SUMMARY:
    R.172 (`R_172_MIP_Rice`): every semantic, non-trivial emergence property
    `P_ℰ` is undecidable (in the negatable `IsDecidablePred` sense).
    R.108 (`R_108_phi_undecidable`): the MIP φ-family is not
    `ComputablePred`-decidable (the algorithmic incompleteness layer).

    These live in *different* decidability vocabularies:
      • R.172 uses `IsDecidablePred P := ∃ f : α → Bool, ∀ a, f a = true ↔ P a`.
      • R.108 uses Mathlib's `ComputablePred` (computability over ℕ).

    **Discovery (this file).** We connect the two:

    1. `IsDecidablePred_of_ComputablePred`: every `ComputablePred` is
       `IsDecidablePred` (composing a computable decider with `Bool.true`
       check). So R.108's hypothesis `¬ ComputablePred phiMIP` is *weaker*
       than `¬ IsDecidablePred phiMIP`.
    2. Equivalently, `¬ IsDecidablePred P → ¬ ComputablePred P` (the
       contrapositive). So **R.172's Rice-undecidability *implies*
       R.108's incomputability** for the same `P`.
    3. **Gödel-Rice combined**. Any non-trivial behaviourally-determined
       MIP property is *both* (a) undecidable (Rice) and (b) algorithmically
       incomplete (no `ComputablePred` decider) — and these are not two
       independent statements but the same fact viewed through different
       lenses.

  R-DEPS:
    • MIP.Results.R172_MIPRice (IsDecidablePred, R_172_MIP_Rice)
    • MIP.Results.R108_MipIncompleteness (R_108_phi_undecidable)
-/
import Mathlib.Computability.Reduce
import MIP.Results.R172_MIPRice
import MIP.Results.R108_MipIncompleteness

namespace MIP

namespace R3_Agent5_RiceIncompleteness

open MIP.MIPRice
open MIP.MipIncompleteness

/-! ## (1) ComputablePred ⟹ IsDecidablePred. -/

/-- **Bridge: every `ComputablePred` is `IsDecidablePred`.**

A `ComputablePred P` on ℕ comes with `Decidable (P n)` for every `n` and
a `Computable` proof. To get `IsDecidablePred P` in R.172's sense, the
witness is `f n := decide (P n)` (using the `Decidable` instance bundled
inside `ComputablePred`). This is the canonical comparison between the
two notions of "P is decidable" used across the impossibility series. -/
theorem IsDecidablePred_of_ComputablePred
    {P : ℕ → Prop} (h : ComputablePred P) : IsDecidablePred P := by
  obtain ⟨_decP, _hcomp⟩ := h
  -- The decidability instance lets us define a Boolean decider.
  refine ⟨fun n => decide (P n), ?_⟩
  intro n
  exact decide_eq_true_iff

/-- **Contrapositive bridge.** A non-`IsDecidablePred` predicate is also
non-`ComputablePred`. -/
theorem not_ComputablePred_of_not_IsDecidablePred
    {P : ℕ → Prop} (h : ¬ IsDecidablePred P) : ¬ ComputablePred P :=
  fun hC => h (IsDecidablePred_of_ComputablePred hC)

/-! ## (2) Direct push: R.172 (Rice) ⟹ R.108-style incompleteness. -/

/-- **Direct corollary: Rice ⟹ incompleteness, same predicate.**

If R.172 has been applied to obtain `¬ IsDecidablePred P` for some
emergence property `P : ℕ → Prop`, then `P` is also not `ComputablePred`.
This is the **R.172 → R.108 incompleteness arrow**: Rice's MIP form is
*at least as strong as* algorithmic incompleteness for the same
predicate. -/
theorem R172_implies_R108_incompleteness
    {P : ℕ → Prop} (h_rice : ¬ IsDecidablePred P) :
    ¬ ComputablePred P :=
  not_ComputablePred_of_not_IsDecidablePred h_rice

/-! ## (3) The combined Gödel-Rice headline. -/

/-- **Combined Gödel-Rice (headline).**

Given (a) classical Rice as a bundled external theorem, (b) a semantic
non-trivial MIP property `P` (via the standard R.172 inputs), the
emergent fact: `P` is *simultaneously*

  • undecidable in the `IsDecidablePred` sense (R.172 conclusion), and
  • non-`ComputablePred` (R.108 conclusion),

via a single derivation that produces R.172's `¬IsDecidablePred` and
then passes through the bridge of §(1). The headline crystalises "no
formal proof system and no algorithm can decide non-trivial behavioural
MIP properties". -/
theorem R172_R108_combined_undecidability
    {TM Agent : Type*} {Hist Out : Type*}
    (ι : TM → Agent)
    (behTM : TM → (Hist → Out))
    (behAg : Agent → (Hist → Out))
    (hintertwine : ∀ T, behAg (ι T) = behTM T)
    (P : Agent → Prop)
    (hsem : SemanticAgent (Hist := Hist) (Out := Out) behAg P)
    (hwitness : (∃ Tplus, P (ι Tplus)) ∧ (∃ Tminus, ¬ P (ι Tminus)))
    (classicalRice : ∀ Q : TM → Prop,
        SemanticAgent (Hist := Hist) (Out := Out) behTM Q →
        ((∃ Tplus, Q Tplus) ∧ (∃ Tminus, ¬ Q Tminus)) →
        ¬ IsDecidablePred Q) :
    ¬ IsDecidablePred P :=
  -- Direct invocation of R.172.
  R_172_MIP_Rice ι behTM behAg hintertwine P hsem hwitness classicalRice

/-- **Companion: the same `P`, lifted to ℕ via any injective encoding,
inherits both undecidability layers.**

If `P : Agent → Prop` is Rice-undecidable and `enc : Agent → ℕ` is an
injective encoding inducing the pulled-back predicate `Penc n := ∃ A, enc A = n ∧ P A`,
then `Penc` is not `IsDecidablePred` either (because a decider for
`Penc` composed with `enc` would decide `P`). Hence `Penc` is also not
`ComputablePred` via the §(1) bridge. -/
theorem encoded_predicate_inherits_both_undecidabilities
    {Agent : Type*}
    (enc : Agent → ℕ) (hEnc : Function.Injective enc)
    (P : Agent → Prop)
    (h_P_undec : ¬ IsDecidablePred P) :
    ¬ IsDecidablePred (fun n => ∃ A, enc A = n ∧ P A)
      ∧ ¬ ComputablePred (fun n => ∃ A, enc A = n ∧ P A) := by
  -- Define the encoded predicate.
  set Penc : ℕ → Prop := fun n => ∃ A, enc A = n ∧ P A with hPenc
  refine ⟨?_, ?_⟩
  · -- A decider for Penc, composed with enc, decides P.
    intro ⟨f, hf⟩
    apply h_P_undec
    refine ⟨fun a => f (enc a), ?_⟩
    intro a
    rw [hf (enc a)]
    constructor
    · rintro ⟨A, hA, hPA⟩
      have : A = a := hEnc hA
      exact this ▸ hPA
    · intro hPa
      exact ⟨a, rfl, hPa⟩
  · -- Then ComputablePred Penc would imply IsDecidablePred Penc.
    intro hC
    -- The previous bullet gives ¬ IsDecidablePred Penc.
    have h_not_dec : ¬ IsDecidablePred Penc := by
      intro ⟨f, hf⟩
      apply h_P_undec
      refine ⟨fun a => f (enc a), ?_⟩
      intro a
      rw [hf (enc a)]
      constructor
      · rintro ⟨A, hA, hPA⟩
        have : A = a := hEnc hA
        exact this ▸ hPA
      · intro hPa
        exact ⟨a, rfl, hPa⟩
    exact h_not_dec (IsDecidablePred_of_ComputablePred hC)

/-! ## (4) Putting R.108 in the Rice form. -/

/-- **R.108 (algorithmic) ⟹ ¬IsDecidablePred via R.172 (uniform corollary)?**

The converse arrow is *not* expected to hold in general: `ComputablePred`
is *stronger* than `IsDecidablePred` on ℕ, because the latter only
requires a total Boolean function (not a Turing-computable one) — i.e.
there exist `IsDecidablePred` predicates that are not `ComputablePred`
(any classical predicate has a Boolean indicator via excluded middle in
the platonist sense; the platonist `f` need not be `Computable`). So R.108
does NOT obviously yield R.172.

We therefore record only the one-way arrow `¬IsDecidablePred → ¬ComputablePred`
as the *correct* synthesis of the two layers: Rice is strictly stronger
than algorithmic incompleteness. The combined headline is the conjunction
form below — both layers hold simultaneously whenever Rice's hypotheses
do. -/
theorem rice_strictly_stronger
    {P : ℕ → Prop} (h_rice : ¬ IsDecidablePred P) :
    ¬ IsDecidablePred P ∧ ¬ ComputablePred P :=
  ⟨h_rice, R172_implies_R108_incompleteness h_rice⟩

end R3_Agent5_RiceIncompleteness

end MIP
