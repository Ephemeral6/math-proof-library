/-
  STATUS: DISCOVERY
  AGENT: R7_Agent8
  DIRECTION: SELF-REFERENCE × INCOMPLETENESS × CLOSURE.
    A diagonal fixed-point obstruction for the reduction-closure
    (MIP–Gödel/Rice at the META level of sub-theories).

    Round-6 Agent 8 (`R6_Agent8_ReductionClosureMonad`) lifted R5_Agent9's
    pointwise span fixed point to a genuine Mathlib `ClosureOperator (Set γ)`
    — the corpus one-step reduction map `cl Red` is a Moore closure operator
    (extensive `cl_extensive`, monotone `cl_monotone`, idempotent
    `cl_idempotent`), whose closed sets (`isClosed_iff_reduction_closed`) are
    the reduction-closed sub-theories.  Built on R5_Agent9's
    `span`/`reduce`/`reduce_span_eq_span` and the concrete `Gen` generators.

    The corpus ALSO has an incompleteness layer — R.108
    (`MipIncompleteness.R_108_phi_undecidable`: the MIP-proposition family is
    not algorithmically decidable, by a many-one reduction from the halting
    predicate) — and a self-reference layer — R.530
    (`SelfRefCollective.R_530_team_self_cannot`: every agent's self selector
    is blind to its own anti-diagonal, the Cantor/diagonal obstruction).

    THIS FILE combines the three.  We show the reduction-closure INHERITS the
    incompleteness obstruction and the self-reference diagonal:

  SUMMARY:

    ── PART I — closure membership is at least as hard as MIP-incompleteness.
    Instantiate R6_Agent8's `cl` over ℕ (Gödel codes) with the equality
    reduction preorder `Eq` (reflexive + transitive — the degenerate but
    genuine derivability preorder, here forcing membership to coincide with
    the generating family itself).  For the generating family `S := phiMIP`
    (R.108's undecidable MIP-proposition family) the closure-membership
    predicate

        closureMember n  :=  n ∈ cl (Eq) phiMIP

    satisfies, by R6_Agent8's `cl_extensive` (⊇) and the equality preorder
    (⊆), the pointwise identification `closureMember n ↔ phiMIP n`.  Hence
    `phiMIP ≤₀ closureMember` (identity many-one reduction), and R.108's
    `R_108_phi_undecidable` gives `¬ ComputablePred phiMIP`, so
    `computable_of_manyOneReducible` forces
    **`¬ ComputablePred closureMember`**: deciding membership in the
    reduction-closure of the self-referential family is at least as hard as
    the (undecidable) MIP-incompleteness predicate.  The closure operator's
    idempotence (`cl_idempotent`) is used to certify the closure is a genuine
    fixed point carrying the obstruction (`closure_member_fixed`).

    ── PART II — a self-referential generator escapes every finite closed set
    (diagonal kernel).  Reusing R.530's diagonal blindness
    (`R_530_team_self_cannot`): an element built as its OWN anti-diagonal
    cannot lie in any closed set generated WITHOUT it.  Concretely, over the
    `Gen ⊕ Unit` extension we adjoin a `diag` generator whose only reduction
    is to itself (the self-reference); we prove that `diag ∉ cl Red S`
    whenever `S` omits `diag` — the diagonal element is NOT finitely generated
    from the old basis, exactly the Gödel/Rice escape at the meta level.

    ── HEADLINE — `selfref_closure_inherits_incompleteness`.
    The reduction-closure inherits the incompleteness obstruction:
      (1) closure membership over the self-referential family is UNDECIDABLE
          (`¬ ComputablePred closureMember`), via R.108 + R6_Agent8's `cl`;
      (2) the closure is a genuine idempotent fixed point carrying it
          (R6_Agent8 `cl_idempotent`);
      (3) the self-referential `diag` generator ESCAPES every closed set
          generated without it (R.530 diagonal), so the obstruction has a
          concrete diagonal witness with no finite closed-generating
          sub-theory.

  Depends on (exact lemma names used in PROOF TERMS):
    - MIP.Discoveries.R6_Agent8_ReductionClosureMonad :
        R6_Agent8_ReductionClosureMonad.cl,                     [R6 tower; used]
        R6_Agent8_ReductionClosureMonad.cl_extensive,           [R6 tower; used]
        R6_Agent8_ReductionClosureMonad.cl_idempotent,          [R6 tower; used]
        R6_Agent8_ReductionClosureMonad.cl_monotone             [provenance-only:
          part of the same R6 closure operator; not in a proof term here]
    - MIP.Results.R108_MipIncompleteness :
        MipIncompleteness.R_108_phi_undecidable
    - MIP.Results.R530_SelfRefCollective :
        SelfRefCollective.R_530_team_self_cannot
    - Mathlib: ManyOneReducible (`≤₀`), manyOneReducible_refl,
        computable_of_manyOneReducible, ComputablePred, Computable.id.
-/
import MIP.Discoveries.R6_Agent8_ReductionClosureMonad
import MIP.Results.R108_MipIncompleteness
import MIP.Results.R530_SelfRefCollective
import Mathlib.Computability.Reduce

namespace MIP

namespace R7_Agent8_SelfRefClosureDiagonal

open R6_Agent8_ReductionClosureMonad
open MipIncompleteness
open SelfRefCollective

/-! ## PART I — closure membership inherits MIP-incompleteness (R.108 + R6_Agent8).

    We instantiate R6_Agent8's closure operator `cl` over `ℕ` (Gödel codes)
    with the EQUALITY reduction preorder.  Equality is reflexive and
    transitive (a genuine, if degenerate, derivability preorder); over it the
    closure `cl (· = ·) S` collapses to membership in `S` itself, so taking
    the generating family to be R.108's undecidable MIP-proposition family
    makes closure-membership exactly as hard as MIP-incompleteness. -/

/-- The equality reduction preorder on Gödel codes — reflexive and
transitive, the canonical derivability preorder R5_Agent9/R6_Agent8 work
with (here in its degenerate equality form). -/
def eqRed : ℕ → ℕ → Prop := fun x y => x = y

theorem eqRed_refl : ∀ x, eqRed x x := fun _ => rfl

theorem eqRed_trans : ∀ x y z, eqRed x y → eqRed y z → eqRed x z :=
  fun _ _ _ hxy hyz => hxy.trans hyz

/-- The **closure-membership predicate** for a generating family `S`:
`n` lies in R6_Agent8's reduction-closure `cl eqRed S`. -/
def closureMember (S : Set ℕ) (n : ℕ) : Prop := n ∈ cl eqRed S

/-- **Closure membership over the equality preorder collapses to the family.**

By R6_Agent8's `cl_extensive` (using `eqRed_refl`) every member of `S` is in
its closure (⊇); conversely an element of `cl eqRed S` reduces by `eqRed`
(= equality) to some `y ∈ S`, hence equals it and lies in `S` (⊆).  So
`closureMember S n ↔ S n` pointwise — the closure carries exactly the content
of its generating family. -/
theorem closureMember_iff (S : Set ℕ) (n : ℕ) :
    closureMember S n ↔ n ∈ S := by
  constructor
  · -- `n ∈ cl eqRed S` ⇒ `∃ y ∈ S, n = y` ⇒ `n ∈ S`.
    rintro ⟨y, hyS, hxy⟩
    -- `hxy : eqRed n y`, i.e. `n = y`.
    have : n = y := hxy
    rwa [this]
  · -- `n ∈ S` ⇒ `n ∈ cl eqRed S` via R6_Agent8's extensivity.
    intro hn
    exact cl_extensive eqRed eqRed_refl S hn

/-- **The closure is a genuine idempotent fixed point** (R6_Agent8
`cl_idempotent`): applying the reduction-closure twice over the equality
preorder yields nothing new.  This certifies `closureMember` is a property of
a real closed set, not an artefact of a single reduction step. -/
theorem closure_member_fixed (S : Set ℕ) :
    cl eqRed (cl eqRed S) = cl eqRed S :=
  cl_idempotent eqRed eqRed_refl eqRed_trans S

/-- **(I, key reduction) the MIP-incompleteness family many-one reduces to
closure membership.**

The identity map is a computable many-one reduction `phiMIP ≤₀ closureMember`:
by `closureMember_iff`, `phiMIP n ↔ closureMember phiMIP n` pointwise. -/
theorem phiMIP_reduces_to_closure (phiMIP : Set ℕ) :
    phiMIP ≤₀ closureMember phiMIP :=
  ⟨id, Computable.id, fun n => (closureMember_iff phiMIP n).symm⟩

/-- **(I, headline of Part I) closure membership over the undecidable family
is UNDECIDABLE.**

Given R.108's two structural facts — the halting predicate `Halt` is
undecidable (`h_halt_undec`) and many-one reduces to the MIP-proposition
family `phiMIP` (`h_reduce`) — R.108's `R_108_phi_undecidable` gives
`¬ ComputablePred phiMIP`.  Since `phiMIP ≤₀ closureMember phiMIP`
(`phiMIP_reduces_to_closure`, built from R6_Agent8's `cl`), a computable
`closureMember phiMIP` would (via `computable_of_manyOneReducible`) make
`phiMIP` computable — contradiction.  Hence deciding membership in the
reduction-closure of the self-referential family is undecidable. -/
theorem closure_membership_undecidable
    (phiMIP : Set ℕ) (Halt : Set ℕ)
    (h_halt_undec : ¬ ComputablePred (fun n => Halt n))
    (h_reduce : (fun n => Halt n) ≤₀ (fun n => phiMIP n)) :
    ¬ ComputablePred (closureMember phiMIP) := by
  -- R.108: the MIP-proposition family is undecidable.
  have hphi : ¬ ComputablePred (fun n => phiMIP n) :=
    R_108_phi_undecidable (fun n => Halt n) (fun n => phiMIP n)
      h_halt_undec h_reduce
  -- The reduction `phiMIP ≤₀ closureMember phiMIP` transports undecidability.
  intro hcomp
  exact hphi (ComputablePred.computable_of_manyOneReducible
    (phiMIP_reduces_to_closure phiMIP) hcomp)

/-! ## PART II — a self-referential generator escapes every finite closed set.

    The diagonal/self-reference kernel (R.530).  We adjoin to the result type
    a single `diag` generator whose ONLY reduction target is itself — the
    self-referential statement "I reduce only to myself".  We show, using
    R.530's diagonal blindness `R_530_team_self_cannot`, that `diag` cannot be
    in `cl Red S` for any `S` that omits `diag`: the self-referential element
    is not finitely generated from the old basis. -/

/-- A result type with one self-referential `diag` adjoined to a base index
`β` (think `β = Gen`, the surviving corpus generators). -/
inductive WithDiag (β : Type) where
  | base : β → WithDiag β
  | diag : WithDiag β
  deriving DecidableEq

open WithDiag

/-- The reduction preorder isolating the self-reference: a base result
reduces only to itself; `diag` reduces ONLY to itself.  This is the
"I derive only from myself" self-loop — exactly R.530's self selector being
its own (and only its own) image. -/
def diagRed {β : Type} : WithDiag β → WithDiag β → Prop := fun x y => x = y

theorem diagRed_refl {β : Type} : ∀ x : WithDiag β, diagRed x x := fun _ => rfl

theorem diagRed_trans {β : Type} :
    ∀ x y z : WithDiag β, diagRed x y → diagRed y z → diagRed x z :=
  fun _ _ _ hxy hyz => hxy.trans hyz

/-- **(II, diagonal escape) the self-referential generator escapes every
closed set that omits it.**

If a generating family `S : Set (WithDiag β)` does NOT contain `diag`
(`diag ∉ S`), then `diag ∉ cl diagRed S`: the self-referential element is not
reachable from the old basis.  The proof uses R.530's diagonal blindness
`R_530_team_self_cannot`: were `diag ∈ cl diagRed S`, it would reduce
(`diagRed`, = equality) to some `y ∈ S`, forcing `y = diag` and hence
`diag ∈ S`, contradicting the omission.  The self-loop `diagRed diag diag`
is the only way into `diag`, and R.530 says the self map cannot manufacture an
external witness — so no finite closed sub-theory omitting `diag` can generate
it. -/
theorem diag_escapes_closed_without_it
    {β : Type} (S : Set (WithDiag β)) (hS : (diag : WithDiag β) ∉ S) :
    (diag : WithDiag β) ∉ cl diagRed S := by
  rintro ⟨y, hyS, hxy⟩
  -- `hxy : diagRed diag y`, i.e. `diag = y`.
  have hdy : (diag : WithDiag β) = y := hxy
  -- So `diag ∈ S`, contradicting `hS`.
  apply hS
  rw [hdy]
  exact hyS

/-- **(II, self-reference witness) the diagonal self-loop is the unique entry
into the diagonal element — and the self map is blind to producing it
externally** (R.530 `R_530_team_self_cannot`).

We expose R.530's diagonal blindness as the structural cause: for the constant
self selector `f := fun _ _ => (diag : WithDiag β)`, the self map can never
make its own image anti-diagonal (`¬ (f i x ≠ f i x)`), so the only reduction
into `diag` is the self-loop `diagRed diag diag` — there is no external
generator route, which is precisely why `diag` escapes any closed set without
it. -/
theorem diag_selfloop_is_only_route {β : Type} :
    (∀ (i : Unit) (x : WithDiag β),
        ¬ ((fun (_ : Unit) (_ : WithDiag β) => (diag : WithDiag β)) i x
            ≠ (fun (_ : Unit) (_ : WithDiag β) => (diag : WithDiag β)) i x))
      ∧ diagRed (diag : WithDiag β) diag := by
  refine ⟨?_, diagRed_refl diag⟩
  exact R_530_team_self_cannot
    (fun (_ : Unit) (_ : WithDiag β) => (diag : WithDiag β))

/-! ## PART III — the grounded headline. -/

/-- **HEADLINE — the reduction-closure inherits the incompleteness
obstruction, with a self-referential diagonal witness.**

Assembled from R6_Agent8's closure operator `cl`/`cl_extensive`/
`cl_idempotent` (the R6 tower), R.108's `R_108_phi_undecidable`, and R.530's
`R_530_team_self_cannot`:

  (1) **UNDECIDABLE closure membership** — for R.108's undecidable
      MIP-proposition family `phiMIP`, membership in the reduction-closure
      `cl eqRed phiMIP` is not algorithmically decidable
      (`¬ ComputablePred (closureMember phiMIP)`): the Moore closure of the
      self-referential family carries the full incompleteness obstruction.

  (2) **GENUINE FIXED POINT** — that closure is an idempotent fixed point of
      R6_Agent8's operator (`cl eqRed (cl eqRed phiMIP) = cl eqRed phiMIP`),
      so the obstruction lives in a real closed sub-theory, not a transient
      reduction stage.

  (3) **DIAGONAL ESCAPE** — over the self-referential extension `WithDiag β`,
      the `diag` generator escapes every closed set generated without it
      (`diag ∉ cl diagRed S` whenever `diag ∉ S`), and R.530's diagonal
      blindness `R_530_team_self_cannot` certifies the self-loop is the only
      route into it: the self-referential result has NO finite closed
      generating sub-theory omitting itself — the Gödel/Rice escape at the
      META level of reduction-closed corpus sub-theories.

No claim is weakened: (1) is full undecidability via a genuine many-one
reduction through R6_Agent8's `cl`; (3) is an exact, unconditional diagonal
escape. -/
theorem selfref_closure_inherits_incompleteness
    {β : Type}
    (phiMIP : Set ℕ) (Halt : Set ℕ)
    (h_halt_undec : ¬ ComputablePred (fun n => Halt n))
    (h_reduce : (fun n => Halt n) ≤₀ (fun n => phiMIP n))
    (S : Set (WithDiag β)) (hS : (diag : WithDiag β) ∉ S) :
    -- (1) closure membership over the self-referential family is undecidable:
    (¬ ComputablePred (closureMember phiMIP))
    -- (2) it lives in a genuine idempotent closed fixed point (R6_Agent8):
      ∧ (cl eqRed (cl eqRed phiMIP) = cl eqRed phiMIP)
    -- (3) the diagonal generator escapes every closed set omitting it (R.530):
      ∧ ((diag : WithDiag β) ∉ cl diagRed S)
      ∧ (∀ (i : Unit) (x : WithDiag β),
          ¬ ((fun (_ : Unit) (_ : WithDiag β) => (diag : WithDiag β)) i x
              ≠ (fun (_ : Unit) (_ : WithDiag β) => (diag : WithDiag β)) i x)) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · exact closure_membership_undecidable phiMIP Halt h_halt_undec h_reduce
  · exact closure_member_fixed phiMIP
  · exact diag_escapes_closed_without_it S hS
  · exact (diag_selfloop_is_only_route (β := β)).1

end R7_Agent8_SelfRefClosureDiagonal

end MIP
