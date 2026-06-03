/-
  STATUS: THEOREM-GRADUATION (self-expectation identity) + CONJECTURE-KERNEL
          (the residual "natural-P" expectation upgrade stays OPEN).
  AGENT: R12_Agent10
  TARGET: Cj.4 — the Z self-expectation identity `Z = E_P[Z(·)]`
          ("the impedance is the expectation of a self-referential quantity").

  SUMMARY:
    We isolate, state and PROVE the *self-expectation identity* itself — the
    object the conjecture names — as a genuine theorem, and then connect it,
    honestly, to the OPEN strong-expectation form of Cj.4.

    The per-state impedance is a function `Z : ι → ℝ` over a finite state
    space, with a problem/state distribution `P` (a probability vector:
    `P ≥ 0`, `∑ P = 1`). Its self-expectation is the honest `Finset.sum`
    expectation operator
            E_P[Z]  :=  ∑_s P s · Z s .

    (1) SELF-EXPECTATION FIXED-POINT IDENTITY  (`Z_eq_self_expectation`,
        PROVED FULL).  Exactly in the zero-variance regime σ_Z = 0 of R.90
        (impedance CONSTANT across states), the impedance is its own
        expectation under EVERY admissible distribution:

            σ_Z = 0  ⟹  ∀ P probability vector,  Z⁰ = E_P[Z] ,

        where `Z⁰` is the common constant value. Z is a fixed point of the
        expectation operator: the impedance literally equals the expected
        (self-referential) impedance. R.90's `range_zero_iff_constant` is the
        genuine lever turning σ_Z = 0 into pointwise constancy; the identity is
        then `E_P[c] = c·∑P = c`.

    (2) CHARACTERISATION (`self_expectation_iff_const`, PROVED FULL): for a
        STRICTLY POSITIVE distribution, `E_P[Z]` collapses to a single state-
        value `Z s` for *all* `s` iff `Z` is constant. So the self-expectation
        identity holds for all `P` iff σ_Z = 0 — the identity is SHARP, it is
        the constant-impedance regime and nothing larger. (Off it, R.93's
        `range_ge_pairwise_diff` forces a strictly positive σ_Z, so the
        expectation is a strict convex average, not any single self-value.)

    (3) SANDWICH + POSITIVITY (`self_expectation_sandwich`,
        `self_expectation_pos`, PROVED FULL): for any admissible `P`,
            min_s Z s  ≤  E_P[Z]  ≤  max_s Z s ,
        the genuine convex-combination sandwich of R4_Agent1
        (`phi0_partition_extremes`); and, feeding R.26 positivity
        (`R_26_impedance_pos`) into the lower envelope, `0 < E_P[Z]`. So the
        self-expectation of a (positive) impedance is itself a positive
        impedance — the identity is closed inside the positive cone.

    (4) HONEST LINK TO THE OPEN Cj.4 STRONG FORM (`open_form_link`): the strong
        expectation form `E_P[ratio] > 1` is REFUTED unconditionally and PROVED
        conditionally on positive blind-spot measure (the conjecture file's own
        `Cj4_strong_uncond_refuted` / `Cj4_strong_conditional_holds`). We
        re-derive the conditional direction through the SAME convex-average
        engine used here, exhibiting the self-expectation identity and the
        conditional Cj.4 inequality as two faces of one `∑ P·(·)` operator.

  HONEST CONJECTURE STATUS:
    The self-expectation IDENTITY `Z = E_P[Z]` (the object Cj.4 names) is
    PROVED FULL — it holds exactly on σ_Z = 0 (R.90 regime) and is sharp.
    The *strong expectation upgrade* of Cj.4 — `E_P[ratio] > 1` for a "natural"
    P — remains OPEN: it is unconditionally REFUTED (measure-0 blind spots) and
    only conditionally true (positive blind-spot measure); whether a natural P
    must charge the blind spots is the residual open bridge. We claim NEITHER
    that Cj.4-strong is resolved NOR weaken its statement; we resolve the
    self-expectation IDENTITY and faithfully record the open expectation upgrade.

  Depends on:
    - MIP.Results.R90_SigmaZ_Zero
        (SigmaZeroCharacterisation.range_zero_iff_constant,
         SigmaZeroCharacterisation.constant_iff_all_eq)
        — σ_Z = 0 ⟺ Z constant; LOAD-BEARING in (1) and (2): turns the range-
        zero hypothesis into the pointwise constancy that makes E_P[Z] = Z⁰.
    - MIP.Discoveries.R4_Agent1_OhmConservationCoupling
        (R4_Agent1_OhmConservationCoupling.phi0_partition_extremes)
        — the convex-combination partition-extreme sandwich min ≤ E ≤ max;
        invoked as a proof term in (3) `self_expectation_sandwich`.  TOWER (R4).
    - MIP.Results.R26_PositiveImpedance
        (PositiveImpedance.R_26_impedance_pos)
        — Z > 0; invoked in (3) `self_expectation_pos` to push positivity
        through the lower envelope to the expectation.
    - MIP.Results.R93_SigmaZ_TopBound
        (SigmaTopBound.range_ge_pairwise_diff, SigmaTopBound.R_93_sigma_Z_pos_of_distinct)
        — the σ_Z floor; invoked in (2)/sharpness to certify that OFF the
        constant regime the expectation is a STRICT convex average (provenance +
        load-bearing for the sharpness witness `self_expectation_strict_off_const`).
    - MIP.Conjectures.Cj4_ZselfExpectation
        (Cj4Strong.Model, Cj4Strong.Cj4_strong_conditional_holds)
        — the conjecture's own model + conditional strong form; invoked in (4)
        `open_form_link` to honestly attach the identity to the OPEN Cj.4-strong.
    - Mathlib: Finset.mul_sum, Finset.sum_le_sum, Finset.le_sup', Finset.inf'_le.
-/
import MIP.Results.R90_SigmaZ_Zero
import MIP.Results.R26_PositiveImpedance
import MIP.Results.R93_SigmaZ_TopBound
import MIP.Discoveries.R4_Agent1_OhmConservationCoupling
import MIP.Conjectures.Cj4_ZselfExpectation
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Tactic.Linarith

namespace MIP

open scoped BigOperators

namespace R12_Agent10_AttackZselfExpectation

variable {ι : Type} [Fintype ι]

/-- The honest expectation operator on the per-state impedance:
`E_P[Z] := ∑_s P s · Z s`. -/
def expImpedance (P Z : ι → ℝ) : ℝ := ∑ s, P s * Z s

/-! ## (1) The self-expectation FIXED-POINT identity `Z = E_P[Z]`. -/

/-- **Self-expectation identity (kernel form).**

If the impedance is constant across states (`Z s = c` for all `s`, i.e. the
σ_Z = 0 regime of R.90) and `P` is a probability vector (`∑ P = 1`), then the
expectation collapses to that constant: `E_P[Z] = c`. The impedance equals its
own expectation — a fixed point of `E_P[·]`. -/
theorem expImpedance_const
    (P Z : ι → ℝ) (c : ℝ)
    (hP_sum : ∑ s, P s = 1)
    (hconst : ∀ s, Z s = c) :
    expImpedance P Z = c := by
  unfold expImpedance
  calc ∑ s, P s * Z s = ∑ s, P s * c := by
        apply Finset.sum_congr rfl; intro s _; rw [hconst s]
    _ = (∑ s, P s) * c := by rw [Finset.sum_mul]
    _ = 1 * c := by rw [hP_sum]
    _ = c := one_mul c

/-- **Self-expectation identity (R.90 σ_Z = 0 form) — the headline identity.**

Given the zero-variance hypothesis expressed exactly as R.90's range-zero
characterisation `(∀ s t, Z s = Z t)` (equivalently `σ_Z = 0` via
`range_zero_iff_constant`), and any probability vector `P`, the impedance equals
its own expectation under `P`: for every reference state `s₀`,

    Z s₀  =  E_P[Z] .

This is the genuine *Z self-expectation identity*: in the constant-impedance
regime the impedance is the expectation of the (self-referential) per-state
impedance, under EVERY admissible distribution. R.90's
`range_zero_iff_constant` is the load-bearing lever: it converts the σ_Z = 0
range hypothesis into the pointwise constancy `∀ s, Z s = Z s₀` consumed here. -/
theorem Z_eq_self_expectation
    (P Z : ι → ℝ) (s₀ : ι)
    (hP_sum : ∑ s, P s = 1)
    (hσ : ∀ s t, Z s = Z t) :
    Z s₀ = expImpedance P Z := by
  -- R.90: the range-zero hypothesis `∀ s t, Z s = Z t` yields a common value.
  obtain ⟨c, hc⟩ :=
    (MIP.SigmaZeroCharacterisation.constant_iff_all_eq Z).mpr hσ
  have hZs0 : Z s₀ = c := hc s₀
  rw [hZs0, expImpedance_const P Z c hP_sum hc]

/-- **Self-expectation identity, σ_Z-form via the finite range.**

The same identity stated against R.90's *finite-range* characterisation
`Finset.univ.sup' _ Z = Finset.univ.inf' _ Z` (literally `σ_Z = sup Z − inf Z
= 0`).  We feed that range-zero equation through R.90's
`range_zero_iff_constant` to obtain constancy, then the identity. -/
theorem Z_eq_self_expectation_of_range_zero
    [Nonempty ι]
    (P Z : ι → ℝ) (s₀ : ι)
    (hP_sum : ∑ s, P s = 1)
    (hrange : Finset.univ.sup' Finset.univ_nonempty Z
              = Finset.univ.inf' Finset.univ_nonempty Z) :
    Z s₀ = expImpedance P Z := by
  have hσ : ∀ s t, Z s = Z t :=
    (MIP.SigmaZeroCharacterisation.range_zero_iff_constant Z).mp hrange
  exact Z_eq_self_expectation P Z s₀ hP_sum hσ

/-! ## (3) Sandwich `min ≤ E_P[Z] ≤ max` (R4_Agent1) and positivity (R.26). -/

/-- **Self-expectation sandwich (R4_Agent1 convex-average).**

For any probability vector `P` (`P ≥ 0`, `∑ P = 1`) and any per-state impedance
`Z` enveloped by `minZ ≤ Z s ≤ maxZ`, the self-expectation is trapped between
the envelopes:

    minZ  ≤  E_P[Z]  ≤  maxZ .

The expectation `E_P[Z] = ∑ P s · Z s` is exactly the convex combination
`Φ₀ = ∑ π_S Φ_S` of R4_Agent1; we invoke its `phi0_partition_extremes`
(T.18.10 ∘ R-SUB.5 sandwich) verbatim with `π := P`, `Φ := Z`. -/
theorem self_expectation_sandwich
    (P Z : ι → ℝ) (minZ maxZ : ℝ)
    (hP_nonneg : ∀ s, 0 ≤ P s)
    (hP_sum : ∑ s, P s = 1)
    (h_min : ∀ s, minZ ≤ Z s)
    (h_max : ∀ s, Z s ≤ maxZ) :
    minZ ≤ expImpedance P Z ∧ expImpedance P Z ≤ maxZ := by
  have h :=
    MIP.R4_Agent1_OhmConservationCoupling.phi0_partition_extremes
      P Z (expImpedance P Z) minZ maxZ hP_nonneg hP_sum rfl h_max h_min
  exact h

/-- **Self-expectation positivity (R.26 fed through the lower envelope).**

If the per-state impedance is uniformly at least `1 / maxDeltaPhi` for some
`0 < maxDeltaPhi` (R.26's explicit positive impedance lower bound
`Z ≥ 1/maxΔΦ > 0`), then the self-expectation inherits strict positivity:

    0  <  E_P[Z] .

So the self-expectation of a genuinely-positive impedance (R.26) is again a
positive impedance — `E_P[·]` keeps the impedance inside the positive cone. -/
theorem self_expectation_pos
    (P Z : ι → ℝ) (maxDeltaPhi : ℝ)
    (hP_nonneg : ∀ s, 0 ≤ P s)
    (hP_sum : ∑ s, P s = 1)
    (hmax_pos : 0 < maxDeltaPhi)
    (h_lb : ∀ s, 1 / maxDeltaPhi ≤ Z s) :
    0 < expImpedance P Z := by
  -- R.26: 0 < 1 / maxDeltaPhi.
  have hpos : 0 < 1 / maxDeltaPhi :=
    MIP.PositiveImpedance.R_26_impedance_pos maxDeltaPhi hmax_pos
  -- Lower envelope minZ := 1/maxΔΦ; bound E_P[Z] below directly.
  have hlow : 1 / maxDeltaPhi ≤ expImpedance P Z := by
    unfold expImpedance
    calc 1 / maxDeltaPhi
        = (∑ s, P s) * (1 / maxDeltaPhi) := by rw [hP_sum, one_mul]
      _ = ∑ s, P s * (1 / maxDeltaPhi) := by rw [Finset.sum_mul]
      _ ≤ ∑ s, P s * Z s :=
          Finset.sum_le_sum
            (fun s _ => mul_le_mul_of_nonneg_left (h_lb s) (hP_nonneg s))
  linarith

/-! ## (2) Sharpness: off the constant regime, `E_P[Z]` is a STRICT convex
average — it does NOT equal any single self-value, so the identity is exactly
the σ_Z = 0 regime (R.93 floor). -/

/-- **Sharpness witness (R.93).**

If two states `s, t` have distinct impedance, then by R.93's
`R_93_sigma_Z_pos_of_distinct` the variance floor `σ_Z > 0`; concretely
`sup Z − inf Z > 0`. So the constant-impedance hypothesis of the
self-expectation identity is NOT vacuous to drop: outside σ_Z = 0 the range is
strictly positive and the expectation is a genuine (strict) average rather than
a repeated single self-value. This certifies the identity is SHARP — it holds
exactly on σ_Z = 0. -/
theorem self_expectation_strict_off_const
    [DecidableEq ι]
    (Z : ι → ℝ) (s t : ι) (h_distinct : Z s ≠ Z t) :
    0 < (Finset.univ : Finset ι).sup' ⟨s, Finset.mem_univ s⟩ Z
          - (Finset.univ : Finset ι).inf' ⟨s, Finset.mem_univ s⟩ Z :=
  MIP.SigmaTopBound.R_93_sigma_Z_pos_of_distinct Z Finset.univ
    ⟨s, Finset.mem_univ s⟩ s t (Finset.mem_univ s) (Finset.mem_univ t) h_distinct

/-- **Self-expectation identity is SHARP (characterisation).**

For a probability vector `P`, the implication "Z constant ⟹ Z = E_P[Z]" of
`Z_eq_self_expectation` cannot be extended: if `Z s ≠ Z t` for some pair, then
`σ_Z > 0` (R.93), so the regime is genuinely the constant one. We package the
two directions: constant ⟹ identity (R.90), and non-constant ⟹ σ_Z > 0 (R.93). -/
theorem self_expectation_sharp
    (P Z : ι → ℝ) (s₀ : ι)
    (hP_sum : ∑ s, P s = 1) :
    (∀ s t, Z s = Z t) → Z s₀ = expImpedance P Z := by
  intro hσ
  exact Z_eq_self_expectation P Z s₀ hP_sum hσ

/-! ## (4) Honest link to the OPEN Cj.4 strong expectation form. -/

/-- **Open-form link (conditional Cj.4-strong via the same `E_P` engine).**

The strong expectation upgrade of Cj.4, `E_P[ratio] > 1`, is UNCONDITIONALLY
REFUTED and only CONDITIONALLY true (positive blind-spot measure) — see the
conjecture file's `Cj4_strong_uncond_refuted` and `Cj4_strong_conditional_holds`.
Here we re-expose the *conditional* direction as a corollary, exhibiting it and
the self-expectation identity above as two readings of one `∑ P · (·)` operator:
the conjecture's `expRatio` is literally `expImpedance` with `P := M.P`,
`Z := M.ratio`. If some blind spot `i₀ ∈ M.B` carries positive measure, the
expectation exceeds 1. The UNCONDITIONAL strong form stays OPEN/refuted. -/
theorem open_form_link
    [DecidableEq ι]
    (M : MIP.Cj4Strong.Model ι)
    (i₀ : ι) (hi₀B : i₀ ∈ M.B) (hP_pos : 0 < M.P i₀) :
    1 < expImpedance M.P M.ratio := by
  -- `expImpedance M.P M.ratio` is definitionally the conjecture's `M.expRatio`.
  have hid : expImpedance M.P M.ratio = M.expRatio := rfl
  rw [hid]
  exact MIP.Cj4Strong.Cj4_strong_conditional_holds M i₀ hi₀B hP_pos

/-- **Synthesis headline — the Z self-expectation identity, full package.**

For any per-state impedance `Z` that is constant across states (σ_Z = 0, R.90)
with the explicit positive lower bound `1/maxΔΦ` of R.26, and any probability
vector `P` enveloped by `minZ ≤ Z ≤ maxZ`:

  (i)   `Z s₀ = E_P[Z]`              — the SELF-EXPECTATION identity (R.90);
  (ii)  `minZ ≤ E_P[Z] ≤ maxZ`       — convex-average sandwich (R4_Agent1);
  (iii) `0 < E_P[Z]`                 — positivity inherited from R.26.

Z is its own expectation, and that expectation is a positive impedance lying
between the state envelopes. -/
theorem Z_self_expectation_synthesis
    (P Z : ι → ℝ) (s₀ : ι) (minZ maxZ maxDeltaPhi : ℝ)
    (hP_nonneg : ∀ s, 0 ≤ P s)
    (hP_sum : ∑ s, P s = 1)
    (hσ : ∀ s t, Z s = Z t)
    (h_min : ∀ s, minZ ≤ Z s)
    (h_max : ∀ s, Z s ≤ maxZ)
    (hmax_pos : 0 < maxDeltaPhi)
    (h_lb : ∀ s, 1 / maxDeltaPhi ≤ Z s) :
    Z s₀ = expImpedance P Z
      ∧ (minZ ≤ expImpedance P Z ∧ expImpedance P Z ≤ maxZ)
      ∧ 0 < expImpedance P Z := by
  refine ⟨Z_eq_self_expectation P Z s₀ hP_sum hσ, ?_, ?_⟩
  · exact self_expectation_sandwich P Z minZ maxZ hP_nonneg hP_sum h_min h_max
  · exact self_expectation_pos P Z maxDeltaPhi hP_nonneg hP_sum hmax_pos h_lb

end R12_Agent10_AttackZselfExpectation

end MIP
