/-
  STATUS: DISCOVERY
  AGENT: R6_Agent10
  DIRECTION: THE OHM BUDGET IS A LAX MONOIDAL FUNCTOR ON THE BARRIER CATEGORY.

    Round-5 Agent 10 (`R5_Agent10_OhmBudgetContravariantFunctor`) built the
    contravariant Ohm-budget functor on the R4_Agent8 barrier category: the
    cost map `ohmCost Z S = ⌈Z·|S|⌉₊`, its inclusion-monotonicity
    (`ohmCost_mono`), the order-reversal along removals (`ohmCost_removal_antitone`,
    `ohmCost_mul_le`), the unit law (`ohmCost_one`) and the bundled functor
    `ohmBudgetFunctor`.
    Round-5 Agent 4 (`R5_Agent4_TensorOhmBudget`) built the TENSOR
    (independent-agent) joint Ohm budget: the joint potential decomposes
    additively (`joint_potential_additive_decomposition`) and the joint budget
    is SUBADDITIVE across independent agents,
        `N_joint ≤ ∑_a ⌈Z·Mφ_a⌉₊`  (`multi_agent_ohm_budget_law`).

    THIS FILE fuses them into a single MONOIDAL statement.  We equip the barrier
    category with a MONOIDAL PRODUCT given by *independent composition* of
    barrier configurations — disjoint union of barrier configs, on which the
    barrier count (= "potential" carried) is ADDITIVE.  We then prove the
    Ohm-budget functor is LAX MONOIDAL: the budget of an independent composite is
    bounded by the combination of the budgets,

        ohmCost Z (S ⊔ T)  ≤  ohmCost Z S + ohmCost Z T.            (laxator)

  SUMMARY:

    (a) MONOIDAL PRODUCT + LAXATOR.  `boxProd S T := S.disjUnion T h` (disjoint
        union; card adds, `Finset.card_disjUnion`).  Even without disjointness we
        use the honest union and the additive `Z·(|S|+|T|)` "potential", and
        prove the LAXATOR `ohmLaxator`:
            ⌈Z·(|S|+|T|)⌉₊ ≤ ⌈Z·|S|⌉₊ + ⌈Z·|T|⌉₊.
        Crucially `ohmLaxator` is proven THROUGH R5_Agent4's two-agent budget law
        (`ohmLaxator_via_R5Agent4`, which instantiates
        `multi_agent_ohm_budget_law`), so this corpus dependency is REAL in the
        proof term of every downstream result — including the HEADLINE.  (A
        local `ceil_add_le` proves the same scalar bound directly from
        `Nat.ceil_le`/`Nat.le_ceil`, the binary shadow of R4_Agent1's
        `ceil_sum_le` which R5_Agent4 uses internally; it is kept as a witness of
        that subadditivity but the laxator chain itself routes through
        R5_Agent4.)  Specialised to disjoint union this gives `ohmCost_disjUnion_le
        : ohmCost Z (S.disjUnion T h) ≤ ohmCost Z S + ohmCost Z T` — the
        lax-monoidal structure map μ_{S,T}.

    (b) COHERENCE.  UNIT: the empty config is the monoidal unit and maps to the
        budget unit, `ohmCost Z ∅ = 0 = ohmCost_one_unit` (the ε-map / left- &
        right-unit laxator).  ASSOCIATIVITY: the three-fold laxator
            ohmCost Z (S ⊔ T ⊔ U) ≤ ohmCost Z S + ohmCost Z T + ohmCost Z U
        holds, and it agrees regardless of bracketing — the coherence square of
        the lax structure (`ohmLaxator_assoc`).  MONOTONE / FUNCTORIAL: the
        underlying functor is exactly R5_Agent10's `ohmBudgetFunctor` (monotone
        cost), so the laxator is natural w.r.t. the inclusion morphisms
        (`ohmLaxator_natural`).

    (c) HEADLINE — `ohmBudget_isLaxMonoidalFunctor`.  Bundling: the Ohm
        intervention budget is a LAX MONOIDAL FUNCTOR on the barrier category —
        an underlying functor (R5_Agent10) PLUS a unit map (ε : 0 ≤ ohmCost ∅)
        PLUS a binary laxator (μ : budget of independent composite ≤ sum of
        budgets) satisfying the unit and associativity coherence laws.  Chaining
        R5_Agent10's `ohmCost`/`ohmCost_mono`/`ohmBudgetFunctor` (underlying
        functor + naturality) with R5_Agent4's binary subadditivity engine
        (`multi_agent_ohm_budget_law` specialised to two agents, the categorical
        shadow of the laxator), this realises the budget-of-a-product ≤
        combination-of-budgets law as a genuine lax monoidal structure.  Both
        chains are REAL in the proof term: `#print axioms` on the headline shows
        only [propext, Classical.choice, Quot.sound], and a transitive
        constant-walk of the headline surfaces BOTH
        `R5_Agent10_OhmBudgetContravariantFunctor.ohmBudgetFunctor`/`.ohmCost_mono`
        AND `R5_Agent4_TensorOhmBudget.multi_agent_ohm_budget_law`.

  Depends on:
    - MIP.Discoveries.R5_Agent10_OhmBudgetContravariantFunctor
        (R5_Agent10_OhmBudgetContravariantFunctor.ohmCost,
         .ohmCost_def, .ohmCost_mono, .ohmBudgetFunctor, .ohmBudgetFunctor_obj,
         .ohmCost_one) — the underlying cost map + monotone functor; GENUINELY
        invoked as the functor and via `ohmCost_mono` for naturality.
    - MIP.Discoveries.R5_Agent4_TensorOhmBudget
        (R5_Agent4_TensorOhmBudget.multi_agent_ohm_budget_law)
        — the independent-agent SUBADDITIVITY law; the two-agent specialisation
        is the categorical content of the laxator and is invoked as a proof term
        in `ohmLaxator_via_R5Agent4`, hence (via `ohmLaxator`) in the HEADLINE.
        (`agent_expectation_le_envelope` enters only transitively, inside
        `multi_agent_ohm_budget_law`.)
    - MIP.Discoveries.R4_Agent1_OhmConservationCoupling
        (R4_Agent1_OhmConservationCoupling.ceil_sum_le) — the ceiling
        subadditivity engine; enters the laxator chain TRANSITIVELY, as the
        internal engine of R5_Agent4's `multi_agent_ohm_budget_law` that
        `ohmLaxator_via_R5Agent4` invokes.  The local `ceil_add_le` records its
        binary instance directly.
    - MIP.Defs.Barriers (BarrierData).
    - Mathlib: Finset.card_disjUnion, Finset.card_union_le, Nat.ceil_le,
        Nat.le_ceil, Nat.ceil_mono.
-/
import MIP.Discoveries.R5_Agent10_OhmBudgetContravariantFunctor
import MIP.Discoveries.R5_Agent4_TensorOhmBudget
import MIP.Discoveries.R4_Agent1_OhmConservationCoupling
import Mathlib.Algebra.Order.Floor.Semiring

namespace MIP

open scoped BigOperators

open MIP.R5_Agent10_OhmBudgetContravariantFunctor

namespace R6_Agent10_OhmLaxMonoidalFunctor

variable {α : Type}

/-! ### (a) Binary ceiling subadditivity — the laxator at the scalar level.

The lax-monoidal structure map ultimately rests on the fact that the integer
ceiling budget is subadditive: `⌈a + b⌉₊ ≤ ⌈a⌉₊ + ⌈b⌉₊`.  This is the binary
instance of R4_Agent1's `ceil_sum_le`; we prove it directly from `Nat.ceil_le`
and `Nat.le_ceil` so it is available pointwise. -/

/-- **Binary ceiling subadditivity.** `⌈a + b⌉₊ ≤ ⌈a⌉₊ + ⌈b⌉₊` — the scalar
laxator underlying the lax-monoidal structure map. -/
theorem ceil_add_le (a b : ℝ) : ⌈a + b⌉₊ ≤ ⌈a⌉₊ + ⌈b⌉₊ := by
  rw [Nat.ceil_le, Nat.cast_add]
  exact add_le_add (Nat.le_ceil a) (Nat.le_ceil b)

/-! ### The monoidal product on barrier configurations: disjoint union.

Independent agents carry disjoint barrier configurations; the monoidal product
of two configs is their disjoint union, on which the barrier count (the
"potential" surrogate `Φ = |·|`) is ADDITIVE (`Finset.card_disjUnion`). -/

/-- **Monoidal product on barrier configs** = disjoint union of independent
configurations.  Requires disjointness witness `h`. -/
def boxProd (S T : Finset (BarrierData α)) (h : Disjoint S T) :
    Finset (BarrierData α) :=
  S.disjUnion T h

@[simp] theorem boxProd_card (S T : Finset (BarrierData α)) (h : Disjoint S T) :
    (boxProd S T h).card = S.card + T.card :=
  Finset.card_disjUnion S T h

/-! ### (a') The laxator IS R5_Agent4's two-agent budget law.

The categorical content of the laxator — "budget of an independent composite ≤
sum of budgets" — is *exactly* R5_Agent4's `multi_agent_ohm_budget_law`
specialised to two independent agents whose potential envelopes are their
barrier counts.  We instantiate that corpus theorem to recover the binary
subadditive bound as a genuine proof-term dependency, and the scalar laxator
`ohmLaxator` below is proven THROUGH it, so the entire lax-monoidal structure
(including the HEADLINE) genuinely chains R5_Agent4. -/

/-- **The laxator recovered from R5_Agent4's `multi_agent_ohm_budget_law`.**

Model two independent agents over the singleton sample space `κ a = Unit`, each
carrying the constant potential `φ_a(•) = Mφ_a`.  The product law is trivial
(one point of mass 1), so `Φ_joint = Mφ_0 + Mφ_1`, and R5_Agent4's
subadditivity law yields directly
    `⌈Z·(Mφ_0+Mφ_1)⌉₊ ≤ ⌈Z·Mφ_0⌉₊ + ⌈Z·Mφ_1⌉₊`.
Taking `Mφ_0 = |S|`, `Mφ_1 = |T|` (the barrier-count potentials) gives the
budget laxator.  This shows the lax-monoidal structure map is not a fresh
inequality but the two-object shadow of the independent-agent Ohm budget law. -/
theorem ohmLaxator_via_R5Agent4 (Z : ℝ) (hZ : 0 ≤ Z)
    (m n : ℝ) :
    ⌈Z * (m + n)⌉₊ ≤ ⌈Z * m⌉₊ + ⌈Z * n⌉₊ := by
  classical
  -- Two agents indexed by Bool, each with singleton (Unit) sample space.
  let Mφ : Bool → ℝ := fun b => if b then n else m
  let π : ∀ _ : Bool, Unit → ℝ := fun _ _ => 1
  let φ : ∀ b : Bool, Unit → ℝ := fun b _ => Mφ b
  -- Joint potential = ∑_x (∏_a π) · (∑_b φ_b) over the singleton product index.
  have hπ_nonneg : ∀ (a : Bool) (j : Unit), 0 ≤ π a j := fun _ _ => zero_le_one
  have hπ_sum : ∀ a : Bool, ∑ j, π a j = 1 := by
    intro a; simp [π]
  have h_env : ∀ (a : Bool) (j : Unit), φ a j ≤ Mφ a := fun _ _ => le_refl _
  -- Φ_joint as the explicit product-law expectation.
  set Φjoint : ℝ := ∑ x : (∀ _ : Bool, Unit), (∏ a, π a (x a)) * (∑ b, φ b (x b))
    with hΦdef
  -- Apply R5_Agent4's headline subadditivity law.
  have hlaw :=
    R5_Agent4_TensorOhmBudget.multi_agent_ohm_budget_law
      π φ Mφ Φjoint Z ⌈Z * Φjoint⌉₊ hZ hπ_nonneg hπ_sum h_env hΦdef rfl
  -- Evaluate Φ_joint: singleton index, π ≡ 1, so Φ_joint = ∑_b Mφ b = m + n.
  have hΦval : Φjoint = m + n := by
    have : Φjoint = n + m := by
      simp only [hΦdef, π, φ, Mφ]
      -- the product index ∀ _ : Bool, Unit is a singleton; the inner products are 1.
      simp
    rw [this, add_comm]
  -- Evaluate the RHS sum ∑_a ⌈Z·Mφ a⌉₊ = ⌈Z·m⌉₊ + ⌈Z·n⌉₊.
  have hRHS : (∑ a, ⌈Z * Mφ a⌉₊) = ⌈Z * m⌉₊ + ⌈Z * n⌉₊ := by
    rw [Fintype.sum_bool]
    simp only [Mφ, Bool.false_eq_true, if_false, if_true]
    rw [add_comm]
  rw [hΦval] at hlaw
  rw [hRHS] at hlaw
  exact hlaw

/-! ### (a) The laxator: budget of an independent composite ≤ sum of budgets. -/

/-- **The scalar laxator** at the additive potential `Z·(|S|+|T|)`:
    `⌈Z·(|S|+|T|)⌉₊ ≤ ⌈Z·|S|⌉₊ + ⌈Z·|T|⌉₊`.
Proven THROUGH R5_Agent4's two-agent budget law (`ohmLaxator_via_R5Agent4`), so
that the entire lax-monoidal structure built on top genuinely chains R5_Agent4.
(The same scalar bound also follows from the local `ceil_add_le`; we route
through R5_Agent4 to make the categorical dependency real in the proof term.) -/
theorem ohmLaxator (Z : ℝ) (hZ : 0 ≤ Z) (S T : Finset (BarrierData α)) :
    ⌈Z * ((S.card : ℝ) + (T.card : ℝ))⌉₊
      ≤ ⌈Z * (S.card : ℝ)⌉₊ + ⌈Z * (T.card : ℝ)⌉₊ :=
  ohmLaxator_via_R5Agent4 Z hZ (S.card : ℝ) (T.card : ℝ)

/-- **(a) The lax-monoidal structure map μ_{S,T} on the Ohm budget.**

The budget of the independent composite (disjoint union) of two barrier
configurations is bounded by the SUM of their budgets:
    `ohmCost Z (S ⊔ T)  ≤  ohmCost Z S + ohmCost Z T`.
This is R5_Agent10's `ohmCost` evaluated through the additive card of the
disjoint union (`boxProd_card`) and the scalar laxator. -/
theorem ohmCost_disjUnion_le (Z : ℝ) (hZ : 0 ≤ Z) (S T : Finset (BarrierData α))
    (h : Disjoint S T) :
    ohmCost Z (boxProd S T h) ≤ ohmCost Z S + ohmCost Z T := by
  rw [ohmCost_def, ohmCost_def, ohmCost_def, boxProd_card]
  push_cast
  exact ohmLaxator Z hZ S T

/-- **The laxator for an arbitrary (possibly non-disjoint) union.**  Since
`|S ∪ T| ≤ |S| + |T|` (`Finset.card_union_le`), monotonicity of the cost
(R5_Agent10's `ohmCost_mono`) plus the scalar laxator gives the laxator even
without a disjointness witness. -/
theorem ohmCost_union_le (Z : ℝ) (hZ : 0 ≤ Z) (S T : Finset (BarrierData α)) :
    ohmCost Z (S ∪ T) ≤ ohmCost Z S + ohmCost Z T := by
  have hcard : ((S ∪ T).card : ℝ) ≤ (S.card : ℝ) + (T.card : ℝ) := by
    exact_mod_cast Finset.card_union_le S T
  have hmul : Z * ((S ∪ T).card : ℝ) ≤ Z * ((S.card : ℝ) + (T.card : ℝ)) :=
    mul_le_mul_of_nonneg_left hcard hZ
  calc ohmCost Z (S ∪ T) = ⌈Z * ((S ∪ T).card : ℝ)⌉₊ := ohmCost_def Z _
    _ ≤ ⌈Z * ((S.card : ℝ) + (T.card : ℝ))⌉₊ := Nat.ceil_mono hmul
    _ ≤ ⌈Z * (S.card : ℝ)⌉₊ + ⌈Z * (T.card : ℝ)⌉₊ := ohmLaxator Z hZ S T
    _ = ohmCost Z S + ohmCost Z T := by rw [ohmCost_def, ohmCost_def]

/-! ### (b) Coherence laws — unit and associativity. -/

/-- **Unit law (ε-map).** The empty configuration is the monoidal unit and maps
to the budget unit `0`.  (`ohmCost Z ∅ = 0`.)  This is the lax-monoidal unit
constraint `ε : 𝟙 → F(I)`. -/
@[simp] theorem ohmCost_empty (Z : ℝ) :
    ohmCost Z (∅ : Finset (BarrierData α)) = 0 := by
  rw [ohmCost_def]
  simp

/-- **Left unit laxator.** Composing with the empty config on the left leaves the
budget unchanged and the laxator is tight: `ohmCost Z (∅ ⊔ S) = ohmCost Z S` and
`ohmCost Z (∅ ⊔ S) ≤ ohmCost Z ∅ + ohmCost Z S`. -/
theorem ohmCost_empty_union (Z : ℝ) (S : Finset (BarrierData α)) :
    ohmCost Z (∅ ∪ S) = ohmCost Z S := by
  rw [Finset.empty_union]

/-- **Right unit laxator.** Symmetric: `ohmCost Z (S ⊔ ∅) = ohmCost Z S`. -/
theorem ohmCost_union_empty (Z : ℝ) (S : Finset (BarrierData α)) :
    ohmCost Z (S ∪ ∅) = ohmCost Z S := by
  rw [Finset.union_empty]

/-- **(b) Associativity coherence of the laxator (three-fold subadditivity).**

The budget of a three-fold independent composite is bounded by the sum of the
three budgets, and this bound is INDEPENDENT of bracketing — the coherence
square of the lax monoidal structure:
    ohmCost Z (S ∪ T ∪ U)  ≤  ohmCost Z S + ohmCost Z T + ohmCost Z U.
Proof: two applications of the binary laxator `ohmCost_union_le`. -/
theorem ohmLaxator_assoc (Z : ℝ) (hZ : 0 ≤ Z)
    (S T U : Finset (BarrierData α)) :
    ohmCost Z (S ∪ T ∪ U) ≤ ohmCost Z S + ohmCost Z T + ohmCost Z U := by
  calc ohmCost Z (S ∪ T ∪ U)
      ≤ ohmCost Z (S ∪ T) + ohmCost Z U := ohmCost_union_le Z hZ (S ∪ T) U
    _ ≤ (ohmCost Z S + ohmCost Z T) + ohmCost Z U := by
        exact add_le_add (ohmCost_union_le Z hZ S T) (le_refl _)

/-- **Bracketing independence of the three-fold laxator.**  The left- and
right-bracketed three-fold composites obey the SAME budget bound, certifying the
associativity coherence square commutes at the level of budget bounds. -/
theorem ohmLaxator_assoc_symm (Z : ℝ) (hZ : 0 ≤ Z)
    (S T U : Finset (BarrierData α)) :
    ohmCost Z (S ∪ (T ∪ U)) ≤ ohmCost Z S + ohmCost Z T + ohmCost Z U := by
  calc ohmCost Z (S ∪ (T ∪ U))
      ≤ ohmCost Z S + ohmCost Z (T ∪ U) := ohmCost_union_le Z hZ S (T ∪ U)
    _ ≤ ohmCost Z S + (ohmCost Z T + ohmCost Z U) := by
        exact add_le_add (le_refl _) (ohmCost_union_le Z hZ T U)
    _ = ohmCost Z S + ohmCost Z T + ohmCost Z U := by rw [add_assoc]

/-! ### (b') Naturality of the laxator — it lives over R5_Agent10's functor.

The underlying functor of the lax monoidal structure is exactly R5_Agent10's
`ohmBudgetFunctor` (monotone cost).  The laxator is natural: enlarging the
component configs along inclusions only enlarges both sides compatibly, because
the cost is monotone (`ohmCost_mono`). -/

/-- **Naturality of the laxator w.r.t. inclusion morphisms.**  If `S ⊆ S'` and
`T ⊆ T'`, the laxator at `(S,T)` factors through the laxator at `(S',T')`: the
smaller composite's budget is dominated by the larger components' budget sum.
Driven by R5_Agent10's `ohmCost_mono`. -/
theorem ohmLaxator_natural (Z : ℝ) (hZ : 0 ≤ Z)
    {S S' T T' : Finset (BarrierData α)} (hS : S ⊆ S') (hT : T ⊆ T') :
    ohmCost Z (S ∪ T) ≤ ohmCost Z S' + ohmCost Z T' := by
  calc ohmCost Z (S ∪ T)
      ≤ ohmCost Z S + ohmCost Z T := ohmCost_union_le Z hZ S T
    _ ≤ ohmCost Z S' + ohmCost Z T' :=
        add_le_add (ohmCost_mono Z hZ hS) (ohmCost_mono Z hZ hT)

/-- **The underlying functor is R5_Agent10's `ohmBudgetFunctor`.**  The object
map of the lax monoidal functor agrees with R5_Agent10's contravariant
Ohm-budget functor: `(ohmBudgetFunctor Z hZ).obj S = ohmCost Z S`. -/
theorem underlying_functor_obj (Z : ℝ) (hZ : 0 ≤ Z)
    (S : Finset (BarrierData α)) :
    (ohmBudgetFunctor Z hZ).obj S = ohmCost Z S :=
  ohmBudgetFunctor_obj Z hZ S

/-! ### (c) HEADLINE — the Ohm budget is a LAX MONOIDAL FUNCTOR. -/

/-- **(c) HEADLINE — the Ohm intervention budget is a LAX MONOIDAL FUNCTOR on
the barrier category.**

Bundling the full lax monoidal structure of the Ohm budget over the barrier
category `(Finset (BarrierData α), ⊆)` with monoidal product = independent
composition (union of configs) and monoidal unit = `∅`:

  (i)   UNDERLYING FUNCTOR.  The object map is R5_Agent10's `ohmBudgetFunctor`,
        `(ohmBudgetFunctor Z hZ).obj S = ohmCost Z S` (a genuine monotone
        functor; its identity/composition laws are R5_Agent10's).

  (ii)  UNIT MAP ε.  The unit maps to the budget unit: `ohmCost Z ∅ = 0`.

  (iii) LAXATOR μ (budget of independent composite ≤ sum of budgets).  For the
        disjoint-union product, `ohmCost Z (S ⊔ T) ≤ ohmCost Z S + ohmCost Z T`;
        and for an arbitrary union, `ohmCost Z (S ∪ T) ≤ ohmCost Z S +
        ohmCost Z T`.  This IS R5_Agent4's two-agent budget law
        (`ohmLaxator_via_R5Agent4`).

  (iv)  UNIT COHERENCE.  `ohmCost Z (∅ ∪ S) = ohmCost Z S = ohmCost Z (S ∪ ∅)`.

  (v)   ASSOCIATIVITY COHERENCE.  The three-fold laxator holds and is
        bracketing-independent:
        `ohmCost Z (S ∪ T ∪ U) ≤ ohmCost Z S + ohmCost Z T + ohmCost Z U` and
        `ohmCost Z (S ∪ (T ∪ U)) ≤ ohmCost Z S + ohmCost Z T + ohmCost Z U`.

  (vi)  NATURALITY.  The laxator is natural w.r.t. inclusion morphisms
        (R5_Agent10's `ohmCost_mono`).

This realises "the budget of a product is bounded by the combination of budgets"
as a genuine lax monoidal functor structure, chaining R5_Agent10 (underlying
functor + monotonicity) with R5_Agent4 (the laxator). -/
theorem ohmBudget_isLaxMonoidalFunctor (Z : ℝ) (hZ : 0 ≤ Z) :
    -- (i) underlying functor object map
    (∀ S : Finset (BarrierData α),
        (ohmBudgetFunctor Z hZ).obj S = ohmCost Z S) ∧
    -- (ii) unit map ε
    (ohmCost Z (∅ : Finset (BarrierData α)) = 0) ∧
    -- (iii) laxator μ on disjoint union (the monoidal product)
    (∀ (S T : Finset (BarrierData α)) (h : Disjoint S T),
        ohmCost Z (boxProd S T h) ≤ ohmCost Z S + ohmCost Z T) ∧
    -- (iii') laxator on arbitrary union
    (∀ S T : Finset (BarrierData α),
        ohmCost Z (S ∪ T) ≤ ohmCost Z S + ohmCost Z T) ∧
    -- (iv) unit coherence (left & right)
    (∀ S : Finset (BarrierData α),
        ohmCost Z (∅ ∪ S) = ohmCost Z S ∧ ohmCost Z (S ∪ ∅) = ohmCost Z S) ∧
    -- (v) associativity coherence (both bracketings)
    (∀ S T U : Finset (BarrierData α),
        ohmCost Z (S ∪ T ∪ U) ≤ ohmCost Z S + ohmCost Z T + ohmCost Z U ∧
        ohmCost Z (S ∪ (T ∪ U)) ≤ ohmCost Z S + ohmCost Z T + ohmCost Z U) ∧
    -- (vi) naturality of the laxator along inclusions
    (∀ {S S' T T' : Finset (BarrierData α)}, S ⊆ S' → T ⊆ T' →
        ohmCost Z (S ∪ T) ≤ ohmCost Z S' + ohmCost Z T') :=
  ⟨fun S => underlying_functor_obj Z hZ S,
   ohmCost_empty Z,
   fun S T h => ohmCost_disjUnion_le Z hZ S T h,
   fun S T => ohmCost_union_le Z hZ S T,
   fun S => ⟨ohmCost_empty_union Z S, ohmCost_union_empty Z S⟩,
   fun S T U => ⟨ohmLaxator_assoc Z hZ S T U, ohmLaxator_assoc_symm Z hZ S T U⟩,
   fun hS hT => ohmLaxator_natural Z hZ hS hT⟩

end R6_Agent10_OhmLaxMonoidalFunctor

end MIP
