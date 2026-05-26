/-
Result R.453 — φ : Param → Phase is a functor; dS/dt = J·(dθ/dt) is the
tangent functor.

Reference: `workspace/categorical_formalization.md` R.453 (A).

**Statement (formalized kernel).** `φ : Θ → S` maps a parameter
configuration to its phase observable `S(θ) = (|K|, Z⁻¹, H_K, κ)`. We
formalize the differential (tangent-functor / chain-rule) content:

* **(b) tangent functor / chain rule along a path.** Given a smooth path
  `θ : ℝ → E` (E the parameter space, `θ' = dθ/dt`) and a differentiable
  map `φ : E → F` with Fréchet derivative (Jacobian) `J := Dφ_{θ(t)}`,
  the composite `φ∘θ` has derivative `J·(θ'(t))`. This is R.150 (★1):
  `dS/dt = J·(dθ/dt)`. In Mathlib, `J` is the continuous linear map `J`
  and `J·v = J v`; the multivariate chain rule is
  `HasFDerivAt.comp_hasDerivAt`.

* **(a) functor preserves identity.** The constant (identity) path
  `id_θ(t) = θ` has zero tangent; `φ` of it is the constant phase path
  `S(θ)`, which also has zero tangent. So `φ` sends `id_θ` to `id_{S(θ)}`
  (the differential statement of identity preservation).

* **(a) functor preserves composition.** Two chain-rule applications
  compose: if `ψ : ℝ → E` is a reparametrization with `(θ∘ψ)` the
  spliced path, the derivative of `φ∘θ∘ψ` factors as the product of the
  Jacobian and the inner path derivatives — composition of tangent maps.

* **(c) structure-preservation (linearity of the tangent map).** The
  tangent map `v ↦ J·v` is ℝ-linear: it preserves the additive/scaling
  structure on tangent vectors (the natural-gradient structure under the
  R.150 (H1)+(H2)+(H3) corner; here we encode the unconditional linear
  core `J(v + w) = J v + J w`, `J(c·v) = c·(J v)`).

**What was reduced to a kernel.** The categorical statement "φ preserves
id and composition" is encoded at the level of its *tangent functor*
`Tφ` (the only piece that carries analytic content). The path-category
structure on `Param`/`Phase` (objects = configs, morphisms = smooth
trajectories) is documented; we formalize the derivative identity that
*is* the local representation of `Tφ`.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.Calculus.Deriv.Comp
import Mathlib.Analysis.Calculus.FDeriv.Const
import Mathlib.Analysis.Calculus.Deriv.Basic

namespace MIP

namespace PhaseFunctor

open ContinuousLinearMap

variable {E F : Type*}
  [NormedAddCommGroup E] [NormedSpace ℝ E]
  [NormedAddCommGroup F] [NormedSpace ℝ F]

/-- **R.453 (b) — tangent functor / chain rule along a path.**

Let `θ : ℝ → E` be a smooth parameter path with `HasDerivAt θ θ' t`, and
let `φ : E → F` have Fréchet derivative (Jacobian) `J` at `θ t`. Then the
phase path `φ ∘ θ` has derivative `J (θ')` at `t`:

    dS/dt = J · (dθ/dt)            (R.150 ★1).

This is the local representation of the tangent functor `Tφ`. -/
theorem R_453_b_tangent_chain_rule
    (φ : E → F) (θ : ℝ → E) (t : ℝ) (θ' : E) (J : E →L[ℝ] F)
    (hφ : HasFDerivAt φ J (θ t)) (hθ : HasDerivAt θ θ' t) :
    HasDerivAt (φ ∘ θ) (J θ') t :=
  hφ.comp_hasDerivAt t hθ

/-- **R.453 (a) — functor preserves identities (differential form).**

The identity (constant) path `id_θ(t) = θ₀` has zero tangent. Its image
under `φ` is the constant phase path `t ↦ φ θ₀`, whose tangent is also
zero — and equals `J·0 = 0`. Thus `φ` maps `id_θ` to `id_{φ θ₀}`. -/
theorem R_453_a_preserves_id
    (φ : E → F) (θ₀ : E) (t : ℝ) (J : E →L[ℝ] F)
    (hφ : HasFDerivAt φ J θ₀) :
    HasDerivAt (φ ∘ (fun _ : ℝ => θ₀)) (J 0) t := by
  have hconst : HasDerivAt (fun _ : ℝ => θ₀) (0 : E) t := hasDerivAt_const t θ₀
  have hcomp := hφ.comp_hasDerivAt t hconst
  simpa using hcomp

/-- **R.453 (a) — `J·0 = 0`: the identity path maps to the identity.**

Confirms the constant-path image is the genuine identity tangent
`id_{φ θ₀} = 0`, completing identity preservation. -/
theorem R_453_a_id_tangent_zero (J : E →L[ℝ] F) : J 0 = 0 :=
  map_zero J

/-- **R.453 (a) — functor preserves composition (tangent functoriality).**

For a reparametrization `ψ : ℝ → ℝ` with `HasDerivAt ψ ψ' s` and a path
`θ : ℝ → E`, the doubly-composed phase path `φ ∘ θ ∘ ψ` has derivative
`(J θ') · ψ'` — the composition of the two tangent maps. This is the
differential statement `Tφ(g₂ ∘ g₁) = Tφ(g₂) ∘ Tφ(g₁)` (chain rule of
chain rules). -/
theorem R_453_a_preserves_comp
    (φ : E → F) (θ : ℝ → E) (ψ : ℝ → ℝ) (s : ℝ) (ψ' : ℝ) (θ' : E)
    (J : E →L[ℝ] F)
    (hψ : HasDerivAt ψ ψ' s)
    (hθ : HasDerivAt θ θ' (ψ s))
    (hφ : HasFDerivAt φ J (θ (ψ s))) :
    HasDerivAt (φ ∘ θ ∘ ψ) (ψ' • (J θ')) s := by
  -- inner: θ ∘ ψ has derivative ψ' • θ'
  have hθψ : HasDerivAt (θ ∘ ψ) (ψ' • θ') s := hθ.scomp s hψ
  -- outer: φ ∘ (θ ∘ ψ) has derivative J (ψ' • θ') = ψ' • J θ'
  have hcomp : HasDerivAt (φ ∘ (θ ∘ ψ)) (J (ψ' • θ')) s :=
    hφ.comp_hasDerivAt s hθψ
  have hmap : J (ψ' • θ') = ψ' • J θ' := by rw [map_smul]
  rw [hmap] at hcomp
  exact hcomp

/-- **R.453 (c) — tangent map is additive (structure preservation, part 1).**

`Tφ : v ↦ J·v` preserves addition of tangent vectors:
`J (v + w) = J v + J w`. The natural-gradient / Riemannian structure of
R.150 (H1)+(H2)+(H3) is built on this linear core. -/
theorem R_453_c_tangent_additive (J : E →L[ℝ] F) (v w : E) :
    J (v + w) = J v + J w :=
  map_add J v w

/-- **R.453 (c) — tangent map is homogeneous (structure preservation, part 2).**

`Tφ` preserves scalar multiplication: `J (c·v) = c·(J v)`. Together with
additivity this is full ℝ-linearity of the tangent functor. -/
theorem R_453_c_tangent_homogeneous (J : E →L[ℝ] F) (c : ℝ) (v : E) :
    J (c • v) = c • J v :=
  map_smul J c v

end PhaseFunctor

end MIP
