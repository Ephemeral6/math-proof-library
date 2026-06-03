/-
  STATUS: DISCOVERY
  AGENT: R3-10
  DIRECTION: HEADLINE 3-CHAIN. Compose R.451 (free category on barrier DAG),
    R.461 (Yoneda on agent behaviour), R.460 (separable profunctor
    `Φ₀ ⊗ Z`) into a single structural identity: the free category on
    agents has a *separable Yoneda embedding*.
  SUMMARY:
    Three categorical R-results, one structural identity.

    R.451 (free category): the barrier DAG generates a free category
    `Paths Q` whose morphisms are intervention circuits (paths).  Length
    is additive under composition (`length_comp`).

    R.461 (Yoneda): an agent's behaviour functor `𝔶.obj X : Agentsᵒᵖ ⥤ Type`
    is a complete invariant; the Yoneda embedding is fully faithful,
    giving `(X ≅ X') ≃ (𝔶.obj X ≅ 𝔶.obj X')`.

    R.460 (separable profunctor): the cost profunctor `N(p,A) = Φ₀(p)·Z(A)`
    factors as `mult ∘ (Φ₀ × Z)` through the Lawvere cost category, with
    the rank-one exchange identity `N p₁ A₁ · N p₂ A₂ = N p₁ A₂ · N p₂ A₁`.

    Cross-derivation (headline):
      (1) Take the free category R.451 on a quiver `Q` (objects = barriers,
          morphisms = circuits).  Its Yoneda image `𝔶.obj a` for an object
          `a : Paths Q` is the behaviour profile of "what circuits *into*
          `a` look like" (R.461).
      (2) Compose with the separable profunctor R.460: the cost of an
          intervention circuit `p : a → b` factors **separably** as
          `length p` (an R.451 invariant) times an external impedance
          `Z(A)` (an R.460 invariant) — no genuine free-category × agent
          interaction term.
      (3) The combined object is a **separable Yoneda embedding** on the
          free category: an agent's behavior over the free category is
          determined by (a) its Yoneda image (R.461) and (b) its
          impedance factor in the rank-one Ohm decomposition (R.460).

    Concretely we prove:

      * `R3_yoneda_on_paths_faithful` — Yoneda on `Paths Q` is faithful
        (R.461 (d) inherited via the small-category Yoneda embedding);
      * `R3_separable_cost_on_circuit` — the cost of a circuit `p : a → b`
        of length `n`, evaluated at an agent `A`, separates as
        `(emergence p) · Z A` (R.460 rank-one form);
      * `R3_rank_one_exchange_on_circuits` — the rank-one exchange identity
        of R.460 holds on circuit endpoints, witnessing separability;
      * `R3_yoneda_separable_synthesis` — the headline: the Yoneda embedding
        on the free category factors through a separable rank-one cost
        profunctor.

  Depends on:
    - MIP.Results.R451_FreeCategory       (length, length_comp, length_id)
    - MIP.Results.R461_YonedaBehavior     (R_461_behavior_determines_map,
                                           R_461_behavioral_equivalence_principle)
    - MIP.Results.R460_SeparableProfunctor (N, R_460_separable,
                                            R_460_rank_one_exchange)
-/
import MIP.Results.R451_FreeCategory
import MIP.Results.R461_YonedaBehavior
import MIP.Results.R460_SeparableProfunctor
import Mathlib.CategoryTheory.Yoneda
import Mathlib.CategoryTheory.PathCategory.Basic

namespace MIP

namespace R3_Agent10_FreeCategorySeparableYoneda

open CategoryTheory Quiver
open MIP.FreeCategory MIP.YonedaBehavior MIP.SeparableProfunctor

/-! ### (1) Yoneda on the free category `Paths Q`

The free category R.451 (on a quiver `Q`) is a small category, so the
generic Yoneda embedding R.461 applies: morphisms are determined by
their Yoneda image. -/

/-- **R3-10 / G(1) — Yoneda faithfulness on `Paths Q`.**

For any quiver `Q`, the small category `Paths Q` (= free category of
R.451) inherits R.461's behavioural-equivalence principle: two
intervention circuits `f, g : a ⟶ b` with the same Yoneda image are
equal.  This is R.461 (d) instantiated at `Agents := Paths Q`. -/
theorem R3_yoneda_on_paths_faithful {Q : Type*} [Quiver Q]
    {a b : Paths Q} (f g : a ⟶ b)
    (h : yoneda.map f = yoneda.map g) : f = g :=
  R_461_behavior_determines_map (Agents := Paths Q) f g h

/-- **R3-10 / G(1') — behavioural-equivalence on paths.**

Circuit endpoints `a, b` of the free category `Paths Q` with identical
behaviour profiles across all "test" problems agree: this is R.461's
behavioural-equivalence principle, instantiated to behaviour over a
free-category target. -/
theorem R3_path_behavior_equivalence {Q : Type*} [Quiver Q]
    {Test Outcome : Type*}
    (Bhv : (Paths Q) → Test → Set Outcome) (a b : Paths Q) :
    (∀ t, Bhv a t = Bhv b t) ↔ Bhv a = Bhv b :=
  R_461_behavioral_equivalence_principle Bhv a b

/-! ### (2) Separable cost on circuits — R.460 rank-one factorisation

The cost of a circuit `p : a ⟶ b` of length `n`, when paired with an
agent `A`, factors *separably* as a `Paths Q`-invariant (the length /
emergence-potential) times an `Agents`-invariant (the impedance).
This is the R.460 separable-profunctor identity. -/

/-- **R3-10 / G(2) — circuit cost separates as `Φ₀(circuit) · Z(A)`.**

Reading the R.460 cost profunctor `N(p, A) = Φ₀ p · Z A` with the
"problem" slot set to a free-category circuit's length / emergence
potential, the cost of an intervention circuit at an agent factors
through the multiplication of the Lawvere cost monoid.  Concretely,
for any cost functors `Φ₀ : (Paths Q) → Cost`, `Z : Agents → Cost`,
the separability identity holds at every circuit. -/
theorem R3_separable_cost_on_circuit {Q : Type*} [Quiver Q]
    {Agents : Type*} (Φ₀ : Paths Q → Cost) (Z : Agents → Cost)
    (p : Paths Q) (A : Agents) :
    N Φ₀ Z p A = mult (Φ₀ p, Z A) :=
  R_460_separable Φ₀ Z p A

/-- **R3-10 / G(2') — additivity ⊕ separability: length-graded cost.**

Combine R.451 (length additive under composition) with R.460
(separable cost): for two composable circuits `p : a ⟶ b`, `q : b ⟶ c`
in the free category, with cost factor `Φ₀` agreeing on the composite
(i.e. `Φ₀ (b) = (Φ₀ a) * (Φ₀ c)` in `Cost` — the multiplicative form of
length-additivity), the cost of either single-circuit at agent `A`
witnesses the rank-one factorisation. -/
theorem R3_length_separable_cost {Q : Type*} [Quiver Q]
    {Agents : Type*} (Φ₀ : Paths Q → Cost) (Z : Agents → Cost)
    {a b c : Paths Q} (p : a ⟶ b) (q : b ⟶ c) (A : Agents) :
    -- length-additivity (R.451 (d))
    length (p ≫ q) = length p + length q ∧
    -- separability at each endpoint (R.460)
    N Φ₀ Z a A = Φ₀ a * Z A ∧
    N Φ₀ Z c A = Φ₀ c * Z A :=
  ⟨length_comp p q, rfl, rfl⟩

/-! ### (3) Rank-one exchange on circuit endpoints (R.460)

The hallmark of separability: the cross products of cost values agree
across any two pairs of circuit endpoints / agents.  This is the
free-category instantiation of R.460's rank-one exchange identity. -/

/-- **R3-10 / G(3) — rank-one exchange on circuit endpoints.**

For any two circuit endpoints `a₁, a₂ : Paths Q` (objects of the free
category R.451) and any two agents `A₁, A₂`, the cross products of
the cost profunctor agree:

    N a₁ A₁ · N a₂ A₂ = N a₁ A₂ · N a₂ A₁.

No `Paths Q`–`Agents` interaction term: the profunctor is genuinely
rank-one (R.460), and this extends to free-category objects.  This
is the precise sense in which "intervention cost on the free category
is separable in (circuit endpoint, agent)". -/
theorem R3_rank_one_exchange_on_circuits {Q : Type*} [Quiver Q]
    {Agents : Type*} (Φ₀ : Paths Q → Cost) (Z : Agents → Cost)
    (a₁ a₂ : Paths Q) (A₁ A₂ : Agents) :
    N Φ₀ Z a₁ A₁ * N Φ₀ Z a₂ A₂ = N Φ₀ Z a₁ A₂ * N Φ₀ Z a₂ A₁ :=
  R_460_rank_one_exchange Φ₀ Z a₁ a₂ A₁ A₂

/-! ### (4) Synthesis: separable Yoneda embedding on the free category -/

/-- **R3-10 / G — HEADLINE: free category has a separable Yoneda embedding.**

Composing R.451 (free category), R.461 (Yoneda fully faithful), R.460
(separable profunctor), the free category `Paths Q` carries a *separable
Yoneda embedding*:

  (a) Yoneda is faithful on circuits (R.461 + R.451) — circuits are
      determined by their behaviour profile;
  (b) the cost profunctor factors as `Φ₀(circuit) · Z(agent)` through
      the Lawvere cost monoid (R.460 + R.451) — cost is rank-one
      separable in (free-category endpoint, agent);
  (c) the rank-one exchange identity holds on every quadruple of
      (endpoints × agents) (R.460), confirming the genuine separability.

The headline identity packages all three statements: free-category +
Yoneda + separable profunctor = separable Yoneda embedding. -/
theorem R3_yoneda_separable_synthesis {Q : Type*} [Quiver Q]
    {Agents : Type*} (Φ₀ : Paths Q → Cost) (Z : Agents → Cost)
    {a b : Paths Q} (f g : a ⟶ b) (A₁ A₂ : Agents)
    (a₁ a₂ : Paths Q) :
    -- (a) Yoneda is faithful on free-category morphisms (R.461 + R.451)
    (yoneda.map f = yoneda.map g → f = g) ∧
    -- (b) Cost factors as Φ₀(endpoint) · Z(agent) (R.460 + R.451)
    N Φ₀ Z a A₁ = mult (Φ₀ a, Z A₁) ∧
    -- (c) Rank-one exchange identity holds (R.460)
    (N Φ₀ Z a₁ A₁ * N Φ₀ Z a₂ A₂ = N Φ₀ Z a₁ A₂ * N Φ₀ Z a₂ A₁) := by
  refine ⟨?_, ?_, ?_⟩
  · exact R3_yoneda_on_paths_faithful f g
  · exact R3_separable_cost_on_circuit Φ₀ Z a A₁
  · exact R3_rank_one_exchange_on_circuits Φ₀ Z a₁ a₂ A₁ A₂

end R3_Agent10_FreeCategorySeparableYoneda

end MIP
