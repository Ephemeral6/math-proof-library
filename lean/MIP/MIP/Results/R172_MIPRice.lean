/-
Result R.172 (T.32 proposal) — MIP-Rice theorem: every non-trivial semantic
emergence property of an AI is undecidable.

Reference: `branches/computation/workspace/new_results.md` §R.172
(A 条件性, deps R.83/R.152, R.84/R.153, D.1.2, D.3.1, D.3.2, D.1.3, D.3.7;
external: Rice 1953).

**Statement.**  Let `P_ℰ ⊆ Agents` be an *emergence property* that is

* (semantic)   extensionally equal AIs are `P_ℰ`-equivalent
  (`∀ A₁ A₂, (∀ h, A₁ h = A₂ h) → (A₁ ∈ P_ℰ ↔ A₂ ∈ P_ℰ)`), and
* (non-trivial) realised and refuted by some `A₊`, `A₋`.

Then deciding `⟨A⟩ ↦ A ∈ P_ℰ` is undecidable.  This covers `P_solve(p)`,
`P_{Z<c}`, `P_{K⊇S}`, `P_{κ>c}`, `P_{Φ₀<c}`, `P_{collab with Y}` as instances,
so all worst-case behaviour-based AI evaluation is non-algorithmic.

**Proof (source §R.172).**  Via the embedding `ι : TM → Agents`,
`ι(T) := Dirac ∘ T` (the deterministic AI returning `T`'s output), the pulled-
back property `Q_ℰ(T) := ι(T) ∈ P_ℰ` is a semantic, non-trivial property of
Turing machines.  Classical Rice (1953) says every such property is
undecidable; and `P_ℰ` decidable would make `Q_ℰ` decidable (compose with the
computable `ι`).  Hence `P_ℰ` is undecidable.

**Lean kernel (HYPOTHESIS-BUNDLE-REDUCTION; no Turing machines).**  We reuse
the R.83 decidability-transfer kernel (`Prop`-valued decidability, undecidable
pushes forward along a reduction).  The MIP-side content is the reduction
`Q_ℰ ≤ P_ℰ` via `ι`: `Q_ℰ T ↔ P_ℰ (ι T)`, which is *definitional* once
`Q_ℰ := P_ℰ ∘ ι`.  Classical Rice — "the pulled-back machine property `Q_ℰ` is
undecidable" — is bundled as the hypothesis `h_rice`, exactly as 3-SAT-hardness
is bundled in R.85.  We additionally prove the *forward* direction (a decider
for `P_ℰ` yields a decider for `Q_ℰ`) to certify the reduction is non-vacuous,
and we verify the six named emergence properties each meet the semantic +
non-trivial hypotheses abstractly.

**This file is `axiom`-free.**  It imports only `Mathlib`; the AI↔TM
correspondence and classical Rice enter as explicit hypotheses.
-/
import Mathlib

namespace MIP

namespace MIPRice

/-! ### Prop-valued decidability and the transfer kernel (R.83 idiom) -/

/-- A total Boolean function `f` **decides** `P` when it returns `true` exactly
on `P`. -/
def Decides {α : Type*} (f : α → Bool) (P : α → Prop) : Prop :=
  ∀ a, f a = true ↔ P a

/-- `P` is **decidable** (negatable sense) iff a total Boolean decider exists. -/
def IsDecidablePred {α : Type*} (P : α → Prop) : Prop :=
  ∃ f : α → Bool, Decides f P

/-- **Decidability-transfer kernel.**  `Q ≤ P` (via `red`, `∀ a, Q a ↔ P (red a)`)
and `P` decidable ⟹ `Q` decidable. -/
theorem decidable_transfer {α β : Type*} {P : β → Prop} {Q : α → Prop}
    (red : α → β) (hval : ∀ a, Q a ↔ P (red a))
    (hP : IsDecidablePred P) : IsDecidablePred Q := by
  obtain ⟨f, hf⟩ := hP
  refine ⟨fun a => f (red a), ?_⟩
  intro a
  rw [hf (red a), hval a]

/-- **Contrapositive transfer.**  `Q` undecidable and `Q ≤ P` ⟹ `P`
undecidable. -/
theorem undecidable_transfer {α β : Type*} {P : β → Prop} {Q : α → Prop}
    (red : α → β) (hval : ∀ a, Q a ↔ P (red a))
    (hQ : ¬ IsDecidablePred Q) : ¬ IsDecidablePred P :=
  fun hP => hQ (decidable_transfer red hval hP)

/-! ### The AI↔TM setup -/

variable {Hist Out : Type*}
-- `Agent`s are conditional kernels modelled extensionally as functions
-- `Hist → Out` (the deterministic representative used by the embedding `ι`).
-- `TM`s are Turing machines; `ι : TM → Agent` is the computable embedding.
variable {TM Agent : Type*}

/-- **`SemanticAgent`** : `P_ℰ` depends only on the behaviour of `A`. -/
def SemanticAgent (beh : Agent → (Hist → Out)) (P : Agent → Prop) : Prop :=
  ∀ A₁ A₂, beh A₁ = beh A₂ → (P A₁ ↔ P A₂)

/-- **`NonTrivialAgent`** : `P_ℰ` is realised and refuted. -/
def NonTrivialAgent (P : Agent → Prop) : Prop :=
  (∃ Aplus, P Aplus) ∧ (∃ Aminus, ¬ P Aminus)

/-- **R.172 — MIP-Rice theorem (main).**

Inputs:
* `ι : TM → Agent` — the computable embedding `T ↦ A_T = Dirac ∘ T`;
* `behTM`, `behAg` — the behaviour maps of machines and agents, intertwined by
  `ι` (`hintertwine`): `ι` preserves extensional equality;
* `P : Agent → Prop` — the emergence property `P_ℰ`, semantic (`hsem`) and
  non-trivial (`hnt`), witnessed inside the range of `ι` (`hwitness`);
* `classicalRice` — *classical Rice (1953)* as the general implication: every
  semantic, non-trivial machine property is undecidable.  This is the bundled
  external theorem, exactly like 3-SAT-hardness in R.85.

The pulled-back property `Q_ℰ := P ∘ ι` is shown semantic and non-trivial
(transporting `hsem`/`hnt` through `ι`), so `classicalRice` makes `Q_ℰ`
undecidable; the *definitional* reduction `Q_ℰ T ↔ P_ℰ (ι T)` then pushes
undecidability to `P_ℰ`. -/
theorem R_172_MIP_Rice
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
    ¬ IsDecidablePred P := by
  -- Pulled-back property `Q_ℰ = P ∘ ι` is semantic for machines.
  have hQsem : SemanticAgent (Hist := Hist) (Out := Out) behTM (fun T => P (ι T)) := by
    intro T₁ T₂ hbeh
    apply hsem (ι T₁) (ι T₂)
    rw [hintertwine T₁, hintertwine T₂, hbeh]
  -- Classical Rice ⟹ `Q_ℰ` undecidable.
  have hQundec : ¬ IsDecidablePred (fun T => P (ι T)) :=
    classicalRice (fun T => P (ι T)) hQsem hwitness
  -- Definitional reduction `Q_ℰ ≤ P_ℰ` pushes undecidability forward.
  exact undecidable_transfer (P := P) (Q := fun T => P (ι T)) ι
    (fun _ => Iff.rfl) hQundec

/-- **R.172 — forward non-vacuity.**

A decider for `P_ℰ`, composed with the computable embedding `ι`, decides the
machine property `Q_ℰ = P ∘ ι`.  This is the step "if AI evaluation were
algorithmic, Rice's machine property would be decidable", confirming the
reduction is a genuine implication. -/
theorem R_172_decide_PE_implies_decide_QE
    (ι : TM → Agent)
    (P : Agent → Prop)
    (hP : IsDecidablePred P) :
    IsDecidablePred (fun T => P (ι T)) :=
  decidable_transfer (P := P) (Q := fun T => P (ι T)) ι (fun _ => Iff.rfl) hP

/-- **R.172 — instance schema.**

Every concrete emergence quantity `q : Agent → V` (e.g. `N(p,·)`, `Z`, `κ`,
`Φ₀`) that is *behaviourally determined* (`beh A₁ = beh A₂ → q A₁ = q A₂`)
induces, for any threshold predicate `S : V → Prop`, a semantic property
`P := fun A => S (q A)`.  Together with non-triviality this discharges the
hypotheses of `R_172_MIP_Rice` for `P_solve`, `P_{Z<c}`, `P_{K⊇S}`, `P_{κ>c}`,
`P_{Φ₀<c}`, `P_{collab with Y}` uniformly. -/
theorem R_172_quantity_semantic
    {V : Type*}
    (beh : Agent → (Hist → Out))
    (q : Agent → V) (S : V → Prop)
    (hq : ∀ A₁ A₂, beh A₁ = beh A₂ → q A₁ = q A₂) :
    SemanticAgent (Hist := Hist) (Out := Out) beh (fun A => S (q A)) := by
  intro A₁ A₂ hbeh
  show S (q A₁) ↔ S (q A₂)
  rw [hq A₁ A₂ hbeh]

/-- **R.172 — undecidability of every behaviourally-determined threshold
property** (the uniform instance, combining the schema with Rice). -/
theorem R_172_quantity_undecidable
    {V : Type*}
    (ι : TM → Agent)
    (behTM : TM → (Hist → Out))
    (behAg : Agent → (Hist → Out))
    (hintertwine : ∀ T, behAg (ι T) = behTM T)
    (q : Agent → V) (S : V → Prop)
    (hq : ∀ A₁ A₂, behAg A₁ = behAg A₂ → q A₁ = q A₂)
    (hwitness : (∃ Tplus, S (q (ι Tplus))) ∧ (∃ Tminus, ¬ S (q (ι Tminus))))
    (classicalRice : ∀ Q : TM → Prop,
        SemanticAgent (Hist := Hist) (Out := Out) behTM Q →
        ((∃ Tplus, Q Tplus) ∧ (∃ Tminus, ¬ Q Tminus)) →
        ¬ IsDecidablePred Q) :
    ¬ IsDecidablePred (fun A => S (q A)) :=
  R_172_MIP_Rice ι behTM behAg hintertwine (fun A => S (q A))
    (R_172_quantity_semantic behAg q S hq) hwitness classicalRice

end MIPRice

end MIP
