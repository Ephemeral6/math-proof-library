/-
Result R.452 — Training as completion (colimit): Gompertz is the
completion rate.

Reference: `workspace/categorical_formalization.md` R.452 (A 条件性).

**Statement (formalized kernel).** Training is the sequential colimit of
a chain of partial commutative magmas `(K(A_t), ⊕_t)`. We formalize the
crisp algebraic core in two pieces:

* **Monotone saturation.** The binary-closure rate `κ(t)` approaches the
  ceiling `1` as `t → ∞`. We reuse the R.98 Gompertz closed form
  `κ t = exp(log κ₀ · exp(-α·(t - t_c)))` and prove `κ t → 1`. Saturation
  `κ_r(A_t) → 1` is the hypothesis under which the colimit is a strict
  symmetric monoidal category; here we encode the `r = 2` (binary) layer.

* **Colimit of an increasing carrier chain.** Given carriers
  `S : ℕ → Set α` with `S t ⊆ S (t+1)` (condition (M): training does not
  shrink the knowledge set), the colimit is `S∞ := ⋃ t, S t`. We prove the
  universal property: every `S t` injects into `S∞` (the cocone legs), the
  legs are compatible with the chain inclusions, and `S∞` is the *least*
  set receiving the whole cocone (universality / initiality of the
  colimit). This is the object-layer of the three phase transitions
  (T.30): the colimit first covers the problem requirement `R(p)`.

**What was reduced to a kernel.** The full statement lives in the
category of partial commutative magmas with partial-operation
homomorphisms; the existence of sequential (filtered) colimits there is
cited as standard. We formalize the *carrier* colimit (`Set` chain +
`⋃`) together with its universal property, and the saturation limit. The
partial-magma operation `⊕_t` extending to `⋃` (and the κ_r-tower giving
strict symmetric monoidal structure) is documented but not encoded, as it
requires the partial-magma category machinery not cleanly in Mathlib.

**This file is `axiom`-free.**
-/
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Data.Set.Lattice
import Mathlib.Order.CompleteLattice.Basic
import Mathlib.Tactic.Linarith

namespace MIP

namespace TrainingColimit

open Real Filter Topology Set

/-! ### Part 1 — Gompertz saturation of the binary-closure rate κ. -/

/-- The closed-form Gompertz binary-closure rate
`κ t = exp(log κ₀ · exp(-α·(t - t_c)))` (R.98 form). -/
noncomputable def kappa (κ₀ α t_c : ℝ) (t : ℝ) : ℝ :=
  Real.exp (Real.log κ₀ * Real.exp (-α * (t - t_c)))

/-- **R.452 (c) — saturation `κ t → 1`.**

For `0 < α`, the inner exponent `exp(-α·(t - t_c)) → 0` as `t → ∞`, so
`g t = log κ₀ · exp(...) → 0` and `κ t = exp(g t) → exp 0 = 1`. This is
the "uncompleted binary fraction `1 − κ(t)`" decaying to `0`: the
colimit's binary layer saturates at the ceiling. -/
theorem R_452_saturation (κ₀ α t_c : ℝ) (hα : 0 < α) :
    Filter.Tendsto (kappa κ₀ α t_c) Filter.atTop (nhds 1) := by
  -- affine argument -α*(t - t_c) → -∞
  have h_arg : Filter.Tendsto (fun t : ℝ => -α * (t - t_c)) atTop atBot := by
    have h_lin : Filter.Tendsto (fun t : ℝ => t - t_c) atTop atTop :=
      tendsto_atTop_add_const_right atTop (-t_c) tendsto_id
    have h_neg : (-α) < 0 := by linarith
    have := (tendsto_const_mul_atBot_of_neg (r := -α) (f := fun t : ℝ => t - t_c)
      h_neg).mpr h_lin
    simpa using this
  -- exp(-α*(t - t_c)) → 0
  have h_exp0 : Filter.Tendsto (fun t : ℝ => Real.exp (-α * (t - t_c)))
      atTop (nhds 0) :=
    Real.tendsto_exp_atBot.comp h_arg
  -- g t = log κ₀ · exp(...) → 0
  have h_g0 : Filter.Tendsto (fun t : ℝ => Real.log κ₀ * Real.exp (-α * (t - t_c)))
      atTop (nhds 0) := by
    have := h_exp0.const_mul (Real.log κ₀)
    simpa using this
  -- κ t = exp(g t) → exp 0 = 1
  have h_kappa : Filter.Tendsto (kappa κ₀ α t_c) atTop (nhds (Real.exp 0)) := by
    unfold kappa
    exact (Real.continuous_exp.tendsto 0).comp h_g0
  simpa using h_kappa

/-- **R.452 (c) — the uncompleted binary fraction `1 − κ(t) → 0`.**

Equivalent restatement: the "fraction of binary pairs not yet closed"
vanishes as training proceeds. -/
theorem R_452_gap_vanishes (κ₀ α t_c : ℝ) (hα : 0 < α) :
    Filter.Tendsto (fun t => 1 - kappa κ₀ α t_c t) Filter.atTop (nhds 0) := by
  have h := R_452_saturation κ₀ α t_c hα
  have : Filter.Tendsto (fun t => 1 - kappa κ₀ α t_c t) atTop (nhds (1 - 1)) :=
    (tendsto_const_nhds (x := (1 : ℝ))).sub h
  simpa using this

/-! ### Part 2 — Colimit of an increasing chain of carriers. -/

variable {α : Type*}

/-- The colimit carrier of an increasing chain `S : ℕ → Set α`: the union
`S∞ := ⋃ t, S t`. -/
def Sinf (S : ℕ → Set α) : Set α := ⋃ t, S t

/-- **R.452 (a) — monotone-chain ⟹ pointwise monotone inclusion.**

Condition (M): if `S t ⊆ S (t+1)` for every step, then `S` is monotone,
so `t₁ ≤ t₂ ⟹ S t₁ ⊆ S t₂`. These are the chain inclusions `ι_{t₁,t₂}`. -/
theorem R_452_chain_mono (S : ℕ → Set α)
    (hstep : ∀ t, S t ⊆ S (t + 1)) :
    Monotone S :=
  monotone_nat_of_le_succ hstep

/-- **R.452 (b) — cocone leg: each `S t` injects into the colimit `S∞`.**

The colimit injection `ι_t : S t ↪ S∞` exists: every element of `S t`
lies in the union. -/
theorem R_452_leg (S : ℕ → Set α) (t : ℕ) :
    S t ⊆ Sinf S :=
  subset_iUnion S t

/-- **R.452 (b) — cocone compatibility.**

The legs are compatible with the chain inclusions: factoring `S t₁ ⊆ S∞`
through `S t₂` (for `t₁ ≤ t₂`) gives the same map. Concretely, the leg at
`t₁` factors through the leg at `t₂` whenever `t₁ ≤ t₂`. -/
theorem R_452_cocone_compat (S : ℕ → Set α)
    (hstep : ∀ t, S t ⊆ S (t + 1)) {t₁ t₂ : ℕ} (h : t₁ ≤ t₂) :
    S t₁ ⊆ S t₂ ∧ (S t₁ ⊆ Sinf S) :=
  ⟨R_452_chain_mono S hstep h, R_452_leg S t₁⟩

/-- **R.452 (b) — universal property of the colimit (initiality).**

`S∞ = ⋃ t, S t` is the *least* set receiving the entire cocone: for any
target `T` such that every leg `S t ⊆ T`, the colimit factors as
`S∞ ⊆ T`. This is the universal property characterizing the colimit
(sequential filtered colimit in `Set`). -/
theorem R_452_universal (S : ℕ → Set α) (T : Set α)
    (h : ∀ t, S t ⊆ T) :
    Sinf S ⊆ T :=
  iUnion_subset h

/-- **R.452 (b) — colimit is unique up to the universal property.**

If `T` receives the cocone *and* embeds into the colimit, then `T = S∞`.
This pins down `S∞` uniquely as the colimit object (any two colimits are
equal as the least cocone-receiver). -/
theorem R_452_colimit_unique (S : ℕ → Set α) (T : Set α)
    (h_recv : ∀ t, S t ⊆ T) (h_into : T ⊆ Sinf S) :
    T = Sinf S :=
  le_antisymm h_into (R_452_universal S T h_recv)

/-! ### Part 3 — Object-layer phase transition (T.30 first transition). -/

/-- **R.452 (d) — first phase transition (object coverage `Π_cov`).**

Coverage layer: once a single carrier `S t₀` covers the problem
requirement `R ⊆ S t₀`, the colimit covers it permanently: `R ⊆ S∞`.
This is the object-layer phase transition `t_cov`: the colimit first
covers the problem demand `R(p)`. -/
theorem R_452_coverage (S : ℕ → Set α) (R : Set α) (t₀ : ℕ)
    (h_cov : R ⊆ S t₀) :
    R ⊆ Sinf S :=
  h_cov.trans (R_452_leg S t₀)

end TrainingColimit

end MIP
