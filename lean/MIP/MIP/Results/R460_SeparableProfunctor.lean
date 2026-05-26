/-
Result R.460 — the T.8 emergent Ohm law `N ≈ Φ₀ · Z` is a separable
(bilinear) cost pair: a profunctor `Prob^op × Agents → Cost` that factors
as `Φ₀ ⊗ Z`, where `Cost = (ℝ_{>0}, ·, 1)` is the Lawvere cost category.

Reference: `workspace/categorical_formalization.md` §R.460
(A 条件性, 2026-05-16, second-round categorical extension).

**Statement (algebraic kernel).**  T.8: `N(p, A) ≈ ⌈Φ₀(p,A) · Z(A)⌉`.
Stripping the ceiling, the *cost* `N : Prob × Agents → Cost` is the
product of two single-variable cost functors:

    N p A  =  Φ₀ p · Z A          (separable / rank-one profunctor)

The cost object lives in the **Lawvere cost category**
`Cost = B(ℝ_{>0}, ·, 1)` — the one-object category whose hom-monoid is
`(ℝ_{>0}, ·, 1)`.  Its composition is multiplication and it is a
*commutative* monoid.

This file formalises, all `axiom`-free:

* `Cost := {x : ℝ // 0 < x}` is a `CommMonoid` under multiplication with
  unit `1` (the Lawvere cost category's composition), and the product
  monoid is well-defined (`R_460_cost_commMonoid`, `R_460_cost_mul_comm`);
* the separable profunctor `N p A := Φ₀ p * Z A` **factors** as the
  composite `mult ∘ (Φ₀ × Z)` (`R_460_separable`,
  `R_460_factors_through_product`);
* **bilinearity / separability**: `N` is multiplicative in each argument
  separately (`R_460_left_multiplicative`, `R_460_right_multiplicative`),
  the defining property of a rank-one (separable) profunctor;
* the **multiplicative conservation law** of R.460's corollary: rescaling
  `Φ₀ → λ·Φ₀`, `Z → Z/λ` leaves `N` invariant
  (`R_460_rescale_invariant`), the categorical root of the efficiency
  ratio `ρ = Z/Φ₀`.

**What is reduced (documented).**  The full enriched-category statement of
R.460 (c) — `N` as the internal hom in `Cost`-enriched `Cat`, and the
end/coend reformulation O.11 — is *not* built as enriched-categorical
infrastructure; instead the load-bearing kernel (separability = product
factorisation, with `Cost` an honest commutative monoid) is proved as
clean monoid algebra over the positive reals.  This is exactly the
"separable/bilinear pair" content of parts (a), (b), (d).

**This file is `axiom`-free.**
-/
import Mathlib.Algebra.Order.Positive.Ring
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring

namespace MIP

namespace SeparableProfunctor

/-- The **Lawvere cost object** `Cost = ℝ_{>0}`: the positive reals, whose
monoid composition is multiplication.  As the hom-monoid of the
one-object Lawvere category `B(ℝ_{>0}, ·, 1)`, this is the value object of
the cost profunctor. -/
abbrev Cost : Type := {x : ℝ // 0 < x}

/-- **R.460 — `Cost` is a commutative monoid under multiplication.**

The Lawvere cost category's composition `·` makes `Cost` a `CommMonoid`
with unit `1`.  (Mathlib's positive-cone instance; recorded here as the
load-bearing structural fact.) -/
theorem R_460_cost_commMonoid : Nonempty (CommMonoid Cost) := ⟨inferInstance⟩

/-- **R.460 — composition in `Cost` is commutative.**  `c₁ · c₂ = c₂ · c₁`.
This is the commutativity of the Lawvere cost category's hom-monoid. -/
theorem R_460_cost_mul_comm (c₁ c₂ : Cost) : c₁ * c₂ = c₂ * c₁ := mul_comm c₁ c₂

/-- **R.460 — the unit of `Cost`.**  `1 · c = c`. -/
theorem R_460_cost_one_mul (c : Cost) : (1 : Cost) * c = c := one_mul c

/-- Composition in `Cost` is the genuine product of positive reals:
`(c₁ · c₂ : ℝ) = c₁ · c₂`.  Confirms the Lawvere composition is literal
multiplication. -/
theorem R_460_cost_coe_mul (c₁ c₂ : Cost) : ((c₁ * c₂ : Cost) : ℝ) = (c₁ : ℝ) * (c₂ : ℝ) :=
  rfl

section Profunctor

-- `Prob` = problem objects, `Agents` = agent objects.
variable {Prob : Type*} {Agents : Type*}
-- `Φ₀ : Prob → Cost` is the emergent-potential cost functor,
-- `Z : Agents → Cost` is the impedance cost functor.
variable (Φ₀ : Prob → Cost) (Z : Agents → Cost)

/-- The **separable cost profunctor** `N : Prob × Agents → Cost`,
`N p A := Φ₀ p · Z A` (T.8 emergent Ohm law, ceiling stripped). -/
def N (p : Prob) (A : Agents) : Cost := Φ₀ p * Z A

/-- The multiplication map of the Lawvere cost category, `mult : Cost × Cost → Cost`. -/
def mult (c : Cost × Cost) : Cost := c.1 * c.2

/-- **R.460 (a)(b) — separability: `N` factors as `mult ∘ (Φ₀ × Z)`.**

The profunctor `N` is the composite
`Prob × Agents → Cost × Cost → Cost`, first applying the pair of cost
functors `(Φ₀, Z)` then composing in `Cost`.  This is precisely the
statement that `N` is a *separable* (rank-one) profunctor `Φ₀ ⊗ Z`. -/
theorem R_460_separable (p : Prob) (A : Agents) :
    N Φ₀ Z p A = mult (Φ₀ p, Z A) := rfl

/-- **R.460 (b) — factorisation through the product, function form.**

`N = mult ∘ (Φ₀ × Z)`, stated as the pointwise equality of the curried
profunctor with the composite `Prob × Agents → Cost × Cost → Cost`. -/
theorem R_460_factors_through_product :
    (fun (pA : Prob × Agents) => N Φ₀ Z pA.1 pA.2)
      = (fun (pA : Prob × Agents) => mult (Φ₀ pA.1, Z pA.2)) := rfl

/-- **R.460 (b) — left-multiplicativity (bilinearity in the `Prob` slot).**

Holding the agent `A` fixed, the partial map `p ↦ N p A` *is* the cost
functor `Φ₀` rescaled by the constant `Z A`; it carries multiplicative
structure of `Φ₀` to `N`.  Concretely, if the emergent potential of `q`
is the product `Φ₀ p₁ · Φ₀ p₂`, then `N q A` equals `N p₁ A · Φ₀ p₂`
(equivalently `Φ₀ p₁ · N p₂ A`).  This is one slot of separability,
stated division-free in the commutative cost monoid. -/
theorem R_460_left_multiplicative (p₁ p₂ : Prob) (A : Agents)
    (q : Prob) (hq : Φ₀ q = Φ₀ p₁ * Φ₀ p₂) :
    N Φ₀ Z q A = N Φ₀ Z p₁ A * Φ₀ p₂ := by
  show Φ₀ q * Z A = Φ₀ p₁ * Z A * Φ₀ p₂
  rw [hq]
  apply Subtype.ext
  show (Φ₀ p₁ : ℝ) * Φ₀ p₂ * Z A = Φ₀ p₁ * Z A * Φ₀ p₂
  ring

/-- **R.460 (b) — right-multiplicativity (bilinearity in the `Agents` slot).**

Symmetrically, holding the problem `p` fixed, `A ↦ N p A` carries the
multiplicative structure of `Z`.  If `Z B = Z A₁ · Z A₂` then
`N p B = N p A₁ · Z A₂`. -/
theorem R_460_right_multiplicative (p : Prob) (A₁ A₂ : Agents)
    (B : Agents) (hB : Z B = Z A₁ * Z A₂) :
    N Φ₀ Z p B = N Φ₀ Z p A₁ * Z A₂ := by
  show Φ₀ p * Z B = Φ₀ p * Z A₁ * Z A₂
  rw [hB]
  apply Subtype.ext
  show (Φ₀ p : ℝ) * (Z A₁ * Z A₂) = Φ₀ p * Z A₁ * Z A₂
  ring

/-- **R.460 (b) — rank-one / separability exchange identity.**

The hallmark of a *separable* (rank-one) profunctor: the cross products
agree,
    `N p₁ A₁ · N p₂ A₂ = N p₁ A₂ · N p₂ A₁`.
This is the coordinate-free statement that `N` factors as `Φ₀ ⊗ Z`
(no genuine `Prob`–`Agents` interaction term). -/
theorem R_460_rank_one_exchange (p₁ p₂ : Prob) (A₁ A₂ : Agents) :
    N Φ₀ Z p₁ A₁ * N Φ₀ Z p₂ A₂ = N Φ₀ Z p₁ A₂ * N Φ₀ Z p₂ A₁ := by
  show (Φ₀ p₁ * Z A₁) * (Φ₀ p₂ * Z A₂) = (Φ₀ p₁ * Z A₂) * (Φ₀ p₂ * Z A₁)
  apply Subtype.ext
  show (Φ₀ p₁ : ℝ) * Z A₁ * (Φ₀ p₂ * Z A₂) = Φ₀ p₁ * Z A₂ * (Φ₀ p₂ * Z A₁)
  ring

/-- **R.460 corollary — multiplicative conservation law.**

Rescaling `Φ₀ → λ·Φ₀` and `Z → Z/λ` (here: replacing `Φ₀ p` by
`Φ₀ p · lam` and `Z A` by `Z A · lam'`, where `lam · lam' = 1` is a unit
pair of the cost monoid) leaves `N` invariant.  This is the categorical
root of the efficiency ratio `ρ = Z/Φ₀`: multiplication by a unit of the
cost monoid is a symmetry of the separable pair.  Stated with explicit
rescaled cost functors `Φ₀'`, `Z'` and a unit pair, so it stays within the
`CommMonoid` structure (no division required). -/
theorem R_460_rescale_invariant
    (Φ₀' : Prob → Cost) (Z' : Agents → Cost) (lam lam' : Cost)
    (hunit : lam * lam' = 1)
    (hΦ : ∀ p, Φ₀' p = Φ₀ p * lam)
    (hZ : ∀ A, Z' A = Z A * lam') (p : Prob) (A : Agents) :
    N Φ₀' Z' p A = N Φ₀ Z p A := by
  show Φ₀' p * Z' A = Φ₀ p * Z A
  rw [hΦ, hZ, mul_mul_mul_comm, hunit, mul_one]

end Profunctor

end SeparableProfunctor

end MIP
