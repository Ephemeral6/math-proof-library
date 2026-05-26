/-
Theorem T.18.1 — Uncomputability of `N`.

Reference: `theorems/index.md` T.18.1 (`N` is Turing-uncomputable as a
function of `(p, X)`, via a reduction from the halting problem).

**Statement.** The bounded-emergence-degree decision predicate
`(p, X) ↦ (N(p, X) ≠ ∞)` — equivalently, by A.2, the predicate
"some admissible knowledge demand of `p` is covered by `K(X)`" — is not
Turing-computable.  Concretely, its ℕ-coding through any encoding of
`(Problem α × Agent α)` is not a `ComputablePred`.

**Proof.** Reduction from the halting problem.  The halting predicate
on Kleene codes, `c ↦ (eval c n).Dom`, is not computable
(`ComputablePred.halting_problem`, proved in Mathlib).  We bundle a
computable many-one reduction `red` from halting to the ℕ-coded
finite-`N` predicate `PredOnN enc` (this is the formal content of the
informal "construct an agent `X_M` whose problem `p_M` is solvable iff
`M(x)` halts").  If `PredOnN enc` were computable, then composing with
the computable `red` would make the halting predicate computable
(`ComputablePred.computable_of_manyOneReducible`), contradicting its
proven non-computability.  Hence `PredOnN enc` is uncomputable.

**What is bundled vs. proven.**
* *Bundled as a hypothesis* (`HaltReductionBundle`): the existence of a
  computable reduction `red : ℕ → ℕ` with
  `(eval (ofNat Code e) n).Dom ↔ PredOnN enc (red e)`.  This is the
  Turing-machine ↦ agent construction, which lies outside the opaque
  `MIP.Axioms` signatures (it needs a TM encoding of agents), so — in
  the `RestrSpec` hypothesis-bundle idiom of T.33 — it is carried as a
  hypothesis rather than asserted as an axiom or `sorry`'d.
* *Bundled as a hypothesis* (`enc`, `hEnc`): an injective ℕ-encoding of
  `Problem α × Agent α` (these are opaque function types, hence not
  `Primcodable`; injectivity is the only structural fact used to read
  `FiniteN` back out of the code).
* *Proven*, with no further assumption: the non-computability of the
  halting predicate, and the whole reduction-contradiction argument.
  There is **no** assumed "`¬ ComputablePred H`": `H` is Mathlib's
  halting predicate and its undecidability is `halting_problem`.
-/
import MIP.Axioms
import Mathlib.Computability.Reduce

namespace MIP

namespace Uncomputability

open Nat.Partrec (Code)

variable {α : Type}

/-! ### The finite-emergence-degree decision predicate -/

/-- **Finite-`N` predicate.**  `FiniteN (p, X)` holds iff the emergence
degree `N(p, X)` is finite (`≠ ∞`).  By Axiom A.2 this is equivalent to
"`∃ R ∈ ℛ(p), R ⊆ K(X)`", i.e. the problem `p` is *solvable* by `X`;
this is the predicate the halting reduction targets. -/
def FiniteN (c : Problem α × Agent α) : Prop := N c.1 c.2 ≠ ⊤

/-- **ℕ-coded finite-`N` predicate.**  Given an encoding
`enc : (Problem α × Agent α) → ℕ`, `PredOnN enc n` decodes `n` to a
configuration `c` and asserts `FiniteN c`.  This is the integer-coded
form of `FiniteN` whose computability is in question. -/
def PredOnN (enc : (Problem α × Agent α) → ℕ) (n : ℕ) : Prop :=
  ∃ c : Problem α × Agent α, enc c = n ∧ FiniteN c

/-! ### The halting-reduction hypothesis bundle -/

/-- **Halting-reduction bundle (Hybrid-statement hypothesis).**

Bundles, as a single `Prop` in the `MIP.UEA.RestrSpec` idiom, the
many-one reduction from the halting problem into the ℕ-coded finite-`N`
predicate:

* a reduction map `red : ℕ → ℕ`,
* its computability `Computable red`,
* the reduction equivalence: a code `c = ofNat Code e` halts on input
  `n` iff `PredOnN enc (red e)`.

Establishing this bundle is the Turing-machine-to-agent construction of
the informal proof of T.18.1, which lives beyond the opaque
`MIP.Axioms` signature layer. -/
def HaltReductionBundle (enc : (Problem α × Agent α) → ℕ) (n : ℕ) : Prop :=
  ∃ red : ℕ → ℕ, Computable red ∧
    (∀ e : ℕ, (Code.eval (Denumerable.ofNat Code e) n).Dom ↔ PredOnN enc (red e))

/-! ### T.18.1 -/

/-- **T.18.1 (N Uncomputability).**

Under the halting-reduction bundle (the formal TM↦agent construction),
the ℕ-coded finite-emergence-degree predicate `PredOnN enc`

* **faithfully codes** `FiniteN` — through the injective encoding it
  reads back exactly `N(p, X) ≠ ∞`
  (`∀ c, PredOnN enc (enc c) ↔ FiniteN c`), and
* is **not** Turing-computable.

This is a faithful rendering of "the map `(p, X) ↦ N(p, X)` is not
computable": if one could compute whether `N(p, X) < ∞`, one could
decide the halting problem.

Proof outline:
* (Faithfulness) injectivity of `enc` collapses the existential decode.
* (Bundle) obtain a computable reduction `red` with halting `↔ PredOnN`.
* (Reduction) `(c ↦ (eval c n).Dom) ≤₀ PredOnN enc` via
  `e := encode c`, using `red ∘ encode` (computable) and the bundle
  equivalence (after `ofNat_encode` cancels the round-trip).
* (Contradiction) if `PredOnN enc` were computable then
  `computable_of_manyOneReducible` would make the halting predicate
  computable, contradicting `ComputablePred.halting_problem`. -/
theorem T18_1_N_uncomputable
    (enc : (Problem α × Agent α) → ℕ) (hEnc : Function.Injective enc)
    (n : ℕ) (hbundle : HaltReductionBundle (α := α) enc n) :
    (∀ c : Problem α × Agent α, PredOnN (α := α) enc (enc c) ↔ FiniteN c)
      ∧ ¬ ComputablePred (PredOnN (α := α) enc) := by
  refine ⟨?_, ?_⟩
  · -- Faithfulness: through the injective encoding, `PredOnN enc` reads
    -- back exactly `FiniteN`.
    intro c
    constructor
    · rintro ⟨c', hc', hfin⟩
      -- `enc c' = enc c` and `enc` injective ⇒ `c' = c`.
      rwa [hEnc hc'] at hfin
    · exact fun hfin => ⟨c, rfl, hfin⟩
  · -- Uncomputability: reduction from the (proven non-computable) halting
    -- predicate.
    obtain ⟨red, hred, hreduces⟩ := hbundle
    intro hcomp
    -- The halting predicate on Kleene codes (Mathlib: not computable).
    set Hcode : Code → Prop := fun c => (Code.eval c n).Dom with hHcode
    -- Many-one reduce the halting predicate to `PredOnN enc`.
    have hle : Hcode ≤₀ PredOnN (α := α) enc := by
      refine ⟨fun c => red (Encodable.encode c), hred.comp Computable.encode, ?_⟩
      intro c
      have h := hreduces (Encodable.encode c)
      simpa [hHcode, Denumerable.ofNat_encode] using h
    -- A computable `PredOnN enc` would make halting computable: contradiction.
    exact ComputablePred.halting_problem n
      (ComputablePred.computable_of_manyOneReducible hle hcomp)

end Uncomputability

end MIP
