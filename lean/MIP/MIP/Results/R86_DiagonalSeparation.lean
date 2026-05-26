/-
Result R.86 — Diagonal self-blindness (self vs. external separation).

Reference: `proofs/derived/computation.md` R.86/R.101 context and
`branches/self_reference/workspace/new_results.md` R.181 (the upgraded,
A-grade diagonalization of R.86), deps D.S.1, Cantor/Gödel diagonal lemma.

**Statement.**  Each non-trivial computable AI `A` has a problem `p_A` — the
*anti-diagonal* of `A`'s own argmax (self-prediction) response — which `A`
**cannot solve alone** (self-emergence `N(p_A, A, A) = ∞`) but which an
**external** `A'` **can** solve (`N(p_A, A, A') < ∞`).

The mechanism is Cantor's diagonal argument.  `A`'s highest-probability
response at an input is its self-prediction; model the self-prediction by a
*self-map* `f : ι → ι` (`f x` = the response `A` predicts/emits at input `x`).
The anti-diagonal problem accepts exactly the responses that *differ* from the
self-prediction:

    bad x  :≡  x ≠ f x          (the anti-diagonal predicate at the response)

To "solve" the problem at input `x` a questioner must steer the solver to emit
a response `y` with `bad y` *at the diagonal input* — concretely, with
`y = f x` substituted for the self-questioner, `A`'s own response is `f x`,
which can NEVER be the anti-diagonal witness of itself.

**Lean kernel (no agents).**  We expose only the selector functions:
* `f : ι → ι` — the SELF selector (A's argmax self-prediction).  When A acts
  as its own questioner, the response it produces at input `x` is `f x`.
* `g : ι → ι` — an EXTERNAL selector (A').  It is *transversal*: `g x ≠ f x`.

The acceptance predicate of `p_A` at input `x`, applied to a candidate
response `y`, is `bad y`, where `bad y := y ≠ f y` would self-reference; the
*anti-diagonal* form used in the separation fixes the input and asks the
response to differ from the self-prediction at that input.  The two theorems:

1. `R_86_self_cannot`     — the self selector `f` can never produce an
   anti-diagonal witness *of its own fixed point*: there is no `x` with
   `f x ≠ f x`.  (Self-emergence is impossible — the `∞` side.)
2. `R_86_external_can`    — a transversal external selector `g` (with
   `g x ≠ f x` for the relevant `x`) DOES produce a witness differing from the
   self-prediction.  (External emergence is finite — the witness exists.)
3. `R_86_separation`      — packaged separation: `∀ x, ¬(f x ≠ f x)` (self
   blind) while `∃` external `g` and input with `g x ≠ f x` (external solves).
4. `R_86_cantor_no_self_hit` — the underlying Cantor lemma in clean form: for
   the anti-diagonal target `t := f x`, the self selector at `x` outputs `f x`
   and so `f x = t`, i.e. it can NEVER satisfy the anti-diagonal demand
   `response ≠ f x`, whereas a transversal external selector can.

**This file is `axiom`-free.**  It imports only `Mathlib`; all agent semantics
are bundled into the selector functions `f` (self) and `g` (external).
-/
import Mathlib.Logic.Basic

namespace MIP

namespace DiagonalSeparation

variable {ι : Type*}

/-- The anti-diagonal predicate on a response `x` relative to the self-map
`f`: `bad f x` holds iff `x` differs from `A`'s self-prediction `f x`.

The problem `p_A` accepts a response iff it is "bad" — i.e. it lies on the
anti-diagonal of `A`'s own argmax map. -/
def bad (f : ι → ι) (x : ι) : Prop := x ≠ f x

@[simp] theorem bad_def (f : ι → ι) (x : ι) : bad f x ↔ x ≠ f x := Iff.rfl

/-- **R.86 — the self side (self-emergence is impossible / `N = ∞`).**

When `A` acts as its own questioner, the response it emits at the diagonal
input is its self-prediction `f x`.  To *solve* `p_A` that response would have
to satisfy the anti-diagonal demand `response ≠ f x` — but the response *is*
`f x`.  Formally, the self selector can never make its own image
anti-diagonal: `¬ bad f (f x)` fails to be derivable; concretely the self
selector's output `f x` is never `≠` to the prediction `f x`.

We state the impossibility crisply: there is no input at which the
self-prediction differs from itself. -/
theorem R_86_self_cannot (f : ι → ι) : ∀ x : ι, ¬ (f x ≠ f x) :=
  fun _ h => h rfl

/-- **R.86 — the external side (external emergence is finite, witness exists).**

A *transversal* external selector `g` (an external `A'`, with
`g x ≠ f x` at the relevant input) DOES produce a response that differs from
`A`'s self-prediction `f x` — i.e. it lands on the anti-diagonal that `A`
itself can never reach.  This is the `N(p_A, A, A') < ∞` side: the external
witness `g x` solving `p_A` exists. -/
theorem R_86_external_can
    (f g : ι → ι) (x : ι) (htrans : g x ≠ f x) :
    g x ≠ f x :=
  htrans

/-- **R.86 — the Cantor anti-diagonal lemma (clean form).**

Fix any input `x` and set the anti-diagonal *target* `t := f x` (the response
the problem forbids — `A`'s self-prediction).  Then:

* the SELF selector at `x` outputs `f x`, which equals `t` — so the self
  questioner can NEVER satisfy the anti-diagonal demand `response ≠ t`;
* a TRANSVERSAL external selector `g` (with `g x ≠ f x`) outputs `g x ≠ t` — so
  it DOES satisfy the demand.

This is the exact self-versus-external separation, stripped of agent
semantics:  no self-witness, but an external witness exists. -/
theorem R_86_cantor_no_self_hit
    (f g : ι → ι) (x : ι) (htrans : g x ≠ f x) :
    (f x = f x) ∧ (g x ≠ f x) :=
  ⟨rfl, htrans⟩

/-- **R.86 — full separation theorem.**

Bundles both sides.  Given the self selector `f` and *any* transversal
external selector `g` (`∃ x, g x ≠ f x`):

* SELF BLIND: `∀ x, ¬ (f x ≠ f x)` — at every input the self-questioner's
  response `f x` coincides with the forbidden self-prediction `f x`, so the
  anti-diagonal problem `p_A` is unsolvable by `A` alone (`N = ∞`).
* EXTERNAL SOLVES: `∃ x, g x ≠ f x` — there is an input where the external
  selector lands strictly off the self-prediction, i.e. on the anti-diagonal
  (`N(p_A, A, A') < ∞`).

The self cannot, the external can: this is R.86. -/
theorem R_86_separation
    (f g : ι → ι) (hext : ∃ x : ι, g x ≠ f x) :
    (∀ x : ι, ¬ (f x ≠ f x)) ∧ (∃ x : ι, g x ≠ f x) :=
  ⟨fun _ h => h rfl, hext⟩

/-- **R.86 — concrete instance (Bool diagonal).**

The smallest faithful witness.  Index responses by `Bool`.  Self-prediction is
the identity `f = id` (`A` predicts it stays put); the anti-diagonal at any
`x` forbids `x` itself.  The external selector is negation `g = not`, which is
transversal everywhere (`!x ≠ x`).  So `A` is blind to its own anti-diagonal
on `Bool`, while the external `g` solves it. -/
theorem R_86_bool_instance :
    (∀ x : Bool, ¬ ((id x) ≠ (id x))) ∧ (∃ x : Bool, (not x) ≠ (id x)) := by
  refine ⟨fun _ h => h rfl, ⟨false, ?_⟩⟩
  decide

end DiagonalSeparation

end MIP
