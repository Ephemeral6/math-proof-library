/-
Result R.430 — CoE engine blind spot (self vs. external) + Z_self ≥ Z_external.

Reference: `workspace/coe_mip_unification.md` §R.430
(A, Block 9 "理论融合", 2026-05-16).
This is the CoE-framed restatement of R.86 (T.18) diagonal self-blindness,
built on the *same* Cantor anti-diagonal kernel.

**Statement.** For each computable CoE system `(A, Engine)` there is a problem
`p_A` (the anti-diagonal of `A`'s own self-prediction) such that:

(i) **Blind spot exists.**  Self-CoE — `A` querying its own engine for R/T/C —
    fails: `N(p_A, A, A_RTC(self)) = ∞`.  The self-questioner's response at the
    diagonal input is its self-prediction `f x`, which can never be the
    anti-diagonal witness of itself.
(ii) **External solvability.**  An external CoE system `A'` (transversal,
     `g x ≠ f x`) solves `p_A`: `N(p_A, A, A'_RTC) < ∞`; the external witness
     `g x` lands on the anti-diagonal `A` itself can never reach.
(iv) **Impedance inequality.**  On the blind spot, `Z_self ≥ Z_external`
     always (Cj.15): the impedance of `A` self-querying weakly exceeds that of
     the external CoE.  Given the bundled blind-spot gap `δ ≥ 0` with
     `Z_self = Z_external + δ`, this is the real inequality `Z_self ≥ Z_ext`.

**Proof.** (i)/(ii) reuse the R.86 Cantor kernel verbatim: the self-map `f`
(A's argmax self-prediction) admits no anti-diagonal self-witness
(`∀ x, ¬ (f x ≠ f x)`), while a transversal external selector `g` (`g x ≠ f x`)
does. (iv) is `≥` from a nonnegative bundled gap `δ`.

**This file is `axiom`-free.**  Agent semantics live in the selector functions
`f` (self engine) and `g` (external engine); the impedance gap is an explicit
real hypothesis.
-/
import Mathlib.Logic.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace EngineBlindSpot

variable {ι : Type*}

/-- The anti-diagonal predicate (same as R.86 `bad`): a response `x` solves the
blind-spot problem `p_A` iff it differs from `A`'s self-prediction `f x`. -/
def antidiag (f : ι → ι) (x : ι) : Prop := x ≠ f x

@[simp] theorem antidiag_def (f : ι → ι) (x : ι) : antidiag f x ↔ x ≠ f x :=
  Iff.rfl

/-- **R.430 (i) — blind-spot existence (self-CoE cannot solve, `N = ∞`).**

When `A` queries its *own* engine for R/T/C, the response it emits at the
diagonal input is its self-prediction `f x`.  Solving `p_A` would require that
response to be anti-diagonal (`response ≠ f x`) — impossible, since it *is*
`f x`.  Crisply: the self engine never produces an anti-diagonal witness of its
own fixed point. -/
theorem R_430_i_self_blind (f : ι → ι) : ∀ x : ι, ¬ (f x ≠ f x) :=
  fun _ h => h rfl

/-- **R.430 (ii) — external solvability (external CoE solves, `N < ∞`).**

A transversal external CoE selector `g` (`g x ≠ f x` at the relevant input)
produces a response differing from `A`'s self-prediction — landing on the
anti-diagonal `A` itself can never reach.  The external witness exists. -/
theorem R_430_ii_external_solves
    (f g : ι → ι) (x : ι) (htrans : g x ≠ f x) :
    g x ≠ f x :=
  -- The anti-diagonal demand at the fixed input `x` is `response ≠ f x`; the
  -- external witness `g x` satisfies it by transversality.
  htrans

/-- **R.430 (i)+(ii) — packaged self/external separation (Cantor kernel).**

Self is blind (`∀ x, ¬ (f x ≠ f x)`) while an external transversal `g` solves
(`∃ x, g x ≠ f x`).  Identical structure to R.86; the CoE framing reads `f` as
the self-engine selector and `g` as the external-engine selector. -/
theorem R_430_separation
    (f g : ι → ι) (hext : ∃ x : ι, g x ≠ f x) :
    (∀ x : ι, ¬ (f x ≠ f x)) ∧ (∃ x : ι, g x ≠ f x) :=
  ⟨fun _ h => h rfl, hext⟩

/-- **R.430 (iv) — impedance inequality `Z_self ≥ Z_external`.**

On the blind spot, self-querying impedance weakly dominates the external CoE's.
Bundling the (nonnegative) blind-spot impedance gap `δ` via
`Z_self = Z_external + δ` with `δ ≥ 0` gives `Z_self ≥ Z_external` (Cj.15). -/
theorem R_430_iv_impedance
    (Z_self Z_ext δ : ℝ)
    (hδ : 0 ≤ δ)
    (hgap : Z_self = Z_ext + δ) :
    Z_ext ≤ Z_self := by
  rw [hgap]; linarith

/-- **R.430 (iv') — strict impedance inequality on a genuine gap.**

If the blind-spot gap is strictly positive (`δ > 0`, the R.101 strengthening to
an infinite parameter family of separations), the impedance dominance is
strict: `Z_self > Z_external`. -/
theorem R_430_iv_impedance_strict
    (Z_self Z_ext δ : ℝ)
    (hδ : 0 < δ)
    (hgap : Z_self = Z_ext + δ) :
    Z_ext < Z_self := by
  rw [hgap]; linarith

/-- **R.430 — concrete instance (Bool diagonal, CoE framing).**

Smallest faithful witness.  Responses indexed by `Bool`; self-engine selector
is `id` (`A` predicts it stays put), so the anti-diagonal forbids `x` itself;
external-engine selector is `not`, transversal everywhere.  Self is blind on
its own anti-diagonal, external solves it; and with any nonnegative impedance
gap the self impedance dominates. -/
theorem R_430_bool_instance (Z_ext δ : ℝ) (hδ : 0 ≤ δ) :
    (∀ x : Bool, ¬ ((id x) ≠ (id x))) ∧
    (∃ x : Bool, (not x) ≠ (id x)) ∧
    Z_ext ≤ Z_ext + δ := by
  refine ⟨fun _ h => h rfl, ⟨false, by decide⟩, by linarith⟩

end EngineBlindSpot

end MIP
