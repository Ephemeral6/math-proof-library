/-
Corollary C.4 — Novice–Expert convergence.  Reference: `proofs/corollaries.md` C.4.

**Statement.** For an expert intervention sequence `σ_e = (e₁,…,e_l)`
with `N_expert = l`, and per-intervention knowledge densities
`C_{eᵢ} := Cₑ(eᵢ)`:

    N_novice(p, A)  ≤  Σ_{i=1}^{l} C_{eᵢ}                    (i)
    N_novice(p, A) − N_expert(p, A)  ≤  Σ_{i=1}^{l} (C_{eᵢ} − 1)  (ii)

**NL content.** By A.3 (corrected) each expert intervention `eᵢ` (whose
encoded knowledge lies in `K(A)`) is replaced by a meta-cognitive block
`σᵢ^m` of length `kᵢ ≤ C_{eᵢ}`.  Concatenating the blocks gives a pure
novice sequence of total length `Σ kᵢ ≤ Σ C_{eᵢ}`, hence (i).  Since
`N_expert = l`, subtracting gives (ii) by `Σ C_{eᵢ} − l = Σ (C_{eᵢ}−1)`.
With `C_{eᵢ} ≥ 1` each term `C_{eᵢ}−1 ≥ 0`, so the gap is nonnegative.

**Kernel formalized here.** The exact telescoping identity and the two
bounds, as a real-arithmetic kernel over `Fin l → ℝ` (the costs
`C_{eᵢ} = (Cₑ eᵢ : ℝ)`), faithfully mirroring the R.69 modelling style:

* `telescoping_identity` : `Σ (C i − 1) = (Σ C i) − l`  (exact).
* `novice_le_sum_cost`   : (i), taken as the A.3-supplied hypothesis
  `N_novice ≤ Σ C i` (the per-block length bound `kᵢ ≤ C_{eᵢ}` summed).
* `novice_minus_expert_le` : (ii), derived from (i) + the identity +
  `N_expert = l`.
* `gap_nonneg` : with each `C i ≥ 1`, `Σ (C i − 1) ≥ 0`.

A.3's existence-of-replacement content (`∃ ms, |ms| ≤ Cₑ e · log(1/ε)`)
is the bridge feeding the summed hypothesis `N_novice ≤ Σ C i`; we take
that summed bound as input and prove the algebraic consequence exactly.

Axiom-free (only A.1–A.4); pure real arithmetic, no axiom used.
-/
import MIP.Axioms
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset

namespace MIP

namespace Corollary_C4

open scoped BigOperators

variable {l : ℕ} (C : Fin l → ℝ)

/-- **C.4 telescoping identity (exact).**

`Σ_{i} (C_{eᵢ} − 1) = (Σ_{i} C_{eᵢ}) − l`. -/
theorem telescoping_identity :
    ∑ i : Fin l, (C i - 1) = (∑ i : Fin l, C i) - (l : ℝ) := by
  rw [Finset.sum_sub_distrib]
  simp

/-- **C.4 (ii) — novice/expert gap bound.**

Given the A.3-supplied length bound `N_novice ≤ Σ C_{eᵢ}` (i) and
`N_expert = l`,

    N_novice − N_expert  ≤  Σ_{i} (C_{eᵢ} − 1). -/
theorem novice_minus_expert_le
    {N_novice N_expert : ℝ}
    (hNov : N_novice ≤ ∑ i : Fin l, C i)
    (hExp : N_expert = (l : ℝ)) :
    N_novice - N_expert ≤ ∑ i : Fin l, (C i - 1) := by
  rw [telescoping_identity, hExp]
  linarith

/-- **C.4 (i) — total novice cost bound (restated).**

The hypothesis `N_novice ≤ Σ C_{eᵢ}` is precisely C.4 (i); we expose it
as a lemma so downstream callers can name it. -/
theorem novice_le_sum_cost
    {N_novice : ℝ} (hNov : N_novice ≤ ∑ i : Fin l, C i) :
    N_novice ≤ ∑ i : Fin l, C i := hNov

/-- **C.4 gap nonnegativity.**

With each density `C_{eᵢ} ≥ 1` (at least one meta-cognitive intervention
replaces each expert one), the per-term cost `C_{eᵢ} − 1 ≥ 0`, so

    Σ_{i} (C_{eᵢ} − 1)  ≥  0. -/
theorem gap_nonneg (hC : ∀ i, 1 ≤ C i) :
    0 ≤ ∑ i : Fin l, (C i - 1) :=
  Finset.sum_nonneg (fun i _ => by linarith [hC i])

/-- **C.4 (combined).**  Under `C_{eᵢ} ≥ 1`, `N_expert = l`, and the
A.3 length bound, the gap is sandwiched: `0 ≤ N_novice − N_expert ≤
Σ (C_{eᵢ} − 1)` whenever additionally `N_expert ≤ N_novice`. -/
theorem gap_sandwich
    {N_novice N_expert : ℝ}
    (_hC : ∀ i, 1 ≤ C i)
    (hNov : N_novice ≤ ∑ i : Fin l, C i)
    (hExp : N_expert = (l : ℝ))
    (hOrd : N_expert ≤ N_novice) :
    0 ≤ N_novice - N_expert ∧
      N_novice - N_expert ≤ ∑ i : Fin l, (C i - 1) :=
  ⟨by linarith, novice_minus_expert_le C hNov hExp⟩

/-! ### Concrete instantiation with the MIP density `Cₑ`

When the expert sequence is given as `e : Fin l → Str α` and the costs
are the genuine MIP knowledge densities `Cₑ (e i)`, the same kernel
applies verbatim with `C i := (Cₑ (e i) : ℝ)`.  (`Cₑ : Str α → NNReal`,
and `(· : NNReal) → ℝ` is `≥ 0`; the hypothesis `1 ≤ Cₑ(eᵢ)` is the
A.3 regularity condition.) -/

variable {α : Type}

/-- **C.4 (ii) with the MIP density `Cₑ`.** -/
theorem novice_minus_expert_le_Cₑ
    (e : Fin l → Str α)
    {N_novice N_expert : ℝ}
    (hNov : N_novice ≤ ∑ i : Fin l, (Cₑ (e i) : ℝ))
    (hExp : N_expert = (l : ℝ)) :
    N_novice - N_expert ≤ ∑ i : Fin l, ((Cₑ (e i) : ℝ) - 1) :=
  novice_minus_expert_le (fun i => (Cₑ (e i) : ℝ)) hNov hExp

end Corollary_C4

end MIP
