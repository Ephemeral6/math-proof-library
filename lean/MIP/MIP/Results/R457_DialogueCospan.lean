/-
Result R.457 — Multi-agent dialogue as a labeled cospan; the role-swap
`σ` (N ↔ N*) duality is an involution.

Reference: `workspace/categorical_formalization.md` R.457 (A 条件性).

**Statement (algebraic core).** A multi-agent dialogue `(X, Y, h)` is
modelled as a *labeled cospan*

    X_solver --r--> h <--m-- Y_questioner

in `Cospan(Σ*)`, with `h` the shared (cumulatively-constructed) dialogue
state, `r` the solver's response edge and `m` the questioner's
metacognitive-intervention edge.  The role-swap operator `σ` exchanges
the solver/questioner roles:

    σ : (X_solver --r--> h <--m-- Y_questioner)
          ↦  (Y_solver --m'--> h^op <--r'-- X_questioner)

and carries the cost metric `N(p, X, Y)` to `N(p, Y, X) =: N*(p, X, Y)`.

**Crisp content (this file).**  `σ` is a strict **involution**:
`σ (σ q) = q` (R.457 (e), `σ² = id`), and it swaps the two cost values
`N ↔ N*`.  This reuses the `Obs.dual` / `dual_dual` involution pattern
from `R142_DualAlgebra.lean`.  We model the data of a labeled cospan by
its solver/questioner endpoints together with the two cost values
`(N, N*)`, and prove:

* `swap_swap`     : `σ (σ q) = q`                    (involution, σ² = id)
* `swap_N`        : `(σ q).N = q.Nstar`              (σ sends N to N*)
* `swap_Nstar`    : `(σ q).Nstar = q.N`              (σ sends N* to N)
* `swap_endpoints`: σ exchanges solver/questioner endpoints
* `R_132_sigma_invariant` : `N + N*` is σ-invariant  (R.458 cross-link)
* `fixed_iff`     : `σ q = q ↔ q.N = q.Nstar ∧ endpoints symmetric`

The full Cospan-category construction (objects/morphisms/composition in
`Cospan(Σ*)`) is intentionally omitted; the σ-involution + N↔N* swap is
the robust algebraic kernel.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

namespace MIP

namespace DialogueCospan

/-- The data of a labeled cospan in `Cospan(Σ*)`, abstracted to its
endpoint labels and cost values.

* `solver`     : the agent currently in the solver role (`X` side label),
* `questioner` : the agent currently in the questioner role (`Y` side label),
* `N`          : the cost `N(p, solver, questioner)` — minimal number of
                 questioner edges `Y → h` that solve `p`,
* `Nstar`      : the dual cost `N*(p, solver, questioner) = N(p, questioner, solver)`.

We use `ℕ` for the agent labels (any type with decidable equality would
do); the cost values are reals matching the MIP-side convention. -/
structure Cospan where
  solver     : ℕ
  questioner : ℕ
  N          : ℝ
  Nstar      : ℝ

namespace Cospan

/-- **The role-swap operator `σ` (R.457 (e)).**

`σ` exchanges the solver/questioner endpoints and swaps the two cost
values `N ↔ N*`.  This is the labeled-cospan dagger: a contravariant
involutive operation. -/
def swap (q : Cospan) : Cospan :=
  ⟨q.questioner, q.solver, q.Nstar, q.N⟩

/-- **R.457 (e) — `σ` is a strict involution: `σ² = id`.**

Applying the role-swap twice returns the original cospan.  This is the
defining property of the dagger / contravariant involutive functor.
Mirrors `Obs.dual_dual` from `R142_DualAlgebra.lean`. -/
@[simp] theorem swap_swap (q : Cospan) : swap (swap q) = q := rfl

/-- **R.457 (e) — `σ` sends the cost `N` to `N*`.** -/
@[simp] theorem swap_N (q : Cospan) : (swap q).N = q.Nstar := rfl

/-- **R.457 (e) — `σ` sends the dual cost `N*` to `N`.** -/
@[simp] theorem swap_Nstar (q : Cospan) : (swap q).Nstar = q.N := rfl

/-- **R.457 (e) — `σ` exchanges the solver endpoint with the questioner
endpoint.** -/
@[simp] theorem swap_solver (q : Cospan) : (swap q).solver = q.questioner := rfl

/-- **R.457 (e) — `σ` exchanges the questioner endpoint with the solver
endpoint.** -/
@[simp] theorem swap_questioner (q : Cospan) : (swap q).questioner = q.solver := rfl

/-- **R.457 (e) — `σ ∘ σ = id` as a function identity.**

The composite of the role-swap with itself is the identity map on the
labeled-cospan data — the global form of `swap_swap`. -/
theorem swap_comp_swap : swap ∘ swap = id := by
  funext q; exact swap_swap q

/-- **R.457 (e) — `σ` is injective.** An involution is its own inverse,
hence a bijection. -/
theorem swap_injective : Function.Injective swap := by
  intro q₁ q₂ h
  have := congrArg swap h
  simpa only [swap_swap] using this

/-- **R.457 (e) — `σ` is bijective** (its own two-sided inverse). -/
theorem swap_bijective : Function.Bijective swap :=
  ⟨swap_injective, fun q => ⟨swap q, swap_swap q⟩⟩

/-- **R.457 (e) ↔ R.458 — the sum `N + N*` is σ-invariant.**

`N(p, X, Y) + N*(p, X, Y) = N(p, Y, X) + N*(p, Y, X)`: the role-swap
fixes the symmetric (S₂-trivial) part of the cost.  This is the
categorical root of the R.132 conservation law (R.458). -/
theorem R_132_sigma_invariant (q : Cospan) :
    (swap q).N + (swap q).Nstar = q.N + q.Nstar := by
  show q.Nstar + q.N = q.N + q.Nstar
  ring

/-- **R.457 (e) — the difference `N − N*` is σ-antisymmetric.**

`σ` sends `N − N*` to its negative: the antisymmetric (S₂-sign) part of
the cost flips under the role-swap. -/
theorem diff_sigma_antisymmetric (q : Cospan) :
    (swap q).N - (swap q).Nstar = -(q.N - q.Nstar) := by
  show q.Nstar - q.N = -(q.N - q.Nstar)
  ring

/-- **R.457 (e) — characterisation of σ-fixed cospans.**

A labeled cospan is fixed by the role-swap (`σ q = q`) iff its two
endpoints coincide *and* the two cost values agree (`N = N*`).  These are
exactly the "symmetric collaboration" cospans where the labeled
distinction (solver vs questioner) carries no metric residual — the
`Asym = 0` regime of R.458 (e). -/
theorem fixed_iff (q : Cospan) :
    swap q = q ↔
      q.solver = q.questioner ∧ q.N = q.Nstar := by
  constructor
  · intro h
    -- Project `h : σ q = q` to the relevant components.  By `swap`:
    --   (σ q).questioner = q.solver, (σ q).Nstar = q.N.
    have h_sq : q.solver = q.questioner := congrArg Cospan.questioner h
    have h_N  : q.N = q.Nstar := congrArg Cospan.Nstar h
    exact ⟨h_sq, h_N⟩
  · rintro ⟨hsq, hN⟩
    cases q with
    | mk solver questioner N Nstar =>
      simp only at hsq hN
      show Cospan.mk questioner solver Nstar N
            = Cospan.mk solver questioner N Nstar
      rw [hsq, hN]

end Cospan

end DialogueCospan

end MIP
