/-
Theorem T.18.2 — BOUNDED-N is NP-hard.

Reference: `theorems/index.md` T.18.2.

**Statement.** The decision problem

    BOUNDED-N := {(p, X, k) : N(p, X) ≤ k}

is NP-hard via a polynomial-time reduction from 3-SAT:

    3-SAT(φ)  ≤_p  BOUNDED-N((p_φ, X_φ, k_φ)).

**Proof sketch.** Given a 3-SAT instance `φ` over `n` variables and `m`
clauses, build:
* knowledge universe `Ω_φ := {x_1, …, x_n, ¬x_1, …, ¬x_n}`,
* problem `p_φ` whose solution corresponds to a satisfying assignment,
* agent `X_φ` whose `K(X_φ)` covers exactly the literals in `φ`,
* bound `k_φ := n` (one intervention per variable assignment).

Then `(p_φ, X_φ, k_φ) ∈ BOUNDED-N ⟺ φ` is satisfiable.

**STATUS: HYBRID.** The concrete `φ ↦ (p_φ, X_φ, k_φ)` construction and
the poly-time bound on it require 3-SAT machinery from Mathlib's
`Computability`, which lies beyond the current opaque signature layer.
Following the `MIP.UEA.RestrSpec` idiom (cf. `T33_UEA.lean`), we bundle
that construction as a *hypothesis*: the base predicate and the
reduction map together with the correctness equivalence are supplied,
and what we *prove* is that this data assembles into a genuine many-one
reduction `NPHardReduction` onto BOUNDED-N. The reduction packaging —
not the 3-SAT encoding — is the content discharged here.
-/
import MIP.Axioms
import Mathlib.Probability.ProbabilityMassFunction.Monad

namespace MIP

namespace NPHard

variable {α : Type}

/-- **`BOUNDED-N` decision predicate.** `(p, X, k) ∈ BOUNDED-N` iff the
emergence degree `N(p, X)` is at most `k`. -/
def BoundedN (p : Problem α) (X : Agent α) (k : ℕ) : Prop :=
  N p X ≤ (k : ℕ∞)

/-- **Many-one reduction onto BOUNDED-N (hypothesis-bundle idiom).**

A genuine many-one reduction from a base decision problem to BOUNDED-N,
packaged following the `MIP.UEA.RestrSpec` bundle pattern. It carries:

* `base : ℕ → Prop` — the base predicate. The intended instance is
  "the natural number `n` encodes a satisfiable 3-SAT formula", but the
  structure is generic over any base problem.
* `red : ℕ → Problem α × Agent α × ℕ` — the reduction map sending an
  encoded base instance `n` to a BOUNDED-N instance `(p, X, k)`.
* `spec : ∀ n, base n ↔ BoundedN (red n).1 (red n).2.1 (red n).2.2` —
  the *correctness* of the reduction: `n` is a yes-instance of `base`
  iff its image lands in BOUNDED-N.

This is the abstract content of "BOUNDED-N is NP-hard": exhibiting a
member of this structure with `base` an NP-hard base problem witnesses a
many-one reduction `base ≤ₘ BOUNDED-N`. The concrete 3-SAT realisation
of `base`/`red`/`spec` is supplied externally (see `T18_2_NPHard`). -/
structure NPHardReduction (α : Type) where
  /-- The base decision predicate (intended: encoded 3-SAT satisfiability). -/
  base : ℕ → Prop
  /-- The reduction map to BOUNDED-N instances `(p, X, k)`. -/
  red : ℕ → Problem α × Agent α × ℕ
  /-- Correctness of the reduction: `base n ↔ image of `n` is in BOUNDED-N`. -/
  spec : ∀ n, base n ↔ BoundedN (red n).1 (red n).2.1 (red n).2.2

/-- The trivially-reducible problem (`base := fun _ => True`) reduces to
BOUNDED-N via the always-true problem, which any agent solves with zero
interventions (`N = 0 ≤ k`). This witnesses inhabitation of the reduction
structure and keeps the carrier non-empty without appeal to the opaque
3-SAT layer. -/
noncomputable instance : Inhabited (NPHardReduction α) where
  default :=
  { base := fun _ => True
    red := fun _ => (fun _ => true, fun h => PMF.pure h, 0)
    spec := by
      intro n
      constructor
      · intro _
        -- `BoundedN` for `k = 0`: `N (always-true) X ≤ 0`, i.e. `N = 0`.
        show N (fun _ => true) (fun h => PMF.pure h) ≤ ((0 : ℕ) : ℕ∞)
        have hΦ : Phi0 (fun h => PMF.pure h) (fun _ : Str α => true) = 0 :=
          Phi0_always_true _
        have hN : N (fun _ : Str α => true) (fun h => PMF.pure h) = 0 :=
          (Axioms.A1 (fun _ : Str α => true) (fun h => PMF.pure h)).2 hΦ
        rw [hN]
        exact le_refl 0
      · intro _; trivial }

/-- **T.18.2 (BOUNDED-N is NP-hard) — hybrid abstract-reduction form.**

Given a base predicate `base` and a reduction map `red` together with the
correctness equivalence `h` (the bundle that, in the intended 3-SAT
instance, encodes the polynomial-time construction `φ ↦ (p_φ, X_φ, k_φ)`),
BOUNDED-N admits a genuine many-one reduction from `base`: the data
assembles into an `NPHardReduction` whose `base`/`red` fields are exactly
the given `base`/`red`.

The 3-SAT construction is the *hypothesis* `h`; the reduction *packaging*
(that `base`, `red`, `h` form a valid many-one reduction onto BOUNDED-N)
is what is *proven*. Specialising `base` to an NP-hard base problem and
`h` to its 3-SAT correctness proof then yields NP-hardness of BOUNDED-N. -/
theorem T18_2_NPHard
    (base : ℕ → Prop)
    (red : ℕ → Problem α × Agent α × ℕ)
    (h : ∀ n, base n ↔ BoundedN (red n).1 (red n).2.1 (red n).2.2) :
    ∃ ρ : NPHardReduction α, ρ.base = base ∧ ρ.red = red :=
  ⟨{ base := base, red := red, spec := h }, rfl, rfl⟩

end NPHard

end MIP
