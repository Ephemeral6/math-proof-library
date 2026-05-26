/-
Result R.454 — φ is a lens in the reverse-derivative category; the lens
back-map is `φ₋(θ, ξ) = Jᵀ·ξ`; gradient descent = lens composition.

Reference: `workspace/categorical_formalization.md` R.454 (A 条件性).

**Statement (formalized kernel).** A lens `(φ₊, φ₋)` on `φ : Θ → S`
equips the forward map `φ₊ = φ` with a backward map
`φ₋(θ, ξ) := Jᵀ·ξ` (transpose-Jacobian acting on a cotangent vector
`ξ ∈ T*S`). We formalize the **lens back-map algebra**:

* **back-map definition** `put J ξ := Jᵀ *ᵥ ξ` (transpose-matrix times
  vector), the cotangent pullback that gradient descent uses.

* **reverse-composition law (the lens chain rule)**
  `(J₂ ⬝ J₁)ᵀ = J₁ᵀ ⬝ J₂ᵀ` (`Matrix.transpose_mul`). This *transpose
  reversal* IS the functoriality `(φ∘ψ)₋ = ψ₋ ∘ φ₋`: the back-map of a
  composite is the *reversed* composite of back-maps — exactly reverse
  mode auto-differentiation / backprop.

* **back-map of composite = composite of back-maps (on vectors)**
  `put (J₂ * J₁) ξ = put J₁ (put J₂ ξ)`: pulling a cotangent back through
  `J₂*J₁` equals pulling it first through `J₂`, then `J₁` — the
  contravariant (reversed-order) functor law of the gradient lens.

* **linearity of the back-map** `φ₋(θ, ·)` is additive in `ξ`:
  `Jᵀ·(ξ + η) = Jᵀ·ξ + Jᵀ·η` (cotangent vectors add linearly under
  pullback), the structural compatibility needed for gradient
  accumulation.

* **involutivity** `(Jᵀ)ᵀ = J`: forward and backward maps are mutually
  dual (the dagger / lens coherence relating `Tφ` and `T*φ`).

**What was reduced to a kernel.** The full reverse-derivative category
(RDC, Cockett–Cruttwell) statement — smooth Riemannian manifolds,
cartesian structure, the Cruttwell–Gavranović–Ghani–Wilson
parametrized-lens monoidal category — is documented but not encoded; it
needs manifold/RDC machinery not cleanly in Mathlib. We formalize the
clean linear-algebraic kernel: the transpose-reversal law that *is* the
lens chain rule, on Mathlib `Matrix`.

**This file is `axiom`-free.**
-/
import Mathlib.Data.Matrix.Mul
import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Fintype.Basic

namespace MIP

namespace GradientLens

open Matrix

variable {P Q R : Type*} [Fintype P] [Fintype Q] [Fintype R]
variable {𝕜 : Type*} [CommRing 𝕜]

/-- **R.454 (a) — lens back-map `φ₋(θ, ξ) = Jᵀ·ξ`.**

Given a Jacobian `J : Matrix Q P 𝕜` (the linearization `dφ : ℝᴾ → ℝ^Q`),
the lens backward map sends a cotangent `ξ ∈ T*S = (Q → 𝕜)` to
`Jᵀ *ᵥ ξ ∈ T*Θ = (P → 𝕜)`. -/
def put (J : Matrix Q P 𝕜) (ξ : Q → 𝕜) : P → 𝕜 :=
  Jᵀ *ᵥ ξ

omit [Fintype P] [Fintype R] in
/-- **R.454 (b) — reverse-composition law (the lens chain rule).**

`(J₂ ⬝ J₁)ᵀ = J₁ᵀ ⬝ J₂ᵀ`. The transpose of a Jacobian product reverses
order — this IS the back-map functoriality `(φ∘ψ)₋ = ψ₋ ∘ φ₋`
(reverse-mode AD / backprop). -/
theorem R_454_b_transpose_reversal
    (J₂ : Matrix R Q 𝕜) (J₁ : Matrix Q P 𝕜) :
    (J₂ * J₁)ᵀ = J₁ᵀ * J₂ᵀ :=
  Matrix.transpose_mul J₂ J₁

omit [Fintype P] in
/-- **R.454 (b) — back-map of a composite = reversed composite of
back-maps (on cotangent vectors).**

`put (J₂ ⬝ J₁) ξ = put J₁ (put J₂ ξ)`. Pulling a cotangent `ξ` back
through the composite `J₂*J₁` equals pulling it first through `J₂` (the
outer map's back-map) and then through `J₁` (the inner map's back-map):
the *contravariant* functor law of the gradient lens. -/
theorem R_454_b_put_comp
    (J₂ : Matrix R Q 𝕜) (J₁ : Matrix Q P 𝕜) (ξ : R → 𝕜) :
    put (J₂ * J₁) ξ = put J₁ (put J₂ ξ) := by
  unfold put
  rw [Matrix.transpose_mul]
  rw [Matrix.mulVec_mulVec]

omit [Fintype P] in
/-- **R.454 (b) — back-map is additive in the cotangent (lens linearity).**

`φ₋(θ, ξ + η) = φ₋(θ, ξ) + φ₋(θ, η)`. Cotangent vectors add linearly
under pullback — the structural compatibility used for gradient
accumulation across a batch. -/
theorem R_454_b_put_additive
    (J : Matrix Q P 𝕜) (ξ η : Q → 𝕜) :
    put J (ξ + η) = put J ξ + put J η := by
  unfold put
  rw [Matrix.mulVec_add]

omit [Fintype P] [Fintype Q] [CommRing 𝕜] in
/-- **R.454 (a) — forward/backward duality (lens coherence / dagger).**

`(Jᵀ)ᵀ = J`: the back-map's linearization is the transpose of the
forward map's, and applying transpose twice recovers the forward
Jacobian — the involutive coherence relating `Tφ` and `T*φ`. -/
theorem R_454_a_transpose_involutive (J : Matrix Q P 𝕜) :
    (Jᵀ)ᵀ = J :=
  Matrix.transpose_transpose J

omit [Fintype P] in
/-- **R.454 (c) — gradient-descent backward step.**

The lens back-map applied to a loss cotangent `∇_S L ∈ T*S` gives the
parameter-space gradient `Jᵀ·∇_S L ∈ T*Θ`, which is the descent
direction (R.150 ★3 vanilla SGD). Stated as the literal back-map
evaluation: the descent gradient is exactly `put J (∇_S L)`. -/
theorem R_454_c_descent_gradient
    (J : Matrix Q P 𝕜) (gradS : Q → 𝕜) :
    put J gradS = Jᵀ *ᵥ gradS :=
  rfl

end GradientLens

end MIP
